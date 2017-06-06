clear;
clc;

des_accs = [];
for s = 2:3
        % TODO: change some paths in run_split function
        split_accs = run_hmdb_split('split',s, 'dataset', 'hmdb51');
        des_accs = [des_accs, split_accs];
end
des_accs = [des_accs, mean(des_accs,2)]  
