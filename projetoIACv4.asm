; TO-DO:

; TIAGO: Mexer com displays, pensar meteoro for later
; PEDRO: limites do ecrã, mudar delay para contador
; JOHNY: traduzir títulos e comentários do write/erase pixels, relatório

; GOALS:

; DONE: O teclado deve estar completamente funcional, detetando todas as teclas;

; DONE: Deve desenhar o rover e movimentá-lo para a esquerda e para a direita (de forma contínua, enquanto se carrega na tecla), até atingir o limite do ecrã;

; - Deve desenhar um meteoro (bom ou mau), no tamanho máximo, numa coluna qualquer, no topo do ecrã. Esse meteoro deve descer uma linha no ecrã sempre que se 
; carrega numa tecla (escolha qual), mas apenas uma linha por cada clique na tecla

; DONE: Deve ter um cenário de fundo 

; - Deve ter um efeito sonoro, de cada vez que se carrega na tecla para o meteoro descer

; - Use outras duas teclas para aumentar e diminuir o valor nos displays. Para já pode ser em hexadecimal, mas na versão final terá de fazer 
; uma rotina para converter um número qualquer para dígitos em decimal.


;****KEYPAD****************************************************************************

INJECTED_LINE 	EQU 8			; Fourth keypad line
KEY_LIN 	EQU 0C000H		; Keyboard Rows
KEY_COL 	EQU 0E000H		; Keyboard Columns
KEY_MASK	EQU 0FH			; Isolates the lower nibble from the output of the keypad
BUTTON		EQU 0900H   		; Stores the pressed button
LAST_BUTTON 	EQU 0902H		; Stores the last pressed button (prior to the current)


;****KEYPAD COMMANDS*******************************************************************

START		EQU	0CH		; Start game
PAUSE		EQU	0DH		; Pause game
END		EQU	0EH		; End game
LEFT		EQU	00H		; Move ship left
RIGHT		EQU	02H		; Move ship right
DOWN		EQU 	05H		; Move meteor down
SHOOT		EQU	01H		; Shoot missile


;***MEDIA CENTER COMMANDS**************************************************************

DEF_LINE    		EQU 600AH	; Define line command adress 
DEF_COL  		EQU 600CH	; Define column command adress
DEF_PIXEL    		EQU 6012H	; Write pixel command adress
DEL_WARNING     	EQU 6040H	; Ignore no background warning command adress
DEL_SCREEN		EQU 6002H	; Delete all pixels drawn command adress
SELECT_BACKGROUND 	EQU 6042H	; Select background command adress


;***DISPLAY*******************************************************************************************

MIN_COLUMN		EQU 0		; Leftmost column that the object can fill
MAX_COLUMN		EQU 63        	; Rightmost column that the object can fill
DELAY			EQU 400H	; Delay used to speed down the movement of the ship
PEN			EQU 1H		; Flag used to write pixels
ERASER			EQU 0H		; Flag used to erase pixels
MOV_TIMER		EQU 0FFFH


;***SPACESHIP*************************************************************************************************************

LINE        		EQU 16        	; Ship initial line (middle of screen)
COLUMN			EQU 30        	; Ship initial column (middle of screen)
WIDTH			EQU 5
HEIGHT			EQU 4
COR_PIXEL		EQU 0FF00H	; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)
WHITE			EQU 0FFFDH	; Hexadecimal ARGB value of the colour WHITE
RED			EQU 0FE00H	; Hexadecimal ARGB value of the colour RED
DARKRED			EQU 0FE33H	; Hexadecimal ARGB value of the colour DARK RED
BLUE			EQU 0F48FH	; Hexadecimal ARGB value of the colour BLUE


;***METEORS*************************************************************************************************************

METEOR_LINE		EQU 3		; Meteor initial line
METEOR_COLUMN		EQU 16		; Meteor initial column
METEOR_HEIGHT		EQU 6
METEOR_WIDTH		EQU 6
METEOR_COLOUR		EQU 0 		; Hexadecimal value of the colour #


;*************************************************************************************************************************

PLACE 1000H
STACK 100H

STACK_INIT:

DEF_SHIP:				; Ship layout (colour of each pixel, height, width)
	WORD HEIGHT, WIDTH
	WORD 0, 0, BLUE, 0, 0, 0, RED, WHITE, RED, 0, DARKRED, WHITE, WHITE, WHITE, DARKRED, WHITE, 0, WHITE, 0, WHITE
	
DEF_METEOR:
	WORD METEOR_HEIGHT, METEOR_WIDTH
	WORD 0, 0, RED, RED, 0, 0, 0, RED, RED, RED, RED, 0, RED, RED, RED, RED, RED, RED, RED, RED, RED, RED, RED, RED,
		0, RED, RED, RED, RED, 0, 0, 0, RED, RED, 0, 0
	
SHIP_PLACE:				; Reference to the position of ship 
	WORD 101EH			; First byte of the word stores the line and the second one the column

METEOR_PLACE:
	WORD 0310H			; First byte of the word stores the line and the second one the column
	
PEN_MODE:				; Flag used to either draw or erase pixels by draw_object and erase_object
	WORD 0H

CHANGE_COL:				; Stores column variation of the position of the object
	WORD 0H
	
CHANGE_LINE:				; Stores line variation of the position of the object
	WORD 0H


PLACE 0H


INITIALIZER:
	MOV SP, STACK_INIT		
	MOV R0, 0 
	MOV [DEL_WARNING], R0		; Deletes no background warning (R0 value is irrelevant)
	MOV [DEL_SCREEN], R0		; Deletes all drawn pixels (R0 value is irrelevant)
    	MOV [SELECT_BACKGROUND], R0	; Selects background


BUILD_SHIP:
	MOV R8, SHIP_PLACE		; Stores line in the first byte of R8 and column on the second one
	MOV R9, DEF_SHIP 		; Stores ship layout
	CALL placement			; Calculates and stores the ship position reference, R1 stores line and R2 stores column
	CALL erase_object		; Deletes ship from display
	CALL draw_object		; Draws ship
	
BUILD_METEOR:
	MOV R8, METEOR_PLACE		; Stores line in the first byte of R8 and column on the second one
	MOV R9, DEF_METEOR		; Stores meteor layout
	CALL placement			; Calculates and stores the meteor position reference, R1 stores line and R2 stores column
	CALL erase_object		; Deletes meteor from display
	CALL draw_object		; Draws meteor

MAIN_CYCLE:
	CALL keypad
	CALL commands
	CALL mov_met
	CALL mov_ship
	JMP MAIN_CYCLE

commands:
	RET

meteors:
	RET

;********************************************************************************************************
;*SHIP MOVEMENTS
;********************************************************************************************************

mov_ship:
	PUSH R0
	PUSH R7
	PUSH R8 
	PUSH R9
	MOV R8, SHIP_PLACE
	MOV R9, DEF_SHIP
	MOV R0, [BUTTON] 		; Moves button value to R0
	CMP R0,	LEFT 			; Compares if the pressed button is equal to the Left Button
	JZ MOVE_LEFT			
	CMP R0, RIGHT			; Compares if the pressed button is equal to the Right Button
	JZ MOVE_RIGHT
	JMP SHIP_END

MOVE_RIGHT:
	MOV R7, 1			
	MOV [CHANGE_COL], R7		; Changes the column variation value to 1
	JMP MOVE

MOVE_LEFT:
	MOV R7, -1			; Changes the column variation value to -1
	MOV [CHANGE_COL], R7
	JMP MOVE
	
MOVE:
	CALL placement
	CALL test_ship_limits
	MOV R7, [CHANGE_COL]
	CMP R7, 0
	JZ SHIP_END
	CALL erase_object		; Deletes object from current position
	ADD R2, R7			; Adds column variation to the new reference position of ship
	ADD R8, 1			; Adds 1 to SHIP_PLACE to obtain the column address
	MOVB [R8], R2			; Changes column position of the ship
	CALL draw_object		; Draws object in new position
	CALL delay			;
	

SHIP_END:
	POP R9
	POP R8
	POP R7
	POP R0
	RET

;********************************************************************************************************
;*METEOR MOVEMENTS
;********************************************************************************************************
mov_met:
	PUSH R0
	PUSH R7
	PUSH R8 
	PUSH R9
	MOV R0, [BUTTON] 		; Moves button value to R0
	CMP R0, DOWN
	JNZ MET_END
	MOV R8, [LAST_BUTTON]
	CMP R0,	R8
	JZ MET_END
	MOV R8, METEOR_PLACE		
	MOV R9, DEF_METEOR


	
MOVE_MET:
	CALL placement
	CALL erase_object		; Deletes object from current position
	ADD R1, 1			; Adds line variation to the new reference position of meteor
	MOVB [R8], R1			; Changes line position of the meteor
	CALL draw_object		; Draws object in new position
	

MET_END:
	POP R9
	POP R8
	POP R7
	POP R0
	RET
	
;***********************************************************************************************************************
;* TESTS DISPLAY LIMITS
;***********************************************************************************************************************

test_ship_limits:
	PUSH R1
	PUSH R2
	PUSH R3
	MOV R1, CHANGE_COL
	MOV R3, [R1]
	CMP R3, 0
	JGT test_right
	
test_left:
	MOV R3, MIN_COLUMN
	CMP R3, R2
	JNZ test_end
	MOV R3, 0
	MOV [R1], R3

test_right:
	MOV R3, MAX_COLUMN
	ADD R2, 4			; width is 4 , so the last pixel is 4 pixels away
	CMP R3, R2
	JNZ test_end
	MOV R3, 0
	MOV [R1], R3

test_end:
	POP R3
	POP R2
	POP R1
	RET
	

;***********************************************************************************************************************
;* ERASE OBJECTS
;***********************************************************************************************************************

erase_object:
	PUSH R6
	MOV R6, ERASER
	MOV [PEN_MODE], R6
	CALL write_object
	POP R6
	RET


;**************************************************************************************
;*DRAW OBJECTS
;**************************************************************************************	

draw_object:
	PUSH R6
	MOV R6, PEN
	MOV [PEN_MODE], R6 
	CALL write_object
	POP R6
	RET

	
;******************************************************************************************
;* SHIP POSITION REFERENCE
;******************************************************************************************	

placement:
	PUSH R8
	MOVB R1, [R8]			; R1 stores line
	ADD R8, 1			; Gets column adress (second byte of R8)
	MOVB R2, [R8]			; R2 stores column
	POP R8
	RET
	
	
;*******************************************************************************************	
;*Escreve pixel LINHA
;*******************************************************************************************

write_object:
	PUSH R0
	PUSH R1
	PUSH R3
	PUSH R9
	MOV R0, [R9]			; obtém a ALTURA do boneco
	ADD R9, 2			; adiciona 2 para obter o endereço da LARGURA do boneco
	MOV R3, [R9]			; obtém a LARGURA
	ADD R9, 2			; para obter a primeira cor

write_line:				; escreve linha de pixeis
	CALL write_column		; escreve a coluna de pixeis referente ao valor de R1
	ADD R1, 1			; Aumenta linha de escrita		
	SUB R0, 1			; Diminui altura
	JZ end_RWpixeis 		; acaba ciclo se altura = 0
	JMP write_line			; repete escrita da linha até altura ser 0
	
end_RWpixeis:
	POP R9				; Devolve valor do OBJETO
	POP R3
	POP R1				; Devolve valor da Linha
	POP R0
	RET


;*********************************************************************************************
;*Escreve coluna
;*********************************************************************************************	

write_column:       			; desenha os pixels do boneco(colunas) a partir da tabela
	PUSH R3				; LOCKS THE LENGHT
	PUSH R2				; LOCKS THE COLUMN
	PUSH R5				; cor do pixel
	
write_pixels_column:				
	MOV R5, [R9]			; cor para apagar o próximo pixel do boneco
	CALL pick_colour		; determina a cor do pixel
	CALL write_pixel		; escreve cada pixel do boneco
	ADD R9, 2			; obter proxima cor
    	ADD R2, 1          	    	; próxima coluna
    	SUB R3, 1			; menos uma coluna para tratar
   	JNZ write_pixels_column      	; continua até percorrer toda a largura do objeto
  	POP R5							
   	POP R2							
   	POP R3
   	RET


;***************************************************************************************************
;*escreve pixel AUXILIARES
;***************************************************************************************************
    
pick_colour:
	PUSH R6
	MOV R6, [PEN_MODE]
	CMP R6,	ERASER 			; Checks if its in erasing mode
	JNZ end_colour			; Se nao for Erasing a cor do pixel is a do objeto
	MOV R5, ERASER			; ITS erasing so a cor de R5 is 0

end_colour:
	POP R6
	RET				; END routine
   
    
write_pixel:
	MOV [DEF_LINE], R1		; seleciona a linha
	MOV [DEF_COL], R2		; seleciona a coluna
	MOV [DEF_PIXEL], R5		; altera a cor do pixel na linha e coluna já selecionadas
	RET
	

;**************************************************************************************
; Keypad code: Searches for a pressed keypad button
;**************************************************************************************

keypad:
	PUSH R0	
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	MOV R1, INJECTED_LINE    	; First line to test 
 	MOV R2, KEY_LIN			; Keypad input in R2
	MOV R3, KEY_COL			; Keypad output in R3

check_keypad:				; Checks if there is a pressed button
   	MOVB [R2], R1      		; Injects line in keypad lines
   	MOVB R0, [R3]      		; Reads from keypad columns
   	MOV R4, KEY_MASK		; Loads keypad mask to R4
  	AND R0, R4   			; Isolates the lower nibble
  	JZ wait_button    		; Jumps if no button is pressed in that line
   	CALL button_calc		; Calls the process that calculates the button pressed
  	JMP keypad_end			; Jumps to the end

wait_button:	
	SHR R1, 1		   	; Changes which line is checked
	JNZ check_keypad		; Jumps if there is still a line to check
	MOV R1, [BUTTON]
	MOV [LAST_BUTTON], R1	
	MOV R2, 0FFFFH 			; Moves value -1 (estado normal do botao) to R2
	MOV [BUTTON], R2		; Changes BUTTON value to FH

keypad_end:
	POP R4				; Restores value to R4
	POP R3				; Restores value to R3
	POP R2				; Restores value to R2
	POP R1				; Restores value to R1	
	POP R0				; Restores value to R0
	RET

;***********************************************************************************************************
;*Determines which button was pressed
;************************************************************************************************************

button_calc:
	MOV R2, 0		   	; Initializes Lines Counter
	MOV R3, 0		   	; Initializes Columns Counter

calc_lin:				; Determines which line is being pressed (0-3)
	SHR R1, 1		   	; Shifts the pressed line 1 bit to the right
	JZ calc_col		   	; Jumps to calculate which column is being pressed
	ADD R2, 1		   	; Adds 1 to the line counter
	JMP calc_lin			; Repeats calc_lin keeps calculating the line

calc_col:				; Determines which column is being pressed (0-3)
	SHR R0, 1		   	; Shifts the pressed column 1 bit to the right
	JZ button_calc_end		; Jumps to end routine
	ADD R3, 1		   	; Adds 1 to the column counter
	JMP calc_col			; Repeats calc_col to keep calculating the column counter

button_calc_end:	
	CALL button_formula		; Calculates the button that is being pressed
	MOV R3, [BUTTON]
	MOV [LAST_BUTTON], R3
	MOV [BUTTON], R2		; Stores button pressed address in R0
	RET


;***********************************************************************************
;*PRESSED BUTTON CALCULATOR (R2)
;***********************************************************************************

button_formula:
	MOV R0, 4
	MUL R2, R0			; Multiples the line counter by 4 
	ADD R2, R3			; Adds the column counter to calculate the button pressed
	RET
	
;***************************************************************************************
;*DELAY CYCLE
;***************************************************************************************	

delay:
	PUSH R11
	MOV R11, MOV_TIMER
	
delay_cicle:
	SUB R11, 1
	JNZ delay_cicle
	POP R11
	RET
