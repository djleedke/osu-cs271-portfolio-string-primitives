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

; (insert macro definitions here)

; (insert constant definitions here)

.data

; (insert variable definitions here)

.code
main PROC

; (insert executable instructions here)

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
