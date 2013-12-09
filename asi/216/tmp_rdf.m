clear all
close all

trial='crystal';
%[filename1,hfile1]=uigetfile({'../*.rdf',},...
% 'Select Data File 1');


%------------------------------------------read in file
%f=fopen(fullfile(hfile1, filename1));
f=fopen('./tmp_all.rdf');
c= textscan(f,'%s', 'Delimiter', '\t');
lines=c{1};
fclose(f);

lines(1:4)=[];

m=1;
for x=1:(length(lines))
    A=sscanf(lines{x},'%f');
    if length(A)==4

        bins(m,1)=A(1,1);
        coord(m,1)=A(2,1);
        c_myRDF_11(m,1)=A(3,1);
        c_myRDF_22(m,1)=A(4,1);
        m=m+1;
    end
end
%delete the header lines

fig=figure;
plot(coord, c_myRDF_11(:,1), 'r')
hold on
%plot(coord, c_myRDF_22(:,1), 'g')

xlabel('bins')
ylabel('count')
print('-r600','-cmyk','-dpdf',['./rdf' trial '.pdf'])
