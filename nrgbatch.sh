#!/bin/bash

dir=$1


#check if dir variable is entered

if [ "$dir" = "" ] 
then
echo "no directory entered"
echo "usage: ./nrgbatch.sh <DIR>"
exit 1
fi


#check if dir has trailing slash (/)
lastchar=$(echo "${dir: -1}")
if [ "$lastchar" = "/" ]
then
echo
else
dir=$(echo "$dir/" )
fi

touch "$dir"converted.txt
mkdir "$dir"iso


#Create list of nrg files
find "$dir" -type f -name "*.nrg" -exec basename {} \;  | sed "s/\.nrg//" > list.txt

#loop for converting every .nrg file in the list
while IFS= read -r line ; do
#Check if iso already exists
if test -f "$dir""$line".iso; then
echo "$line.iso already exists ... skipping"
#convert the nrg to iso
else
echo "converting $line.nrg"
nrg2iso  "$line".nrg "$line".iso
echo "$line.nrg" >> "$dir"converted.txt
fi
done < list.txt

#check if there are any files converted
check=$(cat converted.txt)

if [ "$check" = ""  ]
then
echo "No files have been converted!"
rm list.txt
exit 1
else
echo "The following nrg files have been converted"
cat converted.txt
echo "Do you want to PERMANENTLY delete the .nrg files?"
echo "!!CAUTION - NO WAY TO RESTORE!!"
echo "Delete: (yes/No)"
fi





#delete the nrg list
rm list.txt

