%% Progetto 2016 - Elaborazione del Audio Digitale

% Load audio files
[ref, Fs] = audioread('reference2.wav');
[test, FsT] = audioread('test2.wav');

% Time vectors
tr=0:1/Fs:(length(ref)-1)/Fs;
tt=0:1/Fs:(length(test)-1)/Fs;

%% track segmentation
fd=4;       %frame duration: 4 seconds
fs=fd*Fs;   %frame size

% Segmentation
[refF, refN]=segment(ref,fs,fs);
[testF, testN]=segment(test,fs,fs);

%initialize vector for lags
lagVector=zeros(refN,1);

%% XCorrelation calc and plot graphs
i=1;
%for i=1:refN;
    
% Graph: Segments
figure
subplot(3,1,1), plot(refF{i}), ylabel('Ref')
string=sprintf('Segment number %d',i);
title(string)
subplot(3,1,2), plot(testF{i}), ylabel('Test')

%Xcorrelation
[xc, lag]=xcorr(testF{i},refF{i});
[M,I]=max(abs(xc));
lagVector(i)=lag(I);
% Graph Extra: Xcorr
subplot(3,1,3), plot(lag,abs(xc)), ylabel('XCorr')
resR=refF{i};
%end

%% Plot lags found in each segment


% Graph: Ref & Test Signals
figure
subplot(3,1,1), plot(tr,ref), ylabel('Ref')
string=sprintf('Reference & Test (.wav) Signals, with %d seconds segmentation',fd);
title(string)
subplot(3,1,2), plot(tt,test), ylabel('Test')
seg_lags=repelem(lagVector,fd);
seg_lags=seg_lags ./ Fs;
subplot(3,1,3), plot(1:(15*fd),seg_lags), xlabel('Time (s)'), ylabel('Lag time')

%%

if lag(I)>0
    
    resT=padarray(testF{i}(lag(I)+1:end),[lag(I) 0],'post');
    
    %resR=padarray(refF{1},[lag(I) 0],'pre');
else
    resT=padarray(testF{i}(1:end-lag(I)-1),[lag(I) 0],'pre');
    %resR=padarray(refF{1},[lag(I) 0],'post');
end

tR=0:1/Fs:(length(resT)-1)/Fs;
% Graph: Segments(i=1) synchronized
figure
subplot(2,1,1), plot(tR,resR), ylabel('Ref'), %axis([3.2 4.5 -0.6 0.6])
title('First Segments(i=1) synchronized')
subplot(2,1,2), plot(tR,resT), ylabel('Test'), %axis([3.2 4.5 -0.18 0.18])

