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

#remove potentially existing file & create new file for list of extracted games
#first check if already exists
if [ -f "$destination"/"extracted.txt" ] 
then
rm "$destination"/"extracted.txt"
touch "$destination"/"extracted.txt"
else
touch "$destination"/"extracted.txt"
fi


#Create a list of all games directories
##obsolete 
##ls -d */ | cut -f1 -d'/' > "$destination"/list.txt

#check mode file - dir
if [ "$mode" = d ]
then
#list all directories in list
ls "$source" -p | grep / | cut -f1 -d'/' > "$destination"/list.txt
else
#list all files in list
ls "$source" -p | grep -v / | cut -f1 -d'/' > "$destination"/list.txt
fi

exit 1

#uniq
#cat test1.txt | sort | uniq

#Loop for unpacking the games in directory
while IFS= read -r game ; do
#Check if folder already extist & skip this game
if [ -d "$destination"/"$game" ];then
echo "$game already exists! Skipping.."
else
mkdir "$destination"/"$game" -p
find "$source"/"$game" -name "*.001" -exec 7z x {} -o"$destination/$game" \;
find "$source"/"$game" -name "*.7z" -exec 7z x {} -o"$destination/$game" \;
find "$source"/"$game" -name "*.part1.rar" -exec unrar x {} "$destination/$game/" \;
find "$source"/"$game" -name "*.zip" -exec unzip {} -d "$destination/$game/" \;
echo "$game" >> "$destination"/"extracted.txt"
fi
done < "$destination"/list.txt


#check for ecm in extracted file & unecm them
while IFS= read -r game ; do
find "$destination"/"$game" -name "*.ecm" -exec unecm {} "$destination"/"$game"/"$game".cdi \;
find "$destination"/"$game" -name "*.ecm" -exec rm {} \;
done < "$destination"/list.txt

echo "$(tput setaf 2)Following games have been extracted:$(tput sgr 0)"
cat "$destination"/"extracted.txt"
