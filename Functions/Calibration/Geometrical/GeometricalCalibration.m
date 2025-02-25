function [Human_model_calib, calib_parameters, Markers_set] = GeometricalCalibration(OsteoArticularModel, Markers_set, AnalysisParameters)
% Calibration of the geometrical parameters
%   Geometrical parameters (limbs length, local markers position and axis
%   of rotation) are subject-specific calibrated from motion capture data.
%
%   Associated publication:
%	- Muller, A., Germain, C., Pontonnier, C., Dumont, G., 2015.
%	A Simple Method to Calibrate Kinematical Invariants: Application to Overhead Throwing. Int. Soc. Biomech. Sport. 2�5.
%
%   Based on:
%	- Reinbolt, J.A., Schutte, J.F., Fregly, B.J., Koh, B. Il, Haftka, R.T., George, A.D., Mitchell, K.H., 2005.
%	Determination of patient-specific multi-joint kinematic models through two-level optimization. J. Biomech. 38, 621�626.
%	- Andersen, M.S., Damsgaard, M., MacWilliams, B., Rasmussen, J., 2010.
%	A computationally efficient optimisation-based method for parameter identification of kinematically determinate and over-determinate biomechanical systems. Comput. Methods Biomech. Biomed. Engin. 13, 171�183.
%
%   INPUT
%   - OsteoArticularModel: osteo-articular model (see the Documentation for
%   the structure);
%   - Markers_set: markers set (see the Documentation for the structure);
%   - AnalysisParameters: parameters of the musculoskeletal analysis,
%   automatically generated by the graphic interface 'Analysis'.
%   OUTPUT
%   - Human_model_calib: subject-specific calibrated osteo-articular model
%   (see the Documentation for the structure);
%   - calib_parameters: geometrical calibration results;
%   - Markers_set: subject-specific calibrated markers set (see the
%   Documentation for the structure).
%________________________________________________________
%
% Licence
% Toolbox distributed under GPL 3.0 Licence
%________________________________________________________
%
% Authors : Antoine Muller, Charles Pontonnier, Pierre Puchaud and
% Georges Dumont
%________________________________________________________

%% Model save
Human_model_save=OsteoArticularModel;

%% Taking into account of constraints specified in AnalysisParameters
solid_names={OsteoArticularModel.name};
% k
for i = 1:size(AnalysisParameters.CalibIK.LengthDelete,1)
    [~,~,num_solid] = intersect(AnalysisParameters.CalibIK.LengthDelete{i,1},solid_names);
    OsteoArticularModel(num_solid).calib_k_constraint = [];
end
for i = 1:size(AnalysisParameters.CalibIK.LengthAdd,1)
    [~,~,num_solid1] = intersect(AnalysisParameters.CalibIK.LengthAdd{i,1},solid_names);
    [~,~,num_solid2] = intersect(AnalysisParameters.CalibIK.LengthAdd{i,2},solid_names);
    OsteoArticularModel(num_solid1).calib_k_constraint = num_solid2;
end
% v
for i=1:size(AnalysisParameters.CalibIK.AxisDelete,1)
    [~,~,num_solid] = intersect(AnalysisParameters.CalibIK.AxisDelete{i,1},solid_names);
    %     OsteoArticularModel(num_solid).v = setdiff(OsteoArticularModel(num_solid).v',AnalysisParameters.CalibIK.AxisDelete{i,2}','rows')';
    OsteoArticularModel(num_solid).v=[];
end
for i=1:size(AnalysisParameters.CalibIK.AxisAdd,1)
    [~,~,num_solid] = intersect(AnalysisParameters.CalibIK.AxisAdd{i,1},solid_names);
    OsteoArticularModel(num_solid).v = [OsteoArticularModel(num_solid).v AnalysisParameters.CalibIK.AxisAdd{i,2}];
end
% Markers
for i=1:size(AnalysisParameters.CalibIK.MarkersCalibModif,1)
    [~,~,num_solid] = intersect(AnalysisParameters.CalibIK.MarkersCalibModif{i,1},{Markers_set.name});
    Markers_set(num_solid).calib_dir = AnalysisParameters.CalibIK.MarkersCalibModif{i,2};
end

%% Adding 6 DOF joint (pelvis to world)
[OsteoArticularModel] = Add6dof(OsteoArticularModel);
s_root=find([OsteoArticularModel.mother]==0); %#ok<NASGU> % num�ro du solide root

%% Symbolical function generation
% Markers position according to the joint coordinates
[OsteoArticularModel,nbclosedloop,GC,nb_k,k_map,nb_p,p_map,nb_alpha,alpha_map,A_norm,b_norm]=SymbolicFunctionGeneration_A(OsteoArticularModel, Markers_set);

%% list of markers from the model
list_markers={};
for i=1:numel(Markers_set)
    if Markers_set(i).exist
        list_markers=[list_markers;Markers_set(i).name]; %#ok<AGROW>
    end
end
nb_markers=size(list_markers,1);
nb_solid=size(OsteoArticularModel,2);  % nb de solides (number of solids)

%% Real markers position from C3D file
filename = AnalysisParameters.CalibIK.filename;
[real_markers, nb_frame]=Get_real_markers_Calibration(filename,list_markers, AnalysisParameters);
list_markers = [real_markers.name]';

%% Selection/choice of frame sample
nb_frame_calib = AnalysisParameters.CalibIK.Frames.NbFrames;

[frame_calib] = AnalysisParameters.CalibIK.Frames.Method(nb_frame_calib, real_markers, list_markers);


calib_parameters.frame_calib = frame_calib;
% Frame to use for calibration
real_markers_calib=struct;
for i=1:numel(real_markers)
    real_markers_calib(i).name=real_markers(i).name;
    real_markers_calib(i).position=real_markers(i).position(frame_calib,:);
end

%% Root position
Base_position=cell(nb_frame,1);
Base_rotation=cell(nb_frame,1);
for i=1:nb_frame
    Base_position{i}=zeros(3,1);
    Base_rotation{i}=eye(3,3);
end

%% Initializations
taille = length(b_norm);

k_init=zeros(taille,1);

Nb_qred=size(GC.q_red,1);
% linear constraints for inverse kinemeatics, same joint angles for two
% joints
Aeq_ik=zeros(Nb_qred);
beq_ik=zeros(Nb_qred,1);
solid_red = (GC.q_map'*[1:nb_solid]')';
for i=1:length(solid_red)
    jj=solid_red(i);
    if size(OsteoArticularModel(jj).linear_constraint) ~= [0 0] %#ok<BDSCA>
        Aeq_ik(i,i)=-1;
        ind_col = OsteoArticularModel(jj).linear_constraint(1,1);
        [~,c]=find(GC.q_map(ind_col,:));
        
        ind_val = OsteoArticularModel(jj).linear_constraint(2,1);
        [~,cc]=find(GC.q_map(ind_val,:));
        Aeq_ik(i,c)=cc;
    end
end
% Aeq_ik=zeros(nb_solid);
% beq_ik=zeros(nb_solid,1);
% for i=1:nb_solid
%     if size(OsteoArticularModel(i).linear_constraint) ~= [0 0] %#ok<BDSCA>
%         Aeq_ik(i,i)=-1;
%         Aeq_ik(i,OsteoArticularModel(i).linear_constraint(1,1))=OsteoArticularModel(i).linear_constraint(2,1);
%     end
% end

%% Inverse kinematics

% options = optimoptions(@fmincon,'Algorithm','interior-point','Display','iter-detailed','PlotFcns',@optimplotfval,'TolFun',1e-2,'MaxFunEvals',20000);


addpath('Symbolic_function')

nbcut = max([OsteoArticularModel.KinematicsCut]);
Rcut=zeros(3,3,nbcut);
pcut=zeros(3,1,nbcut);

% Functions list for computing cost function
list_function=cell(nbcut,1);
for c=1:nbcut
    list_function{c}=str2func(sprintf('f%dcut',c));
end
list_function_markers=cell(numel(list_markers),1);
for m=1:numel(list_markers)
    list_function_markers{m}=str2func(sprintf([list_markers{m} '_Position']));
end

% Joint limits
q_map=GC.q_map;
l_inf=[OsteoArticularModel.limit_inf]';
l_sup=[OsteoArticularModel.limit_sup]';
% to handle infinity
ind_infinf=not(isfinite(l_inf));
ind_infsup=not(isfinite(l_sup));
% tip to handle inflinity with a complex number.
l_inf(ind_infinf)=1i;
l_sup(ind_infsup)=1i;
% new indexing
l_inf=q_map'*l_inf;
l_sup=q_map'*l_sup;
%find 1i to replay by inf
l_inf(l_inf==1i)=-inf;
l_sup(l_sup==1i)=+inf;


%% Calibration

% Optimization constraints for calibration
Aeq_calib=zeros(taille);
beq_calib=zeros(taille,1);

% Constraints for k
for i=1:nb_solid-6
    if size(OsteoArticularModel(i).calib_k_constraint) ~= [0 0]
        vect2map = zeros(nb_solid,1);
        vect2map(i,1) = 1;
        cur_ind_k = find(k_map'*vect2map==1);
        %         if OsteoArticularModel(i).calib_k_constraint == 0
        %             Aeq_calib(cur_ind_k,cur_ind_k)=1;
        %             beq_calib(cur_ind_k,1)=-1;
        %         else
        vect2map = zeros(nb_solid,1);
        vect2map(OsteoArticularModel(i).calib_k_constraint,1) = 1;
        ind_k_map_constraint = k_map'*vect2map==1;
        Aeq_calib(cur_ind_k,cur_ind_k)=1;
        Aeq_calib(cur_ind_k,ind_k_map_constraint)=-1;
        %         end
    end
end

% if isfield(AnalysisParameters.CalibIK,'Scapactive') && AnalysisParameters.CalibIK.Scapactive
%     real_markers_calib_scap=struct('name',{real_markers_calib.name});
%     real_markers_calib_scap(numel(real_markers_calib)).position=[];
%     if iscell(AnalysisParameters.CalibIK.ScapFiles)
%         for i=1:length(AnalysisParameters.CalibIK.ScapFiles)
%             filename_i = AnalysisParameters.CalibIK.ScapFiles{i};
%             [real_markers_i, ~]=Get_real_markers_Calibration(filename_i,list_markers, AnalysisParameters);
%             for j=1:numel(real_markers_i)
%                 real_markers_calib_scap(j).position=[real_markers_calib_scap(j).position; real_markers_i(j).position(1,:)];
%             end
%         end
%     else
%         filename_i = AnalysisParameters.CalibIK.ScapFiles;
%         [real_markers_i, ~]=Get_real_markers_Calibration(filename_i,list_markers, AnalysisParameters);
%         for i=1:numel(real_markers)
%             real_markers_calib_scap(i).position=real_markers_i(i).position(frame_calib,:);
%         end
%     end
%     
%     [weights] = ismember(find([Markers_set.exist]) , find(contains({Markers_set.anat_position},'ScapLoc') | contains({Markers_set.anat_position},'SHO')) )';
%     [kp_opt_scap,crit_scap,errorm_scap,~]=GeomCalibOptimization(k_init,weights,Nb_qred,nb_frame_calib,Base_position,Base_rotation,list_function,Rcut,pcut,real_markers_calib,nbcut,list_function_markers,Aeq_ik,beq_ik,l_inf,l_sup,Aeq_calib,beq_calib);
%     calib_parameters.crit_scap = crit_scap;
%     calib_parameters.errorm_scap = errorm_scap;
%     calib_parameters.kp_opt_scap = kp_opt_scap(:,end);
%     k_init = kp_opt_scap(:,end);
% end
% weights=ones(length(list_markers),1);
weights =(ones(1,length(real_markers)));%.*[real_markers(:).weight])';
[kp_opt,crit,errorm,q0]=GeomCalibOptimization(k_init,weights,Nb_qred,nb_frame_calib,Base_position,Base_rotation,list_function,Rcut,pcut,real_markers_calib,nbcut,list_function_markers,Aeq_ik,beq_ik,l_inf,l_sup,Aeq_calib,beq_calib);
calib_parameters.crit = crit;
calib_parameters.errorm = errorm;
calib_parameters.q0 = q0;



%% Recuperation of k, p and alpha
% Normalization
kp_opt_unormalized=A_norm\(kp_opt(:,end)-b_norm);

calib_parameters.k_calib=k_map*[kp_opt_unormalized(1:nb_k,end); 1];
calib_parameters.p_calib=p_map*kp_opt_unormalized(nb_k+1:nb_k+nb_p,end);
calib_parameters.alpha_calib=alpha_map*kp_opt_unormalized(nb_k+nb_p+1:nb_k+nb_p+nb_alpha,end);
calib_parameters.alpha_calib=...
    [calib_parameters.alpha_calib(1:2:length(calib_parameters.alpha_calib)),...
    calib_parameters.alpha_calib(2:2:length(calib_parameters.alpha_calib))];
calib_parameters.radius =kp_opt_unormalized(nb_k+nb_p+nb_alpha+1:end,end);

%% Model actualisation with obtained k and p values.
Human_model_calib=Human_model_save;
% k_calib %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:numel(Human_model_save)
    Human_model_calib(i).b=Human_model_save(i).b*calib_parameters.k_calib(OsteoArticularModel(i).mother); % b (k de la m�re)
    Human_model_calib(i).c=Human_model_save(i).c*calib_parameters.k_calib(i); % c
    Human_model_calib(i).I=Human_model_save(i).I*calib_parameters.k_calib(i)*calib_parameters.k_calib(i); % I
    for j=1:size(Human_model_save(i).anat_position,1)
        Human_model_calib(i).anat_position{j,2}=Human_model_save(i).anat_position{j,2}*calib_parameters.k_calib(i);
    end
end
% p_calib %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m=0;
for i=1:numel(Markers_set)
    if Markers_set(i).exist
        m=m+1;
        Human_model_calib(Markers_set(i).num_solid).anat_position{Markers_set(i).num_markers,2} = ...
            Human_model_calib(Markers_set(i).num_solid).anat_position{Markers_set(i).num_markers,2} + ...
            calib_parameters.p_calib((3*(m-1)+1):(3*m),:)*calib_parameters.k_calib(Markers_set(i).num_solid);
    end
end
% alpha_calib %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nb_alpha
    for j=1:numel(Human_model_save)
        if ~isempty(Human_model_calib(j).v)
            alpha_j=calib_parameters.alpha_calib(j,:);
            Human_model_calib(j).a = Rodrigues(Human_model_calib(j).v(:,2),alpha_j(2))*Rodrigues(Human_model_calib(j).v(:,1),alpha_j(1))*Human_model_calib(j).a;
        end
    end
end

% kinematic dependancy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if size(GC.q_dep,1)>0
    vect_q_dep = GC.q_dep_map*GC.fq_dep_k(GC.q_red , kp_opt_unormalized(1:nb_k,end));
    vect_k_dep = GC.q_dep_map*GC.ind_k_dep;
    for j=1:numel(Human_model_save)
        if isfield(Human_model_calib,'kinematic_dependancy') && ~isempty(Human_model_calib(j).kinematic_dependancy)
            Human_model_calib(j).kinematic_dependancy.q=matlabFunction(vect_q_dep(j));
            %                  if vect_k_dep(j)~=0
            %                     Human_model_calib(j).kinematic_dependancy.numerical_estimates(:,2)=...
            %                         calib_parameters.k_calib(vect_k_dep(j))*Human_model_calib(j).kinematic_dependancy.numerical_estimates(:,2);
            %                  end
        end
        
        switch Human_model_calib(j).name
            case 'RScapuloThoracic_J1'
                if sum(contains({Human_model_calib.name},'RScapuloThoracic_Jalpha'))
                    syms theta1 theta2 real
                    t1 = -calib_parameters.radius(1)*cos(theta1)*cos(theta2);
                    ft =matlabFunction(t1,'vars',[theta1,theta2]);
                    dft =matlabFunction(jacobian(t1,[theta1,theta2]),'vars',[theta1,theta2]);
                    ddft =matlabFunction(jacobian(jacobian(t1,[theta1,theta2]),[theta1,theta2]),'vars',[theta1,theta2]);
                    Human_model_calib(j).kinematic_dependancy.q=   ft;
                    Human_model_calib(j).kinematic_dependancy.dq=dft;
                    Human_model_calib(j).kinematic_dependancy.ddq=ddft;
                else
                    syms theta phi real % latitude longitude
                    
                    t1 = -calib_parameters.radius(1)*cos(theta)*cos(phi);
                    ft =matlabFunction(t1,'vars',[theta,phi]);
                    dft =matlabFunction(jacobian(t1,[theta,phi]),'vars',[theta,phi]);
                    ddft =matlabFunction(jacobian(jacobian(t1,[theta,phi]),[theta,phi]),'vars',[theta,phi]);
                    Human_model_calib(j).kinematic_dependancy.q=   ft;
                    Human_model_calib(j).kinematic_dependancy.dq=dft;
                    Human_model_calib(j).kinematic_dependancy.ddq=ddft;
                end
            case 'RScapuloThoracic_J2'
                if sum(contains({Human_model_calib.name},'RScapuloThoracic_Jalpha'))
                    syms theta2 real
                    t1 = calib_parameters.radius(2)*sin(theta2);
                    ft =matlabFunction(t1,'vars',[theta2]);
                    dft =matlabFunction(jacobian(t1,[theta2]),'vars',[theta2]);
                    ddft =matlabFunction(jacobian(jacobian(t1,[theta2]),[theta2]),'vars',[theta2]);
                    Human_model_calib(j).kinematic_dependancy.q=ft;
                    Human_model_calib(j).kinematic_dependancy.dq=dft;
                    Human_model_calib(j).kinematic_dependancy.ddq=ddft;
                else
                    syms theta real% latitude
                    
                    t1 = calib_parameters.radius(2)*sin(theta);
                    
                    ft =matlabFunction(t1,'vars',[theta]);
                    dft =matlabFunction(jacobian(t1,[theta]),'vars',[theta]);
                    ddft =matlabFunction(jacobian(jacobian(t1,[theta]),[theta]),'vars',[theta]);
                    Human_model_calib(j).kinematic_dependancy.q=   ft;
                    Human_model_calib(j).kinematic_dependancy.dq=dft;
                    Human_model_calib(j).kinematic_dependancy.ddq=ddft;
                end
            case 'RScapuloThoracic_J3'
                
                
                if sum(contains({Human_model_calib.name},'RScapuloThoracic_Jalpha'))
                    syms theta1 theta2 real
                    t1 = calib_parameters.radius(3)*sin(theta1)*cos(theta2);
                    ft =matlabFunction(t1,'vars',[theta1,theta2]);
                    dft =matlabFunction(jacobian(t1,[theta1,theta2]),'vars',[theta1,theta2]);
                    ddft =matlabFunction(jacobian(jacobian(t1,[theta1,theta2]),[theta1,theta2]),'vars',[theta1,theta2]);
                    Human_model_calib(j).kinematic_dependancy.q=   ft;
                    Human_model_calib(j).kinematic_dependancy.dq=dft;
                    Human_model_calib(j).kinematic_dependancy.ddq=ddft;
                else
                    syms theta phi real % latitude longitude
                    
                    t1 = calib_parameters.radius(3)*cos(theta)*sin(phi);
                    
                    ft =matlabFunction(t1,'vars',[theta,phi]);
                    dft =matlabFunction(jacobian(t1,[theta,phi]),'vars',[theta,phi]);
                    ddft =matlabFunction(jacobian(jacobian(t1,[theta,phi]),[theta,phi]),'vars',[theta,phi]);
                    Human_model_calib(j).kinematic_dependancy.q=   ft;
                    Human_model_calib(j).kinematic_dependancy.dq=dft;
                    Human_model_calib(j).kinematic_dependancy.ddq=ddft;
                end
            case 'LScapuloThoracic_J1'
                
                if sum(contains({Human_model_calib.name},'LScapuloThoracic_Jalpha'))
                    syms theta1 theta2 real
                    t1 = -calib_parameters.radius(4)*cos(theta1)*cos(theta2);
                    ft =matlabFunction(t1,'vars',[theta1,theta2]);
                    dft =matlabFunction(jacobian(t1,[theta1,theta2]),'vars',[theta1,theta2]);
                    ddft =matlabFunction(jacobian(jacobian(t1,[theta1,theta2]),[theta1,theta2]),'vars',[theta1,theta2]);
                    Human_model_calib(j).kinematic_dependancy.q=   ft;
                    Human_model_calib(j).kinematic_dependancy.dq=dft;
                    Human_model_calib(j).kinematic_dependancy.ddq=ddft;
                else
                    syms theta phi real % latitude longitude
                    
                    t1=-calib_parameters.radius(4)*cos(theta)*cos(phi);
                    
                    ft =matlabFunction(t1,'vars',[theta,phi]);
                    dft =matlabFunction(jacobian(t1,[theta,phi]),'vars',[theta,phi]);
                    ddft =matlabFunction(jacobian(jacobian(t1,[theta,phi]),[theta,phi]),'vars',[theta,phi]);
                    Human_model_calib(j).kinematic_dependancy.q=   ft;
                    Human_model_calib(j).kinematic_dependancy.dq=dft;
                    Human_model_calib(j).kinematic_dependancy.ddq=ddft;
                    
                end
            case 'LScapuloThoracic_J2'
                if sum(contains({Human_model_calib.name},'LScapuloThoracic_Jalpha'))
                    syms theta2 real
                    t1 = calib_parameters.radius(5)*sin(theta2);
                    ft =matlabFunction(t1,'vars',[theta2]);
                    dft =matlabFunction(jacobian(t1,[theta2]),'vars',[theta2]);
                    ddft =matlabFunction(jacobian(jacobian(t1,[theta2]),[theta2]),'vars',[theta2]);
                    Human_model_calib(j).kinematic_dependancy.q=ft;
                    Human_model_calib(j).kinematic_dependancy.dq=dft;
                    Human_model_calib(j).kinematic_dependancy.ddq=ddft;
                    
                else
                    syms theta real% latitude
                    
                    t1 = calib_parameters.radius(5)*sin(theta);
                    ft =matlabFunction(t1,'vars',[theta]);
                    dft =matlabFunction(jacobian(t1,[theta]),'vars',[theta]);
                    ddft =matlabFunction(jacobian(jacobian(t1,[theta]),[theta]),'vars',[theta]);
                    Human_model_calib(j).kinematic_dependancy.q=   ft;
                    Human_model_calib(j).kinematic_dependancy.dq=dft;
                    Human_model_calib(j).kinematic_dependancy.ddq=ddft;
                    
                end
            case 'LScapuloThoracic_J3'
                if sum(contains({Human_model_calib.name},'LScapuloThoracic_Jalpha'))
                    syms theta1 theta2 real
                    t1 = -calib_parameters.radius(6)*sin(theta1)*cos(theta2);
                    ft =matlabFunction(t1,'vars',[theta1,theta2]);
                    dft =matlabFunction(jacobian(t1,[theta1,theta2]),'vars',[theta1,theta2]);
                    ddft =matlabFunction(jacobian(jacobian(t1,[theta1,theta2]),[theta1,theta2]),'vars',[theta1,theta2]);
                    Human_model_calib(j).kinematic_dependancy.q=   ft;
                    Human_model_calib(j).kinematic_dependancy.dq=dft;
                    Human_model_calib(j).kinematic_dependancy.ddq=ddft;
                else
                    syms theta phi real % latitude longitude
                    
                    t1=-calib_parameters.radius(6)*cos(theta)*sin(phi);
                    
                    ft =matlabFunction(t1,'vars',[theta,phi]);
                    dft =matlabFunction(jacobian(t1,[theta,phi]),'vars',[theta,phi]);
                    ddft =matlabFunction(jacobian(jacobian(t1,[theta,phi]),[theta,phi]),'vars',[theta,phi]);
                    Human_model_calib(j).kinematic_dependancy.q=   ft;
                    Human_model_calib(j).kinematic_dependancy.dq=dft;
                    Human_model_calib(j).kinematic_dependancy.ddq=ddft;
                    
                end
            case 'RScapuloThoracic_J5'
                if sum(contains({Human_model_calib.name},'RScapuloThoracic_Jalpha'))
                    syms theta1 theta2 real % latitude longitude
                    t1 = atan(-(calib_parameters.radius(1)*calib_parameters.radius(3)*tan(theta2)*(1 + tan(theta1)^2))/(calib_parameters.radius(3)*calib_parameters.radius(2)+calib_parameters.radius(1)*calib_parameters.radius(2)*tan(theta1)^2));
                    ft =matlabFunction(t1,'vars',[theta1,theta2]);
                    dft =matlabFunction(jacobian(t1,[theta1,theta2]),'vars',[theta1,theta2]);
                    ddft =matlabFunction(jacobian(jacobian(t1,[theta1,theta2]),[theta1,theta2]),'vars',[theta1,theta2]);
                    Human_model_calib(j).kinematic_dependancy.q=ft;
                    Human_model_calib(j).kinematic_dependancy.dq=dft;
                    Human_model_calib(j).kinematic_dependancy.ddq=ddft;
                    
                end
                
            case 'RScapuloThoracic_Jalpha'
                
                syms theta1 theta2 real
                phi = atan(-(calib_parameters.radius(1)*calib_parameters.radius(3)*tan(theta2)*(1 + tan(theta1)^2))/(calib_parameters.radius(3)*calib_parameters.radius(2)+calib_parameters.radius(1)*calib_parameters.radius(2)*tan(theta1)^2));
                t1=atan(tan(theta1)*(-calib_parameters.radius(2)/calib_parameters.radius(3)*sin(phi)/tan(theta2)-cos(phi)));
                ft =matlabFunction(t1,'vars',[theta1,theta2]);
                dft =matlabFunction(jacobian(t1,[theta1,theta2]),'vars',[theta1,theta2]);
                ddft =matlabFunction(jacobian(jacobian(t1,[theta1,theta2]),[theta1,theta2]),'vars',[theta1,theta2]);
                Human_model_calib(j).kinematic_dependancy.q=ft;
                Human_model_calib(j).kinematic_dependancy.dq=dft;
                Human_model_calib(j).kinematic_dependancy.ddq=ddft;
                
            case 'LScapuloThoracic_J5'
                if sum(contains({Human_model_calib.name},'LScapuloThoracic_Jalpha'))
                    syms theta1 theta2 real % latitude longitude
                    t1 = atan(-(calib_parameters.radius(4)*calib_parameters.radius(6)*tan(theta2)*(1 + tan(theta1)^2))/(calib_parameters.radius(6)*calib_parameters.radius(5)+calib_parameters.radius(4)*calib_parameters.radius(5)*tan(theta1)^2));
                    ft =matlabFunction(t1,'vars',[theta1,theta2]);
                    dft =matlabFunction(jacobian(t1,[theta1,theta2]),'vars',[theta1,theta2]);
                    ddft =matlabFunction(jacobian(jacobian(t1,[theta1,theta2]),[theta1,theta2]),'vars',[theta1,theta2]);
                    Human_model_calib(j).kinematic_dependancy.q=ft;
                    Human_model_calib(j).kinematic_dependancy.dq=dft;
                    Human_model_calib(j).kinematic_dependancy.ddq=ddft;
                    
                end
                
                
            case 'LScapuloThoracic_Jalpha'
                syms theta1 theta2 real
                phi= atan(-(calib_parameters.radius(4)*calib_parameters.radius(6)*tan(theta2)*(1 + tan(theta1)^2))/(calib_parameters.radius(6)*calib_parameters.radius(5)+calib_parameters.radius(4)*calib_parameters.radius(5)*tan(theta1)^2));
                t1=atan(tan(theta1)*(-calib_parameters.radius(5)/calib_parameters.radius(6)*sin(phi)/tan(theta2)-cos(phi)));
                ft =matlabFunction(t1,'vars',[theta1,theta2]);
                dft =matlabFunction(jacobian(t1,[theta1,theta2]),'vars',[theta1,theta2]);
                ddft =matlabFunction(jacobian(jacobian(t1,[theta1,theta2]),[theta1,theta2]),'vars',[theta1,theta2]);
                Human_model_calib(j).kinematic_dependancy.q=ft;
                Human_model_calib(j).kinematic_dependancy.dq=dft;
                Human_model_calib(j).kinematic_dependancy.ddq=ddft;
        end
       
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Symbolical fonction suppression
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rmpath('Symbolic_function')
% rmdir('Symbolic_function','s')

end
