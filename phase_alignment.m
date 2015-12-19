%% Progetto 2016 - Elaborazione del Audio Digitale

% Load audio files
[ref, Fs, nbits] = wavread('reference2.wav');
[test, FsT, nbits] = wavread('test2.wav');

% Time vectors
tr=0:1/Fs:(length(ref)-1)/Fs;
tt=0:1/Fs:(length(test)-1)/Fs;

% Graph: Ref & Test Signals
figure
subplot(2,1,1), plot(tr,ref), ylabel('Ref')
title('Reference & Test (.wav) Signals')
subplot(2,1,2), plot(tt,test), xlabel('Time (s)'), ylabel('Test')


%% track segmentation
fd=4;       %frame duration: 4 seconds
fs=fd*Fs;   %frame size

% Segmentation
[refF, refN]=segment(ref,fs,fs);
[testF, testN]=segment(test,fs,fs);
i=2;
% Graph: Segments(i=1)
figure
subplot(3,1,1), plot(refF{i}), ylabel('Ref')
title('First Segments(i=1)')
subplot(3,1,2), plot(testF{i}), ylabel('Test')


%% XCorrelation
[xc, lag]=xcorr(testF{i},refF{i});
[M,I]=max(abs(xc));

% Graph Extra: Xcorr
subplot(3,1,3), plot(lag,abs(xc)), ylabel('XCorr')
resR=refF{i};
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

