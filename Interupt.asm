;Domas Nemanius 3 laboratorinis darbas 
;Parašykite rezidentinę programą, kuri pakeičia int 21h, 
;09 funkcijos veikimą taip, kad spausdinimui nurodyta eilutė 
;būtų išvedama keičiant visas mažąsias raides didžiosiomis.

%include 'yasmmac.inc'       


org 100h                                                

section .text                                             ; kodas prasideda cia đ
    Pradzia:
      jmp     Nustatymas                                  ;Pirmas paleidimas    

    SenasPertraukimas:
      dw      0, 0
	


NaujasPertraukimas:                                      
    
      macPushAll                                         ; Saugome registrus (uzpushina visus registrus)
      cmp ah, 0x9                                        ; 09h - WRITE STRING TO STANDARD OUTPUT
		JNE senoPertraukimoNaudojimas
		
		mov bx, dx
		mov dx, 0                                           ;stringo adresas nunulinamas, kad cmp galimetu daryt
		mov di, 0                                           


      ciklas
          mov dl, [bx + di]
          CMP dl, '$'                                   
          JE baigti
          mov ah, 0x2                                   
			
          CMP dl, "a"                                   
          JL cont
            
          CMP dl, "z"                                   
          JG cont
            
          sub dl, 32   
          
                                           
          cont
          
            int 0x21  
            int 0x21                                  
            inc di        
                                          
		JMP ciklas
    
		baigti
		
		macPopAll
		iret
	


    senoPertraukimoNaudojimas:
		pushf                                       ;flag'u registras, jei neuzpushinsim megins popint!
		call far [cs:SenasPertraukimas]             ;nuolat saukiamas senas pertraukimas
		macPopAll                                   ;atgaminame visus registrus 
		iret                                        ;senam pertraukime stovi iret, kuris grizta, o  paskui soka i cikla


;  Nustatymo (po pirmo paleidimo) blokas: jis NELIEKA atmintyje

      Nustatymas:
        ; Gauname sena   vektoriu ( grazina adresa tos proceduros, kuri dabar yra ir i kuria persoksiu atlikus savo proc.)
        push    cs
        pop     ds
        mov     ah, 0x35                         ;i al nurodome interupta su kuriuo norime dirbti
        mov     al, 0x21                         ; gauname sena pertraukimo vektoriu
        int     0x21
        
        ; Saugome sena vektoriu 
        mov     [cs:SenasPertraukimas], bx       ; issaugome seno doroklio poslinki    
        mov     [cs:SenasPertraukimas + 2], es   ; issaugome seno doroklio segmenta
        
        ; Nustatome nauja  vektoriu
        mov     dx, NaujasPertraukimas
        mov     ah, 0x25                          ; SET INTERRUPT funkcija
        mov     al, 0x21                          ; nustatome pertraukimo vektoriu
        int     21h 
 
        mov dx, Nustatymas + 1                    ; pazymime pabaiga kur baigiasi rezidentine dalis
        int     27h                               ; Padarome rezidentu (Rezervuojame kiek baitu norime issaugoti atmintyje )

%include 'yasmlib.asm'        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss                                      ; neinicializuoti duomenys  
