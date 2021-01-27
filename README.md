# Emulation-unpack-tools
Collection of scripts to automatically unpack your romsets to the correct format

Short explanation of the usage:

## dc_unpack.sh

Originally created to unpack my Dreamcast rom collection but could be used for other systems as well. 
You will need to have the following dependencies:
* unecm
* unrar
* 7z
* unzip
<p>
Please consult your distrubution on how to install this.
<BR>
The syntax is as follows: <br>

```
./dcunpack.sh <MODE> <SOURCE dir> <DESTINATION dir>
```

* `<MODE>`: 
`f` = all your roms are in archives directly in the SOURCE DIR eg <br>
```
<SOURCE DIR>
|-<SONIC ADVENTURE 1.RAR>
|-<VIRTUA FIGHTER 3.RAR>
```
`d` = all your roms are in separate dirs in your SOURCE DIR eg <br>
```
<SOURCE DIR>
|-<SONIC ADVENTURE 1/>
|  |-<SONIC ADVENTURE 1.RAR>
|-<VIRTUA FIGHTER 3>
   |-<VIRTUA FIGHTER 3.RAR>
```
* `<SOURCE dir>`: The directory containing your roms
* `<DESTINATION dir>`: The (new) directory to where you want to extract your roms


This script will do the following steps:
* Find archive files (`.rar`, `.zip`...) and extract them to the `<DESTINATION dir>`
* Check if there are `.ecm` files present and extract them
* Clean up partially (rar) archives & `.ecm` files
* Display a list of extracted games & save them under `<DESTINATION dir>/extracted.txt`
<br> *Written & tested on on debian 10 - possibly also works under other distros*
