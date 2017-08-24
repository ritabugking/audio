clear all; clc; close all;

filename = sprintf('/Users/yijuwang/Desktop/spto/yw/yw1t1a.wav');
[x1a, Fs]=audioread(filename);
filename = sprintf('/Users/yijuwang/Desktop/spto/yw/yw1t1bm.wav');
[x1b, Fs]=audioread(filename);
x1=[x1a;x1b];
x1=x1(:,1); % one channel


% x_a=x1(1:0.5*Fs+1);
% x_b=x1(0.5*Fs+2:length(x1));
% 
% % bandpass filter 5000-11000Hz
% passBand=[4000, 11000];
% [bb, aa]=butter(10, passBand/(Fs));
% [h, w]=freqz(bb, aa);
% x_a=filter(bb, aa, x_a);
% 
% % bandpass filter 2000-10000Hz
% passBand=[1800, 11000];
% [bb, aa]=butter(10, passBand/(Fs));
% [h, w]=freqz(bb, aa);
% x_b=filter(bb, aa, x_b);
% 
% x1=[x_a;x_b];
x=downsample(x1,2);
% enframe: window length = 256, step = 128
wlen=256; inc=128; win=hanning(wlen);
N=length(x); time=(0:N-1)/Fs;      
y=enframe(x,win,inc)';              
fn=size(y,2);                       
frameTime=(((1:fn)-1)*inc+wlen/2)/Fs; 
W2=wlen/2+1; n2=1:W2;
freq=(n2-1)*Fs/wlen;                
Y=fft(y); 


%=====================================================
%prominent region
for i=1:size(Y,2)
    peak=find(abs(Y(n2,i))==max(abs(Y(n2,i))));
    for j=n2

        if (j~=peak && j~=peak+1 && j~=peak-1 && j~=peak+2 && j~=peak-2 && j~=peak+3 && j~=peak-3 && j~=peak+4 && j~=peak-4)
                Y(j,i)=0;
        end
%         if (j==peak+1 || j==peak-1 || j==peak+2 || j==peak-2 || j==peak+3 || j==peak-3 || j==peak+4 || j==peak-4)
%                 if log(abs(Y(j,i)))<log(max(abs(Y(n2,:))))-2 %%% maximal value of whole spectrogram 
%                     Y(j,i) = 0;
%                 end
%         end
    end
end
ywt=abs(Y(n2,:))>0;

temp=ywt;
% for i=1:size(ywt,2) % ???? ????0.025s
%     for j=n2
%         if (temp(j,i)==1)
%             for k=1
%                 if (i>k)
%                     ywt(j,i-k)=1;
%                 end
%                 if (i<size(ywt,2)-k)
%                     ywt(j,i+k)=1;
%                 end
%             end
%         end
%     end
% end
temp=double(ywt);

%=====================================================%
%tempspec=abs(Y(n2,:)).*temp; % template spectrogram
figure()
set(gcf,'Position',[20 100 600 500]);            
axes('Position',[0.1 0.1 0.85 0.5]);  
imagesc(frameTime,freq,abs(temp(n2,:))); % ????Y?????? 
%imagesc(frameTime,freq,(abs(ywdata(n2,:))));
axis xy; ylabel('????/Hz');xlabel('????/s');
title('??????');
m = 64;
LightYellow = [0.6 0.6 0.6];
MidRed = [0 0 0];
Black = [0.5 0.7 1];
Colors = [LightYellow; MidRed; Black];
% %colormap(SpecColorMap(m,Colors));
% 


filename = sprintf('/Users/yijuwang/Desktop/spto/yw/yw1c.wav');
info = audioinfo(filename);
Fs = info.SampleRate;
n_total=info.TotalSamples;

simatrix=[];
pathmatrix=[];
%for i=1:Fs/2:n_total-1
for i=floor(Fs/2*133+1)
[x2, Fs]=audioread(filename, [i,min(floor(length(x1)*2)-1+i, n_total)]); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%================================================
%[x, Fs]=audioread(filename, [1,44100*1+1]);
x2=x2(:,1); % one channel
x=downsample(x2,2);
% bandpass filter 2000-10000Hz
passBand=[1800, 11000];
[bb, aa]=butter(8, passBand/(Fs/2));
[h, w]=freqz(bb, aa);
x=filter(bb, aa, x);

% enframe: window length = 256, step = 128
wlen=256; inc=128; win=hanning(wlen);
N=length(x); time=(0:N-1)/Fs;      
y=enframe(x,win,inc)';              
fn=size(y,2);                       
frameTime=(((1:fn)-1)*inc+wlen/2)/Fs; 
W2=wlen/2+1; n2=1:W2;
freq=(n2-1)*Fs/wlen;                
Y=fft(y);                           
ywdata=Y(n2,:);
dataspec=abs(ywdata); % potential spectrogram

figure()
set(gcf,'Position',[20 100 600 500]);            
axes('Position',[0.1 0.1 0.85 0.5]);  
imagesc(frameTime,freq,log(abs(dataspec(n2,:)))); % ????Y?????? 
%imagesc(frameTime,freq,(abs(ywdata(n2,:))));
axis xy; ylabel('????/Hz');xlabel('????/s');
title('??????');
m = 64;
LightYellow = [0.6 0.6 0.6];
MidRed = [0 0 0];
Black = [0.5 0.7 1];
Colors = [LightYellow; MidRed; Black];


[simi, locx, locy, path]=sim(temp, dataspec);
%path=reshape(path,2,[])';
%plot(path(:,2),path(:,1))
simatrix=[simatrix, simi];
path = reshape(path,2, [])';
%pathmatrix=[pathmatrix, ];
end
figure()
plot(path(:,1),path(:,2))


function [similarity, location_x, location_y, path_] = sim (template, data) 

s=template; % template spectrogram
t=data; % potential spectrogram

% dynamic time warping
w=-Inf;
ns=size(s,2);
nt=size(t,2);
if size(s,1)~=size(t,1)
    error('Error in dtw(): the dimensions of the two input signals do not match.');
end

%% initialization
D=zeros(ns+2,nt+2)-Inf; % cache matrix
D(1,1)=0;
D(2,2)=0;

% similarity matrix (cosing similarity)
oost = zeros(ns+1,nt+1)-Inf;
for i=1:ns
    for j=1:nt
        oost(i+1,j+1) = (dot(s(:,i),t(:,j))/(norm(s(:,i),2)*norm(t(:,j),2))); % = cos(theta)
    end
end
       

%% begin dynamic programming
%find the maximal similarity between two matrix s(w*ns) & t(w*nt)
% the start point should be aligned, but the end point doesn't need to be
for i=1:ns
    for j=1:nt
        D(i+2,j+2)=max([D(i+1,j+2), D(i+2,j+1), D(i+1,j+1)+oost(i+1,j+1)]);
    end
end

n_max=max(D(:,1:size(D,2))); % ????????????????
big=-Inf;
loc=-Inf;
for i=3:size(D,2)
    if (big<n_max(i)/(i+size(D,1)))
        big=n_max(i)/(i+size(D,1));
        loc=i;
    end
end

similarity = big;
location_x = size(D,1);
location_y = loc;



%=========================================================================
[path, x1, x2]=find_path(size(D,1)-2,size(D,2)-2);

function [pathmap, cord1, cord2] = find_path(a,b)
persistent oo;
if (a==0 || b==0)
    cord1=0;
    cord2=0;
    oo =[oo, cord1, cord2];
    pathmap=oo;
    return;
end

if (max([D(a+1,b+2), D(a+2,b+1), D(a+1,b+1)])==D(a+1,b+2))
    cord1=a;
    cord2=b;
    find_path(a-1,b);
    %oo =[oo, cord1, cord2];
    oo =[oo, a, b];    
    pathmap=oo;
elseif (max([D(a+1,b+2), D(a+2,b+1), D(a+1,b+1)])==D(a+2,b+1))
    cord1=a;
    cord2=b;
    find_path(a,b-1);
    %oo =[oo, cord1, cord2];
    oo =[oo, a, b];   
    pathmap=oo;
elseif (max([D(a+1,b+2), D(a+2,b+1), D(a+1,b+1)])==D(a+1,b+1)+oost(a+1,b+1))
    cord1=a;
    cord2=b;
    find_path(a-1,b-1);
    oo =[oo, a, b];
    pathmap=oo;
end
    
end
path_ = path;

end