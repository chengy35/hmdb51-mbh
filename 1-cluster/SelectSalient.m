function [centers] =  SelectSalient(kmeans_size,totalnumber,fullvideoname,descriptor_path,vocabDir)
    sampleFeatFile = fullfile(vocabDir,'featfile.mat');
    modelFilePath = fullfile(vocabDir,'kmenasmodel.mat');
    if exist(modelFilePath,'file')
        load(modelFilePath);
        return;
    end
    start_index = 1;
    end_index = 1;
    if ~exist(sampleFeatFile,'file')
    	allAll = zeros(totalnumber,96*2);
	num_videos = size(fullvideoname,1);
             num_samples_per_vid = round(totalnumber / num_videos);
	for i = 1:num_videos       
	        timest = tic();        
	        [~,partfile,~] = fileparts(fullvideoname{i});
	        descriptorFile = fullfile(descriptor_path,sprintf('%s.mat',partfile));      
		if exist(descriptorFile,'file')
		        load(descriptorFile);
	             else
		      fprintf('%s not exist !!!',descriptorFile);
                                  [obj,trj,hog,hof,mbhx,mbhy] = extract_improvedfeatures(fullvideoname{i}) ;
                                  save(descriptorFile,'obj','trj','hog','hof','mbhx','mbhy'); 
		end
                            hog = sqrt(hog);hof = sqrt(hof);
                            mbhx = sqrt(mbhx);mbhy = sqrt(mbhy);
                            allf = [hog hof mbhx mbhy];
	        	rnsam = randperm(size(mbhx,1));
		if numel(rnsam) > num_samples_per_vid
		          rnsam = rnsam(1:num_samples_per_vid);
		end
	           end_index = start_index + numel(rnsam) - 1;
	           allAll(start_index:end_index,:) = [allf(rnsam,:)];
	           start_index = start_index + numel(rnsam);        
	           timest = toc(timest);
	           fprintf('%d/%d -> %s --> %1.2f sec\n',i,num_videos,fullvideoname{(i)},timest);  
    	end
    	if end_index ~= totalnumber
    		allAll(end_index+1:totalnumber,:) = [];
    	end
    	fprintf('start generating kmeans models\n');
       	fprintf('start saving descriptors\n');
        save(sampleFeatFile,'allAll');
     else
     	load(sampleFeatFile);  
    end
    % start to generating kmeans.
    numData = size(allAll,1);
    dimension = size(allAll,2);
    numClusters = kmeans_size;
    fprintf('%d\n', numData);
    [centers, ~] = vl_kmeans(allAll', kmeans_size, 'Initialization', 'plusplus') ; % need to transpose it...
    save(modelFilePath,'centers'); % remember it's size and dimension, take care of it.
end