include Irvine32.inc
include init.inc
.data
space byte " ", 0
row_hold word ?
col_hold word ?

.code

getScreenSize PROC
	call GetMaxXY
	mov row_hold, ax
	mov col_hold, dx
	ret
getScreenSize endp


setFloor proc row:word, col:word
	;; set background to black
	mov eax, 0
	call setTextColor

	;; to print
	mov edx, offset space

	;; init counters
	mov cl, 1
	mov bl, 1

	;; use enter call to go from top of
	;; terminal to bottom of terminal
	tile:
		call Crlf ;; new line
		inc cl ;; cl+1
		cmp cl, byte ptr row
		jne tile

	sand:
		mov eax, yellow * 16 ;change to yellow bc sand
		call setTextColor
		;mov dh, byte ptr row
		;call Gotoxy
		jmp last
	
	last:
		mov edx, offset space
		call WriteString
		inc bl
		cmp bl, byte ptr col
		jne last

	ret

setFloor endp




createEnv proc

	invoke getScreenSize
	invoke setFloor, row_hold, col_hold
	mov ax, row_hold
	mov bx, col_hold
	ret
createEnv endp


end