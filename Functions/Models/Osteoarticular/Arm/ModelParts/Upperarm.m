function [OsteoArticularModel]= Upperarm(OsteoArticularModel,k,Signe,Mass,AttachmentPoint,varargin)
% Addition of an upper arm model
%   This upper arm model contains one solid (humerus), exhibits 3 dof for the
%   shoulder
%
%   INPUT
%   - OsteoArticularModel: osteo-articular model of an already existing
%   model (see the Documentation for the structure)
%   - k: homothety coefficient for the geometrical parameters (defined as
%   the subject size in cm divided by 180)
%   - Signe: side of the upper arm model ('R' for right side or 'L' for left side)
%   - Mass: mass of the solids
%   - AttachmentPoint: name of the attachment point of the model on the
%   already existing model (character string)
%   OUTPUT
%   - OsteoArticularModel: new osteo-articular model (see the Documentation
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
% list_solid={'Glenohumeral_J1' 'Glenohumeral_J2' 'Glenohumeral_J3' 'Humerus'};
list_solid={'Glenohumeral_J1' 'Glenohumeral_J2' 'Humerus'};

%% Choose right or left arm
if Signe == 'R'
    Mirror=[1 0 0; 0 1 0; 0 0 1];
    Signe_bool=0;
    FullSide='Right';
elseif Signe == 'L'
    Mirror=[1 0 0; 0 1 0; 0 0 -1];
    Signe_bool=1;
    FullSide='Left';
end

%% solid numbering incremation

s=size(OsteoArticularModel,2)+1;  %#ok<NASGU> % number of the first solid
for i=1:size(list_solid,2)      % each solid numbering: s_"nom du solide"
    if i==1
        eval(strcat('s_',list_solid{i},'=s;'))
    else
        eval(strcat('s_',list_solid{i},'=s_',list_solid{i-1},'+1;'))
    end
end

% find the number of the mother from the attachment point: 'attachment_pt'
if ~numel(AttachmentPoint)
    s_mother=0;
    pos_attachment_pt=[0 0 0]';
else
    test=0;
    for i=1:numel(OsteoArticularModel)
        for j=1:size(OsteoArticularModel(i).anat_position,1)
            if strcmp(AttachmentPoint,OsteoArticularModel(i).anat_position{j,1})
                s_mother=i;
                pos_attachment_pt=OsteoArticularModel(i).anat_position{j,2}+OsteoArticularModel(s_mother).c;
                test=1;
                break
            end
        end
        if i==numel(OsteoArticularModel) && test==0
            error([AttachmentPoint ' is no existent'])
        end
    end
    if OsteoArticularModel(s_mother).child == 0      % if the mother don't have any child
        OsteoArticularModel(s_mother).child = eval(['s_' list_solid{1}]);    % the child of this mother is this solid
    else
        [OsteoArticularModel]=sister_actualize(OsteoArticularModel,OsteoArticularModel(s_mother).child,eval(['s_' list_solid{1}]));   % recherche de la derni�re soeur
    end
end

%%                      Node Definition

% ------------------------- Humerus ---------------------------------------

% Node positions
Humerus_ghJointNode = (k*[0 0.1674 0])*Mirror;
Humerus_ElbowJointNode = (k*[0 -0.1674 0])*Mirror;
osim2antoine=[k k k];
%osim2antoine=[k (Humerus_ghJointNode(2)-Humerus_ElbowJointNode(2))/0.2904 k];
Humerus_RadiusJointNode = (k*[0 -0.1674 0.0191])*Mirror;
Humerus_UlnaJointNode = (k*[0 -0.1674 -0.0191])*Mirror;
Humerus_Brachioradialis = (k*[-0.006 -0.209 -0.007])*Mirror; %in local frame gh Murray2001
% Humerus_Biceps = (k*[0.025 0.009 0.006])*Mirror; %in local frame gh Murray2001
Humerus_BicepsL_via2 = (osim2antoine.*[0.02131 0.01793 0.01028])*Mirror;  %in local frame OSIMarm26
Humerus_BicepsL_via3 = (osim2antoine.*[0.02378 -0.00511 0.01201])*Mirror;  %in local frame OSIMarm26
Humerus_BicepsL_via4 = (osim2antoine.*[0.01345 -0.02827 0.00136])*Mirror;  %in local frame OSIMarm26
Humerus_BicepsL_via5 = (osim2antoine.*[0.01068 -0.07736 -0.00165])*Mirror;  %in local frame OSIMarm26
Humerus_BicepsL_via6 = (osim2antoine.*[0.01703 -0.12125 0.00024])*Mirror;  %in local frame OSIMarm26
Humerus_BicepsS_via2 = (osim2antoine.*[0.01117 -0.07576 -0.01101])*Mirror;  %in local frame OSIMarm26
Humerus_BicepsS_via3 = (osim2antoine.*[0.01703 -0.12125 -0.01079])*Mirror;  %in local frame OSIMarm26
Humerus_Biceps_via7 = (osim2antoine.*[0.0228 -0.1754 -0.0063])*Mirror;  %in local frame OSIMarm26

%Humerus_ECRL = (k*[-0.005 -0.260 -0.002])*Mirror; %in local frame gh Murray2001
%Humerus_Brachialis = (k*[0.008 -0.184 -0.013])*Mirror; %in local frame gh Murray2001
%Humerus_Brachialis = (k*[0.0068 -0.1739 -0.0036])*Mirror; %in local frame OSIMarm26
%Humerus_PronatorTeres = (k*[0.003 -0.270 -0.051])*Mirror; %in local frame gh Murray2001

Humerus_Triceps = (k*[-0.004 -0.039 -0.006])*Mirror; %in local frame gh Murray2001
Humerus_TricepsLg_via1 = (osim2antoine.*[-0.02714 -0.11441 -0.00664])*Mirror;  %in local frame OSIMarm26
Humerus_TricepsLat_o = (osim2antoine.*[-0.00599 -0.12646 0.00428])*Mirror;     %in local frame OSIMarm26
Humerus_TricepsLat_via1 = (osim2antoine.*[-0.02344 -0.14528 0.00928])*Mirror;  %in local frame OSIMarm26
Humerus_TricepsMed_o = (osim2antoine.*[-0.00838 -0.13695 -0.00906])*Mirror;    %in local frame OSIMarm26
Humerus_TricepsMed_via1 = (osim2antoine.*[-0.02601 -0.15139 -0.0108])*Mirror;  %in local frame OSIMarm26
Humerus_Triceps_via2 = (osim2antoine.*[-0.03184 -0.22637 -0.01217])*Mirror; %in local frame OSIMarm26
Humerus_Triceps_via3 = (osim2antoine.*[-0.01743 -0.26757 -0.01208])*Mirror; %in local frame OSIMarm26

% Pennestri to Custom vector transformation
dh = -0.140;
eh = 0.140;
L_humerus = 2*0.1674;
k_Pennestri2custom = L_humerus/(eh-dh)*k*Mirror; % Humerus length equality
Pennestri2custom = k_Pennestri2custom*[0 0 1;-1 0 0;0 -1 0];

%OpenSim to CusToM
CoM_humerus= [0.018064  -0.140141  -0.012746]';

%%              Definition of anatomical landmarks

Humerus_position_set = {...
    [Signe 'HUM'], k*Mirror*[0 -0.1674 -0.05]'; ...
    [Signe 'Humerus_RadiusJointNode'], Humerus_RadiusJointNode'; ...
    [Signe 'Humerus_UlnaJointNode'], Humerus_UlnaJointNode'; ...
    [Signe 'Humerus_ElbowJointNode'], Humerus_ElbowJointNode'; ...
    [Signe 'Humerus_ghJointNode'], Humerus_ghJointNode'; ...
    [Signe 'EAV'], k*Mirror*[0.05 0.1674 -0.01]'; ...
    [Signe 'EAR'], k*Mirror*[-0.05 0.1674 0]'; ...
    %     [Signe 'Humerus_Brachioradialis_o'], (Humerus_Brachioradialis+Humerus_ghJointNode)'; ...
    %   [Signe 'Humerus_Brachioradialis_o'], Humerus_RadiusJointNode'+[0 0.07 0]'; ...
    %     [Signe 'Humerus_Biceps'], (Humerus_Biceps+Humerus_ghJointNode)'; ...
    [Signe 'Humerus_BicepsL_via2'], (Humerus_BicepsL_via2+Humerus_ghJointNode)';...
    [Signe 'Humerus_BicepsL_via3'], (Humerus_BicepsL_via3+Humerus_ghJointNode)';...
    [Signe 'Humerus_BicepsL_via4'], (Humerus_BicepsL_via4+Humerus_ghJointNode)';...
    [Signe 'Humerus_BicepsL_via5'], (Humerus_BicepsL_via5+Humerus_ghJointNode)';...
    [Signe 'Humerus_BicepsL_via6'], (Humerus_BicepsL_via6+Humerus_ghJointNode)';...
    [Signe 'Humerus_BicepsS_via2'], (Humerus_BicepsS_via2+Humerus_ghJointNode)';...
    [Signe 'Humerus_BicepsS_via3'], (Humerus_BicepsS_via3+Humerus_ghJointNode)';...
    [Signe 'Humerus_Biceps_via7'], (Humerus_Biceps_via7+Humerus_ghJointNode)';...
    %     [Signe 'Humerus_ECRL_o'], (Humerus_ECRL+Humerus_ghJointNode)'; ...
    %    [Signe 'Humerus_ECRL_o'], Humerus_RadiusJointNode'+[0 0.03 0]'; ...
    %   [Signe 'Humerus_Brachialis_o'], (Humerus_Brachialis+Humerus_ghJointNode)'; ...
    %     [Signe 'Humerus_PronatorTeres_o'], (Humerus_PronatorTeres+Humerus_ghJointNode)'; ...
    % [Signe 'Humerus_PronatorTeres_o'], Humerus_UlnaJointNode'+[0 0.02 0.01]'; ...
    [Signe 'Humerus_Triceps_o'], (Humerus_Triceps+Humerus_ghJointNode)'; ...
    [Signe 'Humerus_TricepsLg_via1'], (Humerus_TricepsLg_via1+Humerus_ghJointNode)';...
    %  [Signe 'Humerus_TricepsLat_o'], (Humerus_TricepsLat_o+Humerus_ghJointNode)'; ...
    %  [Signe 'Humerus_TricepsLat_via1'], (Humerus_TricepsLat_via1+Humerus_ghJointNode)';...
    %  [Signe 'Humerus_TricepsMed_o'], (Humerus_TricepsMed_o+Humerus_ghJointNode)'; ...
    %     [Signe 'Humerus_TricepsMed_via1'], (Humerus_TricepsMed_via1+Humerus_ghJointNode)';...
    [Signe 'Humerus_Triceps_via2'], (Humerus_Triceps_via2+Humerus_ghJointNode)';...
    [Signe 'Humerus_Triceps_via3'], (Humerus_Triceps_via3+Humerus_ghJointNode)';...
    [Signe 'Humerus_Triceps_via4'], Humerus_ElbowJointNode' + k*[-0.028 0 0]';...
    
    % Muscles from (Puchaud et al. 2019)
    [Signe 'humerus_r_DELT1_r-P1'],osim2antoine.*Mirror*([0.00896;-0.11883;0.00585])+Humerus_ghJointNode';...
    [Signe 'humerus_r_DELT1_r-P2'],osim2antoine.*Mirror*([0.01623;-0.11033;0.00412])+Humerus_ghJointNode';...
    [Signe 'humerus_r_DELT2_r-P1'],osim2antoine.*Mirror*([-0.0048 -0.0862 0.0062]')+Humerus_ghJointNode';...
    [Signe 'humerus_r_DELT3_r-P3'],osim2antoine.*Mirror*([-0.0043 -0.1005 0.0038]')+Humerus_ghJointNode';...
    [Signe 'humerus_r_PECM1_r-P2'],osim2antoine.*Mirror*([0.017133;-0.037;-0.00337])+Humerus_ghJointNode';...
    [Signe 'humerus_r_PECM2_r-P1'],osim2antoine.*Mirror*([0.0099999417760256639 -0.030000153006940828 0]')+Humerus_ghJointNode';...
    [Signe 'humerus_r_PECM2_r-P2'],osim2antoine.*Mirror*([0.015513;-0.04223;-0.00447])+Humerus_ghJointNode';...
    [Signe 'humerus_r_PECM3_r-P1'],osim2antoine.*Mirror*([0.010185240697135417 -0.026204007108265964 -0.0031506861697064947]')+Humerus_ghJointNode';...
    [Signe 'humerus_r_PECM3_r-P2'],osim2antoine.*Mirror*([0.014239;-0.049652;-0.0093637])+Humerus_ghJointNode';...
    [Signe 'humerus_r_LAT1_r-P1'],osim2antoine.*Mirror*([0.0058799957641284184 -0.019040131776404189 -0.0034499858058475164]')+Humerus_ghJointNode';...
    [Signe 'humerus_r_LAT2_r-P1'],osim2antoine.*Mirror*([0.0042200299999999996 -0.049998399999999998 -0.000179999]')+Humerus_ghJointNode';...
    [Signe 'humerus_r_LAT3_r-P1'],osim2antoine.*Mirror*([0.0057799963463681624 -0.04100027577871479 -0.0009999977843013195]')+Humerus_ghJointNode';...
    [Signe 'humerus_SUPSP-P1'],osim2antoine.*Mirror*([0.01777999647719139 0.017640077967619992 0.0096499482685446329]')+Humerus_ghJointNode';...
    [Signe 'humerus_SUPSP-P2'],osim2antoine.*Mirror*([0.010169740787382579 0.0095677577211598953 0.020050375624730808]')+Humerus_ghJointNode';...
    [Signe 'humerus_INFSP-P1'],osim2antoine.*Mirror*([-0.017162031747030893 -0.0057299955321240209 0.024807138325052238]')+Humerus_ghJointNode';...
    [Signe 'humerus_INFSP-P2'],osim2antoine.*Mirror*([-0.014333616543501905 0.0027190845035771852 0.022203973006599511]')+Humerus_ghJointNode';...
    [Signe 'humerus_CORB-P3'],osim2antoine.*Mirror*([-0.0023100065501454803 -0.14500057286047488 -0.0093299486575685996]')+Humerus_ghJointNode';...
    [Signe 'humerus_TeresMajor-P2'],osim2antoine.*Mirror*([0.0043200048470684151 -0.039000198909023079 -0.0016999979333101767]')+Humerus_ghJointNode';...
    [Signe 'humerus_TeresMinor-P2'],osim2antoine.*Mirror*([-0.01588 ; -0.00936 ; 0.01085])+Humerus_ghJointNode';...
    [Signe 'humerus_SUBSC-P1'],osim2antoine.*Mirror*([0.010983836047368828 -0.0034073409555911483 -0.019525776262486971]')+Humerus_ghJointNode';...
    [Signe 'humerus_SUBSC-P2'],osim2antoine.*Mirror*([0.018000095195681718 -0.00023000183974550295 -0.011999885411722819]')+Humerus_ghJointNode';...
    [Signe 'humerus_SUBSC-P3'],osim2antoine.*Mirror*([0.018000095195681718 -0.00023000183974550295 -0.011999885411722819]')+Humerus_ghJointNode';...
    
    [Signe 'humerus_DeltoideusClavicle-P3'],osim2antoine.*Mirror*([0.0066436613177381703 -0.10980522018450981 0.0011474186050816253]')+Humerus_ghJointNode';...
    [Signe 'humerus_PectoralisMajorClavicle1-P3'],osim2antoine.*Mirror*([0.010075141338181376 -0.042144919771239353 -0.0026007368382806521]')+Humerus_ghJointNode';...

    % Muscles from (Pennestri et al., 2007)
    
    %  [Signe 'Humerus_Anconeus_o'],k_Pennestri2custom*[0 0 -1;-1 0 0;0 -1 0]*[0.265 0.005 -0.019]'+Humerus_ghJointNode';...
    %  [Signe 'Humerus_TricepsBrachii1_o'],Pennestri2custom*[0.078 0.011 -0.01]'+Humerus_ghJointNode';...
    % [Signe 'Humerus_Brachialis_o'],Pennestri2custom*[0.176 -0.008 0.016]'+Humerus_ghJointNode';...
    %    [Signe 'Humerus_Brachioradialis_o'],Pennestri2custom*[0.246 -0.027 0]'+Humerus_ghJointNode';...
    % [Signe 'Humerus_PronatorTeres_o'],Pennestri2custom*[0.22 0.033 -0.005]'+Humerus_ghJointNode';...
    %  [Signe 'Humerus_CubitalisAnterior_o'],Pennestri2custom*[ 0.149 0.024 0.005]'+Humerus_ghJointNode';...
    %   [Signe 'Humerus_FlexorCarpiUlnaris_o'],L_humerus/(eh-dh)*k*Mirror*[0 0 1;-1 0 0;0 1 0]*[ 0.249 0.027 0]'+Humerus_ghJointNode'+k*Mirror*[-0.02 -0.04 0]';...% addition of a manual correction term
    %  [Signe 'Humerus_ExtensorCarpiUlnaris_o'],Pennestri2custom*[ 0.249 0.027 0]'+Humerus_ghJointNode'+k*Mirror*[0.05 0 0.05]';...% addition of a manual correction term
    %   [Signe 'Humerus_ExtensorDigitorum_o'],Pennestri2custom*[ 0.242 0.02 -0.02]'+Humerus_ghJointNode';...%+k*Mirror*[0.01 -0.05 0]';...% addition of a manual correction term
    %  [Signe 'Humerus_FlexorDigitorumSuperior_o'],Pennestri2custom*[ 0.227 0.011 0.021]'+Humerus_ghJointNode'+k*Mirror*[-0.03 -0.1 0]';...% addition of a manual correction term
    %    [Signe 'Humerus_FlexorCarpiRadialis_o'],Pennestri2custom*[ 0.249 0.027 0]'+Humerus_ghJointNode';...
    %   [Signe 'Humerus_FlexorCarpiRadialis_o'],Humerus_RadiusJointNode'+k*Mirror*[0 0.001 0]';... %Change to look like wrist model in OpenSim
    %     [Signe 'Thorax_Coracobrachialis_i'],Pennestri2custom*[0.174 0.021 0]'+Humerus_ghJointNode';...
    %     [Signe 'Thorax_Deltoid_i'],Pennestri2custom*[0.106 -0.024 -0.011]'+Humerus_ghJointNode';...
    %     [Signe 'Thorax_LatissimusDorsi_i'],Pennestri2custom*[0 0 -0.013]'+Humerus_ghJointNode';...
    %     [Signe 'Thorax_PectoralisMajor_i'],Pennestri2custom*[0.017 -0.013 0]'+Humerus_ghJointNode';...
    %     [Signe 'Thorax_Supraspinatus_i'],Pennestri2custom*[-0.014 0.017 0.027]'+Humerus_ghJointNode';...
    %     [Signe 'Thorax_Infraspinatus_i'],Pennestri2custom*[0.028 -0.019 0.027]'+Humerus_ghJointNode';...
    %     [Signe 'Thorax_Trapezius_i'],Pennestri2custom*[0.031 0 0.024]'+Humerus_ghJointNode';...
    %     [Signe 'Thorax_BicepsBrachii2_i'],Pennestri2custom*[0.252 0.021 0]'+Humerus_ghJointNode';...
    
    % Wraps
    %  [Signe 'Humerus_TricepsBrachii_p1'],Mirror*osim2antoine'.*([0.0028 -0.2919 -0.0119]'+[0 0.016 0]')+Humerus_ghJointNode';...
    ['Wrap' Signe 'HumerusDelt'],Mirror*osim2antoine'.*[-0.0139 -0.0127 -0.0262]'+Humerus_ghJointNode';...
    ['Wrap' Signe 'HumerusTri'],Mirror*osim2antoine'.*[0.0028 -0.2919 -0.0119]'+Humerus_ghJointNode';...
    
    
    % Muscles from Holzbaur model
    
    %     [Signe 'Humerus_Brachioradialis_o'],Mirror*osim2antoine'.*([-0.0098;-0.19963;0.00223])+Humerus_ghJointNode';...
    %     [Signe 'Humerus_TricepsLat_o'],Mirror*osim2antoine'.*([-0.00599;-0.12646;0.00428])+Humerus_ghJointNode';...
    %     [Signe 'Humerus_TricepsMed_o'],Mirror*osim2antoine'.*([-0.00838;-0.13695;-0.00906])+Humerus_ghJointNode';...
    %      [Signe 'Humerus_Anconeus_o'],Mirror*osim2antoine'.*([-0.00744;-0.28359;0.00979])+Humerus_ghJointNode';...
    %     [Signe 'Humerus_Brachialis_o'],Mirror*osim2antoine'.*([0.0068;-0.1739;-0.0036])+Humerus_ghJointNode';...
    %     [Signe 'Humerus_PronatorTeres_o'],Mirror*osim2antoine'.*([0.0036;-0.2759;-0.0365])+Humerus_ghJointNode';...
    %     [Signe 'Humerus_FlexorCarpiUlnaris_o'],Mirror*osim2antoine'.*([0.00219;-0.2774;-0.0388])+Humerus_ghJointNode';...
    %     [Signe 'Humerus_ExtensorCarpiUlnaris_o'],Mirror*osim2antoine'.*([0.00083;-0.28955;0.0188])+Humerus_ghJointNode';...
    %     [Signe 'Humerus_FlexorCarpiRadialis_o'],Mirror*osim2antoine'.*([0.00758;-0.27806;-0.03705])+Humerus_ghJointNode';...
    %     [Signe 'Humerus_PalmarisLongus_o'],Mirror*osim2antoine'.*([0.00457;-0.27519;-0.03865])+Humerus_ghJointNode';...
    %     [Signe 'Humerus_ExtensorCarpiRadialisLongus_o'],Mirror*osim2antoine'.*([-0.0073;-0.2609;0.0091])+Humerus_ghJointNode';...
    %     [Signe 'Humerus_ExtensorCarpiRadialisBrevis_o'],Mirror*osim2antoine'.*([0.01349;-0.29048;0.01698])+Humerus_ghJointNode';...
    
    % Muscles from moment arm and musculotendon length optimization
    
    [Signe 'Humerus_Brachioradialis_o'], k*Mirror*[-0.0093 ; -0.2303 ; 0.0139] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_Brachioradialis_VP1'], k*Mirror*[-0.0083 ; -0.2306 ; 0.0412] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_ExtensorCarpiRadialisLongus_o'], k*Mirror*[0.0012 ; -0.3078 ; 0.0092] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_ExtensorCarpiRadialisLongus_VP1'], k*Mirror*[0.0206 ; -0.3237 ; 0.0093] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_ExtensorCarpiRadialisBrevis_o'], k*Mirror*[0.0060 ; -0.3372 ; -0.0415] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_ExtensorCarpiRadialisBrevis_VP1'], k*Mirror*[0.0060 ; -0.3372 ; -0.0415] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_ExtensorCarpiUlnaris_o'], k*Mirror*[-0.0077 ; -0.3348 ; 0.0413] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_ExtensorCarpiUlnaris_VP1'], k*Mirror*[-0.0077 ; -0.3348 ; 0.0413] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_FlexorCarpiUlnaris_o'], k*Mirror*[0.0023 ; -0.3200 ; -0.0336] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_FlexorCarpiUlnaris_VP1'], k*Mirror*[0.0025 ; -0.3202 ; -0.0255] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_FlexorCarpiRadialis_o'], k*Mirror*[0.0075 ; -0.3206 ; -0.0365] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_FlexorCarpiRadialis_VP1'], k*Mirror*[0.0062 ; -0.3217 ; -0.0232] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_PalmarisLongus_o'], k*Mirror*[0.0054 ; -0.3172 ; -0.0441] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_PalmarisLongus_VP1'], k*Mirror*[0.0025 ; -0.3175 ; -0.0262] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_PronatorTeres_o'], k*Mirror*[0.0036 ; -0.3181 ; -0.0367] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_PronatorTeres_VP1'], k*Mirror*[0.0040 ; -0.3192 ; -0.0418] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_Anconeus_o'], k*Mirror*[-0.0158 ; -0.3286 ; 0.0005] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_Anconeus_VP1'], k*Mirror*[-0.0182 ; -0.3290 ; -0.0020] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_Brachialis_o'], k*Mirror*[0.0050 ; -0.2217 ; -0.0056] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_Brachialis_VP1'], k*Mirror*[-0.0026 ; -0.3097 ; -0.0137] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_TricepsMed_o'], k*Mirror*[-0.0110 ; -0.1764 ; -0.0091] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_TricepsMed_VP1'], k*Mirror*[-0.0305 ; -0.3124 ; -0.0092] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_TricepsLat_o'], k*Mirror*[-0.0080 ; -0.1628 ; 0.0026] + Humerus_ghJointNode' ;...
    [Signe 'Humerus_TricepsLat_VP1'], k*Mirror*[-0.0270 ; -0.3257 ; -0.0138] + Humerus_ghJointNode' ;...
    
    % Muscles from moment arm optimization
    
    [Signe 'Humerus_DeltoideusScapula_P_VP2'], k*Mirror*[-0.0050 ; -0.0912 ; 0.0066] - Humerus_ghJointNode' ;... 
    
    [Signe 'Humerus_DeltoideusScapula_M_VP2'], k*Mirror*[-0.0083 ; -0.1005 ; 0.0053]  - Humerus_ghJointNode' ;... 
    
    [Signe 'Humerus_Supraspinatus_P_VP2'], k*Mirror*[0.0108 ; 0.0096 ; 0.0213] - Humerus_ghJointNode' ;... 
    
    [Signe 'Humerus_Supraspinatus_A_VP2'], k*Mirror*[0.0199 ; 0.0176 ; 0.0111] - Humerus_ghJointNode' ;... 
    
    [Signe 'Humerus_Infraspinatus_I_VP2'], k*Mirror*[-0.0196 ; -0.0057 ; 0.0281] - Humerus_ghJointNode' ;... 
    
    [Signe 'Humerus_Infraspinatus_S_VP2'], k*Mirror*[-0.0160 ; 0.0027 ; 0.0261] - Humerus_ghJointNode' ;... 
    
    [Signe 'Humerus_Coracobrachialis_VP2'], k*Mirror*[-0.0023 ; -0.1450 ; -0.0094] - Humerus_ghJointNode' ;... 
    
    [Signe 'Humerus_TeresMajor_VP2'], k*Mirror*[0.0044 ; -0.0390 ; -0.0019] - Humerus_ghJointNode' ;... 
    
    [Signe 'Humerus_TeresMinor_VP2'], k*Mirror*[-0.0168 ; -0.0094 ; 0.0115] - Humerus_ghJointNode' ;... 

    [Signe 'Humerus_PectoralisMajorThorax_I_VP4'], k*Mirror*[0.0029 ; -0.0119 ; -0.0004]  - Humerus_ghJointNode' ;... 
        
    [Signe 'Humerus_PectoralisMajorThorax_M_VP4'], k*Mirror*[0.0020 ; -0.0103 ; -0.0013] - Humerus_ghJointNode' ;... 
        
    [Signe 'Humerus_LatissimusDorsi_S_VP4'], k*Mirror*[0.0032 ; -0.0080 ; -0.0014]- Humerus_ghJointNode' ;... 
        

    [Signe 'Humerus_LatissimusDorsi_I_VP4'], k*Mirror*[0.0033 ; -0.0174 ; -0.0015]  - Humerus_ghJointNode' ;... 
    
    [Signe 'Humerus_Subscapularis_I_VP2'], k*Mirror*[0.0117 ; -0.0034 ; -0.0208]  - Humerus_ghJointNode' ;... 

    [Signe 'Humerus_Subscapularis_M_VP2'], k*Mirror*[0.0184 ; -0.0000 ; -0.0221]  - Humerus_ghJointNode' ;... 

    [Signe 'Humerus_Subscapularis_S_VP2'], k*Mirror*[0.0187 ; -0.0002 ; -0.0128]  - Humerus_ghJointNode' ;... 

    };


%%                     Scaling inertial parameters

%% ["Adjustments to McConville et al. and Young et al. body segment inertial parameters"] R. Dumas
% ------------------------- Humerus ---------------------------------------
Length_Humerus=norm(Humerus_ghJointNode-Humerus_ElbowJointNode);
[I_Humerus]=rgyration2inertia([31 14 32 6 5 2], Mass.UpperArm_Mass, [0 0 0], Length_Humerus, Signe);

%% "Human_model" structure generation

num_solid=0;
%% Humerus
% Glenohumeral_J1           % GH plane of elevation (ISB recommandations: Wu et al. 2005)
num_solid=num_solid+1;        % number of the solid ...
name=list_solid{num_solid}; % name of the solid
eval(['incr_solid=s_' name ';'])  % number of the solid in the model
OsteoArticularModel(incr_solid).name=[Signe name];    % name of the solid ('R' or 'L' in prefix)
OsteoArticularModel(incr_solid).sister=0;                       % sister : defined as an input of the function
OsteoArticularModel(incr_solid).child=s_Glenohumeral_J2;
OsteoArticularModel(incr_solid).mother=s_mother;                       % mother : defined as an input of the function
OsteoArticularModel(incr_solid).a=[1 0 0]';                          % rotation /x
OsteoArticularModel(incr_solid).joint=1;
if Signe == 'R'
    OsteoArticularModel(incr_solid).limit_inf=-4*pi/5;                     % inferior joint biomechanical stop
    OsteoArticularModel(incr_solid).limit_sup=pi/2;                    % superior joint biomechanical stop
    OsteoArticularModel(incr_solid).FunctionalAngle='Right GH Abduction(-)/Adduction(+)';
else
    OsteoArticularModel(incr_solid).limit_inf=-pi/2;                   % inferior joint biomechanical stop
    OsteoArticularModel(incr_solid).limit_sup=4*pi/5;                      % superior joint biomechanical stop
    OsteoArticularModel(incr_solid).FunctionalAngle='Left GH Abduction(+)/Adduction(-)';
end                   		% superior joint biomechanical stop
OsteoArticularModel(incr_solid).m=0;                                 % reference mass
OsteoArticularModel(incr_solid).b=pos_attachment_pt;                 % attachment point with respect to the parent's frame
OsteoArticularModel(incr_solid).I=zeros(3,3);                        % reference inertia matrix
OsteoArticularModel(incr_solid).c=[0 0 0]';                          % center of mass location in the local frame
OsteoArticularModel(incr_solid).calib_k_constraint=[];
OsteoArticularModel(incr_solid).u=[];                          % fixed rotation with respect to u axis of theta angle
OsteoArticularModel(incr_solid).theta=[];
OsteoArticularModel(incr_solid).KinematicsCut=[];              % kinematic cut
OsteoArticularModel(incr_solid).ClosedLoop=[];                 % if this solid close a closed-loop chain : {number of solid i on which is attached this solid ; attachement point (local frame of solid i}
OsteoArticularModel(incr_solid).linear_constraint=[];
OsteoArticularModel(incr_solid).Visual=0;

% Glenohumeral_J2           % Negative GH elevation (ISB recommandations: Wu et al. 2005)
num_solid=num_solid+1;        % number of the solid ...
name=list_solid{num_solid}; % name of the solid
eval(['incr_solid=s_' name ';'])  % number of the solid in the model
OsteoArticularModel(incr_solid).name=[Signe name];
OsteoArticularModel(incr_solid).sister=0;
OsteoArticularModel(incr_solid).child=s_Humerus;
OsteoArticularModel(incr_solid).mother=s_Glenohumeral_J1;
OsteoArticularModel(incr_solid).a=[0 0 1]';
OsteoArticularModel(incr_solid).joint=1;
OsteoArticularModel(incr_solid).limit_inf=-pi/2;
OsteoArticularModel(incr_solid).limit_sup=pi;                    % superior joint biomechanical stop
OsteoArticularModel(incr_solid).FunctionalAngle='GH Flexion(+)/Extension(-)';
OsteoArticularModel(incr_solid).m=0;
OsteoArticularModel(incr_solid).b=[0 0 0]';
OsteoArticularModel(incr_solid).I=zeros(3,3);
OsteoArticularModel(incr_solid).c=[0 0 0]';
OsteoArticularModel(incr_solid).Visual=0;

% Humerus                   % GH axial rotation (ISB recommandations: Wu et al. 2005)
num_solid=num_solid+1;         % number of the solid ...
name=list_solid{num_solid}; % name of the solid
eval(['incr_solid=s_' name ';'])  % number of the solid in the model
OsteoArticularModel(incr_solid).name=[Signe name];
OsteoArticularModel(incr_solid).sister=0;
OsteoArticularModel(incr_solid).child=0;
OsteoArticularModel(incr_solid).mother=s_Glenohumeral_J2;
OsteoArticularModel(incr_solid).a=[0 1 0]';
OsteoArticularModel(incr_solid).joint=1;
if Signe == 'R'
    OsteoArticularModel(incr_solid).limit_inf=-pi;
    OsteoArticularModel(incr_solid).limit_sup=pi;                    % superior joint biomechanical stop
    OsteoArticularModel(incr_solid).FunctionalAngle='Right GH Axial rotation Internal(+)/External(-)';
else
    OsteoArticularModel(incr_solid).limit_inf=-pi;
    OsteoArticularModel(incr_solid).limit_sup=pi;                    % superior joint biomechanical stop
    OsteoArticularModel(incr_solid).FunctionalAngle='Left GH Axial rotation Internal(-)/External(+)';
end
OsteoArticularModel(incr_solid).m=Mass.UpperArm_Mass;
OsteoArticularModel(incr_solid).b=[0 0 0]';
OsteoArticularModel(incr_solid).I=[I_Humerus(1) I_Humerus(4) I_Humerus(5); I_Humerus(4) I_Humerus(2) I_Humerus(6); I_Humerus(5) I_Humerus(6) I_Humerus(3)];
OsteoArticularModel(incr_solid).c=-Humerus_ghJointNode';
OsteoArticularModel(incr_solid).anat_position=Humerus_position_set;
OsteoArticularModel(incr_solid).Visual=1;
OsteoArticularModel(incr_solid).visual_file = ['Holzbaur/humerus_' Signe '.mat'];
OsteoArticularModel(incr_solid).L={[Signe 'Humerus_ghJointNode'];[Signe 'Humerus_ElbowJointNode']};
OsteoArticularModel(incr_solid).density=1.07; %kg.L-1


% Wrapping 1
% OsteoArticularModel(incr_solid).wrap(1).name=['Wrap' Signe 'HumerusDelt'];
% OsteoArticularModel(incr_solid).wrap(1).anat_position=['Wrap' Signe 'HumerusDelt'];
% OsteoArticularModel(incr_solid).wrap(1).type='C'; % C: Cylinder or S: Sphere
% OsteoArticularModel(incr_solid).wrap(1).R=k*0.05;
% OsteoArticularModel(incr_solid).wrap(1).orientation=[ 0.4515   -0.2896    0.8440;
%     0.5805    0.8136   -0.0313;
%     -0.6776    0.5041    0.5355];
% OsteoArticularModel(incr_solid).wrap(1).location=Mirror*osim2antoine'.*[-0.0139 -0.0127 -0.0262]'+Humerus_ghJointNode';
% OsteoArticularModel(incr_solid).wrap(1).h=k*0.1;
% OsteoArticularModel(incr_solid).wrap(1).num_solid=incr_solid;

% Wrapping 2
% OsteoArticularModel(incr_solid).wrap(2).name=['Wrap' Signe 'HumerusTri'];
% OsteoArticularModel(incr_solid).wrap(2).anat_position=['Wrap' Signe 'HumerusTri'];
% OsteoArticularModel(incr_solid).wrap(2).type='C'; % C: Cylinder or S: Sphere
% OsteoArticularModel(incr_solid).wrap(2).radius=k*0.016;
% OsteoArticularModel(incr_solid).wrap(2).R=[ 0.9576    0.0114   -0.2878;
%     -0.0200    0.9994   -0.0268;
%     0.2873    0.0314    0.9573];
% OsteoArticularModel(incr_solid).wrap(2).location=Mirror*osim2antoine'.*[0.0028 -0.2919 -0.0119]'+Humerus_ghJointNode';
% OsteoArticularModel(incr_solid).wrap(2).h=k*0.1;
% OsteoArticularModel(incr_solid).wrap(2).num_solid=incr_solid;

% Wrapping Lat
% OsteoArticularModel(incr_solid).wrap(3).name=['Wrap' Signe 'HumerusLat'];
% OsteoArticularModel(incr_solid).wrap(3).anat_position=['Wrap' Signe 'HumerusLat'];
% OsteoArticularModel(incr_solid).wrap(3).type='S'; % C: Cylinder or S: Sphere
% OsteoArticularModel(incr_solid).wrap(3).radius=k*0.03;
% OsteoArticularModel(incr_solid).wrap(3).R=[ 0.9619    -0.0190    (-1)^Signe_bool*0.2726;
%                                             -0.0150    0.9924    (-1)^Signe_bool*0.1221;
%                                             (-1)^Signe_bool*-0.2729   (-1)^Signe_bool*-0.1215    0.9543];
% OsteoArticularModel(incr_solid).wrap(3).location=Mirror*osim2antoine'.*[-0.0016 0.0092 0.0052]'+Humerus_ghJointNode';
% OsteoArticularModel(incr_solid).wrap(3).h=0;
% OsteoArticularModel(incr_solid).wrap(3).num_solid=incr_solid;






cell = varargin{1};

if ~isempty(cell) && strcmp(func2str(cell{1}),'UpperTrunkClavicle')
    
    %% RScapula
    % Scapula_J1
    incr_solid = find(strcmp({OsteoArticularModel.name},[Signe 'Scapula_J1']));
    
    if ~isempty(incr_solid)
        % Dependancy
        OsteoArticularModel(incr_solid).kinematic_dependancy.active=1;
        OsteoArticularModel(incr_solid).kinematic_dependancy.Joint=s_Glenohumeral_J2;
        % Kinematic dependancy function
        syms Hz
        f_z = matlabFunction((1-2*Signe_bool)*(27.939*pi/180+0.088*Hz));
        OsteoArticularModel(incr_solid).kinematic_dependancy.q=f_z;
        
        % Scapula_J2
        incr_solid = find(strcmp({OsteoArticularModel.name},[Signe 'Scapula_J2']));
        % Dependancy
        OsteoArticularModel(incr_solid).kinematic_dependancy.active=1;
        OsteoArticularModel(incr_solid).kinematic_dependancy.Joint=s_Glenohumeral_J2; % Thoracicellips
        % Kinematic dependancy function
        f_x = matlabFunction(-6.970*pi/180+0.220*Hz);
        OsteoArticularModel(incr_solid).kinematic_dependancy.q=f_x;
        %
        % Scapula
        incr_solid = find(strcmp({OsteoArticularModel.name},[Signe 'Scapula']));
        % Dependancy
        OsteoArticularModel(incr_solid).kinematic_dependancy.active=1;
        OsteoArticularModel(incr_solid).kinematic_dependancy.Joint=s_Glenohumeral_J2; % Thoracicellips
        % Kinematic dependancy function
        f_y = matlabFunction(-4.884*pi/180+0.145*Hz);
        OsteoArticularModel(incr_solid).kinematic_dependancy.q=f_y;
    end
    
end




end