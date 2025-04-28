include Irvine32.inc
include init.inc
include draw.inc
.data
moonLine1 BYTE '  ,-,',0
moonLine2 BYTE ' /.(',0
moonLine3 BYTE ' \ {',0
moonLine4 BYTE '  `-`',0


Xstars byte 10, 20, 30, 43, 50, 80, 40, 35, 70, 65, 90, 115, 115, 100 
Ystars byte 5, 8, 6, 9, 4, 5, 7, 9, 8, 4, 8, 2, 7, 6
curX byte 0
curY byte 0

.code
;; macro to one line the movement of cursor on terminal
mCursor macro xPos, yPos
    mov dl,byte ptr xPos
    mov dh,byte ptr yPos
    call Gotoxy
endm

mResetColor macro
	
	mov eax,white (black * 16)
	call SetTextColor

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

DrawStars PROC
    ; Set text color to bright white on black
    mov eax, white + (black * 16)
    call SetTextColor

    ; draw a moon

    ; Line 1
    mCursor 0, 2
    mov edx, offset moonLine1
    call WriteString

    ; Line 2
    mCursor 0, 3
    mov edx, offset moonLine2
    call WriteString

    ; Line 3
    mCursor 0, 4
    mov edx, offset moonLine3
    call WriteString

    ; Line 4
    mCursor 0, 5
    mov edx, offset moonLine4
    call WriteString

    mov ecx, 0
    
    ff:
        ;; get x val
        mov esi, offset Xstars
        add esi, ecx
        mov edx, [esi]
        mov curX, dl
        ;; get y val
        mov esi, offset Ystars
        add esi, ecx
        mov edx, [esi]
        mov curY, dl
        
        ;; move there and write
        mCursor curX, curY
        mov al, "*"
        call WriteChar

        ;; for all stars in list
        inc cl
        cmp cl, 14
        jne ff

        ret

DrawStars ENDP



;; macro for animation
mNext macro xPos, yPos
    mov eax, 250
    call Delay

    ;; erase cur spine
    mResetColor
    mCursor xPos, yPos
    mov al," "
    call WriteChar
    ;; move to next spine pos
    dec yPos
    dec xPos
    mCursor xPos, yPos
    
endm

TakeSpine proc, xPos:byte, yPos:byte

    mov eax, red + (black * 16)  ; Set text color to red with black background
    call SetTextColor
    mCursor xPos, yPos
    mov al, "@" ;; bloody cactus
    call WriteChar

    dec xPos
    dec yPos

    fly: ;; i know its bad code, but it works
        mov cl, xPos
        cmp cl, 0
        jle daEnd

        ;; draw new spine flying away and rotating
        mNext xPos, yPos
        mov al, '/'
        call WriteChar

        mov cl, xPos
        cmp cl, 0
        jle daEnd

        mNext xPos, yPos
        mov al, '_'
        call WriteChar

        mov cl, xPos
        cmp cl, 0
        jle daEnd


        mNext xPos, yPos
        mov al, '\'
        call WriteChar

        mov cl, xPos
        cmp cl, 0
        jle daEnd


        mNext xPos, yPos
        mov al, '|'
        call WriteChar
        jmp fly

    daEnd:
        ret


TakeSpine endp


Grave proc row:word, col:word
    ;; redraw floor
    invoke setFloor, row, col

    mov eax, black + (gray* 16)  ; Set text color to green with black background
    call SetTextColor
    ;; in the middle of screen
    mov ax, col
    mov bl, 2
    div bl
    
    ;; height of stone
    mov byte ptr col, al
    mov cl, 5
    
    ;; print gray
    gg: 
        dec row
        mCursor col, row
        mov al, ' '
        call WriteChar
        dec cl
        cmp cl, 0
        je cross
        jmp gg

    ;; print the cross part
    cross:
        dec col
        inc row

        mCursor col, row
        mov al, ' '
        call WriteChar

        inc col
        inc col

        mCursor col, row
        mov al, ' '
        call WriteChar

        ret
Grave endp

end
