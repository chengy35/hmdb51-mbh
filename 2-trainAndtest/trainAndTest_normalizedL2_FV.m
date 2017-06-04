function [ des_accs ] = trainAndTest_normalizedL2_FV(descriptorType,tr_index,classlabel,encode_method,split,wfeat_all,gmmSize,normalize_method)
    tr_kern_sum = []; ts_kern_sum = [];
    des_accs = zeros(numel(descriptorType)+1,1);
    trn_indx  = find(tr_index==1);
    test_indx = find(tr_index==0);
    trainLabels = classlabel(trn_indx);
    testLabels = classlabel(test_indx);
    for i = 1 : numel(descriptorType)
        [~,ides] = ismember(descriptorType{i},{'hog','hof','mbhx','mbhy'});
        if ~exist(sprintf('%s_%s_%d_Kern.mat',descriptorType{i},encode_method,split),'file')
            feature = wfeat_all{ides};
            feature = normalize(feature',normalize_method, 2*gmmSize); % now feature in column-wise'
            TrainData = feature(:,trn_indx);
            TestData = feature(:,test_indx);
            TrainData_Kern = TrainData' * TrainData;
            TestData_Kern = TrainData' * TestData;
            clear TrainData; clear TestData;
            save(sprintf('%s_%s_%d_Kern.mat',descriptorType{i},encode_method,split), 'TrainData_Kern', 'TestData_Kern','-v7.3');
        else
            load(sprintf('%s_%s_%d_Kern.mat',descriptorType{i},encode_method,split));
        end
        if i==1
            tr_kern_sum = TrainData_Kern;
            ts_kern_sum = TestData_Kern;
        else
            tr_kern_sum = tr_kern_sum + TrainData_Kern;
            ts_kern_sum = ts_kern_sum + TestData_Kern;
        end
        score_test = svm_one_vs_all(TrainData_Kern, TestData_Kern, trainLabels', max(classlabel));
        [~, predict_labels] = max(score_test');
        [~,avg_acc,~] = get_cm(testLabels',predict_labels',1);
        des_accs(i) = avg_acc;
        fprintf('split---%d, %s--->accuracy:\n %f\n',split, descriptorType{i}, avg_acc);
    end
    save(sprintf('%d_%s_%s_SumKern.mat',split,encode_method,cell2mat(descriptorType)), 'tr_kern_sum', 'ts_kern_sum','-v7.3');
    score_test = svm_one_vs_all(tr_kern_sum, ts_kern_sum, trainLabels', max(classlabel));
    [~, predict_labels] = max(score_test');
    [~,avg_acc,~] = get_cm(testLabels',predict_labels',1);
    des_accs(end) = avg_acc;
    fprintf('split---%d, %d descriptor combination--->accuracy:\n %f',split, numel(descriptorType), avg_acc);
end