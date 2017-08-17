[y, fs]=audioread('/Users/yijuwang/Desktop/spto/yw/yw2.wav');
y=y(:,1); % one channel
y_test=y(1:end); % one minute

frameSize = 256;
overlap = 128;
y_test=y_test-mean(y_test);				% zero-mean substraction
frameMat=buffer2(y_test, frameSize, overlap);	% frame blocking
frameNum=size(frameMat, 2);			% no. of frames
volume=frame2volume(frameMat);		% volume
volumeTh1=median(volume)*1.5;			% volume threshold 1
index1 = find(volume>volumeTh1);
endPoint1=frame2sampleIndex([index1(1), index1(end)], frameSize, overlap);
figure()
subplot(2,1,1);
time=(1:length(y_test))/fs;
plot(time, y_test);
ylabel('Amplitude'); title('Waveform');
axis([-inf inf -1 1]);
line(time(endPoint1(  1))*[1 1], [-1, 1], 'color', 'm');
line(time(endPoint1(end))*[1 1], [-1, 1], 'color', 'm');
subplot(2,1,2);
frameTime=frame2sampleIndex(1:frameNum, frameSize, overlap);
plot(frameTime, volume, '.-');
ylabel('Sum of Abs.'); title('Volume');
axis tight;
line([min(frameTime), max(frameTime)], volumeTh1*[1 1], 'color', 'm');