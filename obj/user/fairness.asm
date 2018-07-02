
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 c4 0b 00 00       	call   800c04 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 08 40 80 00 7c 	cmpl   $0xeec0007c,0x804008
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 d5 0d 00 00       	call   800e33 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 80 1f 80 00       	push   $0x801f80
  80006a:	e8 25 01 00 00       	call   800194 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 91 1f 80 00       	push   $0x801f91
  800083:	e8 0c 01 00 00       	call   800194 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 00 0e 00 00       	call   800e9c <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ac:	e8 53 0b 00 00       	call   800c04 <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 04 10 00 00       	call   8010f6 <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 c7 0a 00 00       	call   800bc3 <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	75 1a                	jne    80013a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	68 ff 00 00 00       	push   $0xff
  800128:	8d 43 08             	lea    0x8(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 55 0a 00 00       	call   800b86 <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800137:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	68 01 01 80 00       	push   $0x800101
  800172:	e8 54 01 00 00       	call   8002cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800177:	83 c4 08             	add    $0x8,%esp
  80017a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	50                   	push   %eax
  800187:	e8 fa 09 00 00       	call   800b86 <sys_cputs>

	return b.cnt;
}
  80018c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019d:	50                   	push   %eax
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	e8 9d ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 1c             	sub    $0x1c,%esp
  8001b1:	89 c7                	mov    %eax,%edi
  8001b3:	89 d6                	mov    %edx,%esi
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001be:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001cc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cf:	39 d3                	cmp    %edx,%ebx
  8001d1:	72 05                	jb     8001d8 <printnum+0x30>
  8001d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d6:	77 45                	ja     80021d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	ff 75 18             	pushl  0x18(%ebp)
  8001de:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e4:	53                   	push   %ebx
  8001e5:	ff 75 10             	pushl  0x10(%ebp)
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 e4 1a 00 00       	call   801ce0 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	89 f2                	mov    %esi,%edx
  800203:	89 f8                	mov    %edi,%eax
  800205:	e8 9e ff ff ff       	call   8001a8 <printnum>
  80020a:	83 c4 20             	add    $0x20,%esp
  80020d:	eb 18                	jmp    800227 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	ff d7                	call   *%edi
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	eb 03                	jmp    800220 <printnum+0x78>
  80021d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800220:	83 eb 01             	sub    $0x1,%ebx
  800223:	85 db                	test   %ebx,%ebx
  800225:	7f e8                	jg     80020f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	83 ec 04             	sub    $0x4,%esp
  80022e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800231:	ff 75 e0             	pushl  -0x20(%ebp)
  800234:	ff 75 dc             	pushl  -0x24(%ebp)
  800237:	ff 75 d8             	pushl  -0x28(%ebp)
  80023a:	e8 d1 1b 00 00       	call   801e10 <__umoddi3>
  80023f:	83 c4 14             	add    $0x14,%esp
  800242:	0f be 80 b2 1f 80 00 	movsbl 0x801fb2(%eax),%eax
  800249:	50                   	push   %eax
  80024a:	ff d7                	call   *%edi
}
  80024c:	83 c4 10             	add    $0x10,%esp
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025a:	83 fa 01             	cmp    $0x1,%edx
  80025d:	7e 0e                	jle    80026d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025f:	8b 10                	mov    (%eax),%edx
  800261:	8d 4a 08             	lea    0x8(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 02                	mov    (%edx),%eax
  800268:	8b 52 04             	mov    0x4(%edx),%edx
  80026b:	eb 22                	jmp    80028f <getuint+0x38>
	else if (lflag)
  80026d:	85 d2                	test   %edx,%edx
  80026f:	74 10                	je     800281 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800271:	8b 10                	mov    (%eax),%edx
  800273:	8d 4a 04             	lea    0x4(%edx),%ecx
  800276:	89 08                	mov    %ecx,(%eax)
  800278:	8b 02                	mov    (%edx),%eax
  80027a:	ba 00 00 00 00       	mov    $0x0,%edx
  80027f:	eb 0e                	jmp    80028f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800281:	8b 10                	mov    (%eax),%edx
  800283:	8d 4a 04             	lea    0x4(%edx),%ecx
  800286:	89 08                	mov    %ecx,(%eax)
  800288:	8b 02                	mov    (%edx),%eax
  80028a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800297:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029b:	8b 10                	mov    (%eax),%edx
  80029d:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a0:	73 0a                	jae    8002ac <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002aa:	88 02                	mov    %al,(%edx)
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b7:	50                   	push   %eax
  8002b8:	ff 75 10             	pushl  0x10(%ebp)
  8002bb:	ff 75 0c             	pushl  0xc(%ebp)
  8002be:	ff 75 08             	pushl  0x8(%ebp)
  8002c1:	e8 05 00 00 00       	call   8002cb <vprintfmt>
	va_end(ap);
}
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	c9                   	leave  
  8002ca:	c3                   	ret    

008002cb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	57                   	push   %edi
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
  8002d1:	83 ec 2c             	sub    $0x2c,%esp
  8002d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002da:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002dd:	eb 12                	jmp    8002f1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002df:	85 c0                	test   %eax,%eax
  8002e1:	0f 84 38 04 00 00    	je     80071f <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	53                   	push   %ebx
  8002eb:	50                   	push   %eax
  8002ec:	ff d6                	call   *%esi
  8002ee:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f1:	83 c7 01             	add    $0x1,%edi
  8002f4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f8:	83 f8 25             	cmp    $0x25,%eax
  8002fb:	75 e2                	jne    8002df <vprintfmt+0x14>
  8002fd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800301:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800308:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80030f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800316:	ba 00 00 00 00       	mov    $0x0,%edx
  80031b:	eb 07                	jmp    800324 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  800320:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8d 47 01             	lea    0x1(%edi),%eax
  800327:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032a:	0f b6 07             	movzbl (%edi),%eax
  80032d:	0f b6 c8             	movzbl %al,%ecx
  800330:	83 e8 23             	sub    $0x23,%eax
  800333:	3c 55                	cmp    $0x55,%al
  800335:	0f 87 c9 03 00 00    	ja     800704 <vprintfmt+0x439>
  80033b:	0f b6 c0             	movzbl %al,%eax
  80033e:	ff 24 85 00 21 80 00 	jmp    *0x802100(,%eax,4)
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800348:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80034c:	eb d6                	jmp    800324 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  80034e:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  800355:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800358:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  80035b:	eb 94                	jmp    8002f1 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  80035d:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  800364:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  80036a:	eb 85                	jmp    8002f1 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  80036c:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  800373:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  800379:	e9 73 ff ff ff       	jmp    8002f1 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  80037e:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  800385:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  80038b:	e9 61 ff ff ff       	jmp    8002f1 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  800390:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800397:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  80039d:	e9 4f ff ff ff       	jmp    8002f1 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  8003a2:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  8003a9:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  8003af:	e9 3d ff ff ff       	jmp    8002f1 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  8003b4:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  8003bb:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  8003c1:	e9 2b ff ff ff       	jmp    8002f1 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  8003c6:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  8003cd:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8003d3:	e9 19 ff ff ff       	jmp    8002f1 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  8003d8:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  8003df:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8003e5:	e9 07 ff ff ff       	jmp    8002f1 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8003ea:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  8003f1:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8003f7:	e9 f5 fe ff ff       	jmp    8002f1 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800404:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800407:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80040a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80040e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800411:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800414:	83 fa 09             	cmp    $0x9,%edx
  800417:	77 3f                	ja     800458 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800419:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80041c:	eb e9                	jmp    800407 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80041e:	8b 45 14             	mov    0x14(%ebp),%eax
  800421:	8d 48 04             	lea    0x4(%eax),%ecx
  800424:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800427:	8b 00                	mov    (%eax),%eax
  800429:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80042f:	eb 2d                	jmp    80045e <vprintfmt+0x193>
  800431:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800434:	85 c0                	test   %eax,%eax
  800436:	b9 00 00 00 00       	mov    $0x0,%ecx
  80043b:	0f 49 c8             	cmovns %eax,%ecx
  80043e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800444:	e9 db fe ff ff       	jmp    800324 <vprintfmt+0x59>
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80044c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800453:	e9 cc fe ff ff       	jmp    800324 <vprintfmt+0x59>
  800458:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80045b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80045e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800462:	0f 89 bc fe ff ff    	jns    800324 <vprintfmt+0x59>
				width = precision, precision = -1;
  800468:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80046b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800475:	e9 aa fe ff ff       	jmp    800324 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80047a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800480:	e9 9f fe ff ff       	jmp    800324 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800485:	8b 45 14             	mov    0x14(%ebp),%eax
  800488:	8d 50 04             	lea    0x4(%eax),%edx
  80048b:	89 55 14             	mov    %edx,0x14(%ebp)
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	53                   	push   %ebx
  800492:	ff 30                	pushl  (%eax)
  800494:	ff d6                	call   *%esi
			break;
  800496:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80049c:	e9 50 fe ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a4:	8d 50 04             	lea    0x4(%eax),%edx
  8004a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004aa:	8b 00                	mov    (%eax),%eax
  8004ac:	99                   	cltd   
  8004ad:	31 d0                	xor    %edx,%eax
  8004af:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b1:	83 f8 0f             	cmp    $0xf,%eax
  8004b4:	7f 0b                	jg     8004c1 <vprintfmt+0x1f6>
  8004b6:	8b 14 85 60 22 80 00 	mov    0x802260(,%eax,4),%edx
  8004bd:	85 d2                	test   %edx,%edx
  8004bf:	75 18                	jne    8004d9 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  8004c1:	50                   	push   %eax
  8004c2:	68 ca 1f 80 00       	push   $0x801fca
  8004c7:	53                   	push   %ebx
  8004c8:	56                   	push   %esi
  8004c9:	e8 e0 fd ff ff       	call   8002ae <printfmt>
  8004ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004d4:	e9 18 fe ff ff       	jmp    8002f1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004d9:	52                   	push   %edx
  8004da:	68 c9 23 80 00       	push   $0x8023c9
  8004df:	53                   	push   %ebx
  8004e0:	56                   	push   %esi
  8004e1:	e8 c8 fd ff ff       	call   8002ae <printfmt>
  8004e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ec:	e9 00 fe ff ff       	jmp    8002f1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8d 50 04             	lea    0x4(%eax),%edx
  8004f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fa:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004fc:	85 ff                	test   %edi,%edi
  8004fe:	b8 c3 1f 80 00       	mov    $0x801fc3,%eax
  800503:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800506:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050a:	0f 8e 94 00 00 00    	jle    8005a4 <vprintfmt+0x2d9>
  800510:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800514:	0f 84 98 00 00 00    	je     8005b2 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	ff 75 d0             	pushl  -0x30(%ebp)
  800520:	57                   	push   %edi
  800521:	e8 81 02 00 00       	call   8007a7 <strnlen>
  800526:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800529:	29 c1                	sub    %eax,%ecx
  80052b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80052e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800531:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800535:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800538:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80053b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053d:	eb 0f                	jmp    80054e <vprintfmt+0x283>
					putch(padc, putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	53                   	push   %ebx
  800543:	ff 75 e0             	pushl  -0x20(%ebp)
  800546:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800548:	83 ef 01             	sub    $0x1,%edi
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	85 ff                	test   %edi,%edi
  800550:	7f ed                	jg     80053f <vprintfmt+0x274>
  800552:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800555:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800558:	85 c9                	test   %ecx,%ecx
  80055a:	b8 00 00 00 00       	mov    $0x0,%eax
  80055f:	0f 49 c1             	cmovns %ecx,%eax
  800562:	29 c1                	sub    %eax,%ecx
  800564:	89 75 08             	mov    %esi,0x8(%ebp)
  800567:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056d:	89 cb                	mov    %ecx,%ebx
  80056f:	eb 4d                	jmp    8005be <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800571:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800575:	74 1b                	je     800592 <vprintfmt+0x2c7>
  800577:	0f be c0             	movsbl %al,%eax
  80057a:	83 e8 20             	sub    $0x20,%eax
  80057d:	83 f8 5e             	cmp    $0x5e,%eax
  800580:	76 10                	jbe    800592 <vprintfmt+0x2c7>
					putch('?', putdat);
  800582:	83 ec 08             	sub    $0x8,%esp
  800585:	ff 75 0c             	pushl  0xc(%ebp)
  800588:	6a 3f                	push   $0x3f
  80058a:	ff 55 08             	call   *0x8(%ebp)
  80058d:	83 c4 10             	add    $0x10,%esp
  800590:	eb 0d                	jmp    80059f <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	ff 75 0c             	pushl  0xc(%ebp)
  800598:	52                   	push   %edx
  800599:	ff 55 08             	call   *0x8(%ebp)
  80059c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059f:	83 eb 01             	sub    $0x1,%ebx
  8005a2:	eb 1a                	jmp    8005be <vprintfmt+0x2f3>
  8005a4:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005aa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ad:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b0:	eb 0c                	jmp    8005be <vprintfmt+0x2f3>
  8005b2:	89 75 08             	mov    %esi,0x8(%ebp)
  8005b5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005bb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005be:	83 c7 01             	add    $0x1,%edi
  8005c1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005c5:	0f be d0             	movsbl %al,%edx
  8005c8:	85 d2                	test   %edx,%edx
  8005ca:	74 23                	je     8005ef <vprintfmt+0x324>
  8005cc:	85 f6                	test   %esi,%esi
  8005ce:	78 a1                	js     800571 <vprintfmt+0x2a6>
  8005d0:	83 ee 01             	sub    $0x1,%esi
  8005d3:	79 9c                	jns    800571 <vprintfmt+0x2a6>
  8005d5:	89 df                	mov    %ebx,%edi
  8005d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8005da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005dd:	eb 18                	jmp    8005f7 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	53                   	push   %ebx
  8005e3:	6a 20                	push   $0x20
  8005e5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e7:	83 ef 01             	sub    $0x1,%edi
  8005ea:	83 c4 10             	add    $0x10,%esp
  8005ed:	eb 08                	jmp    8005f7 <vprintfmt+0x32c>
  8005ef:	89 df                	mov    %ebx,%edi
  8005f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f7:	85 ff                	test   %edi,%edi
  8005f9:	7f e4                	jg     8005df <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fe:	e9 ee fc ff ff       	jmp    8002f1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800603:	83 fa 01             	cmp    $0x1,%edx
  800606:	7e 16                	jle    80061e <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 50 08             	lea    0x8(%eax),%edx
  80060e:	89 55 14             	mov    %edx,0x14(%ebp)
  800611:	8b 50 04             	mov    0x4(%eax),%edx
  800614:	8b 00                	mov    (%eax),%eax
  800616:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800619:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80061c:	eb 32                	jmp    800650 <vprintfmt+0x385>
	else if (lflag)
  80061e:	85 d2                	test   %edx,%edx
  800620:	74 18                	je     80063a <vprintfmt+0x36f>
		return va_arg(*ap, long);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 04             	lea    0x4(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)
  80062b:	8b 00                	mov    (%eax),%eax
  80062d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800630:	89 c1                	mov    %eax,%ecx
  800632:	c1 f9 1f             	sar    $0x1f,%ecx
  800635:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800638:	eb 16                	jmp    800650 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	8b 00                	mov    (%eax),%eax
  800645:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800648:	89 c1                	mov    %eax,%ecx
  80064a:	c1 f9 1f             	sar    $0x1f,%ecx
  80064d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800650:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800653:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800656:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80065b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80065f:	79 6f                	jns    8006d0 <vprintfmt+0x405>
				putch('-', putdat);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	53                   	push   %ebx
  800665:	6a 2d                	push   $0x2d
  800667:	ff d6                	call   *%esi
				num = -(long long) num;
  800669:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80066c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80066f:	f7 d8                	neg    %eax
  800671:	83 d2 00             	adc    $0x0,%edx
  800674:	f7 da                	neg    %edx
  800676:	83 c4 10             	add    $0x10,%esp
  800679:	eb 55                	jmp    8006d0 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 d4 fb ff ff       	call   800257 <getuint>
			base = 10;
  800683:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800688:	eb 46                	jmp    8006d0 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80068a:	8d 45 14             	lea    0x14(%ebp),%eax
  80068d:	e8 c5 fb ff ff       	call   800257 <getuint>
			base = 8;
  800692:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800697:	eb 37                	jmp    8006d0 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800699:	83 ec 08             	sub    $0x8,%esp
  80069c:	53                   	push   %ebx
  80069d:	6a 30                	push   $0x30
  80069f:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a1:	83 c4 08             	add    $0x8,%esp
  8006a4:	53                   	push   %ebx
  8006a5:	6a 78                	push   $0x78
  8006a7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	8d 50 04             	lea    0x4(%eax),%edx
  8006af:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006b2:	8b 00                	mov    (%eax),%eax
  8006b4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006bc:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8006c1:	eb 0d                	jmp    8006d0 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c6:	e8 8c fb ff ff       	call   800257 <getuint>
			base = 16;
  8006cb:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d0:	83 ec 0c             	sub    $0xc,%esp
  8006d3:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8006d7:	51                   	push   %ecx
  8006d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006db:	57                   	push   %edi
  8006dc:	52                   	push   %edx
  8006dd:	50                   	push   %eax
  8006de:	89 da                	mov    %ebx,%edx
  8006e0:	89 f0                	mov    %esi,%eax
  8006e2:	e8 c1 fa ff ff       	call   8001a8 <printnum>
			break;
  8006e7:	83 c4 20             	add    $0x20,%esp
  8006ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ed:	e9 ff fb ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	51                   	push   %ecx
  8006f7:	ff d6                	call   *%esi
			break;
  8006f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ff:	e9 ed fb ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800704:	83 ec 08             	sub    $0x8,%esp
  800707:	53                   	push   %ebx
  800708:	6a 25                	push   $0x25
  80070a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	eb 03                	jmp    800714 <vprintfmt+0x449>
  800711:	83 ef 01             	sub    $0x1,%edi
  800714:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800718:	75 f7                	jne    800711 <vprintfmt+0x446>
  80071a:	e9 d2 fb ff ff       	jmp    8002f1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80071f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800722:	5b                   	pop    %ebx
  800723:	5e                   	pop    %esi
  800724:	5f                   	pop    %edi
  800725:	5d                   	pop    %ebp
  800726:	c3                   	ret    

00800727 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	83 ec 18             	sub    $0x18,%esp
  80072d:	8b 45 08             	mov    0x8(%ebp),%eax
  800730:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800733:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800736:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800744:	85 c0                	test   %eax,%eax
  800746:	74 26                	je     80076e <vsnprintf+0x47>
  800748:	85 d2                	test   %edx,%edx
  80074a:	7e 22                	jle    80076e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074c:	ff 75 14             	pushl  0x14(%ebp)
  80074f:	ff 75 10             	pushl  0x10(%ebp)
  800752:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800755:	50                   	push   %eax
  800756:	68 91 02 80 00       	push   $0x800291
  80075b:	e8 6b fb ff ff       	call   8002cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800760:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800763:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800766:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800769:	83 c4 10             	add    $0x10,%esp
  80076c:	eb 05                	jmp    800773 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80076e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800773:	c9                   	leave  
  800774:	c3                   	ret    

00800775 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80077e:	50                   	push   %eax
  80077f:	ff 75 10             	pushl  0x10(%ebp)
  800782:	ff 75 0c             	pushl  0xc(%ebp)
  800785:	ff 75 08             	pushl  0x8(%ebp)
  800788:	e8 9a ff ff ff       	call   800727 <vsnprintf>
	va_end(ap);

	return rc;
}
  80078d:	c9                   	leave  
  80078e:	c3                   	ret    

0080078f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800795:	b8 00 00 00 00       	mov    $0x0,%eax
  80079a:	eb 03                	jmp    80079f <strlen+0x10>
		n++;
  80079c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80079f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a3:	75 f7                	jne    80079c <strlen+0xd>
		n++;
	return n;
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ad:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b5:	eb 03                	jmp    8007ba <strnlen+0x13>
		n++;
  8007b7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ba:	39 c2                	cmp    %eax,%edx
  8007bc:	74 08                	je     8007c6 <strnlen+0x1f>
  8007be:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007c2:	75 f3                	jne    8007b7 <strnlen+0x10>
  8007c4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	53                   	push   %ebx
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d2:	89 c2                	mov    %eax,%edx
  8007d4:	83 c2 01             	add    $0x1,%edx
  8007d7:	83 c1 01             	add    $0x1,%ecx
  8007da:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007de:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e1:	84 db                	test   %bl,%bl
  8007e3:	75 ef                	jne    8007d4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007e5:	5b                   	pop    %ebx
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	53                   	push   %ebx
  8007ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ef:	53                   	push   %ebx
  8007f0:	e8 9a ff ff ff       	call   80078f <strlen>
  8007f5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f8:	ff 75 0c             	pushl  0xc(%ebp)
  8007fb:	01 d8                	add    %ebx,%eax
  8007fd:	50                   	push   %eax
  8007fe:	e8 c5 ff ff ff       	call   8007c8 <strcpy>
	return dst;
}
  800803:	89 d8                	mov    %ebx,%eax
  800805:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	56                   	push   %esi
  80080e:	53                   	push   %ebx
  80080f:	8b 75 08             	mov    0x8(%ebp),%esi
  800812:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800815:	89 f3                	mov    %esi,%ebx
  800817:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081a:	89 f2                	mov    %esi,%edx
  80081c:	eb 0f                	jmp    80082d <strncpy+0x23>
		*dst++ = *src;
  80081e:	83 c2 01             	add    $0x1,%edx
  800821:	0f b6 01             	movzbl (%ecx),%eax
  800824:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800827:	80 39 01             	cmpb   $0x1,(%ecx)
  80082a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082d:	39 da                	cmp    %ebx,%edx
  80082f:	75 ed                	jne    80081e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800831:	89 f0                	mov    %esi,%eax
  800833:	5b                   	pop    %ebx
  800834:	5e                   	pop    %esi
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	56                   	push   %esi
  80083b:	53                   	push   %ebx
  80083c:	8b 75 08             	mov    0x8(%ebp),%esi
  80083f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800842:	8b 55 10             	mov    0x10(%ebp),%edx
  800845:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800847:	85 d2                	test   %edx,%edx
  800849:	74 21                	je     80086c <strlcpy+0x35>
  80084b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80084f:	89 f2                	mov    %esi,%edx
  800851:	eb 09                	jmp    80085c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800853:	83 c2 01             	add    $0x1,%edx
  800856:	83 c1 01             	add    $0x1,%ecx
  800859:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80085c:	39 c2                	cmp    %eax,%edx
  80085e:	74 09                	je     800869 <strlcpy+0x32>
  800860:	0f b6 19             	movzbl (%ecx),%ebx
  800863:	84 db                	test   %bl,%bl
  800865:	75 ec                	jne    800853 <strlcpy+0x1c>
  800867:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800869:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80086c:	29 f0                	sub    %esi,%eax
}
  80086e:	5b                   	pop    %ebx
  80086f:	5e                   	pop    %esi
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800878:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087b:	eb 06                	jmp    800883 <strcmp+0x11>
		p++, q++;
  80087d:	83 c1 01             	add    $0x1,%ecx
  800880:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800883:	0f b6 01             	movzbl (%ecx),%eax
  800886:	84 c0                	test   %al,%al
  800888:	74 04                	je     80088e <strcmp+0x1c>
  80088a:	3a 02                	cmp    (%edx),%al
  80088c:	74 ef                	je     80087d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088e:	0f b6 c0             	movzbl %al,%eax
  800891:	0f b6 12             	movzbl (%edx),%edx
  800894:	29 d0                	sub    %edx,%eax
}
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	53                   	push   %ebx
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a2:	89 c3                	mov    %eax,%ebx
  8008a4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a7:	eb 06                	jmp    8008af <strncmp+0x17>
		n--, p++, q++;
  8008a9:	83 c0 01             	add    $0x1,%eax
  8008ac:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008af:	39 d8                	cmp    %ebx,%eax
  8008b1:	74 15                	je     8008c8 <strncmp+0x30>
  8008b3:	0f b6 08             	movzbl (%eax),%ecx
  8008b6:	84 c9                	test   %cl,%cl
  8008b8:	74 04                	je     8008be <strncmp+0x26>
  8008ba:	3a 0a                	cmp    (%edx),%cl
  8008bc:	74 eb                	je     8008a9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008be:	0f b6 00             	movzbl (%eax),%eax
  8008c1:	0f b6 12             	movzbl (%edx),%edx
  8008c4:	29 d0                	sub    %edx,%eax
  8008c6:	eb 05                	jmp    8008cd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008cd:	5b                   	pop    %ebx
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008da:	eb 07                	jmp    8008e3 <strchr+0x13>
		if (*s == c)
  8008dc:	38 ca                	cmp    %cl,%dl
  8008de:	74 0f                	je     8008ef <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e0:	83 c0 01             	add    $0x1,%eax
  8008e3:	0f b6 10             	movzbl (%eax),%edx
  8008e6:	84 d2                	test   %dl,%dl
  8008e8:	75 f2                	jne    8008dc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fb:	eb 03                	jmp    800900 <strfind+0xf>
  8008fd:	83 c0 01             	add    $0x1,%eax
  800900:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800903:	38 ca                	cmp    %cl,%dl
  800905:	74 04                	je     80090b <strfind+0x1a>
  800907:	84 d2                	test   %dl,%dl
  800909:	75 f2                	jne    8008fd <strfind+0xc>
			break;
	return (char *) s;
}
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	57                   	push   %edi
  800911:	56                   	push   %esi
  800912:	53                   	push   %ebx
  800913:	8b 7d 08             	mov    0x8(%ebp),%edi
  800916:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800919:	85 c9                	test   %ecx,%ecx
  80091b:	74 36                	je     800953 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800923:	75 28                	jne    80094d <memset+0x40>
  800925:	f6 c1 03             	test   $0x3,%cl
  800928:	75 23                	jne    80094d <memset+0x40>
		c &= 0xFF;
  80092a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092e:	89 d3                	mov    %edx,%ebx
  800930:	c1 e3 08             	shl    $0x8,%ebx
  800933:	89 d6                	mov    %edx,%esi
  800935:	c1 e6 18             	shl    $0x18,%esi
  800938:	89 d0                	mov    %edx,%eax
  80093a:	c1 e0 10             	shl    $0x10,%eax
  80093d:	09 f0                	or     %esi,%eax
  80093f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800941:	89 d8                	mov    %ebx,%eax
  800943:	09 d0                	or     %edx,%eax
  800945:	c1 e9 02             	shr    $0x2,%ecx
  800948:	fc                   	cld    
  800949:	f3 ab                	rep stos %eax,%es:(%edi)
  80094b:	eb 06                	jmp    800953 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800950:	fc                   	cld    
  800951:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800953:	89 f8                	mov    %edi,%eax
  800955:	5b                   	pop    %ebx
  800956:	5e                   	pop    %esi
  800957:	5f                   	pop    %edi
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	57                   	push   %edi
  80095e:	56                   	push   %esi
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	8b 75 0c             	mov    0xc(%ebp),%esi
  800965:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800968:	39 c6                	cmp    %eax,%esi
  80096a:	73 35                	jae    8009a1 <memmove+0x47>
  80096c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096f:	39 d0                	cmp    %edx,%eax
  800971:	73 2e                	jae    8009a1 <memmove+0x47>
		s += n;
		d += n;
  800973:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800976:	89 d6                	mov    %edx,%esi
  800978:	09 fe                	or     %edi,%esi
  80097a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800980:	75 13                	jne    800995 <memmove+0x3b>
  800982:	f6 c1 03             	test   $0x3,%cl
  800985:	75 0e                	jne    800995 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800987:	83 ef 04             	sub    $0x4,%edi
  80098a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80098d:	c1 e9 02             	shr    $0x2,%ecx
  800990:	fd                   	std    
  800991:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800993:	eb 09                	jmp    80099e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800995:	83 ef 01             	sub    $0x1,%edi
  800998:	8d 72 ff             	lea    -0x1(%edx),%esi
  80099b:	fd                   	std    
  80099c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099e:	fc                   	cld    
  80099f:	eb 1d                	jmp    8009be <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a1:	89 f2                	mov    %esi,%edx
  8009a3:	09 c2                	or     %eax,%edx
  8009a5:	f6 c2 03             	test   $0x3,%dl
  8009a8:	75 0f                	jne    8009b9 <memmove+0x5f>
  8009aa:	f6 c1 03             	test   $0x3,%cl
  8009ad:	75 0a                	jne    8009b9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009af:	c1 e9 02             	shr    $0x2,%ecx
  8009b2:	89 c7                	mov    %eax,%edi
  8009b4:	fc                   	cld    
  8009b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b7:	eb 05                	jmp    8009be <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b9:	89 c7                	mov    %eax,%edi
  8009bb:	fc                   	cld    
  8009bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009be:	5e                   	pop    %esi
  8009bf:	5f                   	pop    %edi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009c5:	ff 75 10             	pushl  0x10(%ebp)
  8009c8:	ff 75 0c             	pushl  0xc(%ebp)
  8009cb:	ff 75 08             	pushl  0x8(%ebp)
  8009ce:	e8 87 ff ff ff       	call   80095a <memmove>
}
  8009d3:	c9                   	leave  
  8009d4:	c3                   	ret    

008009d5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	56                   	push   %esi
  8009d9:	53                   	push   %ebx
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e0:	89 c6                	mov    %eax,%esi
  8009e2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e5:	eb 1a                	jmp    800a01 <memcmp+0x2c>
		if (*s1 != *s2)
  8009e7:	0f b6 08             	movzbl (%eax),%ecx
  8009ea:	0f b6 1a             	movzbl (%edx),%ebx
  8009ed:	38 d9                	cmp    %bl,%cl
  8009ef:	74 0a                	je     8009fb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009f1:	0f b6 c1             	movzbl %cl,%eax
  8009f4:	0f b6 db             	movzbl %bl,%ebx
  8009f7:	29 d8                	sub    %ebx,%eax
  8009f9:	eb 0f                	jmp    800a0a <memcmp+0x35>
		s1++, s2++;
  8009fb:	83 c0 01             	add    $0x1,%eax
  8009fe:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a01:	39 f0                	cmp    %esi,%eax
  800a03:	75 e2                	jne    8009e7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0a:	5b                   	pop    %ebx
  800a0b:	5e                   	pop    %esi
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	53                   	push   %ebx
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a15:	89 c1                	mov    %eax,%ecx
  800a17:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1e:	eb 0a                	jmp    800a2a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a20:	0f b6 10             	movzbl (%eax),%edx
  800a23:	39 da                	cmp    %ebx,%edx
  800a25:	74 07                	je     800a2e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a27:	83 c0 01             	add    $0x1,%eax
  800a2a:	39 c8                	cmp    %ecx,%eax
  800a2c:	72 f2                	jb     800a20 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a2e:	5b                   	pop    %ebx
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	57                   	push   %edi
  800a35:	56                   	push   %esi
  800a36:	53                   	push   %ebx
  800a37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3d:	eb 03                	jmp    800a42 <strtol+0x11>
		s++;
  800a3f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a42:	0f b6 01             	movzbl (%ecx),%eax
  800a45:	3c 20                	cmp    $0x20,%al
  800a47:	74 f6                	je     800a3f <strtol+0xe>
  800a49:	3c 09                	cmp    $0x9,%al
  800a4b:	74 f2                	je     800a3f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a4d:	3c 2b                	cmp    $0x2b,%al
  800a4f:	75 0a                	jne    800a5b <strtol+0x2a>
		s++;
  800a51:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a54:	bf 00 00 00 00       	mov    $0x0,%edi
  800a59:	eb 11                	jmp    800a6c <strtol+0x3b>
  800a5b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a60:	3c 2d                	cmp    $0x2d,%al
  800a62:	75 08                	jne    800a6c <strtol+0x3b>
		s++, neg = 1;
  800a64:	83 c1 01             	add    $0x1,%ecx
  800a67:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a72:	75 15                	jne    800a89 <strtol+0x58>
  800a74:	80 39 30             	cmpb   $0x30,(%ecx)
  800a77:	75 10                	jne    800a89 <strtol+0x58>
  800a79:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a7d:	75 7c                	jne    800afb <strtol+0xca>
		s += 2, base = 16;
  800a7f:	83 c1 02             	add    $0x2,%ecx
  800a82:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a87:	eb 16                	jmp    800a9f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a89:	85 db                	test   %ebx,%ebx
  800a8b:	75 12                	jne    800a9f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a8d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a92:	80 39 30             	cmpb   $0x30,(%ecx)
  800a95:	75 08                	jne    800a9f <strtol+0x6e>
		s++, base = 8;
  800a97:	83 c1 01             	add    $0x1,%ecx
  800a9a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa7:	0f b6 11             	movzbl (%ecx),%edx
  800aaa:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aad:	89 f3                	mov    %esi,%ebx
  800aaf:	80 fb 09             	cmp    $0x9,%bl
  800ab2:	77 08                	ja     800abc <strtol+0x8b>
			dig = *s - '0';
  800ab4:	0f be d2             	movsbl %dl,%edx
  800ab7:	83 ea 30             	sub    $0x30,%edx
  800aba:	eb 22                	jmp    800ade <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800abc:	8d 72 9f             	lea    -0x61(%edx),%esi
  800abf:	89 f3                	mov    %esi,%ebx
  800ac1:	80 fb 19             	cmp    $0x19,%bl
  800ac4:	77 08                	ja     800ace <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ac6:	0f be d2             	movsbl %dl,%edx
  800ac9:	83 ea 57             	sub    $0x57,%edx
  800acc:	eb 10                	jmp    800ade <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ace:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ad1:	89 f3                	mov    %esi,%ebx
  800ad3:	80 fb 19             	cmp    $0x19,%bl
  800ad6:	77 16                	ja     800aee <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ad8:	0f be d2             	movsbl %dl,%edx
  800adb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ade:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae1:	7d 0b                	jge    800aee <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ae3:	83 c1 01             	add    $0x1,%ecx
  800ae6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aea:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aec:	eb b9                	jmp    800aa7 <strtol+0x76>

	if (endptr)
  800aee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af2:	74 0d                	je     800b01 <strtol+0xd0>
		*endptr = (char *) s;
  800af4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af7:	89 0e                	mov    %ecx,(%esi)
  800af9:	eb 06                	jmp    800b01 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800afb:	85 db                	test   %ebx,%ebx
  800afd:	74 98                	je     800a97 <strtol+0x66>
  800aff:	eb 9e                	jmp    800a9f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b01:	89 c2                	mov    %eax,%edx
  800b03:	f7 da                	neg    %edx
  800b05:	85 ff                	test   %edi,%edi
  800b07:	0f 45 c2             	cmovne %edx,%eax
}
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	5f                   	pop    %edi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
  800b15:	83 ec 04             	sub    $0x4,%esp
  800b18:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800b1b:	57                   	push   %edi
  800b1c:	e8 6e fc ff ff       	call   80078f <strlen>
  800b21:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b24:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800b27:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800b2c:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b31:	eb 46                	jmp    800b79 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800b33:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800b37:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b3a:	80 f9 09             	cmp    $0x9,%cl
  800b3d:	77 08                	ja     800b47 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800b3f:	0f be d2             	movsbl %dl,%edx
  800b42:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b45:	eb 27                	jmp    800b6e <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800b47:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800b4a:	80 f9 05             	cmp    $0x5,%cl
  800b4d:	77 08                	ja     800b57 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800b4f:	0f be d2             	movsbl %dl,%edx
  800b52:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800b55:	eb 17                	jmp    800b6e <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800b57:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800b5a:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800b5d:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800b62:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800b66:	77 06                	ja     800b6e <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800b68:	0f be d2             	movsbl %dl,%edx
  800b6b:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800b6e:	0f af ce             	imul   %esi,%ecx
  800b71:	01 c8                	add    %ecx,%eax
		base *= 16;
  800b73:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b76:	83 eb 01             	sub    $0x1,%ebx
  800b79:	83 fb 01             	cmp    $0x1,%ebx
  800b7c:	7f b5                	jg     800b33 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800b7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	89 c3                	mov    %eax,%ebx
  800b99:	89 c7                	mov    %eax,%edi
  800b9b:	89 c6                	mov    %eax,%esi
  800b9d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	ba 00 00 00 00       	mov    $0x0,%edx
  800baf:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb4:	89 d1                	mov    %edx,%ecx
  800bb6:	89 d3                	mov    %edx,%ebx
  800bb8:	89 d7                	mov    %edx,%edi
  800bba:	89 d6                	mov    %edx,%esi
  800bbc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	89 cb                	mov    %ecx,%ebx
  800bdb:	89 cf                	mov    %ecx,%edi
  800bdd:	89 ce                	mov    %ecx,%esi
  800bdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7e 17                	jle    800bfc <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	50                   	push   %eax
  800be9:	6a 03                	push   $0x3
  800beb:	68 bf 22 80 00       	push   $0x8022bf
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 dc 22 80 00       	push   $0x8022dc
  800bf7:	e8 61 10 00 00       	call   801c5d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0f:	b8 02 00 00 00       	mov    $0x2,%eax
  800c14:	89 d1                	mov    %edx,%ecx
  800c16:	89 d3                	mov    %edx,%ebx
  800c18:	89 d7                	mov    %edx,%edi
  800c1a:	89 d6                	mov    %edx,%esi
  800c1c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_yield>:

void
sys_yield(void)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c33:	89 d1                	mov    %edx,%ecx
  800c35:	89 d3                	mov    %edx,%ebx
  800c37:	89 d7                	mov    %edx,%edi
  800c39:	89 d6                	mov    %edx,%esi
  800c3b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c4b:	be 00 00 00 00       	mov    $0x0,%esi
  800c50:	b8 04 00 00 00       	mov    $0x4,%eax
  800c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5e:	89 f7                	mov    %esi,%edi
  800c60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7e 17                	jle    800c7d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	50                   	push   %eax
  800c6a:	6a 04                	push   $0x4
  800c6c:	68 bf 22 80 00       	push   $0x8022bf
  800c71:	6a 23                	push   $0x23
  800c73:	68 dc 22 80 00       	push   $0x8022dc
  800c78:	e8 e0 0f 00 00       	call   801c5d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c9f:	8b 75 18             	mov    0x18(%ebp),%esi
  800ca2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	7e 17                	jle    800cbf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca8:	83 ec 0c             	sub    $0xc,%esp
  800cab:	50                   	push   %eax
  800cac:	6a 05                	push   $0x5
  800cae:	68 bf 22 80 00       	push   $0x8022bf
  800cb3:	6a 23                	push   $0x23
  800cb5:	68 dc 22 80 00       	push   $0x8022dc
  800cba:	e8 9e 0f 00 00       	call   801c5d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd5:	b8 06 00 00 00       	mov    $0x6,%eax
  800cda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce0:	89 df                	mov    %ebx,%edi
  800ce2:	89 de                	mov    %ebx,%esi
  800ce4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7e 17                	jle    800d01 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cea:	83 ec 0c             	sub    $0xc,%esp
  800ced:	50                   	push   %eax
  800cee:	6a 06                	push   $0x6
  800cf0:	68 bf 22 80 00       	push   $0x8022bf
  800cf5:	6a 23                	push   $0x23
  800cf7:	68 dc 22 80 00       	push   $0x8022dc
  800cfc:	e8 5c 0f 00 00       	call   801c5d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d17:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	89 df                	mov    %ebx,%edi
  800d24:	89 de                	mov    %ebx,%esi
  800d26:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	7e 17                	jle    800d43 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2c:	83 ec 0c             	sub    $0xc,%esp
  800d2f:	50                   	push   %eax
  800d30:	6a 08                	push   $0x8
  800d32:	68 bf 22 80 00       	push   $0x8022bf
  800d37:	6a 23                	push   $0x23
  800d39:	68 dc 22 80 00       	push   $0x8022dc
  800d3e:	e8 1a 0f 00 00       	call   801c5d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
  800d51:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d59:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	89 df                	mov    %ebx,%edi
  800d66:	89 de                	mov    %ebx,%esi
  800d68:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	7e 17                	jle    800d85 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6e:	83 ec 0c             	sub    $0xc,%esp
  800d71:	50                   	push   %eax
  800d72:	6a 0a                	push   $0xa
  800d74:	68 bf 22 80 00       	push   $0x8022bf
  800d79:	6a 23                	push   $0x23
  800d7b:	68 dc 22 80 00       	push   $0x8022dc
  800d80:	e8 d8 0e 00 00       	call   801c5d <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
  800d93:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9b:	b8 09 00 00 00       	mov    $0x9,%eax
  800da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	89 df                	mov    %ebx,%edi
  800da8:	89 de                	mov    %ebx,%esi
  800daa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dac:	85 c0                	test   %eax,%eax
  800dae:	7e 17                	jle    800dc7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db0:	83 ec 0c             	sub    $0xc,%esp
  800db3:	50                   	push   %eax
  800db4:	6a 09                	push   $0x9
  800db6:	68 bf 22 80 00       	push   $0x8022bf
  800dbb:	6a 23                	push   $0x23
  800dbd:	68 dc 22 80 00       	push   $0x8022dc
  800dc2:	e8 96 0e 00 00       	call   801c5d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dca:	5b                   	pop    %ebx
  800dcb:	5e                   	pop    %esi
  800dcc:	5f                   	pop    %edi
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	57                   	push   %edi
  800dd3:	56                   	push   %esi
  800dd4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd5:	be 00 00 00 00       	mov    $0x0,%esi
  800dda:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ddf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de2:	8b 55 08             	mov    0x8(%ebp),%edx
  800de5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800deb:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e00:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e05:	8b 55 08             	mov    0x8(%ebp),%edx
  800e08:	89 cb                	mov    %ecx,%ebx
  800e0a:	89 cf                	mov    %ecx,%edi
  800e0c:	89 ce                	mov    %ecx,%esi
  800e0e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e10:	85 c0                	test   %eax,%eax
  800e12:	7e 17                	jle    800e2b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e14:	83 ec 0c             	sub    $0xc,%esp
  800e17:	50                   	push   %eax
  800e18:	6a 0d                	push   $0xd
  800e1a:	68 bf 22 80 00       	push   $0x8022bf
  800e1f:	6a 23                	push   $0x23
  800e21:	68 dc 22 80 00       	push   $0x8022dc
  800e26:	e8 32 0e 00 00       	call   801c5d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
  800e38:	8b 75 08             	mov    0x8(%ebp),%esi
  800e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  800e41:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  800e43:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800e48:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  800e4b:	83 ec 0c             	sub    $0xc,%esp
  800e4e:	50                   	push   %eax
  800e4f:	e8 9e ff ff ff       	call   800df2 <sys_ipc_recv>
  800e54:	83 c4 10             	add    $0x10,%esp
  800e57:	85 c0                	test   %eax,%eax
  800e59:	79 16                	jns    800e71 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  800e5b:	85 f6                	test   %esi,%esi
  800e5d:	74 06                	je     800e65 <ipc_recv+0x32>
			*from_env_store = 0;
  800e5f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  800e65:	85 db                	test   %ebx,%ebx
  800e67:	74 2c                	je     800e95 <ipc_recv+0x62>
			*perm_store = 0;
  800e69:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800e6f:	eb 24                	jmp    800e95 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  800e71:	85 f6                	test   %esi,%esi
  800e73:	74 0a                	je     800e7f <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  800e75:	a1 08 40 80 00       	mov    0x804008,%eax
  800e7a:	8b 40 74             	mov    0x74(%eax),%eax
  800e7d:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  800e7f:	85 db                	test   %ebx,%ebx
  800e81:	74 0a                	je     800e8d <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  800e83:	a1 08 40 80 00       	mov    0x804008,%eax
  800e88:	8b 40 78             	mov    0x78(%eax),%eax
  800e8b:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  800e8d:	a1 08 40 80 00       	mov    0x804008,%eax
  800e92:	8b 40 70             	mov    0x70(%eax),%eax
}
  800e95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e98:	5b                   	pop    %ebx
  800e99:	5e                   	pop    %esi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	57                   	push   %edi
  800ea0:	56                   	push   %esi
  800ea1:	53                   	push   %ebx
  800ea2:	83 ec 0c             	sub    $0xc,%esp
  800ea5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ea8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800eab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  800eae:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  800eb0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800eb5:	0f 44 d8             	cmove  %eax,%ebx
  800eb8:	eb 1e                	jmp    800ed8 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  800eba:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800ebd:	74 14                	je     800ed3 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  800ebf:	83 ec 04             	sub    $0x4,%esp
  800ec2:	68 ec 22 80 00       	push   $0x8022ec
  800ec7:	6a 44                	push   $0x44
  800ec9:	68 17 23 80 00       	push   $0x802317
  800ece:	e8 8a 0d 00 00       	call   801c5d <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  800ed3:	e8 4b fd ff ff       	call   800c23 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  800ed8:	ff 75 14             	pushl  0x14(%ebp)
  800edb:	53                   	push   %ebx
  800edc:	56                   	push   %esi
  800edd:	57                   	push   %edi
  800ede:	e8 ec fe ff ff       	call   800dcf <sys_ipc_try_send>
  800ee3:	83 c4 10             	add    $0x10,%esp
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	78 d0                	js     800eba <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  800eea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eed:	5b                   	pop    %ebx
  800eee:	5e                   	pop    %esi
  800eef:	5f                   	pop    %edi
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    

00800ef2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800ef8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800efd:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800f00:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800f06:	8b 52 50             	mov    0x50(%edx),%edx
  800f09:	39 ca                	cmp    %ecx,%edx
  800f0b:	75 0d                	jne    800f1a <ipc_find_env+0x28>
			return envs[i].env_id;
  800f0d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f10:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f15:	8b 40 48             	mov    0x48(%eax),%eax
  800f18:	eb 0f                	jmp    800f29 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800f1a:	83 c0 01             	add    $0x1,%eax
  800f1d:	3d 00 04 00 00       	cmp    $0x400,%eax
  800f22:	75 d9                	jne    800efd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800f24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    

00800f2b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f31:	05 00 00 00 30       	add    $0x30000000,%eax
  800f36:	c1 e8 0c             	shr    $0xc,%eax
}
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f41:	05 00 00 00 30       	add    $0x30000000,%eax
  800f46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f4b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    

00800f52 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f58:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f5d:	89 c2                	mov    %eax,%edx
  800f5f:	c1 ea 16             	shr    $0x16,%edx
  800f62:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f69:	f6 c2 01             	test   $0x1,%dl
  800f6c:	74 11                	je     800f7f <fd_alloc+0x2d>
  800f6e:	89 c2                	mov    %eax,%edx
  800f70:	c1 ea 0c             	shr    $0xc,%edx
  800f73:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f7a:	f6 c2 01             	test   $0x1,%dl
  800f7d:	75 09                	jne    800f88 <fd_alloc+0x36>
			*fd_store = fd;
  800f7f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f81:	b8 00 00 00 00       	mov    $0x0,%eax
  800f86:	eb 17                	jmp    800f9f <fd_alloc+0x4d>
  800f88:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f8d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f92:	75 c9                	jne    800f5d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f94:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f9a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    

00800fa1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fa7:	83 f8 1f             	cmp    $0x1f,%eax
  800faa:	77 36                	ja     800fe2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fac:	c1 e0 0c             	shl    $0xc,%eax
  800faf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fb4:	89 c2                	mov    %eax,%edx
  800fb6:	c1 ea 16             	shr    $0x16,%edx
  800fb9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fc0:	f6 c2 01             	test   $0x1,%dl
  800fc3:	74 24                	je     800fe9 <fd_lookup+0x48>
  800fc5:	89 c2                	mov    %eax,%edx
  800fc7:	c1 ea 0c             	shr    $0xc,%edx
  800fca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fd1:	f6 c2 01             	test   $0x1,%dl
  800fd4:	74 1a                	je     800ff0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fd6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fd9:	89 02                	mov    %eax,(%edx)
	return 0;
  800fdb:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe0:	eb 13                	jmp    800ff5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fe2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fe7:	eb 0c                	jmp    800ff5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fe9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fee:	eb 05                	jmp    800ff5 <fd_lookup+0x54>
  800ff0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	83 ec 08             	sub    $0x8,%esp
  800ffd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801000:	ba a0 23 80 00       	mov    $0x8023a0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801005:	eb 13                	jmp    80101a <dev_lookup+0x23>
  801007:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80100a:	39 08                	cmp    %ecx,(%eax)
  80100c:	75 0c                	jne    80101a <dev_lookup+0x23>
			*dev = devtab[i];
  80100e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801011:	89 01                	mov    %eax,(%ecx)
			return 0;
  801013:	b8 00 00 00 00       	mov    $0x0,%eax
  801018:	eb 2e                	jmp    801048 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80101a:	8b 02                	mov    (%edx),%eax
  80101c:	85 c0                	test   %eax,%eax
  80101e:	75 e7                	jne    801007 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801020:	a1 08 40 80 00       	mov    0x804008,%eax
  801025:	8b 40 48             	mov    0x48(%eax),%eax
  801028:	83 ec 04             	sub    $0x4,%esp
  80102b:	51                   	push   %ecx
  80102c:	50                   	push   %eax
  80102d:	68 24 23 80 00       	push   $0x802324
  801032:	e8 5d f1 ff ff       	call   800194 <cprintf>
	*dev = 0;
  801037:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801048:	c9                   	leave  
  801049:	c3                   	ret    

0080104a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	56                   	push   %esi
  80104e:	53                   	push   %ebx
  80104f:	83 ec 10             	sub    $0x10,%esp
  801052:	8b 75 08             	mov    0x8(%ebp),%esi
  801055:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801058:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80105b:	50                   	push   %eax
  80105c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801062:	c1 e8 0c             	shr    $0xc,%eax
  801065:	50                   	push   %eax
  801066:	e8 36 ff ff ff       	call   800fa1 <fd_lookup>
  80106b:	83 c4 08             	add    $0x8,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	78 05                	js     801077 <fd_close+0x2d>
	    || fd != fd2) 
  801072:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801075:	74 0c                	je     801083 <fd_close+0x39>
		return (must_exist ? r : 0); 
  801077:	84 db                	test   %bl,%bl
  801079:	ba 00 00 00 00       	mov    $0x0,%edx
  80107e:	0f 44 c2             	cmove  %edx,%eax
  801081:	eb 41                	jmp    8010c4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801083:	83 ec 08             	sub    $0x8,%esp
  801086:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801089:	50                   	push   %eax
  80108a:	ff 36                	pushl  (%esi)
  80108c:	e8 66 ff ff ff       	call   800ff7 <dev_lookup>
  801091:	89 c3                	mov    %eax,%ebx
  801093:	83 c4 10             	add    $0x10,%esp
  801096:	85 c0                	test   %eax,%eax
  801098:	78 1a                	js     8010b4 <fd_close+0x6a>
		if (dev->dev_close) 
  80109a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80109d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8010a0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8010a5:	85 c0                	test   %eax,%eax
  8010a7:	74 0b                	je     8010b4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010a9:	83 ec 0c             	sub    $0xc,%esp
  8010ac:	56                   	push   %esi
  8010ad:	ff d0                	call   *%eax
  8010af:	89 c3                	mov    %eax,%ebx
  8010b1:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010b4:	83 ec 08             	sub    $0x8,%esp
  8010b7:	56                   	push   %esi
  8010b8:	6a 00                	push   $0x0
  8010ba:	e8 08 fc ff ff       	call   800cc7 <sys_page_unmap>
	return r;
  8010bf:	83 c4 10             	add    $0x10,%esp
  8010c2:	89 d8                	mov    %ebx,%eax
}
  8010c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010c7:	5b                   	pop    %ebx
  8010c8:	5e                   	pop    %esi
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    

008010cb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d4:	50                   	push   %eax
  8010d5:	ff 75 08             	pushl  0x8(%ebp)
  8010d8:	e8 c4 fe ff ff       	call   800fa1 <fd_lookup>
  8010dd:	83 c4 08             	add    $0x8,%esp
  8010e0:	85 c0                	test   %eax,%eax
  8010e2:	78 10                	js     8010f4 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  8010e4:	83 ec 08             	sub    $0x8,%esp
  8010e7:	6a 01                	push   $0x1
  8010e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8010ec:	e8 59 ff ff ff       	call   80104a <fd_close>
  8010f1:	83 c4 10             	add    $0x10,%esp
}
  8010f4:	c9                   	leave  
  8010f5:	c3                   	ret    

008010f6 <close_all>:

void
close_all(void)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	53                   	push   %ebx
  8010fa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010fd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801102:	83 ec 0c             	sub    $0xc,%esp
  801105:	53                   	push   %ebx
  801106:	e8 c0 ff ff ff       	call   8010cb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80110b:	83 c3 01             	add    $0x1,%ebx
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	83 fb 20             	cmp    $0x20,%ebx
  801114:	75 ec                	jne    801102 <close_all+0xc>
		close(i);
}
  801116:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801119:	c9                   	leave  
  80111a:	c3                   	ret    

0080111b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	57                   	push   %edi
  80111f:	56                   	push   %esi
  801120:	53                   	push   %ebx
  801121:	83 ec 2c             	sub    $0x2c,%esp
  801124:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801127:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80112a:	50                   	push   %eax
  80112b:	ff 75 08             	pushl  0x8(%ebp)
  80112e:	e8 6e fe ff ff       	call   800fa1 <fd_lookup>
  801133:	83 c4 08             	add    $0x8,%esp
  801136:	85 c0                	test   %eax,%eax
  801138:	0f 88 c1 00 00 00    	js     8011ff <dup+0xe4>
		return r;
	close(newfdnum);
  80113e:	83 ec 0c             	sub    $0xc,%esp
  801141:	56                   	push   %esi
  801142:	e8 84 ff ff ff       	call   8010cb <close>

	newfd = INDEX2FD(newfdnum);
  801147:	89 f3                	mov    %esi,%ebx
  801149:	c1 e3 0c             	shl    $0xc,%ebx
  80114c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801152:	83 c4 04             	add    $0x4,%esp
  801155:	ff 75 e4             	pushl  -0x1c(%ebp)
  801158:	e8 de fd ff ff       	call   800f3b <fd2data>
  80115d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80115f:	89 1c 24             	mov    %ebx,(%esp)
  801162:	e8 d4 fd ff ff       	call   800f3b <fd2data>
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80116d:	89 f8                	mov    %edi,%eax
  80116f:	c1 e8 16             	shr    $0x16,%eax
  801172:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801179:	a8 01                	test   $0x1,%al
  80117b:	74 37                	je     8011b4 <dup+0x99>
  80117d:	89 f8                	mov    %edi,%eax
  80117f:	c1 e8 0c             	shr    $0xc,%eax
  801182:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801189:	f6 c2 01             	test   $0x1,%dl
  80118c:	74 26                	je     8011b4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80118e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801195:	83 ec 0c             	sub    $0xc,%esp
  801198:	25 07 0e 00 00       	and    $0xe07,%eax
  80119d:	50                   	push   %eax
  80119e:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011a1:	6a 00                	push   $0x0
  8011a3:	57                   	push   %edi
  8011a4:	6a 00                	push   $0x0
  8011a6:	e8 da fa ff ff       	call   800c85 <sys_page_map>
  8011ab:	89 c7                	mov    %eax,%edi
  8011ad:	83 c4 20             	add    $0x20,%esp
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	78 2e                	js     8011e2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011b7:	89 d0                	mov    %edx,%eax
  8011b9:	c1 e8 0c             	shr    $0xc,%eax
  8011bc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011c3:	83 ec 0c             	sub    $0xc,%esp
  8011c6:	25 07 0e 00 00       	and    $0xe07,%eax
  8011cb:	50                   	push   %eax
  8011cc:	53                   	push   %ebx
  8011cd:	6a 00                	push   $0x0
  8011cf:	52                   	push   %edx
  8011d0:	6a 00                	push   $0x0
  8011d2:	e8 ae fa ff ff       	call   800c85 <sys_page_map>
  8011d7:	89 c7                	mov    %eax,%edi
  8011d9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011dc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011de:	85 ff                	test   %edi,%edi
  8011e0:	79 1d                	jns    8011ff <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011e2:	83 ec 08             	sub    $0x8,%esp
  8011e5:	53                   	push   %ebx
  8011e6:	6a 00                	push   $0x0
  8011e8:	e8 da fa ff ff       	call   800cc7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011ed:	83 c4 08             	add    $0x8,%esp
  8011f0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011f3:	6a 00                	push   $0x0
  8011f5:	e8 cd fa ff ff       	call   800cc7 <sys_page_unmap>
	return r;
  8011fa:	83 c4 10             	add    $0x10,%esp
  8011fd:	89 f8                	mov    %edi,%eax
}
  8011ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801202:	5b                   	pop    %ebx
  801203:	5e                   	pop    %esi
  801204:	5f                   	pop    %edi
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	53                   	push   %ebx
  80120b:	83 ec 14             	sub    $0x14,%esp
  80120e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801211:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801214:	50                   	push   %eax
  801215:	53                   	push   %ebx
  801216:	e8 86 fd ff ff       	call   800fa1 <fd_lookup>
  80121b:	83 c4 08             	add    $0x8,%esp
  80121e:	89 c2                	mov    %eax,%edx
  801220:	85 c0                	test   %eax,%eax
  801222:	78 6d                	js     801291 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801224:	83 ec 08             	sub    $0x8,%esp
  801227:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122a:	50                   	push   %eax
  80122b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122e:	ff 30                	pushl  (%eax)
  801230:	e8 c2 fd ff ff       	call   800ff7 <dev_lookup>
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	85 c0                	test   %eax,%eax
  80123a:	78 4c                	js     801288 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80123c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80123f:	8b 42 08             	mov    0x8(%edx),%eax
  801242:	83 e0 03             	and    $0x3,%eax
  801245:	83 f8 01             	cmp    $0x1,%eax
  801248:	75 21                	jne    80126b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80124a:	a1 08 40 80 00       	mov    0x804008,%eax
  80124f:	8b 40 48             	mov    0x48(%eax),%eax
  801252:	83 ec 04             	sub    $0x4,%esp
  801255:	53                   	push   %ebx
  801256:	50                   	push   %eax
  801257:	68 65 23 80 00       	push   $0x802365
  80125c:	e8 33 ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801269:	eb 26                	jmp    801291 <read+0x8a>
	}
	if (!dev->dev_read)
  80126b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80126e:	8b 40 08             	mov    0x8(%eax),%eax
  801271:	85 c0                	test   %eax,%eax
  801273:	74 17                	je     80128c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801275:	83 ec 04             	sub    $0x4,%esp
  801278:	ff 75 10             	pushl  0x10(%ebp)
  80127b:	ff 75 0c             	pushl  0xc(%ebp)
  80127e:	52                   	push   %edx
  80127f:	ff d0                	call   *%eax
  801281:	89 c2                	mov    %eax,%edx
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	eb 09                	jmp    801291 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801288:	89 c2                	mov    %eax,%edx
  80128a:	eb 05                	jmp    801291 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80128c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801291:	89 d0                	mov    %edx,%eax
  801293:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801296:	c9                   	leave  
  801297:	c3                   	ret    

00801298 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	57                   	push   %edi
  80129c:	56                   	push   %esi
  80129d:	53                   	push   %ebx
  80129e:	83 ec 0c             	sub    $0xc,%esp
  8012a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012a4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ac:	eb 21                	jmp    8012cf <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012ae:	83 ec 04             	sub    $0x4,%esp
  8012b1:	89 f0                	mov    %esi,%eax
  8012b3:	29 d8                	sub    %ebx,%eax
  8012b5:	50                   	push   %eax
  8012b6:	89 d8                	mov    %ebx,%eax
  8012b8:	03 45 0c             	add    0xc(%ebp),%eax
  8012bb:	50                   	push   %eax
  8012bc:	57                   	push   %edi
  8012bd:	e8 45 ff ff ff       	call   801207 <read>
		if (m < 0)
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	78 10                	js     8012d9 <readn+0x41>
			return m;
		if (m == 0)
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	74 0a                	je     8012d7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012cd:	01 c3                	add    %eax,%ebx
  8012cf:	39 f3                	cmp    %esi,%ebx
  8012d1:	72 db                	jb     8012ae <readn+0x16>
  8012d3:	89 d8                	mov    %ebx,%eax
  8012d5:	eb 02                	jmp    8012d9 <readn+0x41>
  8012d7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012dc:	5b                   	pop    %ebx
  8012dd:	5e                   	pop    %esi
  8012de:	5f                   	pop    %edi
  8012df:	5d                   	pop    %ebp
  8012e0:	c3                   	ret    

008012e1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	53                   	push   %ebx
  8012e5:	83 ec 14             	sub    $0x14,%esp
  8012e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ee:	50                   	push   %eax
  8012ef:	53                   	push   %ebx
  8012f0:	e8 ac fc ff ff       	call   800fa1 <fd_lookup>
  8012f5:	83 c4 08             	add    $0x8,%esp
  8012f8:	89 c2                	mov    %eax,%edx
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 68                	js     801366 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012fe:	83 ec 08             	sub    $0x8,%esp
  801301:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801304:	50                   	push   %eax
  801305:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801308:	ff 30                	pushl  (%eax)
  80130a:	e8 e8 fc ff ff       	call   800ff7 <dev_lookup>
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	85 c0                	test   %eax,%eax
  801314:	78 47                	js     80135d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801316:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801319:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80131d:	75 21                	jne    801340 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80131f:	a1 08 40 80 00       	mov    0x804008,%eax
  801324:	8b 40 48             	mov    0x48(%eax),%eax
  801327:	83 ec 04             	sub    $0x4,%esp
  80132a:	53                   	push   %ebx
  80132b:	50                   	push   %eax
  80132c:	68 81 23 80 00       	push   $0x802381
  801331:	e8 5e ee ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80133e:	eb 26                	jmp    801366 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801340:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801343:	8b 52 0c             	mov    0xc(%edx),%edx
  801346:	85 d2                	test   %edx,%edx
  801348:	74 17                	je     801361 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80134a:	83 ec 04             	sub    $0x4,%esp
  80134d:	ff 75 10             	pushl  0x10(%ebp)
  801350:	ff 75 0c             	pushl  0xc(%ebp)
  801353:	50                   	push   %eax
  801354:	ff d2                	call   *%edx
  801356:	89 c2                	mov    %eax,%edx
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	eb 09                	jmp    801366 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135d:	89 c2                	mov    %eax,%edx
  80135f:	eb 05                	jmp    801366 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801361:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801366:	89 d0                	mov    %edx,%eax
  801368:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136b:	c9                   	leave  
  80136c:	c3                   	ret    

0080136d <seek>:

int
seek(int fdnum, off_t offset)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801373:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801376:	50                   	push   %eax
  801377:	ff 75 08             	pushl  0x8(%ebp)
  80137a:	e8 22 fc ff ff       	call   800fa1 <fd_lookup>
  80137f:	83 c4 08             	add    $0x8,%esp
  801382:	85 c0                	test   %eax,%eax
  801384:	78 0e                	js     801394 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801386:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801389:	8b 55 0c             	mov    0xc(%ebp),%edx
  80138c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80138f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801394:	c9                   	leave  
  801395:	c3                   	ret    

00801396 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
  801399:	53                   	push   %ebx
  80139a:	83 ec 14             	sub    $0x14,%esp
  80139d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a3:	50                   	push   %eax
  8013a4:	53                   	push   %ebx
  8013a5:	e8 f7 fb ff ff       	call   800fa1 <fd_lookup>
  8013aa:	83 c4 08             	add    $0x8,%esp
  8013ad:	89 c2                	mov    %eax,%edx
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	78 65                	js     801418 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b9:	50                   	push   %eax
  8013ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013bd:	ff 30                	pushl  (%eax)
  8013bf:	e8 33 fc ff ff       	call   800ff7 <dev_lookup>
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	78 44                	js     80140f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ce:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013d2:	75 21                	jne    8013f5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013d4:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013d9:	8b 40 48             	mov    0x48(%eax),%eax
  8013dc:	83 ec 04             	sub    $0x4,%esp
  8013df:	53                   	push   %ebx
  8013e0:	50                   	push   %eax
  8013e1:	68 44 23 80 00       	push   $0x802344
  8013e6:	e8 a9 ed ff ff       	call   800194 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013f3:	eb 23                	jmp    801418 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013f8:	8b 52 18             	mov    0x18(%edx),%edx
  8013fb:	85 d2                	test   %edx,%edx
  8013fd:	74 14                	je     801413 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013ff:	83 ec 08             	sub    $0x8,%esp
  801402:	ff 75 0c             	pushl  0xc(%ebp)
  801405:	50                   	push   %eax
  801406:	ff d2                	call   *%edx
  801408:	89 c2                	mov    %eax,%edx
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	eb 09                	jmp    801418 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140f:	89 c2                	mov    %eax,%edx
  801411:	eb 05                	jmp    801418 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801413:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801418:	89 d0                	mov    %edx,%eax
  80141a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141d:	c9                   	leave  
  80141e:	c3                   	ret    

0080141f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	53                   	push   %ebx
  801423:	83 ec 14             	sub    $0x14,%esp
  801426:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801429:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142c:	50                   	push   %eax
  80142d:	ff 75 08             	pushl  0x8(%ebp)
  801430:	e8 6c fb ff ff       	call   800fa1 <fd_lookup>
  801435:	83 c4 08             	add    $0x8,%esp
  801438:	89 c2                	mov    %eax,%edx
  80143a:	85 c0                	test   %eax,%eax
  80143c:	78 58                	js     801496 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143e:	83 ec 08             	sub    $0x8,%esp
  801441:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801444:	50                   	push   %eax
  801445:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801448:	ff 30                	pushl  (%eax)
  80144a:	e8 a8 fb ff ff       	call   800ff7 <dev_lookup>
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	85 c0                	test   %eax,%eax
  801454:	78 37                	js     80148d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801456:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801459:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80145d:	74 32                	je     801491 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80145f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801462:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801469:	00 00 00 
	stat->st_isdir = 0;
  80146c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801473:	00 00 00 
	stat->st_dev = dev;
  801476:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80147c:	83 ec 08             	sub    $0x8,%esp
  80147f:	53                   	push   %ebx
  801480:	ff 75 f0             	pushl  -0x10(%ebp)
  801483:	ff 50 14             	call   *0x14(%eax)
  801486:	89 c2                	mov    %eax,%edx
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	eb 09                	jmp    801496 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148d:	89 c2                	mov    %eax,%edx
  80148f:	eb 05                	jmp    801496 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801491:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801496:	89 d0                	mov    %edx,%eax
  801498:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149b:	c9                   	leave  
  80149c:	c3                   	ret    

0080149d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	56                   	push   %esi
  8014a1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014a2:	83 ec 08             	sub    $0x8,%esp
  8014a5:	6a 00                	push   $0x0
  8014a7:	ff 75 08             	pushl  0x8(%ebp)
  8014aa:	e8 2b 02 00 00       	call   8016da <open>
  8014af:	89 c3                	mov    %eax,%ebx
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 1b                	js     8014d3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014b8:	83 ec 08             	sub    $0x8,%esp
  8014bb:	ff 75 0c             	pushl  0xc(%ebp)
  8014be:	50                   	push   %eax
  8014bf:	e8 5b ff ff ff       	call   80141f <fstat>
  8014c4:	89 c6                	mov    %eax,%esi
	close(fd);
  8014c6:	89 1c 24             	mov    %ebx,(%esp)
  8014c9:	e8 fd fb ff ff       	call   8010cb <close>
	return r;
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	89 f0                	mov    %esi,%eax
}
  8014d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d6:	5b                   	pop    %ebx
  8014d7:	5e                   	pop    %esi
  8014d8:	5d                   	pop    %ebp
  8014d9:	c3                   	ret    

008014da <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	56                   	push   %esi
  8014de:	53                   	push   %ebx
  8014df:	89 c6                	mov    %eax,%esi
  8014e1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014e3:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8014ea:	75 12                	jne    8014fe <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014ec:	83 ec 0c             	sub    $0xc,%esp
  8014ef:	6a 01                	push   $0x1
  8014f1:	e8 fc f9 ff ff       	call   800ef2 <ipc_find_env>
  8014f6:	a3 04 40 80 00       	mov    %eax,0x804004
  8014fb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014fe:	6a 07                	push   $0x7
  801500:	68 00 50 80 00       	push   $0x805000
  801505:	56                   	push   %esi
  801506:	ff 35 04 40 80 00    	pushl  0x804004
  80150c:	e8 8b f9 ff ff       	call   800e9c <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801511:	83 c4 0c             	add    $0xc,%esp
  801514:	6a 00                	push   $0x0
  801516:	53                   	push   %ebx
  801517:	6a 00                	push   $0x0
  801519:	e8 15 f9 ff ff       	call   800e33 <ipc_recv>
}
  80151e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801521:	5b                   	pop    %ebx
  801522:	5e                   	pop    %esi
  801523:	5d                   	pop    %ebp
  801524:	c3                   	ret    

00801525 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801525:	55                   	push   %ebp
  801526:	89 e5                	mov    %esp,%ebp
  801528:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80152b:	8b 45 08             	mov    0x8(%ebp),%eax
  80152e:	8b 40 0c             	mov    0xc(%eax),%eax
  801531:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801536:	8b 45 0c             	mov    0xc(%ebp),%eax
  801539:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80153e:	ba 00 00 00 00       	mov    $0x0,%edx
  801543:	b8 02 00 00 00       	mov    $0x2,%eax
  801548:	e8 8d ff ff ff       	call   8014da <fsipc>
}
  80154d:	c9                   	leave  
  80154e:	c3                   	ret    

0080154f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801555:	8b 45 08             	mov    0x8(%ebp),%eax
  801558:	8b 40 0c             	mov    0xc(%eax),%eax
  80155b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801560:	ba 00 00 00 00       	mov    $0x0,%edx
  801565:	b8 06 00 00 00       	mov    $0x6,%eax
  80156a:	e8 6b ff ff ff       	call   8014da <fsipc>
}
  80156f:	c9                   	leave  
  801570:	c3                   	ret    

00801571 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	53                   	push   %ebx
  801575:	83 ec 04             	sub    $0x4,%esp
  801578:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80157b:	8b 45 08             	mov    0x8(%ebp),%eax
  80157e:	8b 40 0c             	mov    0xc(%eax),%eax
  801581:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801586:	ba 00 00 00 00       	mov    $0x0,%edx
  80158b:	b8 05 00 00 00       	mov    $0x5,%eax
  801590:	e8 45 ff ff ff       	call   8014da <fsipc>
  801595:	85 c0                	test   %eax,%eax
  801597:	78 2c                	js     8015c5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	68 00 50 80 00       	push   $0x805000
  8015a1:	53                   	push   %ebx
  8015a2:	e8 21 f2 ff ff       	call   8007c8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015a7:	a1 80 50 80 00       	mov    0x805080,%eax
  8015ac:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015b2:	a1 84 50 80 00       	mov    0x805084,%eax
  8015b7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c8:	c9                   	leave  
  8015c9:	c3                   	ret    

008015ca <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	53                   	push   %ebx
  8015ce:	83 ec 08             	sub    $0x8,%esp
  8015d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8015d4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015d9:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8015de:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8015e7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  8015ec:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015f2:	53                   	push   %ebx
  8015f3:	ff 75 0c             	pushl  0xc(%ebp)
  8015f6:	68 08 50 80 00       	push   $0x805008
  8015fb:	e8 5a f3 ff ff       	call   80095a <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801600:	ba 00 00 00 00       	mov    $0x0,%edx
  801605:	b8 04 00 00 00       	mov    $0x4,%eax
  80160a:	e8 cb fe ff ff       	call   8014da <fsipc>
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	85 c0                	test   %eax,%eax
  801614:	78 3d                	js     801653 <devfile_write+0x89>
		return r;

	assert(r <= n);
  801616:	39 d8                	cmp    %ebx,%eax
  801618:	76 19                	jbe    801633 <devfile_write+0x69>
  80161a:	68 b0 23 80 00       	push   $0x8023b0
  80161f:	68 b7 23 80 00       	push   $0x8023b7
  801624:	68 9f 00 00 00       	push   $0x9f
  801629:	68 cc 23 80 00       	push   $0x8023cc
  80162e:	e8 2a 06 00 00       	call   801c5d <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801633:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801638:	76 19                	jbe    801653 <devfile_write+0x89>
  80163a:	68 e4 23 80 00       	push   $0x8023e4
  80163f:	68 b7 23 80 00       	push   $0x8023b7
  801644:	68 a0 00 00 00       	push   $0xa0
  801649:	68 cc 23 80 00       	push   $0x8023cc
  80164e:	e8 0a 06 00 00       	call   801c5d <_panic>

	return r;
}
  801653:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801656:	c9                   	leave  
  801657:	c3                   	ret    

00801658 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	56                   	push   %esi
  80165c:	53                   	push   %ebx
  80165d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801660:	8b 45 08             	mov    0x8(%ebp),%eax
  801663:	8b 40 0c             	mov    0xc(%eax),%eax
  801666:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80166b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801671:	ba 00 00 00 00       	mov    $0x0,%edx
  801676:	b8 03 00 00 00       	mov    $0x3,%eax
  80167b:	e8 5a fe ff ff       	call   8014da <fsipc>
  801680:	89 c3                	mov    %eax,%ebx
  801682:	85 c0                	test   %eax,%eax
  801684:	78 4b                	js     8016d1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801686:	39 c6                	cmp    %eax,%esi
  801688:	73 16                	jae    8016a0 <devfile_read+0x48>
  80168a:	68 b0 23 80 00       	push   $0x8023b0
  80168f:	68 b7 23 80 00       	push   $0x8023b7
  801694:	6a 7e                	push   $0x7e
  801696:	68 cc 23 80 00       	push   $0x8023cc
  80169b:	e8 bd 05 00 00       	call   801c5d <_panic>
	assert(r <= PGSIZE);
  8016a0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016a5:	7e 16                	jle    8016bd <devfile_read+0x65>
  8016a7:	68 d7 23 80 00       	push   $0x8023d7
  8016ac:	68 b7 23 80 00       	push   $0x8023b7
  8016b1:	6a 7f                	push   $0x7f
  8016b3:	68 cc 23 80 00       	push   $0x8023cc
  8016b8:	e8 a0 05 00 00       	call   801c5d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016bd:	83 ec 04             	sub    $0x4,%esp
  8016c0:	50                   	push   %eax
  8016c1:	68 00 50 80 00       	push   $0x805000
  8016c6:	ff 75 0c             	pushl  0xc(%ebp)
  8016c9:	e8 8c f2 ff ff       	call   80095a <memmove>
	return r;
  8016ce:	83 c4 10             	add    $0x10,%esp
}
  8016d1:	89 d8                	mov    %ebx,%eax
  8016d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d6:	5b                   	pop    %ebx
  8016d7:	5e                   	pop    %esi
  8016d8:	5d                   	pop    %ebp
  8016d9:	c3                   	ret    

008016da <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	53                   	push   %ebx
  8016de:	83 ec 20             	sub    $0x20,%esp
  8016e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016e4:	53                   	push   %ebx
  8016e5:	e8 a5 f0 ff ff       	call   80078f <strlen>
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016f2:	7f 67                	jg     80175b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016f4:	83 ec 0c             	sub    $0xc,%esp
  8016f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fa:	50                   	push   %eax
  8016fb:	e8 52 f8 ff ff       	call   800f52 <fd_alloc>
  801700:	83 c4 10             	add    $0x10,%esp
		return r;
  801703:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801705:	85 c0                	test   %eax,%eax
  801707:	78 57                	js     801760 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801709:	83 ec 08             	sub    $0x8,%esp
  80170c:	53                   	push   %ebx
  80170d:	68 00 50 80 00       	push   $0x805000
  801712:	e8 b1 f0 ff ff       	call   8007c8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801717:	8b 45 0c             	mov    0xc(%ebp),%eax
  80171a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80171f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801722:	b8 01 00 00 00       	mov    $0x1,%eax
  801727:	e8 ae fd ff ff       	call   8014da <fsipc>
  80172c:	89 c3                	mov    %eax,%ebx
  80172e:	83 c4 10             	add    $0x10,%esp
  801731:	85 c0                	test   %eax,%eax
  801733:	79 14                	jns    801749 <open+0x6f>
		fd_close(fd, 0);
  801735:	83 ec 08             	sub    $0x8,%esp
  801738:	6a 00                	push   $0x0
  80173a:	ff 75 f4             	pushl  -0xc(%ebp)
  80173d:	e8 08 f9 ff ff       	call   80104a <fd_close>
		return r;
  801742:	83 c4 10             	add    $0x10,%esp
  801745:	89 da                	mov    %ebx,%edx
  801747:	eb 17                	jmp    801760 <open+0x86>
	}

	return fd2num(fd);
  801749:	83 ec 0c             	sub    $0xc,%esp
  80174c:	ff 75 f4             	pushl  -0xc(%ebp)
  80174f:	e8 d7 f7 ff ff       	call   800f2b <fd2num>
  801754:	89 c2                	mov    %eax,%edx
  801756:	83 c4 10             	add    $0x10,%esp
  801759:	eb 05                	jmp    801760 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80175b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801760:	89 d0                	mov    %edx,%eax
  801762:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801765:	c9                   	leave  
  801766:	c3                   	ret    

00801767 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80176d:	ba 00 00 00 00       	mov    $0x0,%edx
  801772:	b8 08 00 00 00       	mov    $0x8,%eax
  801777:	e8 5e fd ff ff       	call   8014da <fsipc>
}
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    

0080177e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	56                   	push   %esi
  801782:	53                   	push   %ebx
  801783:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801786:	83 ec 0c             	sub    $0xc,%esp
  801789:	ff 75 08             	pushl  0x8(%ebp)
  80178c:	e8 aa f7 ff ff       	call   800f3b <fd2data>
  801791:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801793:	83 c4 08             	add    $0x8,%esp
  801796:	68 11 24 80 00       	push   $0x802411
  80179b:	53                   	push   %ebx
  80179c:	e8 27 f0 ff ff       	call   8007c8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017a1:	8b 46 04             	mov    0x4(%esi),%eax
  8017a4:	2b 06                	sub    (%esi),%eax
  8017a6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017ac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b3:	00 00 00 
	stat->st_dev = &devpipe;
  8017b6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8017bd:	30 80 00 
	return 0;
}
  8017c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c8:	5b                   	pop    %ebx
  8017c9:	5e                   	pop    %esi
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	53                   	push   %ebx
  8017d0:	83 ec 0c             	sub    $0xc,%esp
  8017d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017d6:	53                   	push   %ebx
  8017d7:	6a 00                	push   $0x0
  8017d9:	e8 e9 f4 ff ff       	call   800cc7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017de:	89 1c 24             	mov    %ebx,(%esp)
  8017e1:	e8 55 f7 ff ff       	call   800f3b <fd2data>
  8017e6:	83 c4 08             	add    $0x8,%esp
  8017e9:	50                   	push   %eax
  8017ea:	6a 00                	push   $0x0
  8017ec:	e8 d6 f4 ff ff       	call   800cc7 <sys_page_unmap>
}
  8017f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f4:	c9                   	leave  
  8017f5:	c3                   	ret    

008017f6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	57                   	push   %edi
  8017fa:	56                   	push   %esi
  8017fb:	53                   	push   %ebx
  8017fc:	83 ec 1c             	sub    $0x1c,%esp
  8017ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801802:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801804:	a1 08 40 80 00       	mov    0x804008,%eax
  801809:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80180c:	83 ec 0c             	sub    $0xc,%esp
  80180f:	ff 75 e0             	pushl  -0x20(%ebp)
  801812:	e8 8c 04 00 00       	call   801ca3 <pageref>
  801817:	89 c3                	mov    %eax,%ebx
  801819:	89 3c 24             	mov    %edi,(%esp)
  80181c:	e8 82 04 00 00       	call   801ca3 <pageref>
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	39 c3                	cmp    %eax,%ebx
  801826:	0f 94 c1             	sete   %cl
  801829:	0f b6 c9             	movzbl %cl,%ecx
  80182c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80182f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801835:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801838:	39 ce                	cmp    %ecx,%esi
  80183a:	74 1b                	je     801857 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80183c:	39 c3                	cmp    %eax,%ebx
  80183e:	75 c4                	jne    801804 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801840:	8b 42 58             	mov    0x58(%edx),%eax
  801843:	ff 75 e4             	pushl  -0x1c(%ebp)
  801846:	50                   	push   %eax
  801847:	56                   	push   %esi
  801848:	68 18 24 80 00       	push   $0x802418
  80184d:	e8 42 e9 ff ff       	call   800194 <cprintf>
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	eb ad                	jmp    801804 <_pipeisclosed+0xe>
	}
}
  801857:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80185a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80185d:	5b                   	pop    %ebx
  80185e:	5e                   	pop    %esi
  80185f:	5f                   	pop    %edi
  801860:	5d                   	pop    %ebp
  801861:	c3                   	ret    

00801862 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	57                   	push   %edi
  801866:	56                   	push   %esi
  801867:	53                   	push   %ebx
  801868:	83 ec 28             	sub    $0x28,%esp
  80186b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80186e:	56                   	push   %esi
  80186f:	e8 c7 f6 ff ff       	call   800f3b <fd2data>
  801874:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801876:	83 c4 10             	add    $0x10,%esp
  801879:	bf 00 00 00 00       	mov    $0x0,%edi
  80187e:	eb 4b                	jmp    8018cb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801880:	89 da                	mov    %ebx,%edx
  801882:	89 f0                	mov    %esi,%eax
  801884:	e8 6d ff ff ff       	call   8017f6 <_pipeisclosed>
  801889:	85 c0                	test   %eax,%eax
  80188b:	75 48                	jne    8018d5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80188d:	e8 91 f3 ff ff       	call   800c23 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801892:	8b 43 04             	mov    0x4(%ebx),%eax
  801895:	8b 0b                	mov    (%ebx),%ecx
  801897:	8d 51 20             	lea    0x20(%ecx),%edx
  80189a:	39 d0                	cmp    %edx,%eax
  80189c:	73 e2                	jae    801880 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80189e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018a1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018a5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018a8:	89 c2                	mov    %eax,%edx
  8018aa:	c1 fa 1f             	sar    $0x1f,%edx
  8018ad:	89 d1                	mov    %edx,%ecx
  8018af:	c1 e9 1b             	shr    $0x1b,%ecx
  8018b2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8018b5:	83 e2 1f             	and    $0x1f,%edx
  8018b8:	29 ca                	sub    %ecx,%edx
  8018ba:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8018be:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018c2:	83 c0 01             	add    $0x1,%eax
  8018c5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018c8:	83 c7 01             	add    $0x1,%edi
  8018cb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018ce:	75 c2                	jne    801892 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8018d3:	eb 05                	jmp    8018da <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018d5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018dd:	5b                   	pop    %ebx
  8018de:	5e                   	pop    %esi
  8018df:	5f                   	pop    %edi
  8018e0:	5d                   	pop    %ebp
  8018e1:	c3                   	ret    

008018e2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	57                   	push   %edi
  8018e6:	56                   	push   %esi
  8018e7:	53                   	push   %ebx
  8018e8:	83 ec 18             	sub    $0x18,%esp
  8018eb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018ee:	57                   	push   %edi
  8018ef:	e8 47 f6 ff ff       	call   800f3b <fd2data>
  8018f4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018f6:	83 c4 10             	add    $0x10,%esp
  8018f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018fe:	eb 3d                	jmp    80193d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801900:	85 db                	test   %ebx,%ebx
  801902:	74 04                	je     801908 <devpipe_read+0x26>
				return i;
  801904:	89 d8                	mov    %ebx,%eax
  801906:	eb 44                	jmp    80194c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801908:	89 f2                	mov    %esi,%edx
  80190a:	89 f8                	mov    %edi,%eax
  80190c:	e8 e5 fe ff ff       	call   8017f6 <_pipeisclosed>
  801911:	85 c0                	test   %eax,%eax
  801913:	75 32                	jne    801947 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801915:	e8 09 f3 ff ff       	call   800c23 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80191a:	8b 06                	mov    (%esi),%eax
  80191c:	3b 46 04             	cmp    0x4(%esi),%eax
  80191f:	74 df                	je     801900 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801921:	99                   	cltd   
  801922:	c1 ea 1b             	shr    $0x1b,%edx
  801925:	01 d0                	add    %edx,%eax
  801927:	83 e0 1f             	and    $0x1f,%eax
  80192a:	29 d0                	sub    %edx,%eax
  80192c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801931:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801934:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801937:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80193a:	83 c3 01             	add    $0x1,%ebx
  80193d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801940:	75 d8                	jne    80191a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801942:	8b 45 10             	mov    0x10(%ebp),%eax
  801945:	eb 05                	jmp    80194c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801947:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80194c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80194f:	5b                   	pop    %ebx
  801950:	5e                   	pop    %esi
  801951:	5f                   	pop    %edi
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	56                   	push   %esi
  801958:	53                   	push   %ebx
  801959:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80195c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195f:	50                   	push   %eax
  801960:	e8 ed f5 ff ff       	call   800f52 <fd_alloc>
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	89 c2                	mov    %eax,%edx
  80196a:	85 c0                	test   %eax,%eax
  80196c:	0f 88 2c 01 00 00    	js     801a9e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801972:	83 ec 04             	sub    $0x4,%esp
  801975:	68 07 04 00 00       	push   $0x407
  80197a:	ff 75 f4             	pushl  -0xc(%ebp)
  80197d:	6a 00                	push   $0x0
  80197f:	e8 be f2 ff ff       	call   800c42 <sys_page_alloc>
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	89 c2                	mov    %eax,%edx
  801989:	85 c0                	test   %eax,%eax
  80198b:	0f 88 0d 01 00 00    	js     801a9e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801991:	83 ec 0c             	sub    $0xc,%esp
  801994:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801997:	50                   	push   %eax
  801998:	e8 b5 f5 ff ff       	call   800f52 <fd_alloc>
  80199d:	89 c3                	mov    %eax,%ebx
  80199f:	83 c4 10             	add    $0x10,%esp
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	0f 88 e2 00 00 00    	js     801a8c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019aa:	83 ec 04             	sub    $0x4,%esp
  8019ad:	68 07 04 00 00       	push   $0x407
  8019b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8019b5:	6a 00                	push   $0x0
  8019b7:	e8 86 f2 ff ff       	call   800c42 <sys_page_alloc>
  8019bc:	89 c3                	mov    %eax,%ebx
  8019be:	83 c4 10             	add    $0x10,%esp
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	0f 88 c3 00 00 00    	js     801a8c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019c9:	83 ec 0c             	sub    $0xc,%esp
  8019cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cf:	e8 67 f5 ff ff       	call   800f3b <fd2data>
  8019d4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019d6:	83 c4 0c             	add    $0xc,%esp
  8019d9:	68 07 04 00 00       	push   $0x407
  8019de:	50                   	push   %eax
  8019df:	6a 00                	push   $0x0
  8019e1:	e8 5c f2 ff ff       	call   800c42 <sys_page_alloc>
  8019e6:	89 c3                	mov    %eax,%ebx
  8019e8:	83 c4 10             	add    $0x10,%esp
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	0f 88 89 00 00 00    	js     801a7c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f3:	83 ec 0c             	sub    $0xc,%esp
  8019f6:	ff 75 f0             	pushl  -0x10(%ebp)
  8019f9:	e8 3d f5 ff ff       	call   800f3b <fd2data>
  8019fe:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a05:	50                   	push   %eax
  801a06:	6a 00                	push   $0x0
  801a08:	56                   	push   %esi
  801a09:	6a 00                	push   $0x0
  801a0b:	e8 75 f2 ff ff       	call   800c85 <sys_page_map>
  801a10:	89 c3                	mov    %eax,%ebx
  801a12:	83 c4 20             	add    $0x20,%esp
  801a15:	85 c0                	test   %eax,%eax
  801a17:	78 55                	js     801a6e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a19:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a22:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a27:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a2e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a34:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a37:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a3c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a43:	83 ec 0c             	sub    $0xc,%esp
  801a46:	ff 75 f4             	pushl  -0xc(%ebp)
  801a49:	e8 dd f4 ff ff       	call   800f2b <fd2num>
  801a4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a51:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a53:	83 c4 04             	add    $0x4,%esp
  801a56:	ff 75 f0             	pushl  -0x10(%ebp)
  801a59:	e8 cd f4 ff ff       	call   800f2b <fd2num>
  801a5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a61:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6c:	eb 30                	jmp    801a9e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a6e:	83 ec 08             	sub    $0x8,%esp
  801a71:	56                   	push   %esi
  801a72:	6a 00                	push   $0x0
  801a74:	e8 4e f2 ff ff       	call   800cc7 <sys_page_unmap>
  801a79:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a7c:	83 ec 08             	sub    $0x8,%esp
  801a7f:	ff 75 f0             	pushl  -0x10(%ebp)
  801a82:	6a 00                	push   $0x0
  801a84:	e8 3e f2 ff ff       	call   800cc7 <sys_page_unmap>
  801a89:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a8c:	83 ec 08             	sub    $0x8,%esp
  801a8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a92:	6a 00                	push   $0x0
  801a94:	e8 2e f2 ff ff       	call   800cc7 <sys_page_unmap>
  801a99:	83 c4 10             	add    $0x10,%esp
  801a9c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a9e:	89 d0                	mov    %edx,%eax
  801aa0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa3:	5b                   	pop    %ebx
  801aa4:	5e                   	pop    %esi
  801aa5:	5d                   	pop    %ebp
  801aa6:	c3                   	ret    

00801aa7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab0:	50                   	push   %eax
  801ab1:	ff 75 08             	pushl  0x8(%ebp)
  801ab4:	e8 e8 f4 ff ff       	call   800fa1 <fd_lookup>
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	85 c0                	test   %eax,%eax
  801abe:	78 18                	js     801ad8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ac0:	83 ec 0c             	sub    $0xc,%esp
  801ac3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac6:	e8 70 f4 ff ff       	call   800f3b <fd2data>
	return _pipeisclosed(fd, p);
  801acb:	89 c2                	mov    %eax,%edx
  801acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad0:	e8 21 fd ff ff       	call   8017f6 <_pipeisclosed>
  801ad5:	83 c4 10             	add    $0x10,%esp
}
  801ad8:	c9                   	leave  
  801ad9:	c3                   	ret    

00801ada <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801add:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae2:	5d                   	pop    %ebp
  801ae3:	c3                   	ret    

00801ae4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801aea:	68 30 24 80 00       	push   $0x802430
  801aef:	ff 75 0c             	pushl  0xc(%ebp)
  801af2:	e8 d1 ec ff ff       	call   8007c8 <strcpy>
	return 0;
}
  801af7:	b8 00 00 00 00       	mov    $0x0,%eax
  801afc:	c9                   	leave  
  801afd:	c3                   	ret    

00801afe <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	57                   	push   %edi
  801b02:	56                   	push   %esi
  801b03:	53                   	push   %ebx
  801b04:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b0a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b0f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b15:	eb 2d                	jmp    801b44 <devcons_write+0x46>
		m = n - tot;
  801b17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b1a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b1c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b1f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b24:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b27:	83 ec 04             	sub    $0x4,%esp
  801b2a:	53                   	push   %ebx
  801b2b:	03 45 0c             	add    0xc(%ebp),%eax
  801b2e:	50                   	push   %eax
  801b2f:	57                   	push   %edi
  801b30:	e8 25 ee ff ff       	call   80095a <memmove>
		sys_cputs(buf, m);
  801b35:	83 c4 08             	add    $0x8,%esp
  801b38:	53                   	push   %ebx
  801b39:	57                   	push   %edi
  801b3a:	e8 47 f0 ff ff       	call   800b86 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b3f:	01 de                	add    %ebx,%esi
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	89 f0                	mov    %esi,%eax
  801b46:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b49:	72 cc                	jb     801b17 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4e:	5b                   	pop    %ebx
  801b4f:	5e                   	pop    %esi
  801b50:	5f                   	pop    %edi
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	83 ec 08             	sub    $0x8,%esp
  801b59:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801b5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b62:	74 2a                	je     801b8e <devcons_read+0x3b>
  801b64:	eb 05                	jmp    801b6b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b66:	e8 b8 f0 ff ff       	call   800c23 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b6b:	e8 34 f0 ff ff       	call   800ba4 <sys_cgetc>
  801b70:	85 c0                	test   %eax,%eax
  801b72:	74 f2                	je     801b66 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b74:	85 c0                	test   %eax,%eax
  801b76:	78 16                	js     801b8e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b78:	83 f8 04             	cmp    $0x4,%eax
  801b7b:	74 0c                	je     801b89 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b80:	88 02                	mov    %al,(%edx)
	return 1;
  801b82:	b8 01 00 00 00       	mov    $0x1,%eax
  801b87:	eb 05                	jmp    801b8e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b8e:	c9                   	leave  
  801b8f:	c3                   	ret    

00801b90 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b96:	8b 45 08             	mov    0x8(%ebp),%eax
  801b99:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b9c:	6a 01                	push   $0x1
  801b9e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ba1:	50                   	push   %eax
  801ba2:	e8 df ef ff ff       	call   800b86 <sys_cputs>
}
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	c9                   	leave  
  801bab:	c3                   	ret    

00801bac <getchar>:

int
getchar(void)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801bb2:	6a 01                	push   $0x1
  801bb4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bb7:	50                   	push   %eax
  801bb8:	6a 00                	push   $0x0
  801bba:	e8 48 f6 ff ff       	call   801207 <read>
	if (r < 0)
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	78 0f                	js     801bd5 <getchar+0x29>
		return r;
	if (r < 1)
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	7e 06                	jle    801bd0 <getchar+0x24>
		return -E_EOF;
	return c;
  801bca:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801bce:	eb 05                	jmp    801bd5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801bd0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801bd5:	c9                   	leave  
  801bd6:	c3                   	ret    

00801bd7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bdd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be0:	50                   	push   %eax
  801be1:	ff 75 08             	pushl  0x8(%ebp)
  801be4:	e8 b8 f3 ff ff       	call   800fa1 <fd_lookup>
  801be9:	83 c4 10             	add    $0x10,%esp
  801bec:	85 c0                	test   %eax,%eax
  801bee:	78 11                	js     801c01 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bf9:	39 10                	cmp    %edx,(%eax)
  801bfb:	0f 94 c0             	sete   %al
  801bfe:	0f b6 c0             	movzbl %al,%eax
}
  801c01:	c9                   	leave  
  801c02:	c3                   	ret    

00801c03 <opencons>:

int
opencons(void)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0c:	50                   	push   %eax
  801c0d:	e8 40 f3 ff ff       	call   800f52 <fd_alloc>
  801c12:	83 c4 10             	add    $0x10,%esp
		return r;
  801c15:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c17:	85 c0                	test   %eax,%eax
  801c19:	78 3e                	js     801c59 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c1b:	83 ec 04             	sub    $0x4,%esp
  801c1e:	68 07 04 00 00       	push   $0x407
  801c23:	ff 75 f4             	pushl  -0xc(%ebp)
  801c26:	6a 00                	push   $0x0
  801c28:	e8 15 f0 ff ff       	call   800c42 <sys_page_alloc>
  801c2d:	83 c4 10             	add    $0x10,%esp
		return r;
  801c30:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c32:	85 c0                	test   %eax,%eax
  801c34:	78 23                	js     801c59 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c36:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c44:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c4b:	83 ec 0c             	sub    $0xc,%esp
  801c4e:	50                   	push   %eax
  801c4f:	e8 d7 f2 ff ff       	call   800f2b <fd2num>
  801c54:	89 c2                	mov    %eax,%edx
  801c56:	83 c4 10             	add    $0x10,%esp
}
  801c59:	89 d0                	mov    %edx,%eax
  801c5b:	c9                   	leave  
  801c5c:	c3                   	ret    

00801c5d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	56                   	push   %esi
  801c61:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801c62:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c65:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801c6b:	e8 94 ef ff ff       	call   800c04 <sys_getenvid>
  801c70:	83 ec 0c             	sub    $0xc,%esp
  801c73:	ff 75 0c             	pushl  0xc(%ebp)
  801c76:	ff 75 08             	pushl  0x8(%ebp)
  801c79:	56                   	push   %esi
  801c7a:	50                   	push   %eax
  801c7b:	68 3c 24 80 00       	push   $0x80243c
  801c80:	e8 0f e5 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801c85:	83 c4 18             	add    $0x18,%esp
  801c88:	53                   	push   %ebx
  801c89:	ff 75 10             	pushl  0x10(%ebp)
  801c8c:	e8 b2 e4 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  801c91:	c7 04 24 29 24 80 00 	movl   $0x802429,(%esp)
  801c98:	e8 f7 e4 ff ff       	call   800194 <cprintf>
  801c9d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ca0:	cc                   	int3   
  801ca1:	eb fd                	jmp    801ca0 <_panic+0x43>

00801ca3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ca9:	89 d0                	mov    %edx,%eax
  801cab:	c1 e8 16             	shr    $0x16,%eax
  801cae:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801cb5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cba:	f6 c1 01             	test   $0x1,%cl
  801cbd:	74 1d                	je     801cdc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cbf:	c1 ea 0c             	shr    $0xc,%edx
  801cc2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801cc9:	f6 c2 01             	test   $0x1,%dl
  801ccc:	74 0e                	je     801cdc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cce:	c1 ea 0c             	shr    $0xc,%edx
  801cd1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801cd8:	ef 
  801cd9:	0f b7 c0             	movzwl %ax,%eax
}
  801cdc:	5d                   	pop    %ebp
  801cdd:	c3                   	ret    
  801cde:	66 90                	xchg   %ax,%ax

00801ce0 <__udivdi3>:
  801ce0:	55                   	push   %ebp
  801ce1:	57                   	push   %edi
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 1c             	sub    $0x1c,%esp
  801ce7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ceb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801cef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801cf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cf7:	85 f6                	test   %esi,%esi
  801cf9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cfd:	89 ca                	mov    %ecx,%edx
  801cff:	89 f8                	mov    %edi,%eax
  801d01:	75 3d                	jne    801d40 <__udivdi3+0x60>
  801d03:	39 cf                	cmp    %ecx,%edi
  801d05:	0f 87 c5 00 00 00    	ja     801dd0 <__udivdi3+0xf0>
  801d0b:	85 ff                	test   %edi,%edi
  801d0d:	89 fd                	mov    %edi,%ebp
  801d0f:	75 0b                	jne    801d1c <__udivdi3+0x3c>
  801d11:	b8 01 00 00 00       	mov    $0x1,%eax
  801d16:	31 d2                	xor    %edx,%edx
  801d18:	f7 f7                	div    %edi
  801d1a:	89 c5                	mov    %eax,%ebp
  801d1c:	89 c8                	mov    %ecx,%eax
  801d1e:	31 d2                	xor    %edx,%edx
  801d20:	f7 f5                	div    %ebp
  801d22:	89 c1                	mov    %eax,%ecx
  801d24:	89 d8                	mov    %ebx,%eax
  801d26:	89 cf                	mov    %ecx,%edi
  801d28:	f7 f5                	div    %ebp
  801d2a:	89 c3                	mov    %eax,%ebx
  801d2c:	89 d8                	mov    %ebx,%eax
  801d2e:	89 fa                	mov    %edi,%edx
  801d30:	83 c4 1c             	add    $0x1c,%esp
  801d33:	5b                   	pop    %ebx
  801d34:	5e                   	pop    %esi
  801d35:	5f                   	pop    %edi
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    
  801d38:	90                   	nop
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	39 ce                	cmp    %ecx,%esi
  801d42:	77 74                	ja     801db8 <__udivdi3+0xd8>
  801d44:	0f bd fe             	bsr    %esi,%edi
  801d47:	83 f7 1f             	xor    $0x1f,%edi
  801d4a:	0f 84 98 00 00 00    	je     801de8 <__udivdi3+0x108>
  801d50:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d55:	89 f9                	mov    %edi,%ecx
  801d57:	89 c5                	mov    %eax,%ebp
  801d59:	29 fb                	sub    %edi,%ebx
  801d5b:	d3 e6                	shl    %cl,%esi
  801d5d:	89 d9                	mov    %ebx,%ecx
  801d5f:	d3 ed                	shr    %cl,%ebp
  801d61:	89 f9                	mov    %edi,%ecx
  801d63:	d3 e0                	shl    %cl,%eax
  801d65:	09 ee                	or     %ebp,%esi
  801d67:	89 d9                	mov    %ebx,%ecx
  801d69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d6d:	89 d5                	mov    %edx,%ebp
  801d6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d73:	d3 ed                	shr    %cl,%ebp
  801d75:	89 f9                	mov    %edi,%ecx
  801d77:	d3 e2                	shl    %cl,%edx
  801d79:	89 d9                	mov    %ebx,%ecx
  801d7b:	d3 e8                	shr    %cl,%eax
  801d7d:	09 c2                	or     %eax,%edx
  801d7f:	89 d0                	mov    %edx,%eax
  801d81:	89 ea                	mov    %ebp,%edx
  801d83:	f7 f6                	div    %esi
  801d85:	89 d5                	mov    %edx,%ebp
  801d87:	89 c3                	mov    %eax,%ebx
  801d89:	f7 64 24 0c          	mull   0xc(%esp)
  801d8d:	39 d5                	cmp    %edx,%ebp
  801d8f:	72 10                	jb     801da1 <__udivdi3+0xc1>
  801d91:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d95:	89 f9                	mov    %edi,%ecx
  801d97:	d3 e6                	shl    %cl,%esi
  801d99:	39 c6                	cmp    %eax,%esi
  801d9b:	73 07                	jae    801da4 <__udivdi3+0xc4>
  801d9d:	39 d5                	cmp    %edx,%ebp
  801d9f:	75 03                	jne    801da4 <__udivdi3+0xc4>
  801da1:	83 eb 01             	sub    $0x1,%ebx
  801da4:	31 ff                	xor    %edi,%edi
  801da6:	89 d8                	mov    %ebx,%eax
  801da8:	89 fa                	mov    %edi,%edx
  801daa:	83 c4 1c             	add    $0x1c,%esp
  801dad:	5b                   	pop    %ebx
  801dae:	5e                   	pop    %esi
  801daf:	5f                   	pop    %edi
  801db0:	5d                   	pop    %ebp
  801db1:	c3                   	ret    
  801db2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801db8:	31 ff                	xor    %edi,%edi
  801dba:	31 db                	xor    %ebx,%ebx
  801dbc:	89 d8                	mov    %ebx,%eax
  801dbe:	89 fa                	mov    %edi,%edx
  801dc0:	83 c4 1c             	add    $0x1c,%esp
  801dc3:	5b                   	pop    %ebx
  801dc4:	5e                   	pop    %esi
  801dc5:	5f                   	pop    %edi
  801dc6:	5d                   	pop    %ebp
  801dc7:	c3                   	ret    
  801dc8:	90                   	nop
  801dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	89 d8                	mov    %ebx,%eax
  801dd2:	f7 f7                	div    %edi
  801dd4:	31 ff                	xor    %edi,%edi
  801dd6:	89 c3                	mov    %eax,%ebx
  801dd8:	89 d8                	mov    %ebx,%eax
  801dda:	89 fa                	mov    %edi,%edx
  801ddc:	83 c4 1c             	add    $0x1c,%esp
  801ddf:	5b                   	pop    %ebx
  801de0:	5e                   	pop    %esi
  801de1:	5f                   	pop    %edi
  801de2:	5d                   	pop    %ebp
  801de3:	c3                   	ret    
  801de4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801de8:	39 ce                	cmp    %ecx,%esi
  801dea:	72 0c                	jb     801df8 <__udivdi3+0x118>
  801dec:	31 db                	xor    %ebx,%ebx
  801dee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801df2:	0f 87 34 ff ff ff    	ja     801d2c <__udivdi3+0x4c>
  801df8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801dfd:	e9 2a ff ff ff       	jmp    801d2c <__udivdi3+0x4c>
  801e02:	66 90                	xchg   %ax,%ax
  801e04:	66 90                	xchg   %ax,%ax
  801e06:	66 90                	xchg   %ax,%ax
  801e08:	66 90                	xchg   %ax,%ax
  801e0a:	66 90                	xchg   %ax,%ax
  801e0c:	66 90                	xchg   %ax,%ax
  801e0e:	66 90                	xchg   %ax,%ax

00801e10 <__umoddi3>:
  801e10:	55                   	push   %ebp
  801e11:	57                   	push   %edi
  801e12:	56                   	push   %esi
  801e13:	53                   	push   %ebx
  801e14:	83 ec 1c             	sub    $0x1c,%esp
  801e17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e27:	85 d2                	test   %edx,%edx
  801e29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e31:	89 f3                	mov    %esi,%ebx
  801e33:	89 3c 24             	mov    %edi,(%esp)
  801e36:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e3a:	75 1c                	jne    801e58 <__umoddi3+0x48>
  801e3c:	39 f7                	cmp    %esi,%edi
  801e3e:	76 50                	jbe    801e90 <__umoddi3+0x80>
  801e40:	89 c8                	mov    %ecx,%eax
  801e42:	89 f2                	mov    %esi,%edx
  801e44:	f7 f7                	div    %edi
  801e46:	89 d0                	mov    %edx,%eax
  801e48:	31 d2                	xor    %edx,%edx
  801e4a:	83 c4 1c             	add    $0x1c,%esp
  801e4d:	5b                   	pop    %ebx
  801e4e:	5e                   	pop    %esi
  801e4f:	5f                   	pop    %edi
  801e50:	5d                   	pop    %ebp
  801e51:	c3                   	ret    
  801e52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e58:	39 f2                	cmp    %esi,%edx
  801e5a:	89 d0                	mov    %edx,%eax
  801e5c:	77 52                	ja     801eb0 <__umoddi3+0xa0>
  801e5e:	0f bd ea             	bsr    %edx,%ebp
  801e61:	83 f5 1f             	xor    $0x1f,%ebp
  801e64:	75 5a                	jne    801ec0 <__umoddi3+0xb0>
  801e66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e6a:	0f 82 e0 00 00 00    	jb     801f50 <__umoddi3+0x140>
  801e70:	39 0c 24             	cmp    %ecx,(%esp)
  801e73:	0f 86 d7 00 00 00    	jbe    801f50 <__umoddi3+0x140>
  801e79:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e81:	83 c4 1c             	add    $0x1c,%esp
  801e84:	5b                   	pop    %ebx
  801e85:	5e                   	pop    %esi
  801e86:	5f                   	pop    %edi
  801e87:	5d                   	pop    %ebp
  801e88:	c3                   	ret    
  801e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e90:	85 ff                	test   %edi,%edi
  801e92:	89 fd                	mov    %edi,%ebp
  801e94:	75 0b                	jne    801ea1 <__umoddi3+0x91>
  801e96:	b8 01 00 00 00       	mov    $0x1,%eax
  801e9b:	31 d2                	xor    %edx,%edx
  801e9d:	f7 f7                	div    %edi
  801e9f:	89 c5                	mov    %eax,%ebp
  801ea1:	89 f0                	mov    %esi,%eax
  801ea3:	31 d2                	xor    %edx,%edx
  801ea5:	f7 f5                	div    %ebp
  801ea7:	89 c8                	mov    %ecx,%eax
  801ea9:	f7 f5                	div    %ebp
  801eab:	89 d0                	mov    %edx,%eax
  801ead:	eb 99                	jmp    801e48 <__umoddi3+0x38>
  801eaf:	90                   	nop
  801eb0:	89 c8                	mov    %ecx,%eax
  801eb2:	89 f2                	mov    %esi,%edx
  801eb4:	83 c4 1c             	add    $0x1c,%esp
  801eb7:	5b                   	pop    %ebx
  801eb8:	5e                   	pop    %esi
  801eb9:	5f                   	pop    %edi
  801eba:	5d                   	pop    %ebp
  801ebb:	c3                   	ret    
  801ebc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ec0:	8b 34 24             	mov    (%esp),%esi
  801ec3:	bf 20 00 00 00       	mov    $0x20,%edi
  801ec8:	89 e9                	mov    %ebp,%ecx
  801eca:	29 ef                	sub    %ebp,%edi
  801ecc:	d3 e0                	shl    %cl,%eax
  801ece:	89 f9                	mov    %edi,%ecx
  801ed0:	89 f2                	mov    %esi,%edx
  801ed2:	d3 ea                	shr    %cl,%edx
  801ed4:	89 e9                	mov    %ebp,%ecx
  801ed6:	09 c2                	or     %eax,%edx
  801ed8:	89 d8                	mov    %ebx,%eax
  801eda:	89 14 24             	mov    %edx,(%esp)
  801edd:	89 f2                	mov    %esi,%edx
  801edf:	d3 e2                	shl    %cl,%edx
  801ee1:	89 f9                	mov    %edi,%ecx
  801ee3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ee7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801eeb:	d3 e8                	shr    %cl,%eax
  801eed:	89 e9                	mov    %ebp,%ecx
  801eef:	89 c6                	mov    %eax,%esi
  801ef1:	d3 e3                	shl    %cl,%ebx
  801ef3:	89 f9                	mov    %edi,%ecx
  801ef5:	89 d0                	mov    %edx,%eax
  801ef7:	d3 e8                	shr    %cl,%eax
  801ef9:	89 e9                	mov    %ebp,%ecx
  801efb:	09 d8                	or     %ebx,%eax
  801efd:	89 d3                	mov    %edx,%ebx
  801eff:	89 f2                	mov    %esi,%edx
  801f01:	f7 34 24             	divl   (%esp)
  801f04:	89 d6                	mov    %edx,%esi
  801f06:	d3 e3                	shl    %cl,%ebx
  801f08:	f7 64 24 04          	mull   0x4(%esp)
  801f0c:	39 d6                	cmp    %edx,%esi
  801f0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f12:	89 d1                	mov    %edx,%ecx
  801f14:	89 c3                	mov    %eax,%ebx
  801f16:	72 08                	jb     801f20 <__umoddi3+0x110>
  801f18:	75 11                	jne    801f2b <__umoddi3+0x11b>
  801f1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801f1e:	73 0b                	jae    801f2b <__umoddi3+0x11b>
  801f20:	2b 44 24 04          	sub    0x4(%esp),%eax
  801f24:	1b 14 24             	sbb    (%esp),%edx
  801f27:	89 d1                	mov    %edx,%ecx
  801f29:	89 c3                	mov    %eax,%ebx
  801f2b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f2f:	29 da                	sub    %ebx,%edx
  801f31:	19 ce                	sbb    %ecx,%esi
  801f33:	89 f9                	mov    %edi,%ecx
  801f35:	89 f0                	mov    %esi,%eax
  801f37:	d3 e0                	shl    %cl,%eax
  801f39:	89 e9                	mov    %ebp,%ecx
  801f3b:	d3 ea                	shr    %cl,%edx
  801f3d:	89 e9                	mov    %ebp,%ecx
  801f3f:	d3 ee                	shr    %cl,%esi
  801f41:	09 d0                	or     %edx,%eax
  801f43:	89 f2                	mov    %esi,%edx
  801f45:	83 c4 1c             	add    $0x1c,%esp
  801f48:	5b                   	pop    %ebx
  801f49:	5e                   	pop    %esi
  801f4a:	5f                   	pop    %edi
  801f4b:	5d                   	pop    %ebp
  801f4c:	c3                   	ret    
  801f4d:	8d 76 00             	lea    0x0(%esi),%esi
  801f50:	29 f9                	sub    %edi,%ecx
  801f52:	19 d6                	sbb    %edx,%esi
  801f54:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f5c:	e9 18 ff ff ff       	jmp    801e79 <__umoddi3+0x69>
