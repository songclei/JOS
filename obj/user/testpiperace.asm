
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
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
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 60 24 80 00       	push   $0x802460
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 d0 1d 00 00       	call   801e20 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 79 24 80 00       	push   $0x802479
  80005d:	6a 0d                	push   $0xd
  80005f:	68 82 24 80 00       	push   $0x802482
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 24 10 00 00       	call   801092 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 fe 28 80 00       	push   $0x8028fe
  80007a:	6a 10                	push   $0x10
  80007c:	68 82 24 80 00       	push   $0x802482
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 c7 14 00 00       	call   80155c <close>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a3:	e8 cb 1e 00 00       	call   801f73 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 96 24 80 00       	push   $0x802496
  8000b7:	e8 61 02 00 00       	call   80031d <cprintf>
				exit();
  8000bc:	e8 69 01 00 00       	call   80022a <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 e3 0c 00 00       	call   800dac <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000c9:	83 eb 01             	sub    $0x1,%ebx
  8000cc:	75 cf                	jne    80009d <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 00                	push   $0x0
  8000d3:	6a 00                	push   $0x0
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 e8 11 00 00       	call   8012c4 <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 b1 24 80 00       	push   $0x8024b1
  8000e8:	e8 30 02 00 00       	call   80031d <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6b c6 7c             	imul   $0x7c,%esi,%eax
  8000f9:	c1 f8 02             	sar    $0x2,%eax
  8000fc:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800102:	50                   	push   %eax
  800103:	68 bc 24 80 00       	push   $0x8024bc
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 92 14 00 00       	call   8015ac <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 77 14 00 00       	call   8015ac <dup>
  800135:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800138:	8b 53 54             	mov    0x54(%ebx),%edx
  80013b:	83 fa 02             	cmp    $0x2,%edx
  80013e:	74 e8                	je     800128 <umain+0xf5>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	68 c7 24 80 00       	push   $0x8024c7
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 1b 1e 00 00       	call   801f73 <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 20 25 80 00       	push   $0x802520
  800167:	6a 3a                	push   $0x3a
  800169:	68 82 24 80 00       	push   $0x802482
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 b0 12 00 00       	call   801432 <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 dd 24 80 00       	push   $0x8024dd
  80018f:	6a 3c                	push   $0x3c
  800191:	68 82 24 80 00       	push   $0x802482
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 26 12 00 00       	call   8013cc <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 61 1a 00 00       	call   801c0f <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 f5 24 80 00       	push   $0x8024f5
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 0b 25 80 00       	push   $0x80250b
  8001d5:	e8 43 01 00 00       	call   80031d <cprintf>
  8001da:	83 c4 10             	add    $0x10,%esp
}
  8001dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ef:	e8 99 0b 00 00       	call   800d8d <sys_getenvid>
  8001f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800201:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800206:	85 db                	test   %ebx,%ebx
  800208:	7e 07                	jle    800211 <libmain+0x2d>
		binaryname = argv[0];
  80020a:	8b 06                	mov    (%esi),%eax
  80020c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	e8 18 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80021b:	e8 0a 00 00 00       	call   80022a <exit>
}
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800230:	e8 52 13 00 00       	call   801587 <close_all>
	sys_env_destroy(0);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	6a 00                	push   $0x0
  80023a:	e8 0d 0b 00 00       	call   800d4c <sys_env_destroy>
}
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800252:	e8 36 0b 00 00       	call   800d8d <sys_getenvid>
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	56                   	push   %esi
  800261:	50                   	push   %eax
  800262:	68 54 25 80 00       	push   $0x802554
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 77 24 80 00 	movl   $0x802477,(%esp)
  80027f:	e8 99 00 00 00       	call   80031d <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800287:	cc                   	int3   
  800288:	eb fd                	jmp    800287 <_panic+0x43>

0080028a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	53                   	push   %ebx
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800294:	8b 13                	mov    (%ebx),%edx
  800296:	8d 42 01             	lea    0x1(%edx),%eax
  800299:	89 03                	mov    %eax,(%ebx)
  80029b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a7:	75 1a                	jne    8002c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	68 ff 00 00 00       	push   $0xff
  8002b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b4:	50                   	push   %eax
  8002b5:	e8 55 0a 00 00       	call   800d0f <sys_cputs>
		b->idx = 0;
  8002ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002dc:	00 00 00 
	b.cnt = 0;
  8002df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f5:	50                   	push   %eax
  8002f6:	68 8a 02 80 00       	push   $0x80028a
  8002fb:	e8 54 01 00 00       	call   800454 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	83 c4 08             	add    $0x8,%esp
  800303:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800309:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030f:	50                   	push   %eax
  800310:	e8 fa 09 00 00       	call   800d0f <sys_cputs>

	return b.cnt;
}
  800315:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800323:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	e8 9d ff ff ff       	call   8002cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 1c             	sub    $0x1c,%esp
  80033a:	89 c7                	mov    %eax,%edi
  80033c:	89 d6                	mov    %edx,%esi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	8b 55 0c             	mov    0xc(%ebp),%edx
  800344:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800347:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80034d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800352:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800355:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800358:	39 d3                	cmp    %edx,%ebx
  80035a:	72 05                	jb     800361 <printnum+0x30>
  80035c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80035f:	77 45                	ja     8003a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800361:	83 ec 0c             	sub    $0xc,%esp
  800364:	ff 75 18             	pushl  0x18(%ebp)
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80036d:	53                   	push   %ebx
  80036e:	ff 75 10             	pushl  0x10(%ebp)
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	ff 75 e4             	pushl  -0x1c(%ebp)
  800377:	ff 75 e0             	pushl  -0x20(%ebp)
  80037a:	ff 75 dc             	pushl  -0x24(%ebp)
  80037d:	ff 75 d8             	pushl  -0x28(%ebp)
  800380:	e8 3b 1e 00 00       	call   8021c0 <__udivdi3>
  800385:	83 c4 18             	add    $0x18,%esp
  800388:	52                   	push   %edx
  800389:	50                   	push   %eax
  80038a:	89 f2                	mov    %esi,%edx
  80038c:	89 f8                	mov    %edi,%eax
  80038e:	e8 9e ff ff ff       	call   800331 <printnum>
  800393:	83 c4 20             	add    $0x20,%esp
  800396:	eb 18                	jmp    8003b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	ff 75 18             	pushl  0x18(%ebp)
  80039f:	ff d7                	call   *%edi
  8003a1:	83 c4 10             	add    $0x10,%esp
  8003a4:	eb 03                	jmp    8003a9 <printnum+0x78>
  8003a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a9:	83 eb 01             	sub    $0x1,%ebx
  8003ac:	85 db                	test   %ebx,%ebx
  8003ae:	7f e8                	jg     800398 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b0:	83 ec 08             	sub    $0x8,%esp
  8003b3:	56                   	push   %esi
  8003b4:	83 ec 04             	sub    $0x4,%esp
  8003b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8003bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c3:	e8 28 1f 00 00       	call   8022f0 <__umoddi3>
  8003c8:	83 c4 14             	add    $0x14,%esp
  8003cb:	0f be 80 77 25 80 00 	movsbl 0x802577(%eax),%eax
  8003d2:	50                   	push   %eax
  8003d3:	ff d7                	call   *%edi
}
  8003d5:	83 c4 10             	add    $0x10,%esp
  8003d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003db:	5b                   	pop    %ebx
  8003dc:	5e                   	pop    %esi
  8003dd:	5f                   	pop    %edi
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e3:	83 fa 01             	cmp    $0x1,%edx
  8003e6:	7e 0e                	jle    8003f6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e8:	8b 10                	mov    (%eax),%edx
  8003ea:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ed:	89 08                	mov    %ecx,(%eax)
  8003ef:	8b 02                	mov    (%edx),%eax
  8003f1:	8b 52 04             	mov    0x4(%edx),%edx
  8003f4:	eb 22                	jmp    800418 <getuint+0x38>
	else if (lflag)
  8003f6:	85 d2                	test   %edx,%edx
  8003f8:	74 10                	je     80040a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003fa:	8b 10                	mov    (%eax),%edx
  8003fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ff:	89 08                	mov    %ecx,(%eax)
  800401:	8b 02                	mov    (%edx),%eax
  800403:	ba 00 00 00 00       	mov    $0x0,%edx
  800408:	eb 0e                	jmp    800418 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80040a:	8b 10                	mov    (%eax),%edx
  80040c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040f:	89 08                	mov    %ecx,(%eax)
  800411:	8b 02                	mov    (%edx),%eax
  800413:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800418:	5d                   	pop    %ebp
  800419:	c3                   	ret    

0080041a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800420:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800424:	8b 10                	mov    (%eax),%edx
  800426:	3b 50 04             	cmp    0x4(%eax),%edx
  800429:	73 0a                	jae    800435 <sprintputch+0x1b>
		*b->buf++ = ch;
  80042b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80042e:	89 08                	mov    %ecx,(%eax)
  800430:	8b 45 08             	mov    0x8(%ebp),%eax
  800433:	88 02                	mov    %al,(%edx)
}
  800435:	5d                   	pop    %ebp
  800436:	c3                   	ret    

00800437 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80043d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800440:	50                   	push   %eax
  800441:	ff 75 10             	pushl  0x10(%ebp)
  800444:	ff 75 0c             	pushl  0xc(%ebp)
  800447:	ff 75 08             	pushl  0x8(%ebp)
  80044a:	e8 05 00 00 00       	call   800454 <vprintfmt>
	va_end(ap);
}
  80044f:	83 c4 10             	add    $0x10,%esp
  800452:	c9                   	leave  
  800453:	c3                   	ret    

00800454 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	57                   	push   %edi
  800458:	56                   	push   %esi
  800459:	53                   	push   %ebx
  80045a:	83 ec 2c             	sub    $0x2c,%esp
  80045d:	8b 75 08             	mov    0x8(%ebp),%esi
  800460:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800463:	8b 7d 10             	mov    0x10(%ebp),%edi
  800466:	eb 12                	jmp    80047a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800468:	85 c0                	test   %eax,%eax
  80046a:	0f 84 38 04 00 00    	je     8008a8 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	53                   	push   %ebx
  800474:	50                   	push   %eax
  800475:	ff d6                	call   *%esi
  800477:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80047a:	83 c7 01             	add    $0x1,%edi
  80047d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800481:	83 f8 25             	cmp    $0x25,%eax
  800484:	75 e2                	jne    800468 <vprintfmt+0x14>
  800486:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80048a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800491:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800498:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80049f:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a4:	eb 07                	jmp    8004ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8d 47 01             	lea    0x1(%edi),%eax
  8004b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b3:	0f b6 07             	movzbl (%edi),%eax
  8004b6:	0f b6 c8             	movzbl %al,%ecx
  8004b9:	83 e8 23             	sub    $0x23,%eax
  8004bc:	3c 55                	cmp    $0x55,%al
  8004be:	0f 87 c9 03 00 00    	ja     80088d <vprintfmt+0x439>
  8004c4:	0f b6 c0             	movzbl %al,%eax
  8004c7:	ff 24 85 c0 26 80 00 	jmp    *0x8026c0(,%eax,4)
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004d5:	eb d6                	jmp    8004ad <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  8004d7:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  8004de:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  8004e4:	eb 94                	jmp    80047a <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  8004e6:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  8004ed:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  8004f3:	eb 85                	jmp    80047a <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  8004f5:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  8004fc:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  800502:	e9 73 ff ff ff       	jmp    80047a <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  800507:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  80050e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800511:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  800514:	e9 61 ff ff ff       	jmp    80047a <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  800519:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800520:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800523:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  800526:	e9 4f ff ff ff       	jmp    80047a <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80052b:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800532:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800535:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  800538:	e9 3d ff ff ff       	jmp    80047a <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  80053d:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  800544:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80054a:	e9 2b ff ff ff       	jmp    80047a <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  80054f:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  800556:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800559:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  80055c:	e9 19 ff ff ff       	jmp    80047a <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800561:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  800568:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  80056e:	e9 07 ff ff ff       	jmp    80047a <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  800573:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  80057a:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800580:	e9 f5 fe ff ff       	jmp    80047a <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800585:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800588:	b8 00 00 00 00       	mov    $0x0,%eax
  80058d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800590:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800593:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800597:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80059a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80059d:	83 fa 09             	cmp    $0x9,%edx
  8005a0:	77 3f                	ja     8005e1 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005a5:	eb e9                	jmp    800590 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8d 48 04             	lea    0x4(%eax),%ecx
  8005ad:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005b0:	8b 00                	mov    (%eax),%eax
  8005b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005b8:	eb 2d                	jmp    8005e7 <vprintfmt+0x193>
  8005ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005bd:	85 c0                	test   %eax,%eax
  8005bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c4:	0f 49 c8             	cmovns %eax,%ecx
  8005c7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005cd:	e9 db fe ff ff       	jmp    8004ad <vprintfmt+0x59>
  8005d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005d5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005dc:	e9 cc fe ff ff       	jmp    8004ad <vprintfmt+0x59>
  8005e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005e7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005eb:	0f 89 bc fe ff ff    	jns    8004ad <vprintfmt+0x59>
				width = precision, precision = -1;
  8005f1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005fe:	e9 aa fe ff ff       	jmp    8004ad <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800603:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800609:	e9 9f fe ff ff       	jmp    8004ad <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	ff 30                	pushl  (%eax)
  80061d:	ff d6                	call   *%esi
			break;
  80061f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800622:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800625:	e9 50 fe ff ff       	jmp    80047a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8d 50 04             	lea    0x4(%eax),%edx
  800630:	89 55 14             	mov    %edx,0x14(%ebp)
  800633:	8b 00                	mov    (%eax),%eax
  800635:	99                   	cltd   
  800636:	31 d0                	xor    %edx,%eax
  800638:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063a:	83 f8 0f             	cmp    $0xf,%eax
  80063d:	7f 0b                	jg     80064a <vprintfmt+0x1f6>
  80063f:	8b 14 85 20 28 80 00 	mov    0x802820(,%eax,4),%edx
  800646:	85 d2                	test   %edx,%edx
  800648:	75 18                	jne    800662 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80064a:	50                   	push   %eax
  80064b:	68 8f 25 80 00       	push   $0x80258f
  800650:	53                   	push   %ebx
  800651:	56                   	push   %esi
  800652:	e8 e0 fd ff ff       	call   800437 <printfmt>
  800657:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80065d:	e9 18 fe ff ff       	jmp    80047a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800662:	52                   	push   %edx
  800663:	68 3d 2a 80 00       	push   $0x802a3d
  800668:	53                   	push   %ebx
  800669:	56                   	push   %esi
  80066a:	e8 c8 fd ff ff       	call   800437 <printfmt>
  80066f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800672:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800675:	e9 00 fe ff ff       	jmp    80047a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 50 04             	lea    0x4(%eax),%edx
  800680:	89 55 14             	mov    %edx,0x14(%ebp)
  800683:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800685:	85 ff                	test   %edi,%edi
  800687:	b8 88 25 80 00       	mov    $0x802588,%eax
  80068c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80068f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800693:	0f 8e 94 00 00 00    	jle    80072d <vprintfmt+0x2d9>
  800699:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80069d:	0f 84 98 00 00 00    	je     80073b <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	ff 75 d0             	pushl  -0x30(%ebp)
  8006a9:	57                   	push   %edi
  8006aa:	e8 81 02 00 00       	call   800930 <strnlen>
  8006af:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006b2:	29 c1                	sub    %eax,%ecx
  8006b4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006b7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ba:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006c1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006c4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c6:	eb 0f                	jmp    8006d7 <vprintfmt+0x283>
					putch(padc, putdat);
  8006c8:	83 ec 08             	sub    $0x8,%esp
  8006cb:	53                   	push   %ebx
  8006cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d1:	83 ef 01             	sub    $0x1,%edi
  8006d4:	83 c4 10             	add    $0x10,%esp
  8006d7:	85 ff                	test   %edi,%edi
  8006d9:	7f ed                	jg     8006c8 <vprintfmt+0x274>
  8006db:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006de:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006e1:	85 c9                	test   %ecx,%ecx
  8006e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e8:	0f 49 c1             	cmovns %ecx,%eax
  8006eb:	29 c1                	sub    %eax,%ecx
  8006ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8006f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006f6:	89 cb                	mov    %ecx,%ebx
  8006f8:	eb 4d                	jmp    800747 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006fa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006fe:	74 1b                	je     80071b <vprintfmt+0x2c7>
  800700:	0f be c0             	movsbl %al,%eax
  800703:	83 e8 20             	sub    $0x20,%eax
  800706:	83 f8 5e             	cmp    $0x5e,%eax
  800709:	76 10                	jbe    80071b <vprintfmt+0x2c7>
					putch('?', putdat);
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	ff 75 0c             	pushl  0xc(%ebp)
  800711:	6a 3f                	push   $0x3f
  800713:	ff 55 08             	call   *0x8(%ebp)
  800716:	83 c4 10             	add    $0x10,%esp
  800719:	eb 0d                	jmp    800728 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  80071b:	83 ec 08             	sub    $0x8,%esp
  80071e:	ff 75 0c             	pushl  0xc(%ebp)
  800721:	52                   	push   %edx
  800722:	ff 55 08             	call   *0x8(%ebp)
  800725:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800728:	83 eb 01             	sub    $0x1,%ebx
  80072b:	eb 1a                	jmp    800747 <vprintfmt+0x2f3>
  80072d:	89 75 08             	mov    %esi,0x8(%ebp)
  800730:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800733:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800736:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800739:	eb 0c                	jmp    800747 <vprintfmt+0x2f3>
  80073b:	89 75 08             	mov    %esi,0x8(%ebp)
  80073e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800741:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800744:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800747:	83 c7 01             	add    $0x1,%edi
  80074a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80074e:	0f be d0             	movsbl %al,%edx
  800751:	85 d2                	test   %edx,%edx
  800753:	74 23                	je     800778 <vprintfmt+0x324>
  800755:	85 f6                	test   %esi,%esi
  800757:	78 a1                	js     8006fa <vprintfmt+0x2a6>
  800759:	83 ee 01             	sub    $0x1,%esi
  80075c:	79 9c                	jns    8006fa <vprintfmt+0x2a6>
  80075e:	89 df                	mov    %ebx,%edi
  800760:	8b 75 08             	mov    0x8(%ebp),%esi
  800763:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800766:	eb 18                	jmp    800780 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800768:	83 ec 08             	sub    $0x8,%esp
  80076b:	53                   	push   %ebx
  80076c:	6a 20                	push   $0x20
  80076e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800770:	83 ef 01             	sub    $0x1,%edi
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	eb 08                	jmp    800780 <vprintfmt+0x32c>
  800778:	89 df                	mov    %ebx,%edi
  80077a:	8b 75 08             	mov    0x8(%ebp),%esi
  80077d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800780:	85 ff                	test   %edi,%edi
  800782:	7f e4                	jg     800768 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800784:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800787:	e9 ee fc ff ff       	jmp    80047a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80078c:	83 fa 01             	cmp    $0x1,%edx
  80078f:	7e 16                	jle    8007a7 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 50 08             	lea    0x8(%eax),%edx
  800797:	89 55 14             	mov    %edx,0x14(%ebp)
  80079a:	8b 50 04             	mov    0x4(%eax),%edx
  80079d:	8b 00                	mov    (%eax),%eax
  80079f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a5:	eb 32                	jmp    8007d9 <vprintfmt+0x385>
	else if (lflag)
  8007a7:	85 d2                	test   %edx,%edx
  8007a9:	74 18                	je     8007c3 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 50 04             	lea    0x4(%eax),%edx
  8007b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b4:	8b 00                	mov    (%eax),%eax
  8007b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b9:	89 c1                	mov    %eax,%ecx
  8007bb:	c1 f9 1f             	sar    $0x1f,%ecx
  8007be:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007c1:	eb 16                	jmp    8007d9 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8d 50 04             	lea    0x4(%eax),%edx
  8007c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cc:	8b 00                	mov    (%eax),%eax
  8007ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d1:	89 c1                	mov    %eax,%ecx
  8007d3:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007df:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007e4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007e8:	79 6f                	jns    800859 <vprintfmt+0x405>
				putch('-', putdat);
  8007ea:	83 ec 08             	sub    $0x8,%esp
  8007ed:	53                   	push   %ebx
  8007ee:	6a 2d                	push   $0x2d
  8007f0:	ff d6                	call   *%esi
				num = -(long long) num;
  8007f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007f8:	f7 d8                	neg    %eax
  8007fa:	83 d2 00             	adc    $0x0,%edx
  8007fd:	f7 da                	neg    %edx
  8007ff:	83 c4 10             	add    $0x10,%esp
  800802:	eb 55                	jmp    800859 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800804:	8d 45 14             	lea    0x14(%ebp),%eax
  800807:	e8 d4 fb ff ff       	call   8003e0 <getuint>
			base = 10;
  80080c:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800811:	eb 46                	jmp    800859 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800813:	8d 45 14             	lea    0x14(%ebp),%eax
  800816:	e8 c5 fb ff ff       	call   8003e0 <getuint>
			base = 8;
  80081b:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800820:	eb 37                	jmp    800859 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800822:	83 ec 08             	sub    $0x8,%esp
  800825:	53                   	push   %ebx
  800826:	6a 30                	push   $0x30
  800828:	ff d6                	call   *%esi
			putch('x', putdat);
  80082a:	83 c4 08             	add    $0x8,%esp
  80082d:	53                   	push   %ebx
  80082e:	6a 78                	push   $0x78
  800830:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800832:	8b 45 14             	mov    0x14(%ebp),%eax
  800835:	8d 50 04             	lea    0x4(%eax),%edx
  800838:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80083b:	8b 00                	mov    (%eax),%eax
  80083d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800842:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800845:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80084a:	eb 0d                	jmp    800859 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80084c:	8d 45 14             	lea    0x14(%ebp),%eax
  80084f:	e8 8c fb ff ff       	call   8003e0 <getuint>
			base = 16;
  800854:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800859:	83 ec 0c             	sub    $0xc,%esp
  80085c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800860:	51                   	push   %ecx
  800861:	ff 75 e0             	pushl  -0x20(%ebp)
  800864:	57                   	push   %edi
  800865:	52                   	push   %edx
  800866:	50                   	push   %eax
  800867:	89 da                	mov    %ebx,%edx
  800869:	89 f0                	mov    %esi,%eax
  80086b:	e8 c1 fa ff ff       	call   800331 <printnum>
			break;
  800870:	83 c4 20             	add    $0x20,%esp
  800873:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800876:	e9 ff fb ff ff       	jmp    80047a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80087b:	83 ec 08             	sub    $0x8,%esp
  80087e:	53                   	push   %ebx
  80087f:	51                   	push   %ecx
  800880:	ff d6                	call   *%esi
			break;
  800882:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800885:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800888:	e9 ed fb ff ff       	jmp    80047a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80088d:	83 ec 08             	sub    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	6a 25                	push   $0x25
  800893:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800895:	83 c4 10             	add    $0x10,%esp
  800898:	eb 03                	jmp    80089d <vprintfmt+0x449>
  80089a:	83 ef 01             	sub    $0x1,%edi
  80089d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008a1:	75 f7                	jne    80089a <vprintfmt+0x446>
  8008a3:	e9 d2 fb ff ff       	jmp    80047a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008ab:	5b                   	pop    %ebx
  8008ac:	5e                   	pop    %esi
  8008ad:	5f                   	pop    %edi
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	83 ec 18             	sub    $0x18,%esp
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008bf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008c3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008cd:	85 c0                	test   %eax,%eax
  8008cf:	74 26                	je     8008f7 <vsnprintf+0x47>
  8008d1:	85 d2                	test   %edx,%edx
  8008d3:	7e 22                	jle    8008f7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008d5:	ff 75 14             	pushl  0x14(%ebp)
  8008d8:	ff 75 10             	pushl  0x10(%ebp)
  8008db:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008de:	50                   	push   %eax
  8008df:	68 1a 04 80 00       	push   $0x80041a
  8008e4:	e8 6b fb ff ff       	call   800454 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008ec:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f2:	83 c4 10             	add    $0x10,%esp
  8008f5:	eb 05                	jmp    8008fc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008fc:	c9                   	leave  
  8008fd:	c3                   	ret    

008008fe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800904:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800907:	50                   	push   %eax
  800908:	ff 75 10             	pushl  0x10(%ebp)
  80090b:	ff 75 0c             	pushl  0xc(%ebp)
  80090e:	ff 75 08             	pushl  0x8(%ebp)
  800911:	e8 9a ff ff ff       	call   8008b0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800916:	c9                   	leave  
  800917:	c3                   	ret    

00800918 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
  800923:	eb 03                	jmp    800928 <strlen+0x10>
		n++;
  800925:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800928:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80092c:	75 f7                	jne    800925 <strlen+0xd>
		n++;
	return n;
}
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800936:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800939:	ba 00 00 00 00       	mov    $0x0,%edx
  80093e:	eb 03                	jmp    800943 <strnlen+0x13>
		n++;
  800940:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800943:	39 c2                	cmp    %eax,%edx
  800945:	74 08                	je     80094f <strnlen+0x1f>
  800947:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80094b:	75 f3                	jne    800940 <strnlen+0x10>
  80094d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	53                   	push   %ebx
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80095b:	89 c2                	mov    %eax,%edx
  80095d:	83 c2 01             	add    $0x1,%edx
  800960:	83 c1 01             	add    $0x1,%ecx
  800963:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800967:	88 5a ff             	mov    %bl,-0x1(%edx)
  80096a:	84 db                	test   %bl,%bl
  80096c:	75 ef                	jne    80095d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80096e:	5b                   	pop    %ebx
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	53                   	push   %ebx
  800975:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800978:	53                   	push   %ebx
  800979:	e8 9a ff ff ff       	call   800918 <strlen>
  80097e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800981:	ff 75 0c             	pushl  0xc(%ebp)
  800984:	01 d8                	add    %ebx,%eax
  800986:	50                   	push   %eax
  800987:	e8 c5 ff ff ff       	call   800951 <strcpy>
	return dst;
}
  80098c:	89 d8                	mov    %ebx,%eax
  80098e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800991:	c9                   	leave  
  800992:	c3                   	ret    

00800993 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	56                   	push   %esi
  800997:	53                   	push   %ebx
  800998:	8b 75 08             	mov    0x8(%ebp),%esi
  80099b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80099e:	89 f3                	mov    %esi,%ebx
  8009a0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a3:	89 f2                	mov    %esi,%edx
  8009a5:	eb 0f                	jmp    8009b6 <strncpy+0x23>
		*dst++ = *src;
  8009a7:	83 c2 01             	add    $0x1,%edx
  8009aa:	0f b6 01             	movzbl (%ecx),%eax
  8009ad:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009b0:	80 39 01             	cmpb   $0x1,(%ecx)
  8009b3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b6:	39 da                	cmp    %ebx,%edx
  8009b8:	75 ed                	jne    8009a7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009ba:	89 f0                	mov    %esi,%eax
  8009bc:	5b                   	pop    %ebx
  8009bd:	5e                   	pop    %esi
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	56                   	push   %esi
  8009c4:	53                   	push   %ebx
  8009c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009cb:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ce:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d0:	85 d2                	test   %edx,%edx
  8009d2:	74 21                	je     8009f5 <strlcpy+0x35>
  8009d4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009d8:	89 f2                	mov    %esi,%edx
  8009da:	eb 09                	jmp    8009e5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009dc:	83 c2 01             	add    $0x1,%edx
  8009df:	83 c1 01             	add    $0x1,%ecx
  8009e2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009e5:	39 c2                	cmp    %eax,%edx
  8009e7:	74 09                	je     8009f2 <strlcpy+0x32>
  8009e9:	0f b6 19             	movzbl (%ecx),%ebx
  8009ec:	84 db                	test   %bl,%bl
  8009ee:	75 ec                	jne    8009dc <strlcpy+0x1c>
  8009f0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009f2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009f5:	29 f0                	sub    %esi,%eax
}
  8009f7:	5b                   	pop    %ebx
  8009f8:	5e                   	pop    %esi
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a01:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a04:	eb 06                	jmp    800a0c <strcmp+0x11>
		p++, q++;
  800a06:	83 c1 01             	add    $0x1,%ecx
  800a09:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a0c:	0f b6 01             	movzbl (%ecx),%eax
  800a0f:	84 c0                	test   %al,%al
  800a11:	74 04                	je     800a17 <strcmp+0x1c>
  800a13:	3a 02                	cmp    (%edx),%al
  800a15:	74 ef                	je     800a06 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a17:	0f b6 c0             	movzbl %al,%eax
  800a1a:	0f b6 12             	movzbl (%edx),%edx
  800a1d:	29 d0                	sub    %edx,%eax
}
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	53                   	push   %ebx
  800a25:	8b 45 08             	mov    0x8(%ebp),%eax
  800a28:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2b:	89 c3                	mov    %eax,%ebx
  800a2d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a30:	eb 06                	jmp    800a38 <strncmp+0x17>
		n--, p++, q++;
  800a32:	83 c0 01             	add    $0x1,%eax
  800a35:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a38:	39 d8                	cmp    %ebx,%eax
  800a3a:	74 15                	je     800a51 <strncmp+0x30>
  800a3c:	0f b6 08             	movzbl (%eax),%ecx
  800a3f:	84 c9                	test   %cl,%cl
  800a41:	74 04                	je     800a47 <strncmp+0x26>
  800a43:	3a 0a                	cmp    (%edx),%cl
  800a45:	74 eb                	je     800a32 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a47:	0f b6 00             	movzbl (%eax),%eax
  800a4a:	0f b6 12             	movzbl (%edx),%edx
  800a4d:	29 d0                	sub    %edx,%eax
  800a4f:	eb 05                	jmp    800a56 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a51:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a56:	5b                   	pop    %ebx
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a63:	eb 07                	jmp    800a6c <strchr+0x13>
		if (*s == c)
  800a65:	38 ca                	cmp    %cl,%dl
  800a67:	74 0f                	je     800a78 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a69:	83 c0 01             	add    $0x1,%eax
  800a6c:	0f b6 10             	movzbl (%eax),%edx
  800a6f:	84 d2                	test   %dl,%dl
  800a71:	75 f2                	jne    800a65 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a84:	eb 03                	jmp    800a89 <strfind+0xf>
  800a86:	83 c0 01             	add    $0x1,%eax
  800a89:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a8c:	38 ca                	cmp    %cl,%dl
  800a8e:	74 04                	je     800a94 <strfind+0x1a>
  800a90:	84 d2                	test   %dl,%dl
  800a92:	75 f2                	jne    800a86 <strfind+0xc>
			break;
	return (char *) s;
}
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	57                   	push   %edi
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aa2:	85 c9                	test   %ecx,%ecx
  800aa4:	74 36                	je     800adc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aa6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aac:	75 28                	jne    800ad6 <memset+0x40>
  800aae:	f6 c1 03             	test   $0x3,%cl
  800ab1:	75 23                	jne    800ad6 <memset+0x40>
		c &= 0xFF;
  800ab3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab7:	89 d3                	mov    %edx,%ebx
  800ab9:	c1 e3 08             	shl    $0x8,%ebx
  800abc:	89 d6                	mov    %edx,%esi
  800abe:	c1 e6 18             	shl    $0x18,%esi
  800ac1:	89 d0                	mov    %edx,%eax
  800ac3:	c1 e0 10             	shl    $0x10,%eax
  800ac6:	09 f0                	or     %esi,%eax
  800ac8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800aca:	89 d8                	mov    %ebx,%eax
  800acc:	09 d0                	or     %edx,%eax
  800ace:	c1 e9 02             	shr    $0x2,%ecx
  800ad1:	fc                   	cld    
  800ad2:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad4:	eb 06                	jmp    800adc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ad6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad9:	fc                   	cld    
  800ada:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800adc:	89 f8                	mov    %edi,%eax
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aeb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800af1:	39 c6                	cmp    %eax,%esi
  800af3:	73 35                	jae    800b2a <memmove+0x47>
  800af5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800af8:	39 d0                	cmp    %edx,%eax
  800afa:	73 2e                	jae    800b2a <memmove+0x47>
		s += n;
		d += n;
  800afc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aff:	89 d6                	mov    %edx,%esi
  800b01:	09 fe                	or     %edi,%esi
  800b03:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b09:	75 13                	jne    800b1e <memmove+0x3b>
  800b0b:	f6 c1 03             	test   $0x3,%cl
  800b0e:	75 0e                	jne    800b1e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b10:	83 ef 04             	sub    $0x4,%edi
  800b13:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b16:	c1 e9 02             	shr    $0x2,%ecx
  800b19:	fd                   	std    
  800b1a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1c:	eb 09                	jmp    800b27 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b1e:	83 ef 01             	sub    $0x1,%edi
  800b21:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b24:	fd                   	std    
  800b25:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b27:	fc                   	cld    
  800b28:	eb 1d                	jmp    800b47 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2a:	89 f2                	mov    %esi,%edx
  800b2c:	09 c2                	or     %eax,%edx
  800b2e:	f6 c2 03             	test   $0x3,%dl
  800b31:	75 0f                	jne    800b42 <memmove+0x5f>
  800b33:	f6 c1 03             	test   $0x3,%cl
  800b36:	75 0a                	jne    800b42 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b38:	c1 e9 02             	shr    $0x2,%ecx
  800b3b:	89 c7                	mov    %eax,%edi
  800b3d:	fc                   	cld    
  800b3e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b40:	eb 05                	jmp    800b47 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b42:	89 c7                	mov    %eax,%edi
  800b44:	fc                   	cld    
  800b45:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b47:	5e                   	pop    %esi
  800b48:	5f                   	pop    %edi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b4e:	ff 75 10             	pushl  0x10(%ebp)
  800b51:	ff 75 0c             	pushl  0xc(%ebp)
  800b54:	ff 75 08             	pushl  0x8(%ebp)
  800b57:	e8 87 ff ff ff       	call   800ae3 <memmove>
}
  800b5c:	c9                   	leave  
  800b5d:	c3                   	ret    

00800b5e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	8b 45 08             	mov    0x8(%ebp),%eax
  800b66:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b69:	89 c6                	mov    %eax,%esi
  800b6b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6e:	eb 1a                	jmp    800b8a <memcmp+0x2c>
		if (*s1 != *s2)
  800b70:	0f b6 08             	movzbl (%eax),%ecx
  800b73:	0f b6 1a             	movzbl (%edx),%ebx
  800b76:	38 d9                	cmp    %bl,%cl
  800b78:	74 0a                	je     800b84 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b7a:	0f b6 c1             	movzbl %cl,%eax
  800b7d:	0f b6 db             	movzbl %bl,%ebx
  800b80:	29 d8                	sub    %ebx,%eax
  800b82:	eb 0f                	jmp    800b93 <memcmp+0x35>
		s1++, s2++;
  800b84:	83 c0 01             	add    $0x1,%eax
  800b87:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8a:	39 f0                	cmp    %esi,%eax
  800b8c:	75 e2                	jne    800b70 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	53                   	push   %ebx
  800b9b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b9e:	89 c1                	mov    %eax,%ecx
  800ba0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ba7:	eb 0a                	jmp    800bb3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba9:	0f b6 10             	movzbl (%eax),%edx
  800bac:	39 da                	cmp    %ebx,%edx
  800bae:	74 07                	je     800bb7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb0:	83 c0 01             	add    $0x1,%eax
  800bb3:	39 c8                	cmp    %ecx,%eax
  800bb5:	72 f2                	jb     800ba9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc6:	eb 03                	jmp    800bcb <strtol+0x11>
		s++;
  800bc8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bcb:	0f b6 01             	movzbl (%ecx),%eax
  800bce:	3c 20                	cmp    $0x20,%al
  800bd0:	74 f6                	je     800bc8 <strtol+0xe>
  800bd2:	3c 09                	cmp    $0x9,%al
  800bd4:	74 f2                	je     800bc8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bd6:	3c 2b                	cmp    $0x2b,%al
  800bd8:	75 0a                	jne    800be4 <strtol+0x2a>
		s++;
  800bda:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bdd:	bf 00 00 00 00       	mov    $0x0,%edi
  800be2:	eb 11                	jmp    800bf5 <strtol+0x3b>
  800be4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800be9:	3c 2d                	cmp    $0x2d,%al
  800beb:	75 08                	jne    800bf5 <strtol+0x3b>
		s++, neg = 1;
  800bed:	83 c1 01             	add    $0x1,%ecx
  800bf0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bfb:	75 15                	jne    800c12 <strtol+0x58>
  800bfd:	80 39 30             	cmpb   $0x30,(%ecx)
  800c00:	75 10                	jne    800c12 <strtol+0x58>
  800c02:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c06:	75 7c                	jne    800c84 <strtol+0xca>
		s += 2, base = 16;
  800c08:	83 c1 02             	add    $0x2,%ecx
  800c0b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c10:	eb 16                	jmp    800c28 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c12:	85 db                	test   %ebx,%ebx
  800c14:	75 12                	jne    800c28 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c16:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c1b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c1e:	75 08                	jne    800c28 <strtol+0x6e>
		s++, base = 8;
  800c20:	83 c1 01             	add    $0x1,%ecx
  800c23:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c28:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c30:	0f b6 11             	movzbl (%ecx),%edx
  800c33:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c36:	89 f3                	mov    %esi,%ebx
  800c38:	80 fb 09             	cmp    $0x9,%bl
  800c3b:	77 08                	ja     800c45 <strtol+0x8b>
			dig = *s - '0';
  800c3d:	0f be d2             	movsbl %dl,%edx
  800c40:	83 ea 30             	sub    $0x30,%edx
  800c43:	eb 22                	jmp    800c67 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c45:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c48:	89 f3                	mov    %esi,%ebx
  800c4a:	80 fb 19             	cmp    $0x19,%bl
  800c4d:	77 08                	ja     800c57 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c4f:	0f be d2             	movsbl %dl,%edx
  800c52:	83 ea 57             	sub    $0x57,%edx
  800c55:	eb 10                	jmp    800c67 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c57:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c5a:	89 f3                	mov    %esi,%ebx
  800c5c:	80 fb 19             	cmp    $0x19,%bl
  800c5f:	77 16                	ja     800c77 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c61:	0f be d2             	movsbl %dl,%edx
  800c64:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c67:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c6a:	7d 0b                	jge    800c77 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c6c:	83 c1 01             	add    $0x1,%ecx
  800c6f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c73:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c75:	eb b9                	jmp    800c30 <strtol+0x76>

	if (endptr)
  800c77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c7b:	74 0d                	je     800c8a <strtol+0xd0>
		*endptr = (char *) s;
  800c7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c80:	89 0e                	mov    %ecx,(%esi)
  800c82:	eb 06                	jmp    800c8a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c84:	85 db                	test   %ebx,%ebx
  800c86:	74 98                	je     800c20 <strtol+0x66>
  800c88:	eb 9e                	jmp    800c28 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c8a:	89 c2                	mov    %eax,%edx
  800c8c:	f7 da                	neg    %edx
  800c8e:	85 ff                	test   %edi,%edi
  800c90:	0f 45 c2             	cmovne %edx,%eax
}
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
  800c9e:	83 ec 04             	sub    $0x4,%esp
  800ca1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800ca4:	57                   	push   %edi
  800ca5:	e8 6e fc ff ff       	call   800918 <strlen>
  800caa:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800cad:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800cb0:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800cb5:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800cba:	eb 46                	jmp    800d02 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800cbc:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800cc0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800cc3:	80 f9 09             	cmp    $0x9,%cl
  800cc6:	77 08                	ja     800cd0 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800cc8:	0f be d2             	movsbl %dl,%edx
  800ccb:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800cce:	eb 27                	jmp    800cf7 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800cd0:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800cd3:	80 f9 05             	cmp    $0x5,%cl
  800cd6:	77 08                	ja     800ce0 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800cd8:	0f be d2             	movsbl %dl,%edx
  800cdb:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800cde:	eb 17                	jmp    800cf7 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800ce0:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800ce3:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800ce6:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800ceb:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800cef:	77 06                	ja     800cf7 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800cf1:	0f be d2             	movsbl %dl,%edx
  800cf4:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800cf7:	0f af ce             	imul   %esi,%ecx
  800cfa:	01 c8                	add    %ecx,%eax
		base *= 16;
  800cfc:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800cff:	83 eb 01             	sub    $0x1,%ebx
  800d02:	83 fb 01             	cmp    $0x1,%ebx
  800d05:	7f b5                	jg     800cbc <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800d07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d15:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	89 c3                	mov    %eax,%ebx
  800d22:	89 c7                	mov    %eax,%edi
  800d24:	89 c6                	mov    %eax,%esi
  800d26:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <sys_cgetc>:

int
sys_cgetc(void)
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
  800d38:	b8 01 00 00 00       	mov    $0x1,%eax
  800d3d:	89 d1                	mov    %edx,%ecx
  800d3f:	89 d3                	mov    %edx,%ebx
  800d41:	89 d7                	mov    %edx,%edi
  800d43:	89 d6                	mov    %edx,%esi
  800d45:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800d55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5a:	b8 03 00 00 00       	mov    $0x3,%eax
  800d5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d62:	89 cb                	mov    %ecx,%ebx
  800d64:	89 cf                	mov    %ecx,%edi
  800d66:	89 ce                	mov    %ecx,%esi
  800d68:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	7e 17                	jle    800d85 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6e:	83 ec 0c             	sub    $0xc,%esp
  800d71:	50                   	push   %eax
  800d72:	6a 03                	push   $0x3
  800d74:	68 7f 28 80 00       	push   $0x80287f
  800d79:	6a 23                	push   $0x23
  800d7b:	68 9c 28 80 00       	push   $0x80289c
  800d80:	e8 bf f4 ff ff       	call   800244 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d93:	ba 00 00 00 00       	mov    $0x0,%edx
  800d98:	b8 02 00 00 00       	mov    $0x2,%eax
  800d9d:	89 d1                	mov    %edx,%ecx
  800d9f:	89 d3                	mov    %edx,%ebx
  800da1:	89 d7                	mov    %edx,%edi
  800da3:	89 d6                	mov    %edx,%esi
  800da5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <sys_yield>:

void
sys_yield(void)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	57                   	push   %edi
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db2:	ba 00 00 00 00       	mov    $0x0,%edx
  800db7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dbc:	89 d1                	mov    %edx,%ecx
  800dbe:	89 d3                	mov    %edx,%ebx
  800dc0:	89 d7                	mov    %edx,%edi
  800dc2:	89 d6                	mov    %edx,%esi
  800dc4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
  800dd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd4:	be 00 00 00 00       	mov    $0x0,%esi
  800dd9:	b8 04 00 00 00       	mov    $0x4,%eax
  800dde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de1:	8b 55 08             	mov    0x8(%ebp),%edx
  800de4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de7:	89 f7                	mov    %esi,%edi
  800de9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800deb:	85 c0                	test   %eax,%eax
  800ded:	7e 17                	jle    800e06 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	50                   	push   %eax
  800df3:	6a 04                	push   $0x4
  800df5:	68 7f 28 80 00       	push   $0x80287f
  800dfa:	6a 23                	push   $0x23
  800dfc:	68 9c 28 80 00       	push   $0x80289c
  800e01:	e8 3e f4 ff ff       	call   800244 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e17:	b8 05 00 00 00       	mov    $0x5,%eax
  800e1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e22:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e25:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e28:	8b 75 18             	mov    0x18(%ebp),%esi
  800e2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	7e 17                	jle    800e48 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e31:	83 ec 0c             	sub    $0xc,%esp
  800e34:	50                   	push   %eax
  800e35:	6a 05                	push   $0x5
  800e37:	68 7f 28 80 00       	push   $0x80287f
  800e3c:	6a 23                	push   $0x23
  800e3e:	68 9c 28 80 00       	push   $0x80289c
  800e43:	e8 fc f3 ff ff       	call   800244 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	57                   	push   %edi
  800e54:	56                   	push   %esi
  800e55:	53                   	push   %ebx
  800e56:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e66:	8b 55 08             	mov    0x8(%ebp),%edx
  800e69:	89 df                	mov    %ebx,%edi
  800e6b:	89 de                	mov    %ebx,%esi
  800e6d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	7e 17                	jle    800e8a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e73:	83 ec 0c             	sub    $0xc,%esp
  800e76:	50                   	push   %eax
  800e77:	6a 06                	push   $0x6
  800e79:	68 7f 28 80 00       	push   $0x80287f
  800e7e:	6a 23                	push   $0x23
  800e80:	68 9c 28 80 00       	push   $0x80289c
  800e85:	e8 ba f3 ff ff       	call   800244 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    

00800e92 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea0:	b8 08 00 00 00       	mov    $0x8,%eax
  800ea5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea8:	8b 55 08             	mov    0x8(%ebp),%edx
  800eab:	89 df                	mov    %ebx,%edi
  800ead:	89 de                	mov    %ebx,%esi
  800eaf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	7e 17                	jle    800ecc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb5:	83 ec 0c             	sub    $0xc,%esp
  800eb8:	50                   	push   %eax
  800eb9:	6a 08                	push   $0x8
  800ebb:	68 7f 28 80 00       	push   $0x80287f
  800ec0:	6a 23                	push   $0x23
  800ec2:	68 9c 28 80 00       	push   $0x80289c
  800ec7:	e8 78 f3 ff ff       	call   800244 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ecc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
  800eda:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ee7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eea:	8b 55 08             	mov    0x8(%ebp),%edx
  800eed:	89 df                	mov    %ebx,%edi
  800eef:	89 de                	mov    %ebx,%esi
  800ef1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	7e 17                	jle    800f0e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef7:	83 ec 0c             	sub    $0xc,%esp
  800efa:	50                   	push   %eax
  800efb:	6a 0a                	push   $0xa
  800efd:	68 7f 28 80 00       	push   $0x80287f
  800f02:	6a 23                	push   $0x23
  800f04:	68 9c 28 80 00       	push   $0x80289c
  800f09:	e8 36 f3 ff ff       	call   800244 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f11:	5b                   	pop    %ebx
  800f12:	5e                   	pop    %esi
  800f13:	5f                   	pop    %edi
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    

00800f16 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	57                   	push   %edi
  800f1a:	56                   	push   %esi
  800f1b:	53                   	push   %ebx
  800f1c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f24:	b8 09 00 00 00       	mov    $0x9,%eax
  800f29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2f:	89 df                	mov    %ebx,%edi
  800f31:	89 de                	mov    %ebx,%esi
  800f33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f35:	85 c0                	test   %eax,%eax
  800f37:	7e 17                	jle    800f50 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f39:	83 ec 0c             	sub    $0xc,%esp
  800f3c:	50                   	push   %eax
  800f3d:	6a 09                	push   $0x9
  800f3f:	68 7f 28 80 00       	push   $0x80287f
  800f44:	6a 23                	push   $0x23
  800f46:	68 9c 28 80 00       	push   $0x80289c
  800f4b:	e8 f4 f2 ff ff       	call   800244 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f53:	5b                   	pop    %ebx
  800f54:	5e                   	pop    %esi
  800f55:	5f                   	pop    %edi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    

00800f58 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	57                   	push   %edi
  800f5c:	56                   	push   %esi
  800f5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5e:	be 00 00 00 00       	mov    $0x0,%esi
  800f63:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f71:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f74:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f76:	5b                   	pop    %ebx
  800f77:	5e                   	pop    %esi
  800f78:	5f                   	pop    %edi
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    

00800f7b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	57                   	push   %edi
  800f7f:	56                   	push   %esi
  800f80:	53                   	push   %ebx
  800f81:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f89:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f91:	89 cb                	mov    %ecx,%ebx
  800f93:	89 cf                	mov    %ecx,%edi
  800f95:	89 ce                	mov    %ecx,%esi
  800f97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	7e 17                	jle    800fb4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9d:	83 ec 0c             	sub    $0xc,%esp
  800fa0:	50                   	push   %eax
  800fa1:	6a 0d                	push   $0xd
  800fa3:	68 7f 28 80 00       	push   $0x80287f
  800fa8:	6a 23                	push   $0x23
  800faa:	68 9c 28 80 00       	push   $0x80289c
  800faf:	e8 90 f2 ff ff       	call   800244 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb7:	5b                   	pop    %ebx
  800fb8:	5e                   	pop    %esi
  800fb9:	5f                   	pop    %edi
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    

00800fbc <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	53                   	push   %ebx
  800fc0:	83 ec 04             	sub    $0x4,%esp
  800fc3:	8b 45 08             	mov    0x8(%ebp),%eax

	
	void *addr = (void *) utf->utf_fault_va;
  800fc6:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800fc8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fcc:	74 11                	je     800fdf <pgfault+0x23>
  800fce:	89 d8                	mov    %ebx,%eax
  800fd0:	c1 e8 0c             	shr    $0xc,%eax
  800fd3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fda:	f6 c4 08             	test   $0x8,%ah
  800fdd:	75 14                	jne    800ff3 <pgfault+0x37>
		panic("page fault");
  800fdf:	83 ec 04             	sub    $0x4,%esp
  800fe2:	68 aa 28 80 00       	push   $0x8028aa
  800fe7:	6a 5b                	push   $0x5b
  800fe9:	68 b5 28 80 00       	push   $0x8028b5
  800fee:	e8 51 f2 ff ff       	call   800244 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// allocate a new page and map it at a temporary location
	if((r = sys_page_alloc(0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800ff3:	83 ec 04             	sub    $0x4,%esp
  800ff6:	6a 07                	push   $0x7
  800ff8:	68 00 f0 7f 00       	push   $0x7ff000
  800ffd:	6a 00                	push   $0x0
  800fff:	e8 c7 fd ff ff       	call   800dcb <sys_page_alloc>
  801004:	83 c4 10             	add    $0x10,%esp
  801007:	85 c0                	test   %eax,%eax
  801009:	79 12                	jns    80101d <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  80100b:	50                   	push   %eax
  80100c:	68 c0 28 80 00       	push   $0x8028c0
  801011:	6a 66                	push   $0x66
  801013:	68 b5 28 80 00       	push   $0x8028b5
  801018:	e8 27 f2 ff ff       	call   800244 <_panic>

	// copy date to new page
	//strncpy((char *)PFTEMP, (char *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
	memcpy((void *)PFTEMP, (void *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
  80101d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801023:	83 ec 04             	sub    $0x4,%esp
  801026:	68 00 10 00 00       	push   $0x1000
  80102b:	53                   	push   %ebx
  80102c:	68 00 f0 7f 00       	push   $0x7ff000
  801031:	e8 15 fb ff ff       	call   800b4b <memcpy>

	// move the new page to the old page's address
	if((r = sys_page_map(0, (void *)PFTEMP, 0, (void *)
  801036:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80103d:	53                   	push   %ebx
  80103e:	6a 00                	push   $0x0
  801040:	68 00 f0 7f 00       	push   $0x7ff000
  801045:	6a 00                	push   $0x0
  801047:	e8 c2 fd ff ff       	call   800e0e <sys_page_map>
  80104c:	83 c4 20             	add    $0x20,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	79 12                	jns    801065 <pgfault+0xa9>
		(ROUNDDOWN(addr, PGSIZE)), PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_map: %e", r);
  801053:	50                   	push   %eax
  801054:	68 d3 28 80 00       	push   $0x8028d3
  801059:	6a 6f                	push   $0x6f
  80105b:	68 b5 28 80 00       	push   $0x8028b5
  801060:	e8 df f1 ff ff       	call   800244 <_panic>

	// unmap page on PFTEMP
	if((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  801065:	83 ec 08             	sub    $0x8,%esp
  801068:	68 00 f0 7f 00       	push   $0x7ff000
  80106d:	6a 00                	push   $0x0
  80106f:	e8 dc fd ff ff       	call   800e50 <sys_page_unmap>
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	85 c0                	test   %eax,%eax
  801079:	79 12                	jns    80108d <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  80107b:	50                   	push   %eax
  80107c:	68 e4 28 80 00       	push   $0x8028e4
  801081:	6a 73                	push   $0x73
  801083:	68 b5 28 80 00       	push   $0x8028b5
  801088:	e8 b7 f1 ff ff       	call   800244 <_panic>


}
  80108d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801090:	c9                   	leave  
  801091:	c3                   	ret    

00801092 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	57                   	push   %edi
  801096:	56                   	push   %esi
  801097:	53                   	push   %ebx
  801098:	83 ec 28             	sub    $0x28,%esp

	#ifdef CHALLENGE 
	set_exception_handler(pgfault, T_PGFLT);
	#else
	// set up page fault handler
	set_pgfault_handler(pgfault);
  80109b:	68 bc 0f 80 00       	push   $0x800fbc
  8010a0:	e8 84 10 00 00       	call   802129 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010a5:	b8 07 00 00 00       	mov    $0x7,%eax
  8010aa:	cd 30                	int    $0x30
  8010ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	#endif

	// create a child
	envid = sys_exofork();
	if (envid < 0)
  8010b2:	83 c4 10             	add    $0x10,%esp
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	79 15                	jns    8010ce <fork+0x3c>
		panic("sys_exofork: %e", envid);
  8010b9:	50                   	push   %eax
  8010ba:	68 f7 28 80 00       	push   $0x8028f7
  8010bf:	68 d0 00 00 00       	push   $0xd0
  8010c4:	68 b5 28 80 00       	push   $0x8028b5
  8010c9:	e8 76 f1 ff ff       	call   800244 <_panic>
  8010ce:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8010d3:	be 00 08 00 00       	mov    $0x800,%esi
	// we are the child
	if(envid == 0) {
  8010d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8010dc:	75 21                	jne    8010ff <fork+0x6d>
		// the copied valude of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8010de:	e8 aa fc ff ff       	call   800d8d <sys_getenvid>
  8010e3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010e8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010eb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010f0:	a3 08 40 80 00       	mov    %eax,0x804008
		/*// alloc exception stack
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
			PTE_P | PTE_U | PTE_W)) < 0)
			panic("sys_page_alloc: %e", r);*/

		return 0;
  8010f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fa:	e9 a3 01 00 00       	jmp    8012a2 <fork+0x210>
{
	int r;

	// LAB 4: Your code here.
	
	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P))
  8010ff:	89 d8                	mov    %ebx,%eax
  801101:	c1 e8 16             	shr    $0x16,%eax
  801104:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80110b:	a8 01                	test   $0x1,%al
  80110d:	0f 84 f0 00 00 00    	je     801203 <fork+0x171>
		return 0;

	// virtual page pn's page table entry
	pte_t pe = uvpt[pn];
  801113:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi


	if((pe & PTE_P) && (pe & PTE_U)) {
  80111a:	89 f8                	mov    %edi,%eax
  80111c:	83 e0 05             	and    $0x5,%eax
  80111f:	83 f8 05             	cmp    $0x5,%eax
  801122:	0f 85 db 00 00 00    	jne    801203 <fork+0x171>
		// share with the child environment 
		if(pe & PTE_SHARE) {
  801128:	f7 c7 00 04 00 00    	test   $0x400,%edi
  80112e:	74 36                	je     801166 <fork+0xd4>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  801139:	57                   	push   %edi
  80113a:	53                   	push   %ebx
  80113b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80113e:	53                   	push   %ebx
  80113f:	6a 00                	push   $0x0
  801141:	e8 c8 fc ff ff       	call   800e0e <sys_page_map>
  801146:	83 c4 20             	add    $0x20,%esp
  801149:	85 c0                	test   %eax,%eax
  80114b:	0f 89 b2 00 00 00    	jns    801203 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  801151:	50                   	push   %eax
  801152:	68 07 29 80 00       	push   $0x802907
  801157:	68 97 00 00 00       	push   $0x97
  80115c:	68 b5 28 80 00       	push   $0x8028b5
  801161:	e8 de f0 ff ff       	call   800244 <_panic>
		}
		// the page is writable or copy-on-write
		else if((pe & PTE_W) || (pe & PTE_COW)) {
  801166:	f7 c7 02 08 00 00    	test   $0x802,%edi
  80116c:	74 63                	je     8011d1 <fork+0x13f>
			// create the child mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, 
  80116e:	81 e7 05 06 00 00    	and    $0x605,%edi
  801174:	81 cf 00 08 00 00    	or     $0x800,%edi
  80117a:	83 ec 0c             	sub    $0xc,%esp
  80117d:	57                   	push   %edi
  80117e:	53                   	push   %ebx
  80117f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801182:	53                   	push   %ebx
  801183:	6a 00                	push   $0x0
  801185:	e8 84 fc ff ff       	call   800e0e <sys_page_map>
  80118a:	83 c4 20             	add    $0x20,%esp
  80118d:	85 c0                	test   %eax,%eax
  80118f:	79 15                	jns    8011a6 <fork+0x114>
				(void *)(pn*PGSIZE), (pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  801191:	50                   	push   %eax
  801192:	68 07 29 80 00       	push   $0x802907
  801197:	68 9e 00 00 00       	push   $0x9e
  80119c:	68 b5 28 80 00       	push   $0x8028b5
  8011a1:	e8 9e f0 ff ff       	call   800244 <_panic>
			// map the parent mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE),
  8011a6:	83 ec 0c             	sub    $0xc,%esp
  8011a9:	57                   	push   %edi
  8011aa:	53                   	push   %ebx
  8011ab:	6a 00                	push   $0x0
  8011ad:	53                   	push   %ebx
  8011ae:	6a 00                	push   $0x0
  8011b0:	e8 59 fc ff ff       	call   800e0e <sys_page_map>
  8011b5:	83 c4 20             	add    $0x20,%esp
  8011b8:	85 c0                	test   %eax,%eax
  8011ba:	79 47                	jns    801203 <fork+0x171>
				(pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  8011bc:	50                   	push   %eax
  8011bd:	68 07 29 80 00       	push   $0x802907
  8011c2:	68 a2 00 00 00       	push   $0xa2
  8011c7:	68 b5 28 80 00       	push   $0x8028b5
  8011cc:	e8 73 f0 ff ff       	call   800244 <_panic>
		}	
		else {
			// create the child mapping read only
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  8011d1:	83 ec 0c             	sub    $0xc,%esp
  8011d4:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  8011da:	57                   	push   %edi
  8011db:	53                   	push   %ebx
  8011dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011df:	53                   	push   %ebx
  8011e0:	6a 00                	push   $0x0
  8011e2:	e8 27 fc ff ff       	call   800e0e <sys_page_map>
  8011e7:	83 c4 20             	add    $0x20,%esp
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	79 15                	jns    801203 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  8011ee:	50                   	push   %eax
  8011ef:	68 07 29 80 00       	push   $0x802907
  8011f4:	68 a8 00 00 00       	push   $0xa8
  8011f9:	68 b5 28 80 00       	push   $0x8028b5
  8011fe:	e8 41 f0 ff ff       	call   800244 <_panic>
			panic("sys_page_alloc: %e", r);*/

		return 0;
	}
	// copy address to child environment's page dirctory
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn)
  801203:	83 c6 01             	add    $0x1,%esi
  801206:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80120c:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801212:	0f 85 e7 fe ff ff    	jne    8010ff <fork+0x6d>
	#ifdef CHALLENGE 
	if((r = sys_env_set_exception_upcall(envid, thisenv->env_exception_upcall)) < 0)
		panic("sys_env_set_exception_upcall: %e", r);
	#else
	// set child's page fault handler
	if((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  801218:	a1 08 40 80 00       	mov    0x804008,%eax
  80121d:	8b 40 64             	mov    0x64(%eax),%eax
  801220:	83 ec 08             	sub    $0x8,%esp
  801223:	50                   	push   %eax
  801224:	ff 75 e0             	pushl  -0x20(%ebp)
  801227:	e8 ea fc ff ff       	call   800f16 <sys_env_set_pgfault_upcall>
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	85 c0                	test   %eax,%eax
  801231:	79 15                	jns    801248 <fork+0x1b6>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801233:	50                   	push   %eax
  801234:	68 40 29 80 00       	push   $0x802940
  801239:	68 e9 00 00 00       	push   $0xe9
  80123e:	68 b5 28 80 00       	push   $0x8028b5
  801243:	e8 fc ef ff ff       	call   800244 <_panic>
	#endif

	// alloc exception stack for child environment
	if((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), 
  801248:	83 ec 04             	sub    $0x4,%esp
  80124b:	6a 07                	push   $0x7
  80124d:	68 00 f0 bf ee       	push   $0xeebff000
  801252:	ff 75 e0             	pushl  -0x20(%ebp)
  801255:	e8 71 fb ff ff       	call   800dcb <sys_page_alloc>
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	79 15                	jns    801276 <fork+0x1e4>
		PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
  801261:	50                   	push   %eax
  801262:	68 c0 28 80 00       	push   $0x8028c0
  801267:	68 ef 00 00 00       	push   $0xef
  80126c:	68 b5 28 80 00       	push   $0x8028b5
  801271:	e8 ce ef ff ff       	call   800244 <_panic>

	// start the child environment running
	if((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801276:	83 ec 08             	sub    $0x8,%esp
  801279:	6a 02                	push   $0x2
  80127b:	ff 75 e0             	pushl  -0x20(%ebp)
  80127e:	e8 0f fc ff ff       	call   800e92 <sys_env_set_status>
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	79 15                	jns    80129f <fork+0x20d>
		panic("sys_env_set_status: %e", r);
  80128a:	50                   	push   %eax
  80128b:	68 13 29 80 00       	push   $0x802913
  801290:	68 f3 00 00 00       	push   $0xf3
  801295:	68 b5 28 80 00       	push   $0x8028b5
  80129a:	e8 a5 ef ff ff       	call   800244 <_panic>

	return envid;
  80129f:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  8012a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012a5:	5b                   	pop    %ebx
  8012a6:	5e                   	pop    %esi
  8012a7:	5f                   	pop    %edi
  8012a8:	5d                   	pop    %ebp
  8012a9:	c3                   	ret    

008012aa <sfork>:

// Challenge!
int
sfork(void)
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8012b0:	68 2a 29 80 00       	push   $0x80292a
  8012b5:	68 fc 00 00 00       	push   $0xfc
  8012ba:	68 b5 28 80 00       	push   $0x8028b5
  8012bf:	e8 80 ef ff ff       	call   800244 <_panic>

008012c4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	56                   	push   %esi
  8012c8:	53                   	push   %ebx
  8012c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8012cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  8012d2:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8012d4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8012d9:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  8012dc:	83 ec 0c             	sub    $0xc,%esp
  8012df:	50                   	push   %eax
  8012e0:	e8 96 fc ff ff       	call   800f7b <sys_ipc_recv>
  8012e5:	83 c4 10             	add    $0x10,%esp
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	79 16                	jns    801302 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  8012ec:	85 f6                	test   %esi,%esi
  8012ee:	74 06                	je     8012f6 <ipc_recv+0x32>
			*from_env_store = 0;
  8012f0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  8012f6:	85 db                	test   %ebx,%ebx
  8012f8:	74 2c                	je     801326 <ipc_recv+0x62>
			*perm_store = 0;
  8012fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801300:	eb 24                	jmp    801326 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801302:	85 f6                	test   %esi,%esi
  801304:	74 0a                	je     801310 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801306:	a1 08 40 80 00       	mov    0x804008,%eax
  80130b:	8b 40 74             	mov    0x74(%eax),%eax
  80130e:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801310:	85 db                	test   %ebx,%ebx
  801312:	74 0a                	je     80131e <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801314:	a1 08 40 80 00       	mov    0x804008,%eax
  801319:	8b 40 78             	mov    0x78(%eax),%eax
  80131c:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  80131e:	a1 08 40 80 00       	mov    0x804008,%eax
  801323:	8b 40 70             	mov    0x70(%eax),%eax
}
  801326:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801329:	5b                   	pop    %ebx
  80132a:	5e                   	pop    %esi
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    

0080132d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	57                   	push   %edi
  801331:	56                   	push   %esi
  801332:	53                   	push   %ebx
  801333:	83 ec 0c             	sub    $0xc,%esp
  801336:	8b 7d 08             	mov    0x8(%ebp),%edi
  801339:	8b 75 0c             	mov    0xc(%ebp),%esi
  80133c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  80133f:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801341:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801346:	0f 44 d8             	cmove  %eax,%ebx
  801349:	eb 1e                	jmp    801369 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  80134b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80134e:	74 14                	je     801364 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801350:	83 ec 04             	sub    $0x4,%esp
  801353:	68 60 29 80 00       	push   $0x802960
  801358:	6a 44                	push   $0x44
  80135a:	68 8b 29 80 00       	push   $0x80298b
  80135f:	e8 e0 ee ff ff       	call   800244 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801364:	e8 43 fa ff ff       	call   800dac <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801369:	ff 75 14             	pushl  0x14(%ebp)
  80136c:	53                   	push   %ebx
  80136d:	56                   	push   %esi
  80136e:	57                   	push   %edi
  80136f:	e8 e4 fb ff ff       	call   800f58 <sys_ipc_try_send>
  801374:	83 c4 10             	add    $0x10,%esp
  801377:	85 c0                	test   %eax,%eax
  801379:	78 d0                	js     80134b <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  80137b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80137e:	5b                   	pop    %ebx
  80137f:	5e                   	pop    %esi
  801380:	5f                   	pop    %edi
  801381:	5d                   	pop    %ebp
  801382:	c3                   	ret    

00801383 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801389:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80138e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801391:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801397:	8b 52 50             	mov    0x50(%edx),%edx
  80139a:	39 ca                	cmp    %ecx,%edx
  80139c:	75 0d                	jne    8013ab <ipc_find_env+0x28>
			return envs[i].env_id;
  80139e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013a1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013a6:	8b 40 48             	mov    0x48(%eax),%eax
  8013a9:	eb 0f                	jmp    8013ba <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013ab:	83 c0 01             	add    $0x1,%eax
  8013ae:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013b3:	75 d9                	jne    80138e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c2:	05 00 00 00 30       	add    $0x30000000,%eax
  8013c7:	c1 e8 0c             	shr    $0xc,%eax
}
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    

008013cc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d2:	05 00 00 00 30       	add    $0x30000000,%eax
  8013d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013dc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013e1:	5d                   	pop    %ebp
  8013e2:	c3                   	ret    

008013e3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013ee:	89 c2                	mov    %eax,%edx
  8013f0:	c1 ea 16             	shr    $0x16,%edx
  8013f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013fa:	f6 c2 01             	test   $0x1,%dl
  8013fd:	74 11                	je     801410 <fd_alloc+0x2d>
  8013ff:	89 c2                	mov    %eax,%edx
  801401:	c1 ea 0c             	shr    $0xc,%edx
  801404:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80140b:	f6 c2 01             	test   $0x1,%dl
  80140e:	75 09                	jne    801419 <fd_alloc+0x36>
			*fd_store = fd;
  801410:	89 01                	mov    %eax,(%ecx)
			return 0;
  801412:	b8 00 00 00 00       	mov    $0x0,%eax
  801417:	eb 17                	jmp    801430 <fd_alloc+0x4d>
  801419:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80141e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801423:	75 c9                	jne    8013ee <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801425:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80142b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801430:	5d                   	pop    %ebp
  801431:	c3                   	ret    

00801432 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801438:	83 f8 1f             	cmp    $0x1f,%eax
  80143b:	77 36                	ja     801473 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80143d:	c1 e0 0c             	shl    $0xc,%eax
  801440:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801445:	89 c2                	mov    %eax,%edx
  801447:	c1 ea 16             	shr    $0x16,%edx
  80144a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801451:	f6 c2 01             	test   $0x1,%dl
  801454:	74 24                	je     80147a <fd_lookup+0x48>
  801456:	89 c2                	mov    %eax,%edx
  801458:	c1 ea 0c             	shr    $0xc,%edx
  80145b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801462:	f6 c2 01             	test   $0x1,%dl
  801465:	74 1a                	je     801481 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801467:	8b 55 0c             	mov    0xc(%ebp),%edx
  80146a:	89 02                	mov    %eax,(%edx)
	return 0;
  80146c:	b8 00 00 00 00       	mov    $0x0,%eax
  801471:	eb 13                	jmp    801486 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801478:	eb 0c                	jmp    801486 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80147a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80147f:	eb 05                	jmp    801486 <fd_lookup+0x54>
  801481:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    

00801488 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	83 ec 08             	sub    $0x8,%esp
  80148e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801491:	ba 14 2a 80 00       	mov    $0x802a14,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801496:	eb 13                	jmp    8014ab <dev_lookup+0x23>
  801498:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80149b:	39 08                	cmp    %ecx,(%eax)
  80149d:	75 0c                	jne    8014ab <dev_lookup+0x23>
			*dev = devtab[i];
  80149f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014a2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a9:	eb 2e                	jmp    8014d9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014ab:	8b 02                	mov    (%edx),%eax
  8014ad:	85 c0                	test   %eax,%eax
  8014af:	75 e7                	jne    801498 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014b1:	a1 08 40 80 00       	mov    0x804008,%eax
  8014b6:	8b 40 48             	mov    0x48(%eax),%eax
  8014b9:	83 ec 04             	sub    $0x4,%esp
  8014bc:	51                   	push   %ecx
  8014bd:	50                   	push   %eax
  8014be:	68 98 29 80 00       	push   $0x802998
  8014c3:	e8 55 ee ff ff       	call   80031d <cprintf>
	*dev = 0;
  8014c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014d9:	c9                   	leave  
  8014da:	c3                   	ret    

008014db <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	56                   	push   %esi
  8014df:	53                   	push   %ebx
  8014e0:	83 ec 10             	sub    $0x10,%esp
  8014e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ec:	50                   	push   %eax
  8014ed:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014f3:	c1 e8 0c             	shr    $0xc,%eax
  8014f6:	50                   	push   %eax
  8014f7:	e8 36 ff ff ff       	call   801432 <fd_lookup>
  8014fc:	83 c4 08             	add    $0x8,%esp
  8014ff:	85 c0                	test   %eax,%eax
  801501:	78 05                	js     801508 <fd_close+0x2d>
	    || fd != fd2) 
  801503:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801506:	74 0c                	je     801514 <fd_close+0x39>
		return (must_exist ? r : 0); 
  801508:	84 db                	test   %bl,%bl
  80150a:	ba 00 00 00 00       	mov    $0x0,%edx
  80150f:	0f 44 c2             	cmove  %edx,%eax
  801512:	eb 41                	jmp    801555 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801514:	83 ec 08             	sub    $0x8,%esp
  801517:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151a:	50                   	push   %eax
  80151b:	ff 36                	pushl  (%esi)
  80151d:	e8 66 ff ff ff       	call   801488 <dev_lookup>
  801522:	89 c3                	mov    %eax,%ebx
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	85 c0                	test   %eax,%eax
  801529:	78 1a                	js     801545 <fd_close+0x6a>
		if (dev->dev_close) 
  80152b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  801531:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  801536:	85 c0                	test   %eax,%eax
  801538:	74 0b                	je     801545 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80153a:	83 ec 0c             	sub    $0xc,%esp
  80153d:	56                   	push   %esi
  80153e:	ff d0                	call   *%eax
  801540:	89 c3                	mov    %eax,%ebx
  801542:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801545:	83 ec 08             	sub    $0x8,%esp
  801548:	56                   	push   %esi
  801549:	6a 00                	push   $0x0
  80154b:	e8 00 f9 ff ff       	call   800e50 <sys_page_unmap>
	return r;
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	89 d8                	mov    %ebx,%eax
}
  801555:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801558:	5b                   	pop    %ebx
  801559:	5e                   	pop    %esi
  80155a:	5d                   	pop    %ebp
  80155b:	c3                   	ret    

0080155c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801562:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801565:	50                   	push   %eax
  801566:	ff 75 08             	pushl  0x8(%ebp)
  801569:	e8 c4 fe ff ff       	call   801432 <fd_lookup>
  80156e:	83 c4 08             	add    $0x8,%esp
  801571:	85 c0                	test   %eax,%eax
  801573:	78 10                	js     801585 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  801575:	83 ec 08             	sub    $0x8,%esp
  801578:	6a 01                	push   $0x1
  80157a:	ff 75 f4             	pushl  -0xc(%ebp)
  80157d:	e8 59 ff ff ff       	call   8014db <fd_close>
  801582:	83 c4 10             	add    $0x10,%esp
}
  801585:	c9                   	leave  
  801586:	c3                   	ret    

00801587 <close_all>:

void
close_all(void)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	53                   	push   %ebx
  80158b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80158e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801593:	83 ec 0c             	sub    $0xc,%esp
  801596:	53                   	push   %ebx
  801597:	e8 c0 ff ff ff       	call   80155c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80159c:	83 c3 01             	add    $0x1,%ebx
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	83 fb 20             	cmp    $0x20,%ebx
  8015a5:	75 ec                	jne    801593 <close_all+0xc>
		close(i);
}
  8015a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015aa:	c9                   	leave  
  8015ab:	c3                   	ret    

008015ac <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	57                   	push   %edi
  8015b0:	56                   	push   %esi
  8015b1:	53                   	push   %ebx
  8015b2:	83 ec 2c             	sub    $0x2c,%esp
  8015b5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015bb:	50                   	push   %eax
  8015bc:	ff 75 08             	pushl  0x8(%ebp)
  8015bf:	e8 6e fe ff ff       	call   801432 <fd_lookup>
  8015c4:	83 c4 08             	add    $0x8,%esp
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	0f 88 c1 00 00 00    	js     801690 <dup+0xe4>
		return r;
	close(newfdnum);
  8015cf:	83 ec 0c             	sub    $0xc,%esp
  8015d2:	56                   	push   %esi
  8015d3:	e8 84 ff ff ff       	call   80155c <close>

	newfd = INDEX2FD(newfdnum);
  8015d8:	89 f3                	mov    %esi,%ebx
  8015da:	c1 e3 0c             	shl    $0xc,%ebx
  8015dd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015e3:	83 c4 04             	add    $0x4,%esp
  8015e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015e9:	e8 de fd ff ff       	call   8013cc <fd2data>
  8015ee:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015f0:	89 1c 24             	mov    %ebx,(%esp)
  8015f3:	e8 d4 fd ff ff       	call   8013cc <fd2data>
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015fe:	89 f8                	mov    %edi,%eax
  801600:	c1 e8 16             	shr    $0x16,%eax
  801603:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80160a:	a8 01                	test   $0x1,%al
  80160c:	74 37                	je     801645 <dup+0x99>
  80160e:	89 f8                	mov    %edi,%eax
  801610:	c1 e8 0c             	shr    $0xc,%eax
  801613:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80161a:	f6 c2 01             	test   $0x1,%dl
  80161d:	74 26                	je     801645 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80161f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801626:	83 ec 0c             	sub    $0xc,%esp
  801629:	25 07 0e 00 00       	and    $0xe07,%eax
  80162e:	50                   	push   %eax
  80162f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801632:	6a 00                	push   $0x0
  801634:	57                   	push   %edi
  801635:	6a 00                	push   $0x0
  801637:	e8 d2 f7 ff ff       	call   800e0e <sys_page_map>
  80163c:	89 c7                	mov    %eax,%edi
  80163e:	83 c4 20             	add    $0x20,%esp
  801641:	85 c0                	test   %eax,%eax
  801643:	78 2e                	js     801673 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801645:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801648:	89 d0                	mov    %edx,%eax
  80164a:	c1 e8 0c             	shr    $0xc,%eax
  80164d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801654:	83 ec 0c             	sub    $0xc,%esp
  801657:	25 07 0e 00 00       	and    $0xe07,%eax
  80165c:	50                   	push   %eax
  80165d:	53                   	push   %ebx
  80165e:	6a 00                	push   $0x0
  801660:	52                   	push   %edx
  801661:	6a 00                	push   $0x0
  801663:	e8 a6 f7 ff ff       	call   800e0e <sys_page_map>
  801668:	89 c7                	mov    %eax,%edi
  80166a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80166d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80166f:	85 ff                	test   %edi,%edi
  801671:	79 1d                	jns    801690 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801673:	83 ec 08             	sub    $0x8,%esp
  801676:	53                   	push   %ebx
  801677:	6a 00                	push   $0x0
  801679:	e8 d2 f7 ff ff       	call   800e50 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80167e:	83 c4 08             	add    $0x8,%esp
  801681:	ff 75 d4             	pushl  -0x2c(%ebp)
  801684:	6a 00                	push   $0x0
  801686:	e8 c5 f7 ff ff       	call   800e50 <sys_page_unmap>
	return r;
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	89 f8                	mov    %edi,%eax
}
  801690:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801693:	5b                   	pop    %ebx
  801694:	5e                   	pop    %esi
  801695:	5f                   	pop    %edi
  801696:	5d                   	pop    %ebp
  801697:	c3                   	ret    

00801698 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	53                   	push   %ebx
  80169c:	83 ec 14             	sub    $0x14,%esp
  80169f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a5:	50                   	push   %eax
  8016a6:	53                   	push   %ebx
  8016a7:	e8 86 fd ff ff       	call   801432 <fd_lookup>
  8016ac:	83 c4 08             	add    $0x8,%esp
  8016af:	89 c2                	mov    %eax,%edx
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	78 6d                	js     801722 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b5:	83 ec 08             	sub    $0x8,%esp
  8016b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016bb:	50                   	push   %eax
  8016bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bf:	ff 30                	pushl  (%eax)
  8016c1:	e8 c2 fd ff ff       	call   801488 <dev_lookup>
  8016c6:	83 c4 10             	add    $0x10,%esp
  8016c9:	85 c0                	test   %eax,%eax
  8016cb:	78 4c                	js     801719 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016cd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016d0:	8b 42 08             	mov    0x8(%edx),%eax
  8016d3:	83 e0 03             	and    $0x3,%eax
  8016d6:	83 f8 01             	cmp    $0x1,%eax
  8016d9:	75 21                	jne    8016fc <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016db:	a1 08 40 80 00       	mov    0x804008,%eax
  8016e0:	8b 40 48             	mov    0x48(%eax),%eax
  8016e3:	83 ec 04             	sub    $0x4,%esp
  8016e6:	53                   	push   %ebx
  8016e7:	50                   	push   %eax
  8016e8:	68 d9 29 80 00       	push   $0x8029d9
  8016ed:	e8 2b ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016fa:	eb 26                	jmp    801722 <read+0x8a>
	}
	if (!dev->dev_read)
  8016fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ff:	8b 40 08             	mov    0x8(%eax),%eax
  801702:	85 c0                	test   %eax,%eax
  801704:	74 17                	je     80171d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801706:	83 ec 04             	sub    $0x4,%esp
  801709:	ff 75 10             	pushl  0x10(%ebp)
  80170c:	ff 75 0c             	pushl  0xc(%ebp)
  80170f:	52                   	push   %edx
  801710:	ff d0                	call   *%eax
  801712:	89 c2                	mov    %eax,%edx
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	eb 09                	jmp    801722 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801719:	89 c2                	mov    %eax,%edx
  80171b:	eb 05                	jmp    801722 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80171d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801722:	89 d0                	mov    %edx,%eax
  801724:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801727:	c9                   	leave  
  801728:	c3                   	ret    

00801729 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	57                   	push   %edi
  80172d:	56                   	push   %esi
  80172e:	53                   	push   %ebx
  80172f:	83 ec 0c             	sub    $0xc,%esp
  801732:	8b 7d 08             	mov    0x8(%ebp),%edi
  801735:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801738:	bb 00 00 00 00       	mov    $0x0,%ebx
  80173d:	eb 21                	jmp    801760 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80173f:	83 ec 04             	sub    $0x4,%esp
  801742:	89 f0                	mov    %esi,%eax
  801744:	29 d8                	sub    %ebx,%eax
  801746:	50                   	push   %eax
  801747:	89 d8                	mov    %ebx,%eax
  801749:	03 45 0c             	add    0xc(%ebp),%eax
  80174c:	50                   	push   %eax
  80174d:	57                   	push   %edi
  80174e:	e8 45 ff ff ff       	call   801698 <read>
		if (m < 0)
  801753:	83 c4 10             	add    $0x10,%esp
  801756:	85 c0                	test   %eax,%eax
  801758:	78 10                	js     80176a <readn+0x41>
			return m;
		if (m == 0)
  80175a:	85 c0                	test   %eax,%eax
  80175c:	74 0a                	je     801768 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80175e:	01 c3                	add    %eax,%ebx
  801760:	39 f3                	cmp    %esi,%ebx
  801762:	72 db                	jb     80173f <readn+0x16>
  801764:	89 d8                	mov    %ebx,%eax
  801766:	eb 02                	jmp    80176a <readn+0x41>
  801768:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80176a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80176d:	5b                   	pop    %ebx
  80176e:	5e                   	pop    %esi
  80176f:	5f                   	pop    %edi
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    

00801772 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	53                   	push   %ebx
  801776:	83 ec 14             	sub    $0x14,%esp
  801779:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80177c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80177f:	50                   	push   %eax
  801780:	53                   	push   %ebx
  801781:	e8 ac fc ff ff       	call   801432 <fd_lookup>
  801786:	83 c4 08             	add    $0x8,%esp
  801789:	89 c2                	mov    %eax,%edx
  80178b:	85 c0                	test   %eax,%eax
  80178d:	78 68                	js     8017f7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178f:	83 ec 08             	sub    $0x8,%esp
  801792:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801795:	50                   	push   %eax
  801796:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801799:	ff 30                	pushl  (%eax)
  80179b:	e8 e8 fc ff ff       	call   801488 <dev_lookup>
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	78 47                	js     8017ee <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017aa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017ae:	75 21                	jne    8017d1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017b0:	a1 08 40 80 00       	mov    0x804008,%eax
  8017b5:	8b 40 48             	mov    0x48(%eax),%eax
  8017b8:	83 ec 04             	sub    $0x4,%esp
  8017bb:	53                   	push   %ebx
  8017bc:	50                   	push   %eax
  8017bd:	68 f5 29 80 00       	push   $0x8029f5
  8017c2:	e8 56 eb ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  8017c7:	83 c4 10             	add    $0x10,%esp
  8017ca:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017cf:	eb 26                	jmp    8017f7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d4:	8b 52 0c             	mov    0xc(%edx),%edx
  8017d7:	85 d2                	test   %edx,%edx
  8017d9:	74 17                	je     8017f2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017db:	83 ec 04             	sub    $0x4,%esp
  8017de:	ff 75 10             	pushl  0x10(%ebp)
  8017e1:	ff 75 0c             	pushl  0xc(%ebp)
  8017e4:	50                   	push   %eax
  8017e5:	ff d2                	call   *%edx
  8017e7:	89 c2                	mov    %eax,%edx
  8017e9:	83 c4 10             	add    $0x10,%esp
  8017ec:	eb 09                	jmp    8017f7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ee:	89 c2                	mov    %eax,%edx
  8017f0:	eb 05                	jmp    8017f7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017f2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017f7:	89 d0                	mov    %edx,%eax
  8017f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017fc:	c9                   	leave  
  8017fd:	c3                   	ret    

008017fe <seek>:

int
seek(int fdnum, off_t offset)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801804:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801807:	50                   	push   %eax
  801808:	ff 75 08             	pushl  0x8(%ebp)
  80180b:	e8 22 fc ff ff       	call   801432 <fd_lookup>
  801810:	83 c4 08             	add    $0x8,%esp
  801813:	85 c0                	test   %eax,%eax
  801815:	78 0e                	js     801825 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801817:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80181a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80181d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801820:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801825:	c9                   	leave  
  801826:	c3                   	ret    

00801827 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	53                   	push   %ebx
  80182b:	83 ec 14             	sub    $0x14,%esp
  80182e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801831:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801834:	50                   	push   %eax
  801835:	53                   	push   %ebx
  801836:	e8 f7 fb ff ff       	call   801432 <fd_lookup>
  80183b:	83 c4 08             	add    $0x8,%esp
  80183e:	89 c2                	mov    %eax,%edx
  801840:	85 c0                	test   %eax,%eax
  801842:	78 65                	js     8018a9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801844:	83 ec 08             	sub    $0x8,%esp
  801847:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184a:	50                   	push   %eax
  80184b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184e:	ff 30                	pushl  (%eax)
  801850:	e8 33 fc ff ff       	call   801488 <dev_lookup>
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	85 c0                	test   %eax,%eax
  80185a:	78 44                	js     8018a0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80185c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801863:	75 21                	jne    801886 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801865:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80186a:	8b 40 48             	mov    0x48(%eax),%eax
  80186d:	83 ec 04             	sub    $0x4,%esp
  801870:	53                   	push   %ebx
  801871:	50                   	push   %eax
  801872:	68 b8 29 80 00       	push   $0x8029b8
  801877:	e8 a1 ea ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801884:	eb 23                	jmp    8018a9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801886:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801889:	8b 52 18             	mov    0x18(%edx),%edx
  80188c:	85 d2                	test   %edx,%edx
  80188e:	74 14                	je     8018a4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801890:	83 ec 08             	sub    $0x8,%esp
  801893:	ff 75 0c             	pushl  0xc(%ebp)
  801896:	50                   	push   %eax
  801897:	ff d2                	call   *%edx
  801899:	89 c2                	mov    %eax,%edx
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	eb 09                	jmp    8018a9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a0:	89 c2                	mov    %eax,%edx
  8018a2:	eb 05                	jmp    8018a9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018a4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018a9:	89 d0                	mov    %edx,%eax
  8018ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ae:	c9                   	leave  
  8018af:	c3                   	ret    

008018b0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	53                   	push   %ebx
  8018b4:	83 ec 14             	sub    $0x14,%esp
  8018b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018bd:	50                   	push   %eax
  8018be:	ff 75 08             	pushl  0x8(%ebp)
  8018c1:	e8 6c fb ff ff       	call   801432 <fd_lookup>
  8018c6:	83 c4 08             	add    $0x8,%esp
  8018c9:	89 c2                	mov    %eax,%edx
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	78 58                	js     801927 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018cf:	83 ec 08             	sub    $0x8,%esp
  8018d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d5:	50                   	push   %eax
  8018d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d9:	ff 30                	pushl  (%eax)
  8018db:	e8 a8 fb ff ff       	call   801488 <dev_lookup>
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	78 37                	js     80191e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ea:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018ee:	74 32                	je     801922 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018f0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018f3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018fa:	00 00 00 
	stat->st_isdir = 0;
  8018fd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801904:	00 00 00 
	stat->st_dev = dev;
  801907:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80190d:	83 ec 08             	sub    $0x8,%esp
  801910:	53                   	push   %ebx
  801911:	ff 75 f0             	pushl  -0x10(%ebp)
  801914:	ff 50 14             	call   *0x14(%eax)
  801917:	89 c2                	mov    %eax,%edx
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	eb 09                	jmp    801927 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80191e:	89 c2                	mov    %eax,%edx
  801920:	eb 05                	jmp    801927 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801922:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801927:	89 d0                	mov    %edx,%eax
  801929:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192c:	c9                   	leave  
  80192d:	c3                   	ret    

0080192e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	56                   	push   %esi
  801932:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801933:	83 ec 08             	sub    $0x8,%esp
  801936:	6a 00                	push   $0x0
  801938:	ff 75 08             	pushl  0x8(%ebp)
  80193b:	e8 2b 02 00 00       	call   801b6b <open>
  801940:	89 c3                	mov    %eax,%ebx
  801942:	83 c4 10             	add    $0x10,%esp
  801945:	85 c0                	test   %eax,%eax
  801947:	78 1b                	js     801964 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801949:	83 ec 08             	sub    $0x8,%esp
  80194c:	ff 75 0c             	pushl  0xc(%ebp)
  80194f:	50                   	push   %eax
  801950:	e8 5b ff ff ff       	call   8018b0 <fstat>
  801955:	89 c6                	mov    %eax,%esi
	close(fd);
  801957:	89 1c 24             	mov    %ebx,(%esp)
  80195a:	e8 fd fb ff ff       	call   80155c <close>
	return r;
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	89 f0                	mov    %esi,%eax
}
  801964:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801967:	5b                   	pop    %ebx
  801968:	5e                   	pop    %esi
  801969:	5d                   	pop    %ebp
  80196a:	c3                   	ret    

0080196b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	56                   	push   %esi
  80196f:	53                   	push   %ebx
  801970:	89 c6                	mov    %eax,%esi
  801972:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801974:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80197b:	75 12                	jne    80198f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80197d:	83 ec 0c             	sub    $0xc,%esp
  801980:	6a 01                	push   $0x1
  801982:	e8 fc f9 ff ff       	call   801383 <ipc_find_env>
  801987:	a3 04 40 80 00       	mov    %eax,0x804004
  80198c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80198f:	6a 07                	push   $0x7
  801991:	68 00 50 80 00       	push   $0x805000
  801996:	56                   	push   %esi
  801997:	ff 35 04 40 80 00    	pushl  0x804004
  80199d:	e8 8b f9 ff ff       	call   80132d <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8019a2:	83 c4 0c             	add    $0xc,%esp
  8019a5:	6a 00                	push   $0x0
  8019a7:	53                   	push   %ebx
  8019a8:	6a 00                	push   $0x0
  8019aa:	e8 15 f9 ff ff       	call   8012c4 <ipc_recv>
}
  8019af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b2:	5b                   	pop    %ebx
  8019b3:	5e                   	pop    %esi
  8019b4:	5d                   	pop    %ebp
  8019b5:	c3                   	ret    

008019b6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ca:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d4:	b8 02 00 00 00       	mov    $0x2,%eax
  8019d9:	e8 8d ff ff ff       	call   80196b <fsipc>
}
  8019de:	c9                   	leave  
  8019df:	c3                   	ret    

008019e0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ec:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8019fb:	e8 6b ff ff ff       	call   80196b <fsipc>
}
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	53                   	push   %ebx
  801a06:	83 ec 04             	sub    $0x4,%esp
  801a09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a12:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a17:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1c:	b8 05 00 00 00       	mov    $0x5,%eax
  801a21:	e8 45 ff ff ff       	call   80196b <fsipc>
  801a26:	85 c0                	test   %eax,%eax
  801a28:	78 2c                	js     801a56 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a2a:	83 ec 08             	sub    $0x8,%esp
  801a2d:	68 00 50 80 00       	push   $0x805000
  801a32:	53                   	push   %ebx
  801a33:	e8 19 ef ff ff       	call   800951 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a38:	a1 80 50 80 00       	mov    0x805080,%eax
  801a3d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a43:	a1 84 50 80 00       	mov    0x805084,%eax
  801a48:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a59:	c9                   	leave  
  801a5a:	c3                   	ret    

00801a5b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	53                   	push   %ebx
  801a5f:	83 ec 08             	sub    $0x8,%esp
  801a62:	8b 45 10             	mov    0x10(%ebp),%eax
  801a65:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a6a:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801a6f:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a72:	8b 45 08             	mov    0x8(%ebp),%eax
  801a75:	8b 40 0c             	mov    0xc(%eax),%eax
  801a78:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801a7d:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801a83:	53                   	push   %ebx
  801a84:	ff 75 0c             	pushl  0xc(%ebp)
  801a87:	68 08 50 80 00       	push   $0x805008
  801a8c:	e8 52 f0 ff ff       	call   800ae3 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801a91:	ba 00 00 00 00       	mov    $0x0,%edx
  801a96:	b8 04 00 00 00       	mov    $0x4,%eax
  801a9b:	e8 cb fe ff ff       	call   80196b <fsipc>
  801aa0:	83 c4 10             	add    $0x10,%esp
  801aa3:	85 c0                	test   %eax,%eax
  801aa5:	78 3d                	js     801ae4 <devfile_write+0x89>
		return r;

	assert(r <= n);
  801aa7:	39 d8                	cmp    %ebx,%eax
  801aa9:	76 19                	jbe    801ac4 <devfile_write+0x69>
  801aab:	68 24 2a 80 00       	push   $0x802a24
  801ab0:	68 2b 2a 80 00       	push   $0x802a2b
  801ab5:	68 9f 00 00 00       	push   $0x9f
  801aba:	68 40 2a 80 00       	push   $0x802a40
  801abf:	e8 80 e7 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801ac4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ac9:	76 19                	jbe    801ae4 <devfile_write+0x89>
  801acb:	68 58 2a 80 00       	push   $0x802a58
  801ad0:	68 2b 2a 80 00       	push   $0x802a2b
  801ad5:	68 a0 00 00 00       	push   $0xa0
  801ada:	68 40 2a 80 00       	push   $0x802a40
  801adf:	e8 60 e7 ff ff       	call   800244 <_panic>

	return r;
}
  801ae4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae7:	c9                   	leave  
  801ae8:	c3                   	ret    

00801ae9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	56                   	push   %esi
  801aed:	53                   	push   %ebx
  801aee:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801af1:	8b 45 08             	mov    0x8(%ebp),%eax
  801af4:	8b 40 0c             	mov    0xc(%eax),%eax
  801af7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801afc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b02:	ba 00 00 00 00       	mov    $0x0,%edx
  801b07:	b8 03 00 00 00       	mov    $0x3,%eax
  801b0c:	e8 5a fe ff ff       	call   80196b <fsipc>
  801b11:	89 c3                	mov    %eax,%ebx
  801b13:	85 c0                	test   %eax,%eax
  801b15:	78 4b                	js     801b62 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b17:	39 c6                	cmp    %eax,%esi
  801b19:	73 16                	jae    801b31 <devfile_read+0x48>
  801b1b:	68 24 2a 80 00       	push   $0x802a24
  801b20:	68 2b 2a 80 00       	push   $0x802a2b
  801b25:	6a 7e                	push   $0x7e
  801b27:	68 40 2a 80 00       	push   $0x802a40
  801b2c:	e8 13 e7 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  801b31:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b36:	7e 16                	jle    801b4e <devfile_read+0x65>
  801b38:	68 4b 2a 80 00       	push   $0x802a4b
  801b3d:	68 2b 2a 80 00       	push   $0x802a2b
  801b42:	6a 7f                	push   $0x7f
  801b44:	68 40 2a 80 00       	push   $0x802a40
  801b49:	e8 f6 e6 ff ff       	call   800244 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b4e:	83 ec 04             	sub    $0x4,%esp
  801b51:	50                   	push   %eax
  801b52:	68 00 50 80 00       	push   $0x805000
  801b57:	ff 75 0c             	pushl  0xc(%ebp)
  801b5a:	e8 84 ef ff ff       	call   800ae3 <memmove>
	return r;
  801b5f:	83 c4 10             	add    $0x10,%esp
}
  801b62:	89 d8                	mov    %ebx,%eax
  801b64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b67:	5b                   	pop    %ebx
  801b68:	5e                   	pop    %esi
  801b69:	5d                   	pop    %ebp
  801b6a:	c3                   	ret    

00801b6b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	53                   	push   %ebx
  801b6f:	83 ec 20             	sub    $0x20,%esp
  801b72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b75:	53                   	push   %ebx
  801b76:	e8 9d ed ff ff       	call   800918 <strlen>
  801b7b:	83 c4 10             	add    $0x10,%esp
  801b7e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b83:	7f 67                	jg     801bec <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b85:	83 ec 0c             	sub    $0xc,%esp
  801b88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8b:	50                   	push   %eax
  801b8c:	e8 52 f8 ff ff       	call   8013e3 <fd_alloc>
  801b91:	83 c4 10             	add    $0x10,%esp
		return r;
  801b94:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b96:	85 c0                	test   %eax,%eax
  801b98:	78 57                	js     801bf1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b9a:	83 ec 08             	sub    $0x8,%esp
  801b9d:	53                   	push   %ebx
  801b9e:	68 00 50 80 00       	push   $0x805000
  801ba3:	e8 a9 ed ff ff       	call   800951 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bab:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bb3:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb8:	e8 ae fd ff ff       	call   80196b <fsipc>
  801bbd:	89 c3                	mov    %eax,%ebx
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	79 14                	jns    801bda <open+0x6f>
		fd_close(fd, 0);
  801bc6:	83 ec 08             	sub    $0x8,%esp
  801bc9:	6a 00                	push   $0x0
  801bcb:	ff 75 f4             	pushl  -0xc(%ebp)
  801bce:	e8 08 f9 ff ff       	call   8014db <fd_close>
		return r;
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	89 da                	mov    %ebx,%edx
  801bd8:	eb 17                	jmp    801bf1 <open+0x86>
	}

	return fd2num(fd);
  801bda:	83 ec 0c             	sub    $0xc,%esp
  801bdd:	ff 75 f4             	pushl  -0xc(%ebp)
  801be0:	e8 d7 f7 ff ff       	call   8013bc <fd2num>
  801be5:	89 c2                	mov    %eax,%edx
  801be7:	83 c4 10             	add    $0x10,%esp
  801bea:	eb 05                	jmp    801bf1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bec:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bf1:	89 d0                	mov    %edx,%eax
  801bf3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf6:	c9                   	leave  
  801bf7:	c3                   	ret    

00801bf8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bfe:	ba 00 00 00 00       	mov    $0x0,%edx
  801c03:	b8 08 00 00 00       	mov    $0x8,%eax
  801c08:	e8 5e fd ff ff       	call   80196b <fsipc>
}
  801c0d:	c9                   	leave  
  801c0e:	c3                   	ret    

00801c0f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c15:	89 d0                	mov    %edx,%eax
  801c17:	c1 e8 16             	shr    $0x16,%eax
  801c1a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c21:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c26:	f6 c1 01             	test   $0x1,%cl
  801c29:	74 1d                	je     801c48 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c2b:	c1 ea 0c             	shr    $0xc,%edx
  801c2e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c35:	f6 c2 01             	test   $0x1,%dl
  801c38:	74 0e                	je     801c48 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c3a:	c1 ea 0c             	shr    $0xc,%edx
  801c3d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c44:	ef 
  801c45:	0f b7 c0             	movzwl %ax,%eax
}
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    

00801c4a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	56                   	push   %esi
  801c4e:	53                   	push   %ebx
  801c4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c52:	83 ec 0c             	sub    $0xc,%esp
  801c55:	ff 75 08             	pushl  0x8(%ebp)
  801c58:	e8 6f f7 ff ff       	call   8013cc <fd2data>
  801c5d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c5f:	83 c4 08             	add    $0x8,%esp
  801c62:	68 88 2a 80 00       	push   $0x802a88
  801c67:	53                   	push   %ebx
  801c68:	e8 e4 ec ff ff       	call   800951 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c6d:	8b 46 04             	mov    0x4(%esi),%eax
  801c70:	2b 06                	sub    (%esi),%eax
  801c72:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c78:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c7f:	00 00 00 
	stat->st_dev = &devpipe;
  801c82:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c89:	30 80 00 
	return 0;
}
  801c8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c94:	5b                   	pop    %ebx
  801c95:	5e                   	pop    %esi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    

00801c98 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	53                   	push   %ebx
  801c9c:	83 ec 0c             	sub    $0xc,%esp
  801c9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ca2:	53                   	push   %ebx
  801ca3:	6a 00                	push   $0x0
  801ca5:	e8 a6 f1 ff ff       	call   800e50 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801caa:	89 1c 24             	mov    %ebx,(%esp)
  801cad:	e8 1a f7 ff ff       	call   8013cc <fd2data>
  801cb2:	83 c4 08             	add    $0x8,%esp
  801cb5:	50                   	push   %eax
  801cb6:	6a 00                	push   $0x0
  801cb8:	e8 93 f1 ff ff       	call   800e50 <sys_page_unmap>
}
  801cbd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc0:	c9                   	leave  
  801cc1:	c3                   	ret    

00801cc2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	57                   	push   %edi
  801cc6:	56                   	push   %esi
  801cc7:	53                   	push   %ebx
  801cc8:	83 ec 1c             	sub    $0x1c,%esp
  801ccb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cce:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cd0:	a1 08 40 80 00       	mov    0x804008,%eax
  801cd5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801cd8:	83 ec 0c             	sub    $0xc,%esp
  801cdb:	ff 75 e0             	pushl  -0x20(%ebp)
  801cde:	e8 2c ff ff ff       	call   801c0f <pageref>
  801ce3:	89 c3                	mov    %eax,%ebx
  801ce5:	89 3c 24             	mov    %edi,(%esp)
  801ce8:	e8 22 ff ff ff       	call   801c0f <pageref>
  801ced:	83 c4 10             	add    $0x10,%esp
  801cf0:	39 c3                	cmp    %eax,%ebx
  801cf2:	0f 94 c1             	sete   %cl
  801cf5:	0f b6 c9             	movzbl %cl,%ecx
  801cf8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801cfb:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d01:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d04:	39 ce                	cmp    %ecx,%esi
  801d06:	74 1b                	je     801d23 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d08:	39 c3                	cmp    %eax,%ebx
  801d0a:	75 c4                	jne    801cd0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d0c:	8b 42 58             	mov    0x58(%edx),%eax
  801d0f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d12:	50                   	push   %eax
  801d13:	56                   	push   %esi
  801d14:	68 8f 2a 80 00       	push   $0x802a8f
  801d19:	e8 ff e5 ff ff       	call   80031d <cprintf>
  801d1e:	83 c4 10             	add    $0x10,%esp
  801d21:	eb ad                	jmp    801cd0 <_pipeisclosed+0xe>
	}
}
  801d23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d29:	5b                   	pop    %ebx
  801d2a:	5e                   	pop    %esi
  801d2b:	5f                   	pop    %edi
  801d2c:	5d                   	pop    %ebp
  801d2d:	c3                   	ret    

00801d2e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	57                   	push   %edi
  801d32:	56                   	push   %esi
  801d33:	53                   	push   %ebx
  801d34:	83 ec 28             	sub    $0x28,%esp
  801d37:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d3a:	56                   	push   %esi
  801d3b:	e8 8c f6 ff ff       	call   8013cc <fd2data>
  801d40:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d42:	83 c4 10             	add    $0x10,%esp
  801d45:	bf 00 00 00 00       	mov    $0x0,%edi
  801d4a:	eb 4b                	jmp    801d97 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d4c:	89 da                	mov    %ebx,%edx
  801d4e:	89 f0                	mov    %esi,%eax
  801d50:	e8 6d ff ff ff       	call   801cc2 <_pipeisclosed>
  801d55:	85 c0                	test   %eax,%eax
  801d57:	75 48                	jne    801da1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d59:	e8 4e f0 ff ff       	call   800dac <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d5e:	8b 43 04             	mov    0x4(%ebx),%eax
  801d61:	8b 0b                	mov    (%ebx),%ecx
  801d63:	8d 51 20             	lea    0x20(%ecx),%edx
  801d66:	39 d0                	cmp    %edx,%eax
  801d68:	73 e2                	jae    801d4c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d6d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d71:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d74:	89 c2                	mov    %eax,%edx
  801d76:	c1 fa 1f             	sar    $0x1f,%edx
  801d79:	89 d1                	mov    %edx,%ecx
  801d7b:	c1 e9 1b             	shr    $0x1b,%ecx
  801d7e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d81:	83 e2 1f             	and    $0x1f,%edx
  801d84:	29 ca                	sub    %ecx,%edx
  801d86:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d8a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d8e:	83 c0 01             	add    $0x1,%eax
  801d91:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d94:	83 c7 01             	add    $0x1,%edi
  801d97:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d9a:	75 c2                	jne    801d5e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d9c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d9f:	eb 05                	jmp    801da6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801da1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801da6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da9:	5b                   	pop    %ebx
  801daa:	5e                   	pop    %esi
  801dab:	5f                   	pop    %edi
  801dac:	5d                   	pop    %ebp
  801dad:	c3                   	ret    

00801dae <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	57                   	push   %edi
  801db2:	56                   	push   %esi
  801db3:	53                   	push   %ebx
  801db4:	83 ec 18             	sub    $0x18,%esp
  801db7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dba:	57                   	push   %edi
  801dbb:	e8 0c f6 ff ff       	call   8013cc <fd2data>
  801dc0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dc2:	83 c4 10             	add    $0x10,%esp
  801dc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dca:	eb 3d                	jmp    801e09 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dcc:	85 db                	test   %ebx,%ebx
  801dce:	74 04                	je     801dd4 <devpipe_read+0x26>
				return i;
  801dd0:	89 d8                	mov    %ebx,%eax
  801dd2:	eb 44                	jmp    801e18 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801dd4:	89 f2                	mov    %esi,%edx
  801dd6:	89 f8                	mov    %edi,%eax
  801dd8:	e8 e5 fe ff ff       	call   801cc2 <_pipeisclosed>
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	75 32                	jne    801e13 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801de1:	e8 c6 ef ff ff       	call   800dac <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801de6:	8b 06                	mov    (%esi),%eax
  801de8:	3b 46 04             	cmp    0x4(%esi),%eax
  801deb:	74 df                	je     801dcc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ded:	99                   	cltd   
  801dee:	c1 ea 1b             	shr    $0x1b,%edx
  801df1:	01 d0                	add    %edx,%eax
  801df3:	83 e0 1f             	and    $0x1f,%eax
  801df6:	29 d0                	sub    %edx,%eax
  801df8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801dfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e00:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e03:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e06:	83 c3 01             	add    $0x1,%ebx
  801e09:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e0c:	75 d8                	jne    801de6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e0e:	8b 45 10             	mov    0x10(%ebp),%eax
  801e11:	eb 05                	jmp    801e18 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e13:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e1b:	5b                   	pop    %ebx
  801e1c:	5e                   	pop    %esi
  801e1d:	5f                   	pop    %edi
  801e1e:	5d                   	pop    %ebp
  801e1f:	c3                   	ret    

00801e20 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	56                   	push   %esi
  801e24:	53                   	push   %ebx
  801e25:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2b:	50                   	push   %eax
  801e2c:	e8 b2 f5 ff ff       	call   8013e3 <fd_alloc>
  801e31:	83 c4 10             	add    $0x10,%esp
  801e34:	89 c2                	mov    %eax,%edx
  801e36:	85 c0                	test   %eax,%eax
  801e38:	0f 88 2c 01 00 00    	js     801f6a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e3e:	83 ec 04             	sub    $0x4,%esp
  801e41:	68 07 04 00 00       	push   $0x407
  801e46:	ff 75 f4             	pushl  -0xc(%ebp)
  801e49:	6a 00                	push   $0x0
  801e4b:	e8 7b ef ff ff       	call   800dcb <sys_page_alloc>
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	89 c2                	mov    %eax,%edx
  801e55:	85 c0                	test   %eax,%eax
  801e57:	0f 88 0d 01 00 00    	js     801f6a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e5d:	83 ec 0c             	sub    $0xc,%esp
  801e60:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e63:	50                   	push   %eax
  801e64:	e8 7a f5 ff ff       	call   8013e3 <fd_alloc>
  801e69:	89 c3                	mov    %eax,%ebx
  801e6b:	83 c4 10             	add    $0x10,%esp
  801e6e:	85 c0                	test   %eax,%eax
  801e70:	0f 88 e2 00 00 00    	js     801f58 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e76:	83 ec 04             	sub    $0x4,%esp
  801e79:	68 07 04 00 00       	push   $0x407
  801e7e:	ff 75 f0             	pushl  -0x10(%ebp)
  801e81:	6a 00                	push   $0x0
  801e83:	e8 43 ef ff ff       	call   800dcb <sys_page_alloc>
  801e88:	89 c3                	mov    %eax,%ebx
  801e8a:	83 c4 10             	add    $0x10,%esp
  801e8d:	85 c0                	test   %eax,%eax
  801e8f:	0f 88 c3 00 00 00    	js     801f58 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e95:	83 ec 0c             	sub    $0xc,%esp
  801e98:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9b:	e8 2c f5 ff ff       	call   8013cc <fd2data>
  801ea0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea2:	83 c4 0c             	add    $0xc,%esp
  801ea5:	68 07 04 00 00       	push   $0x407
  801eaa:	50                   	push   %eax
  801eab:	6a 00                	push   $0x0
  801ead:	e8 19 ef ff ff       	call   800dcb <sys_page_alloc>
  801eb2:	89 c3                	mov    %eax,%ebx
  801eb4:	83 c4 10             	add    $0x10,%esp
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	0f 88 89 00 00 00    	js     801f48 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ebf:	83 ec 0c             	sub    $0xc,%esp
  801ec2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ec5:	e8 02 f5 ff ff       	call   8013cc <fd2data>
  801eca:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ed1:	50                   	push   %eax
  801ed2:	6a 00                	push   $0x0
  801ed4:	56                   	push   %esi
  801ed5:	6a 00                	push   $0x0
  801ed7:	e8 32 ef ff ff       	call   800e0e <sys_page_map>
  801edc:	89 c3                	mov    %eax,%ebx
  801ede:	83 c4 20             	add    $0x20,%esp
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	78 55                	js     801f3a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ee5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eee:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801efa:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f03:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f08:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f0f:	83 ec 0c             	sub    $0xc,%esp
  801f12:	ff 75 f4             	pushl  -0xc(%ebp)
  801f15:	e8 a2 f4 ff ff       	call   8013bc <fd2num>
  801f1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f1d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f1f:	83 c4 04             	add    $0x4,%esp
  801f22:	ff 75 f0             	pushl  -0x10(%ebp)
  801f25:	e8 92 f4 ff ff       	call   8013bc <fd2num>
  801f2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f2d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f30:	83 c4 10             	add    $0x10,%esp
  801f33:	ba 00 00 00 00       	mov    $0x0,%edx
  801f38:	eb 30                	jmp    801f6a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f3a:	83 ec 08             	sub    $0x8,%esp
  801f3d:	56                   	push   %esi
  801f3e:	6a 00                	push   $0x0
  801f40:	e8 0b ef ff ff       	call   800e50 <sys_page_unmap>
  801f45:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f48:	83 ec 08             	sub    $0x8,%esp
  801f4b:	ff 75 f0             	pushl  -0x10(%ebp)
  801f4e:	6a 00                	push   $0x0
  801f50:	e8 fb ee ff ff       	call   800e50 <sys_page_unmap>
  801f55:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f58:	83 ec 08             	sub    $0x8,%esp
  801f5b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f5e:	6a 00                	push   $0x0
  801f60:	e8 eb ee ff ff       	call   800e50 <sys_page_unmap>
  801f65:	83 c4 10             	add    $0x10,%esp
  801f68:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f6a:	89 d0                	mov    %edx,%eax
  801f6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f6f:	5b                   	pop    %ebx
  801f70:	5e                   	pop    %esi
  801f71:	5d                   	pop    %ebp
  801f72:	c3                   	ret    

00801f73 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7c:	50                   	push   %eax
  801f7d:	ff 75 08             	pushl  0x8(%ebp)
  801f80:	e8 ad f4 ff ff       	call   801432 <fd_lookup>
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	85 c0                	test   %eax,%eax
  801f8a:	78 18                	js     801fa4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f8c:	83 ec 0c             	sub    $0xc,%esp
  801f8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f92:	e8 35 f4 ff ff       	call   8013cc <fd2data>
	return _pipeisclosed(fd, p);
  801f97:	89 c2                	mov    %eax,%edx
  801f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9c:	e8 21 fd ff ff       	call   801cc2 <_pipeisclosed>
  801fa1:	83 c4 10             	add    $0x10,%esp
}
  801fa4:	c9                   	leave  
  801fa5:	c3                   	ret    

00801fa6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fa6:	55                   	push   %ebp
  801fa7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fa9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fae:	5d                   	pop    %ebp
  801faf:	c3                   	ret    

00801fb0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fb6:	68 a7 2a 80 00       	push   $0x802aa7
  801fbb:	ff 75 0c             	pushl  0xc(%ebp)
  801fbe:	e8 8e e9 ff ff       	call   800951 <strcpy>
	return 0;
}
  801fc3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc8:	c9                   	leave  
  801fc9:	c3                   	ret    

00801fca <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fca:	55                   	push   %ebp
  801fcb:	89 e5                	mov    %esp,%ebp
  801fcd:	57                   	push   %edi
  801fce:	56                   	push   %esi
  801fcf:	53                   	push   %ebx
  801fd0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fd6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fdb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fe1:	eb 2d                	jmp    802010 <devcons_write+0x46>
		m = n - tot;
  801fe3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fe6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fe8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801feb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ff0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ff3:	83 ec 04             	sub    $0x4,%esp
  801ff6:	53                   	push   %ebx
  801ff7:	03 45 0c             	add    0xc(%ebp),%eax
  801ffa:	50                   	push   %eax
  801ffb:	57                   	push   %edi
  801ffc:	e8 e2 ea ff ff       	call   800ae3 <memmove>
		sys_cputs(buf, m);
  802001:	83 c4 08             	add    $0x8,%esp
  802004:	53                   	push   %ebx
  802005:	57                   	push   %edi
  802006:	e8 04 ed ff ff       	call   800d0f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80200b:	01 de                	add    %ebx,%esi
  80200d:	83 c4 10             	add    $0x10,%esp
  802010:	89 f0                	mov    %esi,%eax
  802012:	3b 75 10             	cmp    0x10(%ebp),%esi
  802015:	72 cc                	jb     801fe3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802017:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80201a:	5b                   	pop    %ebx
  80201b:	5e                   	pop    %esi
  80201c:	5f                   	pop    %edi
  80201d:	5d                   	pop    %ebp
  80201e:	c3                   	ret    

0080201f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	83 ec 08             	sub    $0x8,%esp
  802025:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80202a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80202e:	74 2a                	je     80205a <devcons_read+0x3b>
  802030:	eb 05                	jmp    802037 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802032:	e8 75 ed ff ff       	call   800dac <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802037:	e8 f1 ec ff ff       	call   800d2d <sys_cgetc>
  80203c:	85 c0                	test   %eax,%eax
  80203e:	74 f2                	je     802032 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802040:	85 c0                	test   %eax,%eax
  802042:	78 16                	js     80205a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802044:	83 f8 04             	cmp    $0x4,%eax
  802047:	74 0c                	je     802055 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802049:	8b 55 0c             	mov    0xc(%ebp),%edx
  80204c:	88 02                	mov    %al,(%edx)
	return 1;
  80204e:	b8 01 00 00 00       	mov    $0x1,%eax
  802053:	eb 05                	jmp    80205a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802055:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80205a:	c9                   	leave  
  80205b:	c3                   	ret    

0080205c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80205c:	55                   	push   %ebp
  80205d:	89 e5                	mov    %esp,%ebp
  80205f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802062:	8b 45 08             	mov    0x8(%ebp),%eax
  802065:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802068:	6a 01                	push   $0x1
  80206a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80206d:	50                   	push   %eax
  80206e:	e8 9c ec ff ff       	call   800d0f <sys_cputs>
}
  802073:	83 c4 10             	add    $0x10,%esp
  802076:	c9                   	leave  
  802077:	c3                   	ret    

00802078 <getchar>:

int
getchar(void)
{
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
  80207b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80207e:	6a 01                	push   $0x1
  802080:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802083:	50                   	push   %eax
  802084:	6a 00                	push   $0x0
  802086:	e8 0d f6 ff ff       	call   801698 <read>
	if (r < 0)
  80208b:	83 c4 10             	add    $0x10,%esp
  80208e:	85 c0                	test   %eax,%eax
  802090:	78 0f                	js     8020a1 <getchar+0x29>
		return r;
	if (r < 1)
  802092:	85 c0                	test   %eax,%eax
  802094:	7e 06                	jle    80209c <getchar+0x24>
		return -E_EOF;
	return c;
  802096:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80209a:	eb 05                	jmp    8020a1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80209c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020a1:	c9                   	leave  
  8020a2:	c3                   	ret    

008020a3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020a3:	55                   	push   %ebp
  8020a4:	89 e5                	mov    %esp,%ebp
  8020a6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ac:	50                   	push   %eax
  8020ad:	ff 75 08             	pushl  0x8(%ebp)
  8020b0:	e8 7d f3 ff ff       	call   801432 <fd_lookup>
  8020b5:	83 c4 10             	add    $0x10,%esp
  8020b8:	85 c0                	test   %eax,%eax
  8020ba:	78 11                	js     8020cd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020bf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020c5:	39 10                	cmp    %edx,(%eax)
  8020c7:	0f 94 c0             	sete   %al
  8020ca:	0f b6 c0             	movzbl %al,%eax
}
  8020cd:	c9                   	leave  
  8020ce:	c3                   	ret    

008020cf <opencons>:

int
opencons(void)
{
  8020cf:	55                   	push   %ebp
  8020d0:	89 e5                	mov    %esp,%ebp
  8020d2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d8:	50                   	push   %eax
  8020d9:	e8 05 f3 ff ff       	call   8013e3 <fd_alloc>
  8020de:	83 c4 10             	add    $0x10,%esp
		return r;
  8020e1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020e3:	85 c0                	test   %eax,%eax
  8020e5:	78 3e                	js     802125 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020e7:	83 ec 04             	sub    $0x4,%esp
  8020ea:	68 07 04 00 00       	push   $0x407
  8020ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8020f2:	6a 00                	push   $0x0
  8020f4:	e8 d2 ec ff ff       	call   800dcb <sys_page_alloc>
  8020f9:	83 c4 10             	add    $0x10,%esp
		return r;
  8020fc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020fe:	85 c0                	test   %eax,%eax
  802100:	78 23                	js     802125 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802102:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802108:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80210d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802110:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802117:	83 ec 0c             	sub    $0xc,%esp
  80211a:	50                   	push   %eax
  80211b:	e8 9c f2 ff ff       	call   8013bc <fd2num>
  802120:	89 c2                	mov    %eax,%edx
  802122:	83 c4 10             	add    $0x10,%esp
}
  802125:	89 d0                	mov    %edx,%eax
  802127:	c9                   	leave  
  802128:	c3                   	ret    

00802129 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802129:	55                   	push   %ebp
  80212a:	89 e5                	mov    %esp,%ebp
  80212c:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  80212f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802136:	75 52                	jne    80218a <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  802138:	83 ec 04             	sub    $0x4,%esp
  80213b:	6a 07                	push   $0x7
  80213d:	68 00 f0 bf ee       	push   $0xeebff000
  802142:	6a 00                	push   $0x0
  802144:	e8 82 ec ff ff       	call   800dcb <sys_page_alloc>
  802149:	83 c4 10             	add    $0x10,%esp
  80214c:	85 c0                	test   %eax,%eax
  80214e:	79 12                	jns    802162 <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  802150:	50                   	push   %eax
  802151:	68 c0 28 80 00       	push   $0x8028c0
  802156:	6a 23                	push   $0x23
  802158:	68 b3 2a 80 00       	push   $0x802ab3
  80215d:	e8 e2 e0 ff ff       	call   800244 <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  802162:	83 ec 08             	sub    $0x8,%esp
  802165:	68 94 21 80 00       	push   $0x802194
  80216a:	6a 00                	push   $0x0
  80216c:	e8 a5 ed ff ff       	call   800f16 <sys_env_set_pgfault_upcall>
  802171:	83 c4 10             	add    $0x10,%esp
  802174:	85 c0                	test   %eax,%eax
  802176:	79 12                	jns    80218a <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  802178:	50                   	push   %eax
  802179:	68 40 29 80 00       	push   $0x802940
  80217e:	6a 26                	push   $0x26
  802180:	68 b3 2a 80 00       	push   $0x802ab3
  802185:	e8 ba e0 ff ff       	call   800244 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80218a:	8b 45 08             	mov    0x8(%ebp),%eax
  80218d:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802192:	c9                   	leave  
  802193:	c3                   	ret    

00802194 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802194:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802195:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80219a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80219c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  80219f:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  8021a3:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  8021a8:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  8021ac:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8021ae:	83 c4 08             	add    $0x8,%esp
	popal 
  8021b1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8021b2:	83 c4 04             	add    $0x4,%esp
	popfl
  8021b5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8021b6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8021b7:	c3                   	ret    
  8021b8:	66 90                	xchg   %ax,%ax
  8021ba:	66 90                	xchg   %ax,%ax
  8021bc:	66 90                	xchg   %ax,%ax
  8021be:	66 90                	xchg   %ax,%ax

008021c0 <__udivdi3>:
  8021c0:	55                   	push   %ebp
  8021c1:	57                   	push   %edi
  8021c2:	56                   	push   %esi
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 1c             	sub    $0x1c,%esp
  8021c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021d7:	85 f6                	test   %esi,%esi
  8021d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021dd:	89 ca                	mov    %ecx,%edx
  8021df:	89 f8                	mov    %edi,%eax
  8021e1:	75 3d                	jne    802220 <__udivdi3+0x60>
  8021e3:	39 cf                	cmp    %ecx,%edi
  8021e5:	0f 87 c5 00 00 00    	ja     8022b0 <__udivdi3+0xf0>
  8021eb:	85 ff                	test   %edi,%edi
  8021ed:	89 fd                	mov    %edi,%ebp
  8021ef:	75 0b                	jne    8021fc <__udivdi3+0x3c>
  8021f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f6:	31 d2                	xor    %edx,%edx
  8021f8:	f7 f7                	div    %edi
  8021fa:	89 c5                	mov    %eax,%ebp
  8021fc:	89 c8                	mov    %ecx,%eax
  8021fe:	31 d2                	xor    %edx,%edx
  802200:	f7 f5                	div    %ebp
  802202:	89 c1                	mov    %eax,%ecx
  802204:	89 d8                	mov    %ebx,%eax
  802206:	89 cf                	mov    %ecx,%edi
  802208:	f7 f5                	div    %ebp
  80220a:	89 c3                	mov    %eax,%ebx
  80220c:	89 d8                	mov    %ebx,%eax
  80220e:	89 fa                	mov    %edi,%edx
  802210:	83 c4 1c             	add    $0x1c,%esp
  802213:	5b                   	pop    %ebx
  802214:	5e                   	pop    %esi
  802215:	5f                   	pop    %edi
  802216:	5d                   	pop    %ebp
  802217:	c3                   	ret    
  802218:	90                   	nop
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	39 ce                	cmp    %ecx,%esi
  802222:	77 74                	ja     802298 <__udivdi3+0xd8>
  802224:	0f bd fe             	bsr    %esi,%edi
  802227:	83 f7 1f             	xor    $0x1f,%edi
  80222a:	0f 84 98 00 00 00    	je     8022c8 <__udivdi3+0x108>
  802230:	bb 20 00 00 00       	mov    $0x20,%ebx
  802235:	89 f9                	mov    %edi,%ecx
  802237:	89 c5                	mov    %eax,%ebp
  802239:	29 fb                	sub    %edi,%ebx
  80223b:	d3 e6                	shl    %cl,%esi
  80223d:	89 d9                	mov    %ebx,%ecx
  80223f:	d3 ed                	shr    %cl,%ebp
  802241:	89 f9                	mov    %edi,%ecx
  802243:	d3 e0                	shl    %cl,%eax
  802245:	09 ee                	or     %ebp,%esi
  802247:	89 d9                	mov    %ebx,%ecx
  802249:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80224d:	89 d5                	mov    %edx,%ebp
  80224f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802253:	d3 ed                	shr    %cl,%ebp
  802255:	89 f9                	mov    %edi,%ecx
  802257:	d3 e2                	shl    %cl,%edx
  802259:	89 d9                	mov    %ebx,%ecx
  80225b:	d3 e8                	shr    %cl,%eax
  80225d:	09 c2                	or     %eax,%edx
  80225f:	89 d0                	mov    %edx,%eax
  802261:	89 ea                	mov    %ebp,%edx
  802263:	f7 f6                	div    %esi
  802265:	89 d5                	mov    %edx,%ebp
  802267:	89 c3                	mov    %eax,%ebx
  802269:	f7 64 24 0c          	mull   0xc(%esp)
  80226d:	39 d5                	cmp    %edx,%ebp
  80226f:	72 10                	jb     802281 <__udivdi3+0xc1>
  802271:	8b 74 24 08          	mov    0x8(%esp),%esi
  802275:	89 f9                	mov    %edi,%ecx
  802277:	d3 e6                	shl    %cl,%esi
  802279:	39 c6                	cmp    %eax,%esi
  80227b:	73 07                	jae    802284 <__udivdi3+0xc4>
  80227d:	39 d5                	cmp    %edx,%ebp
  80227f:	75 03                	jne    802284 <__udivdi3+0xc4>
  802281:	83 eb 01             	sub    $0x1,%ebx
  802284:	31 ff                	xor    %edi,%edi
  802286:	89 d8                	mov    %ebx,%eax
  802288:	89 fa                	mov    %edi,%edx
  80228a:	83 c4 1c             	add    $0x1c,%esp
  80228d:	5b                   	pop    %ebx
  80228e:	5e                   	pop    %esi
  80228f:	5f                   	pop    %edi
  802290:	5d                   	pop    %ebp
  802291:	c3                   	ret    
  802292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802298:	31 ff                	xor    %edi,%edi
  80229a:	31 db                	xor    %ebx,%ebx
  80229c:	89 d8                	mov    %ebx,%eax
  80229e:	89 fa                	mov    %edi,%edx
  8022a0:	83 c4 1c             	add    $0x1c,%esp
  8022a3:	5b                   	pop    %ebx
  8022a4:	5e                   	pop    %esi
  8022a5:	5f                   	pop    %edi
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    
  8022a8:	90                   	nop
  8022a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	89 d8                	mov    %ebx,%eax
  8022b2:	f7 f7                	div    %edi
  8022b4:	31 ff                	xor    %edi,%edi
  8022b6:	89 c3                	mov    %eax,%ebx
  8022b8:	89 d8                	mov    %ebx,%eax
  8022ba:	89 fa                	mov    %edi,%edx
  8022bc:	83 c4 1c             	add    $0x1c,%esp
  8022bf:	5b                   	pop    %ebx
  8022c0:	5e                   	pop    %esi
  8022c1:	5f                   	pop    %edi
  8022c2:	5d                   	pop    %ebp
  8022c3:	c3                   	ret    
  8022c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c8:	39 ce                	cmp    %ecx,%esi
  8022ca:	72 0c                	jb     8022d8 <__udivdi3+0x118>
  8022cc:	31 db                	xor    %ebx,%ebx
  8022ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022d2:	0f 87 34 ff ff ff    	ja     80220c <__udivdi3+0x4c>
  8022d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022dd:	e9 2a ff ff ff       	jmp    80220c <__udivdi3+0x4c>
  8022e2:	66 90                	xchg   %ax,%ax
  8022e4:	66 90                	xchg   %ax,%ax
  8022e6:	66 90                	xchg   %ax,%ax
  8022e8:	66 90                	xchg   %ax,%ax
  8022ea:	66 90                	xchg   %ax,%ax
  8022ec:	66 90                	xchg   %ax,%ax
  8022ee:	66 90                	xchg   %ax,%ax

008022f0 <__umoddi3>:
  8022f0:	55                   	push   %ebp
  8022f1:	57                   	push   %edi
  8022f2:	56                   	push   %esi
  8022f3:	53                   	push   %ebx
  8022f4:	83 ec 1c             	sub    $0x1c,%esp
  8022f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802303:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802307:	85 d2                	test   %edx,%edx
  802309:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80230d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802311:	89 f3                	mov    %esi,%ebx
  802313:	89 3c 24             	mov    %edi,(%esp)
  802316:	89 74 24 04          	mov    %esi,0x4(%esp)
  80231a:	75 1c                	jne    802338 <__umoddi3+0x48>
  80231c:	39 f7                	cmp    %esi,%edi
  80231e:	76 50                	jbe    802370 <__umoddi3+0x80>
  802320:	89 c8                	mov    %ecx,%eax
  802322:	89 f2                	mov    %esi,%edx
  802324:	f7 f7                	div    %edi
  802326:	89 d0                	mov    %edx,%eax
  802328:	31 d2                	xor    %edx,%edx
  80232a:	83 c4 1c             	add    $0x1c,%esp
  80232d:	5b                   	pop    %ebx
  80232e:	5e                   	pop    %esi
  80232f:	5f                   	pop    %edi
  802330:	5d                   	pop    %ebp
  802331:	c3                   	ret    
  802332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802338:	39 f2                	cmp    %esi,%edx
  80233a:	89 d0                	mov    %edx,%eax
  80233c:	77 52                	ja     802390 <__umoddi3+0xa0>
  80233e:	0f bd ea             	bsr    %edx,%ebp
  802341:	83 f5 1f             	xor    $0x1f,%ebp
  802344:	75 5a                	jne    8023a0 <__umoddi3+0xb0>
  802346:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80234a:	0f 82 e0 00 00 00    	jb     802430 <__umoddi3+0x140>
  802350:	39 0c 24             	cmp    %ecx,(%esp)
  802353:	0f 86 d7 00 00 00    	jbe    802430 <__umoddi3+0x140>
  802359:	8b 44 24 08          	mov    0x8(%esp),%eax
  80235d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802361:	83 c4 1c             	add    $0x1c,%esp
  802364:	5b                   	pop    %ebx
  802365:	5e                   	pop    %esi
  802366:	5f                   	pop    %edi
  802367:	5d                   	pop    %ebp
  802368:	c3                   	ret    
  802369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802370:	85 ff                	test   %edi,%edi
  802372:	89 fd                	mov    %edi,%ebp
  802374:	75 0b                	jne    802381 <__umoddi3+0x91>
  802376:	b8 01 00 00 00       	mov    $0x1,%eax
  80237b:	31 d2                	xor    %edx,%edx
  80237d:	f7 f7                	div    %edi
  80237f:	89 c5                	mov    %eax,%ebp
  802381:	89 f0                	mov    %esi,%eax
  802383:	31 d2                	xor    %edx,%edx
  802385:	f7 f5                	div    %ebp
  802387:	89 c8                	mov    %ecx,%eax
  802389:	f7 f5                	div    %ebp
  80238b:	89 d0                	mov    %edx,%eax
  80238d:	eb 99                	jmp    802328 <__umoddi3+0x38>
  80238f:	90                   	nop
  802390:	89 c8                	mov    %ecx,%eax
  802392:	89 f2                	mov    %esi,%edx
  802394:	83 c4 1c             	add    $0x1c,%esp
  802397:	5b                   	pop    %ebx
  802398:	5e                   	pop    %esi
  802399:	5f                   	pop    %edi
  80239a:	5d                   	pop    %ebp
  80239b:	c3                   	ret    
  80239c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	8b 34 24             	mov    (%esp),%esi
  8023a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023a8:	89 e9                	mov    %ebp,%ecx
  8023aa:	29 ef                	sub    %ebp,%edi
  8023ac:	d3 e0                	shl    %cl,%eax
  8023ae:	89 f9                	mov    %edi,%ecx
  8023b0:	89 f2                	mov    %esi,%edx
  8023b2:	d3 ea                	shr    %cl,%edx
  8023b4:	89 e9                	mov    %ebp,%ecx
  8023b6:	09 c2                	or     %eax,%edx
  8023b8:	89 d8                	mov    %ebx,%eax
  8023ba:	89 14 24             	mov    %edx,(%esp)
  8023bd:	89 f2                	mov    %esi,%edx
  8023bf:	d3 e2                	shl    %cl,%edx
  8023c1:	89 f9                	mov    %edi,%ecx
  8023c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023cb:	d3 e8                	shr    %cl,%eax
  8023cd:	89 e9                	mov    %ebp,%ecx
  8023cf:	89 c6                	mov    %eax,%esi
  8023d1:	d3 e3                	shl    %cl,%ebx
  8023d3:	89 f9                	mov    %edi,%ecx
  8023d5:	89 d0                	mov    %edx,%eax
  8023d7:	d3 e8                	shr    %cl,%eax
  8023d9:	89 e9                	mov    %ebp,%ecx
  8023db:	09 d8                	or     %ebx,%eax
  8023dd:	89 d3                	mov    %edx,%ebx
  8023df:	89 f2                	mov    %esi,%edx
  8023e1:	f7 34 24             	divl   (%esp)
  8023e4:	89 d6                	mov    %edx,%esi
  8023e6:	d3 e3                	shl    %cl,%ebx
  8023e8:	f7 64 24 04          	mull   0x4(%esp)
  8023ec:	39 d6                	cmp    %edx,%esi
  8023ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023f2:	89 d1                	mov    %edx,%ecx
  8023f4:	89 c3                	mov    %eax,%ebx
  8023f6:	72 08                	jb     802400 <__umoddi3+0x110>
  8023f8:	75 11                	jne    80240b <__umoddi3+0x11b>
  8023fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023fe:	73 0b                	jae    80240b <__umoddi3+0x11b>
  802400:	2b 44 24 04          	sub    0x4(%esp),%eax
  802404:	1b 14 24             	sbb    (%esp),%edx
  802407:	89 d1                	mov    %edx,%ecx
  802409:	89 c3                	mov    %eax,%ebx
  80240b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80240f:	29 da                	sub    %ebx,%edx
  802411:	19 ce                	sbb    %ecx,%esi
  802413:	89 f9                	mov    %edi,%ecx
  802415:	89 f0                	mov    %esi,%eax
  802417:	d3 e0                	shl    %cl,%eax
  802419:	89 e9                	mov    %ebp,%ecx
  80241b:	d3 ea                	shr    %cl,%edx
  80241d:	89 e9                	mov    %ebp,%ecx
  80241f:	d3 ee                	shr    %cl,%esi
  802421:	09 d0                	or     %edx,%eax
  802423:	89 f2                	mov    %esi,%edx
  802425:	83 c4 1c             	add    $0x1c,%esp
  802428:	5b                   	pop    %ebx
  802429:	5e                   	pop    %esi
  80242a:	5f                   	pop    %edi
  80242b:	5d                   	pop    %ebp
  80242c:	c3                   	ret    
  80242d:	8d 76 00             	lea    0x0(%esi),%esi
  802430:	29 f9                	sub    %edi,%ecx
  802432:	19 d6                	sbb    %edx,%esi
  802434:	89 74 24 04          	mov    %esi,0x4(%esp)
  802438:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80243c:	e9 18 ff ff ff       	jmp    802359 <__umoddi3+0x69>
