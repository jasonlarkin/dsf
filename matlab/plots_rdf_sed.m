clear all
close all

hfile1={'~/dsf/asi/216/'};
expts={'crystal', 'anneal-long','anneal', 'anneal-short'};



rdffilename={ '/rdf/tmp_all.rdf'};
sedfilename={ '/nmd/SEDavg.mat'};

for trial=1:length(expts)
f=fopen(char(fullfile(hfile1, expts(trial),rdffilename)));
c= textscan(f,'%s', 'Delimiter', '\t');
lines=c{1};
fclose(f);

lines(1:4)=[];

m=1;
for x=1:(length(lines))
    A=sscanf(lines{x},'%f');
    if length(A)==4

        bins(m,1,trial)=A(1,1);
        coord(m,1,trial)=A(2,1);
        c_myRDF_11(m,1,trial)=A(3,1);
        c_myRDF_22(m,1,trial)=A(4,1);
        m=m+1;
    end
end

SED(trial)=load(char(fullfile(hfile1, expts(trial),sedfilename)));
end 

%-----------------------------------------------------------plots
for colors=1:length(expts)
rgb_value(colors,:) = [1+colors^2,80-colors*20,90+colors*20];

rgb_value(colors,:) = abs(rgb_value(colors,:)./255);
for i=1:length(rgb_value(colors,:))
        if rgb_value(colors,i)>1
            rgb_value(colors,i)=1/rgb_value(colors,i);
        end
        if rgb_value(colors,i)>1
            rgb_value(colors,i)=10/rgb_value(colors,i);
        end
end
end
colors=jet(length(expts));
linestyles = cellstr(char('-',':','-.','--','-',':','-.','--','-',':','-',':',...
'-.','--','-',':','-.','--','-',':','-.'));
Markers=['o','x','+','*','s','d','v','^','<','>','p','h','.',...
'+','*','o','x','^','<','h','.','>','p','s','d','v',...
'o','x','+','*','s','d','v','^','<','>','p','h','.'];



%%%%%%rdf figure
fig=figure;
for trial=1:length(expts)
h(trial)=plot(coord(:,1,trial), c_myRDF_11(:,1,trial),...
        [linestyles{trial} ], 'Color', colors(trial,:), 'LineWidth', 2);
    M(trial, 1:length(expts(trial)))=expts(trial);
hold on
end
%plot(coord, c_myRDF_22(:,1), 'g')
legend(h,M)
xlabel('Ang.')
ylabel('count')
print('-r600','-cmyk','-dpdf',['./rdf.pdf'])

%%%%%%SED figures
fig=figure;
for trial=1:length(expts)
    subplot(1,length(expts), trial)
    
h(trial,1:3)=semilogy(SED(1,trial).omega, SED(1,trial).sed(:,1), ...
    SED(1,trial).omega, SED(1,trial).sed(:,2), ...
SED(1,trial).omega, SED(1,trial).sed(:,3), 'MarkerSize', 0.005, 'LineWidth', 0.005);
    M(trial, 1:length(expts(trial)))=expts(trial);
hold on
end
%plot(coord, c_myRDF_22(:,1), 'g')
legend(h(:,1),M)
xlabel('THz')
ylabel('SED')
print('-r600','-cmyk','-dpdf',['./SEDavg.pdf'])
