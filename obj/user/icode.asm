
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
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
  800038:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 30 80 00 c0 	movl   $0x8025c0,0x803000
  800045:	25 80 00 

	cprintf("icode startup\n");
  800048:	68 c6 25 80 00       	push   $0x8025c6
  80004d:	e8 1b 02 00 00       	call   80026d <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 d5 25 80 00 	movl   $0x8025d5,(%esp)
  800059:	e8 0f 02 00 00       	call   80026d <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 e8 25 80 00       	push   $0x8025e8
  800068:	e8 4e 16 00 00       	call   8016bb <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 ee 25 80 00       	push   $0x8025ee
  80007c:	6a 0f                	push   $0xf
  80007e:	68 04 26 80 00       	push   $0x802604
  800083:	e8 0c 01 00 00       	call   800194 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 11 26 80 00       	push   $0x802611
  800090:	e8 d8 01 00 00       	call   80026d <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009e:	eb 0d                	jmp    8000ad <umain+0x7a>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 b5 0b 00 00       	call   800c5f <sys_cputs>
  8000aa:	83 c4 10             	add    $0x10,%esp
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	68 00 02 00 00       	push   $0x200
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 2c 11 00 00       	call   8011e8 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 24 26 80 00       	push   $0x802624
  8000cb:	e8 9d 01 00 00       	call   80026d <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 d4 0f 00 00       	call   8010ac <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 38 26 80 00 	movl   $0x802638,(%esp)
  8000df:	e8 89 01 00 00       	call   80026d <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 4c 26 80 00       	push   $0x80264c
  8000f0:	68 55 26 80 00       	push   $0x802655
  8000f5:	68 5f 26 80 00       	push   $0x80265f
  8000fa:	68 5e 26 80 00       	push   $0x80265e
  8000ff:	e8 9d 1b 00 00       	call   801ca1 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 64 26 80 00       	push   $0x802664
  800111:	6a 1a                	push   $0x1a
  800113:	68 04 26 80 00       	push   $0x802604
  800118:	e8 77 00 00 00       	call   800194 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 7b 26 80 00       	push   $0x80267b
  800125:	e8 43 01 00 00       	call   80026d <cprintf>
}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80013f:	e8 99 0b 00 00       	call   800cdd <sys_getenvid>
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800151:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800156:	85 db                	test   %ebx,%ebx
  800158:	7e 07                	jle    800161 <libmain+0x2d>
		binaryname = argv[0];
  80015a:	8b 06                	mov    (%esi),%eax
  80015c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	e8 c8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80016b:	e8 0a 00 00 00       	call   80017a <exit>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800180:	e8 52 0f 00 00       	call   8010d7 <close_all>
	sys_env_destroy(0);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	6a 00                	push   $0x0
  80018a:	e8 0d 0b 00 00       	call   800c9c <sys_env_destroy>
}
  80018f:	83 c4 10             	add    $0x10,%esp
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800199:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a2:	e8 36 0b 00 00       	call   800cdd <sys_getenvid>
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	ff 75 0c             	pushl  0xc(%ebp)
  8001ad:	ff 75 08             	pushl  0x8(%ebp)
  8001b0:	56                   	push   %esi
  8001b1:	50                   	push   %eax
  8001b2:	68 98 26 80 00       	push   $0x802698
  8001b7:	e8 b1 00 00 00       	call   80026d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 54 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 9e 2b 80 00 	movl   $0x802b9e,(%esp)
  8001cf:	e8 99 00 00 00       	call   80026d <cprintf>
  8001d4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x43>

008001da <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	53                   	push   %ebx
  8001de:	83 ec 04             	sub    $0x4,%esp
  8001e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e4:	8b 13                	mov    (%ebx),%edx
  8001e6:	8d 42 01             	lea    0x1(%edx),%eax
  8001e9:	89 03                	mov    %eax,(%ebx)
  8001eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f7:	75 1a                	jne    800213 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	68 ff 00 00 00       	push   $0xff
  800201:	8d 43 08             	lea    0x8(%ebx),%eax
  800204:	50                   	push   %eax
  800205:	e8 55 0a 00 00       	call   800c5f <sys_cputs>
		b->idx = 0;
  80020a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800210:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800213:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800217:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800225:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022c:	00 00 00 
	b.cnt = 0;
  80022f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800236:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800239:	ff 75 0c             	pushl  0xc(%ebp)
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800245:	50                   	push   %eax
  800246:	68 da 01 80 00       	push   $0x8001da
  80024b:	e8 54 01 00 00       	call   8003a4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800250:	83 c4 08             	add    $0x8,%esp
  800253:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800259:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025f:	50                   	push   %eax
  800260:	e8 fa 09 00 00       	call   800c5f <sys_cputs>

	return b.cnt;
}
  800265:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800273:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 08             	pushl  0x8(%ebp)
  80027a:	e8 9d ff ff ff       	call   80021c <vcprintf>
	va_end(ap);

	return cnt;
}
  80027f:	c9                   	leave  
  800280:	c3                   	ret    

00800281 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	57                   	push   %edi
  800285:	56                   	push   %esi
  800286:	53                   	push   %ebx
  800287:	83 ec 1c             	sub    $0x1c,%esp
  80028a:	89 c7                	mov    %eax,%edi
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	8b 55 0c             	mov    0xc(%ebp),%edx
  800294:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800297:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a8:	39 d3                	cmp    %edx,%ebx
  8002aa:	72 05                	jb     8002b1 <printnum+0x30>
  8002ac:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002af:	77 45                	ja     8002f6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b1:	83 ec 0c             	sub    $0xc,%esp
  8002b4:	ff 75 18             	pushl  0x18(%ebp)
  8002b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ba:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bd:	53                   	push   %ebx
  8002be:	ff 75 10             	pushl  0x10(%ebp)
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d0:	e8 5b 20 00 00       	call   802330 <__udivdi3>
  8002d5:	83 c4 18             	add    $0x18,%esp
  8002d8:	52                   	push   %edx
  8002d9:	50                   	push   %eax
  8002da:	89 f2                	mov    %esi,%edx
  8002dc:	89 f8                	mov    %edi,%eax
  8002de:	e8 9e ff ff ff       	call   800281 <printnum>
  8002e3:	83 c4 20             	add    $0x20,%esp
  8002e6:	eb 18                	jmp    800300 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	56                   	push   %esi
  8002ec:	ff 75 18             	pushl  0x18(%ebp)
  8002ef:	ff d7                	call   *%edi
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	eb 03                	jmp    8002f9 <printnum+0x78>
  8002f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f9:	83 eb 01             	sub    $0x1,%ebx
  8002fc:	85 db                	test   %ebx,%ebx
  8002fe:	7f e8                	jg     8002e8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800300:	83 ec 08             	sub    $0x8,%esp
  800303:	56                   	push   %esi
  800304:	83 ec 04             	sub    $0x4,%esp
  800307:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030a:	ff 75 e0             	pushl  -0x20(%ebp)
  80030d:	ff 75 dc             	pushl  -0x24(%ebp)
  800310:	ff 75 d8             	pushl  -0x28(%ebp)
  800313:	e8 48 21 00 00       	call   802460 <__umoddi3>
  800318:	83 c4 14             	add    $0x14,%esp
  80031b:	0f be 80 bb 26 80 00 	movsbl 0x8026bb(%eax),%eax
  800322:	50                   	push   %eax
  800323:	ff d7                	call   *%edi
}
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032b:	5b                   	pop    %ebx
  80032c:	5e                   	pop    %esi
  80032d:	5f                   	pop    %edi
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    

00800330 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800333:	83 fa 01             	cmp    $0x1,%edx
  800336:	7e 0e                	jle    800346 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033d:	89 08                	mov    %ecx,(%eax)
  80033f:	8b 02                	mov    (%edx),%eax
  800341:	8b 52 04             	mov    0x4(%edx),%edx
  800344:	eb 22                	jmp    800368 <getuint+0x38>
	else if (lflag)
  800346:	85 d2                	test   %edx,%edx
  800348:	74 10                	je     80035a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034f:	89 08                	mov    %ecx,(%eax)
  800351:	8b 02                	mov    (%edx),%eax
  800353:	ba 00 00 00 00       	mov    $0x0,%edx
  800358:	eb 0e                	jmp    800368 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80035a:	8b 10                	mov    (%eax),%edx
  80035c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035f:	89 08                	mov    %ecx,(%eax)
  800361:	8b 02                	mov    (%edx),%eax
  800363:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800370:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800374:	8b 10                	mov    (%eax),%edx
  800376:	3b 50 04             	cmp    0x4(%eax),%edx
  800379:	73 0a                	jae    800385 <sprintputch+0x1b>
		*b->buf++ = ch;
  80037b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 45 08             	mov    0x8(%ebp),%eax
  800383:	88 02                	mov    %al,(%edx)
}
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80038d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800390:	50                   	push   %eax
  800391:	ff 75 10             	pushl  0x10(%ebp)
  800394:	ff 75 0c             	pushl  0xc(%ebp)
  800397:	ff 75 08             	pushl  0x8(%ebp)
  80039a:	e8 05 00 00 00       	call   8003a4 <vprintfmt>
	va_end(ap);
}
  80039f:	83 c4 10             	add    $0x10,%esp
  8003a2:	c9                   	leave  
  8003a3:	c3                   	ret    

008003a4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	57                   	push   %edi
  8003a8:	56                   	push   %esi
  8003a9:	53                   	push   %ebx
  8003aa:	83 ec 2c             	sub    $0x2c,%esp
  8003ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8003b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b6:	eb 12                	jmp    8003ca <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b8:	85 c0                	test   %eax,%eax
  8003ba:	0f 84 38 04 00 00    	je     8007f8 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8003c0:	83 ec 08             	sub    $0x8,%esp
  8003c3:	53                   	push   %ebx
  8003c4:	50                   	push   %eax
  8003c5:	ff d6                	call   *%esi
  8003c7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ca:	83 c7 01             	add    $0x1,%edi
  8003cd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003d1:	83 f8 25             	cmp    $0x25,%eax
  8003d4:	75 e2                	jne    8003b8 <vprintfmt+0x14>
  8003d6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003da:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003e1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f4:	eb 07                	jmp    8003fd <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8d 47 01             	lea    0x1(%edi),%eax
  800400:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800403:	0f b6 07             	movzbl (%edi),%eax
  800406:	0f b6 c8             	movzbl %al,%ecx
  800409:	83 e8 23             	sub    $0x23,%eax
  80040c:	3c 55                	cmp    $0x55,%al
  80040e:	0f 87 c9 03 00 00    	ja     8007dd <vprintfmt+0x439>
  800414:	0f b6 c0             	movzbl %al,%eax
  800417:	ff 24 85 00 28 80 00 	jmp    *0x802800(,%eax,4)
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800421:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800425:	eb d6                	jmp    8003fd <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  800427:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  80042e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  800434:	eb 94                	jmp    8003ca <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  800436:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  80043d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  800443:	eb 85                	jmp    8003ca <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  800445:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  80044c:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  800452:	e9 73 ff ff ff       	jmp    8003ca <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  800457:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  80045e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  800464:	e9 61 ff ff ff       	jmp    8003ca <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  800469:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800470:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  800476:	e9 4f ff ff ff       	jmp    8003ca <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80047b:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800482:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  800488:	e9 3d ff ff ff       	jmp    8003ca <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  80048d:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  800494:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800497:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80049a:	e9 2b ff ff ff       	jmp    8003ca <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  80049f:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  8004a6:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8004ac:	e9 19 ff ff ff       	jmp    8003ca <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  8004b1:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  8004b8:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8004be:	e9 07 ff ff ff       	jmp    8003ca <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8004c3:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  8004ca:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8004d0:	e9 f5 fe ff ff       	jmp    8003ca <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004e3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004e7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004ea:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004ed:	83 fa 09             	cmp    $0x9,%edx
  8004f0:	77 3f                	ja     800531 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f5:	eb e9                	jmp    8004e0 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8d 48 04             	lea    0x4(%eax),%ecx
  8004fd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800500:	8b 00                	mov    (%eax),%eax
  800502:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800505:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800508:	eb 2d                	jmp    800537 <vprintfmt+0x193>
  80050a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050d:	85 c0                	test   %eax,%eax
  80050f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800514:	0f 49 c8             	cmovns %eax,%ecx
  800517:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051d:	e9 db fe ff ff       	jmp    8003fd <vprintfmt+0x59>
  800522:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800525:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80052c:	e9 cc fe ff ff       	jmp    8003fd <vprintfmt+0x59>
  800531:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800534:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800537:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80053b:	0f 89 bc fe ff ff    	jns    8003fd <vprintfmt+0x59>
				width = precision, precision = -1;
  800541:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800544:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800547:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80054e:	e9 aa fe ff ff       	jmp    8003fd <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800553:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800559:	e9 9f fe ff ff       	jmp    8003fd <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 50 04             	lea    0x4(%eax),%edx
  800564:	89 55 14             	mov    %edx,0x14(%ebp)
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	53                   	push   %ebx
  80056b:	ff 30                	pushl  (%eax)
  80056d:	ff d6                	call   *%esi
			break;
  80056f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800575:	e9 50 fe ff ff       	jmp    8003ca <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8d 50 04             	lea    0x4(%eax),%edx
  800580:	89 55 14             	mov    %edx,0x14(%ebp)
  800583:	8b 00                	mov    (%eax),%eax
  800585:	99                   	cltd   
  800586:	31 d0                	xor    %edx,%eax
  800588:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80058a:	83 f8 0f             	cmp    $0xf,%eax
  80058d:	7f 0b                	jg     80059a <vprintfmt+0x1f6>
  80058f:	8b 14 85 60 29 80 00 	mov    0x802960(,%eax,4),%edx
  800596:	85 d2                	test   %edx,%edx
  800598:	75 18                	jne    8005b2 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80059a:	50                   	push   %eax
  80059b:	68 d3 26 80 00       	push   $0x8026d3
  8005a0:	53                   	push   %ebx
  8005a1:	56                   	push   %esi
  8005a2:	e8 e0 fd ff ff       	call   800387 <printfmt>
  8005a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005ad:	e9 18 fe ff ff       	jmp    8003ca <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005b2:	52                   	push   %edx
  8005b3:	68 91 2a 80 00       	push   $0x802a91
  8005b8:	53                   	push   %ebx
  8005b9:	56                   	push   %esi
  8005ba:	e8 c8 fd ff ff       	call   800387 <printfmt>
  8005bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c5:	e9 00 fe ff ff       	jmp    8003ca <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005d5:	85 ff                	test   %edi,%edi
  8005d7:	b8 cc 26 80 00       	mov    $0x8026cc,%eax
  8005dc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e3:	0f 8e 94 00 00 00    	jle    80067d <vprintfmt+0x2d9>
  8005e9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005ed:	0f 84 98 00 00 00    	je     80068b <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f3:	83 ec 08             	sub    $0x8,%esp
  8005f6:	ff 75 d0             	pushl  -0x30(%ebp)
  8005f9:	57                   	push   %edi
  8005fa:	e8 81 02 00 00       	call   800880 <strnlen>
  8005ff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800602:	29 c1                	sub    %eax,%ecx
  800604:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800607:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80060a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80060e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800611:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800614:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800616:	eb 0f                	jmp    800627 <vprintfmt+0x283>
					putch(padc, putdat);
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	53                   	push   %ebx
  80061c:	ff 75 e0             	pushl  -0x20(%ebp)
  80061f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800621:	83 ef 01             	sub    $0x1,%edi
  800624:	83 c4 10             	add    $0x10,%esp
  800627:	85 ff                	test   %edi,%edi
  800629:	7f ed                	jg     800618 <vprintfmt+0x274>
  80062b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80062e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800631:	85 c9                	test   %ecx,%ecx
  800633:	b8 00 00 00 00       	mov    $0x0,%eax
  800638:	0f 49 c1             	cmovns %ecx,%eax
  80063b:	29 c1                	sub    %eax,%ecx
  80063d:	89 75 08             	mov    %esi,0x8(%ebp)
  800640:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800643:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800646:	89 cb                	mov    %ecx,%ebx
  800648:	eb 4d                	jmp    800697 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80064a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064e:	74 1b                	je     80066b <vprintfmt+0x2c7>
  800650:	0f be c0             	movsbl %al,%eax
  800653:	83 e8 20             	sub    $0x20,%eax
  800656:	83 f8 5e             	cmp    $0x5e,%eax
  800659:	76 10                	jbe    80066b <vprintfmt+0x2c7>
					putch('?', putdat);
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	ff 75 0c             	pushl  0xc(%ebp)
  800661:	6a 3f                	push   $0x3f
  800663:	ff 55 08             	call   *0x8(%ebp)
  800666:	83 c4 10             	add    $0x10,%esp
  800669:	eb 0d                	jmp    800678 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	ff 75 0c             	pushl  0xc(%ebp)
  800671:	52                   	push   %edx
  800672:	ff 55 08             	call   *0x8(%ebp)
  800675:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800678:	83 eb 01             	sub    $0x1,%ebx
  80067b:	eb 1a                	jmp    800697 <vprintfmt+0x2f3>
  80067d:	89 75 08             	mov    %esi,0x8(%ebp)
  800680:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800683:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800686:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800689:	eb 0c                	jmp    800697 <vprintfmt+0x2f3>
  80068b:	89 75 08             	mov    %esi,0x8(%ebp)
  80068e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800691:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800694:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800697:	83 c7 01             	add    $0x1,%edi
  80069a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069e:	0f be d0             	movsbl %al,%edx
  8006a1:	85 d2                	test   %edx,%edx
  8006a3:	74 23                	je     8006c8 <vprintfmt+0x324>
  8006a5:	85 f6                	test   %esi,%esi
  8006a7:	78 a1                	js     80064a <vprintfmt+0x2a6>
  8006a9:	83 ee 01             	sub    $0x1,%esi
  8006ac:	79 9c                	jns    80064a <vprintfmt+0x2a6>
  8006ae:	89 df                	mov    %ebx,%edi
  8006b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b6:	eb 18                	jmp    8006d0 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b8:	83 ec 08             	sub    $0x8,%esp
  8006bb:	53                   	push   %ebx
  8006bc:	6a 20                	push   $0x20
  8006be:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c0:	83 ef 01             	sub    $0x1,%edi
  8006c3:	83 c4 10             	add    $0x10,%esp
  8006c6:	eb 08                	jmp    8006d0 <vprintfmt+0x32c>
  8006c8:	89 df                	mov    %ebx,%edi
  8006ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8006cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d0:	85 ff                	test   %edi,%edi
  8006d2:	7f e4                	jg     8006b8 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d7:	e9 ee fc ff ff       	jmp    8003ca <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006dc:	83 fa 01             	cmp    $0x1,%edx
  8006df:	7e 16                	jle    8006f7 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	8d 50 08             	lea    0x8(%eax),%edx
  8006e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ea:	8b 50 04             	mov    0x4(%eax),%edx
  8006ed:	8b 00                	mov    (%eax),%eax
  8006ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f5:	eb 32                	jmp    800729 <vprintfmt+0x385>
	else if (lflag)
  8006f7:	85 d2                	test   %edx,%edx
  8006f9:	74 18                	je     800713 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8006fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fe:	8d 50 04             	lea    0x4(%eax),%edx
  800701:	89 55 14             	mov    %edx,0x14(%ebp)
  800704:	8b 00                	mov    (%eax),%eax
  800706:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800709:	89 c1                	mov    %eax,%ecx
  80070b:	c1 f9 1f             	sar    $0x1f,%ecx
  80070e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800711:	eb 16                	jmp    800729 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	8d 50 04             	lea    0x4(%eax),%edx
  800719:	89 55 14             	mov    %edx,0x14(%ebp)
  80071c:	8b 00                	mov    (%eax),%eax
  80071e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800721:	89 c1                	mov    %eax,%ecx
  800723:	c1 f9 1f             	sar    $0x1f,%ecx
  800726:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800729:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80072c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80072f:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800734:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800738:	79 6f                	jns    8007a9 <vprintfmt+0x405>
				putch('-', putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	53                   	push   %ebx
  80073e:	6a 2d                	push   $0x2d
  800740:	ff d6                	call   *%esi
				num = -(long long) num;
  800742:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800745:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800748:	f7 d8                	neg    %eax
  80074a:	83 d2 00             	adc    $0x0,%edx
  80074d:	f7 da                	neg    %edx
  80074f:	83 c4 10             	add    $0x10,%esp
  800752:	eb 55                	jmp    8007a9 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800754:	8d 45 14             	lea    0x14(%ebp),%eax
  800757:	e8 d4 fb ff ff       	call   800330 <getuint>
			base = 10;
  80075c:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800761:	eb 46                	jmp    8007a9 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800763:	8d 45 14             	lea    0x14(%ebp),%eax
  800766:	e8 c5 fb ff ff       	call   800330 <getuint>
			base = 8;
  80076b:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800770:	eb 37                	jmp    8007a9 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800772:	83 ec 08             	sub    $0x8,%esp
  800775:	53                   	push   %ebx
  800776:	6a 30                	push   $0x30
  800778:	ff d6                	call   *%esi
			putch('x', putdat);
  80077a:	83 c4 08             	add    $0x8,%esp
  80077d:	53                   	push   %ebx
  80077e:	6a 78                	push   $0x78
  800780:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800782:	8b 45 14             	mov    0x14(%ebp),%eax
  800785:	8d 50 04             	lea    0x4(%eax),%edx
  800788:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80078b:	8b 00                	mov    (%eax),%eax
  80078d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800792:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800795:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80079a:	eb 0d                	jmp    8007a9 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80079c:	8d 45 14             	lea    0x14(%ebp),%eax
  80079f:	e8 8c fb ff ff       	call   800330 <getuint>
			base = 16;
  8007a4:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a9:	83 ec 0c             	sub    $0xc,%esp
  8007ac:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8007b0:	51                   	push   %ecx
  8007b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8007b4:	57                   	push   %edi
  8007b5:	52                   	push   %edx
  8007b6:	50                   	push   %eax
  8007b7:	89 da                	mov    %ebx,%edx
  8007b9:	89 f0                	mov    %esi,%eax
  8007bb:	e8 c1 fa ff ff       	call   800281 <printnum>
			break;
  8007c0:	83 c4 20             	add    $0x20,%esp
  8007c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c6:	e9 ff fb ff ff       	jmp    8003ca <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	53                   	push   %ebx
  8007cf:	51                   	push   %ecx
  8007d0:	ff d6                	call   *%esi
			break;
  8007d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d8:	e9 ed fb ff ff       	jmp    8003ca <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007dd:	83 ec 08             	sub    $0x8,%esp
  8007e0:	53                   	push   %ebx
  8007e1:	6a 25                	push   $0x25
  8007e3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	eb 03                	jmp    8007ed <vprintfmt+0x449>
  8007ea:	83 ef 01             	sub    $0x1,%edi
  8007ed:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007f1:	75 f7                	jne    8007ea <vprintfmt+0x446>
  8007f3:	e9 d2 fb ff ff       	jmp    8003ca <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007fb:	5b                   	pop    %ebx
  8007fc:	5e                   	pop    %esi
  8007fd:	5f                   	pop    %edi
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	83 ec 18             	sub    $0x18,%esp
  800806:	8b 45 08             	mov    0x8(%ebp),%eax
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800813:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800816:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081d:	85 c0                	test   %eax,%eax
  80081f:	74 26                	je     800847 <vsnprintf+0x47>
  800821:	85 d2                	test   %edx,%edx
  800823:	7e 22                	jle    800847 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800825:	ff 75 14             	pushl  0x14(%ebp)
  800828:	ff 75 10             	pushl  0x10(%ebp)
  80082b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082e:	50                   	push   %eax
  80082f:	68 6a 03 80 00       	push   $0x80036a
  800834:	e8 6b fb ff ff       	call   8003a4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800839:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800842:	83 c4 10             	add    $0x10,%esp
  800845:	eb 05                	jmp    80084c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800847:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80084c:	c9                   	leave  
  80084d:	c3                   	ret    

0080084e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800854:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800857:	50                   	push   %eax
  800858:	ff 75 10             	pushl  0x10(%ebp)
  80085b:	ff 75 0c             	pushl  0xc(%ebp)
  80085e:	ff 75 08             	pushl  0x8(%ebp)
  800861:	e8 9a ff ff ff       	call   800800 <vsnprintf>
	va_end(ap);

	return rc;
}
  800866:	c9                   	leave  
  800867:	c3                   	ret    

00800868 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80086e:	b8 00 00 00 00       	mov    $0x0,%eax
  800873:	eb 03                	jmp    800878 <strlen+0x10>
		n++;
  800875:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800878:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80087c:	75 f7                	jne    800875 <strlen+0xd>
		n++;
	return n;
}
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800886:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800889:	ba 00 00 00 00       	mov    $0x0,%edx
  80088e:	eb 03                	jmp    800893 <strnlen+0x13>
		n++;
  800890:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800893:	39 c2                	cmp    %eax,%edx
  800895:	74 08                	je     80089f <strnlen+0x1f>
  800897:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80089b:	75 f3                	jne    800890 <strnlen+0x10>
  80089d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	53                   	push   %ebx
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ab:	89 c2                	mov    %eax,%edx
  8008ad:	83 c2 01             	add    $0x1,%edx
  8008b0:	83 c1 01             	add    $0x1,%ecx
  8008b3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008b7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ba:	84 db                	test   %bl,%bl
  8008bc:	75 ef                	jne    8008ad <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008be:	5b                   	pop    %ebx
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	53                   	push   %ebx
  8008c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c8:	53                   	push   %ebx
  8008c9:	e8 9a ff ff ff       	call   800868 <strlen>
  8008ce:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008d1:	ff 75 0c             	pushl  0xc(%ebp)
  8008d4:	01 d8                	add    %ebx,%eax
  8008d6:	50                   	push   %eax
  8008d7:	e8 c5 ff ff ff       	call   8008a1 <strcpy>
	return dst;
}
  8008dc:	89 d8                	mov    %ebx,%eax
  8008de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e1:	c9                   	leave  
  8008e2:	c3                   	ret    

008008e3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	56                   	push   %esi
  8008e7:	53                   	push   %ebx
  8008e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ee:	89 f3                	mov    %esi,%ebx
  8008f0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f3:	89 f2                	mov    %esi,%edx
  8008f5:	eb 0f                	jmp    800906 <strncpy+0x23>
		*dst++ = *src;
  8008f7:	83 c2 01             	add    $0x1,%edx
  8008fa:	0f b6 01             	movzbl (%ecx),%eax
  8008fd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800900:	80 39 01             	cmpb   $0x1,(%ecx)
  800903:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800906:	39 da                	cmp    %ebx,%edx
  800908:	75 ed                	jne    8008f7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80090a:	89 f0                	mov    %esi,%eax
  80090c:	5b                   	pop    %ebx
  80090d:	5e                   	pop    %esi
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	56                   	push   %esi
  800914:	53                   	push   %ebx
  800915:	8b 75 08             	mov    0x8(%ebp),%esi
  800918:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091b:	8b 55 10             	mov    0x10(%ebp),%edx
  80091e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800920:	85 d2                	test   %edx,%edx
  800922:	74 21                	je     800945 <strlcpy+0x35>
  800924:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800928:	89 f2                	mov    %esi,%edx
  80092a:	eb 09                	jmp    800935 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80092c:	83 c2 01             	add    $0x1,%edx
  80092f:	83 c1 01             	add    $0x1,%ecx
  800932:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800935:	39 c2                	cmp    %eax,%edx
  800937:	74 09                	je     800942 <strlcpy+0x32>
  800939:	0f b6 19             	movzbl (%ecx),%ebx
  80093c:	84 db                	test   %bl,%bl
  80093e:	75 ec                	jne    80092c <strlcpy+0x1c>
  800940:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800942:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800945:	29 f0                	sub    %esi,%eax
}
  800947:	5b                   	pop    %ebx
  800948:	5e                   	pop    %esi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800951:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800954:	eb 06                	jmp    80095c <strcmp+0x11>
		p++, q++;
  800956:	83 c1 01             	add    $0x1,%ecx
  800959:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80095c:	0f b6 01             	movzbl (%ecx),%eax
  80095f:	84 c0                	test   %al,%al
  800961:	74 04                	je     800967 <strcmp+0x1c>
  800963:	3a 02                	cmp    (%edx),%al
  800965:	74 ef                	je     800956 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800967:	0f b6 c0             	movzbl %al,%eax
  80096a:	0f b6 12             	movzbl (%edx),%edx
  80096d:	29 d0                	sub    %edx,%eax
}
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	53                   	push   %ebx
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097b:	89 c3                	mov    %eax,%ebx
  80097d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800980:	eb 06                	jmp    800988 <strncmp+0x17>
		n--, p++, q++;
  800982:	83 c0 01             	add    $0x1,%eax
  800985:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800988:	39 d8                	cmp    %ebx,%eax
  80098a:	74 15                	je     8009a1 <strncmp+0x30>
  80098c:	0f b6 08             	movzbl (%eax),%ecx
  80098f:	84 c9                	test   %cl,%cl
  800991:	74 04                	je     800997 <strncmp+0x26>
  800993:	3a 0a                	cmp    (%edx),%cl
  800995:	74 eb                	je     800982 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800997:	0f b6 00             	movzbl (%eax),%eax
  80099a:	0f b6 12             	movzbl (%edx),%edx
  80099d:	29 d0                	sub    %edx,%eax
  80099f:	eb 05                	jmp    8009a6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a6:	5b                   	pop    %ebx
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b3:	eb 07                	jmp    8009bc <strchr+0x13>
		if (*s == c)
  8009b5:	38 ca                	cmp    %cl,%dl
  8009b7:	74 0f                	je     8009c8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009b9:	83 c0 01             	add    $0x1,%eax
  8009bc:	0f b6 10             	movzbl (%eax),%edx
  8009bf:	84 d2                	test   %dl,%dl
  8009c1:	75 f2                	jne    8009b5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d4:	eb 03                	jmp    8009d9 <strfind+0xf>
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009dc:	38 ca                	cmp    %cl,%dl
  8009de:	74 04                	je     8009e4 <strfind+0x1a>
  8009e0:	84 d2                	test   %dl,%dl
  8009e2:	75 f2                	jne    8009d6 <strfind+0xc>
			break;
	return (char *) s;
}
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	57                   	push   %edi
  8009ea:	56                   	push   %esi
  8009eb:	53                   	push   %ebx
  8009ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f2:	85 c9                	test   %ecx,%ecx
  8009f4:	74 36                	je     800a2c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fc:	75 28                	jne    800a26 <memset+0x40>
  8009fe:	f6 c1 03             	test   $0x3,%cl
  800a01:	75 23                	jne    800a26 <memset+0x40>
		c &= 0xFF;
  800a03:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a07:	89 d3                	mov    %edx,%ebx
  800a09:	c1 e3 08             	shl    $0x8,%ebx
  800a0c:	89 d6                	mov    %edx,%esi
  800a0e:	c1 e6 18             	shl    $0x18,%esi
  800a11:	89 d0                	mov    %edx,%eax
  800a13:	c1 e0 10             	shl    $0x10,%eax
  800a16:	09 f0                	or     %esi,%eax
  800a18:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a1a:	89 d8                	mov    %ebx,%eax
  800a1c:	09 d0                	or     %edx,%eax
  800a1e:	c1 e9 02             	shr    $0x2,%ecx
  800a21:	fc                   	cld    
  800a22:	f3 ab                	rep stos %eax,%es:(%edi)
  800a24:	eb 06                	jmp    800a2c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a29:	fc                   	cld    
  800a2a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2c:	89 f8                	mov    %edi,%eax
  800a2e:	5b                   	pop    %ebx
  800a2f:	5e                   	pop    %esi
  800a30:	5f                   	pop    %edi
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	57                   	push   %edi
  800a37:	56                   	push   %esi
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a41:	39 c6                	cmp    %eax,%esi
  800a43:	73 35                	jae    800a7a <memmove+0x47>
  800a45:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a48:	39 d0                	cmp    %edx,%eax
  800a4a:	73 2e                	jae    800a7a <memmove+0x47>
		s += n;
		d += n;
  800a4c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4f:	89 d6                	mov    %edx,%esi
  800a51:	09 fe                	or     %edi,%esi
  800a53:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a59:	75 13                	jne    800a6e <memmove+0x3b>
  800a5b:	f6 c1 03             	test   $0x3,%cl
  800a5e:	75 0e                	jne    800a6e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a60:	83 ef 04             	sub    $0x4,%edi
  800a63:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a66:	c1 e9 02             	shr    $0x2,%ecx
  800a69:	fd                   	std    
  800a6a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6c:	eb 09                	jmp    800a77 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a6e:	83 ef 01             	sub    $0x1,%edi
  800a71:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a74:	fd                   	std    
  800a75:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a77:	fc                   	cld    
  800a78:	eb 1d                	jmp    800a97 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7a:	89 f2                	mov    %esi,%edx
  800a7c:	09 c2                	or     %eax,%edx
  800a7e:	f6 c2 03             	test   $0x3,%dl
  800a81:	75 0f                	jne    800a92 <memmove+0x5f>
  800a83:	f6 c1 03             	test   $0x3,%cl
  800a86:	75 0a                	jne    800a92 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a88:	c1 e9 02             	shr    $0x2,%ecx
  800a8b:	89 c7                	mov    %eax,%edi
  800a8d:	fc                   	cld    
  800a8e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a90:	eb 05                	jmp    800a97 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a92:	89 c7                	mov    %eax,%edi
  800a94:	fc                   	cld    
  800a95:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a9e:	ff 75 10             	pushl  0x10(%ebp)
  800aa1:	ff 75 0c             	pushl  0xc(%ebp)
  800aa4:	ff 75 08             	pushl  0x8(%ebp)
  800aa7:	e8 87 ff ff ff       	call   800a33 <memmove>
}
  800aac:	c9                   	leave  
  800aad:	c3                   	ret    

00800aae <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	56                   	push   %esi
  800ab2:	53                   	push   %ebx
  800ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab9:	89 c6                	mov    %eax,%esi
  800abb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abe:	eb 1a                	jmp    800ada <memcmp+0x2c>
		if (*s1 != *s2)
  800ac0:	0f b6 08             	movzbl (%eax),%ecx
  800ac3:	0f b6 1a             	movzbl (%edx),%ebx
  800ac6:	38 d9                	cmp    %bl,%cl
  800ac8:	74 0a                	je     800ad4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aca:	0f b6 c1             	movzbl %cl,%eax
  800acd:	0f b6 db             	movzbl %bl,%ebx
  800ad0:	29 d8                	sub    %ebx,%eax
  800ad2:	eb 0f                	jmp    800ae3 <memcmp+0x35>
		s1++, s2++;
  800ad4:	83 c0 01             	add    $0x1,%eax
  800ad7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ada:	39 f0                	cmp    %esi,%eax
  800adc:	75 e2                	jne    800ac0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	53                   	push   %ebx
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aee:	89 c1                	mov    %eax,%ecx
  800af0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800af3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af7:	eb 0a                	jmp    800b03 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af9:	0f b6 10             	movzbl (%eax),%edx
  800afc:	39 da                	cmp    %ebx,%edx
  800afe:	74 07                	je     800b07 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b00:	83 c0 01             	add    $0x1,%eax
  800b03:	39 c8                	cmp    %ecx,%eax
  800b05:	72 f2                	jb     800af9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b07:	5b                   	pop    %ebx
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
  800b10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b16:	eb 03                	jmp    800b1b <strtol+0x11>
		s++;
  800b18:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1b:	0f b6 01             	movzbl (%ecx),%eax
  800b1e:	3c 20                	cmp    $0x20,%al
  800b20:	74 f6                	je     800b18 <strtol+0xe>
  800b22:	3c 09                	cmp    $0x9,%al
  800b24:	74 f2                	je     800b18 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b26:	3c 2b                	cmp    $0x2b,%al
  800b28:	75 0a                	jne    800b34 <strtol+0x2a>
		s++;
  800b2a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b2d:	bf 00 00 00 00       	mov    $0x0,%edi
  800b32:	eb 11                	jmp    800b45 <strtol+0x3b>
  800b34:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b39:	3c 2d                	cmp    $0x2d,%al
  800b3b:	75 08                	jne    800b45 <strtol+0x3b>
		s++, neg = 1;
  800b3d:	83 c1 01             	add    $0x1,%ecx
  800b40:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b45:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b4b:	75 15                	jne    800b62 <strtol+0x58>
  800b4d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b50:	75 10                	jne    800b62 <strtol+0x58>
  800b52:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b56:	75 7c                	jne    800bd4 <strtol+0xca>
		s += 2, base = 16;
  800b58:	83 c1 02             	add    $0x2,%ecx
  800b5b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b60:	eb 16                	jmp    800b78 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b62:	85 db                	test   %ebx,%ebx
  800b64:	75 12                	jne    800b78 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b66:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6e:	75 08                	jne    800b78 <strtol+0x6e>
		s++, base = 8;
  800b70:	83 c1 01             	add    $0x1,%ecx
  800b73:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b78:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b80:	0f b6 11             	movzbl (%ecx),%edx
  800b83:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b86:	89 f3                	mov    %esi,%ebx
  800b88:	80 fb 09             	cmp    $0x9,%bl
  800b8b:	77 08                	ja     800b95 <strtol+0x8b>
			dig = *s - '0';
  800b8d:	0f be d2             	movsbl %dl,%edx
  800b90:	83 ea 30             	sub    $0x30,%edx
  800b93:	eb 22                	jmp    800bb7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b95:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b98:	89 f3                	mov    %esi,%ebx
  800b9a:	80 fb 19             	cmp    $0x19,%bl
  800b9d:	77 08                	ja     800ba7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b9f:	0f be d2             	movsbl %dl,%edx
  800ba2:	83 ea 57             	sub    $0x57,%edx
  800ba5:	eb 10                	jmp    800bb7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ba7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800baa:	89 f3                	mov    %esi,%ebx
  800bac:	80 fb 19             	cmp    $0x19,%bl
  800baf:	77 16                	ja     800bc7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bb1:	0f be d2             	movsbl %dl,%edx
  800bb4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bb7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bba:	7d 0b                	jge    800bc7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bbc:	83 c1 01             	add    $0x1,%ecx
  800bbf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bc5:	eb b9                	jmp    800b80 <strtol+0x76>

	if (endptr)
  800bc7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bcb:	74 0d                	je     800bda <strtol+0xd0>
		*endptr = (char *) s;
  800bcd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd0:	89 0e                	mov    %ecx,(%esi)
  800bd2:	eb 06                	jmp    800bda <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd4:	85 db                	test   %ebx,%ebx
  800bd6:	74 98                	je     800b70 <strtol+0x66>
  800bd8:	eb 9e                	jmp    800b78 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bda:	89 c2                	mov    %eax,%edx
  800bdc:	f7 da                	neg    %edx
  800bde:	85 ff                	test   %edi,%edi
  800be0:	0f 45 c2             	cmovne %edx,%eax
}
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5f                   	pop    %edi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	83 ec 04             	sub    $0x4,%esp
  800bf1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800bf4:	57                   	push   %edi
  800bf5:	e8 6e fc ff ff       	call   800868 <strlen>
  800bfa:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800bfd:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800c00:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800c05:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800c0a:	eb 46                	jmp    800c52 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800c0c:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800c10:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800c13:	80 f9 09             	cmp    $0x9,%cl
  800c16:	77 08                	ja     800c20 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800c18:	0f be d2             	movsbl %dl,%edx
  800c1b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800c1e:	eb 27                	jmp    800c47 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800c20:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800c23:	80 f9 05             	cmp    $0x5,%cl
  800c26:	77 08                	ja     800c30 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800c28:	0f be d2             	movsbl %dl,%edx
  800c2b:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800c2e:	eb 17                	jmp    800c47 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800c30:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800c33:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800c36:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800c3b:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800c3f:	77 06                	ja     800c47 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800c41:	0f be d2             	movsbl %dl,%edx
  800c44:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800c47:	0f af ce             	imul   %esi,%ecx
  800c4a:	01 c8                	add    %ecx,%eax
		base *= 16;
  800c4c:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800c4f:	83 eb 01             	sub    $0x1,%ebx
  800c52:	83 fb 01             	cmp    $0x1,%ebx
  800c55:	7f b5                	jg     800c0c <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800c57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c65:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	89 c3                	mov    %eax,%ebx
  800c72:	89 c7                	mov    %eax,%edi
  800c74:	89 c6                	mov    %eax,%esi
  800c76:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_cgetc>:

int
sys_cgetc(void)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	ba 00 00 00 00       	mov    $0x0,%edx
  800c88:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8d:	89 d1                	mov    %edx,%ecx
  800c8f:	89 d3                	mov    %edx,%ebx
  800c91:	89 d7                	mov    %edx,%edi
  800c93:	89 d6                	mov    %edx,%esi
  800c95:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800caa:	b8 03 00 00 00       	mov    $0x3,%eax
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	89 cb                	mov    %ecx,%ebx
  800cb4:	89 cf                	mov    %ecx,%edi
  800cb6:	89 ce                	mov    %ecx,%esi
  800cb8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	7e 17                	jle    800cd5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbe:	83 ec 0c             	sub    $0xc,%esp
  800cc1:	50                   	push   %eax
  800cc2:	6a 03                	push   $0x3
  800cc4:	68 bf 29 80 00       	push   $0x8029bf
  800cc9:	6a 23                	push   $0x23
  800ccb:	68 dc 29 80 00       	push   $0x8029dc
  800cd0:	e8 bf f4 ff ff       	call   800194 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce8:	b8 02 00 00 00       	mov    $0x2,%eax
  800ced:	89 d1                	mov    %edx,%ecx
  800cef:	89 d3                	mov    %edx,%ebx
  800cf1:	89 d7                	mov    %edx,%edi
  800cf3:	89 d6                	mov    %edx,%esi
  800cf5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_yield>:

void
sys_yield(void)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	ba 00 00 00 00       	mov    $0x0,%edx
  800d07:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d0c:	89 d1                	mov    %edx,%ecx
  800d0e:	89 d3                	mov    %edx,%ebx
  800d10:	89 d7                	mov    %edx,%edi
  800d12:	89 d6                	mov    %edx,%esi
  800d14:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	be 00 00 00 00       	mov    $0x0,%esi
  800d29:	b8 04 00 00 00       	mov    $0x4,%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
  800d34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d37:	89 f7                	mov    %esi,%edi
  800d39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7e 17                	jle    800d56 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	50                   	push   %eax
  800d43:	6a 04                	push   $0x4
  800d45:	68 bf 29 80 00       	push   $0x8029bf
  800d4a:	6a 23                	push   $0x23
  800d4c:	68 dc 29 80 00       	push   $0x8029dc
  800d51:	e8 3e f4 ff ff       	call   800194 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	b8 05 00 00 00       	mov    $0x5,%eax
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d75:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d78:	8b 75 18             	mov    0x18(%ebp),%esi
  800d7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 17                	jle    800d98 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 05                	push   $0x5
  800d87:	68 bf 29 80 00       	push   $0x8029bf
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 dc 29 80 00       	push   $0x8029dc
  800d93:	e8 fc f3 ff ff       	call   800194 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dae:	b8 06 00 00 00       	mov    $0x6,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 de                	mov    %ebx,%esi
  800dbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 17                	jle    800dda <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	50                   	push   %eax
  800dc7:	6a 06                	push   $0x6
  800dc9:	68 bf 29 80 00       	push   $0x8029bf
  800dce:	6a 23                	push   $0x23
  800dd0:	68 dc 29 80 00       	push   $0x8029dc
  800dd5:	e8 ba f3 ff ff       	call   800194 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df0:	b8 08 00 00 00       	mov    $0x8,%eax
  800df5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	89 df                	mov    %ebx,%edi
  800dfd:	89 de                	mov    %ebx,%esi
  800dff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e01:	85 c0                	test   %eax,%eax
  800e03:	7e 17                	jle    800e1c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e05:	83 ec 0c             	sub    $0xc,%esp
  800e08:	50                   	push   %eax
  800e09:	6a 08                	push   $0x8
  800e0b:	68 bf 29 80 00       	push   $0x8029bf
  800e10:	6a 23                	push   $0x23
  800e12:	68 dc 29 80 00       	push   $0x8029dc
  800e17:	e8 78 f3 ff ff       	call   800194 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	53                   	push   %ebx
  800e2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e32:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3d:	89 df                	mov    %ebx,%edi
  800e3f:	89 de                	mov    %ebx,%esi
  800e41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e43:	85 c0                	test   %eax,%eax
  800e45:	7e 17                	jle    800e5e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e47:	83 ec 0c             	sub    $0xc,%esp
  800e4a:	50                   	push   %eax
  800e4b:	6a 0a                	push   $0xa
  800e4d:	68 bf 29 80 00       	push   $0x8029bf
  800e52:	6a 23                	push   $0x23
  800e54:	68 dc 29 80 00       	push   $0x8029dc
  800e59:	e8 36 f3 ff ff       	call   800194 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e61:	5b                   	pop    %ebx
  800e62:	5e                   	pop    %esi
  800e63:	5f                   	pop    %edi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	57                   	push   %edi
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
  800e6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e74:	b8 09 00 00 00       	mov    $0x9,%eax
  800e79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7f:	89 df                	mov    %ebx,%edi
  800e81:	89 de                	mov    %ebx,%esi
  800e83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e85:	85 c0                	test   %eax,%eax
  800e87:	7e 17                	jle    800ea0 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e89:	83 ec 0c             	sub    $0xc,%esp
  800e8c:	50                   	push   %eax
  800e8d:	6a 09                	push   $0x9
  800e8f:	68 bf 29 80 00       	push   $0x8029bf
  800e94:	6a 23                	push   $0x23
  800e96:	68 dc 29 80 00       	push   $0x8029dc
  800e9b:	e8 f4 f2 ff ff       	call   800194 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ea0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	57                   	push   %edi
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eae:	be 00 00 00 00       	mov    $0x0,%esi
  800eb3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	57                   	push   %edi
  800ecf:	56                   	push   %esi
  800ed0:	53                   	push   %ebx
  800ed1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ede:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee1:	89 cb                	mov    %ecx,%ebx
  800ee3:	89 cf                	mov    %ecx,%edi
  800ee5:	89 ce                	mov    %ecx,%esi
  800ee7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	7e 17                	jle    800f04 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eed:	83 ec 0c             	sub    $0xc,%esp
  800ef0:	50                   	push   %eax
  800ef1:	6a 0d                	push   $0xd
  800ef3:	68 bf 29 80 00       	push   $0x8029bf
  800ef8:	6a 23                	push   $0x23
  800efa:	68 dc 29 80 00       	push   $0x8029dc
  800eff:	e8 90 f2 ff ff       	call   800194 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f07:	5b                   	pop    %ebx
  800f08:	5e                   	pop    %esi
  800f09:	5f                   	pop    %edi
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f12:	05 00 00 00 30       	add    $0x30000000,%eax
  800f17:	c1 e8 0c             	shr    $0xc,%eax
}
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f22:	05 00 00 00 30       	add    $0x30000000,%eax
  800f27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f2c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    

00800f33 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f39:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f3e:	89 c2                	mov    %eax,%edx
  800f40:	c1 ea 16             	shr    $0x16,%edx
  800f43:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f4a:	f6 c2 01             	test   $0x1,%dl
  800f4d:	74 11                	je     800f60 <fd_alloc+0x2d>
  800f4f:	89 c2                	mov    %eax,%edx
  800f51:	c1 ea 0c             	shr    $0xc,%edx
  800f54:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f5b:	f6 c2 01             	test   $0x1,%dl
  800f5e:	75 09                	jne    800f69 <fd_alloc+0x36>
			*fd_store = fd;
  800f60:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f62:	b8 00 00 00 00       	mov    $0x0,%eax
  800f67:	eb 17                	jmp    800f80 <fd_alloc+0x4d>
  800f69:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f6e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f73:	75 c9                	jne    800f3e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f75:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f7b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    

00800f82 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f88:	83 f8 1f             	cmp    $0x1f,%eax
  800f8b:	77 36                	ja     800fc3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f8d:	c1 e0 0c             	shl    $0xc,%eax
  800f90:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f95:	89 c2                	mov    %eax,%edx
  800f97:	c1 ea 16             	shr    $0x16,%edx
  800f9a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fa1:	f6 c2 01             	test   $0x1,%dl
  800fa4:	74 24                	je     800fca <fd_lookup+0x48>
  800fa6:	89 c2                	mov    %eax,%edx
  800fa8:	c1 ea 0c             	shr    $0xc,%edx
  800fab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fb2:	f6 c2 01             	test   $0x1,%dl
  800fb5:	74 1a                	je     800fd1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fba:	89 02                	mov    %eax,(%edx)
	return 0;
  800fbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc1:	eb 13                	jmp    800fd6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fc3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fc8:	eb 0c                	jmp    800fd6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fcf:	eb 05                	jmp    800fd6 <fd_lookup+0x54>
  800fd1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 08             	sub    $0x8,%esp
  800fde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe1:	ba 68 2a 80 00       	mov    $0x802a68,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fe6:	eb 13                	jmp    800ffb <dev_lookup+0x23>
  800fe8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800feb:	39 08                	cmp    %ecx,(%eax)
  800fed:	75 0c                	jne    800ffb <dev_lookup+0x23>
			*dev = devtab[i];
  800fef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff2:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ff4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff9:	eb 2e                	jmp    801029 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ffb:	8b 02                	mov    (%edx),%eax
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	75 e7                	jne    800fe8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801001:	a1 08 40 80 00       	mov    0x804008,%eax
  801006:	8b 40 48             	mov    0x48(%eax),%eax
  801009:	83 ec 04             	sub    $0x4,%esp
  80100c:	51                   	push   %ecx
  80100d:	50                   	push   %eax
  80100e:	68 ec 29 80 00       	push   $0x8029ec
  801013:	e8 55 f2 ff ff       	call   80026d <cprintf>
	*dev = 0;
  801018:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801029:	c9                   	leave  
  80102a:	c3                   	ret    

0080102b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	56                   	push   %esi
  80102f:	53                   	push   %ebx
  801030:	83 ec 10             	sub    $0x10,%esp
  801033:	8b 75 08             	mov    0x8(%ebp),%esi
  801036:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801039:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103c:	50                   	push   %eax
  80103d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801043:	c1 e8 0c             	shr    $0xc,%eax
  801046:	50                   	push   %eax
  801047:	e8 36 ff ff ff       	call   800f82 <fd_lookup>
  80104c:	83 c4 08             	add    $0x8,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	78 05                	js     801058 <fd_close+0x2d>
	    || fd != fd2) 
  801053:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801056:	74 0c                	je     801064 <fd_close+0x39>
		return (must_exist ? r : 0); 
  801058:	84 db                	test   %bl,%bl
  80105a:	ba 00 00 00 00       	mov    $0x0,%edx
  80105f:	0f 44 c2             	cmove  %edx,%eax
  801062:	eb 41                	jmp    8010a5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801064:	83 ec 08             	sub    $0x8,%esp
  801067:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80106a:	50                   	push   %eax
  80106b:	ff 36                	pushl  (%esi)
  80106d:	e8 66 ff ff ff       	call   800fd8 <dev_lookup>
  801072:	89 c3                	mov    %eax,%ebx
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	85 c0                	test   %eax,%eax
  801079:	78 1a                	js     801095 <fd_close+0x6a>
		if (dev->dev_close) 
  80107b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80107e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  801081:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  801086:	85 c0                	test   %eax,%eax
  801088:	74 0b                	je     801095 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	56                   	push   %esi
  80108e:	ff d0                	call   *%eax
  801090:	89 c3                	mov    %eax,%ebx
  801092:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801095:	83 ec 08             	sub    $0x8,%esp
  801098:	56                   	push   %esi
  801099:	6a 00                	push   $0x0
  80109b:	e8 00 fd ff ff       	call   800da0 <sys_page_unmap>
	return r;
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	89 d8                	mov    %ebx,%eax
}
  8010a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010a8:	5b                   	pop    %ebx
  8010a9:	5e                   	pop    %esi
  8010aa:	5d                   	pop    %ebp
  8010ab:	c3                   	ret    

008010ac <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b5:	50                   	push   %eax
  8010b6:	ff 75 08             	pushl  0x8(%ebp)
  8010b9:	e8 c4 fe ff ff       	call   800f82 <fd_lookup>
  8010be:	83 c4 08             	add    $0x8,%esp
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	78 10                	js     8010d5 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  8010c5:	83 ec 08             	sub    $0x8,%esp
  8010c8:	6a 01                	push   $0x1
  8010ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8010cd:	e8 59 ff ff ff       	call   80102b <fd_close>
  8010d2:	83 c4 10             	add    $0x10,%esp
}
  8010d5:	c9                   	leave  
  8010d6:	c3                   	ret    

008010d7 <close_all>:

void
close_all(void)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	53                   	push   %ebx
  8010db:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010de:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010e3:	83 ec 0c             	sub    $0xc,%esp
  8010e6:	53                   	push   %ebx
  8010e7:	e8 c0 ff ff ff       	call   8010ac <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ec:	83 c3 01             	add    $0x1,%ebx
  8010ef:	83 c4 10             	add    $0x10,%esp
  8010f2:	83 fb 20             	cmp    $0x20,%ebx
  8010f5:	75 ec                	jne    8010e3 <close_all+0xc>
		close(i);
}
  8010f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010fa:	c9                   	leave  
  8010fb:	c3                   	ret    

008010fc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	57                   	push   %edi
  801100:	56                   	push   %esi
  801101:	53                   	push   %ebx
  801102:	83 ec 2c             	sub    $0x2c,%esp
  801105:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801108:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80110b:	50                   	push   %eax
  80110c:	ff 75 08             	pushl  0x8(%ebp)
  80110f:	e8 6e fe ff ff       	call   800f82 <fd_lookup>
  801114:	83 c4 08             	add    $0x8,%esp
  801117:	85 c0                	test   %eax,%eax
  801119:	0f 88 c1 00 00 00    	js     8011e0 <dup+0xe4>
		return r;
	close(newfdnum);
  80111f:	83 ec 0c             	sub    $0xc,%esp
  801122:	56                   	push   %esi
  801123:	e8 84 ff ff ff       	call   8010ac <close>

	newfd = INDEX2FD(newfdnum);
  801128:	89 f3                	mov    %esi,%ebx
  80112a:	c1 e3 0c             	shl    $0xc,%ebx
  80112d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801133:	83 c4 04             	add    $0x4,%esp
  801136:	ff 75 e4             	pushl  -0x1c(%ebp)
  801139:	e8 de fd ff ff       	call   800f1c <fd2data>
  80113e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801140:	89 1c 24             	mov    %ebx,(%esp)
  801143:	e8 d4 fd ff ff       	call   800f1c <fd2data>
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80114e:	89 f8                	mov    %edi,%eax
  801150:	c1 e8 16             	shr    $0x16,%eax
  801153:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80115a:	a8 01                	test   $0x1,%al
  80115c:	74 37                	je     801195 <dup+0x99>
  80115e:	89 f8                	mov    %edi,%eax
  801160:	c1 e8 0c             	shr    $0xc,%eax
  801163:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80116a:	f6 c2 01             	test   $0x1,%dl
  80116d:	74 26                	je     801195 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80116f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801176:	83 ec 0c             	sub    $0xc,%esp
  801179:	25 07 0e 00 00       	and    $0xe07,%eax
  80117e:	50                   	push   %eax
  80117f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801182:	6a 00                	push   $0x0
  801184:	57                   	push   %edi
  801185:	6a 00                	push   $0x0
  801187:	e8 d2 fb ff ff       	call   800d5e <sys_page_map>
  80118c:	89 c7                	mov    %eax,%edi
  80118e:	83 c4 20             	add    $0x20,%esp
  801191:	85 c0                	test   %eax,%eax
  801193:	78 2e                	js     8011c3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801195:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801198:	89 d0                	mov    %edx,%eax
  80119a:	c1 e8 0c             	shr    $0xc,%eax
  80119d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011a4:	83 ec 0c             	sub    $0xc,%esp
  8011a7:	25 07 0e 00 00       	and    $0xe07,%eax
  8011ac:	50                   	push   %eax
  8011ad:	53                   	push   %ebx
  8011ae:	6a 00                	push   $0x0
  8011b0:	52                   	push   %edx
  8011b1:	6a 00                	push   $0x0
  8011b3:	e8 a6 fb ff ff       	call   800d5e <sys_page_map>
  8011b8:	89 c7                	mov    %eax,%edi
  8011ba:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011bd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011bf:	85 ff                	test   %edi,%edi
  8011c1:	79 1d                	jns    8011e0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011c3:	83 ec 08             	sub    $0x8,%esp
  8011c6:	53                   	push   %ebx
  8011c7:	6a 00                	push   $0x0
  8011c9:	e8 d2 fb ff ff       	call   800da0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011ce:	83 c4 08             	add    $0x8,%esp
  8011d1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011d4:	6a 00                	push   $0x0
  8011d6:	e8 c5 fb ff ff       	call   800da0 <sys_page_unmap>
	return r;
  8011db:	83 c4 10             	add    $0x10,%esp
  8011de:	89 f8                	mov    %edi,%eax
}
  8011e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e3:	5b                   	pop    %ebx
  8011e4:	5e                   	pop    %esi
  8011e5:	5f                   	pop    %edi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	53                   	push   %ebx
  8011ec:	83 ec 14             	sub    $0x14,%esp
  8011ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f5:	50                   	push   %eax
  8011f6:	53                   	push   %ebx
  8011f7:	e8 86 fd ff ff       	call   800f82 <fd_lookup>
  8011fc:	83 c4 08             	add    $0x8,%esp
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	85 c0                	test   %eax,%eax
  801203:	78 6d                	js     801272 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801205:	83 ec 08             	sub    $0x8,%esp
  801208:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120b:	50                   	push   %eax
  80120c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120f:	ff 30                	pushl  (%eax)
  801211:	e8 c2 fd ff ff       	call   800fd8 <dev_lookup>
  801216:	83 c4 10             	add    $0x10,%esp
  801219:	85 c0                	test   %eax,%eax
  80121b:	78 4c                	js     801269 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80121d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801220:	8b 42 08             	mov    0x8(%edx),%eax
  801223:	83 e0 03             	and    $0x3,%eax
  801226:	83 f8 01             	cmp    $0x1,%eax
  801229:	75 21                	jne    80124c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80122b:	a1 08 40 80 00       	mov    0x804008,%eax
  801230:	8b 40 48             	mov    0x48(%eax),%eax
  801233:	83 ec 04             	sub    $0x4,%esp
  801236:	53                   	push   %ebx
  801237:	50                   	push   %eax
  801238:	68 2d 2a 80 00       	push   $0x802a2d
  80123d:	e8 2b f0 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80124a:	eb 26                	jmp    801272 <read+0x8a>
	}
	if (!dev->dev_read)
  80124c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80124f:	8b 40 08             	mov    0x8(%eax),%eax
  801252:	85 c0                	test   %eax,%eax
  801254:	74 17                	je     80126d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801256:	83 ec 04             	sub    $0x4,%esp
  801259:	ff 75 10             	pushl  0x10(%ebp)
  80125c:	ff 75 0c             	pushl  0xc(%ebp)
  80125f:	52                   	push   %edx
  801260:	ff d0                	call   *%eax
  801262:	89 c2                	mov    %eax,%edx
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	eb 09                	jmp    801272 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801269:	89 c2                	mov    %eax,%edx
  80126b:	eb 05                	jmp    801272 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80126d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801272:	89 d0                	mov    %edx,%eax
  801274:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801277:	c9                   	leave  
  801278:	c3                   	ret    

00801279 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	57                   	push   %edi
  80127d:	56                   	push   %esi
  80127e:	53                   	push   %ebx
  80127f:	83 ec 0c             	sub    $0xc,%esp
  801282:	8b 7d 08             	mov    0x8(%ebp),%edi
  801285:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801288:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128d:	eb 21                	jmp    8012b0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80128f:	83 ec 04             	sub    $0x4,%esp
  801292:	89 f0                	mov    %esi,%eax
  801294:	29 d8                	sub    %ebx,%eax
  801296:	50                   	push   %eax
  801297:	89 d8                	mov    %ebx,%eax
  801299:	03 45 0c             	add    0xc(%ebp),%eax
  80129c:	50                   	push   %eax
  80129d:	57                   	push   %edi
  80129e:	e8 45 ff ff ff       	call   8011e8 <read>
		if (m < 0)
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	78 10                	js     8012ba <readn+0x41>
			return m;
		if (m == 0)
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	74 0a                	je     8012b8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012ae:	01 c3                	add    %eax,%ebx
  8012b0:	39 f3                	cmp    %esi,%ebx
  8012b2:	72 db                	jb     80128f <readn+0x16>
  8012b4:	89 d8                	mov    %ebx,%eax
  8012b6:	eb 02                	jmp    8012ba <readn+0x41>
  8012b8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012bd:	5b                   	pop    %ebx
  8012be:	5e                   	pop    %esi
  8012bf:	5f                   	pop    %edi
  8012c0:	5d                   	pop    %ebp
  8012c1:	c3                   	ret    

008012c2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	53                   	push   %ebx
  8012c6:	83 ec 14             	sub    $0x14,%esp
  8012c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cf:	50                   	push   %eax
  8012d0:	53                   	push   %ebx
  8012d1:	e8 ac fc ff ff       	call   800f82 <fd_lookup>
  8012d6:	83 c4 08             	add    $0x8,%esp
  8012d9:	89 c2                	mov    %eax,%edx
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	78 68                	js     801347 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012df:	83 ec 08             	sub    $0x8,%esp
  8012e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e5:	50                   	push   %eax
  8012e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e9:	ff 30                	pushl  (%eax)
  8012eb:	e8 e8 fc ff ff       	call   800fd8 <dev_lookup>
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	78 47                	js     80133e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012fe:	75 21                	jne    801321 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801300:	a1 08 40 80 00       	mov    0x804008,%eax
  801305:	8b 40 48             	mov    0x48(%eax),%eax
  801308:	83 ec 04             	sub    $0x4,%esp
  80130b:	53                   	push   %ebx
  80130c:	50                   	push   %eax
  80130d:	68 49 2a 80 00       	push   $0x802a49
  801312:	e8 56 ef ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80131f:	eb 26                	jmp    801347 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801321:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801324:	8b 52 0c             	mov    0xc(%edx),%edx
  801327:	85 d2                	test   %edx,%edx
  801329:	74 17                	je     801342 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80132b:	83 ec 04             	sub    $0x4,%esp
  80132e:	ff 75 10             	pushl  0x10(%ebp)
  801331:	ff 75 0c             	pushl  0xc(%ebp)
  801334:	50                   	push   %eax
  801335:	ff d2                	call   *%edx
  801337:	89 c2                	mov    %eax,%edx
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	eb 09                	jmp    801347 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133e:	89 c2                	mov    %eax,%edx
  801340:	eb 05                	jmp    801347 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801342:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801347:	89 d0                	mov    %edx,%eax
  801349:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134c:	c9                   	leave  
  80134d:	c3                   	ret    

0080134e <seek>:

int
seek(int fdnum, off_t offset)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801354:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801357:	50                   	push   %eax
  801358:	ff 75 08             	pushl  0x8(%ebp)
  80135b:	e8 22 fc ff ff       	call   800f82 <fd_lookup>
  801360:	83 c4 08             	add    $0x8,%esp
  801363:	85 c0                	test   %eax,%eax
  801365:	78 0e                	js     801375 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801367:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80136a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80136d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801370:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	53                   	push   %ebx
  80137b:	83 ec 14             	sub    $0x14,%esp
  80137e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801381:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801384:	50                   	push   %eax
  801385:	53                   	push   %ebx
  801386:	e8 f7 fb ff ff       	call   800f82 <fd_lookup>
  80138b:	83 c4 08             	add    $0x8,%esp
  80138e:	89 c2                	mov    %eax,%edx
  801390:	85 c0                	test   %eax,%eax
  801392:	78 65                	js     8013f9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801394:	83 ec 08             	sub    $0x8,%esp
  801397:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139a:	50                   	push   %eax
  80139b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139e:	ff 30                	pushl  (%eax)
  8013a0:	e8 33 fc ff ff       	call   800fd8 <dev_lookup>
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	85 c0                	test   %eax,%eax
  8013aa:	78 44                	js     8013f0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013af:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013b3:	75 21                	jne    8013d6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013b5:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013ba:	8b 40 48             	mov    0x48(%eax),%eax
  8013bd:	83 ec 04             	sub    $0x4,%esp
  8013c0:	53                   	push   %ebx
  8013c1:	50                   	push   %eax
  8013c2:	68 0c 2a 80 00       	push   $0x802a0c
  8013c7:	e8 a1 ee ff ff       	call   80026d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013d4:	eb 23                	jmp    8013f9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013d9:	8b 52 18             	mov    0x18(%edx),%edx
  8013dc:	85 d2                	test   %edx,%edx
  8013de:	74 14                	je     8013f4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013e0:	83 ec 08             	sub    $0x8,%esp
  8013e3:	ff 75 0c             	pushl  0xc(%ebp)
  8013e6:	50                   	push   %eax
  8013e7:	ff d2                	call   *%edx
  8013e9:	89 c2                	mov    %eax,%edx
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	eb 09                	jmp    8013f9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f0:	89 c2                	mov    %eax,%edx
  8013f2:	eb 05                	jmp    8013f9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013f4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013f9:	89 d0                	mov    %edx,%eax
  8013fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fe:	c9                   	leave  
  8013ff:	c3                   	ret    

00801400 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	53                   	push   %ebx
  801404:	83 ec 14             	sub    $0x14,%esp
  801407:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140d:	50                   	push   %eax
  80140e:	ff 75 08             	pushl  0x8(%ebp)
  801411:	e8 6c fb ff ff       	call   800f82 <fd_lookup>
  801416:	83 c4 08             	add    $0x8,%esp
  801419:	89 c2                	mov    %eax,%edx
  80141b:	85 c0                	test   %eax,%eax
  80141d:	78 58                	js     801477 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141f:	83 ec 08             	sub    $0x8,%esp
  801422:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801425:	50                   	push   %eax
  801426:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801429:	ff 30                	pushl  (%eax)
  80142b:	e8 a8 fb ff ff       	call   800fd8 <dev_lookup>
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	85 c0                	test   %eax,%eax
  801435:	78 37                	js     80146e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801437:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80143e:	74 32                	je     801472 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801440:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801443:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80144a:	00 00 00 
	stat->st_isdir = 0;
  80144d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801454:	00 00 00 
	stat->st_dev = dev;
  801457:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80145d:	83 ec 08             	sub    $0x8,%esp
  801460:	53                   	push   %ebx
  801461:	ff 75 f0             	pushl  -0x10(%ebp)
  801464:	ff 50 14             	call   *0x14(%eax)
  801467:	89 c2                	mov    %eax,%edx
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	eb 09                	jmp    801477 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146e:	89 c2                	mov    %eax,%edx
  801470:	eb 05                	jmp    801477 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801472:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801477:	89 d0                	mov    %edx,%eax
  801479:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147c:	c9                   	leave  
  80147d:	c3                   	ret    

0080147e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	56                   	push   %esi
  801482:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801483:	83 ec 08             	sub    $0x8,%esp
  801486:	6a 00                	push   $0x0
  801488:	ff 75 08             	pushl  0x8(%ebp)
  80148b:	e8 2b 02 00 00       	call   8016bb <open>
  801490:	89 c3                	mov    %eax,%ebx
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	85 c0                	test   %eax,%eax
  801497:	78 1b                	js     8014b4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801499:	83 ec 08             	sub    $0x8,%esp
  80149c:	ff 75 0c             	pushl  0xc(%ebp)
  80149f:	50                   	push   %eax
  8014a0:	e8 5b ff ff ff       	call   801400 <fstat>
  8014a5:	89 c6                	mov    %eax,%esi
	close(fd);
  8014a7:	89 1c 24             	mov    %ebx,(%esp)
  8014aa:	e8 fd fb ff ff       	call   8010ac <close>
	return r;
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	89 f0                	mov    %esi,%eax
}
  8014b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5e                   	pop    %esi
  8014b9:	5d                   	pop    %ebp
  8014ba:	c3                   	ret    

008014bb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	56                   	push   %esi
  8014bf:	53                   	push   %ebx
  8014c0:	89 c6                	mov    %eax,%esi
  8014c2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014c4:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8014cb:	75 12                	jne    8014df <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014cd:	83 ec 0c             	sub    $0xc,%esp
  8014d0:	6a 01                	push   $0x1
  8014d2:	e8 db 0d 00 00       	call   8022b2 <ipc_find_env>
  8014d7:	a3 04 40 80 00       	mov    %eax,0x804004
  8014dc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014df:	6a 07                	push   $0x7
  8014e1:	68 00 50 80 00       	push   $0x805000
  8014e6:	56                   	push   %esi
  8014e7:	ff 35 04 40 80 00    	pushl  0x804004
  8014ed:	e8 6a 0d 00 00       	call   80225c <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8014f2:	83 c4 0c             	add    $0xc,%esp
  8014f5:	6a 00                	push   $0x0
  8014f7:	53                   	push   %ebx
  8014f8:	6a 00                	push   $0x0
  8014fa:	e8 f4 0c 00 00       	call   8021f3 <ipc_recv>
}
  8014ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801502:	5b                   	pop    %ebx
  801503:	5e                   	pop    %esi
  801504:	5d                   	pop    %ebp
  801505:	c3                   	ret    

00801506 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80150c:	8b 45 08             	mov    0x8(%ebp),%eax
  80150f:	8b 40 0c             	mov    0xc(%eax),%eax
  801512:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801517:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80151f:	ba 00 00 00 00       	mov    $0x0,%edx
  801524:	b8 02 00 00 00       	mov    $0x2,%eax
  801529:	e8 8d ff ff ff       	call   8014bb <fsipc>
}
  80152e:	c9                   	leave  
  80152f:	c3                   	ret    

00801530 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801536:	8b 45 08             	mov    0x8(%ebp),%eax
  801539:	8b 40 0c             	mov    0xc(%eax),%eax
  80153c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801541:	ba 00 00 00 00       	mov    $0x0,%edx
  801546:	b8 06 00 00 00       	mov    $0x6,%eax
  80154b:	e8 6b ff ff ff       	call   8014bb <fsipc>
}
  801550:	c9                   	leave  
  801551:	c3                   	ret    

00801552 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801552:	55                   	push   %ebp
  801553:	89 e5                	mov    %esp,%ebp
  801555:	53                   	push   %ebx
  801556:	83 ec 04             	sub    $0x4,%esp
  801559:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80155c:	8b 45 08             	mov    0x8(%ebp),%eax
  80155f:	8b 40 0c             	mov    0xc(%eax),%eax
  801562:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801567:	ba 00 00 00 00       	mov    $0x0,%edx
  80156c:	b8 05 00 00 00       	mov    $0x5,%eax
  801571:	e8 45 ff ff ff       	call   8014bb <fsipc>
  801576:	85 c0                	test   %eax,%eax
  801578:	78 2c                	js     8015a6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80157a:	83 ec 08             	sub    $0x8,%esp
  80157d:	68 00 50 80 00       	push   $0x805000
  801582:	53                   	push   %ebx
  801583:	e8 19 f3 ff ff       	call   8008a1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801588:	a1 80 50 80 00       	mov    0x805080,%eax
  80158d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801593:	a1 84 50 80 00       	mov    0x805084,%eax
  801598:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a9:	c9                   	leave  
  8015aa:	c3                   	ret    

008015ab <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	53                   	push   %ebx
  8015af:	83 ec 08             	sub    $0x8,%esp
  8015b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8015b5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015ba:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8015bf:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  8015cd:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015d3:	53                   	push   %ebx
  8015d4:	ff 75 0c             	pushl  0xc(%ebp)
  8015d7:	68 08 50 80 00       	push   $0x805008
  8015dc:	e8 52 f4 ff ff       	call   800a33 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8015e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e6:	b8 04 00 00 00       	mov    $0x4,%eax
  8015eb:	e8 cb fe ff ff       	call   8014bb <fsipc>
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	78 3d                	js     801634 <devfile_write+0x89>
		return r;

	assert(r <= n);
  8015f7:	39 d8                	cmp    %ebx,%eax
  8015f9:	76 19                	jbe    801614 <devfile_write+0x69>
  8015fb:	68 78 2a 80 00       	push   $0x802a78
  801600:	68 7f 2a 80 00       	push   $0x802a7f
  801605:	68 9f 00 00 00       	push   $0x9f
  80160a:	68 94 2a 80 00       	push   $0x802a94
  80160f:	e8 80 eb ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801614:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801619:	76 19                	jbe    801634 <devfile_write+0x89>
  80161b:	68 ac 2a 80 00       	push   $0x802aac
  801620:	68 7f 2a 80 00       	push   $0x802a7f
  801625:	68 a0 00 00 00       	push   $0xa0
  80162a:	68 94 2a 80 00       	push   $0x802a94
  80162f:	e8 60 eb ff ff       	call   800194 <_panic>

	return r;
}
  801634:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801637:	c9                   	leave  
  801638:	c3                   	ret    

00801639 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	56                   	push   %esi
  80163d:	53                   	push   %ebx
  80163e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801641:	8b 45 08             	mov    0x8(%ebp),%eax
  801644:	8b 40 0c             	mov    0xc(%eax),%eax
  801647:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80164c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801652:	ba 00 00 00 00       	mov    $0x0,%edx
  801657:	b8 03 00 00 00       	mov    $0x3,%eax
  80165c:	e8 5a fe ff ff       	call   8014bb <fsipc>
  801661:	89 c3                	mov    %eax,%ebx
  801663:	85 c0                	test   %eax,%eax
  801665:	78 4b                	js     8016b2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801667:	39 c6                	cmp    %eax,%esi
  801669:	73 16                	jae    801681 <devfile_read+0x48>
  80166b:	68 78 2a 80 00       	push   $0x802a78
  801670:	68 7f 2a 80 00       	push   $0x802a7f
  801675:	6a 7e                	push   $0x7e
  801677:	68 94 2a 80 00       	push   $0x802a94
  80167c:	e8 13 eb ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  801681:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801686:	7e 16                	jle    80169e <devfile_read+0x65>
  801688:	68 9f 2a 80 00       	push   $0x802a9f
  80168d:	68 7f 2a 80 00       	push   $0x802a7f
  801692:	6a 7f                	push   $0x7f
  801694:	68 94 2a 80 00       	push   $0x802a94
  801699:	e8 f6 ea ff ff       	call   800194 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80169e:	83 ec 04             	sub    $0x4,%esp
  8016a1:	50                   	push   %eax
  8016a2:	68 00 50 80 00       	push   $0x805000
  8016a7:	ff 75 0c             	pushl  0xc(%ebp)
  8016aa:	e8 84 f3 ff ff       	call   800a33 <memmove>
	return r;
  8016af:	83 c4 10             	add    $0x10,%esp
}
  8016b2:	89 d8                	mov    %ebx,%eax
  8016b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b7:	5b                   	pop    %ebx
  8016b8:	5e                   	pop    %esi
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    

008016bb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	53                   	push   %ebx
  8016bf:	83 ec 20             	sub    $0x20,%esp
  8016c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016c5:	53                   	push   %ebx
  8016c6:	e8 9d f1 ff ff       	call   800868 <strlen>
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016d3:	7f 67                	jg     80173c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016d5:	83 ec 0c             	sub    $0xc,%esp
  8016d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016db:	50                   	push   %eax
  8016dc:	e8 52 f8 ff ff       	call   800f33 <fd_alloc>
  8016e1:	83 c4 10             	add    $0x10,%esp
		return r;
  8016e4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016e6:	85 c0                	test   %eax,%eax
  8016e8:	78 57                	js     801741 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016ea:	83 ec 08             	sub    $0x8,%esp
  8016ed:	53                   	push   %ebx
  8016ee:	68 00 50 80 00       	push   $0x805000
  8016f3:	e8 a9 f1 ff ff       	call   8008a1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016fb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801700:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801703:	b8 01 00 00 00       	mov    $0x1,%eax
  801708:	e8 ae fd ff ff       	call   8014bb <fsipc>
  80170d:	89 c3                	mov    %eax,%ebx
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	85 c0                	test   %eax,%eax
  801714:	79 14                	jns    80172a <open+0x6f>
		fd_close(fd, 0);
  801716:	83 ec 08             	sub    $0x8,%esp
  801719:	6a 00                	push   $0x0
  80171b:	ff 75 f4             	pushl  -0xc(%ebp)
  80171e:	e8 08 f9 ff ff       	call   80102b <fd_close>
		return r;
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	89 da                	mov    %ebx,%edx
  801728:	eb 17                	jmp    801741 <open+0x86>
	}

	return fd2num(fd);
  80172a:	83 ec 0c             	sub    $0xc,%esp
  80172d:	ff 75 f4             	pushl  -0xc(%ebp)
  801730:	e8 d7 f7 ff ff       	call   800f0c <fd2num>
  801735:	89 c2                	mov    %eax,%edx
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	eb 05                	jmp    801741 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80173c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801741:	89 d0                	mov    %edx,%eax
  801743:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801746:	c9                   	leave  
  801747:	c3                   	ret    

00801748 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80174e:	ba 00 00 00 00       	mov    $0x0,%edx
  801753:	b8 08 00 00 00       	mov    $0x8,%eax
  801758:	e8 5e fd ff ff       	call   8014bb <fsipc>
}
  80175d:	c9                   	leave  
  80175e:	c3                   	ret    

0080175f <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	57                   	push   %edi
  801763:	56                   	push   %esi
  801764:	53                   	push   %ebx
  801765:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80176b:	6a 00                	push   $0x0
  80176d:	ff 75 08             	pushl  0x8(%ebp)
  801770:	e8 46 ff ff ff       	call   8016bb <open>
  801775:	89 c7                	mov    %eax,%edi
  801777:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80177d:	83 c4 10             	add    $0x10,%esp
  801780:	85 c0                	test   %eax,%eax
  801782:	0f 88 af 04 00 00    	js     801c37 <spawn+0x4d8>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801788:	83 ec 04             	sub    $0x4,%esp
  80178b:	68 00 02 00 00       	push   $0x200
  801790:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801796:	50                   	push   %eax
  801797:	57                   	push   %edi
  801798:	e8 dc fa ff ff       	call   801279 <readn>
  80179d:	83 c4 10             	add    $0x10,%esp
  8017a0:	3d 00 02 00 00       	cmp    $0x200,%eax
  8017a5:	75 0c                	jne    8017b3 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8017a7:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8017ae:	45 4c 46 
  8017b1:	74 33                	je     8017e6 <spawn+0x87>
		close(fd);
  8017b3:	83 ec 0c             	sub    $0xc,%esp
  8017b6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8017bc:	e8 eb f8 ff ff       	call   8010ac <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8017c1:	83 c4 0c             	add    $0xc,%esp
  8017c4:	68 7f 45 4c 46       	push   $0x464c457f
  8017c9:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8017cf:	68 d9 2a 80 00       	push   $0x802ad9
  8017d4:	e8 94 ea ff ff       	call   80026d <cprintf>
		return -E_NOT_EXEC;
  8017d9:	83 c4 10             	add    $0x10,%esp
  8017dc:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8017e1:	e9 b1 04 00 00       	jmp    801c97 <spawn+0x538>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8017e6:	b8 07 00 00 00       	mov    $0x7,%eax
  8017eb:	cd 30                	int    $0x30
  8017ed:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8017f3:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	0f 88 3e 04 00 00    	js     801c3f <spawn+0x4e0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801801:	89 c6                	mov    %eax,%esi
  801803:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801809:	6b f6 7c             	imul   $0x7c,%esi,%esi
  80180c:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801812:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801818:	b9 11 00 00 00       	mov    $0x11,%ecx
  80181d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80181f:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801825:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80182b:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801830:	be 00 00 00 00       	mov    $0x0,%esi
  801835:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801838:	eb 13                	jmp    80184d <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80183a:	83 ec 0c             	sub    $0xc,%esp
  80183d:	50                   	push   %eax
  80183e:	e8 25 f0 ff ff       	call   800868 <strlen>
  801843:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801847:	83 c3 01             	add    $0x1,%ebx
  80184a:	83 c4 10             	add    $0x10,%esp
  80184d:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801854:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801857:	85 c0                	test   %eax,%eax
  801859:	75 df                	jne    80183a <spawn+0xdb>
  80185b:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801861:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801867:	bf 00 10 40 00       	mov    $0x401000,%edi
  80186c:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80186e:	89 fa                	mov    %edi,%edx
  801870:	83 e2 fc             	and    $0xfffffffc,%edx
  801873:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80187a:	29 c2                	sub    %eax,%edx
  80187c:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801882:	8d 42 f8             	lea    -0x8(%edx),%eax
  801885:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80188a:	0f 86 bf 03 00 00    	jbe    801c4f <spawn+0x4f0>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801890:	83 ec 04             	sub    $0x4,%esp
  801893:	6a 07                	push   $0x7
  801895:	68 00 00 40 00       	push   $0x400000
  80189a:	6a 00                	push   $0x0
  80189c:	e8 7a f4 ff ff       	call   800d1b <sys_page_alloc>
  8018a1:	83 c4 10             	add    $0x10,%esp
  8018a4:	85 c0                	test   %eax,%eax
  8018a6:	0f 88 aa 03 00 00    	js     801c56 <spawn+0x4f7>
  8018ac:	be 00 00 00 00       	mov    $0x0,%esi
  8018b1:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8018b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8018ba:	eb 30                	jmp    8018ec <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8018bc:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8018c2:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8018c8:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8018cb:	83 ec 08             	sub    $0x8,%esp
  8018ce:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8018d1:	57                   	push   %edi
  8018d2:	e8 ca ef ff ff       	call   8008a1 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8018d7:	83 c4 04             	add    $0x4,%esp
  8018da:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8018dd:	e8 86 ef ff ff       	call   800868 <strlen>
  8018e2:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8018e6:	83 c6 01             	add    $0x1,%esi
  8018e9:	83 c4 10             	add    $0x10,%esp
  8018ec:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8018f2:	7f c8                	jg     8018bc <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8018f4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8018fa:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801900:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801907:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80190d:	74 19                	je     801928 <spawn+0x1c9>
  80190f:	68 60 2b 80 00       	push   $0x802b60
  801914:	68 7f 2a 80 00       	push   $0x802a7f
  801919:	68 f2 00 00 00       	push   $0xf2
  80191e:	68 f3 2a 80 00       	push   $0x802af3
  801923:	e8 6c e8 ff ff       	call   800194 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801928:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80192e:	89 f8                	mov    %edi,%eax
  801930:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801935:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801938:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80193e:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801941:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801947:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80194d:	83 ec 0c             	sub    $0xc,%esp
  801950:	6a 07                	push   $0x7
  801952:	68 00 d0 bf ee       	push   $0xeebfd000
  801957:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80195d:	68 00 00 40 00       	push   $0x400000
  801962:	6a 00                	push   $0x0
  801964:	e8 f5 f3 ff ff       	call   800d5e <sys_page_map>
  801969:	89 c3                	mov    %eax,%ebx
  80196b:	83 c4 20             	add    $0x20,%esp
  80196e:	85 c0                	test   %eax,%eax
  801970:	0f 88 0f 03 00 00    	js     801c85 <spawn+0x526>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801976:	83 ec 08             	sub    $0x8,%esp
  801979:	68 00 00 40 00       	push   $0x400000
  80197e:	6a 00                	push   $0x0
  801980:	e8 1b f4 ff ff       	call   800da0 <sys_page_unmap>
  801985:	89 c3                	mov    %eax,%ebx
  801987:	83 c4 10             	add    $0x10,%esp
  80198a:	85 c0                	test   %eax,%eax
  80198c:	0f 88 f3 02 00 00    	js     801c85 <spawn+0x526>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801992:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801998:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80199f:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019a5:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8019ac:	00 00 00 
  8019af:	e9 88 01 00 00       	jmp    801b3c <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  8019b4:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8019ba:	83 38 01             	cmpl   $0x1,(%eax)
  8019bd:	0f 85 6b 01 00 00    	jne    801b2e <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8019c3:	89 c7                	mov    %eax,%edi
  8019c5:	8b 40 18             	mov    0x18(%eax),%eax
  8019c8:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8019ce:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8019d1:	83 f8 01             	cmp    $0x1,%eax
  8019d4:	19 c0                	sbb    %eax,%eax
  8019d6:	83 e0 fe             	and    $0xfffffffe,%eax
  8019d9:	83 c0 07             	add    $0x7,%eax
  8019dc:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8019e2:	89 f8                	mov    %edi,%eax
  8019e4:	8b 7f 04             	mov    0x4(%edi),%edi
  8019e7:	89 f9                	mov    %edi,%ecx
  8019e9:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8019ef:	8b 78 10             	mov    0x10(%eax),%edi
  8019f2:	8b 50 14             	mov    0x14(%eax),%edx
  8019f5:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  8019fb:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8019fe:	89 f0                	mov    %esi,%eax
  801a00:	25 ff 0f 00 00       	and    $0xfff,%eax
  801a05:	74 14                	je     801a1b <spawn+0x2bc>
		va -= i;
  801a07:	29 c6                	sub    %eax,%esi
		memsz += i;
  801a09:	01 c2                	add    %eax,%edx
  801a0b:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801a11:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801a13:	29 c1                	sub    %eax,%ecx
  801a15:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801a1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a20:	e9 f7 00 00 00       	jmp    801b1c <spawn+0x3bd>
		if (i >= filesz) {
  801a25:	39 df                	cmp    %ebx,%edi
  801a27:	77 27                	ja     801a50 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801a29:	83 ec 04             	sub    $0x4,%esp
  801a2c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801a32:	56                   	push   %esi
  801a33:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801a39:	e8 dd f2 ff ff       	call   800d1b <sys_page_alloc>
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	85 c0                	test   %eax,%eax
  801a43:	0f 89 c7 00 00 00    	jns    801b10 <spawn+0x3b1>
  801a49:	89 c3                	mov    %eax,%ebx
  801a4b:	e9 14 02 00 00       	jmp    801c64 <spawn+0x505>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a50:	83 ec 04             	sub    $0x4,%esp
  801a53:	6a 07                	push   $0x7
  801a55:	68 00 00 40 00       	push   $0x400000
  801a5a:	6a 00                	push   $0x0
  801a5c:	e8 ba f2 ff ff       	call   800d1b <sys_page_alloc>
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	85 c0                	test   %eax,%eax
  801a66:	0f 88 ee 01 00 00    	js     801c5a <spawn+0x4fb>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801a6c:	83 ec 08             	sub    $0x8,%esp
  801a6f:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801a75:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801a7b:	50                   	push   %eax
  801a7c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a82:	e8 c7 f8 ff ff       	call   80134e <seek>
  801a87:	83 c4 10             	add    $0x10,%esp
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	0f 88 cc 01 00 00    	js     801c5e <spawn+0x4ff>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801a92:	83 ec 04             	sub    $0x4,%esp
  801a95:	89 f8                	mov    %edi,%eax
  801a97:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801a9d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801aa2:	ba 00 10 00 00       	mov    $0x1000,%edx
  801aa7:	0f 47 c2             	cmova  %edx,%eax
  801aaa:	50                   	push   %eax
  801aab:	68 00 00 40 00       	push   $0x400000
  801ab0:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ab6:	e8 be f7 ff ff       	call   801279 <readn>
  801abb:	83 c4 10             	add    $0x10,%esp
  801abe:	85 c0                	test   %eax,%eax
  801ac0:	0f 88 9c 01 00 00    	js     801c62 <spawn+0x503>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801ac6:	83 ec 0c             	sub    $0xc,%esp
  801ac9:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801acf:	56                   	push   %esi
  801ad0:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801ad6:	68 00 00 40 00       	push   $0x400000
  801adb:	6a 00                	push   $0x0
  801add:	e8 7c f2 ff ff       	call   800d5e <sys_page_map>
  801ae2:	83 c4 20             	add    $0x20,%esp
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	79 15                	jns    801afe <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801ae9:	50                   	push   %eax
  801aea:	68 ff 2a 80 00       	push   $0x802aff
  801aef:	68 25 01 00 00       	push   $0x125
  801af4:	68 f3 2a 80 00       	push   $0x802af3
  801af9:	e8 96 e6 ff ff       	call   800194 <_panic>
			sys_page_unmap(0, UTEMP);
  801afe:	83 ec 08             	sub    $0x8,%esp
  801b01:	68 00 00 40 00       	push   $0x400000
  801b06:	6a 00                	push   $0x0
  801b08:	e8 93 f2 ff ff       	call   800da0 <sys_page_unmap>
  801b0d:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b10:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801b16:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801b1c:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801b22:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801b28:	0f 87 f7 fe ff ff    	ja     801a25 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b2e:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801b35:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801b3c:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801b43:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801b49:	0f 8c 65 fe ff ff    	jl     8019b4 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801b4f:	83 ec 0c             	sub    $0xc,%esp
  801b52:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b58:	e8 4f f5 ff ff       	call   8010ac <close>
  801b5d:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	int r;

	// loop through all page table entries
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn) {
  801b60:	bb 00 08 00 00       	mov    $0x800,%ebx
  801b65:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		// the page table does not exist at all
		if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) {
  801b6b:	89 d8                	mov    %ebx,%eax
  801b6d:	c1 e0 0c             	shl    $0xc,%eax
  801b70:	89 c2                	mov    %eax,%edx
  801b72:	c1 ea 16             	shr    $0x16,%edx
  801b75:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b7c:	f6 c2 01             	test   $0x1,%dl
  801b7f:	75 08                	jne    801b89 <spawn+0x42a>
			pn += NPTENTRIES - 1;
  801b81:	81 c3 ff 03 00 00    	add    $0x3ff,%ebx
  801b87:	eb 3c                	jmp    801bc5 <spawn+0x466>
			continue;
		}

		// virtual page pn's page table entry
		pte_t pe = uvpt[pn];
  801b89:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx

		// share the page with the new environment
		if(pe & PTE_SHARE) {
  801b90:	f6 c6 04             	test   $0x4,%dh
  801b93:	74 30                	je     801bc5 <spawn+0x466>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), child, 
  801b95:	83 ec 0c             	sub    $0xc,%esp
  801b98:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801b9e:	52                   	push   %edx
  801b9f:	50                   	push   %eax
  801ba0:	56                   	push   %esi
  801ba1:	50                   	push   %eax
  801ba2:	6a 00                	push   $0x0
  801ba4:	e8 b5 f1 ff ff       	call   800d5e <sys_page_map>
  801ba9:	83 c4 20             	add    $0x20,%esp
  801bac:	85 c0                	test   %eax,%eax
  801bae:	79 15                	jns    801bc5 <spawn+0x466>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("copy_shared: %e", r);
  801bb0:	50                   	push   %eax
  801bb1:	68 1c 2b 80 00       	push   $0x802b1c
  801bb6:	68 42 01 00 00       	push   $0x142
  801bbb:	68 f3 2a 80 00       	push   $0x802af3
  801bc0:	e8 cf e5 ff ff       	call   800194 <_panic>
{
	// LAB 5: Your code here.
	int r;

	// loop through all page table entries
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn) {
  801bc5:	83 c3 01             	add    $0x1,%ebx
  801bc8:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801bce:	76 9b                	jbe    801b6b <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801bd0:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801bd7:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801bda:	83 ec 08             	sub    $0x8,%esp
  801bdd:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801be3:	50                   	push   %eax
  801be4:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801bea:	e8 35 f2 ff ff       	call   800e24 <sys_env_set_trapframe>
  801bef:	83 c4 10             	add    $0x10,%esp
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	79 15                	jns    801c0b <spawn+0x4ac>
		panic("sys_env_set_trapframe: %e", r);
  801bf6:	50                   	push   %eax
  801bf7:	68 2c 2b 80 00       	push   $0x802b2c
  801bfc:	68 86 00 00 00       	push   $0x86
  801c01:	68 f3 2a 80 00       	push   $0x802af3
  801c06:	e8 89 e5 ff ff       	call   800194 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801c0b:	83 ec 08             	sub    $0x8,%esp
  801c0e:	6a 02                	push   $0x2
  801c10:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801c16:	e8 c7 f1 ff ff       	call   800de2 <sys_env_set_status>
  801c1b:	83 c4 10             	add    $0x10,%esp
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	79 25                	jns    801c47 <spawn+0x4e8>
		panic("sys_env_set_status: %e", r);
  801c22:	50                   	push   %eax
  801c23:	68 46 2b 80 00       	push   $0x802b46
  801c28:	68 89 00 00 00       	push   $0x89
  801c2d:	68 f3 2a 80 00       	push   $0x802af3
  801c32:	e8 5d e5 ff ff       	call   800194 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801c37:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801c3d:	eb 58                	jmp    801c97 <spawn+0x538>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801c3f:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801c45:	eb 50                	jmp    801c97 <spawn+0x538>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801c47:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801c4d:	eb 48                	jmp    801c97 <spawn+0x538>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801c4f:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801c54:	eb 41                	jmp    801c97 <spawn+0x538>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	eb 3d                	jmp    801c97 <spawn+0x538>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c5a:	89 c3                	mov    %eax,%ebx
  801c5c:	eb 06                	jmp    801c64 <spawn+0x505>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c5e:	89 c3                	mov    %eax,%ebx
  801c60:	eb 02                	jmp    801c64 <spawn+0x505>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c62:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801c64:	83 ec 0c             	sub    $0xc,%esp
  801c67:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801c6d:	e8 2a f0 ff ff       	call   800c9c <sys_env_destroy>
	close(fd);
  801c72:	83 c4 04             	add    $0x4,%esp
  801c75:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c7b:	e8 2c f4 ff ff       	call   8010ac <close>
	return r;
  801c80:	83 c4 10             	add    $0x10,%esp
  801c83:	eb 12                	jmp    801c97 <spawn+0x538>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801c85:	83 ec 08             	sub    $0x8,%esp
  801c88:	68 00 00 40 00       	push   $0x400000
  801c8d:	6a 00                	push   $0x0
  801c8f:	e8 0c f1 ff ff       	call   800da0 <sys_page_unmap>
  801c94:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801c97:	89 d8                	mov    %ebx,%eax
  801c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9c:	5b                   	pop    %ebx
  801c9d:	5e                   	pop    %esi
  801c9e:	5f                   	pop    %edi
  801c9f:	5d                   	pop    %ebp
  801ca0:	c3                   	ret    

00801ca1 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	56                   	push   %esi
  801ca5:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ca6:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ca9:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801cae:	eb 03                	jmp    801cb3 <spawnl+0x12>
		argc++;
  801cb0:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801cb3:	83 c2 04             	add    $0x4,%edx
  801cb6:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801cba:	75 f4                	jne    801cb0 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801cbc:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801cc3:	83 e2 f0             	and    $0xfffffff0,%edx
  801cc6:	29 d4                	sub    %edx,%esp
  801cc8:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ccc:	c1 ea 02             	shr    $0x2,%edx
  801ccf:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801cd6:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cdb:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801ce2:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801ce9:	00 
  801cea:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801cec:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf1:	eb 0a                	jmp    801cfd <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801cf3:	83 c0 01             	add    $0x1,%eax
  801cf6:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801cfa:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801cfd:	39 d0                	cmp    %edx,%eax
  801cff:	75 f2                	jne    801cf3 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801d01:	83 ec 08             	sub    $0x8,%esp
  801d04:	56                   	push   %esi
  801d05:	ff 75 08             	pushl  0x8(%ebp)
  801d08:	e8 52 fa ff ff       	call   80175f <spawn>
}
  801d0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d10:	5b                   	pop    %ebx
  801d11:	5e                   	pop    %esi
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    

00801d14 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	56                   	push   %esi
  801d18:	53                   	push   %ebx
  801d19:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d1c:	83 ec 0c             	sub    $0xc,%esp
  801d1f:	ff 75 08             	pushl  0x8(%ebp)
  801d22:	e8 f5 f1 ff ff       	call   800f1c <fd2data>
  801d27:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d29:	83 c4 08             	add    $0x8,%esp
  801d2c:	68 86 2b 80 00       	push   $0x802b86
  801d31:	53                   	push   %ebx
  801d32:	e8 6a eb ff ff       	call   8008a1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d37:	8b 46 04             	mov    0x4(%esi),%eax
  801d3a:	2b 06                	sub    (%esi),%eax
  801d3c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d42:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d49:	00 00 00 
	stat->st_dev = &devpipe;
  801d4c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801d53:	30 80 00 
	return 0;
}
  801d56:	b8 00 00 00 00       	mov    $0x0,%eax
  801d5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d5e:	5b                   	pop    %ebx
  801d5f:	5e                   	pop    %esi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    

00801d62 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	53                   	push   %ebx
  801d66:	83 ec 0c             	sub    $0xc,%esp
  801d69:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d6c:	53                   	push   %ebx
  801d6d:	6a 00                	push   $0x0
  801d6f:	e8 2c f0 ff ff       	call   800da0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d74:	89 1c 24             	mov    %ebx,(%esp)
  801d77:	e8 a0 f1 ff ff       	call   800f1c <fd2data>
  801d7c:	83 c4 08             	add    $0x8,%esp
  801d7f:	50                   	push   %eax
  801d80:	6a 00                	push   $0x0
  801d82:	e8 19 f0 ff ff       	call   800da0 <sys_page_unmap>
}
  801d87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d8a:	c9                   	leave  
  801d8b:	c3                   	ret    

00801d8c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	57                   	push   %edi
  801d90:	56                   	push   %esi
  801d91:	53                   	push   %ebx
  801d92:	83 ec 1c             	sub    $0x1c,%esp
  801d95:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d98:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d9a:	a1 08 40 80 00       	mov    0x804008,%eax
  801d9f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801da2:	83 ec 0c             	sub    $0xc,%esp
  801da5:	ff 75 e0             	pushl  -0x20(%ebp)
  801da8:	e8 3e 05 00 00       	call   8022eb <pageref>
  801dad:	89 c3                	mov    %eax,%ebx
  801daf:	89 3c 24             	mov    %edi,(%esp)
  801db2:	e8 34 05 00 00       	call   8022eb <pageref>
  801db7:	83 c4 10             	add    $0x10,%esp
  801dba:	39 c3                	cmp    %eax,%ebx
  801dbc:	0f 94 c1             	sete   %cl
  801dbf:	0f b6 c9             	movzbl %cl,%ecx
  801dc2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801dc5:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801dcb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801dce:	39 ce                	cmp    %ecx,%esi
  801dd0:	74 1b                	je     801ded <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801dd2:	39 c3                	cmp    %eax,%ebx
  801dd4:	75 c4                	jne    801d9a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801dd6:	8b 42 58             	mov    0x58(%edx),%eax
  801dd9:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ddc:	50                   	push   %eax
  801ddd:	56                   	push   %esi
  801dde:	68 8d 2b 80 00       	push   $0x802b8d
  801de3:	e8 85 e4 ff ff       	call   80026d <cprintf>
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	eb ad                	jmp    801d9a <_pipeisclosed+0xe>
	}
}
  801ded:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df3:	5b                   	pop    %ebx
  801df4:	5e                   	pop    %esi
  801df5:	5f                   	pop    %edi
  801df6:	5d                   	pop    %ebp
  801df7:	c3                   	ret    

00801df8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	57                   	push   %edi
  801dfc:	56                   	push   %esi
  801dfd:	53                   	push   %ebx
  801dfe:	83 ec 28             	sub    $0x28,%esp
  801e01:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e04:	56                   	push   %esi
  801e05:	e8 12 f1 ff ff       	call   800f1c <fd2data>
  801e0a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e0c:	83 c4 10             	add    $0x10,%esp
  801e0f:	bf 00 00 00 00       	mov    $0x0,%edi
  801e14:	eb 4b                	jmp    801e61 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e16:	89 da                	mov    %ebx,%edx
  801e18:	89 f0                	mov    %esi,%eax
  801e1a:	e8 6d ff ff ff       	call   801d8c <_pipeisclosed>
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	75 48                	jne    801e6b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e23:	e8 d4 ee ff ff       	call   800cfc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e28:	8b 43 04             	mov    0x4(%ebx),%eax
  801e2b:	8b 0b                	mov    (%ebx),%ecx
  801e2d:	8d 51 20             	lea    0x20(%ecx),%edx
  801e30:	39 d0                	cmp    %edx,%eax
  801e32:	73 e2                	jae    801e16 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e37:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e3b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e3e:	89 c2                	mov    %eax,%edx
  801e40:	c1 fa 1f             	sar    $0x1f,%edx
  801e43:	89 d1                	mov    %edx,%ecx
  801e45:	c1 e9 1b             	shr    $0x1b,%ecx
  801e48:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e4b:	83 e2 1f             	and    $0x1f,%edx
  801e4e:	29 ca                	sub    %ecx,%edx
  801e50:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e54:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e58:	83 c0 01             	add    $0x1,%eax
  801e5b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e5e:	83 c7 01             	add    $0x1,%edi
  801e61:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e64:	75 c2                	jne    801e28 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e66:	8b 45 10             	mov    0x10(%ebp),%eax
  801e69:	eb 05                	jmp    801e70 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e6b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e73:	5b                   	pop    %ebx
  801e74:	5e                   	pop    %esi
  801e75:	5f                   	pop    %edi
  801e76:	5d                   	pop    %ebp
  801e77:	c3                   	ret    

00801e78 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	57                   	push   %edi
  801e7c:	56                   	push   %esi
  801e7d:	53                   	push   %ebx
  801e7e:	83 ec 18             	sub    $0x18,%esp
  801e81:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e84:	57                   	push   %edi
  801e85:	e8 92 f0 ff ff       	call   800f1c <fd2data>
  801e8a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e8c:	83 c4 10             	add    $0x10,%esp
  801e8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e94:	eb 3d                	jmp    801ed3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e96:	85 db                	test   %ebx,%ebx
  801e98:	74 04                	je     801e9e <devpipe_read+0x26>
				return i;
  801e9a:	89 d8                	mov    %ebx,%eax
  801e9c:	eb 44                	jmp    801ee2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e9e:	89 f2                	mov    %esi,%edx
  801ea0:	89 f8                	mov    %edi,%eax
  801ea2:	e8 e5 fe ff ff       	call   801d8c <_pipeisclosed>
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	75 32                	jne    801edd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801eab:	e8 4c ee ff ff       	call   800cfc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801eb0:	8b 06                	mov    (%esi),%eax
  801eb2:	3b 46 04             	cmp    0x4(%esi),%eax
  801eb5:	74 df                	je     801e96 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801eb7:	99                   	cltd   
  801eb8:	c1 ea 1b             	shr    $0x1b,%edx
  801ebb:	01 d0                	add    %edx,%eax
  801ebd:	83 e0 1f             	and    $0x1f,%eax
  801ec0:	29 d0                	sub    %edx,%eax
  801ec2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ec7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801eca:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ecd:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ed0:	83 c3 01             	add    $0x1,%ebx
  801ed3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ed6:	75 d8                	jne    801eb0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ed8:	8b 45 10             	mov    0x10(%ebp),%eax
  801edb:	eb 05                	jmp    801ee2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801edd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ee2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee5:	5b                   	pop    %ebx
  801ee6:	5e                   	pop    %esi
  801ee7:	5f                   	pop    %edi
  801ee8:	5d                   	pop    %ebp
  801ee9:	c3                   	ret    

00801eea <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	56                   	push   %esi
  801eee:	53                   	push   %ebx
  801eef:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ef2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef5:	50                   	push   %eax
  801ef6:	e8 38 f0 ff ff       	call   800f33 <fd_alloc>
  801efb:	83 c4 10             	add    $0x10,%esp
  801efe:	89 c2                	mov    %eax,%edx
  801f00:	85 c0                	test   %eax,%eax
  801f02:	0f 88 2c 01 00 00    	js     802034 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f08:	83 ec 04             	sub    $0x4,%esp
  801f0b:	68 07 04 00 00       	push   $0x407
  801f10:	ff 75 f4             	pushl  -0xc(%ebp)
  801f13:	6a 00                	push   $0x0
  801f15:	e8 01 ee ff ff       	call   800d1b <sys_page_alloc>
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	89 c2                	mov    %eax,%edx
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	0f 88 0d 01 00 00    	js     802034 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f27:	83 ec 0c             	sub    $0xc,%esp
  801f2a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f2d:	50                   	push   %eax
  801f2e:	e8 00 f0 ff ff       	call   800f33 <fd_alloc>
  801f33:	89 c3                	mov    %eax,%ebx
  801f35:	83 c4 10             	add    $0x10,%esp
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	0f 88 e2 00 00 00    	js     802022 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f40:	83 ec 04             	sub    $0x4,%esp
  801f43:	68 07 04 00 00       	push   $0x407
  801f48:	ff 75 f0             	pushl  -0x10(%ebp)
  801f4b:	6a 00                	push   $0x0
  801f4d:	e8 c9 ed ff ff       	call   800d1b <sys_page_alloc>
  801f52:	89 c3                	mov    %eax,%ebx
  801f54:	83 c4 10             	add    $0x10,%esp
  801f57:	85 c0                	test   %eax,%eax
  801f59:	0f 88 c3 00 00 00    	js     802022 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f5f:	83 ec 0c             	sub    $0xc,%esp
  801f62:	ff 75 f4             	pushl  -0xc(%ebp)
  801f65:	e8 b2 ef ff ff       	call   800f1c <fd2data>
  801f6a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f6c:	83 c4 0c             	add    $0xc,%esp
  801f6f:	68 07 04 00 00       	push   $0x407
  801f74:	50                   	push   %eax
  801f75:	6a 00                	push   $0x0
  801f77:	e8 9f ed ff ff       	call   800d1b <sys_page_alloc>
  801f7c:	89 c3                	mov    %eax,%ebx
  801f7e:	83 c4 10             	add    $0x10,%esp
  801f81:	85 c0                	test   %eax,%eax
  801f83:	0f 88 89 00 00 00    	js     802012 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f89:	83 ec 0c             	sub    $0xc,%esp
  801f8c:	ff 75 f0             	pushl  -0x10(%ebp)
  801f8f:	e8 88 ef ff ff       	call   800f1c <fd2data>
  801f94:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f9b:	50                   	push   %eax
  801f9c:	6a 00                	push   $0x0
  801f9e:	56                   	push   %esi
  801f9f:	6a 00                	push   $0x0
  801fa1:	e8 b8 ed ff ff       	call   800d5e <sys_page_map>
  801fa6:	89 c3                	mov    %eax,%ebx
  801fa8:	83 c4 20             	add    $0x20,%esp
  801fab:	85 c0                	test   %eax,%eax
  801fad:	78 55                	js     802004 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801faf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fc4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fcd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fd2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fd9:	83 ec 0c             	sub    $0xc,%esp
  801fdc:	ff 75 f4             	pushl  -0xc(%ebp)
  801fdf:	e8 28 ef ff ff       	call   800f0c <fd2num>
  801fe4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fe7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fe9:	83 c4 04             	add    $0x4,%esp
  801fec:	ff 75 f0             	pushl  -0x10(%ebp)
  801fef:	e8 18 ef ff ff       	call   800f0c <fd2num>
  801ff4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ff7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	ba 00 00 00 00       	mov    $0x0,%edx
  802002:	eb 30                	jmp    802034 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802004:	83 ec 08             	sub    $0x8,%esp
  802007:	56                   	push   %esi
  802008:	6a 00                	push   $0x0
  80200a:	e8 91 ed ff ff       	call   800da0 <sys_page_unmap>
  80200f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802012:	83 ec 08             	sub    $0x8,%esp
  802015:	ff 75 f0             	pushl  -0x10(%ebp)
  802018:	6a 00                	push   $0x0
  80201a:	e8 81 ed ff ff       	call   800da0 <sys_page_unmap>
  80201f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802022:	83 ec 08             	sub    $0x8,%esp
  802025:	ff 75 f4             	pushl  -0xc(%ebp)
  802028:	6a 00                	push   $0x0
  80202a:	e8 71 ed ff ff       	call   800da0 <sys_page_unmap>
  80202f:	83 c4 10             	add    $0x10,%esp
  802032:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802034:	89 d0                	mov    %edx,%eax
  802036:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802039:	5b                   	pop    %ebx
  80203a:	5e                   	pop    %esi
  80203b:	5d                   	pop    %ebp
  80203c:	c3                   	ret    

0080203d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80203d:	55                   	push   %ebp
  80203e:	89 e5                	mov    %esp,%ebp
  802040:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802043:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802046:	50                   	push   %eax
  802047:	ff 75 08             	pushl  0x8(%ebp)
  80204a:	e8 33 ef ff ff       	call   800f82 <fd_lookup>
  80204f:	83 c4 10             	add    $0x10,%esp
  802052:	85 c0                	test   %eax,%eax
  802054:	78 18                	js     80206e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802056:	83 ec 0c             	sub    $0xc,%esp
  802059:	ff 75 f4             	pushl  -0xc(%ebp)
  80205c:	e8 bb ee ff ff       	call   800f1c <fd2data>
	return _pipeisclosed(fd, p);
  802061:	89 c2                	mov    %eax,%edx
  802063:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802066:	e8 21 fd ff ff       	call   801d8c <_pipeisclosed>
  80206b:	83 c4 10             	add    $0x10,%esp
}
  80206e:	c9                   	leave  
  80206f:	c3                   	ret    

00802070 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802073:	b8 00 00 00 00       	mov    $0x0,%eax
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    

0080207a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80207a:	55                   	push   %ebp
  80207b:	89 e5                	mov    %esp,%ebp
  80207d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802080:	68 a5 2b 80 00       	push   $0x802ba5
  802085:	ff 75 0c             	pushl  0xc(%ebp)
  802088:	e8 14 e8 ff ff       	call   8008a1 <strcpy>
	return 0;
}
  80208d:	b8 00 00 00 00       	mov    $0x0,%eax
  802092:	c9                   	leave  
  802093:	c3                   	ret    

00802094 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802094:	55                   	push   %ebp
  802095:	89 e5                	mov    %esp,%ebp
  802097:	57                   	push   %edi
  802098:	56                   	push   %esi
  802099:	53                   	push   %ebx
  80209a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020a0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020a5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020ab:	eb 2d                	jmp    8020da <devcons_write+0x46>
		m = n - tot;
  8020ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020b0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8020b2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020b5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020ba:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020bd:	83 ec 04             	sub    $0x4,%esp
  8020c0:	53                   	push   %ebx
  8020c1:	03 45 0c             	add    0xc(%ebp),%eax
  8020c4:	50                   	push   %eax
  8020c5:	57                   	push   %edi
  8020c6:	e8 68 e9 ff ff       	call   800a33 <memmove>
		sys_cputs(buf, m);
  8020cb:	83 c4 08             	add    $0x8,%esp
  8020ce:	53                   	push   %ebx
  8020cf:	57                   	push   %edi
  8020d0:	e8 8a eb ff ff       	call   800c5f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020d5:	01 de                	add    %ebx,%esi
  8020d7:	83 c4 10             	add    $0x10,%esp
  8020da:	89 f0                	mov    %esi,%eax
  8020dc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020df:	72 cc                	jb     8020ad <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020e4:	5b                   	pop    %ebx
  8020e5:	5e                   	pop    %esi
  8020e6:	5f                   	pop    %edi
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    

008020e9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020e9:	55                   	push   %ebp
  8020ea:	89 e5                	mov    %esp,%ebp
  8020ec:	83 ec 08             	sub    $0x8,%esp
  8020ef:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8020f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020f8:	74 2a                	je     802124 <devcons_read+0x3b>
  8020fa:	eb 05                	jmp    802101 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020fc:	e8 fb eb ff ff       	call   800cfc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802101:	e8 77 eb ff ff       	call   800c7d <sys_cgetc>
  802106:	85 c0                	test   %eax,%eax
  802108:	74 f2                	je     8020fc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80210a:	85 c0                	test   %eax,%eax
  80210c:	78 16                	js     802124 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80210e:	83 f8 04             	cmp    $0x4,%eax
  802111:	74 0c                	je     80211f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802113:	8b 55 0c             	mov    0xc(%ebp),%edx
  802116:	88 02                	mov    %al,(%edx)
	return 1;
  802118:	b8 01 00 00 00       	mov    $0x1,%eax
  80211d:	eb 05                	jmp    802124 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80211f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802124:	c9                   	leave  
  802125:	c3                   	ret    

00802126 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802126:	55                   	push   %ebp
  802127:	89 e5                	mov    %esp,%ebp
  802129:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80212c:	8b 45 08             	mov    0x8(%ebp),%eax
  80212f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802132:	6a 01                	push   $0x1
  802134:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802137:	50                   	push   %eax
  802138:	e8 22 eb ff ff       	call   800c5f <sys_cputs>
}
  80213d:	83 c4 10             	add    $0x10,%esp
  802140:	c9                   	leave  
  802141:	c3                   	ret    

00802142 <getchar>:

int
getchar(void)
{
  802142:	55                   	push   %ebp
  802143:	89 e5                	mov    %esp,%ebp
  802145:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802148:	6a 01                	push   $0x1
  80214a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80214d:	50                   	push   %eax
  80214e:	6a 00                	push   $0x0
  802150:	e8 93 f0 ff ff       	call   8011e8 <read>
	if (r < 0)
  802155:	83 c4 10             	add    $0x10,%esp
  802158:	85 c0                	test   %eax,%eax
  80215a:	78 0f                	js     80216b <getchar+0x29>
		return r;
	if (r < 1)
  80215c:	85 c0                	test   %eax,%eax
  80215e:	7e 06                	jle    802166 <getchar+0x24>
		return -E_EOF;
	return c;
  802160:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802164:	eb 05                	jmp    80216b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802166:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80216b:	c9                   	leave  
  80216c:	c3                   	ret    

0080216d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80216d:	55                   	push   %ebp
  80216e:	89 e5                	mov    %esp,%ebp
  802170:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802173:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802176:	50                   	push   %eax
  802177:	ff 75 08             	pushl  0x8(%ebp)
  80217a:	e8 03 ee ff ff       	call   800f82 <fd_lookup>
  80217f:	83 c4 10             	add    $0x10,%esp
  802182:	85 c0                	test   %eax,%eax
  802184:	78 11                	js     802197 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802186:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802189:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80218f:	39 10                	cmp    %edx,(%eax)
  802191:	0f 94 c0             	sete   %al
  802194:	0f b6 c0             	movzbl %al,%eax
}
  802197:	c9                   	leave  
  802198:	c3                   	ret    

00802199 <opencons>:

int
opencons(void)
{
  802199:	55                   	push   %ebp
  80219a:	89 e5                	mov    %esp,%ebp
  80219c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80219f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a2:	50                   	push   %eax
  8021a3:	e8 8b ed ff ff       	call   800f33 <fd_alloc>
  8021a8:	83 c4 10             	add    $0x10,%esp
		return r;
  8021ab:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021ad:	85 c0                	test   %eax,%eax
  8021af:	78 3e                	js     8021ef <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021b1:	83 ec 04             	sub    $0x4,%esp
  8021b4:	68 07 04 00 00       	push   $0x407
  8021b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8021bc:	6a 00                	push   $0x0
  8021be:	e8 58 eb ff ff       	call   800d1b <sys_page_alloc>
  8021c3:	83 c4 10             	add    $0x10,%esp
		return r;
  8021c6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021c8:	85 c0                	test   %eax,%eax
  8021ca:	78 23                	js     8021ef <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021cc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021da:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021e1:	83 ec 0c             	sub    $0xc,%esp
  8021e4:	50                   	push   %eax
  8021e5:	e8 22 ed ff ff       	call   800f0c <fd2num>
  8021ea:	89 c2                	mov    %eax,%edx
  8021ec:	83 c4 10             	add    $0x10,%esp
}
  8021ef:	89 d0                	mov    %edx,%eax
  8021f1:	c9                   	leave  
  8021f2:	c3                   	ret    

008021f3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021f3:	55                   	push   %ebp
  8021f4:	89 e5                	mov    %esp,%ebp
  8021f6:	56                   	push   %esi
  8021f7:	53                   	push   %ebx
  8021f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8021fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  802201:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802203:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802208:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  80220b:	83 ec 0c             	sub    $0xc,%esp
  80220e:	50                   	push   %eax
  80220f:	e8 b7 ec ff ff       	call   800ecb <sys_ipc_recv>
  802214:	83 c4 10             	add    $0x10,%esp
  802217:	85 c0                	test   %eax,%eax
  802219:	79 16                	jns    802231 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  80221b:	85 f6                	test   %esi,%esi
  80221d:	74 06                	je     802225 <ipc_recv+0x32>
			*from_env_store = 0;
  80221f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  802225:	85 db                	test   %ebx,%ebx
  802227:	74 2c                	je     802255 <ipc_recv+0x62>
			*perm_store = 0;
  802229:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80222f:	eb 24                	jmp    802255 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  802231:	85 f6                	test   %esi,%esi
  802233:	74 0a                	je     80223f <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  802235:	a1 08 40 80 00       	mov    0x804008,%eax
  80223a:	8b 40 74             	mov    0x74(%eax),%eax
  80223d:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80223f:	85 db                	test   %ebx,%ebx
  802241:	74 0a                	je     80224d <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  802243:	a1 08 40 80 00       	mov    0x804008,%eax
  802248:	8b 40 78             	mov    0x78(%eax),%eax
  80224b:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  80224d:	a1 08 40 80 00       	mov    0x804008,%eax
  802252:	8b 40 70             	mov    0x70(%eax),%eax
}
  802255:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802258:	5b                   	pop    %ebx
  802259:	5e                   	pop    %esi
  80225a:	5d                   	pop    %ebp
  80225b:	c3                   	ret    

0080225c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80225c:	55                   	push   %ebp
  80225d:	89 e5                	mov    %esp,%ebp
  80225f:	57                   	push   %edi
  802260:	56                   	push   %esi
  802261:	53                   	push   %ebx
  802262:	83 ec 0c             	sub    $0xc,%esp
  802265:	8b 7d 08             	mov    0x8(%ebp),%edi
  802268:	8b 75 0c             	mov    0xc(%ebp),%esi
  80226b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  80226e:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802270:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802275:	0f 44 d8             	cmove  %eax,%ebx
  802278:	eb 1e                	jmp    802298 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  80227a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80227d:	74 14                	je     802293 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  80227f:	83 ec 04             	sub    $0x4,%esp
  802282:	68 b4 2b 80 00       	push   $0x802bb4
  802287:	6a 44                	push   $0x44
  802289:	68 e0 2b 80 00       	push   $0x802be0
  80228e:	e8 01 df ff ff       	call   800194 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  802293:	e8 64 ea ff ff       	call   800cfc <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802298:	ff 75 14             	pushl  0x14(%ebp)
  80229b:	53                   	push   %ebx
  80229c:	56                   	push   %esi
  80229d:	57                   	push   %edi
  80229e:	e8 05 ec ff ff       	call   800ea8 <sys_ipc_try_send>
  8022a3:	83 c4 10             	add    $0x10,%esp
  8022a6:	85 c0                	test   %eax,%eax
  8022a8:	78 d0                	js     80227a <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  8022aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022ad:	5b                   	pop    %ebx
  8022ae:	5e                   	pop    %esi
  8022af:	5f                   	pop    %edi
  8022b0:	5d                   	pop    %ebp
  8022b1:	c3                   	ret    

008022b2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022b2:	55                   	push   %ebp
  8022b3:	89 e5                	mov    %esp,%ebp
  8022b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022b8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022bd:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022c0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022c6:	8b 52 50             	mov    0x50(%edx),%edx
  8022c9:	39 ca                	cmp    %ecx,%edx
  8022cb:	75 0d                	jne    8022da <ipc_find_env+0x28>
			return envs[i].env_id;
  8022cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022d5:	8b 40 48             	mov    0x48(%eax),%eax
  8022d8:	eb 0f                	jmp    8022e9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022da:	83 c0 01             	add    $0x1,%eax
  8022dd:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022e2:	75 d9                	jne    8022bd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022e9:	5d                   	pop    %ebp
  8022ea:	c3                   	ret    

008022eb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022eb:	55                   	push   %ebp
  8022ec:	89 e5                	mov    %esp,%ebp
  8022ee:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022f1:	89 d0                	mov    %edx,%eax
  8022f3:	c1 e8 16             	shr    $0x16,%eax
  8022f6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022fd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802302:	f6 c1 01             	test   $0x1,%cl
  802305:	74 1d                	je     802324 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802307:	c1 ea 0c             	shr    $0xc,%edx
  80230a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802311:	f6 c2 01             	test   $0x1,%dl
  802314:	74 0e                	je     802324 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802316:	c1 ea 0c             	shr    $0xc,%edx
  802319:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802320:	ef 
  802321:	0f b7 c0             	movzwl %ax,%eax
}
  802324:	5d                   	pop    %ebp
  802325:	c3                   	ret    
  802326:	66 90                	xchg   %ax,%ax
  802328:	66 90                	xchg   %ax,%ax
  80232a:	66 90                	xchg   %ax,%ax
  80232c:	66 90                	xchg   %ax,%ax
  80232e:	66 90                	xchg   %ax,%ax

00802330 <__udivdi3>:
  802330:	55                   	push   %ebp
  802331:	57                   	push   %edi
  802332:	56                   	push   %esi
  802333:	53                   	push   %ebx
  802334:	83 ec 1c             	sub    $0x1c,%esp
  802337:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80233b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80233f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802343:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802347:	85 f6                	test   %esi,%esi
  802349:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80234d:	89 ca                	mov    %ecx,%edx
  80234f:	89 f8                	mov    %edi,%eax
  802351:	75 3d                	jne    802390 <__udivdi3+0x60>
  802353:	39 cf                	cmp    %ecx,%edi
  802355:	0f 87 c5 00 00 00    	ja     802420 <__udivdi3+0xf0>
  80235b:	85 ff                	test   %edi,%edi
  80235d:	89 fd                	mov    %edi,%ebp
  80235f:	75 0b                	jne    80236c <__udivdi3+0x3c>
  802361:	b8 01 00 00 00       	mov    $0x1,%eax
  802366:	31 d2                	xor    %edx,%edx
  802368:	f7 f7                	div    %edi
  80236a:	89 c5                	mov    %eax,%ebp
  80236c:	89 c8                	mov    %ecx,%eax
  80236e:	31 d2                	xor    %edx,%edx
  802370:	f7 f5                	div    %ebp
  802372:	89 c1                	mov    %eax,%ecx
  802374:	89 d8                	mov    %ebx,%eax
  802376:	89 cf                	mov    %ecx,%edi
  802378:	f7 f5                	div    %ebp
  80237a:	89 c3                	mov    %eax,%ebx
  80237c:	89 d8                	mov    %ebx,%eax
  80237e:	89 fa                	mov    %edi,%edx
  802380:	83 c4 1c             	add    $0x1c,%esp
  802383:	5b                   	pop    %ebx
  802384:	5e                   	pop    %esi
  802385:	5f                   	pop    %edi
  802386:	5d                   	pop    %ebp
  802387:	c3                   	ret    
  802388:	90                   	nop
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	39 ce                	cmp    %ecx,%esi
  802392:	77 74                	ja     802408 <__udivdi3+0xd8>
  802394:	0f bd fe             	bsr    %esi,%edi
  802397:	83 f7 1f             	xor    $0x1f,%edi
  80239a:	0f 84 98 00 00 00    	je     802438 <__udivdi3+0x108>
  8023a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023a5:	89 f9                	mov    %edi,%ecx
  8023a7:	89 c5                	mov    %eax,%ebp
  8023a9:	29 fb                	sub    %edi,%ebx
  8023ab:	d3 e6                	shl    %cl,%esi
  8023ad:	89 d9                	mov    %ebx,%ecx
  8023af:	d3 ed                	shr    %cl,%ebp
  8023b1:	89 f9                	mov    %edi,%ecx
  8023b3:	d3 e0                	shl    %cl,%eax
  8023b5:	09 ee                	or     %ebp,%esi
  8023b7:	89 d9                	mov    %ebx,%ecx
  8023b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023bd:	89 d5                	mov    %edx,%ebp
  8023bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023c3:	d3 ed                	shr    %cl,%ebp
  8023c5:	89 f9                	mov    %edi,%ecx
  8023c7:	d3 e2                	shl    %cl,%edx
  8023c9:	89 d9                	mov    %ebx,%ecx
  8023cb:	d3 e8                	shr    %cl,%eax
  8023cd:	09 c2                	or     %eax,%edx
  8023cf:	89 d0                	mov    %edx,%eax
  8023d1:	89 ea                	mov    %ebp,%edx
  8023d3:	f7 f6                	div    %esi
  8023d5:	89 d5                	mov    %edx,%ebp
  8023d7:	89 c3                	mov    %eax,%ebx
  8023d9:	f7 64 24 0c          	mull   0xc(%esp)
  8023dd:	39 d5                	cmp    %edx,%ebp
  8023df:	72 10                	jb     8023f1 <__udivdi3+0xc1>
  8023e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023e5:	89 f9                	mov    %edi,%ecx
  8023e7:	d3 e6                	shl    %cl,%esi
  8023e9:	39 c6                	cmp    %eax,%esi
  8023eb:	73 07                	jae    8023f4 <__udivdi3+0xc4>
  8023ed:	39 d5                	cmp    %edx,%ebp
  8023ef:	75 03                	jne    8023f4 <__udivdi3+0xc4>
  8023f1:	83 eb 01             	sub    $0x1,%ebx
  8023f4:	31 ff                	xor    %edi,%edi
  8023f6:	89 d8                	mov    %ebx,%eax
  8023f8:	89 fa                	mov    %edi,%edx
  8023fa:	83 c4 1c             	add    $0x1c,%esp
  8023fd:	5b                   	pop    %ebx
  8023fe:	5e                   	pop    %esi
  8023ff:	5f                   	pop    %edi
  802400:	5d                   	pop    %ebp
  802401:	c3                   	ret    
  802402:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802408:	31 ff                	xor    %edi,%edi
  80240a:	31 db                	xor    %ebx,%ebx
  80240c:	89 d8                	mov    %ebx,%eax
  80240e:	89 fa                	mov    %edi,%edx
  802410:	83 c4 1c             	add    $0x1c,%esp
  802413:	5b                   	pop    %ebx
  802414:	5e                   	pop    %esi
  802415:	5f                   	pop    %edi
  802416:	5d                   	pop    %ebp
  802417:	c3                   	ret    
  802418:	90                   	nop
  802419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802420:	89 d8                	mov    %ebx,%eax
  802422:	f7 f7                	div    %edi
  802424:	31 ff                	xor    %edi,%edi
  802426:	89 c3                	mov    %eax,%ebx
  802428:	89 d8                	mov    %ebx,%eax
  80242a:	89 fa                	mov    %edi,%edx
  80242c:	83 c4 1c             	add    $0x1c,%esp
  80242f:	5b                   	pop    %ebx
  802430:	5e                   	pop    %esi
  802431:	5f                   	pop    %edi
  802432:	5d                   	pop    %ebp
  802433:	c3                   	ret    
  802434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802438:	39 ce                	cmp    %ecx,%esi
  80243a:	72 0c                	jb     802448 <__udivdi3+0x118>
  80243c:	31 db                	xor    %ebx,%ebx
  80243e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802442:	0f 87 34 ff ff ff    	ja     80237c <__udivdi3+0x4c>
  802448:	bb 01 00 00 00       	mov    $0x1,%ebx
  80244d:	e9 2a ff ff ff       	jmp    80237c <__udivdi3+0x4c>
  802452:	66 90                	xchg   %ax,%ax
  802454:	66 90                	xchg   %ax,%ax
  802456:	66 90                	xchg   %ax,%ax
  802458:	66 90                	xchg   %ax,%ax
  80245a:	66 90                	xchg   %ax,%ax
  80245c:	66 90                	xchg   %ax,%ax
  80245e:	66 90                	xchg   %ax,%ax

00802460 <__umoddi3>:
  802460:	55                   	push   %ebp
  802461:	57                   	push   %edi
  802462:	56                   	push   %esi
  802463:	53                   	push   %ebx
  802464:	83 ec 1c             	sub    $0x1c,%esp
  802467:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80246b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80246f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802473:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802477:	85 d2                	test   %edx,%edx
  802479:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80247d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802481:	89 f3                	mov    %esi,%ebx
  802483:	89 3c 24             	mov    %edi,(%esp)
  802486:	89 74 24 04          	mov    %esi,0x4(%esp)
  80248a:	75 1c                	jne    8024a8 <__umoddi3+0x48>
  80248c:	39 f7                	cmp    %esi,%edi
  80248e:	76 50                	jbe    8024e0 <__umoddi3+0x80>
  802490:	89 c8                	mov    %ecx,%eax
  802492:	89 f2                	mov    %esi,%edx
  802494:	f7 f7                	div    %edi
  802496:	89 d0                	mov    %edx,%eax
  802498:	31 d2                	xor    %edx,%edx
  80249a:	83 c4 1c             	add    $0x1c,%esp
  80249d:	5b                   	pop    %ebx
  80249e:	5e                   	pop    %esi
  80249f:	5f                   	pop    %edi
  8024a0:	5d                   	pop    %ebp
  8024a1:	c3                   	ret    
  8024a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024a8:	39 f2                	cmp    %esi,%edx
  8024aa:	89 d0                	mov    %edx,%eax
  8024ac:	77 52                	ja     802500 <__umoddi3+0xa0>
  8024ae:	0f bd ea             	bsr    %edx,%ebp
  8024b1:	83 f5 1f             	xor    $0x1f,%ebp
  8024b4:	75 5a                	jne    802510 <__umoddi3+0xb0>
  8024b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8024ba:	0f 82 e0 00 00 00    	jb     8025a0 <__umoddi3+0x140>
  8024c0:	39 0c 24             	cmp    %ecx,(%esp)
  8024c3:	0f 86 d7 00 00 00    	jbe    8025a0 <__umoddi3+0x140>
  8024c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024d1:	83 c4 1c             	add    $0x1c,%esp
  8024d4:	5b                   	pop    %ebx
  8024d5:	5e                   	pop    %esi
  8024d6:	5f                   	pop    %edi
  8024d7:	5d                   	pop    %ebp
  8024d8:	c3                   	ret    
  8024d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	85 ff                	test   %edi,%edi
  8024e2:	89 fd                	mov    %edi,%ebp
  8024e4:	75 0b                	jne    8024f1 <__umoddi3+0x91>
  8024e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024eb:	31 d2                	xor    %edx,%edx
  8024ed:	f7 f7                	div    %edi
  8024ef:	89 c5                	mov    %eax,%ebp
  8024f1:	89 f0                	mov    %esi,%eax
  8024f3:	31 d2                	xor    %edx,%edx
  8024f5:	f7 f5                	div    %ebp
  8024f7:	89 c8                	mov    %ecx,%eax
  8024f9:	f7 f5                	div    %ebp
  8024fb:	89 d0                	mov    %edx,%eax
  8024fd:	eb 99                	jmp    802498 <__umoddi3+0x38>
  8024ff:	90                   	nop
  802500:	89 c8                	mov    %ecx,%eax
  802502:	89 f2                	mov    %esi,%edx
  802504:	83 c4 1c             	add    $0x1c,%esp
  802507:	5b                   	pop    %ebx
  802508:	5e                   	pop    %esi
  802509:	5f                   	pop    %edi
  80250a:	5d                   	pop    %ebp
  80250b:	c3                   	ret    
  80250c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802510:	8b 34 24             	mov    (%esp),%esi
  802513:	bf 20 00 00 00       	mov    $0x20,%edi
  802518:	89 e9                	mov    %ebp,%ecx
  80251a:	29 ef                	sub    %ebp,%edi
  80251c:	d3 e0                	shl    %cl,%eax
  80251e:	89 f9                	mov    %edi,%ecx
  802520:	89 f2                	mov    %esi,%edx
  802522:	d3 ea                	shr    %cl,%edx
  802524:	89 e9                	mov    %ebp,%ecx
  802526:	09 c2                	or     %eax,%edx
  802528:	89 d8                	mov    %ebx,%eax
  80252a:	89 14 24             	mov    %edx,(%esp)
  80252d:	89 f2                	mov    %esi,%edx
  80252f:	d3 e2                	shl    %cl,%edx
  802531:	89 f9                	mov    %edi,%ecx
  802533:	89 54 24 04          	mov    %edx,0x4(%esp)
  802537:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80253b:	d3 e8                	shr    %cl,%eax
  80253d:	89 e9                	mov    %ebp,%ecx
  80253f:	89 c6                	mov    %eax,%esi
  802541:	d3 e3                	shl    %cl,%ebx
  802543:	89 f9                	mov    %edi,%ecx
  802545:	89 d0                	mov    %edx,%eax
  802547:	d3 e8                	shr    %cl,%eax
  802549:	89 e9                	mov    %ebp,%ecx
  80254b:	09 d8                	or     %ebx,%eax
  80254d:	89 d3                	mov    %edx,%ebx
  80254f:	89 f2                	mov    %esi,%edx
  802551:	f7 34 24             	divl   (%esp)
  802554:	89 d6                	mov    %edx,%esi
  802556:	d3 e3                	shl    %cl,%ebx
  802558:	f7 64 24 04          	mull   0x4(%esp)
  80255c:	39 d6                	cmp    %edx,%esi
  80255e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802562:	89 d1                	mov    %edx,%ecx
  802564:	89 c3                	mov    %eax,%ebx
  802566:	72 08                	jb     802570 <__umoddi3+0x110>
  802568:	75 11                	jne    80257b <__umoddi3+0x11b>
  80256a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80256e:	73 0b                	jae    80257b <__umoddi3+0x11b>
  802570:	2b 44 24 04          	sub    0x4(%esp),%eax
  802574:	1b 14 24             	sbb    (%esp),%edx
  802577:	89 d1                	mov    %edx,%ecx
  802579:	89 c3                	mov    %eax,%ebx
  80257b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80257f:	29 da                	sub    %ebx,%edx
  802581:	19 ce                	sbb    %ecx,%esi
  802583:	89 f9                	mov    %edi,%ecx
  802585:	89 f0                	mov    %esi,%eax
  802587:	d3 e0                	shl    %cl,%eax
  802589:	89 e9                	mov    %ebp,%ecx
  80258b:	d3 ea                	shr    %cl,%edx
  80258d:	89 e9                	mov    %ebp,%ecx
  80258f:	d3 ee                	shr    %cl,%esi
  802591:	09 d0                	or     %edx,%eax
  802593:	89 f2                	mov    %esi,%edx
  802595:	83 c4 1c             	add    $0x1c,%esp
  802598:	5b                   	pop    %ebx
  802599:	5e                   	pop    %esi
  80259a:	5f                   	pop    %edi
  80259b:	5d                   	pop    %ebp
  80259c:	c3                   	ret    
  80259d:	8d 76 00             	lea    0x0(%esi),%esi
  8025a0:	29 f9                	sub    %edi,%ecx
  8025a2:	19 d6                	sbb    %edx,%esi
  8025a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025ac:	e9 18 ff ff ff       	jmp    8024c9 <__umoddi3+0x69>
