#!/bin/bash

echo "Select a resolution for the vga output(1/2/3/4):"
echo
echo "1.\\tVGA"
echo "2.\\tXVGA"
echo "3.\\HD"
echo "4.\\FHD"
echo
read selection

BASEADDRESSREG0=0x43C00000
BASEADDRESSREG1=0x43C00004

if (( selection == 1 ))
then
	devmem $(BASEADDRESSREG0) 32 0x53018280
	devmem $(BASEADDRESSREG1) 32 0x284F010
elif (( selection == 2 ))
then
	devmem $(BASEADDRESSREG0) 32 0x1C450400
	devmem $(BASEADDRESSREG1) 32 0xE758018
elif (( selection == 3 ))
then
	devmem $(BASEADDRESSREG0) 32 0x1A86C500
	devmem $(BASEADDRESSREG1) 32 0x35596848
elif (( selection == 4 ))
then
	devmem $(BASEADDRESSREG0) 32 0x2164A780
	devmem $(BASEADDRESSREG1) 32 0x3D921C58
else
	echo "Insert only a number from 1 to 4"
fi

exit
