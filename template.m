filename = sprintf('/Users/yijuwang/Desktop/spto/yw/ywt.wav');
[x, Fs]=audioread(filename);
x=x(:,1); % one channel

% bandpass filter 2000-10000Hz
passBand=[1800, 11000];
[b, a]=butter(8, passBand/(Fs/2));
[h, w]=freqz(b, a);
x=filter(b, a, x);


% enframe
wlen=256; inc=128; win=hanning(wlen);
N=length(x); time=(0:N-1)/Fs;       
y=enframe(x,win,inc)';              
fn=size(y,2);                       
frameTime=(((1:fn)-1)*inc+wlen/2)/Fs; 
W2=wlen/2+1; n2=1:W2;
freq=(n2-1)*Fs/wlen;                
Y=fft(y);                           

%prominent region
for i=1:size(Y,2)
    %peak=find(abs(Y(n2,i))==max(abs(Y(n2,i))));
    peak=find(abs(Y(n2,i))==max(abs(Y(n2,i))));
    for j=n2
        for k=1:14
            if (j==peak)
            elseif(j==peak+k || j==peak-k)
                if (abs(Y(j,i))<max(max(abs(Y)))*0.1) %%% maximal value of whole spectrogram 
                    Y(j,i) = 0;
                end
            else
                Y(j,i)=0;
            end
        end
    end
end
ywt=Y;
ywt=abs(ywt)>0; % make a template
%=====================================================%
% Plot the STFT result              % ??????????        
%=====================================================%
figure()
set(gcf,'Position',[20 100 600 500]);            
axes('Position',[0.1 0.1 0.85 0.5]);  
%imagesc(frameTime,freq,abs(Y(n2,:))); % ????Y??????
imagesc(frameTime,freq,abs(ywt)); % ????Y??????
axis xy; ylabel('????/Hz');xlabel('????/s');
title('??????');
m = 64;
LightYellow = [0.6 0.6 0.6];
MidRed = [0 0 0];
Black = [0.5 0.7 1];
Colors = [LightYellow; MidRed; Black];
colormap(SpecColorMap(m,Colors));
hold on
%=====================================================%
% Plot the Speech Waveform          % ??????????????????  
%=====================================================%

axes('Position',[0.07 0.72 0.9 0.22]);
plot(time,x,'k');
xlim([0 max(time)]);
xlabel('Time/s'); ylabel('Frequency');
title('spectrogram');

%end