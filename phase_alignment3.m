%% Progetto 2016 - Elaborazione del Audio Digitale
% version 3.0

% Load audio files
[ref, Fs] = audioread('reference2.wav');
[test, FsT] = audioread('test2.wav');

% Time vectors
tr=0:1/Fs:(length(ref)-1)/Fs;
tt=0:1/Fs:(length(test)-1)/Fs;

%% track segmentation
fd=3;       %frame duration
fs=fd*Fs;   %frame size
ws=1;      %window size parameter <--ws*fs--| fs |--ws*fs-->

% Segmentation
[refF, refN]=segment(ref,fs,fs);
[testF, testN]=segment(test,fs,fs);

% Set test & ref to the same length
diff=abs(refN-testN);
zp = {zeros(fs,1)};     %zero-padding unit
if refN~=testN
    if refN<testN
        for i=1:diff
            refF = [refF zp];
            refN = refN+1;
        end
    else
        for i=1:diff
            testF = [testF zp];
            testN = testN+1;
        end        
    end
end

%initialize vectors
lagVector=zeros(testN,1);
M=zeros(refN,1);
aligned=zeros(length(test),1);
xc=cell(1,testN);
lag=cell(1,testN);
refw=cell(1,2*ws+1);
refW=cell(1,testN);


%% XCorrelation calc
    
coef=-ws:ws;
% Zero-padding at REF borders
for i=1:ws
    zp = {zeros(fs,1)};
    refF = [zp refF zp];
end
for i=1+ws:testN-ws
    %search segment under the window construction
    refw=cell(1,2*ws+1);    %init refw
    for j=1:2*ws+1
        refw{j}=refF{i+coef(j)};
    end
    refw=[refw{1:2*ws+1}];
    refW{i}=reshape(refw,[],1);
    % Xcorrelation
    [xc{i}, lag{i}]=xcorr(testF{i},refW{i});
    [M(i),I]=max(abs(xc{i}));
    lagVector(i)=lag{i}(I);
end

%lagVector=lagVector(1+ws:end-ws);
lagVector=optlags2(lagVector,40);

%% Plot Xcorr segment graphs
%{
for i=1:refN
figure
subplot(3,1,1), plot(refW{i}), ylabel('Ref')
string=sprintf('Segment number %d',i);
title(string)
subplot(3,1,2), plot(testF{i}), ylabel('Test')
subplot(3,1,3), plot(lag{i},abs(xc{i})), ylabel('XCorr')
end
%}
%% Alignment
for i=1+ws:testN-ws

%{
if i==1+ws
    if sign(lagVector(i)) == 1
        resT=padarray(testF{i}(lagVector(i)+1:end),[lagVector(i) 0],'post');
        aligned(1:fs)=resT;
        %Problem: Information loses at the beginin of the segment
    elseif sign(lagVector(i)) == -1
        resT=padarray(testF{i},[lagVector(i) 0],'pre');
        aligned(1:fs+abs(lagVector(i)))=resT;
        %Problem: Information loses at the end of the segment when Segment
        %i=2 overlaps
    else
        aligned(1:fs)=testF{i};
    end
    
else
    %}
    if M(i) > 0.1
    start=((i-1)*fs)-lagVector(i);
    stop=(start+fs)-1;
    aligned(start:stop)=testF{i};
    end
end
%end

%% XCorrelation between entire tracks
%{
[xcT, lagT]=xcorr(test,ref);
[xcA, lagA]=xcorr(aligned,ref);
%audiowrite('aligned.wav',aligned,Fs);

% plots
figure
title('Cross correlation beteen reference and test (blue) and aligned (red) tracks)')
subplot(2,1,1), plot(lagT,xcT,'b'), ylabel('XCorr')
subplot(2,1,2), plot(lagA,xcA,'r'), ylabel('XCorr')
%}

%% Plots

% Graph: Ref & Test Signals
figure
subplot(3,1,1), plot(tr,ref,'g'), ylabel('Ref')
string=sprintf('Reference & Test (.wav) Signals, with %d seconds segmentation',fd);
title(string)
subplot(3,1,2), plot(tt,test,'g'), ylabel('Test')
%Plot lags found in each segment
%seg_lags=repelem(lagVector,fd);
%seg_lags=seg_lags ./ Fs;
%subplot(3,1,3), plot(1:(i*fd),seg_lags,'g'), xlabel('Time (s)'), ylabel('Lag time')

%plot refF & aligned signal
refFp=[refF{1:end}];
refFp=reshape(refFp,[],1);
trp=0:1/Fs:(length(refFp)-1)/Fs;
ta=0:1/Fs:(length(aligned)-1)/Fs;
figure
subplot(2,1,1), plot(trp,refFp,'b'), ylabel('Ref')
string=sprintf('Reference & Align (.wav) Signals, with %d seconds segmentation',fd);
title(string)
subplot(2,1,2), plot(ta,aligned,'r'), ylabel('Align')

audiowrite('refFINAL.wav',refFp,Fs);
audiowrite('alignedFINAL.wav',aligned,Fs);