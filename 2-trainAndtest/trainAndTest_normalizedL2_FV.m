function trainAndTest_normalizedL2_FV(video_dir,fullvideoname,featDir_FV,encode,actionName)
    category = dir(video_dir);
    nClasses = 16;
    nCorrect = 0;
    nTotal = 0; 
    resultFile = ['./' encode '_result'];
    result = zeros(nClasses,nClasses);

    i=1;
	FileName = ['./2-trainAndtest/classlabel'];
	classlabel = load(FileName);

	FileName = ['./2-trainAndtest/trainIndex'];
	trn_indx = load(FileName);
	
	FileName = ['./2-trainAndtest/testIndex'];
	test_indx = load(FileName);
		
    TrainClass = classlabel(trn_indx,:);
    
    TestClass = classlabel(test_indx,:);

    if ~exist('TestData_Kern_cell.mat','file')
 		    if ~exist('TrainData.mat','file')
			   TrainData = zeros(size(trn_indx),49152);
			   for j = 1:size(trn_indx)
					    featFile{j} = [fullfile(featDir_FV,sprintf('/wall/%d.mat',trn_indx(j)))];
						fprintf('read in training: %d \n',j);
					    temp = dlmread(featFile{j});
					    temp = sqrt(temp);
					    temp = normalizeL2(temp);
					    TrainData(j,:) = temp(:,2:49153);
					    clear temp;
				end
				save('./TrainData','TrainData');
				clear TrainData;
			end
			
			load('TrainData');

			TrainData_Kern_cell = [TrainData * TrainData'];
			
			save('./TrainData_Kern_cell','TrainData_Kern_cell');
			clear TrainData_Kern_cell;

			if ~exist('TestData.mat','file') %'
		    	TestData = zeros(size(test_indx),49152);
			    for j = 1:size(test_indx)
					    featFile{j} = [fullfile(featDir_FV,sprintf('/wall/%d.mat',test_indx(j)))];
						fprintf('read in testing : %d \n',j);
					    temp = dlmread(featFile{j});
					    temp = sqrt(temp);
					    temp = normalizeL2(temp);

					    TestData(j,:) = temp(:,2:49153);
					    clear temp;
				end
				save('./TestData','TestData');
				clear TestData;
			end

			load('TestData');

			TestData_Kern_cell = [TestData * TrainData'];
			clear TrainData;
			clear TestData;
			save('./TestData_Kern_cell','TestData_Kern_cell');
			clear TestData_Kern_cell;
	end
	load ('TrainData_Kern_cell.mat');
	load ('TestData_Kern_cell.mat');

    for cl = 1 : size(classlabel,2)            
        trnLBLB = TrainClass(:,cl);
        testLBL = TestClass(:,cl);         
        ap_class(cl) = train_and_classify(TrainData_Kern_cell,TestData_Kern_cell,trnLBLB,testLBL);       
    end
    for cl = 1 : size(classlabel,2)
            fprintf('%s = %1.2f \n',actionName{cl},ap_class(cl));
    end
    fprintf('mean = %1.2f \n',mean(ap_class));
    save(resultFile,'ap_class');
end

function [ap ] = train_and_classify(TrainData_Kern,TestData_Kern,TrainClass,TestClass)
         nTrain = 1 : size(TrainData_Kern,1);
         TrainData_Kern = [nTrain' TrainData_Kern];         
         nTest = 1 : size(TestData_Kern,1);
         TestData_Kern = [nTest' TestData_Kern];
  		 C = [0.1 1 10 100 500 1000 ];
			for ci = 1 : numel(C)
			model(ci) = svmtrain(TrainClass, TrainData_Kern, sprintf('-t 4 -c %1.6f -v 2 -q ',C(ci)));               
		 end
		 [~,max_indx]=max(model);
		 model = svmtrain(TrainClass, TrainData_Kern, sprintf('-t 4 -c %1.6f  -q ',C(max_indx)));
         
         [~, acc, scores] = svmpredict(TestClass, TestData_Kern ,model);	                 
         [rc, pr, info] = vl_pr(TestClass, scores(:,1)) ; 
         ap = info.ap;
end

function X = normalizeL2(X)
	for i = 1 : size(X,1)
		if norm(X(i,:)) ~= 0
			X(i,:) = X(i,:) ./ norm(X(i,:));
		end
    end	   
end