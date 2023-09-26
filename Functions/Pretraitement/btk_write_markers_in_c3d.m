function []  = btk_write_markers_in_c3d(fullpathTemplateFile, structureNouveauMarkers, nouveauNom, varargin)
% infos

%btk_write_markers_in_c3d : fonction permettant à partir d'un fichier c3d
%servant de template de rentrer des données issus d'un .mat

% Inputs :
% - file template  = pathname et file name tout concatenés type
% fullfile(..)


% - structure_nouveau_markers = structure avec type struct.mark = coord

% - nouveau_nom = nom du fichier créé à partir du template et de la struct

% - varargin :
%* units = si besoin de changer l'unité par rapport au template
%* subject_name = sidem avec nom sujet

% Ouputs :
%* creation d'un fichier c3d avec marquerus et meta données modifiés
% /!\ pour le moment ne prend pas en compte les plateformes


%
% auteur = Antoine RAUD
% version pour parafencing, Janvier 2023
% tourne avec Matlab2022a


% Prérequis : toolbox btk et droits associés

%% DEBUT CODE

%on load le c3d
[ hOriginal, ~ , ~ ] = btkReadAcquisition( fullpathTemplateFile ) ;
meta = btkGetMetaData(hOriginal);
%parcing des inputs

defaultUnits = btkGetPointsUnit(hOriginal,'marker');
% infoname = meta.children.SUBJECTS.children.NAMES.info.values(1);
% defaultName = infoname{1};

p = inputParser;
addRequired(p,'fullpath_template');%validScalarPosNum);
addRequired(p,'structure_nouveau_markers');
addRequired(p,'nouveau_nom');
addParameter(p,'units',defaultUnits);%,@isstring);
% addParameter(p,'subject_name',defaultName);%,@isstring);

parse(p,fullpathTemplateFile, structureNouveauMarkers, nouveauNom,varargin{:});


%on change l'unité,

btkSetPointsUnit(hOriginal, 'marker', p.Results.units)

% le nom du sujet

% btkSetMetaDataValue(hOriginal, 'SUBJECTS','NAMES', 1, p.Results.subject_name)



%on supprime les anciens points

btkClearPoints(hOriginal);


%on rajoute tous les nouveaux
%avec le bon nombre de frame
marqueursNoms = fieldnames(structureNouveauMarkers);
marqueurPremier  = structureNouveauMarkers.(marqueursNoms{1});
nombreframe = length(marqueurPremier(:,1));

btkSetFrameNumber(hOriginal, nombreframe);

for marqueurNum=1:length(marqueursNoms)

    marqueurCoord = structureNouveauMarkers.(marqueursNoms{marqueurNum});
    marqueurType = 'marker';
    marqueurNom= char(marqueursNoms{marqueurNum});
    [points, pointsInfo] = btkAppendPoint(hOriginal,marqueurType,marqueurNom,marqueurCoord);

end

btkWriteAcquisition(hOriginal, nouveauNom)
btkCloseAcquisition(hOriginal)

