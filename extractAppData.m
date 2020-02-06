fields = fieldnames(app);
for a = 1:length(fields)
    eval([char(fields(a,1)) '=' char(strjoin({'app.', char(fields(a,1))},'')) ';'])
end

quiver([XYUVinsurvey(:,2);-5],[XYUVinsurvey(:,3);30],...
    [XYUVinsurvey(:,5); 0.5],[XYUVinsurvey(:,4); 0])
text(-5,29,'Arrow scale: 0.5 m/s')
xlabel('x co-ordinates (m)')
ylabel('y co-ordinates (m)')