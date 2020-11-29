   methods={'KNN','LDA','svm','LR','nn'};
mymat=[];
save_dir='result';
for fil=1:3
    for meth=1:5
        method_name=methods{1,meth};
        seq_name = strcat('Result_',num2str(fil));
        result_fn = [ save_dir '\' method_name '-' seq_name];
        tt=load(result_fn,'mres');
        mymat(fil,meth)=tt.mres(1,2);
    end
end

mymat
% bar(mymat);
%
% axis([0 4 0 0.9])
% xlabel('')
% ylabel('AUC')
% title('Comparision of different algorithms in different tasks')
% legend('KNN','LDA','svm','LR')
% set(gca,'xticklabel',{'Result1','Result2','Result3'})
% xtickangle(10)
% grid on