
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800040:	68 20 20 80 00       	push   $0x802020
  800045:	e8 a4 01 00 00       	call   8001ee <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 3e 0c 00 00       	call   800c9c <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 40 20 80 00       	push   $0x802040
  80006f:	6a 0f                	push   $0xf
  800071:	68 2a 20 80 00       	push   $0x80202a
  800076:	e8 9a 00 00 00       	call   800115 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 6c 20 80 00       	push   $0x80206c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 46 07 00 00       	call   8007cf <snprintf>
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
  80009c:	e8 ec 0d 00 00       	call   800e8d <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 30 0b 00 00       	call   800be0 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 99 0b 00 00       	call   800c5e <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 e1 0f 00 00       	call   8010e7 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 0d 0b 00 00       	call   800c1d <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800123:	e8 36 0b 00 00       	call   800c5e <sys_getenvid>
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	56                   	push   %esi
  800132:	50                   	push   %eax
  800133:	68 98 20 80 00       	push   $0x802098
  800138:	e8 b1 00 00 00       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 54 00 00 00       	call   80019d <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 31 25 80 00 	movl   $0x802531,(%esp)
  800150:	e8 99 00 00 00       	call   8001ee <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800158:	cc                   	int3   
  800159:	eb fd                	jmp    800158 <_panic+0x43>

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	75 1a                	jne    800194 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017a:	83 ec 08             	sub    $0x8,%esp
  80017d:	68 ff 00 00 00       	push   $0xff
  800182:	8d 43 08             	lea    0x8(%ebx),%eax
  800185:	50                   	push   %eax
  800186:	e8 55 0a 00 00       	call   800be0 <sys_cputs>
		b->idx = 0;
  80018b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800191:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ad:	00 00 00 
	b.cnt = 0;
  8001b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ba:	ff 75 0c             	pushl  0xc(%ebp)
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	68 5b 01 80 00       	push   $0x80015b
  8001cc:	e8 54 01 00 00       	call   800325 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d1:	83 c4 08             	add    $0x8,%esp
  8001d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	e8 fa 09 00 00       	call   800be0 <sys_cputs>

	return b.cnt;
}
  8001e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f7:	50                   	push   %eax
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	e8 9d ff ff ff       	call   80019d <vcprintf>
	va_end(ap);

	return cnt;
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	57                   	push   %edi
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	83 ec 1c             	sub    $0x1c,%esp
  80020b:	89 c7                	mov    %eax,%edi
  80020d:	89 d6                	mov    %edx,%esi
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	8b 55 0c             	mov    0xc(%ebp),%edx
  800215:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800218:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800226:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800229:	39 d3                	cmp    %edx,%ebx
  80022b:	72 05                	jb     800232 <printnum+0x30>
  80022d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800230:	77 45                	ja     800277 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800232:	83 ec 0c             	sub    $0xc,%esp
  800235:	ff 75 18             	pushl  0x18(%ebp)
  800238:	8b 45 14             	mov    0x14(%ebp),%eax
  80023b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80023e:	53                   	push   %ebx
  80023f:	ff 75 10             	pushl  0x10(%ebp)
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	ff 75 e4             	pushl  -0x1c(%ebp)
  800248:	ff 75 e0             	pushl  -0x20(%ebp)
  80024b:	ff 75 dc             	pushl  -0x24(%ebp)
  80024e:	ff 75 d8             	pushl  -0x28(%ebp)
  800251:	e8 3a 1b 00 00       	call   801d90 <__udivdi3>
  800256:	83 c4 18             	add    $0x18,%esp
  800259:	52                   	push   %edx
  80025a:	50                   	push   %eax
  80025b:	89 f2                	mov    %esi,%edx
  80025d:	89 f8                	mov    %edi,%eax
  80025f:	e8 9e ff ff ff       	call   800202 <printnum>
  800264:	83 c4 20             	add    $0x20,%esp
  800267:	eb 18                	jmp    800281 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	ff d7                	call   *%edi
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 03                	jmp    80027a <printnum+0x78>
  800277:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027a:	83 eb 01             	sub    $0x1,%ebx
  80027d:	85 db                	test   %ebx,%ebx
  80027f:	7f e8                	jg     800269 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	56                   	push   %esi
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 27 1c 00 00       	call   801ec0 <__umoddi3>
  800299:	83 c4 14             	add    $0x14,%esp
  80029c:	0f be 80 bb 20 80 00 	movsbl 0x8020bb(%eax),%eax
  8002a3:	50                   	push   %eax
  8002a4:	ff d7                	call   *%edi
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b4:	83 fa 01             	cmp    $0x1,%edx
  8002b7:	7e 0e                	jle    8002c7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	8b 52 04             	mov    0x4(%edx),%edx
  8002c5:	eb 22                	jmp    8002e9 <getuint+0x38>
	else if (lflag)
  8002c7:	85 d2                	test   %edx,%edx
  8002c9:	74 10                	je     8002db <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d9:	eb 0e                	jmp    8002e9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 02                	mov    (%edx),%eax
  8002e4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fa:	73 0a                	jae    800306 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 45 08             	mov    0x8(%ebp),%eax
  800304:	88 02                	mov    %al,(%edx)
}
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    

00800308 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800311:	50                   	push   %eax
  800312:	ff 75 10             	pushl  0x10(%ebp)
  800315:	ff 75 0c             	pushl  0xc(%ebp)
  800318:	ff 75 08             	pushl  0x8(%ebp)
  80031b:	e8 05 00 00 00       	call   800325 <vprintfmt>
	va_end(ap);
}
  800320:	83 c4 10             	add    $0x10,%esp
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	83 ec 2c             	sub    $0x2c,%esp
  80032e:	8b 75 08             	mov    0x8(%ebp),%esi
  800331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800334:	8b 7d 10             	mov    0x10(%ebp),%edi
  800337:	eb 12                	jmp    80034b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800339:	85 c0                	test   %eax,%eax
  80033b:	0f 84 38 04 00 00    	je     800779 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	53                   	push   %ebx
  800345:	50                   	push   %eax
  800346:	ff d6                	call   *%esi
  800348:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034b:	83 c7 01             	add    $0x1,%edi
  80034e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800352:	83 f8 25             	cmp    $0x25,%eax
  800355:	75 e2                	jne    800339 <vprintfmt+0x14>
  800357:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800362:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800369:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800370:	ba 00 00 00 00       	mov    $0x0,%edx
  800375:	eb 07                	jmp    80037e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  80037a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8d 47 01             	lea    0x1(%edi),%eax
  800381:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800384:	0f b6 07             	movzbl (%edi),%eax
  800387:	0f b6 c8             	movzbl %al,%ecx
  80038a:	83 e8 23             	sub    $0x23,%eax
  80038d:	3c 55                	cmp    $0x55,%al
  80038f:	0f 87 c9 03 00 00    	ja     80075e <vprintfmt+0x439>
  800395:	0f b6 c0             	movzbl %al,%eax
  800398:	ff 24 85 00 22 80 00 	jmp    *0x802200(,%eax,4)
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a6:	eb d6                	jmp    80037e <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  8003a8:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  8003af:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  8003b5:	eb 94                	jmp    80034b <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  8003b7:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  8003be:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  8003c4:	eb 85                	jmp    80034b <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  8003c6:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  8003cd:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  8003d3:	e9 73 ff ff ff       	jmp    80034b <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  8003d8:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  8003df:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  8003e5:	e9 61 ff ff ff       	jmp    80034b <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  8003ea:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  8003f1:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  8003f7:	e9 4f ff ff ff       	jmp    80034b <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  8003fc:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800403:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  800409:	e9 3d ff ff ff       	jmp    80034b <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  80040e:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  800415:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80041b:	e9 2b ff ff ff       	jmp    80034b <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  800420:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  800427:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  80042d:	e9 19 ff ff ff       	jmp    80034b <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800432:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  800439:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  80043f:	e9 07 ff ff ff       	jmp    80034b <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  800444:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  80044b:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800451:	e9 f5 fe ff ff       	jmp    80034b <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800459:	b8 00 00 00 00       	mov    $0x0,%eax
  80045e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800461:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800464:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800468:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80046b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80046e:	83 fa 09             	cmp    $0x9,%edx
  800471:	77 3f                	ja     8004b2 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800473:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800476:	eb e9                	jmp    800461 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 48 04             	lea    0x4(%eax),%ecx
  80047e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800481:	8b 00                	mov    (%eax),%eax
  800483:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800489:	eb 2d                	jmp    8004b8 <vprintfmt+0x193>
  80048b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80048e:	85 c0                	test   %eax,%eax
  800490:	b9 00 00 00 00       	mov    $0x0,%ecx
  800495:	0f 49 c8             	cmovns %eax,%ecx
  800498:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049e:	e9 db fe ff ff       	jmp    80037e <vprintfmt+0x59>
  8004a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004a6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004ad:	e9 cc fe ff ff       	jmp    80037e <vprintfmt+0x59>
  8004b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004b5:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004b8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004bc:	0f 89 bc fe ff ff    	jns    80037e <vprintfmt+0x59>
				width = precision, precision = -1;
  8004c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004cf:	e9 aa fe ff ff       	jmp    80037e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d4:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004da:	e9 9f fe ff ff       	jmp    80037e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004df:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e2:	8d 50 04             	lea    0x4(%eax),%edx
  8004e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	ff 30                	pushl  (%eax)
  8004ee:	ff d6                	call   *%esi
			break;
  8004f0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004f6:	e9 50 fe ff ff       	jmp    80034b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fe:	8d 50 04             	lea    0x4(%eax),%edx
  800501:	89 55 14             	mov    %edx,0x14(%ebp)
  800504:	8b 00                	mov    (%eax),%eax
  800506:	99                   	cltd   
  800507:	31 d0                	xor    %edx,%eax
  800509:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80050b:	83 f8 0f             	cmp    $0xf,%eax
  80050e:	7f 0b                	jg     80051b <vprintfmt+0x1f6>
  800510:	8b 14 85 60 23 80 00 	mov    0x802360(,%eax,4),%edx
  800517:	85 d2                	test   %edx,%edx
  800519:	75 18                	jne    800533 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80051b:	50                   	push   %eax
  80051c:	68 d3 20 80 00       	push   $0x8020d3
  800521:	53                   	push   %ebx
  800522:	56                   	push   %esi
  800523:	e8 e0 fd ff ff       	call   800308 <printfmt>
  800528:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80052e:	e9 18 fe ff ff       	jmp    80034b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800533:	52                   	push   %edx
  800534:	68 d1 24 80 00       	push   $0x8024d1
  800539:	53                   	push   %ebx
  80053a:	56                   	push   %esi
  80053b:	e8 c8 fd ff ff       	call   800308 <printfmt>
  800540:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800543:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800546:	e9 00 fe ff ff       	jmp    80034b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80054b:	8b 45 14             	mov    0x14(%ebp),%eax
  80054e:	8d 50 04             	lea    0x4(%eax),%edx
  800551:	89 55 14             	mov    %edx,0x14(%ebp)
  800554:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800556:	85 ff                	test   %edi,%edi
  800558:	b8 cc 20 80 00       	mov    $0x8020cc,%eax
  80055d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800560:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800564:	0f 8e 94 00 00 00    	jle    8005fe <vprintfmt+0x2d9>
  80056a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80056e:	0f 84 98 00 00 00    	je     80060c <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  800574:	83 ec 08             	sub    $0x8,%esp
  800577:	ff 75 d0             	pushl  -0x30(%ebp)
  80057a:	57                   	push   %edi
  80057b:	e8 81 02 00 00       	call   800801 <strnlen>
  800580:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800583:	29 c1                	sub    %eax,%ecx
  800585:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800588:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80058b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80058f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800592:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800595:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800597:	eb 0f                	jmp    8005a8 <vprintfmt+0x283>
					putch(padc, putdat);
  800599:	83 ec 08             	sub    $0x8,%esp
  80059c:	53                   	push   %ebx
  80059d:	ff 75 e0             	pushl  -0x20(%ebp)
  8005a0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a2:	83 ef 01             	sub    $0x1,%edi
  8005a5:	83 c4 10             	add    $0x10,%esp
  8005a8:	85 ff                	test   %edi,%edi
  8005aa:	7f ed                	jg     800599 <vprintfmt+0x274>
  8005ac:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005af:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005b2:	85 c9                	test   %ecx,%ecx
  8005b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b9:	0f 49 c1             	cmovns %ecx,%eax
  8005bc:	29 c1                	sub    %eax,%ecx
  8005be:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c7:	89 cb                	mov    %ecx,%ebx
  8005c9:	eb 4d                	jmp    800618 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005cb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005cf:	74 1b                	je     8005ec <vprintfmt+0x2c7>
  8005d1:	0f be c0             	movsbl %al,%eax
  8005d4:	83 e8 20             	sub    $0x20,%eax
  8005d7:	83 f8 5e             	cmp    $0x5e,%eax
  8005da:	76 10                	jbe    8005ec <vprintfmt+0x2c7>
					putch('?', putdat);
  8005dc:	83 ec 08             	sub    $0x8,%esp
  8005df:	ff 75 0c             	pushl  0xc(%ebp)
  8005e2:	6a 3f                	push   $0x3f
  8005e4:	ff 55 08             	call   *0x8(%ebp)
  8005e7:	83 c4 10             	add    $0x10,%esp
  8005ea:	eb 0d                	jmp    8005f9 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	ff 75 0c             	pushl  0xc(%ebp)
  8005f2:	52                   	push   %edx
  8005f3:	ff 55 08             	call   *0x8(%ebp)
  8005f6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f9:	83 eb 01             	sub    $0x1,%ebx
  8005fc:	eb 1a                	jmp    800618 <vprintfmt+0x2f3>
  8005fe:	89 75 08             	mov    %esi,0x8(%ebp)
  800601:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800604:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800607:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80060a:	eb 0c                	jmp    800618 <vprintfmt+0x2f3>
  80060c:	89 75 08             	mov    %esi,0x8(%ebp)
  80060f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800612:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800615:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800618:	83 c7 01             	add    $0x1,%edi
  80061b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80061f:	0f be d0             	movsbl %al,%edx
  800622:	85 d2                	test   %edx,%edx
  800624:	74 23                	je     800649 <vprintfmt+0x324>
  800626:	85 f6                	test   %esi,%esi
  800628:	78 a1                	js     8005cb <vprintfmt+0x2a6>
  80062a:	83 ee 01             	sub    $0x1,%esi
  80062d:	79 9c                	jns    8005cb <vprintfmt+0x2a6>
  80062f:	89 df                	mov    %ebx,%edi
  800631:	8b 75 08             	mov    0x8(%ebp),%esi
  800634:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800637:	eb 18                	jmp    800651 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	53                   	push   %ebx
  80063d:	6a 20                	push   $0x20
  80063f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800641:	83 ef 01             	sub    $0x1,%edi
  800644:	83 c4 10             	add    $0x10,%esp
  800647:	eb 08                	jmp    800651 <vprintfmt+0x32c>
  800649:	89 df                	mov    %ebx,%edi
  80064b:	8b 75 08             	mov    0x8(%ebp),%esi
  80064e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800651:	85 ff                	test   %edi,%edi
  800653:	7f e4                	jg     800639 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800655:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800658:	e9 ee fc ff ff       	jmp    80034b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80065d:	83 fa 01             	cmp    $0x1,%edx
  800660:	7e 16                	jle    800678 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 50 08             	lea    0x8(%eax),%edx
  800668:	89 55 14             	mov    %edx,0x14(%ebp)
  80066b:	8b 50 04             	mov    0x4(%eax),%edx
  80066e:	8b 00                	mov    (%eax),%eax
  800670:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800673:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800676:	eb 32                	jmp    8006aa <vprintfmt+0x385>
	else if (lflag)
  800678:	85 d2                	test   %edx,%edx
  80067a:	74 18                	je     800694 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8d 50 04             	lea    0x4(%eax),%edx
  800682:	89 55 14             	mov    %edx,0x14(%ebp)
  800685:	8b 00                	mov    (%eax),%eax
  800687:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068a:	89 c1                	mov    %eax,%ecx
  80068c:	c1 f9 1f             	sar    $0x1f,%ecx
  80068f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800692:	eb 16                	jmp    8006aa <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 00                	mov    (%eax),%eax
  80069f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a2:	89 c1                	mov    %eax,%ecx
  8006a4:	c1 f9 1f             	sar    $0x1f,%ecx
  8006a7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ad:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006b0:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006b5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006b9:	79 6f                	jns    80072a <vprintfmt+0x405>
				putch('-', putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	6a 2d                	push   $0x2d
  8006c1:	ff d6                	call   *%esi
				num = -(long long) num;
  8006c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006c9:	f7 d8                	neg    %eax
  8006cb:	83 d2 00             	adc    $0x0,%edx
  8006ce:	f7 da                	neg    %edx
  8006d0:	83 c4 10             	add    $0x10,%esp
  8006d3:	eb 55                	jmp    80072a <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d8:	e8 d4 fb ff ff       	call   8002b1 <getuint>
			base = 10;
  8006dd:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8006e2:	eb 46                	jmp    80072a <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e7:	e8 c5 fb ff ff       	call   8002b1 <getuint>
			base = 8;
  8006ec:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8006f1:	eb 37                	jmp    80072a <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	53                   	push   %ebx
  8006f7:	6a 30                	push   $0x30
  8006f9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006fb:	83 c4 08             	add    $0x8,%esp
  8006fe:	53                   	push   %ebx
  8006ff:	6a 78                	push   $0x78
  800701:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	8d 50 04             	lea    0x4(%eax),%edx
  800709:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80070c:	8b 00                	mov    (%eax),%eax
  80070e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800713:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800716:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80071b:	eb 0d                	jmp    80072a <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80071d:	8d 45 14             	lea    0x14(%ebp),%eax
  800720:	e8 8c fb ff ff       	call   8002b1 <getuint>
			base = 16;
  800725:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80072a:	83 ec 0c             	sub    $0xc,%esp
  80072d:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800731:	51                   	push   %ecx
  800732:	ff 75 e0             	pushl  -0x20(%ebp)
  800735:	57                   	push   %edi
  800736:	52                   	push   %edx
  800737:	50                   	push   %eax
  800738:	89 da                	mov    %ebx,%edx
  80073a:	89 f0                	mov    %esi,%eax
  80073c:	e8 c1 fa ff ff       	call   800202 <printnum>
			break;
  800741:	83 c4 20             	add    $0x20,%esp
  800744:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800747:	e9 ff fb ff ff       	jmp    80034b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80074c:	83 ec 08             	sub    $0x8,%esp
  80074f:	53                   	push   %ebx
  800750:	51                   	push   %ecx
  800751:	ff d6                	call   *%esi
			break;
  800753:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800756:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800759:	e9 ed fb ff ff       	jmp    80034b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80075e:	83 ec 08             	sub    $0x8,%esp
  800761:	53                   	push   %ebx
  800762:	6a 25                	push   $0x25
  800764:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	eb 03                	jmp    80076e <vprintfmt+0x449>
  80076b:	83 ef 01             	sub    $0x1,%edi
  80076e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800772:	75 f7                	jne    80076b <vprintfmt+0x446>
  800774:	e9 d2 fb ff ff       	jmp    80034b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800779:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80077c:	5b                   	pop    %ebx
  80077d:	5e                   	pop    %esi
  80077e:	5f                   	pop    %edi
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	83 ec 18             	sub    $0x18,%esp
  800787:	8b 45 08             	mov    0x8(%ebp),%eax
  80078a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80078d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800790:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800794:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800797:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80079e:	85 c0                	test   %eax,%eax
  8007a0:	74 26                	je     8007c8 <vsnprintf+0x47>
  8007a2:	85 d2                	test   %edx,%edx
  8007a4:	7e 22                	jle    8007c8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a6:	ff 75 14             	pushl  0x14(%ebp)
  8007a9:	ff 75 10             	pushl  0x10(%ebp)
  8007ac:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007af:	50                   	push   %eax
  8007b0:	68 eb 02 80 00       	push   $0x8002eb
  8007b5:	e8 6b fb ff ff       	call   800325 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007bd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c3:	83 c4 10             	add    $0x10,%esp
  8007c6:	eb 05                	jmp    8007cd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007cd:	c9                   	leave  
  8007ce:	c3                   	ret    

008007cf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d8:	50                   	push   %eax
  8007d9:	ff 75 10             	pushl  0x10(%ebp)
  8007dc:	ff 75 0c             	pushl  0xc(%ebp)
  8007df:	ff 75 08             	pushl  0x8(%ebp)
  8007e2:	e8 9a ff ff ff       	call   800781 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    

008007e9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f4:	eb 03                	jmp    8007f9 <strlen+0x10>
		n++;
  8007f6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007fd:	75 f7                	jne    8007f6 <strlen+0xd>
		n++;
	return n;
}
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800807:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080a:	ba 00 00 00 00       	mov    $0x0,%edx
  80080f:	eb 03                	jmp    800814 <strnlen+0x13>
		n++;
  800811:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800814:	39 c2                	cmp    %eax,%edx
  800816:	74 08                	je     800820 <strnlen+0x1f>
  800818:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80081c:	75 f3                	jne    800811 <strnlen+0x10>
  80081e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	53                   	push   %ebx
  800826:	8b 45 08             	mov    0x8(%ebp),%eax
  800829:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80082c:	89 c2                	mov    %eax,%edx
  80082e:	83 c2 01             	add    $0x1,%edx
  800831:	83 c1 01             	add    $0x1,%ecx
  800834:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800838:	88 5a ff             	mov    %bl,-0x1(%edx)
  80083b:	84 db                	test   %bl,%bl
  80083d:	75 ef                	jne    80082e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80083f:	5b                   	pop    %ebx
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	53                   	push   %ebx
  800846:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800849:	53                   	push   %ebx
  80084a:	e8 9a ff ff ff       	call   8007e9 <strlen>
  80084f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800852:	ff 75 0c             	pushl  0xc(%ebp)
  800855:	01 d8                	add    %ebx,%eax
  800857:	50                   	push   %eax
  800858:	e8 c5 ff ff ff       	call   800822 <strcpy>
	return dst;
}
  80085d:	89 d8                	mov    %ebx,%eax
  80085f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800862:	c9                   	leave  
  800863:	c3                   	ret    

00800864 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	56                   	push   %esi
  800868:	53                   	push   %ebx
  800869:	8b 75 08             	mov    0x8(%ebp),%esi
  80086c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086f:	89 f3                	mov    %esi,%ebx
  800871:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800874:	89 f2                	mov    %esi,%edx
  800876:	eb 0f                	jmp    800887 <strncpy+0x23>
		*dst++ = *src;
  800878:	83 c2 01             	add    $0x1,%edx
  80087b:	0f b6 01             	movzbl (%ecx),%eax
  80087e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800881:	80 39 01             	cmpb   $0x1,(%ecx)
  800884:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800887:	39 da                	cmp    %ebx,%edx
  800889:	75 ed                	jne    800878 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80088b:	89 f0                	mov    %esi,%eax
  80088d:	5b                   	pop    %ebx
  80088e:	5e                   	pop    %esi
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	56                   	push   %esi
  800895:	53                   	push   %ebx
  800896:	8b 75 08             	mov    0x8(%ebp),%esi
  800899:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089c:	8b 55 10             	mov    0x10(%ebp),%edx
  80089f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a1:	85 d2                	test   %edx,%edx
  8008a3:	74 21                	je     8008c6 <strlcpy+0x35>
  8008a5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008a9:	89 f2                	mov    %esi,%edx
  8008ab:	eb 09                	jmp    8008b6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ad:	83 c2 01             	add    $0x1,%edx
  8008b0:	83 c1 01             	add    $0x1,%ecx
  8008b3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b6:	39 c2                	cmp    %eax,%edx
  8008b8:	74 09                	je     8008c3 <strlcpy+0x32>
  8008ba:	0f b6 19             	movzbl (%ecx),%ebx
  8008bd:	84 db                	test   %bl,%bl
  8008bf:	75 ec                	jne    8008ad <strlcpy+0x1c>
  8008c1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008c3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008c6:	29 f0                	sub    %esi,%eax
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5e                   	pop    %esi
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d5:	eb 06                	jmp    8008dd <strcmp+0x11>
		p++, q++;
  8008d7:	83 c1 01             	add    $0x1,%ecx
  8008da:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008dd:	0f b6 01             	movzbl (%ecx),%eax
  8008e0:	84 c0                	test   %al,%al
  8008e2:	74 04                	je     8008e8 <strcmp+0x1c>
  8008e4:	3a 02                	cmp    (%edx),%al
  8008e6:	74 ef                	je     8008d7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e8:	0f b6 c0             	movzbl %al,%eax
  8008eb:	0f b6 12             	movzbl (%edx),%edx
  8008ee:	29 d0                	sub    %edx,%eax
}
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	53                   	push   %ebx
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fc:	89 c3                	mov    %eax,%ebx
  8008fe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800901:	eb 06                	jmp    800909 <strncmp+0x17>
		n--, p++, q++;
  800903:	83 c0 01             	add    $0x1,%eax
  800906:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800909:	39 d8                	cmp    %ebx,%eax
  80090b:	74 15                	je     800922 <strncmp+0x30>
  80090d:	0f b6 08             	movzbl (%eax),%ecx
  800910:	84 c9                	test   %cl,%cl
  800912:	74 04                	je     800918 <strncmp+0x26>
  800914:	3a 0a                	cmp    (%edx),%cl
  800916:	74 eb                	je     800903 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800918:	0f b6 00             	movzbl (%eax),%eax
  80091b:	0f b6 12             	movzbl (%edx),%edx
  80091e:	29 d0                	sub    %edx,%eax
  800920:	eb 05                	jmp    800927 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800927:	5b                   	pop    %ebx
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800934:	eb 07                	jmp    80093d <strchr+0x13>
		if (*s == c)
  800936:	38 ca                	cmp    %cl,%dl
  800938:	74 0f                	je     800949 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80093a:	83 c0 01             	add    $0x1,%eax
  80093d:	0f b6 10             	movzbl (%eax),%edx
  800940:	84 d2                	test   %dl,%dl
  800942:	75 f2                	jne    800936 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800944:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800955:	eb 03                	jmp    80095a <strfind+0xf>
  800957:	83 c0 01             	add    $0x1,%eax
  80095a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80095d:	38 ca                	cmp    %cl,%dl
  80095f:	74 04                	je     800965 <strfind+0x1a>
  800961:	84 d2                	test   %dl,%dl
  800963:	75 f2                	jne    800957 <strfind+0xc>
			break;
	return (char *) s;
}
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	57                   	push   %edi
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800970:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800973:	85 c9                	test   %ecx,%ecx
  800975:	74 36                	je     8009ad <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800977:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097d:	75 28                	jne    8009a7 <memset+0x40>
  80097f:	f6 c1 03             	test   $0x3,%cl
  800982:	75 23                	jne    8009a7 <memset+0x40>
		c &= 0xFF;
  800984:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800988:	89 d3                	mov    %edx,%ebx
  80098a:	c1 e3 08             	shl    $0x8,%ebx
  80098d:	89 d6                	mov    %edx,%esi
  80098f:	c1 e6 18             	shl    $0x18,%esi
  800992:	89 d0                	mov    %edx,%eax
  800994:	c1 e0 10             	shl    $0x10,%eax
  800997:	09 f0                	or     %esi,%eax
  800999:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80099b:	89 d8                	mov    %ebx,%eax
  80099d:	09 d0                	or     %edx,%eax
  80099f:	c1 e9 02             	shr    $0x2,%ecx
  8009a2:	fc                   	cld    
  8009a3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a5:	eb 06                	jmp    8009ad <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009aa:	fc                   	cld    
  8009ab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ad:	89 f8                	mov    %edi,%eax
  8009af:	5b                   	pop    %ebx
  8009b0:	5e                   	pop    %esi
  8009b1:	5f                   	pop    %edi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	57                   	push   %edi
  8009b8:	56                   	push   %esi
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c2:	39 c6                	cmp    %eax,%esi
  8009c4:	73 35                	jae    8009fb <memmove+0x47>
  8009c6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c9:	39 d0                	cmp    %edx,%eax
  8009cb:	73 2e                	jae    8009fb <memmove+0x47>
		s += n;
		d += n;
  8009cd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d0:	89 d6                	mov    %edx,%esi
  8009d2:	09 fe                	or     %edi,%esi
  8009d4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009da:	75 13                	jne    8009ef <memmove+0x3b>
  8009dc:	f6 c1 03             	test   $0x3,%cl
  8009df:	75 0e                	jne    8009ef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009e1:	83 ef 04             	sub    $0x4,%edi
  8009e4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e7:	c1 e9 02             	shr    $0x2,%ecx
  8009ea:	fd                   	std    
  8009eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ed:	eb 09                	jmp    8009f8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ef:	83 ef 01             	sub    $0x1,%edi
  8009f2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009f5:	fd                   	std    
  8009f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f8:	fc                   	cld    
  8009f9:	eb 1d                	jmp    800a18 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fb:	89 f2                	mov    %esi,%edx
  8009fd:	09 c2                	or     %eax,%edx
  8009ff:	f6 c2 03             	test   $0x3,%dl
  800a02:	75 0f                	jne    800a13 <memmove+0x5f>
  800a04:	f6 c1 03             	test   $0x3,%cl
  800a07:	75 0a                	jne    800a13 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a09:	c1 e9 02             	shr    $0x2,%ecx
  800a0c:	89 c7                	mov    %eax,%edi
  800a0e:	fc                   	cld    
  800a0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a11:	eb 05                	jmp    800a18 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a13:	89 c7                	mov    %eax,%edi
  800a15:	fc                   	cld    
  800a16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a18:	5e                   	pop    %esi
  800a19:	5f                   	pop    %edi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a1f:	ff 75 10             	pushl  0x10(%ebp)
  800a22:	ff 75 0c             	pushl  0xc(%ebp)
  800a25:	ff 75 08             	pushl  0x8(%ebp)
  800a28:	e8 87 ff ff ff       	call   8009b4 <memmove>
}
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    

00800a2f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3a:	89 c6                	mov    %eax,%esi
  800a3c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3f:	eb 1a                	jmp    800a5b <memcmp+0x2c>
		if (*s1 != *s2)
  800a41:	0f b6 08             	movzbl (%eax),%ecx
  800a44:	0f b6 1a             	movzbl (%edx),%ebx
  800a47:	38 d9                	cmp    %bl,%cl
  800a49:	74 0a                	je     800a55 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a4b:	0f b6 c1             	movzbl %cl,%eax
  800a4e:	0f b6 db             	movzbl %bl,%ebx
  800a51:	29 d8                	sub    %ebx,%eax
  800a53:	eb 0f                	jmp    800a64 <memcmp+0x35>
		s1++, s2++;
  800a55:	83 c0 01             	add    $0x1,%eax
  800a58:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5b:	39 f0                	cmp    %esi,%eax
  800a5d:	75 e2                	jne    800a41 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a64:	5b                   	pop    %ebx
  800a65:	5e                   	pop    %esi
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	53                   	push   %ebx
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a6f:	89 c1                	mov    %eax,%ecx
  800a71:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a74:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a78:	eb 0a                	jmp    800a84 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a7a:	0f b6 10             	movzbl (%eax),%edx
  800a7d:	39 da                	cmp    %ebx,%edx
  800a7f:	74 07                	je     800a88 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a81:	83 c0 01             	add    $0x1,%eax
  800a84:	39 c8                	cmp    %ecx,%eax
  800a86:	72 f2                	jb     800a7a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a88:	5b                   	pop    %ebx
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
  800a91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a97:	eb 03                	jmp    800a9c <strtol+0x11>
		s++;
  800a99:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9c:	0f b6 01             	movzbl (%ecx),%eax
  800a9f:	3c 20                	cmp    $0x20,%al
  800aa1:	74 f6                	je     800a99 <strtol+0xe>
  800aa3:	3c 09                	cmp    $0x9,%al
  800aa5:	74 f2                	je     800a99 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aa7:	3c 2b                	cmp    $0x2b,%al
  800aa9:	75 0a                	jne    800ab5 <strtol+0x2a>
		s++;
  800aab:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aae:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab3:	eb 11                	jmp    800ac6 <strtol+0x3b>
  800ab5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aba:	3c 2d                	cmp    $0x2d,%al
  800abc:	75 08                	jne    800ac6 <strtol+0x3b>
		s++, neg = 1;
  800abe:	83 c1 01             	add    $0x1,%ecx
  800ac1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800acc:	75 15                	jne    800ae3 <strtol+0x58>
  800ace:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad1:	75 10                	jne    800ae3 <strtol+0x58>
  800ad3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ad7:	75 7c                	jne    800b55 <strtol+0xca>
		s += 2, base = 16;
  800ad9:	83 c1 02             	add    $0x2,%ecx
  800adc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae1:	eb 16                	jmp    800af9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ae3:	85 db                	test   %ebx,%ebx
  800ae5:	75 12                	jne    800af9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ae7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aec:	80 39 30             	cmpb   $0x30,(%ecx)
  800aef:	75 08                	jne    800af9 <strtol+0x6e>
		s++, base = 8;
  800af1:	83 c1 01             	add    $0x1,%ecx
  800af4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800af9:	b8 00 00 00 00       	mov    $0x0,%eax
  800afe:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b01:	0f b6 11             	movzbl (%ecx),%edx
  800b04:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b07:	89 f3                	mov    %esi,%ebx
  800b09:	80 fb 09             	cmp    $0x9,%bl
  800b0c:	77 08                	ja     800b16 <strtol+0x8b>
			dig = *s - '0';
  800b0e:	0f be d2             	movsbl %dl,%edx
  800b11:	83 ea 30             	sub    $0x30,%edx
  800b14:	eb 22                	jmp    800b38 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b16:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b19:	89 f3                	mov    %esi,%ebx
  800b1b:	80 fb 19             	cmp    $0x19,%bl
  800b1e:	77 08                	ja     800b28 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b20:	0f be d2             	movsbl %dl,%edx
  800b23:	83 ea 57             	sub    $0x57,%edx
  800b26:	eb 10                	jmp    800b38 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b28:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b2b:	89 f3                	mov    %esi,%ebx
  800b2d:	80 fb 19             	cmp    $0x19,%bl
  800b30:	77 16                	ja     800b48 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b32:	0f be d2             	movsbl %dl,%edx
  800b35:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b38:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b3b:	7d 0b                	jge    800b48 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b3d:	83 c1 01             	add    $0x1,%ecx
  800b40:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b44:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b46:	eb b9                	jmp    800b01 <strtol+0x76>

	if (endptr)
  800b48:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b4c:	74 0d                	je     800b5b <strtol+0xd0>
		*endptr = (char *) s;
  800b4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b51:	89 0e                	mov    %ecx,(%esi)
  800b53:	eb 06                	jmp    800b5b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b55:	85 db                	test   %ebx,%ebx
  800b57:	74 98                	je     800af1 <strtol+0x66>
  800b59:	eb 9e                	jmp    800af9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b5b:	89 c2                	mov    %eax,%edx
  800b5d:	f7 da                	neg    %edx
  800b5f:	85 ff                	test   %edi,%edi
  800b61:	0f 45 c2             	cmovne %edx,%eax
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	83 ec 04             	sub    $0x4,%esp
  800b72:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800b75:	57                   	push   %edi
  800b76:	e8 6e fc ff ff       	call   8007e9 <strlen>
  800b7b:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b7e:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800b81:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800b86:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b8b:	eb 46                	jmp    800bd3 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800b8d:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800b91:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b94:	80 f9 09             	cmp    $0x9,%cl
  800b97:	77 08                	ja     800ba1 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800b99:	0f be d2             	movsbl %dl,%edx
  800b9c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b9f:	eb 27                	jmp    800bc8 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800ba1:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800ba4:	80 f9 05             	cmp    $0x5,%cl
  800ba7:	77 08                	ja     800bb1 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800ba9:	0f be d2             	movsbl %dl,%edx
  800bac:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800baf:	eb 17                	jmp    800bc8 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800bb1:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800bb4:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800bb7:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800bbc:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800bc0:	77 06                	ja     800bc8 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800bc2:	0f be d2             	movsbl %dl,%edx
  800bc5:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800bc8:	0f af ce             	imul   %esi,%ecx
  800bcb:	01 c8                	add    %ecx,%eax
		base *= 16;
  800bcd:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800bd0:	83 eb 01             	sub    $0x1,%ebx
  800bd3:	83 fb 01             	cmp    $0x1,%ebx
  800bd6:	7f b5                	jg     800b8d <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	b8 00 00 00 00       	mov    $0x0,%eax
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	89 c3                	mov    %eax,%ebx
  800bf3:	89 c7                	mov    %eax,%edi
  800bf5:	89 c6                	mov    %eax,%esi
  800bf7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_cgetc>:

int
sys_cgetc(void)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0e:	89 d1                	mov    %edx,%ecx
  800c10:	89 d3                	mov    %edx,%ebx
  800c12:	89 d7                	mov    %edx,%edi
  800c14:	89 d6                	mov    %edx,%esi
  800c16:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	89 cb                	mov    %ecx,%ebx
  800c35:	89 cf                	mov    %ecx,%edi
  800c37:	89 ce                	mov    %ecx,%esi
  800c39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	7e 17                	jle    800c56 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	83 ec 0c             	sub    $0xc,%esp
  800c42:	50                   	push   %eax
  800c43:	6a 03                	push   $0x3
  800c45:	68 bf 23 80 00       	push   $0x8023bf
  800c4a:	6a 23                	push   $0x23
  800c4c:	68 dc 23 80 00       	push   $0x8023dc
  800c51:	e8 bf f4 ff ff       	call   800115 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c64:	ba 00 00 00 00       	mov    $0x0,%edx
  800c69:	b8 02 00 00 00       	mov    $0x2,%eax
  800c6e:	89 d1                	mov    %edx,%ecx
  800c70:	89 d3                	mov    %edx,%ebx
  800c72:	89 d7                	mov    %edx,%edi
  800c74:	89 d6                	mov    %edx,%esi
  800c76:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_yield>:

void
sys_yield(void)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	ba 00 00 00 00       	mov    $0x0,%edx
  800c88:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c8d:	89 d1                	mov    %edx,%ecx
  800c8f:	89 d3                	mov    %edx,%ebx
  800c91:	89 d7                	mov    %edx,%edi
  800c93:	89 d6                	mov    %edx,%esi
  800c95:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca5:	be 00 00 00 00       	mov    $0x0,%esi
  800caa:	b8 04 00 00 00       	mov    $0x4,%eax
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb8:	89 f7                	mov    %esi,%edi
  800cba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7e 17                	jle    800cd7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 04                	push   $0x4
  800cc6:	68 bf 23 80 00       	push   $0x8023bf
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 dc 23 80 00       	push   $0x8023dc
  800cd2:	e8 3e f4 ff ff       	call   800115 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	b8 05 00 00 00       	mov    $0x5,%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf9:	8b 75 18             	mov    0x18(%ebp),%esi
  800cfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 05                	push   $0x5
  800d08:	68 bf 23 80 00       	push   $0x8023bf
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 dc 23 80 00       	push   $0x8023dc
  800d14:	e8 fc f3 ff ff       	call   800115 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
  800d27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2f:	b8 06 00 00 00       	mov    $0x6,%eax
  800d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	89 df                	mov    %ebx,%edi
  800d3c:	89 de                	mov    %ebx,%esi
  800d3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d40:	85 c0                	test   %eax,%eax
  800d42:	7e 17                	jle    800d5b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 06                	push   $0x6
  800d4a:	68 bf 23 80 00       	push   $0x8023bf
  800d4f:	6a 23                	push   $0x23
  800d51:	68 dc 23 80 00       	push   $0x8023dc
  800d56:	e8 ba f3 ff ff       	call   800115 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d71:	b8 08 00 00 00       	mov    $0x8,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 df                	mov    %ebx,%edi
  800d7e:	89 de                	mov    %ebx,%esi
  800d80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d82:	85 c0                	test   %eax,%eax
  800d84:	7e 17                	jle    800d9d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	50                   	push   %eax
  800d8a:	6a 08                	push   $0x8
  800d8c:	68 bf 23 80 00       	push   $0x8023bf
  800d91:	6a 23                	push   $0x23
  800d93:	68 dc 23 80 00       	push   $0x8023dc
  800d98:	e8 78 f3 ff ff       	call   800115 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800db8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	89 df                	mov    %ebx,%edi
  800dc0:	89 de                	mov    %ebx,%esi
  800dc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	7e 17                	jle    800ddf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	50                   	push   %eax
  800dcc:	6a 0a                	push   $0xa
  800dce:	68 bf 23 80 00       	push   $0x8023bf
  800dd3:	6a 23                	push   $0x23
  800dd5:	68 dc 23 80 00       	push   $0x8023dc
  800dda:	e8 36 f3 ff ff       	call   800115 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ddf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	56                   	push   %esi
  800dec:	53                   	push   %ebx
  800ded:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df5:	b8 09 00 00 00       	mov    $0x9,%eax
  800dfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	89 df                	mov    %ebx,%edi
  800e02:	89 de                	mov    %ebx,%esi
  800e04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	7e 17                	jle    800e21 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0a:	83 ec 0c             	sub    $0xc,%esp
  800e0d:	50                   	push   %eax
  800e0e:	6a 09                	push   $0x9
  800e10:	68 bf 23 80 00       	push   $0x8023bf
  800e15:	6a 23                	push   $0x23
  800e17:	68 dc 23 80 00       	push   $0x8023dc
  800e1c:	e8 f4 f2 ff ff       	call   800115 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2f:	be 00 00 00 00       	mov    $0x0,%esi
  800e34:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e42:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e45:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e62:	89 cb                	mov    %ecx,%ebx
  800e64:	89 cf                	mov    %ecx,%edi
  800e66:	89 ce                	mov    %ecx,%esi
  800e68:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	7e 17                	jle    800e85 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6e:	83 ec 0c             	sub    $0xc,%esp
  800e71:	50                   	push   %eax
  800e72:	6a 0d                	push   $0xd
  800e74:	68 bf 23 80 00       	push   $0x8023bf
  800e79:	6a 23                	push   $0x23
  800e7b:	68 dc 23 80 00       	push   $0x8023dc
  800e80:	e8 90 f2 ff ff       	call   800115 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  800e93:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800e9a:	75 52                	jne    800eee <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  800e9c:	83 ec 04             	sub    $0x4,%esp
  800e9f:	6a 07                	push   $0x7
  800ea1:	68 00 f0 bf ee       	push   $0xeebff000
  800ea6:	6a 00                	push   $0x0
  800ea8:	e8 ef fd ff ff       	call   800c9c <sys_page_alloc>
  800ead:	83 c4 10             	add    $0x10,%esp
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	79 12                	jns    800ec6 <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  800eb4:	50                   	push   %eax
  800eb5:	68 ea 23 80 00       	push   $0x8023ea
  800eba:	6a 23                	push   $0x23
  800ebc:	68 fd 23 80 00       	push   $0x8023fd
  800ec1:	e8 4f f2 ff ff       	call   800115 <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  800ec6:	83 ec 08             	sub    $0x8,%esp
  800ec9:	68 f8 0e 80 00       	push   $0x800ef8
  800ece:	6a 00                	push   $0x0
  800ed0:	e8 12 ff ff ff       	call   800de7 <sys_env_set_pgfault_upcall>
  800ed5:	83 c4 10             	add    $0x10,%esp
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	79 12                	jns    800eee <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  800edc:	50                   	push   %eax
  800edd:	68 0c 24 80 00       	push   $0x80240c
  800ee2:	6a 26                	push   $0x26
  800ee4:	68 fd 23 80 00       	push   $0x8023fd
  800ee9:	e8 27 f2 ff ff       	call   800115 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800eee:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef1:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800ef6:	c9                   	leave  
  800ef7:	c3                   	ret    

00800ef8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ef8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ef9:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800efe:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800f00:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  800f03:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  800f07:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  800f0c:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  800f10:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800f12:	83 c4 08             	add    $0x8,%esp
	popal 
  800f15:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800f16:	83 c4 04             	add    $0x4,%esp
	popfl
  800f19:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800f1a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800f1b:	c3                   	ret    

00800f1c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f22:	05 00 00 00 30       	add    $0x30000000,%eax
  800f27:	c1 e8 0c             	shr    $0xc,%eax
}
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f32:	05 00 00 00 30       	add    $0x30000000,%eax
  800f37:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f3c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    

00800f43 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f49:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f4e:	89 c2                	mov    %eax,%edx
  800f50:	c1 ea 16             	shr    $0x16,%edx
  800f53:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f5a:	f6 c2 01             	test   $0x1,%dl
  800f5d:	74 11                	je     800f70 <fd_alloc+0x2d>
  800f5f:	89 c2                	mov    %eax,%edx
  800f61:	c1 ea 0c             	shr    $0xc,%edx
  800f64:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f6b:	f6 c2 01             	test   $0x1,%dl
  800f6e:	75 09                	jne    800f79 <fd_alloc+0x36>
			*fd_store = fd;
  800f70:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f72:	b8 00 00 00 00       	mov    $0x0,%eax
  800f77:	eb 17                	jmp    800f90 <fd_alloc+0x4d>
  800f79:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f7e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f83:	75 c9                	jne    800f4e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f85:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f8b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f98:	83 f8 1f             	cmp    $0x1f,%eax
  800f9b:	77 36                	ja     800fd3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f9d:	c1 e0 0c             	shl    $0xc,%eax
  800fa0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fa5:	89 c2                	mov    %eax,%edx
  800fa7:	c1 ea 16             	shr    $0x16,%edx
  800faa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fb1:	f6 c2 01             	test   $0x1,%dl
  800fb4:	74 24                	je     800fda <fd_lookup+0x48>
  800fb6:	89 c2                	mov    %eax,%edx
  800fb8:	c1 ea 0c             	shr    $0xc,%edx
  800fbb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fc2:	f6 c2 01             	test   $0x1,%dl
  800fc5:	74 1a                	je     800fe1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fca:	89 02                	mov    %eax,(%edx)
	return 0;
  800fcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd1:	eb 13                	jmp    800fe6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fd3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fd8:	eb 0c                	jmp    800fe6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fda:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fdf:	eb 05                	jmp    800fe6 <fd_lookup+0x54>
  800fe1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fe6:	5d                   	pop    %ebp
  800fe7:	c3                   	ret    

00800fe8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	83 ec 08             	sub    $0x8,%esp
  800fee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ff1:	ba a8 24 80 00       	mov    $0x8024a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ff6:	eb 13                	jmp    80100b <dev_lookup+0x23>
  800ff8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ffb:	39 08                	cmp    %ecx,(%eax)
  800ffd:	75 0c                	jne    80100b <dev_lookup+0x23>
			*dev = devtab[i];
  800fff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801002:	89 01                	mov    %eax,(%ecx)
			return 0;
  801004:	b8 00 00 00 00       	mov    $0x0,%eax
  801009:	eb 2e                	jmp    801039 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80100b:	8b 02                	mov    (%edx),%eax
  80100d:	85 c0                	test   %eax,%eax
  80100f:	75 e7                	jne    800ff8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801011:	a1 08 40 80 00       	mov    0x804008,%eax
  801016:	8b 40 48             	mov    0x48(%eax),%eax
  801019:	83 ec 04             	sub    $0x4,%esp
  80101c:	51                   	push   %ecx
  80101d:	50                   	push   %eax
  80101e:	68 2c 24 80 00       	push   $0x80242c
  801023:	e8 c6 f1 ff ff       	call   8001ee <cprintf>
	*dev = 0;
  801028:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801031:	83 c4 10             	add    $0x10,%esp
  801034:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801039:	c9                   	leave  
  80103a:	c3                   	ret    

0080103b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	56                   	push   %esi
  80103f:	53                   	push   %ebx
  801040:	83 ec 10             	sub    $0x10,%esp
  801043:	8b 75 08             	mov    0x8(%ebp),%esi
  801046:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801049:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104c:	50                   	push   %eax
  80104d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801053:	c1 e8 0c             	shr    $0xc,%eax
  801056:	50                   	push   %eax
  801057:	e8 36 ff ff ff       	call   800f92 <fd_lookup>
  80105c:	83 c4 08             	add    $0x8,%esp
  80105f:	85 c0                	test   %eax,%eax
  801061:	78 05                	js     801068 <fd_close+0x2d>
	    || fd != fd2) 
  801063:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801066:	74 0c                	je     801074 <fd_close+0x39>
		return (must_exist ? r : 0); 
  801068:	84 db                	test   %bl,%bl
  80106a:	ba 00 00 00 00       	mov    $0x0,%edx
  80106f:	0f 44 c2             	cmove  %edx,%eax
  801072:	eb 41                	jmp    8010b5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801074:	83 ec 08             	sub    $0x8,%esp
  801077:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80107a:	50                   	push   %eax
  80107b:	ff 36                	pushl  (%esi)
  80107d:	e8 66 ff ff ff       	call   800fe8 <dev_lookup>
  801082:	89 c3                	mov    %eax,%ebx
  801084:	83 c4 10             	add    $0x10,%esp
  801087:	85 c0                	test   %eax,%eax
  801089:	78 1a                	js     8010a5 <fd_close+0x6a>
		if (dev->dev_close) 
  80108b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80108e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  801091:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  801096:	85 c0                	test   %eax,%eax
  801098:	74 0b                	je     8010a5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80109a:	83 ec 0c             	sub    $0xc,%esp
  80109d:	56                   	push   %esi
  80109e:	ff d0                	call   *%eax
  8010a0:	89 c3                	mov    %eax,%ebx
  8010a2:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010a5:	83 ec 08             	sub    $0x8,%esp
  8010a8:	56                   	push   %esi
  8010a9:	6a 00                	push   $0x0
  8010ab:	e8 71 fc ff ff       	call   800d21 <sys_page_unmap>
	return r;
  8010b0:	83 c4 10             	add    $0x10,%esp
  8010b3:	89 d8                	mov    %ebx,%eax
}
  8010b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b8:	5b                   	pop    %ebx
  8010b9:	5e                   	pop    %esi
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    

008010bc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c5:	50                   	push   %eax
  8010c6:	ff 75 08             	pushl  0x8(%ebp)
  8010c9:	e8 c4 fe ff ff       	call   800f92 <fd_lookup>
  8010ce:	83 c4 08             	add    $0x8,%esp
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	78 10                	js     8010e5 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  8010d5:	83 ec 08             	sub    $0x8,%esp
  8010d8:	6a 01                	push   $0x1
  8010da:	ff 75 f4             	pushl  -0xc(%ebp)
  8010dd:	e8 59 ff ff ff       	call   80103b <fd_close>
  8010e2:	83 c4 10             	add    $0x10,%esp
}
  8010e5:	c9                   	leave  
  8010e6:	c3                   	ret    

008010e7 <close_all>:

void
close_all(void)
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	53                   	push   %ebx
  8010eb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ee:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010f3:	83 ec 0c             	sub    $0xc,%esp
  8010f6:	53                   	push   %ebx
  8010f7:	e8 c0 ff ff ff       	call   8010bc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010fc:	83 c3 01             	add    $0x1,%ebx
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	83 fb 20             	cmp    $0x20,%ebx
  801105:	75 ec                	jne    8010f3 <close_all+0xc>
		close(i);
}
  801107:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80110a:	c9                   	leave  
  80110b:	c3                   	ret    

0080110c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	57                   	push   %edi
  801110:	56                   	push   %esi
  801111:	53                   	push   %ebx
  801112:	83 ec 2c             	sub    $0x2c,%esp
  801115:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801118:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80111b:	50                   	push   %eax
  80111c:	ff 75 08             	pushl  0x8(%ebp)
  80111f:	e8 6e fe ff ff       	call   800f92 <fd_lookup>
  801124:	83 c4 08             	add    $0x8,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	0f 88 c1 00 00 00    	js     8011f0 <dup+0xe4>
		return r;
	close(newfdnum);
  80112f:	83 ec 0c             	sub    $0xc,%esp
  801132:	56                   	push   %esi
  801133:	e8 84 ff ff ff       	call   8010bc <close>

	newfd = INDEX2FD(newfdnum);
  801138:	89 f3                	mov    %esi,%ebx
  80113a:	c1 e3 0c             	shl    $0xc,%ebx
  80113d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801143:	83 c4 04             	add    $0x4,%esp
  801146:	ff 75 e4             	pushl  -0x1c(%ebp)
  801149:	e8 de fd ff ff       	call   800f2c <fd2data>
  80114e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801150:	89 1c 24             	mov    %ebx,(%esp)
  801153:	e8 d4 fd ff ff       	call   800f2c <fd2data>
  801158:	83 c4 10             	add    $0x10,%esp
  80115b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80115e:	89 f8                	mov    %edi,%eax
  801160:	c1 e8 16             	shr    $0x16,%eax
  801163:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80116a:	a8 01                	test   $0x1,%al
  80116c:	74 37                	je     8011a5 <dup+0x99>
  80116e:	89 f8                	mov    %edi,%eax
  801170:	c1 e8 0c             	shr    $0xc,%eax
  801173:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80117a:	f6 c2 01             	test   $0x1,%dl
  80117d:	74 26                	je     8011a5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80117f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801186:	83 ec 0c             	sub    $0xc,%esp
  801189:	25 07 0e 00 00       	and    $0xe07,%eax
  80118e:	50                   	push   %eax
  80118f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801192:	6a 00                	push   $0x0
  801194:	57                   	push   %edi
  801195:	6a 00                	push   $0x0
  801197:	e8 43 fb ff ff       	call   800cdf <sys_page_map>
  80119c:	89 c7                	mov    %eax,%edi
  80119e:	83 c4 20             	add    $0x20,%esp
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	78 2e                	js     8011d3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011a5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011a8:	89 d0                	mov    %edx,%eax
  8011aa:	c1 e8 0c             	shr    $0xc,%eax
  8011ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b4:	83 ec 0c             	sub    $0xc,%esp
  8011b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8011bc:	50                   	push   %eax
  8011bd:	53                   	push   %ebx
  8011be:	6a 00                	push   $0x0
  8011c0:	52                   	push   %edx
  8011c1:	6a 00                	push   $0x0
  8011c3:	e8 17 fb ff ff       	call   800cdf <sys_page_map>
  8011c8:	89 c7                	mov    %eax,%edi
  8011ca:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011cd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011cf:	85 ff                	test   %edi,%edi
  8011d1:	79 1d                	jns    8011f0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011d3:	83 ec 08             	sub    $0x8,%esp
  8011d6:	53                   	push   %ebx
  8011d7:	6a 00                	push   $0x0
  8011d9:	e8 43 fb ff ff       	call   800d21 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011de:	83 c4 08             	add    $0x8,%esp
  8011e1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011e4:	6a 00                	push   $0x0
  8011e6:	e8 36 fb ff ff       	call   800d21 <sys_page_unmap>
	return r;
  8011eb:	83 c4 10             	add    $0x10,%esp
  8011ee:	89 f8                	mov    %edi,%eax
}
  8011f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f3:	5b                   	pop    %ebx
  8011f4:	5e                   	pop    %esi
  8011f5:	5f                   	pop    %edi
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    

008011f8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	53                   	push   %ebx
  8011fc:	83 ec 14             	sub    $0x14,%esp
  8011ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801202:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801205:	50                   	push   %eax
  801206:	53                   	push   %ebx
  801207:	e8 86 fd ff ff       	call   800f92 <fd_lookup>
  80120c:	83 c4 08             	add    $0x8,%esp
  80120f:	89 c2                	mov    %eax,%edx
  801211:	85 c0                	test   %eax,%eax
  801213:	78 6d                	js     801282 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801215:	83 ec 08             	sub    $0x8,%esp
  801218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121b:	50                   	push   %eax
  80121c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121f:	ff 30                	pushl  (%eax)
  801221:	e8 c2 fd ff ff       	call   800fe8 <dev_lookup>
  801226:	83 c4 10             	add    $0x10,%esp
  801229:	85 c0                	test   %eax,%eax
  80122b:	78 4c                	js     801279 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80122d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801230:	8b 42 08             	mov    0x8(%edx),%eax
  801233:	83 e0 03             	and    $0x3,%eax
  801236:	83 f8 01             	cmp    $0x1,%eax
  801239:	75 21                	jne    80125c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80123b:	a1 08 40 80 00       	mov    0x804008,%eax
  801240:	8b 40 48             	mov    0x48(%eax),%eax
  801243:	83 ec 04             	sub    $0x4,%esp
  801246:	53                   	push   %ebx
  801247:	50                   	push   %eax
  801248:	68 6d 24 80 00       	push   $0x80246d
  80124d:	e8 9c ef ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  801252:	83 c4 10             	add    $0x10,%esp
  801255:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80125a:	eb 26                	jmp    801282 <read+0x8a>
	}
	if (!dev->dev_read)
  80125c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125f:	8b 40 08             	mov    0x8(%eax),%eax
  801262:	85 c0                	test   %eax,%eax
  801264:	74 17                	je     80127d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801266:	83 ec 04             	sub    $0x4,%esp
  801269:	ff 75 10             	pushl  0x10(%ebp)
  80126c:	ff 75 0c             	pushl  0xc(%ebp)
  80126f:	52                   	push   %edx
  801270:	ff d0                	call   *%eax
  801272:	89 c2                	mov    %eax,%edx
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	eb 09                	jmp    801282 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801279:	89 c2                	mov    %eax,%edx
  80127b:	eb 05                	jmp    801282 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80127d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801282:	89 d0                	mov    %edx,%eax
  801284:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801287:	c9                   	leave  
  801288:	c3                   	ret    

00801289 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	57                   	push   %edi
  80128d:	56                   	push   %esi
  80128e:	53                   	push   %ebx
  80128f:	83 ec 0c             	sub    $0xc,%esp
  801292:	8b 7d 08             	mov    0x8(%ebp),%edi
  801295:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801298:	bb 00 00 00 00       	mov    $0x0,%ebx
  80129d:	eb 21                	jmp    8012c0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80129f:	83 ec 04             	sub    $0x4,%esp
  8012a2:	89 f0                	mov    %esi,%eax
  8012a4:	29 d8                	sub    %ebx,%eax
  8012a6:	50                   	push   %eax
  8012a7:	89 d8                	mov    %ebx,%eax
  8012a9:	03 45 0c             	add    0xc(%ebp),%eax
  8012ac:	50                   	push   %eax
  8012ad:	57                   	push   %edi
  8012ae:	e8 45 ff ff ff       	call   8011f8 <read>
		if (m < 0)
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	78 10                	js     8012ca <readn+0x41>
			return m;
		if (m == 0)
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	74 0a                	je     8012c8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012be:	01 c3                	add    %eax,%ebx
  8012c0:	39 f3                	cmp    %esi,%ebx
  8012c2:	72 db                	jb     80129f <readn+0x16>
  8012c4:	89 d8                	mov    %ebx,%eax
  8012c6:	eb 02                	jmp    8012ca <readn+0x41>
  8012c8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012cd:	5b                   	pop    %ebx
  8012ce:	5e                   	pop    %esi
  8012cf:	5f                   	pop    %edi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	53                   	push   %ebx
  8012d6:	83 ec 14             	sub    $0x14,%esp
  8012d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012df:	50                   	push   %eax
  8012e0:	53                   	push   %ebx
  8012e1:	e8 ac fc ff ff       	call   800f92 <fd_lookup>
  8012e6:	83 c4 08             	add    $0x8,%esp
  8012e9:	89 c2                	mov    %eax,%edx
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 68                	js     801357 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ef:	83 ec 08             	sub    $0x8,%esp
  8012f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f5:	50                   	push   %eax
  8012f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f9:	ff 30                	pushl  (%eax)
  8012fb:	e8 e8 fc ff ff       	call   800fe8 <dev_lookup>
  801300:	83 c4 10             	add    $0x10,%esp
  801303:	85 c0                	test   %eax,%eax
  801305:	78 47                	js     80134e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801307:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80130e:	75 21                	jne    801331 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801310:	a1 08 40 80 00       	mov    0x804008,%eax
  801315:	8b 40 48             	mov    0x48(%eax),%eax
  801318:	83 ec 04             	sub    $0x4,%esp
  80131b:	53                   	push   %ebx
  80131c:	50                   	push   %eax
  80131d:	68 89 24 80 00       	push   $0x802489
  801322:	e8 c7 ee ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80132f:	eb 26                	jmp    801357 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801331:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801334:	8b 52 0c             	mov    0xc(%edx),%edx
  801337:	85 d2                	test   %edx,%edx
  801339:	74 17                	je     801352 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80133b:	83 ec 04             	sub    $0x4,%esp
  80133e:	ff 75 10             	pushl  0x10(%ebp)
  801341:	ff 75 0c             	pushl  0xc(%ebp)
  801344:	50                   	push   %eax
  801345:	ff d2                	call   *%edx
  801347:	89 c2                	mov    %eax,%edx
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	eb 09                	jmp    801357 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134e:	89 c2                	mov    %eax,%edx
  801350:	eb 05                	jmp    801357 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801352:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801357:	89 d0                	mov    %edx,%eax
  801359:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135c:	c9                   	leave  
  80135d:	c3                   	ret    

0080135e <seek>:

int
seek(int fdnum, off_t offset)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801364:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801367:	50                   	push   %eax
  801368:	ff 75 08             	pushl  0x8(%ebp)
  80136b:	e8 22 fc ff ff       	call   800f92 <fd_lookup>
  801370:	83 c4 08             	add    $0x8,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	78 0e                	js     801385 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801377:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80137a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801380:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801385:	c9                   	leave  
  801386:	c3                   	ret    

00801387 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	53                   	push   %ebx
  80138b:	83 ec 14             	sub    $0x14,%esp
  80138e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801391:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801394:	50                   	push   %eax
  801395:	53                   	push   %ebx
  801396:	e8 f7 fb ff ff       	call   800f92 <fd_lookup>
  80139b:	83 c4 08             	add    $0x8,%esp
  80139e:	89 c2                	mov    %eax,%edx
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	78 65                	js     801409 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a4:	83 ec 08             	sub    $0x8,%esp
  8013a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013aa:	50                   	push   %eax
  8013ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ae:	ff 30                	pushl  (%eax)
  8013b0:	e8 33 fc ff ff       	call   800fe8 <dev_lookup>
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 44                	js     801400 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013bf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013c3:	75 21                	jne    8013e6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013c5:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013ca:	8b 40 48             	mov    0x48(%eax),%eax
  8013cd:	83 ec 04             	sub    $0x4,%esp
  8013d0:	53                   	push   %ebx
  8013d1:	50                   	push   %eax
  8013d2:	68 4c 24 80 00       	push   $0x80244c
  8013d7:	e8 12 ee ff ff       	call   8001ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013e4:	eb 23                	jmp    801409 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013e9:	8b 52 18             	mov    0x18(%edx),%edx
  8013ec:	85 d2                	test   %edx,%edx
  8013ee:	74 14                	je     801404 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013f0:	83 ec 08             	sub    $0x8,%esp
  8013f3:	ff 75 0c             	pushl  0xc(%ebp)
  8013f6:	50                   	push   %eax
  8013f7:	ff d2                	call   *%edx
  8013f9:	89 c2                	mov    %eax,%edx
  8013fb:	83 c4 10             	add    $0x10,%esp
  8013fe:	eb 09                	jmp    801409 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801400:	89 c2                	mov    %eax,%edx
  801402:	eb 05                	jmp    801409 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801404:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801409:	89 d0                	mov    %edx,%eax
  80140b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140e:	c9                   	leave  
  80140f:	c3                   	ret    

00801410 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	53                   	push   %ebx
  801414:	83 ec 14             	sub    $0x14,%esp
  801417:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141d:	50                   	push   %eax
  80141e:	ff 75 08             	pushl  0x8(%ebp)
  801421:	e8 6c fb ff ff       	call   800f92 <fd_lookup>
  801426:	83 c4 08             	add    $0x8,%esp
  801429:	89 c2                	mov    %eax,%edx
  80142b:	85 c0                	test   %eax,%eax
  80142d:	78 58                	js     801487 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142f:	83 ec 08             	sub    $0x8,%esp
  801432:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801435:	50                   	push   %eax
  801436:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801439:	ff 30                	pushl  (%eax)
  80143b:	e8 a8 fb ff ff       	call   800fe8 <dev_lookup>
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	85 c0                	test   %eax,%eax
  801445:	78 37                	js     80147e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801447:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80144e:	74 32                	je     801482 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801450:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801453:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80145a:	00 00 00 
	stat->st_isdir = 0;
  80145d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801464:	00 00 00 
	stat->st_dev = dev;
  801467:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80146d:	83 ec 08             	sub    $0x8,%esp
  801470:	53                   	push   %ebx
  801471:	ff 75 f0             	pushl  -0x10(%ebp)
  801474:	ff 50 14             	call   *0x14(%eax)
  801477:	89 c2                	mov    %eax,%edx
  801479:	83 c4 10             	add    $0x10,%esp
  80147c:	eb 09                	jmp    801487 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147e:	89 c2                	mov    %eax,%edx
  801480:	eb 05                	jmp    801487 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801482:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801487:	89 d0                	mov    %edx,%eax
  801489:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148c:	c9                   	leave  
  80148d:	c3                   	ret    

0080148e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	56                   	push   %esi
  801492:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801493:	83 ec 08             	sub    $0x8,%esp
  801496:	6a 00                	push   $0x0
  801498:	ff 75 08             	pushl  0x8(%ebp)
  80149b:	e8 2b 02 00 00       	call   8016cb <open>
  8014a0:	89 c3                	mov    %eax,%ebx
  8014a2:	83 c4 10             	add    $0x10,%esp
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 1b                	js     8014c4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014a9:	83 ec 08             	sub    $0x8,%esp
  8014ac:	ff 75 0c             	pushl  0xc(%ebp)
  8014af:	50                   	push   %eax
  8014b0:	e8 5b ff ff ff       	call   801410 <fstat>
  8014b5:	89 c6                	mov    %eax,%esi
	close(fd);
  8014b7:	89 1c 24             	mov    %ebx,(%esp)
  8014ba:	e8 fd fb ff ff       	call   8010bc <close>
	return r;
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	89 f0                	mov    %esi,%eax
}
  8014c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c7:	5b                   	pop    %ebx
  8014c8:	5e                   	pop    %esi
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    

008014cb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	56                   	push   %esi
  8014cf:	53                   	push   %ebx
  8014d0:	89 c6                	mov    %eax,%esi
  8014d2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014d4:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8014db:	75 12                	jne    8014ef <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014dd:	83 ec 0c             	sub    $0xc,%esp
  8014e0:	6a 01                	push   $0x1
  8014e2:	e8 26 08 00 00       	call   801d0d <ipc_find_env>
  8014e7:	a3 04 40 80 00       	mov    %eax,0x804004
  8014ec:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014ef:	6a 07                	push   $0x7
  8014f1:	68 00 50 80 00       	push   $0x805000
  8014f6:	56                   	push   %esi
  8014f7:	ff 35 04 40 80 00    	pushl  0x804004
  8014fd:	e8 b5 07 00 00       	call   801cb7 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801502:	83 c4 0c             	add    $0xc,%esp
  801505:	6a 00                	push   $0x0
  801507:	53                   	push   %ebx
  801508:	6a 00                	push   $0x0
  80150a:	e8 3f 07 00 00       	call   801c4e <ipc_recv>
}
  80150f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801512:	5b                   	pop    %ebx
  801513:	5e                   	pop    %esi
  801514:	5d                   	pop    %ebp
  801515:	c3                   	ret    

00801516 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80151c:	8b 45 08             	mov    0x8(%ebp),%eax
  80151f:	8b 40 0c             	mov    0xc(%eax),%eax
  801522:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801527:	8b 45 0c             	mov    0xc(%ebp),%eax
  80152a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80152f:	ba 00 00 00 00       	mov    $0x0,%edx
  801534:	b8 02 00 00 00       	mov    $0x2,%eax
  801539:	e8 8d ff ff ff       	call   8014cb <fsipc>
}
  80153e:	c9                   	leave  
  80153f:	c3                   	ret    

00801540 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801546:	8b 45 08             	mov    0x8(%ebp),%eax
  801549:	8b 40 0c             	mov    0xc(%eax),%eax
  80154c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801551:	ba 00 00 00 00       	mov    $0x0,%edx
  801556:	b8 06 00 00 00       	mov    $0x6,%eax
  80155b:	e8 6b ff ff ff       	call   8014cb <fsipc>
}
  801560:	c9                   	leave  
  801561:	c3                   	ret    

00801562 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801562:	55                   	push   %ebp
  801563:	89 e5                	mov    %esp,%ebp
  801565:	53                   	push   %ebx
  801566:	83 ec 04             	sub    $0x4,%esp
  801569:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80156c:	8b 45 08             	mov    0x8(%ebp),%eax
  80156f:	8b 40 0c             	mov    0xc(%eax),%eax
  801572:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801577:	ba 00 00 00 00       	mov    $0x0,%edx
  80157c:	b8 05 00 00 00       	mov    $0x5,%eax
  801581:	e8 45 ff ff ff       	call   8014cb <fsipc>
  801586:	85 c0                	test   %eax,%eax
  801588:	78 2c                	js     8015b6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80158a:	83 ec 08             	sub    $0x8,%esp
  80158d:	68 00 50 80 00       	push   $0x805000
  801592:	53                   	push   %ebx
  801593:	e8 8a f2 ff ff       	call   800822 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801598:	a1 80 50 80 00       	mov    0x805080,%eax
  80159d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015a3:	a1 84 50 80 00       	mov    0x805084,%eax
  8015a8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015ae:	83 c4 10             	add    $0x10,%esp
  8015b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b9:	c9                   	leave  
  8015ba:	c3                   	ret    

008015bb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015bb:	55                   	push   %ebp
  8015bc:	89 e5                	mov    %esp,%ebp
  8015be:	53                   	push   %ebx
  8015bf:	83 ec 08             	sub    $0x8,%esp
  8015c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8015c5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015ca:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8015cf:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8015d8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  8015dd:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015e3:	53                   	push   %ebx
  8015e4:	ff 75 0c             	pushl  0xc(%ebp)
  8015e7:	68 08 50 80 00       	push   $0x805008
  8015ec:	e8 c3 f3 ff ff       	call   8009b4 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8015f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f6:	b8 04 00 00 00       	mov    $0x4,%eax
  8015fb:	e8 cb fe ff ff       	call   8014cb <fsipc>
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	85 c0                	test   %eax,%eax
  801605:	78 3d                	js     801644 <devfile_write+0x89>
		return r;

	assert(r <= n);
  801607:	39 d8                	cmp    %ebx,%eax
  801609:	76 19                	jbe    801624 <devfile_write+0x69>
  80160b:	68 b8 24 80 00       	push   $0x8024b8
  801610:	68 bf 24 80 00       	push   $0x8024bf
  801615:	68 9f 00 00 00       	push   $0x9f
  80161a:	68 d4 24 80 00       	push   $0x8024d4
  80161f:	e8 f1 ea ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801624:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801629:	76 19                	jbe    801644 <devfile_write+0x89>
  80162b:	68 ec 24 80 00       	push   $0x8024ec
  801630:	68 bf 24 80 00       	push   $0x8024bf
  801635:	68 a0 00 00 00       	push   $0xa0
  80163a:	68 d4 24 80 00       	push   $0x8024d4
  80163f:	e8 d1 ea ff ff       	call   800115 <_panic>

	return r;
}
  801644:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801647:	c9                   	leave  
  801648:	c3                   	ret    

00801649 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	56                   	push   %esi
  80164d:	53                   	push   %ebx
  80164e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801651:	8b 45 08             	mov    0x8(%ebp),%eax
  801654:	8b 40 0c             	mov    0xc(%eax),%eax
  801657:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80165c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801662:	ba 00 00 00 00       	mov    $0x0,%edx
  801667:	b8 03 00 00 00       	mov    $0x3,%eax
  80166c:	e8 5a fe ff ff       	call   8014cb <fsipc>
  801671:	89 c3                	mov    %eax,%ebx
  801673:	85 c0                	test   %eax,%eax
  801675:	78 4b                	js     8016c2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801677:	39 c6                	cmp    %eax,%esi
  801679:	73 16                	jae    801691 <devfile_read+0x48>
  80167b:	68 b8 24 80 00       	push   $0x8024b8
  801680:	68 bf 24 80 00       	push   $0x8024bf
  801685:	6a 7e                	push   $0x7e
  801687:	68 d4 24 80 00       	push   $0x8024d4
  80168c:	e8 84 ea ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  801691:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801696:	7e 16                	jle    8016ae <devfile_read+0x65>
  801698:	68 df 24 80 00       	push   $0x8024df
  80169d:	68 bf 24 80 00       	push   $0x8024bf
  8016a2:	6a 7f                	push   $0x7f
  8016a4:	68 d4 24 80 00       	push   $0x8024d4
  8016a9:	e8 67 ea ff ff       	call   800115 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016ae:	83 ec 04             	sub    $0x4,%esp
  8016b1:	50                   	push   %eax
  8016b2:	68 00 50 80 00       	push   $0x805000
  8016b7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ba:	e8 f5 f2 ff ff       	call   8009b4 <memmove>
	return r;
  8016bf:	83 c4 10             	add    $0x10,%esp
}
  8016c2:	89 d8                	mov    %ebx,%eax
  8016c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c7:	5b                   	pop    %ebx
  8016c8:	5e                   	pop    %esi
  8016c9:	5d                   	pop    %ebp
  8016ca:	c3                   	ret    

008016cb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	53                   	push   %ebx
  8016cf:	83 ec 20             	sub    $0x20,%esp
  8016d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016d5:	53                   	push   %ebx
  8016d6:	e8 0e f1 ff ff       	call   8007e9 <strlen>
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016e3:	7f 67                	jg     80174c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016e5:	83 ec 0c             	sub    $0xc,%esp
  8016e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016eb:	50                   	push   %eax
  8016ec:	e8 52 f8 ff ff       	call   800f43 <fd_alloc>
  8016f1:	83 c4 10             	add    $0x10,%esp
		return r;
  8016f4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 57                	js     801751 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016fa:	83 ec 08             	sub    $0x8,%esp
  8016fd:	53                   	push   %ebx
  8016fe:	68 00 50 80 00       	push   $0x805000
  801703:	e8 1a f1 ff ff       	call   800822 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801708:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801710:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801713:	b8 01 00 00 00       	mov    $0x1,%eax
  801718:	e8 ae fd ff ff       	call   8014cb <fsipc>
  80171d:	89 c3                	mov    %eax,%ebx
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	85 c0                	test   %eax,%eax
  801724:	79 14                	jns    80173a <open+0x6f>
		fd_close(fd, 0);
  801726:	83 ec 08             	sub    $0x8,%esp
  801729:	6a 00                	push   $0x0
  80172b:	ff 75 f4             	pushl  -0xc(%ebp)
  80172e:	e8 08 f9 ff ff       	call   80103b <fd_close>
		return r;
  801733:	83 c4 10             	add    $0x10,%esp
  801736:	89 da                	mov    %ebx,%edx
  801738:	eb 17                	jmp    801751 <open+0x86>
	}

	return fd2num(fd);
  80173a:	83 ec 0c             	sub    $0xc,%esp
  80173d:	ff 75 f4             	pushl  -0xc(%ebp)
  801740:	e8 d7 f7 ff ff       	call   800f1c <fd2num>
  801745:	89 c2                	mov    %eax,%edx
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	eb 05                	jmp    801751 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80174c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801751:	89 d0                	mov    %edx,%eax
  801753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80175e:	ba 00 00 00 00       	mov    $0x0,%edx
  801763:	b8 08 00 00 00       	mov    $0x8,%eax
  801768:	e8 5e fd ff ff       	call   8014cb <fsipc>
}
  80176d:	c9                   	leave  
  80176e:	c3                   	ret    

0080176f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	56                   	push   %esi
  801773:	53                   	push   %ebx
  801774:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801777:	83 ec 0c             	sub    $0xc,%esp
  80177a:	ff 75 08             	pushl  0x8(%ebp)
  80177d:	e8 aa f7 ff ff       	call   800f2c <fd2data>
  801782:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801784:	83 c4 08             	add    $0x8,%esp
  801787:	68 19 25 80 00       	push   $0x802519
  80178c:	53                   	push   %ebx
  80178d:	e8 90 f0 ff ff       	call   800822 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801792:	8b 46 04             	mov    0x4(%esi),%eax
  801795:	2b 06                	sub    (%esi),%eax
  801797:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80179d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017a4:	00 00 00 
	stat->st_dev = &devpipe;
  8017a7:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8017ae:	30 80 00 
	return 0;
}
  8017b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b9:	5b                   	pop    %ebx
  8017ba:	5e                   	pop    %esi
  8017bb:	5d                   	pop    %ebp
  8017bc:	c3                   	ret    

008017bd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	53                   	push   %ebx
  8017c1:	83 ec 0c             	sub    $0xc,%esp
  8017c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017c7:	53                   	push   %ebx
  8017c8:	6a 00                	push   $0x0
  8017ca:	e8 52 f5 ff ff       	call   800d21 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017cf:	89 1c 24             	mov    %ebx,(%esp)
  8017d2:	e8 55 f7 ff ff       	call   800f2c <fd2data>
  8017d7:	83 c4 08             	add    $0x8,%esp
  8017da:	50                   	push   %eax
  8017db:	6a 00                	push   $0x0
  8017dd:	e8 3f f5 ff ff       	call   800d21 <sys_page_unmap>
}
  8017e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	57                   	push   %edi
  8017eb:	56                   	push   %esi
  8017ec:	53                   	push   %ebx
  8017ed:	83 ec 1c             	sub    $0x1c,%esp
  8017f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017f3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017f5:	a1 08 40 80 00       	mov    0x804008,%eax
  8017fa:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8017fd:	83 ec 0c             	sub    $0xc,%esp
  801800:	ff 75 e0             	pushl  -0x20(%ebp)
  801803:	e8 3e 05 00 00       	call   801d46 <pageref>
  801808:	89 c3                	mov    %eax,%ebx
  80180a:	89 3c 24             	mov    %edi,(%esp)
  80180d:	e8 34 05 00 00       	call   801d46 <pageref>
  801812:	83 c4 10             	add    $0x10,%esp
  801815:	39 c3                	cmp    %eax,%ebx
  801817:	0f 94 c1             	sete   %cl
  80181a:	0f b6 c9             	movzbl %cl,%ecx
  80181d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801820:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801826:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801829:	39 ce                	cmp    %ecx,%esi
  80182b:	74 1b                	je     801848 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80182d:	39 c3                	cmp    %eax,%ebx
  80182f:	75 c4                	jne    8017f5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801831:	8b 42 58             	mov    0x58(%edx),%eax
  801834:	ff 75 e4             	pushl  -0x1c(%ebp)
  801837:	50                   	push   %eax
  801838:	56                   	push   %esi
  801839:	68 20 25 80 00       	push   $0x802520
  80183e:	e8 ab e9 ff ff       	call   8001ee <cprintf>
  801843:	83 c4 10             	add    $0x10,%esp
  801846:	eb ad                	jmp    8017f5 <_pipeisclosed+0xe>
	}
}
  801848:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80184b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80184e:	5b                   	pop    %ebx
  80184f:	5e                   	pop    %esi
  801850:	5f                   	pop    %edi
  801851:	5d                   	pop    %ebp
  801852:	c3                   	ret    

00801853 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	57                   	push   %edi
  801857:	56                   	push   %esi
  801858:	53                   	push   %ebx
  801859:	83 ec 28             	sub    $0x28,%esp
  80185c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80185f:	56                   	push   %esi
  801860:	e8 c7 f6 ff ff       	call   800f2c <fd2data>
  801865:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	bf 00 00 00 00       	mov    $0x0,%edi
  80186f:	eb 4b                	jmp    8018bc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801871:	89 da                	mov    %ebx,%edx
  801873:	89 f0                	mov    %esi,%eax
  801875:	e8 6d ff ff ff       	call   8017e7 <_pipeisclosed>
  80187a:	85 c0                	test   %eax,%eax
  80187c:	75 48                	jne    8018c6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80187e:	e8 fa f3 ff ff       	call   800c7d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801883:	8b 43 04             	mov    0x4(%ebx),%eax
  801886:	8b 0b                	mov    (%ebx),%ecx
  801888:	8d 51 20             	lea    0x20(%ecx),%edx
  80188b:	39 d0                	cmp    %edx,%eax
  80188d:	73 e2                	jae    801871 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80188f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801892:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801896:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801899:	89 c2                	mov    %eax,%edx
  80189b:	c1 fa 1f             	sar    $0x1f,%edx
  80189e:	89 d1                	mov    %edx,%ecx
  8018a0:	c1 e9 1b             	shr    $0x1b,%ecx
  8018a3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8018a6:	83 e2 1f             	and    $0x1f,%edx
  8018a9:	29 ca                	sub    %ecx,%edx
  8018ab:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8018af:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018b3:	83 c0 01             	add    $0x1,%eax
  8018b6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018b9:	83 c7 01             	add    $0x1,%edi
  8018bc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018bf:	75 c2                	jne    801883 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8018c4:	eb 05                	jmp    8018cb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018c6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ce:	5b                   	pop    %ebx
  8018cf:	5e                   	pop    %esi
  8018d0:	5f                   	pop    %edi
  8018d1:	5d                   	pop    %ebp
  8018d2:	c3                   	ret    

008018d3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	57                   	push   %edi
  8018d7:	56                   	push   %esi
  8018d8:	53                   	push   %ebx
  8018d9:	83 ec 18             	sub    $0x18,%esp
  8018dc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018df:	57                   	push   %edi
  8018e0:	e8 47 f6 ff ff       	call   800f2c <fd2data>
  8018e5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018ef:	eb 3d                	jmp    80192e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018f1:	85 db                	test   %ebx,%ebx
  8018f3:	74 04                	je     8018f9 <devpipe_read+0x26>
				return i;
  8018f5:	89 d8                	mov    %ebx,%eax
  8018f7:	eb 44                	jmp    80193d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018f9:	89 f2                	mov    %esi,%edx
  8018fb:	89 f8                	mov    %edi,%eax
  8018fd:	e8 e5 fe ff ff       	call   8017e7 <_pipeisclosed>
  801902:	85 c0                	test   %eax,%eax
  801904:	75 32                	jne    801938 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801906:	e8 72 f3 ff ff       	call   800c7d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80190b:	8b 06                	mov    (%esi),%eax
  80190d:	3b 46 04             	cmp    0x4(%esi),%eax
  801910:	74 df                	je     8018f1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801912:	99                   	cltd   
  801913:	c1 ea 1b             	shr    $0x1b,%edx
  801916:	01 d0                	add    %edx,%eax
  801918:	83 e0 1f             	and    $0x1f,%eax
  80191b:	29 d0                	sub    %edx,%eax
  80191d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801922:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801925:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801928:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80192b:	83 c3 01             	add    $0x1,%ebx
  80192e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801931:	75 d8                	jne    80190b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801933:	8b 45 10             	mov    0x10(%ebp),%eax
  801936:	eb 05                	jmp    80193d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801938:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80193d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801940:	5b                   	pop    %ebx
  801941:	5e                   	pop    %esi
  801942:	5f                   	pop    %edi
  801943:	5d                   	pop    %ebp
  801944:	c3                   	ret    

00801945 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	56                   	push   %esi
  801949:	53                   	push   %ebx
  80194a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80194d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801950:	50                   	push   %eax
  801951:	e8 ed f5 ff ff       	call   800f43 <fd_alloc>
  801956:	83 c4 10             	add    $0x10,%esp
  801959:	89 c2                	mov    %eax,%edx
  80195b:	85 c0                	test   %eax,%eax
  80195d:	0f 88 2c 01 00 00    	js     801a8f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801963:	83 ec 04             	sub    $0x4,%esp
  801966:	68 07 04 00 00       	push   $0x407
  80196b:	ff 75 f4             	pushl  -0xc(%ebp)
  80196e:	6a 00                	push   $0x0
  801970:	e8 27 f3 ff ff       	call   800c9c <sys_page_alloc>
  801975:	83 c4 10             	add    $0x10,%esp
  801978:	89 c2                	mov    %eax,%edx
  80197a:	85 c0                	test   %eax,%eax
  80197c:	0f 88 0d 01 00 00    	js     801a8f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801982:	83 ec 0c             	sub    $0xc,%esp
  801985:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801988:	50                   	push   %eax
  801989:	e8 b5 f5 ff ff       	call   800f43 <fd_alloc>
  80198e:	89 c3                	mov    %eax,%ebx
  801990:	83 c4 10             	add    $0x10,%esp
  801993:	85 c0                	test   %eax,%eax
  801995:	0f 88 e2 00 00 00    	js     801a7d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80199b:	83 ec 04             	sub    $0x4,%esp
  80199e:	68 07 04 00 00       	push   $0x407
  8019a3:	ff 75 f0             	pushl  -0x10(%ebp)
  8019a6:	6a 00                	push   $0x0
  8019a8:	e8 ef f2 ff ff       	call   800c9c <sys_page_alloc>
  8019ad:	89 c3                	mov    %eax,%ebx
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	85 c0                	test   %eax,%eax
  8019b4:	0f 88 c3 00 00 00    	js     801a7d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019ba:	83 ec 0c             	sub    $0xc,%esp
  8019bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c0:	e8 67 f5 ff ff       	call   800f2c <fd2data>
  8019c5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c7:	83 c4 0c             	add    $0xc,%esp
  8019ca:	68 07 04 00 00       	push   $0x407
  8019cf:	50                   	push   %eax
  8019d0:	6a 00                	push   $0x0
  8019d2:	e8 c5 f2 ff ff       	call   800c9c <sys_page_alloc>
  8019d7:	89 c3                	mov    %eax,%ebx
  8019d9:	83 c4 10             	add    $0x10,%esp
  8019dc:	85 c0                	test   %eax,%eax
  8019de:	0f 88 89 00 00 00    	js     801a6d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019e4:	83 ec 0c             	sub    $0xc,%esp
  8019e7:	ff 75 f0             	pushl  -0x10(%ebp)
  8019ea:	e8 3d f5 ff ff       	call   800f2c <fd2data>
  8019ef:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019f6:	50                   	push   %eax
  8019f7:	6a 00                	push   $0x0
  8019f9:	56                   	push   %esi
  8019fa:	6a 00                	push   $0x0
  8019fc:	e8 de f2 ff ff       	call   800cdf <sys_page_map>
  801a01:	89 c3                	mov    %eax,%ebx
  801a03:	83 c4 20             	add    $0x20,%esp
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 55                	js     801a5f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a0a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a13:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a18:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a1f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a28:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a2d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a34:	83 ec 0c             	sub    $0xc,%esp
  801a37:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3a:	e8 dd f4 ff ff       	call   800f1c <fd2num>
  801a3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a42:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a44:	83 c4 04             	add    $0x4,%esp
  801a47:	ff 75 f0             	pushl  -0x10(%ebp)
  801a4a:	e8 cd f4 ff ff       	call   800f1c <fd2num>
  801a4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a52:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a55:	83 c4 10             	add    $0x10,%esp
  801a58:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5d:	eb 30                	jmp    801a8f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a5f:	83 ec 08             	sub    $0x8,%esp
  801a62:	56                   	push   %esi
  801a63:	6a 00                	push   $0x0
  801a65:	e8 b7 f2 ff ff       	call   800d21 <sys_page_unmap>
  801a6a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a6d:	83 ec 08             	sub    $0x8,%esp
  801a70:	ff 75 f0             	pushl  -0x10(%ebp)
  801a73:	6a 00                	push   $0x0
  801a75:	e8 a7 f2 ff ff       	call   800d21 <sys_page_unmap>
  801a7a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a7d:	83 ec 08             	sub    $0x8,%esp
  801a80:	ff 75 f4             	pushl  -0xc(%ebp)
  801a83:	6a 00                	push   $0x0
  801a85:	e8 97 f2 ff ff       	call   800d21 <sys_page_unmap>
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a8f:	89 d0                	mov    %edx,%eax
  801a91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a94:	5b                   	pop    %ebx
  801a95:	5e                   	pop    %esi
  801a96:	5d                   	pop    %ebp
  801a97:	c3                   	ret    

00801a98 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa1:	50                   	push   %eax
  801aa2:	ff 75 08             	pushl  0x8(%ebp)
  801aa5:	e8 e8 f4 ff ff       	call   800f92 <fd_lookup>
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	78 18                	js     801ac9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ab1:	83 ec 0c             	sub    $0xc,%esp
  801ab4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab7:	e8 70 f4 ff ff       	call   800f2c <fd2data>
	return _pipeisclosed(fd, p);
  801abc:	89 c2                	mov    %eax,%edx
  801abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac1:	e8 21 fd ff ff       	call   8017e7 <_pipeisclosed>
  801ac6:	83 c4 10             	add    $0x10,%esp
}
  801ac9:	c9                   	leave  
  801aca:	c3                   	ret    

00801acb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ace:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad3:	5d                   	pop    %ebp
  801ad4:	c3                   	ret    

00801ad5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801adb:	68 38 25 80 00       	push   $0x802538
  801ae0:	ff 75 0c             	pushl  0xc(%ebp)
  801ae3:	e8 3a ed ff ff       	call   800822 <strcpy>
	return 0;
}
  801ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  801aed:	c9                   	leave  
  801aee:	c3                   	ret    

00801aef <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	57                   	push   %edi
  801af3:	56                   	push   %esi
  801af4:	53                   	push   %ebx
  801af5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801afb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b00:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b06:	eb 2d                	jmp    801b35 <devcons_write+0x46>
		m = n - tot;
  801b08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b0b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b0d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b10:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b15:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b18:	83 ec 04             	sub    $0x4,%esp
  801b1b:	53                   	push   %ebx
  801b1c:	03 45 0c             	add    0xc(%ebp),%eax
  801b1f:	50                   	push   %eax
  801b20:	57                   	push   %edi
  801b21:	e8 8e ee ff ff       	call   8009b4 <memmove>
		sys_cputs(buf, m);
  801b26:	83 c4 08             	add    $0x8,%esp
  801b29:	53                   	push   %ebx
  801b2a:	57                   	push   %edi
  801b2b:	e8 b0 f0 ff ff       	call   800be0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b30:	01 de                	add    %ebx,%esi
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	89 f0                	mov    %esi,%eax
  801b37:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b3a:	72 cc                	jb     801b08 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3f:	5b                   	pop    %ebx
  801b40:	5e                   	pop    %esi
  801b41:	5f                   	pop    %edi
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	83 ec 08             	sub    $0x8,%esp
  801b4a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801b4f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b53:	74 2a                	je     801b7f <devcons_read+0x3b>
  801b55:	eb 05                	jmp    801b5c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b57:	e8 21 f1 ff ff       	call   800c7d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b5c:	e8 9d f0 ff ff       	call   800bfe <sys_cgetc>
  801b61:	85 c0                	test   %eax,%eax
  801b63:	74 f2                	je     801b57 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b65:	85 c0                	test   %eax,%eax
  801b67:	78 16                	js     801b7f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b69:	83 f8 04             	cmp    $0x4,%eax
  801b6c:	74 0c                	je     801b7a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b71:	88 02                	mov    %al,(%edx)
	return 1;
  801b73:	b8 01 00 00 00       	mov    $0x1,%eax
  801b78:	eb 05                	jmp    801b7f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b7a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b7f:	c9                   	leave  
  801b80:	c3                   	ret    

00801b81 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b87:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b8d:	6a 01                	push   $0x1
  801b8f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b92:	50                   	push   %eax
  801b93:	e8 48 f0 ff ff       	call   800be0 <sys_cputs>
}
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	c9                   	leave  
  801b9c:	c3                   	ret    

00801b9d <getchar>:

int
getchar(void)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ba3:	6a 01                	push   $0x1
  801ba5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ba8:	50                   	push   %eax
  801ba9:	6a 00                	push   $0x0
  801bab:	e8 48 f6 ff ff       	call   8011f8 <read>
	if (r < 0)
  801bb0:	83 c4 10             	add    $0x10,%esp
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	78 0f                	js     801bc6 <getchar+0x29>
		return r;
	if (r < 1)
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	7e 06                	jle    801bc1 <getchar+0x24>
		return -E_EOF;
	return c;
  801bbb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801bbf:	eb 05                	jmp    801bc6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801bc1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801bc6:	c9                   	leave  
  801bc7:	c3                   	ret    

00801bc8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd1:	50                   	push   %eax
  801bd2:	ff 75 08             	pushl  0x8(%ebp)
  801bd5:	e8 b8 f3 ff ff       	call   800f92 <fd_lookup>
  801bda:	83 c4 10             	add    $0x10,%esp
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	78 11                	js     801bf2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bea:	39 10                	cmp    %edx,(%eax)
  801bec:	0f 94 c0             	sete   %al
  801bef:	0f b6 c0             	movzbl %al,%eax
}
  801bf2:	c9                   	leave  
  801bf3:	c3                   	ret    

00801bf4 <opencons>:

int
opencons(void)
{
  801bf4:	55                   	push   %ebp
  801bf5:	89 e5                	mov    %esp,%ebp
  801bf7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfd:	50                   	push   %eax
  801bfe:	e8 40 f3 ff ff       	call   800f43 <fd_alloc>
  801c03:	83 c4 10             	add    $0x10,%esp
		return r;
  801c06:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c08:	85 c0                	test   %eax,%eax
  801c0a:	78 3e                	js     801c4a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c0c:	83 ec 04             	sub    $0x4,%esp
  801c0f:	68 07 04 00 00       	push   $0x407
  801c14:	ff 75 f4             	pushl  -0xc(%ebp)
  801c17:	6a 00                	push   $0x0
  801c19:	e8 7e f0 ff ff       	call   800c9c <sys_page_alloc>
  801c1e:	83 c4 10             	add    $0x10,%esp
		return r;
  801c21:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c23:	85 c0                	test   %eax,%eax
  801c25:	78 23                	js     801c4a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c27:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c30:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c35:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c3c:	83 ec 0c             	sub    $0xc,%esp
  801c3f:	50                   	push   %eax
  801c40:	e8 d7 f2 ff ff       	call   800f1c <fd2num>
  801c45:	89 c2                	mov    %eax,%edx
  801c47:	83 c4 10             	add    $0x10,%esp
}
  801c4a:	89 d0                	mov    %edx,%eax
  801c4c:	c9                   	leave  
  801c4d:	c3                   	ret    

00801c4e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	56                   	push   %esi
  801c52:	53                   	push   %ebx
  801c53:	8b 75 08             	mov    0x8(%ebp),%esi
  801c56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801c5c:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801c5e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801c63:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801c66:	83 ec 0c             	sub    $0xc,%esp
  801c69:	50                   	push   %eax
  801c6a:	e8 dd f1 ff ff       	call   800e4c <sys_ipc_recv>
  801c6f:	83 c4 10             	add    $0x10,%esp
  801c72:	85 c0                	test   %eax,%eax
  801c74:	79 16                	jns    801c8c <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801c76:	85 f6                	test   %esi,%esi
  801c78:	74 06                	je     801c80 <ipc_recv+0x32>
			*from_env_store = 0;
  801c7a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801c80:	85 db                	test   %ebx,%ebx
  801c82:	74 2c                	je     801cb0 <ipc_recv+0x62>
			*perm_store = 0;
  801c84:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c8a:	eb 24                	jmp    801cb0 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801c8c:	85 f6                	test   %esi,%esi
  801c8e:	74 0a                	je     801c9a <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801c90:	a1 08 40 80 00       	mov    0x804008,%eax
  801c95:	8b 40 74             	mov    0x74(%eax),%eax
  801c98:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801c9a:	85 db                	test   %ebx,%ebx
  801c9c:	74 0a                	je     801ca8 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801c9e:	a1 08 40 80 00       	mov    0x804008,%eax
  801ca3:	8b 40 78             	mov    0x78(%eax),%eax
  801ca6:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801ca8:	a1 08 40 80 00       	mov    0x804008,%eax
  801cad:	8b 40 70             	mov    0x70(%eax),%eax
}
  801cb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb3:	5b                   	pop    %ebx
  801cb4:	5e                   	pop    %esi
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    

00801cb7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	57                   	push   %edi
  801cbb:	56                   	push   %esi
  801cbc:	53                   	push   %ebx
  801cbd:	83 ec 0c             	sub    $0xc,%esp
  801cc0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cc3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801cc9:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801ccb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801cd0:	0f 44 d8             	cmove  %eax,%ebx
  801cd3:	eb 1e                	jmp    801cf3 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801cd5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801cd8:	74 14                	je     801cee <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801cda:	83 ec 04             	sub    $0x4,%esp
  801cdd:	68 44 25 80 00       	push   $0x802544
  801ce2:	6a 44                	push   $0x44
  801ce4:	68 70 25 80 00       	push   $0x802570
  801ce9:	e8 27 e4 ff ff       	call   800115 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801cee:	e8 8a ef ff ff       	call   800c7d <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801cf3:	ff 75 14             	pushl  0x14(%ebp)
  801cf6:	53                   	push   %ebx
  801cf7:	56                   	push   %esi
  801cf8:	57                   	push   %edi
  801cf9:	e8 2b f1 ff ff       	call   800e29 <sys_ipc_try_send>
  801cfe:	83 c4 10             	add    $0x10,%esp
  801d01:	85 c0                	test   %eax,%eax
  801d03:	78 d0                	js     801cd5 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d08:	5b                   	pop    %ebx
  801d09:	5e                   	pop    %esi
  801d0a:	5f                   	pop    %edi
  801d0b:	5d                   	pop    %ebp
  801d0c:	c3                   	ret    

00801d0d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d0d:	55                   	push   %ebp
  801d0e:	89 e5                	mov    %esp,%ebp
  801d10:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d13:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d18:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d1b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d21:	8b 52 50             	mov    0x50(%edx),%edx
  801d24:	39 ca                	cmp    %ecx,%edx
  801d26:	75 0d                	jne    801d35 <ipc_find_env+0x28>
			return envs[i].env_id;
  801d28:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d2b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d30:	8b 40 48             	mov    0x48(%eax),%eax
  801d33:	eb 0f                	jmp    801d44 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d35:	83 c0 01             	add    $0x1,%eax
  801d38:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d3d:	75 d9                	jne    801d18 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d44:	5d                   	pop    %ebp
  801d45:	c3                   	ret    

00801d46 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d4c:	89 d0                	mov    %edx,%eax
  801d4e:	c1 e8 16             	shr    $0x16,%eax
  801d51:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d58:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d5d:	f6 c1 01             	test   $0x1,%cl
  801d60:	74 1d                	je     801d7f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d62:	c1 ea 0c             	shr    $0xc,%edx
  801d65:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d6c:	f6 c2 01             	test   $0x1,%dl
  801d6f:	74 0e                	je     801d7f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d71:	c1 ea 0c             	shr    $0xc,%edx
  801d74:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d7b:	ef 
  801d7c:	0f b7 c0             	movzwl %ax,%eax
}
  801d7f:	5d                   	pop    %ebp
  801d80:	c3                   	ret    
  801d81:	66 90                	xchg   %ax,%ax
  801d83:	66 90                	xchg   %ax,%ax
  801d85:	66 90                	xchg   %ax,%ax
  801d87:	66 90                	xchg   %ax,%ax
  801d89:	66 90                	xchg   %ax,%ax
  801d8b:	66 90                	xchg   %ax,%ax
  801d8d:	66 90                	xchg   %ax,%ax
  801d8f:	90                   	nop

00801d90 <__udivdi3>:
  801d90:	55                   	push   %ebp
  801d91:	57                   	push   %edi
  801d92:	56                   	push   %esi
  801d93:	53                   	push   %ebx
  801d94:	83 ec 1c             	sub    $0x1c,%esp
  801d97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801d9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801d9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801da3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801da7:	85 f6                	test   %esi,%esi
  801da9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dad:	89 ca                	mov    %ecx,%edx
  801daf:	89 f8                	mov    %edi,%eax
  801db1:	75 3d                	jne    801df0 <__udivdi3+0x60>
  801db3:	39 cf                	cmp    %ecx,%edi
  801db5:	0f 87 c5 00 00 00    	ja     801e80 <__udivdi3+0xf0>
  801dbb:	85 ff                	test   %edi,%edi
  801dbd:	89 fd                	mov    %edi,%ebp
  801dbf:	75 0b                	jne    801dcc <__udivdi3+0x3c>
  801dc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc6:	31 d2                	xor    %edx,%edx
  801dc8:	f7 f7                	div    %edi
  801dca:	89 c5                	mov    %eax,%ebp
  801dcc:	89 c8                	mov    %ecx,%eax
  801dce:	31 d2                	xor    %edx,%edx
  801dd0:	f7 f5                	div    %ebp
  801dd2:	89 c1                	mov    %eax,%ecx
  801dd4:	89 d8                	mov    %ebx,%eax
  801dd6:	89 cf                	mov    %ecx,%edi
  801dd8:	f7 f5                	div    %ebp
  801dda:	89 c3                	mov    %eax,%ebx
  801ddc:	89 d8                	mov    %ebx,%eax
  801dde:	89 fa                	mov    %edi,%edx
  801de0:	83 c4 1c             	add    $0x1c,%esp
  801de3:	5b                   	pop    %ebx
  801de4:	5e                   	pop    %esi
  801de5:	5f                   	pop    %edi
  801de6:	5d                   	pop    %ebp
  801de7:	c3                   	ret    
  801de8:	90                   	nop
  801de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801df0:	39 ce                	cmp    %ecx,%esi
  801df2:	77 74                	ja     801e68 <__udivdi3+0xd8>
  801df4:	0f bd fe             	bsr    %esi,%edi
  801df7:	83 f7 1f             	xor    $0x1f,%edi
  801dfa:	0f 84 98 00 00 00    	je     801e98 <__udivdi3+0x108>
  801e00:	bb 20 00 00 00       	mov    $0x20,%ebx
  801e05:	89 f9                	mov    %edi,%ecx
  801e07:	89 c5                	mov    %eax,%ebp
  801e09:	29 fb                	sub    %edi,%ebx
  801e0b:	d3 e6                	shl    %cl,%esi
  801e0d:	89 d9                	mov    %ebx,%ecx
  801e0f:	d3 ed                	shr    %cl,%ebp
  801e11:	89 f9                	mov    %edi,%ecx
  801e13:	d3 e0                	shl    %cl,%eax
  801e15:	09 ee                	or     %ebp,%esi
  801e17:	89 d9                	mov    %ebx,%ecx
  801e19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e1d:	89 d5                	mov    %edx,%ebp
  801e1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e23:	d3 ed                	shr    %cl,%ebp
  801e25:	89 f9                	mov    %edi,%ecx
  801e27:	d3 e2                	shl    %cl,%edx
  801e29:	89 d9                	mov    %ebx,%ecx
  801e2b:	d3 e8                	shr    %cl,%eax
  801e2d:	09 c2                	or     %eax,%edx
  801e2f:	89 d0                	mov    %edx,%eax
  801e31:	89 ea                	mov    %ebp,%edx
  801e33:	f7 f6                	div    %esi
  801e35:	89 d5                	mov    %edx,%ebp
  801e37:	89 c3                	mov    %eax,%ebx
  801e39:	f7 64 24 0c          	mull   0xc(%esp)
  801e3d:	39 d5                	cmp    %edx,%ebp
  801e3f:	72 10                	jb     801e51 <__udivdi3+0xc1>
  801e41:	8b 74 24 08          	mov    0x8(%esp),%esi
  801e45:	89 f9                	mov    %edi,%ecx
  801e47:	d3 e6                	shl    %cl,%esi
  801e49:	39 c6                	cmp    %eax,%esi
  801e4b:	73 07                	jae    801e54 <__udivdi3+0xc4>
  801e4d:	39 d5                	cmp    %edx,%ebp
  801e4f:	75 03                	jne    801e54 <__udivdi3+0xc4>
  801e51:	83 eb 01             	sub    $0x1,%ebx
  801e54:	31 ff                	xor    %edi,%edi
  801e56:	89 d8                	mov    %ebx,%eax
  801e58:	89 fa                	mov    %edi,%edx
  801e5a:	83 c4 1c             	add    $0x1c,%esp
  801e5d:	5b                   	pop    %ebx
  801e5e:	5e                   	pop    %esi
  801e5f:	5f                   	pop    %edi
  801e60:	5d                   	pop    %ebp
  801e61:	c3                   	ret    
  801e62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e68:	31 ff                	xor    %edi,%edi
  801e6a:	31 db                	xor    %ebx,%ebx
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
  801e80:	89 d8                	mov    %ebx,%eax
  801e82:	f7 f7                	div    %edi
  801e84:	31 ff                	xor    %edi,%edi
  801e86:	89 c3                	mov    %eax,%ebx
  801e88:	89 d8                	mov    %ebx,%eax
  801e8a:	89 fa                	mov    %edi,%edx
  801e8c:	83 c4 1c             	add    $0x1c,%esp
  801e8f:	5b                   	pop    %ebx
  801e90:	5e                   	pop    %esi
  801e91:	5f                   	pop    %edi
  801e92:	5d                   	pop    %ebp
  801e93:	c3                   	ret    
  801e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e98:	39 ce                	cmp    %ecx,%esi
  801e9a:	72 0c                	jb     801ea8 <__udivdi3+0x118>
  801e9c:	31 db                	xor    %ebx,%ebx
  801e9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ea2:	0f 87 34 ff ff ff    	ja     801ddc <__udivdi3+0x4c>
  801ea8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ead:	e9 2a ff ff ff       	jmp    801ddc <__udivdi3+0x4c>
  801eb2:	66 90                	xchg   %ax,%ax
  801eb4:	66 90                	xchg   %ax,%ax
  801eb6:	66 90                	xchg   %ax,%ax
  801eb8:	66 90                	xchg   %ax,%ax
  801eba:	66 90                	xchg   %ax,%ax
  801ebc:	66 90                	xchg   %ax,%ax
  801ebe:	66 90                	xchg   %ax,%ax

00801ec0 <__umoddi3>:
  801ec0:	55                   	push   %ebp
  801ec1:	57                   	push   %edi
  801ec2:	56                   	push   %esi
  801ec3:	53                   	push   %ebx
  801ec4:	83 ec 1c             	sub    $0x1c,%esp
  801ec7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ecb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ecf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ed3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ed7:	85 d2                	test   %edx,%edx
  801ed9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801edd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ee1:	89 f3                	mov    %esi,%ebx
  801ee3:	89 3c 24             	mov    %edi,(%esp)
  801ee6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eea:	75 1c                	jne    801f08 <__umoddi3+0x48>
  801eec:	39 f7                	cmp    %esi,%edi
  801eee:	76 50                	jbe    801f40 <__umoddi3+0x80>
  801ef0:	89 c8                	mov    %ecx,%eax
  801ef2:	89 f2                	mov    %esi,%edx
  801ef4:	f7 f7                	div    %edi
  801ef6:	89 d0                	mov    %edx,%eax
  801ef8:	31 d2                	xor    %edx,%edx
  801efa:	83 c4 1c             	add    $0x1c,%esp
  801efd:	5b                   	pop    %ebx
  801efe:	5e                   	pop    %esi
  801eff:	5f                   	pop    %edi
  801f00:	5d                   	pop    %ebp
  801f01:	c3                   	ret    
  801f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f08:	39 f2                	cmp    %esi,%edx
  801f0a:	89 d0                	mov    %edx,%eax
  801f0c:	77 52                	ja     801f60 <__umoddi3+0xa0>
  801f0e:	0f bd ea             	bsr    %edx,%ebp
  801f11:	83 f5 1f             	xor    $0x1f,%ebp
  801f14:	75 5a                	jne    801f70 <__umoddi3+0xb0>
  801f16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801f1a:	0f 82 e0 00 00 00    	jb     802000 <__umoddi3+0x140>
  801f20:	39 0c 24             	cmp    %ecx,(%esp)
  801f23:	0f 86 d7 00 00 00    	jbe    802000 <__umoddi3+0x140>
  801f29:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f31:	83 c4 1c             	add    $0x1c,%esp
  801f34:	5b                   	pop    %ebx
  801f35:	5e                   	pop    %esi
  801f36:	5f                   	pop    %edi
  801f37:	5d                   	pop    %ebp
  801f38:	c3                   	ret    
  801f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f40:	85 ff                	test   %edi,%edi
  801f42:	89 fd                	mov    %edi,%ebp
  801f44:	75 0b                	jne    801f51 <__umoddi3+0x91>
  801f46:	b8 01 00 00 00       	mov    $0x1,%eax
  801f4b:	31 d2                	xor    %edx,%edx
  801f4d:	f7 f7                	div    %edi
  801f4f:	89 c5                	mov    %eax,%ebp
  801f51:	89 f0                	mov    %esi,%eax
  801f53:	31 d2                	xor    %edx,%edx
  801f55:	f7 f5                	div    %ebp
  801f57:	89 c8                	mov    %ecx,%eax
  801f59:	f7 f5                	div    %ebp
  801f5b:	89 d0                	mov    %edx,%eax
  801f5d:	eb 99                	jmp    801ef8 <__umoddi3+0x38>
  801f5f:	90                   	nop
  801f60:	89 c8                	mov    %ecx,%eax
  801f62:	89 f2                	mov    %esi,%edx
  801f64:	83 c4 1c             	add    $0x1c,%esp
  801f67:	5b                   	pop    %ebx
  801f68:	5e                   	pop    %esi
  801f69:	5f                   	pop    %edi
  801f6a:	5d                   	pop    %ebp
  801f6b:	c3                   	ret    
  801f6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f70:	8b 34 24             	mov    (%esp),%esi
  801f73:	bf 20 00 00 00       	mov    $0x20,%edi
  801f78:	89 e9                	mov    %ebp,%ecx
  801f7a:	29 ef                	sub    %ebp,%edi
  801f7c:	d3 e0                	shl    %cl,%eax
  801f7e:	89 f9                	mov    %edi,%ecx
  801f80:	89 f2                	mov    %esi,%edx
  801f82:	d3 ea                	shr    %cl,%edx
  801f84:	89 e9                	mov    %ebp,%ecx
  801f86:	09 c2                	or     %eax,%edx
  801f88:	89 d8                	mov    %ebx,%eax
  801f8a:	89 14 24             	mov    %edx,(%esp)
  801f8d:	89 f2                	mov    %esi,%edx
  801f8f:	d3 e2                	shl    %cl,%edx
  801f91:	89 f9                	mov    %edi,%ecx
  801f93:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f9b:	d3 e8                	shr    %cl,%eax
  801f9d:	89 e9                	mov    %ebp,%ecx
  801f9f:	89 c6                	mov    %eax,%esi
  801fa1:	d3 e3                	shl    %cl,%ebx
  801fa3:	89 f9                	mov    %edi,%ecx
  801fa5:	89 d0                	mov    %edx,%eax
  801fa7:	d3 e8                	shr    %cl,%eax
  801fa9:	89 e9                	mov    %ebp,%ecx
  801fab:	09 d8                	or     %ebx,%eax
  801fad:	89 d3                	mov    %edx,%ebx
  801faf:	89 f2                	mov    %esi,%edx
  801fb1:	f7 34 24             	divl   (%esp)
  801fb4:	89 d6                	mov    %edx,%esi
  801fb6:	d3 e3                	shl    %cl,%ebx
  801fb8:	f7 64 24 04          	mull   0x4(%esp)
  801fbc:	39 d6                	cmp    %edx,%esi
  801fbe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fc2:	89 d1                	mov    %edx,%ecx
  801fc4:	89 c3                	mov    %eax,%ebx
  801fc6:	72 08                	jb     801fd0 <__umoddi3+0x110>
  801fc8:	75 11                	jne    801fdb <__umoddi3+0x11b>
  801fca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801fce:	73 0b                	jae    801fdb <__umoddi3+0x11b>
  801fd0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801fd4:	1b 14 24             	sbb    (%esp),%edx
  801fd7:	89 d1                	mov    %edx,%ecx
  801fd9:	89 c3                	mov    %eax,%ebx
  801fdb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801fdf:	29 da                	sub    %ebx,%edx
  801fe1:	19 ce                	sbb    %ecx,%esi
  801fe3:	89 f9                	mov    %edi,%ecx
  801fe5:	89 f0                	mov    %esi,%eax
  801fe7:	d3 e0                	shl    %cl,%eax
  801fe9:	89 e9                	mov    %ebp,%ecx
  801feb:	d3 ea                	shr    %cl,%edx
  801fed:	89 e9                	mov    %ebp,%ecx
  801fef:	d3 ee                	shr    %cl,%esi
  801ff1:	09 d0                	or     %edx,%eax
  801ff3:	89 f2                	mov    %esi,%edx
  801ff5:	83 c4 1c             	add    $0x1c,%esp
  801ff8:	5b                   	pop    %ebx
  801ff9:	5e                   	pop    %esi
  801ffa:	5f                   	pop    %edi
  801ffb:	5d                   	pop    %ebp
  801ffc:	c3                   	ret    
  801ffd:	8d 76 00             	lea    0x0(%esi),%esi
  802000:	29 f9                	sub    %edi,%ecx
  802002:	19 d6                	sbb    %edx,%esi
  802004:	89 74 24 04          	mov    %esi,0x4(%esp)
  802008:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80200c:	e9 18 ff ff ff       	jmp    801f29 <__umoddi3+0x69>
