clc;clear;
methods={'nn'};
mymat=[];
% name={'12','13','23'};

for nn=1:3
    save_dir= strcat('result');
    for col=7
        for meth=1
            for cv=1:9
                %                 try
                method_name=methods{1,meth};
                seq_name = strcat('Result_',num2str(nn));
                result_fn = [ save_dir '\CV-' num2str(cv) '-' method_name '-' seq_name];
                tt=load(result_fn);
                mymat(:,cv)=tt.selected_f;
                mymat2(:,cv)=double(abs(tt.selected_f)>0);
                %                 catch
                %                 end
            end
        end
    end
    radiomics_feat_fn_t1 = strcat('TheInitialResult',num2str(nn),'.csv');
    [~, ~, all_colst1 ] = xlsread(radiomics_feat_fn_t1);
    nam=cell(all_colst1(1,5:end)');
    mymat2(:,size(mymat2,2)+1)=sum(mymat2,2);
    mat2=mat2cell(mymat2,[ones(1,size(mymat2,1))],[ones(1,size(mymat2,2))]);
    tab=cat(2,nam,mat2);
    xlswrite(strcat(save_dir,num2str(nn),'_bin.xls'),tab);
    
    mat=mat2cell(mymat,[ones(1,size(mymat,1))],[ones(1,size(mymat,2))]);
    tab=cat(2,nam,mat);
    xlswrite(strcat(save_dir,num2str(nn),'_w.xls'),tab);
    
end