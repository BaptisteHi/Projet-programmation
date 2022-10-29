.text
.globl main

main:
movq $0, %rdx
movq $0, %rax

movsd .FLOAT2(%rip), %xmm0
movsd %xmm0, -8(%rsp)
subq $8, %rsp

movsd .FLOAT21(%rip), %xmm0
movsd %xmm0, -8(%rsp)
subq $8, %rsp

movsd (%rsp), %xmm0
movsd 8(%rsp), %xmm1
addq $16, %rsp
mulsd %xmm0, %xmm1
movsd %xmm1, -8(%rsp)
subq $8, %rsp

movsd .FLOAT20(%rip), %xmm0
movsd %xmm0, -8(%rsp)
subq $8, %rsp

movsd (%rsp), %xmm0
movsd 8(%rsp), %xmm1
addq $16, %rsp
addsd %xmm0, %xmm1
movsd %xmm1, -8(%rsp)
subq $8, %rsp
movsd (%rsp), %xmm0
addq $8, %rsp
call print_float
ret

print_float:
movq $message, %rdi
movq $1, %rax
call printf
ret

.data

message:
.string "%f"

.FLOAT2:
.double 7.0
.FLOAT21:
.double 3.0
.FLOAT20:
.double 5.0
.FLM1:
.double -1.0

