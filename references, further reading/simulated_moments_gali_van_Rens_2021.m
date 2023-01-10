% Gali-van Rens (2013) model
% TvR, 12/2008, revised 08/2013, revised for Dynare++ 02/2015


clear;
close all;


%----------------------------------------------------------------
% Settings
%----------------------------------------------------------------

HP=0; % Switch on for HP filtering (lambda=1600)
% First (or second) order approximation, set in mod-file
% Number of periods for simulations, set in mod-file
% 1000 initial periods dropped, set below


%----------------------------------------------------------------
% Solve the model
%----------------------------------------------------------------

Iter = 0;
StartTime = cputime;
results = [];
save resultstable results;

% Calibration:

make_plots = 0;

order_approx_vals = [2.1 2 4];
for order_approx_index = 1:size(order_approx_vals,2)
order_approx = order_approx_vals(order_approx_index);

theta = 0;     % 0 = utility linear in total effective labor supply L, 4 = robustness check (Chetty et al. 2012)
xi = 0.5;      % bargaining power workers (generalized Nash bargaining)
gamma_correction = 1 + (theta==4)*3.165;

Rbar_vals = .95; %[0 .95];
for Rbar_index = 1:size(Rbar_vals,2)
Rbar = Rbar_vals(Rbar_index);
Rcurv = 2;     % needs to be non-negative integer: 0 is flex, 1 is quadratic

%psi_vals = .1;
psi_vals = 0.3; %0.3; %[.05 .1 .2 .3];
for psi_index = 1:size(psi_vals,2)
psi = psi_vals(psi_index);

Nstst_vals = 0.7;  % frictionless steady state empl-pop ratio
for Nstst_index = 1:size(Nstst_vals,2)
Nstst = Nstst_vals(Nstst_index);

mu_vals = 1.5; %[0.6 1 1.5 2 2.4]; % 1 = quadratic adj costs, 0.6 = Mortensen-Nagypal, 2 = cubic
for mu_index = 1:size(mu_vals,2)
mu = mu_vals(mu_index);

kappa_vals = (xi>0.5&mu==1)*1.32045 + (xi==0.2&mu==1)*0.9113 + (theta==4&mu==1)*.90604 + (theta==0&xi==0.5)*( (mu==1.5)*3.18825 + (mu==2.4)*26.2894 + (mu==0.6)*0.41757 + (mu==1)*1.031 );
for kappa_index = 1:size(kappa_vals,2)
kappa = kappa_vals(kappa_index);

sigmaz_vals = (xi>0.5&mu==1&Rbar==0)*0.0024365 + (xi==0.2&mu==1&Rbar==0)*0.001856 + (theta==4&mu==1)*( (Rbar==0.95)*0.0086653 + (Rbar==0)*0.0092791 ) + (theta==0&xi==0.5)*( (mu==1.5)*( (Rbar==0.95)*0.0021093321 + (Rbar==0)*0.00242421 ) + (mu==2.4)*( (Rbar==0.95)*0.0034551 + (Rbar==0)*0.0034877 ) + (mu==0.6)*( (Rbar==0.95)*0.001143 + (Rbar==0)*0.00183763 ) + (mu==1)*( (Rbar==0.95)*0.0015429 + (Rbar==0)*0.0020486 ) );
for sigmaz_index = 1:size(sigmaz_vals,2)
sigmaz = sigmaz_vals(sigmaz_index);

sigmaa_vals = (xi>0.5&mu==1&Rbar==0)*0.0018995 + (xi==0.2&mu==1&Rbar==0)*0.002087 + (theta==4&mu==1)*( (Rbar==0.95)*0.0020898 + (Rbar==0)*0.0021027 ) + (theta==0&xi==0.5)*( (mu==1.5)*( (Rbar==0.95)*0.001849202 + (Rbar==0)*0.001953693 ) + (mu==2.4)*( (Rbar==0.95)*0.00173293 + (Rbar==0)*0.0018071 ) + (mu==0.6)*( (Rbar==0.95)*0.001905 + (Rbar==0)*0.00205873 ) + (mu==1)*( (Rbar==0.95)*0.0018827 + (Rbar==0)*0.0020134 ) );
for sigmaa_index = 1:size(sigmaa_vals,2)
sigmaa = sigmaa_vals(sigmaa_index);

delta_vals = [0.8 0.6]; %[0.4 0.35 0.3 0.25 0.2 0.15 0.001]; %0.306;
for delta_index = 1:size(delta_vals,2)
delta = delta_vals(delta_index);

save parameterfile psi mu sigmaa sigmaz xi Rbar Rcurv Nstst kappa delta theta gamma_correction;

% Call Dynare or Dynare++ to solve the model:
tic;
if order_approx==1.1 || order_approx==2.1
    dynare model_vplp noclearall;
    data = [p y n w w_LB w_UB R e v c sdf L a z];
    levelstst = exp(oo_.steady_state);
    varnames_dyn = M_.endo_names;
else
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    shocks = [sigmaa 0; 0 sigmaz]*randn(2,201000);
    if delta==0.95
        if order_approx==1 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 1 --sim 0 --no-irfs model_vplp_clean_d095.mod
        elseif order_approx==2 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 2 --sim 0 --no-irfs model_vplp_clean_d095.mod
        elseif order_approx==3 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 3 --sim 0 --no-irfs model_vplp_clean_d095.mod
        elseif order_approx==4 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 4 --sim 0 --no-irfs model_vplp_clean_d095.mod
        else
            error('Order of approximation not allowed');
        end
        load model_vplp_clean_d095.mat
        data = dynare_simul('model_vplp_clean_d095.mat', shocks);
        !del model_vplp_clean_d095.mat
    elseif delta==0.8
        if order_approx==1 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 1 --sim 0 --no-irfs model_vplp_clean_d080.mod
        elseif order_approx==2 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 2 --sim 0 --no-irfs model_vplp_clean_d080.mod
        elseif order_approx==3 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 3 --sim 0 --no-irfs model_vplp_clean_d080.mod
        elseif order_approx==4 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 4 --sim 0 --no-irfs model_vplp_clean_d080.mod
        else
            error('Order of approximation not allowed');
        end
        load model_vplp_clean_d080.mat
        data = dynare_simul('model_vplp_clean_d080.mat', shocks);
        !del model_vplp_clean_d080.mat
    elseif delta==0.6
        if order_approx==1 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 1 --sim 0 --no-irfs model_vplp_clean_d060.mod
        elseif order_approx==2 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 2 --sim 0 --no-irfs model_vplp_clean_d060.mod
        elseif order_approx==3 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 3 --sim 0 --no-irfs model_vplp_clean_d060.mod
        elseif order_approx==4 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 4 --sim 0 --no-irfs model_vplp_clean_d060.mod
        else
            error('Order of approximation not allowed');
        end
        load model_vplp_clean_d060.mat
        data = dynare_simul('model_vplp_clean_d060.mat', shocks);
        !del model_vplp_clean_d060.mat
    elseif delta==0.4
        if order_approx==1 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 1 --sim 0 --no-irfs model_vplp_clean_d040.mod
        elseif order_approx==2 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 2 --sim 0 --no-irfs model_vplp_clean_d040.mod
        elseif order_approx==3 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 3 --sim 0 --no-irfs model_vplp_clean_d040.mod
        elseif order_approx==4 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 4 --sim 0 --no-irfs model_vplp_clean_d040.mod
        else
            error('Order of approximation not allowed');
        end
        load model_vplp_clean_d040.mat
        data = dynare_simul('model_vplp_clean_d040.mat', shocks);
        !del model_vplp_clean_d040.mat
    elseif delta==0.35
        if order_approx==1 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 1 --sim 0 --no-irfs model_vplp_clean_d035.mod
        elseif order_approx==2 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 2 --sim 0 --no-irfs model_vplp_clean_d035.mod
        elseif order_approx==3 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 3 --sim 0 --no-irfs model_vplp_clean_d035.mod
        elseif order_approx==4 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 4 --sim 0 --no-irfs model_vplp_clean_d035.mod
        else
            error('Order of approximation not allowed');
        end
        load model_vplp_clean_d035.mat
        data = dynare_simul('model_vplp_clean_d035.mat', shocks);
        !del model_vplp_clean_d035.mat
    elseif delta==0.3
        if order_approx==1 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 1 --sim 0 --no-irfs model_vplp_clean_d030.mod
        elseif order_approx==2 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 2 --sim 0 --no-irfs model_vplp_clean_d030.mod
        elseif order_approx==3 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 3 --sim 0 --no-irfs model_vplp_clean_d030.mod
        elseif order_approx==4 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 4 --sim 0 --no-irfs model_vplp_clean_d030.mod
        else
            error('Order of approximation not allowed');
        end
        load model_vplp_clean_d030.mat
        data = dynare_simul('model_vplp_clean_d030.mat', shocks);
        !del model_vplp_clean_d030.mat
    elseif delta==0.25
        if order_approx==1 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 1 --sim 0 --no-irfs model_vplp_clean_d025.mod
        elseif order_approx==2 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 2 --sim 0 --no-irfs model_vplp_clean_d025.mod
        elseif order_approx==3 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 3 --sim 0 --no-irfs model_vplp_clean_d025.mod
        elseif order_approx==4 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 4 --sim 0 --no-irfs model_vplp_clean_d025.mod
        else
            error('Order of approximation not allowed');
        end
        load model_vplp_clean_d025.mat
        data = dynare_simul('model_vplp_clean_d025.mat', shocks);
        !del model_vplp_clean_d025.mat
    elseif delta==0.2
        if order_approx==1 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 1 --sim 0 --no-irfs model_vplp_clean_d020.mod
        elseif order_approx==2 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 2 --sim 0 --no-irfs model_vplp_clean_d020.mod
        elseif order_approx==3 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 3 --sim 0 --no-irfs model_vplp_clean_d020.mod
        elseif order_approx==4 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 4 --sim 0 --no-irfs model_vplp_clean_d020.mod
        else
            error('Order of approximation not allowed');
        end
        load model_vplp_clean_d020.mat
        data = dynare_simul('model_vplp_clean_d020.mat', shocks);
        !del model_vplp_clean_d020.mat
    elseif delta==0.15
        if order_approx==1 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 1 --sim 0 --no-irfs model_vplp_clean_d015.mod
        elseif order_approx==2 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 2 --sim 0 --no-irfs model_vplp_clean_d015.mod
        elseif order_approx==3 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 3 --sim 0 --no-irfs model_vplp_clean_d015.mod
        elseif order_approx==4 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 4 --sim 0 --no-irfs model_vplp_clean_d015.mod
        else
            error('Order of approximation not allowed');
        end
        load model_vplp_clean_d015.mat
        data = dynare_simul('model_vplp_clean_d015.mat', shocks);
        !del model_vplp_clean_d015.mat
    elseif delta==0.1
        if order_approx==1 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 1 --sim 0 --no-irfs model_vplp_clean_d010.mod
        elseif order_approx==2 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 2 --sim 0 --no-irfs model_vplp_clean_d010.mod
        elseif order_approx==3 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 3 --sim 0 --no-irfs model_vplp_clean_d010.mod
        elseif order_approx==4 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 4 --sim 0 --no-irfs model_vplp_clean_d010.mod
        else
            error('Order of approximation not allowed');
        end
        load model_vplp_clean_d010.mat
        data = dynare_simul('model_vplp_clean_d010.mat', shocks);
        !del model_vplp_clean_d010.mat
    elseif delta==0.05
        if order_approx==1 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 1 --sim 0 --no-irfs model_vplp_clean_d005.mod
        elseif order_approx==2 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 2 --sim 0 --no-irfs model_vplp_clean_d005.mod
        elseif order_approx==3 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 3 --sim 0 --no-irfs model_vplp_clean_d005.mod
        elseif order_approx==4 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 4 --sim 0 --no-irfs model_vplp_clean_d005.mod
        else
            error('Order of approximation not allowed');
        end
        load model_vplp_clean_d005.mat
        data = dynare_simul('model_vplp_clean_d005.mat', shocks);
        !del model_vplp_clean_d005.mat
    elseif delta==0.01
        if order_approx==1 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 1 --sim 0 --no-irfs model_vplp_clean_d001.mod
        elseif order_approx==2 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 2 --sim 0 --no-irfs model_vplp_clean_d001.mod
        elseif order_approx==3 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 3 --sim 0 --no-irfs model_vplp_clean_d001.mod
        elseif order_approx==4 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 4 --sim 0 --no-irfs model_vplp_clean_d001.mod
        else
            error('Order of approximation not allowed');
        end
        load model_vplp_clean_d001.mat
        data = dynare_simul('model_vplp_clean_d001.mat', shocks);
        !del model_vplp_clean_d001.mat
    elseif delta==0.001
        if order_approx==1 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 1 --sim 0 --no-irfs model_vplp_clean_d0001.mod
        elseif order_approx==2 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 2 --sim 0 --no-irfs model_vplp_clean_d0001.mod
        elseif order_approx==3 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 3 --sim 0 --no-irfs model_vplp_clean_d0001.mod
        elseif order_approx==4 
            !C:\dynare\4.3.0\dynare++\dynare++ --order 4 --sim 0 --no-irfs model_vplp_clean_d0001.mod
        else
            error('Order of approximation not allowed');
        end
        load model_vplp_clean_d0001.mat
        data = dynare_simul('model_vplp_clean_d0001.mat', shocks);
        !del model_vplp_clean_d0001.mat
    end
    varnames_dyn = [dyn_vars(dyn_i_p,:);dyn_vars(dyn_i_y,:);dyn_vars(dyn_i_n,:);dyn_vars(dyn_i_w,:);dyn_vars(dyn_i_w_LB,:);dyn_vars(dyn_i_w_UB,:);dyn_vars(dyn_i_R,:);dyn_vars(dyn_i_e,:);dyn_vars(dyn_i_v,:);dyn_vars(dyn_i_c,:);dyn_vars(dyn_i_sdf,:);dyn_vars(dyn_i_L,:);dyn_vars(dyn_i_a,:);dyn_vars(dyn_i_z,:)];
    levelstst = exp([dyn_steady_states(dyn_i_p,1);dyn_steady_states(dyn_i_y,1);dyn_steady_states(dyn_i_n,1);dyn_steady_states(dyn_i_w,1);dyn_steady_states(dyn_i_w_LB,1);dyn_steady_states(dyn_i_w_UB,1);dyn_steady_states(dyn_i_R,1);dyn_steady_states(dyn_i_e,1);dyn_steady_states(dyn_i_v,1);dyn_steady_states(dyn_i_c,1);dyn_steady_states(dyn_i_sdf,1);dyn_steady_states(dyn_i_L,1);dyn_steady_states(dyn_i_a,1);dyn_steady_states(dyn_i_z,1)]);
    data = data';
    data = [ data(:,dyn_i_p) data(:,dyn_i_y) data(:,dyn_i_n) data(:,dyn_i_w) data(:,dyn_i_w_LB) data(:,dyn_i_w_UB) data(:,dyn_i_R) data(:,dyn_i_e) data(:,dyn_i_v) data(:,dyn_i_c) data(:,dyn_i_sdf) data(:,dyn_i_L) data(:,dyn_i_a) data(:,dyn_i_z) ];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end    
toc;

%----------------------------------------------------------------
% Table business cycle stats
%----------------------------------------------------------------

data = data(1001:end-3,:);
varnames = ['p   ';'y   ';'n   ';'w   ';'w_LB';'w_UB';'R   ';'e   ';'v   ';'c   ';'sdf ';'L   ';'a   ';'z   '];
if max(max(varnames_dyn ~= varnames))
    error('you changed the number or order of variables');
end

index_y = find(varnames(:,1)=='y'&varnames(:,2)==' ');
index_n = find(varnames(:,1)=='n'&varnames(:,2)==' ');
index_p = find(varnames(:,1)=='p'&varnames(:,2)==' ');
index_w = find(varnames(:,1)=='w'&varnames(:,2)==' ');
index_wUB = find(varnames(:,1)=='w'&varnames(:,3)=='U');
index_wLB = find(varnames(:,1)=='w'&varnames(:,3)=='L');
index_e = find(varnames(:,1)=='e'&varnames(:,2)==' ');
index_c = find(varnames(:,1)=='c'&varnames(:,2)==' ');
index_v = find(varnames(:,1)=='v'&varnames(:,2)==' ');
index_nolog = find( (varnames(:,1)=='R'&varnames(:,2)==' ') );

levelstst(index_nolog) = log(levelstst(index_nolog));

% THEORETICAL MOMENTS (works only if no variables are dropped by Dynare):
% levelmeans = exp(oo_.mean);
% levelmeans(index_nolog) = log(levelmeans(index_nolog));
% sd = sqrt(diag(oo_.var));
% relsd = sqrt(diag(oo_.var))/sqrt(oo_.var(index_y,index_y));
% autocorr = diag(oo_.autocorr{1,1});
% corry = oo_.var(:,index_y)./(sd*sd(index_y));
% corrn = oo_.var(:,index_n)./(sd*sd(index_n));
% table('THEORETICAL BUSINESS CYCLE MOMENTS)',strvcat('VARIABLE','ST.STATE','MEAN','AUTOCORR','STD.DEV.','REL.S.D.','CORR.Y','CORR.N'),lgy_,[levelstst,levelmeans,autocorr,sd,relsd,corry,corrn],10,8,4);

mean_simul = exp(mean(data))';
mean_simul(index_nolog) = log(mean_simul(index_nolog));

% Filter the data
if HP==1
    for j = 1:size(data,2)
        data(:,j) = data(:,j) - hpfilter(data(:,j),1600); % idealfilter(timeseries(data(:,j)),[1/32 1/6],'pass')
    end
end

sd_simul = sqrt(var(data))';
relsd_simul = sd_simul/sd_simul(index_y);

for j = 1:size(data,2)
    if sd_simul(j)<1e-12
        autocorr_simul(j,1) = NaN;
        corry_simul(j,1) = 0;
        corrn_simul(j,1) = 0;
    else
        autocorr_simul(j,1) = corr(data(2:end,j),data(1:end-1,j));
        corry_simul(j,1) = corr(data(:,j),data(:,index_y));
        corrn_simul(j,1) = corr(data(:,j),data(:,index_n));
    end
end

% Calibration targets:
Eff_stst_fl = ( (psi/(1+phi))*(1/zeta)*(1/(1-PsiF-PsiH)) )^(1/(1+phi));
Nstst_fl = (1-alpha)*(1-PsiF-PsiH)*((1+zeta)/gamma)*levelstst(index_y)^(1-eta);
VacCosts = ((kappa/(1+mu))*(levelstst(index_v)^(1+mu)))/levelstst(index_y);

% Output the results:
disp(sprintf('\nCALIBRATION:'));
disp(sprintf('\nSteady state:'));
disp(sprintf('zeta   = %g ==> Eff_stst_fl = %g (target = 1 in frictionless model)', zeta, Eff_stst_fl));
disp(sprintf('gamma  = %g ==> Nstst_fl = %g (target = %g in frictionless model)', gamma, Nstst_fl*gamma_correction, Nstst));
disp(sprintf('kappa  = %g ==> Vacancy costs fraction output = %g (target = 0.03)', kappa, VacCosts));
disp(sprintf('\nSecond moments:'));
disp(sprintf('sigmaa = %g ==> sd(y) = %g pre 1984 (target = 0.01)', sigmaa, sd_simul(index_y)));
disp(sprintf('sigmaz = %g ==> sd(n)/sd(y) = %g pre 1984 (target = 0.66)', sigmaz, relsd_simul(index_n)));
disp(sprintf('psi    = %g ==> sd(n)/sd(y) = %g post 1984 (target = 0.81)', psi, relsd_simul(index_n)));

table('BUSINESS CYCLE MOMENTS (logs ~R)',strvcat('VARIABLE','ST.STATE','MEAN','AUTOCORR','STD.DEV.','REL.S.D.','CORR.Y','CORR.N'),varnames,[levelstst,mean_simul,autocorr_simul,sd_simul,relsd_simul,corry_simul,corrn_simul],10,8,4);

% Save the most important results:
load resultstable;
results = [ results ; [psi mu delta Rbar 100*sigmaa 100*sigmaz levelstst(index_n) VacCosts corry_simul(index_p) corrn_simul(index_p) relsd_simul(index_n) relsd_simul(index_w) 100*sd_simul(index_y)] ];
save resultstable results;

% Some plots:

if make_plots

t=1:size(data,1);
period = 1:500;
w_plot = data(period,find(varnames(:,1)=='w'&varnames(:,2)==' '));
w_LB_plot = data(period,find(varnames(:,1)=='w'&varnames(:,3)=='L'));
w_UB_plot = data(period,find(varnames(:,1)=='w'&varnames(:,3)=='U'));

% Accuracy check endogenous wage rigidity
what_plot = (2*w_plot-w_LB_plot-w_UB_plot)./(w_UB_plot-w_LB_plot);
R_nonlin_plot = Rbar*(1-what_plot.^(2*Rcurv));
R_simul_plot = data(period,find(varnames(:,1)=='R'&varnames(:,2)==' '));
figure(1);
plot(what_plot,R_simul_plot,'bo',what_plot,R_nonlin_plot,'rd');
axis([-.8 .8 .8 1.05]);

% Simulated wage and bargaining set
figure(2);
plot(t(period),w_plot,'b-',t(period),w_LB_plot,'r--',t(period),w_UB_plot,'r-');

end  % if make_plots

% End loop over parameter values:
Iter = Iter + 1;
disp(sprintf('Iterations completed: %g, Elapsed time: %g',Iter,cputime-StartTime));
end
end
end
end
end
end
end
end
end


%----------------------------------------------------------------
% Output results table
%----------------------------------------------------------------

load resultstable;
modelnr = int2str([1:size(results,1)]');
table('RESULTS FOR VARIOUS CALIBRATIONS',strvcat('MODEL','PSI','MU','DELTA','RBAR','SIGMAA','SIGMAZ','N_STST','VACCOSTS','CORR_PY','CORR_PN','RELSD_N','RELSD_W','SD_Y'),modelnr,results,10,8,4);

