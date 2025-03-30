include draw.inc

.code

UpdatePlayer PROC xPos:byte, yPos:byte, dir:byte
    mov dl,xPos
    mov dh,yPos
    call Gotoxy
    mov al," "
    call WriteChar
    cmp dir, 0
    jl down

    up:
        dec yPos
        invoke DrawPlayer, xPos, yPos

    down:
        inc yPos
        invoke DrawPlayer, xPos, yPos


    ret
UpdatePlayer ENDP




DrawPlayer PROC xPos:byte, yPos:byte

; draw player at (xPos,yPos):
mov dl,xPos
mov dh,yPos
call Gotoxy
mov al,"X"
call WriteChar
ret

DrawPlayer ENDP



DrawCactus PROC row:word, xPos:byte, yPos:word

    ; Get the row height of the screen
    mov ax, row         ; Load row (height) of the screen into ax
    dec ax              ; Decrement by 1 to place the cactus above the floor (second-to-last row)
    dec ax
    mov yPos, ax   ; Store the new value into yPosCacti (which is a WORD)

    ; Set cactus color to green text, black background
    mov eax, green + (black * 16)  ; Set text color to green with black background
    call SetTextColor

    ; Draw the cactus at xPosCacti, yPosCacti
    mov dl, xPos  ; Load x position of cactus
    mov dh, byte ptr yPos  ; Load y position (as byte) from yPosCacti (since dh is 8-bit)
    call Gotoxy
    mov al, "@"         ; Load ASCII value for cactus character (@)
    call WriteChar

    ret
DrawCactus ENDP

end