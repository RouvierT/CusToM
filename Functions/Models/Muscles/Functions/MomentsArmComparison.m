function RMSE=MomentsArmComparison(BiomechanicalModel,num_muscle,MARegression, nb_points,involved_solids,num_markersprov)
% Root mean square difference between input moment arm and moment arm from the model 
%
%   INPUT
%   - BiomechanicalModel: musculoskeletal model
%   - num_muscle : number of the muscle in the Muscles structure
%   - MARegression : structure of moment arm 
%   - nb_points : number of point for coordinates discretization
%   - involved_solids : vector of solids of origin, via, and insertion points 
%   - num_markersprov : vector of anatomical positions of origin, via, and insertion points 
%
%   OUTPUT
%   - RMSE : root mean square difference
%________________________________________________________
%
% Licence
% Toolbox distributed under GPL 3.0 Licence
%________________________________________________________
%
% Authors : Antoine Muller, Charles Pontonnier, Pierre Puchaud and
% Georges Dumont
%________________________________________________________

num_solid=involved_solids(2:end-1);
num_markers=num_markersprov(2:end-1);

Nb_q=numel(BiomechanicalModel.OsteoArticularModel)-6*(~isempty(intersect({BiomechanicalModel.OsteoArticularModel.name},'root0')));

[sp1,sp2]=find_solid_path(BiomechanicalModel.OsteoArticularModel,involved_solids(1),involved_solids(end));
path = unique([sp1,sp2]);
FunctionalAnglesofInterest = {BiomechanicalModel.OsteoArticularModel(path).FunctionalAngle};

mac=[];

ideal_curve=[];
liste_noms=[];
for j=1:size(MARegression,2)
    mactemp=[];
    rangeq=zeros(nb_points,size(MARegression(j).joints,2));
    ideal_curve_temp=[];
    q=zeros(Nb_q,nb_points^size(MARegression(j).joints,2));
    
    map_q=zeros(nb_points^size(MARegression(j).joints,2),size(MARegression(j).joints,2));
    
    for k=1:size(MARegression(j).joints,2)
        joint_name=MARegression(j).joints{k};
        [~,joint_num]=intersect(FunctionalAnglesofInterest, joint_name);
        joint_num=path(joint_num);
        rangeq(:,k)=linspace(BiomechanicalModel.OsteoArticularModel(joint_num).limit_inf,BiomechanicalModel.OsteoArticularModel(joint_num).limit_sup,nb_points)';
        liste_noms=[liste_noms joint_name];
        
        B1=repmat(rangeq(:,k),1,nb_points^(k-1));
        B1=B1';
        B1=B1(:)';
        B2=repmat(B1,1,nb_points^(size(MARegression(j).joints,2)-k));
        map_q(:,k) = B2;
        q(joint_num,:) = B2;
    end
    
    c = ['equation',MARegression(j).equation] ;
    fh = str2func(c);
    ideal_curve_temp=[ideal_curve_temp fh(MARegression(j).coeffs,map_q)];
    

    joint_name=MARegression(j).axe;
    [~,joint_num]=intersect(FunctionalAnglesofInterest,joint_name);
    joint_num=path(joint_num);
    
    parfor i=1:nb_points^size(MARegression(j).joints,2)
        mactemp  = [mactemp MomentArmsComputationNumMuscleJoint(BiomechanicalModel,q(:,i),0.0001,num_muscle,joint_num)];
    end
    
    
    ideal_curve=[ideal_curve ideal_curve_temp];
    
    mac=[mac mactemp];
    
    
end


RMSE.rms=  sqrt(1/length(mac) * sum((ideal_curve - mac).^2));
RMSE.rmsr=  sqrt(1/length(mac) * sum((ideal_curve - mac).^2))/ sqrt(1/length(mac) * sum((ideal_curve).^2))* 100;



end