function [direct_corner_file_struct, indirect_corner_file_struct] = createCornerKickAnalysisOutputFileStructure(varargin)
% The function creates the file structure used to store the output from the
% tactical and strategical analysis of direct and indirect corner kicks.

%% Argument parsing
default_base_folder      = '/output/Corner/';

p = inputParser;

addParameter(p, 'outputFolder'    , default_base_folder);

parse(p, varargin{:});

output_folder           = p.Results.outputFolder;

%% Code

    direct_base_folder   = [pwd, '/', output_folder, 'By Region/AGM/Direct/'];
    indirect_base_folder = [pwd, '/', output_folder, 'By Region/AGM/Indirect/'];

    direct_corner_file_struct   = createDirectCornerKickOutputFileStructure(direct_base_folder);
    indirect_corner_file_struct = createIndirectCornerKickOutputFileStructure(indirect_base_folder);
end

function file_structure = createDirectCornerKickOutputFileStructure(base_folder)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tactic_stats_folder   = strcat(base_folder, 'Tactic probabilities/');
    if ~exist(tactic_stats_folder, 'dir')
       mkdir(tactic_stats_folder)
    end
    
    file_structure.tactic_stats_folder = tactic_stats_folder;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    strategy_tables_folder = strcat(base_folder, 'Strategy tables/');
    if ~exist(strategy_tables_folder, 'dir')
       mkdir(strategy_tables_folder)
    end
    
    file_structure.strategy_tables_folder = strategy_tables_folder;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    strategy_tables_complete_folder = [strategy_tables_folder, 'Complete/'];
    if ~exist(strategy_tables_complete_folder, 'dir')
       mkdir(strategy_tables_complete_folder)
    end
    
    file_structure.strategy_tables_complete_folder = strategy_tables_complete_folder;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tactic_plots_folder = strcat(base_folder, 'Plots/Tactics/');
    if ~exist(tactic_plots_folder, 'dir')
       mkdir(tactic_plots_folder)
    end
    
    file_structure.tactic_plots_folder = tactic_plots_folder;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    contrast_patterns_folder = strcat(base_folder, 'Contrast patterns/PBC4cip/');
    if ~exist(contrast_patterns_folder, 'dir')
       mkdir(contrast_patterns_folder)
    end
    
    file_structure.contrast_patterns_folder = contrast_patterns_folder;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    contrast_patterns_complete_folder = strcat(contrast_patterns_folder, 'Complete/');
    if ~exist(contrast_patterns_complete_folder, 'dir')
       mkdir(contrast_patterns_complete_folder)
    end
    
    file_structure.contrast_patterns_complete_folder = contrast_patterns_complete_folder;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create folders to store internal variables of the current run
    
    data_folder = strcat(base_folder, 'data/');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    contrast_patterns_variables_folder = strcat(data_folder, 'Contrast patterns/');
    if ~exist(contrast_patterns_variables_folder, 'dir')
       mkdir(contrast_patterns_variables_folder)
    end
    
    file_structure.contrast_patterns_variables_folder = contrast_patterns_variables_folder; 
end

function file_structure = createIndirectCornerKickOutputFileStructure(base_folder)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rules_folder   = strcat(base_folder, 'Sequitur/grammar_rules/');
    if ~exist(rules_folder, 'dir')
       mkdir(rules_folder)
    end
    
    file_structure.rules_folder = rules_folder;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    encoded_plays_folder = strcat(base_folder, 'Sequitur/encoded_plays/');
    if ~exist(encoded_plays_folder, 'dir')
       mkdir(encoded_plays_folder)
    end
    
    file_structure.encoded_plays_folder = encoded_plays_folder;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    strategy_tables_folder = strcat(base_folder, 'Strategy tables/');
    if ~exist(strategy_tables_folder, 'dir')
       mkdir(strategy_tables_folder)
    end
    
    file_structure.strategy_tables_folder = strategy_tables_folder;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    strategy_tables_complete_folder = [strategy_tables_folder, 'Complete/'];
    if ~exist(strategy_tables_complete_folder, 'dir')
       mkdir(strategy_tables_complete_folder)
    end
    
    file_structure.strategy_tables_complete_folder = strategy_tables_complete_folder;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tactic_plots_folder = strcat(base_folder, 'Plots/Tactics/');
    if ~exist(tactic_plots_folder, 'dir')
       mkdir(tactic_plots_folder)
    end
    
    file_structure.tactic_plots_folder = tactic_plots_folder;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    contrast_patterns_folder = strcat(base_folder, 'Contrast patterns/PBC4cip/');
    if ~exist(contrast_patterns_folder, 'dir')
       mkdir(contrast_patterns_folder)
    end
    
    file_structure.contrast_patterns_folder = contrast_patterns_folder;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    contrast_patterns_complete_folder = strcat(contrast_patterns_folder, 'Complete/');
    if ~exist(contrast_patterns_complete_folder, 'dir')
       mkdir(contrast_patterns_complete_folder)
    end
    
    file_structure.contrast_patterns_complete_folder = contrast_patterns_complete_folder;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create folders to store internal variables of the current run
    
    data_folder = strcat(base_folder, 'data/');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    contrast_patterns_variables_folder = strcat(data_folder, 'Contrast patterns/');
    if ~exist(contrast_patterns_variables_folder, 'dir')
       mkdir(contrast_patterns_variables_folder)
    end
    
    file_structure.contrast_patterns_variables_folder = contrast_patterns_variables_folder; 
end


