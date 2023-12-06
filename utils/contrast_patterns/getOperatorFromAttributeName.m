function [attribute_name, operator] = getOperatorFromAttributeName(attribute_name)
    tokens   = regexp(attribute_name, '_', "split");
    operator = tokens{end};
    attribute_name = strjoin({(tokens{1:end-1})},'_');
end