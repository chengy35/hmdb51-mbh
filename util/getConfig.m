function [videoname, classlabel,fv_dir, vocab_dir, descriptor_path, video_dir,actions, tr_index] = getConfig(split)
            fv_dir = ['~/remote/hmdb51Data/descriptor', num2str(split)]; % Path where features will be saved
            vocab_dir = '~/remote/hmdb51Data/Vocab';
            descriptor_path = '~/remote/hmdb51Data/descriptor';
            video_dir = '~/remote/hmdb51';
            splitdir = '~/remote/hmdb51Data/testTrainMulti_7030_splits';
            [videoname, classlabel, tr_index, ~, ~, actions]= getHmdbSplit(split,splitdir);    
end
