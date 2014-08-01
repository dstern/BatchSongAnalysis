%Batch Fly Song Analysis

function BatchFlySongAnalysis(daq_file,genotypes,recording_channels,control_genotypes,LLR_threshold)

% USAGE
%
%
% daq_file: full path and name of daq file (time stamp) that was previously 
% segmented with FlySongSegmenterDAQ (e.g. "20110510132426.daq"). If no path 
% defined, then file assumed to reside in current folder
%
% genotypes: cell array of genotype names (e.g. {'strain1' 'wild_type'})
%
% recording_channels: cell array containing numeric arrays that indicate
% how to group genotypes (e.g. {[1 10] [11 18]}). If empty (i.e. {}), then
% all channels (or all files in folder) are same genotype.
%
% control_genotype: genotype name of control genotype. Must be one or more 
% of the names specified in "genotypes". If multiple, enter cell array
% *e.g. {'wild_type' 'other_wild_type'}. If no controls, use {}.
%
% LLR_threshold = can be set by user. Usually want to run twice, once at 50
% and once at 0

if nargin < 5
    LLR_threshold = 0;
end


num_genotypes = numel(genotypes);

%check to confirm # genotypes == number grouops of recording_channels
if num_genotypes ~= numel(recording_channels) && ~isempty(recording_channels);
    error('myApp:argChk','Analysis stopped.\nThe number of genotypes must equal the number of recording channel groups.');
end

%check if _out file exists
[path2daq,daq_root,~] = fileparts(daq_file);
folder = [path2daq '/' daq_root '_out/'];
hyg_file = [path2daq '/' daq_root '.hyg'];
if ~isdir(folder)
    error('myApp:argChk','Analysis stopped.\nFolder with segmented song does not exist.');
end

%check if control_genotype is one of genotypes
% if sum(ismember(genotypes,control_genotypes)) == 0
%     error('myApp:argChk','Analysis stopped.\nControl genotype does not match possible genotypes.');
% end
% 
[poolavail,isOpen] = check_open_pool;

%establish Results folder 
timestamp = datestr(now,'yyyymmddHHMMSS');
results_folder = [daq_root '_Results_LLR=' num2str(LLR_threshold) '_' timestamp];
mkdir([path2daq '/' results_folder]);

%get _out folder info
dir_list = dir(folder);

if ~isempty(recording_channels)
    %make full list of all recording channels and genotypes
    for i = 1:num_genotypes
        start = recording_channels{i}(1);
        finish = recording_channels{i}(2);
        genotype = cellstr(genotypes{i});
        
        %send each analysis job to separate cluster processor
        parfor y = start:finish
            %for y = start:finish
            file = ['PS_' daq_root '_ch' num2str(y) '.mat'];
            [~,root,ext] = fileparts(file);
            path_file = [folder file];
            fprintf(['Analyzing file ' root '\n'])
            
            if exist(path_file, 'file') == 2
                [Analysis_Results,~] = AnalyzeChannel(path_file,LLR_threshold,hyg_file);
                
                if sum(ismember(control_genotypes,genotype)) == 0
                    result_path = strcat(path2daq, '/', results_folder, '/', root, '_', genotype, '_', timestamp, '.mat');
                else
                    result_path = strcat(path2daq, '/', results_folder, '/', root, '_', genotype, '_control_', timestamp, '.mat');
                end
                my_save(result_path{1},Analysis_Results);
            end
        end
    end
else %only one genotype in folder and folder may contain many recordings
    genotype = cellstr(genotypes{1});
    for i = 1:numel(dir_list)
        [~,root,ext] = fileparts(dir_list(i).name);
        if strcmp(ext,'.mat')
            fprintf(['Analyzing file ' dir_list(i).name '\n'])
            path_file = [daq_file '_out' '/' dir_list(i).name];
            [Analysis_Results,~] = AnalyzeChannel(path_file,LLR_threshold);%,hyg_file);
            result_path = strcat(path2daq, '/', results_folder, '/', root, '_', genotype, '_', timestamp, '.mat');
            my_save(result_path{1},Analysis_Results);
        end
    end
end
check_close_pool(poolavail,isOpen);

%send each file in control folder for analysis on separate cluster node

%when all files are analysed, collect analysis results by genotype

%save matrices of analyzed results in folder results_timestamp
%filename = daqroot_chN_genotypeName_timestampofanalysis.m



function my_save(result_path,Analysis_Results)

save(result_path,'Analysis_Results','-mat');
