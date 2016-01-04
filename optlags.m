function [ lags_out ] = optlags( lags_in, thr )
%OPTLAGS Optimize lag Vector from Xcorr
%   the Xcorr process don't give us the exact same value between
%   segments that should be consevutive so this function finds these cases
%   and resolve them.
%   thr => is the Threshold between Xcorr values
j=0;
lags_out=zeros(length(lags_in),1);
for i=1:length(lags_in)-1-j
    if i+j==length(lags_in)
        return
    else
        if lags_in(i+j)-thr<lags_in(i+j+1) && lags_in(i+j+1)<lags_in(i+j)+thr
            lags_out(i+j)=lags_in(i+j);
            lags_out(i+j+1)=lags_in(i+j);
            j=j+1;
        else
            lags_out(i+j)=lags_in(i+j);
            if i==length(lags_in)-1-j
                lags_out(i+j+1)=lags_in(i+j+1);
            end
        end
    end
end

