classdef opCurveletNoFFT < opSpot
%OPCURVELET  Two-dimensional curvelet operator.
%
%   opCurveletNoFFT(M,N,NBSCALES,NBANGLES,FINEST,TTYPE,IS_REAL) creates a
%   two-dimensional curvelet operator for M by N matrices. The curvelet
%   transform is computed using the Curvelab code, but it requires the
%   image to be alredy in spectral domain. E.g. it can be used to replace
%   FFT with other Fourier transforms, like NFFT.
%
%   The remaining five parameters are optional; NBSCALES gives the number
%   of scales and is set to max(1,ceil(log2(min(M,N)) - 3)) by default, as
%   suggested by Curvelab. NBANGLES gives the number of angles at the
%   second coarsest level which must be a multiple of four with a minimum
%   of 8. By default NBANGLES is set to 16. FINEST sets whether to include
%   the finest scale of coefficients and is set to 0 by default; set this
%   to 1 to include the finest scale, or to 2 to keep the finest scale but
%   set it to zeros. IS_REAL sets whether the transform cooefs are real
%   or complex.
%
%   Note: The furier coefficients on input to opCurveletNoFFT have to be
%   properly arraged and normaliazed. Here is how to prepare input, to get
%   equivalent of opCurvelet, if one used MATLAB's fft2:
%       x=fft2(x)
%       x=fftshift(x)/sqrt(M*N)
%   and to recover from inverse:
%       y=reshape(y,size(x))
%       y=ifftshift(y)*sqrt(M*N);
%       y=ifft2(y);
%   Note that zero-frequency component is moved to/from center of spectrum.
%
%   See also CURVELAB.

%   An example that actually works is opCurveletNoFFT(32,32), use this for
%   testing.

%   Henryk Modzelewski - May 2016
%   Nameet Kumar - Oct 2010
%   Copyright 2009, Gilles Hennenfent, Ewout van den Berg and 
%   Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = protected)
        nbscales;
        nbangles;
        finest;   
        header;          %sizes of coefficient vectors
        nbcoeffs;           %total number of coefficients
        dims;           %size of curvelet
    end % Properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function op = opCurveletNoFFT(m,n,nbscales,nbangles,finest,is_real)

            assert( isscalar(m) && isscalar(n),['Please ensure'...
            ' sizes are scalar values']);
            if nargin < 3, nbscales = max(1,ceil(log2(min(m,n)) - 3)); end;
            if nargin < 4, nbangles = 16;                              end;
            if nargin < 5, finest = 0;                                 end;
            if nargin < 6, is_real = 1;                                end;
            assert( isscalar(nbscales) && isscalar(nbangles),...
                'Please ensure nbscales and nbangles are scalar values');
            assert((any(finest == [0 1 2])) && (is_real==0||is_real==1),...
                'Please ensure finest and is_real are appropriate values');
            if finest==0, assert( nbscales>1, ['Please ensure that '...
                    'm and n are large enough for nbscales to be '...
                    'greater than 1 while finest is set to 0']); 
            end

            % Compute length of curvelet coefficient vector
            [tmphdr, cn] = fdct_sizes_mex(m,n,nbscales,nbangles,...
                                                      logical(finest));
            hdr = cell(1,nbscales);
            hdr{1} = {[tmphdr{1:2}]}; 
            for i = 2:nbscales - (~finest)
                j = 3 + 5*(i-2);
                hdr{i}={[tmphdr{j+1:j+2}];[tmphdr{j+3:j+4}];...
                        [tmphdr{j}]};
            end
            if ~finest,  hdr{end} = {[tmphdr{end-1:end}];1}; end;

            % Construct operator
            op = op@opSpot('CurveletNoFFT', cn, m*n);
            op.cflag     = ~is_real;
            op.nbscales  = nbscales;
            op.nbangles  = nbangles;
            op.finest    = finest;
            op.header    = hdr;
            op.nbcoeffs  = cn;
            op.dims      = [m,n];
            op.ns        = {[m n]};
            op.sweepflag = true;
        end % Constructor

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % rrandn             
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % overloaded to produce a vector that really falls in the range of
        % op
        function y = rrandn(op)
            y = op.drandn;
            y = multiply(op,y,1);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % headerMod             
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % overloaded to modify metadata correctly
        function h = headerMod(op,header,mode)
            exsize = header.exsize;

            if mode == 1
                h = header; % Copy header
                % Replace old first (collapsed) dimensional sizes with 
                % operator sizes.
                h.size(exsize(1,1):exsize(2,1)) = [];
                h.size   = [op.ms{:} h.size];
                h.origin(exsize(1,1):exsize(2,1)) = [];
                h.origin = [0 h.origin];
                h.delta(exsize(1,1):exsize(2,1)) = [];
                h.delta  = [1 h.delta];
                h.label(exsize(1,1):exsize(2,1)) = [];
                h.label  = ['lcurvelet' h.label];
                h.unit(exsize(1,1):exsize(2,1)) = [];
                h.unit   = ['ucurvelet' h.unit];

            else % mode == 2
                h = header;
                h.size(exsize(1,1):exsize(2,1)) = [];
                h.size   = [op.ns{:} h.size];
                h.origin(exsize(1,1):exsize(2,1)) = [];
                h.origin = [0 0 h.origin];
                h.delta(exsize(1,1):exsize(2,1)) = [];
                h.delta  = [1 1 h.delta];
                h.label(exsize(1,1):exsize(2,1)) = [];
                h.label  = ['l1' 'l2' h.label];
                h.unit(exsize(1,1):exsize(2,1)) = [];
                h.unit   = ['u1' 'u2' h.unit];

            end

            % Re-append correct exsize
            exsize_out = 1:length(h.size);
            exsize_out = [exsize_out;exsize_out];
            h.exsize   = exsize_out;
        end % headerMod
    end % Public Methods
       
 
    methods ( Access = protected )
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Multiply
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function x = multiply(op,x,mode)
            x_n = size(x,2);
            
            if mode == 1
                for u = x_n:-1:1 % Loop over multivectors
                    x_tmp = full(x(:,u));
                    % Analysis mode
                    x_tmp = fdct_wrapping_nofft_mex(op.dims(1),op.dims(2),...
                            op.nbscales,op.nbangles,...
                            logical(op.finest),...
                            reshape(x_tmp,op.dims(1),op.dims(2)));
                    if op.finest == 2, zero_finest_scale; end
                    if ~op.cflag % real transforms have redundancy 
                        x_tmp = fdct_wrapping_c2r(x_tmp);
                    end
                    y(:,u) = spot.utils.fdct_c2v(x_tmp,op.nbcoeffs);
                end
                x = y;
            else
                for u = x_n:-1:1 % Loop over multivectors
                    x_tmp = full(x(:,u));
                    % Synthesis mode  
                    x_tmp = spot.utils.fdct_v2c(x_tmp,op.header);
                    if op.finest == 2, zero_finest_scale; end
                    if ~op.cflag
                        x_tmp = fdct_wrapping_r2c(x_tmp);
                    end
                    x_tmp = ifdct_wrapping_nofft_mex(op.dims(1),...
                            op.dims(2),op.nbscales,op.nbangles,...
                            logical(op.finest),x_tmp);
                    y(:,u) = x_tmp(:);
                end
                x = y;
            end

            %%% Nested Function
            function zero_finest_scale
                for i = 1:length(x_tmp{end})
                    x_tmp{end}{i} = zeros( size( x_tmp{end}{i} ) );
                end
            end

        end % Multiply
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Divide
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function x = divide(op,b,mode)
            % Non-sweepable
            x = lsqrdivide(op,b,mode);
        end % divide

    end % Protected Methods
end % opCurveletNoFFT
