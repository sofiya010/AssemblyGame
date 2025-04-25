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
UpdateCactus PROC cactiMem:dword, yPosCacti:byte, numCacti:byte

    ;; check if there are any cacti to update
    mov cl, numCacti
    cmp cl, 0
    je done
    mov esi, cactiMem
    
    ;; if there are
    update:
       ;; move cursor to x,y
       mov bl, byte ptr [esi]
       mCursor bl, yPosCacti   

       ;; erase
       mov al," "
       call WriteChar

       ;; decrease xPos by 1
       dec bl
   
       ;; move to new place and draw
       mCursor bl, yPosCacti
       invoke DrawCactus, bl, yPosCacti
        
       ;; check if end of array
       dec cl
       cmp cl, 0
       jle done
       inc esi
       jmp update
   

   done:
       ret

UpdateCactus ENDP

end