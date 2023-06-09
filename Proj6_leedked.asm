TITLE Project 6    (Proj6_leedked.asm)

; Author: Doug Leedke
; Last Modified: 6/9/2023
; OSU email address: leedked@oregonstate.edu
; Course number/section:   CS271 Section 403
; Project Number: 6               Due Date: 6/11/2023
; Description: This program will implement and test two macros & two procedures for string processing using string
; primitive instructions.  One will display a prompt and get the string (entered by the user) and one will display the string.
; The program will then use the 2 procedures to read in 10 valid integers from the user, store them in an array, and display
; the integers, their sum, and their truncated average to the command line.

INCLUDE Irvine32.inc

; ---------- Macros ----------

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Prompts the user to enter a string and then retrieves the string from the user's keyboard input.
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
MAX_INPUT_SIZE = 13			; Gives room for the sign, 10 digits, end line, and 1 extra byte to see if user's number has too many digits
MAX_NUM_LENGTH = 10			; The maximum number of digits
MAX_NUM_LENGTH_SIGNED = 11	; The maximum number of digits if there is a sign
NUM_ENTRIES = 10			; Number of entries that will be requested of the user

MAX_SIZE_SDWORD = 2147483647		; Max size for a positive number
MAX_SIZE_SDWORD_NEG = 2147483648	; Max size for a negative number

ASCII_MINUS = 45			; '-'
ASCII_PLUS = 43				; '+' 
ASCII_NUM_LO = 48			; '0'
ASCII_NUM_HI = 57			; '9'

.data

	; --------- Title & Prompt Variables ---------
	programTitle		BYTE	"Project 6 - Designing Low-level I/O Procedures - By Doug Leedke",13,10,10,0
	instructionStr1		BYTE	"Please provide 10 signed decimal integers.",13,10,0
	instructionStr2		BYTE	"Each number needs to be small enough to fit inside a 32 bit register.",13,10,
								"After you have finished inputting the raw numbers I will display a list of the integers, ",13,10,
								"their sum, and their average value.",13,10,10,0
	getStringPrompt		BYTE	"Please enter a signed number: ",0
	errorMsg			BYTE	"ERROR: You did not enter a signed number or your number was too big.",13,10,0
	errorMsgPrompt		BYTE	"Please try again: ",0
	enteredStr			BYTE	"You entered the following numbers: ",13,10,0
	sumStr				BYTE	"The sum of these numbers is: ",0
	avgStr				BYTE	"The truncated average is: ",0
	goodbyeStr			BYTE	10,"Thanks for playing!",13,10,0
	spaceStr			BYTE	" ",0
	commaStr			BYTE	",",0

	; ---------- Input Variables ----------
	numInput			BYTE	MAX_INPUT_SIZE DUP(?)			; This will hold the user's currently entered number as a string of ASCII
	numOutput			SDWORD	0								; This will hold the user's number converted to a SDWORD
	numArray			SDWORD	NUM_ENTRIES DUP(0)				; This will hold each of the user's entries as an SDWORD decimal

	; --------- Result Variables ----------
	numsSum				SDWORD	0
	numsAvg				SDWORD	0

.code
main PROC

	; Display Program Title	& Instructions
	mDisplayString		OFFSET programTitle									; "Project 6 - Designing Low-level I/O Procedures - By Doug Leedke"
	mDisplayString		OFFSET instructionStr1								; "Please provide 10 signed decimal integers."
	mDisplayString		OFFSET instructionStr2								; "Each number needs to be small enough to fit inside a 32 bit register."
																			; "After you have finished inputting the raw numbers I will display a list of the 
																			;  integers, their sum, and their average value."

	; Setting up the first loop to read in the user's input
	MOV		ECX, NUM_ENTRIES
	MOV		ESI, OFFSET numArray

_Loop1:

	; Reading and validating the user's input
	PUSH	OFFSET	getStringPrompt
	PUSH	OFFSET	errorMsgPrompt
	PUSH	OFFSET	errorMsg
	PUSH	OFFSET	numInput
	PUSH	OFFSET	numOutput
	CALL	ReadVal

	; Moving the value in numOutput into our array
	MOV		EAX, numOutput
	MOV		[ESI], EAX
	ADD		ESI, TYPE numArray

	Loop	_Loop1

	CALL	CrLF
	mDisplayString		OFFSET	enteredStr									;"You entered the following numbers: "

	; Resetting the loop counter to display the values
	MOV		ECX, NUM_ENTRIES
	MOV		ESI, OFFSET numArray

_Loop2:
	
	; Displaying each number as an ascii string using WriteVal
	PUSH	OFFSET numInput
	PUSH	[ESI]															
	CALL	WriteVal

	; Determining if we need a comma or not
	CMP		ECX, 1
	JE		_NoComma														; No Comma on the last iteration
	mDisplayString		OFFSET commaStr

	_NoComma:
	mDisplayString		OFFSET spaceStr

	; Increasing the cumulative sum by the value of the current number
	MOV		EAX, [ESI]
	ADD		numsSum, EAX 
	ADD		ESI, TYPE numArray
	Loop	_Loop2

	CALL	CrLF

	; Displaying the cumulative sum
	mDisplayString		OFFSET sumStr										;"The sum of these numbers is: "
	
	PUSH	OFFSET numInput
	PUSH	numsSum
	CALL	WriteVal

	CALL	CrLF

	; Displaying the truncated average
	mDisplayString		OFFSET avgStr										;"The truncated average is: "
	
	; Dividing total sum by number of entries to get average
	; must do signed division to account for negatives
	MOV		EAX, numsSum
	MOV		EDX, 0	
	MOV		EBX, NUM_ENTRIES
	CDQ																		
	IDIV	EBX															; Average now in EAX
	MOV		numsAvg, EAX

	PUSH	OFFSET numInput
	PUSH	numsAvg
	CALL	WriteVal

	; Goodbye message
	CALL CrLF
	mDisplayString		OFFSET goodbyeStr									;"Thanks for playing!"

	Invoke ExitProcess,0													; Exit
main ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Reads in the user's input in an ASCII string to the provided input array and outputs
; that string into the provided output reference as an SDWORD.  Handles signed integers
; between -2147483648 and 2147483647.  If the input is invalid or out of those bounds
; will reprompt the user with the provided error message.
;
; Preconditions: N/A
;
; Postconditions: N/A
;
; Receives:
;	promptString [EBP + 24]: Reference to the prompt string address, must be passed on the call stack
;	errorMessagePrompt [EBP + 20]:	Reference to the error message prompt used after incorrect input, must be passed to the call stack
;	errorMessage [EBP + 16]: Reference to the error message that will be displayed for bad input, must be passed on the call stack
;	numInput [EBP + 12]: Reference to a variable that will hold the user's keyboard input as a string, must be passed on the call stack
;	numOutput [EBP + 8]: Reference to SDWORD variable that will hold the user's entered value, must be passed on the call stack
;	
; Returns:
;	numOutput: Returns the user's entered value at the given reference.
; ---------------------------------------------------------------------------------
ReadVal PROC

	PUSH	EBP					; Preserve EBP
	MOV		EBP, ESP			; Assign static stack-frame pointer

	; Preserve registers
	PUSH	EAX					
	PUSH	EBX
	PUSH	ECX
	PUSH	EDI					
	PUSH	EDX
	PUSH	ESI


	; Getting the user's input string, numInput [EBP + 12] will be modified to contain it
	mGetString	[EBP + 24], MAX_INPUT_SIZE, [EBP + 12], EBX

_Input:
	; First check if string is too short
	CMP		EBX, 0
	JE		_InvalidInput

	; Prepping for loop
	MOV		ECX, EBX			; Setting up loop counter
	MOV		ESI, [EBP + 12]		; Moving the input string into ESI
	MOV		EAX, 0				; Clearing EAX, AH will track the sign, AL will hold the byte
	MOV		EDI, [EBP + 8]		; Moving address of numOutput into EDI
	MOV		[EDI], EAX			; Zeroing out numOutput

_Loop:
	LODSB						; Loading the next byte into AL

	CMP		ECX, EBX			; If we are on first iteration of loop
	JE		_CheckSign			; we are going to check if there is a sign
	_CheckSignRet:

	JMP		_CheckASCII			; Now going to check if ASCII is a valid number
	_CheckASCIIRet:

	; We have a valid digit we can start accumulating to convert to SDWORD
	JMP		_Accumulate
	_AccumulateRet:
	
	_LoopEnd:
	LOOP _Loop

	CMP		AH, 1	
	JE		_Negate
	_NegateRet:

	; Restore registers
	POP		ESI
	POP		EDX					
	POP		EDI		
	POP		ECX
	POP		EBX					
	POP		EAX					
	POP		EBP					
	RET		20					; De-reference the passed offsets 20 bytes

; ---------- ReadVal Code Labels ---------
_CheckSign:
; Here we are checking the sign, if it is negative setting sign flag

	CMP		AL, ASCII_PLUS
	JE		_LeaveCheckSign		; If it is a plus we can skip the ASCII checker

	CMP		AL, ASCII_MINUS
	JNE		_CheckUnsignedSize	; If it wasn't a minus we need to check size and go on to check the ASCII still	

	; Storing our negative in AH for later
	MOV		AH,	1

	_LeaveCheckSign:
	; Byte is a confirmed + or -

	; If it is the only byte that exists, invalid input
	CMP		EBX, 1
	JE		_InvalidInput

	; If has more than 11 digits (10 digits + the sign) it is too big, invalid
	CMP		EBX, MAX_NUM_LENGTH_SIGNED
	JG		_InvalidInput

	JMP _LoopEnd

_CheckUnsignedSize:
; If it has more than 10 digits it is too big, invalid
	CMP		EBX, MAX_NUM_LENGTH
	JG		_InvalidInput
	JMP		_CheckSignRet

_CheckASCII:
; Checking if the current byte is a valid ascii number or not
	
	CMP		AL, ASCII_NUM_LO
	JL		_InvalidInput
	
	CMP		AL, ASCII_NUM_HI
	JG		_InvalidInput

	JMP		_CheckASCIIRet

_Accumulate:
; Converts byte from ASCII and increments the accumulator (numOutput)

	; Preserving registers for use below
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	
	MOV		EBX, 0				
	MOV		BH,	AH
	PUSH	EBX					; Moving our negative tracker to EBX and push to stack for later use

	MOV		AH, 0				; Zeroing out AH
	MOV		EBX, EAX			; Moving EAX to EBX to clear for multiplication

	SUB		EBX, 48				; Converting the ascii to a decimal	

	MOV		EAX, 10				; Multiplying numOutput accumulator by 10
	MOV		ECX, [EDI]		
	MUL		ECX

	ADD		EAX, EBX			; Adding the value of the current ascii

	POP		EBX					; Retrieving our negative tracker (in BH)
	CMP		BH, 1
	JNE		_AccumulatePos		; If number is negative, special handling below

	_AccumulateNeg:						; Special case to check for negative -2147483648 entry
	PUSH	EAX							
	NEG		EAX							; Negating EAX
	CMP		EAX, MAX_SIZE_SDWORD_NEG	; If we negate and the value is 2147483648 we need to allow entry
	POP		EAX							
	JE		_CheckOverflow				; Jump if equal, anything other than 2147483648 we treat normally

	_AccumulatePos:
	CMP		EAX, MAX_SIZE_SDWORD

	_CheckOverflow:
	JO		_AccumulateExit		; If the OV flag is triggered number was too big

	MOV		[EDI], EAX			; Otherwise Accumulating into numOutput

	_AccumulateExit:

	; Restoring registers
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX

	JO		_InvalidInput

	JMP		_AccumulateRet

_Negate:
; Negates the value in numOutput (in EDI)

	PUSH	EAX

	MOV		EAX, [EDI]			; Moving value to EAX
	NEG		EAX					; Negating

	MOV		[EDI], EAX			; Moving negated number back to numOutput

	POP		EAX

	JMP		_NegateRet

_InvalidInput:
; Input was invalid display message and start over

	mDisplayString [EBP + 16]									; Error message
	mGetString	[EBP + 20], MAX_INPUT_SIZE, [EBP + 12], EBX		; Reprompt for input
	JMP		 _Input

ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Takes in a SDWORD value and converts the decimal back into an ASCII string.  Once
; converted displays the entire value as an ASCII string to the command prompt. This
; process is accomplished by deconstructing the number and pushing each digit onto
; the call stack, then popping each one off into the provided output array to be 
; displayed.
;
; Preconditions: N/A
;
; Postconditions: 
;	numOutput [EBP + 12]: Will be modified during execution
;
; Receives:
;	numOutput [EBP + 12]: Array to hold each ASCII value and display the string, must be passed on the call stack
;	number [EBP + 8]: SDWORD value that will be displayed as ASCII, must be passed on the call stack
;	
; Returns: N/A
;	
; ---------------------------------------------------------------------------------
WriteVal PROC

	PUSH	EBP						; Preserve EBP
	MOV		EBP, ESP				; Assign static stack-frame pointer

	; Preserve registers
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDI
	PUSH	EDX

	MOV		EDI, [EBP + 12]			; This is going to be the output string
	MOV		EAX, [EBP + 8]			; The number value

	CMP		EAX, 0					; If negative, converting to a positive number for easier handling
	JL		_Negate					
	_NegateRet:

	MOV		ECX, MAX_INPUT_SIZE		
	PUSH	0						; Pushing null to signify end of the number

_Loop:

	; Calculating each digit by dividing remaining quotient by 10, pushing remainder to the stack

	MOV		EDX, 0					; Clear high dividend
	MOV		EBX, 10					; Divide by 10
	DIV		EBX

	ADD		EDX, 48
	PUSH	EDX						; Pushing the remainder (the next digit) on to the stack

	CMP		EAX, 0					; Quotient is 0 we are done
	JE		_Continue

	Loop _Loop

_Continue:

	MOV		EAX, [EBP + 8]			; Resetting EAX w/ original value
	CMP		EAX, 0
	JL		_PushMinus				; Pushing minus sign if negative

_Pop:

	; Popping the stack until we hit a null bit and storing in EDI (the output string)

	POP		EAX
	STOSB	

	CMP		AL, 0					
	JNE		_Pop

	mDisplayString	[EBP + 12]		; Finally, display the string

	; Restore registers
	POP		EDX
	POP		EDI
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP	
	RET 8

; ---------- WriteVal Code Labels ---------

_Negate:
; Converting to a positive number for easier handling
	NEG		EAX
	JMP		_NegateRet

_PushMinus:
; Pushing a minus ASCII to the stack
	PUSH	ASCII_MINUS
	JMP		_Pop

WriteVal ENDP

END main
