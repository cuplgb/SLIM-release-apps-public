% This script runs the traveltime tomography example.
% The script may take about an hour to run.

setpaths;
curdir = pwd;
expdir = [resultsdir '/tomo'];
if ~exist(expdir,'dir')
    mkdir(expdir);
end

% read model
[v,o,d,n] = odnread([datadir '/crosswell_vp.odn']);
v0 = 2000;
[z,x] = odn2grid(o,d,n);


% parameters

% model grid
model.o = o;
model.d = d;
model.n = n;

% absorbing boundary
model.nb = [20 20];

% source/receiver grid
model.zsrc = 0:50:1000;
model.xsrc = 10;
model.zrec = 0:50:1000;
model.xrec = 990;

% time
t  = 0:.004:2;
f  = 0:1/t(end):.5/(t(2)-t(1));
If = 2:41;
% frequencies
model.freq = f(If);

% wavelet
model.f0 = 10;
model.t0 = 0;

% model
m  = 1e6./v.^2;
m0 = 1e6./v0.^2*ones(prod(n),1);

Q = speye(length(model.zsrc));

% make data
D = F(m,Q,model);
D = gather(D);
[od,dd,nd] = grid2odn(model.zrec,model.zsrc,model.freq);

R   = opRestriction(length(f),If);
DFT = opKron(R*opDFTR(length(t)),opDirac(nd(2)),opDirac(nd(1)));
Dt  = DFT'*D;

% background data
D0 = G([v0,0],Q,model);

% correlate
C  = conj(D).*D0;
Ct = DFT'*C;

odnwrite([expdir '/Dt.odn'],Dt,[od(1:2) t(1)],[dd(1:2) t(2)-t(1)],[nd(1:2) length(t)]);
odnwrite([expdir '/D0t.odn'],DFT'*D0,[od(1:2) t(1)],[dd(1:2) t(2)-t(1)],[nd(1:2) length(t)]);
odnwrite([expdir '/Ct.odn'],Ct,[od(1:2) t(1)],[dd(1:2) t(2)-t(1)],[nd(1:2) length(t)]);

Ct = fftshift(reshape(Ct,[nd(1)*nd(2) length(t)]),2);
[~,imax] = max(Ct,[],2);
T = t(imax) - 1;
T = T(:);
odnwrite([expdir '/croswell_time.odn'],T,od(1:2),dd(1:2),nd(1:2));

% linear operator
K = opFunction(prod(nd(1:2)),prod(n),{@(x)Ktomo(v0,x,1,model),@(x)Ktomo(v0,x,-1,model)},0,1);

% kernel
e1 = zeros(size(T));
e1(floor(length(T)/2)+1)=1;
k1 = K'*e1;
odnwrite([expdir '/k1.odn'],k1,o,d,n);

% regularization
B = opKron(opSpline1D([100:200:900],x,[1 1]),opSpline1D([100:100:900],z,[0 0]));

% invert
dmt = lsqr(K*B,T,1e-2,10);
odnwrite([expdir '/dmt.odn'],B*dmt,o,d,n);




