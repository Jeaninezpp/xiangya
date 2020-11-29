methods={'KNN','LDA','svm','nn','LR'};
mymat=[];
save_dir='result';
meth= 1;
method_name=methods{1,meth};

for fil=1:3
    seq_name = strcat('Result_',num2str(fil));
    close all
    figure
    hold on;
    for cv=1:9
        fnam = [ save_dir '\CV-' num2str(cv) '-' method_name '-' seq_name];
        xs=load(fnam,'xx');
        ys=load(fnam,'yy');
        
        plot(xs.xx,ys.yy)
    end
    hold off;
end