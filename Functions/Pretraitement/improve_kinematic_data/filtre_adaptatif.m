function filtered_data=filtre_adaptatif(st_marqueurs_cine,BW_order,fs)

%##########################################################################
%Camille EYSSARTIER
%05/2020
%c3d_file: fichier c3d. Vicon
%BW_order:ordre du filtre de Butterworth
%##########################################################################

disp('Le filtrage des données .c3d par residual analysis et fenêtre glissante commence.');
Marqueurs = fieldnames(st_marqueurs_cine);

%Détermination de la taille de la fenêtre pour l'analyse des résidus
%Sur la base d'une fenêtre de 33 frames pour un signal à 200Hz
b=round(33*fs/200);
a=b-1;
c=b+1;
if rem(a,3)==0
    window_size=a;
    elseif rem(b,3)==0
        window_size=b;
    elseif rem(c,3)==0
        window_size=c;
end

%Filtrage par analyse des résidus par fenêtre glissante
nb_frame=crop_sup-crop_inf+1 ;
time=(1:nb_frame);

filtered_data=struct;
max_COF=40; %borne max de COF pour l'analyse des résidus
for i_marqueur =1:size(Marqueurs,1)
    disp(Marqueurs{i_marqueur});

    data = st_marqueurs_cine.(Marqueurs{i_marqueur});

    Data_output=NaN(length(data),3);
    %results_COF=[];%si on veut la ploter
    for i_axe= 1:3 %boucle sur les axes x,y et z
        [Data_output(:,i_axe)]=filtrage_fenetre_glissante(data(:,i_axe),time,fs,BW_order,window_size,max_COF,Marqueurs{i_marqueur},i_axe);
        
        %[Data_output(:,i_axe),results_COF(:,i_axe)]=filtrage_fenetre_glissante(data(:,i_axe),time,fs,BW_order,window_size,max_COF,i_axe);
        %%si on veut ploter
        %on plot: 
%         figure(i_axe+3);
%         tiledlayout(2,1);
%         
%         if i_axe==1
%             axe='X';
%         elseif i_axe==2
%             axe='Y';
%         else 
%             axe='Z';
%         end
%         
%         data_to_plot=data;
%         data_to_plot(isnan(data))=0;
%         
%         ax1 = nexttile;
%         plot(ax1,time,data_to_plot(:,i_axe),'red',time,Data_output(:,i_axe),'blue',time, fct_moyenne_glissante(data(:,i_axe),5),'black');  
%         title(ax1,sprintf("Coord. %s vs frames",axe));
% 
%         ax2 = nexttile;
%         abs_COF=(1:(1/3)*window_size:(length(results_COF(:,i_axe)))*(1/3)*window_size);
%         plot(ax2,abs_COF,results_COF(:,i_axe),'*');
%         title(ax1,sprintf("Optimal COF %s vs frames",axe));
    end
    %on ajoute les données avant et après crop_inf et crop_sup
    filtered_data.(Marqueurs{i_marqueur})=[Data_output];

end
disp('Fin du filtrage');
end