
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 53 01 00 00       	call   800184 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 40 80 00    	pushl  0x804000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 a8 08 00 00       	call   8008f1 <strcpy>
	exit();
  800049:	e8 7c 01 00 00       	call   8001ca <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 f2 0c 00 00       	call   800d6b <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 0c 2a 80 00       	push   $0x802a0c
  800086:	6a 13                	push   $0x13
  800088:	68 1f 2a 80 00       	push   $0x802a1f
  80008d:	e8 52 01 00 00       	call   8001e4 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 9b 0f 00 00       	call   801032 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 4b 2e 80 00       	push   $0x802e4b
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 1f 2a 80 00       	push   $0x802a1f
  8000aa:	e8 35 01 00 00       	call   8001e4 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 40 80 00    	pushl  0x804004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 2b 08 00 00       	call   8008f1 <strcpy>
		exit();
  8000c6:	e8 ff 00 00 00       	call   8001ca <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	cprintf("here\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 33 2a 80 00       	push   $0x802a33
  8000d6:	e8 e2 01 00 00       	call   8002bd <cprintf>
	wait(r);
  8000db:	89 1c 24             	mov    %ebx,(%esp)
  8000de:	e8 e5 22 00 00       	call   8023c8 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000e3:	83 c4 08             	add    $0x8,%esp
  8000e6:	ff 35 04 40 80 00    	pushl  0x804004
  8000ec:	68 00 00 00 a0       	push   $0xa0000000
  8000f1:	e8 a5 08 00 00       	call   80099b <strcmp>
  8000f6:	83 c4 08             	add    $0x8,%esp
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	ba 06 2a 80 00       	mov    $0x802a06,%edx
  800100:	b8 00 2a 80 00       	mov    $0x802a00,%eax
  800105:	0f 45 c2             	cmovne %edx,%eax
  800108:	50                   	push   %eax
  800109:	68 39 2a 80 00       	push   $0x802a39
  80010e:	e8 aa 01 00 00       	call   8002bd <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800113:	6a 00                	push   $0x0
  800115:	68 54 2a 80 00       	push   $0x802a54
  80011a:	68 59 2a 80 00       	push   $0x802a59
  80011f:	68 58 2a 80 00       	push   $0x802a58
  800124:	e8 d0 1e 00 00       	call   801ff9 <spawnl>
  800129:	83 c4 20             	add    $0x20,%esp
  80012c:	85 c0                	test   %eax,%eax
  80012e:	79 12                	jns    800142 <umain+0xef>
		panic("spawn: %e", r);
  800130:	50                   	push   %eax
  800131:	68 66 2a 80 00       	push   $0x802a66
  800136:	6a 22                	push   $0x22
  800138:	68 1f 2a 80 00       	push   $0x802a1f
  80013d:	e8 a2 00 00 00       	call   8001e4 <_panic>
	wait(r);
  800142:	83 ec 0c             	sub    $0xc,%esp
  800145:	50                   	push   %eax
  800146:	e8 7d 22 00 00       	call   8023c8 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80014b:	83 c4 08             	add    $0x8,%esp
  80014e:	ff 35 00 40 80 00    	pushl  0x804000
  800154:	68 00 00 00 a0       	push   $0xa0000000
  800159:	e8 3d 08 00 00       	call   80099b <strcmp>
  80015e:	83 c4 08             	add    $0x8,%esp
  800161:	85 c0                	test   %eax,%eax
  800163:	ba 06 2a 80 00       	mov    $0x802a06,%edx
  800168:	b8 00 2a 80 00       	mov    $0x802a00,%eax
  80016d:	0f 45 c2             	cmovne %edx,%eax
  800170:	50                   	push   %eax
  800171:	68 70 2a 80 00       	push   $0x802a70
  800176:	e8 42 01 00 00       	call   8002bd <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80017b:	cc                   	int3   

	breakpoint();
}
  80017c:	83 c4 10             	add    $0x10,%esp
  80017f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80018c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80018f:	e8 99 0b 00 00       	call   800d2d <sys_getenvid>
  800194:	25 ff 03 00 00       	and    $0x3ff,%eax
  800199:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80019c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a1:	a3 08 50 80 00       	mov    %eax,0x805008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001a6:	85 db                	test   %ebx,%ebx
  8001a8:	7e 07                	jle    8001b1 <libmain+0x2d>
		binaryname = argv[0];
  8001aa:	8b 06                	mov    (%esi),%eax
  8001ac:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001b1:	83 ec 08             	sub    $0x8,%esp
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	e8 98 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001bb:	e8 0a 00 00 00       	call   8001ca <exit>
}
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001c6:	5b                   	pop    %ebx
  8001c7:	5e                   	pop    %esi
  8001c8:	5d                   	pop    %ebp
  8001c9:	c3                   	ret    

008001ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ca:	55                   	push   %ebp
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001d0:	e8 5a 12 00 00       	call   80142f <close_all>
	sys_env_destroy(0);
  8001d5:	83 ec 0c             	sub    $0xc,%esp
  8001d8:	6a 00                	push   $0x0
  8001da:	e8 0d 0b 00 00       	call   800cec <sys_env_destroy>
}
  8001df:	83 c4 10             	add    $0x10,%esp
  8001e2:	c9                   	leave  
  8001e3:	c3                   	ret    

008001e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ec:	8b 35 08 40 80 00    	mov    0x804008,%esi
  8001f2:	e8 36 0b 00 00       	call   800d2d <sys_getenvid>
  8001f7:	83 ec 0c             	sub    $0xc,%esp
  8001fa:	ff 75 0c             	pushl  0xc(%ebp)
  8001fd:	ff 75 08             	pushl  0x8(%ebp)
  800200:	56                   	push   %esi
  800201:	50                   	push   %eax
  800202:	68 b4 2a 80 00       	push   $0x802ab4
  800207:	e8 b1 00 00 00       	call   8002bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020c:	83 c4 18             	add    $0x18,%esp
  80020f:	53                   	push   %ebx
  800210:	ff 75 10             	pushl  0x10(%ebp)
  800213:	e8 54 00 00 00       	call   80026c <vcprintf>
	cprintf("\n");
  800218:	c7 04 24 4a 30 80 00 	movl   $0x80304a,(%esp)
  80021f:	e8 99 00 00 00       	call   8002bd <cprintf>
  800224:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800227:	cc                   	int3   
  800228:	eb fd                	jmp    800227 <_panic+0x43>

0080022a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	53                   	push   %ebx
  80022e:	83 ec 04             	sub    $0x4,%esp
  800231:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800234:	8b 13                	mov    (%ebx),%edx
  800236:	8d 42 01             	lea    0x1(%edx),%eax
  800239:	89 03                	mov    %eax,(%ebx)
  80023b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800242:	3d ff 00 00 00       	cmp    $0xff,%eax
  800247:	75 1a                	jne    800263 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800249:	83 ec 08             	sub    $0x8,%esp
  80024c:	68 ff 00 00 00       	push   $0xff
  800251:	8d 43 08             	lea    0x8(%ebx),%eax
  800254:	50                   	push   %eax
  800255:	e8 55 0a 00 00       	call   800caf <sys_cputs>
		b->idx = 0;
  80025a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800260:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800263:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800267:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800275:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027c:	00 00 00 
	b.cnt = 0;
  80027f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800286:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800289:	ff 75 0c             	pushl  0xc(%ebp)
  80028c:	ff 75 08             	pushl  0x8(%ebp)
  80028f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800295:	50                   	push   %eax
  800296:	68 2a 02 80 00       	push   $0x80022a
  80029b:	e8 54 01 00 00       	call   8003f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a0:	83 c4 08             	add    $0x8,%esp
  8002a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002af:	50                   	push   %eax
  8002b0:	e8 fa 09 00 00       	call   800caf <sys_cputs>

	return b.cnt;
}
  8002b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bb:	c9                   	leave  
  8002bc:	c3                   	ret    

008002bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c6:	50                   	push   %eax
  8002c7:	ff 75 08             	pushl  0x8(%ebp)
  8002ca:	e8 9d ff ff ff       	call   80026c <vcprintf>
	va_end(ap);

	return cnt;
}
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    

008002d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	57                   	push   %edi
  8002d5:	56                   	push   %esi
  8002d6:	53                   	push   %ebx
  8002d7:	83 ec 1c             	sub    $0x1c,%esp
  8002da:	89 c7                	mov    %eax,%edi
  8002dc:	89 d6                	mov    %edx,%esi
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002f8:	39 d3                	cmp    %edx,%ebx
  8002fa:	72 05                	jb     800301 <printnum+0x30>
  8002fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ff:	77 45                	ja     800346 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800301:	83 ec 0c             	sub    $0xc,%esp
  800304:	ff 75 18             	pushl  0x18(%ebp)
  800307:	8b 45 14             	mov    0x14(%ebp),%eax
  80030a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80030d:	53                   	push   %ebx
  80030e:	ff 75 10             	pushl  0x10(%ebp)
  800311:	83 ec 08             	sub    $0x8,%esp
  800314:	ff 75 e4             	pushl  -0x1c(%ebp)
  800317:	ff 75 e0             	pushl  -0x20(%ebp)
  80031a:	ff 75 dc             	pushl  -0x24(%ebp)
  80031d:	ff 75 d8             	pushl  -0x28(%ebp)
  800320:	e8 3b 24 00 00       	call   802760 <__udivdi3>
  800325:	83 c4 18             	add    $0x18,%esp
  800328:	52                   	push   %edx
  800329:	50                   	push   %eax
  80032a:	89 f2                	mov    %esi,%edx
  80032c:	89 f8                	mov    %edi,%eax
  80032e:	e8 9e ff ff ff       	call   8002d1 <printnum>
  800333:	83 c4 20             	add    $0x20,%esp
  800336:	eb 18                	jmp    800350 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800338:	83 ec 08             	sub    $0x8,%esp
  80033b:	56                   	push   %esi
  80033c:	ff 75 18             	pushl  0x18(%ebp)
  80033f:	ff d7                	call   *%edi
  800341:	83 c4 10             	add    $0x10,%esp
  800344:	eb 03                	jmp    800349 <printnum+0x78>
  800346:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800349:	83 eb 01             	sub    $0x1,%ebx
  80034c:	85 db                	test   %ebx,%ebx
  80034e:	7f e8                	jg     800338 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800350:	83 ec 08             	sub    $0x8,%esp
  800353:	56                   	push   %esi
  800354:	83 ec 04             	sub    $0x4,%esp
  800357:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035a:	ff 75 e0             	pushl  -0x20(%ebp)
  80035d:	ff 75 dc             	pushl  -0x24(%ebp)
  800360:	ff 75 d8             	pushl  -0x28(%ebp)
  800363:	e8 28 25 00 00       	call   802890 <__umoddi3>
  800368:	83 c4 14             	add    $0x14,%esp
  80036b:	0f be 80 d7 2a 80 00 	movsbl 0x802ad7(%eax),%eax
  800372:	50                   	push   %eax
  800373:	ff d7                	call   *%edi
}
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037b:	5b                   	pop    %ebx
  80037c:	5e                   	pop    %esi
  80037d:	5f                   	pop    %edi
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800383:	83 fa 01             	cmp    $0x1,%edx
  800386:	7e 0e                	jle    800396 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800388:	8b 10                	mov    (%eax),%edx
  80038a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80038d:	89 08                	mov    %ecx,(%eax)
  80038f:	8b 02                	mov    (%edx),%eax
  800391:	8b 52 04             	mov    0x4(%edx),%edx
  800394:	eb 22                	jmp    8003b8 <getuint+0x38>
	else if (lflag)
  800396:	85 d2                	test   %edx,%edx
  800398:	74 10                	je     8003aa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80039a:	8b 10                	mov    (%eax),%edx
  80039c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039f:	89 08                	mov    %ecx,(%eax)
  8003a1:	8b 02                	mov    (%edx),%eax
  8003a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a8:	eb 0e                	jmp    8003b8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003aa:	8b 10                	mov    (%eax),%edx
  8003ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003af:	89 08                	mov    %ecx,(%eax)
  8003b1:	8b 02                	mov    (%edx),%eax
  8003b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b8:	5d                   	pop    %ebp
  8003b9:	c3                   	ret    

008003ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c4:	8b 10                	mov    (%eax),%edx
  8003c6:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c9:	73 0a                	jae    8003d5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003cb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003ce:	89 08                	mov    %ecx,(%eax)
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d3:	88 02                	mov    %al,(%edx)
}
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e0:	50                   	push   %eax
  8003e1:	ff 75 10             	pushl  0x10(%ebp)
  8003e4:	ff 75 0c             	pushl  0xc(%ebp)
  8003e7:	ff 75 08             	pushl  0x8(%ebp)
  8003ea:	e8 05 00 00 00       	call   8003f4 <vprintfmt>
	va_end(ap);
}
  8003ef:	83 c4 10             	add    $0x10,%esp
  8003f2:	c9                   	leave  
  8003f3:	c3                   	ret    

008003f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	57                   	push   %edi
  8003f8:	56                   	push   %esi
  8003f9:	53                   	push   %ebx
  8003fa:	83 ec 2c             	sub    $0x2c,%esp
  8003fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800400:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800403:	8b 7d 10             	mov    0x10(%ebp),%edi
  800406:	eb 12                	jmp    80041a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800408:	85 c0                	test   %eax,%eax
  80040a:	0f 84 38 04 00 00    	je     800848 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800410:	83 ec 08             	sub    $0x8,%esp
  800413:	53                   	push   %ebx
  800414:	50                   	push   %eax
  800415:	ff d6                	call   *%esi
  800417:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80041a:	83 c7 01             	add    $0x1,%edi
  80041d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800421:	83 f8 25             	cmp    $0x25,%eax
  800424:	75 e2                	jne    800408 <vprintfmt+0x14>
  800426:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80042a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800431:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800438:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80043f:	ba 00 00 00 00       	mov    $0x0,%edx
  800444:	eb 07                	jmp    80044d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  800449:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8d 47 01             	lea    0x1(%edi),%eax
  800450:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800453:	0f b6 07             	movzbl (%edi),%eax
  800456:	0f b6 c8             	movzbl %al,%ecx
  800459:	83 e8 23             	sub    $0x23,%eax
  80045c:	3c 55                	cmp    $0x55,%al
  80045e:	0f 87 c9 03 00 00    	ja     80082d <vprintfmt+0x439>
  800464:	0f b6 c0             	movzbl %al,%eax
  800467:	ff 24 85 20 2c 80 00 	jmp    *0x802c20(,%eax,4)
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800471:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800475:	eb d6                	jmp    80044d <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  800477:	c7 05 00 50 80 00 00 	movl   $0x0,0x805000
  80047e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  800484:	eb 94                	jmp    80041a <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  800486:	c7 05 00 50 80 00 01 	movl   $0x1,0x805000
  80048d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  800493:	eb 85                	jmp    80041a <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  800495:	c7 05 00 50 80 00 02 	movl   $0x2,0x805000
  80049c:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  8004a2:	e9 73 ff ff ff       	jmp    80041a <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  8004a7:	c7 05 00 50 80 00 03 	movl   $0x3,0x805000
  8004ae:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  8004b4:	e9 61 ff ff ff       	jmp    80041a <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  8004b9:	c7 05 00 50 80 00 04 	movl   $0x4,0x805000
  8004c0:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  8004c6:	e9 4f ff ff ff       	jmp    80041a <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  8004cb:	c7 05 00 50 80 00 05 	movl   $0x5,0x805000
  8004d2:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  8004d8:	e9 3d ff ff ff       	jmp    80041a <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  8004dd:	c7 05 00 50 80 00 06 	movl   $0x6,0x805000
  8004e4:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  8004ea:	e9 2b ff ff ff       	jmp    80041a <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  8004ef:	c7 05 00 50 80 00 07 	movl   $0x7,0x805000
  8004f6:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8004fc:	e9 19 ff ff ff       	jmp    80041a <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800501:	c7 05 00 50 80 00 08 	movl   $0x8,0x805000
  800508:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  80050e:	e9 07 ff ff ff       	jmp    80041a <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  800513:	c7 05 00 50 80 00 09 	movl   $0x9,0x805000
  80051a:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800520:	e9 f5 fe ff ff       	jmp    80041a <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800525:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800528:	b8 00 00 00 00       	mov    $0x0,%eax
  80052d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800530:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800533:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800537:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80053a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80053d:	83 fa 09             	cmp    $0x9,%edx
  800540:	77 3f                	ja     800581 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800542:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800545:	eb e9                	jmp    800530 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8d 48 04             	lea    0x4(%eax),%ecx
  80054d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800550:	8b 00                	mov    (%eax),%eax
  800552:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800555:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800558:	eb 2d                	jmp    800587 <vprintfmt+0x193>
  80055a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80055d:	85 c0                	test   %eax,%eax
  80055f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800564:	0f 49 c8             	cmovns %eax,%ecx
  800567:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056d:	e9 db fe ff ff       	jmp    80044d <vprintfmt+0x59>
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800575:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80057c:	e9 cc fe ff ff       	jmp    80044d <vprintfmt+0x59>
  800581:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800584:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800587:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058b:	0f 89 bc fe ff ff    	jns    80044d <vprintfmt+0x59>
				width = precision, precision = -1;
  800591:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800594:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800597:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059e:	e9 aa fe ff ff       	jmp    80044d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005a9:	e9 9f fe ff ff       	jmp    80044d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	53                   	push   %ebx
  8005bb:	ff 30                	pushl  (%eax)
  8005bd:	ff d6                	call   *%esi
			break;
  8005bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005c5:	e9 50 fe ff ff       	jmp    80041a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	99                   	cltd   
  8005d6:	31 d0                	xor    %edx,%eax
  8005d8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005da:	83 f8 0f             	cmp    $0xf,%eax
  8005dd:	7f 0b                	jg     8005ea <vprintfmt+0x1f6>
  8005df:	8b 14 85 80 2d 80 00 	mov    0x802d80(,%eax,4),%edx
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	75 18                	jne    800602 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  8005ea:	50                   	push   %eax
  8005eb:	68 ef 2a 80 00       	push   $0x802aef
  8005f0:	53                   	push   %ebx
  8005f1:	56                   	push   %esi
  8005f2:	e8 e0 fd ff ff       	call   8003d7 <printfmt>
  8005f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005fd:	e9 18 fe ff ff       	jmp    80041a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800602:	52                   	push   %edx
  800603:	68 55 2f 80 00       	push   $0x802f55
  800608:	53                   	push   %ebx
  800609:	56                   	push   %esi
  80060a:	e8 c8 fd ff ff       	call   8003d7 <printfmt>
  80060f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800615:	e9 00 fe ff ff       	jmp    80041a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)
  800623:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800625:	85 ff                	test   %edi,%edi
  800627:	b8 e8 2a 80 00       	mov    $0x802ae8,%eax
  80062c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80062f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800633:	0f 8e 94 00 00 00    	jle    8006cd <vprintfmt+0x2d9>
  800639:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80063d:	0f 84 98 00 00 00    	je     8006db <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	ff 75 d0             	pushl  -0x30(%ebp)
  800649:	57                   	push   %edi
  80064a:	e8 81 02 00 00       	call   8008d0 <strnlen>
  80064f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800652:	29 c1                	sub    %eax,%ecx
  800654:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800657:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80065a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80065e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800661:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800664:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800666:	eb 0f                	jmp    800677 <vprintfmt+0x283>
					putch(padc, putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	ff 75 e0             	pushl  -0x20(%ebp)
  80066f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800671:	83 ef 01             	sub    $0x1,%edi
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	85 ff                	test   %edi,%edi
  800679:	7f ed                	jg     800668 <vprintfmt+0x274>
  80067b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80067e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800681:	85 c9                	test   %ecx,%ecx
  800683:	b8 00 00 00 00       	mov    $0x0,%eax
  800688:	0f 49 c1             	cmovns %ecx,%eax
  80068b:	29 c1                	sub    %eax,%ecx
  80068d:	89 75 08             	mov    %esi,0x8(%ebp)
  800690:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800693:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800696:	89 cb                	mov    %ecx,%ebx
  800698:	eb 4d                	jmp    8006e7 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80069a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80069e:	74 1b                	je     8006bb <vprintfmt+0x2c7>
  8006a0:	0f be c0             	movsbl %al,%eax
  8006a3:	83 e8 20             	sub    $0x20,%eax
  8006a6:	83 f8 5e             	cmp    $0x5e,%eax
  8006a9:	76 10                	jbe    8006bb <vprintfmt+0x2c7>
					putch('?', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	ff 75 0c             	pushl  0xc(%ebp)
  8006b1:	6a 3f                	push   $0x3f
  8006b3:	ff 55 08             	call   *0x8(%ebp)
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	eb 0d                	jmp    8006c8 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	ff 75 0c             	pushl  0xc(%ebp)
  8006c1:	52                   	push   %edx
  8006c2:	ff 55 08             	call   *0x8(%ebp)
  8006c5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c8:	83 eb 01             	sub    $0x1,%ebx
  8006cb:	eb 1a                	jmp    8006e7 <vprintfmt+0x2f3>
  8006cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006d9:	eb 0c                	jmp    8006e7 <vprintfmt+0x2f3>
  8006db:	89 75 08             	mov    %esi,0x8(%ebp)
  8006de:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006e7:	83 c7 01             	add    $0x1,%edi
  8006ea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ee:	0f be d0             	movsbl %al,%edx
  8006f1:	85 d2                	test   %edx,%edx
  8006f3:	74 23                	je     800718 <vprintfmt+0x324>
  8006f5:	85 f6                	test   %esi,%esi
  8006f7:	78 a1                	js     80069a <vprintfmt+0x2a6>
  8006f9:	83 ee 01             	sub    $0x1,%esi
  8006fc:	79 9c                	jns    80069a <vprintfmt+0x2a6>
  8006fe:	89 df                	mov    %ebx,%edi
  800700:	8b 75 08             	mov    0x8(%ebp),%esi
  800703:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800706:	eb 18                	jmp    800720 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	6a 20                	push   $0x20
  80070e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800710:	83 ef 01             	sub    $0x1,%edi
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	eb 08                	jmp    800720 <vprintfmt+0x32c>
  800718:	89 df                	mov    %ebx,%edi
  80071a:	8b 75 08             	mov    0x8(%ebp),%esi
  80071d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800720:	85 ff                	test   %edi,%edi
  800722:	7f e4                	jg     800708 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800727:	e9 ee fc ff ff       	jmp    80041a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072c:	83 fa 01             	cmp    $0x1,%edx
  80072f:	7e 16                	jle    800747 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 08             	lea    0x8(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	8b 50 04             	mov    0x4(%eax),%edx
  80073d:	8b 00                	mov    (%eax),%eax
  80073f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800742:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800745:	eb 32                	jmp    800779 <vprintfmt+0x385>
	else if (lflag)
  800747:	85 d2                	test   %edx,%edx
  800749:	74 18                	je     800763 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8d 50 04             	lea    0x4(%eax),%edx
  800751:	89 55 14             	mov    %edx,0x14(%ebp)
  800754:	8b 00                	mov    (%eax),%eax
  800756:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800759:	89 c1                	mov    %eax,%ecx
  80075b:	c1 f9 1f             	sar    $0x1f,%ecx
  80075e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800761:	eb 16                	jmp    800779 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8d 50 04             	lea    0x4(%eax),%edx
  800769:	89 55 14             	mov    %edx,0x14(%ebp)
  80076c:	8b 00                	mov    (%eax),%eax
  80076e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800771:	89 c1                	mov    %eax,%ecx
  800773:	c1 f9 1f             	sar    $0x1f,%ecx
  800776:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800779:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80077c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80077f:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800784:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800788:	79 6f                	jns    8007f9 <vprintfmt+0x405>
				putch('-', putdat);
  80078a:	83 ec 08             	sub    $0x8,%esp
  80078d:	53                   	push   %ebx
  80078e:	6a 2d                	push   $0x2d
  800790:	ff d6                	call   *%esi
				num = -(long long) num;
  800792:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800795:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800798:	f7 d8                	neg    %eax
  80079a:	83 d2 00             	adc    $0x0,%edx
  80079d:	f7 da                	neg    %edx
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 55                	jmp    8007f9 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a7:	e8 d4 fb ff ff       	call   800380 <getuint>
			base = 10;
  8007ac:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8007b1:	eb 46                	jmp    8007f9 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b6:	e8 c5 fb ff ff       	call   800380 <getuint>
			base = 8;
  8007bb:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8007c0:	eb 37                	jmp    8007f9 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  8007c2:	83 ec 08             	sub    $0x8,%esp
  8007c5:	53                   	push   %ebx
  8007c6:	6a 30                	push   $0x30
  8007c8:	ff d6                	call   *%esi
			putch('x', putdat);
  8007ca:	83 c4 08             	add    $0x8,%esp
  8007cd:	53                   	push   %ebx
  8007ce:	6a 78                	push   $0x78
  8007d0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8d 50 04             	lea    0x4(%eax),%edx
  8007d8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007db:	8b 00                	mov    (%eax),%eax
  8007dd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007e2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007e5:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8007ea:	eb 0d                	jmp    8007f9 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ef:	e8 8c fb ff ff       	call   800380 <getuint>
			base = 16;
  8007f4:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007f9:	83 ec 0c             	sub    $0xc,%esp
  8007fc:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800800:	51                   	push   %ecx
  800801:	ff 75 e0             	pushl  -0x20(%ebp)
  800804:	57                   	push   %edi
  800805:	52                   	push   %edx
  800806:	50                   	push   %eax
  800807:	89 da                	mov    %ebx,%edx
  800809:	89 f0                	mov    %esi,%eax
  80080b:	e8 c1 fa ff ff       	call   8002d1 <printnum>
			break;
  800810:	83 c4 20             	add    $0x20,%esp
  800813:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800816:	e9 ff fb ff ff       	jmp    80041a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	53                   	push   %ebx
  80081f:	51                   	push   %ecx
  800820:	ff d6                	call   *%esi
			break;
  800822:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800825:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800828:	e9 ed fb ff ff       	jmp    80041a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80082d:	83 ec 08             	sub    $0x8,%esp
  800830:	53                   	push   %ebx
  800831:	6a 25                	push   $0x25
  800833:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	eb 03                	jmp    80083d <vprintfmt+0x449>
  80083a:	83 ef 01             	sub    $0x1,%edi
  80083d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800841:	75 f7                	jne    80083a <vprintfmt+0x446>
  800843:	e9 d2 fb ff ff       	jmp    80041a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800848:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80084b:	5b                   	pop    %ebx
  80084c:	5e                   	pop    %esi
  80084d:	5f                   	pop    %edi
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	83 ec 18             	sub    $0x18,%esp
  800856:	8b 45 08             	mov    0x8(%ebp),%eax
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80085c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80085f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800863:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800866:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80086d:	85 c0                	test   %eax,%eax
  80086f:	74 26                	je     800897 <vsnprintf+0x47>
  800871:	85 d2                	test   %edx,%edx
  800873:	7e 22                	jle    800897 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800875:	ff 75 14             	pushl  0x14(%ebp)
  800878:	ff 75 10             	pushl  0x10(%ebp)
  80087b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80087e:	50                   	push   %eax
  80087f:	68 ba 03 80 00       	push   $0x8003ba
  800884:	e8 6b fb ff ff       	call   8003f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800889:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80088c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80088f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800892:	83 c4 10             	add    $0x10,%esp
  800895:	eb 05                	jmp    80089c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800897:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80089c:	c9                   	leave  
  80089d:	c3                   	ret    

0080089e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a7:	50                   	push   %eax
  8008a8:	ff 75 10             	pushl  0x10(%ebp)
  8008ab:	ff 75 0c             	pushl  0xc(%ebp)
  8008ae:	ff 75 08             	pushl  0x8(%ebp)
  8008b1:	e8 9a ff ff ff       	call   800850 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008be:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c3:	eb 03                	jmp    8008c8 <strlen+0x10>
		n++;
  8008c5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008cc:	75 f7                	jne    8008c5 <strlen+0xd>
		n++;
	return n;
}
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008de:	eb 03                	jmp    8008e3 <strnlen+0x13>
		n++;
  8008e0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e3:	39 c2                	cmp    %eax,%edx
  8008e5:	74 08                	je     8008ef <strnlen+0x1f>
  8008e7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008eb:	75 f3                	jne    8008e0 <strnlen+0x10>
  8008ed:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	53                   	push   %ebx
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008fb:	89 c2                	mov    %eax,%edx
  8008fd:	83 c2 01             	add    $0x1,%edx
  800900:	83 c1 01             	add    $0x1,%ecx
  800903:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800907:	88 5a ff             	mov    %bl,-0x1(%edx)
  80090a:	84 db                	test   %bl,%bl
  80090c:	75 ef                	jne    8008fd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80090e:	5b                   	pop    %ebx
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	53                   	push   %ebx
  800915:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800918:	53                   	push   %ebx
  800919:	e8 9a ff ff ff       	call   8008b8 <strlen>
  80091e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800921:	ff 75 0c             	pushl  0xc(%ebp)
  800924:	01 d8                	add    %ebx,%eax
  800926:	50                   	push   %eax
  800927:	e8 c5 ff ff ff       	call   8008f1 <strcpy>
	return dst;
}
  80092c:	89 d8                	mov    %ebx,%eax
  80092e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800931:	c9                   	leave  
  800932:	c3                   	ret    

00800933 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	56                   	push   %esi
  800937:	53                   	push   %ebx
  800938:	8b 75 08             	mov    0x8(%ebp),%esi
  80093b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093e:	89 f3                	mov    %esi,%ebx
  800940:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800943:	89 f2                	mov    %esi,%edx
  800945:	eb 0f                	jmp    800956 <strncpy+0x23>
		*dst++ = *src;
  800947:	83 c2 01             	add    $0x1,%edx
  80094a:	0f b6 01             	movzbl (%ecx),%eax
  80094d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800950:	80 39 01             	cmpb   $0x1,(%ecx)
  800953:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800956:	39 da                	cmp    %ebx,%edx
  800958:	75 ed                	jne    800947 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80095a:	89 f0                	mov    %esi,%eax
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
  800965:	8b 75 08             	mov    0x8(%ebp),%esi
  800968:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096b:	8b 55 10             	mov    0x10(%ebp),%edx
  80096e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800970:	85 d2                	test   %edx,%edx
  800972:	74 21                	je     800995 <strlcpy+0x35>
  800974:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800978:	89 f2                	mov    %esi,%edx
  80097a:	eb 09                	jmp    800985 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80097c:	83 c2 01             	add    $0x1,%edx
  80097f:	83 c1 01             	add    $0x1,%ecx
  800982:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800985:	39 c2                	cmp    %eax,%edx
  800987:	74 09                	je     800992 <strlcpy+0x32>
  800989:	0f b6 19             	movzbl (%ecx),%ebx
  80098c:	84 db                	test   %bl,%bl
  80098e:	75 ec                	jne    80097c <strlcpy+0x1c>
  800990:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800992:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800995:	29 f0                	sub    %esi,%eax
}
  800997:	5b                   	pop    %ebx
  800998:	5e                   	pop    %esi
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a4:	eb 06                	jmp    8009ac <strcmp+0x11>
		p++, q++;
  8009a6:	83 c1 01             	add    $0x1,%ecx
  8009a9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ac:	0f b6 01             	movzbl (%ecx),%eax
  8009af:	84 c0                	test   %al,%al
  8009b1:	74 04                	je     8009b7 <strcmp+0x1c>
  8009b3:	3a 02                	cmp    (%edx),%al
  8009b5:	74 ef                	je     8009a6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b7:	0f b6 c0             	movzbl %al,%eax
  8009ba:	0f b6 12             	movzbl (%edx),%edx
  8009bd:	29 d0                	sub    %edx,%eax
}
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	53                   	push   %ebx
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cb:	89 c3                	mov    %eax,%ebx
  8009cd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d0:	eb 06                	jmp    8009d8 <strncmp+0x17>
		n--, p++, q++;
  8009d2:	83 c0 01             	add    $0x1,%eax
  8009d5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009d8:	39 d8                	cmp    %ebx,%eax
  8009da:	74 15                	je     8009f1 <strncmp+0x30>
  8009dc:	0f b6 08             	movzbl (%eax),%ecx
  8009df:	84 c9                	test   %cl,%cl
  8009e1:	74 04                	je     8009e7 <strncmp+0x26>
  8009e3:	3a 0a                	cmp    (%edx),%cl
  8009e5:	74 eb                	je     8009d2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e7:	0f b6 00             	movzbl (%eax),%eax
  8009ea:	0f b6 12             	movzbl (%edx),%edx
  8009ed:	29 d0                	sub    %edx,%eax
  8009ef:	eb 05                	jmp    8009f6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009f1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009f6:	5b                   	pop    %ebx
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a03:	eb 07                	jmp    800a0c <strchr+0x13>
		if (*s == c)
  800a05:	38 ca                	cmp    %cl,%dl
  800a07:	74 0f                	je     800a18 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a09:	83 c0 01             	add    $0x1,%eax
  800a0c:	0f b6 10             	movzbl (%eax),%edx
  800a0f:	84 d2                	test   %dl,%dl
  800a11:	75 f2                	jne    800a05 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a24:	eb 03                	jmp    800a29 <strfind+0xf>
  800a26:	83 c0 01             	add    $0x1,%eax
  800a29:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a2c:	38 ca                	cmp    %cl,%dl
  800a2e:	74 04                	je     800a34 <strfind+0x1a>
  800a30:	84 d2                	test   %dl,%dl
  800a32:	75 f2                	jne    800a26 <strfind+0xc>
			break;
	return (char *) s;
}
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	57                   	push   %edi
  800a3a:	56                   	push   %esi
  800a3b:	53                   	push   %ebx
  800a3c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a42:	85 c9                	test   %ecx,%ecx
  800a44:	74 36                	je     800a7c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a46:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a4c:	75 28                	jne    800a76 <memset+0x40>
  800a4e:	f6 c1 03             	test   $0x3,%cl
  800a51:	75 23                	jne    800a76 <memset+0x40>
		c &= 0xFF;
  800a53:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a57:	89 d3                	mov    %edx,%ebx
  800a59:	c1 e3 08             	shl    $0x8,%ebx
  800a5c:	89 d6                	mov    %edx,%esi
  800a5e:	c1 e6 18             	shl    $0x18,%esi
  800a61:	89 d0                	mov    %edx,%eax
  800a63:	c1 e0 10             	shl    $0x10,%eax
  800a66:	09 f0                	or     %esi,%eax
  800a68:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a6a:	89 d8                	mov    %ebx,%eax
  800a6c:	09 d0                	or     %edx,%eax
  800a6e:	c1 e9 02             	shr    $0x2,%ecx
  800a71:	fc                   	cld    
  800a72:	f3 ab                	rep stos %eax,%es:(%edi)
  800a74:	eb 06                	jmp    800a7c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a79:	fc                   	cld    
  800a7a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a7c:	89 f8                	mov    %edi,%eax
  800a7e:	5b                   	pop    %ebx
  800a7f:	5e                   	pop    %esi
  800a80:	5f                   	pop    %edi
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	57                   	push   %edi
  800a87:	56                   	push   %esi
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a91:	39 c6                	cmp    %eax,%esi
  800a93:	73 35                	jae    800aca <memmove+0x47>
  800a95:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a98:	39 d0                	cmp    %edx,%eax
  800a9a:	73 2e                	jae    800aca <memmove+0x47>
		s += n;
		d += n;
  800a9c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9f:	89 d6                	mov    %edx,%esi
  800aa1:	09 fe                	or     %edi,%esi
  800aa3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa9:	75 13                	jne    800abe <memmove+0x3b>
  800aab:	f6 c1 03             	test   $0x3,%cl
  800aae:	75 0e                	jne    800abe <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ab0:	83 ef 04             	sub    $0x4,%edi
  800ab3:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab6:	c1 e9 02             	shr    $0x2,%ecx
  800ab9:	fd                   	std    
  800aba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abc:	eb 09                	jmp    800ac7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800abe:	83 ef 01             	sub    $0x1,%edi
  800ac1:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ac4:	fd                   	std    
  800ac5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac7:	fc                   	cld    
  800ac8:	eb 1d                	jmp    800ae7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aca:	89 f2                	mov    %esi,%edx
  800acc:	09 c2                	or     %eax,%edx
  800ace:	f6 c2 03             	test   $0x3,%dl
  800ad1:	75 0f                	jne    800ae2 <memmove+0x5f>
  800ad3:	f6 c1 03             	test   $0x3,%cl
  800ad6:	75 0a                	jne    800ae2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ad8:	c1 e9 02             	shr    $0x2,%ecx
  800adb:	89 c7                	mov    %eax,%edi
  800add:	fc                   	cld    
  800ade:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae0:	eb 05                	jmp    800ae7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae2:	89 c7                	mov    %eax,%edi
  800ae4:	fc                   	cld    
  800ae5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ae7:	5e                   	pop    %esi
  800ae8:	5f                   	pop    %edi
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aee:	ff 75 10             	pushl  0x10(%ebp)
  800af1:	ff 75 0c             	pushl  0xc(%ebp)
  800af4:	ff 75 08             	pushl  0x8(%ebp)
  800af7:	e8 87 ff ff ff       	call   800a83 <memmove>
}
  800afc:	c9                   	leave  
  800afd:	c3                   	ret    

00800afe <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	8b 45 08             	mov    0x8(%ebp),%eax
  800b06:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b09:	89 c6                	mov    %eax,%esi
  800b0b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0e:	eb 1a                	jmp    800b2a <memcmp+0x2c>
		if (*s1 != *s2)
  800b10:	0f b6 08             	movzbl (%eax),%ecx
  800b13:	0f b6 1a             	movzbl (%edx),%ebx
  800b16:	38 d9                	cmp    %bl,%cl
  800b18:	74 0a                	je     800b24 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b1a:	0f b6 c1             	movzbl %cl,%eax
  800b1d:	0f b6 db             	movzbl %bl,%ebx
  800b20:	29 d8                	sub    %ebx,%eax
  800b22:	eb 0f                	jmp    800b33 <memcmp+0x35>
		s1++, s2++;
  800b24:	83 c0 01             	add    $0x1,%eax
  800b27:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2a:	39 f0                	cmp    %esi,%eax
  800b2c:	75 e2                	jne    800b10 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	53                   	push   %ebx
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b3e:	89 c1                	mov    %eax,%ecx
  800b40:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b43:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b47:	eb 0a                	jmp    800b53 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b49:	0f b6 10             	movzbl (%eax),%edx
  800b4c:	39 da                	cmp    %ebx,%edx
  800b4e:	74 07                	je     800b57 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b50:	83 c0 01             	add    $0x1,%eax
  800b53:	39 c8                	cmp    %ecx,%eax
  800b55:	72 f2                	jb     800b49 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b57:	5b                   	pop    %ebx
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
  800b60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b66:	eb 03                	jmp    800b6b <strtol+0x11>
		s++;
  800b68:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6b:	0f b6 01             	movzbl (%ecx),%eax
  800b6e:	3c 20                	cmp    $0x20,%al
  800b70:	74 f6                	je     800b68 <strtol+0xe>
  800b72:	3c 09                	cmp    $0x9,%al
  800b74:	74 f2                	je     800b68 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b76:	3c 2b                	cmp    $0x2b,%al
  800b78:	75 0a                	jne    800b84 <strtol+0x2a>
		s++;
  800b7a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b7d:	bf 00 00 00 00       	mov    $0x0,%edi
  800b82:	eb 11                	jmp    800b95 <strtol+0x3b>
  800b84:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b89:	3c 2d                	cmp    $0x2d,%al
  800b8b:	75 08                	jne    800b95 <strtol+0x3b>
		s++, neg = 1;
  800b8d:	83 c1 01             	add    $0x1,%ecx
  800b90:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b95:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b9b:	75 15                	jne    800bb2 <strtol+0x58>
  800b9d:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba0:	75 10                	jne    800bb2 <strtol+0x58>
  800ba2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ba6:	75 7c                	jne    800c24 <strtol+0xca>
		s += 2, base = 16;
  800ba8:	83 c1 02             	add    $0x2,%ecx
  800bab:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb0:	eb 16                	jmp    800bc8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bb2:	85 db                	test   %ebx,%ebx
  800bb4:	75 12                	jne    800bc8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bb6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbb:	80 39 30             	cmpb   $0x30,(%ecx)
  800bbe:	75 08                	jne    800bc8 <strtol+0x6e>
		s++, base = 8;
  800bc0:	83 c1 01             	add    $0x1,%ecx
  800bc3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bc8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd0:	0f b6 11             	movzbl (%ecx),%edx
  800bd3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bd6:	89 f3                	mov    %esi,%ebx
  800bd8:	80 fb 09             	cmp    $0x9,%bl
  800bdb:	77 08                	ja     800be5 <strtol+0x8b>
			dig = *s - '0';
  800bdd:	0f be d2             	movsbl %dl,%edx
  800be0:	83 ea 30             	sub    $0x30,%edx
  800be3:	eb 22                	jmp    800c07 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800be5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800be8:	89 f3                	mov    %esi,%ebx
  800bea:	80 fb 19             	cmp    $0x19,%bl
  800bed:	77 08                	ja     800bf7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bef:	0f be d2             	movsbl %dl,%edx
  800bf2:	83 ea 57             	sub    $0x57,%edx
  800bf5:	eb 10                	jmp    800c07 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bf7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bfa:	89 f3                	mov    %esi,%ebx
  800bfc:	80 fb 19             	cmp    $0x19,%bl
  800bff:	77 16                	ja     800c17 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c01:	0f be d2             	movsbl %dl,%edx
  800c04:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c07:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c0a:	7d 0b                	jge    800c17 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c0c:	83 c1 01             	add    $0x1,%ecx
  800c0f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c13:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c15:	eb b9                	jmp    800bd0 <strtol+0x76>

	if (endptr)
  800c17:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c1b:	74 0d                	je     800c2a <strtol+0xd0>
		*endptr = (char *) s;
  800c1d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c20:	89 0e                	mov    %ecx,(%esi)
  800c22:	eb 06                	jmp    800c2a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c24:	85 db                	test   %ebx,%ebx
  800c26:	74 98                	je     800bc0 <strtol+0x66>
  800c28:	eb 9e                	jmp    800bc8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c2a:	89 c2                	mov    %eax,%edx
  800c2c:	f7 da                	neg    %edx
  800c2e:	85 ff                	test   %edi,%edi
  800c30:	0f 45 c2             	cmovne %edx,%eax
}
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	83 ec 04             	sub    $0x4,%esp
  800c41:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800c44:	57                   	push   %edi
  800c45:	e8 6e fc ff ff       	call   8008b8 <strlen>
  800c4a:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800c4d:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800c50:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800c55:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800c5a:	eb 46                	jmp    800ca2 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800c5c:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800c60:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800c63:	80 f9 09             	cmp    $0x9,%cl
  800c66:	77 08                	ja     800c70 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800c68:	0f be d2             	movsbl %dl,%edx
  800c6b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800c6e:	eb 27                	jmp    800c97 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800c70:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800c73:	80 f9 05             	cmp    $0x5,%cl
  800c76:	77 08                	ja     800c80 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800c78:	0f be d2             	movsbl %dl,%edx
  800c7b:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800c7e:	eb 17                	jmp    800c97 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800c80:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800c83:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800c86:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800c8b:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800c8f:	77 06                	ja     800c97 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800c91:	0f be d2             	movsbl %dl,%edx
  800c94:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800c97:	0f af ce             	imul   %esi,%ecx
  800c9a:	01 c8                	add    %ecx,%eax
		base *= 16;
  800c9c:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800c9f:	83 eb 01             	sub    $0x1,%ebx
  800ca2:	83 fb 01             	cmp    $0x1,%ebx
  800ca5:	7f b5                	jg     800c5c <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc0:	89 c3                	mov    %eax,%ebx
  800cc2:	89 c7                	mov    %eax,%edi
  800cc4:	89 c6                	mov    %eax,%esi
  800cc6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <sys_cgetc>:

int
sys_cgetc(void)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd8:	b8 01 00 00 00       	mov    $0x1,%eax
  800cdd:	89 d1                	mov    %edx,%ecx
  800cdf:	89 d3                	mov    %edx,%ebx
  800ce1:	89 d7                	mov    %edx,%edi
  800ce3:	89 d6                	mov    %edx,%esi
  800ce5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfa:	b8 03 00 00 00       	mov    $0x3,%eax
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	89 cb                	mov    %ecx,%ebx
  800d04:	89 cf                	mov    %ecx,%edi
  800d06:	89 ce                	mov    %ecx,%esi
  800d08:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	7e 17                	jle    800d25 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0e:	83 ec 0c             	sub    $0xc,%esp
  800d11:	50                   	push   %eax
  800d12:	6a 03                	push   $0x3
  800d14:	68 df 2d 80 00       	push   $0x802ddf
  800d19:	6a 23                	push   $0x23
  800d1b:	68 fc 2d 80 00       	push   $0x802dfc
  800d20:	e8 bf f4 ff ff       	call   8001e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	ba 00 00 00 00       	mov    $0x0,%edx
  800d38:	b8 02 00 00 00       	mov    $0x2,%eax
  800d3d:	89 d1                	mov    %edx,%ecx
  800d3f:	89 d3                	mov    %edx,%ebx
  800d41:	89 d7                	mov    %edx,%edi
  800d43:	89 d6                	mov    %edx,%esi
  800d45:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_yield>:

void
sys_yield(void)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d52:	ba 00 00 00 00       	mov    $0x0,%edx
  800d57:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d5c:	89 d1                	mov    %edx,%ecx
  800d5e:	89 d3                	mov    %edx,%ebx
  800d60:	89 d7                	mov    %edx,%edi
  800d62:	89 d6                	mov    %edx,%esi
  800d64:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d74:	be 00 00 00 00       	mov    $0x0,%esi
  800d79:	b8 04 00 00 00       	mov    $0x4,%eax
  800d7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d87:	89 f7                	mov    %esi,%edi
  800d89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7e 17                	jle    800da6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8f:	83 ec 0c             	sub    $0xc,%esp
  800d92:	50                   	push   %eax
  800d93:	6a 04                	push   $0x4
  800d95:	68 df 2d 80 00       	push   $0x802ddf
  800d9a:	6a 23                	push   $0x23
  800d9c:	68 fc 2d 80 00       	push   $0x802dfc
  800da1:	e8 3e f4 ff ff       	call   8001e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800da6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db7:	b8 05 00 00 00       	mov    $0x5,%eax
  800dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc8:	8b 75 18             	mov    0x18(%ebp),%esi
  800dcb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	7e 17                	jle    800de8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd1:	83 ec 0c             	sub    $0xc,%esp
  800dd4:	50                   	push   %eax
  800dd5:	6a 05                	push   $0x5
  800dd7:	68 df 2d 80 00       	push   $0x802ddf
  800ddc:	6a 23                	push   $0x23
  800dde:	68 fc 2d 80 00       	push   $0x802dfc
  800de3:	e8 fc f3 ff ff       	call   8001e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800de8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
  800df6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfe:	b8 06 00 00 00       	mov    $0x6,%eax
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	8b 55 08             	mov    0x8(%ebp),%edx
  800e09:	89 df                	mov    %ebx,%edi
  800e0b:	89 de                	mov    %ebx,%esi
  800e0d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	7e 17                	jle    800e2a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e13:	83 ec 0c             	sub    $0xc,%esp
  800e16:	50                   	push   %eax
  800e17:	6a 06                	push   $0x6
  800e19:	68 df 2d 80 00       	push   $0x802ddf
  800e1e:	6a 23                	push   $0x23
  800e20:	68 fc 2d 80 00       	push   $0x802dfc
  800e25:	e8 ba f3 ff ff       	call   8001e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
  800e38:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e40:	b8 08 00 00 00       	mov    $0x8,%eax
  800e45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e48:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4b:	89 df                	mov    %ebx,%edi
  800e4d:	89 de                	mov    %ebx,%esi
  800e4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e51:	85 c0                	test   %eax,%eax
  800e53:	7e 17                	jle    800e6c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e55:	83 ec 0c             	sub    $0xc,%esp
  800e58:	50                   	push   %eax
  800e59:	6a 08                	push   $0x8
  800e5b:	68 df 2d 80 00       	push   $0x802ddf
  800e60:	6a 23                	push   $0x23
  800e62:	68 fc 2d 80 00       	push   $0x802dfc
  800e67:	e8 78 f3 ff ff       	call   8001e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6f:	5b                   	pop    %ebx
  800e70:	5e                   	pop    %esi
  800e71:	5f                   	pop    %edi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	57                   	push   %edi
  800e78:	56                   	push   %esi
  800e79:	53                   	push   %ebx
  800e7a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e82:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8d:	89 df                	mov    %ebx,%edi
  800e8f:	89 de                	mov    %ebx,%esi
  800e91:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e93:	85 c0                	test   %eax,%eax
  800e95:	7e 17                	jle    800eae <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e97:	83 ec 0c             	sub    $0xc,%esp
  800e9a:	50                   	push   %eax
  800e9b:	6a 0a                	push   $0xa
  800e9d:	68 df 2d 80 00       	push   $0x802ddf
  800ea2:	6a 23                	push   $0x23
  800ea4:	68 fc 2d 80 00       	push   $0x802dfc
  800ea9:	e8 36 f3 ff ff       	call   8001e4 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5f                   	pop    %edi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	57                   	push   %edi
  800eba:	56                   	push   %esi
  800ebb:	53                   	push   %ebx
  800ebc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec4:	b8 09 00 00 00       	mov    $0x9,%eax
  800ec9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecf:	89 df                	mov    %ebx,%edi
  800ed1:	89 de                	mov    %ebx,%esi
  800ed3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ed5:	85 c0                	test   %eax,%eax
  800ed7:	7e 17                	jle    800ef0 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed9:	83 ec 0c             	sub    $0xc,%esp
  800edc:	50                   	push   %eax
  800edd:	6a 09                	push   $0x9
  800edf:	68 df 2d 80 00       	push   $0x802ddf
  800ee4:	6a 23                	push   $0x23
  800ee6:	68 fc 2d 80 00       	push   $0x802dfc
  800eeb:	e8 f4 f2 ff ff       	call   8001e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ef0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef3:	5b                   	pop    %ebx
  800ef4:	5e                   	pop    %esi
  800ef5:	5f                   	pop    %edi
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	57                   	push   %edi
  800efc:	56                   	push   %esi
  800efd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efe:	be 00 00 00 00       	mov    $0x0,%esi
  800f03:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f11:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f14:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5f                   	pop    %edi
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    

00800f1b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	57                   	push   %edi
  800f1f:	56                   	push   %esi
  800f20:	53                   	push   %ebx
  800f21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f24:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f29:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f31:	89 cb                	mov    %ecx,%ebx
  800f33:	89 cf                	mov    %ecx,%edi
  800f35:	89 ce                	mov    %ecx,%esi
  800f37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	7e 17                	jle    800f54 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3d:	83 ec 0c             	sub    $0xc,%esp
  800f40:	50                   	push   %eax
  800f41:	6a 0d                	push   $0xd
  800f43:	68 df 2d 80 00       	push   $0x802ddf
  800f48:	6a 23                	push   $0x23
  800f4a:	68 fc 2d 80 00       	push   $0x802dfc
  800f4f:	e8 90 f2 ff ff       	call   8001e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f57:	5b                   	pop    %ebx
  800f58:	5e                   	pop    %esi
  800f59:	5f                   	pop    %edi
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    

00800f5c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	53                   	push   %ebx
  800f60:	83 ec 04             	sub    $0x4,%esp
  800f63:	8b 45 08             	mov    0x8(%ebp),%eax

	
	void *addr = (void *) utf->utf_fault_va;
  800f66:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800f68:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f6c:	74 11                	je     800f7f <pgfault+0x23>
  800f6e:	89 d8                	mov    %ebx,%eax
  800f70:	c1 e8 0c             	shr    $0xc,%eax
  800f73:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f7a:	f6 c4 08             	test   $0x8,%ah
  800f7d:	75 14                	jne    800f93 <pgfault+0x37>
		panic("page fault");
  800f7f:	83 ec 04             	sub    $0x4,%esp
  800f82:	68 0a 2e 80 00       	push   $0x802e0a
  800f87:	6a 5b                	push   $0x5b
  800f89:	68 15 2e 80 00       	push   $0x802e15
  800f8e:	e8 51 f2 ff ff       	call   8001e4 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// allocate a new page and map it at a temporary location
	if((r = sys_page_alloc(0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800f93:	83 ec 04             	sub    $0x4,%esp
  800f96:	6a 07                	push   $0x7
  800f98:	68 00 f0 7f 00       	push   $0x7ff000
  800f9d:	6a 00                	push   $0x0
  800f9f:	e8 c7 fd ff ff       	call   800d6b <sys_page_alloc>
  800fa4:	83 c4 10             	add    $0x10,%esp
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	79 12                	jns    800fbd <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800fab:	50                   	push   %eax
  800fac:	68 0c 2a 80 00       	push   $0x802a0c
  800fb1:	6a 66                	push   $0x66
  800fb3:	68 15 2e 80 00       	push   $0x802e15
  800fb8:	e8 27 f2 ff ff       	call   8001e4 <_panic>

	// copy date to new page
	//strncpy((char *)PFTEMP, (char *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
	memcpy((void *)PFTEMP, (void *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
  800fbd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800fc3:	83 ec 04             	sub    $0x4,%esp
  800fc6:	68 00 10 00 00       	push   $0x1000
  800fcb:	53                   	push   %ebx
  800fcc:	68 00 f0 7f 00       	push   $0x7ff000
  800fd1:	e8 15 fb ff ff       	call   800aeb <memcpy>

	// move the new page to the old page's address
	if((r = sys_page_map(0, (void *)PFTEMP, 0, (void *)
  800fd6:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fdd:	53                   	push   %ebx
  800fde:	6a 00                	push   $0x0
  800fe0:	68 00 f0 7f 00       	push   $0x7ff000
  800fe5:	6a 00                	push   $0x0
  800fe7:	e8 c2 fd ff ff       	call   800dae <sys_page_map>
  800fec:	83 c4 20             	add    $0x20,%esp
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	79 12                	jns    801005 <pgfault+0xa9>
		(ROUNDDOWN(addr, PGSIZE)), PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_map: %e", r);
  800ff3:	50                   	push   %eax
  800ff4:	68 20 2e 80 00       	push   $0x802e20
  800ff9:	6a 6f                	push   $0x6f
  800ffb:	68 15 2e 80 00       	push   $0x802e15
  801000:	e8 df f1 ff ff       	call   8001e4 <_panic>

	// unmap page on PFTEMP
	if((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  801005:	83 ec 08             	sub    $0x8,%esp
  801008:	68 00 f0 7f 00       	push   $0x7ff000
  80100d:	6a 00                	push   $0x0
  80100f:	e8 dc fd ff ff       	call   800df0 <sys_page_unmap>
  801014:	83 c4 10             	add    $0x10,%esp
  801017:	85 c0                	test   %eax,%eax
  801019:	79 12                	jns    80102d <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  80101b:	50                   	push   %eax
  80101c:	68 31 2e 80 00       	push   $0x802e31
  801021:	6a 73                	push   $0x73
  801023:	68 15 2e 80 00       	push   $0x802e15
  801028:	e8 b7 f1 ff ff       	call   8001e4 <_panic>


}
  80102d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801030:	c9                   	leave  
  801031:	c3                   	ret    

00801032 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	57                   	push   %edi
  801036:	56                   	push   %esi
  801037:	53                   	push   %ebx
  801038:	83 ec 28             	sub    $0x28,%esp

	#ifdef CHALLENGE 
	set_exception_handler(pgfault, T_PGFLT);
	#else
	// set up page fault handler
	set_pgfault_handler(pgfault);
  80103b:	68 5c 0f 80 00       	push   $0x800f5c
  801040:	e8 55 15 00 00       	call   80259a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801045:	b8 07 00 00 00       	mov    $0x7,%eax
  80104a:	cd 30                	int    $0x30
  80104c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80104f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	#endif

	// create a child
	envid = sys_exofork();
	if (envid < 0)
  801052:	83 c4 10             	add    $0x10,%esp
  801055:	85 c0                	test   %eax,%eax
  801057:	79 15                	jns    80106e <fork+0x3c>
		panic("sys_exofork: %e", envid);
  801059:	50                   	push   %eax
  80105a:	68 44 2e 80 00       	push   $0x802e44
  80105f:	68 d0 00 00 00       	push   $0xd0
  801064:	68 15 2e 80 00       	push   $0x802e15
  801069:	e8 76 f1 ff ff       	call   8001e4 <_panic>
  80106e:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801073:	be 00 08 00 00       	mov    $0x800,%esi
	// we are the child
	if(envid == 0) {
  801078:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80107c:	75 21                	jne    80109f <fork+0x6d>
		// the copied valude of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  80107e:	e8 aa fc ff ff       	call   800d2d <sys_getenvid>
  801083:	25 ff 03 00 00       	and    $0x3ff,%eax
  801088:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80108b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801090:	a3 08 50 80 00       	mov    %eax,0x805008
		/*// alloc exception stack
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
			PTE_P | PTE_U | PTE_W)) < 0)
			panic("sys_page_alloc: %e", r);*/

		return 0;
  801095:	b8 00 00 00 00       	mov    $0x0,%eax
  80109a:	e9 a3 01 00 00       	jmp    801242 <fork+0x210>
{
	int r;

	// LAB 4: Your code here.
	
	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P))
  80109f:	89 d8                	mov    %ebx,%eax
  8010a1:	c1 e8 16             	shr    $0x16,%eax
  8010a4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010ab:	a8 01                	test   $0x1,%al
  8010ad:	0f 84 f0 00 00 00    	je     8011a3 <fork+0x171>
		return 0;

	// virtual page pn's page table entry
	pte_t pe = uvpt[pn];
  8010b3:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi


	if((pe & PTE_P) && (pe & PTE_U)) {
  8010ba:	89 f8                	mov    %edi,%eax
  8010bc:	83 e0 05             	and    $0x5,%eax
  8010bf:	83 f8 05             	cmp    $0x5,%eax
  8010c2:	0f 85 db 00 00 00    	jne    8011a3 <fork+0x171>
		// share with the child environment 
		if(pe & PTE_SHARE) {
  8010c8:	f7 c7 00 04 00 00    	test   $0x400,%edi
  8010ce:	74 36                	je     801106 <fork+0xd4>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  8010d0:	83 ec 0c             	sub    $0xc,%esp
  8010d3:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  8010d9:	57                   	push   %edi
  8010da:	53                   	push   %ebx
  8010db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010de:	53                   	push   %ebx
  8010df:	6a 00                	push   $0x0
  8010e1:	e8 c8 fc ff ff       	call   800dae <sys_page_map>
  8010e6:	83 c4 20             	add    $0x20,%esp
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	0f 89 b2 00 00 00    	jns    8011a3 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  8010f1:	50                   	push   %eax
  8010f2:	68 54 2e 80 00       	push   $0x802e54
  8010f7:	68 97 00 00 00       	push   $0x97
  8010fc:	68 15 2e 80 00       	push   $0x802e15
  801101:	e8 de f0 ff ff       	call   8001e4 <_panic>
		}
		// the page is writable or copy-on-write
		else if((pe & PTE_W) || (pe & PTE_COW)) {
  801106:	f7 c7 02 08 00 00    	test   $0x802,%edi
  80110c:	74 63                	je     801171 <fork+0x13f>
			// create the child mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, 
  80110e:	81 e7 05 06 00 00    	and    $0x605,%edi
  801114:	81 cf 00 08 00 00    	or     $0x800,%edi
  80111a:	83 ec 0c             	sub    $0xc,%esp
  80111d:	57                   	push   %edi
  80111e:	53                   	push   %ebx
  80111f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801122:	53                   	push   %ebx
  801123:	6a 00                	push   $0x0
  801125:	e8 84 fc ff ff       	call   800dae <sys_page_map>
  80112a:	83 c4 20             	add    $0x20,%esp
  80112d:	85 c0                	test   %eax,%eax
  80112f:	79 15                	jns    801146 <fork+0x114>
				(void *)(pn*PGSIZE), (pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  801131:	50                   	push   %eax
  801132:	68 54 2e 80 00       	push   $0x802e54
  801137:	68 9e 00 00 00       	push   $0x9e
  80113c:	68 15 2e 80 00       	push   $0x802e15
  801141:	e8 9e f0 ff ff       	call   8001e4 <_panic>
			// map the parent mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE),
  801146:	83 ec 0c             	sub    $0xc,%esp
  801149:	57                   	push   %edi
  80114a:	53                   	push   %ebx
  80114b:	6a 00                	push   $0x0
  80114d:	53                   	push   %ebx
  80114e:	6a 00                	push   $0x0
  801150:	e8 59 fc ff ff       	call   800dae <sys_page_map>
  801155:	83 c4 20             	add    $0x20,%esp
  801158:	85 c0                	test   %eax,%eax
  80115a:	79 47                	jns    8011a3 <fork+0x171>
				(pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  80115c:	50                   	push   %eax
  80115d:	68 54 2e 80 00       	push   $0x802e54
  801162:	68 a2 00 00 00       	push   $0xa2
  801167:	68 15 2e 80 00       	push   $0x802e15
  80116c:	e8 73 f0 ff ff       	call   8001e4 <_panic>
		}	
		else {
			// create the child mapping read only
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  801171:	83 ec 0c             	sub    $0xc,%esp
  801174:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  80117a:	57                   	push   %edi
  80117b:	53                   	push   %ebx
  80117c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117f:	53                   	push   %ebx
  801180:	6a 00                	push   $0x0
  801182:	e8 27 fc ff ff       	call   800dae <sys_page_map>
  801187:	83 c4 20             	add    $0x20,%esp
  80118a:	85 c0                	test   %eax,%eax
  80118c:	79 15                	jns    8011a3 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  80118e:	50                   	push   %eax
  80118f:	68 54 2e 80 00       	push   $0x802e54
  801194:	68 a8 00 00 00       	push   $0xa8
  801199:	68 15 2e 80 00       	push   $0x802e15
  80119e:	e8 41 f0 ff ff       	call   8001e4 <_panic>
			panic("sys_page_alloc: %e", r);*/

		return 0;
	}
	// copy address to child environment's page dirctory
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn)
  8011a3:	83 c6 01             	add    $0x1,%esi
  8011a6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011ac:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8011b2:	0f 85 e7 fe ff ff    	jne    80109f <fork+0x6d>
	#ifdef CHALLENGE 
	if((r = sys_env_set_exception_upcall(envid, thisenv->env_exception_upcall)) < 0)
		panic("sys_env_set_exception_upcall: %e", r);
	#else
	// set child's page fault handler
	if((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  8011b8:	a1 08 50 80 00       	mov    0x805008,%eax
  8011bd:	8b 40 64             	mov    0x64(%eax),%eax
  8011c0:	83 ec 08             	sub    $0x8,%esp
  8011c3:	50                   	push   %eax
  8011c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c7:	e8 ea fc ff ff       	call   800eb6 <sys_env_set_pgfault_upcall>
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	79 15                	jns    8011e8 <fork+0x1b6>
		panic("sys_env_set_pgfault_upcall: %e", r);
  8011d3:	50                   	push   %eax
  8011d4:	68 90 2e 80 00       	push   $0x802e90
  8011d9:	68 e9 00 00 00       	push   $0xe9
  8011de:	68 15 2e 80 00       	push   $0x802e15
  8011e3:	e8 fc ef ff ff       	call   8001e4 <_panic>
	#endif

	// alloc exception stack for child environment
	if((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), 
  8011e8:	83 ec 04             	sub    $0x4,%esp
  8011eb:	6a 07                	push   $0x7
  8011ed:	68 00 f0 bf ee       	push   $0xeebff000
  8011f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f5:	e8 71 fb ff ff       	call   800d6b <sys_page_alloc>
  8011fa:	83 c4 10             	add    $0x10,%esp
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	79 15                	jns    801216 <fork+0x1e4>
		PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
  801201:	50                   	push   %eax
  801202:	68 0c 2a 80 00       	push   $0x802a0c
  801207:	68 ef 00 00 00       	push   $0xef
  80120c:	68 15 2e 80 00       	push   $0x802e15
  801211:	e8 ce ef ff ff       	call   8001e4 <_panic>

	// start the child environment running
	if((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801216:	83 ec 08             	sub    $0x8,%esp
  801219:	6a 02                	push   $0x2
  80121b:	ff 75 e0             	pushl  -0x20(%ebp)
  80121e:	e8 0f fc ff ff       	call   800e32 <sys_env_set_status>
  801223:	83 c4 10             	add    $0x10,%esp
  801226:	85 c0                	test   %eax,%eax
  801228:	79 15                	jns    80123f <fork+0x20d>
		panic("sys_env_set_status: %e", r);
  80122a:	50                   	push   %eax
  80122b:	68 60 2e 80 00       	push   $0x802e60
  801230:	68 f3 00 00 00       	push   $0xf3
  801235:	68 15 2e 80 00       	push   $0x802e15
  80123a:	e8 a5 ef ff ff       	call   8001e4 <_panic>

	return envid;
  80123f:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801242:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801245:	5b                   	pop    %ebx
  801246:	5e                   	pop    %esi
  801247:	5f                   	pop    %edi
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <sfork>:

// Challenge!
int
sfork(void)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801250:	68 77 2e 80 00       	push   $0x802e77
  801255:	68 fc 00 00 00       	push   $0xfc
  80125a:	68 15 2e 80 00       	push   $0x802e15
  80125f:	e8 80 ef ff ff       	call   8001e4 <_panic>

00801264 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801267:	8b 45 08             	mov    0x8(%ebp),%eax
  80126a:	05 00 00 00 30       	add    $0x30000000,%eax
  80126f:	c1 e8 0c             	shr    $0xc,%eax
}
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    

00801274 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801277:	8b 45 08             	mov    0x8(%ebp),%eax
  80127a:	05 00 00 00 30       	add    $0x30000000,%eax
  80127f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801284:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    

0080128b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801291:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801296:	89 c2                	mov    %eax,%edx
  801298:	c1 ea 16             	shr    $0x16,%edx
  80129b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012a2:	f6 c2 01             	test   $0x1,%dl
  8012a5:	74 11                	je     8012b8 <fd_alloc+0x2d>
  8012a7:	89 c2                	mov    %eax,%edx
  8012a9:	c1 ea 0c             	shr    $0xc,%edx
  8012ac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012b3:	f6 c2 01             	test   $0x1,%dl
  8012b6:	75 09                	jne    8012c1 <fd_alloc+0x36>
			*fd_store = fd;
  8012b8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bf:	eb 17                	jmp    8012d8 <fd_alloc+0x4d>
  8012c1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012c6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012cb:	75 c9                	jne    801296 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012cd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012d3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012e0:	83 f8 1f             	cmp    $0x1f,%eax
  8012e3:	77 36                	ja     80131b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012e5:	c1 e0 0c             	shl    $0xc,%eax
  8012e8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012ed:	89 c2                	mov    %eax,%edx
  8012ef:	c1 ea 16             	shr    $0x16,%edx
  8012f2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012f9:	f6 c2 01             	test   $0x1,%dl
  8012fc:	74 24                	je     801322 <fd_lookup+0x48>
  8012fe:	89 c2                	mov    %eax,%edx
  801300:	c1 ea 0c             	shr    $0xc,%edx
  801303:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80130a:	f6 c2 01             	test   $0x1,%dl
  80130d:	74 1a                	je     801329 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80130f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801312:	89 02                	mov    %eax,(%edx)
	return 0;
  801314:	b8 00 00 00 00       	mov    $0x0,%eax
  801319:	eb 13                	jmp    80132e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80131b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801320:	eb 0c                	jmp    80132e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801322:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801327:	eb 05                	jmp    80132e <fd_lookup+0x54>
  801329:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801339:	ba 2c 2f 80 00       	mov    $0x802f2c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80133e:	eb 13                	jmp    801353 <dev_lookup+0x23>
  801340:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801343:	39 08                	cmp    %ecx,(%eax)
  801345:	75 0c                	jne    801353 <dev_lookup+0x23>
			*dev = devtab[i];
  801347:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80134a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80134c:	b8 00 00 00 00       	mov    $0x0,%eax
  801351:	eb 2e                	jmp    801381 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801353:	8b 02                	mov    (%edx),%eax
  801355:	85 c0                	test   %eax,%eax
  801357:	75 e7                	jne    801340 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801359:	a1 08 50 80 00       	mov    0x805008,%eax
  80135e:	8b 40 48             	mov    0x48(%eax),%eax
  801361:	83 ec 04             	sub    $0x4,%esp
  801364:	51                   	push   %ecx
  801365:	50                   	push   %eax
  801366:	68 b0 2e 80 00       	push   $0x802eb0
  80136b:	e8 4d ef ff ff       	call   8002bd <cprintf>
	*dev = 0;
  801370:	8b 45 0c             	mov    0xc(%ebp),%eax
  801373:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801381:	c9                   	leave  
  801382:	c3                   	ret    

00801383 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	56                   	push   %esi
  801387:	53                   	push   %ebx
  801388:	83 ec 10             	sub    $0x10,%esp
  80138b:	8b 75 08             	mov    0x8(%ebp),%esi
  80138e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801391:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801394:	50                   	push   %eax
  801395:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80139b:	c1 e8 0c             	shr    $0xc,%eax
  80139e:	50                   	push   %eax
  80139f:	e8 36 ff ff ff       	call   8012da <fd_lookup>
  8013a4:	83 c4 08             	add    $0x8,%esp
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	78 05                	js     8013b0 <fd_close+0x2d>
	    || fd != fd2) 
  8013ab:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013ae:	74 0c                	je     8013bc <fd_close+0x39>
		return (must_exist ? r : 0); 
  8013b0:	84 db                	test   %bl,%bl
  8013b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b7:	0f 44 c2             	cmove  %edx,%eax
  8013ba:	eb 41                	jmp    8013fd <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013bc:	83 ec 08             	sub    $0x8,%esp
  8013bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c2:	50                   	push   %eax
  8013c3:	ff 36                	pushl  (%esi)
  8013c5:	e8 66 ff ff ff       	call   801330 <dev_lookup>
  8013ca:	89 c3                	mov    %eax,%ebx
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	78 1a                	js     8013ed <fd_close+0x6a>
		if (dev->dev_close) 
  8013d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8013d9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	74 0b                	je     8013ed <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013e2:	83 ec 0c             	sub    $0xc,%esp
  8013e5:	56                   	push   %esi
  8013e6:	ff d0                	call   *%eax
  8013e8:	89 c3                	mov    %eax,%ebx
  8013ea:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013ed:	83 ec 08             	sub    $0x8,%esp
  8013f0:	56                   	push   %esi
  8013f1:	6a 00                	push   $0x0
  8013f3:	e8 f8 f9 ff ff       	call   800df0 <sys_page_unmap>
	return r;
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	89 d8                	mov    %ebx,%eax
}
  8013fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801400:	5b                   	pop    %ebx
  801401:	5e                   	pop    %esi
  801402:	5d                   	pop    %ebp
  801403:	c3                   	ret    

00801404 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80140a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140d:	50                   	push   %eax
  80140e:	ff 75 08             	pushl  0x8(%ebp)
  801411:	e8 c4 fe ff ff       	call   8012da <fd_lookup>
  801416:	83 c4 08             	add    $0x8,%esp
  801419:	85 c0                	test   %eax,%eax
  80141b:	78 10                	js     80142d <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  80141d:	83 ec 08             	sub    $0x8,%esp
  801420:	6a 01                	push   $0x1
  801422:	ff 75 f4             	pushl  -0xc(%ebp)
  801425:	e8 59 ff ff ff       	call   801383 <fd_close>
  80142a:	83 c4 10             	add    $0x10,%esp
}
  80142d:	c9                   	leave  
  80142e:	c3                   	ret    

0080142f <close_all>:

void
close_all(void)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	53                   	push   %ebx
  801433:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801436:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80143b:	83 ec 0c             	sub    $0xc,%esp
  80143e:	53                   	push   %ebx
  80143f:	e8 c0 ff ff ff       	call   801404 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801444:	83 c3 01             	add    $0x1,%ebx
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	83 fb 20             	cmp    $0x20,%ebx
  80144d:	75 ec                	jne    80143b <close_all+0xc>
		close(i);
}
  80144f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801452:	c9                   	leave  
  801453:	c3                   	ret    

00801454 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	57                   	push   %edi
  801458:	56                   	push   %esi
  801459:	53                   	push   %ebx
  80145a:	83 ec 2c             	sub    $0x2c,%esp
  80145d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801460:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801463:	50                   	push   %eax
  801464:	ff 75 08             	pushl  0x8(%ebp)
  801467:	e8 6e fe ff ff       	call   8012da <fd_lookup>
  80146c:	83 c4 08             	add    $0x8,%esp
  80146f:	85 c0                	test   %eax,%eax
  801471:	0f 88 c1 00 00 00    	js     801538 <dup+0xe4>
		return r;
	close(newfdnum);
  801477:	83 ec 0c             	sub    $0xc,%esp
  80147a:	56                   	push   %esi
  80147b:	e8 84 ff ff ff       	call   801404 <close>

	newfd = INDEX2FD(newfdnum);
  801480:	89 f3                	mov    %esi,%ebx
  801482:	c1 e3 0c             	shl    $0xc,%ebx
  801485:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80148b:	83 c4 04             	add    $0x4,%esp
  80148e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801491:	e8 de fd ff ff       	call   801274 <fd2data>
  801496:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801498:	89 1c 24             	mov    %ebx,(%esp)
  80149b:	e8 d4 fd ff ff       	call   801274 <fd2data>
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014a6:	89 f8                	mov    %edi,%eax
  8014a8:	c1 e8 16             	shr    $0x16,%eax
  8014ab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014b2:	a8 01                	test   $0x1,%al
  8014b4:	74 37                	je     8014ed <dup+0x99>
  8014b6:	89 f8                	mov    %edi,%eax
  8014b8:	c1 e8 0c             	shr    $0xc,%eax
  8014bb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014c2:	f6 c2 01             	test   $0x1,%dl
  8014c5:	74 26                	je     8014ed <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ce:	83 ec 0c             	sub    $0xc,%esp
  8014d1:	25 07 0e 00 00       	and    $0xe07,%eax
  8014d6:	50                   	push   %eax
  8014d7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014da:	6a 00                	push   $0x0
  8014dc:	57                   	push   %edi
  8014dd:	6a 00                	push   $0x0
  8014df:	e8 ca f8 ff ff       	call   800dae <sys_page_map>
  8014e4:	89 c7                	mov    %eax,%edi
  8014e6:	83 c4 20             	add    $0x20,%esp
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	78 2e                	js     80151b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014f0:	89 d0                	mov    %edx,%eax
  8014f2:	c1 e8 0c             	shr    $0xc,%eax
  8014f5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014fc:	83 ec 0c             	sub    $0xc,%esp
  8014ff:	25 07 0e 00 00       	and    $0xe07,%eax
  801504:	50                   	push   %eax
  801505:	53                   	push   %ebx
  801506:	6a 00                	push   $0x0
  801508:	52                   	push   %edx
  801509:	6a 00                	push   $0x0
  80150b:	e8 9e f8 ff ff       	call   800dae <sys_page_map>
  801510:	89 c7                	mov    %eax,%edi
  801512:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801515:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801517:	85 ff                	test   %edi,%edi
  801519:	79 1d                	jns    801538 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80151b:	83 ec 08             	sub    $0x8,%esp
  80151e:	53                   	push   %ebx
  80151f:	6a 00                	push   $0x0
  801521:	e8 ca f8 ff ff       	call   800df0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801526:	83 c4 08             	add    $0x8,%esp
  801529:	ff 75 d4             	pushl  -0x2c(%ebp)
  80152c:	6a 00                	push   $0x0
  80152e:	e8 bd f8 ff ff       	call   800df0 <sys_page_unmap>
	return r;
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	89 f8                	mov    %edi,%eax
}
  801538:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80153b:	5b                   	pop    %ebx
  80153c:	5e                   	pop    %esi
  80153d:	5f                   	pop    %edi
  80153e:	5d                   	pop    %ebp
  80153f:	c3                   	ret    

00801540 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	53                   	push   %ebx
  801544:	83 ec 14             	sub    $0x14,%esp
  801547:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154d:	50                   	push   %eax
  80154e:	53                   	push   %ebx
  80154f:	e8 86 fd ff ff       	call   8012da <fd_lookup>
  801554:	83 c4 08             	add    $0x8,%esp
  801557:	89 c2                	mov    %eax,%edx
  801559:	85 c0                	test   %eax,%eax
  80155b:	78 6d                	js     8015ca <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155d:	83 ec 08             	sub    $0x8,%esp
  801560:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801563:	50                   	push   %eax
  801564:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801567:	ff 30                	pushl  (%eax)
  801569:	e8 c2 fd ff ff       	call   801330 <dev_lookup>
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	85 c0                	test   %eax,%eax
  801573:	78 4c                	js     8015c1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801575:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801578:	8b 42 08             	mov    0x8(%edx),%eax
  80157b:	83 e0 03             	and    $0x3,%eax
  80157e:	83 f8 01             	cmp    $0x1,%eax
  801581:	75 21                	jne    8015a4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801583:	a1 08 50 80 00       	mov    0x805008,%eax
  801588:	8b 40 48             	mov    0x48(%eax),%eax
  80158b:	83 ec 04             	sub    $0x4,%esp
  80158e:	53                   	push   %ebx
  80158f:	50                   	push   %eax
  801590:	68 f1 2e 80 00       	push   $0x802ef1
  801595:	e8 23 ed ff ff       	call   8002bd <cprintf>
		return -E_INVAL;
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015a2:	eb 26                	jmp    8015ca <read+0x8a>
	}
	if (!dev->dev_read)
  8015a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a7:	8b 40 08             	mov    0x8(%eax),%eax
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	74 17                	je     8015c5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015ae:	83 ec 04             	sub    $0x4,%esp
  8015b1:	ff 75 10             	pushl  0x10(%ebp)
  8015b4:	ff 75 0c             	pushl  0xc(%ebp)
  8015b7:	52                   	push   %edx
  8015b8:	ff d0                	call   *%eax
  8015ba:	89 c2                	mov    %eax,%edx
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	eb 09                	jmp    8015ca <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c1:	89 c2                	mov    %eax,%edx
  8015c3:	eb 05                	jmp    8015ca <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015ca:	89 d0                	mov    %edx,%eax
  8015cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cf:	c9                   	leave  
  8015d0:	c3                   	ret    

008015d1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	57                   	push   %edi
  8015d5:	56                   	push   %esi
  8015d6:	53                   	push   %ebx
  8015d7:	83 ec 0c             	sub    $0xc,%esp
  8015da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015dd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e5:	eb 21                	jmp    801608 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015e7:	83 ec 04             	sub    $0x4,%esp
  8015ea:	89 f0                	mov    %esi,%eax
  8015ec:	29 d8                	sub    %ebx,%eax
  8015ee:	50                   	push   %eax
  8015ef:	89 d8                	mov    %ebx,%eax
  8015f1:	03 45 0c             	add    0xc(%ebp),%eax
  8015f4:	50                   	push   %eax
  8015f5:	57                   	push   %edi
  8015f6:	e8 45 ff ff ff       	call   801540 <read>
		if (m < 0)
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 10                	js     801612 <readn+0x41>
			return m;
		if (m == 0)
  801602:	85 c0                	test   %eax,%eax
  801604:	74 0a                	je     801610 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801606:	01 c3                	add    %eax,%ebx
  801608:	39 f3                	cmp    %esi,%ebx
  80160a:	72 db                	jb     8015e7 <readn+0x16>
  80160c:	89 d8                	mov    %ebx,%eax
  80160e:	eb 02                	jmp    801612 <readn+0x41>
  801610:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801612:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801615:	5b                   	pop    %ebx
  801616:	5e                   	pop    %esi
  801617:	5f                   	pop    %edi
  801618:	5d                   	pop    %ebp
  801619:	c3                   	ret    

0080161a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	53                   	push   %ebx
  80161e:	83 ec 14             	sub    $0x14,%esp
  801621:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801624:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801627:	50                   	push   %eax
  801628:	53                   	push   %ebx
  801629:	e8 ac fc ff ff       	call   8012da <fd_lookup>
  80162e:	83 c4 08             	add    $0x8,%esp
  801631:	89 c2                	mov    %eax,%edx
  801633:	85 c0                	test   %eax,%eax
  801635:	78 68                	js     80169f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801637:	83 ec 08             	sub    $0x8,%esp
  80163a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163d:	50                   	push   %eax
  80163e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801641:	ff 30                	pushl  (%eax)
  801643:	e8 e8 fc ff ff       	call   801330 <dev_lookup>
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	85 c0                	test   %eax,%eax
  80164d:	78 47                	js     801696 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80164f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801652:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801656:	75 21                	jne    801679 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801658:	a1 08 50 80 00       	mov    0x805008,%eax
  80165d:	8b 40 48             	mov    0x48(%eax),%eax
  801660:	83 ec 04             	sub    $0x4,%esp
  801663:	53                   	push   %ebx
  801664:	50                   	push   %eax
  801665:	68 0d 2f 80 00       	push   $0x802f0d
  80166a:	e8 4e ec ff ff       	call   8002bd <cprintf>
		return -E_INVAL;
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801677:	eb 26                	jmp    80169f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801679:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80167c:	8b 52 0c             	mov    0xc(%edx),%edx
  80167f:	85 d2                	test   %edx,%edx
  801681:	74 17                	je     80169a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801683:	83 ec 04             	sub    $0x4,%esp
  801686:	ff 75 10             	pushl  0x10(%ebp)
  801689:	ff 75 0c             	pushl  0xc(%ebp)
  80168c:	50                   	push   %eax
  80168d:	ff d2                	call   *%edx
  80168f:	89 c2                	mov    %eax,%edx
  801691:	83 c4 10             	add    $0x10,%esp
  801694:	eb 09                	jmp    80169f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801696:	89 c2                	mov    %eax,%edx
  801698:	eb 05                	jmp    80169f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80169a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80169f:	89 d0                	mov    %edx,%eax
  8016a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016ac:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016af:	50                   	push   %eax
  8016b0:	ff 75 08             	pushl  0x8(%ebp)
  8016b3:	e8 22 fc ff ff       	call   8012da <fd_lookup>
  8016b8:	83 c4 08             	add    $0x8,%esp
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 0e                	js     8016cd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016c5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016cd:	c9                   	leave  
  8016ce:	c3                   	ret    

008016cf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	53                   	push   %ebx
  8016d3:	83 ec 14             	sub    $0x14,%esp
  8016d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016dc:	50                   	push   %eax
  8016dd:	53                   	push   %ebx
  8016de:	e8 f7 fb ff ff       	call   8012da <fd_lookup>
  8016e3:	83 c4 08             	add    $0x8,%esp
  8016e6:	89 c2                	mov    %eax,%edx
  8016e8:	85 c0                	test   %eax,%eax
  8016ea:	78 65                	js     801751 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ec:	83 ec 08             	sub    $0x8,%esp
  8016ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f2:	50                   	push   %eax
  8016f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f6:	ff 30                	pushl  (%eax)
  8016f8:	e8 33 fc ff ff       	call   801330 <dev_lookup>
  8016fd:	83 c4 10             	add    $0x10,%esp
  801700:	85 c0                	test   %eax,%eax
  801702:	78 44                	js     801748 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801704:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801707:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80170b:	75 21                	jne    80172e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80170d:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801712:	8b 40 48             	mov    0x48(%eax),%eax
  801715:	83 ec 04             	sub    $0x4,%esp
  801718:	53                   	push   %ebx
  801719:	50                   	push   %eax
  80171a:	68 d0 2e 80 00       	push   $0x802ed0
  80171f:	e8 99 eb ff ff       	call   8002bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80172c:	eb 23                	jmp    801751 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80172e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801731:	8b 52 18             	mov    0x18(%edx),%edx
  801734:	85 d2                	test   %edx,%edx
  801736:	74 14                	je     80174c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801738:	83 ec 08             	sub    $0x8,%esp
  80173b:	ff 75 0c             	pushl  0xc(%ebp)
  80173e:	50                   	push   %eax
  80173f:	ff d2                	call   *%edx
  801741:	89 c2                	mov    %eax,%edx
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	eb 09                	jmp    801751 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801748:	89 c2                	mov    %eax,%edx
  80174a:	eb 05                	jmp    801751 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80174c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801751:	89 d0                	mov    %edx,%eax
  801753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	53                   	push   %ebx
  80175c:	83 ec 14             	sub    $0x14,%esp
  80175f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801762:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801765:	50                   	push   %eax
  801766:	ff 75 08             	pushl  0x8(%ebp)
  801769:	e8 6c fb ff ff       	call   8012da <fd_lookup>
  80176e:	83 c4 08             	add    $0x8,%esp
  801771:	89 c2                	mov    %eax,%edx
  801773:	85 c0                	test   %eax,%eax
  801775:	78 58                	js     8017cf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801777:	83 ec 08             	sub    $0x8,%esp
  80177a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177d:	50                   	push   %eax
  80177e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801781:	ff 30                	pushl  (%eax)
  801783:	e8 a8 fb ff ff       	call   801330 <dev_lookup>
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	85 c0                	test   %eax,%eax
  80178d:	78 37                	js     8017c6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80178f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801792:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801796:	74 32                	je     8017ca <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801798:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80179b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017a2:	00 00 00 
	stat->st_isdir = 0;
  8017a5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017ac:	00 00 00 
	stat->st_dev = dev;
  8017af:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017b5:	83 ec 08             	sub    $0x8,%esp
  8017b8:	53                   	push   %ebx
  8017b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8017bc:	ff 50 14             	call   *0x14(%eax)
  8017bf:	89 c2                	mov    %eax,%edx
  8017c1:	83 c4 10             	add    $0x10,%esp
  8017c4:	eb 09                	jmp    8017cf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c6:	89 c2                	mov    %eax,%edx
  8017c8:	eb 05                	jmp    8017cf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017ca:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017cf:	89 d0                	mov    %edx,%eax
  8017d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d4:	c9                   	leave  
  8017d5:	c3                   	ret    

008017d6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	56                   	push   %esi
  8017da:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017db:	83 ec 08             	sub    $0x8,%esp
  8017de:	6a 00                	push   $0x0
  8017e0:	ff 75 08             	pushl  0x8(%ebp)
  8017e3:	e8 2b 02 00 00       	call   801a13 <open>
  8017e8:	89 c3                	mov    %eax,%ebx
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	78 1b                	js     80180c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017f1:	83 ec 08             	sub    $0x8,%esp
  8017f4:	ff 75 0c             	pushl  0xc(%ebp)
  8017f7:	50                   	push   %eax
  8017f8:	e8 5b ff ff ff       	call   801758 <fstat>
  8017fd:	89 c6                	mov    %eax,%esi
	close(fd);
  8017ff:	89 1c 24             	mov    %ebx,(%esp)
  801802:	e8 fd fb ff ff       	call   801404 <close>
	return r;
  801807:	83 c4 10             	add    $0x10,%esp
  80180a:	89 f0                	mov    %esi,%eax
}
  80180c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180f:	5b                   	pop    %ebx
  801810:	5e                   	pop    %esi
  801811:	5d                   	pop    %ebp
  801812:	c3                   	ret    

00801813 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	56                   	push   %esi
  801817:	53                   	push   %ebx
  801818:	89 c6                	mov    %eax,%esi
  80181a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80181c:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801823:	75 12                	jne    801837 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801825:	83 ec 0c             	sub    $0xc,%esp
  801828:	6a 01                	push   $0x1
  80182a:	e8 b9 0e 00 00       	call   8026e8 <ipc_find_env>
  80182f:	a3 04 50 80 00       	mov    %eax,0x805004
  801834:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801837:	6a 07                	push   $0x7
  801839:	68 00 60 80 00       	push   $0x806000
  80183e:	56                   	push   %esi
  80183f:	ff 35 04 50 80 00    	pushl  0x805004
  801845:	e8 48 0e 00 00       	call   802692 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80184a:	83 c4 0c             	add    $0xc,%esp
  80184d:	6a 00                	push   $0x0
  80184f:	53                   	push   %ebx
  801850:	6a 00                	push   $0x0
  801852:	e8 d2 0d 00 00       	call   802629 <ipc_recv>
}
  801857:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185a:	5b                   	pop    %ebx
  80185b:	5e                   	pop    %esi
  80185c:	5d                   	pop    %ebp
  80185d:	c3                   	ret    

0080185e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801864:	8b 45 08             	mov    0x8(%ebp),%eax
  801867:	8b 40 0c             	mov    0xc(%eax),%eax
  80186a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80186f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801872:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801877:	ba 00 00 00 00       	mov    $0x0,%edx
  80187c:	b8 02 00 00 00       	mov    $0x2,%eax
  801881:	e8 8d ff ff ff       	call   801813 <fsipc>
}
  801886:	c9                   	leave  
  801887:	c3                   	ret    

00801888 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80188e:	8b 45 08             	mov    0x8(%ebp),%eax
  801891:	8b 40 0c             	mov    0xc(%eax),%eax
  801894:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801899:	ba 00 00 00 00       	mov    $0x0,%edx
  80189e:	b8 06 00 00 00       	mov    $0x6,%eax
  8018a3:	e8 6b ff ff ff       	call   801813 <fsipc>
}
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	53                   	push   %ebx
  8018ae:	83 ec 04             	sub    $0x4,%esp
  8018b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ba:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c4:	b8 05 00 00 00       	mov    $0x5,%eax
  8018c9:	e8 45 ff ff ff       	call   801813 <fsipc>
  8018ce:	85 c0                	test   %eax,%eax
  8018d0:	78 2c                	js     8018fe <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018d2:	83 ec 08             	sub    $0x8,%esp
  8018d5:	68 00 60 80 00       	push   $0x806000
  8018da:	53                   	push   %ebx
  8018db:	e8 11 f0 ff ff       	call   8008f1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018e0:	a1 80 60 80 00       	mov    0x806080,%eax
  8018e5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018eb:	a1 84 60 80 00       	mov    0x806084,%eax
  8018f0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018f6:	83 c4 10             	add    $0x10,%esp
  8018f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801901:	c9                   	leave  
  801902:	c3                   	ret    

00801903 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	53                   	push   %ebx
  801907:	83 ec 08             	sub    $0x8,%esp
  80190a:	8b 45 10             	mov    0x10(%ebp),%eax
  80190d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801912:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801917:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80191a:	8b 45 08             	mov    0x8(%ebp),%eax
  80191d:	8b 40 0c             	mov    0xc(%eax),%eax
  801920:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.write.req_n = n;
  801925:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80192b:	53                   	push   %ebx
  80192c:	ff 75 0c             	pushl  0xc(%ebp)
  80192f:	68 08 60 80 00       	push   $0x806008
  801934:	e8 4a f1 ff ff       	call   800a83 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801939:	ba 00 00 00 00       	mov    $0x0,%edx
  80193e:	b8 04 00 00 00       	mov    $0x4,%eax
  801943:	e8 cb fe ff ff       	call   801813 <fsipc>
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	85 c0                	test   %eax,%eax
  80194d:	78 3d                	js     80198c <devfile_write+0x89>
		return r;

	assert(r <= n);
  80194f:	39 d8                	cmp    %ebx,%eax
  801951:	76 19                	jbe    80196c <devfile_write+0x69>
  801953:	68 3c 2f 80 00       	push   $0x802f3c
  801958:	68 43 2f 80 00       	push   $0x802f43
  80195d:	68 9f 00 00 00       	push   $0x9f
  801962:	68 58 2f 80 00       	push   $0x802f58
  801967:	e8 78 e8 ff ff       	call   8001e4 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  80196c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801971:	76 19                	jbe    80198c <devfile_write+0x89>
  801973:	68 70 2f 80 00       	push   $0x802f70
  801978:	68 43 2f 80 00       	push   $0x802f43
  80197d:	68 a0 00 00 00       	push   $0xa0
  801982:	68 58 2f 80 00       	push   $0x802f58
  801987:	e8 58 e8 ff ff       	call   8001e4 <_panic>

	return r;
}
  80198c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198f:	c9                   	leave  
  801990:	c3                   	ret    

00801991 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	56                   	push   %esi
  801995:	53                   	push   %ebx
  801996:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801999:	8b 45 08             	mov    0x8(%ebp),%eax
  80199c:	8b 40 0c             	mov    0xc(%eax),%eax
  80199f:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8019a4:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8019af:	b8 03 00 00 00       	mov    $0x3,%eax
  8019b4:	e8 5a fe ff ff       	call   801813 <fsipc>
  8019b9:	89 c3                	mov    %eax,%ebx
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	78 4b                	js     801a0a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019bf:	39 c6                	cmp    %eax,%esi
  8019c1:	73 16                	jae    8019d9 <devfile_read+0x48>
  8019c3:	68 3c 2f 80 00       	push   $0x802f3c
  8019c8:	68 43 2f 80 00       	push   $0x802f43
  8019cd:	6a 7e                	push   $0x7e
  8019cf:	68 58 2f 80 00       	push   $0x802f58
  8019d4:	e8 0b e8 ff ff       	call   8001e4 <_panic>
	assert(r <= PGSIZE);
  8019d9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019de:	7e 16                	jle    8019f6 <devfile_read+0x65>
  8019e0:	68 63 2f 80 00       	push   $0x802f63
  8019e5:	68 43 2f 80 00       	push   $0x802f43
  8019ea:	6a 7f                	push   $0x7f
  8019ec:	68 58 2f 80 00       	push   $0x802f58
  8019f1:	e8 ee e7 ff ff       	call   8001e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019f6:	83 ec 04             	sub    $0x4,%esp
  8019f9:	50                   	push   %eax
  8019fa:	68 00 60 80 00       	push   $0x806000
  8019ff:	ff 75 0c             	pushl  0xc(%ebp)
  801a02:	e8 7c f0 ff ff       	call   800a83 <memmove>
	return r;
  801a07:	83 c4 10             	add    $0x10,%esp
}
  801a0a:	89 d8                	mov    %ebx,%eax
  801a0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0f:	5b                   	pop    %ebx
  801a10:	5e                   	pop    %esi
  801a11:	5d                   	pop    %ebp
  801a12:	c3                   	ret    

00801a13 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	53                   	push   %ebx
  801a17:	83 ec 20             	sub    $0x20,%esp
  801a1a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a1d:	53                   	push   %ebx
  801a1e:	e8 95 ee ff ff       	call   8008b8 <strlen>
  801a23:	83 c4 10             	add    $0x10,%esp
  801a26:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a2b:	7f 67                	jg     801a94 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a2d:	83 ec 0c             	sub    $0xc,%esp
  801a30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a33:	50                   	push   %eax
  801a34:	e8 52 f8 ff ff       	call   80128b <fd_alloc>
  801a39:	83 c4 10             	add    $0x10,%esp
		return r;
  801a3c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	78 57                	js     801a99 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a42:	83 ec 08             	sub    $0x8,%esp
  801a45:	53                   	push   %ebx
  801a46:	68 00 60 80 00       	push   $0x806000
  801a4b:	e8 a1 ee ff ff       	call   8008f1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a53:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a58:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a5b:	b8 01 00 00 00       	mov    $0x1,%eax
  801a60:	e8 ae fd ff ff       	call   801813 <fsipc>
  801a65:	89 c3                	mov    %eax,%ebx
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	79 14                	jns    801a82 <open+0x6f>
		fd_close(fd, 0);
  801a6e:	83 ec 08             	sub    $0x8,%esp
  801a71:	6a 00                	push   $0x0
  801a73:	ff 75 f4             	pushl  -0xc(%ebp)
  801a76:	e8 08 f9 ff ff       	call   801383 <fd_close>
		return r;
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	89 da                	mov    %ebx,%edx
  801a80:	eb 17                	jmp    801a99 <open+0x86>
	}

	return fd2num(fd);
  801a82:	83 ec 0c             	sub    $0xc,%esp
  801a85:	ff 75 f4             	pushl  -0xc(%ebp)
  801a88:	e8 d7 f7 ff ff       	call   801264 <fd2num>
  801a8d:	89 c2                	mov    %eax,%edx
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	eb 05                	jmp    801a99 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a94:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a99:	89 d0                	mov    %edx,%eax
  801a9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9e:	c9                   	leave  
  801a9f:	c3                   	ret    

00801aa0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801aa6:	ba 00 00 00 00       	mov    $0x0,%edx
  801aab:	b8 08 00 00 00       	mov    $0x8,%eax
  801ab0:	e8 5e fd ff ff       	call   801813 <fsipc>
}
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	57                   	push   %edi
  801abb:	56                   	push   %esi
  801abc:	53                   	push   %ebx
  801abd:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801ac3:	6a 00                	push   $0x0
  801ac5:	ff 75 08             	pushl  0x8(%ebp)
  801ac8:	e8 46 ff ff ff       	call   801a13 <open>
  801acd:	89 c7                	mov    %eax,%edi
  801acf:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	0f 88 af 04 00 00    	js     801f8f <spawn+0x4d8>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801ae0:	83 ec 04             	sub    $0x4,%esp
  801ae3:	68 00 02 00 00       	push   $0x200
  801ae8:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801aee:	50                   	push   %eax
  801aef:	57                   	push   %edi
  801af0:	e8 dc fa ff ff       	call   8015d1 <readn>
  801af5:	83 c4 10             	add    $0x10,%esp
  801af8:	3d 00 02 00 00       	cmp    $0x200,%eax
  801afd:	75 0c                	jne    801b0b <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801aff:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801b06:	45 4c 46 
  801b09:	74 33                	je     801b3e <spawn+0x87>
		close(fd);
  801b0b:	83 ec 0c             	sub    $0xc,%esp
  801b0e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b14:	e8 eb f8 ff ff       	call   801404 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801b19:	83 c4 0c             	add    $0xc,%esp
  801b1c:	68 7f 45 4c 46       	push   $0x464c457f
  801b21:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801b27:	68 9d 2f 80 00       	push   $0x802f9d
  801b2c:	e8 8c e7 ff ff       	call   8002bd <cprintf>
		return -E_NOT_EXEC;
  801b31:	83 c4 10             	add    $0x10,%esp
  801b34:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801b39:	e9 b1 04 00 00       	jmp    801fef <spawn+0x538>
  801b3e:	b8 07 00 00 00       	mov    $0x7,%eax
  801b43:	cd 30                	int    $0x30
  801b45:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801b4b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801b51:	85 c0                	test   %eax,%eax
  801b53:	0f 88 3e 04 00 00    	js     801f97 <spawn+0x4e0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801b59:	89 c6                	mov    %eax,%esi
  801b5b:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801b61:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801b64:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801b6a:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801b70:	b9 11 00 00 00       	mov    $0x11,%ecx
  801b75:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801b77:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801b7d:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b83:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801b88:	be 00 00 00 00       	mov    $0x0,%esi
  801b8d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b90:	eb 13                	jmp    801ba5 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801b92:	83 ec 0c             	sub    $0xc,%esp
  801b95:	50                   	push   %eax
  801b96:	e8 1d ed ff ff       	call   8008b8 <strlen>
  801b9b:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b9f:	83 c3 01             	add    $0x1,%ebx
  801ba2:	83 c4 10             	add    $0x10,%esp
  801ba5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801bac:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	75 df                	jne    801b92 <spawn+0xdb>
  801bb3:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801bb9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801bbf:	bf 00 10 40 00       	mov    $0x401000,%edi
  801bc4:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801bc6:	89 fa                	mov    %edi,%edx
  801bc8:	83 e2 fc             	and    $0xfffffffc,%edx
  801bcb:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801bd2:	29 c2                	sub    %eax,%edx
  801bd4:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801bda:	8d 42 f8             	lea    -0x8(%edx),%eax
  801bdd:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801be2:	0f 86 bf 03 00 00    	jbe    801fa7 <spawn+0x4f0>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801be8:	83 ec 04             	sub    $0x4,%esp
  801beb:	6a 07                	push   $0x7
  801bed:	68 00 00 40 00       	push   $0x400000
  801bf2:	6a 00                	push   $0x0
  801bf4:	e8 72 f1 ff ff       	call   800d6b <sys_page_alloc>
  801bf9:	83 c4 10             	add    $0x10,%esp
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	0f 88 aa 03 00 00    	js     801fae <spawn+0x4f7>
  801c04:	be 00 00 00 00       	mov    $0x0,%esi
  801c09:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801c0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c12:	eb 30                	jmp    801c44 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801c14:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801c1a:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801c20:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801c23:	83 ec 08             	sub    $0x8,%esp
  801c26:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801c29:	57                   	push   %edi
  801c2a:	e8 c2 ec ff ff       	call   8008f1 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801c2f:	83 c4 04             	add    $0x4,%esp
  801c32:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801c35:	e8 7e ec ff ff       	call   8008b8 <strlen>
  801c3a:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801c3e:	83 c6 01             	add    $0x1,%esi
  801c41:	83 c4 10             	add    $0x10,%esp
  801c44:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801c4a:	7f c8                	jg     801c14 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801c4c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c52:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801c58:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801c5f:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801c65:	74 19                	je     801c80 <spawn+0x1c9>
  801c67:	68 0c 30 80 00       	push   $0x80300c
  801c6c:	68 43 2f 80 00       	push   $0x802f43
  801c71:	68 f2 00 00 00       	push   $0xf2
  801c76:	68 b7 2f 80 00       	push   $0x802fb7
  801c7b:	e8 64 e5 ff ff       	call   8001e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801c80:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801c86:	89 f8                	mov    %edi,%eax
  801c88:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801c8d:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801c90:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801c96:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801c99:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801c9f:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ca5:	83 ec 0c             	sub    $0xc,%esp
  801ca8:	6a 07                	push   $0x7
  801caa:	68 00 d0 bf ee       	push   $0xeebfd000
  801caf:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801cb5:	68 00 00 40 00       	push   $0x400000
  801cba:	6a 00                	push   $0x0
  801cbc:	e8 ed f0 ff ff       	call   800dae <sys_page_map>
  801cc1:	89 c3                	mov    %eax,%ebx
  801cc3:	83 c4 20             	add    $0x20,%esp
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	0f 88 0f 03 00 00    	js     801fdd <spawn+0x526>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801cce:	83 ec 08             	sub    $0x8,%esp
  801cd1:	68 00 00 40 00       	push   $0x400000
  801cd6:	6a 00                	push   $0x0
  801cd8:	e8 13 f1 ff ff       	call   800df0 <sys_page_unmap>
  801cdd:	89 c3                	mov    %eax,%ebx
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	85 c0                	test   %eax,%eax
  801ce4:	0f 88 f3 02 00 00    	js     801fdd <spawn+0x526>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801cea:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801cf0:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801cf7:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801cfd:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801d04:	00 00 00 
  801d07:	e9 88 01 00 00       	jmp    801e94 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801d0c:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801d12:	83 38 01             	cmpl   $0x1,(%eax)
  801d15:	0f 85 6b 01 00 00    	jne    801e86 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d1b:	89 c7                	mov    %eax,%edi
  801d1d:	8b 40 18             	mov    0x18(%eax),%eax
  801d20:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801d26:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801d29:	83 f8 01             	cmp    $0x1,%eax
  801d2c:	19 c0                	sbb    %eax,%eax
  801d2e:	83 e0 fe             	and    $0xfffffffe,%eax
  801d31:	83 c0 07             	add    $0x7,%eax
  801d34:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801d3a:	89 f8                	mov    %edi,%eax
  801d3c:	8b 7f 04             	mov    0x4(%edi),%edi
  801d3f:	89 f9                	mov    %edi,%ecx
  801d41:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801d47:	8b 78 10             	mov    0x10(%eax),%edi
  801d4a:	8b 50 14             	mov    0x14(%eax),%edx
  801d4d:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801d53:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801d56:	89 f0                	mov    %esi,%eax
  801d58:	25 ff 0f 00 00       	and    $0xfff,%eax
  801d5d:	74 14                	je     801d73 <spawn+0x2bc>
		va -= i;
  801d5f:	29 c6                	sub    %eax,%esi
		memsz += i;
  801d61:	01 c2                	add    %eax,%edx
  801d63:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801d69:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801d6b:	29 c1                	sub    %eax,%ecx
  801d6d:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d73:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d78:	e9 f7 00 00 00       	jmp    801e74 <spawn+0x3bd>
		if (i >= filesz) {
  801d7d:	39 df                	cmp    %ebx,%edi
  801d7f:	77 27                	ja     801da8 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801d81:	83 ec 04             	sub    $0x4,%esp
  801d84:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801d8a:	56                   	push   %esi
  801d8b:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801d91:	e8 d5 ef ff ff       	call   800d6b <sys_page_alloc>
  801d96:	83 c4 10             	add    $0x10,%esp
  801d99:	85 c0                	test   %eax,%eax
  801d9b:	0f 89 c7 00 00 00    	jns    801e68 <spawn+0x3b1>
  801da1:	89 c3                	mov    %eax,%ebx
  801da3:	e9 14 02 00 00       	jmp    801fbc <spawn+0x505>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801da8:	83 ec 04             	sub    $0x4,%esp
  801dab:	6a 07                	push   $0x7
  801dad:	68 00 00 40 00       	push   $0x400000
  801db2:	6a 00                	push   $0x0
  801db4:	e8 b2 ef ff ff       	call   800d6b <sys_page_alloc>
  801db9:	83 c4 10             	add    $0x10,%esp
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	0f 88 ee 01 00 00    	js     801fb2 <spawn+0x4fb>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801dc4:	83 ec 08             	sub    $0x8,%esp
  801dc7:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801dcd:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801dd3:	50                   	push   %eax
  801dd4:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801dda:	e8 c7 f8 ff ff       	call   8016a6 <seek>
  801ddf:	83 c4 10             	add    $0x10,%esp
  801de2:	85 c0                	test   %eax,%eax
  801de4:	0f 88 cc 01 00 00    	js     801fb6 <spawn+0x4ff>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801dea:	83 ec 04             	sub    $0x4,%esp
  801ded:	89 f8                	mov    %edi,%eax
  801def:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801df5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801dfa:	ba 00 10 00 00       	mov    $0x1000,%edx
  801dff:	0f 47 c2             	cmova  %edx,%eax
  801e02:	50                   	push   %eax
  801e03:	68 00 00 40 00       	push   $0x400000
  801e08:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e0e:	e8 be f7 ff ff       	call   8015d1 <readn>
  801e13:	83 c4 10             	add    $0x10,%esp
  801e16:	85 c0                	test   %eax,%eax
  801e18:	0f 88 9c 01 00 00    	js     801fba <spawn+0x503>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801e1e:	83 ec 0c             	sub    $0xc,%esp
  801e21:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801e27:	56                   	push   %esi
  801e28:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801e2e:	68 00 00 40 00       	push   $0x400000
  801e33:	6a 00                	push   $0x0
  801e35:	e8 74 ef ff ff       	call   800dae <sys_page_map>
  801e3a:	83 c4 20             	add    $0x20,%esp
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	79 15                	jns    801e56 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801e41:	50                   	push   %eax
  801e42:	68 c3 2f 80 00       	push   $0x802fc3
  801e47:	68 25 01 00 00       	push   $0x125
  801e4c:	68 b7 2f 80 00       	push   $0x802fb7
  801e51:	e8 8e e3 ff ff       	call   8001e4 <_panic>
			sys_page_unmap(0, UTEMP);
  801e56:	83 ec 08             	sub    $0x8,%esp
  801e59:	68 00 00 40 00       	push   $0x400000
  801e5e:	6a 00                	push   $0x0
  801e60:	e8 8b ef ff ff       	call   800df0 <sys_page_unmap>
  801e65:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801e68:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e6e:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801e74:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801e7a:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801e80:	0f 87 f7 fe ff ff    	ja     801d7d <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e86:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801e8d:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801e94:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801e9b:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801ea1:	0f 8c 65 fe ff ff    	jl     801d0c <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801ea7:	83 ec 0c             	sub    $0xc,%esp
  801eaa:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801eb0:	e8 4f f5 ff ff       	call   801404 <close>
  801eb5:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	int r;

	// loop through all page table entries
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn) {
  801eb8:	bb 00 08 00 00       	mov    $0x800,%ebx
  801ebd:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		// the page table does not exist at all
		if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) {
  801ec3:	89 d8                	mov    %ebx,%eax
  801ec5:	c1 e0 0c             	shl    $0xc,%eax
  801ec8:	89 c2                	mov    %eax,%edx
  801eca:	c1 ea 16             	shr    $0x16,%edx
  801ecd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ed4:	f6 c2 01             	test   $0x1,%dl
  801ed7:	75 08                	jne    801ee1 <spawn+0x42a>
			pn += NPTENTRIES - 1;
  801ed9:	81 c3 ff 03 00 00    	add    $0x3ff,%ebx
  801edf:	eb 3c                	jmp    801f1d <spawn+0x466>
			continue;
		}

		// virtual page pn's page table entry
		pte_t pe = uvpt[pn];
  801ee1:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx

		// share the page with the new environment
		if(pe & PTE_SHARE) {
  801ee8:	f6 c6 04             	test   $0x4,%dh
  801eeb:	74 30                	je     801f1d <spawn+0x466>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), child, 
  801eed:	83 ec 0c             	sub    $0xc,%esp
  801ef0:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801ef6:	52                   	push   %edx
  801ef7:	50                   	push   %eax
  801ef8:	56                   	push   %esi
  801ef9:	50                   	push   %eax
  801efa:	6a 00                	push   $0x0
  801efc:	e8 ad ee ff ff       	call   800dae <sys_page_map>
  801f01:	83 c4 20             	add    $0x20,%esp
  801f04:	85 c0                	test   %eax,%eax
  801f06:	79 15                	jns    801f1d <spawn+0x466>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("copy_shared: %e", r);
  801f08:	50                   	push   %eax
  801f09:	68 e0 2f 80 00       	push   $0x802fe0
  801f0e:	68 42 01 00 00       	push   $0x142
  801f13:	68 b7 2f 80 00       	push   $0x802fb7
  801f18:	e8 c7 e2 ff ff       	call   8001e4 <_panic>
{
	// LAB 5: Your code here.
	int r;

	// loop through all page table entries
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn) {
  801f1d:	83 c3 01             	add    $0x1,%ebx
  801f20:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801f26:	76 9b                	jbe    801ec3 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801f28:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801f2f:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801f32:	83 ec 08             	sub    $0x8,%esp
  801f35:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801f3b:	50                   	push   %eax
  801f3c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801f42:	e8 2d ef ff ff       	call   800e74 <sys_env_set_trapframe>
  801f47:	83 c4 10             	add    $0x10,%esp
  801f4a:	85 c0                	test   %eax,%eax
  801f4c:	79 15                	jns    801f63 <spawn+0x4ac>
		panic("sys_env_set_trapframe: %e", r);
  801f4e:	50                   	push   %eax
  801f4f:	68 f0 2f 80 00       	push   $0x802ff0
  801f54:	68 86 00 00 00       	push   $0x86
  801f59:	68 b7 2f 80 00       	push   $0x802fb7
  801f5e:	e8 81 e2 ff ff       	call   8001e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801f63:	83 ec 08             	sub    $0x8,%esp
  801f66:	6a 02                	push   $0x2
  801f68:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801f6e:	e8 bf ee ff ff       	call   800e32 <sys_env_set_status>
  801f73:	83 c4 10             	add    $0x10,%esp
  801f76:	85 c0                	test   %eax,%eax
  801f78:	79 25                	jns    801f9f <spawn+0x4e8>
		panic("sys_env_set_status: %e", r);
  801f7a:	50                   	push   %eax
  801f7b:	68 60 2e 80 00       	push   $0x802e60
  801f80:	68 89 00 00 00       	push   $0x89
  801f85:	68 b7 2f 80 00       	push   $0x802fb7
  801f8a:	e8 55 e2 ff ff       	call   8001e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801f8f:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801f95:	eb 58                	jmp    801fef <spawn+0x538>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801f97:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801f9d:	eb 50                	jmp    801fef <spawn+0x538>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801f9f:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801fa5:	eb 48                	jmp    801fef <spawn+0x538>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801fa7:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801fac:	eb 41                	jmp    801fef <spawn+0x538>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801fae:	89 c3                	mov    %eax,%ebx
  801fb0:	eb 3d                	jmp    801fef <spawn+0x538>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801fb2:	89 c3                	mov    %eax,%ebx
  801fb4:	eb 06                	jmp    801fbc <spawn+0x505>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801fb6:	89 c3                	mov    %eax,%ebx
  801fb8:	eb 02                	jmp    801fbc <spawn+0x505>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801fba:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801fbc:	83 ec 0c             	sub    $0xc,%esp
  801fbf:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801fc5:	e8 22 ed ff ff       	call   800cec <sys_env_destroy>
	close(fd);
  801fca:	83 c4 04             	add    $0x4,%esp
  801fcd:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fd3:	e8 2c f4 ff ff       	call   801404 <close>
	return r;
  801fd8:	83 c4 10             	add    $0x10,%esp
  801fdb:	eb 12                	jmp    801fef <spawn+0x538>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801fdd:	83 ec 08             	sub    $0x8,%esp
  801fe0:	68 00 00 40 00       	push   $0x400000
  801fe5:	6a 00                	push   $0x0
  801fe7:	e8 04 ee ff ff       	call   800df0 <sys_page_unmap>
  801fec:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801fef:	89 d8                	mov    %ebx,%eax
  801ff1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff4:	5b                   	pop    %ebx
  801ff5:	5e                   	pop    %esi
  801ff6:	5f                   	pop    %edi
  801ff7:	5d                   	pop    %ebp
  801ff8:	c3                   	ret    

00801ff9 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801ff9:	55                   	push   %ebp
  801ffa:	89 e5                	mov    %esp,%ebp
  801ffc:	56                   	push   %esi
  801ffd:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ffe:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802001:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802006:	eb 03                	jmp    80200b <spawnl+0x12>
		argc++;
  802008:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80200b:	83 c2 04             	add    $0x4,%edx
  80200e:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802012:	75 f4                	jne    802008 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802014:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  80201b:	83 e2 f0             	and    $0xfffffff0,%edx
  80201e:	29 d4                	sub    %edx,%esp
  802020:	8d 54 24 03          	lea    0x3(%esp),%edx
  802024:	c1 ea 02             	shr    $0x2,%edx
  802027:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  80202e:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802030:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802033:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  80203a:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802041:	00 
  802042:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802044:	b8 00 00 00 00       	mov    $0x0,%eax
  802049:	eb 0a                	jmp    802055 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  80204b:	83 c0 01             	add    $0x1,%eax
  80204e:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802052:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802055:	39 d0                	cmp    %edx,%eax
  802057:	75 f2                	jne    80204b <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802059:	83 ec 08             	sub    $0x8,%esp
  80205c:	56                   	push   %esi
  80205d:	ff 75 08             	pushl  0x8(%ebp)
  802060:	e8 52 fa ff ff       	call   801ab7 <spawn>
}
  802065:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802068:	5b                   	pop    %ebx
  802069:	5e                   	pop    %esi
  80206a:	5d                   	pop    %ebp
  80206b:	c3                   	ret    

0080206c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80206c:	55                   	push   %ebp
  80206d:	89 e5                	mov    %esp,%ebp
  80206f:	56                   	push   %esi
  802070:	53                   	push   %ebx
  802071:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802074:	83 ec 0c             	sub    $0xc,%esp
  802077:	ff 75 08             	pushl  0x8(%ebp)
  80207a:	e8 f5 f1 ff ff       	call   801274 <fd2data>
  80207f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802081:	83 c4 08             	add    $0x8,%esp
  802084:	68 32 30 80 00       	push   $0x803032
  802089:	53                   	push   %ebx
  80208a:	e8 62 e8 ff ff       	call   8008f1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80208f:	8b 46 04             	mov    0x4(%esi),%eax
  802092:	2b 06                	sub    (%esi),%eax
  802094:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80209a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8020a1:	00 00 00 
	stat->st_dev = &devpipe;
  8020a4:	c7 83 88 00 00 00 28 	movl   $0x804028,0x88(%ebx)
  8020ab:	40 80 00 
	return 0;
}
  8020ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020b6:	5b                   	pop    %ebx
  8020b7:	5e                   	pop    %esi
  8020b8:	5d                   	pop    %ebp
  8020b9:	c3                   	ret    

008020ba <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8020ba:	55                   	push   %ebp
  8020bb:	89 e5                	mov    %esp,%ebp
  8020bd:	53                   	push   %ebx
  8020be:	83 ec 0c             	sub    $0xc,%esp
  8020c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8020c4:	53                   	push   %ebx
  8020c5:	6a 00                	push   $0x0
  8020c7:	e8 24 ed ff ff       	call   800df0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020cc:	89 1c 24             	mov    %ebx,(%esp)
  8020cf:	e8 a0 f1 ff ff       	call   801274 <fd2data>
  8020d4:	83 c4 08             	add    $0x8,%esp
  8020d7:	50                   	push   %eax
  8020d8:	6a 00                	push   $0x0
  8020da:	e8 11 ed ff ff       	call   800df0 <sys_page_unmap>
}
  8020df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020e2:	c9                   	leave  
  8020e3:	c3                   	ret    

008020e4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020e4:	55                   	push   %ebp
  8020e5:	89 e5                	mov    %esp,%ebp
  8020e7:	57                   	push   %edi
  8020e8:	56                   	push   %esi
  8020e9:	53                   	push   %ebx
  8020ea:	83 ec 1c             	sub    $0x1c,%esp
  8020ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8020f0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020f2:	a1 08 50 80 00       	mov    0x805008,%eax
  8020f7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8020fa:	83 ec 0c             	sub    $0xc,%esp
  8020fd:	ff 75 e0             	pushl  -0x20(%ebp)
  802100:	e8 1c 06 00 00       	call   802721 <pageref>
  802105:	89 c3                	mov    %eax,%ebx
  802107:	89 3c 24             	mov    %edi,(%esp)
  80210a:	e8 12 06 00 00       	call   802721 <pageref>
  80210f:	83 c4 10             	add    $0x10,%esp
  802112:	39 c3                	cmp    %eax,%ebx
  802114:	0f 94 c1             	sete   %cl
  802117:	0f b6 c9             	movzbl %cl,%ecx
  80211a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80211d:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802123:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802126:	39 ce                	cmp    %ecx,%esi
  802128:	74 1b                	je     802145 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80212a:	39 c3                	cmp    %eax,%ebx
  80212c:	75 c4                	jne    8020f2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80212e:	8b 42 58             	mov    0x58(%edx),%eax
  802131:	ff 75 e4             	pushl  -0x1c(%ebp)
  802134:	50                   	push   %eax
  802135:	56                   	push   %esi
  802136:	68 39 30 80 00       	push   $0x803039
  80213b:	e8 7d e1 ff ff       	call   8002bd <cprintf>
  802140:	83 c4 10             	add    $0x10,%esp
  802143:	eb ad                	jmp    8020f2 <_pipeisclosed+0xe>
	}
}
  802145:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802148:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80214b:	5b                   	pop    %ebx
  80214c:	5e                   	pop    %esi
  80214d:	5f                   	pop    %edi
  80214e:	5d                   	pop    %ebp
  80214f:	c3                   	ret    

00802150 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
  802153:	57                   	push   %edi
  802154:	56                   	push   %esi
  802155:	53                   	push   %ebx
  802156:	83 ec 28             	sub    $0x28,%esp
  802159:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80215c:	56                   	push   %esi
  80215d:	e8 12 f1 ff ff       	call   801274 <fd2data>
  802162:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802164:	83 c4 10             	add    $0x10,%esp
  802167:	bf 00 00 00 00       	mov    $0x0,%edi
  80216c:	eb 4b                	jmp    8021b9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80216e:	89 da                	mov    %ebx,%edx
  802170:	89 f0                	mov    %esi,%eax
  802172:	e8 6d ff ff ff       	call   8020e4 <_pipeisclosed>
  802177:	85 c0                	test   %eax,%eax
  802179:	75 48                	jne    8021c3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80217b:	e8 cc eb ff ff       	call   800d4c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802180:	8b 43 04             	mov    0x4(%ebx),%eax
  802183:	8b 0b                	mov    (%ebx),%ecx
  802185:	8d 51 20             	lea    0x20(%ecx),%edx
  802188:	39 d0                	cmp    %edx,%eax
  80218a:	73 e2                	jae    80216e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80218c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80218f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802193:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802196:	89 c2                	mov    %eax,%edx
  802198:	c1 fa 1f             	sar    $0x1f,%edx
  80219b:	89 d1                	mov    %edx,%ecx
  80219d:	c1 e9 1b             	shr    $0x1b,%ecx
  8021a0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8021a3:	83 e2 1f             	and    $0x1f,%edx
  8021a6:	29 ca                	sub    %ecx,%edx
  8021a8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8021ac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8021b0:	83 c0 01             	add    $0x1,%eax
  8021b3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021b6:	83 c7 01             	add    $0x1,%edi
  8021b9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021bc:	75 c2                	jne    802180 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8021be:	8b 45 10             	mov    0x10(%ebp),%eax
  8021c1:	eb 05                	jmp    8021c8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021c3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8021c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021cb:	5b                   	pop    %ebx
  8021cc:	5e                   	pop    %esi
  8021cd:	5f                   	pop    %edi
  8021ce:	5d                   	pop    %ebp
  8021cf:	c3                   	ret    

008021d0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021d0:	55                   	push   %ebp
  8021d1:	89 e5                	mov    %esp,%ebp
  8021d3:	57                   	push   %edi
  8021d4:	56                   	push   %esi
  8021d5:	53                   	push   %ebx
  8021d6:	83 ec 18             	sub    $0x18,%esp
  8021d9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8021dc:	57                   	push   %edi
  8021dd:	e8 92 f0 ff ff       	call   801274 <fd2data>
  8021e2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021e4:	83 c4 10             	add    $0x10,%esp
  8021e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021ec:	eb 3d                	jmp    80222b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021ee:	85 db                	test   %ebx,%ebx
  8021f0:	74 04                	je     8021f6 <devpipe_read+0x26>
				return i;
  8021f2:	89 d8                	mov    %ebx,%eax
  8021f4:	eb 44                	jmp    80223a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8021f6:	89 f2                	mov    %esi,%edx
  8021f8:	89 f8                	mov    %edi,%eax
  8021fa:	e8 e5 fe ff ff       	call   8020e4 <_pipeisclosed>
  8021ff:	85 c0                	test   %eax,%eax
  802201:	75 32                	jne    802235 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802203:	e8 44 eb ff ff       	call   800d4c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802208:	8b 06                	mov    (%esi),%eax
  80220a:	3b 46 04             	cmp    0x4(%esi),%eax
  80220d:	74 df                	je     8021ee <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80220f:	99                   	cltd   
  802210:	c1 ea 1b             	shr    $0x1b,%edx
  802213:	01 d0                	add    %edx,%eax
  802215:	83 e0 1f             	and    $0x1f,%eax
  802218:	29 d0                	sub    %edx,%eax
  80221a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80221f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802222:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802225:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802228:	83 c3 01             	add    $0x1,%ebx
  80222b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80222e:	75 d8                	jne    802208 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802230:	8b 45 10             	mov    0x10(%ebp),%eax
  802233:	eb 05                	jmp    80223a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802235:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80223a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5f                   	pop    %edi
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    

00802242 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802242:	55                   	push   %ebp
  802243:	89 e5                	mov    %esp,%ebp
  802245:	56                   	push   %esi
  802246:	53                   	push   %ebx
  802247:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80224a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80224d:	50                   	push   %eax
  80224e:	e8 38 f0 ff ff       	call   80128b <fd_alloc>
  802253:	83 c4 10             	add    $0x10,%esp
  802256:	89 c2                	mov    %eax,%edx
  802258:	85 c0                	test   %eax,%eax
  80225a:	0f 88 2c 01 00 00    	js     80238c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802260:	83 ec 04             	sub    $0x4,%esp
  802263:	68 07 04 00 00       	push   $0x407
  802268:	ff 75 f4             	pushl  -0xc(%ebp)
  80226b:	6a 00                	push   $0x0
  80226d:	e8 f9 ea ff ff       	call   800d6b <sys_page_alloc>
  802272:	83 c4 10             	add    $0x10,%esp
  802275:	89 c2                	mov    %eax,%edx
  802277:	85 c0                	test   %eax,%eax
  802279:	0f 88 0d 01 00 00    	js     80238c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80227f:	83 ec 0c             	sub    $0xc,%esp
  802282:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802285:	50                   	push   %eax
  802286:	e8 00 f0 ff ff       	call   80128b <fd_alloc>
  80228b:	89 c3                	mov    %eax,%ebx
  80228d:	83 c4 10             	add    $0x10,%esp
  802290:	85 c0                	test   %eax,%eax
  802292:	0f 88 e2 00 00 00    	js     80237a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802298:	83 ec 04             	sub    $0x4,%esp
  80229b:	68 07 04 00 00       	push   $0x407
  8022a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8022a3:	6a 00                	push   $0x0
  8022a5:	e8 c1 ea ff ff       	call   800d6b <sys_page_alloc>
  8022aa:	89 c3                	mov    %eax,%ebx
  8022ac:	83 c4 10             	add    $0x10,%esp
  8022af:	85 c0                	test   %eax,%eax
  8022b1:	0f 88 c3 00 00 00    	js     80237a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8022b7:	83 ec 0c             	sub    $0xc,%esp
  8022ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8022bd:	e8 b2 ef ff ff       	call   801274 <fd2data>
  8022c2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022c4:	83 c4 0c             	add    $0xc,%esp
  8022c7:	68 07 04 00 00       	push   $0x407
  8022cc:	50                   	push   %eax
  8022cd:	6a 00                	push   $0x0
  8022cf:	e8 97 ea ff ff       	call   800d6b <sys_page_alloc>
  8022d4:	89 c3                	mov    %eax,%ebx
  8022d6:	83 c4 10             	add    $0x10,%esp
  8022d9:	85 c0                	test   %eax,%eax
  8022db:	0f 88 89 00 00 00    	js     80236a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022e1:	83 ec 0c             	sub    $0xc,%esp
  8022e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8022e7:	e8 88 ef ff ff       	call   801274 <fd2data>
  8022ec:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8022f3:	50                   	push   %eax
  8022f4:	6a 00                	push   $0x0
  8022f6:	56                   	push   %esi
  8022f7:	6a 00                	push   $0x0
  8022f9:	e8 b0 ea ff ff       	call   800dae <sys_page_map>
  8022fe:	89 c3                	mov    %eax,%ebx
  802300:	83 c4 20             	add    $0x20,%esp
  802303:	85 c0                	test   %eax,%eax
  802305:	78 55                	js     80235c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802307:	8b 15 28 40 80 00    	mov    0x804028,%edx
  80230d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802310:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802312:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802315:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80231c:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802322:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802325:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802327:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80232a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802331:	83 ec 0c             	sub    $0xc,%esp
  802334:	ff 75 f4             	pushl  -0xc(%ebp)
  802337:	e8 28 ef ff ff       	call   801264 <fd2num>
  80233c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80233f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802341:	83 c4 04             	add    $0x4,%esp
  802344:	ff 75 f0             	pushl  -0x10(%ebp)
  802347:	e8 18 ef ff ff       	call   801264 <fd2num>
  80234c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80234f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802352:	83 c4 10             	add    $0x10,%esp
  802355:	ba 00 00 00 00       	mov    $0x0,%edx
  80235a:	eb 30                	jmp    80238c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80235c:	83 ec 08             	sub    $0x8,%esp
  80235f:	56                   	push   %esi
  802360:	6a 00                	push   $0x0
  802362:	e8 89 ea ff ff       	call   800df0 <sys_page_unmap>
  802367:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80236a:	83 ec 08             	sub    $0x8,%esp
  80236d:	ff 75 f0             	pushl  -0x10(%ebp)
  802370:	6a 00                	push   $0x0
  802372:	e8 79 ea ff ff       	call   800df0 <sys_page_unmap>
  802377:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80237a:	83 ec 08             	sub    $0x8,%esp
  80237d:	ff 75 f4             	pushl  -0xc(%ebp)
  802380:	6a 00                	push   $0x0
  802382:	e8 69 ea ff ff       	call   800df0 <sys_page_unmap>
  802387:	83 c4 10             	add    $0x10,%esp
  80238a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80238c:	89 d0                	mov    %edx,%eax
  80238e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802391:	5b                   	pop    %ebx
  802392:	5e                   	pop    %esi
  802393:	5d                   	pop    %ebp
  802394:	c3                   	ret    

00802395 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802395:	55                   	push   %ebp
  802396:	89 e5                	mov    %esp,%ebp
  802398:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80239b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80239e:	50                   	push   %eax
  80239f:	ff 75 08             	pushl  0x8(%ebp)
  8023a2:	e8 33 ef ff ff       	call   8012da <fd_lookup>
  8023a7:	83 c4 10             	add    $0x10,%esp
  8023aa:	85 c0                	test   %eax,%eax
  8023ac:	78 18                	js     8023c6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8023ae:	83 ec 0c             	sub    $0xc,%esp
  8023b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8023b4:	e8 bb ee ff ff       	call   801274 <fd2data>
	return _pipeisclosed(fd, p);
  8023b9:	89 c2                	mov    %eax,%edx
  8023bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023be:	e8 21 fd ff ff       	call   8020e4 <_pipeisclosed>
  8023c3:	83 c4 10             	add    $0x10,%esp
}
  8023c6:	c9                   	leave  
  8023c7:	c3                   	ret    

008023c8 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8023c8:	55                   	push   %ebp
  8023c9:	89 e5                	mov    %esp,%ebp
  8023cb:	56                   	push   %esi
  8023cc:	53                   	push   %ebx
  8023cd:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8023d0:	85 f6                	test   %esi,%esi
  8023d2:	75 16                	jne    8023ea <wait+0x22>
  8023d4:	68 51 30 80 00       	push   $0x803051
  8023d9:	68 43 2f 80 00       	push   $0x802f43
  8023de:	6a 09                	push   $0x9
  8023e0:	68 5c 30 80 00       	push   $0x80305c
  8023e5:	e8 fa dd ff ff       	call   8001e4 <_panic>
	e = &envs[ENVX(envid)];
  8023ea:	89 f3                	mov    %esi,%ebx
  8023ec:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8023f2:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8023f5:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8023fb:	eb 05                	jmp    802402 <wait+0x3a>
		sys_yield();
  8023fd:	e8 4a e9 ff ff       	call   800d4c <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802402:	8b 43 48             	mov    0x48(%ebx),%eax
  802405:	39 c6                	cmp    %eax,%esi
  802407:	75 07                	jne    802410 <wait+0x48>
  802409:	8b 43 54             	mov    0x54(%ebx),%eax
  80240c:	85 c0                	test   %eax,%eax
  80240e:	75 ed                	jne    8023fd <wait+0x35>
		sys_yield();
}
  802410:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802413:	5b                   	pop    %ebx
  802414:	5e                   	pop    %esi
  802415:	5d                   	pop    %ebp
  802416:	c3                   	ret    

00802417 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802417:	55                   	push   %ebp
  802418:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80241a:	b8 00 00 00 00       	mov    $0x0,%eax
  80241f:	5d                   	pop    %ebp
  802420:	c3                   	ret    

00802421 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802421:	55                   	push   %ebp
  802422:	89 e5                	mov    %esp,%ebp
  802424:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802427:	68 67 30 80 00       	push   $0x803067
  80242c:	ff 75 0c             	pushl  0xc(%ebp)
  80242f:	e8 bd e4 ff ff       	call   8008f1 <strcpy>
	return 0;
}
  802434:	b8 00 00 00 00       	mov    $0x0,%eax
  802439:	c9                   	leave  
  80243a:	c3                   	ret    

0080243b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80243b:	55                   	push   %ebp
  80243c:	89 e5                	mov    %esp,%ebp
  80243e:	57                   	push   %edi
  80243f:	56                   	push   %esi
  802440:	53                   	push   %ebx
  802441:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802447:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80244c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802452:	eb 2d                	jmp    802481 <devcons_write+0x46>
		m = n - tot;
  802454:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802457:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802459:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80245c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802461:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802464:	83 ec 04             	sub    $0x4,%esp
  802467:	53                   	push   %ebx
  802468:	03 45 0c             	add    0xc(%ebp),%eax
  80246b:	50                   	push   %eax
  80246c:	57                   	push   %edi
  80246d:	e8 11 e6 ff ff       	call   800a83 <memmove>
		sys_cputs(buf, m);
  802472:	83 c4 08             	add    $0x8,%esp
  802475:	53                   	push   %ebx
  802476:	57                   	push   %edi
  802477:	e8 33 e8 ff ff       	call   800caf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80247c:	01 de                	add    %ebx,%esi
  80247e:	83 c4 10             	add    $0x10,%esp
  802481:	89 f0                	mov    %esi,%eax
  802483:	3b 75 10             	cmp    0x10(%ebp),%esi
  802486:	72 cc                	jb     802454 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802488:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80248b:	5b                   	pop    %ebx
  80248c:	5e                   	pop    %esi
  80248d:	5f                   	pop    %edi
  80248e:	5d                   	pop    %ebp
  80248f:	c3                   	ret    

00802490 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802490:	55                   	push   %ebp
  802491:	89 e5                	mov    %esp,%ebp
  802493:	83 ec 08             	sub    $0x8,%esp
  802496:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80249b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80249f:	74 2a                	je     8024cb <devcons_read+0x3b>
  8024a1:	eb 05                	jmp    8024a8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8024a3:	e8 a4 e8 ff ff       	call   800d4c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8024a8:	e8 20 e8 ff ff       	call   800ccd <sys_cgetc>
  8024ad:	85 c0                	test   %eax,%eax
  8024af:	74 f2                	je     8024a3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8024b1:	85 c0                	test   %eax,%eax
  8024b3:	78 16                	js     8024cb <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8024b5:	83 f8 04             	cmp    $0x4,%eax
  8024b8:	74 0c                	je     8024c6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8024ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024bd:	88 02                	mov    %al,(%edx)
	return 1;
  8024bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8024c4:	eb 05                	jmp    8024cb <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8024c6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8024cb:	c9                   	leave  
  8024cc:	c3                   	ret    

008024cd <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8024cd:	55                   	push   %ebp
  8024ce:	89 e5                	mov    %esp,%ebp
  8024d0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8024d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8024d6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8024d9:	6a 01                	push   $0x1
  8024db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024de:	50                   	push   %eax
  8024df:	e8 cb e7 ff ff       	call   800caf <sys_cputs>
}
  8024e4:	83 c4 10             	add    $0x10,%esp
  8024e7:	c9                   	leave  
  8024e8:	c3                   	ret    

008024e9 <getchar>:

int
getchar(void)
{
  8024e9:	55                   	push   %ebp
  8024ea:	89 e5                	mov    %esp,%ebp
  8024ec:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8024ef:	6a 01                	push   $0x1
  8024f1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024f4:	50                   	push   %eax
  8024f5:	6a 00                	push   $0x0
  8024f7:	e8 44 f0 ff ff       	call   801540 <read>
	if (r < 0)
  8024fc:	83 c4 10             	add    $0x10,%esp
  8024ff:	85 c0                	test   %eax,%eax
  802501:	78 0f                	js     802512 <getchar+0x29>
		return r;
	if (r < 1)
  802503:	85 c0                	test   %eax,%eax
  802505:	7e 06                	jle    80250d <getchar+0x24>
		return -E_EOF;
	return c;
  802507:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80250b:	eb 05                	jmp    802512 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80250d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802512:	c9                   	leave  
  802513:	c3                   	ret    

00802514 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802514:	55                   	push   %ebp
  802515:	89 e5                	mov    %esp,%ebp
  802517:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80251a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80251d:	50                   	push   %eax
  80251e:	ff 75 08             	pushl  0x8(%ebp)
  802521:	e8 b4 ed ff ff       	call   8012da <fd_lookup>
  802526:	83 c4 10             	add    $0x10,%esp
  802529:	85 c0                	test   %eax,%eax
  80252b:	78 11                	js     80253e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80252d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802530:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802536:	39 10                	cmp    %edx,(%eax)
  802538:	0f 94 c0             	sete   %al
  80253b:	0f b6 c0             	movzbl %al,%eax
}
  80253e:	c9                   	leave  
  80253f:	c3                   	ret    

00802540 <opencons>:

int
opencons(void)
{
  802540:	55                   	push   %ebp
  802541:	89 e5                	mov    %esp,%ebp
  802543:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802546:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802549:	50                   	push   %eax
  80254a:	e8 3c ed ff ff       	call   80128b <fd_alloc>
  80254f:	83 c4 10             	add    $0x10,%esp
		return r;
  802552:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802554:	85 c0                	test   %eax,%eax
  802556:	78 3e                	js     802596 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802558:	83 ec 04             	sub    $0x4,%esp
  80255b:	68 07 04 00 00       	push   $0x407
  802560:	ff 75 f4             	pushl  -0xc(%ebp)
  802563:	6a 00                	push   $0x0
  802565:	e8 01 e8 ff ff       	call   800d6b <sys_page_alloc>
  80256a:	83 c4 10             	add    $0x10,%esp
		return r;
  80256d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80256f:	85 c0                	test   %eax,%eax
  802571:	78 23                	js     802596 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802573:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802579:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80257c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80257e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802581:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802588:	83 ec 0c             	sub    $0xc,%esp
  80258b:	50                   	push   %eax
  80258c:	e8 d3 ec ff ff       	call   801264 <fd2num>
  802591:	89 c2                	mov    %eax,%edx
  802593:	83 c4 10             	add    $0x10,%esp
}
  802596:	89 d0                	mov    %edx,%eax
  802598:	c9                   	leave  
  802599:	c3                   	ret    

0080259a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80259a:	55                   	push   %ebp
  80259b:	89 e5                	mov    %esp,%ebp
  80259d:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  8025a0:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8025a7:	75 52                	jne    8025fb <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  8025a9:	83 ec 04             	sub    $0x4,%esp
  8025ac:	6a 07                	push   $0x7
  8025ae:	68 00 f0 bf ee       	push   $0xeebff000
  8025b3:	6a 00                	push   $0x0
  8025b5:	e8 b1 e7 ff ff       	call   800d6b <sys_page_alloc>
  8025ba:	83 c4 10             	add    $0x10,%esp
  8025bd:	85 c0                	test   %eax,%eax
  8025bf:	79 12                	jns    8025d3 <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  8025c1:	50                   	push   %eax
  8025c2:	68 0c 2a 80 00       	push   $0x802a0c
  8025c7:	6a 23                	push   $0x23
  8025c9:	68 73 30 80 00       	push   $0x803073
  8025ce:	e8 11 dc ff ff       	call   8001e4 <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  8025d3:	83 ec 08             	sub    $0x8,%esp
  8025d6:	68 05 26 80 00       	push   $0x802605
  8025db:	6a 00                	push   $0x0
  8025dd:	e8 d4 e8 ff ff       	call   800eb6 <sys_env_set_pgfault_upcall>
  8025e2:	83 c4 10             	add    $0x10,%esp
  8025e5:	85 c0                	test   %eax,%eax
  8025e7:	79 12                	jns    8025fb <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  8025e9:	50                   	push   %eax
  8025ea:	68 90 2e 80 00       	push   $0x802e90
  8025ef:	6a 26                	push   $0x26
  8025f1:	68 73 30 80 00       	push   $0x803073
  8025f6:	e8 e9 db ff ff       	call   8001e4 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8025fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8025fe:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802603:	c9                   	leave  
  802604:	c3                   	ret    

00802605 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802605:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802606:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80260b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80260d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  802610:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  802614:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  802619:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  80261d:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80261f:	83 c4 08             	add    $0x8,%esp
	popal 
  802622:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802623:	83 c4 04             	add    $0x4,%esp
	popfl
  802626:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802627:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802628:	c3                   	ret    

00802629 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802629:	55                   	push   %ebp
  80262a:	89 e5                	mov    %esp,%ebp
  80262c:	56                   	push   %esi
  80262d:	53                   	push   %ebx
  80262e:	8b 75 08             	mov    0x8(%ebp),%esi
  802631:	8b 45 0c             	mov    0xc(%ebp),%eax
  802634:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  802637:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802639:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80263e:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  802641:	83 ec 0c             	sub    $0xc,%esp
  802644:	50                   	push   %eax
  802645:	e8 d1 e8 ff ff       	call   800f1b <sys_ipc_recv>
  80264a:	83 c4 10             	add    $0x10,%esp
  80264d:	85 c0                	test   %eax,%eax
  80264f:	79 16                	jns    802667 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  802651:	85 f6                	test   %esi,%esi
  802653:	74 06                	je     80265b <ipc_recv+0x32>
			*from_env_store = 0;
  802655:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  80265b:	85 db                	test   %ebx,%ebx
  80265d:	74 2c                	je     80268b <ipc_recv+0x62>
			*perm_store = 0;
  80265f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802665:	eb 24                	jmp    80268b <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  802667:	85 f6                	test   %esi,%esi
  802669:	74 0a                	je     802675 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  80266b:	a1 08 50 80 00       	mov    0x805008,%eax
  802670:	8b 40 74             	mov    0x74(%eax),%eax
  802673:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  802675:	85 db                	test   %ebx,%ebx
  802677:	74 0a                	je     802683 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  802679:	a1 08 50 80 00       	mov    0x805008,%eax
  80267e:	8b 40 78             	mov    0x78(%eax),%eax
  802681:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  802683:	a1 08 50 80 00       	mov    0x805008,%eax
  802688:	8b 40 70             	mov    0x70(%eax),%eax
}
  80268b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80268e:	5b                   	pop    %ebx
  80268f:	5e                   	pop    %esi
  802690:	5d                   	pop    %ebp
  802691:	c3                   	ret    

00802692 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802692:	55                   	push   %ebp
  802693:	89 e5                	mov    %esp,%ebp
  802695:	57                   	push   %edi
  802696:	56                   	push   %esi
  802697:	53                   	push   %ebx
  802698:	83 ec 0c             	sub    $0xc,%esp
  80269b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80269e:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8026a4:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8026a6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8026ab:	0f 44 d8             	cmove  %eax,%ebx
  8026ae:	eb 1e                	jmp    8026ce <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  8026b0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026b3:	74 14                	je     8026c9 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  8026b5:	83 ec 04             	sub    $0x4,%esp
  8026b8:	68 84 30 80 00       	push   $0x803084
  8026bd:	6a 44                	push   $0x44
  8026bf:	68 b0 30 80 00       	push   $0x8030b0
  8026c4:	e8 1b db ff ff       	call   8001e4 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  8026c9:	e8 7e e6 ff ff       	call   800d4c <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8026ce:	ff 75 14             	pushl  0x14(%ebp)
  8026d1:	53                   	push   %ebx
  8026d2:	56                   	push   %esi
  8026d3:	57                   	push   %edi
  8026d4:	e8 1f e8 ff ff       	call   800ef8 <sys_ipc_try_send>
  8026d9:	83 c4 10             	add    $0x10,%esp
  8026dc:	85 c0                	test   %eax,%eax
  8026de:	78 d0                	js     8026b0 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  8026e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026e3:	5b                   	pop    %ebx
  8026e4:	5e                   	pop    %esi
  8026e5:	5f                   	pop    %edi
  8026e6:	5d                   	pop    %ebp
  8026e7:	c3                   	ret    

008026e8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026e8:	55                   	push   %ebp
  8026e9:	89 e5                	mov    %esp,%ebp
  8026eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8026ee:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8026f3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8026f6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026fc:	8b 52 50             	mov    0x50(%edx),%edx
  8026ff:	39 ca                	cmp    %ecx,%edx
  802701:	75 0d                	jne    802710 <ipc_find_env+0x28>
			return envs[i].env_id;
  802703:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802706:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80270b:	8b 40 48             	mov    0x48(%eax),%eax
  80270e:	eb 0f                	jmp    80271f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802710:	83 c0 01             	add    $0x1,%eax
  802713:	3d 00 04 00 00       	cmp    $0x400,%eax
  802718:	75 d9                	jne    8026f3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80271a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80271f:	5d                   	pop    %ebp
  802720:	c3                   	ret    

00802721 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802721:	55                   	push   %ebp
  802722:	89 e5                	mov    %esp,%ebp
  802724:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802727:	89 d0                	mov    %edx,%eax
  802729:	c1 e8 16             	shr    $0x16,%eax
  80272c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802733:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802738:	f6 c1 01             	test   $0x1,%cl
  80273b:	74 1d                	je     80275a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80273d:	c1 ea 0c             	shr    $0xc,%edx
  802740:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802747:	f6 c2 01             	test   $0x1,%dl
  80274a:	74 0e                	je     80275a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80274c:	c1 ea 0c             	shr    $0xc,%edx
  80274f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802756:	ef 
  802757:	0f b7 c0             	movzwl %ax,%eax
}
  80275a:	5d                   	pop    %ebp
  80275b:	c3                   	ret    
  80275c:	66 90                	xchg   %ax,%ax
  80275e:	66 90                	xchg   %ax,%ax

00802760 <__udivdi3>:
  802760:	55                   	push   %ebp
  802761:	57                   	push   %edi
  802762:	56                   	push   %esi
  802763:	53                   	push   %ebx
  802764:	83 ec 1c             	sub    $0x1c,%esp
  802767:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80276b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80276f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802773:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802777:	85 f6                	test   %esi,%esi
  802779:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80277d:	89 ca                	mov    %ecx,%edx
  80277f:	89 f8                	mov    %edi,%eax
  802781:	75 3d                	jne    8027c0 <__udivdi3+0x60>
  802783:	39 cf                	cmp    %ecx,%edi
  802785:	0f 87 c5 00 00 00    	ja     802850 <__udivdi3+0xf0>
  80278b:	85 ff                	test   %edi,%edi
  80278d:	89 fd                	mov    %edi,%ebp
  80278f:	75 0b                	jne    80279c <__udivdi3+0x3c>
  802791:	b8 01 00 00 00       	mov    $0x1,%eax
  802796:	31 d2                	xor    %edx,%edx
  802798:	f7 f7                	div    %edi
  80279a:	89 c5                	mov    %eax,%ebp
  80279c:	89 c8                	mov    %ecx,%eax
  80279e:	31 d2                	xor    %edx,%edx
  8027a0:	f7 f5                	div    %ebp
  8027a2:	89 c1                	mov    %eax,%ecx
  8027a4:	89 d8                	mov    %ebx,%eax
  8027a6:	89 cf                	mov    %ecx,%edi
  8027a8:	f7 f5                	div    %ebp
  8027aa:	89 c3                	mov    %eax,%ebx
  8027ac:	89 d8                	mov    %ebx,%eax
  8027ae:	89 fa                	mov    %edi,%edx
  8027b0:	83 c4 1c             	add    $0x1c,%esp
  8027b3:	5b                   	pop    %ebx
  8027b4:	5e                   	pop    %esi
  8027b5:	5f                   	pop    %edi
  8027b6:	5d                   	pop    %ebp
  8027b7:	c3                   	ret    
  8027b8:	90                   	nop
  8027b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027c0:	39 ce                	cmp    %ecx,%esi
  8027c2:	77 74                	ja     802838 <__udivdi3+0xd8>
  8027c4:	0f bd fe             	bsr    %esi,%edi
  8027c7:	83 f7 1f             	xor    $0x1f,%edi
  8027ca:	0f 84 98 00 00 00    	je     802868 <__udivdi3+0x108>
  8027d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8027d5:	89 f9                	mov    %edi,%ecx
  8027d7:	89 c5                	mov    %eax,%ebp
  8027d9:	29 fb                	sub    %edi,%ebx
  8027db:	d3 e6                	shl    %cl,%esi
  8027dd:	89 d9                	mov    %ebx,%ecx
  8027df:	d3 ed                	shr    %cl,%ebp
  8027e1:	89 f9                	mov    %edi,%ecx
  8027e3:	d3 e0                	shl    %cl,%eax
  8027e5:	09 ee                	or     %ebp,%esi
  8027e7:	89 d9                	mov    %ebx,%ecx
  8027e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027ed:	89 d5                	mov    %edx,%ebp
  8027ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027f3:	d3 ed                	shr    %cl,%ebp
  8027f5:	89 f9                	mov    %edi,%ecx
  8027f7:	d3 e2                	shl    %cl,%edx
  8027f9:	89 d9                	mov    %ebx,%ecx
  8027fb:	d3 e8                	shr    %cl,%eax
  8027fd:	09 c2                	or     %eax,%edx
  8027ff:	89 d0                	mov    %edx,%eax
  802801:	89 ea                	mov    %ebp,%edx
  802803:	f7 f6                	div    %esi
  802805:	89 d5                	mov    %edx,%ebp
  802807:	89 c3                	mov    %eax,%ebx
  802809:	f7 64 24 0c          	mull   0xc(%esp)
  80280d:	39 d5                	cmp    %edx,%ebp
  80280f:	72 10                	jb     802821 <__udivdi3+0xc1>
  802811:	8b 74 24 08          	mov    0x8(%esp),%esi
  802815:	89 f9                	mov    %edi,%ecx
  802817:	d3 e6                	shl    %cl,%esi
  802819:	39 c6                	cmp    %eax,%esi
  80281b:	73 07                	jae    802824 <__udivdi3+0xc4>
  80281d:	39 d5                	cmp    %edx,%ebp
  80281f:	75 03                	jne    802824 <__udivdi3+0xc4>
  802821:	83 eb 01             	sub    $0x1,%ebx
  802824:	31 ff                	xor    %edi,%edi
  802826:	89 d8                	mov    %ebx,%eax
  802828:	89 fa                	mov    %edi,%edx
  80282a:	83 c4 1c             	add    $0x1c,%esp
  80282d:	5b                   	pop    %ebx
  80282e:	5e                   	pop    %esi
  80282f:	5f                   	pop    %edi
  802830:	5d                   	pop    %ebp
  802831:	c3                   	ret    
  802832:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802838:	31 ff                	xor    %edi,%edi
  80283a:	31 db                	xor    %ebx,%ebx
  80283c:	89 d8                	mov    %ebx,%eax
  80283e:	89 fa                	mov    %edi,%edx
  802840:	83 c4 1c             	add    $0x1c,%esp
  802843:	5b                   	pop    %ebx
  802844:	5e                   	pop    %esi
  802845:	5f                   	pop    %edi
  802846:	5d                   	pop    %ebp
  802847:	c3                   	ret    
  802848:	90                   	nop
  802849:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802850:	89 d8                	mov    %ebx,%eax
  802852:	f7 f7                	div    %edi
  802854:	31 ff                	xor    %edi,%edi
  802856:	89 c3                	mov    %eax,%ebx
  802858:	89 d8                	mov    %ebx,%eax
  80285a:	89 fa                	mov    %edi,%edx
  80285c:	83 c4 1c             	add    $0x1c,%esp
  80285f:	5b                   	pop    %ebx
  802860:	5e                   	pop    %esi
  802861:	5f                   	pop    %edi
  802862:	5d                   	pop    %ebp
  802863:	c3                   	ret    
  802864:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802868:	39 ce                	cmp    %ecx,%esi
  80286a:	72 0c                	jb     802878 <__udivdi3+0x118>
  80286c:	31 db                	xor    %ebx,%ebx
  80286e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802872:	0f 87 34 ff ff ff    	ja     8027ac <__udivdi3+0x4c>
  802878:	bb 01 00 00 00       	mov    $0x1,%ebx
  80287d:	e9 2a ff ff ff       	jmp    8027ac <__udivdi3+0x4c>
  802882:	66 90                	xchg   %ax,%ax
  802884:	66 90                	xchg   %ax,%ax
  802886:	66 90                	xchg   %ax,%ax
  802888:	66 90                	xchg   %ax,%ax
  80288a:	66 90                	xchg   %ax,%ax
  80288c:	66 90                	xchg   %ax,%ax
  80288e:	66 90                	xchg   %ax,%ax

00802890 <__umoddi3>:
  802890:	55                   	push   %ebp
  802891:	57                   	push   %edi
  802892:	56                   	push   %esi
  802893:	53                   	push   %ebx
  802894:	83 ec 1c             	sub    $0x1c,%esp
  802897:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80289b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80289f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8028a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028a7:	85 d2                	test   %edx,%edx
  8028a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8028ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028b1:	89 f3                	mov    %esi,%ebx
  8028b3:	89 3c 24             	mov    %edi,(%esp)
  8028b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028ba:	75 1c                	jne    8028d8 <__umoddi3+0x48>
  8028bc:	39 f7                	cmp    %esi,%edi
  8028be:	76 50                	jbe    802910 <__umoddi3+0x80>
  8028c0:	89 c8                	mov    %ecx,%eax
  8028c2:	89 f2                	mov    %esi,%edx
  8028c4:	f7 f7                	div    %edi
  8028c6:	89 d0                	mov    %edx,%eax
  8028c8:	31 d2                	xor    %edx,%edx
  8028ca:	83 c4 1c             	add    $0x1c,%esp
  8028cd:	5b                   	pop    %ebx
  8028ce:	5e                   	pop    %esi
  8028cf:	5f                   	pop    %edi
  8028d0:	5d                   	pop    %ebp
  8028d1:	c3                   	ret    
  8028d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028d8:	39 f2                	cmp    %esi,%edx
  8028da:	89 d0                	mov    %edx,%eax
  8028dc:	77 52                	ja     802930 <__umoddi3+0xa0>
  8028de:	0f bd ea             	bsr    %edx,%ebp
  8028e1:	83 f5 1f             	xor    $0x1f,%ebp
  8028e4:	75 5a                	jne    802940 <__umoddi3+0xb0>
  8028e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8028ea:	0f 82 e0 00 00 00    	jb     8029d0 <__umoddi3+0x140>
  8028f0:	39 0c 24             	cmp    %ecx,(%esp)
  8028f3:	0f 86 d7 00 00 00    	jbe    8029d0 <__umoddi3+0x140>
  8028f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802901:	83 c4 1c             	add    $0x1c,%esp
  802904:	5b                   	pop    %ebx
  802905:	5e                   	pop    %esi
  802906:	5f                   	pop    %edi
  802907:	5d                   	pop    %ebp
  802908:	c3                   	ret    
  802909:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802910:	85 ff                	test   %edi,%edi
  802912:	89 fd                	mov    %edi,%ebp
  802914:	75 0b                	jne    802921 <__umoddi3+0x91>
  802916:	b8 01 00 00 00       	mov    $0x1,%eax
  80291b:	31 d2                	xor    %edx,%edx
  80291d:	f7 f7                	div    %edi
  80291f:	89 c5                	mov    %eax,%ebp
  802921:	89 f0                	mov    %esi,%eax
  802923:	31 d2                	xor    %edx,%edx
  802925:	f7 f5                	div    %ebp
  802927:	89 c8                	mov    %ecx,%eax
  802929:	f7 f5                	div    %ebp
  80292b:	89 d0                	mov    %edx,%eax
  80292d:	eb 99                	jmp    8028c8 <__umoddi3+0x38>
  80292f:	90                   	nop
  802930:	89 c8                	mov    %ecx,%eax
  802932:	89 f2                	mov    %esi,%edx
  802934:	83 c4 1c             	add    $0x1c,%esp
  802937:	5b                   	pop    %ebx
  802938:	5e                   	pop    %esi
  802939:	5f                   	pop    %edi
  80293a:	5d                   	pop    %ebp
  80293b:	c3                   	ret    
  80293c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802940:	8b 34 24             	mov    (%esp),%esi
  802943:	bf 20 00 00 00       	mov    $0x20,%edi
  802948:	89 e9                	mov    %ebp,%ecx
  80294a:	29 ef                	sub    %ebp,%edi
  80294c:	d3 e0                	shl    %cl,%eax
  80294e:	89 f9                	mov    %edi,%ecx
  802950:	89 f2                	mov    %esi,%edx
  802952:	d3 ea                	shr    %cl,%edx
  802954:	89 e9                	mov    %ebp,%ecx
  802956:	09 c2                	or     %eax,%edx
  802958:	89 d8                	mov    %ebx,%eax
  80295a:	89 14 24             	mov    %edx,(%esp)
  80295d:	89 f2                	mov    %esi,%edx
  80295f:	d3 e2                	shl    %cl,%edx
  802961:	89 f9                	mov    %edi,%ecx
  802963:	89 54 24 04          	mov    %edx,0x4(%esp)
  802967:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80296b:	d3 e8                	shr    %cl,%eax
  80296d:	89 e9                	mov    %ebp,%ecx
  80296f:	89 c6                	mov    %eax,%esi
  802971:	d3 e3                	shl    %cl,%ebx
  802973:	89 f9                	mov    %edi,%ecx
  802975:	89 d0                	mov    %edx,%eax
  802977:	d3 e8                	shr    %cl,%eax
  802979:	89 e9                	mov    %ebp,%ecx
  80297b:	09 d8                	or     %ebx,%eax
  80297d:	89 d3                	mov    %edx,%ebx
  80297f:	89 f2                	mov    %esi,%edx
  802981:	f7 34 24             	divl   (%esp)
  802984:	89 d6                	mov    %edx,%esi
  802986:	d3 e3                	shl    %cl,%ebx
  802988:	f7 64 24 04          	mull   0x4(%esp)
  80298c:	39 d6                	cmp    %edx,%esi
  80298e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802992:	89 d1                	mov    %edx,%ecx
  802994:	89 c3                	mov    %eax,%ebx
  802996:	72 08                	jb     8029a0 <__umoddi3+0x110>
  802998:	75 11                	jne    8029ab <__umoddi3+0x11b>
  80299a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80299e:	73 0b                	jae    8029ab <__umoddi3+0x11b>
  8029a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8029a4:	1b 14 24             	sbb    (%esp),%edx
  8029a7:	89 d1                	mov    %edx,%ecx
  8029a9:	89 c3                	mov    %eax,%ebx
  8029ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8029af:	29 da                	sub    %ebx,%edx
  8029b1:	19 ce                	sbb    %ecx,%esi
  8029b3:	89 f9                	mov    %edi,%ecx
  8029b5:	89 f0                	mov    %esi,%eax
  8029b7:	d3 e0                	shl    %cl,%eax
  8029b9:	89 e9                	mov    %ebp,%ecx
  8029bb:	d3 ea                	shr    %cl,%edx
  8029bd:	89 e9                	mov    %ebp,%ecx
  8029bf:	d3 ee                	shr    %cl,%esi
  8029c1:	09 d0                	or     %edx,%eax
  8029c3:	89 f2                	mov    %esi,%edx
  8029c5:	83 c4 1c             	add    $0x1c,%esp
  8029c8:	5b                   	pop    %ebx
  8029c9:	5e                   	pop    %esi
  8029ca:	5f                   	pop    %edi
  8029cb:	5d                   	pop    %ebp
  8029cc:	c3                   	ret    
  8029cd:	8d 76 00             	lea    0x0(%esi),%esi
  8029d0:	29 f9                	sub    %edi,%ecx
  8029d2:	19 d6                	sbb    %edx,%esi
  8029d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029dc:	e9 18 ff ff ff       	jmp    8028f9 <__umoddi3+0x69>
