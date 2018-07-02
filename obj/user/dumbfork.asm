
obj/user/dumbfork.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 aa 01 00 00       	call   8001db <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 78 0d 00 00       	call   800dc2 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 c0 20 80 00       	push   $0x8020c0
  800057:	6a 20                	push   $0x20
  800059:	68 d3 20 80 00       	push   $0x8020d3
  80005e:	e8 d8 01 00 00       	call   80023b <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 8f 0d 00 00       	call   800e05 <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 e3 20 80 00       	push   $0x8020e3
  800083:	6a 22                	push   $0x22
  800085:	68 d3 20 80 00       	push   $0x8020d3
  80008a:	e8 ac 01 00 00       	call   80023b <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 38 0a 00 00       	call   800ada <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 96 0d 00 00       	call   800e47 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 f4 20 80 00       	push   $0x8020f4
  8000be:	6a 25                	push   $0x25
  8000c0:	68 d3 20 80 00       	push   $0x8020d3
  8000c5:	e8 71 01 00 00       	call   80023b <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <dumbfork+0x27>
		panic("sys_exofork: %e", envid);
  8000e6:	50                   	push   %eax
  8000e7:	68 07 21 80 00       	push   $0x802107
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 d3 20 80 00       	push   $0x8020d3
  8000f3:	e8 43 01 00 00       	call   80023b <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1e                	jne    80011c <dumbfork+0x4b>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 81 0c 00 00       	call   800d84 <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800115:	b8 00 00 00 00       	mov    $0x0,%eax
  80011a:	eb 60                	jmp    80017c <dumbfork+0xab>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800123:	eb 14                	jmp    800139 <dumbfork+0x68>
		duppage(envid, addr);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	52                   	push   %edx
  800129:	56                   	push   %esi
  80012a:	e8 04 ff ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80012f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013c:	81 fa 00 60 80 00    	cmp    $0x806000,%edx
  800142:	72 e1                	jb     800125 <dumbfork+0x54>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80014f:	50                   	push   %eax
  800150:	53                   	push   %ebx
  800151:	e8 dd fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	6a 02                	push   $0x2
  80015b:	53                   	push   %ebx
  80015c:	e8 28 0d 00 00       	call   800e89 <sys_env_set_status>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	79 12                	jns    80017a <dumbfork+0xa9>
		panic("sys_env_set_status: %e", r);
  800168:	50                   	push   %eax
  800169:	68 17 21 80 00       	push   $0x802117
  80016e:	6a 4c                	push   $0x4c
  800170:	68 d3 20 80 00       	push   $0x8020d3
  800175:	e8 c1 00 00 00       	call   80023b <_panic>

	return envid;
  80017a:	89 d8                	mov    %ebx,%eax
}
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80018c:	e8 40 ff ff ff       	call   8000d1 <dumbfork>
  800191:	89 c7                	mov    %eax,%edi
  800193:	85 c0                	test   %eax,%eax
  800195:	be 35 21 80 00       	mov    $0x802135,%esi
  80019a:	b8 2e 21 80 00       	mov    $0x80212e,%eax
  80019f:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a7:	eb 1a                	jmp    8001c3 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a9:	83 ec 04             	sub    $0x4,%esp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	68 3b 21 80 00       	push   $0x80213b
  8001b3:	e8 5c 01 00 00       	call   800314 <cprintf>
		sys_yield();
  8001b8:	e8 e6 0b 00 00       	call   800da3 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001bd:	83 c3 01             	add    $0x1,%ebx
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 ff                	test   %edi,%edi
  8001c5:	74 07                	je     8001ce <umain+0x4b>
  8001c7:	83 fb 09             	cmp    $0x9,%ebx
  8001ca:	7e dd                	jle    8001a9 <umain+0x26>
  8001cc:	eb 05                	jmp    8001d3 <umain+0x50>
  8001ce:	83 fb 13             	cmp    $0x13,%ebx
  8001d1:	7e d6                	jle    8001a9 <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e6:	e8 99 0b 00 00       	call   800d84 <sys_getenvid>
  8001eb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001f3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f8:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001fd:	85 db                	test   %ebx,%ebx
  8001ff:	7e 07                	jle    800208 <libmain+0x2d>
		binaryname = argv[0];
  800201:	8b 06                	mov    (%esi),%eax
  800203:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	53                   	push   %ebx
  80020d:	e8 71 ff ff ff       	call   800183 <umain>

	// exit gracefully
	exit();
  800212:	e8 0a 00 00 00       	call   800221 <exit>
}
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800227:	e8 52 0f 00 00       	call   80117e <close_all>
	sys_env_destroy(0);
  80022c:	83 ec 0c             	sub    $0xc,%esp
  80022f:	6a 00                	push   $0x0
  800231:	e8 0d 0b 00 00       	call   800d43 <sys_env_destroy>
}
  800236:	83 c4 10             	add    $0x10,%esp
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800240:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800243:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800249:	e8 36 0b 00 00       	call   800d84 <sys_getenvid>
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	ff 75 0c             	pushl  0xc(%ebp)
  800254:	ff 75 08             	pushl  0x8(%ebp)
  800257:	56                   	push   %esi
  800258:	50                   	push   %eax
  800259:	68 58 21 80 00       	push   $0x802158
  80025e:	e8 b1 00 00 00       	call   800314 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800263:	83 c4 18             	add    $0x18,%esp
  800266:	53                   	push   %ebx
  800267:	ff 75 10             	pushl  0x10(%ebp)
  80026a:	e8 54 00 00 00       	call   8002c3 <vcprintf>
	cprintf("\n");
  80026f:	c7 04 24 4b 21 80 00 	movl   $0x80214b,(%esp)
  800276:	e8 99 00 00 00       	call   800314 <cprintf>
  80027b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027e:	cc                   	int3   
  80027f:	eb fd                	jmp    80027e <_panic+0x43>

00800281 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	53                   	push   %ebx
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80028b:	8b 13                	mov    (%ebx),%edx
  80028d:	8d 42 01             	lea    0x1(%edx),%eax
  800290:	89 03                	mov    %eax,(%ebx)
  800292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800295:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800299:	3d ff 00 00 00       	cmp    $0xff,%eax
  80029e:	75 1a                	jne    8002ba <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	68 ff 00 00 00       	push   $0xff
  8002a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ab:	50                   	push   %eax
  8002ac:	e8 55 0a 00 00       	call   800d06 <sys_cputs>
		b->idx = 0;
  8002b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d3:	00 00 00 
	b.cnt = 0;
  8002d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e0:	ff 75 0c             	pushl  0xc(%ebp)
  8002e3:	ff 75 08             	pushl  0x8(%ebp)
  8002e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ec:	50                   	push   %eax
  8002ed:	68 81 02 80 00       	push   $0x800281
  8002f2:	e8 54 01 00 00       	call   80044b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f7:	83 c4 08             	add    $0x8,%esp
  8002fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800300:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800306:	50                   	push   %eax
  800307:	e8 fa 09 00 00       	call   800d06 <sys_cputs>

	return b.cnt;
}
  80030c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80031a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80031d:	50                   	push   %eax
  80031e:	ff 75 08             	pushl  0x8(%ebp)
  800321:	e8 9d ff ff ff       	call   8002c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 1c             	sub    $0x1c,%esp
  800331:	89 c7                	mov    %eax,%edi
  800333:	89 d6                	mov    %edx,%esi
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	8b 55 0c             	mov    0xc(%ebp),%edx
  80033b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800341:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800344:	bb 00 00 00 00       	mov    $0x0,%ebx
  800349:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80034c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034f:	39 d3                	cmp    %edx,%ebx
  800351:	72 05                	jb     800358 <printnum+0x30>
  800353:	39 45 10             	cmp    %eax,0x10(%ebp)
  800356:	77 45                	ja     80039d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800358:	83 ec 0c             	sub    $0xc,%esp
  80035b:	ff 75 18             	pushl  0x18(%ebp)
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800364:	53                   	push   %ebx
  800365:	ff 75 10             	pushl  0x10(%ebp)
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80036e:	ff 75 e0             	pushl  -0x20(%ebp)
  800371:	ff 75 dc             	pushl  -0x24(%ebp)
  800374:	ff 75 d8             	pushl  -0x28(%ebp)
  800377:	e8 a4 1a 00 00       	call   801e20 <__udivdi3>
  80037c:	83 c4 18             	add    $0x18,%esp
  80037f:	52                   	push   %edx
  800380:	50                   	push   %eax
  800381:	89 f2                	mov    %esi,%edx
  800383:	89 f8                	mov    %edi,%eax
  800385:	e8 9e ff ff ff       	call   800328 <printnum>
  80038a:	83 c4 20             	add    $0x20,%esp
  80038d:	eb 18                	jmp    8003a7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038f:	83 ec 08             	sub    $0x8,%esp
  800392:	56                   	push   %esi
  800393:	ff 75 18             	pushl  0x18(%ebp)
  800396:	ff d7                	call   *%edi
  800398:	83 c4 10             	add    $0x10,%esp
  80039b:	eb 03                	jmp    8003a0 <printnum+0x78>
  80039d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a0:	83 eb 01             	sub    $0x1,%ebx
  8003a3:	85 db                	test   %ebx,%ebx
  8003a5:	7f e8                	jg     80038f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a7:	83 ec 08             	sub    $0x8,%esp
  8003aa:	56                   	push   %esi
  8003ab:	83 ec 04             	sub    $0x4,%esp
  8003ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ba:	e8 91 1b 00 00       	call   801f50 <__umoddi3>
  8003bf:	83 c4 14             	add    $0x14,%esp
  8003c2:	0f be 80 7b 21 80 00 	movsbl 0x80217b(%eax),%eax
  8003c9:	50                   	push   %eax
  8003ca:	ff d7                	call   *%edi
}
  8003cc:	83 c4 10             	add    $0x10,%esp
  8003cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d2:	5b                   	pop    %ebx
  8003d3:	5e                   	pop    %esi
  8003d4:	5f                   	pop    %edi
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003da:	83 fa 01             	cmp    $0x1,%edx
  8003dd:	7e 0e                	jle    8003ed <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003df:	8b 10                	mov    (%eax),%edx
  8003e1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e4:	89 08                	mov    %ecx,(%eax)
  8003e6:	8b 02                	mov    (%edx),%eax
  8003e8:	8b 52 04             	mov    0x4(%edx),%edx
  8003eb:	eb 22                	jmp    80040f <getuint+0x38>
	else if (lflag)
  8003ed:	85 d2                	test   %edx,%edx
  8003ef:	74 10                	je     800401 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f1:	8b 10                	mov    (%eax),%edx
  8003f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f6:	89 08                	mov    %ecx,(%eax)
  8003f8:	8b 02                	mov    (%edx),%eax
  8003fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ff:	eb 0e                	jmp    80040f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800401:	8b 10                	mov    (%eax),%edx
  800403:	8d 4a 04             	lea    0x4(%edx),%ecx
  800406:	89 08                	mov    %ecx,(%eax)
  800408:	8b 02                	mov    (%edx),%eax
  80040a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040f:	5d                   	pop    %ebp
  800410:	c3                   	ret    

00800411 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800417:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80041b:	8b 10                	mov    (%eax),%edx
  80041d:	3b 50 04             	cmp    0x4(%eax),%edx
  800420:	73 0a                	jae    80042c <sprintputch+0x1b>
		*b->buf++ = ch;
  800422:	8d 4a 01             	lea    0x1(%edx),%ecx
  800425:	89 08                	mov    %ecx,(%eax)
  800427:	8b 45 08             	mov    0x8(%ebp),%eax
  80042a:	88 02                	mov    %al,(%edx)
}
  80042c:	5d                   	pop    %ebp
  80042d:	c3                   	ret    

0080042e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800434:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800437:	50                   	push   %eax
  800438:	ff 75 10             	pushl  0x10(%ebp)
  80043b:	ff 75 0c             	pushl  0xc(%ebp)
  80043e:	ff 75 08             	pushl  0x8(%ebp)
  800441:	e8 05 00 00 00       	call   80044b <vprintfmt>
	va_end(ap);
}
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	c9                   	leave  
  80044a:	c3                   	ret    

0080044b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044b:	55                   	push   %ebp
  80044c:	89 e5                	mov    %esp,%ebp
  80044e:	57                   	push   %edi
  80044f:	56                   	push   %esi
  800450:	53                   	push   %ebx
  800451:	83 ec 2c             	sub    $0x2c,%esp
  800454:	8b 75 08             	mov    0x8(%ebp),%esi
  800457:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80045a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80045d:	eb 12                	jmp    800471 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045f:	85 c0                	test   %eax,%eax
  800461:	0f 84 38 04 00 00    	je     80089f <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	53                   	push   %ebx
  80046b:	50                   	push   %eax
  80046c:	ff d6                	call   *%esi
  80046e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800471:	83 c7 01             	add    $0x1,%edi
  800474:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800478:	83 f8 25             	cmp    $0x25,%eax
  80047b:	75 e2                	jne    80045f <vprintfmt+0x14>
  80047d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800481:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800488:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80048f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800496:	ba 00 00 00 00       	mov    $0x0,%edx
  80049b:	eb 07                	jmp    8004a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8d 47 01             	lea    0x1(%edi),%eax
  8004a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004aa:	0f b6 07             	movzbl (%edi),%eax
  8004ad:	0f b6 c8             	movzbl %al,%ecx
  8004b0:	83 e8 23             	sub    $0x23,%eax
  8004b3:	3c 55                	cmp    $0x55,%al
  8004b5:	0f 87 c9 03 00 00    	ja     800884 <vprintfmt+0x439>
  8004bb:	0f b6 c0             	movzbl %al,%eax
  8004be:	ff 24 85 c0 22 80 00 	jmp    *0x8022c0(,%eax,4)
  8004c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004cc:	eb d6                	jmp    8004a4 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  8004ce:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  8004d5:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  8004db:	eb 94                	jmp    800471 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  8004dd:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  8004e4:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  8004ea:	eb 85                	jmp    800471 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  8004ec:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  8004f3:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  8004f9:	e9 73 ff ff ff       	jmp    800471 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  8004fe:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  800505:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  80050b:	e9 61 ff ff ff       	jmp    800471 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  800510:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800517:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  80051d:	e9 4f ff ff ff       	jmp    800471 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  800522:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800529:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80052f:	e9 3d ff ff ff       	jmp    800471 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  800534:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  80053b:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  800541:	e9 2b ff ff ff       	jmp    800471 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  800546:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  80054d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800550:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  800553:	e9 19 ff ff ff       	jmp    800471 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800558:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  80055f:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  800565:	e9 07 ff ff ff       	jmp    800471 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  80056a:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  800571:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800574:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800577:	e9 f5 fe ff ff       	jmp    800471 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057f:	b8 00 00 00 00       	mov    $0x0,%eax
  800584:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800587:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80058a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80058e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800591:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800594:	83 fa 09             	cmp    $0x9,%edx
  800597:	77 3f                	ja     8005d8 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800599:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80059c:	eb e9                	jmp    800587 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8d 48 04             	lea    0x4(%eax),%ecx
  8005a4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005a7:	8b 00                	mov    (%eax),%eax
  8005a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005af:	eb 2d                	jmp    8005de <vprintfmt+0x193>
  8005b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b4:	85 c0                	test   %eax,%eax
  8005b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005bb:	0f 49 c8             	cmovns %eax,%ecx
  8005be:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c4:	e9 db fe ff ff       	jmp    8004a4 <vprintfmt+0x59>
  8005c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005cc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005d3:	e9 cc fe ff ff       	jmp    8004a4 <vprintfmt+0x59>
  8005d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005db:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e2:	0f 89 bc fe ff ff    	jns    8004a4 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ee:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005f5:	e9 aa fe ff ff       	jmp    8004a4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005fa:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800600:	e9 9f fe ff ff       	jmp    8004a4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8d 50 04             	lea    0x4(%eax),%edx
  80060b:	89 55 14             	mov    %edx,0x14(%ebp)
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	ff 30                	pushl  (%eax)
  800614:	ff d6                	call   *%esi
			break;
  800616:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800619:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80061c:	e9 50 fe ff ff       	jmp    800471 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8d 50 04             	lea    0x4(%eax),%edx
  800627:	89 55 14             	mov    %edx,0x14(%ebp)
  80062a:	8b 00                	mov    (%eax),%eax
  80062c:	99                   	cltd   
  80062d:	31 d0                	xor    %edx,%eax
  80062f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800631:	83 f8 0f             	cmp    $0xf,%eax
  800634:	7f 0b                	jg     800641 <vprintfmt+0x1f6>
  800636:	8b 14 85 20 24 80 00 	mov    0x802420(,%eax,4),%edx
  80063d:	85 d2                	test   %edx,%edx
  80063f:	75 18                	jne    800659 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  800641:	50                   	push   %eax
  800642:	68 93 21 80 00       	push   $0x802193
  800647:	53                   	push   %ebx
  800648:	56                   	push   %esi
  800649:	e8 e0 fd ff ff       	call   80042e <printfmt>
  80064e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800651:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800654:	e9 18 fe ff ff       	jmp    800471 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800659:	52                   	push   %edx
  80065a:	68 51 25 80 00       	push   $0x802551
  80065f:	53                   	push   %ebx
  800660:	56                   	push   %esi
  800661:	e8 c8 fd ff ff       	call   80042e <printfmt>
  800666:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800669:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80066c:	e9 00 fe ff ff       	jmp    800471 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8d 50 04             	lea    0x4(%eax),%edx
  800677:	89 55 14             	mov    %edx,0x14(%ebp)
  80067a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80067c:	85 ff                	test   %edi,%edi
  80067e:	b8 8c 21 80 00       	mov    $0x80218c,%eax
  800683:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800686:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80068a:	0f 8e 94 00 00 00    	jle    800724 <vprintfmt+0x2d9>
  800690:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800694:	0f 84 98 00 00 00    	je     800732 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  80069a:	83 ec 08             	sub    $0x8,%esp
  80069d:	ff 75 d0             	pushl  -0x30(%ebp)
  8006a0:	57                   	push   %edi
  8006a1:	e8 81 02 00 00       	call   800927 <strnlen>
  8006a6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006a9:	29 c1                	sub    %eax,%ecx
  8006ab:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006ae:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006b1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006bb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bd:	eb 0f                	jmp    8006ce <vprintfmt+0x283>
					putch(padc, putdat);
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	53                   	push   %ebx
  8006c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c8:	83 ef 01             	sub    $0x1,%edi
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	85 ff                	test   %edi,%edi
  8006d0:	7f ed                	jg     8006bf <vprintfmt+0x274>
  8006d2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006d5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006d8:	85 c9                	test   %ecx,%ecx
  8006da:	b8 00 00 00 00       	mov    $0x0,%eax
  8006df:	0f 49 c1             	cmovns %ecx,%eax
  8006e2:	29 c1                	sub    %eax,%ecx
  8006e4:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006ea:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ed:	89 cb                	mov    %ecx,%ebx
  8006ef:	eb 4d                	jmp    80073e <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006f1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006f5:	74 1b                	je     800712 <vprintfmt+0x2c7>
  8006f7:	0f be c0             	movsbl %al,%eax
  8006fa:	83 e8 20             	sub    $0x20,%eax
  8006fd:	83 f8 5e             	cmp    $0x5e,%eax
  800700:	76 10                	jbe    800712 <vprintfmt+0x2c7>
					putch('?', putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	ff 75 0c             	pushl  0xc(%ebp)
  800708:	6a 3f                	push   $0x3f
  80070a:	ff 55 08             	call   *0x8(%ebp)
  80070d:	83 c4 10             	add    $0x10,%esp
  800710:	eb 0d                	jmp    80071f <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	ff 75 0c             	pushl  0xc(%ebp)
  800718:	52                   	push   %edx
  800719:	ff 55 08             	call   *0x8(%ebp)
  80071c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071f:	83 eb 01             	sub    $0x1,%ebx
  800722:	eb 1a                	jmp    80073e <vprintfmt+0x2f3>
  800724:	89 75 08             	mov    %esi,0x8(%ebp)
  800727:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80072a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80072d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800730:	eb 0c                	jmp    80073e <vprintfmt+0x2f3>
  800732:	89 75 08             	mov    %esi,0x8(%ebp)
  800735:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800738:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80073e:	83 c7 01             	add    $0x1,%edi
  800741:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800745:	0f be d0             	movsbl %al,%edx
  800748:	85 d2                	test   %edx,%edx
  80074a:	74 23                	je     80076f <vprintfmt+0x324>
  80074c:	85 f6                	test   %esi,%esi
  80074e:	78 a1                	js     8006f1 <vprintfmt+0x2a6>
  800750:	83 ee 01             	sub    $0x1,%esi
  800753:	79 9c                	jns    8006f1 <vprintfmt+0x2a6>
  800755:	89 df                	mov    %ebx,%edi
  800757:	8b 75 08             	mov    0x8(%ebp),%esi
  80075a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80075d:	eb 18                	jmp    800777 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80075f:	83 ec 08             	sub    $0x8,%esp
  800762:	53                   	push   %ebx
  800763:	6a 20                	push   $0x20
  800765:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800767:	83 ef 01             	sub    $0x1,%edi
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	eb 08                	jmp    800777 <vprintfmt+0x32c>
  80076f:	89 df                	mov    %ebx,%edi
  800771:	8b 75 08             	mov    0x8(%ebp),%esi
  800774:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800777:	85 ff                	test   %edi,%edi
  800779:	7f e4                	jg     80075f <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077e:	e9 ee fc ff ff       	jmp    800471 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800783:	83 fa 01             	cmp    $0x1,%edx
  800786:	7e 16                	jle    80079e <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800788:	8b 45 14             	mov    0x14(%ebp),%eax
  80078b:	8d 50 08             	lea    0x8(%eax),%edx
  80078e:	89 55 14             	mov    %edx,0x14(%ebp)
  800791:	8b 50 04             	mov    0x4(%eax),%edx
  800794:	8b 00                	mov    (%eax),%eax
  800796:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800799:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80079c:	eb 32                	jmp    8007d0 <vprintfmt+0x385>
	else if (lflag)
  80079e:	85 d2                	test   %edx,%edx
  8007a0:	74 18                	je     8007ba <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8007a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a5:	8d 50 04             	lea    0x4(%eax),%edx
  8007a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ab:	8b 00                	mov    (%eax),%eax
  8007ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b0:	89 c1                	mov    %eax,%ecx
  8007b2:	c1 f9 1f             	sar    $0x1f,%ecx
  8007b5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b8:	eb 16                	jmp    8007d0 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  8007ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bd:	8d 50 04             	lea    0x4(%eax),%edx
  8007c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c3:	8b 00                	mov    (%eax),%eax
  8007c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c8:	89 c1                	mov    %eax,%ecx
  8007ca:	c1 f9 1f             	sar    $0x1f,%ecx
  8007cd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007d3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007d6:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007db:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007df:	79 6f                	jns    800850 <vprintfmt+0x405>
				putch('-', putdat);
  8007e1:	83 ec 08             	sub    $0x8,%esp
  8007e4:	53                   	push   %ebx
  8007e5:	6a 2d                	push   $0x2d
  8007e7:	ff d6                	call   *%esi
				num = -(long long) num;
  8007e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007ef:	f7 d8                	neg    %eax
  8007f1:	83 d2 00             	adc    $0x0,%edx
  8007f4:	f7 da                	neg    %edx
  8007f6:	83 c4 10             	add    $0x10,%esp
  8007f9:	eb 55                	jmp    800850 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fe:	e8 d4 fb ff ff       	call   8003d7 <getuint>
			base = 10;
  800803:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800808:	eb 46                	jmp    800850 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80080a:	8d 45 14             	lea    0x14(%ebp),%eax
  80080d:	e8 c5 fb ff ff       	call   8003d7 <getuint>
			base = 8;
  800812:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800817:	eb 37                	jmp    800850 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800819:	83 ec 08             	sub    $0x8,%esp
  80081c:	53                   	push   %ebx
  80081d:	6a 30                	push   $0x30
  80081f:	ff d6                	call   *%esi
			putch('x', putdat);
  800821:	83 c4 08             	add    $0x8,%esp
  800824:	53                   	push   %ebx
  800825:	6a 78                	push   $0x78
  800827:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800829:	8b 45 14             	mov    0x14(%ebp),%eax
  80082c:	8d 50 04             	lea    0x4(%eax),%edx
  80082f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800832:	8b 00                	mov    (%eax),%eax
  800834:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800839:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80083c:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800841:	eb 0d                	jmp    800850 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800843:	8d 45 14             	lea    0x14(%ebp),%eax
  800846:	e8 8c fb ff ff       	call   8003d7 <getuint>
			base = 16;
  80084b:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800850:	83 ec 0c             	sub    $0xc,%esp
  800853:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800857:	51                   	push   %ecx
  800858:	ff 75 e0             	pushl  -0x20(%ebp)
  80085b:	57                   	push   %edi
  80085c:	52                   	push   %edx
  80085d:	50                   	push   %eax
  80085e:	89 da                	mov    %ebx,%edx
  800860:	89 f0                	mov    %esi,%eax
  800862:	e8 c1 fa ff ff       	call   800328 <printnum>
			break;
  800867:	83 c4 20             	add    $0x20,%esp
  80086a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80086d:	e9 ff fb ff ff       	jmp    800471 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800872:	83 ec 08             	sub    $0x8,%esp
  800875:	53                   	push   %ebx
  800876:	51                   	push   %ecx
  800877:	ff d6                	call   *%esi
			break;
  800879:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80087f:	e9 ed fb ff ff       	jmp    800471 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800884:	83 ec 08             	sub    $0x8,%esp
  800887:	53                   	push   %ebx
  800888:	6a 25                	push   $0x25
  80088a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80088c:	83 c4 10             	add    $0x10,%esp
  80088f:	eb 03                	jmp    800894 <vprintfmt+0x449>
  800891:	83 ef 01             	sub    $0x1,%edi
  800894:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800898:	75 f7                	jne    800891 <vprintfmt+0x446>
  80089a:	e9 d2 fb ff ff       	jmp    800471 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80089f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a2:	5b                   	pop    %ebx
  8008a3:	5e                   	pop    %esi
  8008a4:	5f                   	pop    %edi
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	83 ec 18             	sub    $0x18,%esp
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008b6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008c4:	85 c0                	test   %eax,%eax
  8008c6:	74 26                	je     8008ee <vsnprintf+0x47>
  8008c8:	85 d2                	test   %edx,%edx
  8008ca:	7e 22                	jle    8008ee <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008cc:	ff 75 14             	pushl  0x14(%ebp)
  8008cf:	ff 75 10             	pushl  0x10(%ebp)
  8008d2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d5:	50                   	push   %eax
  8008d6:	68 11 04 80 00       	push   $0x800411
  8008db:	e8 6b fb ff ff       	call   80044b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	eb 05                	jmp    8008f3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    

008008f5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008fb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008fe:	50                   	push   %eax
  8008ff:	ff 75 10             	pushl  0x10(%ebp)
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	ff 75 08             	pushl  0x8(%ebp)
  800908:	e8 9a ff ff ff       	call   8008a7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    

0080090f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
  80091a:	eb 03                	jmp    80091f <strlen+0x10>
		n++;
  80091c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80091f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800923:	75 f7                	jne    80091c <strlen+0xd>
		n++;
	return n;
}
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800930:	ba 00 00 00 00       	mov    $0x0,%edx
  800935:	eb 03                	jmp    80093a <strnlen+0x13>
		n++;
  800937:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093a:	39 c2                	cmp    %eax,%edx
  80093c:	74 08                	je     800946 <strnlen+0x1f>
  80093e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800942:	75 f3                	jne    800937 <strnlen+0x10>
  800944:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	53                   	push   %ebx
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800952:	89 c2                	mov    %eax,%edx
  800954:	83 c2 01             	add    $0x1,%edx
  800957:	83 c1 01             	add    $0x1,%ecx
  80095a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80095e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800961:	84 db                	test   %bl,%bl
  800963:	75 ef                	jne    800954 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800965:	5b                   	pop    %ebx
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	53                   	push   %ebx
  80096c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80096f:	53                   	push   %ebx
  800970:	e8 9a ff ff ff       	call   80090f <strlen>
  800975:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800978:	ff 75 0c             	pushl  0xc(%ebp)
  80097b:	01 d8                	add    %ebx,%eax
  80097d:	50                   	push   %eax
  80097e:	e8 c5 ff ff ff       	call   800948 <strcpy>
	return dst;
}
  800983:	89 d8                	mov    %ebx,%eax
  800985:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800988:	c9                   	leave  
  800989:	c3                   	ret    

0080098a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	56                   	push   %esi
  80098e:	53                   	push   %ebx
  80098f:	8b 75 08             	mov    0x8(%ebp),%esi
  800992:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800995:	89 f3                	mov    %esi,%ebx
  800997:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80099a:	89 f2                	mov    %esi,%edx
  80099c:	eb 0f                	jmp    8009ad <strncpy+0x23>
		*dst++ = *src;
  80099e:	83 c2 01             	add    $0x1,%edx
  8009a1:	0f b6 01             	movzbl (%ecx),%eax
  8009a4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a7:	80 39 01             	cmpb   $0x1,(%ecx)
  8009aa:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ad:	39 da                	cmp    %ebx,%edx
  8009af:	75 ed                	jne    80099e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009b1:	89 f0                	mov    %esi,%eax
  8009b3:	5b                   	pop    %ebx
  8009b4:	5e                   	pop    %esi
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	56                   	push   %esi
  8009bb:	53                   	push   %ebx
  8009bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8009bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c2:	8b 55 10             	mov    0x10(%ebp),%edx
  8009c5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c7:	85 d2                	test   %edx,%edx
  8009c9:	74 21                	je     8009ec <strlcpy+0x35>
  8009cb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009cf:	89 f2                	mov    %esi,%edx
  8009d1:	eb 09                	jmp    8009dc <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009d3:	83 c2 01             	add    $0x1,%edx
  8009d6:	83 c1 01             	add    $0x1,%ecx
  8009d9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009dc:	39 c2                	cmp    %eax,%edx
  8009de:	74 09                	je     8009e9 <strlcpy+0x32>
  8009e0:	0f b6 19             	movzbl (%ecx),%ebx
  8009e3:	84 db                	test   %bl,%bl
  8009e5:	75 ec                	jne    8009d3 <strlcpy+0x1c>
  8009e7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009e9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ec:	29 f0                	sub    %esi,%eax
}
  8009ee:	5b                   	pop    %ebx
  8009ef:	5e                   	pop    %esi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009fb:	eb 06                	jmp    800a03 <strcmp+0x11>
		p++, q++;
  8009fd:	83 c1 01             	add    $0x1,%ecx
  800a00:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a03:	0f b6 01             	movzbl (%ecx),%eax
  800a06:	84 c0                	test   %al,%al
  800a08:	74 04                	je     800a0e <strcmp+0x1c>
  800a0a:	3a 02                	cmp    (%edx),%al
  800a0c:	74 ef                	je     8009fd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0e:	0f b6 c0             	movzbl %al,%eax
  800a11:	0f b6 12             	movzbl (%edx),%edx
  800a14:	29 d0                	sub    %edx,%eax
}
  800a16:	5d                   	pop    %ebp
  800a17:	c3                   	ret    

00800a18 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	53                   	push   %ebx
  800a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a22:	89 c3                	mov    %eax,%ebx
  800a24:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a27:	eb 06                	jmp    800a2f <strncmp+0x17>
		n--, p++, q++;
  800a29:	83 c0 01             	add    $0x1,%eax
  800a2c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a2f:	39 d8                	cmp    %ebx,%eax
  800a31:	74 15                	je     800a48 <strncmp+0x30>
  800a33:	0f b6 08             	movzbl (%eax),%ecx
  800a36:	84 c9                	test   %cl,%cl
  800a38:	74 04                	je     800a3e <strncmp+0x26>
  800a3a:	3a 0a                	cmp    (%edx),%cl
  800a3c:	74 eb                	je     800a29 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3e:	0f b6 00             	movzbl (%eax),%eax
  800a41:	0f b6 12             	movzbl (%edx),%edx
  800a44:	29 d0                	sub    %edx,%eax
  800a46:	eb 05                	jmp    800a4d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a48:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	8b 45 08             	mov    0x8(%ebp),%eax
  800a56:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a5a:	eb 07                	jmp    800a63 <strchr+0x13>
		if (*s == c)
  800a5c:	38 ca                	cmp    %cl,%dl
  800a5e:	74 0f                	je     800a6f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a60:	83 c0 01             	add    $0x1,%eax
  800a63:	0f b6 10             	movzbl (%eax),%edx
  800a66:	84 d2                	test   %dl,%dl
  800a68:	75 f2                	jne    800a5c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
  800a77:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a7b:	eb 03                	jmp    800a80 <strfind+0xf>
  800a7d:	83 c0 01             	add    $0x1,%eax
  800a80:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a83:	38 ca                	cmp    %cl,%dl
  800a85:	74 04                	je     800a8b <strfind+0x1a>
  800a87:	84 d2                	test   %dl,%dl
  800a89:	75 f2                	jne    800a7d <strfind+0xc>
			break;
	return (char *) s;
}
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	57                   	push   %edi
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
  800a93:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a96:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a99:	85 c9                	test   %ecx,%ecx
  800a9b:	74 36                	je     800ad3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a9d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa3:	75 28                	jne    800acd <memset+0x40>
  800aa5:	f6 c1 03             	test   $0x3,%cl
  800aa8:	75 23                	jne    800acd <memset+0x40>
		c &= 0xFF;
  800aaa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aae:	89 d3                	mov    %edx,%ebx
  800ab0:	c1 e3 08             	shl    $0x8,%ebx
  800ab3:	89 d6                	mov    %edx,%esi
  800ab5:	c1 e6 18             	shl    $0x18,%esi
  800ab8:	89 d0                	mov    %edx,%eax
  800aba:	c1 e0 10             	shl    $0x10,%eax
  800abd:	09 f0                	or     %esi,%eax
  800abf:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ac1:	89 d8                	mov    %ebx,%eax
  800ac3:	09 d0                	or     %edx,%eax
  800ac5:	c1 e9 02             	shr    $0x2,%ecx
  800ac8:	fc                   	cld    
  800ac9:	f3 ab                	rep stos %eax,%es:(%edi)
  800acb:	eb 06                	jmp    800ad3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800acd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad0:	fc                   	cld    
  800ad1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ad3:	89 f8                	mov    %edi,%eax
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5f                   	pop    %edi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae8:	39 c6                	cmp    %eax,%esi
  800aea:	73 35                	jae    800b21 <memmove+0x47>
  800aec:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aef:	39 d0                	cmp    %edx,%eax
  800af1:	73 2e                	jae    800b21 <memmove+0x47>
		s += n;
		d += n;
  800af3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af6:	89 d6                	mov    %edx,%esi
  800af8:	09 fe                	or     %edi,%esi
  800afa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b00:	75 13                	jne    800b15 <memmove+0x3b>
  800b02:	f6 c1 03             	test   $0x3,%cl
  800b05:	75 0e                	jne    800b15 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b07:	83 ef 04             	sub    $0x4,%edi
  800b0a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b0d:	c1 e9 02             	shr    $0x2,%ecx
  800b10:	fd                   	std    
  800b11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b13:	eb 09                	jmp    800b1e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b15:	83 ef 01             	sub    $0x1,%edi
  800b18:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b1b:	fd                   	std    
  800b1c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b1e:	fc                   	cld    
  800b1f:	eb 1d                	jmp    800b3e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b21:	89 f2                	mov    %esi,%edx
  800b23:	09 c2                	or     %eax,%edx
  800b25:	f6 c2 03             	test   $0x3,%dl
  800b28:	75 0f                	jne    800b39 <memmove+0x5f>
  800b2a:	f6 c1 03             	test   $0x3,%cl
  800b2d:	75 0a                	jne    800b39 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b2f:	c1 e9 02             	shr    $0x2,%ecx
  800b32:	89 c7                	mov    %eax,%edi
  800b34:	fc                   	cld    
  800b35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b37:	eb 05                	jmp    800b3e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b39:	89 c7                	mov    %eax,%edi
  800b3b:	fc                   	cld    
  800b3c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b45:	ff 75 10             	pushl  0x10(%ebp)
  800b48:	ff 75 0c             	pushl  0xc(%ebp)
  800b4b:	ff 75 08             	pushl  0x8(%ebp)
  800b4e:	e8 87 ff ff ff       	call   800ada <memmove>
}
  800b53:	c9                   	leave  
  800b54:	c3                   	ret    

00800b55 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
  800b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b60:	89 c6                	mov    %eax,%esi
  800b62:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b65:	eb 1a                	jmp    800b81 <memcmp+0x2c>
		if (*s1 != *s2)
  800b67:	0f b6 08             	movzbl (%eax),%ecx
  800b6a:	0f b6 1a             	movzbl (%edx),%ebx
  800b6d:	38 d9                	cmp    %bl,%cl
  800b6f:	74 0a                	je     800b7b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b71:	0f b6 c1             	movzbl %cl,%eax
  800b74:	0f b6 db             	movzbl %bl,%ebx
  800b77:	29 d8                	sub    %ebx,%eax
  800b79:	eb 0f                	jmp    800b8a <memcmp+0x35>
		s1++, s2++;
  800b7b:	83 c0 01             	add    $0x1,%eax
  800b7e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b81:	39 f0                	cmp    %esi,%eax
  800b83:	75 e2                	jne    800b67 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	53                   	push   %ebx
  800b92:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b95:	89 c1                	mov    %eax,%ecx
  800b97:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b9a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b9e:	eb 0a                	jmp    800baa <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba0:	0f b6 10             	movzbl (%eax),%edx
  800ba3:	39 da                	cmp    %ebx,%edx
  800ba5:	74 07                	je     800bae <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ba7:	83 c0 01             	add    $0x1,%eax
  800baa:	39 c8                	cmp    %ecx,%eax
  800bac:	72 f2                	jb     800ba0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bae:	5b                   	pop    %ebx
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bbd:	eb 03                	jmp    800bc2 <strtol+0x11>
		s++;
  800bbf:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc2:	0f b6 01             	movzbl (%ecx),%eax
  800bc5:	3c 20                	cmp    $0x20,%al
  800bc7:	74 f6                	je     800bbf <strtol+0xe>
  800bc9:	3c 09                	cmp    $0x9,%al
  800bcb:	74 f2                	je     800bbf <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bcd:	3c 2b                	cmp    $0x2b,%al
  800bcf:	75 0a                	jne    800bdb <strtol+0x2a>
		s++;
  800bd1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bd4:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd9:	eb 11                	jmp    800bec <strtol+0x3b>
  800bdb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800be0:	3c 2d                	cmp    $0x2d,%al
  800be2:	75 08                	jne    800bec <strtol+0x3b>
		s++, neg = 1;
  800be4:	83 c1 01             	add    $0x1,%ecx
  800be7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bec:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bf2:	75 15                	jne    800c09 <strtol+0x58>
  800bf4:	80 39 30             	cmpb   $0x30,(%ecx)
  800bf7:	75 10                	jne    800c09 <strtol+0x58>
  800bf9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bfd:	75 7c                	jne    800c7b <strtol+0xca>
		s += 2, base = 16;
  800bff:	83 c1 02             	add    $0x2,%ecx
  800c02:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c07:	eb 16                	jmp    800c1f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c09:	85 db                	test   %ebx,%ebx
  800c0b:	75 12                	jne    800c1f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c0d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c12:	80 39 30             	cmpb   $0x30,(%ecx)
  800c15:	75 08                	jne    800c1f <strtol+0x6e>
		s++, base = 8;
  800c17:	83 c1 01             	add    $0x1,%ecx
  800c1a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c24:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c27:	0f b6 11             	movzbl (%ecx),%edx
  800c2a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c2d:	89 f3                	mov    %esi,%ebx
  800c2f:	80 fb 09             	cmp    $0x9,%bl
  800c32:	77 08                	ja     800c3c <strtol+0x8b>
			dig = *s - '0';
  800c34:	0f be d2             	movsbl %dl,%edx
  800c37:	83 ea 30             	sub    $0x30,%edx
  800c3a:	eb 22                	jmp    800c5e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c3c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c3f:	89 f3                	mov    %esi,%ebx
  800c41:	80 fb 19             	cmp    $0x19,%bl
  800c44:	77 08                	ja     800c4e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c46:	0f be d2             	movsbl %dl,%edx
  800c49:	83 ea 57             	sub    $0x57,%edx
  800c4c:	eb 10                	jmp    800c5e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c4e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c51:	89 f3                	mov    %esi,%ebx
  800c53:	80 fb 19             	cmp    $0x19,%bl
  800c56:	77 16                	ja     800c6e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c58:	0f be d2             	movsbl %dl,%edx
  800c5b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c5e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c61:	7d 0b                	jge    800c6e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c63:	83 c1 01             	add    $0x1,%ecx
  800c66:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c6a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c6c:	eb b9                	jmp    800c27 <strtol+0x76>

	if (endptr)
  800c6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c72:	74 0d                	je     800c81 <strtol+0xd0>
		*endptr = (char *) s;
  800c74:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c77:	89 0e                	mov    %ecx,(%esi)
  800c79:	eb 06                	jmp    800c81 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c7b:	85 db                	test   %ebx,%ebx
  800c7d:	74 98                	je     800c17 <strtol+0x66>
  800c7f:	eb 9e                	jmp    800c1f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c81:	89 c2                	mov    %eax,%edx
  800c83:	f7 da                	neg    %edx
  800c85:	85 ff                	test   %edi,%edi
  800c87:	0f 45 c2             	cmovne %edx,%eax
}
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 04             	sub    $0x4,%esp
  800c98:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800c9b:	57                   	push   %edi
  800c9c:	e8 6e fc ff ff       	call   80090f <strlen>
  800ca1:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800ca4:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800ca7:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800cac:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800cb1:	eb 46                	jmp    800cf9 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800cb3:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800cb7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800cba:	80 f9 09             	cmp    $0x9,%cl
  800cbd:	77 08                	ja     800cc7 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800cbf:	0f be d2             	movsbl %dl,%edx
  800cc2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800cc5:	eb 27                	jmp    800cee <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800cc7:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800cca:	80 f9 05             	cmp    $0x5,%cl
  800ccd:	77 08                	ja     800cd7 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800ccf:	0f be d2             	movsbl %dl,%edx
  800cd2:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800cd5:	eb 17                	jmp    800cee <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800cd7:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800cda:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800cdd:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800ce2:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800ce6:	77 06                	ja     800cee <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800ce8:	0f be d2             	movsbl %dl,%edx
  800ceb:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800cee:	0f af ce             	imul   %esi,%ecx
  800cf1:	01 c8                	add    %ecx,%eax
		base *= 16;
  800cf3:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800cf6:	83 eb 01             	sub    $0x1,%ebx
  800cf9:	83 fb 01             	cmp    $0x1,%ebx
  800cfc:	7f b5                	jg     800cb3 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	89 c3                	mov    %eax,%ebx
  800d19:	89 c7                	mov    %eax,%edi
  800d1b:	89 c6                	mov    %eax,%esi
  800d1d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d34:	89 d1                	mov    %edx,%ecx
  800d36:	89 d3                	mov    %edx,%ebx
  800d38:	89 d7                	mov    %edx,%edi
  800d3a:	89 d6                	mov    %edx,%esi
  800d3c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d51:	b8 03 00 00 00       	mov    $0x3,%eax
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 cb                	mov    %ecx,%ebx
  800d5b:	89 cf                	mov    %ecx,%edi
  800d5d:	89 ce                	mov    %ecx,%esi
  800d5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 17                	jle    800d7c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	83 ec 0c             	sub    $0xc,%esp
  800d68:	50                   	push   %eax
  800d69:	6a 03                	push   $0x3
  800d6b:	68 7f 24 80 00       	push   $0x80247f
  800d70:	6a 23                	push   $0x23
  800d72:	68 9c 24 80 00       	push   $0x80249c
  800d77:	e8 bf f4 ff ff       	call   80023b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8f:	b8 02 00 00 00       	mov    $0x2,%eax
  800d94:	89 d1                	mov    %edx,%ecx
  800d96:	89 d3                	mov    %edx,%ebx
  800d98:	89 d7                	mov    %edx,%edi
  800d9a:	89 d6                	mov    %edx,%esi
  800d9c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_yield>:

void
sys_yield(void)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	ba 00 00 00 00       	mov    $0x0,%edx
  800dae:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db3:	89 d1                	mov    %edx,%ecx
  800db5:	89 d3                	mov    %edx,%ebx
  800db7:	89 d7                	mov    %edx,%edi
  800db9:	89 d6                	mov    %edx,%esi
  800dbb:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
  800dc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcb:	be 00 00 00 00       	mov    $0x0,%esi
  800dd0:	b8 04 00 00 00       	mov    $0x4,%eax
  800dd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dde:	89 f7                	mov    %esi,%edi
  800de0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 17                	jle    800dfd <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	83 ec 0c             	sub    $0xc,%esp
  800de9:	50                   	push   %eax
  800dea:	6a 04                	push   $0x4
  800dec:	68 7f 24 80 00       	push   $0x80247f
  800df1:	6a 23                	push   $0x23
  800df3:	68 9c 24 80 00       	push   $0x80249c
  800df8:	e8 3e f4 ff ff       	call   80023b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
  800e0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	b8 05 00 00 00       	mov    $0x5,%eax
  800e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e1f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e24:	85 c0                	test   %eax,%eax
  800e26:	7e 17                	jle    800e3f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e28:	83 ec 0c             	sub    $0xc,%esp
  800e2b:	50                   	push   %eax
  800e2c:	6a 05                	push   $0x5
  800e2e:	68 7f 24 80 00       	push   $0x80247f
  800e33:	6a 23                	push   $0x23
  800e35:	68 9c 24 80 00       	push   $0x80249c
  800e3a:	e8 fc f3 ff ff       	call   80023b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e55:	b8 06 00 00 00       	mov    $0x6,%eax
  800e5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e60:	89 df                	mov    %ebx,%edi
  800e62:	89 de                	mov    %ebx,%esi
  800e64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e66:	85 c0                	test   %eax,%eax
  800e68:	7e 17                	jle    800e81 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6a:	83 ec 0c             	sub    $0xc,%esp
  800e6d:	50                   	push   %eax
  800e6e:	6a 06                	push   $0x6
  800e70:	68 7f 24 80 00       	push   $0x80247f
  800e75:	6a 23                	push   $0x23
  800e77:	68 9c 24 80 00       	push   $0x80249c
  800e7c:	e8 ba f3 ff ff       	call   80023b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
  800e8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e97:	b8 08 00 00 00       	mov    $0x8,%eax
  800e9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea2:	89 df                	mov    %ebx,%edi
  800ea4:	89 de                	mov    %ebx,%esi
  800ea6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea8:	85 c0                	test   %eax,%eax
  800eaa:	7e 17                	jle    800ec3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eac:	83 ec 0c             	sub    $0xc,%esp
  800eaf:	50                   	push   %eax
  800eb0:	6a 08                	push   $0x8
  800eb2:	68 7f 24 80 00       	push   $0x80247f
  800eb7:	6a 23                	push   $0x23
  800eb9:	68 9c 24 80 00       	push   $0x80249c
  800ebe:	e8 78 f3 ff ff       	call   80023b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ec3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	57                   	push   %edi
  800ecf:	56                   	push   %esi
  800ed0:	53                   	push   %ebx
  800ed1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ede:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee4:	89 df                	mov    %ebx,%edi
  800ee6:	89 de                	mov    %ebx,%esi
  800ee8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eea:	85 c0                	test   %eax,%eax
  800eec:	7e 17                	jle    800f05 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eee:	83 ec 0c             	sub    $0xc,%esp
  800ef1:	50                   	push   %eax
  800ef2:	6a 0a                	push   $0xa
  800ef4:	68 7f 24 80 00       	push   $0x80247f
  800ef9:	6a 23                	push   $0x23
  800efb:	68 9c 24 80 00       	push   $0x80249c
  800f00:	e8 36 f3 ff ff       	call   80023b <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	57                   	push   %edi
  800f11:	56                   	push   %esi
  800f12:	53                   	push   %ebx
  800f13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1b:	b8 09 00 00 00       	mov    $0x9,%eax
  800f20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f23:	8b 55 08             	mov    0x8(%ebp),%edx
  800f26:	89 df                	mov    %ebx,%edi
  800f28:	89 de                	mov    %ebx,%esi
  800f2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	7e 17                	jle    800f47 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f30:	83 ec 0c             	sub    $0xc,%esp
  800f33:	50                   	push   %eax
  800f34:	6a 09                	push   $0x9
  800f36:	68 7f 24 80 00       	push   $0x80247f
  800f3b:	6a 23                	push   $0x23
  800f3d:	68 9c 24 80 00       	push   $0x80249c
  800f42:	e8 f4 f2 ff ff       	call   80023b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4a:	5b                   	pop    %ebx
  800f4b:	5e                   	pop    %esi
  800f4c:	5f                   	pop    %edi
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f55:	be 00 00 00 00       	mov    $0x0,%esi
  800f5a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f62:	8b 55 08             	mov    0x8(%ebp),%edx
  800f65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f68:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f6b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f6d:	5b                   	pop    %ebx
  800f6e:	5e                   	pop    %esi
  800f6f:	5f                   	pop    %edi
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    

00800f72 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	57                   	push   %edi
  800f76:	56                   	push   %esi
  800f77:	53                   	push   %ebx
  800f78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f80:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f85:	8b 55 08             	mov    0x8(%ebp),%edx
  800f88:	89 cb                	mov    %ecx,%ebx
  800f8a:	89 cf                	mov    %ecx,%edi
  800f8c:	89 ce                	mov    %ecx,%esi
  800f8e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f90:	85 c0                	test   %eax,%eax
  800f92:	7e 17                	jle    800fab <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	50                   	push   %eax
  800f98:	6a 0d                	push   $0xd
  800f9a:	68 7f 24 80 00       	push   $0x80247f
  800f9f:	6a 23                	push   $0x23
  800fa1:	68 9c 24 80 00       	push   $0x80249c
  800fa6:	e8 90 f2 ff ff       	call   80023b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fae:	5b                   	pop    %ebx
  800faf:	5e                   	pop    %esi
  800fb0:	5f                   	pop    %edi
  800fb1:	5d                   	pop    %ebp
  800fb2:	c3                   	ret    

00800fb3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb9:	05 00 00 00 30       	add    $0x30000000,%eax
  800fbe:	c1 e8 0c             	shr    $0xc,%eax
}
  800fc1:	5d                   	pop    %ebp
  800fc2:	c3                   	ret    

00800fc3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800fc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc9:	05 00 00 00 30       	add    $0x30000000,%eax
  800fce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fd3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    

00800fda <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fe5:	89 c2                	mov    %eax,%edx
  800fe7:	c1 ea 16             	shr    $0x16,%edx
  800fea:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ff1:	f6 c2 01             	test   $0x1,%dl
  800ff4:	74 11                	je     801007 <fd_alloc+0x2d>
  800ff6:	89 c2                	mov    %eax,%edx
  800ff8:	c1 ea 0c             	shr    $0xc,%edx
  800ffb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801002:	f6 c2 01             	test   $0x1,%dl
  801005:	75 09                	jne    801010 <fd_alloc+0x36>
			*fd_store = fd;
  801007:	89 01                	mov    %eax,(%ecx)
			return 0;
  801009:	b8 00 00 00 00       	mov    $0x0,%eax
  80100e:	eb 17                	jmp    801027 <fd_alloc+0x4d>
  801010:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801015:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80101a:	75 c9                	jne    800fe5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80101c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801022:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801027:	5d                   	pop    %ebp
  801028:	c3                   	ret    

00801029 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80102f:	83 f8 1f             	cmp    $0x1f,%eax
  801032:	77 36                	ja     80106a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801034:	c1 e0 0c             	shl    $0xc,%eax
  801037:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80103c:	89 c2                	mov    %eax,%edx
  80103e:	c1 ea 16             	shr    $0x16,%edx
  801041:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801048:	f6 c2 01             	test   $0x1,%dl
  80104b:	74 24                	je     801071 <fd_lookup+0x48>
  80104d:	89 c2                	mov    %eax,%edx
  80104f:	c1 ea 0c             	shr    $0xc,%edx
  801052:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801059:	f6 c2 01             	test   $0x1,%dl
  80105c:	74 1a                	je     801078 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80105e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801061:	89 02                	mov    %eax,(%edx)
	return 0;
  801063:	b8 00 00 00 00       	mov    $0x0,%eax
  801068:	eb 13                	jmp    80107d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80106a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80106f:	eb 0c                	jmp    80107d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801071:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801076:	eb 05                	jmp    80107d <fd_lookup+0x54>
  801078:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80107d:	5d                   	pop    %ebp
  80107e:	c3                   	ret    

0080107f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	83 ec 08             	sub    $0x8,%esp
  801085:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801088:	ba 28 25 80 00       	mov    $0x802528,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80108d:	eb 13                	jmp    8010a2 <dev_lookup+0x23>
  80108f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801092:	39 08                	cmp    %ecx,(%eax)
  801094:	75 0c                	jne    8010a2 <dev_lookup+0x23>
			*dev = devtab[i];
  801096:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801099:	89 01                	mov    %eax,(%ecx)
			return 0;
  80109b:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a0:	eb 2e                	jmp    8010d0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010a2:	8b 02                	mov    (%edx),%eax
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	75 e7                	jne    80108f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010a8:	a1 08 40 80 00       	mov    0x804008,%eax
  8010ad:	8b 40 48             	mov    0x48(%eax),%eax
  8010b0:	83 ec 04             	sub    $0x4,%esp
  8010b3:	51                   	push   %ecx
  8010b4:	50                   	push   %eax
  8010b5:	68 ac 24 80 00       	push   $0x8024ac
  8010ba:	e8 55 f2 ff ff       	call   800314 <cprintf>
	*dev = 0;
  8010bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010d0:	c9                   	leave  
  8010d1:	c3                   	ret    

008010d2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	56                   	push   %esi
  8010d6:	53                   	push   %ebx
  8010d7:	83 ec 10             	sub    $0x10,%esp
  8010da:	8b 75 08             	mov    0x8(%ebp),%esi
  8010dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e3:	50                   	push   %eax
  8010e4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010ea:	c1 e8 0c             	shr    $0xc,%eax
  8010ed:	50                   	push   %eax
  8010ee:	e8 36 ff ff ff       	call   801029 <fd_lookup>
  8010f3:	83 c4 08             	add    $0x8,%esp
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	78 05                	js     8010ff <fd_close+0x2d>
	    || fd != fd2) 
  8010fa:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010fd:	74 0c                	je     80110b <fd_close+0x39>
		return (must_exist ? r : 0); 
  8010ff:	84 db                	test   %bl,%bl
  801101:	ba 00 00 00 00       	mov    $0x0,%edx
  801106:	0f 44 c2             	cmove  %edx,%eax
  801109:	eb 41                	jmp    80114c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80110b:	83 ec 08             	sub    $0x8,%esp
  80110e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801111:	50                   	push   %eax
  801112:	ff 36                	pushl  (%esi)
  801114:	e8 66 ff ff ff       	call   80107f <dev_lookup>
  801119:	89 c3                	mov    %eax,%ebx
  80111b:	83 c4 10             	add    $0x10,%esp
  80111e:	85 c0                	test   %eax,%eax
  801120:	78 1a                	js     80113c <fd_close+0x6a>
		if (dev->dev_close) 
  801122:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801125:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  801128:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  80112d:	85 c0                	test   %eax,%eax
  80112f:	74 0b                	je     80113c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801131:	83 ec 0c             	sub    $0xc,%esp
  801134:	56                   	push   %esi
  801135:	ff d0                	call   *%eax
  801137:	89 c3                	mov    %eax,%ebx
  801139:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80113c:	83 ec 08             	sub    $0x8,%esp
  80113f:	56                   	push   %esi
  801140:	6a 00                	push   $0x0
  801142:	e8 00 fd ff ff       	call   800e47 <sys_page_unmap>
	return r;
  801147:	83 c4 10             	add    $0x10,%esp
  80114a:	89 d8                	mov    %ebx,%eax
}
  80114c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80114f:	5b                   	pop    %ebx
  801150:	5e                   	pop    %esi
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801159:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115c:	50                   	push   %eax
  80115d:	ff 75 08             	pushl  0x8(%ebp)
  801160:	e8 c4 fe ff ff       	call   801029 <fd_lookup>
  801165:	83 c4 08             	add    $0x8,%esp
  801168:	85 c0                	test   %eax,%eax
  80116a:	78 10                	js     80117c <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  80116c:	83 ec 08             	sub    $0x8,%esp
  80116f:	6a 01                	push   $0x1
  801171:	ff 75 f4             	pushl  -0xc(%ebp)
  801174:	e8 59 ff ff ff       	call   8010d2 <fd_close>
  801179:	83 c4 10             	add    $0x10,%esp
}
  80117c:	c9                   	leave  
  80117d:	c3                   	ret    

0080117e <close_all>:

void
close_all(void)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	53                   	push   %ebx
  801182:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801185:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80118a:	83 ec 0c             	sub    $0xc,%esp
  80118d:	53                   	push   %ebx
  80118e:	e8 c0 ff ff ff       	call   801153 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801193:	83 c3 01             	add    $0x1,%ebx
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	83 fb 20             	cmp    $0x20,%ebx
  80119c:	75 ec                	jne    80118a <close_all+0xc>
		close(i);
}
  80119e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a1:	c9                   	leave  
  8011a2:	c3                   	ret    

008011a3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	57                   	push   %edi
  8011a7:	56                   	push   %esi
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 2c             	sub    $0x2c,%esp
  8011ac:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011af:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011b2:	50                   	push   %eax
  8011b3:	ff 75 08             	pushl  0x8(%ebp)
  8011b6:	e8 6e fe ff ff       	call   801029 <fd_lookup>
  8011bb:	83 c4 08             	add    $0x8,%esp
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	0f 88 c1 00 00 00    	js     801287 <dup+0xe4>
		return r;
	close(newfdnum);
  8011c6:	83 ec 0c             	sub    $0xc,%esp
  8011c9:	56                   	push   %esi
  8011ca:	e8 84 ff ff ff       	call   801153 <close>

	newfd = INDEX2FD(newfdnum);
  8011cf:	89 f3                	mov    %esi,%ebx
  8011d1:	c1 e3 0c             	shl    $0xc,%ebx
  8011d4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8011da:	83 c4 04             	add    $0x4,%esp
  8011dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011e0:	e8 de fd ff ff       	call   800fc3 <fd2data>
  8011e5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8011e7:	89 1c 24             	mov    %ebx,(%esp)
  8011ea:	e8 d4 fd ff ff       	call   800fc3 <fd2data>
  8011ef:	83 c4 10             	add    $0x10,%esp
  8011f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011f5:	89 f8                	mov    %edi,%eax
  8011f7:	c1 e8 16             	shr    $0x16,%eax
  8011fa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801201:	a8 01                	test   $0x1,%al
  801203:	74 37                	je     80123c <dup+0x99>
  801205:	89 f8                	mov    %edi,%eax
  801207:	c1 e8 0c             	shr    $0xc,%eax
  80120a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801211:	f6 c2 01             	test   $0x1,%dl
  801214:	74 26                	je     80123c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801216:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80121d:	83 ec 0c             	sub    $0xc,%esp
  801220:	25 07 0e 00 00       	and    $0xe07,%eax
  801225:	50                   	push   %eax
  801226:	ff 75 d4             	pushl  -0x2c(%ebp)
  801229:	6a 00                	push   $0x0
  80122b:	57                   	push   %edi
  80122c:	6a 00                	push   $0x0
  80122e:	e8 d2 fb ff ff       	call   800e05 <sys_page_map>
  801233:	89 c7                	mov    %eax,%edi
  801235:	83 c4 20             	add    $0x20,%esp
  801238:	85 c0                	test   %eax,%eax
  80123a:	78 2e                	js     80126a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80123c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80123f:	89 d0                	mov    %edx,%eax
  801241:	c1 e8 0c             	shr    $0xc,%eax
  801244:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80124b:	83 ec 0c             	sub    $0xc,%esp
  80124e:	25 07 0e 00 00       	and    $0xe07,%eax
  801253:	50                   	push   %eax
  801254:	53                   	push   %ebx
  801255:	6a 00                	push   $0x0
  801257:	52                   	push   %edx
  801258:	6a 00                	push   $0x0
  80125a:	e8 a6 fb ff ff       	call   800e05 <sys_page_map>
  80125f:	89 c7                	mov    %eax,%edi
  801261:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801264:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801266:	85 ff                	test   %edi,%edi
  801268:	79 1d                	jns    801287 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80126a:	83 ec 08             	sub    $0x8,%esp
  80126d:	53                   	push   %ebx
  80126e:	6a 00                	push   $0x0
  801270:	e8 d2 fb ff ff       	call   800e47 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801275:	83 c4 08             	add    $0x8,%esp
  801278:	ff 75 d4             	pushl  -0x2c(%ebp)
  80127b:	6a 00                	push   $0x0
  80127d:	e8 c5 fb ff ff       	call   800e47 <sys_page_unmap>
	return r;
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	89 f8                	mov    %edi,%eax
}
  801287:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128a:	5b                   	pop    %ebx
  80128b:	5e                   	pop    %esi
  80128c:	5f                   	pop    %edi
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	53                   	push   %ebx
  801293:	83 ec 14             	sub    $0x14,%esp
  801296:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801299:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129c:	50                   	push   %eax
  80129d:	53                   	push   %ebx
  80129e:	e8 86 fd ff ff       	call   801029 <fd_lookup>
  8012a3:	83 c4 08             	add    $0x8,%esp
  8012a6:	89 c2                	mov    %eax,%edx
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 6d                	js     801319 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ac:	83 ec 08             	sub    $0x8,%esp
  8012af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b2:	50                   	push   %eax
  8012b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b6:	ff 30                	pushl  (%eax)
  8012b8:	e8 c2 fd ff ff       	call   80107f <dev_lookup>
  8012bd:	83 c4 10             	add    $0x10,%esp
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	78 4c                	js     801310 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012c7:	8b 42 08             	mov    0x8(%edx),%eax
  8012ca:	83 e0 03             	and    $0x3,%eax
  8012cd:	83 f8 01             	cmp    $0x1,%eax
  8012d0:	75 21                	jne    8012f3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012d2:	a1 08 40 80 00       	mov    0x804008,%eax
  8012d7:	8b 40 48             	mov    0x48(%eax),%eax
  8012da:	83 ec 04             	sub    $0x4,%esp
  8012dd:	53                   	push   %ebx
  8012de:	50                   	push   %eax
  8012df:	68 ed 24 80 00       	push   $0x8024ed
  8012e4:	e8 2b f0 ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012f1:	eb 26                	jmp    801319 <read+0x8a>
	}
	if (!dev->dev_read)
  8012f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f6:	8b 40 08             	mov    0x8(%eax),%eax
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	74 17                	je     801314 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012fd:	83 ec 04             	sub    $0x4,%esp
  801300:	ff 75 10             	pushl  0x10(%ebp)
  801303:	ff 75 0c             	pushl  0xc(%ebp)
  801306:	52                   	push   %edx
  801307:	ff d0                	call   *%eax
  801309:	89 c2                	mov    %eax,%edx
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	eb 09                	jmp    801319 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801310:	89 c2                	mov    %eax,%edx
  801312:	eb 05                	jmp    801319 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801314:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801319:	89 d0                	mov    %edx,%eax
  80131b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131e:	c9                   	leave  
  80131f:	c3                   	ret    

00801320 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	57                   	push   %edi
  801324:	56                   	push   %esi
  801325:	53                   	push   %ebx
  801326:	83 ec 0c             	sub    $0xc,%esp
  801329:	8b 7d 08             	mov    0x8(%ebp),%edi
  80132c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80132f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801334:	eb 21                	jmp    801357 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801336:	83 ec 04             	sub    $0x4,%esp
  801339:	89 f0                	mov    %esi,%eax
  80133b:	29 d8                	sub    %ebx,%eax
  80133d:	50                   	push   %eax
  80133e:	89 d8                	mov    %ebx,%eax
  801340:	03 45 0c             	add    0xc(%ebp),%eax
  801343:	50                   	push   %eax
  801344:	57                   	push   %edi
  801345:	e8 45 ff ff ff       	call   80128f <read>
		if (m < 0)
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	85 c0                	test   %eax,%eax
  80134f:	78 10                	js     801361 <readn+0x41>
			return m;
		if (m == 0)
  801351:	85 c0                	test   %eax,%eax
  801353:	74 0a                	je     80135f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801355:	01 c3                	add    %eax,%ebx
  801357:	39 f3                	cmp    %esi,%ebx
  801359:	72 db                	jb     801336 <readn+0x16>
  80135b:	89 d8                	mov    %ebx,%eax
  80135d:	eb 02                	jmp    801361 <readn+0x41>
  80135f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801361:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801364:	5b                   	pop    %ebx
  801365:	5e                   	pop    %esi
  801366:	5f                   	pop    %edi
  801367:	5d                   	pop    %ebp
  801368:	c3                   	ret    

00801369 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	53                   	push   %ebx
  80136d:	83 ec 14             	sub    $0x14,%esp
  801370:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801373:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801376:	50                   	push   %eax
  801377:	53                   	push   %ebx
  801378:	e8 ac fc ff ff       	call   801029 <fd_lookup>
  80137d:	83 c4 08             	add    $0x8,%esp
  801380:	89 c2                	mov    %eax,%edx
  801382:	85 c0                	test   %eax,%eax
  801384:	78 68                	js     8013ee <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801386:	83 ec 08             	sub    $0x8,%esp
  801389:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138c:	50                   	push   %eax
  80138d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801390:	ff 30                	pushl  (%eax)
  801392:	e8 e8 fc ff ff       	call   80107f <dev_lookup>
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	78 47                	js     8013e5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80139e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013a5:	75 21                	jne    8013c8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013a7:	a1 08 40 80 00       	mov    0x804008,%eax
  8013ac:	8b 40 48             	mov    0x48(%eax),%eax
  8013af:	83 ec 04             	sub    $0x4,%esp
  8013b2:	53                   	push   %ebx
  8013b3:	50                   	push   %eax
  8013b4:	68 09 25 80 00       	push   $0x802509
  8013b9:	e8 56 ef ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013c6:	eb 26                	jmp    8013ee <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013cb:	8b 52 0c             	mov    0xc(%edx),%edx
  8013ce:	85 d2                	test   %edx,%edx
  8013d0:	74 17                	je     8013e9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013d2:	83 ec 04             	sub    $0x4,%esp
  8013d5:	ff 75 10             	pushl  0x10(%ebp)
  8013d8:	ff 75 0c             	pushl  0xc(%ebp)
  8013db:	50                   	push   %eax
  8013dc:	ff d2                	call   *%edx
  8013de:	89 c2                	mov    %eax,%edx
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	eb 09                	jmp    8013ee <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e5:	89 c2                	mov    %eax,%edx
  8013e7:	eb 05                	jmp    8013ee <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013e9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8013ee:	89 d0                	mov    %edx,%eax
  8013f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f3:	c9                   	leave  
  8013f4:	c3                   	ret    

008013f5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
  8013f8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013fb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013fe:	50                   	push   %eax
  8013ff:	ff 75 08             	pushl  0x8(%ebp)
  801402:	e8 22 fc ff ff       	call   801029 <fd_lookup>
  801407:	83 c4 08             	add    $0x8,%esp
  80140a:	85 c0                	test   %eax,%eax
  80140c:	78 0e                	js     80141c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80140e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801411:	8b 55 0c             	mov    0xc(%ebp),%edx
  801414:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801417:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80141c:	c9                   	leave  
  80141d:	c3                   	ret    

0080141e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	53                   	push   %ebx
  801422:	83 ec 14             	sub    $0x14,%esp
  801425:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801428:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142b:	50                   	push   %eax
  80142c:	53                   	push   %ebx
  80142d:	e8 f7 fb ff ff       	call   801029 <fd_lookup>
  801432:	83 c4 08             	add    $0x8,%esp
  801435:	89 c2                	mov    %eax,%edx
  801437:	85 c0                	test   %eax,%eax
  801439:	78 65                	js     8014a0 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143b:	83 ec 08             	sub    $0x8,%esp
  80143e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801441:	50                   	push   %eax
  801442:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801445:	ff 30                	pushl  (%eax)
  801447:	e8 33 fc ff ff       	call   80107f <dev_lookup>
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	85 c0                	test   %eax,%eax
  801451:	78 44                	js     801497 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801453:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801456:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80145a:	75 21                	jne    80147d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80145c:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801461:	8b 40 48             	mov    0x48(%eax),%eax
  801464:	83 ec 04             	sub    $0x4,%esp
  801467:	53                   	push   %ebx
  801468:	50                   	push   %eax
  801469:	68 cc 24 80 00       	push   $0x8024cc
  80146e:	e8 a1 ee ff ff       	call   800314 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80147b:	eb 23                	jmp    8014a0 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80147d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801480:	8b 52 18             	mov    0x18(%edx),%edx
  801483:	85 d2                	test   %edx,%edx
  801485:	74 14                	je     80149b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	ff 75 0c             	pushl  0xc(%ebp)
  80148d:	50                   	push   %eax
  80148e:	ff d2                	call   *%edx
  801490:	89 c2                	mov    %eax,%edx
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	eb 09                	jmp    8014a0 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801497:	89 c2                	mov    %eax,%edx
  801499:	eb 05                	jmp    8014a0 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80149b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8014a0:	89 d0                	mov    %edx,%eax
  8014a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a5:	c9                   	leave  
  8014a6:	c3                   	ret    

008014a7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	53                   	push   %ebx
  8014ab:	83 ec 14             	sub    $0x14,%esp
  8014ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b4:	50                   	push   %eax
  8014b5:	ff 75 08             	pushl  0x8(%ebp)
  8014b8:	e8 6c fb ff ff       	call   801029 <fd_lookup>
  8014bd:	83 c4 08             	add    $0x8,%esp
  8014c0:	89 c2                	mov    %eax,%edx
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	78 58                	js     80151e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c6:	83 ec 08             	sub    $0x8,%esp
  8014c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014cc:	50                   	push   %eax
  8014cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d0:	ff 30                	pushl  (%eax)
  8014d2:	e8 a8 fb ff ff       	call   80107f <dev_lookup>
  8014d7:	83 c4 10             	add    $0x10,%esp
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 37                	js     801515 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8014de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014e5:	74 32                	je     801519 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014e7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014ea:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014f1:	00 00 00 
	stat->st_isdir = 0;
  8014f4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014fb:	00 00 00 
	stat->st_dev = dev;
  8014fe:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801504:	83 ec 08             	sub    $0x8,%esp
  801507:	53                   	push   %ebx
  801508:	ff 75 f0             	pushl  -0x10(%ebp)
  80150b:	ff 50 14             	call   *0x14(%eax)
  80150e:	89 c2                	mov    %eax,%edx
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	eb 09                	jmp    80151e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801515:	89 c2                	mov    %eax,%edx
  801517:	eb 05                	jmp    80151e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801519:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80151e:	89 d0                	mov    %edx,%eax
  801520:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801523:	c9                   	leave  
  801524:	c3                   	ret    

00801525 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801525:	55                   	push   %ebp
  801526:	89 e5                	mov    %esp,%ebp
  801528:	56                   	push   %esi
  801529:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80152a:	83 ec 08             	sub    $0x8,%esp
  80152d:	6a 00                	push   $0x0
  80152f:	ff 75 08             	pushl  0x8(%ebp)
  801532:	e8 2b 02 00 00       	call   801762 <open>
  801537:	89 c3                	mov    %eax,%ebx
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 1b                	js     80155b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	ff 75 0c             	pushl  0xc(%ebp)
  801546:	50                   	push   %eax
  801547:	e8 5b ff ff ff       	call   8014a7 <fstat>
  80154c:	89 c6                	mov    %eax,%esi
	close(fd);
  80154e:	89 1c 24             	mov    %ebx,(%esp)
  801551:	e8 fd fb ff ff       	call   801153 <close>
	return r;
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	89 f0                	mov    %esi,%eax
}
  80155b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80155e:	5b                   	pop    %ebx
  80155f:	5e                   	pop    %esi
  801560:	5d                   	pop    %ebp
  801561:	c3                   	ret    

00801562 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801562:	55                   	push   %ebp
  801563:	89 e5                	mov    %esp,%ebp
  801565:	56                   	push   %esi
  801566:	53                   	push   %ebx
  801567:	89 c6                	mov    %eax,%esi
  801569:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80156b:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801572:	75 12                	jne    801586 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801574:	83 ec 0c             	sub    $0xc,%esp
  801577:	6a 01                	push   $0x1
  801579:	e8 26 08 00 00       	call   801da4 <ipc_find_env>
  80157e:	a3 04 40 80 00       	mov    %eax,0x804004
  801583:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801586:	6a 07                	push   $0x7
  801588:	68 00 50 80 00       	push   $0x805000
  80158d:	56                   	push   %esi
  80158e:	ff 35 04 40 80 00    	pushl  0x804004
  801594:	e8 b5 07 00 00       	call   801d4e <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801599:	83 c4 0c             	add    $0xc,%esp
  80159c:	6a 00                	push   $0x0
  80159e:	53                   	push   %ebx
  80159f:	6a 00                	push   $0x0
  8015a1:	e8 3f 07 00 00       	call   801ce5 <ipc_recv>
}
  8015a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a9:	5b                   	pop    %ebx
  8015aa:	5e                   	pop    %esi
  8015ab:	5d                   	pop    %ebp
  8015ac:	c3                   	ret    

008015ad <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b6:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015cb:	b8 02 00 00 00       	mov    $0x2,%eax
  8015d0:	e8 8d ff ff ff       	call   801562 <fsipc>
}
  8015d5:	c9                   	leave  
  8015d6:	c3                   	ret    

008015d7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8015e3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8015f2:	e8 6b ff ff ff       	call   801562 <fsipc>
}
  8015f7:	c9                   	leave  
  8015f8:	c3                   	ret    

008015f9 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015f9:	55                   	push   %ebp
  8015fa:	89 e5                	mov    %esp,%ebp
  8015fc:	53                   	push   %ebx
  8015fd:	83 ec 04             	sub    $0x4,%esp
  801600:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801603:	8b 45 08             	mov    0x8(%ebp),%eax
  801606:	8b 40 0c             	mov    0xc(%eax),%eax
  801609:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80160e:	ba 00 00 00 00       	mov    $0x0,%edx
  801613:	b8 05 00 00 00       	mov    $0x5,%eax
  801618:	e8 45 ff ff ff       	call   801562 <fsipc>
  80161d:	85 c0                	test   %eax,%eax
  80161f:	78 2c                	js     80164d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	68 00 50 80 00       	push   $0x805000
  801629:	53                   	push   %ebx
  80162a:	e8 19 f3 ff ff       	call   800948 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80162f:	a1 80 50 80 00       	mov    0x805080,%eax
  801634:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80163a:	a1 84 50 80 00       	mov    0x805084,%eax
  80163f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80164d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801650:	c9                   	leave  
  801651:	c3                   	ret    

00801652 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	53                   	push   %ebx
  801656:	83 ec 08             	sub    $0x8,%esp
  801659:	8b 45 10             	mov    0x10(%ebp),%eax
  80165c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801661:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801666:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801669:	8b 45 08             	mov    0x8(%ebp),%eax
  80166c:	8b 40 0c             	mov    0xc(%eax),%eax
  80166f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801674:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80167a:	53                   	push   %ebx
  80167b:	ff 75 0c             	pushl  0xc(%ebp)
  80167e:	68 08 50 80 00       	push   $0x805008
  801683:	e8 52 f4 ff ff       	call   800ada <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801688:	ba 00 00 00 00       	mov    $0x0,%edx
  80168d:	b8 04 00 00 00       	mov    $0x4,%eax
  801692:	e8 cb fe ff ff       	call   801562 <fsipc>
  801697:	83 c4 10             	add    $0x10,%esp
  80169a:	85 c0                	test   %eax,%eax
  80169c:	78 3d                	js     8016db <devfile_write+0x89>
		return r;

	assert(r <= n);
  80169e:	39 d8                	cmp    %ebx,%eax
  8016a0:	76 19                	jbe    8016bb <devfile_write+0x69>
  8016a2:	68 38 25 80 00       	push   $0x802538
  8016a7:	68 3f 25 80 00       	push   $0x80253f
  8016ac:	68 9f 00 00 00       	push   $0x9f
  8016b1:	68 54 25 80 00       	push   $0x802554
  8016b6:	e8 80 eb ff ff       	call   80023b <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  8016bb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016c0:	76 19                	jbe    8016db <devfile_write+0x89>
  8016c2:	68 6c 25 80 00       	push   $0x80256c
  8016c7:	68 3f 25 80 00       	push   $0x80253f
  8016cc:	68 a0 00 00 00       	push   $0xa0
  8016d1:	68 54 25 80 00       	push   $0x802554
  8016d6:	e8 60 eb ff ff       	call   80023b <_panic>

	return r;
}
  8016db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016de:	c9                   	leave  
  8016df:	c3                   	ret    

008016e0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	56                   	push   %esi
  8016e4:	53                   	push   %ebx
  8016e5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ee:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016f3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fe:	b8 03 00 00 00       	mov    $0x3,%eax
  801703:	e8 5a fe ff ff       	call   801562 <fsipc>
  801708:	89 c3                	mov    %eax,%ebx
  80170a:	85 c0                	test   %eax,%eax
  80170c:	78 4b                	js     801759 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80170e:	39 c6                	cmp    %eax,%esi
  801710:	73 16                	jae    801728 <devfile_read+0x48>
  801712:	68 38 25 80 00       	push   $0x802538
  801717:	68 3f 25 80 00       	push   $0x80253f
  80171c:	6a 7e                	push   $0x7e
  80171e:	68 54 25 80 00       	push   $0x802554
  801723:	e8 13 eb ff ff       	call   80023b <_panic>
	assert(r <= PGSIZE);
  801728:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80172d:	7e 16                	jle    801745 <devfile_read+0x65>
  80172f:	68 5f 25 80 00       	push   $0x80255f
  801734:	68 3f 25 80 00       	push   $0x80253f
  801739:	6a 7f                	push   $0x7f
  80173b:	68 54 25 80 00       	push   $0x802554
  801740:	e8 f6 ea ff ff       	call   80023b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801745:	83 ec 04             	sub    $0x4,%esp
  801748:	50                   	push   %eax
  801749:	68 00 50 80 00       	push   $0x805000
  80174e:	ff 75 0c             	pushl  0xc(%ebp)
  801751:	e8 84 f3 ff ff       	call   800ada <memmove>
	return r;
  801756:	83 c4 10             	add    $0x10,%esp
}
  801759:	89 d8                	mov    %ebx,%eax
  80175b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80175e:	5b                   	pop    %ebx
  80175f:	5e                   	pop    %esi
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	53                   	push   %ebx
  801766:	83 ec 20             	sub    $0x20,%esp
  801769:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80176c:	53                   	push   %ebx
  80176d:	e8 9d f1 ff ff       	call   80090f <strlen>
  801772:	83 c4 10             	add    $0x10,%esp
  801775:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80177a:	7f 67                	jg     8017e3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80177c:	83 ec 0c             	sub    $0xc,%esp
  80177f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801782:	50                   	push   %eax
  801783:	e8 52 f8 ff ff       	call   800fda <fd_alloc>
  801788:	83 c4 10             	add    $0x10,%esp
		return r;
  80178b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80178d:	85 c0                	test   %eax,%eax
  80178f:	78 57                	js     8017e8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801791:	83 ec 08             	sub    $0x8,%esp
  801794:	53                   	push   %ebx
  801795:	68 00 50 80 00       	push   $0x805000
  80179a:	e8 a9 f1 ff ff       	call   800948 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80179f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8017af:	e8 ae fd ff ff       	call   801562 <fsipc>
  8017b4:	89 c3                	mov    %eax,%ebx
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	79 14                	jns    8017d1 <open+0x6f>
		fd_close(fd, 0);
  8017bd:	83 ec 08             	sub    $0x8,%esp
  8017c0:	6a 00                	push   $0x0
  8017c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c5:	e8 08 f9 ff ff       	call   8010d2 <fd_close>
		return r;
  8017ca:	83 c4 10             	add    $0x10,%esp
  8017cd:	89 da                	mov    %ebx,%edx
  8017cf:	eb 17                	jmp    8017e8 <open+0x86>
	}

	return fd2num(fd);
  8017d1:	83 ec 0c             	sub    $0xc,%esp
  8017d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8017d7:	e8 d7 f7 ff ff       	call   800fb3 <fd2num>
  8017dc:	89 c2                	mov    %eax,%edx
  8017de:	83 c4 10             	add    $0x10,%esp
  8017e1:	eb 05                	jmp    8017e8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017e3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017e8:	89 d0                	mov    %edx,%eax
  8017ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ed:	c9                   	leave  
  8017ee:	c3                   	ret    

008017ef <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fa:	b8 08 00 00 00       	mov    $0x8,%eax
  8017ff:	e8 5e fd ff ff       	call   801562 <fsipc>
}
  801804:	c9                   	leave  
  801805:	c3                   	ret    

00801806 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	56                   	push   %esi
  80180a:	53                   	push   %ebx
  80180b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80180e:	83 ec 0c             	sub    $0xc,%esp
  801811:	ff 75 08             	pushl  0x8(%ebp)
  801814:	e8 aa f7 ff ff       	call   800fc3 <fd2data>
  801819:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80181b:	83 c4 08             	add    $0x8,%esp
  80181e:	68 99 25 80 00       	push   $0x802599
  801823:	53                   	push   %ebx
  801824:	e8 1f f1 ff ff       	call   800948 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801829:	8b 46 04             	mov    0x4(%esi),%eax
  80182c:	2b 06                	sub    (%esi),%eax
  80182e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801834:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80183b:	00 00 00 
	stat->st_dev = &devpipe;
  80183e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801845:	30 80 00 
	return 0;
}
  801848:	b8 00 00 00 00       	mov    $0x0,%eax
  80184d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801850:	5b                   	pop    %ebx
  801851:	5e                   	pop    %esi
  801852:	5d                   	pop    %ebp
  801853:	c3                   	ret    

00801854 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	53                   	push   %ebx
  801858:	83 ec 0c             	sub    $0xc,%esp
  80185b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80185e:	53                   	push   %ebx
  80185f:	6a 00                	push   $0x0
  801861:	e8 e1 f5 ff ff       	call   800e47 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801866:	89 1c 24             	mov    %ebx,(%esp)
  801869:	e8 55 f7 ff ff       	call   800fc3 <fd2data>
  80186e:	83 c4 08             	add    $0x8,%esp
  801871:	50                   	push   %eax
  801872:	6a 00                	push   $0x0
  801874:	e8 ce f5 ff ff       	call   800e47 <sys_page_unmap>
}
  801879:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187c:	c9                   	leave  
  80187d:	c3                   	ret    

0080187e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	57                   	push   %edi
  801882:	56                   	push   %esi
  801883:	53                   	push   %ebx
  801884:	83 ec 1c             	sub    $0x1c,%esp
  801887:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80188a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80188c:	a1 08 40 80 00       	mov    0x804008,%eax
  801891:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801894:	83 ec 0c             	sub    $0xc,%esp
  801897:	ff 75 e0             	pushl  -0x20(%ebp)
  80189a:	e8 3e 05 00 00       	call   801ddd <pageref>
  80189f:	89 c3                	mov    %eax,%ebx
  8018a1:	89 3c 24             	mov    %edi,(%esp)
  8018a4:	e8 34 05 00 00       	call   801ddd <pageref>
  8018a9:	83 c4 10             	add    $0x10,%esp
  8018ac:	39 c3                	cmp    %eax,%ebx
  8018ae:	0f 94 c1             	sete   %cl
  8018b1:	0f b6 c9             	movzbl %cl,%ecx
  8018b4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018b7:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8018bd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018c0:	39 ce                	cmp    %ecx,%esi
  8018c2:	74 1b                	je     8018df <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8018c4:	39 c3                	cmp    %eax,%ebx
  8018c6:	75 c4                	jne    80188c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018c8:	8b 42 58             	mov    0x58(%edx),%eax
  8018cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018ce:	50                   	push   %eax
  8018cf:	56                   	push   %esi
  8018d0:	68 a0 25 80 00       	push   $0x8025a0
  8018d5:	e8 3a ea ff ff       	call   800314 <cprintf>
  8018da:	83 c4 10             	add    $0x10,%esp
  8018dd:	eb ad                	jmp    80188c <_pipeisclosed+0xe>
	}
}
  8018df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e5:	5b                   	pop    %ebx
  8018e6:	5e                   	pop    %esi
  8018e7:	5f                   	pop    %edi
  8018e8:	5d                   	pop    %ebp
  8018e9:	c3                   	ret    

008018ea <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	57                   	push   %edi
  8018ee:	56                   	push   %esi
  8018ef:	53                   	push   %ebx
  8018f0:	83 ec 28             	sub    $0x28,%esp
  8018f3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018f6:	56                   	push   %esi
  8018f7:	e8 c7 f6 ff ff       	call   800fc3 <fd2data>
  8018fc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	bf 00 00 00 00       	mov    $0x0,%edi
  801906:	eb 4b                	jmp    801953 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801908:	89 da                	mov    %ebx,%edx
  80190a:	89 f0                	mov    %esi,%eax
  80190c:	e8 6d ff ff ff       	call   80187e <_pipeisclosed>
  801911:	85 c0                	test   %eax,%eax
  801913:	75 48                	jne    80195d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801915:	e8 89 f4 ff ff       	call   800da3 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80191a:	8b 43 04             	mov    0x4(%ebx),%eax
  80191d:	8b 0b                	mov    (%ebx),%ecx
  80191f:	8d 51 20             	lea    0x20(%ecx),%edx
  801922:	39 d0                	cmp    %edx,%eax
  801924:	73 e2                	jae    801908 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801926:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801929:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80192d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801930:	89 c2                	mov    %eax,%edx
  801932:	c1 fa 1f             	sar    $0x1f,%edx
  801935:	89 d1                	mov    %edx,%ecx
  801937:	c1 e9 1b             	shr    $0x1b,%ecx
  80193a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80193d:	83 e2 1f             	and    $0x1f,%edx
  801940:	29 ca                	sub    %ecx,%edx
  801942:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801946:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80194a:	83 c0 01             	add    $0x1,%eax
  80194d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801950:	83 c7 01             	add    $0x1,%edi
  801953:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801956:	75 c2                	jne    80191a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801958:	8b 45 10             	mov    0x10(%ebp),%eax
  80195b:	eb 05                	jmp    801962 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80195d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801962:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801965:	5b                   	pop    %ebx
  801966:	5e                   	pop    %esi
  801967:	5f                   	pop    %edi
  801968:	5d                   	pop    %ebp
  801969:	c3                   	ret    

0080196a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	57                   	push   %edi
  80196e:	56                   	push   %esi
  80196f:	53                   	push   %ebx
  801970:	83 ec 18             	sub    $0x18,%esp
  801973:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801976:	57                   	push   %edi
  801977:	e8 47 f6 ff ff       	call   800fc3 <fd2data>
  80197c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	bb 00 00 00 00       	mov    $0x0,%ebx
  801986:	eb 3d                	jmp    8019c5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801988:	85 db                	test   %ebx,%ebx
  80198a:	74 04                	je     801990 <devpipe_read+0x26>
				return i;
  80198c:	89 d8                	mov    %ebx,%eax
  80198e:	eb 44                	jmp    8019d4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801990:	89 f2                	mov    %esi,%edx
  801992:	89 f8                	mov    %edi,%eax
  801994:	e8 e5 fe ff ff       	call   80187e <_pipeisclosed>
  801999:	85 c0                	test   %eax,%eax
  80199b:	75 32                	jne    8019cf <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80199d:	e8 01 f4 ff ff       	call   800da3 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019a2:	8b 06                	mov    (%esi),%eax
  8019a4:	3b 46 04             	cmp    0x4(%esi),%eax
  8019a7:	74 df                	je     801988 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019a9:	99                   	cltd   
  8019aa:	c1 ea 1b             	shr    $0x1b,%edx
  8019ad:	01 d0                	add    %edx,%eax
  8019af:	83 e0 1f             	and    $0x1f,%eax
  8019b2:	29 d0                	sub    %edx,%eax
  8019b4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019bc:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019bf:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019c2:	83 c3 01             	add    $0x1,%ebx
  8019c5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019c8:	75 d8                	jne    8019a2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8019cd:	eb 05                	jmp    8019d4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019cf:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019d7:	5b                   	pop    %ebx
  8019d8:	5e                   	pop    %esi
  8019d9:	5f                   	pop    %edi
  8019da:	5d                   	pop    %ebp
  8019db:	c3                   	ret    

008019dc <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	56                   	push   %esi
  8019e0:	53                   	push   %ebx
  8019e1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e7:	50                   	push   %eax
  8019e8:	e8 ed f5 ff ff       	call   800fda <fd_alloc>
  8019ed:	83 c4 10             	add    $0x10,%esp
  8019f0:	89 c2                	mov    %eax,%edx
  8019f2:	85 c0                	test   %eax,%eax
  8019f4:	0f 88 2c 01 00 00    	js     801b26 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019fa:	83 ec 04             	sub    $0x4,%esp
  8019fd:	68 07 04 00 00       	push   $0x407
  801a02:	ff 75 f4             	pushl  -0xc(%ebp)
  801a05:	6a 00                	push   $0x0
  801a07:	e8 b6 f3 ff ff       	call   800dc2 <sys_page_alloc>
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	89 c2                	mov    %eax,%edx
  801a11:	85 c0                	test   %eax,%eax
  801a13:	0f 88 0d 01 00 00    	js     801b26 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a19:	83 ec 0c             	sub    $0xc,%esp
  801a1c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a1f:	50                   	push   %eax
  801a20:	e8 b5 f5 ff ff       	call   800fda <fd_alloc>
  801a25:	89 c3                	mov    %eax,%ebx
  801a27:	83 c4 10             	add    $0x10,%esp
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	0f 88 e2 00 00 00    	js     801b14 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a32:	83 ec 04             	sub    $0x4,%esp
  801a35:	68 07 04 00 00       	push   $0x407
  801a3a:	ff 75 f0             	pushl  -0x10(%ebp)
  801a3d:	6a 00                	push   $0x0
  801a3f:	e8 7e f3 ff ff       	call   800dc2 <sys_page_alloc>
  801a44:	89 c3                	mov    %eax,%ebx
  801a46:	83 c4 10             	add    $0x10,%esp
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	0f 88 c3 00 00 00    	js     801b14 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a51:	83 ec 0c             	sub    $0xc,%esp
  801a54:	ff 75 f4             	pushl  -0xc(%ebp)
  801a57:	e8 67 f5 ff ff       	call   800fc3 <fd2data>
  801a5c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a5e:	83 c4 0c             	add    $0xc,%esp
  801a61:	68 07 04 00 00       	push   $0x407
  801a66:	50                   	push   %eax
  801a67:	6a 00                	push   $0x0
  801a69:	e8 54 f3 ff ff       	call   800dc2 <sys_page_alloc>
  801a6e:	89 c3                	mov    %eax,%ebx
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	85 c0                	test   %eax,%eax
  801a75:	0f 88 89 00 00 00    	js     801b04 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a7b:	83 ec 0c             	sub    $0xc,%esp
  801a7e:	ff 75 f0             	pushl  -0x10(%ebp)
  801a81:	e8 3d f5 ff ff       	call   800fc3 <fd2data>
  801a86:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a8d:	50                   	push   %eax
  801a8e:	6a 00                	push   $0x0
  801a90:	56                   	push   %esi
  801a91:	6a 00                	push   $0x0
  801a93:	e8 6d f3 ff ff       	call   800e05 <sys_page_map>
  801a98:	89 c3                	mov    %eax,%ebx
  801a9a:	83 c4 20             	add    $0x20,%esp
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	78 55                	js     801af6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801aa1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aaa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aaf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ab6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801abc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801abf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ac1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801acb:	83 ec 0c             	sub    $0xc,%esp
  801ace:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad1:	e8 dd f4 ff ff       	call   800fb3 <fd2num>
  801ad6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ad9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801adb:	83 c4 04             	add    $0x4,%esp
  801ade:	ff 75 f0             	pushl  -0x10(%ebp)
  801ae1:	e8 cd f4 ff ff       	call   800fb3 <fd2num>
  801ae6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ae9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	ba 00 00 00 00       	mov    $0x0,%edx
  801af4:	eb 30                	jmp    801b26 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801af6:	83 ec 08             	sub    $0x8,%esp
  801af9:	56                   	push   %esi
  801afa:	6a 00                	push   $0x0
  801afc:	e8 46 f3 ff ff       	call   800e47 <sys_page_unmap>
  801b01:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b04:	83 ec 08             	sub    $0x8,%esp
  801b07:	ff 75 f0             	pushl  -0x10(%ebp)
  801b0a:	6a 00                	push   $0x0
  801b0c:	e8 36 f3 ff ff       	call   800e47 <sys_page_unmap>
  801b11:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b14:	83 ec 08             	sub    $0x8,%esp
  801b17:	ff 75 f4             	pushl  -0xc(%ebp)
  801b1a:	6a 00                	push   $0x0
  801b1c:	e8 26 f3 ff ff       	call   800e47 <sys_page_unmap>
  801b21:	83 c4 10             	add    $0x10,%esp
  801b24:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b26:	89 d0                	mov    %edx,%eax
  801b28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2b:	5b                   	pop    %ebx
  801b2c:	5e                   	pop    %esi
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b38:	50                   	push   %eax
  801b39:	ff 75 08             	pushl  0x8(%ebp)
  801b3c:	e8 e8 f4 ff ff       	call   801029 <fd_lookup>
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	85 c0                	test   %eax,%eax
  801b46:	78 18                	js     801b60 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b48:	83 ec 0c             	sub    $0xc,%esp
  801b4b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4e:	e8 70 f4 ff ff       	call   800fc3 <fd2data>
	return _pipeisclosed(fd, p);
  801b53:	89 c2                	mov    %eax,%edx
  801b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b58:	e8 21 fd ff ff       	call   80187e <_pipeisclosed>
  801b5d:	83 c4 10             	add    $0x10,%esp
}
  801b60:	c9                   	leave  
  801b61:	c3                   	ret    

00801b62 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b65:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6a:	5d                   	pop    %ebp
  801b6b:	c3                   	ret    

00801b6c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b72:	68 b8 25 80 00       	push   $0x8025b8
  801b77:	ff 75 0c             	pushl  0xc(%ebp)
  801b7a:	e8 c9 ed ff ff       	call   800948 <strcpy>
	return 0;
}
  801b7f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	57                   	push   %edi
  801b8a:	56                   	push   %esi
  801b8b:	53                   	push   %ebx
  801b8c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b92:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b97:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b9d:	eb 2d                	jmp    801bcc <devcons_write+0x46>
		m = n - tot;
  801b9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ba2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ba4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ba7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bac:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801baf:	83 ec 04             	sub    $0x4,%esp
  801bb2:	53                   	push   %ebx
  801bb3:	03 45 0c             	add    0xc(%ebp),%eax
  801bb6:	50                   	push   %eax
  801bb7:	57                   	push   %edi
  801bb8:	e8 1d ef ff ff       	call   800ada <memmove>
		sys_cputs(buf, m);
  801bbd:	83 c4 08             	add    $0x8,%esp
  801bc0:	53                   	push   %ebx
  801bc1:	57                   	push   %edi
  801bc2:	e8 3f f1 ff ff       	call   800d06 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc7:	01 de                	add    %ebx,%esi
  801bc9:	83 c4 10             	add    $0x10,%esp
  801bcc:	89 f0                	mov    %esi,%eax
  801bce:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bd1:	72 cc                	jb     801b9f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd6:	5b                   	pop    %ebx
  801bd7:	5e                   	pop    %esi
  801bd8:	5f                   	pop    %edi
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    

00801bdb <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	83 ec 08             	sub    $0x8,%esp
  801be1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801be6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bea:	74 2a                	je     801c16 <devcons_read+0x3b>
  801bec:	eb 05                	jmp    801bf3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801bee:	e8 b0 f1 ff ff       	call   800da3 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801bf3:	e8 2c f1 ff ff       	call   800d24 <sys_cgetc>
  801bf8:	85 c0                	test   %eax,%eax
  801bfa:	74 f2                	je     801bee <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	78 16                	js     801c16 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c00:	83 f8 04             	cmp    $0x4,%eax
  801c03:	74 0c                	je     801c11 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c05:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c08:	88 02                	mov    %al,(%edx)
	return 1;
  801c0a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0f:	eb 05                	jmp    801c16 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c11:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c16:	c9                   	leave  
  801c17:	c3                   	ret    

00801c18 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c21:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c24:	6a 01                	push   $0x1
  801c26:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c29:	50                   	push   %eax
  801c2a:	e8 d7 f0 ff ff       	call   800d06 <sys_cputs>
}
  801c2f:	83 c4 10             	add    $0x10,%esp
  801c32:	c9                   	leave  
  801c33:	c3                   	ret    

00801c34 <getchar>:

int
getchar(void)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c3a:	6a 01                	push   $0x1
  801c3c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c3f:	50                   	push   %eax
  801c40:	6a 00                	push   $0x0
  801c42:	e8 48 f6 ff ff       	call   80128f <read>
	if (r < 0)
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	78 0f                	js     801c5d <getchar+0x29>
		return r;
	if (r < 1)
  801c4e:	85 c0                	test   %eax,%eax
  801c50:	7e 06                	jle    801c58 <getchar+0x24>
		return -E_EOF;
	return c;
  801c52:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c56:	eb 05                	jmp    801c5d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c58:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c5d:	c9                   	leave  
  801c5e:	c3                   	ret    

00801c5f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c68:	50                   	push   %eax
  801c69:	ff 75 08             	pushl  0x8(%ebp)
  801c6c:	e8 b8 f3 ff ff       	call   801029 <fd_lookup>
  801c71:	83 c4 10             	add    $0x10,%esp
  801c74:	85 c0                	test   %eax,%eax
  801c76:	78 11                	js     801c89 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c81:	39 10                	cmp    %edx,(%eax)
  801c83:	0f 94 c0             	sete   %al
  801c86:	0f b6 c0             	movzbl %al,%eax
}
  801c89:	c9                   	leave  
  801c8a:	c3                   	ret    

00801c8b <opencons>:

int
opencons(void)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c94:	50                   	push   %eax
  801c95:	e8 40 f3 ff ff       	call   800fda <fd_alloc>
  801c9a:	83 c4 10             	add    $0x10,%esp
		return r;
  801c9d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	78 3e                	js     801ce1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ca3:	83 ec 04             	sub    $0x4,%esp
  801ca6:	68 07 04 00 00       	push   $0x407
  801cab:	ff 75 f4             	pushl  -0xc(%ebp)
  801cae:	6a 00                	push   $0x0
  801cb0:	e8 0d f1 ff ff       	call   800dc2 <sys_page_alloc>
  801cb5:	83 c4 10             	add    $0x10,%esp
		return r;
  801cb8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cba:	85 c0                	test   %eax,%eax
  801cbc:	78 23                	js     801ce1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801cbe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cd3:	83 ec 0c             	sub    $0xc,%esp
  801cd6:	50                   	push   %eax
  801cd7:	e8 d7 f2 ff ff       	call   800fb3 <fd2num>
  801cdc:	89 c2                	mov    %eax,%edx
  801cde:	83 c4 10             	add    $0x10,%esp
}
  801ce1:	89 d0                	mov    %edx,%eax
  801ce3:	c9                   	leave  
  801ce4:	c3                   	ret    

00801ce5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	56                   	push   %esi
  801ce9:	53                   	push   %ebx
  801cea:	8b 75 08             	mov    0x8(%ebp),%esi
  801ced:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801cf3:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801cf5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801cfa:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801cfd:	83 ec 0c             	sub    $0xc,%esp
  801d00:	50                   	push   %eax
  801d01:	e8 6c f2 ff ff       	call   800f72 <sys_ipc_recv>
  801d06:	83 c4 10             	add    $0x10,%esp
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	79 16                	jns    801d23 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801d0d:	85 f6                	test   %esi,%esi
  801d0f:	74 06                	je     801d17 <ipc_recv+0x32>
			*from_env_store = 0;
  801d11:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801d17:	85 db                	test   %ebx,%ebx
  801d19:	74 2c                	je     801d47 <ipc_recv+0x62>
			*perm_store = 0;
  801d1b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801d21:	eb 24                	jmp    801d47 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801d23:	85 f6                	test   %esi,%esi
  801d25:	74 0a                	je     801d31 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801d27:	a1 08 40 80 00       	mov    0x804008,%eax
  801d2c:	8b 40 74             	mov    0x74(%eax),%eax
  801d2f:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801d31:	85 db                	test   %ebx,%ebx
  801d33:	74 0a                	je     801d3f <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801d35:	a1 08 40 80 00       	mov    0x804008,%eax
  801d3a:	8b 40 78             	mov    0x78(%eax),%eax
  801d3d:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801d3f:	a1 08 40 80 00       	mov    0x804008,%eax
  801d44:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4a:	5b                   	pop    %ebx
  801d4b:	5e                   	pop    %esi
  801d4c:	5d                   	pop    %ebp
  801d4d:	c3                   	ret    

00801d4e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	57                   	push   %edi
  801d52:	56                   	push   %esi
  801d53:	53                   	push   %ebx
  801d54:	83 ec 0c             	sub    $0xc,%esp
  801d57:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d5a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801d60:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801d62:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801d67:	0f 44 d8             	cmove  %eax,%ebx
  801d6a:	eb 1e                	jmp    801d8a <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801d6c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d6f:	74 14                	je     801d85 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801d71:	83 ec 04             	sub    $0x4,%esp
  801d74:	68 c4 25 80 00       	push   $0x8025c4
  801d79:	6a 44                	push   $0x44
  801d7b:	68 f0 25 80 00       	push   $0x8025f0
  801d80:	e8 b6 e4 ff ff       	call   80023b <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801d85:	e8 19 f0 ff ff       	call   800da3 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801d8a:	ff 75 14             	pushl  0x14(%ebp)
  801d8d:	53                   	push   %ebx
  801d8e:	56                   	push   %esi
  801d8f:	57                   	push   %edi
  801d90:	e8 ba f1 ff ff       	call   800f4f <sys_ipc_try_send>
  801d95:	83 c4 10             	add    $0x10,%esp
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	78 d0                	js     801d6c <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801d9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d9f:	5b                   	pop    %ebx
  801da0:	5e                   	pop    %esi
  801da1:	5f                   	pop    %edi
  801da2:	5d                   	pop    %ebp
  801da3:	c3                   	ret    

00801da4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801daa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801daf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801db2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801db8:	8b 52 50             	mov    0x50(%edx),%edx
  801dbb:	39 ca                	cmp    %ecx,%edx
  801dbd:	75 0d                	jne    801dcc <ipc_find_env+0x28>
			return envs[i].env_id;
  801dbf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801dc2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801dc7:	8b 40 48             	mov    0x48(%eax),%eax
  801dca:	eb 0f                	jmp    801ddb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801dcc:	83 c0 01             	add    $0x1,%eax
  801dcf:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dd4:	75 d9                	jne    801daf <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801dd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ddb:	5d                   	pop    %ebp
  801ddc:	c3                   	ret    

00801ddd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ddd:	55                   	push   %ebp
  801dde:	89 e5                	mov    %esp,%ebp
  801de0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801de3:	89 d0                	mov    %edx,%eax
  801de5:	c1 e8 16             	shr    $0x16,%eax
  801de8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801def:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801df4:	f6 c1 01             	test   $0x1,%cl
  801df7:	74 1d                	je     801e16 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801df9:	c1 ea 0c             	shr    $0xc,%edx
  801dfc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e03:	f6 c2 01             	test   $0x1,%dl
  801e06:	74 0e                	je     801e16 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e08:	c1 ea 0c             	shr    $0xc,%edx
  801e0b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e12:	ef 
  801e13:	0f b7 c0             	movzwl %ax,%eax
}
  801e16:	5d                   	pop    %ebp
  801e17:	c3                   	ret    
  801e18:	66 90                	xchg   %ax,%ax
  801e1a:	66 90                	xchg   %ax,%ax
  801e1c:	66 90                	xchg   %ax,%ax
  801e1e:	66 90                	xchg   %ax,%ax

00801e20 <__udivdi3>:
  801e20:	55                   	push   %ebp
  801e21:	57                   	push   %edi
  801e22:	56                   	push   %esi
  801e23:	53                   	push   %ebx
  801e24:	83 ec 1c             	sub    $0x1c,%esp
  801e27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801e2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e37:	85 f6                	test   %esi,%esi
  801e39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e3d:	89 ca                	mov    %ecx,%edx
  801e3f:	89 f8                	mov    %edi,%eax
  801e41:	75 3d                	jne    801e80 <__udivdi3+0x60>
  801e43:	39 cf                	cmp    %ecx,%edi
  801e45:	0f 87 c5 00 00 00    	ja     801f10 <__udivdi3+0xf0>
  801e4b:	85 ff                	test   %edi,%edi
  801e4d:	89 fd                	mov    %edi,%ebp
  801e4f:	75 0b                	jne    801e5c <__udivdi3+0x3c>
  801e51:	b8 01 00 00 00       	mov    $0x1,%eax
  801e56:	31 d2                	xor    %edx,%edx
  801e58:	f7 f7                	div    %edi
  801e5a:	89 c5                	mov    %eax,%ebp
  801e5c:	89 c8                	mov    %ecx,%eax
  801e5e:	31 d2                	xor    %edx,%edx
  801e60:	f7 f5                	div    %ebp
  801e62:	89 c1                	mov    %eax,%ecx
  801e64:	89 d8                	mov    %ebx,%eax
  801e66:	89 cf                	mov    %ecx,%edi
  801e68:	f7 f5                	div    %ebp
  801e6a:	89 c3                	mov    %eax,%ebx
  801e6c:	89 d8                	mov    %ebx,%eax
  801e6e:	89 fa                	mov    %edi,%edx
  801e70:	83 c4 1c             	add    $0x1c,%esp
  801e73:	5b                   	pop    %ebx
  801e74:	5e                   	pop    %esi
  801e75:	5f                   	pop    %edi
  801e76:	5d                   	pop    %ebp
  801e77:	c3                   	ret    
  801e78:	90                   	nop
  801e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e80:	39 ce                	cmp    %ecx,%esi
  801e82:	77 74                	ja     801ef8 <__udivdi3+0xd8>
  801e84:	0f bd fe             	bsr    %esi,%edi
  801e87:	83 f7 1f             	xor    $0x1f,%edi
  801e8a:	0f 84 98 00 00 00    	je     801f28 <__udivdi3+0x108>
  801e90:	bb 20 00 00 00       	mov    $0x20,%ebx
  801e95:	89 f9                	mov    %edi,%ecx
  801e97:	89 c5                	mov    %eax,%ebp
  801e99:	29 fb                	sub    %edi,%ebx
  801e9b:	d3 e6                	shl    %cl,%esi
  801e9d:	89 d9                	mov    %ebx,%ecx
  801e9f:	d3 ed                	shr    %cl,%ebp
  801ea1:	89 f9                	mov    %edi,%ecx
  801ea3:	d3 e0                	shl    %cl,%eax
  801ea5:	09 ee                	or     %ebp,%esi
  801ea7:	89 d9                	mov    %ebx,%ecx
  801ea9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ead:	89 d5                	mov    %edx,%ebp
  801eaf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801eb3:	d3 ed                	shr    %cl,%ebp
  801eb5:	89 f9                	mov    %edi,%ecx
  801eb7:	d3 e2                	shl    %cl,%edx
  801eb9:	89 d9                	mov    %ebx,%ecx
  801ebb:	d3 e8                	shr    %cl,%eax
  801ebd:	09 c2                	or     %eax,%edx
  801ebf:	89 d0                	mov    %edx,%eax
  801ec1:	89 ea                	mov    %ebp,%edx
  801ec3:	f7 f6                	div    %esi
  801ec5:	89 d5                	mov    %edx,%ebp
  801ec7:	89 c3                	mov    %eax,%ebx
  801ec9:	f7 64 24 0c          	mull   0xc(%esp)
  801ecd:	39 d5                	cmp    %edx,%ebp
  801ecf:	72 10                	jb     801ee1 <__udivdi3+0xc1>
  801ed1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ed5:	89 f9                	mov    %edi,%ecx
  801ed7:	d3 e6                	shl    %cl,%esi
  801ed9:	39 c6                	cmp    %eax,%esi
  801edb:	73 07                	jae    801ee4 <__udivdi3+0xc4>
  801edd:	39 d5                	cmp    %edx,%ebp
  801edf:	75 03                	jne    801ee4 <__udivdi3+0xc4>
  801ee1:	83 eb 01             	sub    $0x1,%ebx
  801ee4:	31 ff                	xor    %edi,%edi
  801ee6:	89 d8                	mov    %ebx,%eax
  801ee8:	89 fa                	mov    %edi,%edx
  801eea:	83 c4 1c             	add    $0x1c,%esp
  801eed:	5b                   	pop    %ebx
  801eee:	5e                   	pop    %esi
  801eef:	5f                   	pop    %edi
  801ef0:	5d                   	pop    %ebp
  801ef1:	c3                   	ret    
  801ef2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ef8:	31 ff                	xor    %edi,%edi
  801efa:	31 db                	xor    %ebx,%ebx
  801efc:	89 d8                	mov    %ebx,%eax
  801efe:	89 fa                	mov    %edi,%edx
  801f00:	83 c4 1c             	add    $0x1c,%esp
  801f03:	5b                   	pop    %ebx
  801f04:	5e                   	pop    %esi
  801f05:	5f                   	pop    %edi
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    
  801f08:	90                   	nop
  801f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f10:	89 d8                	mov    %ebx,%eax
  801f12:	f7 f7                	div    %edi
  801f14:	31 ff                	xor    %edi,%edi
  801f16:	89 c3                	mov    %eax,%ebx
  801f18:	89 d8                	mov    %ebx,%eax
  801f1a:	89 fa                	mov    %edi,%edx
  801f1c:	83 c4 1c             	add    $0x1c,%esp
  801f1f:	5b                   	pop    %ebx
  801f20:	5e                   	pop    %esi
  801f21:	5f                   	pop    %edi
  801f22:	5d                   	pop    %ebp
  801f23:	c3                   	ret    
  801f24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f28:	39 ce                	cmp    %ecx,%esi
  801f2a:	72 0c                	jb     801f38 <__udivdi3+0x118>
  801f2c:	31 db                	xor    %ebx,%ebx
  801f2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f32:	0f 87 34 ff ff ff    	ja     801e6c <__udivdi3+0x4c>
  801f38:	bb 01 00 00 00       	mov    $0x1,%ebx
  801f3d:	e9 2a ff ff ff       	jmp    801e6c <__udivdi3+0x4c>
  801f42:	66 90                	xchg   %ax,%ax
  801f44:	66 90                	xchg   %ax,%ax
  801f46:	66 90                	xchg   %ax,%ax
  801f48:	66 90                	xchg   %ax,%ax
  801f4a:	66 90                	xchg   %ax,%ax
  801f4c:	66 90                	xchg   %ax,%ax
  801f4e:	66 90                	xchg   %ax,%ax

00801f50 <__umoddi3>:
  801f50:	55                   	push   %ebp
  801f51:	57                   	push   %edi
  801f52:	56                   	push   %esi
  801f53:	53                   	push   %ebx
  801f54:	83 ec 1c             	sub    $0x1c,%esp
  801f57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f67:	85 d2                	test   %edx,%edx
  801f69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f71:	89 f3                	mov    %esi,%ebx
  801f73:	89 3c 24             	mov    %edi,(%esp)
  801f76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f7a:	75 1c                	jne    801f98 <__umoddi3+0x48>
  801f7c:	39 f7                	cmp    %esi,%edi
  801f7e:	76 50                	jbe    801fd0 <__umoddi3+0x80>
  801f80:	89 c8                	mov    %ecx,%eax
  801f82:	89 f2                	mov    %esi,%edx
  801f84:	f7 f7                	div    %edi
  801f86:	89 d0                	mov    %edx,%eax
  801f88:	31 d2                	xor    %edx,%edx
  801f8a:	83 c4 1c             	add    $0x1c,%esp
  801f8d:	5b                   	pop    %ebx
  801f8e:	5e                   	pop    %esi
  801f8f:	5f                   	pop    %edi
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    
  801f92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f98:	39 f2                	cmp    %esi,%edx
  801f9a:	89 d0                	mov    %edx,%eax
  801f9c:	77 52                	ja     801ff0 <__umoddi3+0xa0>
  801f9e:	0f bd ea             	bsr    %edx,%ebp
  801fa1:	83 f5 1f             	xor    $0x1f,%ebp
  801fa4:	75 5a                	jne    802000 <__umoddi3+0xb0>
  801fa6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801faa:	0f 82 e0 00 00 00    	jb     802090 <__umoddi3+0x140>
  801fb0:	39 0c 24             	cmp    %ecx,(%esp)
  801fb3:	0f 86 d7 00 00 00    	jbe    802090 <__umoddi3+0x140>
  801fb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fbd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801fc1:	83 c4 1c             	add    $0x1c,%esp
  801fc4:	5b                   	pop    %ebx
  801fc5:	5e                   	pop    %esi
  801fc6:	5f                   	pop    %edi
  801fc7:	5d                   	pop    %ebp
  801fc8:	c3                   	ret    
  801fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	85 ff                	test   %edi,%edi
  801fd2:	89 fd                	mov    %edi,%ebp
  801fd4:	75 0b                	jne    801fe1 <__umoddi3+0x91>
  801fd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801fdb:	31 d2                	xor    %edx,%edx
  801fdd:	f7 f7                	div    %edi
  801fdf:	89 c5                	mov    %eax,%ebp
  801fe1:	89 f0                	mov    %esi,%eax
  801fe3:	31 d2                	xor    %edx,%edx
  801fe5:	f7 f5                	div    %ebp
  801fe7:	89 c8                	mov    %ecx,%eax
  801fe9:	f7 f5                	div    %ebp
  801feb:	89 d0                	mov    %edx,%eax
  801fed:	eb 99                	jmp    801f88 <__umoddi3+0x38>
  801fef:	90                   	nop
  801ff0:	89 c8                	mov    %ecx,%eax
  801ff2:	89 f2                	mov    %esi,%edx
  801ff4:	83 c4 1c             	add    $0x1c,%esp
  801ff7:	5b                   	pop    %ebx
  801ff8:	5e                   	pop    %esi
  801ff9:	5f                   	pop    %edi
  801ffa:	5d                   	pop    %ebp
  801ffb:	c3                   	ret    
  801ffc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802000:	8b 34 24             	mov    (%esp),%esi
  802003:	bf 20 00 00 00       	mov    $0x20,%edi
  802008:	89 e9                	mov    %ebp,%ecx
  80200a:	29 ef                	sub    %ebp,%edi
  80200c:	d3 e0                	shl    %cl,%eax
  80200e:	89 f9                	mov    %edi,%ecx
  802010:	89 f2                	mov    %esi,%edx
  802012:	d3 ea                	shr    %cl,%edx
  802014:	89 e9                	mov    %ebp,%ecx
  802016:	09 c2                	or     %eax,%edx
  802018:	89 d8                	mov    %ebx,%eax
  80201a:	89 14 24             	mov    %edx,(%esp)
  80201d:	89 f2                	mov    %esi,%edx
  80201f:	d3 e2                	shl    %cl,%edx
  802021:	89 f9                	mov    %edi,%ecx
  802023:	89 54 24 04          	mov    %edx,0x4(%esp)
  802027:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80202b:	d3 e8                	shr    %cl,%eax
  80202d:	89 e9                	mov    %ebp,%ecx
  80202f:	89 c6                	mov    %eax,%esi
  802031:	d3 e3                	shl    %cl,%ebx
  802033:	89 f9                	mov    %edi,%ecx
  802035:	89 d0                	mov    %edx,%eax
  802037:	d3 e8                	shr    %cl,%eax
  802039:	89 e9                	mov    %ebp,%ecx
  80203b:	09 d8                	or     %ebx,%eax
  80203d:	89 d3                	mov    %edx,%ebx
  80203f:	89 f2                	mov    %esi,%edx
  802041:	f7 34 24             	divl   (%esp)
  802044:	89 d6                	mov    %edx,%esi
  802046:	d3 e3                	shl    %cl,%ebx
  802048:	f7 64 24 04          	mull   0x4(%esp)
  80204c:	39 d6                	cmp    %edx,%esi
  80204e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802052:	89 d1                	mov    %edx,%ecx
  802054:	89 c3                	mov    %eax,%ebx
  802056:	72 08                	jb     802060 <__umoddi3+0x110>
  802058:	75 11                	jne    80206b <__umoddi3+0x11b>
  80205a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80205e:	73 0b                	jae    80206b <__umoddi3+0x11b>
  802060:	2b 44 24 04          	sub    0x4(%esp),%eax
  802064:	1b 14 24             	sbb    (%esp),%edx
  802067:	89 d1                	mov    %edx,%ecx
  802069:	89 c3                	mov    %eax,%ebx
  80206b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80206f:	29 da                	sub    %ebx,%edx
  802071:	19 ce                	sbb    %ecx,%esi
  802073:	89 f9                	mov    %edi,%ecx
  802075:	89 f0                	mov    %esi,%eax
  802077:	d3 e0                	shl    %cl,%eax
  802079:	89 e9                	mov    %ebp,%ecx
  80207b:	d3 ea                	shr    %cl,%edx
  80207d:	89 e9                	mov    %ebp,%ecx
  80207f:	d3 ee                	shr    %cl,%esi
  802081:	09 d0                	or     %edx,%eax
  802083:	89 f2                	mov    %esi,%edx
  802085:	83 c4 1c             	add    $0x1c,%esp
  802088:	5b                   	pop    %ebx
  802089:	5e                   	pop    %esi
  80208a:	5f                   	pop    %edi
  80208b:	5d                   	pop    %ebp
  80208c:	c3                   	ret    
  80208d:	8d 76 00             	lea    0x0(%esi),%esi
  802090:	29 f9                	sub    %edi,%ecx
  802092:	19 d6                	sbb    %edx,%esi
  802094:	89 74 24 04          	mov    %esi,0x4(%esp)
  802098:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80209c:	e9 18 ff ff ff       	jmp    801fb9 <__umoddi3+0x69>
