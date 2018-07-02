
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 02 01 00 00       	call   800133 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003b:	eb 2f                	jmp    80006c <cat+0x39>
		if ((r = write(1, buf, n)) != n)
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	53                   	push   %ebx
  800041:	68 20 40 80 00       	push   $0x804020
  800046:	6a 01                	push   $0x1
  800048:	e8 74 12 00 00       	call   8012c1 <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 20 21 80 00       	push   $0x802120
  800060:	6a 0d                	push   $0xd
  800062:	68 3b 21 80 00       	push   $0x80213b
  800067:	e8 27 01 00 00       	call   800193 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 20 00 00       	push   $0x2000
  800074:	68 20 40 80 00       	push   $0x804020
  800079:	56                   	push   %esi
  80007a:	e8 68 11 00 00       	call   8011e7 <read>
  80007f:	89 c3                	mov    %eax,%ebx
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	85 c0                	test   %eax,%eax
  800086:	7f b5                	jg     80003d <cat+0xa>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  800088:	85 c0                	test   %eax,%eax
  80008a:	79 18                	jns    8000a4 <cat+0x71>
		panic("error reading %s: %e", s, n);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	ff 75 0c             	pushl  0xc(%ebp)
  800093:	68 46 21 80 00       	push   $0x802146
  800098:	6a 0f                	push   $0xf
  80009a:	68 3b 21 80 00       	push   $0x80213b
  80009f:	e8 ef 00 00 00       	call   800193 <_panic>
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000b7:	c7 05 00 30 80 00 5b 	movl   $0x80215b,0x803000
  8000be:	21 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 5f 21 80 00       	push   $0x80215f
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 58 ff ff ff       	call   800033 <cat>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	eb 4b                	jmp    80012b <umain+0x80>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	6a 00                	push   $0x0
  8000e5:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000e8:	e8 cd 15 00 00       	call   8016ba <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 67 21 80 00       	push   $0x802167
  800102:	e8 51 17 00 00       	call   801858 <printf>
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	eb 17                	jmp    800123 <umain+0x78>
			else {
				cat(f, argv[i]);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800112:	50                   	push   %eax
  800113:	e8 1b ff ff ff       	call   800033 <cat>
				close(f);
  800118:	89 34 24             	mov    %esi,(%esp)
  80011b:	e8 8b 0f 00 00       	call   8010ab <close>
  800120:	83 c4 10             	add    $0x10,%esp

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800123:	83 c3 01             	add    $0x1,%ebx
  800126:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800129:	7c b5                	jl     8000e0 <umain+0x35>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80012b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80013e:	e8 99 0b 00 00       	call   800cdc <sys_getenvid>
  800143:	25 ff 03 00 00       	and    $0x3ff,%eax
  800148:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800150:	a3 20 60 80 00       	mov    %eax,0x806020
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800155:	85 db                	test   %ebx,%ebx
  800157:	7e 07                	jle    800160 <libmain+0x2d>
		binaryname = argv[0];
  800159:	8b 06                	mov    (%esi),%eax
  80015b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	e8 41 ff ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  80016a:	e8 0a 00 00 00       	call   800179 <exit>
}
  80016f:	83 c4 10             	add    $0x10,%esp
  800172:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80017f:	e8 52 0f 00 00       	call   8010d6 <close_all>
	sys_env_destroy(0);
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	6a 00                	push   $0x0
  800189:	e8 0d 0b 00 00       	call   800c9b <sys_env_destroy>
}
  80018e:	83 c4 10             	add    $0x10,%esp
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	56                   	push   %esi
  800197:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800198:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a1:	e8 36 0b 00 00       	call   800cdc <sys_getenvid>
  8001a6:	83 ec 0c             	sub    $0xc,%esp
  8001a9:	ff 75 0c             	pushl  0xc(%ebp)
  8001ac:	ff 75 08             	pushl  0x8(%ebp)
  8001af:	56                   	push   %esi
  8001b0:	50                   	push   %eax
  8001b1:	68 84 21 80 00       	push   $0x802184
  8001b6:	e8 b1 00 00 00       	call   80026c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	53                   	push   %ebx
  8001bf:	ff 75 10             	pushl  0x10(%ebp)
  8001c2:	e8 54 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001c7:	c7 04 24 d1 25 80 00 	movl   $0x8025d1,(%esp)
  8001ce:	e8 99 00 00 00       	call   80026c <cprintf>
  8001d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d6:	cc                   	int3   
  8001d7:	eb fd                	jmp    8001d6 <_panic+0x43>

008001d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 04             	sub    $0x4,%esp
  8001e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e3:	8b 13                	mov    (%ebx),%edx
  8001e5:	8d 42 01             	lea    0x1(%edx),%eax
  8001e8:	89 03                	mov    %eax,(%ebx)
  8001ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f6:	75 1a                	jne    800212 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f8:	83 ec 08             	sub    $0x8,%esp
  8001fb:	68 ff 00 00 00       	push   $0xff
  800200:	8d 43 08             	lea    0x8(%ebx),%eax
  800203:	50                   	push   %eax
  800204:	e8 55 0a 00 00       	call   800c5e <sys_cputs>
		b->idx = 0;
  800209:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80020f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800212:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800216:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800219:	c9                   	leave  
  80021a:	c3                   	ret    

0080021b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800224:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022b:	00 00 00 
	b.cnt = 0;
  80022e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800235:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800238:	ff 75 0c             	pushl  0xc(%ebp)
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800244:	50                   	push   %eax
  800245:	68 d9 01 80 00       	push   $0x8001d9
  80024a:	e8 54 01 00 00       	call   8003a3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024f:	83 c4 08             	add    $0x8,%esp
  800252:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800258:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025e:	50                   	push   %eax
  80025f:	e8 fa 09 00 00       	call   800c5e <sys_cputs>

	return b.cnt;
}
  800264:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800272:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800275:	50                   	push   %eax
  800276:	ff 75 08             	pushl  0x8(%ebp)
  800279:	e8 9d ff ff ff       	call   80021b <vcprintf>
	va_end(ap);

	return cnt;
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 1c             	sub    $0x1c,%esp
  800289:	89 c7                	mov    %eax,%edi
  80028b:	89 d6                	mov    %edx,%esi
  80028d:	8b 45 08             	mov    0x8(%ebp),%eax
  800290:	8b 55 0c             	mov    0xc(%ebp),%edx
  800293:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800296:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800299:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a7:	39 d3                	cmp    %edx,%ebx
  8002a9:	72 05                	jb     8002b0 <printnum+0x30>
  8002ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ae:	77 45                	ja     8002f5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b0:	83 ec 0c             	sub    $0xc,%esp
  8002b3:	ff 75 18             	pushl  0x18(%ebp)
  8002b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bc:	53                   	push   %ebx
  8002bd:	ff 75 10             	pushl  0x10(%ebp)
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cf:	e8 ac 1b 00 00       	call   801e80 <__udivdi3>
  8002d4:	83 c4 18             	add    $0x18,%esp
  8002d7:	52                   	push   %edx
  8002d8:	50                   	push   %eax
  8002d9:	89 f2                	mov    %esi,%edx
  8002db:	89 f8                	mov    %edi,%eax
  8002dd:	e8 9e ff ff ff       	call   800280 <printnum>
  8002e2:	83 c4 20             	add    $0x20,%esp
  8002e5:	eb 18                	jmp    8002ff <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	56                   	push   %esi
  8002eb:	ff 75 18             	pushl  0x18(%ebp)
  8002ee:	ff d7                	call   *%edi
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	eb 03                	jmp    8002f8 <printnum+0x78>
  8002f5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f8:	83 eb 01             	sub    $0x1,%ebx
  8002fb:	85 db                	test   %ebx,%ebx
  8002fd:	7f e8                	jg     8002e7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	83 ec 04             	sub    $0x4,%esp
  800306:	ff 75 e4             	pushl  -0x1c(%ebp)
  800309:	ff 75 e0             	pushl  -0x20(%ebp)
  80030c:	ff 75 dc             	pushl  -0x24(%ebp)
  80030f:	ff 75 d8             	pushl  -0x28(%ebp)
  800312:	e8 99 1c 00 00       	call   801fb0 <__umoddi3>
  800317:	83 c4 14             	add    $0x14,%esp
  80031a:	0f be 80 a7 21 80 00 	movsbl 0x8021a7(%eax),%eax
  800321:	50                   	push   %eax
  800322:	ff d7                	call   *%edi
}
  800324:	83 c4 10             	add    $0x10,%esp
  800327:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032a:	5b                   	pop    %ebx
  80032b:	5e                   	pop    %esi
  80032c:	5f                   	pop    %edi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800332:	83 fa 01             	cmp    $0x1,%edx
  800335:	7e 0e                	jle    800345 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800337:	8b 10                	mov    (%eax),%edx
  800339:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033c:	89 08                	mov    %ecx,(%eax)
  80033e:	8b 02                	mov    (%edx),%eax
  800340:	8b 52 04             	mov    0x4(%edx),%edx
  800343:	eb 22                	jmp    800367 <getuint+0x38>
	else if (lflag)
  800345:	85 d2                	test   %edx,%edx
  800347:	74 10                	je     800359 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800349:	8b 10                	mov    (%eax),%edx
  80034b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034e:	89 08                	mov    %ecx,(%eax)
  800350:	8b 02                	mov    (%edx),%eax
  800352:	ba 00 00 00 00       	mov    $0x0,%edx
  800357:	eb 0e                	jmp    800367 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035e:	89 08                	mov    %ecx,(%eax)
  800360:	8b 02                	mov    (%edx),%eax
  800362:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    

00800369 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800373:	8b 10                	mov    (%eax),%edx
  800375:	3b 50 04             	cmp    0x4(%eax),%edx
  800378:	73 0a                	jae    800384 <sprintputch+0x1b>
		*b->buf++ = ch;
  80037a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037d:	89 08                	mov    %ecx,(%eax)
  80037f:	8b 45 08             	mov    0x8(%ebp),%eax
  800382:	88 02                	mov    %al,(%edx)
}
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80038c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038f:	50                   	push   %eax
  800390:	ff 75 10             	pushl  0x10(%ebp)
  800393:	ff 75 0c             	pushl  0xc(%ebp)
  800396:	ff 75 08             	pushl  0x8(%ebp)
  800399:	e8 05 00 00 00       	call   8003a3 <vprintfmt>
	va_end(ap);
}
  80039e:	83 c4 10             	add    $0x10,%esp
  8003a1:	c9                   	leave  
  8003a2:	c3                   	ret    

008003a3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	57                   	push   %edi
  8003a7:	56                   	push   %esi
  8003a8:	53                   	push   %ebx
  8003a9:	83 ec 2c             	sub    $0x2c,%esp
  8003ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8003af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b5:	eb 12                	jmp    8003c9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b7:	85 c0                	test   %eax,%eax
  8003b9:	0f 84 38 04 00 00    	je     8007f7 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8003bf:	83 ec 08             	sub    $0x8,%esp
  8003c2:	53                   	push   %ebx
  8003c3:	50                   	push   %eax
  8003c4:	ff d6                	call   *%esi
  8003c6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c9:	83 c7 01             	add    $0x1,%edi
  8003cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003d0:	83 f8 25             	cmp    $0x25,%eax
  8003d3:	75 e2                	jne    8003b7 <vprintfmt+0x14>
  8003d5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003d9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003e0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f3:	eb 07                	jmp    8003fc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8d 47 01             	lea    0x1(%edi),%eax
  8003ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800402:	0f b6 07             	movzbl (%edi),%eax
  800405:	0f b6 c8             	movzbl %al,%ecx
  800408:	83 e8 23             	sub    $0x23,%eax
  80040b:	3c 55                	cmp    $0x55,%al
  80040d:	0f 87 c9 03 00 00    	ja     8007dc <vprintfmt+0x439>
  800413:	0f b6 c0             	movzbl %al,%eax
  800416:	ff 24 85 e0 22 80 00 	jmp    *0x8022e0(,%eax,4)
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800420:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800424:	eb d6                	jmp    8003fc <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  800426:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  80042d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  800433:	eb 94                	jmp    8003c9 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  800435:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  80043c:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  800442:	eb 85                	jmp    8003c9 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  800444:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  80044b:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  800451:	e9 73 ff ff ff       	jmp    8003c9 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  800456:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  80045d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  800463:	e9 61 ff ff ff       	jmp    8003c9 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  800468:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  80046f:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  800475:	e9 4f ff ff ff       	jmp    8003c9 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80047a:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800481:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  800487:	e9 3d ff ff ff       	jmp    8003c9 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  80048c:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  800493:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  800499:	e9 2b ff ff ff       	jmp    8003c9 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  80049e:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  8004a5:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8004ab:	e9 19 ff ff ff       	jmp    8003c9 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  8004b0:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  8004b7:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8004bd:	e9 07 ff ff ff       	jmp    8003c9 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8004c2:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  8004c9:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8004cf:	e9 f5 fe ff ff       	jmp    8003c9 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004dc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004df:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004e2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004e6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004e9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004ec:	83 fa 09             	cmp    $0x9,%edx
  8004ef:	77 3f                	ja     800530 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f4:	eb e9                	jmp    8004df <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f9:	8d 48 04             	lea    0x4(%eax),%ecx
  8004fc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ff:	8b 00                	mov    (%eax),%eax
  800501:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800507:	eb 2d                	jmp    800536 <vprintfmt+0x193>
  800509:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050c:	85 c0                	test   %eax,%eax
  80050e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800513:	0f 49 c8             	cmovns %eax,%ecx
  800516:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800519:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051c:	e9 db fe ff ff       	jmp    8003fc <vprintfmt+0x59>
  800521:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800524:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80052b:	e9 cc fe ff ff       	jmp    8003fc <vprintfmt+0x59>
  800530:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800533:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800536:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80053a:	0f 89 bc fe ff ff    	jns    8003fc <vprintfmt+0x59>
				width = precision, precision = -1;
  800540:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800543:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800546:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80054d:	e9 aa fe ff ff       	jmp    8003fc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800552:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800555:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800558:	e9 9f fe ff ff       	jmp    8003fc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8d 50 04             	lea    0x4(%eax),%edx
  800563:	89 55 14             	mov    %edx,0x14(%ebp)
  800566:	83 ec 08             	sub    $0x8,%esp
  800569:	53                   	push   %ebx
  80056a:	ff 30                	pushl  (%eax)
  80056c:	ff d6                	call   *%esi
			break;
  80056e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800574:	e9 50 fe ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 50 04             	lea    0x4(%eax),%edx
  80057f:	89 55 14             	mov    %edx,0x14(%ebp)
  800582:	8b 00                	mov    (%eax),%eax
  800584:	99                   	cltd   
  800585:	31 d0                	xor    %edx,%eax
  800587:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800589:	83 f8 0f             	cmp    $0xf,%eax
  80058c:	7f 0b                	jg     800599 <vprintfmt+0x1f6>
  80058e:	8b 14 85 40 24 80 00 	mov    0x802440(,%eax,4),%edx
  800595:	85 d2                	test   %edx,%edx
  800597:	75 18                	jne    8005b1 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  800599:	50                   	push   %eax
  80059a:	68 bf 21 80 00       	push   $0x8021bf
  80059f:	53                   	push   %ebx
  8005a0:	56                   	push   %esi
  8005a1:	e8 e0 fd ff ff       	call   800386 <printfmt>
  8005a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005ac:	e9 18 fe ff ff       	jmp    8003c9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005b1:	52                   	push   %edx
  8005b2:	68 71 25 80 00       	push   $0x802571
  8005b7:	53                   	push   %ebx
  8005b8:	56                   	push   %esi
  8005b9:	e8 c8 fd ff ff       	call   800386 <printfmt>
  8005be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c4:	e9 00 fe ff ff       	jmp    8003c9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8d 50 04             	lea    0x4(%eax),%edx
  8005cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005d4:	85 ff                	test   %edi,%edi
  8005d6:	b8 b8 21 80 00       	mov    $0x8021b8,%eax
  8005db:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e2:	0f 8e 94 00 00 00    	jle    80067c <vprintfmt+0x2d9>
  8005e8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005ec:	0f 84 98 00 00 00    	je     80068a <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f2:	83 ec 08             	sub    $0x8,%esp
  8005f5:	ff 75 d0             	pushl  -0x30(%ebp)
  8005f8:	57                   	push   %edi
  8005f9:	e8 81 02 00 00       	call   80087f <strnlen>
  8005fe:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800601:	29 c1                	sub    %eax,%ecx
  800603:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800606:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800609:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80060d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800610:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800613:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800615:	eb 0f                	jmp    800626 <vprintfmt+0x283>
					putch(padc, putdat);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	ff 75 e0             	pushl  -0x20(%ebp)
  80061e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800620:	83 ef 01             	sub    $0x1,%edi
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	85 ff                	test   %edi,%edi
  800628:	7f ed                	jg     800617 <vprintfmt+0x274>
  80062a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80062d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800630:	85 c9                	test   %ecx,%ecx
  800632:	b8 00 00 00 00       	mov    $0x0,%eax
  800637:	0f 49 c1             	cmovns %ecx,%eax
  80063a:	29 c1                	sub    %eax,%ecx
  80063c:	89 75 08             	mov    %esi,0x8(%ebp)
  80063f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800642:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800645:	89 cb                	mov    %ecx,%ebx
  800647:	eb 4d                	jmp    800696 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800649:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064d:	74 1b                	je     80066a <vprintfmt+0x2c7>
  80064f:	0f be c0             	movsbl %al,%eax
  800652:	83 e8 20             	sub    $0x20,%eax
  800655:	83 f8 5e             	cmp    $0x5e,%eax
  800658:	76 10                	jbe    80066a <vprintfmt+0x2c7>
					putch('?', putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	ff 75 0c             	pushl  0xc(%ebp)
  800660:	6a 3f                	push   $0x3f
  800662:	ff 55 08             	call   *0x8(%ebp)
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	eb 0d                	jmp    800677 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	ff 75 0c             	pushl  0xc(%ebp)
  800670:	52                   	push   %edx
  800671:	ff 55 08             	call   *0x8(%ebp)
  800674:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800677:	83 eb 01             	sub    $0x1,%ebx
  80067a:	eb 1a                	jmp    800696 <vprintfmt+0x2f3>
  80067c:	89 75 08             	mov    %esi,0x8(%ebp)
  80067f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800682:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800685:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800688:	eb 0c                	jmp    800696 <vprintfmt+0x2f3>
  80068a:	89 75 08             	mov    %esi,0x8(%ebp)
  80068d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800690:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800693:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800696:	83 c7 01             	add    $0x1,%edi
  800699:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069d:	0f be d0             	movsbl %al,%edx
  8006a0:	85 d2                	test   %edx,%edx
  8006a2:	74 23                	je     8006c7 <vprintfmt+0x324>
  8006a4:	85 f6                	test   %esi,%esi
  8006a6:	78 a1                	js     800649 <vprintfmt+0x2a6>
  8006a8:	83 ee 01             	sub    $0x1,%esi
  8006ab:	79 9c                	jns    800649 <vprintfmt+0x2a6>
  8006ad:	89 df                	mov    %ebx,%edi
  8006af:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b5:	eb 18                	jmp    8006cf <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	53                   	push   %ebx
  8006bb:	6a 20                	push   $0x20
  8006bd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bf:	83 ef 01             	sub    $0x1,%edi
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	eb 08                	jmp    8006cf <vprintfmt+0x32c>
  8006c7:	89 df                	mov    %ebx,%edi
  8006c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8006cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006cf:	85 ff                	test   %edi,%edi
  8006d1:	7f e4                	jg     8006b7 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d6:	e9 ee fc ff ff       	jmp    8003c9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006db:	83 fa 01             	cmp    $0x1,%edx
  8006de:	7e 16                	jle    8006f6 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8d 50 08             	lea    0x8(%eax),%edx
  8006e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e9:	8b 50 04             	mov    0x4(%eax),%edx
  8006ec:	8b 00                	mov    (%eax),%eax
  8006ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f4:	eb 32                	jmp    800728 <vprintfmt+0x385>
	else if (lflag)
  8006f6:	85 d2                	test   %edx,%edx
  8006f8:	74 18                	je     800712 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8d 50 04             	lea    0x4(%eax),%edx
  800700:	89 55 14             	mov    %edx,0x14(%ebp)
  800703:	8b 00                	mov    (%eax),%eax
  800705:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800708:	89 c1                	mov    %eax,%ecx
  80070a:	c1 f9 1f             	sar    $0x1f,%ecx
  80070d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800710:	eb 16                	jmp    800728 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8d 50 04             	lea    0x4(%eax),%edx
  800718:	89 55 14             	mov    %edx,0x14(%ebp)
  80071b:	8b 00                	mov    (%eax),%eax
  80071d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800720:	89 c1                	mov    %eax,%ecx
  800722:	c1 f9 1f             	sar    $0x1f,%ecx
  800725:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800728:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80072b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80072e:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800733:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800737:	79 6f                	jns    8007a8 <vprintfmt+0x405>
				putch('-', putdat);
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	53                   	push   %ebx
  80073d:	6a 2d                	push   $0x2d
  80073f:	ff d6                	call   *%esi
				num = -(long long) num;
  800741:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800744:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800747:	f7 d8                	neg    %eax
  800749:	83 d2 00             	adc    $0x0,%edx
  80074c:	f7 da                	neg    %edx
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	eb 55                	jmp    8007a8 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800753:	8d 45 14             	lea    0x14(%ebp),%eax
  800756:	e8 d4 fb ff ff       	call   80032f <getuint>
			base = 10;
  80075b:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800760:	eb 46                	jmp    8007a8 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800762:	8d 45 14             	lea    0x14(%ebp),%eax
  800765:	e8 c5 fb ff ff       	call   80032f <getuint>
			base = 8;
  80076a:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  80076f:	eb 37                	jmp    8007a8 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800771:	83 ec 08             	sub    $0x8,%esp
  800774:	53                   	push   %ebx
  800775:	6a 30                	push   $0x30
  800777:	ff d6                	call   *%esi
			putch('x', putdat);
  800779:	83 c4 08             	add    $0x8,%esp
  80077c:	53                   	push   %ebx
  80077d:	6a 78                	push   $0x78
  80077f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800781:	8b 45 14             	mov    0x14(%ebp),%eax
  800784:	8d 50 04             	lea    0x4(%eax),%edx
  800787:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80078a:	8b 00                	mov    (%eax),%eax
  80078c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800791:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800794:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800799:	eb 0d                	jmp    8007a8 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80079b:	8d 45 14             	lea    0x14(%ebp),%eax
  80079e:	e8 8c fb ff ff       	call   80032f <getuint>
			base = 16;
  8007a3:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a8:	83 ec 0c             	sub    $0xc,%esp
  8007ab:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8007af:	51                   	push   %ecx
  8007b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8007b3:	57                   	push   %edi
  8007b4:	52                   	push   %edx
  8007b5:	50                   	push   %eax
  8007b6:	89 da                	mov    %ebx,%edx
  8007b8:	89 f0                	mov    %esi,%eax
  8007ba:	e8 c1 fa ff ff       	call   800280 <printnum>
			break;
  8007bf:	83 c4 20             	add    $0x20,%esp
  8007c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c5:	e9 ff fb ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ca:	83 ec 08             	sub    $0x8,%esp
  8007cd:	53                   	push   %ebx
  8007ce:	51                   	push   %ecx
  8007cf:	ff d6                	call   *%esi
			break;
  8007d1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d7:	e9 ed fb ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	53                   	push   %ebx
  8007e0:	6a 25                	push   $0x25
  8007e2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	eb 03                	jmp    8007ec <vprintfmt+0x449>
  8007e9:	83 ef 01             	sub    $0x1,%edi
  8007ec:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007f0:	75 f7                	jne    8007e9 <vprintfmt+0x446>
  8007f2:	e9 d2 fb ff ff       	jmp    8003c9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007fa:	5b                   	pop    %ebx
  8007fb:	5e                   	pop    %esi
  8007fc:	5f                   	pop    %edi
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	83 ec 18             	sub    $0x18,%esp
  800805:	8b 45 08             	mov    0x8(%ebp),%eax
  800808:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800812:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800815:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081c:	85 c0                	test   %eax,%eax
  80081e:	74 26                	je     800846 <vsnprintf+0x47>
  800820:	85 d2                	test   %edx,%edx
  800822:	7e 22                	jle    800846 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800824:	ff 75 14             	pushl  0x14(%ebp)
  800827:	ff 75 10             	pushl  0x10(%ebp)
  80082a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082d:	50                   	push   %eax
  80082e:	68 69 03 80 00       	push   $0x800369
  800833:	e8 6b fb ff ff       	call   8003a3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800838:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800841:	83 c4 10             	add    $0x10,%esp
  800844:	eb 05                	jmp    80084b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800846:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80084b:	c9                   	leave  
  80084c:	c3                   	ret    

0080084d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800853:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800856:	50                   	push   %eax
  800857:	ff 75 10             	pushl  0x10(%ebp)
  80085a:	ff 75 0c             	pushl  0xc(%ebp)
  80085d:	ff 75 08             	pushl  0x8(%ebp)
  800860:	e8 9a ff ff ff       	call   8007ff <vsnprintf>
	va_end(ap);

	return rc;
}
  800865:	c9                   	leave  
  800866:	c3                   	ret    

00800867 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80086d:	b8 00 00 00 00       	mov    $0x0,%eax
  800872:	eb 03                	jmp    800877 <strlen+0x10>
		n++;
  800874:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800877:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80087b:	75 f7                	jne    800874 <strlen+0xd>
		n++;
	return n;
}
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800885:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800888:	ba 00 00 00 00       	mov    $0x0,%edx
  80088d:	eb 03                	jmp    800892 <strnlen+0x13>
		n++;
  80088f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800892:	39 c2                	cmp    %eax,%edx
  800894:	74 08                	je     80089e <strnlen+0x1f>
  800896:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80089a:	75 f3                	jne    80088f <strnlen+0x10>
  80089c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	53                   	push   %ebx
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008aa:	89 c2                	mov    %eax,%edx
  8008ac:	83 c2 01             	add    $0x1,%edx
  8008af:	83 c1 01             	add    $0x1,%ecx
  8008b2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008b6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008b9:	84 db                	test   %bl,%bl
  8008bb:	75 ef                	jne    8008ac <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008bd:	5b                   	pop    %ebx
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	53                   	push   %ebx
  8008c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c7:	53                   	push   %ebx
  8008c8:	e8 9a ff ff ff       	call   800867 <strlen>
  8008cd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008d0:	ff 75 0c             	pushl  0xc(%ebp)
  8008d3:	01 d8                	add    %ebx,%eax
  8008d5:	50                   	push   %eax
  8008d6:	e8 c5 ff ff ff       	call   8008a0 <strcpy>
	return dst;
}
  8008db:	89 d8                	mov    %ebx,%eax
  8008dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e0:	c9                   	leave  
  8008e1:	c3                   	ret    

008008e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ed:	89 f3                	mov    %esi,%ebx
  8008ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f2:	89 f2                	mov    %esi,%edx
  8008f4:	eb 0f                	jmp    800905 <strncpy+0x23>
		*dst++ = *src;
  8008f6:	83 c2 01             	add    $0x1,%edx
  8008f9:	0f b6 01             	movzbl (%ecx),%eax
  8008fc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ff:	80 39 01             	cmpb   $0x1,(%ecx)
  800902:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800905:	39 da                	cmp    %ebx,%edx
  800907:	75 ed                	jne    8008f6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800909:	89 f0                	mov    %esi,%eax
  80090b:	5b                   	pop    %ebx
  80090c:	5e                   	pop    %esi
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	56                   	push   %esi
  800913:	53                   	push   %ebx
  800914:	8b 75 08             	mov    0x8(%ebp),%esi
  800917:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091a:	8b 55 10             	mov    0x10(%ebp),%edx
  80091d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80091f:	85 d2                	test   %edx,%edx
  800921:	74 21                	je     800944 <strlcpy+0x35>
  800923:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800927:	89 f2                	mov    %esi,%edx
  800929:	eb 09                	jmp    800934 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80092b:	83 c2 01             	add    $0x1,%edx
  80092e:	83 c1 01             	add    $0x1,%ecx
  800931:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800934:	39 c2                	cmp    %eax,%edx
  800936:	74 09                	je     800941 <strlcpy+0x32>
  800938:	0f b6 19             	movzbl (%ecx),%ebx
  80093b:	84 db                	test   %bl,%bl
  80093d:	75 ec                	jne    80092b <strlcpy+0x1c>
  80093f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800941:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800944:	29 f0                	sub    %esi,%eax
}
  800946:	5b                   	pop    %ebx
  800947:	5e                   	pop    %esi
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800950:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800953:	eb 06                	jmp    80095b <strcmp+0x11>
		p++, q++;
  800955:	83 c1 01             	add    $0x1,%ecx
  800958:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80095b:	0f b6 01             	movzbl (%ecx),%eax
  80095e:	84 c0                	test   %al,%al
  800960:	74 04                	je     800966 <strcmp+0x1c>
  800962:	3a 02                	cmp    (%edx),%al
  800964:	74 ef                	je     800955 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800966:	0f b6 c0             	movzbl %al,%eax
  800969:	0f b6 12             	movzbl (%edx),%edx
  80096c:	29 d0                	sub    %edx,%eax
}
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	53                   	push   %ebx
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097a:	89 c3                	mov    %eax,%ebx
  80097c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80097f:	eb 06                	jmp    800987 <strncmp+0x17>
		n--, p++, q++;
  800981:	83 c0 01             	add    $0x1,%eax
  800984:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800987:	39 d8                	cmp    %ebx,%eax
  800989:	74 15                	je     8009a0 <strncmp+0x30>
  80098b:	0f b6 08             	movzbl (%eax),%ecx
  80098e:	84 c9                	test   %cl,%cl
  800990:	74 04                	je     800996 <strncmp+0x26>
  800992:	3a 0a                	cmp    (%edx),%cl
  800994:	74 eb                	je     800981 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800996:	0f b6 00             	movzbl (%eax),%eax
  800999:	0f b6 12             	movzbl (%edx),%edx
  80099c:	29 d0                	sub    %edx,%eax
  80099e:	eb 05                	jmp    8009a5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a5:	5b                   	pop    %ebx
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b2:	eb 07                	jmp    8009bb <strchr+0x13>
		if (*s == c)
  8009b4:	38 ca                	cmp    %cl,%dl
  8009b6:	74 0f                	je     8009c7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009b8:	83 c0 01             	add    $0x1,%eax
  8009bb:	0f b6 10             	movzbl (%eax),%edx
  8009be:	84 d2                	test   %dl,%dl
  8009c0:	75 f2                	jne    8009b4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d3:	eb 03                	jmp    8009d8 <strfind+0xf>
  8009d5:	83 c0 01             	add    $0x1,%eax
  8009d8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009db:	38 ca                	cmp    %cl,%dl
  8009dd:	74 04                	je     8009e3 <strfind+0x1a>
  8009df:	84 d2                	test   %dl,%dl
  8009e1:	75 f2                	jne    8009d5 <strfind+0xc>
			break;
	return (char *) s;
}
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	57                   	push   %edi
  8009e9:	56                   	push   %esi
  8009ea:	53                   	push   %ebx
  8009eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f1:	85 c9                	test   %ecx,%ecx
  8009f3:	74 36                	je     800a2b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fb:	75 28                	jne    800a25 <memset+0x40>
  8009fd:	f6 c1 03             	test   $0x3,%cl
  800a00:	75 23                	jne    800a25 <memset+0x40>
		c &= 0xFF;
  800a02:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a06:	89 d3                	mov    %edx,%ebx
  800a08:	c1 e3 08             	shl    $0x8,%ebx
  800a0b:	89 d6                	mov    %edx,%esi
  800a0d:	c1 e6 18             	shl    $0x18,%esi
  800a10:	89 d0                	mov    %edx,%eax
  800a12:	c1 e0 10             	shl    $0x10,%eax
  800a15:	09 f0                	or     %esi,%eax
  800a17:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a19:	89 d8                	mov    %ebx,%eax
  800a1b:	09 d0                	or     %edx,%eax
  800a1d:	c1 e9 02             	shr    $0x2,%ecx
  800a20:	fc                   	cld    
  800a21:	f3 ab                	rep stos %eax,%es:(%edi)
  800a23:	eb 06                	jmp    800a2b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a28:	fc                   	cld    
  800a29:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2b:	89 f8                	mov    %edi,%eax
  800a2d:	5b                   	pop    %ebx
  800a2e:	5e                   	pop    %esi
  800a2f:	5f                   	pop    %edi
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	57                   	push   %edi
  800a36:	56                   	push   %esi
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a40:	39 c6                	cmp    %eax,%esi
  800a42:	73 35                	jae    800a79 <memmove+0x47>
  800a44:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a47:	39 d0                	cmp    %edx,%eax
  800a49:	73 2e                	jae    800a79 <memmove+0x47>
		s += n;
		d += n;
  800a4b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4e:	89 d6                	mov    %edx,%esi
  800a50:	09 fe                	or     %edi,%esi
  800a52:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a58:	75 13                	jne    800a6d <memmove+0x3b>
  800a5a:	f6 c1 03             	test   $0x3,%cl
  800a5d:	75 0e                	jne    800a6d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a5f:	83 ef 04             	sub    $0x4,%edi
  800a62:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a65:	c1 e9 02             	shr    $0x2,%ecx
  800a68:	fd                   	std    
  800a69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6b:	eb 09                	jmp    800a76 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a6d:	83 ef 01             	sub    $0x1,%edi
  800a70:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a73:	fd                   	std    
  800a74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a76:	fc                   	cld    
  800a77:	eb 1d                	jmp    800a96 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a79:	89 f2                	mov    %esi,%edx
  800a7b:	09 c2                	or     %eax,%edx
  800a7d:	f6 c2 03             	test   $0x3,%dl
  800a80:	75 0f                	jne    800a91 <memmove+0x5f>
  800a82:	f6 c1 03             	test   $0x3,%cl
  800a85:	75 0a                	jne    800a91 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a87:	c1 e9 02             	shr    $0x2,%ecx
  800a8a:	89 c7                	mov    %eax,%edi
  800a8c:	fc                   	cld    
  800a8d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8f:	eb 05                	jmp    800a96 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a91:	89 c7                	mov    %eax,%edi
  800a93:	fc                   	cld    
  800a94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a9d:	ff 75 10             	pushl  0x10(%ebp)
  800aa0:	ff 75 0c             	pushl  0xc(%ebp)
  800aa3:	ff 75 08             	pushl  0x8(%ebp)
  800aa6:	e8 87 ff ff ff       	call   800a32 <memmove>
}
  800aab:	c9                   	leave  
  800aac:	c3                   	ret    

00800aad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab8:	89 c6                	mov    %eax,%esi
  800aba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abd:	eb 1a                	jmp    800ad9 <memcmp+0x2c>
		if (*s1 != *s2)
  800abf:	0f b6 08             	movzbl (%eax),%ecx
  800ac2:	0f b6 1a             	movzbl (%edx),%ebx
  800ac5:	38 d9                	cmp    %bl,%cl
  800ac7:	74 0a                	je     800ad3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ac9:	0f b6 c1             	movzbl %cl,%eax
  800acc:	0f b6 db             	movzbl %bl,%ebx
  800acf:	29 d8                	sub    %ebx,%eax
  800ad1:	eb 0f                	jmp    800ae2 <memcmp+0x35>
		s1++, s2++;
  800ad3:	83 c0 01             	add    $0x1,%eax
  800ad6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad9:	39 f0                	cmp    %esi,%eax
  800adb:	75 e2                	jne    800abf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800add:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	53                   	push   %ebx
  800aea:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aed:	89 c1                	mov    %eax,%ecx
  800aef:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800af2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af6:	eb 0a                	jmp    800b02 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af8:	0f b6 10             	movzbl (%eax),%edx
  800afb:	39 da                	cmp    %ebx,%edx
  800afd:	74 07                	je     800b06 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aff:	83 c0 01             	add    $0x1,%eax
  800b02:	39 c8                	cmp    %ecx,%eax
  800b04:	72 f2                	jb     800af8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b06:	5b                   	pop    %ebx
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	57                   	push   %edi
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
  800b0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b12:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b15:	eb 03                	jmp    800b1a <strtol+0x11>
		s++;
  800b17:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1a:	0f b6 01             	movzbl (%ecx),%eax
  800b1d:	3c 20                	cmp    $0x20,%al
  800b1f:	74 f6                	je     800b17 <strtol+0xe>
  800b21:	3c 09                	cmp    $0x9,%al
  800b23:	74 f2                	je     800b17 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b25:	3c 2b                	cmp    $0x2b,%al
  800b27:	75 0a                	jne    800b33 <strtol+0x2a>
		s++;
  800b29:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b2c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b31:	eb 11                	jmp    800b44 <strtol+0x3b>
  800b33:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b38:	3c 2d                	cmp    $0x2d,%al
  800b3a:	75 08                	jne    800b44 <strtol+0x3b>
		s++, neg = 1;
  800b3c:	83 c1 01             	add    $0x1,%ecx
  800b3f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b44:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b4a:	75 15                	jne    800b61 <strtol+0x58>
  800b4c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b4f:	75 10                	jne    800b61 <strtol+0x58>
  800b51:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b55:	75 7c                	jne    800bd3 <strtol+0xca>
		s += 2, base = 16;
  800b57:	83 c1 02             	add    $0x2,%ecx
  800b5a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b5f:	eb 16                	jmp    800b77 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b61:	85 db                	test   %ebx,%ebx
  800b63:	75 12                	jne    800b77 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b65:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6d:	75 08                	jne    800b77 <strtol+0x6e>
		s++, base = 8;
  800b6f:	83 c1 01             	add    $0x1,%ecx
  800b72:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b7f:	0f b6 11             	movzbl (%ecx),%edx
  800b82:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b85:	89 f3                	mov    %esi,%ebx
  800b87:	80 fb 09             	cmp    $0x9,%bl
  800b8a:	77 08                	ja     800b94 <strtol+0x8b>
			dig = *s - '0';
  800b8c:	0f be d2             	movsbl %dl,%edx
  800b8f:	83 ea 30             	sub    $0x30,%edx
  800b92:	eb 22                	jmp    800bb6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b94:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b97:	89 f3                	mov    %esi,%ebx
  800b99:	80 fb 19             	cmp    $0x19,%bl
  800b9c:	77 08                	ja     800ba6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b9e:	0f be d2             	movsbl %dl,%edx
  800ba1:	83 ea 57             	sub    $0x57,%edx
  800ba4:	eb 10                	jmp    800bb6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ba6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ba9:	89 f3                	mov    %esi,%ebx
  800bab:	80 fb 19             	cmp    $0x19,%bl
  800bae:	77 16                	ja     800bc6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bb0:	0f be d2             	movsbl %dl,%edx
  800bb3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bb6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bb9:	7d 0b                	jge    800bc6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bbb:	83 c1 01             	add    $0x1,%ecx
  800bbe:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bc4:	eb b9                	jmp    800b7f <strtol+0x76>

	if (endptr)
  800bc6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bca:	74 0d                	je     800bd9 <strtol+0xd0>
		*endptr = (char *) s;
  800bcc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bcf:	89 0e                	mov    %ecx,(%esi)
  800bd1:	eb 06                	jmp    800bd9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd3:	85 db                	test   %ebx,%ebx
  800bd5:	74 98                	je     800b6f <strtol+0x66>
  800bd7:	eb 9e                	jmp    800b77 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bd9:	89 c2                	mov    %eax,%edx
  800bdb:	f7 da                	neg    %edx
  800bdd:	85 ff                	test   %edi,%edi
  800bdf:	0f 45 c2             	cmovne %edx,%eax
}
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	83 ec 04             	sub    $0x4,%esp
  800bf0:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800bf3:	57                   	push   %edi
  800bf4:	e8 6e fc ff ff       	call   800867 <strlen>
  800bf9:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800bfc:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800bff:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800c04:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800c09:	eb 46                	jmp    800c51 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800c0b:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800c0f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800c12:	80 f9 09             	cmp    $0x9,%cl
  800c15:	77 08                	ja     800c1f <charhex_to_dec+0x38>
			num = s[i] - '0';
  800c17:	0f be d2             	movsbl %dl,%edx
  800c1a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800c1d:	eb 27                	jmp    800c46 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800c1f:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800c22:	80 f9 05             	cmp    $0x5,%cl
  800c25:	77 08                	ja     800c2f <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800c27:	0f be d2             	movsbl %dl,%edx
  800c2a:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800c2d:	eb 17                	jmp    800c46 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800c2f:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800c32:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800c35:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800c3a:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800c3e:	77 06                	ja     800c46 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800c40:	0f be d2             	movsbl %dl,%edx
  800c43:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800c46:	0f af ce             	imul   %esi,%ecx
  800c49:	01 c8                	add    %ecx,%eax
		base *= 16;
  800c4b:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800c4e:	83 eb 01             	sub    $0x1,%ebx
  800c51:	83 fb 01             	cmp    $0x1,%ebx
  800c54:	7f b5                	jg     800c0b <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
  800c69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6f:	89 c3                	mov    %eax,%ebx
  800c71:	89 c7                	mov    %eax,%edi
  800c73:	89 c6                	mov    %eax,%esi
  800c75:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_cgetc>:

int
sys_cgetc(void)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	ba 00 00 00 00       	mov    $0x0,%edx
  800c87:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8c:	89 d1                	mov    %edx,%ecx
  800c8e:	89 d3                	mov    %edx,%ebx
  800c90:	89 d7                	mov    %edx,%edi
  800c92:	89 d6                	mov    %edx,%esi
  800c94:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca9:	b8 03 00 00 00       	mov    $0x3,%eax
  800cae:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb1:	89 cb                	mov    %ecx,%ebx
  800cb3:	89 cf                	mov    %ecx,%edi
  800cb5:	89 ce                	mov    %ecx,%esi
  800cb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	7e 17                	jle    800cd4 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbd:	83 ec 0c             	sub    $0xc,%esp
  800cc0:	50                   	push   %eax
  800cc1:	6a 03                	push   $0x3
  800cc3:	68 9f 24 80 00       	push   $0x80249f
  800cc8:	6a 23                	push   $0x23
  800cca:	68 bc 24 80 00       	push   $0x8024bc
  800ccf:	e8 bf f4 ff ff       	call   800193 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce7:	b8 02 00 00 00       	mov    $0x2,%eax
  800cec:	89 d1                	mov    %edx,%ecx
  800cee:	89 d3                	mov    %edx,%ebx
  800cf0:	89 d7                	mov    %edx,%edi
  800cf2:	89 d6                	mov    %edx,%esi
  800cf4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_yield>:

void
sys_yield(void)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d01:	ba 00 00 00 00       	mov    $0x0,%edx
  800d06:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d0b:	89 d1                	mov    %edx,%ecx
  800d0d:	89 d3                	mov    %edx,%ebx
  800d0f:	89 d7                	mov    %edx,%edi
  800d11:	89 d6                	mov    %edx,%esi
  800d13:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
  800d20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d23:	be 00 00 00 00       	mov    $0x0,%esi
  800d28:	b8 04 00 00 00       	mov    $0x4,%eax
  800d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d30:	8b 55 08             	mov    0x8(%ebp),%edx
  800d33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d36:	89 f7                	mov    %esi,%edi
  800d38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	7e 17                	jle    800d55 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	50                   	push   %eax
  800d42:	6a 04                	push   $0x4
  800d44:	68 9f 24 80 00       	push   $0x80249f
  800d49:	6a 23                	push   $0x23
  800d4b:	68 bc 24 80 00       	push   $0x8024bc
  800d50:	e8 3e f4 ff ff       	call   800193 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	57                   	push   %edi
  800d61:	56                   	push   %esi
  800d62:	53                   	push   %ebx
  800d63:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d66:	b8 05 00 00 00       	mov    $0x5,%eax
  800d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d74:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d77:	8b 75 18             	mov    0x18(%ebp),%esi
  800d7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7e 17                	jle    800d97 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	50                   	push   %eax
  800d84:	6a 05                	push   $0x5
  800d86:	68 9f 24 80 00       	push   $0x80249f
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 bc 24 80 00       	push   $0x8024bc
  800d92:	e8 fc f3 ff ff       	call   800193 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800da8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dad:	b8 06 00 00 00       	mov    $0x6,%eax
  800db2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db5:	8b 55 08             	mov    0x8(%ebp),%edx
  800db8:	89 df                	mov    %ebx,%edi
  800dba:	89 de                	mov    %ebx,%esi
  800dbc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	7e 17                	jle    800dd9 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc2:	83 ec 0c             	sub    $0xc,%esp
  800dc5:	50                   	push   %eax
  800dc6:	6a 06                	push   $0x6
  800dc8:	68 9f 24 80 00       	push   $0x80249f
  800dcd:	6a 23                	push   $0x23
  800dcf:	68 bc 24 80 00       	push   $0x8024bc
  800dd4:	e8 ba f3 ff ff       	call   800193 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	57                   	push   %edi
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
  800de7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800def:	b8 08 00 00 00       	mov    $0x8,%eax
  800df4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfa:	89 df                	mov    %ebx,%edi
  800dfc:	89 de                	mov    %ebx,%esi
  800dfe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e00:	85 c0                	test   %eax,%eax
  800e02:	7e 17                	jle    800e1b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e04:	83 ec 0c             	sub    $0xc,%esp
  800e07:	50                   	push   %eax
  800e08:	6a 08                	push   $0x8
  800e0a:	68 9f 24 80 00       	push   $0x80249f
  800e0f:	6a 23                	push   $0x23
  800e11:	68 bc 24 80 00       	push   $0x8024bc
  800e16:	e8 78 f3 ff ff       	call   800193 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	57                   	push   %edi
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
  800e29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e31:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	89 df                	mov    %ebx,%edi
  800e3e:	89 de                	mov    %ebx,%esi
  800e40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e42:	85 c0                	test   %eax,%eax
  800e44:	7e 17                	jle    800e5d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e46:	83 ec 0c             	sub    $0xc,%esp
  800e49:	50                   	push   %eax
  800e4a:	6a 0a                	push   $0xa
  800e4c:	68 9f 24 80 00       	push   $0x80249f
  800e51:	6a 23                	push   $0x23
  800e53:	68 bc 24 80 00       	push   $0x8024bc
  800e58:	e8 36 f3 ff ff       	call   800193 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	57                   	push   %edi
  800e69:	56                   	push   %esi
  800e6a:	53                   	push   %ebx
  800e6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e73:	b8 09 00 00 00       	mov    $0x9,%eax
  800e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	89 df                	mov    %ebx,%edi
  800e80:	89 de                	mov    %ebx,%esi
  800e82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e84:	85 c0                	test   %eax,%eax
  800e86:	7e 17                	jle    800e9f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e88:	83 ec 0c             	sub    $0xc,%esp
  800e8b:	50                   	push   %eax
  800e8c:	6a 09                	push   $0x9
  800e8e:	68 9f 24 80 00       	push   $0x80249f
  800e93:	6a 23                	push   $0x23
  800e95:	68 bc 24 80 00       	push   $0x8024bc
  800e9a:	e8 f4 f2 ff ff       	call   800193 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ead:	be 00 00 00 00       	mov    $0x0,%esi
  800eb2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eba:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	57                   	push   %edi
  800ece:	56                   	push   %esi
  800ecf:	53                   	push   %ebx
  800ed0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800edd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee0:	89 cb                	mov    %ecx,%ebx
  800ee2:	89 cf                	mov    %ecx,%edi
  800ee4:	89 ce                	mov    %ecx,%esi
  800ee6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	7e 17                	jle    800f03 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eec:	83 ec 0c             	sub    $0xc,%esp
  800eef:	50                   	push   %eax
  800ef0:	6a 0d                	push   $0xd
  800ef2:	68 9f 24 80 00       	push   $0x80249f
  800ef7:	6a 23                	push   $0x23
  800ef9:	68 bc 24 80 00       	push   $0x8024bc
  800efe:	e8 90 f2 ff ff       	call   800193 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f06:	5b                   	pop    %ebx
  800f07:	5e                   	pop    %esi
  800f08:	5f                   	pop    %edi
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f11:	05 00 00 00 30       	add    $0x30000000,%eax
  800f16:	c1 e8 0c             	shr    $0xc,%eax
}
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    

00800f1b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f21:	05 00 00 00 30       	add    $0x30000000,%eax
  800f26:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f2b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    

00800f32 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f38:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f3d:	89 c2                	mov    %eax,%edx
  800f3f:	c1 ea 16             	shr    $0x16,%edx
  800f42:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f49:	f6 c2 01             	test   $0x1,%dl
  800f4c:	74 11                	je     800f5f <fd_alloc+0x2d>
  800f4e:	89 c2                	mov    %eax,%edx
  800f50:	c1 ea 0c             	shr    $0xc,%edx
  800f53:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f5a:	f6 c2 01             	test   $0x1,%dl
  800f5d:	75 09                	jne    800f68 <fd_alloc+0x36>
			*fd_store = fd;
  800f5f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f61:	b8 00 00 00 00       	mov    $0x0,%eax
  800f66:	eb 17                	jmp    800f7f <fd_alloc+0x4d>
  800f68:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f6d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f72:	75 c9                	jne    800f3d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f74:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f7a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f7f:	5d                   	pop    %ebp
  800f80:	c3                   	ret    

00800f81 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f87:	83 f8 1f             	cmp    $0x1f,%eax
  800f8a:	77 36                	ja     800fc2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f8c:	c1 e0 0c             	shl    $0xc,%eax
  800f8f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f94:	89 c2                	mov    %eax,%edx
  800f96:	c1 ea 16             	shr    $0x16,%edx
  800f99:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fa0:	f6 c2 01             	test   $0x1,%dl
  800fa3:	74 24                	je     800fc9 <fd_lookup+0x48>
  800fa5:	89 c2                	mov    %eax,%edx
  800fa7:	c1 ea 0c             	shr    $0xc,%edx
  800faa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fb1:	f6 c2 01             	test   $0x1,%dl
  800fb4:	74 1a                	je     800fd0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fb6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fb9:	89 02                	mov    %eax,(%edx)
	return 0;
  800fbb:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc0:	eb 13                	jmp    800fd5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fc2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fc7:	eb 0c                	jmp    800fd5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fc9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fce:	eb 05                	jmp    800fd5 <fd_lookup+0x54>
  800fd0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    

00800fd7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 08             	sub    $0x8,%esp
  800fdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe0:	ba 48 25 80 00       	mov    $0x802548,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fe5:	eb 13                	jmp    800ffa <dev_lookup+0x23>
  800fe7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fea:	39 08                	cmp    %ecx,(%eax)
  800fec:	75 0c                	jne    800ffa <dev_lookup+0x23>
			*dev = devtab[i];
  800fee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff8:	eb 2e                	jmp    801028 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ffa:	8b 02                	mov    (%edx),%eax
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	75 e7                	jne    800fe7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801000:	a1 20 60 80 00       	mov    0x806020,%eax
  801005:	8b 40 48             	mov    0x48(%eax),%eax
  801008:	83 ec 04             	sub    $0x4,%esp
  80100b:	51                   	push   %ecx
  80100c:	50                   	push   %eax
  80100d:	68 cc 24 80 00       	push   $0x8024cc
  801012:	e8 55 f2 ff ff       	call   80026c <cprintf>
	*dev = 0;
  801017:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801020:	83 c4 10             	add    $0x10,%esp
  801023:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801028:	c9                   	leave  
  801029:	c3                   	ret    

0080102a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	56                   	push   %esi
  80102e:	53                   	push   %ebx
  80102f:	83 ec 10             	sub    $0x10,%esp
  801032:	8b 75 08             	mov    0x8(%ebp),%esi
  801035:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801038:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103b:	50                   	push   %eax
  80103c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801042:	c1 e8 0c             	shr    $0xc,%eax
  801045:	50                   	push   %eax
  801046:	e8 36 ff ff ff       	call   800f81 <fd_lookup>
  80104b:	83 c4 08             	add    $0x8,%esp
  80104e:	85 c0                	test   %eax,%eax
  801050:	78 05                	js     801057 <fd_close+0x2d>
	    || fd != fd2) 
  801052:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801055:	74 0c                	je     801063 <fd_close+0x39>
		return (must_exist ? r : 0); 
  801057:	84 db                	test   %bl,%bl
  801059:	ba 00 00 00 00       	mov    $0x0,%edx
  80105e:	0f 44 c2             	cmove  %edx,%eax
  801061:	eb 41                	jmp    8010a4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801063:	83 ec 08             	sub    $0x8,%esp
  801066:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801069:	50                   	push   %eax
  80106a:	ff 36                	pushl  (%esi)
  80106c:	e8 66 ff ff ff       	call   800fd7 <dev_lookup>
  801071:	89 c3                	mov    %eax,%ebx
  801073:	83 c4 10             	add    $0x10,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	78 1a                	js     801094 <fd_close+0x6a>
		if (dev->dev_close) 
  80107a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80107d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  801080:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  801085:	85 c0                	test   %eax,%eax
  801087:	74 0b                	je     801094 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801089:	83 ec 0c             	sub    $0xc,%esp
  80108c:	56                   	push   %esi
  80108d:	ff d0                	call   *%eax
  80108f:	89 c3                	mov    %eax,%ebx
  801091:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801094:	83 ec 08             	sub    $0x8,%esp
  801097:	56                   	push   %esi
  801098:	6a 00                	push   $0x0
  80109a:	e8 00 fd ff ff       	call   800d9f <sys_page_unmap>
	return r;
  80109f:	83 c4 10             	add    $0x10,%esp
  8010a2:	89 d8                	mov    %ebx,%eax
}
  8010a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010a7:	5b                   	pop    %ebx
  8010a8:	5e                   	pop    %esi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b4:	50                   	push   %eax
  8010b5:	ff 75 08             	pushl  0x8(%ebp)
  8010b8:	e8 c4 fe ff ff       	call   800f81 <fd_lookup>
  8010bd:	83 c4 08             	add    $0x8,%esp
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	78 10                	js     8010d4 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  8010c4:	83 ec 08             	sub    $0x8,%esp
  8010c7:	6a 01                	push   $0x1
  8010c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8010cc:	e8 59 ff ff ff       	call   80102a <fd_close>
  8010d1:	83 c4 10             	add    $0x10,%esp
}
  8010d4:	c9                   	leave  
  8010d5:	c3                   	ret    

008010d6 <close_all>:

void
close_all(void)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	53                   	push   %ebx
  8010da:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010dd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010e2:	83 ec 0c             	sub    $0xc,%esp
  8010e5:	53                   	push   %ebx
  8010e6:	e8 c0 ff ff ff       	call   8010ab <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010eb:	83 c3 01             	add    $0x1,%ebx
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	83 fb 20             	cmp    $0x20,%ebx
  8010f4:	75 ec                	jne    8010e2 <close_all+0xc>
		close(i);
}
  8010f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f9:	c9                   	leave  
  8010fa:	c3                   	ret    

008010fb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	57                   	push   %edi
  8010ff:	56                   	push   %esi
  801100:	53                   	push   %ebx
  801101:	83 ec 2c             	sub    $0x2c,%esp
  801104:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801107:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80110a:	50                   	push   %eax
  80110b:	ff 75 08             	pushl  0x8(%ebp)
  80110e:	e8 6e fe ff ff       	call   800f81 <fd_lookup>
  801113:	83 c4 08             	add    $0x8,%esp
  801116:	85 c0                	test   %eax,%eax
  801118:	0f 88 c1 00 00 00    	js     8011df <dup+0xe4>
		return r;
	close(newfdnum);
  80111e:	83 ec 0c             	sub    $0xc,%esp
  801121:	56                   	push   %esi
  801122:	e8 84 ff ff ff       	call   8010ab <close>

	newfd = INDEX2FD(newfdnum);
  801127:	89 f3                	mov    %esi,%ebx
  801129:	c1 e3 0c             	shl    $0xc,%ebx
  80112c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801132:	83 c4 04             	add    $0x4,%esp
  801135:	ff 75 e4             	pushl  -0x1c(%ebp)
  801138:	e8 de fd ff ff       	call   800f1b <fd2data>
  80113d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80113f:	89 1c 24             	mov    %ebx,(%esp)
  801142:	e8 d4 fd ff ff       	call   800f1b <fd2data>
  801147:	83 c4 10             	add    $0x10,%esp
  80114a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80114d:	89 f8                	mov    %edi,%eax
  80114f:	c1 e8 16             	shr    $0x16,%eax
  801152:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801159:	a8 01                	test   $0x1,%al
  80115b:	74 37                	je     801194 <dup+0x99>
  80115d:	89 f8                	mov    %edi,%eax
  80115f:	c1 e8 0c             	shr    $0xc,%eax
  801162:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801169:	f6 c2 01             	test   $0x1,%dl
  80116c:	74 26                	je     801194 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80116e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801175:	83 ec 0c             	sub    $0xc,%esp
  801178:	25 07 0e 00 00       	and    $0xe07,%eax
  80117d:	50                   	push   %eax
  80117e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801181:	6a 00                	push   $0x0
  801183:	57                   	push   %edi
  801184:	6a 00                	push   $0x0
  801186:	e8 d2 fb ff ff       	call   800d5d <sys_page_map>
  80118b:	89 c7                	mov    %eax,%edi
  80118d:	83 c4 20             	add    $0x20,%esp
  801190:	85 c0                	test   %eax,%eax
  801192:	78 2e                	js     8011c2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801194:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801197:	89 d0                	mov    %edx,%eax
  801199:	c1 e8 0c             	shr    $0xc,%eax
  80119c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011a3:	83 ec 0c             	sub    $0xc,%esp
  8011a6:	25 07 0e 00 00       	and    $0xe07,%eax
  8011ab:	50                   	push   %eax
  8011ac:	53                   	push   %ebx
  8011ad:	6a 00                	push   $0x0
  8011af:	52                   	push   %edx
  8011b0:	6a 00                	push   $0x0
  8011b2:	e8 a6 fb ff ff       	call   800d5d <sys_page_map>
  8011b7:	89 c7                	mov    %eax,%edi
  8011b9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011bc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011be:	85 ff                	test   %edi,%edi
  8011c0:	79 1d                	jns    8011df <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011c2:	83 ec 08             	sub    $0x8,%esp
  8011c5:	53                   	push   %ebx
  8011c6:	6a 00                	push   $0x0
  8011c8:	e8 d2 fb ff ff       	call   800d9f <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011cd:	83 c4 08             	add    $0x8,%esp
  8011d0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011d3:	6a 00                	push   $0x0
  8011d5:	e8 c5 fb ff ff       	call   800d9f <sys_page_unmap>
	return r;
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	89 f8                	mov    %edi,%eax
}
  8011df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e2:	5b                   	pop    %ebx
  8011e3:	5e                   	pop    %esi
  8011e4:	5f                   	pop    %edi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	53                   	push   %ebx
  8011eb:	83 ec 14             	sub    $0x14,%esp
  8011ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f4:	50                   	push   %eax
  8011f5:	53                   	push   %ebx
  8011f6:	e8 86 fd ff ff       	call   800f81 <fd_lookup>
  8011fb:	83 c4 08             	add    $0x8,%esp
  8011fe:	89 c2                	mov    %eax,%edx
  801200:	85 c0                	test   %eax,%eax
  801202:	78 6d                	js     801271 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801204:	83 ec 08             	sub    $0x8,%esp
  801207:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120a:	50                   	push   %eax
  80120b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120e:	ff 30                	pushl  (%eax)
  801210:	e8 c2 fd ff ff       	call   800fd7 <dev_lookup>
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	78 4c                	js     801268 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80121c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80121f:	8b 42 08             	mov    0x8(%edx),%eax
  801222:	83 e0 03             	and    $0x3,%eax
  801225:	83 f8 01             	cmp    $0x1,%eax
  801228:	75 21                	jne    80124b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80122a:	a1 20 60 80 00       	mov    0x806020,%eax
  80122f:	8b 40 48             	mov    0x48(%eax),%eax
  801232:	83 ec 04             	sub    $0x4,%esp
  801235:	53                   	push   %ebx
  801236:	50                   	push   %eax
  801237:	68 0d 25 80 00       	push   $0x80250d
  80123c:	e8 2b f0 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801249:	eb 26                	jmp    801271 <read+0x8a>
	}
	if (!dev->dev_read)
  80124b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80124e:	8b 40 08             	mov    0x8(%eax),%eax
  801251:	85 c0                	test   %eax,%eax
  801253:	74 17                	je     80126c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801255:	83 ec 04             	sub    $0x4,%esp
  801258:	ff 75 10             	pushl  0x10(%ebp)
  80125b:	ff 75 0c             	pushl  0xc(%ebp)
  80125e:	52                   	push   %edx
  80125f:	ff d0                	call   *%eax
  801261:	89 c2                	mov    %eax,%edx
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	eb 09                	jmp    801271 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801268:	89 c2                	mov    %eax,%edx
  80126a:	eb 05                	jmp    801271 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80126c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801271:	89 d0                	mov    %edx,%eax
  801273:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801276:	c9                   	leave  
  801277:	c3                   	ret    

00801278 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	57                   	push   %edi
  80127c:	56                   	push   %esi
  80127d:	53                   	push   %ebx
  80127e:	83 ec 0c             	sub    $0xc,%esp
  801281:	8b 7d 08             	mov    0x8(%ebp),%edi
  801284:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801287:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128c:	eb 21                	jmp    8012af <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80128e:	83 ec 04             	sub    $0x4,%esp
  801291:	89 f0                	mov    %esi,%eax
  801293:	29 d8                	sub    %ebx,%eax
  801295:	50                   	push   %eax
  801296:	89 d8                	mov    %ebx,%eax
  801298:	03 45 0c             	add    0xc(%ebp),%eax
  80129b:	50                   	push   %eax
  80129c:	57                   	push   %edi
  80129d:	e8 45 ff ff ff       	call   8011e7 <read>
		if (m < 0)
  8012a2:	83 c4 10             	add    $0x10,%esp
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	78 10                	js     8012b9 <readn+0x41>
			return m;
		if (m == 0)
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	74 0a                	je     8012b7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012ad:	01 c3                	add    %eax,%ebx
  8012af:	39 f3                	cmp    %esi,%ebx
  8012b1:	72 db                	jb     80128e <readn+0x16>
  8012b3:	89 d8                	mov    %ebx,%eax
  8012b5:	eb 02                	jmp    8012b9 <readn+0x41>
  8012b7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012bc:	5b                   	pop    %ebx
  8012bd:	5e                   	pop    %esi
  8012be:	5f                   	pop    %edi
  8012bf:	5d                   	pop    %ebp
  8012c0:	c3                   	ret    

008012c1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	53                   	push   %ebx
  8012c5:	83 ec 14             	sub    $0x14,%esp
  8012c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ce:	50                   	push   %eax
  8012cf:	53                   	push   %ebx
  8012d0:	e8 ac fc ff ff       	call   800f81 <fd_lookup>
  8012d5:	83 c4 08             	add    $0x8,%esp
  8012d8:	89 c2                	mov    %eax,%edx
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	78 68                	js     801346 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012de:	83 ec 08             	sub    $0x8,%esp
  8012e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e4:	50                   	push   %eax
  8012e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e8:	ff 30                	pushl  (%eax)
  8012ea:	e8 e8 fc ff ff       	call   800fd7 <dev_lookup>
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	78 47                	js     80133d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012fd:	75 21                	jne    801320 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012ff:	a1 20 60 80 00       	mov    0x806020,%eax
  801304:	8b 40 48             	mov    0x48(%eax),%eax
  801307:	83 ec 04             	sub    $0x4,%esp
  80130a:	53                   	push   %ebx
  80130b:	50                   	push   %eax
  80130c:	68 29 25 80 00       	push   $0x802529
  801311:	e8 56 ef ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  801316:	83 c4 10             	add    $0x10,%esp
  801319:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80131e:	eb 26                	jmp    801346 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801320:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801323:	8b 52 0c             	mov    0xc(%edx),%edx
  801326:	85 d2                	test   %edx,%edx
  801328:	74 17                	je     801341 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80132a:	83 ec 04             	sub    $0x4,%esp
  80132d:	ff 75 10             	pushl  0x10(%ebp)
  801330:	ff 75 0c             	pushl  0xc(%ebp)
  801333:	50                   	push   %eax
  801334:	ff d2                	call   *%edx
  801336:	89 c2                	mov    %eax,%edx
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	eb 09                	jmp    801346 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133d:	89 c2                	mov    %eax,%edx
  80133f:	eb 05                	jmp    801346 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801341:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801346:	89 d0                	mov    %edx,%eax
  801348:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134b:	c9                   	leave  
  80134c:	c3                   	ret    

0080134d <seek>:

int
seek(int fdnum, off_t offset)
{
  80134d:	55                   	push   %ebp
  80134e:	89 e5                	mov    %esp,%ebp
  801350:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801353:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801356:	50                   	push   %eax
  801357:	ff 75 08             	pushl  0x8(%ebp)
  80135a:	e8 22 fc ff ff       	call   800f81 <fd_lookup>
  80135f:	83 c4 08             	add    $0x8,%esp
  801362:	85 c0                	test   %eax,%eax
  801364:	78 0e                	js     801374 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801366:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801369:	8b 55 0c             	mov    0xc(%ebp),%edx
  80136c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80136f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801374:	c9                   	leave  
  801375:	c3                   	ret    

00801376 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	53                   	push   %ebx
  80137a:	83 ec 14             	sub    $0x14,%esp
  80137d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801380:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801383:	50                   	push   %eax
  801384:	53                   	push   %ebx
  801385:	e8 f7 fb ff ff       	call   800f81 <fd_lookup>
  80138a:	83 c4 08             	add    $0x8,%esp
  80138d:	89 c2                	mov    %eax,%edx
  80138f:	85 c0                	test   %eax,%eax
  801391:	78 65                	js     8013f8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801393:	83 ec 08             	sub    $0x8,%esp
  801396:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801399:	50                   	push   %eax
  80139a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139d:	ff 30                	pushl  (%eax)
  80139f:	e8 33 fc ff ff       	call   800fd7 <dev_lookup>
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	78 44                	js     8013ef <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ae:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013b2:	75 21                	jne    8013d5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013b4:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013b9:	8b 40 48             	mov    0x48(%eax),%eax
  8013bc:	83 ec 04             	sub    $0x4,%esp
  8013bf:	53                   	push   %ebx
  8013c0:	50                   	push   %eax
  8013c1:	68 ec 24 80 00       	push   $0x8024ec
  8013c6:	e8 a1 ee ff ff       	call   80026c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013d3:	eb 23                	jmp    8013f8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013d8:	8b 52 18             	mov    0x18(%edx),%edx
  8013db:	85 d2                	test   %edx,%edx
  8013dd:	74 14                	je     8013f3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013df:	83 ec 08             	sub    $0x8,%esp
  8013e2:	ff 75 0c             	pushl  0xc(%ebp)
  8013e5:	50                   	push   %eax
  8013e6:	ff d2                	call   *%edx
  8013e8:	89 c2                	mov    %eax,%edx
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	eb 09                	jmp    8013f8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ef:	89 c2                	mov    %eax,%edx
  8013f1:	eb 05                	jmp    8013f8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013f8:	89 d0                	mov    %edx,%eax
  8013fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fd:	c9                   	leave  
  8013fe:	c3                   	ret    

008013ff <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	53                   	push   %ebx
  801403:	83 ec 14             	sub    $0x14,%esp
  801406:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801409:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140c:	50                   	push   %eax
  80140d:	ff 75 08             	pushl  0x8(%ebp)
  801410:	e8 6c fb ff ff       	call   800f81 <fd_lookup>
  801415:	83 c4 08             	add    $0x8,%esp
  801418:	89 c2                	mov    %eax,%edx
  80141a:	85 c0                	test   %eax,%eax
  80141c:	78 58                	js     801476 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141e:	83 ec 08             	sub    $0x8,%esp
  801421:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801424:	50                   	push   %eax
  801425:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801428:	ff 30                	pushl  (%eax)
  80142a:	e8 a8 fb ff ff       	call   800fd7 <dev_lookup>
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	85 c0                	test   %eax,%eax
  801434:	78 37                	js     80146d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801436:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801439:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80143d:	74 32                	je     801471 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80143f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801442:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801449:	00 00 00 
	stat->st_isdir = 0;
  80144c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801453:	00 00 00 
	stat->st_dev = dev;
  801456:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80145c:	83 ec 08             	sub    $0x8,%esp
  80145f:	53                   	push   %ebx
  801460:	ff 75 f0             	pushl  -0x10(%ebp)
  801463:	ff 50 14             	call   *0x14(%eax)
  801466:	89 c2                	mov    %eax,%edx
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	eb 09                	jmp    801476 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146d:	89 c2                	mov    %eax,%edx
  80146f:	eb 05                	jmp    801476 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801471:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801476:	89 d0                	mov    %edx,%eax
  801478:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147b:	c9                   	leave  
  80147c:	c3                   	ret    

0080147d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	56                   	push   %esi
  801481:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801482:	83 ec 08             	sub    $0x8,%esp
  801485:	6a 00                	push   $0x0
  801487:	ff 75 08             	pushl  0x8(%ebp)
  80148a:	e8 2b 02 00 00       	call   8016ba <open>
  80148f:	89 c3                	mov    %eax,%ebx
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	85 c0                	test   %eax,%eax
  801496:	78 1b                	js     8014b3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801498:	83 ec 08             	sub    $0x8,%esp
  80149b:	ff 75 0c             	pushl  0xc(%ebp)
  80149e:	50                   	push   %eax
  80149f:	e8 5b ff ff ff       	call   8013ff <fstat>
  8014a4:	89 c6                	mov    %eax,%esi
	close(fd);
  8014a6:	89 1c 24             	mov    %ebx,(%esp)
  8014a9:	e8 fd fb ff ff       	call   8010ab <close>
	return r;
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	89 f0                	mov    %esi,%eax
}
  8014b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b6:	5b                   	pop    %ebx
  8014b7:	5e                   	pop    %esi
  8014b8:	5d                   	pop    %ebp
  8014b9:	c3                   	ret    

008014ba <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	56                   	push   %esi
  8014be:	53                   	push   %ebx
  8014bf:	89 c6                	mov    %eax,%esi
  8014c1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014c3:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8014ca:	75 12                	jne    8014de <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014cc:	83 ec 0c             	sub    $0xc,%esp
  8014cf:	6a 01                	push   $0x1
  8014d1:	e8 36 09 00 00       	call   801e0c <ipc_find_env>
  8014d6:	a3 04 40 80 00       	mov    %eax,0x804004
  8014db:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014de:	6a 07                	push   $0x7
  8014e0:	68 00 70 80 00       	push   $0x807000
  8014e5:	56                   	push   %esi
  8014e6:	ff 35 04 40 80 00    	pushl  0x804004
  8014ec:	e8 c5 08 00 00       	call   801db6 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8014f1:	83 c4 0c             	add    $0xc,%esp
  8014f4:	6a 00                	push   $0x0
  8014f6:	53                   	push   %ebx
  8014f7:	6a 00                	push   $0x0
  8014f9:	e8 4f 08 00 00       	call   801d4d <ipc_recv>
}
  8014fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801501:	5b                   	pop    %ebx
  801502:	5e                   	pop    %esi
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    

00801505 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80150b:	8b 45 08             	mov    0x8(%ebp),%eax
  80150e:	8b 40 0c             	mov    0xc(%eax),%eax
  801511:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801516:	8b 45 0c             	mov    0xc(%ebp),%eax
  801519:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80151e:	ba 00 00 00 00       	mov    $0x0,%edx
  801523:	b8 02 00 00 00       	mov    $0x2,%eax
  801528:	e8 8d ff ff ff       	call   8014ba <fsipc>
}
  80152d:	c9                   	leave  
  80152e:	c3                   	ret    

0080152f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801535:	8b 45 08             	mov    0x8(%ebp),%eax
  801538:	8b 40 0c             	mov    0xc(%eax),%eax
  80153b:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801540:	ba 00 00 00 00       	mov    $0x0,%edx
  801545:	b8 06 00 00 00       	mov    $0x6,%eax
  80154a:	e8 6b ff ff ff       	call   8014ba <fsipc>
}
  80154f:	c9                   	leave  
  801550:	c3                   	ret    

00801551 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	53                   	push   %ebx
  801555:	83 ec 04             	sub    $0x4,%esp
  801558:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80155b:	8b 45 08             	mov    0x8(%ebp),%eax
  80155e:	8b 40 0c             	mov    0xc(%eax),%eax
  801561:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801566:	ba 00 00 00 00       	mov    $0x0,%edx
  80156b:	b8 05 00 00 00       	mov    $0x5,%eax
  801570:	e8 45 ff ff ff       	call   8014ba <fsipc>
  801575:	85 c0                	test   %eax,%eax
  801577:	78 2c                	js     8015a5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801579:	83 ec 08             	sub    $0x8,%esp
  80157c:	68 00 70 80 00       	push   $0x807000
  801581:	53                   	push   %ebx
  801582:	e8 19 f3 ff ff       	call   8008a0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801587:	a1 80 70 80 00       	mov    0x807080,%eax
  80158c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801592:	a1 84 70 80 00       	mov    0x807084,%eax
  801597:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80159d:	83 c4 10             	add    $0x10,%esp
  8015a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a8:	c9                   	leave  
  8015a9:	c3                   	ret    

008015aa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	53                   	push   %ebx
  8015ae:	83 ec 08             	sub    $0x8,%esp
  8015b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8015b4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015b9:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8015be:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c7:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.write.req_n = n;
  8015cc:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015d2:	53                   	push   %ebx
  8015d3:	ff 75 0c             	pushl  0xc(%ebp)
  8015d6:	68 08 70 80 00       	push   $0x807008
  8015db:	e8 52 f4 ff ff       	call   800a32 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8015e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e5:	b8 04 00 00 00       	mov    $0x4,%eax
  8015ea:	e8 cb fe ff ff       	call   8014ba <fsipc>
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 3d                	js     801633 <devfile_write+0x89>
		return r;

	assert(r <= n);
  8015f6:	39 d8                	cmp    %ebx,%eax
  8015f8:	76 19                	jbe    801613 <devfile_write+0x69>
  8015fa:	68 58 25 80 00       	push   $0x802558
  8015ff:	68 5f 25 80 00       	push   $0x80255f
  801604:	68 9f 00 00 00       	push   $0x9f
  801609:	68 74 25 80 00       	push   $0x802574
  80160e:	e8 80 eb ff ff       	call   800193 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801613:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801618:	76 19                	jbe    801633 <devfile_write+0x89>
  80161a:	68 8c 25 80 00       	push   $0x80258c
  80161f:	68 5f 25 80 00       	push   $0x80255f
  801624:	68 a0 00 00 00       	push   $0xa0
  801629:	68 74 25 80 00       	push   $0x802574
  80162e:	e8 60 eb ff ff       	call   800193 <_panic>

	return r;
}
  801633:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801636:	c9                   	leave  
  801637:	c3                   	ret    

00801638 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	56                   	push   %esi
  80163c:	53                   	push   %ebx
  80163d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801640:	8b 45 08             	mov    0x8(%ebp),%eax
  801643:	8b 40 0c             	mov    0xc(%eax),%eax
  801646:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  80164b:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801651:	ba 00 00 00 00       	mov    $0x0,%edx
  801656:	b8 03 00 00 00       	mov    $0x3,%eax
  80165b:	e8 5a fe ff ff       	call   8014ba <fsipc>
  801660:	89 c3                	mov    %eax,%ebx
  801662:	85 c0                	test   %eax,%eax
  801664:	78 4b                	js     8016b1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801666:	39 c6                	cmp    %eax,%esi
  801668:	73 16                	jae    801680 <devfile_read+0x48>
  80166a:	68 58 25 80 00       	push   $0x802558
  80166f:	68 5f 25 80 00       	push   $0x80255f
  801674:	6a 7e                	push   $0x7e
  801676:	68 74 25 80 00       	push   $0x802574
  80167b:	e8 13 eb ff ff       	call   800193 <_panic>
	assert(r <= PGSIZE);
  801680:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801685:	7e 16                	jle    80169d <devfile_read+0x65>
  801687:	68 7f 25 80 00       	push   $0x80257f
  80168c:	68 5f 25 80 00       	push   $0x80255f
  801691:	6a 7f                	push   $0x7f
  801693:	68 74 25 80 00       	push   $0x802574
  801698:	e8 f6 ea ff ff       	call   800193 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80169d:	83 ec 04             	sub    $0x4,%esp
  8016a0:	50                   	push   %eax
  8016a1:	68 00 70 80 00       	push   $0x807000
  8016a6:	ff 75 0c             	pushl  0xc(%ebp)
  8016a9:	e8 84 f3 ff ff       	call   800a32 <memmove>
	return r;
  8016ae:	83 c4 10             	add    $0x10,%esp
}
  8016b1:	89 d8                	mov    %ebx,%eax
  8016b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b6:	5b                   	pop    %ebx
  8016b7:	5e                   	pop    %esi
  8016b8:	5d                   	pop    %ebp
  8016b9:	c3                   	ret    

008016ba <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 20             	sub    $0x20,%esp
  8016c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016c4:	53                   	push   %ebx
  8016c5:	e8 9d f1 ff ff       	call   800867 <strlen>
  8016ca:	83 c4 10             	add    $0x10,%esp
  8016cd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016d2:	7f 67                	jg     80173b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016d4:	83 ec 0c             	sub    $0xc,%esp
  8016d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016da:	50                   	push   %eax
  8016db:	e8 52 f8 ff ff       	call   800f32 <fd_alloc>
  8016e0:	83 c4 10             	add    $0x10,%esp
		return r;
  8016e3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	78 57                	js     801740 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016e9:	83 ec 08             	sub    $0x8,%esp
  8016ec:	53                   	push   %ebx
  8016ed:	68 00 70 80 00       	push   $0x807000
  8016f2:	e8 a9 f1 ff ff       	call   8008a0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016fa:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801702:	b8 01 00 00 00       	mov    $0x1,%eax
  801707:	e8 ae fd ff ff       	call   8014ba <fsipc>
  80170c:	89 c3                	mov    %eax,%ebx
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	85 c0                	test   %eax,%eax
  801713:	79 14                	jns    801729 <open+0x6f>
		fd_close(fd, 0);
  801715:	83 ec 08             	sub    $0x8,%esp
  801718:	6a 00                	push   $0x0
  80171a:	ff 75 f4             	pushl  -0xc(%ebp)
  80171d:	e8 08 f9 ff ff       	call   80102a <fd_close>
		return r;
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	89 da                	mov    %ebx,%edx
  801727:	eb 17                	jmp    801740 <open+0x86>
	}

	return fd2num(fd);
  801729:	83 ec 0c             	sub    $0xc,%esp
  80172c:	ff 75 f4             	pushl  -0xc(%ebp)
  80172f:	e8 d7 f7 ff ff       	call   800f0b <fd2num>
  801734:	89 c2                	mov    %eax,%edx
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	eb 05                	jmp    801740 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80173b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801740:	89 d0                	mov    %edx,%eax
  801742:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801745:	c9                   	leave  
  801746:	c3                   	ret    

00801747 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80174d:	ba 00 00 00 00       	mov    $0x0,%edx
  801752:	b8 08 00 00 00       	mov    $0x8,%eax
  801757:	e8 5e fd ff ff       	call   8014ba <fsipc>
}
  80175c:	c9                   	leave  
  80175d:	c3                   	ret    

0080175e <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80175e:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801762:	7e 37                	jle    80179b <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	53                   	push   %ebx
  801768:	83 ec 08             	sub    $0x8,%esp
  80176b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80176d:	ff 70 04             	pushl  0x4(%eax)
  801770:	8d 40 10             	lea    0x10(%eax),%eax
  801773:	50                   	push   %eax
  801774:	ff 33                	pushl  (%ebx)
  801776:	e8 46 fb ff ff       	call   8012c1 <write>
		if (result > 0)
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	85 c0                	test   %eax,%eax
  801780:	7e 03                	jle    801785 <writebuf+0x27>
			b->result += result;
  801782:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801785:	3b 43 04             	cmp    0x4(%ebx),%eax
  801788:	74 0d                	je     801797 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80178a:	85 c0                	test   %eax,%eax
  80178c:	ba 00 00 00 00       	mov    $0x0,%edx
  801791:	0f 4f c2             	cmovg  %edx,%eax
  801794:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179a:	c9                   	leave  
  80179b:	f3 c3                	repz ret 

0080179d <putch>:

static void
putch(int ch, void *thunk)
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	53                   	push   %ebx
  8017a1:	83 ec 04             	sub    $0x4,%esp
  8017a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8017a7:	8b 53 04             	mov    0x4(%ebx),%edx
  8017aa:	8d 42 01             	lea    0x1(%edx),%eax
  8017ad:	89 43 04             	mov    %eax,0x4(%ebx)
  8017b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b3:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8017b7:	3d 00 01 00 00       	cmp    $0x100,%eax
  8017bc:	75 0e                	jne    8017cc <putch+0x2f>
		writebuf(b);
  8017be:	89 d8                	mov    %ebx,%eax
  8017c0:	e8 99 ff ff ff       	call   80175e <writebuf>
		b->idx = 0;
  8017c5:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8017cc:	83 c4 04             	add    $0x4,%esp
  8017cf:	5b                   	pop    %ebx
  8017d0:	5d                   	pop    %ebp
  8017d1:	c3                   	ret    

008017d2 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8017db:	8b 45 08             	mov    0x8(%ebp),%eax
  8017de:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017e4:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017eb:	00 00 00 
	b.result = 0;
  8017ee:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017f5:	00 00 00 
	b.error = 1;
  8017f8:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017ff:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801802:	ff 75 10             	pushl  0x10(%ebp)
  801805:	ff 75 0c             	pushl  0xc(%ebp)
  801808:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80180e:	50                   	push   %eax
  80180f:	68 9d 17 80 00       	push   $0x80179d
  801814:	e8 8a eb ff ff       	call   8003a3 <vprintfmt>
	if (b.idx > 0)
  801819:	83 c4 10             	add    $0x10,%esp
  80181c:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801823:	7e 0b                	jle    801830 <vfprintf+0x5e>
		writebuf(&b);
  801825:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80182b:	e8 2e ff ff ff       	call   80175e <writebuf>

	return (b.result ? b.result : b.error);
  801830:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801836:	85 c0                	test   %eax,%eax
  801838:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80183f:	c9                   	leave  
  801840:	c3                   	ret    

00801841 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801847:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80184a:	50                   	push   %eax
  80184b:	ff 75 0c             	pushl  0xc(%ebp)
  80184e:	ff 75 08             	pushl  0x8(%ebp)
  801851:	e8 7c ff ff ff       	call   8017d2 <vfprintf>
	va_end(ap);

	return cnt;
}
  801856:	c9                   	leave  
  801857:	c3                   	ret    

00801858 <printf>:

int
printf(const char *fmt, ...)
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80185e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801861:	50                   	push   %eax
  801862:	ff 75 08             	pushl  0x8(%ebp)
  801865:	6a 01                	push   $0x1
  801867:	e8 66 ff ff ff       	call   8017d2 <vfprintf>
	va_end(ap);

	return cnt;
}
  80186c:	c9                   	leave  
  80186d:	c3                   	ret    

0080186e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	56                   	push   %esi
  801872:	53                   	push   %ebx
  801873:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801876:	83 ec 0c             	sub    $0xc,%esp
  801879:	ff 75 08             	pushl  0x8(%ebp)
  80187c:	e8 9a f6 ff ff       	call   800f1b <fd2data>
  801881:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801883:	83 c4 08             	add    $0x8,%esp
  801886:	68 b9 25 80 00       	push   $0x8025b9
  80188b:	53                   	push   %ebx
  80188c:	e8 0f f0 ff ff       	call   8008a0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801891:	8b 46 04             	mov    0x4(%esi),%eax
  801894:	2b 06                	sub    (%esi),%eax
  801896:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80189c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018a3:	00 00 00 
	stat->st_dev = &devpipe;
  8018a6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018ad:	30 80 00 
	return 0;
}
  8018b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b8:	5b                   	pop    %ebx
  8018b9:	5e                   	pop    %esi
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    

008018bc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	53                   	push   %ebx
  8018c0:	83 ec 0c             	sub    $0xc,%esp
  8018c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018c6:	53                   	push   %ebx
  8018c7:	6a 00                	push   $0x0
  8018c9:	e8 d1 f4 ff ff       	call   800d9f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018ce:	89 1c 24             	mov    %ebx,(%esp)
  8018d1:	e8 45 f6 ff ff       	call   800f1b <fd2data>
  8018d6:	83 c4 08             	add    $0x8,%esp
  8018d9:	50                   	push   %eax
  8018da:	6a 00                	push   $0x0
  8018dc:	e8 be f4 ff ff       	call   800d9f <sys_page_unmap>
}
  8018e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e4:	c9                   	leave  
  8018e5:	c3                   	ret    

008018e6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	57                   	push   %edi
  8018ea:	56                   	push   %esi
  8018eb:	53                   	push   %ebx
  8018ec:	83 ec 1c             	sub    $0x1c,%esp
  8018ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018f2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018f4:	a1 20 60 80 00       	mov    0x806020,%eax
  8018f9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018fc:	83 ec 0c             	sub    $0xc,%esp
  8018ff:	ff 75 e0             	pushl  -0x20(%ebp)
  801902:	e8 3e 05 00 00       	call   801e45 <pageref>
  801907:	89 c3                	mov    %eax,%ebx
  801909:	89 3c 24             	mov    %edi,(%esp)
  80190c:	e8 34 05 00 00       	call   801e45 <pageref>
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	39 c3                	cmp    %eax,%ebx
  801916:	0f 94 c1             	sete   %cl
  801919:	0f b6 c9             	movzbl %cl,%ecx
  80191c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80191f:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801925:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801928:	39 ce                	cmp    %ecx,%esi
  80192a:	74 1b                	je     801947 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80192c:	39 c3                	cmp    %eax,%ebx
  80192e:	75 c4                	jne    8018f4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801930:	8b 42 58             	mov    0x58(%edx),%eax
  801933:	ff 75 e4             	pushl  -0x1c(%ebp)
  801936:	50                   	push   %eax
  801937:	56                   	push   %esi
  801938:	68 c0 25 80 00       	push   $0x8025c0
  80193d:	e8 2a e9 ff ff       	call   80026c <cprintf>
  801942:	83 c4 10             	add    $0x10,%esp
  801945:	eb ad                	jmp    8018f4 <_pipeisclosed+0xe>
	}
}
  801947:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80194a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80194d:	5b                   	pop    %ebx
  80194e:	5e                   	pop    %esi
  80194f:	5f                   	pop    %edi
  801950:	5d                   	pop    %ebp
  801951:	c3                   	ret    

00801952 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	57                   	push   %edi
  801956:	56                   	push   %esi
  801957:	53                   	push   %ebx
  801958:	83 ec 28             	sub    $0x28,%esp
  80195b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80195e:	56                   	push   %esi
  80195f:	e8 b7 f5 ff ff       	call   800f1b <fd2data>
  801964:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801966:	83 c4 10             	add    $0x10,%esp
  801969:	bf 00 00 00 00       	mov    $0x0,%edi
  80196e:	eb 4b                	jmp    8019bb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801970:	89 da                	mov    %ebx,%edx
  801972:	89 f0                	mov    %esi,%eax
  801974:	e8 6d ff ff ff       	call   8018e6 <_pipeisclosed>
  801979:	85 c0                	test   %eax,%eax
  80197b:	75 48                	jne    8019c5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80197d:	e8 79 f3 ff ff       	call   800cfb <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801982:	8b 43 04             	mov    0x4(%ebx),%eax
  801985:	8b 0b                	mov    (%ebx),%ecx
  801987:	8d 51 20             	lea    0x20(%ecx),%edx
  80198a:	39 d0                	cmp    %edx,%eax
  80198c:	73 e2                	jae    801970 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80198e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801991:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801995:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801998:	89 c2                	mov    %eax,%edx
  80199a:	c1 fa 1f             	sar    $0x1f,%edx
  80199d:	89 d1                	mov    %edx,%ecx
  80199f:	c1 e9 1b             	shr    $0x1b,%ecx
  8019a2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019a5:	83 e2 1f             	and    $0x1f,%edx
  8019a8:	29 ca                	sub    %ecx,%edx
  8019aa:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019ae:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019b2:	83 c0 01             	add    $0x1,%eax
  8019b5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019b8:	83 c7 01             	add    $0x1,%edi
  8019bb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019be:	75 c2                	jne    801982 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c3:	eb 05                	jmp    8019ca <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019c5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019cd:	5b                   	pop    %ebx
  8019ce:	5e                   	pop    %esi
  8019cf:	5f                   	pop    %edi
  8019d0:	5d                   	pop    %ebp
  8019d1:	c3                   	ret    

008019d2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	57                   	push   %edi
  8019d6:	56                   	push   %esi
  8019d7:	53                   	push   %ebx
  8019d8:	83 ec 18             	sub    $0x18,%esp
  8019db:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019de:	57                   	push   %edi
  8019df:	e8 37 f5 ff ff       	call   800f1b <fd2data>
  8019e4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e6:	83 c4 10             	add    $0x10,%esp
  8019e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ee:	eb 3d                	jmp    801a2d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019f0:	85 db                	test   %ebx,%ebx
  8019f2:	74 04                	je     8019f8 <devpipe_read+0x26>
				return i;
  8019f4:	89 d8                	mov    %ebx,%eax
  8019f6:	eb 44                	jmp    801a3c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019f8:	89 f2                	mov    %esi,%edx
  8019fa:	89 f8                	mov    %edi,%eax
  8019fc:	e8 e5 fe ff ff       	call   8018e6 <_pipeisclosed>
  801a01:	85 c0                	test   %eax,%eax
  801a03:	75 32                	jne    801a37 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a05:	e8 f1 f2 ff ff       	call   800cfb <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a0a:	8b 06                	mov    (%esi),%eax
  801a0c:	3b 46 04             	cmp    0x4(%esi),%eax
  801a0f:	74 df                	je     8019f0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a11:	99                   	cltd   
  801a12:	c1 ea 1b             	shr    $0x1b,%edx
  801a15:	01 d0                	add    %edx,%eax
  801a17:	83 e0 1f             	and    $0x1f,%eax
  801a1a:	29 d0                	sub    %edx,%eax
  801a1c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a24:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a27:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a2a:	83 c3 01             	add    $0x1,%ebx
  801a2d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a30:	75 d8                	jne    801a0a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a32:	8b 45 10             	mov    0x10(%ebp),%eax
  801a35:	eb 05                	jmp    801a3c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a37:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a3f:	5b                   	pop    %ebx
  801a40:	5e                   	pop    %esi
  801a41:	5f                   	pop    %edi
  801a42:	5d                   	pop    %ebp
  801a43:	c3                   	ret    

00801a44 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	56                   	push   %esi
  801a48:	53                   	push   %ebx
  801a49:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4f:	50                   	push   %eax
  801a50:	e8 dd f4 ff ff       	call   800f32 <fd_alloc>
  801a55:	83 c4 10             	add    $0x10,%esp
  801a58:	89 c2                	mov    %eax,%edx
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	0f 88 2c 01 00 00    	js     801b8e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a62:	83 ec 04             	sub    $0x4,%esp
  801a65:	68 07 04 00 00       	push   $0x407
  801a6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a6d:	6a 00                	push   $0x0
  801a6f:	e8 a6 f2 ff ff       	call   800d1a <sys_page_alloc>
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	89 c2                	mov    %eax,%edx
  801a79:	85 c0                	test   %eax,%eax
  801a7b:	0f 88 0d 01 00 00    	js     801b8e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a81:	83 ec 0c             	sub    $0xc,%esp
  801a84:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a87:	50                   	push   %eax
  801a88:	e8 a5 f4 ff ff       	call   800f32 <fd_alloc>
  801a8d:	89 c3                	mov    %eax,%ebx
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	85 c0                	test   %eax,%eax
  801a94:	0f 88 e2 00 00 00    	js     801b7c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a9a:	83 ec 04             	sub    $0x4,%esp
  801a9d:	68 07 04 00 00       	push   $0x407
  801aa2:	ff 75 f0             	pushl  -0x10(%ebp)
  801aa5:	6a 00                	push   $0x0
  801aa7:	e8 6e f2 ff ff       	call   800d1a <sys_page_alloc>
  801aac:	89 c3                	mov    %eax,%ebx
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	0f 88 c3 00 00 00    	js     801b7c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ab9:	83 ec 0c             	sub    $0xc,%esp
  801abc:	ff 75 f4             	pushl  -0xc(%ebp)
  801abf:	e8 57 f4 ff ff       	call   800f1b <fd2data>
  801ac4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac6:	83 c4 0c             	add    $0xc,%esp
  801ac9:	68 07 04 00 00       	push   $0x407
  801ace:	50                   	push   %eax
  801acf:	6a 00                	push   $0x0
  801ad1:	e8 44 f2 ff ff       	call   800d1a <sys_page_alloc>
  801ad6:	89 c3                	mov    %eax,%ebx
  801ad8:	83 c4 10             	add    $0x10,%esp
  801adb:	85 c0                	test   %eax,%eax
  801add:	0f 88 89 00 00 00    	js     801b6c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ae3:	83 ec 0c             	sub    $0xc,%esp
  801ae6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ae9:	e8 2d f4 ff ff       	call   800f1b <fd2data>
  801aee:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801af5:	50                   	push   %eax
  801af6:	6a 00                	push   $0x0
  801af8:	56                   	push   %esi
  801af9:	6a 00                	push   $0x0
  801afb:	e8 5d f2 ff ff       	call   800d5d <sys_page_map>
  801b00:	89 c3                	mov    %eax,%ebx
  801b02:	83 c4 20             	add    $0x20,%esp
  801b05:	85 c0                	test   %eax,%eax
  801b07:	78 55                	js     801b5e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b09:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b12:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b17:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b1e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b27:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b2c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b33:	83 ec 0c             	sub    $0xc,%esp
  801b36:	ff 75 f4             	pushl  -0xc(%ebp)
  801b39:	e8 cd f3 ff ff       	call   800f0b <fd2num>
  801b3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b41:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b43:	83 c4 04             	add    $0x4,%esp
  801b46:	ff 75 f0             	pushl  -0x10(%ebp)
  801b49:	e8 bd f3 ff ff       	call   800f0b <fd2num>
  801b4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b51:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	ba 00 00 00 00       	mov    $0x0,%edx
  801b5c:	eb 30                	jmp    801b8e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b5e:	83 ec 08             	sub    $0x8,%esp
  801b61:	56                   	push   %esi
  801b62:	6a 00                	push   $0x0
  801b64:	e8 36 f2 ff ff       	call   800d9f <sys_page_unmap>
  801b69:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b6c:	83 ec 08             	sub    $0x8,%esp
  801b6f:	ff 75 f0             	pushl  -0x10(%ebp)
  801b72:	6a 00                	push   $0x0
  801b74:	e8 26 f2 ff ff       	call   800d9f <sys_page_unmap>
  801b79:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b7c:	83 ec 08             	sub    $0x8,%esp
  801b7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b82:	6a 00                	push   $0x0
  801b84:	e8 16 f2 ff ff       	call   800d9f <sys_page_unmap>
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b8e:	89 d0                	mov    %edx,%eax
  801b90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b93:	5b                   	pop    %ebx
  801b94:	5e                   	pop    %esi
  801b95:	5d                   	pop    %ebp
  801b96:	c3                   	ret    

00801b97 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba0:	50                   	push   %eax
  801ba1:	ff 75 08             	pushl  0x8(%ebp)
  801ba4:	e8 d8 f3 ff ff       	call   800f81 <fd_lookup>
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	85 c0                	test   %eax,%eax
  801bae:	78 18                	js     801bc8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bb0:	83 ec 0c             	sub    $0xc,%esp
  801bb3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb6:	e8 60 f3 ff ff       	call   800f1b <fd2data>
	return _pipeisclosed(fd, p);
  801bbb:	89 c2                	mov    %eax,%edx
  801bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc0:	e8 21 fd ff ff       	call   8018e6 <_pipeisclosed>
  801bc5:	83 c4 10             	add    $0x10,%esp
}
  801bc8:	c9                   	leave  
  801bc9:	c3                   	ret    

00801bca <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bcd:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd2:	5d                   	pop    %ebp
  801bd3:	c3                   	ret    

00801bd4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bda:	68 d8 25 80 00       	push   $0x8025d8
  801bdf:	ff 75 0c             	pushl  0xc(%ebp)
  801be2:	e8 b9 ec ff ff       	call   8008a0 <strcpy>
	return 0;
}
  801be7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bec:	c9                   	leave  
  801bed:	c3                   	ret    

00801bee <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	57                   	push   %edi
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bfa:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bff:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c05:	eb 2d                	jmp    801c34 <devcons_write+0x46>
		m = n - tot;
  801c07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c0a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c0c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c0f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c14:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c17:	83 ec 04             	sub    $0x4,%esp
  801c1a:	53                   	push   %ebx
  801c1b:	03 45 0c             	add    0xc(%ebp),%eax
  801c1e:	50                   	push   %eax
  801c1f:	57                   	push   %edi
  801c20:	e8 0d ee ff ff       	call   800a32 <memmove>
		sys_cputs(buf, m);
  801c25:	83 c4 08             	add    $0x8,%esp
  801c28:	53                   	push   %ebx
  801c29:	57                   	push   %edi
  801c2a:	e8 2f f0 ff ff       	call   800c5e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c2f:	01 de                	add    %ebx,%esi
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	89 f0                	mov    %esi,%eax
  801c36:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c39:	72 cc                	jb     801c07 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3e:	5b                   	pop    %ebx
  801c3f:	5e                   	pop    %esi
  801c40:	5f                   	pop    %edi
  801c41:	5d                   	pop    %ebp
  801c42:	c3                   	ret    

00801c43 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	83 ec 08             	sub    $0x8,%esp
  801c49:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c4e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c52:	74 2a                	je     801c7e <devcons_read+0x3b>
  801c54:	eb 05                	jmp    801c5b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c56:	e8 a0 f0 ff ff       	call   800cfb <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c5b:	e8 1c f0 ff ff       	call   800c7c <sys_cgetc>
  801c60:	85 c0                	test   %eax,%eax
  801c62:	74 f2                	je     801c56 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c64:	85 c0                	test   %eax,%eax
  801c66:	78 16                	js     801c7e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c68:	83 f8 04             	cmp    $0x4,%eax
  801c6b:	74 0c                	je     801c79 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c70:	88 02                	mov    %al,(%edx)
	return 1;
  801c72:	b8 01 00 00 00       	mov    $0x1,%eax
  801c77:	eb 05                	jmp    801c7e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c79:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c7e:	c9                   	leave  
  801c7f:	c3                   	ret    

00801c80 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c86:	8b 45 08             	mov    0x8(%ebp),%eax
  801c89:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c8c:	6a 01                	push   $0x1
  801c8e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c91:	50                   	push   %eax
  801c92:	e8 c7 ef ff ff       	call   800c5e <sys_cputs>
}
  801c97:	83 c4 10             	add    $0x10,%esp
  801c9a:	c9                   	leave  
  801c9b:	c3                   	ret    

00801c9c <getchar>:

int
getchar(void)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ca2:	6a 01                	push   $0x1
  801ca4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ca7:	50                   	push   %eax
  801ca8:	6a 00                	push   $0x0
  801caa:	e8 38 f5 ff ff       	call   8011e7 <read>
	if (r < 0)
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	78 0f                	js     801cc5 <getchar+0x29>
		return r;
	if (r < 1)
  801cb6:	85 c0                	test   %eax,%eax
  801cb8:	7e 06                	jle    801cc0 <getchar+0x24>
		return -E_EOF;
	return c;
  801cba:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cbe:	eb 05                	jmp    801cc5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cc0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cc5:	c9                   	leave  
  801cc6:	c3                   	ret    

00801cc7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ccd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd0:	50                   	push   %eax
  801cd1:	ff 75 08             	pushl  0x8(%ebp)
  801cd4:	e8 a8 f2 ff ff       	call   800f81 <fd_lookup>
  801cd9:	83 c4 10             	add    $0x10,%esp
  801cdc:	85 c0                	test   %eax,%eax
  801cde:	78 11                	js     801cf1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ce9:	39 10                	cmp    %edx,(%eax)
  801ceb:	0f 94 c0             	sete   %al
  801cee:	0f b6 c0             	movzbl %al,%eax
}
  801cf1:	c9                   	leave  
  801cf2:	c3                   	ret    

00801cf3 <opencons>:

int
opencons(void)
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cf9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cfc:	50                   	push   %eax
  801cfd:	e8 30 f2 ff ff       	call   800f32 <fd_alloc>
  801d02:	83 c4 10             	add    $0x10,%esp
		return r;
  801d05:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d07:	85 c0                	test   %eax,%eax
  801d09:	78 3e                	js     801d49 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d0b:	83 ec 04             	sub    $0x4,%esp
  801d0e:	68 07 04 00 00       	push   $0x407
  801d13:	ff 75 f4             	pushl  -0xc(%ebp)
  801d16:	6a 00                	push   $0x0
  801d18:	e8 fd ef ff ff       	call   800d1a <sys_page_alloc>
  801d1d:	83 c4 10             	add    $0x10,%esp
		return r;
  801d20:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d22:	85 c0                	test   %eax,%eax
  801d24:	78 23                	js     801d49 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d26:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d34:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d3b:	83 ec 0c             	sub    $0xc,%esp
  801d3e:	50                   	push   %eax
  801d3f:	e8 c7 f1 ff ff       	call   800f0b <fd2num>
  801d44:	89 c2                	mov    %eax,%edx
  801d46:	83 c4 10             	add    $0x10,%esp
}
  801d49:	89 d0                	mov    %edx,%eax
  801d4b:	c9                   	leave  
  801d4c:	c3                   	ret    

00801d4d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d4d:	55                   	push   %ebp
  801d4e:	89 e5                	mov    %esp,%ebp
  801d50:	56                   	push   %esi
  801d51:	53                   	push   %ebx
  801d52:	8b 75 08             	mov    0x8(%ebp),%esi
  801d55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801d5b:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801d5d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801d62:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801d65:	83 ec 0c             	sub    $0xc,%esp
  801d68:	50                   	push   %eax
  801d69:	e8 5c f1 ff ff       	call   800eca <sys_ipc_recv>
  801d6e:	83 c4 10             	add    $0x10,%esp
  801d71:	85 c0                	test   %eax,%eax
  801d73:	79 16                	jns    801d8b <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801d75:	85 f6                	test   %esi,%esi
  801d77:	74 06                	je     801d7f <ipc_recv+0x32>
			*from_env_store = 0;
  801d79:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801d7f:	85 db                	test   %ebx,%ebx
  801d81:	74 2c                	je     801daf <ipc_recv+0x62>
			*perm_store = 0;
  801d83:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801d89:	eb 24                	jmp    801daf <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801d8b:	85 f6                	test   %esi,%esi
  801d8d:	74 0a                	je     801d99 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801d8f:	a1 20 60 80 00       	mov    0x806020,%eax
  801d94:	8b 40 74             	mov    0x74(%eax),%eax
  801d97:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801d99:	85 db                	test   %ebx,%ebx
  801d9b:	74 0a                	je     801da7 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801d9d:	a1 20 60 80 00       	mov    0x806020,%eax
  801da2:	8b 40 78             	mov    0x78(%eax),%eax
  801da5:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801da7:	a1 20 60 80 00       	mov    0x806020,%eax
  801dac:	8b 40 70             	mov    0x70(%eax),%eax
}
  801daf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db2:	5b                   	pop    %ebx
  801db3:	5e                   	pop    %esi
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    

00801db6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	57                   	push   %edi
  801dba:	56                   	push   %esi
  801dbb:	53                   	push   %ebx
  801dbc:	83 ec 0c             	sub    $0xc,%esp
  801dbf:	8b 7d 08             	mov    0x8(%ebp),%edi
  801dc2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801dc8:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801dca:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801dcf:	0f 44 d8             	cmove  %eax,%ebx
  801dd2:	eb 1e                	jmp    801df2 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801dd4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dd7:	74 14                	je     801ded <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801dd9:	83 ec 04             	sub    $0x4,%esp
  801ddc:	68 e4 25 80 00       	push   $0x8025e4
  801de1:	6a 44                	push   $0x44
  801de3:	68 10 26 80 00       	push   $0x802610
  801de8:	e8 a6 e3 ff ff       	call   800193 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801ded:	e8 09 ef ff ff       	call   800cfb <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801df2:	ff 75 14             	pushl  0x14(%ebp)
  801df5:	53                   	push   %ebx
  801df6:	56                   	push   %esi
  801df7:	57                   	push   %edi
  801df8:	e8 aa f0 ff ff       	call   800ea7 <sys_ipc_try_send>
  801dfd:	83 c4 10             	add    $0x10,%esp
  801e00:	85 c0                	test   %eax,%eax
  801e02:	78 d0                	js     801dd4 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801e04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e07:	5b                   	pop    %ebx
  801e08:	5e                   	pop    %esi
  801e09:	5f                   	pop    %edi
  801e0a:	5d                   	pop    %ebp
  801e0b:	c3                   	ret    

00801e0c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
  801e0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e12:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e17:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e1a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e20:	8b 52 50             	mov    0x50(%edx),%edx
  801e23:	39 ca                	cmp    %ecx,%edx
  801e25:	75 0d                	jne    801e34 <ipc_find_env+0x28>
			return envs[i].env_id;
  801e27:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e2a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e2f:	8b 40 48             	mov    0x48(%eax),%eax
  801e32:	eb 0f                	jmp    801e43 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e34:	83 c0 01             	add    $0x1,%eax
  801e37:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e3c:	75 d9                	jne    801e17 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e43:	5d                   	pop    %ebp
  801e44:	c3                   	ret    

00801e45 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e4b:	89 d0                	mov    %edx,%eax
  801e4d:	c1 e8 16             	shr    $0x16,%eax
  801e50:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e57:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e5c:	f6 c1 01             	test   $0x1,%cl
  801e5f:	74 1d                	je     801e7e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e61:	c1 ea 0c             	shr    $0xc,%edx
  801e64:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e6b:	f6 c2 01             	test   $0x1,%dl
  801e6e:	74 0e                	je     801e7e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e70:	c1 ea 0c             	shr    $0xc,%edx
  801e73:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e7a:	ef 
  801e7b:	0f b7 c0             	movzwl %ax,%eax
}
  801e7e:	5d                   	pop    %ebp
  801e7f:	c3                   	ret    

00801e80 <__udivdi3>:
  801e80:	55                   	push   %ebp
  801e81:	57                   	push   %edi
  801e82:	56                   	push   %esi
  801e83:	53                   	push   %ebx
  801e84:	83 ec 1c             	sub    $0x1c,%esp
  801e87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801e8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e97:	85 f6                	test   %esi,%esi
  801e99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e9d:	89 ca                	mov    %ecx,%edx
  801e9f:	89 f8                	mov    %edi,%eax
  801ea1:	75 3d                	jne    801ee0 <__udivdi3+0x60>
  801ea3:	39 cf                	cmp    %ecx,%edi
  801ea5:	0f 87 c5 00 00 00    	ja     801f70 <__udivdi3+0xf0>
  801eab:	85 ff                	test   %edi,%edi
  801ead:	89 fd                	mov    %edi,%ebp
  801eaf:	75 0b                	jne    801ebc <__udivdi3+0x3c>
  801eb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb6:	31 d2                	xor    %edx,%edx
  801eb8:	f7 f7                	div    %edi
  801eba:	89 c5                	mov    %eax,%ebp
  801ebc:	89 c8                	mov    %ecx,%eax
  801ebe:	31 d2                	xor    %edx,%edx
  801ec0:	f7 f5                	div    %ebp
  801ec2:	89 c1                	mov    %eax,%ecx
  801ec4:	89 d8                	mov    %ebx,%eax
  801ec6:	89 cf                	mov    %ecx,%edi
  801ec8:	f7 f5                	div    %ebp
  801eca:	89 c3                	mov    %eax,%ebx
  801ecc:	89 d8                	mov    %ebx,%eax
  801ece:	89 fa                	mov    %edi,%edx
  801ed0:	83 c4 1c             	add    $0x1c,%esp
  801ed3:	5b                   	pop    %ebx
  801ed4:	5e                   	pop    %esi
  801ed5:	5f                   	pop    %edi
  801ed6:	5d                   	pop    %ebp
  801ed7:	c3                   	ret    
  801ed8:	90                   	nop
  801ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ee0:	39 ce                	cmp    %ecx,%esi
  801ee2:	77 74                	ja     801f58 <__udivdi3+0xd8>
  801ee4:	0f bd fe             	bsr    %esi,%edi
  801ee7:	83 f7 1f             	xor    $0x1f,%edi
  801eea:	0f 84 98 00 00 00    	je     801f88 <__udivdi3+0x108>
  801ef0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ef5:	89 f9                	mov    %edi,%ecx
  801ef7:	89 c5                	mov    %eax,%ebp
  801ef9:	29 fb                	sub    %edi,%ebx
  801efb:	d3 e6                	shl    %cl,%esi
  801efd:	89 d9                	mov    %ebx,%ecx
  801eff:	d3 ed                	shr    %cl,%ebp
  801f01:	89 f9                	mov    %edi,%ecx
  801f03:	d3 e0                	shl    %cl,%eax
  801f05:	09 ee                	or     %ebp,%esi
  801f07:	89 d9                	mov    %ebx,%ecx
  801f09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f0d:	89 d5                	mov    %edx,%ebp
  801f0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f13:	d3 ed                	shr    %cl,%ebp
  801f15:	89 f9                	mov    %edi,%ecx
  801f17:	d3 e2                	shl    %cl,%edx
  801f19:	89 d9                	mov    %ebx,%ecx
  801f1b:	d3 e8                	shr    %cl,%eax
  801f1d:	09 c2                	or     %eax,%edx
  801f1f:	89 d0                	mov    %edx,%eax
  801f21:	89 ea                	mov    %ebp,%edx
  801f23:	f7 f6                	div    %esi
  801f25:	89 d5                	mov    %edx,%ebp
  801f27:	89 c3                	mov    %eax,%ebx
  801f29:	f7 64 24 0c          	mull   0xc(%esp)
  801f2d:	39 d5                	cmp    %edx,%ebp
  801f2f:	72 10                	jb     801f41 <__udivdi3+0xc1>
  801f31:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f35:	89 f9                	mov    %edi,%ecx
  801f37:	d3 e6                	shl    %cl,%esi
  801f39:	39 c6                	cmp    %eax,%esi
  801f3b:	73 07                	jae    801f44 <__udivdi3+0xc4>
  801f3d:	39 d5                	cmp    %edx,%ebp
  801f3f:	75 03                	jne    801f44 <__udivdi3+0xc4>
  801f41:	83 eb 01             	sub    $0x1,%ebx
  801f44:	31 ff                	xor    %edi,%edi
  801f46:	89 d8                	mov    %ebx,%eax
  801f48:	89 fa                	mov    %edi,%edx
  801f4a:	83 c4 1c             	add    $0x1c,%esp
  801f4d:	5b                   	pop    %ebx
  801f4e:	5e                   	pop    %esi
  801f4f:	5f                   	pop    %edi
  801f50:	5d                   	pop    %ebp
  801f51:	c3                   	ret    
  801f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f58:	31 ff                	xor    %edi,%edi
  801f5a:	31 db                	xor    %ebx,%ebx
  801f5c:	89 d8                	mov    %ebx,%eax
  801f5e:	89 fa                	mov    %edi,%edx
  801f60:	83 c4 1c             	add    $0x1c,%esp
  801f63:	5b                   	pop    %ebx
  801f64:	5e                   	pop    %esi
  801f65:	5f                   	pop    %edi
  801f66:	5d                   	pop    %ebp
  801f67:	c3                   	ret    
  801f68:	90                   	nop
  801f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f70:	89 d8                	mov    %ebx,%eax
  801f72:	f7 f7                	div    %edi
  801f74:	31 ff                	xor    %edi,%edi
  801f76:	89 c3                	mov    %eax,%ebx
  801f78:	89 d8                	mov    %ebx,%eax
  801f7a:	89 fa                	mov    %edi,%edx
  801f7c:	83 c4 1c             	add    $0x1c,%esp
  801f7f:	5b                   	pop    %ebx
  801f80:	5e                   	pop    %esi
  801f81:	5f                   	pop    %edi
  801f82:	5d                   	pop    %ebp
  801f83:	c3                   	ret    
  801f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f88:	39 ce                	cmp    %ecx,%esi
  801f8a:	72 0c                	jb     801f98 <__udivdi3+0x118>
  801f8c:	31 db                	xor    %ebx,%ebx
  801f8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f92:	0f 87 34 ff ff ff    	ja     801ecc <__udivdi3+0x4c>
  801f98:	bb 01 00 00 00       	mov    $0x1,%ebx
  801f9d:	e9 2a ff ff ff       	jmp    801ecc <__udivdi3+0x4c>
  801fa2:	66 90                	xchg   %ax,%ax
  801fa4:	66 90                	xchg   %ax,%ax
  801fa6:	66 90                	xchg   %ax,%ax
  801fa8:	66 90                	xchg   %ax,%ax
  801faa:	66 90                	xchg   %ax,%ax
  801fac:	66 90                	xchg   %ax,%ax
  801fae:	66 90                	xchg   %ax,%ax

00801fb0 <__umoddi3>:
  801fb0:	55                   	push   %ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 1c             	sub    $0x1c,%esp
  801fb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801fbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fc7:	85 d2                	test   %edx,%edx
  801fc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801fcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fd1:	89 f3                	mov    %esi,%ebx
  801fd3:	89 3c 24             	mov    %edi,(%esp)
  801fd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fda:	75 1c                	jne    801ff8 <__umoddi3+0x48>
  801fdc:	39 f7                	cmp    %esi,%edi
  801fde:	76 50                	jbe    802030 <__umoddi3+0x80>
  801fe0:	89 c8                	mov    %ecx,%eax
  801fe2:	89 f2                	mov    %esi,%edx
  801fe4:	f7 f7                	div    %edi
  801fe6:	89 d0                	mov    %edx,%eax
  801fe8:	31 d2                	xor    %edx,%edx
  801fea:	83 c4 1c             	add    $0x1c,%esp
  801fed:	5b                   	pop    %ebx
  801fee:	5e                   	pop    %esi
  801fef:	5f                   	pop    %edi
  801ff0:	5d                   	pop    %ebp
  801ff1:	c3                   	ret    
  801ff2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ff8:	39 f2                	cmp    %esi,%edx
  801ffa:	89 d0                	mov    %edx,%eax
  801ffc:	77 52                	ja     802050 <__umoddi3+0xa0>
  801ffe:	0f bd ea             	bsr    %edx,%ebp
  802001:	83 f5 1f             	xor    $0x1f,%ebp
  802004:	75 5a                	jne    802060 <__umoddi3+0xb0>
  802006:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80200a:	0f 82 e0 00 00 00    	jb     8020f0 <__umoddi3+0x140>
  802010:	39 0c 24             	cmp    %ecx,(%esp)
  802013:	0f 86 d7 00 00 00    	jbe    8020f0 <__umoddi3+0x140>
  802019:	8b 44 24 08          	mov    0x8(%esp),%eax
  80201d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802021:	83 c4 1c             	add    $0x1c,%esp
  802024:	5b                   	pop    %ebx
  802025:	5e                   	pop    %esi
  802026:	5f                   	pop    %edi
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	85 ff                	test   %edi,%edi
  802032:	89 fd                	mov    %edi,%ebp
  802034:	75 0b                	jne    802041 <__umoddi3+0x91>
  802036:	b8 01 00 00 00       	mov    $0x1,%eax
  80203b:	31 d2                	xor    %edx,%edx
  80203d:	f7 f7                	div    %edi
  80203f:	89 c5                	mov    %eax,%ebp
  802041:	89 f0                	mov    %esi,%eax
  802043:	31 d2                	xor    %edx,%edx
  802045:	f7 f5                	div    %ebp
  802047:	89 c8                	mov    %ecx,%eax
  802049:	f7 f5                	div    %ebp
  80204b:	89 d0                	mov    %edx,%eax
  80204d:	eb 99                	jmp    801fe8 <__umoddi3+0x38>
  80204f:	90                   	nop
  802050:	89 c8                	mov    %ecx,%eax
  802052:	89 f2                	mov    %esi,%edx
  802054:	83 c4 1c             	add    $0x1c,%esp
  802057:	5b                   	pop    %ebx
  802058:	5e                   	pop    %esi
  802059:	5f                   	pop    %edi
  80205a:	5d                   	pop    %ebp
  80205b:	c3                   	ret    
  80205c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802060:	8b 34 24             	mov    (%esp),%esi
  802063:	bf 20 00 00 00       	mov    $0x20,%edi
  802068:	89 e9                	mov    %ebp,%ecx
  80206a:	29 ef                	sub    %ebp,%edi
  80206c:	d3 e0                	shl    %cl,%eax
  80206e:	89 f9                	mov    %edi,%ecx
  802070:	89 f2                	mov    %esi,%edx
  802072:	d3 ea                	shr    %cl,%edx
  802074:	89 e9                	mov    %ebp,%ecx
  802076:	09 c2                	or     %eax,%edx
  802078:	89 d8                	mov    %ebx,%eax
  80207a:	89 14 24             	mov    %edx,(%esp)
  80207d:	89 f2                	mov    %esi,%edx
  80207f:	d3 e2                	shl    %cl,%edx
  802081:	89 f9                	mov    %edi,%ecx
  802083:	89 54 24 04          	mov    %edx,0x4(%esp)
  802087:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80208b:	d3 e8                	shr    %cl,%eax
  80208d:	89 e9                	mov    %ebp,%ecx
  80208f:	89 c6                	mov    %eax,%esi
  802091:	d3 e3                	shl    %cl,%ebx
  802093:	89 f9                	mov    %edi,%ecx
  802095:	89 d0                	mov    %edx,%eax
  802097:	d3 e8                	shr    %cl,%eax
  802099:	89 e9                	mov    %ebp,%ecx
  80209b:	09 d8                	or     %ebx,%eax
  80209d:	89 d3                	mov    %edx,%ebx
  80209f:	89 f2                	mov    %esi,%edx
  8020a1:	f7 34 24             	divl   (%esp)
  8020a4:	89 d6                	mov    %edx,%esi
  8020a6:	d3 e3                	shl    %cl,%ebx
  8020a8:	f7 64 24 04          	mull   0x4(%esp)
  8020ac:	39 d6                	cmp    %edx,%esi
  8020ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020b2:	89 d1                	mov    %edx,%ecx
  8020b4:	89 c3                	mov    %eax,%ebx
  8020b6:	72 08                	jb     8020c0 <__umoddi3+0x110>
  8020b8:	75 11                	jne    8020cb <__umoddi3+0x11b>
  8020ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8020be:	73 0b                	jae    8020cb <__umoddi3+0x11b>
  8020c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8020c4:	1b 14 24             	sbb    (%esp),%edx
  8020c7:	89 d1                	mov    %edx,%ecx
  8020c9:	89 c3                	mov    %eax,%ebx
  8020cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020cf:	29 da                	sub    %ebx,%edx
  8020d1:	19 ce                	sbb    %ecx,%esi
  8020d3:	89 f9                	mov    %edi,%ecx
  8020d5:	89 f0                	mov    %esi,%eax
  8020d7:	d3 e0                	shl    %cl,%eax
  8020d9:	89 e9                	mov    %ebp,%ecx
  8020db:	d3 ea                	shr    %cl,%edx
  8020dd:	89 e9                	mov    %ebp,%ecx
  8020df:	d3 ee                	shr    %cl,%esi
  8020e1:	09 d0                	or     %edx,%eax
  8020e3:	89 f2                	mov    %esi,%edx
  8020e5:	83 c4 1c             	add    $0x1c,%esp
  8020e8:	5b                   	pop    %ebx
  8020e9:	5e                   	pop    %esi
  8020ea:	5f                   	pop    %edi
  8020eb:	5d                   	pop    %ebp
  8020ec:	c3                   	ret    
  8020ed:	8d 76 00             	lea    0x0(%esi),%esi
  8020f0:	29 f9                	sub    %edi,%ecx
  8020f2:	19 d6                	sbb    %edx,%esi
  8020f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020fc:	e9 18 ff ff ff       	jmp    802019 <__umoddi3+0x69>
