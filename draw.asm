include Irvine32.inc

include draw.inc
.code

mCursor macro xPos, yPos
    mov dl,xPos
    mov dh,yPos
    call Gotoxy
endm

;; Updates the location of player on the screen
UpdatePlayer PROC xPos:byte, yPos:byte, dir:byte
    
    mCursor xPos, yPos
    mov al," "
    call WriteChar
    dec yPos
    mCursor xPos, yPos
    inc yPos
    call WriteChar
    cmp dir, 0
    jl down

    up:
        dec yPos
        invoke DrawPlayer, xPos, yPos
        jmp done
    down:
        inc yPos
        invoke DrawPlayer, xPos, yPos
    
    done:
        mov al, yPos
        ret
UpdatePlayer ENDP

;; when we implement 'duck' we can to -O as the body or something like that
DrawPlayer PROC xPos:byte, yPos:byte

    ; draw player at (xPos,yPos):
    mCursor xPos, yPos
    mov al,"|"  ;; body
    call WriteChar
    dec dh
    call Gotoxy
    mov al, "O"  ;; head
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

;; will implement for contest 2

;;DrawStars PROC
; Generate random white stars in the sky above the floor
;;mov ecx, 50 ; Number of stars to display
;;starLoop:
;;call RandomRange
;;mov dl, al ; Random X position (across the whole screen)

;;call RandomRange
;;and al, 10 ; Keep stars in the top 10 rows (not in the floor area)
;;mov dh, al

;;mov eax, white + (black * 16) ; White foreground, black background
;;call setTextColor
;;call Gotoxy
;;mov al, 42 ; ASCII for '*'
;;call WriteChar

;;loop starLoop
;;ret
;;DrawStars ENDP


end