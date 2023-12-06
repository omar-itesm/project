function createFileForWeka(data, out_filename, varargin)
% The function receives a data struct which contains a named field for each
% of the observations in the data. All fields are expected to be of the
% same size so that their index can be used as the identifier for the
% observation.
% One of the fields of the data struct must be named 'class' which would be
% used as the class of the data for Weka.
% All fields of the struct shall contain a name and a Weka type attribute
% together with the data. If the type is 'nominal' a comma separated string
% of the possible values must be provided in the field 'nominalspec'.

    fid = fopen(out_filename, 'w');

    try

        field_names = fields(data);

        % Create the header
        [~, filename, ~] = fileparts(out_filename);

        fprintf(fid, '@RELATION %s\r\n\r\n', filename);


        for i = 1:numel(field_names)
            feature_name = data.(field_names{i}).name;
            type         = data.(field_names{i}).type;

            is_nominal = strcmp(type, 'nominal');

            if ~is_nominal
                fprintf(fid, '@ATTRIBUTE %s\t%s\r\n', feature_name, type);
            else
                nominal_spec = data.(field_names{i}).nominalspec;
                fprintf(fid, '@ATTRIBUTE %s\t{%s}\r\n', feature_name, nominal_spec);
            end
        end

        fprintf(fid, '\r\n');

        % Create the data section

        fprintf(fid, '@DATA \r\n');

        num_data = numel(data.(field_names{i}).data);

        for i = 1:num_data

            s = ''; % Initialize empty row
            for j = 1:numel(field_names)
                value = data.(field_names{j}).data(i);
                
                if isa(value,'double')
                    if isnan(value)
                        % value = -1;
						value = "?"; % Missing values: https://www.cs.waikato.ac.nz/ml/weka/arff.html
                    end
                end

                s = [s, string(value)];
            end
            
            s = s(2:end);    % Strip initial value
            s = join(s,',');

            fprintf(fid, '%s\r\n', s);
        end
        
    catch e
        fclose(fid);
        throw(e);
    end

    fclose(fid);
    
end

% function mapTypeToWeka(datatype)
% % The function receives a datatype from MATLAB and it maps it to a datatype
% % in Weka.
% 
% end