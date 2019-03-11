%include "io.inc"
%define MAX_INPUT_SIZE 4096
section .bss
	expr: resb MAX_INPUT_SIZE
section .data
section .text
global CMAIN   
CMAIN:
    mov ebp, esp
    push ebp
    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx
    GET_STRING expr, MAX_INPUT_SIZE
        
parcurg_string:
    xor eax, eax
    cmp byte[expr+ecx], '+'            ;verific daca e o adunare
    je adunare
    cmp byte[expr+ecx], '-'            ;verific daca e o scadere
    je scadere
    cmp byte[expr+ecx], '*'            ;verific daca e o inmultire
    je inmultire
    cmp byte[expr+ecx], '/'            ;verific daca e o impartire
    je impartire
    cmp byte[expr+ecx], ' '            ;verific daca e spatiu gol 
    je spatiu
    cmp byte[expr+ecx], 0              ;verific daca e null
    je final
    
cifra:
    mov al, byte [expr + ecx]          ;salvez cifra curenta, calculez valoarea ei si o pun pe stiva
    sub eax, 48                        ;conertesc din ASCII
    push eax
    inc ecx  
    cmp byte[expr + ecx], ' '          ;daca are spatiu dupa, parcurg in continuare stringul
    je parcurg_string                  ;altfel, formez numarul de doua cifre  
       
                                       ;labelurile "doua cifre" si "trei cifre" sunt puse doar pentru claritatea codului
doua_cifre:                            ; ele sunt inutile, programul continua de la sine, le-am pus doar ca sa se inteleaga mai usor  
    pop eax                            ;scot prima cifra ca sa formez noul numar    
    mov ebx, 10
    imul ebx                           ; baza * 10 + cifra
    xor edx,edx
    mov dl, byte[expr+ecx]
    sub edx, 48
    add eax, edx
    
    push eax
    inc ecx
    cmp byte[expr + ecx], ' '          ;daca are spatiu, parcurg in continuare stringul
    je parcurg_string                  ;altfel, formez numarul de trei cifre
    
trei_cifre:
    pop eax                            ; scot numarul de doua cifre
    mov ebx, 10                        ; baza * 10 + cifra
    imul ebx
    xor edx,edx
    mov dl, byte[expr+ecx]
    sub edx, 48
    add eax, edx
    push eax
    inc ecx
    jmp parcurg_string

adunare:
    inc ecx                             ;scot din stiva ultimele doua numere, le adun si fac push la suma
    pop eax
    pop ebx
    add eax, ebx
    push eax
    jmp parcurg_string
    
scadere:
    inc ecx              
    cmp byte[expr+ecx], 0               ;verific daca am ajuns la null
    je diferenta_simpla 
    cmp byte[expr+ecx]," "              ;verific daca am spatiu dupa semn
    je diferenta_simpla                 ;in caz contrar, avem o cifra dupa minus
    
negativ: 
    xor edx,edx 
    mov dl,byte[expr+ecx]               ;urmeaza o cifra 
    sub edx, 48                         ;convertesc din ASCII
    neg edx
    push edx
    inc ecx
    cmp byte[expr + ecx], ' '           ;daca are spatiu, parcurg in continuare stringul
    je parcurg_string           
    jmp doua_cifre_negativ              ;altfel, formez numarul 

doua_cifre_negativ:
    pop eax                             ;scot prima cifra ca sa formez numarul    
    mov ebx, 10
    imul ebx
    xor edx,edx
    mov dl, byte[expr+ecx]
    sub edx, 48
    neg edx                             ;singura diferenta fata de nr de doua cifre pozitive ( neg cifra pe care o adun )
    add eax, edx
    
    push eax
    inc ecx
    cmp byte[expr + ecx], ' '           ;daca are spatiu, parcurg in continuare
    je parcurg_string           
    jmp trei_cifre_negativ              ;altfel, formez numarul 

trei_cifre_negativ:
    pop eax                             ;scot numarul de doua cifre
    mov ebx, 10                         ;il construiesc pe cel de trei cifre
    imul ebx
    xor edx,edx
    mov dl, byte[expr+ecx]
    sub edx, 48
    neg edx
    add eax, edx
    push eax
    inc ecx
    jmp parcurg_string           
    
diferenta_simpla:         
    pop ebx                             ;scot ultimele doua numere si le scad,apoi pun rezultatul in stiva
    pop eax
    sub eax,ebx
    push eax
    jmp parcurg_string 
    
inmultire:
    inc ecx                             ;scot ultimele doua numere si le inmultesc,apoi pun rezultatul in stiva
    pop eax
    pop ebx
    imul ebx
    push eax
    jmp parcurg_string

impartire:
    inc ecx                             ;scot ultimele doua numere si le impart,apoi pun rezultatul in stiva
    xor edx, edx
    xor ebx, ebx

    pop ebx  
    pop eax
    cdq
    idiv ebx   
    push eax
    jmp parcurg_string
      
spatiu:
    inc ecx                             ;daca am spatiu, nu fac nimic
    jmp parcurg_string
    
final:                                  ;afisez rezultatul
    pop eax 
    pop ebp
    PRINT_DEC 4, eax
    ret