function [markers] = NettoieMarkerLabels(markers)
Champs = fieldnames(markers); markers2=[];
        for i=1:size(Champs,1)
           % strfind(Champs{i},'C_')
            if (strfind(Champs{i},'C_'))==1 % ~isempty(strfind(Champs{i},'C_'))==1 % on enlève les marqueurs non labélisés
            elseif ~isempty(strfind(Champs{i},'_1'))==1 % pour enveler les double trajectoire (HEEL, HEEL_1, HEEL_2... on ne garde que la première)
            elseif ~isempty(strfind(Champs{i},'_2'))==1
            elseif ~isempty(strfind(Champs{i},'_3'))==1
            elseif ~isempty(strfind(Champs{i},'_4'))==1
            elseif ~isempty(strfind(Champs{i},'_5'))==1
            elseif ~isempty(strfind(Champs{i},'_6'))==1
            elseif ~isempty(strfind(Champs{i},'_7'))==1
            elseif ~isempty(strfind(Champs{i},'_8'))==1
            elseif ~isempty(strfind(Champs{i},'_9'))==1
            elseif isempty(strfind(Champs{i},'_'))==1 % on garde directement s'il n'y a pas de nom de sujet avant nom de marker (séparateur : '_')
                markers2.(Champs{i})=markers.(Champs{i});
            else
                a =strfind(Champs{i},'_');
                markers2.(Champs{i}(a(end)+1:end))=markers.(Champs{i});
            end
        end
        markers=markers2; clear markers2
        
end