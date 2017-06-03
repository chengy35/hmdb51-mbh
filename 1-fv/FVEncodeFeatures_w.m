function FVEncodeFeatures_w(fullvideoname,gmm,vocab,st,send,featDir,descriptor_path)
        pcaFactor = 0.5;
        if ~exist(fullfile(featDir),'dir')
        	mkdir(fullfile(featDir));
        end
        if ~exist(fullfile(sprintf('%s/all',featDir),'dir'))
        	mkdir(fullfile(sprintf('%s/all',featDir)));
        end
    for i = st : min(size(fullvideoname,1),send)   
        [~,partfile,~] = fileparts(fullvideoname{i});
        file = fullfile(featDir,sprintf('all/%d.mat',i));         
        descriptorFile = fullfile(descriptor_path,sprintf('%s.mat',partfile));
        if exist(file,'file')
			fprintf('%d --> %s Exists \n',i,file);            
            continue;
        end
        load (descriptorFile);
		timest = tic();
		fprintf('Processing Video file %s\n',partfile);
		hog = sqrt(hog);
		hof = sqrt(hof);
        mbhx = sqrt(mbhx);mbhy = sqrt(mbhy);
		all = [hog hof mbhx mbhy];
        frames = unique(obj(:,1));
        fv_all = zeros( numel(frames),pcaFactor*size(gmm.pcamap.all,1)*2*size(gmm.means.all,2));
        for frm = 1 : numel(frames)
            frm_indx = find(obj(:,1)==frames(frm));            
            fv_all(frm,:) = getFisherVector(all,gmm.means.all, gmm.covariances.all, gmm.priors.all,gmm.pcamap.all,pcaFactor,frm_indx);
        end
        file = fullfile(featDir,sprintf('/all/%d.mat',i));
        dlmwrite(file,fv_all);
        timest = toc(timest);
        fprintf('%d--> %s done --> time  %1.1f sec \n',i,file,timest);
    end
end

function h = getFisherVector(all, means, covariances, priors,pcamap,pcaFactor,frm_indx)  
    comps = pcamap(:,1:size(pcamap,1)*pcaFactor);
    h = vl_fisher((all(frm_indx,:)*comps)', means, covariances, priors);
end
