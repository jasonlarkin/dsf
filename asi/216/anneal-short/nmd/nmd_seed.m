NMD=load('./nmd.mat');
[tmp,str.main]=system('pwd');
  SED.sed( 1:NMD.NUM_TSTEPS/2,1:NMD.NUM_KPTS ) = 0.0;
for ikpt = 1:NMD.NUM_KPTS
%--------------------------------------------------------------------------
tic
%--------------------------------------------------------------------------
  str.read = strcat(NMD.str.main,'nmd/SED_',...
  num2str(ikpt),'.txt'); dummy = load(str.read); 
  SED.sed(1:NMD.NUM_TSTEPS/2,ikpt) = dummy(:,2); SED.omega = dummy(:,1);
%--------------------------------------------------------------------------
toc
%--------------------------------------------------------------------------
end
save(strcat(NMD.str.main,'NMDavg.mat'), '-struct', 'NMD');
save(strcat(NMD.str.main,'SEDavg.mat'), '-struct', 'SED');


