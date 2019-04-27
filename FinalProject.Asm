extern _scanf 
extern _printf 
extern _fopen 
extern _rewind 
extern _fscanf 
extern _fprintf 
extern _malloc 
extern _free 
extern _strcpy 
extern _strcmp 
extern _feof 
extern _strlen 
extern _system 
extern _fclose 

segment .data 

szFname db 'names.txt',0 
szName TIMES 50 db 0 
szMode db 'rt',0 
szIn db '%49s',0 
szOut db 'Name %d: %s',10,0 
szError db 'Could not open file: %s',10,0 
szCount db 'Count: %d',10,0 
szPause db 'PAUSE',0 
szOriginal db 'Original File',10,0
szSorted db 'Sorted Names',10,0

segment .code 

global _main 
_main: 

%define count [ebp-4] 
%define size [ebp-8] 
%define x [ebp-12] 
%define y [ebp-16] 
%define temp [ebp-20] 
%define pos [ebp-24] 
%define file [ebp-28] 
%define names [ebp-32] 

enter 32,0 

;setting equal to 0
mov count, dword 0 
mov size, dword 0
mov x, dword 0
mov y, dword 0
mov temp, dword 0
mov pos, dword 0

push szMode ;pushing parameters onto the stack
push szFname
call _fopen ;looks at the top of the stack
mov file, eax ;returning
add esp,8 ;keeping track of what is in the stack. 
; moving the pointer to the top of the stack

;if - statement 
cmp file, dword 0  
je if_else

;while loop
while_start:
push dword file 
call _feof
add esp, 4

cmp eax, dword 0
jne while_end

push szName
push szIn
push dword file
call _fscanf
add esp, 12

inc dword count
jmp while_start ;end of the while loop

if_else: ;else - statement 
push szError
call _printf
add esp, 4

jmp end
while_end:

if_end:

push dword count
push szCount
call _printf
add esp, 8

mov ebx, count
imul ebx, 4 ;multiplying the register by 4
push ebx
call _malloc ;dynamically allocating the memory into the character array
add esp, 4

mov names, eax ;eax into names

push dword file
call _rewind
add esp, 4

mov count, dword 0 ; count = 0

;while loop
while1_start:
push dword file
call _feof
add esp, 4

cmp eax, dword 0
jne while1_end

push szName
push szIn
push dword file
call _fscanf
add esp, 12

push szName
call _strlen
add esp, 4

mov size, eax

; allocating the char array
inc dword size
push dword size
call _malloc
add esp, 4

mov ebx, names
mov ecx, count 
mov [ebx+ecx*4], eax

push szName
push dword [ebx+ecx*4]
call _strcpy
add esp, 8

inc dword count
jmp while1_start

while1_end:
push szOriginal 
call _printf
add esp, 4

;for loop
for_start
mov ebx, count
cmp x, ebx ;comparing
jge for_end ;greater than or equal to 

mov ecx, names
mov ebx, x 
mov edx, [ecx+ebx*4]
inc ebx ;incrementing the register

push edx
push dword ebx
push szOut
call _printf
add esp, 12

inc dword x
jmp for_start ;jumping back to the top

for_end:

;for loop
mov x, dword 0

for1_start:
mov ebx, count
cmp x, ebx
jge NEAR for1_end ;making a longer jump 

mov ebx, names ;first element
mov ecx, x ;nth element
mov edx, [ebx+ecx*4]
mov temp, edx
mov pos, ecx
mov y, ecx

for2_start: ;2nd for loop in the first for loop 
mov ecx, count
cmp y, ecx
jge for2_end

;if - statement 
mov ebx, names
mov ecx, y ;yth element
mov edx, [ebx+ecx*4]

push edx
push dword temp
call _strcmp 
add esp, 8 ;cleaning up the stack

cmp eax, dword 0 ;whatever strcmp returned
jle if1_end

mov ebx, names
mov ecx, dword y
mov edx, [ebx+ecx*4]
mov temp, edx
mov pos, ecx

if1_end:
inc dword y
jmp for2_start

for2_end:

mov ebx, names
mov ecx, x
mov edx, [ebx+ecx*4]
mov temp, edx
mov ebx, names
mov ecx, pos
mov edx, [ebx+ecx*4]
mov ecx, x
mov [ebx+ecx*4],edx
mov ebx, names
mov ecx, dword pos
mov edx, temp
mov [ebx+ecx*4], edx

inc dword x
jmp for1_start

for1_end:

push szSorted
call _printf
add esp, 4

;for loop
mov x, dword 0

for3_start:
mov ecx, count
cmp x, ecx
jge for3_end

mov ebx, names
mov ecx, x
mov edx, [ebx+ecx*4]

inc ecx

push edx
push ecx
push szOut
call _printf
add esp, 12

inc dword x
jmp for3_start

for3_end:

end:
push szPause ;after executing the program
call _system
add esp, 4

mov eax, dword 0 ;main function returning to 0 once it is finished

leave 
ret