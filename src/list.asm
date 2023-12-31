[global list_init]
[global list_push]
[global list_pop]
[global list_print]
[global list_get]
[global list_destroy]

[extern malloc]
[extern realloc]
[extern free]
[extern printf]

list_init:
    push rbp
    mov rbp, rsp
    sub rsp, 8 ; there's a local u64* (the list ptr)

    mov rbx, rdi

    mov rdi, 24 ; 8 * 3 (data and length/idx and capacity are u64s)
    call malloc wrt ..plt
    mov qword [rbp - 8], rax

    mov rax, 8
    mul rbx ; 1st arg aka count

    mov rcx, rbx

    mov rdi, rax ; 8 * count
    call malloc wrt ..plt
    mov rbx, qword [rbp - 8]
    mov qword [rbx], rax ; list addr

    mov rax, qword [rbp - 8]
    add rax, 8
    mov qword [rax], 0 ; length

    mov rax, qword [rbp - 8]
    add rax, 16
    mov qword [rax], rcx ; capacity

    mov rax, qword [rbp - 8]

    add rsp, 8
    mov rsp, rbp
    pop rbp
    ret

list_push:
    push rbp
    mov rbp, rsp

    ; RDI = list ptr

    mov rcx, qword [rdi] ; ptr
    mov rbx, qword [rdi + 8] ; offset
    mov rdx, qword [rdi + 16] ; capacity

    cmp rbx, rdx
    je .list_realloc
    jmp .list_append

.list_realloc:
    mov rax, 2
    mul rdx

    mov qword [rdi + 16], rdx

    mov rax, 8
    mul rdx

    mov rdi, rcx
    mov rsi, rdx
    call realloc wrt ..plt

    mov qword [rdi], rax
    mov rcx, rax

.list_append:
    mov rax, 8
    mul rbx ; rax = rax * rbx
    add rcx, rax ; count * 8

    mov qword [rcx], rsi ; 2nd argument

    add rbx, 1
    mov qword [rdi + 8], rbx

    mov rsp, rbp
    pop rbp
    ret

list_pop:
    push rbp
    mov rbp, rsp

    mov rcx, qword [rdi]
    mov rbx, qword [rdi + 8]

    cmp rbx, 0
    je .error

    sub rbx, 1

    mov qword [rdi + 8], rbx

    mov rax, 8
    mul rbx
    add rcx, rax

    mov rdx, qword [rcx]
    mov qword [rcx], 0

    mov rax, rdx
    jmp .exit
.error:
    mov rax, 0
.exit:
    mov rsp, rbp
    pop rbp
    ret

list_print:
    push rbp
    mov rbp, rsp
    sub rsp, 24

    ; RDI = list ptr

    mov rax, qword [rdi] ; list start
    mov rbx, qword [rdi + 8] ; list entries

    mov qword [rbp - 8], rax ; list start
    mov qword [rbp - 16], rbx ; list entries
    mov qword [rbp - 24], 0 ; current idx

.loop:
    mov rcx, qword [rbp - 24]
    cmp qword [rbp - 16], rcx
    je .exit

    mov rdi, list_at
    
    mov rsi, qword [rbp - 24]
    
    mov rax, 8
    mov rbx, qword [rbp - 24]
    mul rbx ; rax = rax * rbx
    mov rcx, rax
    mov rax, qword [rbp - 8]
    add rax, rcx    
    mov rdx, qword [rax]

    mov rax, 0
    call printf wrt ..plt

    mov rcx, qword [rbp - 24]
    add rcx, 1
    mov qword [rbp - 24], rcx

    jmp .loop

.exit:
    add rsp, 24
    mov rsp, rbp
    pop rbp
    ret

list_get:
    push rbp
    mov rbp, rsp

    ; rdi = list ptr
    ; rsi = list idx

    cmp rsi, qword [rdi + 16]
    jg .error

    mov rcx, qword [rdi]

    mov rax, 8
    mul rsi

    add rcx, rax
    mov rax, qword [rcx]
    jmp .exit
.error:
    mov rax, 0
.exit:
    mov rsp, rbp
    pop rbp
    ret

list_destroy:
    push rbp
    mov rbp, rsp

    call free wrt ..plt ; ptr should be at rdi

    mov rsp, rbp
    pop rbp
    ret

list_at: db `list idx %d: 0x%lx\n\0`