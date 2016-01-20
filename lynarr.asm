%include"asm_io.inc"
global asm_main

section .data
Error1:db "incorrect number of arguments", 10, 0
Error2:db "the length of the string is not below 20, bye", 10, 0
Error3:db "the string contains letter(s) in upper case, bye ",10 ,0
Error4:db "the string contain non lower case character(s), bye",10,0
space: db " ",0

section .bss
a1: resd 1
a2: resd 1
a3: resd 1
i: resd 1
M: resd 20
N: resd 1
X: resd 20
j: resd 1
k: resd 1
p: resd 1
max: resd 1



section .text

asm_main:
		enter 0,0
		pusha
		;check arguments
		mov eax, dword [ebp+8]
		cmp eax, dword 2 
		je argcok
		mov eax, Error1
		call print_string
		jmp done

argcok:
		;address of 1st argument 
		mov ebx, dword [ebp+12]
		mov eax, dword [ebx+4]
		mov ecx, dword [ebx+4]
		mov ebx, dword eax; 
		mov [N], dword 0
		
checkUC_Length:                                 ; all should be in lower case
		mov al, byte [ebx]
		cmp al, 'A'                
        jb NOT_UC                  
        cmp al, 'Z'                
        ja NOT_UC                  					
       	jmp if_UC

if_UC:
       	mov eax, Error3
       	call print_string
       	jmp done

NOT_UC:
        ;call print_char
        cmp al, 'a'
        jb Notgoodchar
        cmp al, 'z'
        ja Notgoodchar
        add [N], dword 1
        inc ebx
        cmp byte[ebx],0
        je CheckLength
        jmp checkUC_Length

Notgoodchar:
        mov eax, Error4
        call print_string
        jmp done

CheckLength:
        cmp [N], dword 20
        jg LengthNOTGOOD
        jmp Keepgoing

LengthNOTGOOD:
        mov eax, Error2
        call print_string
        jmp done
                                                ; put numbers into array
Keepgoing:
        ;mov ebx , dword ecx                    ; arg[1]
        mov [a1], dword X
        jmp Keepgoing2

Keepgoing2:
        cmp byte [ecx], 0
        je disSub
        
        mov al, byte [ecx]
        mov edx, dword [a1]
        mov [edx], al
        inc ecx
        add [a1], dword 4
        
        jmp Keepgoing2

disSub:
        ;mov eax , dword X                      ; X[N] = 0
        ;add eax , dword [N]                    ; do we need it?
        ;mov [eax] , dword 0


        push dword 0
        mov eax , dword[N]
        push eax
        mov eax, dword X
        push eax
        call display
        add esp ,12
        mov [a3] , dword M
        mov [k] , dword 0
        jmp maxLSub
        
maxLSub:
        mov eax , dword [k]
        cmp dword [N] , eax
        jle endMaxL
        mov eax , dword [k]
        push eax
        mov eax , dword [N]
        push eax
        mov eax , dword X
        push eax 
        call maxLyn
        add esp , 12

        mov ecx, dword [a3]
        mov [ecx] , dword eax
        add [a3] , dword 4
        add [k] , dword 1
        jmp maxLSub

endMaxL:
        push dword 1
        mov eax , dword [N]
        push eax
        mov eax , dword M
        ;call print_string
        push eax 
        call display
        add esp , 12


        done:
        popa
        leave
        ret

display:
        push ebp
        mov ebp, esp
        
        mov [i], dword 0
        mov ecx, dword [esp+12]
        mov ebx, dword [esp+8]

        mov [i], dword 0
        cmp dword [esp+16], 0
        jne loop2
        jmp loop1

        loop1:
        mov eax , dword [ebx]
        call print_char
        add [i], dword 1
        add ebx, dword 4
        cmp [i] , dword ecx
        jb loop1
        jmp end

        loop2:
        mov eax , dword [ebx]
        call print_int
        mov eax , space
        call print_string
        add [i] , dword 1
        add ebx , dword 4
        cmp [i] , dword ecx
        jb loop2
        jmp end

        end:
        call read_char
        pop ebp 
        ret

maxLyn:                                     ; hard one 
        push ebp
        mov ebp , esp 
        
        mov edx , dword [esp+12]            
        sub edx , 1                         ; edx = N-1    
        mov [j] , dword edx                 ; j = N-1 (j points to edx)
        
        ;mov eax , dword [j]
        ;call print_int
        ;call print_nl

        mov ebx , dword [esp+16]            
        cmp [j] , dword ebx                 ; if k=n-1 
        je Maxisone ;return 1
        
        mov [max] , dword 1                 ; max = 1
        mov [p] , dword 1                   ; p = 1

        add ebx , 1                         
            
        mov [i] , ebx                       ; i = k+1 (i points to ebx)
        jmp forloop
                                            ; for i <- k+1 to n-1 
forloop:
        mov eax, dword [j]                  
        cmp [i], dword eax                  ; compare if (i <- k+1) = n-1 (forloop condition)
        jg returnMax                        ; end forloop 
                                 
        mov ecx, dword [esp+8]              
        mov eax, dword [i]                  ; eax = i
        lea eax, [eax*4]                        
        
        add ecx, eax                        ; Z[i]
        mov eax, dword [ecx]                
            
        mov edx, dword [p]
        lea edx, [edx*4]                    
        sub ecx, edx                        
        cmp eax, dword [ecx]                ; Z[i-p] != Z[i]
        je incrementi                       ; go to top

        
        ;mov eax , dword [p]                ;error check                
        ;call print_int


        cmp eax, dword [ecx]                ; Z[i-p] > Z[i]
        jg else
        jmp returnMax                       ; if z[i-p] > z[i]
        
        else:   
        mov edx, dword [i]                  
        add edx, 1                          
        sub edx, dword [k]                  
        mov [p], dword edx                  ; p = edx ; p=i+1-k
        mov [max], dword edx                 
        jmp incrementi
        
incrementi:
        add [i], dword 1                    
        jmp forloop

Maxisone:
        mov [max], dword 1
        mov eax , [max]
        jmp MaxLynEnd
        
returnMax:
        mov eax, dword [max]
        jmp MaxLynEnd

MaxLynEnd: 
        pop ebp 
        ret