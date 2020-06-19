% process ground truth pin locations from stylus-based tracker data

% restart
close all; clear; clc;

% tool tip definition
tipPosLocal = readmatrix('..\ndi-polaris-tracker\tool-defs\medtronic_fromdata_2.tip','FileType','text');

% define data file
dataFile = 'C:\Users\f002r5k\Dropbox\projects\surg_nav\stereo\20200613-stereo-setup\pin_target_mapping_001.csv';

% set colors
colors = [0 0 0.8; 0 0.8 0];
colorIdx = [1,2,1,1,2,2,2,1,1,2,2,2,2,1,1,1,1];

% load data
fid = fopen(dataFile);
allData = textscan(fid,'%f %u %c %f %f %f %f %f %f %f %*f %s','Delimiter',',');
fclose(fid);
time = allData{1};
toolID = allData{3};
Q = [allData{4:7}];
T = [allData{8:10}];
trackLabel = str2double(allData{11});
uniqueLabels = unique(trackLabel,'sorted');

% data storage;
allSphereParams = zeros(size(uniqueLabels,1),5);

%%
% start figure;
figure;
hold on; grid on; axis equal;

for pinLabelIdx = 1:size(uniqueLabels,1)
    pinIdx = uniqueLabels(pinLabelIdx);
    thisColor = colors(colorIdx(pinIdx),:);
    thisT = T(trackLabel == pinIdx,:);
    thisQ = Q(trackLabel == pinIdx,:);

    tipPoints = zeros(size(thisT));
    
    % iterate through all points for this marker / label combo
    for ptIdx = 1:size(thisT,1)
        tipPoints(ptIdx,:) = thisT(ptIdx,:) + quatrotate(thisQ(ptIdx,:)',tipPosLocal')';
    end
        
    % plot with correct color
    plot3(tipPoints(:,1),tipPoints(:,2),tipPoints(:,3),'.','MarkerSize',20,'Color',thisColor);
    
    % fit sphere
    [sphereParams,rmse] = fitSphere(tipPoints);
    allSphereParams(pinLabelIdx,:) = [sphereParams',rmse];
    
end

plot3(allSphereParams(:,1),allSphereParams(:,2),allSphereParams(:,3),'.','MarkerSize',30','Color',[0.8 0 0]);