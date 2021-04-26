#! /bin/bash -fexport  
# 

mdrun=$AMBERHOME/bin/pmemd.cuda
#adjust cuda and which protein/ligand
cuda=2
prot="cypX_A4A_water"

echo "$prot Minimisation 1..." 
    export CUDA_VISIBLE_DEVICES=$cuda 
    $mdrun -O -i min1.in -o min1.out -p $prot.parm7 -c $prot.rst7 -ref $prot.rst7 -r min1.rst7 -inf min1.info ; 
echo "$prot Minimisation 2..." 
    export CUDA_VISIBLE_DEVICES=$cuda 
    $mdrun -O -i min2.in -o min2.out -p $prot.parm7 -c min1.rst7 -ref min1.rst7 -r min2.rst7 -inf min2.info ; 
echo "$prot Minimisation 3..." 
    export CUDA_VISIBLE_DEVICES=$cuda 
    $mdrun -O -i min3.in -o min3.out -p $prot.parm7 -c min2.rst7 -ref min2.rst7 -r min3.rst7 -inf min3.info ; 
echo "$prot Minimisation 4..." 
    export CUDA_VISIBLE_DEVICES=$cuda 
    $mdrun -O -i min4.in -o min4.out -p $prot.parm7 -c min3.rst7 -ref min3.rst7 -r min4.rst7 -inf min4.info ; 
echo "$prot Minimisation 5..." 
    export CUDA_VISIBLE_DEVICES=$cuda 
    $mdrun -O -i min5.in -o min5.out -p $prot.parm7 -c min4.rst7 -ref min4.rst7 -r min5.rst7 -inf min5.info ;

echo "$prot Heating..." 
    export CUDA_VISIBLE_DEVICES=$cuda 
    $mdrun -O -i heat.in -o heat.out -p $prot.parm7 -c min5.rst7 -ref min5.rst7 -r heat.rst7 -x heat.nc -inf heat.info ; 

echo "$prot Pressurizing..." 
    export CUDA_VISIBLE_DEVICES=$cuda 
    $mdrun -O -i press.in -o press.out -p $prot.parm7 -c heat.rst7 -ref heat.rst7 -r press.rst7 -x press.nc -inf press.info ;

echo "$prot Equilibrating..." 
    export CUDA_VISIBLE_DEVICES=$cuda 
    $mdrun -O -i eq.in -o eq.out -p $prot.parm7 -c press.rst7 -ref press.rst7 -r eq.rst7 -x eq.nc -inf eq.info
