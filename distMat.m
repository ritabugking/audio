temp=[];
for i=1:7
    
filename = sprintf('%s_%d.%s','/Users/yijuwang/Desktop/spto/yw/segment/seg', i, 'wav');
[x, Fs]=audioread(filename);

x=x(:,1); % one channel
%x=x-mean(x);				% zero-mean substraction
wlen=256; inc=128; win=hanning(wlen);% ??????????????????????
N=length(x); time=(0:N-1)/Fs;       % ????????
y=enframe(x,win,inc)';              % ????
fn=size(y,2);                       % ????
frameTime=(((1:fn)-1)*inc+wlen/2)/Fs; % ??????????????????
W2=wlen/2+1; n2=1:W2;
freq=(n2-1)*Fs/wlen;                % ????FFT????????????
Y=fft(y);  

%prominent region
for i=1:size(Y,2)
    peak=find(abs(Y(n2,i))==max(abs(Y(n2,i))));
    for j=n2
%         if (peak==1 || peak==length(n2))
%             if (peak==1)
%                 if(j~=peak && j~=peak+1)
%                     Y(j,i)=0;
%                 end
%             else
%                 if(j~=peak && j~=peak-1)
%                     Y(j,i)=0;
%                 end
%             end
%         elseif (j~=peak && j~=peak+1 && j~=peak-1)
        if (j~=peak && j~=peak+1 && j~=peak-1 && j~=peak+2 && j~=peak-2 && j~=peak+3 && j~=peak-3 && j~=peak+4 && j~=peak-4 && j~=peak+5 && j~=peak-5 && j~=peak+6 && j~=peak-6 && j~=peak+7 && j~=peak-7 && j~=peak+8 && j~=peak-8 && j~=peak+9 && j~=peak-9 && j~=peak+10 && j~=peak-10 && j~=peak+11 && j~=peak-11 && j~=peak+12 && j~=peak-12 && j~=peak+13 && j~=peak-13 && j~=peak+14 && j~=peak-14)
                Y(j,i)=0;
        end       
    end
end

d=[]; % calculate the distance bt template and data
for i=1:(size(Y,2)-size(yt,2)+1)
    k=sum(sum(abs((yt-Y(:,i:i+size(yt,2)-1)).^2).^0.5));
    d=[d,k];
end
loc = find(d==min(d));
%disp(d)
disp(loc)
disp(d(loc))
disp(mean(d))


temp=[temp; d(loc), mean(d)];

end