clear

init_year=1993;
end_year=2012;

deltaD=30; %search frequency in days

output_path='F:\CPD-Macroscale\Lebreton_phase_2\4th_run_scenarios\ocean_releases\current';
source_path='C:\Users\lolo\Documents\TheOceanCleanup\sources\FishingEffort\sources_nc\fishing_parts_source';
lowbeaching_path='C:\Users\lolo\Documents\TheOceanCleanup\work\beaching\fishing\current\time_threshold_2days';
highbeaching_path='C:\Users\lolo\Documents\TheOceanCleanup\work\beaching\fishing\current\time_threshold_28days';
compartment_file='C:\Users\lolo\Documents\TheOceanCleanup\github\trashtracker\post processing\IW-EEZ\IW-EEZ-Area.shp';

output_shapefile='C:\Users\lolo\Documents\TheOceanCleanup\work\oceanloads\Results\fishing_lowwindage';

S=shaperead(compartment_file);

%init
for k=1:length(S)
       S(k).tp=0; %total parts: the total number of particles found in a compartment
       S(k).tp_lb=0; %total parts that have resided at least 2 consecutive days around the coast
       S(k).tp_hb=0; %total parts that have resided at least 28 consecutive days around the coast
       S(k).sp=0; %selfparts: the total number of particles found in a compartment that were initially released in that same compartment
       S(k).sp_lb=0; %self parts that have resided at least 2 consecutive days around the coast
       S(k).sp_hb=0; %self parts that have resided at least 28 consecutive days around the coast
       S(k).rp=0; %regionparts: the total number of particles found in a compartment that were initially released in the compartment's region (self included)
       S(k).rp_lb=0; %region parts that have resided at least 2 consecutive days around the coast
       S(k).rp_hb=0; %region parts that have resided at least 28 consecutive days around the coast
       S(k).source=0; %sourceparts: total number of particles released from the compartment
       S(k).bp_lb=0; %beachparts_low: number of particles beached in the compartment after spending 2 consecutive days nearshore
       S(k).bp_hb=0; %beachparts_high: number of particles beached in the compartment after spending 28 consecutive days nearshore 
end


for y0=end_year:-1:init_year
        
        age=end_year-y0;
        disp(' ')
        disp(['Computing age ' num2str(age)])
        disp(' ')
        
        %source file
        ncid=netcdf.open([source_path '\parts_source_' num2str(y0) '.nc'],'NOWRITE');
        lonS=netcdf.getVar(ncid,1);
        latS=netcdf.getVar(ncid,2);
        netcdf.close(ncid)
        source=zeros(size(lonS));
        
        %particle output files
        ncid=netcdf.open([output_path '\parts_2012_' num2str(y0) '.nc'],'NOWRITE');
        time=netcdf.getVar(ncid,0);
        lon=netcdf.getVar(ncid,1);
        lat=netcdf.getVar(ncid,2);
        rdate  = netcdf.getVar(ncid,4);
        netcdf.close(ncid)
        
        %low beaching output files
        ncid=netcdf.open([lowbeaching_path '\bdate_' num2str(y0) '.nc'],'NOWRITE');
        dateBlow  = netcdf.getVar(ncid,0);
        lonBlow  = netcdf.getVar(ncid,1);
        latBlow  = netcdf.getVar(ncid,2);
        netcdf.close(ncid)
        
        %high beaching output files
        ncid=netcdf.open([highbeaching_path '\bdate_' num2str(y0) '.nc'],'NOWRITE');
        dateBhigh  = netcdf.getVar(ncid,0);
        lonBhigh  = netcdf.getVar(ncid,1);
        latBhigh  = netcdf.getVar(ncid,2);
        netcdf.close(ncid)
        
        %search in longitude between -180 & 180
        lonS(lonS>180)=lonS(lonS>180)-360;
        lon(lon>180)=lon(lon>180)-360;
        lonBlow(lonBlow>180)=lonBlow(lonBlow>180)-360;
        lonBhigh(lonBhigh>180)=lonBhigh(lonBhigh>180)-360;
        
        %attribute sources
        for k=1:length(S)
               in=inpolygon(lonS,latS,S(k).X,S(k).Y);
               source(in)=k;
               S(k).source = S(k).source + sum(in & ~(latS==0 & lonS==0) );
        end
        
        %attribute beached particles
        for k=1:length(S)
               in=inpolygon(lonBlow,latBlow,S(k).X,S(k).Y);
               S(k).bp_lb = S(k).bp_lb + sum(in & dateBlow>0);
               eval(['S(k).a' num2str(age) '_bp_lb = sum(in & dateBlow>0);'])
               
               in=inpolygon(lonBhigh,latBhigh,S(k).X,S(k).Y);
               S(k).bp_hb = S(k).bp_hb + sum(in & dateBhigh>0);
               eval(['S(k).a' num2str(age) '_bp_hb = sum(in & dateBhigh>0);'])
        end

        %filter search dates
        time=time(1:deltaD:end);
        lon=lon(1:deltaD:end,:);
        lat=lat(1:deltaD:end,:); 
        nD=length(time);
        source=double(ones(nD,1)*source');
        
        %get released particles
        time=double(time*ones(1,length(rdate)));      
        rdate=double(ones(nD,1)*rdate');
        released=(time-rdate>0);
        
        %get beached particles
        dateBlow=double(ones(nD,1)*dateBlow');
        beachedLow=(dateBlow-rdate>0);
        dateBhigh=double(ones(nD,1)*dateBhigh');
        beachedHigh=(dateBhigh-rdate>0);
        
        %flatten
        lon=lon(:);
        lat=lat(:);
        rdate=rdate(:);
        released=released(:);
        source=source(:);
        beachedLow  =beachedLow(:);
        beachedHigh =beachedHigh(:);
        
        %remove never released
        lon(rdate==0)=[];
        lat(rdate==0)=[];
        source(rdate==0)=[];
        released(rdate==0)=[];
        beachedLow(rdate==0)=[];
        beachedHigh(rdate==0)=[];
        rdate(rdate==0)=[];
        
        %remove not released
        lon(~released)=[];
        lat(~released)=[];
        source(~released)=[];
        rdate(~released)=[];
        beachedLow(~released)=[];
        beachedHigh(~released)=[];
        released(~released)=[];
        
        % go through polygons
        for k=1:length(S)
               in=inpolygon(lon,lat,S(k).X,S(k).Y);

               S(k).tp=S(k).tp+sum(in)/nD;
               S(k).tp_lb=S(k).tp_lb+sum(in & beachedLow)/nD;
               S(k).tp_hb=S(k).tp_hb+sum(in & beachedHigh)/nD;
               S(k).sp =S(k).sp+sum(in & source==k)/nD;
               S(k).sp_lb=S(k).sp_lb+sum(in & beachedLow & source==k)/nD;
               S(k).sp_hb=S(k).sp_hb+sum(in & beachedHigh & source==k)/nD;
               
               tmp=0;
               for n=1:length(S)
                   if strcmp(S(n).Region,S(k).Region)
                    S(k).rp=S(k).rp+sum(in & source==n)/nD;
                    S(k).rp_lb =S(k).rp_lb +sum(in & beachedLow  & source==n)/nD;
                    S(k).rp_hb=S(k).rp_hb+sum(in & beachedHigh & source==n)/nD;
                    tmp=tmp+sum(in & source==n)/nD;
                   end
               end
               
               eval(['S(k).a' num2str(age) '_tp=sum(in)/nD;'])
               eval(['S(k).a' num2str(age) '_tp_lb=sum(in & beachedLow)/nD;'])
               eval(['S(k).a' num2str(age) '_tp_hb=sum(in & beachedHigh)/nD;'])
               eval(['S(k).a' num2str(age) '_sp=sum(in & source==k)/nD;'])
               eval(['S(k).a' num2str(age) '_rp=tmp;'])
               
               
               if strcmp(S(k).Country,'')
                disp([S(k).Region ': ' num2str(round(sum(in)/nD)) ' particles'])
               else
                disp([S(k).Country ': ' num2str(round(sum(in)/nD)) ' particles'])   
               end
               
               lon(in)=[];
               lat(in)=[];
               source(in)=[];
               beachedLow(in) =[];
               beachedHigh(in)=[];
        end
end

shapewrite(S,output_shapefile)