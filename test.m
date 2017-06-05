addpath('~/lib/vlfeat/toolbox');
vl_setup();
setenv('LD_LIBRARY_PATH','/usr/local/lib/'); 
addpath('~/lib/liblinear/matlab');
addpath('~/lib/libsvm/matlab');
addpath('~/lib/natsort');
addpath('util')

[split, descriptorType, encode_method, normalize_method, gmmSize, dataset] = parse_parameters('split',1, 'dataset', 'hmdb51');
[videoname, classlabel,fv_dir, w_dir, vocab_dir, descriptor_path, video_dir, actions,tr_index] = getconfig(split, dataset);

wfeat_path = fullfile(w_dir, sprintf('wfeat_all_split_%d.mat', split));


addpath('./0-trajectory');
%extractIDT(video_dir,videoname,descriptor_path);
addpath('./1-fv');
fprintf('getGMM \n');
[gmm,codebook] = getGMMAndBOW(split,videoname(tr_index==1),vocab_dir,descriptor_path, gmmSize);
fprintf('generate Fisher Vectors \n');



if ~exist(fv_dir,'dir'), mkdir(fv_dir), end
    [path, ~, ~]=fileparts(videoname{1});
    if ~exist(fullfile(fv_dir,path),'dir')
        for i = 1 : numel(videoname)
            [path, ~, ~]=fileparts(videoname{i});
            if ~exist(fullfile(fv_dir,path), 'dir')
                mkdir(fullfile(fv_dir,path));
            end
        end
    end
    int hogdimension = size(gmm.pcamap.hog,2)*2*size(gmm.means.hog,2);
    int hofdimension = size(gmm.pcamap.hof,2)*2*size(gmm.means.hof,2);
    int mbhxdimension = size(gmm.pcamap.mbhx,2)*2*size(gmm.means.mbhx,2);
    int mbhydimension = size(gmm.pcamap.mbhy,2)*2*size(gmm.means.mbhy,2);
 i = 1;
descriptorFile = fullfile(descriptor_path,sprintf('%s.mat',videoname{i}));
videoObj = VideoReader(sprintf('%s/%s.avi',video_dir,videoname{i}));



encodeVideos(videoname,gmm,codebook,fv_dir,descriptor_path, encode_method);
fvhogdimension = size(gmm.pcamap.hog,2)*2*size(gmm.means.hog,2);
fvhofdimension = size(gmm.pcamap.hof,2)*2*size(gmm.means.hof,2);
fvmbhxdimension = size(gmm.pcamap.mbhx,2)*2*size(gmm.means.mbhx,2);
fvmbhydimension =  size(gmm.pcamap.mbhy,2)*2*size(gmm.means.mbhy,2);


