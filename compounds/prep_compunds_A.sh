#! /bin/bash -fexport  
#

tleap=$AMBERHOME/bin/tleap 

current_dir=$(pwd)

for ligand in A1A A2A A3A A4A A5A; do
  if [ \! -d $ligand ]; then
    mkdir $ligand
  fi
  sed -e "s/%L%/$ligand/g" $current_dir/AXA.tmpl > $current_dir/$ligand/$ligand.in
  cp init_$ligand.pdb $current_dir/$ligand/$ligand.pdb
done

echo "finished setup, running parameters..."

for ligand in A1A A2A A3A A4A A5A; do
  cd $ligand
  echo "...for $ligand ..."
	antechamber -i $ligand.pdb -fi pdb -o $ligand.mol2 -fo mol2 -c bcc -s 2 ;
	parmchk2 -i $ligand.mol2 -f mol2 -o $ligand.frcmod ;
	$tleap -f $ligand.in
  cd ..
done
