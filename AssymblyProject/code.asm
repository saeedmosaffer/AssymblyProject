.model small
.stack 100h
.data
    prompt db 'Please enter a number between 0 and 999: $'
    bin_msg db 0DH, 0AH, 'The number in binary format is: $'
    hex_msg db 0DH, 0AH, 'The number in hexadecimal format is: $'
    rom_msg db 0DH, 0AH, 'The number in Roman format is: $'
    
    binary_result db 16 dup('$')
    hex_result db 4 dup('$')
    roman_result db 20 dup('$')

.code
main proc
    ; Initialize data segment
    mov ax, @data
    mov ds, ax

    ; Display prompt and get user input
    lea dx, prompt
    mov ah, 09h
    int 21h

    ; Read number from user
    xor bx, bx           ; Clear BX to store the final number
    mov ah, 01h
    int 21h
    sub al, '0'          ; Convert ASCII to number
    mov bl, al           ; Store it in BL

read_next_digit:
    mov ah, 01h
    int 21h
    cmp al, 13           ; Check for Enter key (ASCII 13)
    je convert           ; If Enter, jump to convert

    sub al, '0'
    mov ah, bl
    mov bl, 10
    mul bl
    add bl, al           ; Combine digits
    jmp read_next_digit

convert:
    ; Copy the final value in BX to AX for conversion
    mov ax, bx

    ; Convert to binary
    call convert_to_binary

    ; Convert to hexadecimal
    mov ax, bx
    call convert_to_hex

    ; Convert to Roman numeral
    mov ax, bx
    call convert_to_roman

    ; Display binary result
    lea dx, bin_msg
    mov ah, 09h
    int 21h
    lea dx, binary_result
    mov ah, 09h
    int 21h

    ; Display hexadecimal result
    lea dx, hex_msg
    mov ah, 09h
    int 21h
    lea dx, hex_result
    mov ah, 09h
    int 21h

    ; Display Roman numeral result
    lea dx, rom_msg
    mov ah, 09h
    int 21h
    lea dx, roman_result
    mov ah, 09h
    int 21h

    ; Exit the program
    mov ah, 4Ch
    int 21h

main endp

convert_to_binary proc
    ; Convert number in AX to binary string
    lea di, binary_result + 15   ; Point to the end of the result buffer
    mov cx, 16                   ; 16 bits to process
    mov bx, 1                    ; Start with the lowest bit

bin_loop:
    mov dx, ax
    and dx, bx                   ; Isolate the bit
    shr dx, cl                   ; Shift it to the least significant bit
    add dl, '0'                  ; Convert to ASCII '0' or '1'
    mov [di], dl
    dec di                       ; Move to the next position
    shr bx, 1                    ; Shift mask to the right
    loop bin_loop

    ret
convert_to_binary endp

convert_to_hex proc
    ; Convert number in AX to hexadecimal string
    lea di, hex_result + 3       ; Point to the end of the result buffer
    mov cx, 4                    ; 4 hexadecimal digits to process

hex_loop:
    mov dx, ax
    and dx, 0Fh                  ; Isolate the lowest 4 bits
    cmp dl, 09h
    jbe hex_digit
    add dl, 07h                  ; Adjust for A-F

hex_digit:
    add dl, '0'                  ; Convert to ASCII
    mov [di], dl
    shr ax, 4                    ; Shift AX to process the next digit
    dec di
    loop hex_loop

    ret
convert_to_hex endp

convert_to_roman proc
    ; Convert number in AX to Roman numeral string
    lea di, roman_result         ; Load destination offset for Roman numeral result
    mov cx, 100                  ; Start with the highest value (100 for 'C')
    call roman_digit             ; Convert hundreds

    mov cx, 50                   ; Now handle 'L' (50)
    call roman_digit

    mov cx, 10                   ; Handle tens ('X')
    call roman_digit

    mov cx, 5                    ; Handle fives ('V')
    call roman_digit

    mov cx, 1                    ; Finally, handle units ('I')
    call roman_digit

    ret                          ; Return from the subroutine
convert_to_roman endp

roman_digit proc
    ; Convert digit to Roman numeral
    mov dx, ax                   ; Copy AX to DX for division
    div cx                       ; Divide AX by CX (CX holds the Roman numeral value)
    mov ax, dx                   ; Restore the remainder to AX (for the next iteration)

    cmp al, 4                    ; Special case: Check for 4
    je four_case
    cmp al, 9                    ; Special case: Check for 9
    je nine_case
    cmp al, 5                    ; Check if 5 or more (to handle 'V', 'L', etc.)
    jae five_case

one_case:
    ; Handle cases for 1, 2, 3
    cmp al, 0                    ; If 0, skip
    je end_digit
    mov byte ptr [di], 'I'       ; Add 'I' to the result
    inc di                       ; Move to the next position in the result
    dec al                       ; Decrease the counter
    jmp one_case                 ; Repeat for remaining count

four_case:
    ; Handle case for 4 (like 'IV')
    mov byte ptr [di], 'I'
    mov byte ptr [di+1], 'V'
    add di, 2
    ret

five_case:
    ; Handle cases for 5 or more
    mov byte ptr [di], 'V'
    add di, 1
    sub al, 5
    jmp one_case

nine_case:
    ; Handle case for 9 (like 'IX')
    mov byte ptr [di], 'I'
    mov byte ptr [di+1], 'X'
    add di, 2
    ret

end_digit:
    ret
roman_digit endp

end main
