include Irvine32.inc
include physics.inc
include draw.inc

.code

mResetColor macro
	
	mov eax,white (black * 16)
	call SetTextColor

endm


Gravity proc row: word, xPos:byte, yPos: byte
	
	;; if we are on ground then exit recursion
	mov dl, byte ptr row
	sub dl, 2
	
	; make player fall:
	invoke UpdatePlayer, xPos, yPos, -1
	inc yPos

	mov al, yPos
	ret

Gravity endp


;; Jump procedure 
Jump proc xPos: byte, yPos: byte, row: word, cactiMem:dword, yPosCacti:byte, numCacti:byte
	;; changes position of player up by one
	invoke UpdatePlayer, xPos, yPos, 1
	mov yPos, al ;; update y position

	;; delay runtime
	mov eax, 20
	call Delay

	;inc xPosCacti
	invoke UpdateCactus, cactiMem, yPosCacti, numCacti
	
	mResetColor
	;; changes position of player up by one 
	invoke UpdatePlayer, xPos, yPos, 1
	mov yPos, al

	;; delay runtime
	mov eax, 20
	call Delay
	
	;; invoke Gravity
	mov al, yPos
	
	ret  ;; return
Jump endp

end