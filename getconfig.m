function [videoname, classlabel,fv_dir, w_dir, vocab_dir, descriptor_path, video_dir,actions, tr_index] = getConfig(split, DATASET)
            fv_dir = ['~/remote/hmdb51Data/fv/feats', num2str(split)]; % Path where features will be saved
            w_dir = ['~/remote/hmdb51Data/w/feats', num2str(split)]; % Path where features will be saved
            vocab_dir = '~/remote/hmdb51Data/Vocab';
            descriptor_path = '~/remote/hmdb51Data/descriptor';
            video_dir = '~/remote/hmdb51';
            splitdir = '~/remote/hmdb51Data/testTrainMulti_7030_splits';
            [videoname, classlabel, tr_index, ~, ~, actions]= getHmdbSplit(split,splitdir);
end
