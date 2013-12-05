clear
constant = m_constant;

str_read = '/home/jason/dsf/asi/4320/';
% DSF(1).DSF = load([str_read 'DSF_long.mat']);
% DSF(2).DSF = load([str_read 'DSF_tran.mat']);

DSF = load([str_read 'SEDavg.mat']);
NMD = load([str_read 'NMDavg.mat']);

idir = 1;
% for idir = 1:2
 for ikpt = 1:length(NMD.kptmaster)
  if ikpt<=1
   PT_PERC_LEFT = 0.02; PT_PERC_RIGHT = 0.02;
   INV_PERC = 1.0;
  elseif ikpt<=30 
   PT_PERC_LEFT = 0.1; PT_PERC_RIGHT = 0.1;
   INV_PERC = 1.0;
  elseif ikpt<=58 
   PT_PERC_LEFT = 0.9; PT_PERC_RIGHT = 0.9;
   INV_PERC = 1.0;
  else
   PT_PERC_LEFT = 0.9; PT_PERC_RIGHT = 0.9;
   INV_PERC = 1.0;
  end      
%--------------------------------------------------------------------------
%tran
%--------------------------------------------------------------------------
  start =1;
  [Imax,Jmax] = max(DSF.sed(start:end,ikpt));
%Find wleft    
  [I,J] = find(DSF.sed(start:start+Jmax,ikpt) <...
    PT_PERC_LEFT*DSF.sed(start+Jmax,ikpt) );
  wleft = start+I(length(I))
%Find wright
  [I,J] = find(DSF.sed(start+Jmax:end,ikpt) <...
    PT_PERC_RIGHT*DSF.sed(start+Jmax,ikpt) );
  wright = start+Jmax + I(1)
%FIT THE LORENTZIAN(S)
  c0 = [ 1.0*Imax, 0.05, DSF.omega(start+Jmax) ];

  lb(1:length(c0)) = 0.0; ub(1:3:length(c0)) = 100000*Imax; 
  ub(2:3:length(c0)) = 1000*1e15; 
  ub(3:3:length(c0)) =....
   1000*DSF.omega(length(DSF.omega));
%   weights = ones(length(wleft:wright),1);
%   weights(1:30) = INV_PERC/( (PT_PERC_LEFT + PT_PERC_LEFT)/2);
%   weights(length(weights)-30:length(weights)) =...
%    INV_PERC/( (PT_PERC_LEFT + PT_PERC_LEFT)/2);
  lor_func = @(c,w)(c(1))./(1 + ( (w - c(3))./ c(2) ).^2 );
  options = optimset(...
   'MaxIter',5000,'MaxFunEvals',5000,'TolFun',1e-5,'TolX',1e-5); 
  [c_fit] = lsqcurvefit(lor_func,c0,...
   DSF.omega(wleft:wright),...
   DSF.sed(wleft:wright,ikpt),...
   lb,ub,options);
%Store separate liftimes and frequencies for single and MULTIPLE FITS
  center=c_fit(3); lifetime=1/(2*c_fit(2));
  semilogy(DSF.omega,DSF.sed(:,ikpt),...
    DSF.omega(wleft:wright),...
    lor_func(c0,DSF.omega(wleft:wright)'))
%pause
  semilogy(...
   DSF.omega,DSF.sed(:,ikpt),...
   DSF.omega(wleft:wright)',...
   lor_func(c_fit,DSF.omega(wleft:wright)'))
  DSF_FIT.freq(ikpt) = center;
  DSF_FIT.life(ikpt) = lifetime;
    center
    lifetime
%pause
 end
%end
%pause
%end correction
% reso1 = 0.1; reso2 = 0.1;
% [I,J] = find(...
%     10 - reso1 < DSF_FIT.life & DSF_FIT.life < 70 + reso1 &...
%     15.0 - reso2 < DSF_FIT.freq & DSF_FIT.freq < 26.0 + reso2 ...
%     );
% DSF_FIT.life(J) = 12.43234; 

loglog(...
    DSF_FIT.freq(1:10), DSF_FIT.life(1:10),'.',...
    DSF_FIT.freq(11:end), DSF_FIT.life(11:end),'.',...
    DSF_FIT.freq,2*pi./DSF_FIT.freq,...
    DSF_FIT.freq,(1E4)*1./(DSF_FIT.freq.^4),...
    DSF_FIT.freq,(1E3)*1./(DSF_FIT.freq.^2)...
    )

save(strcat(str_read,'DSF_FIT.mat'), '-struct', 'DSF_FIT');

