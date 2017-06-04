function [wfeat_all] = getVideoDarwin(videoname,gmm,codebook,fv_dir,w_dir,descriptor_path, encode_method,fvhogdimension,fvhofdimension,fvmbhxdimension,fvmbhydimension)
    if ~exist(w_dir,'dir'), mkdir(w_dir), end
    [path, ~, ~]=fileparts(videoname{1});
    if ~exist(fullfile(w_dir,path),'dir')
        for i = 1 : numel(videoname)
            [path, ~, ~]=fileparts(videoname{i});
            if ~exist(fullfile(w_dir,path), 'dir')
                mkdir(fullfile(w_dir,path));
            end
        end
    end
    
    w_hog = zeros( numel(videoname),fvhogdimension*2);
    w_hof = zeros( numel(videoname),fvhofdimension*2);
    w_mbhx = zeros( numel(videoname),fvmbhxdimension*2);
    w_mbhy = zeros( numel(videoname),fvmbhydimension*2);

    for i = 1 : numel(videoname)
        savefile = fullfile(w_dir, sprintf('%s.mat',videoname{i}));
        fvfeatfile = fullfile(fv_dir, sprintf('%s.mat',videoname{i}));
        if ~exist(savefile, 'file')
            timest = tic();
            fvfeat = load (fvfeatfile);
            w_hog(i,:) = VideoDarwin(fvfeat.hog);
            w_hof(i,:) = VideoDarwin(fvfeat.hof);
            w_mbhx(i,:) = VideoDarwin(fvfeat.mbhx);
            w_mbhy(i,:) = VideoDarwin(fvfeat.mbhy);
            save_w(savefile,w_hog(i,:),w_hof(i,:),w_mbhx(i,:),w_mbhy(i,:));
            timest = toc(timest);
            fprintf('%d -> %s -->  %1.1f sec.\n',i,savefile,timest);
        else
            load(savefile);
            w_hog(i,:) = w_hog; 
            w_hof(i,:) = w_hof;
            w_mbhx(i,:) = w_mbhx; 
            w_mbhy(i,:) = w_mbhy;
            sprintf('%s exist!',savefile);
        end
    end

    wfeat_all = {w_hog, w_hof, w_mbhx, w_mbhy};
    save_all_w(sprintf('%s/w_hog.mat',w_dir),w_hog);
    save_all_w(sprintf('%s/w_hof.mat',w_dir),w_hof);
    save_all_w(sprintf('%s/w_mbhx.mat',w_dir),w_mbhx);
    save_all_w(sprintf('%s/w_mbhy.mat',w_dir),w_mbhy);

end

function save_w(savefile,w_hog, w_hof, w_mbhx, w_mbhy)
    save(savefile,'w_hog', 'w_hof', 'w_mbhx', 'w_mbhy');
end

function save_all_w(filepath,wfvecs)
   save(filepath,'wfvecs','-v7.3');
end