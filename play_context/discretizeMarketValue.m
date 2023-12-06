function discrete_market_values = discretizeMarketValue(market_values)

    discrete_market_values = zeros(size(market_values));
    
    for i=1:numel(market_values)
       current_mv = market_values(i);
       
       discrete_market_values(i) = assignOrdinal(current_mv);
    end

end


function ordinal = assignOrdinal(mv)
% The function assigns an ordinal value to the input market value
    if mv > 22.1
        ordinal = 6;
    elseif mv > 13.2 && mv <= 22.1
        ordinal = 5;
    elseif mv > 10.8 && mv <= 13.2
        ordinal = 4;
    elseif mv > 5.4 && mv <= 10.8
        ordinal = 3;
    elseif mv > 2.9 && mv <= 5.4
        ordinal = 2;
    elseif mv > 0 && mv <= 2.9
        ordinal = 1;
    else
        ordinal = -1;
    end 

end