
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 40 20 80 00       	push   $0x802040
  800045:	e8 b9 01 00 00       	call   800203 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 53 0c 00 00       	call   800cb1 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 60 20 80 00       	push   $0x802060
  80006f:	6a 0e                	push   $0xe
  800071:	68 4a 20 80 00       	push   $0x80204a
  800076:	e8 af 00 00 00       	call   80012a <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 8c 20 80 00       	push   $0x80208c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 5b 07 00 00       	call   8007e4 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 01 0e 00 00       	call   800ea2 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 5c 20 80 00       	push   $0x80205c
  8000ae:	e8 50 01 00 00       	call   800203 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 5c 20 80 00       	push   $0x80205c
  8000c0:	e8 3e 01 00 00       	call   800203 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d5:	e8 99 0b 00 00       	call   800c73 <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800116:	e8 e1 0f 00 00       	call   8010fc <close_all>
	sys_env_destroy(0);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	6a 00                	push   $0x0
  800120:	e8 0d 0b 00 00       	call   800c32 <sys_env_destroy>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800132:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800138:	e8 36 0b 00 00       	call   800c73 <sys_getenvid>
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	56                   	push   %esi
  800147:	50                   	push   %eax
  800148:	68 b8 20 80 00       	push   $0x8020b8
  80014d:	e8 b1 00 00 00       	call   800203 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	pushl  0x10(%ebp)
  800159:	e8 54 00 00 00       	call   8001b2 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 51 25 80 00 	movl   $0x802551,(%esp)
  800165:	e8 99 00 00 00       	call   800203 <cprintf>
  80016a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016d:	cc                   	int3   
  80016e:	eb fd                	jmp    80016d <_panic+0x43>

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 13                	mov    (%ebx),%edx
  80017c:	8d 42 01             	lea    0x1(%edx),%eax
  80017f:	89 03                	mov    %eax,(%ebx)
  800181:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800184:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800188:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018d:	75 1a                	jne    8001a9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	68 ff 00 00 00       	push   $0xff
  800197:	8d 43 08             	lea    0x8(%ebx),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 55 0a 00 00       	call   800bf5 <sys_cputs>
		b->idx = 0;
  8001a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    

008001b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c2:	00 00 00 
	b.cnt = 0;
  8001c5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	ff 75 08             	pushl  0x8(%ebp)
  8001d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	68 70 01 80 00       	push   $0x800170
  8001e1:	e8 54 01 00 00       	call   80033a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e6:	83 c4 08             	add    $0x8,%esp
  8001e9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f5:	50                   	push   %eax
  8001f6:	e8 fa 09 00 00       	call   800bf5 <sys_cputs>

	return b.cnt;
}
  8001fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800209:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020c:	50                   	push   %eax
  80020d:	ff 75 08             	pushl  0x8(%ebp)
  800210:	e8 9d ff ff ff       	call   8001b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	57                   	push   %edi
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 1c             	sub    $0x1c,%esp
  800220:	89 c7                	mov    %eax,%edi
  800222:	89 d6                	mov    %edx,%esi
  800224:	8b 45 08             	mov    0x8(%ebp),%eax
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800230:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80023b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023e:	39 d3                	cmp    %edx,%ebx
  800240:	72 05                	jb     800247 <printnum+0x30>
  800242:	39 45 10             	cmp    %eax,0x10(%ebp)
  800245:	77 45                	ja     80028c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	ff 75 18             	pushl  0x18(%ebp)
  80024d:	8b 45 14             	mov    0x14(%ebp),%eax
  800250:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800253:	53                   	push   %ebx
  800254:	ff 75 10             	pushl  0x10(%ebp)
  800257:	83 ec 08             	sub    $0x8,%esp
  80025a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025d:	ff 75 e0             	pushl  -0x20(%ebp)
  800260:	ff 75 dc             	pushl  -0x24(%ebp)
  800263:	ff 75 d8             	pushl  -0x28(%ebp)
  800266:	e8 35 1b 00 00       	call   801da0 <__udivdi3>
  80026b:	83 c4 18             	add    $0x18,%esp
  80026e:	52                   	push   %edx
  80026f:	50                   	push   %eax
  800270:	89 f2                	mov    %esi,%edx
  800272:	89 f8                	mov    %edi,%eax
  800274:	e8 9e ff ff ff       	call   800217 <printnum>
  800279:	83 c4 20             	add    $0x20,%esp
  80027c:	eb 18                	jmp    800296 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	56                   	push   %esi
  800282:	ff 75 18             	pushl  0x18(%ebp)
  800285:	ff d7                	call   *%edi
  800287:	83 c4 10             	add    $0x10,%esp
  80028a:	eb 03                	jmp    80028f <printnum+0x78>
  80028c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028f:	83 eb 01             	sub    $0x1,%ebx
  800292:	85 db                	test   %ebx,%ebx
  800294:	7f e8                	jg     80027e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	56                   	push   %esi
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a9:	e8 22 1c 00 00       	call   801ed0 <__umoddi3>
  8002ae:	83 c4 14             	add    $0x14,%esp
  8002b1:	0f be 80 db 20 80 00 	movsbl 0x8020db(%eax),%eax
  8002b8:	50                   	push   %eax
  8002b9:	ff d7                	call   *%edi
}
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c9:	83 fa 01             	cmp    $0x1,%edx
  8002cc:	7e 0e                	jle    8002dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	8b 52 04             	mov    0x4(%edx),%edx
  8002da:	eb 22                	jmp    8002fe <getuint+0x38>
	else if (lflag)
  8002dc:	85 d2                	test   %edx,%edx
  8002de:	74 10                	je     8002f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ee:	eb 0e                	jmp    8002fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800306:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030a:	8b 10                	mov    (%eax),%edx
  80030c:	3b 50 04             	cmp    0x4(%eax),%edx
  80030f:	73 0a                	jae    80031b <sprintputch+0x1b>
		*b->buf++ = ch;
  800311:	8d 4a 01             	lea    0x1(%edx),%ecx
  800314:	89 08                	mov    %ecx,(%eax)
  800316:	8b 45 08             	mov    0x8(%ebp),%eax
  800319:	88 02                	mov    %al,(%edx)
}
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800323:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 10             	pushl  0x10(%ebp)
  80032a:	ff 75 0c             	pushl  0xc(%ebp)
  80032d:	ff 75 08             	pushl  0x8(%ebp)
  800330:	e8 05 00 00 00       	call   80033a <vprintfmt>
	va_end(ap);
}
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	c9                   	leave  
  800339:	c3                   	ret    

0080033a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	57                   	push   %edi
  80033e:	56                   	push   %esi
  80033f:	53                   	push   %ebx
  800340:	83 ec 2c             	sub    $0x2c,%esp
  800343:	8b 75 08             	mov    0x8(%ebp),%esi
  800346:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800349:	8b 7d 10             	mov    0x10(%ebp),%edi
  80034c:	eb 12                	jmp    800360 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034e:	85 c0                	test   %eax,%eax
  800350:	0f 84 38 04 00 00    	je     80078e <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800356:	83 ec 08             	sub    $0x8,%esp
  800359:	53                   	push   %ebx
  80035a:	50                   	push   %eax
  80035b:	ff d6                	call   *%esi
  80035d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800360:	83 c7 01             	add    $0x1,%edi
  800363:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800367:	83 f8 25             	cmp    $0x25,%eax
  80036a:	75 e2                	jne    80034e <vprintfmt+0x14>
  80036c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800370:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800377:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800385:	ba 00 00 00 00       	mov    $0x0,%edx
  80038a:	eb 07                	jmp    800393 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  80038f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8d 47 01             	lea    0x1(%edi),%eax
  800396:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800399:	0f b6 07             	movzbl (%edi),%eax
  80039c:	0f b6 c8             	movzbl %al,%ecx
  80039f:	83 e8 23             	sub    $0x23,%eax
  8003a2:	3c 55                	cmp    $0x55,%al
  8003a4:	0f 87 c9 03 00 00    	ja     800773 <vprintfmt+0x439>
  8003aa:	0f b6 c0             	movzbl %al,%eax
  8003ad:	ff 24 85 20 22 80 00 	jmp    *0x802220(,%eax,4)
  8003b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003bb:	eb d6                	jmp    800393 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  8003bd:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  8003c4:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  8003ca:	eb 94                	jmp    800360 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  8003cc:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  8003d3:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  8003d9:	eb 85                	jmp    800360 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  8003db:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  8003e2:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  8003e8:	e9 73 ff ff ff       	jmp    800360 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  8003ed:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  8003f4:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  8003fa:	e9 61 ff ff ff       	jmp    800360 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  8003ff:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800406:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  80040c:	e9 4f ff ff ff       	jmp    800360 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  800411:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800418:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80041e:	e9 3d ff ff ff       	jmp    800360 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  800423:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  80042a:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  800430:	e9 2b ff ff ff       	jmp    800360 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  800435:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  80043c:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  800442:	e9 19 ff ff ff       	jmp    800360 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800447:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  80044e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  800454:	e9 07 ff ff ff       	jmp    800360 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  800459:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  800460:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800466:	e9 f5 fe ff ff       	jmp    800360 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046e:	b8 00 00 00 00       	mov    $0x0,%eax
  800473:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800476:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800479:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80047d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800480:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800483:	83 fa 09             	cmp    $0x9,%edx
  800486:	77 3f                	ja     8004c7 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800488:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80048b:	eb e9                	jmp    800476 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8d 48 04             	lea    0x4(%eax),%ecx
  800493:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800496:	8b 00                	mov    (%eax),%eax
  800498:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80049e:	eb 2d                	jmp    8004cd <vprintfmt+0x193>
  8004a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004aa:	0f 49 c8             	cmovns %eax,%ecx
  8004ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b3:	e9 db fe ff ff       	jmp    800393 <vprintfmt+0x59>
  8004b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004c2:	e9 cc fe ff ff       	jmp    800393 <vprintfmt+0x59>
  8004c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004ca:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d1:	0f 89 bc fe ff ff    	jns    800393 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004dd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004e4:	e9 aa fe ff ff       	jmp    800393 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ef:	e9 9f fe ff ff       	jmp    800393 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f7:	8d 50 04             	lea    0x4(%eax),%edx
  8004fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	53                   	push   %ebx
  800501:	ff 30                	pushl  (%eax)
  800503:	ff d6                	call   *%esi
			break;
  800505:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80050b:	e9 50 fe ff ff       	jmp    800360 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8d 50 04             	lea    0x4(%eax),%edx
  800516:	89 55 14             	mov    %edx,0x14(%ebp)
  800519:	8b 00                	mov    (%eax),%eax
  80051b:	99                   	cltd   
  80051c:	31 d0                	xor    %edx,%eax
  80051e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800520:	83 f8 0f             	cmp    $0xf,%eax
  800523:	7f 0b                	jg     800530 <vprintfmt+0x1f6>
  800525:	8b 14 85 80 23 80 00 	mov    0x802380(,%eax,4),%edx
  80052c:	85 d2                	test   %edx,%edx
  80052e:	75 18                	jne    800548 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  800530:	50                   	push   %eax
  800531:	68 f3 20 80 00       	push   $0x8020f3
  800536:	53                   	push   %ebx
  800537:	56                   	push   %esi
  800538:	e8 e0 fd ff ff       	call   80031d <printfmt>
  80053d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800540:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800543:	e9 18 fe ff ff       	jmp    800360 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800548:	52                   	push   %edx
  800549:	68 f1 24 80 00       	push   $0x8024f1
  80054e:	53                   	push   %ebx
  80054f:	56                   	push   %esi
  800550:	e8 c8 fd ff ff       	call   80031d <printfmt>
  800555:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800558:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055b:	e9 00 fe ff ff       	jmp    800360 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 50 04             	lea    0x4(%eax),%edx
  800566:	89 55 14             	mov    %edx,0x14(%ebp)
  800569:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80056b:	85 ff                	test   %edi,%edi
  80056d:	b8 ec 20 80 00       	mov    $0x8020ec,%eax
  800572:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800575:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800579:	0f 8e 94 00 00 00    	jle    800613 <vprintfmt+0x2d9>
  80057f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800583:	0f 84 98 00 00 00    	je     800621 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	ff 75 d0             	pushl  -0x30(%ebp)
  80058f:	57                   	push   %edi
  800590:	e8 81 02 00 00       	call   800816 <strnlen>
  800595:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800598:	29 c1                	sub    %eax,%ecx
  80059a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80059d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005a0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005aa:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ac:	eb 0f                	jmp    8005bd <vprintfmt+0x283>
					putch(padc, putdat);
  8005ae:	83 ec 08             	sub    $0x8,%esp
  8005b1:	53                   	push   %ebx
  8005b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b7:	83 ef 01             	sub    $0x1,%edi
  8005ba:	83 c4 10             	add    $0x10,%esp
  8005bd:	85 ff                	test   %edi,%edi
  8005bf:	7f ed                	jg     8005ae <vprintfmt+0x274>
  8005c1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005c4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005c7:	85 c9                	test   %ecx,%ecx
  8005c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ce:	0f 49 c1             	cmovns %ecx,%eax
  8005d1:	29 c1                	sub    %eax,%ecx
  8005d3:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005dc:	89 cb                	mov    %ecx,%ebx
  8005de:	eb 4d                	jmp    80062d <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e4:	74 1b                	je     800601 <vprintfmt+0x2c7>
  8005e6:	0f be c0             	movsbl %al,%eax
  8005e9:	83 e8 20             	sub    $0x20,%eax
  8005ec:	83 f8 5e             	cmp    $0x5e,%eax
  8005ef:	76 10                	jbe    800601 <vprintfmt+0x2c7>
					putch('?', putdat);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	ff 75 0c             	pushl  0xc(%ebp)
  8005f7:	6a 3f                	push   $0x3f
  8005f9:	ff 55 08             	call   *0x8(%ebp)
  8005fc:	83 c4 10             	add    $0x10,%esp
  8005ff:	eb 0d                	jmp    80060e <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	ff 75 0c             	pushl  0xc(%ebp)
  800607:	52                   	push   %edx
  800608:	ff 55 08             	call   *0x8(%ebp)
  80060b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060e:	83 eb 01             	sub    $0x1,%ebx
  800611:	eb 1a                	jmp    80062d <vprintfmt+0x2f3>
  800613:	89 75 08             	mov    %esi,0x8(%ebp)
  800616:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800619:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80061c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80061f:	eb 0c                	jmp    80062d <vprintfmt+0x2f3>
  800621:	89 75 08             	mov    %esi,0x8(%ebp)
  800624:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800627:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80062a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80062d:	83 c7 01             	add    $0x1,%edi
  800630:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800634:	0f be d0             	movsbl %al,%edx
  800637:	85 d2                	test   %edx,%edx
  800639:	74 23                	je     80065e <vprintfmt+0x324>
  80063b:	85 f6                	test   %esi,%esi
  80063d:	78 a1                	js     8005e0 <vprintfmt+0x2a6>
  80063f:	83 ee 01             	sub    $0x1,%esi
  800642:	79 9c                	jns    8005e0 <vprintfmt+0x2a6>
  800644:	89 df                	mov    %ebx,%edi
  800646:	8b 75 08             	mov    0x8(%ebp),%esi
  800649:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80064c:	eb 18                	jmp    800666 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 20                	push   $0x20
  800654:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800656:	83 ef 01             	sub    $0x1,%edi
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	eb 08                	jmp    800666 <vprintfmt+0x32c>
  80065e:	89 df                	mov    %ebx,%edi
  800660:	8b 75 08             	mov    0x8(%ebp),%esi
  800663:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800666:	85 ff                	test   %edi,%edi
  800668:	7f e4                	jg     80064e <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80066d:	e9 ee fc ff ff       	jmp    800360 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800672:	83 fa 01             	cmp    $0x1,%edx
  800675:	7e 16                	jle    80068d <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8d 50 08             	lea    0x8(%eax),%edx
  80067d:	89 55 14             	mov    %edx,0x14(%ebp)
  800680:	8b 50 04             	mov    0x4(%eax),%edx
  800683:	8b 00                	mov    (%eax),%eax
  800685:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800688:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068b:	eb 32                	jmp    8006bf <vprintfmt+0x385>
	else if (lflag)
  80068d:	85 d2                	test   %edx,%edx
  80068f:	74 18                	je     8006a9 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8d 50 04             	lea    0x4(%eax),%edx
  800697:	89 55 14             	mov    %edx,0x14(%ebp)
  80069a:	8b 00                	mov    (%eax),%eax
  80069c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069f:	89 c1                	mov    %eax,%ecx
  8006a1:	c1 f9 1f             	sar    $0x1f,%ecx
  8006a4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a7:	eb 16                	jmp    8006bf <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	8d 50 04             	lea    0x4(%eax),%edx
  8006af:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b2:	8b 00                	mov    (%eax),%eax
  8006b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b7:	89 c1                	mov    %eax,%ecx
  8006b9:	c1 f9 1f             	sar    $0x1f,%ecx
  8006bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c5:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006ca:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006ce:	79 6f                	jns    80073f <vprintfmt+0x405>
				putch('-', putdat);
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	53                   	push   %ebx
  8006d4:	6a 2d                	push   $0x2d
  8006d6:	ff d6                	call   *%esi
				num = -(long long) num;
  8006d8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006db:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006de:	f7 d8                	neg    %eax
  8006e0:	83 d2 00             	adc    $0x0,%edx
  8006e3:	f7 da                	neg    %edx
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	eb 55                	jmp    80073f <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ed:	e8 d4 fb ff ff       	call   8002c6 <getuint>
			base = 10;
  8006f2:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8006f7:	eb 46                	jmp    80073f <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fc:	e8 c5 fb ff ff       	call   8002c6 <getuint>
			base = 8;
  800701:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800706:	eb 37                	jmp    80073f <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	6a 30                	push   $0x30
  80070e:	ff d6                	call   *%esi
			putch('x', putdat);
  800710:	83 c4 08             	add    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	6a 78                	push   $0x78
  800716:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8d 50 04             	lea    0x4(%eax),%edx
  80071e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800721:	8b 00                	mov    (%eax),%eax
  800723:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800728:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80072b:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800730:	eb 0d                	jmp    80073f <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800732:	8d 45 14             	lea    0x14(%ebp),%eax
  800735:	e8 8c fb ff ff       	call   8002c6 <getuint>
			base = 16;
  80073a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073f:	83 ec 0c             	sub    $0xc,%esp
  800742:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800746:	51                   	push   %ecx
  800747:	ff 75 e0             	pushl  -0x20(%ebp)
  80074a:	57                   	push   %edi
  80074b:	52                   	push   %edx
  80074c:	50                   	push   %eax
  80074d:	89 da                	mov    %ebx,%edx
  80074f:	89 f0                	mov    %esi,%eax
  800751:	e8 c1 fa ff ff       	call   800217 <printnum>
			break;
  800756:	83 c4 20             	add    $0x20,%esp
  800759:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075c:	e9 ff fb ff ff       	jmp    800360 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	53                   	push   %ebx
  800765:	51                   	push   %ecx
  800766:	ff d6                	call   *%esi
			break;
  800768:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80076e:	e9 ed fb ff ff       	jmp    800360 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	53                   	push   %ebx
  800777:	6a 25                	push   $0x25
  800779:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077b:	83 c4 10             	add    $0x10,%esp
  80077e:	eb 03                	jmp    800783 <vprintfmt+0x449>
  800780:	83 ef 01             	sub    $0x1,%edi
  800783:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800787:	75 f7                	jne    800780 <vprintfmt+0x446>
  800789:	e9 d2 fb ff ff       	jmp    800360 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80078e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800791:	5b                   	pop    %ebx
  800792:	5e                   	pop    %esi
  800793:	5f                   	pop    %edi
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 18             	sub    $0x18,%esp
  80079c:	8b 45 08             	mov    0x8(%ebp),%eax
  80079f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b3:	85 c0                	test   %eax,%eax
  8007b5:	74 26                	je     8007dd <vsnprintf+0x47>
  8007b7:	85 d2                	test   %edx,%edx
  8007b9:	7e 22                	jle    8007dd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007bb:	ff 75 14             	pushl  0x14(%ebp)
  8007be:	ff 75 10             	pushl  0x10(%ebp)
  8007c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c4:	50                   	push   %eax
  8007c5:	68 00 03 80 00       	push   $0x800300
  8007ca:	e8 6b fb ff ff       	call   80033a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	eb 05                	jmp    8007e2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e2:	c9                   	leave  
  8007e3:	c3                   	ret    

008007e4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ea:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ed:	50                   	push   %eax
  8007ee:	ff 75 10             	pushl  0x10(%ebp)
  8007f1:	ff 75 0c             	pushl  0xc(%ebp)
  8007f4:	ff 75 08             	pushl  0x8(%ebp)
  8007f7:	e8 9a ff ff ff       	call   800796 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800804:	b8 00 00 00 00       	mov    $0x0,%eax
  800809:	eb 03                	jmp    80080e <strlen+0x10>
		n++;
  80080b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800812:	75 f7                	jne    80080b <strlen+0xd>
		n++;
	return n;
}
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081f:	ba 00 00 00 00       	mov    $0x0,%edx
  800824:	eb 03                	jmp    800829 <strnlen+0x13>
		n++;
  800826:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800829:	39 c2                	cmp    %eax,%edx
  80082b:	74 08                	je     800835 <strnlen+0x1f>
  80082d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800831:	75 f3                	jne    800826 <strnlen+0x10>
  800833:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	53                   	push   %ebx
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800841:	89 c2                	mov    %eax,%edx
  800843:	83 c2 01             	add    $0x1,%edx
  800846:	83 c1 01             	add    $0x1,%ecx
  800849:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800850:	84 db                	test   %bl,%bl
  800852:	75 ef                	jne    800843 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800854:	5b                   	pop    %ebx
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
  80085b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085e:	53                   	push   %ebx
  80085f:	e8 9a ff ff ff       	call   8007fe <strlen>
  800864:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800867:	ff 75 0c             	pushl  0xc(%ebp)
  80086a:	01 d8                	add    %ebx,%eax
  80086c:	50                   	push   %eax
  80086d:	e8 c5 ff ff ff       	call   800837 <strcpy>
	return dst;
}
  800872:	89 d8                	mov    %ebx,%eax
  800874:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	56                   	push   %esi
  80087d:	53                   	push   %ebx
  80087e:	8b 75 08             	mov    0x8(%ebp),%esi
  800881:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800884:	89 f3                	mov    %esi,%ebx
  800886:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800889:	89 f2                	mov    %esi,%edx
  80088b:	eb 0f                	jmp    80089c <strncpy+0x23>
		*dst++ = *src;
  80088d:	83 c2 01             	add    $0x1,%edx
  800890:	0f b6 01             	movzbl (%ecx),%eax
  800893:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800896:	80 39 01             	cmpb   $0x1,(%ecx)
  800899:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089c:	39 da                	cmp    %ebx,%edx
  80089e:	75 ed                	jne    80088d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a0:	89 f0                	mov    %esi,%eax
  8008a2:	5b                   	pop    %ebx
  8008a3:	5e                   	pop    %esi
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	56                   	push   %esi
  8008aa:	53                   	push   %ebx
  8008ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b1:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b6:	85 d2                	test   %edx,%edx
  8008b8:	74 21                	je     8008db <strlcpy+0x35>
  8008ba:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008be:	89 f2                	mov    %esi,%edx
  8008c0:	eb 09                	jmp    8008cb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c2:	83 c2 01             	add    $0x1,%edx
  8008c5:	83 c1 01             	add    $0x1,%ecx
  8008c8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008cb:	39 c2                	cmp    %eax,%edx
  8008cd:	74 09                	je     8008d8 <strlcpy+0x32>
  8008cf:	0f b6 19             	movzbl (%ecx),%ebx
  8008d2:	84 db                	test   %bl,%bl
  8008d4:	75 ec                	jne    8008c2 <strlcpy+0x1c>
  8008d6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008db:	29 f0                	sub    %esi,%eax
}
  8008dd:	5b                   	pop    %ebx
  8008de:	5e                   	pop    %esi
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ea:	eb 06                	jmp    8008f2 <strcmp+0x11>
		p++, q++;
  8008ec:	83 c1 01             	add    $0x1,%ecx
  8008ef:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f2:	0f b6 01             	movzbl (%ecx),%eax
  8008f5:	84 c0                	test   %al,%al
  8008f7:	74 04                	je     8008fd <strcmp+0x1c>
  8008f9:	3a 02                	cmp    (%edx),%al
  8008fb:	74 ef                	je     8008ec <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fd:	0f b6 c0             	movzbl %al,%eax
  800900:	0f b6 12             	movzbl (%edx),%edx
  800903:	29 d0                	sub    %edx,%eax
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	53                   	push   %ebx
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800911:	89 c3                	mov    %eax,%ebx
  800913:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800916:	eb 06                	jmp    80091e <strncmp+0x17>
		n--, p++, q++;
  800918:	83 c0 01             	add    $0x1,%eax
  80091b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80091e:	39 d8                	cmp    %ebx,%eax
  800920:	74 15                	je     800937 <strncmp+0x30>
  800922:	0f b6 08             	movzbl (%eax),%ecx
  800925:	84 c9                	test   %cl,%cl
  800927:	74 04                	je     80092d <strncmp+0x26>
  800929:	3a 0a                	cmp    (%edx),%cl
  80092b:	74 eb                	je     800918 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092d:	0f b6 00             	movzbl (%eax),%eax
  800930:	0f b6 12             	movzbl (%edx),%edx
  800933:	29 d0                	sub    %edx,%eax
  800935:	eb 05                	jmp    80093c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800937:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093c:	5b                   	pop    %ebx
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800949:	eb 07                	jmp    800952 <strchr+0x13>
		if (*s == c)
  80094b:	38 ca                	cmp    %cl,%dl
  80094d:	74 0f                	je     80095e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094f:	83 c0 01             	add    $0x1,%eax
  800952:	0f b6 10             	movzbl (%eax),%edx
  800955:	84 d2                	test   %dl,%dl
  800957:	75 f2                	jne    80094b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800959:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
  800966:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096a:	eb 03                	jmp    80096f <strfind+0xf>
  80096c:	83 c0 01             	add    $0x1,%eax
  80096f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800972:	38 ca                	cmp    %cl,%dl
  800974:	74 04                	je     80097a <strfind+0x1a>
  800976:	84 d2                	test   %dl,%dl
  800978:	75 f2                	jne    80096c <strfind+0xc>
			break;
	return (char *) s;
}
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	57                   	push   %edi
  800980:	56                   	push   %esi
  800981:	53                   	push   %ebx
  800982:	8b 7d 08             	mov    0x8(%ebp),%edi
  800985:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800988:	85 c9                	test   %ecx,%ecx
  80098a:	74 36                	je     8009c2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800992:	75 28                	jne    8009bc <memset+0x40>
  800994:	f6 c1 03             	test   $0x3,%cl
  800997:	75 23                	jne    8009bc <memset+0x40>
		c &= 0xFF;
  800999:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099d:	89 d3                	mov    %edx,%ebx
  80099f:	c1 e3 08             	shl    $0x8,%ebx
  8009a2:	89 d6                	mov    %edx,%esi
  8009a4:	c1 e6 18             	shl    $0x18,%esi
  8009a7:	89 d0                	mov    %edx,%eax
  8009a9:	c1 e0 10             	shl    $0x10,%eax
  8009ac:	09 f0                	or     %esi,%eax
  8009ae:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009b0:	89 d8                	mov    %ebx,%eax
  8009b2:	09 d0                	or     %edx,%eax
  8009b4:	c1 e9 02             	shr    $0x2,%ecx
  8009b7:	fc                   	cld    
  8009b8:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ba:	eb 06                	jmp    8009c2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bf:	fc                   	cld    
  8009c0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c2:	89 f8                	mov    %edi,%eax
  8009c4:	5b                   	pop    %ebx
  8009c5:	5e                   	pop    %esi
  8009c6:	5f                   	pop    %edi
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	57                   	push   %edi
  8009cd:	56                   	push   %esi
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d7:	39 c6                	cmp    %eax,%esi
  8009d9:	73 35                	jae    800a10 <memmove+0x47>
  8009db:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009de:	39 d0                	cmp    %edx,%eax
  8009e0:	73 2e                	jae    800a10 <memmove+0x47>
		s += n;
		d += n;
  8009e2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e5:	89 d6                	mov    %edx,%esi
  8009e7:	09 fe                	or     %edi,%esi
  8009e9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ef:	75 13                	jne    800a04 <memmove+0x3b>
  8009f1:	f6 c1 03             	test   $0x3,%cl
  8009f4:	75 0e                	jne    800a04 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009f6:	83 ef 04             	sub    $0x4,%edi
  8009f9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009fc:	c1 e9 02             	shr    $0x2,%ecx
  8009ff:	fd                   	std    
  800a00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a02:	eb 09                	jmp    800a0d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a04:	83 ef 01             	sub    $0x1,%edi
  800a07:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a0a:	fd                   	std    
  800a0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0d:	fc                   	cld    
  800a0e:	eb 1d                	jmp    800a2d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a10:	89 f2                	mov    %esi,%edx
  800a12:	09 c2                	or     %eax,%edx
  800a14:	f6 c2 03             	test   $0x3,%dl
  800a17:	75 0f                	jne    800a28 <memmove+0x5f>
  800a19:	f6 c1 03             	test   $0x3,%cl
  800a1c:	75 0a                	jne    800a28 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a1e:	c1 e9 02             	shr    $0x2,%ecx
  800a21:	89 c7                	mov    %eax,%edi
  800a23:	fc                   	cld    
  800a24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a26:	eb 05                	jmp    800a2d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a28:	89 c7                	mov    %eax,%edi
  800a2a:	fc                   	cld    
  800a2b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a2d:	5e                   	pop    %esi
  800a2e:	5f                   	pop    %edi
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a34:	ff 75 10             	pushl  0x10(%ebp)
  800a37:	ff 75 0c             	pushl  0xc(%ebp)
  800a3a:	ff 75 08             	pushl  0x8(%ebp)
  800a3d:	e8 87 ff ff ff       	call   8009c9 <memmove>
}
  800a42:	c9                   	leave  
  800a43:	c3                   	ret    

00800a44 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4f:	89 c6                	mov    %eax,%esi
  800a51:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a54:	eb 1a                	jmp    800a70 <memcmp+0x2c>
		if (*s1 != *s2)
  800a56:	0f b6 08             	movzbl (%eax),%ecx
  800a59:	0f b6 1a             	movzbl (%edx),%ebx
  800a5c:	38 d9                	cmp    %bl,%cl
  800a5e:	74 0a                	je     800a6a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a60:	0f b6 c1             	movzbl %cl,%eax
  800a63:	0f b6 db             	movzbl %bl,%ebx
  800a66:	29 d8                	sub    %ebx,%eax
  800a68:	eb 0f                	jmp    800a79 <memcmp+0x35>
		s1++, s2++;
  800a6a:	83 c0 01             	add    $0x1,%eax
  800a6d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a70:	39 f0                	cmp    %esi,%eax
  800a72:	75 e2                	jne    800a56 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	53                   	push   %ebx
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a84:	89 c1                	mov    %eax,%ecx
  800a86:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a89:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8d:	eb 0a                	jmp    800a99 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8f:	0f b6 10             	movzbl (%eax),%edx
  800a92:	39 da                	cmp    %ebx,%edx
  800a94:	74 07                	je     800a9d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a96:	83 c0 01             	add    $0x1,%eax
  800a99:	39 c8                	cmp    %ecx,%eax
  800a9b:	72 f2                	jb     800a8f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aac:	eb 03                	jmp    800ab1 <strtol+0x11>
		s++;
  800aae:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab1:	0f b6 01             	movzbl (%ecx),%eax
  800ab4:	3c 20                	cmp    $0x20,%al
  800ab6:	74 f6                	je     800aae <strtol+0xe>
  800ab8:	3c 09                	cmp    $0x9,%al
  800aba:	74 f2                	je     800aae <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800abc:	3c 2b                	cmp    $0x2b,%al
  800abe:	75 0a                	jne    800aca <strtol+0x2a>
		s++;
  800ac0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac8:	eb 11                	jmp    800adb <strtol+0x3b>
  800aca:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800acf:	3c 2d                	cmp    $0x2d,%al
  800ad1:	75 08                	jne    800adb <strtol+0x3b>
		s++, neg = 1;
  800ad3:	83 c1 01             	add    $0x1,%ecx
  800ad6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800adb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae1:	75 15                	jne    800af8 <strtol+0x58>
  800ae3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae6:	75 10                	jne    800af8 <strtol+0x58>
  800ae8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aec:	75 7c                	jne    800b6a <strtol+0xca>
		s += 2, base = 16;
  800aee:	83 c1 02             	add    $0x2,%ecx
  800af1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af6:	eb 16                	jmp    800b0e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800af8:	85 db                	test   %ebx,%ebx
  800afa:	75 12                	jne    800b0e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800afc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b01:	80 39 30             	cmpb   $0x30,(%ecx)
  800b04:	75 08                	jne    800b0e <strtol+0x6e>
		s++, base = 8;
  800b06:	83 c1 01             	add    $0x1,%ecx
  800b09:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b13:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b16:	0f b6 11             	movzbl (%ecx),%edx
  800b19:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b1c:	89 f3                	mov    %esi,%ebx
  800b1e:	80 fb 09             	cmp    $0x9,%bl
  800b21:	77 08                	ja     800b2b <strtol+0x8b>
			dig = *s - '0';
  800b23:	0f be d2             	movsbl %dl,%edx
  800b26:	83 ea 30             	sub    $0x30,%edx
  800b29:	eb 22                	jmp    800b4d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b2b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2e:	89 f3                	mov    %esi,%ebx
  800b30:	80 fb 19             	cmp    $0x19,%bl
  800b33:	77 08                	ja     800b3d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b35:	0f be d2             	movsbl %dl,%edx
  800b38:	83 ea 57             	sub    $0x57,%edx
  800b3b:	eb 10                	jmp    800b4d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b3d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b40:	89 f3                	mov    %esi,%ebx
  800b42:	80 fb 19             	cmp    $0x19,%bl
  800b45:	77 16                	ja     800b5d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b47:	0f be d2             	movsbl %dl,%edx
  800b4a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b4d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b50:	7d 0b                	jge    800b5d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b52:	83 c1 01             	add    $0x1,%ecx
  800b55:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b59:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b5b:	eb b9                	jmp    800b16 <strtol+0x76>

	if (endptr)
  800b5d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b61:	74 0d                	je     800b70 <strtol+0xd0>
		*endptr = (char *) s;
  800b63:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b66:	89 0e                	mov    %ecx,(%esi)
  800b68:	eb 06                	jmp    800b70 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6a:	85 db                	test   %ebx,%ebx
  800b6c:	74 98                	je     800b06 <strtol+0x66>
  800b6e:	eb 9e                	jmp    800b0e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b70:	89 c2                	mov    %eax,%edx
  800b72:	f7 da                	neg    %edx
  800b74:	85 ff                	test   %edi,%edi
  800b76:	0f 45 c2             	cmovne %edx,%eax
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	83 ec 04             	sub    $0x4,%esp
  800b87:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800b8a:	57                   	push   %edi
  800b8b:	e8 6e fc ff ff       	call   8007fe <strlen>
  800b90:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b93:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800b96:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800b9b:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800ba0:	eb 46                	jmp    800be8 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800ba2:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800ba6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800ba9:	80 f9 09             	cmp    $0x9,%cl
  800bac:	77 08                	ja     800bb6 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800bae:	0f be d2             	movsbl %dl,%edx
  800bb1:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800bb4:	eb 27                	jmp    800bdd <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800bb6:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800bb9:	80 f9 05             	cmp    $0x5,%cl
  800bbc:	77 08                	ja     800bc6 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800bbe:	0f be d2             	movsbl %dl,%edx
  800bc1:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800bc4:	eb 17                	jmp    800bdd <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800bc6:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800bc9:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800bcc:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800bd1:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800bd5:	77 06                	ja     800bdd <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800bd7:	0f be d2             	movsbl %dl,%edx
  800bda:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800bdd:	0f af ce             	imul   %esi,%ecx
  800be0:	01 c8                	add    %ecx,%eax
		base *= 16;
  800be2:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800be5:	83 eb 01             	sub    $0x1,%ebx
  800be8:	83 fb 01             	cmp    $0x1,%ebx
  800beb:	7f b5                	jg     800ba2 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800bed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	b8 00 00 00 00       	mov    $0x0,%eax
  800c00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c03:	8b 55 08             	mov    0x8(%ebp),%edx
  800c06:	89 c3                	mov    %eax,%ebx
  800c08:	89 c7                	mov    %eax,%edi
  800c0a:	89 c6                	mov    %eax,%esi
  800c0c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c19:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c23:	89 d1                	mov    %edx,%ecx
  800c25:	89 d3                	mov    %edx,%ebx
  800c27:	89 d7                	mov    %edx,%edi
  800c29:	89 d6                	mov    %edx,%esi
  800c2b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c40:	b8 03 00 00 00       	mov    $0x3,%eax
  800c45:	8b 55 08             	mov    0x8(%ebp),%edx
  800c48:	89 cb                	mov    %ecx,%ebx
  800c4a:	89 cf                	mov    %ecx,%edi
  800c4c:	89 ce                	mov    %ecx,%esi
  800c4e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c50:	85 c0                	test   %eax,%eax
  800c52:	7e 17                	jle    800c6b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c54:	83 ec 0c             	sub    $0xc,%esp
  800c57:	50                   	push   %eax
  800c58:	6a 03                	push   $0x3
  800c5a:	68 df 23 80 00       	push   $0x8023df
  800c5f:	6a 23                	push   $0x23
  800c61:	68 fc 23 80 00       	push   $0x8023fc
  800c66:	e8 bf f4 ff ff       	call   80012a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c79:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c83:	89 d1                	mov    %edx,%ecx
  800c85:	89 d3                	mov    %edx,%ebx
  800c87:	89 d7                	mov    %edx,%edi
  800c89:	89 d6                	mov    %edx,%esi
  800c8b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <sys_yield>:

void
sys_yield(void)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c98:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca2:	89 d1                	mov    %edx,%ecx
  800ca4:	89 d3                	mov    %edx,%ebx
  800ca6:	89 d7                	mov    %edx,%edi
  800ca8:	89 d6                	mov    %edx,%esi
  800caa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cba:	be 00 00 00 00       	mov    $0x0,%esi
  800cbf:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccd:	89 f7                	mov    %esi,%edi
  800ccf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd1:	85 c0                	test   %eax,%eax
  800cd3:	7e 17                	jle    800cec <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd5:	83 ec 0c             	sub    $0xc,%esp
  800cd8:	50                   	push   %eax
  800cd9:	6a 04                	push   $0x4
  800cdb:	68 df 23 80 00       	push   $0x8023df
  800ce0:	6a 23                	push   $0x23
  800ce2:	68 fc 23 80 00       	push   $0x8023fc
  800ce7:	e8 3e f4 ff ff       	call   80012a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	b8 05 00 00 00       	mov    $0x5,%eax
  800d02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d05:	8b 55 08             	mov    0x8(%ebp),%edx
  800d08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0e:	8b 75 18             	mov    0x18(%ebp),%esi
  800d11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d13:	85 c0                	test   %eax,%eax
  800d15:	7e 17                	jle    800d2e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d17:	83 ec 0c             	sub    $0xc,%esp
  800d1a:	50                   	push   %eax
  800d1b:	6a 05                	push   $0x5
  800d1d:	68 df 23 80 00       	push   $0x8023df
  800d22:	6a 23                	push   $0x23
  800d24:	68 fc 23 80 00       	push   $0x8023fc
  800d29:	e8 fc f3 ff ff       	call   80012a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d44:	b8 06 00 00 00       	mov    $0x6,%eax
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4f:	89 df                	mov    %ebx,%edi
  800d51:	89 de                	mov    %ebx,%esi
  800d53:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d55:	85 c0                	test   %eax,%eax
  800d57:	7e 17                	jle    800d70 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d59:	83 ec 0c             	sub    $0xc,%esp
  800d5c:	50                   	push   %eax
  800d5d:	6a 06                	push   $0x6
  800d5f:	68 df 23 80 00       	push   $0x8023df
  800d64:	6a 23                	push   $0x23
  800d66:	68 fc 23 80 00       	push   $0x8023fc
  800d6b:	e8 ba f3 ff ff       	call   80012a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
  800d7e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d81:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d86:	b8 08 00 00 00       	mov    $0x8,%eax
  800d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d91:	89 df                	mov    %ebx,%edi
  800d93:	89 de                	mov    %ebx,%esi
  800d95:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d97:	85 c0                	test   %eax,%eax
  800d99:	7e 17                	jle    800db2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9b:	83 ec 0c             	sub    $0xc,%esp
  800d9e:	50                   	push   %eax
  800d9f:	6a 08                	push   $0x8
  800da1:	68 df 23 80 00       	push   $0x8023df
  800da6:	6a 23                	push   $0x23
  800da8:	68 fc 23 80 00       	push   $0x8023fc
  800dad:	e8 78 f3 ff ff       	call   80012a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
  800dc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd3:	89 df                	mov    %ebx,%edi
  800dd5:	89 de                	mov    %ebx,%esi
  800dd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	7e 17                	jle    800df4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddd:	83 ec 0c             	sub    $0xc,%esp
  800de0:	50                   	push   %eax
  800de1:	6a 0a                	push   $0xa
  800de3:	68 df 23 80 00       	push   $0x8023df
  800de8:	6a 23                	push   $0x23
  800dea:	68 fc 23 80 00       	push   $0x8023fc
  800def:	e8 36 f3 ff ff       	call   80012a <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800df4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5f                   	pop    %edi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
  800e02:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e12:	8b 55 08             	mov    0x8(%ebp),%edx
  800e15:	89 df                	mov    %ebx,%edi
  800e17:	89 de                	mov    %ebx,%esi
  800e19:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	7e 17                	jle    800e36 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1f:	83 ec 0c             	sub    $0xc,%esp
  800e22:	50                   	push   %eax
  800e23:	6a 09                	push   $0x9
  800e25:	68 df 23 80 00       	push   $0x8023df
  800e2a:	6a 23                	push   $0x23
  800e2c:	68 fc 23 80 00       	push   $0x8023fc
  800e31:	e8 f4 f2 ff ff       	call   80012a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e39:	5b                   	pop    %ebx
  800e3a:	5e                   	pop    %esi
  800e3b:	5f                   	pop    %edi
  800e3c:	5d                   	pop    %ebp
  800e3d:	c3                   	ret    

00800e3e <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e44:	be 00 00 00 00       	mov    $0x0,%esi
  800e49:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e51:	8b 55 08             	mov    0x8(%ebp),%edx
  800e54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e57:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e5a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	57                   	push   %edi
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
  800e67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e6f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e74:	8b 55 08             	mov    0x8(%ebp),%edx
  800e77:	89 cb                	mov    %ecx,%ebx
  800e79:	89 cf                	mov    %ecx,%edi
  800e7b:	89 ce                	mov    %ecx,%esi
  800e7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	7e 17                	jle    800e9a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e83:	83 ec 0c             	sub    $0xc,%esp
  800e86:	50                   	push   %eax
  800e87:	6a 0d                	push   $0xd
  800e89:	68 df 23 80 00       	push   $0x8023df
  800e8e:	6a 23                	push   $0x23
  800e90:	68 fc 23 80 00       	push   $0x8023fc
  800e95:	e8 90 f2 ff ff       	call   80012a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  800ea8:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800eaf:	75 52                	jne    800f03 <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  800eb1:	83 ec 04             	sub    $0x4,%esp
  800eb4:	6a 07                	push   $0x7
  800eb6:	68 00 f0 bf ee       	push   $0xeebff000
  800ebb:	6a 00                	push   $0x0
  800ebd:	e8 ef fd ff ff       	call   800cb1 <sys_page_alloc>
  800ec2:	83 c4 10             	add    $0x10,%esp
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	79 12                	jns    800edb <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  800ec9:	50                   	push   %eax
  800eca:	68 0a 24 80 00       	push   $0x80240a
  800ecf:	6a 23                	push   $0x23
  800ed1:	68 1d 24 80 00       	push   $0x80241d
  800ed6:	e8 4f f2 ff ff       	call   80012a <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  800edb:	83 ec 08             	sub    $0x8,%esp
  800ede:	68 0d 0f 80 00       	push   $0x800f0d
  800ee3:	6a 00                	push   $0x0
  800ee5:	e8 12 ff ff ff       	call   800dfc <sys_env_set_pgfault_upcall>
  800eea:	83 c4 10             	add    $0x10,%esp
  800eed:	85 c0                	test   %eax,%eax
  800eef:	79 12                	jns    800f03 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  800ef1:	50                   	push   %eax
  800ef2:	68 2c 24 80 00       	push   $0x80242c
  800ef7:	6a 26                	push   $0x26
  800ef9:	68 1d 24 80 00       	push   $0x80241d
  800efe:	e8 27 f2 ff ff       	call   80012a <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f03:	8b 45 08             	mov    0x8(%ebp),%eax
  800f06:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800f0b:	c9                   	leave  
  800f0c:	c3                   	ret    

00800f0d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800f0d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800f0e:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800f13:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800f15:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  800f18:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  800f1c:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  800f21:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  800f25:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800f27:	83 c4 08             	add    $0x8,%esp
	popal 
  800f2a:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800f2b:	83 c4 04             	add    $0x4,%esp
	popfl
  800f2e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800f2f:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800f30:	c3                   	ret    

00800f31 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f34:	8b 45 08             	mov    0x8(%ebp),%eax
  800f37:	05 00 00 00 30       	add    $0x30000000,%eax
  800f3c:	c1 e8 0c             	shr    $0xc,%eax
}
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    

00800f41 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f44:	8b 45 08             	mov    0x8(%ebp),%eax
  800f47:	05 00 00 00 30       	add    $0x30000000,%eax
  800f4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f51:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    

00800f58 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f5e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f63:	89 c2                	mov    %eax,%edx
  800f65:	c1 ea 16             	shr    $0x16,%edx
  800f68:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f6f:	f6 c2 01             	test   $0x1,%dl
  800f72:	74 11                	je     800f85 <fd_alloc+0x2d>
  800f74:	89 c2                	mov    %eax,%edx
  800f76:	c1 ea 0c             	shr    $0xc,%edx
  800f79:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f80:	f6 c2 01             	test   $0x1,%dl
  800f83:	75 09                	jne    800f8e <fd_alloc+0x36>
			*fd_store = fd;
  800f85:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f87:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8c:	eb 17                	jmp    800fa5 <fd_alloc+0x4d>
  800f8e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f93:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f98:	75 c9                	jne    800f63 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f9a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800fa0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    

00800fa7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fad:	83 f8 1f             	cmp    $0x1f,%eax
  800fb0:	77 36                	ja     800fe8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fb2:	c1 e0 0c             	shl    $0xc,%eax
  800fb5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fba:	89 c2                	mov    %eax,%edx
  800fbc:	c1 ea 16             	shr    $0x16,%edx
  800fbf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fc6:	f6 c2 01             	test   $0x1,%dl
  800fc9:	74 24                	je     800fef <fd_lookup+0x48>
  800fcb:	89 c2                	mov    %eax,%edx
  800fcd:	c1 ea 0c             	shr    $0xc,%edx
  800fd0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fd7:	f6 c2 01             	test   $0x1,%dl
  800fda:	74 1a                	je     800ff6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fdc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fdf:	89 02                	mov    %eax,(%edx)
	return 0;
  800fe1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe6:	eb 13                	jmp    800ffb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fe8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fed:	eb 0c                	jmp    800ffb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff4:	eb 05                	jmp    800ffb <fd_lookup+0x54>
  800ff6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    

00800ffd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	83 ec 08             	sub    $0x8,%esp
  801003:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801006:	ba c8 24 80 00       	mov    $0x8024c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80100b:	eb 13                	jmp    801020 <dev_lookup+0x23>
  80100d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801010:	39 08                	cmp    %ecx,(%eax)
  801012:	75 0c                	jne    801020 <dev_lookup+0x23>
			*dev = devtab[i];
  801014:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801017:	89 01                	mov    %eax,(%ecx)
			return 0;
  801019:	b8 00 00 00 00       	mov    $0x0,%eax
  80101e:	eb 2e                	jmp    80104e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801020:	8b 02                	mov    (%edx),%eax
  801022:	85 c0                	test   %eax,%eax
  801024:	75 e7                	jne    80100d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801026:	a1 08 40 80 00       	mov    0x804008,%eax
  80102b:	8b 40 48             	mov    0x48(%eax),%eax
  80102e:	83 ec 04             	sub    $0x4,%esp
  801031:	51                   	push   %ecx
  801032:	50                   	push   %eax
  801033:	68 4c 24 80 00       	push   $0x80244c
  801038:	e8 c6 f1 ff ff       	call   800203 <cprintf>
	*dev = 0;
  80103d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801040:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801046:	83 c4 10             	add    $0x10,%esp
  801049:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80104e:	c9                   	leave  
  80104f:	c3                   	ret    

00801050 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	56                   	push   %esi
  801054:	53                   	push   %ebx
  801055:	83 ec 10             	sub    $0x10,%esp
  801058:	8b 75 08             	mov    0x8(%ebp),%esi
  80105b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80105e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801061:	50                   	push   %eax
  801062:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801068:	c1 e8 0c             	shr    $0xc,%eax
  80106b:	50                   	push   %eax
  80106c:	e8 36 ff ff ff       	call   800fa7 <fd_lookup>
  801071:	83 c4 08             	add    $0x8,%esp
  801074:	85 c0                	test   %eax,%eax
  801076:	78 05                	js     80107d <fd_close+0x2d>
	    || fd != fd2) 
  801078:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80107b:	74 0c                	je     801089 <fd_close+0x39>
		return (must_exist ? r : 0); 
  80107d:	84 db                	test   %bl,%bl
  80107f:	ba 00 00 00 00       	mov    $0x0,%edx
  801084:	0f 44 c2             	cmove  %edx,%eax
  801087:	eb 41                	jmp    8010ca <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801089:	83 ec 08             	sub    $0x8,%esp
  80108c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80108f:	50                   	push   %eax
  801090:	ff 36                	pushl  (%esi)
  801092:	e8 66 ff ff ff       	call   800ffd <dev_lookup>
  801097:	89 c3                	mov    %eax,%ebx
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	85 c0                	test   %eax,%eax
  80109e:	78 1a                	js     8010ba <fd_close+0x6a>
		if (dev->dev_close) 
  8010a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010a3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8010a6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	74 0b                	je     8010ba <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010af:	83 ec 0c             	sub    $0xc,%esp
  8010b2:	56                   	push   %esi
  8010b3:	ff d0                	call   *%eax
  8010b5:	89 c3                	mov    %eax,%ebx
  8010b7:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010ba:	83 ec 08             	sub    $0x8,%esp
  8010bd:	56                   	push   %esi
  8010be:	6a 00                	push   $0x0
  8010c0:	e8 71 fc ff ff       	call   800d36 <sys_page_unmap>
	return r;
  8010c5:	83 c4 10             	add    $0x10,%esp
  8010c8:	89 d8                	mov    %ebx,%eax
}
  8010ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010cd:	5b                   	pop    %ebx
  8010ce:	5e                   	pop    %esi
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010da:	50                   	push   %eax
  8010db:	ff 75 08             	pushl  0x8(%ebp)
  8010de:	e8 c4 fe ff ff       	call   800fa7 <fd_lookup>
  8010e3:	83 c4 08             	add    $0x8,%esp
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	78 10                	js     8010fa <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  8010ea:	83 ec 08             	sub    $0x8,%esp
  8010ed:	6a 01                	push   $0x1
  8010ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8010f2:	e8 59 ff ff ff       	call   801050 <fd_close>
  8010f7:	83 c4 10             	add    $0x10,%esp
}
  8010fa:	c9                   	leave  
  8010fb:	c3                   	ret    

008010fc <close_all>:

void
close_all(void)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	53                   	push   %ebx
  801100:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801103:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801108:	83 ec 0c             	sub    $0xc,%esp
  80110b:	53                   	push   %ebx
  80110c:	e8 c0 ff ff ff       	call   8010d1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801111:	83 c3 01             	add    $0x1,%ebx
  801114:	83 c4 10             	add    $0x10,%esp
  801117:	83 fb 20             	cmp    $0x20,%ebx
  80111a:	75 ec                	jne    801108 <close_all+0xc>
		close(i);
}
  80111c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80111f:	c9                   	leave  
  801120:	c3                   	ret    

00801121 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	57                   	push   %edi
  801125:	56                   	push   %esi
  801126:	53                   	push   %ebx
  801127:	83 ec 2c             	sub    $0x2c,%esp
  80112a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80112d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801130:	50                   	push   %eax
  801131:	ff 75 08             	pushl  0x8(%ebp)
  801134:	e8 6e fe ff ff       	call   800fa7 <fd_lookup>
  801139:	83 c4 08             	add    $0x8,%esp
  80113c:	85 c0                	test   %eax,%eax
  80113e:	0f 88 c1 00 00 00    	js     801205 <dup+0xe4>
		return r;
	close(newfdnum);
  801144:	83 ec 0c             	sub    $0xc,%esp
  801147:	56                   	push   %esi
  801148:	e8 84 ff ff ff       	call   8010d1 <close>

	newfd = INDEX2FD(newfdnum);
  80114d:	89 f3                	mov    %esi,%ebx
  80114f:	c1 e3 0c             	shl    $0xc,%ebx
  801152:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801158:	83 c4 04             	add    $0x4,%esp
  80115b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80115e:	e8 de fd ff ff       	call   800f41 <fd2data>
  801163:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801165:	89 1c 24             	mov    %ebx,(%esp)
  801168:	e8 d4 fd ff ff       	call   800f41 <fd2data>
  80116d:	83 c4 10             	add    $0x10,%esp
  801170:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801173:	89 f8                	mov    %edi,%eax
  801175:	c1 e8 16             	shr    $0x16,%eax
  801178:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80117f:	a8 01                	test   $0x1,%al
  801181:	74 37                	je     8011ba <dup+0x99>
  801183:	89 f8                	mov    %edi,%eax
  801185:	c1 e8 0c             	shr    $0xc,%eax
  801188:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80118f:	f6 c2 01             	test   $0x1,%dl
  801192:	74 26                	je     8011ba <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801194:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80119b:	83 ec 0c             	sub    $0xc,%esp
  80119e:	25 07 0e 00 00       	and    $0xe07,%eax
  8011a3:	50                   	push   %eax
  8011a4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011a7:	6a 00                	push   $0x0
  8011a9:	57                   	push   %edi
  8011aa:	6a 00                	push   $0x0
  8011ac:	e8 43 fb ff ff       	call   800cf4 <sys_page_map>
  8011b1:	89 c7                	mov    %eax,%edi
  8011b3:	83 c4 20             	add    $0x20,%esp
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	78 2e                	js     8011e8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011bd:	89 d0                	mov    %edx,%eax
  8011bf:	c1 e8 0c             	shr    $0xc,%eax
  8011c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011c9:	83 ec 0c             	sub    $0xc,%esp
  8011cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8011d1:	50                   	push   %eax
  8011d2:	53                   	push   %ebx
  8011d3:	6a 00                	push   $0x0
  8011d5:	52                   	push   %edx
  8011d6:	6a 00                	push   $0x0
  8011d8:	e8 17 fb ff ff       	call   800cf4 <sys_page_map>
  8011dd:	89 c7                	mov    %eax,%edi
  8011df:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011e2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011e4:	85 ff                	test   %edi,%edi
  8011e6:	79 1d                	jns    801205 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011e8:	83 ec 08             	sub    $0x8,%esp
  8011eb:	53                   	push   %ebx
  8011ec:	6a 00                	push   $0x0
  8011ee:	e8 43 fb ff ff       	call   800d36 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011f3:	83 c4 08             	add    $0x8,%esp
  8011f6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011f9:	6a 00                	push   $0x0
  8011fb:	e8 36 fb ff ff       	call   800d36 <sys_page_unmap>
	return r;
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	89 f8                	mov    %edi,%eax
}
  801205:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801208:	5b                   	pop    %ebx
  801209:	5e                   	pop    %esi
  80120a:	5f                   	pop    %edi
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    

0080120d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	53                   	push   %ebx
  801211:	83 ec 14             	sub    $0x14,%esp
  801214:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801217:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121a:	50                   	push   %eax
  80121b:	53                   	push   %ebx
  80121c:	e8 86 fd ff ff       	call   800fa7 <fd_lookup>
  801221:	83 c4 08             	add    $0x8,%esp
  801224:	89 c2                	mov    %eax,%edx
  801226:	85 c0                	test   %eax,%eax
  801228:	78 6d                	js     801297 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122a:	83 ec 08             	sub    $0x8,%esp
  80122d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801230:	50                   	push   %eax
  801231:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801234:	ff 30                	pushl  (%eax)
  801236:	e8 c2 fd ff ff       	call   800ffd <dev_lookup>
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	85 c0                	test   %eax,%eax
  801240:	78 4c                	js     80128e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801242:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801245:	8b 42 08             	mov    0x8(%edx),%eax
  801248:	83 e0 03             	and    $0x3,%eax
  80124b:	83 f8 01             	cmp    $0x1,%eax
  80124e:	75 21                	jne    801271 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801250:	a1 08 40 80 00       	mov    0x804008,%eax
  801255:	8b 40 48             	mov    0x48(%eax),%eax
  801258:	83 ec 04             	sub    $0x4,%esp
  80125b:	53                   	push   %ebx
  80125c:	50                   	push   %eax
  80125d:	68 8d 24 80 00       	push   $0x80248d
  801262:	e8 9c ef ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80126f:	eb 26                	jmp    801297 <read+0x8a>
	}
	if (!dev->dev_read)
  801271:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801274:	8b 40 08             	mov    0x8(%eax),%eax
  801277:	85 c0                	test   %eax,%eax
  801279:	74 17                	je     801292 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80127b:	83 ec 04             	sub    $0x4,%esp
  80127e:	ff 75 10             	pushl  0x10(%ebp)
  801281:	ff 75 0c             	pushl  0xc(%ebp)
  801284:	52                   	push   %edx
  801285:	ff d0                	call   *%eax
  801287:	89 c2                	mov    %eax,%edx
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	eb 09                	jmp    801297 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128e:	89 c2                	mov    %eax,%edx
  801290:	eb 05                	jmp    801297 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801292:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801297:	89 d0                	mov    %edx,%eax
  801299:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129c:	c9                   	leave  
  80129d:	c3                   	ret    

0080129e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	57                   	push   %edi
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 0c             	sub    $0xc,%esp
  8012a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012aa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b2:	eb 21                	jmp    8012d5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012b4:	83 ec 04             	sub    $0x4,%esp
  8012b7:	89 f0                	mov    %esi,%eax
  8012b9:	29 d8                	sub    %ebx,%eax
  8012bb:	50                   	push   %eax
  8012bc:	89 d8                	mov    %ebx,%eax
  8012be:	03 45 0c             	add    0xc(%ebp),%eax
  8012c1:	50                   	push   %eax
  8012c2:	57                   	push   %edi
  8012c3:	e8 45 ff ff ff       	call   80120d <read>
		if (m < 0)
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	78 10                	js     8012df <readn+0x41>
			return m;
		if (m == 0)
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	74 0a                	je     8012dd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012d3:	01 c3                	add    %eax,%ebx
  8012d5:	39 f3                	cmp    %esi,%ebx
  8012d7:	72 db                	jb     8012b4 <readn+0x16>
  8012d9:	89 d8                	mov    %ebx,%eax
  8012db:	eb 02                	jmp    8012df <readn+0x41>
  8012dd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e2:	5b                   	pop    %ebx
  8012e3:	5e                   	pop    %esi
  8012e4:	5f                   	pop    %edi
  8012e5:	5d                   	pop    %ebp
  8012e6:	c3                   	ret    

008012e7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	53                   	push   %ebx
  8012eb:	83 ec 14             	sub    $0x14,%esp
  8012ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f4:	50                   	push   %eax
  8012f5:	53                   	push   %ebx
  8012f6:	e8 ac fc ff ff       	call   800fa7 <fd_lookup>
  8012fb:	83 c4 08             	add    $0x8,%esp
  8012fe:	89 c2                	mov    %eax,%edx
  801300:	85 c0                	test   %eax,%eax
  801302:	78 68                	js     80136c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130a:	50                   	push   %eax
  80130b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130e:	ff 30                	pushl  (%eax)
  801310:	e8 e8 fc ff ff       	call   800ffd <dev_lookup>
  801315:	83 c4 10             	add    $0x10,%esp
  801318:	85 c0                	test   %eax,%eax
  80131a:	78 47                	js     801363 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80131c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801323:	75 21                	jne    801346 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801325:	a1 08 40 80 00       	mov    0x804008,%eax
  80132a:	8b 40 48             	mov    0x48(%eax),%eax
  80132d:	83 ec 04             	sub    $0x4,%esp
  801330:	53                   	push   %ebx
  801331:	50                   	push   %eax
  801332:	68 a9 24 80 00       	push   $0x8024a9
  801337:	e8 c7 ee ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  80133c:	83 c4 10             	add    $0x10,%esp
  80133f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801344:	eb 26                	jmp    80136c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801346:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801349:	8b 52 0c             	mov    0xc(%edx),%edx
  80134c:	85 d2                	test   %edx,%edx
  80134e:	74 17                	je     801367 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801350:	83 ec 04             	sub    $0x4,%esp
  801353:	ff 75 10             	pushl  0x10(%ebp)
  801356:	ff 75 0c             	pushl  0xc(%ebp)
  801359:	50                   	push   %eax
  80135a:	ff d2                	call   *%edx
  80135c:	89 c2                	mov    %eax,%edx
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	eb 09                	jmp    80136c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801363:	89 c2                	mov    %eax,%edx
  801365:	eb 05                	jmp    80136c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801367:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80136c:	89 d0                	mov    %edx,%eax
  80136e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <seek>:

int
seek(int fdnum, off_t offset)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801379:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80137c:	50                   	push   %eax
  80137d:	ff 75 08             	pushl  0x8(%ebp)
  801380:	e8 22 fc ff ff       	call   800fa7 <fd_lookup>
  801385:	83 c4 08             	add    $0x8,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 0e                	js     80139a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80138c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80138f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801392:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801395:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80139a:	c9                   	leave  
  80139b:	c3                   	ret    

0080139c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	53                   	push   %ebx
  8013a0:	83 ec 14             	sub    $0x14,%esp
  8013a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a9:	50                   	push   %eax
  8013aa:	53                   	push   %ebx
  8013ab:	e8 f7 fb ff ff       	call   800fa7 <fd_lookup>
  8013b0:	83 c4 08             	add    $0x8,%esp
  8013b3:	89 c2                	mov    %eax,%edx
  8013b5:	85 c0                	test   %eax,%eax
  8013b7:	78 65                	js     80141e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b9:	83 ec 08             	sub    $0x8,%esp
  8013bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bf:	50                   	push   %eax
  8013c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c3:	ff 30                	pushl  (%eax)
  8013c5:	e8 33 fc ff ff       	call   800ffd <dev_lookup>
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	78 44                	js     801415 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013d8:	75 21                	jne    8013fb <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013da:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013df:	8b 40 48             	mov    0x48(%eax),%eax
  8013e2:	83 ec 04             	sub    $0x4,%esp
  8013e5:	53                   	push   %ebx
  8013e6:	50                   	push   %eax
  8013e7:	68 6c 24 80 00       	push   $0x80246c
  8013ec:	e8 12 ee ff ff       	call   800203 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013f9:	eb 23                	jmp    80141e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013fe:	8b 52 18             	mov    0x18(%edx),%edx
  801401:	85 d2                	test   %edx,%edx
  801403:	74 14                	je     801419 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801405:	83 ec 08             	sub    $0x8,%esp
  801408:	ff 75 0c             	pushl  0xc(%ebp)
  80140b:	50                   	push   %eax
  80140c:	ff d2                	call   *%edx
  80140e:	89 c2                	mov    %eax,%edx
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	eb 09                	jmp    80141e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801415:	89 c2                	mov    %eax,%edx
  801417:	eb 05                	jmp    80141e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801419:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80141e:	89 d0                	mov    %edx,%eax
  801420:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801423:	c9                   	leave  
  801424:	c3                   	ret    

00801425 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	53                   	push   %ebx
  801429:	83 ec 14             	sub    $0x14,%esp
  80142c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80142f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801432:	50                   	push   %eax
  801433:	ff 75 08             	pushl  0x8(%ebp)
  801436:	e8 6c fb ff ff       	call   800fa7 <fd_lookup>
  80143b:	83 c4 08             	add    $0x8,%esp
  80143e:	89 c2                	mov    %eax,%edx
  801440:	85 c0                	test   %eax,%eax
  801442:	78 58                	js     80149c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144a:	50                   	push   %eax
  80144b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144e:	ff 30                	pushl  (%eax)
  801450:	e8 a8 fb ff ff       	call   800ffd <dev_lookup>
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	85 c0                	test   %eax,%eax
  80145a:	78 37                	js     801493 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80145c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801463:	74 32                	je     801497 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801465:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801468:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80146f:	00 00 00 
	stat->st_isdir = 0;
  801472:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801479:	00 00 00 
	stat->st_dev = dev;
  80147c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801482:	83 ec 08             	sub    $0x8,%esp
  801485:	53                   	push   %ebx
  801486:	ff 75 f0             	pushl  -0x10(%ebp)
  801489:	ff 50 14             	call   *0x14(%eax)
  80148c:	89 c2                	mov    %eax,%edx
  80148e:	83 c4 10             	add    $0x10,%esp
  801491:	eb 09                	jmp    80149c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801493:	89 c2                	mov    %eax,%edx
  801495:	eb 05                	jmp    80149c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801497:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80149c:	89 d0                	mov    %edx,%eax
  80149e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a1:	c9                   	leave  
  8014a2:	c3                   	ret    

008014a3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	56                   	push   %esi
  8014a7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	6a 00                	push   $0x0
  8014ad:	ff 75 08             	pushl  0x8(%ebp)
  8014b0:	e8 2b 02 00 00       	call   8016e0 <open>
  8014b5:	89 c3                	mov    %eax,%ebx
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 1b                	js     8014d9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014be:	83 ec 08             	sub    $0x8,%esp
  8014c1:	ff 75 0c             	pushl  0xc(%ebp)
  8014c4:	50                   	push   %eax
  8014c5:	e8 5b ff ff ff       	call   801425 <fstat>
  8014ca:	89 c6                	mov    %eax,%esi
	close(fd);
  8014cc:	89 1c 24             	mov    %ebx,(%esp)
  8014cf:	e8 fd fb ff ff       	call   8010d1 <close>
	return r;
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	89 f0                	mov    %esi,%eax
}
  8014d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014dc:	5b                   	pop    %ebx
  8014dd:	5e                   	pop    %esi
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    

008014e0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	56                   	push   %esi
  8014e4:	53                   	push   %ebx
  8014e5:	89 c6                	mov    %eax,%esi
  8014e7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014e9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8014f0:	75 12                	jne    801504 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014f2:	83 ec 0c             	sub    $0xc,%esp
  8014f5:	6a 01                	push   $0x1
  8014f7:	e8 26 08 00 00       	call   801d22 <ipc_find_env>
  8014fc:	a3 04 40 80 00       	mov    %eax,0x804004
  801501:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801504:	6a 07                	push   $0x7
  801506:	68 00 50 80 00       	push   $0x805000
  80150b:	56                   	push   %esi
  80150c:	ff 35 04 40 80 00    	pushl  0x804004
  801512:	e8 b5 07 00 00       	call   801ccc <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801517:	83 c4 0c             	add    $0xc,%esp
  80151a:	6a 00                	push   $0x0
  80151c:	53                   	push   %ebx
  80151d:	6a 00                	push   $0x0
  80151f:	e8 3f 07 00 00       	call   801c63 <ipc_recv>
}
  801524:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801527:	5b                   	pop    %ebx
  801528:	5e                   	pop    %esi
  801529:	5d                   	pop    %ebp
  80152a:	c3                   	ret    

0080152b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801531:	8b 45 08             	mov    0x8(%ebp),%eax
  801534:	8b 40 0c             	mov    0xc(%eax),%eax
  801537:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80153c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801544:	ba 00 00 00 00       	mov    $0x0,%edx
  801549:	b8 02 00 00 00       	mov    $0x2,%eax
  80154e:	e8 8d ff ff ff       	call   8014e0 <fsipc>
}
  801553:	c9                   	leave  
  801554:	c3                   	ret    

00801555 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801555:	55                   	push   %ebp
  801556:	89 e5                	mov    %esp,%ebp
  801558:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80155b:	8b 45 08             	mov    0x8(%ebp),%eax
  80155e:	8b 40 0c             	mov    0xc(%eax),%eax
  801561:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801566:	ba 00 00 00 00       	mov    $0x0,%edx
  80156b:	b8 06 00 00 00       	mov    $0x6,%eax
  801570:	e8 6b ff ff ff       	call   8014e0 <fsipc>
}
  801575:	c9                   	leave  
  801576:	c3                   	ret    

00801577 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	53                   	push   %ebx
  80157b:	83 ec 04             	sub    $0x4,%esp
  80157e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801581:	8b 45 08             	mov    0x8(%ebp),%eax
  801584:	8b 40 0c             	mov    0xc(%eax),%eax
  801587:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80158c:	ba 00 00 00 00       	mov    $0x0,%edx
  801591:	b8 05 00 00 00       	mov    $0x5,%eax
  801596:	e8 45 ff ff ff       	call   8014e0 <fsipc>
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 2c                	js     8015cb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80159f:	83 ec 08             	sub    $0x8,%esp
  8015a2:	68 00 50 80 00       	push   $0x805000
  8015a7:	53                   	push   %ebx
  8015a8:	e8 8a f2 ff ff       	call   800837 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015ad:	a1 80 50 80 00       	mov    0x805080,%eax
  8015b2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015b8:	a1 84 50 80 00       	mov    0x805084,%eax
  8015bd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ce:	c9                   	leave  
  8015cf:	c3                   	ret    

008015d0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	53                   	push   %ebx
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8015da:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015df:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8015e4:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ed:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  8015f2:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015f8:	53                   	push   %ebx
  8015f9:	ff 75 0c             	pushl  0xc(%ebp)
  8015fc:	68 08 50 80 00       	push   $0x805008
  801601:	e8 c3 f3 ff ff       	call   8009c9 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801606:	ba 00 00 00 00       	mov    $0x0,%edx
  80160b:	b8 04 00 00 00       	mov    $0x4,%eax
  801610:	e8 cb fe ff ff       	call   8014e0 <fsipc>
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	85 c0                	test   %eax,%eax
  80161a:	78 3d                	js     801659 <devfile_write+0x89>
		return r;

	assert(r <= n);
  80161c:	39 d8                	cmp    %ebx,%eax
  80161e:	76 19                	jbe    801639 <devfile_write+0x69>
  801620:	68 d8 24 80 00       	push   $0x8024d8
  801625:	68 df 24 80 00       	push   $0x8024df
  80162a:	68 9f 00 00 00       	push   $0x9f
  80162f:	68 f4 24 80 00       	push   $0x8024f4
  801634:	e8 f1 ea ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801639:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80163e:	76 19                	jbe    801659 <devfile_write+0x89>
  801640:	68 0c 25 80 00       	push   $0x80250c
  801645:	68 df 24 80 00       	push   $0x8024df
  80164a:	68 a0 00 00 00       	push   $0xa0
  80164f:	68 f4 24 80 00       	push   $0x8024f4
  801654:	e8 d1 ea ff ff       	call   80012a <_panic>

	return r;
}
  801659:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165c:	c9                   	leave  
  80165d:	c3                   	ret    

0080165e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	56                   	push   %esi
  801662:	53                   	push   %ebx
  801663:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801666:	8b 45 08             	mov    0x8(%ebp),%eax
  801669:	8b 40 0c             	mov    0xc(%eax),%eax
  80166c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801671:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801677:	ba 00 00 00 00       	mov    $0x0,%edx
  80167c:	b8 03 00 00 00       	mov    $0x3,%eax
  801681:	e8 5a fe ff ff       	call   8014e0 <fsipc>
  801686:	89 c3                	mov    %eax,%ebx
  801688:	85 c0                	test   %eax,%eax
  80168a:	78 4b                	js     8016d7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80168c:	39 c6                	cmp    %eax,%esi
  80168e:	73 16                	jae    8016a6 <devfile_read+0x48>
  801690:	68 d8 24 80 00       	push   $0x8024d8
  801695:	68 df 24 80 00       	push   $0x8024df
  80169a:	6a 7e                	push   $0x7e
  80169c:	68 f4 24 80 00       	push   $0x8024f4
  8016a1:	e8 84 ea ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE);
  8016a6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016ab:	7e 16                	jle    8016c3 <devfile_read+0x65>
  8016ad:	68 ff 24 80 00       	push   $0x8024ff
  8016b2:	68 df 24 80 00       	push   $0x8024df
  8016b7:	6a 7f                	push   $0x7f
  8016b9:	68 f4 24 80 00       	push   $0x8024f4
  8016be:	e8 67 ea ff ff       	call   80012a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016c3:	83 ec 04             	sub    $0x4,%esp
  8016c6:	50                   	push   %eax
  8016c7:	68 00 50 80 00       	push   $0x805000
  8016cc:	ff 75 0c             	pushl  0xc(%ebp)
  8016cf:	e8 f5 f2 ff ff       	call   8009c9 <memmove>
	return r;
  8016d4:	83 c4 10             	add    $0x10,%esp
}
  8016d7:	89 d8                	mov    %ebx,%eax
  8016d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016dc:	5b                   	pop    %ebx
  8016dd:	5e                   	pop    %esi
  8016de:	5d                   	pop    %ebp
  8016df:	c3                   	ret    

008016e0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	53                   	push   %ebx
  8016e4:	83 ec 20             	sub    $0x20,%esp
  8016e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016ea:	53                   	push   %ebx
  8016eb:	e8 0e f1 ff ff       	call   8007fe <strlen>
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016f8:	7f 67                	jg     801761 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016fa:	83 ec 0c             	sub    $0xc,%esp
  8016fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801700:	50                   	push   %eax
  801701:	e8 52 f8 ff ff       	call   800f58 <fd_alloc>
  801706:	83 c4 10             	add    $0x10,%esp
		return r;
  801709:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80170b:	85 c0                	test   %eax,%eax
  80170d:	78 57                	js     801766 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80170f:	83 ec 08             	sub    $0x8,%esp
  801712:	53                   	push   %ebx
  801713:	68 00 50 80 00       	push   $0x805000
  801718:	e8 1a f1 ff ff       	call   800837 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80171d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801720:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801725:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801728:	b8 01 00 00 00       	mov    $0x1,%eax
  80172d:	e8 ae fd ff ff       	call   8014e0 <fsipc>
  801732:	89 c3                	mov    %eax,%ebx
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	85 c0                	test   %eax,%eax
  801739:	79 14                	jns    80174f <open+0x6f>
		fd_close(fd, 0);
  80173b:	83 ec 08             	sub    $0x8,%esp
  80173e:	6a 00                	push   $0x0
  801740:	ff 75 f4             	pushl  -0xc(%ebp)
  801743:	e8 08 f9 ff ff       	call   801050 <fd_close>
		return r;
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	89 da                	mov    %ebx,%edx
  80174d:	eb 17                	jmp    801766 <open+0x86>
	}

	return fd2num(fd);
  80174f:	83 ec 0c             	sub    $0xc,%esp
  801752:	ff 75 f4             	pushl  -0xc(%ebp)
  801755:	e8 d7 f7 ff ff       	call   800f31 <fd2num>
  80175a:	89 c2                	mov    %eax,%edx
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	eb 05                	jmp    801766 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801761:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801766:	89 d0                	mov    %edx,%eax
  801768:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176b:	c9                   	leave  
  80176c:	c3                   	ret    

0080176d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801773:	ba 00 00 00 00       	mov    $0x0,%edx
  801778:	b8 08 00 00 00       	mov    $0x8,%eax
  80177d:	e8 5e fd ff ff       	call   8014e0 <fsipc>
}
  801782:	c9                   	leave  
  801783:	c3                   	ret    

00801784 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	56                   	push   %esi
  801788:	53                   	push   %ebx
  801789:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80178c:	83 ec 0c             	sub    $0xc,%esp
  80178f:	ff 75 08             	pushl  0x8(%ebp)
  801792:	e8 aa f7 ff ff       	call   800f41 <fd2data>
  801797:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801799:	83 c4 08             	add    $0x8,%esp
  80179c:	68 39 25 80 00       	push   $0x802539
  8017a1:	53                   	push   %ebx
  8017a2:	e8 90 f0 ff ff       	call   800837 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017a7:	8b 46 04             	mov    0x4(%esi),%eax
  8017aa:	2b 06                	sub    (%esi),%eax
  8017ac:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017b2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b9:	00 00 00 
	stat->st_dev = &devpipe;
  8017bc:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8017c3:	30 80 00 
	return 0;
}
  8017c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8017cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ce:	5b                   	pop    %ebx
  8017cf:	5e                   	pop    %esi
  8017d0:	5d                   	pop    %ebp
  8017d1:	c3                   	ret    

008017d2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	53                   	push   %ebx
  8017d6:	83 ec 0c             	sub    $0xc,%esp
  8017d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017dc:	53                   	push   %ebx
  8017dd:	6a 00                	push   $0x0
  8017df:	e8 52 f5 ff ff       	call   800d36 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017e4:	89 1c 24             	mov    %ebx,(%esp)
  8017e7:	e8 55 f7 ff ff       	call   800f41 <fd2data>
  8017ec:	83 c4 08             	add    $0x8,%esp
  8017ef:	50                   	push   %eax
  8017f0:	6a 00                	push   $0x0
  8017f2:	e8 3f f5 ff ff       	call   800d36 <sys_page_unmap>
}
  8017f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017fa:	c9                   	leave  
  8017fb:	c3                   	ret    

008017fc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	57                   	push   %edi
  801800:	56                   	push   %esi
  801801:	53                   	push   %ebx
  801802:	83 ec 1c             	sub    $0x1c,%esp
  801805:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801808:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80180a:	a1 08 40 80 00       	mov    0x804008,%eax
  80180f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801812:	83 ec 0c             	sub    $0xc,%esp
  801815:	ff 75 e0             	pushl  -0x20(%ebp)
  801818:	e8 3e 05 00 00       	call   801d5b <pageref>
  80181d:	89 c3                	mov    %eax,%ebx
  80181f:	89 3c 24             	mov    %edi,(%esp)
  801822:	e8 34 05 00 00       	call   801d5b <pageref>
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	39 c3                	cmp    %eax,%ebx
  80182c:	0f 94 c1             	sete   %cl
  80182f:	0f b6 c9             	movzbl %cl,%ecx
  801832:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801835:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80183b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80183e:	39 ce                	cmp    %ecx,%esi
  801840:	74 1b                	je     80185d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801842:	39 c3                	cmp    %eax,%ebx
  801844:	75 c4                	jne    80180a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801846:	8b 42 58             	mov    0x58(%edx),%eax
  801849:	ff 75 e4             	pushl  -0x1c(%ebp)
  80184c:	50                   	push   %eax
  80184d:	56                   	push   %esi
  80184e:	68 40 25 80 00       	push   $0x802540
  801853:	e8 ab e9 ff ff       	call   800203 <cprintf>
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	eb ad                	jmp    80180a <_pipeisclosed+0xe>
	}
}
  80185d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801860:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801863:	5b                   	pop    %ebx
  801864:	5e                   	pop    %esi
  801865:	5f                   	pop    %edi
  801866:	5d                   	pop    %ebp
  801867:	c3                   	ret    

00801868 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	57                   	push   %edi
  80186c:	56                   	push   %esi
  80186d:	53                   	push   %ebx
  80186e:	83 ec 28             	sub    $0x28,%esp
  801871:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801874:	56                   	push   %esi
  801875:	e8 c7 f6 ff ff       	call   800f41 <fd2data>
  80187a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	bf 00 00 00 00       	mov    $0x0,%edi
  801884:	eb 4b                	jmp    8018d1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801886:	89 da                	mov    %ebx,%edx
  801888:	89 f0                	mov    %esi,%eax
  80188a:	e8 6d ff ff ff       	call   8017fc <_pipeisclosed>
  80188f:	85 c0                	test   %eax,%eax
  801891:	75 48                	jne    8018db <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801893:	e8 fa f3 ff ff       	call   800c92 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801898:	8b 43 04             	mov    0x4(%ebx),%eax
  80189b:	8b 0b                	mov    (%ebx),%ecx
  80189d:	8d 51 20             	lea    0x20(%ecx),%edx
  8018a0:	39 d0                	cmp    %edx,%eax
  8018a2:	73 e2                	jae    801886 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018a7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018ab:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018ae:	89 c2                	mov    %eax,%edx
  8018b0:	c1 fa 1f             	sar    $0x1f,%edx
  8018b3:	89 d1                	mov    %edx,%ecx
  8018b5:	c1 e9 1b             	shr    $0x1b,%ecx
  8018b8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8018bb:	83 e2 1f             	and    $0x1f,%edx
  8018be:	29 ca                	sub    %ecx,%edx
  8018c0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8018c4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018c8:	83 c0 01             	add    $0x1,%eax
  8018cb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018ce:	83 c7 01             	add    $0x1,%edi
  8018d1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018d4:	75 c2                	jne    801898 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8018d9:	eb 05                	jmp    8018e0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018db:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e3:	5b                   	pop    %ebx
  8018e4:	5e                   	pop    %esi
  8018e5:	5f                   	pop    %edi
  8018e6:	5d                   	pop    %ebp
  8018e7:	c3                   	ret    

008018e8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	57                   	push   %edi
  8018ec:	56                   	push   %esi
  8018ed:	53                   	push   %ebx
  8018ee:	83 ec 18             	sub    $0x18,%esp
  8018f1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018f4:	57                   	push   %edi
  8018f5:	e8 47 f6 ff ff       	call   800f41 <fd2data>
  8018fa:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801904:	eb 3d                	jmp    801943 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801906:	85 db                	test   %ebx,%ebx
  801908:	74 04                	je     80190e <devpipe_read+0x26>
				return i;
  80190a:	89 d8                	mov    %ebx,%eax
  80190c:	eb 44                	jmp    801952 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80190e:	89 f2                	mov    %esi,%edx
  801910:	89 f8                	mov    %edi,%eax
  801912:	e8 e5 fe ff ff       	call   8017fc <_pipeisclosed>
  801917:	85 c0                	test   %eax,%eax
  801919:	75 32                	jne    80194d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80191b:	e8 72 f3 ff ff       	call   800c92 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801920:	8b 06                	mov    (%esi),%eax
  801922:	3b 46 04             	cmp    0x4(%esi),%eax
  801925:	74 df                	je     801906 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801927:	99                   	cltd   
  801928:	c1 ea 1b             	shr    $0x1b,%edx
  80192b:	01 d0                	add    %edx,%eax
  80192d:	83 e0 1f             	and    $0x1f,%eax
  801930:	29 d0                	sub    %edx,%eax
  801932:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801937:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80193a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80193d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801940:	83 c3 01             	add    $0x1,%ebx
  801943:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801946:	75 d8                	jne    801920 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801948:	8b 45 10             	mov    0x10(%ebp),%eax
  80194b:	eb 05                	jmp    801952 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80194d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801952:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801955:	5b                   	pop    %ebx
  801956:	5e                   	pop    %esi
  801957:	5f                   	pop    %edi
  801958:	5d                   	pop    %ebp
  801959:	c3                   	ret    

0080195a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	56                   	push   %esi
  80195e:	53                   	push   %ebx
  80195f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801962:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801965:	50                   	push   %eax
  801966:	e8 ed f5 ff ff       	call   800f58 <fd_alloc>
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	89 c2                	mov    %eax,%edx
  801970:	85 c0                	test   %eax,%eax
  801972:	0f 88 2c 01 00 00    	js     801aa4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801978:	83 ec 04             	sub    $0x4,%esp
  80197b:	68 07 04 00 00       	push   $0x407
  801980:	ff 75 f4             	pushl  -0xc(%ebp)
  801983:	6a 00                	push   $0x0
  801985:	e8 27 f3 ff ff       	call   800cb1 <sys_page_alloc>
  80198a:	83 c4 10             	add    $0x10,%esp
  80198d:	89 c2                	mov    %eax,%edx
  80198f:	85 c0                	test   %eax,%eax
  801991:	0f 88 0d 01 00 00    	js     801aa4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801997:	83 ec 0c             	sub    $0xc,%esp
  80199a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80199d:	50                   	push   %eax
  80199e:	e8 b5 f5 ff ff       	call   800f58 <fd_alloc>
  8019a3:	89 c3                	mov    %eax,%ebx
  8019a5:	83 c4 10             	add    $0x10,%esp
  8019a8:	85 c0                	test   %eax,%eax
  8019aa:	0f 88 e2 00 00 00    	js     801a92 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019b0:	83 ec 04             	sub    $0x4,%esp
  8019b3:	68 07 04 00 00       	push   $0x407
  8019b8:	ff 75 f0             	pushl  -0x10(%ebp)
  8019bb:	6a 00                	push   $0x0
  8019bd:	e8 ef f2 ff ff       	call   800cb1 <sys_page_alloc>
  8019c2:	89 c3                	mov    %eax,%ebx
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	85 c0                	test   %eax,%eax
  8019c9:	0f 88 c3 00 00 00    	js     801a92 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019cf:	83 ec 0c             	sub    $0xc,%esp
  8019d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d5:	e8 67 f5 ff ff       	call   800f41 <fd2data>
  8019da:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019dc:	83 c4 0c             	add    $0xc,%esp
  8019df:	68 07 04 00 00       	push   $0x407
  8019e4:	50                   	push   %eax
  8019e5:	6a 00                	push   $0x0
  8019e7:	e8 c5 f2 ff ff       	call   800cb1 <sys_page_alloc>
  8019ec:	89 c3                	mov    %eax,%ebx
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	0f 88 89 00 00 00    	js     801a82 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f9:	83 ec 0c             	sub    $0xc,%esp
  8019fc:	ff 75 f0             	pushl  -0x10(%ebp)
  8019ff:	e8 3d f5 ff ff       	call   800f41 <fd2data>
  801a04:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a0b:	50                   	push   %eax
  801a0c:	6a 00                	push   $0x0
  801a0e:	56                   	push   %esi
  801a0f:	6a 00                	push   $0x0
  801a11:	e8 de f2 ff ff       	call   800cf4 <sys_page_map>
  801a16:	89 c3                	mov    %eax,%ebx
  801a18:	83 c4 20             	add    $0x20,%esp
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	78 55                	js     801a74 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a1f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a28:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a34:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a3d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a42:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a49:	83 ec 0c             	sub    $0xc,%esp
  801a4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a4f:	e8 dd f4 ff ff       	call   800f31 <fd2num>
  801a54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a57:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a59:	83 c4 04             	add    $0x4,%esp
  801a5c:	ff 75 f0             	pushl  -0x10(%ebp)
  801a5f:	e8 cd f4 ff ff       	call   800f31 <fd2num>
  801a64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a67:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a6a:	83 c4 10             	add    $0x10,%esp
  801a6d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a72:	eb 30                	jmp    801aa4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a74:	83 ec 08             	sub    $0x8,%esp
  801a77:	56                   	push   %esi
  801a78:	6a 00                	push   $0x0
  801a7a:	e8 b7 f2 ff ff       	call   800d36 <sys_page_unmap>
  801a7f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a82:	83 ec 08             	sub    $0x8,%esp
  801a85:	ff 75 f0             	pushl  -0x10(%ebp)
  801a88:	6a 00                	push   $0x0
  801a8a:	e8 a7 f2 ff ff       	call   800d36 <sys_page_unmap>
  801a8f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a92:	83 ec 08             	sub    $0x8,%esp
  801a95:	ff 75 f4             	pushl  -0xc(%ebp)
  801a98:	6a 00                	push   $0x0
  801a9a:	e8 97 f2 ff ff       	call   800d36 <sys_page_unmap>
  801a9f:	83 c4 10             	add    $0x10,%esp
  801aa2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801aa4:	89 d0                	mov    %edx,%eax
  801aa6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa9:	5b                   	pop    %ebx
  801aaa:	5e                   	pop    %esi
  801aab:	5d                   	pop    %ebp
  801aac:	c3                   	ret    

00801aad <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ab3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab6:	50                   	push   %eax
  801ab7:	ff 75 08             	pushl  0x8(%ebp)
  801aba:	e8 e8 f4 ff ff       	call   800fa7 <fd_lookup>
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	78 18                	js     801ade <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ac6:	83 ec 0c             	sub    $0xc,%esp
  801ac9:	ff 75 f4             	pushl  -0xc(%ebp)
  801acc:	e8 70 f4 ff ff       	call   800f41 <fd2data>
	return _pipeisclosed(fd, p);
  801ad1:	89 c2                	mov    %eax,%edx
  801ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad6:	e8 21 fd ff ff       	call   8017fc <_pipeisclosed>
  801adb:	83 c4 10             	add    $0x10,%esp
}
  801ade:	c9                   	leave  
  801adf:	c3                   	ret    

00801ae0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801af0:	68 58 25 80 00       	push   $0x802558
  801af5:	ff 75 0c             	pushl  0xc(%ebp)
  801af8:	e8 3a ed ff ff       	call   800837 <strcpy>
	return 0;
}
  801afd:	b8 00 00 00 00       	mov    $0x0,%eax
  801b02:	c9                   	leave  
  801b03:	c3                   	ret    

00801b04 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	57                   	push   %edi
  801b08:	56                   	push   %esi
  801b09:	53                   	push   %ebx
  801b0a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b10:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b15:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b1b:	eb 2d                	jmp    801b4a <devcons_write+0x46>
		m = n - tot;
  801b1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b20:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b22:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b25:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b2a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b2d:	83 ec 04             	sub    $0x4,%esp
  801b30:	53                   	push   %ebx
  801b31:	03 45 0c             	add    0xc(%ebp),%eax
  801b34:	50                   	push   %eax
  801b35:	57                   	push   %edi
  801b36:	e8 8e ee ff ff       	call   8009c9 <memmove>
		sys_cputs(buf, m);
  801b3b:	83 c4 08             	add    $0x8,%esp
  801b3e:	53                   	push   %ebx
  801b3f:	57                   	push   %edi
  801b40:	e8 b0 f0 ff ff       	call   800bf5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b45:	01 de                	add    %ebx,%esi
  801b47:	83 c4 10             	add    $0x10,%esp
  801b4a:	89 f0                	mov    %esi,%eax
  801b4c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b4f:	72 cc                	jb     801b1d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b54:	5b                   	pop    %ebx
  801b55:	5e                   	pop    %esi
  801b56:	5f                   	pop    %edi
  801b57:	5d                   	pop    %ebp
  801b58:	c3                   	ret    

00801b59 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	83 ec 08             	sub    $0x8,%esp
  801b5f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801b64:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b68:	74 2a                	je     801b94 <devcons_read+0x3b>
  801b6a:	eb 05                	jmp    801b71 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b6c:	e8 21 f1 ff ff       	call   800c92 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b71:	e8 9d f0 ff ff       	call   800c13 <sys_cgetc>
  801b76:	85 c0                	test   %eax,%eax
  801b78:	74 f2                	je     801b6c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	78 16                	js     801b94 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b7e:	83 f8 04             	cmp    $0x4,%eax
  801b81:	74 0c                	je     801b8f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b83:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b86:	88 02                	mov    %al,(%edx)
	return 1;
  801b88:	b8 01 00 00 00       	mov    $0x1,%eax
  801b8d:	eb 05                	jmp    801b94 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b8f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ba2:	6a 01                	push   $0x1
  801ba4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ba7:	50                   	push   %eax
  801ba8:	e8 48 f0 ff ff       	call   800bf5 <sys_cputs>
}
  801bad:	83 c4 10             	add    $0x10,%esp
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    

00801bb2 <getchar>:

int
getchar(void)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801bb8:	6a 01                	push   $0x1
  801bba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bbd:	50                   	push   %eax
  801bbe:	6a 00                	push   $0x0
  801bc0:	e8 48 f6 ff ff       	call   80120d <read>
	if (r < 0)
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	78 0f                	js     801bdb <getchar+0x29>
		return r;
	if (r < 1)
  801bcc:	85 c0                	test   %eax,%eax
  801bce:	7e 06                	jle    801bd6 <getchar+0x24>
		return -E_EOF;
	return c;
  801bd0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801bd4:	eb 05                	jmp    801bdb <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801bd6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801bdb:	c9                   	leave  
  801bdc:	c3                   	ret    

00801bdd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801be3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be6:	50                   	push   %eax
  801be7:	ff 75 08             	pushl  0x8(%ebp)
  801bea:	e8 b8 f3 ff ff       	call   800fa7 <fd_lookup>
  801bef:	83 c4 10             	add    $0x10,%esp
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	78 11                	js     801c07 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bff:	39 10                	cmp    %edx,(%eax)
  801c01:	0f 94 c0             	sete   %al
  801c04:	0f b6 c0             	movzbl %al,%eax
}
  801c07:	c9                   	leave  
  801c08:	c3                   	ret    

00801c09 <opencons>:

int
opencons(void)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c12:	50                   	push   %eax
  801c13:	e8 40 f3 ff ff       	call   800f58 <fd_alloc>
  801c18:	83 c4 10             	add    $0x10,%esp
		return r;
  801c1b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	78 3e                	js     801c5f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c21:	83 ec 04             	sub    $0x4,%esp
  801c24:	68 07 04 00 00       	push   $0x407
  801c29:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2c:	6a 00                	push   $0x0
  801c2e:	e8 7e f0 ff ff       	call   800cb1 <sys_page_alloc>
  801c33:	83 c4 10             	add    $0x10,%esp
		return r;
  801c36:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	78 23                	js     801c5f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c3c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c45:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c51:	83 ec 0c             	sub    $0xc,%esp
  801c54:	50                   	push   %eax
  801c55:	e8 d7 f2 ff ff       	call   800f31 <fd2num>
  801c5a:	89 c2                	mov    %eax,%edx
  801c5c:	83 c4 10             	add    $0x10,%esp
}
  801c5f:	89 d0                	mov    %edx,%eax
  801c61:	c9                   	leave  
  801c62:	c3                   	ret    

00801c63 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	8b 75 08             	mov    0x8(%ebp),%esi
  801c6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801c71:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801c73:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801c78:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801c7b:	83 ec 0c             	sub    $0xc,%esp
  801c7e:	50                   	push   %eax
  801c7f:	e8 dd f1 ff ff       	call   800e61 <sys_ipc_recv>
  801c84:	83 c4 10             	add    $0x10,%esp
  801c87:	85 c0                	test   %eax,%eax
  801c89:	79 16                	jns    801ca1 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801c8b:	85 f6                	test   %esi,%esi
  801c8d:	74 06                	je     801c95 <ipc_recv+0x32>
			*from_env_store = 0;
  801c8f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801c95:	85 db                	test   %ebx,%ebx
  801c97:	74 2c                	je     801cc5 <ipc_recv+0x62>
			*perm_store = 0;
  801c99:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c9f:	eb 24                	jmp    801cc5 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801ca1:	85 f6                	test   %esi,%esi
  801ca3:	74 0a                	je     801caf <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801ca5:	a1 08 40 80 00       	mov    0x804008,%eax
  801caa:	8b 40 74             	mov    0x74(%eax),%eax
  801cad:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801caf:	85 db                	test   %ebx,%ebx
  801cb1:	74 0a                	je     801cbd <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801cb3:	a1 08 40 80 00       	mov    0x804008,%eax
  801cb8:	8b 40 78             	mov    0x78(%eax),%eax
  801cbb:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801cbd:	a1 08 40 80 00       	mov    0x804008,%eax
  801cc2:	8b 40 70             	mov    0x70(%eax),%eax
}
  801cc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cc8:	5b                   	pop    %ebx
  801cc9:	5e                   	pop    %esi
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    

00801ccc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	57                   	push   %edi
  801cd0:	56                   	push   %esi
  801cd1:	53                   	push   %ebx
  801cd2:	83 ec 0c             	sub    $0xc,%esp
  801cd5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cd8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801cde:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801ce0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ce5:	0f 44 d8             	cmove  %eax,%ebx
  801ce8:	eb 1e                	jmp    801d08 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801cea:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ced:	74 14                	je     801d03 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801cef:	83 ec 04             	sub    $0x4,%esp
  801cf2:	68 64 25 80 00       	push   $0x802564
  801cf7:	6a 44                	push   $0x44
  801cf9:	68 90 25 80 00       	push   $0x802590
  801cfe:	e8 27 e4 ff ff       	call   80012a <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801d03:	e8 8a ef ff ff       	call   800c92 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801d08:	ff 75 14             	pushl  0x14(%ebp)
  801d0b:	53                   	push   %ebx
  801d0c:	56                   	push   %esi
  801d0d:	57                   	push   %edi
  801d0e:	e8 2b f1 ff ff       	call   800e3e <sys_ipc_try_send>
  801d13:	83 c4 10             	add    $0x10,%esp
  801d16:	85 c0                	test   %eax,%eax
  801d18:	78 d0                	js     801cea <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d1d:	5b                   	pop    %ebx
  801d1e:	5e                   	pop    %esi
  801d1f:	5f                   	pop    %edi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    

00801d22 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d28:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d2d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d30:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d36:	8b 52 50             	mov    0x50(%edx),%edx
  801d39:	39 ca                	cmp    %ecx,%edx
  801d3b:	75 0d                	jne    801d4a <ipc_find_env+0x28>
			return envs[i].env_id;
  801d3d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d40:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d45:	8b 40 48             	mov    0x48(%eax),%eax
  801d48:	eb 0f                	jmp    801d59 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d4a:	83 c0 01             	add    $0x1,%eax
  801d4d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d52:	75 d9                	jne    801d2d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d59:	5d                   	pop    %ebp
  801d5a:	c3                   	ret    

00801d5b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d61:	89 d0                	mov    %edx,%eax
  801d63:	c1 e8 16             	shr    $0x16,%eax
  801d66:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d6d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d72:	f6 c1 01             	test   $0x1,%cl
  801d75:	74 1d                	je     801d94 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d77:	c1 ea 0c             	shr    $0xc,%edx
  801d7a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d81:	f6 c2 01             	test   $0x1,%dl
  801d84:	74 0e                	je     801d94 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d86:	c1 ea 0c             	shr    $0xc,%edx
  801d89:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d90:	ef 
  801d91:	0f b7 c0             	movzwl %ax,%eax
}
  801d94:	5d                   	pop    %ebp
  801d95:	c3                   	ret    
  801d96:	66 90                	xchg   %ax,%ax
  801d98:	66 90                	xchg   %ax,%ax
  801d9a:	66 90                	xchg   %ax,%ax
  801d9c:	66 90                	xchg   %ax,%ax
  801d9e:	66 90                	xchg   %ax,%ax

00801da0 <__udivdi3>:
  801da0:	55                   	push   %ebp
  801da1:	57                   	push   %edi
  801da2:	56                   	push   %esi
  801da3:	53                   	push   %ebx
  801da4:	83 ec 1c             	sub    $0x1c,%esp
  801da7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801dab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801daf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801db3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801db7:	85 f6                	test   %esi,%esi
  801db9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dbd:	89 ca                	mov    %ecx,%edx
  801dbf:	89 f8                	mov    %edi,%eax
  801dc1:	75 3d                	jne    801e00 <__udivdi3+0x60>
  801dc3:	39 cf                	cmp    %ecx,%edi
  801dc5:	0f 87 c5 00 00 00    	ja     801e90 <__udivdi3+0xf0>
  801dcb:	85 ff                	test   %edi,%edi
  801dcd:	89 fd                	mov    %edi,%ebp
  801dcf:	75 0b                	jne    801ddc <__udivdi3+0x3c>
  801dd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd6:	31 d2                	xor    %edx,%edx
  801dd8:	f7 f7                	div    %edi
  801dda:	89 c5                	mov    %eax,%ebp
  801ddc:	89 c8                	mov    %ecx,%eax
  801dde:	31 d2                	xor    %edx,%edx
  801de0:	f7 f5                	div    %ebp
  801de2:	89 c1                	mov    %eax,%ecx
  801de4:	89 d8                	mov    %ebx,%eax
  801de6:	89 cf                	mov    %ecx,%edi
  801de8:	f7 f5                	div    %ebp
  801dea:	89 c3                	mov    %eax,%ebx
  801dec:	89 d8                	mov    %ebx,%eax
  801dee:	89 fa                	mov    %edi,%edx
  801df0:	83 c4 1c             	add    $0x1c,%esp
  801df3:	5b                   	pop    %ebx
  801df4:	5e                   	pop    %esi
  801df5:	5f                   	pop    %edi
  801df6:	5d                   	pop    %ebp
  801df7:	c3                   	ret    
  801df8:	90                   	nop
  801df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e00:	39 ce                	cmp    %ecx,%esi
  801e02:	77 74                	ja     801e78 <__udivdi3+0xd8>
  801e04:	0f bd fe             	bsr    %esi,%edi
  801e07:	83 f7 1f             	xor    $0x1f,%edi
  801e0a:	0f 84 98 00 00 00    	je     801ea8 <__udivdi3+0x108>
  801e10:	bb 20 00 00 00       	mov    $0x20,%ebx
  801e15:	89 f9                	mov    %edi,%ecx
  801e17:	89 c5                	mov    %eax,%ebp
  801e19:	29 fb                	sub    %edi,%ebx
  801e1b:	d3 e6                	shl    %cl,%esi
  801e1d:	89 d9                	mov    %ebx,%ecx
  801e1f:	d3 ed                	shr    %cl,%ebp
  801e21:	89 f9                	mov    %edi,%ecx
  801e23:	d3 e0                	shl    %cl,%eax
  801e25:	09 ee                	or     %ebp,%esi
  801e27:	89 d9                	mov    %ebx,%ecx
  801e29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e2d:	89 d5                	mov    %edx,%ebp
  801e2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e33:	d3 ed                	shr    %cl,%ebp
  801e35:	89 f9                	mov    %edi,%ecx
  801e37:	d3 e2                	shl    %cl,%edx
  801e39:	89 d9                	mov    %ebx,%ecx
  801e3b:	d3 e8                	shr    %cl,%eax
  801e3d:	09 c2                	or     %eax,%edx
  801e3f:	89 d0                	mov    %edx,%eax
  801e41:	89 ea                	mov    %ebp,%edx
  801e43:	f7 f6                	div    %esi
  801e45:	89 d5                	mov    %edx,%ebp
  801e47:	89 c3                	mov    %eax,%ebx
  801e49:	f7 64 24 0c          	mull   0xc(%esp)
  801e4d:	39 d5                	cmp    %edx,%ebp
  801e4f:	72 10                	jb     801e61 <__udivdi3+0xc1>
  801e51:	8b 74 24 08          	mov    0x8(%esp),%esi
  801e55:	89 f9                	mov    %edi,%ecx
  801e57:	d3 e6                	shl    %cl,%esi
  801e59:	39 c6                	cmp    %eax,%esi
  801e5b:	73 07                	jae    801e64 <__udivdi3+0xc4>
  801e5d:	39 d5                	cmp    %edx,%ebp
  801e5f:	75 03                	jne    801e64 <__udivdi3+0xc4>
  801e61:	83 eb 01             	sub    $0x1,%ebx
  801e64:	31 ff                	xor    %edi,%edi
  801e66:	89 d8                	mov    %ebx,%eax
  801e68:	89 fa                	mov    %edi,%edx
  801e6a:	83 c4 1c             	add    $0x1c,%esp
  801e6d:	5b                   	pop    %ebx
  801e6e:	5e                   	pop    %esi
  801e6f:	5f                   	pop    %edi
  801e70:	5d                   	pop    %ebp
  801e71:	c3                   	ret    
  801e72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e78:	31 ff                	xor    %edi,%edi
  801e7a:	31 db                	xor    %ebx,%ebx
  801e7c:	89 d8                	mov    %ebx,%eax
  801e7e:	89 fa                	mov    %edi,%edx
  801e80:	83 c4 1c             	add    $0x1c,%esp
  801e83:	5b                   	pop    %ebx
  801e84:	5e                   	pop    %esi
  801e85:	5f                   	pop    %edi
  801e86:	5d                   	pop    %ebp
  801e87:	c3                   	ret    
  801e88:	90                   	nop
  801e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e90:	89 d8                	mov    %ebx,%eax
  801e92:	f7 f7                	div    %edi
  801e94:	31 ff                	xor    %edi,%edi
  801e96:	89 c3                	mov    %eax,%ebx
  801e98:	89 d8                	mov    %ebx,%eax
  801e9a:	89 fa                	mov    %edi,%edx
  801e9c:	83 c4 1c             	add    $0x1c,%esp
  801e9f:	5b                   	pop    %ebx
  801ea0:	5e                   	pop    %esi
  801ea1:	5f                   	pop    %edi
  801ea2:	5d                   	pop    %ebp
  801ea3:	c3                   	ret    
  801ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ea8:	39 ce                	cmp    %ecx,%esi
  801eaa:	72 0c                	jb     801eb8 <__udivdi3+0x118>
  801eac:	31 db                	xor    %ebx,%ebx
  801eae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801eb2:	0f 87 34 ff ff ff    	ja     801dec <__udivdi3+0x4c>
  801eb8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ebd:	e9 2a ff ff ff       	jmp    801dec <__udivdi3+0x4c>
  801ec2:	66 90                	xchg   %ax,%ax
  801ec4:	66 90                	xchg   %ax,%ax
  801ec6:	66 90                	xchg   %ax,%ax
  801ec8:	66 90                	xchg   %ax,%ax
  801eca:	66 90                	xchg   %ax,%ax
  801ecc:	66 90                	xchg   %ax,%ax
  801ece:	66 90                	xchg   %ax,%ax

00801ed0 <__umoddi3>:
  801ed0:	55                   	push   %ebp
  801ed1:	57                   	push   %edi
  801ed2:	56                   	push   %esi
  801ed3:	53                   	push   %ebx
  801ed4:	83 ec 1c             	sub    $0x1c,%esp
  801ed7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801edb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801edf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ee3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ee7:	85 d2                	test   %edx,%edx
  801ee9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801eed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ef1:	89 f3                	mov    %esi,%ebx
  801ef3:	89 3c 24             	mov    %edi,(%esp)
  801ef6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801efa:	75 1c                	jne    801f18 <__umoddi3+0x48>
  801efc:	39 f7                	cmp    %esi,%edi
  801efe:	76 50                	jbe    801f50 <__umoddi3+0x80>
  801f00:	89 c8                	mov    %ecx,%eax
  801f02:	89 f2                	mov    %esi,%edx
  801f04:	f7 f7                	div    %edi
  801f06:	89 d0                	mov    %edx,%eax
  801f08:	31 d2                	xor    %edx,%edx
  801f0a:	83 c4 1c             	add    $0x1c,%esp
  801f0d:	5b                   	pop    %ebx
  801f0e:	5e                   	pop    %esi
  801f0f:	5f                   	pop    %edi
  801f10:	5d                   	pop    %ebp
  801f11:	c3                   	ret    
  801f12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f18:	39 f2                	cmp    %esi,%edx
  801f1a:	89 d0                	mov    %edx,%eax
  801f1c:	77 52                	ja     801f70 <__umoddi3+0xa0>
  801f1e:	0f bd ea             	bsr    %edx,%ebp
  801f21:	83 f5 1f             	xor    $0x1f,%ebp
  801f24:	75 5a                	jne    801f80 <__umoddi3+0xb0>
  801f26:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801f2a:	0f 82 e0 00 00 00    	jb     802010 <__umoddi3+0x140>
  801f30:	39 0c 24             	cmp    %ecx,(%esp)
  801f33:	0f 86 d7 00 00 00    	jbe    802010 <__umoddi3+0x140>
  801f39:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f3d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f41:	83 c4 1c             	add    $0x1c,%esp
  801f44:	5b                   	pop    %ebx
  801f45:	5e                   	pop    %esi
  801f46:	5f                   	pop    %edi
  801f47:	5d                   	pop    %ebp
  801f48:	c3                   	ret    
  801f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f50:	85 ff                	test   %edi,%edi
  801f52:	89 fd                	mov    %edi,%ebp
  801f54:	75 0b                	jne    801f61 <__umoddi3+0x91>
  801f56:	b8 01 00 00 00       	mov    $0x1,%eax
  801f5b:	31 d2                	xor    %edx,%edx
  801f5d:	f7 f7                	div    %edi
  801f5f:	89 c5                	mov    %eax,%ebp
  801f61:	89 f0                	mov    %esi,%eax
  801f63:	31 d2                	xor    %edx,%edx
  801f65:	f7 f5                	div    %ebp
  801f67:	89 c8                	mov    %ecx,%eax
  801f69:	f7 f5                	div    %ebp
  801f6b:	89 d0                	mov    %edx,%eax
  801f6d:	eb 99                	jmp    801f08 <__umoddi3+0x38>
  801f6f:	90                   	nop
  801f70:	89 c8                	mov    %ecx,%eax
  801f72:	89 f2                	mov    %esi,%edx
  801f74:	83 c4 1c             	add    $0x1c,%esp
  801f77:	5b                   	pop    %ebx
  801f78:	5e                   	pop    %esi
  801f79:	5f                   	pop    %edi
  801f7a:	5d                   	pop    %ebp
  801f7b:	c3                   	ret    
  801f7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f80:	8b 34 24             	mov    (%esp),%esi
  801f83:	bf 20 00 00 00       	mov    $0x20,%edi
  801f88:	89 e9                	mov    %ebp,%ecx
  801f8a:	29 ef                	sub    %ebp,%edi
  801f8c:	d3 e0                	shl    %cl,%eax
  801f8e:	89 f9                	mov    %edi,%ecx
  801f90:	89 f2                	mov    %esi,%edx
  801f92:	d3 ea                	shr    %cl,%edx
  801f94:	89 e9                	mov    %ebp,%ecx
  801f96:	09 c2                	or     %eax,%edx
  801f98:	89 d8                	mov    %ebx,%eax
  801f9a:	89 14 24             	mov    %edx,(%esp)
  801f9d:	89 f2                	mov    %esi,%edx
  801f9f:	d3 e2                	shl    %cl,%edx
  801fa1:	89 f9                	mov    %edi,%ecx
  801fa3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fa7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801fab:	d3 e8                	shr    %cl,%eax
  801fad:	89 e9                	mov    %ebp,%ecx
  801faf:	89 c6                	mov    %eax,%esi
  801fb1:	d3 e3                	shl    %cl,%ebx
  801fb3:	89 f9                	mov    %edi,%ecx
  801fb5:	89 d0                	mov    %edx,%eax
  801fb7:	d3 e8                	shr    %cl,%eax
  801fb9:	89 e9                	mov    %ebp,%ecx
  801fbb:	09 d8                	or     %ebx,%eax
  801fbd:	89 d3                	mov    %edx,%ebx
  801fbf:	89 f2                	mov    %esi,%edx
  801fc1:	f7 34 24             	divl   (%esp)
  801fc4:	89 d6                	mov    %edx,%esi
  801fc6:	d3 e3                	shl    %cl,%ebx
  801fc8:	f7 64 24 04          	mull   0x4(%esp)
  801fcc:	39 d6                	cmp    %edx,%esi
  801fce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fd2:	89 d1                	mov    %edx,%ecx
  801fd4:	89 c3                	mov    %eax,%ebx
  801fd6:	72 08                	jb     801fe0 <__umoddi3+0x110>
  801fd8:	75 11                	jne    801feb <__umoddi3+0x11b>
  801fda:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801fde:	73 0b                	jae    801feb <__umoddi3+0x11b>
  801fe0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801fe4:	1b 14 24             	sbb    (%esp),%edx
  801fe7:	89 d1                	mov    %edx,%ecx
  801fe9:	89 c3                	mov    %eax,%ebx
  801feb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801fef:	29 da                	sub    %ebx,%edx
  801ff1:	19 ce                	sbb    %ecx,%esi
  801ff3:	89 f9                	mov    %edi,%ecx
  801ff5:	89 f0                	mov    %esi,%eax
  801ff7:	d3 e0                	shl    %cl,%eax
  801ff9:	89 e9                	mov    %ebp,%ecx
  801ffb:	d3 ea                	shr    %cl,%edx
  801ffd:	89 e9                	mov    %ebp,%ecx
  801fff:	d3 ee                	shr    %cl,%esi
  802001:	09 d0                	or     %edx,%eax
  802003:	89 f2                	mov    %esi,%edx
  802005:	83 c4 1c             	add    $0x1c,%esp
  802008:	5b                   	pop    %ebx
  802009:	5e                   	pop    %esi
  80200a:	5f                   	pop    %edi
  80200b:	5d                   	pop    %ebp
  80200c:	c3                   	ret    
  80200d:	8d 76 00             	lea    0x0(%esi),%esi
  802010:	29 f9                	sub    %edi,%ecx
  802012:	19 d6                	sbb    %edx,%esi
  802014:	89 74 24 04          	mov    %esi,0x4(%esp)
  802018:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80201c:	e9 18 ff ff ff       	jmp    801f39 <__umoddi3+0x69>
