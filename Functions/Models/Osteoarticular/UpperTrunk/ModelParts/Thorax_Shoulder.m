function [Human_model]= Thorax_Shoulder(Human_model,k,Mass,AttachmentPoint)
% Addition of a thorax model
%   INPUT
%   - Human_model: osteo-articular model of an already existing
%   model (see the Documentation for the structure)
%   - k: homothety coefficient for the geometrical parameters (defined as
%   the subject size in cm divided by 180)
%   - Mass: mass of the solids
%   - AttachmentPoint: name of the attachment point of the model on the
%   already existing model (character string)
%   OUTPUT
%   - Human_model: new osteo-articular model (see the Documentation
%   for the structure) 
%________________________________________________________
%
% Licence
% Toolbox distributed under GPL 3.0 Licence
%________________________________________________________
%
% Authors : Antoine Muller, Charles Pontonnier, Pierre Puchaud and
% Georges Dumont
%________________________________________________________
%% Solid list

list_solid={'UpperTrunk_J1' 'UpperTrunk_J2' 'Thorax'};

%% Solid numbering incremation

s=size(Human_model,2)+1;  %#ok<NASGU> % num�ro du premier solide
for i=1:size(list_solid,2)      % num�rotation de chaque solide : s_"nom du solide"
    if i==1
        eval(strcat('s_',list_solid{i},'=s;'))
    else
        eval(strcat('s_',list_solid{i},'=s_',list_solid{i-1},'+1;'))
    end
end

% find the number of the mother from the attachment point: 'attachment_pt'
if numel(Human_model) == 0
    s_mother=0;
    pos_attachment_pt=[0 0 0]';
else
    test=0;
    for i=1:numel(Human_model)
        for j=1:size(Human_model(i).anat_position,1)
            if strcmp(AttachmentPoint,Human_model(i).anat_position{j,1})
                s_mother=i;
                pos_attachment_pt=Human_model(i).anat_position{j,2}+Human_model(s_mother).c;
                test=1;
                break
            end
        end
        if i==numel(Human_model) && test==0
            error([AttachmentPoint ' is no existent'])
        end
    end
    if Human_model(s_mother).child == 0      % si la m�re n'a pas d'enfant
        Human_model(s_mother).child = eval(['s_' list_solid{1}]);    % l'enfant de cette m�re est ce solide
    else
        [Human_model]=sister_actualize(Human_model,Human_model(s_mother).child,eval(['s_' list_solid{1}]));   % recherche de la derni�re soeur
    end
end


%%                     Definition of anatomical landmarks

% ------------------------- Thorax ----------------------------------------

% Center of mass location with respect to the reference frame
CoM_Thorax = k*[0.060 0.303 0];

% Node locations
Thorax_T12L1JointNode = k*[0.022 0.154 0] - CoM_Thorax;
Thorax_C1HatNode = k*[0.026 0.6 0] - CoM_Thorax;
Thorax_T1C5 = k*[0.013 0.462 0] - CoM_Thorax;
Thorax_ShoulderRightNode = k*[-0.0408 0.1099 0.1929]-Thorax_T12L1JointNode;
Thorax_ShoulderLeftNode = [1 1 -1].*Thorax_ShoulderRightNode;
NeckNode=Thorax_C1HatNode;
Acromion_inThorax = k*[-0.0416 0.1707 0.1853];
% Joints imported and adjusted from (Puchaud et al. 2019)
Thorax_osim2antoine         = [k k k]; % scaling coef based on shoulder width
%Thorax_osim2antoine         = [k k Thorax_ShoulderRightNode(3)/0.17]; % scaling coef based on shoulder width
CoM_Thorax_osim             = Thorax_osim2antoine.*[-0.0591 -0.1486 0];
Thorax_scjJointRightNode    = Thorax_osim2antoine.*[0.006325 0.00693 0.025465] - CoM_Thorax_osim;
Thorax_scjJointLeftNode     = Thorax_osim2antoine.*[0.006325 0.00693 -0.025465] - CoM_Thorax_osim;
Thorax_EllipsoidRightNode   = Thorax_osim2antoine.*[-0.02 -0.0173 0.0609] - CoM_Thorax_osim;
Thorax_EllipsoidLeftNode    = Thorax_osim2antoine.*[-0.02 -0.0173 -0.0609] - CoM_Thorax_osim;

%% Definition of anatomical landmarks (with respect to the center of mass of the solid)

Thorax_position_set= {...
    % Markers
    'STRN', k*[0.095 -0.055 0]'; ...
    'CLAV', k*[0.01 0.13 0]'; ...
    'T10', k*[-0.12 -0.115 0]'; ...
    'T8', k*[-0.13 -0.05 0]'; ...
    'T12', k*[-0.10 -0.175 0]'; ...
    'C7', k*[-0.105 0.165 0]'; ...
    % Joint Nodes
    'NeckNode', NeckNode'; ...
    'Thorax_T1C5', Thorax_T1C5'; ...
    'Thorax_scjJointRightNode', Thorax_scjJointRightNode'; ...
    'Thorax_scjJointLeftNode', Thorax_scjJointLeftNode'; ...
    'Thorax_T12L1JointNode', Thorax_T12L1JointNode'; ...
    'R_Thorax_EllipsoidNode', Thorax_EllipsoidRightNode'; ... 
    'L_Thorax_EllipsoidNode', Thorax_EllipsoidLeftNode'; ... 
    'ShoulderRightNode_inThorax', Thorax_ShoulderRightNode';...
    'ShoulderLeftNode_inThorax', Thorax_ShoulderLeftNode';...
    'RightAcromion_inThorax', Acromion_inThorax';...
    'LeftAcromion_inThorax', [1 0 0;0 1 0;0 0 -1]*Acromion_inThorax';...
    % Muscle paths   
    ['RThorax_r_PECM1-P1'],Thorax_osim2antoine'.*[0.047729456651525642 -0.10400960432311702 0.091178074794605088]'- CoM_Thorax_osim';...
    ['LThorax_r_PECM1-P1'],Thorax_osim2antoine'.*[0.047729456651525642 -0.10400960432311702 -0.091178074794605088]'- CoM_Thorax_osim';...
    ['RThorax_PECM1-P3'],Thorax_osim2antoine'.*[0.0063633;-0.0073233;0.11927]- CoM_Thorax_osim';...
    ['RThorax_PECM2-P3'],Thorax_osim2antoine'.*([0.020397;-0.03445;0.12312])- CoM_Thorax_osim';...
    ['RThorax_PECM2-P4'],Thorax_osim2antoine'.*([0.03091;-0.03922;0.09705])- CoM_Thorax_osim';...
    
    ['RThorax_PECM2-P5'],Thorax_osim2antoine'.*([0.053209800941519628 -0.1156612321448223 0.024739462102192737]')- CoM_Thorax_osim';...
    
    
    ['RThorax_PECM3-P3'],Thorax_osim2antoine'.*([0.02984;-0.069739;0.1151])- CoM_Thorax_osim';...
    ['RThorax_PECM3-P4'],Thorax_osim2antoine'.*([0.0525;-0.08417;0.08935])- CoM_Thorax_osim';...
    ['RThorax_PECM3-P5'],Thorax_osim2antoine'.*([0.019539914459309596 -0.038002047654690653 0.012999454632222693]')- CoM_Thorax_osim';...
    ['RThorax_LAT1-P4'],Thorax_osim2antoine'.*([-0.11828;-0.10118;0.03316])- CoM_Thorax_osim';...
    ['RThorax_LAT1-P5'],Thorax_osim2antoine'.*([-0.09578;-0.11724;0.00882])- CoM_Thorax_osim';...
    ['RThorax_LAT2-P4'],Thorax_osim2antoine'.*([-0.10992;-0.16908;0.02878])- CoM_Thorax_osim';...
    ['RThorax_LAT2-P5'],Thorax_osim2antoine'.*([-0.062738100000000005 -0.25480799999999998 0.090611700000000003]')- CoM_Thorax_osim';...
    ['RThorax_LAT3-P4'],Thorax_osim2antoine'.*([-0.090819691158656735 -0.21745171689568252 -0.0015599645546081824]')- CoM_Thorax_osim';...
    ['RThorax_LAT3-P5'],Thorax_osim2antoine'.*([-0.07117;-0.24858;0.00907])- CoM_Thorax_osim';...
    ['LThorax_PECM1-P3'],Thorax_osim2antoine'.*([0.0063633;-0.0073233;-0.11927])- CoM_Thorax_osim';...
    ['LThorax_PECM2-P3'],Thorax_osim2antoine'.*([0.020397;-0.03445;-0.12312])- CoM_Thorax_osim';...
    ['LThorax_PECM2-P4'],Thorax_osim2antoine'.*([0.03091;-0.03922;-0.09705])- CoM_Thorax_osim';...
    ['LThorax_PECM2-P5'],Thorax_osim2antoine'.*([0.053209800941519628 -0.1156612321448223 -0.024739462102192737]')- CoM_Thorax_osim';...
    ['LThorax_PECM3-P3'],Thorax_osim2antoine'.*([0.02984;-0.069739;-0.1151])- CoM_Thorax_osim';...
    ['LThorax_PECM3-P4'],Thorax_osim2antoine'.*([0.0525;-0.08417;-0.08935])- CoM_Thorax_osim';...
    ['LThorax_PECM3-P5'],Thorax_osim2antoine'.*([0.019539914459309596 -0.038002047654690653 -0.012999454632222693]')- CoM_Thorax_osim';...
    ['LThorax_LAT1-P4'],Thorax_osim2antoine'.*([-0.11828;-0.10118;-0.03316])- CoM_Thorax_osim';...
  
    
    ['LThorax_LAT1-P5'],Thorax_osim2antoine'.*([-0.1008796560238172 -0.11663128441390257 0.0017099582619030595]')- CoM_Thorax_osim';...
    ['LThorax_LAT2-P4'],Thorax_osim2antoine'.*([-0.10992;-0.16908;-0.02878])- CoM_Thorax_osim';...
    ['LThorax_LAT2-P5'],Thorax_osim2antoine'.*([-0.062738100000000005 -0.25480799999999998 -0.090611700000000003]')- CoM_Thorax_osim';...
    ['LThorax_LAT3-P4'],Thorax_osim2antoine'.*([-0.090819691158656735 -0.21745171689568252 0.0015599645546081824]')- CoM_Thorax_osim';...
    ['LThorax_LAT3-P5'],Thorax_osim2antoine'.*([-0.07117;-0.24858;-0.00907])- CoM_Thorax_osim';...
    ['RThorax_stern_mast-P1'],Thorax_osim2antoine'.*([-0.002;-0.0005;0.0087])- CoM_Thorax_osim';...
    ['LThorax_stern_mast-P1'],Thorax_osim2antoine'.*([-0.002;-0.0005;-0.0087])- CoM_Thorax_osim';...
    ['RThorax_rhomboid_S-P1'],Thorax_osim2antoine'.*([-0.0907 -0.0093 -0.0005]')- CoM_Thorax_osim';...
    ['RThorax_rhomboid_I-P1'],Thorax_osim2antoine'.*([-0.0733 0.0402 -0.0020]')- CoM_Thorax_osim';...
    ['LThorax_rhomboid_S-P1'],Thorax_osim2antoine'.*([-0.0907 -0.0093 0.0005]')- CoM_Thorax_osim';...
    ['LThorax_rhomboid_I-P1'],Thorax_osim2antoine'.*([-0.0733 0.0402 0.0020]')- CoM_Thorax_osim';...
    ['RThorax_serr_ant_1-P2'],Thorax_osim2antoine'.*([-0.0005 -0.1705 0.1482]')- CoM_Thorax_osim';...
    ['RThorax_serr_ant_2-P2'],Thorax_osim2antoine'.*([0.0167 -0.0763 0.1147]')- CoM_Thorax_osim';...
    ['RThorax_serr_ant_3-P2'],Thorax_osim2antoine'.*([-0.0285 -0.0145 0.0993]')- CoM_Thorax_osim';...
    ['LThorax_serr_ant_1-P2'],Thorax_osim2antoine'.*([-0.0005 -0.1705 -0.1482]')- CoM_Thorax_osim';...
    ['LThorax_serr_ant_2-P2'],Thorax_osim2antoine'.*([0.0167 -0.0763 -0.1147]')- CoM_Thorax_osim';...
    ['LThorax_serr_ant_3-P2'],Thorax_osim2antoine'.*([-0.0285 -0.0145 -0.0993]')- CoM_Thorax_osim';...
    ['RThorax_TrapeziusScapula_M-P1'],Thorax_osim2antoine'.*([-0.0845;-0.0004;-0.0018])- CoM_Thorax_osim';... 
    ['LThorax_TrapeziusScapula_M-P1'],Thorax_osim2antoine'.*([-0.0845;-0.0004;0.0018])- CoM_Thorax_osim';... 
    ['RThorax_TrapeziusScapula_S-P1'],Thorax_osim2antoine'.*([-0.0748;0.0450;-0.0036])- CoM_Thorax_osim';... 
    ['LThorax_TrapeziusScapula_S-P1'],Thorax_osim2antoine'.*([-0.0748;0.0450;0.0036])- CoM_Thorax_osim';... 
    ['RThorax_TrapeziusScapula_I-P1'],Thorax_osim2antoine'.*([-0.1016;-0.1346;0.0011])- CoM_Thorax_osim';... 
    ['LThorax_TrapeziusScapula_I-P1'],Thorax_osim2antoine'.*([-0.1016;-0.1346;-0.0011])- CoM_Thorax_osim';... 
    ['RThorax_TrapeziusClavicle_S-P1'],Thorax_osim2antoine'.*([-0.0623;0.1203;0.0024])- CoM_Thorax_osim';... 
    ['LThorax_TrapeziusClavicle_S-P1'],Thorax_osim2antoine'.*([-0.0623;0.1203;-0.0024])- CoM_Thorax_osim';...
    
    % From moment arm optimisation
    ['RThorax_Rhomboideus_I_VP1'], k*[0.0652 ; 0.2980 ; 0.1174] - CoM_Thorax' ;... 
    ['LThorax_Rhomboideus_I_VP1'], k*[0.0652 ; 0.2980 ; -0.1174] - CoM_Thorax' ;... 

    ['RThorax_PectoralisMajorThorax_I_VP1'], k*[0.0616 ; 0.2980 ; -0.0643] - CoM_Thorax' ;... 
    ['LThorax_PectoralisMajorThorax_I_VP1'], k*[0.0616 ; 0.2980 ; 0.0643]- CoM_Thorax' ;... 

    ['RThorax_PectoralisMajorThorax_M_VP1'], k*[0.0539 ; 0.2261 ; 0.0263] - CoM_Thorax' ;... 
    ['LThorax_PectoralisMajorThorax_M_VP1'], k*[0.0539 ; 0.2261 ; -0.0263] - CoM_Thorax' ;... 

    
    ['RThorax_TrapeziusScapula_M_VP1'], k*[0.0126 ; 0.2972 ; -0.0018] - CoM_Thorax' ;... 
    ['LThorax_TrapeziusScapula_M_VP1'], k*[0.0126 ; 0.2972 ; 0.0018] - CoM_Thorax' ;... 

    ['RThorax_TrapeziusScapula_S_VP1'], k*[0.0223 ; 0.3426 ; -0.0036] - CoM_Thorax' ;... 
    ['LThorax_TrapeziusScapula_S_VP1'], k*[0.0223 ; 0.3426 ; 0.0036] - CoM_Thorax' ;... 

    ['RThorax_TrapeziusScapula_I_VP1'], k*[-0.0045 ; 0.1630 ; 0.0011] - CoM_Thorax' ;... 
    ['LThorax_TrapeziusScapula_I_VP1'], k*[-0.0045 ; 0.1630 ; -0.0011] - CoM_Thorax' ;... 

    [ 'RThorax_TrapeziusClavicle_S_VP1'], k*[0.0348 ; 0.4179 ; 0.0024] -  CoM_Thorax' ;... 
    [ 'LThorax_TrapeziusClavicle_S_VP1'], k*[0.0348 ; 0.4179 ; -0.0024] -  CoM_Thorax' ;... 
    
    [ 'RThorax_LatissimusDorsi_S_VP1'], k*[-0.1262 ; 0.2975 ; -0.0185] -  CoM_Thorax' ;... 
    [ 'LThorax_LatissimusDorsi_S_VP1'], k*[-0.1262 ; 0.2975 ; 0.0185] -  CoM_Thorax' ;... 
    
    [ 'RThorax_LatissimusDorsi_I_VP1'], k*[0.0770 ; 0.2561 ; 0.1467]  -  CoM_Thorax' ;... 
    [ 'LThorax_LatissimusDorsi_I_VP1'], k*[0.0770 ; 0.2561 ; -0.1467] -  CoM_Thorax' ;... 

    [ 'RThorax_SerratusAnterior_M_VP1'], k*[0.0874 ; 0.3387 ; 0.1416] -  CoM_Thorax' ;... 
    [ 'LThorax_SerratusAnterior_M_VP1'], k*[0.0874 ; 0.3387 ; -0.1416]  -  CoM_Thorax' ;... 

    ['RThorax_SerratusAnterior_I_VP1'], k*[0.1131 ; 0.3919 ; 0.1220] -  CoM_Thorax' ;... 
    ['LThorax_SerratusAnterior_I_VP1'], k*[0.1131 ; 0.3919 ; -0.1220] -  CoM_Thorax' ;... 

    ['RThorax_PectoralisMinor_VP1'], k*[0.0330 ; 0.3427 ; 0.0438] - CoM_Thorax' ;... 
    ['LThorax_PectoralisMinor_VP1'], k*[0.0330 ; 0.3427 ; -0.0438] - CoM_Thorax' ;... 


    };

%% Scaling inertial parameters

% longueur entre 'Pelvis_L5JointNode' et 'Thorax_T1C5'
Lpts={'Pelvis_LowerTrunkNode';'LowerTrunk_UpperTrunkNode'};
for pp=1:2
    test=0;
    for i=1:numel(Human_model)
        for j=1:size(Human_model(i).anat_position,1)
            if strcmp(Lpts{pp},Human_model(i).anat_position{j,1})
               Lpts{pp,2}=i; % solid number
               Lpts{pp,3}=j; % number of the anatomical landmarks
               test=1;
               break
            end
        end
        if i==numel(Human_model) && test==0
            error([Lpts{pp} ' is no existent'])        
        end       
    end
end
Length_Thorax = distance_point(Lpts{1,3},Lpts{1,2},Lpts{2,3},Lpts{2,2},Human_model,zeros(numel(Human_model),1)) ...
    +norm(Thorax_T12L1JointNode-Thorax_T1C5);

%% ["Adjustments to McConville et al. and Young et al. body segment inertial parameters"] R. Dumas

[I_Thorax]=rgyration2inertia([27 25 28 18 2 4*1i], Mass.Thorax_Mass, [0 0 0], Length_Thorax);

%% "Human_model" structure generation
 
num_solid=0;
% UpperTrunk_J1
num_solid=num_solid+1;        % number of the solid ...
name=list_solid{num_solid}; % solid name
eval(['incr_solid=s_' name ';'])  % number of the solid in the model
Human_model(incr_solid).name=name;               % solid name
Human_model(incr_solid).sister=0;                
Human_model(incr_solid).child=s_UpperTrunk_J2;                   
Human_model(incr_solid).mother=s_mother;           
Human_model(incr_solid).a=[0 0 1]'; 
Human_model(incr_solid).joint=1;  
Human_model(incr_solid).limit_inf=-0.2;
Human_model(incr_solid).limit_sup=0.2;
Human_model(incr_solid).linear_constraint=[];
Human_model(incr_solid).Visual=0;
Human_model(incr_solid).b=pos_attachment_pt;
Human_model(incr_solid).c=[0 0 0]';
Human_model(incr_solid).m=0;                 
Human_model(incr_solid).I=zeros(3,3);
Human_model(incr_solid).comment='Trunk Flexion(-)/Extension(+)';
Human_model(incr_solid).FunctionalAngle='Trunk Flexion(-)/Extension(+)';

% UpperTrunk_J2
num_solid=num_solid+1;        % number of the solid ...
name=list_solid{num_solid}; % solid name
eval(['incr_solid=s_' name ';'])  % number of the solid in the model
Human_model(incr_solid).name=name;               % solid name
Human_model(incr_solid).sister=0;                
Human_model(incr_solid).child=s_Thorax;                   
Human_model(incr_solid).mother=s_UpperTrunk_J1;           
Human_model(incr_solid).a=[1 0 0]';
Human_model(incr_solid).joint=1;
Human_model(incr_solid).limit_inf=-0.2;
Human_model(incr_solid).limit_sup=0.2;
Human_model(incr_solid).linear_constraint=[];
Human_model(incr_solid).Visual=0;
Human_model(incr_solid).b=[0 0 0]';  
Human_model(incr_solid).c=[0 0 0]';
Human_model(incr_solid).m=0;                 
Human_model(incr_solid).I=zeros(3,3);
Human_model(incr_solid).comment='Trunk Axial Rotation Right(+)/Left(-)';
Human_model(incr_solid).FunctionalAngle='Trunk Axial Rotation Right(+)/Left(-)';

% Thorax
num_solid=num_solid+1;        % number of the solid ...
name=list_solid{num_solid}; % solid name
eval(['incr_solid=s_' name ';'])  % number of the solid in the model
Human_model(incr_solid).name=name;               % solid name
Human_model(incr_solid).sister=0;                
Human_model(incr_solid).child=0;                   
Human_model(incr_solid).mother=s_UpperTrunk_J2;           
Human_model(incr_solid).a=[0 1 0]';    
Human_model(incr_solid).joint=1;
Human_model(incr_solid).limit_inf=-0.2;
Human_model(incr_solid).limit_sup=0.2;
Human_model(incr_solid).Visual=1;
Human_model(incr_solid).Visual_file='Holzbaur/torso.mat';
Human_model(incr_solid).calib_k_constraint=[];
Human_model(incr_solid).b=[0 0 0]';  
Human_model(incr_solid).c=-Thorax_T12L1JointNode';
Human_model(incr_solid).m=Mass.Thorax_Mass;                 
Human_model(incr_solid).I=[I_Thorax(1) I_Thorax(4) I_Thorax(5); I_Thorax(4) I_Thorax(2) I_Thorax(6); I_Thorax(5) I_Thorax(6) I_Thorax(3)];
Human_model(incr_solid).anat_position=Thorax_position_set;
Human_model(incr_solid).L={'Pelvis_LowerTrunkNode';'Thorax_T1C5'};
Human_model(incr_solid).comment='Trunk Lateral Bending Right(+)/Left(-)';
Human_model(incr_solid).FunctionalAngle='Trunk Lateral Bending Right(+)/Left(-)';
Human_model(incr_solid).density=0.92;


% Wrapping 1 : kind of right ellipsoid
Human_model(incr_solid).wrap(1).name='Wrap R Ellipsoid';
Human_model(incr_solid).wrap(1).anat_position='R_Thorax_EllipsoidNode';
Human_model(incr_solid).wrap(1).type='C'; % C: Cylinder or S: Sphere
Human_model(incr_solid).wrap(1).R=(Thorax_osim2antoine(2)*0.15+Thorax_osim2antoine(3)*0.07)/2;
Human_model(incr_solid).wrap(1).orientation=[1,0,0;0,0,-1;0,1,0];
Human_model(incr_solid).wrap(1).location=Thorax_EllipsoidRightNode';
Human_model(incr_solid).wrap(1).h=0.5;
Human_model(incr_solid).wrap(1).num_solid=incr_solid;


% Wrapping 1 : kind of left ellipsoid
Human_model(incr_solid).wrap(2).name='Wrap L Ellipsoid';
Human_model(incr_solid).wrap(2).anat_position='L_Thorax_EllipsoidNode';
Human_model(incr_solid).wrap(2).type='C'; % C: Cylinder or S: Sphere
Human_model(incr_solid).wrap(2).R=(Thorax_osim2antoine(2)*0.15+Thorax_osim2antoine(3)*0.07)/2;
Human_model(incr_solid).wrap(2).orientation=[1,0,0;0,0,-1;0,1,0];
Human_model(incr_solid).wrap(2).location=Thorax_EllipsoidLeftNode';
Human_model(incr_solid).wrap(2).h=0.5;
Human_model(incr_solid).wrap(2).num_solid=incr_solid;


end