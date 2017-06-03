function trainAndTest_normalizedL2(video_dir,fullvideoname,featDir,encode)
    category = dir(video_dir);
    nClasses = 16;
    nCorrect = 0;
    nTotal = 0; 
    resultFile = ['./' encode '_result'];
    result = zeros(nClasses,nClasses);

    i=1;
	FileName = ['./2-trainAndtest/classLabel'];
	trainAndTestsplit = load(FileName);
	labels2 = zeros(size(trainAndTestsplit,1)-1,1);
	labels2(:,i) = trainAndTestsplit(2:size(trainAndTestsplit,1),2);
	fnames = trainAndTestsplit(2:size(trainAndTestsplit,1),1);
    trn_indx{1} = trainAndTestsplit(2:trainAndTestsplit(1,1)+1,1); 
    test_indx{1} = trainAndTestsplit(trainAndTestsplit(1,1)+2:size(trainAndTestsplit,1),1);
    classid = labels2;
    clear labels2;

    TrainClass = trainAndTestsplit(2:trainAndTestsplit(1,1)+1,2); 
    TestClass = trainAndTestsplit(trainAndTestsplit(1,1)+2:size(trainAndTestsplit,1),2);

 	if ~exist('TestData_Kern_cell.mat','file')
 		    if ~exist('TrainData.mat','file')
			   TrainData = zeros(size(trn_indx{1}),49152);
			   for j = 1:size(trn_indx{1})
					    featFile{j} = [fullfile(featDir,sprintf('/mbh/%d.mat',trn_indx{1}(j)))];
						fprintf('read in training: %d \n',j);
					    temp = dlmread(featFile{j});
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
		    	TestData = zeros(size(test_indx{1}),49152);
			    for j = 1:size(test_indx{1})
					    featFile{j} = [fullfile(featDir,sprintf('/mbh/%d.mat',test_indx{1}(j)))];
						fprintf('read in testing : %d \n',j);
					    temp = dlmread(featFile{j});
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
	nTrain = 1:size(TrainData_Kern_cell,1);
	trainData = [nTrain' TrainData_Kern_cell];       
	
	clear total;
	C = [0.1 1 10 100 500 1000 ];
    for ci = 1 : numel(C)
         model(ci) = svmtrain(TrainClass, trainData, sprintf('-t 4 -c %1.6f -v 2 -q ',C(ci)));               
    end
    [~,max_indx]=max(model);
    
    clear TrainData_Kern_cell;
    load ('TestData_Kern_cell.mat');
	nTest = 1:size(TestData_Kern_cell,1);
	testData = [nTest' TestData_Kern_cell]; %'
	
    C = C(max_indx);
		for ci = 1 : numel(C)
         model = svmtrain(TrainClass, trainData, sprintf('-t 4 -c %1.6f  -q ',C(ci)));
         [predicted_label{ci}, acc, scores{ci}] = svmpredict(TestClass, testData ,model);	                 
         accuracy(ci) = acc(1,1);
    end
    [acc,cindx] = max(accuracy); 
    best_predicted_label =  predicted_label{cindx};
    
   
	for i = 1: size(nTest,2)
		nTotal = nTotal + 1;
		if best_predicted_label(i) == TestClass(i)
			nCorrect = nCorrect + 1;
		end
		result(TestClass(i),best_predicted_label(i)) = result(TestClass(i),best_predicted_label(i))+1;
	end
	clear model;

	
	average_accuracy = 0;
	accura = [];
	for i = 1:nClasses
		nsequences = sum(result(i,:));
		if nsequences ~= 0
			average_accuracy = average_accuracy + result(i,i)/nsequences;
			accura(i) = result(i,i)/nsequences;
		end
	end
	average_accuracy = average_accuracy / nClasses;
	accuracy = nCorrect / nTotal;
	save(resultFile,'result','nTotal','average_accuracy','accuracy','accura');
	fprintf('average_accuracy is %f, and accuracy is %f, and nTotal is %d',average_accuracy,accuracy,nTotal);
end