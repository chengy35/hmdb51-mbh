function getVideoDarwin(fullvideoname,featType,featDir,descriptor_path)
    if ~exist(fullfile(featDir,'wall'),'dir')
        mkdir(fullfile(featDir,'wall'));
    end
    for i = 1:length(fullvideoname) % 1-16 actions
            [~,partfile,~] = fileparts(fullvideoname{i});
            allfeatFile = fullfile(featDir,sprintf('/all/%d.mat',i));
            wFile = fullfile(featDir,'w',sprintf('%s.mat',partfile));  
            if exist(wFile,'file') == 2
                fprintf('%s exist! \n',wFile);
                continue;
            end
            fprintf('%s\n',allfeatFile);
            if exist(allfeatFile,'file') == 2
                timest = tic();
                data = dlmread(allfeatFile);
                w = VideoDarwin(data);
                dlmwrite(wFile,w');
                clear data;
                clear w;
                timest = toc(timest);
                fprintf('%d/%d -->%s----> %1.2f sec\n',i,length(fullvideoname),wFile,timest);
            end
    end
end
