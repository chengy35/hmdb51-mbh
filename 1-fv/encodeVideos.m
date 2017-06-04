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
    int hogdimension = size(gmm.pcamap.hog,2)*2*size(gmm.means.hog,2);
    int hofdimension = size(gmm.pcamap.hof,2)*2*size(gmm.means.hof,2);
    int mbhxdimension = size(gmm.pcamap.mbhx,2)*2*size(gmm.means.mbhx,2);
    int mbhydimension = size(gmm.pcamap.mbhy,2)*2*size(gmm.means.mbhy,2);
    
    for i = 1 : numel(videoname)
        timest = tic();
        savefile = fullfile(fv_dir, sprintf('%s.mat',videoname{i}));
        if ~exist(savefile, 'file')
            descriptorFile = fullfile(descriptor_path,sprintf('%s.mat',videoname{i}));
            videoObj = VideoReader(sprintf('%s%s.avi',video_dir,videoname{i}));
            frames = videoObj.NumberOfFrames;
            dt = load(descriptorFile);
            fv_hog = zeros( numel(frames),size(gmm.pcamap.hog,2)*2*size(gmm.means.hog,2));
            fv_hof = zeros( numel(frames),size(gmm.pcamap.hof,2)*2*size(gmm.means.hof,2));
            fv_mbhx = zeros( numel(frames),size(gmm.pcamap.mbhx,2)*2*size(gmm.means.mbhx,2));
            fv_mbhy = zeros( numel(frames),size(gmm.pcamap.mbhy,2)*2*size(gmm.means.mbhy,2));
            if ~isempty(dt)
                for frm = 1 : numel(frames)
                    frm_indx = find(obj(:,1)==frames(frm));            
                    fv_hog(frm,:) = getFisherVector(dt.hog,gmm.means.hog, gmm.covariances.hog, gmm.priors.hog,gmm.pcamap.hog,0.5,frm_indx);
                    fv_hof(frm,:) = getFisherVector(dt.hof,gmm.means.hof, gmm.covariances.hof, gmm.priors.hof,gmm.pcamap.hof,0.5,frm_indx);
                    fv_mbhx(frm,:) = getFisherVector(dt.mbhx,gmm.means.mbhx, gmm.covariances.mbhx, gmm.priors.mbhx,gmm.pcamap.mbhx,0.5,frm_indx);
                    fv_mbhy(frm,:) = getFisherVector(dt.mbhy,gmm.means.mbhy, gmm.covariances.mbhy, gmm.priors.mbhy,gmm.pcamap.mbhy,0.5,frm_indx);
                end
            else
                for i = 1 : numel(frames)
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

function h = getFisherVector(all, means, covariances, priors,pcamap,pcaFactor,frm_indx)  
    comps = pcamap(:,1:size(pcamap,1)*pcaFactor);
    h = vl_fisher((all(frm_indx,:)*comps)', means, covariances, priors);
end