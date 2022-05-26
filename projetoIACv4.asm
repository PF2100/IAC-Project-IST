

;****KEYPAD****************************************************************************
LINE 		EQU 8		; Fourth keypad line
KEY_LIN 	EQU 0C000H	; Keyboard Rows
KEY_COL 	EQU 0E000H	; Keyboard Columns
KEY_MASK	EQU 0FH		; Isolates the lower nibble from the output of the keypad
BUTTON		EQU 0900H   ; Memory address that stores the pressed button
LAST_BUTTON EQU 0902H
;**************************************************************************************

;****KEYPAD COMMANDS*******************************************************************
START		EQU	0CH		; Start game
PAUSE		EQU	0DH		; Pause game
END			EQU	0EH		; End game
LEFT		EQU	00H		; Move ship left
RIGHT		EQU	02H		; Move ship right
SHOOT		EQU	01H		; Shoot missile
;**************************************************************************************

;***MEDIA CENTER COMMANDS**************************************************************
DEF_LINE    	  EQU 600AH      ; endereço do comando para definir a linha
DEF_COL   		  EQU 600CH      ; endereço do comando para definir a coluna
DEF_PIXEL    	  EQU 6012H      ; endereço do comando para escrever um pixel
DEL_WARNING       EQU 6040H      ; endereço do comando para apagar o aviso de nenhum cenário selecionado
DEL_SCREEN	 	  EQU 6002H      ; endereço do comando para apagar todos os pixels já desenhados
SELECT_BACKGROUND EQU 6042H      ; endereço do comando para selecionar uma imagem de fundo
;**************************************************************************************************************

;***DISPLAY*****************************************************************************************************
MIN_COLUNA		EQU  0		   ; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU  63        ; número da coluna mais à direita que o objeto pode ocupar
ATRASO			EQU	400H	   ; atraso para limitar a velocidade de movimento do boneco
PEN				EQU 1H
ERASER			EQU 0H
MOV_TIMER		EQU 0FFFH
;***SPACESHIP***************************************************************************************************
LINHA        	EQU 16        ; linha do boneco (a meio do ecrã))
COLUNA			EQU 30        ; coluna do boneco (a meio do ecrã)
LARGURA			EQU	5		   ; largura do boneco
ALTURA			EQU 2		   ; altura do boneco
COR_PIXEL		EQU	0FF00H	   ; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)
;****************************************************************************************************************




PLACE 1000H
STACK 100H              ;espaço reservado para a pilha 
						; (200H bytes, pois são 100H words)
STACK_INIT:

DEF_NAVE:		; tabela que define o boneco (cor, largura, pixels)
	WORD		ALTURA,LARGURA
	WORD		COR_PIXEL, 0, COR_PIXEL, 0, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL		; # # #   as cores 	podem ser diferentes

SHIP_PLACE:
	WORD	101EH

PEN_MODE:
	WORD	0H

ALT_COL:
	WORD 0H
	
ALT_LINHA:
	WORD 0H


PLACE 0H




Initializer:
	MOV SP, STACK_INIT
	MOV R0, 0 
	MOV  [DEL_WARNING], R0			; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [DEL_SCREEN], R0			; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
    MOV  [SELECT_BACKGROUND], R0	; seleciona o cenário de fundo
	MOV	R7, 1			    		; valor a somar à coluna do boneco, para o movimentar

Obtem_nave:
	MOV R8, SHIP_PLACE		;recebe o a linha e coluna em que a nave se encontra(0-7 bits para coluna , 8-15 bits para linha)
	MOV R9, DEF_NAVE 		;Recebe formato do boneco
	CALL Placement			;Calcula e guarda valores da linha e coluna em R1 E R2 respetivamente
	CALL apaga_boneco		;Apaga o boneco do display
	CALL desenha_boneco		;Desenha boneco
	


MAIN_CYCLE:
	CALL keypad;
	CALL COMMANDS;
	CALL METEOROS;
	CALL MOV_NAVE;
	JMP MAIN_CYCLE;

COMMANDS:
	RET;

METEOROS:
	RET
		;MOVIMENTOS EM RELACAO A NAVE



;********************************************************************************************************
;*MOVIMENTOS DA NAVE ( NAO MEXAM NESTAS FUNCOES DO MOV , da para meter mais simples)
;********************************************************************************************************

MOV_NAVE:
		PUSH R0
		PUSH R7
		PUSH R8 
		PUSH R9
		MOV R0, [BUTTON] ;NAO FUNCIONA AINDA VAI TER OS MOVIMENTOS TODOS SO DA NAVE
		CMP R0,	LEFT 
		JZ MOVE_LEFT;
		CMP R0, RIGHT;
		JZ MOVE_RIGHT;
		JMP NAVE_END

MOVE_RIGHT:
	MOV R7, 1
	MOV	[ALT_COL] , R7
	JMP MOVE

MOVE_LEFT:
	MOV R7, -1
	MOV [ALT_COL] , R7
	JMP MOVE
	
MOVE:
	CALL Placement
	;CALL TESTA_LIMITES
	MOV R7, [ALT_COL]
	CMP R7, 0
	JZ NAVE_END
	CALL apaga_boneco		;apaga o boneco
	ADD R2 , R7				;adiciona o incremento a coluna para indicar a nova coluna onde comeca
	ADD R8 , 1				;
	MOVB [R8], R2			;muda a coluna onde o objeto esta
	CALL desenha_boneco		;desenha a nova posicao do objeto
	CALL atraso				;
	

NAVE_END:
	POP R9
	POP R8
	POP R7
	POP R0
	RET
	








	
	


	

;**********************************************************************************************
;* APAGA BONECOS
;**********************************************************************************************

apaga_boneco:
	PUSH R6
	MOV R6 , ERASER
	MOV [PEN_MODE],R6 ;
	CALL escreve_boneco;
	POP R6
	RET


;**************************************************************************************
;*Desenha Bonecos
;**************************************************************************************	

desenha_boneco:
	PUSH R6
	MOV R6 , PEN
	MOV [PEN_MODE],R6 ;
	CALL escreve_boneco;
	POP R6
	RET

	
;******************************************************************************************
;* Obtem enderecos
;******************************************************************************************	

Placement:
	PUSH R8
	MOVB R1 , [R8]			;R1 guarda linha
	ADD R8 , 1				;Obtem endereço da coluna 
	MOVB R2, [R8]			;R2 stores the column
	POP R8
	RET
	
	
	
	
	
;*******************************************************************************************	
;*Escreve pixel LINHA
;*******************************************************************************************

escreve_boneco:
	PUSH  	R0
	PUSH 	R1
	PUSH 	R3
	PUSH	R9
	MOV	R0, [R9]			; obtém a ALTURA do boneco
	ADD	R9, 2				; adiciona 2 para obter o endereço da LARGURA do boneco
	MOV	R3, [R9]			; obtém a LARGURA
	ADD R9, 2				;para obter a primeira cor

escreve_linha:				;escreve linha de pixeis
	CALL escreve_coluna		;escreve a coluna de pixeis referente ao valor de R1
	ADD R1, 1				;Aumenta linha de escrita		
	SUB R0, 1				;Diminui altura
	JZ end_RWpixeis 		;acaba ciclo se altura = 0
	JMP escreve_linha		;repete escrita da linha até altura ser 0
	
end_RWpixeis:
	POP R9					;Devolve valor do OBJETO
	POP R3
	POP R1					;Devolve valor da Linha
	POP R0
	RET

;*********************************************************************************************
;*Escreve coluna
;*********************************************************************************************						
escreve_coluna:       		; desenha os pixels do boneco(colunas) a partir da tabela
	PUSH R3					;LOCKS THE LENGHT
	PUSH R2					;LOCKS THE COLUMN
	PUSH R5					;cor do pixel
	
escreve_pixeis_coluna:				;
	MOV	R5, [R9]					;cor para apagar o próximo pixel do boneco
	CALL escolhe_cor				;determina a cor do pixel
	CALL  escreve_pixel				;escreve cada pixel do boneco
	ADD R9, 2						;obter proxima cor
    ADD  R2, 1              		;próxima coluna
    SUB  R3, 1						;menos uma coluna para tratar
    JNZ  escreve_pixeis_coluna      ;continua até percorrer toda a largura do objeto
    POP R5							;
    POP R2							;
    POP R3
    RET

;***************************************************************************************************
;*escreve pixel AUXILIARES
;***************************************************************************************************
    
escolhe_cor:
	PUSH R6
	MOV R6 , [PEN_MODE]
	CMP R6,	ERASER 				;Checks if its in erasing mode
	JNZ end_cor					;Se nao for Erasing a cor do pixel is a do objeto
	MOV R5, ERASER				;ITS erasing so a cor de R5 is 0

end_cor:
	POP R6
	RET							;END routine
   
   
    
escreve_pixel:
	MOV  [DEF_LINE], R1		; seleciona a linha
	MOV  [DEF_COL], R2		; seleciona a coluna
	MOV  [DEF_PIXEL], R5	; altera a cor do pixel na linha e coluna já selecionadas
	RET
	
	
;*************************************************************************************
;*Testa Limites
;*************************************************************************************




;**************************************************************************************
; Keypad code: Searches for a pressed keypad button
;**************************************************************************************


keypad:
	PUSH R0				; Locks R0 value	
	PUSH R1				; Locks R1 value
	PUSH R2				; Locks R2 value
	PUSH R3				; Locks R3 value
	PUSH R4				; Locks R4 value
	MOV  R1, LINE       ; First line to test 
    MOV  R2, KEY_LIN	; Keypad input in R2
	MOV	 R3, KEY_COL	; Keypad output in R3

check_keypad:			; Checks if there is a pressed button
    MOVB [R2], R1      	; Injects Line in Keypad Lines
    MOVB R0, [R3]      	; Reads from Keypad Colums
    MOV  R4, KEY_MASK	; Loads Keypad Mask to
    AND  R0, R4   		; Isolates the Lower Nibble
    JZ 	 wait_button    ; Jumps if no button is pressed in that line
	CALL button_calc	; Calls the process that calculates the button pressed
	JMP keypad_end		; Jumps to the end

wait_button:	
	SHR R1, 1		   		; Changes which line is checked
	JNZ check_keypad		; Jumps if there is still a line to check
	MOV R1 , [BUTTON]		;
	MOV [LAST_BUTTON], R1	; 
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
	JMP calc_lin		; Repeats calc_lin keeps calculating the line

calc_col:				; Determines which column is being pressed (0-3)
	SHR R0, 1		   	; Shifts the pressed column 1 bit to the right
	JZ button_calc_end	; Jumps to end routine
	ADD R3, 1		   	; Adds 1 to the column counter
	JMP calc_col		; Repeats calc_col to keep calculating the column counter

button_calc_end:	
	CALL button_formula	; Calculates the button that is being pressed
	MOV R3 , [BUTTON]		;
	MOV [LAST_BUTTON], R3	; 
	MOV [BUTTON], R2		; Stores button pressed address in R0
	RET


;***********************************************************************************
;*CALCULA BOTAO EM R2 
;***********************************************************************************

button_formula:
	MOV R0, 4			;
	MUL R2, R0			; Multiples the line counter by 4 
	ADD R2, R3			; Adds the column counter to calculate the button pressed
	RET
	
;***************************************************************************************
;*CICLO DE ATRASO
;***************************************************************************************	

atraso:
	PUSH	R11
	MOV R11, MOV_TIMER
	
ciclo_atraso:
	SUB	R11, 1
	JNZ	ciclo_atraso
	POP	R11
	RET
