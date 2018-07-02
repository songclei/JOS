
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 e5 0e 00 00       	call   800f26 <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 d2 0b 00 00       	call   800c21 <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 40 23 80 00       	push   $0x802340
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 55 11 00 00       	call   8011c1 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 d9 10 00 00       	call   801158 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 98 0b 00 00       	call   800c21 <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 56 23 80 00       	push   $0x802356
  800091:	e8 1b 01 00 00       	call   8001b1 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 13 11 00 00       	call   8011c1 <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c9:	e8 53 0b 00 00       	call   800c21 <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010a:	e8 0c 13 00 00       	call   80141b <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 c7 0a 00 00       	call   800be0 <sys_env_destroy>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	53                   	push   %ebx
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800128:	8b 13                	mov    (%ebx),%edx
  80012a:	8d 42 01             	lea    0x1(%edx),%eax
  80012d:	89 03                	mov    %eax,(%ebx)
  80012f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800132:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 1a                	jne    800157 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 55 0a 00 00       	call   800ba3 <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800157:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	ff 75 0c             	pushl  0xc(%ebp)
  800180:	ff 75 08             	pushl  0x8(%ebp)
  800183:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	68 1e 01 80 00       	push   $0x80011e
  80018f:	e8 54 01 00 00       	call   8002e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800194:	83 c4 08             	add    $0x8,%esp
  800197:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 fa 09 00 00       	call   800ba3 <sys_cputs>

	return b.cnt;
}
  8001a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ba:	50                   	push   %eax
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	e8 9d ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 1c             	sub    $0x1c,%esp
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ec:	39 d3                	cmp    %edx,%ebx
  8001ee:	72 05                	jb     8001f5 <printnum+0x30>
  8001f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f3:	77 45                	ja     80023a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	ff 75 18             	pushl  0x18(%ebp)
  8001fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800201:	53                   	push   %ebx
  800202:	ff 75 10             	pushl  0x10(%ebp)
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 87 1e 00 00       	call   8020a0 <__udivdi3>
  800219:	83 c4 18             	add    $0x18,%esp
  80021c:	52                   	push   %edx
  80021d:	50                   	push   %eax
  80021e:	89 f2                	mov    %esi,%edx
  800220:	89 f8                	mov    %edi,%eax
  800222:	e8 9e ff ff ff       	call   8001c5 <printnum>
  800227:	83 c4 20             	add    $0x20,%esp
  80022a:	eb 18                	jmp    800244 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	ff d7                	call   *%edi
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	eb 03                	jmp    80023d <printnum+0x78>
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f e8                	jg     80022c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	56                   	push   %esi
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 74 1f 00 00       	call   8021d0 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 73 23 80 00 	movsbl 0x802373(%eax),%eax
  800266:	50                   	push   %eax
  800267:	ff d7                	call   *%edi
}
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800277:	83 fa 01             	cmp    $0x1,%edx
  80027a:	7e 0e                	jle    80028a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 02                	mov    (%edx),%eax
  800285:	8b 52 04             	mov    0x4(%edx),%edx
  800288:	eb 22                	jmp    8002ac <getuint+0x38>
	else if (lflag)
  80028a:	85 d2                	test   %edx,%edx
  80028c:	74 10                	je     80029e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 04             	lea    0x4(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	ba 00 00 00 00       	mov    $0x0,%edx
  80029c:	eb 0e                	jmp    8002ac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bd:	73 0a                	jae    8002c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c7:	88 02                	mov    %al,(%edx)
}
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d4:	50                   	push   %eax
  8002d5:	ff 75 10             	pushl  0x10(%ebp)
  8002d8:	ff 75 0c             	pushl  0xc(%ebp)
  8002db:	ff 75 08             	pushl  0x8(%ebp)
  8002de:	e8 05 00 00 00       	call   8002e8 <vprintfmt>
	va_end(ap);
}
  8002e3:	83 c4 10             	add    $0x10,%esp
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 2c             	sub    $0x2c,%esp
  8002f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fa:	eb 12                	jmp    80030e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	0f 84 38 04 00 00    	je     80073c <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800304:	83 ec 08             	sub    $0x8,%esp
  800307:	53                   	push   %ebx
  800308:	50                   	push   %eax
  800309:	ff d6                	call   *%esi
  80030b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030e:	83 c7 01             	add    $0x1,%edi
  800311:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800315:	83 f8 25             	cmp    $0x25,%eax
  800318:	75 e2                	jne    8002fc <vprintfmt+0x14>
  80031a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80031e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800325:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800333:	ba 00 00 00 00       	mov    $0x0,%edx
  800338:	eb 07                	jmp    800341 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  80033d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8d 47 01             	lea    0x1(%edi),%eax
  800344:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800347:	0f b6 07             	movzbl (%edi),%eax
  80034a:	0f b6 c8             	movzbl %al,%ecx
  80034d:	83 e8 23             	sub    $0x23,%eax
  800350:	3c 55                	cmp    $0x55,%al
  800352:	0f 87 c9 03 00 00    	ja     800721 <vprintfmt+0x439>
  800358:	0f b6 c0             	movzbl %al,%eax
  80035b:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800365:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800369:	eb d6                	jmp    800341 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  80036b:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  800372:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  800378:	eb 94                	jmp    80030e <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  80037a:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  800381:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  800387:	eb 85                	jmp    80030e <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  800389:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  800390:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  800396:	e9 73 ff ff ff       	jmp    80030e <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  80039b:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  8003a2:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  8003a8:	e9 61 ff ff ff       	jmp    80030e <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  8003ad:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  8003b4:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  8003ba:	e9 4f ff ff ff       	jmp    80030e <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  8003bf:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  8003c6:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  8003cc:	e9 3d ff ff ff       	jmp    80030e <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  8003d1:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  8003d8:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  8003de:	e9 2b ff ff ff       	jmp    80030e <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  8003e3:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  8003ea:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8003f0:	e9 19 ff ff ff       	jmp    80030e <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  8003f5:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  8003fc:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  800402:	e9 07 ff ff ff       	jmp    80030e <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  800407:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  80040e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800411:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800414:	e9 f5 fe ff ff       	jmp    80030e <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041c:	b8 00 00 00 00       	mov    $0x0,%eax
  800421:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800424:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800427:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80042b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80042e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800431:	83 fa 09             	cmp    $0x9,%edx
  800434:	77 3f                	ja     800475 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800436:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800439:	eb e9                	jmp    800424 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	8d 48 04             	lea    0x4(%eax),%ecx
  800441:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800444:	8b 00                	mov    (%eax),%eax
  800446:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80044c:	eb 2d                	jmp    80047b <vprintfmt+0x193>
  80044e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800451:	85 c0                	test   %eax,%eax
  800453:	b9 00 00 00 00       	mov    $0x0,%ecx
  800458:	0f 49 c8             	cmovns %eax,%ecx
  80045b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800461:	e9 db fe ff ff       	jmp    800341 <vprintfmt+0x59>
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800469:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800470:	e9 cc fe ff ff       	jmp    800341 <vprintfmt+0x59>
  800475:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800478:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80047b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047f:	0f 89 bc fe ff ff    	jns    800341 <vprintfmt+0x59>
				width = precision, precision = -1;
  800485:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800488:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800492:	e9 aa fe ff ff       	jmp    800341 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800497:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80049d:	e9 9f fe ff ff       	jmp    800341 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a5:	8d 50 04             	lea    0x4(%eax),%edx
  8004a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	53                   	push   %ebx
  8004af:	ff 30                	pushl  (%eax)
  8004b1:	ff d6                	call   *%esi
			break;
  8004b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b9:	e9 50 fe ff ff       	jmp    80030e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 50 04             	lea    0x4(%eax),%edx
  8004c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c7:	8b 00                	mov    (%eax),%eax
  8004c9:	99                   	cltd   
  8004ca:	31 d0                	xor    %edx,%eax
  8004cc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ce:	83 f8 0f             	cmp    $0xf,%eax
  8004d1:	7f 0b                	jg     8004de <vprintfmt+0x1f6>
  8004d3:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8004da:	85 d2                	test   %edx,%edx
  8004dc:	75 18                	jne    8004f6 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  8004de:	50                   	push   %eax
  8004df:	68 8b 23 80 00       	push   $0x80238b
  8004e4:	53                   	push   %ebx
  8004e5:	56                   	push   %esi
  8004e6:	e8 e0 fd ff ff       	call   8002cb <printfmt>
  8004eb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f1:	e9 18 fe ff ff       	jmp    80030e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004f6:	52                   	push   %edx
  8004f7:	68 3d 28 80 00       	push   $0x80283d
  8004fc:	53                   	push   %ebx
  8004fd:	56                   	push   %esi
  8004fe:	e8 c8 fd ff ff       	call   8002cb <printfmt>
  800503:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800509:	e9 00 fe ff ff       	jmp    80030e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80050e:	8b 45 14             	mov    0x14(%ebp),%eax
  800511:	8d 50 04             	lea    0x4(%eax),%edx
  800514:	89 55 14             	mov    %edx,0x14(%ebp)
  800517:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800519:	85 ff                	test   %edi,%edi
  80051b:	b8 84 23 80 00       	mov    $0x802384,%eax
  800520:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800523:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800527:	0f 8e 94 00 00 00    	jle    8005c1 <vprintfmt+0x2d9>
  80052d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800531:	0f 84 98 00 00 00    	je     8005cf <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	ff 75 d0             	pushl  -0x30(%ebp)
  80053d:	57                   	push   %edi
  80053e:	e8 81 02 00 00       	call   8007c4 <strnlen>
  800543:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800546:	29 c1                	sub    %eax,%ecx
  800548:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80054b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80054e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800552:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800555:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800558:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055a:	eb 0f                	jmp    80056b <vprintfmt+0x283>
					putch(padc, putdat);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	53                   	push   %ebx
  800560:	ff 75 e0             	pushl  -0x20(%ebp)
  800563:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800565:	83 ef 01             	sub    $0x1,%edi
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	85 ff                	test   %edi,%edi
  80056d:	7f ed                	jg     80055c <vprintfmt+0x274>
  80056f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800572:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800575:	85 c9                	test   %ecx,%ecx
  800577:	b8 00 00 00 00       	mov    $0x0,%eax
  80057c:	0f 49 c1             	cmovns %ecx,%eax
  80057f:	29 c1                	sub    %eax,%ecx
  800581:	89 75 08             	mov    %esi,0x8(%ebp)
  800584:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800587:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058a:	89 cb                	mov    %ecx,%ebx
  80058c:	eb 4d                	jmp    8005db <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80058e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800592:	74 1b                	je     8005af <vprintfmt+0x2c7>
  800594:	0f be c0             	movsbl %al,%eax
  800597:	83 e8 20             	sub    $0x20,%eax
  80059a:	83 f8 5e             	cmp    $0x5e,%eax
  80059d:	76 10                	jbe    8005af <vprintfmt+0x2c7>
					putch('?', putdat);
  80059f:	83 ec 08             	sub    $0x8,%esp
  8005a2:	ff 75 0c             	pushl  0xc(%ebp)
  8005a5:	6a 3f                	push   $0x3f
  8005a7:	ff 55 08             	call   *0x8(%ebp)
  8005aa:	83 c4 10             	add    $0x10,%esp
  8005ad:	eb 0d                	jmp    8005bc <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	ff 75 0c             	pushl  0xc(%ebp)
  8005b5:	52                   	push   %edx
  8005b6:	ff 55 08             	call   *0x8(%ebp)
  8005b9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005bc:	83 eb 01             	sub    $0x1,%ebx
  8005bf:	eb 1a                	jmp    8005db <vprintfmt+0x2f3>
  8005c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005cd:	eb 0c                	jmp    8005db <vprintfmt+0x2f3>
  8005cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005db:	83 c7 01             	add    $0x1,%edi
  8005de:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005e2:	0f be d0             	movsbl %al,%edx
  8005e5:	85 d2                	test   %edx,%edx
  8005e7:	74 23                	je     80060c <vprintfmt+0x324>
  8005e9:	85 f6                	test   %esi,%esi
  8005eb:	78 a1                	js     80058e <vprintfmt+0x2a6>
  8005ed:	83 ee 01             	sub    $0x1,%esi
  8005f0:	79 9c                	jns    80058e <vprintfmt+0x2a6>
  8005f2:	89 df                	mov    %ebx,%edi
  8005f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005fa:	eb 18                	jmp    800614 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	53                   	push   %ebx
  800600:	6a 20                	push   $0x20
  800602:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800604:	83 ef 01             	sub    $0x1,%edi
  800607:	83 c4 10             	add    $0x10,%esp
  80060a:	eb 08                	jmp    800614 <vprintfmt+0x32c>
  80060c:	89 df                	mov    %ebx,%edi
  80060e:	8b 75 08             	mov    0x8(%ebp),%esi
  800611:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800614:	85 ff                	test   %edi,%edi
  800616:	7f e4                	jg     8005fc <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800618:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061b:	e9 ee fc ff ff       	jmp    80030e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800620:	83 fa 01             	cmp    $0x1,%edx
  800623:	7e 16                	jle    80063b <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8d 50 08             	lea    0x8(%eax),%edx
  80062b:	89 55 14             	mov    %edx,0x14(%ebp)
  80062e:	8b 50 04             	mov    0x4(%eax),%edx
  800631:	8b 00                	mov    (%eax),%eax
  800633:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800636:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800639:	eb 32                	jmp    80066d <vprintfmt+0x385>
	else if (lflag)
  80063b:	85 d2                	test   %edx,%edx
  80063d:	74 18                	je     800657 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8d 50 04             	lea    0x4(%eax),%edx
  800645:	89 55 14             	mov    %edx,0x14(%ebp)
  800648:	8b 00                	mov    (%eax),%eax
  80064a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064d:	89 c1                	mov    %eax,%ecx
  80064f:	c1 f9 1f             	sar    $0x1f,%ecx
  800652:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800655:	eb 16                	jmp    80066d <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)
  800660:	8b 00                	mov    (%eax),%eax
  800662:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800665:	89 c1                	mov    %eax,%ecx
  800667:	c1 f9 1f             	sar    $0x1f,%ecx
  80066a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80066d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800670:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800673:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800678:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80067c:	79 6f                	jns    8006ed <vprintfmt+0x405>
				putch('-', putdat);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	53                   	push   %ebx
  800682:	6a 2d                	push   $0x2d
  800684:	ff d6                	call   *%esi
				num = -(long long) num;
  800686:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800689:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80068c:	f7 d8                	neg    %eax
  80068e:	83 d2 00             	adc    $0x0,%edx
  800691:	f7 da                	neg    %edx
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	eb 55                	jmp    8006ed <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800698:	8d 45 14             	lea    0x14(%ebp),%eax
  80069b:	e8 d4 fb ff ff       	call   800274 <getuint>
			base = 10;
  8006a0:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8006a5:	eb 46                	jmp    8006ed <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006aa:	e8 c5 fb ff ff       	call   800274 <getuint>
			base = 8;
  8006af:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8006b4:	eb 37                	jmp    8006ed <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	6a 30                	push   $0x30
  8006bc:	ff d6                	call   *%esi
			putch('x', putdat);
  8006be:	83 c4 08             	add    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	6a 78                	push   $0x78
  8006c4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006cf:	8b 00                	mov    (%eax),%eax
  8006d1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006d6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d9:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8006de:	eb 0d                	jmp    8006ed <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e3:	e8 8c fb ff ff       	call   800274 <getuint>
			base = 16;
  8006e8:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ed:	83 ec 0c             	sub    $0xc,%esp
  8006f0:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8006f4:	51                   	push   %ecx
  8006f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f8:	57                   	push   %edi
  8006f9:	52                   	push   %edx
  8006fa:	50                   	push   %eax
  8006fb:	89 da                	mov    %ebx,%edx
  8006fd:	89 f0                	mov    %esi,%eax
  8006ff:	e8 c1 fa ff ff       	call   8001c5 <printnum>
			break;
  800704:	83 c4 20             	add    $0x20,%esp
  800707:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80070a:	e9 ff fb ff ff       	jmp    80030e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	53                   	push   %ebx
  800713:	51                   	push   %ecx
  800714:	ff d6                	call   *%esi
			break;
  800716:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800719:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80071c:	e9 ed fb ff ff       	jmp    80030e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800721:	83 ec 08             	sub    $0x8,%esp
  800724:	53                   	push   %ebx
  800725:	6a 25                	push   $0x25
  800727:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800729:	83 c4 10             	add    $0x10,%esp
  80072c:	eb 03                	jmp    800731 <vprintfmt+0x449>
  80072e:	83 ef 01             	sub    $0x1,%edi
  800731:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800735:	75 f7                	jne    80072e <vprintfmt+0x446>
  800737:	e9 d2 fb ff ff       	jmp    80030e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80073c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80073f:	5b                   	pop    %ebx
  800740:	5e                   	pop    %esi
  800741:	5f                   	pop    %edi
  800742:	5d                   	pop    %ebp
  800743:	c3                   	ret    

00800744 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	83 ec 18             	sub    $0x18,%esp
  80074a:	8b 45 08             	mov    0x8(%ebp),%eax
  80074d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800750:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800753:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800757:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800761:	85 c0                	test   %eax,%eax
  800763:	74 26                	je     80078b <vsnprintf+0x47>
  800765:	85 d2                	test   %edx,%edx
  800767:	7e 22                	jle    80078b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800769:	ff 75 14             	pushl  0x14(%ebp)
  80076c:	ff 75 10             	pushl  0x10(%ebp)
  80076f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800772:	50                   	push   %eax
  800773:	68 ae 02 80 00       	push   $0x8002ae
  800778:	e8 6b fb ff ff       	call   8002e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800780:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800783:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800786:	83 c4 10             	add    $0x10,%esp
  800789:	eb 05                	jmp    800790 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80078b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800790:	c9                   	leave  
  800791:	c3                   	ret    

00800792 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800798:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079b:	50                   	push   %eax
  80079c:	ff 75 10             	pushl  0x10(%ebp)
  80079f:	ff 75 0c             	pushl  0xc(%ebp)
  8007a2:	ff 75 08             	pushl  0x8(%ebp)
  8007a5:	e8 9a ff ff ff       	call   800744 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007aa:	c9                   	leave  
  8007ab:	c3                   	ret    

008007ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b7:	eb 03                	jmp    8007bc <strlen+0x10>
		n++;
  8007b9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c0:	75 f7                	jne    8007b9 <strlen+0xd>
		n++;
	return n;
}
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ca:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d2:	eb 03                	jmp    8007d7 <strnlen+0x13>
		n++;
  8007d4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d7:	39 c2                	cmp    %eax,%edx
  8007d9:	74 08                	je     8007e3 <strnlen+0x1f>
  8007db:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007df:	75 f3                	jne    8007d4 <strnlen+0x10>
  8007e1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	53                   	push   %ebx
  8007e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ef:	89 c2                	mov    %eax,%edx
  8007f1:	83 c2 01             	add    $0x1,%edx
  8007f4:	83 c1 01             	add    $0x1,%ecx
  8007f7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007fb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007fe:	84 db                	test   %bl,%bl
  800800:	75 ef                	jne    8007f1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800802:	5b                   	pop    %ebx
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	53                   	push   %ebx
  800809:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80080c:	53                   	push   %ebx
  80080d:	e8 9a ff ff ff       	call   8007ac <strlen>
  800812:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800815:	ff 75 0c             	pushl  0xc(%ebp)
  800818:	01 d8                	add    %ebx,%eax
  80081a:	50                   	push   %eax
  80081b:	e8 c5 ff ff ff       	call   8007e5 <strcpy>
	return dst;
}
  800820:	89 d8                	mov    %ebx,%eax
  800822:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800825:	c9                   	leave  
  800826:	c3                   	ret    

00800827 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	56                   	push   %esi
  80082b:	53                   	push   %ebx
  80082c:	8b 75 08             	mov    0x8(%ebp),%esi
  80082f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800832:	89 f3                	mov    %esi,%ebx
  800834:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800837:	89 f2                	mov    %esi,%edx
  800839:	eb 0f                	jmp    80084a <strncpy+0x23>
		*dst++ = *src;
  80083b:	83 c2 01             	add    $0x1,%edx
  80083e:	0f b6 01             	movzbl (%ecx),%eax
  800841:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800844:	80 39 01             	cmpb   $0x1,(%ecx)
  800847:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084a:	39 da                	cmp    %ebx,%edx
  80084c:	75 ed                	jne    80083b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80084e:	89 f0                	mov    %esi,%eax
  800850:	5b                   	pop    %ebx
  800851:	5e                   	pop    %esi
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	56                   	push   %esi
  800858:	53                   	push   %ebx
  800859:	8b 75 08             	mov    0x8(%ebp),%esi
  80085c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085f:	8b 55 10             	mov    0x10(%ebp),%edx
  800862:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800864:	85 d2                	test   %edx,%edx
  800866:	74 21                	je     800889 <strlcpy+0x35>
  800868:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80086c:	89 f2                	mov    %esi,%edx
  80086e:	eb 09                	jmp    800879 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800870:	83 c2 01             	add    $0x1,%edx
  800873:	83 c1 01             	add    $0x1,%ecx
  800876:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800879:	39 c2                	cmp    %eax,%edx
  80087b:	74 09                	je     800886 <strlcpy+0x32>
  80087d:	0f b6 19             	movzbl (%ecx),%ebx
  800880:	84 db                	test   %bl,%bl
  800882:	75 ec                	jne    800870 <strlcpy+0x1c>
  800884:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800886:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800889:	29 f0                	sub    %esi,%eax
}
  80088b:	5b                   	pop    %ebx
  80088c:	5e                   	pop    %esi
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800895:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800898:	eb 06                	jmp    8008a0 <strcmp+0x11>
		p++, q++;
  80089a:	83 c1 01             	add    $0x1,%ecx
  80089d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a0:	0f b6 01             	movzbl (%ecx),%eax
  8008a3:	84 c0                	test   %al,%al
  8008a5:	74 04                	je     8008ab <strcmp+0x1c>
  8008a7:	3a 02                	cmp    (%edx),%al
  8008a9:	74 ef                	je     80089a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ab:	0f b6 c0             	movzbl %al,%eax
  8008ae:	0f b6 12             	movzbl (%edx),%edx
  8008b1:	29 d0                	sub    %edx,%eax
}
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	53                   	push   %ebx
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bf:	89 c3                	mov    %eax,%ebx
  8008c1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c4:	eb 06                	jmp    8008cc <strncmp+0x17>
		n--, p++, q++;
  8008c6:	83 c0 01             	add    $0x1,%eax
  8008c9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008cc:	39 d8                	cmp    %ebx,%eax
  8008ce:	74 15                	je     8008e5 <strncmp+0x30>
  8008d0:	0f b6 08             	movzbl (%eax),%ecx
  8008d3:	84 c9                	test   %cl,%cl
  8008d5:	74 04                	je     8008db <strncmp+0x26>
  8008d7:	3a 0a                	cmp    (%edx),%cl
  8008d9:	74 eb                	je     8008c6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008db:	0f b6 00             	movzbl (%eax),%eax
  8008de:	0f b6 12             	movzbl (%edx),%edx
  8008e1:	29 d0                	sub    %edx,%eax
  8008e3:	eb 05                	jmp    8008ea <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ea:	5b                   	pop    %ebx
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f7:	eb 07                	jmp    800900 <strchr+0x13>
		if (*s == c)
  8008f9:	38 ca                	cmp    %cl,%dl
  8008fb:	74 0f                	je     80090c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008fd:	83 c0 01             	add    $0x1,%eax
  800900:	0f b6 10             	movzbl (%eax),%edx
  800903:	84 d2                	test   %dl,%dl
  800905:	75 f2                	jne    8008f9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800918:	eb 03                	jmp    80091d <strfind+0xf>
  80091a:	83 c0 01             	add    $0x1,%eax
  80091d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800920:	38 ca                	cmp    %cl,%dl
  800922:	74 04                	je     800928 <strfind+0x1a>
  800924:	84 d2                	test   %dl,%dl
  800926:	75 f2                	jne    80091a <strfind+0xc>
			break;
	return (char *) s;
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	57                   	push   %edi
  80092e:	56                   	push   %esi
  80092f:	53                   	push   %ebx
  800930:	8b 7d 08             	mov    0x8(%ebp),%edi
  800933:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800936:	85 c9                	test   %ecx,%ecx
  800938:	74 36                	je     800970 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800940:	75 28                	jne    80096a <memset+0x40>
  800942:	f6 c1 03             	test   $0x3,%cl
  800945:	75 23                	jne    80096a <memset+0x40>
		c &= 0xFF;
  800947:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094b:	89 d3                	mov    %edx,%ebx
  80094d:	c1 e3 08             	shl    $0x8,%ebx
  800950:	89 d6                	mov    %edx,%esi
  800952:	c1 e6 18             	shl    $0x18,%esi
  800955:	89 d0                	mov    %edx,%eax
  800957:	c1 e0 10             	shl    $0x10,%eax
  80095a:	09 f0                	or     %esi,%eax
  80095c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80095e:	89 d8                	mov    %ebx,%eax
  800960:	09 d0                	or     %edx,%eax
  800962:	c1 e9 02             	shr    $0x2,%ecx
  800965:	fc                   	cld    
  800966:	f3 ab                	rep stos %eax,%es:(%edi)
  800968:	eb 06                	jmp    800970 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096d:	fc                   	cld    
  80096e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800970:	89 f8                	mov    %edi,%eax
  800972:	5b                   	pop    %ebx
  800973:	5e                   	pop    %esi
  800974:	5f                   	pop    %edi
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	57                   	push   %edi
  80097b:	56                   	push   %esi
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800982:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800985:	39 c6                	cmp    %eax,%esi
  800987:	73 35                	jae    8009be <memmove+0x47>
  800989:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098c:	39 d0                	cmp    %edx,%eax
  80098e:	73 2e                	jae    8009be <memmove+0x47>
		s += n;
		d += n;
  800990:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800993:	89 d6                	mov    %edx,%esi
  800995:	09 fe                	or     %edi,%esi
  800997:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80099d:	75 13                	jne    8009b2 <memmove+0x3b>
  80099f:	f6 c1 03             	test   $0x3,%cl
  8009a2:	75 0e                	jne    8009b2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009a4:	83 ef 04             	sub    $0x4,%edi
  8009a7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009aa:	c1 e9 02             	shr    $0x2,%ecx
  8009ad:	fd                   	std    
  8009ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b0:	eb 09                	jmp    8009bb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b2:	83 ef 01             	sub    $0x1,%edi
  8009b5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009b8:	fd                   	std    
  8009b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009bb:	fc                   	cld    
  8009bc:	eb 1d                	jmp    8009db <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009be:	89 f2                	mov    %esi,%edx
  8009c0:	09 c2                	or     %eax,%edx
  8009c2:	f6 c2 03             	test   $0x3,%dl
  8009c5:	75 0f                	jne    8009d6 <memmove+0x5f>
  8009c7:	f6 c1 03             	test   $0x3,%cl
  8009ca:	75 0a                	jne    8009d6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009cc:	c1 e9 02             	shr    $0x2,%ecx
  8009cf:	89 c7                	mov    %eax,%edi
  8009d1:	fc                   	cld    
  8009d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d4:	eb 05                	jmp    8009db <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d6:	89 c7                	mov    %eax,%edi
  8009d8:	fc                   	cld    
  8009d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009db:	5e                   	pop    %esi
  8009dc:	5f                   	pop    %edi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e2:	ff 75 10             	pushl  0x10(%ebp)
  8009e5:	ff 75 0c             	pushl  0xc(%ebp)
  8009e8:	ff 75 08             	pushl  0x8(%ebp)
  8009eb:	e8 87 ff ff ff       	call   800977 <memmove>
}
  8009f0:	c9                   	leave  
  8009f1:	c3                   	ret    

008009f2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fd:	89 c6                	mov    %eax,%esi
  8009ff:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a02:	eb 1a                	jmp    800a1e <memcmp+0x2c>
		if (*s1 != *s2)
  800a04:	0f b6 08             	movzbl (%eax),%ecx
  800a07:	0f b6 1a             	movzbl (%edx),%ebx
  800a0a:	38 d9                	cmp    %bl,%cl
  800a0c:	74 0a                	je     800a18 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a0e:	0f b6 c1             	movzbl %cl,%eax
  800a11:	0f b6 db             	movzbl %bl,%ebx
  800a14:	29 d8                	sub    %ebx,%eax
  800a16:	eb 0f                	jmp    800a27 <memcmp+0x35>
		s1++, s2++;
  800a18:	83 c0 01             	add    $0x1,%eax
  800a1b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1e:	39 f0                	cmp    %esi,%eax
  800a20:	75 e2                	jne    800a04 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a27:	5b                   	pop    %ebx
  800a28:	5e                   	pop    %esi
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a32:	89 c1                	mov    %eax,%ecx
  800a34:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a37:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3b:	eb 0a                	jmp    800a47 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3d:	0f b6 10             	movzbl (%eax),%edx
  800a40:	39 da                	cmp    %ebx,%edx
  800a42:	74 07                	je     800a4b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a44:	83 c0 01             	add    $0x1,%eax
  800a47:	39 c8                	cmp    %ecx,%eax
  800a49:	72 f2                	jb     800a3d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a4b:	5b                   	pop    %ebx
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	57                   	push   %edi
  800a52:	56                   	push   %esi
  800a53:	53                   	push   %ebx
  800a54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5a:	eb 03                	jmp    800a5f <strtol+0x11>
		s++;
  800a5c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5f:	0f b6 01             	movzbl (%ecx),%eax
  800a62:	3c 20                	cmp    $0x20,%al
  800a64:	74 f6                	je     800a5c <strtol+0xe>
  800a66:	3c 09                	cmp    $0x9,%al
  800a68:	74 f2                	je     800a5c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6a:	3c 2b                	cmp    $0x2b,%al
  800a6c:	75 0a                	jne    800a78 <strtol+0x2a>
		s++;
  800a6e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a71:	bf 00 00 00 00       	mov    $0x0,%edi
  800a76:	eb 11                	jmp    800a89 <strtol+0x3b>
  800a78:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a7d:	3c 2d                	cmp    $0x2d,%al
  800a7f:	75 08                	jne    800a89 <strtol+0x3b>
		s++, neg = 1;
  800a81:	83 c1 01             	add    $0x1,%ecx
  800a84:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a89:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a8f:	75 15                	jne    800aa6 <strtol+0x58>
  800a91:	80 39 30             	cmpb   $0x30,(%ecx)
  800a94:	75 10                	jne    800aa6 <strtol+0x58>
  800a96:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a9a:	75 7c                	jne    800b18 <strtol+0xca>
		s += 2, base = 16;
  800a9c:	83 c1 02             	add    $0x2,%ecx
  800a9f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa4:	eb 16                	jmp    800abc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aa6:	85 db                	test   %ebx,%ebx
  800aa8:	75 12                	jne    800abc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aaa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aaf:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab2:	75 08                	jne    800abc <strtol+0x6e>
		s++, base = 8;
  800ab4:	83 c1 01             	add    $0x1,%ecx
  800ab7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800abc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac4:	0f b6 11             	movzbl (%ecx),%edx
  800ac7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aca:	89 f3                	mov    %esi,%ebx
  800acc:	80 fb 09             	cmp    $0x9,%bl
  800acf:	77 08                	ja     800ad9 <strtol+0x8b>
			dig = *s - '0';
  800ad1:	0f be d2             	movsbl %dl,%edx
  800ad4:	83 ea 30             	sub    $0x30,%edx
  800ad7:	eb 22                	jmp    800afb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ad9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800adc:	89 f3                	mov    %esi,%ebx
  800ade:	80 fb 19             	cmp    $0x19,%bl
  800ae1:	77 08                	ja     800aeb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ae3:	0f be d2             	movsbl %dl,%edx
  800ae6:	83 ea 57             	sub    $0x57,%edx
  800ae9:	eb 10                	jmp    800afb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aeb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aee:	89 f3                	mov    %esi,%ebx
  800af0:	80 fb 19             	cmp    $0x19,%bl
  800af3:	77 16                	ja     800b0b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800af5:	0f be d2             	movsbl %dl,%edx
  800af8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800afb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800afe:	7d 0b                	jge    800b0b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b00:	83 c1 01             	add    $0x1,%ecx
  800b03:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b07:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b09:	eb b9                	jmp    800ac4 <strtol+0x76>

	if (endptr)
  800b0b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0f:	74 0d                	je     800b1e <strtol+0xd0>
		*endptr = (char *) s;
  800b11:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b14:	89 0e                	mov    %ecx,(%esi)
  800b16:	eb 06                	jmp    800b1e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b18:	85 db                	test   %ebx,%ebx
  800b1a:	74 98                	je     800ab4 <strtol+0x66>
  800b1c:	eb 9e                	jmp    800abc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b1e:	89 c2                	mov    %eax,%edx
  800b20:	f7 da                	neg    %edx
  800b22:	85 ff                	test   %edi,%edi
  800b24:	0f 45 c2             	cmovne %edx,%eax
}
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5f                   	pop    %edi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	83 ec 04             	sub    $0x4,%esp
  800b35:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800b38:	57                   	push   %edi
  800b39:	e8 6e fc ff ff       	call   8007ac <strlen>
  800b3e:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b41:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800b44:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800b49:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b4e:	eb 46                	jmp    800b96 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800b50:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800b54:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b57:	80 f9 09             	cmp    $0x9,%cl
  800b5a:	77 08                	ja     800b64 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800b5c:	0f be d2             	movsbl %dl,%edx
  800b5f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b62:	eb 27                	jmp    800b8b <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800b64:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800b67:	80 f9 05             	cmp    $0x5,%cl
  800b6a:	77 08                	ja     800b74 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800b6c:	0f be d2             	movsbl %dl,%edx
  800b6f:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800b72:	eb 17                	jmp    800b8b <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800b74:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800b77:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800b7a:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800b7f:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800b83:	77 06                	ja     800b8b <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800b85:	0f be d2             	movsbl %dl,%edx
  800b88:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800b8b:	0f af ce             	imul   %esi,%ecx
  800b8e:	01 c8                	add    %ecx,%eax
		base *= 16;
  800b90:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b93:	83 eb 01             	sub    $0x1,%ebx
  800b96:	83 fb 01             	cmp    $0x1,%ebx
  800b99:	7f b5                	jg     800b50 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800b9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb4:	89 c3                	mov    %eax,%ebx
  800bb6:	89 c7                	mov    %eax,%edi
  800bb8:	89 c6                	mov    %eax,%esi
  800bba:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcc:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd1:	89 d1                	mov    %edx,%ecx
  800bd3:	89 d3                	mov    %edx,%ebx
  800bd5:	89 d7                	mov    %edx,%edi
  800bd7:	89 d6                	mov    %edx,%esi
  800bd9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bee:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf6:	89 cb                	mov    %ecx,%ebx
  800bf8:	89 cf                	mov    %ecx,%edi
  800bfa:	89 ce                	mov    %ecx,%esi
  800bfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	7e 17                	jle    800c19 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c02:	83 ec 0c             	sub    $0xc,%esp
  800c05:	50                   	push   %eax
  800c06:	6a 03                	push   $0x3
  800c08:	68 7f 26 80 00       	push   $0x80267f
  800c0d:	6a 23                	push   $0x23
  800c0f:	68 9c 26 80 00       	push   $0x80269c
  800c14:	e8 69 13 00 00       	call   801f82 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2c:	b8 02 00 00 00       	mov    $0x2,%eax
  800c31:	89 d1                	mov    %edx,%ecx
  800c33:	89 d3                	mov    %edx,%ebx
  800c35:	89 d7                	mov    %edx,%edi
  800c37:	89 d6                	mov    %edx,%esi
  800c39:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <sys_yield>:

void
sys_yield(void)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c50:	89 d1                	mov    %edx,%ecx
  800c52:	89 d3                	mov    %edx,%ebx
  800c54:	89 d7                	mov    %edx,%edi
  800c56:	89 d6                	mov    %edx,%esi
  800c58:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
  800c65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c68:	be 00 00 00 00       	mov    $0x0,%esi
  800c6d:	b8 04 00 00 00       	mov    $0x4,%eax
  800c72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c75:	8b 55 08             	mov    0x8(%ebp),%edx
  800c78:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7b:	89 f7                	mov    %esi,%edi
  800c7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 17                	jle    800c9a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 04                	push   $0x4
  800c89:	68 7f 26 80 00       	push   $0x80267f
  800c8e:	6a 23                	push   $0x23
  800c90:	68 9c 26 80 00       	push   $0x80269c
  800c95:	e8 e8 12 00 00       	call   801f82 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbc:	8b 75 18             	mov    0x18(%ebp),%esi
  800cbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7e 17                	jle    800cdc <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	50                   	push   %eax
  800cc9:	6a 05                	push   $0x5
  800ccb:	68 7f 26 80 00       	push   $0x80267f
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 9c 26 80 00       	push   $0x80269c
  800cd7:	e8 a6 12 00 00       	call   801f82 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf2:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	89 df                	mov    %ebx,%edi
  800cff:	89 de                	mov    %ebx,%esi
  800d01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 17                	jle    800d1e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	50                   	push   %eax
  800d0b:	6a 06                	push   $0x6
  800d0d:	68 7f 26 80 00       	push   $0x80267f
  800d12:	6a 23                	push   $0x23
  800d14:	68 9c 26 80 00       	push   $0x80269c
  800d19:	e8 64 12 00 00       	call   801f82 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d34:	b8 08 00 00 00       	mov    $0x8,%eax
  800d39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	89 df                	mov    %ebx,%edi
  800d41:	89 de                	mov    %ebx,%esi
  800d43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7e 17                	jle    800d60 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	50                   	push   %eax
  800d4d:	6a 08                	push   $0x8
  800d4f:	68 7f 26 80 00       	push   $0x80267f
  800d54:	6a 23                	push   $0x23
  800d56:	68 9c 26 80 00       	push   $0x80269c
  800d5b:	e8 22 12 00 00       	call   801f82 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d76:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	89 df                	mov    %ebx,%edi
  800d83:	89 de                	mov    %ebx,%esi
  800d85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	7e 17                	jle    800da2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	50                   	push   %eax
  800d8f:	6a 0a                	push   $0xa
  800d91:	68 7f 26 80 00       	push   $0x80267f
  800d96:	6a 23                	push   $0x23
  800d98:	68 9c 26 80 00       	push   $0x80269c
  800d9d:	e8 e0 11 00 00       	call   801f82 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800da2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db8:	b8 09 00 00 00       	mov    $0x9,%eax
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	89 df                	mov    %ebx,%edi
  800dc5:	89 de                	mov    %ebx,%esi
  800dc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	7e 17                	jle    800de4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcd:	83 ec 0c             	sub    $0xc,%esp
  800dd0:	50                   	push   %eax
  800dd1:	6a 09                	push   $0x9
  800dd3:	68 7f 26 80 00       	push   $0x80267f
  800dd8:	6a 23                	push   $0x23
  800dda:	68 9c 26 80 00       	push   $0x80269c
  800ddf:	e8 9e 11 00 00       	call   801f82 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de7:	5b                   	pop    %ebx
  800de8:	5e                   	pop    %esi
  800de9:	5f                   	pop    %edi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	57                   	push   %edi
  800df0:	56                   	push   %esi
  800df1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df2:	be 00 00 00 00       	mov    $0x0,%esi
  800df7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dff:	8b 55 08             	mov    0x8(%ebp),%edx
  800e02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e05:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e08:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e0a:	5b                   	pop    %ebx
  800e0b:	5e                   	pop    %esi
  800e0c:	5f                   	pop    %edi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	57                   	push   %edi
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
  800e15:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e18:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e22:	8b 55 08             	mov    0x8(%ebp),%edx
  800e25:	89 cb                	mov    %ecx,%ebx
  800e27:	89 cf                	mov    %ecx,%edi
  800e29:	89 ce                	mov    %ecx,%esi
  800e2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	7e 17                	jle    800e48 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e31:	83 ec 0c             	sub    $0xc,%esp
  800e34:	50                   	push   %eax
  800e35:	6a 0d                	push   $0xd
  800e37:	68 7f 26 80 00       	push   $0x80267f
  800e3c:	6a 23                	push   $0x23
  800e3e:	68 9c 26 80 00       	push   $0x80269c
  800e43:	e8 3a 11 00 00       	call   801f82 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	53                   	push   %ebx
  800e54:	83 ec 04             	sub    $0x4,%esp
  800e57:	8b 45 08             	mov    0x8(%ebp),%eax

	
	void *addr = (void *) utf->utf_fault_va;
  800e5a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800e5c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e60:	74 11                	je     800e73 <pgfault+0x23>
  800e62:	89 d8                	mov    %ebx,%eax
  800e64:	c1 e8 0c             	shr    $0xc,%eax
  800e67:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e6e:	f6 c4 08             	test   $0x8,%ah
  800e71:	75 14                	jne    800e87 <pgfault+0x37>
		panic("page fault");
  800e73:	83 ec 04             	sub    $0x4,%esp
  800e76:	68 aa 26 80 00       	push   $0x8026aa
  800e7b:	6a 5b                	push   $0x5b
  800e7d:	68 b5 26 80 00       	push   $0x8026b5
  800e82:	e8 fb 10 00 00       	call   801f82 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// allocate a new page and map it at a temporary location
	if((r = sys_page_alloc(0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800e87:	83 ec 04             	sub    $0x4,%esp
  800e8a:	6a 07                	push   $0x7
  800e8c:	68 00 f0 7f 00       	push   $0x7ff000
  800e91:	6a 00                	push   $0x0
  800e93:	e8 c7 fd ff ff       	call   800c5f <sys_page_alloc>
  800e98:	83 c4 10             	add    $0x10,%esp
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	79 12                	jns    800eb1 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800e9f:	50                   	push   %eax
  800ea0:	68 c0 26 80 00       	push   $0x8026c0
  800ea5:	6a 66                	push   $0x66
  800ea7:	68 b5 26 80 00       	push   $0x8026b5
  800eac:	e8 d1 10 00 00       	call   801f82 <_panic>

	// copy date to new page
	//strncpy((char *)PFTEMP, (char *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
	memcpy((void *)PFTEMP, (void *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
  800eb1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800eb7:	83 ec 04             	sub    $0x4,%esp
  800eba:	68 00 10 00 00       	push   $0x1000
  800ebf:	53                   	push   %ebx
  800ec0:	68 00 f0 7f 00       	push   $0x7ff000
  800ec5:	e8 15 fb ff ff       	call   8009df <memcpy>

	// move the new page to the old page's address
	if((r = sys_page_map(0, (void *)PFTEMP, 0, (void *)
  800eca:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ed1:	53                   	push   %ebx
  800ed2:	6a 00                	push   $0x0
  800ed4:	68 00 f0 7f 00       	push   $0x7ff000
  800ed9:	6a 00                	push   $0x0
  800edb:	e8 c2 fd ff ff       	call   800ca2 <sys_page_map>
  800ee0:	83 c4 20             	add    $0x20,%esp
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	79 12                	jns    800ef9 <pgfault+0xa9>
		(ROUNDDOWN(addr, PGSIZE)), PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_map: %e", r);
  800ee7:	50                   	push   %eax
  800ee8:	68 d3 26 80 00       	push   $0x8026d3
  800eed:	6a 6f                	push   $0x6f
  800eef:	68 b5 26 80 00       	push   $0x8026b5
  800ef4:	e8 89 10 00 00       	call   801f82 <_panic>

	// unmap page on PFTEMP
	if((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800ef9:	83 ec 08             	sub    $0x8,%esp
  800efc:	68 00 f0 7f 00       	push   $0x7ff000
  800f01:	6a 00                	push   $0x0
  800f03:	e8 dc fd ff ff       	call   800ce4 <sys_page_unmap>
  800f08:	83 c4 10             	add    $0x10,%esp
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	79 12                	jns    800f21 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  800f0f:	50                   	push   %eax
  800f10:	68 e4 26 80 00       	push   $0x8026e4
  800f15:	6a 73                	push   $0x73
  800f17:	68 b5 26 80 00       	push   $0x8026b5
  800f1c:	e8 61 10 00 00       	call   801f82 <_panic>


}
  800f21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f24:	c9                   	leave  
  800f25:	c3                   	ret    

00800f26 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
  800f2c:	83 ec 28             	sub    $0x28,%esp

	#ifdef CHALLENGE 
	set_exception_handler(pgfault, T_PGFLT);
	#else
	// set up page fault handler
	set_pgfault_handler(pgfault);
  800f2f:	68 50 0e 80 00       	push   $0x800e50
  800f34:	e8 8f 10 00 00       	call   801fc8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f39:	b8 07 00 00 00       	mov    $0x7,%eax
  800f3e:	cd 30                	int    $0x30
  800f40:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f43:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	#endif

	// create a child
	envid = sys_exofork();
	if (envid < 0)
  800f46:	83 c4 10             	add    $0x10,%esp
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	79 15                	jns    800f62 <fork+0x3c>
		panic("sys_exofork: %e", envid);
  800f4d:	50                   	push   %eax
  800f4e:	68 f7 26 80 00       	push   $0x8026f7
  800f53:	68 d0 00 00 00       	push   $0xd0
  800f58:	68 b5 26 80 00       	push   $0x8026b5
  800f5d:	e8 20 10 00 00       	call   801f82 <_panic>
  800f62:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f67:	be 00 08 00 00       	mov    $0x800,%esi
	// we are the child
	if(envid == 0) {
  800f6c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f70:	75 21                	jne    800f93 <fork+0x6d>
		// the copied valude of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800f72:	e8 aa fc ff ff       	call   800c21 <sys_getenvid>
  800f77:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f7c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f7f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f84:	a3 08 40 80 00       	mov    %eax,0x804008
		/*// alloc exception stack
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
			PTE_P | PTE_U | PTE_W)) < 0)
			panic("sys_page_alloc: %e", r);*/

		return 0;
  800f89:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8e:	e9 a3 01 00 00       	jmp    801136 <fork+0x210>
{
	int r;

	// LAB 4: Your code here.
	
	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P))
  800f93:	89 d8                	mov    %ebx,%eax
  800f95:	c1 e8 16             	shr    $0x16,%eax
  800f98:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f9f:	a8 01                	test   $0x1,%al
  800fa1:	0f 84 f0 00 00 00    	je     801097 <fork+0x171>
		return 0;

	// virtual page pn's page table entry
	pte_t pe = uvpt[pn];
  800fa7:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi


	if((pe & PTE_P) && (pe & PTE_U)) {
  800fae:	89 f8                	mov    %edi,%eax
  800fb0:	83 e0 05             	and    $0x5,%eax
  800fb3:	83 f8 05             	cmp    $0x5,%eax
  800fb6:	0f 85 db 00 00 00    	jne    801097 <fork+0x171>
		// share with the child environment 
		if(pe & PTE_SHARE) {
  800fbc:	f7 c7 00 04 00 00    	test   $0x400,%edi
  800fc2:	74 36                	je     800ffa <fork+0xd4>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  800fc4:	83 ec 0c             	sub    $0xc,%esp
  800fc7:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  800fcd:	57                   	push   %edi
  800fce:	53                   	push   %ebx
  800fcf:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd2:	53                   	push   %ebx
  800fd3:	6a 00                	push   $0x0
  800fd5:	e8 c8 fc ff ff       	call   800ca2 <sys_page_map>
  800fda:	83 c4 20             	add    $0x20,%esp
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	0f 89 b2 00 00 00    	jns    801097 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  800fe5:	50                   	push   %eax
  800fe6:	68 07 27 80 00       	push   $0x802707
  800feb:	68 97 00 00 00       	push   $0x97
  800ff0:	68 b5 26 80 00       	push   $0x8026b5
  800ff5:	e8 88 0f 00 00       	call   801f82 <_panic>
		}
		// the page is writable or copy-on-write
		else if((pe & PTE_W) || (pe & PTE_COW)) {
  800ffa:	f7 c7 02 08 00 00    	test   $0x802,%edi
  801000:	74 63                	je     801065 <fork+0x13f>
			// create the child mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, 
  801002:	81 e7 05 06 00 00    	and    $0x605,%edi
  801008:	81 cf 00 08 00 00    	or     $0x800,%edi
  80100e:	83 ec 0c             	sub    $0xc,%esp
  801011:	57                   	push   %edi
  801012:	53                   	push   %ebx
  801013:	ff 75 e4             	pushl  -0x1c(%ebp)
  801016:	53                   	push   %ebx
  801017:	6a 00                	push   $0x0
  801019:	e8 84 fc ff ff       	call   800ca2 <sys_page_map>
  80101e:	83 c4 20             	add    $0x20,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	79 15                	jns    80103a <fork+0x114>
				(void *)(pn*PGSIZE), (pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  801025:	50                   	push   %eax
  801026:	68 07 27 80 00       	push   $0x802707
  80102b:	68 9e 00 00 00       	push   $0x9e
  801030:	68 b5 26 80 00       	push   $0x8026b5
  801035:	e8 48 0f 00 00       	call   801f82 <_panic>
			// map the parent mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE),
  80103a:	83 ec 0c             	sub    $0xc,%esp
  80103d:	57                   	push   %edi
  80103e:	53                   	push   %ebx
  80103f:	6a 00                	push   $0x0
  801041:	53                   	push   %ebx
  801042:	6a 00                	push   $0x0
  801044:	e8 59 fc ff ff       	call   800ca2 <sys_page_map>
  801049:	83 c4 20             	add    $0x20,%esp
  80104c:	85 c0                	test   %eax,%eax
  80104e:	79 47                	jns    801097 <fork+0x171>
				(pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  801050:	50                   	push   %eax
  801051:	68 07 27 80 00       	push   $0x802707
  801056:	68 a2 00 00 00       	push   $0xa2
  80105b:	68 b5 26 80 00       	push   $0x8026b5
  801060:	e8 1d 0f 00 00       	call   801f82 <_panic>
		}	
		else {
			// create the child mapping read only
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  801065:	83 ec 0c             	sub    $0xc,%esp
  801068:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  80106e:	57                   	push   %edi
  80106f:	53                   	push   %ebx
  801070:	ff 75 e4             	pushl  -0x1c(%ebp)
  801073:	53                   	push   %ebx
  801074:	6a 00                	push   $0x0
  801076:	e8 27 fc ff ff       	call   800ca2 <sys_page_map>
  80107b:	83 c4 20             	add    $0x20,%esp
  80107e:	85 c0                	test   %eax,%eax
  801080:	79 15                	jns    801097 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  801082:	50                   	push   %eax
  801083:	68 07 27 80 00       	push   $0x802707
  801088:	68 a8 00 00 00       	push   $0xa8
  80108d:	68 b5 26 80 00       	push   $0x8026b5
  801092:	e8 eb 0e 00 00       	call   801f82 <_panic>
			panic("sys_page_alloc: %e", r);*/

		return 0;
	}
	// copy address to child environment's page dirctory
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn)
  801097:	83 c6 01             	add    $0x1,%esi
  80109a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010a0:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8010a6:	0f 85 e7 fe ff ff    	jne    800f93 <fork+0x6d>
	#ifdef CHALLENGE 
	if((r = sys_env_set_exception_upcall(envid, thisenv->env_exception_upcall)) < 0)
		panic("sys_env_set_exception_upcall: %e", r);
	#else
	// set child's page fault handler
	if((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  8010ac:	a1 08 40 80 00       	mov    0x804008,%eax
  8010b1:	8b 40 64             	mov    0x64(%eax),%eax
  8010b4:	83 ec 08             	sub    $0x8,%esp
  8010b7:	50                   	push   %eax
  8010b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8010bb:	e8 ea fc ff ff       	call   800daa <sys_env_set_pgfault_upcall>
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	79 15                	jns    8010dc <fork+0x1b6>
		panic("sys_env_set_pgfault_upcall: %e", r);
  8010c7:	50                   	push   %eax
  8010c8:	68 40 27 80 00       	push   $0x802740
  8010cd:	68 e9 00 00 00       	push   $0xe9
  8010d2:	68 b5 26 80 00       	push   $0x8026b5
  8010d7:	e8 a6 0e 00 00       	call   801f82 <_panic>
	#endif

	// alloc exception stack for child environment
	if((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), 
  8010dc:	83 ec 04             	sub    $0x4,%esp
  8010df:	6a 07                	push   $0x7
  8010e1:	68 00 f0 bf ee       	push   $0xeebff000
  8010e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8010e9:	e8 71 fb ff ff       	call   800c5f <sys_page_alloc>
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	79 15                	jns    80110a <fork+0x1e4>
		PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
  8010f5:	50                   	push   %eax
  8010f6:	68 c0 26 80 00       	push   $0x8026c0
  8010fb:	68 ef 00 00 00       	push   $0xef
  801100:	68 b5 26 80 00       	push   $0x8026b5
  801105:	e8 78 0e 00 00       	call   801f82 <_panic>

	// start the child environment running
	if((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80110a:	83 ec 08             	sub    $0x8,%esp
  80110d:	6a 02                	push   $0x2
  80110f:	ff 75 e0             	pushl  -0x20(%ebp)
  801112:	e8 0f fc ff ff       	call   800d26 <sys_env_set_status>
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	85 c0                	test   %eax,%eax
  80111c:	79 15                	jns    801133 <fork+0x20d>
		panic("sys_env_set_status: %e", r);
  80111e:	50                   	push   %eax
  80111f:	68 13 27 80 00       	push   $0x802713
  801124:	68 f3 00 00 00       	push   $0xf3
  801129:	68 b5 26 80 00       	push   $0x8026b5
  80112e:	e8 4f 0e 00 00       	call   801f82 <_panic>

	return envid;
  801133:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801136:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801139:	5b                   	pop    %ebx
  80113a:	5e                   	pop    %esi
  80113b:	5f                   	pop    %edi
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <sfork>:

// Challenge!
int
sfork(void)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801144:	68 2a 27 80 00       	push   $0x80272a
  801149:	68 fc 00 00 00       	push   $0xfc
  80114e:	68 b5 26 80 00       	push   $0x8026b5
  801153:	e8 2a 0e 00 00       	call   801f82 <_panic>

00801158 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
  80115d:	8b 75 08             	mov    0x8(%ebp),%esi
  801160:	8b 45 0c             	mov    0xc(%ebp),%eax
  801163:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801166:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801168:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80116d:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801170:	83 ec 0c             	sub    $0xc,%esp
  801173:	50                   	push   %eax
  801174:	e8 96 fc ff ff       	call   800e0f <sys_ipc_recv>
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	85 c0                	test   %eax,%eax
  80117e:	79 16                	jns    801196 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801180:	85 f6                	test   %esi,%esi
  801182:	74 06                	je     80118a <ipc_recv+0x32>
			*from_env_store = 0;
  801184:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  80118a:	85 db                	test   %ebx,%ebx
  80118c:	74 2c                	je     8011ba <ipc_recv+0x62>
			*perm_store = 0;
  80118e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801194:	eb 24                	jmp    8011ba <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801196:	85 f6                	test   %esi,%esi
  801198:	74 0a                	je     8011a4 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  80119a:	a1 08 40 80 00       	mov    0x804008,%eax
  80119f:	8b 40 74             	mov    0x74(%eax),%eax
  8011a2:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  8011a4:	85 db                	test   %ebx,%ebx
  8011a6:	74 0a                	je     8011b2 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  8011a8:	a1 08 40 80 00       	mov    0x804008,%eax
  8011ad:	8b 40 78             	mov    0x78(%eax),%eax
  8011b0:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  8011b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8011b7:	8b 40 70             	mov    0x70(%eax),%eax
}
  8011ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011bd:	5b                   	pop    %ebx
  8011be:	5e                   	pop    %esi
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    

008011c1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	57                   	push   %edi
  8011c5:	56                   	push   %esi
  8011c6:	53                   	push   %ebx
  8011c7:	83 ec 0c             	sub    $0xc,%esp
  8011ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8011d3:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8011d5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011da:	0f 44 d8             	cmove  %eax,%ebx
  8011dd:	eb 1e                	jmp    8011fd <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  8011df:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011e2:	74 14                	je     8011f8 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  8011e4:	83 ec 04             	sub    $0x4,%esp
  8011e7:	68 60 27 80 00       	push   $0x802760
  8011ec:	6a 44                	push   $0x44
  8011ee:	68 8b 27 80 00       	push   $0x80278b
  8011f3:	e8 8a 0d 00 00       	call   801f82 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  8011f8:	e8 43 fa ff ff       	call   800c40 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8011fd:	ff 75 14             	pushl  0x14(%ebp)
  801200:	53                   	push   %ebx
  801201:	56                   	push   %esi
  801202:	57                   	push   %edi
  801203:	e8 e4 fb ff ff       	call   800dec <sys_ipc_try_send>
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	85 c0                	test   %eax,%eax
  80120d:	78 d0                	js     8011df <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  80120f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801212:	5b                   	pop    %ebx
  801213:	5e                   	pop    %esi
  801214:	5f                   	pop    %edi
  801215:	5d                   	pop    %ebp
  801216:	c3                   	ret    

00801217 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80121d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801222:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801225:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80122b:	8b 52 50             	mov    0x50(%edx),%edx
  80122e:	39 ca                	cmp    %ecx,%edx
  801230:	75 0d                	jne    80123f <ipc_find_env+0x28>
			return envs[i].env_id;
  801232:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801235:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80123a:	8b 40 48             	mov    0x48(%eax),%eax
  80123d:	eb 0f                	jmp    80124e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80123f:	83 c0 01             	add    $0x1,%eax
  801242:	3d 00 04 00 00       	cmp    $0x400,%eax
  801247:	75 d9                	jne    801222 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801249:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801253:	8b 45 08             	mov    0x8(%ebp),%eax
  801256:	05 00 00 00 30       	add    $0x30000000,%eax
  80125b:	c1 e8 0c             	shr    $0xc,%eax
}
  80125e:	5d                   	pop    %ebp
  80125f:	c3                   	ret    

00801260 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801263:	8b 45 08             	mov    0x8(%ebp),%eax
  801266:	05 00 00 00 30       	add    $0x30000000,%eax
  80126b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801270:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    

00801277 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80127d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801282:	89 c2                	mov    %eax,%edx
  801284:	c1 ea 16             	shr    $0x16,%edx
  801287:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80128e:	f6 c2 01             	test   $0x1,%dl
  801291:	74 11                	je     8012a4 <fd_alloc+0x2d>
  801293:	89 c2                	mov    %eax,%edx
  801295:	c1 ea 0c             	shr    $0xc,%edx
  801298:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80129f:	f6 c2 01             	test   $0x1,%dl
  8012a2:	75 09                	jne    8012ad <fd_alloc+0x36>
			*fd_store = fd;
  8012a4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ab:	eb 17                	jmp    8012c4 <fd_alloc+0x4d>
  8012ad:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012b2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012b7:	75 c9                	jne    801282 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012b9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012bf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    

008012c6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012cc:	83 f8 1f             	cmp    $0x1f,%eax
  8012cf:	77 36                	ja     801307 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012d1:	c1 e0 0c             	shl    $0xc,%eax
  8012d4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012d9:	89 c2                	mov    %eax,%edx
  8012db:	c1 ea 16             	shr    $0x16,%edx
  8012de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012e5:	f6 c2 01             	test   $0x1,%dl
  8012e8:	74 24                	je     80130e <fd_lookup+0x48>
  8012ea:	89 c2                	mov    %eax,%edx
  8012ec:	c1 ea 0c             	shr    $0xc,%edx
  8012ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f6:	f6 c2 01             	test   $0x1,%dl
  8012f9:	74 1a                	je     801315 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012fe:	89 02                	mov    %eax,(%edx)
	return 0;
  801300:	b8 00 00 00 00       	mov    $0x0,%eax
  801305:	eb 13                	jmp    80131a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801307:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130c:	eb 0c                	jmp    80131a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80130e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801313:	eb 05                	jmp    80131a <fd_lookup+0x54>
  801315:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    

0080131c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	83 ec 08             	sub    $0x8,%esp
  801322:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801325:	ba 14 28 80 00       	mov    $0x802814,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80132a:	eb 13                	jmp    80133f <dev_lookup+0x23>
  80132c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80132f:	39 08                	cmp    %ecx,(%eax)
  801331:	75 0c                	jne    80133f <dev_lookup+0x23>
			*dev = devtab[i];
  801333:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801336:	89 01                	mov    %eax,(%ecx)
			return 0;
  801338:	b8 00 00 00 00       	mov    $0x0,%eax
  80133d:	eb 2e                	jmp    80136d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80133f:	8b 02                	mov    (%edx),%eax
  801341:	85 c0                	test   %eax,%eax
  801343:	75 e7                	jne    80132c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801345:	a1 08 40 80 00       	mov    0x804008,%eax
  80134a:	8b 40 48             	mov    0x48(%eax),%eax
  80134d:	83 ec 04             	sub    $0x4,%esp
  801350:	51                   	push   %ecx
  801351:	50                   	push   %eax
  801352:	68 98 27 80 00       	push   $0x802798
  801357:	e8 55 ee ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  80135c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801365:	83 c4 10             	add    $0x10,%esp
  801368:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80136d:	c9                   	leave  
  80136e:	c3                   	ret    

0080136f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	56                   	push   %esi
  801373:	53                   	push   %ebx
  801374:	83 ec 10             	sub    $0x10,%esp
  801377:	8b 75 08             	mov    0x8(%ebp),%esi
  80137a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80137d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801380:	50                   	push   %eax
  801381:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801387:	c1 e8 0c             	shr    $0xc,%eax
  80138a:	50                   	push   %eax
  80138b:	e8 36 ff ff ff       	call   8012c6 <fd_lookup>
  801390:	83 c4 08             	add    $0x8,%esp
  801393:	85 c0                	test   %eax,%eax
  801395:	78 05                	js     80139c <fd_close+0x2d>
	    || fd != fd2) 
  801397:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80139a:	74 0c                	je     8013a8 <fd_close+0x39>
		return (must_exist ? r : 0); 
  80139c:	84 db                	test   %bl,%bl
  80139e:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a3:	0f 44 c2             	cmove  %edx,%eax
  8013a6:	eb 41                	jmp    8013e9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ae:	50                   	push   %eax
  8013af:	ff 36                	pushl  (%esi)
  8013b1:	e8 66 ff ff ff       	call   80131c <dev_lookup>
  8013b6:	89 c3                	mov    %eax,%ebx
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	78 1a                	js     8013d9 <fd_close+0x6a>
		if (dev->dev_close) 
  8013bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8013c5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	74 0b                	je     8013d9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013ce:	83 ec 0c             	sub    $0xc,%esp
  8013d1:	56                   	push   %esi
  8013d2:	ff d0                	call   *%eax
  8013d4:	89 c3                	mov    %eax,%ebx
  8013d6:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013d9:	83 ec 08             	sub    $0x8,%esp
  8013dc:	56                   	push   %esi
  8013dd:	6a 00                	push   $0x0
  8013df:	e8 00 f9 ff ff       	call   800ce4 <sys_page_unmap>
	return r;
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	89 d8                	mov    %ebx,%eax
}
  8013e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ec:	5b                   	pop    %ebx
  8013ed:	5e                   	pop    %esi
  8013ee:	5d                   	pop    %ebp
  8013ef:	c3                   	ret    

008013f0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
  8013f3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f9:	50                   	push   %eax
  8013fa:	ff 75 08             	pushl  0x8(%ebp)
  8013fd:	e8 c4 fe ff ff       	call   8012c6 <fd_lookup>
  801402:	83 c4 08             	add    $0x8,%esp
  801405:	85 c0                	test   %eax,%eax
  801407:	78 10                	js     801419 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  801409:	83 ec 08             	sub    $0x8,%esp
  80140c:	6a 01                	push   $0x1
  80140e:	ff 75 f4             	pushl  -0xc(%ebp)
  801411:	e8 59 ff ff ff       	call   80136f <fd_close>
  801416:	83 c4 10             	add    $0x10,%esp
}
  801419:	c9                   	leave  
  80141a:	c3                   	ret    

0080141b <close_all>:

void
close_all(void)
{
  80141b:	55                   	push   %ebp
  80141c:	89 e5                	mov    %esp,%ebp
  80141e:	53                   	push   %ebx
  80141f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801422:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801427:	83 ec 0c             	sub    $0xc,%esp
  80142a:	53                   	push   %ebx
  80142b:	e8 c0 ff ff ff       	call   8013f0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801430:	83 c3 01             	add    $0x1,%ebx
  801433:	83 c4 10             	add    $0x10,%esp
  801436:	83 fb 20             	cmp    $0x20,%ebx
  801439:	75 ec                	jne    801427 <close_all+0xc>
		close(i);
}
  80143b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143e:	c9                   	leave  
  80143f:	c3                   	ret    

00801440 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	57                   	push   %edi
  801444:	56                   	push   %esi
  801445:	53                   	push   %ebx
  801446:	83 ec 2c             	sub    $0x2c,%esp
  801449:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80144c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80144f:	50                   	push   %eax
  801450:	ff 75 08             	pushl  0x8(%ebp)
  801453:	e8 6e fe ff ff       	call   8012c6 <fd_lookup>
  801458:	83 c4 08             	add    $0x8,%esp
  80145b:	85 c0                	test   %eax,%eax
  80145d:	0f 88 c1 00 00 00    	js     801524 <dup+0xe4>
		return r;
	close(newfdnum);
  801463:	83 ec 0c             	sub    $0xc,%esp
  801466:	56                   	push   %esi
  801467:	e8 84 ff ff ff       	call   8013f0 <close>

	newfd = INDEX2FD(newfdnum);
  80146c:	89 f3                	mov    %esi,%ebx
  80146e:	c1 e3 0c             	shl    $0xc,%ebx
  801471:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801477:	83 c4 04             	add    $0x4,%esp
  80147a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80147d:	e8 de fd ff ff       	call   801260 <fd2data>
  801482:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801484:	89 1c 24             	mov    %ebx,(%esp)
  801487:	e8 d4 fd ff ff       	call   801260 <fd2data>
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801492:	89 f8                	mov    %edi,%eax
  801494:	c1 e8 16             	shr    $0x16,%eax
  801497:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80149e:	a8 01                	test   $0x1,%al
  8014a0:	74 37                	je     8014d9 <dup+0x99>
  8014a2:	89 f8                	mov    %edi,%eax
  8014a4:	c1 e8 0c             	shr    $0xc,%eax
  8014a7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014ae:	f6 c2 01             	test   $0x1,%dl
  8014b1:	74 26                	je     8014d9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014b3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ba:	83 ec 0c             	sub    $0xc,%esp
  8014bd:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c2:	50                   	push   %eax
  8014c3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014c6:	6a 00                	push   $0x0
  8014c8:	57                   	push   %edi
  8014c9:	6a 00                	push   $0x0
  8014cb:	e8 d2 f7 ff ff       	call   800ca2 <sys_page_map>
  8014d0:	89 c7                	mov    %eax,%edi
  8014d2:	83 c4 20             	add    $0x20,%esp
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 2e                	js     801507 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014dc:	89 d0                	mov    %edx,%eax
  8014de:	c1 e8 0c             	shr    $0xc,%eax
  8014e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014e8:	83 ec 0c             	sub    $0xc,%esp
  8014eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f0:	50                   	push   %eax
  8014f1:	53                   	push   %ebx
  8014f2:	6a 00                	push   $0x0
  8014f4:	52                   	push   %edx
  8014f5:	6a 00                	push   $0x0
  8014f7:	e8 a6 f7 ff ff       	call   800ca2 <sys_page_map>
  8014fc:	89 c7                	mov    %eax,%edi
  8014fe:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801501:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801503:	85 ff                	test   %edi,%edi
  801505:	79 1d                	jns    801524 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801507:	83 ec 08             	sub    $0x8,%esp
  80150a:	53                   	push   %ebx
  80150b:	6a 00                	push   $0x0
  80150d:	e8 d2 f7 ff ff       	call   800ce4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801512:	83 c4 08             	add    $0x8,%esp
  801515:	ff 75 d4             	pushl  -0x2c(%ebp)
  801518:	6a 00                	push   $0x0
  80151a:	e8 c5 f7 ff ff       	call   800ce4 <sys_page_unmap>
	return r;
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	89 f8                	mov    %edi,%eax
}
  801524:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801527:	5b                   	pop    %ebx
  801528:	5e                   	pop    %esi
  801529:	5f                   	pop    %edi
  80152a:	5d                   	pop    %ebp
  80152b:	c3                   	ret    

0080152c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	53                   	push   %ebx
  801530:	83 ec 14             	sub    $0x14,%esp
  801533:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801536:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801539:	50                   	push   %eax
  80153a:	53                   	push   %ebx
  80153b:	e8 86 fd ff ff       	call   8012c6 <fd_lookup>
  801540:	83 c4 08             	add    $0x8,%esp
  801543:	89 c2                	mov    %eax,%edx
  801545:	85 c0                	test   %eax,%eax
  801547:	78 6d                	js     8015b6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801549:	83 ec 08             	sub    $0x8,%esp
  80154c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154f:	50                   	push   %eax
  801550:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801553:	ff 30                	pushl  (%eax)
  801555:	e8 c2 fd ff ff       	call   80131c <dev_lookup>
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	85 c0                	test   %eax,%eax
  80155f:	78 4c                	js     8015ad <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801561:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801564:	8b 42 08             	mov    0x8(%edx),%eax
  801567:	83 e0 03             	and    $0x3,%eax
  80156a:	83 f8 01             	cmp    $0x1,%eax
  80156d:	75 21                	jne    801590 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80156f:	a1 08 40 80 00       	mov    0x804008,%eax
  801574:	8b 40 48             	mov    0x48(%eax),%eax
  801577:	83 ec 04             	sub    $0x4,%esp
  80157a:	53                   	push   %ebx
  80157b:	50                   	push   %eax
  80157c:	68 d9 27 80 00       	push   $0x8027d9
  801581:	e8 2b ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80158e:	eb 26                	jmp    8015b6 <read+0x8a>
	}
	if (!dev->dev_read)
  801590:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801593:	8b 40 08             	mov    0x8(%eax),%eax
  801596:	85 c0                	test   %eax,%eax
  801598:	74 17                	je     8015b1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80159a:	83 ec 04             	sub    $0x4,%esp
  80159d:	ff 75 10             	pushl  0x10(%ebp)
  8015a0:	ff 75 0c             	pushl  0xc(%ebp)
  8015a3:	52                   	push   %edx
  8015a4:	ff d0                	call   *%eax
  8015a6:	89 c2                	mov    %eax,%edx
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	eb 09                	jmp    8015b6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ad:	89 c2                	mov    %eax,%edx
  8015af:	eb 05                	jmp    8015b6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015b6:	89 d0                	mov    %edx,%eax
  8015b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bb:	c9                   	leave  
  8015bc:	c3                   	ret    

008015bd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
  8015c0:	57                   	push   %edi
  8015c1:	56                   	push   %esi
  8015c2:	53                   	push   %ebx
  8015c3:	83 ec 0c             	sub    $0xc,%esp
  8015c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d1:	eb 21                	jmp    8015f4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015d3:	83 ec 04             	sub    $0x4,%esp
  8015d6:	89 f0                	mov    %esi,%eax
  8015d8:	29 d8                	sub    %ebx,%eax
  8015da:	50                   	push   %eax
  8015db:	89 d8                	mov    %ebx,%eax
  8015dd:	03 45 0c             	add    0xc(%ebp),%eax
  8015e0:	50                   	push   %eax
  8015e1:	57                   	push   %edi
  8015e2:	e8 45 ff ff ff       	call   80152c <read>
		if (m < 0)
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	85 c0                	test   %eax,%eax
  8015ec:	78 10                	js     8015fe <readn+0x41>
			return m;
		if (m == 0)
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	74 0a                	je     8015fc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f2:	01 c3                	add    %eax,%ebx
  8015f4:	39 f3                	cmp    %esi,%ebx
  8015f6:	72 db                	jb     8015d3 <readn+0x16>
  8015f8:	89 d8                	mov    %ebx,%eax
  8015fa:	eb 02                	jmp    8015fe <readn+0x41>
  8015fc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801601:	5b                   	pop    %ebx
  801602:	5e                   	pop    %esi
  801603:	5f                   	pop    %edi
  801604:	5d                   	pop    %ebp
  801605:	c3                   	ret    

00801606 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	53                   	push   %ebx
  80160a:	83 ec 14             	sub    $0x14,%esp
  80160d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801610:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801613:	50                   	push   %eax
  801614:	53                   	push   %ebx
  801615:	e8 ac fc ff ff       	call   8012c6 <fd_lookup>
  80161a:	83 c4 08             	add    $0x8,%esp
  80161d:	89 c2                	mov    %eax,%edx
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 68                	js     80168b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801623:	83 ec 08             	sub    $0x8,%esp
  801626:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801629:	50                   	push   %eax
  80162a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162d:	ff 30                	pushl  (%eax)
  80162f:	e8 e8 fc ff ff       	call   80131c <dev_lookup>
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	85 c0                	test   %eax,%eax
  801639:	78 47                	js     801682 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801642:	75 21                	jne    801665 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801644:	a1 08 40 80 00       	mov    0x804008,%eax
  801649:	8b 40 48             	mov    0x48(%eax),%eax
  80164c:	83 ec 04             	sub    $0x4,%esp
  80164f:	53                   	push   %ebx
  801650:	50                   	push   %eax
  801651:	68 f5 27 80 00       	push   $0x8027f5
  801656:	e8 56 eb ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801663:	eb 26                	jmp    80168b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801665:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801668:	8b 52 0c             	mov    0xc(%edx),%edx
  80166b:	85 d2                	test   %edx,%edx
  80166d:	74 17                	je     801686 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80166f:	83 ec 04             	sub    $0x4,%esp
  801672:	ff 75 10             	pushl  0x10(%ebp)
  801675:	ff 75 0c             	pushl  0xc(%ebp)
  801678:	50                   	push   %eax
  801679:	ff d2                	call   *%edx
  80167b:	89 c2                	mov    %eax,%edx
  80167d:	83 c4 10             	add    $0x10,%esp
  801680:	eb 09                	jmp    80168b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801682:	89 c2                	mov    %eax,%edx
  801684:	eb 05                	jmp    80168b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801686:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80168b:	89 d0                	mov    %edx,%eax
  80168d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801690:	c9                   	leave  
  801691:	c3                   	ret    

00801692 <seek>:

int
seek(int fdnum, off_t offset)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801698:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80169b:	50                   	push   %eax
  80169c:	ff 75 08             	pushl  0x8(%ebp)
  80169f:	e8 22 fc ff ff       	call   8012c6 <fd_lookup>
  8016a4:	83 c4 08             	add    $0x8,%esp
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	78 0e                	js     8016b9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016b9:	c9                   	leave  
  8016ba:	c3                   	ret    

008016bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	53                   	push   %ebx
  8016bf:	83 ec 14             	sub    $0x14,%esp
  8016c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c8:	50                   	push   %eax
  8016c9:	53                   	push   %ebx
  8016ca:	e8 f7 fb ff ff       	call   8012c6 <fd_lookup>
  8016cf:	83 c4 08             	add    $0x8,%esp
  8016d2:	89 c2                	mov    %eax,%edx
  8016d4:	85 c0                	test   %eax,%eax
  8016d6:	78 65                	js     80173d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d8:	83 ec 08             	sub    $0x8,%esp
  8016db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016de:	50                   	push   %eax
  8016df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e2:	ff 30                	pushl  (%eax)
  8016e4:	e8 33 fc ff ff       	call   80131c <dev_lookup>
  8016e9:	83 c4 10             	add    $0x10,%esp
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 44                	js     801734 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016f7:	75 21                	jne    80171a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016f9:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016fe:	8b 40 48             	mov    0x48(%eax),%eax
  801701:	83 ec 04             	sub    $0x4,%esp
  801704:	53                   	push   %ebx
  801705:	50                   	push   %eax
  801706:	68 b8 27 80 00       	push   $0x8027b8
  80170b:	e8 a1 ea ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801718:	eb 23                	jmp    80173d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80171a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80171d:	8b 52 18             	mov    0x18(%edx),%edx
  801720:	85 d2                	test   %edx,%edx
  801722:	74 14                	je     801738 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801724:	83 ec 08             	sub    $0x8,%esp
  801727:	ff 75 0c             	pushl  0xc(%ebp)
  80172a:	50                   	push   %eax
  80172b:	ff d2                	call   *%edx
  80172d:	89 c2                	mov    %eax,%edx
  80172f:	83 c4 10             	add    $0x10,%esp
  801732:	eb 09                	jmp    80173d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801734:	89 c2                	mov    %eax,%edx
  801736:	eb 05                	jmp    80173d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801738:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80173d:	89 d0                	mov    %edx,%eax
  80173f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801742:	c9                   	leave  
  801743:	c3                   	ret    

00801744 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	53                   	push   %ebx
  801748:	83 ec 14             	sub    $0x14,%esp
  80174b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801751:	50                   	push   %eax
  801752:	ff 75 08             	pushl  0x8(%ebp)
  801755:	e8 6c fb ff ff       	call   8012c6 <fd_lookup>
  80175a:	83 c4 08             	add    $0x8,%esp
  80175d:	89 c2                	mov    %eax,%edx
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 58                	js     8017bb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801763:	83 ec 08             	sub    $0x8,%esp
  801766:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801769:	50                   	push   %eax
  80176a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176d:	ff 30                	pushl  (%eax)
  80176f:	e8 a8 fb ff ff       	call   80131c <dev_lookup>
  801774:	83 c4 10             	add    $0x10,%esp
  801777:	85 c0                	test   %eax,%eax
  801779:	78 37                	js     8017b2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80177b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801782:	74 32                	je     8017b6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801784:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801787:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80178e:	00 00 00 
	stat->st_isdir = 0;
  801791:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801798:	00 00 00 
	stat->st_dev = dev;
  80179b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017a1:	83 ec 08             	sub    $0x8,%esp
  8017a4:	53                   	push   %ebx
  8017a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8017a8:	ff 50 14             	call   *0x14(%eax)
  8017ab:	89 c2                	mov    %eax,%edx
  8017ad:	83 c4 10             	add    $0x10,%esp
  8017b0:	eb 09                	jmp    8017bb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b2:	89 c2                	mov    %eax,%edx
  8017b4:	eb 05                	jmp    8017bb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017b6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017bb:	89 d0                	mov    %edx,%eax
  8017bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c0:	c9                   	leave  
  8017c1:	c3                   	ret    

008017c2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	56                   	push   %esi
  8017c6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017c7:	83 ec 08             	sub    $0x8,%esp
  8017ca:	6a 00                	push   $0x0
  8017cc:	ff 75 08             	pushl  0x8(%ebp)
  8017cf:	e8 2b 02 00 00       	call   8019ff <open>
  8017d4:	89 c3                	mov    %eax,%ebx
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	78 1b                	js     8017f8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017dd:	83 ec 08             	sub    $0x8,%esp
  8017e0:	ff 75 0c             	pushl  0xc(%ebp)
  8017e3:	50                   	push   %eax
  8017e4:	e8 5b ff ff ff       	call   801744 <fstat>
  8017e9:	89 c6                	mov    %eax,%esi
	close(fd);
  8017eb:	89 1c 24             	mov    %ebx,(%esp)
  8017ee:	e8 fd fb ff ff       	call   8013f0 <close>
	return r;
  8017f3:	83 c4 10             	add    $0x10,%esp
  8017f6:	89 f0                	mov    %esi,%eax
}
  8017f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fb:	5b                   	pop    %ebx
  8017fc:	5e                   	pop    %esi
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	56                   	push   %esi
  801803:	53                   	push   %ebx
  801804:	89 c6                	mov    %eax,%esi
  801806:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801808:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80180f:	75 12                	jne    801823 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801811:	83 ec 0c             	sub    $0xc,%esp
  801814:	6a 01                	push   $0x1
  801816:	e8 fc f9 ff ff       	call   801217 <ipc_find_env>
  80181b:	a3 04 40 80 00       	mov    %eax,0x804004
  801820:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801823:	6a 07                	push   $0x7
  801825:	68 00 50 80 00       	push   $0x805000
  80182a:	56                   	push   %esi
  80182b:	ff 35 04 40 80 00    	pushl  0x804004
  801831:	e8 8b f9 ff ff       	call   8011c1 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801836:	83 c4 0c             	add    $0xc,%esp
  801839:	6a 00                	push   $0x0
  80183b:	53                   	push   %ebx
  80183c:	6a 00                	push   $0x0
  80183e:	e8 15 f9 ff ff       	call   801158 <ipc_recv>
}
  801843:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801846:	5b                   	pop    %ebx
  801847:	5e                   	pop    %esi
  801848:	5d                   	pop    %ebp
  801849:	c3                   	ret    

0080184a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801850:	8b 45 08             	mov    0x8(%ebp),%eax
  801853:	8b 40 0c             	mov    0xc(%eax),%eax
  801856:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80185b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801863:	ba 00 00 00 00       	mov    $0x0,%edx
  801868:	b8 02 00 00 00       	mov    $0x2,%eax
  80186d:	e8 8d ff ff ff       	call   8017ff <fsipc>
}
  801872:	c9                   	leave  
  801873:	c3                   	ret    

00801874 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	8b 40 0c             	mov    0xc(%eax),%eax
  801880:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801885:	ba 00 00 00 00       	mov    $0x0,%edx
  80188a:	b8 06 00 00 00       	mov    $0x6,%eax
  80188f:	e8 6b ff ff ff       	call   8017ff <fsipc>
}
  801894:	c9                   	leave  
  801895:	c3                   	ret    

00801896 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	53                   	push   %ebx
  80189a:	83 ec 04             	sub    $0x4,%esp
  80189d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8018b5:	e8 45 ff ff ff       	call   8017ff <fsipc>
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 2c                	js     8018ea <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018be:	83 ec 08             	sub    $0x8,%esp
  8018c1:	68 00 50 80 00       	push   $0x805000
  8018c6:	53                   	push   %ebx
  8018c7:	e8 19 ef ff ff       	call   8007e5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018cc:	a1 80 50 80 00       	mov    0x805080,%eax
  8018d1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018d7:	a1 84 50 80 00       	mov    0x805084,%eax
  8018dc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018e2:	83 c4 10             	add    $0x10,%esp
  8018e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ed:	c9                   	leave  
  8018ee:	c3                   	ret    

008018ef <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	53                   	push   %ebx
  8018f3:	83 ec 08             	sub    $0x8,%esp
  8018f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8018f9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018fe:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801903:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801906:	8b 45 08             	mov    0x8(%ebp),%eax
  801909:	8b 40 0c             	mov    0xc(%eax),%eax
  80190c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801911:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801917:	53                   	push   %ebx
  801918:	ff 75 0c             	pushl  0xc(%ebp)
  80191b:	68 08 50 80 00       	push   $0x805008
  801920:	e8 52 f0 ff ff       	call   800977 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801925:	ba 00 00 00 00       	mov    $0x0,%edx
  80192a:	b8 04 00 00 00       	mov    $0x4,%eax
  80192f:	e8 cb fe ff ff       	call   8017ff <fsipc>
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	85 c0                	test   %eax,%eax
  801939:	78 3d                	js     801978 <devfile_write+0x89>
		return r;

	assert(r <= n);
  80193b:	39 d8                	cmp    %ebx,%eax
  80193d:	76 19                	jbe    801958 <devfile_write+0x69>
  80193f:	68 24 28 80 00       	push   $0x802824
  801944:	68 2b 28 80 00       	push   $0x80282b
  801949:	68 9f 00 00 00       	push   $0x9f
  80194e:	68 40 28 80 00       	push   $0x802840
  801953:	e8 2a 06 00 00       	call   801f82 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801958:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80195d:	76 19                	jbe    801978 <devfile_write+0x89>
  80195f:	68 58 28 80 00       	push   $0x802858
  801964:	68 2b 28 80 00       	push   $0x80282b
  801969:	68 a0 00 00 00       	push   $0xa0
  80196e:	68 40 28 80 00       	push   $0x802840
  801973:	e8 0a 06 00 00       	call   801f82 <_panic>

	return r;
}
  801978:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197b:	c9                   	leave  
  80197c:	c3                   	ret    

0080197d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	56                   	push   %esi
  801981:	53                   	push   %ebx
  801982:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801985:	8b 45 08             	mov    0x8(%ebp),%eax
  801988:	8b 40 0c             	mov    0xc(%eax),%eax
  80198b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801990:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801996:	ba 00 00 00 00       	mov    $0x0,%edx
  80199b:	b8 03 00 00 00       	mov    $0x3,%eax
  8019a0:	e8 5a fe ff ff       	call   8017ff <fsipc>
  8019a5:	89 c3                	mov    %eax,%ebx
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 4b                	js     8019f6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019ab:	39 c6                	cmp    %eax,%esi
  8019ad:	73 16                	jae    8019c5 <devfile_read+0x48>
  8019af:	68 24 28 80 00       	push   $0x802824
  8019b4:	68 2b 28 80 00       	push   $0x80282b
  8019b9:	6a 7e                	push   $0x7e
  8019bb:	68 40 28 80 00       	push   $0x802840
  8019c0:	e8 bd 05 00 00       	call   801f82 <_panic>
	assert(r <= PGSIZE);
  8019c5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019ca:	7e 16                	jle    8019e2 <devfile_read+0x65>
  8019cc:	68 4b 28 80 00       	push   $0x80284b
  8019d1:	68 2b 28 80 00       	push   $0x80282b
  8019d6:	6a 7f                	push   $0x7f
  8019d8:	68 40 28 80 00       	push   $0x802840
  8019dd:	e8 a0 05 00 00       	call   801f82 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019e2:	83 ec 04             	sub    $0x4,%esp
  8019e5:	50                   	push   %eax
  8019e6:	68 00 50 80 00       	push   $0x805000
  8019eb:	ff 75 0c             	pushl  0xc(%ebp)
  8019ee:	e8 84 ef ff ff       	call   800977 <memmove>
	return r;
  8019f3:	83 c4 10             	add    $0x10,%esp
}
  8019f6:	89 d8                	mov    %ebx,%eax
  8019f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019fb:	5b                   	pop    %ebx
  8019fc:	5e                   	pop    %esi
  8019fd:	5d                   	pop    %ebp
  8019fe:	c3                   	ret    

008019ff <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	53                   	push   %ebx
  801a03:	83 ec 20             	sub    $0x20,%esp
  801a06:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a09:	53                   	push   %ebx
  801a0a:	e8 9d ed ff ff       	call   8007ac <strlen>
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a17:	7f 67                	jg     801a80 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a19:	83 ec 0c             	sub    $0xc,%esp
  801a1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1f:	50                   	push   %eax
  801a20:	e8 52 f8 ff ff       	call   801277 <fd_alloc>
  801a25:	83 c4 10             	add    $0x10,%esp
		return r;
  801a28:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	78 57                	js     801a85 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a2e:	83 ec 08             	sub    $0x8,%esp
  801a31:	53                   	push   %ebx
  801a32:	68 00 50 80 00       	push   $0x805000
  801a37:	e8 a9 ed ff ff       	call   8007e5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a44:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a47:	b8 01 00 00 00       	mov    $0x1,%eax
  801a4c:	e8 ae fd ff ff       	call   8017ff <fsipc>
  801a51:	89 c3                	mov    %eax,%ebx
  801a53:	83 c4 10             	add    $0x10,%esp
  801a56:	85 c0                	test   %eax,%eax
  801a58:	79 14                	jns    801a6e <open+0x6f>
		fd_close(fd, 0);
  801a5a:	83 ec 08             	sub    $0x8,%esp
  801a5d:	6a 00                	push   $0x0
  801a5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a62:	e8 08 f9 ff ff       	call   80136f <fd_close>
		return r;
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	89 da                	mov    %ebx,%edx
  801a6c:	eb 17                	jmp    801a85 <open+0x86>
	}

	return fd2num(fd);
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	ff 75 f4             	pushl  -0xc(%ebp)
  801a74:	e8 d7 f7 ff ff       	call   801250 <fd2num>
  801a79:	89 c2                	mov    %eax,%edx
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	eb 05                	jmp    801a85 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a80:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a85:	89 d0                	mov    %edx,%eax
  801a87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8a:	c9                   	leave  
  801a8b:	c3                   	ret    

00801a8c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a92:	ba 00 00 00 00       	mov    $0x0,%edx
  801a97:	b8 08 00 00 00       	mov    $0x8,%eax
  801a9c:	e8 5e fd ff ff       	call   8017ff <fsipc>
}
  801aa1:	c9                   	leave  
  801aa2:	c3                   	ret    

00801aa3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	56                   	push   %esi
  801aa7:	53                   	push   %ebx
  801aa8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801aab:	83 ec 0c             	sub    $0xc,%esp
  801aae:	ff 75 08             	pushl  0x8(%ebp)
  801ab1:	e8 aa f7 ff ff       	call   801260 <fd2data>
  801ab6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ab8:	83 c4 08             	add    $0x8,%esp
  801abb:	68 85 28 80 00       	push   $0x802885
  801ac0:	53                   	push   %ebx
  801ac1:	e8 1f ed ff ff       	call   8007e5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ac6:	8b 46 04             	mov    0x4(%esi),%eax
  801ac9:	2b 06                	sub    (%esi),%eax
  801acb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ad1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ad8:	00 00 00 
	stat->st_dev = &devpipe;
  801adb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ae2:	30 80 00 
	return 0;
}
  801ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  801aea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aed:	5b                   	pop    %ebx
  801aee:	5e                   	pop    %esi
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	53                   	push   %ebx
  801af5:	83 ec 0c             	sub    $0xc,%esp
  801af8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801afb:	53                   	push   %ebx
  801afc:	6a 00                	push   $0x0
  801afe:	e8 e1 f1 ff ff       	call   800ce4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b03:	89 1c 24             	mov    %ebx,(%esp)
  801b06:	e8 55 f7 ff ff       	call   801260 <fd2data>
  801b0b:	83 c4 08             	add    $0x8,%esp
  801b0e:	50                   	push   %eax
  801b0f:	6a 00                	push   $0x0
  801b11:	e8 ce f1 ff ff       	call   800ce4 <sys_page_unmap>
}
  801b16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b19:	c9                   	leave  
  801b1a:	c3                   	ret    

00801b1b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	57                   	push   %edi
  801b1f:	56                   	push   %esi
  801b20:	53                   	push   %ebx
  801b21:	83 ec 1c             	sub    $0x1c,%esp
  801b24:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b27:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b29:	a1 08 40 80 00       	mov    0x804008,%eax
  801b2e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b31:	83 ec 0c             	sub    $0xc,%esp
  801b34:	ff 75 e0             	pushl  -0x20(%ebp)
  801b37:	e8 1b 05 00 00       	call   802057 <pageref>
  801b3c:	89 c3                	mov    %eax,%ebx
  801b3e:	89 3c 24             	mov    %edi,(%esp)
  801b41:	e8 11 05 00 00       	call   802057 <pageref>
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	39 c3                	cmp    %eax,%ebx
  801b4b:	0f 94 c1             	sete   %cl
  801b4e:	0f b6 c9             	movzbl %cl,%ecx
  801b51:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b54:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b5a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b5d:	39 ce                	cmp    %ecx,%esi
  801b5f:	74 1b                	je     801b7c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b61:	39 c3                	cmp    %eax,%ebx
  801b63:	75 c4                	jne    801b29 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b65:	8b 42 58             	mov    0x58(%edx),%eax
  801b68:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b6b:	50                   	push   %eax
  801b6c:	56                   	push   %esi
  801b6d:	68 8c 28 80 00       	push   $0x80288c
  801b72:	e8 3a e6 ff ff       	call   8001b1 <cprintf>
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	eb ad                	jmp    801b29 <_pipeisclosed+0xe>
	}
}
  801b7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b82:	5b                   	pop    %ebx
  801b83:	5e                   	pop    %esi
  801b84:	5f                   	pop    %edi
  801b85:	5d                   	pop    %ebp
  801b86:	c3                   	ret    

00801b87 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	57                   	push   %edi
  801b8b:	56                   	push   %esi
  801b8c:	53                   	push   %ebx
  801b8d:	83 ec 28             	sub    $0x28,%esp
  801b90:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b93:	56                   	push   %esi
  801b94:	e8 c7 f6 ff ff       	call   801260 <fd2data>
  801b99:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	bf 00 00 00 00       	mov    $0x0,%edi
  801ba3:	eb 4b                	jmp    801bf0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ba5:	89 da                	mov    %ebx,%edx
  801ba7:	89 f0                	mov    %esi,%eax
  801ba9:	e8 6d ff ff ff       	call   801b1b <_pipeisclosed>
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	75 48                	jne    801bfa <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bb2:	e8 89 f0 ff ff       	call   800c40 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bb7:	8b 43 04             	mov    0x4(%ebx),%eax
  801bba:	8b 0b                	mov    (%ebx),%ecx
  801bbc:	8d 51 20             	lea    0x20(%ecx),%edx
  801bbf:	39 d0                	cmp    %edx,%eax
  801bc1:	73 e2                	jae    801ba5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bca:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bcd:	89 c2                	mov    %eax,%edx
  801bcf:	c1 fa 1f             	sar    $0x1f,%edx
  801bd2:	89 d1                	mov    %edx,%ecx
  801bd4:	c1 e9 1b             	shr    $0x1b,%ecx
  801bd7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bda:	83 e2 1f             	and    $0x1f,%edx
  801bdd:	29 ca                	sub    %ecx,%edx
  801bdf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801be3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801be7:	83 c0 01             	add    $0x1,%eax
  801bea:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bed:	83 c7 01             	add    $0x1,%edi
  801bf0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bf3:	75 c2                	jne    801bb7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bf5:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf8:	eb 05                	jmp    801bff <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bfa:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c02:	5b                   	pop    %ebx
  801c03:	5e                   	pop    %esi
  801c04:	5f                   	pop    %edi
  801c05:	5d                   	pop    %ebp
  801c06:	c3                   	ret    

00801c07 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	57                   	push   %edi
  801c0b:	56                   	push   %esi
  801c0c:	53                   	push   %ebx
  801c0d:	83 ec 18             	sub    $0x18,%esp
  801c10:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c13:	57                   	push   %edi
  801c14:	e8 47 f6 ff ff       	call   801260 <fd2data>
  801c19:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c1b:	83 c4 10             	add    $0x10,%esp
  801c1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c23:	eb 3d                	jmp    801c62 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c25:	85 db                	test   %ebx,%ebx
  801c27:	74 04                	je     801c2d <devpipe_read+0x26>
				return i;
  801c29:	89 d8                	mov    %ebx,%eax
  801c2b:	eb 44                	jmp    801c71 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c2d:	89 f2                	mov    %esi,%edx
  801c2f:	89 f8                	mov    %edi,%eax
  801c31:	e8 e5 fe ff ff       	call   801b1b <_pipeisclosed>
  801c36:	85 c0                	test   %eax,%eax
  801c38:	75 32                	jne    801c6c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c3a:	e8 01 f0 ff ff       	call   800c40 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c3f:	8b 06                	mov    (%esi),%eax
  801c41:	3b 46 04             	cmp    0x4(%esi),%eax
  801c44:	74 df                	je     801c25 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c46:	99                   	cltd   
  801c47:	c1 ea 1b             	shr    $0x1b,%edx
  801c4a:	01 d0                	add    %edx,%eax
  801c4c:	83 e0 1f             	and    $0x1f,%eax
  801c4f:	29 d0                	sub    %edx,%eax
  801c51:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c59:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c5c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c5f:	83 c3 01             	add    $0x1,%ebx
  801c62:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c65:	75 d8                	jne    801c3f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c67:	8b 45 10             	mov    0x10(%ebp),%eax
  801c6a:	eb 05                	jmp    801c71 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c6c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c74:	5b                   	pop    %ebx
  801c75:	5e                   	pop    %esi
  801c76:	5f                   	pop    %edi
  801c77:	5d                   	pop    %ebp
  801c78:	c3                   	ret    

00801c79 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	56                   	push   %esi
  801c7d:	53                   	push   %ebx
  801c7e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c84:	50                   	push   %eax
  801c85:	e8 ed f5 ff ff       	call   801277 <fd_alloc>
  801c8a:	83 c4 10             	add    $0x10,%esp
  801c8d:	89 c2                	mov    %eax,%edx
  801c8f:	85 c0                	test   %eax,%eax
  801c91:	0f 88 2c 01 00 00    	js     801dc3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c97:	83 ec 04             	sub    $0x4,%esp
  801c9a:	68 07 04 00 00       	push   $0x407
  801c9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca2:	6a 00                	push   $0x0
  801ca4:	e8 b6 ef ff ff       	call   800c5f <sys_page_alloc>
  801ca9:	83 c4 10             	add    $0x10,%esp
  801cac:	89 c2                	mov    %eax,%edx
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	0f 88 0d 01 00 00    	js     801dc3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cb6:	83 ec 0c             	sub    $0xc,%esp
  801cb9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cbc:	50                   	push   %eax
  801cbd:	e8 b5 f5 ff ff       	call   801277 <fd_alloc>
  801cc2:	89 c3                	mov    %eax,%ebx
  801cc4:	83 c4 10             	add    $0x10,%esp
  801cc7:	85 c0                	test   %eax,%eax
  801cc9:	0f 88 e2 00 00 00    	js     801db1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ccf:	83 ec 04             	sub    $0x4,%esp
  801cd2:	68 07 04 00 00       	push   $0x407
  801cd7:	ff 75 f0             	pushl  -0x10(%ebp)
  801cda:	6a 00                	push   $0x0
  801cdc:	e8 7e ef ff ff       	call   800c5f <sys_page_alloc>
  801ce1:	89 c3                	mov    %eax,%ebx
  801ce3:	83 c4 10             	add    $0x10,%esp
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	0f 88 c3 00 00 00    	js     801db1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cee:	83 ec 0c             	sub    $0xc,%esp
  801cf1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf4:	e8 67 f5 ff ff       	call   801260 <fd2data>
  801cf9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfb:	83 c4 0c             	add    $0xc,%esp
  801cfe:	68 07 04 00 00       	push   $0x407
  801d03:	50                   	push   %eax
  801d04:	6a 00                	push   $0x0
  801d06:	e8 54 ef ff ff       	call   800c5f <sys_page_alloc>
  801d0b:	89 c3                	mov    %eax,%ebx
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	85 c0                	test   %eax,%eax
  801d12:	0f 88 89 00 00 00    	js     801da1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d18:	83 ec 0c             	sub    $0xc,%esp
  801d1b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d1e:	e8 3d f5 ff ff       	call   801260 <fd2data>
  801d23:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d2a:	50                   	push   %eax
  801d2b:	6a 00                	push   $0x0
  801d2d:	56                   	push   %esi
  801d2e:	6a 00                	push   $0x0
  801d30:	e8 6d ef ff ff       	call   800ca2 <sys_page_map>
  801d35:	89 c3                	mov    %eax,%ebx
  801d37:	83 c4 20             	add    $0x20,%esp
  801d3a:	85 c0                	test   %eax,%eax
  801d3c:	78 55                	js     801d93 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d3e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d47:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d53:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d5c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d61:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d68:	83 ec 0c             	sub    $0xc,%esp
  801d6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d6e:	e8 dd f4 ff ff       	call   801250 <fd2num>
  801d73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d76:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d78:	83 c4 04             	add    $0x4,%esp
  801d7b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d7e:	e8 cd f4 ff ff       	call   801250 <fd2num>
  801d83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d86:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d89:	83 c4 10             	add    $0x10,%esp
  801d8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801d91:	eb 30                	jmp    801dc3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d93:	83 ec 08             	sub    $0x8,%esp
  801d96:	56                   	push   %esi
  801d97:	6a 00                	push   $0x0
  801d99:	e8 46 ef ff ff       	call   800ce4 <sys_page_unmap>
  801d9e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801da1:	83 ec 08             	sub    $0x8,%esp
  801da4:	ff 75 f0             	pushl  -0x10(%ebp)
  801da7:	6a 00                	push   $0x0
  801da9:	e8 36 ef ff ff       	call   800ce4 <sys_page_unmap>
  801dae:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801db1:	83 ec 08             	sub    $0x8,%esp
  801db4:	ff 75 f4             	pushl  -0xc(%ebp)
  801db7:	6a 00                	push   $0x0
  801db9:	e8 26 ef ff ff       	call   800ce4 <sys_page_unmap>
  801dbe:	83 c4 10             	add    $0x10,%esp
  801dc1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dc3:	89 d0                	mov    %edx,%eax
  801dc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc8:	5b                   	pop    %ebx
  801dc9:	5e                   	pop    %esi
  801dca:	5d                   	pop    %ebp
  801dcb:	c3                   	ret    

00801dcc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd5:	50                   	push   %eax
  801dd6:	ff 75 08             	pushl  0x8(%ebp)
  801dd9:	e8 e8 f4 ff ff       	call   8012c6 <fd_lookup>
  801dde:	83 c4 10             	add    $0x10,%esp
  801de1:	85 c0                	test   %eax,%eax
  801de3:	78 18                	js     801dfd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801de5:	83 ec 0c             	sub    $0xc,%esp
  801de8:	ff 75 f4             	pushl  -0xc(%ebp)
  801deb:	e8 70 f4 ff ff       	call   801260 <fd2data>
	return _pipeisclosed(fd, p);
  801df0:	89 c2                	mov    %eax,%edx
  801df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df5:	e8 21 fd ff ff       	call   801b1b <_pipeisclosed>
  801dfa:	83 c4 10             	add    $0x10,%esp
}
  801dfd:	c9                   	leave  
  801dfe:	c3                   	ret    

00801dff <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dff:	55                   	push   %ebp
  801e00:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e02:	b8 00 00 00 00       	mov    $0x0,%eax
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    

00801e09 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e0f:	68 a4 28 80 00       	push   $0x8028a4
  801e14:	ff 75 0c             	pushl  0xc(%ebp)
  801e17:	e8 c9 e9 ff ff       	call   8007e5 <strcpy>
	return 0;
}
  801e1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e21:	c9                   	leave  
  801e22:	c3                   	ret    

00801e23 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e23:	55                   	push   %ebp
  801e24:	89 e5                	mov    %esp,%ebp
  801e26:	57                   	push   %edi
  801e27:	56                   	push   %esi
  801e28:	53                   	push   %ebx
  801e29:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e2f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e34:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e3a:	eb 2d                	jmp    801e69 <devcons_write+0x46>
		m = n - tot;
  801e3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e3f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e41:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e44:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e49:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e4c:	83 ec 04             	sub    $0x4,%esp
  801e4f:	53                   	push   %ebx
  801e50:	03 45 0c             	add    0xc(%ebp),%eax
  801e53:	50                   	push   %eax
  801e54:	57                   	push   %edi
  801e55:	e8 1d eb ff ff       	call   800977 <memmove>
		sys_cputs(buf, m);
  801e5a:	83 c4 08             	add    $0x8,%esp
  801e5d:	53                   	push   %ebx
  801e5e:	57                   	push   %edi
  801e5f:	e8 3f ed ff ff       	call   800ba3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e64:	01 de                	add    %ebx,%esi
  801e66:	83 c4 10             	add    $0x10,%esp
  801e69:	89 f0                	mov    %esi,%eax
  801e6b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e6e:	72 cc                	jb     801e3c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e73:	5b                   	pop    %ebx
  801e74:	5e                   	pop    %esi
  801e75:	5f                   	pop    %edi
  801e76:	5d                   	pop    %ebp
  801e77:	c3                   	ret    

00801e78 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	83 ec 08             	sub    $0x8,%esp
  801e7e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e87:	74 2a                	je     801eb3 <devcons_read+0x3b>
  801e89:	eb 05                	jmp    801e90 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e8b:	e8 b0 ed ff ff       	call   800c40 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e90:	e8 2c ed ff ff       	call   800bc1 <sys_cgetc>
  801e95:	85 c0                	test   %eax,%eax
  801e97:	74 f2                	je     801e8b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e99:	85 c0                	test   %eax,%eax
  801e9b:	78 16                	js     801eb3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e9d:	83 f8 04             	cmp    $0x4,%eax
  801ea0:	74 0c                	je     801eae <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ea2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ea5:	88 02                	mov    %al,(%edx)
	return 1;
  801ea7:	b8 01 00 00 00       	mov    $0x1,%eax
  801eac:	eb 05                	jmp    801eb3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801eae:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801eb3:	c9                   	leave  
  801eb4:	c3                   	ret    

00801eb5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801eb5:	55                   	push   %ebp
  801eb6:	89 e5                	mov    %esp,%ebp
  801eb8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebe:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ec1:	6a 01                	push   $0x1
  801ec3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ec6:	50                   	push   %eax
  801ec7:	e8 d7 ec ff ff       	call   800ba3 <sys_cputs>
}
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	c9                   	leave  
  801ed0:	c3                   	ret    

00801ed1 <getchar>:

int
getchar(void)
{
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ed7:	6a 01                	push   $0x1
  801ed9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801edc:	50                   	push   %eax
  801edd:	6a 00                	push   $0x0
  801edf:	e8 48 f6 ff ff       	call   80152c <read>
	if (r < 0)
  801ee4:	83 c4 10             	add    $0x10,%esp
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	78 0f                	js     801efa <getchar+0x29>
		return r;
	if (r < 1)
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	7e 06                	jle    801ef5 <getchar+0x24>
		return -E_EOF;
	return c;
  801eef:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ef3:	eb 05                	jmp    801efa <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ef5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801efa:	c9                   	leave  
  801efb:	c3                   	ret    

00801efc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f05:	50                   	push   %eax
  801f06:	ff 75 08             	pushl  0x8(%ebp)
  801f09:	e8 b8 f3 ff ff       	call   8012c6 <fd_lookup>
  801f0e:	83 c4 10             	add    $0x10,%esp
  801f11:	85 c0                	test   %eax,%eax
  801f13:	78 11                	js     801f26 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f18:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f1e:	39 10                	cmp    %edx,(%eax)
  801f20:	0f 94 c0             	sete   %al
  801f23:	0f b6 c0             	movzbl %al,%eax
}
  801f26:	c9                   	leave  
  801f27:	c3                   	ret    

00801f28 <opencons>:

int
opencons(void)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f31:	50                   	push   %eax
  801f32:	e8 40 f3 ff ff       	call   801277 <fd_alloc>
  801f37:	83 c4 10             	add    $0x10,%esp
		return r;
  801f3a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	78 3e                	js     801f7e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f40:	83 ec 04             	sub    $0x4,%esp
  801f43:	68 07 04 00 00       	push   $0x407
  801f48:	ff 75 f4             	pushl  -0xc(%ebp)
  801f4b:	6a 00                	push   $0x0
  801f4d:	e8 0d ed ff ff       	call   800c5f <sys_page_alloc>
  801f52:	83 c4 10             	add    $0x10,%esp
		return r;
  801f55:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f57:	85 c0                	test   %eax,%eax
  801f59:	78 23                	js     801f7e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f5b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f64:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f69:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f70:	83 ec 0c             	sub    $0xc,%esp
  801f73:	50                   	push   %eax
  801f74:	e8 d7 f2 ff ff       	call   801250 <fd2num>
  801f79:	89 c2                	mov    %eax,%edx
  801f7b:	83 c4 10             	add    $0x10,%esp
}
  801f7e:	89 d0                	mov    %edx,%eax
  801f80:	c9                   	leave  
  801f81:	c3                   	ret    

00801f82 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f82:	55                   	push   %ebp
  801f83:	89 e5                	mov    %esp,%ebp
  801f85:	56                   	push   %esi
  801f86:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f87:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f8a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f90:	e8 8c ec ff ff       	call   800c21 <sys_getenvid>
  801f95:	83 ec 0c             	sub    $0xc,%esp
  801f98:	ff 75 0c             	pushl  0xc(%ebp)
  801f9b:	ff 75 08             	pushl  0x8(%ebp)
  801f9e:	56                   	push   %esi
  801f9f:	50                   	push   %eax
  801fa0:	68 b0 28 80 00       	push   $0x8028b0
  801fa5:	e8 07 e2 ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801faa:	83 c4 18             	add    $0x18,%esp
  801fad:	53                   	push   %ebx
  801fae:	ff 75 10             	pushl  0x10(%ebp)
  801fb1:	e8 aa e1 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  801fb6:	c7 04 24 9d 28 80 00 	movl   $0x80289d,(%esp)
  801fbd:	e8 ef e1 ff ff       	call   8001b1 <cprintf>
  801fc2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fc5:	cc                   	int3   
  801fc6:	eb fd                	jmp    801fc5 <_panic+0x43>

00801fc8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801fce:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fd5:	75 52                	jne    802029 <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  801fd7:	83 ec 04             	sub    $0x4,%esp
  801fda:	6a 07                	push   $0x7
  801fdc:	68 00 f0 bf ee       	push   $0xeebff000
  801fe1:	6a 00                	push   $0x0
  801fe3:	e8 77 ec ff ff       	call   800c5f <sys_page_alloc>
  801fe8:	83 c4 10             	add    $0x10,%esp
  801feb:	85 c0                	test   %eax,%eax
  801fed:	79 12                	jns    802001 <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  801fef:	50                   	push   %eax
  801ff0:	68 c0 26 80 00       	push   $0x8026c0
  801ff5:	6a 23                	push   $0x23
  801ff7:	68 d4 28 80 00       	push   $0x8028d4
  801ffc:	e8 81 ff ff ff       	call   801f82 <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  802001:	83 ec 08             	sub    $0x8,%esp
  802004:	68 33 20 80 00       	push   $0x802033
  802009:	6a 00                	push   $0x0
  80200b:	e8 9a ed ff ff       	call   800daa <sys_env_set_pgfault_upcall>
  802010:	83 c4 10             	add    $0x10,%esp
  802013:	85 c0                	test   %eax,%eax
  802015:	79 12                	jns    802029 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  802017:	50                   	push   %eax
  802018:	68 40 27 80 00       	push   $0x802740
  80201d:	6a 26                	push   $0x26
  80201f:	68 d4 28 80 00       	push   $0x8028d4
  802024:	e8 59 ff ff ff       	call   801f82 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802029:	8b 45 08             	mov    0x8(%ebp),%eax
  80202c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802031:	c9                   	leave  
  802032:	c3                   	ret    

00802033 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802033:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802034:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802039:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80203b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  80203e:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  802042:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  802047:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  80204b:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80204d:	83 c4 08             	add    $0x8,%esp
	popal 
  802050:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802051:	83 c4 04             	add    $0x4,%esp
	popfl
  802054:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802055:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802056:	c3                   	ret    

00802057 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802057:	55                   	push   %ebp
  802058:	89 e5                	mov    %esp,%ebp
  80205a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80205d:	89 d0                	mov    %edx,%eax
  80205f:	c1 e8 16             	shr    $0x16,%eax
  802062:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802069:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80206e:	f6 c1 01             	test   $0x1,%cl
  802071:	74 1d                	je     802090 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802073:	c1 ea 0c             	shr    $0xc,%edx
  802076:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80207d:	f6 c2 01             	test   $0x1,%dl
  802080:	74 0e                	je     802090 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802082:	c1 ea 0c             	shr    $0xc,%edx
  802085:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80208c:	ef 
  80208d:	0f b7 c0             	movzwl %ax,%eax
}
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	66 90                	xchg   %ax,%ax
  802094:	66 90                	xchg   %ax,%ax
  802096:	66 90                	xchg   %ax,%ax
  802098:	66 90                	xchg   %ax,%ax
  80209a:	66 90                	xchg   %ax,%ax
  80209c:	66 90                	xchg   %ax,%ax
  80209e:	66 90                	xchg   %ax,%ax

008020a0 <__udivdi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b7:	85 f6                	test   %esi,%esi
  8020b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020bd:	89 ca                	mov    %ecx,%edx
  8020bf:	89 f8                	mov    %edi,%eax
  8020c1:	75 3d                	jne    802100 <__udivdi3+0x60>
  8020c3:	39 cf                	cmp    %ecx,%edi
  8020c5:	0f 87 c5 00 00 00    	ja     802190 <__udivdi3+0xf0>
  8020cb:	85 ff                	test   %edi,%edi
  8020cd:	89 fd                	mov    %edi,%ebp
  8020cf:	75 0b                	jne    8020dc <__udivdi3+0x3c>
  8020d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d6:	31 d2                	xor    %edx,%edx
  8020d8:	f7 f7                	div    %edi
  8020da:	89 c5                	mov    %eax,%ebp
  8020dc:	89 c8                	mov    %ecx,%eax
  8020de:	31 d2                	xor    %edx,%edx
  8020e0:	f7 f5                	div    %ebp
  8020e2:	89 c1                	mov    %eax,%ecx
  8020e4:	89 d8                	mov    %ebx,%eax
  8020e6:	89 cf                	mov    %ecx,%edi
  8020e8:	f7 f5                	div    %ebp
  8020ea:	89 c3                	mov    %eax,%ebx
  8020ec:	89 d8                	mov    %ebx,%eax
  8020ee:	89 fa                	mov    %edi,%edx
  8020f0:	83 c4 1c             	add    $0x1c,%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    
  8020f8:	90                   	nop
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	39 ce                	cmp    %ecx,%esi
  802102:	77 74                	ja     802178 <__udivdi3+0xd8>
  802104:	0f bd fe             	bsr    %esi,%edi
  802107:	83 f7 1f             	xor    $0x1f,%edi
  80210a:	0f 84 98 00 00 00    	je     8021a8 <__udivdi3+0x108>
  802110:	bb 20 00 00 00       	mov    $0x20,%ebx
  802115:	89 f9                	mov    %edi,%ecx
  802117:	89 c5                	mov    %eax,%ebp
  802119:	29 fb                	sub    %edi,%ebx
  80211b:	d3 e6                	shl    %cl,%esi
  80211d:	89 d9                	mov    %ebx,%ecx
  80211f:	d3 ed                	shr    %cl,%ebp
  802121:	89 f9                	mov    %edi,%ecx
  802123:	d3 e0                	shl    %cl,%eax
  802125:	09 ee                	or     %ebp,%esi
  802127:	89 d9                	mov    %ebx,%ecx
  802129:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80212d:	89 d5                	mov    %edx,%ebp
  80212f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802133:	d3 ed                	shr    %cl,%ebp
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e2                	shl    %cl,%edx
  802139:	89 d9                	mov    %ebx,%ecx
  80213b:	d3 e8                	shr    %cl,%eax
  80213d:	09 c2                	or     %eax,%edx
  80213f:	89 d0                	mov    %edx,%eax
  802141:	89 ea                	mov    %ebp,%edx
  802143:	f7 f6                	div    %esi
  802145:	89 d5                	mov    %edx,%ebp
  802147:	89 c3                	mov    %eax,%ebx
  802149:	f7 64 24 0c          	mull   0xc(%esp)
  80214d:	39 d5                	cmp    %edx,%ebp
  80214f:	72 10                	jb     802161 <__udivdi3+0xc1>
  802151:	8b 74 24 08          	mov    0x8(%esp),%esi
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 e6                	shl    %cl,%esi
  802159:	39 c6                	cmp    %eax,%esi
  80215b:	73 07                	jae    802164 <__udivdi3+0xc4>
  80215d:	39 d5                	cmp    %edx,%ebp
  80215f:	75 03                	jne    802164 <__udivdi3+0xc4>
  802161:	83 eb 01             	sub    $0x1,%ebx
  802164:	31 ff                	xor    %edi,%edi
  802166:	89 d8                	mov    %ebx,%eax
  802168:	89 fa                	mov    %edi,%edx
  80216a:	83 c4 1c             	add    $0x1c,%esp
  80216d:	5b                   	pop    %ebx
  80216e:	5e                   	pop    %esi
  80216f:	5f                   	pop    %edi
  802170:	5d                   	pop    %ebp
  802171:	c3                   	ret    
  802172:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802178:	31 ff                	xor    %edi,%edi
  80217a:	31 db                	xor    %ebx,%ebx
  80217c:	89 d8                	mov    %ebx,%eax
  80217e:	89 fa                	mov    %edi,%edx
  802180:	83 c4 1c             	add    $0x1c,%esp
  802183:	5b                   	pop    %ebx
  802184:	5e                   	pop    %esi
  802185:	5f                   	pop    %edi
  802186:	5d                   	pop    %ebp
  802187:	c3                   	ret    
  802188:	90                   	nop
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	89 d8                	mov    %ebx,%eax
  802192:	f7 f7                	div    %edi
  802194:	31 ff                	xor    %edi,%edi
  802196:	89 c3                	mov    %eax,%ebx
  802198:	89 d8                	mov    %ebx,%eax
  80219a:	89 fa                	mov    %edi,%edx
  80219c:	83 c4 1c             	add    $0x1c,%esp
  80219f:	5b                   	pop    %ebx
  8021a0:	5e                   	pop    %esi
  8021a1:	5f                   	pop    %edi
  8021a2:	5d                   	pop    %ebp
  8021a3:	c3                   	ret    
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	39 ce                	cmp    %ecx,%esi
  8021aa:	72 0c                	jb     8021b8 <__udivdi3+0x118>
  8021ac:	31 db                	xor    %ebx,%ebx
  8021ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021b2:	0f 87 34 ff ff ff    	ja     8020ec <__udivdi3+0x4c>
  8021b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021bd:	e9 2a ff ff ff       	jmp    8020ec <__udivdi3+0x4c>
  8021c2:	66 90                	xchg   %ax,%ax
  8021c4:	66 90                	xchg   %ax,%ax
  8021c6:	66 90                	xchg   %ax,%ax
  8021c8:	66 90                	xchg   %ax,%ax
  8021ca:	66 90                	xchg   %ax,%ax
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

008021d0 <__umoddi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 1c             	sub    $0x1c,%esp
  8021d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021e7:	85 d2                	test   %edx,%edx
  8021e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021f1:	89 f3                	mov    %esi,%ebx
  8021f3:	89 3c 24             	mov    %edi,(%esp)
  8021f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021fa:	75 1c                	jne    802218 <__umoddi3+0x48>
  8021fc:	39 f7                	cmp    %esi,%edi
  8021fe:	76 50                	jbe    802250 <__umoddi3+0x80>
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	f7 f7                	div    %edi
  802206:	89 d0                	mov    %edx,%eax
  802208:	31 d2                	xor    %edx,%edx
  80220a:	83 c4 1c             	add    $0x1c,%esp
  80220d:	5b                   	pop    %ebx
  80220e:	5e                   	pop    %esi
  80220f:	5f                   	pop    %edi
  802210:	5d                   	pop    %ebp
  802211:	c3                   	ret    
  802212:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802218:	39 f2                	cmp    %esi,%edx
  80221a:	89 d0                	mov    %edx,%eax
  80221c:	77 52                	ja     802270 <__umoddi3+0xa0>
  80221e:	0f bd ea             	bsr    %edx,%ebp
  802221:	83 f5 1f             	xor    $0x1f,%ebp
  802224:	75 5a                	jne    802280 <__umoddi3+0xb0>
  802226:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80222a:	0f 82 e0 00 00 00    	jb     802310 <__umoddi3+0x140>
  802230:	39 0c 24             	cmp    %ecx,(%esp)
  802233:	0f 86 d7 00 00 00    	jbe    802310 <__umoddi3+0x140>
  802239:	8b 44 24 08          	mov    0x8(%esp),%eax
  80223d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802241:	83 c4 1c             	add    $0x1c,%esp
  802244:	5b                   	pop    %ebx
  802245:	5e                   	pop    %esi
  802246:	5f                   	pop    %edi
  802247:	5d                   	pop    %ebp
  802248:	c3                   	ret    
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	85 ff                	test   %edi,%edi
  802252:	89 fd                	mov    %edi,%ebp
  802254:	75 0b                	jne    802261 <__umoddi3+0x91>
  802256:	b8 01 00 00 00       	mov    $0x1,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	f7 f7                	div    %edi
  80225f:	89 c5                	mov    %eax,%ebp
  802261:	89 f0                	mov    %esi,%eax
  802263:	31 d2                	xor    %edx,%edx
  802265:	f7 f5                	div    %ebp
  802267:	89 c8                	mov    %ecx,%eax
  802269:	f7 f5                	div    %ebp
  80226b:	89 d0                	mov    %edx,%eax
  80226d:	eb 99                	jmp    802208 <__umoddi3+0x38>
  80226f:	90                   	nop
  802270:	89 c8                	mov    %ecx,%eax
  802272:	89 f2                	mov    %esi,%edx
  802274:	83 c4 1c             	add    $0x1c,%esp
  802277:	5b                   	pop    %ebx
  802278:	5e                   	pop    %esi
  802279:	5f                   	pop    %edi
  80227a:	5d                   	pop    %ebp
  80227b:	c3                   	ret    
  80227c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802280:	8b 34 24             	mov    (%esp),%esi
  802283:	bf 20 00 00 00       	mov    $0x20,%edi
  802288:	89 e9                	mov    %ebp,%ecx
  80228a:	29 ef                	sub    %ebp,%edi
  80228c:	d3 e0                	shl    %cl,%eax
  80228e:	89 f9                	mov    %edi,%ecx
  802290:	89 f2                	mov    %esi,%edx
  802292:	d3 ea                	shr    %cl,%edx
  802294:	89 e9                	mov    %ebp,%ecx
  802296:	09 c2                	or     %eax,%edx
  802298:	89 d8                	mov    %ebx,%eax
  80229a:	89 14 24             	mov    %edx,(%esp)
  80229d:	89 f2                	mov    %esi,%edx
  80229f:	d3 e2                	shl    %cl,%edx
  8022a1:	89 f9                	mov    %edi,%ecx
  8022a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022ab:	d3 e8                	shr    %cl,%eax
  8022ad:	89 e9                	mov    %ebp,%ecx
  8022af:	89 c6                	mov    %eax,%esi
  8022b1:	d3 e3                	shl    %cl,%ebx
  8022b3:	89 f9                	mov    %edi,%ecx
  8022b5:	89 d0                	mov    %edx,%eax
  8022b7:	d3 e8                	shr    %cl,%eax
  8022b9:	89 e9                	mov    %ebp,%ecx
  8022bb:	09 d8                	or     %ebx,%eax
  8022bd:	89 d3                	mov    %edx,%ebx
  8022bf:	89 f2                	mov    %esi,%edx
  8022c1:	f7 34 24             	divl   (%esp)
  8022c4:	89 d6                	mov    %edx,%esi
  8022c6:	d3 e3                	shl    %cl,%ebx
  8022c8:	f7 64 24 04          	mull   0x4(%esp)
  8022cc:	39 d6                	cmp    %edx,%esi
  8022ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022d2:	89 d1                	mov    %edx,%ecx
  8022d4:	89 c3                	mov    %eax,%ebx
  8022d6:	72 08                	jb     8022e0 <__umoddi3+0x110>
  8022d8:	75 11                	jne    8022eb <__umoddi3+0x11b>
  8022da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022de:	73 0b                	jae    8022eb <__umoddi3+0x11b>
  8022e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022e4:	1b 14 24             	sbb    (%esp),%edx
  8022e7:	89 d1                	mov    %edx,%ecx
  8022e9:	89 c3                	mov    %eax,%ebx
  8022eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022ef:	29 da                	sub    %ebx,%edx
  8022f1:	19 ce                	sbb    %ecx,%esi
  8022f3:	89 f9                	mov    %edi,%ecx
  8022f5:	89 f0                	mov    %esi,%eax
  8022f7:	d3 e0                	shl    %cl,%eax
  8022f9:	89 e9                	mov    %ebp,%ecx
  8022fb:	d3 ea                	shr    %cl,%edx
  8022fd:	89 e9                	mov    %ebp,%ecx
  8022ff:	d3 ee                	shr    %cl,%esi
  802301:	09 d0                	or     %edx,%eax
  802303:	89 f2                	mov    %esi,%edx
  802305:	83 c4 1c             	add    $0x1c,%esp
  802308:	5b                   	pop    %ebx
  802309:	5e                   	pop    %esi
  80230a:	5f                   	pop    %edi
  80230b:	5d                   	pop    %ebp
  80230c:	c3                   	ret    
  80230d:	8d 76 00             	lea    0x0(%esi),%esi
  802310:	29 f9                	sub    %edi,%ecx
  802312:	19 d6                	sbb    %edx,%esi
  802314:	89 74 24 04          	mov    %esi,0x4(%esp)
  802318:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80231c:	e9 18 ff ff ff       	jmp    802239 <__umoddi3+0x69>
