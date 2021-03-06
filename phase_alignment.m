%% Progetto 2016 - Elaborazione del Audio Digitale
% version 1.0

% Load audio files
[ref, Fs] = audioread('reference2.wav');
[test, FsT] = audioread('test2.wav');

% Time vectors
tr=0:1/Fs:(length(ref)-1)/Fs;
tt=0:1/Fs:(length(test)-1)/Fs;

fd=3;       %frame duration
fs=fd*Fs;   %frame size


%% track segmentation
% Segmentation
[refF, refN]=segment(ref,fs,fs);
[testF, testN]=segment(test,fs,fs);

%initialize vectors
lagVector=zeros(refN,1);
M=zeros(refN,1);
aligned=zeros(length(test),1);
xc=cell(1,refN);
resT=cell(1,refN);


%% XCorrelation calc
for i=1:refN
% Xcorrelation
[xc{i}, lag]=xcorr(testF{i},refF{i});
[M(i),I]=max(abs(xc{i}));
lagVector(i)=lag(I);
end

lagVector=optlags2(lagVector,40);

%% Plot Xcorr segment graphs
for i=1:refN
figure
subplot(3,1,1), plot(refF{i}), ylabel('Ref')
string=sprintf('Segment number %d',i);
title(string)
subplot(3,1,2), plot(testF{i}), ylabel('Test')
subplot(3,1,3), plot(lag,abs(xc{i})), ylabel('XCorr')
end

%% Alignment solution 1
for i=1:refN
% if lagVector(i)>0
%     
%     resT{i}=padarray(testF{i}(lagVector(i)+1:end),[lagVector(i) 0],'post');
%     
%     %resR=padarray(refF{1},[lag(I) 0],'pre');
% else
%     resT{i}=padarray(testF{i}(1:end-lagVector(i)-1),[lagVector(i) 0],'pre');
%     %resR=padarray(refF{1},[lag(I) 0],'post');
% end

%% Alignment solution 2

if i==1
    if sign(lagVector(i)) == 1
        resT=padarray(testF{i}(lagVector(i)+1:end),[lagVector(i) 0],'post');
        aligned(1:(i*fs))=resT;
        %Problem: Information losses at the beginin of the segment
    elseif sign(lagVector(i)) == -1
        resT=padarray(testF{i},[lagVector(i) 0],'pre');
        aligned(1:fs+abs(lagVector(i)))=resT;
        %Problem: Information loses at the end of the segment when Segment
        %i=2 overlaps
    else
        aligned(1:fs)=testF{i};
    end
else
    start=((i-1)*fs)-lagVector(i);
    stop=(start+fs)-1;
    aligned(start:stop)=testF{i};

end


end


%% XCorrelation between entire tracks

[xcT, lagT]=xcorr(test,ref);
[xcA, lagA]=xcorr(aligned,ref);
%audiowrite('aligned.wav',aligned,Fs);

% plots
figure
title('Cross correlation beteen reference and test (blue) and aligned (red) tracks)')
subplot(2,1,1), plot(lagT,xcT,'b'), ylabel('XCorr')
subplot(2,1,2), plot(lagA,xcA,'r'), ylabel('XCorr')


%% Plots

% Graph: Ref & Test Signals
figure
subplot(3,1,1), plot(tr,ref,'Color',[0,0.5,0]), ylabel('Ref')
string=sprintf('Reference & Test (.wav) Signals, with %d seconds segmentation',fd);
title(string)
subplot(3,1,2), plot(tt,test,'Color',[0,0.5,0]), ylabel('Test')
%Plot lags found in each segment
seg_lags=repelem(lagVector,fd);
seg_lags=seg_lags ./ Fs;
subplot(3,1,3), plot(1:(i*fd),seg_lags,'Color',[0,0.5,0]), xlabel('Time (s)'), ylabel('Lag time')

% plot xcorr max values for each segment
figure
string=sprintf('Values of xcorr peaks for track segments');
title(string)
x=1:i;
stem(x,M,'filled','Color',[1,0.5,0],'LineWidth',2);
hold on
t(1:i)=0.09;
plot(x,t,'g');

%plot aligned signal
ta=0:1/Fs:(length(aligned)-1)/Fs;
figure
subplot(2,1,1), plot(tr,ref,'r'), ylabel('Ref')
string=sprintf('Reference & Test (.wav) Signals, with %d seconds segmentation',fd);
title(string)
subplot(2,1,2), plot(ta,aligned,'r'), ylabel('Test')
