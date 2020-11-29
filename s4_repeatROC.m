close all
clear
methods={'nn','Luck'};
mymat=[];
save_dir='result';
% 0.8451    0.8162    0.8487
for fil=3
    figure
    meth=1;
    k=1;
    t=0.01;
    y=[];
    method_name=methods{1,meth};
    seq_name = strcat('Result_',num2str(fil));
    result_fn = [ save_dir '\' method_name '-' seq_name];
    for x=0:t:1
        [mme,mma,mmi]=gety(save_dir,method_name,seq_name, x);
        mmean(k,1)=mme;
        %         mmax(k,1)=min(mma,1);
        mmax(k,1)=min(mma,mma);
        mmin(k,1)=mmi;
        k=k+1;
    end
    tt=0:t:1;
    hold on
    fill([tt,fliplr(tt)],[mmin',fliplr(mmax')],[0.85 0.85 0.85])
    plot(0:t:1,mmean,'r');
    plot([0 1],[0 1],'b:')
    legend('±1std dev.','Mean of 100 CVs (AUC=0.849)','Luck');
    title('Receiver operating characteristics (ROC)');
    xlabel('False Positive Rate');
    ylabel('True Positive Rate');
        axis([0 1 0 1])
    
    hold off
end


function [mmean,mmax,mmin]=gety(save_dir,method_name,seq_name,x)
y=[];
for run =1:50
    k=1;
    for cv=1:10
        try
            fnam = [ save_dir '\CV-' num2str(cv) '-' method_name '-run' num2str(run) '' seq_name];
            xs=load(fnam,'xx');
            ys=load(fnam,'yy');
            if find(xs.xx==x)>0
                y(k,1)=ys.yy(max(find(xs.xx==x)));
                k=k+1;
            else
                x1=max(find(xs.xx<x));
                x2=x1+1;
                y1=ys.yy(x1);
                y2=ys.yy(x2);
                y(k,1)=y1+(x-xs.xx(x1))/(xs.xx(x2)-xs.xx(x1))*(y2-y1);
                k=k+1;
            end
        catch
        end
    end
    yy(run,1)=mean(y);
end
mmean=mean(yy);
mstd=std(yy);
mmax=mmean+mstd;
mmin=mmean-mstd;
end
