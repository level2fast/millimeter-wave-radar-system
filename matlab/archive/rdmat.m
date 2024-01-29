% This program form an image of multiple target. Please first run the
% FMCW.m program to generate the signal data.
% Maybe there are still some shortcomings, because moving target detection
% is a difficult problem and its solving need too many knowledge. For
% example the velocity ambiguity problem is not solved in the program,
% it can be solved by other method. In this program, using the default
% parameter, the max and min velocity can be detected is nearly 150m/s and
% -149m/s.
% by Li HN, June 2020. 443303682@qq.com
clear all;
close all;
load fmcwmatlab2018data;
x=cube;
[nrn,nan]=size(x);
matchingcoeff=getMatchedFilter(waveform);
mlength=length(matchingcoeff);
lambda=c/fc;
fx=fftshift((linspace(-prf/2,prf/2-prf/nan,nan))*2*pi);
Vel=-fx/2*lambda/2/pi;
ts=(0/fs:1/fs:(nrn-1)/fs).';
% Eliminating the frequency shift in frequncy domain
x=fft(x,nrn,1);
x=fft(x,nan,2);
u=exp(1i*4*pi/lambda*(ts*Vel));  %
u=fft(u,nrn,1);
for k=1:nan
    x3=cconv(x(:,k),u(:,k),nrn);
    x(:,k)=x3/nrn;
end
x=ifft(x,nrn,1);
x=ifft(x,nan,2);
% Construct the signal generating matrix
z=zeros(nrn,nrn-mlength);
Rs=0:Rresolution:(nrn-1)*Rresolution;
L=(4*pi*Rs*2/lambda).^2;
L=L/max(abs(L));
L=1./L;
L(1)=L(2)*1;
L(end-mlength+1:end)=ones(mlength,1);
for k=1:nrn-mlength
    z(:,k)=circshift(sig,k-1)*L(k);
end
% the noise added to the signal
noiseadd=[wgn(nrn-mlength+1,mlength,20*log10(2.0324*1e-9),'complex');zeros(mlength-1,mlength)];
for k=1:mlength
    noiseadd(:,k)=circshift(noiseadd(:,k),k-1);
end
z=[z noiseadd];
% Solve the problem throught the Least Square method
x=pinv(z'*z)*z'*x;
% Because for close range and high speed targets, the side lobe in the velocity direction is very
% high, so the chebwin window is added to lower the side lobe. This step
% perhaps is  unnecessary for far range target such as farther than 5
% meters;
w=chebwin(nan);
for k=1:nrn
    x(k,:)=x(k,:).*w.';
end
x=fft(x,nan,2);
x=fftshift(x,2);
% Because for close range and high speed targets, the side lobe severely
% effect the detection, so for far range such as farther than 5 meters, these
% lines need not be zeroed.
x(:,1)=0*x(:,1);
x(:,2)=0*x(:,2);
x(:,end)=0*x(:,end);
x(:,end-1)=0*x(:,end-1);
V=fftshift(Vel);
[Vgrid,Rgrid]=meshgrid(V,Rs);
figure;mesh(Vgrid,Rgrid,abs(x));axis tight;
figure;imagesc(V,Rs,abs(x));grid on;axis tight;
xlabel('Vel');ylabel('Range');
