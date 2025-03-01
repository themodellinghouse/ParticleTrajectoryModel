function stationSearchArea=getStationSearchArea

load('Merged_Eriksen_SEA.mat')

Nstations=length(data);
stationSearchArea=zeros(Nstations,3);

for k=1:Nstations
   lat=data(k,2);
   lon=data(k,3);
   
   a1=lldistkm([lat lon],[lat lon+0.1]);
   b1=lldistkm([lat lon],[lat+0.1 lon]);
   s1=pi*a1*b1;
   
   a2=lldistkm([lat lon],[lat lon+0.5]);
   b2=lldistkm([lat lon],[lat+0.5 lon]);
   s2=pi*a2*b2;
   
   a3=lldistkm([lat lon],[lat lon+1]);
   b3=lldistkm([lat lon],[lat+1 lon]);
   s3=pi*a3*b3;
   
   stationSearchArea(k,1) = s1;
   stationSearchArea(k,2) = s2;
   stationSearchArea(k,3) = s3;
end