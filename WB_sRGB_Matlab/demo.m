%% Demo: White balancing a single image
%
% Copyright (c) 2018-present, Mahmoud Afifi
% York University, Canada
% mafifi@eecs.yorku.ca | m.3afifi@gmail.com
%
% This source code is licensed under the license found in the
% LICENSE file in the root directory of this source tree.
% All rights reserved.
%
% Please cite the following work if this program is used:
% Mahmoud Afifi, Brian Price, Scott Cohen, and Michael S. Brown,
% "When color constancy goes wrong: Correcting improperly white-balanced
% images", CVPR 2019.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

%% input and options
infileName = fullfile('..','example_images','figure3.jpg');
outfileName = fullfile('result.jpg');
device = 'cpu'; % 'cpu' or 'gpu'
gamut_mapping = 2; % use 1 for scaling, 2 for clipping (our paper's results reported using clipping).
upgraded_model = 1; % use 1 to load our new model that is upgraded with new training examples.


%% 
switch lower(device)
    case 'cpu'
        if upgraded_model == 1
            load(fullfile('models','WB_model+.mat'));
        elseif upgraded_model == 0
            load(fullfile('models','WB_model.mat'));
        else
            error('Wrong upgraded_model value; please use 0 or 1');
        end
    case 'gpu'
        try
            gpuDevice();
        catch
            error('Cannot find a GPU device');
        end
        if upgraded_model == 1
            load(fullfile('models','WB_model+_gpu.mat'));
        elseif upgraded_model == 0
            load(fullfile('models','WB_model_gpu.mat'));
        else
            error('Wrong upgraded_model value; please use 0 or 1');
        end
    otherwise
        error('Wrong device; please use ''gpu'' or ''cpu''')
end
model.gamut_mapping = gamut_mapping;
fprintf('Processing image: %s\n',infileName);
I_in = imread(infileName);
tic
I_corr = model.correctImage(I_in);
disp('Done!');
toc
subplot(1,2,1); imshow(I_in); title('Input');
subplot(1,2,2); imshow(I_corr); title('Our result');
disp('Saving...');
if strcmpi(device,'cpu')
    imwrite(I_corr,outfileName);
else
    imwrite(gather(I_corr),outfileName);
end
disp('Saved!');