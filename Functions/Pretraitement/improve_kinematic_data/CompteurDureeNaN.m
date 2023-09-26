function [ front_montant,front_descendant,duree ] = CompteurDureeNaN( V )

% V est un vecteur contenant des NaN
% l'objectif est de les compter 

% duree est la nombre de NaN successifs, indiqué au moment de la mise à 1

nan_V=isnan(V);
non_nan_V=~isnan(V);

front_montant=zeros(size(V,1),1);
front_descendant=zeros(size(V,1),1);
duree=zeros(size(V,1),1);
compteur=0;
for i=1:size(V,1)-1
    test=nan_V(i+1)-nan_V(i);
    if test>0
        front_montant(i+1)=1;
        compteur=compteur+1;
    elseif test<0
        duree(i-compteur+1)=compteur;
        front_descendant(i+1)=1;
        compteur=0;
    end
    
end


end

