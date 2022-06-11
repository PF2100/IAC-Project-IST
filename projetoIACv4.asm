
;********************************************************************************************************
;* SPACE INVADERS
; IAC PROJECT - INTERMEDIATE VERSION
;
; GROUP 13: João Trocado (103333), Pedro Freitas (103168), Tiago Firmino (103590)
;********************************************************************************************************


; PEDRO - check_missile_limits ( falta colisões missil->meteoro) , mov_meteor (falta selecionar o tipo de tamanho e colisões 
;	 meteoro->rover ) , MENUS DE PAUSA , game over quando  existirem colisoes ou display value a






;****KEYPAD****************************************************************************

INJECTED_LINE 	EQU 8			; Initial keypad line (fourth)
KEY_LIN 	EQU 0C000H		; Keyboard Rows
KEY_COL 	EQU 0E000H		; Keyboard Columns
KEY_MASK	EQU 0FH			; Isolates the lower nibble from the output of the keypad
BUTTON		EQU 0900H   		; Stores the pressed button
LAST_BUTTON 	EQU 0902H		; Stores previous pressed button (prior to the current)
NO_BUTTON	EQU 0FFFFH		; Value of no pressed button

;****DISPLAY****************************************************************************

DISPLAY			EQU 0A000H		; Display adress
UPPER_BOUND		EQU 0064H		; Display upper bound (energy)
LOWER_BOUND		EQU 0000H		; Display lower bound (energy)
DISPLAY_TIMER 		EQU 0100H		; Display delay between pressing button and changing energy value
HEXTODEC_CONST		EQU 000AH		; Display hexadecimal to decimal constant
DISPLAY_DECREASE	EQU -5			; Display decrease value 

;****KEYPAD COMMANDS*******************************************************************

START		EQU	0CH		; Start game
PAUSE		EQU	0DH		; Pause game
END		EQU	0EH		; End game
LEFT		EQU	00H		; Move ship left
RIGHT		EQU	02H		; Move ship right
MET_DOWN	EQU 	05H		; Move meteor down
DIS_DOWN	EQU	07H		; Move display value down
DIS_UP		EQU	03H		; Move display value up
SHOOT		EQU	01H		; Shoot missile


;***MEDIA CENTER COMMANDS**************************************************************

DEF_LINE    		EQU 600AH	; Define line command adress 
DEF_COL  		EQU 600CH	; Define column command adress
DEF_PIXEL    		EQU 6012H	; Write pixel command adress
DEL_WARNING     	EQU 6040H	; Ignore no background warning command adress
DEL_SCREEN		EQU 6002H	; Delete all pixels drawn command adress
SELECT_BACKGROUND 	EQU 6042H	; Select background command adress
SELECT_SCREEN		EQU 6004H	; Select pixel screen
PLAY_SOUND_VIDEO	EQU 605AH	;


;***SCREEN*******************************************************************************************

MIN_COLUMN		EQU 0		; Leftmost column that the object can fill
MAX_COLUMN		EQU 63       	; Rightmost column that the object can fill
DELAY			EQU 400H	; Delay used to speed down the movement of the ship
PEN			EQU 1H		; Flag used to write pixels
ERASER			EQU 0H		; Flag used to erase pixels
MOV_TIMER		EQU 010H	; Movement delay definition


;***SPACESHIP*************************************************************************************************************

LINE        		EQU 27        	; Ship initial line (bottom of the screen)
COLUMN			EQU 30        	; Ship initial column (middle of the screen)
WIDTH			EQU 5
HEIGHT			EQU 4
WHITE			EQU 0FFFDH	; Hexadecimal ARGB value of the colour WHITE
RED			EQU 0FE00H	; Hexadecimal ARGB value of the colour RED
DARKRED			EQU 0FE33H	; Hexadecimal ARGB value of the colour DARKRED
BLUE			EQU 0F48FH	; Hexadecimal ARGB value of the colour BLUE
;***MISSILE****************************************************************************************************************

MISSILE_WIDTH		EQU 1
MISSILE_HEIGHT		EQU 1
MISSILE_LINE		EQU 0
MISSILE_COLUMN		EQU 0
MISSILE_LINE_MAX	EQU 15


;***METEORS*************************************************************************************************************

METEOR_LINE		EQU 3		; Meteor initial line
METEOR_COLUMN		EQU 16		; Meteor initial column
METEOR_HEIGHT		EQU 6
METEOR_WIDTH		EQU 6
METEOR_COLOUR		EQU 0 		; Hexadecimal value of the colour #
MET_TIMER		EQU 0800H
MAX_STEPS		EQU 13		; 
MAX_METEOR_LINE		EQU 1FH

;*************************************************************************************************************************


PLACE 1000H
STACK 100H

STACK_INIT:

DEF_SHIP:				; Ship layout (colour of each pixel, height, width)
	WORD HEIGHT, WIDTH
	WORD 0, 0, BLUE, 0, 0, 0, RED, WHITE, RED, 0, DARKRED, WHITE, WHITE, WHITE, DARKRED, WHITE, 0, WHITE, 0, WHITE
	
;**********METEOR DIMENSIONS**********************************************************************************************

DEF_METEOR_FAR:
	WORD 1, 1
	WORD RED

DEF_METEOR_CLOSER:
	WORD 2, 2
	WORD RED, RED, RED, RED

DEF_METEOR_SMALL:
	WORD 3, 3
	WORD RED, RED, RED, RED, RED, RED, RED, RED, RED

DEF_METEOR_MEDIUM:
	WORD 4, 4
	WORD RED, RED, RED, RED, RED, RED, RED, RED, RED, RED, RED, RED, RED, RED, RED, RED
	
DEF_METEOR_MAX:
	WORD METEOR_HEIGHT, METEOR_WIDTH
	WORD 0, 0, RED, RED, 0, 0, 0, RED, RED, RED, RED, 0, RED, RED, RED, RED, RED, RED, RED, RED, RED, RED, RED, RED,
		0, RED, RED, RED, RED, 0, 0, 0, RED, RED, 0, 0
		
;*************************************************************************************************************************

DEF_MISSILE:
	WORD MISSILE_HEIGHT, MISSILE_WIDTH
	WORD RED


;*************************************************************************************************************************

interruption_table:
	WORD meteor_interruption	; meteor interruption routine
	WORD missile_interruption	; missile interruption routine
	WORD energy_interruption	; energy interruption routine	
		
;**************************************************************************************************************************



	
		
	
SHIP_PLACE:					; Reference to the position of ship 
	BYTE LINE, COLUMN			; First byte of the word stores the line and the second one the column
	
MISSILE_PLACE:					; Reference to the position of the missile 
	WORD MISSILE_LINE, MISSILE_COLUMN	; First byte of the word stores the line and the second one the column

MISSILE_STEPS:
	WORD 0H

METEOR_PLACE:
	BYTE METEOR_LINE, METEOR_COLUMN		; First byte of the word stores the line and the second one the column
	
CHANGE_COL:					; Stores column variation of the position of the object
	WORD 0H
	
CHANGE_LINE:					; Stores line variation of the position of the object
	WORD 0H
	

PEN_MODE:					; Flag used to either draw or erase pixels by draw_object and erase_object
	WORD 0H
	
DELAY_COUNTER:					; Counter until MOV_TIMER is reached and ship moves
	WORD 0H

DISPLAY_VALUE:
	WORD UPPER_BOUND			; Energy display initial value

DISPLAY_VARIATION:				; Energy display variation value
	WORD 0H
	
DELAY_FLAG:					; Ship movement delay flag
	WORD 0H

METEOR_INTERRUPTION_FLAG:			; Flag to determine the movement of the meteor 
	WORD 0H

MISSILE_INTERRUPTION_FLAG:			; Flag to determine the movement of the missile
	WORD 0H
	
ENERGY_INTERRUPTION_FLAG:			; Flag to determine the movement of the energy
	WORD 0H

MET_SPAWN_TIMER:				; Value to determine the creation of a meteor 
	WORD 0800H

METEOR_NUMBER:					; Number of meteors in the screen
	WORD 0H
	
BAD_METEOR_SHAPES:				; Table of  all BAD type meteor layouts
	WORD DEF_METEOR_FAR, DEF_METEOR_CLOSER 
	WORD DEF_METEOR_SMALL, DEF_METEOR_MEDIUM
	WORD DEF_METEOR_MAX
	
GOOD_METEOR_SHAPES:				; Table of  all GOOD type meteor layouts
	WORD DEF_METEOR_FAR, DEF_METEOR_CLOSER 
	WORD DEF_METEOR_SMALL, DEF_METEOR_MEDIUM
	WORD DEF_METEOR_MAX			

METEOR_TABLE:					; Table of all the meteor positions , type and steps it took
	BYTE 0H, 0H 
	WORD GOOD_METEOR_SHAPES, 1H
	
	BYTE 0H, 0H 
	WORD GOOD_METEOR_SHAPES, 1H
	
	BYTE 0H, 0H 
	WORD GOOD_METEOR_SHAPES, 1H
	
	BYTE 0H, 0H 
	WORD GOOD_METEOR_SHAPES, 1H

;*************************************************************************************************************************

PLACE 0H


INITIALIZER:
	MOV BTE, interruption_table	; Iniciates BTE in interruption table
	MOV SP, STACK_INIT		; Iniciates SP for the stack
	MOV R0, 0
	EI0				; Allows meteor_interruption 
	EI1				; Allows missile_interruption 
	EI2				; Allows energy_interruption 
	EI				; Allows all interruptions

	
	MOV [DEL_WARNING], R0		; Deletes no background warning (R0 value is irrelevant)
	MOV [DEL_SCREEN], R0		; Deletes all drawn pixels (R0 value is irrelevant)
    	MOV [SELECT_BACKGROUND], R0	; Selects background
    	MOV R0, 0100H			; Stores energy display initial value in R0
	MOV [DISPLAY], R0		; Initializes display
	MOV R0, UPPER_BOUND
	MOV [DISPLAY_VALUE], R0


BUILD_SHIP:
	MOV R8, SHIP_PLACE		; Stores line in the first byte of R8 and column on the second one
	MOV R9, DEF_SHIP 		; Stores ship layout
	CALL placement			; Stores the ship position reference, R1 stores line and R2 stores column
	CALL erase_object		; Deletes ship from screen
	CALL draw_object		; Draws ship
	

MAIN_CYCLE:
	CALL keypad			; Checks if there is a pressed button
	CALL display_decrease		; Checks if the pressed button changes the display
	CALL mov_missile		; Checks if missile is to be shot , moved , or destroyed
	CALL create_met			; Checks if the pressed button changes the meteor position
	CALL move_meteors
	CALL mov_ship			; Checks if the pressed button changes the ship position
	JMP MAIN_CYCLE
		

;********************************************************************************************************
;* mov_ship
;
; Moves ship position (accordingly to its delay) if the button pressed is either LEFT or RIGHT
;********************************************************************************************************

mov_ship:
	PUSH R0	
	PUSH R7
	PUSH R8 
	PUSH R9
	PUSH R10
	MOV R8, SHIP_PLACE		; Stores current ship position
	MOV R9, DEF_SHIP		; Stores ship layout
	MOV R0, [BUTTON] 		; Stores button value in R0
	MOV R7, -1
	CMP R0,	LEFT 			; Compares if the pressed button is LEFT Button
	JZ CHECK_DELAY	
	MOV R7, 1
	CMP R0, RIGHT			; Compares if the pressed button is RIGHT Button
	JZ CHECK_DELAY
	JMP SHIP_END			; Jumps to the end of the routine if button is neither LEFT or RIGHT


CHECK_DELAY:
	MOV R10, MOV_TIMER
	CALL delay			
	MOV R10, [DELAY_FLAG]
	CMP R10, 1
	JNZ SHIP_END			; Jumps to the end of the routine if DELAY_COUNTER is neither 0 nor MOV_TIMER
	
MOVE:
	MOV [CHANGE_COL], R7		; Stores column variation value of ship position
	CALL placement			; Stores ship line in R1 and its column in R2
	CALL test_ship_limits		; Checks if ship has reached left or right screen limits
	MOV R7, [CHANGE_COL]		; Stores new column variation value after checking screen limits
	CMP R7, 0
	JZ SHIP_END			; Ends routine if column variation is 0
	CALL erase_object		; Deletes object from current position
	ADD R2, R7			; Adds column variation to the new reference position of ship
	ADD R8, 1			; Adds 1 to SHIP_PLACE to obtain the column address
	MOVB [R8], R2			; Changes column position of the ship
	CALL draw_object		; Draws object in new position
	

SHIP_END:				; Restores stack values in the registers
	POP R10
	POP R9
	POP R8
	POP R7
	POP R0
	RET
	
	

;********************************************************************************************************
;*mov_missile
;
; Shoots a missile ( if the pressed Button is SHOOT ) and moves the missile upwards if the value 
;of MISSILE_INTERRUPTION_FLAG is 1
;********************************************************************************************************

mov_missile:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R8
	PUSH R9
	MOV R9, DEF_MISSILE			; Stores missile layout in R9
	MOV R8, MISSILE_PLACE			; Stores missile reference position address in R8
	CALL shoot_missile			; Shoots a missile if the pressed button is SHOOT and there is no missile in the air
	CAll placement				; Stores missile reference position( line in R1, column in R2)
	CMP R1 , 0				; Checks if ther is a missile in the air ( line will never be 0 )
	JZ MOV_MISSILE_END			; Jumps to end of routine if there is no missile in the air

ALLOW_MISSILE_MOV:
	MOV R0 , [MISSILE_INTERRUPTION_FLAG]	
	CMP R0, 1				; Checks if the interruption value is 1
	JNZ MOV_MISSILE_END			; If the interruption value isnt 1 , then it jumps to the end of routine

MOVE_DRAW_MISSILE:
	MOV R0 , -1				
	MOV [CHANGE_LINE], R0			; Changes the Line variation value to -1
	CALL mov_object_vertically		; Moves the missile vertically 1 line up
	MOV R0 , 0			
	MOV [MISSILE_INTERRUPTION_FLAG], R0	; Resets the interruption value to 0
	CALL check_missile_limits		; Checks if the missile is in its limit position
	


MOV_MISSILE_END:				; Ends routine
	POP R9
	POP R8
	POP R2
	POP R1
	POP R0
	RET
	
;********************************************************************************************************
;*shoot_missile
;
; Shoots a missile if there isnt one flying already
;********************************************************************************************************

shoot_missile:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R8
	PUSH R9
	MOV R0 , [BUTTON]		; Stores pressed button 
	MOV R1 , SHOOT			
	CMP R0, R1			; Checks if the pressed button is SHOOT
	JNZ SHOOT_MISSILE_END		; Jumps to end of routine if the last instruction is false
	
GET_MISSILE_POSITION:
	MOV R0, [MISSILE_PLACE]		; Stores missile placement
	CMP R0, 0			; Verifies if line and collumn are 0 ( there is no missile flying)
	JNZ SHOOT_MISSILE_END		; If no missile is in the air , end routine
	
DRAW_MISSILE:
	MOV R8, SHIP_PLACE		; Stores Ship position
	CALL placement			; Stores ship reference position (Line in R1 and Column in R2)
	ADD R1, -1			; Adds-1 to obtain line above the ship
	ADD R2, 2			; Adds 2 to obtain middle reference collumn of the ship
	MOV R9 , DEF_MISSILE		; Stores missile layout
	Call draw_object		; Draws object
	MOV [PLAY_SOUND_VIDEO], R0	; Play shooting sound
	SHL R1 ,8			; Shifts R1 to the higher byte
	OR R1 , R2			; Uses OR function to store line and collumn together in R1
	MOV [MISSILE_PLACE] , R1	; Stores in memory the missile reference position
		
SHOOT_MISSILE_END:			; Ends Routine
	POP R9
	POP R8
	POP R2
	POP R1
	POP R0
	RET
	
;********************************************************************************************************
;*check_missile_limits
;
; Checks if missile has reached either the MISSILE_LINE_MAX value or if there is a collision
; INPUT: R8 - Missile reference position 
;********************************************************************************************************		
	
check_missile_limits:
	PUSH R0
	PUSH R1
	PUSH R2
	CALL placement			; Stores missile reference position (Line in R1 and Column in R2)

MISSILE_TOP_LIMIT:
	MOV R0, MISSILE_LINE_MAX	 
	CMP R1 , R0			; Checks if missile line has reached its maximum value
	JNZ CHECK_MISSILE_LIMITS_END	; Jumps to the end of the routine if the last intsuction is false
	CALL erase_object		; Erases the missile from the screen
	MOV R0, 0			
	MOV [R8], R0			; Chages missile line and column to 0
	


CHECK_MISSILE_LIMITS_END:		; Ends routine
	POP R2
	POP R1
	POP R0
	RET

	
	
	
;********************************************************************************************************
;*mov_object_vertically
;
; Moves a object vertically based on CHANGE_LINE value
; INPUT: R8 - Object Reference position 
;	 R9 - Object Layout
;********************************************************************************************************		

mov_object_vertically:
	PUSH R1
	PUSH R7
	PUSH R8
	MOV R7 , [CHANGE_LINE]		; Stores Line variation value in R7
	CALL placement			; Stores object reference position (Line in R1 and Column in R2)
	CALL erase_object		; Deletes object from current position
	ADD R1, R7			; Adds line variation to the new reference position of meteor
	MOVB [R8], R1			; Changes line position of the meteor
	CALL draw_object		; Draws object in new position
	
mov_object_vertically_end:		; Ends Routine
	POP R8
	POP R7
	POP R1
	RET



;********************************************************************************************************
;*mov_met
;
; Moves the meteor position if the pressed button is MET_DOWN
;********************************************************************************************************


create_met:
	PUSH R0
	PUSH R2
	PUSH R3 
	
CHECK_MET_TIMER:
	MOV R3 , [MET_SPAWN_TIMER]	; Stores spawn_timer value in R3
	MOV R2, MET_TIMER
	CMP R3, R2			; Checks if spawn_timer has reached its maximum value
	JLT CREATE_MET_END		; Jumps to end of routine if last instruction is false

	MOV R3 , 0			; Stores value of MET_SPAWN_TIMER
	MOV R0, [METEOR_NUMBER]		
	CMP R0, 4			; Checks if the maximum number of meteors was achieved
	JZ CREATE_MET_END
	CALL store_build_meteor		; Stores and creates a meteor
	MOV R2, 0			; 
	MOV [SELECT_SCREEN], R2		; Selects screen with the ship
	ADD R0, 1			; Adds 1 to the number of meteors
	MOV [METEOR_NUMBER], R0 	; Changes METEOR_NUMBER to its new added value
	 
	
	
CREATE_MET_END:				; Ends routine
	ADD R3, 1
	MOV [MET_SPAWN_TIMER], R3	; Changes MET_SPAWN_TIMER to its new added value
	POP R3
	POP R2
	POP R0
	RET
	
;********************************************************************************************************
;*store_build_meteor
;
;
;********************************************************************************************************


store_build_meteor:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R9
	PUSH R8
	MOV R8 , METEOR_TABLE
	MOV R1 , 1
	MOV [SELECT_SCREEN], R1

FIND_SPACE:
	CALL placement			; Stores meteor reference position (Line in R1 and Column in R2) 
	CMP R2 , 0			; Checks if there is no meteor in this position ( meteor will never be in collumn 0)
	JZ BUILD_METEOR			; If there is a free space it will build a meteor there
	CALL select_meteor		; Selects next meteor from the meteor_table and next pixel screen 
	JMP FIND_SPACE			; Repeats cycle until it finds a free meteor space
	
BUILD_METEOR:
	MOV R1, METEOR_LINE		; Stores in R1 initial meteor position line
	MOV R2, METEOR_COLUMN		; Stores in R2 initial meteor position column
	MOV R3, R1			;
	SHL R3 , 8			;
	OR R3 , R2			;
	MOV [R8], R3			; Storesin memory the meteor reference position
	ADD R8 , 2 			; Advances one word in the meteor_table to obtain meteor_layout 
	MOV R9, GOOD_METEOR_SHAPES	; Stores in R9 the meteor_layout
	MOV [R8], R9			; Stores in memory the meteor__evolution address
	MOV R9 , [R9]			; Obtains the meteor layout
	CALL draw_object		; Draws meteor
	
STORE_BUILD_METEOR_END:
	POP R9
	POP R8
	POP R3
	POP R2
	POP R1
	RET	

	

;********************************************************************************************************
;*move_meteors
;
; Moves all the meteors from teh METEOR_TABLE if METEOR_INTERRUPTION_FALG value is 1
;********************************************************************************************************

move_meteors:
	PUSH R1
	PUSH R3
	PUSH R6
	PUSH R7
	PUSH R8 
	PUSH R9
	MOV R3, 0
	MOV R8, METEOR_TABLE
	MOV R6, [METEOR_NUMBER]
	
ALLOW_METEOR_MOVEMENT:
	MOV R1 , [METEOR_INTERRUPTION_FLAG]
	CMP R1, 1				; Checks if there is METEOR_INTERRUPTION_FLAG value is 1
	JNZ MOVE_MET_END			; Ends routine if last instruction is false
	MOV [METEOR_INTERRUPTION_FLAG], R3	; Resets METEOR_INTERRUPTION_FLAG to 0
	CMP R6, 0				; Checks if the number of meteors is 0
	JZ MOVE_MET_END				; Ends routine if last instruction is True
	MOV R1, 1				
	MOV [SELECT_SCREEN], R1			; Selects first meteor screen
	

GET_METEOR:
	CALL placement				; Stores meteor reference position (Line in R1 and Column in R2) 
	CMP R2 , 0				; Checks if there is no meteor in this position ( meteor will never be in collumn 0)
	JZ GET_NEXT_METEOR			; Jumps if there is no meteor in this position
	CALL move_meteor			; Moves Meteor in this position			
	SUB R6 , 1				; Subtracts 1 from the number of meteors
	JZ MOVE_MET_END				; Ends routine if there are no more meteors to take care of
	
GET_NEXT_METEOR:
	CALL select_meteor			; Selects next meteor from the METEOR_TABLE
	JMP GET_METEOR				; Repeats GET_METEOR cycle until all meteors are checked
	
MOVE_MET_END:
	MOV [SELECT_SCREEN], R3		; Selects original screen 
	POP R9
	POP R8
	POP R7
	POP R6
	POP R3
	POP R1
	RET
	
;********************************************************************************************************
;*move_meteor
;
; Moves a meteor , and checks it collisions , limits and changes its layout	
; INPUT: R8 - METEOR_TABLE
;********************************************************************************************************	

move_meteor:
	PUSH R0
	PUSH R1
	PUSH R7
	PUSH R8
	PUSH R9
	MOV R7 , 1
	MOV [CHANGE_LINE], R7		; Changes line variation value to 1

CHECK_LAYOUT:
	CALL select_layout		;
	MOV R7, [R8+2H]
	MOV R9, [R7]
	CALL mov_object_vertically	; Moves the meteor 1 line down
	CALL check_meteor_limits	; 

move_meteor_end:
	POP R9
	POP R9
	POP R7
	POP R1
	POP R0
	RET


;********************************************************************************************************
;* check_meteor_limits
;
;********************************************************************************************************

check_meteor_limits:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R8
	CALL placement
	MOV R3, MAX_METEOR_LINE
	CMP R1, R3
	JNZ CHECK_METEOR_LIMITS_END
	Call eliminate_meteor

CHECK_METEOR_LIMITS_END:
	POP R8
	POP R3
	POP R2
	POP R1
	POP R0
	RET
	
;********************************************************************************************************
;*eliminate_meteor
;
;********************************************************************************************************
	
eliminate_meteor:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R8
	
	MOV R0, 0
	CALL erase_object
	MOV [R8], R0
	ADD R8 , 2H
	MOV [R8], R0
	ADD R8, 2H
	MOV R0, 1
	MOV [R8], R0
	MOV R2 , [METEOR_NUMBER]
	SUB R2, 1
	MOV [METEOR_NUMBER], R2
	
	POP R8
	POP R2
	POP R1
	POP R0
	RET
		
	
	
;********************************************************************************************************
;* check_layout
;
;********************************************************************************************************

select_layout:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R6
	PUSH R8
	MOV R6 ,R8
	ADD R8 , 4H
	ADD R6 , 2H
	
CHECK_STEPS:
	MOV R0, [R8]
	MOV R1, MAX_STEPS
	CMP R0, R1
	JGE SELECT_LAYOUT_END
	
	MOV R2, R0
	MOV R1, 3
	MOD R2, R1
	JNZ ADD_STEPS
	
	MOV R1 , 2H
	MOV R9 , [R6]
	ADD R9 , R1
	MOV [R6], R9
	
ADD_STEPS:
	ADD R0, 1
	MOV [R8], R0
	
	
SELECT_LAYOUT_END:
	POP R8
	POP R6
	POP R2
	POP R1
	POP R0
	RET



;********************************************************************************************************
;* select_meteor
; Selects new meteor from the METEOR_TABLE anges the selected screen to which the meteor should be at
;
; INPUT: R8 - meteor address in METEOR_TABLE
;********************************************************************************************************

select_meteor:
	PUSH R0
	MOV R0, 6
	ADD  R8	, R0			; Adds 6 to R8 ( METEOR_TABLE) , to obtain next meteor
	MOV R0, [SELECT_SCREEN]		; Stores number of selected screen in R0
	ADD R0, 1		
	MOV [SELECT_SCREEN], R0		; Selects next screen
	POP R0	
	RET






;***********************************************************************************************************************
;* display_decrease:
;
; Decreases the value that the display shows by DISPLAY_DECREASE (5) 
;***********************************************************************************************************************

display_decrease:
	PUSH R1	
	MOV R1 , [ENERGY_INTERRUPTION_FLAG]	
	CMP R1, 1				; Checks if ENERGY_INTERRUPTION_VALUE is 1
	JNZ DISPLAY_DECREASE_END		; Jumps to end of routine if last instruction is true
	MOV R1, DISPLAY_DECREASE		
	MOV [DISPLAY_VARIATION], R1		; Changes DISPLAY_VARIATION value to DISPLAY_DECREASE
	CALL mov_display			; Changes the value that the display shows
	MOV R1, 0		
	MOV [ENERGY_INTERRUPTION_FLAG], R1 	; Resets the ENERGY_INTERRUPTION_FLAG value to 0

DISPLAY_DECREASE_END:				; End of routine
	POP R1
	RET
	

;***********************************************************************************************************************
;* moves_display:
;
; Uses DISPLAY_VARIATION value to change the value that display shows
;***********************************************************************************************************************

mov_display:
	PUSH R0	
	PUSH R1
	PUSH R2
	PUSH R7
	MOV R7, [DISPLAY_VARIATION]	; R7 stores the energy variation
	
CHANGE_DISPLAY:
	CALL test_display_limits	; Checks if the energy has reached display limits (100 upper, 0 lower)
	MOV [DISPLAY_VALUE], R1		; Stores in memory value of display(R1)
	CALL convert_hex_to_dec		; Converts hexadecimal value of display do decimal
	MOV [DISPLAY], R1		; Sets display to correspondant decimal value
	
DISPLAY_END:
	POP R7
	POP R2
	POP R1
	POP R0
	RET
	

;***********************************************************************************************************************************
;* test_display_limits:
;
; Changes the display value to either 100 or 0 , if the addition of R7 to the display value surpasses the display limits
; INPUT:	R1 - Value that the display currently shows
;	 	R7 - Display variation
; OUTPUT:	R1 - New display value
;***********************************************************************************************************************************	

test_display_limits:	
	PUSH R0				;
	CMP R7, DISPLAY_DECREASE	; 
	JZ LOWER_LIMIT			; Jumps to LOWER_LIMIT check if Display variation value is DISPLAY_DECREASE
	
UPPER_LIMIT:
	MOV R0, UPPER_BOUND
	MOV R1, [DISPLAY_VALUE]
	ADD R1, R7			; Adds display variation (5) to R1 (DISPLAY_VALUE)
	CMP R1, R0
	JLT TEST_DISPLAY_LIMITS_END	; Jumps if DISPLAY_VALUE is lower then upper limit (limit hasn't been reached)
	MOV R1, R0			; Sets DISPLAY_VALUE to UPPER_BOUND (limit reached)
	JMP TEST_DISPLAY_LIMITS_END	; Ends routine

LOWER_LIMIT:
	MOV R0, LOWER_BOUND		;
	MOV R1, [DISPLAY_VALUE]		;
	ADD R1, R7			; Adds display variation (-5) to R1 (DISPLAY_VALUE)
	CMP R1, R0			; 
	JGT TEST_DISPLAY_LIMITS_END	; Jumps if DISPLAY_VALUE is greater then lower limit (limit hasn't been reached)
	MOV R1, R0			; Sets DISPLAY_VALUE to LOWER_BOUND (limit reached)
	
TEST_DISPLAY_LIMITS_END:
	POP R0
	RET
	
;***********************************************************************************************************************
;* convert_hex_to_dec:
;
; Converts hexadecimal value to decimal value
; INPUT: R1 - Hexadecimal value of DISPLAY
; OUTPUT: R1 - Decimal value of Display
;***********************************************************************************************************************

convert_hex_to_dec: 				; converto numeros hexadecimais (até 63H) para decimal
	PUSH R2					; converte o numero em R1, e deixa-o em R1
	PUSH R3
	MOV  R3, HEXTODEC_CONST
	MOV  R2, R1				; Saves the display value in R2
	DIV  R1, R3 				; Stores the tens digit of the display value in R1
	MOD  R2, R3 				; Stores the units digit of the display value in R2
	SHL  R1, 4				; Moves the tens value of the display value to the second hexadecimal digit
	ADD  R1, R2				; Adds the units digit to R1
	POP  R3
	POP  R2
	RET
	
;***********************************************************************************************************************
;* test_ship_limits:
;
; Changes value of the column variation (CHANGE_COL) to 0 if the ship placement is at either column limits
;***********************************************************************************************************************

test_ship_limits:
	PUSH R1
	PUSH R2
	PUSH R3
	MOV R1, CHANGE_COL		; Stores CHANGE_COL adress
	MOV R3, [R1]			; Stores column variation of object in R3
	CMP R3, 0
	JGT TEST_RIGHT			; Jumps if CHANGE_COL is positive (move right)
	
TEST_LEFT:
	MOV R3, MIN_COLUMN		; Stores the minimium screen column 
	CMP R3, R2			; Checks if obejct has reached MIN_COLUMN
	JNZ TEST_END			; Ends routine if it hasn't
	MOV R3, 0			
	MOV [R1], R3			; Changes CHANGE_COL to 0 (ship won't move left)

TEST_RIGHT:
	MOV R3, MAX_COLUMN		; Stores the maximum screen column 
	ADD R2, 4			; Width is 4, so the last pixel is 4 pixels away from position reference
	CMP R3, R2			; Checks if obejct has reached MAX_COLUMN
	JNZ TEST_END			; Ends routine if it hasn't
	MOV R3, 0
	MOV [R1], R3			; Changes CHANGE_COL to 0 (ship won't move right)

TEST_END:				; Restores stack values in the registers
	POP R3
	POP R2
	POP R1
	RET
	

;*****************************************************************************************
;* erase_object:
;
; Erases object written by write_object, by changing PEN_MODE to 0
;*****************************************************************************************

erase_object:
	PUSH R6
	MOV R6, ERASER			; Loads ERASER flag to R6
	MOV [PEN_MODE], R6		; Sets PEN_MODE to ERASER
	CALL write_object		; Writes object in eraser mode (deletes it)
	POP R6
	RET


;****************************************************************************************
;* draw_object:
;
; Draws object written by write_object, by changing PEN_MODE to 1
;****************************************************************************************

draw_object:
	PUSH R6
	MOV R6, PEN			; Loads PEN flag to R6
	MOV [PEN_MODE], R6 		; Sets PEN_MODE to PEN
	CALL write_object		; Writes object in pen mode (draws it)
	POP R6
	RET

	
;******************************************************************************************
;* placement:
;
; Obtains object reference position
;
; INPUT: 	R8 - Object reference screen position
; OUTPUT:	R1 - Object reference position line
;		R2 - Object reference position column
;******************************************************************************************	

placement:
	PUSH R8
	MOVB R1, [R8]			; R1 stores line
	ADD R8, 1			; Gets column adress (second byte of R8)
	MOVB R2, [R8]			; R2 stores column
	POP R8
	RET
	
	
;*******************************************************************************************	
;* write_object:
;
; Writes an object on the screen (either to draw or erase it)
;
; INPUT:	R1 - Object reference line
;		R2 - Object reference column
;		R9 - Object definition (heigth, width, layout)
;*******************************************************************************************

write_object:
	PUSH R0
	PUSH R1
	PUSH R3
	PUSH R9				; Stores object layout table (R9) in stack
	MOV R0, [R9]			; Stores object height
	ADD R9, 2			; Adds 2 to get object width
	MOV R3, [R9]			; Stores object width
	ADD R9, 2			; Gets first pixel colour to use

WRITE_LINES:				; Writes a line of pixels
	CALL write_line			; Writes the line of pixels that refer to the value of R1
	ADD R1, 1			; Selects next line to write		
	SUB R0, 1			; Decreases the remaining object height to write (-1)
	JZ END_WRITE_LINES		; Ends routine if remaining object height to write is 0 (object is written)
	JMP WRITE_LINES			; Repeats write_lines if there are more lines to write
	
END_WRITE_LINES:
	POP R9				; Returns object layout table
	POP R3
	POP R1				; Returns object position line
	POP R0
	RET


;*********************************************************************************************
;* write_line:
;
; Writes a line of pixels determined by the object width to draw
;
; INPUT: 	R2 - Object position column
;		R3 - Object width
;		R5 - Object pixel colour
;*********************************************************************************************	

write_line:      
	PUSH R3				; Stores width
	PUSH R2				; Stores current column in stack
	PUSH R5				; Stores pixel colour in stack
	
WRITE_PIXELS_LINE:				
	MOV R5, [R9]			; Stores pixel colour in R5
	CALL pick_colour		; Changes colour to 0 if ERASER mode is activated
	CALL write_pixel		; Writes pixel
	ADD R9, 2			; Gets next colour (R9 is object layout)
    	ADD R2, 1          	    	; Gets next column
    	SUB R3, 1			; Decreases number of remaining columns to write (-1)
   	JNZ WRITE_PIXELS_LINE      	; Repeats until all width of the object is written (until R3 is 0)
  	POP R5							
   	POP R2							
   	POP R3
   	RET


;***************************************************************************************************
;* pick_colour:
;
; Changes pixel colour based on PEN_MODE flag value
;
; INPUT: 	R5 - Pixel colour to use
; OUTPUT: 	R5 - Pixel colour to use
;***************************************************************************************************
    
pick_colour:
	PUSH R6
	MOV R6, [PEN_MODE]
	CMP R6,	ERASER 			; Checks PEN_MODE flag
	JNZ END_COLOUR			; If PEN mode is selected, pixel colour remains the same
	MOV R5, ERASER			; If ERASER mode is activated, colour 0 is selected

END_COLOUR:
	POP R6
	RET				; Ends routine
	
	
;***************************************************************************************************
;* write_pixel:
;
; Write a pixel on the screen
;
; INPUT: 	R1 - Screen line to write on
;		R2 - Screen column to write on
;		R5 - Pixel colour to use
;***************************************************************************************************
    
write_pixel:
	MOV [DEF_LINE], R1		; Selects line to write
	MOV [DEF_COL], R2		; Selects column to write
	MOV [DEF_PIXEL], R5		; Changes pixel colour in line and colum selected
	RET
	

;**************************************************************************************
;* keypad:
;
; Verifies if there is a pressed button and, if true, store it in memory.
; Otherwise resets the button (FFFFH)
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

CHECK_KEYPAD:				; Checks if there is a pressed button
   	MOVB [R2], R1      		; Injects line in keypad lines
   	MOVB R0, [R3]      		; Reads from keypad columns
   	MOV R4, KEY_MASK		; Loads keypad mask to R4
  	AND R0, R4   			; Isolates the lower nibble
  	JZ WAIT_BUTTON    		; Jumps if no button is pressed in that line
   	CALL button_calc		; Calls the process that calculates the button pressed
  	JMP KEYPAD_END			; Jumps to the end

WAIT_BUTTON:	
	SHR R1, 1		   	; Changes which line is checked
	JNZ CHECK_KEYPAD		; Jumps if there is still a line to check
	MOV R1, [BUTTON]
	MOV [LAST_BUTTON], R1	
	MOV R2, NO_BUTTON		; Moves value -1 (estado normal do botao) to R2
	MOV [BUTTON], R2		; Changes BUTTON value to FH

KEYPAD_END:
	POP R4				; Restores value to R4
	POP R3				; Restores value to R3
	POP R2				; Restores value to R2
	POP R1				; Restores value to R1	
	POP R0				; Restores value to R0
	RET


;***********************************************************************************************************
;* button_calc:
;
; Calculates pressed line and column, and calls button_formula to determine the pressed button 
; and store it in memory along with the previous pressed button
;
; INPUT: 	R0 - Keypad peripheral output
;		R1 - Keypad peripheral input (injected line)	
;************************************************************************************************************

button_calc:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	MOV R2, 0		   	; Initializes Lines Counter
	MOV R3, 0		   	; Initializes Columns Counter

CALC_LIN:				; Determines which line is being pressed (0-3)
	SHR R1, 1		   	; Shifts the pressed line 1 bit to the right
	JZ CALC_COL		   	; Jumps to calculate which column is being pressed
	ADD R2, 1		   	; Adds 1 to the line counter
	JMP CALC_LIN			; Repeats calc_lin keeps calculating the line

CALC_COL:				; Determines which column is being pressed (0-3)
	SHR R0, 1		   	; Shifts the pressed column 1 bit to the right
	JZ BUTTON_CALC_END		; Jumps to end routine
	ADD R3, 1		   	; Adds 1 to the column counter
	JMP CALC_COL			; Repeats calc_col to keep calculating the column counter

BUTTON_CALC_END:	
	CALL button_formula		; Calculates the button that is being pressed
	MOV R3, [BUTTON]
	MOV [LAST_BUTTON], R3
	MOV [BUTTON], R2		; Stores button pressed address in R0
	POP R3
	POP R2
	POP R1
	POP R0
	RET


;***********************************************************************************
;* button_formula
;
; Calculates the pressed button using the formula 4 * line + column
;
; INPUT: 	R2 - Line counter (obtained in CALC_LIN)
;		R3 - Column counter (obtained in CALC_COL)
; OUTPUT:	R2 - Pressed button
;***********************************************************************************

button_formula:
	SHL R2, 2			; Multiples the line counter by 4 
	ADD R2, R3			; Adds the column counter to calculate the button pressed
	RET
	
	
;***************************************************************************************
;* delay: 
;
; Adds 1 to DELAY_COUNTER value. If the value reaches MOV_TIMER, the counter is reset and
; DELAY_FLAG is activated (set to 1) allowing the ship to move
;
; INPUT: 	R10 - MOV_TIMER (delay maximum)
;***************************************************************************************	

delay:
	PUSH R0
	PUSH R1
	PUSH R2	
	PUSH R3
	PUSH R10
	CALL same_button		; Stores pressed button in R0 and previous pressed button in R1
	CMP R0, R1			; Checks if the buttons are the same
	JNZ RESET			; Resets counter if buttons are not the same
	MOV R2, [DELAY_COUNTER]		; Stores DELAY_COUNTER value in R2
	ADD R2, 1			; Increments the delay by 1			
	CMP R2, R10			; Checks if delay has reached MOV_TIMER (delay maximum)
	JNZ DEACTIVATE_FLAG

RESET:
	MOV R2, 0			; Sets counter back to 0

ACTIVATE_FLAG:				; Activates flag so the object can move
	MOV R3, 1			
	MOV [DELAY_FLAG], R3
	JMP END_DELAY

DEACTIVATE_FLAG:			; Deactivates flag to prevent object from moving
	MOV R3, 0
	MOV [DELAY_FLAG], R3
	
END_DELAY:			
	MOV [DELAY_COUNTER], R2		; Updates the DELAY_COUNTER value
	POP R10
	POP R3
	POP R2
	POP R1
	POP R0
	RET


;*****************************************************************************************
;* same_button: 
;
; Stores value of BUTTON and LAST_BUTTON
; OUTPUT:	R0 - Stores pressed button
;		R1 - Stores previous pressed button
;*****************************************************************************************

same_button:
	MOV R0, [BUTTON]		; Stores current pressed button in R0
	MOV R1, [LAST_BUTTON]		; Stores previous pressed button in R1
	RET
	
;*****************************************************************************************
;*INTERRUPTIONS
;
;*****************************************************************************************

meteor_interruption:
	PUSH R0
	MOV R0, 1
	MOV [METEOR_INTERRUPTION_FLAG], R0	; Activates meteor interruption flag
	POP R0
	RFE 
	
missile_interruption:
	PUSH R0
	MOV R0, 1
	MOV [MISSILE_INTERRUPTION_FLAG], R0	; Activates missile interruption flag
	POP R0
	RFE 


energy_interruption:
	PUSH R0
	MOV R0, 1
	MOV [ENERGY_INTERRUPTION_FLAG], R0	; Activates energy interruption flag
	POP R0
	RFE 
