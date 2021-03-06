%for i=1:7
    
filename = sprintf('/Users/yijuwang/Desktop/spto/yw/segment/seg1_7.wav');
[x, Fs]=audioread(filename);
%[x,Fs]=audioread('/Users/yijuwang/Desktop/spto/yw/ywt.wav'); 
%[x,Fs]=audioread('/Users/yijuwang/Desktop/spto/song2.wav', [1,Fs*0.1+1]); 
x=x(:,1); % one channel
%x=x-mean(x);				% zero-mean substraction

%x=x(22232:Fs*0.8+22232);% ????????????

%x=x(1:Fs*5+1);
% modulation = cos(3000/24000*pi*length(x));
% h = (5000/24000)*sinc((5000/24000)*length(x));
% h2 = 2*x.*modulation;


%h = (5000/24000)*sinc((5000/24000)*length(x));
%x = conv(h,x);

%x=x(Fs*0.2+1:Fs*0.8+1);
%x=downsample(x,2);
%x1=x;
%Fs=Fs/2;

% bandpass filter 2000-10000Hz
passBand=[1800, 11000];
[b, a]=butter(8, passBand/(Fs/2));
[h, w]=freqz(b, a);
x=filter(b, a, x);



wlen=256; inc=128; win=hanning(wlen);% ??????????????????????
N=length(x); time=(0:N-1)/Fs;       % ????????
y=enframe(x,win,inc)';              % ????
fn=size(y,2);                       % ????
frameTime=(((1:fn)-1)*inc+wlen/2)/Fs; % ??????????????????
W2=wlen/2+1; n2=1:W2;
freq=(n2-1)*Fs/wlen;                % ????FFT????????????
Y=fft(y);                           % ??????????????
%=====================================================
%prominent region
for i=1:size(Y,2)
    peak=find(abs(Y(n2,i))==max(abs(Y(n2,i))));
    for j=n2

        if (j~=peak && j~=peak+1 && j~=peak-1 && j~=peak+2 && j~=peak-2 && j~=peak+3 && j~=peak-3 && j~=peak+4 && j~=peak-4 && j~=peak+5 && j~=peak-5 && j~=peak+6 && j~=peak-6 && j~=peak+7 && j~=peak-7 && j~=peak+8 && j~=peak-8 && j~=peak+9 && j~=peak-9 && j~=peak+10 && j~=peak-10 && j~=peak+11 && j~=peak-11 && j~=peak+12 && j~=peak-12 && j~=peak+13 && j~=peak-13 && j~=peak+14 && j~=peak-14)
                Y(j,i)=0;
        end
        if (j==peak+1 || j==peak-1 || j==peak+2 || j==peak-2 || j==peak+3 || j==peak-3 || j==peak+4 || j==peak-4 || j==peak+5 || j==peak-5 || j==peak+6 || j==peak-6 || j==peak+7 || j==peak-7 || j==peak+8 || j==peak-8 || j==peak+9 || j==peak-9 || j==peak+10 || j==peak-10 || j==peak+11 || j==peak-11 || j==peak+12 || j==peak-12 || j==peak+13 || j==peak-13 || j==peak+14 || j==peak-14)
                if (abs(Y(j,i))<max(max(abs(Y)))*0.1) %%% maximal value of whole spectrogram 
                    Y(j,i) = 0;
                end
        end
    end
end
ywsg417=Y;
%clf                                 % ??????????
%=====================================================%
% Plot the STFT result              % ??????????        
%=====================================================%
figure()
set(gcf,'Position',[20 100 600 500]);            
axes('Position',[0.1 0.1 0.85 0.5]);  
imagesc(frameTime,freq,abs(Y(n2,:))); % ????Y??????  
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