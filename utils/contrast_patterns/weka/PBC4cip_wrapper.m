function PBC4cip_wrapper(input_file, output_file, varargin)
    %% Parse arguments
    default_filter_enable = 'false'; % Passing an empty string will make the algorithm take default values
    default_max_depth     = 4; % Corresponds to three clauses at most
    default_num_trees     = 150;
    default_node_split_measure = 'Hellinger'; % Default from PBC4cip article
    
    
    valid_split_measures    = {'Hellinger', 'Quinlan'};
    
    p = inputParser;
    
    addRequired(p, 'inputFile' , @(x) isa(x, 'string'));
    addRequired(p, 'outputFile', @(x) isa(x, 'string'));
    
    addParameter(p, 'filtering'             , default_filter_enable , @(x) isa(x, 'char'));
    addParameter(p, 'max_depth'             , default_max_depth     , @(x) isa(x, 'double'));
    addParameter(p, 'num_trees'             , default_num_trees     , @(x) isa(x, 'double'));
    addParameter(p, 'node_split_measure'    , default_node_split_measure, @(x) any(validatestring(x,valid_split_measures)));
    
    parse(p, input_file, output_file, varargin{:});
    
    filtering  = p.Results.filtering;
    max_depth  = p.Results.max_depth;
    num_trees  = p.Results.num_trees;
    node_split_meas  = p.Results.node_split_measure;

    %% Run the java code

    [filepath,~,~] = fileparts(mfilename('fullpath'));
    jar_location = [filepath '\PBC4cip.jar'];
    
    command = sprintf('java -Xmx1024m -jar "%s" "%s" "%s" "%s" "%d" "%d" "%s"', jar_location, input_file, output_file, filtering, max_depth, num_trees, node_split_meas);
    
    disp(command)
    
    [status, cmdout] = system(command);
end