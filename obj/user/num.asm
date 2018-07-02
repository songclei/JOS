
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 54 01 00 00       	call   800185 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	eb 6e                	jmp    8000b1 <num+0x7e>
		if (bol) {
  800043:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004a:	74 28                	je     800074 <num+0x41>
			printf("%5d ", ++line);
  80004c:	a1 00 40 80 00       	mov    0x804000,%eax
  800051:	83 c0 01             	add    $0x1,%eax
  800054:	a3 00 40 80 00       	mov    %eax,0x804000
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	50                   	push   %eax
  80005d:	68 80 21 80 00       	push   $0x802180
  800062:	e8 43 18 00 00       	call   8018aa <printf>
			bol = 0;
  800067:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  80006e:	00 00 00 
  800071:	83 c4 10             	add    $0x10,%esp
		}
		if ((r = write(1, &c, 1)) != 1)
  800074:	83 ec 04             	sub    $0x4,%esp
  800077:	6a 01                	push   $0x1
  800079:	53                   	push   %ebx
  80007a:	6a 01                	push   $0x1
  80007c:	e8 92 12 00 00       	call   801313 <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 85 21 80 00       	push   $0x802185
  800095:	6a 13                	push   $0x13
  800097:	68 a0 21 80 00       	push   $0x8021a0
  80009c:	e8 44 01 00 00       	call   8001e5 <_panic>
		if (c == '\n')
  8000a1:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  8000a5:	75 0a                	jne    8000b1 <num+0x7e>
			bol = 1;
  8000a7:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000ae:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000b1:	83 ec 04             	sub    $0x4,%esp
  8000b4:	6a 01                	push   $0x1
  8000b6:	53                   	push   %ebx
  8000b7:	56                   	push   %esi
  8000b8:	e8 7c 11 00 00       	call   801239 <read>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	0f 8f 7b ff ff ff    	jg     800043 <num+0x10>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	79 18                	jns    8000e4 <num+0xb1>
		panic("error reading %s: %e", s, n);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	50                   	push   %eax
  8000d0:	ff 75 0c             	pushl  0xc(%ebp)
  8000d3:	68 ab 21 80 00       	push   $0x8021ab
  8000d8:	6a 18                	push   $0x18
  8000da:	68 a0 21 80 00       	push   $0x8021a0
  8000df:	e8 01 01 00 00       	call   8001e5 <_panic>
}
  8000e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 1c             	sub    $0x1c,%esp
	int f, i;

	binaryname = "num";
  8000f4:	c7 05 04 30 80 00 c0 	movl   $0x8021c0,0x803004
  8000fb:	21 80 00 
	if (argc == 1)
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	74 0d                	je     800111 <umain+0x26>
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	8d 58 04             	lea    0x4(%eax),%ebx
  80010a:	bf 01 00 00 00       	mov    $0x1,%edi
  80010f:	eb 62                	jmp    800173 <umain+0x88>
		num(0, "<stdin>");
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 c4 21 80 00       	push   $0x8021c4
  800119:	6a 00                	push   $0x0
  80011b:	e8 13 ff ff ff       	call   800033 <num>
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	eb 53                	jmp    800178 <umain+0x8d>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800125:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 00                	push   $0x0
  80012d:	ff 33                	pushl  (%ebx)
  80012f:	e8 d8 15 00 00       	call   80170c <open>
  800134:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	85 c0                	test   %eax,%eax
  80013b:	79 1a                	jns    800157 <umain+0x6c>
				panic("can't open %s: %e", argv[i], f);
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800144:	ff 30                	pushl  (%eax)
  800146:	68 cc 21 80 00       	push   $0x8021cc
  80014b:	6a 27                	push   $0x27
  80014d:	68 a0 21 80 00       	push   $0x8021a0
  800152:	e8 8e 00 00 00       	call   8001e5 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 93 0f 00 00       	call   8010fd <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80016a:	83 c7 01             	add    $0x1,%edi
  80016d:	83 c3 04             	add    $0x4,%ebx
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	3b 7d 08             	cmp    0x8(%ebp),%edi
  800176:	7c ad                	jl     800125 <umain+0x3a>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  800178:	e8 4e 00 00 00       	call   8001cb <exit>
}
  80017d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80018d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800190:	e8 99 0b 00 00       	call   800d2e <sys_getenvid>
  800195:	25 ff 03 00 00       	and    $0x3ff,%eax
  80019a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80019d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a2:	a3 0c 40 80 00       	mov    %eax,0x80400c
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001a7:	85 db                	test   %ebx,%ebx
  8001a9:	7e 07                	jle    8001b2 <libmain+0x2d>
		binaryname = argv[0];
  8001ab:	8b 06                	mov    (%esi),%eax
  8001ad:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	56                   	push   %esi
  8001b6:	53                   	push   %ebx
  8001b7:	e8 2f ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8001bc:	e8 0a 00 00 00       	call   8001cb <exit>
}
  8001c1:	83 c4 10             	add    $0x10,%esp
  8001c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5d                   	pop    %ebp
  8001ca:	c3                   	ret    

008001cb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001d1:	e8 52 0f 00 00       	call   801128 <close_all>
	sys_env_destroy(0);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	6a 00                	push   $0x0
  8001db:	e8 0d 0b 00 00       	call   800ced <sys_env_destroy>
}
  8001e0:	83 c4 10             	add    $0x10,%esp
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    

008001e5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001ea:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ed:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8001f3:	e8 36 0b 00 00       	call   800d2e <sys_getenvid>
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 0c             	pushl  0xc(%ebp)
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	56                   	push   %esi
  800202:	50                   	push   %eax
  800203:	68 e8 21 80 00       	push   $0x8021e8
  800208:	e8 b1 00 00 00       	call   8002be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020d:	83 c4 18             	add    $0x18,%esp
  800210:	53                   	push   %ebx
  800211:	ff 75 10             	pushl  0x10(%ebp)
  800214:	e8 54 00 00 00       	call   80026d <vcprintf>
	cprintf("\n");
  800219:	c7 04 24 31 26 80 00 	movl   $0x802631,(%esp)
  800220:	e8 99 00 00 00       	call   8002be <cprintf>
  800225:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800228:	cc                   	int3   
  800229:	eb fd                	jmp    800228 <_panic+0x43>

0080022b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	53                   	push   %ebx
  80022f:	83 ec 04             	sub    $0x4,%esp
  800232:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800235:	8b 13                	mov    (%ebx),%edx
  800237:	8d 42 01             	lea    0x1(%edx),%eax
  80023a:	89 03                	mov    %eax,(%ebx)
  80023c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800243:	3d ff 00 00 00       	cmp    $0xff,%eax
  800248:	75 1a                	jne    800264 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	68 ff 00 00 00       	push   $0xff
  800252:	8d 43 08             	lea    0x8(%ebx),%eax
  800255:	50                   	push   %eax
  800256:	e8 55 0a 00 00       	call   800cb0 <sys_cputs>
		b->idx = 0;
  80025b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800261:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800264:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800268:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800276:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027d:	00 00 00 
	b.cnt = 0;
  800280:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800287:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80028a:	ff 75 0c             	pushl  0xc(%ebp)
  80028d:	ff 75 08             	pushl  0x8(%ebp)
  800290:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800296:	50                   	push   %eax
  800297:	68 2b 02 80 00       	push   $0x80022b
  80029c:	e8 54 01 00 00       	call   8003f5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a1:	83 c4 08             	add    $0x8,%esp
  8002a4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b0:	50                   	push   %eax
  8002b1:	e8 fa 09 00 00       	call   800cb0 <sys_cputs>

	return b.cnt;
}
  8002b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c7:	50                   	push   %eax
  8002c8:	ff 75 08             	pushl  0x8(%ebp)
  8002cb:	e8 9d ff ff ff       	call   80026d <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 1c             	sub    $0x1c,%esp
  8002db:	89 c7                	mov    %eax,%edi
  8002dd:	89 d6                	mov    %edx,%esi
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002f6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002f9:	39 d3                	cmp    %edx,%ebx
  8002fb:	72 05                	jb     800302 <printnum+0x30>
  8002fd:	39 45 10             	cmp    %eax,0x10(%ebp)
  800300:	77 45                	ja     800347 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800302:	83 ec 0c             	sub    $0xc,%esp
  800305:	ff 75 18             	pushl  0x18(%ebp)
  800308:	8b 45 14             	mov    0x14(%ebp),%eax
  80030b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80030e:	53                   	push   %ebx
  80030f:	ff 75 10             	pushl  0x10(%ebp)
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	ff 75 e4             	pushl  -0x1c(%ebp)
  800318:	ff 75 e0             	pushl  -0x20(%ebp)
  80031b:	ff 75 dc             	pushl  -0x24(%ebp)
  80031e:	ff 75 d8             	pushl  -0x28(%ebp)
  800321:	e8 ba 1b 00 00       	call   801ee0 <__udivdi3>
  800326:	83 c4 18             	add    $0x18,%esp
  800329:	52                   	push   %edx
  80032a:	50                   	push   %eax
  80032b:	89 f2                	mov    %esi,%edx
  80032d:	89 f8                	mov    %edi,%eax
  80032f:	e8 9e ff ff ff       	call   8002d2 <printnum>
  800334:	83 c4 20             	add    $0x20,%esp
  800337:	eb 18                	jmp    800351 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800339:	83 ec 08             	sub    $0x8,%esp
  80033c:	56                   	push   %esi
  80033d:	ff 75 18             	pushl  0x18(%ebp)
  800340:	ff d7                	call   *%edi
  800342:	83 c4 10             	add    $0x10,%esp
  800345:	eb 03                	jmp    80034a <printnum+0x78>
  800347:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034a:	83 eb 01             	sub    $0x1,%ebx
  80034d:	85 db                	test   %ebx,%ebx
  80034f:	7f e8                	jg     800339 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800351:	83 ec 08             	sub    $0x8,%esp
  800354:	56                   	push   %esi
  800355:	83 ec 04             	sub    $0x4,%esp
  800358:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035b:	ff 75 e0             	pushl  -0x20(%ebp)
  80035e:	ff 75 dc             	pushl  -0x24(%ebp)
  800361:	ff 75 d8             	pushl  -0x28(%ebp)
  800364:	e8 a7 1c 00 00       	call   802010 <__umoddi3>
  800369:	83 c4 14             	add    $0x14,%esp
  80036c:	0f be 80 0b 22 80 00 	movsbl 0x80220b(%eax),%eax
  800373:	50                   	push   %eax
  800374:	ff d7                	call   *%edi
}
  800376:	83 c4 10             	add    $0x10,%esp
  800379:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037c:	5b                   	pop    %ebx
  80037d:	5e                   	pop    %esi
  80037e:	5f                   	pop    %edi
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800384:	83 fa 01             	cmp    $0x1,%edx
  800387:	7e 0e                	jle    800397 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 02                	mov    (%edx),%eax
  800392:	8b 52 04             	mov    0x4(%edx),%edx
  800395:	eb 22                	jmp    8003b9 <getuint+0x38>
	else if (lflag)
  800397:	85 d2                	test   %edx,%edx
  800399:	74 10                	je     8003ab <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80039b:	8b 10                	mov    (%eax),%edx
  80039d:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a0:	89 08                	mov    %ecx,(%eax)
  8003a2:	8b 02                	mov    (%edx),%eax
  8003a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a9:	eb 0e                	jmp    8003b9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ab:	8b 10                	mov    (%eax),%edx
  8003ad:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b0:	89 08                	mov    %ecx,(%eax)
  8003b2:	8b 02                	mov    (%edx),%eax
  8003b4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    

008003bb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c5:	8b 10                	mov    (%eax),%edx
  8003c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ca:	73 0a                	jae    8003d6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003cc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003cf:	89 08                	mov    %ecx,(%eax)
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	88 02                	mov    %al,(%edx)
}
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003de:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e1:	50                   	push   %eax
  8003e2:	ff 75 10             	pushl  0x10(%ebp)
  8003e5:	ff 75 0c             	pushl  0xc(%ebp)
  8003e8:	ff 75 08             	pushl  0x8(%ebp)
  8003eb:	e8 05 00 00 00       	call   8003f5 <vprintfmt>
	va_end(ap);
}
  8003f0:	83 c4 10             	add    $0x10,%esp
  8003f3:	c9                   	leave  
  8003f4:	c3                   	ret    

008003f5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	57                   	push   %edi
  8003f9:	56                   	push   %esi
  8003fa:	53                   	push   %ebx
  8003fb:	83 ec 2c             	sub    $0x2c,%esp
  8003fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800401:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800404:	8b 7d 10             	mov    0x10(%ebp),%edi
  800407:	eb 12                	jmp    80041b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800409:	85 c0                	test   %eax,%eax
  80040b:	0f 84 38 04 00 00    	je     800849 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	53                   	push   %ebx
  800415:	50                   	push   %eax
  800416:	ff d6                	call   *%esi
  800418:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80041b:	83 c7 01             	add    $0x1,%edi
  80041e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800422:	83 f8 25             	cmp    $0x25,%eax
  800425:	75 e2                	jne    800409 <vprintfmt+0x14>
  800427:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80042b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800432:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800439:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800440:	ba 00 00 00 00       	mov    $0x0,%edx
  800445:	eb 07                	jmp    80044e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  80044a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8d 47 01             	lea    0x1(%edi),%eax
  800451:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800454:	0f b6 07             	movzbl (%edi),%eax
  800457:	0f b6 c8             	movzbl %al,%ecx
  80045a:	83 e8 23             	sub    $0x23,%eax
  80045d:	3c 55                	cmp    $0x55,%al
  80045f:	0f 87 c9 03 00 00    	ja     80082e <vprintfmt+0x439>
  800465:	0f b6 c0             	movzbl %al,%eax
  800468:	ff 24 85 40 23 80 00 	jmp    *0x802340(,%eax,4)
  80046f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800472:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800476:	eb d6                	jmp    80044e <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  800478:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80047f:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  800485:	eb 94                	jmp    80041b <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  800487:	c7 05 04 40 80 00 01 	movl   $0x1,0x804004
  80048e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  800494:	eb 85                	jmp    80041b <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  800496:	c7 05 04 40 80 00 02 	movl   $0x2,0x804004
  80049d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  8004a3:	e9 73 ff ff ff       	jmp    80041b <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  8004a8:	c7 05 04 40 80 00 03 	movl   $0x3,0x804004
  8004af:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  8004b5:	e9 61 ff ff ff       	jmp    80041b <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  8004ba:	c7 05 04 40 80 00 04 	movl   $0x4,0x804004
  8004c1:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  8004c7:	e9 4f ff ff ff       	jmp    80041b <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  8004cc:	c7 05 04 40 80 00 05 	movl   $0x5,0x804004
  8004d3:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  8004d9:	e9 3d ff ff ff       	jmp    80041b <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  8004de:	c7 05 04 40 80 00 06 	movl   $0x6,0x804004
  8004e5:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  8004eb:	e9 2b ff ff ff       	jmp    80041b <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  8004f0:	c7 05 04 40 80 00 07 	movl   $0x7,0x804004
  8004f7:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8004fd:	e9 19 ff ff ff       	jmp    80041b <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800502:	c7 05 04 40 80 00 08 	movl   $0x8,0x804004
  800509:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  80050f:	e9 07 ff ff ff       	jmp    80041b <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  800514:	c7 05 04 40 80 00 09 	movl   $0x9,0x804004
  80051b:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800521:	e9 f5 fe ff ff       	jmp    80041b <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800529:	b8 00 00 00 00       	mov    $0x0,%eax
  80052e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800531:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800534:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800538:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80053b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80053e:	83 fa 09             	cmp    $0x9,%edx
  800541:	77 3f                	ja     800582 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800543:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800546:	eb e9                	jmp    800531 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8d 48 04             	lea    0x4(%eax),%ecx
  80054e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800559:	eb 2d                	jmp    800588 <vprintfmt+0x193>
  80055b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80055e:	85 c0                	test   %eax,%eax
  800560:	b9 00 00 00 00       	mov    $0x0,%ecx
  800565:	0f 49 c8             	cmovns %eax,%ecx
  800568:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056e:	e9 db fe ff ff       	jmp    80044e <vprintfmt+0x59>
  800573:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800576:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80057d:	e9 cc fe ff ff       	jmp    80044e <vprintfmt+0x59>
  800582:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800585:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800588:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058c:	0f 89 bc fe ff ff    	jns    80044e <vprintfmt+0x59>
				width = precision, precision = -1;
  800592:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800595:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800598:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059f:	e9 aa fe ff ff       	jmp    80044e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a4:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005aa:	e9 9f fe ff ff       	jmp    80044e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 50 04             	lea    0x4(%eax),%edx
  8005b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	53                   	push   %ebx
  8005bc:	ff 30                	pushl  (%eax)
  8005be:	ff d6                	call   *%esi
			break;
  8005c0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005c6:	e9 50 fe ff ff       	jmp    80041b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 50 04             	lea    0x4(%eax),%edx
  8005d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	99                   	cltd   
  8005d7:	31 d0                	xor    %edx,%eax
  8005d9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005db:	83 f8 0f             	cmp    $0xf,%eax
  8005de:	7f 0b                	jg     8005eb <vprintfmt+0x1f6>
  8005e0:	8b 14 85 a0 24 80 00 	mov    0x8024a0(,%eax,4),%edx
  8005e7:	85 d2                	test   %edx,%edx
  8005e9:	75 18                	jne    800603 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  8005eb:	50                   	push   %eax
  8005ec:	68 23 22 80 00       	push   $0x802223
  8005f1:	53                   	push   %ebx
  8005f2:	56                   	push   %esi
  8005f3:	e8 e0 fd ff ff       	call   8003d8 <printfmt>
  8005f8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005fe:	e9 18 fe ff ff       	jmp    80041b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800603:	52                   	push   %edx
  800604:	68 d1 25 80 00       	push   $0x8025d1
  800609:	53                   	push   %ebx
  80060a:	56                   	push   %esi
  80060b:	e8 c8 fd ff ff       	call   8003d8 <printfmt>
  800610:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800613:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800616:	e9 00 fe ff ff       	jmp    80041b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 50 04             	lea    0x4(%eax),%edx
  800621:	89 55 14             	mov    %edx,0x14(%ebp)
  800624:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800626:	85 ff                	test   %edi,%edi
  800628:	b8 1c 22 80 00       	mov    $0x80221c,%eax
  80062d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800630:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800634:	0f 8e 94 00 00 00    	jle    8006ce <vprintfmt+0x2d9>
  80063a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80063e:	0f 84 98 00 00 00    	je     8006dc <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	ff 75 d0             	pushl  -0x30(%ebp)
  80064a:	57                   	push   %edi
  80064b:	e8 81 02 00 00       	call   8008d1 <strnlen>
  800650:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800653:	29 c1                	sub    %eax,%ecx
  800655:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800658:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80065b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80065f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800662:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800665:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800667:	eb 0f                	jmp    800678 <vprintfmt+0x283>
					putch(padc, putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	53                   	push   %ebx
  80066d:	ff 75 e0             	pushl  -0x20(%ebp)
  800670:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800672:	83 ef 01             	sub    $0x1,%edi
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	85 ff                	test   %edi,%edi
  80067a:	7f ed                	jg     800669 <vprintfmt+0x274>
  80067c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80067f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800682:	85 c9                	test   %ecx,%ecx
  800684:	b8 00 00 00 00       	mov    $0x0,%eax
  800689:	0f 49 c1             	cmovns %ecx,%eax
  80068c:	29 c1                	sub    %eax,%ecx
  80068e:	89 75 08             	mov    %esi,0x8(%ebp)
  800691:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800694:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800697:	89 cb                	mov    %ecx,%ebx
  800699:	eb 4d                	jmp    8006e8 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80069b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80069f:	74 1b                	je     8006bc <vprintfmt+0x2c7>
  8006a1:	0f be c0             	movsbl %al,%eax
  8006a4:	83 e8 20             	sub    $0x20,%eax
  8006a7:	83 f8 5e             	cmp    $0x5e,%eax
  8006aa:	76 10                	jbe    8006bc <vprintfmt+0x2c7>
					putch('?', putdat);
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	ff 75 0c             	pushl  0xc(%ebp)
  8006b2:	6a 3f                	push   $0x3f
  8006b4:	ff 55 08             	call   *0x8(%ebp)
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	eb 0d                	jmp    8006c9 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	ff 75 0c             	pushl  0xc(%ebp)
  8006c2:	52                   	push   %edx
  8006c3:	ff 55 08             	call   *0x8(%ebp)
  8006c6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c9:	83 eb 01             	sub    $0x1,%ebx
  8006cc:	eb 1a                	jmp    8006e8 <vprintfmt+0x2f3>
  8006ce:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006da:	eb 0c                	jmp    8006e8 <vprintfmt+0x2f3>
  8006dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8006df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006e8:	83 c7 01             	add    $0x1,%edi
  8006eb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ef:	0f be d0             	movsbl %al,%edx
  8006f2:	85 d2                	test   %edx,%edx
  8006f4:	74 23                	je     800719 <vprintfmt+0x324>
  8006f6:	85 f6                	test   %esi,%esi
  8006f8:	78 a1                	js     80069b <vprintfmt+0x2a6>
  8006fa:	83 ee 01             	sub    $0x1,%esi
  8006fd:	79 9c                	jns    80069b <vprintfmt+0x2a6>
  8006ff:	89 df                	mov    %ebx,%edi
  800701:	8b 75 08             	mov    0x8(%ebp),%esi
  800704:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800707:	eb 18                	jmp    800721 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	53                   	push   %ebx
  80070d:	6a 20                	push   $0x20
  80070f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800711:	83 ef 01             	sub    $0x1,%edi
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb 08                	jmp    800721 <vprintfmt+0x32c>
  800719:	89 df                	mov    %ebx,%edi
  80071b:	8b 75 08             	mov    0x8(%ebp),%esi
  80071e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800721:	85 ff                	test   %edi,%edi
  800723:	7f e4                	jg     800709 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800725:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800728:	e9 ee fc ff ff       	jmp    80041b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072d:	83 fa 01             	cmp    $0x1,%edx
  800730:	7e 16                	jle    800748 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8d 50 08             	lea    0x8(%eax),%edx
  800738:	89 55 14             	mov    %edx,0x14(%ebp)
  80073b:	8b 50 04             	mov    0x4(%eax),%edx
  80073e:	8b 00                	mov    (%eax),%eax
  800740:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800743:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800746:	eb 32                	jmp    80077a <vprintfmt+0x385>
	else if (lflag)
  800748:	85 d2                	test   %edx,%edx
  80074a:	74 18                	je     800764 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  80074c:	8b 45 14             	mov    0x14(%ebp),%eax
  80074f:	8d 50 04             	lea    0x4(%eax),%edx
  800752:	89 55 14             	mov    %edx,0x14(%ebp)
  800755:	8b 00                	mov    (%eax),%eax
  800757:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80075a:	89 c1                	mov    %eax,%ecx
  80075c:	c1 f9 1f             	sar    $0x1f,%ecx
  80075f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800762:	eb 16                	jmp    80077a <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	8d 50 04             	lea    0x4(%eax),%edx
  80076a:	89 55 14             	mov    %edx,0x14(%ebp)
  80076d:	8b 00                	mov    (%eax),%eax
  80076f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800772:	89 c1                	mov    %eax,%ecx
  800774:	c1 f9 1f             	sar    $0x1f,%ecx
  800777:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80077a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80077d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800780:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800785:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800789:	79 6f                	jns    8007fa <vprintfmt+0x405>
				putch('-', putdat);
  80078b:	83 ec 08             	sub    $0x8,%esp
  80078e:	53                   	push   %ebx
  80078f:	6a 2d                	push   $0x2d
  800791:	ff d6                	call   *%esi
				num = -(long long) num;
  800793:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800796:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800799:	f7 d8                	neg    %eax
  80079b:	83 d2 00             	adc    $0x0,%edx
  80079e:	f7 da                	neg    %edx
  8007a0:	83 c4 10             	add    $0x10,%esp
  8007a3:	eb 55                	jmp    8007fa <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a8:	e8 d4 fb ff ff       	call   800381 <getuint>
			base = 10;
  8007ad:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8007b2:	eb 46                	jmp    8007fa <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b7:	e8 c5 fb ff ff       	call   800381 <getuint>
			base = 8;
  8007bc:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8007c1:	eb 37                	jmp    8007fa <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  8007c3:	83 ec 08             	sub    $0x8,%esp
  8007c6:	53                   	push   %ebx
  8007c7:	6a 30                	push   $0x30
  8007c9:	ff d6                	call   *%esi
			putch('x', putdat);
  8007cb:	83 c4 08             	add    $0x8,%esp
  8007ce:	53                   	push   %ebx
  8007cf:	6a 78                	push   $0x78
  8007d1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8d 50 04             	lea    0x4(%eax),%edx
  8007d9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007dc:	8b 00                	mov    (%eax),%eax
  8007de:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007e3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007e6:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8007eb:	eb 0d                	jmp    8007fa <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f0:	e8 8c fb ff ff       	call   800381 <getuint>
			base = 16;
  8007f5:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007fa:	83 ec 0c             	sub    $0xc,%esp
  8007fd:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800801:	51                   	push   %ecx
  800802:	ff 75 e0             	pushl  -0x20(%ebp)
  800805:	57                   	push   %edi
  800806:	52                   	push   %edx
  800807:	50                   	push   %eax
  800808:	89 da                	mov    %ebx,%edx
  80080a:	89 f0                	mov    %esi,%eax
  80080c:	e8 c1 fa ff ff       	call   8002d2 <printnum>
			break;
  800811:	83 c4 20             	add    $0x20,%esp
  800814:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800817:	e9 ff fb ff ff       	jmp    80041b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80081c:	83 ec 08             	sub    $0x8,%esp
  80081f:	53                   	push   %ebx
  800820:	51                   	push   %ecx
  800821:	ff d6                	call   *%esi
			break;
  800823:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800826:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800829:	e9 ed fb ff ff       	jmp    80041b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80082e:	83 ec 08             	sub    $0x8,%esp
  800831:	53                   	push   %ebx
  800832:	6a 25                	push   $0x25
  800834:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	eb 03                	jmp    80083e <vprintfmt+0x449>
  80083b:	83 ef 01             	sub    $0x1,%edi
  80083e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800842:	75 f7                	jne    80083b <vprintfmt+0x446>
  800844:	e9 d2 fb ff ff       	jmp    80041b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800849:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80084c:	5b                   	pop    %ebx
  80084d:	5e                   	pop    %esi
  80084e:	5f                   	pop    %edi
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	83 ec 18             	sub    $0x18,%esp
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80085d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800860:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800864:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800867:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80086e:	85 c0                	test   %eax,%eax
  800870:	74 26                	je     800898 <vsnprintf+0x47>
  800872:	85 d2                	test   %edx,%edx
  800874:	7e 22                	jle    800898 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800876:	ff 75 14             	pushl  0x14(%ebp)
  800879:	ff 75 10             	pushl  0x10(%ebp)
  80087c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80087f:	50                   	push   %eax
  800880:	68 bb 03 80 00       	push   $0x8003bb
  800885:	e8 6b fb ff ff       	call   8003f5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80088a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80088d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800890:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	eb 05                	jmp    80089d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800898:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80089d:	c9                   	leave  
  80089e:	c3                   	ret    

0080089f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a8:	50                   	push   %eax
  8008a9:	ff 75 10             	pushl  0x10(%ebp)
  8008ac:	ff 75 0c             	pushl  0xc(%ebp)
  8008af:	ff 75 08             	pushl  0x8(%ebp)
  8008b2:	e8 9a ff ff ff       	call   800851 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c4:	eb 03                	jmp    8008c9 <strlen+0x10>
		n++;
  8008c6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008cd:	75 f7                	jne    8008c6 <strlen+0xd>
		n++;
	return n;
}
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008da:	ba 00 00 00 00       	mov    $0x0,%edx
  8008df:	eb 03                	jmp    8008e4 <strnlen+0x13>
		n++;
  8008e1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e4:	39 c2                	cmp    %eax,%edx
  8008e6:	74 08                	je     8008f0 <strnlen+0x1f>
  8008e8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008ec:	75 f3                	jne    8008e1 <strnlen+0x10>
  8008ee:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	53                   	push   %ebx
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008fc:	89 c2                	mov    %eax,%edx
  8008fe:	83 c2 01             	add    $0x1,%edx
  800901:	83 c1 01             	add    $0x1,%ecx
  800904:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800908:	88 5a ff             	mov    %bl,-0x1(%edx)
  80090b:	84 db                	test   %bl,%bl
  80090d:	75 ef                	jne    8008fe <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80090f:	5b                   	pop    %ebx
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	53                   	push   %ebx
  800916:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800919:	53                   	push   %ebx
  80091a:	e8 9a ff ff ff       	call   8008b9 <strlen>
  80091f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800922:	ff 75 0c             	pushl  0xc(%ebp)
  800925:	01 d8                	add    %ebx,%eax
  800927:	50                   	push   %eax
  800928:	e8 c5 ff ff ff       	call   8008f2 <strcpy>
	return dst;
}
  80092d:	89 d8                	mov    %ebx,%eax
  80092f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800932:	c9                   	leave  
  800933:	c3                   	ret    

00800934 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	8b 75 08             	mov    0x8(%ebp),%esi
  80093c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093f:	89 f3                	mov    %esi,%ebx
  800941:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800944:	89 f2                	mov    %esi,%edx
  800946:	eb 0f                	jmp    800957 <strncpy+0x23>
		*dst++ = *src;
  800948:	83 c2 01             	add    $0x1,%edx
  80094b:	0f b6 01             	movzbl (%ecx),%eax
  80094e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800951:	80 39 01             	cmpb   $0x1,(%ecx)
  800954:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800957:	39 da                	cmp    %ebx,%edx
  800959:	75 ed                	jne    800948 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80095b:	89 f0                	mov    %esi,%eax
  80095d:	5b                   	pop    %ebx
  80095e:	5e                   	pop    %esi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	56                   	push   %esi
  800965:	53                   	push   %ebx
  800966:	8b 75 08             	mov    0x8(%ebp),%esi
  800969:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096c:	8b 55 10             	mov    0x10(%ebp),%edx
  80096f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800971:	85 d2                	test   %edx,%edx
  800973:	74 21                	je     800996 <strlcpy+0x35>
  800975:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800979:	89 f2                	mov    %esi,%edx
  80097b:	eb 09                	jmp    800986 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80097d:	83 c2 01             	add    $0x1,%edx
  800980:	83 c1 01             	add    $0x1,%ecx
  800983:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800986:	39 c2                	cmp    %eax,%edx
  800988:	74 09                	je     800993 <strlcpy+0x32>
  80098a:	0f b6 19             	movzbl (%ecx),%ebx
  80098d:	84 db                	test   %bl,%bl
  80098f:	75 ec                	jne    80097d <strlcpy+0x1c>
  800991:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800993:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800996:	29 f0                	sub    %esi,%eax
}
  800998:	5b                   	pop    %ebx
  800999:	5e                   	pop    %esi
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a5:	eb 06                	jmp    8009ad <strcmp+0x11>
		p++, q++;
  8009a7:	83 c1 01             	add    $0x1,%ecx
  8009aa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ad:	0f b6 01             	movzbl (%ecx),%eax
  8009b0:	84 c0                	test   %al,%al
  8009b2:	74 04                	je     8009b8 <strcmp+0x1c>
  8009b4:	3a 02                	cmp    (%edx),%al
  8009b6:	74 ef                	je     8009a7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b8:	0f b6 c0             	movzbl %al,%eax
  8009bb:	0f b6 12             	movzbl (%edx),%edx
  8009be:	29 d0                	sub    %edx,%eax
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	53                   	push   %ebx
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cc:	89 c3                	mov    %eax,%ebx
  8009ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d1:	eb 06                	jmp    8009d9 <strncmp+0x17>
		n--, p++, q++;
  8009d3:	83 c0 01             	add    $0x1,%eax
  8009d6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009d9:	39 d8                	cmp    %ebx,%eax
  8009db:	74 15                	je     8009f2 <strncmp+0x30>
  8009dd:	0f b6 08             	movzbl (%eax),%ecx
  8009e0:	84 c9                	test   %cl,%cl
  8009e2:	74 04                	je     8009e8 <strncmp+0x26>
  8009e4:	3a 0a                	cmp    (%edx),%cl
  8009e6:	74 eb                	je     8009d3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e8:	0f b6 00             	movzbl (%eax),%eax
  8009eb:	0f b6 12             	movzbl (%edx),%edx
  8009ee:	29 d0                	sub    %edx,%eax
  8009f0:	eb 05                	jmp    8009f7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009f7:	5b                   	pop    %ebx
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a04:	eb 07                	jmp    800a0d <strchr+0x13>
		if (*s == c)
  800a06:	38 ca                	cmp    %cl,%dl
  800a08:	74 0f                	je     800a19 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	0f b6 10             	movzbl (%eax),%edx
  800a10:	84 d2                	test   %dl,%dl
  800a12:	75 f2                	jne    800a06 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a25:	eb 03                	jmp    800a2a <strfind+0xf>
  800a27:	83 c0 01             	add    $0x1,%eax
  800a2a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a2d:	38 ca                	cmp    %cl,%dl
  800a2f:	74 04                	je     800a35 <strfind+0x1a>
  800a31:	84 d2                	test   %dl,%dl
  800a33:	75 f2                	jne    800a27 <strfind+0xc>
			break;
	return (char *) s;
}
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	57                   	push   %edi
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
  800a3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a43:	85 c9                	test   %ecx,%ecx
  800a45:	74 36                	je     800a7d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a47:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a4d:	75 28                	jne    800a77 <memset+0x40>
  800a4f:	f6 c1 03             	test   $0x3,%cl
  800a52:	75 23                	jne    800a77 <memset+0x40>
		c &= 0xFF;
  800a54:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a58:	89 d3                	mov    %edx,%ebx
  800a5a:	c1 e3 08             	shl    $0x8,%ebx
  800a5d:	89 d6                	mov    %edx,%esi
  800a5f:	c1 e6 18             	shl    $0x18,%esi
  800a62:	89 d0                	mov    %edx,%eax
  800a64:	c1 e0 10             	shl    $0x10,%eax
  800a67:	09 f0                	or     %esi,%eax
  800a69:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a6b:	89 d8                	mov    %ebx,%eax
  800a6d:	09 d0                	or     %edx,%eax
  800a6f:	c1 e9 02             	shr    $0x2,%ecx
  800a72:	fc                   	cld    
  800a73:	f3 ab                	rep stos %eax,%es:(%edi)
  800a75:	eb 06                	jmp    800a7d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7a:	fc                   	cld    
  800a7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a7d:	89 f8                	mov    %edi,%eax
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5f                   	pop    %edi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a92:	39 c6                	cmp    %eax,%esi
  800a94:	73 35                	jae    800acb <memmove+0x47>
  800a96:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a99:	39 d0                	cmp    %edx,%eax
  800a9b:	73 2e                	jae    800acb <memmove+0x47>
		s += n;
		d += n;
  800a9d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa0:	89 d6                	mov    %edx,%esi
  800aa2:	09 fe                	or     %edi,%esi
  800aa4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aaa:	75 13                	jne    800abf <memmove+0x3b>
  800aac:	f6 c1 03             	test   $0x3,%cl
  800aaf:	75 0e                	jne    800abf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ab1:	83 ef 04             	sub    $0x4,%edi
  800ab4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab7:	c1 e9 02             	shr    $0x2,%ecx
  800aba:	fd                   	std    
  800abb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abd:	eb 09                	jmp    800ac8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800abf:	83 ef 01             	sub    $0x1,%edi
  800ac2:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ac5:	fd                   	std    
  800ac6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac8:	fc                   	cld    
  800ac9:	eb 1d                	jmp    800ae8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acb:	89 f2                	mov    %esi,%edx
  800acd:	09 c2                	or     %eax,%edx
  800acf:	f6 c2 03             	test   $0x3,%dl
  800ad2:	75 0f                	jne    800ae3 <memmove+0x5f>
  800ad4:	f6 c1 03             	test   $0x3,%cl
  800ad7:	75 0a                	jne    800ae3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ad9:	c1 e9 02             	shr    $0x2,%ecx
  800adc:	89 c7                	mov    %eax,%edi
  800ade:	fc                   	cld    
  800adf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae1:	eb 05                	jmp    800ae8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae3:	89 c7                	mov    %eax,%edi
  800ae5:	fc                   	cld    
  800ae6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ae8:	5e                   	pop    %esi
  800ae9:	5f                   	pop    %edi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aef:	ff 75 10             	pushl  0x10(%ebp)
  800af2:	ff 75 0c             	pushl  0xc(%ebp)
  800af5:	ff 75 08             	pushl  0x8(%ebp)
  800af8:	e8 87 ff ff ff       	call   800a84 <memmove>
}
  800afd:	c9                   	leave  
  800afe:	c3                   	ret    

00800aff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0a:	89 c6                	mov    %eax,%esi
  800b0c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0f:	eb 1a                	jmp    800b2b <memcmp+0x2c>
		if (*s1 != *s2)
  800b11:	0f b6 08             	movzbl (%eax),%ecx
  800b14:	0f b6 1a             	movzbl (%edx),%ebx
  800b17:	38 d9                	cmp    %bl,%cl
  800b19:	74 0a                	je     800b25 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b1b:	0f b6 c1             	movzbl %cl,%eax
  800b1e:	0f b6 db             	movzbl %bl,%ebx
  800b21:	29 d8                	sub    %ebx,%eax
  800b23:	eb 0f                	jmp    800b34 <memcmp+0x35>
		s1++, s2++;
  800b25:	83 c0 01             	add    $0x1,%eax
  800b28:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2b:	39 f0                	cmp    %esi,%eax
  800b2d:	75 e2                	jne    800b11 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	53                   	push   %ebx
  800b3c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b3f:	89 c1                	mov    %eax,%ecx
  800b41:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b44:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b48:	eb 0a                	jmp    800b54 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4a:	0f b6 10             	movzbl (%eax),%edx
  800b4d:	39 da                	cmp    %ebx,%edx
  800b4f:	74 07                	je     800b58 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b51:	83 c0 01             	add    $0x1,%eax
  800b54:	39 c8                	cmp    %ecx,%eax
  800b56:	72 f2                	jb     800b4a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b58:	5b                   	pop    %ebx
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
  800b61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b64:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b67:	eb 03                	jmp    800b6c <strtol+0x11>
		s++;
  800b69:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6c:	0f b6 01             	movzbl (%ecx),%eax
  800b6f:	3c 20                	cmp    $0x20,%al
  800b71:	74 f6                	je     800b69 <strtol+0xe>
  800b73:	3c 09                	cmp    $0x9,%al
  800b75:	74 f2                	je     800b69 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b77:	3c 2b                	cmp    $0x2b,%al
  800b79:	75 0a                	jne    800b85 <strtol+0x2a>
		s++;
  800b7b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b83:	eb 11                	jmp    800b96 <strtol+0x3b>
  800b85:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b8a:	3c 2d                	cmp    $0x2d,%al
  800b8c:	75 08                	jne    800b96 <strtol+0x3b>
		s++, neg = 1;
  800b8e:	83 c1 01             	add    $0x1,%ecx
  800b91:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b96:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b9c:	75 15                	jne    800bb3 <strtol+0x58>
  800b9e:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba1:	75 10                	jne    800bb3 <strtol+0x58>
  800ba3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ba7:	75 7c                	jne    800c25 <strtol+0xca>
		s += 2, base = 16;
  800ba9:	83 c1 02             	add    $0x2,%ecx
  800bac:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb1:	eb 16                	jmp    800bc9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bb3:	85 db                	test   %ebx,%ebx
  800bb5:	75 12                	jne    800bc9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bb7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbc:	80 39 30             	cmpb   $0x30,(%ecx)
  800bbf:	75 08                	jne    800bc9 <strtol+0x6e>
		s++, base = 8;
  800bc1:	83 c1 01             	add    $0x1,%ecx
  800bc4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bce:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd1:	0f b6 11             	movzbl (%ecx),%edx
  800bd4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bd7:	89 f3                	mov    %esi,%ebx
  800bd9:	80 fb 09             	cmp    $0x9,%bl
  800bdc:	77 08                	ja     800be6 <strtol+0x8b>
			dig = *s - '0';
  800bde:	0f be d2             	movsbl %dl,%edx
  800be1:	83 ea 30             	sub    $0x30,%edx
  800be4:	eb 22                	jmp    800c08 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800be6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800be9:	89 f3                	mov    %esi,%ebx
  800beb:	80 fb 19             	cmp    $0x19,%bl
  800bee:	77 08                	ja     800bf8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bf0:	0f be d2             	movsbl %dl,%edx
  800bf3:	83 ea 57             	sub    $0x57,%edx
  800bf6:	eb 10                	jmp    800c08 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bf8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bfb:	89 f3                	mov    %esi,%ebx
  800bfd:	80 fb 19             	cmp    $0x19,%bl
  800c00:	77 16                	ja     800c18 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c02:	0f be d2             	movsbl %dl,%edx
  800c05:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c08:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c0b:	7d 0b                	jge    800c18 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c0d:	83 c1 01             	add    $0x1,%ecx
  800c10:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c14:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c16:	eb b9                	jmp    800bd1 <strtol+0x76>

	if (endptr)
  800c18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c1c:	74 0d                	je     800c2b <strtol+0xd0>
		*endptr = (char *) s;
  800c1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c21:	89 0e                	mov    %ecx,(%esi)
  800c23:	eb 06                	jmp    800c2b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c25:	85 db                	test   %ebx,%ebx
  800c27:	74 98                	je     800bc1 <strtol+0x66>
  800c29:	eb 9e                	jmp    800bc9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c2b:	89 c2                	mov    %eax,%edx
  800c2d:	f7 da                	neg    %edx
  800c2f:	85 ff                	test   %edi,%edi
  800c31:	0f 45 c2             	cmovne %edx,%eax
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 04             	sub    $0x4,%esp
  800c42:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800c45:	57                   	push   %edi
  800c46:	e8 6e fc ff ff       	call   8008b9 <strlen>
  800c4b:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800c4e:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800c51:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800c56:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800c5b:	eb 46                	jmp    800ca3 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800c5d:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800c61:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800c64:	80 f9 09             	cmp    $0x9,%cl
  800c67:	77 08                	ja     800c71 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800c69:	0f be d2             	movsbl %dl,%edx
  800c6c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800c6f:	eb 27                	jmp    800c98 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800c71:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800c74:	80 f9 05             	cmp    $0x5,%cl
  800c77:	77 08                	ja     800c81 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800c79:	0f be d2             	movsbl %dl,%edx
  800c7c:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800c7f:	eb 17                	jmp    800c98 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800c81:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800c84:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800c87:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800c8c:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800c90:	77 06                	ja     800c98 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800c92:	0f be d2             	movsbl %dl,%edx
  800c95:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800c98:	0f af ce             	imul   %esi,%ecx
  800c9b:	01 c8                	add    %ecx,%eax
		base *= 16;
  800c9d:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800ca0:	83 eb 01             	sub    $0x1,%ebx
  800ca3:	83 fb 01             	cmp    $0x1,%ebx
  800ca6:	7f b5                	jg     800c5d <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	57                   	push   %edi
  800cb4:	56                   	push   %esi
  800cb5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	89 c3                	mov    %eax,%ebx
  800cc3:	89 c7                	mov    %eax,%edi
  800cc5:	89 c6                	mov    %eax,%esi
  800cc7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <sys_cgetc>:

int
sys_cgetc(void)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cde:	89 d1                	mov    %edx,%ecx
  800ce0:	89 d3                	mov    %edx,%ebx
  800ce2:	89 d7                	mov    %edx,%edi
  800ce4:	89 d6                	mov    %edx,%esi
  800ce6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
  800cf3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfb:	b8 03 00 00 00       	mov    $0x3,%eax
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	89 cb                	mov    %ecx,%ebx
  800d05:	89 cf                	mov    %ecx,%edi
  800d07:	89 ce                	mov    %ecx,%esi
  800d09:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	7e 17                	jle    800d26 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0f:	83 ec 0c             	sub    $0xc,%esp
  800d12:	50                   	push   %eax
  800d13:	6a 03                	push   $0x3
  800d15:	68 ff 24 80 00       	push   $0x8024ff
  800d1a:	6a 23                	push   $0x23
  800d1c:	68 1c 25 80 00       	push   $0x80251c
  800d21:	e8 bf f4 ff ff       	call   8001e5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d34:	ba 00 00 00 00       	mov    $0x0,%edx
  800d39:	b8 02 00 00 00       	mov    $0x2,%eax
  800d3e:	89 d1                	mov    %edx,%ecx
  800d40:	89 d3                	mov    %edx,%ebx
  800d42:	89 d7                	mov    %edx,%edi
  800d44:	89 d6                	mov    %edx,%esi
  800d46:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_yield>:

void
sys_yield(void)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d53:	ba 00 00 00 00       	mov    $0x0,%edx
  800d58:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d5d:	89 d1                	mov    %edx,%ecx
  800d5f:	89 d3                	mov    %edx,%ebx
  800d61:	89 d7                	mov    %edx,%edi
  800d63:	89 d6                	mov    %edx,%esi
  800d65:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d75:	be 00 00 00 00       	mov    $0x0,%esi
  800d7a:	b8 04 00 00 00       	mov    $0x4,%eax
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d88:	89 f7                	mov    %esi,%edi
  800d8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7e 17                	jle    800da7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	50                   	push   %eax
  800d94:	6a 04                	push   $0x4
  800d96:	68 ff 24 80 00       	push   $0x8024ff
  800d9b:	6a 23                	push   $0x23
  800d9d:	68 1c 25 80 00       	push   $0x80251c
  800da2:	e8 3e f4 ff ff       	call   8001e5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800da7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800db8:	b8 05 00 00 00       	mov    $0x5,%eax
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc9:	8b 75 18             	mov    0x18(%ebp),%esi
  800dcc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	7e 17                	jle    800de9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd2:	83 ec 0c             	sub    $0xc,%esp
  800dd5:	50                   	push   %eax
  800dd6:	6a 05                	push   $0x5
  800dd8:	68 ff 24 80 00       	push   $0x8024ff
  800ddd:	6a 23                	push   $0x23
  800ddf:	68 1c 25 80 00       	push   $0x80251c
  800de4:	e8 fc f3 ff ff       	call   8001e5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800de9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5f                   	pop    %edi
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	57                   	push   %edi
  800df5:	56                   	push   %esi
  800df6:	53                   	push   %ebx
  800df7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dff:	b8 06 00 00 00       	mov    $0x6,%eax
  800e04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e07:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0a:	89 df                	mov    %ebx,%edi
  800e0c:	89 de                	mov    %ebx,%esi
  800e0e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e10:	85 c0                	test   %eax,%eax
  800e12:	7e 17                	jle    800e2b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e14:	83 ec 0c             	sub    $0xc,%esp
  800e17:	50                   	push   %eax
  800e18:	6a 06                	push   $0x6
  800e1a:	68 ff 24 80 00       	push   $0x8024ff
  800e1f:	6a 23                	push   $0x23
  800e21:	68 1c 25 80 00       	push   $0x80251c
  800e26:	e8 ba f3 ff ff       	call   8001e5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	57                   	push   %edi
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
  800e39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e41:	b8 08 00 00 00       	mov    $0x8,%eax
  800e46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e49:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4c:	89 df                	mov    %ebx,%edi
  800e4e:	89 de                	mov    %ebx,%esi
  800e50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e52:	85 c0                	test   %eax,%eax
  800e54:	7e 17                	jle    800e6d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e56:	83 ec 0c             	sub    $0xc,%esp
  800e59:	50                   	push   %eax
  800e5a:	6a 08                	push   $0x8
  800e5c:	68 ff 24 80 00       	push   $0x8024ff
  800e61:	6a 23                	push   $0x23
  800e63:	68 1c 25 80 00       	push   $0x80251c
  800e68:	e8 78 f3 ff ff       	call   8001e5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	57                   	push   %edi
  800e79:	56                   	push   %esi
  800e7a:	53                   	push   %ebx
  800e7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e83:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8e:	89 df                	mov    %ebx,%edi
  800e90:	89 de                	mov    %ebx,%esi
  800e92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e94:	85 c0                	test   %eax,%eax
  800e96:	7e 17                	jle    800eaf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e98:	83 ec 0c             	sub    $0xc,%esp
  800e9b:	50                   	push   %eax
  800e9c:	6a 0a                	push   $0xa
  800e9e:	68 ff 24 80 00       	push   $0x8024ff
  800ea3:	6a 23                	push   $0x23
  800ea5:	68 1c 25 80 00       	push   $0x80251c
  800eaa:	e8 36 f3 ff ff       	call   8001e5 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eaf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb2:	5b                   	pop    %ebx
  800eb3:	5e                   	pop    %esi
  800eb4:	5f                   	pop    %edi
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    

00800eb7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	57                   	push   %edi
  800ebb:	56                   	push   %esi
  800ebc:	53                   	push   %ebx
  800ebd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec5:	b8 09 00 00 00       	mov    $0x9,%eax
  800eca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed0:	89 df                	mov    %ebx,%edi
  800ed2:	89 de                	mov    %ebx,%esi
  800ed4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	7e 17                	jle    800ef1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eda:	83 ec 0c             	sub    $0xc,%esp
  800edd:	50                   	push   %eax
  800ede:	6a 09                	push   $0x9
  800ee0:	68 ff 24 80 00       	push   $0x8024ff
  800ee5:	6a 23                	push   $0x23
  800ee7:	68 1c 25 80 00       	push   $0x80251c
  800eec:	e8 f4 f2 ff ff       	call   8001e5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ef1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eff:	be 00 00 00 00       	mov    $0x0,%esi
  800f04:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f15:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f17:	5b                   	pop    %ebx
  800f18:	5e                   	pop    %esi
  800f19:	5f                   	pop    %edi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	57                   	push   %edi
  800f20:	56                   	push   %esi
  800f21:	53                   	push   %ebx
  800f22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f2a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f32:	89 cb                	mov    %ecx,%ebx
  800f34:	89 cf                	mov    %ecx,%edi
  800f36:	89 ce                	mov    %ecx,%esi
  800f38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	7e 17                	jle    800f55 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3e:	83 ec 0c             	sub    $0xc,%esp
  800f41:	50                   	push   %eax
  800f42:	6a 0d                	push   $0xd
  800f44:	68 ff 24 80 00       	push   $0x8024ff
  800f49:	6a 23                	push   $0x23
  800f4b:	68 1c 25 80 00       	push   $0x80251c
  800f50:	e8 90 f2 ff ff       	call   8001e5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f58:	5b                   	pop    %ebx
  800f59:	5e                   	pop    %esi
  800f5a:	5f                   	pop    %edi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    

00800f5d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f60:	8b 45 08             	mov    0x8(%ebp),%eax
  800f63:	05 00 00 00 30       	add    $0x30000000,%eax
  800f68:	c1 e8 0c             	shr    $0xc,%eax
}
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f70:	8b 45 08             	mov    0x8(%ebp),%eax
  800f73:	05 00 00 00 30       	add    $0x30000000,%eax
  800f78:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f7d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f8a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f8f:	89 c2                	mov    %eax,%edx
  800f91:	c1 ea 16             	shr    $0x16,%edx
  800f94:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f9b:	f6 c2 01             	test   $0x1,%dl
  800f9e:	74 11                	je     800fb1 <fd_alloc+0x2d>
  800fa0:	89 c2                	mov    %eax,%edx
  800fa2:	c1 ea 0c             	shr    $0xc,%edx
  800fa5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fac:	f6 c2 01             	test   $0x1,%dl
  800faf:	75 09                	jne    800fba <fd_alloc+0x36>
			*fd_store = fd;
  800fb1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb8:	eb 17                	jmp    800fd1 <fd_alloc+0x4d>
  800fba:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800fbf:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fc4:	75 c9                	jne    800f8f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fc6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800fcc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fd9:	83 f8 1f             	cmp    $0x1f,%eax
  800fdc:	77 36                	ja     801014 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fde:	c1 e0 0c             	shl    $0xc,%eax
  800fe1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fe6:	89 c2                	mov    %eax,%edx
  800fe8:	c1 ea 16             	shr    $0x16,%edx
  800feb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ff2:	f6 c2 01             	test   $0x1,%dl
  800ff5:	74 24                	je     80101b <fd_lookup+0x48>
  800ff7:	89 c2                	mov    %eax,%edx
  800ff9:	c1 ea 0c             	shr    $0xc,%edx
  800ffc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801003:	f6 c2 01             	test   $0x1,%dl
  801006:	74 1a                	je     801022 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801008:	8b 55 0c             	mov    0xc(%ebp),%edx
  80100b:	89 02                	mov    %eax,(%edx)
	return 0;
  80100d:	b8 00 00 00 00       	mov    $0x0,%eax
  801012:	eb 13                	jmp    801027 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801014:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801019:	eb 0c                	jmp    801027 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80101b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801020:	eb 05                	jmp    801027 <fd_lookup+0x54>
  801022:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801027:	5d                   	pop    %ebp
  801028:	c3                   	ret    

00801029 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	83 ec 08             	sub    $0x8,%esp
  80102f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801032:	ba a8 25 80 00       	mov    $0x8025a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801037:	eb 13                	jmp    80104c <dev_lookup+0x23>
  801039:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80103c:	39 08                	cmp    %ecx,(%eax)
  80103e:	75 0c                	jne    80104c <dev_lookup+0x23>
			*dev = devtab[i];
  801040:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801043:	89 01                	mov    %eax,(%ecx)
			return 0;
  801045:	b8 00 00 00 00       	mov    $0x0,%eax
  80104a:	eb 2e                	jmp    80107a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80104c:	8b 02                	mov    (%edx),%eax
  80104e:	85 c0                	test   %eax,%eax
  801050:	75 e7                	jne    801039 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801052:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801057:	8b 40 48             	mov    0x48(%eax),%eax
  80105a:	83 ec 04             	sub    $0x4,%esp
  80105d:	51                   	push   %ecx
  80105e:	50                   	push   %eax
  80105f:	68 2c 25 80 00       	push   $0x80252c
  801064:	e8 55 f2 ff ff       	call   8002be <cprintf>
	*dev = 0;
  801069:	8b 45 0c             	mov    0xc(%ebp),%eax
  80106c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801072:	83 c4 10             	add    $0x10,%esp
  801075:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80107a:	c9                   	leave  
  80107b:	c3                   	ret    

0080107c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	56                   	push   %esi
  801080:	53                   	push   %ebx
  801081:	83 ec 10             	sub    $0x10,%esp
  801084:	8b 75 08             	mov    0x8(%ebp),%esi
  801087:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80108a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80108d:	50                   	push   %eax
  80108e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801094:	c1 e8 0c             	shr    $0xc,%eax
  801097:	50                   	push   %eax
  801098:	e8 36 ff ff ff       	call   800fd3 <fd_lookup>
  80109d:	83 c4 08             	add    $0x8,%esp
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	78 05                	js     8010a9 <fd_close+0x2d>
	    || fd != fd2) 
  8010a4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010a7:	74 0c                	je     8010b5 <fd_close+0x39>
		return (must_exist ? r : 0); 
  8010a9:	84 db                	test   %bl,%bl
  8010ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b0:	0f 44 c2             	cmove  %edx,%eax
  8010b3:	eb 41                	jmp    8010f6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010b5:	83 ec 08             	sub    $0x8,%esp
  8010b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010bb:	50                   	push   %eax
  8010bc:	ff 36                	pushl  (%esi)
  8010be:	e8 66 ff ff ff       	call   801029 <dev_lookup>
  8010c3:	89 c3                	mov    %eax,%ebx
  8010c5:	83 c4 10             	add    $0x10,%esp
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	78 1a                	js     8010e6 <fd_close+0x6a>
		if (dev->dev_close) 
  8010cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010cf:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8010d2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	74 0b                	je     8010e6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010db:	83 ec 0c             	sub    $0xc,%esp
  8010de:	56                   	push   %esi
  8010df:	ff d0                	call   *%eax
  8010e1:	89 c3                	mov    %eax,%ebx
  8010e3:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010e6:	83 ec 08             	sub    $0x8,%esp
  8010e9:	56                   	push   %esi
  8010ea:	6a 00                	push   $0x0
  8010ec:	e8 00 fd ff ff       	call   800df1 <sys_page_unmap>
	return r;
  8010f1:	83 c4 10             	add    $0x10,%esp
  8010f4:	89 d8                	mov    %ebx,%eax
}
  8010f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010f9:	5b                   	pop    %ebx
  8010fa:	5e                   	pop    %esi
  8010fb:	5d                   	pop    %ebp
  8010fc:	c3                   	ret    

008010fd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801103:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801106:	50                   	push   %eax
  801107:	ff 75 08             	pushl  0x8(%ebp)
  80110a:	e8 c4 fe ff ff       	call   800fd3 <fd_lookup>
  80110f:	83 c4 08             	add    $0x8,%esp
  801112:	85 c0                	test   %eax,%eax
  801114:	78 10                	js     801126 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  801116:	83 ec 08             	sub    $0x8,%esp
  801119:	6a 01                	push   $0x1
  80111b:	ff 75 f4             	pushl  -0xc(%ebp)
  80111e:	e8 59 ff ff ff       	call   80107c <fd_close>
  801123:	83 c4 10             	add    $0x10,%esp
}
  801126:	c9                   	leave  
  801127:	c3                   	ret    

00801128 <close_all>:

void
close_all(void)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	53                   	push   %ebx
  80112c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80112f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801134:	83 ec 0c             	sub    $0xc,%esp
  801137:	53                   	push   %ebx
  801138:	e8 c0 ff ff ff       	call   8010fd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80113d:	83 c3 01             	add    $0x1,%ebx
  801140:	83 c4 10             	add    $0x10,%esp
  801143:	83 fb 20             	cmp    $0x20,%ebx
  801146:	75 ec                	jne    801134 <close_all+0xc>
		close(i);
}
  801148:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80114b:	c9                   	leave  
  80114c:	c3                   	ret    

0080114d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	57                   	push   %edi
  801151:	56                   	push   %esi
  801152:	53                   	push   %ebx
  801153:	83 ec 2c             	sub    $0x2c,%esp
  801156:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801159:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80115c:	50                   	push   %eax
  80115d:	ff 75 08             	pushl  0x8(%ebp)
  801160:	e8 6e fe ff ff       	call   800fd3 <fd_lookup>
  801165:	83 c4 08             	add    $0x8,%esp
  801168:	85 c0                	test   %eax,%eax
  80116a:	0f 88 c1 00 00 00    	js     801231 <dup+0xe4>
		return r;
	close(newfdnum);
  801170:	83 ec 0c             	sub    $0xc,%esp
  801173:	56                   	push   %esi
  801174:	e8 84 ff ff ff       	call   8010fd <close>

	newfd = INDEX2FD(newfdnum);
  801179:	89 f3                	mov    %esi,%ebx
  80117b:	c1 e3 0c             	shl    $0xc,%ebx
  80117e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801184:	83 c4 04             	add    $0x4,%esp
  801187:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118a:	e8 de fd ff ff       	call   800f6d <fd2data>
  80118f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801191:	89 1c 24             	mov    %ebx,(%esp)
  801194:	e8 d4 fd ff ff       	call   800f6d <fd2data>
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80119f:	89 f8                	mov    %edi,%eax
  8011a1:	c1 e8 16             	shr    $0x16,%eax
  8011a4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011ab:	a8 01                	test   $0x1,%al
  8011ad:	74 37                	je     8011e6 <dup+0x99>
  8011af:	89 f8                	mov    %edi,%eax
  8011b1:	c1 e8 0c             	shr    $0xc,%eax
  8011b4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011bb:	f6 c2 01             	test   $0x1,%dl
  8011be:	74 26                	je     8011e6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011c7:	83 ec 0c             	sub    $0xc,%esp
  8011ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8011cf:	50                   	push   %eax
  8011d0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011d3:	6a 00                	push   $0x0
  8011d5:	57                   	push   %edi
  8011d6:	6a 00                	push   $0x0
  8011d8:	e8 d2 fb ff ff       	call   800daf <sys_page_map>
  8011dd:	89 c7                	mov    %eax,%edi
  8011df:	83 c4 20             	add    $0x20,%esp
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	78 2e                	js     801214 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011e9:	89 d0                	mov    %edx,%eax
  8011eb:	c1 e8 0c             	shr    $0xc,%eax
  8011ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011f5:	83 ec 0c             	sub    $0xc,%esp
  8011f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8011fd:	50                   	push   %eax
  8011fe:	53                   	push   %ebx
  8011ff:	6a 00                	push   $0x0
  801201:	52                   	push   %edx
  801202:	6a 00                	push   $0x0
  801204:	e8 a6 fb ff ff       	call   800daf <sys_page_map>
  801209:	89 c7                	mov    %eax,%edi
  80120b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80120e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801210:	85 ff                	test   %edi,%edi
  801212:	79 1d                	jns    801231 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801214:	83 ec 08             	sub    $0x8,%esp
  801217:	53                   	push   %ebx
  801218:	6a 00                	push   $0x0
  80121a:	e8 d2 fb ff ff       	call   800df1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80121f:	83 c4 08             	add    $0x8,%esp
  801222:	ff 75 d4             	pushl  -0x2c(%ebp)
  801225:	6a 00                	push   $0x0
  801227:	e8 c5 fb ff ff       	call   800df1 <sys_page_unmap>
	return r;
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	89 f8                	mov    %edi,%eax
}
  801231:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801234:	5b                   	pop    %ebx
  801235:	5e                   	pop    %esi
  801236:	5f                   	pop    %edi
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    

00801239 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	53                   	push   %ebx
  80123d:	83 ec 14             	sub    $0x14,%esp
  801240:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801243:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801246:	50                   	push   %eax
  801247:	53                   	push   %ebx
  801248:	e8 86 fd ff ff       	call   800fd3 <fd_lookup>
  80124d:	83 c4 08             	add    $0x8,%esp
  801250:	89 c2                	mov    %eax,%edx
  801252:	85 c0                	test   %eax,%eax
  801254:	78 6d                	js     8012c3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801256:	83 ec 08             	sub    $0x8,%esp
  801259:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125c:	50                   	push   %eax
  80125d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801260:	ff 30                	pushl  (%eax)
  801262:	e8 c2 fd ff ff       	call   801029 <dev_lookup>
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 4c                	js     8012ba <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80126e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801271:	8b 42 08             	mov    0x8(%edx),%eax
  801274:	83 e0 03             	and    $0x3,%eax
  801277:	83 f8 01             	cmp    $0x1,%eax
  80127a:	75 21                	jne    80129d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80127c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801281:	8b 40 48             	mov    0x48(%eax),%eax
  801284:	83 ec 04             	sub    $0x4,%esp
  801287:	53                   	push   %ebx
  801288:	50                   	push   %eax
  801289:	68 6d 25 80 00       	push   $0x80256d
  80128e:	e8 2b f0 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80129b:	eb 26                	jmp    8012c3 <read+0x8a>
	}
	if (!dev->dev_read)
  80129d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a0:	8b 40 08             	mov    0x8(%eax),%eax
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	74 17                	je     8012be <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012a7:	83 ec 04             	sub    $0x4,%esp
  8012aa:	ff 75 10             	pushl  0x10(%ebp)
  8012ad:	ff 75 0c             	pushl  0xc(%ebp)
  8012b0:	52                   	push   %edx
  8012b1:	ff d0                	call   *%eax
  8012b3:	89 c2                	mov    %eax,%edx
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	eb 09                	jmp    8012c3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ba:	89 c2                	mov    %eax,%edx
  8012bc:	eb 05                	jmp    8012c3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8012c3:	89 d0                	mov    %edx,%eax
  8012c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c8:	c9                   	leave  
  8012c9:	c3                   	ret    

008012ca <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	57                   	push   %edi
  8012ce:	56                   	push   %esi
  8012cf:	53                   	push   %ebx
  8012d0:	83 ec 0c             	sub    $0xc,%esp
  8012d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012de:	eb 21                	jmp    801301 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012e0:	83 ec 04             	sub    $0x4,%esp
  8012e3:	89 f0                	mov    %esi,%eax
  8012e5:	29 d8                	sub    %ebx,%eax
  8012e7:	50                   	push   %eax
  8012e8:	89 d8                	mov    %ebx,%eax
  8012ea:	03 45 0c             	add    0xc(%ebp),%eax
  8012ed:	50                   	push   %eax
  8012ee:	57                   	push   %edi
  8012ef:	e8 45 ff ff ff       	call   801239 <read>
		if (m < 0)
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	78 10                	js     80130b <readn+0x41>
			return m;
		if (m == 0)
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	74 0a                	je     801309 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012ff:	01 c3                	add    %eax,%ebx
  801301:	39 f3                	cmp    %esi,%ebx
  801303:	72 db                	jb     8012e0 <readn+0x16>
  801305:	89 d8                	mov    %ebx,%eax
  801307:	eb 02                	jmp    80130b <readn+0x41>
  801309:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80130b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80130e:	5b                   	pop    %ebx
  80130f:	5e                   	pop    %esi
  801310:	5f                   	pop    %edi
  801311:	5d                   	pop    %ebp
  801312:	c3                   	ret    

00801313 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	53                   	push   %ebx
  801317:	83 ec 14             	sub    $0x14,%esp
  80131a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80131d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801320:	50                   	push   %eax
  801321:	53                   	push   %ebx
  801322:	e8 ac fc ff ff       	call   800fd3 <fd_lookup>
  801327:	83 c4 08             	add    $0x8,%esp
  80132a:	89 c2                	mov    %eax,%edx
  80132c:	85 c0                	test   %eax,%eax
  80132e:	78 68                	js     801398 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801330:	83 ec 08             	sub    $0x8,%esp
  801333:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801336:	50                   	push   %eax
  801337:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133a:	ff 30                	pushl  (%eax)
  80133c:	e8 e8 fc ff ff       	call   801029 <dev_lookup>
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	85 c0                	test   %eax,%eax
  801346:	78 47                	js     80138f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801348:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80134f:	75 21                	jne    801372 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801351:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801356:	8b 40 48             	mov    0x48(%eax),%eax
  801359:	83 ec 04             	sub    $0x4,%esp
  80135c:	53                   	push   %ebx
  80135d:	50                   	push   %eax
  80135e:	68 89 25 80 00       	push   $0x802589
  801363:	e8 56 ef ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801370:	eb 26                	jmp    801398 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801372:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801375:	8b 52 0c             	mov    0xc(%edx),%edx
  801378:	85 d2                	test   %edx,%edx
  80137a:	74 17                	je     801393 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80137c:	83 ec 04             	sub    $0x4,%esp
  80137f:	ff 75 10             	pushl  0x10(%ebp)
  801382:	ff 75 0c             	pushl  0xc(%ebp)
  801385:	50                   	push   %eax
  801386:	ff d2                	call   *%edx
  801388:	89 c2                	mov    %eax,%edx
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	eb 09                	jmp    801398 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138f:	89 c2                	mov    %eax,%edx
  801391:	eb 05                	jmp    801398 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801393:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801398:	89 d0                	mov    %edx,%eax
  80139a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139d:	c9                   	leave  
  80139e:	c3                   	ret    

0080139f <seek>:

int
seek(int fdnum, off_t offset)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013a8:	50                   	push   %eax
  8013a9:	ff 75 08             	pushl  0x8(%ebp)
  8013ac:	e8 22 fc ff ff       	call   800fd3 <fd_lookup>
  8013b1:	83 c4 08             	add    $0x8,%esp
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 0e                	js     8013c6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8013b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013be:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013c6:	c9                   	leave  
  8013c7:	c3                   	ret    

008013c8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	53                   	push   %ebx
  8013cc:	83 ec 14             	sub    $0x14,%esp
  8013cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d5:	50                   	push   %eax
  8013d6:	53                   	push   %ebx
  8013d7:	e8 f7 fb ff ff       	call   800fd3 <fd_lookup>
  8013dc:	83 c4 08             	add    $0x8,%esp
  8013df:	89 c2                	mov    %eax,%edx
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	78 65                	js     80144a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013eb:	50                   	push   %eax
  8013ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ef:	ff 30                	pushl  (%eax)
  8013f1:	e8 33 fc ff ff       	call   801029 <dev_lookup>
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	85 c0                	test   %eax,%eax
  8013fb:	78 44                	js     801441 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801400:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801404:	75 21                	jne    801427 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801406:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80140b:	8b 40 48             	mov    0x48(%eax),%eax
  80140e:	83 ec 04             	sub    $0x4,%esp
  801411:	53                   	push   %ebx
  801412:	50                   	push   %eax
  801413:	68 4c 25 80 00       	push   $0x80254c
  801418:	e8 a1 ee ff ff       	call   8002be <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80141d:	83 c4 10             	add    $0x10,%esp
  801420:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801425:	eb 23                	jmp    80144a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801427:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80142a:	8b 52 18             	mov    0x18(%edx),%edx
  80142d:	85 d2                	test   %edx,%edx
  80142f:	74 14                	je     801445 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801431:	83 ec 08             	sub    $0x8,%esp
  801434:	ff 75 0c             	pushl  0xc(%ebp)
  801437:	50                   	push   %eax
  801438:	ff d2                	call   *%edx
  80143a:	89 c2                	mov    %eax,%edx
  80143c:	83 c4 10             	add    $0x10,%esp
  80143f:	eb 09                	jmp    80144a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801441:	89 c2                	mov    %eax,%edx
  801443:	eb 05                	jmp    80144a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801445:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80144a:	89 d0                	mov    %edx,%eax
  80144c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144f:	c9                   	leave  
  801450:	c3                   	ret    

00801451 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	53                   	push   %ebx
  801455:	83 ec 14             	sub    $0x14,%esp
  801458:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80145b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80145e:	50                   	push   %eax
  80145f:	ff 75 08             	pushl  0x8(%ebp)
  801462:	e8 6c fb ff ff       	call   800fd3 <fd_lookup>
  801467:	83 c4 08             	add    $0x8,%esp
  80146a:	89 c2                	mov    %eax,%edx
  80146c:	85 c0                	test   %eax,%eax
  80146e:	78 58                	js     8014c8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801470:	83 ec 08             	sub    $0x8,%esp
  801473:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801476:	50                   	push   %eax
  801477:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147a:	ff 30                	pushl  (%eax)
  80147c:	e8 a8 fb ff ff       	call   801029 <dev_lookup>
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	85 c0                	test   %eax,%eax
  801486:	78 37                	js     8014bf <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801488:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80148f:	74 32                	je     8014c3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801491:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801494:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80149b:	00 00 00 
	stat->st_isdir = 0;
  80149e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014a5:	00 00 00 
	stat->st_dev = dev;
  8014a8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014ae:	83 ec 08             	sub    $0x8,%esp
  8014b1:	53                   	push   %ebx
  8014b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8014b5:	ff 50 14             	call   *0x14(%eax)
  8014b8:	89 c2                	mov    %eax,%edx
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	eb 09                	jmp    8014c8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014bf:	89 c2                	mov    %eax,%edx
  8014c1:	eb 05                	jmp    8014c8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014c8:	89 d0                	mov    %edx,%eax
  8014ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cd:	c9                   	leave  
  8014ce:	c3                   	ret    

008014cf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	56                   	push   %esi
  8014d3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014d4:	83 ec 08             	sub    $0x8,%esp
  8014d7:	6a 00                	push   $0x0
  8014d9:	ff 75 08             	pushl  0x8(%ebp)
  8014dc:	e8 2b 02 00 00       	call   80170c <open>
  8014e1:	89 c3                	mov    %eax,%ebx
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 1b                	js     801505 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014ea:	83 ec 08             	sub    $0x8,%esp
  8014ed:	ff 75 0c             	pushl  0xc(%ebp)
  8014f0:	50                   	push   %eax
  8014f1:	e8 5b ff ff ff       	call   801451 <fstat>
  8014f6:	89 c6                	mov    %eax,%esi
	close(fd);
  8014f8:	89 1c 24             	mov    %ebx,(%esp)
  8014fb:	e8 fd fb ff ff       	call   8010fd <close>
	return r;
  801500:	83 c4 10             	add    $0x10,%esp
  801503:	89 f0                	mov    %esi,%eax
}
  801505:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801508:	5b                   	pop    %ebx
  801509:	5e                   	pop    %esi
  80150a:	5d                   	pop    %ebp
  80150b:	c3                   	ret    

0080150c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	56                   	push   %esi
  801510:	53                   	push   %ebx
  801511:	89 c6                	mov    %eax,%esi
  801513:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801515:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  80151c:	75 12                	jne    801530 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80151e:	83 ec 0c             	sub    $0xc,%esp
  801521:	6a 01                	push   $0x1
  801523:	e8 36 09 00 00       	call   801e5e <ipc_find_env>
  801528:	a3 08 40 80 00       	mov    %eax,0x804008
  80152d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801530:	6a 07                	push   $0x7
  801532:	68 00 50 80 00       	push   $0x805000
  801537:	56                   	push   %esi
  801538:	ff 35 08 40 80 00    	pushl  0x804008
  80153e:	e8 c5 08 00 00       	call   801e08 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801543:	83 c4 0c             	add    $0xc,%esp
  801546:	6a 00                	push   $0x0
  801548:	53                   	push   %ebx
  801549:	6a 00                	push   $0x0
  80154b:	e8 4f 08 00 00       	call   801d9f <ipc_recv>
}
  801550:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801553:	5b                   	pop    %ebx
  801554:	5e                   	pop    %esi
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    

00801557 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80155d:	8b 45 08             	mov    0x8(%ebp),%eax
  801560:	8b 40 0c             	mov    0xc(%eax),%eax
  801563:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801568:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801570:	ba 00 00 00 00       	mov    $0x0,%edx
  801575:	b8 02 00 00 00       	mov    $0x2,%eax
  80157a:	e8 8d ff ff ff       	call   80150c <fsipc>
}
  80157f:	c9                   	leave  
  801580:	c3                   	ret    

00801581 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801587:	8b 45 08             	mov    0x8(%ebp),%eax
  80158a:	8b 40 0c             	mov    0xc(%eax),%eax
  80158d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801592:	ba 00 00 00 00       	mov    $0x0,%edx
  801597:	b8 06 00 00 00       	mov    $0x6,%eax
  80159c:	e8 6b ff ff ff       	call   80150c <fsipc>
}
  8015a1:	c9                   	leave  
  8015a2:	c3                   	ret    

008015a3 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 04             	sub    $0x4,%esp
  8015aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bd:	b8 05 00 00 00       	mov    $0x5,%eax
  8015c2:	e8 45 ff ff ff       	call   80150c <fsipc>
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	78 2c                	js     8015f7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	68 00 50 80 00       	push   $0x805000
  8015d3:	53                   	push   %ebx
  8015d4:	e8 19 f3 ff ff       	call   8008f2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015d9:	a1 80 50 80 00       	mov    0x805080,%eax
  8015de:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015e4:	a1 84 50 80 00       	mov    0x805084,%eax
  8015e9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fa:	c9                   	leave  
  8015fb:	c3                   	ret    

008015fc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	53                   	push   %ebx
  801600:	83 ec 08             	sub    $0x8,%esp
  801603:	8b 45 10             	mov    0x10(%ebp),%eax
  801606:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80160b:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801610:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801613:	8b 45 08             	mov    0x8(%ebp),%eax
  801616:	8b 40 0c             	mov    0xc(%eax),%eax
  801619:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  80161e:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801624:	53                   	push   %ebx
  801625:	ff 75 0c             	pushl  0xc(%ebp)
  801628:	68 08 50 80 00       	push   $0x805008
  80162d:	e8 52 f4 ff ff       	call   800a84 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801632:	ba 00 00 00 00       	mov    $0x0,%edx
  801637:	b8 04 00 00 00       	mov    $0x4,%eax
  80163c:	e8 cb fe ff ff       	call   80150c <fsipc>
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	85 c0                	test   %eax,%eax
  801646:	78 3d                	js     801685 <devfile_write+0x89>
		return r;

	assert(r <= n);
  801648:	39 d8                	cmp    %ebx,%eax
  80164a:	76 19                	jbe    801665 <devfile_write+0x69>
  80164c:	68 b8 25 80 00       	push   $0x8025b8
  801651:	68 bf 25 80 00       	push   $0x8025bf
  801656:	68 9f 00 00 00       	push   $0x9f
  80165b:	68 d4 25 80 00       	push   $0x8025d4
  801660:	e8 80 eb ff ff       	call   8001e5 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801665:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80166a:	76 19                	jbe    801685 <devfile_write+0x89>
  80166c:	68 ec 25 80 00       	push   $0x8025ec
  801671:	68 bf 25 80 00       	push   $0x8025bf
  801676:	68 a0 00 00 00       	push   $0xa0
  80167b:	68 d4 25 80 00       	push   $0x8025d4
  801680:	e8 60 eb ff ff       	call   8001e5 <_panic>

	return r;
}
  801685:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801688:	c9                   	leave  
  801689:	c3                   	ret    

0080168a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	56                   	push   %esi
  80168e:	53                   	push   %ebx
  80168f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801692:	8b 45 08             	mov    0x8(%ebp),%eax
  801695:	8b 40 0c             	mov    0xc(%eax),%eax
  801698:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80169d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a8:	b8 03 00 00 00       	mov    $0x3,%eax
  8016ad:	e8 5a fe ff ff       	call   80150c <fsipc>
  8016b2:	89 c3                	mov    %eax,%ebx
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 4b                	js     801703 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8016b8:	39 c6                	cmp    %eax,%esi
  8016ba:	73 16                	jae    8016d2 <devfile_read+0x48>
  8016bc:	68 b8 25 80 00       	push   $0x8025b8
  8016c1:	68 bf 25 80 00       	push   $0x8025bf
  8016c6:	6a 7e                	push   $0x7e
  8016c8:	68 d4 25 80 00       	push   $0x8025d4
  8016cd:	e8 13 eb ff ff       	call   8001e5 <_panic>
	assert(r <= PGSIZE);
  8016d2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016d7:	7e 16                	jle    8016ef <devfile_read+0x65>
  8016d9:	68 df 25 80 00       	push   $0x8025df
  8016de:	68 bf 25 80 00       	push   $0x8025bf
  8016e3:	6a 7f                	push   $0x7f
  8016e5:	68 d4 25 80 00       	push   $0x8025d4
  8016ea:	e8 f6 ea ff ff       	call   8001e5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016ef:	83 ec 04             	sub    $0x4,%esp
  8016f2:	50                   	push   %eax
  8016f3:	68 00 50 80 00       	push   $0x805000
  8016f8:	ff 75 0c             	pushl  0xc(%ebp)
  8016fb:	e8 84 f3 ff ff       	call   800a84 <memmove>
	return r;
  801700:	83 c4 10             	add    $0x10,%esp
}
  801703:	89 d8                	mov    %ebx,%eax
  801705:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801708:	5b                   	pop    %ebx
  801709:	5e                   	pop    %esi
  80170a:	5d                   	pop    %ebp
  80170b:	c3                   	ret    

0080170c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	53                   	push   %ebx
  801710:	83 ec 20             	sub    $0x20,%esp
  801713:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801716:	53                   	push   %ebx
  801717:	e8 9d f1 ff ff       	call   8008b9 <strlen>
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801724:	7f 67                	jg     80178d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801726:	83 ec 0c             	sub    $0xc,%esp
  801729:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172c:	50                   	push   %eax
  80172d:	e8 52 f8 ff ff       	call   800f84 <fd_alloc>
  801732:	83 c4 10             	add    $0x10,%esp
		return r;
  801735:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801737:	85 c0                	test   %eax,%eax
  801739:	78 57                	js     801792 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80173b:	83 ec 08             	sub    $0x8,%esp
  80173e:	53                   	push   %ebx
  80173f:	68 00 50 80 00       	push   $0x805000
  801744:	e8 a9 f1 ff ff       	call   8008f2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801749:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801751:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801754:	b8 01 00 00 00       	mov    $0x1,%eax
  801759:	e8 ae fd ff ff       	call   80150c <fsipc>
  80175e:	89 c3                	mov    %eax,%ebx
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	85 c0                	test   %eax,%eax
  801765:	79 14                	jns    80177b <open+0x6f>
		fd_close(fd, 0);
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	6a 00                	push   $0x0
  80176c:	ff 75 f4             	pushl  -0xc(%ebp)
  80176f:	e8 08 f9 ff ff       	call   80107c <fd_close>
		return r;
  801774:	83 c4 10             	add    $0x10,%esp
  801777:	89 da                	mov    %ebx,%edx
  801779:	eb 17                	jmp    801792 <open+0x86>
	}

	return fd2num(fd);
  80177b:	83 ec 0c             	sub    $0xc,%esp
  80177e:	ff 75 f4             	pushl  -0xc(%ebp)
  801781:	e8 d7 f7 ff ff       	call   800f5d <fd2num>
  801786:	89 c2                	mov    %eax,%edx
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	eb 05                	jmp    801792 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80178d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801792:	89 d0                	mov    %edx,%eax
  801794:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801797:	c9                   	leave  
  801798:	c3                   	ret    

00801799 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80179f:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a4:	b8 08 00 00 00       	mov    $0x8,%eax
  8017a9:	e8 5e fd ff ff       	call   80150c <fsipc>
}
  8017ae:	c9                   	leave  
  8017af:	c3                   	ret    

008017b0 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8017b0:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8017b4:	7e 37                	jle    8017ed <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	53                   	push   %ebx
  8017ba:	83 ec 08             	sub    $0x8,%esp
  8017bd:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8017bf:	ff 70 04             	pushl  0x4(%eax)
  8017c2:	8d 40 10             	lea    0x10(%eax),%eax
  8017c5:	50                   	push   %eax
  8017c6:	ff 33                	pushl  (%ebx)
  8017c8:	e8 46 fb ff ff       	call   801313 <write>
		if (result > 0)
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	7e 03                	jle    8017d7 <writebuf+0x27>
			b->result += result;
  8017d4:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8017d7:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017da:	74 0d                	je     8017e9 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e3:	0f 4f c2             	cmovg  %edx,%eax
  8017e6:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8017e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ec:	c9                   	leave  
  8017ed:	f3 c3                	repz ret 

008017ef <putch>:

static void
putch(int ch, void *thunk)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	53                   	push   %ebx
  8017f3:	83 ec 04             	sub    $0x4,%esp
  8017f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8017f9:	8b 53 04             	mov    0x4(%ebx),%edx
  8017fc:	8d 42 01             	lea    0x1(%edx),%eax
  8017ff:	89 43 04             	mov    %eax,0x4(%ebx)
  801802:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801805:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801809:	3d 00 01 00 00       	cmp    $0x100,%eax
  80180e:	75 0e                	jne    80181e <putch+0x2f>
		writebuf(b);
  801810:	89 d8                	mov    %ebx,%eax
  801812:	e8 99 ff ff ff       	call   8017b0 <writebuf>
		b->idx = 0;
  801817:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80181e:	83 c4 04             	add    $0x4,%esp
  801821:	5b                   	pop    %ebx
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80182d:	8b 45 08             	mov    0x8(%ebp),%eax
  801830:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801836:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80183d:	00 00 00 
	b.result = 0;
  801840:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801847:	00 00 00 
	b.error = 1;
  80184a:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801851:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801854:	ff 75 10             	pushl  0x10(%ebp)
  801857:	ff 75 0c             	pushl  0xc(%ebp)
  80185a:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801860:	50                   	push   %eax
  801861:	68 ef 17 80 00       	push   $0x8017ef
  801866:	e8 8a eb ff ff       	call   8003f5 <vprintfmt>
	if (b.idx > 0)
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801875:	7e 0b                	jle    801882 <vfprintf+0x5e>
		writebuf(&b);
  801877:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80187d:	e8 2e ff ff ff       	call   8017b0 <writebuf>

	return (b.result ? b.result : b.error);
  801882:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801888:	85 c0                	test   %eax,%eax
  80188a:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801891:	c9                   	leave  
  801892:	c3                   	ret    

00801893 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801899:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80189c:	50                   	push   %eax
  80189d:	ff 75 0c             	pushl  0xc(%ebp)
  8018a0:	ff 75 08             	pushl  0x8(%ebp)
  8018a3:	e8 7c ff ff ff       	call   801824 <vfprintf>
	va_end(ap);

	return cnt;
}
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <printf>:

int
printf(const char *fmt, ...)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018b0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8018b3:	50                   	push   %eax
  8018b4:	ff 75 08             	pushl  0x8(%ebp)
  8018b7:	6a 01                	push   $0x1
  8018b9:	e8 66 ff ff ff       	call   801824 <vfprintf>
	va_end(ap);

	return cnt;
}
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	56                   	push   %esi
  8018c4:	53                   	push   %ebx
  8018c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018c8:	83 ec 0c             	sub    $0xc,%esp
  8018cb:	ff 75 08             	pushl  0x8(%ebp)
  8018ce:	e8 9a f6 ff ff       	call   800f6d <fd2data>
  8018d3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018d5:	83 c4 08             	add    $0x8,%esp
  8018d8:	68 19 26 80 00       	push   $0x802619
  8018dd:	53                   	push   %ebx
  8018de:	e8 0f f0 ff ff       	call   8008f2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018e3:	8b 46 04             	mov    0x4(%esi),%eax
  8018e6:	2b 06                	sub    (%esi),%eax
  8018e8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018ee:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018f5:	00 00 00 
	stat->st_dev = &devpipe;
  8018f8:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  8018ff:	30 80 00 
	return 0;
}
  801902:	b8 00 00 00 00       	mov    $0x0,%eax
  801907:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190a:	5b                   	pop    %ebx
  80190b:	5e                   	pop    %esi
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	53                   	push   %ebx
  801912:	83 ec 0c             	sub    $0xc,%esp
  801915:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801918:	53                   	push   %ebx
  801919:	6a 00                	push   $0x0
  80191b:	e8 d1 f4 ff ff       	call   800df1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801920:	89 1c 24             	mov    %ebx,(%esp)
  801923:	e8 45 f6 ff ff       	call   800f6d <fd2data>
  801928:	83 c4 08             	add    $0x8,%esp
  80192b:	50                   	push   %eax
  80192c:	6a 00                	push   $0x0
  80192e:	e8 be f4 ff ff       	call   800df1 <sys_page_unmap>
}
  801933:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801936:	c9                   	leave  
  801937:	c3                   	ret    

00801938 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	57                   	push   %edi
  80193c:	56                   	push   %esi
  80193d:	53                   	push   %ebx
  80193e:	83 ec 1c             	sub    $0x1c,%esp
  801941:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801944:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801946:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80194b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80194e:	83 ec 0c             	sub    $0xc,%esp
  801951:	ff 75 e0             	pushl  -0x20(%ebp)
  801954:	e8 3e 05 00 00       	call   801e97 <pageref>
  801959:	89 c3                	mov    %eax,%ebx
  80195b:	89 3c 24             	mov    %edi,(%esp)
  80195e:	e8 34 05 00 00       	call   801e97 <pageref>
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	39 c3                	cmp    %eax,%ebx
  801968:	0f 94 c1             	sete   %cl
  80196b:	0f b6 c9             	movzbl %cl,%ecx
  80196e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801971:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801977:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80197a:	39 ce                	cmp    %ecx,%esi
  80197c:	74 1b                	je     801999 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80197e:	39 c3                	cmp    %eax,%ebx
  801980:	75 c4                	jne    801946 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801982:	8b 42 58             	mov    0x58(%edx),%eax
  801985:	ff 75 e4             	pushl  -0x1c(%ebp)
  801988:	50                   	push   %eax
  801989:	56                   	push   %esi
  80198a:	68 20 26 80 00       	push   $0x802620
  80198f:	e8 2a e9 ff ff       	call   8002be <cprintf>
  801994:	83 c4 10             	add    $0x10,%esp
  801997:	eb ad                	jmp    801946 <_pipeisclosed+0xe>
	}
}
  801999:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80199c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80199f:	5b                   	pop    %ebx
  8019a0:	5e                   	pop    %esi
  8019a1:	5f                   	pop    %edi
  8019a2:	5d                   	pop    %ebp
  8019a3:	c3                   	ret    

008019a4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	57                   	push   %edi
  8019a8:	56                   	push   %esi
  8019a9:	53                   	push   %ebx
  8019aa:	83 ec 28             	sub    $0x28,%esp
  8019ad:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019b0:	56                   	push   %esi
  8019b1:	e8 b7 f5 ff ff       	call   800f6d <fd2data>
  8019b6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019b8:	83 c4 10             	add    $0x10,%esp
  8019bb:	bf 00 00 00 00       	mov    $0x0,%edi
  8019c0:	eb 4b                	jmp    801a0d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019c2:	89 da                	mov    %ebx,%edx
  8019c4:	89 f0                	mov    %esi,%eax
  8019c6:	e8 6d ff ff ff       	call   801938 <_pipeisclosed>
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	75 48                	jne    801a17 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019cf:	e8 79 f3 ff ff       	call   800d4d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019d4:	8b 43 04             	mov    0x4(%ebx),%eax
  8019d7:	8b 0b                	mov    (%ebx),%ecx
  8019d9:	8d 51 20             	lea    0x20(%ecx),%edx
  8019dc:	39 d0                	cmp    %edx,%eax
  8019de:	73 e2                	jae    8019c2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019e7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019ea:	89 c2                	mov    %eax,%edx
  8019ec:	c1 fa 1f             	sar    $0x1f,%edx
  8019ef:	89 d1                	mov    %edx,%ecx
  8019f1:	c1 e9 1b             	shr    $0x1b,%ecx
  8019f4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019f7:	83 e2 1f             	and    $0x1f,%edx
  8019fa:	29 ca                	sub    %ecx,%edx
  8019fc:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a00:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a04:	83 c0 01             	add    $0x1,%eax
  801a07:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a0a:	83 c7 01             	add    $0x1,%edi
  801a0d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a10:	75 c2                	jne    8019d4 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a12:	8b 45 10             	mov    0x10(%ebp),%eax
  801a15:	eb 05                	jmp    801a1c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a17:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a1f:	5b                   	pop    %ebx
  801a20:	5e                   	pop    %esi
  801a21:	5f                   	pop    %edi
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	57                   	push   %edi
  801a28:	56                   	push   %esi
  801a29:	53                   	push   %ebx
  801a2a:	83 ec 18             	sub    $0x18,%esp
  801a2d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a30:	57                   	push   %edi
  801a31:	e8 37 f5 ff ff       	call   800f6d <fd2data>
  801a36:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a40:	eb 3d                	jmp    801a7f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a42:	85 db                	test   %ebx,%ebx
  801a44:	74 04                	je     801a4a <devpipe_read+0x26>
				return i;
  801a46:	89 d8                	mov    %ebx,%eax
  801a48:	eb 44                	jmp    801a8e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a4a:	89 f2                	mov    %esi,%edx
  801a4c:	89 f8                	mov    %edi,%eax
  801a4e:	e8 e5 fe ff ff       	call   801938 <_pipeisclosed>
  801a53:	85 c0                	test   %eax,%eax
  801a55:	75 32                	jne    801a89 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a57:	e8 f1 f2 ff ff       	call   800d4d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a5c:	8b 06                	mov    (%esi),%eax
  801a5e:	3b 46 04             	cmp    0x4(%esi),%eax
  801a61:	74 df                	je     801a42 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a63:	99                   	cltd   
  801a64:	c1 ea 1b             	shr    $0x1b,%edx
  801a67:	01 d0                	add    %edx,%eax
  801a69:	83 e0 1f             	and    $0x1f,%eax
  801a6c:	29 d0                	sub    %edx,%eax
  801a6e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a76:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a79:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a7c:	83 c3 01             	add    $0x1,%ebx
  801a7f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a82:	75 d8                	jne    801a5c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a84:	8b 45 10             	mov    0x10(%ebp),%eax
  801a87:	eb 05                	jmp    801a8e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a89:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a91:	5b                   	pop    %ebx
  801a92:	5e                   	pop    %esi
  801a93:	5f                   	pop    %edi
  801a94:	5d                   	pop    %ebp
  801a95:	c3                   	ret    

00801a96 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	56                   	push   %esi
  801a9a:	53                   	push   %ebx
  801a9b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa1:	50                   	push   %eax
  801aa2:	e8 dd f4 ff ff       	call   800f84 <fd_alloc>
  801aa7:	83 c4 10             	add    $0x10,%esp
  801aaa:	89 c2                	mov    %eax,%edx
  801aac:	85 c0                	test   %eax,%eax
  801aae:	0f 88 2c 01 00 00    	js     801be0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab4:	83 ec 04             	sub    $0x4,%esp
  801ab7:	68 07 04 00 00       	push   $0x407
  801abc:	ff 75 f4             	pushl  -0xc(%ebp)
  801abf:	6a 00                	push   $0x0
  801ac1:	e8 a6 f2 ff ff       	call   800d6c <sys_page_alloc>
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	89 c2                	mov    %eax,%edx
  801acb:	85 c0                	test   %eax,%eax
  801acd:	0f 88 0d 01 00 00    	js     801be0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ad3:	83 ec 0c             	sub    $0xc,%esp
  801ad6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ad9:	50                   	push   %eax
  801ada:	e8 a5 f4 ff ff       	call   800f84 <fd_alloc>
  801adf:	89 c3                	mov    %eax,%ebx
  801ae1:	83 c4 10             	add    $0x10,%esp
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	0f 88 e2 00 00 00    	js     801bce <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aec:	83 ec 04             	sub    $0x4,%esp
  801aef:	68 07 04 00 00       	push   $0x407
  801af4:	ff 75 f0             	pushl  -0x10(%ebp)
  801af7:	6a 00                	push   $0x0
  801af9:	e8 6e f2 ff ff       	call   800d6c <sys_page_alloc>
  801afe:	89 c3                	mov    %eax,%ebx
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	85 c0                	test   %eax,%eax
  801b05:	0f 88 c3 00 00 00    	js     801bce <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b0b:	83 ec 0c             	sub    $0xc,%esp
  801b0e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b11:	e8 57 f4 ff ff       	call   800f6d <fd2data>
  801b16:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b18:	83 c4 0c             	add    $0xc,%esp
  801b1b:	68 07 04 00 00       	push   $0x407
  801b20:	50                   	push   %eax
  801b21:	6a 00                	push   $0x0
  801b23:	e8 44 f2 ff ff       	call   800d6c <sys_page_alloc>
  801b28:	89 c3                	mov    %eax,%ebx
  801b2a:	83 c4 10             	add    $0x10,%esp
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	0f 88 89 00 00 00    	js     801bbe <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b35:	83 ec 0c             	sub    $0xc,%esp
  801b38:	ff 75 f0             	pushl  -0x10(%ebp)
  801b3b:	e8 2d f4 ff ff       	call   800f6d <fd2data>
  801b40:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b47:	50                   	push   %eax
  801b48:	6a 00                	push   $0x0
  801b4a:	56                   	push   %esi
  801b4b:	6a 00                	push   $0x0
  801b4d:	e8 5d f2 ff ff       	call   800daf <sys_page_map>
  801b52:	89 c3                	mov    %eax,%ebx
  801b54:	83 c4 20             	add    $0x20,%esp
  801b57:	85 c0                	test   %eax,%eax
  801b59:	78 55                	js     801bb0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b5b:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b64:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b69:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b70:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b79:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b7e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b85:	83 ec 0c             	sub    $0xc,%esp
  801b88:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8b:	e8 cd f3 ff ff       	call   800f5d <fd2num>
  801b90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b93:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b95:	83 c4 04             	add    $0x4,%esp
  801b98:	ff 75 f0             	pushl  -0x10(%ebp)
  801b9b:	e8 bd f3 ff ff       	call   800f5d <fd2num>
  801ba0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ba3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ba6:	83 c4 10             	add    $0x10,%esp
  801ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  801bae:	eb 30                	jmp    801be0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bb0:	83 ec 08             	sub    $0x8,%esp
  801bb3:	56                   	push   %esi
  801bb4:	6a 00                	push   $0x0
  801bb6:	e8 36 f2 ff ff       	call   800df1 <sys_page_unmap>
  801bbb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bbe:	83 ec 08             	sub    $0x8,%esp
  801bc1:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc4:	6a 00                	push   $0x0
  801bc6:	e8 26 f2 ff ff       	call   800df1 <sys_page_unmap>
  801bcb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bce:	83 ec 08             	sub    $0x8,%esp
  801bd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd4:	6a 00                	push   $0x0
  801bd6:	e8 16 f2 ff ff       	call   800df1 <sys_page_unmap>
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801be0:	89 d0                	mov    %edx,%eax
  801be2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be5:	5b                   	pop    %ebx
  801be6:	5e                   	pop    %esi
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf2:	50                   	push   %eax
  801bf3:	ff 75 08             	pushl  0x8(%ebp)
  801bf6:	e8 d8 f3 ff ff       	call   800fd3 <fd_lookup>
  801bfb:	83 c4 10             	add    $0x10,%esp
  801bfe:	85 c0                	test   %eax,%eax
  801c00:	78 18                	js     801c1a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c02:	83 ec 0c             	sub    $0xc,%esp
  801c05:	ff 75 f4             	pushl  -0xc(%ebp)
  801c08:	e8 60 f3 ff ff       	call   800f6d <fd2data>
	return _pipeisclosed(fd, p);
  801c0d:	89 c2                	mov    %eax,%edx
  801c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c12:	e8 21 fd ff ff       	call   801938 <_pipeisclosed>
  801c17:	83 c4 10             	add    $0x10,%esp
}
  801c1a:	c9                   	leave  
  801c1b:	c3                   	ret    

00801c1c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c24:	5d                   	pop    %ebp
  801c25:	c3                   	ret    

00801c26 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c26:	55                   	push   %ebp
  801c27:	89 e5                	mov    %esp,%ebp
  801c29:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c2c:	68 38 26 80 00       	push   $0x802638
  801c31:	ff 75 0c             	pushl  0xc(%ebp)
  801c34:	e8 b9 ec ff ff       	call   8008f2 <strcpy>
	return 0;
}
  801c39:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3e:	c9                   	leave  
  801c3f:	c3                   	ret    

00801c40 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	57                   	push   %edi
  801c44:	56                   	push   %esi
  801c45:	53                   	push   %ebx
  801c46:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c4c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c51:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c57:	eb 2d                	jmp    801c86 <devcons_write+0x46>
		m = n - tot;
  801c59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c5c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c5e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c61:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c66:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c69:	83 ec 04             	sub    $0x4,%esp
  801c6c:	53                   	push   %ebx
  801c6d:	03 45 0c             	add    0xc(%ebp),%eax
  801c70:	50                   	push   %eax
  801c71:	57                   	push   %edi
  801c72:	e8 0d ee ff ff       	call   800a84 <memmove>
		sys_cputs(buf, m);
  801c77:	83 c4 08             	add    $0x8,%esp
  801c7a:	53                   	push   %ebx
  801c7b:	57                   	push   %edi
  801c7c:	e8 2f f0 ff ff       	call   800cb0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c81:	01 de                	add    %ebx,%esi
  801c83:	83 c4 10             	add    $0x10,%esp
  801c86:	89 f0                	mov    %esi,%eax
  801c88:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c8b:	72 cc                	jb     801c59 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c90:	5b                   	pop    %ebx
  801c91:	5e                   	pop    %esi
  801c92:	5f                   	pop    %edi
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    

00801c95 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	83 ec 08             	sub    $0x8,%esp
  801c9b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ca0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ca4:	74 2a                	je     801cd0 <devcons_read+0x3b>
  801ca6:	eb 05                	jmp    801cad <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ca8:	e8 a0 f0 ff ff       	call   800d4d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cad:	e8 1c f0 ff ff       	call   800cce <sys_cgetc>
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	74 f2                	je     801ca8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801cb6:	85 c0                	test   %eax,%eax
  801cb8:	78 16                	js     801cd0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cba:	83 f8 04             	cmp    $0x4,%eax
  801cbd:	74 0c                	je     801ccb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cbf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cc2:	88 02                	mov    %al,(%edx)
	return 1;
  801cc4:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc9:	eb 05                	jmp    801cd0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ccb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cd0:	c9                   	leave  
  801cd1:	c3                   	ret    

00801cd2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cde:	6a 01                	push   $0x1
  801ce0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ce3:	50                   	push   %eax
  801ce4:	e8 c7 ef ff ff       	call   800cb0 <sys_cputs>
}
  801ce9:	83 c4 10             	add    $0x10,%esp
  801cec:	c9                   	leave  
  801ced:	c3                   	ret    

00801cee <getchar>:

int
getchar(void)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cf4:	6a 01                	push   $0x1
  801cf6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cf9:	50                   	push   %eax
  801cfa:	6a 00                	push   $0x0
  801cfc:	e8 38 f5 ff ff       	call   801239 <read>
	if (r < 0)
  801d01:	83 c4 10             	add    $0x10,%esp
  801d04:	85 c0                	test   %eax,%eax
  801d06:	78 0f                	js     801d17 <getchar+0x29>
		return r;
	if (r < 1)
  801d08:	85 c0                	test   %eax,%eax
  801d0a:	7e 06                	jle    801d12 <getchar+0x24>
		return -E_EOF;
	return c;
  801d0c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d10:	eb 05                	jmp    801d17 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d12:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d17:	c9                   	leave  
  801d18:	c3                   	ret    

00801d19 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d22:	50                   	push   %eax
  801d23:	ff 75 08             	pushl  0x8(%ebp)
  801d26:	e8 a8 f2 ff ff       	call   800fd3 <fd_lookup>
  801d2b:	83 c4 10             	add    $0x10,%esp
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	78 11                	js     801d43 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d35:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801d3b:	39 10                	cmp    %edx,(%eax)
  801d3d:	0f 94 c0             	sete   %al
  801d40:	0f b6 c0             	movzbl %al,%eax
}
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    

00801d45 <opencons>:

int
opencons(void)
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4e:	50                   	push   %eax
  801d4f:	e8 30 f2 ff ff       	call   800f84 <fd_alloc>
  801d54:	83 c4 10             	add    $0x10,%esp
		return r;
  801d57:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d59:	85 c0                	test   %eax,%eax
  801d5b:	78 3e                	js     801d9b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d5d:	83 ec 04             	sub    $0x4,%esp
  801d60:	68 07 04 00 00       	push   $0x407
  801d65:	ff 75 f4             	pushl  -0xc(%ebp)
  801d68:	6a 00                	push   $0x0
  801d6a:	e8 fd ef ff ff       	call   800d6c <sys_page_alloc>
  801d6f:	83 c4 10             	add    $0x10,%esp
		return r;
  801d72:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d74:	85 c0                	test   %eax,%eax
  801d76:	78 23                	js     801d9b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d78:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d81:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d86:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d8d:	83 ec 0c             	sub    $0xc,%esp
  801d90:	50                   	push   %eax
  801d91:	e8 c7 f1 ff ff       	call   800f5d <fd2num>
  801d96:	89 c2                	mov    %eax,%edx
  801d98:	83 c4 10             	add    $0x10,%esp
}
  801d9b:	89 d0                	mov    %edx,%eax
  801d9d:	c9                   	leave  
  801d9e:	c3                   	ret    

00801d9f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	56                   	push   %esi
  801da3:	53                   	push   %ebx
  801da4:	8b 75 08             	mov    0x8(%ebp),%esi
  801da7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801daa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801dad:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801daf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801db4:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801db7:	83 ec 0c             	sub    $0xc,%esp
  801dba:	50                   	push   %eax
  801dbb:	e8 5c f1 ff ff       	call   800f1c <sys_ipc_recv>
  801dc0:	83 c4 10             	add    $0x10,%esp
  801dc3:	85 c0                	test   %eax,%eax
  801dc5:	79 16                	jns    801ddd <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801dc7:	85 f6                	test   %esi,%esi
  801dc9:	74 06                	je     801dd1 <ipc_recv+0x32>
			*from_env_store = 0;
  801dcb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801dd1:	85 db                	test   %ebx,%ebx
  801dd3:	74 2c                	je     801e01 <ipc_recv+0x62>
			*perm_store = 0;
  801dd5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ddb:	eb 24                	jmp    801e01 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801ddd:	85 f6                	test   %esi,%esi
  801ddf:	74 0a                	je     801deb <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801de1:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801de6:	8b 40 74             	mov    0x74(%eax),%eax
  801de9:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801deb:	85 db                	test   %ebx,%ebx
  801ded:	74 0a                	je     801df9 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801def:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801df4:	8b 40 78             	mov    0x78(%eax),%eax
  801df7:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801df9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801dfe:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e01:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e04:	5b                   	pop    %ebx
  801e05:	5e                   	pop    %esi
  801e06:	5d                   	pop    %ebp
  801e07:	c3                   	ret    

00801e08 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e08:	55                   	push   %ebp
  801e09:	89 e5                	mov    %esp,%ebp
  801e0b:	57                   	push   %edi
  801e0c:	56                   	push   %esi
  801e0d:	53                   	push   %ebx
  801e0e:	83 ec 0c             	sub    $0xc,%esp
  801e11:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e14:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801e1a:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801e1c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e21:	0f 44 d8             	cmove  %eax,%ebx
  801e24:	eb 1e                	jmp    801e44 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801e26:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e29:	74 14                	je     801e3f <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801e2b:	83 ec 04             	sub    $0x4,%esp
  801e2e:	68 44 26 80 00       	push   $0x802644
  801e33:	6a 44                	push   $0x44
  801e35:	68 70 26 80 00       	push   $0x802670
  801e3a:	e8 a6 e3 ff ff       	call   8001e5 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801e3f:	e8 09 ef ff ff       	call   800d4d <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801e44:	ff 75 14             	pushl  0x14(%ebp)
  801e47:	53                   	push   %ebx
  801e48:	56                   	push   %esi
  801e49:	57                   	push   %edi
  801e4a:	e8 aa f0 ff ff       	call   800ef9 <sys_ipc_try_send>
  801e4f:	83 c4 10             	add    $0x10,%esp
  801e52:	85 c0                	test   %eax,%eax
  801e54:	78 d0                	js     801e26 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801e56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e59:	5b                   	pop    %ebx
  801e5a:	5e                   	pop    %esi
  801e5b:	5f                   	pop    %edi
  801e5c:	5d                   	pop    %ebp
  801e5d:	c3                   	ret    

00801e5e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e5e:	55                   	push   %ebp
  801e5f:	89 e5                	mov    %esp,%ebp
  801e61:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e69:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e6c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e72:	8b 52 50             	mov    0x50(%edx),%edx
  801e75:	39 ca                	cmp    %ecx,%edx
  801e77:	75 0d                	jne    801e86 <ipc_find_env+0x28>
			return envs[i].env_id;
  801e79:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e7c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e81:	8b 40 48             	mov    0x48(%eax),%eax
  801e84:	eb 0f                	jmp    801e95 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e86:	83 c0 01             	add    $0x1,%eax
  801e89:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e8e:	75 d9                	jne    801e69 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e95:	5d                   	pop    %ebp
  801e96:	c3                   	ret    

00801e97 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e97:	55                   	push   %ebp
  801e98:	89 e5                	mov    %esp,%ebp
  801e9a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e9d:	89 d0                	mov    %edx,%eax
  801e9f:	c1 e8 16             	shr    $0x16,%eax
  801ea2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ea9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eae:	f6 c1 01             	test   $0x1,%cl
  801eb1:	74 1d                	je     801ed0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801eb3:	c1 ea 0c             	shr    $0xc,%edx
  801eb6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ebd:	f6 c2 01             	test   $0x1,%dl
  801ec0:	74 0e                	je     801ed0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ec2:	c1 ea 0c             	shr    $0xc,%edx
  801ec5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ecc:	ef 
  801ecd:	0f b7 c0             	movzwl %ax,%eax
}
  801ed0:	5d                   	pop    %ebp
  801ed1:	c3                   	ret    
  801ed2:	66 90                	xchg   %ax,%ax
  801ed4:	66 90                	xchg   %ax,%ax
  801ed6:	66 90                	xchg   %ax,%ax
  801ed8:	66 90                	xchg   %ax,%ax
  801eda:	66 90                	xchg   %ax,%ax
  801edc:	66 90                	xchg   %ax,%ax
  801ede:	66 90                	xchg   %ax,%ax

00801ee0 <__udivdi3>:
  801ee0:	55                   	push   %ebp
  801ee1:	57                   	push   %edi
  801ee2:	56                   	push   %esi
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 1c             	sub    $0x1c,%esp
  801ee7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801eeb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801eef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ef3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ef7:	85 f6                	test   %esi,%esi
  801ef9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801efd:	89 ca                	mov    %ecx,%edx
  801eff:	89 f8                	mov    %edi,%eax
  801f01:	75 3d                	jne    801f40 <__udivdi3+0x60>
  801f03:	39 cf                	cmp    %ecx,%edi
  801f05:	0f 87 c5 00 00 00    	ja     801fd0 <__udivdi3+0xf0>
  801f0b:	85 ff                	test   %edi,%edi
  801f0d:	89 fd                	mov    %edi,%ebp
  801f0f:	75 0b                	jne    801f1c <__udivdi3+0x3c>
  801f11:	b8 01 00 00 00       	mov    $0x1,%eax
  801f16:	31 d2                	xor    %edx,%edx
  801f18:	f7 f7                	div    %edi
  801f1a:	89 c5                	mov    %eax,%ebp
  801f1c:	89 c8                	mov    %ecx,%eax
  801f1e:	31 d2                	xor    %edx,%edx
  801f20:	f7 f5                	div    %ebp
  801f22:	89 c1                	mov    %eax,%ecx
  801f24:	89 d8                	mov    %ebx,%eax
  801f26:	89 cf                	mov    %ecx,%edi
  801f28:	f7 f5                	div    %ebp
  801f2a:	89 c3                	mov    %eax,%ebx
  801f2c:	89 d8                	mov    %ebx,%eax
  801f2e:	89 fa                	mov    %edi,%edx
  801f30:	83 c4 1c             	add    $0x1c,%esp
  801f33:	5b                   	pop    %ebx
  801f34:	5e                   	pop    %esi
  801f35:	5f                   	pop    %edi
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    
  801f38:	90                   	nop
  801f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f40:	39 ce                	cmp    %ecx,%esi
  801f42:	77 74                	ja     801fb8 <__udivdi3+0xd8>
  801f44:	0f bd fe             	bsr    %esi,%edi
  801f47:	83 f7 1f             	xor    $0x1f,%edi
  801f4a:	0f 84 98 00 00 00    	je     801fe8 <__udivdi3+0x108>
  801f50:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f55:	89 f9                	mov    %edi,%ecx
  801f57:	89 c5                	mov    %eax,%ebp
  801f59:	29 fb                	sub    %edi,%ebx
  801f5b:	d3 e6                	shl    %cl,%esi
  801f5d:	89 d9                	mov    %ebx,%ecx
  801f5f:	d3 ed                	shr    %cl,%ebp
  801f61:	89 f9                	mov    %edi,%ecx
  801f63:	d3 e0                	shl    %cl,%eax
  801f65:	09 ee                	or     %ebp,%esi
  801f67:	89 d9                	mov    %ebx,%ecx
  801f69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f6d:	89 d5                	mov    %edx,%ebp
  801f6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f73:	d3 ed                	shr    %cl,%ebp
  801f75:	89 f9                	mov    %edi,%ecx
  801f77:	d3 e2                	shl    %cl,%edx
  801f79:	89 d9                	mov    %ebx,%ecx
  801f7b:	d3 e8                	shr    %cl,%eax
  801f7d:	09 c2                	or     %eax,%edx
  801f7f:	89 d0                	mov    %edx,%eax
  801f81:	89 ea                	mov    %ebp,%edx
  801f83:	f7 f6                	div    %esi
  801f85:	89 d5                	mov    %edx,%ebp
  801f87:	89 c3                	mov    %eax,%ebx
  801f89:	f7 64 24 0c          	mull   0xc(%esp)
  801f8d:	39 d5                	cmp    %edx,%ebp
  801f8f:	72 10                	jb     801fa1 <__udivdi3+0xc1>
  801f91:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f95:	89 f9                	mov    %edi,%ecx
  801f97:	d3 e6                	shl    %cl,%esi
  801f99:	39 c6                	cmp    %eax,%esi
  801f9b:	73 07                	jae    801fa4 <__udivdi3+0xc4>
  801f9d:	39 d5                	cmp    %edx,%ebp
  801f9f:	75 03                	jne    801fa4 <__udivdi3+0xc4>
  801fa1:	83 eb 01             	sub    $0x1,%ebx
  801fa4:	31 ff                	xor    %edi,%edi
  801fa6:	89 d8                	mov    %ebx,%eax
  801fa8:	89 fa                	mov    %edi,%edx
  801faa:	83 c4 1c             	add    $0x1c,%esp
  801fad:	5b                   	pop    %ebx
  801fae:	5e                   	pop    %esi
  801faf:	5f                   	pop    %edi
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    
  801fb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fb8:	31 ff                	xor    %edi,%edi
  801fba:	31 db                	xor    %ebx,%ebx
  801fbc:	89 d8                	mov    %ebx,%eax
  801fbe:	89 fa                	mov    %edi,%edx
  801fc0:	83 c4 1c             	add    $0x1c,%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
  801fc8:	90                   	nop
  801fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	89 d8                	mov    %ebx,%eax
  801fd2:	f7 f7                	div    %edi
  801fd4:	31 ff                	xor    %edi,%edi
  801fd6:	89 c3                	mov    %eax,%ebx
  801fd8:	89 d8                	mov    %ebx,%eax
  801fda:	89 fa                	mov    %edi,%edx
  801fdc:	83 c4 1c             	add    $0x1c,%esp
  801fdf:	5b                   	pop    %ebx
  801fe0:	5e                   	pop    %esi
  801fe1:	5f                   	pop    %edi
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    
  801fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fe8:	39 ce                	cmp    %ecx,%esi
  801fea:	72 0c                	jb     801ff8 <__udivdi3+0x118>
  801fec:	31 db                	xor    %ebx,%ebx
  801fee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ff2:	0f 87 34 ff ff ff    	ja     801f2c <__udivdi3+0x4c>
  801ff8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ffd:	e9 2a ff ff ff       	jmp    801f2c <__udivdi3+0x4c>
  802002:	66 90                	xchg   %ax,%ax
  802004:	66 90                	xchg   %ax,%ax
  802006:	66 90                	xchg   %ax,%ax
  802008:	66 90                	xchg   %ax,%ax
  80200a:	66 90                	xchg   %ax,%ax
  80200c:	66 90                	xchg   %ax,%ax
  80200e:	66 90                	xchg   %ax,%ax

00802010 <__umoddi3>:
  802010:	55                   	push   %ebp
  802011:	57                   	push   %edi
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	83 ec 1c             	sub    $0x1c,%esp
  802017:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80201b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80201f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802023:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802027:	85 d2                	test   %edx,%edx
  802029:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80202d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802031:	89 f3                	mov    %esi,%ebx
  802033:	89 3c 24             	mov    %edi,(%esp)
  802036:	89 74 24 04          	mov    %esi,0x4(%esp)
  80203a:	75 1c                	jne    802058 <__umoddi3+0x48>
  80203c:	39 f7                	cmp    %esi,%edi
  80203e:	76 50                	jbe    802090 <__umoddi3+0x80>
  802040:	89 c8                	mov    %ecx,%eax
  802042:	89 f2                	mov    %esi,%edx
  802044:	f7 f7                	div    %edi
  802046:	89 d0                	mov    %edx,%eax
  802048:	31 d2                	xor    %edx,%edx
  80204a:	83 c4 1c             	add    $0x1c,%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
  802052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802058:	39 f2                	cmp    %esi,%edx
  80205a:	89 d0                	mov    %edx,%eax
  80205c:	77 52                	ja     8020b0 <__umoddi3+0xa0>
  80205e:	0f bd ea             	bsr    %edx,%ebp
  802061:	83 f5 1f             	xor    $0x1f,%ebp
  802064:	75 5a                	jne    8020c0 <__umoddi3+0xb0>
  802066:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80206a:	0f 82 e0 00 00 00    	jb     802150 <__umoddi3+0x140>
  802070:	39 0c 24             	cmp    %ecx,(%esp)
  802073:	0f 86 d7 00 00 00    	jbe    802150 <__umoddi3+0x140>
  802079:	8b 44 24 08          	mov    0x8(%esp),%eax
  80207d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802081:	83 c4 1c             	add    $0x1c,%esp
  802084:	5b                   	pop    %ebx
  802085:	5e                   	pop    %esi
  802086:	5f                   	pop    %edi
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	85 ff                	test   %edi,%edi
  802092:	89 fd                	mov    %edi,%ebp
  802094:	75 0b                	jne    8020a1 <__umoddi3+0x91>
  802096:	b8 01 00 00 00       	mov    $0x1,%eax
  80209b:	31 d2                	xor    %edx,%edx
  80209d:	f7 f7                	div    %edi
  80209f:	89 c5                	mov    %eax,%ebp
  8020a1:	89 f0                	mov    %esi,%eax
  8020a3:	31 d2                	xor    %edx,%edx
  8020a5:	f7 f5                	div    %ebp
  8020a7:	89 c8                	mov    %ecx,%eax
  8020a9:	f7 f5                	div    %ebp
  8020ab:	89 d0                	mov    %edx,%eax
  8020ad:	eb 99                	jmp    802048 <__umoddi3+0x38>
  8020af:	90                   	nop
  8020b0:	89 c8                	mov    %ecx,%eax
  8020b2:	89 f2                	mov    %esi,%edx
  8020b4:	83 c4 1c             	add    $0x1c,%esp
  8020b7:	5b                   	pop    %ebx
  8020b8:	5e                   	pop    %esi
  8020b9:	5f                   	pop    %edi
  8020ba:	5d                   	pop    %ebp
  8020bb:	c3                   	ret    
  8020bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	8b 34 24             	mov    (%esp),%esi
  8020c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8020c8:	89 e9                	mov    %ebp,%ecx
  8020ca:	29 ef                	sub    %ebp,%edi
  8020cc:	d3 e0                	shl    %cl,%eax
  8020ce:	89 f9                	mov    %edi,%ecx
  8020d0:	89 f2                	mov    %esi,%edx
  8020d2:	d3 ea                	shr    %cl,%edx
  8020d4:	89 e9                	mov    %ebp,%ecx
  8020d6:	09 c2                	or     %eax,%edx
  8020d8:	89 d8                	mov    %ebx,%eax
  8020da:	89 14 24             	mov    %edx,(%esp)
  8020dd:	89 f2                	mov    %esi,%edx
  8020df:	d3 e2                	shl    %cl,%edx
  8020e1:	89 f9                	mov    %edi,%ecx
  8020e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020eb:	d3 e8                	shr    %cl,%eax
  8020ed:	89 e9                	mov    %ebp,%ecx
  8020ef:	89 c6                	mov    %eax,%esi
  8020f1:	d3 e3                	shl    %cl,%ebx
  8020f3:	89 f9                	mov    %edi,%ecx
  8020f5:	89 d0                	mov    %edx,%eax
  8020f7:	d3 e8                	shr    %cl,%eax
  8020f9:	89 e9                	mov    %ebp,%ecx
  8020fb:	09 d8                	or     %ebx,%eax
  8020fd:	89 d3                	mov    %edx,%ebx
  8020ff:	89 f2                	mov    %esi,%edx
  802101:	f7 34 24             	divl   (%esp)
  802104:	89 d6                	mov    %edx,%esi
  802106:	d3 e3                	shl    %cl,%ebx
  802108:	f7 64 24 04          	mull   0x4(%esp)
  80210c:	39 d6                	cmp    %edx,%esi
  80210e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802112:	89 d1                	mov    %edx,%ecx
  802114:	89 c3                	mov    %eax,%ebx
  802116:	72 08                	jb     802120 <__umoddi3+0x110>
  802118:	75 11                	jne    80212b <__umoddi3+0x11b>
  80211a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80211e:	73 0b                	jae    80212b <__umoddi3+0x11b>
  802120:	2b 44 24 04          	sub    0x4(%esp),%eax
  802124:	1b 14 24             	sbb    (%esp),%edx
  802127:	89 d1                	mov    %edx,%ecx
  802129:	89 c3                	mov    %eax,%ebx
  80212b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80212f:	29 da                	sub    %ebx,%edx
  802131:	19 ce                	sbb    %ecx,%esi
  802133:	89 f9                	mov    %edi,%ecx
  802135:	89 f0                	mov    %esi,%eax
  802137:	d3 e0                	shl    %cl,%eax
  802139:	89 e9                	mov    %ebp,%ecx
  80213b:	d3 ea                	shr    %cl,%edx
  80213d:	89 e9                	mov    %ebp,%ecx
  80213f:	d3 ee                	shr    %cl,%esi
  802141:	09 d0                	or     %edx,%eax
  802143:	89 f2                	mov    %esi,%edx
  802145:	83 c4 1c             	add    $0x1c,%esp
  802148:	5b                   	pop    %ebx
  802149:	5e                   	pop    %esi
  80214a:	5f                   	pop    %edi
  80214b:	5d                   	pop    %ebp
  80214c:	c3                   	ret    
  80214d:	8d 76 00             	lea    0x0(%esi),%esi
  802150:	29 f9                	sub    %edi,%ecx
  802152:	19 d6                	sbb    %edx,%esi
  802154:	89 74 24 04          	mov    %esi,0x4(%esp)
  802158:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80215c:	e9 18 ff ff ff       	jmp    802079 <__umoddi3+0x69>
