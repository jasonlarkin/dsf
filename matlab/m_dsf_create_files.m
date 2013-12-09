%--------------------------------------------------------------------------
%input
%--------------------------------------------------------------------------
clear
%--------------------------------------------------------------------------
    nmd.str.main = '~/dsf/asi/216/crystal/nmd/' ;
    nmd.str.matlab = '~/dsf/matlab/';
    nmd.str.gulp = 'gulp_disp_si_conv.tmp';
    nmd.str.lmp_in = 'lmp.in.x0.alloy.single.si.tmp';
    nmd.str.lmp_sed = 'lmp.in.dsf.si.tmp';
    nmd.str.m_nmd = 'm_dsf.tmp.m';
    nmd.str.m_grep = 'm_nmd_grep_vel.tmp.m';
    nmd.str.m_seed = 'm_dsf_seed_avg.tmp.m';
    nmd.str.env = 'gilg'
%--------------------------------------------------------------------------
nmd.si = m_si; nmd.constant = m_constant;
%--------------------------------------------------------------------------
nmd.m(1) = 1.0; nmd.m(2) = 3.0; nmd.NUM_ATOMS_TYPE = 1;
%--------------------------------------------------------------------------
nmd.walltime.lammps = 12; nmd.cpu.lammps = 8; 
nmd.walltime.matlab = 12; nmd.cpu.matlab = 1; nmd.mem.matlab = 4;
%--------------------------------------------------------------------------
nmd.Nx = 3*20; nmd.Ny = 3; nmd.Nz = 3;
nmd.kptmaster(:,1) = [1:nmd.Nx]'; 
nmd.kptmaster(:,2) = 0; nmd.kptmaster(:,3) = 0;
nmd.NUM_KPTS = size(nmd.kptmaster(:,1:3),1);
nmd.kptmaster_index = 1:nmd.NUM_KPTS;
%--------------------------------------------------------------------------
nmd.seed.initial = 1:10;
%--------------------------------------------------------------------------

%SED PARAMETERS------------------------------------------------------------    

%ISEED---------------------------------------------------------------------
nmd.NUM_SEEDS = size(nmd.seed.initial,2); nmd.seed.alloy = 1;
%--------------------------------------------------------------------------   

%TIMES---------------------------------------------------------------------
nmd.t_total = 2^19; nmd.t_fft = 2^19; nmd.t_step = 2^7; nmd.dt = 0.0005;
nmd.NUM_TSTEPS = nmd.t_fft/nmd.t_step; 
%-------------------------------------------------------------------------- 

%IFFT----------------------------------------------------------------------
nmd.NUM_FFTS = nmd.t_total/nmd.t_fft;
%-------------------------------------------------------------------------- 

%FREQS---------------------------------------------------------------------
nmd.w_step = 2*pi/(nmd.t_fft*nmd.dt); 
nmd.w_max = 2*pi/(nmd.t_step*nmd.dt*2);
nmd.NUM_OMEGAS = nmd.t_fft/(2*nmd.t_step); 
%-------------------------------------------------------------------------- 

%--------------------------------------------------------------------------
%read data
dummy =dlmread(strcat(nmd.str.main,'x0.data'));
nmd.param = dummy(1,:);
nmd.x0(:,1) = dummy(2:size(dummy,1),1);
nmd.x0(:,2) = dummy(2:size(dummy,1),2);
nmd.x0(:,3) = dummy(2:size(dummy,1),3);
nmd.x0(:,4) = dummy(2:size(dummy,1),4);
nmd.x0(:,5) = dummy(2:size(dummy,1),5);
nmd.mass = nmd.x0(:,2);    
%replace double alloy
I = find(nmd.mass(:,1) ==1); nmd.mass(I) = nmd.mass(1);
I = find(nmd.mass(:,1) ==2); nmd.mass(I) = nmd.mass(2);

nmd.NUM_ATOMS_UCELL = nmd.param(1);
nmd.NUM_MODES = nmd.param(1)*3; nmd.NUM_ATOMS = size(nmd.x0,1);    
nmd.NUM_UCELL_COPIES=nmd.NUM_ATOMS/nmd.NUM_ATOMS_UCELL;    
nmd.Lx = nmd.param(3); nmd.Ly = nmd.param(4); nmd.Lz = nmd.param(5);
nmd.VOLUME = nmd.Lx*nmd.Ly*nmd.Lz;
nmd.alat = nmd.Lx/nmd.Nx;

%nmd.freq = dlmread(strcat(nmd.str.main,'AF_freq.dat'))'; 
    
%--------------------------------------------------------------------------
%pause
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%LAMMPS
%--------------------------------------------------------------------------
  str.cmd = ['mkdir -p ' nmd.str.main '/nmd'];
  system(str.cmd);
  str.cmd =...
      ['cp ' nmd.str.matlab 'lmp_submit.sh.tmp.' nmd.str.env ' ' ...
      nmd.str.main 'lmp_submit.sh'];
  system(str.cmd);      
  str.orig = 'NUM_ATOMS';
  str.change = [int2str(nmd.NUM_ATOMS)];
  str.cmd1 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];

  str.orig = 'NUM_ATOM_TYPE';
  str.change = [int2str(nmd.NUM_ATOMS_TYPE)];
  str.cmd2 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];

  str.orig = 'LX';
  str.change = [num2str( nmd.Lx )];
  str.cmd3 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
  str.orig = 'LY';
  str.change = [num2str( nmd.Lx )];
  str.cmd4 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
  str.orig = 'LZ';
  str.change = [num2str( nmd.Lx )];
  str.cmd5 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
  str.orig = 'ATOM_MASS_1';
  str.change = [num2str(nmd.m(1)*nmd.si.mass)];
  str.cmd6 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
      
  str.cmd8 =...
      [nmd.str.matlab nmd.str.lmp_in ...
      ' > ' nmd.str.main 'lmp.in.x0.' int2str(nmd.seed.alloy)];

  str.cmd = ['sed ' str.cmd1 str.cmd2 str.cmd3 str.cmd4 str.cmd5...
      str.cmd6 str.cmd8];
  system(str.cmd);
        
output = [nmd.x0(:,1:5)];
str.write=...
    [nmd.str.main 'lmp.in.x0.' int2str(nmd.seed.alloy)];
dlmwrite(str.write,output,'-append','delimiter','\t');

%--------------------------------------------------------------------------
%pause
%--------------------------------------------------------------------------
for iseed=1:size(nmd.seed.initial,2)         
  str.orig = 'lmp.sh.tmp';
  str.change = ['lmp' int2str(iseed) '.sh'];
  str.cmd1 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
  str.orig = 'runpath';
  str.change = strcat(nmd.str.main);
  str.temp = strcat('-e ''s|',str.orig,'|',str.change);
  str.cmd2 = [str.temp '|g'' '];
  str.orig = 'LMP_TMP';
  str.change = ['lmp.in.sed.' int2str(iseed)];
  str.cmd3 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
  str.orig = 'lmp_temp';
  str.change = ['lmp' int2str(iseed)];
  str.cmd4 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];

  str.cmd5 = [nmd.str.matlab 'lmp.sh.tmp.' nmd.str.env ' > ' ...
  nmd.str.main 'lmp' int2str(iseed) '.sh'];

  str.cmd = ['sed ' str.cmd1 str.cmd2 str.cmd3 str.cmd4 str.cmd5];
  system(str.cmd);
           
  str.orig = 'IN.X0';
  str.change = ['lmp.in.x0.' int2str(nmd.seed.alloy)];
  str.cmd1 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
  str.orig = 'LMP_TMP';
  str.change = ['lmp.in.sed.' int2str(iseed)];
  str.cmd2 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
  str.orig = 'IX0';
  str.change = [int2str(nmd.seed.alloy)];
  str.cmd3 = ['-e ''s/\' str.orig '>/' str.change '/g'' '];
  str.orig = 'ISEED_TMP';
  str.change = [int2str(iseed)];
  str.cmd4 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
  str.orig = 'SEED_TMP';
  str.change = [int2str(iseed) int2str(iseed) int2str(iseed)...
      int2str(iseed)];
  str.cmd5 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
  str.orig = 'T_STEP';
  str.change = [num2str(nmd.t_step)];
  str.cmd6 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
  str.orig = 'T_FFT';
  str.change = [num2str(nmd.t_fft)];
  str.cmd7 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
  str.orig = 'T_TOTAL';
  str.change = [num2str(nmd.t_total)];
  str.cmd8 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
  
  str.cmd9 = [nmd.str.matlab nmd.str.lmp_sed ' > ' ...
      nmd.str.main 'lmp.in.sed.' int2str(iseed)];
  
  str.cmd = ['sed ' str.cmd1 str.cmd2 str.cmd3 str.cmd4 str.cmd5...
      str.cmd6 str.cmd7 str.cmd8 str.cmd9 ];       
  system(str.cmd);
   
  output =...
      ['qsub -l walltime=' int2str(nmd.walltime.lammps)...
      ':00:00 -l nodes=1:ppn=' int2str(nmd.cpu.lammps)...
      ' lmp' int2str(iseed) '.sh'];
  
  str.write = strcat(nmd.str.main,'lmp_submit.sh');
  dlmwrite(str.write,output,'-append','delimiter','');

end 
%end

%--------------------------------------------------------------------------
%LAMMPS
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%MATLAB
%--------------------------------------------------------------------------

%MAKES JOB FILES-----------------------------------------------------------
  system(['cp ' nmd.str.matlab 'nmd.submit.sh.tmp.' nmd.str.env ' ' ...
  nmd.str.main 'nmd_submit.sh']);
imode = 1;
  str.orig = 'nmd_tmp';
  str.change = ['nmd_' int2str(imode)];
  str.cmd1 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
  str.orig = 'runpath';
  str.change = strcat(nmd.str.main);
  str.temp = strcat('-e ''s|',str.orig,'|',str.change);
  str.cmd2 = [str.temp '|g'' '];
  str.orig = 'nmd_TMP.m';
  str.change = ['nmd_' int2str(imode) '.m'];
  str.cmd3 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
  str.cmd4 = [nmd.str.matlab 'nmd.sh.tmp.' nmd.str.env ...
    ' > ' nmd.str.main 'nmd_' int2str(imode) '.sh'];

  str.cmd = ['sed ' str.cmd1 str.cmd2 str.cmd3 str.cmd4];
  system(str.cmd);    
  str.orig = 'ISEED';
  str.change = [int2str(iseed)];
  str.cmd1 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
  str.orig = 'IKSLICE';
  str.change = [int2str(imode)];
  str.cmd2 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
  str.cmd3 = [nmd.str.matlab nmd.str.m_nmd ' > ' ...
    nmd.str.main 'nmd_' int2str(imode) '.m'];
  str.cmd = ['sed ' str.cmd1 str.cmd2 str.cmd3];
  system(str.cmd);
  output = ['qsub -l walltime=' int2str(nmd.walltime.matlab)...
      ':00:00,nodes=' int2str(nmd.cpu.matlab)...
      ',mem=' int2str(nmd.mem.matlab)...
      'gb nmd_' int2str(imode) '.sh'];
  str.write = strcat(nmd.str.main,'nmd_submit.sh');
  dlmwrite(str.write,output,'-append','delimiter','');
system(...
  ['cp ' nmd.str.matlab nmd.str.m_grep ' ' nmd.str.main 'nmd_grep.m']);
  str.orig = 'nmd_tmp.m';
  str.change = [int2str(imode)];
  str.cmd1 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
  str.orig = 'runpath';
  str.change = strcat(nmd.str.main);
  str.temp = strcat('-e ''s|',str.orig,'|',str.change);
  str.cmd2 = [str.temp '|g'' '];
  str.cmd3 =...
      [nmd.str.matlab 'nmd_grep.sh.tmp.' nmd.str.env ' > ' ...
      nmd.str.main 'nmd_grep.sh'];
  str.cmd = ['sed ' str.cmd1 str.cmd2 str.cmd3];
  system(str.cmd);
system(...
  ['cp ' nmd.str.matlab 'nmd_grep_submit.sh.tmp.' nmd.str.env ' ' ...
  nmd.str.main 'nmd_grep_submit.sh']);
output =...
  ['qsub -l walltime=' int2str(4)...
  ':00:00,nodes=' int2str(nmd.cpu.matlab)...
  ',mem=' int2str(nmd.mem.matlab)...
  'gb nmd_grep.sh'];
  str.write = strcat(nmd.str.main,'nmd_grep_submit.sh');
  dlmwrite(str.write,output,'-append','delimiter','');
    
system(['cp ' nmd.str.matlab nmd.str.m_seed ' ' nmd.str.main 'nmd_seed.m']);

  str.orig = 'nmd_tmp.m';
  str.change = [int2str(imode)];
  str.cmd1 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
  str.orig = 'runpath';
  str.change = strcat(nmd.str.main);
  str.temp = strcat('-e ''s|',str.orig,'|',str.change);
  str.cmd2 = [str.temp '|g'' '];
  str.cmd3 =...
      [nmd.str.matlab 'nmd_seed.sh.tmp.' nmd.str.env ' > ' ...
      nmd.str.main 'nmd_seed.sh'];
  str.cmd = ['sed ' str.cmd1 str.cmd2 str.cmd3];
  system(str.cmd);
system(...
  ['cp ' nmd.str.matlab 'nmd_seed_submit.sh.tmp.' nmd.str.env ' ' ...
  nmd.str.main 'nmd_seed_submit.sh']);
output =...
  ['qsub -l walltime=' int2str(4)...
  ':00:00,nodes=' int2str(nmd.cpu.matlab)...
  ',mem=' int2str(nmd.mem.matlab)...
  'gb nmd_seed.sh'];
  str.write = strcat(nmd.str.main,'nmd_seed_submit.sh');
  dlmwrite(str.write,output,'-append','delimiter','');
    
save([nmd.str.main 'nmd.mat'], '-struct', 'nmd');
