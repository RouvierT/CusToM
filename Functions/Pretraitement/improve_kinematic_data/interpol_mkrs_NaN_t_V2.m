function mkrs_interp_t = interpol_mkrs_NaN_t_V2(mkrs_t, nb_data_necess, nb_nan_admis)

% **********
% *** modif jba 2011 11 17 pb si 1 seul pt connu après ou avant
% *** modif cs 2016 12 08: ligne 57-58 :  nb_select_av pouvaient ne pas être entier
% ***********

% Objectif :
%   Interpolation des positions de marqueurs manquants dans le temps
%   - Si tous on a suffisamment de points avant et après, que la taille des
%   points NaN n'est pas trop importante, extrapolation de tous les points
%   NaN avec les points autours
%   - Sinon, extrapolation de la moitié des points nan admissibles ou de la
%   moitié des points connus à droite et à gauche des points NaN

% En entrée :
%   mkrs_t : matrice n_points * 3_dimensions * t_temps

% En sortie :
%   mkrs_interp_t : matrice de même dimension que mkrs_t, mais avec les
%   points interpolés

%% ************************************************
%% ***** Début de fonction
%% ************************************************

mymethod = 'spline' ;
if ndims(mkrs_t)==3
    for ipts=1:size(mkrs_t,1)
        for idim=1:size(mkrs_t,2)
            vect_avec_NaN = squeeze( mkrs_t(ipts,idim,:) ); % ***sélection d'un ligne de données
            newpts = vect_avec_NaN ; % *** initialisation des nouvelles valeurs

            [serie_pts_ss_NaN, index_nan] = decoupe_data_avec_nan( vect_avec_NaN ) ; % ***découpage enlevant les NaN

            % *** traitement des NaN de début
            % % %             if serie_pts_ss_NaN(1).index(1) > 1
            % % %                 interp_pts = interp1(
            % % %             newpts(1:serie_pts_ss_NaN(1).index(1))
            % % %
            ind_depart = 1; % *** initialisation de l'index de départ pour données connues

            for iind_nan = 1:size(index_nan,2)
                if iind_nan+1 > size(index_nan,2)
                    ind_fin = size(vect_avec_NaN,1);
                else
                    ind_fin = index_nan(iind_nan+1).index(1)-1;
                end
                myserienan = index_nan(iind_nan).index;
                nb_nan = length( myserienan ) ;
                nb_connus_av = length( ind_depart:myserienan(1)-1);
                nb_connus_ap = length( myserienan(end)+1:ind_fin );
                ind_depart=myserienan(end)+1;


                %                 if nb_nan < nb_nan_admis     % *** si nombre de NaN suffisamment peu nombreux
                %                     if nb_connus_av + nb_connus_ap > nb_data_necess  % *** traitement des NaN entourés par un nb suffisant de pts connus
                % **** sélection des points avant et après le nan
                nb_select_av = round(min( nb_connus_av, min(nb_connus_av,nb_data_necess/2) + nb_data_necess/2 - min(nb_connus_ap,nb_data_necess/2) ));
                nb_select_ap = round(min( nb_connus_ap, nb_data_necess - nb_select_av ));

                if nb_select_av > 1 && nb_select_ap > 1 ...
                        && nb_nan < nb_nan_admis ...      % *** si nombre de NaN suffisamment peu nombreux
                        && nb_connus_av + nb_connus_ap > min(nb_data_necess, nb_nan*2) ...  % *** traitement des NaN entourés par un nb suffisant de pts connus

                    % *** selection des points
                    xsel1 = ( (myserienan(1)-nb_select_av):(myserienan(1)-1) )';
                    xsel2 = ( (myserienan(end)+1) : (myserienan(end) + nb_select_ap) )';
                    x_sel = [xsel1;xsel2]' ;
                    ysel = vect_avec_NaN(x_sel);
                    x_to_interp = myserienan';
                    vect_interp = interp1(x_sel, ysel, x_to_interp, mymethod);
                    % **** remplissage des pts connus en début de série
                    newpts( x_to_interp ) = vect_interp ;


                else


                    if nb_select_av > 1 % extrapolation à partir des données de droite
                        xsel = ( (myserienan(1)-nb_select_av):(myserienan(1)-1) )';
                        ysel = vect_avec_NaN(xsel');
                        x_to_interp = myserienan( 1:min(length(myserienan),max(1,int32( min(nb_nan_admis, nb_select_av/2) ))) );
                        vect_interp = interp1(xsel, ysel, x_to_interp, mymethod);
                        % **** remplissage des pts connus en début de série
                        newpts( x_to_interp ) = vect_interp ;

                    end

                    if nb_select_ap > 1 % extrapolation à partir des données de gauche
                        xsel = ( (myserienan(end)+1):(myserienan(end)+nb_select_ap) )';
                        ysel = vect_avec_NaN(xsel');
                        x_to_interp = myserienan( max(1,end - int32(min(nb_nan_admis, nb_select_ap/2))):end );
                        vect_interp = interp1(xsel, ysel, x_to_interp, mymethod);
                        % **** remplissage des pts connus en début de série
                        newpts( x_to_interp ) = vect_interp ;
                    end
                end

            end
            %                 end
            %     end
            % end



            mkrs_interp_t(ipts,idim,:) =    newpts;

        end
    end
else
    disp('non traité : matrice d''entree de taille incorrecte (voulu : n*3*tps)');
    mkrs_interp_t = mkrs_t ;
end
