
% ===========================================
loc=find(simatrix>0.25);  % find locations > threshold
marker=[];
i=1;
while (i<=length(loc))
a=loc(i);
k=i;
if (i~=length(loc))
while (loc(k)+1==loc(k+1))
k=k+1;
end
end
b=loc(k);
i=k+1;
marker=[marker,a,b];
if (i>length(loc))
break;
end
end

marker=reshape(marker,2,[])';
%============================================
sec_point=[];
for i=1:size(marker,1)
    loc_p = find(simatrix==max(simatrix(marker(i,1):marker(i,2))));
    loc_p = (loc_p-1-1)*0.5;
    sec_point=[sec_point,loc_p];
end
