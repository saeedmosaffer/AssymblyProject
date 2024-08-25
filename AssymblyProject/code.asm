org 100h

.data
 first_string db 0ah,0dh, 'Please enter a number between 0 and 999:  $'  ; Prompt to enter a number
 number DB 4
        db ?
        db 3 dup(?)  ; Stores the user input (number of digits)
 error_message db 0ah,0dh, 'Invalid input! Please enter digits only.$' ; Error message for invalid input
 binarysoso db 0ah,0dh, 'THE VALUE IN BINARY FORMAT IS: $'  ; Binary output label
 HEXSTR DB 0ah,0dh, 'THE NUMBER IN HEXADECIMAL FORMAT IS : ','$' ; Hexadecimal output label
 ROMANSTR DB 0AH,0DH,'THE NUMBER IN ROMAN SYSTEM IS : $' ; Roman numeral output label
 digits db 0  ; Store digits of the number
 mytemp db 4 dup(' '), '$'  ; Temporary storage for hexadecimal result
 binarytemp db 16 dup('0'), '$'  ; Temporary storage for binary result
 ROMANVALUES DW 'CM', 900, 'D', 500, 'CD', 400, 'C', 100, 'XC', 90, 'L', 50, 'XL', 40, 'X', 10, 'IX', 9, 'V', 5, 'IV', 4, 'I', 1, 0 ; Roman numeral values and their corresponding numbers
 ROMANVALUE DW 20 DUP(?), '$'  ; Temporary storage for Roman numeral result

.code
mov ax,@data
mov ds,ax

main proc
 call Print_First_String  ; Prompt user for input
 call read_from_user  ; Read and convert user input to CX register
 mov bx, cx  ; Save CX for reuse
 call convert_to_hex  ; Convert the input to hexadecimal
 call printHexa  ; Print the hexadecimal result
 mov cx, bx  ; Restore CX for binary conversion
 call convertbinary  ; Convert the input to binary
 call CONVERTTOROMAN  ; Convert the input to Roman numeral
endp main
RET

; Prints the first string (prompt for user input)
Print_First_String proc
 mov dx,offset first_string
 mov ah,09h
 int 21h
 ret
Print_First_String endp

; Reads user input and converts it to numeric value in CX
read_from_user proc
 mov ah,0ah
 mov dx,offset number
 int 21h     
 mov si,dx
 cmp [si+1], 2
 je convertTwoVariable
 cmp [si+1], 3
 je convertThreeVariable   
 cmp [si+1], 1
 je convertOneVariable
 jmp fi
 
; Convert a single-digit number to its value in CX
convertOneVariable:
 XOR CX,CX
 mov cx,[si+2]
 SUB CX,30H  ; Convert ASCII to digit
 XOR CH,CH
 JMP FI

; Convert a two-digit number to its value in CX
convertTwoVariable:
 mov si,dx    
 xor bx,bx
 mov al,10  
 mov bl,[si+2]
 sub bl,30h
 mul bl  ; Multiply the first digit by 10
 mov cx,ax
 mov bl,[si+3]
 sub bl,30h
 add cx,bx  ; Add the second digit
 jmp fi

; Convert a three-digit number to its value in CX
convertThreeVariable:
 mov si,dx
 xor bx,bx
 mov bl,[si+2] 
 sub bl,30h
 mov al,10
 mul bl  ; Multiply the first digit by 100
 mov cx,ax
 mov al,10
 mov bl,[si+3] 
 sub bl,30h
 add cx,bx  ; Add the second digit
 mul cl
 mov cx,ax
 mov bl,[si+4]
 sub bl,30h
 add cx,bx  ; Add the third digit
fi:
 RET
read_from_user endp  

; Converts the value in CX to hexadecimal and stores it in 'mytemp'
convert_to_hex proc
 mov di, offset mytemp + 3  
 xor al,al                  

convert_loop:
 mov ax, cx  ; Copy CX to AX
 and ax, 0Fh  ; Isolate the lower 4 bits
 add al, 30h  ; Convert to ASCII
 cmp al, 39h                 
 jbe store_hex  ; If it's a digit, store it
 add al, 7  ; Otherwise, adjust for hex letters

store_hex:
 mov [di], al  ; Store the digit/letter
 dec di  ; Move pointer left
 shr cx, 4  ; Shift the input right by 4 bits (next hex digit)
 jnz convert_loop  ; Repeat until CX is 0

; Remove leading zeros from 'mytemp'
remove_leading_zeros: 
 cmp byte ptr [di], '0'  
 jne finish_conversion
 mov al, ' '
 mov [di], al
 inc di
 cmp di, offset mytemp + 3
 jle remove_leading_zeros

finish_conversion:
 ret
convert_to_hex endp

; Prints the hexadecimal result
printHexa proc
 mov dx, OFFSET HEXSTR   
 mov ah, 09h
 int 21h

 mov dx, offset mytemp   
 mov ah, 09h
 int 21h

 ret
printHexa endp

; Converts the value in CX to binary and stores it in 'binarytemp'
convertbinary proc
 xor si,si
 xor ax,ax   
 mov si,offset binarytemp 
 mov si,offset binarytemp + 15
 mov bx,cx    

doLoop:
 cmp cx ,0
 je outt

 shr cx,1  ; Shift right to get the next bit
 jc put1  ; If the bit is 1, store '1'
 jmp put0  ; Otherwise, store '0'

put1:
 mov al,'1'
 mov [si],al 
 dec si
 jmp doLoop

put0:  
 mov al,'0'
 mov [si],al 
 dec si
 jmp doLoop 

outt:
 mov dx, OFFSET binarysoso   
 mov ah, 09h
 int 21h

 mov dx, offset binarytemp   
 mov ah, 09h
 int 21h 
 ret
convertbinary endp  

; Converts the value in BX to Roman numeral and stores it in 'ROMANVALUE'
CONVERTTOROMAN PROC
 mov si,offset ROMANVALUES
 mov di, offset ROMANVALUE

LOOPTOFINDCURRVALUE:
 cmp bx,0
 je BY  ; Exit if BX is 0
 mov dl,[si+2]
 mov dh,[si+3]
 cmp bx,dx  ; Compare BX with the Roman value
 jl RETERN  ; Skip if BX is smaller
 sub bx,dx  ; Subtract the value
 mov cl,[si]
 mov ch,[si+1]
 mov [di],cx  ; Store the Roman numeral
 inc di
 inc di
 jmp LOOPTOFINDCURRVALUE  ; Repeat

RETERN:
 inc si
 inc si
 inc si 
 inc si
 jmp LOOPTOFINDCURRVALUE

BY: 
 mov dx,OFFSET ROMANSTR
 mov ah,9
 int 21h
           
 mov dx,OFFSET ROMANVALUE
 mov ah,9
 int 21h  
 ret
CONVERTTOROMAN ENDP

end main
