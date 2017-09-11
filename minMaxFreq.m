filename = sprintf('/Users/yijuwang/Desktop/spto/yw/song/s1.wav');
[x1, Fs]=audioread(filename);
[pxx,w] = pwelch(x1,'power');
dB = pow2db(pxx);
plot(w/pi,dB)
xlabel('\omega / \pi')
ylabel('Power (dB)')
pwelch(x1,'power')
thr=ceil(2000/(44100/2)*1025);
mx=find(dB==max(dB(thr:end)));
a=find(dB>(dB(mx)-45));
loc=find(a==mx);
while((loc+1)~=length(a)&&a(loc+1)-a(loc)==1)
loc=loc+1;
end
ep=loc+1;
maxFreq=ep/length(dB)*(Fs/2);
while(a(loc)-a(loc-1)==1)
loc=loc-1;
end
sp=loc;
minFreq=sp/length(dB)*(Fs/2);