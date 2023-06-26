#!/bin/bash

############################################################
# help                                                     #
############################################################
Help()
{
   # Display help
   echo "Script to automatically unpack your iso romsets to the correct format"
   echo
   echo "Syntax: ./dc_unpack.sh [-s|d|M|m|p|h]"
   echo "options:"
   echo "  -m     choose input mode | d use directories as input | f: use files as input"
   echo "  -M     create separate directories for each game - use only when archive does not contain directories"
   echo "  -p     use this option when extracting PS2 isos"
   echo "  -s     source directory"
   echo "  -d     destination directory"
   echo
   echo "example: ./dc_unpack.sh -s dcroms -d dcroms/extracted -m d -M -p"
}

############################################################
ps2()
{
   find "$destination" -mindepth 2 -type f \( -iname \*.cue -o -iname \*.bin -o -iname \*.iso \)  -exec mv {} "$destination" \;
   #\( -iname \*.cue -o -iname \*.bin \)

   while read -r game; do

   name=$(echo "$game" | rev | cut -f2- -d '.' | rev)
   #to prevent filenames with . in the name to be cut to early (e.g. sega ages vol. X.cue)
   #see https://unix.stackexchange.com/a/217630/308419
   #echo "$name"
   #check if .bin file exists
 if [ -f  "$destination"/"$name".bin ]
  then
   bchunk "$destination"/"$name".bin "$destination"/"$name".cue "$destination"/"$name"
  else
   echo "skipping "$name".iso"
 fi

 done < "$destination"/list.txt

 # remove 01 in the filename of the isos
 find "$destination" -type f -name *01* -exec bash -c 'new_filename="${1:0:-6}${1:(-4)}"; mv "$1" "$new_filename"' _ {} \;

   #create folder CD & DVD
   for dir in CD DVD
    do
   #first check if already exist
      if [ -d "$destination"/"$dir" ]
       then
      echo "$dir already exists!"
       else
      echo "create $dir"
      mkdir "$destination"/"$dir"
      fi
    done
 echo "moving iso's to correct folder"
 # move iso's up to 700MB to folder CD
 find "$destination" -maxdepth 1 -type f -name "*.iso" -size -701M -exec mv -f {} "$destination"/CD/ \;
 # move iso's up to 700MB to folder CD
 find "$destination" -maxdepth 1 -type f -name "*.iso"  -exec mv -f {} "$destination"/DVD/ \;

 #Cleanup .bin & .cue files
 find "$destination" -type f \( -iname \*.cue -o -iname \*.bin \)  -exec rm {} \;
 #multiple extensions see: https://unix.stackexchange.com/a/15309/308419

 #show extracted games
 echo "$(tput setaf 2)Following games have been extracted:$(tput sgr 0)"
 cat "$destination"/"extracted.txt"

 #Cleanup iso directories
 while true; do
    read -p "Do you want to delete the remaining ISO folders (y/n)? " yn
    case $yn in
 #exclude directories CD & DVD see https://stackoverflow.com/a/4210072
        [Yy]* ) find "$destination" -mindepth 1 -type d  -not \( -path "$destination"/CD -o -path "$destination"/DVD \) -exec rm -rf {} \; > /dev/null 2>&1 & exit 1 ;;
        [Nn]* ) exit 1;;
        * ) echo "press y or n";;
    esac
done

}



############################################################
while getopts ":hs:d:Mm:p" option; do
  case "$option" in
      h) # display help
         Help
         exit;;
      s) # Source
         source="$OPTARG";;
      d) # destination
         destination="$OPTARG";;
      M) #mkdir
         mk_dir="m";;
      m) #mode
         mode="$OPTARG";;
      p) # ps2
         ps2="1";;
      \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
    esac
done
#echo mode "$mode"
#echo source "$source"
#echo destination "$destination"
#echo mk_dir "$mk_dir"
#echo PS2 "$ps2"


if [ -z "$source" ] || [ -z "$destination" ] || [ -z "$mode" ]
then
      echo "please enter valid source, destination & mode"
      echo
      Help
      exit 1
else
      echo > /dev/null
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
 ### file mode & make separate dirs for each game

 # extract extension
 # see https://stackoverflow.com/a/965072
 filename=$(basename -- "$game")
 extension="${filename##*.}"
 gamedir="${filename%.*}"

 mkdir "$destination"/"$gamedir"
 find "$source"/"$game" -name "*.rar" -exec unrar x -y {} "$destination"/"$gamedir" \;
 find "$source"/"$game" -name "*.zip" -exec unzip {} -d "$destination"/"$gamedir" \;
 find "$source"/"$game" -name "*.7z" -exec 7z x {} -y -o"$destination"/"$gamedir" \;
 find "$source"/"$game" -name "*.part1.rar" -exec unrar x -y {} "$destination"/"$gamedir" \;
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
 #file mode & do NOT make separate dirs
 find "$source"/"$game" -name "*.rar" -exec unrar x -y {} "$destination" \;
 find "$source"/"$game" -name "*.zip" -exec unzip {} -d "$destination" \; 
 find "$source"/"$game" -name "*.7z" -exec 7z x {} -y -o"$destination" \;
 find "$source"/"$game" -name "*.part1.rar" -exec unrar x -y {} "$destination" \;


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
find "$source"/"$game" -name "*.001" -exec 7z x {} -y -o"$destination/$game" \;
find "$source"/"$game" -name "*.7z" -exec 7z x {} -y -o"$destination/$game" \;
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
##find "$destination" -name "*part01.rar" -print0 | while $read -r -d $'\0' partrar
#do
#   unrardir=$(dirname "$partrar")
   #unrar archive
#   unrar x -y "$partrar" "$unrardir/"
   #delete partially archives
#   find "$unrardir/" -name "*.part*.rar" -exec rm -i -f {} \;
#done

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
#file mode
while IFS= read -r game ; do
#ecm
find "$destination" -name "*.ecm" -exec unecm {} "$destination"/"$game"/"$game".cdi \;
find "$destination" -name "*.ecm" -exec rm {} \;
#nrg
find "$destination" -name "*.nrg" -exec nrg2iso {} "$destination"/"$game"/"$game".iso \;
find "$destination" -name "*.nrg" -exec rm {} \;
#mdf
find "$destination" -name "*.mdf" -exec mdf2iso --cue {} "$destination"/"$game"/"$game".iso \;
find "$destination" -name "*.md*" -exec rm {} \;
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


 if [ "$ps2" = 1 ]
  then
   ps2
  else
   echo "$(tput setaf 2)Following games have been extracted:$(tput sgr 0)"
   cat "$destination"/"extracted.txt"
 fi


##temp auto PS2 unpack
##cd "$destination"
##/home/wouter/batch/Emulation-unpack-tools/ps2_unpack.sh
