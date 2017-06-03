function des_accs = run_hmdb_split(split)
%run_split:
%    Example:
%    descriptor: {'hog','hof','mbhx','mbhy'} or its subset.
%    encode: choose one method from {'fv','svc','svc-k','svc-all','vlad','vlad-k','vlad-all','llc','sa-k','vq'}
%    normalize: choose one method from {'Power-L2','Power-Intra-L2'}.

    gmmSize = 256;
    normalize_method = 'Power-Intra-L2';
    encode_method = 'fv';
    dataset = 'hmdb51';
    descriptorType = {'mbhx', 'mbhy'};
    [videoname, classlabel,fv_dir, vocab_dir, descriptor_path, video_dir, actions,tr_index] = getconfig(split);
    
    addpath('./0-trajectory');
    extractIDT(video_dir,videoname,descriptor_path);

    feat_path = fullfile(fv_dir, sprintf('feat_all_split_%d.mat', split));
    if ~exist(feat_path,'file')
        addpath('./1-fv');
        fprintf('getGMM \n');
        [gmm,codebook] = getGMMAndBOW(split,videoname(tr_index==1),vocab_dir,descriptor_path, gmmSize);
        fprintf('generate Fisher Vectors \n');
        feat_all = encodeVideos(videoname,gmm,codebook,fv_dir,descriptor_path, encode_method);
        %FVEncodeFeatures_w(fullvideoname,gmm,vocabDir,st,send,featDir_FV,descriptor_path);
        save(feat_path,'feat_all','-v7.3');    
    else
        load(feat_path);
    end

%    feat_path = fullfile(fv_dir, sprintf('feat_wall_split_%d.mat', split));
%   if ~exist(feat_path,'file')
%        fprintf('generate videodarwin Vectors \n');
%        feat_wall = getVideoDarwin(fullvideoname,featType,featDir_FV,descriptor_path);
%        save(feat_path,'feat_wall','-v7.3');    
%    else
%       load(feat_path);
%    end

    addpath('2-trainAndtest');
  des_accs =   trainAndTest_normalizedL2_FV(descriptorType,tr_index,classlabel,encode_method,split,feat_all,gmmSize);
end