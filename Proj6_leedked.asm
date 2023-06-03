TITLE Project 6    (Proj6_leedked.asm)

; Author: Doug Leedke
; Last Modified: 6/3/2023
; OSU email address: leedked@oregonstate.edu
; Course number/section:   CS271 Section 403
; Project Number: 6               Due Date: 6/11/2023
; Description: This program will implement and test two macros & two procedures for string processing using string
; primitive instructions.  One will display a prompt and get the a string (entered by the user) and one will display the string.
; The program will then use the 2 procedures to read in 10 valid integers from the user, store them in an array, and display
; the integers, their sum, and their truncated average to the command line.

INCLUDE Irvine32.inc

; ---------- Macros ----------

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Gets a string from the user's keyboard input.
;
; Preconditions:
;	EAX: Do not use as argument
;	ECX: Do not use as argument
;	EDX: Do not use as argument
;
; Postconditions: N/A
;
; Receives:
;	prompt: The address offset of the string that will be display as the prompt.
;	maxLength: Value representing the maximum length of input allowed
;	userInput: Reference to an array that will hold the entered string
;	bytesRead: Reference to where the number of bytes read will be stored.	
;
; Returns:
;	userInput: Returns the user's entered string.
;	bytesRead: Returns the number of bytes read from the user's input.
;
; ---------------------------------------------------------------------------------
mGetString	MACRO promptStr, maxLength, userInput, bytesRead
	; Preserving registers
	PUSH EAX				
	PUSH ECX				
	PUSH EDX

	mDisplayString	promptStr			; Displaying provided prompt string

	MOV		EDX, userInput				; Pointing EDX to userInput buffer
	MOV		ECX, SIZEOF	maxLength		; Specifying the max length
	CALL	ReadString					; Getting the string
	MOV		bytesRead,	EAX				; Moving EAX (number of bytes read) into bytesRead
	
	; Restoring registers
	POP EDX
	POP ECX
	POP EAX
ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Displays the string at the provided offset.
;
; Preconditions:
;	EDX: Do not use as argument
;
; Postconditions: N/A
;
; Receives:
;	displayStr: The address offset of the string that is to be displayed.
;	
; Returns: N/A
; ---------------------------------------------------------------------------------
mDisplayString MACRO displayStr
	PUSH	EDX				; Preserve EDX

	MOV		EDX, displayStr
	CALL	WriteString

	POP		EDX				; Restore EDX
ENDM

; ---------- Constants ---------
MAX_INPUT_SIZE = 13			; Gives room for the sign, 10 digits, and 1 extra byte to see if user's number is too big
MAX_NUM_LENGTH = 10

.data

	; --------- Title & Prompt Variables ---------
	programTitle		BYTE	"Project 6 - Designing Low-level I/O Procedures - By Doug Leedke",13,10,10,0
	instructionString1	BYTE	"Please provide 10 signed decimal integers.",13,10,0
	instructionString2	BYTE	"Each number needs to be small enough to fit inside a 32 bit register.",13,10,
								"After you have finished inputting the raw numbers I will display a list of the integers, ",13,10,
								"their sum, and their average value.",13,10,10,0
	getStringPrompt		BYTE	"Please enter a signed number: ",0

	; ---------- Input Variables ----------
	numInput			BYTE	MAX_INPUT_SIZE DUP(?)						; This will hold the user's currently entered number
	errorMsg			BYTE	"ERROR: You did not enter a signed number or your number was too big.",13,10,0



; (insert variable definitions here)

.code
main PROC

	; Display Program Title	& Instructions
	mDisplayString		OFFSET programTitle									; "Project 6 - Designing Low-level I/O Procedures - By Doug Leedke"
	mDisplayString		OFFSET instructionString1							; "Please provide 10 signed decimal integers."
	mDisplayString		OFFSET instructionString2							; "Each number needs to be small enough to fit inside a 32 bit register."
																			; "After you have finished inputting the raw numbers I will display a list of the 
																			;  integers, their sum, and their average value."


	PUSH	OFFSET	getStringPrompt
	PUSH	OFFSET	errorMsg
	PUSH	OFFSET	numInput
	CALL	ReadVal

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; TODO: NEED DESCRIPTION
;
; Preconditions: N/A
;
; Postconditions: N/A
;
; Receives:
;	promptString [EBP + 16]: Reference to the prompStr address, must be passed on the call stack
;	errorMessage [EBP + 12]: Reference to the error message that will be displayed for bad input, must be passed on the call stack
;	numInput [EBP + 8]: Reference to a variable that will hold the user's entered value, must be passed on the call stack
;	
; Returns:
;	numInput: Returns the user's entered value at the given reference.
; ---------------------------------------------------------------------------------
ReadVal PROC

	PUSH	EBP					; Preserve EBP
	MOV		EBP, ESP			; Assign static stack-frame pointer
	PUSH	EBX					; Preserve EBX

_Input:
	; Getting the user's input 
	; numInput [EBP + 8] will be modified to contain it
	mGetString	[EBP + 16], MAX_INPUT_SIZE, [EBP + 8], EBX

	; First check if string is too short
	CMP		EBX, 0
	JE		_InvalidInput

	MOV		ECX, EBX			; Setting up loop
	MOV		ESI, [EBP + 8]		; Moving the input string into ESI

; TODO: UNDER CONSTRUCTION
_Loop:
		LODSB
		 MOV AH, AL
	LOOP _Loop

	POP		EBX					; Restore EBX
	POP		EBP					; Restore EBP
	RET		12					; De-reference the passed offsets 12 bytes

_InvalidInput:

	mDisplayString [EBP + 12]
	JMP _Input

ReadVal ENDP


WriteVal PROC



WriteVal ENDP

END main
