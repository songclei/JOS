
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#else

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 e0 1f 80 00       	push   $0x801fe0
  80004a:	e8 24 01 00 00       	call   800173 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 8f 0b 00 00       	call   800be3 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 46 0b 00 00       	call   800ba2 <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 a1 0d 00 00       	call   800e12 <set_pgfault_handler>
	
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80008b:	e8 53 0b 00 00       	call   800be3 <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cc:	e8 9b 0f 00 00       	call   80106c <close_all>
	sys_env_destroy(0);
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 c7 0a 00 00       	call   800ba2 <sys_env_destroy>
}
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 13                	mov    (%ebx),%edx
  8000ec:	8d 42 01             	lea    0x1(%edx),%eax
  8000ef:	89 03                	mov    %eax,(%ebx)
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fd:	75 1a                	jne    800119 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	68 ff 00 00 00       	push   $0xff
  800107:	8d 43 08             	lea    0x8(%ebx),%eax
  80010a:	50                   	push   %eax
  80010b:	e8 55 0a 00 00       	call   800b65 <sys_cputs>
		b->idx = 0;
  800110:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800116:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800119:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800132:	00 00 00 
	b.cnt = 0;
  800135:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013f:	ff 75 0c             	pushl  0xc(%ebp)
  800142:	ff 75 08             	pushl  0x8(%ebp)
  800145:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	68 e0 00 80 00       	push   $0x8000e0
  800151:	e8 54 01 00 00       	call   8002aa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	e8 fa 09 00 00       	call   800b65 <sys_cputs>

	return b.cnt;
}
  80016b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800179:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017c:	50                   	push   %eax
  80017d:	ff 75 08             	pushl  0x8(%ebp)
  800180:	e8 9d ff ff ff       	call   800122 <vcprintf>
	va_end(ap);

	return cnt;
}
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 1c             	sub    $0x1c,%esp
  800190:	89 c7                	mov    %eax,%edi
  800192:	89 d6                	mov    %edx,%esi
  800194:	8b 45 08             	mov    0x8(%ebp),%eax
  800197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ab:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ae:	39 d3                	cmp    %edx,%ebx
  8001b0:	72 05                	jb     8001b7 <printnum+0x30>
  8001b2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b5:	77 45                	ja     8001fc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	ff 75 18             	pushl  0x18(%ebp)
  8001bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c3:	53                   	push   %ebx
  8001c4:	ff 75 10             	pushl  0x10(%ebp)
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d6:	e8 75 1b 00 00       	call   801d50 <__udivdi3>
  8001db:	83 c4 18             	add    $0x18,%esp
  8001de:	52                   	push   %edx
  8001df:	50                   	push   %eax
  8001e0:	89 f2                	mov    %esi,%edx
  8001e2:	89 f8                	mov    %edi,%eax
  8001e4:	e8 9e ff ff ff       	call   800187 <printnum>
  8001e9:	83 c4 20             	add    $0x20,%esp
  8001ec:	eb 18                	jmp    800206 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	ff 75 18             	pushl  0x18(%ebp)
  8001f5:	ff d7                	call   *%edi
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	eb 03                	jmp    8001ff <printnum+0x78>
  8001fc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ff:	83 eb 01             	sub    $0x1,%ebx
  800202:	85 db                	test   %ebx,%ebx
  800204:	7f e8                	jg     8001ee <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800206:	83 ec 08             	sub    $0x8,%esp
  800209:	56                   	push   %esi
  80020a:	83 ec 04             	sub    $0x4,%esp
  80020d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800210:	ff 75 e0             	pushl  -0x20(%ebp)
  800213:	ff 75 dc             	pushl  -0x24(%ebp)
  800216:	ff 75 d8             	pushl  -0x28(%ebp)
  800219:	e8 62 1c 00 00       	call   801e80 <__umoddi3>
  80021e:	83 c4 14             	add    $0x14,%esp
  800221:	0f be 80 06 20 80 00 	movsbl 0x802006(%eax),%eax
  800228:	50                   	push   %eax
  800229:	ff d7                	call   *%edi
}
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800231:	5b                   	pop    %ebx
  800232:	5e                   	pop    %esi
  800233:	5f                   	pop    %edi
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800239:	83 fa 01             	cmp    $0x1,%edx
  80023c:	7e 0e                	jle    80024c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80023e:	8b 10                	mov    (%eax),%edx
  800240:	8d 4a 08             	lea    0x8(%edx),%ecx
  800243:	89 08                	mov    %ecx,(%eax)
  800245:	8b 02                	mov    (%edx),%eax
  800247:	8b 52 04             	mov    0x4(%edx),%edx
  80024a:	eb 22                	jmp    80026e <getuint+0x38>
	else if (lflag)
  80024c:	85 d2                	test   %edx,%edx
  80024e:	74 10                	je     800260 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800250:	8b 10                	mov    (%eax),%edx
  800252:	8d 4a 04             	lea    0x4(%edx),%ecx
  800255:	89 08                	mov    %ecx,(%eax)
  800257:	8b 02                	mov    (%edx),%eax
  800259:	ba 00 00 00 00       	mov    $0x0,%edx
  80025e:	eb 0e                	jmp    80026e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800260:	8b 10                	mov    (%eax),%edx
  800262:	8d 4a 04             	lea    0x4(%edx),%ecx
  800265:	89 08                	mov    %ecx,(%eax)
  800267:	8b 02                	mov    (%edx),%eax
  800269:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800276:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	3b 50 04             	cmp    0x4(%eax),%edx
  80027f:	73 0a                	jae    80028b <sprintputch+0x1b>
		*b->buf++ = ch;
  800281:	8d 4a 01             	lea    0x1(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 45 08             	mov    0x8(%ebp),%eax
  800289:	88 02                	mov    %al,(%edx)
}
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800293:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800296:	50                   	push   %eax
  800297:	ff 75 10             	pushl  0x10(%ebp)
  80029a:	ff 75 0c             	pushl  0xc(%ebp)
  80029d:	ff 75 08             	pushl  0x8(%ebp)
  8002a0:	e8 05 00 00 00       	call   8002aa <vprintfmt>
	va_end(ap);
}
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	57                   	push   %edi
  8002ae:	56                   	push   %esi
  8002af:	53                   	push   %ebx
  8002b0:	83 ec 2c             	sub    $0x2c,%esp
  8002b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002bc:	eb 12                	jmp    8002d0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	0f 84 38 04 00 00    	je     8006fe <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8002c6:	83 ec 08             	sub    $0x8,%esp
  8002c9:	53                   	push   %ebx
  8002ca:	50                   	push   %eax
  8002cb:	ff d6                	call   *%esi
  8002cd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d0:	83 c7 01             	add    $0x1,%edi
  8002d3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d7:	83 f8 25             	cmp    $0x25,%eax
  8002da:	75 e2                	jne    8002be <vprintfmt+0x14>
  8002dc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002ee:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fa:	eb 07                	jmp    800303 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8002ff:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8d 47 01             	lea    0x1(%edi),%eax
  800306:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800309:	0f b6 07             	movzbl (%edi),%eax
  80030c:	0f b6 c8             	movzbl %al,%ecx
  80030f:	83 e8 23             	sub    $0x23,%eax
  800312:	3c 55                	cmp    $0x55,%al
  800314:	0f 87 c9 03 00 00    	ja     8006e3 <vprintfmt+0x439>
  80031a:	0f b6 c0             	movzbl %al,%eax
  80031d:	ff 24 85 40 21 80 00 	jmp    *0x802140(,%eax,4)
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800327:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032b:	eb d6                	jmp    800303 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  80032d:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  800334:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800337:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  80033a:	eb 94                	jmp    8002d0 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  80033c:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  800343:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  800349:	eb 85                	jmp    8002d0 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  80034b:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  800352:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  800358:	e9 73 ff ff ff       	jmp    8002d0 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  80035d:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  800364:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  80036a:	e9 61 ff ff ff       	jmp    8002d0 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  80036f:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800376:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  80037c:	e9 4f ff ff ff       	jmp    8002d0 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  800381:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800388:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80038e:	e9 3d ff ff ff       	jmp    8002d0 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  800393:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  80039a:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  8003a0:	e9 2b ff ff ff       	jmp    8002d0 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  8003a5:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  8003ac:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8003b2:	e9 19 ff ff ff       	jmp    8002d0 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  8003b7:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  8003be:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8003c4:	e9 07 ff ff ff       	jmp    8002d0 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8003c9:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  8003d0:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8003d6:	e9 f5 fe ff ff       	jmp    8002d0 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003de:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003e9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ed:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f3:	83 fa 09             	cmp    $0x9,%edx
  8003f6:	77 3f                	ja     800437 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003fb:	eb e9                	jmp    8003e6 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	8d 48 04             	lea    0x4(%eax),%ecx
  800403:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800406:	8b 00                	mov    (%eax),%eax
  800408:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80040e:	eb 2d                	jmp    80043d <vprintfmt+0x193>
  800410:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800413:	85 c0                	test   %eax,%eax
  800415:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041a:	0f 49 c8             	cmovns %eax,%ecx
  80041d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800423:	e9 db fe ff ff       	jmp    800303 <vprintfmt+0x59>
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800432:	e9 cc fe ff ff       	jmp    800303 <vprintfmt+0x59>
  800437:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80043a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80043d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800441:	0f 89 bc fe ff ff    	jns    800303 <vprintfmt+0x59>
				width = precision, precision = -1;
  800447:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80044a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800454:	e9 aa fe ff ff       	jmp    800303 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800459:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045f:	e9 9f fe ff ff       	jmp    800303 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8d 50 04             	lea    0x4(%eax),%edx
  80046a:	89 55 14             	mov    %edx,0x14(%ebp)
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	53                   	push   %ebx
  800471:	ff 30                	pushl  (%eax)
  800473:	ff d6                	call   *%esi
			break;
  800475:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047b:	e9 50 fe ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	8b 00                	mov    (%eax),%eax
  80048b:	99                   	cltd   
  80048c:	31 d0                	xor    %edx,%eax
  80048e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800490:	83 f8 0f             	cmp    $0xf,%eax
  800493:	7f 0b                	jg     8004a0 <vprintfmt+0x1f6>
  800495:	8b 14 85 a0 22 80 00 	mov    0x8022a0(,%eax,4),%edx
  80049c:	85 d2                	test   %edx,%edx
  80049e:	75 18                	jne    8004b8 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  8004a0:	50                   	push   %eax
  8004a1:	68 1e 20 80 00       	push   $0x80201e
  8004a6:	53                   	push   %ebx
  8004a7:	56                   	push   %esi
  8004a8:	e8 e0 fd ff ff       	call   80028d <printfmt>
  8004ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b3:	e9 18 fe ff ff       	jmp    8002d0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b8:	52                   	push   %edx
  8004b9:	68 11 24 80 00       	push   $0x802411
  8004be:	53                   	push   %ebx
  8004bf:	56                   	push   %esi
  8004c0:	e8 c8 fd ff ff       	call   80028d <printfmt>
  8004c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cb:	e9 00 fe ff ff       	jmp    8002d0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d3:	8d 50 04             	lea    0x4(%eax),%edx
  8004d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004db:	85 ff                	test   %edi,%edi
  8004dd:	b8 17 20 80 00       	mov    $0x802017,%eax
  8004e2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e9:	0f 8e 94 00 00 00    	jle    800583 <vprintfmt+0x2d9>
  8004ef:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f3:	0f 84 98 00 00 00    	je     800591 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ff:	57                   	push   %edi
  800500:	e8 81 02 00 00       	call   800786 <strnlen>
  800505:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800508:	29 c1                	sub    %eax,%ecx
  80050a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80050d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800510:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800514:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800517:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80051a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051c:	eb 0f                	jmp    80052d <vprintfmt+0x283>
					putch(padc, putdat);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	53                   	push   %ebx
  800522:	ff 75 e0             	pushl  -0x20(%ebp)
  800525:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800527:	83 ef 01             	sub    $0x1,%edi
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	85 ff                	test   %edi,%edi
  80052f:	7f ed                	jg     80051e <vprintfmt+0x274>
  800531:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800534:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800537:	85 c9                	test   %ecx,%ecx
  800539:	b8 00 00 00 00       	mov    $0x0,%eax
  80053e:	0f 49 c1             	cmovns %ecx,%eax
  800541:	29 c1                	sub    %eax,%ecx
  800543:	89 75 08             	mov    %esi,0x8(%ebp)
  800546:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800549:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054c:	89 cb                	mov    %ecx,%ebx
  80054e:	eb 4d                	jmp    80059d <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800550:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800554:	74 1b                	je     800571 <vprintfmt+0x2c7>
  800556:	0f be c0             	movsbl %al,%eax
  800559:	83 e8 20             	sub    $0x20,%eax
  80055c:	83 f8 5e             	cmp    $0x5e,%eax
  80055f:	76 10                	jbe    800571 <vprintfmt+0x2c7>
					putch('?', putdat);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	ff 75 0c             	pushl  0xc(%ebp)
  800567:	6a 3f                	push   $0x3f
  800569:	ff 55 08             	call   *0x8(%ebp)
  80056c:	83 c4 10             	add    $0x10,%esp
  80056f:	eb 0d                	jmp    80057e <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	ff 75 0c             	pushl  0xc(%ebp)
  800577:	52                   	push   %edx
  800578:	ff 55 08             	call   *0x8(%ebp)
  80057b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057e:	83 eb 01             	sub    $0x1,%ebx
  800581:	eb 1a                	jmp    80059d <vprintfmt+0x2f3>
  800583:	89 75 08             	mov    %esi,0x8(%ebp)
  800586:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800589:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058f:	eb 0c                	jmp    80059d <vprintfmt+0x2f3>
  800591:	89 75 08             	mov    %esi,0x8(%ebp)
  800594:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800597:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059d:	83 c7 01             	add    $0x1,%edi
  8005a0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a4:	0f be d0             	movsbl %al,%edx
  8005a7:	85 d2                	test   %edx,%edx
  8005a9:	74 23                	je     8005ce <vprintfmt+0x324>
  8005ab:	85 f6                	test   %esi,%esi
  8005ad:	78 a1                	js     800550 <vprintfmt+0x2a6>
  8005af:	83 ee 01             	sub    $0x1,%esi
  8005b2:	79 9c                	jns    800550 <vprintfmt+0x2a6>
  8005b4:	89 df                	mov    %ebx,%edi
  8005b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bc:	eb 18                	jmp    8005d6 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	53                   	push   %ebx
  8005c2:	6a 20                	push   $0x20
  8005c4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c6:	83 ef 01             	sub    $0x1,%edi
  8005c9:	83 c4 10             	add    $0x10,%esp
  8005cc:	eb 08                	jmp    8005d6 <vprintfmt+0x32c>
  8005ce:	89 df                	mov    %ebx,%edi
  8005d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d6:	85 ff                	test   %edi,%edi
  8005d8:	7f e4                	jg     8005be <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dd:	e9 ee fc ff ff       	jmp    8002d0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e2:	83 fa 01             	cmp    $0x1,%edx
  8005e5:	7e 16                	jle    8005fd <vprintfmt+0x353>
		return va_arg(*ap, long long);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 50 08             	lea    0x8(%eax),%edx
  8005ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f0:	8b 50 04             	mov    0x4(%eax),%edx
  8005f3:	8b 00                	mov    (%eax),%eax
  8005f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fb:	eb 32                	jmp    80062f <vprintfmt+0x385>
	else if (lflag)
  8005fd:	85 d2                	test   %edx,%edx
  8005ff:	74 18                	je     800619 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8d 50 04             	lea    0x4(%eax),%edx
  800607:	89 55 14             	mov    %edx,0x14(%ebp)
  80060a:	8b 00                	mov    (%eax),%eax
  80060c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060f:	89 c1                	mov    %eax,%ecx
  800611:	c1 f9 1f             	sar    $0x1f,%ecx
  800614:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800617:	eb 16                	jmp    80062f <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8d 50 04             	lea    0x4(%eax),%edx
  80061f:	89 55 14             	mov    %edx,0x14(%ebp)
  800622:	8b 00                	mov    (%eax),%eax
  800624:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800627:	89 c1                	mov    %eax,%ecx
  800629:	c1 f9 1f             	sar    $0x1f,%ecx
  80062c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800632:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800635:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063e:	79 6f                	jns    8006af <vprintfmt+0x405>
				putch('-', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	53                   	push   %ebx
  800644:	6a 2d                	push   $0x2d
  800646:	ff d6                	call   *%esi
				num = -(long long) num;
  800648:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80064e:	f7 d8                	neg    %eax
  800650:	83 d2 00             	adc    $0x0,%edx
  800653:	f7 da                	neg    %edx
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	eb 55                	jmp    8006af <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80065a:	8d 45 14             	lea    0x14(%ebp),%eax
  80065d:	e8 d4 fb ff ff       	call   800236 <getuint>
			base = 10;
  800662:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800667:	eb 46                	jmp    8006af <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800669:	8d 45 14             	lea    0x14(%ebp),%eax
  80066c:	e8 c5 fb ff ff       	call   800236 <getuint>
			base = 8;
  800671:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800676:	eb 37                	jmp    8006af <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	6a 30                	push   $0x30
  80067e:	ff d6                	call   *%esi
			putch('x', putdat);
  800680:	83 c4 08             	add    $0x8,%esp
  800683:	53                   	push   %ebx
  800684:	6a 78                	push   $0x78
  800686:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8d 50 04             	lea    0x4(%eax),%edx
  80068e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800691:	8b 00                	mov    (%eax),%eax
  800693:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800698:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80069b:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8006a0:	eb 0d                	jmp    8006af <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a5:	e8 8c fb ff ff       	call   800236 <getuint>
			base = 16;
  8006aa:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006af:	83 ec 0c             	sub    $0xc,%esp
  8006b2:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8006b6:	51                   	push   %ecx
  8006b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ba:	57                   	push   %edi
  8006bb:	52                   	push   %edx
  8006bc:	50                   	push   %eax
  8006bd:	89 da                	mov    %ebx,%edx
  8006bf:	89 f0                	mov    %esi,%eax
  8006c1:	e8 c1 fa ff ff       	call   800187 <printnum>
			break;
  8006c6:	83 c4 20             	add    $0x20,%esp
  8006c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006cc:	e9 ff fb ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d1:	83 ec 08             	sub    $0x8,%esp
  8006d4:	53                   	push   %ebx
  8006d5:	51                   	push   %ecx
  8006d6:	ff d6                	call   *%esi
			break;
  8006d8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006de:	e9 ed fb ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	53                   	push   %ebx
  8006e7:	6a 25                	push   $0x25
  8006e9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	eb 03                	jmp    8006f3 <vprintfmt+0x449>
  8006f0:	83 ef 01             	sub    $0x1,%edi
  8006f3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f7:	75 f7                	jne    8006f0 <vprintfmt+0x446>
  8006f9:	e9 d2 fb ff ff       	jmp    8002d0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800701:	5b                   	pop    %ebx
  800702:	5e                   	pop    %esi
  800703:	5f                   	pop    %edi
  800704:	5d                   	pop    %ebp
  800705:	c3                   	ret    

00800706 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	83 ec 18             	sub    $0x18,%esp
  80070c:	8b 45 08             	mov    0x8(%ebp),%eax
  80070f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800712:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800715:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800719:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800723:	85 c0                	test   %eax,%eax
  800725:	74 26                	je     80074d <vsnprintf+0x47>
  800727:	85 d2                	test   %edx,%edx
  800729:	7e 22                	jle    80074d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072b:	ff 75 14             	pushl  0x14(%ebp)
  80072e:	ff 75 10             	pushl  0x10(%ebp)
  800731:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	68 70 02 80 00       	push   $0x800270
  80073a:	e8 6b fb ff ff       	call   8002aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800742:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800745:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	eb 05                	jmp    800752 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075d:	50                   	push   %eax
  80075e:	ff 75 10             	pushl  0x10(%ebp)
  800761:	ff 75 0c             	pushl  0xc(%ebp)
  800764:	ff 75 08             	pushl  0x8(%ebp)
  800767:	e8 9a ff ff ff       	call   800706 <vsnprintf>
	va_end(ap);

	return rc;
}
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    

0080076e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800774:	b8 00 00 00 00       	mov    $0x0,%eax
  800779:	eb 03                	jmp    80077e <strlen+0x10>
		n++;
  80077b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80077e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800782:	75 f7                	jne    80077b <strlen+0xd>
		n++;
	return n;
}
  800784:	5d                   	pop    %ebp
  800785:	c3                   	ret    

00800786 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078f:	ba 00 00 00 00       	mov    $0x0,%edx
  800794:	eb 03                	jmp    800799 <strnlen+0x13>
		n++;
  800796:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800799:	39 c2                	cmp    %eax,%edx
  80079b:	74 08                	je     8007a5 <strnlen+0x1f>
  80079d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a1:	75 f3                	jne    800796 <strnlen+0x10>
  8007a3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b1:	89 c2                	mov    %eax,%edx
  8007b3:	83 c2 01             	add    $0x1,%edx
  8007b6:	83 c1 01             	add    $0x1,%ecx
  8007b9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007bd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c0:	84 db                	test   %bl,%bl
  8007c2:	75 ef                	jne    8007b3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c4:	5b                   	pop    %ebx
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	53                   	push   %ebx
  8007cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ce:	53                   	push   %ebx
  8007cf:	e8 9a ff ff ff       	call   80076e <strlen>
  8007d4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007d7:	ff 75 0c             	pushl  0xc(%ebp)
  8007da:	01 d8                	add    %ebx,%eax
  8007dc:	50                   	push   %eax
  8007dd:	e8 c5 ff ff ff       	call   8007a7 <strcpy>
	return dst;
}
  8007e2:	89 d8                	mov    %ebx,%eax
  8007e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    

008007e9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	56                   	push   %esi
  8007ed:	53                   	push   %ebx
  8007ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f4:	89 f3                	mov    %esi,%ebx
  8007f6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f9:	89 f2                	mov    %esi,%edx
  8007fb:	eb 0f                	jmp    80080c <strncpy+0x23>
		*dst++ = *src;
  8007fd:	83 c2 01             	add    $0x1,%edx
  800800:	0f b6 01             	movzbl (%ecx),%eax
  800803:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800806:	80 39 01             	cmpb   $0x1,(%ecx)
  800809:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080c:	39 da                	cmp    %ebx,%edx
  80080e:	75 ed                	jne    8007fd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800810:	89 f0                	mov    %esi,%eax
  800812:	5b                   	pop    %ebx
  800813:	5e                   	pop    %esi
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	56                   	push   %esi
  80081a:	53                   	push   %ebx
  80081b:	8b 75 08             	mov    0x8(%ebp),%esi
  80081e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800821:	8b 55 10             	mov    0x10(%ebp),%edx
  800824:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800826:	85 d2                	test   %edx,%edx
  800828:	74 21                	je     80084b <strlcpy+0x35>
  80082a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80082e:	89 f2                	mov    %esi,%edx
  800830:	eb 09                	jmp    80083b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800832:	83 c2 01             	add    $0x1,%edx
  800835:	83 c1 01             	add    $0x1,%ecx
  800838:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80083b:	39 c2                	cmp    %eax,%edx
  80083d:	74 09                	je     800848 <strlcpy+0x32>
  80083f:	0f b6 19             	movzbl (%ecx),%ebx
  800842:	84 db                	test   %bl,%bl
  800844:	75 ec                	jne    800832 <strlcpy+0x1c>
  800846:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800848:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084b:	29 f0                	sub    %esi,%eax
}
  80084d:	5b                   	pop    %ebx
  80084e:	5e                   	pop    %esi
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800857:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085a:	eb 06                	jmp    800862 <strcmp+0x11>
		p++, q++;
  80085c:	83 c1 01             	add    $0x1,%ecx
  80085f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800862:	0f b6 01             	movzbl (%ecx),%eax
  800865:	84 c0                	test   %al,%al
  800867:	74 04                	je     80086d <strcmp+0x1c>
  800869:	3a 02                	cmp    (%edx),%al
  80086b:	74 ef                	je     80085c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086d:	0f b6 c0             	movzbl %al,%eax
  800870:	0f b6 12             	movzbl (%edx),%edx
  800873:	29 d0                	sub    %edx,%eax
}
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800881:	89 c3                	mov    %eax,%ebx
  800883:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800886:	eb 06                	jmp    80088e <strncmp+0x17>
		n--, p++, q++;
  800888:	83 c0 01             	add    $0x1,%eax
  80088b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80088e:	39 d8                	cmp    %ebx,%eax
  800890:	74 15                	je     8008a7 <strncmp+0x30>
  800892:	0f b6 08             	movzbl (%eax),%ecx
  800895:	84 c9                	test   %cl,%cl
  800897:	74 04                	je     80089d <strncmp+0x26>
  800899:	3a 0a                	cmp    (%edx),%cl
  80089b:	74 eb                	je     800888 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089d:	0f b6 00             	movzbl (%eax),%eax
  8008a0:	0f b6 12             	movzbl (%edx),%edx
  8008a3:	29 d0                	sub    %edx,%eax
  8008a5:	eb 05                	jmp    8008ac <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ac:	5b                   	pop    %ebx
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b9:	eb 07                	jmp    8008c2 <strchr+0x13>
		if (*s == c)
  8008bb:	38 ca                	cmp    %cl,%dl
  8008bd:	74 0f                	je     8008ce <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008bf:	83 c0 01             	add    $0x1,%eax
  8008c2:	0f b6 10             	movzbl (%eax),%edx
  8008c5:	84 d2                	test   %dl,%dl
  8008c7:	75 f2                	jne    8008bb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008da:	eb 03                	jmp    8008df <strfind+0xf>
  8008dc:	83 c0 01             	add    $0x1,%eax
  8008df:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e2:	38 ca                	cmp    %cl,%dl
  8008e4:	74 04                	je     8008ea <strfind+0x1a>
  8008e6:	84 d2                	test   %dl,%dl
  8008e8:	75 f2                	jne    8008dc <strfind+0xc>
			break;
	return (char *) s;
}
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	57                   	push   %edi
  8008f0:	56                   	push   %esi
  8008f1:	53                   	push   %ebx
  8008f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f8:	85 c9                	test   %ecx,%ecx
  8008fa:	74 36                	je     800932 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008fc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800902:	75 28                	jne    80092c <memset+0x40>
  800904:	f6 c1 03             	test   $0x3,%cl
  800907:	75 23                	jne    80092c <memset+0x40>
		c &= 0xFF;
  800909:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80090d:	89 d3                	mov    %edx,%ebx
  80090f:	c1 e3 08             	shl    $0x8,%ebx
  800912:	89 d6                	mov    %edx,%esi
  800914:	c1 e6 18             	shl    $0x18,%esi
  800917:	89 d0                	mov    %edx,%eax
  800919:	c1 e0 10             	shl    $0x10,%eax
  80091c:	09 f0                	or     %esi,%eax
  80091e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800920:	89 d8                	mov    %ebx,%eax
  800922:	09 d0                	or     %edx,%eax
  800924:	c1 e9 02             	shr    $0x2,%ecx
  800927:	fc                   	cld    
  800928:	f3 ab                	rep stos %eax,%es:(%edi)
  80092a:	eb 06                	jmp    800932 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80092c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092f:	fc                   	cld    
  800930:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800932:	89 f8                	mov    %edi,%eax
  800934:	5b                   	pop    %ebx
  800935:	5e                   	pop    %esi
  800936:	5f                   	pop    %edi
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	57                   	push   %edi
  80093d:	56                   	push   %esi
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8b 75 0c             	mov    0xc(%ebp),%esi
  800944:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800947:	39 c6                	cmp    %eax,%esi
  800949:	73 35                	jae    800980 <memmove+0x47>
  80094b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80094e:	39 d0                	cmp    %edx,%eax
  800950:	73 2e                	jae    800980 <memmove+0x47>
		s += n;
		d += n;
  800952:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800955:	89 d6                	mov    %edx,%esi
  800957:	09 fe                	or     %edi,%esi
  800959:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095f:	75 13                	jne    800974 <memmove+0x3b>
  800961:	f6 c1 03             	test   $0x3,%cl
  800964:	75 0e                	jne    800974 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800966:	83 ef 04             	sub    $0x4,%edi
  800969:	8d 72 fc             	lea    -0x4(%edx),%esi
  80096c:	c1 e9 02             	shr    $0x2,%ecx
  80096f:	fd                   	std    
  800970:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800972:	eb 09                	jmp    80097d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800974:	83 ef 01             	sub    $0x1,%edi
  800977:	8d 72 ff             	lea    -0x1(%edx),%esi
  80097a:	fd                   	std    
  80097b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80097d:	fc                   	cld    
  80097e:	eb 1d                	jmp    80099d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800980:	89 f2                	mov    %esi,%edx
  800982:	09 c2                	or     %eax,%edx
  800984:	f6 c2 03             	test   $0x3,%dl
  800987:	75 0f                	jne    800998 <memmove+0x5f>
  800989:	f6 c1 03             	test   $0x3,%cl
  80098c:	75 0a                	jne    800998 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80098e:	c1 e9 02             	shr    $0x2,%ecx
  800991:	89 c7                	mov    %eax,%edi
  800993:	fc                   	cld    
  800994:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800996:	eb 05                	jmp    80099d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800998:	89 c7                	mov    %eax,%edi
  80099a:	fc                   	cld    
  80099b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80099d:	5e                   	pop    %esi
  80099e:	5f                   	pop    %edi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a4:	ff 75 10             	pushl  0x10(%ebp)
  8009a7:	ff 75 0c             	pushl  0xc(%ebp)
  8009aa:	ff 75 08             	pushl  0x8(%ebp)
  8009ad:	e8 87 ff ff ff       	call   800939 <memmove>
}
  8009b2:	c9                   	leave  
  8009b3:	c3                   	ret    

008009b4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	56                   	push   %esi
  8009b8:	53                   	push   %ebx
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bf:	89 c6                	mov    %eax,%esi
  8009c1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c4:	eb 1a                	jmp    8009e0 <memcmp+0x2c>
		if (*s1 != *s2)
  8009c6:	0f b6 08             	movzbl (%eax),%ecx
  8009c9:	0f b6 1a             	movzbl (%edx),%ebx
  8009cc:	38 d9                	cmp    %bl,%cl
  8009ce:	74 0a                	je     8009da <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d0:	0f b6 c1             	movzbl %cl,%eax
  8009d3:	0f b6 db             	movzbl %bl,%ebx
  8009d6:	29 d8                	sub    %ebx,%eax
  8009d8:	eb 0f                	jmp    8009e9 <memcmp+0x35>
		s1++, s2++;
  8009da:	83 c0 01             	add    $0x1,%eax
  8009dd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e0:	39 f0                	cmp    %esi,%eax
  8009e2:	75 e2                	jne    8009c6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e9:	5b                   	pop    %ebx
  8009ea:	5e                   	pop    %esi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	53                   	push   %ebx
  8009f1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f4:	89 c1                	mov    %eax,%ecx
  8009f6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fd:	eb 0a                	jmp    800a09 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ff:	0f b6 10             	movzbl (%eax),%edx
  800a02:	39 da                	cmp    %ebx,%edx
  800a04:	74 07                	je     800a0d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a06:	83 c0 01             	add    $0x1,%eax
  800a09:	39 c8                	cmp    %ecx,%eax
  800a0b:	72 f2                	jb     8009ff <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a0d:	5b                   	pop    %ebx
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	57                   	push   %edi
  800a14:	56                   	push   %esi
  800a15:	53                   	push   %ebx
  800a16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1c:	eb 03                	jmp    800a21 <strtol+0x11>
		s++;
  800a1e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a21:	0f b6 01             	movzbl (%ecx),%eax
  800a24:	3c 20                	cmp    $0x20,%al
  800a26:	74 f6                	je     800a1e <strtol+0xe>
  800a28:	3c 09                	cmp    $0x9,%al
  800a2a:	74 f2                	je     800a1e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a2c:	3c 2b                	cmp    $0x2b,%al
  800a2e:	75 0a                	jne    800a3a <strtol+0x2a>
		s++;
  800a30:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a33:	bf 00 00 00 00       	mov    $0x0,%edi
  800a38:	eb 11                	jmp    800a4b <strtol+0x3b>
  800a3a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a3f:	3c 2d                	cmp    $0x2d,%al
  800a41:	75 08                	jne    800a4b <strtol+0x3b>
		s++, neg = 1;
  800a43:	83 c1 01             	add    $0x1,%ecx
  800a46:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a51:	75 15                	jne    800a68 <strtol+0x58>
  800a53:	80 39 30             	cmpb   $0x30,(%ecx)
  800a56:	75 10                	jne    800a68 <strtol+0x58>
  800a58:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a5c:	75 7c                	jne    800ada <strtol+0xca>
		s += 2, base = 16;
  800a5e:	83 c1 02             	add    $0x2,%ecx
  800a61:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a66:	eb 16                	jmp    800a7e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a68:	85 db                	test   %ebx,%ebx
  800a6a:	75 12                	jne    800a7e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a71:	80 39 30             	cmpb   $0x30,(%ecx)
  800a74:	75 08                	jne    800a7e <strtol+0x6e>
		s++, base = 8;
  800a76:	83 c1 01             	add    $0x1,%ecx
  800a79:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a83:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a86:	0f b6 11             	movzbl (%ecx),%edx
  800a89:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a8c:	89 f3                	mov    %esi,%ebx
  800a8e:	80 fb 09             	cmp    $0x9,%bl
  800a91:	77 08                	ja     800a9b <strtol+0x8b>
			dig = *s - '0';
  800a93:	0f be d2             	movsbl %dl,%edx
  800a96:	83 ea 30             	sub    $0x30,%edx
  800a99:	eb 22                	jmp    800abd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a9b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a9e:	89 f3                	mov    %esi,%ebx
  800aa0:	80 fb 19             	cmp    $0x19,%bl
  800aa3:	77 08                	ja     800aad <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aa5:	0f be d2             	movsbl %dl,%edx
  800aa8:	83 ea 57             	sub    $0x57,%edx
  800aab:	eb 10                	jmp    800abd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aad:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab0:	89 f3                	mov    %esi,%ebx
  800ab2:	80 fb 19             	cmp    $0x19,%bl
  800ab5:	77 16                	ja     800acd <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ab7:	0f be d2             	movsbl %dl,%edx
  800aba:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800abd:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac0:	7d 0b                	jge    800acd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac2:	83 c1 01             	add    $0x1,%ecx
  800ac5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800acb:	eb b9                	jmp    800a86 <strtol+0x76>

	if (endptr)
  800acd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad1:	74 0d                	je     800ae0 <strtol+0xd0>
		*endptr = (char *) s;
  800ad3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad6:	89 0e                	mov    %ecx,(%esi)
  800ad8:	eb 06                	jmp    800ae0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ada:	85 db                	test   %ebx,%ebx
  800adc:	74 98                	je     800a76 <strtol+0x66>
  800ade:	eb 9e                	jmp    800a7e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae0:	89 c2                	mov    %eax,%edx
  800ae2:	f7 da                	neg    %edx
  800ae4:	85 ff                	test   %edi,%edi
  800ae6:	0f 45 c2             	cmovne %edx,%eax
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	83 ec 04             	sub    $0x4,%esp
  800af7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800afa:	57                   	push   %edi
  800afb:	e8 6e fc ff ff       	call   80076e <strlen>
  800b00:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b03:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800b06:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b10:	eb 46                	jmp    800b58 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800b12:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800b16:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b19:	80 f9 09             	cmp    $0x9,%cl
  800b1c:	77 08                	ja     800b26 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800b1e:	0f be d2             	movsbl %dl,%edx
  800b21:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b24:	eb 27                	jmp    800b4d <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800b26:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800b29:	80 f9 05             	cmp    $0x5,%cl
  800b2c:	77 08                	ja     800b36 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800b2e:	0f be d2             	movsbl %dl,%edx
  800b31:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800b34:	eb 17                	jmp    800b4d <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800b36:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800b39:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800b3c:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800b41:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800b45:	77 06                	ja     800b4d <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800b47:	0f be d2             	movsbl %dl,%edx
  800b4a:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800b4d:	0f af ce             	imul   %esi,%ecx
  800b50:	01 c8                	add    %ecx,%eax
		base *= 16;
  800b52:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b55:	83 eb 01             	sub    $0x1,%ebx
  800b58:	83 fb 01             	cmp    $0x1,%ebx
  800b5b:	7f b5                	jg     800b12 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800b5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
  800b76:	89 c3                	mov    %eax,%ebx
  800b78:	89 c7                	mov    %eax,%edi
  800b7a:	89 c6                	mov    %eax,%esi
  800b7c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b93:	89 d1                	mov    %edx,%ecx
  800b95:	89 d3                	mov    %edx,%ebx
  800b97:	89 d7                	mov    %edx,%edi
  800b99:	89 d6                	mov    %edx,%esi
  800b9b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bab:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb0:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb8:	89 cb                	mov    %ecx,%ebx
  800bba:	89 cf                	mov    %ecx,%edi
  800bbc:	89 ce                	mov    %ecx,%esi
  800bbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	7e 17                	jle    800bdb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc4:	83 ec 0c             	sub    $0xc,%esp
  800bc7:	50                   	push   %eax
  800bc8:	6a 03                	push   $0x3
  800bca:	68 ff 22 80 00       	push   $0x8022ff
  800bcf:	6a 23                	push   $0x23
  800bd1:	68 1c 23 80 00       	push   $0x80231c
  800bd6:	e8 f8 0f 00 00       	call   801bd3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bee:	b8 02 00 00 00       	mov    $0x2,%eax
  800bf3:	89 d1                	mov    %edx,%ecx
  800bf5:	89 d3                	mov    %edx,%ebx
  800bf7:	89 d7                	mov    %edx,%edi
  800bf9:	89 d6                	mov    %edx,%esi
  800bfb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <sys_yield>:

void
sys_yield(void)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c08:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c12:	89 d1                	mov    %edx,%ecx
  800c14:	89 d3                	mov    %edx,%ebx
  800c16:	89 d7                	mov    %edx,%edi
  800c18:	89 d6                	mov    %edx,%esi
  800c1a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	be 00 00 00 00       	mov    $0x0,%esi
  800c2f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3d:	89 f7                	mov    %esi,%edi
  800c3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c41:	85 c0                	test   %eax,%eax
  800c43:	7e 17                	jle    800c5c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c45:	83 ec 0c             	sub    $0xc,%esp
  800c48:	50                   	push   %eax
  800c49:	6a 04                	push   $0x4
  800c4b:	68 ff 22 80 00       	push   $0x8022ff
  800c50:	6a 23                	push   $0x23
  800c52:	68 1c 23 80 00       	push   $0x80231c
  800c57:	e8 77 0f 00 00       	call   801bd3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	b8 05 00 00 00       	mov    $0x5,%eax
  800c72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c75:	8b 55 08             	mov    0x8(%ebp),%edx
  800c78:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7e:	8b 75 18             	mov    0x18(%ebp),%esi
  800c81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c83:	85 c0                	test   %eax,%eax
  800c85:	7e 17                	jle    800c9e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c87:	83 ec 0c             	sub    $0xc,%esp
  800c8a:	50                   	push   %eax
  800c8b:	6a 05                	push   $0x5
  800c8d:	68 ff 22 80 00       	push   $0x8022ff
  800c92:	6a 23                	push   $0x23
  800c94:	68 1c 23 80 00       	push   $0x80231c
  800c99:	e8 35 0f 00 00       	call   801bd3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb4:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	89 df                	mov    %ebx,%edi
  800cc1:	89 de                	mov    %ebx,%esi
  800cc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7e 17                	jle    800ce0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	50                   	push   %eax
  800ccd:	6a 06                	push   $0x6
  800ccf:	68 ff 22 80 00       	push   $0x8022ff
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 1c 23 80 00       	push   $0x80231c
  800cdb:	e8 f3 0e 00 00       	call   801bd3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf6:	b8 08 00 00 00       	mov    $0x8,%eax
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	89 df                	mov    %ebx,%edi
  800d03:	89 de                	mov    %ebx,%esi
  800d05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7e 17                	jle    800d22 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 08                	push   $0x8
  800d11:	68 ff 22 80 00       	push   $0x8022ff
  800d16:	6a 23                	push   $0x23
  800d18:	68 1c 23 80 00       	push   $0x80231c
  800d1d:	e8 b1 0e 00 00       	call   801bd3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d38:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 df                	mov    %ebx,%edi
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7e 17                	jle    800d64 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4d:	83 ec 0c             	sub    $0xc,%esp
  800d50:	50                   	push   %eax
  800d51:	6a 0a                	push   $0xa
  800d53:	68 ff 22 80 00       	push   $0x8022ff
  800d58:	6a 23                	push   $0x23
  800d5a:	68 1c 23 80 00       	push   $0x80231c
  800d5f:	e8 6f 0e 00 00       	call   801bd3 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	89 df                	mov    %ebx,%edi
  800d87:	89 de                	mov    %ebx,%esi
  800d89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7e 17                	jle    800da6 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8f:	83 ec 0c             	sub    $0xc,%esp
  800d92:	50                   	push   %eax
  800d93:	6a 09                	push   $0x9
  800d95:	68 ff 22 80 00       	push   $0x8022ff
  800d9a:	6a 23                	push   $0x23
  800d9c:	68 1c 23 80 00       	push   $0x80231c
  800da1:	e8 2d 0e 00 00       	call   801bd3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db4:	be 00 00 00 00       	mov    $0x0,%esi
  800db9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dca:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dcc:	5b                   	pop    %ebx
  800dcd:	5e                   	pop    %esi
  800dce:	5f                   	pop    %edi
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	57                   	push   %edi
  800dd5:	56                   	push   %esi
  800dd6:	53                   	push   %ebx
  800dd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dda:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ddf:	b8 0d 00 00 00       	mov    $0xd,%eax
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	89 cb                	mov    %ecx,%ebx
  800de9:	89 cf                	mov    %ecx,%edi
  800deb:	89 ce                	mov    %ecx,%esi
  800ded:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800def:	85 c0                	test   %eax,%eax
  800df1:	7e 17                	jle    800e0a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	50                   	push   %eax
  800df7:	6a 0d                	push   $0xd
  800df9:	68 ff 22 80 00       	push   $0x8022ff
  800dfe:	6a 23                	push   $0x23
  800e00:	68 1c 23 80 00       	push   $0x80231c
  800e05:	e8 c9 0d 00 00       	call   801bd3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  800e18:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800e1f:	75 52                	jne    800e73 <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  800e21:	83 ec 04             	sub    $0x4,%esp
  800e24:	6a 07                	push   $0x7
  800e26:	68 00 f0 bf ee       	push   $0xeebff000
  800e2b:	6a 00                	push   $0x0
  800e2d:	e8 ef fd ff ff       	call   800c21 <sys_page_alloc>
  800e32:	83 c4 10             	add    $0x10,%esp
  800e35:	85 c0                	test   %eax,%eax
  800e37:	79 12                	jns    800e4b <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  800e39:	50                   	push   %eax
  800e3a:	68 2a 23 80 00       	push   $0x80232a
  800e3f:	6a 23                	push   $0x23
  800e41:	68 3d 23 80 00       	push   $0x80233d
  800e46:	e8 88 0d 00 00       	call   801bd3 <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  800e4b:	83 ec 08             	sub    $0x8,%esp
  800e4e:	68 7d 0e 80 00       	push   $0x800e7d
  800e53:	6a 00                	push   $0x0
  800e55:	e8 12 ff ff ff       	call   800d6c <sys_env_set_pgfault_upcall>
  800e5a:	83 c4 10             	add    $0x10,%esp
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	79 12                	jns    800e73 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  800e61:	50                   	push   %eax
  800e62:	68 4c 23 80 00       	push   $0x80234c
  800e67:	6a 26                	push   $0x26
  800e69:	68 3d 23 80 00       	push   $0x80233d
  800e6e:	e8 60 0d 00 00       	call   801bd3 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e73:	8b 45 08             	mov    0x8(%ebp),%eax
  800e76:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800e7b:	c9                   	leave  
  800e7c:	c3                   	ret    

00800e7d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e7d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e7e:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800e83:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e85:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  800e88:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  800e8c:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  800e91:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  800e95:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800e97:	83 c4 08             	add    $0x8,%esp
	popal 
  800e9a:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800e9b:	83 c4 04             	add    $0x4,%esp
	popfl
  800e9e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e9f:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800ea0:	c3                   	ret    

00800ea1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea7:	05 00 00 00 30       	add    $0x30000000,%eax
  800eac:	c1 e8 0c             	shr    $0xc,%eax
}
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb7:	05 00 00 00 30       	add    $0x30000000,%eax
  800ebc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ec1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ece:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ed3:	89 c2                	mov    %eax,%edx
  800ed5:	c1 ea 16             	shr    $0x16,%edx
  800ed8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800edf:	f6 c2 01             	test   $0x1,%dl
  800ee2:	74 11                	je     800ef5 <fd_alloc+0x2d>
  800ee4:	89 c2                	mov    %eax,%edx
  800ee6:	c1 ea 0c             	shr    $0xc,%edx
  800ee9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef0:	f6 c2 01             	test   $0x1,%dl
  800ef3:	75 09                	jne    800efe <fd_alloc+0x36>
			*fd_store = fd;
  800ef5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef7:	b8 00 00 00 00       	mov    $0x0,%eax
  800efc:	eb 17                	jmp    800f15 <fd_alloc+0x4d>
  800efe:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f03:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f08:	75 c9                	jne    800ed3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f0a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f10:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f1d:	83 f8 1f             	cmp    $0x1f,%eax
  800f20:	77 36                	ja     800f58 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f22:	c1 e0 0c             	shl    $0xc,%eax
  800f25:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f2a:	89 c2                	mov    %eax,%edx
  800f2c:	c1 ea 16             	shr    $0x16,%edx
  800f2f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f36:	f6 c2 01             	test   $0x1,%dl
  800f39:	74 24                	je     800f5f <fd_lookup+0x48>
  800f3b:	89 c2                	mov    %eax,%edx
  800f3d:	c1 ea 0c             	shr    $0xc,%edx
  800f40:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f47:	f6 c2 01             	test   $0x1,%dl
  800f4a:	74 1a                	je     800f66 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4f:	89 02                	mov    %eax,(%edx)
	return 0;
  800f51:	b8 00 00 00 00       	mov    $0x0,%eax
  800f56:	eb 13                	jmp    800f6b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f58:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f5d:	eb 0c                	jmp    800f6b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f5f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f64:	eb 05                	jmp    800f6b <fd_lookup+0x54>
  800f66:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	83 ec 08             	sub    $0x8,%esp
  800f73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f76:	ba e8 23 80 00       	mov    $0x8023e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f7b:	eb 13                	jmp    800f90 <dev_lookup+0x23>
  800f7d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f80:	39 08                	cmp    %ecx,(%eax)
  800f82:	75 0c                	jne    800f90 <dev_lookup+0x23>
			*dev = devtab[i];
  800f84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f87:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f89:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8e:	eb 2e                	jmp    800fbe <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f90:	8b 02                	mov    (%edx),%eax
  800f92:	85 c0                	test   %eax,%eax
  800f94:	75 e7                	jne    800f7d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f96:	a1 08 40 80 00       	mov    0x804008,%eax
  800f9b:	8b 40 48             	mov    0x48(%eax),%eax
  800f9e:	83 ec 04             	sub    $0x4,%esp
  800fa1:	51                   	push   %ecx
  800fa2:	50                   	push   %eax
  800fa3:	68 6c 23 80 00       	push   $0x80236c
  800fa8:	e8 c6 f1 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800fad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fbe:	c9                   	leave  
  800fbf:	c3                   	ret    

00800fc0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	56                   	push   %esi
  800fc4:	53                   	push   %ebx
  800fc5:	83 ec 10             	sub    $0x10,%esp
  800fc8:	8b 75 08             	mov    0x8(%ebp),%esi
  800fcb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd1:	50                   	push   %eax
  800fd2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fd8:	c1 e8 0c             	shr    $0xc,%eax
  800fdb:	50                   	push   %eax
  800fdc:	e8 36 ff ff ff       	call   800f17 <fd_lookup>
  800fe1:	83 c4 08             	add    $0x8,%esp
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	78 05                	js     800fed <fd_close+0x2d>
	    || fd != fd2) 
  800fe8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800feb:	74 0c                	je     800ff9 <fd_close+0x39>
		return (must_exist ? r : 0); 
  800fed:	84 db                	test   %bl,%bl
  800fef:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff4:	0f 44 c2             	cmove  %edx,%eax
  800ff7:	eb 41                	jmp    80103a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ff9:	83 ec 08             	sub    $0x8,%esp
  800ffc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fff:	50                   	push   %eax
  801000:	ff 36                	pushl  (%esi)
  801002:	e8 66 ff ff ff       	call   800f6d <dev_lookup>
  801007:	89 c3                	mov    %eax,%ebx
  801009:	83 c4 10             	add    $0x10,%esp
  80100c:	85 c0                	test   %eax,%eax
  80100e:	78 1a                	js     80102a <fd_close+0x6a>
		if (dev->dev_close) 
  801010:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801013:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  801016:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  80101b:	85 c0                	test   %eax,%eax
  80101d:	74 0b                	je     80102a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	56                   	push   %esi
  801023:	ff d0                	call   *%eax
  801025:	89 c3                	mov    %eax,%ebx
  801027:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80102a:	83 ec 08             	sub    $0x8,%esp
  80102d:	56                   	push   %esi
  80102e:	6a 00                	push   $0x0
  801030:	e8 71 fc ff ff       	call   800ca6 <sys_page_unmap>
	return r;
  801035:	83 c4 10             	add    $0x10,%esp
  801038:	89 d8                	mov    %ebx,%eax
}
  80103a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80103d:	5b                   	pop    %ebx
  80103e:	5e                   	pop    %esi
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    

00801041 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801047:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104a:	50                   	push   %eax
  80104b:	ff 75 08             	pushl  0x8(%ebp)
  80104e:	e8 c4 fe ff ff       	call   800f17 <fd_lookup>
  801053:	83 c4 08             	add    $0x8,%esp
  801056:	85 c0                	test   %eax,%eax
  801058:	78 10                	js     80106a <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  80105a:	83 ec 08             	sub    $0x8,%esp
  80105d:	6a 01                	push   $0x1
  80105f:	ff 75 f4             	pushl  -0xc(%ebp)
  801062:	e8 59 ff ff ff       	call   800fc0 <fd_close>
  801067:	83 c4 10             	add    $0x10,%esp
}
  80106a:	c9                   	leave  
  80106b:	c3                   	ret    

0080106c <close_all>:

void
close_all(void)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	53                   	push   %ebx
  801070:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801073:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	53                   	push   %ebx
  80107c:	e8 c0 ff ff ff       	call   801041 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801081:	83 c3 01             	add    $0x1,%ebx
  801084:	83 c4 10             	add    $0x10,%esp
  801087:	83 fb 20             	cmp    $0x20,%ebx
  80108a:	75 ec                	jne    801078 <close_all+0xc>
		close(i);
}
  80108c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108f:	c9                   	leave  
  801090:	c3                   	ret    

00801091 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	57                   	push   %edi
  801095:	56                   	push   %esi
  801096:	53                   	push   %ebx
  801097:	83 ec 2c             	sub    $0x2c,%esp
  80109a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80109d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010a0:	50                   	push   %eax
  8010a1:	ff 75 08             	pushl  0x8(%ebp)
  8010a4:	e8 6e fe ff ff       	call   800f17 <fd_lookup>
  8010a9:	83 c4 08             	add    $0x8,%esp
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	0f 88 c1 00 00 00    	js     801175 <dup+0xe4>
		return r;
	close(newfdnum);
  8010b4:	83 ec 0c             	sub    $0xc,%esp
  8010b7:	56                   	push   %esi
  8010b8:	e8 84 ff ff ff       	call   801041 <close>

	newfd = INDEX2FD(newfdnum);
  8010bd:	89 f3                	mov    %esi,%ebx
  8010bf:	c1 e3 0c             	shl    $0xc,%ebx
  8010c2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010c8:	83 c4 04             	add    $0x4,%esp
  8010cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ce:	e8 de fd ff ff       	call   800eb1 <fd2data>
  8010d3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010d5:	89 1c 24             	mov    %ebx,(%esp)
  8010d8:	e8 d4 fd ff ff       	call   800eb1 <fd2data>
  8010dd:	83 c4 10             	add    $0x10,%esp
  8010e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010e3:	89 f8                	mov    %edi,%eax
  8010e5:	c1 e8 16             	shr    $0x16,%eax
  8010e8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010ef:	a8 01                	test   $0x1,%al
  8010f1:	74 37                	je     80112a <dup+0x99>
  8010f3:	89 f8                	mov    %edi,%eax
  8010f5:	c1 e8 0c             	shr    $0xc,%eax
  8010f8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ff:	f6 c2 01             	test   $0x1,%dl
  801102:	74 26                	je     80112a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801104:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80110b:	83 ec 0c             	sub    $0xc,%esp
  80110e:	25 07 0e 00 00       	and    $0xe07,%eax
  801113:	50                   	push   %eax
  801114:	ff 75 d4             	pushl  -0x2c(%ebp)
  801117:	6a 00                	push   $0x0
  801119:	57                   	push   %edi
  80111a:	6a 00                	push   $0x0
  80111c:	e8 43 fb ff ff       	call   800c64 <sys_page_map>
  801121:	89 c7                	mov    %eax,%edi
  801123:	83 c4 20             	add    $0x20,%esp
  801126:	85 c0                	test   %eax,%eax
  801128:	78 2e                	js     801158 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80112a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80112d:	89 d0                	mov    %edx,%eax
  80112f:	c1 e8 0c             	shr    $0xc,%eax
  801132:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801139:	83 ec 0c             	sub    $0xc,%esp
  80113c:	25 07 0e 00 00       	and    $0xe07,%eax
  801141:	50                   	push   %eax
  801142:	53                   	push   %ebx
  801143:	6a 00                	push   $0x0
  801145:	52                   	push   %edx
  801146:	6a 00                	push   $0x0
  801148:	e8 17 fb ff ff       	call   800c64 <sys_page_map>
  80114d:	89 c7                	mov    %eax,%edi
  80114f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801152:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801154:	85 ff                	test   %edi,%edi
  801156:	79 1d                	jns    801175 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801158:	83 ec 08             	sub    $0x8,%esp
  80115b:	53                   	push   %ebx
  80115c:	6a 00                	push   $0x0
  80115e:	e8 43 fb ff ff       	call   800ca6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801163:	83 c4 08             	add    $0x8,%esp
  801166:	ff 75 d4             	pushl  -0x2c(%ebp)
  801169:	6a 00                	push   $0x0
  80116b:	e8 36 fb ff ff       	call   800ca6 <sys_page_unmap>
	return r;
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	89 f8                	mov    %edi,%eax
}
  801175:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801178:	5b                   	pop    %ebx
  801179:	5e                   	pop    %esi
  80117a:	5f                   	pop    %edi
  80117b:	5d                   	pop    %ebp
  80117c:	c3                   	ret    

0080117d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
  801180:	53                   	push   %ebx
  801181:	83 ec 14             	sub    $0x14,%esp
  801184:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801187:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118a:	50                   	push   %eax
  80118b:	53                   	push   %ebx
  80118c:	e8 86 fd ff ff       	call   800f17 <fd_lookup>
  801191:	83 c4 08             	add    $0x8,%esp
  801194:	89 c2                	mov    %eax,%edx
  801196:	85 c0                	test   %eax,%eax
  801198:	78 6d                	js     801207 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119a:	83 ec 08             	sub    $0x8,%esp
  80119d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a0:	50                   	push   %eax
  8011a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a4:	ff 30                	pushl  (%eax)
  8011a6:	e8 c2 fd ff ff       	call   800f6d <dev_lookup>
  8011ab:	83 c4 10             	add    $0x10,%esp
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	78 4c                	js     8011fe <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011b5:	8b 42 08             	mov    0x8(%edx),%eax
  8011b8:	83 e0 03             	and    $0x3,%eax
  8011bb:	83 f8 01             	cmp    $0x1,%eax
  8011be:	75 21                	jne    8011e1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011c0:	a1 08 40 80 00       	mov    0x804008,%eax
  8011c5:	8b 40 48             	mov    0x48(%eax),%eax
  8011c8:	83 ec 04             	sub    $0x4,%esp
  8011cb:	53                   	push   %ebx
  8011cc:	50                   	push   %eax
  8011cd:	68 ad 23 80 00       	push   $0x8023ad
  8011d2:	e8 9c ef ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  8011d7:	83 c4 10             	add    $0x10,%esp
  8011da:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011df:	eb 26                	jmp    801207 <read+0x8a>
	}
	if (!dev->dev_read)
  8011e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e4:	8b 40 08             	mov    0x8(%eax),%eax
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	74 17                	je     801202 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011eb:	83 ec 04             	sub    $0x4,%esp
  8011ee:	ff 75 10             	pushl  0x10(%ebp)
  8011f1:	ff 75 0c             	pushl  0xc(%ebp)
  8011f4:	52                   	push   %edx
  8011f5:	ff d0                	call   *%eax
  8011f7:	89 c2                	mov    %eax,%edx
  8011f9:	83 c4 10             	add    $0x10,%esp
  8011fc:	eb 09                	jmp    801207 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fe:	89 c2                	mov    %eax,%edx
  801200:	eb 05                	jmp    801207 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801202:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801207:	89 d0                	mov    %edx,%eax
  801209:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120c:	c9                   	leave  
  80120d:	c3                   	ret    

0080120e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	57                   	push   %edi
  801212:	56                   	push   %esi
  801213:	53                   	push   %ebx
  801214:	83 ec 0c             	sub    $0xc,%esp
  801217:	8b 7d 08             	mov    0x8(%ebp),%edi
  80121a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80121d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801222:	eb 21                	jmp    801245 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801224:	83 ec 04             	sub    $0x4,%esp
  801227:	89 f0                	mov    %esi,%eax
  801229:	29 d8                	sub    %ebx,%eax
  80122b:	50                   	push   %eax
  80122c:	89 d8                	mov    %ebx,%eax
  80122e:	03 45 0c             	add    0xc(%ebp),%eax
  801231:	50                   	push   %eax
  801232:	57                   	push   %edi
  801233:	e8 45 ff ff ff       	call   80117d <read>
		if (m < 0)
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	78 10                	js     80124f <readn+0x41>
			return m;
		if (m == 0)
  80123f:	85 c0                	test   %eax,%eax
  801241:	74 0a                	je     80124d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801243:	01 c3                	add    %eax,%ebx
  801245:	39 f3                	cmp    %esi,%ebx
  801247:	72 db                	jb     801224 <readn+0x16>
  801249:	89 d8                	mov    %ebx,%eax
  80124b:	eb 02                	jmp    80124f <readn+0x41>
  80124d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80124f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801252:	5b                   	pop    %ebx
  801253:	5e                   	pop    %esi
  801254:	5f                   	pop    %edi
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    

00801257 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	53                   	push   %ebx
  80125b:	83 ec 14             	sub    $0x14,%esp
  80125e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801261:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801264:	50                   	push   %eax
  801265:	53                   	push   %ebx
  801266:	e8 ac fc ff ff       	call   800f17 <fd_lookup>
  80126b:	83 c4 08             	add    $0x8,%esp
  80126e:	89 c2                	mov    %eax,%edx
  801270:	85 c0                	test   %eax,%eax
  801272:	78 68                	js     8012dc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801274:	83 ec 08             	sub    $0x8,%esp
  801277:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127a:	50                   	push   %eax
  80127b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127e:	ff 30                	pushl  (%eax)
  801280:	e8 e8 fc ff ff       	call   800f6d <dev_lookup>
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	85 c0                	test   %eax,%eax
  80128a:	78 47                	js     8012d3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801293:	75 21                	jne    8012b6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801295:	a1 08 40 80 00       	mov    0x804008,%eax
  80129a:	8b 40 48             	mov    0x48(%eax),%eax
  80129d:	83 ec 04             	sub    $0x4,%esp
  8012a0:	53                   	push   %ebx
  8012a1:	50                   	push   %eax
  8012a2:	68 c9 23 80 00       	push   $0x8023c9
  8012a7:	e8 c7 ee ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  8012ac:	83 c4 10             	add    $0x10,%esp
  8012af:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012b4:	eb 26                	jmp    8012dc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b9:	8b 52 0c             	mov    0xc(%edx),%edx
  8012bc:	85 d2                	test   %edx,%edx
  8012be:	74 17                	je     8012d7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012c0:	83 ec 04             	sub    $0x4,%esp
  8012c3:	ff 75 10             	pushl  0x10(%ebp)
  8012c6:	ff 75 0c             	pushl  0xc(%ebp)
  8012c9:	50                   	push   %eax
  8012ca:	ff d2                	call   *%edx
  8012cc:	89 c2                	mov    %eax,%edx
  8012ce:	83 c4 10             	add    $0x10,%esp
  8012d1:	eb 09                	jmp    8012dc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d3:	89 c2                	mov    %eax,%edx
  8012d5:	eb 05                	jmp    8012dc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012dc:	89 d0                	mov    %edx,%eax
  8012de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e1:	c9                   	leave  
  8012e2:	c3                   	ret    

008012e3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012ec:	50                   	push   %eax
  8012ed:	ff 75 08             	pushl  0x8(%ebp)
  8012f0:	e8 22 fc ff ff       	call   800f17 <fd_lookup>
  8012f5:	83 c4 08             	add    $0x8,%esp
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	78 0e                	js     80130a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801302:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801305:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80130a:	c9                   	leave  
  80130b:	c3                   	ret    

0080130c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	53                   	push   %ebx
  801310:	83 ec 14             	sub    $0x14,%esp
  801313:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801316:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801319:	50                   	push   %eax
  80131a:	53                   	push   %ebx
  80131b:	e8 f7 fb ff ff       	call   800f17 <fd_lookup>
  801320:	83 c4 08             	add    $0x8,%esp
  801323:	89 c2                	mov    %eax,%edx
  801325:	85 c0                	test   %eax,%eax
  801327:	78 65                	js     80138e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801329:	83 ec 08             	sub    $0x8,%esp
  80132c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132f:	50                   	push   %eax
  801330:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801333:	ff 30                	pushl  (%eax)
  801335:	e8 33 fc ff ff       	call   800f6d <dev_lookup>
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 44                	js     801385 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801341:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801344:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801348:	75 21                	jne    80136b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80134a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80134f:	8b 40 48             	mov    0x48(%eax),%eax
  801352:	83 ec 04             	sub    $0x4,%esp
  801355:	53                   	push   %ebx
  801356:	50                   	push   %eax
  801357:	68 8c 23 80 00       	push   $0x80238c
  80135c:	e8 12 ee ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801369:	eb 23                	jmp    80138e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80136b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80136e:	8b 52 18             	mov    0x18(%edx),%edx
  801371:	85 d2                	test   %edx,%edx
  801373:	74 14                	je     801389 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801375:	83 ec 08             	sub    $0x8,%esp
  801378:	ff 75 0c             	pushl  0xc(%ebp)
  80137b:	50                   	push   %eax
  80137c:	ff d2                	call   *%edx
  80137e:	89 c2                	mov    %eax,%edx
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	eb 09                	jmp    80138e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801385:	89 c2                	mov    %eax,%edx
  801387:	eb 05                	jmp    80138e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801389:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80138e:	89 d0                	mov    %edx,%eax
  801390:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801393:	c9                   	leave  
  801394:	c3                   	ret    

00801395 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	53                   	push   %ebx
  801399:	83 ec 14             	sub    $0x14,%esp
  80139c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80139f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a2:	50                   	push   %eax
  8013a3:	ff 75 08             	pushl  0x8(%ebp)
  8013a6:	e8 6c fb ff ff       	call   800f17 <fd_lookup>
  8013ab:	83 c4 08             	add    $0x8,%esp
  8013ae:	89 c2                	mov    %eax,%edx
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	78 58                	js     80140c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b4:	83 ec 08             	sub    $0x8,%esp
  8013b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ba:	50                   	push   %eax
  8013bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013be:	ff 30                	pushl  (%eax)
  8013c0:	e8 a8 fb ff ff       	call   800f6d <dev_lookup>
  8013c5:	83 c4 10             	add    $0x10,%esp
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	78 37                	js     801403 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013d3:	74 32                	je     801407 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013d5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013d8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013df:	00 00 00 
	stat->st_isdir = 0;
  8013e2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013e9:	00 00 00 
	stat->st_dev = dev;
  8013ec:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013f2:	83 ec 08             	sub    $0x8,%esp
  8013f5:	53                   	push   %ebx
  8013f6:	ff 75 f0             	pushl  -0x10(%ebp)
  8013f9:	ff 50 14             	call   *0x14(%eax)
  8013fc:	89 c2                	mov    %eax,%edx
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	eb 09                	jmp    80140c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801403:	89 c2                	mov    %eax,%edx
  801405:	eb 05                	jmp    80140c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801407:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80140c:	89 d0                	mov    %edx,%eax
  80140e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	56                   	push   %esi
  801417:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801418:	83 ec 08             	sub    $0x8,%esp
  80141b:	6a 00                	push   $0x0
  80141d:	ff 75 08             	pushl  0x8(%ebp)
  801420:	e8 2b 02 00 00       	call   801650 <open>
  801425:	89 c3                	mov    %eax,%ebx
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 1b                	js     801449 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	ff 75 0c             	pushl  0xc(%ebp)
  801434:	50                   	push   %eax
  801435:	e8 5b ff ff ff       	call   801395 <fstat>
  80143a:	89 c6                	mov    %eax,%esi
	close(fd);
  80143c:	89 1c 24             	mov    %ebx,(%esp)
  80143f:	e8 fd fb ff ff       	call   801041 <close>
	return r;
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	89 f0                	mov    %esi,%eax
}
  801449:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144c:	5b                   	pop    %ebx
  80144d:	5e                   	pop    %esi
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    

00801450 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	56                   	push   %esi
  801454:	53                   	push   %ebx
  801455:	89 c6                	mov    %eax,%esi
  801457:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801459:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801460:	75 12                	jne    801474 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801462:	83 ec 0c             	sub    $0xc,%esp
  801465:	6a 01                	push   $0x1
  801467:	e8 6c 08 00 00       	call   801cd8 <ipc_find_env>
  80146c:	a3 04 40 80 00       	mov    %eax,0x804004
  801471:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801474:	6a 07                	push   $0x7
  801476:	68 00 50 80 00       	push   $0x805000
  80147b:	56                   	push   %esi
  80147c:	ff 35 04 40 80 00    	pushl  0x804004
  801482:	e8 fb 07 00 00       	call   801c82 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801487:	83 c4 0c             	add    $0xc,%esp
  80148a:	6a 00                	push   $0x0
  80148c:	53                   	push   %ebx
  80148d:	6a 00                	push   $0x0
  80148f:	e8 85 07 00 00       	call   801c19 <ipc_recv>
}
  801494:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801497:	5b                   	pop    %ebx
  801498:	5e                   	pop    %esi
  801499:	5d                   	pop    %ebp
  80149a:	c3                   	ret    

0080149b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014af:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b9:	b8 02 00 00 00       	mov    $0x2,%eax
  8014be:	e8 8d ff ff ff       	call   801450 <fsipc>
}
  8014c3:	c9                   	leave  
  8014c4:	c3                   	ret    

008014c5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014db:	b8 06 00 00 00       	mov    $0x6,%eax
  8014e0:	e8 6b ff ff ff       	call   801450 <fsipc>
}
  8014e5:	c9                   	leave  
  8014e6:	c3                   	ret    

008014e7 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	53                   	push   %ebx
  8014eb:	83 ec 04             	sub    $0x4,%esp
  8014ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801501:	b8 05 00 00 00       	mov    $0x5,%eax
  801506:	e8 45 ff ff ff       	call   801450 <fsipc>
  80150b:	85 c0                	test   %eax,%eax
  80150d:	78 2c                	js     80153b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80150f:	83 ec 08             	sub    $0x8,%esp
  801512:	68 00 50 80 00       	push   $0x805000
  801517:	53                   	push   %ebx
  801518:	e8 8a f2 ff ff       	call   8007a7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80151d:	a1 80 50 80 00       	mov    0x805080,%eax
  801522:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801528:	a1 84 50 80 00       	mov    0x805084,%eax
  80152d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153e:	c9                   	leave  
  80153f:	c3                   	ret    

00801540 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	53                   	push   %ebx
  801544:	83 ec 08             	sub    $0x8,%esp
  801547:	8b 45 10             	mov    0x10(%ebp),%eax
  80154a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80154f:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801554:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801557:	8b 45 08             	mov    0x8(%ebp),%eax
  80155a:	8b 40 0c             	mov    0xc(%eax),%eax
  80155d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801562:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801568:	53                   	push   %ebx
  801569:	ff 75 0c             	pushl  0xc(%ebp)
  80156c:	68 08 50 80 00       	push   $0x805008
  801571:	e8 c3 f3 ff ff       	call   800939 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801576:	ba 00 00 00 00       	mov    $0x0,%edx
  80157b:	b8 04 00 00 00       	mov    $0x4,%eax
  801580:	e8 cb fe ff ff       	call   801450 <fsipc>
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	85 c0                	test   %eax,%eax
  80158a:	78 3d                	js     8015c9 <devfile_write+0x89>
		return r;

	assert(r <= n);
  80158c:	39 d8                	cmp    %ebx,%eax
  80158e:	76 19                	jbe    8015a9 <devfile_write+0x69>
  801590:	68 f8 23 80 00       	push   $0x8023f8
  801595:	68 ff 23 80 00       	push   $0x8023ff
  80159a:	68 9f 00 00 00       	push   $0x9f
  80159f:	68 14 24 80 00       	push   $0x802414
  8015a4:	e8 2a 06 00 00       	call   801bd3 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  8015a9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015ae:	76 19                	jbe    8015c9 <devfile_write+0x89>
  8015b0:	68 2c 24 80 00       	push   $0x80242c
  8015b5:	68 ff 23 80 00       	push   $0x8023ff
  8015ba:	68 a0 00 00 00       	push   $0xa0
  8015bf:	68 14 24 80 00       	push   $0x802414
  8015c4:	e8 0a 06 00 00       	call   801bd3 <_panic>

	return r;
}
  8015c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cc:	c9                   	leave  
  8015cd:	c3                   	ret    

008015ce <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	56                   	push   %esi
  8015d2:	53                   	push   %ebx
  8015d3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8015dc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015e1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ec:	b8 03 00 00 00       	mov    $0x3,%eax
  8015f1:	e8 5a fe ff ff       	call   801450 <fsipc>
  8015f6:	89 c3                	mov    %eax,%ebx
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	78 4b                	js     801647 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015fc:	39 c6                	cmp    %eax,%esi
  8015fe:	73 16                	jae    801616 <devfile_read+0x48>
  801600:	68 f8 23 80 00       	push   $0x8023f8
  801605:	68 ff 23 80 00       	push   $0x8023ff
  80160a:	6a 7e                	push   $0x7e
  80160c:	68 14 24 80 00       	push   $0x802414
  801611:	e8 bd 05 00 00       	call   801bd3 <_panic>
	assert(r <= PGSIZE);
  801616:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80161b:	7e 16                	jle    801633 <devfile_read+0x65>
  80161d:	68 1f 24 80 00       	push   $0x80241f
  801622:	68 ff 23 80 00       	push   $0x8023ff
  801627:	6a 7f                	push   $0x7f
  801629:	68 14 24 80 00       	push   $0x802414
  80162e:	e8 a0 05 00 00       	call   801bd3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801633:	83 ec 04             	sub    $0x4,%esp
  801636:	50                   	push   %eax
  801637:	68 00 50 80 00       	push   $0x805000
  80163c:	ff 75 0c             	pushl  0xc(%ebp)
  80163f:	e8 f5 f2 ff ff       	call   800939 <memmove>
	return r;
  801644:	83 c4 10             	add    $0x10,%esp
}
  801647:	89 d8                	mov    %ebx,%eax
  801649:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164c:	5b                   	pop    %ebx
  80164d:	5e                   	pop    %esi
  80164e:	5d                   	pop    %ebp
  80164f:	c3                   	ret    

00801650 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	53                   	push   %ebx
  801654:	83 ec 20             	sub    $0x20,%esp
  801657:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80165a:	53                   	push   %ebx
  80165b:	e8 0e f1 ff ff       	call   80076e <strlen>
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801668:	7f 67                	jg     8016d1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80166a:	83 ec 0c             	sub    $0xc,%esp
  80166d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801670:	50                   	push   %eax
  801671:	e8 52 f8 ff ff       	call   800ec8 <fd_alloc>
  801676:	83 c4 10             	add    $0x10,%esp
		return r;
  801679:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80167b:	85 c0                	test   %eax,%eax
  80167d:	78 57                	js     8016d6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80167f:	83 ec 08             	sub    $0x8,%esp
  801682:	53                   	push   %ebx
  801683:	68 00 50 80 00       	push   $0x805000
  801688:	e8 1a f1 ff ff       	call   8007a7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80168d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801690:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801695:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801698:	b8 01 00 00 00       	mov    $0x1,%eax
  80169d:	e8 ae fd ff ff       	call   801450 <fsipc>
  8016a2:	89 c3                	mov    %eax,%ebx
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	79 14                	jns    8016bf <open+0x6f>
		fd_close(fd, 0);
  8016ab:	83 ec 08             	sub    $0x8,%esp
  8016ae:	6a 00                	push   $0x0
  8016b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b3:	e8 08 f9 ff ff       	call   800fc0 <fd_close>
		return r;
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	89 da                	mov    %ebx,%edx
  8016bd:	eb 17                	jmp    8016d6 <open+0x86>
	}

	return fd2num(fd);
  8016bf:	83 ec 0c             	sub    $0xc,%esp
  8016c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8016c5:	e8 d7 f7 ff ff       	call   800ea1 <fd2num>
  8016ca:	89 c2                	mov    %eax,%edx
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	eb 05                	jmp    8016d6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016d1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016d6:	89 d0                	mov    %edx,%eax
  8016d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016db:	c9                   	leave  
  8016dc:	c3                   	ret    

008016dd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e8:	b8 08 00 00 00       	mov    $0x8,%eax
  8016ed:	e8 5e fd ff ff       	call   801450 <fsipc>
}
  8016f2:	c9                   	leave  
  8016f3:	c3                   	ret    

008016f4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	56                   	push   %esi
  8016f8:	53                   	push   %ebx
  8016f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016fc:	83 ec 0c             	sub    $0xc,%esp
  8016ff:	ff 75 08             	pushl  0x8(%ebp)
  801702:	e8 aa f7 ff ff       	call   800eb1 <fd2data>
  801707:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801709:	83 c4 08             	add    $0x8,%esp
  80170c:	68 59 24 80 00       	push   $0x802459
  801711:	53                   	push   %ebx
  801712:	e8 90 f0 ff ff       	call   8007a7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801717:	8b 46 04             	mov    0x4(%esi),%eax
  80171a:	2b 06                	sub    (%esi),%eax
  80171c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801722:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801729:	00 00 00 
	stat->st_dev = &devpipe;
  80172c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801733:	30 80 00 
	return 0;
}
  801736:	b8 00 00 00 00       	mov    $0x0,%eax
  80173b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80173e:	5b                   	pop    %ebx
  80173f:	5e                   	pop    %esi
  801740:	5d                   	pop    %ebp
  801741:	c3                   	ret    

00801742 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	53                   	push   %ebx
  801746:	83 ec 0c             	sub    $0xc,%esp
  801749:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80174c:	53                   	push   %ebx
  80174d:	6a 00                	push   $0x0
  80174f:	e8 52 f5 ff ff       	call   800ca6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801754:	89 1c 24             	mov    %ebx,(%esp)
  801757:	e8 55 f7 ff ff       	call   800eb1 <fd2data>
  80175c:	83 c4 08             	add    $0x8,%esp
  80175f:	50                   	push   %eax
  801760:	6a 00                	push   $0x0
  801762:	e8 3f f5 ff ff       	call   800ca6 <sys_page_unmap>
}
  801767:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176a:	c9                   	leave  
  80176b:	c3                   	ret    

0080176c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	57                   	push   %edi
  801770:	56                   	push   %esi
  801771:	53                   	push   %ebx
  801772:	83 ec 1c             	sub    $0x1c,%esp
  801775:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801778:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80177a:	a1 08 40 80 00       	mov    0x804008,%eax
  80177f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801782:	83 ec 0c             	sub    $0xc,%esp
  801785:	ff 75 e0             	pushl  -0x20(%ebp)
  801788:	e8 84 05 00 00       	call   801d11 <pageref>
  80178d:	89 c3                	mov    %eax,%ebx
  80178f:	89 3c 24             	mov    %edi,(%esp)
  801792:	e8 7a 05 00 00       	call   801d11 <pageref>
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	39 c3                	cmp    %eax,%ebx
  80179c:	0f 94 c1             	sete   %cl
  80179f:	0f b6 c9             	movzbl %cl,%ecx
  8017a2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8017a5:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8017ab:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017ae:	39 ce                	cmp    %ecx,%esi
  8017b0:	74 1b                	je     8017cd <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8017b2:	39 c3                	cmp    %eax,%ebx
  8017b4:	75 c4                	jne    80177a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017b6:	8b 42 58             	mov    0x58(%edx),%eax
  8017b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017bc:	50                   	push   %eax
  8017bd:	56                   	push   %esi
  8017be:	68 60 24 80 00       	push   $0x802460
  8017c3:	e8 ab e9 ff ff       	call   800173 <cprintf>
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	eb ad                	jmp    80177a <_pipeisclosed+0xe>
	}
}
  8017cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d3:	5b                   	pop    %ebx
  8017d4:	5e                   	pop    %esi
  8017d5:	5f                   	pop    %edi
  8017d6:	5d                   	pop    %ebp
  8017d7:	c3                   	ret    

008017d8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	57                   	push   %edi
  8017dc:	56                   	push   %esi
  8017dd:	53                   	push   %ebx
  8017de:	83 ec 28             	sub    $0x28,%esp
  8017e1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8017e4:	56                   	push   %esi
  8017e5:	e8 c7 f6 ff ff       	call   800eb1 <fd2data>
  8017ea:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ec:	83 c4 10             	add    $0x10,%esp
  8017ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8017f4:	eb 4b                	jmp    801841 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017f6:	89 da                	mov    %ebx,%edx
  8017f8:	89 f0                	mov    %esi,%eax
  8017fa:	e8 6d ff ff ff       	call   80176c <_pipeisclosed>
  8017ff:	85 c0                	test   %eax,%eax
  801801:	75 48                	jne    80184b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801803:	e8 fa f3 ff ff       	call   800c02 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801808:	8b 43 04             	mov    0x4(%ebx),%eax
  80180b:	8b 0b                	mov    (%ebx),%ecx
  80180d:	8d 51 20             	lea    0x20(%ecx),%edx
  801810:	39 d0                	cmp    %edx,%eax
  801812:	73 e2                	jae    8017f6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801814:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801817:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80181b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80181e:	89 c2                	mov    %eax,%edx
  801820:	c1 fa 1f             	sar    $0x1f,%edx
  801823:	89 d1                	mov    %edx,%ecx
  801825:	c1 e9 1b             	shr    $0x1b,%ecx
  801828:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80182b:	83 e2 1f             	and    $0x1f,%edx
  80182e:	29 ca                	sub    %ecx,%edx
  801830:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801834:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801838:	83 c0 01             	add    $0x1,%eax
  80183b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80183e:	83 c7 01             	add    $0x1,%edi
  801841:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801844:	75 c2                	jne    801808 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801846:	8b 45 10             	mov    0x10(%ebp),%eax
  801849:	eb 05                	jmp    801850 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80184b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801850:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801853:	5b                   	pop    %ebx
  801854:	5e                   	pop    %esi
  801855:	5f                   	pop    %edi
  801856:	5d                   	pop    %ebp
  801857:	c3                   	ret    

00801858 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	57                   	push   %edi
  80185c:	56                   	push   %esi
  80185d:	53                   	push   %ebx
  80185e:	83 ec 18             	sub    $0x18,%esp
  801861:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801864:	57                   	push   %edi
  801865:	e8 47 f6 ff ff       	call   800eb1 <fd2data>
  80186a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80186c:	83 c4 10             	add    $0x10,%esp
  80186f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801874:	eb 3d                	jmp    8018b3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801876:	85 db                	test   %ebx,%ebx
  801878:	74 04                	je     80187e <devpipe_read+0x26>
				return i;
  80187a:	89 d8                	mov    %ebx,%eax
  80187c:	eb 44                	jmp    8018c2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80187e:	89 f2                	mov    %esi,%edx
  801880:	89 f8                	mov    %edi,%eax
  801882:	e8 e5 fe ff ff       	call   80176c <_pipeisclosed>
  801887:	85 c0                	test   %eax,%eax
  801889:	75 32                	jne    8018bd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80188b:	e8 72 f3 ff ff       	call   800c02 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801890:	8b 06                	mov    (%esi),%eax
  801892:	3b 46 04             	cmp    0x4(%esi),%eax
  801895:	74 df                	je     801876 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801897:	99                   	cltd   
  801898:	c1 ea 1b             	shr    $0x1b,%edx
  80189b:	01 d0                	add    %edx,%eax
  80189d:	83 e0 1f             	and    $0x1f,%eax
  8018a0:	29 d0                	sub    %edx,%eax
  8018a2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8018a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018aa:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8018ad:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018b0:	83 c3 01             	add    $0x1,%ebx
  8018b3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8018b6:	75 d8                	jne    801890 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8018b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8018bb:	eb 05                	jmp    8018c2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018bd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c5:	5b                   	pop    %ebx
  8018c6:	5e                   	pop    %esi
  8018c7:	5f                   	pop    %edi
  8018c8:	5d                   	pop    %ebp
  8018c9:	c3                   	ret    

008018ca <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	56                   	push   %esi
  8018ce:	53                   	push   %ebx
  8018cf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d5:	50                   	push   %eax
  8018d6:	e8 ed f5 ff ff       	call   800ec8 <fd_alloc>
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	89 c2                	mov    %eax,%edx
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	0f 88 2c 01 00 00    	js     801a14 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018e8:	83 ec 04             	sub    $0x4,%esp
  8018eb:	68 07 04 00 00       	push   $0x407
  8018f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f3:	6a 00                	push   $0x0
  8018f5:	e8 27 f3 ff ff       	call   800c21 <sys_page_alloc>
  8018fa:	83 c4 10             	add    $0x10,%esp
  8018fd:	89 c2                	mov    %eax,%edx
  8018ff:	85 c0                	test   %eax,%eax
  801901:	0f 88 0d 01 00 00    	js     801a14 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801907:	83 ec 0c             	sub    $0xc,%esp
  80190a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80190d:	50                   	push   %eax
  80190e:	e8 b5 f5 ff ff       	call   800ec8 <fd_alloc>
  801913:	89 c3                	mov    %eax,%ebx
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	85 c0                	test   %eax,%eax
  80191a:	0f 88 e2 00 00 00    	js     801a02 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801920:	83 ec 04             	sub    $0x4,%esp
  801923:	68 07 04 00 00       	push   $0x407
  801928:	ff 75 f0             	pushl  -0x10(%ebp)
  80192b:	6a 00                	push   $0x0
  80192d:	e8 ef f2 ff ff       	call   800c21 <sys_page_alloc>
  801932:	89 c3                	mov    %eax,%ebx
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	85 c0                	test   %eax,%eax
  801939:	0f 88 c3 00 00 00    	js     801a02 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80193f:	83 ec 0c             	sub    $0xc,%esp
  801942:	ff 75 f4             	pushl  -0xc(%ebp)
  801945:	e8 67 f5 ff ff       	call   800eb1 <fd2data>
  80194a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80194c:	83 c4 0c             	add    $0xc,%esp
  80194f:	68 07 04 00 00       	push   $0x407
  801954:	50                   	push   %eax
  801955:	6a 00                	push   $0x0
  801957:	e8 c5 f2 ff ff       	call   800c21 <sys_page_alloc>
  80195c:	89 c3                	mov    %eax,%ebx
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	85 c0                	test   %eax,%eax
  801963:	0f 88 89 00 00 00    	js     8019f2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801969:	83 ec 0c             	sub    $0xc,%esp
  80196c:	ff 75 f0             	pushl  -0x10(%ebp)
  80196f:	e8 3d f5 ff ff       	call   800eb1 <fd2data>
  801974:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80197b:	50                   	push   %eax
  80197c:	6a 00                	push   $0x0
  80197e:	56                   	push   %esi
  80197f:	6a 00                	push   $0x0
  801981:	e8 de f2 ff ff       	call   800c64 <sys_page_map>
  801986:	89 c3                	mov    %eax,%ebx
  801988:	83 c4 20             	add    $0x20,%esp
  80198b:	85 c0                	test   %eax,%eax
  80198d:	78 55                	js     8019e4 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80198f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801995:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801998:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80199a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019a4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ad:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8019b9:	83 ec 0c             	sub    $0xc,%esp
  8019bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8019bf:	e8 dd f4 ff ff       	call   800ea1 <fd2num>
  8019c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019c7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8019c9:	83 c4 04             	add    $0x4,%esp
  8019cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8019cf:	e8 cd f4 ff ff       	call   800ea1 <fd2num>
  8019d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019d7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8019da:	83 c4 10             	add    $0x10,%esp
  8019dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e2:	eb 30                	jmp    801a14 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8019e4:	83 ec 08             	sub    $0x8,%esp
  8019e7:	56                   	push   %esi
  8019e8:	6a 00                	push   $0x0
  8019ea:	e8 b7 f2 ff ff       	call   800ca6 <sys_page_unmap>
  8019ef:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8019f2:	83 ec 08             	sub    $0x8,%esp
  8019f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8019f8:	6a 00                	push   $0x0
  8019fa:	e8 a7 f2 ff ff       	call   800ca6 <sys_page_unmap>
  8019ff:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a02:	83 ec 08             	sub    $0x8,%esp
  801a05:	ff 75 f4             	pushl  -0xc(%ebp)
  801a08:	6a 00                	push   $0x0
  801a0a:	e8 97 f2 ff ff       	call   800ca6 <sys_page_unmap>
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a14:	89 d0                	mov    %edx,%eax
  801a16:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a19:	5b                   	pop    %ebx
  801a1a:	5e                   	pop    %esi
  801a1b:	5d                   	pop    %ebp
  801a1c:	c3                   	ret    

00801a1d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a26:	50                   	push   %eax
  801a27:	ff 75 08             	pushl  0x8(%ebp)
  801a2a:	e8 e8 f4 ff ff       	call   800f17 <fd_lookup>
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	85 c0                	test   %eax,%eax
  801a34:	78 18                	js     801a4e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a36:	83 ec 0c             	sub    $0xc,%esp
  801a39:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3c:	e8 70 f4 ff ff       	call   800eb1 <fd2data>
	return _pipeisclosed(fd, p);
  801a41:	89 c2                	mov    %eax,%edx
  801a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a46:	e8 21 fd ff ff       	call   80176c <_pipeisclosed>
  801a4b:	83 c4 10             	add    $0x10,%esp
}
  801a4e:	c9                   	leave  
  801a4f:	c3                   	ret    

00801a50 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a53:	b8 00 00 00 00       	mov    $0x0,%eax
  801a58:	5d                   	pop    %ebp
  801a59:	c3                   	ret    

00801a5a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a60:	68 78 24 80 00       	push   $0x802478
  801a65:	ff 75 0c             	pushl  0xc(%ebp)
  801a68:	e8 3a ed ff ff       	call   8007a7 <strcpy>
	return 0;
}
  801a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a72:	c9                   	leave  
  801a73:	c3                   	ret    

00801a74 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	57                   	push   %edi
  801a78:	56                   	push   %esi
  801a79:	53                   	push   %ebx
  801a7a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a80:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a85:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a8b:	eb 2d                	jmp    801aba <devcons_write+0x46>
		m = n - tot;
  801a8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a90:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a92:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a95:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a9a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a9d:	83 ec 04             	sub    $0x4,%esp
  801aa0:	53                   	push   %ebx
  801aa1:	03 45 0c             	add    0xc(%ebp),%eax
  801aa4:	50                   	push   %eax
  801aa5:	57                   	push   %edi
  801aa6:	e8 8e ee ff ff       	call   800939 <memmove>
		sys_cputs(buf, m);
  801aab:	83 c4 08             	add    $0x8,%esp
  801aae:	53                   	push   %ebx
  801aaf:	57                   	push   %edi
  801ab0:	e8 b0 f0 ff ff       	call   800b65 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ab5:	01 de                	add    %ebx,%esi
  801ab7:	83 c4 10             	add    $0x10,%esp
  801aba:	89 f0                	mov    %esi,%eax
  801abc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801abf:	72 cc                	jb     801a8d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ac1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac4:	5b                   	pop    %ebx
  801ac5:	5e                   	pop    %esi
  801ac6:	5f                   	pop    %edi
  801ac7:	5d                   	pop    %ebp
  801ac8:	c3                   	ret    

00801ac9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	83 ec 08             	sub    $0x8,%esp
  801acf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ad4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ad8:	74 2a                	je     801b04 <devcons_read+0x3b>
  801ada:	eb 05                	jmp    801ae1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801adc:	e8 21 f1 ff ff       	call   800c02 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ae1:	e8 9d f0 ff ff       	call   800b83 <sys_cgetc>
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	74 f2                	je     801adc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801aea:	85 c0                	test   %eax,%eax
  801aec:	78 16                	js     801b04 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801aee:	83 f8 04             	cmp    $0x4,%eax
  801af1:	74 0c                	je     801aff <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801af3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801af6:	88 02                	mov    %al,(%edx)
	return 1;
  801af8:	b8 01 00 00 00       	mov    $0x1,%eax
  801afd:	eb 05                	jmp    801b04 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801aff:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b04:	c9                   	leave  
  801b05:	c3                   	ret    

00801b06 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b12:	6a 01                	push   $0x1
  801b14:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b17:	50                   	push   %eax
  801b18:	e8 48 f0 ff ff       	call   800b65 <sys_cputs>
}
  801b1d:	83 c4 10             	add    $0x10,%esp
  801b20:	c9                   	leave  
  801b21:	c3                   	ret    

00801b22 <getchar>:

int
getchar(void)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b28:	6a 01                	push   $0x1
  801b2a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b2d:	50                   	push   %eax
  801b2e:	6a 00                	push   $0x0
  801b30:	e8 48 f6 ff ff       	call   80117d <read>
	if (r < 0)
  801b35:	83 c4 10             	add    $0x10,%esp
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	78 0f                	js     801b4b <getchar+0x29>
		return r;
	if (r < 1)
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	7e 06                	jle    801b46 <getchar+0x24>
		return -E_EOF;
	return c;
  801b40:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b44:	eb 05                	jmp    801b4b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b46:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b4b:	c9                   	leave  
  801b4c:	c3                   	ret    

00801b4d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b56:	50                   	push   %eax
  801b57:	ff 75 08             	pushl  0x8(%ebp)
  801b5a:	e8 b8 f3 ff ff       	call   800f17 <fd_lookup>
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	85 c0                	test   %eax,%eax
  801b64:	78 11                	js     801b77 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b69:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b6f:	39 10                	cmp    %edx,(%eax)
  801b71:	0f 94 c0             	sete   %al
  801b74:	0f b6 c0             	movzbl %al,%eax
}
  801b77:	c9                   	leave  
  801b78:	c3                   	ret    

00801b79 <opencons>:

int
opencons(void)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b82:	50                   	push   %eax
  801b83:	e8 40 f3 ff ff       	call   800ec8 <fd_alloc>
  801b88:	83 c4 10             	add    $0x10,%esp
		return r;
  801b8b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b8d:	85 c0                	test   %eax,%eax
  801b8f:	78 3e                	js     801bcf <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b91:	83 ec 04             	sub    $0x4,%esp
  801b94:	68 07 04 00 00       	push   $0x407
  801b99:	ff 75 f4             	pushl  -0xc(%ebp)
  801b9c:	6a 00                	push   $0x0
  801b9e:	e8 7e f0 ff ff       	call   800c21 <sys_page_alloc>
  801ba3:	83 c4 10             	add    $0x10,%esp
		return r;
  801ba6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	78 23                	js     801bcf <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801bac:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bba:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bc1:	83 ec 0c             	sub    $0xc,%esp
  801bc4:	50                   	push   %eax
  801bc5:	e8 d7 f2 ff ff       	call   800ea1 <fd2num>
  801bca:	89 c2                	mov    %eax,%edx
  801bcc:	83 c4 10             	add    $0x10,%esp
}
  801bcf:	89 d0                	mov    %edx,%eax
  801bd1:	c9                   	leave  
  801bd2:	c3                   	ret    

00801bd3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	56                   	push   %esi
  801bd7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801bd8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801bdb:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801be1:	e8 fd ef ff ff       	call   800be3 <sys_getenvid>
  801be6:	83 ec 0c             	sub    $0xc,%esp
  801be9:	ff 75 0c             	pushl  0xc(%ebp)
  801bec:	ff 75 08             	pushl  0x8(%ebp)
  801bef:	56                   	push   %esi
  801bf0:	50                   	push   %eax
  801bf1:	68 84 24 80 00       	push   $0x802484
  801bf6:	e8 78 e5 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801bfb:	83 c4 18             	add    $0x18,%esp
  801bfe:	53                   	push   %ebx
  801bff:	ff 75 10             	pushl  0x10(%ebp)
  801c02:	e8 1b e5 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801c07:	c7 04 24 71 24 80 00 	movl   $0x802471,(%esp)
  801c0e:	e8 60 e5 ff ff       	call   800173 <cprintf>
  801c13:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801c16:	cc                   	int3   
  801c17:	eb fd                	jmp    801c16 <_panic+0x43>

00801c19 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	56                   	push   %esi
  801c1d:	53                   	push   %ebx
  801c1e:	8b 75 08             	mov    0x8(%ebp),%esi
  801c21:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c24:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801c27:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801c29:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801c2e:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801c31:	83 ec 0c             	sub    $0xc,%esp
  801c34:	50                   	push   %eax
  801c35:	e8 97 f1 ff ff       	call   800dd1 <sys_ipc_recv>
  801c3a:	83 c4 10             	add    $0x10,%esp
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	79 16                	jns    801c57 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801c41:	85 f6                	test   %esi,%esi
  801c43:	74 06                	je     801c4b <ipc_recv+0x32>
			*from_env_store = 0;
  801c45:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801c4b:	85 db                	test   %ebx,%ebx
  801c4d:	74 2c                	je     801c7b <ipc_recv+0x62>
			*perm_store = 0;
  801c4f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c55:	eb 24                	jmp    801c7b <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801c57:	85 f6                	test   %esi,%esi
  801c59:	74 0a                	je     801c65 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801c5b:	a1 08 40 80 00       	mov    0x804008,%eax
  801c60:	8b 40 74             	mov    0x74(%eax),%eax
  801c63:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801c65:	85 db                	test   %ebx,%ebx
  801c67:	74 0a                	je     801c73 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801c69:	a1 08 40 80 00       	mov    0x804008,%eax
  801c6e:	8b 40 78             	mov    0x78(%eax),%eax
  801c71:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801c73:	a1 08 40 80 00       	mov    0x804008,%eax
  801c78:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c7e:	5b                   	pop    %ebx
  801c7f:	5e                   	pop    %esi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    

00801c82 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	57                   	push   %edi
  801c86:	56                   	push   %esi
  801c87:	53                   	push   %ebx
  801c88:	83 ec 0c             	sub    $0xc,%esp
  801c8b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c8e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c91:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801c94:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801c96:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c9b:	0f 44 d8             	cmove  %eax,%ebx
  801c9e:	eb 1e                	jmp    801cbe <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801ca0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ca3:	74 14                	je     801cb9 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801ca5:	83 ec 04             	sub    $0x4,%esp
  801ca8:	68 a8 24 80 00       	push   $0x8024a8
  801cad:	6a 44                	push   $0x44
  801caf:	68 d4 24 80 00       	push   $0x8024d4
  801cb4:	e8 1a ff ff ff       	call   801bd3 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801cb9:	e8 44 ef ff ff       	call   800c02 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801cbe:	ff 75 14             	pushl  0x14(%ebp)
  801cc1:	53                   	push   %ebx
  801cc2:	56                   	push   %esi
  801cc3:	57                   	push   %edi
  801cc4:	e8 e5 f0 ff ff       	call   800dae <sys_ipc_try_send>
  801cc9:	83 c4 10             	add    $0x10,%esp
  801ccc:	85 c0                	test   %eax,%eax
  801cce:	78 d0                	js     801ca0 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801cd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cd3:	5b                   	pop    %ebx
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    

00801cd8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cde:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ce3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ce6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cec:	8b 52 50             	mov    0x50(%edx),%edx
  801cef:	39 ca                	cmp    %ecx,%edx
  801cf1:	75 0d                	jne    801d00 <ipc_find_env+0x28>
			return envs[i].env_id;
  801cf3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cf6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801cfb:	8b 40 48             	mov    0x48(%eax),%eax
  801cfe:	eb 0f                	jmp    801d0f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d00:	83 c0 01             	add    $0x1,%eax
  801d03:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d08:	75 d9                	jne    801ce3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d0f:	5d                   	pop    %ebp
  801d10:	c3                   	ret    

00801d11 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d17:	89 d0                	mov    %edx,%eax
  801d19:	c1 e8 16             	shr    $0x16,%eax
  801d1c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d23:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d28:	f6 c1 01             	test   $0x1,%cl
  801d2b:	74 1d                	je     801d4a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d2d:	c1 ea 0c             	shr    $0xc,%edx
  801d30:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d37:	f6 c2 01             	test   $0x1,%dl
  801d3a:	74 0e                	je     801d4a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d3c:	c1 ea 0c             	shr    $0xc,%edx
  801d3f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d46:	ef 
  801d47:	0f b7 c0             	movzwl %ax,%eax
}
  801d4a:	5d                   	pop    %ebp
  801d4b:	c3                   	ret    
  801d4c:	66 90                	xchg   %ax,%ax
  801d4e:	66 90                	xchg   %ax,%ax

00801d50 <__udivdi3>:
  801d50:	55                   	push   %ebp
  801d51:	57                   	push   %edi
  801d52:	56                   	push   %esi
  801d53:	53                   	push   %ebx
  801d54:	83 ec 1c             	sub    $0x1c,%esp
  801d57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801d5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801d5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801d63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d67:	85 f6                	test   %esi,%esi
  801d69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d6d:	89 ca                	mov    %ecx,%edx
  801d6f:	89 f8                	mov    %edi,%eax
  801d71:	75 3d                	jne    801db0 <__udivdi3+0x60>
  801d73:	39 cf                	cmp    %ecx,%edi
  801d75:	0f 87 c5 00 00 00    	ja     801e40 <__udivdi3+0xf0>
  801d7b:	85 ff                	test   %edi,%edi
  801d7d:	89 fd                	mov    %edi,%ebp
  801d7f:	75 0b                	jne    801d8c <__udivdi3+0x3c>
  801d81:	b8 01 00 00 00       	mov    $0x1,%eax
  801d86:	31 d2                	xor    %edx,%edx
  801d88:	f7 f7                	div    %edi
  801d8a:	89 c5                	mov    %eax,%ebp
  801d8c:	89 c8                	mov    %ecx,%eax
  801d8e:	31 d2                	xor    %edx,%edx
  801d90:	f7 f5                	div    %ebp
  801d92:	89 c1                	mov    %eax,%ecx
  801d94:	89 d8                	mov    %ebx,%eax
  801d96:	89 cf                	mov    %ecx,%edi
  801d98:	f7 f5                	div    %ebp
  801d9a:	89 c3                	mov    %eax,%ebx
  801d9c:	89 d8                	mov    %ebx,%eax
  801d9e:	89 fa                	mov    %edi,%edx
  801da0:	83 c4 1c             	add    $0x1c,%esp
  801da3:	5b                   	pop    %ebx
  801da4:	5e                   	pop    %esi
  801da5:	5f                   	pop    %edi
  801da6:	5d                   	pop    %ebp
  801da7:	c3                   	ret    
  801da8:	90                   	nop
  801da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db0:	39 ce                	cmp    %ecx,%esi
  801db2:	77 74                	ja     801e28 <__udivdi3+0xd8>
  801db4:	0f bd fe             	bsr    %esi,%edi
  801db7:	83 f7 1f             	xor    $0x1f,%edi
  801dba:	0f 84 98 00 00 00    	je     801e58 <__udivdi3+0x108>
  801dc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801dc5:	89 f9                	mov    %edi,%ecx
  801dc7:	89 c5                	mov    %eax,%ebp
  801dc9:	29 fb                	sub    %edi,%ebx
  801dcb:	d3 e6                	shl    %cl,%esi
  801dcd:	89 d9                	mov    %ebx,%ecx
  801dcf:	d3 ed                	shr    %cl,%ebp
  801dd1:	89 f9                	mov    %edi,%ecx
  801dd3:	d3 e0                	shl    %cl,%eax
  801dd5:	09 ee                	or     %ebp,%esi
  801dd7:	89 d9                	mov    %ebx,%ecx
  801dd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ddd:	89 d5                	mov    %edx,%ebp
  801ddf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801de3:	d3 ed                	shr    %cl,%ebp
  801de5:	89 f9                	mov    %edi,%ecx
  801de7:	d3 e2                	shl    %cl,%edx
  801de9:	89 d9                	mov    %ebx,%ecx
  801deb:	d3 e8                	shr    %cl,%eax
  801ded:	09 c2                	or     %eax,%edx
  801def:	89 d0                	mov    %edx,%eax
  801df1:	89 ea                	mov    %ebp,%edx
  801df3:	f7 f6                	div    %esi
  801df5:	89 d5                	mov    %edx,%ebp
  801df7:	89 c3                	mov    %eax,%ebx
  801df9:	f7 64 24 0c          	mull   0xc(%esp)
  801dfd:	39 d5                	cmp    %edx,%ebp
  801dff:	72 10                	jb     801e11 <__udivdi3+0xc1>
  801e01:	8b 74 24 08          	mov    0x8(%esp),%esi
  801e05:	89 f9                	mov    %edi,%ecx
  801e07:	d3 e6                	shl    %cl,%esi
  801e09:	39 c6                	cmp    %eax,%esi
  801e0b:	73 07                	jae    801e14 <__udivdi3+0xc4>
  801e0d:	39 d5                	cmp    %edx,%ebp
  801e0f:	75 03                	jne    801e14 <__udivdi3+0xc4>
  801e11:	83 eb 01             	sub    $0x1,%ebx
  801e14:	31 ff                	xor    %edi,%edi
  801e16:	89 d8                	mov    %ebx,%eax
  801e18:	89 fa                	mov    %edi,%edx
  801e1a:	83 c4 1c             	add    $0x1c,%esp
  801e1d:	5b                   	pop    %ebx
  801e1e:	5e                   	pop    %esi
  801e1f:	5f                   	pop    %edi
  801e20:	5d                   	pop    %ebp
  801e21:	c3                   	ret    
  801e22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e28:	31 ff                	xor    %edi,%edi
  801e2a:	31 db                	xor    %ebx,%ebx
  801e2c:	89 d8                	mov    %ebx,%eax
  801e2e:	89 fa                	mov    %edi,%edx
  801e30:	83 c4 1c             	add    $0x1c,%esp
  801e33:	5b                   	pop    %ebx
  801e34:	5e                   	pop    %esi
  801e35:	5f                   	pop    %edi
  801e36:	5d                   	pop    %ebp
  801e37:	c3                   	ret    
  801e38:	90                   	nop
  801e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e40:	89 d8                	mov    %ebx,%eax
  801e42:	f7 f7                	div    %edi
  801e44:	31 ff                	xor    %edi,%edi
  801e46:	89 c3                	mov    %eax,%ebx
  801e48:	89 d8                	mov    %ebx,%eax
  801e4a:	89 fa                	mov    %edi,%edx
  801e4c:	83 c4 1c             	add    $0x1c,%esp
  801e4f:	5b                   	pop    %ebx
  801e50:	5e                   	pop    %esi
  801e51:	5f                   	pop    %edi
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    
  801e54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e58:	39 ce                	cmp    %ecx,%esi
  801e5a:	72 0c                	jb     801e68 <__udivdi3+0x118>
  801e5c:	31 db                	xor    %ebx,%ebx
  801e5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801e62:	0f 87 34 ff ff ff    	ja     801d9c <__udivdi3+0x4c>
  801e68:	bb 01 00 00 00       	mov    $0x1,%ebx
  801e6d:	e9 2a ff ff ff       	jmp    801d9c <__udivdi3+0x4c>
  801e72:	66 90                	xchg   %ax,%ax
  801e74:	66 90                	xchg   %ax,%ax
  801e76:	66 90                	xchg   %ax,%ax
  801e78:	66 90                	xchg   %ax,%ax
  801e7a:	66 90                	xchg   %ax,%ax
  801e7c:	66 90                	xchg   %ax,%ax
  801e7e:	66 90                	xchg   %ax,%ax

00801e80 <__umoddi3>:
  801e80:	55                   	push   %ebp
  801e81:	57                   	push   %edi
  801e82:	56                   	push   %esi
  801e83:	53                   	push   %ebx
  801e84:	83 ec 1c             	sub    $0x1c,%esp
  801e87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e97:	85 d2                	test   %edx,%edx
  801e99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ea1:	89 f3                	mov    %esi,%ebx
  801ea3:	89 3c 24             	mov    %edi,(%esp)
  801ea6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eaa:	75 1c                	jne    801ec8 <__umoddi3+0x48>
  801eac:	39 f7                	cmp    %esi,%edi
  801eae:	76 50                	jbe    801f00 <__umoddi3+0x80>
  801eb0:	89 c8                	mov    %ecx,%eax
  801eb2:	89 f2                	mov    %esi,%edx
  801eb4:	f7 f7                	div    %edi
  801eb6:	89 d0                	mov    %edx,%eax
  801eb8:	31 d2                	xor    %edx,%edx
  801eba:	83 c4 1c             	add    $0x1c,%esp
  801ebd:	5b                   	pop    %ebx
  801ebe:	5e                   	pop    %esi
  801ebf:	5f                   	pop    %edi
  801ec0:	5d                   	pop    %ebp
  801ec1:	c3                   	ret    
  801ec2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ec8:	39 f2                	cmp    %esi,%edx
  801eca:	89 d0                	mov    %edx,%eax
  801ecc:	77 52                	ja     801f20 <__umoddi3+0xa0>
  801ece:	0f bd ea             	bsr    %edx,%ebp
  801ed1:	83 f5 1f             	xor    $0x1f,%ebp
  801ed4:	75 5a                	jne    801f30 <__umoddi3+0xb0>
  801ed6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801eda:	0f 82 e0 00 00 00    	jb     801fc0 <__umoddi3+0x140>
  801ee0:	39 0c 24             	cmp    %ecx,(%esp)
  801ee3:	0f 86 d7 00 00 00    	jbe    801fc0 <__umoddi3+0x140>
  801ee9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801eed:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ef1:	83 c4 1c             	add    $0x1c,%esp
  801ef4:	5b                   	pop    %ebx
  801ef5:	5e                   	pop    %esi
  801ef6:	5f                   	pop    %edi
  801ef7:	5d                   	pop    %ebp
  801ef8:	c3                   	ret    
  801ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f00:	85 ff                	test   %edi,%edi
  801f02:	89 fd                	mov    %edi,%ebp
  801f04:	75 0b                	jne    801f11 <__umoddi3+0x91>
  801f06:	b8 01 00 00 00       	mov    $0x1,%eax
  801f0b:	31 d2                	xor    %edx,%edx
  801f0d:	f7 f7                	div    %edi
  801f0f:	89 c5                	mov    %eax,%ebp
  801f11:	89 f0                	mov    %esi,%eax
  801f13:	31 d2                	xor    %edx,%edx
  801f15:	f7 f5                	div    %ebp
  801f17:	89 c8                	mov    %ecx,%eax
  801f19:	f7 f5                	div    %ebp
  801f1b:	89 d0                	mov    %edx,%eax
  801f1d:	eb 99                	jmp    801eb8 <__umoddi3+0x38>
  801f1f:	90                   	nop
  801f20:	89 c8                	mov    %ecx,%eax
  801f22:	89 f2                	mov    %esi,%edx
  801f24:	83 c4 1c             	add    $0x1c,%esp
  801f27:	5b                   	pop    %ebx
  801f28:	5e                   	pop    %esi
  801f29:	5f                   	pop    %edi
  801f2a:	5d                   	pop    %ebp
  801f2b:	c3                   	ret    
  801f2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f30:	8b 34 24             	mov    (%esp),%esi
  801f33:	bf 20 00 00 00       	mov    $0x20,%edi
  801f38:	89 e9                	mov    %ebp,%ecx
  801f3a:	29 ef                	sub    %ebp,%edi
  801f3c:	d3 e0                	shl    %cl,%eax
  801f3e:	89 f9                	mov    %edi,%ecx
  801f40:	89 f2                	mov    %esi,%edx
  801f42:	d3 ea                	shr    %cl,%edx
  801f44:	89 e9                	mov    %ebp,%ecx
  801f46:	09 c2                	or     %eax,%edx
  801f48:	89 d8                	mov    %ebx,%eax
  801f4a:	89 14 24             	mov    %edx,(%esp)
  801f4d:	89 f2                	mov    %esi,%edx
  801f4f:	d3 e2                	shl    %cl,%edx
  801f51:	89 f9                	mov    %edi,%ecx
  801f53:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f57:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f5b:	d3 e8                	shr    %cl,%eax
  801f5d:	89 e9                	mov    %ebp,%ecx
  801f5f:	89 c6                	mov    %eax,%esi
  801f61:	d3 e3                	shl    %cl,%ebx
  801f63:	89 f9                	mov    %edi,%ecx
  801f65:	89 d0                	mov    %edx,%eax
  801f67:	d3 e8                	shr    %cl,%eax
  801f69:	89 e9                	mov    %ebp,%ecx
  801f6b:	09 d8                	or     %ebx,%eax
  801f6d:	89 d3                	mov    %edx,%ebx
  801f6f:	89 f2                	mov    %esi,%edx
  801f71:	f7 34 24             	divl   (%esp)
  801f74:	89 d6                	mov    %edx,%esi
  801f76:	d3 e3                	shl    %cl,%ebx
  801f78:	f7 64 24 04          	mull   0x4(%esp)
  801f7c:	39 d6                	cmp    %edx,%esi
  801f7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f82:	89 d1                	mov    %edx,%ecx
  801f84:	89 c3                	mov    %eax,%ebx
  801f86:	72 08                	jb     801f90 <__umoddi3+0x110>
  801f88:	75 11                	jne    801f9b <__umoddi3+0x11b>
  801f8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801f8e:	73 0b                	jae    801f9b <__umoddi3+0x11b>
  801f90:	2b 44 24 04          	sub    0x4(%esp),%eax
  801f94:	1b 14 24             	sbb    (%esp),%edx
  801f97:	89 d1                	mov    %edx,%ecx
  801f99:	89 c3                	mov    %eax,%ebx
  801f9b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f9f:	29 da                	sub    %ebx,%edx
  801fa1:	19 ce                	sbb    %ecx,%esi
  801fa3:	89 f9                	mov    %edi,%ecx
  801fa5:	89 f0                	mov    %esi,%eax
  801fa7:	d3 e0                	shl    %cl,%eax
  801fa9:	89 e9                	mov    %ebp,%ecx
  801fab:	d3 ea                	shr    %cl,%edx
  801fad:	89 e9                	mov    %ebp,%ecx
  801faf:	d3 ee                	shr    %cl,%esi
  801fb1:	09 d0                	or     %edx,%eax
  801fb3:	89 f2                	mov    %esi,%edx
  801fb5:	83 c4 1c             	add    $0x1c,%esp
  801fb8:	5b                   	pop    %ebx
  801fb9:	5e                   	pop    %esi
  801fba:	5f                   	pop    %edi
  801fbb:	5d                   	pop    %ebp
  801fbc:	c3                   	ret    
  801fbd:	8d 76 00             	lea    0x0(%esi),%esi
  801fc0:	29 f9                	sub    %edi,%ecx
  801fc2:	19 d6                	sbb    %edx,%esi
  801fc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fc8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fcc:	e9 18 ff ff ff       	jmp    801ee9 <__umoddi3+0x69>
