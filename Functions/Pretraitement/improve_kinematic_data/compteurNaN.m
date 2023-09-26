function [ N_NaN ] = compteurNaN( A )
% Fonction permettant de compter le nombre de NaN d'une matrice.

N_NaN=length(find(isnan(A)));

end

