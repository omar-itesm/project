function [expected_freqs, is_valid] = computeExpectedFrequency(a,b,c,d)
    % The function computes the expected frequency for a 2x2
    % contingency table. Additionally, it returns wether or not the
    % expected frequency is valid for performing further statistical
    % testing (chi-squared).
    p_total  = a  + b;
    np_total = c + d;
    
    s_total  = a + c;
    f_total  = b + d;
    
    total = a + b + c + d;
    
    expected_freqs = [s_total*p_total , f_total*p_total;
                      s_total*np_total, f_total*np_total]./total;
            
	is_valid = isValidExpectedFreq(expected_freqs);
end