function [positive_class_support, negative_class_support] = supportString2double(support_string)
    
    % Remove the initial and final characters
    support = support_string(2:end-1);
    
    support = regexp(support, ' ', 'split');
    
    positive_class_support = str2double(support{1});
    negative_class_support = str2double(support{2});
end