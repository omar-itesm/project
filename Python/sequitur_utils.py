from sksequitur import parse
from sksequitur import Parser
from sksequitur import Grammar
from sksequitur import Mark
from sksequitur import Production

from collections import Counter

import os, os.path
from pandas import Series
import copy
import random
import tempfile
import shutil


# Grammars
def createGrammarForPlays(input_filename):
    '''
    The function receives the filename of a set of plays encoded as characters and finds the
    grammar that describe the plays.
    '''

    # num_plays = 0

    parser = Parser()

    with open(input_filename) as fp:
        for line in fp:
            # num_plays += 1
            current_line = line.strip()
            current_line = current_line.split()
            parser.feed(current_line)
            parser.feed([Mark()])

    grammar = Grammar(parser.tree)

    return grammar


def createGrammarForPlaysComplete(input_file):
    """
    The function creates the grammar and ensures no rule repetitions occur which are an artifact
    of the separation of the input sequence into multiple sequences.
    """
    # NOTE: Commenting out as sorting is now expected to be done externally.
    ## Sort the input to reduce the repeated rules probability
    # sorted_input_file = './tmp_sorted.txt'
    # status = orderPlaysByLength(input_file, sorted_input_file)

    # Create grammar
    grammar = createGrammarForPlays(input_file)

    no_repeated_rules = False

    while not no_repeated_rules:
        # Fix the grammar
        grammar = removeRepeatedRules(grammar)

        new_input_file = "./tmp_input.txt"
        grammarToSeqIn(grammar, new_input_file)

        compound_grammar = createGrammarForPlays(new_input_file)

        grammar = addRulesToGrammar(grammar, compound_grammar)

        grammar = removeSingleRules(grammar)

        same_rule_cnt = sameRuleCounter(grammar, grammar)

        no_repeated_rules = max(same_rule_cnt.values()) == 1

    return grammar


def removeSingleRules(grammar):
    """
    Due to manipulation of the grammar, there are scenarios where we end up with rules of a single element which
    can be seen as a rule that points to another rule. This function makes sure that such rules are safely removed.
    """

    grammar_cp = copy.deepcopy(grammar)

    for key, value in grammar_cp.items():
        if len(value) == 1:
            grammar = replaceGrammarRule(grammar, key, value[0])

    return grammar


def grammarToFile(grammar, output_filename):
    '''
    The function receives a grammar, computes the different support metrics and writes the rules to a file
    together with their support. The output filename is also received as a parameter.
    '''
    # TODO: Add the intra class support...

    # Count the number of plays
    num_plays = len(extractPlaysFromGrammar(grammar))

    # Direct rule frequency
    drf = dict(grammar.counts())

    # Raw play frequency
    rpf = computeGrammarRPF(grammar)

    # Play frequency
    pf = computeGrammarPF(grammar)

    with safe_open_w(output_filename) as file_object:
        line = f"Rule,Raw,Expand,RRF,DF,RPF,PF,PF%,RPF/PF\n"
        file_object.write(line)
        for rule in grammar.keys():
            if rule != 0:
                rrf = computeRRF(grammar, rule)
                _drf = drf[rule]
                _rpf = rpf[rule]
                _pf = pf[rule]

                if _pf == 0:
                    _pf = 0.000001

                if num_plays == 0:
                    num_plays = 0.000001

                line = f"{rule},\"{grammar[rule]}\",\"{list(grammar.expand(rule))}\",{rrf},{_drf},{_rpf},{_pf:.0f},{(_pf / num_plays) * 100:.2f},{_rpf / _pf:.2f}\n"
                file_object.write(line)


def createGrammarFileForPlays(input_filename, output_filename):
    '''
    The function receives the filename of a set of plays encoded as characters, finds the grammar that describe
    the plays and finally writes the grammar to a file.
    '''

    grammar = createGrammarForPlays(input_filename)

    grammarToFile(grammar, output_filename)


def createGrammarFileForPlaysComplete(input_filename, output_filename):
    '''
    The function receives the filename of a set of plays encoded as characters, finds the grammar that describe
    the plays and finally writes the grammar to a file.
    '''

    grammar = createGrammarForPlaysComplete(input_filename)

    grammarToFile(grammar, output_filename)


# Frequency
def computeRRF(grammar, rule):
    '''
    The function computes the 'real rule frequency' of a given rule.
    '''
    if rule == 0:
        return 1

    total_freq = 0
    for op in grammar.keys():
        if rule in grammar[op]:
            prod_in_op_cnt = Counter(grammar[op])
            prod_in_op_sup = prod_in_op_cnt[rule]
            total_freq = total_freq + prod_in_op_sup * computeRRF(grammar, op)

    return total_freq


def computeGrammarRRF(grammar):
    '''
    The function computes the 'real rule frequency' for all the rules in the grammar.

    The 'real rule frequency' corresponds to how many times a given rule is used in the rule 0 considering
    that the rule could be nested in other rules. This is not the same metric as grammar.counts()
    '''
    grammar_rrf = {rule: computeRRF(grammar, rule) for rule in grammar.keys() if rule != 0}
    return grammar_rrf


def computeGrammarRPF(grammar):
    '''
    The function computes the 'Raw Play Frequency' of the rules in the grammar and returns it
    as a dictionary where the keys are the grammar rules and the values the 'Raw Play Frequency'
    '''

    plays = extractPlaysFromGrammar(grammar)

    prev_plays_c = Counter()  # Used to count the number of times the rule appears in the plays
    sid = {}  # Used to hold the ids of the plays where the rule appears
    play_id = 1
    for play in plays:
        # Filter the play to contain only productions
        play = [event for event in play if isinstance(event, Production)]

        # Create the counter
        plays_c = Counter(play)
        plays_c = prev_plays_c + plays_c
        prev_plays_c = plays_c

    return plays_c


def computeGrammarPF(grammar):
    '''
    The function computes the 'Play Frequency'. This is different from the 'Raw Play Frequency' in that
    rules only count once per play.
    '''

    plays = extractPlaysFromGrammar(grammar)

    prev_plays_c = Counter()  # Used to count the number of times the rule appears in the plays
    sid = {}  # Used to hold the ids of the plays where the rule appears
    play_id = 1
    for play in plays:
        # Filter the play to contain only productions
        play = [event for event in play if isinstance(event, Production)]
        play = list(set(play))

        # Create the counter
        plays_c = Counter(play)
        plays_c = prev_plays_c + plays_c
        prev_plays_c = plays_c

    return plays_c


def extractPlaysFromGrammar(grammar):
    '''
    The function reads a grammar of a football game and returns rule 0 (the plays)
    as an array where each element in the array is a play compressed by the rules
    of the grammar.
    '''
    plays = grammar[0]

    size = len(plays)
    idx_list = [idx + 1 for idx, val in
                enumerate(plays) if isinstance(val, Mark)]

    plays = [plays[i: j - 1] for i, j in
             zip([0] + idx_list, idx_list +
                 ([size] if idx_list[-1] != size else []))]

    return plays


def compressPlaysFile(input_filename, output_filename):
    '''
    The function reads a plays file encoded for Sequitur, creates the grammar and
    extracts the compressed plays from the grammar. Finally it writes the compress
    plays to a file.

    The function returns the length of the compressed plays.

    TODO: This function and the grammarToFile function may be a single function.
    '''
    grammar = createGrammarForPlays(input_filename)
    # grammarToFile(grammar, output_filename)

    plays = extractPlaysFromGrammar(grammar)
    compressed_lengths = [len(x) for x in plays]

    writeCompressedPlaysFile(plays, output_filename)

    return compressed_lengths


def compressPlaysFileComplete(input_filename, output_filename):
    '''
    The function reads a plays file encoded for Sequitur, creates the grammar and
    extracts the compressed plays from the grammar. Finally it writes the compress
    plays to a file.

    The function returns the length of the compressed plays.

    TODO: This function and the grammarToFile function may be a single function.
    '''
    grammar = createGrammarForPlaysComplete(input_filename)
    # grammarToFile(grammar, output_filename)

    plays = extractPlaysFromGrammar(grammar)
    compressed_lengths = [len(x) for x in plays]

    writeCompressedPlaysFile(plays, output_filename)

    return compressed_lengths


def writeCompressedPlaysFile(plays, output_filename):
    '''
    The function reads a list of plays and writes it to a file
    '''
    with safe_open_w(output_filename) as file_object:
        for play in plays:
            file_object.write(str(play) + '\n')


def getPlayLengthsFromFile(input_file):
    play_lengths = []

    with open(input_file) as fp:
        for line in fp:
            current_line = line.strip()
            current_line = current_line.split()
            play_lengths.append(len(current_line))

    return play_lengths


# General utilities
def safe_open_w(path):
    ''' Open "path" for writing, creating any parent directories as needed.
    '''
    os.makedirs(os.path.dirname(path), exist_ok=True)
    return open(path, 'w')


def sameRuleCounter(ref_g, other_g):
    rule_cnt_dict = {}
    for ref_rule in ref_g.keys():
        if ref_rule == 0:
            continue

        ref_g_expanded = list(ref_g.expand(ref_rule))

        cnt = 0
        for other_rule in other_g.keys():
            if other_rule == 0:
                continue

            other_g_expanded = list(other_g.expand(other_rule))

            if other_g_expanded == ref_g_expanded:
                cnt = cnt + 1

        rule_cnt_dict[ref_rule] = cnt
    return rule_cnt_dict


def orderPlaysByLength(input_file, output_file):
    """
    Receives a file and outputs the sorted version of the file by
    row length.
    NOTE:
    - To ensure the proper behavior, the input file must end with a new line!!
    """

    with open(input_file) as in_file:
        my_list = in_file.readlines()

    # Include index before sorting
    my_list = list(enumerate(my_list))
    my_list = sorted(my_list, key=lambda x: len(x[1]))

    # Get the new string to write the sorted file
    ordered_plays = [x[1] for x in my_list]
    sorted_string = ''.join(ordered_plays)

    original_index = [x[0] for x in my_list]

    with safe_open_w(output_file) as file_object:
        file_object.write(sorted_string)

    return original_index


def replaceGrammarRule(grammar, old_rule, new_rule):
    for rule in grammar.keys():
        current_rule = grammar[rule]

        modified_rule = [new_rule if production == old_rule else production for production in current_rule]
        grammar[rule] = modified_rule

    grammar.pop(old_rule, None)

    return grammar


def removeRepeatedRules(grammar):
    """
    The function removes repeated rules from the input grammar.

    NOTE:
    - Input is being modified in this function
    """

    # Filter by frequency
    freq_thresh = 2

    # Find repeated rules above threshold and sort them according to the number of repetitions
    same_rule_cnt = sameRuleCounter(grammar, grammar)

    filtered_same_rule_cnt = {x: count for x, count in same_rule_cnt.items() if count >= freq_thresh}
    filtered_same_rule_cnt = dict(sorted(filtered_same_rule_cnt.items(), key=lambda item: item[1], reverse=True))

    # Obtain their expanded form
    expanded_repetitions = {key: list(grammar.expand(key)) for key, count in filtered_same_rule_cnt.items()}
    expanded_repetitions_sort = dict(sorted(expanded_repetitions.items(), key=lambda item: item[1], reverse=True))

    # Replace repeated rules in grammar
    prev_value = []
    for key, value in expanded_repetitions_sort.items():

        is_first_repetition = prev_value != value
        if not is_first_repetition:
            # Replace the repeated rules
            old_rule = key
            new_rule = first_key
            grammar = replaceGrammarRule(grammar, old_rule, new_rule)
        else:
            first_key = key

        prev_key = key
        prev_value = value

    # This is just for simplicity but not needed as the original grammar
    # is being modified in the function call
    return grammar


# Generate new text file for Sequitur from the modified grammar. Each rule is treated as a sequence
def grammarToSeqIn(grammar, filename):
    """
    The function converts a grammar into a new input for Sequitur.
    This is used to find patterns in the grammar that may appear after applying the rule reduction step
    which ensures no repeated rules appear.
    """

    line = ''

    with safe_open_w(filename) as file_object:

        for rule, value in grammar.items():
            for production in value:
                if not isinstance(production, Mark):
                    line = line + f" {production}"
                else:
                    line = line + '\n'
                    file_object.write(line)
                    line = ''

            if line:
                line = line + '\n'
            file_object.write(line)
            line = ''


def convertStringToRule(s):
    """
    Converts a string representing a rule into a rule
    """
    s = s.split(" ")
    for i in range(len(s)):
        if s[i] == '|':
            s[i] = Mark()
        elif s[i].isdigit():
            s[i] = Production(s[i])
    return s


def convertRuleToString(rule):
    """
    It converts the rule list to a string.
    """
    rule = ' '.join(map(str, rule))
    return rule


def replacePatternByRule(grammar, pattern, new_rule):
    """
    Example:
        pattern = '42 C'
        new_rule = '600'

        grammar = replacePatternByRule(grammar, pattern, new_rule)
    """
    for rule_number, rule in grammar.items():
        rule_string = convertRuleToString(rule)
        rule_string = ' ' + rule_string + ' '  # Add space to ensure proper text replacement
        #        print(rule_string)
        rule_string = rule_string.replace(' ' + pattern + ' ', ' ' + new_rule + ' ')
        #        print(rule_string)
        replacement = convertStringToRule(rule_string[1:-1:])

        grammar[rule_number] = replacement

        # print(rule_number)
        # print(replacement)

    return grammar


def addRulesToGrammar(output_grammar, other_grammar):
    """
    The function receives two grammars. One is the output grammar and the other is the grammar where the new rules will be taken from. All rules in the other grammar except for rule 0 are taken and the output grammar is modified to correctly state the rules in terms of the new rules where applicable.

    NOTE:
    - The function modifies the output_grammar input, that is, the output is stored in the input.
    """

    # Add the new rules to the original grammar

    last_rule = int(max(output_grammar))

    num_rules_other_grammar = len(other_grammar) - 1

    # Look for rules in the other grammar and replace them if necessary
    other_tmp = copy.deepcopy(other_grammar)
    for rule, production in other_tmp.items():
        new_rule = []
        needs_replacement = False
        if rule != 0:
            for elem in production:
                if isinstance(elem, Production):
                    new_rule_num = int(elem) + last_rule
                    new_rule.append(str(new_rule_num))
                    needs_replacement = True
                else:
                    new_rule.append(elem)

            other_grammar[rule] = new_rule
            if needs_replacement:
                pattern_to_replace = convertRuleToString(other_tmp.expand(rule))
                output_grammar = replacePatternByRule(output_grammar, pattern_to_replace, convertRuleToString(new_rule))

    # Append the new rules to the existing grammar safely
    for rule, production in other_grammar.items():
        if rule != 0:

            new_rule_index = last_rule + 1
            ###########################################
            # Replace occurrences of new rules
            pattern_to_replace = convertRuleToString(production)

            output_grammar = replacePatternByRule(output_grammar, pattern_to_replace, str(new_rule_index))

            ##########################################
            # Add the new rule

            # print(production)

            new_rule = []
            for elem in production:

                if elem.isdigit():
                    new_rule.append(Production(int(elem)))
                else:
                    new_rule.append(elem)

            # print(new_rule)

            # Modify the old grammar
            output_grammar[Production(new_rule_index)] = new_rule
            # print(grammar)

            last_rule += 1

    return output_grammar


def createSubGrammar(play_vector, grammar):
    """
    The function creates a dummy grammar (only rule 0) from a set of plays.
    The set of plays needs to be a subset of the plays used to compute the
    input grammar.
    """

    parser = Parser()
    subgrammar = Grammar(parser.tree)

    # Create grammar rules
    rule0 = []
    for play in play_vector:
        for elem in play:
            rule0.append(elem)
            if (elem not in subgrammar) and (isinstance(elem, Production)):
                subgrammar = addRuleToSubGrammar(grammar, subgrammar, elem)

        rule0.append(Mark())

    subgrammar[Production(0)] = rule0

    return subgrammar


def addRuleToSubGrammar(grammar, subgrammar, rule):
    subgrammar[Production(rule)] = grammar[rule]

    if all(isinstance(x, str) for x in grammar[rule]):
        return subgrammar

    sub_rules = [x for x in grammar[rule] if isinstance(x, Production)]

    for subrule in sub_rules:
        if subrule not in subgrammar:
            subgrammar = addRuleToSubGrammar(grammar, subgrammar, subrule)

    return subgrammar


def getClassLabelDescription(label):
    class_labels = {
        0: 'Failed',
        1: 'Goal',
        2: 'Shot',
        3: 'Pass_to_goal',
        4: 'Definition_sector',
        5: 'Success'
    }

    return class_labels[label]


def createGrammarIntraClassReportForPlays(plays_filename, play_labels_filename, report_folder):
    # Compute grammar
    # grammar = createGrammarForPlaysComplete(plays_filename)
    grammar, optimal_order_plays_file, optimal_order_play_labels_file = searchShortestGrammar(plays_filename,
                                                                                              play_labels_filename)

    grammarToFile(grammar, report_folder + 'All_rules.csv')

    # Extract compressed plays from grammar
    plays = extractPlaysFromGrammar(grammar)
    plays = Series(plays)

    writeCompressedPlaysFile(plays, report_folder + 'All_compressedPlays.txt')

    # Parse play labels
    play_labels_file = open(optimal_order_play_labels_file, "r")
    play_labels = play_labels_file.read()
    play_labels_file.close()

    play_labels = [int(x) for x in play_labels.split()]
    play_labels = Series(play_labels)

    for label in play_labels.unique():
        class_plays = plays[play_labels == label]

        subgrammar = createSubGrammar(class_plays, grammar)

        # Write compressed play files
        subplays = extractPlaysFromGrammar(subgrammar)
        compressed_filename = report_folder + getClassLabelDescription(label) + '_compressedPlays.txt'
        writeCompressedPlaysFile(subplays, compressed_filename)

        # Write rule files
        grammar_filename = report_folder + getClassLabelDescription(label) + '_rules.csv'

        grammarToFile(subgrammar, grammar_filename)


def createGrammarIntraClassReportForPlays2(plays_filename, play_labels_filename, report_folder):
    # Compute grammar
    # grammar = createGrammarForPlaysComplete(plays_filename)
    grammar, optimal_order_plays_file, original_index = searchShortestGrammar2(plays_filename)

    grammarToFile(grammar, report_folder + 'All_rules.csv')

    # Extract compressed plays from grammar
    plays = extractPlaysFromGrammar(grammar)  # The plays come in the new optimal order
    plays = Series(plays)

    # Sort the plays according to the original index to ensure the labels match the plays
    plays = [x for y, x in sorted(zip(original_index, plays))]
    plays = Series(plays)

    # Write compressed plays
    writeCompressedPlaysFile(plays, report_folder + 'All_compressedPlays.txt')

    # Parse play labels (original order)
    play_labels_file = open(play_labels_filename, "r")
    play_labels = play_labels_file.read()
    play_labels_file.close()

    play_labels = [int(x) for x in play_labels.split()]
    play_labels = Series(play_labels)

    for label in play_labels.unique():
        class_plays = plays[play_labels == label]

        subgrammar = createSubGrammar(class_plays, grammar)

        # Write compressed play files
        subplays = extractPlaysFromGrammar(subgrammar)
        compressed_filename = report_folder + getClassLabelDescription(label) + '_compressedPlays.txt'
        writeCompressedPlaysFile(subplays, compressed_filename)

        # Write rule files
        grammar_filename = report_folder + getClassLabelDescription(label) + '_rules.csv'

        grammarToFile(subgrammar, grammar_filename)


def mergePlaysAndLabelsFiles(plays_file, play_labels_file, output_file):
    """
    The function merges a plays file with a play labels file line by line using a separator character.
    """
    separator = ','

    with open(plays_file) as xh:
        with open(play_labels_file) as yh:
            with open(output_file, "w") as zh:
                # Read first file
                xlines = xh.readlines()

                # Read second file
                ylines = yh.readlines()

                # Combine content of both lists  and Write to third file
                for line1, line2 in zip(ylines, xlines):
                    zh.write("{}{}{}\n".format(line1.rstrip(), separator, line2.rstrip()))


def searchShortestGrammar2(input_file):
    """
    The function runs the Sequitur algorithm multiple times by changing the order of the input multiple times.
    The shortest of the generated grammars is kept. The function returns the order of the plays in the original file.
    """

    # For reproducibility of the results
    random.seed(42)

    num_shuffles = 150

    # Read the original file
    lines = open(input_file).readlines()
    lines_with_original_order = list(enumerate(lines))

    with tempfile.TemporaryDirectory() as tmpdir:

        # Initialize the shortest grammar using the ordered plays
        shuffled_plays_file = os.path.join(tmpdir, 'shuffled.txt')
        original_index = orderPlaysByLength(input_file, output_file=shuffled_plays_file)
        shortest_grammar = createGrammarForPlaysComplete(shuffled_plays_file)
        len_shortest_grammar = len(shortest_grammar)

        # Store the current optimal order
        optimal_order_plays = 'shuffled_plays.txt'
        optimal_order_orig_index = original_index
        shutil.copyfile(shuffled_plays_file, optimal_order_plays)

        # Compute the grammar for random permutations of the original file
        for i in range(num_shuffles):

            # Shuffle lines and create a temporary file with the result
            random.shuffle(lines_with_original_order)
            original_index, shuffled_lines = zip(*lines_with_original_order)

            with open(shuffled_plays_file, 'w') as file:
                file.writelines(shuffled_lines)

            # Create a new grammar using the shuffled file
            grammar = createGrammarForPlaysComplete(shuffled_plays_file)

            # Keep the smallest grammar
            if len(grammar) < len_shortest_grammar:
                shortest_grammar = grammar
                len_shortest_grammar = len(shortest_grammar)

                # Create non-temporary version of the shuffle plays and labels that create the shortest grammar
                shutil.copyfile(shuffled_plays_file, optimal_order_plays)

                optimal_order_orig_index = original_index

    return shortest_grammar, optimal_order_plays, optimal_order_orig_index


def searchShortestGrammar(input_file, play_labels_filename=None):
    """
    The function runs the Sequitur algorithm multiple times by changing the order of the input multiple times.
    The shortest of the generated grammars is kept.
    """

    num_shuffles = 150  # Tune for different purposes

    with tempfile.TemporaryDirectory() as tmpdir:

        # Read the plays file
        if play_labels_filename is None:
            # Read the contents of the original file
            _input_file = input_file
            optimal_order_play_labels = None
        else:
            # Merge the play and play labels into one file
            _input_file = os.path.join(tmpdir, 'merged_input.txt')
            mergePlaysAndLabelsFiles(input_file, play_labels_filename, _input_file)
            optimal_order_play_labels = 'shuffled_play_labels.txt'

        lines = open(_input_file).readlines()
        optimal_order_plays = 'shuffled_plays.txt'

        # Temporary file for shuffling
        shuffled_plays_file = os.path.join(tmpdir, 'shuffled.txt')

        # Compute the grammar in an ordered version of the original file and initialize shortest grammar
        orderPlaysByLength(_input_file, shuffled_plays_file)

        if play_labels_filename is not None:
            shuffled_play_labels_file = os.path.join(tmpdir, 'shuffled_labels.txt')
            separatePlaysAndLabelsFiles(shuffled_plays_file, plays_file=shuffled_plays_file,
                                        labels_file=shuffled_play_labels_file)

        shortest_grammar = createGrammarForPlaysComplete(shuffled_plays_file)
        len_shortest_grammar = len(shortest_grammar)

        # Create non-temporary version of the shuffle plays and labels that create the shortest grammar
        shutil.copyfile(shuffled_plays_file, optimal_order_plays)
        if play_labels_filename is not None:
            shutil.copyfile(shuffled_play_labels_file, optimal_order_play_labels)

        # Compute the grammar for random permutations of the original file
        for i in range(num_shuffles):

            # Shuffle the lines of the original file and create a temporary file
            random.shuffle(lines)
            with open(shuffled_plays_file, 'w') as file:
                file.writelines(lines)

            if play_labels_filename is not None:
                shuffled_play_labels_file = os.path.join(tmpdir, 'shuffled_labels.txt')
                separatePlaysAndLabelsFiles(shuffled_plays_file, plays_file=shuffled_plays_file,
                                            labels_file=shuffled_play_labels_file)

            # Create a new grammar using the shuffled file
            grammar = createGrammarForPlaysComplete(shuffled_plays_file)

            # Keep the smallest grammar
            if len(grammar) < len_shortest_grammar:
                shortest_grammar = grammar
                len_shortest_grammar = len(shortest_grammar)

                # Create non-temporary version of the shuffle plays and labels that create the shortest grammar
                shutil.copyfile(shuffled_plays_file, optimal_order_plays)
                if play_labels_filename is not None:
                    shutil.copyfile(shuffled_play_labels_file, optimal_order_play_labels)

    return shortest_grammar, optimal_order_plays, optimal_order_play_labels


def separatePlaysAndLabelsFiles(compound_file, plays_file='plays.txt', labels_file='labels.txt'):
    # Read compound file
    with open(compound_file, 'r') as file:
        lines = file.readlines()

        tmp = [l.split(',') for l in lines]

        labels = [l[0] + '\n' for l in tmp]
        plays = [l[1] for l in tmp]

    # Write the plays file
    with open(plays_file, 'w') as pf:
        pf.writelines(plays)
        pf.flush()
        os.fsync(pf)

    # Write the labels file
    with open(labels_file, 'w') as lf:
        lf.writelines(labels)
        lf.flush()
        os.fsync(lf)

