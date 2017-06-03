clear;
clc;
% TODO Add paths
addpath('~/lib/vlfeat/toolbox');
vl_setup();
setenv('LD_LIBRARY_PATH','/usr/local/lib/'); 
addpath('~/lib/liblinear/matlab');
addpath('~/lib/libsvm/matlab');
addpath('~/lib/natsort');
addpath('~/lib/chol_incomplete/');
addpath('/usr/local/MATLAB/extern/lib/essential/');
addpath('~/lib/exact_alm_rpca/');


addpath('util')
addpath(genpath('mex'))
addpath('~/lib/vlfeat/toolbox');
vl_setup();
addpath('~/lib/spams-matlab/build');
setenv('LD_LIBRARY_PATH','/usr/local/lib/'); 
addpath('~/lib/liblinear/matlab');
addpath('~/lib/libsvm/matlab');
addpath(genpath('~/lib/lightspeed'));
addpath('~/lib/natsort');
des_accs = [];
for s = 1:3
        % TODO: change some paths in run_split function
        split_accs = run_hmdb_split('split',s,'descriptor',{'mbhx','mbhy'}, 'encode', 'fv', 'gmmSize', 256, 'normalize', 'Power-Intra-L2', 'dataset', 'hmdb51');
        des_accs = [des_accs, split_accs];
end
des_accs = [des_accs, mean(des_accs,2)]  

