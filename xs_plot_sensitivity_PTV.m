%% Required input:
% Description: This script utilises data deposited at 
% https://drive.google.com/open?id=1zFp5v1qG-q9cFrMn27-ScQVBakTFC2HO
% This script is used to reproduce Figure 7g and 7h within the research
%  paper of Pearce et al. (2020) An Evaluation of Image Velocimetry Techniques under Low Flow Conditions 
%and High Seeding Densities Using Unmanned Aerial Systems. Journal Remote Sensing 
%(SI: Unamnned Aerial Systems for Surface Hydrology).

% This script will produce a box and whisker plot representing the
% sensitivity of all the configurations assessed. A variable will also be
% produced named 'TotalScore', this variable will give you the sensitivity
% scores produced in Table 3 within Pearce et al. (2020). 

% Inputs: 
% The inputs for this script can be found at: https://drive.google.com/open?id=1zFp5v1qG-q9cFrMn27-ScQVBakTFC2HO
% In the folder: Sensitivity_Analysis\Inputs\LSPTV_VideoA - all inputs in
% this folder are required to run this script. 
% In Pearce et al (2020), two cross sections are analysed, please change
% the 'xIn' variable to 10 and 20 to replicate the two figures produced. 
% You will need the scripts 'blockmean_V2' saved in the same location as
% this script for the script to run accurately. 


% Alter the inputs
dirName = 'F:\Year 3\BelgradeData_toUpload\ToUpload\Sensitivity_Analysis\Inputs\LSPTV_VideoA\';
%
listing = dir(dirName); % Import the list of files within the specified directory
Acell = struct2cell(listing)';
fileNameIn = Acell(3:end,1);

for aa = 1:length(fileNameIn)
    pathIn = [dirName, char(fileNameIn(aa,1))];
    load(pathIn)
    
    xIn = 10; % This is the x- axis co-ordinates. Outputs at 10 and 20m
    leftBank = 25; % in y
    rightBank = 5; % in y
    stepDist = 0.5;
    
    %OTV inputs
    allXY = [ptvXtransGrid(:),ptvYtransGrid(:)]; % exported x y grid for PTV
    uOut = zi; % PTV out
    
    %surf(x,y,avu); hold on % OTV output co-ordinates
    for b = 1:length(xIn)
        bb = regress([xIn(b), xIn(b)]',[leftBank, rightBank; 1, 1]'); %[x,y]
        interogation = rightBank:stepDist:leftBank; % y-axis (channel width)
        xExtract = bb(2)+interogation.*bb(1)'; %x-axis (up/downstream)
        [ d, dist ] = knnsearch(allXY,[xExtract;interogation]');
        extracted = uOut(d)';
        %plot3(xExtract,interogation, extracted, 'r');
        varIn = char(fileNameIn(aa,1));
        varIn = varIn (1:end-4);
        eval(['out_' varIn '= transpose([xExtract; interogation; extracted]);']) 
        hold on
    end

    %zlabel('Velocity Magnitude $\mathrm{(m \ s^{-1})}$' , 'Interpreter','LaTex')
    %xlabel('x co-ordinates (m)', 'Interpreter','LaTex')
    %ylabel('y co-ordinates (m)', 'Interpreter','LaTex')
    
end

test = who('-regexp','out_*');
for aa = 1:length(test)
    if aa == 1
        compiledByDist = eval([char(test(aa,1)) '(:, 1:3);']);
    else
        compiledByDist(:,aa+2) = eval([char(test(aa,1)) '(:, 3);']);
    end
end

[~, width1] = size(compiledByDist);

fig = gcf;
pbaspect([2 1 1]); 
hold on;
set(gca,'TickLabelInterpreter','latex')
remove = find(compiledByDist < 0);
compiledByDist(remove) = NaN;
boxplot(compiledByDist(:,3:width1)', 'positions', compiledByDist(:,2)', 'labels',compiledByDist(:,2)', ...
    'plotstyle','compact',.... % compact style
    'colors', [0.5,0.5,0.5],... % grey color
    'symbol',''); % remove outliers

h = findobj(gca, 'type', 'text');
delete(findobj(gca,'type','text'))  % wipe out the boxplot labels that are problematic
set(gca,'xlim',[4 26])
yLims = get(gca,'ylim');
ylim ([0 0.4])
% set(gca,'ylim',[0 nanmax(nanmax(compiledByDist(:,3:width1)))])
set(gca,'xtick',rightBank:5:leftBank,'xticklabel',num2cell(rightBank:5:leftBank))  % and write the labels wanted

xlabel('Distance across the channel (m)', 'FontSize', 14, 'Interpreter','LaTex')
ylabel('Downstream velocity  $\mathrm{(m \ s^{-1})}$' , 'FontSize', 14, 'Interpreter','LaTex')


clear scoreDifference
referenceValue = nanmedian(compiledByDist(:,3:width1)');
for aa = 1:length(referenceValue)
    scoreDifference(aa, 1:width1-2) = compiledByDist(aa,3:width1) - referenceValue(aa);
end
abs_scoreDifference = abs(scoreDifference);
totalScore = nansum(abs_scoreDifference);
missing = sum(isnan(abs_scoreDifference))./length(abs_scoreDifference).*100;


