% Run from here to ...
U = xyzA_final(:,1); 
V = xyzA_final(:,2);
requiredResolution = 0.31; % in meters
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

% HERE first with the raw output data
% Then remove everything except: normalVelocity, xyzA_final, xyzB_final. Xout, Yout, zi
% Save as a diffent matlab workspace

xIn = 5:5:25;
leftBank = 24.5; % in y
rightBank = 1.1; % in y
stepDist = 0.3;

% KLT inputs
allXY = [Xout(:),Yout(:)]; % exported x y grid for KLT
uOut = zi; % KLT out

f1 = figure();
hold on;
set(gca,'TickLabelInterpreter','latex')
ax1 = gca;
%surf(Xout,Yout,zi); hold on % piv output co-ordinates
for a = 1:length(xIn)
    bb = regress([xIn(a), xIn(a)]',[leftBank, rightBank; 1, 1]'); %[x,y]
    interogation = rightBank:stepDist:leftBank; % y-axis (channel width)
    xExtract = bb(2)+interogation.*bb(1); %x-axis (up/downstream)
    [ d, dist ] = knnsearch(allXY,[xExtract;interogation]');
    extracted = uOut(d);
    plot3(xExtract,interogation, extracted, 'b');
    hold on
end

%plot3(ADCP(:, 2),ADCP(:, 3), ADCP(:, 5), 'k');

%PIV inputs
allXY = [x(:),y(:)]; % exported x y grid for PIV
uOut = avu; % PIV out

%surf(x,y,avu); hold on % piv output co-ordinates
for a = 1:length(xIn)
    bb = regress([xIn(a), xIn(a)]',[leftBank, rightBank; 1, 1]'); %[x,y]
    interogation = rightBank:stepDist:leftBank; % y-axis (channel width)
    xExtract = bb(2)+interogation.*bb(1); %x-axis (up/downstream)
    [ d, dist ] = knnsearch(allXY,[xExtract;interogation]');
    extracted = uOut(d);
    plot3(xExtract,interogation, extracted, 'r');
    hold on
end




zlabel('Velocity Magnitude $\mathrm{(m \ s^{-1})}$' , 'Interpreter','LaTex')
xlabel('x co-ordinates (m)', 'Interpreter','LaTex')
ylabel('y co-ordinates (m)', 'Interpreter','LaTex')
