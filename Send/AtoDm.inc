;============================================================================================.inc
;AtoDm.inc
;
;Beymer Bevill, Jr.
;
;Version 1.0 June 27, 2011
;

;===========================================================================================

;begin label port pins++++++++++++++++++++++++++++++++++++++
;label A/D control pins
ce		EQU		0x00
sc		EQU		0x01
;end label port pins+++++++++++++++++++++++++++++++++++++++++

;begin label storage in ram+++++++++++++++++++++++++++++++++++++++++++++++++++
;bank0 storage	
	cblock
       addat
       addatW
       addatT
       addatH
    endc

;end label storage++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


