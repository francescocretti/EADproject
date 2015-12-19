function [F, N]  = segment(input,frame_size, shift)

%if shift==0
 %   overlap=0;
    
%else
    overlap=frame_size-shift;
%end

frames=buffer(input,frame_size,overlap,'nodelay');
%cell containing all segments
F=num2cell(frames,1);
%number of segments
N=length(F);
end
