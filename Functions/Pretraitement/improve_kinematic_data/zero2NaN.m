function [st_marqueurs]=zero2NaN(st_marqueurs)

% Cette fonction permet de transformer les [0,0,0] sortant de Nexus à cause de la
% perte de marqueurs en des [NaN,NaN,NaN]

% structure :
%            st_marqueurs.nom_marqueurs=Matrice de coordonnée du marqueur

Champs_marqueurs = fieldnames(st_marqueurs);

for i_marqueur = 1:size(Champs_marqueurs ,1)
%     % version lisible
%     A = find(sum(abs(st_marqueurs.(Champs_marqueurs{i_marqueur})),2)==0);
%     st_marqueurs.(Champs_marqueurs{i_marqueur})(A,:)=NaN;
    
    % version avec indexation logique (recommandée Matlab)
    st_marqueurs.(Champs_marqueurs{i_marqueur})(logical(sum(abs(st_marqueurs.(Champs_marqueurs{i_marqueur})),2)==0),:)=NaN;
end

end % end function