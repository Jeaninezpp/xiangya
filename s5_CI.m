CIFcn = @(x,p)std(x(:),'omitnan')/sqrt(sum(~isnan(x(:)))) * tinv(abs([0,1]-(1-p/100)/2),sum(~isnan(x(:)))-1) + mean(x(:),'omitnan');

methods={'nn'};
mymat=[];
name={'1','2','3'};

for nn=2
    save_dir= strcat('result');
    for meth=1
        for cv=1:10
            method_name=methods{1,meth};
%             seq_name = strcat('',num2str(name));
            seq_name =  num2str(nn);
            result_fn = [ save_dir '\CV-' num2str(cv) '-' method_name '-Result_' seq_name];
            tt=load(result_fn,'value_AUC');
            mymat(meth,cv)=tt.value_AUC;
        end
    end
    x=mymat;
    p = 95;
    disp(save_dir)
    disp(mean(x))
    CI = CIFcn(x,p);
    disp(CI)
end
