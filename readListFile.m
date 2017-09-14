clear all; clc; close all;
% ====== read List file ======
for num_file=1:42
%for num_file=2
filename = sprintf('%s%d.%s','/Users/yijuwang/Desktop/spto/yw/txtList/yw', num_file, 'txt');
fileID = fopen(filename);
%fileID = fopen('/Users/yijuwang/Desktop/spto/yw/txtList/yw8.txt');
C = textscan(fileID,'%f %s %s %f','HeaderLines',1);
fclose(fileID);
startTime = C{:,1};
endTime = C{:,4};
phrase = string(C{:,3});


filename = sprintf('%s%d.%s','/Users/yijuwang/Desktop/spto/yw/yw', num_file, 'wav');
info = audioinfo(filename);
Fs = info.SampleRate;
n_total=info.TotalSamples;

minMax=[];
minMax2=[];
for i=1:length(startTime)
%for i=8
[x1, Fs]=audioread(filename, [floor(startTime(i)*Fs), floor(endTime(i)*Fs)]); 
% ============ find min max frequency =============
[pxx,w] = pwelch(x1,'power');
dB = pow2db(pxx);
dB = fastSmoo(dB, 400, 1, 1); % smoothing 
figure()
plot(w/pi*Fs/2,dB)
hold on
xlabel('Frequency (Hz)')
ylabel('Power (dB)')
%pwelch(x1,'power')
thr1=ceil(2500/(44100/2)*length(pxx)); % set frequency range from 2500-10000 Hz
thr2=floor(10000/(44100/2)*length(pxx));
diff_dB = diff(dB); % calculate dB slope
thr = diff_dB(thr1:thr2);

% ======= first method: find min & max frequency by steep slope ======

% mx=find(thr>max(thr)*0.9); % find slope > 0.15, set the most left one as minimum frequency
% mx=mx(1);
% mn=find(thr<min(thr)*0.9); % find slope < -0.2, set the most right one as maximum frequency
% mn=mn(length(mn));
% % test=find(thr==0); % find slope > 0.15, set the most left one as minimum frequency
% % mx=test(1);
% % mn=test(length(test));
% 
% maxFreq=(mn+thr1)/length(dB)*(Fs/2); 
% minFreq=(mx+thr1)/length(dB)*(Fs/2);
% minMax=[minMax, minFreq, maxFreq];
% ======= second method: find min & max  frequency by decibel threshold ===
max_dB=find(dB==max(dB(thr1:thr2)));
a=find(dB>(dB(max_dB)-10));
% b=find(a>(mx+thr1) & a<(mn+thr1));
% a=a(b);
% sp=a(1);
% minFreq2=sp/length(dB)*(Fs/2);
% ep=a(length(a));
% maxFreq2=ep/length(dB)*(Fs/2);
loc=find(a==max_dB);
while((loc+1)~=length(a)&&a(loc+1)-a(loc)==1)
loc=loc+1;
end
ep=a(loc)+1;
maxFreq=ep/length(dB)*(Fs/2);
while((loc-1)~=0 && a(loc)-a(loc-1)==1)
loc=loc-1;
end
sp=a(loc);
diff_dB2=diff(diff_dB);
% thr3 = find(diff_dB2>-0.0001 & diff_dB2<0.0001); % set the first reflection point as threshold
% thr3=thr3(find(thr3>thr1));

thr3 = diff_dB2(find(diff_dB2>-0.0001 & diff_dB2<0.0001));
thr3 = (find(diff_dB2>-0.0001 & diff_dB2<0.0001));
thr3=thr3(find(thr3>thr1));
thr3=thr3(find(thr3<max_dB));
if(isempty(thr3))
    thr3=thr1:max_dB;
    
    %reflect = find(abs(diff_dB2)==min(abs(diff_dB2(thr3))));
    
end
reflect = find(dB==min(dB(thr3))); % find the min dB point between thr1 to max dB = reflection point


%thr4 = reflect/length(dB)*(Fs/2);
if(~isempty(reflect))   % set min point to reflection
    if (dB(reflect)>dB(max_dB)-10)
        sp=reflect;
    else                % else, set point > threshold as min point
        a=a(find(a>thr1));
        a=a(find(a<max_dB));
        a=a(find(a>reflect));
        sp=a(1);
    end
end
minFreq=sp/length(dB)*(Fs/2);
minMax=[minMax, minFreq, maxFreq];

% max_dB=find(dB==max(dB(mx:mn)));
% a=find(dB>(dB(max_dB)-25)); % threshold = max dB - 25dB
% b=find(a>(mx+thr1) & a<(mn+thr1)); % find threshold within range of steep slope
% a=a(b);
% sp=a(1);
% minFreq2=sp/length(dB)*(Fs/2);
% ep=a(length(a));
% maxFreq2=ep/length(dB)*(Fs/2);
% minMax2=[minMax2, minFreq2, maxFreq2];
end
minMax = reshape(minMax, 2,[])';
minMax2 = reshape(minMax2, 2,[])';
min_=minMax(:,1);
max_=minMax(:,2);

%header = 'yw8';
header1=sprintf('%s%d','yw', num_file);
header2='start end phrase minFreq maxFreq'; 
formatSpec = '%f %f %s %f %f\n';
filename = sprintf('%s%d.%s','/Users/yijuwang/Desktop/spto/yw/txtList/f_yw', num_file, 'txt');
fid=fopen(filename,'w');
fprintf(fid, [ header1 '\n' header2 '\n']);
fprintf(fid, formatSpec, [[startTime, endTime, phrase, min_, max_]']);
fclose(fid);
end