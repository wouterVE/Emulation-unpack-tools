#!/bin/bash
find . -mindepth 2 -type f \( -iname \*.cue -o -iname \*.bin -o -iname \*.iso \)  -exec mv {} . \;
#\( -iname \*.cue -o -iname \*.bin \)

while read -r game; do

name=$(echo "$game" | rev | cut -f2- -d '.' | rev)
#to prevent filenames with . in the name to be cut to early (e.g. sega ages vol. X.cue)
#see https://unix.stackexchange.com/a/217630/308419
#echo "$name"
#check if .bin file exists
if [ -f  "$name".bin ]
then
bchunk "$name".bin "$name".cue "$name"
else
echo "skipping "$name".iso"
fi

done < list.txt

#create folder CD & DVD
for dir in CD DVD
do
#first check if already exist
if [ -d "$dir" ]
then
echo "$dir already exists!"
else
echo "create $dir"
mkdir "$dir"
fi
done

echo "moving iso's to correct folder"
# move iso's up to 700MB to folder CD
find . -maxdepth 1 -type f -name "*.iso" -size -701M -exec mv -f {} CD/ \;
# move iso's up to 700MB to folder CD
find . -maxdepth 1 -type f -name "*.iso"  -exec mv -f {} DVD/ \;

#Cleanup .bin & .cue files
find . -type f \( -iname \*.cue -o -iname \*.bin \)  -exec rm {} \;
#multiple extensions see: https://unix.stackexchange.com/a/15309/308419

#Cleanup iso directories
while true; do
    read -p "Do you want to delete the remaining ISO folders (y/n)? " yn
    case $yn in
#exclude directories CD & DVD see https://stackoverflow.com/a/4210072
        [Yy]* ) find -type d  -not \( -path ./CD -o -path ./DVD \) -exec rm -rf {} \;;;
        [Nn]* ) exit 1;;
        * ) echo "press y or n";;
    esac
done


