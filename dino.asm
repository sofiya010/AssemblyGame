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
score BYTE 0

;; position of a cactus
xPosCacti BYTE 40
yPosCacti word 0

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
	sub yPos, 2
	mov xPos, 10

	;; draw 'dino'
	mResetColor
	invoke DrawPlayer, byte ptr xPos, byte ptr yPos

	;; start game loop
	gameLoop:

		mResetColor

		;; while we are on the ground
		onGround:

			; get user key input:
 			call ReadChar
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
			invoke Jump, xPos, yPos, row
			jmp gameLoop

	exitGame:
		exit
main ENDP




END main