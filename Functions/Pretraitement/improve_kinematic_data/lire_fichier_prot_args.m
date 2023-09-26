function [liste_noms] = lire_fichier_prot_args(fid)


% Version:     9.2 (2007)
% Langage:     Matlab    Version: 7.0
% Plate-forme: PC 

% Auteurs : H. Goujon X. Bonnet
% Date de création : 06-04-07
% Créé dans le cadre de : Thèse
% Professeur responsable : F. Lavaste
%_________________________________________________________________________
% Laboratoire de Biomécanique LBM
% ENSAM C.E.R. de PARIS                          email: lbm@paris.ensam.fr
% 151, bld de l'Hôpital                          tel:   01.44.24.63.63
% 75013 PARIS                                    fax:   01.44.24.63.66
%_________________________________________________________________________
% Toutes copies ou diffusions de cette fonction ne peut être réalisée sans
% l'accord du LBM
%__________________________________________________________________________
% Description de la fonction : lit un bloc de ligne délimité par une ligne
% vide en prenant les intitulés à droite du signe egal et les arguments associés
% séparés par une virgule à gauche du signe égal
%__________________________________________________________________________
% Paramètres d'entrée  : 
%   - fid : ientifiant fichier
%
% Paramètres de sortie : 
%   - liste_noms : structure avec des champs correspondant
% à la liste intitulé
%___________________________________________________________________________

liste_noms=[];
ligne=fgetl(fid); % *** rm: nous sommes a une ligne specifique du fichier

while ~isempty(ligne)
    % *** récupération de l intitule
    [label,list_arg] = strtok(ligne,'=');
    compt=1; % *** compteur utilisé pour le remplissage de la structure résultat
    
    % *** boucle de remplissage des arguments dans la variable résultat
    while ~isempty(list_arg)
        [nom_arg,list_arg]=strtok(list_arg,'=,'); % *** séparation du premier argument de la liste
        liste_noms.(label){compt}=nom_arg; % *** insertion de cet argument dans la structure résultat
        compt=compt+1;
    end;
    
    % *** détection de fin ou passage a une nouvelle ligne
    if feof(fid)
        break;
    else
        ligne=fgetl(fid); 
    end;
end;