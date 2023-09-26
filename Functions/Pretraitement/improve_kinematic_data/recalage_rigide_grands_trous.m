function     [st_marqueurs_cine,flag_marqueur_absent] = recalage_rigide_grands_trous(st_marqueurs_cine,Marqueurs_Segment)
%% #############################################################################################################################
% Sauret Christophe, IBHGC
% 05/05/2017

% st_marqueurs_cine : structure contenant les coordonnées de tous les marqueurs
% Marqueurs_Segment : liste des marqueurs du segment à traiter : exemple : {'C7', 'MAN', 'XYP', 'T8', 'T12', 'COTG', 'COTD'}
% flag_marqueur_absent : balise pour la suite du traitement si un marqueur
%                          (1) un ou plusieurs marqueurs absents du fichier 
%                          (2) tout le segment est absent
% #############################################################################################################################
%%

        nb_marqueurs_segment = length(Marqueurs_Segment);
        Mat = [];%NaN(size(st_marqueurs_cine.(Marqueurs_Segment{1}),1),nb_marqueurs_segment);
        flag_marqueur_absent    = 0;
        i_present               = 0; 
        for icol=1:nb_marqueurs_segment
            try 
                Mat         = [Mat st_marqueurs_cine.(Marqueurs_Segment{icol})(:,1)];
                i_present   = i_present + 1;
                Marqueurs_Segment_presents{i_present} = Marqueurs_Segment{icol};
            catch
%                 display(['!!! Marqueur ',Marqueurs_Segment{icol} ', manquant dans le c3d !!!']),
                nb_marqueurs_segment = nb_marqueurs_segment-1;
                flag_marqueur_absent = 1;
                
            end
        end
      
      if ~isempty(Mat)  
          A = isnan(Mat);
          ind = find(sum(A,2)>=1);
          for i_ind = 1:length(ind)
              % on verifie qu'il y a bien au moins 3 marqueurs pour faire un recalage rigide
              Marqueurs_presents = A(ind(i_ind),:)==0;          

              % on compte combien il y a de marqueurs manquants à recaler
              Marqueurs_absents = A(ind(i_ind),:)==1;
              Qui_est_absent = find( Marqueurs_absents==1);

              for i_marqueurs_absents = 1:sum( Marqueurs_absents)

                  if sum(Marqueurs_presents)>=3
                      % on cherche sur les frames proches une frame ou le marqueur est presents
                      ok=0; i=0;
                      while ok==0
                          i = i+1;

                          % on cherche sur la frame d'avant
                          if ind(i_ind)-i>=1
                              if ~isnan(Mat(ind(i_ind)-i,Qui_est_absent))
                                  Marqueurs_presents_i = -(A(ind(i_ind)-i,:)==0) - Marqueurs_presents;
                                  Qui_presents_both_frames = find(Marqueurs_presents_i==-2); % les marqueurs sont présents dans les deux frames (i et frame à corriger)
                                  if size(Qui_presents_both_frames,2)>=3
                                      cluster_initial = zeros(size(Qui_presents_both_frames,2),3);
                                      cluster_reference = zeros(size(Qui_presents_both_frames,2),3);
                                      for i_m = 1:size(Qui_presents_both_frames,2)
                                          cluster_initial(i_m,:) =  st_marqueurs_cine.(Marqueurs_Segment_presents{Qui_presents_both_frames(i_m)})(ind(i_ind)-i,:);
                                          cluster_reference(i_m,:) =  st_marqueurs_cine.(Marqueurs_Segment_presents{Qui_presents_both_frames(i_m)})(ind(i_ind),:);
                                      end

                                      Marqueur_a_recaler =  st_marqueurs_cine.(Marqueurs_Segment_presents{Qui_est_absent(i_marqueurs_absents)})(ind(i_ind)-i,:); % en met en dernier le marqueur a recaler
                                      Registered_marker = fct_recalage(cluster_reference, cluster_initial, Marqueur_a_recaler);
                                      st_marqueurs_cine.(Marqueurs_Segment_presents{Qui_est_absent(i_marqueurs_absents)})(ind(i_ind),:)=Registered_marker;
                                      % mise à jour des variable Mat et A
                                      Mat(ind(i_ind),Qui_est_absent(i_marqueurs_absents))=Registered_marker(1);
                                      A(ind(i_ind),Qui_est_absent(i_marqueurs_absents))=0;
                                      ok=1; % pour sortir du while

                                  else %on ne peut rien faire
                                  end

                              else % on ne peut rien faire
                              end
                          end

                          % si ça n'a pas marché avec la frame d'avant on teste avec la frame d'après
                          if ind(i_ind)+i<=size(Mat,1)
                              if ~isnan(Mat(ind(i_ind)+i,Qui_est_absent))
                                  Marqueurs_presents_i = -(A(ind(i_ind)+i,:)==0) - Marqueurs_presents;
                                  Qui_presents_both_frames = find(Marqueurs_presents_i==-2); % les marqueurs sont présents dans les deux frames (i et frame à corriger)
                                  if size(Qui_presents_both_frames,2)>=3
                                      cluster_initial = zeros(size(Qui_presents_both_frames,2),3);
                                      cluster_reference = zeros(size(Qui_presents_both_frames,2),3);
                                      for i_m = 1:size(Qui_presents_both_frames,2)
                                          cluster_initial(i_m,:) =  st_marqueurs_cine.(Marqueurs_Segment_presents{Qui_presents_both_frames(i_m)})(ind(i_ind)+i,:);
                                          cluster_reference(i_m,:) =  st_marqueurs_cine.(Marqueurs_Segment_presents{Qui_presents_both_frames(i_m)})(ind(i_ind),:);
                                      end

                                      Marqueur_a_recaler =  st_marqueurs_cine.(Marqueurs_Segment_presents{Qui_est_absent(i_marqueurs_absents)})(ind(i_ind)+i,:); % en met en dernier le marqueur a recaler
                                      Registered_marker = fct_recalage(cluster_reference, cluster_initial, Marqueur_a_recaler);
                                      st_marqueurs_cine.(Marqueurs_Segment_presents{Qui_est_absent(i_marqueurs_absents)})(ind(i_ind),:)=Registered_marker;
                                      % mise à jour des variable Mat et A
                                      Mat(ind(i_ind),Qui_est_absent(i_marqueurs_absents))=Registered_marker(1);
                                      A(ind(i_ind),Qui_est_absent(i_marqueurs_absents))=0;
                                      ok=1; % pour sortir du while

                                  else %on ne peut rien faire
                                  end

                              else % on ne peut rien faire
                              end
                          end
                          if ind(i_ind)+i>size(Mat,1) && ind(i_ind)-i<1
    %                           disp('Un Marqueurs n''est présent sur aucune frame.')
                              break
                          end
                      end
                  end
              end
          end
          
      else
          flag_marqueur_absent = 2; %signifie que le segment complet est absent
      end
end
