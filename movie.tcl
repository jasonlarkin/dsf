cd ~/dsf/asi/216/anneal-recrystal/dumps
mol new dump.0.xyz type {xyz} first 0 last -1 step 1 waitfor 1
foreach f [lsort -dictionary [glob {dump.*.xyz} ] ] {mol addfile $f type xyz waitfor all}
mol modstyle 0 top Points 15.000000
mol modcolor 0 top Element

color Element He blue
color Element H red

light 2 on
light 3 on

mol rename top {2TYPE}
