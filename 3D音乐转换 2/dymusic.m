function [] = dymusic(dist,elev,flag,circle,step,fs,y)
% dist= 100;
% elev= 10;
% circle=3;
% flag=1;
% step = 5;
if flag==1
    az=0:step:360-step;
else
    az=360-step:-step:0;
end
nlock=360/step;


% [y, fs] = audioread('./muc.wav');

read_path = './PKU-IOA HRTF database/';
n=length(y)/circle;
mus=zeros(circle,n);

midnframe=360/step+1;
midframe=floor(size(mus,2)/midnframe);
frame=floor((size(mus,2)/midnframe))*2;

for i=1:circle
   mus(i,:)=y((i-1)*n+1:i*n);
end

w_1 = 1/midframe:1/midframe:1;
w_0 = 1-1/midframe:-1/midframe:0;
w=[w_1,w_0];

HLlist = zeros(nlock, 1024);
HRlist = zeros(nlock, 1024);
for j=1:nlock
   hrir_l = readhrir(read_path, dist, elev, az(j), 'l');
   HLlist(j,:)=hrir_l;
   hrir_r = readhrir(read_path, dist, elev, az(j), 'r');
   HRlist(j,:)=hrir_r;
end

data_lll=zeros(1,midframe*(nlock*circle+1));
data_rrr=zeros(1,midframe*(nlock*circle+1));
% 圈数要过渡处 平滑
% data_lll=[];
% data_rrr=[];
data_ll=zeros(circle,midframe*(nlock+1));
data_rr=zeros(circle,midframe*(nlock+1));

for i=1:circle
    for j=1:nlock
        data_l =conv(w.*mus(i,(j-1)*midframe+1:(midframe*(j-1)+frame)),HLlist(j,:),'same');
        data_r =conv(w.*mus(i,(j-1)*midframe+1:(midframe*(j-1)+frame)),HRlist(j,:),'same');
%         sound([data_l;data_r]',fs);
%         data_ll=[data_ll,data_l(1:midframe)];
%         data_rr=[data_rr,data_r(1:midframe)];
          data_ll(i,(j-1)*midframe+1:(midframe*(j-1)+frame))=data_ll(i,(j-1)*midframe+1:(midframe*(j-1)+frame))+data_l;
          data_rr(i,(j-1)*midframe+1:(midframe*(j-1)+frame))=data_rr(i,(j-1)*midframe+1:(midframe*(j-1)+frame))+data_r;
    end
         data_lll(1+(i-1)*midframe*nlock:((i-1)*midframe*nlock+midframe*(nlock+1)))=data_lll(1+(i-1)*midframe*nlock:((i-1)*midframe*nlock+midframe*(nlock+1)))+data_ll(i,:);
         data_rrr(1+(i-1)*midframe*nlock:((i-1)*midframe*nlock+midframe*(nlock+1)))=data_rrr(1+(i-1)*midframe*nlock:((i-1)*midframe*nlock+midframe*(nlock+1)))+data_rr(i,:);
%        data_lll=[data_lll,data_ll(i,:)];       
%        data_rrr=[data_rrr,data_rr(i,:)];
end
    sound([data_lll;data_rrr]',fs);
    audiowrite('end.wav',[data_ll;data_rr]',fs);
end




% data_ll=[];
% data_rr=[];
% for i=1:circle
%     for j=1:nlock
%            data_l = conv(mus(i,(j-1)*(n/nlock)+1:(j-1/2)*(n/nlock)), (HLlist(mod(nlock-1+j-1,nlock)+1,:).*w_0+HLlist(mod(nlock-1+j,nlock)+1,:).*w_1),'same');
%            data_r = conv(mus(i,(j-1)*(n/nlock)+1:(j-1/2)*(n/nlock)), (HRlist(mod(nlock-1+j-1,nlock)+1,:).*w_0+HRlist(mod(nlock-1+j,nlock)+1,:).*w_1),'same');
%            data_ll=[data_ll,data_l];
%            data_rr=[data_rr,data_r];
% %            sound([data_l', data_r'], fs);
% %            pause(length(data_l)/fs);
% 
%            data_l = conv(mus(i,(j-1/2)*(n/nlock)+1:j*(n/nlock)), (HLlist(mod(nlock-1+j,nlock)+1,:).*w_0+HLlist(mod(nlock-1+j+1,nlock)+1,:).*w_1),'same');
%            data_r = conv(mus(i,(j-1/2)*(n/nlock)+1:j*(n/nlock)), (HRlist(mod(nlock-1+j,nlock)+1,:).*w_0+HRlist(mod(nlock-1+j+1,nlock)+1,:).*w_1),'same');
% %            sound([data_l', data_r'],fs);
% %            pause(length(data_l)/fs);
%            data_ll=[data_ll,data_l];
%            data_rr=[data_rr,data_r];
%     end
% end
%     sound([data_ll;data_rr]',fs);
%     audiowrite('end.wav',[data_ll;data_rr]',fs);
% end

