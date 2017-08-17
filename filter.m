filename = sprintf('%s%d.%s','/Users/yijuwang/Desktop/spto/yw/yw', 1, 'wav');
[x, fs]=audioread(filename);


% ====== band-pass filter
passBand=[1800, 11000];
[b, a]=butter(8, passBand/(fs/2));
[h, w]=freqz(b, a);

y=filter(b, a, x);
filename = sprintf('%s_%d.%s','/Users/yijuwang/Desktop/spto/yw/ywfiltertest', 1, 'wav');
audiowrite(filename,y,Fs);