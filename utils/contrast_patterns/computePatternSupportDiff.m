function support_diff = computePatternSupportDiff(support_string, varargin)
% The function receives the contrast pattern support as a string and
% computes the support difference metric. Using input parameters we can
% choose between signed or unsigned support difference.

    default_output_type = 'unsigned';
    valid_output_types  = {'unsigned', 'signed'};
    
    p = inputParser;
    
    addRequired(p, 'support_string', @(x) isa(x, 'char'));
    addParameter(p, 'output_type', default_output_type, @(x) any(validatestring(x, valid_output_types)));
    
    parse(p, support_string, varargin{:});
    
    output_type = p.Results.output_type;
    
    [positive_class_support, negative_class_support] = supportString2double(support_string);
    
    support_diff = positive_class_support - negative_class_support;
    
    if strcmp(output_type, 'unsigned')
        support_diff = abs(support_diff);
    end
    
    

end