
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 a6 01 00 00       	call   8001d7 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 a0 24 80 00       	push   $0x8024a0
  800043:	e8 1e 1a 00 00       	call   801a66 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 a5 24 80 00       	push   $0x8024a5
  800057:	6a 0c                	push   $0xc
  800059:	68 b3 24 80 00       	push   $0x8024b3
  80005e:	e8 d4 01 00 00       	call   800237 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 8b 16 00 00       	call   8016f9 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0) 
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 a3 15 00 00       	call   801624 <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 c8 24 80 00       	push   $0x8024c8
  800090:	6a 0f                	push   $0xf
  800092:	68 b3 24 80 00       	push   $0x8024b3
  800097:	e8 9b 01 00 00       	call   800237 <_panic>
	cprintf("line14: n = %d\n", n);
  80009c:	83 ec 08             	sub    $0x8,%esp
  80009f:	50                   	push   %eax
  8000a0:	68 d2 24 80 00       	push   $0x8024d2
  8000a5:	e8 66 02 00 00       	call   800310 <cprintf>

	if ((r = fork()) < 0)
  8000aa:	e8 d6 0f 00 00       	call   801085 <fork>
  8000af:	89 c7                	mov    %eax,%edi
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <umain+0x97>
		panic("fork: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 9e 29 80 00       	push   $0x80299e
  8000be:	6a 13                	push   $0x13
  8000c0:	68 b3 24 80 00       	push   $0x8024b3
  8000c5:	e8 6d 01 00 00       	call   800237 <_panic>
	if (r == 0) {
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	0f 85 ab 00 00 00    	jne    80017d <umain+0x14a>
		seek(fd, 0);
  8000d2:	83 ec 08             	sub    $0x8,%esp
  8000d5:	6a 00                	push   $0x0
  8000d7:	53                   	push   %ebx
  8000d8:	e8 1c 16 00 00       	call   8016f9 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000dd:	c7 04 24 28 25 80 00 	movl   $0x802528,(%esp)
  8000e4:	e8 27 02 00 00       	call   800310 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000e9:	83 c4 0c             	add    $0xc,%esp
  8000ec:	68 00 02 00 00       	push   $0x200
  8000f1:	68 20 40 80 00       	push   $0x804020
  8000f6:	53                   	push   %ebx
  8000f7:	e8 28 15 00 00       	call   801624 <readn>
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	39 c6                	cmp    %eax,%esi
  800101:	74 16                	je     800119 <umain+0xe6>
			panic("read in parent got %d, read in child got %d", n, n2);
  800103:	83 ec 0c             	sub    $0xc,%esp
  800106:	50                   	push   %eax
  800107:	56                   	push   %esi
  800108:	68 6c 25 80 00       	push   $0x80256c
  80010d:	6a 18                	push   $0x18
  80010f:	68 b3 24 80 00       	push   $0x8024b3
  800114:	e8 1e 01 00 00       	call   800237 <_panic>
		cprintf("line23: n2 = %d\n", n2);
  800119:	83 ec 08             	sub    $0x8,%esp
  80011c:	56                   	push   %esi
  80011d:	68 e2 24 80 00       	push   $0x8024e2
  800122:	e8 e9 01 00 00       	call   800310 <cprintf>
		
		if (memcmp(buf, buf2, n) != 0)
  800127:	83 c4 0c             	add    $0xc,%esp
  80012a:	56                   	push   %esi
  80012b:	68 20 40 80 00       	push   $0x804020
  800130:	68 20 42 80 00       	push   $0x804220
  800135:	e8 17 0a 00 00       	call   800b51 <memcmp>
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	85 c0                	test   %eax,%eax
  80013f:	74 14                	je     800155 <umain+0x122>
			panic("read in parent got different bytes from read in child");
  800141:	83 ec 04             	sub    $0x4,%esp
  800144:	68 98 25 80 00       	push   $0x802598
  800149:	6a 1c                	push   $0x1c
  80014b:	68 b3 24 80 00       	push   $0x8024b3
  800150:	e8 e2 00 00 00       	call   800237 <_panic>
		cprintf("read in child succeeded\n");
  800155:	83 ec 0c             	sub    $0xc,%esp
  800158:	68 f3 24 80 00       	push   $0x8024f3
  80015d:	e8 ae 01 00 00       	call   800310 <cprintf>
		seek(fd, 0);
  800162:	83 c4 08             	add    $0x8,%esp
  800165:	6a 00                	push   $0x0
  800167:	53                   	push   %ebx
  800168:	e8 8c 15 00 00       	call   8016f9 <seek>
		close(fd);
  80016d:	89 1c 24             	mov    %ebx,(%esp)
  800170:	e8 e2 12 00 00       	call   801457 <close>
		exit();
  800175:	e8 a3 00 00 00       	call   80021d <exit>
  80017a:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	57                   	push   %edi
  800181:	e8 e0 1c 00 00       	call   801e66 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800186:	83 c4 0c             	add    $0xc,%esp
  800189:	68 00 02 00 00       	push   $0x200
  80018e:	68 20 40 80 00       	push   $0x804020
  800193:	53                   	push   %ebx
  800194:	e8 8b 14 00 00       	call   801624 <readn>
  800199:	83 c4 10             	add    $0x10,%esp
  80019c:	39 c6                	cmp    %eax,%esi
  80019e:	74 16                	je     8001b6 <umain+0x183>
		panic("read in parent got %d, then got %d", n, n2);
  8001a0:	83 ec 0c             	sub    $0xc,%esp
  8001a3:	50                   	push   %eax
  8001a4:	56                   	push   %esi
  8001a5:	68 d0 25 80 00       	push   $0x8025d0
  8001aa:	6a 24                	push   $0x24
  8001ac:	68 b3 24 80 00       	push   $0x8024b3
  8001b1:	e8 81 00 00 00       	call   800237 <_panic>
	cprintf("read in parent succeeded\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 0c 25 80 00       	push   $0x80250c
  8001be:	e8 4d 01 00 00       	call   800310 <cprintf>
	close(fd);
  8001c3:	89 1c 24             	mov    %ebx,(%esp)
  8001c6:	e8 8c 12 00 00       	call   801457 <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8001cb:	cc                   	int3   

	breakpoint();
}
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d2:	5b                   	pop    %ebx
  8001d3:	5e                   	pop    %esi
  8001d4:	5f                   	pop    %edi
  8001d5:	5d                   	pop    %ebp
  8001d6:	c3                   	ret    

008001d7 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	56                   	push   %esi
  8001db:	53                   	push   %ebx
  8001dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001df:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e2:	e8 99 0b 00 00       	call   800d80 <sys_getenvid>
  8001e7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ec:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ef:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f4:	a3 20 44 80 00       	mov    %eax,0x804420
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f9:	85 db                	test   %ebx,%ebx
  8001fb:	7e 07                	jle    800204 <libmain+0x2d>
		binaryname = argv[0];
  8001fd:	8b 06                	mov    (%esi),%eax
  8001ff:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800204:	83 ec 08             	sub    $0x8,%esp
  800207:	56                   	push   %esi
  800208:	53                   	push   %ebx
  800209:	e8 25 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020e:	e8 0a 00 00 00       	call   80021d <exit>
}
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800219:	5b                   	pop    %ebx
  80021a:	5e                   	pop    %esi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800223:	e8 5a 12 00 00       	call   801482 <close_all>
	sys_env_destroy(0);
  800228:	83 ec 0c             	sub    $0xc,%esp
  80022b:	6a 00                	push   $0x0
  80022d:	e8 0d 0b 00 00       	call   800d3f <sys_env_destroy>
}
  800232:	83 c4 10             	add    $0x10,%esp
  800235:	c9                   	leave  
  800236:	c3                   	ret    

00800237 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	56                   	push   %esi
  80023b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800245:	e8 36 0b 00 00       	call   800d80 <sys_getenvid>
  80024a:	83 ec 0c             	sub    $0xc,%esp
  80024d:	ff 75 0c             	pushl  0xc(%ebp)
  800250:	ff 75 08             	pushl  0x8(%ebp)
  800253:	56                   	push   %esi
  800254:	50                   	push   %eax
  800255:	68 00 26 80 00       	push   $0x802600
  80025a:	e8 b1 00 00 00       	call   800310 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025f:	83 c4 18             	add    $0x18,%esp
  800262:	53                   	push   %ebx
  800263:	ff 75 10             	pushl  0x10(%ebp)
  800266:	e8 54 00 00 00       	call   8002bf <vcprintf>
	cprintf("\n");
  80026b:	c7 04 24 f1 24 80 00 	movl   $0x8024f1,(%esp)
  800272:	e8 99 00 00 00       	call   800310 <cprintf>
  800277:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027a:	cc                   	int3   
  80027b:	eb fd                	jmp    80027a <_panic+0x43>

0080027d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	53                   	push   %ebx
  800281:	83 ec 04             	sub    $0x4,%esp
  800284:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800287:	8b 13                	mov    (%ebx),%edx
  800289:	8d 42 01             	lea    0x1(%edx),%eax
  80028c:	89 03                	mov    %eax,(%ebx)
  80028e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800291:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800295:	3d ff 00 00 00       	cmp    $0xff,%eax
  80029a:	75 1a                	jne    8002b6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80029c:	83 ec 08             	sub    $0x8,%esp
  80029f:	68 ff 00 00 00       	push   $0xff
  8002a4:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a7:	50                   	push   %eax
  8002a8:	e8 55 0a 00 00       	call   800d02 <sys_cputs>
		b->idx = 0;
  8002ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bd:	c9                   	leave  
  8002be:	c3                   	ret    

008002bf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002cf:	00 00 00 
	b.cnt = 0;
  8002d2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002dc:	ff 75 0c             	pushl  0xc(%ebp)
  8002df:	ff 75 08             	pushl  0x8(%ebp)
  8002e2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e8:	50                   	push   %eax
  8002e9:	68 7d 02 80 00       	push   $0x80027d
  8002ee:	e8 54 01 00 00       	call   800447 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f3:	83 c4 08             	add    $0x8,%esp
  8002f6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002fc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800302:	50                   	push   %eax
  800303:	e8 fa 09 00 00       	call   800d02 <sys_cputs>

	return b.cnt;
}
  800308:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030e:	c9                   	leave  
  80030f:	c3                   	ret    

00800310 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800316:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800319:	50                   	push   %eax
  80031a:	ff 75 08             	pushl  0x8(%ebp)
  80031d:	e8 9d ff ff ff       	call   8002bf <vcprintf>
	va_end(ap);

	return cnt;
}
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	57                   	push   %edi
  800328:	56                   	push   %esi
  800329:	53                   	push   %ebx
  80032a:	83 ec 1c             	sub    $0x1c,%esp
  80032d:	89 c7                	mov    %eax,%edi
  80032f:	89 d6                	mov    %edx,%esi
  800331:	8b 45 08             	mov    0x8(%ebp),%eax
  800334:	8b 55 0c             	mov    0xc(%ebp),%edx
  800337:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800340:	bb 00 00 00 00       	mov    $0x0,%ebx
  800345:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800348:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034b:	39 d3                	cmp    %edx,%ebx
  80034d:	72 05                	jb     800354 <printnum+0x30>
  80034f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800352:	77 45                	ja     800399 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800354:	83 ec 0c             	sub    $0xc,%esp
  800357:	ff 75 18             	pushl  0x18(%ebp)
  80035a:	8b 45 14             	mov    0x14(%ebp),%eax
  80035d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800360:	53                   	push   %ebx
  800361:	ff 75 10             	pushl  0x10(%ebp)
  800364:	83 ec 08             	sub    $0x8,%esp
  800367:	ff 75 e4             	pushl  -0x1c(%ebp)
  80036a:	ff 75 e0             	pushl  -0x20(%ebp)
  80036d:	ff 75 dc             	pushl  -0x24(%ebp)
  800370:	ff 75 d8             	pushl  -0x28(%ebp)
  800373:	e8 88 1e 00 00       	call   802200 <__udivdi3>
  800378:	83 c4 18             	add    $0x18,%esp
  80037b:	52                   	push   %edx
  80037c:	50                   	push   %eax
  80037d:	89 f2                	mov    %esi,%edx
  80037f:	89 f8                	mov    %edi,%eax
  800381:	e8 9e ff ff ff       	call   800324 <printnum>
  800386:	83 c4 20             	add    $0x20,%esp
  800389:	eb 18                	jmp    8003a3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038b:	83 ec 08             	sub    $0x8,%esp
  80038e:	56                   	push   %esi
  80038f:	ff 75 18             	pushl  0x18(%ebp)
  800392:	ff d7                	call   *%edi
  800394:	83 c4 10             	add    $0x10,%esp
  800397:	eb 03                	jmp    80039c <printnum+0x78>
  800399:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039c:	83 eb 01             	sub    $0x1,%ebx
  80039f:	85 db                	test   %ebx,%ebx
  8003a1:	7f e8                	jg     80038b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	56                   	push   %esi
  8003a7:	83 ec 04             	sub    $0x4,%esp
  8003aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b6:	e8 75 1f 00 00       	call   802330 <__umoddi3>
  8003bb:	83 c4 14             	add    $0x14,%esp
  8003be:	0f be 80 23 26 80 00 	movsbl 0x802623(%eax),%eax
  8003c5:	50                   	push   %eax
  8003c6:	ff d7                	call   *%edi
}
  8003c8:	83 c4 10             	add    $0x10,%esp
  8003cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ce:	5b                   	pop    %ebx
  8003cf:	5e                   	pop    %esi
  8003d0:	5f                   	pop    %edi
  8003d1:	5d                   	pop    %ebp
  8003d2:	c3                   	ret    

008003d3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d6:	83 fa 01             	cmp    $0x1,%edx
  8003d9:	7e 0e                	jle    8003e9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003db:	8b 10                	mov    (%eax),%edx
  8003dd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e0:	89 08                	mov    %ecx,(%eax)
  8003e2:	8b 02                	mov    (%edx),%eax
  8003e4:	8b 52 04             	mov    0x4(%edx),%edx
  8003e7:	eb 22                	jmp    80040b <getuint+0x38>
	else if (lflag)
  8003e9:	85 d2                	test   %edx,%edx
  8003eb:	74 10                	je     8003fd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f2:	89 08                	mov    %ecx,(%eax)
  8003f4:	8b 02                	mov    (%edx),%eax
  8003f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fb:	eb 0e                	jmp    80040b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003fd:	8b 10                	mov    (%eax),%edx
  8003ff:	8d 4a 04             	lea    0x4(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 02                	mov    (%edx),%eax
  800406:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040b:	5d                   	pop    %ebp
  80040c:	c3                   	ret    

0080040d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040d:	55                   	push   %ebp
  80040e:	89 e5                	mov    %esp,%ebp
  800410:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800413:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800417:	8b 10                	mov    (%eax),%edx
  800419:	3b 50 04             	cmp    0x4(%eax),%edx
  80041c:	73 0a                	jae    800428 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800421:	89 08                	mov    %ecx,(%eax)
  800423:	8b 45 08             	mov    0x8(%ebp),%eax
  800426:	88 02                	mov    %al,(%edx)
}
  800428:	5d                   	pop    %ebp
  800429:	c3                   	ret    

0080042a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800430:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800433:	50                   	push   %eax
  800434:	ff 75 10             	pushl  0x10(%ebp)
  800437:	ff 75 0c             	pushl  0xc(%ebp)
  80043a:	ff 75 08             	pushl  0x8(%ebp)
  80043d:	e8 05 00 00 00       	call   800447 <vprintfmt>
	va_end(ap);
}
  800442:	83 c4 10             	add    $0x10,%esp
  800445:	c9                   	leave  
  800446:	c3                   	ret    

00800447 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800447:	55                   	push   %ebp
  800448:	89 e5                	mov    %esp,%ebp
  80044a:	57                   	push   %edi
  80044b:	56                   	push   %esi
  80044c:	53                   	push   %ebx
  80044d:	83 ec 2c             	sub    $0x2c,%esp
  800450:	8b 75 08             	mov    0x8(%ebp),%esi
  800453:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800456:	8b 7d 10             	mov    0x10(%ebp),%edi
  800459:	eb 12                	jmp    80046d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045b:	85 c0                	test   %eax,%eax
  80045d:	0f 84 38 04 00 00    	je     80089b <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	53                   	push   %ebx
  800467:	50                   	push   %eax
  800468:	ff d6                	call   *%esi
  80046a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046d:	83 c7 01             	add    $0x1,%edi
  800470:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800474:	83 f8 25             	cmp    $0x25,%eax
  800477:	75 e2                	jne    80045b <vprintfmt+0x14>
  800479:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80047d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800484:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80048b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800492:	ba 00 00 00 00       	mov    $0x0,%edx
  800497:	eb 07                	jmp    8004a0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  80049c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8d 47 01             	lea    0x1(%edi),%eax
  8004a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a6:	0f b6 07             	movzbl (%edi),%eax
  8004a9:	0f b6 c8             	movzbl %al,%ecx
  8004ac:	83 e8 23             	sub    $0x23,%eax
  8004af:	3c 55                	cmp    $0x55,%al
  8004b1:	0f 87 c9 03 00 00    	ja     800880 <vprintfmt+0x439>
  8004b7:	0f b6 c0             	movzbl %al,%eax
  8004ba:	ff 24 85 60 27 80 00 	jmp    *0x802760(,%eax,4)
  8004c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004c8:	eb d6                	jmp    8004a0 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  8004ca:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  8004d1:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  8004d7:	eb 94                	jmp    80046d <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  8004d9:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  8004e0:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  8004e6:	eb 85                	jmp    80046d <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  8004e8:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  8004ef:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  8004f5:	e9 73 ff ff ff       	jmp    80046d <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  8004fa:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  800501:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  800507:	e9 61 ff ff ff       	jmp    80046d <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  80050c:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800513:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800516:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  800519:	e9 4f ff ff ff       	jmp    80046d <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80051e:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800525:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80052b:	e9 3d ff ff ff       	jmp    80046d <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  800530:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  800537:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80053d:	e9 2b ff ff ff       	jmp    80046d <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  800542:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  800549:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  80054f:	e9 19 ff ff ff       	jmp    80046d <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800554:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  80055b:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  800561:	e9 07 ff ff ff       	jmp    80046d <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  800566:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  80056d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800573:	e9 f5 fe ff ff       	jmp    80046d <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800578:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057b:	b8 00 00 00 00       	mov    $0x0,%eax
  800580:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800583:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800586:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80058a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80058d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800590:	83 fa 09             	cmp    $0x9,%edx
  800593:	77 3f                	ja     8005d4 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800595:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800598:	eb e9                	jmp    800583 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 48 04             	lea    0x4(%eax),%ecx
  8005a0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005a3:	8b 00                	mov    (%eax),%eax
  8005a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ab:	eb 2d                	jmp    8005da <vprintfmt+0x193>
  8005ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b0:	85 c0                	test   %eax,%eax
  8005b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b7:	0f 49 c8             	cmovns %eax,%ecx
  8005ba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c0:	e9 db fe ff ff       	jmp    8004a0 <vprintfmt+0x59>
  8005c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005c8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005cf:	e9 cc fe ff ff       	jmp    8004a0 <vprintfmt+0x59>
  8005d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005de:	0f 89 bc fe ff ff    	jns    8004a0 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005e4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ea:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005f1:	e9 aa fe ff ff       	jmp    8004a0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005f6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005fc:	e9 9f fe ff ff       	jmp    8004a0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8d 50 04             	lea    0x4(%eax),%edx
  800607:	89 55 14             	mov    %edx,0x14(%ebp)
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	ff 30                	pushl  (%eax)
  800610:	ff d6                	call   *%esi
			break;
  800612:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800615:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800618:	e9 50 fe ff ff       	jmp    80046d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8d 50 04             	lea    0x4(%eax),%edx
  800623:	89 55 14             	mov    %edx,0x14(%ebp)
  800626:	8b 00                	mov    (%eax),%eax
  800628:	99                   	cltd   
  800629:	31 d0                	xor    %edx,%eax
  80062b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80062d:	83 f8 0f             	cmp    $0xf,%eax
  800630:	7f 0b                	jg     80063d <vprintfmt+0x1f6>
  800632:	8b 14 85 c0 28 80 00 	mov    0x8028c0(,%eax,4),%edx
  800639:	85 d2                	test   %edx,%edx
  80063b:	75 18                	jne    800655 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80063d:	50                   	push   %eax
  80063e:	68 3b 26 80 00       	push   $0x80263b
  800643:	53                   	push   %ebx
  800644:	56                   	push   %esi
  800645:	e8 e0 fd ff ff       	call   80042a <printfmt>
  80064a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800650:	e9 18 fe ff ff       	jmp    80046d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800655:	52                   	push   %edx
  800656:	68 a5 2a 80 00       	push   $0x802aa5
  80065b:	53                   	push   %ebx
  80065c:	56                   	push   %esi
  80065d:	e8 c8 fd ff ff       	call   80042a <printfmt>
  800662:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800665:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800668:	e9 00 fe ff ff       	jmp    80046d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8d 50 04             	lea    0x4(%eax),%edx
  800673:	89 55 14             	mov    %edx,0x14(%ebp)
  800676:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800678:	85 ff                	test   %edi,%edi
  80067a:	b8 34 26 80 00       	mov    $0x802634,%eax
  80067f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800682:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800686:	0f 8e 94 00 00 00    	jle    800720 <vprintfmt+0x2d9>
  80068c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800690:	0f 84 98 00 00 00    	je     80072e <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	ff 75 d0             	pushl  -0x30(%ebp)
  80069c:	57                   	push   %edi
  80069d:	e8 81 02 00 00       	call   800923 <strnlen>
  8006a2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006a5:	29 c1                	sub    %eax,%ecx
  8006a7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006aa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ad:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006b7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b9:	eb 0f                	jmp    8006ca <vprintfmt+0x283>
					putch(padc, putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c4:	83 ef 01             	sub    $0x1,%edi
  8006c7:	83 c4 10             	add    $0x10,%esp
  8006ca:	85 ff                	test   %edi,%edi
  8006cc:	7f ed                	jg     8006bb <vprintfmt+0x274>
  8006ce:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006d1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006d4:	85 c9                	test   %ecx,%ecx
  8006d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006db:	0f 49 c1             	cmovns %ecx,%eax
  8006de:	29 c1                	sub    %eax,%ecx
  8006e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e9:	89 cb                	mov    %ecx,%ebx
  8006eb:	eb 4d                	jmp    80073a <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006ed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006f1:	74 1b                	je     80070e <vprintfmt+0x2c7>
  8006f3:	0f be c0             	movsbl %al,%eax
  8006f6:	83 e8 20             	sub    $0x20,%eax
  8006f9:	83 f8 5e             	cmp    $0x5e,%eax
  8006fc:	76 10                	jbe    80070e <vprintfmt+0x2c7>
					putch('?', putdat);
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	ff 75 0c             	pushl  0xc(%ebp)
  800704:	6a 3f                	push   $0x3f
  800706:	ff 55 08             	call   *0x8(%ebp)
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	eb 0d                	jmp    80071b <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	ff 75 0c             	pushl  0xc(%ebp)
  800714:	52                   	push   %edx
  800715:	ff 55 08             	call   *0x8(%ebp)
  800718:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071b:	83 eb 01             	sub    $0x1,%ebx
  80071e:	eb 1a                	jmp    80073a <vprintfmt+0x2f3>
  800720:	89 75 08             	mov    %esi,0x8(%ebp)
  800723:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800726:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800729:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80072c:	eb 0c                	jmp    80073a <vprintfmt+0x2f3>
  80072e:	89 75 08             	mov    %esi,0x8(%ebp)
  800731:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800734:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800737:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80073a:	83 c7 01             	add    $0x1,%edi
  80073d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800741:	0f be d0             	movsbl %al,%edx
  800744:	85 d2                	test   %edx,%edx
  800746:	74 23                	je     80076b <vprintfmt+0x324>
  800748:	85 f6                	test   %esi,%esi
  80074a:	78 a1                	js     8006ed <vprintfmt+0x2a6>
  80074c:	83 ee 01             	sub    $0x1,%esi
  80074f:	79 9c                	jns    8006ed <vprintfmt+0x2a6>
  800751:	89 df                	mov    %ebx,%edi
  800753:	8b 75 08             	mov    0x8(%ebp),%esi
  800756:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800759:	eb 18                	jmp    800773 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80075b:	83 ec 08             	sub    $0x8,%esp
  80075e:	53                   	push   %ebx
  80075f:	6a 20                	push   $0x20
  800761:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800763:	83 ef 01             	sub    $0x1,%edi
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	eb 08                	jmp    800773 <vprintfmt+0x32c>
  80076b:	89 df                	mov    %ebx,%edi
  80076d:	8b 75 08             	mov    0x8(%ebp),%esi
  800770:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800773:	85 ff                	test   %edi,%edi
  800775:	7f e4                	jg     80075b <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077a:	e9 ee fc ff ff       	jmp    80046d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80077f:	83 fa 01             	cmp    $0x1,%edx
  800782:	7e 16                	jle    80079a <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800784:	8b 45 14             	mov    0x14(%ebp),%eax
  800787:	8d 50 08             	lea    0x8(%eax),%edx
  80078a:	89 55 14             	mov    %edx,0x14(%ebp)
  80078d:	8b 50 04             	mov    0x4(%eax),%edx
  800790:	8b 00                	mov    (%eax),%eax
  800792:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800795:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800798:	eb 32                	jmp    8007cc <vprintfmt+0x385>
	else if (lflag)
  80079a:	85 d2                	test   %edx,%edx
  80079c:	74 18                	je     8007b6 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8d 50 04             	lea    0x4(%eax),%edx
  8007a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a7:	8b 00                	mov    (%eax),%eax
  8007a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ac:	89 c1                	mov    %eax,%ecx
  8007ae:	c1 f9 1f             	sar    $0x1f,%ecx
  8007b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b4:	eb 16                	jmp    8007cc <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  8007b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b9:	8d 50 04             	lea    0x4(%eax),%edx
  8007bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bf:	8b 00                	mov    (%eax),%eax
  8007c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c4:	89 c1                	mov    %eax,%ecx
  8007c6:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007d2:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007d7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007db:	79 6f                	jns    80084c <vprintfmt+0x405>
				putch('-', putdat);
  8007dd:	83 ec 08             	sub    $0x8,%esp
  8007e0:	53                   	push   %ebx
  8007e1:	6a 2d                	push   $0x2d
  8007e3:	ff d6                	call   *%esi
				num = -(long long) num;
  8007e5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007e8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007eb:	f7 d8                	neg    %eax
  8007ed:	83 d2 00             	adc    $0x0,%edx
  8007f0:	f7 da                	neg    %edx
  8007f2:	83 c4 10             	add    $0x10,%esp
  8007f5:	eb 55                	jmp    80084c <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fa:	e8 d4 fb ff ff       	call   8003d3 <getuint>
			base = 10;
  8007ff:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800804:	eb 46                	jmp    80084c <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800806:	8d 45 14             	lea    0x14(%ebp),%eax
  800809:	e8 c5 fb ff ff       	call   8003d3 <getuint>
			base = 8;
  80080e:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800813:	eb 37                	jmp    80084c <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800815:	83 ec 08             	sub    $0x8,%esp
  800818:	53                   	push   %ebx
  800819:	6a 30                	push   $0x30
  80081b:	ff d6                	call   *%esi
			putch('x', putdat);
  80081d:	83 c4 08             	add    $0x8,%esp
  800820:	53                   	push   %ebx
  800821:	6a 78                	push   $0x78
  800823:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800825:	8b 45 14             	mov    0x14(%ebp),%eax
  800828:	8d 50 04             	lea    0x4(%eax),%edx
  80082b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80082e:	8b 00                	mov    (%eax),%eax
  800830:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800835:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800838:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80083d:	eb 0d                	jmp    80084c <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80083f:	8d 45 14             	lea    0x14(%ebp),%eax
  800842:	e8 8c fb ff ff       	call   8003d3 <getuint>
			base = 16;
  800847:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80084c:	83 ec 0c             	sub    $0xc,%esp
  80084f:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800853:	51                   	push   %ecx
  800854:	ff 75 e0             	pushl  -0x20(%ebp)
  800857:	57                   	push   %edi
  800858:	52                   	push   %edx
  800859:	50                   	push   %eax
  80085a:	89 da                	mov    %ebx,%edx
  80085c:	89 f0                	mov    %esi,%eax
  80085e:	e8 c1 fa ff ff       	call   800324 <printnum>
			break;
  800863:	83 c4 20             	add    $0x20,%esp
  800866:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800869:	e9 ff fb ff ff       	jmp    80046d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	53                   	push   %ebx
  800872:	51                   	push   %ecx
  800873:	ff d6                	call   *%esi
			break;
  800875:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800878:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80087b:	e9 ed fb ff ff       	jmp    80046d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800880:	83 ec 08             	sub    $0x8,%esp
  800883:	53                   	push   %ebx
  800884:	6a 25                	push   $0x25
  800886:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800888:	83 c4 10             	add    $0x10,%esp
  80088b:	eb 03                	jmp    800890 <vprintfmt+0x449>
  80088d:	83 ef 01             	sub    $0x1,%edi
  800890:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800894:	75 f7                	jne    80088d <vprintfmt+0x446>
  800896:	e9 d2 fb ff ff       	jmp    80046d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80089b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5f                   	pop    %edi
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	83 ec 18             	sub    $0x18,%esp
  8008a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008b2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008c0:	85 c0                	test   %eax,%eax
  8008c2:	74 26                	je     8008ea <vsnprintf+0x47>
  8008c4:	85 d2                	test   %edx,%edx
  8008c6:	7e 22                	jle    8008ea <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c8:	ff 75 14             	pushl  0x14(%ebp)
  8008cb:	ff 75 10             	pushl  0x10(%ebp)
  8008ce:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d1:	50                   	push   %eax
  8008d2:	68 0d 04 80 00       	push   $0x80040d
  8008d7:	e8 6b fb ff ff       	call   800447 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008df:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e5:	83 c4 10             	add    $0x10,%esp
  8008e8:	eb 05                	jmp    8008ef <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008ef:	c9                   	leave  
  8008f0:	c3                   	ret    

008008f1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008fa:	50                   	push   %eax
  8008fb:	ff 75 10             	pushl  0x10(%ebp)
  8008fe:	ff 75 0c             	pushl  0xc(%ebp)
  800901:	ff 75 08             	pushl  0x8(%ebp)
  800904:	e8 9a ff ff ff       	call   8008a3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800909:	c9                   	leave  
  80090a:	c3                   	ret    

0080090b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
  800916:	eb 03                	jmp    80091b <strlen+0x10>
		n++;
  800918:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80091b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80091f:	75 f7                	jne    800918 <strlen+0xd>
		n++;
	return n;
}
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800929:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092c:	ba 00 00 00 00       	mov    $0x0,%edx
  800931:	eb 03                	jmp    800936 <strnlen+0x13>
		n++;
  800933:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800936:	39 c2                	cmp    %eax,%edx
  800938:	74 08                	je     800942 <strnlen+0x1f>
  80093a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80093e:	75 f3                	jne    800933 <strnlen+0x10>
  800940:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	53                   	push   %ebx
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80094e:	89 c2                	mov    %eax,%edx
  800950:	83 c2 01             	add    $0x1,%edx
  800953:	83 c1 01             	add    $0x1,%ecx
  800956:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80095a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80095d:	84 db                	test   %bl,%bl
  80095f:	75 ef                	jne    800950 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800961:	5b                   	pop    %ebx
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	53                   	push   %ebx
  800968:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80096b:	53                   	push   %ebx
  80096c:	e8 9a ff ff ff       	call   80090b <strlen>
  800971:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800974:	ff 75 0c             	pushl  0xc(%ebp)
  800977:	01 d8                	add    %ebx,%eax
  800979:	50                   	push   %eax
  80097a:	e8 c5 ff ff ff       	call   800944 <strcpy>
	return dst;
}
  80097f:	89 d8                	mov    %ebx,%eax
  800981:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800984:	c9                   	leave  
  800985:	c3                   	ret    

00800986 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	56                   	push   %esi
  80098a:	53                   	push   %ebx
  80098b:	8b 75 08             	mov    0x8(%ebp),%esi
  80098e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800991:	89 f3                	mov    %esi,%ebx
  800993:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800996:	89 f2                	mov    %esi,%edx
  800998:	eb 0f                	jmp    8009a9 <strncpy+0x23>
		*dst++ = *src;
  80099a:	83 c2 01             	add    $0x1,%edx
  80099d:	0f b6 01             	movzbl (%ecx),%eax
  8009a0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a3:	80 39 01             	cmpb   $0x1,(%ecx)
  8009a6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a9:	39 da                	cmp    %ebx,%edx
  8009ab:	75 ed                	jne    80099a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009ad:	89 f0                	mov    %esi,%eax
  8009af:	5b                   	pop    %ebx
  8009b0:	5e                   	pop    %esi
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	56                   	push   %esi
  8009b7:	53                   	push   %ebx
  8009b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8009bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009be:	8b 55 10             	mov    0x10(%ebp),%edx
  8009c1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c3:	85 d2                	test   %edx,%edx
  8009c5:	74 21                	je     8009e8 <strlcpy+0x35>
  8009c7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009cb:	89 f2                	mov    %esi,%edx
  8009cd:	eb 09                	jmp    8009d8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009cf:	83 c2 01             	add    $0x1,%edx
  8009d2:	83 c1 01             	add    $0x1,%ecx
  8009d5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d8:	39 c2                	cmp    %eax,%edx
  8009da:	74 09                	je     8009e5 <strlcpy+0x32>
  8009dc:	0f b6 19             	movzbl (%ecx),%ebx
  8009df:	84 db                	test   %bl,%bl
  8009e1:	75 ec                	jne    8009cf <strlcpy+0x1c>
  8009e3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009e5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009e8:	29 f0                	sub    %esi,%eax
}
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f7:	eb 06                	jmp    8009ff <strcmp+0x11>
		p++, q++;
  8009f9:	83 c1 01             	add    $0x1,%ecx
  8009fc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ff:	0f b6 01             	movzbl (%ecx),%eax
  800a02:	84 c0                	test   %al,%al
  800a04:	74 04                	je     800a0a <strcmp+0x1c>
  800a06:	3a 02                	cmp    (%edx),%al
  800a08:	74 ef                	je     8009f9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0a:	0f b6 c0             	movzbl %al,%eax
  800a0d:	0f b6 12             	movzbl (%edx),%edx
  800a10:	29 d0                	sub    %edx,%eax
}
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	53                   	push   %ebx
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1e:	89 c3                	mov    %eax,%ebx
  800a20:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a23:	eb 06                	jmp    800a2b <strncmp+0x17>
		n--, p++, q++;
  800a25:	83 c0 01             	add    $0x1,%eax
  800a28:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a2b:	39 d8                	cmp    %ebx,%eax
  800a2d:	74 15                	je     800a44 <strncmp+0x30>
  800a2f:	0f b6 08             	movzbl (%eax),%ecx
  800a32:	84 c9                	test   %cl,%cl
  800a34:	74 04                	je     800a3a <strncmp+0x26>
  800a36:	3a 0a                	cmp    (%edx),%cl
  800a38:	74 eb                	je     800a25 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3a:	0f b6 00             	movzbl (%eax),%eax
  800a3d:	0f b6 12             	movzbl (%edx),%edx
  800a40:	29 d0                	sub    %edx,%eax
  800a42:	eb 05                	jmp    800a49 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a49:	5b                   	pop    %ebx
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a56:	eb 07                	jmp    800a5f <strchr+0x13>
		if (*s == c)
  800a58:	38 ca                	cmp    %cl,%dl
  800a5a:	74 0f                	je     800a6b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a5c:	83 c0 01             	add    $0x1,%eax
  800a5f:	0f b6 10             	movzbl (%eax),%edx
  800a62:	84 d2                	test   %dl,%dl
  800a64:	75 f2                	jne    800a58 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a77:	eb 03                	jmp    800a7c <strfind+0xf>
  800a79:	83 c0 01             	add    $0x1,%eax
  800a7c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a7f:	38 ca                	cmp    %cl,%dl
  800a81:	74 04                	je     800a87 <strfind+0x1a>
  800a83:	84 d2                	test   %dl,%dl
  800a85:	75 f2                	jne    800a79 <strfind+0xc>
			break;
	return (char *) s;
}
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	57                   	push   %edi
  800a8d:	56                   	push   %esi
  800a8e:	53                   	push   %ebx
  800a8f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a92:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a95:	85 c9                	test   %ecx,%ecx
  800a97:	74 36                	je     800acf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a99:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9f:	75 28                	jne    800ac9 <memset+0x40>
  800aa1:	f6 c1 03             	test   $0x3,%cl
  800aa4:	75 23                	jne    800ac9 <memset+0x40>
		c &= 0xFF;
  800aa6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aaa:	89 d3                	mov    %edx,%ebx
  800aac:	c1 e3 08             	shl    $0x8,%ebx
  800aaf:	89 d6                	mov    %edx,%esi
  800ab1:	c1 e6 18             	shl    $0x18,%esi
  800ab4:	89 d0                	mov    %edx,%eax
  800ab6:	c1 e0 10             	shl    $0x10,%eax
  800ab9:	09 f0                	or     %esi,%eax
  800abb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800abd:	89 d8                	mov    %ebx,%eax
  800abf:	09 d0                	or     %edx,%eax
  800ac1:	c1 e9 02             	shr    $0x2,%ecx
  800ac4:	fc                   	cld    
  800ac5:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac7:	eb 06                	jmp    800acf <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acc:	fc                   	cld    
  800acd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800acf:	89 f8                	mov    %edi,%eax
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	57                   	push   %edi
  800ada:	56                   	push   %esi
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae4:	39 c6                	cmp    %eax,%esi
  800ae6:	73 35                	jae    800b1d <memmove+0x47>
  800ae8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aeb:	39 d0                	cmp    %edx,%eax
  800aed:	73 2e                	jae    800b1d <memmove+0x47>
		s += n;
		d += n;
  800aef:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af2:	89 d6                	mov    %edx,%esi
  800af4:	09 fe                	or     %edi,%esi
  800af6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800afc:	75 13                	jne    800b11 <memmove+0x3b>
  800afe:	f6 c1 03             	test   $0x3,%cl
  800b01:	75 0e                	jne    800b11 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b03:	83 ef 04             	sub    $0x4,%edi
  800b06:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b09:	c1 e9 02             	shr    $0x2,%ecx
  800b0c:	fd                   	std    
  800b0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0f:	eb 09                	jmp    800b1a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b11:	83 ef 01             	sub    $0x1,%edi
  800b14:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b17:	fd                   	std    
  800b18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b1a:	fc                   	cld    
  800b1b:	eb 1d                	jmp    800b3a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1d:	89 f2                	mov    %esi,%edx
  800b1f:	09 c2                	or     %eax,%edx
  800b21:	f6 c2 03             	test   $0x3,%dl
  800b24:	75 0f                	jne    800b35 <memmove+0x5f>
  800b26:	f6 c1 03             	test   $0x3,%cl
  800b29:	75 0a                	jne    800b35 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b2b:	c1 e9 02             	shr    $0x2,%ecx
  800b2e:	89 c7                	mov    %eax,%edi
  800b30:	fc                   	cld    
  800b31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b33:	eb 05                	jmp    800b3a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b35:	89 c7                	mov    %eax,%edi
  800b37:	fc                   	cld    
  800b38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b41:	ff 75 10             	pushl  0x10(%ebp)
  800b44:	ff 75 0c             	pushl  0xc(%ebp)
  800b47:	ff 75 08             	pushl  0x8(%ebp)
  800b4a:	e8 87 ff ff ff       	call   800ad6 <memmove>
}
  800b4f:	c9                   	leave  
  800b50:	c3                   	ret    

00800b51 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
  800b56:	8b 45 08             	mov    0x8(%ebp),%eax
  800b59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5c:	89 c6                	mov    %eax,%esi
  800b5e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b61:	eb 1a                	jmp    800b7d <memcmp+0x2c>
		if (*s1 != *s2)
  800b63:	0f b6 08             	movzbl (%eax),%ecx
  800b66:	0f b6 1a             	movzbl (%edx),%ebx
  800b69:	38 d9                	cmp    %bl,%cl
  800b6b:	74 0a                	je     800b77 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b6d:	0f b6 c1             	movzbl %cl,%eax
  800b70:	0f b6 db             	movzbl %bl,%ebx
  800b73:	29 d8                	sub    %ebx,%eax
  800b75:	eb 0f                	jmp    800b86 <memcmp+0x35>
		s1++, s2++;
  800b77:	83 c0 01             	add    $0x1,%eax
  800b7a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7d:	39 f0                	cmp    %esi,%eax
  800b7f:	75 e2                	jne    800b63 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	53                   	push   %ebx
  800b8e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b91:	89 c1                	mov    %eax,%ecx
  800b93:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b96:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b9a:	eb 0a                	jmp    800ba6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b9c:	0f b6 10             	movzbl (%eax),%edx
  800b9f:	39 da                	cmp    %ebx,%edx
  800ba1:	74 07                	je     800baa <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ba3:	83 c0 01             	add    $0x1,%eax
  800ba6:	39 c8                	cmp    %ecx,%eax
  800ba8:	72 f2                	jb     800b9c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800baa:	5b                   	pop    %ebx
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	57                   	push   %edi
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
  800bb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb9:	eb 03                	jmp    800bbe <strtol+0x11>
		s++;
  800bbb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bbe:	0f b6 01             	movzbl (%ecx),%eax
  800bc1:	3c 20                	cmp    $0x20,%al
  800bc3:	74 f6                	je     800bbb <strtol+0xe>
  800bc5:	3c 09                	cmp    $0x9,%al
  800bc7:	74 f2                	je     800bbb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc9:	3c 2b                	cmp    $0x2b,%al
  800bcb:	75 0a                	jne    800bd7 <strtol+0x2a>
		s++;
  800bcd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bd0:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd5:	eb 11                	jmp    800be8 <strtol+0x3b>
  800bd7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bdc:	3c 2d                	cmp    $0x2d,%al
  800bde:	75 08                	jne    800be8 <strtol+0x3b>
		s++, neg = 1;
  800be0:	83 c1 01             	add    $0x1,%ecx
  800be3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bee:	75 15                	jne    800c05 <strtol+0x58>
  800bf0:	80 39 30             	cmpb   $0x30,(%ecx)
  800bf3:	75 10                	jne    800c05 <strtol+0x58>
  800bf5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf9:	75 7c                	jne    800c77 <strtol+0xca>
		s += 2, base = 16;
  800bfb:	83 c1 02             	add    $0x2,%ecx
  800bfe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c03:	eb 16                	jmp    800c1b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c05:	85 db                	test   %ebx,%ebx
  800c07:	75 12                	jne    800c1b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c09:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c0e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c11:	75 08                	jne    800c1b <strtol+0x6e>
		s++, base = 8;
  800c13:	83 c1 01             	add    $0x1,%ecx
  800c16:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c20:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c23:	0f b6 11             	movzbl (%ecx),%edx
  800c26:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c29:	89 f3                	mov    %esi,%ebx
  800c2b:	80 fb 09             	cmp    $0x9,%bl
  800c2e:	77 08                	ja     800c38 <strtol+0x8b>
			dig = *s - '0';
  800c30:	0f be d2             	movsbl %dl,%edx
  800c33:	83 ea 30             	sub    $0x30,%edx
  800c36:	eb 22                	jmp    800c5a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c38:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c3b:	89 f3                	mov    %esi,%ebx
  800c3d:	80 fb 19             	cmp    $0x19,%bl
  800c40:	77 08                	ja     800c4a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c42:	0f be d2             	movsbl %dl,%edx
  800c45:	83 ea 57             	sub    $0x57,%edx
  800c48:	eb 10                	jmp    800c5a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c4a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c4d:	89 f3                	mov    %esi,%ebx
  800c4f:	80 fb 19             	cmp    $0x19,%bl
  800c52:	77 16                	ja     800c6a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c54:	0f be d2             	movsbl %dl,%edx
  800c57:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c5a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c5d:	7d 0b                	jge    800c6a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c5f:	83 c1 01             	add    $0x1,%ecx
  800c62:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c66:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c68:	eb b9                	jmp    800c23 <strtol+0x76>

	if (endptr)
  800c6a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c6e:	74 0d                	je     800c7d <strtol+0xd0>
		*endptr = (char *) s;
  800c70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c73:	89 0e                	mov    %ecx,(%esi)
  800c75:	eb 06                	jmp    800c7d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c77:	85 db                	test   %ebx,%ebx
  800c79:	74 98                	je     800c13 <strtol+0x66>
  800c7b:	eb 9e                	jmp    800c1b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c7d:	89 c2                	mov    %eax,%edx
  800c7f:	f7 da                	neg    %edx
  800c81:	85 ff                	test   %edi,%edi
  800c83:	0f 45 c2             	cmovne %edx,%eax
}
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	83 ec 04             	sub    $0x4,%esp
  800c94:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800c97:	57                   	push   %edi
  800c98:	e8 6e fc ff ff       	call   80090b <strlen>
  800c9d:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800ca0:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800ca3:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800ca8:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800cad:	eb 46                	jmp    800cf5 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800caf:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800cb3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800cb6:	80 f9 09             	cmp    $0x9,%cl
  800cb9:	77 08                	ja     800cc3 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800cbb:	0f be d2             	movsbl %dl,%edx
  800cbe:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800cc1:	eb 27                	jmp    800cea <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800cc3:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800cc6:	80 f9 05             	cmp    $0x5,%cl
  800cc9:	77 08                	ja     800cd3 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800ccb:	0f be d2             	movsbl %dl,%edx
  800cce:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800cd1:	eb 17                	jmp    800cea <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800cd3:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800cd6:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800cd9:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800cde:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800ce2:	77 06                	ja     800cea <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800ce4:	0f be d2             	movsbl %dl,%edx
  800ce7:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800cea:	0f af ce             	imul   %esi,%ecx
  800ced:	01 c8                	add    %ecx,%eax
		base *= 16;
  800cef:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800cf2:	83 eb 01             	sub    $0x1,%ebx
  800cf5:	83 fb 01             	cmp    $0x1,%ebx
  800cf8:	7f b5                	jg     800caf <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d08:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d10:	8b 55 08             	mov    0x8(%ebp),%edx
  800d13:	89 c3                	mov    %eax,%ebx
  800d15:	89 c7                	mov    %eax,%edi
  800d17:	89 c6                	mov    %eax,%esi
  800d19:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d26:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2b:	b8 01 00 00 00       	mov    $0x1,%eax
  800d30:	89 d1                	mov    %edx,%ecx
  800d32:	89 d3                	mov    %edx,%ebx
  800d34:	89 d7                	mov    %edx,%edi
  800d36:	89 d6                	mov    %edx,%esi
  800d38:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	57                   	push   %edi
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d48:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4d:	b8 03 00 00 00       	mov    $0x3,%eax
  800d52:	8b 55 08             	mov    0x8(%ebp),%edx
  800d55:	89 cb                	mov    %ecx,%ebx
  800d57:	89 cf                	mov    %ecx,%edi
  800d59:	89 ce                	mov    %ecx,%esi
  800d5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	7e 17                	jle    800d78 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d61:	83 ec 0c             	sub    $0xc,%esp
  800d64:	50                   	push   %eax
  800d65:	6a 03                	push   $0x3
  800d67:	68 1f 29 80 00       	push   $0x80291f
  800d6c:	6a 23                	push   $0x23
  800d6e:	68 3c 29 80 00       	push   $0x80293c
  800d73:	e8 bf f4 ff ff       	call   800237 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	57                   	push   %edi
  800d84:	56                   	push   %esi
  800d85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d86:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8b:	b8 02 00 00 00       	mov    $0x2,%eax
  800d90:	89 d1                	mov    %edx,%ecx
  800d92:	89 d3                	mov    %edx,%ebx
  800d94:	89 d7                	mov    %edx,%edi
  800d96:	89 d6                	mov    %edx,%esi
  800d98:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <sys_yield>:

void
sys_yield(void)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	57                   	push   %edi
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da5:	ba 00 00 00 00       	mov    $0x0,%edx
  800daa:	b8 0b 00 00 00       	mov    $0xb,%eax
  800daf:	89 d1                	mov    %edx,%ecx
  800db1:	89 d3                	mov    %edx,%ebx
  800db3:	89 d7                	mov    %edx,%edi
  800db5:	89 d6                	mov    %edx,%esi
  800db7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800dc7:	be 00 00 00 00       	mov    $0x0,%esi
  800dcc:	b8 04 00 00 00       	mov    $0x4,%eax
  800dd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dda:	89 f7                	mov    %esi,%edi
  800ddc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dde:	85 c0                	test   %eax,%eax
  800de0:	7e 17                	jle    800df9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	83 ec 0c             	sub    $0xc,%esp
  800de5:	50                   	push   %eax
  800de6:	6a 04                	push   $0x4
  800de8:	68 1f 29 80 00       	push   $0x80291f
  800ded:	6a 23                	push   $0x23
  800def:	68 3c 29 80 00       	push   $0x80293c
  800df4:	e8 3e f4 ff ff       	call   800237 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800df9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
  800e07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e12:	8b 55 08             	mov    0x8(%ebp),%edx
  800e15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e18:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e1b:	8b 75 18             	mov    0x18(%ebp),%esi
  800e1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e20:	85 c0                	test   %eax,%eax
  800e22:	7e 17                	jle    800e3b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e24:	83 ec 0c             	sub    $0xc,%esp
  800e27:	50                   	push   %eax
  800e28:	6a 05                	push   $0x5
  800e2a:	68 1f 29 80 00       	push   $0x80291f
  800e2f:	6a 23                	push   $0x23
  800e31:	68 3c 29 80 00       	push   $0x80293c
  800e36:	e8 fc f3 ff ff       	call   800237 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	57                   	push   %edi
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e51:	b8 06 00 00 00       	mov    $0x6,%eax
  800e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	89 df                	mov    %ebx,%edi
  800e5e:	89 de                	mov    %ebx,%esi
  800e60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e62:	85 c0                	test   %eax,%eax
  800e64:	7e 17                	jle    800e7d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e66:	83 ec 0c             	sub    $0xc,%esp
  800e69:	50                   	push   %eax
  800e6a:	6a 06                	push   $0x6
  800e6c:	68 1f 29 80 00       	push   $0x80291f
  800e71:	6a 23                	push   $0x23
  800e73:	68 3c 29 80 00       	push   $0x80293c
  800e78:	e8 ba f3 ff ff       	call   800237 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	57                   	push   %edi
  800e89:	56                   	push   %esi
  800e8a:	53                   	push   %ebx
  800e8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e93:	b8 08 00 00 00       	mov    $0x8,%eax
  800e98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9e:	89 df                	mov    %ebx,%edi
  800ea0:	89 de                	mov    %ebx,%esi
  800ea2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	7e 17                	jle    800ebf <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea8:	83 ec 0c             	sub    $0xc,%esp
  800eab:	50                   	push   %eax
  800eac:	6a 08                	push   $0x8
  800eae:	68 1f 29 80 00       	push   $0x80291f
  800eb3:	6a 23                	push   $0x23
  800eb5:	68 3c 29 80 00       	push   $0x80293c
  800eba:	e8 78 f3 ff ff       	call   800237 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ebf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec2:	5b                   	pop    %ebx
  800ec3:	5e                   	pop    %esi
  800ec4:	5f                   	pop    %edi
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	57                   	push   %edi
  800ecb:	56                   	push   %esi
  800ecc:	53                   	push   %ebx
  800ecd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee0:	89 df                	mov    %ebx,%edi
  800ee2:	89 de                	mov    %ebx,%esi
  800ee4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	7e 17                	jle    800f01 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eea:	83 ec 0c             	sub    $0xc,%esp
  800eed:	50                   	push   %eax
  800eee:	6a 0a                	push   $0xa
  800ef0:	68 1f 29 80 00       	push   $0x80291f
  800ef5:	6a 23                	push   $0x23
  800ef7:	68 3c 29 80 00       	push   $0x80293c
  800efc:	e8 36 f3 ff ff       	call   800237 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	57                   	push   %edi
  800f0d:	56                   	push   %esi
  800f0e:	53                   	push   %ebx
  800f0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f17:	b8 09 00 00 00       	mov    $0x9,%eax
  800f1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f22:	89 df                	mov    %ebx,%edi
  800f24:	89 de                	mov    %ebx,%esi
  800f26:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	7e 17                	jle    800f43 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2c:	83 ec 0c             	sub    $0xc,%esp
  800f2f:	50                   	push   %eax
  800f30:	6a 09                	push   $0x9
  800f32:	68 1f 29 80 00       	push   $0x80291f
  800f37:	6a 23                	push   $0x23
  800f39:	68 3c 29 80 00       	push   $0x80293c
  800f3e:	e8 f4 f2 ff ff       	call   800237 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f46:	5b                   	pop    %ebx
  800f47:	5e                   	pop    %esi
  800f48:	5f                   	pop    %edi
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	57                   	push   %edi
  800f4f:	56                   	push   %esi
  800f50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f51:	be 00 00 00 00       	mov    $0x0,%esi
  800f56:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f64:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f67:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f69:	5b                   	pop    %ebx
  800f6a:	5e                   	pop    %esi
  800f6b:	5f                   	pop    %edi
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    

00800f6e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	53                   	push   %ebx
  800f74:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f7c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f81:	8b 55 08             	mov    0x8(%ebp),%edx
  800f84:	89 cb                	mov    %ecx,%ebx
  800f86:	89 cf                	mov    %ecx,%edi
  800f88:	89 ce                	mov    %ecx,%esi
  800f8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	7e 17                	jle    800fa7 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f90:	83 ec 0c             	sub    $0xc,%esp
  800f93:	50                   	push   %eax
  800f94:	6a 0d                	push   $0xd
  800f96:	68 1f 29 80 00       	push   $0x80291f
  800f9b:	6a 23                	push   $0x23
  800f9d:	68 3c 29 80 00       	push   $0x80293c
  800fa2:	e8 90 f2 ff ff       	call   800237 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fa7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800faa:	5b                   	pop    %ebx
  800fab:	5e                   	pop    %esi
  800fac:	5f                   	pop    %edi
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    

00800faf <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	53                   	push   %ebx
  800fb3:	83 ec 04             	sub    $0x4,%esp
  800fb6:	8b 45 08             	mov    0x8(%ebp),%eax

	
	void *addr = (void *) utf->utf_fault_va;
  800fb9:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800fbb:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fbf:	74 11                	je     800fd2 <pgfault+0x23>
  800fc1:	89 d8                	mov    %ebx,%eax
  800fc3:	c1 e8 0c             	shr    $0xc,%eax
  800fc6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fcd:	f6 c4 08             	test   $0x8,%ah
  800fd0:	75 14                	jne    800fe6 <pgfault+0x37>
		panic("page fault");
  800fd2:	83 ec 04             	sub    $0x4,%esp
  800fd5:	68 4a 29 80 00       	push   $0x80294a
  800fda:	6a 5b                	push   $0x5b
  800fdc:	68 55 29 80 00       	push   $0x802955
  800fe1:	e8 51 f2 ff ff       	call   800237 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// allocate a new page and map it at a temporary location
	if((r = sys_page_alloc(0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800fe6:	83 ec 04             	sub    $0x4,%esp
  800fe9:	6a 07                	push   $0x7
  800feb:	68 00 f0 7f 00       	push   $0x7ff000
  800ff0:	6a 00                	push   $0x0
  800ff2:	e8 c7 fd ff ff       	call   800dbe <sys_page_alloc>
  800ff7:	83 c4 10             	add    $0x10,%esp
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	79 12                	jns    801010 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800ffe:	50                   	push   %eax
  800fff:	68 60 29 80 00       	push   $0x802960
  801004:	6a 66                	push   $0x66
  801006:	68 55 29 80 00       	push   $0x802955
  80100b:	e8 27 f2 ff ff       	call   800237 <_panic>

	// copy date to new page
	//strncpy((char *)PFTEMP, (char *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
	memcpy((void *)PFTEMP, (void *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
  801010:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801016:	83 ec 04             	sub    $0x4,%esp
  801019:	68 00 10 00 00       	push   $0x1000
  80101e:	53                   	push   %ebx
  80101f:	68 00 f0 7f 00       	push   $0x7ff000
  801024:	e8 15 fb ff ff       	call   800b3e <memcpy>

	// move the new page to the old page's address
	if((r = sys_page_map(0, (void *)PFTEMP, 0, (void *)
  801029:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801030:	53                   	push   %ebx
  801031:	6a 00                	push   $0x0
  801033:	68 00 f0 7f 00       	push   $0x7ff000
  801038:	6a 00                	push   $0x0
  80103a:	e8 c2 fd ff ff       	call   800e01 <sys_page_map>
  80103f:	83 c4 20             	add    $0x20,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	79 12                	jns    801058 <pgfault+0xa9>
		(ROUNDDOWN(addr, PGSIZE)), PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_map: %e", r);
  801046:	50                   	push   %eax
  801047:	68 73 29 80 00       	push   $0x802973
  80104c:	6a 6f                	push   $0x6f
  80104e:	68 55 29 80 00       	push   $0x802955
  801053:	e8 df f1 ff ff       	call   800237 <_panic>

	// unmap page on PFTEMP
	if((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  801058:	83 ec 08             	sub    $0x8,%esp
  80105b:	68 00 f0 7f 00       	push   $0x7ff000
  801060:	6a 00                	push   $0x0
  801062:	e8 dc fd ff ff       	call   800e43 <sys_page_unmap>
  801067:	83 c4 10             	add    $0x10,%esp
  80106a:	85 c0                	test   %eax,%eax
  80106c:	79 12                	jns    801080 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  80106e:	50                   	push   %eax
  80106f:	68 84 29 80 00       	push   $0x802984
  801074:	6a 73                	push   $0x73
  801076:	68 55 29 80 00       	push   $0x802955
  80107b:	e8 b7 f1 ff ff       	call   800237 <_panic>


}
  801080:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801083:	c9                   	leave  
  801084:	c3                   	ret    

00801085 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	57                   	push   %edi
  801089:	56                   	push   %esi
  80108a:	53                   	push   %ebx
  80108b:	83 ec 28             	sub    $0x28,%esp

	#ifdef CHALLENGE 
	set_exception_handler(pgfault, T_PGFLT);
	#else
	// set up page fault handler
	set_pgfault_handler(pgfault);
  80108e:	68 af 0f 80 00       	push   $0x800faf
  801093:	e8 a0 0f 00 00       	call   802038 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801098:	b8 07 00 00 00       	mov    $0x7,%eax
  80109d:	cd 30                	int    $0x30
  80109f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	#endif

	// create a child
	envid = sys_exofork();
	if (envid < 0)
  8010a5:	83 c4 10             	add    $0x10,%esp
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	79 15                	jns    8010c1 <fork+0x3c>
		panic("sys_exofork: %e", envid);
  8010ac:	50                   	push   %eax
  8010ad:	68 97 29 80 00       	push   $0x802997
  8010b2:	68 d0 00 00 00       	push   $0xd0
  8010b7:	68 55 29 80 00       	push   $0x802955
  8010bc:	e8 76 f1 ff ff       	call   800237 <_panic>
  8010c1:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8010c6:	be 00 08 00 00       	mov    $0x800,%esi
	// we are the child
	if(envid == 0) {
  8010cb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8010cf:	75 21                	jne    8010f2 <fork+0x6d>
		// the copied valude of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8010d1:	e8 aa fc ff ff       	call   800d80 <sys_getenvid>
  8010d6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010db:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010de:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010e3:	a3 20 44 80 00       	mov    %eax,0x804420
		/*// alloc exception stack
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
			PTE_P | PTE_U | PTE_W)) < 0)
			panic("sys_page_alloc: %e", r);*/

		return 0;
  8010e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ed:	e9 a3 01 00 00       	jmp    801295 <fork+0x210>
{
	int r;

	// LAB 4: Your code here.
	
	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P))
  8010f2:	89 d8                	mov    %ebx,%eax
  8010f4:	c1 e8 16             	shr    $0x16,%eax
  8010f7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010fe:	a8 01                	test   $0x1,%al
  801100:	0f 84 f0 00 00 00    	je     8011f6 <fork+0x171>
		return 0;

	// virtual page pn's page table entry
	pte_t pe = uvpt[pn];
  801106:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi


	if((pe & PTE_P) && (pe & PTE_U)) {
  80110d:	89 f8                	mov    %edi,%eax
  80110f:	83 e0 05             	and    $0x5,%eax
  801112:	83 f8 05             	cmp    $0x5,%eax
  801115:	0f 85 db 00 00 00    	jne    8011f6 <fork+0x171>
		// share with the child environment 
		if(pe & PTE_SHARE) {
  80111b:	f7 c7 00 04 00 00    	test   $0x400,%edi
  801121:	74 36                	je     801159 <fork+0xd4>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  801123:	83 ec 0c             	sub    $0xc,%esp
  801126:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  80112c:	57                   	push   %edi
  80112d:	53                   	push   %ebx
  80112e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801131:	53                   	push   %ebx
  801132:	6a 00                	push   $0x0
  801134:	e8 c8 fc ff ff       	call   800e01 <sys_page_map>
  801139:	83 c4 20             	add    $0x20,%esp
  80113c:	85 c0                	test   %eax,%eax
  80113e:	0f 89 b2 00 00 00    	jns    8011f6 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  801144:	50                   	push   %eax
  801145:	68 a7 29 80 00       	push   $0x8029a7
  80114a:	68 97 00 00 00       	push   $0x97
  80114f:	68 55 29 80 00       	push   $0x802955
  801154:	e8 de f0 ff ff       	call   800237 <_panic>
		}
		// the page is writable or copy-on-write
		else if((pe & PTE_W) || (pe & PTE_COW)) {
  801159:	f7 c7 02 08 00 00    	test   $0x802,%edi
  80115f:	74 63                	je     8011c4 <fork+0x13f>
			// create the child mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, 
  801161:	81 e7 05 06 00 00    	and    $0x605,%edi
  801167:	81 cf 00 08 00 00    	or     $0x800,%edi
  80116d:	83 ec 0c             	sub    $0xc,%esp
  801170:	57                   	push   %edi
  801171:	53                   	push   %ebx
  801172:	ff 75 e4             	pushl  -0x1c(%ebp)
  801175:	53                   	push   %ebx
  801176:	6a 00                	push   $0x0
  801178:	e8 84 fc ff ff       	call   800e01 <sys_page_map>
  80117d:	83 c4 20             	add    $0x20,%esp
  801180:	85 c0                	test   %eax,%eax
  801182:	79 15                	jns    801199 <fork+0x114>
				(void *)(pn*PGSIZE), (pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  801184:	50                   	push   %eax
  801185:	68 a7 29 80 00       	push   $0x8029a7
  80118a:	68 9e 00 00 00       	push   $0x9e
  80118f:	68 55 29 80 00       	push   $0x802955
  801194:	e8 9e f0 ff ff       	call   800237 <_panic>
			// map the parent mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE),
  801199:	83 ec 0c             	sub    $0xc,%esp
  80119c:	57                   	push   %edi
  80119d:	53                   	push   %ebx
  80119e:	6a 00                	push   $0x0
  8011a0:	53                   	push   %ebx
  8011a1:	6a 00                	push   $0x0
  8011a3:	e8 59 fc ff ff       	call   800e01 <sys_page_map>
  8011a8:	83 c4 20             	add    $0x20,%esp
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	79 47                	jns    8011f6 <fork+0x171>
				(pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  8011af:	50                   	push   %eax
  8011b0:	68 a7 29 80 00       	push   $0x8029a7
  8011b5:	68 a2 00 00 00       	push   $0xa2
  8011ba:	68 55 29 80 00       	push   $0x802955
  8011bf:	e8 73 f0 ff ff       	call   800237 <_panic>
		}	
		else {
			// create the child mapping read only
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  8011c4:	83 ec 0c             	sub    $0xc,%esp
  8011c7:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  8011cd:	57                   	push   %edi
  8011ce:	53                   	push   %ebx
  8011cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d2:	53                   	push   %ebx
  8011d3:	6a 00                	push   $0x0
  8011d5:	e8 27 fc ff ff       	call   800e01 <sys_page_map>
  8011da:	83 c4 20             	add    $0x20,%esp
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	79 15                	jns    8011f6 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  8011e1:	50                   	push   %eax
  8011e2:	68 a7 29 80 00       	push   $0x8029a7
  8011e7:	68 a8 00 00 00       	push   $0xa8
  8011ec:	68 55 29 80 00       	push   $0x802955
  8011f1:	e8 41 f0 ff ff       	call   800237 <_panic>
			panic("sys_page_alloc: %e", r);*/

		return 0;
	}
	// copy address to child environment's page dirctory
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn)
  8011f6:	83 c6 01             	add    $0x1,%esi
  8011f9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011ff:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801205:	0f 85 e7 fe ff ff    	jne    8010f2 <fork+0x6d>
	#ifdef CHALLENGE 
	if((r = sys_env_set_exception_upcall(envid, thisenv->env_exception_upcall)) < 0)
		panic("sys_env_set_exception_upcall: %e", r);
	#else
	// set child's page fault handler
	if((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  80120b:	a1 20 44 80 00       	mov    0x804420,%eax
  801210:	8b 40 64             	mov    0x64(%eax),%eax
  801213:	83 ec 08             	sub    $0x8,%esp
  801216:	50                   	push   %eax
  801217:	ff 75 e0             	pushl  -0x20(%ebp)
  80121a:	e8 ea fc ff ff       	call   800f09 <sys_env_set_pgfault_upcall>
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	85 c0                	test   %eax,%eax
  801224:	79 15                	jns    80123b <fork+0x1b6>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801226:	50                   	push   %eax
  801227:	68 e0 29 80 00       	push   $0x8029e0
  80122c:	68 e9 00 00 00       	push   $0xe9
  801231:	68 55 29 80 00       	push   $0x802955
  801236:	e8 fc ef ff ff       	call   800237 <_panic>
	#endif

	// alloc exception stack for child environment
	if((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), 
  80123b:	83 ec 04             	sub    $0x4,%esp
  80123e:	6a 07                	push   $0x7
  801240:	68 00 f0 bf ee       	push   $0xeebff000
  801245:	ff 75 e0             	pushl  -0x20(%ebp)
  801248:	e8 71 fb ff ff       	call   800dbe <sys_page_alloc>
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	85 c0                	test   %eax,%eax
  801252:	79 15                	jns    801269 <fork+0x1e4>
		PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
  801254:	50                   	push   %eax
  801255:	68 60 29 80 00       	push   $0x802960
  80125a:	68 ef 00 00 00       	push   $0xef
  80125f:	68 55 29 80 00       	push   $0x802955
  801264:	e8 ce ef ff ff       	call   800237 <_panic>

	// start the child environment running
	if((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801269:	83 ec 08             	sub    $0x8,%esp
  80126c:	6a 02                	push   $0x2
  80126e:	ff 75 e0             	pushl  -0x20(%ebp)
  801271:	e8 0f fc ff ff       	call   800e85 <sys_env_set_status>
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	85 c0                	test   %eax,%eax
  80127b:	79 15                	jns    801292 <fork+0x20d>
		panic("sys_env_set_status: %e", r);
  80127d:	50                   	push   %eax
  80127e:	68 b3 29 80 00       	push   $0x8029b3
  801283:	68 f3 00 00 00       	push   $0xf3
  801288:	68 55 29 80 00       	push   $0x802955
  80128d:	e8 a5 ef ff ff       	call   800237 <_panic>

	return envid;
  801292:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801295:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801298:	5b                   	pop    %ebx
  801299:	5e                   	pop    %esi
  80129a:	5f                   	pop    %edi
  80129b:	5d                   	pop    %ebp
  80129c:	c3                   	ret    

0080129d <sfork>:

// Challenge!
int
sfork(void)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8012a3:	68 ca 29 80 00       	push   $0x8029ca
  8012a8:	68 fc 00 00 00       	push   $0xfc
  8012ad:	68 55 29 80 00       	push   $0x802955
  8012b2:	e8 80 ef ff ff       	call   800237 <_panic>

008012b7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bd:	05 00 00 00 30       	add    $0x30000000,%eax
  8012c2:	c1 e8 0c             	shr    $0xc,%eax
}
  8012c5:	5d                   	pop    %ebp
  8012c6:	c3                   	ret    

008012c7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cd:	05 00 00 00 30       	add    $0x30000000,%eax
  8012d2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012d7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012dc:	5d                   	pop    %ebp
  8012dd:	c3                   	ret    

008012de <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012e9:	89 c2                	mov    %eax,%edx
  8012eb:	c1 ea 16             	shr    $0x16,%edx
  8012ee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012f5:	f6 c2 01             	test   $0x1,%dl
  8012f8:	74 11                	je     80130b <fd_alloc+0x2d>
  8012fa:	89 c2                	mov    %eax,%edx
  8012fc:	c1 ea 0c             	shr    $0xc,%edx
  8012ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801306:	f6 c2 01             	test   $0x1,%dl
  801309:	75 09                	jne    801314 <fd_alloc+0x36>
			*fd_store = fd;
  80130b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80130d:	b8 00 00 00 00       	mov    $0x0,%eax
  801312:	eb 17                	jmp    80132b <fd_alloc+0x4d>
  801314:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801319:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80131e:	75 c9                	jne    8012e9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801320:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801326:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    

0080132d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801333:	83 f8 1f             	cmp    $0x1f,%eax
  801336:	77 36                	ja     80136e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801338:	c1 e0 0c             	shl    $0xc,%eax
  80133b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801340:	89 c2                	mov    %eax,%edx
  801342:	c1 ea 16             	shr    $0x16,%edx
  801345:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80134c:	f6 c2 01             	test   $0x1,%dl
  80134f:	74 24                	je     801375 <fd_lookup+0x48>
  801351:	89 c2                	mov    %eax,%edx
  801353:	c1 ea 0c             	shr    $0xc,%edx
  801356:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80135d:	f6 c2 01             	test   $0x1,%dl
  801360:	74 1a                	je     80137c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801362:	8b 55 0c             	mov    0xc(%ebp),%edx
  801365:	89 02                	mov    %eax,(%edx)
	return 0;
  801367:	b8 00 00 00 00       	mov    $0x0,%eax
  80136c:	eb 13                	jmp    801381 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80136e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801373:	eb 0c                	jmp    801381 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801375:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80137a:	eb 05                	jmp    801381 <fd_lookup+0x54>
  80137c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801381:	5d                   	pop    %ebp
  801382:	c3                   	ret    

00801383 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	83 ec 08             	sub    $0x8,%esp
  801389:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80138c:	ba 7c 2a 80 00       	mov    $0x802a7c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801391:	eb 13                	jmp    8013a6 <dev_lookup+0x23>
  801393:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801396:	39 08                	cmp    %ecx,(%eax)
  801398:	75 0c                	jne    8013a6 <dev_lookup+0x23>
			*dev = devtab[i];
  80139a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80139d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80139f:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a4:	eb 2e                	jmp    8013d4 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013a6:	8b 02                	mov    (%edx),%eax
  8013a8:	85 c0                	test   %eax,%eax
  8013aa:	75 e7                	jne    801393 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013ac:	a1 20 44 80 00       	mov    0x804420,%eax
  8013b1:	8b 40 48             	mov    0x48(%eax),%eax
  8013b4:	83 ec 04             	sub    $0x4,%esp
  8013b7:	51                   	push   %ecx
  8013b8:	50                   	push   %eax
  8013b9:	68 00 2a 80 00       	push   $0x802a00
  8013be:	e8 4d ef ff ff       	call   800310 <cprintf>
	*dev = 0;
  8013c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013d4:	c9                   	leave  
  8013d5:	c3                   	ret    

008013d6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	56                   	push   %esi
  8013da:	53                   	push   %ebx
  8013db:	83 ec 10             	sub    $0x10,%esp
  8013de:	8b 75 08             	mov    0x8(%ebp),%esi
  8013e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e7:	50                   	push   %eax
  8013e8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013ee:	c1 e8 0c             	shr    $0xc,%eax
  8013f1:	50                   	push   %eax
  8013f2:	e8 36 ff ff ff       	call   80132d <fd_lookup>
  8013f7:	83 c4 08             	add    $0x8,%esp
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	78 05                	js     801403 <fd_close+0x2d>
	    || fd != fd2) 
  8013fe:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801401:	74 0c                	je     80140f <fd_close+0x39>
		return (must_exist ? r : 0); 
  801403:	84 db                	test   %bl,%bl
  801405:	ba 00 00 00 00       	mov    $0x0,%edx
  80140a:	0f 44 c2             	cmove  %edx,%eax
  80140d:	eb 41                	jmp    801450 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80140f:	83 ec 08             	sub    $0x8,%esp
  801412:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801415:	50                   	push   %eax
  801416:	ff 36                	pushl  (%esi)
  801418:	e8 66 ff ff ff       	call   801383 <dev_lookup>
  80141d:	89 c3                	mov    %eax,%ebx
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	85 c0                	test   %eax,%eax
  801424:	78 1a                	js     801440 <fd_close+0x6a>
		if (dev->dev_close) 
  801426:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801429:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  80142c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  801431:	85 c0                	test   %eax,%eax
  801433:	74 0b                	je     801440 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801435:	83 ec 0c             	sub    $0xc,%esp
  801438:	56                   	push   %esi
  801439:	ff d0                	call   *%eax
  80143b:	89 c3                	mov    %eax,%ebx
  80143d:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801440:	83 ec 08             	sub    $0x8,%esp
  801443:	56                   	push   %esi
  801444:	6a 00                	push   $0x0
  801446:	e8 f8 f9 ff ff       	call   800e43 <sys_page_unmap>
	return r;
  80144b:	83 c4 10             	add    $0x10,%esp
  80144e:	89 d8                	mov    %ebx,%eax
}
  801450:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801453:	5b                   	pop    %ebx
  801454:	5e                   	pop    %esi
  801455:	5d                   	pop    %ebp
  801456:	c3                   	ret    

00801457 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80145d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801460:	50                   	push   %eax
  801461:	ff 75 08             	pushl  0x8(%ebp)
  801464:	e8 c4 fe ff ff       	call   80132d <fd_lookup>
  801469:	83 c4 08             	add    $0x8,%esp
  80146c:	85 c0                	test   %eax,%eax
  80146e:	78 10                	js     801480 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  801470:	83 ec 08             	sub    $0x8,%esp
  801473:	6a 01                	push   $0x1
  801475:	ff 75 f4             	pushl  -0xc(%ebp)
  801478:	e8 59 ff ff ff       	call   8013d6 <fd_close>
  80147d:	83 c4 10             	add    $0x10,%esp
}
  801480:	c9                   	leave  
  801481:	c3                   	ret    

00801482 <close_all>:

void
close_all(void)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	53                   	push   %ebx
  801486:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801489:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80148e:	83 ec 0c             	sub    $0xc,%esp
  801491:	53                   	push   %ebx
  801492:	e8 c0 ff ff ff       	call   801457 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801497:	83 c3 01             	add    $0x1,%ebx
  80149a:	83 c4 10             	add    $0x10,%esp
  80149d:	83 fb 20             	cmp    $0x20,%ebx
  8014a0:	75 ec                	jne    80148e <close_all+0xc>
		close(i);
}
  8014a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a5:	c9                   	leave  
  8014a6:	c3                   	ret    

008014a7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	57                   	push   %edi
  8014ab:	56                   	push   %esi
  8014ac:	53                   	push   %ebx
  8014ad:	83 ec 2c             	sub    $0x2c,%esp
  8014b0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014b3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014b6:	50                   	push   %eax
  8014b7:	ff 75 08             	pushl  0x8(%ebp)
  8014ba:	e8 6e fe ff ff       	call   80132d <fd_lookup>
  8014bf:	83 c4 08             	add    $0x8,%esp
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	0f 88 c1 00 00 00    	js     80158b <dup+0xe4>
		return r;
	close(newfdnum);
  8014ca:	83 ec 0c             	sub    $0xc,%esp
  8014cd:	56                   	push   %esi
  8014ce:	e8 84 ff ff ff       	call   801457 <close>

	newfd = INDEX2FD(newfdnum);
  8014d3:	89 f3                	mov    %esi,%ebx
  8014d5:	c1 e3 0c             	shl    $0xc,%ebx
  8014d8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014de:	83 c4 04             	add    $0x4,%esp
  8014e1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014e4:	e8 de fd ff ff       	call   8012c7 <fd2data>
  8014e9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014eb:	89 1c 24             	mov    %ebx,(%esp)
  8014ee:	e8 d4 fd ff ff       	call   8012c7 <fd2data>
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014f9:	89 f8                	mov    %edi,%eax
  8014fb:	c1 e8 16             	shr    $0x16,%eax
  8014fe:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801505:	a8 01                	test   $0x1,%al
  801507:	74 37                	je     801540 <dup+0x99>
  801509:	89 f8                	mov    %edi,%eax
  80150b:	c1 e8 0c             	shr    $0xc,%eax
  80150e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801515:	f6 c2 01             	test   $0x1,%dl
  801518:	74 26                	je     801540 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80151a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801521:	83 ec 0c             	sub    $0xc,%esp
  801524:	25 07 0e 00 00       	and    $0xe07,%eax
  801529:	50                   	push   %eax
  80152a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80152d:	6a 00                	push   $0x0
  80152f:	57                   	push   %edi
  801530:	6a 00                	push   $0x0
  801532:	e8 ca f8 ff ff       	call   800e01 <sys_page_map>
  801537:	89 c7                	mov    %eax,%edi
  801539:	83 c4 20             	add    $0x20,%esp
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 2e                	js     80156e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801540:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801543:	89 d0                	mov    %edx,%eax
  801545:	c1 e8 0c             	shr    $0xc,%eax
  801548:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80154f:	83 ec 0c             	sub    $0xc,%esp
  801552:	25 07 0e 00 00       	and    $0xe07,%eax
  801557:	50                   	push   %eax
  801558:	53                   	push   %ebx
  801559:	6a 00                	push   $0x0
  80155b:	52                   	push   %edx
  80155c:	6a 00                	push   $0x0
  80155e:	e8 9e f8 ff ff       	call   800e01 <sys_page_map>
  801563:	89 c7                	mov    %eax,%edi
  801565:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801568:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80156a:	85 ff                	test   %edi,%edi
  80156c:	79 1d                	jns    80158b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80156e:	83 ec 08             	sub    $0x8,%esp
  801571:	53                   	push   %ebx
  801572:	6a 00                	push   $0x0
  801574:	e8 ca f8 ff ff       	call   800e43 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801579:	83 c4 08             	add    $0x8,%esp
  80157c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80157f:	6a 00                	push   $0x0
  801581:	e8 bd f8 ff ff       	call   800e43 <sys_page_unmap>
	return r;
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	89 f8                	mov    %edi,%eax
}
  80158b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158e:	5b                   	pop    %ebx
  80158f:	5e                   	pop    %esi
  801590:	5f                   	pop    %edi
  801591:	5d                   	pop    %ebp
  801592:	c3                   	ret    

00801593 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	53                   	push   %ebx
  801597:	83 ec 14             	sub    $0x14,%esp
  80159a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a0:	50                   	push   %eax
  8015a1:	53                   	push   %ebx
  8015a2:	e8 86 fd ff ff       	call   80132d <fd_lookup>
  8015a7:	83 c4 08             	add    $0x8,%esp
  8015aa:	89 c2                	mov    %eax,%edx
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	78 6d                	js     80161d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b0:	83 ec 08             	sub    $0x8,%esp
  8015b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b6:	50                   	push   %eax
  8015b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ba:	ff 30                	pushl  (%eax)
  8015bc:	e8 c2 fd ff ff       	call   801383 <dev_lookup>
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	78 4c                	js     801614 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015cb:	8b 42 08             	mov    0x8(%edx),%eax
  8015ce:	83 e0 03             	and    $0x3,%eax
  8015d1:	83 f8 01             	cmp    $0x1,%eax
  8015d4:	75 21                	jne    8015f7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d6:	a1 20 44 80 00       	mov    0x804420,%eax
  8015db:	8b 40 48             	mov    0x48(%eax),%eax
  8015de:	83 ec 04             	sub    $0x4,%esp
  8015e1:	53                   	push   %ebx
  8015e2:	50                   	push   %eax
  8015e3:	68 41 2a 80 00       	push   $0x802a41
  8015e8:	e8 23 ed ff ff       	call   800310 <cprintf>
		return -E_INVAL;
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015f5:	eb 26                	jmp    80161d <read+0x8a>
	}
	if (!dev->dev_read)
  8015f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fa:	8b 40 08             	mov    0x8(%eax),%eax
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	74 17                	je     801618 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801601:	83 ec 04             	sub    $0x4,%esp
  801604:	ff 75 10             	pushl  0x10(%ebp)
  801607:	ff 75 0c             	pushl  0xc(%ebp)
  80160a:	52                   	push   %edx
  80160b:	ff d0                	call   *%eax
  80160d:	89 c2                	mov    %eax,%edx
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	eb 09                	jmp    80161d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801614:	89 c2                	mov    %eax,%edx
  801616:	eb 05                	jmp    80161d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801618:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80161d:	89 d0                	mov    %edx,%eax
  80161f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801622:	c9                   	leave  
  801623:	c3                   	ret    

00801624 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	57                   	push   %edi
  801628:	56                   	push   %esi
  801629:	53                   	push   %ebx
  80162a:	83 ec 0c             	sub    $0xc,%esp
  80162d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801630:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801633:	bb 00 00 00 00       	mov    $0x0,%ebx
  801638:	eb 21                	jmp    80165b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80163a:	83 ec 04             	sub    $0x4,%esp
  80163d:	89 f0                	mov    %esi,%eax
  80163f:	29 d8                	sub    %ebx,%eax
  801641:	50                   	push   %eax
  801642:	89 d8                	mov    %ebx,%eax
  801644:	03 45 0c             	add    0xc(%ebp),%eax
  801647:	50                   	push   %eax
  801648:	57                   	push   %edi
  801649:	e8 45 ff ff ff       	call   801593 <read>
		if (m < 0)
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	85 c0                	test   %eax,%eax
  801653:	78 10                	js     801665 <readn+0x41>
			return m;
		if (m == 0)
  801655:	85 c0                	test   %eax,%eax
  801657:	74 0a                	je     801663 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801659:	01 c3                	add    %eax,%ebx
  80165b:	39 f3                	cmp    %esi,%ebx
  80165d:	72 db                	jb     80163a <readn+0x16>
  80165f:	89 d8                	mov    %ebx,%eax
  801661:	eb 02                	jmp    801665 <readn+0x41>
  801663:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801665:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801668:	5b                   	pop    %ebx
  801669:	5e                   	pop    %esi
  80166a:	5f                   	pop    %edi
  80166b:	5d                   	pop    %ebp
  80166c:	c3                   	ret    

0080166d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	53                   	push   %ebx
  801671:	83 ec 14             	sub    $0x14,%esp
  801674:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801677:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167a:	50                   	push   %eax
  80167b:	53                   	push   %ebx
  80167c:	e8 ac fc ff ff       	call   80132d <fd_lookup>
  801681:	83 c4 08             	add    $0x8,%esp
  801684:	89 c2                	mov    %eax,%edx
  801686:	85 c0                	test   %eax,%eax
  801688:	78 68                	js     8016f2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168a:	83 ec 08             	sub    $0x8,%esp
  80168d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801694:	ff 30                	pushl  (%eax)
  801696:	e8 e8 fc ff ff       	call   801383 <dev_lookup>
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	78 47                	js     8016e9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016a9:	75 21                	jne    8016cc <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016ab:	a1 20 44 80 00       	mov    0x804420,%eax
  8016b0:	8b 40 48             	mov    0x48(%eax),%eax
  8016b3:	83 ec 04             	sub    $0x4,%esp
  8016b6:	53                   	push   %ebx
  8016b7:	50                   	push   %eax
  8016b8:	68 5d 2a 80 00       	push   $0x802a5d
  8016bd:	e8 4e ec ff ff       	call   800310 <cprintf>
		return -E_INVAL;
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016ca:	eb 26                	jmp    8016f2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016cf:	8b 52 0c             	mov    0xc(%edx),%edx
  8016d2:	85 d2                	test   %edx,%edx
  8016d4:	74 17                	je     8016ed <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016d6:	83 ec 04             	sub    $0x4,%esp
  8016d9:	ff 75 10             	pushl  0x10(%ebp)
  8016dc:	ff 75 0c             	pushl  0xc(%ebp)
  8016df:	50                   	push   %eax
  8016e0:	ff d2                	call   *%edx
  8016e2:	89 c2                	mov    %eax,%edx
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	eb 09                	jmp    8016f2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e9:	89 c2                	mov    %eax,%edx
  8016eb:	eb 05                	jmp    8016f2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016ed:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016f2:	89 d0                	mov    %edx,%eax
  8016f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f7:	c9                   	leave  
  8016f8:	c3                   	ret    

008016f9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016ff:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801702:	50                   	push   %eax
  801703:	ff 75 08             	pushl  0x8(%ebp)
  801706:	e8 22 fc ff ff       	call   80132d <fd_lookup>
  80170b:	83 c4 08             	add    $0x8,%esp
  80170e:	85 c0                	test   %eax,%eax
  801710:	78 0e                	js     801720 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801712:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801715:	8b 55 0c             	mov    0xc(%ebp),%edx
  801718:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80171b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801720:	c9                   	leave  
  801721:	c3                   	ret    

00801722 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	53                   	push   %ebx
  801726:	83 ec 14             	sub    $0x14,%esp
  801729:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172f:	50                   	push   %eax
  801730:	53                   	push   %ebx
  801731:	e8 f7 fb ff ff       	call   80132d <fd_lookup>
  801736:	83 c4 08             	add    $0x8,%esp
  801739:	89 c2                	mov    %eax,%edx
  80173b:	85 c0                	test   %eax,%eax
  80173d:	78 65                	js     8017a4 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173f:	83 ec 08             	sub    $0x8,%esp
  801742:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801745:	50                   	push   %eax
  801746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801749:	ff 30                	pushl  (%eax)
  80174b:	e8 33 fc ff ff       	call   801383 <dev_lookup>
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	85 c0                	test   %eax,%eax
  801755:	78 44                	js     80179b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801757:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80175e:	75 21                	jne    801781 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801760:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801765:	8b 40 48             	mov    0x48(%eax),%eax
  801768:	83 ec 04             	sub    $0x4,%esp
  80176b:	53                   	push   %ebx
  80176c:	50                   	push   %eax
  80176d:	68 20 2a 80 00       	push   $0x802a20
  801772:	e8 99 eb ff ff       	call   800310 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80177f:	eb 23                	jmp    8017a4 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801781:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801784:	8b 52 18             	mov    0x18(%edx),%edx
  801787:	85 d2                	test   %edx,%edx
  801789:	74 14                	je     80179f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80178b:	83 ec 08             	sub    $0x8,%esp
  80178e:	ff 75 0c             	pushl  0xc(%ebp)
  801791:	50                   	push   %eax
  801792:	ff d2                	call   *%edx
  801794:	89 c2                	mov    %eax,%edx
  801796:	83 c4 10             	add    $0x10,%esp
  801799:	eb 09                	jmp    8017a4 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179b:	89 c2                	mov    %eax,%edx
  80179d:	eb 05                	jmp    8017a4 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80179f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017a4:	89 d0                	mov    %edx,%eax
  8017a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a9:	c9                   	leave  
  8017aa:	c3                   	ret    

008017ab <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	53                   	push   %ebx
  8017af:	83 ec 14             	sub    $0x14,%esp
  8017b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b8:	50                   	push   %eax
  8017b9:	ff 75 08             	pushl  0x8(%ebp)
  8017bc:	e8 6c fb ff ff       	call   80132d <fd_lookup>
  8017c1:	83 c4 08             	add    $0x8,%esp
  8017c4:	89 c2                	mov    %eax,%edx
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	78 58                	js     801822 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ca:	83 ec 08             	sub    $0x8,%esp
  8017cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d0:	50                   	push   %eax
  8017d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d4:	ff 30                	pushl  (%eax)
  8017d6:	e8 a8 fb ff ff       	call   801383 <dev_lookup>
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 37                	js     801819 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017e9:	74 32                	je     80181d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017eb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017ee:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017f5:	00 00 00 
	stat->st_isdir = 0;
  8017f8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017ff:	00 00 00 
	stat->st_dev = dev;
  801802:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801808:	83 ec 08             	sub    $0x8,%esp
  80180b:	53                   	push   %ebx
  80180c:	ff 75 f0             	pushl  -0x10(%ebp)
  80180f:	ff 50 14             	call   *0x14(%eax)
  801812:	89 c2                	mov    %eax,%edx
  801814:	83 c4 10             	add    $0x10,%esp
  801817:	eb 09                	jmp    801822 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801819:	89 c2                	mov    %eax,%edx
  80181b:	eb 05                	jmp    801822 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80181d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801822:	89 d0                	mov    %edx,%eax
  801824:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801827:	c9                   	leave  
  801828:	c3                   	ret    

00801829 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801829:	55                   	push   %ebp
  80182a:	89 e5                	mov    %esp,%ebp
  80182c:	56                   	push   %esi
  80182d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80182e:	83 ec 08             	sub    $0x8,%esp
  801831:	6a 00                	push   $0x0
  801833:	ff 75 08             	pushl  0x8(%ebp)
  801836:	e8 2b 02 00 00       	call   801a66 <open>
  80183b:	89 c3                	mov    %eax,%ebx
  80183d:	83 c4 10             	add    $0x10,%esp
  801840:	85 c0                	test   %eax,%eax
  801842:	78 1b                	js     80185f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801844:	83 ec 08             	sub    $0x8,%esp
  801847:	ff 75 0c             	pushl  0xc(%ebp)
  80184a:	50                   	push   %eax
  80184b:	e8 5b ff ff ff       	call   8017ab <fstat>
  801850:	89 c6                	mov    %eax,%esi
	close(fd);
  801852:	89 1c 24             	mov    %ebx,(%esp)
  801855:	e8 fd fb ff ff       	call   801457 <close>
	return r;
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	89 f0                	mov    %esi,%eax
}
  80185f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801862:	5b                   	pop    %ebx
  801863:	5e                   	pop    %esi
  801864:	5d                   	pop    %ebp
  801865:	c3                   	ret    

00801866 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	56                   	push   %esi
  80186a:	53                   	push   %ebx
  80186b:	89 c6                	mov    %eax,%esi
  80186d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80186f:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801876:	75 12                	jne    80188a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801878:	83 ec 0c             	sub    $0xc,%esp
  80187b:	6a 01                	push   $0x1
  80187d:	e8 04 09 00 00       	call   802186 <ipc_find_env>
  801882:	a3 04 40 80 00       	mov    %eax,0x804004
  801887:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80188a:	6a 07                	push   $0x7
  80188c:	68 00 50 80 00       	push   $0x805000
  801891:	56                   	push   %esi
  801892:	ff 35 04 40 80 00    	pushl  0x804004
  801898:	e8 93 08 00 00       	call   802130 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80189d:	83 c4 0c             	add    $0xc,%esp
  8018a0:	6a 00                	push   $0x0
  8018a2:	53                   	push   %ebx
  8018a3:	6a 00                	push   $0x0
  8018a5:	e8 1d 08 00 00       	call   8020c7 <ipc_recv>
}
  8018aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ad:	5b                   	pop    %ebx
  8018ae:	5e                   	pop    %esi
  8018af:	5d                   	pop    %ebp
  8018b0:	c3                   	ret    

008018b1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018b1:	55                   	push   %ebp
  8018b2:	89 e5                	mov    %esp,%ebp
  8018b4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8018bd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cf:	b8 02 00 00 00       	mov    $0x2,%eax
  8018d4:	e8 8d ff ff ff       	call   801866 <fsipc>
}
  8018d9:	c9                   	leave  
  8018da:	c3                   	ret    

008018db <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8018f6:	e8 6b ff ff ff       	call   801866 <fsipc>
}
  8018fb:	c9                   	leave  
  8018fc:	c3                   	ret    

008018fd <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	53                   	push   %ebx
  801901:	83 ec 04             	sub    $0x4,%esp
  801904:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801907:	8b 45 08             	mov    0x8(%ebp),%eax
  80190a:	8b 40 0c             	mov    0xc(%eax),%eax
  80190d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801912:	ba 00 00 00 00       	mov    $0x0,%edx
  801917:	b8 05 00 00 00       	mov    $0x5,%eax
  80191c:	e8 45 ff ff ff       	call   801866 <fsipc>
  801921:	85 c0                	test   %eax,%eax
  801923:	78 2c                	js     801951 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801925:	83 ec 08             	sub    $0x8,%esp
  801928:	68 00 50 80 00       	push   $0x805000
  80192d:	53                   	push   %ebx
  80192e:	e8 11 f0 ff ff       	call   800944 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801933:	a1 80 50 80 00       	mov    0x805080,%eax
  801938:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80193e:	a1 84 50 80 00       	mov    0x805084,%eax
  801943:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801951:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801954:	c9                   	leave  
  801955:	c3                   	ret    

00801956 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	53                   	push   %ebx
  80195a:	83 ec 08             	sub    $0x8,%esp
  80195d:	8b 45 10             	mov    0x10(%ebp),%eax
  801960:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801965:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80196a:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80196d:	8b 45 08             	mov    0x8(%ebp),%eax
  801970:	8b 40 0c             	mov    0xc(%eax),%eax
  801973:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801978:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80197e:	53                   	push   %ebx
  80197f:	ff 75 0c             	pushl  0xc(%ebp)
  801982:	68 08 50 80 00       	push   $0x805008
  801987:	e8 4a f1 ff ff       	call   800ad6 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80198c:	ba 00 00 00 00       	mov    $0x0,%edx
  801991:	b8 04 00 00 00       	mov    $0x4,%eax
  801996:	e8 cb fe ff ff       	call   801866 <fsipc>
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 3d                	js     8019df <devfile_write+0x89>
		return r;

	assert(r <= n);
  8019a2:	39 d8                	cmp    %ebx,%eax
  8019a4:	76 19                	jbe    8019bf <devfile_write+0x69>
  8019a6:	68 8c 2a 80 00       	push   $0x802a8c
  8019ab:	68 93 2a 80 00       	push   $0x802a93
  8019b0:	68 9f 00 00 00       	push   $0x9f
  8019b5:	68 a8 2a 80 00       	push   $0x802aa8
  8019ba:	e8 78 e8 ff ff       	call   800237 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  8019bf:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019c4:	76 19                	jbe    8019df <devfile_write+0x89>
  8019c6:	68 c0 2a 80 00       	push   $0x802ac0
  8019cb:	68 93 2a 80 00       	push   $0x802a93
  8019d0:	68 a0 00 00 00       	push   $0xa0
  8019d5:	68 a8 2a 80 00       	push   $0x802aa8
  8019da:	e8 58 e8 ff ff       	call   800237 <_panic>

	return r;
}
  8019df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e2:	c9                   	leave  
  8019e3:	c3                   	ret    

008019e4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	56                   	push   %esi
  8019e8:	53                   	push   %ebx
  8019e9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019f7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801a02:	b8 03 00 00 00       	mov    $0x3,%eax
  801a07:	e8 5a fe ff ff       	call   801866 <fsipc>
  801a0c:	89 c3                	mov    %eax,%ebx
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 4b                	js     801a5d <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a12:	39 c6                	cmp    %eax,%esi
  801a14:	73 16                	jae    801a2c <devfile_read+0x48>
  801a16:	68 8c 2a 80 00       	push   $0x802a8c
  801a1b:	68 93 2a 80 00       	push   $0x802a93
  801a20:	6a 7e                	push   $0x7e
  801a22:	68 a8 2a 80 00       	push   $0x802aa8
  801a27:	e8 0b e8 ff ff       	call   800237 <_panic>
	assert(r <= PGSIZE);
  801a2c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a31:	7e 16                	jle    801a49 <devfile_read+0x65>
  801a33:	68 b3 2a 80 00       	push   $0x802ab3
  801a38:	68 93 2a 80 00       	push   $0x802a93
  801a3d:	6a 7f                	push   $0x7f
  801a3f:	68 a8 2a 80 00       	push   $0x802aa8
  801a44:	e8 ee e7 ff ff       	call   800237 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a49:	83 ec 04             	sub    $0x4,%esp
  801a4c:	50                   	push   %eax
  801a4d:	68 00 50 80 00       	push   $0x805000
  801a52:	ff 75 0c             	pushl  0xc(%ebp)
  801a55:	e8 7c f0 ff ff       	call   800ad6 <memmove>
	return r;
  801a5a:	83 c4 10             	add    $0x10,%esp
}
  801a5d:	89 d8                	mov    %ebx,%eax
  801a5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a62:	5b                   	pop    %ebx
  801a63:	5e                   	pop    %esi
  801a64:	5d                   	pop    %ebp
  801a65:	c3                   	ret    

00801a66 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	53                   	push   %ebx
  801a6a:	83 ec 20             	sub    $0x20,%esp
  801a6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a70:	53                   	push   %ebx
  801a71:	e8 95 ee ff ff       	call   80090b <strlen>
  801a76:	83 c4 10             	add    $0x10,%esp
  801a79:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a7e:	7f 67                	jg     801ae7 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a80:	83 ec 0c             	sub    $0xc,%esp
  801a83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a86:	50                   	push   %eax
  801a87:	e8 52 f8 ff ff       	call   8012de <fd_alloc>
  801a8c:	83 c4 10             	add    $0x10,%esp
		return r;
  801a8f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a91:	85 c0                	test   %eax,%eax
  801a93:	78 57                	js     801aec <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a95:	83 ec 08             	sub    $0x8,%esp
  801a98:	53                   	push   %ebx
  801a99:	68 00 50 80 00       	push   $0x805000
  801a9e:	e8 a1 ee ff ff       	call   800944 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801aa3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801aab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aae:	b8 01 00 00 00       	mov    $0x1,%eax
  801ab3:	e8 ae fd ff ff       	call   801866 <fsipc>
  801ab8:	89 c3                	mov    %eax,%ebx
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	85 c0                	test   %eax,%eax
  801abf:	79 14                	jns    801ad5 <open+0x6f>
		fd_close(fd, 0);
  801ac1:	83 ec 08             	sub    $0x8,%esp
  801ac4:	6a 00                	push   $0x0
  801ac6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac9:	e8 08 f9 ff ff       	call   8013d6 <fd_close>
		return r;
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	89 da                	mov    %ebx,%edx
  801ad3:	eb 17                	jmp    801aec <open+0x86>
	}

	return fd2num(fd);
  801ad5:	83 ec 0c             	sub    $0xc,%esp
  801ad8:	ff 75 f4             	pushl  -0xc(%ebp)
  801adb:	e8 d7 f7 ff ff       	call   8012b7 <fd2num>
  801ae0:	89 c2                	mov    %eax,%edx
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	eb 05                	jmp    801aec <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ae7:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801aec:	89 d0                	mov    %edx,%eax
  801aee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af1:	c9                   	leave  
  801af2:	c3                   	ret    

00801af3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801af9:	ba 00 00 00 00       	mov    $0x0,%edx
  801afe:	b8 08 00 00 00       	mov    $0x8,%eax
  801b03:	e8 5e fd ff ff       	call   801866 <fsipc>
}
  801b08:	c9                   	leave  
  801b09:	c3                   	ret    

00801b0a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	56                   	push   %esi
  801b0e:	53                   	push   %ebx
  801b0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b12:	83 ec 0c             	sub    $0xc,%esp
  801b15:	ff 75 08             	pushl  0x8(%ebp)
  801b18:	e8 aa f7 ff ff       	call   8012c7 <fd2data>
  801b1d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b1f:	83 c4 08             	add    $0x8,%esp
  801b22:	68 ed 2a 80 00       	push   $0x802aed
  801b27:	53                   	push   %ebx
  801b28:	e8 17 ee ff ff       	call   800944 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b2d:	8b 46 04             	mov    0x4(%esi),%eax
  801b30:	2b 06                	sub    (%esi),%eax
  801b32:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b38:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b3f:	00 00 00 
	stat->st_dev = &devpipe;
  801b42:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b49:	30 80 00 
	return 0;
}
  801b4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b54:	5b                   	pop    %ebx
  801b55:	5e                   	pop    %esi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    

00801b58 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	53                   	push   %ebx
  801b5c:	83 ec 0c             	sub    $0xc,%esp
  801b5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b62:	53                   	push   %ebx
  801b63:	6a 00                	push   $0x0
  801b65:	e8 d9 f2 ff ff       	call   800e43 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b6a:	89 1c 24             	mov    %ebx,(%esp)
  801b6d:	e8 55 f7 ff ff       	call   8012c7 <fd2data>
  801b72:	83 c4 08             	add    $0x8,%esp
  801b75:	50                   	push   %eax
  801b76:	6a 00                	push   $0x0
  801b78:	e8 c6 f2 ff ff       	call   800e43 <sys_page_unmap>
}
  801b7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b80:	c9                   	leave  
  801b81:	c3                   	ret    

00801b82 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	57                   	push   %edi
  801b86:	56                   	push   %esi
  801b87:	53                   	push   %ebx
  801b88:	83 ec 1c             	sub    $0x1c,%esp
  801b8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b8e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b90:	a1 20 44 80 00       	mov    0x804420,%eax
  801b95:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b98:	83 ec 0c             	sub    $0xc,%esp
  801b9b:	ff 75 e0             	pushl  -0x20(%ebp)
  801b9e:	e8 1c 06 00 00       	call   8021bf <pageref>
  801ba3:	89 c3                	mov    %eax,%ebx
  801ba5:	89 3c 24             	mov    %edi,(%esp)
  801ba8:	e8 12 06 00 00       	call   8021bf <pageref>
  801bad:	83 c4 10             	add    $0x10,%esp
  801bb0:	39 c3                	cmp    %eax,%ebx
  801bb2:	0f 94 c1             	sete   %cl
  801bb5:	0f b6 c9             	movzbl %cl,%ecx
  801bb8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bbb:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801bc1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bc4:	39 ce                	cmp    %ecx,%esi
  801bc6:	74 1b                	je     801be3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bc8:	39 c3                	cmp    %eax,%ebx
  801bca:	75 c4                	jne    801b90 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bcc:	8b 42 58             	mov    0x58(%edx),%eax
  801bcf:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bd2:	50                   	push   %eax
  801bd3:	56                   	push   %esi
  801bd4:	68 f4 2a 80 00       	push   $0x802af4
  801bd9:	e8 32 e7 ff ff       	call   800310 <cprintf>
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	eb ad                	jmp    801b90 <_pipeisclosed+0xe>
	}
}
  801be3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be9:	5b                   	pop    %ebx
  801bea:	5e                   	pop    %esi
  801beb:	5f                   	pop    %edi
  801bec:	5d                   	pop    %ebp
  801bed:	c3                   	ret    

00801bee <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	57                   	push   %edi
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	83 ec 28             	sub    $0x28,%esp
  801bf7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bfa:	56                   	push   %esi
  801bfb:	e8 c7 f6 ff ff       	call   8012c7 <fd2data>
  801c00:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	bf 00 00 00 00       	mov    $0x0,%edi
  801c0a:	eb 4b                	jmp    801c57 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c0c:	89 da                	mov    %ebx,%edx
  801c0e:	89 f0                	mov    %esi,%eax
  801c10:	e8 6d ff ff ff       	call   801b82 <_pipeisclosed>
  801c15:	85 c0                	test   %eax,%eax
  801c17:	75 48                	jne    801c61 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c19:	e8 81 f1 ff ff       	call   800d9f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c1e:	8b 43 04             	mov    0x4(%ebx),%eax
  801c21:	8b 0b                	mov    (%ebx),%ecx
  801c23:	8d 51 20             	lea    0x20(%ecx),%edx
  801c26:	39 d0                	cmp    %edx,%eax
  801c28:	73 e2                	jae    801c0c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c2d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c31:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c34:	89 c2                	mov    %eax,%edx
  801c36:	c1 fa 1f             	sar    $0x1f,%edx
  801c39:	89 d1                	mov    %edx,%ecx
  801c3b:	c1 e9 1b             	shr    $0x1b,%ecx
  801c3e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c41:	83 e2 1f             	and    $0x1f,%edx
  801c44:	29 ca                	sub    %ecx,%edx
  801c46:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c4a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c4e:	83 c0 01             	add    $0x1,%eax
  801c51:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c54:	83 c7 01             	add    $0x1,%edi
  801c57:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c5a:	75 c2                	jne    801c1e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c5c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c5f:	eb 05                	jmp    801c66 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c61:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c69:	5b                   	pop    %ebx
  801c6a:	5e                   	pop    %esi
  801c6b:	5f                   	pop    %edi
  801c6c:	5d                   	pop    %ebp
  801c6d:	c3                   	ret    

00801c6e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	57                   	push   %edi
  801c72:	56                   	push   %esi
  801c73:	53                   	push   %ebx
  801c74:	83 ec 18             	sub    $0x18,%esp
  801c77:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c7a:	57                   	push   %edi
  801c7b:	e8 47 f6 ff ff       	call   8012c7 <fd2data>
  801c80:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c82:	83 c4 10             	add    $0x10,%esp
  801c85:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c8a:	eb 3d                	jmp    801cc9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c8c:	85 db                	test   %ebx,%ebx
  801c8e:	74 04                	je     801c94 <devpipe_read+0x26>
				return i;
  801c90:	89 d8                	mov    %ebx,%eax
  801c92:	eb 44                	jmp    801cd8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c94:	89 f2                	mov    %esi,%edx
  801c96:	89 f8                	mov    %edi,%eax
  801c98:	e8 e5 fe ff ff       	call   801b82 <_pipeisclosed>
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	75 32                	jne    801cd3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ca1:	e8 f9 f0 ff ff       	call   800d9f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ca6:	8b 06                	mov    (%esi),%eax
  801ca8:	3b 46 04             	cmp    0x4(%esi),%eax
  801cab:	74 df                	je     801c8c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cad:	99                   	cltd   
  801cae:	c1 ea 1b             	shr    $0x1b,%edx
  801cb1:	01 d0                	add    %edx,%eax
  801cb3:	83 e0 1f             	and    $0x1f,%eax
  801cb6:	29 d0                	sub    %edx,%eax
  801cb8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cc0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cc3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc6:	83 c3 01             	add    $0x1,%ebx
  801cc9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ccc:	75 d8                	jne    801ca6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cce:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd1:	eb 05                	jmp    801cd8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cd3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cdb:	5b                   	pop    %ebx
  801cdc:	5e                   	pop    %esi
  801cdd:	5f                   	pop    %edi
  801cde:	5d                   	pop    %ebp
  801cdf:	c3                   	ret    

00801ce0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	56                   	push   %esi
  801ce4:	53                   	push   %ebx
  801ce5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ce8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ceb:	50                   	push   %eax
  801cec:	e8 ed f5 ff ff       	call   8012de <fd_alloc>
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	89 c2                	mov    %eax,%edx
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	0f 88 2c 01 00 00    	js     801e2a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfe:	83 ec 04             	sub    $0x4,%esp
  801d01:	68 07 04 00 00       	push   $0x407
  801d06:	ff 75 f4             	pushl  -0xc(%ebp)
  801d09:	6a 00                	push   $0x0
  801d0b:	e8 ae f0 ff ff       	call   800dbe <sys_page_alloc>
  801d10:	83 c4 10             	add    $0x10,%esp
  801d13:	89 c2                	mov    %eax,%edx
  801d15:	85 c0                	test   %eax,%eax
  801d17:	0f 88 0d 01 00 00    	js     801e2a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d1d:	83 ec 0c             	sub    $0xc,%esp
  801d20:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d23:	50                   	push   %eax
  801d24:	e8 b5 f5 ff ff       	call   8012de <fd_alloc>
  801d29:	89 c3                	mov    %eax,%ebx
  801d2b:	83 c4 10             	add    $0x10,%esp
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	0f 88 e2 00 00 00    	js     801e18 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d36:	83 ec 04             	sub    $0x4,%esp
  801d39:	68 07 04 00 00       	push   $0x407
  801d3e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d41:	6a 00                	push   $0x0
  801d43:	e8 76 f0 ff ff       	call   800dbe <sys_page_alloc>
  801d48:	89 c3                	mov    %eax,%ebx
  801d4a:	83 c4 10             	add    $0x10,%esp
  801d4d:	85 c0                	test   %eax,%eax
  801d4f:	0f 88 c3 00 00 00    	js     801e18 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d55:	83 ec 0c             	sub    $0xc,%esp
  801d58:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5b:	e8 67 f5 ff ff       	call   8012c7 <fd2data>
  801d60:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d62:	83 c4 0c             	add    $0xc,%esp
  801d65:	68 07 04 00 00       	push   $0x407
  801d6a:	50                   	push   %eax
  801d6b:	6a 00                	push   $0x0
  801d6d:	e8 4c f0 ff ff       	call   800dbe <sys_page_alloc>
  801d72:	89 c3                	mov    %eax,%ebx
  801d74:	83 c4 10             	add    $0x10,%esp
  801d77:	85 c0                	test   %eax,%eax
  801d79:	0f 88 89 00 00 00    	js     801e08 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d7f:	83 ec 0c             	sub    $0xc,%esp
  801d82:	ff 75 f0             	pushl  -0x10(%ebp)
  801d85:	e8 3d f5 ff ff       	call   8012c7 <fd2data>
  801d8a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d91:	50                   	push   %eax
  801d92:	6a 00                	push   $0x0
  801d94:	56                   	push   %esi
  801d95:	6a 00                	push   $0x0
  801d97:	e8 65 f0 ff ff       	call   800e01 <sys_page_map>
  801d9c:	89 c3                	mov    %eax,%ebx
  801d9e:	83 c4 20             	add    $0x20,%esp
  801da1:	85 c0                	test   %eax,%eax
  801da3:	78 55                	js     801dfa <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801da5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dae:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dba:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dcf:	83 ec 0c             	sub    $0xc,%esp
  801dd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd5:	e8 dd f4 ff ff       	call   8012b7 <fd2num>
  801dda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ddd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ddf:	83 c4 04             	add    $0x4,%esp
  801de2:	ff 75 f0             	pushl  -0x10(%ebp)
  801de5:	e8 cd f4 ff ff       	call   8012b7 <fd2num>
  801dea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ded:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	ba 00 00 00 00       	mov    $0x0,%edx
  801df8:	eb 30                	jmp    801e2a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dfa:	83 ec 08             	sub    $0x8,%esp
  801dfd:	56                   	push   %esi
  801dfe:	6a 00                	push   $0x0
  801e00:	e8 3e f0 ff ff       	call   800e43 <sys_page_unmap>
  801e05:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e08:	83 ec 08             	sub    $0x8,%esp
  801e0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e0e:	6a 00                	push   $0x0
  801e10:	e8 2e f0 ff ff       	call   800e43 <sys_page_unmap>
  801e15:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e18:	83 ec 08             	sub    $0x8,%esp
  801e1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1e:	6a 00                	push   $0x0
  801e20:	e8 1e f0 ff ff       	call   800e43 <sys_page_unmap>
  801e25:	83 c4 10             	add    $0x10,%esp
  801e28:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e2a:	89 d0                	mov    %edx,%eax
  801e2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2f:	5b                   	pop    %ebx
  801e30:	5e                   	pop    %esi
  801e31:	5d                   	pop    %ebp
  801e32:	c3                   	ret    

00801e33 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3c:	50                   	push   %eax
  801e3d:	ff 75 08             	pushl  0x8(%ebp)
  801e40:	e8 e8 f4 ff ff       	call   80132d <fd_lookup>
  801e45:	83 c4 10             	add    $0x10,%esp
  801e48:	85 c0                	test   %eax,%eax
  801e4a:	78 18                	js     801e64 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e4c:	83 ec 0c             	sub    $0xc,%esp
  801e4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e52:	e8 70 f4 ff ff       	call   8012c7 <fd2data>
	return _pipeisclosed(fd, p);
  801e57:	89 c2                	mov    %eax,%edx
  801e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5c:	e8 21 fd ff ff       	call   801b82 <_pipeisclosed>
  801e61:	83 c4 10             	add    $0x10,%esp
}
  801e64:	c9                   	leave  
  801e65:	c3                   	ret    

00801e66 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	56                   	push   %esi
  801e6a:	53                   	push   %ebx
  801e6b:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801e6e:	85 f6                	test   %esi,%esi
  801e70:	75 16                	jne    801e88 <wait+0x22>
  801e72:	68 0c 2b 80 00       	push   $0x802b0c
  801e77:	68 93 2a 80 00       	push   $0x802a93
  801e7c:	6a 09                	push   $0x9
  801e7e:	68 17 2b 80 00       	push   $0x802b17
  801e83:	e8 af e3 ff ff       	call   800237 <_panic>
	e = &envs[ENVX(envid)];
  801e88:	89 f3                	mov    %esi,%ebx
  801e8a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e90:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801e93:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801e99:	eb 05                	jmp    801ea0 <wait+0x3a>
		sys_yield();
  801e9b:	e8 ff ee ff ff       	call   800d9f <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801ea0:	8b 43 48             	mov    0x48(%ebx),%eax
  801ea3:	39 c6                	cmp    %eax,%esi
  801ea5:	75 07                	jne    801eae <wait+0x48>
  801ea7:	8b 43 54             	mov    0x54(%ebx),%eax
  801eaa:	85 c0                	test   %eax,%eax
  801eac:	75 ed                	jne    801e9b <wait+0x35>
		sys_yield();
}
  801eae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb1:	5b                   	pop    %ebx
  801eb2:	5e                   	pop    %esi
  801eb3:	5d                   	pop    %ebp
  801eb4:	c3                   	ret    

00801eb5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801eb5:	55                   	push   %ebp
  801eb6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801eb8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ebd:	5d                   	pop    %ebp
  801ebe:	c3                   	ret    

00801ebf <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
  801ec2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ec5:	68 22 2b 80 00       	push   $0x802b22
  801eca:	ff 75 0c             	pushl  0xc(%ebp)
  801ecd:	e8 72 ea ff ff       	call   800944 <strcpy>
	return 0;
}
  801ed2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed7:	c9                   	leave  
  801ed8:	c3                   	ret    

00801ed9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	57                   	push   %edi
  801edd:	56                   	push   %esi
  801ede:	53                   	push   %ebx
  801edf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ee5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eea:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ef0:	eb 2d                	jmp    801f1f <devcons_write+0x46>
		m = n - tot;
  801ef2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ef5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ef7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801efa:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801eff:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f02:	83 ec 04             	sub    $0x4,%esp
  801f05:	53                   	push   %ebx
  801f06:	03 45 0c             	add    0xc(%ebp),%eax
  801f09:	50                   	push   %eax
  801f0a:	57                   	push   %edi
  801f0b:	e8 c6 eb ff ff       	call   800ad6 <memmove>
		sys_cputs(buf, m);
  801f10:	83 c4 08             	add    $0x8,%esp
  801f13:	53                   	push   %ebx
  801f14:	57                   	push   %edi
  801f15:	e8 e8 ed ff ff       	call   800d02 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f1a:	01 de                	add    %ebx,%esi
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	89 f0                	mov    %esi,%eax
  801f21:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f24:	72 cc                	jb     801ef2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f29:	5b                   	pop    %ebx
  801f2a:	5e                   	pop    %esi
  801f2b:	5f                   	pop    %edi
  801f2c:	5d                   	pop    %ebp
  801f2d:	c3                   	ret    

00801f2e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	83 ec 08             	sub    $0x8,%esp
  801f34:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f39:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f3d:	74 2a                	je     801f69 <devcons_read+0x3b>
  801f3f:	eb 05                	jmp    801f46 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f41:	e8 59 ee ff ff       	call   800d9f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f46:	e8 d5 ed ff ff       	call   800d20 <sys_cgetc>
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	74 f2                	je     801f41 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f4f:	85 c0                	test   %eax,%eax
  801f51:	78 16                	js     801f69 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f53:	83 f8 04             	cmp    $0x4,%eax
  801f56:	74 0c                	je     801f64 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f58:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f5b:	88 02                	mov    %al,(%edx)
	return 1;
  801f5d:	b8 01 00 00 00       	mov    $0x1,%eax
  801f62:	eb 05                	jmp    801f69 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f64:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f69:	c9                   	leave  
  801f6a:	c3                   	ret    

00801f6b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f6b:	55                   	push   %ebp
  801f6c:	89 e5                	mov    %esp,%ebp
  801f6e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f71:	8b 45 08             	mov    0x8(%ebp),%eax
  801f74:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f77:	6a 01                	push   $0x1
  801f79:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f7c:	50                   	push   %eax
  801f7d:	e8 80 ed ff ff       	call   800d02 <sys_cputs>
}
  801f82:	83 c4 10             	add    $0x10,%esp
  801f85:	c9                   	leave  
  801f86:	c3                   	ret    

00801f87 <getchar>:

int
getchar(void)
{
  801f87:	55                   	push   %ebp
  801f88:	89 e5                	mov    %esp,%ebp
  801f8a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f8d:	6a 01                	push   $0x1
  801f8f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f92:	50                   	push   %eax
  801f93:	6a 00                	push   $0x0
  801f95:	e8 f9 f5 ff ff       	call   801593 <read>
	if (r < 0)
  801f9a:	83 c4 10             	add    $0x10,%esp
  801f9d:	85 c0                	test   %eax,%eax
  801f9f:	78 0f                	js     801fb0 <getchar+0x29>
		return r;
	if (r < 1)
  801fa1:	85 c0                	test   %eax,%eax
  801fa3:	7e 06                	jle    801fab <getchar+0x24>
		return -E_EOF;
	return c;
  801fa5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fa9:	eb 05                	jmp    801fb0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fab:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fb0:	c9                   	leave  
  801fb1:	c3                   	ret    

00801fb2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fb2:	55                   	push   %ebp
  801fb3:	89 e5                	mov    %esp,%ebp
  801fb5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fbb:	50                   	push   %eax
  801fbc:	ff 75 08             	pushl  0x8(%ebp)
  801fbf:	e8 69 f3 ff ff       	call   80132d <fd_lookup>
  801fc4:	83 c4 10             	add    $0x10,%esp
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	78 11                	js     801fdc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fce:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fd4:	39 10                	cmp    %edx,(%eax)
  801fd6:	0f 94 c0             	sete   %al
  801fd9:	0f b6 c0             	movzbl %al,%eax
}
  801fdc:	c9                   	leave  
  801fdd:	c3                   	ret    

00801fde <opencons>:

int
opencons(void)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fe4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe7:	50                   	push   %eax
  801fe8:	e8 f1 f2 ff ff       	call   8012de <fd_alloc>
  801fed:	83 c4 10             	add    $0x10,%esp
		return r;
  801ff0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ff2:	85 c0                	test   %eax,%eax
  801ff4:	78 3e                	js     802034 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ff6:	83 ec 04             	sub    $0x4,%esp
  801ff9:	68 07 04 00 00       	push   $0x407
  801ffe:	ff 75 f4             	pushl  -0xc(%ebp)
  802001:	6a 00                	push   $0x0
  802003:	e8 b6 ed ff ff       	call   800dbe <sys_page_alloc>
  802008:	83 c4 10             	add    $0x10,%esp
		return r;
  80200b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80200d:	85 c0                	test   %eax,%eax
  80200f:	78 23                	js     802034 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802011:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802017:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80201c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802026:	83 ec 0c             	sub    $0xc,%esp
  802029:	50                   	push   %eax
  80202a:	e8 88 f2 ff ff       	call   8012b7 <fd2num>
  80202f:	89 c2                	mov    %eax,%edx
  802031:	83 c4 10             	add    $0x10,%esp
}
  802034:	89 d0                	mov    %edx,%eax
  802036:	c9                   	leave  
  802037:	c3                   	ret    

00802038 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802038:	55                   	push   %ebp
  802039:	89 e5                	mov    %esp,%ebp
  80203b:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  80203e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802045:	75 52                	jne    802099 <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  802047:	83 ec 04             	sub    $0x4,%esp
  80204a:	6a 07                	push   $0x7
  80204c:	68 00 f0 bf ee       	push   $0xeebff000
  802051:	6a 00                	push   $0x0
  802053:	e8 66 ed ff ff       	call   800dbe <sys_page_alloc>
  802058:	83 c4 10             	add    $0x10,%esp
  80205b:	85 c0                	test   %eax,%eax
  80205d:	79 12                	jns    802071 <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  80205f:	50                   	push   %eax
  802060:	68 60 29 80 00       	push   $0x802960
  802065:	6a 23                	push   $0x23
  802067:	68 2e 2b 80 00       	push   $0x802b2e
  80206c:	e8 c6 e1 ff ff       	call   800237 <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  802071:	83 ec 08             	sub    $0x8,%esp
  802074:	68 a3 20 80 00       	push   $0x8020a3
  802079:	6a 00                	push   $0x0
  80207b:	e8 89 ee ff ff       	call   800f09 <sys_env_set_pgfault_upcall>
  802080:	83 c4 10             	add    $0x10,%esp
  802083:	85 c0                	test   %eax,%eax
  802085:	79 12                	jns    802099 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  802087:	50                   	push   %eax
  802088:	68 e0 29 80 00       	push   $0x8029e0
  80208d:	6a 26                	push   $0x26
  80208f:	68 2e 2b 80 00       	push   $0x802b2e
  802094:	e8 9e e1 ff ff       	call   800237 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802099:	8b 45 08             	mov    0x8(%ebp),%eax
  80209c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8020a1:	c9                   	leave  
  8020a2:	c3                   	ret    

008020a3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020a3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020a4:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020a9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020ab:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  8020ae:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  8020b2:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  8020b7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  8020bb:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8020bd:	83 c4 08             	add    $0x8,%esp
	popal 
  8020c0:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8020c1:	83 c4 04             	add    $0x4,%esp
	popfl
  8020c4:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8020c5:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020c6:	c3                   	ret    

008020c7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020c7:	55                   	push   %ebp
  8020c8:	89 e5                	mov    %esp,%ebp
  8020ca:	56                   	push   %esi
  8020cb:	53                   	push   %ebx
  8020cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8020cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  8020d5:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8020d7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8020dc:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  8020df:	83 ec 0c             	sub    $0xc,%esp
  8020e2:	50                   	push   %eax
  8020e3:	e8 86 ee ff ff       	call   800f6e <sys_ipc_recv>
  8020e8:	83 c4 10             	add    $0x10,%esp
  8020eb:	85 c0                	test   %eax,%eax
  8020ed:	79 16                	jns    802105 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  8020ef:	85 f6                	test   %esi,%esi
  8020f1:	74 06                	je     8020f9 <ipc_recv+0x32>
			*from_env_store = 0;
  8020f3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  8020f9:	85 db                	test   %ebx,%ebx
  8020fb:	74 2c                	je     802129 <ipc_recv+0x62>
			*perm_store = 0;
  8020fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802103:	eb 24                	jmp    802129 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  802105:	85 f6                	test   %esi,%esi
  802107:	74 0a                	je     802113 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  802109:	a1 20 44 80 00       	mov    0x804420,%eax
  80210e:	8b 40 74             	mov    0x74(%eax),%eax
  802111:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  802113:	85 db                	test   %ebx,%ebx
  802115:	74 0a                	je     802121 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  802117:	a1 20 44 80 00       	mov    0x804420,%eax
  80211c:	8b 40 78             	mov    0x78(%eax),%eax
  80211f:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  802121:	a1 20 44 80 00       	mov    0x804420,%eax
  802126:	8b 40 70             	mov    0x70(%eax),%eax
}
  802129:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80212c:	5b                   	pop    %ebx
  80212d:	5e                   	pop    %esi
  80212e:	5d                   	pop    %ebp
  80212f:	c3                   	ret    

00802130 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	57                   	push   %edi
  802134:	56                   	push   %esi
  802135:	53                   	push   %ebx
  802136:	83 ec 0c             	sub    $0xc,%esp
  802139:	8b 7d 08             	mov    0x8(%ebp),%edi
  80213c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80213f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  802142:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802144:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802149:	0f 44 d8             	cmove  %eax,%ebx
  80214c:	eb 1e                	jmp    80216c <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  80214e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802151:	74 14                	je     802167 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  802153:	83 ec 04             	sub    $0x4,%esp
  802156:	68 3c 2b 80 00       	push   $0x802b3c
  80215b:	6a 44                	push   $0x44
  80215d:	68 68 2b 80 00       	push   $0x802b68
  802162:	e8 d0 e0 ff ff       	call   800237 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  802167:	e8 33 ec ff ff       	call   800d9f <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80216c:	ff 75 14             	pushl  0x14(%ebp)
  80216f:	53                   	push   %ebx
  802170:	56                   	push   %esi
  802171:	57                   	push   %edi
  802172:	e8 d4 ed ff ff       	call   800f4b <sys_ipc_try_send>
  802177:	83 c4 10             	add    $0x10,%esp
  80217a:	85 c0                	test   %eax,%eax
  80217c:	78 d0                	js     80214e <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  80217e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802181:	5b                   	pop    %ebx
  802182:	5e                   	pop    %esi
  802183:	5f                   	pop    %edi
  802184:	5d                   	pop    %ebp
  802185:	c3                   	ret    

00802186 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802186:	55                   	push   %ebp
  802187:	89 e5                	mov    %esp,%ebp
  802189:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80218c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802191:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802194:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80219a:	8b 52 50             	mov    0x50(%edx),%edx
  80219d:	39 ca                	cmp    %ecx,%edx
  80219f:	75 0d                	jne    8021ae <ipc_find_env+0x28>
			return envs[i].env_id;
  8021a1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021a4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021a9:	8b 40 48             	mov    0x48(%eax),%eax
  8021ac:	eb 0f                	jmp    8021bd <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021ae:	83 c0 01             	add    $0x1,%eax
  8021b1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021b6:	75 d9                	jne    802191 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021bd:	5d                   	pop    %ebp
  8021be:	c3                   	ret    

008021bf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021bf:	55                   	push   %ebp
  8021c0:	89 e5                	mov    %esp,%ebp
  8021c2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021c5:	89 d0                	mov    %edx,%eax
  8021c7:	c1 e8 16             	shr    $0x16,%eax
  8021ca:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021d1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021d6:	f6 c1 01             	test   $0x1,%cl
  8021d9:	74 1d                	je     8021f8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021db:	c1 ea 0c             	shr    $0xc,%edx
  8021de:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021e5:	f6 c2 01             	test   $0x1,%dl
  8021e8:	74 0e                	je     8021f8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021ea:	c1 ea 0c             	shr    $0xc,%edx
  8021ed:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021f4:	ef 
  8021f5:	0f b7 c0             	movzwl %ax,%eax
}
  8021f8:	5d                   	pop    %ebp
  8021f9:	c3                   	ret    
  8021fa:	66 90                	xchg   %ax,%ax
  8021fc:	66 90                	xchg   %ax,%ax
  8021fe:	66 90                	xchg   %ax,%ax

00802200 <__udivdi3>:
  802200:	55                   	push   %ebp
  802201:	57                   	push   %edi
  802202:	56                   	push   %esi
  802203:	53                   	push   %ebx
  802204:	83 ec 1c             	sub    $0x1c,%esp
  802207:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80220b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80220f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802217:	85 f6                	test   %esi,%esi
  802219:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80221d:	89 ca                	mov    %ecx,%edx
  80221f:	89 f8                	mov    %edi,%eax
  802221:	75 3d                	jne    802260 <__udivdi3+0x60>
  802223:	39 cf                	cmp    %ecx,%edi
  802225:	0f 87 c5 00 00 00    	ja     8022f0 <__udivdi3+0xf0>
  80222b:	85 ff                	test   %edi,%edi
  80222d:	89 fd                	mov    %edi,%ebp
  80222f:	75 0b                	jne    80223c <__udivdi3+0x3c>
  802231:	b8 01 00 00 00       	mov    $0x1,%eax
  802236:	31 d2                	xor    %edx,%edx
  802238:	f7 f7                	div    %edi
  80223a:	89 c5                	mov    %eax,%ebp
  80223c:	89 c8                	mov    %ecx,%eax
  80223e:	31 d2                	xor    %edx,%edx
  802240:	f7 f5                	div    %ebp
  802242:	89 c1                	mov    %eax,%ecx
  802244:	89 d8                	mov    %ebx,%eax
  802246:	89 cf                	mov    %ecx,%edi
  802248:	f7 f5                	div    %ebp
  80224a:	89 c3                	mov    %eax,%ebx
  80224c:	89 d8                	mov    %ebx,%eax
  80224e:	89 fa                	mov    %edi,%edx
  802250:	83 c4 1c             	add    $0x1c,%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5f                   	pop    %edi
  802256:	5d                   	pop    %ebp
  802257:	c3                   	ret    
  802258:	90                   	nop
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	39 ce                	cmp    %ecx,%esi
  802262:	77 74                	ja     8022d8 <__udivdi3+0xd8>
  802264:	0f bd fe             	bsr    %esi,%edi
  802267:	83 f7 1f             	xor    $0x1f,%edi
  80226a:	0f 84 98 00 00 00    	je     802308 <__udivdi3+0x108>
  802270:	bb 20 00 00 00       	mov    $0x20,%ebx
  802275:	89 f9                	mov    %edi,%ecx
  802277:	89 c5                	mov    %eax,%ebp
  802279:	29 fb                	sub    %edi,%ebx
  80227b:	d3 e6                	shl    %cl,%esi
  80227d:	89 d9                	mov    %ebx,%ecx
  80227f:	d3 ed                	shr    %cl,%ebp
  802281:	89 f9                	mov    %edi,%ecx
  802283:	d3 e0                	shl    %cl,%eax
  802285:	09 ee                	or     %ebp,%esi
  802287:	89 d9                	mov    %ebx,%ecx
  802289:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80228d:	89 d5                	mov    %edx,%ebp
  80228f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802293:	d3 ed                	shr    %cl,%ebp
  802295:	89 f9                	mov    %edi,%ecx
  802297:	d3 e2                	shl    %cl,%edx
  802299:	89 d9                	mov    %ebx,%ecx
  80229b:	d3 e8                	shr    %cl,%eax
  80229d:	09 c2                	or     %eax,%edx
  80229f:	89 d0                	mov    %edx,%eax
  8022a1:	89 ea                	mov    %ebp,%edx
  8022a3:	f7 f6                	div    %esi
  8022a5:	89 d5                	mov    %edx,%ebp
  8022a7:	89 c3                	mov    %eax,%ebx
  8022a9:	f7 64 24 0c          	mull   0xc(%esp)
  8022ad:	39 d5                	cmp    %edx,%ebp
  8022af:	72 10                	jb     8022c1 <__udivdi3+0xc1>
  8022b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022b5:	89 f9                	mov    %edi,%ecx
  8022b7:	d3 e6                	shl    %cl,%esi
  8022b9:	39 c6                	cmp    %eax,%esi
  8022bb:	73 07                	jae    8022c4 <__udivdi3+0xc4>
  8022bd:	39 d5                	cmp    %edx,%ebp
  8022bf:	75 03                	jne    8022c4 <__udivdi3+0xc4>
  8022c1:	83 eb 01             	sub    $0x1,%ebx
  8022c4:	31 ff                	xor    %edi,%edi
  8022c6:	89 d8                	mov    %ebx,%eax
  8022c8:	89 fa                	mov    %edi,%edx
  8022ca:	83 c4 1c             	add    $0x1c,%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5f                   	pop    %edi
  8022d0:	5d                   	pop    %ebp
  8022d1:	c3                   	ret    
  8022d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022d8:	31 ff                	xor    %edi,%edi
  8022da:	31 db                	xor    %ebx,%ebx
  8022dc:	89 d8                	mov    %ebx,%eax
  8022de:	89 fa                	mov    %edi,%edx
  8022e0:	83 c4 1c             	add    $0x1c,%esp
  8022e3:	5b                   	pop    %ebx
  8022e4:	5e                   	pop    %esi
  8022e5:	5f                   	pop    %edi
  8022e6:	5d                   	pop    %ebp
  8022e7:	c3                   	ret    
  8022e8:	90                   	nop
  8022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	89 d8                	mov    %ebx,%eax
  8022f2:	f7 f7                	div    %edi
  8022f4:	31 ff                	xor    %edi,%edi
  8022f6:	89 c3                	mov    %eax,%ebx
  8022f8:	89 d8                	mov    %ebx,%eax
  8022fa:	89 fa                	mov    %edi,%edx
  8022fc:	83 c4 1c             	add    $0x1c,%esp
  8022ff:	5b                   	pop    %ebx
  802300:	5e                   	pop    %esi
  802301:	5f                   	pop    %edi
  802302:	5d                   	pop    %ebp
  802303:	c3                   	ret    
  802304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802308:	39 ce                	cmp    %ecx,%esi
  80230a:	72 0c                	jb     802318 <__udivdi3+0x118>
  80230c:	31 db                	xor    %ebx,%ebx
  80230e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802312:	0f 87 34 ff ff ff    	ja     80224c <__udivdi3+0x4c>
  802318:	bb 01 00 00 00       	mov    $0x1,%ebx
  80231d:	e9 2a ff ff ff       	jmp    80224c <__udivdi3+0x4c>
  802322:	66 90                	xchg   %ax,%ax
  802324:	66 90                	xchg   %ax,%ax
  802326:	66 90                	xchg   %ax,%ax
  802328:	66 90                	xchg   %ax,%ax
  80232a:	66 90                	xchg   %ax,%ax
  80232c:	66 90                	xchg   %ax,%ax
  80232e:	66 90                	xchg   %ax,%ax

00802330 <__umoddi3>:
  802330:	55                   	push   %ebp
  802331:	57                   	push   %edi
  802332:	56                   	push   %esi
  802333:	53                   	push   %ebx
  802334:	83 ec 1c             	sub    $0x1c,%esp
  802337:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80233b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80233f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802343:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802347:	85 d2                	test   %edx,%edx
  802349:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80234d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802351:	89 f3                	mov    %esi,%ebx
  802353:	89 3c 24             	mov    %edi,(%esp)
  802356:	89 74 24 04          	mov    %esi,0x4(%esp)
  80235a:	75 1c                	jne    802378 <__umoddi3+0x48>
  80235c:	39 f7                	cmp    %esi,%edi
  80235e:	76 50                	jbe    8023b0 <__umoddi3+0x80>
  802360:	89 c8                	mov    %ecx,%eax
  802362:	89 f2                	mov    %esi,%edx
  802364:	f7 f7                	div    %edi
  802366:	89 d0                	mov    %edx,%eax
  802368:	31 d2                	xor    %edx,%edx
  80236a:	83 c4 1c             	add    $0x1c,%esp
  80236d:	5b                   	pop    %ebx
  80236e:	5e                   	pop    %esi
  80236f:	5f                   	pop    %edi
  802370:	5d                   	pop    %ebp
  802371:	c3                   	ret    
  802372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802378:	39 f2                	cmp    %esi,%edx
  80237a:	89 d0                	mov    %edx,%eax
  80237c:	77 52                	ja     8023d0 <__umoddi3+0xa0>
  80237e:	0f bd ea             	bsr    %edx,%ebp
  802381:	83 f5 1f             	xor    $0x1f,%ebp
  802384:	75 5a                	jne    8023e0 <__umoddi3+0xb0>
  802386:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80238a:	0f 82 e0 00 00 00    	jb     802470 <__umoddi3+0x140>
  802390:	39 0c 24             	cmp    %ecx,(%esp)
  802393:	0f 86 d7 00 00 00    	jbe    802470 <__umoddi3+0x140>
  802399:	8b 44 24 08          	mov    0x8(%esp),%eax
  80239d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023a1:	83 c4 1c             	add    $0x1c,%esp
  8023a4:	5b                   	pop    %ebx
  8023a5:	5e                   	pop    %esi
  8023a6:	5f                   	pop    %edi
  8023a7:	5d                   	pop    %ebp
  8023a8:	c3                   	ret    
  8023a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	85 ff                	test   %edi,%edi
  8023b2:	89 fd                	mov    %edi,%ebp
  8023b4:	75 0b                	jne    8023c1 <__umoddi3+0x91>
  8023b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023bb:	31 d2                	xor    %edx,%edx
  8023bd:	f7 f7                	div    %edi
  8023bf:	89 c5                	mov    %eax,%ebp
  8023c1:	89 f0                	mov    %esi,%eax
  8023c3:	31 d2                	xor    %edx,%edx
  8023c5:	f7 f5                	div    %ebp
  8023c7:	89 c8                	mov    %ecx,%eax
  8023c9:	f7 f5                	div    %ebp
  8023cb:	89 d0                	mov    %edx,%eax
  8023cd:	eb 99                	jmp    802368 <__umoddi3+0x38>
  8023cf:	90                   	nop
  8023d0:	89 c8                	mov    %ecx,%eax
  8023d2:	89 f2                	mov    %esi,%edx
  8023d4:	83 c4 1c             	add    $0x1c,%esp
  8023d7:	5b                   	pop    %ebx
  8023d8:	5e                   	pop    %esi
  8023d9:	5f                   	pop    %edi
  8023da:	5d                   	pop    %ebp
  8023db:	c3                   	ret    
  8023dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	8b 34 24             	mov    (%esp),%esi
  8023e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023e8:	89 e9                	mov    %ebp,%ecx
  8023ea:	29 ef                	sub    %ebp,%edi
  8023ec:	d3 e0                	shl    %cl,%eax
  8023ee:	89 f9                	mov    %edi,%ecx
  8023f0:	89 f2                	mov    %esi,%edx
  8023f2:	d3 ea                	shr    %cl,%edx
  8023f4:	89 e9                	mov    %ebp,%ecx
  8023f6:	09 c2                	or     %eax,%edx
  8023f8:	89 d8                	mov    %ebx,%eax
  8023fa:	89 14 24             	mov    %edx,(%esp)
  8023fd:	89 f2                	mov    %esi,%edx
  8023ff:	d3 e2                	shl    %cl,%edx
  802401:	89 f9                	mov    %edi,%ecx
  802403:	89 54 24 04          	mov    %edx,0x4(%esp)
  802407:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80240b:	d3 e8                	shr    %cl,%eax
  80240d:	89 e9                	mov    %ebp,%ecx
  80240f:	89 c6                	mov    %eax,%esi
  802411:	d3 e3                	shl    %cl,%ebx
  802413:	89 f9                	mov    %edi,%ecx
  802415:	89 d0                	mov    %edx,%eax
  802417:	d3 e8                	shr    %cl,%eax
  802419:	89 e9                	mov    %ebp,%ecx
  80241b:	09 d8                	or     %ebx,%eax
  80241d:	89 d3                	mov    %edx,%ebx
  80241f:	89 f2                	mov    %esi,%edx
  802421:	f7 34 24             	divl   (%esp)
  802424:	89 d6                	mov    %edx,%esi
  802426:	d3 e3                	shl    %cl,%ebx
  802428:	f7 64 24 04          	mull   0x4(%esp)
  80242c:	39 d6                	cmp    %edx,%esi
  80242e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802432:	89 d1                	mov    %edx,%ecx
  802434:	89 c3                	mov    %eax,%ebx
  802436:	72 08                	jb     802440 <__umoddi3+0x110>
  802438:	75 11                	jne    80244b <__umoddi3+0x11b>
  80243a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80243e:	73 0b                	jae    80244b <__umoddi3+0x11b>
  802440:	2b 44 24 04          	sub    0x4(%esp),%eax
  802444:	1b 14 24             	sbb    (%esp),%edx
  802447:	89 d1                	mov    %edx,%ecx
  802449:	89 c3                	mov    %eax,%ebx
  80244b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80244f:	29 da                	sub    %ebx,%edx
  802451:	19 ce                	sbb    %ecx,%esi
  802453:	89 f9                	mov    %edi,%ecx
  802455:	89 f0                	mov    %esi,%eax
  802457:	d3 e0                	shl    %cl,%eax
  802459:	89 e9                	mov    %ebp,%ecx
  80245b:	d3 ea                	shr    %cl,%edx
  80245d:	89 e9                	mov    %ebp,%ecx
  80245f:	d3 ee                	shr    %cl,%esi
  802461:	09 d0                	or     %edx,%eax
  802463:	89 f2                	mov    %esi,%edx
  802465:	83 c4 1c             	add    $0x1c,%esp
  802468:	5b                   	pop    %ebx
  802469:	5e                   	pop    %esi
  80246a:	5f                   	pop    %edi
  80246b:	5d                   	pop    %ebp
  80246c:	c3                   	ret    
  80246d:	8d 76 00             	lea    0x0(%esi),%esi
  802470:	29 f9                	sub    %edi,%ecx
  802472:	19 d6                	sbb    %edx,%esi
  802474:	89 74 24 04          	mov    %esi,0x4(%esp)
  802478:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80247c:	e9 18 ff ff ff       	jmp    802399 <__umoddi3+0x69>
