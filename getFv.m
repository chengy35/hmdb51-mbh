function h = getFv(descr,means, covariances, priors,pcamap,pcaFactor,indx)  
    comps = pcamap(:,1:size(pcamap,1)*pcaFactor);
    h = vl_fisher( (descr(indx,:)*comps)', means, covariances, priors);
end
