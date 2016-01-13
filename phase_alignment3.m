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
ws=1;       %window size parameter <--ws*fs--| fs |--ws*fs-->

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
aligned=zeros(fs*testN,1);
xc=cell(1,testN);
lag=cell(1,testN);


%% XCorrelation calc

% Zero-padding at REF borders
%padding unit
zp = {zeros(fs,1)};
for i=1:ws  
    refF = [zp refF zp];
    refN=refN+2;
end

coef=-ws:ws;
%init refw
refw=cell(1,2*ws+1);
searchwindow=cell(1,testN);

for i=1+ws:refN-ws
    %search segment under the window construction
        
    for j=1:2*ws+1
        refw{j}=refF{i+coef(j)};
    end
    
    %build the search window
    searchwindow{i-ws}={cat(1,refw{1:end})};
    
end

for i=1:testN
    %convert cell in array
    SW=cell2mat(searchwindow{i});
    % Xcorrelation
    [xc{i}, lag{i}]=xcorr(testF{i},SW);
    [M(i),I]=max(abs(xc{i}));
    lagVector(i)=lag{i}(I);
end

lagVector=optlags2(lagVector,40);

%lagVector(lagVector<0)=lagVector(lagVector<0)+2*ws*fs;
%lagVector(lagVector>0)=lagVector(lagVector>0)-2*ws*fs;
lagVector=lagVector+2*ws*fs;



%% Alignment

for i=1:testN

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
    if M(i) > 3
    start=((i-1)*fs)-lagVector(i);
    stop=(start+fs)-1;
    aligned(start:stop)=testF{i};
    end
    
   
    %{
    %Super Plots
    ta=0:1/Fs:(length(aligned)-1)/Fs;
    FigHandle = figure('Position', [100, 100, 1049, 895]);
    subplot(4,1,1), plot(refW{i}), ylabel('Ref')
    string=sprintf('Segment number %d',i);
    title(string)
    subplot(4,1,2), plot(testF{i}), ylabel('Test')
    subplot(4,1,3), plot(lag{i},abs(xc{i})), ylabel('XCorr')
    subplot(4,1,4), plot(ta,aligned), ylabel('aligned(start-fs:stop+fs)')
   subplot(5,1,5), plot(ta,aligned), ylabel('aligned')
    %}
end

aligned=aligned(ws*fs:end);




% ####################### Plots ################################

%% Plot each segment with search window and Xcorrelation graphs
refFplot={cat(1,refF{1:end})};
refFplot=cell2mat(refFplot);
trf=0:1/Fs:(length(refFplot)-1)/Fs;
testFplot={cat(1,testF{1:end})};
testFplot=cell2mat(testFplot);
ttf=0:1/Fs:(length(testFplot)-1)/Fs;
testNplot=testN;

for i=1:testNplot  
SWplot=cell2mat(searchwindow{i});
FigHandle = figure('Position', [100, 100, 949, 705]);  
%subplot(4,1,1), plot(trf,refFplot)
subplot(3,1,1), plot(trf,refFplot),hold on,plot(trf(((i-1)*fs)+1 : ((i-1)*fs)+length(SWplot) ),SWplot,'r'), ylabel('Ref')
string=sprintf('Segment number %d',i);
title(string)
subplot(3,1,2), plot(ttf,testFplot,'Color',[1 .5 0]), hold on, plot(ttf(((i-1)*fs)+1 : ((i-1)*fs)+length(testF{i}) ),testF{i},'Color', [0 0 .5]), ylabel('Test'),axis([-(ws*fs/Fs) 70-(ws*fs/Fs) -0.3 0.3])
subplot(3,1,3), plot(lag{i},abs(xc{i})), ylabel('XCorr')
end


%% Plot XCorrelation between entire tracks

[xcT, lagT]=xcorr(test,ref);
[xcA, lagA]=xcorr(aligned,ref);
figure
title('Cross correlation beteen reference and test (blue) and aligned (red) tracks)')
subplot(2,1,1), plot(lagT,xcT,'b'), ylabel('XCorr')
subplot(2,1,2), plot(lagA,xcA,'r'), ylabel('XCorr')


%% Plot Ref & Test Signals
figure
subplot(3,1,1), plot(tr,ref,'g','Color',[0,0.5,0]), ylabel('Ref')
string=sprintf('Reference & Test (.wav) Signals, with %d seconds segmentation',fd);
title(string)
subplot(3,1,2), plot(tt,test,'g','Color',[0,0.5,0]), ylabel('Test')
%Plot lags found in each segment
seg_lags=repelem(lagVector,fd);
seg_lags=seg_lags ./ Fs;
subplot(3,1,3), plot(1:length(seg_lags),seg_lags,'g','Color',[0,0.5,0]), xlabel('Time (s)'), ylabel('Lag time')


%% Plot xcorr max values for each segment
figure
string=sprintf('Values of xcorr peaks for track segments');
title(string)
x=1:testN;
stem(x,M,'filled','Color',[1,0.5,0],'LineWidth',2);
hold on
t(1:testN)=3;
plot(x,t,'g');


%% Plot refF & aligned signal
figure
subplot(2,1,1), plot(tr,ref,'b'), ylabel('Ref')
string=sprintf('Reference & Aligned (.wav) Signals, with %d seconds segmentation',fd);
title(string)
ta=0:1/Fs:(length(aligned)-1)/Fs;
subplot(2,1,2), plot(ta,aligned,'r'), ylabel('Align')


%% Export final aligned track
audiowrite('alignedFINAL.wav',aligned,Fs);
