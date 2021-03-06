function si = m_si
% lj = m_lj returns an si structrue with si parameters
%--------------------------------------------------------------------------             
con = m_constant;

si.mass = 28.0855;  

si.sound_expt =8433;
si.sound =...
    ((2/3)*4.48797 + (1/3)*8.39012)*1000;
si.sound_goic =...
    ((2/3)*4.4887 + (1/3)*8.002)*1000;
si.sound_used =...
    ((2/6)*4.4887 + (1/6)*8.002 + (2/6)*1.800 + (1/6)*5.164 )*1000;

si.alat = 5.43E-10;

si.alat_amor = 5.43E-10*1.0438;

si.amor.alat = 5.43E-10;
si.amor.vs = (2/3)*3886.67+(1/3)*8271.51;    %~/disorder2/si/amor/normand/perf4096/anneal_1100K/emin
si.amor.vs_long = 8271.51;
si.amor.vs_tran = 3886.67;

si.num_atom_ucell=8;
si.num_density = (si.num_atom_ucell / (si.alat^3));

si.Tmelt.sw = (0.08)*(50/0.239*1000)/con.kb/con.avog;      %\cite{stillinger_computer_1985}

m1 = 1; m2 = 2.6; 
si.cahill_conc =...
    (6.2E19)/(si.num_density/(100^3));
vm = (1-si.cahill_conc)*m1 + si.cahill_conc*m2;
si.cahill_g =...
    (1-si.cahill_conc)* ((1 - (m1/vm) )^2) +...
    (si.cahill_conc)* ((1 - (m2/vm) )^2);

m1 = 58.6934; m2 = 106.42; 
si.cahill_conc_nipd =...
    0.55;
vm = (1-si.cahill_conc_nipd)*m1 + si.cahill_conc_nipd*m2;
si.cahill_g_nipd =...
    (1-si.cahill_conc_nipd)* ((1 - (m1/vm) )^2) +...
    (si.cahill_conc_nipd)* ((1 - (m2/vm) )^2);

si.num_density = (4096) / ((8*5.43E-10)^3);

si.prefactor =...
    (3/2)*( (pi/6)^(1/3))*con.kb*...
    si.num_density^(2/3);
si.high_scatter = [...
    si.prefactor*si.amor.vs...
    ];

end
%--------------------------------------------------------------------------	


