clear all
close all
%% Entrée
rep_entree = uigetdir('','Selectionner le dossier où les données à traiter sont stockées'); %Dossier contenant les dossiers pour chaque subject après pré-traitement (DonneesTraitees)
cd(rep_entree)
path_prot = uigetfile('.protOS','Selectionner le fichier prot.OS du modèle de marqueurs');
reserved_dir_without_info_global = {'.','..','.DS_Store','info_global','Info_global','Info_Global','modele','fichiers_wrl','Statique','MvtsFonctionnels','resultats_globaux','Events'} ; % pour enlever les dossiers fantômes .,..,DS_store (mac)
list_subject = dir(rep_entree);
list_subject = { list_subject.name };
list_subject( contains( list_subject,reserved_dir_without_info_global ) ) = [];

for i_subject = 1:length(list_subject)
    cur_subject = char(list_subject(i_subject));

    rep_sortie = [rep_entree cur_subject];
    list_activity=dir(fullfile(rep_entree,cur_subject));

    list_activity = {list_activity.name};
    list_activity( contains (list_activity,reserved_dir_without_info_global))=[];
    for i_activity=1:length(list_activity)
        cur_activity=list_activity{i_activity};
        %___ Getting the files to preprocess
        rep_files = fullfile(rep_entree,cur_subject,cur_activity) ;
        [~,list_c3d] = PathContent_Type( rep_files ,'.c3d');
        [~,list_mat] = PathContent_Type( rep_files,'.mat');
        nb_acquisition=length(list_c3d);
        %___ Cropping the files if necessary
        %%

        for i_c3d = 1:length(list_c3d)
            %On affiche dans la commande l'acq traitée
            disp([list_c3d{i_c3d},' : début'])

            %On ouvre le fichier d'acquisition
            h = fullfile(cur_subject,cur_activity,list_c3d{i_c3d});

            [VICON_cine,~] = recuperation_c3d(h); % extraction données c3d
            [st_marqueurs_cine] = NettoieMarkerLabels(VICON_cine.Marqueurs); % enlève les marqueurs sans label %version parafencing NettoieMarkerLabels_Parafencing

            if ~isempty(st_marqueurs_cine)

                [st_marqueurs_cine] = zero2NaN(st_marqueurs_cine); % transforme les [0 0 0] en NaN

                Marqueurs = fieldnames(st_marqueurs_cine);


                st_marqueurs_cine = improve_kinematic_data(st_marqueurs_cine, lire_fichier_prot_2(path_prot));
            end
            s = char(list_c3d{i_c3d});
            btk_write_markers_in_c3d(h, st_marqueurs_cine, h);%,'units','mm','subject_name','SV01AR')
            clear st_marqueurs_cine VICON_cine
            disp([list_c3d{i_c3d},' : fin'])
        end
    end
end




