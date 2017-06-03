function llcEncodeFeatures(centers,fullvideoname,descriptor_path,featDir,class_category,video_dir)
    category = dir(video_dir);
    pyramid = [1, 2, 4];                % spatial block structure for the SPM               
    knn = 5;                            % number of neighbors for local coding
    index = 0;
    for i = 1:length(fullvideoname)
    	[~,partfile,~] = fileparts(fullvideoname{i});
            descriptorFile = fullfile(descriptor_path,sprintf('%s.mat',partfile));  
	if exist(descriptorFile,'file') == 2 
		allfeatFile = fullfile(featDir,sprintf('/all/%d.mat',i));
		if exist(allfeatFile,'file') == 0
			timest = tic();
			index = index + 1;
			load(descriptorFile);
			hog = sqrt(hog);hof = sqrt(hof);
			mbhx = sqrt(mbhx);mbhy = sqrt(mbhy);
			all = [hog hof mbhx , mbhy];
			feaSet.feaArr = all';
			feaSet.x = obj(:,2);
			feaSet.y = obj(:,3); 
			video_name = fullvideoname{index};
			videoObj = VideoReader(video_name);
			feaSet.width = videoObj.Width;
			feaSet.height = videoObj.Height;
			fea = LLC_pooling(feaSet, centers, pyramid, knn); % get unnderstand of LLC_pooling
			dlmwrite(allfeatFile,fea');
			timest = toc(timest);
			fprintf('%d/%d->%s--> %1.2f sec\n',i,length(fullvideoname),allfeatFile,timest);		
		else
			fprintf('%d/%d %s exists! \n',index,length(fullvideoname),allfeatFile);
		end
	end
    end
end