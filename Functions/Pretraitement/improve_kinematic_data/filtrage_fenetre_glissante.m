function [filtered_data]=filtrage_fenetre_glissante(data,time,fs,BW_order,window,max_COF,marqueur,i_axe)
%##################################################################################################
%Camille EYSSARTIER
%05/2020
%data: data à filtrer, vecteur colonne, n lignes = n frames, ex: marqueur MAN, direction x
%time: vecteur frames
%fs: fréquence d'acquisition du signal
%BW_order:ordre du filtre de Butterworth
%window: taille de la fenêtre glissante
%max_COF: borne max des fréquences à tester pour l'analyse des résidus
%##################################################################################################

nb_frame=length(time);

%% Evaluation du nombre d'évaluations des fréquences optimales
nb_window=nb_frame/window;
if nb_window==ceil(nb_window)
    nb_eval=nb_window*3-2;
else
    reste=nb_frame-(ceil(nb_window)-1)*window;
    nb_eval_reste=ceil(reste/(window/3));
    nb_eval=(ceil(nb_window)-1)*3-2+nb_eval_reste;
end

%% On bouche les trous (les trous seront "replacés" ensuite)
data_filled = fillmissing(data,'spline');

%si il reste des NaN on  ne peut pas procéder à la recheche de la fréquence optimale de coupure 
%on ne filtre pas et on le signal
if any(isnan(data_filled))
    filtered_data= data;
    if i_axe==1
        axe='X';
    elseif i_axe==2
        axe='Y';
    else 
        axe='Z';
    end
    fprintf("Les donnees .c3d du marqueur %s axe %s (repère OS) n'ont pas pu être filtrer, cause: trop de NaN dans le signal.",marqueur,axe);
    return
end


%% Evaluation des best COF: déplacement de fenêtre 1/3 par 1/3
list_optim_COF=NaN(1,nb_eval);
start_frame=1;
end_frame=window; 
i_eval=1;
while i_eval<=nb_eval

    if end_frame > nb_frame
        end_frame = nb_frame;
    end

    %Analyse spectrale par FFT 
    [frequ_FFT,pks_PSD]=spectral_analysis(data_filled(start_frame:end_frame),fs);

    [~,direction]=sort(pks_PSD,'descend');
    frequ_FFT_sorted=frequ_FFT(direction);%vecteurs des fréqu. pcpales ordonnés par importance décroissante

    main_frequ_1=frequ_FFT_sorted(1); %on considère les deux fréquences les plus importantes
    main_frequ_2=frequ_FFT_sorted(2);

    if main_frequ_2 < main_frequ_1 %on veut main_frequ_1 < main_frequ_2
        [main_frequ_1,main_frequ_2]=deal(main_frequ_2,main_frequ_1);
    end

    first_frequ=(0.98^2/(1-0.98^2))^(0.5/BW_order)*main_frequ_1; %0.98 de rep en ampl à la frequ pcpale
    second_frequ=(0.98^2/(1-0.98^2))^(0.5/BW_order)*main_frequ_2; %0.98 de rep en ampl à second frequ pcpale

    %Spectre de fréquences à tester pour le filtrage par analyse des résidus : vecteur COF
    i_frequ=first_frequ;
    COF=[i_frequ];
    while i_frequ < max_COF
        i_frequ=1.2*i_frequ;
        COF=[COF,i_frequ];
    end

    %Evaluation de la meilleure fréquence de coupure
    if length(COF) > 2 
    
    optim_COF=evaluation_best_COF(data(start_frame:end_frame),data_filled(start_frame:end_frame),fs,first_frequ,second_frequ,COF,BW_order);    
    %cas où on plot     
    %[optim_COF,COF,residuals,interpol_COF,interpol_residuals,tangent_hf,tangent_bf,x_intersect,y_intersect]=evaluation_best_COF(data(start_frame:end_frame),data_filled(start_frame:end_frame),fs,first_frequ,second_frequ,COF,BW_order);
       
        %on plot: A SUPPRIMER
%         figure(i_axe)
%         subplot(ceil(nb_eval/4),4,i_eval);
%         yyaxis left
%         bar(frequ_FFT,pks_PSD,0.2,'r');
%         yyaxis right
%         plot(interpol_COF,interpol_residuals,'blue',COF,residuals,'+blue',interpol_COF,tangent_hf,':r',interpol_COF(1:150),tangent_bf(1:150),':m',x_intersect,y_intersect,'*green');
%         title(sprintf("Frame %d à frame %d",start_frame,end_frame),'FontWeight','normal');

    else %si COF contient seulement 2 ou 1 fréquences car la fréquence principale est très élevée
        optim_COF = NaN; %on ne peut pas faire l'analyse des résidus
    end
    list_optim_COF(i_eval)=optim_COF;

    %On avance d'1/3 de fenêtre
    start_frame=start_frame+ (1/3)*window;
    end_frame=end_frame+ (1/3)*window; 
    i_eval=i_eval+1;
end

%% Détermination des fréquences auxquelles on va filtrer
results_COF=NaN(1,nb_eval);%liste des COF utilisées pour filtrer les data
if ~isnan(list_optim_COF(1))
    results_COF(1)=list_optim_COF(1);
elseif ~isnan(list_optim_COF(2))
    results_COF(1)=list_optim_COF(2);
else
    results_COF(1)= max(list_optim_COF);
end
if ~isnan(list_optim_COF(1))|| ~isnan(list_optim_COF(2))
    binome_COF=[list_optim_COF(1),list_optim_COF(2)];
    binome_COF(isnan(binome_COF))=0;
    results_COF(2)=sum(binome_COF)/(3-sum(isnan(binome_COF)));
else
    results_COF(2)=results_COF(1) ;
end
for i_COF = 3: length(list_optim_COF)
  if ~isnan(list_optim_COF(i_COF-2))|| ~isnan(list_optim_COF(i_COF-1)) || ~isnan(list_optim_COF(i_COF))
    trinome_COF=[list_optim_COF(i_COF-2),list_optim_COF(i_COF-1),list_optim_COF(i_COF)];
    trinome_COF(isnan(trinome_COF))=0;
    results_COF(i_COF)=sum(trinome_COF)/(3-sum(isnan(trinome_COF)));
  else 
    results_COF(i_COF)=results_COF(i_COF-1);
  end
end

%% Set up d'une valeur de filtrage min: optimal COF de l'ensemble du signal 
[frequ_FFT,pks_PSD]=spectral_analysis(data_filled,fs);
%détermination de l'optimal COF de l'ensemble du signal
[~,direction]=sort(pks_PSD,'descend');
frequ_FFT_sorted=frequ_FFT(direction);
main_frequ_1=frequ_FFT_sorted(1);
main_frequ_2=frequ_FFT_sorted(2);
if main_frequ_2 < main_frequ_1 
    [main_frequ_1,main_frequ_2]=deal(main_frequ_2,main_frequ_1);
end
first_frequ=(0.98^2/(1-0.98^2))^(0.5/BW_order)*main_frequ_1; 
second_frequ=(0.98^2/(1-0.98^2))^(0.5/BW_order)*main_frequ_2; 
i_frequ=first_frequ;
COF=[i_frequ];
while i_frequ < max_COF
    i_frequ=1.2*i_frequ;
    COF=[COF,i_frequ];
end
optim_COF=evaluation_best_COF(data,data_filled,fs,first_frequ,second_frequ,COF,BW_order);
%cas où on plot :
%[optim_COF,COF,residuals,interpol_COF,interpol_residuals,tangent_hf,tangent_bf,x_intersect,y_intersect]=evaluation_best_COF(data,data_filled,fs,first_frequ,second_frequ,COF,BW_order);
COF_seuil=optim_COF; %valeur seuil

%Si certaines COF sont inférieures à COF_seuil on les remonte à COF_seuil
results_COF(results_COF < COF_seuil)=COF_seuil ;

%% Filtrage 
window_bis=(1/3)*window;
filtered_data=data.*0;
start_frame=1;
end_frame=window_bis ; 
data_cut=struct; %data filtrée sont stockée en vu du lissage aux bords des fenêtres post filtrage
%première fenêtre
data_cut.window1=filtre_BW(BW_order,results_COF(1),fs,data_filled(start_frame:end_frame+window_bis));
filtered_data(start_frame:end_frame)=data_cut.window1(1:end-window_bis);
start_frame=start_frame+window_bis ;
end_frame= end_frame+window_bis;
%seconde fenêtre 
data_cut.window2=filtre_BW(BW_order,results_COF(2),fs,data_filled(start_frame-window_bis:end_frame+window_bis));
filtered_data(start_frame:end_frame)=data_cut.window2(window_bis+1:end-window_bis);
start_frame=start_frame+window_bis ;
end_frame= end_frame+window_bis;
for i_COF = 3: length(results_COF)-1
    %nb_trou=sum(isnan(data(start_frame:end_frame)));
    data_cut.(sprintf("window%d",i_COF))=filtre_BW(BW_order,results_COF(i_COF),fs,data_filled(start_frame-window_bis:end_frame+window_bis));
    filtered_data(start_frame:end_frame)=data_cut.(sprintf("window%d",i_COF))(window_bis+1:end-window_bis);
    start_frame=start_frame+window_bis;
    end_frame= end_frame+window_bis;
end 
%dernière fenêtre
data_cut.(sprintf("window%d",nb_eval))=filtre_BW(BW_order,results_COF(end),fs,data_filled(start_frame-window_bis:nb_frame));
filtered_data(start_frame:nb_frame)=data_cut.(sprintf("window%d",nb_eval))(window_bis+1:end);

%% lissage au bord des fenêtres de filtrage
for i_joint = 1:nb_eval-1
    frame_joint=i_joint*window_bis;
    l = round(window_bis/5)-1 ;
    w1= 2*l+1;
    w2=1;
    while l>=0
        filtered_data(frame_joint-l)=(w1*filtered_data(frame_joint-l)+w2*data_cut.(sprintf("window%d",i_joint+1))(window_bis-l,1))/(w1+w2);
        l=l-1 ;
        w1=w1-1;
        w2=w2+1;
    end
    l=0 ;
    while l<= round(window_bis/5)-1
        filtered_data(frame_joint+1+l)=(w1*data_cut.(sprintf("window%d",i_joint))(end-window_bis+1+l,1)+w2*filtered_data(frame_joint+1+l))/(w1+w2);
        l=l+1;
        w1=w1-1;
        w2=w2+1;
    end
end

%% On replace les trous d'origines
filtered_data(isnan(data))=NaN;


end