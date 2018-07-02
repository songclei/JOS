
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 40 1f 80 00       	push   $0x801f40
  80003e:	e8 0e 01 00 00       	call   800151 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 08 40 80 00       	mov    0x804008,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 4e 1f 80 00       	push   $0x801f4e
  800054:	e8 f8 00 00 00       	call   800151 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800069:	e8 53 0b 00 00       	call   800bc1 <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 0c 0f 00 00       	call   800fbb <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 c7 0a 00 00       	call   800b80 <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c8:	8b 13                	mov    (%ebx),%edx
  8000ca:	8d 42 01             	lea    0x1(%edx),%eax
  8000cd:	89 03                	mov    %eax,(%ebx)
  8000cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	75 1a                	jne    8000f7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000dd:	83 ec 08             	sub    $0x8,%esp
  8000e0:	68 ff 00 00 00       	push   $0xff
  8000e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e8:	50                   	push   %eax
  8000e9:	e8 55 0a 00 00       	call   800b43 <sys_cputs>
		b->idx = 0;
  8000ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fe:	c9                   	leave  
  8000ff:	c3                   	ret    

00800100 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800109:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800110:	00 00 00 
	b.cnt = 0;
  800113:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011d:	ff 75 0c             	pushl  0xc(%ebp)
  800120:	ff 75 08             	pushl  0x8(%ebp)
  800123:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800129:	50                   	push   %eax
  80012a:	68 be 00 80 00       	push   $0x8000be
  80012f:	e8 54 01 00 00       	call   800288 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800134:	83 c4 08             	add    $0x8,%esp
  800137:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 fa 09 00 00       	call   800b43 <sys_cputs>

	return b.cnt;
}
  800149:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800157:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015a:	50                   	push   %eax
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	e8 9d ff ff ff       	call   800100 <vcprintf>
	va_end(ap);

	return cnt;
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
  80016b:	83 ec 1c             	sub    $0x1c,%esp
  80016e:	89 c7                	mov    %eax,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	8b 55 0c             	mov    0xc(%ebp),%edx
  800178:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800181:	bb 00 00 00 00       	mov    $0x0,%ebx
  800186:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800189:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018c:	39 d3                	cmp    %edx,%ebx
  80018e:	72 05                	jb     800195 <printnum+0x30>
  800190:	39 45 10             	cmp    %eax,0x10(%ebp)
  800193:	77 45                	ja     8001da <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	ff 75 18             	pushl  0x18(%ebp)
  80019b:	8b 45 14             	mov    0x14(%ebp),%eax
  80019e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a1:	53                   	push   %ebx
  8001a2:	ff 75 10             	pushl  0x10(%ebp)
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b4:	e8 e7 1a 00 00       	call   801ca0 <__udivdi3>
  8001b9:	83 c4 18             	add    $0x18,%esp
  8001bc:	52                   	push   %edx
  8001bd:	50                   	push   %eax
  8001be:	89 f2                	mov    %esi,%edx
  8001c0:	89 f8                	mov    %edi,%eax
  8001c2:	e8 9e ff ff ff       	call   800165 <printnum>
  8001c7:	83 c4 20             	add    $0x20,%esp
  8001ca:	eb 18                	jmp    8001e4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	ff 75 18             	pushl  0x18(%ebp)
  8001d3:	ff d7                	call   *%edi
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	eb 03                	jmp    8001dd <printnum+0x78>
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001dd:	83 eb 01             	sub    $0x1,%ebx
  8001e0:	85 db                	test   %ebx,%ebx
  8001e2:	7f e8                	jg     8001cc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	56                   	push   %esi
  8001e8:	83 ec 04             	sub    $0x4,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 d4 1b 00 00       	call   801dd0 <__umoddi3>
  8001fc:	83 c4 14             	add    $0x14,%esp
  8001ff:	0f be 80 6f 1f 80 00 	movsbl 0x801f6f(%eax),%eax
  800206:	50                   	push   %eax
  800207:	ff d7                	call   *%edi
}
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800217:	83 fa 01             	cmp    $0x1,%edx
  80021a:	7e 0e                	jle    80022a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80021c:	8b 10                	mov    (%eax),%edx
  80021e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800221:	89 08                	mov    %ecx,(%eax)
  800223:	8b 02                	mov    (%edx),%eax
  800225:	8b 52 04             	mov    0x4(%edx),%edx
  800228:	eb 22                	jmp    80024c <getuint+0x38>
	else if (lflag)
  80022a:	85 d2                	test   %edx,%edx
  80022c:	74 10                	je     80023e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80022e:	8b 10                	mov    (%eax),%edx
  800230:	8d 4a 04             	lea    0x4(%edx),%ecx
  800233:	89 08                	mov    %ecx,(%eax)
  800235:	8b 02                	mov    (%edx),%eax
  800237:	ba 00 00 00 00       	mov    $0x0,%edx
  80023c:	eb 0e                	jmp    80024c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80023e:	8b 10                	mov    (%eax),%edx
  800240:	8d 4a 04             	lea    0x4(%edx),%ecx
  800243:	89 08                	mov    %ecx,(%eax)
  800245:	8b 02                	mov    (%edx),%eax
  800247:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800254:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	3b 50 04             	cmp    0x4(%eax),%edx
  80025d:	73 0a                	jae    800269 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800262:	89 08                	mov    %ecx,(%eax)
  800264:	8b 45 08             	mov    0x8(%ebp),%eax
  800267:	88 02                	mov    %al,(%edx)
}
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800271:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800274:	50                   	push   %eax
  800275:	ff 75 10             	pushl  0x10(%ebp)
  800278:	ff 75 0c             	pushl  0xc(%ebp)
  80027b:	ff 75 08             	pushl  0x8(%ebp)
  80027e:	e8 05 00 00 00       	call   800288 <vprintfmt>
	va_end(ap);
}
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	57                   	push   %edi
  80028c:	56                   	push   %esi
  80028d:	53                   	push   %ebx
  80028e:	83 ec 2c             	sub    $0x2c,%esp
  800291:	8b 75 08             	mov    0x8(%ebp),%esi
  800294:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800297:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029a:	eb 12                	jmp    8002ae <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80029c:	85 c0                	test   %eax,%eax
  80029e:	0f 84 38 04 00 00    	je     8006dc <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	53                   	push   %ebx
  8002a8:	50                   	push   %eax
  8002a9:	ff d6                	call   *%esi
  8002ab:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ae:	83 c7 01             	add    $0x1,%edi
  8002b1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b5:	83 f8 25             	cmp    $0x25,%eax
  8002b8:	75 e2                	jne    80029c <vprintfmt+0x14>
  8002ba:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002be:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002cc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d8:	eb 07                	jmp    8002e1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8002dd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e1:	8d 47 01             	lea    0x1(%edi),%eax
  8002e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e7:	0f b6 07             	movzbl (%edi),%eax
  8002ea:	0f b6 c8             	movzbl %al,%ecx
  8002ed:	83 e8 23             	sub    $0x23,%eax
  8002f0:	3c 55                	cmp    $0x55,%al
  8002f2:	0f 87 c9 03 00 00    	ja     8006c1 <vprintfmt+0x439>
  8002f8:	0f b6 c0             	movzbl %al,%eax
  8002fb:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  800302:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800305:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800309:	eb d6                	jmp    8002e1 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  80030b:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  800312:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800315:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  800318:	eb 94                	jmp    8002ae <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  80031a:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  800321:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  800327:	eb 85                	jmp    8002ae <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  800329:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  800330:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800333:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  800336:	e9 73 ff ff ff       	jmp    8002ae <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  80033b:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  800342:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  800348:	e9 61 ff ff ff       	jmp    8002ae <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  80034d:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800354:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  80035a:	e9 4f ff ff ff       	jmp    8002ae <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80035f:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800366:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80036c:	e9 3d ff ff ff       	jmp    8002ae <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  800371:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  800378:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80037e:	e9 2b ff ff ff       	jmp    8002ae <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  800383:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  80038a:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  800390:	e9 19 ff ff ff       	jmp    8002ae <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800395:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  80039c:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8003a2:	e9 07 ff ff ff       	jmp    8002ae <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8003a7:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  8003ae:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8003b4:	e9 f5 fe ff ff       	jmp    8002ae <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003cb:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003ce:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d1:	83 fa 09             	cmp    $0x9,%edx
  8003d4:	77 3f                	ja     800415 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d9:	eb e9                	jmp    8003c4 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e4:	8b 00                	mov    (%eax),%eax
  8003e6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ec:	eb 2d                	jmp    80041b <vprintfmt+0x193>
  8003ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f1:	85 c0                	test   %eax,%eax
  8003f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f8:	0f 49 c8             	cmovns %eax,%ecx
  8003fb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800401:	e9 db fe ff ff       	jmp    8002e1 <vprintfmt+0x59>
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800409:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800410:	e9 cc fe ff ff       	jmp    8002e1 <vprintfmt+0x59>
  800415:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800418:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80041b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041f:	0f 89 bc fe ff ff    	jns    8002e1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800425:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800428:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800432:	e9 aa fe ff ff       	jmp    8002e1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800437:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043d:	e9 9f fe ff ff       	jmp    8002e1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 50 04             	lea    0x4(%eax),%edx
  800448:	89 55 14             	mov    %edx,0x14(%ebp)
  80044b:	83 ec 08             	sub    $0x8,%esp
  80044e:	53                   	push   %ebx
  80044f:	ff 30                	pushl  (%eax)
  800451:	ff d6                	call   *%esi
			break;
  800453:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800459:	e9 50 fe ff ff       	jmp    8002ae <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 50 04             	lea    0x4(%eax),%edx
  800464:	89 55 14             	mov    %edx,0x14(%ebp)
  800467:	8b 00                	mov    (%eax),%eax
  800469:	99                   	cltd   
  80046a:	31 d0                	xor    %edx,%eax
  80046c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046e:	83 f8 0f             	cmp    $0xf,%eax
  800471:	7f 0b                	jg     80047e <vprintfmt+0x1f6>
  800473:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  80047a:	85 d2                	test   %edx,%edx
  80047c:	75 18                	jne    800496 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80047e:	50                   	push   %eax
  80047f:	68 87 1f 80 00       	push   $0x801f87
  800484:	53                   	push   %ebx
  800485:	56                   	push   %esi
  800486:	e8 e0 fd ff ff       	call   80026b <printfmt>
  80048b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800491:	e9 18 fe ff ff       	jmp    8002ae <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800496:	52                   	push   %edx
  800497:	68 51 23 80 00       	push   $0x802351
  80049c:	53                   	push   %ebx
  80049d:	56                   	push   %esi
  80049e:	e8 c8 fd ff ff       	call   80026b <printfmt>
  8004a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a9:	e9 00 fe ff ff       	jmp    8002ae <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8d 50 04             	lea    0x4(%eax),%edx
  8004b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b9:	85 ff                	test   %edi,%edi
  8004bb:	b8 80 1f 80 00       	mov    $0x801f80,%eax
  8004c0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c7:	0f 8e 94 00 00 00    	jle    800561 <vprintfmt+0x2d9>
  8004cd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d1:	0f 84 98 00 00 00    	je     80056f <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	ff 75 d0             	pushl  -0x30(%ebp)
  8004dd:	57                   	push   %edi
  8004de:	e8 81 02 00 00       	call   800764 <strnlen>
  8004e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e6:	29 c1                	sub    %eax,%ecx
  8004e8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004eb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ee:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fa:	eb 0f                	jmp    80050b <vprintfmt+0x283>
					putch(padc, putdat);
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	53                   	push   %ebx
  800500:	ff 75 e0             	pushl  -0x20(%ebp)
  800503:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800505:	83 ef 01             	sub    $0x1,%edi
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	85 ff                	test   %edi,%edi
  80050d:	7f ed                	jg     8004fc <vprintfmt+0x274>
  80050f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800512:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800515:	85 c9                	test   %ecx,%ecx
  800517:	b8 00 00 00 00       	mov    $0x0,%eax
  80051c:	0f 49 c1             	cmovns %ecx,%eax
  80051f:	29 c1                	sub    %eax,%ecx
  800521:	89 75 08             	mov    %esi,0x8(%ebp)
  800524:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800527:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052a:	89 cb                	mov    %ecx,%ebx
  80052c:	eb 4d                	jmp    80057b <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800532:	74 1b                	je     80054f <vprintfmt+0x2c7>
  800534:	0f be c0             	movsbl %al,%eax
  800537:	83 e8 20             	sub    $0x20,%eax
  80053a:	83 f8 5e             	cmp    $0x5e,%eax
  80053d:	76 10                	jbe    80054f <vprintfmt+0x2c7>
					putch('?', putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	ff 75 0c             	pushl  0xc(%ebp)
  800545:	6a 3f                	push   $0x3f
  800547:	ff 55 08             	call   *0x8(%ebp)
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	eb 0d                	jmp    80055c <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	ff 75 0c             	pushl  0xc(%ebp)
  800555:	52                   	push   %edx
  800556:	ff 55 08             	call   *0x8(%ebp)
  800559:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055c:	83 eb 01             	sub    $0x1,%ebx
  80055f:	eb 1a                	jmp    80057b <vprintfmt+0x2f3>
  800561:	89 75 08             	mov    %esi,0x8(%ebp)
  800564:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800567:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056d:	eb 0c                	jmp    80057b <vprintfmt+0x2f3>
  80056f:	89 75 08             	mov    %esi,0x8(%ebp)
  800572:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800575:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800578:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057b:	83 c7 01             	add    $0x1,%edi
  80057e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800582:	0f be d0             	movsbl %al,%edx
  800585:	85 d2                	test   %edx,%edx
  800587:	74 23                	je     8005ac <vprintfmt+0x324>
  800589:	85 f6                	test   %esi,%esi
  80058b:	78 a1                	js     80052e <vprintfmt+0x2a6>
  80058d:	83 ee 01             	sub    $0x1,%esi
  800590:	79 9c                	jns    80052e <vprintfmt+0x2a6>
  800592:	89 df                	mov    %ebx,%edi
  800594:	8b 75 08             	mov    0x8(%ebp),%esi
  800597:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059a:	eb 18                	jmp    8005b4 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059c:	83 ec 08             	sub    $0x8,%esp
  80059f:	53                   	push   %ebx
  8005a0:	6a 20                	push   $0x20
  8005a2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a4:	83 ef 01             	sub    $0x1,%edi
  8005a7:	83 c4 10             	add    $0x10,%esp
  8005aa:	eb 08                	jmp    8005b4 <vprintfmt+0x32c>
  8005ac:	89 df                	mov    %ebx,%edi
  8005ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b4:	85 ff                	test   %edi,%edi
  8005b6:	7f e4                	jg     80059c <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bb:	e9 ee fc ff ff       	jmp    8002ae <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c0:	83 fa 01             	cmp    $0x1,%edx
  8005c3:	7e 16                	jle    8005db <vprintfmt+0x353>
		return va_arg(*ap, long long);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 50 08             	lea    0x8(%eax),%edx
  8005cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ce:	8b 50 04             	mov    0x4(%eax),%edx
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d9:	eb 32                	jmp    80060d <vprintfmt+0x385>
	else if (lflag)
  8005db:	85 d2                	test   %edx,%edx
  8005dd:	74 18                	je     8005f7 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 50 04             	lea    0x4(%eax),%edx
  8005e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e8:	8b 00                	mov    (%eax),%eax
  8005ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ed:	89 c1                	mov    %eax,%ecx
  8005ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f5:	eb 16                	jmp    80060d <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 50 04             	lea    0x4(%eax),%edx
  8005fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800600:	8b 00                	mov    (%eax),%eax
  800602:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800605:	89 c1                	mov    %eax,%ecx
  800607:	c1 f9 1f             	sar    $0x1f,%ecx
  80060a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800610:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800613:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800618:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061c:	79 6f                	jns    80068d <vprintfmt+0x405>
				putch('-', putdat);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	53                   	push   %ebx
  800622:	6a 2d                	push   $0x2d
  800624:	ff d6                	call   *%esi
				num = -(long long) num;
  800626:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800629:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80062c:	f7 d8                	neg    %eax
  80062e:	83 d2 00             	adc    $0x0,%edx
  800631:	f7 da                	neg    %edx
  800633:	83 c4 10             	add    $0x10,%esp
  800636:	eb 55                	jmp    80068d <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800638:	8d 45 14             	lea    0x14(%ebp),%eax
  80063b:	e8 d4 fb ff ff       	call   800214 <getuint>
			base = 10;
  800640:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800645:	eb 46                	jmp    80068d <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800647:	8d 45 14             	lea    0x14(%ebp),%eax
  80064a:	e8 c5 fb ff ff       	call   800214 <getuint>
			base = 8;
  80064f:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800654:	eb 37                	jmp    80068d <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	53                   	push   %ebx
  80065a:	6a 30                	push   $0x30
  80065c:	ff d6                	call   *%esi
			putch('x', putdat);
  80065e:	83 c4 08             	add    $0x8,%esp
  800661:	53                   	push   %ebx
  800662:	6a 78                	push   $0x78
  800664:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800676:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800679:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80067e:	eb 0d                	jmp    80068d <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800680:	8d 45 14             	lea    0x14(%ebp),%eax
  800683:	e8 8c fb ff ff       	call   800214 <getuint>
			base = 16;
  800688:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80068d:	83 ec 0c             	sub    $0xc,%esp
  800690:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800694:	51                   	push   %ecx
  800695:	ff 75 e0             	pushl  -0x20(%ebp)
  800698:	57                   	push   %edi
  800699:	52                   	push   %edx
  80069a:	50                   	push   %eax
  80069b:	89 da                	mov    %ebx,%edx
  80069d:	89 f0                	mov    %esi,%eax
  80069f:	e8 c1 fa ff ff       	call   800165 <printnum>
			break;
  8006a4:	83 c4 20             	add    $0x20,%esp
  8006a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006aa:	e9 ff fb ff ff       	jmp    8002ae <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	51                   	push   %ecx
  8006b4:	ff d6                	call   *%esi
			break;
  8006b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006bc:	e9 ed fb ff ff       	jmp    8002ae <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	53                   	push   %ebx
  8006c5:	6a 25                	push   $0x25
  8006c7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	eb 03                	jmp    8006d1 <vprintfmt+0x449>
  8006ce:	83 ef 01             	sub    $0x1,%edi
  8006d1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d5:	75 f7                	jne    8006ce <vprintfmt+0x446>
  8006d7:	e9 d2 fb ff ff       	jmp    8002ae <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006df:	5b                   	pop    %ebx
  8006e0:	5e                   	pop    %esi
  8006e1:	5f                   	pop    %edi
  8006e2:	5d                   	pop    %ebp
  8006e3:	c3                   	ret    

008006e4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	83 ec 18             	sub    $0x18,%esp
  8006ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800701:	85 c0                	test   %eax,%eax
  800703:	74 26                	je     80072b <vsnprintf+0x47>
  800705:	85 d2                	test   %edx,%edx
  800707:	7e 22                	jle    80072b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800709:	ff 75 14             	pushl  0x14(%ebp)
  80070c:	ff 75 10             	pushl  0x10(%ebp)
  80070f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	68 4e 02 80 00       	push   $0x80024e
  800718:	e8 6b fb ff ff       	call   800288 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800720:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800723:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800726:	83 c4 10             	add    $0x10,%esp
  800729:	eb 05                	jmp    800730 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80072b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800730:	c9                   	leave  
  800731:	c3                   	ret    

00800732 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073b:	50                   	push   %eax
  80073c:	ff 75 10             	pushl  0x10(%ebp)
  80073f:	ff 75 0c             	pushl  0xc(%ebp)
  800742:	ff 75 08             	pushl  0x8(%ebp)
  800745:	e8 9a ff ff ff       	call   8006e4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800752:	b8 00 00 00 00       	mov    $0x0,%eax
  800757:	eb 03                	jmp    80075c <strlen+0x10>
		n++;
  800759:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800760:	75 f7                	jne    800759 <strlen+0xd>
		n++;
	return n;
}
  800762:	5d                   	pop    %ebp
  800763:	c3                   	ret    

00800764 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076d:	ba 00 00 00 00       	mov    $0x0,%edx
  800772:	eb 03                	jmp    800777 <strnlen+0x13>
		n++;
  800774:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800777:	39 c2                	cmp    %eax,%edx
  800779:	74 08                	je     800783 <strnlen+0x1f>
  80077b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80077f:	75 f3                	jne    800774 <strnlen+0x10>
  800781:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	53                   	push   %ebx
  800789:	8b 45 08             	mov    0x8(%ebp),%eax
  80078c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078f:	89 c2                	mov    %eax,%edx
  800791:	83 c2 01             	add    $0x1,%edx
  800794:	83 c1 01             	add    $0x1,%ecx
  800797:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80079b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80079e:	84 db                	test   %bl,%bl
  8007a0:	75 ef                	jne    800791 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a2:	5b                   	pop    %ebx
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	53                   	push   %ebx
  8007a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ac:	53                   	push   %ebx
  8007ad:	e8 9a ff ff ff       	call   80074c <strlen>
  8007b2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b5:	ff 75 0c             	pushl  0xc(%ebp)
  8007b8:	01 d8                	add    %ebx,%eax
  8007ba:	50                   	push   %eax
  8007bb:	e8 c5 ff ff ff       	call   800785 <strcpy>
	return dst;
}
  8007c0:	89 d8                	mov    %ebx,%eax
  8007c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	56                   	push   %esi
  8007cb:	53                   	push   %ebx
  8007cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d2:	89 f3                	mov    %esi,%ebx
  8007d4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d7:	89 f2                	mov    %esi,%edx
  8007d9:	eb 0f                	jmp    8007ea <strncpy+0x23>
		*dst++ = *src;
  8007db:	83 c2 01             	add    $0x1,%edx
  8007de:	0f b6 01             	movzbl (%ecx),%eax
  8007e1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e4:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ea:	39 da                	cmp    %ebx,%edx
  8007ec:	75 ed                	jne    8007db <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ee:	89 f0                	mov    %esi,%eax
  8007f0:	5b                   	pop    %ebx
  8007f1:	5e                   	pop    %esi
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	56                   	push   %esi
  8007f8:	53                   	push   %ebx
  8007f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ff:	8b 55 10             	mov    0x10(%ebp),%edx
  800802:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800804:	85 d2                	test   %edx,%edx
  800806:	74 21                	je     800829 <strlcpy+0x35>
  800808:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080c:	89 f2                	mov    %esi,%edx
  80080e:	eb 09                	jmp    800819 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800810:	83 c2 01             	add    $0x1,%edx
  800813:	83 c1 01             	add    $0x1,%ecx
  800816:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800819:	39 c2                	cmp    %eax,%edx
  80081b:	74 09                	je     800826 <strlcpy+0x32>
  80081d:	0f b6 19             	movzbl (%ecx),%ebx
  800820:	84 db                	test   %bl,%bl
  800822:	75 ec                	jne    800810 <strlcpy+0x1c>
  800824:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800826:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800829:	29 f0                	sub    %esi,%eax
}
  80082b:	5b                   	pop    %ebx
  80082c:	5e                   	pop    %esi
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800835:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800838:	eb 06                	jmp    800840 <strcmp+0x11>
		p++, q++;
  80083a:	83 c1 01             	add    $0x1,%ecx
  80083d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800840:	0f b6 01             	movzbl (%ecx),%eax
  800843:	84 c0                	test   %al,%al
  800845:	74 04                	je     80084b <strcmp+0x1c>
  800847:	3a 02                	cmp    (%edx),%al
  800849:	74 ef                	je     80083a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80084b:	0f b6 c0             	movzbl %al,%eax
  80084e:	0f b6 12             	movzbl (%edx),%edx
  800851:	29 d0                	sub    %edx,%eax
}
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	53                   	push   %ebx
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085f:	89 c3                	mov    %eax,%ebx
  800861:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800864:	eb 06                	jmp    80086c <strncmp+0x17>
		n--, p++, q++;
  800866:	83 c0 01             	add    $0x1,%eax
  800869:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80086c:	39 d8                	cmp    %ebx,%eax
  80086e:	74 15                	je     800885 <strncmp+0x30>
  800870:	0f b6 08             	movzbl (%eax),%ecx
  800873:	84 c9                	test   %cl,%cl
  800875:	74 04                	je     80087b <strncmp+0x26>
  800877:	3a 0a                	cmp    (%edx),%cl
  800879:	74 eb                	je     800866 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087b:	0f b6 00             	movzbl (%eax),%eax
  80087e:	0f b6 12             	movzbl (%edx),%edx
  800881:	29 d0                	sub    %edx,%eax
  800883:	eb 05                	jmp    80088a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800885:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80088a:	5b                   	pop    %ebx
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800897:	eb 07                	jmp    8008a0 <strchr+0x13>
		if (*s == c)
  800899:	38 ca                	cmp    %cl,%dl
  80089b:	74 0f                	je     8008ac <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80089d:	83 c0 01             	add    $0x1,%eax
  8008a0:	0f b6 10             	movzbl (%eax),%edx
  8008a3:	84 d2                	test   %dl,%dl
  8008a5:	75 f2                	jne    800899 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b8:	eb 03                	jmp    8008bd <strfind+0xf>
  8008ba:	83 c0 01             	add    $0x1,%eax
  8008bd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c0:	38 ca                	cmp    %cl,%dl
  8008c2:	74 04                	je     8008c8 <strfind+0x1a>
  8008c4:	84 d2                	test   %dl,%dl
  8008c6:	75 f2                	jne    8008ba <strfind+0xc>
			break;
	return (char *) s;
}
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	57                   	push   %edi
  8008ce:	56                   	push   %esi
  8008cf:	53                   	push   %ebx
  8008d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d6:	85 c9                	test   %ecx,%ecx
  8008d8:	74 36                	je     800910 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008da:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e0:	75 28                	jne    80090a <memset+0x40>
  8008e2:	f6 c1 03             	test   $0x3,%cl
  8008e5:	75 23                	jne    80090a <memset+0x40>
		c &= 0xFF;
  8008e7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008eb:	89 d3                	mov    %edx,%ebx
  8008ed:	c1 e3 08             	shl    $0x8,%ebx
  8008f0:	89 d6                	mov    %edx,%esi
  8008f2:	c1 e6 18             	shl    $0x18,%esi
  8008f5:	89 d0                	mov    %edx,%eax
  8008f7:	c1 e0 10             	shl    $0x10,%eax
  8008fa:	09 f0                	or     %esi,%eax
  8008fc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008fe:	89 d8                	mov    %ebx,%eax
  800900:	09 d0                	or     %edx,%eax
  800902:	c1 e9 02             	shr    $0x2,%ecx
  800905:	fc                   	cld    
  800906:	f3 ab                	rep stos %eax,%es:(%edi)
  800908:	eb 06                	jmp    800910 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090d:	fc                   	cld    
  80090e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800910:	89 f8                	mov    %edi,%eax
  800912:	5b                   	pop    %ebx
  800913:	5e                   	pop    %esi
  800914:	5f                   	pop    %edi
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	57                   	push   %edi
  80091b:	56                   	push   %esi
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800922:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800925:	39 c6                	cmp    %eax,%esi
  800927:	73 35                	jae    80095e <memmove+0x47>
  800929:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092c:	39 d0                	cmp    %edx,%eax
  80092e:	73 2e                	jae    80095e <memmove+0x47>
		s += n;
		d += n;
  800930:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800933:	89 d6                	mov    %edx,%esi
  800935:	09 fe                	or     %edi,%esi
  800937:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093d:	75 13                	jne    800952 <memmove+0x3b>
  80093f:	f6 c1 03             	test   $0x3,%cl
  800942:	75 0e                	jne    800952 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800944:	83 ef 04             	sub    $0x4,%edi
  800947:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094a:	c1 e9 02             	shr    $0x2,%ecx
  80094d:	fd                   	std    
  80094e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800950:	eb 09                	jmp    80095b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800952:	83 ef 01             	sub    $0x1,%edi
  800955:	8d 72 ff             	lea    -0x1(%edx),%esi
  800958:	fd                   	std    
  800959:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095b:	fc                   	cld    
  80095c:	eb 1d                	jmp    80097b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095e:	89 f2                	mov    %esi,%edx
  800960:	09 c2                	or     %eax,%edx
  800962:	f6 c2 03             	test   $0x3,%dl
  800965:	75 0f                	jne    800976 <memmove+0x5f>
  800967:	f6 c1 03             	test   $0x3,%cl
  80096a:	75 0a                	jne    800976 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80096c:	c1 e9 02             	shr    $0x2,%ecx
  80096f:	89 c7                	mov    %eax,%edi
  800971:	fc                   	cld    
  800972:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800974:	eb 05                	jmp    80097b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800976:	89 c7                	mov    %eax,%edi
  800978:	fc                   	cld    
  800979:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097b:	5e                   	pop    %esi
  80097c:	5f                   	pop    %edi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800982:	ff 75 10             	pushl  0x10(%ebp)
  800985:	ff 75 0c             	pushl  0xc(%ebp)
  800988:	ff 75 08             	pushl  0x8(%ebp)
  80098b:	e8 87 ff ff ff       	call   800917 <memmove>
}
  800990:	c9                   	leave  
  800991:	c3                   	ret    

00800992 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	56                   	push   %esi
  800996:	53                   	push   %ebx
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099d:	89 c6                	mov    %eax,%esi
  80099f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a2:	eb 1a                	jmp    8009be <memcmp+0x2c>
		if (*s1 != *s2)
  8009a4:	0f b6 08             	movzbl (%eax),%ecx
  8009a7:	0f b6 1a             	movzbl (%edx),%ebx
  8009aa:	38 d9                	cmp    %bl,%cl
  8009ac:	74 0a                	je     8009b8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ae:	0f b6 c1             	movzbl %cl,%eax
  8009b1:	0f b6 db             	movzbl %bl,%ebx
  8009b4:	29 d8                	sub    %ebx,%eax
  8009b6:	eb 0f                	jmp    8009c7 <memcmp+0x35>
		s1++, s2++;
  8009b8:	83 c0 01             	add    $0x1,%eax
  8009bb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009be:	39 f0                	cmp    %esi,%eax
  8009c0:	75 e2                	jne    8009a4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c7:	5b                   	pop    %ebx
  8009c8:	5e                   	pop    %esi
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009d2:	89 c1                	mov    %eax,%ecx
  8009d4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009db:	eb 0a                	jmp    8009e7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009dd:	0f b6 10             	movzbl (%eax),%edx
  8009e0:	39 da                	cmp    %ebx,%edx
  8009e2:	74 07                	je     8009eb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e4:	83 c0 01             	add    $0x1,%eax
  8009e7:	39 c8                	cmp    %ecx,%eax
  8009e9:	72 f2                	jb     8009dd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009eb:	5b                   	pop    %ebx
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	57                   	push   %edi
  8009f2:	56                   	push   %esi
  8009f3:	53                   	push   %ebx
  8009f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fa:	eb 03                	jmp    8009ff <strtol+0x11>
		s++;
  8009fc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ff:	0f b6 01             	movzbl (%ecx),%eax
  800a02:	3c 20                	cmp    $0x20,%al
  800a04:	74 f6                	je     8009fc <strtol+0xe>
  800a06:	3c 09                	cmp    $0x9,%al
  800a08:	74 f2                	je     8009fc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a0a:	3c 2b                	cmp    $0x2b,%al
  800a0c:	75 0a                	jne    800a18 <strtol+0x2a>
		s++;
  800a0e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a11:	bf 00 00 00 00       	mov    $0x0,%edi
  800a16:	eb 11                	jmp    800a29 <strtol+0x3b>
  800a18:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a1d:	3c 2d                	cmp    $0x2d,%al
  800a1f:	75 08                	jne    800a29 <strtol+0x3b>
		s++, neg = 1;
  800a21:	83 c1 01             	add    $0x1,%ecx
  800a24:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a29:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2f:	75 15                	jne    800a46 <strtol+0x58>
  800a31:	80 39 30             	cmpb   $0x30,(%ecx)
  800a34:	75 10                	jne    800a46 <strtol+0x58>
  800a36:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3a:	75 7c                	jne    800ab8 <strtol+0xca>
		s += 2, base = 16;
  800a3c:	83 c1 02             	add    $0x2,%ecx
  800a3f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a44:	eb 16                	jmp    800a5c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a46:	85 db                	test   %ebx,%ebx
  800a48:	75 12                	jne    800a5c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a52:	75 08                	jne    800a5c <strtol+0x6e>
		s++, base = 8;
  800a54:	83 c1 01             	add    $0x1,%ecx
  800a57:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a61:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a64:	0f b6 11             	movzbl (%ecx),%edx
  800a67:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a6a:	89 f3                	mov    %esi,%ebx
  800a6c:	80 fb 09             	cmp    $0x9,%bl
  800a6f:	77 08                	ja     800a79 <strtol+0x8b>
			dig = *s - '0';
  800a71:	0f be d2             	movsbl %dl,%edx
  800a74:	83 ea 30             	sub    $0x30,%edx
  800a77:	eb 22                	jmp    800a9b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a79:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a7c:	89 f3                	mov    %esi,%ebx
  800a7e:	80 fb 19             	cmp    $0x19,%bl
  800a81:	77 08                	ja     800a8b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a83:	0f be d2             	movsbl %dl,%edx
  800a86:	83 ea 57             	sub    $0x57,%edx
  800a89:	eb 10                	jmp    800a9b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a8b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a8e:	89 f3                	mov    %esi,%ebx
  800a90:	80 fb 19             	cmp    $0x19,%bl
  800a93:	77 16                	ja     800aab <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a95:	0f be d2             	movsbl %dl,%edx
  800a98:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a9b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a9e:	7d 0b                	jge    800aab <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aa0:	83 c1 01             	add    $0x1,%ecx
  800aa3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa9:	eb b9                	jmp    800a64 <strtol+0x76>

	if (endptr)
  800aab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aaf:	74 0d                	je     800abe <strtol+0xd0>
		*endptr = (char *) s;
  800ab1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab4:	89 0e                	mov    %ecx,(%esi)
  800ab6:	eb 06                	jmp    800abe <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab8:	85 db                	test   %ebx,%ebx
  800aba:	74 98                	je     800a54 <strtol+0x66>
  800abc:	eb 9e                	jmp    800a5c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800abe:	89 c2                	mov    %eax,%edx
  800ac0:	f7 da                	neg    %edx
  800ac2:	85 ff                	test   %edi,%edi
  800ac4:	0f 45 c2             	cmovne %edx,%eax
}
  800ac7:	5b                   	pop    %ebx
  800ac8:	5e                   	pop    %esi
  800ac9:	5f                   	pop    %edi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	83 ec 04             	sub    $0x4,%esp
  800ad5:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800ad8:	57                   	push   %edi
  800ad9:	e8 6e fc ff ff       	call   80074c <strlen>
  800ade:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800ae1:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800ae4:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800ae9:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800aee:	eb 46                	jmp    800b36 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800af0:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800af4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800af7:	80 f9 09             	cmp    $0x9,%cl
  800afa:	77 08                	ja     800b04 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800afc:	0f be d2             	movsbl %dl,%edx
  800aff:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b02:	eb 27                	jmp    800b2b <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800b04:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800b07:	80 f9 05             	cmp    $0x5,%cl
  800b0a:	77 08                	ja     800b14 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800b0c:	0f be d2             	movsbl %dl,%edx
  800b0f:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800b12:	eb 17                	jmp    800b2b <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800b14:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800b17:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800b1a:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800b1f:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800b23:	77 06                	ja     800b2b <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800b25:	0f be d2             	movsbl %dl,%edx
  800b28:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800b2b:	0f af ce             	imul   %esi,%ecx
  800b2e:	01 c8                	add    %ecx,%eax
		base *= 16;
  800b30:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b33:	83 eb 01             	sub    $0x1,%ebx
  800b36:	83 fb 01             	cmp    $0x1,%ebx
  800b39:	7f b5                	jg     800af0 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800b3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b49:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b51:	8b 55 08             	mov    0x8(%ebp),%edx
  800b54:	89 c3                	mov    %eax,%ebx
  800b56:	89 c7                	mov    %eax,%edi
  800b58:	89 c6                	mov    %eax,%esi
  800b5a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b71:	89 d1                	mov    %edx,%ecx
  800b73:	89 d3                	mov    %edx,%ebx
  800b75:	89 d7                	mov    %edx,%edi
  800b77:	89 d6                	mov    %edx,%esi
  800b79:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b93:	8b 55 08             	mov    0x8(%ebp),%edx
  800b96:	89 cb                	mov    %ecx,%ebx
  800b98:	89 cf                	mov    %ecx,%edi
  800b9a:	89 ce                	mov    %ecx,%esi
  800b9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9e:	85 c0                	test   %eax,%eax
  800ba0:	7e 17                	jle    800bb9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	50                   	push   %eax
  800ba6:	6a 03                	push   $0x3
  800ba8:	68 7f 22 80 00       	push   $0x80227f
  800bad:	6a 23                	push   $0x23
  800baf:	68 9c 22 80 00       	push   $0x80229c
  800bb4:	e8 69 0f 00 00       	call   801b22 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800bcc:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd1:	89 d1                	mov    %edx,%ecx
  800bd3:	89 d3                	mov    %edx,%ebx
  800bd5:	89 d7                	mov    %edx,%edi
  800bd7:	89 d6                	mov    %edx,%esi
  800bd9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_yield>:

void
sys_yield(void)
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
  800be6:	ba 00 00 00 00       	mov    $0x0,%edx
  800beb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf0:	89 d1                	mov    %edx,%ecx
  800bf2:	89 d3                	mov    %edx,%ebx
  800bf4:	89 d7                	mov    %edx,%edi
  800bf6:	89 d6                	mov    %edx,%esi
  800bf8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c08:	be 00 00 00 00       	mov    $0x0,%esi
  800c0d:	b8 04 00 00 00       	mov    $0x4,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1b:	89 f7                	mov    %esi,%edi
  800c1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	7e 17                	jle    800c3a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	50                   	push   %eax
  800c27:	6a 04                	push   $0x4
  800c29:	68 7f 22 80 00       	push   $0x80227f
  800c2e:	6a 23                	push   $0x23
  800c30:	68 9c 22 80 00       	push   $0x80229c
  800c35:	e8 e8 0e 00 00       	call   801b22 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c59:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5c:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7e 17                	jle    800c7c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c65:	83 ec 0c             	sub    $0xc,%esp
  800c68:	50                   	push   %eax
  800c69:	6a 05                	push   $0x5
  800c6b:	68 7f 22 80 00       	push   $0x80227f
  800c70:	6a 23                	push   $0x23
  800c72:	68 9c 22 80 00       	push   $0x80229c
  800c77:	e8 a6 0e 00 00       	call   801b22 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c92:	b8 06 00 00 00       	mov    $0x6,%eax
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	89 df                	mov    %ebx,%edi
  800c9f:	89 de                	mov    %ebx,%esi
  800ca1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 17                	jle    800cbe <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	50                   	push   %eax
  800cab:	6a 06                	push   $0x6
  800cad:	68 7f 22 80 00       	push   $0x80227f
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 9c 22 80 00       	push   $0x80229c
  800cb9:	e8 64 0e 00 00       	call   801b22 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd4:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	89 df                	mov    %ebx,%edi
  800ce1:	89 de                	mov    %ebx,%esi
  800ce3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	7e 17                	jle    800d00 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce9:	83 ec 0c             	sub    $0xc,%esp
  800cec:	50                   	push   %eax
  800ced:	6a 08                	push   $0x8
  800cef:	68 7f 22 80 00       	push   $0x80227f
  800cf4:	6a 23                	push   $0x23
  800cf6:	68 9c 22 80 00       	push   $0x80229c
  800cfb:	e8 22 0e 00 00       	call   801b22 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d16:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	89 df                	mov    %ebx,%edi
  800d23:	89 de                	mov    %ebx,%esi
  800d25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d27:	85 c0                	test   %eax,%eax
  800d29:	7e 17                	jle    800d42 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2b:	83 ec 0c             	sub    $0xc,%esp
  800d2e:	50                   	push   %eax
  800d2f:	6a 0a                	push   $0xa
  800d31:	68 7f 22 80 00       	push   $0x80227f
  800d36:	6a 23                	push   $0x23
  800d38:	68 9c 22 80 00       	push   $0x80229c
  800d3d:	e8 e0 0d 00 00       	call   801b22 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d58:	b8 09 00 00 00       	mov    $0x9,%eax
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	89 df                	mov    %ebx,%edi
  800d65:	89 de                	mov    %ebx,%esi
  800d67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 17                	jle    800d84 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	83 ec 0c             	sub    $0xc,%esp
  800d70:	50                   	push   %eax
  800d71:	6a 09                	push   $0x9
  800d73:	68 7f 22 80 00       	push   $0x80227f
  800d78:	6a 23                	push   $0x23
  800d7a:	68 9c 22 80 00       	push   $0x80229c
  800d7f:	e8 9e 0d 00 00       	call   801b22 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d92:	be 00 00 00 00       	mov    $0x0,%esi
  800d97:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800da2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	57                   	push   %edi
  800db3:	56                   	push   %esi
  800db4:	53                   	push   %ebx
  800db5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc5:	89 cb                	mov    %ecx,%ebx
  800dc7:	89 cf                	mov    %ecx,%edi
  800dc9:	89 ce                	mov    %ecx,%esi
  800dcb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	7e 17                	jle    800de8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd1:	83 ec 0c             	sub    $0xc,%esp
  800dd4:	50                   	push   %eax
  800dd5:	6a 0d                	push   $0xd
  800dd7:	68 7f 22 80 00       	push   $0x80227f
  800ddc:	6a 23                	push   $0x23
  800dde:	68 9c 22 80 00       	push   $0x80229c
  800de3:	e8 3a 0d 00 00       	call   801b22 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800df3:	8b 45 08             	mov    0x8(%ebp),%eax
  800df6:	05 00 00 00 30       	add    $0x30000000,%eax
  800dfb:	c1 e8 0c             	shr    $0xc,%eax
}
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e03:	8b 45 08             	mov    0x8(%ebp),%eax
  800e06:	05 00 00 00 30       	add    $0x30000000,%eax
  800e0b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e10:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e22:	89 c2                	mov    %eax,%edx
  800e24:	c1 ea 16             	shr    $0x16,%edx
  800e27:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e2e:	f6 c2 01             	test   $0x1,%dl
  800e31:	74 11                	je     800e44 <fd_alloc+0x2d>
  800e33:	89 c2                	mov    %eax,%edx
  800e35:	c1 ea 0c             	shr    $0xc,%edx
  800e38:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e3f:	f6 c2 01             	test   $0x1,%dl
  800e42:	75 09                	jne    800e4d <fd_alloc+0x36>
			*fd_store = fd;
  800e44:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e46:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4b:	eb 17                	jmp    800e64 <fd_alloc+0x4d>
  800e4d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e52:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e57:	75 c9                	jne    800e22 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e59:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e5f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e6c:	83 f8 1f             	cmp    $0x1f,%eax
  800e6f:	77 36                	ja     800ea7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e71:	c1 e0 0c             	shl    $0xc,%eax
  800e74:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e79:	89 c2                	mov    %eax,%edx
  800e7b:	c1 ea 16             	shr    $0x16,%edx
  800e7e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e85:	f6 c2 01             	test   $0x1,%dl
  800e88:	74 24                	je     800eae <fd_lookup+0x48>
  800e8a:	89 c2                	mov    %eax,%edx
  800e8c:	c1 ea 0c             	shr    $0xc,%edx
  800e8f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e96:	f6 c2 01             	test   $0x1,%dl
  800e99:	74 1a                	je     800eb5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e9e:	89 02                	mov    %eax,(%edx)
	return 0;
  800ea0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea5:	eb 13                	jmp    800eba <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ea7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eac:	eb 0c                	jmp    800eba <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eb3:	eb 05                	jmp    800eba <fd_lookup+0x54>
  800eb5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	83 ec 08             	sub    $0x8,%esp
  800ec2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec5:	ba 28 23 80 00       	mov    $0x802328,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eca:	eb 13                	jmp    800edf <dev_lookup+0x23>
  800ecc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ecf:	39 08                	cmp    %ecx,(%eax)
  800ed1:	75 0c                	jne    800edf <dev_lookup+0x23>
			*dev = devtab[i];
  800ed3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed6:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ed8:	b8 00 00 00 00       	mov    $0x0,%eax
  800edd:	eb 2e                	jmp    800f0d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800edf:	8b 02                	mov    (%edx),%eax
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	75 e7                	jne    800ecc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ee5:	a1 08 40 80 00       	mov    0x804008,%eax
  800eea:	8b 40 48             	mov    0x48(%eax),%eax
  800eed:	83 ec 04             	sub    $0x4,%esp
  800ef0:	51                   	push   %ecx
  800ef1:	50                   	push   %eax
  800ef2:	68 ac 22 80 00       	push   $0x8022ac
  800ef7:	e8 55 f2 ff ff       	call   800151 <cprintf>
	*dev = 0;
  800efc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f05:	83 c4 10             	add    $0x10,%esp
  800f08:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f0d:	c9                   	leave  
  800f0e:	c3                   	ret    

00800f0f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
  800f14:	83 ec 10             	sub    $0x10,%esp
  800f17:	8b 75 08             	mov    0x8(%ebp),%esi
  800f1a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f20:	50                   	push   %eax
  800f21:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f27:	c1 e8 0c             	shr    $0xc,%eax
  800f2a:	50                   	push   %eax
  800f2b:	e8 36 ff ff ff       	call   800e66 <fd_lookup>
  800f30:	83 c4 08             	add    $0x8,%esp
  800f33:	85 c0                	test   %eax,%eax
  800f35:	78 05                	js     800f3c <fd_close+0x2d>
	    || fd != fd2) 
  800f37:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f3a:	74 0c                	je     800f48 <fd_close+0x39>
		return (must_exist ? r : 0); 
  800f3c:	84 db                	test   %bl,%bl
  800f3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f43:	0f 44 c2             	cmove  %edx,%eax
  800f46:	eb 41                	jmp    800f89 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f48:	83 ec 08             	sub    $0x8,%esp
  800f4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f4e:	50                   	push   %eax
  800f4f:	ff 36                	pushl  (%esi)
  800f51:	e8 66 ff ff ff       	call   800ebc <dev_lookup>
  800f56:	89 c3                	mov    %eax,%ebx
  800f58:	83 c4 10             	add    $0x10,%esp
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	78 1a                	js     800f79 <fd_close+0x6a>
		if (dev->dev_close) 
  800f5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f62:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  800f65:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	74 0b                	je     800f79 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f6e:	83 ec 0c             	sub    $0xc,%esp
  800f71:	56                   	push   %esi
  800f72:	ff d0                	call   *%eax
  800f74:	89 c3                	mov    %eax,%ebx
  800f76:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f79:	83 ec 08             	sub    $0x8,%esp
  800f7c:	56                   	push   %esi
  800f7d:	6a 00                	push   $0x0
  800f7f:	e8 00 fd ff ff       	call   800c84 <sys_page_unmap>
	return r;
  800f84:	83 c4 10             	add    $0x10,%esp
  800f87:	89 d8                	mov    %ebx,%eax
}
  800f89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8c:	5b                   	pop    %ebx
  800f8d:	5e                   	pop    %esi
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    

00800f90 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f99:	50                   	push   %eax
  800f9a:	ff 75 08             	pushl  0x8(%ebp)
  800f9d:	e8 c4 fe ff ff       	call   800e66 <fd_lookup>
  800fa2:	83 c4 08             	add    $0x8,%esp
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	78 10                	js     800fb9 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  800fa9:	83 ec 08             	sub    $0x8,%esp
  800fac:	6a 01                	push   $0x1
  800fae:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb1:	e8 59 ff ff ff       	call   800f0f <fd_close>
  800fb6:	83 c4 10             	add    $0x10,%esp
}
  800fb9:	c9                   	leave  
  800fba:	c3                   	ret    

00800fbb <close_all>:

void
close_all(void)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	53                   	push   %ebx
  800fbf:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fc7:	83 ec 0c             	sub    $0xc,%esp
  800fca:	53                   	push   %ebx
  800fcb:	e8 c0 ff ff ff       	call   800f90 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd0:	83 c3 01             	add    $0x1,%ebx
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	83 fb 20             	cmp    $0x20,%ebx
  800fd9:	75 ec                	jne    800fc7 <close_all+0xc>
		close(i);
}
  800fdb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fde:	c9                   	leave  
  800fdf:	c3                   	ret    

00800fe0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	57                   	push   %edi
  800fe4:	56                   	push   %esi
  800fe5:	53                   	push   %ebx
  800fe6:	83 ec 2c             	sub    $0x2c,%esp
  800fe9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fef:	50                   	push   %eax
  800ff0:	ff 75 08             	pushl  0x8(%ebp)
  800ff3:	e8 6e fe ff ff       	call   800e66 <fd_lookup>
  800ff8:	83 c4 08             	add    $0x8,%esp
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	0f 88 c1 00 00 00    	js     8010c4 <dup+0xe4>
		return r;
	close(newfdnum);
  801003:	83 ec 0c             	sub    $0xc,%esp
  801006:	56                   	push   %esi
  801007:	e8 84 ff ff ff       	call   800f90 <close>

	newfd = INDEX2FD(newfdnum);
  80100c:	89 f3                	mov    %esi,%ebx
  80100e:	c1 e3 0c             	shl    $0xc,%ebx
  801011:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801017:	83 c4 04             	add    $0x4,%esp
  80101a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80101d:	e8 de fd ff ff       	call   800e00 <fd2data>
  801022:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801024:	89 1c 24             	mov    %ebx,(%esp)
  801027:	e8 d4 fd ff ff       	call   800e00 <fd2data>
  80102c:	83 c4 10             	add    $0x10,%esp
  80102f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801032:	89 f8                	mov    %edi,%eax
  801034:	c1 e8 16             	shr    $0x16,%eax
  801037:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80103e:	a8 01                	test   $0x1,%al
  801040:	74 37                	je     801079 <dup+0x99>
  801042:	89 f8                	mov    %edi,%eax
  801044:	c1 e8 0c             	shr    $0xc,%eax
  801047:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80104e:	f6 c2 01             	test   $0x1,%dl
  801051:	74 26                	je     801079 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801053:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105a:	83 ec 0c             	sub    $0xc,%esp
  80105d:	25 07 0e 00 00       	and    $0xe07,%eax
  801062:	50                   	push   %eax
  801063:	ff 75 d4             	pushl  -0x2c(%ebp)
  801066:	6a 00                	push   $0x0
  801068:	57                   	push   %edi
  801069:	6a 00                	push   $0x0
  80106b:	e8 d2 fb ff ff       	call   800c42 <sys_page_map>
  801070:	89 c7                	mov    %eax,%edi
  801072:	83 c4 20             	add    $0x20,%esp
  801075:	85 c0                	test   %eax,%eax
  801077:	78 2e                	js     8010a7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801079:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80107c:	89 d0                	mov    %edx,%eax
  80107e:	c1 e8 0c             	shr    $0xc,%eax
  801081:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801088:	83 ec 0c             	sub    $0xc,%esp
  80108b:	25 07 0e 00 00       	and    $0xe07,%eax
  801090:	50                   	push   %eax
  801091:	53                   	push   %ebx
  801092:	6a 00                	push   $0x0
  801094:	52                   	push   %edx
  801095:	6a 00                	push   $0x0
  801097:	e8 a6 fb ff ff       	call   800c42 <sys_page_map>
  80109c:	89 c7                	mov    %eax,%edi
  80109e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010a1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010a3:	85 ff                	test   %edi,%edi
  8010a5:	79 1d                	jns    8010c4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010a7:	83 ec 08             	sub    $0x8,%esp
  8010aa:	53                   	push   %ebx
  8010ab:	6a 00                	push   $0x0
  8010ad:	e8 d2 fb ff ff       	call   800c84 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010b2:	83 c4 08             	add    $0x8,%esp
  8010b5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010b8:	6a 00                	push   $0x0
  8010ba:	e8 c5 fb ff ff       	call   800c84 <sys_page_unmap>
	return r;
  8010bf:	83 c4 10             	add    $0x10,%esp
  8010c2:	89 f8                	mov    %edi,%eax
}
  8010c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c7:	5b                   	pop    %ebx
  8010c8:	5e                   	pop    %esi
  8010c9:	5f                   	pop    %edi
  8010ca:	5d                   	pop    %ebp
  8010cb:	c3                   	ret    

008010cc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	53                   	push   %ebx
  8010d0:	83 ec 14             	sub    $0x14,%esp
  8010d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d9:	50                   	push   %eax
  8010da:	53                   	push   %ebx
  8010db:	e8 86 fd ff ff       	call   800e66 <fd_lookup>
  8010e0:	83 c4 08             	add    $0x8,%esp
  8010e3:	89 c2                	mov    %eax,%edx
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	78 6d                	js     801156 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e9:	83 ec 08             	sub    $0x8,%esp
  8010ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ef:	50                   	push   %eax
  8010f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f3:	ff 30                	pushl  (%eax)
  8010f5:	e8 c2 fd ff ff       	call   800ebc <dev_lookup>
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	78 4c                	js     80114d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801101:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801104:	8b 42 08             	mov    0x8(%edx),%eax
  801107:	83 e0 03             	and    $0x3,%eax
  80110a:	83 f8 01             	cmp    $0x1,%eax
  80110d:	75 21                	jne    801130 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80110f:	a1 08 40 80 00       	mov    0x804008,%eax
  801114:	8b 40 48             	mov    0x48(%eax),%eax
  801117:	83 ec 04             	sub    $0x4,%esp
  80111a:	53                   	push   %ebx
  80111b:	50                   	push   %eax
  80111c:	68 ed 22 80 00       	push   $0x8022ed
  801121:	e8 2b f0 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  801126:	83 c4 10             	add    $0x10,%esp
  801129:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80112e:	eb 26                	jmp    801156 <read+0x8a>
	}
	if (!dev->dev_read)
  801130:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801133:	8b 40 08             	mov    0x8(%eax),%eax
  801136:	85 c0                	test   %eax,%eax
  801138:	74 17                	je     801151 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80113a:	83 ec 04             	sub    $0x4,%esp
  80113d:	ff 75 10             	pushl  0x10(%ebp)
  801140:	ff 75 0c             	pushl  0xc(%ebp)
  801143:	52                   	push   %edx
  801144:	ff d0                	call   *%eax
  801146:	89 c2                	mov    %eax,%edx
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	eb 09                	jmp    801156 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114d:	89 c2                	mov    %eax,%edx
  80114f:	eb 05                	jmp    801156 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801151:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801156:	89 d0                	mov    %edx,%eax
  801158:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115b:	c9                   	leave  
  80115c:	c3                   	ret    

0080115d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	57                   	push   %edi
  801161:	56                   	push   %esi
  801162:	53                   	push   %ebx
  801163:	83 ec 0c             	sub    $0xc,%esp
  801166:	8b 7d 08             	mov    0x8(%ebp),%edi
  801169:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80116c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801171:	eb 21                	jmp    801194 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801173:	83 ec 04             	sub    $0x4,%esp
  801176:	89 f0                	mov    %esi,%eax
  801178:	29 d8                	sub    %ebx,%eax
  80117a:	50                   	push   %eax
  80117b:	89 d8                	mov    %ebx,%eax
  80117d:	03 45 0c             	add    0xc(%ebp),%eax
  801180:	50                   	push   %eax
  801181:	57                   	push   %edi
  801182:	e8 45 ff ff ff       	call   8010cc <read>
		if (m < 0)
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	85 c0                	test   %eax,%eax
  80118c:	78 10                	js     80119e <readn+0x41>
			return m;
		if (m == 0)
  80118e:	85 c0                	test   %eax,%eax
  801190:	74 0a                	je     80119c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801192:	01 c3                	add    %eax,%ebx
  801194:	39 f3                	cmp    %esi,%ebx
  801196:	72 db                	jb     801173 <readn+0x16>
  801198:	89 d8                	mov    %ebx,%eax
  80119a:	eb 02                	jmp    80119e <readn+0x41>
  80119c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80119e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a1:	5b                   	pop    %ebx
  8011a2:	5e                   	pop    %esi
  8011a3:	5f                   	pop    %edi
  8011a4:	5d                   	pop    %ebp
  8011a5:	c3                   	ret    

008011a6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	53                   	push   %ebx
  8011aa:	83 ec 14             	sub    $0x14,%esp
  8011ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b3:	50                   	push   %eax
  8011b4:	53                   	push   %ebx
  8011b5:	e8 ac fc ff ff       	call   800e66 <fd_lookup>
  8011ba:	83 c4 08             	add    $0x8,%esp
  8011bd:	89 c2                	mov    %eax,%edx
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	78 68                	js     80122b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c3:	83 ec 08             	sub    $0x8,%esp
  8011c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c9:	50                   	push   %eax
  8011ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cd:	ff 30                	pushl  (%eax)
  8011cf:	e8 e8 fc ff ff       	call   800ebc <dev_lookup>
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	78 47                	js     801222 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011de:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011e2:	75 21                	jne    801205 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e4:	a1 08 40 80 00       	mov    0x804008,%eax
  8011e9:	8b 40 48             	mov    0x48(%eax),%eax
  8011ec:	83 ec 04             	sub    $0x4,%esp
  8011ef:	53                   	push   %ebx
  8011f0:	50                   	push   %eax
  8011f1:	68 09 23 80 00       	push   $0x802309
  8011f6:	e8 56 ef ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  8011fb:	83 c4 10             	add    $0x10,%esp
  8011fe:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801203:	eb 26                	jmp    80122b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801205:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801208:	8b 52 0c             	mov    0xc(%edx),%edx
  80120b:	85 d2                	test   %edx,%edx
  80120d:	74 17                	je     801226 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80120f:	83 ec 04             	sub    $0x4,%esp
  801212:	ff 75 10             	pushl  0x10(%ebp)
  801215:	ff 75 0c             	pushl  0xc(%ebp)
  801218:	50                   	push   %eax
  801219:	ff d2                	call   *%edx
  80121b:	89 c2                	mov    %eax,%edx
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	eb 09                	jmp    80122b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801222:	89 c2                	mov    %eax,%edx
  801224:	eb 05                	jmp    80122b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801226:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80122b:	89 d0                	mov    %edx,%eax
  80122d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801230:	c9                   	leave  
  801231:	c3                   	ret    

00801232 <seek>:

int
seek(int fdnum, off_t offset)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801238:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80123b:	50                   	push   %eax
  80123c:	ff 75 08             	pushl  0x8(%ebp)
  80123f:	e8 22 fc ff ff       	call   800e66 <fd_lookup>
  801244:	83 c4 08             	add    $0x8,%esp
  801247:	85 c0                	test   %eax,%eax
  801249:	78 0e                	js     801259 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80124b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80124e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801251:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801254:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801259:	c9                   	leave  
  80125a:	c3                   	ret    

0080125b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	53                   	push   %ebx
  80125f:	83 ec 14             	sub    $0x14,%esp
  801262:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801265:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801268:	50                   	push   %eax
  801269:	53                   	push   %ebx
  80126a:	e8 f7 fb ff ff       	call   800e66 <fd_lookup>
  80126f:	83 c4 08             	add    $0x8,%esp
  801272:	89 c2                	mov    %eax,%edx
  801274:	85 c0                	test   %eax,%eax
  801276:	78 65                	js     8012dd <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801278:	83 ec 08             	sub    $0x8,%esp
  80127b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127e:	50                   	push   %eax
  80127f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801282:	ff 30                	pushl  (%eax)
  801284:	e8 33 fc ff ff       	call   800ebc <dev_lookup>
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	85 c0                	test   %eax,%eax
  80128e:	78 44                	js     8012d4 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801290:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801293:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801297:	75 21                	jne    8012ba <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801299:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80129e:	8b 40 48             	mov    0x48(%eax),%eax
  8012a1:	83 ec 04             	sub    $0x4,%esp
  8012a4:	53                   	push   %ebx
  8012a5:	50                   	push   %eax
  8012a6:	68 cc 22 80 00       	push   $0x8022cc
  8012ab:	e8 a1 ee ff ff       	call   800151 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b0:	83 c4 10             	add    $0x10,%esp
  8012b3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012b8:	eb 23                	jmp    8012dd <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bd:	8b 52 18             	mov    0x18(%edx),%edx
  8012c0:	85 d2                	test   %edx,%edx
  8012c2:	74 14                	je     8012d8 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012c4:	83 ec 08             	sub    $0x8,%esp
  8012c7:	ff 75 0c             	pushl  0xc(%ebp)
  8012ca:	50                   	push   %eax
  8012cb:	ff d2                	call   *%edx
  8012cd:	89 c2                	mov    %eax,%edx
  8012cf:	83 c4 10             	add    $0x10,%esp
  8012d2:	eb 09                	jmp    8012dd <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d4:	89 c2                	mov    %eax,%edx
  8012d6:	eb 05                	jmp    8012dd <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012dd:	89 d0                	mov    %edx,%eax
  8012df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e2:	c9                   	leave  
  8012e3:	c3                   	ret    

008012e4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	53                   	push   %ebx
  8012e8:	83 ec 14             	sub    $0x14,%esp
  8012eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f1:	50                   	push   %eax
  8012f2:	ff 75 08             	pushl  0x8(%ebp)
  8012f5:	e8 6c fb ff ff       	call   800e66 <fd_lookup>
  8012fa:	83 c4 08             	add    $0x8,%esp
  8012fd:	89 c2                	mov    %eax,%edx
  8012ff:	85 c0                	test   %eax,%eax
  801301:	78 58                	js     80135b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801303:	83 ec 08             	sub    $0x8,%esp
  801306:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801309:	50                   	push   %eax
  80130a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130d:	ff 30                	pushl  (%eax)
  80130f:	e8 a8 fb ff ff       	call   800ebc <dev_lookup>
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	85 c0                	test   %eax,%eax
  801319:	78 37                	js     801352 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80131b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801322:	74 32                	je     801356 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801324:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801327:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80132e:	00 00 00 
	stat->st_isdir = 0;
  801331:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801338:	00 00 00 
	stat->st_dev = dev;
  80133b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801341:	83 ec 08             	sub    $0x8,%esp
  801344:	53                   	push   %ebx
  801345:	ff 75 f0             	pushl  -0x10(%ebp)
  801348:	ff 50 14             	call   *0x14(%eax)
  80134b:	89 c2                	mov    %eax,%edx
  80134d:	83 c4 10             	add    $0x10,%esp
  801350:	eb 09                	jmp    80135b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801352:	89 c2                	mov    %eax,%edx
  801354:	eb 05                	jmp    80135b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801356:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80135b:	89 d0                	mov    %edx,%eax
  80135d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801360:	c9                   	leave  
  801361:	c3                   	ret    

00801362 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	56                   	push   %esi
  801366:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801367:	83 ec 08             	sub    $0x8,%esp
  80136a:	6a 00                	push   $0x0
  80136c:	ff 75 08             	pushl  0x8(%ebp)
  80136f:	e8 2b 02 00 00       	call   80159f <open>
  801374:	89 c3                	mov    %eax,%ebx
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	85 c0                	test   %eax,%eax
  80137b:	78 1b                	js     801398 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80137d:	83 ec 08             	sub    $0x8,%esp
  801380:	ff 75 0c             	pushl  0xc(%ebp)
  801383:	50                   	push   %eax
  801384:	e8 5b ff ff ff       	call   8012e4 <fstat>
  801389:	89 c6                	mov    %eax,%esi
	close(fd);
  80138b:	89 1c 24             	mov    %ebx,(%esp)
  80138e:	e8 fd fb ff ff       	call   800f90 <close>
	return r;
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	89 f0                	mov    %esi,%eax
}
  801398:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80139b:	5b                   	pop    %ebx
  80139c:	5e                   	pop    %esi
  80139d:	5d                   	pop    %ebp
  80139e:	c3                   	ret    

0080139f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	56                   	push   %esi
  8013a3:	53                   	push   %ebx
  8013a4:	89 c6                	mov    %eax,%esi
  8013a6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013a8:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8013af:	75 12                	jne    8013c3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013b1:	83 ec 0c             	sub    $0xc,%esp
  8013b4:	6a 01                	push   $0x1
  8013b6:	e8 6c 08 00 00       	call   801c27 <ipc_find_env>
  8013bb:	a3 04 40 80 00       	mov    %eax,0x804004
  8013c0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013c3:	6a 07                	push   $0x7
  8013c5:	68 00 50 80 00       	push   $0x805000
  8013ca:	56                   	push   %esi
  8013cb:	ff 35 04 40 80 00    	pushl  0x804004
  8013d1:	e8 fb 07 00 00       	call   801bd1 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8013d6:	83 c4 0c             	add    $0xc,%esp
  8013d9:	6a 00                	push   $0x0
  8013db:	53                   	push   %ebx
  8013dc:	6a 00                	push   $0x0
  8013de:	e8 85 07 00 00       	call   801b68 <ipc_recv>
}
  8013e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e6:	5b                   	pop    %ebx
  8013e7:	5e                   	pop    %esi
  8013e8:	5d                   	pop    %ebp
  8013e9:	c3                   	ret    

008013ea <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f3:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fe:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801403:	ba 00 00 00 00       	mov    $0x0,%edx
  801408:	b8 02 00 00 00       	mov    $0x2,%eax
  80140d:	e8 8d ff ff ff       	call   80139f <fsipc>
}
  801412:	c9                   	leave  
  801413:	c3                   	ret    

00801414 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80141a:	8b 45 08             	mov    0x8(%ebp),%eax
  80141d:	8b 40 0c             	mov    0xc(%eax),%eax
  801420:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801425:	ba 00 00 00 00       	mov    $0x0,%edx
  80142a:	b8 06 00 00 00       	mov    $0x6,%eax
  80142f:	e8 6b ff ff ff       	call   80139f <fsipc>
}
  801434:	c9                   	leave  
  801435:	c3                   	ret    

00801436 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	53                   	push   %ebx
  80143a:	83 ec 04             	sub    $0x4,%esp
  80143d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801440:	8b 45 08             	mov    0x8(%ebp),%eax
  801443:	8b 40 0c             	mov    0xc(%eax),%eax
  801446:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80144b:	ba 00 00 00 00       	mov    $0x0,%edx
  801450:	b8 05 00 00 00       	mov    $0x5,%eax
  801455:	e8 45 ff ff ff       	call   80139f <fsipc>
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 2c                	js     80148a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80145e:	83 ec 08             	sub    $0x8,%esp
  801461:	68 00 50 80 00       	push   $0x805000
  801466:	53                   	push   %ebx
  801467:	e8 19 f3 ff ff       	call   800785 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80146c:	a1 80 50 80 00       	mov    0x805080,%eax
  801471:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801477:	a1 84 50 80 00       	mov    0x805084,%eax
  80147c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80148a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148d:	c9                   	leave  
  80148e:	c3                   	ret    

0080148f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	53                   	push   %ebx
  801493:	83 ec 08             	sub    $0x8,%esp
  801496:	8b 45 10             	mov    0x10(%ebp),%eax
  801499:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80149e:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8014a3:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ac:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  8014b1:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014b7:	53                   	push   %ebx
  8014b8:	ff 75 0c             	pushl  0xc(%ebp)
  8014bb:	68 08 50 80 00       	push   $0x805008
  8014c0:	e8 52 f4 ff ff       	call   800917 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8014c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ca:	b8 04 00 00 00       	mov    $0x4,%eax
  8014cf:	e8 cb fe ff ff       	call   80139f <fsipc>
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	78 3d                	js     801518 <devfile_write+0x89>
		return r;

	assert(r <= n);
  8014db:	39 d8                	cmp    %ebx,%eax
  8014dd:	76 19                	jbe    8014f8 <devfile_write+0x69>
  8014df:	68 38 23 80 00       	push   $0x802338
  8014e4:	68 3f 23 80 00       	push   $0x80233f
  8014e9:	68 9f 00 00 00       	push   $0x9f
  8014ee:	68 54 23 80 00       	push   $0x802354
  8014f3:	e8 2a 06 00 00       	call   801b22 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  8014f8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014fd:	76 19                	jbe    801518 <devfile_write+0x89>
  8014ff:	68 6c 23 80 00       	push   $0x80236c
  801504:	68 3f 23 80 00       	push   $0x80233f
  801509:	68 a0 00 00 00       	push   $0xa0
  80150e:	68 54 23 80 00       	push   $0x802354
  801513:	e8 0a 06 00 00       	call   801b22 <_panic>

	return r;
}
  801518:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151b:	c9                   	leave  
  80151c:	c3                   	ret    

0080151d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	56                   	push   %esi
  801521:	53                   	push   %ebx
  801522:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801525:	8b 45 08             	mov    0x8(%ebp),%eax
  801528:	8b 40 0c             	mov    0xc(%eax),%eax
  80152b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801530:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801536:	ba 00 00 00 00       	mov    $0x0,%edx
  80153b:	b8 03 00 00 00       	mov    $0x3,%eax
  801540:	e8 5a fe ff ff       	call   80139f <fsipc>
  801545:	89 c3                	mov    %eax,%ebx
  801547:	85 c0                	test   %eax,%eax
  801549:	78 4b                	js     801596 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80154b:	39 c6                	cmp    %eax,%esi
  80154d:	73 16                	jae    801565 <devfile_read+0x48>
  80154f:	68 38 23 80 00       	push   $0x802338
  801554:	68 3f 23 80 00       	push   $0x80233f
  801559:	6a 7e                	push   $0x7e
  80155b:	68 54 23 80 00       	push   $0x802354
  801560:	e8 bd 05 00 00       	call   801b22 <_panic>
	assert(r <= PGSIZE);
  801565:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80156a:	7e 16                	jle    801582 <devfile_read+0x65>
  80156c:	68 5f 23 80 00       	push   $0x80235f
  801571:	68 3f 23 80 00       	push   $0x80233f
  801576:	6a 7f                	push   $0x7f
  801578:	68 54 23 80 00       	push   $0x802354
  80157d:	e8 a0 05 00 00       	call   801b22 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801582:	83 ec 04             	sub    $0x4,%esp
  801585:	50                   	push   %eax
  801586:	68 00 50 80 00       	push   $0x805000
  80158b:	ff 75 0c             	pushl  0xc(%ebp)
  80158e:	e8 84 f3 ff ff       	call   800917 <memmove>
	return r;
  801593:	83 c4 10             	add    $0x10,%esp
}
  801596:	89 d8                	mov    %ebx,%eax
  801598:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159b:	5b                   	pop    %ebx
  80159c:	5e                   	pop    %esi
  80159d:	5d                   	pop    %ebp
  80159e:	c3                   	ret    

0080159f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	53                   	push   %ebx
  8015a3:	83 ec 20             	sub    $0x20,%esp
  8015a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015a9:	53                   	push   %ebx
  8015aa:	e8 9d f1 ff ff       	call   80074c <strlen>
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015b7:	7f 67                	jg     801620 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015b9:	83 ec 0c             	sub    $0xc,%esp
  8015bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bf:	50                   	push   %eax
  8015c0:	e8 52 f8 ff ff       	call   800e17 <fd_alloc>
  8015c5:	83 c4 10             	add    $0x10,%esp
		return r;
  8015c8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015ca:	85 c0                	test   %eax,%eax
  8015cc:	78 57                	js     801625 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015ce:	83 ec 08             	sub    $0x8,%esp
  8015d1:	53                   	push   %ebx
  8015d2:	68 00 50 80 00       	push   $0x805000
  8015d7:	e8 a9 f1 ff ff       	call   800785 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015df:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ec:	e8 ae fd ff ff       	call   80139f <fsipc>
  8015f1:	89 c3                	mov    %eax,%ebx
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	79 14                	jns    80160e <open+0x6f>
		fd_close(fd, 0);
  8015fa:	83 ec 08             	sub    $0x8,%esp
  8015fd:	6a 00                	push   $0x0
  8015ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801602:	e8 08 f9 ff ff       	call   800f0f <fd_close>
		return r;
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	89 da                	mov    %ebx,%edx
  80160c:	eb 17                	jmp    801625 <open+0x86>
	}

	return fd2num(fd);
  80160e:	83 ec 0c             	sub    $0xc,%esp
  801611:	ff 75 f4             	pushl  -0xc(%ebp)
  801614:	e8 d7 f7 ff ff       	call   800df0 <fd2num>
  801619:	89 c2                	mov    %eax,%edx
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	eb 05                	jmp    801625 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801620:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801625:	89 d0                	mov    %edx,%eax
  801627:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162a:	c9                   	leave  
  80162b:	c3                   	ret    

0080162c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801632:	ba 00 00 00 00       	mov    $0x0,%edx
  801637:	b8 08 00 00 00       	mov    $0x8,%eax
  80163c:	e8 5e fd ff ff       	call   80139f <fsipc>
}
  801641:	c9                   	leave  
  801642:	c3                   	ret    

00801643 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	56                   	push   %esi
  801647:	53                   	push   %ebx
  801648:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80164b:	83 ec 0c             	sub    $0xc,%esp
  80164e:	ff 75 08             	pushl  0x8(%ebp)
  801651:	e8 aa f7 ff ff       	call   800e00 <fd2data>
  801656:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801658:	83 c4 08             	add    $0x8,%esp
  80165b:	68 99 23 80 00       	push   $0x802399
  801660:	53                   	push   %ebx
  801661:	e8 1f f1 ff ff       	call   800785 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801666:	8b 46 04             	mov    0x4(%esi),%eax
  801669:	2b 06                	sub    (%esi),%eax
  80166b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801671:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801678:	00 00 00 
	stat->st_dev = &devpipe;
  80167b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801682:	30 80 00 
	return 0;
}
  801685:	b8 00 00 00 00       	mov    $0x0,%eax
  80168a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80168d:	5b                   	pop    %ebx
  80168e:	5e                   	pop    %esi
  80168f:	5d                   	pop    %ebp
  801690:	c3                   	ret    

00801691 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	53                   	push   %ebx
  801695:	83 ec 0c             	sub    $0xc,%esp
  801698:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80169b:	53                   	push   %ebx
  80169c:	6a 00                	push   $0x0
  80169e:	e8 e1 f5 ff ff       	call   800c84 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016a3:	89 1c 24             	mov    %ebx,(%esp)
  8016a6:	e8 55 f7 ff ff       	call   800e00 <fd2data>
  8016ab:	83 c4 08             	add    $0x8,%esp
  8016ae:	50                   	push   %eax
  8016af:	6a 00                	push   $0x0
  8016b1:	e8 ce f5 ff ff       	call   800c84 <sys_page_unmap>
}
  8016b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b9:	c9                   	leave  
  8016ba:	c3                   	ret    

008016bb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	57                   	push   %edi
  8016bf:	56                   	push   %esi
  8016c0:	53                   	push   %ebx
  8016c1:	83 ec 1c             	sub    $0x1c,%esp
  8016c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016c7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8016ce:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016d1:	83 ec 0c             	sub    $0xc,%esp
  8016d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8016d7:	e8 84 05 00 00       	call   801c60 <pageref>
  8016dc:	89 c3                	mov    %eax,%ebx
  8016de:	89 3c 24             	mov    %edi,(%esp)
  8016e1:	e8 7a 05 00 00       	call   801c60 <pageref>
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	39 c3                	cmp    %eax,%ebx
  8016eb:	0f 94 c1             	sete   %cl
  8016ee:	0f b6 c9             	movzbl %cl,%ecx
  8016f1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016f4:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8016fa:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016fd:	39 ce                	cmp    %ecx,%esi
  8016ff:	74 1b                	je     80171c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801701:	39 c3                	cmp    %eax,%ebx
  801703:	75 c4                	jne    8016c9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801705:	8b 42 58             	mov    0x58(%edx),%eax
  801708:	ff 75 e4             	pushl  -0x1c(%ebp)
  80170b:	50                   	push   %eax
  80170c:	56                   	push   %esi
  80170d:	68 a0 23 80 00       	push   $0x8023a0
  801712:	e8 3a ea ff ff       	call   800151 <cprintf>
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	eb ad                	jmp    8016c9 <_pipeisclosed+0xe>
	}
}
  80171c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80171f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801722:	5b                   	pop    %ebx
  801723:	5e                   	pop    %esi
  801724:	5f                   	pop    %edi
  801725:	5d                   	pop    %ebp
  801726:	c3                   	ret    

00801727 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	57                   	push   %edi
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
  80172d:	83 ec 28             	sub    $0x28,%esp
  801730:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801733:	56                   	push   %esi
  801734:	e8 c7 f6 ff ff       	call   800e00 <fd2data>
  801739:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	bf 00 00 00 00       	mov    $0x0,%edi
  801743:	eb 4b                	jmp    801790 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801745:	89 da                	mov    %ebx,%edx
  801747:	89 f0                	mov    %esi,%eax
  801749:	e8 6d ff ff ff       	call   8016bb <_pipeisclosed>
  80174e:	85 c0                	test   %eax,%eax
  801750:	75 48                	jne    80179a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801752:	e8 89 f4 ff ff       	call   800be0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801757:	8b 43 04             	mov    0x4(%ebx),%eax
  80175a:	8b 0b                	mov    (%ebx),%ecx
  80175c:	8d 51 20             	lea    0x20(%ecx),%edx
  80175f:	39 d0                	cmp    %edx,%eax
  801761:	73 e2                	jae    801745 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801763:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801766:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80176a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80176d:	89 c2                	mov    %eax,%edx
  80176f:	c1 fa 1f             	sar    $0x1f,%edx
  801772:	89 d1                	mov    %edx,%ecx
  801774:	c1 e9 1b             	shr    $0x1b,%ecx
  801777:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80177a:	83 e2 1f             	and    $0x1f,%edx
  80177d:	29 ca                	sub    %ecx,%edx
  80177f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801783:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801787:	83 c0 01             	add    $0x1,%eax
  80178a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80178d:	83 c7 01             	add    $0x1,%edi
  801790:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801793:	75 c2                	jne    801757 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801795:	8b 45 10             	mov    0x10(%ebp),%eax
  801798:	eb 05                	jmp    80179f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80179a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80179f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017a2:	5b                   	pop    %ebx
  8017a3:	5e                   	pop    %esi
  8017a4:	5f                   	pop    %edi
  8017a5:	5d                   	pop    %ebp
  8017a6:	c3                   	ret    

008017a7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	57                   	push   %edi
  8017ab:	56                   	push   %esi
  8017ac:	53                   	push   %ebx
  8017ad:	83 ec 18             	sub    $0x18,%esp
  8017b0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017b3:	57                   	push   %edi
  8017b4:	e8 47 f6 ff ff       	call   800e00 <fd2data>
  8017b9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017c3:	eb 3d                	jmp    801802 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017c5:	85 db                	test   %ebx,%ebx
  8017c7:	74 04                	je     8017cd <devpipe_read+0x26>
				return i;
  8017c9:	89 d8                	mov    %ebx,%eax
  8017cb:	eb 44                	jmp    801811 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017cd:	89 f2                	mov    %esi,%edx
  8017cf:	89 f8                	mov    %edi,%eax
  8017d1:	e8 e5 fe ff ff       	call   8016bb <_pipeisclosed>
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	75 32                	jne    80180c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017da:	e8 01 f4 ff ff       	call   800be0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017df:	8b 06                	mov    (%esi),%eax
  8017e1:	3b 46 04             	cmp    0x4(%esi),%eax
  8017e4:	74 df                	je     8017c5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017e6:	99                   	cltd   
  8017e7:	c1 ea 1b             	shr    $0x1b,%edx
  8017ea:	01 d0                	add    %edx,%eax
  8017ec:	83 e0 1f             	and    $0x1f,%eax
  8017ef:	29 d0                	sub    %edx,%eax
  8017f1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017f9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017fc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ff:	83 c3 01             	add    $0x1,%ebx
  801802:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801805:	75 d8                	jne    8017df <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801807:	8b 45 10             	mov    0x10(%ebp),%eax
  80180a:	eb 05                	jmp    801811 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80180c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801811:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801814:	5b                   	pop    %ebx
  801815:	5e                   	pop    %esi
  801816:	5f                   	pop    %edi
  801817:	5d                   	pop    %ebp
  801818:	c3                   	ret    

00801819 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	56                   	push   %esi
  80181d:	53                   	push   %ebx
  80181e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801821:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801824:	50                   	push   %eax
  801825:	e8 ed f5 ff ff       	call   800e17 <fd_alloc>
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	89 c2                	mov    %eax,%edx
  80182f:	85 c0                	test   %eax,%eax
  801831:	0f 88 2c 01 00 00    	js     801963 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801837:	83 ec 04             	sub    $0x4,%esp
  80183a:	68 07 04 00 00       	push   $0x407
  80183f:	ff 75 f4             	pushl  -0xc(%ebp)
  801842:	6a 00                	push   $0x0
  801844:	e8 b6 f3 ff ff       	call   800bff <sys_page_alloc>
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	89 c2                	mov    %eax,%edx
  80184e:	85 c0                	test   %eax,%eax
  801850:	0f 88 0d 01 00 00    	js     801963 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801856:	83 ec 0c             	sub    $0xc,%esp
  801859:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80185c:	50                   	push   %eax
  80185d:	e8 b5 f5 ff ff       	call   800e17 <fd_alloc>
  801862:	89 c3                	mov    %eax,%ebx
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	85 c0                	test   %eax,%eax
  801869:	0f 88 e2 00 00 00    	js     801951 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80186f:	83 ec 04             	sub    $0x4,%esp
  801872:	68 07 04 00 00       	push   $0x407
  801877:	ff 75 f0             	pushl  -0x10(%ebp)
  80187a:	6a 00                	push   $0x0
  80187c:	e8 7e f3 ff ff       	call   800bff <sys_page_alloc>
  801881:	89 c3                	mov    %eax,%ebx
  801883:	83 c4 10             	add    $0x10,%esp
  801886:	85 c0                	test   %eax,%eax
  801888:	0f 88 c3 00 00 00    	js     801951 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80188e:	83 ec 0c             	sub    $0xc,%esp
  801891:	ff 75 f4             	pushl  -0xc(%ebp)
  801894:	e8 67 f5 ff ff       	call   800e00 <fd2data>
  801899:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80189b:	83 c4 0c             	add    $0xc,%esp
  80189e:	68 07 04 00 00       	push   $0x407
  8018a3:	50                   	push   %eax
  8018a4:	6a 00                	push   $0x0
  8018a6:	e8 54 f3 ff ff       	call   800bff <sys_page_alloc>
  8018ab:	89 c3                	mov    %eax,%ebx
  8018ad:	83 c4 10             	add    $0x10,%esp
  8018b0:	85 c0                	test   %eax,%eax
  8018b2:	0f 88 89 00 00 00    	js     801941 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b8:	83 ec 0c             	sub    $0xc,%esp
  8018bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8018be:	e8 3d f5 ff ff       	call   800e00 <fd2data>
  8018c3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018ca:	50                   	push   %eax
  8018cb:	6a 00                	push   $0x0
  8018cd:	56                   	push   %esi
  8018ce:	6a 00                	push   $0x0
  8018d0:	e8 6d f3 ff ff       	call   800c42 <sys_page_map>
  8018d5:	89 c3                	mov    %eax,%ebx
  8018d7:	83 c4 20             	add    $0x20,%esp
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	78 55                	js     801933 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018de:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ec:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018f3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801901:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801908:	83 ec 0c             	sub    $0xc,%esp
  80190b:	ff 75 f4             	pushl  -0xc(%ebp)
  80190e:	e8 dd f4 ff ff       	call   800df0 <fd2num>
  801913:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801916:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801918:	83 c4 04             	add    $0x4,%esp
  80191b:	ff 75 f0             	pushl  -0x10(%ebp)
  80191e:	e8 cd f4 ff ff       	call   800df0 <fd2num>
  801923:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801926:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	ba 00 00 00 00       	mov    $0x0,%edx
  801931:	eb 30                	jmp    801963 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801933:	83 ec 08             	sub    $0x8,%esp
  801936:	56                   	push   %esi
  801937:	6a 00                	push   $0x0
  801939:	e8 46 f3 ff ff       	call   800c84 <sys_page_unmap>
  80193e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801941:	83 ec 08             	sub    $0x8,%esp
  801944:	ff 75 f0             	pushl  -0x10(%ebp)
  801947:	6a 00                	push   $0x0
  801949:	e8 36 f3 ff ff       	call   800c84 <sys_page_unmap>
  80194e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	ff 75 f4             	pushl  -0xc(%ebp)
  801957:	6a 00                	push   $0x0
  801959:	e8 26 f3 ff ff       	call   800c84 <sys_page_unmap>
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801963:	89 d0                	mov    %edx,%eax
  801965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	5d                   	pop    %ebp
  80196b:	c3                   	ret    

0080196c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801972:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801975:	50                   	push   %eax
  801976:	ff 75 08             	pushl  0x8(%ebp)
  801979:	e8 e8 f4 ff ff       	call   800e66 <fd_lookup>
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	85 c0                	test   %eax,%eax
  801983:	78 18                	js     80199d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801985:	83 ec 0c             	sub    $0xc,%esp
  801988:	ff 75 f4             	pushl  -0xc(%ebp)
  80198b:	e8 70 f4 ff ff       	call   800e00 <fd2data>
	return _pipeisclosed(fd, p);
  801990:	89 c2                	mov    %eax,%edx
  801992:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801995:	e8 21 fd ff ff       	call   8016bb <_pipeisclosed>
  80199a:	83 c4 10             	add    $0x10,%esp
}
  80199d:	c9                   	leave  
  80199e:	c3                   	ret    

0080199f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a7:	5d                   	pop    %ebp
  8019a8:	c3                   	ret    

008019a9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019af:	68 b8 23 80 00       	push   $0x8023b8
  8019b4:	ff 75 0c             	pushl  0xc(%ebp)
  8019b7:	e8 c9 ed ff ff       	call   800785 <strcpy>
	return 0;
}
  8019bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c1:	c9                   	leave  
  8019c2:	c3                   	ret    

008019c3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	57                   	push   %edi
  8019c7:	56                   	push   %esi
  8019c8:	53                   	push   %ebx
  8019c9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019cf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019d4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019da:	eb 2d                	jmp    801a09 <devcons_write+0x46>
		m = n - tot;
  8019dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019df:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019e1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019e4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019e9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019ec:	83 ec 04             	sub    $0x4,%esp
  8019ef:	53                   	push   %ebx
  8019f0:	03 45 0c             	add    0xc(%ebp),%eax
  8019f3:	50                   	push   %eax
  8019f4:	57                   	push   %edi
  8019f5:	e8 1d ef ff ff       	call   800917 <memmove>
		sys_cputs(buf, m);
  8019fa:	83 c4 08             	add    $0x8,%esp
  8019fd:	53                   	push   %ebx
  8019fe:	57                   	push   %edi
  8019ff:	e8 3f f1 ff ff       	call   800b43 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a04:	01 de                	add    %ebx,%esi
  801a06:	83 c4 10             	add    $0x10,%esp
  801a09:	89 f0                	mov    %esi,%eax
  801a0b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a0e:	72 cc                	jb     8019dc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a13:	5b                   	pop    %ebx
  801a14:	5e                   	pop    %esi
  801a15:	5f                   	pop    %edi
  801a16:	5d                   	pop    %ebp
  801a17:	c3                   	ret    

00801a18 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	83 ec 08             	sub    $0x8,%esp
  801a1e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a23:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a27:	74 2a                	je     801a53 <devcons_read+0x3b>
  801a29:	eb 05                	jmp    801a30 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a2b:	e8 b0 f1 ff ff       	call   800be0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a30:	e8 2c f1 ff ff       	call   800b61 <sys_cgetc>
  801a35:	85 c0                	test   %eax,%eax
  801a37:	74 f2                	je     801a2b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	78 16                	js     801a53 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a3d:	83 f8 04             	cmp    $0x4,%eax
  801a40:	74 0c                	je     801a4e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a42:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a45:	88 02                	mov    %al,(%edx)
	return 1;
  801a47:	b8 01 00 00 00       	mov    $0x1,%eax
  801a4c:	eb 05                	jmp    801a53 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a4e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    

00801a55 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a61:	6a 01                	push   $0x1
  801a63:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a66:	50                   	push   %eax
  801a67:	e8 d7 f0 ff ff       	call   800b43 <sys_cputs>
}
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	c9                   	leave  
  801a70:	c3                   	ret    

00801a71 <getchar>:

int
getchar(void)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a77:	6a 01                	push   $0x1
  801a79:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a7c:	50                   	push   %eax
  801a7d:	6a 00                	push   $0x0
  801a7f:	e8 48 f6 ff ff       	call   8010cc <read>
	if (r < 0)
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	85 c0                	test   %eax,%eax
  801a89:	78 0f                	js     801a9a <getchar+0x29>
		return r;
	if (r < 1)
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	7e 06                	jle    801a95 <getchar+0x24>
		return -E_EOF;
	return c;
  801a8f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a93:	eb 05                	jmp    801a9a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a95:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a9a:	c9                   	leave  
  801a9b:	c3                   	ret    

00801a9c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aa2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa5:	50                   	push   %eax
  801aa6:	ff 75 08             	pushl  0x8(%ebp)
  801aa9:	e8 b8 f3 ff ff       	call   800e66 <fd_lookup>
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 11                	js     801ac6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801abe:	39 10                	cmp    %edx,(%eax)
  801ac0:	0f 94 c0             	sete   %al
  801ac3:	0f b6 c0             	movzbl %al,%eax
}
  801ac6:	c9                   	leave  
  801ac7:	c3                   	ret    

00801ac8 <opencons>:

int
opencons(void)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ace:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad1:	50                   	push   %eax
  801ad2:	e8 40 f3 ff ff       	call   800e17 <fd_alloc>
  801ad7:	83 c4 10             	add    $0x10,%esp
		return r;
  801ada:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801adc:	85 c0                	test   %eax,%eax
  801ade:	78 3e                	js     801b1e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ae0:	83 ec 04             	sub    $0x4,%esp
  801ae3:	68 07 04 00 00       	push   $0x407
  801ae8:	ff 75 f4             	pushl  -0xc(%ebp)
  801aeb:	6a 00                	push   $0x0
  801aed:	e8 0d f1 ff ff       	call   800bff <sys_page_alloc>
  801af2:	83 c4 10             	add    $0x10,%esp
		return r;
  801af5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801af7:	85 c0                	test   %eax,%eax
  801af9:	78 23                	js     801b1e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801afb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b04:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b09:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b10:	83 ec 0c             	sub    $0xc,%esp
  801b13:	50                   	push   %eax
  801b14:	e8 d7 f2 ff ff       	call   800df0 <fd2num>
  801b19:	89 c2                	mov    %eax,%edx
  801b1b:	83 c4 10             	add    $0x10,%esp
}
  801b1e:	89 d0                	mov    %edx,%eax
  801b20:	c9                   	leave  
  801b21:	c3                   	ret    

00801b22 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	56                   	push   %esi
  801b26:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b27:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b2a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b30:	e8 8c f0 ff ff       	call   800bc1 <sys_getenvid>
  801b35:	83 ec 0c             	sub    $0xc,%esp
  801b38:	ff 75 0c             	pushl  0xc(%ebp)
  801b3b:	ff 75 08             	pushl  0x8(%ebp)
  801b3e:	56                   	push   %esi
  801b3f:	50                   	push   %eax
  801b40:	68 c4 23 80 00       	push   $0x8023c4
  801b45:	e8 07 e6 ff ff       	call   800151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b4a:	83 c4 18             	add    $0x18,%esp
  801b4d:	53                   	push   %ebx
  801b4e:	ff 75 10             	pushl  0x10(%ebp)
  801b51:	e8 aa e5 ff ff       	call   800100 <vcprintf>
	cprintf("\n");
  801b56:	c7 04 24 b1 23 80 00 	movl   $0x8023b1,(%esp)
  801b5d:	e8 ef e5 ff ff       	call   800151 <cprintf>
  801b62:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b65:	cc                   	int3   
  801b66:	eb fd                	jmp    801b65 <_panic+0x43>

00801b68 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	56                   	push   %esi
  801b6c:	53                   	push   %ebx
  801b6d:	8b 75 08             	mov    0x8(%ebp),%esi
  801b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801b76:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801b78:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b7d:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801b80:	83 ec 0c             	sub    $0xc,%esp
  801b83:	50                   	push   %eax
  801b84:	e8 26 f2 ff ff       	call   800daf <sys_ipc_recv>
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	79 16                	jns    801ba6 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801b90:	85 f6                	test   %esi,%esi
  801b92:	74 06                	je     801b9a <ipc_recv+0x32>
			*from_env_store = 0;
  801b94:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801b9a:	85 db                	test   %ebx,%ebx
  801b9c:	74 2c                	je     801bca <ipc_recv+0x62>
			*perm_store = 0;
  801b9e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ba4:	eb 24                	jmp    801bca <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801ba6:	85 f6                	test   %esi,%esi
  801ba8:	74 0a                	je     801bb4 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801baa:	a1 08 40 80 00       	mov    0x804008,%eax
  801baf:	8b 40 74             	mov    0x74(%eax),%eax
  801bb2:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801bb4:	85 db                	test   %ebx,%ebx
  801bb6:	74 0a                	je     801bc2 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801bb8:	a1 08 40 80 00       	mov    0x804008,%eax
  801bbd:	8b 40 78             	mov    0x78(%eax),%eax
  801bc0:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801bc2:	a1 08 40 80 00       	mov    0x804008,%eax
  801bc7:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bcd:	5b                   	pop    %ebx
  801bce:	5e                   	pop    %esi
  801bcf:	5d                   	pop    %ebp
  801bd0:	c3                   	ret    

00801bd1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	57                   	push   %edi
  801bd5:	56                   	push   %esi
  801bd6:	53                   	push   %ebx
  801bd7:	83 ec 0c             	sub    $0xc,%esp
  801bda:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bdd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801be0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801be3:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801be5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bea:	0f 44 d8             	cmove  %eax,%ebx
  801bed:	eb 1e                	jmp    801c0d <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801bef:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bf2:	74 14                	je     801c08 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801bf4:	83 ec 04             	sub    $0x4,%esp
  801bf7:	68 e8 23 80 00       	push   $0x8023e8
  801bfc:	6a 44                	push   $0x44
  801bfe:	68 14 24 80 00       	push   $0x802414
  801c03:	e8 1a ff ff ff       	call   801b22 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801c08:	e8 d3 ef ff ff       	call   800be0 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c0d:	ff 75 14             	pushl  0x14(%ebp)
  801c10:	53                   	push   %ebx
  801c11:	56                   	push   %esi
  801c12:	57                   	push   %edi
  801c13:	e8 74 f1 ff ff       	call   800d8c <sys_ipc_try_send>
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	78 d0                	js     801bef <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801c1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c22:	5b                   	pop    %ebx
  801c23:	5e                   	pop    %esi
  801c24:	5f                   	pop    %edi
  801c25:	5d                   	pop    %ebp
  801c26:	c3                   	ret    

00801c27 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c2d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c32:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c35:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c3b:	8b 52 50             	mov    0x50(%edx),%edx
  801c3e:	39 ca                	cmp    %ecx,%edx
  801c40:	75 0d                	jne    801c4f <ipc_find_env+0x28>
			return envs[i].env_id;
  801c42:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c45:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c4a:	8b 40 48             	mov    0x48(%eax),%eax
  801c4d:	eb 0f                	jmp    801c5e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c4f:	83 c0 01             	add    $0x1,%eax
  801c52:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c57:	75 d9                	jne    801c32 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c59:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c5e:	5d                   	pop    %ebp
  801c5f:	c3                   	ret    

00801c60 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c66:	89 d0                	mov    %edx,%eax
  801c68:	c1 e8 16             	shr    $0x16,%eax
  801c6b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c72:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c77:	f6 c1 01             	test   $0x1,%cl
  801c7a:	74 1d                	je     801c99 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c7c:	c1 ea 0c             	shr    $0xc,%edx
  801c7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c86:	f6 c2 01             	test   $0x1,%dl
  801c89:	74 0e                	je     801c99 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c8b:	c1 ea 0c             	shr    $0xc,%edx
  801c8e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c95:	ef 
  801c96:	0f b7 c0             	movzwl %ax,%eax
}
  801c99:	5d                   	pop    %ebp
  801c9a:	c3                   	ret    
  801c9b:	66 90                	xchg   %ax,%ax
  801c9d:	66 90                	xchg   %ax,%ax
  801c9f:	90                   	nop

00801ca0 <__udivdi3>:
  801ca0:	55                   	push   %ebp
  801ca1:	57                   	push   %edi
  801ca2:	56                   	push   %esi
  801ca3:	53                   	push   %ebx
  801ca4:	83 ec 1c             	sub    $0x1c,%esp
  801ca7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801cab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801caf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801cb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cb7:	85 f6                	test   %esi,%esi
  801cb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cbd:	89 ca                	mov    %ecx,%edx
  801cbf:	89 f8                	mov    %edi,%eax
  801cc1:	75 3d                	jne    801d00 <__udivdi3+0x60>
  801cc3:	39 cf                	cmp    %ecx,%edi
  801cc5:	0f 87 c5 00 00 00    	ja     801d90 <__udivdi3+0xf0>
  801ccb:	85 ff                	test   %edi,%edi
  801ccd:	89 fd                	mov    %edi,%ebp
  801ccf:	75 0b                	jne    801cdc <__udivdi3+0x3c>
  801cd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cd6:	31 d2                	xor    %edx,%edx
  801cd8:	f7 f7                	div    %edi
  801cda:	89 c5                	mov    %eax,%ebp
  801cdc:	89 c8                	mov    %ecx,%eax
  801cde:	31 d2                	xor    %edx,%edx
  801ce0:	f7 f5                	div    %ebp
  801ce2:	89 c1                	mov    %eax,%ecx
  801ce4:	89 d8                	mov    %ebx,%eax
  801ce6:	89 cf                	mov    %ecx,%edi
  801ce8:	f7 f5                	div    %ebp
  801cea:	89 c3                	mov    %eax,%ebx
  801cec:	89 d8                	mov    %ebx,%eax
  801cee:	89 fa                	mov    %edi,%edx
  801cf0:	83 c4 1c             	add    $0x1c,%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5f                   	pop    %edi
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    
  801cf8:	90                   	nop
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	39 ce                	cmp    %ecx,%esi
  801d02:	77 74                	ja     801d78 <__udivdi3+0xd8>
  801d04:	0f bd fe             	bsr    %esi,%edi
  801d07:	83 f7 1f             	xor    $0x1f,%edi
  801d0a:	0f 84 98 00 00 00    	je     801da8 <__udivdi3+0x108>
  801d10:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d15:	89 f9                	mov    %edi,%ecx
  801d17:	89 c5                	mov    %eax,%ebp
  801d19:	29 fb                	sub    %edi,%ebx
  801d1b:	d3 e6                	shl    %cl,%esi
  801d1d:	89 d9                	mov    %ebx,%ecx
  801d1f:	d3 ed                	shr    %cl,%ebp
  801d21:	89 f9                	mov    %edi,%ecx
  801d23:	d3 e0                	shl    %cl,%eax
  801d25:	09 ee                	or     %ebp,%esi
  801d27:	89 d9                	mov    %ebx,%ecx
  801d29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d2d:	89 d5                	mov    %edx,%ebp
  801d2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d33:	d3 ed                	shr    %cl,%ebp
  801d35:	89 f9                	mov    %edi,%ecx
  801d37:	d3 e2                	shl    %cl,%edx
  801d39:	89 d9                	mov    %ebx,%ecx
  801d3b:	d3 e8                	shr    %cl,%eax
  801d3d:	09 c2                	or     %eax,%edx
  801d3f:	89 d0                	mov    %edx,%eax
  801d41:	89 ea                	mov    %ebp,%edx
  801d43:	f7 f6                	div    %esi
  801d45:	89 d5                	mov    %edx,%ebp
  801d47:	89 c3                	mov    %eax,%ebx
  801d49:	f7 64 24 0c          	mull   0xc(%esp)
  801d4d:	39 d5                	cmp    %edx,%ebp
  801d4f:	72 10                	jb     801d61 <__udivdi3+0xc1>
  801d51:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d55:	89 f9                	mov    %edi,%ecx
  801d57:	d3 e6                	shl    %cl,%esi
  801d59:	39 c6                	cmp    %eax,%esi
  801d5b:	73 07                	jae    801d64 <__udivdi3+0xc4>
  801d5d:	39 d5                	cmp    %edx,%ebp
  801d5f:	75 03                	jne    801d64 <__udivdi3+0xc4>
  801d61:	83 eb 01             	sub    $0x1,%ebx
  801d64:	31 ff                	xor    %edi,%edi
  801d66:	89 d8                	mov    %ebx,%eax
  801d68:	89 fa                	mov    %edi,%edx
  801d6a:	83 c4 1c             	add    $0x1c,%esp
  801d6d:	5b                   	pop    %ebx
  801d6e:	5e                   	pop    %esi
  801d6f:	5f                   	pop    %edi
  801d70:	5d                   	pop    %ebp
  801d71:	c3                   	ret    
  801d72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d78:	31 ff                	xor    %edi,%edi
  801d7a:	31 db                	xor    %ebx,%ebx
  801d7c:	89 d8                	mov    %ebx,%eax
  801d7e:	89 fa                	mov    %edi,%edx
  801d80:	83 c4 1c             	add    $0x1c,%esp
  801d83:	5b                   	pop    %ebx
  801d84:	5e                   	pop    %esi
  801d85:	5f                   	pop    %edi
  801d86:	5d                   	pop    %ebp
  801d87:	c3                   	ret    
  801d88:	90                   	nop
  801d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d90:	89 d8                	mov    %ebx,%eax
  801d92:	f7 f7                	div    %edi
  801d94:	31 ff                	xor    %edi,%edi
  801d96:	89 c3                	mov    %eax,%ebx
  801d98:	89 d8                	mov    %ebx,%eax
  801d9a:	89 fa                	mov    %edi,%edx
  801d9c:	83 c4 1c             	add    $0x1c,%esp
  801d9f:	5b                   	pop    %ebx
  801da0:	5e                   	pop    %esi
  801da1:	5f                   	pop    %edi
  801da2:	5d                   	pop    %ebp
  801da3:	c3                   	ret    
  801da4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da8:	39 ce                	cmp    %ecx,%esi
  801daa:	72 0c                	jb     801db8 <__udivdi3+0x118>
  801dac:	31 db                	xor    %ebx,%ebx
  801dae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801db2:	0f 87 34 ff ff ff    	ja     801cec <__udivdi3+0x4c>
  801db8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801dbd:	e9 2a ff ff ff       	jmp    801cec <__udivdi3+0x4c>
  801dc2:	66 90                	xchg   %ax,%ax
  801dc4:	66 90                	xchg   %ax,%ax
  801dc6:	66 90                	xchg   %ax,%ax
  801dc8:	66 90                	xchg   %ax,%ax
  801dca:	66 90                	xchg   %ax,%ax
  801dcc:	66 90                	xchg   %ax,%ax
  801dce:	66 90                	xchg   %ax,%ax

00801dd0 <__umoddi3>:
  801dd0:	55                   	push   %ebp
  801dd1:	57                   	push   %edi
  801dd2:	56                   	push   %esi
  801dd3:	53                   	push   %ebx
  801dd4:	83 ec 1c             	sub    $0x1c,%esp
  801dd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ddb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ddf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801de3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801de7:	85 d2                	test   %edx,%edx
  801de9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ded:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801df1:	89 f3                	mov    %esi,%ebx
  801df3:	89 3c 24             	mov    %edi,(%esp)
  801df6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dfa:	75 1c                	jne    801e18 <__umoddi3+0x48>
  801dfc:	39 f7                	cmp    %esi,%edi
  801dfe:	76 50                	jbe    801e50 <__umoddi3+0x80>
  801e00:	89 c8                	mov    %ecx,%eax
  801e02:	89 f2                	mov    %esi,%edx
  801e04:	f7 f7                	div    %edi
  801e06:	89 d0                	mov    %edx,%eax
  801e08:	31 d2                	xor    %edx,%edx
  801e0a:	83 c4 1c             	add    $0x1c,%esp
  801e0d:	5b                   	pop    %ebx
  801e0e:	5e                   	pop    %esi
  801e0f:	5f                   	pop    %edi
  801e10:	5d                   	pop    %ebp
  801e11:	c3                   	ret    
  801e12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e18:	39 f2                	cmp    %esi,%edx
  801e1a:	89 d0                	mov    %edx,%eax
  801e1c:	77 52                	ja     801e70 <__umoddi3+0xa0>
  801e1e:	0f bd ea             	bsr    %edx,%ebp
  801e21:	83 f5 1f             	xor    $0x1f,%ebp
  801e24:	75 5a                	jne    801e80 <__umoddi3+0xb0>
  801e26:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e2a:	0f 82 e0 00 00 00    	jb     801f10 <__umoddi3+0x140>
  801e30:	39 0c 24             	cmp    %ecx,(%esp)
  801e33:	0f 86 d7 00 00 00    	jbe    801f10 <__umoddi3+0x140>
  801e39:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e3d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e41:	83 c4 1c             	add    $0x1c,%esp
  801e44:	5b                   	pop    %ebx
  801e45:	5e                   	pop    %esi
  801e46:	5f                   	pop    %edi
  801e47:	5d                   	pop    %ebp
  801e48:	c3                   	ret    
  801e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e50:	85 ff                	test   %edi,%edi
  801e52:	89 fd                	mov    %edi,%ebp
  801e54:	75 0b                	jne    801e61 <__umoddi3+0x91>
  801e56:	b8 01 00 00 00       	mov    $0x1,%eax
  801e5b:	31 d2                	xor    %edx,%edx
  801e5d:	f7 f7                	div    %edi
  801e5f:	89 c5                	mov    %eax,%ebp
  801e61:	89 f0                	mov    %esi,%eax
  801e63:	31 d2                	xor    %edx,%edx
  801e65:	f7 f5                	div    %ebp
  801e67:	89 c8                	mov    %ecx,%eax
  801e69:	f7 f5                	div    %ebp
  801e6b:	89 d0                	mov    %edx,%eax
  801e6d:	eb 99                	jmp    801e08 <__umoddi3+0x38>
  801e6f:	90                   	nop
  801e70:	89 c8                	mov    %ecx,%eax
  801e72:	89 f2                	mov    %esi,%edx
  801e74:	83 c4 1c             	add    $0x1c,%esp
  801e77:	5b                   	pop    %ebx
  801e78:	5e                   	pop    %esi
  801e79:	5f                   	pop    %edi
  801e7a:	5d                   	pop    %ebp
  801e7b:	c3                   	ret    
  801e7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e80:	8b 34 24             	mov    (%esp),%esi
  801e83:	bf 20 00 00 00       	mov    $0x20,%edi
  801e88:	89 e9                	mov    %ebp,%ecx
  801e8a:	29 ef                	sub    %ebp,%edi
  801e8c:	d3 e0                	shl    %cl,%eax
  801e8e:	89 f9                	mov    %edi,%ecx
  801e90:	89 f2                	mov    %esi,%edx
  801e92:	d3 ea                	shr    %cl,%edx
  801e94:	89 e9                	mov    %ebp,%ecx
  801e96:	09 c2                	or     %eax,%edx
  801e98:	89 d8                	mov    %ebx,%eax
  801e9a:	89 14 24             	mov    %edx,(%esp)
  801e9d:	89 f2                	mov    %esi,%edx
  801e9f:	d3 e2                	shl    %cl,%edx
  801ea1:	89 f9                	mov    %edi,%ecx
  801ea3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ea7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801eab:	d3 e8                	shr    %cl,%eax
  801ead:	89 e9                	mov    %ebp,%ecx
  801eaf:	89 c6                	mov    %eax,%esi
  801eb1:	d3 e3                	shl    %cl,%ebx
  801eb3:	89 f9                	mov    %edi,%ecx
  801eb5:	89 d0                	mov    %edx,%eax
  801eb7:	d3 e8                	shr    %cl,%eax
  801eb9:	89 e9                	mov    %ebp,%ecx
  801ebb:	09 d8                	or     %ebx,%eax
  801ebd:	89 d3                	mov    %edx,%ebx
  801ebf:	89 f2                	mov    %esi,%edx
  801ec1:	f7 34 24             	divl   (%esp)
  801ec4:	89 d6                	mov    %edx,%esi
  801ec6:	d3 e3                	shl    %cl,%ebx
  801ec8:	f7 64 24 04          	mull   0x4(%esp)
  801ecc:	39 d6                	cmp    %edx,%esi
  801ece:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ed2:	89 d1                	mov    %edx,%ecx
  801ed4:	89 c3                	mov    %eax,%ebx
  801ed6:	72 08                	jb     801ee0 <__umoddi3+0x110>
  801ed8:	75 11                	jne    801eeb <__umoddi3+0x11b>
  801eda:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801ede:	73 0b                	jae    801eeb <__umoddi3+0x11b>
  801ee0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ee4:	1b 14 24             	sbb    (%esp),%edx
  801ee7:	89 d1                	mov    %edx,%ecx
  801ee9:	89 c3                	mov    %eax,%ebx
  801eeb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801eef:	29 da                	sub    %ebx,%edx
  801ef1:	19 ce                	sbb    %ecx,%esi
  801ef3:	89 f9                	mov    %edi,%ecx
  801ef5:	89 f0                	mov    %esi,%eax
  801ef7:	d3 e0                	shl    %cl,%eax
  801ef9:	89 e9                	mov    %ebp,%ecx
  801efb:	d3 ea                	shr    %cl,%edx
  801efd:	89 e9                	mov    %ebp,%ecx
  801eff:	d3 ee                	shr    %cl,%esi
  801f01:	09 d0                	or     %edx,%eax
  801f03:	89 f2                	mov    %esi,%edx
  801f05:	83 c4 1c             	add    $0x1c,%esp
  801f08:	5b                   	pop    %ebx
  801f09:	5e                   	pop    %esi
  801f0a:	5f                   	pop    %edi
  801f0b:	5d                   	pop    %ebp
  801f0c:	c3                   	ret    
  801f0d:	8d 76 00             	lea    0x0(%esi),%esi
  801f10:	29 f9                	sub    %edi,%ecx
  801f12:	19 d6                	sbb    %edx,%esi
  801f14:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f1c:	e9 18 ff ff ff       	jmp    801e39 <__umoddi3+0x69>
