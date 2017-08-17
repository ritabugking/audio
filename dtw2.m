% Copyright (C) 2013 Quan Wang <wangq10@rpi.edu>,
% Signal Analysis and Machine Perception Laboratory,
% Department of Electrical, Computer, and Systems Engineering,
% Rensselaer Polytechnic Institute, Troy, NY 12180, USA

% dynamic time warping of two signals
s=[2;3;5];
t=[1;1;2;3;3;5;5;6;6;7;8;9];



%function d=dtw(s,t,w)
% s: signal 1, size is ns*k, row for time, colume for channel 
% t: signal 2, size is nt*k, row for time, colume for channel 
% w: window parameter
%      if s(i) is matched with t(j) then |i-j|<=w
% d: resulting distance

% if nargin<3
    w=Inf;
% end

ns=size(s,1);
nt=size(t,1);
if size(s,2)~=size(t,2)
    error('Error in dtw(): the dimensions of the two input signals do not match.');
end
w=max(w, abs(ns-nt)); % adapt window size

%% initialization
D=zeros(ns+2,nt+2)+Inf; % cache matrix
D(1,1)=0;
D(2,2)=0;

% %% begin dynamic programming
% for i=1:ns
%     for j=max(i-w,1):min(i+w,nt)
%         oost=norm(s(i,:)-t(j,:));
%         D(i+1,j+1)=oost+min( [D(i,j+1), D(i+1,j), D(i,j)] );
%         
%     end
% end
% d=D(ns+1,nt+1);
oost=zeros(ns+1,nt+1)+Inf;
for i=1:ns
    for j=max(i-w,1):min(i+w,nt)
        oost(i+1,j+1)=norm(s(i,:)-t(j,:));
    end
end
       

%% begin dynamic programming
for i=1:ns
    for j=max(i-w,1):min(i+w,nt)
        D(i+2,j+2)=oost(i+1,j+1)+min([D(i,j+1)+oost(i,j+1), D(i+1,j)+oost(i+1,j), D(i+1,j+1)]);
%         if (min([D(i,j+1)+oost(i,j+1), D(i+1,j)+oost(i+1,j), D(i+1,j+1)])==D(i+1,j+1))
%             fprintf('(%d, %d)', i, j);
%         elseif (min([D(i,j+1)+oost(i,j+1), D(i+1,j)+oost(i+1,j), D(i+1,j+1)])==D(i+1,j)+oost(i+1,j))           
%             fprintf('(%d, %d)', i+1, j);
%             fprintf('(%d, %d)', i, j-1);
%         else
%             fprintf('(%d, %d)', i, j+1);
%             fprintf('(%d, %d)', i-1, j);
%         end
    end
end
%d=D(ns+2,nt+2);
d=D(ns+2,nt+2);
d_len=nt+2;
while(min(D(:,d_len)==Inf))
    d_len=d_len-1;
    d=min(D(:,d_len));
end
