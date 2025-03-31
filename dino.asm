;; Include main inc file
include Irvine32.inc
include physics.inc
include init.inc
include draw.inc


.data

;; size of the command window
row word 0
col word 0

;; position of bottom of player
xPos BYTE 0
yPos BYTE 0

;; score variabes
strScore BYTE "Your score is: ",0
score DWORD 0
lastTime DWORD 0       ; Stores the last recorded time

;; position of a cactus
xPosCacti byte 40
yPosCacti byte 0
dir BYTE 0

; Cactus X positions array
cactiXPos BYTE 10, 30, 50, 70, 90  ; Add more positions as needed
numCacti BYTE 5   ; The number of cacti

; block obstacles to jump over
xBlockPos BYTE ?
yBlockPos BYTE ?

inputChar BYTE ?

.code
;; funny marcos

mResetColor macro
	
	mov eax,white (black * 16)
	call SetTextColor

endm

checkTime PROC
    ; Get the current time in milliseconds
    call GetMseconds
    mov ebx, eax       ; Store current time in EBX

    ; Check if 3 seconds (3000 ms) have passed
    mov ecx, lastTime  
    add ecx, 3000       ; lastTime + 3000 (3 seconds)
    cmp ebx, ecx        ; Compare current time with lastTime + 3s
    jl noUpdate         ; If less than, skip update

    ; Update score
    add score, 5        ; Add 5 points

    ; Save new lastTime
    mov lastTime, ebx   ; Store new time

noUpdate:
    ret
checkTime ENDP

; start main
main PROC

	;; initializes the game and creates the environment
	;; will add starts to createEnv later
	mResetColor
	invoke createEnv
	;; store row and col values
	mov row, ax
	mov col, bx

	;; set up our dino location
	mov bl,  byte ptr row
	mov yPos, bl
	mov yPosCacti, bl
	sub yPosCacti, 2
	sub yPos, 2
	mov xPos, 10

	;; draw 'dino'
	mResetColor
	invoke DrawPlayer, byte ptr xPos, byte ptr yPos

	;; draw cactus
	
	;mResetColor
	invoke DrawCactus, xPosCacti, yPosCacti



	;; start game loop
	gameLoop:
		mov eax, 100
		call Delay
		;mResetColor
		invoke UpdateCactus, xPosCacti, yPosCacti
		mov xPosCacti, al
		cmp xPosCacti, 0
		jle resetCacti

		;; while we are on the ground
		onGround:

			; get user key input:
 			call ReadKey
			mov inputChar,al

			; exit game if user types 'x':
			cmp inputChar,"x"
			je exitGame
		
			;; check if jump
			cmp inputChar,"w"
			je ascend

			cmp inputChar," "
			je ascend

			jmp gameLoop

		ascend:
			mResetColor
			invoke Jump, xPos, yPos, row
			jmp gameLoop

		resetCacti:
			mov bl, byte ptr col
			mov xPosCacti, bl
			jmp gameLoop


	exitGame:
		mResetColor
		;mov eax, 5
		exit
main ENDP




END main