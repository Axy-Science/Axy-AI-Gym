; solution.asm — x86-64 Linux (NASM)
; Print 1 and all primes < N (Sieve of Eratosthenes)
; Build: nasm -f elf64 solution.asm -o solution.o && ld solution.o -o solution
; Run:   echo "100" | ./solution

global _start

section .data
    one_nl  db '1', 10          ; "1\n" — always first output

section .bss
    inbuf   resb 32             ; stdin read buffer

section .text

_start:
    ; --- read N from stdin ---
    xor     eax, eax            ; sys_read = 0
    xor     edi, edi            ; fd = stdin
    lea     rsi, [rel inbuf]
    mov     edx, 32
    syscall

    ; --- parse decimal integer → r12 ---
    lea     rsi, [rel inbuf]
    xor     r12, r12
.parse:
    movzx   eax, byte [rsi]
    inc     rsi
    cmp     al, '0'
    jb      .parse_done
    cmp     al, '9'
    ja      .parse_done
    sub     al, '0'
    imul    r12, r12, 10
    add     r12, rax
    jmp     .parse
.parse_done:
    ; r12 = N

    cmp     r12, 1
    jle     .exit               ; N <= 1: no output

    ; --- mmap N bytes for sieve (kernel zero-fills) ---
    mov     eax, 9              ; sys_mmap
    xor     edi, edi            ; addr = NULL
    mov     rsi, r12            ; length = N
    mov     edx, 3              ; PROT_READ | PROT_WRITE
    mov     r10d, 0x22          ; MAP_PRIVATE | MAP_ANONYMOUS
    mov     r8d, -1             ; fd = -1
    xor     r9d, r9d            ; offset = 0
    syscall
    mov     r13, rax            ; r13 = sieve base (all bytes 0 = prime)

    ; mark 0 and 1 as non-qualifying
    mov     byte [r13], 1
    mov     byte [r13 + 1], 1

    ; --- Sieve of Eratosthenes ---
    mov     rbx, 2
.sieve_outer:
    mov     rax, rbx
    imul    rax, rbx            ; rax = i*i
    cmp     rax, r12
    jge     .sieve_done
    cmp     byte [r13 + rbx], 0
    jne     .sieve_next
    mov     rcx, rbx
    imul    rcx, rbx            ; start marking at i*i
.sieve_inner:
    cmp     rcx, r12
    jge     .sieve_next
    mov     byte [r13 + rcx], 1
    add     rcx, rbx
    jmp     .sieve_inner
.sieve_next:
    inc     rbx
    jmp     .sieve_outer
.sieve_done:

    ; --- print "1\n" ---
    mov     eax, 1
    mov     edi, 1
    lea     rsi, [rel one_nl]
    mov     edx, 2
    syscall

    ; --- print all primes 2..N-1 ---
    mov     rbx, 2
.print_loop:
    cmp     rbx, r12
    jge     .exit
    cmp     byte [r13 + rbx], 0
    jne     .print_skip
    mov     rdi, rbx
    call    print_uint64
.print_skip:
    inc     rbx
    jmp     .print_loop

.exit:
    mov     eax, 60             ; sys_exit
    xor     edi, edi
    syscall

; ---------------------------------------------------------
; print_uint64 — write rdi as decimal + newline to stdout
; Uses 24-byte stack buffer; digits built right-to-left.
; Clobbers: rax, rcx, rdx, rsi, r8 (all caller-save here)
; ---------------------------------------------------------
print_uint64:
    ; rsp after call = original-8 (return addr pushed)
    ; sub 24 → total -32 from original → 16-byte aligned
    sub     rsp, 24
    mov     byte [rsp + 23], 10     ; newline terminator
    lea     rcx, [rsp + 22]         ; write digits right-to-left from here
    mov     rax, rdi
    mov     r8d, 10
.digit:
    xor     rdx, rdx
    div     r8                      ; rdx:rax / 10 → quot rax, rem rdx
    add     dl, '0'
    mov     [rcx], dl
    dec     rcx
    test    rax, rax
    jnz     .digit
    inc     rcx                     ; rcx = pointer to first digit
    mov     rsi, rcx
    lea     rdx, [rsp + 24]         ; one past newline
    sub     rdx, rcx                ; length = end - start
    mov     eax, 1                  ; sys_write
    mov     edi, 1                  ; stdout
    syscall
    add     rsp, 24
    ret
