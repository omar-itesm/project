function is_valid = isValidExpectedFreq(expected_freq)
    % Check if the chi-square expected frequency table is valid.
    %
    % If any expected frequency is less than 1, or if the expected frequency 
    % is less than 5, in more than 20% of your cells, the chi-square tests 
    % should not be used.  Expected frequencies of less than 5 are often regarded 
    % as acceptable in the 2 x 2 case of the chi-square test of independence 
    % if Yates' correction is used.
    % Source: https://biomath.med.uth.gr/statistics/chi_square.html
    
    % Initialization
    is_valid = true;
    
    % Any expected freq less than 1
    expected_lt_one = any(any(expected_freq < 1));
    
    if expected_lt_one
        is_valid = false;
    end
    
    % 20% of the cells have a expected freq less than 5
    expected_lt_five = any(any(expected_freq < 5));
    percentage       = expected_lt_five/4;
    
    if percentage > 0.2
        is_valid = false;
    end
    
end