# MPLAB IDE generated this makefile for use with GNU make.
# Project: A8_AtoD.mcp
# Date: Mon Jul 18 10:00:54 2011

AS = MPASMWIN.exe
CC = mcc18.exe
LD = mplink.exe
AR = mplib.exe
RM = rm

A8_AtoD.cof : A8_AtoD.o
	$(LD) /p16F627A "A8_AtoD.o" /u_DEBUG /z__MPLAB_BUILD=1 /z__MPLAB_DEBUG=1 /o"A8_AtoD.cof" /M"A8_AtoD.map" /W /x

A8_AtoD.o : A8_AtoD.asm C:/Program\ Files/Microchip/MPASM\ Suite/p16f627a.inc LAB_IO_BSm.inc AtoDm.inc LCDm.inc
	$(AS) /q /p16F627A "A8_AtoD.asm" /l"A8_AtoD.lst" /e"A8_AtoD.err" /d__DEBUG=1

clean : 
	$(RM) "A8_AtoD.o" "A8_AtoD.hex" "A8_AtoD.err" "A8_AtoD.lst" "A8_AtoD.cof"

