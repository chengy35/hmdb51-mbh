function dt = readIDTbin(file)
    index = [1,11,41,137,245,341;10,40,136,244,340,436];
    % max_desc = 100000;
    if exist(file, 'file')
        fid = fopen(file,'rb');
        temp = fread(fid, [index(2,end), inf],'single');
        fclose(fid);
        if ~isempty(temp)
            dt.info = temp(index(1,1):index(2,1),:);
            dt.trajectory = temp(index(1,2):index(2,2),:)';
            dt.hog = temp(index(1,3):index(2,3),:)';
            dt.hof = temp(index(1,4):index(2,4),:)';
            dt.mbhx = temp(index(1,5):index(2,5),:)';
            dt.mbhy = temp(index(1,6):index(2,6),:)';
        else
            fprintf([file, '----no trajectories!']);
            dt = [];
        end
    else
        dt = [];
        fprintf([file, 'file does not exist, please check!']);
    end
end