filename = sprintf('/Users/yijuwang/Desktop/spto/yw/segment/seg1_7.wav');
[x, Fs]=audioread(filename);
x=x(:,1); % one channel

% bandpass filter 2000-10000Hz
passBand=[1800, 11000];
[b, a]=butter(8, passBand/(Fs/2));
[h, w]=freqz(b, a);
x=filter(b, a, x);

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
% % make prominent region
% for i=1:size(Y,2)
%     peak=find(abs(Y(n2,i))==max(abs(Y(n2,i))));
%     for j=n2
% 
%         if (j~=peak && j~=peak+1 && j~=peak-1 && j~=peak+2 && j~=peak-2 && j~=peak+3 && j~=peak-3 && j~=peak+4 && j~=peak-4 && j~=peak+5 && j~=peak-5 && j~=peak+6 && j~=peak-6 && j~=peak+7 && j~=peak-7 && j~=peak+8 && j~=peak-8 && j~=peak+9 && j~=peak-9 && j~=peak+10 && j~=peak-10 && j~=peak+11 && j~=peak-11 && j~=peak+12 && j~=peak-12 && j~=peak+13 && j~=peak-13 && j~=peak+14 && j~=peak-14)
%                 Y(j,i)=0;
%         end
%         if (j==peak+1 || j==peak-1 || j==peak+2 || j==peak-2 || j==peak+3 || j==peak-3 || j==peak+4 || j==peak-4 || j==peak+5 || j==peak-5 || j==peak+6 || j==peak-6 || j==peak+7 || j==peak-7 || j==peak+8 || j==peak-8 || j==peak+9 || j==peak-9 || j==peak+10 || j==peak-10 || j==peak+11 || j==peak-11 || j==peak+12 || j==peak-12 || j==peak+13 || j==peak-13 || j==peak+14 || j==peak-14)
%                 if (abs(Y(j,i))<max(max(abs(Y)))*0.1) %%% maximal value of whole spectrogram 
%                     Y(j,i) = 0;
%                 end
%         end
%     end
% end

% dot with template

ywdata=Y;


s=abs(ywt); % template spectrogram
t=abs(ywdata); % potential spectrogram


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
d=max(D(:,nt+2));
d_len=nt+2;

while(max(D(:,d_len))==-Inf)
    d_len=d_len-1;
    d=max(D(:,d_len));
end