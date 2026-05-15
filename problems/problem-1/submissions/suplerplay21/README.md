# suplerplay21 — Problem 1 Solution

## Approach

Sieve of Eratosthenes in x86-64 Linux assembly (NASM). Marks composites in O(N log log N) via direct memory writes, then streams `1` followed by all unmarked indices (primes) to stdout.

## Solution Code

```nasm
; solution.asm — x86-64 Linux (NASM)
; Print 1 and all primes < N (Sieve of Eratosthenes)

global _start

section .data
    one_nl  db '1', 10

section .bss
    inbuf   resb 32

section .text

_start:
    ; read N from stdin
    xor     eax, eax
    xor     edi, edi
    lea     rsi, [rel inbuf]
    mov     edx, 32
    syscall

    ; parse decimal integer → r12
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

    cmp     r12, 1
    jle     .exit

    ; mmap N bytes for sieve (kernel zero-fills)
    mov     eax, 9
    xor     edi, edi
    mov     rsi, r12
    mov     edx, 3              ; PROT_READ | PROT_WRITE
    mov     r10d, 0x22          ; MAP_PRIVATE | MAP_ANONYMOUS
    mov     r8d, -1
    xor     r9d, r9d
    syscall
    mov     r13, rax

    mov     byte [r13], 1
    mov     byte [r13 + 1], 1

    ; Sieve of Eratosthenes
    mov     rbx, 2
.sieve_outer:
    mov     rax, rbx
    imul    rax, rbx
    cmp     rax, r12
    jge     .sieve_done
    cmp     byte [r13 + rbx], 0
    jne     .sieve_next
    mov     rcx, rbx
    imul    rcx, rbx
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

    ; print "1\n"
    mov     eax, 1
    mov     edi, 1
    lea     rsi, [rel one_nl]
    mov     edx, 2
    syscall

    ; print all primes 2..N-1
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
    mov     eax, 60
    xor     edi, edi
    syscall

; print_uint64 — write rdi as decimal + newline
print_uint64:
    sub     rsp, 24
    mov     byte [rsp + 23], 10
    lea     rcx, [rsp + 22]
    mov     rax, rdi
    mov     r8d, 10
.digit:
    xor     rdx, rdx
    div     r8
    add     dl, '0'
    mov     [rcx], dl
    dec     rcx
    test    rax, rax
    jnz     .digit
    inc     rcx
    mov     rsi, rcx
    lea     rdx, [rsp + 24]
    sub     rdx, rcx
    mov     eax, 1
    mov     edi, 1
    syscall
    add     rsp, 24
    ret
```

## How to Build

**Requirements:** NASM + GNU linker (`ld`) on Linux x86-64

```bash
# Assemble + link
nasm -f elf64 solution.asm -o solution.o
ld solution.o -o solution

# Quick test
echo "13" | ./solution
# Expected: 1 2 3 5 7 11 (one per line)
```

## How to Run

```bash
# Direct
echo "100" | ./solution

# Pipe from file
./solution < input.txt
```

## Re-evaluate

From `problems/problem-1/` on Linux:

```bash
# Compile first
nasm -f elf64 submissions/suplerplay21/solution.asm -o /tmp/sol.o
ld /tmp/sol.o -o submissions/suplerplay21/solution_bin

# Run evaluator
./evaluate-linux-amd64 "submissions/suplerplay21/solution_bin" submissions/suplerplay21/results.md
```

## Score

**100 / 100** — all 10 test cases passed.
