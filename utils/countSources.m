function n=countSources(path)

% path='C:\Users\lolo\Documents\TheOceanCleanup\sources\FishingEffort\sources_nc';

n=[];
for year=1993:2030
     ncid=netcdf.open([path '\parts_source_' num2str(year) '.nc'],'NOWRITE');
     id  = netcdf.getVar(ncid,0)';
     np = length(id);
     netcdf.close(ncid);
     n(end+1)=np;
end