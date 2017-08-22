[sim, locx, locy, path, x1, x2]=find_path(218,218);
path=reshape(path,2,[])';
plot(path(:,2),path(:,1))

function [similarity, location_x, location_y, pathmap, cord1, cord2] = find_path(a,b)
persistent oo;
% global pathMat;
if (a==0 || b==0)
    cord1=0;
    cord2=0;
    oo =[oo, cord1, cord2];
    pathmap=oo;
    %oo=mat;
    %matx=mat;
    return;
end


filename = sprintf('/Users/yijuwang/Desktop/spto/yw/yw1t2longer.wav');
[x, Fs]=audioread(filename);
%[x, Fs]=audioread(filename, [1,44100*1+1]);
x=x(:,1); % one channel
x=downsample(x,2);
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
ywdata=Y;
%t=abs(ywdata); % potential spectrogram
t=abs(ywdata); % potential spectrogram

filename = sprintf('/Users/yijuwang/Desktop/spto/yw/ywt.wav');
[x, Fs]=audioread(filename);
x=x(:,1); % one channel
x=downsample(x,2);
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
ywt=Y;
s=abs(ywt); % template spectrogram

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
        D(i+2,j+2)=oost(i+1,j+1)+max([D(i,j+1)+oost(i,j+1), D(i+1,j)+oost(i+1,j), D(i+1,j+1)]);
    end
end
similarity=max(D(:,nt+2)/(nt+2+ns+2)); % the biggest num at last column
loc=find(D/(nt+2+ns+2)==max(D(:,nt+2)/(nt+2+ns+2)));
location_x = mod(loc,size(D,1));
location_y = floor(loc/size(D,1))+1;
if (location_x==0)
    location_x=size(D,1);
    location_y = location_y-1;
end
d_len=nt+2;

while(max(D(:,d_len))==-Inf) % the biggest num isn't at last column
    d_len=d_len-1;
    similarity=max(D(:,d_len))/ns+2+d_len;
end
loc=find(D/(ns+2+d_len)==max(D(:,d_len)/(ns+2+d_len)));
location_x = mod(loc,size(D,1));
location_y = floor(loc/size(D,1))+1;
if (location_x==0)
    location_x=size(D,1);
    location_y = location_y-1;
end

if (max([D(a,b+1)+oost(a,b+1), D(a+1,b)+oost(a+1,b), D(a+1,b+1)])==D(a,b+1)+oost(a,b+1))
%     fprintf('(%d, %d)', a, b);
%     fprintf('(%d, %d)', a-1, b);
    cord1=a-1;
    cord2=b;
    find_path(a-2,b-1);
    oo =[oo, cord1, cord2];
    oo =[oo, a, b];    
    pathmap=oo;
elseif (max([D(a,b+1)+oost(a,b+1), D(a+1,b)+oost(a+1,b), D(a+1,b+1)])==D(a+1,b)+oost(a+1,b))
%     fprintf('(%d, %d)', a, b);
%     fprintf('(%d, %d)', a, b-1);
    cord1=a;
    cord2=b-1;
    find_path(a-1,b-2);
    oo =[oo, cord1, cord2];
    oo =[oo, a, b];   
    pathmap=oo;
elseif (max([D(a,b+1)+oost(a,b+1), D(a+1,b)+oost(a+1,b), D(a+1,b+1)])==D(a+1,b+1))
%     fprintf('(%d, %d)', a, b);
    cord1=a;
    cord2=b;
    find_path(a-1,b-1);
    oo =[oo, a, b];
    pathmap=oo;
end
    
end

