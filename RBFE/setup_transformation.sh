#!/bin/sh
#
# Setup for setup and free energy

#terms to change
ligand1="A1A"
ligand2="A2A"
protein="cypB"
trans="A1A_A2A"
ligand1sc="H28"
ligand2sc="C25,C26,H29,C3,H4,H5"

#adjust window no and pick right one!
no_w="21"
#wind="0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0"
#wind="0.0000, 0.0625, 0.1250, 0.1875, 0.2500, 0.3125, 0.3750, 0.4375, 0.5000, 0.5625, 0.6250, 0.6875, 0.7500, 0.8125, 0.8750, 0.9375, 1.0000"
wind="0.00, 0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40, 0.45, 0.50, 0.55, 0.60, 0.65, 0.70, 0.75, 0.80, 0.85, 0.90, 0.95, 1.00"

#choose cuda to run it on
cudasetup=1

current_dir=$(pwd)
templ_dir=$(cd templates ; pwd)
templ_dir_s=$(cd templates/setup ; pwd)
templ_dir_fe=$(cd templates/free_energy ; pwd)
comp_dir_1=$(cd compounds/$ligand1 ; pwd)
comp_dir_2=$(cd compounds/$ligand2 ; pwd)
#protein from md run cypA_A4A, change as required, make sure needed empty protein is in this file
prot_dir=$(cd protein/$protein'_A4A' ; pwd)
#remember to also copy the pdb w the shared topology to the leap folder at the end of the setup

trans_dir=$(cd $ligand1'_'$ligand2 ; pwd)

cd $trans_dir
echo $trans_dir

for x in setup free_energy; do
  if [ \! -d $x ]; then
    mkdir $x
  fi
done

s_dir=$(cd setup ; pwd)
fe_dir=$(cd free_energy ; pwd)
 
#setup

cd $s_dir
echo $s_dir

mkdir leap
cp $comp_dir_1/$ligand1.lib $s_dir/leap/$ligand1.lib
cp $comp_dir_2/$ligand2.lib $s_dir/leap/$ligand2.lib
cp $current_dir/$ligand1'_'$ligand2.pdb $s_dir/leap/$ligand1'_'$ligand2.pdb
cp $prot_dir/$protein.pdb $s_dir/leap/$protein.pdb
 
sed -e "s/%ONE%/$ligand1/g" -e "s/%TWO%/$ligand2/g" -e "s/%PROT%/$protein/g" $templ_dir_s/1_leap.tmpl > $s_dir/1_leap.sh
chmod u+x $s_dir/1_leap.sh

for system_prep in ligands_prepare complex_prepare; do
  if [ \! -d $system_prep ]; then
    mkdir $system_prep
  fi

  sed -e "s/%ONE%/$ligand1/g" -e "s/%TWO%/$ligand2/g" -e "s/%ONESC%/$ligand1@$ligand1sc/g" -e "s/%TWOSC%/$ligand2@$ligand2sc/g" $templ_dir_s/min1.tmpl > $system_prep/min1.in

  sed -e "s/%ONE%/$ligand1/g" -e "s/%TWO%/$ligand2/g" -e "s/%ONESC%/$ligand1@$ligand1sc/g" -e "s/%TWOSC%/$ligand2@$ligand2sc/g" $templ_dir_s/min2.tmpl > $system_prep/min2.in

  sed -e "s/%ONE%/$ligand1/g" -e "s/%TWO%/$ligand2/g" -e "s/%ONESC%/$ligand1@$ligand1sc/g" -e "s/%TWOSC%/$ligand2@$ligand2sc/g" $templ_dir_s/heat.tmpl > $system_prep/heat.in

  sed -e "s/%ONE%/$ligand1/g" -e "s/%TWO%/$ligand2/g" -e "s/%ONESC%/$ligand1@$ligand1sc/g" -e "s/%TWOSC%/$ligand2@$ligand2sc/g" $templ_dir_s/press.tmpl > $system_prep/press.in
done

sed -e "s/%%/$cudasetup/g" -e "s/%TRANS%/$trans/g" $templ_dir_s/run_all_md_complex_prepare.tmpl > $s_dir/complex_prepare/run_all_md_complex_prepare.sh
sed -e "s/%%/$cudasetup/g" -e "s/%TRANS%/$trans/g" $templ_dir_s/run_all_md_ligands_prepare.tmpl > $s_dir/ligands_prepare/run_all_md_ligands_prepare.sh
chmod u+x $s_dir/complex_prepare/run_all_md_complex_prepare.sh
chmod u+x $s_dir/ligands_prepare/run_all_md_ligands_prepare.sh

cp $templ_dir_s/2_run_md.tmpl $s_dir/2_run_md.sh
chmod u+x $s_dir/2_run_md.sh

#free energy

cp $templ_dir_fe/windows_$no_w $fe_dir/windows


cd $fe_dir
echo $fe_dir

. ./windows

FE="scmask1=':$ligand1@$ligand1sc', scmask2=':$ligand2@$ligand2sc',"

for system in complex ligands; do
  if [ \! -d $system ]; then
    mkdir $system
  fi

    cd $system

    for w in $windows; do
      if [ \! -d $w ]; then
        mkdir $w
      fi
      sed -e "s/%ONE%/$ligand1/g" -e "s/%TWO%/$ligand2/g" -e "s/%L%/$w/g" -e "s/%FE%/$FE/g" $templ_dir_fe/min.tmpl > $w/min.in
      sed -e "s/%ONE%/$ligand1/g" -e "s/%TWO%/$ligand2/g" -e "s/%L%/$w/g" -e "s/%FE%/$FE/g" $templ_dir_fe/heat.tmpl > $w/heat.in
      sed -e "s/%ONE%/$ligand1/g" -e "s/%TWO%/$ligand2/g" -e "s/%L%/$w/g" -e "s/%FE%/$FE/g" $templ_dir_fe/eq.tmpl > $w/eq.in
      sed -e "s/%ONE%/$ligand1/g" -e "s/%TWO%/$ligand2/g" -e "s/%L%/$w/g" -e "s/%FE%/$FE/g" -e "s/%WIND%/$wind/g" -e "s/%TW%/$no_w/g" $templ_dir_fe/prod.tmpl > $w/prod.in

    done

  cd $fe_dir
  done

sed -e "s/%CL%/$cudasetup/g" -e "s/%TRANS%/$trans/g" $templ_dir_fe/submit_ligands.tmpl > $fe_dir/submit_ligands.sh
chmod u+x $fe_dir/submit_ligands.sh

sed -e "s/%CC%/$cudasetup/g" -e "s/%TRANS%/$trans/g" $templ_dir_fe/submit_complex.tmpl > $fe_dir/submit_complex.sh
chmod u+x $fe_dir/submit_complex.sh

#copy execute
cp $templ_dir/execute.tmpl $trans_dir/execute.sh
chmod u+x $trans_dir/execute.sh

sed -e "s/%%/$cudasetup/g" -e "s/%TRANS%/$trans/g" $templ_dir/repeats.tmpl > $trans_dir/repeats.sh
chmod u+x $trans_dir/repeats.sh