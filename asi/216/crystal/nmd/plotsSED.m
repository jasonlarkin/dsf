SED = load(['SEDavg.mat']);

trial='crystal';

fig=figure;
semilogy(SED.omega,SED.sed(:,1),SED.omega,SED.sed(:,2),SED.omega,SED.sed(:,3))

print('-r600','-cmyk','-dpdf',['./SEDavg' trial '.pdf'])
