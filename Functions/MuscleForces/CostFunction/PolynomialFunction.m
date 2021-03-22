function [Aopt] = PolynomialFunction(A0, Aeq, beq, Amin, Amax, fmincon_options, options,Fmax, BiomechanicalModel,MuscleConcerned, Fext, Fa, Fp,R,dRdq,J,dJdq, pourcentage_raideur, Ktmax, varargin)
% Optimization used for the force sharing problem: polynomial function
%   
%	Based on :
%	-Pedotti, A., Krishnan, V. V., & Stark, L., 1978. 
%	Optimization of muscle-force sequencing in human locomotion. Mathematical Biosciences, 38(1-2), 57-76.
%	-Herzog, W., 1987. 
%	Individual muscle force estimations using a non-linear optimal design. Journal of Neuroscience Methods, 21(2-4), 167-179.
%	-Happee, R., 1994. 
%	Inverse dynamic optimization including muscular dynamics, a new simulation method applied to goal directed movements. Journal of Biomechanics, 27(7), 953-960.
%
%   INPUT
%   - F0: initial solution
%   - Aeq / beq: matrix used for the equality contraints: Aeq*X=beq
%   - Fmin: lower bounds 
%   - Fmax: upper bounds
%   - fmincon_options: options for the fmincon optimization function
%   - options: degree of the polynomial function
%   - Fmaxbis: upper boundss
%   OUTPUT
%   - Fopt: solution of the optimization problem
%________________________________________________________
%
% Licence
% Toolbox distributed under GPL 3.0 Licence
%________________________________________________________
%
% Authors : Antoine Muller, Charles Pontonnier, Pierre Puchaud and
% Georges Dumont
%________________________________________________________

%Cost function
if ~sum(isinf(Amax))
    cost_function = @(A) sum((Fa./Fmax.*A).^(options));
else
    % ClosedLoop case
    if ~isempty(pourcentage_raideur) && ~isempty(find(pourcentage_raideur,1))
        cost_function = @(A) sum((pourcentage_raideur - Kt_list_eff(BiomechanicalModel,MuscleConcerned,Fext,Fa,A,Fp,R,dRdq,J,dJdq)./Ktmax).^2); % fatigue non prise en compte norm(A)^2 +
    else
        ind_act=find(isinf(Amax)); % first element to be infinite in Fmax
        cost_function = @(A) sum((Fa./Fmax.*A(1:ind_act-1)).^(options));
    end
end
% Optimization
[Aopt,fminval] = fmincon(cost_function,A0,[],[],Aeq,beq,Amin,Amax,[],fmincon_options);
end