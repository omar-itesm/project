function data = createDataForWeka(attr_names, attr_data, info, class_data, varargin)
% The function receives the names of the attributes, the corresponding data
% and the class data and it formats it for Weka.
% It is expected that the attribute names have one name per column and the
% attr_data has one column per attribute name.

%% Argument parsing
    default_contrast  = 'shot_goal_vs_rest'; % The traditional definition of success in this thesis
    valid_contrasts   = {'shot_goal_vs_rest','goal_vs_shot'};
    
    p = inputParser;
    
    addRequired(p, 'attr_names' , @(x) isa(x,'uint64') | isa(x,'double'));
    addRequired(p, 'attr_data'  , @(x) isa(x,'double'));
    addRequired(p, 'info'       , @(x) isa(x,'struct'));
    addRequired(p, 'class_data' , @(x) isa(x,'double'));
    
    addParameter(p, 'contrast_type', default_contrast, @(x) any(validatestring(x,valid_contrasts)));

    parse(p, attr_names, attr_data, info, class_data, varargin{:});
    
    contrast_type           = p.Results.contrast_type;

%% Code

    % Local variables
    GOAL_LABEL = 1;
    SHOT_LABEL = 2;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create the class vector
    data.class.name     = 'class';
    class_data_nominal  = strings(size(class_data));

    % Regardless of the contrast, we will preserve the notion of two
    % classes that are referred to as success and fail.
    switch contrast_type
        case 'shot_goal_vs_rest'
            is_success = class_data == GOAL_LABEL | class_data == SHOT_LABEL;
            is_failure = ~is_success;
        case 'goal_vs_shot'
            is_success = class_data == GOAL_LABEL;
            is_failure = class_data == SHOT_LABEL;
        otherwise
            warning('Unexpected contrast type found in createDataForWeka.m')
    end

    % Declare the classes based on the target contrast
    class_data_nominal(is_success)  = 'success';
    class_data_nominal(is_failure) = 'fail';
    
    % Remove all observations that are not relevant for the target contrast
    valid_observations = ~strcmp(class_data_nominal,'');
    class_data_nominal = class_data_nominal(valid_observations);
    
    data.class.data = class_data_nominal;
    data.class.type = 'nominal';
    
    data.class.nominalspec = 'success,fail';

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create the tactic attributes
    
    for i = 1:numel(attr_names)
        current_attr = attr_names(i);
        attr_name = strcat('Tactic_', num2str(current_attr));
        
        has_attr     = attr_data(:,i) == 1;
        data_nominal = strings(size(attr_data(:,1)));
        data_nominal(has_attr)  = 't';
        data_nominal(~has_attr) = 'f';
        
        current_field = createFieldForWeka(attr_name, data_nominal);
        current_field.data = current_field.data(valid_observations);

        data.(attr_name) = current_field;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create the plays info attributes
    
    for f=fieldnames(info)'
        attr_name = f{1};
        current_attr_data = info.(attr_name);
        
        current_field = createFieldForWeka(attr_name, current_attr_data);
        current_field.data = current_field.data(valid_observations);
        
        data.(attr_name) = current_field;
    end
    
    


end

function field = createFieldForWeka(name, data, varargin)

    % TODO: Add support for non-numeric fields

    field.name = name;
    field.data = data;
    
    if isa(data, 'string') 
        field.type = 'nominal';
        field.nominalspec = strjoin(unique(data),',');
    elseif isa(data, 'double')
        field.type = 'real';
    else
        disp('TODO');
    end

end