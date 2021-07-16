
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt
include 'emu8086.inc'
org 100h

.data segment
    a DB 032H,088H,031H,0e0H
      DB 043H,05aH,031H,037H
      DB 0f6H,030H,098H,007H
      DB 0a8H,08dH,0a2H,034H
      
    key DB 02bH,028H,0abH,09H
        DB 07eH,0aeH,0F7H,0cfH
        DB 015H,0d2H,015H,04fH
        DB 016H,0a6H,088H,03cH
        
    newkey  DB 00H,00H,00H,00H
            DB 00H,00H,00H,00H
            DB 00H,00H,00H,00H
            DB 00H,00H,00H,00H
    
    
    sbox DB 063H,07cH,077H,07bH,0f2H,06bH,06fH,0c5H,030H,001H,067H,02bH,0feH,0d7H,0abH,076H
        DB 0caH,082H,0c9H,07dH,0faH,059H,047H,0f0H,0adH,0d4H,0a2H,0afH,09cH,0a4H,072H,0c0H
        DB 0b7H,0fdH,093H,026H,036H,03fH,0f7H,0ccH,034H,0a5H,0e5H,0f1H,071H,0d8H,031H,015H
        DB 004H,0c7H,023H,0c3H,018H,096H,005H,09aH,007H,012H,080H,0e2H,0ebH,027H,0b2H,075H
        DB 009H,083H,02cH,01aH,01bH,06eH,05aH,0a0H,052H,03bH,0d6H,0b3H,029H,0e3H,02fH,084H
        DB 053H,0d1H,000H,0edH,020H,0fcH,0b1H,05bH,06aH,0cbH,0beH,039H,04aH,04cH,058H,0cfH
        DB 0d0H,0efH,0aaH,0fbH,043H,04dH,033H,085H,045H,0f9H,002H,07fH,050H,03cH,09fH,0a8H
        DB 051H,0a3H,040H,08fH,092H,09dH,038H,0f5H,0bcH,0b6H,0daH,021H,010H,0ffH,0f3H,0d2H
        DB 0cdH,00cH,013H,0ecH,05fH,097H,044H,017H,0c4H,0a7H,07eH,03dH,064H,05dH,019H,073H
        DB 060H,081H,04fH,0dcH,022H,02aH,090H,088H,046H,0eeH,0b8H,014H,0deH,05eH,00bH,0dbH
        DB 0e0H,032H,03aH,00aH,049H,006H,024H,05cH,0c2H,0d3H,0acH,062H,091H,095H,0e4H,079H
        DB 0e7H,0c8H,037H,06dH,08dH,0d5H,04eH,0a9H,06cH,056H,0f4H,0eaH,065H,07aH,0aeH,008H
        DB 0baH,078H,025H,02eH,01cH,0a6H,0b4H,0c6H,0e8H,0ddH,074H,01fH,04bH,0bdH,08bH,08aH
        DB 070H,03eH,0b5H,066H,048H,003H,0f6H,00eH,061H,035H,057H,0b9H,086H,0c1H,01dH,09eH
        DB 0e1H,0f8H,098H,011H,069H,0d9H,08eH,094H,09bH,01eH,087H,0e9H,0ceH,055H,028H,0dfH
        DB 08cH,0a1H,089H,00dH,0bfH,0e6H,042H,068H,041H,099H,02dH,00fH,0b0H,054H,0bbH,016H
    
    mat DB 2,3,1,1
        DB 1,2,3,1
        DB 1,1,2,3
        DB 3,1,1,2
    rcon    DB 01H,02H,04H,08H,10H,20H,40H,80H,1BH,36H
            DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
            DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
            DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H    
        
    MS1 DB 00FH
    MS2 DB 0F0H
    MS3 DB 00011011B
    roundcount DW 0

.code segment
    MOV BH, 4                    ; set BH=4
    MOV BL, 4                    ; set BL=4
    
    LEA SI, a                    ; set SI=offset address of a
    LEA DI, mat                  ; set DI=offset address of mat
    
    CALL UserInput
    
    CALL Step4                  ; initial step

Loop1:    
    CALL KeySchedule    
    CALL Step1             
    CALL Step2        
    CALL Step3
    CALL Step4
    INC roundcount
    
    CMP roundcount,9
    JNE Loop1
    
    PRINTN
    PRINT "Cipher Text After 9th Round: "
    PRINTN
    CALL PRINT_2D_ARRAY          ; call the procedure PRINT_2D_ARRAY
    PRINTN
    
    CALL KeySchedule    
    CALL Step1             
    CALL Step2            
    CALL Step4
    
    PRINT "Final Cipher Text: "
    PRINTN
    CALL PRINT_2D_ARRAY          ; call the procedure PRINT_2D_ARRAY
    PRINTN
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; take user input as a 16 pair ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UserInput PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    
    
    MOV AH,1            ; prepare AH for input
        
    MOV CL,16
    MOV CH,0
    MOV SI,0
        
    ; user must enter values in hexa format and in case of characters like A must be in capital 
    PRINT "Enter values in Hexa (without press enter or space): "
    PRINTN
        
    INPUT:
        INT 21H
        CALL AdjustDigit
        SAL AL,4
        Mov BL,AL
           
        INT 21H
        CALL AdjustDigit
           
        Add AL,BL
        MOV a[SI],AL
        INC SI
    LOOP INPUT
    
    POP SI
    POP CX
    POP BX
    POP AX
    
    RET    
UserInput ENDP

AdjustDigit Proc
    CMP AL,065
    JL  Digit                       ; 65 ascii for A
    SUB AL,055                      ; A,B,C,D,E,F handling
Digit:
    AND AL,0FH                      ;convert from ascii value to real value    
    RET     
AdjustDigit ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; imp note DI Register holds the column number of rcon matrix
KeySchedule PROC
    PUSH AX    
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI          
    ;;;;;;;;;;;;;;;;;;;;;;; First Step (Last Column Shift) ;;;;;;;;;;;;;;;;
    MOV AL,key[3]                   
    MOV newkey[12],AL    
    
    MOV AL,key[7]
    MOV newkey[0],AL
        
    MOV AL,key[11]                   
    MOV newkey[4],AL
        
    MOV AL,key[15]                   
    MOV newkey[8],AL 
    ;;;;;;;;;;;;;;;;;;;;;;; Second Step (Byte Sub.) ;;;;;;;;;;;;;;;;;;;;;;;
    MOV CL, BL                   ; CL counter = 4
    MOV SI, 0

    KeyScheduleL0:                 
       MOV AL,newkey[SI]               
       
       CALL SubByte               ; call the procedure SubByte that gives the index of byte in sbox array
       
       MOV  AH,sbox[DI]           ; get the dyte from sub matrix
       MOV  newkey[SI],AH            ; update the array with the result of subistitution  

       ADD SI, 4                  
       DEC CL                     
    JNZ KeyScheduleL0
    ;;;;;;;;;;;;;;;;;;;;;;; Third Step (XOR) ;;;;;;;;;;;;;;;;;;;;;;;
    MOV DI, roundcount                   
    MOV SI, 0
    MOV CL, BL                   

    KeyScheduleL1:                        
            MOV AL, key[SI]
            MOV AH, newkey[SI]                      
            XOR AL,AH
            
            MOV AH,rcon[DI]
            XOR AL,AH
                   
            MOV  newkey[SI],AL        ; update the array with the result of xor  

            ADD SI, 4
            ADD DI, 10                  
            DEC CL                     
    JNZ KeyScheduleL1              
    
    MOV CH,3                 ; outer loop is 3 not 4 since first column is finished
    MOV SI,1
    KeyScheduleL2:
            MOV CL, BL
            KeyScheduleL3:                        
                MOV AL, key[SI]
                MOV AH, newkey[SI-1]                      
                XOR AL,AH                      
                       
                MOV  newkey[SI],AL        ; update the array with the result of xor  
    
                ADD SI, 4            
                DEC CL                     
            JNZ KeyScheduleL3
            
            SUB SI,15
            DEC CH
    JNZ KeyScheduleL2  
    ;;;;;;;;;;;;;;;;;;;;;;; Finally Copy newkey into old key ;;;;;;;;;;;;;;;;;;;;;;;
    MOV CL,16
    MOV SI,0
    KeyScheduleL4:                        
         MOV AL, newkey[SI]
         MOV key[SI],AL                                 
    
         ADD SI, 1            
         DEC CL                     
    JNZ KeyScheduleL4
            
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    RET
KeySchedule ENDP    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; First Step Sub Bytes ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Step1 PROC
   PUSH AX                        ; push BX onto the STACK
   PUSH CX                        ; push CX onto the STACK   
   PUSH SI                        ; push SI onto the STACK
   PUSH DI                        ; push DI onto the STACK
       
   MOV CX, BX                     ; set CX=BX
   MOV SI, 0
   
   Step1L1:                   ; loop label
     MOV CL, BL                   ; set CL=BL

     Step1L2:                 ; loop label       
       MOV AL, a[SI]               ; set AX=[SI]
       
       CALL SubByte               ; call the procedure SubByte that gives the index of byte in sbox array
       
       MOV  AH,sbox[DI]             ; get the dyte from sub matrix
       MOV  a[SI],AH                 ; update the array with the result of subistitution  

       ADD SI, 1                  ; set SI=SI+1
       DEC CL                     ; set CL=CL-1
     JNZ Step1L2              ; jump to label @INNER_LOOP if CL!=0
                    
     DEC CH                       ; set CH=CH-1
   JNZ Step1L1                ; jump to label @OUTER_LOOP if CX!=0
   
   POP DI                         ; pop a value from STACK into DI
   POP SI                         ; pop a value from STACK into SI   
   POP CX                         ; pop a value from STACK into CX
   POP AX                         ; pop a value from STACK into AX
    
   RET    
Step1 ENDP
; assume input in al and output in DI
SubByte PROC  
    MOV AH,AL
    
    AND AL,MS1
    AND AH,MS2
    ROR AH,04
    
    SAL  AH,4                    ; AH= AH * 16
    ADD  AL,AH                   ; AL= AL + AH gives the required index
    MOV  AH,0                    ; reset AH to zero to copy only AL to DI 
    MOV  DI,AX                   ; because we can't copy AL to DI directly but we can copy AX to DI(both are 16 bits)
    
    RET
SubByte ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Second Step Shift Rows ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Step2 PROC
    PUSH AX                        ; push BX onto the STACK
    
    MOV AL,a[4]                    ; second row shift
    
    MOV AH,a[5]
    MOV a[4],AH    
    MOV AH,a[6]
    MOV a[5],AH    
    MOV AH,a[7]
    MOV a[6],AH
        
    MOV a[7],AL
    
    
    MOV AL,a[8]                    ; third row shift
    MOV AH,a[10]
    MOV a[8],AH        
    MOV a[10],AL
    MOV AL,a[9]                    
    MOV AH,a[11]
    MOV a[9],AH        
    MOV a[11],AL
    
    
    MOV AL,a[15]                    ; forth row shift
    
    MOV AH,a[14]
    MOV a[15],AH    
    MOV AH,a[13]
    MOV a[14],AH    
    MOV AH,a[12]
    MOV a[13],AH
        
    MOV a[12],AL
    
    POP AX                         ; pop a value from STACK into AX
    RET    
Step2 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Third Step Mix Columns ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Step3 PROC
   PUSH AX                        ; push AX onto the STACK
   PUSH BX                        ; push BX onto the STACK
   PUSH CX                        ; push CX onto the STACK   
   PUSH DX                        ; push DX onto the STACK   
   PUSH SI                        ; push SI onto the STACK
   PUSH DI                        ; push DI onto the STACK
       
   MOV CX, BX                     ; set CX=BX (outer loop)
   MOV DI,0
   MOV SI,0

   Step3L1:                       ; set DH=BL (inner loop)
        MOV    DH,BL
        Step3L2:  
             MOV CL, BL                 ; set CL=BL (inner inner loop)
             MOV AH,0                   ; AH act as XOR Sum

             Step3L3:                 ; loop label       
                   MOV AL, a[SI]               ; set AL=[SI]
                   MOV DL, mat[DI]               ; set DL=[DI]
                   
                   CMP DL,1                   ; check if DL is 1
                   JE Cont
                   
                   CMP DL,2                   ; check if DL is 2
                   JE  Two
                   JMP Three                  
                   
                   Two:
                   CALL MixColumn2
                   JMP  Cont   
                   
                   Three:
                   CALL MixColumn3
             
                   Cont:
                   XOR  AH,AL   
            
                   ADD SI, 4                  ; set SI=SI+4
                   ADD DI, 1                  ; set DI=DI+1
                   DEC CL                     ; set CL=CL-1
             JNZ Step3L3              ; jump to label @INNER_LOOP if CL!=0
     
             PUSH   AX                ; we push the whole AX because stack rules must be 16 bits but we need only AH part 
             SUB    SI,16
             DEC    DH
        JNZ Step3L2      
        
        ; get results from stack into array
        MOV   CL, BL                ; initialize CL to 4 again to pop 4 values from stack to array again
        ADD   SI,16                 ; Last loop you subtract 16 but you don't enter this loop again so
                                    ; add another 16 inorder to pop from the stack and insert it in the
                                    ; column in the required order (from bottom to top) 
        ResultLoop:
        POP   AX
        SUB   SI,4
        MOV   a[SI],AH
        DEC   CL
        JNZ   ResultLoop
        
        ADD   SI,1
        SUB   DI,16               
        DEC   CH                       ; set CH=CH-1
   JNZ Step3L1                ; jump to label @OUTER_LOOP if CX!=0
   
   POP DI                         ; pop a value from STACK into DI
   POP SI                         ; pop a value from STACK into SI   
   POP DX                         ; pop a value from STACK into DX
   POP CX                         ; pop a value from STACK into CX
   POP BX                         ; pop a value from STACK into BX
   POP AX                         ; pop a value from STACK into AX
    
   RET    
Step3 ENDP
                            ;;;;;;;;;;;;; Helper Functions for Mix Columns ;;;;;;;;;;;;;;;;;;;;
MixColumn2 PROC
    CMP     AL, 0
    JL      isNegative
    SAL     AL,1
    JMP     exit1
isNegative:
    SAL     AL,1
    XOR     AL,MS3    
exit1:    
    RET
MixColumn2 ENDP


MixColumn3 PROC
    MOV     DL,AL
    CALL    MixColumn2
    XOR     AL,DL        
    RET
MixColumn3 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Forth Stwp Add Round Key ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Step4 PROC
   PUSH AX                        ; push BX onto the STACK
   PUSH CX                        ; push CX onto the STACK   
   PUSH SI                        ; push SI onto the STACK
   PUSH DI                        ; push DI onto the STACK
       
   MOV CX, BX                     ; set CX=BX
   MOV SI, 0

   Step4L1:                   ; loop label
     MOV CL, BL                   ; set CL=BL

     Step4L2:                 ; loop label       
           MOV AL,a[SI]               ; set AX=[SI]
           MOV AH,key[SI]
           XOR AL,AH
           
           MOV  a[SI],AL                 ; update the array 
    
           ADD SI, 4                  ; set SI=SI+1
           DEC CL                     ; set CL=CL-1
     JNZ Step4L2              ; jump to label @INNER_LOOP if CL!=0
     
     SUB SI,15               
     DEC CH                       ; set CH=CH-1
   JNZ Step4L1                ; jump to label @OUTER_LOOP if CX!=0
   
   POP DI                         ; pop a value from STACK into DI
   POP SI                         ; pop a value from STACK into SI   
   POP CX                         ; pop a value from STACK into CX
   POP AX                         ; pop a value from STACK into AX
    
   RET
Step4 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRINT_2D_ARRAY PROC
    ; this procedure will print the given 2D array
    ; input : SI=offset address of the 2D array
    ;       : BH=number of rows
    ;       : BL=number of columns 
    ; output : none

   PUSH AX                        ; push BX onto the STACK
   PUSH CX                        ; push CX onto the STACK
   PUSH DX                        ; push DX onto the STACK
   PUSH SI                        ; push SI onto the STACK
   
   MOV CX, BX                     ; set CX=BX

   @OUTER_LOOP:                   ; loop label
     MOV CL, BL                   ; set CL=BL

     @INNER_LOOP:                 ; loop label
       MOV AH, 2                  ; set output function
       MOV DL, 20H                ; set DL=20H
       INT 21H                    ; print a character
                             
       MOV AL, [SI]               ; set AX=[SI]
                            
       CALL OUTDEC                ; call the procedure OUTDEC

       ADD SI, 1                  ; set SI=SI+1
       DEC CL                     ; set CL=CL-1
     JNZ @INNER_LOOP              ; jump to label @INNER_LOOP if CL!=0
                           
     MOV AH, 2                    ; set output function
     MOV DL, 0DH                  ; set DL=0DH
     INT 21H                      ; print a character

     MOV DL, 0AH                  ; set DL=0AH
     INT 21H                      ; print a character

     DEC CH                       ; set CH=CH-1
   JNZ @OUTER_LOOP                ; jump to label @OUTER_LOOP if CX!=0
   
   MOV AH, 2                  ; set output function
   MOV DL, 0DH                ; set DL=20H
   INT 21H

   POP SI                         ; pop a value from STACK into SI
   POP DX                         ; pop a value from STACK into DX
   POP CX                         ; pop a value from STACK into CX
   POP AX                         ; pop a value from STACK into AX

   RET
PRINT_2D_ARRAY ENDP

OUTDEC PROC
   PUSH BX                        ; push BX onto the STACK
   PUSH CX                        ; push CX onto the STACK
   PUSH DX                        ; push DX onto the STACK
    
   mov cx,2         ; print 2 hex digits ( 8 bits)
    .print_digit:
        rol al,4   ; move the currently left-most digit into the least significant 4 bits
        mov dl,al
        and dl,0xF  ; isolate the hex digit we want to print
        add dl,'0'  ; and convert it into a character..
        cmp dl,'9'  ; ...
        jbe .ok     ; ...
        add dl,7    ; ... (for 'A'..'F')
    .ok:            ; ...
        push ax    ; save EAX on the stack temporarily
        mov ah,2    ; INT 21H / AH=2: write character to std out
        int 0x21
        pop ax     ; restore EAX
        loop .print_digit
        
   POP DX                         ; pop a value from STACK into DX
   POP CX                         ; pop a value from STACK into CX
   POP BX                         ; pop a value from STACK into BX
   ret                     ; return control to the calling procedure
OUTDEC ENDP