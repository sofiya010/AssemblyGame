include Irvine32.inc

include draw.inc
.code
;; macro to one line the movement of cursor on terminal
mCursor macro xPos, yPos
    mov dl,xPos
    mov dh,yPos
    call Gotoxy
endm

;; Updates the location of player on the screen
UpdatePlayer PROC xPos:byte, yPos:byte, dir:byte
    ;; move cursor to player current position
    mCursor xPos, yPos

    ;; delete the character
    mov al," "
    call WriteChar
    dec yPos
    mCursor xPos, yPos
    inc yPos
    call WriteChar

    ;; check if player is going up or down
    cmp dir, 0
    jl down
    
    ;; if jumping then move player up one
    up:
        dec yPos
        invoke DrawPlayer, xPos, yPos
        jmp done
    ;;  if falling then move player down one
    down:
        inc yPos
        invoke DrawPlayer, xPos, yPos
    ;; end procedure
    done:
        mov al, yPos ;; return new position of player in al
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



DrawCactus PROC xPosCacti:byte, yPosCacti:byte

    ; Get the row height of the screen
    ;mov al, byte ptr row         ; Load row (height) of the screen into ax
    ;dec al              ; Decrement by 1 to place the cactus above the floor (second-to-last row)
    ;dec al
    ;mov yPosCacti, al  ; Store the new value into yPosCacti (BYTE Value)

    ; Set cactus color to green text, black background
    mov eax, green + (black * 16)  ; Set text color to green with black background
    call SetTextColor

    ; Draw the cactus at xPosCacti, yPosCacti
    mCursor xPosCacti, yPosCacti

    mov al, "@"         ; Load ASCII value for cactus character (@)
    call WriteChar

    ret
DrawCactus ENDP 


;; basically moves the cactus visually to the left- then we can code interactions
UpdateCactus PROC xPosCacti:byte, yPosCacti:byte

   ;;mov al, xPosCacti  ; Zero-extend BYTE to WORD
   mCursor xPosCacti, yPosCacti   ; Now both parameters are WORD- still not working though

   mov al," "
   call WriteChar

   dec xPosCacti ;prolly need to dec xPosCacti via dec ax, but rn just trying to get it to compile
   cmp xPosCacti, 0
   jle done
   
   mCursor xPosCacti, yPosCacti
   invoke DrawCactus, xPosCacti, yPosCacti
   
   done:
       mov al, xPosCacti
       ret

UpdateCactus ENDP



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