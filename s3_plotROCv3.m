close all
clear
methods={'KNN','LDA','svm','nn','LR','Luck'};
names={'KNN','LDA','SVM','NN','LR','Luck'};
mymat=[];
save_dir='result';
for fil=1:3
    figure
    for meth=1:5
        k=1;
        t=0.01;
        y=[];
        method_name=methods{1,meth};
        seq_name = strcat('Result_',num2str(fil));
        result_fn = [ save_dir '\' method_name '-' seq_name];
        for x=0:t:1
            y(k,1)=gety(save_dir,method_name,seq_name, x);
            k=k+1;
        end
        plot(0:t:1,y);
        hold on
    end
    plot([0 1],[0 1],'b:')
    legend(names);
    title('Receiver operating characteristics (ROC)');
    xlabel('False Positive Rate');
    ylabel('True Positive Rate');
    hold off
end


function res=gety(save_dir,method_name,seq_name,x)
y=[];
for cv=1:9
    try
        fnam = [ save_dir '\CV-' num2str(cv) '-' method_name '-' seq_name];
        xs=load(fnam,'xx');
        ys=load(fnam,'yy');
        if find(xs.xx==x)>0
            y(cv,1)=ys.yy(max(find(xs.xx==x)));
        else
            %             y(cv,1)=ys.yy(  max(find(xs.xx<x)+1)  );
            x1=max(find(xs.xx<x));
            x2=x1+1;
            y1=ys.yy(x1);
            y2=ys.yy(x2);
            y(cv,1)=y1+(x-xs.xx(x1))/(xs.xx(x2)-xs.xx(x1))*(y2-y1);
        end
    catch
    end
end
res=mean(y);
end
