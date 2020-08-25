%% Computer Vision Challenge 2019

% Group number:
group_number = 29;

% Group members:
members = {'Kevin Rexhepi', 'Jens Ernstberger','Ghassen Laajailia','Achraf Friaa', 'Lida Kostis'};

% Email-Address (from Moodle!):
mail = {'ga42fuh@mytum.de','ga59taj@mytum.de','ga78duc@mytum.de','ga65vow@mytum.de','ga97paf@mytum.de'};


 %% Start timer here
timer = tic;

%% Disparity Map
% Specify path to scene folder containing img0 img1 and calib
scene_path = '../playground';

% Calculate disparity map and Euclidean motion
[D, R, T] = disparity_map(scene_path);

%% Validation

% Specify path to ground truth disparity map
% gt_path = 'paht\to\ground\truth'
ground_path = strcat(scene_path,'/disp0.pfm');
% Load the ground truth
G = readpfm(ground_path);
% 
% Estimate the quality of the calculated disparity map
p = verify_dmap(D, G);

%% Stop timer here
elapsed_time = toc(timer);

%% Print Results
R, T, p, elapsed_time
disp('Rotationsmatrix R') ;
disp(R) ; 
disp('------------------') ;
disp('Translation T') ;
disp(T) ; 
disp('------------------');
disp('Peak-Signal-to-Noise-Ratio') ;
disp(p) ;
disp('------------------');
disp('elapsed_time') ;
disp(elapsed_time) ; 
disp('------------------');



%% Display Disparity
clf;
image(D);
% Configure the axes to properly display an image.
axis image;
% Use the 'jet' color map.
colormap('jet');
% Display the color map legend.
colorbar;
caxis([0 255]);
    


