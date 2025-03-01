function [age_unique,dist_25,dist_50,dist_75,dist_mean]=scoreValidationRun

path='C:\Users\lolo\Documents\TheOceanCleanup\data\globaldrifter\modelled\drogue_on\nostokes_nowindage\';
drogue=1;
age_=[];
dist_=[];

for id=[2578,2611,2613,2623,2931,3274,3275,3276,4440,4639]
    
    traj= shaperead(['C:\Users\lolo\Documents\TheOceanCleanup\data\globaldrifter\shp\' num2str(id) '.shp']);
    
    ncid=netcdf.open([path 'parts_drifter_' num2str(id) '.nc'],'NOWRITE');
    time=netcdf.getVar(ncid,0);
    lon=netcdf.getVar(ncid,1);
    lat=netcdf.getVar(ncid,2);
    rdate  = netcdf.getVar(ncid,4);
    netcdf.close(ncid)
    
    
    dist = NaN(size(lon));
    age  = NaN(size(lon));
    
    for k=1:length(traj)
        if traj(k).drogue==drogue
            for i=1:length(traj(k).X)
                t=find(floor(time)==floor(traj(k).startDate+(i-1)));
                if ~isempty(t)
                    for p=1:size(lon,2)
                        [d1km d2km]=lldistkm([traj(k).Y(i) traj(k).X(i)],[lat(t,p) lon(t,p)]);
                        dist(t,p)= d1km;
                        age(t,p) = traj(k).startDate+(i-1) - rdate(p);
                    end
                end
            end
        end
    end
    
    
    age=floor(age);
    age_  = [age_;age(:)];
    dist_ = [dist_;dist(:)];
    
end


age_unique  = unique(sort(age_));
age_unique(age_unique<0)=[];

dist_25=zeros(size(age_unique));
dist_50=zeros(size(age_unique));
dist_75=zeros(size(age_unique));
dist_mean=zeros(size(age_unique));

for d=1:length(age_unique)
    dist_25(d)=quantile(dist_(age_==age_unique(d)),0.25);
    dist_50(d)=quantile(dist_(age_==age_unique(d)),0.50);
    dist_75(d)=quantile(dist_(age_==age_unique(d)),0.75);
    dist_mean(d)=mean(dist_(age_==age_unique(d)));
end

figure;
plot(age_,dist_,'.k','markersize',1)

hold on
plot(age_unique,dist_25,'r')
plot(age_unique,dist_50,'r','linewidth',2)
plot(age_unique,dist_75,'r')

xlim([0 max(age_unique)])
xlabel('time (days)')
ylabel('distance (km)')