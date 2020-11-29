clear
clc

cv1=load('CV-1.mat');
cv2=load('CV-2.mat');
cv3=load('CV-3.mat');
cv4=load('CV-4.mat');
cv5=load('CV-5.mat');

plot(cv1.xx,cv1.yy)
hold on
plot(cv2.xx,cv2.yy)
plot(cv3.xx,cv3.yy)
plot(cv4.xx,cv4.yy)
plot(cv5.xx,cv5.yy)

title({'The ROC curve of each folder obtianed by LR for the ring area (ROI 3)'})
% title('The ROC curve of LR with )
legend('CV folder 1','CV folder 2','CV folder 3','CV folder 4','CV folder 5')
hold off