function PlotIndivSineMFFT(folder,channels)
% USAGE
% PlotGenotypeSineMFFT( ,[10 17])

%setup tight_subplot grid for 8 plots
%grab data from file
%plot in each grid



%get _out folder info
dir_list = dir(folder);

%collect target results


all_channels = channels(1):channels(end);

clf;
ha = tight_subplot(4,2,.05,.06,[.05 .03]);
x=0;
for i=1:numel(dir_list)
    
    file = dir_list(i).name; %pull out the file name
    [~,root,ext] = fileparts(file);
    channel_pos = strfind(root, '_ch');
    channel = root(channel_pos + 3:end);
    
    if ~isempty(channel) & strfind(root(1:3),'PS_')
        if find(all_channels==str2num(channel))
            x=x+1;
            if x <9
                path_file = [folder '/' file];
                load(path_file,'-mat');
                PlotSineMFFT(Data,Sines,Pulses,ha(x),0);
            end
        end
    end
end

for i = x+1:8
    axis(ha(i),'off')
end
    

% %print useful information in final panel
% axes(ha(j+2))
% text(0,1,['Genotype = ' char(genotypes{i})], 'interpreter', 'none')
% %collect data folders
% resFolders = [];
% for a= 1:numel(folders)
%     folder = regexp(folders{a},'/','split');
%     resFolders= [resFolders '  ' folder(end-1)];
% end
% text(0,.8,['Analysis Folders = ' resFolders], 'interpreter', 'none')
% 
% %collect controls
% conGenos = [];
% for a= 1:numControls
%     conGenos = [conGenos '  ' char(control_genotypes{a})];
% end
% text(0,.5,['Controls = ' conGenos], 'interpreter', 'none')
% 
% %collect control folders
% conFolders = [];
% for a= 1:numel(folders)
%     folder = regexp(control_folders{a},'/','split');
%     conFolders= [conFolders '  ' folder(end-1)];
% end
% text(0,.3,['Control Folders = ' conFolders], 'interpreter', 'none')


%save figure
set(gcf,'OuterPosition',[500 1000 900 1150]);
%set(gcf,'PaperPositionMode','auto');
%position = get(gcf,'Position');
%set(gcf,'PaperPosition',[0.5,0,position(3:4)]);
save2pdf([folder '/sineMFFT_ch' num2str(channels(1)) '-' num2str(channels(end)) '.pdf'],gcf)
