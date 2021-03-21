#!/bin/bash
mode=$1
source=$2
destination=$3
mk_dir=$4

#check if variables are entered
if [ "$destination" = "" ]
then
echo "no mode,source or destination directory entered"
echo "usage: ./dc_unpack.sh <MODE> <SOURCE dir> <DESTINATION dir> <OPTION: (m)>"
echo "mode=d: use directories as input"
echo "mode=f: use files as input"
echo "m: create separate directories for each game - only use when archive does not contain directory"
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


#check mode file/dir
if [ "$mode" = d ]
then
#create list of all directories
ls "$source" -p | grep / | cut -f1 -d'/' > "$destination"/list.txt
else
#create list of all files
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

 #check if mk_dir option is entered
if [ "$mk_dir" = "m" ]
 then
 # make separate dirs for each game

 # extract extension
 # see https://stackoverflow.com/a/965072
 filename=$(basename -- "$game")
 extension="${filename##*.}"
 gamedir="${filename%.*}"
 mkdir "$destination"/"$gamedir"
 unrar x -y "$source"/"$game" "$destination"/"$gamedir"
 echo "$gamedir" >> "$destination"/"extracted.txt"

#13/03/2021:Temporarily disable -> check for which files this code applies to
#find "$destination" -name "*part01.rar" -print0 | while read -r -d $'\0' partrar
#do
#   unrardir=$(dirname "$partrar")
#   #unrar archive
#   unrar x -y "$partrar" "$unrardir/"
#   #delete partially archives
#   find "$unrardir/" -name "*.part*.rar" -exec rm -i -f {} \;
#done

 else
 #do NOT make separate dirs
 find "$source"/"$game" -name "*.rar" -exec unrar x -y {} "$destination" \;
 ######extract extension 
 filename=$(basename -- "$game")
 gamename="${filename%.*}"
 echo "$gamename" >> "$destination"/"extracted.txt"
 fi

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


#https://stackoverflow.com/questions/5119946/find-exec-with-multiple-commands

#find & extract partially archives
#https://stackoverflow.com/a/9612560

#RAR
#13/03/2021: possibly not necessary as *.rar would also extract *part01.rar
find "$destination" -name "*part01.rar" -print0 | while read -r -d $'\0' partrar
do
   unrardir=$(dirname "$partrar")
   #unrar archive
   unrar x -y "$partrar" "$unrardir/"
   #delete partially archives
   find "$unrardir/" -name "*.part*.rar" -exec rm -i -f {} \;
done

#001
find "$destination" -name "*.001" -print0 | while read -r -d $'\0' partrar
do
   unrardir=$(dirname "$partrar")
   #unrar archive
   unrar x -y "$partrar" "$unrardir/"
   #delete partially archives
   find "$unrardir/" -name "*.0??" -exec rm -i -f {} \;
done

#rar
find "$destination" -name "*.rar" -print0 | while read -r -d $'\0' partrar
do
   unrardir=$(dirname "$partrar")
   #unrar archive
   unrar x -y "$partrar" "$unrardir/"
   #delete partially archives
   find "$unrardir/" -name "*.r??" -exec rm -i -f {} \;
   #delete remaining .sfv files
   find "$destination" -name "*.sfv" -exec rm -i -f {} \;
   find "$destination" -name "*.SFV" -exec rm -i -f {} \;
done

#check for ecm, nrg and mdf in extracted file & convert them
if [ "$mode" = "f" ]
then
#efile mode
while IFS= read -r game ; do
#ecm
find "$destination"/"$game" -name "*.ecm" -exec unecm {} "$destination"/"$game"/"$game".cdi \;
find "$destination"/"$game" -name "*.ecm" -exec rm {} \;
#nrg
find "$destination"/"$game" -name "*.nrg" -exec nrg2iso {} "$destination"/"$game"/"$game".iso \;
find "$destination"/"$game" -name "*.nrg" -exec rm {} \;
#mdf
find "$destination"/"$game" -name "*.mdf" -exec mdf2iso --cue {} "$destination"/"$game"/"$game".iso \;
find "$destination"/"$game" -name "*.md*" -exec rm {} \;
done <"$destination"/extracted.txt
echo
fi

if [ "$mode" = "d" ]
then
#dir mode
while IFS= read -r game ; do
#ecm
find "$destination"/"$game" -name "*.ecm" -exec unecm {} "$destination"/"$game"/"$game".cdi \;
find "$destination"/"$game" -name "*.ecm" -exec rm {} \;
#nrg
find "$destination"/"$game" -name "*.nrg" -exec nrg2iso {} "$destination"/"$game"/"$game".iso \;
find "$destination"/"$game" -name "*.nrg" -exec rm {} \;
#mdf
find "$destination"/"$game" -name "*.mdf" -exec mdf2iso --cue {} "$destination"/"$game"/"$game".iso \;
find "$destination"/"$game" -name "*.md*" -exec rm {} \;
done < "$destination"/list.txt
fi



echo "$(tput setaf 2)Following games have been extracted:$(tput sgr 0)"
cat "$destination"/"extracted.txt"
