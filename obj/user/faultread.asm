
obj/user/faultread.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	ff 35 00 00 00 00    	pushl  0x0
  80003f:	68 20 1f 80 00       	push   $0x801f20
  800044:	e8 f8 00 00 00       	call   800141 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 53 0b 00 00       	call   800bb1 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 0c 0f 00 00       	call   800fab <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 c7 0a 00 00       	call   800b70 <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	53                   	push   %ebx
  8000b2:	83 ec 04             	sub    $0x4,%esp
  8000b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b8:	8b 13                	mov    (%ebx),%edx
  8000ba:	8d 42 01             	lea    0x1(%edx),%eax
  8000bd:	89 03                	mov    %eax,(%ebx)
  8000bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cb:	75 1a                	jne    8000e7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000cd:	83 ec 08             	sub    $0x8,%esp
  8000d0:	68 ff 00 00 00       	push   $0xff
  8000d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d8:	50                   	push   %eax
  8000d9:	e8 55 0a 00 00       	call   800b33 <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800100:	00 00 00 
	b.cnt = 0;
  800103:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010d:	ff 75 0c             	pushl  0xc(%ebp)
  800110:	ff 75 08             	pushl  0x8(%ebp)
  800113:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800119:	50                   	push   %eax
  80011a:	68 ae 00 80 00       	push   $0x8000ae
  80011f:	e8 54 01 00 00       	call   800278 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800124:	83 c4 08             	add    $0x8,%esp
  800127:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80012d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	e8 fa 09 00 00       	call   800b33 <sys_cputs>

	return b.cnt;
}
  800139:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800147:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014a:	50                   	push   %eax
  80014b:	ff 75 08             	pushl  0x8(%ebp)
  80014e:	e8 9d ff ff ff       	call   8000f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 1c             	sub    $0x1c,%esp
  80015e:	89 c7                	mov    %eax,%edi
  800160:	89 d6                	mov    %edx,%esi
  800162:	8b 45 08             	mov    0x8(%ebp),%eax
  800165:	8b 55 0c             	mov    0xc(%ebp),%edx
  800168:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80016b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80016e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800171:	bb 00 00 00 00       	mov    $0x0,%ebx
  800176:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800179:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80017c:	39 d3                	cmp    %edx,%ebx
  80017e:	72 05                	jb     800185 <printnum+0x30>
  800180:	39 45 10             	cmp    %eax,0x10(%ebp)
  800183:	77 45                	ja     8001ca <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	ff 75 18             	pushl  0x18(%ebp)
  80018b:	8b 45 14             	mov    0x14(%ebp),%eax
  80018e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800191:	53                   	push   %ebx
  800192:	ff 75 10             	pushl  0x10(%ebp)
  800195:	83 ec 08             	sub    $0x8,%esp
  800198:	ff 75 e4             	pushl  -0x1c(%ebp)
  80019b:	ff 75 e0             	pushl  -0x20(%ebp)
  80019e:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a4:	e8 e7 1a 00 00       	call   801c90 <__udivdi3>
  8001a9:	83 c4 18             	add    $0x18,%esp
  8001ac:	52                   	push   %edx
  8001ad:	50                   	push   %eax
  8001ae:	89 f2                	mov    %esi,%edx
  8001b0:	89 f8                	mov    %edi,%eax
  8001b2:	e8 9e ff ff ff       	call   800155 <printnum>
  8001b7:	83 c4 20             	add    $0x20,%esp
  8001ba:	eb 18                	jmp    8001d4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	56                   	push   %esi
  8001c0:	ff 75 18             	pushl  0x18(%ebp)
  8001c3:	ff d7                	call   *%edi
  8001c5:	83 c4 10             	add    $0x10,%esp
  8001c8:	eb 03                	jmp    8001cd <printnum+0x78>
  8001ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001cd:	83 eb 01             	sub    $0x1,%ebx
  8001d0:	85 db                	test   %ebx,%ebx
  8001d2:	7f e8                	jg     8001bc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d4:	83 ec 08             	sub    $0x8,%esp
  8001d7:	56                   	push   %esi
  8001d8:	83 ec 04             	sub    $0x4,%esp
  8001db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001de:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e7:	e8 d4 1b 00 00       	call   801dc0 <__umoddi3>
  8001ec:	83 c4 14             	add    $0x14,%esp
  8001ef:	0f be 80 48 1f 80 00 	movsbl 0x801f48(%eax),%eax
  8001f6:	50                   	push   %eax
  8001f7:	ff d7                	call   *%edi
}
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ff:	5b                   	pop    %ebx
  800200:	5e                   	pop    %esi
  800201:	5f                   	pop    %edi
  800202:	5d                   	pop    %ebp
  800203:	c3                   	ret    

00800204 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800207:	83 fa 01             	cmp    $0x1,%edx
  80020a:	7e 0e                	jle    80021a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80020c:	8b 10                	mov    (%eax),%edx
  80020e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800211:	89 08                	mov    %ecx,(%eax)
  800213:	8b 02                	mov    (%edx),%eax
  800215:	8b 52 04             	mov    0x4(%edx),%edx
  800218:	eb 22                	jmp    80023c <getuint+0x38>
	else if (lflag)
  80021a:	85 d2                	test   %edx,%edx
  80021c:	74 10                	je     80022e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80021e:	8b 10                	mov    (%eax),%edx
  800220:	8d 4a 04             	lea    0x4(%edx),%ecx
  800223:	89 08                	mov    %ecx,(%eax)
  800225:	8b 02                	mov    (%edx),%eax
  800227:	ba 00 00 00 00       	mov    $0x0,%edx
  80022c:	eb 0e                	jmp    80023c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80022e:	8b 10                	mov    (%eax),%edx
  800230:	8d 4a 04             	lea    0x4(%edx),%ecx
  800233:	89 08                	mov    %ecx,(%eax)
  800235:	8b 02                	mov    (%edx),%eax
  800237:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80023c:	5d                   	pop    %ebp
  80023d:	c3                   	ret    

0080023e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800244:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800248:	8b 10                	mov    (%eax),%edx
  80024a:	3b 50 04             	cmp    0x4(%eax),%edx
  80024d:	73 0a                	jae    800259 <sprintputch+0x1b>
		*b->buf++ = ch;
  80024f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800252:	89 08                	mov    %ecx,(%eax)
  800254:	8b 45 08             	mov    0x8(%ebp),%eax
  800257:	88 02                	mov    %al,(%edx)
}
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800261:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800264:	50                   	push   %eax
  800265:	ff 75 10             	pushl  0x10(%ebp)
  800268:	ff 75 0c             	pushl  0xc(%ebp)
  80026b:	ff 75 08             	pushl  0x8(%ebp)
  80026e:	e8 05 00 00 00       	call   800278 <vprintfmt>
	va_end(ap);
}
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 2c             	sub    $0x2c,%esp
  800281:	8b 75 08             	mov    0x8(%ebp),%esi
  800284:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800287:	8b 7d 10             	mov    0x10(%ebp),%edi
  80028a:	eb 12                	jmp    80029e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80028c:	85 c0                	test   %eax,%eax
  80028e:	0f 84 38 04 00 00    	je     8006cc <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	53                   	push   %ebx
  800298:	50                   	push   %eax
  800299:	ff d6                	call   *%esi
  80029b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80029e:	83 c7 01             	add    $0x1,%edi
  8002a1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002a5:	83 f8 25             	cmp    $0x25,%eax
  8002a8:	75 e2                	jne    80028c <vprintfmt+0x14>
  8002aa:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002ae:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002b5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002bc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c8:	eb 07                	jmp    8002d1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8002cd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d1:	8d 47 01             	lea    0x1(%edi),%eax
  8002d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d7:	0f b6 07             	movzbl (%edi),%eax
  8002da:	0f b6 c8             	movzbl %al,%ecx
  8002dd:	83 e8 23             	sub    $0x23,%eax
  8002e0:	3c 55                	cmp    $0x55,%al
  8002e2:	0f 87 c9 03 00 00    	ja     8006b1 <vprintfmt+0x439>
  8002e8:	0f b6 c0             	movzbl %al,%eax
  8002eb:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  8002f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002f5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f9:	eb d6                	jmp    8002d1 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  8002fb:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  800302:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800305:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  800308:	eb 94                	jmp    80029e <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  80030a:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  800311:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  800317:	eb 85                	jmp    80029e <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  800319:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  800320:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800323:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  800326:	e9 73 ff ff ff       	jmp    80029e <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  80032b:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  800332:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  800338:	e9 61 ff ff ff       	jmp    80029e <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  80033d:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800344:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  80034a:	e9 4f ff ff ff       	jmp    80029e <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80034f:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800356:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80035c:	e9 3d ff ff ff       	jmp    80029e <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  800361:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  800368:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80036e:	e9 2b ff ff ff       	jmp    80029e <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  800373:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  80037a:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  800380:	e9 19 ff ff ff       	jmp    80029e <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800385:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  80038c:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  800392:	e9 07 ff ff ff       	jmp    80029e <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  800397:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  80039e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8003a4:	e9 f5 fe ff ff       	jmp    80029e <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003bb:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003be:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c1:	83 fa 09             	cmp    $0x9,%edx
  8003c4:	77 3f                	ja     800405 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c9:	eb e9                	jmp    8003b4 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ce:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d4:	8b 00                	mov    (%eax),%eax
  8003d6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003dc:	eb 2d                	jmp    80040b <vprintfmt+0x193>
  8003de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e1:	85 c0                	test   %eax,%eax
  8003e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e8:	0f 49 c8             	cmovns %eax,%ecx
  8003eb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f1:	e9 db fe ff ff       	jmp    8002d1 <vprintfmt+0x59>
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800400:	e9 cc fe ff ff       	jmp    8002d1 <vprintfmt+0x59>
  800405:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800408:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80040b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040f:	0f 89 bc fe ff ff    	jns    8002d1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800415:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800418:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800422:	e9 aa fe ff ff       	jmp    8002d1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800427:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042d:	e9 9f fe ff ff       	jmp    8002d1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8d 50 04             	lea    0x4(%eax),%edx
  800438:	89 55 14             	mov    %edx,0x14(%ebp)
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	53                   	push   %ebx
  80043f:	ff 30                	pushl  (%eax)
  800441:	ff d6                	call   *%esi
			break;
  800443:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800449:	e9 50 fe ff ff       	jmp    80029e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044e:	8b 45 14             	mov    0x14(%ebp),%eax
  800451:	8d 50 04             	lea    0x4(%eax),%edx
  800454:	89 55 14             	mov    %edx,0x14(%ebp)
  800457:	8b 00                	mov    (%eax),%eax
  800459:	99                   	cltd   
  80045a:	31 d0                	xor    %edx,%eax
  80045c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045e:	83 f8 0f             	cmp    $0xf,%eax
  800461:	7f 0b                	jg     80046e <vprintfmt+0x1f6>
  800463:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  80046a:	85 d2                	test   %edx,%edx
  80046c:	75 18                	jne    800486 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80046e:	50                   	push   %eax
  80046f:	68 60 1f 80 00       	push   $0x801f60
  800474:	53                   	push   %ebx
  800475:	56                   	push   %esi
  800476:	e8 e0 fd ff ff       	call   80025b <printfmt>
  80047b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800481:	e9 18 fe ff ff       	jmp    80029e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800486:	52                   	push   %edx
  800487:	68 11 23 80 00       	push   $0x802311
  80048c:	53                   	push   %ebx
  80048d:	56                   	push   %esi
  80048e:	e8 c8 fd ff ff       	call   80025b <printfmt>
  800493:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800499:	e9 00 fe ff ff       	jmp    80029e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	8d 50 04             	lea    0x4(%eax),%edx
  8004a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a9:	85 ff                	test   %edi,%edi
  8004ab:	b8 59 1f 80 00       	mov    $0x801f59,%eax
  8004b0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b7:	0f 8e 94 00 00 00    	jle    800551 <vprintfmt+0x2d9>
  8004bd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c1:	0f 84 98 00 00 00    	je     80055f <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	ff 75 d0             	pushl  -0x30(%ebp)
  8004cd:	57                   	push   %edi
  8004ce:	e8 81 02 00 00       	call   800754 <strnlen>
  8004d3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d6:	29 c1                	sub    %eax,%ecx
  8004d8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004db:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004de:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ea:	eb 0f                	jmp    8004fb <vprintfmt+0x283>
					putch(padc, putdat);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	53                   	push   %ebx
  8004f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f5:	83 ef 01             	sub    $0x1,%edi
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	85 ff                	test   %edi,%edi
  8004fd:	7f ed                	jg     8004ec <vprintfmt+0x274>
  8004ff:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800502:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800505:	85 c9                	test   %ecx,%ecx
  800507:	b8 00 00 00 00       	mov    $0x0,%eax
  80050c:	0f 49 c1             	cmovns %ecx,%eax
  80050f:	29 c1                	sub    %eax,%ecx
  800511:	89 75 08             	mov    %esi,0x8(%ebp)
  800514:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800517:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051a:	89 cb                	mov    %ecx,%ebx
  80051c:	eb 4d                	jmp    80056b <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800522:	74 1b                	je     80053f <vprintfmt+0x2c7>
  800524:	0f be c0             	movsbl %al,%eax
  800527:	83 e8 20             	sub    $0x20,%eax
  80052a:	83 f8 5e             	cmp    $0x5e,%eax
  80052d:	76 10                	jbe    80053f <vprintfmt+0x2c7>
					putch('?', putdat);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	ff 75 0c             	pushl  0xc(%ebp)
  800535:	6a 3f                	push   $0x3f
  800537:	ff 55 08             	call   *0x8(%ebp)
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	eb 0d                	jmp    80054c <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	ff 75 0c             	pushl  0xc(%ebp)
  800545:	52                   	push   %edx
  800546:	ff 55 08             	call   *0x8(%ebp)
  800549:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054c:	83 eb 01             	sub    $0x1,%ebx
  80054f:	eb 1a                	jmp    80056b <vprintfmt+0x2f3>
  800551:	89 75 08             	mov    %esi,0x8(%ebp)
  800554:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800557:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055d:	eb 0c                	jmp    80056b <vprintfmt+0x2f3>
  80055f:	89 75 08             	mov    %esi,0x8(%ebp)
  800562:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800565:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800568:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056b:	83 c7 01             	add    $0x1,%edi
  80056e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800572:	0f be d0             	movsbl %al,%edx
  800575:	85 d2                	test   %edx,%edx
  800577:	74 23                	je     80059c <vprintfmt+0x324>
  800579:	85 f6                	test   %esi,%esi
  80057b:	78 a1                	js     80051e <vprintfmt+0x2a6>
  80057d:	83 ee 01             	sub    $0x1,%esi
  800580:	79 9c                	jns    80051e <vprintfmt+0x2a6>
  800582:	89 df                	mov    %ebx,%edi
  800584:	8b 75 08             	mov    0x8(%ebp),%esi
  800587:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058a:	eb 18                	jmp    8005a4 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	53                   	push   %ebx
  800590:	6a 20                	push   $0x20
  800592:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800594:	83 ef 01             	sub    $0x1,%edi
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	eb 08                	jmp    8005a4 <vprintfmt+0x32c>
  80059c:	89 df                	mov    %ebx,%edi
  80059e:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a4:	85 ff                	test   %edi,%edi
  8005a6:	7f e4                	jg     80058c <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ab:	e9 ee fc ff ff       	jmp    80029e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b0:	83 fa 01             	cmp    $0x1,%edx
  8005b3:	7e 16                	jle    8005cb <vprintfmt+0x353>
		return va_arg(*ap, long long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 50 08             	lea    0x8(%eax),%edx
  8005bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005be:	8b 50 04             	mov    0x4(%eax),%edx
  8005c1:	8b 00                	mov    (%eax),%eax
  8005c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c9:	eb 32                	jmp    8005fd <vprintfmt+0x385>
	else if (lflag)
  8005cb:	85 d2                	test   %edx,%edx
  8005cd:	74 18                	je     8005e7 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8d 50 04             	lea    0x4(%eax),%edx
  8005d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d8:	8b 00                	mov    (%eax),%eax
  8005da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005dd:	89 c1                	mov    %eax,%ecx
  8005df:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e5:	eb 16                	jmp    8005fd <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 50 04             	lea    0x4(%eax),%edx
  8005ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f0:	8b 00                	mov    (%eax),%eax
  8005f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f5:	89 c1                	mov    %eax,%ecx
  8005f7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800600:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800603:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800608:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060c:	79 6f                	jns    80067d <vprintfmt+0x405>
				putch('-', putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 2d                	push   $0x2d
  800614:	ff d6                	call   *%esi
				num = -(long long) num;
  800616:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800619:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80061c:	f7 d8                	neg    %eax
  80061e:	83 d2 00             	adc    $0x0,%edx
  800621:	f7 da                	neg    %edx
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	eb 55                	jmp    80067d <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800628:	8d 45 14             	lea    0x14(%ebp),%eax
  80062b:	e8 d4 fb ff ff       	call   800204 <getuint>
			base = 10;
  800630:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800635:	eb 46                	jmp    80067d <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800637:	8d 45 14             	lea    0x14(%ebp),%eax
  80063a:	e8 c5 fb ff ff       	call   800204 <getuint>
			base = 8;
  80063f:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800644:	eb 37                	jmp    80067d <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	6a 30                	push   $0x30
  80064c:	ff d6                	call   *%esi
			putch('x', putdat);
  80064e:	83 c4 08             	add    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 78                	push   $0x78
  800654:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800666:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800669:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80066e:	eb 0d                	jmp    80067d <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800670:	8d 45 14             	lea    0x14(%ebp),%eax
  800673:	e8 8c fb ff ff       	call   800204 <getuint>
			base = 16;
  800678:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067d:	83 ec 0c             	sub    $0xc,%esp
  800680:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800684:	51                   	push   %ecx
  800685:	ff 75 e0             	pushl  -0x20(%ebp)
  800688:	57                   	push   %edi
  800689:	52                   	push   %edx
  80068a:	50                   	push   %eax
  80068b:	89 da                	mov    %ebx,%edx
  80068d:	89 f0                	mov    %esi,%eax
  80068f:	e8 c1 fa ff ff       	call   800155 <printnum>
			break;
  800694:	83 c4 20             	add    $0x20,%esp
  800697:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069a:	e9 ff fb ff ff       	jmp    80029e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	51                   	push   %ecx
  8006a4:	ff d6                	call   *%esi
			break;
  8006a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ac:	e9 ed fb ff ff       	jmp    80029e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	6a 25                	push   $0x25
  8006b7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	eb 03                	jmp    8006c1 <vprintfmt+0x449>
  8006be:	83 ef 01             	sub    $0x1,%edi
  8006c1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c5:	75 f7                	jne    8006be <vprintfmt+0x446>
  8006c7:	e9 d2 fb ff ff       	jmp    80029e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006cf:	5b                   	pop    %ebx
  8006d0:	5e                   	pop    %esi
  8006d1:	5f                   	pop    %edi
  8006d2:	5d                   	pop    %ebp
  8006d3:	c3                   	ret    

008006d4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	83 ec 18             	sub    $0x18,%esp
  8006da:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	74 26                	je     80071b <vsnprintf+0x47>
  8006f5:	85 d2                	test   %edx,%edx
  8006f7:	7e 22                	jle    80071b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f9:	ff 75 14             	pushl  0x14(%ebp)
  8006fc:	ff 75 10             	pushl  0x10(%ebp)
  8006ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	68 3e 02 80 00       	push   $0x80023e
  800708:	e8 6b fb ff ff       	call   800278 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800710:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800713:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800716:	83 c4 10             	add    $0x10,%esp
  800719:	eb 05                	jmp    800720 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800720:	c9                   	leave  
  800721:	c3                   	ret    

00800722 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800728:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072b:	50                   	push   %eax
  80072c:	ff 75 10             	pushl  0x10(%ebp)
  80072f:	ff 75 0c             	pushl  0xc(%ebp)
  800732:	ff 75 08             	pushl  0x8(%ebp)
  800735:	e8 9a ff ff ff       	call   8006d4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    

0080073c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800742:	b8 00 00 00 00       	mov    $0x0,%eax
  800747:	eb 03                	jmp    80074c <strlen+0x10>
		n++;
  800749:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800750:	75 f7                	jne    800749 <strlen+0xd>
		n++;
	return n;
}
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075d:	ba 00 00 00 00       	mov    $0x0,%edx
  800762:	eb 03                	jmp    800767 <strnlen+0x13>
		n++;
  800764:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800767:	39 c2                	cmp    %eax,%edx
  800769:	74 08                	je     800773 <strnlen+0x1f>
  80076b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80076f:	75 f3                	jne    800764 <strnlen+0x10>
  800771:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	53                   	push   %ebx
  800779:	8b 45 08             	mov    0x8(%ebp),%eax
  80077c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077f:	89 c2                	mov    %eax,%edx
  800781:	83 c2 01             	add    $0x1,%edx
  800784:	83 c1 01             	add    $0x1,%ecx
  800787:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078e:	84 db                	test   %bl,%bl
  800790:	75 ef                	jne    800781 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800792:	5b                   	pop    %ebx
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	53                   	push   %ebx
  800799:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079c:	53                   	push   %ebx
  80079d:	e8 9a ff ff ff       	call   80073c <strlen>
  8007a2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a5:	ff 75 0c             	pushl  0xc(%ebp)
  8007a8:	01 d8                	add    %ebx,%eax
  8007aa:	50                   	push   %eax
  8007ab:	e8 c5 ff ff ff       	call   800775 <strcpy>
	return dst;
}
  8007b0:	89 d8                	mov    %ebx,%eax
  8007b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	56                   	push   %esi
  8007bb:	53                   	push   %ebx
  8007bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c2:	89 f3                	mov    %esi,%ebx
  8007c4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c7:	89 f2                	mov    %esi,%edx
  8007c9:	eb 0f                	jmp    8007da <strncpy+0x23>
		*dst++ = *src;
  8007cb:	83 c2 01             	add    $0x1,%edx
  8007ce:	0f b6 01             	movzbl (%ecx),%eax
  8007d1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d4:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007da:	39 da                	cmp    %ebx,%edx
  8007dc:	75 ed                	jne    8007cb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007de:	89 f0                	mov    %esi,%eax
  8007e0:	5b                   	pop    %ebx
  8007e1:	5e                   	pop    %esi
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	56                   	push   %esi
  8007e8:	53                   	push   %ebx
  8007e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ef:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f4:	85 d2                	test   %edx,%edx
  8007f6:	74 21                	je     800819 <strlcpy+0x35>
  8007f8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fc:	89 f2                	mov    %esi,%edx
  8007fe:	eb 09                	jmp    800809 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800800:	83 c2 01             	add    $0x1,%edx
  800803:	83 c1 01             	add    $0x1,%ecx
  800806:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800809:	39 c2                	cmp    %eax,%edx
  80080b:	74 09                	je     800816 <strlcpy+0x32>
  80080d:	0f b6 19             	movzbl (%ecx),%ebx
  800810:	84 db                	test   %bl,%bl
  800812:	75 ec                	jne    800800 <strlcpy+0x1c>
  800814:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800816:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800819:	29 f0                	sub    %esi,%eax
}
  80081b:	5b                   	pop    %ebx
  80081c:	5e                   	pop    %esi
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800825:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800828:	eb 06                	jmp    800830 <strcmp+0x11>
		p++, q++;
  80082a:	83 c1 01             	add    $0x1,%ecx
  80082d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800830:	0f b6 01             	movzbl (%ecx),%eax
  800833:	84 c0                	test   %al,%al
  800835:	74 04                	je     80083b <strcmp+0x1c>
  800837:	3a 02                	cmp    (%edx),%al
  800839:	74 ef                	je     80082a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083b:	0f b6 c0             	movzbl %al,%eax
  80083e:	0f b6 12             	movzbl (%edx),%edx
  800841:	29 d0                	sub    %edx,%eax
}
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	53                   	push   %ebx
  800849:	8b 45 08             	mov    0x8(%ebp),%eax
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084f:	89 c3                	mov    %eax,%ebx
  800851:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800854:	eb 06                	jmp    80085c <strncmp+0x17>
		n--, p++, q++;
  800856:	83 c0 01             	add    $0x1,%eax
  800859:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085c:	39 d8                	cmp    %ebx,%eax
  80085e:	74 15                	je     800875 <strncmp+0x30>
  800860:	0f b6 08             	movzbl (%eax),%ecx
  800863:	84 c9                	test   %cl,%cl
  800865:	74 04                	je     80086b <strncmp+0x26>
  800867:	3a 0a                	cmp    (%edx),%cl
  800869:	74 eb                	je     800856 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086b:	0f b6 00             	movzbl (%eax),%eax
  80086e:	0f b6 12             	movzbl (%edx),%edx
  800871:	29 d0                	sub    %edx,%eax
  800873:	eb 05                	jmp    80087a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800875:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087a:	5b                   	pop    %ebx
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800887:	eb 07                	jmp    800890 <strchr+0x13>
		if (*s == c)
  800889:	38 ca                	cmp    %cl,%dl
  80088b:	74 0f                	je     80089c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088d:	83 c0 01             	add    $0x1,%eax
  800890:	0f b6 10             	movzbl (%eax),%edx
  800893:	84 d2                	test   %dl,%dl
  800895:	75 f2                	jne    800889 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a8:	eb 03                	jmp    8008ad <strfind+0xf>
  8008aa:	83 c0 01             	add    $0x1,%eax
  8008ad:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b0:	38 ca                	cmp    %cl,%dl
  8008b2:	74 04                	je     8008b8 <strfind+0x1a>
  8008b4:	84 d2                	test   %dl,%dl
  8008b6:	75 f2                	jne    8008aa <strfind+0xc>
			break;
	return (char *) s;
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	57                   	push   %edi
  8008be:	56                   	push   %esi
  8008bf:	53                   	push   %ebx
  8008c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c6:	85 c9                	test   %ecx,%ecx
  8008c8:	74 36                	je     800900 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ca:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d0:	75 28                	jne    8008fa <memset+0x40>
  8008d2:	f6 c1 03             	test   $0x3,%cl
  8008d5:	75 23                	jne    8008fa <memset+0x40>
		c &= 0xFF;
  8008d7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008db:	89 d3                	mov    %edx,%ebx
  8008dd:	c1 e3 08             	shl    $0x8,%ebx
  8008e0:	89 d6                	mov    %edx,%esi
  8008e2:	c1 e6 18             	shl    $0x18,%esi
  8008e5:	89 d0                	mov    %edx,%eax
  8008e7:	c1 e0 10             	shl    $0x10,%eax
  8008ea:	09 f0                	or     %esi,%eax
  8008ec:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ee:	89 d8                	mov    %ebx,%eax
  8008f0:	09 d0                	or     %edx,%eax
  8008f2:	c1 e9 02             	shr    $0x2,%ecx
  8008f5:	fc                   	cld    
  8008f6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f8:	eb 06                	jmp    800900 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fd:	fc                   	cld    
  8008fe:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800900:	89 f8                	mov    %edi,%eax
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5f                   	pop    %edi
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	57                   	push   %edi
  80090b:	56                   	push   %esi
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800912:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800915:	39 c6                	cmp    %eax,%esi
  800917:	73 35                	jae    80094e <memmove+0x47>
  800919:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091c:	39 d0                	cmp    %edx,%eax
  80091e:	73 2e                	jae    80094e <memmove+0x47>
		s += n;
		d += n;
  800920:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800923:	89 d6                	mov    %edx,%esi
  800925:	09 fe                	or     %edi,%esi
  800927:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092d:	75 13                	jne    800942 <memmove+0x3b>
  80092f:	f6 c1 03             	test   $0x3,%cl
  800932:	75 0e                	jne    800942 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800934:	83 ef 04             	sub    $0x4,%edi
  800937:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093a:	c1 e9 02             	shr    $0x2,%ecx
  80093d:	fd                   	std    
  80093e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800940:	eb 09                	jmp    80094b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800942:	83 ef 01             	sub    $0x1,%edi
  800945:	8d 72 ff             	lea    -0x1(%edx),%esi
  800948:	fd                   	std    
  800949:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094b:	fc                   	cld    
  80094c:	eb 1d                	jmp    80096b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094e:	89 f2                	mov    %esi,%edx
  800950:	09 c2                	or     %eax,%edx
  800952:	f6 c2 03             	test   $0x3,%dl
  800955:	75 0f                	jne    800966 <memmove+0x5f>
  800957:	f6 c1 03             	test   $0x3,%cl
  80095a:	75 0a                	jne    800966 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80095c:	c1 e9 02             	shr    $0x2,%ecx
  80095f:	89 c7                	mov    %eax,%edi
  800961:	fc                   	cld    
  800962:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800964:	eb 05                	jmp    80096b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800966:	89 c7                	mov    %eax,%edi
  800968:	fc                   	cld    
  800969:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096b:	5e                   	pop    %esi
  80096c:	5f                   	pop    %edi
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800972:	ff 75 10             	pushl  0x10(%ebp)
  800975:	ff 75 0c             	pushl  0xc(%ebp)
  800978:	ff 75 08             	pushl  0x8(%ebp)
  80097b:	e8 87 ff ff ff       	call   800907 <memmove>
}
  800980:	c9                   	leave  
  800981:	c3                   	ret    

00800982 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098d:	89 c6                	mov    %eax,%esi
  80098f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800992:	eb 1a                	jmp    8009ae <memcmp+0x2c>
		if (*s1 != *s2)
  800994:	0f b6 08             	movzbl (%eax),%ecx
  800997:	0f b6 1a             	movzbl (%edx),%ebx
  80099a:	38 d9                	cmp    %bl,%cl
  80099c:	74 0a                	je     8009a8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80099e:	0f b6 c1             	movzbl %cl,%eax
  8009a1:	0f b6 db             	movzbl %bl,%ebx
  8009a4:	29 d8                	sub    %ebx,%eax
  8009a6:	eb 0f                	jmp    8009b7 <memcmp+0x35>
		s1++, s2++;
  8009a8:	83 c0 01             	add    $0x1,%eax
  8009ab:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ae:	39 f0                	cmp    %esi,%eax
  8009b0:	75 e2                	jne    800994 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b7:	5b                   	pop    %ebx
  8009b8:	5e                   	pop    %esi
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c2:	89 c1                	mov    %eax,%ecx
  8009c4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cb:	eb 0a                	jmp    8009d7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cd:	0f b6 10             	movzbl (%eax),%edx
  8009d0:	39 da                	cmp    %ebx,%edx
  8009d2:	74 07                	je     8009db <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d4:	83 c0 01             	add    $0x1,%eax
  8009d7:	39 c8                	cmp    %ecx,%eax
  8009d9:	72 f2                	jb     8009cd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009db:	5b                   	pop    %ebx
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	57                   	push   %edi
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ea:	eb 03                	jmp    8009ef <strtol+0x11>
		s++;
  8009ec:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ef:	0f b6 01             	movzbl (%ecx),%eax
  8009f2:	3c 20                	cmp    $0x20,%al
  8009f4:	74 f6                	je     8009ec <strtol+0xe>
  8009f6:	3c 09                	cmp    $0x9,%al
  8009f8:	74 f2                	je     8009ec <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fa:	3c 2b                	cmp    $0x2b,%al
  8009fc:	75 0a                	jne    800a08 <strtol+0x2a>
		s++;
  8009fe:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a01:	bf 00 00 00 00       	mov    $0x0,%edi
  800a06:	eb 11                	jmp    800a19 <strtol+0x3b>
  800a08:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0d:	3c 2d                	cmp    $0x2d,%al
  800a0f:	75 08                	jne    800a19 <strtol+0x3b>
		s++, neg = 1;
  800a11:	83 c1 01             	add    $0x1,%ecx
  800a14:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a19:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a1f:	75 15                	jne    800a36 <strtol+0x58>
  800a21:	80 39 30             	cmpb   $0x30,(%ecx)
  800a24:	75 10                	jne    800a36 <strtol+0x58>
  800a26:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2a:	75 7c                	jne    800aa8 <strtol+0xca>
		s += 2, base = 16;
  800a2c:	83 c1 02             	add    $0x2,%ecx
  800a2f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a34:	eb 16                	jmp    800a4c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a36:	85 db                	test   %ebx,%ebx
  800a38:	75 12                	jne    800a4c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a42:	75 08                	jne    800a4c <strtol+0x6e>
		s++, base = 8;
  800a44:	83 c1 01             	add    $0x1,%ecx
  800a47:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a51:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a54:	0f b6 11             	movzbl (%ecx),%edx
  800a57:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5a:	89 f3                	mov    %esi,%ebx
  800a5c:	80 fb 09             	cmp    $0x9,%bl
  800a5f:	77 08                	ja     800a69 <strtol+0x8b>
			dig = *s - '0';
  800a61:	0f be d2             	movsbl %dl,%edx
  800a64:	83 ea 30             	sub    $0x30,%edx
  800a67:	eb 22                	jmp    800a8b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a69:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6c:	89 f3                	mov    %esi,%ebx
  800a6e:	80 fb 19             	cmp    $0x19,%bl
  800a71:	77 08                	ja     800a7b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a73:	0f be d2             	movsbl %dl,%edx
  800a76:	83 ea 57             	sub    $0x57,%edx
  800a79:	eb 10                	jmp    800a8b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a7b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a7e:	89 f3                	mov    %esi,%ebx
  800a80:	80 fb 19             	cmp    $0x19,%bl
  800a83:	77 16                	ja     800a9b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a85:	0f be d2             	movsbl %dl,%edx
  800a88:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8e:	7d 0b                	jge    800a9b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a90:	83 c1 01             	add    $0x1,%ecx
  800a93:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a97:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a99:	eb b9                	jmp    800a54 <strtol+0x76>

	if (endptr)
  800a9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9f:	74 0d                	je     800aae <strtol+0xd0>
		*endptr = (char *) s;
  800aa1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa4:	89 0e                	mov    %ecx,(%esi)
  800aa6:	eb 06                	jmp    800aae <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa8:	85 db                	test   %ebx,%ebx
  800aaa:	74 98                	je     800a44 <strtol+0x66>
  800aac:	eb 9e                	jmp    800a4c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aae:	89 c2                	mov    %eax,%edx
  800ab0:	f7 da                	neg    %edx
  800ab2:	85 ff                	test   %edi,%edi
  800ab4:	0f 45 c2             	cmovne %edx,%eax
}
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
  800ac2:	83 ec 04             	sub    $0x4,%esp
  800ac5:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800ac8:	57                   	push   %edi
  800ac9:	e8 6e fc ff ff       	call   80073c <strlen>
  800ace:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800ad1:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800ad4:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800ade:	eb 46                	jmp    800b26 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800ae0:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800ae4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800ae7:	80 f9 09             	cmp    $0x9,%cl
  800aea:	77 08                	ja     800af4 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800aec:	0f be d2             	movsbl %dl,%edx
  800aef:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800af2:	eb 27                	jmp    800b1b <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800af4:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800af7:	80 f9 05             	cmp    $0x5,%cl
  800afa:	77 08                	ja     800b04 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800afc:	0f be d2             	movsbl %dl,%edx
  800aff:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800b02:	eb 17                	jmp    800b1b <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800b04:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800b07:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800b0a:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800b0f:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800b13:	77 06                	ja     800b1b <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800b15:	0f be d2             	movsbl %dl,%edx
  800b18:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800b1b:	0f af ce             	imul   %esi,%ecx
  800b1e:	01 c8                	add    %ecx,%eax
		base *= 16;
  800b20:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b23:	83 eb 01             	sub    $0x1,%ebx
  800b26:	83 fb 01             	cmp    $0x1,%ebx
  800b29:	7f b5                	jg     800ae0 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800b2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5f                   	pop    %edi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b39:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b41:	8b 55 08             	mov    0x8(%ebp),%edx
  800b44:	89 c3                	mov    %eax,%ebx
  800b46:	89 c7                	mov    %eax,%edi
  800b48:	89 c6                	mov    %eax,%esi
  800b4a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b57:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b61:	89 d1                	mov    %edx,%ecx
  800b63:	89 d3                	mov    %edx,%ebx
  800b65:	89 d7                	mov    %edx,%edi
  800b67:	89 d6                	mov    %edx,%esi
  800b69:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
  800b76:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b83:	8b 55 08             	mov    0x8(%ebp),%edx
  800b86:	89 cb                	mov    %ecx,%ebx
  800b88:	89 cf                	mov    %ecx,%edi
  800b8a:	89 ce                	mov    %ecx,%esi
  800b8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8e:	85 c0                	test   %eax,%eax
  800b90:	7e 17                	jle    800ba9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b92:	83 ec 0c             	sub    $0xc,%esp
  800b95:	50                   	push   %eax
  800b96:	6a 03                	push   $0x3
  800b98:	68 3f 22 80 00       	push   $0x80223f
  800b9d:	6a 23                	push   $0x23
  800b9f:	68 5c 22 80 00       	push   $0x80225c
  800ba4:	e8 69 0f 00 00       	call   801b12 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbc:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc1:	89 d1                	mov    %edx,%ecx
  800bc3:	89 d3                	mov    %edx,%ebx
  800bc5:	89 d7                	mov    %edx,%edi
  800bc7:	89 d6                	mov    %edx,%esi
  800bc9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5f                   	pop    %edi
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <sys_yield>:

void
sys_yield(void)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	57                   	push   %edi
  800bd4:	56                   	push   %esi
  800bd5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be0:	89 d1                	mov    %edx,%ecx
  800be2:	89 d3                	mov    %edx,%ebx
  800be4:	89 d7                	mov    %edx,%edi
  800be6:	89 d6                	mov    %edx,%esi
  800be8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
  800bf5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf8:	be 00 00 00 00       	mov    $0x0,%esi
  800bfd:	b8 04 00 00 00       	mov    $0x4,%eax
  800c02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c05:	8b 55 08             	mov    0x8(%ebp),%edx
  800c08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0b:	89 f7                	mov    %esi,%edi
  800c0d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	7e 17                	jle    800c2a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c13:	83 ec 0c             	sub    $0xc,%esp
  800c16:	50                   	push   %eax
  800c17:	6a 04                	push   $0x4
  800c19:	68 3f 22 80 00       	push   $0x80223f
  800c1e:	6a 23                	push   $0x23
  800c20:	68 5c 22 80 00       	push   $0x80225c
  800c25:	e8 e8 0e 00 00       	call   801b12 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800c3b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
  800c46:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c49:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c4c:	8b 75 18             	mov    0x18(%ebp),%esi
  800c4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c51:	85 c0                	test   %eax,%eax
  800c53:	7e 17                	jle    800c6c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c55:	83 ec 0c             	sub    $0xc,%esp
  800c58:	50                   	push   %eax
  800c59:	6a 05                	push   $0x5
  800c5b:	68 3f 22 80 00       	push   $0x80223f
  800c60:	6a 23                	push   $0x23
  800c62:	68 5c 22 80 00       	push   $0x80225c
  800c67:	e8 a6 0e 00 00       	call   801b12 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
  800c7a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c82:	b8 06 00 00 00       	mov    $0x6,%eax
  800c87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8d:	89 df                	mov    %ebx,%edi
  800c8f:	89 de                	mov    %ebx,%esi
  800c91:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c93:	85 c0                	test   %eax,%eax
  800c95:	7e 17                	jle    800cae <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c97:	83 ec 0c             	sub    $0xc,%esp
  800c9a:	50                   	push   %eax
  800c9b:	6a 06                	push   $0x6
  800c9d:	68 3f 22 80 00       	push   $0x80223f
  800ca2:	6a 23                	push   $0x23
  800ca4:	68 5c 22 80 00       	push   $0x80225c
  800ca9:	e8 64 0e 00 00       	call   801b12 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc4:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccf:	89 df                	mov    %ebx,%edi
  800cd1:	89 de                	mov    %ebx,%esi
  800cd3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	7e 17                	jle    800cf0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd9:	83 ec 0c             	sub    $0xc,%esp
  800cdc:	50                   	push   %eax
  800cdd:	6a 08                	push   $0x8
  800cdf:	68 3f 22 80 00       	push   $0x80223f
  800ce4:	6a 23                	push   $0x23
  800ce6:	68 5c 22 80 00       	push   $0x80225c
  800ceb:	e8 22 0e 00 00       	call   801b12 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
  800cfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d01:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d06:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	89 df                	mov    %ebx,%edi
  800d13:	89 de                	mov    %ebx,%esi
  800d15:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d17:	85 c0                	test   %eax,%eax
  800d19:	7e 17                	jle    800d32 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1b:	83 ec 0c             	sub    $0xc,%esp
  800d1e:	50                   	push   %eax
  800d1f:	6a 0a                	push   $0xa
  800d21:	68 3f 22 80 00       	push   $0x80223f
  800d26:	6a 23                	push   $0x23
  800d28:	68 5c 22 80 00       	push   $0x80225c
  800d2d:	e8 e0 0d 00 00       	call   801b12 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d48:	b8 09 00 00 00       	mov    $0x9,%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	89 df                	mov    %ebx,%edi
  800d55:	89 de                	mov    %ebx,%esi
  800d57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 17                	jle    800d74 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	50                   	push   %eax
  800d61:	6a 09                	push   $0x9
  800d63:	68 3f 22 80 00       	push   $0x80223f
  800d68:	6a 23                	push   $0x23
  800d6a:	68 5c 22 80 00       	push   $0x80225c
  800d6f:	e8 9e 0d 00 00       	call   801b12 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d82:	be 00 00 00 00       	mov    $0x0,%esi
  800d87:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d95:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d98:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	57                   	push   %edi
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
  800da5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dad:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	89 cb                	mov    %ecx,%ebx
  800db7:	89 cf                	mov    %ecx,%edi
  800db9:	89 ce                	mov    %ecx,%esi
  800dbb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	7e 17                	jle    800dd8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	50                   	push   %eax
  800dc5:	6a 0d                	push   $0xd
  800dc7:	68 3f 22 80 00       	push   $0x80223f
  800dcc:	6a 23                	push   $0x23
  800dce:	68 5c 22 80 00       	push   $0x80225c
  800dd3:	e8 3a 0d 00 00       	call   801b12 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800de3:	8b 45 08             	mov    0x8(%ebp),%eax
  800de6:	05 00 00 00 30       	add    $0x30000000,%eax
  800deb:	c1 e8 0c             	shr    $0xc,%eax
}
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800df3:	8b 45 08             	mov    0x8(%ebp),%eax
  800df6:	05 00 00 00 30       	add    $0x30000000,%eax
  800dfb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e00:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e12:	89 c2                	mov    %eax,%edx
  800e14:	c1 ea 16             	shr    $0x16,%edx
  800e17:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e1e:	f6 c2 01             	test   $0x1,%dl
  800e21:	74 11                	je     800e34 <fd_alloc+0x2d>
  800e23:	89 c2                	mov    %eax,%edx
  800e25:	c1 ea 0c             	shr    $0xc,%edx
  800e28:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2f:	f6 c2 01             	test   $0x1,%dl
  800e32:	75 09                	jne    800e3d <fd_alloc+0x36>
			*fd_store = fd;
  800e34:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e36:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3b:	eb 17                	jmp    800e54 <fd_alloc+0x4d>
  800e3d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e42:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e47:	75 c9                	jne    800e12 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e49:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e4f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e5c:	83 f8 1f             	cmp    $0x1f,%eax
  800e5f:	77 36                	ja     800e97 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e61:	c1 e0 0c             	shl    $0xc,%eax
  800e64:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e69:	89 c2                	mov    %eax,%edx
  800e6b:	c1 ea 16             	shr    $0x16,%edx
  800e6e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e75:	f6 c2 01             	test   $0x1,%dl
  800e78:	74 24                	je     800e9e <fd_lookup+0x48>
  800e7a:	89 c2                	mov    %eax,%edx
  800e7c:	c1 ea 0c             	shr    $0xc,%edx
  800e7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e86:	f6 c2 01             	test   $0x1,%dl
  800e89:	74 1a                	je     800ea5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8e:	89 02                	mov    %eax,(%edx)
	return 0;
  800e90:	b8 00 00 00 00       	mov    $0x0,%eax
  800e95:	eb 13                	jmp    800eaa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e9c:	eb 0c                	jmp    800eaa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea3:	eb 05                	jmp    800eaa <fd_lookup+0x54>
  800ea5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 08             	sub    $0x8,%esp
  800eb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb5:	ba e8 22 80 00       	mov    $0x8022e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eba:	eb 13                	jmp    800ecf <dev_lookup+0x23>
  800ebc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ebf:	39 08                	cmp    %ecx,(%eax)
  800ec1:	75 0c                	jne    800ecf <dev_lookup+0x23>
			*dev = devtab[i];
  800ec3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec6:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ec8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecd:	eb 2e                	jmp    800efd <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ecf:	8b 02                	mov    (%edx),%eax
  800ed1:	85 c0                	test   %eax,%eax
  800ed3:	75 e7                	jne    800ebc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ed5:	a1 08 40 80 00       	mov    0x804008,%eax
  800eda:	8b 40 48             	mov    0x48(%eax),%eax
  800edd:	83 ec 04             	sub    $0x4,%esp
  800ee0:	51                   	push   %ecx
  800ee1:	50                   	push   %eax
  800ee2:	68 6c 22 80 00       	push   $0x80226c
  800ee7:	e8 55 f2 ff ff       	call   800141 <cprintf>
	*dev = 0;
  800eec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ef5:	83 c4 10             	add    $0x10,%esp
  800ef8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    

00800eff <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 10             	sub    $0x10,%esp
  800f07:	8b 75 08             	mov    0x8(%ebp),%esi
  800f0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f10:	50                   	push   %eax
  800f11:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f17:	c1 e8 0c             	shr    $0xc,%eax
  800f1a:	50                   	push   %eax
  800f1b:	e8 36 ff ff ff       	call   800e56 <fd_lookup>
  800f20:	83 c4 08             	add    $0x8,%esp
  800f23:	85 c0                	test   %eax,%eax
  800f25:	78 05                	js     800f2c <fd_close+0x2d>
	    || fd != fd2) 
  800f27:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f2a:	74 0c                	je     800f38 <fd_close+0x39>
		return (must_exist ? r : 0); 
  800f2c:	84 db                	test   %bl,%bl
  800f2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f33:	0f 44 c2             	cmove  %edx,%eax
  800f36:	eb 41                	jmp    800f79 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f38:	83 ec 08             	sub    $0x8,%esp
  800f3b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f3e:	50                   	push   %eax
  800f3f:	ff 36                	pushl  (%esi)
  800f41:	e8 66 ff ff ff       	call   800eac <dev_lookup>
  800f46:	89 c3                	mov    %eax,%ebx
  800f48:	83 c4 10             	add    $0x10,%esp
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	78 1a                	js     800f69 <fd_close+0x6a>
		if (dev->dev_close) 
  800f4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f52:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  800f55:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	74 0b                	je     800f69 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f5e:	83 ec 0c             	sub    $0xc,%esp
  800f61:	56                   	push   %esi
  800f62:	ff d0                	call   *%eax
  800f64:	89 c3                	mov    %eax,%ebx
  800f66:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f69:	83 ec 08             	sub    $0x8,%esp
  800f6c:	56                   	push   %esi
  800f6d:	6a 00                	push   $0x0
  800f6f:	e8 00 fd ff ff       	call   800c74 <sys_page_unmap>
	return r;
  800f74:	83 c4 10             	add    $0x10,%esp
  800f77:	89 d8                	mov    %ebx,%eax
}
  800f79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f7c:	5b                   	pop    %ebx
  800f7d:	5e                   	pop    %esi
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    

00800f80 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f89:	50                   	push   %eax
  800f8a:	ff 75 08             	pushl  0x8(%ebp)
  800f8d:	e8 c4 fe ff ff       	call   800e56 <fd_lookup>
  800f92:	83 c4 08             	add    $0x8,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	78 10                	js     800fa9 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  800f99:	83 ec 08             	sub    $0x8,%esp
  800f9c:	6a 01                	push   $0x1
  800f9e:	ff 75 f4             	pushl  -0xc(%ebp)
  800fa1:	e8 59 ff ff ff       	call   800eff <fd_close>
  800fa6:	83 c4 10             	add    $0x10,%esp
}
  800fa9:	c9                   	leave  
  800faa:	c3                   	ret    

00800fab <close_all>:

void
close_all(void)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	53                   	push   %ebx
  800faf:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fb7:	83 ec 0c             	sub    $0xc,%esp
  800fba:	53                   	push   %ebx
  800fbb:	e8 c0 ff ff ff       	call   800f80 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc0:	83 c3 01             	add    $0x1,%ebx
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	83 fb 20             	cmp    $0x20,%ebx
  800fc9:	75 ec                	jne    800fb7 <close_all+0xc>
		close(i);
}
  800fcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fce:	c9                   	leave  
  800fcf:	c3                   	ret    

00800fd0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	57                   	push   %edi
  800fd4:	56                   	push   %esi
  800fd5:	53                   	push   %ebx
  800fd6:	83 ec 2c             	sub    $0x2c,%esp
  800fd9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fdc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fdf:	50                   	push   %eax
  800fe0:	ff 75 08             	pushl  0x8(%ebp)
  800fe3:	e8 6e fe ff ff       	call   800e56 <fd_lookup>
  800fe8:	83 c4 08             	add    $0x8,%esp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	0f 88 c1 00 00 00    	js     8010b4 <dup+0xe4>
		return r;
	close(newfdnum);
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	56                   	push   %esi
  800ff7:	e8 84 ff ff ff       	call   800f80 <close>

	newfd = INDEX2FD(newfdnum);
  800ffc:	89 f3                	mov    %esi,%ebx
  800ffe:	c1 e3 0c             	shl    $0xc,%ebx
  801001:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801007:	83 c4 04             	add    $0x4,%esp
  80100a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80100d:	e8 de fd ff ff       	call   800df0 <fd2data>
  801012:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801014:	89 1c 24             	mov    %ebx,(%esp)
  801017:	e8 d4 fd ff ff       	call   800df0 <fd2data>
  80101c:	83 c4 10             	add    $0x10,%esp
  80101f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801022:	89 f8                	mov    %edi,%eax
  801024:	c1 e8 16             	shr    $0x16,%eax
  801027:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80102e:	a8 01                	test   $0x1,%al
  801030:	74 37                	je     801069 <dup+0x99>
  801032:	89 f8                	mov    %edi,%eax
  801034:	c1 e8 0c             	shr    $0xc,%eax
  801037:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103e:	f6 c2 01             	test   $0x1,%dl
  801041:	74 26                	je     801069 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801043:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	25 07 0e 00 00       	and    $0xe07,%eax
  801052:	50                   	push   %eax
  801053:	ff 75 d4             	pushl  -0x2c(%ebp)
  801056:	6a 00                	push   $0x0
  801058:	57                   	push   %edi
  801059:	6a 00                	push   $0x0
  80105b:	e8 d2 fb ff ff       	call   800c32 <sys_page_map>
  801060:	89 c7                	mov    %eax,%edi
  801062:	83 c4 20             	add    $0x20,%esp
  801065:	85 c0                	test   %eax,%eax
  801067:	78 2e                	js     801097 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801069:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80106c:	89 d0                	mov    %edx,%eax
  80106e:	c1 e8 0c             	shr    $0xc,%eax
  801071:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	25 07 0e 00 00       	and    $0xe07,%eax
  801080:	50                   	push   %eax
  801081:	53                   	push   %ebx
  801082:	6a 00                	push   $0x0
  801084:	52                   	push   %edx
  801085:	6a 00                	push   $0x0
  801087:	e8 a6 fb ff ff       	call   800c32 <sys_page_map>
  80108c:	89 c7                	mov    %eax,%edi
  80108e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801091:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801093:	85 ff                	test   %edi,%edi
  801095:	79 1d                	jns    8010b4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801097:	83 ec 08             	sub    $0x8,%esp
  80109a:	53                   	push   %ebx
  80109b:	6a 00                	push   $0x0
  80109d:	e8 d2 fb ff ff       	call   800c74 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010a2:	83 c4 08             	add    $0x8,%esp
  8010a5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a8:	6a 00                	push   $0x0
  8010aa:	e8 c5 fb ff ff       	call   800c74 <sys_page_unmap>
	return r;
  8010af:	83 c4 10             	add    $0x10,%esp
  8010b2:	89 f8                	mov    %edi,%eax
}
  8010b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b7:	5b                   	pop    %ebx
  8010b8:	5e                   	pop    %esi
  8010b9:	5f                   	pop    %edi
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    

008010bc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	53                   	push   %ebx
  8010c0:	83 ec 14             	sub    $0x14,%esp
  8010c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c9:	50                   	push   %eax
  8010ca:	53                   	push   %ebx
  8010cb:	e8 86 fd ff ff       	call   800e56 <fd_lookup>
  8010d0:	83 c4 08             	add    $0x8,%esp
  8010d3:	89 c2                	mov    %eax,%edx
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	78 6d                	js     801146 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d9:	83 ec 08             	sub    $0x8,%esp
  8010dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010df:	50                   	push   %eax
  8010e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e3:	ff 30                	pushl  (%eax)
  8010e5:	e8 c2 fd ff ff       	call   800eac <dev_lookup>
  8010ea:	83 c4 10             	add    $0x10,%esp
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	78 4c                	js     80113d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010f4:	8b 42 08             	mov    0x8(%edx),%eax
  8010f7:	83 e0 03             	and    $0x3,%eax
  8010fa:	83 f8 01             	cmp    $0x1,%eax
  8010fd:	75 21                	jne    801120 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010ff:	a1 08 40 80 00       	mov    0x804008,%eax
  801104:	8b 40 48             	mov    0x48(%eax),%eax
  801107:	83 ec 04             	sub    $0x4,%esp
  80110a:	53                   	push   %ebx
  80110b:	50                   	push   %eax
  80110c:	68 ad 22 80 00       	push   $0x8022ad
  801111:	e8 2b f0 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  801116:	83 c4 10             	add    $0x10,%esp
  801119:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80111e:	eb 26                	jmp    801146 <read+0x8a>
	}
	if (!dev->dev_read)
  801120:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801123:	8b 40 08             	mov    0x8(%eax),%eax
  801126:	85 c0                	test   %eax,%eax
  801128:	74 17                	je     801141 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80112a:	83 ec 04             	sub    $0x4,%esp
  80112d:	ff 75 10             	pushl  0x10(%ebp)
  801130:	ff 75 0c             	pushl  0xc(%ebp)
  801133:	52                   	push   %edx
  801134:	ff d0                	call   *%eax
  801136:	89 c2                	mov    %eax,%edx
  801138:	83 c4 10             	add    $0x10,%esp
  80113b:	eb 09                	jmp    801146 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113d:	89 c2                	mov    %eax,%edx
  80113f:	eb 05                	jmp    801146 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801141:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801146:	89 d0                	mov    %edx,%eax
  801148:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80114b:	c9                   	leave  
  80114c:	c3                   	ret    

0080114d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	57                   	push   %edi
  801151:	56                   	push   %esi
  801152:	53                   	push   %ebx
  801153:	83 ec 0c             	sub    $0xc,%esp
  801156:	8b 7d 08             	mov    0x8(%ebp),%edi
  801159:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80115c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801161:	eb 21                	jmp    801184 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801163:	83 ec 04             	sub    $0x4,%esp
  801166:	89 f0                	mov    %esi,%eax
  801168:	29 d8                	sub    %ebx,%eax
  80116a:	50                   	push   %eax
  80116b:	89 d8                	mov    %ebx,%eax
  80116d:	03 45 0c             	add    0xc(%ebp),%eax
  801170:	50                   	push   %eax
  801171:	57                   	push   %edi
  801172:	e8 45 ff ff ff       	call   8010bc <read>
		if (m < 0)
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	85 c0                	test   %eax,%eax
  80117c:	78 10                	js     80118e <readn+0x41>
			return m;
		if (m == 0)
  80117e:	85 c0                	test   %eax,%eax
  801180:	74 0a                	je     80118c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801182:	01 c3                	add    %eax,%ebx
  801184:	39 f3                	cmp    %esi,%ebx
  801186:	72 db                	jb     801163 <readn+0x16>
  801188:	89 d8                	mov    %ebx,%eax
  80118a:	eb 02                	jmp    80118e <readn+0x41>
  80118c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80118e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801191:	5b                   	pop    %ebx
  801192:	5e                   	pop    %esi
  801193:	5f                   	pop    %edi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	53                   	push   %ebx
  80119a:	83 ec 14             	sub    $0x14,%esp
  80119d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a3:	50                   	push   %eax
  8011a4:	53                   	push   %ebx
  8011a5:	e8 ac fc ff ff       	call   800e56 <fd_lookup>
  8011aa:	83 c4 08             	add    $0x8,%esp
  8011ad:	89 c2                	mov    %eax,%edx
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	78 68                	js     80121b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b3:	83 ec 08             	sub    $0x8,%esp
  8011b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b9:	50                   	push   %eax
  8011ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011bd:	ff 30                	pushl  (%eax)
  8011bf:	e8 e8 fc ff ff       	call   800eac <dev_lookup>
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	78 47                	js     801212 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ce:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011d2:	75 21                	jne    8011f5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011d4:	a1 08 40 80 00       	mov    0x804008,%eax
  8011d9:	8b 40 48             	mov    0x48(%eax),%eax
  8011dc:	83 ec 04             	sub    $0x4,%esp
  8011df:	53                   	push   %ebx
  8011e0:	50                   	push   %eax
  8011e1:	68 c9 22 80 00       	push   $0x8022c9
  8011e6:	e8 56 ef ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  8011eb:	83 c4 10             	add    $0x10,%esp
  8011ee:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011f3:	eb 26                	jmp    80121b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8011fb:	85 d2                	test   %edx,%edx
  8011fd:	74 17                	je     801216 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011ff:	83 ec 04             	sub    $0x4,%esp
  801202:	ff 75 10             	pushl  0x10(%ebp)
  801205:	ff 75 0c             	pushl  0xc(%ebp)
  801208:	50                   	push   %eax
  801209:	ff d2                	call   *%edx
  80120b:	89 c2                	mov    %eax,%edx
  80120d:	83 c4 10             	add    $0x10,%esp
  801210:	eb 09                	jmp    80121b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801212:	89 c2                	mov    %eax,%edx
  801214:	eb 05                	jmp    80121b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801216:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80121b:	89 d0                	mov    %edx,%eax
  80121d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801220:	c9                   	leave  
  801221:	c3                   	ret    

00801222 <seek>:

int
seek(int fdnum, off_t offset)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801228:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80122b:	50                   	push   %eax
  80122c:	ff 75 08             	pushl  0x8(%ebp)
  80122f:	e8 22 fc ff ff       	call   800e56 <fd_lookup>
  801234:	83 c4 08             	add    $0x8,%esp
  801237:	85 c0                	test   %eax,%eax
  801239:	78 0e                	js     801249 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80123b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80123e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801241:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801244:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	53                   	push   %ebx
  80124f:	83 ec 14             	sub    $0x14,%esp
  801252:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801255:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801258:	50                   	push   %eax
  801259:	53                   	push   %ebx
  80125a:	e8 f7 fb ff ff       	call   800e56 <fd_lookup>
  80125f:	83 c4 08             	add    $0x8,%esp
  801262:	89 c2                	mov    %eax,%edx
  801264:	85 c0                	test   %eax,%eax
  801266:	78 65                	js     8012cd <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801268:	83 ec 08             	sub    $0x8,%esp
  80126b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126e:	50                   	push   %eax
  80126f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801272:	ff 30                	pushl  (%eax)
  801274:	e8 33 fc ff ff       	call   800eac <dev_lookup>
  801279:	83 c4 10             	add    $0x10,%esp
  80127c:	85 c0                	test   %eax,%eax
  80127e:	78 44                	js     8012c4 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801280:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801283:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801287:	75 21                	jne    8012aa <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801289:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80128e:	8b 40 48             	mov    0x48(%eax),%eax
  801291:	83 ec 04             	sub    $0x4,%esp
  801294:	53                   	push   %ebx
  801295:	50                   	push   %eax
  801296:	68 8c 22 80 00       	push   $0x80228c
  80129b:	e8 a1 ee ff ff       	call   800141 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a0:	83 c4 10             	add    $0x10,%esp
  8012a3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012a8:	eb 23                	jmp    8012cd <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ad:	8b 52 18             	mov    0x18(%edx),%edx
  8012b0:	85 d2                	test   %edx,%edx
  8012b2:	74 14                	je     8012c8 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012b4:	83 ec 08             	sub    $0x8,%esp
  8012b7:	ff 75 0c             	pushl  0xc(%ebp)
  8012ba:	50                   	push   %eax
  8012bb:	ff d2                	call   *%edx
  8012bd:	89 c2                	mov    %eax,%edx
  8012bf:	83 c4 10             	add    $0x10,%esp
  8012c2:	eb 09                	jmp    8012cd <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c4:	89 c2                	mov    %eax,%edx
  8012c6:	eb 05                	jmp    8012cd <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012c8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012cd:	89 d0                	mov    %edx,%eax
  8012cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d2:	c9                   	leave  
  8012d3:	c3                   	ret    

008012d4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	53                   	push   %ebx
  8012d8:	83 ec 14             	sub    $0x14,%esp
  8012db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e1:	50                   	push   %eax
  8012e2:	ff 75 08             	pushl  0x8(%ebp)
  8012e5:	e8 6c fb ff ff       	call   800e56 <fd_lookup>
  8012ea:	83 c4 08             	add    $0x8,%esp
  8012ed:	89 c2                	mov    %eax,%edx
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 58                	js     80134b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f3:	83 ec 08             	sub    $0x8,%esp
  8012f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f9:	50                   	push   %eax
  8012fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fd:	ff 30                	pushl  (%eax)
  8012ff:	e8 a8 fb ff ff       	call   800eac <dev_lookup>
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	85 c0                	test   %eax,%eax
  801309:	78 37                	js     801342 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80130b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801312:	74 32                	je     801346 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801314:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801317:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80131e:	00 00 00 
	stat->st_isdir = 0;
  801321:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801328:	00 00 00 
	stat->st_dev = dev;
  80132b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801331:	83 ec 08             	sub    $0x8,%esp
  801334:	53                   	push   %ebx
  801335:	ff 75 f0             	pushl  -0x10(%ebp)
  801338:	ff 50 14             	call   *0x14(%eax)
  80133b:	89 c2                	mov    %eax,%edx
  80133d:	83 c4 10             	add    $0x10,%esp
  801340:	eb 09                	jmp    80134b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801342:	89 c2                	mov    %eax,%edx
  801344:	eb 05                	jmp    80134b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801346:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80134b:	89 d0                	mov    %edx,%eax
  80134d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801350:	c9                   	leave  
  801351:	c3                   	ret    

00801352 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	56                   	push   %esi
  801356:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801357:	83 ec 08             	sub    $0x8,%esp
  80135a:	6a 00                	push   $0x0
  80135c:	ff 75 08             	pushl  0x8(%ebp)
  80135f:	e8 2b 02 00 00       	call   80158f <open>
  801364:	89 c3                	mov    %eax,%ebx
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	85 c0                	test   %eax,%eax
  80136b:	78 1b                	js     801388 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80136d:	83 ec 08             	sub    $0x8,%esp
  801370:	ff 75 0c             	pushl  0xc(%ebp)
  801373:	50                   	push   %eax
  801374:	e8 5b ff ff ff       	call   8012d4 <fstat>
  801379:	89 c6                	mov    %eax,%esi
	close(fd);
  80137b:	89 1c 24             	mov    %ebx,(%esp)
  80137e:	e8 fd fb ff ff       	call   800f80 <close>
	return r;
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	89 f0                	mov    %esi,%eax
}
  801388:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80138b:	5b                   	pop    %ebx
  80138c:	5e                   	pop    %esi
  80138d:	5d                   	pop    %ebp
  80138e:	c3                   	ret    

0080138f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	56                   	push   %esi
  801393:	53                   	push   %ebx
  801394:	89 c6                	mov    %eax,%esi
  801396:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801398:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80139f:	75 12                	jne    8013b3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013a1:	83 ec 0c             	sub    $0xc,%esp
  8013a4:	6a 01                	push   $0x1
  8013a6:	e8 6c 08 00 00       	call   801c17 <ipc_find_env>
  8013ab:	a3 04 40 80 00       	mov    %eax,0x804004
  8013b0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013b3:	6a 07                	push   $0x7
  8013b5:	68 00 50 80 00       	push   $0x805000
  8013ba:	56                   	push   %esi
  8013bb:	ff 35 04 40 80 00    	pushl  0x804004
  8013c1:	e8 fb 07 00 00       	call   801bc1 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8013c6:	83 c4 0c             	add    $0xc,%esp
  8013c9:	6a 00                	push   $0x0
  8013cb:	53                   	push   %ebx
  8013cc:	6a 00                	push   $0x0
  8013ce:	e8 85 07 00 00       	call   801b58 <ipc_recv>
}
  8013d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d6:	5b                   	pop    %ebx
  8013d7:	5e                   	pop    %esi
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    

008013da <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ee:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f8:	b8 02 00 00 00       	mov    $0x2,%eax
  8013fd:	e8 8d ff ff ff       	call   80138f <fsipc>
}
  801402:	c9                   	leave  
  801403:	c3                   	ret    

00801404 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80140a:	8b 45 08             	mov    0x8(%ebp),%eax
  80140d:	8b 40 0c             	mov    0xc(%eax),%eax
  801410:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801415:	ba 00 00 00 00       	mov    $0x0,%edx
  80141a:	b8 06 00 00 00       	mov    $0x6,%eax
  80141f:	e8 6b ff ff ff       	call   80138f <fsipc>
}
  801424:	c9                   	leave  
  801425:	c3                   	ret    

00801426 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	53                   	push   %ebx
  80142a:	83 ec 04             	sub    $0x4,%esp
  80142d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801430:	8b 45 08             	mov    0x8(%ebp),%eax
  801433:	8b 40 0c             	mov    0xc(%eax),%eax
  801436:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80143b:	ba 00 00 00 00       	mov    $0x0,%edx
  801440:	b8 05 00 00 00       	mov    $0x5,%eax
  801445:	e8 45 ff ff ff       	call   80138f <fsipc>
  80144a:	85 c0                	test   %eax,%eax
  80144c:	78 2c                	js     80147a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80144e:	83 ec 08             	sub    $0x8,%esp
  801451:	68 00 50 80 00       	push   $0x805000
  801456:	53                   	push   %ebx
  801457:	e8 19 f3 ff ff       	call   800775 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80145c:	a1 80 50 80 00       	mov    0x805080,%eax
  801461:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801467:	a1 84 50 80 00       	mov    0x805084,%eax
  80146c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80147a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    

0080147f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	53                   	push   %ebx
  801483:	83 ec 08             	sub    $0x8,%esp
  801486:	8b 45 10             	mov    0x10(%ebp),%eax
  801489:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80148e:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801493:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801496:	8b 45 08             	mov    0x8(%ebp),%eax
  801499:	8b 40 0c             	mov    0xc(%eax),%eax
  80149c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  8014a1:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014a7:	53                   	push   %ebx
  8014a8:	ff 75 0c             	pushl  0xc(%ebp)
  8014ab:	68 08 50 80 00       	push   $0x805008
  8014b0:	e8 52 f4 ff ff       	call   800907 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8014b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ba:	b8 04 00 00 00       	mov    $0x4,%eax
  8014bf:	e8 cb fe ff ff       	call   80138f <fsipc>
  8014c4:	83 c4 10             	add    $0x10,%esp
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 3d                	js     801508 <devfile_write+0x89>
		return r;

	assert(r <= n);
  8014cb:	39 d8                	cmp    %ebx,%eax
  8014cd:	76 19                	jbe    8014e8 <devfile_write+0x69>
  8014cf:	68 f8 22 80 00       	push   $0x8022f8
  8014d4:	68 ff 22 80 00       	push   $0x8022ff
  8014d9:	68 9f 00 00 00       	push   $0x9f
  8014de:	68 14 23 80 00       	push   $0x802314
  8014e3:	e8 2a 06 00 00       	call   801b12 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  8014e8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014ed:	76 19                	jbe    801508 <devfile_write+0x89>
  8014ef:	68 2c 23 80 00       	push   $0x80232c
  8014f4:	68 ff 22 80 00       	push   $0x8022ff
  8014f9:	68 a0 00 00 00       	push   $0xa0
  8014fe:	68 14 23 80 00       	push   $0x802314
  801503:	e8 0a 06 00 00       	call   801b12 <_panic>

	return r;
}
  801508:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150b:	c9                   	leave  
  80150c:	c3                   	ret    

0080150d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	56                   	push   %esi
  801511:	53                   	push   %ebx
  801512:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801515:	8b 45 08             	mov    0x8(%ebp),%eax
  801518:	8b 40 0c             	mov    0xc(%eax),%eax
  80151b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801520:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801526:	ba 00 00 00 00       	mov    $0x0,%edx
  80152b:	b8 03 00 00 00       	mov    $0x3,%eax
  801530:	e8 5a fe ff ff       	call   80138f <fsipc>
  801535:	89 c3                	mov    %eax,%ebx
  801537:	85 c0                	test   %eax,%eax
  801539:	78 4b                	js     801586 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80153b:	39 c6                	cmp    %eax,%esi
  80153d:	73 16                	jae    801555 <devfile_read+0x48>
  80153f:	68 f8 22 80 00       	push   $0x8022f8
  801544:	68 ff 22 80 00       	push   $0x8022ff
  801549:	6a 7e                	push   $0x7e
  80154b:	68 14 23 80 00       	push   $0x802314
  801550:	e8 bd 05 00 00       	call   801b12 <_panic>
	assert(r <= PGSIZE);
  801555:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80155a:	7e 16                	jle    801572 <devfile_read+0x65>
  80155c:	68 1f 23 80 00       	push   $0x80231f
  801561:	68 ff 22 80 00       	push   $0x8022ff
  801566:	6a 7f                	push   $0x7f
  801568:	68 14 23 80 00       	push   $0x802314
  80156d:	e8 a0 05 00 00       	call   801b12 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801572:	83 ec 04             	sub    $0x4,%esp
  801575:	50                   	push   %eax
  801576:	68 00 50 80 00       	push   $0x805000
  80157b:	ff 75 0c             	pushl  0xc(%ebp)
  80157e:	e8 84 f3 ff ff       	call   800907 <memmove>
	return r;
  801583:	83 c4 10             	add    $0x10,%esp
}
  801586:	89 d8                	mov    %ebx,%eax
  801588:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158b:	5b                   	pop    %ebx
  80158c:	5e                   	pop    %esi
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    

0080158f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	53                   	push   %ebx
  801593:	83 ec 20             	sub    $0x20,%esp
  801596:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801599:	53                   	push   %ebx
  80159a:	e8 9d f1 ff ff       	call   80073c <strlen>
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015a7:	7f 67                	jg     801610 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015a9:	83 ec 0c             	sub    $0xc,%esp
  8015ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015af:	50                   	push   %eax
  8015b0:	e8 52 f8 ff ff       	call   800e07 <fd_alloc>
  8015b5:	83 c4 10             	add    $0x10,%esp
		return r;
  8015b8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 57                	js     801615 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015be:	83 ec 08             	sub    $0x8,%esp
  8015c1:	53                   	push   %ebx
  8015c2:	68 00 50 80 00       	push   $0x805000
  8015c7:	e8 a9 f1 ff ff       	call   800775 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015cf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8015dc:	e8 ae fd ff ff       	call   80138f <fsipc>
  8015e1:	89 c3                	mov    %eax,%ebx
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	79 14                	jns    8015fe <open+0x6f>
		fd_close(fd, 0);
  8015ea:	83 ec 08             	sub    $0x8,%esp
  8015ed:	6a 00                	push   $0x0
  8015ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f2:	e8 08 f9 ff ff       	call   800eff <fd_close>
		return r;
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	89 da                	mov    %ebx,%edx
  8015fc:	eb 17                	jmp    801615 <open+0x86>
	}

	return fd2num(fd);
  8015fe:	83 ec 0c             	sub    $0xc,%esp
  801601:	ff 75 f4             	pushl  -0xc(%ebp)
  801604:	e8 d7 f7 ff ff       	call   800de0 <fd2num>
  801609:	89 c2                	mov    %eax,%edx
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	eb 05                	jmp    801615 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801610:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801615:	89 d0                	mov    %edx,%eax
  801617:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161a:	c9                   	leave  
  80161b:	c3                   	ret    

0080161c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801622:	ba 00 00 00 00       	mov    $0x0,%edx
  801627:	b8 08 00 00 00       	mov    $0x8,%eax
  80162c:	e8 5e fd ff ff       	call   80138f <fsipc>
}
  801631:	c9                   	leave  
  801632:	c3                   	ret    

00801633 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	56                   	push   %esi
  801637:	53                   	push   %ebx
  801638:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80163b:	83 ec 0c             	sub    $0xc,%esp
  80163e:	ff 75 08             	pushl  0x8(%ebp)
  801641:	e8 aa f7 ff ff       	call   800df0 <fd2data>
  801646:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801648:	83 c4 08             	add    $0x8,%esp
  80164b:	68 59 23 80 00       	push   $0x802359
  801650:	53                   	push   %ebx
  801651:	e8 1f f1 ff ff       	call   800775 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801656:	8b 46 04             	mov    0x4(%esi),%eax
  801659:	2b 06                	sub    (%esi),%eax
  80165b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801661:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801668:	00 00 00 
	stat->st_dev = &devpipe;
  80166b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801672:	30 80 00 
	return 0;
}
  801675:	b8 00 00 00 00       	mov    $0x0,%eax
  80167a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167d:	5b                   	pop    %ebx
  80167e:	5e                   	pop    %esi
  80167f:	5d                   	pop    %ebp
  801680:	c3                   	ret    

00801681 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	53                   	push   %ebx
  801685:	83 ec 0c             	sub    $0xc,%esp
  801688:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80168b:	53                   	push   %ebx
  80168c:	6a 00                	push   $0x0
  80168e:	e8 e1 f5 ff ff       	call   800c74 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801693:	89 1c 24             	mov    %ebx,(%esp)
  801696:	e8 55 f7 ff ff       	call   800df0 <fd2data>
  80169b:	83 c4 08             	add    $0x8,%esp
  80169e:	50                   	push   %eax
  80169f:	6a 00                	push   $0x0
  8016a1:	e8 ce f5 ff ff       	call   800c74 <sys_page_unmap>
}
  8016a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    

008016ab <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	57                   	push   %edi
  8016af:	56                   	push   %esi
  8016b0:	53                   	push   %ebx
  8016b1:	83 ec 1c             	sub    $0x1c,%esp
  8016b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016b7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016b9:	a1 08 40 80 00       	mov    0x804008,%eax
  8016be:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016c1:	83 ec 0c             	sub    $0xc,%esp
  8016c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8016c7:	e8 84 05 00 00       	call   801c50 <pageref>
  8016cc:	89 c3                	mov    %eax,%ebx
  8016ce:	89 3c 24             	mov    %edi,(%esp)
  8016d1:	e8 7a 05 00 00       	call   801c50 <pageref>
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	39 c3                	cmp    %eax,%ebx
  8016db:	0f 94 c1             	sete   %cl
  8016de:	0f b6 c9             	movzbl %cl,%ecx
  8016e1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016e4:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8016ea:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016ed:	39 ce                	cmp    %ecx,%esi
  8016ef:	74 1b                	je     80170c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016f1:	39 c3                	cmp    %eax,%ebx
  8016f3:	75 c4                	jne    8016b9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016f5:	8b 42 58             	mov    0x58(%edx),%eax
  8016f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016fb:	50                   	push   %eax
  8016fc:	56                   	push   %esi
  8016fd:	68 60 23 80 00       	push   $0x802360
  801702:	e8 3a ea ff ff       	call   800141 <cprintf>
  801707:	83 c4 10             	add    $0x10,%esp
  80170a:	eb ad                	jmp    8016b9 <_pipeisclosed+0xe>
	}
}
  80170c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80170f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801712:	5b                   	pop    %ebx
  801713:	5e                   	pop    %esi
  801714:	5f                   	pop    %edi
  801715:	5d                   	pop    %ebp
  801716:	c3                   	ret    

00801717 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	57                   	push   %edi
  80171b:	56                   	push   %esi
  80171c:	53                   	push   %ebx
  80171d:	83 ec 28             	sub    $0x28,%esp
  801720:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801723:	56                   	push   %esi
  801724:	e8 c7 f6 ff ff       	call   800df0 <fd2data>
  801729:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	bf 00 00 00 00       	mov    $0x0,%edi
  801733:	eb 4b                	jmp    801780 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801735:	89 da                	mov    %ebx,%edx
  801737:	89 f0                	mov    %esi,%eax
  801739:	e8 6d ff ff ff       	call   8016ab <_pipeisclosed>
  80173e:	85 c0                	test   %eax,%eax
  801740:	75 48                	jne    80178a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801742:	e8 89 f4 ff ff       	call   800bd0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801747:	8b 43 04             	mov    0x4(%ebx),%eax
  80174a:	8b 0b                	mov    (%ebx),%ecx
  80174c:	8d 51 20             	lea    0x20(%ecx),%edx
  80174f:	39 d0                	cmp    %edx,%eax
  801751:	73 e2                	jae    801735 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801753:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801756:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80175a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80175d:	89 c2                	mov    %eax,%edx
  80175f:	c1 fa 1f             	sar    $0x1f,%edx
  801762:	89 d1                	mov    %edx,%ecx
  801764:	c1 e9 1b             	shr    $0x1b,%ecx
  801767:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80176a:	83 e2 1f             	and    $0x1f,%edx
  80176d:	29 ca                	sub    %ecx,%edx
  80176f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801773:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801777:	83 c0 01             	add    $0x1,%eax
  80177a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80177d:	83 c7 01             	add    $0x1,%edi
  801780:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801783:	75 c2                	jne    801747 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801785:	8b 45 10             	mov    0x10(%ebp),%eax
  801788:	eb 05                	jmp    80178f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80178a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80178f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801792:	5b                   	pop    %ebx
  801793:	5e                   	pop    %esi
  801794:	5f                   	pop    %edi
  801795:	5d                   	pop    %ebp
  801796:	c3                   	ret    

00801797 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	57                   	push   %edi
  80179b:	56                   	push   %esi
  80179c:	53                   	push   %ebx
  80179d:	83 ec 18             	sub    $0x18,%esp
  8017a0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017a3:	57                   	push   %edi
  8017a4:	e8 47 f6 ff ff       	call   800df0 <fd2data>
  8017a9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b3:	eb 3d                	jmp    8017f2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017b5:	85 db                	test   %ebx,%ebx
  8017b7:	74 04                	je     8017bd <devpipe_read+0x26>
				return i;
  8017b9:	89 d8                	mov    %ebx,%eax
  8017bb:	eb 44                	jmp    801801 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017bd:	89 f2                	mov    %esi,%edx
  8017bf:	89 f8                	mov    %edi,%eax
  8017c1:	e8 e5 fe ff ff       	call   8016ab <_pipeisclosed>
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	75 32                	jne    8017fc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017ca:	e8 01 f4 ff ff       	call   800bd0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017cf:	8b 06                	mov    (%esi),%eax
  8017d1:	3b 46 04             	cmp    0x4(%esi),%eax
  8017d4:	74 df                	je     8017b5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017d6:	99                   	cltd   
  8017d7:	c1 ea 1b             	shr    $0x1b,%edx
  8017da:	01 d0                	add    %edx,%eax
  8017dc:	83 e0 1f             	and    $0x1f,%eax
  8017df:	29 d0                	sub    %edx,%eax
  8017e1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017ec:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ef:	83 c3 01             	add    $0x1,%ebx
  8017f2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017f5:	75 d8                	jne    8017cf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8017fa:	eb 05                	jmp    801801 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017fc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801801:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801804:	5b                   	pop    %ebx
  801805:	5e                   	pop    %esi
  801806:	5f                   	pop    %edi
  801807:	5d                   	pop    %ebp
  801808:	c3                   	ret    

00801809 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	56                   	push   %esi
  80180d:	53                   	push   %ebx
  80180e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801811:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801814:	50                   	push   %eax
  801815:	e8 ed f5 ff ff       	call   800e07 <fd_alloc>
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	89 c2                	mov    %eax,%edx
  80181f:	85 c0                	test   %eax,%eax
  801821:	0f 88 2c 01 00 00    	js     801953 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801827:	83 ec 04             	sub    $0x4,%esp
  80182a:	68 07 04 00 00       	push   $0x407
  80182f:	ff 75 f4             	pushl  -0xc(%ebp)
  801832:	6a 00                	push   $0x0
  801834:	e8 b6 f3 ff ff       	call   800bef <sys_page_alloc>
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	89 c2                	mov    %eax,%edx
  80183e:	85 c0                	test   %eax,%eax
  801840:	0f 88 0d 01 00 00    	js     801953 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801846:	83 ec 0c             	sub    $0xc,%esp
  801849:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80184c:	50                   	push   %eax
  80184d:	e8 b5 f5 ff ff       	call   800e07 <fd_alloc>
  801852:	89 c3                	mov    %eax,%ebx
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	85 c0                	test   %eax,%eax
  801859:	0f 88 e2 00 00 00    	js     801941 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80185f:	83 ec 04             	sub    $0x4,%esp
  801862:	68 07 04 00 00       	push   $0x407
  801867:	ff 75 f0             	pushl  -0x10(%ebp)
  80186a:	6a 00                	push   $0x0
  80186c:	e8 7e f3 ff ff       	call   800bef <sys_page_alloc>
  801871:	89 c3                	mov    %eax,%ebx
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	85 c0                	test   %eax,%eax
  801878:	0f 88 c3 00 00 00    	js     801941 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80187e:	83 ec 0c             	sub    $0xc,%esp
  801881:	ff 75 f4             	pushl  -0xc(%ebp)
  801884:	e8 67 f5 ff ff       	call   800df0 <fd2data>
  801889:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80188b:	83 c4 0c             	add    $0xc,%esp
  80188e:	68 07 04 00 00       	push   $0x407
  801893:	50                   	push   %eax
  801894:	6a 00                	push   $0x0
  801896:	e8 54 f3 ff ff       	call   800bef <sys_page_alloc>
  80189b:	89 c3                	mov    %eax,%ebx
  80189d:	83 c4 10             	add    $0x10,%esp
  8018a0:	85 c0                	test   %eax,%eax
  8018a2:	0f 88 89 00 00 00    	js     801931 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a8:	83 ec 0c             	sub    $0xc,%esp
  8018ab:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ae:	e8 3d f5 ff ff       	call   800df0 <fd2data>
  8018b3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018ba:	50                   	push   %eax
  8018bb:	6a 00                	push   $0x0
  8018bd:	56                   	push   %esi
  8018be:	6a 00                	push   $0x0
  8018c0:	e8 6d f3 ff ff       	call   800c32 <sys_page_map>
  8018c5:	89 c3                	mov    %eax,%ebx
  8018c7:	83 c4 20             	add    $0x20,%esp
  8018ca:	85 c0                	test   %eax,%eax
  8018cc:	78 55                	js     801923 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018ce:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018dc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018e3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ec:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018f8:	83 ec 0c             	sub    $0xc,%esp
  8018fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8018fe:	e8 dd f4 ff ff       	call   800de0 <fd2num>
  801903:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801906:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801908:	83 c4 04             	add    $0x4,%esp
  80190b:	ff 75 f0             	pushl  -0x10(%ebp)
  80190e:	e8 cd f4 ff ff       	call   800de0 <fd2num>
  801913:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801916:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	ba 00 00 00 00       	mov    $0x0,%edx
  801921:	eb 30                	jmp    801953 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801923:	83 ec 08             	sub    $0x8,%esp
  801926:	56                   	push   %esi
  801927:	6a 00                	push   $0x0
  801929:	e8 46 f3 ff ff       	call   800c74 <sys_page_unmap>
  80192e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801931:	83 ec 08             	sub    $0x8,%esp
  801934:	ff 75 f0             	pushl  -0x10(%ebp)
  801937:	6a 00                	push   $0x0
  801939:	e8 36 f3 ff ff       	call   800c74 <sys_page_unmap>
  80193e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801941:	83 ec 08             	sub    $0x8,%esp
  801944:	ff 75 f4             	pushl  -0xc(%ebp)
  801947:	6a 00                	push   $0x0
  801949:	e8 26 f3 ff ff       	call   800c74 <sys_page_unmap>
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801953:	89 d0                	mov    %edx,%eax
  801955:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801958:	5b                   	pop    %ebx
  801959:	5e                   	pop    %esi
  80195a:	5d                   	pop    %ebp
  80195b:	c3                   	ret    

0080195c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801962:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801965:	50                   	push   %eax
  801966:	ff 75 08             	pushl  0x8(%ebp)
  801969:	e8 e8 f4 ff ff       	call   800e56 <fd_lookup>
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	85 c0                	test   %eax,%eax
  801973:	78 18                	js     80198d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801975:	83 ec 0c             	sub    $0xc,%esp
  801978:	ff 75 f4             	pushl  -0xc(%ebp)
  80197b:	e8 70 f4 ff ff       	call   800df0 <fd2data>
	return _pipeisclosed(fd, p);
  801980:	89 c2                	mov    %eax,%edx
  801982:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801985:	e8 21 fd ff ff       	call   8016ab <_pipeisclosed>
  80198a:	83 c4 10             	add    $0x10,%esp
}
  80198d:	c9                   	leave  
  80198e:	c3                   	ret    

0080198f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801992:	b8 00 00 00 00       	mov    $0x0,%eax
  801997:	5d                   	pop    %ebp
  801998:	c3                   	ret    

00801999 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80199f:	68 78 23 80 00       	push   $0x802378
  8019a4:	ff 75 0c             	pushl  0xc(%ebp)
  8019a7:	e8 c9 ed ff ff       	call   800775 <strcpy>
	return 0;
}
  8019ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b1:	c9                   	leave  
  8019b2:	c3                   	ret    

008019b3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	57                   	push   %edi
  8019b7:	56                   	push   %esi
  8019b8:	53                   	push   %ebx
  8019b9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019bf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019c4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019ca:	eb 2d                	jmp    8019f9 <devcons_write+0x46>
		m = n - tot;
  8019cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019cf:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019d1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019d4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019d9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019dc:	83 ec 04             	sub    $0x4,%esp
  8019df:	53                   	push   %ebx
  8019e0:	03 45 0c             	add    0xc(%ebp),%eax
  8019e3:	50                   	push   %eax
  8019e4:	57                   	push   %edi
  8019e5:	e8 1d ef ff ff       	call   800907 <memmove>
		sys_cputs(buf, m);
  8019ea:	83 c4 08             	add    $0x8,%esp
  8019ed:	53                   	push   %ebx
  8019ee:	57                   	push   %edi
  8019ef:	e8 3f f1 ff ff       	call   800b33 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019f4:	01 de                	add    %ebx,%esi
  8019f6:	83 c4 10             	add    $0x10,%esp
  8019f9:	89 f0                	mov    %esi,%eax
  8019fb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019fe:	72 cc                	jb     8019cc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a03:	5b                   	pop    %ebx
  801a04:	5e                   	pop    %esi
  801a05:	5f                   	pop    %edi
  801a06:	5d                   	pop    %ebp
  801a07:	c3                   	ret    

00801a08 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	83 ec 08             	sub    $0x8,%esp
  801a0e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a13:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a17:	74 2a                	je     801a43 <devcons_read+0x3b>
  801a19:	eb 05                	jmp    801a20 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a1b:	e8 b0 f1 ff ff       	call   800bd0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a20:	e8 2c f1 ff ff       	call   800b51 <sys_cgetc>
  801a25:	85 c0                	test   %eax,%eax
  801a27:	74 f2                	je     801a1b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	78 16                	js     801a43 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a2d:	83 f8 04             	cmp    $0x4,%eax
  801a30:	74 0c                	je     801a3e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a32:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a35:	88 02                	mov    %al,(%edx)
	return 1;
  801a37:	b8 01 00 00 00       	mov    $0x1,%eax
  801a3c:	eb 05                	jmp    801a43 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a3e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a43:	c9                   	leave  
  801a44:	c3                   	ret    

00801a45 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a51:	6a 01                	push   $0x1
  801a53:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a56:	50                   	push   %eax
  801a57:	e8 d7 f0 ff ff       	call   800b33 <sys_cputs>
}
  801a5c:	83 c4 10             	add    $0x10,%esp
  801a5f:	c9                   	leave  
  801a60:	c3                   	ret    

00801a61 <getchar>:

int
getchar(void)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a67:	6a 01                	push   $0x1
  801a69:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a6c:	50                   	push   %eax
  801a6d:	6a 00                	push   $0x0
  801a6f:	e8 48 f6 ff ff       	call   8010bc <read>
	if (r < 0)
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	85 c0                	test   %eax,%eax
  801a79:	78 0f                	js     801a8a <getchar+0x29>
		return r;
	if (r < 1)
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	7e 06                	jle    801a85 <getchar+0x24>
		return -E_EOF;
	return c;
  801a7f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a83:	eb 05                	jmp    801a8a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a85:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a8a:	c9                   	leave  
  801a8b:	c3                   	ret    

00801a8c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a95:	50                   	push   %eax
  801a96:	ff 75 08             	pushl  0x8(%ebp)
  801a99:	e8 b8 f3 ff ff       	call   800e56 <fd_lookup>
  801a9e:	83 c4 10             	add    $0x10,%esp
  801aa1:	85 c0                	test   %eax,%eax
  801aa3:	78 11                	js     801ab6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aae:	39 10                	cmp    %edx,(%eax)
  801ab0:	0f 94 c0             	sete   %al
  801ab3:	0f b6 c0             	movzbl %al,%eax
}
  801ab6:	c9                   	leave  
  801ab7:	c3                   	ret    

00801ab8 <opencons>:

int
opencons(void)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801abe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac1:	50                   	push   %eax
  801ac2:	e8 40 f3 ff ff       	call   800e07 <fd_alloc>
  801ac7:	83 c4 10             	add    $0x10,%esp
		return r;
  801aca:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801acc:	85 c0                	test   %eax,%eax
  801ace:	78 3e                	js     801b0e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ad0:	83 ec 04             	sub    $0x4,%esp
  801ad3:	68 07 04 00 00       	push   $0x407
  801ad8:	ff 75 f4             	pushl  -0xc(%ebp)
  801adb:	6a 00                	push   $0x0
  801add:	e8 0d f1 ff ff       	call   800bef <sys_page_alloc>
  801ae2:	83 c4 10             	add    $0x10,%esp
		return r;
  801ae5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	78 23                	js     801b0e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801aeb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b00:	83 ec 0c             	sub    $0xc,%esp
  801b03:	50                   	push   %eax
  801b04:	e8 d7 f2 ff ff       	call   800de0 <fd2num>
  801b09:	89 c2                	mov    %eax,%edx
  801b0b:	83 c4 10             	add    $0x10,%esp
}
  801b0e:	89 d0                	mov    %edx,%eax
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    

00801b12 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	56                   	push   %esi
  801b16:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b17:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b1a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b20:	e8 8c f0 ff ff       	call   800bb1 <sys_getenvid>
  801b25:	83 ec 0c             	sub    $0xc,%esp
  801b28:	ff 75 0c             	pushl  0xc(%ebp)
  801b2b:	ff 75 08             	pushl  0x8(%ebp)
  801b2e:	56                   	push   %esi
  801b2f:	50                   	push   %eax
  801b30:	68 84 23 80 00       	push   $0x802384
  801b35:	e8 07 e6 ff ff       	call   800141 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b3a:	83 c4 18             	add    $0x18,%esp
  801b3d:	53                   	push   %ebx
  801b3e:	ff 75 10             	pushl  0x10(%ebp)
  801b41:	e8 aa e5 ff ff       	call   8000f0 <vcprintf>
	cprintf("\n");
  801b46:	c7 04 24 3c 1f 80 00 	movl   $0x801f3c,(%esp)
  801b4d:	e8 ef e5 ff ff       	call   800141 <cprintf>
  801b52:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b55:	cc                   	int3   
  801b56:	eb fd                	jmp    801b55 <_panic+0x43>

00801b58 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	56                   	push   %esi
  801b5c:	53                   	push   %ebx
  801b5d:	8b 75 08             	mov    0x8(%ebp),%esi
  801b60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801b66:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801b68:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b6d:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801b70:	83 ec 0c             	sub    $0xc,%esp
  801b73:	50                   	push   %eax
  801b74:	e8 26 f2 ff ff       	call   800d9f <sys_ipc_recv>
  801b79:	83 c4 10             	add    $0x10,%esp
  801b7c:	85 c0                	test   %eax,%eax
  801b7e:	79 16                	jns    801b96 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801b80:	85 f6                	test   %esi,%esi
  801b82:	74 06                	je     801b8a <ipc_recv+0x32>
			*from_env_store = 0;
  801b84:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801b8a:	85 db                	test   %ebx,%ebx
  801b8c:	74 2c                	je     801bba <ipc_recv+0x62>
			*perm_store = 0;
  801b8e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b94:	eb 24                	jmp    801bba <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801b96:	85 f6                	test   %esi,%esi
  801b98:	74 0a                	je     801ba4 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801b9a:	a1 08 40 80 00       	mov    0x804008,%eax
  801b9f:	8b 40 74             	mov    0x74(%eax),%eax
  801ba2:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801ba4:	85 db                	test   %ebx,%ebx
  801ba6:	74 0a                	je     801bb2 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801ba8:	a1 08 40 80 00       	mov    0x804008,%eax
  801bad:	8b 40 78             	mov    0x78(%eax),%eax
  801bb0:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801bb2:	a1 08 40 80 00       	mov    0x804008,%eax
  801bb7:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bbd:	5b                   	pop    %ebx
  801bbe:	5e                   	pop    %esi
  801bbf:	5d                   	pop    %ebp
  801bc0:	c3                   	ret    

00801bc1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	57                   	push   %edi
  801bc5:	56                   	push   %esi
  801bc6:	53                   	push   %ebx
  801bc7:	83 ec 0c             	sub    $0xc,%esp
  801bca:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bcd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801bd3:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801bd5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bda:	0f 44 d8             	cmove  %eax,%ebx
  801bdd:	eb 1e                	jmp    801bfd <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801bdf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801be2:	74 14                	je     801bf8 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801be4:	83 ec 04             	sub    $0x4,%esp
  801be7:	68 a8 23 80 00       	push   $0x8023a8
  801bec:	6a 44                	push   $0x44
  801bee:	68 d4 23 80 00       	push   $0x8023d4
  801bf3:	e8 1a ff ff ff       	call   801b12 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801bf8:	e8 d3 ef ff ff       	call   800bd0 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801bfd:	ff 75 14             	pushl  0x14(%ebp)
  801c00:	53                   	push   %ebx
  801c01:	56                   	push   %esi
  801c02:	57                   	push   %edi
  801c03:	e8 74 f1 ff ff       	call   800d7c <sys_ipc_try_send>
  801c08:	83 c4 10             	add    $0x10,%esp
  801c0b:	85 c0                	test   %eax,%eax
  801c0d:	78 d0                	js     801bdf <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5e                   	pop    %esi
  801c14:	5f                   	pop    %edi
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c1d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c22:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c25:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c2b:	8b 52 50             	mov    0x50(%edx),%edx
  801c2e:	39 ca                	cmp    %ecx,%edx
  801c30:	75 0d                	jne    801c3f <ipc_find_env+0x28>
			return envs[i].env_id;
  801c32:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c35:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c3a:	8b 40 48             	mov    0x48(%eax),%eax
  801c3d:	eb 0f                	jmp    801c4e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c3f:	83 c0 01             	add    $0x1,%eax
  801c42:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c47:	75 d9                	jne    801c22 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c4e:	5d                   	pop    %ebp
  801c4f:	c3                   	ret    

00801c50 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c56:	89 d0                	mov    %edx,%eax
  801c58:	c1 e8 16             	shr    $0x16,%eax
  801c5b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c62:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c67:	f6 c1 01             	test   $0x1,%cl
  801c6a:	74 1d                	je     801c89 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c6c:	c1 ea 0c             	shr    $0xc,%edx
  801c6f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c76:	f6 c2 01             	test   $0x1,%dl
  801c79:	74 0e                	je     801c89 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c7b:	c1 ea 0c             	shr    $0xc,%edx
  801c7e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c85:	ef 
  801c86:	0f b7 c0             	movzwl %ax,%eax
}
  801c89:	5d                   	pop    %ebp
  801c8a:	c3                   	ret    
  801c8b:	66 90                	xchg   %ax,%ax
  801c8d:	66 90                	xchg   %ax,%ax
  801c8f:	90                   	nop

00801c90 <__udivdi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	83 ec 1c             	sub    $0x1c,%esp
  801c97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca7:	85 f6                	test   %esi,%esi
  801ca9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cad:	89 ca                	mov    %ecx,%edx
  801caf:	89 f8                	mov    %edi,%eax
  801cb1:	75 3d                	jne    801cf0 <__udivdi3+0x60>
  801cb3:	39 cf                	cmp    %ecx,%edi
  801cb5:	0f 87 c5 00 00 00    	ja     801d80 <__udivdi3+0xf0>
  801cbb:	85 ff                	test   %edi,%edi
  801cbd:	89 fd                	mov    %edi,%ebp
  801cbf:	75 0b                	jne    801ccc <__udivdi3+0x3c>
  801cc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc6:	31 d2                	xor    %edx,%edx
  801cc8:	f7 f7                	div    %edi
  801cca:	89 c5                	mov    %eax,%ebp
  801ccc:	89 c8                	mov    %ecx,%eax
  801cce:	31 d2                	xor    %edx,%edx
  801cd0:	f7 f5                	div    %ebp
  801cd2:	89 c1                	mov    %eax,%ecx
  801cd4:	89 d8                	mov    %ebx,%eax
  801cd6:	89 cf                	mov    %ecx,%edi
  801cd8:	f7 f5                	div    %ebp
  801cda:	89 c3                	mov    %eax,%ebx
  801cdc:	89 d8                	mov    %ebx,%eax
  801cde:	89 fa                	mov    %edi,%edx
  801ce0:	83 c4 1c             	add    $0x1c,%esp
  801ce3:	5b                   	pop    %ebx
  801ce4:	5e                   	pop    %esi
  801ce5:	5f                   	pop    %edi
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    
  801ce8:	90                   	nop
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	39 ce                	cmp    %ecx,%esi
  801cf2:	77 74                	ja     801d68 <__udivdi3+0xd8>
  801cf4:	0f bd fe             	bsr    %esi,%edi
  801cf7:	83 f7 1f             	xor    $0x1f,%edi
  801cfa:	0f 84 98 00 00 00    	je     801d98 <__udivdi3+0x108>
  801d00:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d05:	89 f9                	mov    %edi,%ecx
  801d07:	89 c5                	mov    %eax,%ebp
  801d09:	29 fb                	sub    %edi,%ebx
  801d0b:	d3 e6                	shl    %cl,%esi
  801d0d:	89 d9                	mov    %ebx,%ecx
  801d0f:	d3 ed                	shr    %cl,%ebp
  801d11:	89 f9                	mov    %edi,%ecx
  801d13:	d3 e0                	shl    %cl,%eax
  801d15:	09 ee                	or     %ebp,%esi
  801d17:	89 d9                	mov    %ebx,%ecx
  801d19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d1d:	89 d5                	mov    %edx,%ebp
  801d1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d23:	d3 ed                	shr    %cl,%ebp
  801d25:	89 f9                	mov    %edi,%ecx
  801d27:	d3 e2                	shl    %cl,%edx
  801d29:	89 d9                	mov    %ebx,%ecx
  801d2b:	d3 e8                	shr    %cl,%eax
  801d2d:	09 c2                	or     %eax,%edx
  801d2f:	89 d0                	mov    %edx,%eax
  801d31:	89 ea                	mov    %ebp,%edx
  801d33:	f7 f6                	div    %esi
  801d35:	89 d5                	mov    %edx,%ebp
  801d37:	89 c3                	mov    %eax,%ebx
  801d39:	f7 64 24 0c          	mull   0xc(%esp)
  801d3d:	39 d5                	cmp    %edx,%ebp
  801d3f:	72 10                	jb     801d51 <__udivdi3+0xc1>
  801d41:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d45:	89 f9                	mov    %edi,%ecx
  801d47:	d3 e6                	shl    %cl,%esi
  801d49:	39 c6                	cmp    %eax,%esi
  801d4b:	73 07                	jae    801d54 <__udivdi3+0xc4>
  801d4d:	39 d5                	cmp    %edx,%ebp
  801d4f:	75 03                	jne    801d54 <__udivdi3+0xc4>
  801d51:	83 eb 01             	sub    $0x1,%ebx
  801d54:	31 ff                	xor    %edi,%edi
  801d56:	89 d8                	mov    %ebx,%eax
  801d58:	89 fa                	mov    %edi,%edx
  801d5a:	83 c4 1c             	add    $0x1c,%esp
  801d5d:	5b                   	pop    %ebx
  801d5e:	5e                   	pop    %esi
  801d5f:	5f                   	pop    %edi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    
  801d62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d68:	31 ff                	xor    %edi,%edi
  801d6a:	31 db                	xor    %ebx,%ebx
  801d6c:	89 d8                	mov    %ebx,%eax
  801d6e:	89 fa                	mov    %edi,%edx
  801d70:	83 c4 1c             	add    $0x1c,%esp
  801d73:	5b                   	pop    %ebx
  801d74:	5e                   	pop    %esi
  801d75:	5f                   	pop    %edi
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    
  801d78:	90                   	nop
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	89 d8                	mov    %ebx,%eax
  801d82:	f7 f7                	div    %edi
  801d84:	31 ff                	xor    %edi,%edi
  801d86:	89 c3                	mov    %eax,%ebx
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	89 fa                	mov    %edi,%edx
  801d8c:	83 c4 1c             	add    $0x1c,%esp
  801d8f:	5b                   	pop    %ebx
  801d90:	5e                   	pop    %esi
  801d91:	5f                   	pop    %edi
  801d92:	5d                   	pop    %ebp
  801d93:	c3                   	ret    
  801d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d98:	39 ce                	cmp    %ecx,%esi
  801d9a:	72 0c                	jb     801da8 <__udivdi3+0x118>
  801d9c:	31 db                	xor    %ebx,%ebx
  801d9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801da2:	0f 87 34 ff ff ff    	ja     801cdc <__udivdi3+0x4c>
  801da8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801dad:	e9 2a ff ff ff       	jmp    801cdc <__udivdi3+0x4c>
  801db2:	66 90                	xchg   %ax,%ax
  801db4:	66 90                	xchg   %ax,%ax
  801db6:	66 90                	xchg   %ax,%ax
  801db8:	66 90                	xchg   %ax,%ax
  801dba:	66 90                	xchg   %ax,%ax
  801dbc:	66 90                	xchg   %ax,%ax
  801dbe:	66 90                	xchg   %ax,%ax

00801dc0 <__umoddi3>:
  801dc0:	55                   	push   %ebp
  801dc1:	57                   	push   %edi
  801dc2:	56                   	push   %esi
  801dc3:	53                   	push   %ebx
  801dc4:	83 ec 1c             	sub    $0x1c,%esp
  801dc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801dcb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801dcf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dd7:	85 d2                	test   %edx,%edx
  801dd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ddd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801de1:	89 f3                	mov    %esi,%ebx
  801de3:	89 3c 24             	mov    %edi,(%esp)
  801de6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dea:	75 1c                	jne    801e08 <__umoddi3+0x48>
  801dec:	39 f7                	cmp    %esi,%edi
  801dee:	76 50                	jbe    801e40 <__umoddi3+0x80>
  801df0:	89 c8                	mov    %ecx,%eax
  801df2:	89 f2                	mov    %esi,%edx
  801df4:	f7 f7                	div    %edi
  801df6:	89 d0                	mov    %edx,%eax
  801df8:	31 d2                	xor    %edx,%edx
  801dfa:	83 c4 1c             	add    $0x1c,%esp
  801dfd:	5b                   	pop    %ebx
  801dfe:	5e                   	pop    %esi
  801dff:	5f                   	pop    %edi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    
  801e02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e08:	39 f2                	cmp    %esi,%edx
  801e0a:	89 d0                	mov    %edx,%eax
  801e0c:	77 52                	ja     801e60 <__umoddi3+0xa0>
  801e0e:	0f bd ea             	bsr    %edx,%ebp
  801e11:	83 f5 1f             	xor    $0x1f,%ebp
  801e14:	75 5a                	jne    801e70 <__umoddi3+0xb0>
  801e16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e1a:	0f 82 e0 00 00 00    	jb     801f00 <__umoddi3+0x140>
  801e20:	39 0c 24             	cmp    %ecx,(%esp)
  801e23:	0f 86 d7 00 00 00    	jbe    801f00 <__umoddi3+0x140>
  801e29:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e31:	83 c4 1c             	add    $0x1c,%esp
  801e34:	5b                   	pop    %ebx
  801e35:	5e                   	pop    %esi
  801e36:	5f                   	pop    %edi
  801e37:	5d                   	pop    %ebp
  801e38:	c3                   	ret    
  801e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e40:	85 ff                	test   %edi,%edi
  801e42:	89 fd                	mov    %edi,%ebp
  801e44:	75 0b                	jne    801e51 <__umoddi3+0x91>
  801e46:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4b:	31 d2                	xor    %edx,%edx
  801e4d:	f7 f7                	div    %edi
  801e4f:	89 c5                	mov    %eax,%ebp
  801e51:	89 f0                	mov    %esi,%eax
  801e53:	31 d2                	xor    %edx,%edx
  801e55:	f7 f5                	div    %ebp
  801e57:	89 c8                	mov    %ecx,%eax
  801e59:	f7 f5                	div    %ebp
  801e5b:	89 d0                	mov    %edx,%eax
  801e5d:	eb 99                	jmp    801df8 <__umoddi3+0x38>
  801e5f:	90                   	nop
  801e60:	89 c8                	mov    %ecx,%eax
  801e62:	89 f2                	mov    %esi,%edx
  801e64:	83 c4 1c             	add    $0x1c,%esp
  801e67:	5b                   	pop    %ebx
  801e68:	5e                   	pop    %esi
  801e69:	5f                   	pop    %edi
  801e6a:	5d                   	pop    %ebp
  801e6b:	c3                   	ret    
  801e6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e70:	8b 34 24             	mov    (%esp),%esi
  801e73:	bf 20 00 00 00       	mov    $0x20,%edi
  801e78:	89 e9                	mov    %ebp,%ecx
  801e7a:	29 ef                	sub    %ebp,%edi
  801e7c:	d3 e0                	shl    %cl,%eax
  801e7e:	89 f9                	mov    %edi,%ecx
  801e80:	89 f2                	mov    %esi,%edx
  801e82:	d3 ea                	shr    %cl,%edx
  801e84:	89 e9                	mov    %ebp,%ecx
  801e86:	09 c2                	or     %eax,%edx
  801e88:	89 d8                	mov    %ebx,%eax
  801e8a:	89 14 24             	mov    %edx,(%esp)
  801e8d:	89 f2                	mov    %esi,%edx
  801e8f:	d3 e2                	shl    %cl,%edx
  801e91:	89 f9                	mov    %edi,%ecx
  801e93:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e9b:	d3 e8                	shr    %cl,%eax
  801e9d:	89 e9                	mov    %ebp,%ecx
  801e9f:	89 c6                	mov    %eax,%esi
  801ea1:	d3 e3                	shl    %cl,%ebx
  801ea3:	89 f9                	mov    %edi,%ecx
  801ea5:	89 d0                	mov    %edx,%eax
  801ea7:	d3 e8                	shr    %cl,%eax
  801ea9:	89 e9                	mov    %ebp,%ecx
  801eab:	09 d8                	or     %ebx,%eax
  801ead:	89 d3                	mov    %edx,%ebx
  801eaf:	89 f2                	mov    %esi,%edx
  801eb1:	f7 34 24             	divl   (%esp)
  801eb4:	89 d6                	mov    %edx,%esi
  801eb6:	d3 e3                	shl    %cl,%ebx
  801eb8:	f7 64 24 04          	mull   0x4(%esp)
  801ebc:	39 d6                	cmp    %edx,%esi
  801ebe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ec2:	89 d1                	mov    %edx,%ecx
  801ec4:	89 c3                	mov    %eax,%ebx
  801ec6:	72 08                	jb     801ed0 <__umoddi3+0x110>
  801ec8:	75 11                	jne    801edb <__umoddi3+0x11b>
  801eca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801ece:	73 0b                	jae    801edb <__umoddi3+0x11b>
  801ed0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ed4:	1b 14 24             	sbb    (%esp),%edx
  801ed7:	89 d1                	mov    %edx,%ecx
  801ed9:	89 c3                	mov    %eax,%ebx
  801edb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801edf:	29 da                	sub    %ebx,%edx
  801ee1:	19 ce                	sbb    %ecx,%esi
  801ee3:	89 f9                	mov    %edi,%ecx
  801ee5:	89 f0                	mov    %esi,%eax
  801ee7:	d3 e0                	shl    %cl,%eax
  801ee9:	89 e9                	mov    %ebp,%ecx
  801eeb:	d3 ea                	shr    %cl,%edx
  801eed:	89 e9                	mov    %ebp,%ecx
  801eef:	d3 ee                	shr    %cl,%esi
  801ef1:	09 d0                	or     %edx,%eax
  801ef3:	89 f2                	mov    %esi,%edx
  801ef5:	83 c4 1c             	add    $0x1c,%esp
  801ef8:	5b                   	pop    %ebx
  801ef9:	5e                   	pop    %esi
  801efa:	5f                   	pop    %edi
  801efb:	5d                   	pop    %ebp
  801efc:	c3                   	ret    
  801efd:	8d 76 00             	lea    0x0(%esi),%esi
  801f00:	29 f9                	sub    %edi,%ecx
  801f02:	19 d6                	sbb    %edx,%esi
  801f04:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f0c:	e9 18 ff ff ff       	jmp    801e29 <__umoddi3+0x69>
