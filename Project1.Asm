extern _scanf 
extern _printf 
extern _malloc 
extern _free 
extern _strlen 
extern _strcpy
extern _system

segment .data 

szPrompt db 'Please enter a string',10,0 
szIn db '%49s',0 
szOut db '%s',10,0 
szPause db 'PAUSE',0
szString TIMES 50 db 0 


segment .code 

global _main 

_main: 
enter 0,0 

; 1. print the prompt 
push szPrompt
call _printf
add esp,4

; 2. read in the string into szString 
push szString
push szIn
call _scanf
add esp,8

; 3. pass szString as a parameter to _noSpaces 
push szString
call _noSpaces
add esp,4

; 4. Print out szString
push szString ;copied the buffer into the szString
push szOut
call _printf
add esp,8

push szPause
call _system 
add esp,4

leave 
ret 

%define input [ebp+8] ;szString
%define inputCounter [ebp-4] ;other variables used in the function
%define bufferCounter [ebp-8] 
%define length [ebp-12] 
%define buffer [ebp-16] ;allocates a range of memory to store the string. Our new string
; without the spaces

_noSpaces: 
enter 16,0 

push dword input
call _strlen
add esp,4

mov length, eax
add eax,4

push eax
call _malloc 
add esp,4

mov buffer, eax ;return buffer

mov dword bufferCounter,0 ;setting bufferCounter equal to 0
mov dword inputCounter,0 ;setting inputCounter equal to 0

;label for where the loop starts
looping_start:

;taking care of the spaces in between

mov eax, dword inputCounter ;comparing inputCounter to length
cmp eax, dword length
jnl looping_end

;if first and next position are spaces
mov ebx, dword input
mov ecx, dword inputCounter
mov ah, [ebx + ecx] ;ah = register for smaller values
mov al, [ebx + ecx + 1] ;al & ah -> (make up another register called 'ax')

cmp ax, 0x5F5F ;Hx value (2 _ _ because of the 2 5F's)
;if current character were on the string and the one after it are _'s then
; increment inputCounter, if not then jump to the end of the if-statement
jne if_end

inc dword inputCounter
jnl looping_start

if_end:

mov eax, dword input
mov ebx, dword inputCounter
mov ecx, dword [eax + ebx] ;taking the character at wherever we are (cursor wise)

mov eax, dword buffer
mov ebx, dword bufferCounter
mov [eax + ebx], ecx

inc dword inputCounter
inc dword bufferCounter

jmp looping_start

looping_end:

;taking care of the spaces at the end and at the beginning

mov ebx, dword buffer
mov ecx, dword bufferCounter
mov dword [ebx + ecx],0x00

;if-statement checking the end of the sentence
mov ebx, dword buffer
mov ecx, dword bufferCounter
mov ah, [ebx + ecx - 1] ;last character in the string
cmp ah, 0x5F ;comparing to the underscore character
jne if1_end

mov ebx, dword buffer ;dword to let the program know it is a certain size
mov ecx, dword bufferCounter
mov dword [ebx + ecx - 1],0x00 ;setting it equal to 0 

if1_end:

;another if-statement
mov ebx, dword buffer ;checking the buffer at index 0, which it is already there
mov ah, [ebx] ;at the beginning of the string
cmp ah, 0x5F
jne if2_else

mov ebx, dword input ;calling string copy method
mov eax, dword buffer
inc eax ;incrementing eax by 1 because with the string copy method, it has
; to take the second argument, which is a 2nd pointer to the string (copied to
; first)
;adding one gets rid of the first character


push eax
push ebx
call _strcpy
add esp,8

jmp if2_end

if2_else:
mov eax, dword buffer
mov ebx, dword input

push eax
push ebx
call _strcpy ; putting our result in the buffer and taking the new sentence
; with spaces included and placed into the input variable to be used in the main method
add esp,8

if2_end:

push dword buffer ;variable that we allocated
call _free ;i.e. delete key word (freeing the memory since we are done with the buffer)
add esp,4

;cmp AX, 0x5F5F (example)
;cmp AX, 5F5Fh (example)

leave 
ret