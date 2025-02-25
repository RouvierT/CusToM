function [protocole] = lire_fichier_prot_2(fichier_prot)

% Version:     9.2 (2007)
% Langage:     Matlab    Version: 7.5
% Plate-forme: PC 

% Auteurs : H. Goujon X. Bonnet
% Date de cr�ation : 06-04-07

% Cr�� dans le cadre de : Th�se
% Professeur responsable : F. Lavaste
% Revision 2010-05-18: J.Bascou: ajout du nom du fichier en argument
% Revision 2023-09-26 : T. Rouvier: modification des param�tres d'entr�es
% et suppression du comportement nocif du programme (cd)
%_________________________________________________________________________
% Laboratoire de Biom�canique LBM
% ENSAM C.E.R. de PARIS                          email: lbm@paris.ensam.fr
% 151, bld de l'H�pital                          tel:   01.44.24.63.63
% 75013 PARIS                                    fax:   01.44.24.63.66
%__________________________________________________________________________
% Toutes copies ou diffusions de cette fonction ne peut �tre r�alis�e sans
% l'accord du LBM
%__________________________________________________________________________
% Version:     9.1 (2006)  
% Description de la fonction : lit le fichier de protocole (.prot)
%__________________________________________________________________________
% Param�tres d'entr�e  : 
%   - fichier_prot: nom et chemin d'acc�s du fichier protocole
%
% Param�tres de sortie : 
%   - protocole : structure dont els champs sont d�finis dans le fichier prot
%___________________________________________________________________________
%

nom_fichier = fichier_prot;

%% ouverture du fichier
fid=fopen(nom_fichier,'r');
comp = 1;
if fid == -1
    errordlg(['impossible d''ouvrir le fichier' nom_fichier])
    return
    %     fclose(fid)
%     return;
end;


%% Recherche des listes de marqueurs
while ~feof(fid)
    ligne=fgetl(fid);
    %*** it�ration jusqu a trouver un entete (signe '#')
    while (isempty(strfind(ligne,'#')) || ~isempty( strfind(ligne,'##') ) ) && ~feof(fid)
        ligne=fgetl(fid);
    end;
    if ~feof(fid)
%     if isempty( strfind(ligne,'##') ) % *** verif si champ non annul�
%     (deux signes '##')
        champ = strrep(ligne,'#',''); % **** d�claration d un entete
        [protocole.(champ)] = lire_fichier_prot_args(fid); % **** remplissage de toutes les donnees de l entete
    end
end;
fclose(fid);
