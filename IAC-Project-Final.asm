
;********************************************************************************************************
;* SPACE INVADERS
; IAC PROJECT - FINAL VERSION
;
; GROUP 13: João Trocado (103333), Pedro Freitas (103168), Tiago Firmino (103590)
;********************************************************************************************************

WORD_VALUE		EQU 02H		
LOWER_BYTE_MASK		EQU 00FFH
BYTE_VALUE		EQU 8
FLAG_ON			EQU 1		; Value that determines a activated flag
FLAG_OFF		EQU 0		; Value that determines a deactivated flag
NO_VALUE		EQU FLAG_OFF	

;****KEYPAD****************************************************************************************************************
INJECTED_LINE 		EQU BYTE_VALUE	; Initial keypad line (fourth)
KEY_LIN 		EQU 0C000H	; Keyboard Rows
KEY_COL 		EQU 0E000H	; Keyboard Columns
KEY_MASK		EQU 0FH		; Isolates the lower nibble from the output of the keypad
NO_BUTTON		EQU 0FFFFH	; Value of no pressed button
GET_RANDOM_NUMBER	EQU 5		; Value that is used to Move the RANDOM_NUMBER from bits(7 to 4) into bits 2 to 0


;****DISPLAY***************************************************************************************************************

DISPLAY			EQU 0A000H	; Display adress
UPPER_BOUND		EQU 0064H	; Display upper bound (energy)
LOWER_BOUND		EQU 0000H	; Display lower bound (energy)
DISPLAY_TIMER 		EQU 0100H	; Display delay between pressing button and changing energy value
HEXTODEC_CONST		EQU 000AH	; Display hexadecimal to decimal constant
DISPLAY_DECREASE	EQU -5		; Display decremente value 
BAD_COLLISION_INCREASE	EQU 10		; Display increase value when there is a missile-meteor collision
GOOD_COLLISION_INCREASE EQU 15		; Display increase value when there is a ship-meteor collision
INITIAL_DISPLAY_VALUE	EQU 0100H	; Display initial shown value


;****KEYPAD COMMANDS*********************************************************************************************************

START			EQU 0CH		; Start game
PAUSE			EQU 0DH		; Pause game
END			EQU 0EH		; End game
LEFT			EQU 00H		; Move ship left
RIGHT			EQU 02H		; Move ship right
SHOOT			EQU 01H		; Shoot missile


;***MEDIA CENTER COMMANDS**************************************************************

DEF_LINE    		EQU 600AH	; Define line command adress 
DEF_COL  		EQU 600CH	; Define column command adress
DEF_PIXEL    		EQU 6012H	; Write pixel command adress
DEL_WARNING     	EQU 6040H	; Delete no background warning command adress
DEL_ALL_SCREENS		EQU 6002H	; Delete all pixels drawn command adress
DEL_SCREEN		EQU 6000H

SELECT_FOREGROUND	EQU 6046H       ; Select a foreground command adress
DEL_FOREGROUND		EQU 6044H	; Deletes froeground command adress
SELECT_BACKGROUND 	EQU 6042H	; Select background command adress
SELECT_SCREEN		EQU 6004H	; Select pixel screen

PLAY_SOUND_VIDEO	EQU 605AH	; Plays a sound/video util its end
START_SOUND_VIDEO	EQU 605CH	; Continously plays a sound/video
PAUSE_SOUND_VIDEO	EQU 605EH	; Pauses a sound/video
RESUME_SOUND_VIDEO	EQU 6060H	; Resumes the sound/video
END_ALL_SOUND_VIDEO	EQU 6068H	; Ends all playing/paused videos/sounds


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
WIDTH			EQU 5		; Ship width
HEIGHT			EQU 4		; Ship height
WHITE			EQU 0FFFDH	; Hexadecimal ARGB value of the colour WHITE
RED			EQU 0FE00H	; Hexadecimal ARGB value of the colour RED
DARKRED			EQU 0FE33H	; Hexadecimal ARGB value of the colour DARKRED
BLUE			EQU 0F48FH	; Hexadecimal ARGB value of the colour BLUE


;***MISSILE****************************************************************************************************************

MISSILE_WIDTH		EQU 1		; Missile width
MISSILE_HEIGHT		EQU 1		; Missile height
MISSILE_LINE_MAX	EQU 15		; Maximum line the missile can go
MISSILE_COLOUR		EQU 0E8EFH	; Missile colour


;***METEORS*************************************************************************************************************

METEOR_LINE		EQU 0		; Meteor initial line
MET_TIMER		EQU 0100H	; Meteor spawn timer
MAX_STEPS		EQU 13		; Maximum number of steps until meteor stops changing layouts
MAX_METEOR_LINE		EQU 1FH		; Maximum line a meteor can go
NEXT_METEOR_VALUE	EQU 06H		; Value added to METEOR_TABLE to go from one meteor position to another
OBTAIN_STEPS		EQU 04H		; Value added to METEOR_TABLE to obtain a meteor steps from its position
GOOD_COLLISION		EQU 1H		; Value that refers to a good collision ( collision with ENERGY_BOLT)
BAD_COLLISION		EQU 0H		; Value that refers to a bad collision ( collision with METEOR)
MAXIMUM_METEOR_NUMBER 	EQU 4H		; Maximum number of meteors that can appear on screen
NO_METEORS		EQU 0H		; Value that reffers to no meteors being on screen

YELLOW 			EQU 0FFE0H
DARKYELLOW		EQU 0FFC1H
ORANGE			EQU 0FF90H

CENTERGREY		EQU 0F999H
LIGHTERBLUE		EQU 0F589H
OUTERBLUE		EQU 0F579H
DARKGRAY		EQU 0F777H
GRAY 			EQU 0FAAAH
LIGHTGRAY		EQU 0F9ABH
DARK 			EQU 0F447H
LIGHT 			EQU 0FACCH

DEADRED			EQU 0FE55H
PINK			EQU 0FF97H
DEADYELLOW		EQU 0FAA3H
BRIGHTYELLOW		EQU 0FFF3H
DEADORANGE		EQU 0FEA7H

;***RANDOM*************************************************************************************************************

RANDOM_MAX		EQU 7		; Maximum Value the random number can achieve
MAX_METEOR_COLUMN	EQU 56		; Maximum collumn a meteor can appear in
COL_DETERM_VAL		EQU 8		; Value ADDED to the RANDOM number to obtain the meteor column


;*************************************************************************************************************************

PLACE 1000H
STACK 100H

STACK_INIT:


;**********OBJECTS LAYOUT*************************************************************************************************

DEF_SHIP:				; Ship layout (colour of each pixel, height, width)
	WORD HEIGHT, WIDTH
	WORD 0, 0, BLUE, 0, 0, 0, RED, WHITE, RED, 0, DARKRED, WHITE, WHITE, WHITE, DARKRED, WHITE, 0, WHITE, 0, WHITE

DEF_OBJECT_FAR:				; Initial object layout
	WORD 1, 1
	WORD CENTERGREY

DEF_OBJECT_CLOSER:			; Closer object layout
	WORD 3, 3
	WORD 0, CENTERGREY, 0, CENTERGREY, CENTERGREY, CENTERGREY, 0, CENTERGREY, 0

DEF_METEOR_SMALL:			; Small METEOR layout
	WORD 4, 4
	WORD 0, LIGHTERBLUE, OUTERBLUE, 0, OUTERBLUE, GRAY, GRAY, LIGHTERBLUE, LIGHTERBLUE, CENTERGREY, LIGHTGRAY, OUTERBLUE,
		0, OUTERBLUE, LIGHTERBLUE, 0

DEF_METEOR_MEDIUM:			; Medium METEOR layout
	WORD 5, 5
	WORD 0, OUTERBLUE, LIGHTERBLUE, LIGHTERBLUE, LIGHTERBLUE, 0, LIGHTERBLUE, GRAY, GRAY, LIGHTERBLUE, OUTERBLUE, LIGHTERBLUE,
		DARK, DARKGRAY, OUTERBLUE, 0, OUTERBLUE, LIGHTERBLUE, OUTERBLUE, LIGHTERBLUE, LIGHTERBLUE, 0, 0, LIGHTERBLUE, 0, 0 

DEF_METEOR_MAX:				; Maximum METEOR layout
	WORD 6, 6
	WORD 0, 0, LIGHTERBLUE, LIGHTERBLUE, LIGHTGRAY, LIGHTERBLUE, 0, OUTERBLUE, LIGHTGRAY, LIGHTGRAY, DARKGRAY, OUTERBLUE,
		OUTERBLUE, GRAY, DARK, LIGHT, DARKGRAY, OUTERBLUE, LIGHTERBLUE, GRAY, LIGHTGRAY, LIGHTGRAY, GRAY, LIGHTERBLUE,
		OUTERBLUE, OUTERBLUE, LIGHTGRAY, DARKGRAY, LIGHTERBLUE, 0, 0, OUTERBLUE, LIGHTERBLUE, OUTERBLUE, 0, 0
	
DEF_ENERGY_BOLT_SMALL:			; Small ENERGY_BOLT layout
	WORD 4, 4
	WORD 0, 0, 0, DARKYELLOW, 0, YELLOW, YELLOW, 0, 0, YELLOW, YELLOW, 0, DARKYELLOW, 0, 0, 0

DEF_ENERGY_BOLT_MEDIUM:			; Medium ENERGY_BOLT layout
	WORD 5, 3
	WORD 0, 0, ORANGE, 0, YELLOW, 0, YELLOW, YELLOW, YELLOW, 0, YELLOW, 0, ORANGE, 0, 0 

DEF_ENERGY_BOLT_MAX:			; Maximum ENERGY_BOLT layout
	WORD 6, 3
	WORD 0, 0,DARKYELLOW, 0, ORANGE, 0, YELLOW, YELLOW, YELLOW, 0, 0, ORANGE, 0,	ORANGE, 0, DARKYELLOW, 0, 0

DEF_MISSILE:				; Missile layout
	WORD MISSILE_HEIGHT, MISSILE_WIDTH
	WORD MISSILE_COLOUR
	
EXPLODE_METEOR:				; Meteor explosion layout
	WORD 6, 6
	WORD 0,0, PINK, 0, DEADRED, 0, 0, BRIGHTYELLOW, 0, BRIGHTYELLOW, 0, YELLOW, DEADORANGE, 0, ORANGE, DEADRED,
		BRIGHTYELLOW, 0, 0, BRIGHTYELLOW, DEADRED, ORANGE, 0, DEADORANGE, DEADRED, 0, BRIGHTYELLOW, 0, BRIGHTYELLOW,
		0, 0, YELLOW, 0, PINK, 0, 0
	

;*************************************************************************************************************************

interruption_table:
	WORD meteor_interruption	; Meteor interruption routine
	WORD missile_interruption	; Missile interruption routine
	WORD energy_interruption	; Energy interruption routine	
	
		
;**************************************************************************************************************************

BUTTON:					; Currently pressed button
	WORD 0H
	
LAST_BUTTON:				; Previously pressed button
	WORD 0H

SHIP_PLACE:				; Reference to the position of ship 
	BYTE LINE, COLUMN		; First byte of the word stores the line and the second one the column
	
MISSILE_PLACE:				; Reference to the position of the missile 
	BYTE 0H, 0H			; First byte of the word stores the line and the second one the column
	
CHANGE_COL:				; Stores column variation of the position of the object
	WORD NO_VALUE
	
CHANGE_LINE:				; Stores line variation of the position of the object
	WORD NO_VALUE

PEN_MODE:				; Flag used to either draw or erase pixels by draw_object and erase_object
	WORD NO_VALUE
	
DELAY_COUNTER:				; Counter until MOV_TIMER is reached and ship moves
	WORD 0H

DISPLAY_VALUE:
	WORD INITIAL_DISPLAY_VALUE	; Energy display initial value

DISPLAY_VARIATION:			; Energy display variation value
	WORD NO_VALUE
	
DELAY_FLAG:				; Ship movement delay flag
	WORD FLAG_OFF

METEOR_INTERRUPTION_FLAG:		; Flag to determine the movement of the meteor 
	WORD FLAG_OFF

MISSILE_INTERRUPTION_FLAG:		; Flag to determine the movement of the missile
	WORD FLAG_OFF
	
ENERGY_INTERRUPTION_FLAG:		; Flag to determine the movement of the energy
	WORD FLAG_OFF

MET_SPAWN_TIMER:			; Value to determine the creation of a meteor 
	WORD MET_TIMER

METEOR_NUMBER:				; Number of meteors in the screen
	WORD 0H
	
BAD_METEOR_SHAPES:			; Meteor evolution table of all METEOR layouts
	WORD DEF_OBJECT_FAR, DEF_OBJECT_CLOSER 
	WORD DEF_METEOR_SMALL, DEF_METEOR_MEDIUM
	WORD DEF_METEOR_MAX
	
GOOD_METEOR_SHAPES:			; Meteor evolution table of all ENERGY BOLT layouts
	WORD DEF_OBJECT_FAR, DEF_OBJECT_CLOSER 
	WORD DEF_ENERGY_BOLT_SMALL, DEF_ENERGY_BOLT_MEDIUM
	WORD DEF_ENERGY_BOLT_MAX			

METEOR_TABLE:				; Table of all the meteor positions, meteor evolution tables and steps they took
	BYTE NO_VALUE, NO_VALUE 
	WORD NO_VALUE, 1H
	
	BYTE NO_VALUE, NO_VALUE 
	WORD NO_VALUE, 1H
	
	BYTE NO_VALUE, NO_VALUE 
	WORD 0H, 1H
	
	BYTE NO_VALUE, NO_VALUE 
	WORD NO_VALUE, 1H

EXISTS_COLLISION:			; Flag that determines if there was a collision
	WORD NO_VALUE
	
LEFT_DOWN_POSITION:			; Lower left corner reference position (meteor)
	WORD NO_VALUE
	
RIGHT_UP_POSITION:			; Upper right corner reference position (meteor)
	WORD NO_VALUE
	
COLLISION_TYPE:				; Flag that determines collision type
	WORD NO_VALUE
	
END_GAME_FLAG:				; Flag that determines if game has ended
	WORD FLAG_OFF
	

;*************************************************************************************************************************

PLACE 0H

FIRST_INITIALIZER:
	MOV BTE, interruption_table	; Iniciates BTE in interruption table
	MOV SP, STACK_INIT		; Iniciates SP for the stack
	EI0				; Allows meteor_interruption 
	EI1				; Allows missile_interruption 
	EI2				; Allows energy_interruption 
	EI				; Allows all interruptions
	
SECOND_INITIALIZER:
	CALL initial_screen_menu	; Starts initial screen menu
	CALL reset_game
    	CALL start_game			; Starts game

MAIN_CYCLE:
	CALL keypad			; Checks if there is a pressed button
	CALL commands			; Checks if game has ended or if command buttons were pressed (PAUSE or END)
	CALL display_clock_decrease	; Checks if the pressed button changes the display
	CALL mov_missile		; Checks if missile is to be shot , moved , or destroyed
	CALL create_met			; Checks if the pressed button changes the meteor position
	CALL move_meteors		; Moves all of the meteors if the requirements are set 
	CALL mov_ship			; Checks if the pressed button changes the ship position
	JMP MAIN_CYCLE


;********************************************************************************************************
;* initial_screen:
;
; Initializes the starting screen
;********************************************************************************************************		

initial_screen_menu:
	PUSH R0
	PUSH R1
	MOV R0, NO_VALUE
	MOV [DEL_WARNING], R0		; Deletes no background warning (R0 value is irrelevant)
	MOV [DEL_ALL_SCREENS], R0	; Deletes all drawn pixels (R0 value is irrelevant)
	MOV [DEL_FOREGROUND], R0
	MOV R1, 2
    	MOV [START_SOUND_VIDEO], R1	; Plays starting music
    	MOV [SELECT_BACKGROUND], R1	; Selects initial screen background
	
INITIAL_SCREEN_LOOP:
	CALL keypad
	MOV R1, START
	MOV R0, [BUTTON]
	CMP R1, R0
	JNZ INITIAL_SCREEN_LOOP		; Repeats cycle until START button is pressed
	MOV R0, 2
	MOV [END_ALL_SOUND_VIDEO],R0	; Ends all video/sounds playing
	POP R1
	POP R0
	RET
	

;********************************************************************************************************
;* start_game:
;
; Starts the game
;********************************************************************************************************

start_game:
	PUSH R0
	PUSH R1
	MOV [END_ALL_SOUND_VIDEO], R0	; Ends all video/sounds playing
	MOV [DEL_FOREGROUND], R0	; Deletes foreground screen
	MOV R0, 1
	MOV [START_SOUND_VIDEO], R0	; Starts gameplay music
	MOV [SELECT_BACKGROUND], R0  	; Selects background number 1
	
	CALL build_ship			; Draws ship in its original position
	
    	MOV R0, INITIAL_DISPLAY_VALUE	; Stores energy display initial value in R0
	MOV [DISPLAY], R0		; Initializes display
	MOV R0, UPPER_BOUND
	MOV [DISPLAY_VALUE], R0		; Changes display value to UPPER_BOUND
	POP R1
	POP R0
	RET
	
;********************************************************************************************************
;* build_ship:
;
; Draws ship in its original position
;********************************************************************************************************

build_ship:
	PUSH R1
	PUSH R2
	PUSH R8
	PUSH R9
	
	MOV R8, SHIP_PLACE		; Stores line in the first byte of R8 and column on the second one
	MOV R9, DEF_SHIP 		; Stores ship layout
	CALL placement			; Stores the ship position reference, R1 stores line and R2 stores column
	CALL draw_object		; Draws ship
	
	POP R9
	POP R8
	POP R2
	POP R1
	RET	
	

;***********************************************************************************************************
;* commands:
;
; Pauses the game or ends the game according to the button pressed and/or if the END_GAME_FLAG is activated
;***********************************************************************************************************

commands:
	PUSH R0
	PUSH R1
	PUSH R2
	MOV R0, [BUTTON]
	MOV R2, [END_GAME_FLAG]	; Stores END_GAME_FLAG value

PAUSE_BUTTON_CHECK:
	MOV R1, PAUSE
	CMP R0, R1
	JNZ END_BUTTON_CHECK	; Jumps if PAUSE button was not pressed 
	MOV R1, [LAST_BUTTON]
	CMP R0, R1
	JZ END_CHECK		; Jumps if LAST_BUTTON and BUTTON are both PAUSE
	CALL pause_menu		; Enters pause menu
	JMP END_CHECK
	
END_BUTTON_CHECK:
	MOV R1, END
	CMP R0, R1
	JNZ END_CHECK		; Jumps if pressed BUTTON is END
	MOV R2, FLAG_ON		; Activates END_GAME_FLAG value
	
END_CHECK:
	CMP R2, FLAG_ON
	JNZ COMMANDS_END	; Ends routine if END_GAME_FLAG value is 0
	CALL end_game_menu	; Enters end_game_menu (ends game)
	
COMMANDS_END:
	POP R2
	POP R1
	POP R0
	RET


;********************************************************************************************************
;* pause_menu:
;
; Loop cycle until PAUSE button is pressed again
;********************************************************************************************************

pause_menu:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	MOV R3, 0
	MOV [SELECT_FOREGROUND], R3	; Selects foreground number 0
	MOV R3, 1
	MOV [PAUSE_SOUND_VIDEO], R3	; Stops the gameplay music
	
PAUSE_CYCLE:	
	CALL keypad
	MOV R1, [BUTTON]
	MOV R0, END
	CMP R1, R0
	JZ PRESSED_END_BUTTON		; Jump if END button was pressed
	
	MOV R0, PAUSE
	CMP R1, R0
	JNZ PAUSE_CYCLE			; Repeat cycle if PAUSE button was not pressed
	
	MOV R0, [LAST_BUTTON]
	CMP R1, R0
	JZ PAUSE_CYCLE			; Repeat cycle if LAST_BUTTON and BUTTON are both PAUSE (stops first pause_menu entry)
	
	JMP PAUSE_END			; Ends routine
	
PRESSED_END_BUTTON:
	MOV R1, FLAG_ON
	MOV [END_GAME_FLAG], R1		; Activates END_GAME_FLAG
	
PAUSE_END:
	MOV [DEL_FOREGROUND], R3	; Deletes foreground screen 
	MOV [RESUME_SOUND_VIDEO], R3	; Resumes the gameplay music
	POP R3
	POP R2
	POP R1
	POP R0
	RET
	
	
;********************************************************************************************************
;* mov_ship:
;
; Moves ship position (accordingly to its delay) if the button pressed is either LEFT or RIGHT
;********************************************************************************************************

mov_ship:
	PUSH R0	
	PUSH R7
	PUSH R8 
	PUSH R9
	PUSH R10
	
	MOV R0, [END_GAME_FLAG]
	CMP R0, FLAG_ON
	JZ SHIP_END			; Ends routine if END_GAME_FLAG is activated
	
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
	CMP R10, FLAG_ON
	JNZ SHIP_END			; Ends routine if DELAY_COUNTER is neither 0 nor MOV_TIMER
	
MOVE:
	MOV [CHANGE_COL], R7		; Stores column variation value of ship position
	CALL placement			; Stores ship line in R1 and its column in R2
	CALL test_ship_limits		; Checks if ship has reached left or right screen limits
	MOV R7, [CHANGE_COL]		; Stores new column variation value after checking screen limits
	CMP R7, NO_VALUE		;
	JZ SHIP_END			; Ends routine if column variation is 0
	CALL erase_object		; Deletes object from current position
	ADD R2, R7			; Adds column variation to the new reference position of ship
	ADD R8, 1			; Adds 1 to SHIP_PLACE to obtain the column address
	MOVB [R8], R2			; Changes column position of the ship
	CALL draw_object		; Draws object in new position

SHIP_END:
	POP R10
	POP R9
	POP R8
	POP R7
	POP R0
	RET
		

;***************************************************************************************************************************
;* mov_missile:
;
; Shoots a missile (if the pressed Button is SHOOT) and moves the missile upwards if MISSILE_INTERRUPTION_FLAG is activated
;***************************************************************************************************************************

mov_missile:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R8
	PUSH R9
	
	MOV R1, [END_GAME_FLAG]
	CMP R0, FLAG_ON
	JZ MOV_MISSILE_END			; Ends routine if END_GAME_FLAG is activated
	
	MOV R9, DEF_MISSILE			; Stores missile layout in R9
	MOV R8, MISSILE_PLACE			; Stores missile reference position address in R8
	CALL shoot_missile			; Shoots a missile if the pressed button is SHOOT and there is no missile in the air
	
	MOV R0, [END_GAME_FLAG]
	CMP R0, FLAG_ON
	JZ MOV_MISSILE_END			; Ends routine if after shooting, END_GAME_FLAG is activated (energy reached 0%)
	
	CAll placement				; Stores missile reference position (line in R1, column in R2)
	CMP R1, NO_VALUE			; Checks if there is a missile in the air (line will never be 0)
	JZ MOV_MISSILE_END			; Jumps to end of routine if there is no missile in the air

ALLOW_MISSILE_MOV:
	MOV R0, [MISSILE_INTERRUPTION_FLAG]	
	CMP R0, FLAG_ON				
	JNZ MOV_MISSILE_END			; Ends routine if MISSILE_INTERRUPTION_FLAG is not activated

MOVE_DRAW_MISSILE:
	MOV R0, -1				
	MOV [CHANGE_LINE], R0			; Changes the Line variation value to -1
	CALL mov_object_vertically		; Moves the missile vertically 1 line up
	MOV R0, FLAG_OFF			
	MOV [MISSILE_INTERRUPTION_FLAG], R0	; Resets the interruption value to 0
	CALL check_missile_limits		; Checks if the missile has reached its limit position
	
MOV_MISSILE_END:
	POP R9
	POP R8
	POP R2
	POP R1
	POP R0
	RET
	
	
;********************************************************************************************************
;* shoot_missile:
;
; Shoots a missile if there isnt one flying already
;********************************************************************************************************

shoot_missile:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R8
	PUSH R9
	MOV R0, [BUTTON]		; Stores pressed button 
	MOV R1, SHOOT			
	CMP R0, R1			; Checks if the pressed button is SHOOT
	JNZ SHOOT_MISSILE_END		; Ends routine if the last instruction is false
	
GET_MISSILE_POSITION:
	MOV R0, [MISSILE_PLACE]		; Stores missile placement
	CMP R0, NO_VALUE		; Verifies if line and collumn are 0 ( there is no missile flying)
	JNZ SHOOT_MISSILE_END		; If no missile is in the air, end routine
	
DRAW_MISSILE:
	MOV R8, SHIP_PLACE		; Stores ship position
	CALL placement			; Stores ship reference position (Line in R1 and Column in R2)
	ADD R1, -1			; Adds -1 to obtain line above the ship
	ADD R2, 2			; Adds 2 to obtain middle reference collumn of the ship
	MOV R9, DEF_MISSILE		; Stores missile layout
	Call draw_object		; Draws object
	MOV [PLAY_SOUND_VIDEO], R0	; Plays shooting sound
	SHL R1, BYTE_VALUE		; Moves R1 to the upper byte
	OR R1, R2			; Stores line and column together in R1
	MOV [MISSILE_PLACE], R1		; Stores in memory the missile reference position
	CALL display_decrease		; Decreases display value by 5%
		
SHOOT_MISSILE_END:
	POP R9
	POP R8
	POP R2
	POP R1
	POP R0
	RET
	
	
;********************************************************************************************************
;* check_missile_limits:
;
; Checks if missile has reached either the MISSILE_LINE_MAX value or if there is a collision
;
; INPUT:	R8 - Missile reference position
;	 	R9 - Missile layout address
;********************************************************************************************************		
	
check_missile_limits:
	PUSH R0
	PUSH R1
	PUSH R2
	CALL placement			; Stores missile reference position (Line in R1 and Column in R2)

MISSILE_TOP_LIMIT:
	MOV R0, MISSILE_LINE_MAX	 
	CMP R1, R0			; Checks if missile line has reached its maximum value
	JNZ CHECK_MISSILE_LIMITS_END	; Ends routine if the last instruction is false
	CALL erase_object		; Erases the missile from the screen
	MOV R0, NO_VALUE			
	MOV [R8], R0			; Changes in memory the missile line and column to 0

CHECK_MISSILE_LIMITS_END:
	POP R2
	POP R1
	POP R0
	RET
	
	
;********************************************************************************************************
;* mov_object_vertically:
;
; Moves a object vertically based on CHANGE_LINE value
;
; INPUT: 	R8 - Object Reference position 
;		 R9 - Object Layout
;********************************************************************************************************		

mov_object_vertically:
	PUSH R1
	PUSH R7
	PUSH R8
	MOV R7 , [CHANGE_LINE]		; Stores Line variation value in R7
	CALL placement			; Stores object reference position (Line in R1 and Column in R2)
	CALL erase_object		; Deletes object from current position
	ADD R1, R7			; Adds line variation to the new reference position of meteor
	MOVB [R8], R1			; Stores in memory the new line position of the meteor
	CALL draw_object		; Draws object in the new position
	
MOV_OBJECT_VERTICALLY_END:
	POP R8
	POP R7
	POP R1
	RET


;********************************************************************************************************
;* create_met:
;
; Creates a meteor if MET_TIMER value is reached
;********************************************************************************************************

create_met:
	PUSH R0
	PUSH R2
	PUSH R3 
	
	MOV R2, [END_GAME_FLAG]
	CMP R2, FLAG_ON
	JZ CREATE_MET_END		; Ends routine if END_GAME_FLAG is activated
	
CHECK_MET_TIMER:
	MOV R3, [MET_SPAWN_TIMER]	; Stores spawn_timer value in R3
	MOV R2, MET_TIMER
	CMP R3, R2			; Checks if spawn_timer has reached its maximum value
	JLT CREATE_MET_END		; Jumps to end of routine if last instruction is false
	
	MOV R3, 0			; Stores the new value of MET_SPAWN_TIMER
	MOV R0, [METEOR_NUMBER]		; Stores METEOR_NUMBER in R0
	CMP R0, MAXIMUM_METEOR_NUMBER		; Checks if the maximum number of meteors was achieved
	JZ CREATE_MET_END		; Ends routine if previous instruction is true
	
	CALL store_build_meteor		; Stores and creates a meteor
	MOV R2, 0			
	MOV [SELECT_SCREEN], R2		; Selects screen number 0 (contains ship and missile)
	ADD R0, 1			; Adds 1 to the number of meteors
	MOV [METEOR_NUMBER], R0 	; Changes METEOR_NUMBER to its new added value
	
CREATE_MET_END:
	ADD R3, 1
	MOV [MET_SPAWN_TIMER], R3	; Changes MET_SPAWN_TIMER to its new added value
	POP R3
	POP R2
	POP R0
	RET
	
	
;********************************************************************************************************
;* store_build_meteor:
;
; Build a meteor and store it in METEOR_TABLE
;********************************************************************************************************

store_build_meteor:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R9
	PUSH R8
	MOV R8, METEOR_TABLE
	MOV R1, 1
	MOV [SELECT_SCREEN], R1		; Selects the first screen

FIND_SPACE:
	CALL placement			; Stores meteor reference position (Line in R1 and Column in R2) 
	CMP R2, NO_VALUE		; Checks if there is no meteor in this position (meteor will never be in collumn 0)
	JZ BUILD_METEOR			; If there is a free space it will build a meteor there
	CALL select_meteor		; Selects next meteor from the METEOR_TABLE and next pixel screen 
	JMP FIND_SPACE			; Repeats cycle until it finds a free meteor space
	
BUILD_METEOR:

	MOV R1, METEOR_LINE		; Stores initial meteor position line in R1
	CALL random_met_place		; Creates a random spawning column for the meteor
	MOV R3, R1			; Stores METEOR_LINE in R3
	SHL R3, BYTE_VALUE		; Stores meteor line in upper byte
	OR R3, R2			; Obtains meteor reference position by adding meteor column to R3
	MOV [R8], R3			; Stores in memory the meteor reference position
	ADD R8, WORD_VALUE 		; Advances one word in the meteor_table to obtain meteor_layout 
	CALL random_met_type		; Chooses the random meteor type (GOOD_METEOR or BAD_METEOR)
	MOV [R8], R9			; Stores in memory the meteor evolution table address
	MOV R9, [R9]			; Obtains the meteor layout
	CALL draw_object		; Draws meteor
	
STORE_BUILD_METEOR_END:
	POP R9
	POP R8
	POP R3
	POP R2
	POP R1
	RET	


;********************************************************************************************************
;* random_met_place:
;
; Chooses the meteor column randomly (8 possible columns, columns 8 to 56)
;
; OUTPUT:	R2 - Meteor spawn column
;********************************************************************************************************

random_met_place:
	PUSH R0
	PUSH R1
	PUSH R3
	PUSH R4
	MOV R3, KEY_COL			; Stores keypad output in R3
	MOV R1, COL_DETERM_VAL		; Stores COL_DETERM_VAL (8) in R1
	
GENERATE_RANDOM_COL:
	MOVB R0, [R3]			; Reads from keypad columns
	SHR R0, GET_RANDOM_NUMBER	; Obtains the random value in bits 7 to 4 placing it in bits 2 to 0
	MOV R4, KEY_MASK
	AND R0, R4			; Isolates lower nibble
	MOV R2, R0			; Stores random column value (between 0 and 7)
	CMP R0, RANDOM_MAX
	JNZ DETERMINE_COLUMN		; Jump if value is not 7
	MOV R2, MAX_METEOR_COLUMN	; Store MAX_METEOR_COLUMN in R2 (56)
	JMP RANDOM_PLACE_END		; End routine

DETERMINE_COLUMN:
	SHL R2, 3			; Multiply random column value by 8
	ADD R2, R1			; Add COL_DETERM_VAL (8) to random column value

RANDOM_PLACE_END:
	POP R4
	POP R3
	POP R1
	POP R0
	RET
	

;****************************************************************************************************************
;* random_met_type:
;
; Chooses the meteor type randomly (25% chance to be GOOD_METEOR [0 or 1], 75% chance to be BAD_METEOR [2 to 7])
; 
; OUTPUT:	R9 - Meteor evolution table address
;****************************************************************************************************************

random_met_type:
	PUSH R0
	PUSH R1
	PUSH R3
	MOV R3, KEY_COL			; Stores keypad output in R3

GENERATE_RANDOM_NUM:
	MOVB R0, [R3]			; Reads from keypad columns
	SHR R0, GET_RANDOM_NUMBER	; Obtains the random value in bits 7 to 4 placing it in bits 2 to 0
	MOV R4, KEY_MASK
	AND R0, R4			; Isolates lower nibble

CHOOSE_MET_TYPE:
	CMP R0, 1
	JLE GOOD_MET			; Jumps if the value is lower or equal to 1
	MOV R9, BAD_METEOR_SHAPES	; Stores BAD_METEOR_SHAPES evolution table address in  R9
	JMP RANDOM_TYPE_END		; Ends routine

GOOD_MET:
	MOV R9, GOOD_METEOR_SHAPES	; Stores GOOD_METEOR_SHAPES evolution table address in  R9

RANDOM_TYPE_END:
	POP R3
	POP R1
	POP R0
	RET
	
	
;********************************************************************************************************
;* move_meteors:
;
; Moves all the meteors from the METEOR_TABLE if METEOR_INTERRUPTION_FLAG value is 1
;********************************************************************************************************

move_meteors:
	PUSH R1
	PUSH R3
	PUSH R6
	PUSH R7
	PUSH R8 
	PUSH R9
	
	MOV R3, 0				; Stores de R3 with the value 0
	MOV R1, [END_GAME_FLAG]
	CMP R1, FLAG_ON
	JZ MOVE_MET_END				; Ends routine if END_GAME_FLAG is activated
	
	MOV R8, METEOR_TABLE
	MOV R6, [METEOR_NUMBER]
	
ALLOW_METEOR_MOVEMENT:
	MOV R1, [METEOR_INTERRUPTION_FLAG]
	CMP R1, FLAG_ON				; Checks if there is METEOR_INTERRUPTION_FLAG value is 1
	JNZ MOVE_MET_END			; Ends routine if last instruction is false
	
	CALL clean_explosions			; Clean all explosions from screen number 5
	MOV [METEOR_INTERRUPTION_FLAG], R3	; Resets METEOR_INTERRUPTION_FLAG to 0
	CMP R6, 0
	JZ MOVE_MET_END				; Ends routine if the number of meteors is 0
	
	MOV R1, 1				
	MOV [SELECT_SCREEN], R1			; Selects first meteor screen

GET_METEOR:
	CALL placement				; Stores meteor reference position (Line in R1 and Column in R2) 
	CMP R2, NO_VALUE			; Checks if there is no meteor in this position (meteor will never be in column 0)
	JZ GET_NEXT_METEOR			; Jumps if there is no meteor in this position
	CALL move_meteor			; Moves meteor
	
	MOV R1, [END_GAME_FLAG]
	CMP R1, FLAG_ON
	JZ MOVE_MET_END				; Ends routine if END_GAME_FLAG is activated
	
	SUB R6, 1				; Subtracts 1 from the number of meteors
	JZ MOVE_MET_END				; Ends routine if there are no more meteors to take care of
	
GET_NEXT_METEOR:
	CALL select_meteor			; Selects next meteor from the METEOR_TABLE
	JMP GET_METEOR				; Repeats GET_METEOR cycle until all meteors are checked
	
MOVE_MET_END:
	MOV [SELECT_SCREEN], R3			; Selects original screen 
	POP R9
	POP R8
	POP R7
	POP R6
	POP R3
	POP R1
	RET


;********************************************************************************************************
;* clean_explosions:
;
; Deletes all destroyed meteors from screen number 5
; 
;********************************************************************************************************	

clean_explosions:
	PUSH R0
	MOV R0, 5
	MOV [DEL_SCREEN], R0		; Deletes all pixels from screen number 5 (deletes the explosions)
	
CLEAN_EXPLOSION_END:
	POP R0
	RET 	
	
	
;****************************************************************************************************************
;* move_meteor:
;
; Moves a meteor, checks its collisions, limits and modifies its layout based on the amount of steps it has taken	
;
; INPUT: 	R8 - METEOR_TABLE
;****************************************************************************************************************

move_meteor:
	PUSH R0
	PUSH R1
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	MOV R7, 1
	MOV [CHANGE_LINE], R7		; Changes line variation value to 1

CHECK_LAYOUT:
	MOV R7, [R8+WORD_VALUE]		; Adds WORD value to METEOR_TABLE to obtain meteor evolution table address
	MOV R9, [R7]			; Stores the meteor layout in R9
	CALL erase_object		; Erases meteor from the screen
	CALL select_layout		; Selects meteor layout based on steps it took
	MOV R7, [R8+WORD_VALUE]		; Adds WORD value to METEOR_TABLE to obtain meteor evolution table address
	MOV R9, [R7]			; Stores meteor layout in R9
	CALL mov_object_vertically	; Moves the meteor 1 line down

COLLISION_HAPPENED:
	CALL check_missile_collision	; Checks a missile-meteor collision
	MOV R6, [EXISTS_COLLISION]
	CMP R6, FLAG_ON
	JZ MOVE_METEOR_END		; Ends routine if a collision has happened
	
	CALL check_ship_collision	; Checks a ship-meteor collision
	MOV R6, [EXISTS_COLLISION]
	CMP R6, FLAG_ON
	JZ MOVE_METEOR_END
	CALL check_meteor_limits	; Eliminates de meteor if it has reached its maximum line

MOVE_METEOR_END:			; Ends routine
	MOV R6, NO_VALUE
	MOV [EXISTS_COLLISION], R6	; Resets EXISTS_COLLISION to 0
	POP R9
	POP R8
	POP R7
	POP R6
	POP R1
	POP R0
	RET


;********************************************************************************************************
;* check_ship_collision:
;
; Checks if a collision between the ship and a meteor has occured
;
; INPUT:	R8 - METEOR_TABLE
;		R9 - Meteor layout address
;********************************************************************************************************

check_ship_collision:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	
	MOV R1, [R8]				; Stores METEOR_TABLE in R1
	CALL obtain_reference_points		; Obtains LEFT_DOWN position in R1 and RIGHT_UP position in R2
	MOV [LEFT_DOWN_POSITION], R1		; Stores meteor LEFT_DOWN position in memory
	MOV [RIGHT_UP_POSITION], R2		; Stores meteor RIGHT_UP position in memory

	MOV R7, SHIP_PLACE			
	MOV R9, DEF_SHIP
	CALL check_collisions			; Checks if a collision happened between the ship and a meteor

DETECT_SHIP_COLLISION:
	MOV R6, [EXISTS_COLLISION]
	CMP R6, FLAG_ON
	JNZ CHECK_SHIP_COLLISION_END		; Ends routine if there was no collision
	CALL treat_ship_meteor_collisions	; Takes care of a ship-meteor collision
	
CHECK_SHIP_COLLISION_END:
	POP R9
	POP R8
	POP R7
	POP R6
	POP R3
	POP R2
	POP R1
	RET
	
	
;********************************************************************************************************
;* check_missile_collision:
;
; Checks if a collision between a missile and a meteor has occured
;
; INPUT:	R8 - METEOR_TABLE
;		R9 - Meteor layout address
;********************************************************************************************************

check_missile_collision:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	
	MOV R1, [R8]				; Stores METEOR_TABLE in R1
	CALL obtain_reference_points		; Obtains LEFT_DOWN position in R1 and RIGHT_UP position in R2
	MOV [LEFT_DOWN_POSITION], R1		; Stores meteor LEFT_DOWN position in memory
	MOV [RIGHT_UP_POSITION], R2		; Stores meteor RIGHT_UP position in memory

	MOV R7, MISSILE_PLACE			
	MOV R9, DEF_MISSILE			
	CALL check_collisions			; Checks collision between missile and meteor

DETECT_MISSILE_COLLISION:
	MOV R6, [EXISTS_COLLISION]
	CMP R6, FLAG_ON
	JNZ DETECT_MISSILE_COLLISION_END	; Ends routine if there was no collision
	CALL treat_missile_meteor_collisions	; Takes care of a missile-meteor collision

DETECT_MISSILE_COLLISION_END:
	POP R9
	POP R8
	POP R7
	POP R6
	POP R3
	POP R2
	POP R1
	RET


;********************************************************************************************************
;* treat_ship_meteor_collisions:
;
; Takes care of collisions between the ship and a meteor based on COLLISION_TYPE
;
; INPUT:	R8 - METEOR_TABLE
;		R9 - Meteor layout adress
;********************************************************************************************************

treat_ship_meteor_collisions:
	PUSH R1
	PUSH R6

	CALL determine_bad_good_collision	; Determines the COLLISION_TYPE
	MOV R1, [COLLISION_TYPE]
	
TREAT_SHIP_BAD_COLLISION:
	CMP R1, BAD_COLLISION
	JNZ TREAT_SHIP_GOOD_COLLISIONS		; Jumps if COLLISION_TYPE is not BAD_COLLISION
	MOV R6, FLAG_ON
	MOV [END_GAME_FLAG], R6			; Activates the END_GAME_FLAG
	JMP TREAT_SHIP_METEOR_COLLISIONS_END	; Jumps to end routine

TREAT_SHIP_GOOD_COLLISIONS:
	CALL explode_meteor			; Explodes meteor
	CALL display_increase			; Increases display
	MOV R1, MET_TIMER			; Stores the meteor spawn timer in R1
	MOV [MET_SPAWN_TIMER], R1		; Allows meteor to be created

TREAT_SHIP_METEOR_COLLISIONS_END:
	POP R6
	POP R1
	RET


;********************************************************************************************************
;* treat_missile_meteor_collisions:
;
; Takes care of collisions between a missile and a meteor based on COLLISION_TYPE
;
; INPUT:	R8 - METEOR_TABLE
;		R9 - Meteor layout adress
;********************************************************************************************************	

treat_missile_meteor_collisions:
	PUSH R1
	
	CALL eliminate_missile			; Eliminates missile
	MOV R1, [SELECT_SCREEN]			; Stores selected screen
	
	CALL determine_bad_good_collision	; Determines the COLLISION_TYPE
	MOV R1, [COLLISION_TYPE]
	
TREAT_MISSILE_BAD_COLLISION:
	CMP R1, BAD_COLLISION	
	JNZ TREAT_MISSILE_METEOR_COLLISIONS_END	; Jumps to end routine if COLLISION_TYPE is BAD_COLLISION
	CALL display_increase			; Increases display based on COLLISION_TYPE

TREAT_MISSILE_METEOR_COLLISIONS_END:
	CALL explode_meteor			; Explodes meteor
	MOV R1, MET_TIMER			; Stores the meteor spawn timer in R1
	MOV [MET_SPAWN_TIMER], R1		; Allows meteor to be created
	POP R1
	RET


;********************************************************************************************************
;* determine_bad_good_collision:
;
; Determines the collision type (good or bad meteor collision)
;********************************************************************************************************	

determine_bad_good_collision:
	PUSH R1
	PUSH R2
	PUSH R8
	
	MOV R1, [R8+WORD_VALUE] 		; Obtains meteor evolution table address
		
GOOD_TYPE_COLLISION:
	MOV R2, GOOD_METEOR_SHAPES		; Stores GOOD_METEOR_SHAPES evolution table address
	CMP R1, R2
	JLT BAD_TYPE_COLLISION			; Jumps if meteor evolution table address is lower than GOOD_METEOR_SHAPES evolution table address
	MOV R1, GOOD_COLLISION			
	MOV [COLLISION_TYPE], R1		; Sets COLLISION_TYPE to GOOD_COLLISION
	JMP DETERMINE_BAD_GOOD_COLLISION_END	; Jumps to end routine

BAD_TYPE_COLLISION:
	MOV R1, BAD_COLLISION
	MOV [COLLISION_TYPE], R1		; Sets COLLISION_TYPE to BAD_COLLISION

DETERMINE_BAD_GOOD_COLLISION_END:
	POP R8
	POP R2
	POP R1
	RET
	
	
;********************************************************************************************************
;* explode_meteor:
;
; Erases a meteor from the screen and draws the explosion layout
;
; INPUT:	R8 - METEOR_TABLE
;		R9 - Meteor layout adress
;********************************************************************************************************	

explode_meteor:
	PUSH R0
	PUSH R1
	PUSH R5
	PUSH R8
	PUSH R9
	MOV R0, [SELECT_SCREEN]		; Stores current screen
	
	MOV R1, 5
	MOV [SELECT_SCREEN], R1		; Selects screen 5
	CALL placement			; Stores meteor position line in R1 and column in R2
	MOV R9, EXPLODE_METEOR		; Stores EXPLODE_METEOR layout
	CALL draw_object		; Draws meteor explosion on screen
	
	MOV [SELECT_SCREEN], R0		; Selects previous selected screen
	MOV R9, [R8 + WORD_VALUE]	; Obtains meteor evolution table adress
	MOV R9, [R9]			; Obtains meteor layout adress
	CALL eliminate_meteor		; Erases meteor from screen and from METEOR_TABLE
	MOV R5, 4	
	MOV [PLAY_SOUND_VIDEO], R5	; Plays the meteor explosion sound
	
	POP R9
	POP R8
	POP R5
	POP R1
	POP R0
	RET
	
		
;********************************************************************************************************
;* eliminate_missile:
;
; Resets missile position to 0 and erases it from the screen
;*******************************************************************************************************

eliminate_missile:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R8
	PUSH R9
	
	MOV R0, [SELECT_SCREEN]		; Stores current selected screen
	MOV R1, 0
	MOV [SELECT_SCREEN], R1		; Selects screen number 0 (used to ship and missiles)
	MOV R8, MISSILE_PLACE
	MOV R9, DEF_MISSILE
	CALL placement			; Stores missile position line in R1 and column in R2
	CALL erase_object		; Erases missile from screen
	MOV R1, NO_VALUE			
	MOV [R8], R1			; Sets missile position to 0
	MOV [SELECT_SCREEN], R0		; Restores previous selected screen
	
	POP R9
	POP R8
	POP R2
	POP R1
	POP R0
	RET


;********************************************************************************************************
;* check_collisions:
;
; Checks if there was a collision between a meteor and ship or missile
;
; INPUT: 	R7 - Object position reference adress
;		R9 - Object layout
;*******************************************************************************************************

check_collisions:
	push R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	
	MOV R1, [R7]			; Stores object position in R1
	CMP R1, NO_VALUE		; Checks if object exists
	JZ CHECK_COLLISIONS_END		
	CALL obtain_reference_points	; Stores LEFT_DOWN in R1 and UP_DOWN in R2 (Object lower left and upper right corners position)
	MOV R3, [LEFT_DOWN_POSITION]	; Stores meteor LEFT_DOWN point in R3
	MOV R4, [RIGHT_UP_POSITION]	; Stores meteor RIGHT_UP point in R4

CHECK_LINE:
	MOV R5, R3 			; Stores meteor LEFT_DOWN point in R3		
	MOV R6, R2			; Stores meteor RIGHT_UP point in R6
	SHR R3, BYTE_VALUE		; Obtains meteor bottom line
	SHR R2, BYTE_VALUE		; Obtains object upper line
	CMP R3, R2
	JLT CHECK_COLLISIONS_END	; Ends routine if meteor botoom line is lower than object upper line

CHECK_LEFT_SIDE:
	MOV R0, LOWER_BYTE_MASK
	MOV R3, R5			; Stores meteor LEFT_DOWN position		
	MOV R2, R6			; Stores object RIGHT_UP position
	AND R5, R0			; Applies lower byte mask to obtain meteor left column
	AND R6, R0			; Applies lower byte mask to obtain object right column
	CMP R5, R6
	JGT CHECK_COLLISIONS_END 	; Ends routine if the meteor left column is further to the right than the object's right column

CHECK_RIGHT_SIDE:
	AND R4, R0			; Applies lower byte mask to obtain meteor right column
	AND R1, R0			; Applies lower byte mask to obtain object left column
	CMP R4, R1			
	JLT CHECK_COLLISIONS_END 	; Ends routine if the meteor right column is further to the left than the object's left column
	MOV R0, FLAG_ON
	MOV [EXISTS_COLLISION], R0	; Activates EXISTS_COLLISION (collision flag)

CHECK_COLLISIONS_END:
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
	RET
	

;********************************************************************************************************
;* obtain_reference_positions:
;
; Obtains the object position reference points:
; Lower left corner (LEFT_DOWN) and the upper right corner (RIGHT_UP)
;
; INPUT:	R1 - Object position reference (upper left corner)
;		R9 - Object layout adress (heigth, width and colours)
; OUPUT:	R1 - LEFT_DOWN point
;		R2 - RIGHT_UP point
;********************************************************************************************************
		
obtain_reference_points:			
	PUSH R3
	PUSH R4
	PUSH R9
	MOV R2, R1			; Stores object position reference in R2
	
OBTAIN_LEFT_DOWN_POINT:			
	MOV R3, [R9]			; Stores object height in R3
	ROR R1, BYTE_VALUE 		; Rotates line and column (move line to lower byte)
	ADD R1, R3			; Adds object height to object position reference
	SUB R1, 1			; Subtracts 1 to the value to obtain the object LEFT_DOWN point
	ROR R1, BYTE_VALUE 		; Rotates line and column again (move line to upper byte)

OBTAIN_RIGHT_UP_POINT:
	MOV R4, [R9+WORD_VALUE] 	; Stores object width in R4
	ADD R2, R4			; Adds object width to object position reference
	SUB R2, 1			; Subtracts 1 to the value to obtain the object RIGHT_UP point

OBTAIN_REFERENCE_POINTS_END:
	POP R9
	POP R4
	POP R3
	RET
	
	
;********************************************************************************************************
;* check_meteor_limits:
;
; Checks if a meteor has reached the lower limit of the screen (Line 31 - 1FH)
;
; INPUT:	R8 - METEOR_TABLE
; 		R9 - Meteor layout	
;********************************************************************************************************

check_meteor_limits:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R8
	CALL placement			; Stores meteor reference position (Line in R1 and Column in R2)
	MOV R3, MAX_METEOR_LINE		; Stores lower limit of the screen in R3
	CMP R1, R3			; Checks if the meteor has reached its maximum possible line value
	JNZ CHECK_METEOR_LIMITS_END	; Ends routine if last instruction is false
	CALL eliminate_meteor		; Eliminates the meteor from the METEOR_TABLE and the screen

CHECK_METEOR_LIMITS_END:
	POP R8
	POP R3
	POP R2
	POP R1
	POP R0
	RET
	
	
;********************************************************************************************************
;* eliminate_meteor:
;
; Eliminates a meteor from the table and subtracts 1 from the number of meteors
;
; INPUT:	R8 - METEOR_TABLE
; 		R9 - Meteor layout
;********************************************************************************************************
	
eliminate_meteor:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R8
	
	MOV R0, NO_VALUE
	CALL erase_object		; Eliminates meteor from the screen
	MOV [R8], R0			; Resets reference position of meteor to 0
	MOV [R8+WORD_VALUE], R0		; Resets the meteor evolution table to 0
	MOV R0, 1			
	MOV [R8+OBTAIN_STEPS], R0	; Resets number of steps to 1
	MOV R2, [METEOR_NUMBER]
	SUB R2, 1			; Subtracts 1 from the number of active meteors
	MOV [METEOR_NUMBER], R2		; Stores new value of active meteors 
	
	POP R8
	POP R2
	POP R1
	POP R0
	RET
		
	
;********************************************************************************************************
;* select_layout:
;
; Determines the meteor layout according to the steps it has taken
;
; INPUT: 	R8 - METEOR_TABLE
;********************************************************************************************************

select_layout:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R6
	PUSH R8
	PUSH R9
	MOV R6, R8			; Stores METEOR_TABLE in R6
	ADD R8, OBTAIN_STEPS		; Stores in R8 the steps adress
	ADD R6, WORD_VALUE		; Stores METEOR_TABLE adress that contains meteor evolution table in R6
	
CHECK_STEPS:
	MOV R0, [R8]			; Stores number of steps in R0
	MOV R1, MAX_STEPS	
	CMP R0, R1			; Compares number of steps with the maximum number of steps
	JGE SELECT_LAYOUT_END		; Jumps to end routine if the maximum number of steps hasnt been reached
	
	MOV R2, R0			; Stores number of steps in R2
	MOV R1, 3			
	MOD R2, R1			; Checks if the number of R2 is a multiple of 3
	JNZ ADD_STEPS			; Jumps to ADD_STEPS if the last intsruction is false
	 		
	MOV R9, [R6]			; Stores meteor_evolution_table in R9 
	ADD R9, WORD_VALUE		; Obtains next address in meteor_evolution_table
	MOV [R6], R9			; Stores the meteor evolution table in METEOR_TABLE
	
ADD_STEPS:
	ADD R0, 1			; Adds 1 to the number of steps
	MOV [R8], R0			; Stores te number of steps in the METEOR_TABLE
	
SELECT_LAYOUT_END:
	POP R9
	POP R8
	POP R6
	POP R2
	POP R1
	POP R0
	RET


;********************************************************************************************************
;* select_meteor:
;
; Selects new meteor from the METEOR_TABLE and changes the selected screen where the meteor should be
;
; INPUT: 	R8 - Meteor address in METEOR_TABLE
; OUTPUT: 	R8 - Next meteor adress in METEOR_TABLE
;********************************************************************************************************

select_meteor:
	PUSH R0
	MOV R0, NEXT_METEOR_VALUE
	ADD R8, R0			; Adds 6 to R8 (METEOR_TABLE), to obtain next meteor
	MOV R0, [SELECT_SCREEN]		; Stores number of selected screen in R0
	ADD R0, 1		
	MOV [SELECT_SCREEN], R0		; Selects next screen
	POP R0	
	RET


;***********************************************************************************************************************
;* display_clock_decrease:
;
; Decreases the value that the display shows by DISPLAY_DECREASE (-5) according to the display clock
;***********************************************************************************************************************

display_clock_decrease:
	PUSH R1	
	MOV R1, [ENERGY_INTERRUPTION_FLAG]
	CMP R1, FLAG_ON				; Checks if ENERGY_INTERRUPTION_FLAG is activated
	JNZ DISPLAY_CLOCK_DECREASE_END		; Ends routine if the flag isn't activated
	CALL display_decrease			; Decreases display value by 5
	MOV R1, FLAG_OFF		
	MOV [ENERGY_INTERRUPTION_FLAG], R1 	; Deactivates ENERGY_INTERRUPTION_FLAG

DISPLAY_CLOCK_DECREASE_END:	
	POP R1
	RET


;***********************************************************************************************************************
;* display_increase:
;
; Increases the value that the display shows by DISPLAY_INCREASE (10 or 15) 
;***********************************************************************************************************************

display_increase:
	PUSH R0
	PUSH R1
	MOV R0, GOOD_COLLISION_INCREASE		; Stores in R0, the display increase value of a good meteor (15)
	MOV R1, [COLLISION_TYPE]		; Stores in R1 the type of the collision
	CMP R1, GOOD_COLLISION
	JZ DISPLAY_INCREASE_END			; Jumps to DISPLAY_INCREASE_END if the collision type was good
	MOV R0, BAD_COLLISION_INCREASE		; Stores the display increase value of a bad meteor (10)

DISPLAY_INCREASE_END:
	MOV [DISPLAY_VARIATION], R0		; Stores in memory the variation that was previously determined
	CALL mov_display			; Changes display value
	POP R1
	POP R0
	RET
	

;***********************************************************************************************************************
;* display_decrease:
;
; Decreases the value that the display shows by DISPLAY_DECREASE (-5) 
;***********************************************************************************************************************

display_decrease:
	PUSH R1	
	MOV R1, DISPLAY_DECREASE		
	MOV [DISPLAY_VARIATION], R1	; Changes DISPLAY_VARIATION value to DISPLAY_DECREASE
	CALL mov_display		; Changes the value that the display shows

DISPLAY_DECREASE_END:
	POP R1
	RET
		

;***********************************************************************************************************************
;* mov_display:
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
	MOV [DISPLAY_VALUE], R1		; Stores in memory value of display (R1)
	CALL convert_hex_to_dec		; Converts hexadecimal value of display to decimal (and stores it in R1)
	CMP R1, LOWER_BOUND
	JNZ DISPLAY_END			; Ends routine if the lower limit hasn't been reached (ship has energy)
	MOV R0, FLAG_ON
	MOV [END_GAME_FLAG], R0		; Activates END_GAME_FLAG to end the game later (ship has run out of energy)
	
DISPLAY_END:
	MOV [DISPLAY], R1		; Sets display to correspondant decimal value
	POP R7
	POP R2
	POP R1
	POP R0
	RET
	

;***********************************************************************************************************************************
;* test_display_limits:
;
; Changes the display value to either 100 or 0, if the addition of R7 to the display value exceeds the display limits
; INPUT:	R1 - Value that the display currently shows
;	 	R7 - Display variation
; OUTPUT:	R1 - New display value
;***********************************************************************************************************************************	

test_display_limits:	
	PUSH R0		
	CMP R7, DISPLAY_DECREASE
	JZ LOWER_LIMIT			; Jumps to LOWER_LIMIT if the display variation value is DISPLAY_DECREASE
	
UPPER_LIMIT:
	MOV R0, UPPER_BOUND
	MOV R1, [DISPLAY_VALUE]
	ADD R1, R7			; Adds display variation (10 or 15) to R1 (DISPLAY_VALUE)
	CMP R1, R0
	JLT TEST_DISPLAY_LIMITS_END	; Jumps if DISPLAY_VALUE is lower then upper limit (limit hasn't been reached)
	MOV R1, R0			; Sets DISPLAY_VALUE to UPPER_BOUND (limit reached)
	JMP TEST_DISPLAY_LIMITS_END	; Ends routine

LOWER_LIMIT:
	MOV R0, LOWER_BOUND	
	MOV R1, [DISPLAY_VALUE]
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
; Converts hexadecimal values to decimal to show in display
;
; INPUT: 	R1 - Hexadecimal value of DISPLAY
; OUTPUT: 	R1 - Decimal value of DISPLAY
;***********************************************************************************************************************

convert_hex_to_dec:
	PUSH R2
	PUSH R3
	MOV  R3, UPPER_BOUND		; Stores the max display value (64H) in R3
	CMP R1, R3			; Checks if hexadecimal value to be converted has reached UPPER_BOUND
	JZ UPPER_BOUND_REACHED		; Jumps if previous condition is true
	MOV  R3, HEXTODEC_CONST		; Stores the hexadecimal equivalent to 10 decimal in R3
	MOV  R2, R1			; Saves the display value in R2
	DIV  R1, R3 			; Stores the tens digit of the display value in R1
	MOD  R2, R3 			; Stores the units digit of the display value in R2
	SHL  R1, 4			; Moves the tens value of the display value to the next hexadecimal digit
	ADD  R1, R2			; Adds the units digit to R1
	JMP CONVERT_HEX_TO_DEC_END

UPPER_BOUND_REACHED:
	MOV R1, INITIAL_DISPLAY_VALUE	; Treats the specific case of the input being 64H (Stores "decimal" value 100)

CONVERT_HEX_TO_DEC_END:
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
	MOV R3, NO_VALUE			
	MOV [R1], R3			; Changes CHANGE_COL to 0 (ship won't move left)

TEST_RIGHT:
	MOV R3, MAX_COLUMN		; Stores the maximum screen column 
	ADD R2, 4			; Width is 4, so the last pixel is 4 pixels away from position reference
	CMP R3, R2			; Checks if obejct has reached MAX_COLUMN
	JNZ TEST_END			; Ends routine if it hasn't
	MOV R3, NO_VALUE
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
	ADD R9, WORD_VALUE		; Adds 2 to get object width
	MOV R3, [R9]			; Stores object width
	ADD R9, WORD_VALUE		; Gets first pixel colour to use

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
	ADD R9, WORD_VALUE		; Gets next colour (R9 is object layout)
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
	MOV R2, NO_VALUE		; Sets counter back to 0

ACTIVATE_FLAG:				; Activates flag so the object can move
	MOV R3, 1			
	MOV [DELAY_FLAG], R3
	JMP END_DELAY

DEACTIVATE_FLAG:			; Deactivates flag to prevent object from moving
	MOV R3, FLAG_OFF
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
;* end_game_menu
;
; Enters game over cycle when the player loses the game or when the button END is pressed
;*****************************************************************************************	

end_game_menu:
	PUSH R0	
	PUSH R1
	PUSH R2
	MOV R2, 3
	MOV [END_ALL_SOUND_VIDEO], R2	; Stops all videos and sounds playing
	MOV [DEL_ALL_SCREENS], R2	; Deletes all pixels from all the screens
	CALL determine_ending_video
	MOV [START_SOUND_VIDEO], R2	; Plays end_game video 
	
END_GAME_CYCLE:
	CALL keypad
	MOV R1, [BUTTON]
	MOV R0, START
	CMP R1, R0			; Checks if button pressed is START
	JNZ END_GAME_CYCLE		; Leaves cycle if the previous condition is true
	
	
END_GAME_RETURN:
	CALL reset_game			; Resets all values to original conditions
	CALL start_game			; Starts new game
	POP R2
	POP R1
	POP R0
	RET

;*****************************************************************************************
;* determine_ending_video
;
; Determines the type of game over ( game over by energy , collision or button pressed)
;*****************************************************************************************

determine_ending_video:
	PUSH R0
	MOV R0, [DISPLAY_VALUE]
	CMP R0, LOWER_BOUND
	JZ ENERGY_END_SCREEN			; Jumps if the game was lost because of energy
	MOV R2, 3				; Stores the "lost by collison" video
	JMP DETERMINE_ENDING_VIDEO_RETURN

ENERGY_END_SCREEN:
	MOV R2, 5				; Stores the "lost by energy" video

DETERMINE_ENDING_VIDEO_RETURN:
	POP R0
	RET

	
;*****************************************************************************************
;* reset_game 
;
; Sets the game to the original conditions
;*****************************************************************************************

reset_game:
	PUSH R0
	PUSH R1
	MOV R0, LINE			; Stores ship initial position reference line
	MOV R1, COLUMN			; Stores ship initial position reference column
	SHL R0, BYTE_VALUE		; Shifts ship line one byte to the left
	OR R0, R1			; Adds to R0 the ship column
	MOV [SHIP_PLACE], R0		; Stores in memory the initial position of the ship 
	CALL reset_meteor_table 	; Resets all meteor table values
	CALL reset_flags		; Resets all game flags
	MOV R0, 0
	MOV [MISSILE_PLACE], R0		; Allows a new missile to be shot when shoot_missile is called
	POP R0
	POP R1
	RET


;*****************************************************************************************
;* reset_meteor_table: 
;
; Restores all of the meteor table values to the original ones
;*****************************************************************************************

reset_meteor_table:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R8
	MOV R1, MAXIMUM_METEOR_NUMBER
	MOV R0, 0
	MOV R2, 1
	MOV R8, METEOR_TABLE		; Stores METEOR_TABLE adress

CLEAN_TABLE:
	MOV [R8], R0			; Resets meteor position to 0
	MOV [R8+WORD_VALUE], R0		; Resets meteor layout address to 0
	MOV [R8+OBTAIN_STEPS], R2	; Resets meteor steps to 1
	ADD R8, NEXT_METEOR_VALUE	; Stores in R8 the next meteor position
	SUB R1, 1			; Subtracts number of meteors by 1
	JNZ CLEAN_TABLE			; Repeats cycle if the number of meteors is not 0

RESET_METEOR_TABLE_END:
	MOV [METEOR_NUMBER], R1		; Changes METEOR_NUMBER to 0
	POP R8
	POP R2
	POP R1
	POP R0
	RET
	
	
;*****************************************************************************************
;* reset_flags: 
;
; Resets all game flags, setting them to 0
;*****************************************************************************************

reset_flags:
	PUSH R0
	MOV R0, FLAG_OFF
	MOV [DELAY_COUNTER], R0
	MOV [DELAY_FLAG], R0
	MOV [EXISTS_COLLISION], R0
	MOV [END_GAME_FLAG], R0
	POP R0
	RET


;*****************************************************************************************
;* INTERRUPTIONS
;
; Activates interruptions flags according to the clocks 
;*****************************************************************************************

meteor_interruption:
	PUSH R0
	MOV R0, FLAG_ON
	MOV [METEOR_INTERRUPTION_FLAG], R0	; Activates meteor interruption flag
	POP R0
	RFE 
	
missile_interruption:
	PUSH R0
	MOV R0, FLAG_ON
	MOV [MISSILE_INTERRUPTION_FLAG], R0	; Activates missile interruption flag
	POP R0
	RFE 

energy_interruption:
	PUSH R0
	MOV R0, FLAG_ON
	MOV [ENERGY_INTERRUPTION_FLAG], R0	; Activates energy interruption flag
	POP R0
	RFE
