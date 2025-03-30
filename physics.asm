include physics.inc

.code
Gravity proc row: word, yPos: byte
cmp yPos, row
jg onGround
call Delay ;lets slow that animation down a bit
; make player fall:
call UpdatePlayer
inc yPos
call DrawPlayer
mov eax,80
call Delay
jmp gravity

ret

Gravity endp

end