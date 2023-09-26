function [Registered_Data] = fct_recalage(Cluster_Reference,Cluster_to_register,Data_to_register)
%% 
% Input : Cluster_Reference :  Cluster référence sur lequel se recaler (R1)  [Xp1,Yp1,Zp1 ; Xp2,Yp2,Zp2; ...]
%         Cluster_to_register : Cluster à recaler (R2) [X,Y,Z]
%         Data_to_register : Donnée à recaler [X,Y,Z] (connue dans R2 et voulue dans R1) (Data_to_register peut être de taille différente de Cluster_R1 - par exemple : recalage de 12 marqueurs et la transformation définie à partir de 5) 
%
% Output : Registered_Data : Données exprimées dans R2 [X,Y,Z]
%%
[~,Transformation] = Recalage_svd(Cluster_Reference,Cluster_to_register);
MH_R1R2 = [Transformation.MR2R1',Transformation.translation;0,0,0,1];
Registered_Data = MH_R1R2 * [Data_to_register,ones(size(Data_to_register,1),1)]';
Registered_Data = Registered_Data(1:3,:)';
end