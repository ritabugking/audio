
for num_file=1:42

filename = sprintf('%s%d.%s','/Users/yijuwang/Desktop/spto/yw/yw', num_file, 'wav');
info = audioinfo(filename);
Fs = info.SampleRate;
n_total=info.TotalSamples;

chunkDuration = 30; % 30 sec
numSamplesPerChunk = chunkDuration*Fs;
startLoc = 1;
endLoc = min(startLoc + numSamplesPerChunk - 1, info.TotalSamples);
num_seg=1;
flag = 0;


while (endLoc < info.TotalSamples+1)
%for startLoc = 1:numSamplesPerChunk:info.TotalSamples
    %endLoc = min(startLoc + numSamplesPerChunk - 1, info.TotalSamples);
    y = audioread(filename, [startLoc endLoc]);    




%[y, Fs]=audioread(filename);
y=y(:,1); % one channel

% bandpass filter 2000-10000Hz
passBand=[1800, 11000];
[b, a]=butter(8, passBand/(Fs/2));
[h, w]=freqz(b, a);
y=filter(b, a, y);


y_test=y;

frameSize = 256;
overlap = 128;
y_test=y_test-mean(y_test);				% zero-mean substraction
frameMat=buffer2(y_test, frameSize, overlap);	% frame blocking
frameNum=size(frameMat, 2);			% no. of frames

% setting threshold
volume=frame2volume(frameMat);		% volume
volumeTh1=max(volume)*0.2;	
%volumeTh1=0.9;
%volumeTh1=median(volume)*8;			% volume threshold 1
%volumeTh1=median(volume)*5;
%volumeTh1=9;
index1 = find(volume>volumeTh1);

% get segment sound
staEndMat=[];
i=1;
if (length(index1)>0)
while (i < length(index1)-1)
    n_start = index1(i);
    while ((index1(i+1) - index1(i)) == 1)
        if (i < length(index1)-1)
            i = i+1;
        else
            break;
        end
    end
    n_end = index1(i);
    staEndMat = [staEndMat; n_start, n_end];    
    i=i+1;
end
end

seMat=[];
i=1;
if (size(staEndMat,1)>0)
while (i<size(staEndMat, 1)) % align all small syllables into one phrase
    s=staEndMat(i, 1);
    e=staEndMat(i, 2);
    while ((i+1) < size(staEndMat, 1)+1)
        if ((staEndMat(i+1,1)-staEndMat(i,2))*128 < floor(0.2*Fs)) % convert to n point to compare
            e=staEndMat(i+1, 2);
            i=i+1;
        else
            break;
        end
    end
    seMat=[seMat; s, e];
    i=i+1;
end
end

seMat2=[];
if (size(seMat,1)>0)
if ((endLoc < info.TotalSamples+1) && (seMat(size(seMat,1), 2)*128 > floor(length(y_test)-Fs*0.1))) % if there is a sound bt two chunks
%     endLoc = endLoc + numSamplesPerChunk - 1;
%     startLoc = (seMat(size(seMat,1), 1)-1)*128+1; % convert to n point
%     %endLoc = min(startLoc + numSamplesPerChunk - 1, info.TotalSamples);
%     seMat2 = seMat(1:size(seMat,1)-1, :);
    flag = 1;
    seMat2 = seMat;
    startLoc = startLoc + numSamplesPerChunk;
    endLoc = endLoc + numSamplesPerChunk - 1;

else
    seMat2 = seMat;
    startLoc = startLoc + numSamplesPerChunk;
    endLoc = endLoc + numSamplesPerChunk - 1;
end
else
    startLoc = startLoc + numSamplesPerChunk;
    endLoc = endLoc + numSamplesPerChunk - 1;
end

%seMat2=seMat2.*128./Fs; % convert point scale into time scale
%convert to sample point number
seg=[];
if (size(seMat2,1)>0)
for i=1:size(seMat2,1)
    if ((seMat2(i,2)-seMat2(i,1))*128>floor(0.8*Fs)) % if phrase length > 0.8s, keep it
        seg = [seg; max(seMat2(i,1)*128-127-floor(0.2*Fs),1), min((seMat2(i,2)-1)*128+1+floor(0.1*Fs), length(y_test))]; % add 0.1s at the front and end of phrase
    end
end
end

if (size(seg,1)>0)
for i=1:size(seg,1) % get phrase segment from original file
    f = y_test(max(seg(i,1),1):seg(i,2));
    if (flag && num_seg>1)  % if there is a sound bt two chunks, align them into one wav file
        filename_t = sprintf('%s%d_%d.%s','/Users/yijuwang/Desktop/spto/yw/segment/seg', num_file, num_seg-1, 'wav');
        [yy, Fss]=audioread(filename_t);
        f = [yy; f];
        filename2 = sprintf('%s%d_%d.%s','/Users/yijuwang/Desktop/spto/yw/segment/seg', num_file, num_seg, 'wav');
        audiowrite(filename2,f,Fs);
        num_seg = num_seg+1;       
        flag = 0;
    else
    filename2 = sprintf('%s%d_%d.%s','/Users/yijuwang/Desktop/spto/yw/segment/seg', num_file, num_seg, 'wav');
    audiowrite(filename2,f,Fs);
    num_seg = num_seg+1;
    end
end
end
end

end