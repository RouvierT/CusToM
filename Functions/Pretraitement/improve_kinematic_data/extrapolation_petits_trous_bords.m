function mrk=extrapolation_petits_trous_bords(mrk,taille_trou,cur_mark,cur_acquisition)

for i_coord=1:size(mrk,2)
    ind_nan = find(isnan(mrk(:,i_coord)));
    i=1;
    long_NaN=0;
    for i_NaN=1:size(ind_nan,1)
        cur_ind_nan=ind_nan(i_NaN);
        if long_NaN(i)==0
            long_NaN(i)=1;
            prev_ind_nan=cur_ind_nan;
        elseif cur_ind_nan==prev_ind_nan+1
            long_NaN(i)=long_NaN(i)+1;
            prev_ind_nan=cur_ind_nan;
        else
            i=i+1;
            long_NaN(i+1)=0;
        end
    end
    if length(long_NaN)==1
        long_NaN(2)=0;
    end
    %% Extrapolation début de colonne de donnée
    if ~isempty(ind_nan)
        if ind_nan(1)==1
            if long_NaN(1)<taille_trou
                try
                    ind_not_nan=long_NaN(1)+1; % Indice de la première valeur qui n'est pas à NaN
                    x_interp=1:1:ind_not_nan-1; % Indices sur lesquelles on va extrapoler
                    x=ind_not_nan:1:ind_not_nan+50; % Indices des coordonnées que l'on connait pour l'extrapolation
                    val_connues=mrk(ind_not_nan:ind_not_nan+50,i_coord); % Valeurs connues aux indices x
                    val_interp=interp1(x,val_connues,x_interp,'spline','extrap');
                    mrk(1:ind_not_nan-1,i_coord)=val_interp;
%                 catch
%                     disp(['!!! Erreur interpolation debut de trajectoire pour ,' cur_mark 'dans ' cur_acquisition '!!!'])
                end
            end
        end
        
        %% Extrapolation fin de donnée
        if ind_nan(end)==size(mrk,1)
            if long_NaN(end-1)<taille_trou
                try 
                    ind_not_nan=size(mrk,1)-long_NaN(end-1)-1; % Indice de la dernière valeur qui n'est pas à NaN
                    x_interp=ind_not_nan+1:1:size(mrk,1); % Indices sur lesquelles on va extrapoler
                    x=ind_not_nan-50:1:ind_not_nan; % Indices des coordonnées que l'on connait pour l'extrapolation
                    val_connues=mrk(ind_not_nan-50:ind_not_nan,i_coord); % Valeurs connues aux indices x
                    val_interp=interp1(x,val_connues,x_interp,'spline','extrap');
                    mrk(ind_not_nan+1:end,i_coord)=val_interp;
%                 catch
%                     disp(['!!! Erreur interpolation fin de trajectoire pour ,' cur_mark 'dans ' cur_acquisition '!!!'])
                end
            end
        end
    end
end
