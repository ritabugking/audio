num_seg=1;
for i=1:42
    
filename = sprintf('%s%d.%s','/Users/yijuwang/Desktop/spto/yw/yw', i, 'wav');
[y, Fs]=audioread(filename);
y=y(:,1); % one channel
y_test=y;

frameSize = 256;
overlap = 128;
y_test=y_test-mean(y_test);				% zero-mean substraction
frameMat=buffer2(y_test, frameSize, overlap);	% frame blocking
frameNum=size(frameMat, 2);			% no. of frames

% setting threshold
volume=frame2volume(frameMat);		% volume
volumeTh1=max(volume)*0.1;			% volume threshold 1
index1 = find(volume>volumeTh1);

% get segment sound
staEndMat=[];
i=1;
flag = 0;
while (i < length(index1)-1)
    n_start = index1(i);
    while ((index1(i+1) - index1(i)) == 1)
        if (i < length(index1)-1)
            i = i+1;
        end
    end
    n_end = index1(i);
    staEndMat = [staEndMat; n_start, n_end];    
    i=i+1;
end

seMat=[];
i=1;
while (i<size(staEndMat, 1)) % align all small syllables into one phrase
    s=staEndMat(i, 1);
    e=staEndMat(i, 2);
    while ((i+1) < size(staEndMat, 1)+1)
        if ((staEndMat(i+1,1)-staEndMat(i,2))<0.2*Fs/128)
            e=staEndMat(i+1, 2);
            i=i+1;
        else
            break;
        end
    end
    seMat=[seMat; s, e];
    i=i+1;
end

seMat=seMat.*128./Fs; % convert point scale into time scale

seg=[];
for i=1:size(seMat,1)
    if ((seMat(i,2)-seMat(i,1))>0.8) % if phrase length > 0.8s, keep it
        seg = [seg; seMat(i,1)-0.1, seMat(i,2)+0.1]; % add 0.1s at the front and end of phrase
    end
end


for i=1:size(seg,1) % get phrase segment from original file
    f = y_test(floor(seg(i,1)*Fs):ceil(seg(i,2)*Fs));
    filename = sprintf('%s_%d.%s','seg' ,num_seg, 'wav')
    audiowrite(filename,f,Fs);
    num_seg = num_seg+1;
end

end