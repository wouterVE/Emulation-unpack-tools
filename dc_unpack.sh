#!/bin/bash
mode=$1
source=$2
destination=$3

#check if variables are entered
if [ "$destination" = "" ]
then
echo "no mode,source or destination directory entered"
echo "usage: ./dc_unpack.sh <MODE> <SOURCE dir> <DESTINATION dir>"
echo "mode d: use directories as input"
echo "mode f: use files as input"
exit 1
fi

#convert to full path
source=$(echo "$(cd "$(dirname "$source")"; pwd)/$(basename "$source")")
destination=$(echo "$(cd "$(dirname "$destination")"; pwd)/$(basename "$destination")")
#see https://stackoverflow.com/a/31605674/9240687


#create dir to extract games to
mkdir -p "$destination"

#check if list of extracted games already exists & remove it - otherwise just create one
if [ -f "$destination"/"extracted.txt" ] 
then
rm "$destination"/"extracted.txt"
touch "$destination"/"extracted.txt"
else
touch "$destination"/"extracted.txt"
fi


#check mode file - dir
if [ "$mode" = d ]
then
#list all directories in list
ls "$source" -p | grep / | cut -f1 -d'/' > "$destination"/list.txt
else
#list all files in list
ls "$source" -p | grep -v / | cut -f1 -d'/' > "$destination"/list.txt
fi


#Loop for unpacking the games in directory
while IFS= read -r game ; do
#Check if folder already extist & skip this game
if [ -d "$destination"/"$game" ];then
echo "$game already exists! Skipping.."
else
#check entered mode
if [ "$mode" = "f" ] 
then
#file mode
find "$source"/"$game" -name "*.rar" -exec unrar x -y {} "$destination" \;
echo "$game" >> "$destination"/"extracted.txt"
fi
if [ "$mode" = "d" ]
then
#dir mode
mkdir "$destination"/"$game" -p
find "$source"/"$game" -name "*.001" -exec 7z x {} -o"$destination/$game" \;
find "$source"/"$game" -name "*.7z" -exec 7z x {} -o"$destination/$game" \;
find "$source"/"$game" -name "*.part1.rar" -exec unrar x {} "$destination/$game/" \;
find "$source"/"$game" -name "*.zip" -exec unzip {} -d "$destination/$game/" \;
echo "$game" >> "$destination"/"extracted.txt"
fi

fi
done < "$destination"/list.txt


#check for ecm in extracted file & unecm them
if [ "$mode" = "f" ]
then
#file mode
echo
fi

if [ "$mode" = "d" ]
then
#dir mode
while IFS= read -r game ; do
find "$destination"/"$game" -name "*.ecm" -exec unecm {} "$destination"/"$game"/"$game".cdi \;
find "$destination"/"$game" -name "*.ecm" -exec rm {} \;
done < "$destination"/list.txt
fi


#https://stackoverflow.com/questions/5119946/find-exec-with-multiple-commands

#find & extract partially archives
#https://stackoverflow.com/a/9612560

#RAR
find "$destination" -name "*part01.rar" -print0 | while read -d $'\0' partrar
do
   unrardir=$(dirname "$partrar")
   #unrar archive
   unrar x -y "$partrar" "$unrardir/"
   #delete partially archives
   find "$unrardir/" -name "*.part*.rar" -exec rm -i -f {} \;
done

#001
find "$destination" -name "*.001" -print0 | while read -d $'\0' partrar
do
   unrardir=$(dirname "$partrar")
   #unrar archive
   unrar x -y "$partrar" "$unrardir/"
   #delete partially archives
   find "$unrardir/" -name "*.0??" -exec rm -i -f {} \;
done

#rar
find "$destination" -name "*.rar" -print0 | while read -d $'\0' partrar
do
   unrardir=$(dirname "$partrar")
   #unrar archive
   unrar x -y "$partrar" "$unrardir/"
   #delete partially archives
   find "$unrardir/" -name "*.r??" -exec rm -i -f {} \;
   #delete .sfv files
   find "$destination" -name "*.sfv" -exec rm -i -f {} \;
done



echo "$(tput setaf 2)Following games have been extracted:$(tput sgr 0)"
cat "$destination"/"extracted.txt"
