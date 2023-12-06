function [is_valid, chi_squared, p_value] = computeStatisticalSignificance(p_s, p_f, np_s, np_f)

    %% Check the expected frequency criteria for valid
    [~, is_valid] = computeExpectedFrequency(p_s, p_f, np_s, np_f);

    dof = 1; % Degrees of freedom for a 2x2 contingency table = (2-1)*(2-1)

    p_total  = p_s  + p_f;
    np_total = np_s + np_f;
    
    s_total  = p_s + np_s;
    f_total  = p_f + np_f;
    
    total = p_s + p_f + np_s + np_f;
    
    observed = [p_s , p_f; 
                np_s, np_f];
    
    expected = [s_total*p_total , f_total*p_total;
                s_total*np_total, f_total*np_total]./total;
            

        
    tmp = expected - observed;
    tmp = tmp.^2;
    tmp = tmp./expected;
    
    chi_squared = sum(sum(tmp));
    
    p_value = 1-chi2cdf(chi_squared, dof);
    
end