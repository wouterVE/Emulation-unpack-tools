# Emulation-unpack-tools
Collection of scripts to automatically unpack your romsets to the correct format

Short explanation of the usage:

## dc_unpack.sh

Originally created to unpack my Dreamcast rom collection but could be used for other systems as well. 
You will need to have the following dependencies:
* unecm (instructions see below)
* unrar
* 7z
* unzip
<p>
Please consult your distrubution on how to install this.
<BR>
The syntax is as follows: <br>

```
./dcunpack.sh <MODE> <SOURCE dir> <DESTINATION dir> <OPTION m>
```

* `<MODE>`:<br>
<br>`f` = all your roms are in archives directly in the SOURCE DIR e.g. <br>
```
<SOURCE DIR>
|_<SONIC ADVENTURE 1.RAR>
|_<VIRTUA FIGHTER 3.RAR>

```
`d` = all your roms are in separate dirs in your SOURCE DIR e.g. <br>
```
<SOURCE DIR>
|_<SONIC ADVENTURE 1/>
|  |_<SONIC ADVENTURE 1.RAR>
|_<VIRTUA FIGHTER 3>
   |_<VIRTUA FIGHTER 3.RAR>
```
* `<SOURCE dir>`: The directory containing your roms
* `<DESTINATION dir>`: The (new) directory to where you want to extract your roms
* `<OPTION m>`: creates separate directories to extract each archive to. Only use when the archives don't containt any folder and only in file mode


This script will do the following steps:
* Find archive files (`.rar`, `.zip`...) and extract them to the `<DESTINATION dir>`
* Check if there are `.ecm` files present and extract them
* Clean up partially (rar) archives & `.ecm` files
* Display a list of extracted games & save them under `<DESTINATION dir>/extracted.txt`

## nrgbatch.sh
Used to convert .nrg files to .iso
Usage:
```
usage: ./nrgbatch.sh <DIR>
```
With `<DIR>` the directory where your `.nrg` files are located.
After all files are converted you also have the possibility to delete the .nrg files (WIP - not implemented yet)


   unecm Instructions for Debian/Ubuntu:
   1. Download source from https://raw.githubusercontent.com/MaddTheSane/ECMGUI/master/unecm/unecm.c
   2. compile using the folowing command `gcc -o unecm unecm.c` 
   3. Copy the unecm file to `/usr/bin` so you can call the program system-wide (`cp unecm /usr/bin`)
<br><br>*All written & tested on on debian 10 - possibly also works under other distros*
