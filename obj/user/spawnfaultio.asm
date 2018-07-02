
obj/user/spawnfaultio.debug:     file format elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
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
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 08 40 80 00       	mov    0x804008,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 00 25 80 00       	push   $0x802500
  800047:	e8 68 01 00 00       	call   8001b4 <cprintf>
	if ((r = spawnl("faultio", "faultio", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 1e 25 80 00       	push   $0x80251e
  800056:	68 1e 25 80 00       	push   $0x80251e
  80005b:	e8 88 1b 00 00       	call   801be8 <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(faultio) failed: %e", r);
  800067:	50                   	push   %eax
  800068:	68 26 25 80 00       	push   $0x802526
  80006d:	6a 09                	push   $0x9
  80006f:	68 40 25 80 00       	push   $0x802540
  800074:	e8 62 00 00 00       	call   8000db <_panic>
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800086:	e8 99 0b 00 00       	call   800c24 <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800098:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009d:	85 db                	test   %ebx,%ebx
  80009f:	7e 07                	jle    8000a8 <libmain+0x2d>
		binaryname = argv[0];
  8000a1:	8b 06                	mov    (%esi),%eax
  8000a3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 0a 00 00 00       	call   8000c1 <exit>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c7:	e8 52 0f 00 00       	call   80101e <close_all>
	sys_env_destroy(0);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 0d 0b 00 00       	call   800be3 <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000e9:	e8 36 0b 00 00       	call   800c24 <sys_getenvid>
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	ff 75 0c             	pushl  0xc(%ebp)
  8000f4:	ff 75 08             	pushl  0x8(%ebp)
  8000f7:	56                   	push   %esi
  8000f8:	50                   	push   %eax
  8000f9:	68 60 25 80 00       	push   $0x802560
  8000fe:	e8 b1 00 00 00       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800103:	83 c4 18             	add    $0x18,%esp
  800106:	53                   	push   %ebx
  800107:	ff 75 10             	pushl  0x10(%ebp)
  80010a:	e8 54 00 00 00       	call   800163 <vcprintf>
	cprintf("\n");
  80010f:	c7 04 24 5e 2a 80 00 	movl   $0x802a5e,(%esp)
  800116:	e8 99 00 00 00       	call   8001b4 <cprintf>
  80011b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80011e:	cc                   	int3   
  80011f:	eb fd                	jmp    80011e <_panic+0x43>

00800121 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	53                   	push   %ebx
  800125:	83 ec 04             	sub    $0x4,%esp
  800128:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012b:	8b 13                	mov    (%ebx),%edx
  80012d:	8d 42 01             	lea    0x1(%edx),%eax
  800130:	89 03                	mov    %eax,(%ebx)
  800132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800135:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800139:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013e:	75 1a                	jne    80015a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	68 ff 00 00 00       	push   $0xff
  800148:	8d 43 08             	lea    0x8(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 55 0a 00 00       	call   800ba6 <sys_cputs>
		b->idx = 0;
  800151:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800157:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	68 21 01 80 00       	push   $0x800121
  800192:	e8 54 01 00 00       	call   8002eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800197:	83 c4 08             	add    $0x8,%esp
  80019a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 fa 09 00 00       	call   800ba6 <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bd:	50                   	push   %eax
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	e8 9d ff ff ff       	call   800163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 1c             	sub    $0x1c,%esp
  8001d1:	89 c7                	mov    %eax,%edi
  8001d3:	89 d6                	mov    %edx,%esi
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001de:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ef:	39 d3                	cmp    %edx,%ebx
  8001f1:	72 05                	jb     8001f8 <printnum+0x30>
  8001f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f6:	77 45                	ja     80023d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 18             	pushl  0x18(%ebp)
  8001fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800201:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800204:	53                   	push   %ebx
  800205:	ff 75 10             	pushl  0x10(%ebp)
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020e:	ff 75 e0             	pushl  -0x20(%ebp)
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	e8 54 20 00 00       	call   802270 <__udivdi3>
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	89 f2                	mov    %esi,%edx
  800223:	89 f8                	mov    %edi,%eax
  800225:	e8 9e ff ff ff       	call   8001c8 <printnum>
  80022a:	83 c4 20             	add    $0x20,%esp
  80022d:	eb 18                	jmp    800247 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	ff d7                	call   *%edi
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	eb 03                	jmp    800240 <printnum+0x78>
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800240:	83 eb 01             	sub    $0x1,%ebx
  800243:	85 db                	test   %ebx,%ebx
  800245:	7f e8                	jg     80022f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	83 ec 04             	sub    $0x4,%esp
  80024e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800251:	ff 75 e0             	pushl  -0x20(%ebp)
  800254:	ff 75 dc             	pushl  -0x24(%ebp)
  800257:	ff 75 d8             	pushl  -0x28(%ebp)
  80025a:	e8 41 21 00 00       	call   8023a0 <__umoddi3>
  80025f:	83 c4 14             	add    $0x14,%esp
  800262:	0f be 80 83 25 80 00 	movsbl 0x802583(%eax),%eax
  800269:	50                   	push   %eax
  80026a:	ff d7                	call   *%edi
}
  80026c:	83 c4 10             	add    $0x10,%esp
  80026f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027a:	83 fa 01             	cmp    $0x1,%edx
  80027d:	7e 0e                	jle    80028d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027f:	8b 10                	mov    (%eax),%edx
  800281:	8d 4a 08             	lea    0x8(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 02                	mov    (%edx),%eax
  800288:	8b 52 04             	mov    0x4(%edx),%edx
  80028b:	eb 22                	jmp    8002af <getuint+0x38>
	else if (lflag)
  80028d:	85 d2                	test   %edx,%edx
  80028f:	74 10                	je     8002a1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800291:	8b 10                	mov    (%eax),%edx
  800293:	8d 4a 04             	lea    0x4(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 02                	mov    (%edx),%eax
  80029a:	ba 00 00 00 00       	mov    $0x0,%edx
  80029f:	eb 0e                	jmp    8002af <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a1:	8b 10                	mov    (%eax),%edx
  8002a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a6:	89 08                	mov    %ecx,(%eax)
  8002a8:	8b 02                	mov    (%edx),%eax
  8002aa:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c0:	73 0a                	jae    8002cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	88 02                	mov    %al,(%edx)
}
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d7:	50                   	push   %eax
  8002d8:	ff 75 10             	pushl  0x10(%ebp)
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	e8 05 00 00 00       	call   8002eb <vprintfmt>
	va_end(ap);
}
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 2c             	sub    $0x2c,%esp
  8002f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fd:	eb 12                	jmp    800311 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ff:	85 c0                	test   %eax,%eax
  800301:	0f 84 38 04 00 00    	je     80073f <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	53                   	push   %ebx
  80030b:	50                   	push   %eax
  80030c:	ff d6                	call   *%esi
  80030e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800311:	83 c7 01             	add    $0x1,%edi
  800314:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800318:	83 f8 25             	cmp    $0x25,%eax
  80031b:	75 e2                	jne    8002ff <vprintfmt+0x14>
  80031d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800321:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800328:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800336:	ba 00 00 00 00       	mov    $0x0,%edx
  80033b:	eb 07                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  800340:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8d 47 01             	lea    0x1(%edi),%eax
  800347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034a:	0f b6 07             	movzbl (%edi),%eax
  80034d:	0f b6 c8             	movzbl %al,%ecx
  800350:	83 e8 23             	sub    $0x23,%eax
  800353:	3c 55                	cmp    $0x55,%al
  800355:	0f 87 c9 03 00 00    	ja     800724 <vprintfmt+0x439>
  80035b:	0f b6 c0             	movzbl %al,%eax
  80035e:	ff 24 85 c0 26 80 00 	jmp    *0x8026c0(,%eax,4)
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036c:	eb d6                	jmp    800344 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  80036e:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  800375:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  80037b:	eb 94                	jmp    800311 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  80037d:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  800384:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  80038a:	eb 85                	jmp    800311 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  80038c:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  800393:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  800399:	e9 73 ff ff ff       	jmp    800311 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  80039e:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  8003a5:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  8003ab:	e9 61 ff ff ff       	jmp    800311 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  8003b0:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  8003b7:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  8003bd:	e9 4f ff ff ff       	jmp    800311 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  8003c2:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  8003c9:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  8003cf:	e9 3d ff ff ff       	jmp    800311 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  8003d4:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  8003db:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  8003e1:	e9 2b ff ff ff       	jmp    800311 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  8003e6:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  8003ed:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8003f3:	e9 19 ff ff ff       	jmp    800311 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  8003f8:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  8003ff:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  800405:	e9 07 ff ff ff       	jmp    800311 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  80040a:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  800411:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800417:	e9 f5 fe ff ff       	jmp    800311 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041f:	b8 00 00 00 00       	mov    $0x0,%eax
  800424:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800427:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80042a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80042e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800431:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800434:	83 fa 09             	cmp    $0x9,%edx
  800437:	77 3f                	ja     800478 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800439:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80043c:	eb e9                	jmp    800427 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80043e:	8b 45 14             	mov    0x14(%ebp),%eax
  800441:	8d 48 04             	lea    0x4(%eax),%ecx
  800444:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800447:	8b 00                	mov    (%eax),%eax
  800449:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80044f:	eb 2d                	jmp    80047e <vprintfmt+0x193>
  800451:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800454:	85 c0                	test   %eax,%eax
  800456:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045b:	0f 49 c8             	cmovns %eax,%ecx
  80045e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800464:	e9 db fe ff ff       	jmp    800344 <vprintfmt+0x59>
  800469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80046c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800473:	e9 cc fe ff ff       	jmp    800344 <vprintfmt+0x59>
  800478:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80047b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80047e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800482:	0f 89 bc fe ff ff    	jns    800344 <vprintfmt+0x59>
				width = precision, precision = -1;
  800488:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80048b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800495:	e9 aa fe ff ff       	jmp    800344 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a0:	e9 9f fe ff ff       	jmp    800344 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8d 50 04             	lea    0x4(%eax),%edx
  8004ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	53                   	push   %ebx
  8004b2:	ff 30                	pushl  (%eax)
  8004b4:	ff d6                	call   *%esi
			break;
  8004b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004bc:	e9 50 fe ff ff       	jmp    800311 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8d 50 04             	lea    0x4(%eax),%edx
  8004c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ca:	8b 00                	mov    (%eax),%eax
  8004cc:	99                   	cltd   
  8004cd:	31 d0                	xor    %edx,%eax
  8004cf:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d1:	83 f8 0f             	cmp    $0xf,%eax
  8004d4:	7f 0b                	jg     8004e1 <vprintfmt+0x1f6>
  8004d6:	8b 14 85 20 28 80 00 	mov    0x802820(,%eax,4),%edx
  8004dd:	85 d2                	test   %edx,%edx
  8004df:	75 18                	jne    8004f9 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  8004e1:	50                   	push   %eax
  8004e2:	68 9b 25 80 00       	push   $0x80259b
  8004e7:	53                   	push   %ebx
  8004e8:	56                   	push   %esi
  8004e9:	e8 e0 fd ff ff       	call   8002ce <printfmt>
  8004ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f4:	e9 18 fe ff ff       	jmp    800311 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004f9:	52                   	push   %edx
  8004fa:	68 51 29 80 00       	push   $0x802951
  8004ff:	53                   	push   %ebx
  800500:	56                   	push   %esi
  800501:	e8 c8 fd ff ff       	call   8002ce <printfmt>
  800506:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800509:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050c:	e9 00 fe ff ff       	jmp    800311 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 50 04             	lea    0x4(%eax),%edx
  800517:	89 55 14             	mov    %edx,0x14(%ebp)
  80051a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80051c:	85 ff                	test   %edi,%edi
  80051e:	b8 94 25 80 00       	mov    $0x802594,%eax
  800523:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800526:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052a:	0f 8e 94 00 00 00    	jle    8005c4 <vprintfmt+0x2d9>
  800530:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800534:	0f 84 98 00 00 00    	je     8005d2 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	ff 75 d0             	pushl  -0x30(%ebp)
  800540:	57                   	push   %edi
  800541:	e8 81 02 00 00       	call   8007c7 <strnlen>
  800546:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800549:	29 c1                	sub    %eax,%ecx
  80054b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80054e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800551:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800555:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800558:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80055b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055d:	eb 0f                	jmp    80056e <vprintfmt+0x283>
					putch(padc, putdat);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	53                   	push   %ebx
  800563:	ff 75 e0             	pushl  -0x20(%ebp)
  800566:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800568:	83 ef 01             	sub    $0x1,%edi
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	85 ff                	test   %edi,%edi
  800570:	7f ed                	jg     80055f <vprintfmt+0x274>
  800572:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800575:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800578:	85 c9                	test   %ecx,%ecx
  80057a:	b8 00 00 00 00       	mov    $0x0,%eax
  80057f:	0f 49 c1             	cmovns %ecx,%eax
  800582:	29 c1                	sub    %eax,%ecx
  800584:	89 75 08             	mov    %esi,0x8(%ebp)
  800587:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058d:	89 cb                	mov    %ecx,%ebx
  80058f:	eb 4d                	jmp    8005de <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800591:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800595:	74 1b                	je     8005b2 <vprintfmt+0x2c7>
  800597:	0f be c0             	movsbl %al,%eax
  80059a:	83 e8 20             	sub    $0x20,%eax
  80059d:	83 f8 5e             	cmp    $0x5e,%eax
  8005a0:	76 10                	jbe    8005b2 <vprintfmt+0x2c7>
					putch('?', putdat);
  8005a2:	83 ec 08             	sub    $0x8,%esp
  8005a5:	ff 75 0c             	pushl  0xc(%ebp)
  8005a8:	6a 3f                	push   $0x3f
  8005aa:	ff 55 08             	call   *0x8(%ebp)
  8005ad:	83 c4 10             	add    $0x10,%esp
  8005b0:	eb 0d                	jmp    8005bf <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	ff 75 0c             	pushl  0xc(%ebp)
  8005b8:	52                   	push   %edx
  8005b9:	ff 55 08             	call   *0x8(%ebp)
  8005bc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005bf:	83 eb 01             	sub    $0x1,%ebx
  8005c2:	eb 1a                	jmp    8005de <vprintfmt+0x2f3>
  8005c4:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005cd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d0:	eb 0c                	jmp    8005de <vprintfmt+0x2f3>
  8005d2:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005db:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005de:	83 c7 01             	add    $0x1,%edi
  8005e1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005e5:	0f be d0             	movsbl %al,%edx
  8005e8:	85 d2                	test   %edx,%edx
  8005ea:	74 23                	je     80060f <vprintfmt+0x324>
  8005ec:	85 f6                	test   %esi,%esi
  8005ee:	78 a1                	js     800591 <vprintfmt+0x2a6>
  8005f0:	83 ee 01             	sub    $0x1,%esi
  8005f3:	79 9c                	jns    800591 <vprintfmt+0x2a6>
  8005f5:	89 df                	mov    %ebx,%edi
  8005f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8005fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005fd:	eb 18                	jmp    800617 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	53                   	push   %ebx
  800603:	6a 20                	push   $0x20
  800605:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800607:	83 ef 01             	sub    $0x1,%edi
  80060a:	83 c4 10             	add    $0x10,%esp
  80060d:	eb 08                	jmp    800617 <vprintfmt+0x32c>
  80060f:	89 df                	mov    %ebx,%edi
  800611:	8b 75 08             	mov    0x8(%ebp),%esi
  800614:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800617:	85 ff                	test   %edi,%edi
  800619:	7f e4                	jg     8005ff <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061e:	e9 ee fc ff ff       	jmp    800311 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800623:	83 fa 01             	cmp    $0x1,%edx
  800626:	7e 16                	jle    80063e <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 08             	lea    0x8(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	8b 50 04             	mov    0x4(%eax),%edx
  800634:	8b 00                	mov    (%eax),%eax
  800636:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800639:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80063c:	eb 32                	jmp    800670 <vprintfmt+0x385>
	else if (lflag)
  80063e:	85 d2                	test   %edx,%edx
  800640:	74 18                	je     80065a <vprintfmt+0x36f>
		return va_arg(*ap, long);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 50 04             	lea    0x4(%eax),%edx
  800648:	89 55 14             	mov    %edx,0x14(%ebp)
  80064b:	8b 00                	mov    (%eax),%eax
  80064d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800650:	89 c1                	mov    %eax,%ecx
  800652:	c1 f9 1f             	sar    $0x1f,%ecx
  800655:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800658:	eb 16                	jmp    800670 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8d 50 04             	lea    0x4(%eax),%edx
  800660:	89 55 14             	mov    %edx,0x14(%ebp)
  800663:	8b 00                	mov    (%eax),%eax
  800665:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800668:	89 c1                	mov    %eax,%ecx
  80066a:	c1 f9 1f             	sar    $0x1f,%ecx
  80066d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800670:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800673:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800676:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80067b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80067f:	79 6f                	jns    8006f0 <vprintfmt+0x405>
				putch('-', putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	53                   	push   %ebx
  800685:	6a 2d                	push   $0x2d
  800687:	ff d6                	call   *%esi
				num = -(long long) num;
  800689:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80068c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80068f:	f7 d8                	neg    %eax
  800691:	83 d2 00             	adc    $0x0,%edx
  800694:	f7 da                	neg    %edx
  800696:	83 c4 10             	add    $0x10,%esp
  800699:	eb 55                	jmp    8006f0 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
  80069e:	e8 d4 fb ff ff       	call   800277 <getuint>
			base = 10;
  8006a3:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8006a8:	eb 46                	jmp    8006f0 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ad:	e8 c5 fb ff ff       	call   800277 <getuint>
			base = 8;
  8006b2:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8006b7:	eb 37                	jmp    8006f0 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	6a 30                	push   $0x30
  8006bf:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c1:	83 c4 08             	add    $0x8,%esp
  8006c4:	53                   	push   %ebx
  8006c5:	6a 78                	push   $0x78
  8006c7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8d 50 04             	lea    0x4(%eax),%edx
  8006cf:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d2:	8b 00                	mov    (%eax),%eax
  8006d4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006d9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006dc:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8006e1:	eb 0d                	jmp    8006f0 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e6:	e8 8c fb ff ff       	call   800277 <getuint>
			base = 16;
  8006eb:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f0:	83 ec 0c             	sub    $0xc,%esp
  8006f3:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8006f7:	51                   	push   %ecx
  8006f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fb:	57                   	push   %edi
  8006fc:	52                   	push   %edx
  8006fd:	50                   	push   %eax
  8006fe:	89 da                	mov    %ebx,%edx
  800700:	89 f0                	mov    %esi,%eax
  800702:	e8 c1 fa ff ff       	call   8001c8 <printnum>
			break;
  800707:	83 c4 20             	add    $0x20,%esp
  80070a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80070d:	e9 ff fb ff ff       	jmp    800311 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	53                   	push   %ebx
  800716:	51                   	push   %ecx
  800717:	ff d6                	call   *%esi
			break;
  800719:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80071f:	e9 ed fb ff ff       	jmp    800311 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	53                   	push   %ebx
  800728:	6a 25                	push   $0x25
  80072a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	eb 03                	jmp    800734 <vprintfmt+0x449>
  800731:	83 ef 01             	sub    $0x1,%edi
  800734:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800738:	75 f7                	jne    800731 <vprintfmt+0x446>
  80073a:	e9 d2 fb ff ff       	jmp    800311 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80073f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800742:	5b                   	pop    %ebx
  800743:	5e                   	pop    %esi
  800744:	5f                   	pop    %edi
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	83 ec 18             	sub    $0x18,%esp
  80074d:	8b 45 08             	mov    0x8(%ebp),%eax
  800750:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800753:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800756:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800764:	85 c0                	test   %eax,%eax
  800766:	74 26                	je     80078e <vsnprintf+0x47>
  800768:	85 d2                	test   %edx,%edx
  80076a:	7e 22                	jle    80078e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076c:	ff 75 14             	pushl  0x14(%ebp)
  80076f:	ff 75 10             	pushl  0x10(%ebp)
  800772:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800775:	50                   	push   %eax
  800776:	68 b1 02 80 00       	push   $0x8002b1
  80077b:	e8 6b fb ff ff       	call   8002eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800780:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800783:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800786:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800789:	83 c4 10             	add    $0x10,%esp
  80078c:	eb 05                	jmp    800793 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80078e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800793:	c9                   	leave  
  800794:	c3                   	ret    

00800795 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079e:	50                   	push   %eax
  80079f:	ff 75 10             	pushl  0x10(%ebp)
  8007a2:	ff 75 0c             	pushl  0xc(%ebp)
  8007a5:	ff 75 08             	pushl  0x8(%ebp)
  8007a8:	e8 9a ff ff ff       	call   800747 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    

008007af <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ba:	eb 03                	jmp    8007bf <strlen+0x10>
		n++;
  8007bc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c3:	75 f7                	jne    8007bc <strlen+0xd>
		n++;
	return n;
}
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d5:	eb 03                	jmp    8007da <strnlen+0x13>
		n++;
  8007d7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007da:	39 c2                	cmp    %eax,%edx
  8007dc:	74 08                	je     8007e6 <strnlen+0x1f>
  8007de:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007e2:	75 f3                	jne    8007d7 <strnlen+0x10>
  8007e4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	53                   	push   %ebx
  8007ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f2:	89 c2                	mov    %eax,%edx
  8007f4:	83 c2 01             	add    $0x1,%edx
  8007f7:	83 c1 01             	add    $0x1,%ecx
  8007fa:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007fe:	88 5a ff             	mov    %bl,-0x1(%edx)
  800801:	84 db                	test   %bl,%bl
  800803:	75 ef                	jne    8007f4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800805:	5b                   	pop    %ebx
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	53                   	push   %ebx
  80080c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80080f:	53                   	push   %ebx
  800810:	e8 9a ff ff ff       	call   8007af <strlen>
  800815:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800818:	ff 75 0c             	pushl  0xc(%ebp)
  80081b:	01 d8                	add    %ebx,%eax
  80081d:	50                   	push   %eax
  80081e:	e8 c5 ff ff ff       	call   8007e8 <strcpy>
	return dst;
}
  800823:	89 d8                	mov    %ebx,%eax
  800825:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800828:	c9                   	leave  
  800829:	c3                   	ret    

0080082a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	56                   	push   %esi
  80082e:	53                   	push   %ebx
  80082f:	8b 75 08             	mov    0x8(%ebp),%esi
  800832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800835:	89 f3                	mov    %esi,%ebx
  800837:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083a:	89 f2                	mov    %esi,%edx
  80083c:	eb 0f                	jmp    80084d <strncpy+0x23>
		*dst++ = *src;
  80083e:	83 c2 01             	add    $0x1,%edx
  800841:	0f b6 01             	movzbl (%ecx),%eax
  800844:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800847:	80 39 01             	cmpb   $0x1,(%ecx)
  80084a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084d:	39 da                	cmp    %ebx,%edx
  80084f:	75 ed                	jne    80083e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800851:	89 f0                	mov    %esi,%eax
  800853:	5b                   	pop    %ebx
  800854:	5e                   	pop    %esi
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	8b 75 08             	mov    0x8(%ebp),%esi
  80085f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800862:	8b 55 10             	mov    0x10(%ebp),%edx
  800865:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800867:	85 d2                	test   %edx,%edx
  800869:	74 21                	je     80088c <strlcpy+0x35>
  80086b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80086f:	89 f2                	mov    %esi,%edx
  800871:	eb 09                	jmp    80087c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800873:	83 c2 01             	add    $0x1,%edx
  800876:	83 c1 01             	add    $0x1,%ecx
  800879:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80087c:	39 c2                	cmp    %eax,%edx
  80087e:	74 09                	je     800889 <strlcpy+0x32>
  800880:	0f b6 19             	movzbl (%ecx),%ebx
  800883:	84 db                	test   %bl,%bl
  800885:	75 ec                	jne    800873 <strlcpy+0x1c>
  800887:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800889:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80088c:	29 f0                	sub    %esi,%eax
}
  80088e:	5b                   	pop    %ebx
  80088f:	5e                   	pop    %esi
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800898:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089b:	eb 06                	jmp    8008a3 <strcmp+0x11>
		p++, q++;
  80089d:	83 c1 01             	add    $0x1,%ecx
  8008a0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a3:	0f b6 01             	movzbl (%ecx),%eax
  8008a6:	84 c0                	test   %al,%al
  8008a8:	74 04                	je     8008ae <strcmp+0x1c>
  8008aa:	3a 02                	cmp    (%edx),%al
  8008ac:	74 ef                	je     80089d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ae:	0f b6 c0             	movzbl %al,%eax
  8008b1:	0f b6 12             	movzbl (%edx),%edx
  8008b4:	29 d0                	sub    %edx,%eax
}
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	53                   	push   %ebx
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c2:	89 c3                	mov    %eax,%ebx
  8008c4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c7:	eb 06                	jmp    8008cf <strncmp+0x17>
		n--, p++, q++;
  8008c9:	83 c0 01             	add    $0x1,%eax
  8008cc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008cf:	39 d8                	cmp    %ebx,%eax
  8008d1:	74 15                	je     8008e8 <strncmp+0x30>
  8008d3:	0f b6 08             	movzbl (%eax),%ecx
  8008d6:	84 c9                	test   %cl,%cl
  8008d8:	74 04                	je     8008de <strncmp+0x26>
  8008da:	3a 0a                	cmp    (%edx),%cl
  8008dc:	74 eb                	je     8008c9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008de:	0f b6 00             	movzbl (%eax),%eax
  8008e1:	0f b6 12             	movzbl (%edx),%edx
  8008e4:	29 d0                	sub    %edx,%eax
  8008e6:	eb 05                	jmp    8008ed <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ed:	5b                   	pop    %ebx
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fa:	eb 07                	jmp    800903 <strchr+0x13>
		if (*s == c)
  8008fc:	38 ca                	cmp    %cl,%dl
  8008fe:	74 0f                	je     80090f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800900:	83 c0 01             	add    $0x1,%eax
  800903:	0f b6 10             	movzbl (%eax),%edx
  800906:	84 d2                	test   %dl,%dl
  800908:	75 f2                	jne    8008fc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80090a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091b:	eb 03                	jmp    800920 <strfind+0xf>
  80091d:	83 c0 01             	add    $0x1,%eax
  800920:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800923:	38 ca                	cmp    %cl,%dl
  800925:	74 04                	je     80092b <strfind+0x1a>
  800927:	84 d2                	test   %dl,%dl
  800929:	75 f2                	jne    80091d <strfind+0xc>
			break;
	return (char *) s;
}
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	57                   	push   %edi
  800931:	56                   	push   %esi
  800932:	53                   	push   %ebx
  800933:	8b 7d 08             	mov    0x8(%ebp),%edi
  800936:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800939:	85 c9                	test   %ecx,%ecx
  80093b:	74 36                	je     800973 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800943:	75 28                	jne    80096d <memset+0x40>
  800945:	f6 c1 03             	test   $0x3,%cl
  800948:	75 23                	jne    80096d <memset+0x40>
		c &= 0xFF;
  80094a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094e:	89 d3                	mov    %edx,%ebx
  800950:	c1 e3 08             	shl    $0x8,%ebx
  800953:	89 d6                	mov    %edx,%esi
  800955:	c1 e6 18             	shl    $0x18,%esi
  800958:	89 d0                	mov    %edx,%eax
  80095a:	c1 e0 10             	shl    $0x10,%eax
  80095d:	09 f0                	or     %esi,%eax
  80095f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800961:	89 d8                	mov    %ebx,%eax
  800963:	09 d0                	or     %edx,%eax
  800965:	c1 e9 02             	shr    $0x2,%ecx
  800968:	fc                   	cld    
  800969:	f3 ab                	rep stos %eax,%es:(%edi)
  80096b:	eb 06                	jmp    800973 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800970:	fc                   	cld    
  800971:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800973:	89 f8                	mov    %edi,%eax
  800975:	5b                   	pop    %ebx
  800976:	5e                   	pop    %esi
  800977:	5f                   	pop    %edi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	57                   	push   %edi
  80097e:	56                   	push   %esi
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 75 0c             	mov    0xc(%ebp),%esi
  800985:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800988:	39 c6                	cmp    %eax,%esi
  80098a:	73 35                	jae    8009c1 <memmove+0x47>
  80098c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098f:	39 d0                	cmp    %edx,%eax
  800991:	73 2e                	jae    8009c1 <memmove+0x47>
		s += n;
		d += n;
  800993:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800996:	89 d6                	mov    %edx,%esi
  800998:	09 fe                	or     %edi,%esi
  80099a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a0:	75 13                	jne    8009b5 <memmove+0x3b>
  8009a2:	f6 c1 03             	test   $0x3,%cl
  8009a5:	75 0e                	jne    8009b5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009a7:	83 ef 04             	sub    $0x4,%edi
  8009aa:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ad:	c1 e9 02             	shr    $0x2,%ecx
  8009b0:	fd                   	std    
  8009b1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b3:	eb 09                	jmp    8009be <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b5:	83 ef 01             	sub    $0x1,%edi
  8009b8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009bb:	fd                   	std    
  8009bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009be:	fc                   	cld    
  8009bf:	eb 1d                	jmp    8009de <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c1:	89 f2                	mov    %esi,%edx
  8009c3:	09 c2                	or     %eax,%edx
  8009c5:	f6 c2 03             	test   $0x3,%dl
  8009c8:	75 0f                	jne    8009d9 <memmove+0x5f>
  8009ca:	f6 c1 03             	test   $0x3,%cl
  8009cd:	75 0a                	jne    8009d9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009cf:	c1 e9 02             	shr    $0x2,%ecx
  8009d2:	89 c7                	mov    %eax,%edi
  8009d4:	fc                   	cld    
  8009d5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d7:	eb 05                	jmp    8009de <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d9:	89 c7                	mov    %eax,%edi
  8009db:	fc                   	cld    
  8009dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009de:	5e                   	pop    %esi
  8009df:	5f                   	pop    %edi
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e5:	ff 75 10             	pushl  0x10(%ebp)
  8009e8:	ff 75 0c             	pushl  0xc(%ebp)
  8009eb:	ff 75 08             	pushl  0x8(%ebp)
  8009ee:	e8 87 ff ff ff       	call   80097a <memmove>
}
  8009f3:	c9                   	leave  
  8009f4:	c3                   	ret    

008009f5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	56                   	push   %esi
  8009f9:	53                   	push   %ebx
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a00:	89 c6                	mov    %eax,%esi
  800a02:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a05:	eb 1a                	jmp    800a21 <memcmp+0x2c>
		if (*s1 != *s2)
  800a07:	0f b6 08             	movzbl (%eax),%ecx
  800a0a:	0f b6 1a             	movzbl (%edx),%ebx
  800a0d:	38 d9                	cmp    %bl,%cl
  800a0f:	74 0a                	je     800a1b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a11:	0f b6 c1             	movzbl %cl,%eax
  800a14:	0f b6 db             	movzbl %bl,%ebx
  800a17:	29 d8                	sub    %ebx,%eax
  800a19:	eb 0f                	jmp    800a2a <memcmp+0x35>
		s1++, s2++;
  800a1b:	83 c0 01             	add    $0x1,%eax
  800a1e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a21:	39 f0                	cmp    %esi,%eax
  800a23:	75 e2                	jne    800a07 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2a:	5b                   	pop    %ebx
  800a2b:	5e                   	pop    %esi
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	53                   	push   %ebx
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a35:	89 c1                	mov    %eax,%ecx
  800a37:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3e:	eb 0a                	jmp    800a4a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a40:	0f b6 10             	movzbl (%eax),%edx
  800a43:	39 da                	cmp    %ebx,%edx
  800a45:	74 07                	je     800a4e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a47:	83 c0 01             	add    $0x1,%eax
  800a4a:	39 c8                	cmp    %ecx,%eax
  800a4c:	72 f2                	jb     800a40 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a4e:	5b                   	pop    %ebx
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	57                   	push   %edi
  800a55:	56                   	push   %esi
  800a56:	53                   	push   %ebx
  800a57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5d:	eb 03                	jmp    800a62 <strtol+0x11>
		s++;
  800a5f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a62:	0f b6 01             	movzbl (%ecx),%eax
  800a65:	3c 20                	cmp    $0x20,%al
  800a67:	74 f6                	je     800a5f <strtol+0xe>
  800a69:	3c 09                	cmp    $0x9,%al
  800a6b:	74 f2                	je     800a5f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6d:	3c 2b                	cmp    $0x2b,%al
  800a6f:	75 0a                	jne    800a7b <strtol+0x2a>
		s++;
  800a71:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a74:	bf 00 00 00 00       	mov    $0x0,%edi
  800a79:	eb 11                	jmp    800a8c <strtol+0x3b>
  800a7b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a80:	3c 2d                	cmp    $0x2d,%al
  800a82:	75 08                	jne    800a8c <strtol+0x3b>
		s++, neg = 1;
  800a84:	83 c1 01             	add    $0x1,%ecx
  800a87:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a92:	75 15                	jne    800aa9 <strtol+0x58>
  800a94:	80 39 30             	cmpb   $0x30,(%ecx)
  800a97:	75 10                	jne    800aa9 <strtol+0x58>
  800a99:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a9d:	75 7c                	jne    800b1b <strtol+0xca>
		s += 2, base = 16;
  800a9f:	83 c1 02             	add    $0x2,%ecx
  800aa2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa7:	eb 16                	jmp    800abf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aa9:	85 db                	test   %ebx,%ebx
  800aab:	75 12                	jne    800abf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aad:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab5:	75 08                	jne    800abf <strtol+0x6e>
		s++, base = 8;
  800ab7:	83 c1 01             	add    $0x1,%ecx
  800aba:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800abf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac7:	0f b6 11             	movzbl (%ecx),%edx
  800aca:	8d 72 d0             	lea    -0x30(%edx),%esi
  800acd:	89 f3                	mov    %esi,%ebx
  800acf:	80 fb 09             	cmp    $0x9,%bl
  800ad2:	77 08                	ja     800adc <strtol+0x8b>
			dig = *s - '0';
  800ad4:	0f be d2             	movsbl %dl,%edx
  800ad7:	83 ea 30             	sub    $0x30,%edx
  800ada:	eb 22                	jmp    800afe <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800adc:	8d 72 9f             	lea    -0x61(%edx),%esi
  800adf:	89 f3                	mov    %esi,%ebx
  800ae1:	80 fb 19             	cmp    $0x19,%bl
  800ae4:	77 08                	ja     800aee <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ae6:	0f be d2             	movsbl %dl,%edx
  800ae9:	83 ea 57             	sub    $0x57,%edx
  800aec:	eb 10                	jmp    800afe <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aee:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af1:	89 f3                	mov    %esi,%ebx
  800af3:	80 fb 19             	cmp    $0x19,%bl
  800af6:	77 16                	ja     800b0e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800af8:	0f be d2             	movsbl %dl,%edx
  800afb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800afe:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b01:	7d 0b                	jge    800b0e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b03:	83 c1 01             	add    $0x1,%ecx
  800b06:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b0a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b0c:	eb b9                	jmp    800ac7 <strtol+0x76>

	if (endptr)
  800b0e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b12:	74 0d                	je     800b21 <strtol+0xd0>
		*endptr = (char *) s;
  800b14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b17:	89 0e                	mov    %ecx,(%esi)
  800b19:	eb 06                	jmp    800b21 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b1b:	85 db                	test   %ebx,%ebx
  800b1d:	74 98                	je     800ab7 <strtol+0x66>
  800b1f:	eb 9e                	jmp    800abf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b21:	89 c2                	mov    %eax,%edx
  800b23:	f7 da                	neg    %edx
  800b25:	85 ff                	test   %edi,%edi
  800b27:	0f 45 c2             	cmovne %edx,%eax
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 04             	sub    $0x4,%esp
  800b38:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800b3b:	57                   	push   %edi
  800b3c:	e8 6e fc ff ff       	call   8007af <strlen>
  800b41:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b44:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800b47:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800b4c:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b51:	eb 46                	jmp    800b99 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800b53:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800b57:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b5a:	80 f9 09             	cmp    $0x9,%cl
  800b5d:	77 08                	ja     800b67 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800b5f:	0f be d2             	movsbl %dl,%edx
  800b62:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b65:	eb 27                	jmp    800b8e <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800b67:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800b6a:	80 f9 05             	cmp    $0x5,%cl
  800b6d:	77 08                	ja     800b77 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800b6f:	0f be d2             	movsbl %dl,%edx
  800b72:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800b75:	eb 17                	jmp    800b8e <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800b77:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800b7a:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800b7d:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800b82:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800b86:	77 06                	ja     800b8e <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800b88:	0f be d2             	movsbl %dl,%edx
  800b8b:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800b8e:	0f af ce             	imul   %esi,%ecx
  800b91:	01 c8                	add    %ecx,%eax
		base *= 16;
  800b93:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b96:	83 eb 01             	sub    $0x1,%ebx
  800b99:	83 fb 01             	cmp    $0x1,%ebx
  800b9c:	7f b5                	jg     800b53 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800b9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bac:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	89 c3                	mov    %eax,%ebx
  800bb9:	89 c7                	mov    %eax,%edi
  800bbb:	89 c6                	mov    %eax,%esi
  800bbd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcf:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd4:	89 d1                	mov    %edx,%ecx
  800bd6:	89 d3                	mov    %edx,%ebx
  800bd8:	89 d7                	mov    %edx,%edi
  800bda:	89 d6                	mov    %edx,%esi
  800bdc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf9:	89 cb                	mov    %ecx,%ebx
  800bfb:	89 cf                	mov    %ecx,%edi
  800bfd:	89 ce                	mov    %ecx,%esi
  800bff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7e 17                	jle    800c1c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c05:	83 ec 0c             	sub    $0xc,%esp
  800c08:	50                   	push   %eax
  800c09:	6a 03                	push   $0x3
  800c0b:	68 7f 28 80 00       	push   $0x80287f
  800c10:	6a 23                	push   $0x23
  800c12:	68 9c 28 80 00       	push   $0x80289c
  800c17:	e8 bf f4 ff ff       	call   8000db <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2f:	b8 02 00 00 00       	mov    $0x2,%eax
  800c34:	89 d1                	mov    %edx,%ecx
  800c36:	89 d3                	mov    %edx,%ebx
  800c38:	89 d7                	mov    %edx,%edi
  800c3a:	89 d6                	mov    %edx,%esi
  800c3c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_yield>:

void
sys_yield(void)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c53:	89 d1                	mov    %edx,%ecx
  800c55:	89 d3                	mov    %edx,%ebx
  800c57:	89 d7                	mov    %edx,%edi
  800c59:	89 d6                	mov    %edx,%esi
  800c5b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
  800c68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6b:	be 00 00 00 00       	mov    $0x0,%esi
  800c70:	b8 04 00 00 00       	mov    $0x4,%eax
  800c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c78:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7e:	89 f7                	mov    %esi,%edi
  800c80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c82:	85 c0                	test   %eax,%eax
  800c84:	7e 17                	jle    800c9d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	50                   	push   %eax
  800c8a:	6a 04                	push   $0x4
  800c8c:	68 7f 28 80 00       	push   $0x80287f
  800c91:	6a 23                	push   $0x23
  800c93:	68 9c 28 80 00       	push   $0x80289c
  800c98:	e8 3e f4 ff ff       	call   8000db <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbf:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	7e 17                	jle    800cdf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc8:	83 ec 0c             	sub    $0xc,%esp
  800ccb:	50                   	push   %eax
  800ccc:	6a 05                	push   $0x5
  800cce:	68 7f 28 80 00       	push   $0x80287f
  800cd3:	6a 23                	push   $0x23
  800cd5:	68 9c 28 80 00       	push   $0x80289c
  800cda:	e8 fc f3 ff ff       	call   8000db <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf5:	b8 06 00 00 00       	mov    $0x6,%eax
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800d00:	89 df                	mov    %ebx,%edi
  800d02:	89 de                	mov    %ebx,%esi
  800d04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 17                	jle    800d21 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	83 ec 0c             	sub    $0xc,%esp
  800d0d:	50                   	push   %eax
  800d0e:	6a 06                	push   $0x6
  800d10:	68 7f 28 80 00       	push   $0x80287f
  800d15:	6a 23                	push   $0x23
  800d17:	68 9c 28 80 00       	push   $0x80289c
  800d1c:	e8 ba f3 ff ff       	call   8000db <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d37:	b8 08 00 00 00       	mov    $0x8,%eax
  800d3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d42:	89 df                	mov    %ebx,%edi
  800d44:	89 de                	mov    %ebx,%esi
  800d46:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	7e 17                	jle    800d63 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4c:	83 ec 0c             	sub    $0xc,%esp
  800d4f:	50                   	push   %eax
  800d50:	6a 08                	push   $0x8
  800d52:	68 7f 28 80 00       	push   $0x80287f
  800d57:	6a 23                	push   $0x23
  800d59:	68 9c 28 80 00       	push   $0x80289c
  800d5e:	e8 78 f3 ff ff       	call   8000db <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d79:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	89 df                	mov    %ebx,%edi
  800d86:	89 de                	mov    %ebx,%esi
  800d88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	7e 17                	jle    800da5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8e:	83 ec 0c             	sub    $0xc,%esp
  800d91:	50                   	push   %eax
  800d92:	6a 0a                	push   $0xa
  800d94:	68 7f 28 80 00       	push   $0x80287f
  800d99:	6a 23                	push   $0x23
  800d9b:	68 9c 28 80 00       	push   $0x80289c
  800da0:	e8 36 f3 ff ff       	call   8000db <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800da5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbb:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	89 df                	mov    %ebx,%edi
  800dc8:	89 de                	mov    %ebx,%esi
  800dca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	7e 17                	jle    800de7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd0:	83 ec 0c             	sub    $0xc,%esp
  800dd3:	50                   	push   %eax
  800dd4:	6a 09                	push   $0x9
  800dd6:	68 7f 28 80 00       	push   $0x80287f
  800ddb:	6a 23                	push   $0x23
  800ddd:	68 9c 28 80 00       	push   $0x80289c
  800de2:	e8 f4 f2 ff ff       	call   8000db <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	57                   	push   %edi
  800df3:	56                   	push   %esi
  800df4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df5:	be 00 00 00 00       	mov    $0x0,%esi
  800dfa:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e02:	8b 55 08             	mov    0x8(%ebp),%edx
  800e05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e20:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e25:	8b 55 08             	mov    0x8(%ebp),%edx
  800e28:	89 cb                	mov    %ecx,%ebx
  800e2a:	89 cf                	mov    %ecx,%edi
  800e2c:	89 ce                	mov    %ecx,%esi
  800e2e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e30:	85 c0                	test   %eax,%eax
  800e32:	7e 17                	jle    800e4b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e34:	83 ec 0c             	sub    $0xc,%esp
  800e37:	50                   	push   %eax
  800e38:	6a 0d                	push   $0xd
  800e3a:	68 7f 28 80 00       	push   $0x80287f
  800e3f:	6a 23                	push   $0x23
  800e41:	68 9c 28 80 00       	push   $0x80289c
  800e46:	e8 90 f2 ff ff       	call   8000db <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e56:	8b 45 08             	mov    0x8(%ebp),%eax
  800e59:	05 00 00 00 30       	add    $0x30000000,%eax
  800e5e:	c1 e8 0c             	shr    $0xc,%eax
}
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e66:	8b 45 08             	mov    0x8(%ebp),%eax
  800e69:	05 00 00 00 30       	add    $0x30000000,%eax
  800e6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e73:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e80:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e85:	89 c2                	mov    %eax,%edx
  800e87:	c1 ea 16             	shr    $0x16,%edx
  800e8a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e91:	f6 c2 01             	test   $0x1,%dl
  800e94:	74 11                	je     800ea7 <fd_alloc+0x2d>
  800e96:	89 c2                	mov    %eax,%edx
  800e98:	c1 ea 0c             	shr    $0xc,%edx
  800e9b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea2:	f6 c2 01             	test   $0x1,%dl
  800ea5:	75 09                	jne    800eb0 <fd_alloc+0x36>
			*fd_store = fd;
  800ea7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ea9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eae:	eb 17                	jmp    800ec7 <fd_alloc+0x4d>
  800eb0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eb5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eba:	75 c9                	jne    800e85 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ebc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ec2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    

00800ec9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ecf:	83 f8 1f             	cmp    $0x1f,%eax
  800ed2:	77 36                	ja     800f0a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ed4:	c1 e0 0c             	shl    $0xc,%eax
  800ed7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800edc:	89 c2                	mov    %eax,%edx
  800ede:	c1 ea 16             	shr    $0x16,%edx
  800ee1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee8:	f6 c2 01             	test   $0x1,%dl
  800eeb:	74 24                	je     800f11 <fd_lookup+0x48>
  800eed:	89 c2                	mov    %eax,%edx
  800eef:	c1 ea 0c             	shr    $0xc,%edx
  800ef2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef9:	f6 c2 01             	test   $0x1,%dl
  800efc:	74 1a                	je     800f18 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800efe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f01:	89 02                	mov    %eax,(%edx)
	return 0;
  800f03:	b8 00 00 00 00       	mov    $0x0,%eax
  800f08:	eb 13                	jmp    800f1d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f0f:	eb 0c                	jmp    800f1d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f16:	eb 05                	jmp    800f1d <fd_lookup+0x54>
  800f18:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f1d:	5d                   	pop    %ebp
  800f1e:	c3                   	ret    

00800f1f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	83 ec 08             	sub    $0x8,%esp
  800f25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f28:	ba 28 29 80 00       	mov    $0x802928,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f2d:	eb 13                	jmp    800f42 <dev_lookup+0x23>
  800f2f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f32:	39 08                	cmp    %ecx,(%eax)
  800f34:	75 0c                	jne    800f42 <dev_lookup+0x23>
			*dev = devtab[i];
  800f36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f39:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f40:	eb 2e                	jmp    800f70 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f42:	8b 02                	mov    (%edx),%eax
  800f44:	85 c0                	test   %eax,%eax
  800f46:	75 e7                	jne    800f2f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f48:	a1 08 40 80 00       	mov    0x804008,%eax
  800f4d:	8b 40 48             	mov    0x48(%eax),%eax
  800f50:	83 ec 04             	sub    $0x4,%esp
  800f53:	51                   	push   %ecx
  800f54:	50                   	push   %eax
  800f55:	68 ac 28 80 00       	push   $0x8028ac
  800f5a:	e8 55 f2 ff ff       	call   8001b4 <cprintf>
	*dev = 0;
  800f5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f62:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f68:	83 c4 10             	add    $0x10,%esp
  800f6b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    

00800f72 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	83 ec 10             	sub    $0x10,%esp
  800f7a:	8b 75 08             	mov    0x8(%ebp),%esi
  800f7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f83:	50                   	push   %eax
  800f84:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f8a:	c1 e8 0c             	shr    $0xc,%eax
  800f8d:	50                   	push   %eax
  800f8e:	e8 36 ff ff ff       	call   800ec9 <fd_lookup>
  800f93:	83 c4 08             	add    $0x8,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	78 05                	js     800f9f <fd_close+0x2d>
	    || fd != fd2) 
  800f9a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f9d:	74 0c                	je     800fab <fd_close+0x39>
		return (must_exist ? r : 0); 
  800f9f:	84 db                	test   %bl,%bl
  800fa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa6:	0f 44 c2             	cmove  %edx,%eax
  800fa9:	eb 41                	jmp    800fec <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fab:	83 ec 08             	sub    $0x8,%esp
  800fae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fb1:	50                   	push   %eax
  800fb2:	ff 36                	pushl  (%esi)
  800fb4:	e8 66 ff ff ff       	call   800f1f <dev_lookup>
  800fb9:	89 c3                	mov    %eax,%ebx
  800fbb:	83 c4 10             	add    $0x10,%esp
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	78 1a                	js     800fdc <fd_close+0x6a>
		if (dev->dev_close) 
  800fc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fc5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  800fc8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	74 0b                	je     800fdc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fd1:	83 ec 0c             	sub    $0xc,%esp
  800fd4:	56                   	push   %esi
  800fd5:	ff d0                	call   *%eax
  800fd7:	89 c3                	mov    %eax,%ebx
  800fd9:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fdc:	83 ec 08             	sub    $0x8,%esp
  800fdf:	56                   	push   %esi
  800fe0:	6a 00                	push   $0x0
  800fe2:	e8 00 fd ff ff       	call   800ce7 <sys_page_unmap>
	return r;
  800fe7:	83 c4 10             	add    $0x10,%esp
  800fea:	89 d8                	mov    %ebx,%eax
}
  800fec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fef:	5b                   	pop    %ebx
  800ff0:	5e                   	pop    %esi
  800ff1:	5d                   	pop    %ebp
  800ff2:	c3                   	ret    

00800ff3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffc:	50                   	push   %eax
  800ffd:	ff 75 08             	pushl  0x8(%ebp)
  801000:	e8 c4 fe ff ff       	call   800ec9 <fd_lookup>
  801005:	83 c4 08             	add    $0x8,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	78 10                	js     80101c <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  80100c:	83 ec 08             	sub    $0x8,%esp
  80100f:	6a 01                	push   $0x1
  801011:	ff 75 f4             	pushl  -0xc(%ebp)
  801014:	e8 59 ff ff ff       	call   800f72 <fd_close>
  801019:	83 c4 10             	add    $0x10,%esp
}
  80101c:	c9                   	leave  
  80101d:	c3                   	ret    

0080101e <close_all>:

void
close_all(void)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	53                   	push   %ebx
  801022:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801025:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80102a:	83 ec 0c             	sub    $0xc,%esp
  80102d:	53                   	push   %ebx
  80102e:	e8 c0 ff ff ff       	call   800ff3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801033:	83 c3 01             	add    $0x1,%ebx
  801036:	83 c4 10             	add    $0x10,%esp
  801039:	83 fb 20             	cmp    $0x20,%ebx
  80103c:	75 ec                	jne    80102a <close_all+0xc>
		close(i);
}
  80103e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801041:	c9                   	leave  
  801042:	c3                   	ret    

00801043 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	57                   	push   %edi
  801047:	56                   	push   %esi
  801048:	53                   	push   %ebx
  801049:	83 ec 2c             	sub    $0x2c,%esp
  80104c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80104f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801052:	50                   	push   %eax
  801053:	ff 75 08             	pushl  0x8(%ebp)
  801056:	e8 6e fe ff ff       	call   800ec9 <fd_lookup>
  80105b:	83 c4 08             	add    $0x8,%esp
  80105e:	85 c0                	test   %eax,%eax
  801060:	0f 88 c1 00 00 00    	js     801127 <dup+0xe4>
		return r;
	close(newfdnum);
  801066:	83 ec 0c             	sub    $0xc,%esp
  801069:	56                   	push   %esi
  80106a:	e8 84 ff ff ff       	call   800ff3 <close>

	newfd = INDEX2FD(newfdnum);
  80106f:	89 f3                	mov    %esi,%ebx
  801071:	c1 e3 0c             	shl    $0xc,%ebx
  801074:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80107a:	83 c4 04             	add    $0x4,%esp
  80107d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801080:	e8 de fd ff ff       	call   800e63 <fd2data>
  801085:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801087:	89 1c 24             	mov    %ebx,(%esp)
  80108a:	e8 d4 fd ff ff       	call   800e63 <fd2data>
  80108f:	83 c4 10             	add    $0x10,%esp
  801092:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801095:	89 f8                	mov    %edi,%eax
  801097:	c1 e8 16             	shr    $0x16,%eax
  80109a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a1:	a8 01                	test   $0x1,%al
  8010a3:	74 37                	je     8010dc <dup+0x99>
  8010a5:	89 f8                	mov    %edi,%eax
  8010a7:	c1 e8 0c             	shr    $0xc,%eax
  8010aa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010b1:	f6 c2 01             	test   $0x1,%dl
  8010b4:	74 26                	je     8010dc <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010bd:	83 ec 0c             	sub    $0xc,%esp
  8010c0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c5:	50                   	push   %eax
  8010c6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010c9:	6a 00                	push   $0x0
  8010cb:	57                   	push   %edi
  8010cc:	6a 00                	push   $0x0
  8010ce:	e8 d2 fb ff ff       	call   800ca5 <sys_page_map>
  8010d3:	89 c7                	mov    %eax,%edi
  8010d5:	83 c4 20             	add    $0x20,%esp
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	78 2e                	js     80110a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010df:	89 d0                	mov    %edx,%eax
  8010e1:	c1 e8 0c             	shr    $0xc,%eax
  8010e4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010eb:	83 ec 0c             	sub    $0xc,%esp
  8010ee:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f3:	50                   	push   %eax
  8010f4:	53                   	push   %ebx
  8010f5:	6a 00                	push   $0x0
  8010f7:	52                   	push   %edx
  8010f8:	6a 00                	push   $0x0
  8010fa:	e8 a6 fb ff ff       	call   800ca5 <sys_page_map>
  8010ff:	89 c7                	mov    %eax,%edi
  801101:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801104:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801106:	85 ff                	test   %edi,%edi
  801108:	79 1d                	jns    801127 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80110a:	83 ec 08             	sub    $0x8,%esp
  80110d:	53                   	push   %ebx
  80110e:	6a 00                	push   $0x0
  801110:	e8 d2 fb ff ff       	call   800ce7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801115:	83 c4 08             	add    $0x8,%esp
  801118:	ff 75 d4             	pushl  -0x2c(%ebp)
  80111b:	6a 00                	push   $0x0
  80111d:	e8 c5 fb ff ff       	call   800ce7 <sys_page_unmap>
	return r;
  801122:	83 c4 10             	add    $0x10,%esp
  801125:	89 f8                	mov    %edi,%eax
}
  801127:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112a:	5b                   	pop    %ebx
  80112b:	5e                   	pop    %esi
  80112c:	5f                   	pop    %edi
  80112d:	5d                   	pop    %ebp
  80112e:	c3                   	ret    

0080112f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	53                   	push   %ebx
  801133:	83 ec 14             	sub    $0x14,%esp
  801136:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801139:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113c:	50                   	push   %eax
  80113d:	53                   	push   %ebx
  80113e:	e8 86 fd ff ff       	call   800ec9 <fd_lookup>
  801143:	83 c4 08             	add    $0x8,%esp
  801146:	89 c2                	mov    %eax,%edx
  801148:	85 c0                	test   %eax,%eax
  80114a:	78 6d                	js     8011b9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114c:	83 ec 08             	sub    $0x8,%esp
  80114f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801152:	50                   	push   %eax
  801153:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801156:	ff 30                	pushl  (%eax)
  801158:	e8 c2 fd ff ff       	call   800f1f <dev_lookup>
  80115d:	83 c4 10             	add    $0x10,%esp
  801160:	85 c0                	test   %eax,%eax
  801162:	78 4c                	js     8011b0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801164:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801167:	8b 42 08             	mov    0x8(%edx),%eax
  80116a:	83 e0 03             	and    $0x3,%eax
  80116d:	83 f8 01             	cmp    $0x1,%eax
  801170:	75 21                	jne    801193 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801172:	a1 08 40 80 00       	mov    0x804008,%eax
  801177:	8b 40 48             	mov    0x48(%eax),%eax
  80117a:	83 ec 04             	sub    $0x4,%esp
  80117d:	53                   	push   %ebx
  80117e:	50                   	push   %eax
  80117f:	68 ed 28 80 00       	push   $0x8028ed
  801184:	e8 2b f0 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801191:	eb 26                	jmp    8011b9 <read+0x8a>
	}
	if (!dev->dev_read)
  801193:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801196:	8b 40 08             	mov    0x8(%eax),%eax
  801199:	85 c0                	test   %eax,%eax
  80119b:	74 17                	je     8011b4 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80119d:	83 ec 04             	sub    $0x4,%esp
  8011a0:	ff 75 10             	pushl  0x10(%ebp)
  8011a3:	ff 75 0c             	pushl  0xc(%ebp)
  8011a6:	52                   	push   %edx
  8011a7:	ff d0                	call   *%eax
  8011a9:	89 c2                	mov    %eax,%edx
  8011ab:	83 c4 10             	add    $0x10,%esp
  8011ae:	eb 09                	jmp    8011b9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b0:	89 c2                	mov    %eax,%edx
  8011b2:	eb 05                	jmp    8011b9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011b4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011b9:	89 d0                	mov    %edx,%eax
  8011bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011be:	c9                   	leave  
  8011bf:	c3                   	ret    

008011c0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	57                   	push   %edi
  8011c4:	56                   	push   %esi
  8011c5:	53                   	push   %ebx
  8011c6:	83 ec 0c             	sub    $0xc,%esp
  8011c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011cc:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d4:	eb 21                	jmp    8011f7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011d6:	83 ec 04             	sub    $0x4,%esp
  8011d9:	89 f0                	mov    %esi,%eax
  8011db:	29 d8                	sub    %ebx,%eax
  8011dd:	50                   	push   %eax
  8011de:	89 d8                	mov    %ebx,%eax
  8011e0:	03 45 0c             	add    0xc(%ebp),%eax
  8011e3:	50                   	push   %eax
  8011e4:	57                   	push   %edi
  8011e5:	e8 45 ff ff ff       	call   80112f <read>
		if (m < 0)
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	78 10                	js     801201 <readn+0x41>
			return m;
		if (m == 0)
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	74 0a                	je     8011ff <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f5:	01 c3                	add    %eax,%ebx
  8011f7:	39 f3                	cmp    %esi,%ebx
  8011f9:	72 db                	jb     8011d6 <readn+0x16>
  8011fb:	89 d8                	mov    %ebx,%eax
  8011fd:	eb 02                	jmp    801201 <readn+0x41>
  8011ff:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801201:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801204:	5b                   	pop    %ebx
  801205:	5e                   	pop    %esi
  801206:	5f                   	pop    %edi
  801207:	5d                   	pop    %ebp
  801208:	c3                   	ret    

00801209 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	53                   	push   %ebx
  80120d:	83 ec 14             	sub    $0x14,%esp
  801210:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801213:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801216:	50                   	push   %eax
  801217:	53                   	push   %ebx
  801218:	e8 ac fc ff ff       	call   800ec9 <fd_lookup>
  80121d:	83 c4 08             	add    $0x8,%esp
  801220:	89 c2                	mov    %eax,%edx
  801222:	85 c0                	test   %eax,%eax
  801224:	78 68                	js     80128e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801226:	83 ec 08             	sub    $0x8,%esp
  801229:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122c:	50                   	push   %eax
  80122d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801230:	ff 30                	pushl  (%eax)
  801232:	e8 e8 fc ff ff       	call   800f1f <dev_lookup>
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	85 c0                	test   %eax,%eax
  80123c:	78 47                	js     801285 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80123e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801241:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801245:	75 21                	jne    801268 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801247:	a1 08 40 80 00       	mov    0x804008,%eax
  80124c:	8b 40 48             	mov    0x48(%eax),%eax
  80124f:	83 ec 04             	sub    $0x4,%esp
  801252:	53                   	push   %ebx
  801253:	50                   	push   %eax
  801254:	68 09 29 80 00       	push   $0x802909
  801259:	e8 56 ef ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  80125e:	83 c4 10             	add    $0x10,%esp
  801261:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801266:	eb 26                	jmp    80128e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801268:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80126b:	8b 52 0c             	mov    0xc(%edx),%edx
  80126e:	85 d2                	test   %edx,%edx
  801270:	74 17                	je     801289 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801272:	83 ec 04             	sub    $0x4,%esp
  801275:	ff 75 10             	pushl  0x10(%ebp)
  801278:	ff 75 0c             	pushl  0xc(%ebp)
  80127b:	50                   	push   %eax
  80127c:	ff d2                	call   *%edx
  80127e:	89 c2                	mov    %eax,%edx
  801280:	83 c4 10             	add    $0x10,%esp
  801283:	eb 09                	jmp    80128e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801285:	89 c2                	mov    %eax,%edx
  801287:	eb 05                	jmp    80128e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801289:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80128e:	89 d0                	mov    %edx,%eax
  801290:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801293:	c9                   	leave  
  801294:	c3                   	ret    

00801295 <seek>:

int
seek(int fdnum, off_t offset)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80129b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80129e:	50                   	push   %eax
  80129f:	ff 75 08             	pushl  0x8(%ebp)
  8012a2:	e8 22 fc ff ff       	call   800ec9 <fd_lookup>
  8012a7:	83 c4 08             	add    $0x8,%esp
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	78 0e                	js     8012bc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012bc:	c9                   	leave  
  8012bd:	c3                   	ret    

008012be <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	53                   	push   %ebx
  8012c2:	83 ec 14             	sub    $0x14,%esp
  8012c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cb:	50                   	push   %eax
  8012cc:	53                   	push   %ebx
  8012cd:	e8 f7 fb ff ff       	call   800ec9 <fd_lookup>
  8012d2:	83 c4 08             	add    $0x8,%esp
  8012d5:	89 c2                	mov    %eax,%edx
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 65                	js     801340 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e1:	50                   	push   %eax
  8012e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e5:	ff 30                	pushl  (%eax)
  8012e7:	e8 33 fc ff ff       	call   800f1f <dev_lookup>
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 44                	js     801337 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012fa:	75 21                	jne    80131d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012fc:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801301:	8b 40 48             	mov    0x48(%eax),%eax
  801304:	83 ec 04             	sub    $0x4,%esp
  801307:	53                   	push   %ebx
  801308:	50                   	push   %eax
  801309:	68 cc 28 80 00       	push   $0x8028cc
  80130e:	e8 a1 ee ff ff       	call   8001b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801313:	83 c4 10             	add    $0x10,%esp
  801316:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80131b:	eb 23                	jmp    801340 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80131d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801320:	8b 52 18             	mov    0x18(%edx),%edx
  801323:	85 d2                	test   %edx,%edx
  801325:	74 14                	je     80133b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801327:	83 ec 08             	sub    $0x8,%esp
  80132a:	ff 75 0c             	pushl  0xc(%ebp)
  80132d:	50                   	push   %eax
  80132e:	ff d2                	call   *%edx
  801330:	89 c2                	mov    %eax,%edx
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	eb 09                	jmp    801340 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801337:	89 c2                	mov    %eax,%edx
  801339:	eb 05                	jmp    801340 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80133b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801340:	89 d0                	mov    %edx,%eax
  801342:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801345:	c9                   	leave  
  801346:	c3                   	ret    

00801347 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	53                   	push   %ebx
  80134b:	83 ec 14             	sub    $0x14,%esp
  80134e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801351:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801354:	50                   	push   %eax
  801355:	ff 75 08             	pushl  0x8(%ebp)
  801358:	e8 6c fb ff ff       	call   800ec9 <fd_lookup>
  80135d:	83 c4 08             	add    $0x8,%esp
  801360:	89 c2                	mov    %eax,%edx
  801362:	85 c0                	test   %eax,%eax
  801364:	78 58                	js     8013be <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136c:	50                   	push   %eax
  80136d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801370:	ff 30                	pushl  (%eax)
  801372:	e8 a8 fb ff ff       	call   800f1f <dev_lookup>
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	85 c0                	test   %eax,%eax
  80137c:	78 37                	js     8013b5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80137e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801381:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801385:	74 32                	je     8013b9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801387:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80138a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801391:	00 00 00 
	stat->st_isdir = 0;
  801394:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80139b:	00 00 00 
	stat->st_dev = dev;
  80139e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013a4:	83 ec 08             	sub    $0x8,%esp
  8013a7:	53                   	push   %ebx
  8013a8:	ff 75 f0             	pushl  -0x10(%ebp)
  8013ab:	ff 50 14             	call   *0x14(%eax)
  8013ae:	89 c2                	mov    %eax,%edx
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	eb 09                	jmp    8013be <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b5:	89 c2                	mov    %eax,%edx
  8013b7:	eb 05                	jmp    8013be <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013be:	89 d0                	mov    %edx,%eax
  8013c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    

008013c5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	56                   	push   %esi
  8013c9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013ca:	83 ec 08             	sub    $0x8,%esp
  8013cd:	6a 00                	push   $0x0
  8013cf:	ff 75 08             	pushl  0x8(%ebp)
  8013d2:	e8 2b 02 00 00       	call   801602 <open>
  8013d7:	89 c3                	mov    %eax,%ebx
  8013d9:	83 c4 10             	add    $0x10,%esp
  8013dc:	85 c0                	test   %eax,%eax
  8013de:	78 1b                	js     8013fb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013e0:	83 ec 08             	sub    $0x8,%esp
  8013e3:	ff 75 0c             	pushl  0xc(%ebp)
  8013e6:	50                   	push   %eax
  8013e7:	e8 5b ff ff ff       	call   801347 <fstat>
  8013ec:	89 c6                	mov    %eax,%esi
	close(fd);
  8013ee:	89 1c 24             	mov    %ebx,(%esp)
  8013f1:	e8 fd fb ff ff       	call   800ff3 <close>
	return r;
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	89 f0                	mov    %esi,%eax
}
  8013fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fe:	5b                   	pop    %ebx
  8013ff:	5e                   	pop    %esi
  801400:	5d                   	pop    %ebp
  801401:	c3                   	ret    

00801402 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801402:	55                   	push   %ebp
  801403:	89 e5                	mov    %esp,%ebp
  801405:	56                   	push   %esi
  801406:	53                   	push   %ebx
  801407:	89 c6                	mov    %eax,%esi
  801409:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80140b:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801412:	75 12                	jne    801426 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801414:	83 ec 0c             	sub    $0xc,%esp
  801417:	6a 01                	push   $0x1
  801419:	e8 db 0d 00 00       	call   8021f9 <ipc_find_env>
  80141e:	a3 04 40 80 00       	mov    %eax,0x804004
  801423:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801426:	6a 07                	push   $0x7
  801428:	68 00 50 80 00       	push   $0x805000
  80142d:	56                   	push   %esi
  80142e:	ff 35 04 40 80 00    	pushl  0x804004
  801434:	e8 6a 0d 00 00       	call   8021a3 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801439:	83 c4 0c             	add    $0xc,%esp
  80143c:	6a 00                	push   $0x0
  80143e:	53                   	push   %ebx
  80143f:	6a 00                	push   $0x0
  801441:	e8 f4 0c 00 00       	call   80213a <ipc_recv>
}
  801446:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801449:	5b                   	pop    %ebx
  80144a:	5e                   	pop    %esi
  80144b:	5d                   	pop    %ebp
  80144c:	c3                   	ret    

0080144d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80144d:	55                   	push   %ebp
  80144e:	89 e5                	mov    %esp,%ebp
  801450:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801453:	8b 45 08             	mov    0x8(%ebp),%eax
  801456:	8b 40 0c             	mov    0xc(%eax),%eax
  801459:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80145e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801461:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801466:	ba 00 00 00 00       	mov    $0x0,%edx
  80146b:	b8 02 00 00 00       	mov    $0x2,%eax
  801470:	e8 8d ff ff ff       	call   801402 <fsipc>
}
  801475:	c9                   	leave  
  801476:	c3                   	ret    

00801477 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80147d:	8b 45 08             	mov    0x8(%ebp),%eax
  801480:	8b 40 0c             	mov    0xc(%eax),%eax
  801483:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801488:	ba 00 00 00 00       	mov    $0x0,%edx
  80148d:	b8 06 00 00 00       	mov    $0x6,%eax
  801492:	e8 6b ff ff ff       	call   801402 <fsipc>
}
  801497:	c9                   	leave  
  801498:	c3                   	ret    

00801499 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801499:	55                   	push   %ebp
  80149a:	89 e5                	mov    %esp,%ebp
  80149c:	53                   	push   %ebx
  80149d:	83 ec 04             	sub    $0x4,%esp
  8014a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b3:	b8 05 00 00 00       	mov    $0x5,%eax
  8014b8:	e8 45 ff ff ff       	call   801402 <fsipc>
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 2c                	js     8014ed <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014c1:	83 ec 08             	sub    $0x8,%esp
  8014c4:	68 00 50 80 00       	push   $0x805000
  8014c9:	53                   	push   %ebx
  8014ca:	e8 19 f3 ff ff       	call   8007e8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014cf:	a1 80 50 80 00       	mov    0x805080,%eax
  8014d4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014da:	a1 84 50 80 00       	mov    0x805084,%eax
  8014df:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f0:	c9                   	leave  
  8014f1:	c3                   	ret    

008014f2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	53                   	push   %ebx
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8014fc:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801501:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801506:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801509:	8b 45 08             	mov    0x8(%ebp),%eax
  80150c:	8b 40 0c             	mov    0xc(%eax),%eax
  80150f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801514:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80151a:	53                   	push   %ebx
  80151b:	ff 75 0c             	pushl  0xc(%ebp)
  80151e:	68 08 50 80 00       	push   $0x805008
  801523:	e8 52 f4 ff ff       	call   80097a <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801528:	ba 00 00 00 00       	mov    $0x0,%edx
  80152d:	b8 04 00 00 00       	mov    $0x4,%eax
  801532:	e8 cb fe ff ff       	call   801402 <fsipc>
  801537:	83 c4 10             	add    $0x10,%esp
  80153a:	85 c0                	test   %eax,%eax
  80153c:	78 3d                	js     80157b <devfile_write+0x89>
		return r;

	assert(r <= n);
  80153e:	39 d8                	cmp    %ebx,%eax
  801540:	76 19                	jbe    80155b <devfile_write+0x69>
  801542:	68 38 29 80 00       	push   $0x802938
  801547:	68 3f 29 80 00       	push   $0x80293f
  80154c:	68 9f 00 00 00       	push   $0x9f
  801551:	68 54 29 80 00       	push   $0x802954
  801556:	e8 80 eb ff ff       	call   8000db <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  80155b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801560:	76 19                	jbe    80157b <devfile_write+0x89>
  801562:	68 6c 29 80 00       	push   $0x80296c
  801567:	68 3f 29 80 00       	push   $0x80293f
  80156c:	68 a0 00 00 00       	push   $0xa0
  801571:	68 54 29 80 00       	push   $0x802954
  801576:	e8 60 eb ff ff       	call   8000db <_panic>

	return r;
}
  80157b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	56                   	push   %esi
  801584:	53                   	push   %ebx
  801585:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801588:	8b 45 08             	mov    0x8(%ebp),%eax
  80158b:	8b 40 0c             	mov    0xc(%eax),%eax
  80158e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801593:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801599:	ba 00 00 00 00       	mov    $0x0,%edx
  80159e:	b8 03 00 00 00       	mov    $0x3,%eax
  8015a3:	e8 5a fe ff ff       	call   801402 <fsipc>
  8015a8:	89 c3                	mov    %eax,%ebx
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 4b                	js     8015f9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015ae:	39 c6                	cmp    %eax,%esi
  8015b0:	73 16                	jae    8015c8 <devfile_read+0x48>
  8015b2:	68 38 29 80 00       	push   $0x802938
  8015b7:	68 3f 29 80 00       	push   $0x80293f
  8015bc:	6a 7e                	push   $0x7e
  8015be:	68 54 29 80 00       	push   $0x802954
  8015c3:	e8 13 eb ff ff       	call   8000db <_panic>
	assert(r <= PGSIZE);
  8015c8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015cd:	7e 16                	jle    8015e5 <devfile_read+0x65>
  8015cf:	68 5f 29 80 00       	push   $0x80295f
  8015d4:	68 3f 29 80 00       	push   $0x80293f
  8015d9:	6a 7f                	push   $0x7f
  8015db:	68 54 29 80 00       	push   $0x802954
  8015e0:	e8 f6 ea ff ff       	call   8000db <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015e5:	83 ec 04             	sub    $0x4,%esp
  8015e8:	50                   	push   %eax
  8015e9:	68 00 50 80 00       	push   $0x805000
  8015ee:	ff 75 0c             	pushl  0xc(%ebp)
  8015f1:	e8 84 f3 ff ff       	call   80097a <memmove>
	return r;
  8015f6:	83 c4 10             	add    $0x10,%esp
}
  8015f9:	89 d8                	mov    %ebx,%eax
  8015fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015fe:	5b                   	pop    %ebx
  8015ff:	5e                   	pop    %esi
  801600:	5d                   	pop    %ebp
  801601:	c3                   	ret    

00801602 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	53                   	push   %ebx
  801606:	83 ec 20             	sub    $0x20,%esp
  801609:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80160c:	53                   	push   %ebx
  80160d:	e8 9d f1 ff ff       	call   8007af <strlen>
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80161a:	7f 67                	jg     801683 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80161c:	83 ec 0c             	sub    $0xc,%esp
  80161f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801622:	50                   	push   %eax
  801623:	e8 52 f8 ff ff       	call   800e7a <fd_alloc>
  801628:	83 c4 10             	add    $0x10,%esp
		return r;
  80162b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80162d:	85 c0                	test   %eax,%eax
  80162f:	78 57                	js     801688 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801631:	83 ec 08             	sub    $0x8,%esp
  801634:	53                   	push   %ebx
  801635:	68 00 50 80 00       	push   $0x805000
  80163a:	e8 a9 f1 ff ff       	call   8007e8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80163f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801642:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801647:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80164a:	b8 01 00 00 00       	mov    $0x1,%eax
  80164f:	e8 ae fd ff ff       	call   801402 <fsipc>
  801654:	89 c3                	mov    %eax,%ebx
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	85 c0                	test   %eax,%eax
  80165b:	79 14                	jns    801671 <open+0x6f>
		fd_close(fd, 0);
  80165d:	83 ec 08             	sub    $0x8,%esp
  801660:	6a 00                	push   $0x0
  801662:	ff 75 f4             	pushl  -0xc(%ebp)
  801665:	e8 08 f9 ff ff       	call   800f72 <fd_close>
		return r;
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	89 da                	mov    %ebx,%edx
  80166f:	eb 17                	jmp    801688 <open+0x86>
	}

	return fd2num(fd);
  801671:	83 ec 0c             	sub    $0xc,%esp
  801674:	ff 75 f4             	pushl  -0xc(%ebp)
  801677:	e8 d7 f7 ff ff       	call   800e53 <fd2num>
  80167c:	89 c2                	mov    %eax,%edx
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	eb 05                	jmp    801688 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801683:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801688:	89 d0                	mov    %edx,%eax
  80168a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168d:	c9                   	leave  
  80168e:	c3                   	ret    

0080168f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801695:	ba 00 00 00 00       	mov    $0x0,%edx
  80169a:	b8 08 00 00 00       	mov    $0x8,%eax
  80169f:	e8 5e fd ff ff       	call   801402 <fsipc>
}
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	57                   	push   %edi
  8016aa:	56                   	push   %esi
  8016ab:	53                   	push   %ebx
  8016ac:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8016b2:	6a 00                	push   $0x0
  8016b4:	ff 75 08             	pushl  0x8(%ebp)
  8016b7:	e8 46 ff ff ff       	call   801602 <open>
  8016bc:	89 c7                	mov    %eax,%edi
  8016be:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	0f 88 af 04 00 00    	js     801b7e <spawn+0x4d8>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8016cf:	83 ec 04             	sub    $0x4,%esp
  8016d2:	68 00 02 00 00       	push   $0x200
  8016d7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8016dd:	50                   	push   %eax
  8016de:	57                   	push   %edi
  8016df:	e8 dc fa ff ff       	call   8011c0 <readn>
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	3d 00 02 00 00       	cmp    $0x200,%eax
  8016ec:	75 0c                	jne    8016fa <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8016ee:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8016f5:	45 4c 46 
  8016f8:	74 33                	je     80172d <spawn+0x87>
		close(fd);
  8016fa:	83 ec 0c             	sub    $0xc,%esp
  8016fd:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801703:	e8 eb f8 ff ff       	call   800ff3 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801708:	83 c4 0c             	add    $0xc,%esp
  80170b:	68 7f 45 4c 46       	push   $0x464c457f
  801710:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801716:	68 99 29 80 00       	push   $0x802999
  80171b:	e8 94 ea ff ff       	call   8001b4 <cprintf>
		return -E_NOT_EXEC;
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801728:	e9 b1 04 00 00       	jmp    801bde <spawn+0x538>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80172d:	b8 07 00 00 00       	mov    $0x7,%eax
  801732:	cd 30                	int    $0x30
  801734:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80173a:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801740:	85 c0                	test   %eax,%eax
  801742:	0f 88 3e 04 00 00    	js     801b86 <spawn+0x4e0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801748:	89 c6                	mov    %eax,%esi
  80174a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801750:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801753:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801759:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80175f:	b9 11 00 00 00       	mov    $0x11,%ecx
  801764:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801766:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80176c:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801772:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801777:	be 00 00 00 00       	mov    $0x0,%esi
  80177c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80177f:	eb 13                	jmp    801794 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801781:	83 ec 0c             	sub    $0xc,%esp
  801784:	50                   	push   %eax
  801785:	e8 25 f0 ff ff       	call   8007af <strlen>
  80178a:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80178e:	83 c3 01             	add    $0x1,%ebx
  801791:	83 c4 10             	add    $0x10,%esp
  801794:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80179b:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	75 df                	jne    801781 <spawn+0xdb>
  8017a2:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8017a8:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8017ae:	bf 00 10 40 00       	mov    $0x401000,%edi
  8017b3:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8017b5:	89 fa                	mov    %edi,%edx
  8017b7:	83 e2 fc             	and    $0xfffffffc,%edx
  8017ba:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8017c1:	29 c2                	sub    %eax,%edx
  8017c3:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8017c9:	8d 42 f8             	lea    -0x8(%edx),%eax
  8017cc:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8017d1:	0f 86 bf 03 00 00    	jbe    801b96 <spawn+0x4f0>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8017d7:	83 ec 04             	sub    $0x4,%esp
  8017da:	6a 07                	push   $0x7
  8017dc:	68 00 00 40 00       	push   $0x400000
  8017e1:	6a 00                	push   $0x0
  8017e3:	e8 7a f4 ff ff       	call   800c62 <sys_page_alloc>
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	0f 88 aa 03 00 00    	js     801b9d <spawn+0x4f7>
  8017f3:	be 00 00 00 00       	mov    $0x0,%esi
  8017f8:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8017fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801801:	eb 30                	jmp    801833 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801803:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801809:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80180f:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801812:	83 ec 08             	sub    $0x8,%esp
  801815:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801818:	57                   	push   %edi
  801819:	e8 ca ef ff ff       	call   8007e8 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80181e:	83 c4 04             	add    $0x4,%esp
  801821:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801824:	e8 86 ef ff ff       	call   8007af <strlen>
  801829:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80182d:	83 c6 01             	add    $0x1,%esi
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801839:	7f c8                	jg     801803 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80183b:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801841:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801847:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80184e:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801854:	74 19                	je     80186f <spawn+0x1c9>
  801856:	68 20 2a 80 00       	push   $0x802a20
  80185b:	68 3f 29 80 00       	push   $0x80293f
  801860:	68 f2 00 00 00       	push   $0xf2
  801865:	68 b3 29 80 00       	push   $0x8029b3
  80186a:	e8 6c e8 ff ff       	call   8000db <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80186f:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801875:	89 f8                	mov    %edi,%eax
  801877:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80187c:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  80187f:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801885:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801888:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  80188e:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801894:	83 ec 0c             	sub    $0xc,%esp
  801897:	6a 07                	push   $0x7
  801899:	68 00 d0 bf ee       	push   $0xeebfd000
  80189e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8018a4:	68 00 00 40 00       	push   $0x400000
  8018a9:	6a 00                	push   $0x0
  8018ab:	e8 f5 f3 ff ff       	call   800ca5 <sys_page_map>
  8018b0:	89 c3                	mov    %eax,%ebx
  8018b2:	83 c4 20             	add    $0x20,%esp
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	0f 88 0f 03 00 00    	js     801bcc <spawn+0x526>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8018bd:	83 ec 08             	sub    $0x8,%esp
  8018c0:	68 00 00 40 00       	push   $0x400000
  8018c5:	6a 00                	push   $0x0
  8018c7:	e8 1b f4 ff ff       	call   800ce7 <sys_page_unmap>
  8018cc:	89 c3                	mov    %eax,%ebx
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	85 c0                	test   %eax,%eax
  8018d3:	0f 88 f3 02 00 00    	js     801bcc <spawn+0x526>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8018d9:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8018df:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8018e6:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8018ec:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8018f3:	00 00 00 
  8018f6:	e9 88 01 00 00       	jmp    801a83 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  8018fb:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801901:	83 38 01             	cmpl   $0x1,(%eax)
  801904:	0f 85 6b 01 00 00    	jne    801a75 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80190a:	89 c7                	mov    %eax,%edi
  80190c:	8b 40 18             	mov    0x18(%eax),%eax
  80190f:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801915:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801918:	83 f8 01             	cmp    $0x1,%eax
  80191b:	19 c0                	sbb    %eax,%eax
  80191d:	83 e0 fe             	and    $0xfffffffe,%eax
  801920:	83 c0 07             	add    $0x7,%eax
  801923:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801929:	89 f8                	mov    %edi,%eax
  80192b:	8b 7f 04             	mov    0x4(%edi),%edi
  80192e:	89 f9                	mov    %edi,%ecx
  801930:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801936:	8b 78 10             	mov    0x10(%eax),%edi
  801939:	8b 50 14             	mov    0x14(%eax),%edx
  80193c:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801942:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801945:	89 f0                	mov    %esi,%eax
  801947:	25 ff 0f 00 00       	and    $0xfff,%eax
  80194c:	74 14                	je     801962 <spawn+0x2bc>
		va -= i;
  80194e:	29 c6                	sub    %eax,%esi
		memsz += i;
  801950:	01 c2                	add    %eax,%edx
  801952:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801958:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80195a:	29 c1                	sub    %eax,%ecx
  80195c:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801962:	bb 00 00 00 00       	mov    $0x0,%ebx
  801967:	e9 f7 00 00 00       	jmp    801a63 <spawn+0x3bd>
		if (i >= filesz) {
  80196c:	39 df                	cmp    %ebx,%edi
  80196e:	77 27                	ja     801997 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801970:	83 ec 04             	sub    $0x4,%esp
  801973:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801979:	56                   	push   %esi
  80197a:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801980:	e8 dd f2 ff ff       	call   800c62 <sys_page_alloc>
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	85 c0                	test   %eax,%eax
  80198a:	0f 89 c7 00 00 00    	jns    801a57 <spawn+0x3b1>
  801990:	89 c3                	mov    %eax,%ebx
  801992:	e9 14 02 00 00       	jmp    801bab <spawn+0x505>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801997:	83 ec 04             	sub    $0x4,%esp
  80199a:	6a 07                	push   $0x7
  80199c:	68 00 00 40 00       	push   $0x400000
  8019a1:	6a 00                	push   $0x0
  8019a3:	e8 ba f2 ff ff       	call   800c62 <sys_page_alloc>
  8019a8:	83 c4 10             	add    $0x10,%esp
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	0f 88 ee 01 00 00    	js     801ba1 <spawn+0x4fb>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8019b3:	83 ec 08             	sub    $0x8,%esp
  8019b6:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8019bc:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8019c2:	50                   	push   %eax
  8019c3:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019c9:	e8 c7 f8 ff ff       	call   801295 <seek>
  8019ce:	83 c4 10             	add    $0x10,%esp
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	0f 88 cc 01 00 00    	js     801ba5 <spawn+0x4ff>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8019d9:	83 ec 04             	sub    $0x4,%esp
  8019dc:	89 f8                	mov    %edi,%eax
  8019de:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8019e4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019e9:	ba 00 10 00 00       	mov    $0x1000,%edx
  8019ee:	0f 47 c2             	cmova  %edx,%eax
  8019f1:	50                   	push   %eax
  8019f2:	68 00 00 40 00       	push   $0x400000
  8019f7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019fd:	e8 be f7 ff ff       	call   8011c0 <readn>
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	85 c0                	test   %eax,%eax
  801a07:	0f 88 9c 01 00 00    	js     801ba9 <spawn+0x503>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801a0d:	83 ec 0c             	sub    $0xc,%esp
  801a10:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801a16:	56                   	push   %esi
  801a17:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801a1d:	68 00 00 40 00       	push   $0x400000
  801a22:	6a 00                	push   $0x0
  801a24:	e8 7c f2 ff ff       	call   800ca5 <sys_page_map>
  801a29:	83 c4 20             	add    $0x20,%esp
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	79 15                	jns    801a45 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801a30:	50                   	push   %eax
  801a31:	68 bf 29 80 00       	push   $0x8029bf
  801a36:	68 25 01 00 00       	push   $0x125
  801a3b:	68 b3 29 80 00       	push   $0x8029b3
  801a40:	e8 96 e6 ff ff       	call   8000db <_panic>
			sys_page_unmap(0, UTEMP);
  801a45:	83 ec 08             	sub    $0x8,%esp
  801a48:	68 00 00 40 00       	push   $0x400000
  801a4d:	6a 00                	push   $0x0
  801a4f:	e8 93 f2 ff ff       	call   800ce7 <sys_page_unmap>
  801a54:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801a57:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a5d:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801a63:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801a69:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801a6f:	0f 87 f7 fe ff ff    	ja     80196c <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a75:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801a7c:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801a83:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a8a:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801a90:	0f 8c 65 fe ff ff    	jl     8018fb <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a96:	83 ec 0c             	sub    $0xc,%esp
  801a99:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a9f:	e8 4f f5 ff ff       	call   800ff3 <close>
  801aa4:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	int r;

	// loop through all page table entries
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn) {
  801aa7:	bb 00 08 00 00       	mov    $0x800,%ebx
  801aac:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		// the page table does not exist at all
		if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) {
  801ab2:	89 d8                	mov    %ebx,%eax
  801ab4:	c1 e0 0c             	shl    $0xc,%eax
  801ab7:	89 c2                	mov    %eax,%edx
  801ab9:	c1 ea 16             	shr    $0x16,%edx
  801abc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ac3:	f6 c2 01             	test   $0x1,%dl
  801ac6:	75 08                	jne    801ad0 <spawn+0x42a>
			pn += NPTENTRIES - 1;
  801ac8:	81 c3 ff 03 00 00    	add    $0x3ff,%ebx
  801ace:	eb 3c                	jmp    801b0c <spawn+0x466>
			continue;
		}

		// virtual page pn's page table entry
		pte_t pe = uvpt[pn];
  801ad0:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx

		// share the page with the new environment
		if(pe & PTE_SHARE) {
  801ad7:	f6 c6 04             	test   $0x4,%dh
  801ada:	74 30                	je     801b0c <spawn+0x466>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), child, 
  801adc:	83 ec 0c             	sub    $0xc,%esp
  801adf:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801ae5:	52                   	push   %edx
  801ae6:	50                   	push   %eax
  801ae7:	56                   	push   %esi
  801ae8:	50                   	push   %eax
  801ae9:	6a 00                	push   $0x0
  801aeb:	e8 b5 f1 ff ff       	call   800ca5 <sys_page_map>
  801af0:	83 c4 20             	add    $0x20,%esp
  801af3:	85 c0                	test   %eax,%eax
  801af5:	79 15                	jns    801b0c <spawn+0x466>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("copy_shared: %e", r);
  801af7:	50                   	push   %eax
  801af8:	68 dc 29 80 00       	push   $0x8029dc
  801afd:	68 42 01 00 00       	push   $0x142
  801b02:	68 b3 29 80 00       	push   $0x8029b3
  801b07:	e8 cf e5 ff ff       	call   8000db <_panic>
{
	// LAB 5: Your code here.
	int r;

	// loop through all page table entries
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn) {
  801b0c:	83 c3 01             	add    $0x1,%ebx
  801b0f:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801b15:	76 9b                	jbe    801ab2 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801b17:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801b1e:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b21:	83 ec 08             	sub    $0x8,%esp
  801b24:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b2a:	50                   	push   %eax
  801b2b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b31:	e8 35 f2 ff ff       	call   800d6b <sys_env_set_trapframe>
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	79 15                	jns    801b52 <spawn+0x4ac>
		panic("sys_env_set_trapframe: %e", r);
  801b3d:	50                   	push   %eax
  801b3e:	68 ec 29 80 00       	push   $0x8029ec
  801b43:	68 86 00 00 00       	push   $0x86
  801b48:	68 b3 29 80 00       	push   $0x8029b3
  801b4d:	e8 89 e5 ff ff       	call   8000db <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801b52:	83 ec 08             	sub    $0x8,%esp
  801b55:	6a 02                	push   $0x2
  801b57:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b5d:	e8 c7 f1 ff ff       	call   800d29 <sys_env_set_status>
  801b62:	83 c4 10             	add    $0x10,%esp
  801b65:	85 c0                	test   %eax,%eax
  801b67:	79 25                	jns    801b8e <spawn+0x4e8>
		panic("sys_env_set_status: %e", r);
  801b69:	50                   	push   %eax
  801b6a:	68 06 2a 80 00       	push   $0x802a06
  801b6f:	68 89 00 00 00       	push   $0x89
  801b74:	68 b3 29 80 00       	push   $0x8029b3
  801b79:	e8 5d e5 ff ff       	call   8000db <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801b7e:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801b84:	eb 58                	jmp    801bde <spawn+0x538>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801b86:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b8c:	eb 50                	jmp    801bde <spawn+0x538>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801b8e:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b94:	eb 48                	jmp    801bde <spawn+0x538>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801b96:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801b9b:	eb 41                	jmp    801bde <spawn+0x538>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801b9d:	89 c3                	mov    %eax,%ebx
  801b9f:	eb 3d                	jmp    801bde <spawn+0x538>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ba1:	89 c3                	mov    %eax,%ebx
  801ba3:	eb 06                	jmp    801bab <spawn+0x505>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ba5:	89 c3                	mov    %eax,%ebx
  801ba7:	eb 02                	jmp    801bab <spawn+0x505>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ba9:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801bab:	83 ec 0c             	sub    $0xc,%esp
  801bae:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801bb4:	e8 2a f0 ff ff       	call   800be3 <sys_env_destroy>
	close(fd);
  801bb9:	83 c4 04             	add    $0x4,%esp
  801bbc:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bc2:	e8 2c f4 ff ff       	call   800ff3 <close>
	return r;
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	eb 12                	jmp    801bde <spawn+0x538>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801bcc:	83 ec 08             	sub    $0x8,%esp
  801bcf:	68 00 00 40 00       	push   $0x400000
  801bd4:	6a 00                	push   $0x0
  801bd6:	e8 0c f1 ff ff       	call   800ce7 <sys_page_unmap>
  801bdb:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801bde:	89 d8                	mov    %ebx,%eax
  801be0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5f                   	pop    %edi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	56                   	push   %esi
  801bec:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801bed:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801bf0:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801bf5:	eb 03                	jmp    801bfa <spawnl+0x12>
		argc++;
  801bf7:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801bfa:	83 c2 04             	add    $0x4,%edx
  801bfd:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801c01:	75 f4                	jne    801bf7 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801c03:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801c0a:	83 e2 f0             	and    $0xfffffff0,%edx
  801c0d:	29 d4                	sub    %edx,%esp
  801c0f:	8d 54 24 03          	lea    0x3(%esp),%edx
  801c13:	c1 ea 02             	shr    $0x2,%edx
  801c16:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801c1d:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801c1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c22:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801c29:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801c30:	00 
  801c31:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c33:	b8 00 00 00 00       	mov    $0x0,%eax
  801c38:	eb 0a                	jmp    801c44 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801c3a:	83 c0 01             	add    $0x1,%eax
  801c3d:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801c41:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c44:	39 d0                	cmp    %edx,%eax
  801c46:	75 f2                	jne    801c3a <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801c48:	83 ec 08             	sub    $0x8,%esp
  801c4b:	56                   	push   %esi
  801c4c:	ff 75 08             	pushl  0x8(%ebp)
  801c4f:	e8 52 fa ff ff       	call   8016a6 <spawn>
}
  801c54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c57:	5b                   	pop    %ebx
  801c58:	5e                   	pop    %esi
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    

00801c5b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	56                   	push   %esi
  801c5f:	53                   	push   %ebx
  801c60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c63:	83 ec 0c             	sub    $0xc,%esp
  801c66:	ff 75 08             	pushl  0x8(%ebp)
  801c69:	e8 f5 f1 ff ff       	call   800e63 <fd2data>
  801c6e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c70:	83 c4 08             	add    $0x8,%esp
  801c73:	68 46 2a 80 00       	push   $0x802a46
  801c78:	53                   	push   %ebx
  801c79:	e8 6a eb ff ff       	call   8007e8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c7e:	8b 46 04             	mov    0x4(%esi),%eax
  801c81:	2b 06                	sub    (%esi),%eax
  801c83:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c89:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c90:	00 00 00 
	stat->st_dev = &devpipe;
  801c93:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c9a:	30 80 00 
	return 0;
}
  801c9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ca5:	5b                   	pop    %ebx
  801ca6:	5e                   	pop    %esi
  801ca7:	5d                   	pop    %ebp
  801ca8:	c3                   	ret    

00801ca9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	53                   	push   %ebx
  801cad:	83 ec 0c             	sub    $0xc,%esp
  801cb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cb3:	53                   	push   %ebx
  801cb4:	6a 00                	push   $0x0
  801cb6:	e8 2c f0 ff ff       	call   800ce7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cbb:	89 1c 24             	mov    %ebx,(%esp)
  801cbe:	e8 a0 f1 ff ff       	call   800e63 <fd2data>
  801cc3:	83 c4 08             	add    $0x8,%esp
  801cc6:	50                   	push   %eax
  801cc7:	6a 00                	push   $0x0
  801cc9:	e8 19 f0 ff ff       	call   800ce7 <sys_page_unmap>
}
  801cce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd1:	c9                   	leave  
  801cd2:	c3                   	ret    

00801cd3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	57                   	push   %edi
  801cd7:	56                   	push   %esi
  801cd8:	53                   	push   %ebx
  801cd9:	83 ec 1c             	sub    $0x1c,%esp
  801cdc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cdf:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ce1:	a1 08 40 80 00       	mov    0x804008,%eax
  801ce6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ce9:	83 ec 0c             	sub    $0xc,%esp
  801cec:	ff 75 e0             	pushl  -0x20(%ebp)
  801cef:	e8 3e 05 00 00       	call   802232 <pageref>
  801cf4:	89 c3                	mov    %eax,%ebx
  801cf6:	89 3c 24             	mov    %edi,(%esp)
  801cf9:	e8 34 05 00 00       	call   802232 <pageref>
  801cfe:	83 c4 10             	add    $0x10,%esp
  801d01:	39 c3                	cmp    %eax,%ebx
  801d03:	0f 94 c1             	sete   %cl
  801d06:	0f b6 c9             	movzbl %cl,%ecx
  801d09:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d0c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d12:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d15:	39 ce                	cmp    %ecx,%esi
  801d17:	74 1b                	je     801d34 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d19:	39 c3                	cmp    %eax,%ebx
  801d1b:	75 c4                	jne    801ce1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d1d:	8b 42 58             	mov    0x58(%edx),%eax
  801d20:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d23:	50                   	push   %eax
  801d24:	56                   	push   %esi
  801d25:	68 4d 2a 80 00       	push   $0x802a4d
  801d2a:	e8 85 e4 ff ff       	call   8001b4 <cprintf>
  801d2f:	83 c4 10             	add    $0x10,%esp
  801d32:	eb ad                	jmp    801ce1 <_pipeisclosed+0xe>
	}
}
  801d34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d3a:	5b                   	pop    %ebx
  801d3b:	5e                   	pop    %esi
  801d3c:	5f                   	pop    %edi
  801d3d:	5d                   	pop    %ebp
  801d3e:	c3                   	ret    

00801d3f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d3f:	55                   	push   %ebp
  801d40:	89 e5                	mov    %esp,%ebp
  801d42:	57                   	push   %edi
  801d43:	56                   	push   %esi
  801d44:	53                   	push   %ebx
  801d45:	83 ec 28             	sub    $0x28,%esp
  801d48:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d4b:	56                   	push   %esi
  801d4c:	e8 12 f1 ff ff       	call   800e63 <fd2data>
  801d51:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d53:	83 c4 10             	add    $0x10,%esp
  801d56:	bf 00 00 00 00       	mov    $0x0,%edi
  801d5b:	eb 4b                	jmp    801da8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d5d:	89 da                	mov    %ebx,%edx
  801d5f:	89 f0                	mov    %esi,%eax
  801d61:	e8 6d ff ff ff       	call   801cd3 <_pipeisclosed>
  801d66:	85 c0                	test   %eax,%eax
  801d68:	75 48                	jne    801db2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d6a:	e8 d4 ee ff ff       	call   800c43 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d6f:	8b 43 04             	mov    0x4(%ebx),%eax
  801d72:	8b 0b                	mov    (%ebx),%ecx
  801d74:	8d 51 20             	lea    0x20(%ecx),%edx
  801d77:	39 d0                	cmp    %edx,%eax
  801d79:	73 e2                	jae    801d5d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d7e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d82:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d85:	89 c2                	mov    %eax,%edx
  801d87:	c1 fa 1f             	sar    $0x1f,%edx
  801d8a:	89 d1                	mov    %edx,%ecx
  801d8c:	c1 e9 1b             	shr    $0x1b,%ecx
  801d8f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d92:	83 e2 1f             	and    $0x1f,%edx
  801d95:	29 ca                	sub    %ecx,%edx
  801d97:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d9b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d9f:	83 c0 01             	add    $0x1,%eax
  801da2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da5:	83 c7 01             	add    $0x1,%edi
  801da8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dab:	75 c2                	jne    801d6f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801dad:	8b 45 10             	mov    0x10(%ebp),%eax
  801db0:	eb 05                	jmp    801db7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801db2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801db7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dba:	5b                   	pop    %ebx
  801dbb:	5e                   	pop    %esi
  801dbc:	5f                   	pop    %edi
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    

00801dbf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	57                   	push   %edi
  801dc3:	56                   	push   %esi
  801dc4:	53                   	push   %ebx
  801dc5:	83 ec 18             	sub    $0x18,%esp
  801dc8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dcb:	57                   	push   %edi
  801dcc:	e8 92 f0 ff ff       	call   800e63 <fd2data>
  801dd1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dd3:	83 c4 10             	add    $0x10,%esp
  801dd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ddb:	eb 3d                	jmp    801e1a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ddd:	85 db                	test   %ebx,%ebx
  801ddf:	74 04                	je     801de5 <devpipe_read+0x26>
				return i;
  801de1:	89 d8                	mov    %ebx,%eax
  801de3:	eb 44                	jmp    801e29 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801de5:	89 f2                	mov    %esi,%edx
  801de7:	89 f8                	mov    %edi,%eax
  801de9:	e8 e5 fe ff ff       	call   801cd3 <_pipeisclosed>
  801dee:	85 c0                	test   %eax,%eax
  801df0:	75 32                	jne    801e24 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801df2:	e8 4c ee ff ff       	call   800c43 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801df7:	8b 06                	mov    (%esi),%eax
  801df9:	3b 46 04             	cmp    0x4(%esi),%eax
  801dfc:	74 df                	je     801ddd <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dfe:	99                   	cltd   
  801dff:	c1 ea 1b             	shr    $0x1b,%edx
  801e02:	01 d0                	add    %edx,%eax
  801e04:	83 e0 1f             	and    $0x1f,%eax
  801e07:	29 d0                	sub    %edx,%eax
  801e09:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e11:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e14:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e17:	83 c3 01             	add    $0x1,%ebx
  801e1a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e1d:	75 d8                	jne    801df7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e1f:	8b 45 10             	mov    0x10(%ebp),%eax
  801e22:	eb 05                	jmp    801e29 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e24:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e2c:	5b                   	pop    %ebx
  801e2d:	5e                   	pop    %esi
  801e2e:	5f                   	pop    %edi
  801e2f:	5d                   	pop    %ebp
  801e30:	c3                   	ret    

00801e31 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	56                   	push   %esi
  801e35:	53                   	push   %ebx
  801e36:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3c:	50                   	push   %eax
  801e3d:	e8 38 f0 ff ff       	call   800e7a <fd_alloc>
  801e42:	83 c4 10             	add    $0x10,%esp
  801e45:	89 c2                	mov    %eax,%edx
  801e47:	85 c0                	test   %eax,%eax
  801e49:	0f 88 2c 01 00 00    	js     801f7b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e4f:	83 ec 04             	sub    $0x4,%esp
  801e52:	68 07 04 00 00       	push   $0x407
  801e57:	ff 75 f4             	pushl  -0xc(%ebp)
  801e5a:	6a 00                	push   $0x0
  801e5c:	e8 01 ee ff ff       	call   800c62 <sys_page_alloc>
  801e61:	83 c4 10             	add    $0x10,%esp
  801e64:	89 c2                	mov    %eax,%edx
  801e66:	85 c0                	test   %eax,%eax
  801e68:	0f 88 0d 01 00 00    	js     801f7b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e6e:	83 ec 0c             	sub    $0xc,%esp
  801e71:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e74:	50                   	push   %eax
  801e75:	e8 00 f0 ff ff       	call   800e7a <fd_alloc>
  801e7a:	89 c3                	mov    %eax,%ebx
  801e7c:	83 c4 10             	add    $0x10,%esp
  801e7f:	85 c0                	test   %eax,%eax
  801e81:	0f 88 e2 00 00 00    	js     801f69 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e87:	83 ec 04             	sub    $0x4,%esp
  801e8a:	68 07 04 00 00       	push   $0x407
  801e8f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e92:	6a 00                	push   $0x0
  801e94:	e8 c9 ed ff ff       	call   800c62 <sys_page_alloc>
  801e99:	89 c3                	mov    %eax,%ebx
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	0f 88 c3 00 00 00    	js     801f69 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ea6:	83 ec 0c             	sub    $0xc,%esp
  801ea9:	ff 75 f4             	pushl  -0xc(%ebp)
  801eac:	e8 b2 ef ff ff       	call   800e63 <fd2data>
  801eb1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eb3:	83 c4 0c             	add    $0xc,%esp
  801eb6:	68 07 04 00 00       	push   $0x407
  801ebb:	50                   	push   %eax
  801ebc:	6a 00                	push   $0x0
  801ebe:	e8 9f ed ff ff       	call   800c62 <sys_page_alloc>
  801ec3:	89 c3                	mov    %eax,%ebx
  801ec5:	83 c4 10             	add    $0x10,%esp
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	0f 88 89 00 00 00    	js     801f59 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ed0:	83 ec 0c             	sub    $0xc,%esp
  801ed3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ed6:	e8 88 ef ff ff       	call   800e63 <fd2data>
  801edb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ee2:	50                   	push   %eax
  801ee3:	6a 00                	push   $0x0
  801ee5:	56                   	push   %esi
  801ee6:	6a 00                	push   $0x0
  801ee8:	e8 b8 ed ff ff       	call   800ca5 <sys_page_map>
  801eed:	89 c3                	mov    %eax,%ebx
  801eef:	83 c4 20             	add    $0x20,%esp
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	78 55                	js     801f4b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ef6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eff:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f04:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f0b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f14:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f19:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f20:	83 ec 0c             	sub    $0xc,%esp
  801f23:	ff 75 f4             	pushl  -0xc(%ebp)
  801f26:	e8 28 ef ff ff       	call   800e53 <fd2num>
  801f2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f2e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f30:	83 c4 04             	add    $0x4,%esp
  801f33:	ff 75 f0             	pushl  -0x10(%ebp)
  801f36:	e8 18 ef ff ff       	call   800e53 <fd2num>
  801f3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f3e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f41:	83 c4 10             	add    $0x10,%esp
  801f44:	ba 00 00 00 00       	mov    $0x0,%edx
  801f49:	eb 30                	jmp    801f7b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f4b:	83 ec 08             	sub    $0x8,%esp
  801f4e:	56                   	push   %esi
  801f4f:	6a 00                	push   $0x0
  801f51:	e8 91 ed ff ff       	call   800ce7 <sys_page_unmap>
  801f56:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f59:	83 ec 08             	sub    $0x8,%esp
  801f5c:	ff 75 f0             	pushl  -0x10(%ebp)
  801f5f:	6a 00                	push   $0x0
  801f61:	e8 81 ed ff ff       	call   800ce7 <sys_page_unmap>
  801f66:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f69:	83 ec 08             	sub    $0x8,%esp
  801f6c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f6f:	6a 00                	push   $0x0
  801f71:	e8 71 ed ff ff       	call   800ce7 <sys_page_unmap>
  801f76:	83 c4 10             	add    $0x10,%esp
  801f79:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f7b:	89 d0                	mov    %edx,%eax
  801f7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f80:	5b                   	pop    %ebx
  801f81:	5e                   	pop    %esi
  801f82:	5d                   	pop    %ebp
  801f83:	c3                   	ret    

00801f84 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f8d:	50                   	push   %eax
  801f8e:	ff 75 08             	pushl  0x8(%ebp)
  801f91:	e8 33 ef ff ff       	call   800ec9 <fd_lookup>
  801f96:	83 c4 10             	add    $0x10,%esp
  801f99:	85 c0                	test   %eax,%eax
  801f9b:	78 18                	js     801fb5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f9d:	83 ec 0c             	sub    $0xc,%esp
  801fa0:	ff 75 f4             	pushl  -0xc(%ebp)
  801fa3:	e8 bb ee ff ff       	call   800e63 <fd2data>
	return _pipeisclosed(fd, p);
  801fa8:	89 c2                	mov    %eax,%edx
  801faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fad:	e8 21 fd ff ff       	call   801cd3 <_pipeisclosed>
  801fb2:	83 c4 10             	add    $0x10,%esp
}
  801fb5:	c9                   	leave  
  801fb6:	c3                   	ret    

00801fb7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fba:	b8 00 00 00 00       	mov    $0x0,%eax
  801fbf:	5d                   	pop    %ebp
  801fc0:	c3                   	ret    

00801fc1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fc1:	55                   	push   %ebp
  801fc2:	89 e5                	mov    %esp,%ebp
  801fc4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fc7:	68 65 2a 80 00       	push   $0x802a65
  801fcc:	ff 75 0c             	pushl  0xc(%ebp)
  801fcf:	e8 14 e8 ff ff       	call   8007e8 <strcpy>
	return 0;
}
  801fd4:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd9:	c9                   	leave  
  801fda:	c3                   	ret    

00801fdb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	57                   	push   %edi
  801fdf:	56                   	push   %esi
  801fe0:	53                   	push   %ebx
  801fe1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fe7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fec:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ff2:	eb 2d                	jmp    802021 <devcons_write+0x46>
		m = n - tot;
  801ff4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ff7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ff9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ffc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802001:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802004:	83 ec 04             	sub    $0x4,%esp
  802007:	53                   	push   %ebx
  802008:	03 45 0c             	add    0xc(%ebp),%eax
  80200b:	50                   	push   %eax
  80200c:	57                   	push   %edi
  80200d:	e8 68 e9 ff ff       	call   80097a <memmove>
		sys_cputs(buf, m);
  802012:	83 c4 08             	add    $0x8,%esp
  802015:	53                   	push   %ebx
  802016:	57                   	push   %edi
  802017:	e8 8a eb ff ff       	call   800ba6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80201c:	01 de                	add    %ebx,%esi
  80201e:	83 c4 10             	add    $0x10,%esp
  802021:	89 f0                	mov    %esi,%eax
  802023:	3b 75 10             	cmp    0x10(%ebp),%esi
  802026:	72 cc                	jb     801ff4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802028:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202b:	5b                   	pop    %ebx
  80202c:	5e                   	pop    %esi
  80202d:	5f                   	pop    %edi
  80202e:	5d                   	pop    %ebp
  80202f:	c3                   	ret    

00802030 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	83 ec 08             	sub    $0x8,%esp
  802036:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80203b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80203f:	74 2a                	je     80206b <devcons_read+0x3b>
  802041:	eb 05                	jmp    802048 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802043:	e8 fb eb ff ff       	call   800c43 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802048:	e8 77 eb ff ff       	call   800bc4 <sys_cgetc>
  80204d:	85 c0                	test   %eax,%eax
  80204f:	74 f2                	je     802043 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802051:	85 c0                	test   %eax,%eax
  802053:	78 16                	js     80206b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802055:	83 f8 04             	cmp    $0x4,%eax
  802058:	74 0c                	je     802066 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80205a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80205d:	88 02                	mov    %al,(%edx)
	return 1;
  80205f:	b8 01 00 00 00       	mov    $0x1,%eax
  802064:	eb 05                	jmp    80206b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802066:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80206b:	c9                   	leave  
  80206c:	c3                   	ret    

0080206d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80206d:	55                   	push   %ebp
  80206e:	89 e5                	mov    %esp,%ebp
  802070:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802073:	8b 45 08             	mov    0x8(%ebp),%eax
  802076:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802079:	6a 01                	push   $0x1
  80207b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80207e:	50                   	push   %eax
  80207f:	e8 22 eb ff ff       	call   800ba6 <sys_cputs>
}
  802084:	83 c4 10             	add    $0x10,%esp
  802087:	c9                   	leave  
  802088:	c3                   	ret    

00802089 <getchar>:

int
getchar(void)
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80208f:	6a 01                	push   $0x1
  802091:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802094:	50                   	push   %eax
  802095:	6a 00                	push   $0x0
  802097:	e8 93 f0 ff ff       	call   80112f <read>
	if (r < 0)
  80209c:	83 c4 10             	add    $0x10,%esp
  80209f:	85 c0                	test   %eax,%eax
  8020a1:	78 0f                	js     8020b2 <getchar+0x29>
		return r;
	if (r < 1)
  8020a3:	85 c0                	test   %eax,%eax
  8020a5:	7e 06                	jle    8020ad <getchar+0x24>
		return -E_EOF;
	return c;
  8020a7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020ab:	eb 05                	jmp    8020b2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020ad:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020b2:	c9                   	leave  
  8020b3:	c3                   	ret    

008020b4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020b4:	55                   	push   %ebp
  8020b5:	89 e5                	mov    %esp,%ebp
  8020b7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020bd:	50                   	push   %eax
  8020be:	ff 75 08             	pushl  0x8(%ebp)
  8020c1:	e8 03 ee ff ff       	call   800ec9 <fd_lookup>
  8020c6:	83 c4 10             	add    $0x10,%esp
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	78 11                	js     8020de <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020d6:	39 10                	cmp    %edx,(%eax)
  8020d8:	0f 94 c0             	sete   %al
  8020db:	0f b6 c0             	movzbl %al,%eax
}
  8020de:	c9                   	leave  
  8020df:	c3                   	ret    

008020e0 <opencons>:

int
opencons(void)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e9:	50                   	push   %eax
  8020ea:	e8 8b ed ff ff       	call   800e7a <fd_alloc>
  8020ef:	83 c4 10             	add    $0x10,%esp
		return r;
  8020f2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020f4:	85 c0                	test   %eax,%eax
  8020f6:	78 3e                	js     802136 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020f8:	83 ec 04             	sub    $0x4,%esp
  8020fb:	68 07 04 00 00       	push   $0x407
  802100:	ff 75 f4             	pushl  -0xc(%ebp)
  802103:	6a 00                	push   $0x0
  802105:	e8 58 eb ff ff       	call   800c62 <sys_page_alloc>
  80210a:	83 c4 10             	add    $0x10,%esp
		return r;
  80210d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80210f:	85 c0                	test   %eax,%eax
  802111:	78 23                	js     802136 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802113:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802119:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80211e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802121:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802128:	83 ec 0c             	sub    $0xc,%esp
  80212b:	50                   	push   %eax
  80212c:	e8 22 ed ff ff       	call   800e53 <fd2num>
  802131:	89 c2                	mov    %eax,%edx
  802133:	83 c4 10             	add    $0x10,%esp
}
  802136:	89 d0                	mov    %edx,%eax
  802138:	c9                   	leave  
  802139:	c3                   	ret    

0080213a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80213a:	55                   	push   %ebp
  80213b:	89 e5                	mov    %esp,%ebp
  80213d:	56                   	push   %esi
  80213e:	53                   	push   %ebx
  80213f:	8b 75 08             	mov    0x8(%ebp),%esi
  802142:	8b 45 0c             	mov    0xc(%ebp),%eax
  802145:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  802148:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80214a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80214f:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  802152:	83 ec 0c             	sub    $0xc,%esp
  802155:	50                   	push   %eax
  802156:	e8 b7 ec ff ff       	call   800e12 <sys_ipc_recv>
  80215b:	83 c4 10             	add    $0x10,%esp
  80215e:	85 c0                	test   %eax,%eax
  802160:	79 16                	jns    802178 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  802162:	85 f6                	test   %esi,%esi
  802164:	74 06                	je     80216c <ipc_recv+0x32>
			*from_env_store = 0;
  802166:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  80216c:	85 db                	test   %ebx,%ebx
  80216e:	74 2c                	je     80219c <ipc_recv+0x62>
			*perm_store = 0;
  802170:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802176:	eb 24                	jmp    80219c <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  802178:	85 f6                	test   %esi,%esi
  80217a:	74 0a                	je     802186 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  80217c:	a1 08 40 80 00       	mov    0x804008,%eax
  802181:	8b 40 74             	mov    0x74(%eax),%eax
  802184:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  802186:	85 db                	test   %ebx,%ebx
  802188:	74 0a                	je     802194 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  80218a:	a1 08 40 80 00       	mov    0x804008,%eax
  80218f:	8b 40 78             	mov    0x78(%eax),%eax
  802192:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  802194:	a1 08 40 80 00       	mov    0x804008,%eax
  802199:	8b 40 70             	mov    0x70(%eax),%eax
}
  80219c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80219f:	5b                   	pop    %ebx
  8021a0:	5e                   	pop    %esi
  8021a1:	5d                   	pop    %ebp
  8021a2:	c3                   	ret    

008021a3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021a3:	55                   	push   %ebp
  8021a4:	89 e5                	mov    %esp,%ebp
  8021a6:	57                   	push   %edi
  8021a7:	56                   	push   %esi
  8021a8:	53                   	push   %ebx
  8021a9:	83 ec 0c             	sub    $0xc,%esp
  8021ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8021b5:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8021b7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8021bc:	0f 44 d8             	cmove  %eax,%ebx
  8021bf:	eb 1e                	jmp    8021df <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  8021c1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021c4:	74 14                	je     8021da <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  8021c6:	83 ec 04             	sub    $0x4,%esp
  8021c9:	68 74 2a 80 00       	push   $0x802a74
  8021ce:	6a 44                	push   $0x44
  8021d0:	68 a0 2a 80 00       	push   $0x802aa0
  8021d5:	e8 01 df ff ff       	call   8000db <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  8021da:	e8 64 ea ff ff       	call   800c43 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8021df:	ff 75 14             	pushl  0x14(%ebp)
  8021e2:	53                   	push   %ebx
  8021e3:	56                   	push   %esi
  8021e4:	57                   	push   %edi
  8021e5:	e8 05 ec ff ff       	call   800def <sys_ipc_try_send>
  8021ea:	83 c4 10             	add    $0x10,%esp
  8021ed:	85 c0                	test   %eax,%eax
  8021ef:	78 d0                	js     8021c1 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  8021f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021f4:	5b                   	pop    %ebx
  8021f5:	5e                   	pop    %esi
  8021f6:	5f                   	pop    %edi
  8021f7:	5d                   	pop    %ebp
  8021f8:	c3                   	ret    

008021f9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021f9:	55                   	push   %ebp
  8021fa:	89 e5                	mov    %esp,%ebp
  8021fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021ff:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802204:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802207:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80220d:	8b 52 50             	mov    0x50(%edx),%edx
  802210:	39 ca                	cmp    %ecx,%edx
  802212:	75 0d                	jne    802221 <ipc_find_env+0x28>
			return envs[i].env_id;
  802214:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802217:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80221c:	8b 40 48             	mov    0x48(%eax),%eax
  80221f:	eb 0f                	jmp    802230 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802221:	83 c0 01             	add    $0x1,%eax
  802224:	3d 00 04 00 00       	cmp    $0x400,%eax
  802229:	75 d9                	jne    802204 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80222b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802230:	5d                   	pop    %ebp
  802231:	c3                   	ret    

00802232 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802232:	55                   	push   %ebp
  802233:	89 e5                	mov    %esp,%ebp
  802235:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802238:	89 d0                	mov    %edx,%eax
  80223a:	c1 e8 16             	shr    $0x16,%eax
  80223d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802244:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802249:	f6 c1 01             	test   $0x1,%cl
  80224c:	74 1d                	je     80226b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80224e:	c1 ea 0c             	shr    $0xc,%edx
  802251:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802258:	f6 c2 01             	test   $0x1,%dl
  80225b:	74 0e                	je     80226b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80225d:	c1 ea 0c             	shr    $0xc,%edx
  802260:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802267:	ef 
  802268:	0f b7 c0             	movzwl %ax,%eax
}
  80226b:	5d                   	pop    %ebp
  80226c:	c3                   	ret    
  80226d:	66 90                	xchg   %ax,%ax
  80226f:	90                   	nop

00802270 <__udivdi3>:
  802270:	55                   	push   %ebp
  802271:	57                   	push   %edi
  802272:	56                   	push   %esi
  802273:	53                   	push   %ebx
  802274:	83 ec 1c             	sub    $0x1c,%esp
  802277:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80227b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80227f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802283:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802287:	85 f6                	test   %esi,%esi
  802289:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80228d:	89 ca                	mov    %ecx,%edx
  80228f:	89 f8                	mov    %edi,%eax
  802291:	75 3d                	jne    8022d0 <__udivdi3+0x60>
  802293:	39 cf                	cmp    %ecx,%edi
  802295:	0f 87 c5 00 00 00    	ja     802360 <__udivdi3+0xf0>
  80229b:	85 ff                	test   %edi,%edi
  80229d:	89 fd                	mov    %edi,%ebp
  80229f:	75 0b                	jne    8022ac <__udivdi3+0x3c>
  8022a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022a6:	31 d2                	xor    %edx,%edx
  8022a8:	f7 f7                	div    %edi
  8022aa:	89 c5                	mov    %eax,%ebp
  8022ac:	89 c8                	mov    %ecx,%eax
  8022ae:	31 d2                	xor    %edx,%edx
  8022b0:	f7 f5                	div    %ebp
  8022b2:	89 c1                	mov    %eax,%ecx
  8022b4:	89 d8                	mov    %ebx,%eax
  8022b6:	89 cf                	mov    %ecx,%edi
  8022b8:	f7 f5                	div    %ebp
  8022ba:	89 c3                	mov    %eax,%ebx
  8022bc:	89 d8                	mov    %ebx,%eax
  8022be:	89 fa                	mov    %edi,%edx
  8022c0:	83 c4 1c             	add    $0x1c,%esp
  8022c3:	5b                   	pop    %ebx
  8022c4:	5e                   	pop    %esi
  8022c5:	5f                   	pop    %edi
  8022c6:	5d                   	pop    %ebp
  8022c7:	c3                   	ret    
  8022c8:	90                   	nop
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	39 ce                	cmp    %ecx,%esi
  8022d2:	77 74                	ja     802348 <__udivdi3+0xd8>
  8022d4:	0f bd fe             	bsr    %esi,%edi
  8022d7:	83 f7 1f             	xor    $0x1f,%edi
  8022da:	0f 84 98 00 00 00    	je     802378 <__udivdi3+0x108>
  8022e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022e5:	89 f9                	mov    %edi,%ecx
  8022e7:	89 c5                	mov    %eax,%ebp
  8022e9:	29 fb                	sub    %edi,%ebx
  8022eb:	d3 e6                	shl    %cl,%esi
  8022ed:	89 d9                	mov    %ebx,%ecx
  8022ef:	d3 ed                	shr    %cl,%ebp
  8022f1:	89 f9                	mov    %edi,%ecx
  8022f3:	d3 e0                	shl    %cl,%eax
  8022f5:	09 ee                	or     %ebp,%esi
  8022f7:	89 d9                	mov    %ebx,%ecx
  8022f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022fd:	89 d5                	mov    %edx,%ebp
  8022ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802303:	d3 ed                	shr    %cl,%ebp
  802305:	89 f9                	mov    %edi,%ecx
  802307:	d3 e2                	shl    %cl,%edx
  802309:	89 d9                	mov    %ebx,%ecx
  80230b:	d3 e8                	shr    %cl,%eax
  80230d:	09 c2                	or     %eax,%edx
  80230f:	89 d0                	mov    %edx,%eax
  802311:	89 ea                	mov    %ebp,%edx
  802313:	f7 f6                	div    %esi
  802315:	89 d5                	mov    %edx,%ebp
  802317:	89 c3                	mov    %eax,%ebx
  802319:	f7 64 24 0c          	mull   0xc(%esp)
  80231d:	39 d5                	cmp    %edx,%ebp
  80231f:	72 10                	jb     802331 <__udivdi3+0xc1>
  802321:	8b 74 24 08          	mov    0x8(%esp),%esi
  802325:	89 f9                	mov    %edi,%ecx
  802327:	d3 e6                	shl    %cl,%esi
  802329:	39 c6                	cmp    %eax,%esi
  80232b:	73 07                	jae    802334 <__udivdi3+0xc4>
  80232d:	39 d5                	cmp    %edx,%ebp
  80232f:	75 03                	jne    802334 <__udivdi3+0xc4>
  802331:	83 eb 01             	sub    $0x1,%ebx
  802334:	31 ff                	xor    %edi,%edi
  802336:	89 d8                	mov    %ebx,%eax
  802338:	89 fa                	mov    %edi,%edx
  80233a:	83 c4 1c             	add    $0x1c,%esp
  80233d:	5b                   	pop    %ebx
  80233e:	5e                   	pop    %esi
  80233f:	5f                   	pop    %edi
  802340:	5d                   	pop    %ebp
  802341:	c3                   	ret    
  802342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802348:	31 ff                	xor    %edi,%edi
  80234a:	31 db                	xor    %ebx,%ebx
  80234c:	89 d8                	mov    %ebx,%eax
  80234e:	89 fa                	mov    %edi,%edx
  802350:	83 c4 1c             	add    $0x1c,%esp
  802353:	5b                   	pop    %ebx
  802354:	5e                   	pop    %esi
  802355:	5f                   	pop    %edi
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    
  802358:	90                   	nop
  802359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802360:	89 d8                	mov    %ebx,%eax
  802362:	f7 f7                	div    %edi
  802364:	31 ff                	xor    %edi,%edi
  802366:	89 c3                	mov    %eax,%ebx
  802368:	89 d8                	mov    %ebx,%eax
  80236a:	89 fa                	mov    %edi,%edx
  80236c:	83 c4 1c             	add    $0x1c,%esp
  80236f:	5b                   	pop    %ebx
  802370:	5e                   	pop    %esi
  802371:	5f                   	pop    %edi
  802372:	5d                   	pop    %ebp
  802373:	c3                   	ret    
  802374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802378:	39 ce                	cmp    %ecx,%esi
  80237a:	72 0c                	jb     802388 <__udivdi3+0x118>
  80237c:	31 db                	xor    %ebx,%ebx
  80237e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802382:	0f 87 34 ff ff ff    	ja     8022bc <__udivdi3+0x4c>
  802388:	bb 01 00 00 00       	mov    $0x1,%ebx
  80238d:	e9 2a ff ff ff       	jmp    8022bc <__udivdi3+0x4c>
  802392:	66 90                	xchg   %ax,%ax
  802394:	66 90                	xchg   %ax,%ax
  802396:	66 90                	xchg   %ax,%ax
  802398:	66 90                	xchg   %ax,%ax
  80239a:	66 90                	xchg   %ax,%ax
  80239c:	66 90                	xchg   %ax,%ax
  80239e:	66 90                	xchg   %ax,%ax

008023a0 <__umoddi3>:
  8023a0:	55                   	push   %ebp
  8023a1:	57                   	push   %edi
  8023a2:	56                   	push   %esi
  8023a3:	53                   	push   %ebx
  8023a4:	83 ec 1c             	sub    $0x1c,%esp
  8023a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8023ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8023af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023b7:	85 d2                	test   %edx,%edx
  8023b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023c1:	89 f3                	mov    %esi,%ebx
  8023c3:	89 3c 24             	mov    %edi,(%esp)
  8023c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023ca:	75 1c                	jne    8023e8 <__umoddi3+0x48>
  8023cc:	39 f7                	cmp    %esi,%edi
  8023ce:	76 50                	jbe    802420 <__umoddi3+0x80>
  8023d0:	89 c8                	mov    %ecx,%eax
  8023d2:	89 f2                	mov    %esi,%edx
  8023d4:	f7 f7                	div    %edi
  8023d6:	89 d0                	mov    %edx,%eax
  8023d8:	31 d2                	xor    %edx,%edx
  8023da:	83 c4 1c             	add    $0x1c,%esp
  8023dd:	5b                   	pop    %ebx
  8023de:	5e                   	pop    %esi
  8023df:	5f                   	pop    %edi
  8023e0:	5d                   	pop    %ebp
  8023e1:	c3                   	ret    
  8023e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023e8:	39 f2                	cmp    %esi,%edx
  8023ea:	89 d0                	mov    %edx,%eax
  8023ec:	77 52                	ja     802440 <__umoddi3+0xa0>
  8023ee:	0f bd ea             	bsr    %edx,%ebp
  8023f1:	83 f5 1f             	xor    $0x1f,%ebp
  8023f4:	75 5a                	jne    802450 <__umoddi3+0xb0>
  8023f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023fa:	0f 82 e0 00 00 00    	jb     8024e0 <__umoddi3+0x140>
  802400:	39 0c 24             	cmp    %ecx,(%esp)
  802403:	0f 86 d7 00 00 00    	jbe    8024e0 <__umoddi3+0x140>
  802409:	8b 44 24 08          	mov    0x8(%esp),%eax
  80240d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802411:	83 c4 1c             	add    $0x1c,%esp
  802414:	5b                   	pop    %ebx
  802415:	5e                   	pop    %esi
  802416:	5f                   	pop    %edi
  802417:	5d                   	pop    %ebp
  802418:	c3                   	ret    
  802419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802420:	85 ff                	test   %edi,%edi
  802422:	89 fd                	mov    %edi,%ebp
  802424:	75 0b                	jne    802431 <__umoddi3+0x91>
  802426:	b8 01 00 00 00       	mov    $0x1,%eax
  80242b:	31 d2                	xor    %edx,%edx
  80242d:	f7 f7                	div    %edi
  80242f:	89 c5                	mov    %eax,%ebp
  802431:	89 f0                	mov    %esi,%eax
  802433:	31 d2                	xor    %edx,%edx
  802435:	f7 f5                	div    %ebp
  802437:	89 c8                	mov    %ecx,%eax
  802439:	f7 f5                	div    %ebp
  80243b:	89 d0                	mov    %edx,%eax
  80243d:	eb 99                	jmp    8023d8 <__umoddi3+0x38>
  80243f:	90                   	nop
  802440:	89 c8                	mov    %ecx,%eax
  802442:	89 f2                	mov    %esi,%edx
  802444:	83 c4 1c             	add    $0x1c,%esp
  802447:	5b                   	pop    %ebx
  802448:	5e                   	pop    %esi
  802449:	5f                   	pop    %edi
  80244a:	5d                   	pop    %ebp
  80244b:	c3                   	ret    
  80244c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802450:	8b 34 24             	mov    (%esp),%esi
  802453:	bf 20 00 00 00       	mov    $0x20,%edi
  802458:	89 e9                	mov    %ebp,%ecx
  80245a:	29 ef                	sub    %ebp,%edi
  80245c:	d3 e0                	shl    %cl,%eax
  80245e:	89 f9                	mov    %edi,%ecx
  802460:	89 f2                	mov    %esi,%edx
  802462:	d3 ea                	shr    %cl,%edx
  802464:	89 e9                	mov    %ebp,%ecx
  802466:	09 c2                	or     %eax,%edx
  802468:	89 d8                	mov    %ebx,%eax
  80246a:	89 14 24             	mov    %edx,(%esp)
  80246d:	89 f2                	mov    %esi,%edx
  80246f:	d3 e2                	shl    %cl,%edx
  802471:	89 f9                	mov    %edi,%ecx
  802473:	89 54 24 04          	mov    %edx,0x4(%esp)
  802477:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80247b:	d3 e8                	shr    %cl,%eax
  80247d:	89 e9                	mov    %ebp,%ecx
  80247f:	89 c6                	mov    %eax,%esi
  802481:	d3 e3                	shl    %cl,%ebx
  802483:	89 f9                	mov    %edi,%ecx
  802485:	89 d0                	mov    %edx,%eax
  802487:	d3 e8                	shr    %cl,%eax
  802489:	89 e9                	mov    %ebp,%ecx
  80248b:	09 d8                	or     %ebx,%eax
  80248d:	89 d3                	mov    %edx,%ebx
  80248f:	89 f2                	mov    %esi,%edx
  802491:	f7 34 24             	divl   (%esp)
  802494:	89 d6                	mov    %edx,%esi
  802496:	d3 e3                	shl    %cl,%ebx
  802498:	f7 64 24 04          	mull   0x4(%esp)
  80249c:	39 d6                	cmp    %edx,%esi
  80249e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024a2:	89 d1                	mov    %edx,%ecx
  8024a4:	89 c3                	mov    %eax,%ebx
  8024a6:	72 08                	jb     8024b0 <__umoddi3+0x110>
  8024a8:	75 11                	jne    8024bb <__umoddi3+0x11b>
  8024aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8024ae:	73 0b                	jae    8024bb <__umoddi3+0x11b>
  8024b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8024b4:	1b 14 24             	sbb    (%esp),%edx
  8024b7:	89 d1                	mov    %edx,%ecx
  8024b9:	89 c3                	mov    %eax,%ebx
  8024bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024bf:	29 da                	sub    %ebx,%edx
  8024c1:	19 ce                	sbb    %ecx,%esi
  8024c3:	89 f9                	mov    %edi,%ecx
  8024c5:	89 f0                	mov    %esi,%eax
  8024c7:	d3 e0                	shl    %cl,%eax
  8024c9:	89 e9                	mov    %ebp,%ecx
  8024cb:	d3 ea                	shr    %cl,%edx
  8024cd:	89 e9                	mov    %ebp,%ecx
  8024cf:	d3 ee                	shr    %cl,%esi
  8024d1:	09 d0                	or     %edx,%eax
  8024d3:	89 f2                	mov    %esi,%edx
  8024d5:	83 c4 1c             	add    $0x1c,%esp
  8024d8:	5b                   	pop    %ebx
  8024d9:	5e                   	pop    %esi
  8024da:	5f                   	pop    %edi
  8024db:	5d                   	pop    %ebp
  8024dc:	c3                   	ret    
  8024dd:	8d 76 00             	lea    0x0(%esi),%esi
  8024e0:	29 f9                	sub    %edi,%ecx
  8024e2:	19 d6                	sbb    %edx,%esi
  8024e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024ec:	e9 18 ff ff ff       	jmp    802409 <__umoddi3+0x69>
