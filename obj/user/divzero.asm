
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 40 1f 80 00       	push   $0x801f40
  800056:	e8 f8 00 00 00       	call   800153 <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80006b:	e8 53 0b 00 00       	call   800bc3 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 0c 40 80 00       	mov    %eax,0x80400c
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ac:	e8 0c 0f 00 00       	call   800fbd <close_all>
	sys_env_destroy(0);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	6a 00                	push   $0x0
  8000b6:	e8 c7 0a 00 00       	call   800b82 <sys_env_destroy>
}
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 04             	sub    $0x4,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 13                	mov    (%ebx),%edx
  8000cc:	8d 42 01             	lea    0x1(%edx),%eax
  8000cf:	89 03                	mov    %eax,(%ebx)
  8000d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dd:	75 1a                	jne    8000f9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	68 ff 00 00 00       	push   $0xff
  8000e7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ea:	50                   	push   %eax
  8000eb:	e8 55 0a 00 00       	call   800b45 <sys_cputs>
		b->idx = 0;
  8000f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800100:	c9                   	leave  
  800101:	c3                   	ret    

00800102 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800112:	00 00 00 
	b.cnt = 0;
  800115:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011f:	ff 75 0c             	pushl  0xc(%ebp)
  800122:	ff 75 08             	pushl  0x8(%ebp)
  800125:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	68 c0 00 80 00       	push   $0x8000c0
  800131:	e8 54 01 00 00       	call   80028a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800136:	83 c4 08             	add    $0x8,%esp
  800139:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800145:	50                   	push   %eax
  800146:	e8 fa 09 00 00       	call   800b45 <sys_cputs>

	return b.cnt;
}
  80014b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800159:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015c:	50                   	push   %eax
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	e8 9d ff ff ff       	call   800102 <vcprintf>
	va_end(ap);

	return cnt;
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 1c             	sub    $0x1c,%esp
  800170:	89 c7                	mov    %eax,%edi
  800172:	89 d6                	mov    %edx,%esi
  800174:	8b 45 08             	mov    0x8(%ebp),%eax
  800177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800180:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800183:	bb 00 00 00 00       	mov    $0x0,%ebx
  800188:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80018b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018e:	39 d3                	cmp    %edx,%ebx
  800190:	72 05                	jb     800197 <printnum+0x30>
  800192:	39 45 10             	cmp    %eax,0x10(%ebp)
  800195:	77 45                	ja     8001dc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	ff 75 18             	pushl  0x18(%ebp)
  80019d:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a3:	53                   	push   %ebx
  8001a4:	ff 75 10             	pushl  0x10(%ebp)
  8001a7:	83 ec 08             	sub    $0x8,%esp
  8001aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b6:	e8 e5 1a 00 00       	call   801ca0 <__udivdi3>
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	52                   	push   %edx
  8001bf:	50                   	push   %eax
  8001c0:	89 f2                	mov    %esi,%edx
  8001c2:	89 f8                	mov    %edi,%eax
  8001c4:	e8 9e ff ff ff       	call   800167 <printnum>
  8001c9:	83 c4 20             	add    $0x20,%esp
  8001cc:	eb 18                	jmp    8001e6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ce:	83 ec 08             	sub    $0x8,%esp
  8001d1:	56                   	push   %esi
  8001d2:	ff 75 18             	pushl  0x18(%ebp)
  8001d5:	ff d7                	call   *%edi
  8001d7:	83 c4 10             	add    $0x10,%esp
  8001da:	eb 03                	jmp    8001df <printnum+0x78>
  8001dc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001df:	83 eb 01             	sub    $0x1,%ebx
  8001e2:	85 db                	test   %ebx,%ebx
  8001e4:	7f e8                	jg     8001ce <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e6:	83 ec 08             	sub    $0x8,%esp
  8001e9:	56                   	push   %esi
  8001ea:	83 ec 04             	sub    $0x4,%esp
  8001ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f9:	e8 d2 1b 00 00       	call   801dd0 <__umoddi3>
  8001fe:	83 c4 14             	add    $0x14,%esp
  800201:	0f be 80 58 1f 80 00 	movsbl 0x801f58(%eax),%eax
  800208:	50                   	push   %eax
  800209:	ff d7                	call   *%edi
}
  80020b:	83 c4 10             	add    $0x10,%esp
  80020e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5f                   	pop    %edi
  800214:	5d                   	pop    %ebp
  800215:	c3                   	ret    

00800216 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800219:	83 fa 01             	cmp    $0x1,%edx
  80021c:	7e 0e                	jle    80022c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80021e:	8b 10                	mov    (%eax),%edx
  800220:	8d 4a 08             	lea    0x8(%edx),%ecx
  800223:	89 08                	mov    %ecx,(%eax)
  800225:	8b 02                	mov    (%edx),%eax
  800227:	8b 52 04             	mov    0x4(%edx),%edx
  80022a:	eb 22                	jmp    80024e <getuint+0x38>
	else if (lflag)
  80022c:	85 d2                	test   %edx,%edx
  80022e:	74 10                	je     800240 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800230:	8b 10                	mov    (%eax),%edx
  800232:	8d 4a 04             	lea    0x4(%edx),%ecx
  800235:	89 08                	mov    %ecx,(%eax)
  800237:	8b 02                	mov    (%edx),%eax
  800239:	ba 00 00 00 00       	mov    $0x0,%edx
  80023e:	eb 0e                	jmp    80024e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800240:	8b 10                	mov    (%eax),%edx
  800242:	8d 4a 04             	lea    0x4(%edx),%ecx
  800245:	89 08                	mov    %ecx,(%eax)
  800247:	8b 02                	mov    (%edx),%eax
  800249:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800256:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025a:	8b 10                	mov    (%eax),%edx
  80025c:	3b 50 04             	cmp    0x4(%eax),%edx
  80025f:	73 0a                	jae    80026b <sprintputch+0x1b>
		*b->buf++ = ch;
  800261:	8d 4a 01             	lea    0x1(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 45 08             	mov    0x8(%ebp),%eax
  800269:	88 02                	mov    %al,(%edx)
}
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    

0080026d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800273:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	ff 75 0c             	pushl  0xc(%ebp)
  80027d:	ff 75 08             	pushl  0x8(%ebp)
  800280:	e8 05 00 00 00       	call   80028a <vprintfmt>
	va_end(ap);
}
  800285:	83 c4 10             	add    $0x10,%esp
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 2c             	sub    $0x2c,%esp
  800293:	8b 75 08             	mov    0x8(%ebp),%esi
  800296:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800299:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029c:	eb 12                	jmp    8002b0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80029e:	85 c0                	test   %eax,%eax
  8002a0:	0f 84 38 04 00 00    	je     8006de <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8002a6:	83 ec 08             	sub    $0x8,%esp
  8002a9:	53                   	push   %ebx
  8002aa:	50                   	push   %eax
  8002ab:	ff d6                	call   *%esi
  8002ad:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b0:	83 c7 01             	add    $0x1,%edi
  8002b3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b7:	83 f8 25             	cmp    $0x25,%eax
  8002ba:	75 e2                	jne    80029e <vprintfmt+0x14>
  8002bc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002ce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002da:	eb 07                	jmp    8002e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8002df:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e3:	8d 47 01             	lea    0x1(%edi),%eax
  8002e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e9:	0f b6 07             	movzbl (%edi),%eax
  8002ec:	0f b6 c8             	movzbl %al,%ecx
  8002ef:	83 e8 23             	sub    $0x23,%eax
  8002f2:	3c 55                	cmp    $0x55,%al
  8002f4:	0f 87 c9 03 00 00    	ja     8006c3 <vprintfmt+0x439>
  8002fa:	0f b6 c0             	movzbl %al,%eax
  8002fd:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  800304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800307:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030b:	eb d6                	jmp    8002e3 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  80030d:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  800314:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800317:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  80031a:	eb 94                	jmp    8002b0 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  80031c:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  800323:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  800329:	eb 85                	jmp    8002b0 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  80032b:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  800332:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  800338:	e9 73 ff ff ff       	jmp    8002b0 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  80033d:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  800344:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  80034a:	e9 61 ff ff ff       	jmp    8002b0 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  80034f:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800356:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  80035c:	e9 4f ff ff ff       	jmp    8002b0 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  800361:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800368:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80036e:	e9 3d ff ff ff       	jmp    8002b0 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  800373:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  80037a:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  800380:	e9 2b ff ff ff       	jmp    8002b0 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  800385:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  80038c:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  800392:	e9 19 ff ff ff       	jmp    8002b0 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800397:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  80039e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8003a4:	e9 07 ff ff ff       	jmp    8002b0 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8003a9:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  8003b0:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8003b6:	e9 f5 fe ff ff       	jmp    8002b0 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003be:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003cd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003d0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d3:	83 fa 09             	cmp    $0x9,%edx
  8003d6:	77 3f                	ja     800417 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003db:	eb e9                	jmp    8003c6 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e6:	8b 00                	mov    (%eax),%eax
  8003e8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ee:	eb 2d                	jmp    80041d <vprintfmt+0x193>
  8003f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f3:	85 c0                	test   %eax,%eax
  8003f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fa:	0f 49 c8             	cmovns %eax,%ecx
  8003fd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800403:	e9 db fe ff ff       	jmp    8002e3 <vprintfmt+0x59>
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800412:	e9 cc fe ff ff       	jmp    8002e3 <vprintfmt+0x59>
  800417:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80041a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80041d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800421:	0f 89 bc fe ff ff    	jns    8002e3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800427:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80042a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800434:	e9 aa fe ff ff       	jmp    8002e3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800439:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043f:	e9 9f fe ff ff       	jmp    8002e3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8d 50 04             	lea    0x4(%eax),%edx
  80044a:	89 55 14             	mov    %edx,0x14(%ebp)
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	53                   	push   %ebx
  800451:	ff 30                	pushl  (%eax)
  800453:	ff d6                	call   *%esi
			break;
  800455:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80045b:	e9 50 fe ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	8b 00                	mov    (%eax),%eax
  80046b:	99                   	cltd   
  80046c:	31 d0                	xor    %edx,%eax
  80046e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800470:	83 f8 0f             	cmp    $0xf,%eax
  800473:	7f 0b                	jg     800480 <vprintfmt+0x1f6>
  800475:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  80047c:	85 d2                	test   %edx,%edx
  80047e:	75 18                	jne    800498 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  800480:	50                   	push   %eax
  800481:	68 70 1f 80 00       	push   $0x801f70
  800486:	53                   	push   %ebx
  800487:	56                   	push   %esi
  800488:	e8 e0 fd ff ff       	call   80026d <printfmt>
  80048d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800493:	e9 18 fe ff ff       	jmp    8002b0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800498:	52                   	push   %edx
  800499:	68 31 23 80 00       	push   $0x802331
  80049e:	53                   	push   %ebx
  80049f:	56                   	push   %esi
  8004a0:	e8 c8 fd ff ff       	call   80026d <printfmt>
  8004a5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ab:	e9 00 fe ff ff       	jmp    8002b0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8d 50 04             	lea    0x4(%eax),%edx
  8004b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004bb:	85 ff                	test   %edi,%edi
  8004bd:	b8 69 1f 80 00       	mov    $0x801f69,%eax
  8004c2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c9:	0f 8e 94 00 00 00    	jle    800563 <vprintfmt+0x2d9>
  8004cf:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d3:	0f 84 98 00 00 00    	je     800571 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	ff 75 d0             	pushl  -0x30(%ebp)
  8004df:	57                   	push   %edi
  8004e0:	e8 81 02 00 00       	call   800766 <strnlen>
  8004e5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e8:	29 c1                	sub    %eax,%ecx
  8004ea:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004ed:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004f0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004fa:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fc:	eb 0f                	jmp    80050d <vprintfmt+0x283>
					putch(padc, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	53                   	push   %ebx
  800502:	ff 75 e0             	pushl  -0x20(%ebp)
  800505:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800507:	83 ef 01             	sub    $0x1,%edi
  80050a:	83 c4 10             	add    $0x10,%esp
  80050d:	85 ff                	test   %edi,%edi
  80050f:	7f ed                	jg     8004fe <vprintfmt+0x274>
  800511:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800514:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800517:	85 c9                	test   %ecx,%ecx
  800519:	b8 00 00 00 00       	mov    $0x0,%eax
  80051e:	0f 49 c1             	cmovns %ecx,%eax
  800521:	29 c1                	sub    %eax,%ecx
  800523:	89 75 08             	mov    %esi,0x8(%ebp)
  800526:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800529:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052c:	89 cb                	mov    %ecx,%ebx
  80052e:	eb 4d                	jmp    80057d <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800530:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800534:	74 1b                	je     800551 <vprintfmt+0x2c7>
  800536:	0f be c0             	movsbl %al,%eax
  800539:	83 e8 20             	sub    $0x20,%eax
  80053c:	83 f8 5e             	cmp    $0x5e,%eax
  80053f:	76 10                	jbe    800551 <vprintfmt+0x2c7>
					putch('?', putdat);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	ff 75 0c             	pushl  0xc(%ebp)
  800547:	6a 3f                	push   $0x3f
  800549:	ff 55 08             	call   *0x8(%ebp)
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	eb 0d                	jmp    80055e <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	ff 75 0c             	pushl  0xc(%ebp)
  800557:	52                   	push   %edx
  800558:	ff 55 08             	call   *0x8(%ebp)
  80055b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055e:	83 eb 01             	sub    $0x1,%ebx
  800561:	eb 1a                	jmp    80057d <vprintfmt+0x2f3>
  800563:	89 75 08             	mov    %esi,0x8(%ebp)
  800566:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800569:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056f:	eb 0c                	jmp    80057d <vprintfmt+0x2f3>
  800571:	89 75 08             	mov    %esi,0x8(%ebp)
  800574:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800577:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057d:	83 c7 01             	add    $0x1,%edi
  800580:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800584:	0f be d0             	movsbl %al,%edx
  800587:	85 d2                	test   %edx,%edx
  800589:	74 23                	je     8005ae <vprintfmt+0x324>
  80058b:	85 f6                	test   %esi,%esi
  80058d:	78 a1                	js     800530 <vprintfmt+0x2a6>
  80058f:	83 ee 01             	sub    $0x1,%esi
  800592:	79 9c                	jns    800530 <vprintfmt+0x2a6>
  800594:	89 df                	mov    %ebx,%edi
  800596:	8b 75 08             	mov    0x8(%ebp),%esi
  800599:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059c:	eb 18                	jmp    8005b6 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	53                   	push   %ebx
  8005a2:	6a 20                	push   $0x20
  8005a4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a6:	83 ef 01             	sub    $0x1,%edi
  8005a9:	83 c4 10             	add    $0x10,%esp
  8005ac:	eb 08                	jmp    8005b6 <vprintfmt+0x32c>
  8005ae:	89 df                	mov    %ebx,%edi
  8005b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b6:	85 ff                	test   %edi,%edi
  8005b8:	7f e4                	jg     80059e <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bd:	e9 ee fc ff ff       	jmp    8002b0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c2:	83 fa 01             	cmp    $0x1,%edx
  8005c5:	7e 16                	jle    8005dd <vprintfmt+0x353>
		return va_arg(*ap, long long);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 50 08             	lea    0x8(%eax),%edx
  8005cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d0:	8b 50 04             	mov    0x4(%eax),%edx
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005db:	eb 32                	jmp    80060f <vprintfmt+0x385>
	else if (lflag)
  8005dd:	85 d2                	test   %edx,%edx
  8005df:	74 18                	je     8005f9 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8d 50 04             	lea    0x4(%eax),%edx
  8005e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ea:	8b 00                	mov    (%eax),%eax
  8005ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ef:	89 c1                	mov    %eax,%ecx
  8005f1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f7:	eb 16                	jmp    80060f <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 50 04             	lea    0x4(%eax),%edx
  8005ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800602:	8b 00                	mov    (%eax),%eax
  800604:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800607:	89 c1                	mov    %eax,%ecx
  800609:	c1 f9 1f             	sar    $0x1f,%ecx
  80060c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800612:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800615:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80061a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061e:	79 6f                	jns    80068f <vprintfmt+0x405>
				putch('-', putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	53                   	push   %ebx
  800624:	6a 2d                	push   $0x2d
  800626:	ff d6                	call   *%esi
				num = -(long long) num;
  800628:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80062b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80062e:	f7 d8                	neg    %eax
  800630:	83 d2 00             	adc    $0x0,%edx
  800633:	f7 da                	neg    %edx
  800635:	83 c4 10             	add    $0x10,%esp
  800638:	eb 55                	jmp    80068f <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063a:	8d 45 14             	lea    0x14(%ebp),%eax
  80063d:	e8 d4 fb ff ff       	call   800216 <getuint>
			base = 10;
  800642:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800647:	eb 46                	jmp    80068f <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800649:	8d 45 14             	lea    0x14(%ebp),%eax
  80064c:	e8 c5 fb ff ff       	call   800216 <getuint>
			base = 8;
  800651:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800656:	eb 37                	jmp    80068f <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	53                   	push   %ebx
  80065c:	6a 30                	push   $0x30
  80065e:	ff d6                	call   *%esi
			putch('x', putdat);
  800660:	83 c4 08             	add    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	6a 78                	push   $0x78
  800666:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8d 50 04             	lea    0x4(%eax),%edx
  80066e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800671:	8b 00                	mov    (%eax),%eax
  800673:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800678:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067b:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800680:	eb 0d                	jmp    80068f <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800682:	8d 45 14             	lea    0x14(%ebp),%eax
  800685:	e8 8c fb ff ff       	call   800216 <getuint>
			base = 16;
  80068a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80068f:	83 ec 0c             	sub    $0xc,%esp
  800692:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800696:	51                   	push   %ecx
  800697:	ff 75 e0             	pushl  -0x20(%ebp)
  80069a:	57                   	push   %edi
  80069b:	52                   	push   %edx
  80069c:	50                   	push   %eax
  80069d:	89 da                	mov    %ebx,%edx
  80069f:	89 f0                	mov    %esi,%eax
  8006a1:	e8 c1 fa ff ff       	call   800167 <printnum>
			break;
  8006a6:	83 c4 20             	add    $0x20,%esp
  8006a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ac:	e9 ff fb ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	51                   	push   %ecx
  8006b6:	ff d6                	call   *%esi
			break;
  8006b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006be:	e9 ed fb ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	6a 25                	push   $0x25
  8006c9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	eb 03                	jmp    8006d3 <vprintfmt+0x449>
  8006d0:	83 ef 01             	sub    $0x1,%edi
  8006d3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d7:	75 f7                	jne    8006d0 <vprintfmt+0x446>
  8006d9:	e9 d2 fb ff ff       	jmp    8002b0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e1:	5b                   	pop    %ebx
  8006e2:	5e                   	pop    %esi
  8006e3:	5f                   	pop    %edi
  8006e4:	5d                   	pop    %ebp
  8006e5:	c3                   	ret    

008006e6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	83 ec 18             	sub    $0x18,%esp
  8006ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800703:	85 c0                	test   %eax,%eax
  800705:	74 26                	je     80072d <vsnprintf+0x47>
  800707:	85 d2                	test   %edx,%edx
  800709:	7e 22                	jle    80072d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80070b:	ff 75 14             	pushl  0x14(%ebp)
  80070e:	ff 75 10             	pushl  0x10(%ebp)
  800711:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800714:	50                   	push   %eax
  800715:	68 50 02 80 00       	push   $0x800250
  80071a:	e8 6b fb ff ff       	call   80028a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800722:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800725:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	eb 05                	jmp    800732 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80072d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800732:	c9                   	leave  
  800733:	c3                   	ret    

00800734 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80073a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073d:	50                   	push   %eax
  80073e:	ff 75 10             	pushl  0x10(%ebp)
  800741:	ff 75 0c             	pushl  0xc(%ebp)
  800744:	ff 75 08             	pushl  0x8(%ebp)
  800747:	e8 9a ff ff ff       	call   8006e6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80074c:	c9                   	leave  
  80074d:	c3                   	ret    

0080074e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800754:	b8 00 00 00 00       	mov    $0x0,%eax
  800759:	eb 03                	jmp    80075e <strlen+0x10>
		n++;
  80075b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800762:	75 f7                	jne    80075b <strlen+0xd>
		n++;
	return n;
}
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076f:	ba 00 00 00 00       	mov    $0x0,%edx
  800774:	eb 03                	jmp    800779 <strnlen+0x13>
		n++;
  800776:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800779:	39 c2                	cmp    %eax,%edx
  80077b:	74 08                	je     800785 <strnlen+0x1f>
  80077d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800781:	75 f3                	jne    800776 <strnlen+0x10>
  800783:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	53                   	push   %ebx
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800791:	89 c2                	mov    %eax,%edx
  800793:	83 c2 01             	add    $0x1,%edx
  800796:	83 c1 01             	add    $0x1,%ecx
  800799:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80079d:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a0:	84 db                	test   %bl,%bl
  8007a2:	75 ef                	jne    800793 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a4:	5b                   	pop    %ebx
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ae:	53                   	push   %ebx
  8007af:	e8 9a ff ff ff       	call   80074e <strlen>
  8007b4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ba:	01 d8                	add    %ebx,%eax
  8007bc:	50                   	push   %eax
  8007bd:	e8 c5 ff ff ff       	call   800787 <strcpy>
	return dst;
}
  8007c2:	89 d8                	mov    %ebx,%eax
  8007c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	56                   	push   %esi
  8007cd:	53                   	push   %ebx
  8007ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d4:	89 f3                	mov    %esi,%ebx
  8007d6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d9:	89 f2                	mov    %esi,%edx
  8007db:	eb 0f                	jmp    8007ec <strncpy+0x23>
		*dst++ = *src;
  8007dd:	83 c2 01             	add    $0x1,%edx
  8007e0:	0f b6 01             	movzbl (%ecx),%eax
  8007e3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e6:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ec:	39 da                	cmp    %ebx,%edx
  8007ee:	75 ed                	jne    8007dd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f0:	89 f0                	mov    %esi,%eax
  8007f2:	5b                   	pop    %ebx
  8007f3:	5e                   	pop    %esi
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	56                   	push   %esi
  8007fa:	53                   	push   %ebx
  8007fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800801:	8b 55 10             	mov    0x10(%ebp),%edx
  800804:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800806:	85 d2                	test   %edx,%edx
  800808:	74 21                	je     80082b <strlcpy+0x35>
  80080a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080e:	89 f2                	mov    %esi,%edx
  800810:	eb 09                	jmp    80081b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800812:	83 c2 01             	add    $0x1,%edx
  800815:	83 c1 01             	add    $0x1,%ecx
  800818:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80081b:	39 c2                	cmp    %eax,%edx
  80081d:	74 09                	je     800828 <strlcpy+0x32>
  80081f:	0f b6 19             	movzbl (%ecx),%ebx
  800822:	84 db                	test   %bl,%bl
  800824:	75 ec                	jne    800812 <strlcpy+0x1c>
  800826:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800828:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80082b:	29 f0                	sub    %esi,%eax
}
  80082d:	5b                   	pop    %ebx
  80082e:	5e                   	pop    %esi
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800837:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083a:	eb 06                	jmp    800842 <strcmp+0x11>
		p++, q++;
  80083c:	83 c1 01             	add    $0x1,%ecx
  80083f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800842:	0f b6 01             	movzbl (%ecx),%eax
  800845:	84 c0                	test   %al,%al
  800847:	74 04                	je     80084d <strcmp+0x1c>
  800849:	3a 02                	cmp    (%edx),%al
  80084b:	74 ef                	je     80083c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80084d:	0f b6 c0             	movzbl %al,%eax
  800850:	0f b6 12             	movzbl (%edx),%edx
  800853:	29 d0                	sub    %edx,%eax
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800861:	89 c3                	mov    %eax,%ebx
  800863:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800866:	eb 06                	jmp    80086e <strncmp+0x17>
		n--, p++, q++;
  800868:	83 c0 01             	add    $0x1,%eax
  80086b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80086e:	39 d8                	cmp    %ebx,%eax
  800870:	74 15                	je     800887 <strncmp+0x30>
  800872:	0f b6 08             	movzbl (%eax),%ecx
  800875:	84 c9                	test   %cl,%cl
  800877:	74 04                	je     80087d <strncmp+0x26>
  800879:	3a 0a                	cmp    (%edx),%cl
  80087b:	74 eb                	je     800868 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087d:	0f b6 00             	movzbl (%eax),%eax
  800880:	0f b6 12             	movzbl (%edx),%edx
  800883:	29 d0                	sub    %edx,%eax
  800885:	eb 05                	jmp    80088c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800887:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80088c:	5b                   	pop    %ebx
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800899:	eb 07                	jmp    8008a2 <strchr+0x13>
		if (*s == c)
  80089b:	38 ca                	cmp    %cl,%dl
  80089d:	74 0f                	je     8008ae <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80089f:	83 c0 01             	add    $0x1,%eax
  8008a2:	0f b6 10             	movzbl (%eax),%edx
  8008a5:	84 d2                	test   %dl,%dl
  8008a7:	75 f2                	jne    80089b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ba:	eb 03                	jmp    8008bf <strfind+0xf>
  8008bc:	83 c0 01             	add    $0x1,%eax
  8008bf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c2:	38 ca                	cmp    %cl,%dl
  8008c4:	74 04                	je     8008ca <strfind+0x1a>
  8008c6:	84 d2                	test   %dl,%dl
  8008c8:	75 f2                	jne    8008bc <strfind+0xc>
			break;
	return (char *) s;
}
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	57                   	push   %edi
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
  8008d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d8:	85 c9                	test   %ecx,%ecx
  8008da:	74 36                	je     800912 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008dc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e2:	75 28                	jne    80090c <memset+0x40>
  8008e4:	f6 c1 03             	test   $0x3,%cl
  8008e7:	75 23                	jne    80090c <memset+0x40>
		c &= 0xFF;
  8008e9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ed:	89 d3                	mov    %edx,%ebx
  8008ef:	c1 e3 08             	shl    $0x8,%ebx
  8008f2:	89 d6                	mov    %edx,%esi
  8008f4:	c1 e6 18             	shl    $0x18,%esi
  8008f7:	89 d0                	mov    %edx,%eax
  8008f9:	c1 e0 10             	shl    $0x10,%eax
  8008fc:	09 f0                	or     %esi,%eax
  8008fe:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800900:	89 d8                	mov    %ebx,%eax
  800902:	09 d0                	or     %edx,%eax
  800904:	c1 e9 02             	shr    $0x2,%ecx
  800907:	fc                   	cld    
  800908:	f3 ab                	rep stos %eax,%es:(%edi)
  80090a:	eb 06                	jmp    800912 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090f:	fc                   	cld    
  800910:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800912:	89 f8                	mov    %edi,%eax
  800914:	5b                   	pop    %ebx
  800915:	5e                   	pop    %esi
  800916:	5f                   	pop    %edi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	57                   	push   %edi
  80091d:	56                   	push   %esi
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	8b 75 0c             	mov    0xc(%ebp),%esi
  800924:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800927:	39 c6                	cmp    %eax,%esi
  800929:	73 35                	jae    800960 <memmove+0x47>
  80092b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092e:	39 d0                	cmp    %edx,%eax
  800930:	73 2e                	jae    800960 <memmove+0x47>
		s += n;
		d += n;
  800932:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800935:	89 d6                	mov    %edx,%esi
  800937:	09 fe                	or     %edi,%esi
  800939:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093f:	75 13                	jne    800954 <memmove+0x3b>
  800941:	f6 c1 03             	test   $0x3,%cl
  800944:	75 0e                	jne    800954 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800946:	83 ef 04             	sub    $0x4,%edi
  800949:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094c:	c1 e9 02             	shr    $0x2,%ecx
  80094f:	fd                   	std    
  800950:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800952:	eb 09                	jmp    80095d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800954:	83 ef 01             	sub    $0x1,%edi
  800957:	8d 72 ff             	lea    -0x1(%edx),%esi
  80095a:	fd                   	std    
  80095b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095d:	fc                   	cld    
  80095e:	eb 1d                	jmp    80097d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800960:	89 f2                	mov    %esi,%edx
  800962:	09 c2                	or     %eax,%edx
  800964:	f6 c2 03             	test   $0x3,%dl
  800967:	75 0f                	jne    800978 <memmove+0x5f>
  800969:	f6 c1 03             	test   $0x3,%cl
  80096c:	75 0a                	jne    800978 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80096e:	c1 e9 02             	shr    $0x2,%ecx
  800971:	89 c7                	mov    %eax,%edi
  800973:	fc                   	cld    
  800974:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800976:	eb 05                	jmp    80097d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800978:	89 c7                	mov    %eax,%edi
  80097a:	fc                   	cld    
  80097b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097d:	5e                   	pop    %esi
  80097e:	5f                   	pop    %edi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800984:	ff 75 10             	pushl  0x10(%ebp)
  800987:	ff 75 0c             	pushl  0xc(%ebp)
  80098a:	ff 75 08             	pushl  0x8(%ebp)
  80098d:	e8 87 ff ff ff       	call   800919 <memmove>
}
  800992:	c9                   	leave  
  800993:	c3                   	ret    

00800994 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099f:	89 c6                	mov    %eax,%esi
  8009a1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a4:	eb 1a                	jmp    8009c0 <memcmp+0x2c>
		if (*s1 != *s2)
  8009a6:	0f b6 08             	movzbl (%eax),%ecx
  8009a9:	0f b6 1a             	movzbl (%edx),%ebx
  8009ac:	38 d9                	cmp    %bl,%cl
  8009ae:	74 0a                	je     8009ba <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009b0:	0f b6 c1             	movzbl %cl,%eax
  8009b3:	0f b6 db             	movzbl %bl,%ebx
  8009b6:	29 d8                	sub    %ebx,%eax
  8009b8:	eb 0f                	jmp    8009c9 <memcmp+0x35>
		s1++, s2++;
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c0:	39 f0                	cmp    %esi,%eax
  8009c2:	75 e2                	jne    8009a6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c9:	5b                   	pop    %ebx
  8009ca:	5e                   	pop    %esi
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	53                   	push   %ebx
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009d4:	89 c1                	mov    %eax,%ecx
  8009d6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009dd:	eb 0a                	jmp    8009e9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009df:	0f b6 10             	movzbl (%eax),%edx
  8009e2:	39 da                	cmp    %ebx,%edx
  8009e4:	74 07                	je     8009ed <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e6:	83 c0 01             	add    $0x1,%eax
  8009e9:	39 c8                	cmp    %ecx,%eax
  8009eb:	72 f2                	jb     8009df <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ed:	5b                   	pop    %ebx
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	57                   	push   %edi
  8009f4:	56                   	push   %esi
  8009f5:	53                   	push   %ebx
  8009f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fc:	eb 03                	jmp    800a01 <strtol+0x11>
		s++;
  8009fe:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a01:	0f b6 01             	movzbl (%ecx),%eax
  800a04:	3c 20                	cmp    $0x20,%al
  800a06:	74 f6                	je     8009fe <strtol+0xe>
  800a08:	3c 09                	cmp    $0x9,%al
  800a0a:	74 f2                	je     8009fe <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a0c:	3c 2b                	cmp    $0x2b,%al
  800a0e:	75 0a                	jne    800a1a <strtol+0x2a>
		s++;
  800a10:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a13:	bf 00 00 00 00       	mov    $0x0,%edi
  800a18:	eb 11                	jmp    800a2b <strtol+0x3b>
  800a1a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a1f:	3c 2d                	cmp    $0x2d,%al
  800a21:	75 08                	jne    800a2b <strtol+0x3b>
		s++, neg = 1;
  800a23:	83 c1 01             	add    $0x1,%ecx
  800a26:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a31:	75 15                	jne    800a48 <strtol+0x58>
  800a33:	80 39 30             	cmpb   $0x30,(%ecx)
  800a36:	75 10                	jne    800a48 <strtol+0x58>
  800a38:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3c:	75 7c                	jne    800aba <strtol+0xca>
		s += 2, base = 16;
  800a3e:	83 c1 02             	add    $0x2,%ecx
  800a41:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a46:	eb 16                	jmp    800a5e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a48:	85 db                	test   %ebx,%ebx
  800a4a:	75 12                	jne    800a5e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a51:	80 39 30             	cmpb   $0x30,(%ecx)
  800a54:	75 08                	jne    800a5e <strtol+0x6e>
		s++, base = 8;
  800a56:	83 c1 01             	add    $0x1,%ecx
  800a59:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a63:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a66:	0f b6 11             	movzbl (%ecx),%edx
  800a69:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a6c:	89 f3                	mov    %esi,%ebx
  800a6e:	80 fb 09             	cmp    $0x9,%bl
  800a71:	77 08                	ja     800a7b <strtol+0x8b>
			dig = *s - '0';
  800a73:	0f be d2             	movsbl %dl,%edx
  800a76:	83 ea 30             	sub    $0x30,%edx
  800a79:	eb 22                	jmp    800a9d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a7b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a7e:	89 f3                	mov    %esi,%ebx
  800a80:	80 fb 19             	cmp    $0x19,%bl
  800a83:	77 08                	ja     800a8d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a85:	0f be d2             	movsbl %dl,%edx
  800a88:	83 ea 57             	sub    $0x57,%edx
  800a8b:	eb 10                	jmp    800a9d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a8d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a90:	89 f3                	mov    %esi,%ebx
  800a92:	80 fb 19             	cmp    $0x19,%bl
  800a95:	77 16                	ja     800aad <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a97:	0f be d2             	movsbl %dl,%edx
  800a9a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a9d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa0:	7d 0b                	jge    800aad <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aa2:	83 c1 01             	add    $0x1,%ecx
  800aa5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aab:	eb b9                	jmp    800a66 <strtol+0x76>

	if (endptr)
  800aad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab1:	74 0d                	je     800ac0 <strtol+0xd0>
		*endptr = (char *) s;
  800ab3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab6:	89 0e                	mov    %ecx,(%esi)
  800ab8:	eb 06                	jmp    800ac0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aba:	85 db                	test   %ebx,%ebx
  800abc:	74 98                	je     800a56 <strtol+0x66>
  800abe:	eb 9e                	jmp    800a5e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ac0:	89 c2                	mov    %eax,%edx
  800ac2:	f7 da                	neg    %edx
  800ac4:	85 ff                	test   %edi,%edi
  800ac6:	0f 45 c2             	cmovne %edx,%eax
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5e                   	pop    %esi
  800acb:	5f                   	pop    %edi
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	57                   	push   %edi
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
  800ad4:	83 ec 04             	sub    $0x4,%esp
  800ad7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800ada:	57                   	push   %edi
  800adb:	e8 6e fc ff ff       	call   80074e <strlen>
  800ae0:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800ae3:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800ae6:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800aeb:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800af0:	eb 46                	jmp    800b38 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800af2:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800af6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800af9:	80 f9 09             	cmp    $0x9,%cl
  800afc:	77 08                	ja     800b06 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800afe:	0f be d2             	movsbl %dl,%edx
  800b01:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b04:	eb 27                	jmp    800b2d <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800b06:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800b09:	80 f9 05             	cmp    $0x5,%cl
  800b0c:	77 08                	ja     800b16 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800b0e:	0f be d2             	movsbl %dl,%edx
  800b11:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800b14:	eb 17                	jmp    800b2d <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800b16:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800b19:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800b1c:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800b21:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800b25:	77 06                	ja     800b2d <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800b27:	0f be d2             	movsbl %dl,%edx
  800b2a:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800b2d:	0f af ce             	imul   %esi,%ecx
  800b30:	01 c8                	add    %ecx,%eax
		base *= 16;
  800b32:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b35:	83 eb 01             	sub    $0x1,%ebx
  800b38:	83 fb 01             	cmp    $0x1,%ebx
  800b3b:	7f b5                	jg     800af2 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800b3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
  800b56:	89 c3                	mov    %eax,%ebx
  800b58:	89 c7                	mov    %eax,%edi
  800b5a:	89 c6                	mov    %eax,%esi
  800b5c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5f                   	pop    %edi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b69:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b73:	89 d1                	mov    %edx,%ecx
  800b75:	89 d3                	mov    %edx,%ebx
  800b77:	89 d7                	mov    %edx,%edi
  800b79:	89 d6                	mov    %edx,%esi
  800b7b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b90:	b8 03 00 00 00       	mov    $0x3,%eax
  800b95:	8b 55 08             	mov    0x8(%ebp),%edx
  800b98:	89 cb                	mov    %ecx,%ebx
  800b9a:	89 cf                	mov    %ecx,%edi
  800b9c:	89 ce                	mov    %ecx,%esi
  800b9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba0:	85 c0                	test   %eax,%eax
  800ba2:	7e 17                	jle    800bbb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba4:	83 ec 0c             	sub    $0xc,%esp
  800ba7:	50                   	push   %eax
  800ba8:	6a 03                	push   $0x3
  800baa:	68 5f 22 80 00       	push   $0x80225f
  800baf:	6a 23                	push   $0x23
  800bb1:	68 7c 22 80 00       	push   $0x80227c
  800bb6:	e8 69 0f 00 00       	call   801b24 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bce:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd3:	89 d1                	mov    %edx,%ecx
  800bd5:	89 d3                	mov    %edx,%ebx
  800bd7:	89 d7                	mov    %edx,%edi
  800bd9:	89 d6                	mov    %edx,%esi
  800bdb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_yield>:

void
sys_yield(void)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bed:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf2:	89 d1                	mov    %edx,%ecx
  800bf4:	89 d3                	mov    %edx,%ebx
  800bf6:	89 d7                	mov    %edx,%edi
  800bf8:	89 d6                	mov    %edx,%esi
  800bfa:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	be 00 00 00 00       	mov    $0x0,%esi
  800c0f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1d:	89 f7                	mov    %esi,%edi
  800c1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7e 17                	jle    800c3c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c25:	83 ec 0c             	sub    $0xc,%esp
  800c28:	50                   	push   %eax
  800c29:	6a 04                	push   $0x4
  800c2b:	68 5f 22 80 00       	push   $0x80225f
  800c30:	6a 23                	push   $0x23
  800c32:	68 7c 22 80 00       	push   $0x80227c
  800c37:	e8 e8 0e 00 00       	call   801b24 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	b8 05 00 00 00       	mov    $0x5,%eax
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5e:	8b 75 18             	mov    0x18(%ebp),%esi
  800c61:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c63:	85 c0                	test   %eax,%eax
  800c65:	7e 17                	jle    800c7e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	50                   	push   %eax
  800c6b:	6a 05                	push   $0x5
  800c6d:	68 5f 22 80 00       	push   $0x80225f
  800c72:	6a 23                	push   $0x23
  800c74:	68 7c 22 80 00       	push   $0x80227c
  800c79:	e8 a6 0e 00 00       	call   801b24 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c94:	b8 06 00 00 00       	mov    $0x6,%eax
  800c99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9f:	89 df                	mov    %ebx,%edi
  800ca1:	89 de                	mov    %ebx,%esi
  800ca3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	7e 17                	jle    800cc0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	83 ec 0c             	sub    $0xc,%esp
  800cac:	50                   	push   %eax
  800cad:	6a 06                	push   $0x6
  800caf:	68 5f 22 80 00       	push   $0x80225f
  800cb4:	6a 23                	push   $0x23
  800cb6:	68 7c 22 80 00       	push   $0x80227c
  800cbb:	e8 64 0e 00 00       	call   801b24 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
  800cce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd6:	b8 08 00 00 00       	mov    $0x8,%eax
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	89 df                	mov    %ebx,%edi
  800ce3:	89 de                	mov    %ebx,%esi
  800ce5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	7e 17                	jle    800d02 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ceb:	83 ec 0c             	sub    $0xc,%esp
  800cee:	50                   	push   %eax
  800cef:	6a 08                	push   $0x8
  800cf1:	68 5f 22 80 00       	push   $0x80225f
  800cf6:	6a 23                	push   $0x23
  800cf8:	68 7c 22 80 00       	push   $0x80227c
  800cfd:	e8 22 0e 00 00       	call   801b24 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
  800d10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d18:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	89 df                	mov    %ebx,%edi
  800d25:	89 de                	mov    %ebx,%esi
  800d27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7e 17                	jle    800d44 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	83 ec 0c             	sub    $0xc,%esp
  800d30:	50                   	push   %eax
  800d31:	6a 0a                	push   $0xa
  800d33:	68 5f 22 80 00       	push   $0x80225f
  800d38:	6a 23                	push   $0x23
  800d3a:	68 7c 22 80 00       	push   $0x80227c
  800d3f:	e8 e0 0d 00 00       	call   801b24 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	89 df                	mov    %ebx,%edi
  800d67:	89 de                	mov    %ebx,%esi
  800d69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	7e 17                	jle    800d86 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	50                   	push   %eax
  800d73:	6a 09                	push   $0x9
  800d75:	68 5f 22 80 00       	push   $0x80225f
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 7c 22 80 00       	push   $0x80227c
  800d81:	e8 9e 0d 00 00       	call   801b24 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d94:	be 00 00 00 00       	mov    $0x0,%esi
  800d99:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da1:	8b 55 08             	mov    0x8(%ebp),%edx
  800da4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800daa:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	57                   	push   %edi
  800db5:	56                   	push   %esi
  800db6:	53                   	push   %ebx
  800db7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbf:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	89 cb                	mov    %ecx,%ebx
  800dc9:	89 cf                	mov    %ecx,%edi
  800dcb:	89 ce                	mov    %ecx,%esi
  800dcd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	7e 17                	jle    800dea <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd3:	83 ec 0c             	sub    $0xc,%esp
  800dd6:	50                   	push   %eax
  800dd7:	6a 0d                	push   $0xd
  800dd9:	68 5f 22 80 00       	push   $0x80225f
  800dde:	6a 23                	push   $0x23
  800de0:	68 7c 22 80 00       	push   $0x80227c
  800de5:	e8 3a 0d 00 00       	call   801b24 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800df5:	8b 45 08             	mov    0x8(%ebp),%eax
  800df8:	05 00 00 00 30       	add    $0x30000000,%eax
  800dfd:	c1 e8 0c             	shr    $0xc,%eax
}
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e05:	8b 45 08             	mov    0x8(%ebp),%eax
  800e08:	05 00 00 00 30       	add    $0x30000000,%eax
  800e0d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e12:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e24:	89 c2                	mov    %eax,%edx
  800e26:	c1 ea 16             	shr    $0x16,%edx
  800e29:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e30:	f6 c2 01             	test   $0x1,%dl
  800e33:	74 11                	je     800e46 <fd_alloc+0x2d>
  800e35:	89 c2                	mov    %eax,%edx
  800e37:	c1 ea 0c             	shr    $0xc,%edx
  800e3a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e41:	f6 c2 01             	test   $0x1,%dl
  800e44:	75 09                	jne    800e4f <fd_alloc+0x36>
			*fd_store = fd;
  800e46:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e48:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4d:	eb 17                	jmp    800e66 <fd_alloc+0x4d>
  800e4f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e54:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e59:	75 c9                	jne    800e24 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e5b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e61:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e6e:	83 f8 1f             	cmp    $0x1f,%eax
  800e71:	77 36                	ja     800ea9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e73:	c1 e0 0c             	shl    $0xc,%eax
  800e76:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e7b:	89 c2                	mov    %eax,%edx
  800e7d:	c1 ea 16             	shr    $0x16,%edx
  800e80:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e87:	f6 c2 01             	test   $0x1,%dl
  800e8a:	74 24                	je     800eb0 <fd_lookup+0x48>
  800e8c:	89 c2                	mov    %eax,%edx
  800e8e:	c1 ea 0c             	shr    $0xc,%edx
  800e91:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e98:	f6 c2 01             	test   $0x1,%dl
  800e9b:	74 1a                	je     800eb7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea0:	89 02                	mov    %eax,(%edx)
	return 0;
  800ea2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea7:	eb 13                	jmp    800ebc <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ea9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eae:	eb 0c                	jmp    800ebc <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eb5:	eb 05                	jmp    800ebc <fd_lookup+0x54>
  800eb7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	83 ec 08             	sub    $0x8,%esp
  800ec4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec7:	ba 08 23 80 00       	mov    $0x802308,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ecc:	eb 13                	jmp    800ee1 <dev_lookup+0x23>
  800ece:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ed1:	39 08                	cmp    %ecx,(%eax)
  800ed3:	75 0c                	jne    800ee1 <dev_lookup+0x23>
			*dev = devtab[i];
  800ed5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eda:	b8 00 00 00 00       	mov    $0x0,%eax
  800edf:	eb 2e                	jmp    800f0f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ee1:	8b 02                	mov    (%edx),%eax
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	75 e7                	jne    800ece <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ee7:	a1 0c 40 80 00       	mov    0x80400c,%eax
  800eec:	8b 40 48             	mov    0x48(%eax),%eax
  800eef:	83 ec 04             	sub    $0x4,%esp
  800ef2:	51                   	push   %ecx
  800ef3:	50                   	push   %eax
  800ef4:	68 8c 22 80 00       	push   $0x80228c
  800ef9:	e8 55 f2 ff ff       	call   800153 <cprintf>
	*dev = 0;
  800efe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f01:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f07:	83 c4 10             	add    $0x10,%esp
  800f0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f0f:	c9                   	leave  
  800f10:	c3                   	ret    

00800f11 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	56                   	push   %esi
  800f15:	53                   	push   %ebx
  800f16:	83 ec 10             	sub    $0x10,%esp
  800f19:	8b 75 08             	mov    0x8(%ebp),%esi
  800f1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f22:	50                   	push   %eax
  800f23:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f29:	c1 e8 0c             	shr    $0xc,%eax
  800f2c:	50                   	push   %eax
  800f2d:	e8 36 ff ff ff       	call   800e68 <fd_lookup>
  800f32:	83 c4 08             	add    $0x8,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	78 05                	js     800f3e <fd_close+0x2d>
	    || fd != fd2) 
  800f39:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f3c:	74 0c                	je     800f4a <fd_close+0x39>
		return (must_exist ? r : 0); 
  800f3e:	84 db                	test   %bl,%bl
  800f40:	ba 00 00 00 00       	mov    $0x0,%edx
  800f45:	0f 44 c2             	cmove  %edx,%eax
  800f48:	eb 41                	jmp    800f8b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f4a:	83 ec 08             	sub    $0x8,%esp
  800f4d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f50:	50                   	push   %eax
  800f51:	ff 36                	pushl  (%esi)
  800f53:	e8 66 ff ff ff       	call   800ebe <dev_lookup>
  800f58:	89 c3                	mov    %eax,%ebx
  800f5a:	83 c4 10             	add    $0x10,%esp
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	78 1a                	js     800f7b <fd_close+0x6a>
		if (dev->dev_close) 
  800f61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f64:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  800f67:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	74 0b                	je     800f7b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f70:	83 ec 0c             	sub    $0xc,%esp
  800f73:	56                   	push   %esi
  800f74:	ff d0                	call   *%eax
  800f76:	89 c3                	mov    %eax,%ebx
  800f78:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f7b:	83 ec 08             	sub    $0x8,%esp
  800f7e:	56                   	push   %esi
  800f7f:	6a 00                	push   $0x0
  800f81:	e8 00 fd ff ff       	call   800c86 <sys_page_unmap>
	return r;
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	89 d8                	mov    %ebx,%eax
}
  800f8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9b:	50                   	push   %eax
  800f9c:	ff 75 08             	pushl  0x8(%ebp)
  800f9f:	e8 c4 fe ff ff       	call   800e68 <fd_lookup>
  800fa4:	83 c4 08             	add    $0x8,%esp
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	78 10                	js     800fbb <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  800fab:	83 ec 08             	sub    $0x8,%esp
  800fae:	6a 01                	push   $0x1
  800fb0:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb3:	e8 59 ff ff ff       	call   800f11 <fd_close>
  800fb8:	83 c4 10             	add    $0x10,%esp
}
  800fbb:	c9                   	leave  
  800fbc:	c3                   	ret    

00800fbd <close_all>:

void
close_all(void)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	53                   	push   %ebx
  800fc1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fc9:	83 ec 0c             	sub    $0xc,%esp
  800fcc:	53                   	push   %ebx
  800fcd:	e8 c0 ff ff ff       	call   800f92 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd2:	83 c3 01             	add    $0x1,%ebx
  800fd5:	83 c4 10             	add    $0x10,%esp
  800fd8:	83 fb 20             	cmp    $0x20,%ebx
  800fdb:	75 ec                	jne    800fc9 <close_all+0xc>
		close(i);
}
  800fdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe0:	c9                   	leave  
  800fe1:	c3                   	ret    

00800fe2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	57                   	push   %edi
  800fe6:	56                   	push   %esi
  800fe7:	53                   	push   %ebx
  800fe8:	83 ec 2c             	sub    $0x2c,%esp
  800feb:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ff1:	50                   	push   %eax
  800ff2:	ff 75 08             	pushl  0x8(%ebp)
  800ff5:	e8 6e fe ff ff       	call   800e68 <fd_lookup>
  800ffa:	83 c4 08             	add    $0x8,%esp
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	0f 88 c1 00 00 00    	js     8010c6 <dup+0xe4>
		return r;
	close(newfdnum);
  801005:	83 ec 0c             	sub    $0xc,%esp
  801008:	56                   	push   %esi
  801009:	e8 84 ff ff ff       	call   800f92 <close>

	newfd = INDEX2FD(newfdnum);
  80100e:	89 f3                	mov    %esi,%ebx
  801010:	c1 e3 0c             	shl    $0xc,%ebx
  801013:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801019:	83 c4 04             	add    $0x4,%esp
  80101c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80101f:	e8 de fd ff ff       	call   800e02 <fd2data>
  801024:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801026:	89 1c 24             	mov    %ebx,(%esp)
  801029:	e8 d4 fd ff ff       	call   800e02 <fd2data>
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801034:	89 f8                	mov    %edi,%eax
  801036:	c1 e8 16             	shr    $0x16,%eax
  801039:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801040:	a8 01                	test   $0x1,%al
  801042:	74 37                	je     80107b <dup+0x99>
  801044:	89 f8                	mov    %edi,%eax
  801046:	c1 e8 0c             	shr    $0xc,%eax
  801049:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801050:	f6 c2 01             	test   $0x1,%dl
  801053:	74 26                	je     80107b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801055:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105c:	83 ec 0c             	sub    $0xc,%esp
  80105f:	25 07 0e 00 00       	and    $0xe07,%eax
  801064:	50                   	push   %eax
  801065:	ff 75 d4             	pushl  -0x2c(%ebp)
  801068:	6a 00                	push   $0x0
  80106a:	57                   	push   %edi
  80106b:	6a 00                	push   $0x0
  80106d:	e8 d2 fb ff ff       	call   800c44 <sys_page_map>
  801072:	89 c7                	mov    %eax,%edi
  801074:	83 c4 20             	add    $0x20,%esp
  801077:	85 c0                	test   %eax,%eax
  801079:	78 2e                	js     8010a9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80107b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80107e:	89 d0                	mov    %edx,%eax
  801080:	c1 e8 0c             	shr    $0xc,%eax
  801083:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	25 07 0e 00 00       	and    $0xe07,%eax
  801092:	50                   	push   %eax
  801093:	53                   	push   %ebx
  801094:	6a 00                	push   $0x0
  801096:	52                   	push   %edx
  801097:	6a 00                	push   $0x0
  801099:	e8 a6 fb ff ff       	call   800c44 <sys_page_map>
  80109e:	89 c7                	mov    %eax,%edi
  8010a0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010a3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010a5:	85 ff                	test   %edi,%edi
  8010a7:	79 1d                	jns    8010c6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010a9:	83 ec 08             	sub    $0x8,%esp
  8010ac:	53                   	push   %ebx
  8010ad:	6a 00                	push   $0x0
  8010af:	e8 d2 fb ff ff       	call   800c86 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010b4:	83 c4 08             	add    $0x8,%esp
  8010b7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ba:	6a 00                	push   $0x0
  8010bc:	e8 c5 fb ff ff       	call   800c86 <sys_page_unmap>
	return r;
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	89 f8                	mov    %edi,%eax
}
  8010c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c9:	5b                   	pop    %ebx
  8010ca:	5e                   	pop    %esi
  8010cb:	5f                   	pop    %edi
  8010cc:	5d                   	pop    %ebp
  8010cd:	c3                   	ret    

008010ce <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	53                   	push   %ebx
  8010d2:	83 ec 14             	sub    $0x14,%esp
  8010d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010db:	50                   	push   %eax
  8010dc:	53                   	push   %ebx
  8010dd:	e8 86 fd ff ff       	call   800e68 <fd_lookup>
  8010e2:	83 c4 08             	add    $0x8,%esp
  8010e5:	89 c2                	mov    %eax,%edx
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 6d                	js     801158 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010eb:	83 ec 08             	sub    $0x8,%esp
  8010ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f1:	50                   	push   %eax
  8010f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f5:	ff 30                	pushl  (%eax)
  8010f7:	e8 c2 fd ff ff       	call   800ebe <dev_lookup>
  8010fc:	83 c4 10             	add    $0x10,%esp
  8010ff:	85 c0                	test   %eax,%eax
  801101:	78 4c                	js     80114f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801103:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801106:	8b 42 08             	mov    0x8(%edx),%eax
  801109:	83 e0 03             	and    $0x3,%eax
  80110c:	83 f8 01             	cmp    $0x1,%eax
  80110f:	75 21                	jne    801132 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801111:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801116:	8b 40 48             	mov    0x48(%eax),%eax
  801119:	83 ec 04             	sub    $0x4,%esp
  80111c:	53                   	push   %ebx
  80111d:	50                   	push   %eax
  80111e:	68 cd 22 80 00       	push   $0x8022cd
  801123:	e8 2b f0 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  801128:	83 c4 10             	add    $0x10,%esp
  80112b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801130:	eb 26                	jmp    801158 <read+0x8a>
	}
	if (!dev->dev_read)
  801132:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801135:	8b 40 08             	mov    0x8(%eax),%eax
  801138:	85 c0                	test   %eax,%eax
  80113a:	74 17                	je     801153 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80113c:	83 ec 04             	sub    $0x4,%esp
  80113f:	ff 75 10             	pushl  0x10(%ebp)
  801142:	ff 75 0c             	pushl  0xc(%ebp)
  801145:	52                   	push   %edx
  801146:	ff d0                	call   *%eax
  801148:	89 c2                	mov    %eax,%edx
  80114a:	83 c4 10             	add    $0x10,%esp
  80114d:	eb 09                	jmp    801158 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114f:	89 c2                	mov    %eax,%edx
  801151:	eb 05                	jmp    801158 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801153:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801158:	89 d0                	mov    %edx,%eax
  80115a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115d:	c9                   	leave  
  80115e:	c3                   	ret    

0080115f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	57                   	push   %edi
  801163:	56                   	push   %esi
  801164:	53                   	push   %ebx
  801165:	83 ec 0c             	sub    $0xc,%esp
  801168:	8b 7d 08             	mov    0x8(%ebp),%edi
  80116b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80116e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801173:	eb 21                	jmp    801196 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801175:	83 ec 04             	sub    $0x4,%esp
  801178:	89 f0                	mov    %esi,%eax
  80117a:	29 d8                	sub    %ebx,%eax
  80117c:	50                   	push   %eax
  80117d:	89 d8                	mov    %ebx,%eax
  80117f:	03 45 0c             	add    0xc(%ebp),%eax
  801182:	50                   	push   %eax
  801183:	57                   	push   %edi
  801184:	e8 45 ff ff ff       	call   8010ce <read>
		if (m < 0)
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	85 c0                	test   %eax,%eax
  80118e:	78 10                	js     8011a0 <readn+0x41>
			return m;
		if (m == 0)
  801190:	85 c0                	test   %eax,%eax
  801192:	74 0a                	je     80119e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801194:	01 c3                	add    %eax,%ebx
  801196:	39 f3                	cmp    %esi,%ebx
  801198:	72 db                	jb     801175 <readn+0x16>
  80119a:	89 d8                	mov    %ebx,%eax
  80119c:	eb 02                	jmp    8011a0 <readn+0x41>
  80119e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a3:	5b                   	pop    %ebx
  8011a4:	5e                   	pop    %esi
  8011a5:	5f                   	pop    %edi
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    

008011a8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	53                   	push   %ebx
  8011ac:	83 ec 14             	sub    $0x14,%esp
  8011af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b5:	50                   	push   %eax
  8011b6:	53                   	push   %ebx
  8011b7:	e8 ac fc ff ff       	call   800e68 <fd_lookup>
  8011bc:	83 c4 08             	add    $0x8,%esp
  8011bf:	89 c2                	mov    %eax,%edx
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	78 68                	js     80122d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c5:	83 ec 08             	sub    $0x8,%esp
  8011c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cb:	50                   	push   %eax
  8011cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cf:	ff 30                	pushl  (%eax)
  8011d1:	e8 e8 fc ff ff       	call   800ebe <dev_lookup>
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	78 47                	js     801224 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011e4:	75 21                	jne    801207 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e6:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8011eb:	8b 40 48             	mov    0x48(%eax),%eax
  8011ee:	83 ec 04             	sub    $0x4,%esp
  8011f1:	53                   	push   %ebx
  8011f2:	50                   	push   %eax
  8011f3:	68 e9 22 80 00       	push   $0x8022e9
  8011f8:	e8 56 ef ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801205:	eb 26                	jmp    80122d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801207:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80120a:	8b 52 0c             	mov    0xc(%edx),%edx
  80120d:	85 d2                	test   %edx,%edx
  80120f:	74 17                	je     801228 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801211:	83 ec 04             	sub    $0x4,%esp
  801214:	ff 75 10             	pushl  0x10(%ebp)
  801217:	ff 75 0c             	pushl  0xc(%ebp)
  80121a:	50                   	push   %eax
  80121b:	ff d2                	call   *%edx
  80121d:	89 c2                	mov    %eax,%edx
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	eb 09                	jmp    80122d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801224:	89 c2                	mov    %eax,%edx
  801226:	eb 05                	jmp    80122d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801228:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80122d:	89 d0                	mov    %edx,%eax
  80122f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801232:	c9                   	leave  
  801233:	c3                   	ret    

00801234 <seek>:

int
seek(int fdnum, off_t offset)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80123a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80123d:	50                   	push   %eax
  80123e:	ff 75 08             	pushl  0x8(%ebp)
  801241:	e8 22 fc ff ff       	call   800e68 <fd_lookup>
  801246:	83 c4 08             	add    $0x8,%esp
  801249:	85 c0                	test   %eax,%eax
  80124b:	78 0e                	js     80125b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80124d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801250:	8b 55 0c             	mov    0xc(%ebp),%edx
  801253:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801256:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80125b:	c9                   	leave  
  80125c:	c3                   	ret    

0080125d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	53                   	push   %ebx
  801261:	83 ec 14             	sub    $0x14,%esp
  801264:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801267:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126a:	50                   	push   %eax
  80126b:	53                   	push   %ebx
  80126c:	e8 f7 fb ff ff       	call   800e68 <fd_lookup>
  801271:	83 c4 08             	add    $0x8,%esp
  801274:	89 c2                	mov    %eax,%edx
  801276:	85 c0                	test   %eax,%eax
  801278:	78 65                	js     8012df <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127a:	83 ec 08             	sub    $0x8,%esp
  80127d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801280:	50                   	push   %eax
  801281:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801284:	ff 30                	pushl  (%eax)
  801286:	e8 33 fc ff ff       	call   800ebe <dev_lookup>
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	85 c0                	test   %eax,%eax
  801290:	78 44                	js     8012d6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801292:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801295:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801299:	75 21                	jne    8012bc <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80129b:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012a0:	8b 40 48             	mov    0x48(%eax),%eax
  8012a3:	83 ec 04             	sub    $0x4,%esp
  8012a6:	53                   	push   %ebx
  8012a7:	50                   	push   %eax
  8012a8:	68 ac 22 80 00       	push   $0x8022ac
  8012ad:	e8 a1 ee ff ff       	call   800153 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ba:	eb 23                	jmp    8012df <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bf:	8b 52 18             	mov    0x18(%edx),%edx
  8012c2:	85 d2                	test   %edx,%edx
  8012c4:	74 14                	je     8012da <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012c6:	83 ec 08             	sub    $0x8,%esp
  8012c9:	ff 75 0c             	pushl  0xc(%ebp)
  8012cc:	50                   	push   %eax
  8012cd:	ff d2                	call   *%edx
  8012cf:	89 c2                	mov    %eax,%edx
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	eb 09                	jmp    8012df <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d6:	89 c2                	mov    %eax,%edx
  8012d8:	eb 05                	jmp    8012df <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012da:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012df:	89 d0                	mov    %edx,%eax
  8012e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e4:	c9                   	leave  
  8012e5:	c3                   	ret    

008012e6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	53                   	push   %ebx
  8012ea:	83 ec 14             	sub    $0x14,%esp
  8012ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f3:	50                   	push   %eax
  8012f4:	ff 75 08             	pushl  0x8(%ebp)
  8012f7:	e8 6c fb ff ff       	call   800e68 <fd_lookup>
  8012fc:	83 c4 08             	add    $0x8,%esp
  8012ff:	89 c2                	mov    %eax,%edx
  801301:	85 c0                	test   %eax,%eax
  801303:	78 58                	js     80135d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801305:	83 ec 08             	sub    $0x8,%esp
  801308:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130b:	50                   	push   %eax
  80130c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130f:	ff 30                	pushl  (%eax)
  801311:	e8 a8 fb ff ff       	call   800ebe <dev_lookup>
  801316:	83 c4 10             	add    $0x10,%esp
  801319:	85 c0                	test   %eax,%eax
  80131b:	78 37                	js     801354 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80131d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801320:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801324:	74 32                	je     801358 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801326:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801329:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801330:	00 00 00 
	stat->st_isdir = 0;
  801333:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80133a:	00 00 00 
	stat->st_dev = dev;
  80133d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801343:	83 ec 08             	sub    $0x8,%esp
  801346:	53                   	push   %ebx
  801347:	ff 75 f0             	pushl  -0x10(%ebp)
  80134a:	ff 50 14             	call   *0x14(%eax)
  80134d:	89 c2                	mov    %eax,%edx
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	eb 09                	jmp    80135d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801354:	89 c2                	mov    %eax,%edx
  801356:	eb 05                	jmp    80135d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801358:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80135d:	89 d0                	mov    %edx,%eax
  80135f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801362:	c9                   	leave  
  801363:	c3                   	ret    

00801364 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	56                   	push   %esi
  801368:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801369:	83 ec 08             	sub    $0x8,%esp
  80136c:	6a 00                	push   $0x0
  80136e:	ff 75 08             	pushl  0x8(%ebp)
  801371:	e8 2b 02 00 00       	call   8015a1 <open>
  801376:	89 c3                	mov    %eax,%ebx
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	85 c0                	test   %eax,%eax
  80137d:	78 1b                	js     80139a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80137f:	83 ec 08             	sub    $0x8,%esp
  801382:	ff 75 0c             	pushl  0xc(%ebp)
  801385:	50                   	push   %eax
  801386:	e8 5b ff ff ff       	call   8012e6 <fstat>
  80138b:	89 c6                	mov    %eax,%esi
	close(fd);
  80138d:	89 1c 24             	mov    %ebx,(%esp)
  801390:	e8 fd fb ff ff       	call   800f92 <close>
	return r;
  801395:	83 c4 10             	add    $0x10,%esp
  801398:	89 f0                	mov    %esi,%eax
}
  80139a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80139d:	5b                   	pop    %ebx
  80139e:	5e                   	pop    %esi
  80139f:	5d                   	pop    %ebp
  8013a0:	c3                   	ret    

008013a1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	56                   	push   %esi
  8013a5:	53                   	push   %ebx
  8013a6:	89 c6                	mov    %eax,%esi
  8013a8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013aa:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8013b1:	75 12                	jne    8013c5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013b3:	83 ec 0c             	sub    $0xc,%esp
  8013b6:	6a 01                	push   $0x1
  8013b8:	e8 6c 08 00 00       	call   801c29 <ipc_find_env>
  8013bd:	a3 04 40 80 00       	mov    %eax,0x804004
  8013c2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013c5:	6a 07                	push   $0x7
  8013c7:	68 00 50 80 00       	push   $0x805000
  8013cc:	56                   	push   %esi
  8013cd:	ff 35 04 40 80 00    	pushl  0x804004
  8013d3:	e8 fb 07 00 00       	call   801bd3 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8013d8:	83 c4 0c             	add    $0xc,%esp
  8013db:	6a 00                	push   $0x0
  8013dd:	53                   	push   %ebx
  8013de:	6a 00                	push   $0x0
  8013e0:	e8 85 07 00 00       	call   801b6a <ipc_recv>
}
  8013e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e8:	5b                   	pop    %ebx
  8013e9:	5e                   	pop    %esi
  8013ea:	5d                   	pop    %ebp
  8013eb:	c3                   	ret    

008013ec <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801400:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801405:	ba 00 00 00 00       	mov    $0x0,%edx
  80140a:	b8 02 00 00 00       	mov    $0x2,%eax
  80140f:	e8 8d ff ff ff       	call   8013a1 <fsipc>
}
  801414:	c9                   	leave  
  801415:	c3                   	ret    

00801416 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80141c:	8b 45 08             	mov    0x8(%ebp),%eax
  80141f:	8b 40 0c             	mov    0xc(%eax),%eax
  801422:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801427:	ba 00 00 00 00       	mov    $0x0,%edx
  80142c:	b8 06 00 00 00       	mov    $0x6,%eax
  801431:	e8 6b ff ff ff       	call   8013a1 <fsipc>
}
  801436:	c9                   	leave  
  801437:	c3                   	ret    

00801438 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	53                   	push   %ebx
  80143c:	83 ec 04             	sub    $0x4,%esp
  80143f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801442:	8b 45 08             	mov    0x8(%ebp),%eax
  801445:	8b 40 0c             	mov    0xc(%eax),%eax
  801448:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80144d:	ba 00 00 00 00       	mov    $0x0,%edx
  801452:	b8 05 00 00 00       	mov    $0x5,%eax
  801457:	e8 45 ff ff ff       	call   8013a1 <fsipc>
  80145c:	85 c0                	test   %eax,%eax
  80145e:	78 2c                	js     80148c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801460:	83 ec 08             	sub    $0x8,%esp
  801463:	68 00 50 80 00       	push   $0x805000
  801468:	53                   	push   %ebx
  801469:	e8 19 f3 ff ff       	call   800787 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80146e:	a1 80 50 80 00       	mov    0x805080,%eax
  801473:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801479:	a1 84 50 80 00       	mov    0x805084,%eax
  80147e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80148c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148f:	c9                   	leave  
  801490:	c3                   	ret    

00801491 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	53                   	push   %ebx
  801495:	83 ec 08             	sub    $0x8,%esp
  801498:	8b 45 10             	mov    0x10(%ebp),%eax
  80149b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014a0:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8014a5:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  8014b3:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014b9:	53                   	push   %ebx
  8014ba:	ff 75 0c             	pushl  0xc(%ebp)
  8014bd:	68 08 50 80 00       	push   $0x805008
  8014c2:	e8 52 f4 ff ff       	call   800919 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8014c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cc:	b8 04 00 00 00       	mov    $0x4,%eax
  8014d1:	e8 cb fe ff ff       	call   8013a1 <fsipc>
  8014d6:	83 c4 10             	add    $0x10,%esp
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 3d                	js     80151a <devfile_write+0x89>
		return r;

	assert(r <= n);
  8014dd:	39 d8                	cmp    %ebx,%eax
  8014df:	76 19                	jbe    8014fa <devfile_write+0x69>
  8014e1:	68 18 23 80 00       	push   $0x802318
  8014e6:	68 1f 23 80 00       	push   $0x80231f
  8014eb:	68 9f 00 00 00       	push   $0x9f
  8014f0:	68 34 23 80 00       	push   $0x802334
  8014f5:	e8 2a 06 00 00       	call   801b24 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  8014fa:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014ff:	76 19                	jbe    80151a <devfile_write+0x89>
  801501:	68 4c 23 80 00       	push   $0x80234c
  801506:	68 1f 23 80 00       	push   $0x80231f
  80150b:	68 a0 00 00 00       	push   $0xa0
  801510:	68 34 23 80 00       	push   $0x802334
  801515:	e8 0a 06 00 00       	call   801b24 <_panic>

	return r;
}
  80151a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151d:	c9                   	leave  
  80151e:	c3                   	ret    

0080151f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	56                   	push   %esi
  801523:	53                   	push   %ebx
  801524:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801527:	8b 45 08             	mov    0x8(%ebp),%eax
  80152a:	8b 40 0c             	mov    0xc(%eax),%eax
  80152d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801532:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801538:	ba 00 00 00 00       	mov    $0x0,%edx
  80153d:	b8 03 00 00 00       	mov    $0x3,%eax
  801542:	e8 5a fe ff ff       	call   8013a1 <fsipc>
  801547:	89 c3                	mov    %eax,%ebx
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 4b                	js     801598 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80154d:	39 c6                	cmp    %eax,%esi
  80154f:	73 16                	jae    801567 <devfile_read+0x48>
  801551:	68 18 23 80 00       	push   $0x802318
  801556:	68 1f 23 80 00       	push   $0x80231f
  80155b:	6a 7e                	push   $0x7e
  80155d:	68 34 23 80 00       	push   $0x802334
  801562:	e8 bd 05 00 00       	call   801b24 <_panic>
	assert(r <= PGSIZE);
  801567:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80156c:	7e 16                	jle    801584 <devfile_read+0x65>
  80156e:	68 3f 23 80 00       	push   $0x80233f
  801573:	68 1f 23 80 00       	push   $0x80231f
  801578:	6a 7f                	push   $0x7f
  80157a:	68 34 23 80 00       	push   $0x802334
  80157f:	e8 a0 05 00 00       	call   801b24 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801584:	83 ec 04             	sub    $0x4,%esp
  801587:	50                   	push   %eax
  801588:	68 00 50 80 00       	push   $0x805000
  80158d:	ff 75 0c             	pushl  0xc(%ebp)
  801590:	e8 84 f3 ff ff       	call   800919 <memmove>
	return r;
  801595:	83 c4 10             	add    $0x10,%esp
}
  801598:	89 d8                	mov    %ebx,%eax
  80159a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159d:	5b                   	pop    %ebx
  80159e:	5e                   	pop    %esi
  80159f:	5d                   	pop    %ebp
  8015a0:	c3                   	ret    

008015a1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	53                   	push   %ebx
  8015a5:	83 ec 20             	sub    $0x20,%esp
  8015a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015ab:	53                   	push   %ebx
  8015ac:	e8 9d f1 ff ff       	call   80074e <strlen>
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015b9:	7f 67                	jg     801622 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015bb:	83 ec 0c             	sub    $0xc,%esp
  8015be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c1:	50                   	push   %eax
  8015c2:	e8 52 f8 ff ff       	call   800e19 <fd_alloc>
  8015c7:	83 c4 10             	add    $0x10,%esp
		return r;
  8015ca:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 57                	js     801627 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	53                   	push   %ebx
  8015d4:	68 00 50 80 00       	push   $0x805000
  8015d9:	e8 a9 f1 ff ff       	call   800787 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ee:	e8 ae fd ff ff       	call   8013a1 <fsipc>
  8015f3:	89 c3                	mov    %eax,%ebx
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	79 14                	jns    801610 <open+0x6f>
		fd_close(fd, 0);
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	6a 00                	push   $0x0
  801601:	ff 75 f4             	pushl  -0xc(%ebp)
  801604:	e8 08 f9 ff ff       	call   800f11 <fd_close>
		return r;
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	89 da                	mov    %ebx,%edx
  80160e:	eb 17                	jmp    801627 <open+0x86>
	}

	return fd2num(fd);
  801610:	83 ec 0c             	sub    $0xc,%esp
  801613:	ff 75 f4             	pushl  -0xc(%ebp)
  801616:	e8 d7 f7 ff ff       	call   800df2 <fd2num>
  80161b:	89 c2                	mov    %eax,%edx
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	eb 05                	jmp    801627 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801622:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801627:	89 d0                	mov    %edx,%eax
  801629:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162c:	c9                   	leave  
  80162d:	c3                   	ret    

0080162e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801634:	ba 00 00 00 00       	mov    $0x0,%edx
  801639:	b8 08 00 00 00       	mov    $0x8,%eax
  80163e:	e8 5e fd ff ff       	call   8013a1 <fsipc>
}
  801643:	c9                   	leave  
  801644:	c3                   	ret    

00801645 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	56                   	push   %esi
  801649:	53                   	push   %ebx
  80164a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80164d:	83 ec 0c             	sub    $0xc,%esp
  801650:	ff 75 08             	pushl  0x8(%ebp)
  801653:	e8 aa f7 ff ff       	call   800e02 <fd2data>
  801658:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80165a:	83 c4 08             	add    $0x8,%esp
  80165d:	68 79 23 80 00       	push   $0x802379
  801662:	53                   	push   %ebx
  801663:	e8 1f f1 ff ff       	call   800787 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801668:	8b 46 04             	mov    0x4(%esi),%eax
  80166b:	2b 06                	sub    (%esi),%eax
  80166d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801673:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80167a:	00 00 00 
	stat->st_dev = &devpipe;
  80167d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801684:	30 80 00 
	return 0;
}
  801687:	b8 00 00 00 00       	mov    $0x0,%eax
  80168c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80168f:	5b                   	pop    %ebx
  801690:	5e                   	pop    %esi
  801691:	5d                   	pop    %ebp
  801692:	c3                   	ret    

00801693 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	53                   	push   %ebx
  801697:	83 ec 0c             	sub    $0xc,%esp
  80169a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80169d:	53                   	push   %ebx
  80169e:	6a 00                	push   $0x0
  8016a0:	e8 e1 f5 ff ff       	call   800c86 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016a5:	89 1c 24             	mov    %ebx,(%esp)
  8016a8:	e8 55 f7 ff ff       	call   800e02 <fd2data>
  8016ad:	83 c4 08             	add    $0x8,%esp
  8016b0:	50                   	push   %eax
  8016b1:	6a 00                	push   $0x0
  8016b3:	e8 ce f5 ff ff       	call   800c86 <sys_page_unmap>
}
  8016b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	57                   	push   %edi
  8016c1:	56                   	push   %esi
  8016c2:	53                   	push   %ebx
  8016c3:	83 ec 1c             	sub    $0x1c,%esp
  8016c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016c9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016cb:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8016d0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016d3:	83 ec 0c             	sub    $0xc,%esp
  8016d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8016d9:	e8 84 05 00 00       	call   801c62 <pageref>
  8016de:	89 c3                	mov    %eax,%ebx
  8016e0:	89 3c 24             	mov    %edi,(%esp)
  8016e3:	e8 7a 05 00 00       	call   801c62 <pageref>
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	39 c3                	cmp    %eax,%ebx
  8016ed:	0f 94 c1             	sete   %cl
  8016f0:	0f b6 c9             	movzbl %cl,%ecx
  8016f3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016f6:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  8016fc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016ff:	39 ce                	cmp    %ecx,%esi
  801701:	74 1b                	je     80171e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801703:	39 c3                	cmp    %eax,%ebx
  801705:	75 c4                	jne    8016cb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801707:	8b 42 58             	mov    0x58(%edx),%eax
  80170a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80170d:	50                   	push   %eax
  80170e:	56                   	push   %esi
  80170f:	68 80 23 80 00       	push   $0x802380
  801714:	e8 3a ea ff ff       	call   800153 <cprintf>
  801719:	83 c4 10             	add    $0x10,%esp
  80171c:	eb ad                	jmp    8016cb <_pipeisclosed+0xe>
	}
}
  80171e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801721:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801724:	5b                   	pop    %ebx
  801725:	5e                   	pop    %esi
  801726:	5f                   	pop    %edi
  801727:	5d                   	pop    %ebp
  801728:	c3                   	ret    

00801729 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	57                   	push   %edi
  80172d:	56                   	push   %esi
  80172e:	53                   	push   %ebx
  80172f:	83 ec 28             	sub    $0x28,%esp
  801732:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801735:	56                   	push   %esi
  801736:	e8 c7 f6 ff ff       	call   800e02 <fd2data>
  80173b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	bf 00 00 00 00       	mov    $0x0,%edi
  801745:	eb 4b                	jmp    801792 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801747:	89 da                	mov    %ebx,%edx
  801749:	89 f0                	mov    %esi,%eax
  80174b:	e8 6d ff ff ff       	call   8016bd <_pipeisclosed>
  801750:	85 c0                	test   %eax,%eax
  801752:	75 48                	jne    80179c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801754:	e8 89 f4 ff ff       	call   800be2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801759:	8b 43 04             	mov    0x4(%ebx),%eax
  80175c:	8b 0b                	mov    (%ebx),%ecx
  80175e:	8d 51 20             	lea    0x20(%ecx),%edx
  801761:	39 d0                	cmp    %edx,%eax
  801763:	73 e2                	jae    801747 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801765:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801768:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80176c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80176f:	89 c2                	mov    %eax,%edx
  801771:	c1 fa 1f             	sar    $0x1f,%edx
  801774:	89 d1                	mov    %edx,%ecx
  801776:	c1 e9 1b             	shr    $0x1b,%ecx
  801779:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80177c:	83 e2 1f             	and    $0x1f,%edx
  80177f:	29 ca                	sub    %ecx,%edx
  801781:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801785:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801789:	83 c0 01             	add    $0x1,%eax
  80178c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80178f:	83 c7 01             	add    $0x1,%edi
  801792:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801795:	75 c2                	jne    801759 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801797:	8b 45 10             	mov    0x10(%ebp),%eax
  80179a:	eb 05                	jmp    8017a1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80179c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017a4:	5b                   	pop    %ebx
  8017a5:	5e                   	pop    %esi
  8017a6:	5f                   	pop    %edi
  8017a7:	5d                   	pop    %ebp
  8017a8:	c3                   	ret    

008017a9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	57                   	push   %edi
  8017ad:	56                   	push   %esi
  8017ae:	53                   	push   %ebx
  8017af:	83 ec 18             	sub    $0x18,%esp
  8017b2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017b5:	57                   	push   %edi
  8017b6:	e8 47 f6 ff ff       	call   800e02 <fd2data>
  8017bb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017bd:	83 c4 10             	add    $0x10,%esp
  8017c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017c5:	eb 3d                	jmp    801804 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017c7:	85 db                	test   %ebx,%ebx
  8017c9:	74 04                	je     8017cf <devpipe_read+0x26>
				return i;
  8017cb:	89 d8                	mov    %ebx,%eax
  8017cd:	eb 44                	jmp    801813 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017cf:	89 f2                	mov    %esi,%edx
  8017d1:	89 f8                	mov    %edi,%eax
  8017d3:	e8 e5 fe ff ff       	call   8016bd <_pipeisclosed>
  8017d8:	85 c0                	test   %eax,%eax
  8017da:	75 32                	jne    80180e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017dc:	e8 01 f4 ff ff       	call   800be2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017e1:	8b 06                	mov    (%esi),%eax
  8017e3:	3b 46 04             	cmp    0x4(%esi),%eax
  8017e6:	74 df                	je     8017c7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017e8:	99                   	cltd   
  8017e9:	c1 ea 1b             	shr    $0x1b,%edx
  8017ec:	01 d0                	add    %edx,%eax
  8017ee:	83 e0 1f             	and    $0x1f,%eax
  8017f1:	29 d0                	sub    %edx,%eax
  8017f3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017fb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017fe:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801801:	83 c3 01             	add    $0x1,%ebx
  801804:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801807:	75 d8                	jne    8017e1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801809:	8b 45 10             	mov    0x10(%ebp),%eax
  80180c:	eb 05                	jmp    801813 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80180e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801813:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801816:	5b                   	pop    %ebx
  801817:	5e                   	pop    %esi
  801818:	5f                   	pop    %edi
  801819:	5d                   	pop    %ebp
  80181a:	c3                   	ret    

0080181b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	56                   	push   %esi
  80181f:	53                   	push   %ebx
  801820:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801823:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801826:	50                   	push   %eax
  801827:	e8 ed f5 ff ff       	call   800e19 <fd_alloc>
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	89 c2                	mov    %eax,%edx
  801831:	85 c0                	test   %eax,%eax
  801833:	0f 88 2c 01 00 00    	js     801965 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801839:	83 ec 04             	sub    $0x4,%esp
  80183c:	68 07 04 00 00       	push   $0x407
  801841:	ff 75 f4             	pushl  -0xc(%ebp)
  801844:	6a 00                	push   $0x0
  801846:	e8 b6 f3 ff ff       	call   800c01 <sys_page_alloc>
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	89 c2                	mov    %eax,%edx
  801850:	85 c0                	test   %eax,%eax
  801852:	0f 88 0d 01 00 00    	js     801965 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801858:	83 ec 0c             	sub    $0xc,%esp
  80185b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80185e:	50                   	push   %eax
  80185f:	e8 b5 f5 ff ff       	call   800e19 <fd_alloc>
  801864:	89 c3                	mov    %eax,%ebx
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	85 c0                	test   %eax,%eax
  80186b:	0f 88 e2 00 00 00    	js     801953 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801871:	83 ec 04             	sub    $0x4,%esp
  801874:	68 07 04 00 00       	push   $0x407
  801879:	ff 75 f0             	pushl  -0x10(%ebp)
  80187c:	6a 00                	push   $0x0
  80187e:	e8 7e f3 ff ff       	call   800c01 <sys_page_alloc>
  801883:	89 c3                	mov    %eax,%ebx
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	85 c0                	test   %eax,%eax
  80188a:	0f 88 c3 00 00 00    	js     801953 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801890:	83 ec 0c             	sub    $0xc,%esp
  801893:	ff 75 f4             	pushl  -0xc(%ebp)
  801896:	e8 67 f5 ff ff       	call   800e02 <fd2data>
  80189b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80189d:	83 c4 0c             	add    $0xc,%esp
  8018a0:	68 07 04 00 00       	push   $0x407
  8018a5:	50                   	push   %eax
  8018a6:	6a 00                	push   $0x0
  8018a8:	e8 54 f3 ff ff       	call   800c01 <sys_page_alloc>
  8018ad:	89 c3                	mov    %eax,%ebx
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	85 c0                	test   %eax,%eax
  8018b4:	0f 88 89 00 00 00    	js     801943 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ba:	83 ec 0c             	sub    $0xc,%esp
  8018bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8018c0:	e8 3d f5 ff ff       	call   800e02 <fd2data>
  8018c5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018cc:	50                   	push   %eax
  8018cd:	6a 00                	push   $0x0
  8018cf:	56                   	push   %esi
  8018d0:	6a 00                	push   $0x0
  8018d2:	e8 6d f3 ff ff       	call   800c44 <sys_page_map>
  8018d7:	89 c3                	mov    %eax,%ebx
  8018d9:	83 c4 20             	add    $0x20,%esp
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	78 55                	js     801935 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018e0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ee:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018f5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fe:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801900:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801903:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80190a:	83 ec 0c             	sub    $0xc,%esp
  80190d:	ff 75 f4             	pushl  -0xc(%ebp)
  801910:	e8 dd f4 ff ff       	call   800df2 <fd2num>
  801915:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801918:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80191a:	83 c4 04             	add    $0x4,%esp
  80191d:	ff 75 f0             	pushl  -0x10(%ebp)
  801920:	e8 cd f4 ff ff       	call   800df2 <fd2num>
  801925:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801928:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	ba 00 00 00 00       	mov    $0x0,%edx
  801933:	eb 30                	jmp    801965 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801935:	83 ec 08             	sub    $0x8,%esp
  801938:	56                   	push   %esi
  801939:	6a 00                	push   $0x0
  80193b:	e8 46 f3 ff ff       	call   800c86 <sys_page_unmap>
  801940:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801943:	83 ec 08             	sub    $0x8,%esp
  801946:	ff 75 f0             	pushl  -0x10(%ebp)
  801949:	6a 00                	push   $0x0
  80194b:	e8 36 f3 ff ff       	call   800c86 <sys_page_unmap>
  801950:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801953:	83 ec 08             	sub    $0x8,%esp
  801956:	ff 75 f4             	pushl  -0xc(%ebp)
  801959:	6a 00                	push   $0x0
  80195b:	e8 26 f3 ff ff       	call   800c86 <sys_page_unmap>
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801965:	89 d0                	mov    %edx,%eax
  801967:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196a:	5b                   	pop    %ebx
  80196b:	5e                   	pop    %esi
  80196c:	5d                   	pop    %ebp
  80196d:	c3                   	ret    

0080196e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801974:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801977:	50                   	push   %eax
  801978:	ff 75 08             	pushl  0x8(%ebp)
  80197b:	e8 e8 f4 ff ff       	call   800e68 <fd_lookup>
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	85 c0                	test   %eax,%eax
  801985:	78 18                	js     80199f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801987:	83 ec 0c             	sub    $0xc,%esp
  80198a:	ff 75 f4             	pushl  -0xc(%ebp)
  80198d:	e8 70 f4 ff ff       	call   800e02 <fd2data>
	return _pipeisclosed(fd, p);
  801992:	89 c2                	mov    %eax,%edx
  801994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801997:	e8 21 fd ff ff       	call   8016bd <_pipeisclosed>
  80199c:	83 c4 10             	add    $0x10,%esp
}
  80199f:	c9                   	leave  
  8019a0:	c3                   	ret    

008019a1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019a1:	55                   	push   %ebp
  8019a2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a9:	5d                   	pop    %ebp
  8019aa:	c3                   	ret    

008019ab <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019b1:	68 98 23 80 00       	push   $0x802398
  8019b6:	ff 75 0c             	pushl  0xc(%ebp)
  8019b9:	e8 c9 ed ff ff       	call   800787 <strcpy>
	return 0;
}
  8019be:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c3:	c9                   	leave  
  8019c4:	c3                   	ret    

008019c5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019c5:	55                   	push   %ebp
  8019c6:	89 e5                	mov    %esp,%ebp
  8019c8:	57                   	push   %edi
  8019c9:	56                   	push   %esi
  8019ca:	53                   	push   %ebx
  8019cb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019d1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019d6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019dc:	eb 2d                	jmp    801a0b <devcons_write+0x46>
		m = n - tot;
  8019de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019e1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019e3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019e6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019eb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019ee:	83 ec 04             	sub    $0x4,%esp
  8019f1:	53                   	push   %ebx
  8019f2:	03 45 0c             	add    0xc(%ebp),%eax
  8019f5:	50                   	push   %eax
  8019f6:	57                   	push   %edi
  8019f7:	e8 1d ef ff ff       	call   800919 <memmove>
		sys_cputs(buf, m);
  8019fc:	83 c4 08             	add    $0x8,%esp
  8019ff:	53                   	push   %ebx
  801a00:	57                   	push   %edi
  801a01:	e8 3f f1 ff ff       	call   800b45 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a06:	01 de                	add    %ebx,%esi
  801a08:	83 c4 10             	add    $0x10,%esp
  801a0b:	89 f0                	mov    %esi,%eax
  801a0d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a10:	72 cc                	jb     8019de <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a15:	5b                   	pop    %ebx
  801a16:	5e                   	pop    %esi
  801a17:	5f                   	pop    %edi
  801a18:	5d                   	pop    %ebp
  801a19:	c3                   	ret    

00801a1a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	83 ec 08             	sub    $0x8,%esp
  801a20:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a25:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a29:	74 2a                	je     801a55 <devcons_read+0x3b>
  801a2b:	eb 05                	jmp    801a32 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a2d:	e8 b0 f1 ff ff       	call   800be2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a32:	e8 2c f1 ff ff       	call   800b63 <sys_cgetc>
  801a37:	85 c0                	test   %eax,%eax
  801a39:	74 f2                	je     801a2d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	78 16                	js     801a55 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a3f:	83 f8 04             	cmp    $0x4,%eax
  801a42:	74 0c                	je     801a50 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a44:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a47:	88 02                	mov    %al,(%edx)
	return 1;
  801a49:	b8 01 00 00 00       	mov    $0x1,%eax
  801a4e:	eb 05                	jmp    801a55 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a50:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a55:	c9                   	leave  
  801a56:	c3                   	ret    

00801a57 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a57:	55                   	push   %ebp
  801a58:	89 e5                	mov    %esp,%ebp
  801a5a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a60:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a63:	6a 01                	push   $0x1
  801a65:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a68:	50                   	push   %eax
  801a69:	e8 d7 f0 ff ff       	call   800b45 <sys_cputs>
}
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	c9                   	leave  
  801a72:	c3                   	ret    

00801a73 <getchar>:

int
getchar(void)
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a79:	6a 01                	push   $0x1
  801a7b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a7e:	50                   	push   %eax
  801a7f:	6a 00                	push   $0x0
  801a81:	e8 48 f6 ff ff       	call   8010ce <read>
	if (r < 0)
  801a86:	83 c4 10             	add    $0x10,%esp
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	78 0f                	js     801a9c <getchar+0x29>
		return r;
	if (r < 1)
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	7e 06                	jle    801a97 <getchar+0x24>
		return -E_EOF;
	return c;
  801a91:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a95:	eb 05                	jmp    801a9c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a97:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a9c:	c9                   	leave  
  801a9d:	c3                   	ret    

00801a9e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa7:	50                   	push   %eax
  801aa8:	ff 75 08             	pushl  0x8(%ebp)
  801aab:	e8 b8 f3 ff ff       	call   800e68 <fd_lookup>
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	78 11                	js     801ac8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aba:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ac0:	39 10                	cmp    %edx,(%eax)
  801ac2:	0f 94 c0             	sete   %al
  801ac5:	0f b6 c0             	movzbl %al,%eax
}
  801ac8:	c9                   	leave  
  801ac9:	c3                   	ret    

00801aca <opencons>:

int
opencons(void)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ad0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad3:	50                   	push   %eax
  801ad4:	e8 40 f3 ff ff       	call   800e19 <fd_alloc>
  801ad9:	83 c4 10             	add    $0x10,%esp
		return r;
  801adc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	78 3e                	js     801b20 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ae2:	83 ec 04             	sub    $0x4,%esp
  801ae5:	68 07 04 00 00       	push   $0x407
  801aea:	ff 75 f4             	pushl  -0xc(%ebp)
  801aed:	6a 00                	push   $0x0
  801aef:	e8 0d f1 ff ff       	call   800c01 <sys_page_alloc>
  801af4:	83 c4 10             	add    $0x10,%esp
		return r;
  801af7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801af9:	85 c0                	test   %eax,%eax
  801afb:	78 23                	js     801b20 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801afd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b06:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b12:	83 ec 0c             	sub    $0xc,%esp
  801b15:	50                   	push   %eax
  801b16:	e8 d7 f2 ff ff       	call   800df2 <fd2num>
  801b1b:	89 c2                	mov    %eax,%edx
  801b1d:	83 c4 10             	add    $0x10,%esp
}
  801b20:	89 d0                	mov    %edx,%eax
  801b22:	c9                   	leave  
  801b23:	c3                   	ret    

00801b24 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	56                   	push   %esi
  801b28:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b29:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b2c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b32:	e8 8c f0 ff ff       	call   800bc3 <sys_getenvid>
  801b37:	83 ec 0c             	sub    $0xc,%esp
  801b3a:	ff 75 0c             	pushl  0xc(%ebp)
  801b3d:	ff 75 08             	pushl  0x8(%ebp)
  801b40:	56                   	push   %esi
  801b41:	50                   	push   %eax
  801b42:	68 a4 23 80 00       	push   $0x8023a4
  801b47:	e8 07 e6 ff ff       	call   800153 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b4c:	83 c4 18             	add    $0x18,%esp
  801b4f:	53                   	push   %ebx
  801b50:	ff 75 10             	pushl  0x10(%ebp)
  801b53:	e8 aa e5 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  801b58:	c7 04 24 4c 1f 80 00 	movl   $0x801f4c,(%esp)
  801b5f:	e8 ef e5 ff ff       	call   800153 <cprintf>
  801b64:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b67:	cc                   	int3   
  801b68:	eb fd                	jmp    801b67 <_panic+0x43>

00801b6a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	56                   	push   %esi
  801b6e:	53                   	push   %ebx
  801b6f:	8b 75 08             	mov    0x8(%ebp),%esi
  801b72:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801b78:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801b7a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b7f:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801b82:	83 ec 0c             	sub    $0xc,%esp
  801b85:	50                   	push   %eax
  801b86:	e8 26 f2 ff ff       	call   800db1 <sys_ipc_recv>
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	79 16                	jns    801ba8 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801b92:	85 f6                	test   %esi,%esi
  801b94:	74 06                	je     801b9c <ipc_recv+0x32>
			*from_env_store = 0;
  801b96:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801b9c:	85 db                	test   %ebx,%ebx
  801b9e:	74 2c                	je     801bcc <ipc_recv+0x62>
			*perm_store = 0;
  801ba0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ba6:	eb 24                	jmp    801bcc <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801ba8:	85 f6                	test   %esi,%esi
  801baa:	74 0a                	je     801bb6 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801bac:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801bb1:	8b 40 74             	mov    0x74(%eax),%eax
  801bb4:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801bb6:	85 db                	test   %ebx,%ebx
  801bb8:	74 0a                	je     801bc4 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801bba:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801bbf:	8b 40 78             	mov    0x78(%eax),%eax
  801bc2:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801bc4:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801bc9:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bcf:	5b                   	pop    %ebx
  801bd0:	5e                   	pop    %esi
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    

00801bd3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	57                   	push   %edi
  801bd7:	56                   	push   %esi
  801bd8:	53                   	push   %ebx
  801bd9:	83 ec 0c             	sub    $0xc,%esp
  801bdc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bdf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801be2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801be5:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801be7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bec:	0f 44 d8             	cmove  %eax,%ebx
  801bef:	eb 1e                	jmp    801c0f <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801bf1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bf4:	74 14                	je     801c0a <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801bf6:	83 ec 04             	sub    $0x4,%esp
  801bf9:	68 c8 23 80 00       	push   $0x8023c8
  801bfe:	6a 44                	push   $0x44
  801c00:	68 f4 23 80 00       	push   $0x8023f4
  801c05:	e8 1a ff ff ff       	call   801b24 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801c0a:	e8 d3 ef ff ff       	call   800be2 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c0f:	ff 75 14             	pushl  0x14(%ebp)
  801c12:	53                   	push   %ebx
  801c13:	56                   	push   %esi
  801c14:	57                   	push   %edi
  801c15:	e8 74 f1 ff ff       	call   800d8e <sys_ipc_try_send>
  801c1a:	83 c4 10             	add    $0x10,%esp
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	78 d0                	js     801bf1 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c24:	5b                   	pop    %ebx
  801c25:	5e                   	pop    %esi
  801c26:	5f                   	pop    %edi
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    

00801c29 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c2f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c34:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c37:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c3d:	8b 52 50             	mov    0x50(%edx),%edx
  801c40:	39 ca                	cmp    %ecx,%edx
  801c42:	75 0d                	jne    801c51 <ipc_find_env+0x28>
			return envs[i].env_id;
  801c44:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c47:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c4c:	8b 40 48             	mov    0x48(%eax),%eax
  801c4f:	eb 0f                	jmp    801c60 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c51:	83 c0 01             	add    $0x1,%eax
  801c54:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c59:	75 d9                	jne    801c34 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    

00801c62 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c68:	89 d0                	mov    %edx,%eax
  801c6a:	c1 e8 16             	shr    $0x16,%eax
  801c6d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c74:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c79:	f6 c1 01             	test   $0x1,%cl
  801c7c:	74 1d                	je     801c9b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c7e:	c1 ea 0c             	shr    $0xc,%edx
  801c81:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c88:	f6 c2 01             	test   $0x1,%dl
  801c8b:	74 0e                	je     801c9b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c8d:	c1 ea 0c             	shr    $0xc,%edx
  801c90:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c97:	ef 
  801c98:	0f b7 c0             	movzwl %ax,%eax
}
  801c9b:	5d                   	pop    %ebp
  801c9c:	c3                   	ret    
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
