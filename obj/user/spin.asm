
obj/user/spin.debug:     file format elf32-i386


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

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 20 23 80 00       	push   $0x802320
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 d4 0e 00 00       	call   800f1d <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 98 23 80 00       	push   $0x802398
  800058:	e8 4b 01 00 00       	call   8001a8 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 48 23 80 00       	push   $0x802348
  80006c:	e8 37 01 00 00       	call   8001a8 <cprintf>
	sys_yield();
  800071:	e8 c1 0b 00 00       	call   800c37 <sys_yield>
	sys_yield();
  800076:	e8 bc 0b 00 00       	call   800c37 <sys_yield>
	sys_yield();
  80007b:	e8 b7 0b 00 00       	call   800c37 <sys_yield>
	sys_yield();
  800080:	e8 b2 0b 00 00       	call   800c37 <sys_yield>
	sys_yield();
  800085:	e8 ad 0b 00 00       	call   800c37 <sys_yield>
	sys_yield();
  80008a:	e8 a8 0b 00 00       	call   800c37 <sys_yield>
	sys_yield();
  80008f:	e8 a3 0b 00 00       	call   800c37 <sys_yield>
	sys_yield();
  800094:	e8 9e 0b 00 00       	call   800c37 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 70 23 80 00 	movl   $0x802370,(%esp)
  8000a0:	e8 03 01 00 00       	call   8001a8 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 2a 0b 00 00       	call   800bd7 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
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
  8000c0:	e8 53 0b 00 00       	call   800c18 <sys_getenvid>
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
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

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
  800101:	e8 14 12 00 00       	call   80131a <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 c7 0a 00 00       	call   800bd7 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	53                   	push   %ebx
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011f:	8b 13                	mov    (%ebx),%edx
  800121:	8d 42 01             	lea    0x1(%edx),%eax
  800124:	89 03                	mov    %eax,(%ebx)
  800126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800129:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800132:	75 1a                	jne    80014e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	8d 43 08             	lea    0x8(%ebx),%eax
  80013f:	50                   	push   %eax
  800140:	e8 55 0a 00 00       	call   800b9a <sys_cputs>
		b->idx = 0;
  800145:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800160:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800167:	00 00 00 
	b.cnt = 0;
  80016a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800171:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800174:	ff 75 0c             	pushl  0xc(%ebp)
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	68 15 01 80 00       	push   $0x800115
  800186:	e8 54 01 00 00       	call   8002df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018b:	83 c4 08             	add    $0x8,%esp
  80018e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800194:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 fa 09 00 00       	call   800b9a <sys_cputs>

	return b.cnt;
}
  8001a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	50                   	push   %eax
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	e8 9d ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 1c             	sub    $0x1c,%esp
  8001c5:	89 c7                	mov    %eax,%edi
  8001c7:	89 d6                	mov    %edx,%esi
  8001c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001dd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e3:	39 d3                	cmp    %edx,%ebx
  8001e5:	72 05                	jb     8001ec <printnum+0x30>
  8001e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ea:	77 45                	ja     800231 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ec:	83 ec 0c             	sub    $0xc,%esp
  8001ef:	ff 75 18             	pushl  0x18(%ebp)
  8001f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f8:	53                   	push   %ebx
  8001f9:	ff 75 10             	pushl  0x10(%ebp)
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800202:	ff 75 e0             	pushl  -0x20(%ebp)
  800205:	ff 75 dc             	pushl  -0x24(%ebp)
  800208:	ff 75 d8             	pushl  -0x28(%ebp)
  80020b:	e8 80 1e 00 00       	call   802090 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 9e ff ff ff       	call   8001bc <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 18                	jmp    80023b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	pushl  0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb 03                	jmp    800234 <printnum+0x78>
  800231:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800234:	83 eb 01             	sub    $0x1,%ebx
  800237:	85 db                	test   %ebx,%ebx
  800239:	7f e8                	jg     800223 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023b:	83 ec 08             	sub    $0x8,%esp
  80023e:	56                   	push   %esi
  80023f:	83 ec 04             	sub    $0x4,%esp
  800242:	ff 75 e4             	pushl  -0x1c(%ebp)
  800245:	ff 75 e0             	pushl  -0x20(%ebp)
  800248:	ff 75 dc             	pushl  -0x24(%ebp)
  80024b:	ff 75 d8             	pushl  -0x28(%ebp)
  80024e:	e8 6d 1f 00 00       	call   8021c0 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 80 c0 23 80 00 	movsbl 0x8023c0(%eax),%eax
  80025d:	50                   	push   %eax
  80025e:	ff d7                	call   *%edi
}
  800260:	83 c4 10             	add    $0x10,%esp
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026e:	83 fa 01             	cmp    $0x1,%edx
  800271:	7e 0e                	jle    800281 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800273:	8b 10                	mov    (%eax),%edx
  800275:	8d 4a 08             	lea    0x8(%edx),%ecx
  800278:	89 08                	mov    %ecx,(%eax)
  80027a:	8b 02                	mov    (%edx),%eax
  80027c:	8b 52 04             	mov    0x4(%edx),%edx
  80027f:	eb 22                	jmp    8002a3 <getuint+0x38>
	else if (lflag)
  800281:	85 d2                	test   %edx,%edx
  800283:	74 10                	je     800295 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800285:	8b 10                	mov    (%eax),%edx
  800287:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028a:	89 08                	mov    %ecx,(%eax)
  80028c:	8b 02                	mov    (%edx),%eax
  80028e:	ba 00 00 00 00       	mov    $0x0,%edx
  800293:	eb 0e                	jmp    8002a3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800295:	8b 10                	mov    (%eax),%edx
  800297:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 02                	mov    (%edx),%eax
  80029e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ab:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b4:	73 0a                	jae    8002c0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002be:	88 02                	mov    %al,(%edx)
}
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cb:	50                   	push   %eax
  8002cc:	ff 75 10             	pushl  0x10(%ebp)
  8002cf:	ff 75 0c             	pushl  0xc(%ebp)
  8002d2:	ff 75 08             	pushl  0x8(%ebp)
  8002d5:	e8 05 00 00 00       	call   8002df <vprintfmt>
	va_end(ap);
}
  8002da:	83 c4 10             	add    $0x10,%esp
  8002dd:	c9                   	leave  
  8002de:	c3                   	ret    

008002df <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	57                   	push   %edi
  8002e3:	56                   	push   %esi
  8002e4:	53                   	push   %ebx
  8002e5:	83 ec 2c             	sub    $0x2c,%esp
  8002e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f1:	eb 12                	jmp    800305 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f3:	85 c0                	test   %eax,%eax
  8002f5:	0f 84 38 04 00 00    	je     800733 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	53                   	push   %ebx
  8002ff:	50                   	push   %eax
  800300:	ff d6                	call   *%esi
  800302:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800305:	83 c7 01             	add    $0x1,%edi
  800308:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80030c:	83 f8 25             	cmp    $0x25,%eax
  80030f:	75 e2                	jne    8002f3 <vprintfmt+0x14>
  800311:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800315:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80031c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800323:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80032a:	ba 00 00 00 00       	mov    $0x0,%edx
  80032f:	eb 07                	jmp    800338 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  800334:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8d 47 01             	lea    0x1(%edi),%eax
  80033b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033e:	0f b6 07             	movzbl (%edi),%eax
  800341:	0f b6 c8             	movzbl %al,%ecx
  800344:	83 e8 23             	sub    $0x23,%eax
  800347:	3c 55                	cmp    $0x55,%al
  800349:	0f 87 c9 03 00 00    	ja     800718 <vprintfmt+0x439>
  80034f:	0f b6 c0             	movzbl %al,%eax
  800352:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800360:	eb d6                	jmp    800338 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  800362:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  800369:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  80036f:	eb 94                	jmp    800305 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  800371:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  800378:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  80037e:	eb 85                	jmp    800305 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  800380:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  800387:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  80038d:	e9 73 ff ff ff       	jmp    800305 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  800392:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  800399:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  80039f:	e9 61 ff ff ff       	jmp    800305 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  8003a4:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  8003ab:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  8003b1:	e9 4f ff ff ff       	jmp    800305 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  8003b6:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  8003bd:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  8003c3:	e9 3d ff ff ff       	jmp    800305 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  8003c8:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  8003cf:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  8003d5:	e9 2b ff ff ff       	jmp    800305 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  8003da:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  8003e1:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8003e7:	e9 19 ff ff ff       	jmp    800305 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  8003ec:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  8003f3:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8003f9:	e9 07 ff ff ff       	jmp    800305 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8003fe:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  800405:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  80040b:	e9 f5 fe ff ff       	jmp    800305 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800413:	b8 00 00 00 00       	mov    $0x0,%eax
  800418:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80041b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80041e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800422:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800425:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800428:	83 fa 09             	cmp    $0x9,%edx
  80042b:	77 3f                	ja     80046c <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80042d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800430:	eb e9                	jmp    80041b <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8d 48 04             	lea    0x4(%eax),%ecx
  800438:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80043b:	8b 00                	mov    (%eax),%eax
  80043d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800443:	eb 2d                	jmp    800472 <vprintfmt+0x193>
  800445:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800448:	85 c0                	test   %eax,%eax
  80044a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80044f:	0f 49 c8             	cmovns %eax,%ecx
  800452:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800458:	e9 db fe ff ff       	jmp    800338 <vprintfmt+0x59>
  80045d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800460:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800467:	e9 cc fe ff ff       	jmp    800338 <vprintfmt+0x59>
  80046c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80046f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800472:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800476:	0f 89 bc fe ff ff    	jns    800338 <vprintfmt+0x59>
				width = precision, precision = -1;
  80047c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80047f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800482:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800489:	e9 aa fe ff ff       	jmp    800338 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800494:	e9 9f fe ff ff       	jmp    800338 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800499:	8b 45 14             	mov    0x14(%ebp),%eax
  80049c:	8d 50 04             	lea    0x4(%eax),%edx
  80049f:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	53                   	push   %ebx
  8004a6:	ff 30                	pushl  (%eax)
  8004a8:	ff d6                	call   *%esi
			break;
  8004aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b0:	e9 50 fe ff ff       	jmp    800305 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b8:	8d 50 04             	lea    0x4(%eax),%edx
  8004bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004be:	8b 00                	mov    (%eax),%eax
  8004c0:	99                   	cltd   
  8004c1:	31 d0                	xor    %edx,%eax
  8004c3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c5:	83 f8 0f             	cmp    $0xf,%eax
  8004c8:	7f 0b                	jg     8004d5 <vprintfmt+0x1f6>
  8004ca:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  8004d1:	85 d2                	test   %edx,%edx
  8004d3:	75 18                	jne    8004ed <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  8004d5:	50                   	push   %eax
  8004d6:	68 d8 23 80 00       	push   $0x8023d8
  8004db:	53                   	push   %ebx
  8004dc:	56                   	push   %esi
  8004dd:	e8 e0 fd ff ff       	call   8002c2 <printfmt>
  8004e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e8:	e9 18 fe ff ff       	jmp    800305 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004ed:	52                   	push   %edx
  8004ee:	68 45 28 80 00       	push   $0x802845
  8004f3:	53                   	push   %ebx
  8004f4:	56                   	push   %esi
  8004f5:	e8 c8 fd ff ff       	call   8002c2 <printfmt>
  8004fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800500:	e9 00 fe ff ff       	jmp    800305 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8d 50 04             	lea    0x4(%eax),%edx
  80050b:	89 55 14             	mov    %edx,0x14(%ebp)
  80050e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800510:	85 ff                	test   %edi,%edi
  800512:	b8 d1 23 80 00       	mov    $0x8023d1,%eax
  800517:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80051a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80051e:	0f 8e 94 00 00 00    	jle    8005b8 <vprintfmt+0x2d9>
  800524:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800528:	0f 84 98 00 00 00    	je     8005c6 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052e:	83 ec 08             	sub    $0x8,%esp
  800531:	ff 75 d0             	pushl  -0x30(%ebp)
  800534:	57                   	push   %edi
  800535:	e8 81 02 00 00       	call   8007bb <strnlen>
  80053a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80053d:	29 c1                	sub    %eax,%ecx
  80053f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800542:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800545:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800549:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80054f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800551:	eb 0f                	jmp    800562 <vprintfmt+0x283>
					putch(padc, putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	53                   	push   %ebx
  800557:	ff 75 e0             	pushl  -0x20(%ebp)
  80055a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055c:	83 ef 01             	sub    $0x1,%edi
  80055f:	83 c4 10             	add    $0x10,%esp
  800562:	85 ff                	test   %edi,%edi
  800564:	7f ed                	jg     800553 <vprintfmt+0x274>
  800566:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800569:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80056c:	85 c9                	test   %ecx,%ecx
  80056e:	b8 00 00 00 00       	mov    $0x0,%eax
  800573:	0f 49 c1             	cmovns %ecx,%eax
  800576:	29 c1                	sub    %eax,%ecx
  800578:	89 75 08             	mov    %esi,0x8(%ebp)
  80057b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80057e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800581:	89 cb                	mov    %ecx,%ebx
  800583:	eb 4d                	jmp    8005d2 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800585:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800589:	74 1b                	je     8005a6 <vprintfmt+0x2c7>
  80058b:	0f be c0             	movsbl %al,%eax
  80058e:	83 e8 20             	sub    $0x20,%eax
  800591:	83 f8 5e             	cmp    $0x5e,%eax
  800594:	76 10                	jbe    8005a6 <vprintfmt+0x2c7>
					putch('?', putdat);
  800596:	83 ec 08             	sub    $0x8,%esp
  800599:	ff 75 0c             	pushl  0xc(%ebp)
  80059c:	6a 3f                	push   $0x3f
  80059e:	ff 55 08             	call   *0x8(%ebp)
  8005a1:	83 c4 10             	add    $0x10,%esp
  8005a4:	eb 0d                	jmp    8005b3 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	ff 75 0c             	pushl  0xc(%ebp)
  8005ac:	52                   	push   %edx
  8005ad:	ff 55 08             	call   *0x8(%ebp)
  8005b0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b3:	83 eb 01             	sub    $0x1,%ebx
  8005b6:	eb 1a                	jmp    8005d2 <vprintfmt+0x2f3>
  8005b8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005bb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005be:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005c4:	eb 0c                	jmp    8005d2 <vprintfmt+0x2f3>
  8005c6:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005cc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005cf:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d2:	83 c7 01             	add    $0x1,%edi
  8005d5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005d9:	0f be d0             	movsbl %al,%edx
  8005dc:	85 d2                	test   %edx,%edx
  8005de:	74 23                	je     800603 <vprintfmt+0x324>
  8005e0:	85 f6                	test   %esi,%esi
  8005e2:	78 a1                	js     800585 <vprintfmt+0x2a6>
  8005e4:	83 ee 01             	sub    $0x1,%esi
  8005e7:	79 9c                	jns    800585 <vprintfmt+0x2a6>
  8005e9:	89 df                	mov    %ebx,%edi
  8005eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f1:	eb 18                	jmp    80060b <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f3:	83 ec 08             	sub    $0x8,%esp
  8005f6:	53                   	push   %ebx
  8005f7:	6a 20                	push   $0x20
  8005f9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005fb:	83 ef 01             	sub    $0x1,%edi
  8005fe:	83 c4 10             	add    $0x10,%esp
  800601:	eb 08                	jmp    80060b <vprintfmt+0x32c>
  800603:	89 df                	mov    %ebx,%edi
  800605:	8b 75 08             	mov    0x8(%ebp),%esi
  800608:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80060b:	85 ff                	test   %edi,%edi
  80060d:	7f e4                	jg     8005f3 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800612:	e9 ee fc ff ff       	jmp    800305 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800617:	83 fa 01             	cmp    $0x1,%edx
  80061a:	7e 16                	jle    800632 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 08             	lea    0x8(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)
  800625:	8b 50 04             	mov    0x4(%eax),%edx
  800628:	8b 00                	mov    (%eax),%eax
  80062a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800630:	eb 32                	jmp    800664 <vprintfmt+0x385>
	else if (lflag)
  800632:	85 d2                	test   %edx,%edx
  800634:	74 18                	je     80064e <vprintfmt+0x36f>
		return va_arg(*ap, long);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8d 50 04             	lea    0x4(%eax),%edx
  80063c:	89 55 14             	mov    %edx,0x14(%ebp)
  80063f:	8b 00                	mov    (%eax),%eax
  800641:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800644:	89 c1                	mov    %eax,%ecx
  800646:	c1 f9 1f             	sar    $0x1f,%ecx
  800649:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80064c:	eb 16                	jmp    800664 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 50 04             	lea    0x4(%eax),%edx
  800654:	89 55 14             	mov    %edx,0x14(%ebp)
  800657:	8b 00                	mov    (%eax),%eax
  800659:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065c:	89 c1                	mov    %eax,%ecx
  80065e:	c1 f9 1f             	sar    $0x1f,%ecx
  800661:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800664:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800667:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80066a:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80066f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800673:	79 6f                	jns    8006e4 <vprintfmt+0x405>
				putch('-', putdat);
  800675:	83 ec 08             	sub    $0x8,%esp
  800678:	53                   	push   %ebx
  800679:	6a 2d                	push   $0x2d
  80067b:	ff d6                	call   *%esi
				num = -(long long) num;
  80067d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800680:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800683:	f7 d8                	neg    %eax
  800685:	83 d2 00             	adc    $0x0,%edx
  800688:	f7 da                	neg    %edx
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	eb 55                	jmp    8006e4 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80068f:	8d 45 14             	lea    0x14(%ebp),%eax
  800692:	e8 d4 fb ff ff       	call   80026b <getuint>
			base = 10;
  800697:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80069c:	eb 46                	jmp    8006e4 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80069e:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a1:	e8 c5 fb ff ff       	call   80026b <getuint>
			base = 8;
  8006a6:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8006ab:	eb 37                	jmp    8006e4 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	6a 30                	push   $0x30
  8006b3:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b5:	83 c4 08             	add    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	6a 78                	push   $0x78
  8006bb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8d 50 04             	lea    0x4(%eax),%edx
  8006c3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006c6:	8b 00                	mov    (%eax),%eax
  8006c8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006cd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d0:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8006d5:	eb 0d                	jmp    8006e4 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006da:	e8 8c fb ff ff       	call   80026b <getuint>
			base = 16;
  8006df:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e4:	83 ec 0c             	sub    $0xc,%esp
  8006e7:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8006eb:	51                   	push   %ecx
  8006ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ef:	57                   	push   %edi
  8006f0:	52                   	push   %edx
  8006f1:	50                   	push   %eax
  8006f2:	89 da                	mov    %ebx,%edx
  8006f4:	89 f0                	mov    %esi,%eax
  8006f6:	e8 c1 fa ff ff       	call   8001bc <printnum>
			break;
  8006fb:	83 c4 20             	add    $0x20,%esp
  8006fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800701:	e9 ff fb ff ff       	jmp    800305 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800706:	83 ec 08             	sub    $0x8,%esp
  800709:	53                   	push   %ebx
  80070a:	51                   	push   %ecx
  80070b:	ff d6                	call   *%esi
			break;
  80070d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800710:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800713:	e9 ed fb ff ff       	jmp    800305 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800718:	83 ec 08             	sub    $0x8,%esp
  80071b:	53                   	push   %ebx
  80071c:	6a 25                	push   $0x25
  80071e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800720:	83 c4 10             	add    $0x10,%esp
  800723:	eb 03                	jmp    800728 <vprintfmt+0x449>
  800725:	83 ef 01             	sub    $0x1,%edi
  800728:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80072c:	75 f7                	jne    800725 <vprintfmt+0x446>
  80072e:	e9 d2 fb ff ff       	jmp    800305 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800733:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800736:	5b                   	pop    %ebx
  800737:	5e                   	pop    %esi
  800738:	5f                   	pop    %edi
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	83 ec 18             	sub    $0x18,%esp
  800741:	8b 45 08             	mov    0x8(%ebp),%eax
  800744:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800747:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800751:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800758:	85 c0                	test   %eax,%eax
  80075a:	74 26                	je     800782 <vsnprintf+0x47>
  80075c:	85 d2                	test   %edx,%edx
  80075e:	7e 22                	jle    800782 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800760:	ff 75 14             	pushl  0x14(%ebp)
  800763:	ff 75 10             	pushl  0x10(%ebp)
  800766:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800769:	50                   	push   %eax
  80076a:	68 a5 02 80 00       	push   $0x8002a5
  80076f:	e8 6b fb ff ff       	call   8002df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800774:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800777:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	eb 05                	jmp    800787 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800782:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800787:	c9                   	leave  
  800788:	c3                   	ret    

00800789 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800792:	50                   	push   %eax
  800793:	ff 75 10             	pushl  0x10(%ebp)
  800796:	ff 75 0c             	pushl  0xc(%ebp)
  800799:	ff 75 08             	pushl  0x8(%ebp)
  80079c:	e8 9a ff ff ff       	call   80073b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a1:	c9                   	leave  
  8007a2:	c3                   	ret    

008007a3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ae:	eb 03                	jmp    8007b3 <strlen+0x10>
		n++;
  8007b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b7:	75 f7                	jne    8007b0 <strlen+0xd>
		n++;
	return n;
}
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c9:	eb 03                	jmp    8007ce <strnlen+0x13>
		n++;
  8007cb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ce:	39 c2                	cmp    %eax,%edx
  8007d0:	74 08                	je     8007da <strnlen+0x1f>
  8007d2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007d6:	75 f3                	jne    8007cb <strnlen+0x10>
  8007d8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	53                   	push   %ebx
  8007e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e6:	89 c2                	mov    %eax,%edx
  8007e8:	83 c2 01             	add    $0x1,%edx
  8007eb:	83 c1 01             	add    $0x1,%ecx
  8007ee:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007f2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f5:	84 db                	test   %bl,%bl
  8007f7:	75 ef                	jne    8007e8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f9:	5b                   	pop    %ebx
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	53                   	push   %ebx
  800800:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800803:	53                   	push   %ebx
  800804:	e8 9a ff ff ff       	call   8007a3 <strlen>
  800809:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80080c:	ff 75 0c             	pushl  0xc(%ebp)
  80080f:	01 d8                	add    %ebx,%eax
  800811:	50                   	push   %eax
  800812:	e8 c5 ff ff ff       	call   8007dc <strcpy>
	return dst;
}
  800817:	89 d8                	mov    %ebx,%eax
  800819:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    

0080081e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	56                   	push   %esi
  800822:	53                   	push   %ebx
  800823:	8b 75 08             	mov    0x8(%ebp),%esi
  800826:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800829:	89 f3                	mov    %esi,%ebx
  80082b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082e:	89 f2                	mov    %esi,%edx
  800830:	eb 0f                	jmp    800841 <strncpy+0x23>
		*dst++ = *src;
  800832:	83 c2 01             	add    $0x1,%edx
  800835:	0f b6 01             	movzbl (%ecx),%eax
  800838:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083b:	80 39 01             	cmpb   $0x1,(%ecx)
  80083e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800841:	39 da                	cmp    %ebx,%edx
  800843:	75 ed                	jne    800832 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800845:	89 f0                	mov    %esi,%eax
  800847:	5b                   	pop    %ebx
  800848:	5e                   	pop    %esi
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	56                   	push   %esi
  80084f:	53                   	push   %ebx
  800850:	8b 75 08             	mov    0x8(%ebp),%esi
  800853:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800856:	8b 55 10             	mov    0x10(%ebp),%edx
  800859:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085b:	85 d2                	test   %edx,%edx
  80085d:	74 21                	je     800880 <strlcpy+0x35>
  80085f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800863:	89 f2                	mov    %esi,%edx
  800865:	eb 09                	jmp    800870 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800867:	83 c2 01             	add    $0x1,%edx
  80086a:	83 c1 01             	add    $0x1,%ecx
  80086d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800870:	39 c2                	cmp    %eax,%edx
  800872:	74 09                	je     80087d <strlcpy+0x32>
  800874:	0f b6 19             	movzbl (%ecx),%ebx
  800877:	84 db                	test   %bl,%bl
  800879:	75 ec                	jne    800867 <strlcpy+0x1c>
  80087b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80087d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800880:	29 f0                	sub    %esi,%eax
}
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088f:	eb 06                	jmp    800897 <strcmp+0x11>
		p++, q++;
  800891:	83 c1 01             	add    $0x1,%ecx
  800894:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800897:	0f b6 01             	movzbl (%ecx),%eax
  80089a:	84 c0                	test   %al,%al
  80089c:	74 04                	je     8008a2 <strcmp+0x1c>
  80089e:	3a 02                	cmp    (%edx),%al
  8008a0:	74 ef                	je     800891 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a2:	0f b6 c0             	movzbl %al,%eax
  8008a5:	0f b6 12             	movzbl (%edx),%edx
  8008a8:	29 d0                	sub    %edx,%eax
}
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	53                   	push   %ebx
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b6:	89 c3                	mov    %eax,%ebx
  8008b8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008bb:	eb 06                	jmp    8008c3 <strncmp+0x17>
		n--, p++, q++;
  8008bd:	83 c0 01             	add    $0x1,%eax
  8008c0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c3:	39 d8                	cmp    %ebx,%eax
  8008c5:	74 15                	je     8008dc <strncmp+0x30>
  8008c7:	0f b6 08             	movzbl (%eax),%ecx
  8008ca:	84 c9                	test   %cl,%cl
  8008cc:	74 04                	je     8008d2 <strncmp+0x26>
  8008ce:	3a 0a                	cmp    (%edx),%cl
  8008d0:	74 eb                	je     8008bd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d2:	0f b6 00             	movzbl (%eax),%eax
  8008d5:	0f b6 12             	movzbl (%edx),%edx
  8008d8:	29 d0                	sub    %edx,%eax
  8008da:	eb 05                	jmp    8008e1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e1:	5b                   	pop    %ebx
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ee:	eb 07                	jmp    8008f7 <strchr+0x13>
		if (*s == c)
  8008f0:	38 ca                	cmp    %cl,%dl
  8008f2:	74 0f                	je     800903 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f4:	83 c0 01             	add    $0x1,%eax
  8008f7:	0f b6 10             	movzbl (%eax),%edx
  8008fa:	84 d2                	test   %dl,%dl
  8008fc:	75 f2                	jne    8008f0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090f:	eb 03                	jmp    800914 <strfind+0xf>
  800911:	83 c0 01             	add    $0x1,%eax
  800914:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800917:	38 ca                	cmp    %cl,%dl
  800919:	74 04                	je     80091f <strfind+0x1a>
  80091b:	84 d2                	test   %dl,%dl
  80091d:	75 f2                	jne    800911 <strfind+0xc>
			break;
	return (char *) s;
}
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	57                   	push   %edi
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80092d:	85 c9                	test   %ecx,%ecx
  80092f:	74 36                	je     800967 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800931:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800937:	75 28                	jne    800961 <memset+0x40>
  800939:	f6 c1 03             	test   $0x3,%cl
  80093c:	75 23                	jne    800961 <memset+0x40>
		c &= 0xFF;
  80093e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800942:	89 d3                	mov    %edx,%ebx
  800944:	c1 e3 08             	shl    $0x8,%ebx
  800947:	89 d6                	mov    %edx,%esi
  800949:	c1 e6 18             	shl    $0x18,%esi
  80094c:	89 d0                	mov    %edx,%eax
  80094e:	c1 e0 10             	shl    $0x10,%eax
  800951:	09 f0                	or     %esi,%eax
  800953:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800955:	89 d8                	mov    %ebx,%eax
  800957:	09 d0                	or     %edx,%eax
  800959:	c1 e9 02             	shr    $0x2,%ecx
  80095c:	fc                   	cld    
  80095d:	f3 ab                	rep stos %eax,%es:(%edi)
  80095f:	eb 06                	jmp    800967 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800961:	8b 45 0c             	mov    0xc(%ebp),%eax
  800964:	fc                   	cld    
  800965:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800967:	89 f8                	mov    %edi,%eax
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	5f                   	pop    %edi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	57                   	push   %edi
  800972:	56                   	push   %esi
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8b 75 0c             	mov    0xc(%ebp),%esi
  800979:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097c:	39 c6                	cmp    %eax,%esi
  80097e:	73 35                	jae    8009b5 <memmove+0x47>
  800980:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800983:	39 d0                	cmp    %edx,%eax
  800985:	73 2e                	jae    8009b5 <memmove+0x47>
		s += n;
		d += n;
  800987:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098a:	89 d6                	mov    %edx,%esi
  80098c:	09 fe                	or     %edi,%esi
  80098e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800994:	75 13                	jne    8009a9 <memmove+0x3b>
  800996:	f6 c1 03             	test   $0x3,%cl
  800999:	75 0e                	jne    8009a9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80099b:	83 ef 04             	sub    $0x4,%edi
  80099e:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a1:	c1 e9 02             	shr    $0x2,%ecx
  8009a4:	fd                   	std    
  8009a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a7:	eb 09                	jmp    8009b2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a9:	83 ef 01             	sub    $0x1,%edi
  8009ac:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009af:	fd                   	std    
  8009b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b2:	fc                   	cld    
  8009b3:	eb 1d                	jmp    8009d2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b5:	89 f2                	mov    %esi,%edx
  8009b7:	09 c2                	or     %eax,%edx
  8009b9:	f6 c2 03             	test   $0x3,%dl
  8009bc:	75 0f                	jne    8009cd <memmove+0x5f>
  8009be:	f6 c1 03             	test   $0x3,%cl
  8009c1:	75 0a                	jne    8009cd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009c3:	c1 e9 02             	shr    $0x2,%ecx
  8009c6:	89 c7                	mov    %eax,%edi
  8009c8:	fc                   	cld    
  8009c9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cb:	eb 05                	jmp    8009d2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009cd:	89 c7                	mov    %eax,%edi
  8009cf:	fc                   	cld    
  8009d0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d2:	5e                   	pop    %esi
  8009d3:	5f                   	pop    %edi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d9:	ff 75 10             	pushl  0x10(%ebp)
  8009dc:	ff 75 0c             	pushl  0xc(%ebp)
  8009df:	ff 75 08             	pushl  0x8(%ebp)
  8009e2:	e8 87 ff ff ff       	call   80096e <memmove>
}
  8009e7:	c9                   	leave  
  8009e8:	c3                   	ret    

008009e9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	56                   	push   %esi
  8009ed:	53                   	push   %ebx
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f4:	89 c6                	mov    %eax,%esi
  8009f6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f9:	eb 1a                	jmp    800a15 <memcmp+0x2c>
		if (*s1 != *s2)
  8009fb:	0f b6 08             	movzbl (%eax),%ecx
  8009fe:	0f b6 1a             	movzbl (%edx),%ebx
  800a01:	38 d9                	cmp    %bl,%cl
  800a03:	74 0a                	je     800a0f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a05:	0f b6 c1             	movzbl %cl,%eax
  800a08:	0f b6 db             	movzbl %bl,%ebx
  800a0b:	29 d8                	sub    %ebx,%eax
  800a0d:	eb 0f                	jmp    800a1e <memcmp+0x35>
		s1++, s2++;
  800a0f:	83 c0 01             	add    $0x1,%eax
  800a12:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a15:	39 f0                	cmp    %esi,%eax
  800a17:	75 e2                	jne    8009fb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1e:	5b                   	pop    %ebx
  800a1f:	5e                   	pop    %esi
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	53                   	push   %ebx
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a29:	89 c1                	mov    %eax,%ecx
  800a2b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a32:	eb 0a                	jmp    800a3e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a34:	0f b6 10             	movzbl (%eax),%edx
  800a37:	39 da                	cmp    %ebx,%edx
  800a39:	74 07                	je     800a42 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3b:	83 c0 01             	add    $0x1,%eax
  800a3e:	39 c8                	cmp    %ecx,%eax
  800a40:	72 f2                	jb     800a34 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a42:	5b                   	pop    %ebx
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	57                   	push   %edi
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
  800a4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a51:	eb 03                	jmp    800a56 <strtol+0x11>
		s++;
  800a53:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a56:	0f b6 01             	movzbl (%ecx),%eax
  800a59:	3c 20                	cmp    $0x20,%al
  800a5b:	74 f6                	je     800a53 <strtol+0xe>
  800a5d:	3c 09                	cmp    $0x9,%al
  800a5f:	74 f2                	je     800a53 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a61:	3c 2b                	cmp    $0x2b,%al
  800a63:	75 0a                	jne    800a6f <strtol+0x2a>
		s++;
  800a65:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a68:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6d:	eb 11                	jmp    800a80 <strtol+0x3b>
  800a6f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a74:	3c 2d                	cmp    $0x2d,%al
  800a76:	75 08                	jne    800a80 <strtol+0x3b>
		s++, neg = 1;
  800a78:	83 c1 01             	add    $0x1,%ecx
  800a7b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a80:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a86:	75 15                	jne    800a9d <strtol+0x58>
  800a88:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8b:	75 10                	jne    800a9d <strtol+0x58>
  800a8d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a91:	75 7c                	jne    800b0f <strtol+0xca>
		s += 2, base = 16;
  800a93:	83 c1 02             	add    $0x2,%ecx
  800a96:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9b:	eb 16                	jmp    800ab3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a9d:	85 db                	test   %ebx,%ebx
  800a9f:	75 12                	jne    800ab3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa6:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa9:	75 08                	jne    800ab3 <strtol+0x6e>
		s++, base = 8;
  800aab:	83 c1 01             	add    $0x1,%ecx
  800aae:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800abb:	0f b6 11             	movzbl (%ecx),%edx
  800abe:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ac1:	89 f3                	mov    %esi,%ebx
  800ac3:	80 fb 09             	cmp    $0x9,%bl
  800ac6:	77 08                	ja     800ad0 <strtol+0x8b>
			dig = *s - '0';
  800ac8:	0f be d2             	movsbl %dl,%edx
  800acb:	83 ea 30             	sub    $0x30,%edx
  800ace:	eb 22                	jmp    800af2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ad0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad3:	89 f3                	mov    %esi,%ebx
  800ad5:	80 fb 19             	cmp    $0x19,%bl
  800ad8:	77 08                	ja     800ae2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ada:	0f be d2             	movsbl %dl,%edx
  800add:	83 ea 57             	sub    $0x57,%edx
  800ae0:	eb 10                	jmp    800af2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ae2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae5:	89 f3                	mov    %esi,%ebx
  800ae7:	80 fb 19             	cmp    $0x19,%bl
  800aea:	77 16                	ja     800b02 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aec:	0f be d2             	movsbl %dl,%edx
  800aef:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800af2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af5:	7d 0b                	jge    800b02 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800af7:	83 c1 01             	add    $0x1,%ecx
  800afa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800afe:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b00:	eb b9                	jmp    800abb <strtol+0x76>

	if (endptr)
  800b02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b06:	74 0d                	je     800b15 <strtol+0xd0>
		*endptr = (char *) s;
  800b08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0b:	89 0e                	mov    %ecx,(%esi)
  800b0d:	eb 06                	jmp    800b15 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b0f:	85 db                	test   %ebx,%ebx
  800b11:	74 98                	je     800aab <strtol+0x66>
  800b13:	eb 9e                	jmp    800ab3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b15:	89 c2                	mov    %eax,%edx
  800b17:	f7 da                	neg    %edx
  800b19:	85 ff                	test   %edi,%edi
  800b1b:	0f 45 c2             	cmovne %edx,%eax
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	83 ec 04             	sub    $0x4,%esp
  800b2c:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800b2f:	57                   	push   %edi
  800b30:	e8 6e fc ff ff       	call   8007a3 <strlen>
  800b35:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b38:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800b3b:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800b40:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b45:	eb 46                	jmp    800b8d <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800b47:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800b4b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b4e:	80 f9 09             	cmp    $0x9,%cl
  800b51:	77 08                	ja     800b5b <charhex_to_dec+0x38>
			num = s[i] - '0';
  800b53:	0f be d2             	movsbl %dl,%edx
  800b56:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b59:	eb 27                	jmp    800b82 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800b5b:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800b5e:	80 f9 05             	cmp    $0x5,%cl
  800b61:	77 08                	ja     800b6b <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800b63:	0f be d2             	movsbl %dl,%edx
  800b66:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800b69:	eb 17                	jmp    800b82 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800b6b:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800b6e:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800b71:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800b76:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800b7a:	77 06                	ja     800b82 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800b7c:	0f be d2             	movsbl %dl,%edx
  800b7f:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800b82:	0f af ce             	imul   %esi,%ecx
  800b85:	01 c8                	add    %ecx,%eax
		base *= 16;
  800b87:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b8a:	83 eb 01             	sub    $0x1,%ebx
  800b8d:	83 fb 01             	cmp    $0x1,%ebx
  800b90:	7f b5                	jg     800b47 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	89 c3                	mov    %eax,%ebx
  800bad:	89 c7                	mov    %eax,%edi
  800baf:	89 c6                	mov    %eax,%esi
  800bb1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc3:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc8:	89 d1                	mov    %edx,%ecx
  800bca:	89 d3                	mov    %edx,%ebx
  800bcc:	89 d7                	mov    %edx,%edi
  800bce:	89 d6                	mov    %edx,%esi
  800bd0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be5:	b8 03 00 00 00       	mov    $0x3,%eax
  800bea:	8b 55 08             	mov    0x8(%ebp),%edx
  800bed:	89 cb                	mov    %ecx,%ebx
  800bef:	89 cf                	mov    %ecx,%edi
  800bf1:	89 ce                	mov    %ecx,%esi
  800bf3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf5:	85 c0                	test   %eax,%eax
  800bf7:	7e 17                	jle    800c10 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf9:	83 ec 0c             	sub    $0xc,%esp
  800bfc:	50                   	push   %eax
  800bfd:	6a 03                	push   $0x3
  800bff:	68 bf 26 80 00       	push   $0x8026bf
  800c04:	6a 23                	push   $0x23
  800c06:	68 dc 26 80 00       	push   $0x8026dc
  800c0b:	e8 71 12 00 00       	call   801e81 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c23:	b8 02 00 00 00       	mov    $0x2,%eax
  800c28:	89 d1                	mov    %edx,%ecx
  800c2a:	89 d3                	mov    %edx,%ebx
  800c2c:	89 d7                	mov    %edx,%edi
  800c2e:	89 d6                	mov    %edx,%esi
  800c30:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <sys_yield>:

void
sys_yield(void)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c42:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c47:	89 d1                	mov    %edx,%ecx
  800c49:	89 d3                	mov    %edx,%ebx
  800c4b:	89 d7                	mov    %edx,%edi
  800c4d:	89 d6                	mov    %edx,%esi
  800c4f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5f:	be 00 00 00 00       	mov    $0x0,%esi
  800c64:	b8 04 00 00 00       	mov    $0x4,%eax
  800c69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c72:	89 f7                	mov    %esi,%edi
  800c74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 17                	jle    800c91 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	50                   	push   %eax
  800c7e:	6a 04                	push   $0x4
  800c80:	68 bf 26 80 00       	push   $0x8026bf
  800c85:	6a 23                	push   $0x23
  800c87:	68 dc 26 80 00       	push   $0x8026dc
  800c8c:	e8 f0 11 00 00       	call   801e81 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb3:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7e 17                	jle    800cd3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbc:	83 ec 0c             	sub    $0xc,%esp
  800cbf:	50                   	push   %eax
  800cc0:	6a 05                	push   $0x5
  800cc2:	68 bf 26 80 00       	push   $0x8026bf
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 dc 26 80 00       	push   $0x8026dc
  800cce:	e8 ae 11 00 00       	call   801e81 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce9:	b8 06 00 00 00       	mov    $0x6,%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	89 df                	mov    %ebx,%edi
  800cf6:	89 de                	mov    %ebx,%esi
  800cf8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 17                	jle    800d15 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	83 ec 0c             	sub    $0xc,%esp
  800d01:	50                   	push   %eax
  800d02:	6a 06                	push   $0x6
  800d04:	68 bf 26 80 00       	push   $0x8026bf
  800d09:	6a 23                	push   $0x23
  800d0b:	68 dc 26 80 00       	push   $0x8026dc
  800d10:	e8 6c 11 00 00       	call   801e81 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
  800d23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	89 df                	mov    %ebx,%edi
  800d38:	89 de                	mov    %ebx,%esi
  800d3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	7e 17                	jle    800d57 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	83 ec 0c             	sub    $0xc,%esp
  800d43:	50                   	push   %eax
  800d44:	6a 08                	push   $0x8
  800d46:	68 bf 26 80 00       	push   $0x8026bf
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 dc 26 80 00       	push   $0x8026dc
  800d52:	e8 2a 11 00 00       	call   801e81 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d75:	8b 55 08             	mov    0x8(%ebp),%edx
  800d78:	89 df                	mov    %ebx,%edi
  800d7a:	89 de                	mov    %ebx,%esi
  800d7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	7e 17                	jle    800d99 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d82:	83 ec 0c             	sub    $0xc,%esp
  800d85:	50                   	push   %eax
  800d86:	6a 0a                	push   $0xa
  800d88:	68 bf 26 80 00       	push   $0x8026bf
  800d8d:	6a 23                	push   $0x23
  800d8f:	68 dc 26 80 00       	push   $0x8026dc
  800d94:	e8 e8 10 00 00       	call   801e81 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
  800da7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800daf:	b8 09 00 00 00       	mov    $0x9,%eax
  800db4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dba:	89 df                	mov    %ebx,%edi
  800dbc:	89 de                	mov    %ebx,%esi
  800dbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	7e 17                	jle    800ddb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc4:	83 ec 0c             	sub    $0xc,%esp
  800dc7:	50                   	push   %eax
  800dc8:	6a 09                	push   $0x9
  800dca:	68 bf 26 80 00       	push   $0x8026bf
  800dcf:	6a 23                	push   $0x23
  800dd1:	68 dc 26 80 00       	push   $0x8026dc
  800dd6:	e8 a6 10 00 00       	call   801e81 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ddb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dde:	5b                   	pop    %ebx
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	57                   	push   %edi
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de9:	be 00 00 00 00       	mov    $0x0,%esi
  800dee:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df6:	8b 55 08             	mov    0x8(%ebp),%edx
  800df9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
  800e0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e14:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	89 cb                	mov    %ecx,%ebx
  800e1e:	89 cf                	mov    %ecx,%edi
  800e20:	89 ce                	mov    %ecx,%esi
  800e22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e24:	85 c0                	test   %eax,%eax
  800e26:	7e 17                	jle    800e3f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e28:	83 ec 0c             	sub    $0xc,%esp
  800e2b:	50                   	push   %eax
  800e2c:	6a 0d                	push   $0xd
  800e2e:	68 bf 26 80 00       	push   $0x8026bf
  800e33:	6a 23                	push   $0x23
  800e35:	68 dc 26 80 00       	push   $0x8026dc
  800e3a:	e8 42 10 00 00       	call   801e81 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	53                   	push   %ebx
  800e4b:	83 ec 04             	sub    $0x4,%esp
  800e4e:	8b 45 08             	mov    0x8(%ebp),%eax

	
	void *addr = (void *) utf->utf_fault_va;
  800e51:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800e53:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e57:	74 11                	je     800e6a <pgfault+0x23>
  800e59:	89 d8                	mov    %ebx,%eax
  800e5b:	c1 e8 0c             	shr    $0xc,%eax
  800e5e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e65:	f6 c4 08             	test   $0x8,%ah
  800e68:	75 14                	jne    800e7e <pgfault+0x37>
		panic("page fault");
  800e6a:	83 ec 04             	sub    $0x4,%esp
  800e6d:	68 ea 26 80 00       	push   $0x8026ea
  800e72:	6a 5b                	push   $0x5b
  800e74:	68 f5 26 80 00       	push   $0x8026f5
  800e79:	e8 03 10 00 00       	call   801e81 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// allocate a new page and map it at a temporary location
	if((r = sys_page_alloc(0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800e7e:	83 ec 04             	sub    $0x4,%esp
  800e81:	6a 07                	push   $0x7
  800e83:	68 00 f0 7f 00       	push   $0x7ff000
  800e88:	6a 00                	push   $0x0
  800e8a:	e8 c7 fd ff ff       	call   800c56 <sys_page_alloc>
  800e8f:	83 c4 10             	add    $0x10,%esp
  800e92:	85 c0                	test   %eax,%eax
  800e94:	79 12                	jns    800ea8 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800e96:	50                   	push   %eax
  800e97:	68 00 27 80 00       	push   $0x802700
  800e9c:	6a 66                	push   $0x66
  800e9e:	68 f5 26 80 00       	push   $0x8026f5
  800ea3:	e8 d9 0f 00 00       	call   801e81 <_panic>

	// copy date to new page
	//strncpy((char *)PFTEMP, (char *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
	memcpy((void *)PFTEMP, (void *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
  800ea8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800eae:	83 ec 04             	sub    $0x4,%esp
  800eb1:	68 00 10 00 00       	push   $0x1000
  800eb6:	53                   	push   %ebx
  800eb7:	68 00 f0 7f 00       	push   $0x7ff000
  800ebc:	e8 15 fb ff ff       	call   8009d6 <memcpy>

	// move the new page to the old page's address
	if((r = sys_page_map(0, (void *)PFTEMP, 0, (void *)
  800ec1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ec8:	53                   	push   %ebx
  800ec9:	6a 00                	push   $0x0
  800ecb:	68 00 f0 7f 00       	push   $0x7ff000
  800ed0:	6a 00                	push   $0x0
  800ed2:	e8 c2 fd ff ff       	call   800c99 <sys_page_map>
  800ed7:	83 c4 20             	add    $0x20,%esp
  800eda:	85 c0                	test   %eax,%eax
  800edc:	79 12                	jns    800ef0 <pgfault+0xa9>
		(ROUNDDOWN(addr, PGSIZE)), PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_map: %e", r);
  800ede:	50                   	push   %eax
  800edf:	68 13 27 80 00       	push   $0x802713
  800ee4:	6a 6f                	push   $0x6f
  800ee6:	68 f5 26 80 00       	push   $0x8026f5
  800eeb:	e8 91 0f 00 00       	call   801e81 <_panic>

	// unmap page on PFTEMP
	if((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800ef0:	83 ec 08             	sub    $0x8,%esp
  800ef3:	68 00 f0 7f 00       	push   $0x7ff000
  800ef8:	6a 00                	push   $0x0
  800efa:	e8 dc fd ff ff       	call   800cdb <sys_page_unmap>
  800eff:	83 c4 10             	add    $0x10,%esp
  800f02:	85 c0                	test   %eax,%eax
  800f04:	79 12                	jns    800f18 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  800f06:	50                   	push   %eax
  800f07:	68 24 27 80 00       	push   $0x802724
  800f0c:	6a 73                	push   $0x73
  800f0e:	68 f5 26 80 00       	push   $0x8026f5
  800f13:	e8 69 0f 00 00       	call   801e81 <_panic>


}
  800f18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1b:	c9                   	leave  
  800f1c:	c3                   	ret    

00800f1d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	57                   	push   %edi
  800f21:	56                   	push   %esi
  800f22:	53                   	push   %ebx
  800f23:	83 ec 28             	sub    $0x28,%esp

	#ifdef CHALLENGE 
	set_exception_handler(pgfault, T_PGFLT);
	#else
	// set up page fault handler
	set_pgfault_handler(pgfault);
  800f26:	68 47 0e 80 00       	push   $0x800e47
  800f2b:	e8 97 0f 00 00       	call   801ec7 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f30:	b8 07 00 00 00       	mov    $0x7,%eax
  800f35:	cd 30                	int    $0x30
  800f37:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	#endif

	// create a child
	envid = sys_exofork();
	if (envid < 0)
  800f3d:	83 c4 10             	add    $0x10,%esp
  800f40:	85 c0                	test   %eax,%eax
  800f42:	79 15                	jns    800f59 <fork+0x3c>
		panic("sys_exofork: %e", envid);
  800f44:	50                   	push   %eax
  800f45:	68 37 27 80 00       	push   $0x802737
  800f4a:	68 d0 00 00 00       	push   $0xd0
  800f4f:	68 f5 26 80 00       	push   $0x8026f5
  800f54:	e8 28 0f 00 00       	call   801e81 <_panic>
  800f59:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f5e:	be 00 08 00 00       	mov    $0x800,%esi
	// we are the child
	if(envid == 0) {
  800f63:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f67:	75 21                	jne    800f8a <fork+0x6d>
		// the copied valude of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800f69:	e8 aa fc ff ff       	call   800c18 <sys_getenvid>
  800f6e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f73:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f76:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f7b:	a3 08 40 80 00       	mov    %eax,0x804008
		/*// alloc exception stack
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
			PTE_P | PTE_U | PTE_W)) < 0)
			panic("sys_page_alloc: %e", r);*/

		return 0;
  800f80:	b8 00 00 00 00       	mov    $0x0,%eax
  800f85:	e9 a3 01 00 00       	jmp    80112d <fork+0x210>
{
	int r;

	// LAB 4: Your code here.
	
	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P))
  800f8a:	89 d8                	mov    %ebx,%eax
  800f8c:	c1 e8 16             	shr    $0x16,%eax
  800f8f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f96:	a8 01                	test   $0x1,%al
  800f98:	0f 84 f0 00 00 00    	je     80108e <fork+0x171>
		return 0;

	// virtual page pn's page table entry
	pte_t pe = uvpt[pn];
  800f9e:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi


	if((pe & PTE_P) && (pe & PTE_U)) {
  800fa5:	89 f8                	mov    %edi,%eax
  800fa7:	83 e0 05             	and    $0x5,%eax
  800faa:	83 f8 05             	cmp    $0x5,%eax
  800fad:	0f 85 db 00 00 00    	jne    80108e <fork+0x171>
		// share with the child environment 
		if(pe & PTE_SHARE) {
  800fb3:	f7 c7 00 04 00 00    	test   $0x400,%edi
  800fb9:	74 36                	je     800ff1 <fork+0xd4>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  800fbb:	83 ec 0c             	sub    $0xc,%esp
  800fbe:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  800fc4:	57                   	push   %edi
  800fc5:	53                   	push   %ebx
  800fc6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc9:	53                   	push   %ebx
  800fca:	6a 00                	push   $0x0
  800fcc:	e8 c8 fc ff ff       	call   800c99 <sys_page_map>
  800fd1:	83 c4 20             	add    $0x20,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	0f 89 b2 00 00 00    	jns    80108e <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  800fdc:	50                   	push   %eax
  800fdd:	68 47 27 80 00       	push   $0x802747
  800fe2:	68 97 00 00 00       	push   $0x97
  800fe7:	68 f5 26 80 00       	push   $0x8026f5
  800fec:	e8 90 0e 00 00       	call   801e81 <_panic>
		}
		// the page is writable or copy-on-write
		else if((pe & PTE_W) || (pe & PTE_COW)) {
  800ff1:	f7 c7 02 08 00 00    	test   $0x802,%edi
  800ff7:	74 63                	je     80105c <fork+0x13f>
			// create the child mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, 
  800ff9:	81 e7 05 06 00 00    	and    $0x605,%edi
  800fff:	81 cf 00 08 00 00    	or     $0x800,%edi
  801005:	83 ec 0c             	sub    $0xc,%esp
  801008:	57                   	push   %edi
  801009:	53                   	push   %ebx
  80100a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80100d:	53                   	push   %ebx
  80100e:	6a 00                	push   $0x0
  801010:	e8 84 fc ff ff       	call   800c99 <sys_page_map>
  801015:	83 c4 20             	add    $0x20,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	79 15                	jns    801031 <fork+0x114>
				(void *)(pn*PGSIZE), (pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  80101c:	50                   	push   %eax
  80101d:	68 47 27 80 00       	push   $0x802747
  801022:	68 9e 00 00 00       	push   $0x9e
  801027:	68 f5 26 80 00       	push   $0x8026f5
  80102c:	e8 50 0e 00 00       	call   801e81 <_panic>
			// map the parent mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE),
  801031:	83 ec 0c             	sub    $0xc,%esp
  801034:	57                   	push   %edi
  801035:	53                   	push   %ebx
  801036:	6a 00                	push   $0x0
  801038:	53                   	push   %ebx
  801039:	6a 00                	push   $0x0
  80103b:	e8 59 fc ff ff       	call   800c99 <sys_page_map>
  801040:	83 c4 20             	add    $0x20,%esp
  801043:	85 c0                	test   %eax,%eax
  801045:	79 47                	jns    80108e <fork+0x171>
				(pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  801047:	50                   	push   %eax
  801048:	68 47 27 80 00       	push   $0x802747
  80104d:	68 a2 00 00 00       	push   $0xa2
  801052:	68 f5 26 80 00       	push   $0x8026f5
  801057:	e8 25 0e 00 00       	call   801e81 <_panic>
		}	
		else {
			// create the child mapping read only
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  80105c:	83 ec 0c             	sub    $0xc,%esp
  80105f:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  801065:	57                   	push   %edi
  801066:	53                   	push   %ebx
  801067:	ff 75 e4             	pushl  -0x1c(%ebp)
  80106a:	53                   	push   %ebx
  80106b:	6a 00                	push   $0x0
  80106d:	e8 27 fc ff ff       	call   800c99 <sys_page_map>
  801072:	83 c4 20             	add    $0x20,%esp
  801075:	85 c0                	test   %eax,%eax
  801077:	79 15                	jns    80108e <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  801079:	50                   	push   %eax
  80107a:	68 47 27 80 00       	push   $0x802747
  80107f:	68 a8 00 00 00       	push   $0xa8
  801084:	68 f5 26 80 00       	push   $0x8026f5
  801089:	e8 f3 0d 00 00       	call   801e81 <_panic>
			panic("sys_page_alloc: %e", r);*/

		return 0;
	}
	// copy address to child environment's page dirctory
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn)
  80108e:	83 c6 01             	add    $0x1,%esi
  801091:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801097:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  80109d:	0f 85 e7 fe ff ff    	jne    800f8a <fork+0x6d>
	#ifdef CHALLENGE 
	if((r = sys_env_set_exception_upcall(envid, thisenv->env_exception_upcall)) < 0)
		panic("sys_env_set_exception_upcall: %e", r);
	#else
	// set child's page fault handler
	if((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  8010a3:	a1 08 40 80 00       	mov    0x804008,%eax
  8010a8:	8b 40 64             	mov    0x64(%eax),%eax
  8010ab:	83 ec 08             	sub    $0x8,%esp
  8010ae:	50                   	push   %eax
  8010af:	ff 75 e0             	pushl  -0x20(%ebp)
  8010b2:	e8 ea fc ff ff       	call   800da1 <sys_env_set_pgfault_upcall>
  8010b7:	83 c4 10             	add    $0x10,%esp
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	79 15                	jns    8010d3 <fork+0x1b6>
		panic("sys_env_set_pgfault_upcall: %e", r);
  8010be:	50                   	push   %eax
  8010bf:	68 80 27 80 00       	push   $0x802780
  8010c4:	68 e9 00 00 00       	push   $0xe9
  8010c9:	68 f5 26 80 00       	push   $0x8026f5
  8010ce:	e8 ae 0d 00 00       	call   801e81 <_panic>
	#endif

	// alloc exception stack for child environment
	if((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), 
  8010d3:	83 ec 04             	sub    $0x4,%esp
  8010d6:	6a 07                	push   $0x7
  8010d8:	68 00 f0 bf ee       	push   $0xeebff000
  8010dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8010e0:	e8 71 fb ff ff       	call   800c56 <sys_page_alloc>
  8010e5:	83 c4 10             	add    $0x10,%esp
  8010e8:	85 c0                	test   %eax,%eax
  8010ea:	79 15                	jns    801101 <fork+0x1e4>
		PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
  8010ec:	50                   	push   %eax
  8010ed:	68 00 27 80 00       	push   $0x802700
  8010f2:	68 ef 00 00 00       	push   $0xef
  8010f7:	68 f5 26 80 00       	push   $0x8026f5
  8010fc:	e8 80 0d 00 00       	call   801e81 <_panic>

	// start the child environment running
	if((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801101:	83 ec 08             	sub    $0x8,%esp
  801104:	6a 02                	push   $0x2
  801106:	ff 75 e0             	pushl  -0x20(%ebp)
  801109:	e8 0f fc ff ff       	call   800d1d <sys_env_set_status>
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	85 c0                	test   %eax,%eax
  801113:	79 15                	jns    80112a <fork+0x20d>
		panic("sys_env_set_status: %e", r);
  801115:	50                   	push   %eax
  801116:	68 53 27 80 00       	push   $0x802753
  80111b:	68 f3 00 00 00       	push   $0xf3
  801120:	68 f5 26 80 00       	push   $0x8026f5
  801125:	e8 57 0d 00 00       	call   801e81 <_panic>

	return envid;
  80112a:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  80112d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801130:	5b                   	pop    %ebx
  801131:	5e                   	pop    %esi
  801132:	5f                   	pop    %edi
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    

00801135 <sfork>:

// Challenge!
int
sfork(void)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80113b:	68 6a 27 80 00       	push   $0x80276a
  801140:	68 fc 00 00 00       	push   $0xfc
  801145:	68 f5 26 80 00       	push   $0x8026f5
  80114a:	e8 32 0d 00 00       	call   801e81 <_panic>

0080114f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801152:	8b 45 08             	mov    0x8(%ebp),%eax
  801155:	05 00 00 00 30       	add    $0x30000000,%eax
  80115a:	c1 e8 0c             	shr    $0xc,%eax
}
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    

0080115f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801162:	8b 45 08             	mov    0x8(%ebp),%eax
  801165:	05 00 00 00 30       	add    $0x30000000,%eax
  80116a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80116f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    

00801176 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801181:	89 c2                	mov    %eax,%edx
  801183:	c1 ea 16             	shr    $0x16,%edx
  801186:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118d:	f6 c2 01             	test   $0x1,%dl
  801190:	74 11                	je     8011a3 <fd_alloc+0x2d>
  801192:	89 c2                	mov    %eax,%edx
  801194:	c1 ea 0c             	shr    $0xc,%edx
  801197:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119e:	f6 c2 01             	test   $0x1,%dl
  8011a1:	75 09                	jne    8011ac <fd_alloc+0x36>
			*fd_store = fd;
  8011a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011aa:	eb 17                	jmp    8011c3 <fd_alloc+0x4d>
  8011ac:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011b1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011b6:	75 c9                	jne    801181 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011b8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011be:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    

008011c5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011cb:	83 f8 1f             	cmp    $0x1f,%eax
  8011ce:	77 36                	ja     801206 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011d0:	c1 e0 0c             	shl    $0xc,%eax
  8011d3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011d8:	89 c2                	mov    %eax,%edx
  8011da:	c1 ea 16             	shr    $0x16,%edx
  8011dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e4:	f6 c2 01             	test   $0x1,%dl
  8011e7:	74 24                	je     80120d <fd_lookup+0x48>
  8011e9:	89 c2                	mov    %eax,%edx
  8011eb:	c1 ea 0c             	shr    $0xc,%edx
  8011ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f5:	f6 c2 01             	test   $0x1,%dl
  8011f8:	74 1a                	je     801214 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011fd:	89 02                	mov    %eax,(%edx)
	return 0;
  8011ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801204:	eb 13                	jmp    801219 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801206:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120b:	eb 0c                	jmp    801219 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80120d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801212:	eb 05                	jmp    801219 <fd_lookup+0x54>
  801214:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	83 ec 08             	sub    $0x8,%esp
  801221:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801224:	ba 1c 28 80 00       	mov    $0x80281c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801229:	eb 13                	jmp    80123e <dev_lookup+0x23>
  80122b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80122e:	39 08                	cmp    %ecx,(%eax)
  801230:	75 0c                	jne    80123e <dev_lookup+0x23>
			*dev = devtab[i];
  801232:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801235:	89 01                	mov    %eax,(%ecx)
			return 0;
  801237:	b8 00 00 00 00       	mov    $0x0,%eax
  80123c:	eb 2e                	jmp    80126c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80123e:	8b 02                	mov    (%edx),%eax
  801240:	85 c0                	test   %eax,%eax
  801242:	75 e7                	jne    80122b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801244:	a1 08 40 80 00       	mov    0x804008,%eax
  801249:	8b 40 48             	mov    0x48(%eax),%eax
  80124c:	83 ec 04             	sub    $0x4,%esp
  80124f:	51                   	push   %ecx
  801250:	50                   	push   %eax
  801251:	68 a0 27 80 00       	push   $0x8027a0
  801256:	e8 4d ef ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  80125b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80125e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	56                   	push   %esi
  801272:	53                   	push   %ebx
  801273:	83 ec 10             	sub    $0x10,%esp
  801276:	8b 75 08             	mov    0x8(%ebp),%esi
  801279:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80127c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127f:	50                   	push   %eax
  801280:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801286:	c1 e8 0c             	shr    $0xc,%eax
  801289:	50                   	push   %eax
  80128a:	e8 36 ff ff ff       	call   8011c5 <fd_lookup>
  80128f:	83 c4 08             	add    $0x8,%esp
  801292:	85 c0                	test   %eax,%eax
  801294:	78 05                	js     80129b <fd_close+0x2d>
	    || fd != fd2) 
  801296:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801299:	74 0c                	je     8012a7 <fd_close+0x39>
		return (must_exist ? r : 0); 
  80129b:	84 db                	test   %bl,%bl
  80129d:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a2:	0f 44 c2             	cmove  %edx,%eax
  8012a5:	eb 41                	jmp    8012e8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012a7:	83 ec 08             	sub    $0x8,%esp
  8012aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ad:	50                   	push   %eax
  8012ae:	ff 36                	pushl  (%esi)
  8012b0:	e8 66 ff ff ff       	call   80121b <dev_lookup>
  8012b5:	89 c3                	mov    %eax,%ebx
  8012b7:	83 c4 10             	add    $0x10,%esp
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	78 1a                	js     8012d8 <fd_close+0x6a>
		if (dev->dev_close) 
  8012be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8012c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	74 0b                	je     8012d8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012cd:	83 ec 0c             	sub    $0xc,%esp
  8012d0:	56                   	push   %esi
  8012d1:	ff d0                	call   *%eax
  8012d3:	89 c3                	mov    %eax,%ebx
  8012d5:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012d8:	83 ec 08             	sub    $0x8,%esp
  8012db:	56                   	push   %esi
  8012dc:	6a 00                	push   $0x0
  8012de:	e8 f8 f9 ff ff       	call   800cdb <sys_page_unmap>
	return r;
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	89 d8                	mov    %ebx,%eax
}
  8012e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012eb:	5b                   	pop    %ebx
  8012ec:	5e                   	pop    %esi
  8012ed:	5d                   	pop    %ebp
  8012ee:	c3                   	ret    

008012ef <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f8:	50                   	push   %eax
  8012f9:	ff 75 08             	pushl  0x8(%ebp)
  8012fc:	e8 c4 fe ff ff       	call   8011c5 <fd_lookup>
  801301:	83 c4 08             	add    $0x8,%esp
  801304:	85 c0                	test   %eax,%eax
  801306:	78 10                	js     801318 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  801308:	83 ec 08             	sub    $0x8,%esp
  80130b:	6a 01                	push   $0x1
  80130d:	ff 75 f4             	pushl  -0xc(%ebp)
  801310:	e8 59 ff ff ff       	call   80126e <fd_close>
  801315:	83 c4 10             	add    $0x10,%esp
}
  801318:	c9                   	leave  
  801319:	c3                   	ret    

0080131a <close_all>:

void
close_all(void)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	53                   	push   %ebx
  80131e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801321:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801326:	83 ec 0c             	sub    $0xc,%esp
  801329:	53                   	push   %ebx
  80132a:	e8 c0 ff ff ff       	call   8012ef <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80132f:	83 c3 01             	add    $0x1,%ebx
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	83 fb 20             	cmp    $0x20,%ebx
  801338:	75 ec                	jne    801326 <close_all+0xc>
		close(i);
}
  80133a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133d:	c9                   	leave  
  80133e:	c3                   	ret    

0080133f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	57                   	push   %edi
  801343:	56                   	push   %esi
  801344:	53                   	push   %ebx
  801345:	83 ec 2c             	sub    $0x2c,%esp
  801348:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80134b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80134e:	50                   	push   %eax
  80134f:	ff 75 08             	pushl  0x8(%ebp)
  801352:	e8 6e fe ff ff       	call   8011c5 <fd_lookup>
  801357:	83 c4 08             	add    $0x8,%esp
  80135a:	85 c0                	test   %eax,%eax
  80135c:	0f 88 c1 00 00 00    	js     801423 <dup+0xe4>
		return r;
	close(newfdnum);
  801362:	83 ec 0c             	sub    $0xc,%esp
  801365:	56                   	push   %esi
  801366:	e8 84 ff ff ff       	call   8012ef <close>

	newfd = INDEX2FD(newfdnum);
  80136b:	89 f3                	mov    %esi,%ebx
  80136d:	c1 e3 0c             	shl    $0xc,%ebx
  801370:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801376:	83 c4 04             	add    $0x4,%esp
  801379:	ff 75 e4             	pushl  -0x1c(%ebp)
  80137c:	e8 de fd ff ff       	call   80115f <fd2data>
  801381:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801383:	89 1c 24             	mov    %ebx,(%esp)
  801386:	e8 d4 fd ff ff       	call   80115f <fd2data>
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801391:	89 f8                	mov    %edi,%eax
  801393:	c1 e8 16             	shr    $0x16,%eax
  801396:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80139d:	a8 01                	test   $0x1,%al
  80139f:	74 37                	je     8013d8 <dup+0x99>
  8013a1:	89 f8                	mov    %edi,%eax
  8013a3:	c1 e8 0c             	shr    $0xc,%eax
  8013a6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ad:	f6 c2 01             	test   $0x1,%dl
  8013b0:	74 26                	je     8013d8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b9:	83 ec 0c             	sub    $0xc,%esp
  8013bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c1:	50                   	push   %eax
  8013c2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c5:	6a 00                	push   $0x0
  8013c7:	57                   	push   %edi
  8013c8:	6a 00                	push   $0x0
  8013ca:	e8 ca f8 ff ff       	call   800c99 <sys_page_map>
  8013cf:	89 c7                	mov    %eax,%edi
  8013d1:	83 c4 20             	add    $0x20,%esp
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	78 2e                	js     801406 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013db:	89 d0                	mov    %edx,%eax
  8013dd:	c1 e8 0c             	shr    $0xc,%eax
  8013e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e7:	83 ec 0c             	sub    $0xc,%esp
  8013ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ef:	50                   	push   %eax
  8013f0:	53                   	push   %ebx
  8013f1:	6a 00                	push   $0x0
  8013f3:	52                   	push   %edx
  8013f4:	6a 00                	push   $0x0
  8013f6:	e8 9e f8 ff ff       	call   800c99 <sys_page_map>
  8013fb:	89 c7                	mov    %eax,%edi
  8013fd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801400:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801402:	85 ff                	test   %edi,%edi
  801404:	79 1d                	jns    801423 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801406:	83 ec 08             	sub    $0x8,%esp
  801409:	53                   	push   %ebx
  80140a:	6a 00                	push   $0x0
  80140c:	e8 ca f8 ff ff       	call   800cdb <sys_page_unmap>
	sys_page_unmap(0, nva);
  801411:	83 c4 08             	add    $0x8,%esp
  801414:	ff 75 d4             	pushl  -0x2c(%ebp)
  801417:	6a 00                	push   $0x0
  801419:	e8 bd f8 ff ff       	call   800cdb <sys_page_unmap>
	return r;
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	89 f8                	mov    %edi,%eax
}
  801423:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801426:	5b                   	pop    %ebx
  801427:	5e                   	pop    %esi
  801428:	5f                   	pop    %edi
  801429:	5d                   	pop    %ebp
  80142a:	c3                   	ret    

0080142b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	53                   	push   %ebx
  80142f:	83 ec 14             	sub    $0x14,%esp
  801432:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801435:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801438:	50                   	push   %eax
  801439:	53                   	push   %ebx
  80143a:	e8 86 fd ff ff       	call   8011c5 <fd_lookup>
  80143f:	83 c4 08             	add    $0x8,%esp
  801442:	89 c2                	mov    %eax,%edx
  801444:	85 c0                	test   %eax,%eax
  801446:	78 6d                	js     8014b5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801448:	83 ec 08             	sub    $0x8,%esp
  80144b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144e:	50                   	push   %eax
  80144f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801452:	ff 30                	pushl  (%eax)
  801454:	e8 c2 fd ff ff       	call   80121b <dev_lookup>
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	85 c0                	test   %eax,%eax
  80145e:	78 4c                	js     8014ac <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801460:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801463:	8b 42 08             	mov    0x8(%edx),%eax
  801466:	83 e0 03             	and    $0x3,%eax
  801469:	83 f8 01             	cmp    $0x1,%eax
  80146c:	75 21                	jne    80148f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80146e:	a1 08 40 80 00       	mov    0x804008,%eax
  801473:	8b 40 48             	mov    0x48(%eax),%eax
  801476:	83 ec 04             	sub    $0x4,%esp
  801479:	53                   	push   %ebx
  80147a:	50                   	push   %eax
  80147b:	68 e1 27 80 00       	push   $0x8027e1
  801480:	e8 23 ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80148d:	eb 26                	jmp    8014b5 <read+0x8a>
	}
	if (!dev->dev_read)
  80148f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801492:	8b 40 08             	mov    0x8(%eax),%eax
  801495:	85 c0                	test   %eax,%eax
  801497:	74 17                	je     8014b0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801499:	83 ec 04             	sub    $0x4,%esp
  80149c:	ff 75 10             	pushl  0x10(%ebp)
  80149f:	ff 75 0c             	pushl  0xc(%ebp)
  8014a2:	52                   	push   %edx
  8014a3:	ff d0                	call   *%eax
  8014a5:	89 c2                	mov    %eax,%edx
  8014a7:	83 c4 10             	add    $0x10,%esp
  8014aa:	eb 09                	jmp    8014b5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ac:	89 c2                	mov    %eax,%edx
  8014ae:	eb 05                	jmp    8014b5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014b5:	89 d0                	mov    %edx,%eax
  8014b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	57                   	push   %edi
  8014c0:	56                   	push   %esi
  8014c1:	53                   	push   %ebx
  8014c2:	83 ec 0c             	sub    $0xc,%esp
  8014c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d0:	eb 21                	jmp    8014f3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d2:	83 ec 04             	sub    $0x4,%esp
  8014d5:	89 f0                	mov    %esi,%eax
  8014d7:	29 d8                	sub    %ebx,%eax
  8014d9:	50                   	push   %eax
  8014da:	89 d8                	mov    %ebx,%eax
  8014dc:	03 45 0c             	add    0xc(%ebp),%eax
  8014df:	50                   	push   %eax
  8014e0:	57                   	push   %edi
  8014e1:	e8 45 ff ff ff       	call   80142b <read>
		if (m < 0)
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	78 10                	js     8014fd <readn+0x41>
			return m;
		if (m == 0)
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	74 0a                	je     8014fb <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f1:	01 c3                	add    %eax,%ebx
  8014f3:	39 f3                	cmp    %esi,%ebx
  8014f5:	72 db                	jb     8014d2 <readn+0x16>
  8014f7:	89 d8                	mov    %ebx,%eax
  8014f9:	eb 02                	jmp    8014fd <readn+0x41>
  8014fb:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801500:	5b                   	pop    %ebx
  801501:	5e                   	pop    %esi
  801502:	5f                   	pop    %edi
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    

00801505 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	53                   	push   %ebx
  801509:	83 ec 14             	sub    $0x14,%esp
  80150c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801512:	50                   	push   %eax
  801513:	53                   	push   %ebx
  801514:	e8 ac fc ff ff       	call   8011c5 <fd_lookup>
  801519:	83 c4 08             	add    $0x8,%esp
  80151c:	89 c2                	mov    %eax,%edx
  80151e:	85 c0                	test   %eax,%eax
  801520:	78 68                	js     80158a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801522:	83 ec 08             	sub    $0x8,%esp
  801525:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801528:	50                   	push   %eax
  801529:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152c:	ff 30                	pushl  (%eax)
  80152e:	e8 e8 fc ff ff       	call   80121b <dev_lookup>
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	85 c0                	test   %eax,%eax
  801538:	78 47                	js     801581 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801541:	75 21                	jne    801564 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801543:	a1 08 40 80 00       	mov    0x804008,%eax
  801548:	8b 40 48             	mov    0x48(%eax),%eax
  80154b:	83 ec 04             	sub    $0x4,%esp
  80154e:	53                   	push   %ebx
  80154f:	50                   	push   %eax
  801550:	68 fd 27 80 00       	push   $0x8027fd
  801555:	e8 4e ec ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801562:	eb 26                	jmp    80158a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801564:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801567:	8b 52 0c             	mov    0xc(%edx),%edx
  80156a:	85 d2                	test   %edx,%edx
  80156c:	74 17                	je     801585 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80156e:	83 ec 04             	sub    $0x4,%esp
  801571:	ff 75 10             	pushl  0x10(%ebp)
  801574:	ff 75 0c             	pushl  0xc(%ebp)
  801577:	50                   	push   %eax
  801578:	ff d2                	call   *%edx
  80157a:	89 c2                	mov    %eax,%edx
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	eb 09                	jmp    80158a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801581:	89 c2                	mov    %eax,%edx
  801583:	eb 05                	jmp    80158a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801585:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80158a:	89 d0                	mov    %edx,%eax
  80158c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158f:	c9                   	leave  
  801590:	c3                   	ret    

00801591 <seek>:

int
seek(int fdnum, off_t offset)
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801597:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80159a:	50                   	push   %eax
  80159b:	ff 75 08             	pushl  0x8(%ebp)
  80159e:	e8 22 fc ff ff       	call   8011c5 <fd_lookup>
  8015a3:	83 c4 08             	add    $0x8,%esp
  8015a6:	85 c0                	test   %eax,%eax
  8015a8:	78 0e                	js     8015b8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b8:	c9                   	leave  
  8015b9:	c3                   	ret    

008015ba <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	53                   	push   %ebx
  8015be:	83 ec 14             	sub    $0x14,%esp
  8015c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c7:	50                   	push   %eax
  8015c8:	53                   	push   %ebx
  8015c9:	e8 f7 fb ff ff       	call   8011c5 <fd_lookup>
  8015ce:	83 c4 08             	add    $0x8,%esp
  8015d1:	89 c2                	mov    %eax,%edx
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 65                	js     80163c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d7:	83 ec 08             	sub    $0x8,%esp
  8015da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e1:	ff 30                	pushl  (%eax)
  8015e3:	e8 33 fc ff ff       	call   80121b <dev_lookup>
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	78 44                	js     801633 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f6:	75 21                	jne    801619 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015f8:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015fd:	8b 40 48             	mov    0x48(%eax),%eax
  801600:	83 ec 04             	sub    $0x4,%esp
  801603:	53                   	push   %ebx
  801604:	50                   	push   %eax
  801605:	68 c0 27 80 00       	push   $0x8027c0
  80160a:	e8 99 eb ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801617:	eb 23                	jmp    80163c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801619:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161c:	8b 52 18             	mov    0x18(%edx),%edx
  80161f:	85 d2                	test   %edx,%edx
  801621:	74 14                	je     801637 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801623:	83 ec 08             	sub    $0x8,%esp
  801626:	ff 75 0c             	pushl  0xc(%ebp)
  801629:	50                   	push   %eax
  80162a:	ff d2                	call   *%edx
  80162c:	89 c2                	mov    %eax,%edx
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	eb 09                	jmp    80163c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801633:	89 c2                	mov    %eax,%edx
  801635:	eb 05                	jmp    80163c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801637:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80163c:	89 d0                	mov    %edx,%eax
  80163e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801641:	c9                   	leave  
  801642:	c3                   	ret    

00801643 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	53                   	push   %ebx
  801647:	83 ec 14             	sub    $0x14,%esp
  80164a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801650:	50                   	push   %eax
  801651:	ff 75 08             	pushl  0x8(%ebp)
  801654:	e8 6c fb ff ff       	call   8011c5 <fd_lookup>
  801659:	83 c4 08             	add    $0x8,%esp
  80165c:	89 c2                	mov    %eax,%edx
  80165e:	85 c0                	test   %eax,%eax
  801660:	78 58                	js     8016ba <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801662:	83 ec 08             	sub    $0x8,%esp
  801665:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166c:	ff 30                	pushl  (%eax)
  80166e:	e8 a8 fb ff ff       	call   80121b <dev_lookup>
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	85 c0                	test   %eax,%eax
  801678:	78 37                	js     8016b1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80167a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801681:	74 32                	je     8016b5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801683:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801686:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80168d:	00 00 00 
	stat->st_isdir = 0;
  801690:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801697:	00 00 00 
	stat->st_dev = dev;
  80169a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016a0:	83 ec 08             	sub    $0x8,%esp
  8016a3:	53                   	push   %ebx
  8016a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8016a7:	ff 50 14             	call   *0x14(%eax)
  8016aa:	89 c2                	mov    %eax,%edx
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	eb 09                	jmp    8016ba <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b1:	89 c2                	mov    %eax,%edx
  8016b3:	eb 05                	jmp    8016ba <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016ba:	89 d0                	mov    %edx,%eax
  8016bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	56                   	push   %esi
  8016c5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016c6:	83 ec 08             	sub    $0x8,%esp
  8016c9:	6a 00                	push   $0x0
  8016cb:	ff 75 08             	pushl  0x8(%ebp)
  8016ce:	e8 2b 02 00 00       	call   8018fe <open>
  8016d3:	89 c3                	mov    %eax,%ebx
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	78 1b                	js     8016f7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016dc:	83 ec 08             	sub    $0x8,%esp
  8016df:	ff 75 0c             	pushl  0xc(%ebp)
  8016e2:	50                   	push   %eax
  8016e3:	e8 5b ff ff ff       	call   801643 <fstat>
  8016e8:	89 c6                	mov    %eax,%esi
	close(fd);
  8016ea:	89 1c 24             	mov    %ebx,(%esp)
  8016ed:	e8 fd fb ff ff       	call   8012ef <close>
	return r;
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	89 f0                	mov    %esi,%eax
}
  8016f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016fa:	5b                   	pop    %ebx
  8016fb:	5e                   	pop    %esi
  8016fc:	5d                   	pop    %ebp
  8016fd:	c3                   	ret    

008016fe <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	56                   	push   %esi
  801702:	53                   	push   %ebx
  801703:	89 c6                	mov    %eax,%esi
  801705:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801707:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80170e:	75 12                	jne    801722 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801710:	83 ec 0c             	sub    $0xc,%esp
  801713:	6a 01                	push   $0x1
  801715:	e8 fb 08 00 00       	call   802015 <ipc_find_env>
  80171a:	a3 04 40 80 00       	mov    %eax,0x804004
  80171f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801722:	6a 07                	push   $0x7
  801724:	68 00 50 80 00       	push   $0x805000
  801729:	56                   	push   %esi
  80172a:	ff 35 04 40 80 00    	pushl  0x804004
  801730:	e8 8a 08 00 00       	call   801fbf <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801735:	83 c4 0c             	add    $0xc,%esp
  801738:	6a 00                	push   $0x0
  80173a:	53                   	push   %ebx
  80173b:	6a 00                	push   $0x0
  80173d:	e8 14 08 00 00       	call   801f56 <ipc_recv>
}
  801742:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801745:	5b                   	pop    %ebx
  801746:	5e                   	pop    %esi
  801747:	5d                   	pop    %ebp
  801748:	c3                   	ret    

00801749 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80174f:	8b 45 08             	mov    0x8(%ebp),%eax
  801752:	8b 40 0c             	mov    0xc(%eax),%eax
  801755:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80175a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80175d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801762:	ba 00 00 00 00       	mov    $0x0,%edx
  801767:	b8 02 00 00 00       	mov    $0x2,%eax
  80176c:	e8 8d ff ff ff       	call   8016fe <fsipc>
}
  801771:	c9                   	leave  
  801772:	c3                   	ret    

00801773 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801779:	8b 45 08             	mov    0x8(%ebp),%eax
  80177c:	8b 40 0c             	mov    0xc(%eax),%eax
  80177f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801784:	ba 00 00 00 00       	mov    $0x0,%edx
  801789:	b8 06 00 00 00       	mov    $0x6,%eax
  80178e:	e8 6b ff ff ff       	call   8016fe <fsipc>
}
  801793:	c9                   	leave  
  801794:	c3                   	ret    

00801795 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	53                   	push   %ebx
  801799:	83 ec 04             	sub    $0x4,%esp
  80179c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80179f:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8017af:	b8 05 00 00 00       	mov    $0x5,%eax
  8017b4:	e8 45 ff ff ff       	call   8016fe <fsipc>
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	78 2c                	js     8017e9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017bd:	83 ec 08             	sub    $0x8,%esp
  8017c0:	68 00 50 80 00       	push   $0x805000
  8017c5:	53                   	push   %ebx
  8017c6:	e8 11 f0 ff ff       	call   8007dc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017cb:	a1 80 50 80 00       	mov    0x805080,%eax
  8017d0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017d6:	a1 84 50 80 00       	mov    0x805084,%eax
  8017db:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017e1:	83 c4 10             	add    $0x10,%esp
  8017e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ec:	c9                   	leave  
  8017ed:	c3                   	ret    

008017ee <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	53                   	push   %ebx
  8017f2:	83 ec 08             	sub    $0x8,%esp
  8017f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8017f8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017fd:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801802:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801805:	8b 45 08             	mov    0x8(%ebp),%eax
  801808:	8b 40 0c             	mov    0xc(%eax),%eax
  80180b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801810:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801816:	53                   	push   %ebx
  801817:	ff 75 0c             	pushl  0xc(%ebp)
  80181a:	68 08 50 80 00       	push   $0x805008
  80181f:	e8 4a f1 ff ff       	call   80096e <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801824:	ba 00 00 00 00       	mov    $0x0,%edx
  801829:	b8 04 00 00 00       	mov    $0x4,%eax
  80182e:	e8 cb fe ff ff       	call   8016fe <fsipc>
  801833:	83 c4 10             	add    $0x10,%esp
  801836:	85 c0                	test   %eax,%eax
  801838:	78 3d                	js     801877 <devfile_write+0x89>
		return r;

	assert(r <= n);
  80183a:	39 d8                	cmp    %ebx,%eax
  80183c:	76 19                	jbe    801857 <devfile_write+0x69>
  80183e:	68 2c 28 80 00       	push   $0x80282c
  801843:	68 33 28 80 00       	push   $0x802833
  801848:	68 9f 00 00 00       	push   $0x9f
  80184d:	68 48 28 80 00       	push   $0x802848
  801852:	e8 2a 06 00 00       	call   801e81 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801857:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80185c:	76 19                	jbe    801877 <devfile_write+0x89>
  80185e:	68 60 28 80 00       	push   $0x802860
  801863:	68 33 28 80 00       	push   $0x802833
  801868:	68 a0 00 00 00       	push   $0xa0
  80186d:	68 48 28 80 00       	push   $0x802848
  801872:	e8 0a 06 00 00       	call   801e81 <_panic>

	return r;
}
  801877:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187a:	c9                   	leave  
  80187b:	c3                   	ret    

0080187c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	56                   	push   %esi
  801880:	53                   	push   %ebx
  801881:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801884:	8b 45 08             	mov    0x8(%ebp),%eax
  801887:	8b 40 0c             	mov    0xc(%eax),%eax
  80188a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80188f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801895:	ba 00 00 00 00       	mov    $0x0,%edx
  80189a:	b8 03 00 00 00       	mov    $0x3,%eax
  80189f:	e8 5a fe ff ff       	call   8016fe <fsipc>
  8018a4:	89 c3                	mov    %eax,%ebx
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	78 4b                	js     8018f5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018aa:	39 c6                	cmp    %eax,%esi
  8018ac:	73 16                	jae    8018c4 <devfile_read+0x48>
  8018ae:	68 2c 28 80 00       	push   $0x80282c
  8018b3:	68 33 28 80 00       	push   $0x802833
  8018b8:	6a 7e                	push   $0x7e
  8018ba:	68 48 28 80 00       	push   $0x802848
  8018bf:	e8 bd 05 00 00       	call   801e81 <_panic>
	assert(r <= PGSIZE);
  8018c4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018c9:	7e 16                	jle    8018e1 <devfile_read+0x65>
  8018cb:	68 53 28 80 00       	push   $0x802853
  8018d0:	68 33 28 80 00       	push   $0x802833
  8018d5:	6a 7f                	push   $0x7f
  8018d7:	68 48 28 80 00       	push   $0x802848
  8018dc:	e8 a0 05 00 00       	call   801e81 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018e1:	83 ec 04             	sub    $0x4,%esp
  8018e4:	50                   	push   %eax
  8018e5:	68 00 50 80 00       	push   $0x805000
  8018ea:	ff 75 0c             	pushl  0xc(%ebp)
  8018ed:	e8 7c f0 ff ff       	call   80096e <memmove>
	return r;
  8018f2:	83 c4 10             	add    $0x10,%esp
}
  8018f5:	89 d8                	mov    %ebx,%eax
  8018f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fa:	5b                   	pop    %ebx
  8018fb:	5e                   	pop    %esi
  8018fc:	5d                   	pop    %ebp
  8018fd:	c3                   	ret    

008018fe <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	53                   	push   %ebx
  801902:	83 ec 20             	sub    $0x20,%esp
  801905:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801908:	53                   	push   %ebx
  801909:	e8 95 ee ff ff       	call   8007a3 <strlen>
  80190e:	83 c4 10             	add    $0x10,%esp
  801911:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801916:	7f 67                	jg     80197f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801918:	83 ec 0c             	sub    $0xc,%esp
  80191b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191e:	50                   	push   %eax
  80191f:	e8 52 f8 ff ff       	call   801176 <fd_alloc>
  801924:	83 c4 10             	add    $0x10,%esp
		return r;
  801927:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801929:	85 c0                	test   %eax,%eax
  80192b:	78 57                	js     801984 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80192d:	83 ec 08             	sub    $0x8,%esp
  801930:	53                   	push   %ebx
  801931:	68 00 50 80 00       	push   $0x805000
  801936:	e8 a1 ee ff ff       	call   8007dc <strcpy>
	fsipcbuf.open.req_omode = mode;
  80193b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801943:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801946:	b8 01 00 00 00       	mov    $0x1,%eax
  80194b:	e8 ae fd ff ff       	call   8016fe <fsipc>
  801950:	89 c3                	mov    %eax,%ebx
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	85 c0                	test   %eax,%eax
  801957:	79 14                	jns    80196d <open+0x6f>
		fd_close(fd, 0);
  801959:	83 ec 08             	sub    $0x8,%esp
  80195c:	6a 00                	push   $0x0
  80195e:	ff 75 f4             	pushl  -0xc(%ebp)
  801961:	e8 08 f9 ff ff       	call   80126e <fd_close>
		return r;
  801966:	83 c4 10             	add    $0x10,%esp
  801969:	89 da                	mov    %ebx,%edx
  80196b:	eb 17                	jmp    801984 <open+0x86>
	}

	return fd2num(fd);
  80196d:	83 ec 0c             	sub    $0xc,%esp
  801970:	ff 75 f4             	pushl  -0xc(%ebp)
  801973:	e8 d7 f7 ff ff       	call   80114f <fd2num>
  801978:	89 c2                	mov    %eax,%edx
  80197a:	83 c4 10             	add    $0x10,%esp
  80197d:	eb 05                	jmp    801984 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80197f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801984:	89 d0                	mov    %edx,%eax
  801986:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801989:	c9                   	leave  
  80198a:	c3                   	ret    

0080198b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801991:	ba 00 00 00 00       	mov    $0x0,%edx
  801996:	b8 08 00 00 00       	mov    $0x8,%eax
  80199b:	e8 5e fd ff ff       	call   8016fe <fsipc>
}
  8019a0:	c9                   	leave  
  8019a1:	c3                   	ret    

008019a2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	56                   	push   %esi
  8019a6:	53                   	push   %ebx
  8019a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019aa:	83 ec 0c             	sub    $0xc,%esp
  8019ad:	ff 75 08             	pushl  0x8(%ebp)
  8019b0:	e8 aa f7 ff ff       	call   80115f <fd2data>
  8019b5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019b7:	83 c4 08             	add    $0x8,%esp
  8019ba:	68 8d 28 80 00       	push   $0x80288d
  8019bf:	53                   	push   %ebx
  8019c0:	e8 17 ee ff ff       	call   8007dc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019c5:	8b 46 04             	mov    0x4(%esi),%eax
  8019c8:	2b 06                	sub    (%esi),%eax
  8019ca:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019d0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019d7:	00 00 00 
	stat->st_dev = &devpipe;
  8019da:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019e1:	30 80 00 
	return 0;
}
  8019e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ec:	5b                   	pop    %ebx
  8019ed:	5e                   	pop    %esi
  8019ee:	5d                   	pop    %ebp
  8019ef:	c3                   	ret    

008019f0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	53                   	push   %ebx
  8019f4:	83 ec 0c             	sub    $0xc,%esp
  8019f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019fa:	53                   	push   %ebx
  8019fb:	6a 00                	push   $0x0
  8019fd:	e8 d9 f2 ff ff       	call   800cdb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a02:	89 1c 24             	mov    %ebx,(%esp)
  801a05:	e8 55 f7 ff ff       	call   80115f <fd2data>
  801a0a:	83 c4 08             	add    $0x8,%esp
  801a0d:	50                   	push   %eax
  801a0e:	6a 00                	push   $0x0
  801a10:	e8 c6 f2 ff ff       	call   800cdb <sys_page_unmap>
}
  801a15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a18:	c9                   	leave  
  801a19:	c3                   	ret    

00801a1a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	57                   	push   %edi
  801a1e:	56                   	push   %esi
  801a1f:	53                   	push   %ebx
  801a20:	83 ec 1c             	sub    $0x1c,%esp
  801a23:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a26:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a28:	a1 08 40 80 00       	mov    0x804008,%eax
  801a2d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a30:	83 ec 0c             	sub    $0xc,%esp
  801a33:	ff 75 e0             	pushl  -0x20(%ebp)
  801a36:	e8 13 06 00 00       	call   80204e <pageref>
  801a3b:	89 c3                	mov    %eax,%ebx
  801a3d:	89 3c 24             	mov    %edi,(%esp)
  801a40:	e8 09 06 00 00       	call   80204e <pageref>
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	39 c3                	cmp    %eax,%ebx
  801a4a:	0f 94 c1             	sete   %cl
  801a4d:	0f b6 c9             	movzbl %cl,%ecx
  801a50:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a53:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a59:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a5c:	39 ce                	cmp    %ecx,%esi
  801a5e:	74 1b                	je     801a7b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a60:	39 c3                	cmp    %eax,%ebx
  801a62:	75 c4                	jne    801a28 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a64:	8b 42 58             	mov    0x58(%edx),%eax
  801a67:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a6a:	50                   	push   %eax
  801a6b:	56                   	push   %esi
  801a6c:	68 94 28 80 00       	push   $0x802894
  801a71:	e8 32 e7 ff ff       	call   8001a8 <cprintf>
  801a76:	83 c4 10             	add    $0x10,%esp
  801a79:	eb ad                	jmp    801a28 <_pipeisclosed+0xe>
	}
}
  801a7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a81:	5b                   	pop    %ebx
  801a82:	5e                   	pop    %esi
  801a83:	5f                   	pop    %edi
  801a84:	5d                   	pop    %ebp
  801a85:	c3                   	ret    

00801a86 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	57                   	push   %edi
  801a8a:	56                   	push   %esi
  801a8b:	53                   	push   %ebx
  801a8c:	83 ec 28             	sub    $0x28,%esp
  801a8f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a92:	56                   	push   %esi
  801a93:	e8 c7 f6 ff ff       	call   80115f <fd2data>
  801a98:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	bf 00 00 00 00       	mov    $0x0,%edi
  801aa2:	eb 4b                	jmp    801aef <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aa4:	89 da                	mov    %ebx,%edx
  801aa6:	89 f0                	mov    %esi,%eax
  801aa8:	e8 6d ff ff ff       	call   801a1a <_pipeisclosed>
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	75 48                	jne    801af9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ab1:	e8 81 f1 ff ff       	call   800c37 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ab6:	8b 43 04             	mov    0x4(%ebx),%eax
  801ab9:	8b 0b                	mov    (%ebx),%ecx
  801abb:	8d 51 20             	lea    0x20(%ecx),%edx
  801abe:	39 d0                	cmp    %edx,%eax
  801ac0:	73 e2                	jae    801aa4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ac2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ac9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801acc:	89 c2                	mov    %eax,%edx
  801ace:	c1 fa 1f             	sar    $0x1f,%edx
  801ad1:	89 d1                	mov    %edx,%ecx
  801ad3:	c1 e9 1b             	shr    $0x1b,%ecx
  801ad6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ad9:	83 e2 1f             	and    $0x1f,%edx
  801adc:	29 ca                	sub    %ecx,%edx
  801ade:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ae2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ae6:	83 c0 01             	add    $0x1,%eax
  801ae9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aec:	83 c7 01             	add    $0x1,%edi
  801aef:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801af2:	75 c2                	jne    801ab6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801af4:	8b 45 10             	mov    0x10(%ebp),%eax
  801af7:	eb 05                	jmp    801afe <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801af9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801afe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b01:	5b                   	pop    %ebx
  801b02:	5e                   	pop    %esi
  801b03:	5f                   	pop    %edi
  801b04:	5d                   	pop    %ebp
  801b05:	c3                   	ret    

00801b06 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	57                   	push   %edi
  801b0a:	56                   	push   %esi
  801b0b:	53                   	push   %ebx
  801b0c:	83 ec 18             	sub    $0x18,%esp
  801b0f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b12:	57                   	push   %edi
  801b13:	e8 47 f6 ff ff       	call   80115f <fd2data>
  801b18:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1a:	83 c4 10             	add    $0x10,%esp
  801b1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b22:	eb 3d                	jmp    801b61 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b24:	85 db                	test   %ebx,%ebx
  801b26:	74 04                	je     801b2c <devpipe_read+0x26>
				return i;
  801b28:	89 d8                	mov    %ebx,%eax
  801b2a:	eb 44                	jmp    801b70 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b2c:	89 f2                	mov    %esi,%edx
  801b2e:	89 f8                	mov    %edi,%eax
  801b30:	e8 e5 fe ff ff       	call   801a1a <_pipeisclosed>
  801b35:	85 c0                	test   %eax,%eax
  801b37:	75 32                	jne    801b6b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b39:	e8 f9 f0 ff ff       	call   800c37 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b3e:	8b 06                	mov    (%esi),%eax
  801b40:	3b 46 04             	cmp    0x4(%esi),%eax
  801b43:	74 df                	je     801b24 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b45:	99                   	cltd   
  801b46:	c1 ea 1b             	shr    $0x1b,%edx
  801b49:	01 d0                	add    %edx,%eax
  801b4b:	83 e0 1f             	and    $0x1f,%eax
  801b4e:	29 d0                	sub    %edx,%eax
  801b50:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b58:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b5b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b5e:	83 c3 01             	add    $0x1,%ebx
  801b61:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b64:	75 d8                	jne    801b3e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b66:	8b 45 10             	mov    0x10(%ebp),%eax
  801b69:	eb 05                	jmp    801b70 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b6b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b73:	5b                   	pop    %ebx
  801b74:	5e                   	pop    %esi
  801b75:	5f                   	pop    %edi
  801b76:	5d                   	pop    %ebp
  801b77:	c3                   	ret    

00801b78 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	56                   	push   %esi
  801b7c:	53                   	push   %ebx
  801b7d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b83:	50                   	push   %eax
  801b84:	e8 ed f5 ff ff       	call   801176 <fd_alloc>
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	89 c2                	mov    %eax,%edx
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	0f 88 2c 01 00 00    	js     801cc2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b96:	83 ec 04             	sub    $0x4,%esp
  801b99:	68 07 04 00 00       	push   $0x407
  801b9e:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba1:	6a 00                	push   $0x0
  801ba3:	e8 ae f0 ff ff       	call   800c56 <sys_page_alloc>
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	89 c2                	mov    %eax,%edx
  801bad:	85 c0                	test   %eax,%eax
  801baf:	0f 88 0d 01 00 00    	js     801cc2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bb5:	83 ec 0c             	sub    $0xc,%esp
  801bb8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bbb:	50                   	push   %eax
  801bbc:	e8 b5 f5 ff ff       	call   801176 <fd_alloc>
  801bc1:	89 c3                	mov    %eax,%ebx
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	0f 88 e2 00 00 00    	js     801cb0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bce:	83 ec 04             	sub    $0x4,%esp
  801bd1:	68 07 04 00 00       	push   $0x407
  801bd6:	ff 75 f0             	pushl  -0x10(%ebp)
  801bd9:	6a 00                	push   $0x0
  801bdb:	e8 76 f0 ff ff       	call   800c56 <sys_page_alloc>
  801be0:	89 c3                	mov    %eax,%ebx
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	85 c0                	test   %eax,%eax
  801be7:	0f 88 c3 00 00 00    	js     801cb0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bed:	83 ec 0c             	sub    $0xc,%esp
  801bf0:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf3:	e8 67 f5 ff ff       	call   80115f <fd2data>
  801bf8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfa:	83 c4 0c             	add    $0xc,%esp
  801bfd:	68 07 04 00 00       	push   $0x407
  801c02:	50                   	push   %eax
  801c03:	6a 00                	push   $0x0
  801c05:	e8 4c f0 ff ff       	call   800c56 <sys_page_alloc>
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	83 c4 10             	add    $0x10,%esp
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	0f 88 89 00 00 00    	js     801ca0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c17:	83 ec 0c             	sub    $0xc,%esp
  801c1a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c1d:	e8 3d f5 ff ff       	call   80115f <fd2data>
  801c22:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c29:	50                   	push   %eax
  801c2a:	6a 00                	push   $0x0
  801c2c:	56                   	push   %esi
  801c2d:	6a 00                	push   $0x0
  801c2f:	e8 65 f0 ff ff       	call   800c99 <sys_page_map>
  801c34:	89 c3                	mov    %eax,%ebx
  801c36:	83 c4 20             	add    $0x20,%esp
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	78 55                	js     801c92 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c3d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c46:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c52:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c5b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c60:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c67:	83 ec 0c             	sub    $0xc,%esp
  801c6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6d:	e8 dd f4 ff ff       	call   80114f <fd2num>
  801c72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c75:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c77:	83 c4 04             	add    $0x4,%esp
  801c7a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c7d:	e8 cd f4 ff ff       	call   80114f <fd2num>
  801c82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c85:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c88:	83 c4 10             	add    $0x10,%esp
  801c8b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c90:	eb 30                	jmp    801cc2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c92:	83 ec 08             	sub    $0x8,%esp
  801c95:	56                   	push   %esi
  801c96:	6a 00                	push   $0x0
  801c98:	e8 3e f0 ff ff       	call   800cdb <sys_page_unmap>
  801c9d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ca0:	83 ec 08             	sub    $0x8,%esp
  801ca3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca6:	6a 00                	push   $0x0
  801ca8:	e8 2e f0 ff ff       	call   800cdb <sys_page_unmap>
  801cad:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cb0:	83 ec 08             	sub    $0x8,%esp
  801cb3:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb6:	6a 00                	push   $0x0
  801cb8:	e8 1e f0 ff ff       	call   800cdb <sys_page_unmap>
  801cbd:	83 c4 10             	add    $0x10,%esp
  801cc0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cc2:	89 d0                	mov    %edx,%eax
  801cc4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cc7:	5b                   	pop    %ebx
  801cc8:	5e                   	pop    %esi
  801cc9:	5d                   	pop    %ebp
  801cca:	c3                   	ret    

00801ccb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd4:	50                   	push   %eax
  801cd5:	ff 75 08             	pushl  0x8(%ebp)
  801cd8:	e8 e8 f4 ff ff       	call   8011c5 <fd_lookup>
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	85 c0                	test   %eax,%eax
  801ce2:	78 18                	js     801cfc <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ce4:	83 ec 0c             	sub    $0xc,%esp
  801ce7:	ff 75 f4             	pushl  -0xc(%ebp)
  801cea:	e8 70 f4 ff ff       	call   80115f <fd2data>
	return _pipeisclosed(fd, p);
  801cef:	89 c2                	mov    %eax,%edx
  801cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf4:	e8 21 fd ff ff       	call   801a1a <_pipeisclosed>
  801cf9:	83 c4 10             	add    $0x10,%esp
}
  801cfc:	c9                   	leave  
  801cfd:	c3                   	ret    

00801cfe <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d01:	b8 00 00 00 00       	mov    $0x0,%eax
  801d06:	5d                   	pop    %ebp
  801d07:	c3                   	ret    

00801d08 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d0e:	68 ac 28 80 00       	push   $0x8028ac
  801d13:	ff 75 0c             	pushl  0xc(%ebp)
  801d16:	e8 c1 ea ff ff       	call   8007dc <strcpy>
	return 0;
}
  801d1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d20:	c9                   	leave  
  801d21:	c3                   	ret    

00801d22 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	57                   	push   %edi
  801d26:	56                   	push   %esi
  801d27:	53                   	push   %ebx
  801d28:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d2e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d33:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d39:	eb 2d                	jmp    801d68 <devcons_write+0x46>
		m = n - tot;
  801d3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d3e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d40:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d43:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d48:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d4b:	83 ec 04             	sub    $0x4,%esp
  801d4e:	53                   	push   %ebx
  801d4f:	03 45 0c             	add    0xc(%ebp),%eax
  801d52:	50                   	push   %eax
  801d53:	57                   	push   %edi
  801d54:	e8 15 ec ff ff       	call   80096e <memmove>
		sys_cputs(buf, m);
  801d59:	83 c4 08             	add    $0x8,%esp
  801d5c:	53                   	push   %ebx
  801d5d:	57                   	push   %edi
  801d5e:	e8 37 ee ff ff       	call   800b9a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d63:	01 de                	add    %ebx,%esi
  801d65:	83 c4 10             	add    $0x10,%esp
  801d68:	89 f0                	mov    %esi,%eax
  801d6a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d6d:	72 cc                	jb     801d3b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d72:	5b                   	pop    %ebx
  801d73:	5e                   	pop    %esi
  801d74:	5f                   	pop    %edi
  801d75:	5d                   	pop    %ebp
  801d76:	c3                   	ret    

00801d77 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	83 ec 08             	sub    $0x8,%esp
  801d7d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d82:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d86:	74 2a                	je     801db2 <devcons_read+0x3b>
  801d88:	eb 05                	jmp    801d8f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d8a:	e8 a8 ee ff ff       	call   800c37 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d8f:	e8 24 ee ff ff       	call   800bb8 <sys_cgetc>
  801d94:	85 c0                	test   %eax,%eax
  801d96:	74 f2                	je     801d8a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	78 16                	js     801db2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d9c:	83 f8 04             	cmp    $0x4,%eax
  801d9f:	74 0c                	je     801dad <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801da1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801da4:	88 02                	mov    %al,(%edx)
	return 1;
  801da6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dab:	eb 05                	jmp    801db2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dad:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801db2:	c9                   	leave  
  801db3:	c3                   	ret    

00801db4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dba:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dc0:	6a 01                	push   $0x1
  801dc2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dc5:	50                   	push   %eax
  801dc6:	e8 cf ed ff ff       	call   800b9a <sys_cputs>
}
  801dcb:	83 c4 10             	add    $0x10,%esp
  801dce:	c9                   	leave  
  801dcf:	c3                   	ret    

00801dd0 <getchar>:

int
getchar(void)
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dd6:	6a 01                	push   $0x1
  801dd8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ddb:	50                   	push   %eax
  801ddc:	6a 00                	push   $0x0
  801dde:	e8 48 f6 ff ff       	call   80142b <read>
	if (r < 0)
  801de3:	83 c4 10             	add    $0x10,%esp
  801de6:	85 c0                	test   %eax,%eax
  801de8:	78 0f                	js     801df9 <getchar+0x29>
		return r;
	if (r < 1)
  801dea:	85 c0                	test   %eax,%eax
  801dec:	7e 06                	jle    801df4 <getchar+0x24>
		return -E_EOF;
	return c;
  801dee:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801df2:	eb 05                	jmp    801df9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801df4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    

00801dfb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e04:	50                   	push   %eax
  801e05:	ff 75 08             	pushl  0x8(%ebp)
  801e08:	e8 b8 f3 ff ff       	call   8011c5 <fd_lookup>
  801e0d:	83 c4 10             	add    $0x10,%esp
  801e10:	85 c0                	test   %eax,%eax
  801e12:	78 11                	js     801e25 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e17:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e1d:	39 10                	cmp    %edx,(%eax)
  801e1f:	0f 94 c0             	sete   %al
  801e22:	0f b6 c0             	movzbl %al,%eax
}
  801e25:	c9                   	leave  
  801e26:	c3                   	ret    

00801e27 <opencons>:

int
opencons(void)
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
  801e2a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e30:	50                   	push   %eax
  801e31:	e8 40 f3 ff ff       	call   801176 <fd_alloc>
  801e36:	83 c4 10             	add    $0x10,%esp
		return r;
  801e39:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e3b:	85 c0                	test   %eax,%eax
  801e3d:	78 3e                	js     801e7d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e3f:	83 ec 04             	sub    $0x4,%esp
  801e42:	68 07 04 00 00       	push   $0x407
  801e47:	ff 75 f4             	pushl  -0xc(%ebp)
  801e4a:	6a 00                	push   $0x0
  801e4c:	e8 05 ee ff ff       	call   800c56 <sys_page_alloc>
  801e51:	83 c4 10             	add    $0x10,%esp
		return r;
  801e54:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e56:	85 c0                	test   %eax,%eax
  801e58:	78 23                	js     801e7d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e5a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e63:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e68:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e6f:	83 ec 0c             	sub    $0xc,%esp
  801e72:	50                   	push   %eax
  801e73:	e8 d7 f2 ff ff       	call   80114f <fd2num>
  801e78:	89 c2                	mov    %eax,%edx
  801e7a:	83 c4 10             	add    $0x10,%esp
}
  801e7d:	89 d0                	mov    %edx,%eax
  801e7f:	c9                   	leave  
  801e80:	c3                   	ret    

00801e81 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	56                   	push   %esi
  801e85:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e86:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e89:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e8f:	e8 84 ed ff ff       	call   800c18 <sys_getenvid>
  801e94:	83 ec 0c             	sub    $0xc,%esp
  801e97:	ff 75 0c             	pushl  0xc(%ebp)
  801e9a:	ff 75 08             	pushl  0x8(%ebp)
  801e9d:	56                   	push   %esi
  801e9e:	50                   	push   %eax
  801e9f:	68 b8 28 80 00       	push   $0x8028b8
  801ea4:	e8 ff e2 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ea9:	83 c4 18             	add    $0x18,%esp
  801eac:	53                   	push   %ebx
  801ead:	ff 75 10             	pushl  0x10(%ebp)
  801eb0:	e8 a2 e2 ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  801eb5:	c7 04 24 b4 23 80 00 	movl   $0x8023b4,(%esp)
  801ebc:	e8 e7 e2 ff ff       	call   8001a8 <cprintf>
  801ec1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ec4:	cc                   	int3   
  801ec5:	eb fd                	jmp    801ec4 <_panic+0x43>

00801ec7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801ecd:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ed4:	75 52                	jne    801f28 <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  801ed6:	83 ec 04             	sub    $0x4,%esp
  801ed9:	6a 07                	push   $0x7
  801edb:	68 00 f0 bf ee       	push   $0xeebff000
  801ee0:	6a 00                	push   $0x0
  801ee2:	e8 6f ed ff ff       	call   800c56 <sys_page_alloc>
  801ee7:	83 c4 10             	add    $0x10,%esp
  801eea:	85 c0                	test   %eax,%eax
  801eec:	79 12                	jns    801f00 <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  801eee:	50                   	push   %eax
  801eef:	68 00 27 80 00       	push   $0x802700
  801ef4:	6a 23                	push   $0x23
  801ef6:	68 db 28 80 00       	push   $0x8028db
  801efb:	e8 81 ff ff ff       	call   801e81 <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  801f00:	83 ec 08             	sub    $0x8,%esp
  801f03:	68 32 1f 80 00       	push   $0x801f32
  801f08:	6a 00                	push   $0x0
  801f0a:	e8 92 ee ff ff       	call   800da1 <sys_env_set_pgfault_upcall>
  801f0f:	83 c4 10             	add    $0x10,%esp
  801f12:	85 c0                	test   %eax,%eax
  801f14:	79 12                	jns    801f28 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  801f16:	50                   	push   %eax
  801f17:	68 80 27 80 00       	push   $0x802780
  801f1c:	6a 26                	push   $0x26
  801f1e:	68 db 28 80 00       	push   $0x8028db
  801f23:	e8 59 ff ff ff       	call   801e81 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f28:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2b:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f30:	c9                   	leave  
  801f31:	c3                   	ret    

00801f32 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f32:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f33:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f38:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f3a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  801f3d:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  801f41:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  801f46:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  801f4a:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801f4c:	83 c4 08             	add    $0x8,%esp
	popal 
  801f4f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801f50:	83 c4 04             	add    $0x4,%esp
	popfl
  801f53:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f54:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f55:	c3                   	ret    

00801f56 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f56:	55                   	push   %ebp
  801f57:	89 e5                	mov    %esp,%ebp
  801f59:	56                   	push   %esi
  801f5a:	53                   	push   %ebx
  801f5b:	8b 75 08             	mov    0x8(%ebp),%esi
  801f5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801f64:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f66:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f6b:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801f6e:	83 ec 0c             	sub    $0xc,%esp
  801f71:	50                   	push   %eax
  801f72:	e8 8f ee ff ff       	call   800e06 <sys_ipc_recv>
  801f77:	83 c4 10             	add    $0x10,%esp
  801f7a:	85 c0                	test   %eax,%eax
  801f7c:	79 16                	jns    801f94 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801f7e:	85 f6                	test   %esi,%esi
  801f80:	74 06                	je     801f88 <ipc_recv+0x32>
			*from_env_store = 0;
  801f82:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801f88:	85 db                	test   %ebx,%ebx
  801f8a:	74 2c                	je     801fb8 <ipc_recv+0x62>
			*perm_store = 0;
  801f8c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f92:	eb 24                	jmp    801fb8 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801f94:	85 f6                	test   %esi,%esi
  801f96:	74 0a                	je     801fa2 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801f98:	a1 08 40 80 00       	mov    0x804008,%eax
  801f9d:	8b 40 74             	mov    0x74(%eax),%eax
  801fa0:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801fa2:	85 db                	test   %ebx,%ebx
  801fa4:	74 0a                	je     801fb0 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801fa6:	a1 08 40 80 00       	mov    0x804008,%eax
  801fab:	8b 40 78             	mov    0x78(%eax),%eax
  801fae:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801fb0:	a1 08 40 80 00       	mov    0x804008,%eax
  801fb5:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fbb:	5b                   	pop    %ebx
  801fbc:	5e                   	pop    %esi
  801fbd:	5d                   	pop    %ebp
  801fbe:	c3                   	ret    

00801fbf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fbf:	55                   	push   %ebp
  801fc0:	89 e5                	mov    %esp,%ebp
  801fc2:	57                   	push   %edi
  801fc3:	56                   	push   %esi
  801fc4:	53                   	push   %ebx
  801fc5:	83 ec 0c             	sub    $0xc,%esp
  801fc8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fcb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801fd1:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801fd3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fd8:	0f 44 d8             	cmove  %eax,%ebx
  801fdb:	eb 1e                	jmp    801ffb <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801fdd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fe0:	74 14                	je     801ff6 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801fe2:	83 ec 04             	sub    $0x4,%esp
  801fe5:	68 ec 28 80 00       	push   $0x8028ec
  801fea:	6a 44                	push   $0x44
  801fec:	68 18 29 80 00       	push   $0x802918
  801ff1:	e8 8b fe ff ff       	call   801e81 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801ff6:	e8 3c ec ff ff       	call   800c37 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801ffb:	ff 75 14             	pushl  0x14(%ebp)
  801ffe:	53                   	push   %ebx
  801fff:	56                   	push   %esi
  802000:	57                   	push   %edi
  802001:	e8 dd ed ff ff       	call   800de3 <sys_ipc_try_send>
  802006:	83 c4 10             	add    $0x10,%esp
  802009:	85 c0                	test   %eax,%eax
  80200b:	78 d0                	js     801fdd <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  80200d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802010:	5b                   	pop    %ebx
  802011:	5e                   	pop    %esi
  802012:	5f                   	pop    %edi
  802013:	5d                   	pop    %ebp
  802014:	c3                   	ret    

00802015 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802015:	55                   	push   %ebp
  802016:	89 e5                	mov    %esp,%ebp
  802018:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80201b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802020:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802023:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802029:	8b 52 50             	mov    0x50(%edx),%edx
  80202c:	39 ca                	cmp    %ecx,%edx
  80202e:	75 0d                	jne    80203d <ipc_find_env+0x28>
			return envs[i].env_id;
  802030:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802033:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802038:	8b 40 48             	mov    0x48(%eax),%eax
  80203b:	eb 0f                	jmp    80204c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80203d:	83 c0 01             	add    $0x1,%eax
  802040:	3d 00 04 00 00       	cmp    $0x400,%eax
  802045:	75 d9                	jne    802020 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802047:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80204c:	5d                   	pop    %ebp
  80204d:	c3                   	ret    

0080204e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80204e:	55                   	push   %ebp
  80204f:	89 e5                	mov    %esp,%ebp
  802051:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802054:	89 d0                	mov    %edx,%eax
  802056:	c1 e8 16             	shr    $0x16,%eax
  802059:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802060:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802065:	f6 c1 01             	test   $0x1,%cl
  802068:	74 1d                	je     802087 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80206a:	c1 ea 0c             	shr    $0xc,%edx
  80206d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802074:	f6 c2 01             	test   $0x1,%dl
  802077:	74 0e                	je     802087 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802079:	c1 ea 0c             	shr    $0xc,%edx
  80207c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802083:	ef 
  802084:	0f b7 c0             	movzwl %ax,%eax
}
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    
  802089:	66 90                	xchg   %ax,%ax
  80208b:	66 90                	xchg   %ax,%ax
  80208d:	66 90                	xchg   %ax,%ax
  80208f:	90                   	nop

00802090 <__udivdi3>:
  802090:	55                   	push   %ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
  802097:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80209b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80209f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020a7:	85 f6                	test   %esi,%esi
  8020a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ad:	89 ca                	mov    %ecx,%edx
  8020af:	89 f8                	mov    %edi,%eax
  8020b1:	75 3d                	jne    8020f0 <__udivdi3+0x60>
  8020b3:	39 cf                	cmp    %ecx,%edi
  8020b5:	0f 87 c5 00 00 00    	ja     802180 <__udivdi3+0xf0>
  8020bb:	85 ff                	test   %edi,%edi
  8020bd:	89 fd                	mov    %edi,%ebp
  8020bf:	75 0b                	jne    8020cc <__udivdi3+0x3c>
  8020c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020c6:	31 d2                	xor    %edx,%edx
  8020c8:	f7 f7                	div    %edi
  8020ca:	89 c5                	mov    %eax,%ebp
  8020cc:	89 c8                	mov    %ecx,%eax
  8020ce:	31 d2                	xor    %edx,%edx
  8020d0:	f7 f5                	div    %ebp
  8020d2:	89 c1                	mov    %eax,%ecx
  8020d4:	89 d8                	mov    %ebx,%eax
  8020d6:	89 cf                	mov    %ecx,%edi
  8020d8:	f7 f5                	div    %ebp
  8020da:	89 c3                	mov    %eax,%ebx
  8020dc:	89 d8                	mov    %ebx,%eax
  8020de:	89 fa                	mov    %edi,%edx
  8020e0:	83 c4 1c             	add    $0x1c,%esp
  8020e3:	5b                   	pop    %ebx
  8020e4:	5e                   	pop    %esi
  8020e5:	5f                   	pop    %edi
  8020e6:	5d                   	pop    %ebp
  8020e7:	c3                   	ret    
  8020e8:	90                   	nop
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	39 ce                	cmp    %ecx,%esi
  8020f2:	77 74                	ja     802168 <__udivdi3+0xd8>
  8020f4:	0f bd fe             	bsr    %esi,%edi
  8020f7:	83 f7 1f             	xor    $0x1f,%edi
  8020fa:	0f 84 98 00 00 00    	je     802198 <__udivdi3+0x108>
  802100:	bb 20 00 00 00       	mov    $0x20,%ebx
  802105:	89 f9                	mov    %edi,%ecx
  802107:	89 c5                	mov    %eax,%ebp
  802109:	29 fb                	sub    %edi,%ebx
  80210b:	d3 e6                	shl    %cl,%esi
  80210d:	89 d9                	mov    %ebx,%ecx
  80210f:	d3 ed                	shr    %cl,%ebp
  802111:	89 f9                	mov    %edi,%ecx
  802113:	d3 e0                	shl    %cl,%eax
  802115:	09 ee                	or     %ebp,%esi
  802117:	89 d9                	mov    %ebx,%ecx
  802119:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80211d:	89 d5                	mov    %edx,%ebp
  80211f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802123:	d3 ed                	shr    %cl,%ebp
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e2                	shl    %cl,%edx
  802129:	89 d9                	mov    %ebx,%ecx
  80212b:	d3 e8                	shr    %cl,%eax
  80212d:	09 c2                	or     %eax,%edx
  80212f:	89 d0                	mov    %edx,%eax
  802131:	89 ea                	mov    %ebp,%edx
  802133:	f7 f6                	div    %esi
  802135:	89 d5                	mov    %edx,%ebp
  802137:	89 c3                	mov    %eax,%ebx
  802139:	f7 64 24 0c          	mull   0xc(%esp)
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	72 10                	jb     802151 <__udivdi3+0xc1>
  802141:	8b 74 24 08          	mov    0x8(%esp),%esi
  802145:	89 f9                	mov    %edi,%ecx
  802147:	d3 e6                	shl    %cl,%esi
  802149:	39 c6                	cmp    %eax,%esi
  80214b:	73 07                	jae    802154 <__udivdi3+0xc4>
  80214d:	39 d5                	cmp    %edx,%ebp
  80214f:	75 03                	jne    802154 <__udivdi3+0xc4>
  802151:	83 eb 01             	sub    $0x1,%ebx
  802154:	31 ff                	xor    %edi,%edi
  802156:	89 d8                	mov    %ebx,%eax
  802158:	89 fa                	mov    %edi,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	31 ff                	xor    %edi,%edi
  80216a:	31 db                	xor    %ebx,%ebx
  80216c:	89 d8                	mov    %ebx,%eax
  80216e:	89 fa                	mov    %edi,%edx
  802170:	83 c4 1c             	add    $0x1c,%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    
  802178:	90                   	nop
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 d8                	mov    %ebx,%eax
  802182:	f7 f7                	div    %edi
  802184:	31 ff                	xor    %edi,%edi
  802186:	89 c3                	mov    %eax,%ebx
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	89 fa                	mov    %edi,%edx
  80218c:	83 c4 1c             	add    $0x1c,%esp
  80218f:	5b                   	pop    %ebx
  802190:	5e                   	pop    %esi
  802191:	5f                   	pop    %edi
  802192:	5d                   	pop    %ebp
  802193:	c3                   	ret    
  802194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802198:	39 ce                	cmp    %ecx,%esi
  80219a:	72 0c                	jb     8021a8 <__udivdi3+0x118>
  80219c:	31 db                	xor    %ebx,%ebx
  80219e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021a2:	0f 87 34 ff ff ff    	ja     8020dc <__udivdi3+0x4c>
  8021a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021ad:	e9 2a ff ff ff       	jmp    8020dc <__udivdi3+0x4c>
  8021b2:	66 90                	xchg   %ax,%ax
  8021b4:	66 90                	xchg   %ax,%ax
  8021b6:	66 90                	xchg   %ax,%ax
  8021b8:	66 90                	xchg   %ax,%ax
  8021ba:	66 90                	xchg   %ax,%ax
  8021bc:	66 90                	xchg   %ax,%ax
  8021be:	66 90                	xchg   %ax,%ax

008021c0 <__umoddi3>:
  8021c0:	55                   	push   %ebp
  8021c1:	57                   	push   %edi
  8021c2:	56                   	push   %esi
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 1c             	sub    $0x1c,%esp
  8021c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021d7:	85 d2                	test   %edx,%edx
  8021d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021e1:	89 f3                	mov    %esi,%ebx
  8021e3:	89 3c 24             	mov    %edi,(%esp)
  8021e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ea:	75 1c                	jne    802208 <__umoddi3+0x48>
  8021ec:	39 f7                	cmp    %esi,%edi
  8021ee:	76 50                	jbe    802240 <__umoddi3+0x80>
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	f7 f7                	div    %edi
  8021f6:	89 d0                	mov    %edx,%eax
  8021f8:	31 d2                	xor    %edx,%edx
  8021fa:	83 c4 1c             	add    $0x1c,%esp
  8021fd:	5b                   	pop    %ebx
  8021fe:	5e                   	pop    %esi
  8021ff:	5f                   	pop    %edi
  802200:	5d                   	pop    %ebp
  802201:	c3                   	ret    
  802202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802208:	39 f2                	cmp    %esi,%edx
  80220a:	89 d0                	mov    %edx,%eax
  80220c:	77 52                	ja     802260 <__umoddi3+0xa0>
  80220e:	0f bd ea             	bsr    %edx,%ebp
  802211:	83 f5 1f             	xor    $0x1f,%ebp
  802214:	75 5a                	jne    802270 <__umoddi3+0xb0>
  802216:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80221a:	0f 82 e0 00 00 00    	jb     802300 <__umoddi3+0x140>
  802220:	39 0c 24             	cmp    %ecx,(%esp)
  802223:	0f 86 d7 00 00 00    	jbe    802300 <__umoddi3+0x140>
  802229:	8b 44 24 08          	mov    0x8(%esp),%eax
  80222d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802231:	83 c4 1c             	add    $0x1c,%esp
  802234:	5b                   	pop    %ebx
  802235:	5e                   	pop    %esi
  802236:	5f                   	pop    %edi
  802237:	5d                   	pop    %ebp
  802238:	c3                   	ret    
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	85 ff                	test   %edi,%edi
  802242:	89 fd                	mov    %edi,%ebp
  802244:	75 0b                	jne    802251 <__umoddi3+0x91>
  802246:	b8 01 00 00 00       	mov    $0x1,%eax
  80224b:	31 d2                	xor    %edx,%edx
  80224d:	f7 f7                	div    %edi
  80224f:	89 c5                	mov    %eax,%ebp
  802251:	89 f0                	mov    %esi,%eax
  802253:	31 d2                	xor    %edx,%edx
  802255:	f7 f5                	div    %ebp
  802257:	89 c8                	mov    %ecx,%eax
  802259:	f7 f5                	div    %ebp
  80225b:	89 d0                	mov    %edx,%eax
  80225d:	eb 99                	jmp    8021f8 <__umoddi3+0x38>
  80225f:	90                   	nop
  802260:	89 c8                	mov    %ecx,%eax
  802262:	89 f2                	mov    %esi,%edx
  802264:	83 c4 1c             	add    $0x1c,%esp
  802267:	5b                   	pop    %ebx
  802268:	5e                   	pop    %esi
  802269:	5f                   	pop    %edi
  80226a:	5d                   	pop    %ebp
  80226b:	c3                   	ret    
  80226c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802270:	8b 34 24             	mov    (%esp),%esi
  802273:	bf 20 00 00 00       	mov    $0x20,%edi
  802278:	89 e9                	mov    %ebp,%ecx
  80227a:	29 ef                	sub    %ebp,%edi
  80227c:	d3 e0                	shl    %cl,%eax
  80227e:	89 f9                	mov    %edi,%ecx
  802280:	89 f2                	mov    %esi,%edx
  802282:	d3 ea                	shr    %cl,%edx
  802284:	89 e9                	mov    %ebp,%ecx
  802286:	09 c2                	or     %eax,%edx
  802288:	89 d8                	mov    %ebx,%eax
  80228a:	89 14 24             	mov    %edx,(%esp)
  80228d:	89 f2                	mov    %esi,%edx
  80228f:	d3 e2                	shl    %cl,%edx
  802291:	89 f9                	mov    %edi,%ecx
  802293:	89 54 24 04          	mov    %edx,0x4(%esp)
  802297:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80229b:	d3 e8                	shr    %cl,%eax
  80229d:	89 e9                	mov    %ebp,%ecx
  80229f:	89 c6                	mov    %eax,%esi
  8022a1:	d3 e3                	shl    %cl,%ebx
  8022a3:	89 f9                	mov    %edi,%ecx
  8022a5:	89 d0                	mov    %edx,%eax
  8022a7:	d3 e8                	shr    %cl,%eax
  8022a9:	89 e9                	mov    %ebp,%ecx
  8022ab:	09 d8                	or     %ebx,%eax
  8022ad:	89 d3                	mov    %edx,%ebx
  8022af:	89 f2                	mov    %esi,%edx
  8022b1:	f7 34 24             	divl   (%esp)
  8022b4:	89 d6                	mov    %edx,%esi
  8022b6:	d3 e3                	shl    %cl,%ebx
  8022b8:	f7 64 24 04          	mull   0x4(%esp)
  8022bc:	39 d6                	cmp    %edx,%esi
  8022be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022c2:	89 d1                	mov    %edx,%ecx
  8022c4:	89 c3                	mov    %eax,%ebx
  8022c6:	72 08                	jb     8022d0 <__umoddi3+0x110>
  8022c8:	75 11                	jne    8022db <__umoddi3+0x11b>
  8022ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ce:	73 0b                	jae    8022db <__umoddi3+0x11b>
  8022d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022d4:	1b 14 24             	sbb    (%esp),%edx
  8022d7:	89 d1                	mov    %edx,%ecx
  8022d9:	89 c3                	mov    %eax,%ebx
  8022db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022df:	29 da                	sub    %ebx,%edx
  8022e1:	19 ce                	sbb    %ecx,%esi
  8022e3:	89 f9                	mov    %edi,%ecx
  8022e5:	89 f0                	mov    %esi,%eax
  8022e7:	d3 e0                	shl    %cl,%eax
  8022e9:	89 e9                	mov    %ebp,%ecx
  8022eb:	d3 ea                	shr    %cl,%edx
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	d3 ee                	shr    %cl,%esi
  8022f1:	09 d0                	or     %edx,%eax
  8022f3:	89 f2                	mov    %esi,%edx
  8022f5:	83 c4 1c             	add    $0x1c,%esp
  8022f8:	5b                   	pop    %ebx
  8022f9:	5e                   	pop    %esi
  8022fa:	5f                   	pop    %edi
  8022fb:	5d                   	pop    %ebp
  8022fc:	c3                   	ret    
  8022fd:	8d 76 00             	lea    0x0(%esi),%esi
  802300:	29 f9                	sub    %edi,%ecx
  802302:	19 d6                	sbb    %edx,%esi
  802304:	89 74 24 04          	mov    %esi,0x4(%esp)
  802308:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80230c:	e9 18 ff ff ff       	jmp    802229 <__umoddi3+0x69>
