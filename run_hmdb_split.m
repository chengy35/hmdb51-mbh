function des_accs = run_hmdb_split(varargin)
	%run_split:
	%    Example:
	%    descriptor: {'hog','hof','mbhx','mbhy'} or its subset.
	%    encode: choose one method from {'fv','svc','svc-k','svc-all','vlad','vlad-k','vlad-all','llc','sa-k','vq'}
	%    normalize: choose one method from {'Power-L2','Power-Intra-L2'}.
	addpath('~/lib/vlfeat/toolbox');
	vl_setup();
	setenv('LD_LIBRARY_PATH','/usr/local/lib/'); 
	addpath('~/lib/liblinear/matlab');
	addpath('~/lib/libsvm/matlab');
	addpath('~/lib/natsort');
	addpath('util')
	
	[split, descriptorType, encode_method, normalize_method, gmmSize, dataset] = parse_parameters(varargin{:});
	[videoname, classlabel,fv_dir, w_dir, vocab_dir, descriptor_path, video_dir, actions,tr_index] = getconfig(split, dataset);

	wfeat_path = fullfile(w_dir, sprintf('wfeat_all_split_%d.mat', split));
	if ~exist(feat_path,'file')
		addpath('./0-trajectory');
		extractIDT(video_dir,videoname,descriptor_path);
		addpath('./1-fv');
		fprintf('getGMM \n');
		[gmm,codebook] = getGMMAndBOW(split,videoname(tr_index==1),vocab_dir,descriptor_path, gmmSize);
		fprintf('generate Fisher Vectors \n');
		encodeVideos(videoname,gmm,codebook,fv_dir,descriptor_path, encode_method);
		fvhogdimension = size(gmm.pcamap.hog,2)*2*size(gmm.means.hog,2);
		fvhofdimension = size(gmm.pcamap.hof,2)*2*size(gmm.means.hof,2);
		fvmbhxdimension = size(gmm.pcamap.mbhx,2)*2*size(gmm.means.mbhx,2);
		fvmbhydimension =  size(gmm.pcamap.mbhy,2)*2*size(gmm.means.mbhy,2);
		wfeat_all = getVideoDarwin(videoname,gmm,codebook,fv_dir,w_dir,descriptor_path, encode_method,fvhogdimension,fvhofdimension,fvmbhxdimension,fvmbhydimension);
	 	save(wfeat_path,'wfeat_all','-v7.3');
	else
		load(wfeat_path);
	end

	addpath('./2-trainAndtest');
	des_accs = trainAndTest_normalizedL2_FV(descriptorType,tr_index,classlabel,encode_method,split,wfeat_all,gmmSize,normalize_method);
end