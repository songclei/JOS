#ifdef CHALLENGE
#include <inc/lib.h>


extern void _exception_upcall(void);

void (*_exception_handler[EXCEPTION_NUM])(struct UTrapframe *utf);


void set_exception_handler(void (*handler)(struct UTrapframe *utf),
						int exception_num)
{
	int r;
	// fist time to set exception handler, so we need to alloc
	// an exception stack
	if(thisenv->env_exception_upcall == 0) {
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), 
			PTE_P|PTE_U|PTE_W)) < 0)
			panic("sys_page_alloc: %e", r);

		if((r = sys_env_set_exception_upcall(0, _exception_upcall)) < 0)
			panic("sys_env_set_exception_upcall: %e", r);
	}

	_exception_handler[exception_num] = handler;
	
	if((r = sys_env_set_exception_handler(0, exception_num)) < 0)
		panic("sys_env_set_exception_handler: %e", r);
}
#endif

