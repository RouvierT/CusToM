function [ c_nb_NaN, N_NaN_total, names_ddl] = compteur_NaN_structure( st_RMSE_sto )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
N_NaN_total=0;
names_ddl=fieldnames(st_RMSE_sto);
nb_ddl=length(names_ddl);
% c_nb_NaN=cell(2,nb_ddl);
c_nb_NaN=cell(1,nb_ddl);
for i_ddl=1:length(names_ddl)
    cur_ddl=names_ddl{i_ddl};
    %     c_nb_NaN{1,i_ddl}=cur_ddl;
    cur_mat=st_RMSE_sto.(cur_ddl);
    cur_N_NaN=compteurNaN(cur_mat);
    N_NaN_total=N_NaN_total+cur_N_NaN;
    %     c_nb_NaN{2,i_ddl}=cur_N_NaN;
    c_nb_NaN{1,i_ddl}=cur_N_NaN;
end
names_ddl=names_ddl';

end

