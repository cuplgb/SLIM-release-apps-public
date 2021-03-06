function convacq_2arrays(flipflop, tfireint_min, ns, dt, boatspeed, fig)

%--------------------------------------------------------------------------------------------------------------------
% convacq_2arrays plots a conventional acquisition scenario (i.e., no overlaps between adjacent shot gathers)
%
% Use: 
%   convacq_2arrays(flipflop, tfireint_min, ns, dt, boatspeed, fig)  
%
% Input:
%         flipflop - plot a flipflop acquisition scenario ('yes' or 'no')
%     tfireint_min - minimal interval between firing times (in seconds), which cannot be violated for a
%                    pragmatic acquisition scenario (default is 10.0s)
%               ns - number of sources
%               dt - sampling interval
%        boatspeed - speed of the boat (in meters/second)
%              fig - plot the acquisition scenario ('yes' or 'no')

% Author: Haneet Wason
%         Seismic Laboratory for Imaging and Modeling
%         Department of Earth, Ocean, and Atmospheric Sciences
%         The University of British Columbia
%         
% Date: April, 2013

% You may use this code only under the conditions and terms of the
% license contained in the file LICENSE provided with this source
% code. If you do not agree to these terms you may not use this
% software.
%--------------------------------------------------------------------------------------------------------------------

% Determine type of acquisition
if strcmp(flipflop, 'yes')
   tfirearr1 = 0.0 : 2*tfireint_min : (ns-1)*tfireint_min; 
   tfirearr2 = tfireint_min : 2*tfireint_min : ns*tfireint_min; 
elseif strcmp(flipflop, 'no')
   tfirearr1 = tfireint_min : 2*tfireint_min : ns*tfireint_min;
   tfirearr2 = tfirearr1;
end

% Firing time grid indices
tfiregrid = 0.0 : dt : tfirearr2(end);
tfiregridINDarr1 = zeros(1,length(tfirearr1)); 
tfiregridINDarr2 = zeros(1,length(tfirearr2)); 
for j = 1:length(tfirearr2)
    indarr1 = find(tfiregrid <= tfirearr1(j));
    tfiregridINDarr1(j) = indarr1(end);
    indarr2 = find(tfiregrid <= tfirearr2(j));
    tfiregridINDarr2(j) = indarr2(end); 
end

% Source positions
sposarr1 = boatspeed*tfirearr1;
sposarr2 = boatspeed*tfirearr2;

% Plot acquisition scenario
if strcmp(fig, 'yes')
   figure 
   plot(sposarr1, tfirearr1, 'o', sposarr2, tfirearr2, 'b*'); legend('Array 1', 'Array 2'); 
   axis ij, axis('tight'); grid on; xlabel('Source position (m)'); ylabel('Recording time (s)'); 

   if strcmp(flipflop, 'yes')
      title('Conventional acquisition (flipflop)');
   elseif strcmp(flipflop, 'no')
      title('Conventional acquisition');
   end

end

end  % function end

