function data_table = convertWekaData2Table(weka_data)

    fnames = fieldnames(weka_data);
    
    data_table = table();
    
    for i=1:numel(fnames)
        current_fieldname = fnames{i};
        current_field     = weka_data.(current_fieldname);
        current_data      = current_field.data;

        data_table.(current_fieldname) = current_data;
    end


end