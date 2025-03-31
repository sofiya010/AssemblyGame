include Irvine32.inc
include physics.inc
include draw.inc

.code
Gravity proc row: word, xPos:byte, yPos: byte
	
	falling:
		;; if we are on ground then exit recursion
		mov dl, byte ptr row
		sub dl, 2
		cmp yPos, dl
		je onGround
	
		call Delay ;lets slow that animation down a bit
	
		; make player fall:
		invoke UpdatePlayer, xPos, yPos, -1
		inc yPos

		mov eax,80
		call Delay
		jmp falling
		

	onGround:
		ret

Gravity endp


;; Jump procedure 
Jump proc xPos: byte, yPos: byte, row: word
	;; changes position of player up by one
	invoke UpdatePlayer, xPos, yPos, 1
	mov yPos, al ;; update y position

	;; delay runtime
	mov eax, 80
	call Delay
	
	;; changes position of player up by one 
	invoke UpdatePlayer, xPos, yPos, 1
	mov yPos, al

	;; delay runtime
	mov eax, 160
	call Delay
	
	;; invoke Gravity
	invoke Gravity, row, xPos, yPos
	ret  ;; return
Jump endp

end