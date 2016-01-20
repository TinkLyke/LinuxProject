%include "asm_io.inc"
global asm_main

section .data
errargc: db "Error: Incorrect number of arguments",10,0
errorcase: db "Error: The input string contains an uppercase letter",10,0
errorlen: db "Error: The input string exceeded 20 characters",10,0
space: db " ",0

section .bss
N: resd 1
X: resd 20
Y: resd 20
a1: resd 1
a2: resd 1 
a3: resd 1
i: resd 1 
k: resd 1
p: resd 1
t: resd 1 

section .text

asm_main:
	enter 0,0 
	pusha
	
	;check arguments
	mov eax, dword [ebp+8]
	cmp eax, dword 2 
	je argcok
	
	;print error and quit 
	mov eax, errargc
	call print_string
	jmp endmain
	
	;if arugments is okay 
	argcok:  
	mov ebx, dword [ebp+12] ;address of argv[] 
	mov eax, dword [ebx+4] ;get argv[1] argument	
	 
	mov ebx, dword eax ;fuck this

	;loop through each character
	loop1:
	mov al, byte [ebx]
	cmp byte [ebx], 0
	je eloop1
	inc ebx
	add [N], dword 1
	
	cmp al, 'a'
	jb errorc
	cmp al, 'z'
	ja errorc

	jmp loop1 ;go to top
	
	errorc:
	mov eax, errorcase
	call print_string
	jmp endmain

	eloop1:
	cmp [N], dword 20
	jle continue
	mov eax, errorlen
	call print_string
	jmp endmain
	
	continue:
	mov ebx, dword [ebp+12] ;address of argv[] 
	mov eax, dword [ebx+4] ;get argv[1] argument	
	mov ebx, dword eax ;fuck this

	;load into array
	mov [a1], dword X
	loop2:
	cmp byte [ebx], 0
	je eloop2
	mov al, byte [ebx]
	mov ecx, dword [a1]
	mov [ecx], al
	add [a1], dword 4
	inc ebx
	jmp loop2	

	;go to display subroutine
	eloop2:
	push dword 0
	mov eax, dword [N]
	push eax
	mov eax, dword X 
	push eax
	call display 
	add esp, 12 
	
	mov [a3], dword Y
	;go to maxLyn subroutine
	mov [k], dword 0
	loop6:
	mov eax, dword [k]
	cmp dword [N], eax 
	jle eloop6 
	mov eax, dword [k]
	push eax	
	mov eax, dword [N]
	push eax
	mov eax, dword X
	push eax
	call maxLyn
	add esp, 12

	;section to put to array

	mov ecx, dword [a3]
	mov [ecx], dword eax
	add [a3], dword 4

	;------------------

	add [k], dword 1
	jmp loop6
	
	eloop6:
	;print array
	push dword 1
	mov eax, dword [N]
	push eax
	mov eax, dword Y
	push eax
	call display
	add esp, 12

	;clean 
	endmain: 
	popa 
	leave
	ret
;--------------------------

display: 
	push ebp 
	mov ebp, esp

	mov [i], dword 0
	mov ecx, dword [esp+12]
	mov ebx, dword [esp+8]
	
	;compare flag
	mov [i], dword 0
	cmp dword [esp+16], 0
	jne loop4

	;display if byte array
	loop3:
	mov eax, dword [ebx]
	call print_char
	add [i], dword 1
	add ebx, dword 4
	cmp [i], dword ecx
	jb loop3
	jmp end

	;display if int array
	loop4:
	mov eax, dword [ebx]
	call print_int
	add [i], dword 1
	add ebx, dword 4	
	cmp [i], dword ecx
	jb loop4

	end:
	;wait for user to press enter
	call read_char 
	pop ebp
	ret
;--------------------

maxLyn:
        push ebp
        mov ebp , esp 
        
        mov edx , dword [esp+12]            ; edx = n 
        sub edx , 1                         ; edx = N-1    
        mov [t] , dword edx                 ; t = N-1 (t points to edx)
        
        ;mov eax , dword [t]
        ;call print_int
        ;call print_nl

        mov ebx , dword [esp+16]            ; ebx = k 
        cmp [t] , dword ebx                 ; if k=n-1 
        je Maxisone ;return 1
        
        mov [max] , dword 1                 ; max = 1
        mov [p] , dword 1                   ; p = 1

        add ebx , 1                         ; ebx = k+1
            
        mov [i] , ebx                       ; i = k+1 (i points to ebx)
    


;for i <- k+1 to n-1 
    
forloop:
        mov eax, dword [t]                   ; eax = (n-1) which t = n-1
        cmp [i], dword eax                   ; compare if (i <- k+1) = n-1 (forloop condition)
        jg returnMax                         ; end forloop 

        ;indexing
        mov ecx, dword [esp+8]               ; (ecx points to array)
        mov eax, dword [i]                   ; eax = i
        lea eax, [eax*4]                     ; multiply offset by 4 bytes    
        
        add ecx, eax ; Z[i]
        mov eax, dword [ecx]                 ; cl = Z[i]
            
        mov edi, dword [p]
        lea edi, [edi*4]                     ; multiply offset by 4 bytes
        sub ecx, edi                         ; Z[i-p]
        cmp eax, dword [ecx]                 ; Z[i-p] != Z[i]
        je incrementi                        ; go to top

        cmp eax, dword [ecx]                 ; Z[i-p] > Z[i]
        jg else
        jmp returnMax                        ; if z[i-p] > z[i]
        
        else:   
        mov esi, dword [i]                   ; r8d = i
        add esi, 1                           ; r8d = i+1
        sub esi, dword [k]                   ; r8d = i+1-k
        mov [p], dword esi                   ; p point to r8d ; p=i+1-k
        mov [max], dword esi                 ; max point to r8d 
        jmp incrementi
        
incrementi:
        add [i], dword 1                     ; i = (k+1)+1+2+3...
        jmp forloop

Maxisone:
        mov [max], dword 1
        mov eax , [max]
        jmp end_maxLyn
        
returnMax:
        mov eax, dword [max]
        jmp end_maxLyn

end_maxLyn: 
        pop ebp 
        ret