
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
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
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 08 40 80 00       	mov    0x804008,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 80 1f 80 00       	push   $0x801f80
  800048:	e8 40 01 00 00       	call   80018d <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 c2 0b 00 00       	call   800c1c <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 08 40 80 00       	mov    0x804008,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 a0 1f 80 00       	push   $0x801fa0
  80006c:	e8 1c 01 00 00       	call   80018d <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 08 40 80 00       	mov    0x804008,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 cc 1f 80 00       	push   $0x801fcc
  80008d:	e8 fb 00 00 00       	call   80018d <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a5:	e8 53 0b 00 00       	call   800bfd <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e6:	e8 0c 0f 00 00       	call   800ff7 <close_all>
	sys_env_destroy(0);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	6a 00                	push   $0x0
  8000f0:	e8 c7 0a 00 00       	call   800bbc <sys_env_destroy>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800104:	8b 13                	mov    (%ebx),%edx
  800106:	8d 42 01             	lea    0x1(%edx),%eax
  800109:	89 03                	mov    %eax,(%ebx)
  80010b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800112:	3d ff 00 00 00       	cmp    $0xff,%eax
  800117:	75 1a                	jne    800133 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800119:	83 ec 08             	sub    $0x8,%esp
  80011c:	68 ff 00 00 00       	push   $0xff
  800121:	8d 43 08             	lea    0x8(%ebx),%eax
  800124:	50                   	push   %eax
  800125:	e8 55 0a 00 00       	call   800b7f <sys_cputs>
		b->idx = 0;
  80012a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800130:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800133:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800145:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014c:	00 00 00 
	b.cnt = 0;
  80014f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800156:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800159:	ff 75 0c             	pushl  0xc(%ebp)
  80015c:	ff 75 08             	pushl  0x8(%ebp)
  80015f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	68 fa 00 80 00       	push   $0x8000fa
  80016b:	e8 54 01 00 00       	call   8002c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800170:	83 c4 08             	add    $0x8,%esp
  800173:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800179:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017f:	50                   	push   %eax
  800180:	e8 fa 09 00 00       	call   800b7f <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800193:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800196:	50                   	push   %eax
  800197:	ff 75 08             	pushl  0x8(%ebp)
  80019a:	e8 9d ff ff ff       	call   80013c <vcprintf>
	va_end(ap);

	return cnt;
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 1c             	sub    $0x1c,%esp
  8001aa:	89 c7                	mov    %eax,%edi
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c8:	39 d3                	cmp    %edx,%ebx
  8001ca:	72 05                	jb     8001d1 <printnum+0x30>
  8001cc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001cf:	77 45                	ja     800216 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	ff 75 18             	pushl  0x18(%ebp)
  8001d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001da:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001dd:	53                   	push   %ebx
  8001de:	ff 75 10             	pushl  0x10(%ebp)
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f0:	e8 eb 1a 00 00       	call   801ce0 <__udivdi3>
  8001f5:	83 c4 18             	add    $0x18,%esp
  8001f8:	52                   	push   %edx
  8001f9:	50                   	push   %eax
  8001fa:	89 f2                	mov    %esi,%edx
  8001fc:	89 f8                	mov    %edi,%eax
  8001fe:	e8 9e ff ff ff       	call   8001a1 <printnum>
  800203:	83 c4 20             	add    $0x20,%esp
  800206:	eb 18                	jmp    800220 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	ff 75 18             	pushl  0x18(%ebp)
  80020f:	ff d7                	call   *%edi
  800211:	83 c4 10             	add    $0x10,%esp
  800214:	eb 03                	jmp    800219 <printnum+0x78>
  800216:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800219:	83 eb 01             	sub    $0x1,%ebx
  80021c:	85 db                	test   %ebx,%ebx
  80021e:	7f e8                	jg     800208 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	56                   	push   %esi
  800224:	83 ec 04             	sub    $0x4,%esp
  800227:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022a:	ff 75 e0             	pushl  -0x20(%ebp)
  80022d:	ff 75 dc             	pushl  -0x24(%ebp)
  800230:	ff 75 d8             	pushl  -0x28(%ebp)
  800233:	e8 d8 1b 00 00       	call   801e10 <__umoddi3>
  800238:	83 c4 14             	add    $0x14,%esp
  80023b:	0f be 80 f5 1f 80 00 	movsbl 0x801ff5(%eax),%eax
  800242:	50                   	push   %eax
  800243:	ff d7                	call   *%edi
}
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800253:	83 fa 01             	cmp    $0x1,%edx
  800256:	7e 0e                	jle    800266 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 02                	mov    (%edx),%eax
  800261:	8b 52 04             	mov    0x4(%edx),%edx
  800264:	eb 22                	jmp    800288 <getuint+0x38>
	else if (lflag)
  800266:	85 d2                	test   %edx,%edx
  800268:	74 10                	je     80027a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80026a:	8b 10                	mov    (%eax),%edx
  80026c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026f:	89 08                	mov    %ecx,(%eax)
  800271:	8b 02                	mov    (%edx),%eax
  800273:	ba 00 00 00 00       	mov    $0x0,%edx
  800278:	eb 0e                	jmp    800288 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 02                	mov    (%edx),%eax
  800283:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800290:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800294:	8b 10                	mov    (%eax),%edx
  800296:	3b 50 04             	cmp    0x4(%eax),%edx
  800299:	73 0a                	jae    8002a5 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a3:	88 02                	mov    %al,(%edx)
}
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    

008002a7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ad:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b0:	50                   	push   %eax
  8002b1:	ff 75 10             	pushl  0x10(%ebp)
  8002b4:	ff 75 0c             	pushl  0xc(%ebp)
  8002b7:	ff 75 08             	pushl  0x8(%ebp)
  8002ba:	e8 05 00 00 00       	call   8002c4 <vprintfmt>
	va_end(ap);
}
  8002bf:	83 c4 10             	add    $0x10,%esp
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 2c             	sub    $0x2c,%esp
  8002cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d6:	eb 12                	jmp    8002ea <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d8:	85 c0                	test   %eax,%eax
  8002da:	0f 84 38 04 00 00    	je     800718 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	53                   	push   %ebx
  8002e4:	50                   	push   %eax
  8002e5:	ff d6                	call   *%esi
  8002e7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ea:	83 c7 01             	add    $0x1,%edi
  8002ed:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f1:	83 f8 25             	cmp    $0x25,%eax
  8002f4:	75 e2                	jne    8002d8 <vprintfmt+0x14>
  8002f6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002fa:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800301:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800308:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80030f:	ba 00 00 00 00       	mov    $0x0,%edx
  800314:	eb 07                	jmp    80031d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800316:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  800319:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8d 47 01             	lea    0x1(%edi),%eax
  800320:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800323:	0f b6 07             	movzbl (%edi),%eax
  800326:	0f b6 c8             	movzbl %al,%ecx
  800329:	83 e8 23             	sub    $0x23,%eax
  80032c:	3c 55                	cmp    $0x55,%al
  80032e:	0f 87 c9 03 00 00    	ja     8006fd <vprintfmt+0x439>
  800334:	0f b6 c0             	movzbl %al,%eax
  800337:	ff 24 85 40 21 80 00 	jmp    *0x802140(,%eax,4)
  80033e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800341:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800345:	eb d6                	jmp    80031d <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  800347:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  80034e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  800354:	eb 94                	jmp    8002ea <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  800356:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  80035d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  800363:	eb 85                	jmp    8002ea <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  800365:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  80036c:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  800372:	e9 73 ff ff ff       	jmp    8002ea <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  800377:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  80037e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  800384:	e9 61 ff ff ff       	jmp    8002ea <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  800389:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800390:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  800396:	e9 4f ff ff ff       	jmp    8002ea <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80039b:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  8003a2:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  8003a8:	e9 3d ff ff ff       	jmp    8002ea <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  8003ad:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  8003b4:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  8003ba:	e9 2b ff ff ff       	jmp    8002ea <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  8003bf:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  8003c6:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8003cc:	e9 19 ff ff ff       	jmp    8002ea <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  8003d1:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  8003d8:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8003de:	e9 07 ff ff ff       	jmp    8002ea <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8003e3:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  8003ea:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8003f0:	e9 f5 fe ff ff       	jmp    8002ea <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800400:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800403:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800407:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80040a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80040d:	83 fa 09             	cmp    $0x9,%edx
  800410:	77 3f                	ja     800451 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800412:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800415:	eb e9                	jmp    800400 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8d 48 04             	lea    0x4(%eax),%ecx
  80041d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800420:	8b 00                	mov    (%eax),%eax
  800422:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800428:	eb 2d                	jmp    800457 <vprintfmt+0x193>
  80042a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042d:	85 c0                	test   %eax,%eax
  80042f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800434:	0f 49 c8             	cmovns %eax,%ecx
  800437:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043d:	e9 db fe ff ff       	jmp    80031d <vprintfmt+0x59>
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800445:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80044c:	e9 cc fe ff ff       	jmp    80031d <vprintfmt+0x59>
  800451:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800454:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800457:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80045b:	0f 89 bc fe ff ff    	jns    80031d <vprintfmt+0x59>
				width = precision, precision = -1;
  800461:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800464:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800467:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80046e:	e9 aa fe ff ff       	jmp    80031d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800473:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800479:	e9 9f fe ff ff       	jmp    80031d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80047e:	8b 45 14             	mov    0x14(%ebp),%eax
  800481:	8d 50 04             	lea    0x4(%eax),%edx
  800484:	89 55 14             	mov    %edx,0x14(%ebp)
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	53                   	push   %ebx
  80048b:	ff 30                	pushl  (%eax)
  80048d:	ff d6                	call   *%esi
			break;
  80048f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800495:	e9 50 fe ff ff       	jmp    8002ea <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 50 04             	lea    0x4(%eax),%edx
  8004a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a3:	8b 00                	mov    (%eax),%eax
  8004a5:	99                   	cltd   
  8004a6:	31 d0                	xor    %edx,%eax
  8004a8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004aa:	83 f8 0f             	cmp    $0xf,%eax
  8004ad:	7f 0b                	jg     8004ba <vprintfmt+0x1f6>
  8004af:	8b 14 85 a0 22 80 00 	mov    0x8022a0(,%eax,4),%edx
  8004b6:	85 d2                	test   %edx,%edx
  8004b8:	75 18                	jne    8004d2 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  8004ba:	50                   	push   %eax
  8004bb:	68 0d 20 80 00       	push   $0x80200d
  8004c0:	53                   	push   %ebx
  8004c1:	56                   	push   %esi
  8004c2:	e8 e0 fd ff ff       	call   8002a7 <printfmt>
  8004c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004cd:	e9 18 fe ff ff       	jmp    8002ea <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004d2:	52                   	push   %edx
  8004d3:	68 d1 23 80 00       	push   $0x8023d1
  8004d8:	53                   	push   %ebx
  8004d9:	56                   	push   %esi
  8004da:	e8 c8 fd ff ff       	call   8002a7 <printfmt>
  8004df:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e5:	e9 00 fe ff ff       	jmp    8002ea <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ed:	8d 50 04             	lea    0x4(%eax),%edx
  8004f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004f5:	85 ff                	test   %edi,%edi
  8004f7:	b8 06 20 80 00       	mov    $0x802006,%eax
  8004fc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800503:	0f 8e 94 00 00 00    	jle    80059d <vprintfmt+0x2d9>
  800509:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80050d:	0f 84 98 00 00 00    	je     8005ab <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  800513:	83 ec 08             	sub    $0x8,%esp
  800516:	ff 75 d0             	pushl  -0x30(%ebp)
  800519:	57                   	push   %edi
  80051a:	e8 81 02 00 00       	call   8007a0 <strnlen>
  80051f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800522:	29 c1                	sub    %eax,%ecx
  800524:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800527:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80052a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80052e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800531:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800534:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800536:	eb 0f                	jmp    800547 <vprintfmt+0x283>
					putch(padc, putdat);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	53                   	push   %ebx
  80053c:	ff 75 e0             	pushl  -0x20(%ebp)
  80053f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800541:	83 ef 01             	sub    $0x1,%edi
  800544:	83 c4 10             	add    $0x10,%esp
  800547:	85 ff                	test   %edi,%edi
  800549:	7f ed                	jg     800538 <vprintfmt+0x274>
  80054b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80054e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800551:	85 c9                	test   %ecx,%ecx
  800553:	b8 00 00 00 00       	mov    $0x0,%eax
  800558:	0f 49 c1             	cmovns %ecx,%eax
  80055b:	29 c1                	sub    %eax,%ecx
  80055d:	89 75 08             	mov    %esi,0x8(%ebp)
  800560:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800563:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800566:	89 cb                	mov    %ecx,%ebx
  800568:	eb 4d                	jmp    8005b7 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80056a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80056e:	74 1b                	je     80058b <vprintfmt+0x2c7>
  800570:	0f be c0             	movsbl %al,%eax
  800573:	83 e8 20             	sub    $0x20,%eax
  800576:	83 f8 5e             	cmp    $0x5e,%eax
  800579:	76 10                	jbe    80058b <vprintfmt+0x2c7>
					putch('?', putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	ff 75 0c             	pushl  0xc(%ebp)
  800581:	6a 3f                	push   $0x3f
  800583:	ff 55 08             	call   *0x8(%ebp)
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	eb 0d                	jmp    800598 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	ff 75 0c             	pushl  0xc(%ebp)
  800591:	52                   	push   %edx
  800592:	ff 55 08             	call   *0x8(%ebp)
  800595:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800598:	83 eb 01             	sub    $0x1,%ebx
  80059b:	eb 1a                	jmp    8005b7 <vprintfmt+0x2f3>
  80059d:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a9:	eb 0c                	jmp    8005b7 <vprintfmt+0x2f3>
  8005ab:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ae:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b7:	83 c7 01             	add    $0x1,%edi
  8005ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005be:	0f be d0             	movsbl %al,%edx
  8005c1:	85 d2                	test   %edx,%edx
  8005c3:	74 23                	je     8005e8 <vprintfmt+0x324>
  8005c5:	85 f6                	test   %esi,%esi
  8005c7:	78 a1                	js     80056a <vprintfmt+0x2a6>
  8005c9:	83 ee 01             	sub    $0x1,%esi
  8005cc:	79 9c                	jns    80056a <vprintfmt+0x2a6>
  8005ce:	89 df                	mov    %ebx,%edi
  8005d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d6:	eb 18                	jmp    8005f0 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d8:	83 ec 08             	sub    $0x8,%esp
  8005db:	53                   	push   %ebx
  8005dc:	6a 20                	push   $0x20
  8005de:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e0:	83 ef 01             	sub    $0x1,%edi
  8005e3:	83 c4 10             	add    $0x10,%esp
  8005e6:	eb 08                	jmp    8005f0 <vprintfmt+0x32c>
  8005e8:	89 df                	mov    %ebx,%edi
  8005ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f0:	85 ff                	test   %edi,%edi
  8005f2:	7f e4                	jg     8005d8 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f7:	e9 ee fc ff ff       	jmp    8002ea <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005fc:	83 fa 01             	cmp    $0x1,%edx
  8005ff:	7e 16                	jle    800617 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8d 50 08             	lea    0x8(%eax),%edx
  800607:	89 55 14             	mov    %edx,0x14(%ebp)
  80060a:	8b 50 04             	mov    0x4(%eax),%edx
  80060d:	8b 00                	mov    (%eax),%eax
  80060f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800612:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800615:	eb 32                	jmp    800649 <vprintfmt+0x385>
	else if (lflag)
  800617:	85 d2                	test   %edx,%edx
  800619:	74 18                	je     800633 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 50 04             	lea    0x4(%eax),%edx
  800621:	89 55 14             	mov    %edx,0x14(%ebp)
  800624:	8b 00                	mov    (%eax),%eax
  800626:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800629:	89 c1                	mov    %eax,%ecx
  80062b:	c1 f9 1f             	sar    $0x1f,%ecx
  80062e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800631:	eb 16                	jmp    800649 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8d 50 04             	lea    0x4(%eax),%edx
  800639:	89 55 14             	mov    %edx,0x14(%ebp)
  80063c:	8b 00                	mov    (%eax),%eax
  80063e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800641:	89 c1                	mov    %eax,%ecx
  800643:	c1 f9 1f             	sar    $0x1f,%ecx
  800646:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800649:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80064f:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800654:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800658:	79 6f                	jns    8006c9 <vprintfmt+0x405>
				putch('-', putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	6a 2d                	push   $0x2d
  800660:	ff d6                	call   *%esi
				num = -(long long) num;
  800662:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800665:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800668:	f7 d8                	neg    %eax
  80066a:	83 d2 00             	adc    $0x0,%edx
  80066d:	f7 da                	neg    %edx
  80066f:	83 c4 10             	add    $0x10,%esp
  800672:	eb 55                	jmp    8006c9 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800674:	8d 45 14             	lea    0x14(%ebp),%eax
  800677:	e8 d4 fb ff ff       	call   800250 <getuint>
			base = 10;
  80067c:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800681:	eb 46                	jmp    8006c9 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 c5 fb ff ff       	call   800250 <getuint>
			base = 8;
  80068b:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800690:	eb 37                	jmp    8006c9 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	53                   	push   %ebx
  800696:	6a 30                	push   $0x30
  800698:	ff d6                	call   *%esi
			putch('x', putdat);
  80069a:	83 c4 08             	add    $0x8,%esp
  80069d:	53                   	push   %ebx
  80069e:	6a 78                	push   $0x78
  8006a0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 50 04             	lea    0x4(%eax),%edx
  8006a8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ab:	8b 00                	mov    (%eax),%eax
  8006ad:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b5:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8006ba:	eb 0d                	jmp    8006c9 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bf:	e8 8c fb ff ff       	call   800250 <getuint>
			base = 16;
  8006c4:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c9:	83 ec 0c             	sub    $0xc,%esp
  8006cc:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8006d0:	51                   	push   %ecx
  8006d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d4:	57                   	push   %edi
  8006d5:	52                   	push   %edx
  8006d6:	50                   	push   %eax
  8006d7:	89 da                	mov    %ebx,%edx
  8006d9:	89 f0                	mov    %esi,%eax
  8006db:	e8 c1 fa ff ff       	call   8001a1 <printnum>
			break;
  8006e0:	83 c4 20             	add    $0x20,%esp
  8006e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e6:	e9 ff fb ff ff       	jmp    8002ea <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	53                   	push   %ebx
  8006ef:	51                   	push   %ecx
  8006f0:	ff d6                	call   *%esi
			break;
  8006f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f8:	e9 ed fb ff ff       	jmp    8002ea <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	53                   	push   %ebx
  800701:	6a 25                	push   $0x25
  800703:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	eb 03                	jmp    80070d <vprintfmt+0x449>
  80070a:	83 ef 01             	sub    $0x1,%edi
  80070d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800711:	75 f7                	jne    80070a <vprintfmt+0x446>
  800713:	e9 d2 fb ff ff       	jmp    8002ea <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800718:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071b:	5b                   	pop    %ebx
  80071c:	5e                   	pop    %esi
  80071d:	5f                   	pop    %edi
  80071e:	5d                   	pop    %ebp
  80071f:	c3                   	ret    

00800720 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	83 ec 18             	sub    $0x18,%esp
  800726:	8b 45 08             	mov    0x8(%ebp),%eax
  800729:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800733:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800736:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073d:	85 c0                	test   %eax,%eax
  80073f:	74 26                	je     800767 <vsnprintf+0x47>
  800741:	85 d2                	test   %edx,%edx
  800743:	7e 22                	jle    800767 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800745:	ff 75 14             	pushl  0x14(%ebp)
  800748:	ff 75 10             	pushl  0x10(%ebp)
  80074b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074e:	50                   	push   %eax
  80074f:	68 8a 02 80 00       	push   $0x80028a
  800754:	e8 6b fb ff ff       	call   8002c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800759:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	eb 05                	jmp    80076c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800767:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    

0080076e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800774:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800777:	50                   	push   %eax
  800778:	ff 75 10             	pushl  0x10(%ebp)
  80077b:	ff 75 0c             	pushl  0xc(%ebp)
  80077e:	ff 75 08             	pushl  0x8(%ebp)
  800781:	e8 9a ff ff ff       	call   800720 <vsnprintf>
	va_end(ap);

	return rc;
}
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078e:	b8 00 00 00 00       	mov    $0x0,%eax
  800793:	eb 03                	jmp    800798 <strlen+0x10>
		n++;
  800795:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800798:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079c:	75 f7                	jne    800795 <strlen+0xd>
		n++;
	return n;
}
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ae:	eb 03                	jmp    8007b3 <strnlen+0x13>
		n++;
  8007b0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b3:	39 c2                	cmp    %eax,%edx
  8007b5:	74 08                	je     8007bf <strnlen+0x1f>
  8007b7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007bb:	75 f3                	jne    8007b0 <strnlen+0x10>
  8007bd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007bf:	5d                   	pop    %ebp
  8007c0:	c3                   	ret    

008007c1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	53                   	push   %ebx
  8007c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007cb:	89 c2                	mov    %eax,%edx
  8007cd:	83 c2 01             	add    $0x1,%edx
  8007d0:	83 c1 01             	add    $0x1,%ecx
  8007d3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007da:	84 db                	test   %bl,%bl
  8007dc:	75 ef                	jne    8007cd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007de:	5b                   	pop    %ebx
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	53                   	push   %ebx
  8007e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e8:	53                   	push   %ebx
  8007e9:	e8 9a ff ff ff       	call   800788 <strlen>
  8007ee:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f1:	ff 75 0c             	pushl  0xc(%ebp)
  8007f4:	01 d8                	add    %ebx,%eax
  8007f6:	50                   	push   %eax
  8007f7:	e8 c5 ff ff ff       	call   8007c1 <strcpy>
	return dst;
}
  8007fc:	89 d8                	mov    %ebx,%eax
  8007fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800801:	c9                   	leave  
  800802:	c3                   	ret    

00800803 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	56                   	push   %esi
  800807:	53                   	push   %ebx
  800808:	8b 75 08             	mov    0x8(%ebp),%esi
  80080b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080e:	89 f3                	mov    %esi,%ebx
  800810:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800813:	89 f2                	mov    %esi,%edx
  800815:	eb 0f                	jmp    800826 <strncpy+0x23>
		*dst++ = *src;
  800817:	83 c2 01             	add    $0x1,%edx
  80081a:	0f b6 01             	movzbl (%ecx),%eax
  80081d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800820:	80 39 01             	cmpb   $0x1,(%ecx)
  800823:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800826:	39 da                	cmp    %ebx,%edx
  800828:	75 ed                	jne    800817 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80082a:	89 f0                	mov    %esi,%eax
  80082c:	5b                   	pop    %ebx
  80082d:	5e                   	pop    %esi
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	56                   	push   %esi
  800834:	53                   	push   %ebx
  800835:	8b 75 08             	mov    0x8(%ebp),%esi
  800838:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083b:	8b 55 10             	mov    0x10(%ebp),%edx
  80083e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800840:	85 d2                	test   %edx,%edx
  800842:	74 21                	je     800865 <strlcpy+0x35>
  800844:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800848:	89 f2                	mov    %esi,%edx
  80084a:	eb 09                	jmp    800855 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80084c:	83 c2 01             	add    $0x1,%edx
  80084f:	83 c1 01             	add    $0x1,%ecx
  800852:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800855:	39 c2                	cmp    %eax,%edx
  800857:	74 09                	je     800862 <strlcpy+0x32>
  800859:	0f b6 19             	movzbl (%ecx),%ebx
  80085c:	84 db                	test   %bl,%bl
  80085e:	75 ec                	jne    80084c <strlcpy+0x1c>
  800860:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800862:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800865:	29 f0                	sub    %esi,%eax
}
  800867:	5b                   	pop    %ebx
  800868:	5e                   	pop    %esi
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800874:	eb 06                	jmp    80087c <strcmp+0x11>
		p++, q++;
  800876:	83 c1 01             	add    $0x1,%ecx
  800879:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80087c:	0f b6 01             	movzbl (%ecx),%eax
  80087f:	84 c0                	test   %al,%al
  800881:	74 04                	je     800887 <strcmp+0x1c>
  800883:	3a 02                	cmp    (%edx),%al
  800885:	74 ef                	je     800876 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800887:	0f b6 c0             	movzbl %al,%eax
  80088a:	0f b6 12             	movzbl (%edx),%edx
  80088d:	29 d0                	sub    %edx,%eax
}
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	53                   	push   %ebx
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089b:	89 c3                	mov    %eax,%ebx
  80089d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a0:	eb 06                	jmp    8008a8 <strncmp+0x17>
		n--, p++, q++;
  8008a2:	83 c0 01             	add    $0x1,%eax
  8008a5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a8:	39 d8                	cmp    %ebx,%eax
  8008aa:	74 15                	je     8008c1 <strncmp+0x30>
  8008ac:	0f b6 08             	movzbl (%eax),%ecx
  8008af:	84 c9                	test   %cl,%cl
  8008b1:	74 04                	je     8008b7 <strncmp+0x26>
  8008b3:	3a 0a                	cmp    (%edx),%cl
  8008b5:	74 eb                	je     8008a2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b7:	0f b6 00             	movzbl (%eax),%eax
  8008ba:	0f b6 12             	movzbl (%edx),%edx
  8008bd:	29 d0                	sub    %edx,%eax
  8008bf:	eb 05                	jmp    8008c6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c6:	5b                   	pop    %ebx
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d3:	eb 07                	jmp    8008dc <strchr+0x13>
		if (*s == c)
  8008d5:	38 ca                	cmp    %cl,%dl
  8008d7:	74 0f                	je     8008e8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d9:	83 c0 01             	add    $0x1,%eax
  8008dc:	0f b6 10             	movzbl (%eax),%edx
  8008df:	84 d2                	test   %dl,%dl
  8008e1:	75 f2                	jne    8008d5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f4:	eb 03                	jmp    8008f9 <strfind+0xf>
  8008f6:	83 c0 01             	add    $0x1,%eax
  8008f9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008fc:	38 ca                	cmp    %cl,%dl
  8008fe:	74 04                	je     800904 <strfind+0x1a>
  800900:	84 d2                	test   %dl,%dl
  800902:	75 f2                	jne    8008f6 <strfind+0xc>
			break;
	return (char *) s;
}
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	57                   	push   %edi
  80090a:	56                   	push   %esi
  80090b:	53                   	push   %ebx
  80090c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800912:	85 c9                	test   %ecx,%ecx
  800914:	74 36                	je     80094c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800916:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091c:	75 28                	jne    800946 <memset+0x40>
  80091e:	f6 c1 03             	test   $0x3,%cl
  800921:	75 23                	jne    800946 <memset+0x40>
		c &= 0xFF;
  800923:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800927:	89 d3                	mov    %edx,%ebx
  800929:	c1 e3 08             	shl    $0x8,%ebx
  80092c:	89 d6                	mov    %edx,%esi
  80092e:	c1 e6 18             	shl    $0x18,%esi
  800931:	89 d0                	mov    %edx,%eax
  800933:	c1 e0 10             	shl    $0x10,%eax
  800936:	09 f0                	or     %esi,%eax
  800938:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80093a:	89 d8                	mov    %ebx,%eax
  80093c:	09 d0                	or     %edx,%eax
  80093e:	c1 e9 02             	shr    $0x2,%ecx
  800941:	fc                   	cld    
  800942:	f3 ab                	rep stos %eax,%es:(%edi)
  800944:	eb 06                	jmp    80094c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800946:	8b 45 0c             	mov    0xc(%ebp),%eax
  800949:	fc                   	cld    
  80094a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094c:	89 f8                	mov    %edi,%eax
  80094e:	5b                   	pop    %ebx
  80094f:	5e                   	pop    %esi
  800950:	5f                   	pop    %edi
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	57                   	push   %edi
  800957:	56                   	push   %esi
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800961:	39 c6                	cmp    %eax,%esi
  800963:	73 35                	jae    80099a <memmove+0x47>
  800965:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800968:	39 d0                	cmp    %edx,%eax
  80096a:	73 2e                	jae    80099a <memmove+0x47>
		s += n;
		d += n;
  80096c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096f:	89 d6                	mov    %edx,%esi
  800971:	09 fe                	or     %edi,%esi
  800973:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800979:	75 13                	jne    80098e <memmove+0x3b>
  80097b:	f6 c1 03             	test   $0x3,%cl
  80097e:	75 0e                	jne    80098e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800980:	83 ef 04             	sub    $0x4,%edi
  800983:	8d 72 fc             	lea    -0x4(%edx),%esi
  800986:	c1 e9 02             	shr    $0x2,%ecx
  800989:	fd                   	std    
  80098a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098c:	eb 09                	jmp    800997 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80098e:	83 ef 01             	sub    $0x1,%edi
  800991:	8d 72 ff             	lea    -0x1(%edx),%esi
  800994:	fd                   	std    
  800995:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800997:	fc                   	cld    
  800998:	eb 1d                	jmp    8009b7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099a:	89 f2                	mov    %esi,%edx
  80099c:	09 c2                	or     %eax,%edx
  80099e:	f6 c2 03             	test   $0x3,%dl
  8009a1:	75 0f                	jne    8009b2 <memmove+0x5f>
  8009a3:	f6 c1 03             	test   $0x3,%cl
  8009a6:	75 0a                	jne    8009b2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a8:	c1 e9 02             	shr    $0x2,%ecx
  8009ab:	89 c7                	mov    %eax,%edi
  8009ad:	fc                   	cld    
  8009ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b0:	eb 05                	jmp    8009b7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b2:	89 c7                	mov    %eax,%edi
  8009b4:	fc                   	cld    
  8009b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b7:	5e                   	pop    %esi
  8009b8:	5f                   	pop    %edi
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009be:	ff 75 10             	pushl  0x10(%ebp)
  8009c1:	ff 75 0c             	pushl  0xc(%ebp)
  8009c4:	ff 75 08             	pushl  0x8(%ebp)
  8009c7:	e8 87 ff ff ff       	call   800953 <memmove>
}
  8009cc:	c9                   	leave  
  8009cd:	c3                   	ret    

008009ce <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	56                   	push   %esi
  8009d2:	53                   	push   %ebx
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d9:	89 c6                	mov    %eax,%esi
  8009db:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009de:	eb 1a                	jmp    8009fa <memcmp+0x2c>
		if (*s1 != *s2)
  8009e0:	0f b6 08             	movzbl (%eax),%ecx
  8009e3:	0f b6 1a             	movzbl (%edx),%ebx
  8009e6:	38 d9                	cmp    %bl,%cl
  8009e8:	74 0a                	je     8009f4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ea:	0f b6 c1             	movzbl %cl,%eax
  8009ed:	0f b6 db             	movzbl %bl,%ebx
  8009f0:	29 d8                	sub    %ebx,%eax
  8009f2:	eb 0f                	jmp    800a03 <memcmp+0x35>
		s1++, s2++;
  8009f4:	83 c0 01             	add    $0x1,%eax
  8009f7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fa:	39 f0                	cmp    %esi,%eax
  8009fc:	75 e2                	jne    8009e0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	53                   	push   %ebx
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a0e:	89 c1                	mov    %eax,%ecx
  800a10:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a13:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a17:	eb 0a                	jmp    800a23 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a19:	0f b6 10             	movzbl (%eax),%edx
  800a1c:	39 da                	cmp    %ebx,%edx
  800a1e:	74 07                	je     800a27 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a20:	83 c0 01             	add    $0x1,%eax
  800a23:	39 c8                	cmp    %ecx,%eax
  800a25:	72 f2                	jb     800a19 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a27:	5b                   	pop    %ebx
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	57                   	push   %edi
  800a2e:	56                   	push   %esi
  800a2f:	53                   	push   %ebx
  800a30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a36:	eb 03                	jmp    800a3b <strtol+0x11>
		s++;
  800a38:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3b:	0f b6 01             	movzbl (%ecx),%eax
  800a3e:	3c 20                	cmp    $0x20,%al
  800a40:	74 f6                	je     800a38 <strtol+0xe>
  800a42:	3c 09                	cmp    $0x9,%al
  800a44:	74 f2                	je     800a38 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a46:	3c 2b                	cmp    $0x2b,%al
  800a48:	75 0a                	jne    800a54 <strtol+0x2a>
		s++;
  800a4a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a4d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a52:	eb 11                	jmp    800a65 <strtol+0x3b>
  800a54:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a59:	3c 2d                	cmp    $0x2d,%al
  800a5b:	75 08                	jne    800a65 <strtol+0x3b>
		s++, neg = 1;
  800a5d:	83 c1 01             	add    $0x1,%ecx
  800a60:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a65:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a6b:	75 15                	jne    800a82 <strtol+0x58>
  800a6d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a70:	75 10                	jne    800a82 <strtol+0x58>
  800a72:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a76:	75 7c                	jne    800af4 <strtol+0xca>
		s += 2, base = 16;
  800a78:	83 c1 02             	add    $0x2,%ecx
  800a7b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a80:	eb 16                	jmp    800a98 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a82:	85 db                	test   %ebx,%ebx
  800a84:	75 12                	jne    800a98 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a86:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8e:	75 08                	jne    800a98 <strtol+0x6e>
		s++, base = 8;
  800a90:	83 c1 01             	add    $0x1,%ecx
  800a93:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a98:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa0:	0f b6 11             	movzbl (%ecx),%edx
  800aa3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa6:	89 f3                	mov    %esi,%ebx
  800aa8:	80 fb 09             	cmp    $0x9,%bl
  800aab:	77 08                	ja     800ab5 <strtol+0x8b>
			dig = *s - '0';
  800aad:	0f be d2             	movsbl %dl,%edx
  800ab0:	83 ea 30             	sub    $0x30,%edx
  800ab3:	eb 22                	jmp    800ad7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ab5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab8:	89 f3                	mov    %esi,%ebx
  800aba:	80 fb 19             	cmp    $0x19,%bl
  800abd:	77 08                	ja     800ac7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800abf:	0f be d2             	movsbl %dl,%edx
  800ac2:	83 ea 57             	sub    $0x57,%edx
  800ac5:	eb 10                	jmp    800ad7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aca:	89 f3                	mov    %esi,%ebx
  800acc:	80 fb 19             	cmp    $0x19,%bl
  800acf:	77 16                	ja     800ae7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ad1:	0f be d2             	movsbl %dl,%edx
  800ad4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ada:	7d 0b                	jge    800ae7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800adc:	83 c1 01             	add    $0x1,%ecx
  800adf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ae5:	eb b9                	jmp    800aa0 <strtol+0x76>

	if (endptr)
  800ae7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aeb:	74 0d                	je     800afa <strtol+0xd0>
		*endptr = (char *) s;
  800aed:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af0:	89 0e                	mov    %ecx,(%esi)
  800af2:	eb 06                	jmp    800afa <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af4:	85 db                	test   %ebx,%ebx
  800af6:	74 98                	je     800a90 <strtol+0x66>
  800af8:	eb 9e                	jmp    800a98 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800afa:	89 c2                	mov    %eax,%edx
  800afc:	f7 da                	neg    %edx
  800afe:	85 ff                	test   %edi,%edi
  800b00:	0f 45 c2             	cmovne %edx,%eax
}
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5f                   	pop    %edi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	57                   	push   %edi
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
  800b0e:	83 ec 04             	sub    $0x4,%esp
  800b11:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800b14:	57                   	push   %edi
  800b15:	e8 6e fc ff ff       	call   800788 <strlen>
  800b1a:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b1d:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800b20:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b2a:	eb 46                	jmp    800b72 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800b2c:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800b30:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b33:	80 f9 09             	cmp    $0x9,%cl
  800b36:	77 08                	ja     800b40 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800b38:	0f be d2             	movsbl %dl,%edx
  800b3b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b3e:	eb 27                	jmp    800b67 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800b40:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800b43:	80 f9 05             	cmp    $0x5,%cl
  800b46:	77 08                	ja     800b50 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800b48:	0f be d2             	movsbl %dl,%edx
  800b4b:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800b4e:	eb 17                	jmp    800b67 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800b50:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800b53:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800b56:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800b5b:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800b5f:	77 06                	ja     800b67 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800b61:	0f be d2             	movsbl %dl,%edx
  800b64:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800b67:	0f af ce             	imul   %esi,%ecx
  800b6a:	01 c8                	add    %ecx,%eax
		base *= 16;
  800b6c:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b6f:	83 eb 01             	sub    $0x1,%ebx
  800b72:	83 fb 01             	cmp    $0x1,%ebx
  800b75:	7f b5                	jg     800b2c <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800b77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b90:	89 c3                	mov    %eax,%ebx
  800b92:	89 c7                	mov    %eax,%edi
  800b94:	89 c6                	mov    %eax,%esi
  800b96:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba8:	b8 01 00 00 00       	mov    $0x1,%eax
  800bad:	89 d1                	mov    %edx,%ecx
  800baf:	89 d3                	mov    %edx,%ebx
  800bb1:	89 d7                	mov    %edx,%edi
  800bb3:	89 d6                	mov    %edx,%esi
  800bb5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bca:	b8 03 00 00 00       	mov    $0x3,%eax
  800bcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd2:	89 cb                	mov    %ecx,%ebx
  800bd4:	89 cf                	mov    %ecx,%edi
  800bd6:	89 ce                	mov    %ecx,%esi
  800bd8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	7e 17                	jle    800bf5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bde:	83 ec 0c             	sub    $0xc,%esp
  800be1:	50                   	push   %eax
  800be2:	6a 03                	push   $0x3
  800be4:	68 ff 22 80 00       	push   $0x8022ff
  800be9:	6a 23                	push   $0x23
  800beb:	68 1c 23 80 00       	push   $0x80231c
  800bf0:	e8 69 0f 00 00       	call   801b5e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c03:	ba 00 00 00 00       	mov    $0x0,%edx
  800c08:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0d:	89 d1                	mov    %edx,%ecx
  800c0f:	89 d3                	mov    %edx,%ebx
  800c11:	89 d7                	mov    %edx,%edi
  800c13:	89 d6                	mov    %edx,%esi
  800c15:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_yield>:

void
sys_yield(void)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c22:	ba 00 00 00 00       	mov    $0x0,%edx
  800c27:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2c:	89 d1                	mov    %edx,%ecx
  800c2e:	89 d3                	mov    %edx,%ebx
  800c30:	89 d7                	mov    %edx,%edi
  800c32:	89 d6                	mov    %edx,%esi
  800c34:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c44:	be 00 00 00 00       	mov    $0x0,%esi
  800c49:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c57:	89 f7                	mov    %esi,%edi
  800c59:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	7e 17                	jle    800c76 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5f:	83 ec 0c             	sub    $0xc,%esp
  800c62:	50                   	push   %eax
  800c63:	6a 04                	push   $0x4
  800c65:	68 ff 22 80 00       	push   $0x8022ff
  800c6a:	6a 23                	push   $0x23
  800c6c:	68 1c 23 80 00       	push   $0x80231c
  800c71:	e8 e8 0e 00 00       	call   801b5e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c87:	b8 05 00 00 00       	mov    $0x5,%eax
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c95:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c98:	8b 75 18             	mov    0x18(%ebp),%esi
  800c9b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	7e 17                	jle    800cb8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca1:	83 ec 0c             	sub    $0xc,%esp
  800ca4:	50                   	push   %eax
  800ca5:	6a 05                	push   $0x5
  800ca7:	68 ff 22 80 00       	push   $0x8022ff
  800cac:	6a 23                	push   $0x23
  800cae:	68 1c 23 80 00       	push   $0x80231c
  800cb3:	e8 a6 0e 00 00       	call   801b5e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
  800cc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cce:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd9:	89 df                	mov    %ebx,%edi
  800cdb:	89 de                	mov    %ebx,%esi
  800cdd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	7e 17                	jle    800cfa <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	50                   	push   %eax
  800ce7:	6a 06                	push   $0x6
  800ce9:	68 ff 22 80 00       	push   $0x8022ff
  800cee:	6a 23                	push   $0x23
  800cf0:	68 1c 23 80 00       	push   $0x80231c
  800cf5:	e8 64 0e 00 00       	call   801b5e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
  800d08:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d10:	b8 08 00 00 00       	mov    $0x8,%eax
  800d15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d18:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1b:	89 df                	mov    %ebx,%edi
  800d1d:	89 de                	mov    %ebx,%esi
  800d1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d21:	85 c0                	test   %eax,%eax
  800d23:	7e 17                	jle    800d3c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d25:	83 ec 0c             	sub    $0xc,%esp
  800d28:	50                   	push   %eax
  800d29:	6a 08                	push   $0x8
  800d2b:	68 ff 22 80 00       	push   $0x8022ff
  800d30:	6a 23                	push   $0x23
  800d32:	68 1c 23 80 00       	push   $0x80231c
  800d37:	e8 22 0e 00 00       	call   801b5e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
  800d4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d52:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5d:	89 df                	mov    %ebx,%edi
  800d5f:	89 de                	mov    %ebx,%esi
  800d61:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d63:	85 c0                	test   %eax,%eax
  800d65:	7e 17                	jle    800d7e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d67:	83 ec 0c             	sub    $0xc,%esp
  800d6a:	50                   	push   %eax
  800d6b:	6a 0a                	push   $0xa
  800d6d:	68 ff 22 80 00       	push   $0x8022ff
  800d72:	6a 23                	push   $0x23
  800d74:	68 1c 23 80 00       	push   $0x80231c
  800d79:	e8 e0 0d 00 00       	call   801b5e <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d94:	b8 09 00 00 00       	mov    $0x9,%eax
  800d99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9f:	89 df                	mov    %ebx,%edi
  800da1:	89 de                	mov    %ebx,%esi
  800da3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7e 17                	jle    800dc0 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	50                   	push   %eax
  800dad:	6a 09                	push   $0x9
  800daf:	68 ff 22 80 00       	push   $0x8022ff
  800db4:	6a 23                	push   $0x23
  800db6:	68 1c 23 80 00       	push   $0x80231c
  800dbb:	e8 9e 0d 00 00       	call   801b5e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dce:	be 00 00 00 00       	mov    $0x0,%esi
  800dd3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
  800df1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	89 cb                	mov    %ecx,%ebx
  800e03:	89 cf                	mov    %ecx,%edi
  800e05:	89 ce                	mov    %ecx,%esi
  800e07:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	7e 17                	jle    800e24 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0d:	83 ec 0c             	sub    $0xc,%esp
  800e10:	50                   	push   %eax
  800e11:	6a 0d                	push   $0xd
  800e13:	68 ff 22 80 00       	push   $0x8022ff
  800e18:	6a 23                	push   $0x23
  800e1a:	68 1c 23 80 00       	push   $0x80231c
  800e1f:	e8 3a 0d 00 00       	call   801b5e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e32:	05 00 00 00 30       	add    $0x30000000,%eax
  800e37:	c1 e8 0c             	shr    $0xc,%eax
}
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    

00800e3c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e42:	05 00 00 00 30       	add    $0x30000000,%eax
  800e47:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e4c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e59:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e5e:	89 c2                	mov    %eax,%edx
  800e60:	c1 ea 16             	shr    $0x16,%edx
  800e63:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6a:	f6 c2 01             	test   $0x1,%dl
  800e6d:	74 11                	je     800e80 <fd_alloc+0x2d>
  800e6f:	89 c2                	mov    %eax,%edx
  800e71:	c1 ea 0c             	shr    $0xc,%edx
  800e74:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7b:	f6 c2 01             	test   $0x1,%dl
  800e7e:	75 09                	jne    800e89 <fd_alloc+0x36>
			*fd_store = fd;
  800e80:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e82:	b8 00 00 00 00       	mov    $0x0,%eax
  800e87:	eb 17                	jmp    800ea0 <fd_alloc+0x4d>
  800e89:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e8e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e93:	75 c9                	jne    800e5e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e95:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e9b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ea8:	83 f8 1f             	cmp    $0x1f,%eax
  800eab:	77 36                	ja     800ee3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ead:	c1 e0 0c             	shl    $0xc,%eax
  800eb0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eb5:	89 c2                	mov    %eax,%edx
  800eb7:	c1 ea 16             	shr    $0x16,%edx
  800eba:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec1:	f6 c2 01             	test   $0x1,%dl
  800ec4:	74 24                	je     800eea <fd_lookup+0x48>
  800ec6:	89 c2                	mov    %eax,%edx
  800ec8:	c1 ea 0c             	shr    $0xc,%edx
  800ecb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed2:	f6 c2 01             	test   $0x1,%dl
  800ed5:	74 1a                	je     800ef1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ed7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eda:	89 02                	mov    %eax,(%edx)
	return 0;
  800edc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee1:	eb 13                	jmp    800ef6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee8:	eb 0c                	jmp    800ef6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eef:	eb 05                	jmp    800ef6 <fd_lookup+0x54>
  800ef1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	83 ec 08             	sub    $0x8,%esp
  800efe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f01:	ba a8 23 80 00       	mov    $0x8023a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f06:	eb 13                	jmp    800f1b <dev_lookup+0x23>
  800f08:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f0b:	39 08                	cmp    %ecx,(%eax)
  800f0d:	75 0c                	jne    800f1b <dev_lookup+0x23>
			*dev = devtab[i];
  800f0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f12:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f14:	b8 00 00 00 00       	mov    $0x0,%eax
  800f19:	eb 2e                	jmp    800f49 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f1b:	8b 02                	mov    (%edx),%eax
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	75 e7                	jne    800f08 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f21:	a1 08 40 80 00       	mov    0x804008,%eax
  800f26:	8b 40 48             	mov    0x48(%eax),%eax
  800f29:	83 ec 04             	sub    $0x4,%esp
  800f2c:	51                   	push   %ecx
  800f2d:	50                   	push   %eax
  800f2e:	68 2c 23 80 00       	push   $0x80232c
  800f33:	e8 55 f2 ff ff       	call   80018d <cprintf>
	*dev = 0;
  800f38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f41:	83 c4 10             	add    $0x10,%esp
  800f44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f49:	c9                   	leave  
  800f4a:	c3                   	ret    

00800f4b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	56                   	push   %esi
  800f4f:	53                   	push   %ebx
  800f50:	83 ec 10             	sub    $0x10,%esp
  800f53:	8b 75 08             	mov    0x8(%ebp),%esi
  800f56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f5c:	50                   	push   %eax
  800f5d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f63:	c1 e8 0c             	shr    $0xc,%eax
  800f66:	50                   	push   %eax
  800f67:	e8 36 ff ff ff       	call   800ea2 <fd_lookup>
  800f6c:	83 c4 08             	add    $0x8,%esp
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	78 05                	js     800f78 <fd_close+0x2d>
	    || fd != fd2) 
  800f73:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f76:	74 0c                	je     800f84 <fd_close+0x39>
		return (must_exist ? r : 0); 
  800f78:	84 db                	test   %bl,%bl
  800f7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7f:	0f 44 c2             	cmove  %edx,%eax
  800f82:	eb 41                	jmp    800fc5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f84:	83 ec 08             	sub    $0x8,%esp
  800f87:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f8a:	50                   	push   %eax
  800f8b:	ff 36                	pushl  (%esi)
  800f8d:	e8 66 ff ff ff       	call   800ef8 <dev_lookup>
  800f92:	89 c3                	mov    %eax,%ebx
  800f94:	83 c4 10             	add    $0x10,%esp
  800f97:	85 c0                	test   %eax,%eax
  800f99:	78 1a                	js     800fb5 <fd_close+0x6a>
		if (dev->dev_close) 
  800f9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f9e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  800fa1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	74 0b                	je     800fb5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800faa:	83 ec 0c             	sub    $0xc,%esp
  800fad:	56                   	push   %esi
  800fae:	ff d0                	call   *%eax
  800fb0:	89 c3                	mov    %eax,%ebx
  800fb2:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fb5:	83 ec 08             	sub    $0x8,%esp
  800fb8:	56                   	push   %esi
  800fb9:	6a 00                	push   $0x0
  800fbb:	e8 00 fd ff ff       	call   800cc0 <sys_page_unmap>
	return r;
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	89 d8                	mov    %ebx,%eax
}
  800fc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fc8:	5b                   	pop    %ebx
  800fc9:	5e                   	pop    %esi
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    

00800fcc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd5:	50                   	push   %eax
  800fd6:	ff 75 08             	pushl  0x8(%ebp)
  800fd9:	e8 c4 fe ff ff       	call   800ea2 <fd_lookup>
  800fde:	83 c4 08             	add    $0x8,%esp
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	78 10                	js     800ff5 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  800fe5:	83 ec 08             	sub    $0x8,%esp
  800fe8:	6a 01                	push   $0x1
  800fea:	ff 75 f4             	pushl  -0xc(%ebp)
  800fed:	e8 59 ff ff ff       	call   800f4b <fd_close>
  800ff2:	83 c4 10             	add    $0x10,%esp
}
  800ff5:	c9                   	leave  
  800ff6:	c3                   	ret    

00800ff7 <close_all>:

void
close_all(void)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	53                   	push   %ebx
  800ffb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ffe:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801003:	83 ec 0c             	sub    $0xc,%esp
  801006:	53                   	push   %ebx
  801007:	e8 c0 ff ff ff       	call   800fcc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80100c:	83 c3 01             	add    $0x1,%ebx
  80100f:	83 c4 10             	add    $0x10,%esp
  801012:	83 fb 20             	cmp    $0x20,%ebx
  801015:	75 ec                	jne    801003 <close_all+0xc>
		close(i);
}
  801017:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101a:	c9                   	leave  
  80101b:	c3                   	ret    

0080101c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	57                   	push   %edi
  801020:	56                   	push   %esi
  801021:	53                   	push   %ebx
  801022:	83 ec 2c             	sub    $0x2c,%esp
  801025:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801028:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80102b:	50                   	push   %eax
  80102c:	ff 75 08             	pushl  0x8(%ebp)
  80102f:	e8 6e fe ff ff       	call   800ea2 <fd_lookup>
  801034:	83 c4 08             	add    $0x8,%esp
  801037:	85 c0                	test   %eax,%eax
  801039:	0f 88 c1 00 00 00    	js     801100 <dup+0xe4>
		return r;
	close(newfdnum);
  80103f:	83 ec 0c             	sub    $0xc,%esp
  801042:	56                   	push   %esi
  801043:	e8 84 ff ff ff       	call   800fcc <close>

	newfd = INDEX2FD(newfdnum);
  801048:	89 f3                	mov    %esi,%ebx
  80104a:	c1 e3 0c             	shl    $0xc,%ebx
  80104d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801053:	83 c4 04             	add    $0x4,%esp
  801056:	ff 75 e4             	pushl  -0x1c(%ebp)
  801059:	e8 de fd ff ff       	call   800e3c <fd2data>
  80105e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801060:	89 1c 24             	mov    %ebx,(%esp)
  801063:	e8 d4 fd ff ff       	call   800e3c <fd2data>
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80106e:	89 f8                	mov    %edi,%eax
  801070:	c1 e8 16             	shr    $0x16,%eax
  801073:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107a:	a8 01                	test   $0x1,%al
  80107c:	74 37                	je     8010b5 <dup+0x99>
  80107e:	89 f8                	mov    %edi,%eax
  801080:	c1 e8 0c             	shr    $0xc,%eax
  801083:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108a:	f6 c2 01             	test   $0x1,%dl
  80108d:	74 26                	je     8010b5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80108f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801096:	83 ec 0c             	sub    $0xc,%esp
  801099:	25 07 0e 00 00       	and    $0xe07,%eax
  80109e:	50                   	push   %eax
  80109f:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a2:	6a 00                	push   $0x0
  8010a4:	57                   	push   %edi
  8010a5:	6a 00                	push   $0x0
  8010a7:	e8 d2 fb ff ff       	call   800c7e <sys_page_map>
  8010ac:	89 c7                	mov    %eax,%edi
  8010ae:	83 c4 20             	add    $0x20,%esp
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	78 2e                	js     8010e3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010b8:	89 d0                	mov    %edx,%eax
  8010ba:	c1 e8 0c             	shr    $0xc,%eax
  8010bd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c4:	83 ec 0c             	sub    $0xc,%esp
  8010c7:	25 07 0e 00 00       	and    $0xe07,%eax
  8010cc:	50                   	push   %eax
  8010cd:	53                   	push   %ebx
  8010ce:	6a 00                	push   $0x0
  8010d0:	52                   	push   %edx
  8010d1:	6a 00                	push   $0x0
  8010d3:	e8 a6 fb ff ff       	call   800c7e <sys_page_map>
  8010d8:	89 c7                	mov    %eax,%edi
  8010da:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010dd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010df:	85 ff                	test   %edi,%edi
  8010e1:	79 1d                	jns    801100 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010e3:	83 ec 08             	sub    $0x8,%esp
  8010e6:	53                   	push   %ebx
  8010e7:	6a 00                	push   $0x0
  8010e9:	e8 d2 fb ff ff       	call   800cc0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010ee:	83 c4 08             	add    $0x8,%esp
  8010f1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f4:	6a 00                	push   $0x0
  8010f6:	e8 c5 fb ff ff       	call   800cc0 <sys_page_unmap>
	return r;
  8010fb:	83 c4 10             	add    $0x10,%esp
  8010fe:	89 f8                	mov    %edi,%eax
}
  801100:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801103:	5b                   	pop    %ebx
  801104:	5e                   	pop    %esi
  801105:	5f                   	pop    %edi
  801106:	5d                   	pop    %ebp
  801107:	c3                   	ret    

00801108 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	53                   	push   %ebx
  80110c:	83 ec 14             	sub    $0x14,%esp
  80110f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801112:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801115:	50                   	push   %eax
  801116:	53                   	push   %ebx
  801117:	e8 86 fd ff ff       	call   800ea2 <fd_lookup>
  80111c:	83 c4 08             	add    $0x8,%esp
  80111f:	89 c2                	mov    %eax,%edx
  801121:	85 c0                	test   %eax,%eax
  801123:	78 6d                	js     801192 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801125:	83 ec 08             	sub    $0x8,%esp
  801128:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80112b:	50                   	push   %eax
  80112c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80112f:	ff 30                	pushl  (%eax)
  801131:	e8 c2 fd ff ff       	call   800ef8 <dev_lookup>
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	85 c0                	test   %eax,%eax
  80113b:	78 4c                	js     801189 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80113d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801140:	8b 42 08             	mov    0x8(%edx),%eax
  801143:	83 e0 03             	and    $0x3,%eax
  801146:	83 f8 01             	cmp    $0x1,%eax
  801149:	75 21                	jne    80116c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80114b:	a1 08 40 80 00       	mov    0x804008,%eax
  801150:	8b 40 48             	mov    0x48(%eax),%eax
  801153:	83 ec 04             	sub    $0x4,%esp
  801156:	53                   	push   %ebx
  801157:	50                   	push   %eax
  801158:	68 6d 23 80 00       	push   $0x80236d
  80115d:	e8 2b f0 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  801162:	83 c4 10             	add    $0x10,%esp
  801165:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80116a:	eb 26                	jmp    801192 <read+0x8a>
	}
	if (!dev->dev_read)
  80116c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116f:	8b 40 08             	mov    0x8(%eax),%eax
  801172:	85 c0                	test   %eax,%eax
  801174:	74 17                	je     80118d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801176:	83 ec 04             	sub    $0x4,%esp
  801179:	ff 75 10             	pushl  0x10(%ebp)
  80117c:	ff 75 0c             	pushl  0xc(%ebp)
  80117f:	52                   	push   %edx
  801180:	ff d0                	call   *%eax
  801182:	89 c2                	mov    %eax,%edx
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	eb 09                	jmp    801192 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801189:	89 c2                	mov    %eax,%edx
  80118b:	eb 05                	jmp    801192 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80118d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801192:	89 d0                	mov    %edx,%eax
  801194:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801197:	c9                   	leave  
  801198:	c3                   	ret    

00801199 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	57                   	push   %edi
  80119d:	56                   	push   %esi
  80119e:	53                   	push   %ebx
  80119f:	83 ec 0c             	sub    $0xc,%esp
  8011a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011a5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ad:	eb 21                	jmp    8011d0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011af:	83 ec 04             	sub    $0x4,%esp
  8011b2:	89 f0                	mov    %esi,%eax
  8011b4:	29 d8                	sub    %ebx,%eax
  8011b6:	50                   	push   %eax
  8011b7:	89 d8                	mov    %ebx,%eax
  8011b9:	03 45 0c             	add    0xc(%ebp),%eax
  8011bc:	50                   	push   %eax
  8011bd:	57                   	push   %edi
  8011be:	e8 45 ff ff ff       	call   801108 <read>
		if (m < 0)
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	78 10                	js     8011da <readn+0x41>
			return m;
		if (m == 0)
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	74 0a                	je     8011d8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ce:	01 c3                	add    %eax,%ebx
  8011d0:	39 f3                	cmp    %esi,%ebx
  8011d2:	72 db                	jb     8011af <readn+0x16>
  8011d4:	89 d8                	mov    %ebx,%eax
  8011d6:	eb 02                	jmp    8011da <readn+0x41>
  8011d8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5f                   	pop    %edi
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	53                   	push   %ebx
  8011e6:	83 ec 14             	sub    $0x14,%esp
  8011e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ef:	50                   	push   %eax
  8011f0:	53                   	push   %ebx
  8011f1:	e8 ac fc ff ff       	call   800ea2 <fd_lookup>
  8011f6:	83 c4 08             	add    $0x8,%esp
  8011f9:	89 c2                	mov    %eax,%edx
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	78 68                	js     801267 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ff:	83 ec 08             	sub    $0x8,%esp
  801202:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801205:	50                   	push   %eax
  801206:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801209:	ff 30                	pushl  (%eax)
  80120b:	e8 e8 fc ff ff       	call   800ef8 <dev_lookup>
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	85 c0                	test   %eax,%eax
  801215:	78 47                	js     80125e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801217:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80121e:	75 21                	jne    801241 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801220:	a1 08 40 80 00       	mov    0x804008,%eax
  801225:	8b 40 48             	mov    0x48(%eax),%eax
  801228:	83 ec 04             	sub    $0x4,%esp
  80122b:	53                   	push   %ebx
  80122c:	50                   	push   %eax
  80122d:	68 89 23 80 00       	push   $0x802389
  801232:	e8 56 ef ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80123f:	eb 26                	jmp    801267 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801241:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801244:	8b 52 0c             	mov    0xc(%edx),%edx
  801247:	85 d2                	test   %edx,%edx
  801249:	74 17                	je     801262 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80124b:	83 ec 04             	sub    $0x4,%esp
  80124e:	ff 75 10             	pushl  0x10(%ebp)
  801251:	ff 75 0c             	pushl  0xc(%ebp)
  801254:	50                   	push   %eax
  801255:	ff d2                	call   *%edx
  801257:	89 c2                	mov    %eax,%edx
  801259:	83 c4 10             	add    $0x10,%esp
  80125c:	eb 09                	jmp    801267 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125e:	89 c2                	mov    %eax,%edx
  801260:	eb 05                	jmp    801267 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801262:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801267:	89 d0                	mov    %edx,%eax
  801269:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <seek>:

int
seek(int fdnum, off_t offset)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801274:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801277:	50                   	push   %eax
  801278:	ff 75 08             	pushl  0x8(%ebp)
  80127b:	e8 22 fc ff ff       	call   800ea2 <fd_lookup>
  801280:	83 c4 08             	add    $0x8,%esp
  801283:	85 c0                	test   %eax,%eax
  801285:	78 0e                	js     801295 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801287:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80128a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801290:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801295:	c9                   	leave  
  801296:	c3                   	ret    

00801297 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	53                   	push   %ebx
  80129b:	83 ec 14             	sub    $0x14,%esp
  80129e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a4:	50                   	push   %eax
  8012a5:	53                   	push   %ebx
  8012a6:	e8 f7 fb ff ff       	call   800ea2 <fd_lookup>
  8012ab:	83 c4 08             	add    $0x8,%esp
  8012ae:	89 c2                	mov    %eax,%edx
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	78 65                	js     801319 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b4:	83 ec 08             	sub    $0x8,%esp
  8012b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ba:	50                   	push   %eax
  8012bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012be:	ff 30                	pushl  (%eax)
  8012c0:	e8 33 fc ff ff       	call   800ef8 <dev_lookup>
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	78 44                	js     801310 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d3:	75 21                	jne    8012f6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012d5:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012da:	8b 40 48             	mov    0x48(%eax),%eax
  8012dd:	83 ec 04             	sub    $0x4,%esp
  8012e0:	53                   	push   %ebx
  8012e1:	50                   	push   %eax
  8012e2:	68 4c 23 80 00       	push   $0x80234c
  8012e7:	e8 a1 ee ff ff       	call   80018d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012f4:	eb 23                	jmp    801319 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012f9:	8b 52 18             	mov    0x18(%edx),%edx
  8012fc:	85 d2                	test   %edx,%edx
  8012fe:	74 14                	je     801314 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801300:	83 ec 08             	sub    $0x8,%esp
  801303:	ff 75 0c             	pushl  0xc(%ebp)
  801306:	50                   	push   %eax
  801307:	ff d2                	call   *%edx
  801309:	89 c2                	mov    %eax,%edx
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	eb 09                	jmp    801319 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801310:	89 c2                	mov    %eax,%edx
  801312:	eb 05                	jmp    801319 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801314:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801319:	89 d0                	mov    %edx,%eax
  80131b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131e:	c9                   	leave  
  80131f:	c3                   	ret    

00801320 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	53                   	push   %ebx
  801324:	83 ec 14             	sub    $0x14,%esp
  801327:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132d:	50                   	push   %eax
  80132e:	ff 75 08             	pushl  0x8(%ebp)
  801331:	e8 6c fb ff ff       	call   800ea2 <fd_lookup>
  801336:	83 c4 08             	add    $0x8,%esp
  801339:	89 c2                	mov    %eax,%edx
  80133b:	85 c0                	test   %eax,%eax
  80133d:	78 58                	js     801397 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133f:	83 ec 08             	sub    $0x8,%esp
  801342:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801345:	50                   	push   %eax
  801346:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801349:	ff 30                	pushl  (%eax)
  80134b:	e8 a8 fb ff ff       	call   800ef8 <dev_lookup>
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	85 c0                	test   %eax,%eax
  801355:	78 37                	js     80138e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801357:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80135e:	74 32                	je     801392 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801360:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801363:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80136a:	00 00 00 
	stat->st_isdir = 0;
  80136d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801374:	00 00 00 
	stat->st_dev = dev;
  801377:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80137d:	83 ec 08             	sub    $0x8,%esp
  801380:	53                   	push   %ebx
  801381:	ff 75 f0             	pushl  -0x10(%ebp)
  801384:	ff 50 14             	call   *0x14(%eax)
  801387:	89 c2                	mov    %eax,%edx
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	eb 09                	jmp    801397 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138e:	89 c2                	mov    %eax,%edx
  801390:	eb 05                	jmp    801397 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801392:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801397:	89 d0                	mov    %edx,%eax
  801399:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139c:	c9                   	leave  
  80139d:	c3                   	ret    

0080139e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	56                   	push   %esi
  8013a2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013a3:	83 ec 08             	sub    $0x8,%esp
  8013a6:	6a 00                	push   $0x0
  8013a8:	ff 75 08             	pushl  0x8(%ebp)
  8013ab:	e8 2b 02 00 00       	call   8015db <open>
  8013b0:	89 c3                	mov    %eax,%ebx
  8013b2:	83 c4 10             	add    $0x10,%esp
  8013b5:	85 c0                	test   %eax,%eax
  8013b7:	78 1b                	js     8013d4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013b9:	83 ec 08             	sub    $0x8,%esp
  8013bc:	ff 75 0c             	pushl  0xc(%ebp)
  8013bf:	50                   	push   %eax
  8013c0:	e8 5b ff ff ff       	call   801320 <fstat>
  8013c5:	89 c6                	mov    %eax,%esi
	close(fd);
  8013c7:	89 1c 24             	mov    %ebx,(%esp)
  8013ca:	e8 fd fb ff ff       	call   800fcc <close>
	return r;
  8013cf:	83 c4 10             	add    $0x10,%esp
  8013d2:	89 f0                	mov    %esi,%eax
}
  8013d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d7:	5b                   	pop    %ebx
  8013d8:	5e                   	pop    %esi
  8013d9:	5d                   	pop    %ebp
  8013da:	c3                   	ret    

008013db <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	56                   	push   %esi
  8013df:	53                   	push   %ebx
  8013e0:	89 c6                	mov    %eax,%esi
  8013e2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013e4:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8013eb:	75 12                	jne    8013ff <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013ed:	83 ec 0c             	sub    $0xc,%esp
  8013f0:	6a 01                	push   $0x1
  8013f2:	e8 6c 08 00 00       	call   801c63 <ipc_find_env>
  8013f7:	a3 04 40 80 00       	mov    %eax,0x804004
  8013fc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013ff:	6a 07                	push   $0x7
  801401:	68 00 50 80 00       	push   $0x805000
  801406:	56                   	push   %esi
  801407:	ff 35 04 40 80 00    	pushl  0x804004
  80140d:	e8 fb 07 00 00       	call   801c0d <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801412:	83 c4 0c             	add    $0xc,%esp
  801415:	6a 00                	push   $0x0
  801417:	53                   	push   %ebx
  801418:	6a 00                	push   $0x0
  80141a:	e8 85 07 00 00       	call   801ba4 <ipc_recv>
}
  80141f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801422:	5b                   	pop    %ebx
  801423:	5e                   	pop    %esi
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    

00801426 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80142c:	8b 45 08             	mov    0x8(%ebp),%eax
  80142f:	8b 40 0c             	mov    0xc(%eax),%eax
  801432:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801437:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80143f:	ba 00 00 00 00       	mov    $0x0,%edx
  801444:	b8 02 00 00 00       	mov    $0x2,%eax
  801449:	e8 8d ff ff ff       	call   8013db <fsipc>
}
  80144e:	c9                   	leave  
  80144f:	c3                   	ret    

00801450 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801456:	8b 45 08             	mov    0x8(%ebp),%eax
  801459:	8b 40 0c             	mov    0xc(%eax),%eax
  80145c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801461:	ba 00 00 00 00       	mov    $0x0,%edx
  801466:	b8 06 00 00 00       	mov    $0x6,%eax
  80146b:	e8 6b ff ff ff       	call   8013db <fsipc>
}
  801470:	c9                   	leave  
  801471:	c3                   	ret    

00801472 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	53                   	push   %ebx
  801476:	83 ec 04             	sub    $0x4,%esp
  801479:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80147c:	8b 45 08             	mov    0x8(%ebp),%eax
  80147f:	8b 40 0c             	mov    0xc(%eax),%eax
  801482:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801487:	ba 00 00 00 00       	mov    $0x0,%edx
  80148c:	b8 05 00 00 00       	mov    $0x5,%eax
  801491:	e8 45 ff ff ff       	call   8013db <fsipc>
  801496:	85 c0                	test   %eax,%eax
  801498:	78 2c                	js     8014c6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80149a:	83 ec 08             	sub    $0x8,%esp
  80149d:	68 00 50 80 00       	push   $0x805000
  8014a2:	53                   	push   %ebx
  8014a3:	e8 19 f3 ff ff       	call   8007c1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014a8:	a1 80 50 80 00       	mov    0x805080,%eax
  8014ad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014b3:	a1 84 50 80 00       	mov    0x805084,%eax
  8014b8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c9:	c9                   	leave  
  8014ca:	c3                   	ret    

008014cb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	53                   	push   %ebx
  8014cf:	83 ec 08             	sub    $0x8,%esp
  8014d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8014d5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014da:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8014df:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  8014ed:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014f3:	53                   	push   %ebx
  8014f4:	ff 75 0c             	pushl  0xc(%ebp)
  8014f7:	68 08 50 80 00       	push   $0x805008
  8014fc:	e8 52 f4 ff ff       	call   800953 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801501:	ba 00 00 00 00       	mov    $0x0,%edx
  801506:	b8 04 00 00 00       	mov    $0x4,%eax
  80150b:	e8 cb fe ff ff       	call   8013db <fsipc>
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	85 c0                	test   %eax,%eax
  801515:	78 3d                	js     801554 <devfile_write+0x89>
		return r;

	assert(r <= n);
  801517:	39 d8                	cmp    %ebx,%eax
  801519:	76 19                	jbe    801534 <devfile_write+0x69>
  80151b:	68 b8 23 80 00       	push   $0x8023b8
  801520:	68 bf 23 80 00       	push   $0x8023bf
  801525:	68 9f 00 00 00       	push   $0x9f
  80152a:	68 d4 23 80 00       	push   $0x8023d4
  80152f:	e8 2a 06 00 00       	call   801b5e <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801534:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801539:	76 19                	jbe    801554 <devfile_write+0x89>
  80153b:	68 ec 23 80 00       	push   $0x8023ec
  801540:	68 bf 23 80 00       	push   $0x8023bf
  801545:	68 a0 00 00 00       	push   $0xa0
  80154a:	68 d4 23 80 00       	push   $0x8023d4
  80154f:	e8 0a 06 00 00       	call   801b5e <_panic>

	return r;
}
  801554:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801557:	c9                   	leave  
  801558:	c3                   	ret    

00801559 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	56                   	push   %esi
  80155d:	53                   	push   %ebx
  80155e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801561:	8b 45 08             	mov    0x8(%ebp),%eax
  801564:	8b 40 0c             	mov    0xc(%eax),%eax
  801567:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80156c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801572:	ba 00 00 00 00       	mov    $0x0,%edx
  801577:	b8 03 00 00 00       	mov    $0x3,%eax
  80157c:	e8 5a fe ff ff       	call   8013db <fsipc>
  801581:	89 c3                	mov    %eax,%ebx
  801583:	85 c0                	test   %eax,%eax
  801585:	78 4b                	js     8015d2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801587:	39 c6                	cmp    %eax,%esi
  801589:	73 16                	jae    8015a1 <devfile_read+0x48>
  80158b:	68 b8 23 80 00       	push   $0x8023b8
  801590:	68 bf 23 80 00       	push   $0x8023bf
  801595:	6a 7e                	push   $0x7e
  801597:	68 d4 23 80 00       	push   $0x8023d4
  80159c:	e8 bd 05 00 00       	call   801b5e <_panic>
	assert(r <= PGSIZE);
  8015a1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015a6:	7e 16                	jle    8015be <devfile_read+0x65>
  8015a8:	68 df 23 80 00       	push   $0x8023df
  8015ad:	68 bf 23 80 00       	push   $0x8023bf
  8015b2:	6a 7f                	push   $0x7f
  8015b4:	68 d4 23 80 00       	push   $0x8023d4
  8015b9:	e8 a0 05 00 00       	call   801b5e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015be:	83 ec 04             	sub    $0x4,%esp
  8015c1:	50                   	push   %eax
  8015c2:	68 00 50 80 00       	push   $0x805000
  8015c7:	ff 75 0c             	pushl  0xc(%ebp)
  8015ca:	e8 84 f3 ff ff       	call   800953 <memmove>
	return r;
  8015cf:	83 c4 10             	add    $0x10,%esp
}
  8015d2:	89 d8                	mov    %ebx,%eax
  8015d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d7:	5b                   	pop    %ebx
  8015d8:	5e                   	pop    %esi
  8015d9:	5d                   	pop    %ebp
  8015da:	c3                   	ret    

008015db <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	53                   	push   %ebx
  8015df:	83 ec 20             	sub    $0x20,%esp
  8015e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015e5:	53                   	push   %ebx
  8015e6:	e8 9d f1 ff ff       	call   800788 <strlen>
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015f3:	7f 67                	jg     80165c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015f5:	83 ec 0c             	sub    $0xc,%esp
  8015f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fb:	50                   	push   %eax
  8015fc:	e8 52 f8 ff ff       	call   800e53 <fd_alloc>
  801601:	83 c4 10             	add    $0x10,%esp
		return r;
  801604:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801606:	85 c0                	test   %eax,%eax
  801608:	78 57                	js     801661 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80160a:	83 ec 08             	sub    $0x8,%esp
  80160d:	53                   	push   %ebx
  80160e:	68 00 50 80 00       	push   $0x805000
  801613:	e8 a9 f1 ff ff       	call   8007c1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801618:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801620:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801623:	b8 01 00 00 00       	mov    $0x1,%eax
  801628:	e8 ae fd ff ff       	call   8013db <fsipc>
  80162d:	89 c3                	mov    %eax,%ebx
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	85 c0                	test   %eax,%eax
  801634:	79 14                	jns    80164a <open+0x6f>
		fd_close(fd, 0);
  801636:	83 ec 08             	sub    $0x8,%esp
  801639:	6a 00                	push   $0x0
  80163b:	ff 75 f4             	pushl  -0xc(%ebp)
  80163e:	e8 08 f9 ff ff       	call   800f4b <fd_close>
		return r;
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	89 da                	mov    %ebx,%edx
  801648:	eb 17                	jmp    801661 <open+0x86>
	}

	return fd2num(fd);
  80164a:	83 ec 0c             	sub    $0xc,%esp
  80164d:	ff 75 f4             	pushl  -0xc(%ebp)
  801650:	e8 d7 f7 ff ff       	call   800e2c <fd2num>
  801655:	89 c2                	mov    %eax,%edx
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	eb 05                	jmp    801661 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80165c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801661:	89 d0                	mov    %edx,%eax
  801663:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801666:	c9                   	leave  
  801667:	c3                   	ret    

00801668 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80166e:	ba 00 00 00 00       	mov    $0x0,%edx
  801673:	b8 08 00 00 00       	mov    $0x8,%eax
  801678:	e8 5e fd ff ff       	call   8013db <fsipc>
}
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	56                   	push   %esi
  801683:	53                   	push   %ebx
  801684:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801687:	83 ec 0c             	sub    $0xc,%esp
  80168a:	ff 75 08             	pushl  0x8(%ebp)
  80168d:	e8 aa f7 ff ff       	call   800e3c <fd2data>
  801692:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801694:	83 c4 08             	add    $0x8,%esp
  801697:	68 19 24 80 00       	push   $0x802419
  80169c:	53                   	push   %ebx
  80169d:	e8 1f f1 ff ff       	call   8007c1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016a2:	8b 46 04             	mov    0x4(%esi),%eax
  8016a5:	2b 06                	sub    (%esi),%eax
  8016a7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016ad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016b4:	00 00 00 
	stat->st_dev = &devpipe;
  8016b7:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016be:	30 80 00 
	return 0;
}
  8016c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c9:	5b                   	pop    %ebx
  8016ca:	5e                   	pop    %esi
  8016cb:	5d                   	pop    %ebp
  8016cc:	c3                   	ret    

008016cd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	53                   	push   %ebx
  8016d1:	83 ec 0c             	sub    $0xc,%esp
  8016d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016d7:	53                   	push   %ebx
  8016d8:	6a 00                	push   $0x0
  8016da:	e8 e1 f5 ff ff       	call   800cc0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016df:	89 1c 24             	mov    %ebx,(%esp)
  8016e2:	e8 55 f7 ff ff       	call   800e3c <fd2data>
  8016e7:	83 c4 08             	add    $0x8,%esp
  8016ea:	50                   	push   %eax
  8016eb:	6a 00                	push   $0x0
  8016ed:	e8 ce f5 ff ff       	call   800cc0 <sys_page_unmap>
}
  8016f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	57                   	push   %edi
  8016fb:	56                   	push   %esi
  8016fc:	53                   	push   %ebx
  8016fd:	83 ec 1c             	sub    $0x1c,%esp
  801700:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801703:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801705:	a1 08 40 80 00       	mov    0x804008,%eax
  80170a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80170d:	83 ec 0c             	sub    $0xc,%esp
  801710:	ff 75 e0             	pushl  -0x20(%ebp)
  801713:	e8 84 05 00 00       	call   801c9c <pageref>
  801718:	89 c3                	mov    %eax,%ebx
  80171a:	89 3c 24             	mov    %edi,(%esp)
  80171d:	e8 7a 05 00 00       	call   801c9c <pageref>
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	39 c3                	cmp    %eax,%ebx
  801727:	0f 94 c1             	sete   %cl
  80172a:	0f b6 c9             	movzbl %cl,%ecx
  80172d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801730:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801736:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801739:	39 ce                	cmp    %ecx,%esi
  80173b:	74 1b                	je     801758 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80173d:	39 c3                	cmp    %eax,%ebx
  80173f:	75 c4                	jne    801705 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801741:	8b 42 58             	mov    0x58(%edx),%eax
  801744:	ff 75 e4             	pushl  -0x1c(%ebp)
  801747:	50                   	push   %eax
  801748:	56                   	push   %esi
  801749:	68 20 24 80 00       	push   $0x802420
  80174e:	e8 3a ea ff ff       	call   80018d <cprintf>
  801753:	83 c4 10             	add    $0x10,%esp
  801756:	eb ad                	jmp    801705 <_pipeisclosed+0xe>
	}
}
  801758:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80175b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175e:	5b                   	pop    %ebx
  80175f:	5e                   	pop    %esi
  801760:	5f                   	pop    %edi
  801761:	5d                   	pop    %ebp
  801762:	c3                   	ret    

00801763 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	57                   	push   %edi
  801767:	56                   	push   %esi
  801768:	53                   	push   %ebx
  801769:	83 ec 28             	sub    $0x28,%esp
  80176c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80176f:	56                   	push   %esi
  801770:	e8 c7 f6 ff ff       	call   800e3c <fd2data>
  801775:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	bf 00 00 00 00       	mov    $0x0,%edi
  80177f:	eb 4b                	jmp    8017cc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801781:	89 da                	mov    %ebx,%edx
  801783:	89 f0                	mov    %esi,%eax
  801785:	e8 6d ff ff ff       	call   8016f7 <_pipeisclosed>
  80178a:	85 c0                	test   %eax,%eax
  80178c:	75 48                	jne    8017d6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80178e:	e8 89 f4 ff ff       	call   800c1c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801793:	8b 43 04             	mov    0x4(%ebx),%eax
  801796:	8b 0b                	mov    (%ebx),%ecx
  801798:	8d 51 20             	lea    0x20(%ecx),%edx
  80179b:	39 d0                	cmp    %edx,%eax
  80179d:	73 e2                	jae    801781 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80179f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017a2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017a6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017a9:	89 c2                	mov    %eax,%edx
  8017ab:	c1 fa 1f             	sar    $0x1f,%edx
  8017ae:	89 d1                	mov    %edx,%ecx
  8017b0:	c1 e9 1b             	shr    $0x1b,%ecx
  8017b3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017b6:	83 e2 1f             	and    $0x1f,%edx
  8017b9:	29 ca                	sub    %ecx,%edx
  8017bb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017bf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017c3:	83 c0 01             	add    $0x1,%eax
  8017c6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017c9:	83 c7 01             	add    $0x1,%edi
  8017cc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017cf:	75 c2                	jne    801793 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8017d4:	eb 05                	jmp    8017db <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017d6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017de:	5b                   	pop    %ebx
  8017df:	5e                   	pop    %esi
  8017e0:	5f                   	pop    %edi
  8017e1:	5d                   	pop    %ebp
  8017e2:	c3                   	ret    

008017e3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	57                   	push   %edi
  8017e7:	56                   	push   %esi
  8017e8:	53                   	push   %ebx
  8017e9:	83 ec 18             	sub    $0x18,%esp
  8017ec:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017ef:	57                   	push   %edi
  8017f0:	e8 47 f6 ff ff       	call   800e3c <fd2data>
  8017f5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f7:	83 c4 10             	add    $0x10,%esp
  8017fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017ff:	eb 3d                	jmp    80183e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801801:	85 db                	test   %ebx,%ebx
  801803:	74 04                	je     801809 <devpipe_read+0x26>
				return i;
  801805:	89 d8                	mov    %ebx,%eax
  801807:	eb 44                	jmp    80184d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801809:	89 f2                	mov    %esi,%edx
  80180b:	89 f8                	mov    %edi,%eax
  80180d:	e8 e5 fe ff ff       	call   8016f7 <_pipeisclosed>
  801812:	85 c0                	test   %eax,%eax
  801814:	75 32                	jne    801848 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801816:	e8 01 f4 ff ff       	call   800c1c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80181b:	8b 06                	mov    (%esi),%eax
  80181d:	3b 46 04             	cmp    0x4(%esi),%eax
  801820:	74 df                	je     801801 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801822:	99                   	cltd   
  801823:	c1 ea 1b             	shr    $0x1b,%edx
  801826:	01 d0                	add    %edx,%eax
  801828:	83 e0 1f             	and    $0x1f,%eax
  80182b:	29 d0                	sub    %edx,%eax
  80182d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801835:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801838:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80183b:	83 c3 01             	add    $0x1,%ebx
  80183e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801841:	75 d8                	jne    80181b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801843:	8b 45 10             	mov    0x10(%ebp),%eax
  801846:	eb 05                	jmp    80184d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801848:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80184d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801850:	5b                   	pop    %ebx
  801851:	5e                   	pop    %esi
  801852:	5f                   	pop    %edi
  801853:	5d                   	pop    %ebp
  801854:	c3                   	ret    

00801855 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	56                   	push   %esi
  801859:	53                   	push   %ebx
  80185a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80185d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801860:	50                   	push   %eax
  801861:	e8 ed f5 ff ff       	call   800e53 <fd_alloc>
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	89 c2                	mov    %eax,%edx
  80186b:	85 c0                	test   %eax,%eax
  80186d:	0f 88 2c 01 00 00    	js     80199f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801873:	83 ec 04             	sub    $0x4,%esp
  801876:	68 07 04 00 00       	push   $0x407
  80187b:	ff 75 f4             	pushl  -0xc(%ebp)
  80187e:	6a 00                	push   $0x0
  801880:	e8 b6 f3 ff ff       	call   800c3b <sys_page_alloc>
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	89 c2                	mov    %eax,%edx
  80188a:	85 c0                	test   %eax,%eax
  80188c:	0f 88 0d 01 00 00    	js     80199f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801892:	83 ec 0c             	sub    $0xc,%esp
  801895:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801898:	50                   	push   %eax
  801899:	e8 b5 f5 ff ff       	call   800e53 <fd_alloc>
  80189e:	89 c3                	mov    %eax,%ebx
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	0f 88 e2 00 00 00    	js     80198d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ab:	83 ec 04             	sub    $0x4,%esp
  8018ae:	68 07 04 00 00       	push   $0x407
  8018b3:	ff 75 f0             	pushl  -0x10(%ebp)
  8018b6:	6a 00                	push   $0x0
  8018b8:	e8 7e f3 ff ff       	call   800c3b <sys_page_alloc>
  8018bd:	89 c3                	mov    %eax,%ebx
  8018bf:	83 c4 10             	add    $0x10,%esp
  8018c2:	85 c0                	test   %eax,%eax
  8018c4:	0f 88 c3 00 00 00    	js     80198d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018ca:	83 ec 0c             	sub    $0xc,%esp
  8018cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d0:	e8 67 f5 ff ff       	call   800e3c <fd2data>
  8018d5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d7:	83 c4 0c             	add    $0xc,%esp
  8018da:	68 07 04 00 00       	push   $0x407
  8018df:	50                   	push   %eax
  8018e0:	6a 00                	push   $0x0
  8018e2:	e8 54 f3 ff ff       	call   800c3b <sys_page_alloc>
  8018e7:	89 c3                	mov    %eax,%ebx
  8018e9:	83 c4 10             	add    $0x10,%esp
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	0f 88 89 00 00 00    	js     80197d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018f4:	83 ec 0c             	sub    $0xc,%esp
  8018f7:	ff 75 f0             	pushl  -0x10(%ebp)
  8018fa:	e8 3d f5 ff ff       	call   800e3c <fd2data>
  8018ff:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801906:	50                   	push   %eax
  801907:	6a 00                	push   $0x0
  801909:	56                   	push   %esi
  80190a:	6a 00                	push   $0x0
  80190c:	e8 6d f3 ff ff       	call   800c7e <sys_page_map>
  801911:	89 c3                	mov    %eax,%ebx
  801913:	83 c4 20             	add    $0x20,%esp
  801916:	85 c0                	test   %eax,%eax
  801918:	78 55                	js     80196f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80191a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801920:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801923:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801925:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801928:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80192f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801935:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801938:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80193a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801944:	83 ec 0c             	sub    $0xc,%esp
  801947:	ff 75 f4             	pushl  -0xc(%ebp)
  80194a:	e8 dd f4 ff ff       	call   800e2c <fd2num>
  80194f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801952:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801954:	83 c4 04             	add    $0x4,%esp
  801957:	ff 75 f0             	pushl  -0x10(%ebp)
  80195a:	e8 cd f4 ff ff       	call   800e2c <fd2num>
  80195f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801962:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	ba 00 00 00 00       	mov    $0x0,%edx
  80196d:	eb 30                	jmp    80199f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80196f:	83 ec 08             	sub    $0x8,%esp
  801972:	56                   	push   %esi
  801973:	6a 00                	push   $0x0
  801975:	e8 46 f3 ff ff       	call   800cc0 <sys_page_unmap>
  80197a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80197d:	83 ec 08             	sub    $0x8,%esp
  801980:	ff 75 f0             	pushl  -0x10(%ebp)
  801983:	6a 00                	push   $0x0
  801985:	e8 36 f3 ff ff       	call   800cc0 <sys_page_unmap>
  80198a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80198d:	83 ec 08             	sub    $0x8,%esp
  801990:	ff 75 f4             	pushl  -0xc(%ebp)
  801993:	6a 00                	push   $0x0
  801995:	e8 26 f3 ff ff       	call   800cc0 <sys_page_unmap>
  80199a:	83 c4 10             	add    $0x10,%esp
  80199d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80199f:	89 d0                	mov    %edx,%eax
  8019a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a4:	5b                   	pop    %ebx
  8019a5:	5e                   	pop    %esi
  8019a6:	5d                   	pop    %ebp
  8019a7:	c3                   	ret    

008019a8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b1:	50                   	push   %eax
  8019b2:	ff 75 08             	pushl  0x8(%ebp)
  8019b5:	e8 e8 f4 ff ff       	call   800ea2 <fd_lookup>
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	85 c0                	test   %eax,%eax
  8019bf:	78 18                	js     8019d9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019c1:	83 ec 0c             	sub    $0xc,%esp
  8019c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c7:	e8 70 f4 ff ff       	call   800e3c <fd2data>
	return _pipeisclosed(fd, p);
  8019cc:	89 c2                	mov    %eax,%edx
  8019ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d1:	e8 21 fd ff ff       	call   8016f7 <_pipeisclosed>
  8019d6:	83 c4 10             	add    $0x10,%esp
}
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019de:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e3:	5d                   	pop    %ebp
  8019e4:	c3                   	ret    

008019e5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019eb:	68 38 24 80 00       	push   $0x802438
  8019f0:	ff 75 0c             	pushl  0xc(%ebp)
  8019f3:	e8 c9 ed ff ff       	call   8007c1 <strcpy>
	return 0;
}
  8019f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fd:	c9                   	leave  
  8019fe:	c3                   	ret    

008019ff <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	57                   	push   %edi
  801a03:	56                   	push   %esi
  801a04:	53                   	push   %ebx
  801a05:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a0b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a10:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a16:	eb 2d                	jmp    801a45 <devcons_write+0x46>
		m = n - tot;
  801a18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a1b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a1d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a20:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a25:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a28:	83 ec 04             	sub    $0x4,%esp
  801a2b:	53                   	push   %ebx
  801a2c:	03 45 0c             	add    0xc(%ebp),%eax
  801a2f:	50                   	push   %eax
  801a30:	57                   	push   %edi
  801a31:	e8 1d ef ff ff       	call   800953 <memmove>
		sys_cputs(buf, m);
  801a36:	83 c4 08             	add    $0x8,%esp
  801a39:	53                   	push   %ebx
  801a3a:	57                   	push   %edi
  801a3b:	e8 3f f1 ff ff       	call   800b7f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a40:	01 de                	add    %ebx,%esi
  801a42:	83 c4 10             	add    $0x10,%esp
  801a45:	89 f0                	mov    %esi,%eax
  801a47:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a4a:	72 cc                	jb     801a18 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a4f:	5b                   	pop    %ebx
  801a50:	5e                   	pop    %esi
  801a51:	5f                   	pop    %edi
  801a52:	5d                   	pop    %ebp
  801a53:	c3                   	ret    

00801a54 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	83 ec 08             	sub    $0x8,%esp
  801a5a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a5f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a63:	74 2a                	je     801a8f <devcons_read+0x3b>
  801a65:	eb 05                	jmp    801a6c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a67:	e8 b0 f1 ff ff       	call   800c1c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a6c:	e8 2c f1 ff ff       	call   800b9d <sys_cgetc>
  801a71:	85 c0                	test   %eax,%eax
  801a73:	74 f2                	je     801a67 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a75:	85 c0                	test   %eax,%eax
  801a77:	78 16                	js     801a8f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a79:	83 f8 04             	cmp    $0x4,%eax
  801a7c:	74 0c                	je     801a8a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a81:	88 02                	mov    %al,(%edx)
	return 1;
  801a83:	b8 01 00 00 00       	mov    $0x1,%eax
  801a88:	eb 05                	jmp    801a8f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a8a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a8f:	c9                   	leave  
  801a90:	c3                   	ret    

00801a91 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a97:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a9d:	6a 01                	push   $0x1
  801a9f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aa2:	50                   	push   %eax
  801aa3:	e8 d7 f0 ff ff       	call   800b7f <sys_cputs>
}
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	c9                   	leave  
  801aac:	c3                   	ret    

00801aad <getchar>:

int
getchar(void)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ab3:	6a 01                	push   $0x1
  801ab5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ab8:	50                   	push   %eax
  801ab9:	6a 00                	push   $0x0
  801abb:	e8 48 f6 ff ff       	call   801108 <read>
	if (r < 0)
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	78 0f                	js     801ad6 <getchar+0x29>
		return r;
	if (r < 1)
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	7e 06                	jle    801ad1 <getchar+0x24>
		return -E_EOF;
	return c;
  801acb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801acf:	eb 05                	jmp    801ad6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ad1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ad6:	c9                   	leave  
  801ad7:	c3                   	ret    

00801ad8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ade:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae1:	50                   	push   %eax
  801ae2:	ff 75 08             	pushl  0x8(%ebp)
  801ae5:	e8 b8 f3 ff ff       	call   800ea2 <fd_lookup>
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	85 c0                	test   %eax,%eax
  801aef:	78 11                	js     801b02 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801afa:	39 10                	cmp    %edx,(%eax)
  801afc:	0f 94 c0             	sete   %al
  801aff:	0f b6 c0             	movzbl %al,%eax
}
  801b02:	c9                   	leave  
  801b03:	c3                   	ret    

00801b04 <opencons>:

int
opencons(void)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b0d:	50                   	push   %eax
  801b0e:	e8 40 f3 ff ff       	call   800e53 <fd_alloc>
  801b13:	83 c4 10             	add    $0x10,%esp
		return r;
  801b16:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b18:	85 c0                	test   %eax,%eax
  801b1a:	78 3e                	js     801b5a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b1c:	83 ec 04             	sub    $0x4,%esp
  801b1f:	68 07 04 00 00       	push   $0x407
  801b24:	ff 75 f4             	pushl  -0xc(%ebp)
  801b27:	6a 00                	push   $0x0
  801b29:	e8 0d f1 ff ff       	call   800c3b <sys_page_alloc>
  801b2e:	83 c4 10             	add    $0x10,%esp
		return r;
  801b31:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b33:	85 c0                	test   %eax,%eax
  801b35:	78 23                	js     801b5a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b37:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b40:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b45:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b4c:	83 ec 0c             	sub    $0xc,%esp
  801b4f:	50                   	push   %eax
  801b50:	e8 d7 f2 ff ff       	call   800e2c <fd2num>
  801b55:	89 c2                	mov    %eax,%edx
  801b57:	83 c4 10             	add    $0x10,%esp
}
  801b5a:	89 d0                	mov    %edx,%eax
  801b5c:	c9                   	leave  
  801b5d:	c3                   	ret    

00801b5e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	56                   	push   %esi
  801b62:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b63:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b66:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b6c:	e8 8c f0 ff ff       	call   800bfd <sys_getenvid>
  801b71:	83 ec 0c             	sub    $0xc,%esp
  801b74:	ff 75 0c             	pushl  0xc(%ebp)
  801b77:	ff 75 08             	pushl  0x8(%ebp)
  801b7a:	56                   	push   %esi
  801b7b:	50                   	push   %eax
  801b7c:	68 44 24 80 00       	push   $0x802444
  801b81:	e8 07 e6 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b86:	83 c4 18             	add    $0x18,%esp
  801b89:	53                   	push   %ebx
  801b8a:	ff 75 10             	pushl  0x10(%ebp)
  801b8d:	e8 aa e5 ff ff       	call   80013c <vcprintf>
	cprintf("\n");
  801b92:	c7 04 24 31 24 80 00 	movl   $0x802431,(%esp)
  801b99:	e8 ef e5 ff ff       	call   80018d <cprintf>
  801b9e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ba1:	cc                   	int3   
  801ba2:	eb fd                	jmp    801ba1 <_panic+0x43>

00801ba4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	56                   	push   %esi
  801ba8:	53                   	push   %ebx
  801ba9:	8b 75 08             	mov    0x8(%ebp),%esi
  801bac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801baf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801bb2:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801bb4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801bb9:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801bbc:	83 ec 0c             	sub    $0xc,%esp
  801bbf:	50                   	push   %eax
  801bc0:	e8 26 f2 ff ff       	call   800deb <sys_ipc_recv>
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	79 16                	jns    801be2 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801bcc:	85 f6                	test   %esi,%esi
  801bce:	74 06                	je     801bd6 <ipc_recv+0x32>
			*from_env_store = 0;
  801bd0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801bd6:	85 db                	test   %ebx,%ebx
  801bd8:	74 2c                	je     801c06 <ipc_recv+0x62>
			*perm_store = 0;
  801bda:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801be0:	eb 24                	jmp    801c06 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801be2:	85 f6                	test   %esi,%esi
  801be4:	74 0a                	je     801bf0 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801be6:	a1 08 40 80 00       	mov    0x804008,%eax
  801beb:	8b 40 74             	mov    0x74(%eax),%eax
  801bee:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801bf0:	85 db                	test   %ebx,%ebx
  801bf2:	74 0a                	je     801bfe <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801bf4:	a1 08 40 80 00       	mov    0x804008,%eax
  801bf9:	8b 40 78             	mov    0x78(%eax),%eax
  801bfc:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801bfe:	a1 08 40 80 00       	mov    0x804008,%eax
  801c03:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c06:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c09:	5b                   	pop    %ebx
  801c0a:	5e                   	pop    %esi
  801c0b:	5d                   	pop    %ebp
  801c0c:	c3                   	ret    

00801c0d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	57                   	push   %edi
  801c11:	56                   	push   %esi
  801c12:	53                   	push   %ebx
  801c13:	83 ec 0c             	sub    $0xc,%esp
  801c16:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c19:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801c1f:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801c21:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c26:	0f 44 d8             	cmove  %eax,%ebx
  801c29:	eb 1e                	jmp    801c49 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801c2b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c2e:	74 14                	je     801c44 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801c30:	83 ec 04             	sub    $0x4,%esp
  801c33:	68 68 24 80 00       	push   $0x802468
  801c38:	6a 44                	push   $0x44
  801c3a:	68 94 24 80 00       	push   $0x802494
  801c3f:	e8 1a ff ff ff       	call   801b5e <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801c44:	e8 d3 ef ff ff       	call   800c1c <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c49:	ff 75 14             	pushl  0x14(%ebp)
  801c4c:	53                   	push   %ebx
  801c4d:	56                   	push   %esi
  801c4e:	57                   	push   %edi
  801c4f:	e8 74 f1 ff ff       	call   800dc8 <sys_ipc_try_send>
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	85 c0                	test   %eax,%eax
  801c59:	78 d0                	js     801c2b <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c5e:	5b                   	pop    %ebx
  801c5f:	5e                   	pop    %esi
  801c60:	5f                   	pop    %edi
  801c61:	5d                   	pop    %ebp
  801c62:	c3                   	ret    

00801c63 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c69:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c6e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c71:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c77:	8b 52 50             	mov    0x50(%edx),%edx
  801c7a:	39 ca                	cmp    %ecx,%edx
  801c7c:	75 0d                	jne    801c8b <ipc_find_env+0x28>
			return envs[i].env_id;
  801c7e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c81:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c86:	8b 40 48             	mov    0x48(%eax),%eax
  801c89:	eb 0f                	jmp    801c9a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c8b:	83 c0 01             	add    $0x1,%eax
  801c8e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c93:	75 d9                	jne    801c6e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c95:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c9a:	5d                   	pop    %ebp
  801c9b:	c3                   	ret    

00801c9c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ca2:	89 d0                	mov    %edx,%eax
  801ca4:	c1 e8 16             	shr    $0x16,%eax
  801ca7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801cae:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cb3:	f6 c1 01             	test   $0x1,%cl
  801cb6:	74 1d                	je     801cd5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cb8:	c1 ea 0c             	shr    $0xc,%edx
  801cbb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801cc2:	f6 c2 01             	test   $0x1,%dl
  801cc5:	74 0e                	je     801cd5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cc7:	c1 ea 0c             	shr    $0xc,%edx
  801cca:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801cd1:	ef 
  801cd2:	0f b7 c0             	movzwl %ax,%eax
}
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    
  801cd7:	66 90                	xchg   %ax,%ax
  801cd9:	66 90                	xchg   %ax,%ax
  801cdb:	66 90                	xchg   %ax,%ax
  801cdd:	66 90                	xchg   %ax,%ax
  801cdf:	90                   	nop

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
