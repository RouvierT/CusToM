% Entrées : 
% Ref : nuage de points de référence
% Rec : nuage de points à recaler
%
% Sorties :
% NRec : nouvelles coordonnées pour les points recalés
% Transformation : transformation de Rec(initial) vers Ref(final)
%      .translation : translation des points de Rec vers Ref
%      .MR2R1 : matrice de passage de Rec vers Ref
%      on tend vers : Transformation(Rec) = Ref
%                     R*Rec + T = Ref
% Info : Information sur le changement de base
%      .vecteur : vecteur directeur de l'axe de rotation
%      .angle :   angle de rotation autour de l'axe en rad
%
%
% References:     Soderkvist I. and Wedin P. -A., (1993). Determining the
%                 movements of the skeleton using well-configured markers.
%                 Journal of Biomechanics, 26:1473-1477      
%
% Author:	Christoph Reinschmidt, HPL, The University of Calgary
%               (Matlab code adapted from Ron Jacobs, 1993)
% Date:		February, 1995
% Last Changes: December 09, 1996
% Version:      3.1
% _____________________________________________________________________

function [NRec,Transformation] = Recalage_svd(Ref,Rec);

% Checking for NaNs and also checking if still 3 pts left and if not
% T=[NaN...];
cut=[0];

qrec=isnan(Rec); 
qref=isnan(Ref);
qtout=[qrec,qref];

qsum=sum(qtout');
cut=find(qsum~=0);

Rec([cut],:)=[]; 
Ref([cut],:)=[];
if size(Rec,1)<3,
    Transformation.MR2R1=[NaN,NaN,NaN;NaN,NaN,NaN;NaN,NaN,NaN];
    Transformation.translation=[NaN;NaN;NaN];
    return;
end

Rec_mean=mean(Rec);
Ref_mean=mean(Ref);
for i=1:size(Rec,1)-size(cut,2),  
    Rec_i(:,i)=[Rec(i,:)-Rec_mean]';
    Ref_i(:,i)=[Ref(i,:)-Ref_mean]';
end

C=Ref_i*Rec_i';
% Decomposition en valeurs singulières :
[P,T,Q]=svd(C);
Transformation.MR2R1=(P*diag([1 1 det(P*Q')])*Q')';
Transformation.translation=(Ref_mean-Rec_mean*Transformation.MR2R1)';

% On deplace le nuage Rec :
for i=1:size(Rec,1);
    NRec(i,:)=Transformation.translation' + Rec(i,:)*Transformation.MR2R1;
end

% 