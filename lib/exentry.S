#include <inc/mmu.h>
#include <inc/memlayout.h>

.text
.globl _exception_upcall
_exception_upcall:
	pushl %esp
	movl $_exception_handler, %eax 
	movl 0x4(%esp), %ebx
	addl %ebx, %ebx
	addl %ebx, %ebx
	addl %ebx, %eax
	movl (%eax), %eax
	call *%eax
	addl $4, %esp

	movl 0x2c(%esp), %eax
	subl $4, 0x34(%esp)
	movl 0x34(%esp), %ecx
	movl %eax, (%ecx)

	addl $12, %esp
	popal

	addl $4, %esp
	popfl

	popl %esp

	ret
