clearvars
clc

%% Load example raw data info and functions into the workspace

% Add path for 'Functions'
addpath     'C:\Users\deher\Dropbox\switching_task_backup\Data_to_share\Example dataset\Functions';

% Define working folders
reg_folder_name = 'Registered';

folder          = 'C:\Users\deher\Dropbox\switching_task_backup\Data_to_share\Example dataset\D1_FOV10'; 
cd(folder)                                                                 % set current folder with unregistered images and reference image ('MED.tif').

mkdir(reg_folder_name)                                                     % create new folder 'Registered' to save registered images.     
folder_reg      = strcat (folder,'\',reg_folder_name);                     % define new folder name for registered images
responses.example = 55;                                                    % define example trial/roi for plots
save("responses.mat","responses");                                         % save struct to save and load information through the pipeline

% Load info of all trial t-stacks in the example folder
data = dir('*Gr.tif');                                                     

% Load info median "Z-projection' tiff file created using imageJ
ref_reg  = dir('MED.tif');                                                 % Image created using a stable "mid-session" trial and a range of stable frames in that trial.
                                                                           % Current example: trial 134, all frames (1 to 100)

%% Trial by trial registration

image_ref   = imread(strcat(ref_reg.folder,'\',ref_reg.name));             % Load reference image into workspace
reg_range   = 100;                                                         % Set range for x/y pixel movement displacement 

% Trial by trial registration
for nFile = 1:length(data)

    file_to_read    = data(nFile).name;                                    % Get trial name
    image_raw       = tiffreadVolume(file_to_read);                        % Load trial time-stack into workspace 
    masked_filename = ['Trial_' num2str(nFile,'%03d') '_.tif'];            % Define name to save new file 
    
    % Run registration function
    image_masked = trial_registration_20240816(image_ref, image_raw, reg_range);

    % Save images in new folder with registered images
    save_tiff_20240818(folder_reg, image_masked, masked_filename);

    cd(folder)

    disp(num2str(nFile));
end

%% Registration example

clearvars -except folder folder_reg responses

example = responses.example;

cd(folder)
data_unreg      = dir('*Gr.tif');                                          % Get info unregistered data
file_to_read    = data_unreg(example).name;                                % Ger name picked unregistered trial 
image_raw       = tiffreadVolume(file_to_read);                            % Read picked unregistered trial

cd(folder_reg)                                                       
data_reg        = dir('*_.tif');                                           % Get info registered data
file_to_read    = data_reg(example).name;                                  % Get name picked registered trial
image_reg       = tiffreadVolume(file_to_read);                            % Read picked registered trial

% Show videos of unregistered and registered example trial
implay(image_raw);
implay(image_reg);

%% Load ROIs 

close all
clearvars -except folder folder_reg responses
cd(folder)

ref_roi     = dir('MED_ROI.tif');                                          % Get info reference ROI image used to draw ROIs in ImageJ
image_roi   = imread(strcat(folder,'\',ref_roi.name));                     % Load matrix of reference ROI image
roi_set     = ReadImageJROI('RoiSet.zip');                                 % Get ROI data from ImageJ ROI manager
num_roi     = length(roi_set);                                             % Number of ROIs   

cd(folder_reg)  
data_reg    = dir('*_.tif');                                               % Get info of registered trials

[ROI,f1] = roi_info_20240817(roi_set,image_roi,num_roi);                   % ROI information and ROI plotting

responses.ROI = ROI;

cd(folder)
save("responses.mat","responses"); 

%% Movement correction

close all
clearvars -except folder folder_reg responses

cd(folder)
roi_set     = ReadImageJROI('RoiSet.zip');
num_roi     = size(roi_set,2);

cd(folder_reg)
data_reg    = dir('*_.tif');
num_files   = length(data_reg); 

ROI         = responses.ROI;

% Generate idx to identify frames with excesive motion artifacts
responses   = movement_correction_20240817(data_reg,num_files,ROI,num_roi,responses);

cd(folder)
save("responses.mat","responses"); 

%% ROI data extraction and removal of frames afected by motion artifacts

clearvars -except folder folder_reg responses

cd(folder)

roi_set     = ReadImageJROI('RoiSet.zip');
num_roi     = size(roi_set,2);
roi_means   = readroi_20240817(folder_reg,roi_set);
num_files   = size(roi_means,2);
example     = responses.example;

% Generate matrix with fluorescence data for each ROI and assign frames
% with excesive motion artifacts == NaN

roi_data = data_extraction_20240817(roi_means,num_roi,num_files,responses);

responses.framerate                 = 60.57;                               % ms per frame 
responses.raw                       = roi_data;

test_1      = squeeze(roi_data(:,example,:));
test_2      = squeeze(roi_data(:,:,example));

f2 = figure(2);
    subplot(1,3,1);
        imagesc(mean(roi_data,3,'omitnan')');
            xlabel('Frames');
            ylabel('ROI #');
            title('Average ROI fluorescence');
    subplot(1,3,2);
        imagesc(test_1');
            xlabel('Frames');
            ylabel('Trial #');    
            title(strcat('ROI #',num2str(example),{' '},'across trials'));
    subplot(1,3,3);
        imagesc(test_2');
            xlabel('Frames');
            ylabel('ROI #');
            title(strcat('Trial #',num2str(example)));

f2.Position = [200 400 1500 400];

cd(folder)
save("responses.mat","responses"); 

%% Trial and ROI rejection

clearvars -except folder folder_reg responses 

cd(folder)

tr_fil_min  = 70;                                                          % Trials that have less than this percentage of possible data will be tossed
max_nan_win = 15;                                                          % Trials and Roi's that have contiguous loss greater than this will be tossed

all_raw = responses.raw;

[tr_info, ro_info]          = parse_2024017(all_raw);
[all_ROIrej, responses]     = toss_2024017(all_raw, responses, ... 
                                           ro_info, tr_info, ...
                                           tr_fil_min, max_nan_win);

responses.rej_roi = all_ROIrej;

example     = 55;
test_1      = squeeze(all_ROIrej(:,example,:));
test_2      = squeeze(all_ROIrej(:,:,example));

f3 = figure(3);
    subplot(1,3,1);
        imagesc(mean(all_ROIrej,3,'omitnan')');
            xlabel('Frames');
            ylabel('ROI #');
            title('Average ROI fluorescence');
    subplot(1,3,2);
        imagesc(test_1');
            xlabel('Frames');
            ylabel('Trial #');    
            title(strcat('ROI #',num2str(example),{' '},'across trials'));
    subplot(1,3,3);
        imagesc(test_2');
            xlabel('Frames');
            ylabel('ROI #');
            title(strcat('Trial #',num2str(example)));

f3.Position = [200 400 1500 400];

cd(folder)
save("responses.mat","responses"); 

%% Interpolate NaNs

clearvars -except folder folder_reg responses

all_ROIrej  = responses.rej_roi;

thres_aki   = 6;                                                           % If the nan window (per roi, per trial) is smaller than this, akima interpolation is used)
thres_lin   = 1;                                                           % If the window is longer than thres aki, linear or step interpolation is used;
                                                                           % the smaller this value is, the more likely it is that we use step
nanlpt      = prep_int(all_ROIrej);

all_interp  = interpolate_nan_20240817(all_ROIrej, nanlpt, thres_aki, thres_lin);
responses.interpolated = all_interp;

example     = 55;
test_1      = squeeze(all_interp(:,example,:));
test_2      = squeeze(all_interp(:,:,example));

f4 = figure(4);
    subplot(1,3,1);
        imagesc(mean(all_interp ,3,'omitnan')');
            xlabel('Frames');
            ylabel('ROI #');
            title('Average ROI fluorescence');
    subplot(1,3,2);
        imagesc(test_1');
            xlabel('Frames');
            ylabel('Trial #');    
            title(strcat('ROI #',num2str(example),{' '},'across trials'));
    subplot(1,3,3);
        imagesc(test_2');
            xlabel('Frames');
            ylabel('ROI #');
            title(strcat('Trial #',num2str(example)));

f4.Position = [200 400 1500 400];

cd(folder)
save("responses.mat","responses"); 

%% Remove exponential trend

clearvars -except folder folder_reg responses

cd(folder)

load("stamps.mat");

stim_delivery       = stamps.stimulus_delivery_raw;
earliest_stim       = min(stim_delivery);

all_raw    = responses.raw;
all_interp = responses.interpolated;

[all_det, gof]  = exp_remove_bychan_20240817(all_interp, earliest_stim);       

responses.detrended = all_det;

f5 = figure(5);
    subplot(1,2,1);
        imagesc(mean(all_raw,3,'omitnan')');
            xlabel('Frames');
            ylabel('ROI #');
            title('Raw');
    subplot(1,2,2);
        imagesc(mean(all_det,3,'omitnan')');
            xlabel('Frames');
            ylabel('ROI #');
            title('Detrended');

f5.Position = [400 400 1100 400];

cd(folder)
save("responses.mat","responses"); 

%% z-score quantification

clearvars -except folder folder_reg responses

cd(folder)

load("stamps.mat");

stim_delivery       = stamps.stimulus_delivery_raw;

all_det = responses.detrended;

all_zscore = zscore_20240817(stim_delivery,all_det);

responses.zscore = all_zscore;

range_1    = [-500 1500];
range_2    = [-1 2];

f6 = figure(6);
    subplot(1,2,1);
        imagesc(mean(all_det,3,'omitnan')',range_1);
            xlabel('Frames');
            ylabel('ROI #');
            title('Detrended');
            colorbar;
    subplot(1,2,2);
        imagesc(mean(all_zscore,3,'omitnan')',range_2);
            xlabel('Frames');
            ylabel('ROI #');
            title('z-score');
            colorbar;

f6.Position = [400 400 1100 400];

cd(folder)
save("responses.mat","responses"); 

%% Align to stimulus

clearvars -except folder folder_reg responses
cd(folder)

load("stamps.mat");

stim_delivery       = stamps.stimulus_delivery_raw;

all_zscore = responses.zscore;

[aligned_raw,aligned_det,aligned_zscore] = align_20240817(stim_delivery,responses);
    
responses.aligned_raw    = aligned_raw;
responses.aligned_det    = aligned_det;
responses.aligned_zscore = aligned_zscore;

range   = [-1 2];

f7 = figure(7);
    subplot(1,2,1);
        imagesc(mean(all_zscore,3,'omitnan')',range);
            xlabel('Frames');
            ylabel('ROI #');
            title('non-aligned z-score');
            colorbar;
    subplot(1,2,2);
        imagesc(mean(aligned_zscore,3,'omitnan')',range);
            xlabel('Frames');
            ylabel('ROI #');
            title('aligned z-score');
            colorbar;

f7.Position = [400 400 1100 400];

cd(folder)
save("responses.mat","responses"); 

  
