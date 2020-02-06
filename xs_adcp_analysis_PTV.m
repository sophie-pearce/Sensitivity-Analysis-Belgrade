%% Required input:

% Description: This script utilises data deposited at 
% https://drive.google.com/open?id=1zFp5v1qG-q9cFrMn27-ScQVBakTFC2HO
% In the folder: ADCP_Comparions - choose whether you wish to process the
% data from Video A or Video B. 
% This script is used to reproduce Figure 8 and 9 within the research
%  paper of Pearce et al. (2020) An Evaluation of Image Velocimetry Techniques under Low Flow Conditions 
%and High Seeding Densities Using Unmanned Aerial Systems. Journal Remote Sensing 
%(SI: Unamnned Aerial Systems for Surface Hydrology).

% Outputs: 
% This script will produce the velocities and locations of the LSPTV surface
% velocities, in comparisons to the ADCP measurements. 

%Inputs: 
% You will need the LSPTV data for each video (to be run seperately)
% available from the link above.
% You will also need the XYUV_split.txt file available from this
% repository. 

% The data produced within this script, will then need to be inputted into
% the XS_Comparisons script to create the required figures. 

dirName = 'F:\Year 3\BelgradeData_toUpload\ToUpload\ADCP_Comparisons\LSPTV\';
%dirName = 'C:\Users\Matt\Dropbox\Begrade Analysis\PIV\Converted_sortedByVideo';
listing = dir(dirName); % Import the list of files within the specified directory
Acell = struct2cell(listing)';
fileNameIn = Acell(3:end,1);

for aa = 1
    %pathIn = strjoin({'D:\Dropbox\Begrade Analysis\PIV\Converted_sortedByVideo\', char(fileNameIn(aa,1))},'');
    pathIn = strjoin({'F:\Year 3\BelgradeData_toUpload\ToUpload\ADCP_Comparisons\LSPTV\', char(fileNameIn(aa,1))},'');
    load(pathIn)
    stepDist = 0.5;
    
    %PIV inputs
    allXY = [ptvXtransGrid(:), ptvYtransGrid(:)]; % exported x y grid for PIV
    uOut = normalVel; % PIV out
    uOut1 = uOut(:);
    
    [data_text,~] = readtext('F:\Year 3\BelgradeData_toUpload\ToUpload\ADCP_Comparisons\XYUV_split.txt', ',', '','','textual');% read in the comma delimeted data
    data_text = str2double(data_text(2:end,2:end));
    %[ d, dist ] = knnsearch(data_text(:,1:2),[xExtract;interogation]');
    
    transectNumbers = 1:3;
    for e = 1:max(transectNumbers)
        figure()
        
        stepLength = nanmin(data_text(:, 2+(e-1)*4)):stepDist:nanmax(data_text(:, 2+(e-1)*4));
        for c = 1:length(stepLength)
            [minValue(e,c), minIndex(e,c)] = min(abs(data_text(:,2+(e-1)*4) - stepLength(c)));
            adcpExtracted(e,c) = data_text(minIndex(e,c), 3+(e-1)*4);
            adcpX(e,c) = data_text(minIndex(e,c), 1+(e-1)*4);
            adcpY(e,c) = data_text(minIndex(e,c), 2+(e-1)*4);
        end
        
        [ d, dist ] = knnsearch(allXY,transpose([adcpX(e,:); adcpY(e,:)]));
        %plot3(allXY(d, 1),allXY(d, 2),uOut1 (d,1)); hold on
        %plot3(adcpX(e,:), adcpY(e,:), adcpExtracted(e,:))
        plot(allXY(d, 2),uOut1 (d,1)); hold on % x-axis for PTV data and velocity
        % Pause the script here, and in the command window, plot
        % 'allXY(d,2)' and 'uOut2(d,1) for each pass. Copy these values
        % into a spreadsheet, to then import into the XS_Comparisons Script
        % for the creation of the figure. The completed spreadsheet should
        % contain 6 columns, with the layout of Y,Vel,Y,Vel,Y,Vel
        plot(adcpY(e,:), adcpExtracted(e,:))
        outs(e,1) = nanmean(uOut1 (d,1));
        outs(e,2) = nanmean(adcpExtracted (e,:));
        percentDiff (e,1) = (outs(e,1) - outs(e,2))./outs(e,2);
        
        zlabel('Velocity Magnitude $\mathrm{(m \ s^{-1})}$' , 'Interpreter','LaTex')
        xlabel('x co-ordinates (m)', 'Interpreter','LaTex')
        %ylabel('y co-ordinates (m)', 'Interpreter','LaTex')
        ylabel('Velocity Magnitude $\mathrm{(m \ s^{-1})}$' , 'Interpreter','LaTex')
        
    end
    
end
