
%% Required input:


% Description: This script utilises data deposited at 
% https://drive.google.com/open?id=1zFp5v1qG-q9cFrMn27-ScQVBakTFC2HO
% In the folder: ADCP_Comparions - choose whether you wish to process the
% data from Video A or Video B. 
% This script is used to create the data for the replication of Figures 8 and 9 within the research
% paper of Pearce et al. (2020) An Evaluation of Image Velocimetry Techniques under Low Flow Conditions 
%and High Seeding Densities Using Unmanned Aerial Systems. Journal Remote Sensing 
%(SI: Unamnned Aerial Systems for Surface Hydrology). The data produced throughout this script
% is to be inputted into the script XS_Comparisons for the creation of the figures. 

% Outputs: 
% This script will produce the velocities and locations of the KLT surface
% velocities, in comparisons to the ADCP measurements. 

%Inputs: 
% You will need the KLT data for each video (to be run seperately)
% available from the link above.
% You will also need the XYUV_split.txt file available from this
% repository. 

% The data produced within this script, will then need to be inputted into
% the XS_Comparisons script to create the required figures. 

dirName = 'F:\Year 3\BelgradeData_toUpload\ToUpload\ADCP_Comparisons\KLT\';
listing = dir(dirName); % Import the list of files within the specified directory
Acell = struct2cell(listing)';
fileNameIn = Acell(3:end,1);

for aa = 1
    
    pathIn = [dirName, char(fileNameIn(aa,1))];
    
    load(pathIn)
    
    stepDist = 0.5;
    
    U = xyzA_final(:,1);
    V = xyzA_final(:,2);
    requiredResolution = 0.5; % in meters
    xi = nanmin(xyzA_final(:,1)):requiredResolution:nanmax(xyzA_final(:,1));
    yi = nanmin(xyzA_final(:,2)):requiredResolution:nanmax(xyzA_final(:,2));
    [Xout,Yout] = meshgrid(xi,yi);
    Ze1 = normalVelocity(:,1);
    
    [xi,yi,zi,ct,zc,bn_x,bn_y] = blockmean_v2(xi,yi,U,V,Ze1,requiredResolution,requiredResolution);
    def1 = size(zi);
    xVels(1:def1(1,1),1:def1(1,2)) = NaN;
    yVels(1:def1(1,1),1:def1(1,2)) = NaN;
    zc = replace(zc,0,NaN);
    tt1 = full(ct);
    [w1 w2] = find(tt1 > 0);
    % out = Xout, Yout, zi
    
    allXY = [Xout(:),Yout(:)]; % exported x y grid for KLT
    uOut = zi; % KLT out
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
        plot(allXY(d, 2),uOut1 (d,1)); hold on % extract these
        
       % Pause the script here (plot(allXY(d, 2),uOut1 (d,1)); hold on), and in the command window, plot
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

