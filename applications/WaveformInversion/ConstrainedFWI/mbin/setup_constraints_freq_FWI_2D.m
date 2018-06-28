function [P,LB,UB] = setup_constraints_freq_FWI_2D(constraint,model,comp_grid,params,m,freq_batch_nr)
m=m(:);
counter=1;

%% bound constraints
if isfield(constraint,'use_bounds') && constraint.use_bounds == 1
    [LB,UB]=get_bound_constraints(m,comp_grid,constraint);
    %convert bound constraints from m/s to s^2/m^2
    LB_s2m2=1e6./UB.^2;
    UB_s2m2=1e6./LB.^2;
    P{counter}            = @(input) boundProject(input,LB_s2m2,UB_s2m2);
    counter               = counter+1;
end

%% Nuclear norm constraints
if  isfield(constraint,'use_nuclear') && constraint.use_nuclear == 1
    if isfield(constraint,'NN_fixed_value')==1
        nuclear_norm = constraint.NN_fixed_value;
    else
        nn_current = norm(svd(reshape(m,comp_grid.n)),1); %nuclear norm of curent model
        if freq_batch_nr==1; nuclear_norm = constraint.NN_initial*nn_current; end
        if freq_batch_nr>1;  nuclear_norm = constraint.NN_increment*nn_current; end
    end
    P{counter}             = @(input) proj_Nuclear(input,comp_grid,nuclear_norm);
    counter                = counter+1;
end

%% Rank constraints
if  isfield(constraint,'use_rank') && constraint.use_rank == 1
    if freq_batch_nr==1; rank = constraint.r_initial; end;
    if freq_batch_nr>1;  rank = floor(constraint.r_initial+freq_batch_nr*constraint.r_increment); end;
    P{counter} = @(input) vec(proj_Rank(reshape(input,comp_grid.n),rank));
    counter                = counter+1;
end

%% Total-variation constraints
if isfield(constraint,'use_TV') && constraint.use_TV == 1 
    h1=comp_grid.d(1); h2=comp_grid.d(2);
    [D,~] = getDiscreteGrad(comp_grid.n(1),comp_grid.n(2),h1,h2,ones(comp_grid.n(1),1));
    
    if isfield(constraint,'TV_ini_abs')
        TV = constraint.TV_ini_abs;
    else
        if strcmp(constraint.TV_units,'m/s')==1
            if freq_batch_nr==1
                TV = constraint.TV_initial.*sum(abs(D*(1e3./sqrt(P{1}(m(:))))));
            elseif freq_batch_nr>1
                TV = constraint.TV_increment.*sum(abs(D*(1e3./sqrt(P{1}(m(:))))));
            end;
        elseif strcmp(constraint.TV_units,'s^2/m^2')==1
            if freq_batch_nr==1
                TV = constraint.TV_initial.*sum(abs(D*m(:)));
            elseif freq_batch_nr>1
                TV = constraint.TV_increment.*sum(abs(D*m(:)));
            end;
        end
    end
    
    if constraint.ADMM_options.adjust_rho==0
        R=chol(speye(length(m))+constraint.ADMM_options.rho*(D'*D));
    else
        R=[];
    end
    
    
    if isfield(constraint,'TV_proj')
        if strcmp(constraint.TV_proj,'ernie')==1
            P{counter} = @(input) vec(proj_TVbounds(reshape(input,comp_grid.n), TV,h1,ones(comp_grid.n(1),1),LB,UB));
        elseif strcmp(constraint.TV_proj,'ernie_CP')==1
            P{counter} = @(input) vec(proj_TVbounds_CP(reshape(input,comp_grid.n), TV,h1,ones(comp_grid.n(1),1),LB,UB));
        end
    else
        
        funProj = @(input) NormL1_project(input,TV);
        if strcmp(constraint.TV_units,'m/s')==1
            P{counter} = @(input) (1e6./((Compute_projection_ADMM((1e3./sqrt(P{1}(input))),D,funProj,constraint.ADMM_options,R)).^2));
        elseif strcmp(constraint.TV_units,'s^2/m^2')==1
            P{counter} = @(input)  Compute_projection_ADMM(input,D,funProj,constraint.ADMM_options,R);
        end
    end
    
    counter                = counter+1;
end

%% Cardinality constraints
if  isfield(constraint,'use_cardinality') && constraint.use_cardinality==1
    [S]=get_TD_operator(comp_grid,constraint.card_operator);
    %determine a initial cardinality, depending on the selected
    %operator
    if strcmp(constraint.card_operator,'D_vert')
        card = constraint.card_initial*comp_grid.n(2);
    elseif strcmp(constraint.card_operator,'D_lat')
        card = constraint.card_initial*comp_grid.n(1);
    elseif strcmp(constraint.card_operator,'TV')
        card = constraint.card_initial*(comp_grid.n(1)+comp_grid.n(2));
    end
    if constraint.ADMM_options.adjust_rho==0
        R=chol(speye(length(m))+constraint.ADMM_options.rho*(S'*S));
    else
        R=[];
    end
    card=round(card);
    funProj = @(input) proj_card(input,card);
    if strcmp(constraint.card_units,'m/s')==1
        P{counter} = @(input) 1e6./(Compute_projection_ADMM(real(1e3./sqrt(P{1}(input))),S,funProj,constraint.ADMM_options,R).^2);
    elseif strcmp(constraint.card_units,'s^2/m^2')==1
        P{counter} = @(input) Compute_projection_ADMM(input,S,funProj,constraint.ADMM_options,R);
    end
    counter                = counter+1;
end

%% Cardinality constraints (another type)
if isfield(constraint,'use_cardinality_2') && constraint.use_cardinality_2==1
    [S]=get_TD_operator(comp_grid,constraint.card_operator_2);
    %determine a initial cardinality, depending on the selected
    %operator
    if strcmp(constraint.card_operator_2,'D_vert')
        card = constraint.card_initial_2*comp_grid.n(2);
    elseif strcmp(constraint.card_operator_2,'D_lat')
        card = constraint.card_initial_2*comp_grid.n(1);
    elseif strcmp(constraint.card_operator_2,'TV')
        card = constraint.card_initial_2*(comp_grid.n(1)+comp_grid.n(2));
    end
    if constraint.ADMM_options.adjust_rho==0
        R=chol(speye(length(m))+constraint.ADMM_options.rho*(S'*S));
    else
        R=[];
    end
    card=round(card);
    funProj = @(input) proj_card(input,card);
    if strcmp(constraint.card_units,'m/s')==1
        P{counter} = @(input) 1e6./(Compute_projection_ADMM(real(1e3./sqrt(P{1}(input))),S,funProj,constraint.ADMM_options,R).^2);
    elseif strcmp(constraint.card_units,'s^2/m^2')==1
        P{counter} = @(input) Compute_projection_ADMM(input,S,funProj,constraint.ADMM_options,R);
    end
    counter                = counter+1;
end

%% Transform domain bound-constraints & slope constraints
if isfield(constraint,'use_TD_bounds') && constraint.use_TD_bounds==1
    
    if freq_batch_nr==1;
        [S]=get_TD_operator(comp_grid,constraint.TD_operator);
    end;
    if freq_batch_nr>1;
        [S]=get_TD_operator(comp_grid,constraint.TD_operator);
        constraint.TD_LB = constraint.TD_LB_increment*constraint.TD_LB;
        constraint.TD_UB = constraint.TD_UB_increment*constraint.TD_UB;
    end
    funProj = @(input) boundProject(input,constraint.TD_LB.*ones(size(S,1),1),constraint.TD_UB.*ones(size(S,1),1));
    if constraint.ADMM_options.adjust_rho==0
        R=chol(speye(length(m))+constraint.ADMM_options.rho*(S'*S));
    else
        R=[];
    end
    if strcmp(constraint.TDbounds_units,'m/s')==1
        P{counter} = @(input) 1e6./(Compute_projection_ADMM(real(1e3./sqrt(P{1}(input))),S,funProj,constraint.ADMM_options,R).^2);
    elseif strcmp(constraint.TDbounds_units,'s^2/m^2')==1
        P{counter} = @(input) Compute_projection_ADMM(input,S,funProj,constraint.ADMM_options,R);
    end
    
    counter                = counter+1;
end

%% Fourier based minimum smoothness constraints
if isfield(constraint,'use_min_smooth') && constraint.use_min_smooth == 1
    cmin        = min(1e3./sqrt(m(:)));
    fmax        = max(model.freq(params.freq_index));
    k           = fmax / cmin;
    HPF         = getHPF(comp_grid, constraint, k);
    LPF         = getLPF(comp_grid, constraint, k);
    
    P{counter} = @(input) LPF*input;
    counter = counter+1;
    constraint.use_min_smooth = 0;
end

%% Projection onto a subspace
if isfield(constraint,'use_subspace') && constraint.use_subspace ==1
    %P{counter} = @(input) vec(Proj_subspace(reshape(input,comp_grid.n),constraint.U,1));
    P{counter} = @(input) real(vec(Proj_subspace(input,constraint.U,0)));
    counter = counter+1;
end

end
