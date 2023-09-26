function [new_data,index_nan] = decoupe_data_avec_nan(donnees)

% Objectif:
%   Découper les données en structure de points continues, sans NaN

%   !!! on suppose que si la première colonne est NaN, les autres colonnes le
%   seront !!!

% En entrée :
%   donnees : données à traiter : n lignes (où seront détectées les NaN), m colonnes

% En sortie :
%   new_data :
%       .data : structure de matrices exemptes de NaN de points continus, j lignes et m
%   colonnes
%       .index: début et fin de la structure


ind_nan = find(isnan(donnees(:,1)));
saut_nan = ind_nan(2:end) - ind_nan(1:end-1)-1 ;

idata = 1;
new_data(1).data = [];
new_data(1).index= [];

if isempty(ind_nan)
    new_data(1).data = donnees;
    new_data(1).index = [1,size(donnees,1)];
    index_nan = []; % *** la liste des index nan est vide
else
    % sauts intermédiaires des nan
    ind_saut_nan = find (saut_nan);

    % initiation du 1er elt data : si la premiere donnee n'est pas nan
    if ind_nan(1) > 1
        new_data(idata).data = donnees( 1:ind_nan(1)-1,: ) ;
        new_data(idata).index = [1, ind_nan(1)-1 ];
        idata = idata+1;
    end

    % *** initialisation  et  remplissagede la série des index nan
    if isempty(ind_saut_nan) % *** s'il n'y a qu'une série de nan
        index_nan(1).index = ind_nan(1):ind_nan(end) ;
    else
        index_nan(1).index = ind_nan(1):ind_nan(ind_saut_nan(1)) ;
        for isautnan = 1:length( ind_saut_nan )-1
            index_nan(isautnan+1).index = ind_nan(ind_saut_nan(isautnan)+1):ind_nan(ind_saut_nan(isautnan+1));
        end
        index_nan(end+1).index = ind_nan( ind_saut_nan(end)+1:end ) ;
    end

    % **** remplissage des données non nan : itération sur les sauts nan
    for isaut = 1:length( ind_saut_nan )
        new_data(idata).data = donnees( ind_nan(ind_saut_nan(isaut))+1:ind_nan( ind_saut_nan(isaut)+1 )-1 , :);
        new_data(idata).index = [ind_nan(ind_saut_nan(isaut))+1, ind_nan( ind_saut_nan(isaut)+1 )-1 ];
        idata = idata + 1 ;
    end


    % final data
    if ind_nan(end)<length(donnees)
        new_data(idata).data = donnees( ind_nan(end)+1:end , : );
        new_data(idata).index = [ind_nan(end)+1, length(donnees) ];
    end
end