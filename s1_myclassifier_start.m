clc;clear;
warning off


for run=1
    for meth=1:5
        for file=1:1
            mres=myclassifier_fun(meth,file,run);
            mymat(file,meth)=mres(1,2);
        end
    end
end
% mymat
% bar(mymat);
