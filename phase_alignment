%progetto allineamento tracce

%load audio files
[ref,ref_Fs]=audioread('reference2.wav');
[test,test_Fs]=audioread('test2.wav');

subplot(2,1,1);
plot(ref);
subplot(2,1,2);
plot(test);
%plot waveforms of original files
% plot(ref);
% hold on;
% plot(test);

%track segmentation
%frame duration
fd=4;%4 seconds
%frame size calc
fs=fd*ref_Fs;

%segmentation
[refF, refN]=segment(ref,fs,fs);
[testF, testN]=segment(test,fs,fs);

lag=zeros(10,1);

for i=1:refN
 
%cross correlation calc
xc=xcorr(testF{i},refF{i});
[M,I]=max(xc);
lag(i)=I;

end
%Steps:
%calcolo crosscorrelazione segmento per segmento
%estrazione samples di sfasamento segmento per segmento (plot grafico)
%compensazione sfasamento
