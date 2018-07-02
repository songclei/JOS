
obj/user/faultio.debug:     file format elf32-i386


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
  80002c:	e8 3c 00 00 00       	call   80006d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>
#include <inc/x86.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
  800039:	9c                   	pushf  
  80003a:	58                   	pop    %eax
        int x, r;
	int nsecs = 1;
	int secno = 0;
	int diskno = 1;

	if (read_eflags() & FL_IOPL_3)
  80003b:	f6 c4 30             	test   $0x30,%ah
  80003e:	74 10                	je     800050 <umain+0x1d>
		cprintf("eflags wrong\n");
  800040:	83 ec 0c             	sub    $0xc,%esp
  800043:	68 40 1f 80 00       	push   $0x801f40
  800048:	e8 13 01 00 00       	call   800160 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800050:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800055:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80005a:	ee                   	out    %al,(%dx)

	// this outb to select disk 1 should result in a general protection
	// fault, because user-level code shouldn't be able to use the io space.
	outb(0x1F6, 0xE0 | (1<<4));

        cprintf("%s: made it here --- bug\n");
  80005b:	83 ec 0c             	sub    $0xc,%esp
  80005e:	68 4e 1f 80 00       	push   $0x801f4e
  800063:	e8 f8 00 00 00       	call   800160 <cprintf>
}
  800068:	83 c4 10             	add    $0x10,%esp
  80006b:	c9                   	leave  
  80006c:	c3                   	ret    

0080006d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80006d:	55                   	push   %ebp
  80006e:	89 e5                	mov    %esp,%ebp
  800070:	56                   	push   %esi
  800071:	53                   	push   %ebx
  800072:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800075:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800078:	e8 53 0b 00 00       	call   800bd0 <sys_getenvid>
  80007d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800082:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800085:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008a:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008f:	85 db                	test   %ebx,%ebx
  800091:	7e 07                	jle    80009a <libmain+0x2d>
		binaryname = argv[0];
  800093:	8b 06                	mov    (%esi),%eax
  800095:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009a:	83 ec 08             	sub    $0x8,%esp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	e8 8f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a4:	e8 0a 00 00 00       	call   8000b3 <exit>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    

008000b3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b9:	e8 0c 0f 00 00       	call   800fca <close_all>
	sys_env_destroy(0);
  8000be:	83 ec 0c             	sub    $0xc,%esp
  8000c1:	6a 00                	push   $0x0
  8000c3:	e8 c7 0a 00 00       	call   800b8f <sys_env_destroy>
}
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	c9                   	leave  
  8000cc:	c3                   	ret    

008000cd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	53                   	push   %ebx
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d7:	8b 13                	mov    (%ebx),%edx
  8000d9:	8d 42 01             	lea    0x1(%edx),%eax
  8000dc:	89 03                	mov    %eax,(%ebx)
  8000de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ea:	75 1a                	jne    800106 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ec:	83 ec 08             	sub    $0x8,%esp
  8000ef:	68 ff 00 00 00       	push   $0xff
  8000f4:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f7:	50                   	push   %eax
  8000f8:	e8 55 0a 00 00       	call   800b52 <sys_cputs>
		b->idx = 0;
  8000fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800103:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800106:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80010a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80010d:	c9                   	leave  
  80010e:	c3                   	ret    

0080010f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800118:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011f:	00 00 00 
	b.cnt = 0;
  800122:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800129:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012c:	ff 75 0c             	pushl  0xc(%ebp)
  80012f:	ff 75 08             	pushl  0x8(%ebp)
  800132:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800138:	50                   	push   %eax
  800139:	68 cd 00 80 00       	push   $0x8000cd
  80013e:	e8 54 01 00 00       	call   800297 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80014c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800152:	50                   	push   %eax
  800153:	e8 fa 09 00 00       	call   800b52 <sys_cputs>

	return b.cnt;
}
  800158:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800166:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800169:	50                   	push   %eax
  80016a:	ff 75 08             	pushl  0x8(%ebp)
  80016d:	e8 9d ff ff ff       	call   80010f <vcprintf>
	va_end(ap);

	return cnt;
}
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	57                   	push   %edi
  800178:	56                   	push   %esi
  800179:	53                   	push   %ebx
  80017a:	83 ec 1c             	sub    $0x1c,%esp
  80017d:	89 c7                	mov    %eax,%edi
  80017f:	89 d6                	mov    %edx,%esi
  800181:	8b 45 08             	mov    0x8(%ebp),%eax
  800184:	8b 55 0c             	mov    0xc(%ebp),%edx
  800187:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80018a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800190:	bb 00 00 00 00       	mov    $0x0,%ebx
  800195:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800198:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80019b:	39 d3                	cmp    %edx,%ebx
  80019d:	72 05                	jb     8001a4 <printnum+0x30>
  80019f:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001a2:	77 45                	ja     8001e9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a4:	83 ec 0c             	sub    $0xc,%esp
  8001a7:	ff 75 18             	pushl  0x18(%ebp)
  8001aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ad:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001b0:	53                   	push   %ebx
  8001b1:	ff 75 10             	pushl  0x10(%ebp)
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8001bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c3:	e8 e8 1a 00 00       	call   801cb0 <__udivdi3>
  8001c8:	83 c4 18             	add    $0x18,%esp
  8001cb:	52                   	push   %edx
  8001cc:	50                   	push   %eax
  8001cd:	89 f2                	mov    %esi,%edx
  8001cf:	89 f8                	mov    %edi,%eax
  8001d1:	e8 9e ff ff ff       	call   800174 <printnum>
  8001d6:	83 c4 20             	add    $0x20,%esp
  8001d9:	eb 18                	jmp    8001f3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001db:	83 ec 08             	sub    $0x8,%esp
  8001de:	56                   	push   %esi
  8001df:	ff 75 18             	pushl  0x18(%ebp)
  8001e2:	ff d7                	call   *%edi
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 03                	jmp    8001ec <printnum+0x78>
  8001e9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ec:	83 eb 01             	sub    $0x1,%ebx
  8001ef:	85 db                	test   %ebx,%ebx
  8001f1:	7f e8                	jg     8001db <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f3:	83 ec 08             	sub    $0x8,%esp
  8001f6:	56                   	push   %esi
  8001f7:	83 ec 04             	sub    $0x4,%esp
  8001fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fd:	ff 75 e0             	pushl  -0x20(%ebp)
  800200:	ff 75 dc             	pushl  -0x24(%ebp)
  800203:	ff 75 d8             	pushl  -0x28(%ebp)
  800206:	e8 d5 1b 00 00       	call   801de0 <__umoddi3>
  80020b:	83 c4 14             	add    $0x14,%esp
  80020e:	0f be 80 72 1f 80 00 	movsbl 0x801f72(%eax),%eax
  800215:	50                   	push   %eax
  800216:	ff d7                	call   *%edi
}
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021e:	5b                   	pop    %ebx
  80021f:	5e                   	pop    %esi
  800220:	5f                   	pop    %edi
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    

00800223 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800226:	83 fa 01             	cmp    $0x1,%edx
  800229:	7e 0e                	jle    800239 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80022b:	8b 10                	mov    (%eax),%edx
  80022d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800230:	89 08                	mov    %ecx,(%eax)
  800232:	8b 02                	mov    (%edx),%eax
  800234:	8b 52 04             	mov    0x4(%edx),%edx
  800237:	eb 22                	jmp    80025b <getuint+0x38>
	else if (lflag)
  800239:	85 d2                	test   %edx,%edx
  80023b:	74 10                	je     80024d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80023d:	8b 10                	mov    (%eax),%edx
  80023f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800242:	89 08                	mov    %ecx,(%eax)
  800244:	8b 02                	mov    (%edx),%eax
  800246:	ba 00 00 00 00       	mov    $0x0,%edx
  80024b:	eb 0e                	jmp    80025b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80024d:	8b 10                	mov    (%eax),%edx
  80024f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800252:	89 08                	mov    %ecx,(%eax)
  800254:	8b 02                	mov    (%edx),%eax
  800256:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80025b:	5d                   	pop    %ebp
  80025c:	c3                   	ret    

0080025d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800263:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800267:	8b 10                	mov    (%eax),%edx
  800269:	3b 50 04             	cmp    0x4(%eax),%edx
  80026c:	73 0a                	jae    800278 <sprintputch+0x1b>
		*b->buf++ = ch;
  80026e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800271:	89 08                	mov    %ecx,(%eax)
  800273:	8b 45 08             	mov    0x8(%ebp),%eax
  800276:	88 02                	mov    %al,(%edx)
}
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800280:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800283:	50                   	push   %eax
  800284:	ff 75 10             	pushl  0x10(%ebp)
  800287:	ff 75 0c             	pushl  0xc(%ebp)
  80028a:	ff 75 08             	pushl  0x8(%ebp)
  80028d:	e8 05 00 00 00       	call   800297 <vprintfmt>
	va_end(ap);
}
  800292:	83 c4 10             	add    $0x10,%esp
  800295:	c9                   	leave  
  800296:	c3                   	ret    

00800297 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	57                   	push   %edi
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
  80029d:	83 ec 2c             	sub    $0x2c,%esp
  8002a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a9:	eb 12                	jmp    8002bd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ab:	85 c0                	test   %eax,%eax
  8002ad:	0f 84 38 04 00 00    	je     8006eb <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8002b3:	83 ec 08             	sub    $0x8,%esp
  8002b6:	53                   	push   %ebx
  8002b7:	50                   	push   %eax
  8002b8:	ff d6                	call   *%esi
  8002ba:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002bd:	83 c7 01             	add    $0x1,%edi
  8002c0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002c4:	83 f8 25             	cmp    $0x25,%eax
  8002c7:	75 e2                	jne    8002ab <vprintfmt+0x14>
  8002c9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002cd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002d4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002db:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e7:	eb 07                	jmp    8002f0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8002ec:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f0:	8d 47 01             	lea    0x1(%edi),%eax
  8002f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f6:	0f b6 07             	movzbl (%edi),%eax
  8002f9:	0f b6 c8             	movzbl %al,%ecx
  8002fc:	83 e8 23             	sub    $0x23,%eax
  8002ff:	3c 55                	cmp    $0x55,%al
  800301:	0f 87 c9 03 00 00    	ja     8006d0 <vprintfmt+0x439>
  800307:	0f b6 c0             	movzbl %al,%eax
  80030a:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  800311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800314:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800318:	eb d6                	jmp    8002f0 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  80031a:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  800321:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  800327:	eb 94                	jmp    8002bd <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  800329:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  800330:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800333:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  800336:	eb 85                	jmp    8002bd <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  800338:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  80033f:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  800345:	e9 73 ff ff ff       	jmp    8002bd <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  80034a:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  800351:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  800357:	e9 61 ff ff ff       	jmp    8002bd <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  80035c:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800363:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  800369:	e9 4f ff ff ff       	jmp    8002bd <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80036e:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800375:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80037b:	e9 3d ff ff ff       	jmp    8002bd <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  800380:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  800387:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80038d:	e9 2b ff ff ff       	jmp    8002bd <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  800392:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  800399:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  80039f:	e9 19 ff ff ff       	jmp    8002bd <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  8003a4:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  8003ab:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8003b1:	e9 07 ff ff ff       	jmp    8002bd <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8003b6:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  8003bd:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8003c3:	e9 f5 fe ff ff       	jmp    8002bd <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003da:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003dd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e0:	83 fa 09             	cmp    $0x9,%edx
  8003e3:	77 3f                	ja     800424 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e8:	eb e9                	jmp    8003d3 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ed:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f3:	8b 00                	mov    (%eax),%eax
  8003f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003fb:	eb 2d                	jmp    80042a <vprintfmt+0x193>
  8003fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800400:	85 c0                	test   %eax,%eax
  800402:	b9 00 00 00 00       	mov    $0x0,%ecx
  800407:	0f 49 c8             	cmovns %eax,%ecx
  80040a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800410:	e9 db fe ff ff       	jmp    8002f0 <vprintfmt+0x59>
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800418:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80041f:	e9 cc fe ff ff       	jmp    8002f0 <vprintfmt+0x59>
  800424:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800427:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80042a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042e:	0f 89 bc fe ff ff    	jns    8002f0 <vprintfmt+0x59>
				width = precision, precision = -1;
  800434:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800437:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800441:	e9 aa fe ff ff       	jmp    8002f0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800446:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044c:	e9 9f fe ff ff       	jmp    8002f0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 50 04             	lea    0x4(%eax),%edx
  800457:	89 55 14             	mov    %edx,0x14(%ebp)
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	53                   	push   %ebx
  80045e:	ff 30                	pushl  (%eax)
  800460:	ff d6                	call   *%esi
			break;
  800462:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800468:	e9 50 fe ff ff       	jmp    8002bd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046d:	8b 45 14             	mov    0x14(%ebp),%eax
  800470:	8d 50 04             	lea    0x4(%eax),%edx
  800473:	89 55 14             	mov    %edx,0x14(%ebp)
  800476:	8b 00                	mov    (%eax),%eax
  800478:	99                   	cltd   
  800479:	31 d0                	xor    %edx,%eax
  80047b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047d:	83 f8 0f             	cmp    $0xf,%eax
  800480:	7f 0b                	jg     80048d <vprintfmt+0x1f6>
  800482:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  800489:	85 d2                	test   %edx,%edx
  80048b:	75 18                	jne    8004a5 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80048d:	50                   	push   %eax
  80048e:	68 8a 1f 80 00       	push   $0x801f8a
  800493:	53                   	push   %ebx
  800494:	56                   	push   %esi
  800495:	e8 e0 fd ff ff       	call   80027a <printfmt>
  80049a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a0:	e9 18 fe ff ff       	jmp    8002bd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a5:	52                   	push   %edx
  8004a6:	68 51 23 80 00       	push   $0x802351
  8004ab:	53                   	push   %ebx
  8004ac:	56                   	push   %esi
  8004ad:	e8 c8 fd ff ff       	call   80027a <printfmt>
  8004b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b8:	e9 00 fe ff ff       	jmp    8002bd <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c0:	8d 50 04             	lea    0x4(%eax),%edx
  8004c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c8:	85 ff                	test   %edi,%edi
  8004ca:	b8 83 1f 80 00       	mov    $0x801f83,%eax
  8004cf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d6:	0f 8e 94 00 00 00    	jle    800570 <vprintfmt+0x2d9>
  8004dc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e0:	0f 84 98 00 00 00    	je     80057e <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ec:	57                   	push   %edi
  8004ed:	e8 81 02 00 00       	call   800773 <strnlen>
  8004f2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f5:	29 c1                	sub    %eax,%ecx
  8004f7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004fa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800501:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800504:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800507:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800509:	eb 0f                	jmp    80051a <vprintfmt+0x283>
					putch(padc, putdat);
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	53                   	push   %ebx
  80050f:	ff 75 e0             	pushl  -0x20(%ebp)
  800512:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800514:	83 ef 01             	sub    $0x1,%edi
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 ff                	test   %edi,%edi
  80051c:	7f ed                	jg     80050b <vprintfmt+0x274>
  80051e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800521:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800524:	85 c9                	test   %ecx,%ecx
  800526:	b8 00 00 00 00       	mov    $0x0,%eax
  80052b:	0f 49 c1             	cmovns %ecx,%eax
  80052e:	29 c1                	sub    %eax,%ecx
  800530:	89 75 08             	mov    %esi,0x8(%ebp)
  800533:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800536:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800539:	89 cb                	mov    %ecx,%ebx
  80053b:	eb 4d                	jmp    80058a <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800541:	74 1b                	je     80055e <vprintfmt+0x2c7>
  800543:	0f be c0             	movsbl %al,%eax
  800546:	83 e8 20             	sub    $0x20,%eax
  800549:	83 f8 5e             	cmp    $0x5e,%eax
  80054c:	76 10                	jbe    80055e <vprintfmt+0x2c7>
					putch('?', putdat);
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	ff 75 0c             	pushl  0xc(%ebp)
  800554:	6a 3f                	push   $0x3f
  800556:	ff 55 08             	call   *0x8(%ebp)
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	eb 0d                	jmp    80056b <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	ff 75 0c             	pushl  0xc(%ebp)
  800564:	52                   	push   %edx
  800565:	ff 55 08             	call   *0x8(%ebp)
  800568:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056b:	83 eb 01             	sub    $0x1,%ebx
  80056e:	eb 1a                	jmp    80058a <vprintfmt+0x2f3>
  800570:	89 75 08             	mov    %esi,0x8(%ebp)
  800573:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800576:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800579:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057c:	eb 0c                	jmp    80058a <vprintfmt+0x2f3>
  80057e:	89 75 08             	mov    %esi,0x8(%ebp)
  800581:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800584:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800587:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058a:	83 c7 01             	add    $0x1,%edi
  80058d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800591:	0f be d0             	movsbl %al,%edx
  800594:	85 d2                	test   %edx,%edx
  800596:	74 23                	je     8005bb <vprintfmt+0x324>
  800598:	85 f6                	test   %esi,%esi
  80059a:	78 a1                	js     80053d <vprintfmt+0x2a6>
  80059c:	83 ee 01             	sub    $0x1,%esi
  80059f:	79 9c                	jns    80053d <vprintfmt+0x2a6>
  8005a1:	89 df                	mov    %ebx,%edi
  8005a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a9:	eb 18                	jmp    8005c3 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	53                   	push   %ebx
  8005af:	6a 20                	push   $0x20
  8005b1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b3:	83 ef 01             	sub    $0x1,%edi
  8005b6:	83 c4 10             	add    $0x10,%esp
  8005b9:	eb 08                	jmp    8005c3 <vprintfmt+0x32c>
  8005bb:	89 df                	mov    %ebx,%edi
  8005bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c3:	85 ff                	test   %edi,%edi
  8005c5:	7f e4                	jg     8005ab <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ca:	e9 ee fc ff ff       	jmp    8002bd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005cf:	83 fa 01             	cmp    $0x1,%edx
  8005d2:	7e 16                	jle    8005ea <vprintfmt+0x353>
		return va_arg(*ap, long long);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 50 08             	lea    0x8(%eax),%edx
  8005da:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dd:	8b 50 04             	mov    0x4(%eax),%edx
  8005e0:	8b 00                	mov    (%eax),%eax
  8005e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e8:	eb 32                	jmp    80061c <vprintfmt+0x385>
	else if (lflag)
  8005ea:	85 d2                	test   %edx,%edx
  8005ec:	74 18                	je     800606 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 50 04             	lea    0x4(%eax),%edx
  8005f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f7:	8b 00                	mov    (%eax),%eax
  8005f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fc:	89 c1                	mov    %eax,%ecx
  8005fe:	c1 f9 1f             	sar    $0x1f,%ecx
  800601:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800604:	eb 16                	jmp    80061c <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 50 04             	lea    0x4(%eax),%edx
  80060c:	89 55 14             	mov    %edx,0x14(%ebp)
  80060f:	8b 00                	mov    (%eax),%eax
  800611:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800614:	89 c1                	mov    %eax,%ecx
  800616:	c1 f9 1f             	sar    $0x1f,%ecx
  800619:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800622:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800627:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062b:	79 6f                	jns    80069c <vprintfmt+0x405>
				putch('-', putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 2d                	push   $0x2d
  800633:	ff d6                	call   *%esi
				num = -(long long) num;
  800635:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800638:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063b:	f7 d8                	neg    %eax
  80063d:	83 d2 00             	adc    $0x0,%edx
  800640:	f7 da                	neg    %edx
  800642:	83 c4 10             	add    $0x10,%esp
  800645:	eb 55                	jmp    80069c <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800647:	8d 45 14             	lea    0x14(%ebp),%eax
  80064a:	e8 d4 fb ff ff       	call   800223 <getuint>
			base = 10;
  80064f:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800654:	eb 46                	jmp    80069c <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800656:	8d 45 14             	lea    0x14(%ebp),%eax
  800659:	e8 c5 fb ff ff       	call   800223 <getuint>
			base = 8;
  80065e:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800663:	eb 37                	jmp    80069c <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800665:	83 ec 08             	sub    $0x8,%esp
  800668:	53                   	push   %ebx
  800669:	6a 30                	push   $0x30
  80066b:	ff d6                	call   *%esi
			putch('x', putdat);
  80066d:	83 c4 08             	add    $0x8,%esp
  800670:	53                   	push   %ebx
  800671:	6a 78                	push   $0x78
  800673:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8d 50 04             	lea    0x4(%eax),%edx
  80067b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80067e:	8b 00                	mov    (%eax),%eax
  800680:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800685:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800688:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80068d:	eb 0d                	jmp    80069c <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068f:	8d 45 14             	lea    0x14(%ebp),%eax
  800692:	e8 8c fb ff ff       	call   800223 <getuint>
			base = 16;
  800697:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069c:	83 ec 0c             	sub    $0xc,%esp
  80069f:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8006a3:	51                   	push   %ecx
  8006a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a7:	57                   	push   %edi
  8006a8:	52                   	push   %edx
  8006a9:	50                   	push   %eax
  8006aa:	89 da                	mov    %ebx,%edx
  8006ac:	89 f0                	mov    %esi,%eax
  8006ae:	e8 c1 fa ff ff       	call   800174 <printnum>
			break;
  8006b3:	83 c4 20             	add    $0x20,%esp
  8006b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b9:	e9 ff fb ff ff       	jmp    8002bd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	51                   	push   %ecx
  8006c3:	ff d6                	call   *%esi
			break;
  8006c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cb:	e9 ed fb ff ff       	jmp    8002bd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	53                   	push   %ebx
  8006d4:	6a 25                	push   $0x25
  8006d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	eb 03                	jmp    8006e0 <vprintfmt+0x449>
  8006dd:	83 ef 01             	sub    $0x1,%edi
  8006e0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e4:	75 f7                	jne    8006dd <vprintfmt+0x446>
  8006e6:	e9 d2 fb ff ff       	jmp    8002bd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ee:	5b                   	pop    %ebx
  8006ef:	5e                   	pop    %esi
  8006f0:	5f                   	pop    %edi
  8006f1:	5d                   	pop    %ebp
  8006f2:	c3                   	ret    

008006f3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f3:	55                   	push   %ebp
  8006f4:	89 e5                	mov    %esp,%ebp
  8006f6:	83 ec 18             	sub    $0x18,%esp
  8006f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800702:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800706:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800709:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800710:	85 c0                	test   %eax,%eax
  800712:	74 26                	je     80073a <vsnprintf+0x47>
  800714:	85 d2                	test   %edx,%edx
  800716:	7e 22                	jle    80073a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800718:	ff 75 14             	pushl  0x14(%ebp)
  80071b:	ff 75 10             	pushl  0x10(%ebp)
  80071e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800721:	50                   	push   %eax
  800722:	68 5d 02 80 00       	push   $0x80025d
  800727:	e8 6b fb ff ff       	call   800297 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800732:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	eb 05                	jmp    80073f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073f:	c9                   	leave  
  800740:	c3                   	ret    

00800741 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074a:	50                   	push   %eax
  80074b:	ff 75 10             	pushl  0x10(%ebp)
  80074e:	ff 75 0c             	pushl  0xc(%ebp)
  800751:	ff 75 08             	pushl  0x8(%ebp)
  800754:	e8 9a ff ff ff       	call   8006f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800759:	c9                   	leave  
  80075a:	c3                   	ret    

0080075b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800761:	b8 00 00 00 00       	mov    $0x0,%eax
  800766:	eb 03                	jmp    80076b <strlen+0x10>
		n++;
  800768:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076f:	75 f7                	jne    800768 <strlen+0xd>
		n++;
	return n;
}
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800779:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077c:	ba 00 00 00 00       	mov    $0x0,%edx
  800781:	eb 03                	jmp    800786 <strnlen+0x13>
		n++;
  800783:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800786:	39 c2                	cmp    %eax,%edx
  800788:	74 08                	je     800792 <strnlen+0x1f>
  80078a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80078e:	75 f3                	jne    800783 <strnlen+0x10>
  800790:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	53                   	push   %ebx
  800798:	8b 45 08             	mov    0x8(%ebp),%eax
  80079b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079e:	89 c2                	mov    %eax,%edx
  8007a0:	83 c2 01             	add    $0x1,%edx
  8007a3:	83 c1 01             	add    $0x1,%ecx
  8007a6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007aa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ad:	84 db                	test   %bl,%bl
  8007af:	75 ef                	jne    8007a0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b1:	5b                   	pop    %ebx
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bb:	53                   	push   %ebx
  8007bc:	e8 9a ff ff ff       	call   80075b <strlen>
  8007c1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c4:	ff 75 0c             	pushl  0xc(%ebp)
  8007c7:	01 d8                	add    %ebx,%eax
  8007c9:	50                   	push   %eax
  8007ca:	e8 c5 ff ff ff       	call   800794 <strcpy>
	return dst;
}
  8007cf:	89 d8                	mov    %ebx,%eax
  8007d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    

008007d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	56                   	push   %esi
  8007da:	53                   	push   %ebx
  8007db:	8b 75 08             	mov    0x8(%ebp),%esi
  8007de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e1:	89 f3                	mov    %esi,%ebx
  8007e3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e6:	89 f2                	mov    %esi,%edx
  8007e8:	eb 0f                	jmp    8007f9 <strncpy+0x23>
		*dst++ = *src;
  8007ea:	83 c2 01             	add    $0x1,%edx
  8007ed:	0f b6 01             	movzbl (%ecx),%eax
  8007f0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f9:	39 da                	cmp    %ebx,%edx
  8007fb:	75 ed                	jne    8007ea <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007fd:	89 f0                	mov    %esi,%eax
  8007ff:	5b                   	pop    %ebx
  800800:	5e                   	pop    %esi
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	56                   	push   %esi
  800807:	53                   	push   %ebx
  800808:	8b 75 08             	mov    0x8(%ebp),%esi
  80080b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080e:	8b 55 10             	mov    0x10(%ebp),%edx
  800811:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800813:	85 d2                	test   %edx,%edx
  800815:	74 21                	je     800838 <strlcpy+0x35>
  800817:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081b:	89 f2                	mov    %esi,%edx
  80081d:	eb 09                	jmp    800828 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081f:	83 c2 01             	add    $0x1,%edx
  800822:	83 c1 01             	add    $0x1,%ecx
  800825:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800828:	39 c2                	cmp    %eax,%edx
  80082a:	74 09                	je     800835 <strlcpy+0x32>
  80082c:	0f b6 19             	movzbl (%ecx),%ebx
  80082f:	84 db                	test   %bl,%bl
  800831:	75 ec                	jne    80081f <strlcpy+0x1c>
  800833:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800835:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800838:	29 f0                	sub    %esi,%eax
}
  80083a:	5b                   	pop    %ebx
  80083b:	5e                   	pop    %esi
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800844:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800847:	eb 06                	jmp    80084f <strcmp+0x11>
		p++, q++;
  800849:	83 c1 01             	add    $0x1,%ecx
  80084c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80084f:	0f b6 01             	movzbl (%ecx),%eax
  800852:	84 c0                	test   %al,%al
  800854:	74 04                	je     80085a <strcmp+0x1c>
  800856:	3a 02                	cmp    (%edx),%al
  800858:	74 ef                	je     800849 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085a:	0f b6 c0             	movzbl %al,%eax
  80085d:	0f b6 12             	movzbl (%edx),%edx
  800860:	29 d0                	sub    %edx,%eax
}
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	53                   	push   %ebx
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086e:	89 c3                	mov    %eax,%ebx
  800870:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800873:	eb 06                	jmp    80087b <strncmp+0x17>
		n--, p++, q++;
  800875:	83 c0 01             	add    $0x1,%eax
  800878:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087b:	39 d8                	cmp    %ebx,%eax
  80087d:	74 15                	je     800894 <strncmp+0x30>
  80087f:	0f b6 08             	movzbl (%eax),%ecx
  800882:	84 c9                	test   %cl,%cl
  800884:	74 04                	je     80088a <strncmp+0x26>
  800886:	3a 0a                	cmp    (%edx),%cl
  800888:	74 eb                	je     800875 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088a:	0f b6 00             	movzbl (%eax),%eax
  80088d:	0f b6 12             	movzbl (%edx),%edx
  800890:	29 d0                	sub    %edx,%eax
  800892:	eb 05                	jmp    800899 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800899:	5b                   	pop    %ebx
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a6:	eb 07                	jmp    8008af <strchr+0x13>
		if (*s == c)
  8008a8:	38 ca                	cmp    %cl,%dl
  8008aa:	74 0f                	je     8008bb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ac:	83 c0 01             	add    $0x1,%eax
  8008af:	0f b6 10             	movzbl (%eax),%edx
  8008b2:	84 d2                	test   %dl,%dl
  8008b4:	75 f2                	jne    8008a8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c7:	eb 03                	jmp    8008cc <strfind+0xf>
  8008c9:	83 c0 01             	add    $0x1,%eax
  8008cc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008cf:	38 ca                	cmp    %cl,%dl
  8008d1:	74 04                	je     8008d7 <strfind+0x1a>
  8008d3:	84 d2                	test   %dl,%dl
  8008d5:	75 f2                	jne    8008c9 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	57                   	push   %edi
  8008dd:	56                   	push   %esi
  8008de:	53                   	push   %ebx
  8008df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e5:	85 c9                	test   %ecx,%ecx
  8008e7:	74 36                	je     80091f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ef:	75 28                	jne    800919 <memset+0x40>
  8008f1:	f6 c1 03             	test   $0x3,%cl
  8008f4:	75 23                	jne    800919 <memset+0x40>
		c &= 0xFF;
  8008f6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fa:	89 d3                	mov    %edx,%ebx
  8008fc:	c1 e3 08             	shl    $0x8,%ebx
  8008ff:	89 d6                	mov    %edx,%esi
  800901:	c1 e6 18             	shl    $0x18,%esi
  800904:	89 d0                	mov    %edx,%eax
  800906:	c1 e0 10             	shl    $0x10,%eax
  800909:	09 f0                	or     %esi,%eax
  80090b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80090d:	89 d8                	mov    %ebx,%eax
  80090f:	09 d0                	or     %edx,%eax
  800911:	c1 e9 02             	shr    $0x2,%ecx
  800914:	fc                   	cld    
  800915:	f3 ab                	rep stos %eax,%es:(%edi)
  800917:	eb 06                	jmp    80091f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800919:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091c:	fc                   	cld    
  80091d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091f:	89 f8                	mov    %edi,%eax
  800921:	5b                   	pop    %ebx
  800922:	5e                   	pop    %esi
  800923:	5f                   	pop    %edi
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	57                   	push   %edi
  80092a:	56                   	push   %esi
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800931:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800934:	39 c6                	cmp    %eax,%esi
  800936:	73 35                	jae    80096d <memmove+0x47>
  800938:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093b:	39 d0                	cmp    %edx,%eax
  80093d:	73 2e                	jae    80096d <memmove+0x47>
		s += n;
		d += n;
  80093f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800942:	89 d6                	mov    %edx,%esi
  800944:	09 fe                	or     %edi,%esi
  800946:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094c:	75 13                	jne    800961 <memmove+0x3b>
  80094e:	f6 c1 03             	test   $0x3,%cl
  800951:	75 0e                	jne    800961 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800953:	83 ef 04             	sub    $0x4,%edi
  800956:	8d 72 fc             	lea    -0x4(%edx),%esi
  800959:	c1 e9 02             	shr    $0x2,%ecx
  80095c:	fd                   	std    
  80095d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095f:	eb 09                	jmp    80096a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800961:	83 ef 01             	sub    $0x1,%edi
  800964:	8d 72 ff             	lea    -0x1(%edx),%esi
  800967:	fd                   	std    
  800968:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096a:	fc                   	cld    
  80096b:	eb 1d                	jmp    80098a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096d:	89 f2                	mov    %esi,%edx
  80096f:	09 c2                	or     %eax,%edx
  800971:	f6 c2 03             	test   $0x3,%dl
  800974:	75 0f                	jne    800985 <memmove+0x5f>
  800976:	f6 c1 03             	test   $0x3,%cl
  800979:	75 0a                	jne    800985 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80097b:	c1 e9 02             	shr    $0x2,%ecx
  80097e:	89 c7                	mov    %eax,%edi
  800980:	fc                   	cld    
  800981:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800983:	eb 05                	jmp    80098a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800985:	89 c7                	mov    %eax,%edi
  800987:	fc                   	cld    
  800988:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098a:	5e                   	pop    %esi
  80098b:	5f                   	pop    %edi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800991:	ff 75 10             	pushl  0x10(%ebp)
  800994:	ff 75 0c             	pushl  0xc(%ebp)
  800997:	ff 75 08             	pushl  0x8(%ebp)
  80099a:	e8 87 ff ff ff       	call   800926 <memmove>
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ac:	89 c6                	mov    %eax,%esi
  8009ae:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b1:	eb 1a                	jmp    8009cd <memcmp+0x2c>
		if (*s1 != *s2)
  8009b3:	0f b6 08             	movzbl (%eax),%ecx
  8009b6:	0f b6 1a             	movzbl (%edx),%ebx
  8009b9:	38 d9                	cmp    %bl,%cl
  8009bb:	74 0a                	je     8009c7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009bd:	0f b6 c1             	movzbl %cl,%eax
  8009c0:	0f b6 db             	movzbl %bl,%ebx
  8009c3:	29 d8                	sub    %ebx,%eax
  8009c5:	eb 0f                	jmp    8009d6 <memcmp+0x35>
		s1++, s2++;
  8009c7:	83 c0 01             	add    $0x1,%eax
  8009ca:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cd:	39 f0                	cmp    %esi,%eax
  8009cf:	75 e2                	jne    8009b3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	53                   	push   %ebx
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e1:	89 c1                	mov    %eax,%ecx
  8009e3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ea:	eb 0a                	jmp    8009f6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ec:	0f b6 10             	movzbl (%eax),%edx
  8009ef:	39 da                	cmp    %ebx,%edx
  8009f1:	74 07                	je     8009fa <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f3:	83 c0 01             	add    $0x1,%eax
  8009f6:	39 c8                	cmp    %ecx,%eax
  8009f8:	72 f2                	jb     8009ec <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fa:	5b                   	pop    %ebx
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	57                   	push   %edi
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a09:	eb 03                	jmp    800a0e <strtol+0x11>
		s++;
  800a0b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0e:	0f b6 01             	movzbl (%ecx),%eax
  800a11:	3c 20                	cmp    $0x20,%al
  800a13:	74 f6                	je     800a0b <strtol+0xe>
  800a15:	3c 09                	cmp    $0x9,%al
  800a17:	74 f2                	je     800a0b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a19:	3c 2b                	cmp    $0x2b,%al
  800a1b:	75 0a                	jne    800a27 <strtol+0x2a>
		s++;
  800a1d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a20:	bf 00 00 00 00       	mov    $0x0,%edi
  800a25:	eb 11                	jmp    800a38 <strtol+0x3b>
  800a27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2c:	3c 2d                	cmp    $0x2d,%al
  800a2e:	75 08                	jne    800a38 <strtol+0x3b>
		s++, neg = 1;
  800a30:	83 c1 01             	add    $0x1,%ecx
  800a33:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3e:	75 15                	jne    800a55 <strtol+0x58>
  800a40:	80 39 30             	cmpb   $0x30,(%ecx)
  800a43:	75 10                	jne    800a55 <strtol+0x58>
  800a45:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a49:	75 7c                	jne    800ac7 <strtol+0xca>
		s += 2, base = 16;
  800a4b:	83 c1 02             	add    $0x2,%ecx
  800a4e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a53:	eb 16                	jmp    800a6b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a55:	85 db                	test   %ebx,%ebx
  800a57:	75 12                	jne    800a6b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a59:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a61:	75 08                	jne    800a6b <strtol+0x6e>
		s++, base = 8;
  800a63:	83 c1 01             	add    $0x1,%ecx
  800a66:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a70:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a73:	0f b6 11             	movzbl (%ecx),%edx
  800a76:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a79:	89 f3                	mov    %esi,%ebx
  800a7b:	80 fb 09             	cmp    $0x9,%bl
  800a7e:	77 08                	ja     800a88 <strtol+0x8b>
			dig = *s - '0';
  800a80:	0f be d2             	movsbl %dl,%edx
  800a83:	83 ea 30             	sub    $0x30,%edx
  800a86:	eb 22                	jmp    800aaa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a88:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8b:	89 f3                	mov    %esi,%ebx
  800a8d:	80 fb 19             	cmp    $0x19,%bl
  800a90:	77 08                	ja     800a9a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a92:	0f be d2             	movsbl %dl,%edx
  800a95:	83 ea 57             	sub    $0x57,%edx
  800a98:	eb 10                	jmp    800aaa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a9a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9d:	89 f3                	mov    %esi,%ebx
  800a9f:	80 fb 19             	cmp    $0x19,%bl
  800aa2:	77 16                	ja     800aba <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa4:	0f be d2             	movsbl %dl,%edx
  800aa7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aaa:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aad:	7d 0b                	jge    800aba <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aaf:	83 c1 01             	add    $0x1,%ecx
  800ab2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab8:	eb b9                	jmp    800a73 <strtol+0x76>

	if (endptr)
  800aba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abe:	74 0d                	je     800acd <strtol+0xd0>
		*endptr = (char *) s;
  800ac0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac3:	89 0e                	mov    %ecx,(%esi)
  800ac5:	eb 06                	jmp    800acd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac7:	85 db                	test   %ebx,%ebx
  800ac9:	74 98                	je     800a63 <strtol+0x66>
  800acb:	eb 9e                	jmp    800a6b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800acd:	89 c2                	mov    %eax,%edx
  800acf:	f7 da                	neg    %edx
  800ad1:	85 ff                	test   %edi,%edi
  800ad3:	0f 45 c2             	cmovne %edx,%eax
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	83 ec 04             	sub    $0x4,%esp
  800ae4:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800ae7:	57                   	push   %edi
  800ae8:	e8 6e fc ff ff       	call   80075b <strlen>
  800aed:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800af0:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800af3:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800afd:	eb 46                	jmp    800b45 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800aff:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800b03:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b06:	80 f9 09             	cmp    $0x9,%cl
  800b09:	77 08                	ja     800b13 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800b0b:	0f be d2             	movsbl %dl,%edx
  800b0e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b11:	eb 27                	jmp    800b3a <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800b13:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800b16:	80 f9 05             	cmp    $0x5,%cl
  800b19:	77 08                	ja     800b23 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800b1b:	0f be d2             	movsbl %dl,%edx
  800b1e:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800b21:	eb 17                	jmp    800b3a <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800b23:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800b26:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800b29:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800b2e:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800b32:	77 06                	ja     800b3a <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800b34:	0f be d2             	movsbl %dl,%edx
  800b37:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800b3a:	0f af ce             	imul   %esi,%ecx
  800b3d:	01 c8                	add    %ecx,%eax
		base *= 16;
  800b3f:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b42:	83 eb 01             	sub    $0x1,%ebx
  800b45:	83 fb 01             	cmp    $0x1,%ebx
  800b48:	7f b5                	jg     800aff <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800b4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b58:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b60:	8b 55 08             	mov    0x8(%ebp),%edx
  800b63:	89 c3                	mov    %eax,%ebx
  800b65:	89 c7                	mov    %eax,%edi
  800b67:	89 c6                	mov    %eax,%esi
  800b69:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b80:	89 d1                	mov    %edx,%ecx
  800b82:	89 d3                	mov    %edx,%ebx
  800b84:	89 d7                	mov    %edx,%edi
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
  800b95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b98:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9d:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba5:	89 cb                	mov    %ecx,%ebx
  800ba7:	89 cf                	mov    %ecx,%edi
  800ba9:	89 ce                	mov    %ecx,%esi
  800bab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bad:	85 c0                	test   %eax,%eax
  800baf:	7e 17                	jle    800bc8 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb1:	83 ec 0c             	sub    $0xc,%esp
  800bb4:	50                   	push   %eax
  800bb5:	6a 03                	push   $0x3
  800bb7:	68 7f 22 80 00       	push   $0x80227f
  800bbc:	6a 23                	push   $0x23
  800bbe:	68 9c 22 80 00       	push   $0x80229c
  800bc3:	e8 69 0f 00 00       	call   801b31 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5f                   	pop    %edi
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800bdb:	b8 02 00 00 00       	mov    $0x2,%eax
  800be0:	89 d1                	mov    %edx,%ecx
  800be2:	89 d3                	mov    %edx,%ebx
  800be4:	89 d7                	mov    %edx,%edi
  800be6:	89 d6                	mov    %edx,%esi
  800be8:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <sys_yield>:

void
sys_yield(void)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfa:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bff:	89 d1                	mov    %edx,%ecx
  800c01:	89 d3                	mov    %edx,%ebx
  800c03:	89 d7                	mov    %edx,%edi
  800c05:	89 d6                	mov    %edx,%esi
  800c07:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
  800c14:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c17:	be 00 00 00 00       	mov    $0x0,%esi
  800c1c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c24:	8b 55 08             	mov    0x8(%ebp),%edx
  800c27:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2a:	89 f7                	mov    %esi,%edi
  800c2c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2e:	85 c0                	test   %eax,%eax
  800c30:	7e 17                	jle    800c49 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c32:	83 ec 0c             	sub    $0xc,%esp
  800c35:	50                   	push   %eax
  800c36:	6a 04                	push   $0x4
  800c38:	68 7f 22 80 00       	push   $0x80227f
  800c3d:	6a 23                	push   $0x23
  800c3f:	68 9c 22 80 00       	push   $0x80229c
  800c44:	e8 e8 0e 00 00       	call   801b31 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c62:	8b 55 08             	mov    0x8(%ebp),%edx
  800c65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c68:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c6b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c6e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c70:	85 c0                	test   %eax,%eax
  800c72:	7e 17                	jle    800c8b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c74:	83 ec 0c             	sub    $0xc,%esp
  800c77:	50                   	push   %eax
  800c78:	6a 05                	push   $0x5
  800c7a:	68 7f 22 80 00       	push   $0x80227f
  800c7f:	6a 23                	push   $0x23
  800c81:	68 9c 22 80 00       	push   $0x80229c
  800c86:	e8 a6 0e 00 00       	call   801b31 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca1:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	89 df                	mov    %ebx,%edi
  800cae:	89 de                	mov    %ebx,%esi
  800cb0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	7e 17                	jle    800ccd <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb6:	83 ec 0c             	sub    $0xc,%esp
  800cb9:	50                   	push   %eax
  800cba:	6a 06                	push   $0x6
  800cbc:	68 7f 22 80 00       	push   $0x80227f
  800cc1:	6a 23                	push   $0x23
  800cc3:	68 9c 22 80 00       	push   $0x80229c
  800cc8:	e8 64 0e 00 00       	call   801b31 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ccd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
  800cdb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cde:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce3:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	89 df                	mov    %ebx,%edi
  800cf0:	89 de                	mov    %ebx,%esi
  800cf2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	7e 17                	jle    800d0f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf8:	83 ec 0c             	sub    $0xc,%esp
  800cfb:	50                   	push   %eax
  800cfc:	6a 08                	push   $0x8
  800cfe:	68 7f 22 80 00       	push   $0x80227f
  800d03:	6a 23                	push   $0x23
  800d05:	68 9c 22 80 00       	push   $0x80229c
  800d0a:	e8 22 0e 00 00       	call   801b31 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d25:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	89 df                	mov    %ebx,%edi
  800d32:	89 de                	mov    %ebx,%esi
  800d34:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7e 17                	jle    800d51 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3a:	83 ec 0c             	sub    $0xc,%esp
  800d3d:	50                   	push   %eax
  800d3e:	6a 0a                	push   $0xa
  800d40:	68 7f 22 80 00       	push   $0x80227f
  800d45:	6a 23                	push   $0x23
  800d47:	68 9c 22 80 00       	push   $0x80229c
  800d4c:	e8 e0 0d 00 00       	call   801b31 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
  800d5f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d62:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d67:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	89 df                	mov    %ebx,%edi
  800d74:	89 de                	mov    %ebx,%esi
  800d76:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	7e 17                	jle    800d93 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7c:	83 ec 0c             	sub    $0xc,%esp
  800d7f:	50                   	push   %eax
  800d80:	6a 09                	push   $0x9
  800d82:	68 7f 22 80 00       	push   $0x80227f
  800d87:	6a 23                	push   $0x23
  800d89:	68 9c 22 80 00       	push   $0x80229c
  800d8e:	e8 9e 0d 00 00       	call   801b31 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da1:	be 00 00 00 00       	mov    $0x0,%esi
  800da6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dcc:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	89 cb                	mov    %ecx,%ebx
  800dd6:	89 cf                	mov    %ecx,%edi
  800dd8:	89 ce                	mov    %ecx,%esi
  800dda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	7e 17                	jle    800df7 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de0:	83 ec 0c             	sub    $0xc,%esp
  800de3:	50                   	push   %eax
  800de4:	6a 0d                	push   $0xd
  800de6:	68 7f 22 80 00       	push   $0x80227f
  800deb:	6a 23                	push   $0x23
  800ded:	68 9c 22 80 00       	push   $0x80229c
  800df2:	e8 3a 0d 00 00       	call   801b31 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfa:	5b                   	pop    %ebx
  800dfb:	5e                   	pop    %esi
  800dfc:	5f                   	pop    %edi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e02:	8b 45 08             	mov    0x8(%ebp),%eax
  800e05:	05 00 00 00 30       	add    $0x30000000,%eax
  800e0a:	c1 e8 0c             	shr    $0xc,%eax
}
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e12:	8b 45 08             	mov    0x8(%ebp),%eax
  800e15:	05 00 00 00 30       	add    $0x30000000,%eax
  800e1a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e1f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e31:	89 c2                	mov    %eax,%edx
  800e33:	c1 ea 16             	shr    $0x16,%edx
  800e36:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e3d:	f6 c2 01             	test   $0x1,%dl
  800e40:	74 11                	je     800e53 <fd_alloc+0x2d>
  800e42:	89 c2                	mov    %eax,%edx
  800e44:	c1 ea 0c             	shr    $0xc,%edx
  800e47:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e4e:	f6 c2 01             	test   $0x1,%dl
  800e51:	75 09                	jne    800e5c <fd_alloc+0x36>
			*fd_store = fd;
  800e53:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e55:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5a:	eb 17                	jmp    800e73 <fd_alloc+0x4d>
  800e5c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e61:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e66:	75 c9                	jne    800e31 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e68:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e6e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e7b:	83 f8 1f             	cmp    $0x1f,%eax
  800e7e:	77 36                	ja     800eb6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e80:	c1 e0 0c             	shl    $0xc,%eax
  800e83:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e88:	89 c2                	mov    %eax,%edx
  800e8a:	c1 ea 16             	shr    $0x16,%edx
  800e8d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e94:	f6 c2 01             	test   $0x1,%dl
  800e97:	74 24                	je     800ebd <fd_lookup+0x48>
  800e99:	89 c2                	mov    %eax,%edx
  800e9b:	c1 ea 0c             	shr    $0xc,%edx
  800e9e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea5:	f6 c2 01             	test   $0x1,%dl
  800ea8:	74 1a                	je     800ec4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eaa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ead:	89 02                	mov    %eax,(%edx)
	return 0;
  800eaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb4:	eb 13                	jmp    800ec9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ebb:	eb 0c                	jmp    800ec9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ebd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec2:	eb 05                	jmp    800ec9 <fd_lookup+0x54>
  800ec4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 08             	sub    $0x8,%esp
  800ed1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed4:	ba 28 23 80 00       	mov    $0x802328,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ed9:	eb 13                	jmp    800eee <dev_lookup+0x23>
  800edb:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ede:	39 08                	cmp    %ecx,(%eax)
  800ee0:	75 0c                	jne    800eee <dev_lookup+0x23>
			*dev = devtab[i];
  800ee2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee7:	b8 00 00 00 00       	mov    $0x0,%eax
  800eec:	eb 2e                	jmp    800f1c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eee:	8b 02                	mov    (%edx),%eax
  800ef0:	85 c0                	test   %eax,%eax
  800ef2:	75 e7                	jne    800edb <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ef4:	a1 08 40 80 00       	mov    0x804008,%eax
  800ef9:	8b 40 48             	mov    0x48(%eax),%eax
  800efc:	83 ec 04             	sub    $0x4,%esp
  800eff:	51                   	push   %ecx
  800f00:	50                   	push   %eax
  800f01:	68 ac 22 80 00       	push   $0x8022ac
  800f06:	e8 55 f2 ff ff       	call   800160 <cprintf>
	*dev = 0;
  800f0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f14:	83 c4 10             	add    $0x10,%esp
  800f17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f1c:	c9                   	leave  
  800f1d:	c3                   	ret    

00800f1e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	56                   	push   %esi
  800f22:	53                   	push   %ebx
  800f23:	83 ec 10             	sub    $0x10,%esp
  800f26:	8b 75 08             	mov    0x8(%ebp),%esi
  800f29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2f:	50                   	push   %eax
  800f30:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f36:	c1 e8 0c             	shr    $0xc,%eax
  800f39:	50                   	push   %eax
  800f3a:	e8 36 ff ff ff       	call   800e75 <fd_lookup>
  800f3f:	83 c4 08             	add    $0x8,%esp
  800f42:	85 c0                	test   %eax,%eax
  800f44:	78 05                	js     800f4b <fd_close+0x2d>
	    || fd != fd2) 
  800f46:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f49:	74 0c                	je     800f57 <fd_close+0x39>
		return (must_exist ? r : 0); 
  800f4b:	84 db                	test   %bl,%bl
  800f4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f52:	0f 44 c2             	cmove  %edx,%eax
  800f55:	eb 41                	jmp    800f98 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f57:	83 ec 08             	sub    $0x8,%esp
  800f5a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f5d:	50                   	push   %eax
  800f5e:	ff 36                	pushl  (%esi)
  800f60:	e8 66 ff ff ff       	call   800ecb <dev_lookup>
  800f65:	89 c3                	mov    %eax,%ebx
  800f67:	83 c4 10             	add    $0x10,%esp
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	78 1a                	js     800f88 <fd_close+0x6a>
		if (dev->dev_close) 
  800f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f71:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  800f74:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	74 0b                	je     800f88 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f7d:	83 ec 0c             	sub    $0xc,%esp
  800f80:	56                   	push   %esi
  800f81:	ff d0                	call   *%eax
  800f83:	89 c3                	mov    %eax,%ebx
  800f85:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f88:	83 ec 08             	sub    $0x8,%esp
  800f8b:	56                   	push   %esi
  800f8c:	6a 00                	push   $0x0
  800f8e:	e8 00 fd ff ff       	call   800c93 <sys_page_unmap>
	return r;
  800f93:	83 c4 10             	add    $0x10,%esp
  800f96:	89 d8                	mov    %ebx,%eax
}
  800f98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f9b:	5b                   	pop    %ebx
  800f9c:	5e                   	pop    %esi
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    

00800f9f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa8:	50                   	push   %eax
  800fa9:	ff 75 08             	pushl  0x8(%ebp)
  800fac:	e8 c4 fe ff ff       	call   800e75 <fd_lookup>
  800fb1:	83 c4 08             	add    $0x8,%esp
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	78 10                	js     800fc8 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  800fb8:	83 ec 08             	sub    $0x8,%esp
  800fbb:	6a 01                	push   $0x1
  800fbd:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc0:	e8 59 ff ff ff       	call   800f1e <fd_close>
  800fc5:	83 c4 10             	add    $0x10,%esp
}
  800fc8:	c9                   	leave  
  800fc9:	c3                   	ret    

00800fca <close_all>:

void
close_all(void)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	53                   	push   %ebx
  800fce:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	53                   	push   %ebx
  800fda:	e8 c0 ff ff ff       	call   800f9f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fdf:	83 c3 01             	add    $0x1,%ebx
  800fe2:	83 c4 10             	add    $0x10,%esp
  800fe5:	83 fb 20             	cmp    $0x20,%ebx
  800fe8:	75 ec                	jne    800fd6 <close_all+0xc>
		close(i);
}
  800fea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fed:	c9                   	leave  
  800fee:	c3                   	ret    

00800fef <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fef:	55                   	push   %ebp
  800ff0:	89 e5                	mov    %esp,%ebp
  800ff2:	57                   	push   %edi
  800ff3:	56                   	push   %esi
  800ff4:	53                   	push   %ebx
  800ff5:	83 ec 2c             	sub    $0x2c,%esp
  800ff8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ffb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ffe:	50                   	push   %eax
  800fff:	ff 75 08             	pushl  0x8(%ebp)
  801002:	e8 6e fe ff ff       	call   800e75 <fd_lookup>
  801007:	83 c4 08             	add    $0x8,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	0f 88 c1 00 00 00    	js     8010d3 <dup+0xe4>
		return r;
	close(newfdnum);
  801012:	83 ec 0c             	sub    $0xc,%esp
  801015:	56                   	push   %esi
  801016:	e8 84 ff ff ff       	call   800f9f <close>

	newfd = INDEX2FD(newfdnum);
  80101b:	89 f3                	mov    %esi,%ebx
  80101d:	c1 e3 0c             	shl    $0xc,%ebx
  801020:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801026:	83 c4 04             	add    $0x4,%esp
  801029:	ff 75 e4             	pushl  -0x1c(%ebp)
  80102c:	e8 de fd ff ff       	call   800e0f <fd2data>
  801031:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801033:	89 1c 24             	mov    %ebx,(%esp)
  801036:	e8 d4 fd ff ff       	call   800e0f <fd2data>
  80103b:	83 c4 10             	add    $0x10,%esp
  80103e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801041:	89 f8                	mov    %edi,%eax
  801043:	c1 e8 16             	shr    $0x16,%eax
  801046:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80104d:	a8 01                	test   $0x1,%al
  80104f:	74 37                	je     801088 <dup+0x99>
  801051:	89 f8                	mov    %edi,%eax
  801053:	c1 e8 0c             	shr    $0xc,%eax
  801056:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105d:	f6 c2 01             	test   $0x1,%dl
  801060:	74 26                	je     801088 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801062:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801069:	83 ec 0c             	sub    $0xc,%esp
  80106c:	25 07 0e 00 00       	and    $0xe07,%eax
  801071:	50                   	push   %eax
  801072:	ff 75 d4             	pushl  -0x2c(%ebp)
  801075:	6a 00                	push   $0x0
  801077:	57                   	push   %edi
  801078:	6a 00                	push   $0x0
  80107a:	e8 d2 fb ff ff       	call   800c51 <sys_page_map>
  80107f:	89 c7                	mov    %eax,%edi
  801081:	83 c4 20             	add    $0x20,%esp
  801084:	85 c0                	test   %eax,%eax
  801086:	78 2e                	js     8010b6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801088:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80108b:	89 d0                	mov    %edx,%eax
  80108d:	c1 e8 0c             	shr    $0xc,%eax
  801090:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	25 07 0e 00 00       	and    $0xe07,%eax
  80109f:	50                   	push   %eax
  8010a0:	53                   	push   %ebx
  8010a1:	6a 00                	push   $0x0
  8010a3:	52                   	push   %edx
  8010a4:	6a 00                	push   $0x0
  8010a6:	e8 a6 fb ff ff       	call   800c51 <sys_page_map>
  8010ab:	89 c7                	mov    %eax,%edi
  8010ad:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010b0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b2:	85 ff                	test   %edi,%edi
  8010b4:	79 1d                	jns    8010d3 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010b6:	83 ec 08             	sub    $0x8,%esp
  8010b9:	53                   	push   %ebx
  8010ba:	6a 00                	push   $0x0
  8010bc:	e8 d2 fb ff ff       	call   800c93 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010c1:	83 c4 08             	add    $0x8,%esp
  8010c4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010c7:	6a 00                	push   $0x0
  8010c9:	e8 c5 fb ff ff       	call   800c93 <sys_page_unmap>
	return r;
  8010ce:	83 c4 10             	add    $0x10,%esp
  8010d1:	89 f8                	mov    %edi,%eax
}
  8010d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d6:	5b                   	pop    %ebx
  8010d7:	5e                   	pop    %esi
  8010d8:	5f                   	pop    %edi
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	53                   	push   %ebx
  8010df:	83 ec 14             	sub    $0x14,%esp
  8010e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010e8:	50                   	push   %eax
  8010e9:	53                   	push   %ebx
  8010ea:	e8 86 fd ff ff       	call   800e75 <fd_lookup>
  8010ef:	83 c4 08             	add    $0x8,%esp
  8010f2:	89 c2                	mov    %eax,%edx
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	78 6d                	js     801165 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f8:	83 ec 08             	sub    $0x8,%esp
  8010fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010fe:	50                   	push   %eax
  8010ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801102:	ff 30                	pushl  (%eax)
  801104:	e8 c2 fd ff ff       	call   800ecb <dev_lookup>
  801109:	83 c4 10             	add    $0x10,%esp
  80110c:	85 c0                	test   %eax,%eax
  80110e:	78 4c                	js     80115c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801110:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801113:	8b 42 08             	mov    0x8(%edx),%eax
  801116:	83 e0 03             	and    $0x3,%eax
  801119:	83 f8 01             	cmp    $0x1,%eax
  80111c:	75 21                	jne    80113f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80111e:	a1 08 40 80 00       	mov    0x804008,%eax
  801123:	8b 40 48             	mov    0x48(%eax),%eax
  801126:	83 ec 04             	sub    $0x4,%esp
  801129:	53                   	push   %ebx
  80112a:	50                   	push   %eax
  80112b:	68 ed 22 80 00       	push   $0x8022ed
  801130:	e8 2b f0 ff ff       	call   800160 <cprintf>
		return -E_INVAL;
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80113d:	eb 26                	jmp    801165 <read+0x8a>
	}
	if (!dev->dev_read)
  80113f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801142:	8b 40 08             	mov    0x8(%eax),%eax
  801145:	85 c0                	test   %eax,%eax
  801147:	74 17                	je     801160 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801149:	83 ec 04             	sub    $0x4,%esp
  80114c:	ff 75 10             	pushl  0x10(%ebp)
  80114f:	ff 75 0c             	pushl  0xc(%ebp)
  801152:	52                   	push   %edx
  801153:	ff d0                	call   *%eax
  801155:	89 c2                	mov    %eax,%edx
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	eb 09                	jmp    801165 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115c:	89 c2                	mov    %eax,%edx
  80115e:	eb 05                	jmp    801165 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801160:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801165:	89 d0                	mov    %edx,%eax
  801167:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116a:	c9                   	leave  
  80116b:	c3                   	ret    

0080116c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	57                   	push   %edi
  801170:	56                   	push   %esi
  801171:	53                   	push   %ebx
  801172:	83 ec 0c             	sub    $0xc,%esp
  801175:	8b 7d 08             	mov    0x8(%ebp),%edi
  801178:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80117b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801180:	eb 21                	jmp    8011a3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801182:	83 ec 04             	sub    $0x4,%esp
  801185:	89 f0                	mov    %esi,%eax
  801187:	29 d8                	sub    %ebx,%eax
  801189:	50                   	push   %eax
  80118a:	89 d8                	mov    %ebx,%eax
  80118c:	03 45 0c             	add    0xc(%ebp),%eax
  80118f:	50                   	push   %eax
  801190:	57                   	push   %edi
  801191:	e8 45 ff ff ff       	call   8010db <read>
		if (m < 0)
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	85 c0                	test   %eax,%eax
  80119b:	78 10                	js     8011ad <readn+0x41>
			return m;
		if (m == 0)
  80119d:	85 c0                	test   %eax,%eax
  80119f:	74 0a                	je     8011ab <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a1:	01 c3                	add    %eax,%ebx
  8011a3:	39 f3                	cmp    %esi,%ebx
  8011a5:	72 db                	jb     801182 <readn+0x16>
  8011a7:	89 d8                	mov    %ebx,%eax
  8011a9:	eb 02                	jmp    8011ad <readn+0x41>
  8011ab:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b0:	5b                   	pop    %ebx
  8011b1:	5e                   	pop    %esi
  8011b2:	5f                   	pop    %edi
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	53                   	push   %ebx
  8011b9:	83 ec 14             	sub    $0x14,%esp
  8011bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c2:	50                   	push   %eax
  8011c3:	53                   	push   %ebx
  8011c4:	e8 ac fc ff ff       	call   800e75 <fd_lookup>
  8011c9:	83 c4 08             	add    $0x8,%esp
  8011cc:	89 c2                	mov    %eax,%edx
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 68                	js     80123a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d2:	83 ec 08             	sub    $0x8,%esp
  8011d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d8:	50                   	push   %eax
  8011d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011dc:	ff 30                	pushl  (%eax)
  8011de:	e8 e8 fc ff ff       	call   800ecb <dev_lookup>
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	78 47                	js     801231 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f1:	75 21                	jne    801214 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f3:	a1 08 40 80 00       	mov    0x804008,%eax
  8011f8:	8b 40 48             	mov    0x48(%eax),%eax
  8011fb:	83 ec 04             	sub    $0x4,%esp
  8011fe:	53                   	push   %ebx
  8011ff:	50                   	push   %eax
  801200:	68 09 23 80 00       	push   $0x802309
  801205:	e8 56 ef ff ff       	call   800160 <cprintf>
		return -E_INVAL;
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801212:	eb 26                	jmp    80123a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801214:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801217:	8b 52 0c             	mov    0xc(%edx),%edx
  80121a:	85 d2                	test   %edx,%edx
  80121c:	74 17                	je     801235 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80121e:	83 ec 04             	sub    $0x4,%esp
  801221:	ff 75 10             	pushl  0x10(%ebp)
  801224:	ff 75 0c             	pushl  0xc(%ebp)
  801227:	50                   	push   %eax
  801228:	ff d2                	call   *%edx
  80122a:	89 c2                	mov    %eax,%edx
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	eb 09                	jmp    80123a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801231:	89 c2                	mov    %eax,%edx
  801233:	eb 05                	jmp    80123a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801235:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80123a:	89 d0                	mov    %edx,%eax
  80123c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123f:	c9                   	leave  
  801240:	c3                   	ret    

00801241 <seek>:

int
seek(int fdnum, off_t offset)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801247:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80124a:	50                   	push   %eax
  80124b:	ff 75 08             	pushl  0x8(%ebp)
  80124e:	e8 22 fc ff ff       	call   800e75 <fd_lookup>
  801253:	83 c4 08             	add    $0x8,%esp
  801256:	85 c0                	test   %eax,%eax
  801258:	78 0e                	js     801268 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80125a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80125d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801260:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801263:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801268:	c9                   	leave  
  801269:	c3                   	ret    

0080126a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	53                   	push   %ebx
  80126e:	83 ec 14             	sub    $0x14,%esp
  801271:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801274:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801277:	50                   	push   %eax
  801278:	53                   	push   %ebx
  801279:	e8 f7 fb ff ff       	call   800e75 <fd_lookup>
  80127e:	83 c4 08             	add    $0x8,%esp
  801281:	89 c2                	mov    %eax,%edx
  801283:	85 c0                	test   %eax,%eax
  801285:	78 65                	js     8012ec <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801287:	83 ec 08             	sub    $0x8,%esp
  80128a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128d:	50                   	push   %eax
  80128e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801291:	ff 30                	pushl  (%eax)
  801293:	e8 33 fc ff ff       	call   800ecb <dev_lookup>
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	85 c0                	test   %eax,%eax
  80129d:	78 44                	js     8012e3 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80129f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a6:	75 21                	jne    8012c9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012a8:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012ad:	8b 40 48             	mov    0x48(%eax),%eax
  8012b0:	83 ec 04             	sub    $0x4,%esp
  8012b3:	53                   	push   %ebx
  8012b4:	50                   	push   %eax
  8012b5:	68 cc 22 80 00       	push   $0x8022cc
  8012ba:	e8 a1 ee ff ff       	call   800160 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012bf:	83 c4 10             	add    $0x10,%esp
  8012c2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012c7:	eb 23                	jmp    8012ec <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012cc:	8b 52 18             	mov    0x18(%edx),%edx
  8012cf:	85 d2                	test   %edx,%edx
  8012d1:	74 14                	je     8012e7 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012d3:	83 ec 08             	sub    $0x8,%esp
  8012d6:	ff 75 0c             	pushl  0xc(%ebp)
  8012d9:	50                   	push   %eax
  8012da:	ff d2                	call   *%edx
  8012dc:	89 c2                	mov    %eax,%edx
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	eb 09                	jmp    8012ec <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e3:	89 c2                	mov    %eax,%edx
  8012e5:	eb 05                	jmp    8012ec <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012e7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012ec:	89 d0                	mov    %edx,%eax
  8012ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f1:	c9                   	leave  
  8012f2:	c3                   	ret    

008012f3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	53                   	push   %ebx
  8012f7:	83 ec 14             	sub    $0x14,%esp
  8012fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801300:	50                   	push   %eax
  801301:	ff 75 08             	pushl  0x8(%ebp)
  801304:	e8 6c fb ff ff       	call   800e75 <fd_lookup>
  801309:	83 c4 08             	add    $0x8,%esp
  80130c:	89 c2                	mov    %eax,%edx
  80130e:	85 c0                	test   %eax,%eax
  801310:	78 58                	js     80136a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801312:	83 ec 08             	sub    $0x8,%esp
  801315:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801318:	50                   	push   %eax
  801319:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131c:	ff 30                	pushl  (%eax)
  80131e:	e8 a8 fb ff ff       	call   800ecb <dev_lookup>
  801323:	83 c4 10             	add    $0x10,%esp
  801326:	85 c0                	test   %eax,%eax
  801328:	78 37                	js     801361 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80132a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801331:	74 32                	je     801365 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801333:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801336:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80133d:	00 00 00 
	stat->st_isdir = 0;
  801340:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801347:	00 00 00 
	stat->st_dev = dev;
  80134a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801350:	83 ec 08             	sub    $0x8,%esp
  801353:	53                   	push   %ebx
  801354:	ff 75 f0             	pushl  -0x10(%ebp)
  801357:	ff 50 14             	call   *0x14(%eax)
  80135a:	89 c2                	mov    %eax,%edx
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	eb 09                	jmp    80136a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801361:	89 c2                	mov    %eax,%edx
  801363:	eb 05                	jmp    80136a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801365:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80136a:	89 d0                	mov    %edx,%eax
  80136c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136f:	c9                   	leave  
  801370:	c3                   	ret    

00801371 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	56                   	push   %esi
  801375:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801376:	83 ec 08             	sub    $0x8,%esp
  801379:	6a 00                	push   $0x0
  80137b:	ff 75 08             	pushl  0x8(%ebp)
  80137e:	e8 2b 02 00 00       	call   8015ae <open>
  801383:	89 c3                	mov    %eax,%ebx
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 1b                	js     8013a7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80138c:	83 ec 08             	sub    $0x8,%esp
  80138f:	ff 75 0c             	pushl  0xc(%ebp)
  801392:	50                   	push   %eax
  801393:	e8 5b ff ff ff       	call   8012f3 <fstat>
  801398:	89 c6                	mov    %eax,%esi
	close(fd);
  80139a:	89 1c 24             	mov    %ebx,(%esp)
  80139d:	e8 fd fb ff ff       	call   800f9f <close>
	return r;
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	89 f0                	mov    %esi,%eax
}
  8013a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013aa:	5b                   	pop    %ebx
  8013ab:	5e                   	pop    %esi
  8013ac:	5d                   	pop    %ebp
  8013ad:	c3                   	ret    

008013ae <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	56                   	push   %esi
  8013b2:	53                   	push   %ebx
  8013b3:	89 c6                	mov    %eax,%esi
  8013b5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013b7:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8013be:	75 12                	jne    8013d2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013c0:	83 ec 0c             	sub    $0xc,%esp
  8013c3:	6a 01                	push   $0x1
  8013c5:	e8 6c 08 00 00       	call   801c36 <ipc_find_env>
  8013ca:	a3 04 40 80 00       	mov    %eax,0x804004
  8013cf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013d2:	6a 07                	push   $0x7
  8013d4:	68 00 50 80 00       	push   $0x805000
  8013d9:	56                   	push   %esi
  8013da:	ff 35 04 40 80 00    	pushl  0x804004
  8013e0:	e8 fb 07 00 00       	call   801be0 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8013e5:	83 c4 0c             	add    $0xc,%esp
  8013e8:	6a 00                	push   $0x0
  8013ea:	53                   	push   %ebx
  8013eb:	6a 00                	push   $0x0
  8013ed:	e8 85 07 00 00       	call   801b77 <ipc_recv>
}
  8013f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f5:	5b                   	pop    %ebx
  8013f6:	5e                   	pop    %esi
  8013f7:	5d                   	pop    %ebp
  8013f8:	c3                   	ret    

008013f9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013f9:	55                   	push   %ebp
  8013fa:	89 e5                	mov    %esp,%ebp
  8013fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801402:	8b 40 0c             	mov    0xc(%eax),%eax
  801405:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80140a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801412:	ba 00 00 00 00       	mov    $0x0,%edx
  801417:	b8 02 00 00 00       	mov    $0x2,%eax
  80141c:	e8 8d ff ff ff       	call   8013ae <fsipc>
}
  801421:	c9                   	leave  
  801422:	c3                   	ret    

00801423 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801429:	8b 45 08             	mov    0x8(%ebp),%eax
  80142c:	8b 40 0c             	mov    0xc(%eax),%eax
  80142f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801434:	ba 00 00 00 00       	mov    $0x0,%edx
  801439:	b8 06 00 00 00       	mov    $0x6,%eax
  80143e:	e8 6b ff ff ff       	call   8013ae <fsipc>
}
  801443:	c9                   	leave  
  801444:	c3                   	ret    

00801445 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	53                   	push   %ebx
  801449:	83 ec 04             	sub    $0x4,%esp
  80144c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80144f:	8b 45 08             	mov    0x8(%ebp),%eax
  801452:	8b 40 0c             	mov    0xc(%eax),%eax
  801455:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80145a:	ba 00 00 00 00       	mov    $0x0,%edx
  80145f:	b8 05 00 00 00       	mov    $0x5,%eax
  801464:	e8 45 ff ff ff       	call   8013ae <fsipc>
  801469:	85 c0                	test   %eax,%eax
  80146b:	78 2c                	js     801499 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80146d:	83 ec 08             	sub    $0x8,%esp
  801470:	68 00 50 80 00       	push   $0x805000
  801475:	53                   	push   %ebx
  801476:	e8 19 f3 ff ff       	call   800794 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80147b:	a1 80 50 80 00       	mov    0x805080,%eax
  801480:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801486:	a1 84 50 80 00       	mov    0x805084,%eax
  80148b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801499:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149c:	c9                   	leave  
  80149d:	c3                   	ret    

0080149e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	53                   	push   %ebx
  8014a2:	83 ec 08             	sub    $0x8,%esp
  8014a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8014a8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014ad:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8014b2:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  8014c0:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014c6:	53                   	push   %ebx
  8014c7:	ff 75 0c             	pushl  0xc(%ebp)
  8014ca:	68 08 50 80 00       	push   $0x805008
  8014cf:	e8 52 f4 ff ff       	call   800926 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8014d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d9:	b8 04 00 00 00       	mov    $0x4,%eax
  8014de:	e8 cb fe ff ff       	call   8013ae <fsipc>
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 3d                	js     801527 <devfile_write+0x89>
		return r;

	assert(r <= n);
  8014ea:	39 d8                	cmp    %ebx,%eax
  8014ec:	76 19                	jbe    801507 <devfile_write+0x69>
  8014ee:	68 38 23 80 00       	push   $0x802338
  8014f3:	68 3f 23 80 00       	push   $0x80233f
  8014f8:	68 9f 00 00 00       	push   $0x9f
  8014fd:	68 54 23 80 00       	push   $0x802354
  801502:	e8 2a 06 00 00       	call   801b31 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801507:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80150c:	76 19                	jbe    801527 <devfile_write+0x89>
  80150e:	68 6c 23 80 00       	push   $0x80236c
  801513:	68 3f 23 80 00       	push   $0x80233f
  801518:	68 a0 00 00 00       	push   $0xa0
  80151d:	68 54 23 80 00       	push   $0x802354
  801522:	e8 0a 06 00 00       	call   801b31 <_panic>

	return r;
}
  801527:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152a:	c9                   	leave  
  80152b:	c3                   	ret    

0080152c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	56                   	push   %esi
  801530:	53                   	push   %ebx
  801531:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801534:	8b 45 08             	mov    0x8(%ebp),%eax
  801537:	8b 40 0c             	mov    0xc(%eax),%eax
  80153a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80153f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801545:	ba 00 00 00 00       	mov    $0x0,%edx
  80154a:	b8 03 00 00 00       	mov    $0x3,%eax
  80154f:	e8 5a fe ff ff       	call   8013ae <fsipc>
  801554:	89 c3                	mov    %eax,%ebx
  801556:	85 c0                	test   %eax,%eax
  801558:	78 4b                	js     8015a5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80155a:	39 c6                	cmp    %eax,%esi
  80155c:	73 16                	jae    801574 <devfile_read+0x48>
  80155e:	68 38 23 80 00       	push   $0x802338
  801563:	68 3f 23 80 00       	push   $0x80233f
  801568:	6a 7e                	push   $0x7e
  80156a:	68 54 23 80 00       	push   $0x802354
  80156f:	e8 bd 05 00 00       	call   801b31 <_panic>
	assert(r <= PGSIZE);
  801574:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801579:	7e 16                	jle    801591 <devfile_read+0x65>
  80157b:	68 5f 23 80 00       	push   $0x80235f
  801580:	68 3f 23 80 00       	push   $0x80233f
  801585:	6a 7f                	push   $0x7f
  801587:	68 54 23 80 00       	push   $0x802354
  80158c:	e8 a0 05 00 00       	call   801b31 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801591:	83 ec 04             	sub    $0x4,%esp
  801594:	50                   	push   %eax
  801595:	68 00 50 80 00       	push   $0x805000
  80159a:	ff 75 0c             	pushl  0xc(%ebp)
  80159d:	e8 84 f3 ff ff       	call   800926 <memmove>
	return r;
  8015a2:	83 c4 10             	add    $0x10,%esp
}
  8015a5:	89 d8                	mov    %ebx,%eax
  8015a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015aa:	5b                   	pop    %ebx
  8015ab:	5e                   	pop    %esi
  8015ac:	5d                   	pop    %ebp
  8015ad:	c3                   	ret    

008015ae <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015ae:	55                   	push   %ebp
  8015af:	89 e5                	mov    %esp,%ebp
  8015b1:	53                   	push   %ebx
  8015b2:	83 ec 20             	sub    $0x20,%esp
  8015b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015b8:	53                   	push   %ebx
  8015b9:	e8 9d f1 ff ff       	call   80075b <strlen>
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015c6:	7f 67                	jg     80162f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015c8:	83 ec 0c             	sub    $0xc,%esp
  8015cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ce:	50                   	push   %eax
  8015cf:	e8 52 f8 ff ff       	call   800e26 <fd_alloc>
  8015d4:	83 c4 10             	add    $0x10,%esp
		return r;
  8015d7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	78 57                	js     801634 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	53                   	push   %ebx
  8015e1:	68 00 50 80 00       	push   $0x805000
  8015e6:	e8 a9 f1 ff ff       	call   800794 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ee:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8015fb:	e8 ae fd ff ff       	call   8013ae <fsipc>
  801600:	89 c3                	mov    %eax,%ebx
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	85 c0                	test   %eax,%eax
  801607:	79 14                	jns    80161d <open+0x6f>
		fd_close(fd, 0);
  801609:	83 ec 08             	sub    $0x8,%esp
  80160c:	6a 00                	push   $0x0
  80160e:	ff 75 f4             	pushl  -0xc(%ebp)
  801611:	e8 08 f9 ff ff       	call   800f1e <fd_close>
		return r;
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	89 da                	mov    %ebx,%edx
  80161b:	eb 17                	jmp    801634 <open+0x86>
	}

	return fd2num(fd);
  80161d:	83 ec 0c             	sub    $0xc,%esp
  801620:	ff 75 f4             	pushl  -0xc(%ebp)
  801623:	e8 d7 f7 ff ff       	call   800dff <fd2num>
  801628:	89 c2                	mov    %eax,%edx
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	eb 05                	jmp    801634 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80162f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801634:	89 d0                	mov    %edx,%eax
  801636:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801639:	c9                   	leave  
  80163a:	c3                   	ret    

0080163b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801641:	ba 00 00 00 00       	mov    $0x0,%edx
  801646:	b8 08 00 00 00       	mov    $0x8,%eax
  80164b:	e8 5e fd ff ff       	call   8013ae <fsipc>
}
  801650:	c9                   	leave  
  801651:	c3                   	ret    

00801652 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	56                   	push   %esi
  801656:	53                   	push   %ebx
  801657:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80165a:	83 ec 0c             	sub    $0xc,%esp
  80165d:	ff 75 08             	pushl  0x8(%ebp)
  801660:	e8 aa f7 ff ff       	call   800e0f <fd2data>
  801665:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801667:	83 c4 08             	add    $0x8,%esp
  80166a:	68 99 23 80 00       	push   $0x802399
  80166f:	53                   	push   %ebx
  801670:	e8 1f f1 ff ff       	call   800794 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801675:	8b 46 04             	mov    0x4(%esi),%eax
  801678:	2b 06                	sub    (%esi),%eax
  80167a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801680:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801687:	00 00 00 
	stat->st_dev = &devpipe;
  80168a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801691:	30 80 00 
	return 0;
}
  801694:	b8 00 00 00 00       	mov    $0x0,%eax
  801699:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80169c:	5b                   	pop    %ebx
  80169d:	5e                   	pop    %esi
  80169e:	5d                   	pop    %ebp
  80169f:	c3                   	ret    

008016a0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	53                   	push   %ebx
  8016a4:	83 ec 0c             	sub    $0xc,%esp
  8016a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016aa:	53                   	push   %ebx
  8016ab:	6a 00                	push   $0x0
  8016ad:	e8 e1 f5 ff ff       	call   800c93 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016b2:	89 1c 24             	mov    %ebx,(%esp)
  8016b5:	e8 55 f7 ff ff       	call   800e0f <fd2data>
  8016ba:	83 c4 08             	add    $0x8,%esp
  8016bd:	50                   	push   %eax
  8016be:	6a 00                	push   $0x0
  8016c0:	e8 ce f5 ff ff       	call   800c93 <sys_page_unmap>
}
  8016c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c8:	c9                   	leave  
  8016c9:	c3                   	ret    

008016ca <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	57                   	push   %edi
  8016ce:	56                   	push   %esi
  8016cf:	53                   	push   %ebx
  8016d0:	83 ec 1c             	sub    $0x1c,%esp
  8016d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016d6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016d8:	a1 08 40 80 00       	mov    0x804008,%eax
  8016dd:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016e0:	83 ec 0c             	sub    $0xc,%esp
  8016e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8016e6:	e8 84 05 00 00       	call   801c6f <pageref>
  8016eb:	89 c3                	mov    %eax,%ebx
  8016ed:	89 3c 24             	mov    %edi,(%esp)
  8016f0:	e8 7a 05 00 00       	call   801c6f <pageref>
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	39 c3                	cmp    %eax,%ebx
  8016fa:	0f 94 c1             	sete   %cl
  8016fd:	0f b6 c9             	movzbl %cl,%ecx
  801700:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801703:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801709:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80170c:	39 ce                	cmp    %ecx,%esi
  80170e:	74 1b                	je     80172b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801710:	39 c3                	cmp    %eax,%ebx
  801712:	75 c4                	jne    8016d8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801714:	8b 42 58             	mov    0x58(%edx),%eax
  801717:	ff 75 e4             	pushl  -0x1c(%ebp)
  80171a:	50                   	push   %eax
  80171b:	56                   	push   %esi
  80171c:	68 a0 23 80 00       	push   $0x8023a0
  801721:	e8 3a ea ff ff       	call   800160 <cprintf>
  801726:	83 c4 10             	add    $0x10,%esp
  801729:	eb ad                	jmp    8016d8 <_pipeisclosed+0xe>
	}
}
  80172b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80172e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801731:	5b                   	pop    %ebx
  801732:	5e                   	pop    %esi
  801733:	5f                   	pop    %edi
  801734:	5d                   	pop    %ebp
  801735:	c3                   	ret    

00801736 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	57                   	push   %edi
  80173a:	56                   	push   %esi
  80173b:	53                   	push   %ebx
  80173c:	83 ec 28             	sub    $0x28,%esp
  80173f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801742:	56                   	push   %esi
  801743:	e8 c7 f6 ff ff       	call   800e0f <fd2data>
  801748:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	bf 00 00 00 00       	mov    $0x0,%edi
  801752:	eb 4b                	jmp    80179f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801754:	89 da                	mov    %ebx,%edx
  801756:	89 f0                	mov    %esi,%eax
  801758:	e8 6d ff ff ff       	call   8016ca <_pipeisclosed>
  80175d:	85 c0                	test   %eax,%eax
  80175f:	75 48                	jne    8017a9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801761:	e8 89 f4 ff ff       	call   800bef <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801766:	8b 43 04             	mov    0x4(%ebx),%eax
  801769:	8b 0b                	mov    (%ebx),%ecx
  80176b:	8d 51 20             	lea    0x20(%ecx),%edx
  80176e:	39 d0                	cmp    %edx,%eax
  801770:	73 e2                	jae    801754 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801772:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801775:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801779:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80177c:	89 c2                	mov    %eax,%edx
  80177e:	c1 fa 1f             	sar    $0x1f,%edx
  801781:	89 d1                	mov    %edx,%ecx
  801783:	c1 e9 1b             	shr    $0x1b,%ecx
  801786:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801789:	83 e2 1f             	and    $0x1f,%edx
  80178c:	29 ca                	sub    %ecx,%edx
  80178e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801792:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801796:	83 c0 01             	add    $0x1,%eax
  801799:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80179c:	83 c7 01             	add    $0x1,%edi
  80179f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017a2:	75 c2                	jne    801766 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a7:	eb 05                	jmp    8017ae <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017a9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b1:	5b                   	pop    %ebx
  8017b2:	5e                   	pop    %esi
  8017b3:	5f                   	pop    %edi
  8017b4:	5d                   	pop    %ebp
  8017b5:	c3                   	ret    

008017b6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	57                   	push   %edi
  8017ba:	56                   	push   %esi
  8017bb:	53                   	push   %ebx
  8017bc:	83 ec 18             	sub    $0x18,%esp
  8017bf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017c2:	57                   	push   %edi
  8017c3:	e8 47 f6 ff ff       	call   800e0f <fd2data>
  8017c8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ca:	83 c4 10             	add    $0x10,%esp
  8017cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017d2:	eb 3d                	jmp    801811 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017d4:	85 db                	test   %ebx,%ebx
  8017d6:	74 04                	je     8017dc <devpipe_read+0x26>
				return i;
  8017d8:	89 d8                	mov    %ebx,%eax
  8017da:	eb 44                	jmp    801820 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017dc:	89 f2                	mov    %esi,%edx
  8017de:	89 f8                	mov    %edi,%eax
  8017e0:	e8 e5 fe ff ff       	call   8016ca <_pipeisclosed>
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	75 32                	jne    80181b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017e9:	e8 01 f4 ff ff       	call   800bef <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017ee:	8b 06                	mov    (%esi),%eax
  8017f0:	3b 46 04             	cmp    0x4(%esi),%eax
  8017f3:	74 df                	je     8017d4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017f5:	99                   	cltd   
  8017f6:	c1 ea 1b             	shr    $0x1b,%edx
  8017f9:	01 d0                	add    %edx,%eax
  8017fb:	83 e0 1f             	and    $0x1f,%eax
  8017fe:	29 d0                	sub    %edx,%eax
  801800:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801805:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801808:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80180b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80180e:	83 c3 01             	add    $0x1,%ebx
  801811:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801814:	75 d8                	jne    8017ee <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801816:	8b 45 10             	mov    0x10(%ebp),%eax
  801819:	eb 05                	jmp    801820 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80181b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801820:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801823:	5b                   	pop    %ebx
  801824:	5e                   	pop    %esi
  801825:	5f                   	pop    %edi
  801826:	5d                   	pop    %ebp
  801827:	c3                   	ret    

00801828 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	56                   	push   %esi
  80182c:	53                   	push   %ebx
  80182d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801830:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801833:	50                   	push   %eax
  801834:	e8 ed f5 ff ff       	call   800e26 <fd_alloc>
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	89 c2                	mov    %eax,%edx
  80183e:	85 c0                	test   %eax,%eax
  801840:	0f 88 2c 01 00 00    	js     801972 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801846:	83 ec 04             	sub    $0x4,%esp
  801849:	68 07 04 00 00       	push   $0x407
  80184e:	ff 75 f4             	pushl  -0xc(%ebp)
  801851:	6a 00                	push   $0x0
  801853:	e8 b6 f3 ff ff       	call   800c0e <sys_page_alloc>
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	89 c2                	mov    %eax,%edx
  80185d:	85 c0                	test   %eax,%eax
  80185f:	0f 88 0d 01 00 00    	js     801972 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801865:	83 ec 0c             	sub    $0xc,%esp
  801868:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80186b:	50                   	push   %eax
  80186c:	e8 b5 f5 ff ff       	call   800e26 <fd_alloc>
  801871:	89 c3                	mov    %eax,%ebx
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	85 c0                	test   %eax,%eax
  801878:	0f 88 e2 00 00 00    	js     801960 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80187e:	83 ec 04             	sub    $0x4,%esp
  801881:	68 07 04 00 00       	push   $0x407
  801886:	ff 75 f0             	pushl  -0x10(%ebp)
  801889:	6a 00                	push   $0x0
  80188b:	e8 7e f3 ff ff       	call   800c0e <sys_page_alloc>
  801890:	89 c3                	mov    %eax,%ebx
  801892:	83 c4 10             	add    $0x10,%esp
  801895:	85 c0                	test   %eax,%eax
  801897:	0f 88 c3 00 00 00    	js     801960 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80189d:	83 ec 0c             	sub    $0xc,%esp
  8018a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a3:	e8 67 f5 ff ff       	call   800e0f <fd2data>
  8018a8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018aa:	83 c4 0c             	add    $0xc,%esp
  8018ad:	68 07 04 00 00       	push   $0x407
  8018b2:	50                   	push   %eax
  8018b3:	6a 00                	push   $0x0
  8018b5:	e8 54 f3 ff ff       	call   800c0e <sys_page_alloc>
  8018ba:	89 c3                	mov    %eax,%ebx
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	85 c0                	test   %eax,%eax
  8018c1:	0f 88 89 00 00 00    	js     801950 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018c7:	83 ec 0c             	sub    $0xc,%esp
  8018ca:	ff 75 f0             	pushl  -0x10(%ebp)
  8018cd:	e8 3d f5 ff ff       	call   800e0f <fd2data>
  8018d2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018d9:	50                   	push   %eax
  8018da:	6a 00                	push   $0x0
  8018dc:	56                   	push   %esi
  8018dd:	6a 00                	push   $0x0
  8018df:	e8 6d f3 ff ff       	call   800c51 <sys_page_map>
  8018e4:	89 c3                	mov    %eax,%ebx
  8018e6:	83 c4 20             	add    $0x20,%esp
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	78 55                	js     801942 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018ed:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018fb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801902:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801908:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80190d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801910:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801917:	83 ec 0c             	sub    $0xc,%esp
  80191a:	ff 75 f4             	pushl  -0xc(%ebp)
  80191d:	e8 dd f4 ff ff       	call   800dff <fd2num>
  801922:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801925:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801927:	83 c4 04             	add    $0x4,%esp
  80192a:	ff 75 f0             	pushl  -0x10(%ebp)
  80192d:	e8 cd f4 ff ff       	call   800dff <fd2num>
  801932:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801935:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	ba 00 00 00 00       	mov    $0x0,%edx
  801940:	eb 30                	jmp    801972 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801942:	83 ec 08             	sub    $0x8,%esp
  801945:	56                   	push   %esi
  801946:	6a 00                	push   $0x0
  801948:	e8 46 f3 ff ff       	call   800c93 <sys_page_unmap>
  80194d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801950:	83 ec 08             	sub    $0x8,%esp
  801953:	ff 75 f0             	pushl  -0x10(%ebp)
  801956:	6a 00                	push   $0x0
  801958:	e8 36 f3 ff ff       	call   800c93 <sys_page_unmap>
  80195d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801960:	83 ec 08             	sub    $0x8,%esp
  801963:	ff 75 f4             	pushl  -0xc(%ebp)
  801966:	6a 00                	push   $0x0
  801968:	e8 26 f3 ff ff       	call   800c93 <sys_page_unmap>
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801972:	89 d0                	mov    %edx,%eax
  801974:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801977:	5b                   	pop    %ebx
  801978:	5e                   	pop    %esi
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801981:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801984:	50                   	push   %eax
  801985:	ff 75 08             	pushl  0x8(%ebp)
  801988:	e8 e8 f4 ff ff       	call   800e75 <fd_lookup>
  80198d:	83 c4 10             	add    $0x10,%esp
  801990:	85 c0                	test   %eax,%eax
  801992:	78 18                	js     8019ac <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801994:	83 ec 0c             	sub    $0xc,%esp
  801997:	ff 75 f4             	pushl  -0xc(%ebp)
  80199a:	e8 70 f4 ff ff       	call   800e0f <fd2data>
	return _pipeisclosed(fd, p);
  80199f:	89 c2                	mov    %eax,%edx
  8019a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a4:	e8 21 fd ff ff       	call   8016ca <_pipeisclosed>
  8019a9:	83 c4 10             	add    $0x10,%esp
}
  8019ac:	c9                   	leave  
  8019ad:	c3                   	ret    

008019ae <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019ae:	55                   	push   %ebp
  8019af:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b6:	5d                   	pop    %ebp
  8019b7:	c3                   	ret    

008019b8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019be:	68 b8 23 80 00       	push   $0x8023b8
  8019c3:	ff 75 0c             	pushl  0xc(%ebp)
  8019c6:	e8 c9 ed ff ff       	call   800794 <strcpy>
	return 0;
}
  8019cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d0:	c9                   	leave  
  8019d1:	c3                   	ret    

008019d2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	57                   	push   %edi
  8019d6:	56                   	push   %esi
  8019d7:	53                   	push   %ebx
  8019d8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019de:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019e3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019e9:	eb 2d                	jmp    801a18 <devcons_write+0x46>
		m = n - tot;
  8019eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019ee:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019f0:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019f3:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019f8:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019fb:	83 ec 04             	sub    $0x4,%esp
  8019fe:	53                   	push   %ebx
  8019ff:	03 45 0c             	add    0xc(%ebp),%eax
  801a02:	50                   	push   %eax
  801a03:	57                   	push   %edi
  801a04:	e8 1d ef ff ff       	call   800926 <memmove>
		sys_cputs(buf, m);
  801a09:	83 c4 08             	add    $0x8,%esp
  801a0c:	53                   	push   %ebx
  801a0d:	57                   	push   %edi
  801a0e:	e8 3f f1 ff ff       	call   800b52 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a13:	01 de                	add    %ebx,%esi
  801a15:	83 c4 10             	add    $0x10,%esp
  801a18:	89 f0                	mov    %esi,%eax
  801a1a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a1d:	72 cc                	jb     8019eb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a22:	5b                   	pop    %ebx
  801a23:	5e                   	pop    %esi
  801a24:	5f                   	pop    %edi
  801a25:	5d                   	pop    %ebp
  801a26:	c3                   	ret    

00801a27 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	83 ec 08             	sub    $0x8,%esp
  801a2d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a32:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a36:	74 2a                	je     801a62 <devcons_read+0x3b>
  801a38:	eb 05                	jmp    801a3f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a3a:	e8 b0 f1 ff ff       	call   800bef <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a3f:	e8 2c f1 ff ff       	call   800b70 <sys_cgetc>
  801a44:	85 c0                	test   %eax,%eax
  801a46:	74 f2                	je     801a3a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	78 16                	js     801a62 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a4c:	83 f8 04             	cmp    $0x4,%eax
  801a4f:	74 0c                	je     801a5d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a51:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a54:	88 02                	mov    %al,(%edx)
	return 1;
  801a56:	b8 01 00 00 00       	mov    $0x1,%eax
  801a5b:	eb 05                	jmp    801a62 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a5d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a62:	c9                   	leave  
  801a63:	c3                   	ret    

00801a64 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a70:	6a 01                	push   $0x1
  801a72:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a75:	50                   	push   %eax
  801a76:	e8 d7 f0 ff ff       	call   800b52 <sys_cputs>
}
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <getchar>:

int
getchar(void)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a86:	6a 01                	push   $0x1
  801a88:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a8b:	50                   	push   %eax
  801a8c:	6a 00                	push   $0x0
  801a8e:	e8 48 f6 ff ff       	call   8010db <read>
	if (r < 0)
  801a93:	83 c4 10             	add    $0x10,%esp
  801a96:	85 c0                	test   %eax,%eax
  801a98:	78 0f                	js     801aa9 <getchar+0x29>
		return r;
	if (r < 1)
  801a9a:	85 c0                	test   %eax,%eax
  801a9c:	7e 06                	jle    801aa4 <getchar+0x24>
		return -E_EOF;
	return c;
  801a9e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801aa2:	eb 05                	jmp    801aa9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801aa4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801aa9:	c9                   	leave  
  801aaa:	c3                   	ret    

00801aab <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ab1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab4:	50                   	push   %eax
  801ab5:	ff 75 08             	pushl  0x8(%ebp)
  801ab8:	e8 b8 f3 ff ff       	call   800e75 <fd_lookup>
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	78 11                	js     801ad5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801acd:	39 10                	cmp    %edx,(%eax)
  801acf:	0f 94 c0             	sete   %al
  801ad2:	0f b6 c0             	movzbl %al,%eax
}
  801ad5:	c9                   	leave  
  801ad6:	c3                   	ret    

00801ad7 <opencons>:

int
opencons(void)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801add:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae0:	50                   	push   %eax
  801ae1:	e8 40 f3 ff ff       	call   800e26 <fd_alloc>
  801ae6:	83 c4 10             	add    $0x10,%esp
		return r;
  801ae9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	78 3e                	js     801b2d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801aef:	83 ec 04             	sub    $0x4,%esp
  801af2:	68 07 04 00 00       	push   $0x407
  801af7:	ff 75 f4             	pushl  -0xc(%ebp)
  801afa:	6a 00                	push   $0x0
  801afc:	e8 0d f1 ff ff       	call   800c0e <sys_page_alloc>
  801b01:	83 c4 10             	add    $0x10,%esp
		return r;
  801b04:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b06:	85 c0                	test   %eax,%eax
  801b08:	78 23                	js     801b2d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b0a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b13:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b18:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b1f:	83 ec 0c             	sub    $0xc,%esp
  801b22:	50                   	push   %eax
  801b23:	e8 d7 f2 ff ff       	call   800dff <fd2num>
  801b28:	89 c2                	mov    %eax,%edx
  801b2a:	83 c4 10             	add    $0x10,%esp
}
  801b2d:	89 d0                	mov    %edx,%eax
  801b2f:	c9                   	leave  
  801b30:	c3                   	ret    

00801b31 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b31:	55                   	push   %ebp
  801b32:	89 e5                	mov    %esp,%ebp
  801b34:	56                   	push   %esi
  801b35:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b36:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b39:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b3f:	e8 8c f0 ff ff       	call   800bd0 <sys_getenvid>
  801b44:	83 ec 0c             	sub    $0xc,%esp
  801b47:	ff 75 0c             	pushl  0xc(%ebp)
  801b4a:	ff 75 08             	pushl  0x8(%ebp)
  801b4d:	56                   	push   %esi
  801b4e:	50                   	push   %eax
  801b4f:	68 c4 23 80 00       	push   $0x8023c4
  801b54:	e8 07 e6 ff ff       	call   800160 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b59:	83 c4 18             	add    $0x18,%esp
  801b5c:	53                   	push   %ebx
  801b5d:	ff 75 10             	pushl  0x10(%ebp)
  801b60:	e8 aa e5 ff ff       	call   80010f <vcprintf>
	cprintf("\n");
  801b65:	c7 04 24 b1 23 80 00 	movl   $0x8023b1,(%esp)
  801b6c:	e8 ef e5 ff ff       	call   800160 <cprintf>
  801b71:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b74:	cc                   	int3   
  801b75:	eb fd                	jmp    801b74 <_panic+0x43>

00801b77 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	56                   	push   %esi
  801b7b:	53                   	push   %ebx
  801b7c:	8b 75 08             	mov    0x8(%ebp),%esi
  801b7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b82:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801b85:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801b87:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b8c:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801b8f:	83 ec 0c             	sub    $0xc,%esp
  801b92:	50                   	push   %eax
  801b93:	e8 26 f2 ff ff       	call   800dbe <sys_ipc_recv>
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	79 16                	jns    801bb5 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801b9f:	85 f6                	test   %esi,%esi
  801ba1:	74 06                	je     801ba9 <ipc_recv+0x32>
			*from_env_store = 0;
  801ba3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801ba9:	85 db                	test   %ebx,%ebx
  801bab:	74 2c                	je     801bd9 <ipc_recv+0x62>
			*perm_store = 0;
  801bad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801bb3:	eb 24                	jmp    801bd9 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801bb5:	85 f6                	test   %esi,%esi
  801bb7:	74 0a                	je     801bc3 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801bb9:	a1 08 40 80 00       	mov    0x804008,%eax
  801bbe:	8b 40 74             	mov    0x74(%eax),%eax
  801bc1:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801bc3:	85 db                	test   %ebx,%ebx
  801bc5:	74 0a                	je     801bd1 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801bc7:	a1 08 40 80 00       	mov    0x804008,%eax
  801bcc:	8b 40 78             	mov    0x78(%eax),%eax
  801bcf:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801bd1:	a1 08 40 80 00       	mov    0x804008,%eax
  801bd6:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bd9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bdc:	5b                   	pop    %ebx
  801bdd:	5e                   	pop    %esi
  801bde:	5d                   	pop    %ebp
  801bdf:	c3                   	ret    

00801be0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	57                   	push   %edi
  801be4:	56                   	push   %esi
  801be5:	53                   	push   %ebx
  801be6:	83 ec 0c             	sub    $0xc,%esp
  801be9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bec:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801bf2:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801bf4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bf9:	0f 44 d8             	cmove  %eax,%ebx
  801bfc:	eb 1e                	jmp    801c1c <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801bfe:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c01:	74 14                	je     801c17 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801c03:	83 ec 04             	sub    $0x4,%esp
  801c06:	68 e8 23 80 00       	push   $0x8023e8
  801c0b:	6a 44                	push   $0x44
  801c0d:	68 14 24 80 00       	push   $0x802414
  801c12:	e8 1a ff ff ff       	call   801b31 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801c17:	e8 d3 ef ff ff       	call   800bef <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c1c:	ff 75 14             	pushl  0x14(%ebp)
  801c1f:	53                   	push   %ebx
  801c20:	56                   	push   %esi
  801c21:	57                   	push   %edi
  801c22:	e8 74 f1 ff ff       	call   800d9b <sys_ipc_try_send>
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	78 d0                	js     801bfe <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801c2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c31:	5b                   	pop    %ebx
  801c32:	5e                   	pop    %esi
  801c33:	5f                   	pop    %edi
  801c34:	5d                   	pop    %ebp
  801c35:	c3                   	ret    

00801c36 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c3c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c41:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c44:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c4a:	8b 52 50             	mov    0x50(%edx),%edx
  801c4d:	39 ca                	cmp    %ecx,%edx
  801c4f:	75 0d                	jne    801c5e <ipc_find_env+0x28>
			return envs[i].env_id;
  801c51:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c54:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c59:	8b 40 48             	mov    0x48(%eax),%eax
  801c5c:	eb 0f                	jmp    801c6d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c5e:	83 c0 01             	add    $0x1,%eax
  801c61:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c66:	75 d9                	jne    801c41 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c6d:	5d                   	pop    %ebp
  801c6e:	c3                   	ret    

00801c6f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c75:	89 d0                	mov    %edx,%eax
  801c77:	c1 e8 16             	shr    $0x16,%eax
  801c7a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c81:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c86:	f6 c1 01             	test   $0x1,%cl
  801c89:	74 1d                	je     801ca8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c8b:	c1 ea 0c             	shr    $0xc,%edx
  801c8e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c95:	f6 c2 01             	test   $0x1,%dl
  801c98:	74 0e                	je     801ca8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c9a:	c1 ea 0c             	shr    $0xc,%edx
  801c9d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ca4:	ef 
  801ca5:	0f b7 c0             	movzwl %ax,%eax
}
  801ca8:	5d                   	pop    %ebp
  801ca9:	c3                   	ret    
  801caa:	66 90                	xchg   %ax,%ax
  801cac:	66 90                	xchg   %ax,%ax
  801cae:	66 90                	xchg   %ax,%ax

00801cb0 <__udivdi3>:
  801cb0:	55                   	push   %ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
  801cb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801cbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801cbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801cc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cc7:	85 f6                	test   %esi,%esi
  801cc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ccd:	89 ca                	mov    %ecx,%edx
  801ccf:	89 f8                	mov    %edi,%eax
  801cd1:	75 3d                	jne    801d10 <__udivdi3+0x60>
  801cd3:	39 cf                	cmp    %ecx,%edi
  801cd5:	0f 87 c5 00 00 00    	ja     801da0 <__udivdi3+0xf0>
  801cdb:	85 ff                	test   %edi,%edi
  801cdd:	89 fd                	mov    %edi,%ebp
  801cdf:	75 0b                	jne    801cec <__udivdi3+0x3c>
  801ce1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce6:	31 d2                	xor    %edx,%edx
  801ce8:	f7 f7                	div    %edi
  801cea:	89 c5                	mov    %eax,%ebp
  801cec:	89 c8                	mov    %ecx,%eax
  801cee:	31 d2                	xor    %edx,%edx
  801cf0:	f7 f5                	div    %ebp
  801cf2:	89 c1                	mov    %eax,%ecx
  801cf4:	89 d8                	mov    %ebx,%eax
  801cf6:	89 cf                	mov    %ecx,%edi
  801cf8:	f7 f5                	div    %ebp
  801cfa:	89 c3                	mov    %eax,%ebx
  801cfc:	89 d8                	mov    %ebx,%eax
  801cfe:	89 fa                	mov    %edi,%edx
  801d00:	83 c4 1c             	add    $0x1c,%esp
  801d03:	5b                   	pop    %ebx
  801d04:	5e                   	pop    %esi
  801d05:	5f                   	pop    %edi
  801d06:	5d                   	pop    %ebp
  801d07:	c3                   	ret    
  801d08:	90                   	nop
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	39 ce                	cmp    %ecx,%esi
  801d12:	77 74                	ja     801d88 <__udivdi3+0xd8>
  801d14:	0f bd fe             	bsr    %esi,%edi
  801d17:	83 f7 1f             	xor    $0x1f,%edi
  801d1a:	0f 84 98 00 00 00    	je     801db8 <__udivdi3+0x108>
  801d20:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d25:	89 f9                	mov    %edi,%ecx
  801d27:	89 c5                	mov    %eax,%ebp
  801d29:	29 fb                	sub    %edi,%ebx
  801d2b:	d3 e6                	shl    %cl,%esi
  801d2d:	89 d9                	mov    %ebx,%ecx
  801d2f:	d3 ed                	shr    %cl,%ebp
  801d31:	89 f9                	mov    %edi,%ecx
  801d33:	d3 e0                	shl    %cl,%eax
  801d35:	09 ee                	or     %ebp,%esi
  801d37:	89 d9                	mov    %ebx,%ecx
  801d39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d3d:	89 d5                	mov    %edx,%ebp
  801d3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d43:	d3 ed                	shr    %cl,%ebp
  801d45:	89 f9                	mov    %edi,%ecx
  801d47:	d3 e2                	shl    %cl,%edx
  801d49:	89 d9                	mov    %ebx,%ecx
  801d4b:	d3 e8                	shr    %cl,%eax
  801d4d:	09 c2                	or     %eax,%edx
  801d4f:	89 d0                	mov    %edx,%eax
  801d51:	89 ea                	mov    %ebp,%edx
  801d53:	f7 f6                	div    %esi
  801d55:	89 d5                	mov    %edx,%ebp
  801d57:	89 c3                	mov    %eax,%ebx
  801d59:	f7 64 24 0c          	mull   0xc(%esp)
  801d5d:	39 d5                	cmp    %edx,%ebp
  801d5f:	72 10                	jb     801d71 <__udivdi3+0xc1>
  801d61:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d65:	89 f9                	mov    %edi,%ecx
  801d67:	d3 e6                	shl    %cl,%esi
  801d69:	39 c6                	cmp    %eax,%esi
  801d6b:	73 07                	jae    801d74 <__udivdi3+0xc4>
  801d6d:	39 d5                	cmp    %edx,%ebp
  801d6f:	75 03                	jne    801d74 <__udivdi3+0xc4>
  801d71:	83 eb 01             	sub    $0x1,%ebx
  801d74:	31 ff                	xor    %edi,%edi
  801d76:	89 d8                	mov    %ebx,%eax
  801d78:	89 fa                	mov    %edi,%edx
  801d7a:	83 c4 1c             	add    $0x1c,%esp
  801d7d:	5b                   	pop    %ebx
  801d7e:	5e                   	pop    %esi
  801d7f:	5f                   	pop    %edi
  801d80:	5d                   	pop    %ebp
  801d81:	c3                   	ret    
  801d82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d88:	31 ff                	xor    %edi,%edi
  801d8a:	31 db                	xor    %ebx,%ebx
  801d8c:	89 d8                	mov    %ebx,%eax
  801d8e:	89 fa                	mov    %edi,%edx
  801d90:	83 c4 1c             	add    $0x1c,%esp
  801d93:	5b                   	pop    %ebx
  801d94:	5e                   	pop    %esi
  801d95:	5f                   	pop    %edi
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    
  801d98:	90                   	nop
  801d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801da0:	89 d8                	mov    %ebx,%eax
  801da2:	f7 f7                	div    %edi
  801da4:	31 ff                	xor    %edi,%edi
  801da6:	89 c3                	mov    %eax,%ebx
  801da8:	89 d8                	mov    %ebx,%eax
  801daa:	89 fa                	mov    %edi,%edx
  801dac:	83 c4 1c             	add    $0x1c,%esp
  801daf:	5b                   	pop    %ebx
  801db0:	5e                   	pop    %esi
  801db1:	5f                   	pop    %edi
  801db2:	5d                   	pop    %ebp
  801db3:	c3                   	ret    
  801db4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801db8:	39 ce                	cmp    %ecx,%esi
  801dba:	72 0c                	jb     801dc8 <__udivdi3+0x118>
  801dbc:	31 db                	xor    %ebx,%ebx
  801dbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801dc2:	0f 87 34 ff ff ff    	ja     801cfc <__udivdi3+0x4c>
  801dc8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801dcd:	e9 2a ff ff ff       	jmp    801cfc <__udivdi3+0x4c>
  801dd2:	66 90                	xchg   %ax,%ax
  801dd4:	66 90                	xchg   %ax,%ax
  801dd6:	66 90                	xchg   %ax,%ax
  801dd8:	66 90                	xchg   %ax,%ax
  801dda:	66 90                	xchg   %ax,%ax
  801ddc:	66 90                	xchg   %ax,%ax
  801dde:	66 90                	xchg   %ax,%ax

00801de0 <__umoddi3>:
  801de0:	55                   	push   %ebp
  801de1:	57                   	push   %edi
  801de2:	56                   	push   %esi
  801de3:	53                   	push   %ebx
  801de4:	83 ec 1c             	sub    $0x1c,%esp
  801de7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801deb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801def:	8b 74 24 34          	mov    0x34(%esp),%esi
  801df3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801df7:	85 d2                	test   %edx,%edx
  801df9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e01:	89 f3                	mov    %esi,%ebx
  801e03:	89 3c 24             	mov    %edi,(%esp)
  801e06:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e0a:	75 1c                	jne    801e28 <__umoddi3+0x48>
  801e0c:	39 f7                	cmp    %esi,%edi
  801e0e:	76 50                	jbe    801e60 <__umoddi3+0x80>
  801e10:	89 c8                	mov    %ecx,%eax
  801e12:	89 f2                	mov    %esi,%edx
  801e14:	f7 f7                	div    %edi
  801e16:	89 d0                	mov    %edx,%eax
  801e18:	31 d2                	xor    %edx,%edx
  801e1a:	83 c4 1c             	add    $0x1c,%esp
  801e1d:	5b                   	pop    %ebx
  801e1e:	5e                   	pop    %esi
  801e1f:	5f                   	pop    %edi
  801e20:	5d                   	pop    %ebp
  801e21:	c3                   	ret    
  801e22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e28:	39 f2                	cmp    %esi,%edx
  801e2a:	89 d0                	mov    %edx,%eax
  801e2c:	77 52                	ja     801e80 <__umoddi3+0xa0>
  801e2e:	0f bd ea             	bsr    %edx,%ebp
  801e31:	83 f5 1f             	xor    $0x1f,%ebp
  801e34:	75 5a                	jne    801e90 <__umoddi3+0xb0>
  801e36:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e3a:	0f 82 e0 00 00 00    	jb     801f20 <__umoddi3+0x140>
  801e40:	39 0c 24             	cmp    %ecx,(%esp)
  801e43:	0f 86 d7 00 00 00    	jbe    801f20 <__umoddi3+0x140>
  801e49:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e4d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e51:	83 c4 1c             	add    $0x1c,%esp
  801e54:	5b                   	pop    %ebx
  801e55:	5e                   	pop    %esi
  801e56:	5f                   	pop    %edi
  801e57:	5d                   	pop    %ebp
  801e58:	c3                   	ret    
  801e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e60:	85 ff                	test   %edi,%edi
  801e62:	89 fd                	mov    %edi,%ebp
  801e64:	75 0b                	jne    801e71 <__umoddi3+0x91>
  801e66:	b8 01 00 00 00       	mov    $0x1,%eax
  801e6b:	31 d2                	xor    %edx,%edx
  801e6d:	f7 f7                	div    %edi
  801e6f:	89 c5                	mov    %eax,%ebp
  801e71:	89 f0                	mov    %esi,%eax
  801e73:	31 d2                	xor    %edx,%edx
  801e75:	f7 f5                	div    %ebp
  801e77:	89 c8                	mov    %ecx,%eax
  801e79:	f7 f5                	div    %ebp
  801e7b:	89 d0                	mov    %edx,%eax
  801e7d:	eb 99                	jmp    801e18 <__umoddi3+0x38>
  801e7f:	90                   	nop
  801e80:	89 c8                	mov    %ecx,%eax
  801e82:	89 f2                	mov    %esi,%edx
  801e84:	83 c4 1c             	add    $0x1c,%esp
  801e87:	5b                   	pop    %ebx
  801e88:	5e                   	pop    %esi
  801e89:	5f                   	pop    %edi
  801e8a:	5d                   	pop    %ebp
  801e8b:	c3                   	ret    
  801e8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e90:	8b 34 24             	mov    (%esp),%esi
  801e93:	bf 20 00 00 00       	mov    $0x20,%edi
  801e98:	89 e9                	mov    %ebp,%ecx
  801e9a:	29 ef                	sub    %ebp,%edi
  801e9c:	d3 e0                	shl    %cl,%eax
  801e9e:	89 f9                	mov    %edi,%ecx
  801ea0:	89 f2                	mov    %esi,%edx
  801ea2:	d3 ea                	shr    %cl,%edx
  801ea4:	89 e9                	mov    %ebp,%ecx
  801ea6:	09 c2                	or     %eax,%edx
  801ea8:	89 d8                	mov    %ebx,%eax
  801eaa:	89 14 24             	mov    %edx,(%esp)
  801ead:	89 f2                	mov    %esi,%edx
  801eaf:	d3 e2                	shl    %cl,%edx
  801eb1:	89 f9                	mov    %edi,%ecx
  801eb3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801eb7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ebb:	d3 e8                	shr    %cl,%eax
  801ebd:	89 e9                	mov    %ebp,%ecx
  801ebf:	89 c6                	mov    %eax,%esi
  801ec1:	d3 e3                	shl    %cl,%ebx
  801ec3:	89 f9                	mov    %edi,%ecx
  801ec5:	89 d0                	mov    %edx,%eax
  801ec7:	d3 e8                	shr    %cl,%eax
  801ec9:	89 e9                	mov    %ebp,%ecx
  801ecb:	09 d8                	or     %ebx,%eax
  801ecd:	89 d3                	mov    %edx,%ebx
  801ecf:	89 f2                	mov    %esi,%edx
  801ed1:	f7 34 24             	divl   (%esp)
  801ed4:	89 d6                	mov    %edx,%esi
  801ed6:	d3 e3                	shl    %cl,%ebx
  801ed8:	f7 64 24 04          	mull   0x4(%esp)
  801edc:	39 d6                	cmp    %edx,%esi
  801ede:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ee2:	89 d1                	mov    %edx,%ecx
  801ee4:	89 c3                	mov    %eax,%ebx
  801ee6:	72 08                	jb     801ef0 <__umoddi3+0x110>
  801ee8:	75 11                	jne    801efb <__umoddi3+0x11b>
  801eea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801eee:	73 0b                	jae    801efb <__umoddi3+0x11b>
  801ef0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ef4:	1b 14 24             	sbb    (%esp),%edx
  801ef7:	89 d1                	mov    %edx,%ecx
  801ef9:	89 c3                	mov    %eax,%ebx
  801efb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801eff:	29 da                	sub    %ebx,%edx
  801f01:	19 ce                	sbb    %ecx,%esi
  801f03:	89 f9                	mov    %edi,%ecx
  801f05:	89 f0                	mov    %esi,%eax
  801f07:	d3 e0                	shl    %cl,%eax
  801f09:	89 e9                	mov    %ebp,%ecx
  801f0b:	d3 ea                	shr    %cl,%edx
  801f0d:	89 e9                	mov    %ebp,%ecx
  801f0f:	d3 ee                	shr    %cl,%esi
  801f11:	09 d0                	or     %edx,%eax
  801f13:	89 f2                	mov    %esi,%edx
  801f15:	83 c4 1c             	add    $0x1c,%esp
  801f18:	5b                   	pop    %ebx
  801f19:	5e                   	pop    %esi
  801f1a:	5f                   	pop    %edi
  801f1b:	5d                   	pop    %ebp
  801f1c:	c3                   	ret    
  801f1d:	8d 76 00             	lea    0x0(%esi),%esi
  801f20:	29 f9                	sub    %edi,%ecx
  801f22:	19 d6                	sbb    %edx,%esi
  801f24:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f2c:	e9 18 ff ff ff       	jmp    801e49 <__umoddi3+0x69>
