// test user-level fault handler -- just exit when we fault

#include <inc/lib.h>


#ifdef CHALLENGE
void
handler(struct UTrapframe *utf)
{
	cprintf("yeah!!!!\n");
	sys_env_destroy(sys_getenvid());
}

void
umain(int argc, char **argv)
{
	set_exception_handler(handler, T_GPFLT);
	cprintf("-------------\n");
	asm volatile("int $14");
}

#else

void
handler(struct UTrapframe *utf)
{
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
	sys_env_destroy(sys_getenvid());
}

void
umain(int argc, char **argv)
{
	set_pgfault_handler(handler);
	
	*(int*)0xDeadBeef = 0;
}
#endif
