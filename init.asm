include init.inc
.data
space byte " ", 0

.code




getScreenSize PROC row:word, col:word
	call GetMaxXY
	mov row, ax
	mov col, dx
	ret
getScreenSize endp

setFloor proc row:word, col:word
	mov eax, 0
	call setTextColor

	mov cl, 1
	;; use enter call to go from top of
	;; terminal to bottom of terminal
	tile:
		call Crlf

		inc cl
		cmp cl, byte ptr row
		jne tile


	mov eax, yellow * 16 ;changed to yellow bc sand
	call setTextColor
	mov dh, byte ptr row
	call Gotoxy
	mov cl, 0

	til2:
		mov edx, offset space
		call WriteString
		inc cl
		cmp cl, byte ptr col
		jne til2

		mov eax, 0

	ret

setFloor endp

createEnv proc row:word, col:word

	invoke getScreenSize, row, col
	invoke setFloor, row, col
	ret
createEnv endp


end