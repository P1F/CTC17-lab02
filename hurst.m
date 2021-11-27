function [hurst_exponent, c, log2R, log2S] = hurst(serie)
    serie_sz = length(serie);
    R = zeros(1,1);
    S = zeros(1,1);

    idx = 1;
    section_sz = serie_sz;
    while section_sz > 4
        R_sum = 0;
        R_cnt = 0;
        ini_dx = 1;
        end_idx = ini_dx + section_sz - 1;
        while end_idx <= serie_sz
            X = serie(ini_dx:end_idx);
            V = cumsum(X - mean(X));
            Ri = max(V) - min(V);
            Si = std(X);
            R_sum = R_sum + Ri / Si;
            
            R_cnt = R_cnt + 1;
            ini_dx = ini_dx + section_sz;
            end_idx = ini_dx + section_sz - 1;
        end
        R(idx) = R_sum / R_cnt;
        S(idx) = section_sz;
        idx = idx + 1;
        section_sz = floor(section_sz / 2);
    end

    log2R = log2(R);
    log2S = log2(S);

    p = polyfit(log2S, log2R, 1);
    hurst_exponent = p(1);
    c = p(2);
end