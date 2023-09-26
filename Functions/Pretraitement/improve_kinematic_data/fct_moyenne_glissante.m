function [b]=fct_moyenne_glissante(a,n) % a : vecteur colonne ? lisser, n : valeur pour la moyenne glissante (doit ?tre impair)

% on vérifie que le vecteur est un vecteur colonne
[nb_lignes,nb_col]=size(a);

transposee = 0;
if nb_lignes<nb_col
    a=a';
    transposee=1;
end

 n2=(n-1)/2;
 a2=zeros(size(a,1)+2*n2,1); a2(n2+1:size(a2,1)-n2,1)=a;
 
 % Extrapolation
   for i =1:n2 % extrapolation sur n2 valeur avant et apr?s la matrice a (permet de ne pas perdre de valeurs et eviter les effets de bords)
     a2(n2+1-i,1)=a2(n2+1,1)-(a2(n2+1+i,1)-a2(n2+1));
     a2(size(a2,1)-n2+i,1)=a2(size(a2,1)-n2,1)-(a2(size(a2,1)-n2-i,1)-a2(size(a2,1)-n2,1));
   end % end for
   
   % Lissage - sens horaire
   a3=a2;
   for i=n2+1:(size(a2,1)-n2)
     %gestion des NaN
     segment = a2(i-n2:i+n2,1);
     z = isnan(segment);
     z2 = find(z(1:n2)==1);
     z3 = find(z(n2+1:end)==1);
     z4 = unique([z2;n2+z3]);
     
     segment(end+1-z4)=NaN;
     
     % Moyenne
     a3(i,1)=nanmean(segment);
   end % end for 
   
   
   % lissage - sens anti-horaire
   a4=a3;
   for i=n2:size(a2,1)-(n2+1)
     %gestion des NaN
     segment = a4(size(a2,1)-i-n2:size(a2,1)-i+n2,1);
     z = isnan(segment);
     z2 = find(z(1:n2)==1);
     z3 = find(z(n2+1:end)==1);
     z4 = unique([z2;n2+z3]);
     
     segment(end+1-z4)=NaN;
    
     % Moyenne
     a4(size(a3,1)-i,1)=nanmean(segment);
   end % end for 
   
  b=a4(n2+1:size(a2,1)-n2);
  
  if transposee == 1
      b=b';
  end

end