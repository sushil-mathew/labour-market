% Gali-van Rens (2013) model
% TvR, 12/2008, revised 08/2013, revised for Dynare++ 02/2015


%----------------------------------------------------------------
% Defining variables and settings
%----------------------------------------------------------------

var p y n w w_LB w_UB R e v c sdf L a z;
varexo epsa epsz;

parameters beta eta theta gamma alpha mu q phi psi PsiF PsiH zeta delta kappa xi Rbar Rcurv rhoa rhoz sigmaa sigmaz Nstst vac_costs_wasted gamma_correction;


%----------------------------------------------------------------
% Calibration
%----------------------------------------------------------------

% Parameters and calibration targets set in main program
load parameterfile;
set_param_value('psi',psi);
set_param_value('mu',mu);
set_param_value('sigmaa',sigmaa);
set_param_value('sigmaz',sigmaz);
set_param_value('xi',xi);
set_param_value('Rbar',Rbar);
set_param_value('Rcurv',Rcurv);
set_param_value('Nstst',Nstst);
set_param_value('kappa',kappa);
set_param_value('delta',delta);
set_param_value('theta',theta);
set_param_value('gamma_correction',gamma_correction);

% Utility
beta = .99;    % discount factor (quarterly)
eta = 1;       % utility logarithmic in consumption
%theta set in parameterfile (0 = utility linear in total effective labor supply L)

% Production
alpha = 1/3;   % capital share

% Matching
% mu set in parameterfile (0 = linear, 1 = quadratic, 0.6 = Mortensen and Nagypal, Shimer: 0.72, Bl-Gali: 2/(1+1)=1, Bl-Gali rev: 2/(2+1)=0.67)
q = 1;         % Normalization, only kappa/q matters. Here: V = M.

% Effort
phi = 0;       % normalization (linear disutility from effort)
%psi set in parameterfile
PsiF = alpha*psi / ( 1 + phi - (1-alpha)*psi );
PsiH = (psi/(1+phi))* ( (1-eta)*(1+phi) - psi ) / ( 1+phi-psi );

% zeta (disutility from effort) set to normalize frictionless steady state effort to one:
zeta = (psi/(1+phi))/(1-PsiF-PsiH);

% gamma (utility from leisure) set to match frictionless employment population ratio:
gamma = gamma_correction*(1-alpha)*(1-PsiF-PsiH)*(1+zeta)/Nstst;

% Separation rate
%delta = 0.306; % to match quarterly gross separation rate
%delta set in the parameterfile

% Frictions
% vacancy posting costs set in parameterfile

% Wage determination
%xi set in parameterfile
%Rbar set in parameterfile
%Rcurv set in parameterfile

% Shocks
rhoa = 0.97;
%sigmaa set in parameterfile
rhoz = 0.97;
%sigmaz set in parameterfile


%----------------------------------------------------------------
% Model
%----------------------------------------------------------------

% Note: All variables in logs, except for R (because close to zero)

vac_costs_wasted = 1;

model;

  kappa*exp(v)^mu = q*(exp(w_UB)-exp(w));

  exp(e)^(1+phi) = (psi/(1+phi))*((1+zeta)/zeta)*(exp(z)/(gamma*(exp(c)^eta)*(exp(L)^theta)))*(1-alpha)*exp(p);

  exp(w) = R(-1)*exp(w(-1)) + (1-R(-1))*(xi*exp(w_UB)+(1-xi)*exp(w_LB));
  R = Rbar*( 1 - ( (2*exp(w)-exp(w_LB)-exp(w_UB)) / (exp(w_UB)-exp(w_LB)) )^(2*Rcurv) );

  exp(w_UB) = (1-PsiF)*(1-alpha)*exp(p) + (1-delta)*( exp(sdf(+1))*(exp(w_UB(+1))-exp(w(+1))) );
  exp(w_LB) = (1/(1+zeta))*((gamma*(exp(c)^eta)*(exp(L)^theta))/exp(z)) + PsiH*(1-alpha)*exp(p) + (1-delta)*( exp(sdf(+1))*(exp(w_LB(+1))-exp(w(+1))) );

  exp(n) = (1-delta)*exp(n(-1)) + q*exp(v);

  exp(c) = exp(y) - vac_costs_wasted * (kappa/(1+mu))*exp(v)^(1+mu);

  exp(y) = exp(a)*((exp(e)^psi)*exp(n))^(1-alpha);
  exp(p) = exp(y)/exp(n);

  exp(sdf) = beta*(exp(z)/exp(z(-1)))*(exp(c(-1))/exp(c))^eta;
  exp(L) = ( ( 1 + zeta*(exp(e)^(1+phi)) )/(1+zeta) )*exp(n);

  z = rhoz*z(-1) + epsz;
  a = rhoa*a(-1) + epsa;

end;

shocks;
  var epsz = sigmaz^2;
  var epsa = sigmaa^2;
end;


%----------------------------------------------------------------
% Steady state
%----------------------------------------------------------------

% Initialize to the frictionless steady state with Eff_stst=1 and Nstst

if Rcurv == 0
    Rstst = 0;
else
    Rstst = Rbar;
end

initval;
  n = log(Nstst);
  y = (1-alpha)*log(Nstst);
  p = -alpha*log(Nstst);
  c = y;
  w_UB = log( (1-PsiF)*(1-alpha)*exp(y)/exp(n) ) + 1e-3;
  w_LB = log( (gamma/(1+zeta))*(exp(c)^eta) + PsiH*(1-alpha)*exp(y)/exp(n) ) - 1e-3;
  w = log( xi*exp(w_UB) + (1-xi)*exp(w_LB) );
  R = Rbar; %Rstst;
  e = log(1);
  v = log(.21);
  sdf = log(beta);
  L = n;
  a = log(1);
  z = log(1);
end;

%options_.noprint = 1;
steady(solve_algo=2);
%steady(solve_algo=1);


%----------------------------------------------------------------
% Policy rules and simulations
%----------------------------------------------------------------

%options_.pruning=0;
stoch_simul(order=2, periods=201000, drop=0, irf=0, nomoments, nocorr, noprint);
% periods = 201000 for final results, = 11000 for quick run
% , irf=20
% , hp_filter=1600
% , drop=1000
