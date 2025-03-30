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

Jump proc xPos: byte, yPos: byte, row: word
	invoke UpdatePlayer, xPos, yPos, 1
	mov yPos, al
	mov eax, 80
	call Delay
	invoke UpdatePlayer, xPos, yPos, 1
	mov yPos, al
	mov eax, 160
	call Delay
	invoke Gravity, row, xPos, yPos
	ret
Jump endp

end