function operator = lpFilter(M, N, lbound, ubound, aspect)

    maskvec = double(fkmask(M, N, lbound, ubound, aspect)) .* 0.25;

    FT = opDFT2(2*M, 2*N,true);
    E = opExtend(M,N,2*M,2*N);
    MV = opDiag(maskvec);
    
    operator = E' * FT' * MV * FT * E;

end