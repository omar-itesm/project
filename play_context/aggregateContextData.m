function plays_info1 = aggregateContextData(plays_info1, plays_info2)
     f = fieldnames(plays_info2);
     for i = 1:length(f)
        plays_info1.(f{i}) = plays_info2.(f{i});
     end
end