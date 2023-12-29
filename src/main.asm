[default rel]
[global main]

[extern printf]

[extern list_init]
[extern list_push]
[extern list_pop]
[extern list_print]
[extern list_get]
[extern list_destroy]

main:
    push rbp
    mov rbp, rsp
    sub rsp, 8

    mov rdi, 16 ; 16 entries
    call list_init
    mov qword [rbp - 8], rax ; list ptr

    mov rdi, fmt_alloc
    mov rsi, qword [rbp - 8]
    mov rax, 0
    call printf wrt ..plt

    mov rdi, qword [rbp - 8]
    mov rsi, 0x42
    call list_push

    mov rdi, qword [rbp - 8]
    mov rsi, 0x43
    call list_push

    mov rdi, qword [rbp - 8]
    mov rsi, 512
    call list_push

    mov rdi, qword [rbp - 8]
    mov rsi, 1
    call list_get

    mov rdi, fmt_at
    mov rsi, 1
    mov rdx, rax
    mov rax, 0
    call printf wrt ..plt

    mov rdi, qword [rbp - 8]
    call list_print

    mov rdi, qword [rbp - 8]
    call list_pop

    mov rdi, fmt_popped
    mov rsi, rax
    mov rax, 0
    call printf wrt ..plt

    mov rdi, qword [rbp - 8]
    call list_print

    mov rdi, qword [rbp - 8]
    call list_destroy

    mov eax, 0
    leave
    ret

fmt_alloc: db `List allocated at %lx\n\0`
fmt_at: db `list at %lx: 0x%lx\n\0`
fmt_popped: db `list popped: 0x%lx\n\0`