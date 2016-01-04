function [ lags_out ] = optlags2( lags_in, thr )
%OPTLAGS2 Optimize lag Vector from Xcorr
%   version 2.0
%   the Xcorr process don't give us the exact same value between
%   segments that should be consevutive so this function finds these cases
%   and resolve them.
%   thr => is the Threshold between Xcorr values

lags_out=zeros(length(lags_in),1);
flag=0;
for i=1:length(lags_in)-1
    if lags_in(i)-thr<lags_in(i+1) && lags_in(i+1)<lags_in(i)+thr
        if flag==0
        lags_out(i)=lags_in(i);
        lags_out(i+1)=lags_in(i);
        else
            lags_out(i+1)=lags_out(i);
        end
        flag=1;
    else
        if flag==0
        lags_out(i)=lags_in(i);
        end
        if i==length(lags_in)-1
            lags_out(i+1)=lags_in(i+1);
        end
        flag=0;
    end
end

