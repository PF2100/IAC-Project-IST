
;****KEYPAD****************************************************************************

INJECTED_LINE 	EQU 8			; Initial keypad line (fourth)
KEY_LIN 	EQU 0C000H		; Keyboard Rows
KEY_COL 	EQU 0E000H		; Keyboard Columns
KEY_MASK	EQU 0FH			; Isolates the lower nibble from the output of the keypad
BUTTON		EQU 0900H   		; Stores the pressed button
LAST_BUTTON 	EQU 0902H		; Stores the last pressed button (prior to the current)

;****DISPLAY****************************************************************************

DISPLAY		EQU 0A000H		; Display adress
UPPER_BOUND	EQU 0100H		; Display upper bound (energy)
LOWER_BOUND	EQU 0000H		; Display lower bound (energy)
DISPLAY_TIMER 	EQU 0100H		; Display delay between pressing button and changing energy value

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
	BYTE LINE, COLUMN		; First byte of the word stores the line and the second one the column

METEOR_PLACE:
	BYTE METEOR_LINE, METEOR_COLUMN	; First byte of the word stores the line and the second one the column
	
CHANGE_COL:				; Stores column variation of the position of the object
	WORD 0H
	
CHANGE_LINE:				; Stores line variation of the position of the object
	WORD 0H
	
PEN_MODE:				; Flag used to either draw or erase pixels by draw_object and erase_object
	WORD 0H
	
DELAY_COUNTER:				; Counter until MOV_TIMER is reached and ship moves
	WORD 0H

DISPLAY_VALUE:
	WORD 100H			; Energy display initial value
	
FLAG0:
	WORD 0H
	

;*************************************************************************************************************************

PLACE 0H


INITIALIZER:
	MOV SP, STACK_INIT
	MOV R0, 0
	MOV [DEL_WARNING], R0		; Deletes no background warning (R0 value is irrelevant)
	MOV [DEL_SCREEN], R0		; Deletes all drawn pixels (R0 value is irrelevant)
    	MOV [SELECT_BACKGROUND], R0	; Selects background
    	MOV R0, [DISPLAY_VALUE]		; Stores energy display initial value in R0
	MOV [DISPLAY], R0		; Initializes display


BUILD_SHIP:
	MOV R8, SHIP_PLACE		; Stores line in the first byte of R8 and column on the second one
	MOV R9, DEF_SHIP 		; Stores ship layout
	CALL placement			; Stores the ship position reference, R1 stores line and R2 stores column
	CALL erase_object		; Deletes ship from screen
	CALL draw_object		; Draws ship
	
BUILD_METEOR:
	MOV R8, METEOR_PLACE		; Stores line in the first byte of R8 and column on the second one
	MOV R9, DEF_METEOR		; Stores meteor layout
	CALL placement			; Stores the meteor position reference, R1 stores line and R2 stores column
	CALL erase_object		; Deletes meteor from screen
	CALL draw_object		; Draws meteor

MAIN_CYCLE:
	CALL keypad
	CALL commands
	CALL mov_display
	CALL mov_met
	CALL mov_ship
	JMP MAIN_CYCLE

commands:
	RET
	

;********************************************************************************************************
;*SHIP MOVEMENTS
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
	MOV R10, [FLAG0]
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
;*METEOR MOVEMENTS
;********************************************************************************************************

mov_met:
	PUSH R0
	PUSH R7
	PUSH R8 
	PUSH R9
	MOV R0, [BUTTON] 		; Moves button value to R0
	CMP R0, MET_DOWN
	JNZ MET_END			; Ends routine if the pressed button isn't DOWN
	CALL same_button		; Checks if the the button pressed is the last pressed button (prior to the current)
	CMP R0, R1
	JZ MET_END			; Ends routine if previous instruction is true
	MOV R8, METEOR_PLACE		; Stores meteor reference position
	MOV R9, DEF_METEOR		; Stores meteor layout
	
MOVE_MET:
	CALL placement			; Stores meteor reference position (Line in R1 and Column in R2)
	CALL erase_object		; Deletes object from current position
	ADD R1, 1			; Adds line variation to the new reference position of meteor
	MOVB [R8], R1			; Changes line position of the meteor
	CALL draw_object		; Draws object in new position
	MOV R1, 0
	MOV [PLAY_SOUND_VIDEO], R1
	
MET_END:				; Restores stack values in the registers
	POP R9
	POP R8
	POP R7
	POP R0
	RET
	

;***********************************************************************************************************************
;*DISPLAY MANAGEMENT
;***********************************************************************************************************************

mov_display:
	PUSH R0	
	PUSH R1
	PUSH R2
	PUSH R7
	MOV R0, [BUTTON] 		; Stores pressed button in R0
	MOV R7, -5			; Sets energy variation to -5
	CMP R0,	DIS_DOWN 		; Compares if the pressed button is DIS_DOWN button
	JZ CHECK_DIS_DELAY		; Jumps if button is DIS_DOWN
	MOV R7, 5			; Sets energy variation to 5
	CMP R0, DIS_UP			; Compares if the pressed button is DIS_UP button
	JZ CHECK_DIS_DELAY		; Jumps if button is DIS_UP
	JMP DISPLAY_END			; Jumps to the end of the routine if button is neither DIS_DOWN nor DIS_UP
	
CHECK_DIS_DELAY:
	CALL same_button
	CMP R0,R1			
	JZ DISPLAY_END			; Jumps to the end of the routine if DELAY_COUNTER is neither 0 nor MOV_TIMER
	
CHANGE_DISPLAY:
	CALL test_display_limits	; Checks if the energy has reached display limits (100 upper, 0 lower)
	;CALL convert_hex_to_dec
	MOV [DISPLAY], R1		; Sets display to R1
	MOV [DISPLAY_VALUE], R1		; Stores new display value in memory
	
DISPLAY_END:
	POP R7
	POP R2
	POP R1
	POP R0
	RET
	

;***********************************************************************************************************************
;*TESTS DISPLAY LIMITS
;***********************************************************************************************************************	

test_display_limits:	
	PUSH R0
	CMP R7, -5			; Checks if display variation is -5
	JZ LOWER_LIMIT			; Jumps if DIS_DOWN is pressed
	
UPPER_LIMIT:
	MOV R0, UPPER_BOUND
	MOV R1, [DISPLAY_VALUE]
	ADD R1, R7			; Adds display variation (5) to R1 (DISPLAY_VALUE)
	CMP R1, R0
	JLT test_display_limits_end	; Jumps if DISPLAY_VALUE is lower then upper limit (limit hasn't been reached)
	MOV R1, R0			; Sets DISPLAY_VALUE to UPPER_BOUND (limit reached)
	JMP test_display_limits_end	; Ends routine

LOWER_LIMIT:
	MOV R0, LOWER_BOUND
	MOV R1, [DISPLAY_VALUE]		
	ADD R1, R7			; Adds display variation (-5) to R1 (DISPLAY_VALUE)
	CMP R1, R0			
	JGT test_display_limits_end	; Jumps if DISPLAY_VALUE is greater then lower limit (limit hasn't been reached)
	MOV R1, R0			; Sets DISPLAY_VALUE to LOWER_BOUND (limit reached)
	
test_display_limits_end:
	POP R0
	RET


;***********************************************************************************************************************
;*TESTS SCREEN LIMITS
;***********************************************************************************************************************

test_ship_limits:
	PUSH R1
	PUSH R2
	PUSH R3
	MOV R1, CHANGE_COL		; Stores CHANGE_COL adress
	MOV R3, [R1]			; Stores column variation of object in R3
	CMP R3, 0
	JGT test_right			; Jumps if CHANGE_COL is positive (move right)
	
test_left:
	MOV R3, MIN_COLUMN		; Stores the minimium screen column 
	CMP R3, R2			; Checks if obejct has reached MIN_COLUMN
	JNZ test_end			; Ends routine if it hasn't
	MOV R3, 0			
	MOV [R1], R3			; Changes CHANGE_COL to 0 (ship won't move left)

test_right:
	MOV R3, MAX_COLUMN		; Stores the maximum screen column 
	ADD R2, 4			; Width is 4, so the last pixel is 4 pixels away from position reference
	CMP R3, R2			; Checks if obejct has reached MAX_COLUMN
	JNZ test_end			; Ends routine if it hasn't
	MOV R3, 0
	MOV [R1], R3			; Changes CHANGE_COL to 0 (ship won't move right)

test_end:				; Restores stack values in the registers
	POP R3
	POP R2
	POP R1
	RET
	

;*****************************************************************************************
;*ERASE OBJECTS
;*****************************************************************************************

erase_object:
	PUSH R6
	MOV R6, ERASER			; Loads ERASER flag to R6
	MOV [PEN_MODE], R6		; Sets PEN_MODE to ERASER
	CALL write_object		; Writes object in eraser mode (deletes it)
	POP R6
	RET


;****************************************************************************************
;*DRAW OBJECTS
;****************************************************************************************

draw_object:
	PUSH R6
	MOV R6, PEN			; Loads PEN flag to R6
	MOV [PEN_MODE], R6 		; Sets PEN_MODE to PEN
	CALL write_object		; Writes object in pen mode (draws it)
	POP R6
	RET

	
;******************************************************************************************
;*SHIP POSITION REFERENCE
;******************************************************************************************	

placement:
	PUSH R8
	MOVB R1, [R8]			; R1 stores line
	ADD R8, 1			; Gets column adress (second byte of R8)
	MOVB R2, [R8]			; R2 stores column
	POP R8
	RET
	
	
;*******************************************************************************************	
;*WRITE OBJECTS
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

write_lines:				; Writes a line of pixels
	CALL write_line			; Writes the line of pixels that refer to the value of R1
	ADD R1, 1			; Selects next line to write		
	SUB R0, 1			; Decreases the remaining object height to write (-1)
	JZ end_write_lines		; Ends routine if remaining object height to write is 0 (object is written)
	JMP write_lines			; Repeats write_lines if there are more lines to write
	
end_write_lines:
	POP R9				; Returns object layout table
	POP R3
	POP R1				; Returns object position line
	POP R0
	RET


;*********************************************************************************************
;*WRITE LINE
;*********************************************************************************************	

write_line:      
	PUSH R3				; Stores width
	PUSH R2				; Stores current column in stack
	PUSH R5				; Stores pixel colour in stack
	
write_pixels_line:				
	MOV R5, [R9]			; Stores pixel colour in R5
	CALL pick_colour		; Changes colour to 0 if ERASER mode is activated
	CALL write_pixel		; Writes pixel
	ADD R9, 2			; Gets next colour (R9 is object layout)
    	ADD R2, 1          	    	; Gets next column
    	SUB R3, 1			; Decreases number of remaining columns to write (-1)
   	JNZ write_pixels_line      	; Repeats until all width of the object is written (until R3 is 0)
  	POP R5							
   	POP R2							
   	POP R3
   	RET


;***************************************************************************************************
;*WRITE PIXEL AUXILIAR ROUTINES
;***************************************************************************************************
    
pick_colour:
	PUSH R6
	MOV R6, [PEN_MODE]
	CMP R6,	ERASER 			; Checks PEN_MODE flag
	JNZ end_colour			; If PEN mode is selected, pixel colour remains the same
	MOV R5, ERASER			; If ERASER mode is activated, colour 0 is selected

end_colour:
	POP R6
	RET				; Ends routine
    
write_pixel:
	MOV [DEF_LINE], R1		; Selects line to write
	MOV [DEF_COL], R2		; Selects column to write
	MOV [DEF_PIXEL], R5		; Changes pixel colour in line and colum selected
	RET
	

;**************************************************************************************
;*KEYPAD: SEARCHES FOR A PRESSED BUTTON
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
;*KEYPAD: DETERMINES WHICH BUTTON WAS PRESSED
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
;*KEYPAD: PRESSED BUTTON CALCULATOR (R2)
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
	PUSH R1
	PUSH R2	
	PUSH R3
	PUSH R10
	CALL same_button;
	CMP R0, R1
	JNZ reset
	MOV R2, [DELAY_COUNTER]
	ADD R2, 1
	MOV R1, R10
	CMP R2, R1
	JNZ deactivate_flag

reset:
	MOV R2, 0

activate_flag:
	MOV R3, 1
	MOV [FLAG0], R3
	JMP end_delay

deactivate_flag:
	MOV R3, 0
	MOV [FLAG0], R3
	
end_delay:
	MOV [DELAY_COUNTER], R2
	POP R10
	POP R3
	POP R2
	POP R1
	RET




;*****************************************************************************************
;*CHECKS IF THE LAST BUTTON IS THE SAME AS THE CURRENT PRESSED ONE
;*****************************************************************************************

same_button:
	MOV R0, [BUTTON]		; Stores current pressed button in R0
	MOV R1, [LAST_BUTTON]		; Stores previous pressed button in R1
	RET

