%matlab function for audio segmentation with variable frame size and shift
%created by Francesco Cretti - December 2015

function [F, N]  = segment(input,frame_size, shift)

overlap=frame_size-shift;
frames=buffer(input,frame_size,overlap,'nodelay');
%cell containing all segments
F=num2cell(frames,1);
%number of segments
N=length(F);

end
