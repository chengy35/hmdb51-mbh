function  encodeVideos(videoname,gmm,codebook,fv_dir,descriptor_path, encode,video_dir)

%ENCODEVIDEOS:   encode all video IDT features with 'encode' method.
% For simplity, we only integrate Fisher vector method here
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
    
    hogdimension = size(gmm.pcamap.hog,2)*2*size(gmm.means.hog,2);
    hofdimension = size(gmm.pcamap.hof,2)*2*size(gmm.means.hof,2);
    mbhxdimension = size(gmm.pcamap.mbhx,2)*2*size(gmm.means.mbhx,2);
    mbhydimension = size(gmm.pcamap.mbhy,2)*2*size(gmm.means.mbhy,2);
    
    for i = 1 :  numel(videoname)
        timest = tic();
        savefile = fullfile(fv_dir, sprintf('%s.mat',videoname{i}));
        if ~exist(savefile, 'file')
            descriptorFile = fullfile(descriptor_path,sprintf('%s.mat',videoname{i}));
            dt = load(descriptorFile);
            if ~isempty(dt)
                frames = unique(dt.obj(:,1));
                fv_hog = zeros( numel(frames),hogdimension);
                fv_hof = zeros( numel(frames),hofdimension);
                fv_mbhx = zeros( numel(frames),mbhxdimension);
                fv_mbhy = zeros( numel(frames),mbhydimension);
                for frm = 1 : numel(frames)
                    frm_indx = find(dt.obj(:,1)==frames(frm));
                    fv_hog(frm,:) = vl_fisher( (bsxfun(@minus,dt.hog(frm_indx,:),gmm.centre.hog)*gmm.pcamap.hog)', gmm.means.hog, gmm.covariances.hog, gmm.priors.hog);
                    fv_hof(frm,:) = vl_fisher( (bsxfun(@minus,dt.hof(frm_indx,:),gmm.centre.hof)*gmm.pcamap.hof)', gmm.means.hof, gmm.covariances.hof, gmm.priors.hof);
                    fv_mbhx(frm,:) = vl_fisher( (bsxfun(@minus,dt.mbhx(frm_indx,:),gmm.centre.mbhx)*gmm.pcamap.mbhx)', gmm.means.mbhx, gmm.covariances.mbhx, gmm.priors.mbhx);
                    fv_mbhy(frm,:) = vl_fisher( (bsxfun(@minus,dt.mbhy(frm_indx,:),gmm.centre.mbhy)*gmm.pcamap.mbhy)', gmm.means.mbhy, gmm.covariances.mbhy, gmm.priors.mbhy);
                end
            else
                videoObj = VideoReader(sprintf('%s/%s.avi',video_dir,videoname{i}));
                frames = videoObj.NumberOfFrames;
                fv_hog = zeros( frames,hogdimension);
                fv_hof = zeros( frames,hofdimension);
                fv_mbhx = zeros( frames,mbhxdimension);
                fv_mbhy = zeros( frames,mbhydimension);
                for i = 1 : frames
                    fv_hog(i,:) = 1/hogdimension;
                    fv_hof(i,:) = 1/hofdimension;
                    fv_mbhx(i,:) = 1/mbhxdimension;
                    fv_mbhy(i,:) = 1/mbhydimension;
                end
            end
            save_fv(savefile, fv_hog, fv_hof, fv_mbhx, fv_mbhy);
        else
              sprintf('%s exist!',savefile);
        end
        timest = toc(timest);
        fprintf('%d -> %s -->  %1.1f sec.\n',i,videoname{i},timest);
    end
end

function save_fv(filepath,fvec_hog, fvec_hof, fvec_mbhx, fvec_mbhy)
   save(filepath,'fvec_hog', 'fvec_hof', 'fvec_mbhx', 'fvec_mbhy');
end