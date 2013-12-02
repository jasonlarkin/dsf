NMD=load('./nmd.mat');
%---IKSLICE----------------------------------------------------------------
    imslice = 1;
%-------------------------------------------------------------------------- 
SED.SED(...
    size(NMD.kptmaster(:,1:3),1),...
    1:(NMD.NUM_TSTEPS/2),1:size(NMD.modelist(:,imslice),1)) = 0.0;
for iseed = 1:NMD.NUM_SEEDS
for ifft = 1:NMD.NUM_FFTS  
%VElOCITIES
    str_read=...
        strcat(...
        NMD.str.main ,'dump_',int2str(iseed),'_',int2str(ifft),'.vel');
    fid=fopen(str_read);
    dummy = textscan(fid,'%f%f%f','Delimiter',' ','commentStyle', '--'); 
   fclose(fid);
%POSITIONS
%     str_read=...
%         strcat(...
%         NMD.str.main ,'dump_',int2str(iseed),'_',int2str(ifft),'.pos');
%     fid=fopen(str_read);
%     dummy2 = textscan(fid,'%f%f%f','Delimiter',' ','commentStyle', '--'); 
%     fclose(fid);
%Store velocity data of all atoms: subtract off the last time step
    velx = zeros(NMD.NUM_ATOMS,NMD.NUM_TSTEPS);
    vely = zeros(NMD.NUM_ATOMS,NMD.NUM_TSTEPS);
    velz = zeros(NMD.NUM_ATOMS,NMD.NUM_TSTEPS);

%     posx = zeros(NMD.NUM_ATOMS,NMD.NUM_TSTEPS);
%     posy = zeros(NMD.NUM_ATOMS,NMD.NUM_TSTEPS);
%     posz = zeros(NMD.NUM_ATOMS,NMD.NUM_TSTEPS);
%--------------------------------------------------------------------------
tic  
%--------------------------------------------------------------------------
    for iatom = 1:NMD.NUM_ATOMS  
        velx(iatom,1:NMD.NUM_TSTEPS) =...
            dummy{1}...
            (iatom:NMD.NUM_ATOMS:(length(dummy{1}(:))-NMD.NUM_ATOMS))*...
		NMD.constant.ang2m/NMD.constant.s2ps;
        vely(iatom,1:NMD.NUM_TSTEPS) =...
            dummy{2}...
            (iatom:NMD.NUM_ATOMS:(length(dummy{1}(:))-NMD.NUM_ATOMS))*...
		NMD.constant.ang2m/NMD.constant.s2ps;;
        velz(iatom,1:NMD.NUM_TSTEPS) =...
            dummy{3}...
            (iatom:NMD.NUM_ATOMS:(length(dummy{1}(:))-NMD.NUM_ATOMS))*...
		NMD.constant.ang2m/NMD.constant.s2ps;
%     	posx(iatom,1:NMD.NUM_TSTEPS) =...
% 	    (dummy2{1}(iatom:NMD.NUM_ATOMS:(length(dummy2{1}(:))-NMD.NUM_ATOMS))- ...
% 		NMD.x0(iatom,3))*NMD.constant.ang2m;
%     	posy(iatom,1:NMD.NUM_TSTEPS) =...
% 	    (dummy2{2}(iatom:NMD.NUM_ATOMS:(length(dummy2{1}(:))-NMD.NUM_ATOMS))- ...
% 		NMD.x0(iatom,4))*NMD.constant.ang2m;
%     	posz(iatom,1:NMD.NUM_TSTEPS) =...
% 	    (dummy2{3}(iatom:NMD.NUM_ATOMS:(length(dummy2{1}(:))-NMD.NUM_ATOMS))-...
% 		NMD.x0(iatom,5))*NMD.constant.ang2m;
    end
%--------------------------------------------------------------------------
toc
%--------------------------------------------------------------------------
%Remove dummy
    clear dummy dummy2
%Set mass array
%     m = repmat(NMD.mass(:,1),1,NMD.NUM_TSTEPS);     
    m = NMD.mass(:,1)*NMD.si.mass/NMD.constant.g2kg/NMD.constant.avog;
%EIGENVECTORS
%     eigenvec =...
%         dlmread(...
%         strcat(...
%         NMD.str.main,'AF_eigvec.dat') );   
%Zero main SED FP: this gets averaged as you loop over the NUM_FFTS      
    Q = zeros(1,NMD.NUM_TSTEPS);
    QDOT = zeros(1,NMD.NUM_TSTEPS);
    ETOT = zeros(1,NMD.NUM_TSTEPS);
%--------------------------------------------------------------------------
tic  
%--------------------------------------------------------------------------
    for ikpt = 1:size(NMD.kptmaster(:,1:3),1)
            
            spatial = 2*pi*1i*(...
    NMD.x0(:,3)*( (NMD.kptmaster(ikpt,1))/(NMD.alat*NMD.Nx) ) +...
    NMD.x0(:,4)*( (NMD.kptmaster(ikpt,2))/(NMD.alat*NMD.Ny) ) +...
    NMD.x0(:,5)*( (NMD.kptmaster(ikpt,3))/(NMD.alat*NMD.Nz) ) );

%             SPATIAL = repmat(spatial,1,NMD.NUM_TSTEPS);
            
%WARNING: :3:, where PRIM has :1: (: implicit) for CONV, must use 
    
    kindex = NMD.kptmaster_index(ikpt);

    POSX_FFT = fft(velx,[],2); POSY_FFT = fft(vely,[],2); POSZ_FFT = fft(velz,[],2); 
    
%     POSX_FFT = fft(posx,[],2); POSY_FFT = fft(posy,[],2); POSZ_FFT = fft(posz,[],2); 
    
            Q = sum(...
                bsxfun(@times,...
                POSX_FFT(:,1:(NMD.NUM_TSTEPS/2)) +...
                POSY_FFT(:,1:(NMD.NUM_TSTEPS/2)) +...
                POSZ_FFT(:,1:(NMD.NUM_TSTEPS/2)) ...
                , exp(spatial)...
                ) ...
                , 1 );
            
        SED.SED(ikpt,:) =...
            SED.SED(ikpt,:) + abs(Q).^2 ;

    end %END ikpt
%--------------------------------------------------------------------------
toc 
%--------------------------------------------------------------------------
end %END ifft
    
end %iseed

%seed avg
SED.SED(:,:) =...
    SED.SED(:,:)/NMD.NUM_SEEDS/NMD.NUM_FFTS;

%Define frequencies

    omega = (1:NMD.NUM_OMEGAS)*(NMD.w_max/NMD.NUM_OMEGAS);

%Output SED
for ikpt = 1:size(NMD.kptmaster(:,1:3),1)
    str_write_single=...
        strcat(NMD.str.main,'nmd/SED_',...
        num2str(NMD.kptmaster_index(ikpt)),'.txt');
    output(1:length(omega),1) = omega
    output(1:length(omega),2) = SED.SED(ikpt,:)';
    dlmwrite(str_write_single,output,'delimiter',' ');
    clear output
end %END ikpt  
