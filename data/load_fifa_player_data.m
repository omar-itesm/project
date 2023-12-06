function fifaplayers = load_fifa_player_data()

filename = 'fifa_playerPersonalData.csv';

dataLines = [2, Inf];

opts = delimitedTextImportOptions("NumVariables", 6);

opts.DataLines = dataLines;
opts.Delimiter = ",";

opts.VariableNames = ["ID", "Name", "Nationality", "Overall", "Potential", "Club"];
opts.VariableTypes = ["double", "string", "string", "double", "double", "string"];


opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";


fifaplayers = readtable(filename, opts);


end
