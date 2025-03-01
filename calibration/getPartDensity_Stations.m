data_path='G:\particles\fishing windage 0.5';
output_filename='Eriksen_SEA_fishing_current_stokes_wind_0.5.mat';

load('Merged_Eriksen_SEA.mat')
Nstations=length(data);

density_1=zeros(Nstations,1);
density_2=zeros(Nstations,1);
density_3=zeros(Nstations,1);


init_year=1993;
search_radius_1=0.1;
search_radius_2=0.5;
search_radius_3=1;

for k=1:Nstations
   disp(k/Nstations*100)
   day=data(k,1); 
   lat=data(k,2);
   lon=data(k,3);
   if lon<0; lon=360+lon; end
   dvec=datevec(day); 
   for y=init_year:dvec(1)
        ncid=netcdf.open([data_path '\parts_' datestr(day,'yyyy') '_' num2str(y) '.nc'],'NOWRITE');
        time=netcdf.getVar(ncid,0);
        lon_=netcdf.getVar(ncid,1);
        lat_=netcdf.getVar(ncid,2);
        netcdf.close(ncid)
        
        t=find(time==day);
        d=sqrt((lon_(t,:)-lon).^2+(lat_(t,:)-lat).^2);
        
        near=find(d<search_radius_1);
        density_1(k)=density_1(k)+length(near);
        near=find(d<search_radius_2);
        density_2(k)=density_2(k)+length(near);
        near=find(d<search_radius_3);
        density_3(k)=density_3(k)+length(near);
   end
end

save(output_filename,'density_1','density_2','density_3')
