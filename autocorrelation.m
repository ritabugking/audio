clear all; clc; close all;

filename = sprintf('/Users/yijuwang/Desktop/spto/yw/yw4t.wav');
[x1, Fs]=audioread(filename);
x1=x1(:,1); % one channel

% % bandpass filter 5000-11000Hz
passBand=[4000, 11000];
[bb, aa]=butter(10, passBand/(Fs));
[h, w]=freqz(bb, aa);
x1=filter(bb, aa, x1);

% enframe: window length = 256, step = 128
wlen=256; inc=128; win=hanning(wlen);
N=length(x1); time=(0:N-1)/Fs;      
y=enframe(x1,win,inc)';              
fn=size(y,2);                       
frameTime=(((1:fn)-1)*inc+wlen/2)/Fs; 
W2=wlen/2+1; n2=1:W2;
freq=(n2-1)*Fs/wlen;                
Y=fft(y); 


%=====================================================
%prominent region
% for i=1:size(Y,2)
%     peak=find(abs(Y(n2,i))==max(abs(Y(n2,i))));
%     for j=n2
%         %if (j~=peak && j~=peak+1 && j~=peak-1 && j~=peak+2 && j~=peak-2 && j~=peak+3 && j~=peak-3 && j~=peak+4 && j~=peak-4)
%         if (j~=peak && j~=peak+1 && j~=peak-1)
%                 Y(j,i)=0;
%         end
% %         if (j==peak+1 || j==peak-1 || j==peak+2 || j==peak-2 || j==peak+3 || j==peak-3 || j==peak+4 || j==peak-4)
% %                 if log(abs(Y(j,i)))<log(max(abs(Y(n2,:))))-2 %%% maximal value of whole spectrogram 
% %                     Y(j,i) = 0;
% %                 end
% %         end
%     end
% end
%ywt=abs(Y(n2,:))>0;
ywt=abs(Y(n2,:));
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
tempspec=abs(Y(n2,:)).*temp; % template spectrogram
% figure()
% set(gcf,'Position',[20 100 600 500]);            
% axes('Position',[0.1 0.1 0.85 0.5]);  
% imagesc(frameTime,freq,log(abs(temp(n2,:)))); % ????Y?????? 
% %imagesc(frameTime,freq,(abs(ywdata(n2,:))));
% axis xy; ylabel('????/Hz');xlabel('????/s');
% title('??????');
% m = 64;
% LightYellow = [0.6 0.6 0.6];
% MidRed = [0 0 0];
% Black = [0.5 0.7 1];
% Colors = [LightYellow; MidRed; Black];
% %colormap(SpecColorMap(m,Colors));
% 


filename = sprintf('/Users/yijuwang/Desktop/spto/yw/yw4.wav');
info = audioinfo(filename);
Fs = info.SampleRate;
n_total=info.TotalSamples;

simatrix=[];
pathmatrix=[];


for i=1:length(sec_point)
i=sec_point(i);
%for i=floor(Fs/2*(13-1)+1)
[x2, Fs]=audioread(filename, [i,min(floor(length(x1)*2)-1+i, n_total)]); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%================================================
%[x, Fs]=audioread(filename, [1,44100*1+1]);
x2=x2(:,1); % one channel
%x=downsample(x2,2);
% bandpass filter 2000-10000Hz
passBand=[4000, 11000];
[bb, aa]=butter(8, passBand/(Fs));
[h, w]=freqz(bb, aa);
x=filter(bb, aa, x2);

% enframe: window length = 256, step = 128
wlen=256; inc=128; win=hanning(wlen);
N=length(x); time=(0:N-1)/Fs;      
y=enframe(x,win,inc)';              
fn=size(y,2);                       
frameTime=(((1:fn)-1)*inc+wlen/2)/Fs; 
W2=wlen/2+1; n2=1:W2;
freq=(n2-1)*Fs/wlen;                
Y=fft(y);
%prominent region
% for i=1:size(Y,2)
%     peak=find(abs(Y(n2,i))==max(abs(Y(n2,i))));
%     for j=n2
%         %if (j~=peak && j~=peak+1 && j~=peak-1 && j~=peak+2 && j~=peak-2 && j~=peak+3 && j~=peak-3 && j~=peak+4 && j~=peak-4)
%         if (j~=peak && j~=peak+1 && j~=peak-1)
%                 Y(j,i)=0;
%         end
% %         if (j==peak+1 || j==peak-1 || j==peak+2 || j==peak-2 || j==peak+3 || j==peak-3 || j==peak+4 || j==peak-4)
% %                 if log(abs(Y(j,i)))<log(max(abs(Y(n2,:))))-2 %%% maximal value of whole spectrogram 
% %                     Y(j,i) = 0;
% %                 end
% %         end
%     end
% end
%ywdata=abs(Y(n2,:))>0;
ywdata=Y(n2,:);
dataspec=abs(ywdata); % potential spectrogram
% autocorrelation with minimun distance

corr=[];
for i=1:size(dataspec,2)-size(tempspec,2)+1
a=sum(sum((tempspec-dataspec(:,i:i-1+size(tempspec,2))).^2.^0.5));
corr=[corr,a];
end
pos=find(corr==min(corr));
pos_sec=((pos-1)*128+1)/44100;
sec_point(i)=sec_point(i)+pos_sec;
end