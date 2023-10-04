function st_marqueurs_cine = improve_kinematic_data(st_marqueurs_cine,st_protocole_pretraitement,type_filtre,frequence_vicon,crop_inf,crop_sup)

Marqueurs = fieldnames(st_marqueurs_cine);

%0. Filtrage
if nargin > 2
    %filtrage par fenêtre glissante par residual analysis
    if strcmp(type_filtre,'FA')
        st_marqueurs_cine = filtre_adaptatif(st_marqueurs_cine,2,frequence_vicon); %filtre de BW d'ordre 2
    %filtrage par moyenne glissante
    else
        n_mg = 5;
        for i_marqueur = 1:size(Marqueurs,1)
            Data = st_marqueurs_cine.(Marqueurs{i_marqueur});
            for i_col = 1:3
                Data(:,i_col)=fct_moyenne_glissante(Data(:,i_col),n_mg);
                st_marqueurs_cine.(Marqueurs{i_marqueur}) = Data ;
            end
        end
    end 
else
    n_mg = 5;
    for i_marqueur = 1:size(Marqueurs,1)
        Data = st_marqueurs_cine.(Marqueurs{i_marqueur});
        for i_col = 1:3
            Data(:,i_col)=fct_moyenne_glissante(Data(:,i_col),n_mg);
        end
        st_marqueurs_cine.(Marqueurs{i_marqueur}) = Data ;
    end
end
%1. interpolation si petit trous et filtrage
taille_trou = 15;
nb_min_points = round( taille_trou/2);
n_mg=5;

for i_marqueur = 1:size(Marqueurs,1)
    Data = st_marqueurs_cine.(Marqueurs{i_marqueur});
    Data_output = bouche_petits_trous_coord3D(Data,n_mg,taille_trou,nb_min_points);
    st_marqueurs_cine.(Marqueurs{i_marqueur}) = Data_output;
end

% 2. Recalage rigide si gros trous

list_seg=fieldnames(st_protocole_pretraitement.SEGMENTS);
nb_seg=size(list_seg,1);

for i_seg=1:nb_seg
    try
        cur_seg=list_seg{i_seg};
        Marqueurs_Segment=st_protocole_pretraitement.SEGMENTS.(cur_seg);
        st_marqueurs_cine = recalage_rigide_grands_trous(st_marqueurs_cine,Marqueurs_Segment);
    catch
        disp(['!!! Erreur recalage rigide pour ',cur_seg,', marqueurs manquants dans le c3d !!!'])
    end


end

% 3. Re interpolation si petits trous

for i_marqueur = 1:size(Marqueurs,1)
    Data = st_marqueurs_cine.(Marqueurs{i_marqueur});
    Data_output = bouche_petits_trous_coord3D(Data,n_mg,taille_trou,nb_min_points);
    st_marqueurs_cine.(Marqueurs{i_marqueur}) = Data_output;
end

% % 4. Extrapolation sur les bords
% 
% for i_marqueur = 1:size(Marqueurs,1)
%     st_marqueurs_cine.(Marqueurs{i_marqueur}) = extrapolation_petits_trous_bords(st_marqueurs_cine.(Marqueurs{i_marqueur}),taille_trou);
% end

% 5. On enlève les marqueurs où il reste des NaN
% ratio_NaN=0.3;
% [st_marqueurs_cine,~]=Nettoiemark(st_marqueurs_cine,ratio_NaN);

end
