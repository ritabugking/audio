clear all; clc; close all;
% ====== read List file ======
fileID = fopen('/Users/yijuwang/Desktop/spto/yw/txtList/yw1.txt');
C = textscan(fileID,'%f %s %s %f','HeaderLines',1);
fclose(fileID);
startTime = C{:,1};
endTime = C{:,4};
phrase = C{:,3};



% filename = sprintf('/Users/yijuwang/Desktop/spto/yw/ttt.wav');
 filename = sprintf('/Users/yijuwang/Desktop/spto/yw/yw1.wav');
info = audioinfo(filename);
Fs = info.SampleRate;
n_total=info.TotalSamples;
% 
% 
 [x1, Fs]=audioread(filename, [floor(startTime(1)*Fs), floor(endTime(1)*Fs)]); 
%[x1, Fs]=audioread(filename);
% enframe: window length = 256, step = 128
% wlen=256; inc=128; win=hanning(wlen);
% N=length(x1); time=(0:N-1)/Fs;      
% y=enframe(x1,win,inc)';              
% fn=size(y,2);                       
% frameTime=(((1:fn)-1)*inc+wlen/2)/Fs; 
% W2=wlen/2+1; n2=1:W2;
% freq=(n2-1)*Fs/wlen;                
% Y=fft(y);                           
% ywdata=Y(n2,:);
% dataspec=abs(ywdata); % potential spectrogram
% 
% figure()
% set(gcf,'Position',[20 100 600 500]);            
% axes('Position',[0.1 0.1 0.85 0.5]);  
% imagesc(frameTime,freq,log(abs(dataspec(n2,:)))); % ????Y?????? 
% %imagesc(frameTime,freq,(abs(ywdata(n2,:))));
% axis xy; ylabel('????/Hz');xlabel('????/s');
% title('??????');
% m = 64;
% LightYellow = [0.6 0.6 0.6];
% MidRed = [0 0 0];
% Black = [0.5 0.7 1];
% Colors = [LightYellow; MidRed; Black];
% hold on
% ============ find min max frequency =================================================
[pxx,w] = pwelch(x1,'power');
%pxx=fastSmoo(pxx, 100);
dB = pow2db(pxx);
dB = fastSmoo(dB, 40, 1, 1);
figure()
plot(w/pi*Fs/2,dB)
%plot(dB)
hold on
%xlabel('\omega / \pi')
xlabel('Frequency (Hz)')
ylabel('Power (dB)')
%pwelch(x1,'power')
thr1=ceil(2500/(44100/2)*length(pxx));
thr2=floor(10000/(44100/2)*length(pxx));
diff_dB = diff(dB);
thr = diff_dB(thr1:thr2);
% mx=find(thr==max(thr));
% mn=find(thr==min(thr));
mx=find(thr>0.15);
mx=mx(1);
mn=find(thr<-0.2);
mn=mn(length(mn));
maxFreq=(mn+thr1)/length(dB)*(Fs/2);
minFreq=(mx+thr1)/length(dB)*(Fs/2);

max_dB=find(dB==max(dB(mx:mn)));
a=find(dB>(dB(max_dB)-25));
b=find(a>(mx+thr1) & a<(mn+thr1));
a=a(b);
sp=a(1);
minFreq2=sp/length(dB)*(Fs/2);
ep=a(length(a));
maxFreq2=ep/length(dB)*(Fs/2);

% loc=find(a==max_dB);
% while((loc+1)~=length(a)&&a(loc+1)-a(loc)==1)
% loc=loc+1;
% end
% ep=loc+1;
% maxFreq=ep/length(dB)*(Fs/2);
% while(a(loc)-a(loc-1)==1)
% loc=loc-1;
% end
% sp=loc;
% minFreq=sp/length(dB)*(Fs/2);
 maxfr = maxFreq; 
 minfr = minFreq;