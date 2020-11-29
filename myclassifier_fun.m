function mres=myclassifier_fun(meth,r,run)
methods={'nn','KNN','LDA','svm','LR'}; % NN>LR>LDA>SVM KNN
method_name=methods{1,meth};

seq_name = strcat('run',num2str(run),'Result_data3_',num2str(r));
datapath = '../data/';
radiomics_feat_fn_t1 = strcat(datapath,'data3_imputed.xlsx'); % test10.data3_imputed.

[number, text, all_colst1 ] = xlsread(radiomics_feat_fn_t1);
all_radiomics_features =(all_colst1(2:end,2:end));

% Table = readtable(radiomics_feat_fn_t1,'ReadRowNames',true);
% all_radiomics_features = table2array(Table);

y=readtable('../data/lable.xlsx','ReadRowNames',true);
pts_class = table2array(y);
% pts_class=cell2mat( all_colst1(2:end,4));
% pts_class=y.yy(:,2);


%%% rand
% n=randperm(size(all_radiomics_features,1));
% all_radiomics_features=all_radiomics_features(n,:);
% pts_class=pts_class(n,:);




save_dir='result';
mkdir(save_dir)


% all_radiomics_features=myclean(all_radiomics_features);
pts_org = [];
pts_id = [];
i = 1;

% fclose(filepr);
[pos_idx ] = find(pts_class==1);
% Negative classes
[neg_idx ] = find(pts_class==0);

train_set_pos_idx = pos_idx;
train_set_neg_idx = neg_idx;

%%%%%%%
CV_NUM = 10; %????
folder_per_CV_pos = ceil(length(train_set_pos_idx)/CV_NUM);
%CV data partition
train_pos_pts_idx_CV = zeros(CV_NUM, folder_per_CV_pos*(CV_NUM-1));
test_pos_pts_idx_CV = zeros(CV_NUM, folder_per_CV_pos);
folder_per_CV_neg = ceil(length(train_set_neg_idx)/CV_NUM);
%CV data partition
train_neg_pts_idx_CV = zeros(CV_NUM, folder_per_CV_neg*(CV_NUM-1));
test_neg_pts_idx_CV = zeros(CV_NUM, folder_per_CV_neg);

for  i = 1 : CV_NUM
    start_idx_pos = folder_per_CV_pos *(i - 1) + 1;
    end_idx_pos = min( folder_per_CV_pos * (i - 1) + folder_per_CV_pos , length(train_set_pos_idx));
    test_idx_pos =train_set_pos_idx(start_idx_pos : end_idx_pos );
    all_idx_pos = train_set_pos_idx;
    test_pos_pts_idx_CV(i,1:length(test_idx_pos)) = test_idx_pos;
    train_pos_pts_idx_CV(i,1: length(setdiff(all_idx_pos, test_idx_pos))) = setdiff(all_idx_pos, test_idx_pos);
    start_idx_neg = folder_per_CV_neg *(i - 1) + 1;
    end_idx_neg = min( folder_per_CV_neg * (i - 1) + folder_per_CV_neg , length(train_set_neg_idx));
    test_idx_neg =train_set_neg_idx(start_idx_neg : end_idx_neg );
    all_idx_neg = train_set_neg_idx;
    test_neg_pts_idx_CV(i,1:length(test_idx_neg)) = test_idx_neg;
    train_neg_pts_idx_CV(i,1:length(setdiff(all_idx_neg, test_idx_neg))) = setdiff(all_idx_neg, test_idx_neg);
end

CV_AUC = [];
CV_ACC = [];
CV_feat_selected = [];

for i = CV_NUM :-1: 1
    try
        cur_train_pos_slices_idx = nonzeros(train_pos_pts_idx_CV(i, :));
        cur_test_pos_slices_idx = nonzeros(test_pos_pts_idx_CV(i, :));
        cur_train_neg_slices_idx = nonzeros(train_neg_pts_idx_CV(i, :));
        cur_test_neg_slices_idx = nonzeros(test_neg_pts_idx_CV(i, :));
        %%get feature mat
        train_pos_features_mat_cv = all_radiomics_features(cur_train_pos_slices_idx',:);
        test_pos_features_mat_cv  = all_radiomics_features(cur_test_pos_slices_idx,:);
        train_neg_features_mat_cv = all_radiomics_features(cur_train_neg_slices_idx,:);
        test_neg_features_mat_cv  = all_radiomics_features(cur_test_neg_slices_idx,:);
        train_pos_set_label = zeros(size(train_pos_features_mat_cv,1),1);
        train_neg_set_label = ones(size(train_neg_features_mat_cv,1),1);
        test_pos_set_label = zeros(size(test_pos_features_mat_cv,1),1);
        test_neg_set_label = ones(size(test_neg_features_mat_cv,1),1);
        features_mat_train = [train_pos_features_mat_cv' train_neg_features_mat_cv'];
        features_mat_train = features_mat_train';
        %delete the cell contain 0 element in cr_numer ( 'nan' or 'inf' in features_mat_train)
        %all() Determine if all array elements are nonzero or true
        cr_number = cellfun(@(x) isnumeric(x),features_mat_train);
        out_test = features_mat_train(:, all(cr_number,1));
        features_mat_train = cell2mat(out_test);
        train_label_vec = [train_pos_set_label' train_neg_set_label'];
        test_label_vec = [test_pos_set_label' test_neg_set_label'];
        %     size(test_label_vec)
        [B, FitInfo]= lasso(features_mat_train,train_label_vec,'cv',5);
        C=(abs(B)>0);
        THR_num_features = zeros(1,size(C,2));
        THR_ACC = zeros(1,size(C,2));
        THR_AUC =  zeros(1,size(C,2));
        
        
        XX=[];%zeros(size(C,2),29);
        YY=[];%zeros(size(C,2),29);
        xys=[];%zeros(size(C,2),1);
        
        for lasso_t=1:size(C,2)
            r=(find(C(:,lasso_t)==1))' ;
            
            feature_selected=r;
            num_features=size(feature_selected,2);
            THR_num_features(1,lasso_t) = num_features;
            if num_features < 1
                continue;
            end
            train_selected = features_mat_train(:, feature_selected);
            norm_train_selected = train_selected - train_selected;
            for col_idx = 1 : size(train_selected,2)
                m = train_selected(:,col_idx);
                range = max(m(:)) - min(m(:)) + eps;
                norm_train_selected(:,col_idx) = (m - min(m(:))) / range;
            end
            
            if strcmp(methods{1,meth},'LR')
                b =glmfit(norm_train_selected, train_label_vec );
            end
            if strcmp(methods{1,meth},'KNN')
                b =ClassificationKNN.fit(norm_train_selected, train_label_vec );
            end
            if strcmp(methods{1,meth},'RandomForest')
                b =TreeBagger(5,norm_train_selected, train_label_vec );
            end
            if strcmp(methods{1,meth},'Bayes')
                b =fitcnb(norm_train_selected, train_label_vec );
            end
            if strcmp(methods{1,meth},'LDA')
                b =ClassificationDiscriminant.fit(norm_train_selected, train_label_vec );
            end
            if strcmp(methods{1,meth},'Ensembles')
                b =fitensemble(norm_train_selected, train_label_vec,'AdaBoostM1' ,5,'tree','type','classification' );
            end
            if strcmp(methods{1,meth},'svm')
                b = fitcsvm(norm_train_selected, train_label_vec,'Standardize',true,'KernelFunction','RBF',...
                    'KernelScale','auto');
            end
            if strcmp(methods{1,meth},'nn')
                net = feedforwardnet(10);
                net.trainParam.showWindow = false;
                net.trainParam.showCommandLine = false;
                net = train(net,norm_train_selected',train_label_vec);
            end
            
            
            features_mat_test_cv = [test_pos_features_mat_cv' test_neg_features_mat_cv'];
            
            features_mat_test_cv = features_mat_test_cv';
            %%we will use code below in the testing and the cross-validataion and the
            %%test set
            cr_number = cellfun(@(x) isnumeric(x),features_mat_test_cv);
            %delete the cell contain 0 element in cr_numer ( 'nan' or 'inf' in features_mat_test)
            %all() Determine if all array elements are nonzero or true
            out_test = features_mat_test_cv(:, all(cr_number,1));
            %out_test = features_mat_test(:, ~any(out_test,1));
            features_mat_cv = cell2mat(out_test);
            test_selected = features_mat_cv(:, feature_selected);
            %%Evaluate models' performances
            norm_test_selected = test_selected - test_selected;
            for col_idx = 1 : size(test_selected,2)
                m = test_selected(:,col_idx);
                range = max(m(:)) - min(m(:)) + eps;
                norm_test_selected(:,col_idx) = (m - min(m(:))) / range;
            end
            if strcmp(methods{1,meth},'LR')
                p = glmval(b,norm_test_selected,'logit' );
            elseif strcmp(methods{1,meth},'nn')
                p = net(norm_test_selected');
            else
                p = predict(b,norm_test_selected);
            end
            test_label = test_label_vec;
            CP = classperf(test_label, p<0.5);
            
            THR_ACC(1,lasso_t) = CP.CorrectRate;
            [X_coord,Y_coord,T_thr,AUC_SVM,OPT] = perfcurve(test_label, p, 0);
            %disp('SVM AUC = ');
            %disp(AUC_SVM);
            XX(lasso_t,1:size(X_coord,1))=X_coord;
            YY(lasso_t,1:size(Y_coord,1))=Y_coord;
            xys(lasso_t)=size(X_coord,1);
            THR_AUC(1,lasso_t) =  AUC_SVM;
            %
        end
        [value_max, idx_max] = max(THR_AUC);
        selected_f = B(:,idx_max);
        value_AUC = value_max;
        idx_AUC = min(idx_max);
        value_ACC = THR_ACC(idx_AUC);
        selected_fea_num = THR_num_features(idx_AUC);
        %             disp(['CV-' num2str(i)]);
        %             disp([num2str(selected_fea_num) ' ' num2str(value_AUC) ' ' num2str(value_ACC) ]);
        result_fn = [ save_dir '\CV-' num2str(i) '-' method_name '-' seq_name];
        
        CV_AUC = [CV_AUC value_AUC];
        CV_ACC = [CV_ACC value_ACC];
        CV_feat_selected = [CV_feat_selected selected_fea_num];
        
        plot(XX(idx_max,1:xys(idx_max)),YY(idx_max,1:xys(idx_max)))
        xx=XX(idx_max,1:xys(idx_max));
        yy=YY(idx_max,1:xys(idx_max));
        save(result_fn,'THR_AUC', 'THR_ACC', 'THR_num_features','C','value_AUC','idx_AUC','value_ACC','selected_fea_num','xx','yy','selected_fea_num','selected_f');
    catch
        disp(i);
    end
end

%     mean(CV_AUC)
%     mean(CV_ACC)
res=[CV_feat_selected' CV_AUC' CV_ACC'];
result_fn = [ save_dir '/' method_name '-' seq_name];
disp(result_fn)
disp(res);
mres=mean(res);
disp(mres);
save(result_fn,'mres');
