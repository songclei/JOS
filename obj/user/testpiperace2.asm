
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 a5 01 00 00       	call   8001d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 40 24 80 00       	push   $0x802440
  800041:	e8 c9 02 00 00       	call   80030f <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 8e 1c 00 00       	call   801cdf <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 8e 24 80 00       	push   $0x80248e
  80005e:	6a 0d                	push   $0xd
  800060:	68 97 24 80 00       	push   $0x802497
  800065:	e8 cc 01 00 00       	call   800236 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 15 10 00 00       	call   801084 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 be 28 80 00       	push   $0x8028be
  80007b:	6a 0f                	push   $0xf
  80007d:	68 97 24 80 00       	push   $0x802497
  800082:	e8 af 01 00 00       	call   800236 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 c0 13 00 00       	call   801456 <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 67 66 66 66       	mov    $0x66666667,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ef                	imul   %edi
  8000a7:	c1 fa 02             	sar    $0x2,%edx
  8000aa:	89 d8                	mov    %ebx,%eax
  8000ac:	c1 f8 1f             	sar    $0x1f,%eax
  8000af:	29 c2                	sub    %eax,%edx
  8000b1:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000b4:	01 c0                	add    %eax,%eax
  8000b6:	39 c3                	cmp    %eax,%ebx
  8000b8:	75 11                	jne    8000cb <umain+0x98>
				cprintf("%d.", i);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	68 ac 24 80 00       	push   $0x8024ac
  8000c3:	e8 47 02 00 00       	call   80030f <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 ce 13 00 00       	call   8014a6 <dup>
			sys_yield();
  8000d8:	e8 c1 0c 00 00       	call   800d9e <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 6d 13 00 00       	call   801456 <close>
			sys_yield();
  8000e9:	e8 b0 0c 00 00       	call   800d9e <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000ee:	83 c3 01             	add    $0x1,%ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000fa:	75 a7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000fc:	e8 1b 01 00 00       	call   80021c <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 10 1d 00 00       	call   801e32 <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 b0 24 80 00       	push   $0x8024b0
  800131:	e8 d9 01 00 00       	call   80030f <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 00 0c 00 00       	call   800d3e <sys_env_destroy>
			exit();
  80013e:	e8 d9 00 00 00       	call   80021c <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800149:	29 fb                	sub    %edi,%ebx
  80014b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800151:	8b 43 54             	mov    0x54(%ebx),%eax
  800154:	83 f8 02             	cmp    $0x2,%eax
  800157:	74 be                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	68 cc 24 80 00       	push   $0x8024cc
  800161:	e8 a9 01 00 00       	call   80030f <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 c1 1c 00 00       	call   801e32 <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 64 24 80 00       	push   $0x802464
  800180:	6a 40                	push   $0x40
  800182:	68 97 24 80 00       	push   $0x802497
  800187:	e8 aa 00 00 00       	call   800236 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 91 11 00 00       	call   80132c <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 e2 24 80 00       	push   $0x8024e2
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 97 24 80 00       	push   $0x802497
  8001af:	e8 82 00 00 00       	call   800236 <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 07 11 00 00       	call   8012c6 <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 fa 24 80 00 	movl   $0x8024fa,(%esp)
  8001c6:	e8 44 01 00 00       	call   80030f <cprintf>
}
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e1:	e8 99 0b 00 00       	call   800d7f <sys_getenvid>
  8001e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f3:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7e 07                	jle    800203 <libmain+0x2d>
		binaryname = argv[0];
  8001fc:	8b 06                	mov    (%esi),%eax
  8001fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	e8 26 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020d:	e8 0a 00 00 00       	call   80021c <exit>
}
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800222:	e8 5a 12 00 00       	call   801481 <close_all>
	sys_env_destroy(0);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	6a 00                	push   $0x0
  80022c:	e8 0d 0b 00 00       	call   800d3e <sys_env_destroy>
}
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800244:	e8 36 0b 00 00       	call   800d7f <sys_getenvid>
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	56                   	push   %esi
  800253:	50                   	push   %eax
  800254:	68 18 25 80 00       	push   $0x802518
  800259:	e8 b1 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	e8 54 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 25 2a 80 00 	movl   $0x802a25,(%esp)
  800271:	e8 99 00 00 00       	call   80030f <cprintf>
  800276:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800279:	cc                   	int3   
  80027a:	eb fd                	jmp    800279 <_panic+0x43>

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 13                	mov    (%ebx),%edx
  800288:	8d 42 01             	lea    0x1(%edx),%eax
  80028b:	89 03                	mov    %eax,(%ebx)
  80028d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800290:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800294:	3d ff 00 00 00       	cmp    $0xff,%eax
  800299:	75 1a                	jne    8002b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	68 ff 00 00 00       	push   $0xff
  8002a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 55 0a 00 00       	call   800d01 <sys_cputs>
		b->idx = 0;
  8002ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ce:	00 00 00 
	b.cnt = 0;
  8002d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e7:	50                   	push   %eax
  8002e8:	68 7c 02 80 00       	push   $0x80027c
  8002ed:	e8 54 01 00 00       	call   800446 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f2:	83 c4 08             	add    $0x8,%esp
  8002f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800301:	50                   	push   %eax
  800302:	e8 fa 09 00 00       	call   800d01 <sys_cputs>

	return b.cnt;
}
  800307:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800315:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800318:	50                   	push   %eax
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 9d ff ff ff       	call   8002be <vcprintf>
	va_end(ap);

	return cnt;
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 1c             	sub    $0x1c,%esp
  80032c:	89 c7                	mov    %eax,%edi
  80032e:	89 d6                	mov    %edx,%esi
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 55 0c             	mov    0xc(%ebp),%edx
  800336:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800339:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80033f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800344:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800347:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034a:	39 d3                	cmp    %edx,%ebx
  80034c:	72 05                	jb     800353 <printnum+0x30>
  80034e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800351:	77 45                	ja     800398 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	ff 75 18             	pushl  0x18(%ebp)
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035f:	53                   	push   %ebx
  800360:	ff 75 10             	pushl  0x10(%ebp)
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 39 1e 00 00       	call   8021b0 <__udivdi3>
  800377:	83 c4 18             	add    $0x18,%esp
  80037a:	52                   	push   %edx
  80037b:	50                   	push   %eax
  80037c:	89 f2                	mov    %esi,%edx
  80037e:	89 f8                	mov    %edi,%eax
  800380:	e8 9e ff ff ff       	call   800323 <printnum>
  800385:	83 c4 20             	add    $0x20,%esp
  800388:	eb 18                	jmp    8003a2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	56                   	push   %esi
  80038e:	ff 75 18             	pushl  0x18(%ebp)
  800391:	ff d7                	call   *%edi
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb 03                	jmp    80039b <printnum+0x78>
  800398:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039b:	83 eb 01             	sub    $0x1,%ebx
  80039e:	85 db                	test   %ebx,%ebx
  8003a0:	7f e8                	jg     80038a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	56                   	push   %esi
  8003a6:	83 ec 04             	sub    $0x4,%esp
  8003a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8003af:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b5:	e8 26 1f 00 00       	call   8022e0 <__umoddi3>
  8003ba:	83 c4 14             	add    $0x14,%esp
  8003bd:	0f be 80 3b 25 80 00 	movsbl 0x80253b(%eax),%eax
  8003c4:	50                   	push   %eax
  8003c5:	ff d7                	call   *%edi
}
  8003c7:	83 c4 10             	add    $0x10,%esp
  8003ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003cd:	5b                   	pop    %ebx
  8003ce:	5e                   	pop    %esi
  8003cf:	5f                   	pop    %edi
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d5:	83 fa 01             	cmp    $0x1,%edx
  8003d8:	7e 0e                	jle    8003e8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003df:	89 08                	mov    %ecx,(%eax)
  8003e1:	8b 02                	mov    (%edx),%eax
  8003e3:	8b 52 04             	mov    0x4(%edx),%edx
  8003e6:	eb 22                	jmp    80040a <getuint+0x38>
	else if (lflag)
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	74 10                	je     8003fc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f1:	89 08                	mov    %ecx,(%eax)
  8003f3:	8b 02                	mov    (%edx),%eax
  8003f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fa:	eb 0e                	jmp    80040a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003fc:	8b 10                	mov    (%eax),%edx
  8003fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800401:	89 08                	mov    %ecx,(%eax)
  800403:	8b 02                	mov    (%edx),%eax
  800405:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800412:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800416:	8b 10                	mov    (%eax),%edx
  800418:	3b 50 04             	cmp    0x4(%eax),%edx
  80041b:	73 0a                	jae    800427 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800420:	89 08                	mov    %ecx,(%eax)
  800422:	8b 45 08             	mov    0x8(%ebp),%eax
  800425:	88 02                	mov    %al,(%edx)
}
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80042f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800432:	50                   	push   %eax
  800433:	ff 75 10             	pushl  0x10(%ebp)
  800436:	ff 75 0c             	pushl  0xc(%ebp)
  800439:	ff 75 08             	pushl  0x8(%ebp)
  80043c:	e8 05 00 00 00       	call   800446 <vprintfmt>
	va_end(ap);
}
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	c9                   	leave  
  800445:	c3                   	ret    

00800446 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	57                   	push   %edi
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
  80044c:	83 ec 2c             	sub    $0x2c,%esp
  80044f:	8b 75 08             	mov    0x8(%ebp),%esi
  800452:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800455:	8b 7d 10             	mov    0x10(%ebp),%edi
  800458:	eb 12                	jmp    80046c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045a:	85 c0                	test   %eax,%eax
  80045c:	0f 84 38 04 00 00    	je     80089a <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	50                   	push   %eax
  800467:	ff d6                	call   *%esi
  800469:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046c:	83 c7 01             	add    $0x1,%edi
  80046f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800473:	83 f8 25             	cmp    $0x25,%eax
  800476:	75 e2                	jne    80045a <vprintfmt+0x14>
  800478:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80047c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800483:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80048a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800491:	ba 00 00 00 00       	mov    $0x0,%edx
  800496:	eb 07                	jmp    80049f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  80049b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8d 47 01             	lea    0x1(%edi),%eax
  8004a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a5:	0f b6 07             	movzbl (%edi),%eax
  8004a8:	0f b6 c8             	movzbl %al,%ecx
  8004ab:	83 e8 23             	sub    $0x23,%eax
  8004ae:	3c 55                	cmp    $0x55,%al
  8004b0:	0f 87 c9 03 00 00    	ja     80087f <vprintfmt+0x439>
  8004b6:	0f b6 c0             	movzbl %al,%eax
  8004b9:	ff 24 85 80 26 80 00 	jmp    *0x802680(,%eax,4)
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004c7:	eb d6                	jmp    80049f <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  8004c9:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  8004d0:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  8004d6:	eb 94                	jmp    80046c <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  8004d8:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  8004df:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  8004e5:	eb 85                	jmp    80046c <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  8004e7:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  8004ee:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  8004f4:	e9 73 ff ff ff       	jmp    80046c <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  8004f9:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  800500:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800503:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  800506:	e9 61 ff ff ff       	jmp    80046c <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  80050b:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800512:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  800518:	e9 4f ff ff ff       	jmp    80046c <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80051d:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800524:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80052a:	e9 3d ff ff ff       	jmp    80046c <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  80052f:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  800536:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80053c:	e9 2b ff ff ff       	jmp    80046c <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  800541:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  800548:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  80054e:	e9 19 ff ff ff       	jmp    80046c <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800553:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  80055a:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  800560:	e9 07 ff ff ff       	jmp    80046c <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  800565:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  80056c:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800572:	e9 f5 fe ff ff       	jmp    80046c <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800577:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057a:	b8 00 00 00 00       	mov    $0x0,%eax
  80057f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800582:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800585:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800589:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80058c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80058f:	83 fa 09             	cmp    $0x9,%edx
  800592:	77 3f                	ja     8005d3 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800594:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800597:	eb e9                	jmp    800582 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8d 48 04             	lea    0x4(%eax),%ecx
  80059f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005aa:	eb 2d                	jmp    8005d9 <vprintfmt+0x193>
  8005ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005af:	85 c0                	test   %eax,%eax
  8005b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b6:	0f 49 c8             	cmovns %eax,%ecx
  8005b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bf:	e9 db fe ff ff       	jmp    80049f <vprintfmt+0x59>
  8005c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005c7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ce:	e9 cc fe ff ff       	jmp    80049f <vprintfmt+0x59>
  8005d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005dd:	0f 89 bc fe ff ff    	jns    80049f <vprintfmt+0x59>
				width = precision, precision = -1;
  8005e3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005f0:	e9 aa fe ff ff       	jmp    80049f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005f5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005fb:	e9 9f fe ff ff       	jmp    80049f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	ff 30                	pushl  (%eax)
  80060f:	ff d6                	call   *%esi
			break;
  800611:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800614:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800617:	e9 50 fe ff ff       	jmp    80046c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 04             	lea    0x4(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)
  800625:	8b 00                	mov    (%eax),%eax
  800627:	99                   	cltd   
  800628:	31 d0                	xor    %edx,%eax
  80062a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80062c:	83 f8 0f             	cmp    $0xf,%eax
  80062f:	7f 0b                	jg     80063c <vprintfmt+0x1f6>
  800631:	8b 14 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%edx
  800638:	85 d2                	test   %edx,%edx
  80063a:	75 18                	jne    800654 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80063c:	50                   	push   %eax
  80063d:	68 53 25 80 00       	push   $0x802553
  800642:	53                   	push   %ebx
  800643:	56                   	push   %esi
  800644:	e8 e0 fd ff ff       	call   800429 <printfmt>
  800649:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80064f:	e9 18 fe ff ff       	jmp    80046c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800654:	52                   	push   %edx
  800655:	68 c5 29 80 00       	push   $0x8029c5
  80065a:	53                   	push   %ebx
  80065b:	56                   	push   %esi
  80065c:	e8 c8 fd ff ff       	call   800429 <printfmt>
  800661:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800667:	e9 00 fe ff ff       	jmp    80046c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 50 04             	lea    0x4(%eax),%edx
  800672:	89 55 14             	mov    %edx,0x14(%ebp)
  800675:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800677:	85 ff                	test   %edi,%edi
  800679:	b8 4c 25 80 00       	mov    $0x80254c,%eax
  80067e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800681:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800685:	0f 8e 94 00 00 00    	jle    80071f <vprintfmt+0x2d9>
  80068b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80068f:	0f 84 98 00 00 00    	je     80072d <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	ff 75 d0             	pushl  -0x30(%ebp)
  80069b:	57                   	push   %edi
  80069c:	e8 81 02 00 00       	call   800922 <strnlen>
  8006a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006a4:	29 c1                	sub    %eax,%ecx
  8006a6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006a9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ac:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006b6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b8:	eb 0f                	jmp    8006c9 <vprintfmt+0x283>
					putch(padc, putdat);
  8006ba:	83 ec 08             	sub    $0x8,%esp
  8006bd:	53                   	push   %ebx
  8006be:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c3:	83 ef 01             	sub    $0x1,%edi
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	85 ff                	test   %edi,%edi
  8006cb:	7f ed                	jg     8006ba <vprintfmt+0x274>
  8006cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006d0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006d3:	85 c9                	test   %ecx,%ecx
  8006d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006da:	0f 49 c1             	cmovns %ecx,%eax
  8006dd:	29 c1                	sub    %eax,%ecx
  8006df:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e8:	89 cb                	mov    %ecx,%ebx
  8006ea:	eb 4d                	jmp    800739 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006f0:	74 1b                	je     80070d <vprintfmt+0x2c7>
  8006f2:	0f be c0             	movsbl %al,%eax
  8006f5:	83 e8 20             	sub    $0x20,%eax
  8006f8:	83 f8 5e             	cmp    $0x5e,%eax
  8006fb:	76 10                	jbe    80070d <vprintfmt+0x2c7>
					putch('?', putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	ff 75 0c             	pushl  0xc(%ebp)
  800703:	6a 3f                	push   $0x3f
  800705:	ff 55 08             	call   *0x8(%ebp)
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	eb 0d                	jmp    80071a <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  80070d:	83 ec 08             	sub    $0x8,%esp
  800710:	ff 75 0c             	pushl  0xc(%ebp)
  800713:	52                   	push   %edx
  800714:	ff 55 08             	call   *0x8(%ebp)
  800717:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071a:	83 eb 01             	sub    $0x1,%ebx
  80071d:	eb 1a                	jmp    800739 <vprintfmt+0x2f3>
  80071f:	89 75 08             	mov    %esi,0x8(%ebp)
  800722:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800725:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800728:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80072b:	eb 0c                	jmp    800739 <vprintfmt+0x2f3>
  80072d:	89 75 08             	mov    %esi,0x8(%ebp)
  800730:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800733:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800736:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800739:	83 c7 01             	add    $0x1,%edi
  80073c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800740:	0f be d0             	movsbl %al,%edx
  800743:	85 d2                	test   %edx,%edx
  800745:	74 23                	je     80076a <vprintfmt+0x324>
  800747:	85 f6                	test   %esi,%esi
  800749:	78 a1                	js     8006ec <vprintfmt+0x2a6>
  80074b:	83 ee 01             	sub    $0x1,%esi
  80074e:	79 9c                	jns    8006ec <vprintfmt+0x2a6>
  800750:	89 df                	mov    %ebx,%edi
  800752:	8b 75 08             	mov    0x8(%ebp),%esi
  800755:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800758:	eb 18                	jmp    800772 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	53                   	push   %ebx
  80075e:	6a 20                	push   $0x20
  800760:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800762:	83 ef 01             	sub    $0x1,%edi
  800765:	83 c4 10             	add    $0x10,%esp
  800768:	eb 08                	jmp    800772 <vprintfmt+0x32c>
  80076a:	89 df                	mov    %ebx,%edi
  80076c:	8b 75 08             	mov    0x8(%ebp),%esi
  80076f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800772:	85 ff                	test   %edi,%edi
  800774:	7f e4                	jg     80075a <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800776:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800779:	e9 ee fc ff ff       	jmp    80046c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80077e:	83 fa 01             	cmp    $0x1,%edx
  800781:	7e 16                	jle    800799 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8d 50 08             	lea    0x8(%eax),%edx
  800789:	89 55 14             	mov    %edx,0x14(%ebp)
  80078c:	8b 50 04             	mov    0x4(%eax),%edx
  80078f:	8b 00                	mov    (%eax),%eax
  800791:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800794:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800797:	eb 32                	jmp    8007cb <vprintfmt+0x385>
	else if (lflag)
  800799:	85 d2                	test   %edx,%edx
  80079b:	74 18                	je     8007b5 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	8d 50 04             	lea    0x4(%eax),%edx
  8007a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a6:	8b 00                	mov    (%eax),%eax
  8007a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ab:	89 c1                	mov    %eax,%ecx
  8007ad:	c1 f9 1f             	sar    $0x1f,%ecx
  8007b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b3:	eb 16                	jmp    8007cb <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  8007b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b8:	8d 50 04             	lea    0x4(%eax),%edx
  8007bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007be:	8b 00                	mov    (%eax),%eax
  8007c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c3:	89 c1                	mov    %eax,%ecx
  8007c5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007d1:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007d6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007da:	79 6f                	jns    80084b <vprintfmt+0x405>
				putch('-', putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	53                   	push   %ebx
  8007e0:	6a 2d                	push   $0x2d
  8007e2:	ff d6                	call   *%esi
				num = -(long long) num;
  8007e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007ea:	f7 d8                	neg    %eax
  8007ec:	83 d2 00             	adc    $0x0,%edx
  8007ef:	f7 da                	neg    %edx
  8007f1:	83 c4 10             	add    $0x10,%esp
  8007f4:	eb 55                	jmp    80084b <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f9:	e8 d4 fb ff ff       	call   8003d2 <getuint>
			base = 10;
  8007fe:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800803:	eb 46                	jmp    80084b <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800805:	8d 45 14             	lea    0x14(%ebp),%eax
  800808:	e8 c5 fb ff ff       	call   8003d2 <getuint>
			base = 8;
  80080d:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800812:	eb 37                	jmp    80084b <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800814:	83 ec 08             	sub    $0x8,%esp
  800817:	53                   	push   %ebx
  800818:	6a 30                	push   $0x30
  80081a:	ff d6                	call   *%esi
			putch('x', putdat);
  80081c:	83 c4 08             	add    $0x8,%esp
  80081f:	53                   	push   %ebx
  800820:	6a 78                	push   $0x78
  800822:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8d 50 04             	lea    0x4(%eax),%edx
  80082a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80082d:	8b 00                	mov    (%eax),%eax
  80082f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800834:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800837:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80083c:	eb 0d                	jmp    80084b <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80083e:	8d 45 14             	lea    0x14(%ebp),%eax
  800841:	e8 8c fb ff ff       	call   8003d2 <getuint>
			base = 16;
  800846:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80084b:	83 ec 0c             	sub    $0xc,%esp
  80084e:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800852:	51                   	push   %ecx
  800853:	ff 75 e0             	pushl  -0x20(%ebp)
  800856:	57                   	push   %edi
  800857:	52                   	push   %edx
  800858:	50                   	push   %eax
  800859:	89 da                	mov    %ebx,%edx
  80085b:	89 f0                	mov    %esi,%eax
  80085d:	e8 c1 fa ff ff       	call   800323 <printnum>
			break;
  800862:	83 c4 20             	add    $0x20,%esp
  800865:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800868:	e9 ff fb ff ff       	jmp    80046c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80086d:	83 ec 08             	sub    $0x8,%esp
  800870:	53                   	push   %ebx
  800871:	51                   	push   %ecx
  800872:	ff d6                	call   *%esi
			break;
  800874:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800877:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80087a:	e9 ed fb ff ff       	jmp    80046c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80087f:	83 ec 08             	sub    $0x8,%esp
  800882:	53                   	push   %ebx
  800883:	6a 25                	push   $0x25
  800885:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800887:	83 c4 10             	add    $0x10,%esp
  80088a:	eb 03                	jmp    80088f <vprintfmt+0x449>
  80088c:	83 ef 01             	sub    $0x1,%edi
  80088f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800893:	75 f7                	jne    80088c <vprintfmt+0x446>
  800895:	e9 d2 fb ff ff       	jmp    80046c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80089a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80089d:	5b                   	pop    %ebx
  80089e:	5e                   	pop    %esi
  80089f:	5f                   	pop    %edi
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	83 ec 18             	sub    $0x18,%esp
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008b1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008bf:	85 c0                	test   %eax,%eax
  8008c1:	74 26                	je     8008e9 <vsnprintf+0x47>
  8008c3:	85 d2                	test   %edx,%edx
  8008c5:	7e 22                	jle    8008e9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c7:	ff 75 14             	pushl  0x14(%ebp)
  8008ca:	ff 75 10             	pushl  0x10(%ebp)
  8008cd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d0:	50                   	push   %eax
  8008d1:	68 0c 04 80 00       	push   $0x80040c
  8008d6:	e8 6b fb ff ff       	call   800446 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008db:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008de:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e4:	83 c4 10             	add    $0x10,%esp
  8008e7:	eb 05                	jmp    8008ee <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008ee:	c9                   	leave  
  8008ef:	c3                   	ret    

008008f0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f9:	50                   	push   %eax
  8008fa:	ff 75 10             	pushl  0x10(%ebp)
  8008fd:	ff 75 0c             	pushl  0xc(%ebp)
  800900:	ff 75 08             	pushl  0x8(%ebp)
  800903:	e8 9a ff ff ff       	call   8008a2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800908:	c9                   	leave  
  800909:	c3                   	ret    

0080090a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800910:	b8 00 00 00 00       	mov    $0x0,%eax
  800915:	eb 03                	jmp    80091a <strlen+0x10>
		n++;
  800917:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80091a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80091e:	75 f7                	jne    800917 <strlen+0xd>
		n++;
	return n;
}
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800928:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092b:	ba 00 00 00 00       	mov    $0x0,%edx
  800930:	eb 03                	jmp    800935 <strnlen+0x13>
		n++;
  800932:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800935:	39 c2                	cmp    %eax,%edx
  800937:	74 08                	je     800941 <strnlen+0x1f>
  800939:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80093d:	75 f3                	jne    800932 <strnlen+0x10>
  80093f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	53                   	push   %ebx
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80094d:	89 c2                	mov    %eax,%edx
  80094f:	83 c2 01             	add    $0x1,%edx
  800952:	83 c1 01             	add    $0x1,%ecx
  800955:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800959:	88 5a ff             	mov    %bl,-0x1(%edx)
  80095c:	84 db                	test   %bl,%bl
  80095e:	75 ef                	jne    80094f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800960:	5b                   	pop    %ebx
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	53                   	push   %ebx
  800967:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80096a:	53                   	push   %ebx
  80096b:	e8 9a ff ff ff       	call   80090a <strlen>
  800970:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800973:	ff 75 0c             	pushl  0xc(%ebp)
  800976:	01 d8                	add    %ebx,%eax
  800978:	50                   	push   %eax
  800979:	e8 c5 ff ff ff       	call   800943 <strcpy>
	return dst;
}
  80097e:	89 d8                	mov    %ebx,%eax
  800980:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800983:	c9                   	leave  
  800984:	c3                   	ret    

00800985 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	56                   	push   %esi
  800989:	53                   	push   %ebx
  80098a:	8b 75 08             	mov    0x8(%ebp),%esi
  80098d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800990:	89 f3                	mov    %esi,%ebx
  800992:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800995:	89 f2                	mov    %esi,%edx
  800997:	eb 0f                	jmp    8009a8 <strncpy+0x23>
		*dst++ = *src;
  800999:	83 c2 01             	add    $0x1,%edx
  80099c:	0f b6 01             	movzbl (%ecx),%eax
  80099f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a2:	80 39 01             	cmpb   $0x1,(%ecx)
  8009a5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a8:	39 da                	cmp    %ebx,%edx
  8009aa:	75 ed                	jne    800999 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009ac:	89 f0                	mov    %esi,%eax
  8009ae:	5b                   	pop    %ebx
  8009af:	5e                   	pop    %esi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bd:	8b 55 10             	mov    0x10(%ebp),%edx
  8009c0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c2:	85 d2                	test   %edx,%edx
  8009c4:	74 21                	je     8009e7 <strlcpy+0x35>
  8009c6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009ca:	89 f2                	mov    %esi,%edx
  8009cc:	eb 09                	jmp    8009d7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ce:	83 c2 01             	add    $0x1,%edx
  8009d1:	83 c1 01             	add    $0x1,%ecx
  8009d4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d7:	39 c2                	cmp    %eax,%edx
  8009d9:	74 09                	je     8009e4 <strlcpy+0x32>
  8009db:	0f b6 19             	movzbl (%ecx),%ebx
  8009de:	84 db                	test   %bl,%bl
  8009e0:	75 ec                	jne    8009ce <strlcpy+0x1c>
  8009e2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009e4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009e7:	29 f0                	sub    %esi,%eax
}
  8009e9:	5b                   	pop    %ebx
  8009ea:	5e                   	pop    %esi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f6:	eb 06                	jmp    8009fe <strcmp+0x11>
		p++, q++;
  8009f8:	83 c1 01             	add    $0x1,%ecx
  8009fb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009fe:	0f b6 01             	movzbl (%ecx),%eax
  800a01:	84 c0                	test   %al,%al
  800a03:	74 04                	je     800a09 <strcmp+0x1c>
  800a05:	3a 02                	cmp    (%edx),%al
  800a07:	74 ef                	je     8009f8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a09:	0f b6 c0             	movzbl %al,%eax
  800a0c:	0f b6 12             	movzbl (%edx),%edx
  800a0f:	29 d0                	sub    %edx,%eax
}
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	53                   	push   %ebx
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1d:	89 c3                	mov    %eax,%ebx
  800a1f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a22:	eb 06                	jmp    800a2a <strncmp+0x17>
		n--, p++, q++;
  800a24:	83 c0 01             	add    $0x1,%eax
  800a27:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a2a:	39 d8                	cmp    %ebx,%eax
  800a2c:	74 15                	je     800a43 <strncmp+0x30>
  800a2e:	0f b6 08             	movzbl (%eax),%ecx
  800a31:	84 c9                	test   %cl,%cl
  800a33:	74 04                	je     800a39 <strncmp+0x26>
  800a35:	3a 0a                	cmp    (%edx),%cl
  800a37:	74 eb                	je     800a24 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a39:	0f b6 00             	movzbl (%eax),%eax
  800a3c:	0f b6 12             	movzbl (%edx),%edx
  800a3f:	29 d0                	sub    %edx,%eax
  800a41:	eb 05                	jmp    800a48 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a48:	5b                   	pop    %ebx
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a55:	eb 07                	jmp    800a5e <strchr+0x13>
		if (*s == c)
  800a57:	38 ca                	cmp    %cl,%dl
  800a59:	74 0f                	je     800a6a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a5b:	83 c0 01             	add    $0x1,%eax
  800a5e:	0f b6 10             	movzbl (%eax),%edx
  800a61:	84 d2                	test   %dl,%dl
  800a63:	75 f2                	jne    800a57 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a65:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a76:	eb 03                	jmp    800a7b <strfind+0xf>
  800a78:	83 c0 01             	add    $0x1,%eax
  800a7b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a7e:	38 ca                	cmp    %cl,%dl
  800a80:	74 04                	je     800a86 <strfind+0x1a>
  800a82:	84 d2                	test   %dl,%dl
  800a84:	75 f2                	jne    800a78 <strfind+0xc>
			break;
	return (char *) s;
}
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	53                   	push   %ebx
  800a8e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a91:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a94:	85 c9                	test   %ecx,%ecx
  800a96:	74 36                	je     800ace <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a98:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9e:	75 28                	jne    800ac8 <memset+0x40>
  800aa0:	f6 c1 03             	test   $0x3,%cl
  800aa3:	75 23                	jne    800ac8 <memset+0x40>
		c &= 0xFF;
  800aa5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa9:	89 d3                	mov    %edx,%ebx
  800aab:	c1 e3 08             	shl    $0x8,%ebx
  800aae:	89 d6                	mov    %edx,%esi
  800ab0:	c1 e6 18             	shl    $0x18,%esi
  800ab3:	89 d0                	mov    %edx,%eax
  800ab5:	c1 e0 10             	shl    $0x10,%eax
  800ab8:	09 f0                	or     %esi,%eax
  800aba:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800abc:	89 d8                	mov    %ebx,%eax
  800abe:	09 d0                	or     %edx,%eax
  800ac0:	c1 e9 02             	shr    $0x2,%ecx
  800ac3:	fc                   	cld    
  800ac4:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac6:	eb 06                	jmp    800ace <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acb:	fc                   	cld    
  800acc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ace:	89 f8                	mov    %edi,%eax
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5f                   	pop    %edi
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	57                   	push   %edi
  800ad9:	56                   	push   %esi
  800ada:	8b 45 08             	mov    0x8(%ebp),%eax
  800add:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae3:	39 c6                	cmp    %eax,%esi
  800ae5:	73 35                	jae    800b1c <memmove+0x47>
  800ae7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aea:	39 d0                	cmp    %edx,%eax
  800aec:	73 2e                	jae    800b1c <memmove+0x47>
		s += n;
		d += n;
  800aee:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af1:	89 d6                	mov    %edx,%esi
  800af3:	09 fe                	or     %edi,%esi
  800af5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800afb:	75 13                	jne    800b10 <memmove+0x3b>
  800afd:	f6 c1 03             	test   $0x3,%cl
  800b00:	75 0e                	jne    800b10 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b02:	83 ef 04             	sub    $0x4,%edi
  800b05:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b08:	c1 e9 02             	shr    $0x2,%ecx
  800b0b:	fd                   	std    
  800b0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0e:	eb 09                	jmp    800b19 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b10:	83 ef 01             	sub    $0x1,%edi
  800b13:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b16:	fd                   	std    
  800b17:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b19:	fc                   	cld    
  800b1a:	eb 1d                	jmp    800b39 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1c:	89 f2                	mov    %esi,%edx
  800b1e:	09 c2                	or     %eax,%edx
  800b20:	f6 c2 03             	test   $0x3,%dl
  800b23:	75 0f                	jne    800b34 <memmove+0x5f>
  800b25:	f6 c1 03             	test   $0x3,%cl
  800b28:	75 0a                	jne    800b34 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b2a:	c1 e9 02             	shr    $0x2,%ecx
  800b2d:	89 c7                	mov    %eax,%edi
  800b2f:	fc                   	cld    
  800b30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b32:	eb 05                	jmp    800b39 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b34:	89 c7                	mov    %eax,%edi
  800b36:	fc                   	cld    
  800b37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b40:	ff 75 10             	pushl  0x10(%ebp)
  800b43:	ff 75 0c             	pushl  0xc(%ebp)
  800b46:	ff 75 08             	pushl  0x8(%ebp)
  800b49:	e8 87 ff ff ff       	call   800ad5 <memmove>
}
  800b4e:	c9                   	leave  
  800b4f:	c3                   	ret    

00800b50 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5b:	89 c6                	mov    %eax,%esi
  800b5d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b60:	eb 1a                	jmp    800b7c <memcmp+0x2c>
		if (*s1 != *s2)
  800b62:	0f b6 08             	movzbl (%eax),%ecx
  800b65:	0f b6 1a             	movzbl (%edx),%ebx
  800b68:	38 d9                	cmp    %bl,%cl
  800b6a:	74 0a                	je     800b76 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b6c:	0f b6 c1             	movzbl %cl,%eax
  800b6f:	0f b6 db             	movzbl %bl,%ebx
  800b72:	29 d8                	sub    %ebx,%eax
  800b74:	eb 0f                	jmp    800b85 <memcmp+0x35>
		s1++, s2++;
  800b76:	83 c0 01             	add    $0x1,%eax
  800b79:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7c:	39 f0                	cmp    %esi,%eax
  800b7e:	75 e2                	jne    800b62 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b85:	5b                   	pop    %ebx
  800b86:	5e                   	pop    %esi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	53                   	push   %ebx
  800b8d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b90:	89 c1                	mov    %eax,%ecx
  800b92:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b95:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b99:	eb 0a                	jmp    800ba5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b9b:	0f b6 10             	movzbl (%eax),%edx
  800b9e:	39 da                	cmp    %ebx,%edx
  800ba0:	74 07                	je     800ba9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ba2:	83 c0 01             	add    $0x1,%eax
  800ba5:	39 c8                	cmp    %ecx,%eax
  800ba7:	72 f2                	jb     800b9b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb8:	eb 03                	jmp    800bbd <strtol+0x11>
		s++;
  800bba:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bbd:	0f b6 01             	movzbl (%ecx),%eax
  800bc0:	3c 20                	cmp    $0x20,%al
  800bc2:	74 f6                	je     800bba <strtol+0xe>
  800bc4:	3c 09                	cmp    $0x9,%al
  800bc6:	74 f2                	je     800bba <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc8:	3c 2b                	cmp    $0x2b,%al
  800bca:	75 0a                	jne    800bd6 <strtol+0x2a>
		s++;
  800bcc:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bcf:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd4:	eb 11                	jmp    800be7 <strtol+0x3b>
  800bd6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bdb:	3c 2d                	cmp    $0x2d,%al
  800bdd:	75 08                	jne    800be7 <strtol+0x3b>
		s++, neg = 1;
  800bdf:	83 c1 01             	add    $0x1,%ecx
  800be2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bed:	75 15                	jne    800c04 <strtol+0x58>
  800bef:	80 39 30             	cmpb   $0x30,(%ecx)
  800bf2:	75 10                	jne    800c04 <strtol+0x58>
  800bf4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf8:	75 7c                	jne    800c76 <strtol+0xca>
		s += 2, base = 16;
  800bfa:	83 c1 02             	add    $0x2,%ecx
  800bfd:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c02:	eb 16                	jmp    800c1a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c04:	85 db                	test   %ebx,%ebx
  800c06:	75 12                	jne    800c1a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c08:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c0d:	80 39 30             	cmpb   $0x30,(%ecx)
  800c10:	75 08                	jne    800c1a <strtol+0x6e>
		s++, base = 8;
  800c12:	83 c1 01             	add    $0x1,%ecx
  800c15:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c22:	0f b6 11             	movzbl (%ecx),%edx
  800c25:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c28:	89 f3                	mov    %esi,%ebx
  800c2a:	80 fb 09             	cmp    $0x9,%bl
  800c2d:	77 08                	ja     800c37 <strtol+0x8b>
			dig = *s - '0';
  800c2f:	0f be d2             	movsbl %dl,%edx
  800c32:	83 ea 30             	sub    $0x30,%edx
  800c35:	eb 22                	jmp    800c59 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c37:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c3a:	89 f3                	mov    %esi,%ebx
  800c3c:	80 fb 19             	cmp    $0x19,%bl
  800c3f:	77 08                	ja     800c49 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c41:	0f be d2             	movsbl %dl,%edx
  800c44:	83 ea 57             	sub    $0x57,%edx
  800c47:	eb 10                	jmp    800c59 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c49:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c4c:	89 f3                	mov    %esi,%ebx
  800c4e:	80 fb 19             	cmp    $0x19,%bl
  800c51:	77 16                	ja     800c69 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c53:	0f be d2             	movsbl %dl,%edx
  800c56:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c59:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c5c:	7d 0b                	jge    800c69 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c5e:	83 c1 01             	add    $0x1,%ecx
  800c61:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c65:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c67:	eb b9                	jmp    800c22 <strtol+0x76>

	if (endptr)
  800c69:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c6d:	74 0d                	je     800c7c <strtol+0xd0>
		*endptr = (char *) s;
  800c6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c72:	89 0e                	mov    %ecx,(%esi)
  800c74:	eb 06                	jmp    800c7c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c76:	85 db                	test   %ebx,%ebx
  800c78:	74 98                	je     800c12 <strtol+0x66>
  800c7a:	eb 9e                	jmp    800c1a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c7c:	89 c2                	mov    %eax,%edx
  800c7e:	f7 da                	neg    %edx
  800c80:	85 ff                	test   %edi,%edi
  800c82:	0f 45 c2             	cmovne %edx,%eax
}
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 04             	sub    $0x4,%esp
  800c93:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800c96:	57                   	push   %edi
  800c97:	e8 6e fc ff ff       	call   80090a <strlen>
  800c9c:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800c9f:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800ca2:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800ca7:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800cac:	eb 46                	jmp    800cf4 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800cae:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800cb2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800cb5:	80 f9 09             	cmp    $0x9,%cl
  800cb8:	77 08                	ja     800cc2 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800cba:	0f be d2             	movsbl %dl,%edx
  800cbd:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800cc0:	eb 27                	jmp    800ce9 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800cc2:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800cc5:	80 f9 05             	cmp    $0x5,%cl
  800cc8:	77 08                	ja     800cd2 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800cca:	0f be d2             	movsbl %dl,%edx
  800ccd:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800cd0:	eb 17                	jmp    800ce9 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800cd2:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800cd5:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800cd8:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800cdd:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800ce1:	77 06                	ja     800ce9 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800ce3:	0f be d2             	movsbl %dl,%edx
  800ce6:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800ce9:	0f af ce             	imul   %esi,%ecx
  800cec:	01 c8                	add    %ecx,%eax
		base *= 16;
  800cee:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800cf1:	83 eb 01             	sub    $0x1,%ebx
  800cf4:	83 fb 01             	cmp    $0x1,%ebx
  800cf7:	7f b5                	jg     800cae <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	89 c3                	mov    %eax,%ebx
  800d14:	89 c7                	mov    %eax,%edi
  800d16:	89 c6                	mov    %eax,%esi
  800d18:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <sys_cgetc>:

int
sys_cgetc(void)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d25:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2a:	b8 01 00 00 00       	mov    $0x1,%eax
  800d2f:	89 d1                	mov    %edx,%ecx
  800d31:	89 d3                	mov    %edx,%ebx
  800d33:	89 d7                	mov    %edx,%edi
  800d35:	89 d6                	mov    %edx,%esi
  800d37:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    

00800d3e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d47:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4c:	b8 03 00 00 00       	mov    $0x3,%eax
  800d51:	8b 55 08             	mov    0x8(%ebp),%edx
  800d54:	89 cb                	mov    %ecx,%ebx
  800d56:	89 cf                	mov    %ecx,%edi
  800d58:	89 ce                	mov    %ecx,%esi
  800d5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	7e 17                	jle    800d77 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d60:	83 ec 0c             	sub    $0xc,%esp
  800d63:	50                   	push   %eax
  800d64:	6a 03                	push   $0x3
  800d66:	68 3f 28 80 00       	push   $0x80283f
  800d6b:	6a 23                	push   $0x23
  800d6d:	68 5c 28 80 00       	push   $0x80285c
  800d72:	e8 bf f4 ff ff       	call   800236 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d85:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8a:	b8 02 00 00 00       	mov    $0x2,%eax
  800d8f:	89 d1                	mov    %edx,%ecx
  800d91:	89 d3                	mov    %edx,%ebx
  800d93:	89 d7                	mov    %edx,%edi
  800d95:	89 d6                	mov    %edx,%esi
  800d97:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <sys_yield>:

void
sys_yield(void)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da4:	ba 00 00 00 00       	mov    $0x0,%edx
  800da9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dae:	89 d1                	mov    %edx,%ecx
  800db0:	89 d3                	mov    %edx,%ebx
  800db2:	89 d7                	mov    %edx,%edi
  800db4:	89 d6                	mov    %edx,%esi
  800db6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	57                   	push   %edi
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
  800dc3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc6:	be 00 00 00 00       	mov    $0x0,%esi
  800dcb:	b8 04 00 00 00       	mov    $0x4,%eax
  800dd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd9:	89 f7                	mov    %esi,%edi
  800ddb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	7e 17                	jle    800df8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	50                   	push   %eax
  800de5:	6a 04                	push   $0x4
  800de7:	68 3f 28 80 00       	push   $0x80283f
  800dec:	6a 23                	push   $0x23
  800dee:	68 5c 28 80 00       	push   $0x80285c
  800df3:	e8 3e f4 ff ff       	call   800236 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800df8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e09:	b8 05 00 00 00       	mov    $0x5,%eax
  800e0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e11:	8b 55 08             	mov    0x8(%ebp),%edx
  800e14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e17:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e1a:	8b 75 18             	mov    0x18(%ebp),%esi
  800e1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	7e 17                	jle    800e3a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	50                   	push   %eax
  800e27:	6a 05                	push   $0x5
  800e29:	68 3f 28 80 00       	push   $0x80283f
  800e2e:	6a 23                	push   $0x23
  800e30:	68 5c 28 80 00       	push   $0x80285c
  800e35:	e8 fc f3 ff ff       	call   800236 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
  800e48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e50:	b8 06 00 00 00       	mov    $0x6,%eax
  800e55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	89 df                	mov    %ebx,%edi
  800e5d:	89 de                	mov    %ebx,%esi
  800e5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e61:	85 c0                	test   %eax,%eax
  800e63:	7e 17                	jle    800e7c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e65:	83 ec 0c             	sub    $0xc,%esp
  800e68:	50                   	push   %eax
  800e69:	6a 06                	push   $0x6
  800e6b:	68 3f 28 80 00       	push   $0x80283f
  800e70:	6a 23                	push   $0x23
  800e72:	68 5c 28 80 00       	push   $0x80285c
  800e77:	e8 ba f3 ff ff       	call   800236 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	57                   	push   %edi
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
  800e8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e92:	b8 08 00 00 00       	mov    $0x8,%eax
  800e97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9d:	89 df                	mov    %ebx,%edi
  800e9f:	89 de                	mov    %ebx,%esi
  800ea1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea3:	85 c0                	test   %eax,%eax
  800ea5:	7e 17                	jle    800ebe <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea7:	83 ec 0c             	sub    $0xc,%esp
  800eaa:	50                   	push   %eax
  800eab:	6a 08                	push   $0x8
  800ead:	68 3f 28 80 00       	push   $0x80283f
  800eb2:	6a 23                	push   $0x23
  800eb4:	68 5c 28 80 00       	push   $0x80285c
  800eb9:	e8 78 f3 ff ff       	call   800236 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ebe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ed9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edc:	8b 55 08             	mov    0x8(%ebp),%edx
  800edf:	89 df                	mov    %ebx,%edi
  800ee1:	89 de                	mov    %ebx,%esi
  800ee3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	7e 17                	jle    800f00 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee9:	83 ec 0c             	sub    $0xc,%esp
  800eec:	50                   	push   %eax
  800eed:	6a 0a                	push   $0xa
  800eef:	68 3f 28 80 00       	push   $0x80283f
  800ef4:	6a 23                	push   $0x23
  800ef6:	68 5c 28 80 00       	push   $0x80285c
  800efb:	e8 36 f3 ff ff       	call   800236 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
  800f0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f16:	b8 09 00 00 00       	mov    $0x9,%eax
  800f1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f21:	89 df                	mov    %ebx,%edi
  800f23:	89 de                	mov    %ebx,%esi
  800f25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f27:	85 c0                	test   %eax,%eax
  800f29:	7e 17                	jle    800f42 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2b:	83 ec 0c             	sub    $0xc,%esp
  800f2e:	50                   	push   %eax
  800f2f:	6a 09                	push   $0x9
  800f31:	68 3f 28 80 00       	push   $0x80283f
  800f36:	6a 23                	push   $0x23
  800f38:	68 5c 28 80 00       	push   $0x80285c
  800f3d:	e8 f4 f2 ff ff       	call   800236 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	57                   	push   %edi
  800f4e:	56                   	push   %esi
  800f4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f50:	be 00 00 00 00       	mov    $0x0,%esi
  800f55:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f63:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f66:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	57                   	push   %edi
  800f71:	56                   	push   %esi
  800f72:	53                   	push   %ebx
  800f73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f7b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f80:	8b 55 08             	mov    0x8(%ebp),%edx
  800f83:	89 cb                	mov    %ecx,%ebx
  800f85:	89 cf                	mov    %ecx,%edi
  800f87:	89 ce                	mov    %ecx,%esi
  800f89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	7e 17                	jle    800fa6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	50                   	push   %eax
  800f93:	6a 0d                	push   $0xd
  800f95:	68 3f 28 80 00       	push   $0x80283f
  800f9a:	6a 23                	push   $0x23
  800f9c:	68 5c 28 80 00       	push   $0x80285c
  800fa1:	e8 90 f2 ff ff       	call   800236 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa9:	5b                   	pop    %ebx
  800faa:	5e                   	pop    %esi
  800fab:	5f                   	pop    %edi
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    

00800fae <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	53                   	push   %ebx
  800fb2:	83 ec 04             	sub    $0x4,%esp
  800fb5:	8b 45 08             	mov    0x8(%ebp),%eax

	
	void *addr = (void *) utf->utf_fault_va;
  800fb8:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800fba:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fbe:	74 11                	je     800fd1 <pgfault+0x23>
  800fc0:	89 d8                	mov    %ebx,%eax
  800fc2:	c1 e8 0c             	shr    $0xc,%eax
  800fc5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fcc:	f6 c4 08             	test   $0x8,%ah
  800fcf:	75 14                	jne    800fe5 <pgfault+0x37>
		panic("page fault");
  800fd1:	83 ec 04             	sub    $0x4,%esp
  800fd4:	68 6a 28 80 00       	push   $0x80286a
  800fd9:	6a 5b                	push   $0x5b
  800fdb:	68 75 28 80 00       	push   $0x802875
  800fe0:	e8 51 f2 ff ff       	call   800236 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// allocate a new page and map it at a temporary location
	if((r = sys_page_alloc(0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800fe5:	83 ec 04             	sub    $0x4,%esp
  800fe8:	6a 07                	push   $0x7
  800fea:	68 00 f0 7f 00       	push   $0x7ff000
  800fef:	6a 00                	push   $0x0
  800ff1:	e8 c7 fd ff ff       	call   800dbd <sys_page_alloc>
  800ff6:	83 c4 10             	add    $0x10,%esp
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	79 12                	jns    80100f <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800ffd:	50                   	push   %eax
  800ffe:	68 80 28 80 00       	push   $0x802880
  801003:	6a 66                	push   $0x66
  801005:	68 75 28 80 00       	push   $0x802875
  80100a:	e8 27 f2 ff ff       	call   800236 <_panic>

	// copy date to new page
	//strncpy((char *)PFTEMP, (char *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
	memcpy((void *)PFTEMP, (void *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
  80100f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801015:	83 ec 04             	sub    $0x4,%esp
  801018:	68 00 10 00 00       	push   $0x1000
  80101d:	53                   	push   %ebx
  80101e:	68 00 f0 7f 00       	push   $0x7ff000
  801023:	e8 15 fb ff ff       	call   800b3d <memcpy>

	// move the new page to the old page's address
	if((r = sys_page_map(0, (void *)PFTEMP, 0, (void *)
  801028:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80102f:	53                   	push   %ebx
  801030:	6a 00                	push   $0x0
  801032:	68 00 f0 7f 00       	push   $0x7ff000
  801037:	6a 00                	push   $0x0
  801039:	e8 c2 fd ff ff       	call   800e00 <sys_page_map>
  80103e:	83 c4 20             	add    $0x20,%esp
  801041:	85 c0                	test   %eax,%eax
  801043:	79 12                	jns    801057 <pgfault+0xa9>
		(ROUNDDOWN(addr, PGSIZE)), PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_map: %e", r);
  801045:	50                   	push   %eax
  801046:	68 93 28 80 00       	push   $0x802893
  80104b:	6a 6f                	push   $0x6f
  80104d:	68 75 28 80 00       	push   $0x802875
  801052:	e8 df f1 ff ff       	call   800236 <_panic>

	// unmap page on PFTEMP
	if((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  801057:	83 ec 08             	sub    $0x8,%esp
  80105a:	68 00 f0 7f 00       	push   $0x7ff000
  80105f:	6a 00                	push   $0x0
  801061:	e8 dc fd ff ff       	call   800e42 <sys_page_unmap>
  801066:	83 c4 10             	add    $0x10,%esp
  801069:	85 c0                	test   %eax,%eax
  80106b:	79 12                	jns    80107f <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  80106d:	50                   	push   %eax
  80106e:	68 a4 28 80 00       	push   $0x8028a4
  801073:	6a 73                	push   $0x73
  801075:	68 75 28 80 00       	push   $0x802875
  80107a:	e8 b7 f1 ff ff       	call   800236 <_panic>


}
  80107f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801082:	c9                   	leave  
  801083:	c3                   	ret    

00801084 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	57                   	push   %edi
  801088:	56                   	push   %esi
  801089:	53                   	push   %ebx
  80108a:	83 ec 28             	sub    $0x28,%esp

	#ifdef CHALLENGE 
	set_exception_handler(pgfault, T_PGFLT);
	#else
	// set up page fault handler
	set_pgfault_handler(pgfault);
  80108d:	68 ae 0f 80 00       	push   $0x800fae
  801092:	e8 51 0f 00 00       	call   801fe8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801097:	b8 07 00 00 00       	mov    $0x7,%eax
  80109c:	cd 30                	int    $0x30
  80109e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	#endif

	// create a child
	envid = sys_exofork();
	if (envid < 0)
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	79 15                	jns    8010c0 <fork+0x3c>
		panic("sys_exofork: %e", envid);
  8010ab:	50                   	push   %eax
  8010ac:	68 b7 28 80 00       	push   $0x8028b7
  8010b1:	68 d0 00 00 00       	push   $0xd0
  8010b6:	68 75 28 80 00       	push   $0x802875
  8010bb:	e8 76 f1 ff ff       	call   800236 <_panic>
  8010c0:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8010c5:	be 00 08 00 00       	mov    $0x800,%esi
	// we are the child
	if(envid == 0) {
  8010ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8010ce:	75 21                	jne    8010f1 <fork+0x6d>
		// the copied valude of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8010d0:	e8 aa fc ff ff       	call   800d7f <sys_getenvid>
  8010d5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010da:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010e2:	a3 08 40 80 00       	mov    %eax,0x804008
		/*// alloc exception stack
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
			PTE_P | PTE_U | PTE_W)) < 0)
			panic("sys_page_alloc: %e", r);*/

		return 0;
  8010e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ec:	e9 a3 01 00 00       	jmp    801294 <fork+0x210>
{
	int r;

	// LAB 4: Your code here.
	
	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P))
  8010f1:	89 d8                	mov    %ebx,%eax
  8010f3:	c1 e8 16             	shr    $0x16,%eax
  8010f6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010fd:	a8 01                	test   $0x1,%al
  8010ff:	0f 84 f0 00 00 00    	je     8011f5 <fork+0x171>
		return 0;

	// virtual page pn's page table entry
	pte_t pe = uvpt[pn];
  801105:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi


	if((pe & PTE_P) && (pe & PTE_U)) {
  80110c:	89 f8                	mov    %edi,%eax
  80110e:	83 e0 05             	and    $0x5,%eax
  801111:	83 f8 05             	cmp    $0x5,%eax
  801114:	0f 85 db 00 00 00    	jne    8011f5 <fork+0x171>
		// share with the child environment 
		if(pe & PTE_SHARE) {
  80111a:	f7 c7 00 04 00 00    	test   $0x400,%edi
  801120:	74 36                	je     801158 <fork+0xd4>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  801122:	83 ec 0c             	sub    $0xc,%esp
  801125:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  80112b:	57                   	push   %edi
  80112c:	53                   	push   %ebx
  80112d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801130:	53                   	push   %ebx
  801131:	6a 00                	push   $0x0
  801133:	e8 c8 fc ff ff       	call   800e00 <sys_page_map>
  801138:	83 c4 20             	add    $0x20,%esp
  80113b:	85 c0                	test   %eax,%eax
  80113d:	0f 89 b2 00 00 00    	jns    8011f5 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  801143:	50                   	push   %eax
  801144:	68 c7 28 80 00       	push   $0x8028c7
  801149:	68 97 00 00 00       	push   $0x97
  80114e:	68 75 28 80 00       	push   $0x802875
  801153:	e8 de f0 ff ff       	call   800236 <_panic>
		}
		// the page is writable or copy-on-write
		else if((pe & PTE_W) || (pe & PTE_COW)) {
  801158:	f7 c7 02 08 00 00    	test   $0x802,%edi
  80115e:	74 63                	je     8011c3 <fork+0x13f>
			// create the child mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, 
  801160:	81 e7 05 06 00 00    	and    $0x605,%edi
  801166:	81 cf 00 08 00 00    	or     $0x800,%edi
  80116c:	83 ec 0c             	sub    $0xc,%esp
  80116f:	57                   	push   %edi
  801170:	53                   	push   %ebx
  801171:	ff 75 e4             	pushl  -0x1c(%ebp)
  801174:	53                   	push   %ebx
  801175:	6a 00                	push   $0x0
  801177:	e8 84 fc ff ff       	call   800e00 <sys_page_map>
  80117c:	83 c4 20             	add    $0x20,%esp
  80117f:	85 c0                	test   %eax,%eax
  801181:	79 15                	jns    801198 <fork+0x114>
				(void *)(pn*PGSIZE), (pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  801183:	50                   	push   %eax
  801184:	68 c7 28 80 00       	push   $0x8028c7
  801189:	68 9e 00 00 00       	push   $0x9e
  80118e:	68 75 28 80 00       	push   $0x802875
  801193:	e8 9e f0 ff ff       	call   800236 <_panic>
			// map the parent mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE),
  801198:	83 ec 0c             	sub    $0xc,%esp
  80119b:	57                   	push   %edi
  80119c:	53                   	push   %ebx
  80119d:	6a 00                	push   $0x0
  80119f:	53                   	push   %ebx
  8011a0:	6a 00                	push   $0x0
  8011a2:	e8 59 fc ff ff       	call   800e00 <sys_page_map>
  8011a7:	83 c4 20             	add    $0x20,%esp
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	79 47                	jns    8011f5 <fork+0x171>
				(pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  8011ae:	50                   	push   %eax
  8011af:	68 c7 28 80 00       	push   $0x8028c7
  8011b4:	68 a2 00 00 00       	push   $0xa2
  8011b9:	68 75 28 80 00       	push   $0x802875
  8011be:	e8 73 f0 ff ff       	call   800236 <_panic>
		}	
		else {
			// create the child mapping read only
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  8011c3:	83 ec 0c             	sub    $0xc,%esp
  8011c6:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  8011cc:	57                   	push   %edi
  8011cd:	53                   	push   %ebx
  8011ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d1:	53                   	push   %ebx
  8011d2:	6a 00                	push   $0x0
  8011d4:	e8 27 fc ff ff       	call   800e00 <sys_page_map>
  8011d9:	83 c4 20             	add    $0x20,%esp
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	79 15                	jns    8011f5 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  8011e0:	50                   	push   %eax
  8011e1:	68 c7 28 80 00       	push   $0x8028c7
  8011e6:	68 a8 00 00 00       	push   $0xa8
  8011eb:	68 75 28 80 00       	push   $0x802875
  8011f0:	e8 41 f0 ff ff       	call   800236 <_panic>
			panic("sys_page_alloc: %e", r);*/

		return 0;
	}
	// copy address to child environment's page dirctory
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn)
  8011f5:	83 c6 01             	add    $0x1,%esi
  8011f8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011fe:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801204:	0f 85 e7 fe ff ff    	jne    8010f1 <fork+0x6d>
	#ifdef CHALLENGE 
	if((r = sys_env_set_exception_upcall(envid, thisenv->env_exception_upcall)) < 0)
		panic("sys_env_set_exception_upcall: %e", r);
	#else
	// set child's page fault handler
	if((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  80120a:	a1 08 40 80 00       	mov    0x804008,%eax
  80120f:	8b 40 64             	mov    0x64(%eax),%eax
  801212:	83 ec 08             	sub    $0x8,%esp
  801215:	50                   	push   %eax
  801216:	ff 75 e0             	pushl  -0x20(%ebp)
  801219:	e8 ea fc ff ff       	call   800f08 <sys_env_set_pgfault_upcall>
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	85 c0                	test   %eax,%eax
  801223:	79 15                	jns    80123a <fork+0x1b6>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801225:	50                   	push   %eax
  801226:	68 00 29 80 00       	push   $0x802900
  80122b:	68 e9 00 00 00       	push   $0xe9
  801230:	68 75 28 80 00       	push   $0x802875
  801235:	e8 fc ef ff ff       	call   800236 <_panic>
	#endif

	// alloc exception stack for child environment
	if((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), 
  80123a:	83 ec 04             	sub    $0x4,%esp
  80123d:	6a 07                	push   $0x7
  80123f:	68 00 f0 bf ee       	push   $0xeebff000
  801244:	ff 75 e0             	pushl  -0x20(%ebp)
  801247:	e8 71 fb ff ff       	call   800dbd <sys_page_alloc>
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	85 c0                	test   %eax,%eax
  801251:	79 15                	jns    801268 <fork+0x1e4>
		PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
  801253:	50                   	push   %eax
  801254:	68 80 28 80 00       	push   $0x802880
  801259:	68 ef 00 00 00       	push   $0xef
  80125e:	68 75 28 80 00       	push   $0x802875
  801263:	e8 ce ef ff ff       	call   800236 <_panic>

	// start the child environment running
	if((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801268:	83 ec 08             	sub    $0x8,%esp
  80126b:	6a 02                	push   $0x2
  80126d:	ff 75 e0             	pushl  -0x20(%ebp)
  801270:	e8 0f fc ff ff       	call   800e84 <sys_env_set_status>
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	79 15                	jns    801291 <fork+0x20d>
		panic("sys_env_set_status: %e", r);
  80127c:	50                   	push   %eax
  80127d:	68 d3 28 80 00       	push   $0x8028d3
  801282:	68 f3 00 00 00       	push   $0xf3
  801287:	68 75 28 80 00       	push   $0x802875
  80128c:	e8 a5 ef ff ff       	call   800236 <_panic>

	return envid;
  801291:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801294:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801297:	5b                   	pop    %ebx
  801298:	5e                   	pop    %esi
  801299:	5f                   	pop    %edi
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    

0080129c <sfork>:

// Challenge!
int
sfork(void)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8012a2:	68 ea 28 80 00       	push   $0x8028ea
  8012a7:	68 fc 00 00 00       	push   $0xfc
  8012ac:	68 75 28 80 00       	push   $0x802875
  8012b1:	e8 80 ef ff ff       	call   800236 <_panic>

008012b6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bc:	05 00 00 00 30       	add    $0x30000000,%eax
  8012c1:	c1 e8 0c             	shr    $0xc,%eax
}
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    

008012c6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cc:	05 00 00 00 30       	add    $0x30000000,%eax
  8012d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012d6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012db:	5d                   	pop    %ebp
  8012dc:	c3                   	ret    

008012dd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012e8:	89 c2                	mov    %eax,%edx
  8012ea:	c1 ea 16             	shr    $0x16,%edx
  8012ed:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012f4:	f6 c2 01             	test   $0x1,%dl
  8012f7:	74 11                	je     80130a <fd_alloc+0x2d>
  8012f9:	89 c2                	mov    %eax,%edx
  8012fb:	c1 ea 0c             	shr    $0xc,%edx
  8012fe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801305:	f6 c2 01             	test   $0x1,%dl
  801308:	75 09                	jne    801313 <fd_alloc+0x36>
			*fd_store = fd;
  80130a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80130c:	b8 00 00 00 00       	mov    $0x0,%eax
  801311:	eb 17                	jmp    80132a <fd_alloc+0x4d>
  801313:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801318:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80131d:	75 c9                	jne    8012e8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80131f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801325:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80132a:	5d                   	pop    %ebp
  80132b:	c3                   	ret    

0080132c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801332:	83 f8 1f             	cmp    $0x1f,%eax
  801335:	77 36                	ja     80136d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801337:	c1 e0 0c             	shl    $0xc,%eax
  80133a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80133f:	89 c2                	mov    %eax,%edx
  801341:	c1 ea 16             	shr    $0x16,%edx
  801344:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80134b:	f6 c2 01             	test   $0x1,%dl
  80134e:	74 24                	je     801374 <fd_lookup+0x48>
  801350:	89 c2                	mov    %eax,%edx
  801352:	c1 ea 0c             	shr    $0xc,%edx
  801355:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80135c:	f6 c2 01             	test   $0x1,%dl
  80135f:	74 1a                	je     80137b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801361:	8b 55 0c             	mov    0xc(%ebp),%edx
  801364:	89 02                	mov    %eax,(%edx)
	return 0;
  801366:	b8 00 00 00 00       	mov    $0x0,%eax
  80136b:	eb 13                	jmp    801380 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80136d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801372:	eb 0c                	jmp    801380 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801374:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801379:	eb 05                	jmp    801380 <fd_lookup+0x54>
  80137b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801380:	5d                   	pop    %ebp
  801381:	c3                   	ret    

00801382 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	83 ec 08             	sub    $0x8,%esp
  801388:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80138b:	ba 9c 29 80 00       	mov    $0x80299c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801390:	eb 13                	jmp    8013a5 <dev_lookup+0x23>
  801392:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801395:	39 08                	cmp    %ecx,(%eax)
  801397:	75 0c                	jne    8013a5 <dev_lookup+0x23>
			*dev = devtab[i];
  801399:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80139c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80139e:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a3:	eb 2e                	jmp    8013d3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013a5:	8b 02                	mov    (%edx),%eax
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	75 e7                	jne    801392 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013ab:	a1 08 40 80 00       	mov    0x804008,%eax
  8013b0:	8b 40 48             	mov    0x48(%eax),%eax
  8013b3:	83 ec 04             	sub    $0x4,%esp
  8013b6:	51                   	push   %ecx
  8013b7:	50                   	push   %eax
  8013b8:	68 20 29 80 00       	push   $0x802920
  8013bd:	e8 4d ef ff ff       	call   80030f <cprintf>
	*dev = 0;
  8013c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013d3:	c9                   	leave  
  8013d4:	c3                   	ret    

008013d5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	56                   	push   %esi
  8013d9:	53                   	push   %ebx
  8013da:	83 ec 10             	sub    $0x10,%esp
  8013dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8013e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e6:	50                   	push   %eax
  8013e7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013ed:	c1 e8 0c             	shr    $0xc,%eax
  8013f0:	50                   	push   %eax
  8013f1:	e8 36 ff ff ff       	call   80132c <fd_lookup>
  8013f6:	83 c4 08             	add    $0x8,%esp
  8013f9:	85 c0                	test   %eax,%eax
  8013fb:	78 05                	js     801402 <fd_close+0x2d>
	    || fd != fd2) 
  8013fd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801400:	74 0c                	je     80140e <fd_close+0x39>
		return (must_exist ? r : 0); 
  801402:	84 db                	test   %bl,%bl
  801404:	ba 00 00 00 00       	mov    $0x0,%edx
  801409:	0f 44 c2             	cmove  %edx,%eax
  80140c:	eb 41                	jmp    80144f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80140e:	83 ec 08             	sub    $0x8,%esp
  801411:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801414:	50                   	push   %eax
  801415:	ff 36                	pushl  (%esi)
  801417:	e8 66 ff ff ff       	call   801382 <dev_lookup>
  80141c:	89 c3                	mov    %eax,%ebx
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	85 c0                	test   %eax,%eax
  801423:	78 1a                	js     80143f <fd_close+0x6a>
		if (dev->dev_close) 
  801425:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801428:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  80142b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  801430:	85 c0                	test   %eax,%eax
  801432:	74 0b                	je     80143f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801434:	83 ec 0c             	sub    $0xc,%esp
  801437:	56                   	push   %esi
  801438:	ff d0                	call   *%eax
  80143a:	89 c3                	mov    %eax,%ebx
  80143c:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80143f:	83 ec 08             	sub    $0x8,%esp
  801442:	56                   	push   %esi
  801443:	6a 00                	push   $0x0
  801445:	e8 f8 f9 ff ff       	call   800e42 <sys_page_unmap>
	return r;
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	89 d8                	mov    %ebx,%eax
}
  80144f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801452:	5b                   	pop    %ebx
  801453:	5e                   	pop    %esi
  801454:	5d                   	pop    %ebp
  801455:	c3                   	ret    

00801456 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80145c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145f:	50                   	push   %eax
  801460:	ff 75 08             	pushl  0x8(%ebp)
  801463:	e8 c4 fe ff ff       	call   80132c <fd_lookup>
  801468:	83 c4 08             	add    $0x8,%esp
  80146b:	85 c0                	test   %eax,%eax
  80146d:	78 10                	js     80147f <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  80146f:	83 ec 08             	sub    $0x8,%esp
  801472:	6a 01                	push   $0x1
  801474:	ff 75 f4             	pushl  -0xc(%ebp)
  801477:	e8 59 ff ff ff       	call   8013d5 <fd_close>
  80147c:	83 c4 10             	add    $0x10,%esp
}
  80147f:	c9                   	leave  
  801480:	c3                   	ret    

00801481 <close_all>:

void
close_all(void)
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	53                   	push   %ebx
  801485:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801488:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80148d:	83 ec 0c             	sub    $0xc,%esp
  801490:	53                   	push   %ebx
  801491:	e8 c0 ff ff ff       	call   801456 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801496:	83 c3 01             	add    $0x1,%ebx
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	83 fb 20             	cmp    $0x20,%ebx
  80149f:	75 ec                	jne    80148d <close_all+0xc>
		close(i);
}
  8014a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a4:	c9                   	leave  
  8014a5:	c3                   	ret    

008014a6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	57                   	push   %edi
  8014aa:	56                   	push   %esi
  8014ab:	53                   	push   %ebx
  8014ac:	83 ec 2c             	sub    $0x2c,%esp
  8014af:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014b2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014b5:	50                   	push   %eax
  8014b6:	ff 75 08             	pushl  0x8(%ebp)
  8014b9:	e8 6e fe ff ff       	call   80132c <fd_lookup>
  8014be:	83 c4 08             	add    $0x8,%esp
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	0f 88 c1 00 00 00    	js     80158a <dup+0xe4>
		return r;
	close(newfdnum);
  8014c9:	83 ec 0c             	sub    $0xc,%esp
  8014cc:	56                   	push   %esi
  8014cd:	e8 84 ff ff ff       	call   801456 <close>

	newfd = INDEX2FD(newfdnum);
  8014d2:	89 f3                	mov    %esi,%ebx
  8014d4:	c1 e3 0c             	shl    $0xc,%ebx
  8014d7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014dd:	83 c4 04             	add    $0x4,%esp
  8014e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014e3:	e8 de fd ff ff       	call   8012c6 <fd2data>
  8014e8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014ea:	89 1c 24             	mov    %ebx,(%esp)
  8014ed:	e8 d4 fd ff ff       	call   8012c6 <fd2data>
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014f8:	89 f8                	mov    %edi,%eax
  8014fa:	c1 e8 16             	shr    $0x16,%eax
  8014fd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801504:	a8 01                	test   $0x1,%al
  801506:	74 37                	je     80153f <dup+0x99>
  801508:	89 f8                	mov    %edi,%eax
  80150a:	c1 e8 0c             	shr    $0xc,%eax
  80150d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801514:	f6 c2 01             	test   $0x1,%dl
  801517:	74 26                	je     80153f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801519:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801520:	83 ec 0c             	sub    $0xc,%esp
  801523:	25 07 0e 00 00       	and    $0xe07,%eax
  801528:	50                   	push   %eax
  801529:	ff 75 d4             	pushl  -0x2c(%ebp)
  80152c:	6a 00                	push   $0x0
  80152e:	57                   	push   %edi
  80152f:	6a 00                	push   $0x0
  801531:	e8 ca f8 ff ff       	call   800e00 <sys_page_map>
  801536:	89 c7                	mov    %eax,%edi
  801538:	83 c4 20             	add    $0x20,%esp
  80153b:	85 c0                	test   %eax,%eax
  80153d:	78 2e                	js     80156d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80153f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801542:	89 d0                	mov    %edx,%eax
  801544:	c1 e8 0c             	shr    $0xc,%eax
  801547:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80154e:	83 ec 0c             	sub    $0xc,%esp
  801551:	25 07 0e 00 00       	and    $0xe07,%eax
  801556:	50                   	push   %eax
  801557:	53                   	push   %ebx
  801558:	6a 00                	push   $0x0
  80155a:	52                   	push   %edx
  80155b:	6a 00                	push   $0x0
  80155d:	e8 9e f8 ff ff       	call   800e00 <sys_page_map>
  801562:	89 c7                	mov    %eax,%edi
  801564:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801567:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801569:	85 ff                	test   %edi,%edi
  80156b:	79 1d                	jns    80158a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80156d:	83 ec 08             	sub    $0x8,%esp
  801570:	53                   	push   %ebx
  801571:	6a 00                	push   $0x0
  801573:	e8 ca f8 ff ff       	call   800e42 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801578:	83 c4 08             	add    $0x8,%esp
  80157b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80157e:	6a 00                	push   $0x0
  801580:	e8 bd f8 ff ff       	call   800e42 <sys_page_unmap>
	return r;
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	89 f8                	mov    %edi,%eax
}
  80158a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158d:	5b                   	pop    %ebx
  80158e:	5e                   	pop    %esi
  80158f:	5f                   	pop    %edi
  801590:	5d                   	pop    %ebp
  801591:	c3                   	ret    

00801592 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	53                   	push   %ebx
  801596:	83 ec 14             	sub    $0x14,%esp
  801599:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159f:	50                   	push   %eax
  8015a0:	53                   	push   %ebx
  8015a1:	e8 86 fd ff ff       	call   80132c <fd_lookup>
  8015a6:	83 c4 08             	add    $0x8,%esp
  8015a9:	89 c2                	mov    %eax,%edx
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	78 6d                	js     80161c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015af:	83 ec 08             	sub    $0x8,%esp
  8015b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b5:	50                   	push   %eax
  8015b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b9:	ff 30                	pushl  (%eax)
  8015bb:	e8 c2 fd ff ff       	call   801382 <dev_lookup>
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	78 4c                	js     801613 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015ca:	8b 42 08             	mov    0x8(%edx),%eax
  8015cd:	83 e0 03             	and    $0x3,%eax
  8015d0:	83 f8 01             	cmp    $0x1,%eax
  8015d3:	75 21                	jne    8015f6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d5:	a1 08 40 80 00       	mov    0x804008,%eax
  8015da:	8b 40 48             	mov    0x48(%eax),%eax
  8015dd:	83 ec 04             	sub    $0x4,%esp
  8015e0:	53                   	push   %ebx
  8015e1:	50                   	push   %eax
  8015e2:	68 61 29 80 00       	push   $0x802961
  8015e7:	e8 23 ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015f4:	eb 26                	jmp    80161c <read+0x8a>
	}
	if (!dev->dev_read)
  8015f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f9:	8b 40 08             	mov    0x8(%eax),%eax
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	74 17                	je     801617 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801600:	83 ec 04             	sub    $0x4,%esp
  801603:	ff 75 10             	pushl  0x10(%ebp)
  801606:	ff 75 0c             	pushl  0xc(%ebp)
  801609:	52                   	push   %edx
  80160a:	ff d0                	call   *%eax
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	eb 09                	jmp    80161c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801613:	89 c2                	mov    %eax,%edx
  801615:	eb 05                	jmp    80161c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801617:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80161c:	89 d0                	mov    %edx,%eax
  80161e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801621:	c9                   	leave  
  801622:	c3                   	ret    

00801623 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	57                   	push   %edi
  801627:	56                   	push   %esi
  801628:	53                   	push   %ebx
  801629:	83 ec 0c             	sub    $0xc,%esp
  80162c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80162f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801632:	bb 00 00 00 00       	mov    $0x0,%ebx
  801637:	eb 21                	jmp    80165a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801639:	83 ec 04             	sub    $0x4,%esp
  80163c:	89 f0                	mov    %esi,%eax
  80163e:	29 d8                	sub    %ebx,%eax
  801640:	50                   	push   %eax
  801641:	89 d8                	mov    %ebx,%eax
  801643:	03 45 0c             	add    0xc(%ebp),%eax
  801646:	50                   	push   %eax
  801647:	57                   	push   %edi
  801648:	e8 45 ff ff ff       	call   801592 <read>
		if (m < 0)
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	85 c0                	test   %eax,%eax
  801652:	78 10                	js     801664 <readn+0x41>
			return m;
		if (m == 0)
  801654:	85 c0                	test   %eax,%eax
  801656:	74 0a                	je     801662 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801658:	01 c3                	add    %eax,%ebx
  80165a:	39 f3                	cmp    %esi,%ebx
  80165c:	72 db                	jb     801639 <readn+0x16>
  80165e:	89 d8                	mov    %ebx,%eax
  801660:	eb 02                	jmp    801664 <readn+0x41>
  801662:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801664:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801667:	5b                   	pop    %ebx
  801668:	5e                   	pop    %esi
  801669:	5f                   	pop    %edi
  80166a:	5d                   	pop    %ebp
  80166b:	c3                   	ret    

0080166c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	53                   	push   %ebx
  801670:	83 ec 14             	sub    $0x14,%esp
  801673:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801676:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801679:	50                   	push   %eax
  80167a:	53                   	push   %ebx
  80167b:	e8 ac fc ff ff       	call   80132c <fd_lookup>
  801680:	83 c4 08             	add    $0x8,%esp
  801683:	89 c2                	mov    %eax,%edx
  801685:	85 c0                	test   %eax,%eax
  801687:	78 68                	js     8016f1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801689:	83 ec 08             	sub    $0x8,%esp
  80168c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168f:	50                   	push   %eax
  801690:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801693:	ff 30                	pushl  (%eax)
  801695:	e8 e8 fc ff ff       	call   801382 <dev_lookup>
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	85 c0                	test   %eax,%eax
  80169f:	78 47                	js     8016e8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016a8:	75 21                	jne    8016cb <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016aa:	a1 08 40 80 00       	mov    0x804008,%eax
  8016af:	8b 40 48             	mov    0x48(%eax),%eax
  8016b2:	83 ec 04             	sub    $0x4,%esp
  8016b5:	53                   	push   %ebx
  8016b6:	50                   	push   %eax
  8016b7:	68 7d 29 80 00       	push   $0x80297d
  8016bc:	e8 4e ec ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016c9:	eb 26                	jmp    8016f1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ce:	8b 52 0c             	mov    0xc(%edx),%edx
  8016d1:	85 d2                	test   %edx,%edx
  8016d3:	74 17                	je     8016ec <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016d5:	83 ec 04             	sub    $0x4,%esp
  8016d8:	ff 75 10             	pushl  0x10(%ebp)
  8016db:	ff 75 0c             	pushl  0xc(%ebp)
  8016de:	50                   	push   %eax
  8016df:	ff d2                	call   *%edx
  8016e1:	89 c2                	mov    %eax,%edx
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	eb 09                	jmp    8016f1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e8:	89 c2                	mov    %eax,%edx
  8016ea:	eb 05                	jmp    8016f1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016f1:	89 d0                	mov    %edx,%eax
  8016f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016fe:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801701:	50                   	push   %eax
  801702:	ff 75 08             	pushl  0x8(%ebp)
  801705:	e8 22 fc ff ff       	call   80132c <fd_lookup>
  80170a:	83 c4 08             	add    $0x8,%esp
  80170d:	85 c0                	test   %eax,%eax
  80170f:	78 0e                	js     80171f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801711:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801714:	8b 55 0c             	mov    0xc(%ebp),%edx
  801717:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80171a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80171f:	c9                   	leave  
  801720:	c3                   	ret    

00801721 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	53                   	push   %ebx
  801725:	83 ec 14             	sub    $0x14,%esp
  801728:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172e:	50                   	push   %eax
  80172f:	53                   	push   %ebx
  801730:	e8 f7 fb ff ff       	call   80132c <fd_lookup>
  801735:	83 c4 08             	add    $0x8,%esp
  801738:	89 c2                	mov    %eax,%edx
  80173a:	85 c0                	test   %eax,%eax
  80173c:	78 65                	js     8017a3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173e:	83 ec 08             	sub    $0x8,%esp
  801741:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801744:	50                   	push   %eax
  801745:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801748:	ff 30                	pushl  (%eax)
  80174a:	e8 33 fc ff ff       	call   801382 <dev_lookup>
  80174f:	83 c4 10             	add    $0x10,%esp
  801752:	85 c0                	test   %eax,%eax
  801754:	78 44                	js     80179a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801756:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801759:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80175d:	75 21                	jne    801780 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80175f:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801764:	8b 40 48             	mov    0x48(%eax),%eax
  801767:	83 ec 04             	sub    $0x4,%esp
  80176a:	53                   	push   %ebx
  80176b:	50                   	push   %eax
  80176c:	68 40 29 80 00       	push   $0x802940
  801771:	e8 99 eb ff ff       	call   80030f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80177e:	eb 23                	jmp    8017a3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801780:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801783:	8b 52 18             	mov    0x18(%edx),%edx
  801786:	85 d2                	test   %edx,%edx
  801788:	74 14                	je     80179e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80178a:	83 ec 08             	sub    $0x8,%esp
  80178d:	ff 75 0c             	pushl  0xc(%ebp)
  801790:	50                   	push   %eax
  801791:	ff d2                	call   *%edx
  801793:	89 c2                	mov    %eax,%edx
  801795:	83 c4 10             	add    $0x10,%esp
  801798:	eb 09                	jmp    8017a3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179a:	89 c2                	mov    %eax,%edx
  80179c:	eb 05                	jmp    8017a3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80179e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017a3:	89 d0                	mov    %edx,%eax
  8017a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a8:	c9                   	leave  
  8017a9:	c3                   	ret    

008017aa <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	53                   	push   %ebx
  8017ae:	83 ec 14             	sub    $0x14,%esp
  8017b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b7:	50                   	push   %eax
  8017b8:	ff 75 08             	pushl  0x8(%ebp)
  8017bb:	e8 6c fb ff ff       	call   80132c <fd_lookup>
  8017c0:	83 c4 08             	add    $0x8,%esp
  8017c3:	89 c2                	mov    %eax,%edx
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	78 58                	js     801821 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c9:	83 ec 08             	sub    $0x8,%esp
  8017cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017cf:	50                   	push   %eax
  8017d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d3:	ff 30                	pushl  (%eax)
  8017d5:	e8 a8 fb ff ff       	call   801382 <dev_lookup>
  8017da:	83 c4 10             	add    $0x10,%esp
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	78 37                	js     801818 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017e8:	74 32                	je     80181c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017ea:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017ed:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017f4:	00 00 00 
	stat->st_isdir = 0;
  8017f7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017fe:	00 00 00 
	stat->st_dev = dev;
  801801:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801807:	83 ec 08             	sub    $0x8,%esp
  80180a:	53                   	push   %ebx
  80180b:	ff 75 f0             	pushl  -0x10(%ebp)
  80180e:	ff 50 14             	call   *0x14(%eax)
  801811:	89 c2                	mov    %eax,%edx
  801813:	83 c4 10             	add    $0x10,%esp
  801816:	eb 09                	jmp    801821 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801818:	89 c2                	mov    %eax,%edx
  80181a:	eb 05                	jmp    801821 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80181c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801821:	89 d0                	mov    %edx,%eax
  801823:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801826:	c9                   	leave  
  801827:	c3                   	ret    

00801828 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	56                   	push   %esi
  80182c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80182d:	83 ec 08             	sub    $0x8,%esp
  801830:	6a 00                	push   $0x0
  801832:	ff 75 08             	pushl  0x8(%ebp)
  801835:	e8 2b 02 00 00       	call   801a65 <open>
  80183a:	89 c3                	mov    %eax,%ebx
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	85 c0                	test   %eax,%eax
  801841:	78 1b                	js     80185e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801843:	83 ec 08             	sub    $0x8,%esp
  801846:	ff 75 0c             	pushl  0xc(%ebp)
  801849:	50                   	push   %eax
  80184a:	e8 5b ff ff ff       	call   8017aa <fstat>
  80184f:	89 c6                	mov    %eax,%esi
	close(fd);
  801851:	89 1c 24             	mov    %ebx,(%esp)
  801854:	e8 fd fb ff ff       	call   801456 <close>
	return r;
  801859:	83 c4 10             	add    $0x10,%esp
  80185c:	89 f0                	mov    %esi,%eax
}
  80185e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801861:	5b                   	pop    %ebx
  801862:	5e                   	pop    %esi
  801863:	5d                   	pop    %ebp
  801864:	c3                   	ret    

00801865 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	56                   	push   %esi
  801869:	53                   	push   %ebx
  80186a:	89 c6                	mov    %eax,%esi
  80186c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80186e:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801875:	75 12                	jne    801889 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801877:	83 ec 0c             	sub    $0xc,%esp
  80187a:	6a 01                	push   $0x1
  80187c:	e8 b5 08 00 00       	call   802136 <ipc_find_env>
  801881:	a3 04 40 80 00       	mov    %eax,0x804004
  801886:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801889:	6a 07                	push   $0x7
  80188b:	68 00 50 80 00       	push   $0x805000
  801890:	56                   	push   %esi
  801891:	ff 35 04 40 80 00    	pushl  0x804004
  801897:	e8 44 08 00 00       	call   8020e0 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80189c:	83 c4 0c             	add    $0xc,%esp
  80189f:	6a 00                	push   $0x0
  8018a1:	53                   	push   %ebx
  8018a2:	6a 00                	push   $0x0
  8018a4:	e8 ce 07 00 00       	call   802077 <ipc_recv>
}
  8018a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ac:	5b                   	pop    %ebx
  8018ad:	5e                   	pop    %esi
  8018ae:	5d                   	pop    %ebp
  8018af:	c3                   	ret    

008018b0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018bc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ce:	b8 02 00 00 00       	mov    $0x2,%eax
  8018d3:	e8 8d ff ff ff       	call   801865 <fsipc>
}
  8018d8:	c9                   	leave  
  8018d9:	c3                   	ret    

008018da <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
  8018dd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f0:	b8 06 00 00 00       	mov    $0x6,%eax
  8018f5:	e8 6b ff ff ff       	call   801865 <fsipc>
}
  8018fa:	c9                   	leave  
  8018fb:	c3                   	ret    

008018fc <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	53                   	push   %ebx
  801900:	83 ec 04             	sub    $0x4,%esp
  801903:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801906:	8b 45 08             	mov    0x8(%ebp),%eax
  801909:	8b 40 0c             	mov    0xc(%eax),%eax
  80190c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801911:	ba 00 00 00 00       	mov    $0x0,%edx
  801916:	b8 05 00 00 00       	mov    $0x5,%eax
  80191b:	e8 45 ff ff ff       	call   801865 <fsipc>
  801920:	85 c0                	test   %eax,%eax
  801922:	78 2c                	js     801950 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801924:	83 ec 08             	sub    $0x8,%esp
  801927:	68 00 50 80 00       	push   $0x805000
  80192c:	53                   	push   %ebx
  80192d:	e8 11 f0 ff ff       	call   800943 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801932:	a1 80 50 80 00       	mov    0x805080,%eax
  801937:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80193d:	a1 84 50 80 00       	mov    0x805084,%eax
  801942:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801950:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801953:	c9                   	leave  
  801954:	c3                   	ret    

00801955 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	53                   	push   %ebx
  801959:	83 ec 08             	sub    $0x8,%esp
  80195c:	8b 45 10             	mov    0x10(%ebp),%eax
  80195f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801964:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801969:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80196c:	8b 45 08             	mov    0x8(%ebp),%eax
  80196f:	8b 40 0c             	mov    0xc(%eax),%eax
  801972:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801977:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80197d:	53                   	push   %ebx
  80197e:	ff 75 0c             	pushl  0xc(%ebp)
  801981:	68 08 50 80 00       	push   $0x805008
  801986:	e8 4a f1 ff ff       	call   800ad5 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80198b:	ba 00 00 00 00       	mov    $0x0,%edx
  801990:	b8 04 00 00 00       	mov    $0x4,%eax
  801995:	e8 cb fe ff ff       	call   801865 <fsipc>
  80199a:	83 c4 10             	add    $0x10,%esp
  80199d:	85 c0                	test   %eax,%eax
  80199f:	78 3d                	js     8019de <devfile_write+0x89>
		return r;

	assert(r <= n);
  8019a1:	39 d8                	cmp    %ebx,%eax
  8019a3:	76 19                	jbe    8019be <devfile_write+0x69>
  8019a5:	68 ac 29 80 00       	push   $0x8029ac
  8019aa:	68 b3 29 80 00       	push   $0x8029b3
  8019af:	68 9f 00 00 00       	push   $0x9f
  8019b4:	68 c8 29 80 00       	push   $0x8029c8
  8019b9:	e8 78 e8 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  8019be:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019c3:	76 19                	jbe    8019de <devfile_write+0x89>
  8019c5:	68 e0 29 80 00       	push   $0x8029e0
  8019ca:	68 b3 29 80 00       	push   $0x8029b3
  8019cf:	68 a0 00 00 00       	push   $0xa0
  8019d4:	68 c8 29 80 00       	push   $0x8029c8
  8019d9:	e8 58 e8 ff ff       	call   800236 <_panic>

	return r;
}
  8019de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	56                   	push   %esi
  8019e7:	53                   	push   %ebx
  8019e8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019f6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801a01:	b8 03 00 00 00       	mov    $0x3,%eax
  801a06:	e8 5a fe ff ff       	call   801865 <fsipc>
  801a0b:	89 c3                	mov    %eax,%ebx
  801a0d:	85 c0                	test   %eax,%eax
  801a0f:	78 4b                	js     801a5c <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a11:	39 c6                	cmp    %eax,%esi
  801a13:	73 16                	jae    801a2b <devfile_read+0x48>
  801a15:	68 ac 29 80 00       	push   $0x8029ac
  801a1a:	68 b3 29 80 00       	push   $0x8029b3
  801a1f:	6a 7e                	push   $0x7e
  801a21:	68 c8 29 80 00       	push   $0x8029c8
  801a26:	e8 0b e8 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  801a2b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a30:	7e 16                	jle    801a48 <devfile_read+0x65>
  801a32:	68 d3 29 80 00       	push   $0x8029d3
  801a37:	68 b3 29 80 00       	push   $0x8029b3
  801a3c:	6a 7f                	push   $0x7f
  801a3e:	68 c8 29 80 00       	push   $0x8029c8
  801a43:	e8 ee e7 ff ff       	call   800236 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a48:	83 ec 04             	sub    $0x4,%esp
  801a4b:	50                   	push   %eax
  801a4c:	68 00 50 80 00       	push   $0x805000
  801a51:	ff 75 0c             	pushl  0xc(%ebp)
  801a54:	e8 7c f0 ff ff       	call   800ad5 <memmove>
	return r;
  801a59:	83 c4 10             	add    $0x10,%esp
}
  801a5c:	89 d8                	mov    %ebx,%eax
  801a5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a61:	5b                   	pop    %ebx
  801a62:	5e                   	pop    %esi
  801a63:	5d                   	pop    %ebp
  801a64:	c3                   	ret    

00801a65 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	53                   	push   %ebx
  801a69:	83 ec 20             	sub    $0x20,%esp
  801a6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a6f:	53                   	push   %ebx
  801a70:	e8 95 ee ff ff       	call   80090a <strlen>
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a7d:	7f 67                	jg     801ae6 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a7f:	83 ec 0c             	sub    $0xc,%esp
  801a82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a85:	50                   	push   %eax
  801a86:	e8 52 f8 ff ff       	call   8012dd <fd_alloc>
  801a8b:	83 c4 10             	add    $0x10,%esp
		return r;
  801a8e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a90:	85 c0                	test   %eax,%eax
  801a92:	78 57                	js     801aeb <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a94:	83 ec 08             	sub    $0x8,%esp
  801a97:	53                   	push   %ebx
  801a98:	68 00 50 80 00       	push   $0x805000
  801a9d:	e8 a1 ee ff ff       	call   800943 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801aa2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801aaa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aad:	b8 01 00 00 00       	mov    $0x1,%eax
  801ab2:	e8 ae fd ff ff       	call   801865 <fsipc>
  801ab7:	89 c3                	mov    %eax,%ebx
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	85 c0                	test   %eax,%eax
  801abe:	79 14                	jns    801ad4 <open+0x6f>
		fd_close(fd, 0);
  801ac0:	83 ec 08             	sub    $0x8,%esp
  801ac3:	6a 00                	push   $0x0
  801ac5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac8:	e8 08 f9 ff ff       	call   8013d5 <fd_close>
		return r;
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	89 da                	mov    %ebx,%edx
  801ad2:	eb 17                	jmp    801aeb <open+0x86>
	}

	return fd2num(fd);
  801ad4:	83 ec 0c             	sub    $0xc,%esp
  801ad7:	ff 75 f4             	pushl  -0xc(%ebp)
  801ada:	e8 d7 f7 ff ff       	call   8012b6 <fd2num>
  801adf:	89 c2                	mov    %eax,%edx
  801ae1:	83 c4 10             	add    $0x10,%esp
  801ae4:	eb 05                	jmp    801aeb <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ae6:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801aeb:	89 d0                	mov    %edx,%eax
  801aed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af0:	c9                   	leave  
  801af1:	c3                   	ret    

00801af2 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801af8:	ba 00 00 00 00       	mov    $0x0,%edx
  801afd:	b8 08 00 00 00       	mov    $0x8,%eax
  801b02:	e8 5e fd ff ff       	call   801865 <fsipc>
}
  801b07:	c9                   	leave  
  801b08:	c3                   	ret    

00801b09 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	56                   	push   %esi
  801b0d:	53                   	push   %ebx
  801b0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b11:	83 ec 0c             	sub    $0xc,%esp
  801b14:	ff 75 08             	pushl  0x8(%ebp)
  801b17:	e8 aa f7 ff ff       	call   8012c6 <fd2data>
  801b1c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b1e:	83 c4 08             	add    $0x8,%esp
  801b21:	68 0d 2a 80 00       	push   $0x802a0d
  801b26:	53                   	push   %ebx
  801b27:	e8 17 ee ff ff       	call   800943 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b2c:	8b 46 04             	mov    0x4(%esi),%eax
  801b2f:	2b 06                	sub    (%esi),%eax
  801b31:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b37:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b3e:	00 00 00 
	stat->st_dev = &devpipe;
  801b41:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b48:	30 80 00 
	return 0;
}
  801b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5e                   	pop    %esi
  801b55:	5d                   	pop    %ebp
  801b56:	c3                   	ret    

00801b57 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	53                   	push   %ebx
  801b5b:	83 ec 0c             	sub    $0xc,%esp
  801b5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b61:	53                   	push   %ebx
  801b62:	6a 00                	push   $0x0
  801b64:	e8 d9 f2 ff ff       	call   800e42 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b69:	89 1c 24             	mov    %ebx,(%esp)
  801b6c:	e8 55 f7 ff ff       	call   8012c6 <fd2data>
  801b71:	83 c4 08             	add    $0x8,%esp
  801b74:	50                   	push   %eax
  801b75:	6a 00                	push   $0x0
  801b77:	e8 c6 f2 ff ff       	call   800e42 <sys_page_unmap>
}
  801b7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b7f:	c9                   	leave  
  801b80:	c3                   	ret    

00801b81 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	57                   	push   %edi
  801b85:	56                   	push   %esi
  801b86:	53                   	push   %ebx
  801b87:	83 ec 1c             	sub    $0x1c,%esp
  801b8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b8d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b8f:	a1 08 40 80 00       	mov    0x804008,%eax
  801b94:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b97:	83 ec 0c             	sub    $0xc,%esp
  801b9a:	ff 75 e0             	pushl  -0x20(%ebp)
  801b9d:	e8 cd 05 00 00       	call   80216f <pageref>
  801ba2:	89 c3                	mov    %eax,%ebx
  801ba4:	89 3c 24             	mov    %edi,(%esp)
  801ba7:	e8 c3 05 00 00       	call   80216f <pageref>
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	39 c3                	cmp    %eax,%ebx
  801bb1:	0f 94 c1             	sete   %cl
  801bb4:	0f b6 c9             	movzbl %cl,%ecx
  801bb7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bba:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801bc0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bc3:	39 ce                	cmp    %ecx,%esi
  801bc5:	74 1b                	je     801be2 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bc7:	39 c3                	cmp    %eax,%ebx
  801bc9:	75 c4                	jne    801b8f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bcb:	8b 42 58             	mov    0x58(%edx),%eax
  801bce:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bd1:	50                   	push   %eax
  801bd2:	56                   	push   %esi
  801bd3:	68 14 2a 80 00       	push   $0x802a14
  801bd8:	e8 32 e7 ff ff       	call   80030f <cprintf>
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	eb ad                	jmp    801b8f <_pipeisclosed+0xe>
	}
}
  801be2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801be5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be8:	5b                   	pop    %ebx
  801be9:	5e                   	pop    %esi
  801bea:	5f                   	pop    %edi
  801beb:	5d                   	pop    %ebp
  801bec:	c3                   	ret    

00801bed <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	57                   	push   %edi
  801bf1:	56                   	push   %esi
  801bf2:	53                   	push   %ebx
  801bf3:	83 ec 28             	sub    $0x28,%esp
  801bf6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bf9:	56                   	push   %esi
  801bfa:	e8 c7 f6 ff ff       	call   8012c6 <fd2data>
  801bff:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	bf 00 00 00 00       	mov    $0x0,%edi
  801c09:	eb 4b                	jmp    801c56 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c0b:	89 da                	mov    %ebx,%edx
  801c0d:	89 f0                	mov    %esi,%eax
  801c0f:	e8 6d ff ff ff       	call   801b81 <_pipeisclosed>
  801c14:	85 c0                	test   %eax,%eax
  801c16:	75 48                	jne    801c60 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c18:	e8 81 f1 ff ff       	call   800d9e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c1d:	8b 43 04             	mov    0x4(%ebx),%eax
  801c20:	8b 0b                	mov    (%ebx),%ecx
  801c22:	8d 51 20             	lea    0x20(%ecx),%edx
  801c25:	39 d0                	cmp    %edx,%eax
  801c27:	73 e2                	jae    801c0b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c2c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c30:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c33:	89 c2                	mov    %eax,%edx
  801c35:	c1 fa 1f             	sar    $0x1f,%edx
  801c38:	89 d1                	mov    %edx,%ecx
  801c3a:	c1 e9 1b             	shr    $0x1b,%ecx
  801c3d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c40:	83 e2 1f             	and    $0x1f,%edx
  801c43:	29 ca                	sub    %ecx,%edx
  801c45:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c49:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c4d:	83 c0 01             	add    $0x1,%eax
  801c50:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c53:	83 c7 01             	add    $0x1,%edi
  801c56:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c59:	75 c2                	jne    801c1d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c5e:	eb 05                	jmp    801c65 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c60:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c68:	5b                   	pop    %ebx
  801c69:	5e                   	pop    %esi
  801c6a:	5f                   	pop    %edi
  801c6b:	5d                   	pop    %ebp
  801c6c:	c3                   	ret    

00801c6d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	57                   	push   %edi
  801c71:	56                   	push   %esi
  801c72:	53                   	push   %ebx
  801c73:	83 ec 18             	sub    $0x18,%esp
  801c76:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c79:	57                   	push   %edi
  801c7a:	e8 47 f6 ff ff       	call   8012c6 <fd2data>
  801c7f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c89:	eb 3d                	jmp    801cc8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c8b:	85 db                	test   %ebx,%ebx
  801c8d:	74 04                	je     801c93 <devpipe_read+0x26>
				return i;
  801c8f:	89 d8                	mov    %ebx,%eax
  801c91:	eb 44                	jmp    801cd7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c93:	89 f2                	mov    %esi,%edx
  801c95:	89 f8                	mov    %edi,%eax
  801c97:	e8 e5 fe ff ff       	call   801b81 <_pipeisclosed>
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	75 32                	jne    801cd2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ca0:	e8 f9 f0 ff ff       	call   800d9e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ca5:	8b 06                	mov    (%esi),%eax
  801ca7:	3b 46 04             	cmp    0x4(%esi),%eax
  801caa:	74 df                	je     801c8b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cac:	99                   	cltd   
  801cad:	c1 ea 1b             	shr    $0x1b,%edx
  801cb0:	01 d0                	add    %edx,%eax
  801cb2:	83 e0 1f             	and    $0x1f,%eax
  801cb5:	29 d0                	sub    %edx,%eax
  801cb7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cbf:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cc2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc5:	83 c3 01             	add    $0x1,%ebx
  801cc8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ccb:	75 d8                	jne    801ca5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ccd:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd0:	eb 05                	jmp    801cd7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cd2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cda:	5b                   	pop    %ebx
  801cdb:	5e                   	pop    %esi
  801cdc:	5f                   	pop    %edi
  801cdd:	5d                   	pop    %ebp
  801cde:	c3                   	ret    

00801cdf <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ce7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cea:	50                   	push   %eax
  801ceb:	e8 ed f5 ff ff       	call   8012dd <fd_alloc>
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	89 c2                	mov    %eax,%edx
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	0f 88 2c 01 00 00    	js     801e29 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfd:	83 ec 04             	sub    $0x4,%esp
  801d00:	68 07 04 00 00       	push   $0x407
  801d05:	ff 75 f4             	pushl  -0xc(%ebp)
  801d08:	6a 00                	push   $0x0
  801d0a:	e8 ae f0 ff ff       	call   800dbd <sys_page_alloc>
  801d0f:	83 c4 10             	add    $0x10,%esp
  801d12:	89 c2                	mov    %eax,%edx
  801d14:	85 c0                	test   %eax,%eax
  801d16:	0f 88 0d 01 00 00    	js     801e29 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d1c:	83 ec 0c             	sub    $0xc,%esp
  801d1f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d22:	50                   	push   %eax
  801d23:	e8 b5 f5 ff ff       	call   8012dd <fd_alloc>
  801d28:	89 c3                	mov    %eax,%ebx
  801d2a:	83 c4 10             	add    $0x10,%esp
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	0f 88 e2 00 00 00    	js     801e17 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d35:	83 ec 04             	sub    $0x4,%esp
  801d38:	68 07 04 00 00       	push   $0x407
  801d3d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d40:	6a 00                	push   $0x0
  801d42:	e8 76 f0 ff ff       	call   800dbd <sys_page_alloc>
  801d47:	89 c3                	mov    %eax,%ebx
  801d49:	83 c4 10             	add    $0x10,%esp
  801d4c:	85 c0                	test   %eax,%eax
  801d4e:	0f 88 c3 00 00 00    	js     801e17 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d54:	83 ec 0c             	sub    $0xc,%esp
  801d57:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5a:	e8 67 f5 ff ff       	call   8012c6 <fd2data>
  801d5f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d61:	83 c4 0c             	add    $0xc,%esp
  801d64:	68 07 04 00 00       	push   $0x407
  801d69:	50                   	push   %eax
  801d6a:	6a 00                	push   $0x0
  801d6c:	e8 4c f0 ff ff       	call   800dbd <sys_page_alloc>
  801d71:	89 c3                	mov    %eax,%ebx
  801d73:	83 c4 10             	add    $0x10,%esp
  801d76:	85 c0                	test   %eax,%eax
  801d78:	0f 88 89 00 00 00    	js     801e07 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d7e:	83 ec 0c             	sub    $0xc,%esp
  801d81:	ff 75 f0             	pushl  -0x10(%ebp)
  801d84:	e8 3d f5 ff ff       	call   8012c6 <fd2data>
  801d89:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d90:	50                   	push   %eax
  801d91:	6a 00                	push   $0x0
  801d93:	56                   	push   %esi
  801d94:	6a 00                	push   $0x0
  801d96:	e8 65 f0 ff ff       	call   800e00 <sys_page_map>
  801d9b:	89 c3                	mov    %eax,%ebx
  801d9d:	83 c4 20             	add    $0x20,%esp
  801da0:	85 c0                	test   %eax,%eax
  801da2:	78 55                	js     801df9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801da4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dad:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801db9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dce:	83 ec 0c             	sub    $0xc,%esp
  801dd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd4:	e8 dd f4 ff ff       	call   8012b6 <fd2num>
  801dd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ddc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dde:	83 c4 04             	add    $0x4,%esp
  801de1:	ff 75 f0             	pushl  -0x10(%ebp)
  801de4:	e8 cd f4 ff ff       	call   8012b6 <fd2num>
  801de9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dec:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801def:	83 c4 10             	add    $0x10,%esp
  801df2:	ba 00 00 00 00       	mov    $0x0,%edx
  801df7:	eb 30                	jmp    801e29 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801df9:	83 ec 08             	sub    $0x8,%esp
  801dfc:	56                   	push   %esi
  801dfd:	6a 00                	push   $0x0
  801dff:	e8 3e f0 ff ff       	call   800e42 <sys_page_unmap>
  801e04:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e07:	83 ec 08             	sub    $0x8,%esp
  801e0a:	ff 75 f0             	pushl  -0x10(%ebp)
  801e0d:	6a 00                	push   $0x0
  801e0f:	e8 2e f0 ff ff       	call   800e42 <sys_page_unmap>
  801e14:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e17:	83 ec 08             	sub    $0x8,%esp
  801e1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1d:	6a 00                	push   $0x0
  801e1f:	e8 1e f0 ff ff       	call   800e42 <sys_page_unmap>
  801e24:	83 c4 10             	add    $0x10,%esp
  801e27:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e29:	89 d0                	mov    %edx,%eax
  801e2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2e:	5b                   	pop    %ebx
  801e2f:	5e                   	pop    %esi
  801e30:	5d                   	pop    %ebp
  801e31:	c3                   	ret    

00801e32 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3b:	50                   	push   %eax
  801e3c:	ff 75 08             	pushl  0x8(%ebp)
  801e3f:	e8 e8 f4 ff ff       	call   80132c <fd_lookup>
  801e44:	83 c4 10             	add    $0x10,%esp
  801e47:	85 c0                	test   %eax,%eax
  801e49:	78 18                	js     801e63 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e4b:	83 ec 0c             	sub    $0xc,%esp
  801e4e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e51:	e8 70 f4 ff ff       	call   8012c6 <fd2data>
	return _pipeisclosed(fd, p);
  801e56:	89 c2                	mov    %eax,%edx
  801e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5b:	e8 21 fd ff ff       	call   801b81 <_pipeisclosed>
  801e60:	83 c4 10             	add    $0x10,%esp
}
  801e63:	c9                   	leave  
  801e64:	c3                   	ret    

00801e65 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e65:	55                   	push   %ebp
  801e66:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e68:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6d:	5d                   	pop    %ebp
  801e6e:	c3                   	ret    

00801e6f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e75:	68 2c 2a 80 00       	push   $0x802a2c
  801e7a:	ff 75 0c             	pushl  0xc(%ebp)
  801e7d:	e8 c1 ea ff ff       	call   800943 <strcpy>
	return 0;
}
  801e82:	b8 00 00 00 00       	mov    $0x0,%eax
  801e87:	c9                   	leave  
  801e88:	c3                   	ret    

00801e89 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	57                   	push   %edi
  801e8d:	56                   	push   %esi
  801e8e:	53                   	push   %ebx
  801e8f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e95:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e9a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ea0:	eb 2d                	jmp    801ecf <devcons_write+0x46>
		m = n - tot;
  801ea2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ea5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ea7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801eaa:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801eaf:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eb2:	83 ec 04             	sub    $0x4,%esp
  801eb5:	53                   	push   %ebx
  801eb6:	03 45 0c             	add    0xc(%ebp),%eax
  801eb9:	50                   	push   %eax
  801eba:	57                   	push   %edi
  801ebb:	e8 15 ec ff ff       	call   800ad5 <memmove>
		sys_cputs(buf, m);
  801ec0:	83 c4 08             	add    $0x8,%esp
  801ec3:	53                   	push   %ebx
  801ec4:	57                   	push   %edi
  801ec5:	e8 37 ee ff ff       	call   800d01 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eca:	01 de                	add    %ebx,%esi
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	89 f0                	mov    %esi,%eax
  801ed1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ed4:	72 cc                	jb     801ea2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ed6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed9:	5b                   	pop    %ebx
  801eda:	5e                   	pop    %esi
  801edb:	5f                   	pop    %edi
  801edc:	5d                   	pop    %ebp
  801edd:	c3                   	ret    

00801ede <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	83 ec 08             	sub    $0x8,%esp
  801ee4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ee9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eed:	74 2a                	je     801f19 <devcons_read+0x3b>
  801eef:	eb 05                	jmp    801ef6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ef1:	e8 a8 ee ff ff       	call   800d9e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ef6:	e8 24 ee ff ff       	call   800d1f <sys_cgetc>
  801efb:	85 c0                	test   %eax,%eax
  801efd:	74 f2                	je     801ef1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801eff:	85 c0                	test   %eax,%eax
  801f01:	78 16                	js     801f19 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f03:	83 f8 04             	cmp    $0x4,%eax
  801f06:	74 0c                	je     801f14 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f08:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f0b:	88 02                	mov    %al,(%edx)
	return 1;
  801f0d:	b8 01 00 00 00       	mov    $0x1,%eax
  801f12:	eb 05                	jmp    801f19 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f14:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f19:	c9                   	leave  
  801f1a:	c3                   	ret    

00801f1b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f21:	8b 45 08             	mov    0x8(%ebp),%eax
  801f24:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f27:	6a 01                	push   $0x1
  801f29:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f2c:	50                   	push   %eax
  801f2d:	e8 cf ed ff ff       	call   800d01 <sys_cputs>
}
  801f32:	83 c4 10             	add    $0x10,%esp
  801f35:	c9                   	leave  
  801f36:	c3                   	ret    

00801f37 <getchar>:

int
getchar(void)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f3d:	6a 01                	push   $0x1
  801f3f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f42:	50                   	push   %eax
  801f43:	6a 00                	push   $0x0
  801f45:	e8 48 f6 ff ff       	call   801592 <read>
	if (r < 0)
  801f4a:	83 c4 10             	add    $0x10,%esp
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	78 0f                	js     801f60 <getchar+0x29>
		return r;
	if (r < 1)
  801f51:	85 c0                	test   %eax,%eax
  801f53:	7e 06                	jle    801f5b <getchar+0x24>
		return -E_EOF;
	return c;
  801f55:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f59:	eb 05                	jmp    801f60 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f5b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f60:	c9                   	leave  
  801f61:	c3                   	ret    

00801f62 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f62:	55                   	push   %ebp
  801f63:	89 e5                	mov    %esp,%ebp
  801f65:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f6b:	50                   	push   %eax
  801f6c:	ff 75 08             	pushl  0x8(%ebp)
  801f6f:	e8 b8 f3 ff ff       	call   80132c <fd_lookup>
  801f74:	83 c4 10             	add    $0x10,%esp
  801f77:	85 c0                	test   %eax,%eax
  801f79:	78 11                	js     801f8c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f84:	39 10                	cmp    %edx,(%eax)
  801f86:	0f 94 c0             	sete   %al
  801f89:	0f b6 c0             	movzbl %al,%eax
}
  801f8c:	c9                   	leave  
  801f8d:	c3                   	ret    

00801f8e <opencons>:

int
opencons(void)
{
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f97:	50                   	push   %eax
  801f98:	e8 40 f3 ff ff       	call   8012dd <fd_alloc>
  801f9d:	83 c4 10             	add    $0x10,%esp
		return r;
  801fa0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fa2:	85 c0                	test   %eax,%eax
  801fa4:	78 3e                	js     801fe4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fa6:	83 ec 04             	sub    $0x4,%esp
  801fa9:	68 07 04 00 00       	push   $0x407
  801fae:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb1:	6a 00                	push   $0x0
  801fb3:	e8 05 ee ff ff       	call   800dbd <sys_page_alloc>
  801fb8:	83 c4 10             	add    $0x10,%esp
		return r;
  801fbb:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	78 23                	js     801fe4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fc1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fca:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fd6:	83 ec 0c             	sub    $0xc,%esp
  801fd9:	50                   	push   %eax
  801fda:	e8 d7 f2 ff ff       	call   8012b6 <fd2num>
  801fdf:	89 c2                	mov    %eax,%edx
  801fe1:	83 c4 10             	add    $0x10,%esp
}
  801fe4:	89 d0                	mov    %edx,%eax
  801fe6:	c9                   	leave  
  801fe7:	c3                   	ret    

00801fe8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801fee:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ff5:	75 52                	jne    802049 <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  801ff7:	83 ec 04             	sub    $0x4,%esp
  801ffa:	6a 07                	push   $0x7
  801ffc:	68 00 f0 bf ee       	push   $0xeebff000
  802001:	6a 00                	push   $0x0
  802003:	e8 b5 ed ff ff       	call   800dbd <sys_page_alloc>
  802008:	83 c4 10             	add    $0x10,%esp
  80200b:	85 c0                	test   %eax,%eax
  80200d:	79 12                	jns    802021 <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  80200f:	50                   	push   %eax
  802010:	68 80 28 80 00       	push   $0x802880
  802015:	6a 23                	push   $0x23
  802017:	68 38 2a 80 00       	push   $0x802a38
  80201c:	e8 15 e2 ff ff       	call   800236 <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  802021:	83 ec 08             	sub    $0x8,%esp
  802024:	68 53 20 80 00       	push   $0x802053
  802029:	6a 00                	push   $0x0
  80202b:	e8 d8 ee ff ff       	call   800f08 <sys_env_set_pgfault_upcall>
  802030:	83 c4 10             	add    $0x10,%esp
  802033:	85 c0                	test   %eax,%eax
  802035:	79 12                	jns    802049 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  802037:	50                   	push   %eax
  802038:	68 00 29 80 00       	push   $0x802900
  80203d:	6a 26                	push   $0x26
  80203f:	68 38 2a 80 00       	push   $0x802a38
  802044:	e8 ed e1 ff ff       	call   800236 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802049:	8b 45 08             	mov    0x8(%ebp),%eax
  80204c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802051:	c9                   	leave  
  802052:	c3                   	ret    

00802053 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802053:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802054:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802059:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80205b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  80205e:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  802062:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  802067:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  80206b:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80206d:	83 c4 08             	add    $0x8,%esp
	popal 
  802070:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802071:	83 c4 04             	add    $0x4,%esp
	popfl
  802074:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802075:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802076:	c3                   	ret    

00802077 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802077:	55                   	push   %ebp
  802078:	89 e5                	mov    %esp,%ebp
  80207a:	56                   	push   %esi
  80207b:	53                   	push   %ebx
  80207c:	8b 75 08             	mov    0x8(%ebp),%esi
  80207f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802082:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  802085:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802087:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80208c:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  80208f:	83 ec 0c             	sub    $0xc,%esp
  802092:	50                   	push   %eax
  802093:	e8 d5 ee ff ff       	call   800f6d <sys_ipc_recv>
  802098:	83 c4 10             	add    $0x10,%esp
  80209b:	85 c0                	test   %eax,%eax
  80209d:	79 16                	jns    8020b5 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  80209f:	85 f6                	test   %esi,%esi
  8020a1:	74 06                	je     8020a9 <ipc_recv+0x32>
			*from_env_store = 0;
  8020a3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  8020a9:	85 db                	test   %ebx,%ebx
  8020ab:	74 2c                	je     8020d9 <ipc_recv+0x62>
			*perm_store = 0;
  8020ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020b3:	eb 24                	jmp    8020d9 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  8020b5:	85 f6                	test   %esi,%esi
  8020b7:	74 0a                	je     8020c3 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  8020b9:	a1 08 40 80 00       	mov    0x804008,%eax
  8020be:	8b 40 74             	mov    0x74(%eax),%eax
  8020c1:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  8020c3:	85 db                	test   %ebx,%ebx
  8020c5:	74 0a                	je     8020d1 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  8020c7:	a1 08 40 80 00       	mov    0x804008,%eax
  8020cc:	8b 40 78             	mov    0x78(%eax),%eax
  8020cf:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  8020d1:	a1 08 40 80 00       	mov    0x804008,%eax
  8020d6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020dc:	5b                   	pop    %ebx
  8020dd:	5e                   	pop    %esi
  8020de:	5d                   	pop    %ebp
  8020df:	c3                   	ret    

008020e0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	57                   	push   %edi
  8020e4:	56                   	push   %esi
  8020e5:	53                   	push   %ebx
  8020e6:	83 ec 0c             	sub    $0xc,%esp
  8020e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8020f2:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8020f4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020f9:	0f 44 d8             	cmove  %eax,%ebx
  8020fc:	eb 1e                	jmp    80211c <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  8020fe:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802101:	74 14                	je     802117 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  802103:	83 ec 04             	sub    $0x4,%esp
  802106:	68 48 2a 80 00       	push   $0x802a48
  80210b:	6a 44                	push   $0x44
  80210d:	68 74 2a 80 00       	push   $0x802a74
  802112:	e8 1f e1 ff ff       	call   800236 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  802117:	e8 82 ec ff ff       	call   800d9e <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80211c:	ff 75 14             	pushl  0x14(%ebp)
  80211f:	53                   	push   %ebx
  802120:	56                   	push   %esi
  802121:	57                   	push   %edi
  802122:	e8 23 ee ff ff       	call   800f4a <sys_ipc_try_send>
  802127:	83 c4 10             	add    $0x10,%esp
  80212a:	85 c0                	test   %eax,%eax
  80212c:	78 d0                	js     8020fe <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  80212e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802131:	5b                   	pop    %ebx
  802132:	5e                   	pop    %esi
  802133:	5f                   	pop    %edi
  802134:	5d                   	pop    %ebp
  802135:	c3                   	ret    

00802136 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802136:	55                   	push   %ebp
  802137:	89 e5                	mov    %esp,%ebp
  802139:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80213c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802141:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802144:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80214a:	8b 52 50             	mov    0x50(%edx),%edx
  80214d:	39 ca                	cmp    %ecx,%edx
  80214f:	75 0d                	jne    80215e <ipc_find_env+0x28>
			return envs[i].env_id;
  802151:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802154:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802159:	8b 40 48             	mov    0x48(%eax),%eax
  80215c:	eb 0f                	jmp    80216d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80215e:	83 c0 01             	add    $0x1,%eax
  802161:	3d 00 04 00 00       	cmp    $0x400,%eax
  802166:	75 d9                	jne    802141 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802168:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80216d:	5d                   	pop    %ebp
  80216e:	c3                   	ret    

0080216f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80216f:	55                   	push   %ebp
  802170:	89 e5                	mov    %esp,%ebp
  802172:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802175:	89 d0                	mov    %edx,%eax
  802177:	c1 e8 16             	shr    $0x16,%eax
  80217a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802181:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802186:	f6 c1 01             	test   $0x1,%cl
  802189:	74 1d                	je     8021a8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80218b:	c1 ea 0c             	shr    $0xc,%edx
  80218e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802195:	f6 c2 01             	test   $0x1,%dl
  802198:	74 0e                	je     8021a8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80219a:	c1 ea 0c             	shr    $0xc,%edx
  80219d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021a4:	ef 
  8021a5:	0f b7 c0             	movzwl %ax,%eax
}
  8021a8:	5d                   	pop    %ebp
  8021a9:	c3                   	ret    
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__udivdi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
  8021b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021c7:	85 f6                	test   %esi,%esi
  8021c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021cd:	89 ca                	mov    %ecx,%edx
  8021cf:	89 f8                	mov    %edi,%eax
  8021d1:	75 3d                	jne    802210 <__udivdi3+0x60>
  8021d3:	39 cf                	cmp    %ecx,%edi
  8021d5:	0f 87 c5 00 00 00    	ja     8022a0 <__udivdi3+0xf0>
  8021db:	85 ff                	test   %edi,%edi
  8021dd:	89 fd                	mov    %edi,%ebp
  8021df:	75 0b                	jne    8021ec <__udivdi3+0x3c>
  8021e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021e6:	31 d2                	xor    %edx,%edx
  8021e8:	f7 f7                	div    %edi
  8021ea:	89 c5                	mov    %eax,%ebp
  8021ec:	89 c8                	mov    %ecx,%eax
  8021ee:	31 d2                	xor    %edx,%edx
  8021f0:	f7 f5                	div    %ebp
  8021f2:	89 c1                	mov    %eax,%ecx
  8021f4:	89 d8                	mov    %ebx,%eax
  8021f6:	89 cf                	mov    %ecx,%edi
  8021f8:	f7 f5                	div    %ebp
  8021fa:	89 c3                	mov    %eax,%ebx
  8021fc:	89 d8                	mov    %ebx,%eax
  8021fe:	89 fa                	mov    %edi,%edx
  802200:	83 c4 1c             	add    $0x1c,%esp
  802203:	5b                   	pop    %ebx
  802204:	5e                   	pop    %esi
  802205:	5f                   	pop    %edi
  802206:	5d                   	pop    %ebp
  802207:	c3                   	ret    
  802208:	90                   	nop
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	39 ce                	cmp    %ecx,%esi
  802212:	77 74                	ja     802288 <__udivdi3+0xd8>
  802214:	0f bd fe             	bsr    %esi,%edi
  802217:	83 f7 1f             	xor    $0x1f,%edi
  80221a:	0f 84 98 00 00 00    	je     8022b8 <__udivdi3+0x108>
  802220:	bb 20 00 00 00       	mov    $0x20,%ebx
  802225:	89 f9                	mov    %edi,%ecx
  802227:	89 c5                	mov    %eax,%ebp
  802229:	29 fb                	sub    %edi,%ebx
  80222b:	d3 e6                	shl    %cl,%esi
  80222d:	89 d9                	mov    %ebx,%ecx
  80222f:	d3 ed                	shr    %cl,%ebp
  802231:	89 f9                	mov    %edi,%ecx
  802233:	d3 e0                	shl    %cl,%eax
  802235:	09 ee                	or     %ebp,%esi
  802237:	89 d9                	mov    %ebx,%ecx
  802239:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80223d:	89 d5                	mov    %edx,%ebp
  80223f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802243:	d3 ed                	shr    %cl,%ebp
  802245:	89 f9                	mov    %edi,%ecx
  802247:	d3 e2                	shl    %cl,%edx
  802249:	89 d9                	mov    %ebx,%ecx
  80224b:	d3 e8                	shr    %cl,%eax
  80224d:	09 c2                	or     %eax,%edx
  80224f:	89 d0                	mov    %edx,%eax
  802251:	89 ea                	mov    %ebp,%edx
  802253:	f7 f6                	div    %esi
  802255:	89 d5                	mov    %edx,%ebp
  802257:	89 c3                	mov    %eax,%ebx
  802259:	f7 64 24 0c          	mull   0xc(%esp)
  80225d:	39 d5                	cmp    %edx,%ebp
  80225f:	72 10                	jb     802271 <__udivdi3+0xc1>
  802261:	8b 74 24 08          	mov    0x8(%esp),%esi
  802265:	89 f9                	mov    %edi,%ecx
  802267:	d3 e6                	shl    %cl,%esi
  802269:	39 c6                	cmp    %eax,%esi
  80226b:	73 07                	jae    802274 <__udivdi3+0xc4>
  80226d:	39 d5                	cmp    %edx,%ebp
  80226f:	75 03                	jne    802274 <__udivdi3+0xc4>
  802271:	83 eb 01             	sub    $0x1,%ebx
  802274:	31 ff                	xor    %edi,%edi
  802276:	89 d8                	mov    %ebx,%eax
  802278:	89 fa                	mov    %edi,%edx
  80227a:	83 c4 1c             	add    $0x1c,%esp
  80227d:	5b                   	pop    %ebx
  80227e:	5e                   	pop    %esi
  80227f:	5f                   	pop    %edi
  802280:	5d                   	pop    %ebp
  802281:	c3                   	ret    
  802282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802288:	31 ff                	xor    %edi,%edi
  80228a:	31 db                	xor    %ebx,%ebx
  80228c:	89 d8                	mov    %ebx,%eax
  80228e:	89 fa                	mov    %edi,%edx
  802290:	83 c4 1c             	add    $0x1c,%esp
  802293:	5b                   	pop    %ebx
  802294:	5e                   	pop    %esi
  802295:	5f                   	pop    %edi
  802296:	5d                   	pop    %ebp
  802297:	c3                   	ret    
  802298:	90                   	nop
  802299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	89 d8                	mov    %ebx,%eax
  8022a2:	f7 f7                	div    %edi
  8022a4:	31 ff                	xor    %edi,%edi
  8022a6:	89 c3                	mov    %eax,%ebx
  8022a8:	89 d8                	mov    %ebx,%eax
  8022aa:	89 fa                	mov    %edi,%edx
  8022ac:	83 c4 1c             	add    $0x1c,%esp
  8022af:	5b                   	pop    %ebx
  8022b0:	5e                   	pop    %esi
  8022b1:	5f                   	pop    %edi
  8022b2:	5d                   	pop    %ebp
  8022b3:	c3                   	ret    
  8022b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022b8:	39 ce                	cmp    %ecx,%esi
  8022ba:	72 0c                	jb     8022c8 <__udivdi3+0x118>
  8022bc:	31 db                	xor    %ebx,%ebx
  8022be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022c2:	0f 87 34 ff ff ff    	ja     8021fc <__udivdi3+0x4c>
  8022c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022cd:	e9 2a ff ff ff       	jmp    8021fc <__udivdi3+0x4c>
  8022d2:	66 90                	xchg   %ax,%ax
  8022d4:	66 90                	xchg   %ax,%ax
  8022d6:	66 90                	xchg   %ax,%ax
  8022d8:	66 90                	xchg   %ax,%ax
  8022da:	66 90                	xchg   %ax,%ax
  8022dc:	66 90                	xchg   %ax,%ax
  8022de:	66 90                	xchg   %ax,%ax

008022e0 <__umoddi3>:
  8022e0:	55                   	push   %ebp
  8022e1:	57                   	push   %edi
  8022e2:	56                   	push   %esi
  8022e3:	53                   	push   %ebx
  8022e4:	83 ec 1c             	sub    $0x1c,%esp
  8022e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022f7:	85 d2                	test   %edx,%edx
  8022f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802301:	89 f3                	mov    %esi,%ebx
  802303:	89 3c 24             	mov    %edi,(%esp)
  802306:	89 74 24 04          	mov    %esi,0x4(%esp)
  80230a:	75 1c                	jne    802328 <__umoddi3+0x48>
  80230c:	39 f7                	cmp    %esi,%edi
  80230e:	76 50                	jbe    802360 <__umoddi3+0x80>
  802310:	89 c8                	mov    %ecx,%eax
  802312:	89 f2                	mov    %esi,%edx
  802314:	f7 f7                	div    %edi
  802316:	89 d0                	mov    %edx,%eax
  802318:	31 d2                	xor    %edx,%edx
  80231a:	83 c4 1c             	add    $0x1c,%esp
  80231d:	5b                   	pop    %ebx
  80231e:	5e                   	pop    %esi
  80231f:	5f                   	pop    %edi
  802320:	5d                   	pop    %ebp
  802321:	c3                   	ret    
  802322:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802328:	39 f2                	cmp    %esi,%edx
  80232a:	89 d0                	mov    %edx,%eax
  80232c:	77 52                	ja     802380 <__umoddi3+0xa0>
  80232e:	0f bd ea             	bsr    %edx,%ebp
  802331:	83 f5 1f             	xor    $0x1f,%ebp
  802334:	75 5a                	jne    802390 <__umoddi3+0xb0>
  802336:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80233a:	0f 82 e0 00 00 00    	jb     802420 <__umoddi3+0x140>
  802340:	39 0c 24             	cmp    %ecx,(%esp)
  802343:	0f 86 d7 00 00 00    	jbe    802420 <__umoddi3+0x140>
  802349:	8b 44 24 08          	mov    0x8(%esp),%eax
  80234d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802351:	83 c4 1c             	add    $0x1c,%esp
  802354:	5b                   	pop    %ebx
  802355:	5e                   	pop    %esi
  802356:	5f                   	pop    %edi
  802357:	5d                   	pop    %ebp
  802358:	c3                   	ret    
  802359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802360:	85 ff                	test   %edi,%edi
  802362:	89 fd                	mov    %edi,%ebp
  802364:	75 0b                	jne    802371 <__umoddi3+0x91>
  802366:	b8 01 00 00 00       	mov    $0x1,%eax
  80236b:	31 d2                	xor    %edx,%edx
  80236d:	f7 f7                	div    %edi
  80236f:	89 c5                	mov    %eax,%ebp
  802371:	89 f0                	mov    %esi,%eax
  802373:	31 d2                	xor    %edx,%edx
  802375:	f7 f5                	div    %ebp
  802377:	89 c8                	mov    %ecx,%eax
  802379:	f7 f5                	div    %ebp
  80237b:	89 d0                	mov    %edx,%eax
  80237d:	eb 99                	jmp    802318 <__umoddi3+0x38>
  80237f:	90                   	nop
  802380:	89 c8                	mov    %ecx,%eax
  802382:	89 f2                	mov    %esi,%edx
  802384:	83 c4 1c             	add    $0x1c,%esp
  802387:	5b                   	pop    %ebx
  802388:	5e                   	pop    %esi
  802389:	5f                   	pop    %edi
  80238a:	5d                   	pop    %ebp
  80238b:	c3                   	ret    
  80238c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802390:	8b 34 24             	mov    (%esp),%esi
  802393:	bf 20 00 00 00       	mov    $0x20,%edi
  802398:	89 e9                	mov    %ebp,%ecx
  80239a:	29 ef                	sub    %ebp,%edi
  80239c:	d3 e0                	shl    %cl,%eax
  80239e:	89 f9                	mov    %edi,%ecx
  8023a0:	89 f2                	mov    %esi,%edx
  8023a2:	d3 ea                	shr    %cl,%edx
  8023a4:	89 e9                	mov    %ebp,%ecx
  8023a6:	09 c2                	or     %eax,%edx
  8023a8:	89 d8                	mov    %ebx,%eax
  8023aa:	89 14 24             	mov    %edx,(%esp)
  8023ad:	89 f2                	mov    %esi,%edx
  8023af:	d3 e2                	shl    %cl,%edx
  8023b1:	89 f9                	mov    %edi,%ecx
  8023b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023bb:	d3 e8                	shr    %cl,%eax
  8023bd:	89 e9                	mov    %ebp,%ecx
  8023bf:	89 c6                	mov    %eax,%esi
  8023c1:	d3 e3                	shl    %cl,%ebx
  8023c3:	89 f9                	mov    %edi,%ecx
  8023c5:	89 d0                	mov    %edx,%eax
  8023c7:	d3 e8                	shr    %cl,%eax
  8023c9:	89 e9                	mov    %ebp,%ecx
  8023cb:	09 d8                	or     %ebx,%eax
  8023cd:	89 d3                	mov    %edx,%ebx
  8023cf:	89 f2                	mov    %esi,%edx
  8023d1:	f7 34 24             	divl   (%esp)
  8023d4:	89 d6                	mov    %edx,%esi
  8023d6:	d3 e3                	shl    %cl,%ebx
  8023d8:	f7 64 24 04          	mull   0x4(%esp)
  8023dc:	39 d6                	cmp    %edx,%esi
  8023de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023e2:	89 d1                	mov    %edx,%ecx
  8023e4:	89 c3                	mov    %eax,%ebx
  8023e6:	72 08                	jb     8023f0 <__umoddi3+0x110>
  8023e8:	75 11                	jne    8023fb <__umoddi3+0x11b>
  8023ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023ee:	73 0b                	jae    8023fb <__umoddi3+0x11b>
  8023f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023f4:	1b 14 24             	sbb    (%esp),%edx
  8023f7:	89 d1                	mov    %edx,%ecx
  8023f9:	89 c3                	mov    %eax,%ebx
  8023fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023ff:	29 da                	sub    %ebx,%edx
  802401:	19 ce                	sbb    %ecx,%esi
  802403:	89 f9                	mov    %edi,%ecx
  802405:	89 f0                	mov    %esi,%eax
  802407:	d3 e0                	shl    %cl,%eax
  802409:	89 e9                	mov    %ebp,%ecx
  80240b:	d3 ea                	shr    %cl,%edx
  80240d:	89 e9                	mov    %ebp,%ecx
  80240f:	d3 ee                	shr    %cl,%esi
  802411:	09 d0                	or     %edx,%eax
  802413:	89 f2                	mov    %esi,%edx
  802415:	83 c4 1c             	add    $0x1c,%esp
  802418:	5b                   	pop    %ebx
  802419:	5e                   	pop    %esi
  80241a:	5f                   	pop    %edi
  80241b:	5d                   	pop    %ebp
  80241c:	c3                   	ret    
  80241d:	8d 76 00             	lea    0x0(%esi),%esi
  802420:	29 f9                	sub    %edi,%ecx
  802422:	19 d6                	sbb    %edx,%esi
  802424:	89 74 24 04          	mov    %esi,0x4(%esp)
  802428:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80242c:	e9 18 ff ff ff       	jmp    802349 <__umoddi3+0x69>
