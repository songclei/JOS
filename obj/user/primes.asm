
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 8c 11 00 00       	call   8011d8 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 08 40 80 00       	mov    0x804008,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 60 23 80 00       	push   $0x802360
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 3c 0f 00 00       	call   800fa6 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 1e 27 80 00       	push   $0x80271e
  800079:	6a 1a                	push   $0x1a
  80007b:	68 6c 23 80 00       	push   $0x80236c
  800080:	e8 d3 00 00 00       	call   800158 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 3f 11 00 00       	call   8011d8 <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 91 11 00 00       	call   801241 <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 e7 0e 00 00       	call   800fa6 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 1e 27 80 00       	push   $0x80271e
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 6c 23 80 00       	push   $0x80236c
  8000d2:	e8 81 00 00 00       	call   800158 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 51 11 00 00       	call   801241 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800103:	e8 99 0b 00 00       	call   800ca1 <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800144:	e8 52 13 00 00       	call   80149b <close_all>
	sys_env_destroy(0);
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	6a 00                	push   $0x0
  80014e:	e8 0d 0b 00 00       	call   800c60 <sys_env_destroy>
}
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 36 0b 00 00       	call   800ca1 <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 84 23 80 00       	push   $0x802384
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 c0 28 80 00 	movl   $0x8028c0,(%esp)
  800193:	e8 99 00 00 00       	call   800231 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a8:	8b 13                	mov    (%ebx),%edx
  8001aa:	8d 42 01             	lea    0x1(%edx),%eax
  8001ad:	89 03                	mov    %eax,(%ebx)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	75 1a                	jne    8001d7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	68 ff 00 00 00       	push   $0xff
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 55 0a 00 00       	call   800c23 <sys_cputs>
		b->idx = 0;
  8001ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f0:	00 00 00 
	b.cnt = 0;
  8001f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fd:	ff 75 0c             	pushl  0xc(%ebp)
  800200:	ff 75 08             	pushl  0x8(%ebp)
  800203:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800209:	50                   	push   %eax
  80020a:	68 9e 01 80 00       	push   $0x80019e
  80020f:	e8 54 01 00 00       	call   800368 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800214:	83 c4 08             	add    $0x8,%esp
  800217:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800223:	50                   	push   %eax
  800224:	e8 fa 09 00 00       	call   800c23 <sys_cputs>

	return b.cnt;
}
  800229:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800237:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023a:	50                   	push   %eax
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	e8 9d ff ff ff       	call   8001e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 1c             	sub    $0x1c,%esp
  80024e:	89 c7                	mov    %eax,%edi
  800250:	89 d6                	mov    %edx,%esi
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	8b 55 0c             	mov    0xc(%ebp),%edx
  800258:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800261:	bb 00 00 00 00       	mov    $0x0,%ebx
  800266:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800269:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026c:	39 d3                	cmp    %edx,%ebx
  80026e:	72 05                	jb     800275 <printnum+0x30>
  800270:	39 45 10             	cmp    %eax,0x10(%ebp)
  800273:	77 45                	ja     8002ba <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	ff 75 18             	pushl  0x18(%ebp)
  80027b:	8b 45 14             	mov    0x14(%ebp),%eax
  80027e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800281:	53                   	push   %ebx
  800282:	ff 75 10             	pushl  0x10(%ebp)
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 37 1e 00 00       	call   8020d0 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	89 f8                	mov    %edi,%eax
  8002a2:	e8 9e ff ff ff       	call   800245 <printnum>
  8002a7:	83 c4 20             	add    $0x20,%esp
  8002aa:	eb 18                	jmp    8002c4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	ff 75 18             	pushl  0x18(%ebp)
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	eb 03                	jmp    8002bd <printnum+0x78>
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bd:	83 eb 01             	sub    $0x1,%ebx
  8002c0:	85 db                	test   %ebx,%ebx
  8002c2:	7f e8                	jg     8002ac <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c4:	83 ec 08             	sub    $0x8,%esp
  8002c7:	56                   	push   %esi
  8002c8:	83 ec 04             	sub    $0x4,%esp
  8002cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d7:	e8 24 1f 00 00       	call   802200 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 a7 23 80 00 	movsbl 0x8023a7(%eax),%eax
  8002e6:	50                   	push   %eax
  8002e7:	ff d7                	call   *%edi
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ef:	5b                   	pop    %ebx
  8002f0:	5e                   	pop    %esi
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f7:	83 fa 01             	cmp    $0x1,%edx
  8002fa:	7e 0e                	jle    80030a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 08             	lea    0x8(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	8b 52 04             	mov    0x4(%edx),%edx
  800308:	eb 22                	jmp    80032c <getuint+0x38>
	else if (lflag)
  80030a:	85 d2                	test   %edx,%edx
  80030c:	74 10                	je     80031e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	ba 00 00 00 00       	mov    $0x0,%edx
  80031c:	eb 0e                	jmp    80032c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 04             	lea    0x4(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800334:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	3b 50 04             	cmp    0x4(%eax),%edx
  80033d:	73 0a                	jae    800349 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800342:	89 08                	mov    %ecx,(%eax)
  800344:	8b 45 08             	mov    0x8(%ebp),%eax
  800347:	88 02                	mov    %al,(%edx)
}
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800351:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800354:	50                   	push   %eax
  800355:	ff 75 10             	pushl  0x10(%ebp)
  800358:	ff 75 0c             	pushl  0xc(%ebp)
  80035b:	ff 75 08             	pushl  0x8(%ebp)
  80035e:	e8 05 00 00 00       	call   800368 <vprintfmt>
	va_end(ap);
}
  800363:	83 c4 10             	add    $0x10,%esp
  800366:	c9                   	leave  
  800367:	c3                   	ret    

00800368 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	57                   	push   %edi
  80036c:	56                   	push   %esi
  80036d:	53                   	push   %ebx
  80036e:	83 ec 2c             	sub    $0x2c,%esp
  800371:	8b 75 08             	mov    0x8(%ebp),%esi
  800374:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800377:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037a:	eb 12                	jmp    80038e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037c:	85 c0                	test   %eax,%eax
  80037e:	0f 84 38 04 00 00    	je     8007bc <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	53                   	push   %ebx
  800388:	50                   	push   %eax
  800389:	ff d6                	call   *%esi
  80038b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038e:	83 c7 01             	add    $0x1,%edi
  800391:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800395:	83 f8 25             	cmp    $0x25,%eax
  800398:	75 e2                	jne    80037c <vprintfmt+0x14>
  80039a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80039e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ac:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b8:	eb 07                	jmp    8003c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8d 47 01             	lea    0x1(%edi),%eax
  8003c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c7:	0f b6 07             	movzbl (%edi),%eax
  8003ca:	0f b6 c8             	movzbl %al,%ecx
  8003cd:	83 e8 23             	sub    $0x23,%eax
  8003d0:	3c 55                	cmp    $0x55,%al
  8003d2:	0f 87 c9 03 00 00    	ja     8007a1 <vprintfmt+0x439>
  8003d8:	0f b6 c0             	movzbl %al,%eax
  8003db:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e9:	eb d6                	jmp    8003c1 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  8003eb:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  8003f2:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  8003f8:	eb 94                	jmp    80038e <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  8003fa:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  800401:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  800407:	eb 85                	jmp    80038e <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  800409:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  800410:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  800416:	e9 73 ff ff ff       	jmp    80038e <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  80041b:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  800422:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  800428:	e9 61 ff ff ff       	jmp    80038e <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  80042d:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800434:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  80043a:	e9 4f ff ff ff       	jmp    80038e <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80043f:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800446:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80044c:	e9 3d ff ff ff       	jmp    80038e <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  800451:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  800458:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80045e:	e9 2b ff ff ff       	jmp    80038e <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  800463:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  80046a:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  800470:	e9 19 ff ff ff       	jmp    80038e <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800475:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  80047c:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  800482:	e9 07 ff ff ff       	jmp    80038e <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  800487:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  80048e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800494:	e9 f5 fe ff ff       	jmp    80038e <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004a7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004ab:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004ae:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004b1:	83 fa 09             	cmp    $0x9,%edx
  8004b4:	77 3f                	ja     8004f5 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004b9:	eb e9                	jmp    8004a4 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004be:	8d 48 04             	lea    0x4(%eax),%ecx
  8004c1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004c4:	8b 00                	mov    (%eax),%eax
  8004c6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004cc:	eb 2d                	jmp    8004fb <vprintfmt+0x193>
  8004ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004d8:	0f 49 c8             	cmovns %eax,%ecx
  8004db:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e1:	e9 db fe ff ff       	jmp    8003c1 <vprintfmt+0x59>
  8004e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004e9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004f0:	e9 cc fe ff ff       	jmp    8003c1 <vprintfmt+0x59>
  8004f5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004f8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ff:	0f 89 bc fe ff ff    	jns    8003c1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800505:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800508:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800512:	e9 aa fe ff ff       	jmp    8003c1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800517:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80051d:	e9 9f fe ff ff       	jmp    8003c1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 50 04             	lea    0x4(%eax),%edx
  800528:	89 55 14             	mov    %edx,0x14(%ebp)
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	53                   	push   %ebx
  80052f:	ff 30                	pushl  (%eax)
  800531:	ff d6                	call   *%esi
			break;
  800533:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800536:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800539:	e9 50 fe ff ff       	jmp    80038e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	8d 50 04             	lea    0x4(%eax),%edx
  800544:	89 55 14             	mov    %edx,0x14(%ebp)
  800547:	8b 00                	mov    (%eax),%eax
  800549:	99                   	cltd   
  80054a:	31 d0                	xor    %edx,%eax
  80054c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054e:	83 f8 0f             	cmp    $0xf,%eax
  800551:	7f 0b                	jg     80055e <vprintfmt+0x1f6>
  800553:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  80055a:	85 d2                	test   %edx,%edx
  80055c:	75 18                	jne    800576 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80055e:	50                   	push   %eax
  80055f:	68 bf 23 80 00       	push   $0x8023bf
  800564:	53                   	push   %ebx
  800565:	56                   	push   %esi
  800566:	e8 e0 fd ff ff       	call   80034b <printfmt>
  80056b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800571:	e9 18 fe ff ff       	jmp    80038e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800576:	52                   	push   %edx
  800577:	68 5d 28 80 00       	push   $0x80285d
  80057c:	53                   	push   %ebx
  80057d:	56                   	push   %esi
  80057e:	e8 c8 fd ff ff       	call   80034b <printfmt>
  800583:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800589:	e9 00 fe ff ff       	jmp    80038e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 50 04             	lea    0x4(%eax),%edx
  800594:	89 55 14             	mov    %edx,0x14(%ebp)
  800597:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800599:	85 ff                	test   %edi,%edi
  80059b:	b8 b8 23 80 00       	mov    $0x8023b8,%eax
  8005a0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005a3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a7:	0f 8e 94 00 00 00    	jle    800641 <vprintfmt+0x2d9>
  8005ad:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005b1:	0f 84 98 00 00 00    	je     80064f <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	ff 75 d0             	pushl  -0x30(%ebp)
  8005bd:	57                   	push   %edi
  8005be:	e8 81 02 00 00       	call   800844 <strnlen>
  8005c3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c6:	29 c1                	sub    %eax,%ecx
  8005c8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005cb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005ce:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005d8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005da:	eb 0f                	jmp    8005eb <vprintfmt+0x283>
					putch(padc, putdat);
  8005dc:	83 ec 08             	sub    $0x8,%esp
  8005df:	53                   	push   %ebx
  8005e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e5:	83 ef 01             	sub    $0x1,%edi
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	85 ff                	test   %edi,%edi
  8005ed:	7f ed                	jg     8005dc <vprintfmt+0x274>
  8005ef:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005f2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005f5:	85 c9                	test   %ecx,%ecx
  8005f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005fc:	0f 49 c1             	cmovns %ecx,%eax
  8005ff:	29 c1                	sub    %eax,%ecx
  800601:	89 75 08             	mov    %esi,0x8(%ebp)
  800604:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800607:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80060a:	89 cb                	mov    %ecx,%ebx
  80060c:	eb 4d                	jmp    80065b <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80060e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800612:	74 1b                	je     80062f <vprintfmt+0x2c7>
  800614:	0f be c0             	movsbl %al,%eax
  800617:	83 e8 20             	sub    $0x20,%eax
  80061a:	83 f8 5e             	cmp    $0x5e,%eax
  80061d:	76 10                	jbe    80062f <vprintfmt+0x2c7>
					putch('?', putdat);
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	ff 75 0c             	pushl  0xc(%ebp)
  800625:	6a 3f                	push   $0x3f
  800627:	ff 55 08             	call   *0x8(%ebp)
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	eb 0d                	jmp    80063c <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  80062f:	83 ec 08             	sub    $0x8,%esp
  800632:	ff 75 0c             	pushl  0xc(%ebp)
  800635:	52                   	push   %edx
  800636:	ff 55 08             	call   *0x8(%ebp)
  800639:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063c:	83 eb 01             	sub    $0x1,%ebx
  80063f:	eb 1a                	jmp    80065b <vprintfmt+0x2f3>
  800641:	89 75 08             	mov    %esi,0x8(%ebp)
  800644:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800647:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80064a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80064d:	eb 0c                	jmp    80065b <vprintfmt+0x2f3>
  80064f:	89 75 08             	mov    %esi,0x8(%ebp)
  800652:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800655:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800658:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80065b:	83 c7 01             	add    $0x1,%edi
  80065e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800662:	0f be d0             	movsbl %al,%edx
  800665:	85 d2                	test   %edx,%edx
  800667:	74 23                	je     80068c <vprintfmt+0x324>
  800669:	85 f6                	test   %esi,%esi
  80066b:	78 a1                	js     80060e <vprintfmt+0x2a6>
  80066d:	83 ee 01             	sub    $0x1,%esi
  800670:	79 9c                	jns    80060e <vprintfmt+0x2a6>
  800672:	89 df                	mov    %ebx,%edi
  800674:	8b 75 08             	mov    0x8(%ebp),%esi
  800677:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80067a:	eb 18                	jmp    800694 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 20                	push   $0x20
  800682:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800684:	83 ef 01             	sub    $0x1,%edi
  800687:	83 c4 10             	add    $0x10,%esp
  80068a:	eb 08                	jmp    800694 <vprintfmt+0x32c>
  80068c:	89 df                	mov    %ebx,%edi
  80068e:	8b 75 08             	mov    0x8(%ebp),%esi
  800691:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800694:	85 ff                	test   %edi,%edi
  800696:	7f e4                	jg     80067c <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800698:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069b:	e9 ee fc ff ff       	jmp    80038e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a0:	83 fa 01             	cmp    $0x1,%edx
  8006a3:	7e 16                	jle    8006bb <vprintfmt+0x353>
		return va_arg(*ap, long long);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8d 50 08             	lea    0x8(%eax),%edx
  8006ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ae:	8b 50 04             	mov    0x4(%eax),%edx
  8006b1:	8b 00                	mov    (%eax),%eax
  8006b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006b9:	eb 32                	jmp    8006ed <vprintfmt+0x385>
	else if (lflag)
  8006bb:	85 d2                	test   %edx,%edx
  8006bd:	74 18                	je     8006d7 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8d 50 04             	lea    0x4(%eax),%edx
  8006c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c8:	8b 00                	mov    (%eax),%eax
  8006ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006cd:	89 c1                	mov    %eax,%ecx
  8006cf:	c1 f9 1f             	sar    $0x1f,%ecx
  8006d2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d5:	eb 16                	jmp    8006ed <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8d 50 04             	lea    0x4(%eax),%edx
  8006dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e0:	8b 00                	mov    (%eax),%eax
  8006e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e5:	89 c1                	mov    %eax,%ecx
  8006e7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006f3:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006f8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006fc:	79 6f                	jns    80076d <vprintfmt+0x405>
				putch('-', putdat);
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	53                   	push   %ebx
  800702:	6a 2d                	push   $0x2d
  800704:	ff d6                	call   *%esi
				num = -(long long) num;
  800706:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800709:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80070c:	f7 d8                	neg    %eax
  80070e:	83 d2 00             	adc    $0x0,%edx
  800711:	f7 da                	neg    %edx
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	eb 55                	jmp    80076d <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800718:	8d 45 14             	lea    0x14(%ebp),%eax
  80071b:	e8 d4 fb ff ff       	call   8002f4 <getuint>
			base = 10;
  800720:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800725:	eb 46                	jmp    80076d <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800727:	8d 45 14             	lea    0x14(%ebp),%eax
  80072a:	e8 c5 fb ff ff       	call   8002f4 <getuint>
			base = 8;
  80072f:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800734:	eb 37                	jmp    80076d <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	53                   	push   %ebx
  80073a:	6a 30                	push   $0x30
  80073c:	ff d6                	call   *%esi
			putch('x', putdat);
  80073e:	83 c4 08             	add    $0x8,%esp
  800741:	53                   	push   %ebx
  800742:	6a 78                	push   $0x78
  800744:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800746:	8b 45 14             	mov    0x14(%ebp),%eax
  800749:	8d 50 04             	lea    0x4(%eax),%edx
  80074c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80074f:	8b 00                	mov    (%eax),%eax
  800751:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800756:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800759:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80075e:	eb 0d                	jmp    80076d <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800760:	8d 45 14             	lea    0x14(%ebp),%eax
  800763:	e8 8c fb ff ff       	call   8002f4 <getuint>
			base = 16;
  800768:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80076d:	83 ec 0c             	sub    $0xc,%esp
  800770:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800774:	51                   	push   %ecx
  800775:	ff 75 e0             	pushl  -0x20(%ebp)
  800778:	57                   	push   %edi
  800779:	52                   	push   %edx
  80077a:	50                   	push   %eax
  80077b:	89 da                	mov    %ebx,%edx
  80077d:	89 f0                	mov    %esi,%eax
  80077f:	e8 c1 fa ff ff       	call   800245 <printnum>
			break;
  800784:	83 c4 20             	add    $0x20,%esp
  800787:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80078a:	e9 ff fb ff ff       	jmp    80038e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80078f:	83 ec 08             	sub    $0x8,%esp
  800792:	53                   	push   %ebx
  800793:	51                   	push   %ecx
  800794:	ff d6                	call   *%esi
			break;
  800796:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800799:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80079c:	e9 ed fb ff ff       	jmp    80038e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007a1:	83 ec 08             	sub    $0x8,%esp
  8007a4:	53                   	push   %ebx
  8007a5:	6a 25                	push   $0x25
  8007a7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a9:	83 c4 10             	add    $0x10,%esp
  8007ac:	eb 03                	jmp    8007b1 <vprintfmt+0x449>
  8007ae:	83 ef 01             	sub    $0x1,%edi
  8007b1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007b5:	75 f7                	jne    8007ae <vprintfmt+0x446>
  8007b7:	e9 d2 fb ff ff       	jmp    80038e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007bf:	5b                   	pop    %ebx
  8007c0:	5e                   	pop    %esi
  8007c1:	5f                   	pop    %edi
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	83 ec 18             	sub    $0x18,%esp
  8007ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007d3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007d7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007e1:	85 c0                	test   %eax,%eax
  8007e3:	74 26                	je     80080b <vsnprintf+0x47>
  8007e5:	85 d2                	test   %edx,%edx
  8007e7:	7e 22                	jle    80080b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e9:	ff 75 14             	pushl  0x14(%ebp)
  8007ec:	ff 75 10             	pushl  0x10(%ebp)
  8007ef:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f2:	50                   	push   %eax
  8007f3:	68 2e 03 80 00       	push   $0x80032e
  8007f8:	e8 6b fb ff ff       	call   800368 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800800:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800803:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	eb 05                	jmp    800810 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80080b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800818:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80081b:	50                   	push   %eax
  80081c:	ff 75 10             	pushl  0x10(%ebp)
  80081f:	ff 75 0c             	pushl  0xc(%ebp)
  800822:	ff 75 08             	pushl  0x8(%ebp)
  800825:	e8 9a ff ff ff       	call   8007c4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80082a:	c9                   	leave  
  80082b:	c3                   	ret    

0080082c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800832:	b8 00 00 00 00       	mov    $0x0,%eax
  800837:	eb 03                	jmp    80083c <strlen+0x10>
		n++;
  800839:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80083c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800840:	75 f7                	jne    800839 <strlen+0xd>
		n++;
	return n;
}
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084d:	ba 00 00 00 00       	mov    $0x0,%edx
  800852:	eb 03                	jmp    800857 <strnlen+0x13>
		n++;
  800854:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800857:	39 c2                	cmp    %eax,%edx
  800859:	74 08                	je     800863 <strnlen+0x1f>
  80085b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80085f:	75 f3                	jne    800854 <strnlen+0x10>
  800861:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	53                   	push   %ebx
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80086f:	89 c2                	mov    %eax,%edx
  800871:	83 c2 01             	add    $0x1,%edx
  800874:	83 c1 01             	add    $0x1,%ecx
  800877:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80087b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80087e:	84 db                	test   %bl,%bl
  800880:	75 ef                	jne    800871 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800882:	5b                   	pop    %ebx
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	53                   	push   %ebx
  800889:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80088c:	53                   	push   %ebx
  80088d:	e8 9a ff ff ff       	call   80082c <strlen>
  800892:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800895:	ff 75 0c             	pushl  0xc(%ebp)
  800898:	01 d8                	add    %ebx,%eax
  80089a:	50                   	push   %eax
  80089b:	e8 c5 ff ff ff       	call   800865 <strcpy>
	return dst;
}
  8008a0:	89 d8                	mov    %ebx,%eax
  8008a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a5:	c9                   	leave  
  8008a6:	c3                   	ret    

008008a7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	56                   	push   %esi
  8008ab:	53                   	push   %ebx
  8008ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8008af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b2:	89 f3                	mov    %esi,%ebx
  8008b4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b7:	89 f2                	mov    %esi,%edx
  8008b9:	eb 0f                	jmp    8008ca <strncpy+0x23>
		*dst++ = *src;
  8008bb:	83 c2 01             	add    $0x1,%edx
  8008be:	0f b6 01             	movzbl (%ecx),%eax
  8008c1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c4:	80 39 01             	cmpb   $0x1,(%ecx)
  8008c7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ca:	39 da                	cmp    %ebx,%edx
  8008cc:	75 ed                	jne    8008bb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008ce:	89 f0                	mov    %esi,%eax
  8008d0:	5b                   	pop    %ebx
  8008d1:	5e                   	pop    %esi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	56                   	push   %esi
  8008d8:	53                   	push   %ebx
  8008d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008df:	8b 55 10             	mov    0x10(%ebp),%edx
  8008e2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e4:	85 d2                	test   %edx,%edx
  8008e6:	74 21                	je     800909 <strlcpy+0x35>
  8008e8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008ec:	89 f2                	mov    %esi,%edx
  8008ee:	eb 09                	jmp    8008f9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008f0:	83 c2 01             	add    $0x1,%edx
  8008f3:	83 c1 01             	add    $0x1,%ecx
  8008f6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008f9:	39 c2                	cmp    %eax,%edx
  8008fb:	74 09                	je     800906 <strlcpy+0x32>
  8008fd:	0f b6 19             	movzbl (%ecx),%ebx
  800900:	84 db                	test   %bl,%bl
  800902:	75 ec                	jne    8008f0 <strlcpy+0x1c>
  800904:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800906:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800909:	29 f0                	sub    %esi,%eax
}
  80090b:	5b                   	pop    %ebx
  80090c:	5e                   	pop    %esi
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800915:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800918:	eb 06                	jmp    800920 <strcmp+0x11>
		p++, q++;
  80091a:	83 c1 01             	add    $0x1,%ecx
  80091d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800920:	0f b6 01             	movzbl (%ecx),%eax
  800923:	84 c0                	test   %al,%al
  800925:	74 04                	je     80092b <strcmp+0x1c>
  800927:	3a 02                	cmp    (%edx),%al
  800929:	74 ef                	je     80091a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80092b:	0f b6 c0             	movzbl %al,%eax
  80092e:	0f b6 12             	movzbl (%edx),%edx
  800931:	29 d0                	sub    %edx,%eax
}
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	53                   	push   %ebx
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093f:	89 c3                	mov    %eax,%ebx
  800941:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800944:	eb 06                	jmp    80094c <strncmp+0x17>
		n--, p++, q++;
  800946:	83 c0 01             	add    $0x1,%eax
  800949:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80094c:	39 d8                	cmp    %ebx,%eax
  80094e:	74 15                	je     800965 <strncmp+0x30>
  800950:	0f b6 08             	movzbl (%eax),%ecx
  800953:	84 c9                	test   %cl,%cl
  800955:	74 04                	je     80095b <strncmp+0x26>
  800957:	3a 0a                	cmp    (%edx),%cl
  800959:	74 eb                	je     800946 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80095b:	0f b6 00             	movzbl (%eax),%eax
  80095e:	0f b6 12             	movzbl (%edx),%edx
  800961:	29 d0                	sub    %edx,%eax
  800963:	eb 05                	jmp    80096a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800965:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80096a:	5b                   	pop    %ebx
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800977:	eb 07                	jmp    800980 <strchr+0x13>
		if (*s == c)
  800979:	38 ca                	cmp    %cl,%dl
  80097b:	74 0f                	je     80098c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80097d:	83 c0 01             	add    $0x1,%eax
  800980:	0f b6 10             	movzbl (%eax),%edx
  800983:	84 d2                	test   %dl,%dl
  800985:	75 f2                	jne    800979 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800987:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800998:	eb 03                	jmp    80099d <strfind+0xf>
  80099a:	83 c0 01             	add    $0x1,%eax
  80099d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009a0:	38 ca                	cmp    %cl,%dl
  8009a2:	74 04                	je     8009a8 <strfind+0x1a>
  8009a4:	84 d2                	test   %dl,%dl
  8009a6:	75 f2                	jne    80099a <strfind+0xc>
			break;
	return (char *) s;
}
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	57                   	push   %edi
  8009ae:	56                   	push   %esi
  8009af:	53                   	push   %ebx
  8009b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b6:	85 c9                	test   %ecx,%ecx
  8009b8:	74 36                	je     8009f0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ba:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c0:	75 28                	jne    8009ea <memset+0x40>
  8009c2:	f6 c1 03             	test   $0x3,%cl
  8009c5:	75 23                	jne    8009ea <memset+0x40>
		c &= 0xFF;
  8009c7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009cb:	89 d3                	mov    %edx,%ebx
  8009cd:	c1 e3 08             	shl    $0x8,%ebx
  8009d0:	89 d6                	mov    %edx,%esi
  8009d2:	c1 e6 18             	shl    $0x18,%esi
  8009d5:	89 d0                	mov    %edx,%eax
  8009d7:	c1 e0 10             	shl    $0x10,%eax
  8009da:	09 f0                	or     %esi,%eax
  8009dc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009de:	89 d8                	mov    %ebx,%eax
  8009e0:	09 d0                	or     %edx,%eax
  8009e2:	c1 e9 02             	shr    $0x2,%ecx
  8009e5:	fc                   	cld    
  8009e6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e8:	eb 06                	jmp    8009f0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ed:	fc                   	cld    
  8009ee:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f0:	89 f8                	mov    %edi,%eax
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5f                   	pop    %edi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	57                   	push   %edi
  8009fb:	56                   	push   %esi
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a05:	39 c6                	cmp    %eax,%esi
  800a07:	73 35                	jae    800a3e <memmove+0x47>
  800a09:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a0c:	39 d0                	cmp    %edx,%eax
  800a0e:	73 2e                	jae    800a3e <memmove+0x47>
		s += n;
		d += n;
  800a10:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a13:	89 d6                	mov    %edx,%esi
  800a15:	09 fe                	or     %edi,%esi
  800a17:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a1d:	75 13                	jne    800a32 <memmove+0x3b>
  800a1f:	f6 c1 03             	test   $0x3,%cl
  800a22:	75 0e                	jne    800a32 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a24:	83 ef 04             	sub    $0x4,%edi
  800a27:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a2a:	c1 e9 02             	shr    $0x2,%ecx
  800a2d:	fd                   	std    
  800a2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a30:	eb 09                	jmp    800a3b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a32:	83 ef 01             	sub    $0x1,%edi
  800a35:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a38:	fd                   	std    
  800a39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a3b:	fc                   	cld    
  800a3c:	eb 1d                	jmp    800a5b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3e:	89 f2                	mov    %esi,%edx
  800a40:	09 c2                	or     %eax,%edx
  800a42:	f6 c2 03             	test   $0x3,%dl
  800a45:	75 0f                	jne    800a56 <memmove+0x5f>
  800a47:	f6 c1 03             	test   $0x3,%cl
  800a4a:	75 0a                	jne    800a56 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a4c:	c1 e9 02             	shr    $0x2,%ecx
  800a4f:	89 c7                	mov    %eax,%edi
  800a51:	fc                   	cld    
  800a52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a54:	eb 05                	jmp    800a5b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a56:	89 c7                	mov    %eax,%edi
  800a58:	fc                   	cld    
  800a59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a5b:	5e                   	pop    %esi
  800a5c:	5f                   	pop    %edi
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a62:	ff 75 10             	pushl  0x10(%ebp)
  800a65:	ff 75 0c             	pushl  0xc(%ebp)
  800a68:	ff 75 08             	pushl  0x8(%ebp)
  800a6b:	e8 87 ff ff ff       	call   8009f7 <memmove>
}
  800a70:	c9                   	leave  
  800a71:	c3                   	ret    

00800a72 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	56                   	push   %esi
  800a76:	53                   	push   %ebx
  800a77:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7d:	89 c6                	mov    %eax,%esi
  800a7f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a82:	eb 1a                	jmp    800a9e <memcmp+0x2c>
		if (*s1 != *s2)
  800a84:	0f b6 08             	movzbl (%eax),%ecx
  800a87:	0f b6 1a             	movzbl (%edx),%ebx
  800a8a:	38 d9                	cmp    %bl,%cl
  800a8c:	74 0a                	je     800a98 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a8e:	0f b6 c1             	movzbl %cl,%eax
  800a91:	0f b6 db             	movzbl %bl,%ebx
  800a94:	29 d8                	sub    %ebx,%eax
  800a96:	eb 0f                	jmp    800aa7 <memcmp+0x35>
		s1++, s2++;
  800a98:	83 c0 01             	add    $0x1,%eax
  800a9b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9e:	39 f0                	cmp    %esi,%eax
  800aa0:	75 e2                	jne    800a84 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa7:	5b                   	pop    %ebx
  800aa8:	5e                   	pop    %esi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	53                   	push   %ebx
  800aaf:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ab2:	89 c1                	mov    %eax,%ecx
  800ab4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800abb:	eb 0a                	jmp    800ac7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800abd:	0f b6 10             	movzbl (%eax),%edx
  800ac0:	39 da                	cmp    %ebx,%edx
  800ac2:	74 07                	je     800acb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac4:	83 c0 01             	add    $0x1,%eax
  800ac7:	39 c8                	cmp    %ecx,%eax
  800ac9:	72 f2                	jb     800abd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800acb:	5b                   	pop    %ebx
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	57                   	push   %edi
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
  800ad4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ada:	eb 03                	jmp    800adf <strtol+0x11>
		s++;
  800adc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800adf:	0f b6 01             	movzbl (%ecx),%eax
  800ae2:	3c 20                	cmp    $0x20,%al
  800ae4:	74 f6                	je     800adc <strtol+0xe>
  800ae6:	3c 09                	cmp    $0x9,%al
  800ae8:	74 f2                	je     800adc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aea:	3c 2b                	cmp    $0x2b,%al
  800aec:	75 0a                	jne    800af8 <strtol+0x2a>
		s++;
  800aee:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800af1:	bf 00 00 00 00       	mov    $0x0,%edi
  800af6:	eb 11                	jmp    800b09 <strtol+0x3b>
  800af8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800afd:	3c 2d                	cmp    $0x2d,%al
  800aff:	75 08                	jne    800b09 <strtol+0x3b>
		s++, neg = 1;
  800b01:	83 c1 01             	add    $0x1,%ecx
  800b04:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b09:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b0f:	75 15                	jne    800b26 <strtol+0x58>
  800b11:	80 39 30             	cmpb   $0x30,(%ecx)
  800b14:	75 10                	jne    800b26 <strtol+0x58>
  800b16:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b1a:	75 7c                	jne    800b98 <strtol+0xca>
		s += 2, base = 16;
  800b1c:	83 c1 02             	add    $0x2,%ecx
  800b1f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b24:	eb 16                	jmp    800b3c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b26:	85 db                	test   %ebx,%ebx
  800b28:	75 12                	jne    800b3c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b2a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b2f:	80 39 30             	cmpb   $0x30,(%ecx)
  800b32:	75 08                	jne    800b3c <strtol+0x6e>
		s++, base = 8;
  800b34:	83 c1 01             	add    $0x1,%ecx
  800b37:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b41:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b44:	0f b6 11             	movzbl (%ecx),%edx
  800b47:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b4a:	89 f3                	mov    %esi,%ebx
  800b4c:	80 fb 09             	cmp    $0x9,%bl
  800b4f:	77 08                	ja     800b59 <strtol+0x8b>
			dig = *s - '0';
  800b51:	0f be d2             	movsbl %dl,%edx
  800b54:	83 ea 30             	sub    $0x30,%edx
  800b57:	eb 22                	jmp    800b7b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b59:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b5c:	89 f3                	mov    %esi,%ebx
  800b5e:	80 fb 19             	cmp    $0x19,%bl
  800b61:	77 08                	ja     800b6b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b63:	0f be d2             	movsbl %dl,%edx
  800b66:	83 ea 57             	sub    $0x57,%edx
  800b69:	eb 10                	jmp    800b7b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b6b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b6e:	89 f3                	mov    %esi,%ebx
  800b70:	80 fb 19             	cmp    $0x19,%bl
  800b73:	77 16                	ja     800b8b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b75:	0f be d2             	movsbl %dl,%edx
  800b78:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b7b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b7e:	7d 0b                	jge    800b8b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b80:	83 c1 01             	add    $0x1,%ecx
  800b83:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b87:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b89:	eb b9                	jmp    800b44 <strtol+0x76>

	if (endptr)
  800b8b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b8f:	74 0d                	je     800b9e <strtol+0xd0>
		*endptr = (char *) s;
  800b91:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b94:	89 0e                	mov    %ecx,(%esi)
  800b96:	eb 06                	jmp    800b9e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b98:	85 db                	test   %ebx,%ebx
  800b9a:	74 98                	je     800b34 <strtol+0x66>
  800b9c:	eb 9e                	jmp    800b3c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b9e:	89 c2                	mov    %eax,%edx
  800ba0:	f7 da                	neg    %edx
  800ba2:	85 ff                	test   %edi,%edi
  800ba4:	0f 45 c2             	cmovne %edx,%eax
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	83 ec 04             	sub    $0x4,%esp
  800bb5:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800bb8:	57                   	push   %edi
  800bb9:	e8 6e fc ff ff       	call   80082c <strlen>
  800bbe:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800bc1:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800bc4:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800bc9:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800bce:	eb 46                	jmp    800c16 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800bd0:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800bd4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800bd7:	80 f9 09             	cmp    $0x9,%cl
  800bda:	77 08                	ja     800be4 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800bdc:	0f be d2             	movsbl %dl,%edx
  800bdf:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800be2:	eb 27                	jmp    800c0b <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800be4:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800be7:	80 f9 05             	cmp    $0x5,%cl
  800bea:	77 08                	ja     800bf4 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800bec:	0f be d2             	movsbl %dl,%edx
  800bef:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800bf2:	eb 17                	jmp    800c0b <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800bf4:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800bf7:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800bfa:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800bff:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800c03:	77 06                	ja     800c0b <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800c05:	0f be d2             	movsbl %dl,%edx
  800c08:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800c0b:	0f af ce             	imul   %esi,%ecx
  800c0e:	01 c8                	add    %ecx,%eax
		base *= 16;
  800c10:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800c13:	83 eb 01             	sub    $0x1,%ebx
  800c16:	83 fb 01             	cmp    $0x1,%ebx
  800c19:	7f b5                	jg     800bd0 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c31:	8b 55 08             	mov    0x8(%ebp),%edx
  800c34:	89 c3                	mov    %eax,%ebx
  800c36:	89 c7                	mov    %eax,%edi
  800c38:	89 c6                	mov    %eax,%esi
  800c3a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c47:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800c51:	89 d1                	mov    %edx,%ecx
  800c53:	89 d3                	mov    %edx,%ebx
  800c55:	89 d7                	mov    %edx,%edi
  800c57:	89 d6                	mov    %edx,%esi
  800c59:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c6e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	89 cb                	mov    %ecx,%ebx
  800c78:	89 cf                	mov    %ecx,%edi
  800c7a:	89 ce                	mov    %ecx,%esi
  800c7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	7e 17                	jle    800c99 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c82:	83 ec 0c             	sub    $0xc,%esp
  800c85:	50                   	push   %eax
  800c86:	6a 03                	push   $0x3
  800c88:	68 9f 26 80 00       	push   $0x80269f
  800c8d:	6a 23                	push   $0x23
  800c8f:	68 bc 26 80 00       	push   $0x8026bc
  800c94:	e8 bf f4 ff ff       	call   800158 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cac:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb1:	89 d1                	mov    %edx,%ecx
  800cb3:	89 d3                	mov    %edx,%ebx
  800cb5:	89 d7                	mov    %edx,%edi
  800cb7:	89 d6                	mov    %edx,%esi
  800cb9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <sys_yield>:

void
sys_yield(void)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd0:	89 d1                	mov    %edx,%ecx
  800cd2:	89 d3                	mov    %edx,%ebx
  800cd4:	89 d7                	mov    %edx,%edi
  800cd6:	89 d6                	mov    %edx,%esi
  800cd8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	be 00 00 00 00       	mov    $0x0,%esi
  800ced:	b8 04 00 00 00       	mov    $0x4,%eax
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfb:	89 f7                	mov    %esi,%edi
  800cfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cff:	85 c0                	test   %eax,%eax
  800d01:	7e 17                	jle    800d1a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	6a 04                	push   $0x4
  800d09:	68 9f 26 80 00       	push   $0x80269f
  800d0e:	6a 23                	push   $0x23
  800d10:	68 bc 26 80 00       	push   $0x8026bc
  800d15:	e8 3e f4 ff ff       	call   800158 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2b:	b8 05 00 00 00       	mov    $0x5,%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d39:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3c:	8b 75 18             	mov    0x18(%ebp),%esi
  800d3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d41:	85 c0                	test   %eax,%eax
  800d43:	7e 17                	jle    800d5c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	83 ec 0c             	sub    $0xc,%esp
  800d48:	50                   	push   %eax
  800d49:	6a 05                	push   $0x5
  800d4b:	68 9f 26 80 00       	push   $0x80269f
  800d50:	6a 23                	push   $0x23
  800d52:	68 bc 26 80 00       	push   $0x8026bc
  800d57:	e8 fc f3 ff ff       	call   800158 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
  800d6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d72:	b8 06 00 00 00       	mov    $0x6,%eax
  800d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	89 df                	mov    %ebx,%edi
  800d7f:	89 de                	mov    %ebx,%esi
  800d81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d83:	85 c0                	test   %eax,%eax
  800d85:	7e 17                	jle    800d9e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d87:	83 ec 0c             	sub    $0xc,%esp
  800d8a:	50                   	push   %eax
  800d8b:	6a 06                	push   $0x6
  800d8d:	68 9f 26 80 00       	push   $0x80269f
  800d92:	6a 23                	push   $0x23
  800d94:	68 bc 26 80 00       	push   $0x8026bc
  800d99:	e8 ba f3 ff ff       	call   800158 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
  800dac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db4:	b8 08 00 00 00       	mov    $0x8,%eax
  800db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	89 df                	mov    %ebx,%edi
  800dc1:	89 de                	mov    %ebx,%esi
  800dc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	7e 17                	jle    800de0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc9:	83 ec 0c             	sub    $0xc,%esp
  800dcc:	50                   	push   %eax
  800dcd:	6a 08                	push   $0x8
  800dcf:	68 9f 26 80 00       	push   $0x80269f
  800dd4:	6a 23                	push   $0x23
  800dd6:	68 bc 26 80 00       	push   $0x8026bc
  800ddb:	e8 78 f3 ff ff       	call   800158 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800de0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	57                   	push   %edi
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
  800dee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	89 df                	mov    %ebx,%edi
  800e03:	89 de                	mov    %ebx,%esi
  800e05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e07:	85 c0                	test   %eax,%eax
  800e09:	7e 17                	jle    800e22 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	83 ec 0c             	sub    $0xc,%esp
  800e0e:	50                   	push   %eax
  800e0f:	6a 0a                	push   $0xa
  800e11:	68 9f 26 80 00       	push   $0x80269f
  800e16:	6a 23                	push   $0x23
  800e18:	68 bc 26 80 00       	push   $0x8026bc
  800e1d:	e8 36 f3 ff ff       	call   800158 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
  800e30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e38:	b8 09 00 00 00       	mov    $0x9,%eax
  800e3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e40:	8b 55 08             	mov    0x8(%ebp),%edx
  800e43:	89 df                	mov    %ebx,%edi
  800e45:	89 de                	mov    %ebx,%esi
  800e47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	7e 17                	jle    800e64 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4d:	83 ec 0c             	sub    $0xc,%esp
  800e50:	50                   	push   %eax
  800e51:	6a 09                	push   $0x9
  800e53:	68 9f 26 80 00       	push   $0x80269f
  800e58:	6a 23                	push   $0x23
  800e5a:	68 bc 26 80 00       	push   $0x8026bc
  800e5f:	e8 f4 f2 ff ff       	call   800158 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e67:	5b                   	pop    %ebx
  800e68:	5e                   	pop    %esi
  800e69:	5f                   	pop    %edi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	57                   	push   %edi
  800e70:	56                   	push   %esi
  800e71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e72:	be 00 00 00 00       	mov    $0x0,%esi
  800e77:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e82:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e85:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e88:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e8a:	5b                   	pop    %ebx
  800e8b:	5e                   	pop    %esi
  800e8c:	5f                   	pop    %edi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	57                   	push   %edi
  800e93:	56                   	push   %esi
  800e94:	53                   	push   %ebx
  800e95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e98:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e9d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ea2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea5:	89 cb                	mov    %ecx,%ebx
  800ea7:	89 cf                	mov    %ecx,%edi
  800ea9:	89 ce                	mov    %ecx,%esi
  800eab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7e 17                	jle    800ec8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	50                   	push   %eax
  800eb5:	6a 0d                	push   $0xd
  800eb7:	68 9f 26 80 00       	push   $0x80269f
  800ebc:	6a 23                	push   $0x23
  800ebe:	68 bc 26 80 00       	push   $0x8026bc
  800ec3:	e8 90 f2 ff ff       	call   800158 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ec8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ecb:	5b                   	pop    %ebx
  800ecc:	5e                   	pop    %esi
  800ecd:	5f                   	pop    %edi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	53                   	push   %ebx
  800ed4:	83 ec 04             	sub    $0x4,%esp
  800ed7:	8b 45 08             	mov    0x8(%ebp),%eax

	
	void *addr = (void *) utf->utf_fault_va;
  800eda:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800edc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ee0:	74 11                	je     800ef3 <pgfault+0x23>
  800ee2:	89 d8                	mov    %ebx,%eax
  800ee4:	c1 e8 0c             	shr    $0xc,%eax
  800ee7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eee:	f6 c4 08             	test   $0x8,%ah
  800ef1:	75 14                	jne    800f07 <pgfault+0x37>
		panic("page fault");
  800ef3:	83 ec 04             	sub    $0x4,%esp
  800ef6:	68 ca 26 80 00       	push   $0x8026ca
  800efb:	6a 5b                	push   $0x5b
  800efd:	68 d5 26 80 00       	push   $0x8026d5
  800f02:	e8 51 f2 ff ff       	call   800158 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// allocate a new page and map it at a temporary location
	if((r = sys_page_alloc(0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800f07:	83 ec 04             	sub    $0x4,%esp
  800f0a:	6a 07                	push   $0x7
  800f0c:	68 00 f0 7f 00       	push   $0x7ff000
  800f11:	6a 00                	push   $0x0
  800f13:	e8 c7 fd ff ff       	call   800cdf <sys_page_alloc>
  800f18:	83 c4 10             	add    $0x10,%esp
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	79 12                	jns    800f31 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800f1f:	50                   	push   %eax
  800f20:	68 e0 26 80 00       	push   $0x8026e0
  800f25:	6a 66                	push   $0x66
  800f27:	68 d5 26 80 00       	push   $0x8026d5
  800f2c:	e8 27 f2 ff ff       	call   800158 <_panic>

	// copy date to new page
	//strncpy((char *)PFTEMP, (char *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
	memcpy((void *)PFTEMP, (void *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
  800f31:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f37:	83 ec 04             	sub    $0x4,%esp
  800f3a:	68 00 10 00 00       	push   $0x1000
  800f3f:	53                   	push   %ebx
  800f40:	68 00 f0 7f 00       	push   $0x7ff000
  800f45:	e8 15 fb ff ff       	call   800a5f <memcpy>

	// move the new page to the old page's address
	if((r = sys_page_map(0, (void *)PFTEMP, 0, (void *)
  800f4a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f51:	53                   	push   %ebx
  800f52:	6a 00                	push   $0x0
  800f54:	68 00 f0 7f 00       	push   $0x7ff000
  800f59:	6a 00                	push   $0x0
  800f5b:	e8 c2 fd ff ff       	call   800d22 <sys_page_map>
  800f60:	83 c4 20             	add    $0x20,%esp
  800f63:	85 c0                	test   %eax,%eax
  800f65:	79 12                	jns    800f79 <pgfault+0xa9>
		(ROUNDDOWN(addr, PGSIZE)), PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_map: %e", r);
  800f67:	50                   	push   %eax
  800f68:	68 f3 26 80 00       	push   $0x8026f3
  800f6d:	6a 6f                	push   $0x6f
  800f6f:	68 d5 26 80 00       	push   $0x8026d5
  800f74:	e8 df f1 ff ff       	call   800158 <_panic>

	// unmap page on PFTEMP
	if((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800f79:	83 ec 08             	sub    $0x8,%esp
  800f7c:	68 00 f0 7f 00       	push   $0x7ff000
  800f81:	6a 00                	push   $0x0
  800f83:	e8 dc fd ff ff       	call   800d64 <sys_page_unmap>
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	79 12                	jns    800fa1 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  800f8f:	50                   	push   %eax
  800f90:	68 04 27 80 00       	push   $0x802704
  800f95:	6a 73                	push   $0x73
  800f97:	68 d5 26 80 00       	push   $0x8026d5
  800f9c:	e8 b7 f1 ff ff       	call   800158 <_panic>


}
  800fa1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa4:	c9                   	leave  
  800fa5:	c3                   	ret    

00800fa6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
  800fac:	83 ec 28             	sub    $0x28,%esp

	#ifdef CHALLENGE 
	set_exception_handler(pgfault, T_PGFLT);
	#else
	// set up page fault handler
	set_pgfault_handler(pgfault);
  800faf:	68 d0 0e 80 00       	push   $0x800ed0
  800fb4:	e8 49 10 00 00       	call   802002 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fb9:	b8 07 00 00 00       	mov    $0x7,%eax
  800fbe:	cd 30                	int    $0x30
  800fc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fc3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	#endif

	// create a child
	envid = sys_exofork();
	if (envid < 0)
  800fc6:	83 c4 10             	add    $0x10,%esp
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	79 15                	jns    800fe2 <fork+0x3c>
		panic("sys_exofork: %e", envid);
  800fcd:	50                   	push   %eax
  800fce:	68 17 27 80 00       	push   $0x802717
  800fd3:	68 d0 00 00 00       	push   $0xd0
  800fd8:	68 d5 26 80 00       	push   $0x8026d5
  800fdd:	e8 76 f1 ff ff       	call   800158 <_panic>
  800fe2:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800fe7:	be 00 08 00 00       	mov    $0x800,%esi
	// we are the child
	if(envid == 0) {
  800fec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ff0:	75 21                	jne    801013 <fork+0x6d>
		// the copied valude of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800ff2:	e8 aa fc ff ff       	call   800ca1 <sys_getenvid>
  800ff7:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ffc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fff:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801004:	a3 08 40 80 00       	mov    %eax,0x804008
		/*// alloc exception stack
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
			PTE_P | PTE_U | PTE_W)) < 0)
			panic("sys_page_alloc: %e", r);*/

		return 0;
  801009:	b8 00 00 00 00       	mov    $0x0,%eax
  80100e:	e9 a3 01 00 00       	jmp    8011b6 <fork+0x210>
{
	int r;

	// LAB 4: Your code here.
	
	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P))
  801013:	89 d8                	mov    %ebx,%eax
  801015:	c1 e8 16             	shr    $0x16,%eax
  801018:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80101f:	a8 01                	test   $0x1,%al
  801021:	0f 84 f0 00 00 00    	je     801117 <fork+0x171>
		return 0;

	// virtual page pn's page table entry
	pte_t pe = uvpt[pn];
  801027:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi


	if((pe & PTE_P) && (pe & PTE_U)) {
  80102e:	89 f8                	mov    %edi,%eax
  801030:	83 e0 05             	and    $0x5,%eax
  801033:	83 f8 05             	cmp    $0x5,%eax
  801036:	0f 85 db 00 00 00    	jne    801117 <fork+0x171>
		// share with the child environment 
		if(pe & PTE_SHARE) {
  80103c:	f7 c7 00 04 00 00    	test   $0x400,%edi
  801042:	74 36                	je     80107a <fork+0xd4>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  801044:	83 ec 0c             	sub    $0xc,%esp
  801047:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  80104d:	57                   	push   %edi
  80104e:	53                   	push   %ebx
  80104f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801052:	53                   	push   %ebx
  801053:	6a 00                	push   $0x0
  801055:	e8 c8 fc ff ff       	call   800d22 <sys_page_map>
  80105a:	83 c4 20             	add    $0x20,%esp
  80105d:	85 c0                	test   %eax,%eax
  80105f:	0f 89 b2 00 00 00    	jns    801117 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  801065:	50                   	push   %eax
  801066:	68 27 27 80 00       	push   $0x802727
  80106b:	68 97 00 00 00       	push   $0x97
  801070:	68 d5 26 80 00       	push   $0x8026d5
  801075:	e8 de f0 ff ff       	call   800158 <_panic>
		}
		// the page is writable or copy-on-write
		else if((pe & PTE_W) || (pe & PTE_COW)) {
  80107a:	f7 c7 02 08 00 00    	test   $0x802,%edi
  801080:	74 63                	je     8010e5 <fork+0x13f>
			// create the child mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, 
  801082:	81 e7 05 06 00 00    	and    $0x605,%edi
  801088:	81 cf 00 08 00 00    	or     $0x800,%edi
  80108e:	83 ec 0c             	sub    $0xc,%esp
  801091:	57                   	push   %edi
  801092:	53                   	push   %ebx
  801093:	ff 75 e4             	pushl  -0x1c(%ebp)
  801096:	53                   	push   %ebx
  801097:	6a 00                	push   $0x0
  801099:	e8 84 fc ff ff       	call   800d22 <sys_page_map>
  80109e:	83 c4 20             	add    $0x20,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	79 15                	jns    8010ba <fork+0x114>
				(void *)(pn*PGSIZE), (pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  8010a5:	50                   	push   %eax
  8010a6:	68 27 27 80 00       	push   $0x802727
  8010ab:	68 9e 00 00 00       	push   $0x9e
  8010b0:	68 d5 26 80 00       	push   $0x8026d5
  8010b5:	e8 9e f0 ff ff       	call   800158 <_panic>
			// map the parent mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE),
  8010ba:	83 ec 0c             	sub    $0xc,%esp
  8010bd:	57                   	push   %edi
  8010be:	53                   	push   %ebx
  8010bf:	6a 00                	push   $0x0
  8010c1:	53                   	push   %ebx
  8010c2:	6a 00                	push   $0x0
  8010c4:	e8 59 fc ff ff       	call   800d22 <sys_page_map>
  8010c9:	83 c4 20             	add    $0x20,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	79 47                	jns    801117 <fork+0x171>
				(pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  8010d0:	50                   	push   %eax
  8010d1:	68 27 27 80 00       	push   $0x802727
  8010d6:	68 a2 00 00 00       	push   $0xa2
  8010db:	68 d5 26 80 00       	push   $0x8026d5
  8010e0:	e8 73 f0 ff ff       	call   800158 <_panic>
		}	
		else {
			// create the child mapping read only
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  8010e5:	83 ec 0c             	sub    $0xc,%esp
  8010e8:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  8010ee:	57                   	push   %edi
  8010ef:	53                   	push   %ebx
  8010f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f3:	53                   	push   %ebx
  8010f4:	6a 00                	push   $0x0
  8010f6:	e8 27 fc ff ff       	call   800d22 <sys_page_map>
  8010fb:	83 c4 20             	add    $0x20,%esp
  8010fe:	85 c0                	test   %eax,%eax
  801100:	79 15                	jns    801117 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  801102:	50                   	push   %eax
  801103:	68 27 27 80 00       	push   $0x802727
  801108:	68 a8 00 00 00       	push   $0xa8
  80110d:	68 d5 26 80 00       	push   $0x8026d5
  801112:	e8 41 f0 ff ff       	call   800158 <_panic>
			panic("sys_page_alloc: %e", r);*/

		return 0;
	}
	// copy address to child environment's page dirctory
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn)
  801117:	83 c6 01             	add    $0x1,%esi
  80111a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801120:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801126:	0f 85 e7 fe ff ff    	jne    801013 <fork+0x6d>
	#ifdef CHALLENGE 
	if((r = sys_env_set_exception_upcall(envid, thisenv->env_exception_upcall)) < 0)
		panic("sys_env_set_exception_upcall: %e", r);
	#else
	// set child's page fault handler
	if((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  80112c:	a1 08 40 80 00       	mov    0x804008,%eax
  801131:	8b 40 64             	mov    0x64(%eax),%eax
  801134:	83 ec 08             	sub    $0x8,%esp
  801137:	50                   	push   %eax
  801138:	ff 75 e0             	pushl  -0x20(%ebp)
  80113b:	e8 ea fc ff ff       	call   800e2a <sys_env_set_pgfault_upcall>
  801140:	83 c4 10             	add    $0x10,%esp
  801143:	85 c0                	test   %eax,%eax
  801145:	79 15                	jns    80115c <fork+0x1b6>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801147:	50                   	push   %eax
  801148:	68 60 27 80 00       	push   $0x802760
  80114d:	68 e9 00 00 00       	push   $0xe9
  801152:	68 d5 26 80 00       	push   $0x8026d5
  801157:	e8 fc ef ff ff       	call   800158 <_panic>
	#endif

	// alloc exception stack for child environment
	if((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), 
  80115c:	83 ec 04             	sub    $0x4,%esp
  80115f:	6a 07                	push   $0x7
  801161:	68 00 f0 bf ee       	push   $0xeebff000
  801166:	ff 75 e0             	pushl  -0x20(%ebp)
  801169:	e8 71 fb ff ff       	call   800cdf <sys_page_alloc>
  80116e:	83 c4 10             	add    $0x10,%esp
  801171:	85 c0                	test   %eax,%eax
  801173:	79 15                	jns    80118a <fork+0x1e4>
		PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
  801175:	50                   	push   %eax
  801176:	68 e0 26 80 00       	push   $0x8026e0
  80117b:	68 ef 00 00 00       	push   $0xef
  801180:	68 d5 26 80 00       	push   $0x8026d5
  801185:	e8 ce ef ff ff       	call   800158 <_panic>

	// start the child environment running
	if((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80118a:	83 ec 08             	sub    $0x8,%esp
  80118d:	6a 02                	push   $0x2
  80118f:	ff 75 e0             	pushl  -0x20(%ebp)
  801192:	e8 0f fc ff ff       	call   800da6 <sys_env_set_status>
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	85 c0                	test   %eax,%eax
  80119c:	79 15                	jns    8011b3 <fork+0x20d>
		panic("sys_env_set_status: %e", r);
  80119e:	50                   	push   %eax
  80119f:	68 33 27 80 00       	push   $0x802733
  8011a4:	68 f3 00 00 00       	push   $0xf3
  8011a9:	68 d5 26 80 00       	push   $0x8026d5
  8011ae:	e8 a5 ef ff ff       	call   800158 <_panic>

	return envid;
  8011b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  8011b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b9:	5b                   	pop    %ebx
  8011ba:	5e                   	pop    %esi
  8011bb:	5f                   	pop    %edi
  8011bc:	5d                   	pop    %ebp
  8011bd:	c3                   	ret    

008011be <sfork>:

// Challenge!
int
sfork(void)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011c4:	68 4a 27 80 00       	push   $0x80274a
  8011c9:	68 fc 00 00 00       	push   $0xfc
  8011ce:	68 d5 26 80 00       	push   $0x8026d5
  8011d3:	e8 80 ef ff ff       	call   800158 <_panic>

008011d8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	56                   	push   %esi
  8011dc:	53                   	push   %ebx
  8011dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  8011e6:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8011e8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8011ed:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  8011f0:	83 ec 0c             	sub    $0xc,%esp
  8011f3:	50                   	push   %eax
  8011f4:	e8 96 fc ff ff       	call   800e8f <sys_ipc_recv>
  8011f9:	83 c4 10             	add    $0x10,%esp
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	79 16                	jns    801216 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801200:	85 f6                	test   %esi,%esi
  801202:	74 06                	je     80120a <ipc_recv+0x32>
			*from_env_store = 0;
  801204:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  80120a:	85 db                	test   %ebx,%ebx
  80120c:	74 2c                	je     80123a <ipc_recv+0x62>
			*perm_store = 0;
  80120e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801214:	eb 24                	jmp    80123a <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801216:	85 f6                	test   %esi,%esi
  801218:	74 0a                	je     801224 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  80121a:	a1 08 40 80 00       	mov    0x804008,%eax
  80121f:	8b 40 74             	mov    0x74(%eax),%eax
  801222:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801224:	85 db                	test   %ebx,%ebx
  801226:	74 0a                	je     801232 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801228:	a1 08 40 80 00       	mov    0x804008,%eax
  80122d:	8b 40 78             	mov    0x78(%eax),%eax
  801230:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801232:	a1 08 40 80 00       	mov    0x804008,%eax
  801237:	8b 40 70             	mov    0x70(%eax),%eax
}
  80123a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80123d:	5b                   	pop    %ebx
  80123e:	5e                   	pop    %esi
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	57                   	push   %edi
  801245:	56                   	push   %esi
  801246:	53                   	push   %ebx
  801247:	83 ec 0c             	sub    $0xc,%esp
  80124a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80124d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801250:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801253:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801255:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80125a:	0f 44 d8             	cmove  %eax,%ebx
  80125d:	eb 1e                	jmp    80127d <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  80125f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801262:	74 14                	je     801278 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801264:	83 ec 04             	sub    $0x4,%esp
  801267:	68 80 27 80 00       	push   $0x802780
  80126c:	6a 44                	push   $0x44
  80126e:	68 ab 27 80 00       	push   $0x8027ab
  801273:	e8 e0 ee ff ff       	call   800158 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801278:	e8 43 fa ff ff       	call   800cc0 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80127d:	ff 75 14             	pushl  0x14(%ebp)
  801280:	53                   	push   %ebx
  801281:	56                   	push   %esi
  801282:	57                   	push   %edi
  801283:	e8 e4 fb ff ff       	call   800e6c <sys_ipc_try_send>
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	85 c0                	test   %eax,%eax
  80128d:	78 d0                	js     80125f <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  80128f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801292:	5b                   	pop    %ebx
  801293:	5e                   	pop    %esi
  801294:	5f                   	pop    %edi
  801295:	5d                   	pop    %ebp
  801296:	c3                   	ret    

00801297 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80129d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012a2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012a5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012ab:	8b 52 50             	mov    0x50(%edx),%edx
  8012ae:	39 ca                	cmp    %ecx,%edx
  8012b0:	75 0d                	jne    8012bf <ipc_find_env+0x28>
			return envs[i].env_id;
  8012b2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012b5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012ba:	8b 40 48             	mov    0x48(%eax),%eax
  8012bd:	eb 0f                	jmp    8012ce <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012bf:	83 c0 01             	add    $0x1,%eax
  8012c2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012c7:	75 d9                	jne    8012a2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ce:	5d                   	pop    %ebp
  8012cf:	c3                   	ret    

008012d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8012db:	c1 e8 0c             	shr    $0xc,%eax
}
  8012de:	5d                   	pop    %ebp
  8012df:	c3                   	ret    

008012e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8012eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012f0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012f5:	5d                   	pop    %ebp
  8012f6:	c3                   	ret    

008012f7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012fd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801302:	89 c2                	mov    %eax,%edx
  801304:	c1 ea 16             	shr    $0x16,%edx
  801307:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80130e:	f6 c2 01             	test   $0x1,%dl
  801311:	74 11                	je     801324 <fd_alloc+0x2d>
  801313:	89 c2                	mov    %eax,%edx
  801315:	c1 ea 0c             	shr    $0xc,%edx
  801318:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80131f:	f6 c2 01             	test   $0x1,%dl
  801322:	75 09                	jne    80132d <fd_alloc+0x36>
			*fd_store = fd;
  801324:	89 01                	mov    %eax,(%ecx)
			return 0;
  801326:	b8 00 00 00 00       	mov    $0x0,%eax
  80132b:	eb 17                	jmp    801344 <fd_alloc+0x4d>
  80132d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801332:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801337:	75 c9                	jne    801302 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801339:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80133f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    

00801346 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80134c:	83 f8 1f             	cmp    $0x1f,%eax
  80134f:	77 36                	ja     801387 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801351:	c1 e0 0c             	shl    $0xc,%eax
  801354:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801359:	89 c2                	mov    %eax,%edx
  80135b:	c1 ea 16             	shr    $0x16,%edx
  80135e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801365:	f6 c2 01             	test   $0x1,%dl
  801368:	74 24                	je     80138e <fd_lookup+0x48>
  80136a:	89 c2                	mov    %eax,%edx
  80136c:	c1 ea 0c             	shr    $0xc,%edx
  80136f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801376:	f6 c2 01             	test   $0x1,%dl
  801379:	74 1a                	je     801395 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80137b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137e:	89 02                	mov    %eax,(%edx)
	return 0;
  801380:	b8 00 00 00 00       	mov    $0x0,%eax
  801385:	eb 13                	jmp    80139a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801387:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138c:	eb 0c                	jmp    80139a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80138e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801393:	eb 05                	jmp    80139a <fd_lookup+0x54>
  801395:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80139a:	5d                   	pop    %ebp
  80139b:	c3                   	ret    

0080139c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	83 ec 08             	sub    $0x8,%esp
  8013a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013a5:	ba 34 28 80 00       	mov    $0x802834,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013aa:	eb 13                	jmp    8013bf <dev_lookup+0x23>
  8013ac:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013af:	39 08                	cmp    %ecx,(%eax)
  8013b1:	75 0c                	jne    8013bf <dev_lookup+0x23>
			*dev = devtab[i];
  8013b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013bd:	eb 2e                	jmp    8013ed <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013bf:	8b 02                	mov    (%edx),%eax
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	75 e7                	jne    8013ac <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013c5:	a1 08 40 80 00       	mov    0x804008,%eax
  8013ca:	8b 40 48             	mov    0x48(%eax),%eax
  8013cd:	83 ec 04             	sub    $0x4,%esp
  8013d0:	51                   	push   %ecx
  8013d1:	50                   	push   %eax
  8013d2:	68 b8 27 80 00       	push   $0x8027b8
  8013d7:	e8 55 ee ff ff       	call   800231 <cprintf>
	*dev = 0;
  8013dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013ed:	c9                   	leave  
  8013ee:	c3                   	ret    

008013ef <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	56                   	push   %esi
  8013f3:	53                   	push   %ebx
  8013f4:	83 ec 10             	sub    $0x10,%esp
  8013f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8013fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801400:	50                   	push   %eax
  801401:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801407:	c1 e8 0c             	shr    $0xc,%eax
  80140a:	50                   	push   %eax
  80140b:	e8 36 ff ff ff       	call   801346 <fd_lookup>
  801410:	83 c4 08             	add    $0x8,%esp
  801413:	85 c0                	test   %eax,%eax
  801415:	78 05                	js     80141c <fd_close+0x2d>
	    || fd != fd2) 
  801417:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80141a:	74 0c                	je     801428 <fd_close+0x39>
		return (must_exist ? r : 0); 
  80141c:	84 db                	test   %bl,%bl
  80141e:	ba 00 00 00 00       	mov    $0x0,%edx
  801423:	0f 44 c2             	cmove  %edx,%eax
  801426:	eb 41                	jmp    801469 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142e:	50                   	push   %eax
  80142f:	ff 36                	pushl  (%esi)
  801431:	e8 66 ff ff ff       	call   80139c <dev_lookup>
  801436:	89 c3                	mov    %eax,%ebx
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 1a                	js     801459 <fd_close+0x6a>
		if (dev->dev_close) 
  80143f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801442:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  801445:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  80144a:	85 c0                	test   %eax,%eax
  80144c:	74 0b                	je     801459 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80144e:	83 ec 0c             	sub    $0xc,%esp
  801451:	56                   	push   %esi
  801452:	ff d0                	call   *%eax
  801454:	89 c3                	mov    %eax,%ebx
  801456:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801459:	83 ec 08             	sub    $0x8,%esp
  80145c:	56                   	push   %esi
  80145d:	6a 00                	push   $0x0
  80145f:	e8 00 f9 ff ff       	call   800d64 <sys_page_unmap>
	return r;
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	89 d8                	mov    %ebx,%eax
}
  801469:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146c:	5b                   	pop    %ebx
  80146d:	5e                   	pop    %esi
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801476:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801479:	50                   	push   %eax
  80147a:	ff 75 08             	pushl  0x8(%ebp)
  80147d:	e8 c4 fe ff ff       	call   801346 <fd_lookup>
  801482:	83 c4 08             	add    $0x8,%esp
  801485:	85 c0                	test   %eax,%eax
  801487:	78 10                	js     801499 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  801489:	83 ec 08             	sub    $0x8,%esp
  80148c:	6a 01                	push   $0x1
  80148e:	ff 75 f4             	pushl  -0xc(%ebp)
  801491:	e8 59 ff ff ff       	call   8013ef <fd_close>
  801496:	83 c4 10             	add    $0x10,%esp
}
  801499:	c9                   	leave  
  80149a:	c3                   	ret    

0080149b <close_all>:

void
close_all(void)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	53                   	push   %ebx
  80149f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014a2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014a7:	83 ec 0c             	sub    $0xc,%esp
  8014aa:	53                   	push   %ebx
  8014ab:	e8 c0 ff ff ff       	call   801470 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014b0:	83 c3 01             	add    $0x1,%ebx
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	83 fb 20             	cmp    $0x20,%ebx
  8014b9:	75 ec                	jne    8014a7 <close_all+0xc>
		close(i);
}
  8014bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014be:	c9                   	leave  
  8014bf:	c3                   	ret    

008014c0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	57                   	push   %edi
  8014c4:	56                   	push   %esi
  8014c5:	53                   	push   %ebx
  8014c6:	83 ec 2c             	sub    $0x2c,%esp
  8014c9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014cf:	50                   	push   %eax
  8014d0:	ff 75 08             	pushl  0x8(%ebp)
  8014d3:	e8 6e fe ff ff       	call   801346 <fd_lookup>
  8014d8:	83 c4 08             	add    $0x8,%esp
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	0f 88 c1 00 00 00    	js     8015a4 <dup+0xe4>
		return r;
	close(newfdnum);
  8014e3:	83 ec 0c             	sub    $0xc,%esp
  8014e6:	56                   	push   %esi
  8014e7:	e8 84 ff ff ff       	call   801470 <close>

	newfd = INDEX2FD(newfdnum);
  8014ec:	89 f3                	mov    %esi,%ebx
  8014ee:	c1 e3 0c             	shl    $0xc,%ebx
  8014f1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014f7:	83 c4 04             	add    $0x4,%esp
  8014fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014fd:	e8 de fd ff ff       	call   8012e0 <fd2data>
  801502:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801504:	89 1c 24             	mov    %ebx,(%esp)
  801507:	e8 d4 fd ff ff       	call   8012e0 <fd2data>
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801512:	89 f8                	mov    %edi,%eax
  801514:	c1 e8 16             	shr    $0x16,%eax
  801517:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80151e:	a8 01                	test   $0x1,%al
  801520:	74 37                	je     801559 <dup+0x99>
  801522:	89 f8                	mov    %edi,%eax
  801524:	c1 e8 0c             	shr    $0xc,%eax
  801527:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80152e:	f6 c2 01             	test   $0x1,%dl
  801531:	74 26                	je     801559 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801533:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80153a:	83 ec 0c             	sub    $0xc,%esp
  80153d:	25 07 0e 00 00       	and    $0xe07,%eax
  801542:	50                   	push   %eax
  801543:	ff 75 d4             	pushl  -0x2c(%ebp)
  801546:	6a 00                	push   $0x0
  801548:	57                   	push   %edi
  801549:	6a 00                	push   $0x0
  80154b:	e8 d2 f7 ff ff       	call   800d22 <sys_page_map>
  801550:	89 c7                	mov    %eax,%edi
  801552:	83 c4 20             	add    $0x20,%esp
  801555:	85 c0                	test   %eax,%eax
  801557:	78 2e                	js     801587 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801559:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80155c:	89 d0                	mov    %edx,%eax
  80155e:	c1 e8 0c             	shr    $0xc,%eax
  801561:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801568:	83 ec 0c             	sub    $0xc,%esp
  80156b:	25 07 0e 00 00       	and    $0xe07,%eax
  801570:	50                   	push   %eax
  801571:	53                   	push   %ebx
  801572:	6a 00                	push   $0x0
  801574:	52                   	push   %edx
  801575:	6a 00                	push   $0x0
  801577:	e8 a6 f7 ff ff       	call   800d22 <sys_page_map>
  80157c:	89 c7                	mov    %eax,%edi
  80157e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801581:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801583:	85 ff                	test   %edi,%edi
  801585:	79 1d                	jns    8015a4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801587:	83 ec 08             	sub    $0x8,%esp
  80158a:	53                   	push   %ebx
  80158b:	6a 00                	push   $0x0
  80158d:	e8 d2 f7 ff ff       	call   800d64 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801592:	83 c4 08             	add    $0x8,%esp
  801595:	ff 75 d4             	pushl  -0x2c(%ebp)
  801598:	6a 00                	push   $0x0
  80159a:	e8 c5 f7 ff ff       	call   800d64 <sys_page_unmap>
	return r;
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	89 f8                	mov    %edi,%eax
}
  8015a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a7:	5b                   	pop    %ebx
  8015a8:	5e                   	pop    %esi
  8015a9:	5f                   	pop    %edi
  8015aa:	5d                   	pop    %ebp
  8015ab:	c3                   	ret    

008015ac <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	53                   	push   %ebx
  8015b0:	83 ec 14             	sub    $0x14,%esp
  8015b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	53                   	push   %ebx
  8015bb:	e8 86 fd ff ff       	call   801346 <fd_lookup>
  8015c0:	83 c4 08             	add    $0x8,%esp
  8015c3:	89 c2                	mov    %eax,%edx
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	78 6d                	js     801636 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c9:	83 ec 08             	sub    $0x8,%esp
  8015cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cf:	50                   	push   %eax
  8015d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d3:	ff 30                	pushl  (%eax)
  8015d5:	e8 c2 fd ff ff       	call   80139c <dev_lookup>
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	78 4c                	js     80162d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015e4:	8b 42 08             	mov    0x8(%edx),%eax
  8015e7:	83 e0 03             	and    $0x3,%eax
  8015ea:	83 f8 01             	cmp    $0x1,%eax
  8015ed:	75 21                	jne    801610 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ef:	a1 08 40 80 00       	mov    0x804008,%eax
  8015f4:	8b 40 48             	mov    0x48(%eax),%eax
  8015f7:	83 ec 04             	sub    $0x4,%esp
  8015fa:	53                   	push   %ebx
  8015fb:	50                   	push   %eax
  8015fc:	68 f9 27 80 00       	push   $0x8027f9
  801601:	e8 2b ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80160e:	eb 26                	jmp    801636 <read+0x8a>
	}
	if (!dev->dev_read)
  801610:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801613:	8b 40 08             	mov    0x8(%eax),%eax
  801616:	85 c0                	test   %eax,%eax
  801618:	74 17                	je     801631 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80161a:	83 ec 04             	sub    $0x4,%esp
  80161d:	ff 75 10             	pushl  0x10(%ebp)
  801620:	ff 75 0c             	pushl  0xc(%ebp)
  801623:	52                   	push   %edx
  801624:	ff d0                	call   *%eax
  801626:	89 c2                	mov    %eax,%edx
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	eb 09                	jmp    801636 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162d:	89 c2                	mov    %eax,%edx
  80162f:	eb 05                	jmp    801636 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801631:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801636:	89 d0                	mov    %edx,%eax
  801638:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163b:	c9                   	leave  
  80163c:	c3                   	ret    

0080163d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	57                   	push   %edi
  801641:	56                   	push   %esi
  801642:	53                   	push   %ebx
  801643:	83 ec 0c             	sub    $0xc,%esp
  801646:	8b 7d 08             	mov    0x8(%ebp),%edi
  801649:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80164c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801651:	eb 21                	jmp    801674 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801653:	83 ec 04             	sub    $0x4,%esp
  801656:	89 f0                	mov    %esi,%eax
  801658:	29 d8                	sub    %ebx,%eax
  80165a:	50                   	push   %eax
  80165b:	89 d8                	mov    %ebx,%eax
  80165d:	03 45 0c             	add    0xc(%ebp),%eax
  801660:	50                   	push   %eax
  801661:	57                   	push   %edi
  801662:	e8 45 ff ff ff       	call   8015ac <read>
		if (m < 0)
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	85 c0                	test   %eax,%eax
  80166c:	78 10                	js     80167e <readn+0x41>
			return m;
		if (m == 0)
  80166e:	85 c0                	test   %eax,%eax
  801670:	74 0a                	je     80167c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801672:	01 c3                	add    %eax,%ebx
  801674:	39 f3                	cmp    %esi,%ebx
  801676:	72 db                	jb     801653 <readn+0x16>
  801678:	89 d8                	mov    %ebx,%eax
  80167a:	eb 02                	jmp    80167e <readn+0x41>
  80167c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80167e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801681:	5b                   	pop    %ebx
  801682:	5e                   	pop    %esi
  801683:	5f                   	pop    %edi
  801684:	5d                   	pop    %ebp
  801685:	c3                   	ret    

00801686 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	53                   	push   %ebx
  80168a:	83 ec 14             	sub    $0x14,%esp
  80168d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801690:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801693:	50                   	push   %eax
  801694:	53                   	push   %ebx
  801695:	e8 ac fc ff ff       	call   801346 <fd_lookup>
  80169a:	83 c4 08             	add    $0x8,%esp
  80169d:	89 c2                	mov    %eax,%edx
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	78 68                	js     80170b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a3:	83 ec 08             	sub    $0x8,%esp
  8016a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a9:	50                   	push   %eax
  8016aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ad:	ff 30                	pushl  (%eax)
  8016af:	e8 e8 fc ff ff       	call   80139c <dev_lookup>
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	78 47                	js     801702 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016be:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c2:	75 21                	jne    8016e5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c4:	a1 08 40 80 00       	mov    0x804008,%eax
  8016c9:	8b 40 48             	mov    0x48(%eax),%eax
  8016cc:	83 ec 04             	sub    $0x4,%esp
  8016cf:	53                   	push   %ebx
  8016d0:	50                   	push   %eax
  8016d1:	68 15 28 80 00       	push   $0x802815
  8016d6:	e8 56 eb ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e3:	eb 26                	jmp    80170b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8016eb:	85 d2                	test   %edx,%edx
  8016ed:	74 17                	je     801706 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016ef:	83 ec 04             	sub    $0x4,%esp
  8016f2:	ff 75 10             	pushl  0x10(%ebp)
  8016f5:	ff 75 0c             	pushl  0xc(%ebp)
  8016f8:	50                   	push   %eax
  8016f9:	ff d2                	call   *%edx
  8016fb:	89 c2                	mov    %eax,%edx
  8016fd:	83 c4 10             	add    $0x10,%esp
  801700:	eb 09                	jmp    80170b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801702:	89 c2                	mov    %eax,%edx
  801704:	eb 05                	jmp    80170b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801706:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80170b:	89 d0                	mov    %edx,%eax
  80170d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801710:	c9                   	leave  
  801711:	c3                   	ret    

00801712 <seek>:

int
seek(int fdnum, off_t offset)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801718:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80171b:	50                   	push   %eax
  80171c:	ff 75 08             	pushl  0x8(%ebp)
  80171f:	e8 22 fc ff ff       	call   801346 <fd_lookup>
  801724:	83 c4 08             	add    $0x8,%esp
  801727:	85 c0                	test   %eax,%eax
  801729:	78 0e                	js     801739 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80172b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80172e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801731:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801734:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801739:	c9                   	leave  
  80173a:	c3                   	ret    

0080173b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	53                   	push   %ebx
  80173f:	83 ec 14             	sub    $0x14,%esp
  801742:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801745:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801748:	50                   	push   %eax
  801749:	53                   	push   %ebx
  80174a:	e8 f7 fb ff ff       	call   801346 <fd_lookup>
  80174f:	83 c4 08             	add    $0x8,%esp
  801752:	89 c2                	mov    %eax,%edx
  801754:	85 c0                	test   %eax,%eax
  801756:	78 65                	js     8017bd <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801758:	83 ec 08             	sub    $0x8,%esp
  80175b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175e:	50                   	push   %eax
  80175f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801762:	ff 30                	pushl  (%eax)
  801764:	e8 33 fc ff ff       	call   80139c <dev_lookup>
  801769:	83 c4 10             	add    $0x10,%esp
  80176c:	85 c0                	test   %eax,%eax
  80176e:	78 44                	js     8017b4 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801770:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801773:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801777:	75 21                	jne    80179a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801779:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80177e:	8b 40 48             	mov    0x48(%eax),%eax
  801781:	83 ec 04             	sub    $0x4,%esp
  801784:	53                   	push   %ebx
  801785:	50                   	push   %eax
  801786:	68 d8 27 80 00       	push   $0x8027d8
  80178b:	e8 a1 ea ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801790:	83 c4 10             	add    $0x10,%esp
  801793:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801798:	eb 23                	jmp    8017bd <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80179a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80179d:	8b 52 18             	mov    0x18(%edx),%edx
  8017a0:	85 d2                	test   %edx,%edx
  8017a2:	74 14                	je     8017b8 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017a4:	83 ec 08             	sub    $0x8,%esp
  8017a7:	ff 75 0c             	pushl  0xc(%ebp)
  8017aa:	50                   	push   %eax
  8017ab:	ff d2                	call   *%edx
  8017ad:	89 c2                	mov    %eax,%edx
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	eb 09                	jmp    8017bd <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b4:	89 c2                	mov    %eax,%edx
  8017b6:	eb 05                	jmp    8017bd <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017bd:	89 d0                	mov    %edx,%eax
  8017bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c2:	c9                   	leave  
  8017c3:	c3                   	ret    

008017c4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	53                   	push   %ebx
  8017c8:	83 ec 14             	sub    $0x14,%esp
  8017cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d1:	50                   	push   %eax
  8017d2:	ff 75 08             	pushl  0x8(%ebp)
  8017d5:	e8 6c fb ff ff       	call   801346 <fd_lookup>
  8017da:	83 c4 08             	add    $0x8,%esp
  8017dd:	89 c2                	mov    %eax,%edx
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	78 58                	js     80183b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e3:	83 ec 08             	sub    $0x8,%esp
  8017e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e9:	50                   	push   %eax
  8017ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ed:	ff 30                	pushl  (%eax)
  8017ef:	e8 a8 fb ff ff       	call   80139c <dev_lookup>
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	78 37                	js     801832 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fe:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801802:	74 32                	je     801836 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801804:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801807:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80180e:	00 00 00 
	stat->st_isdir = 0;
  801811:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801818:	00 00 00 
	stat->st_dev = dev;
  80181b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801821:	83 ec 08             	sub    $0x8,%esp
  801824:	53                   	push   %ebx
  801825:	ff 75 f0             	pushl  -0x10(%ebp)
  801828:	ff 50 14             	call   *0x14(%eax)
  80182b:	89 c2                	mov    %eax,%edx
  80182d:	83 c4 10             	add    $0x10,%esp
  801830:	eb 09                	jmp    80183b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801832:	89 c2                	mov    %eax,%edx
  801834:	eb 05                	jmp    80183b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801836:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80183b:	89 d0                	mov    %edx,%eax
  80183d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801840:	c9                   	leave  
  801841:	c3                   	ret    

00801842 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	56                   	push   %esi
  801846:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801847:	83 ec 08             	sub    $0x8,%esp
  80184a:	6a 00                	push   $0x0
  80184c:	ff 75 08             	pushl  0x8(%ebp)
  80184f:	e8 2b 02 00 00       	call   801a7f <open>
  801854:	89 c3                	mov    %eax,%ebx
  801856:	83 c4 10             	add    $0x10,%esp
  801859:	85 c0                	test   %eax,%eax
  80185b:	78 1b                	js     801878 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80185d:	83 ec 08             	sub    $0x8,%esp
  801860:	ff 75 0c             	pushl  0xc(%ebp)
  801863:	50                   	push   %eax
  801864:	e8 5b ff ff ff       	call   8017c4 <fstat>
  801869:	89 c6                	mov    %eax,%esi
	close(fd);
  80186b:	89 1c 24             	mov    %ebx,(%esp)
  80186e:	e8 fd fb ff ff       	call   801470 <close>
	return r;
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	89 f0                	mov    %esi,%eax
}
  801878:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187b:	5b                   	pop    %ebx
  80187c:	5e                   	pop    %esi
  80187d:	5d                   	pop    %ebp
  80187e:	c3                   	ret    

0080187f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	56                   	push   %esi
  801883:	53                   	push   %ebx
  801884:	89 c6                	mov    %eax,%esi
  801886:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801888:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80188f:	75 12                	jne    8018a3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801891:	83 ec 0c             	sub    $0xc,%esp
  801894:	6a 01                	push   $0x1
  801896:	e8 fc f9 ff ff       	call   801297 <ipc_find_env>
  80189b:	a3 04 40 80 00       	mov    %eax,0x804004
  8018a0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018a3:	6a 07                	push   $0x7
  8018a5:	68 00 50 80 00       	push   $0x805000
  8018aa:	56                   	push   %esi
  8018ab:	ff 35 04 40 80 00    	pushl  0x804004
  8018b1:	e8 8b f9 ff ff       	call   801241 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8018b6:	83 c4 0c             	add    $0xc,%esp
  8018b9:	6a 00                	push   $0x0
  8018bb:	53                   	push   %ebx
  8018bc:	6a 00                	push   $0x0
  8018be:	e8 15 f9 ff ff       	call   8011d8 <ipc_recv>
}
  8018c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c6:	5b                   	pop    %ebx
  8018c7:	5e                   	pop    %esi
  8018c8:	5d                   	pop    %ebp
  8018c9:	c3                   	ret    

008018ca <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018de:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e8:	b8 02 00 00 00       	mov    $0x2,%eax
  8018ed:	e8 8d ff ff ff       	call   80187f <fsipc>
}
  8018f2:	c9                   	leave  
  8018f3:	c3                   	ret    

008018f4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801900:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801905:	ba 00 00 00 00       	mov    $0x0,%edx
  80190a:	b8 06 00 00 00       	mov    $0x6,%eax
  80190f:	e8 6b ff ff ff       	call   80187f <fsipc>
}
  801914:	c9                   	leave  
  801915:	c3                   	ret    

00801916 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	53                   	push   %ebx
  80191a:	83 ec 04             	sub    $0x4,%esp
  80191d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801920:	8b 45 08             	mov    0x8(%ebp),%eax
  801923:	8b 40 0c             	mov    0xc(%eax),%eax
  801926:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80192b:	ba 00 00 00 00       	mov    $0x0,%edx
  801930:	b8 05 00 00 00       	mov    $0x5,%eax
  801935:	e8 45 ff ff ff       	call   80187f <fsipc>
  80193a:	85 c0                	test   %eax,%eax
  80193c:	78 2c                	js     80196a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80193e:	83 ec 08             	sub    $0x8,%esp
  801941:	68 00 50 80 00       	push   $0x805000
  801946:	53                   	push   %ebx
  801947:	e8 19 ef ff ff       	call   800865 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80194c:	a1 80 50 80 00       	mov    0x805080,%eax
  801951:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801957:	a1 84 50 80 00       	mov    0x805084,%eax
  80195c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80196a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196d:	c9                   	leave  
  80196e:	c3                   	ret    

0080196f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	53                   	push   %ebx
  801973:	83 ec 08             	sub    $0x8,%esp
  801976:	8b 45 10             	mov    0x10(%ebp),%eax
  801979:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80197e:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801983:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801986:	8b 45 08             	mov    0x8(%ebp),%eax
  801989:	8b 40 0c             	mov    0xc(%eax),%eax
  80198c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801991:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801997:	53                   	push   %ebx
  801998:	ff 75 0c             	pushl  0xc(%ebp)
  80199b:	68 08 50 80 00       	push   $0x805008
  8019a0:	e8 52 f0 ff ff       	call   8009f7 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8019a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019aa:	b8 04 00 00 00       	mov    $0x4,%eax
  8019af:	e8 cb fe ff ff       	call   80187f <fsipc>
  8019b4:	83 c4 10             	add    $0x10,%esp
  8019b7:	85 c0                	test   %eax,%eax
  8019b9:	78 3d                	js     8019f8 <devfile_write+0x89>
		return r;

	assert(r <= n);
  8019bb:	39 d8                	cmp    %ebx,%eax
  8019bd:	76 19                	jbe    8019d8 <devfile_write+0x69>
  8019bf:	68 44 28 80 00       	push   $0x802844
  8019c4:	68 4b 28 80 00       	push   $0x80284b
  8019c9:	68 9f 00 00 00       	push   $0x9f
  8019ce:	68 60 28 80 00       	push   $0x802860
  8019d3:	e8 80 e7 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  8019d8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019dd:	76 19                	jbe    8019f8 <devfile_write+0x89>
  8019df:	68 78 28 80 00       	push   $0x802878
  8019e4:	68 4b 28 80 00       	push   $0x80284b
  8019e9:	68 a0 00 00 00       	push   $0xa0
  8019ee:	68 60 28 80 00       	push   $0x802860
  8019f3:	e8 60 e7 ff ff       	call   800158 <_panic>

	return r;
}
  8019f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019fb:	c9                   	leave  
  8019fc:	c3                   	ret    

008019fd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019fd:	55                   	push   %ebp
  8019fe:	89 e5                	mov    %esp,%ebp
  801a00:	56                   	push   %esi
  801a01:	53                   	push   %ebx
  801a02:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a05:	8b 45 08             	mov    0x8(%ebp),%eax
  801a08:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a10:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a16:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1b:	b8 03 00 00 00       	mov    $0x3,%eax
  801a20:	e8 5a fe ff ff       	call   80187f <fsipc>
  801a25:	89 c3                	mov    %eax,%ebx
  801a27:	85 c0                	test   %eax,%eax
  801a29:	78 4b                	js     801a76 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a2b:	39 c6                	cmp    %eax,%esi
  801a2d:	73 16                	jae    801a45 <devfile_read+0x48>
  801a2f:	68 44 28 80 00       	push   $0x802844
  801a34:	68 4b 28 80 00       	push   $0x80284b
  801a39:	6a 7e                	push   $0x7e
  801a3b:	68 60 28 80 00       	push   $0x802860
  801a40:	e8 13 e7 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  801a45:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a4a:	7e 16                	jle    801a62 <devfile_read+0x65>
  801a4c:	68 6b 28 80 00       	push   $0x80286b
  801a51:	68 4b 28 80 00       	push   $0x80284b
  801a56:	6a 7f                	push   $0x7f
  801a58:	68 60 28 80 00       	push   $0x802860
  801a5d:	e8 f6 e6 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a62:	83 ec 04             	sub    $0x4,%esp
  801a65:	50                   	push   %eax
  801a66:	68 00 50 80 00       	push   $0x805000
  801a6b:	ff 75 0c             	pushl  0xc(%ebp)
  801a6e:	e8 84 ef ff ff       	call   8009f7 <memmove>
	return r;
  801a73:	83 c4 10             	add    $0x10,%esp
}
  801a76:	89 d8                	mov    %ebx,%eax
  801a78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7b:	5b                   	pop    %ebx
  801a7c:	5e                   	pop    %esi
  801a7d:	5d                   	pop    %ebp
  801a7e:	c3                   	ret    

00801a7f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	53                   	push   %ebx
  801a83:	83 ec 20             	sub    $0x20,%esp
  801a86:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a89:	53                   	push   %ebx
  801a8a:	e8 9d ed ff ff       	call   80082c <strlen>
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a97:	7f 67                	jg     801b00 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a99:	83 ec 0c             	sub    $0xc,%esp
  801a9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9f:	50                   	push   %eax
  801aa0:	e8 52 f8 ff ff       	call   8012f7 <fd_alloc>
  801aa5:	83 c4 10             	add    $0x10,%esp
		return r;
  801aa8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aaa:	85 c0                	test   %eax,%eax
  801aac:	78 57                	js     801b05 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801aae:	83 ec 08             	sub    $0x8,%esp
  801ab1:	53                   	push   %ebx
  801ab2:	68 00 50 80 00       	push   $0x805000
  801ab7:	e8 a9 ed ff ff       	call   800865 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801abc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801abf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ac4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ac7:	b8 01 00 00 00       	mov    $0x1,%eax
  801acc:	e8 ae fd ff ff       	call   80187f <fsipc>
  801ad1:	89 c3                	mov    %eax,%ebx
  801ad3:	83 c4 10             	add    $0x10,%esp
  801ad6:	85 c0                	test   %eax,%eax
  801ad8:	79 14                	jns    801aee <open+0x6f>
		fd_close(fd, 0);
  801ada:	83 ec 08             	sub    $0x8,%esp
  801add:	6a 00                	push   $0x0
  801adf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae2:	e8 08 f9 ff ff       	call   8013ef <fd_close>
		return r;
  801ae7:	83 c4 10             	add    $0x10,%esp
  801aea:	89 da                	mov    %ebx,%edx
  801aec:	eb 17                	jmp    801b05 <open+0x86>
	}

	return fd2num(fd);
  801aee:	83 ec 0c             	sub    $0xc,%esp
  801af1:	ff 75 f4             	pushl  -0xc(%ebp)
  801af4:	e8 d7 f7 ff ff       	call   8012d0 <fd2num>
  801af9:	89 c2                	mov    %eax,%edx
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	eb 05                	jmp    801b05 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b00:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b05:	89 d0                	mov    %edx,%eax
  801b07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b12:	ba 00 00 00 00       	mov    $0x0,%edx
  801b17:	b8 08 00 00 00       	mov    $0x8,%eax
  801b1c:	e8 5e fd ff ff       	call   80187f <fsipc>
}
  801b21:	c9                   	leave  
  801b22:	c3                   	ret    

00801b23 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	56                   	push   %esi
  801b27:	53                   	push   %ebx
  801b28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b2b:	83 ec 0c             	sub    $0xc,%esp
  801b2e:	ff 75 08             	pushl  0x8(%ebp)
  801b31:	e8 aa f7 ff ff       	call   8012e0 <fd2data>
  801b36:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b38:	83 c4 08             	add    $0x8,%esp
  801b3b:	68 a8 28 80 00       	push   $0x8028a8
  801b40:	53                   	push   %ebx
  801b41:	e8 1f ed ff ff       	call   800865 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b46:	8b 46 04             	mov    0x4(%esi),%eax
  801b49:	2b 06                	sub    (%esi),%eax
  801b4b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b51:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b58:	00 00 00 
	stat->st_dev = &devpipe;
  801b5b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b62:	30 80 00 
	return 0;
}
  801b65:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6d:	5b                   	pop    %ebx
  801b6e:	5e                   	pop    %esi
  801b6f:	5d                   	pop    %ebp
  801b70:	c3                   	ret    

00801b71 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	53                   	push   %ebx
  801b75:	83 ec 0c             	sub    $0xc,%esp
  801b78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b7b:	53                   	push   %ebx
  801b7c:	6a 00                	push   $0x0
  801b7e:	e8 e1 f1 ff ff       	call   800d64 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b83:	89 1c 24             	mov    %ebx,(%esp)
  801b86:	e8 55 f7 ff ff       	call   8012e0 <fd2data>
  801b8b:	83 c4 08             	add    $0x8,%esp
  801b8e:	50                   	push   %eax
  801b8f:	6a 00                	push   $0x0
  801b91:	e8 ce f1 ff ff       	call   800d64 <sys_page_unmap>
}
  801b96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b99:	c9                   	leave  
  801b9a:	c3                   	ret    

00801b9b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	57                   	push   %edi
  801b9f:	56                   	push   %esi
  801ba0:	53                   	push   %ebx
  801ba1:	83 ec 1c             	sub    $0x1c,%esp
  801ba4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ba7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ba9:	a1 08 40 80 00       	mov    0x804008,%eax
  801bae:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bb1:	83 ec 0c             	sub    $0xc,%esp
  801bb4:	ff 75 e0             	pushl  -0x20(%ebp)
  801bb7:	e8 d5 04 00 00       	call   802091 <pageref>
  801bbc:	89 c3                	mov    %eax,%ebx
  801bbe:	89 3c 24             	mov    %edi,(%esp)
  801bc1:	e8 cb 04 00 00       	call   802091 <pageref>
  801bc6:	83 c4 10             	add    $0x10,%esp
  801bc9:	39 c3                	cmp    %eax,%ebx
  801bcb:	0f 94 c1             	sete   %cl
  801bce:	0f b6 c9             	movzbl %cl,%ecx
  801bd1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bd4:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801bda:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bdd:	39 ce                	cmp    %ecx,%esi
  801bdf:	74 1b                	je     801bfc <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801be1:	39 c3                	cmp    %eax,%ebx
  801be3:	75 c4                	jne    801ba9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801be5:	8b 42 58             	mov    0x58(%edx),%eax
  801be8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801beb:	50                   	push   %eax
  801bec:	56                   	push   %esi
  801bed:	68 af 28 80 00       	push   $0x8028af
  801bf2:	e8 3a e6 ff ff       	call   800231 <cprintf>
  801bf7:	83 c4 10             	add    $0x10,%esp
  801bfa:	eb ad                	jmp    801ba9 <_pipeisclosed+0xe>
	}
}
  801bfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c02:	5b                   	pop    %ebx
  801c03:	5e                   	pop    %esi
  801c04:	5f                   	pop    %edi
  801c05:	5d                   	pop    %ebp
  801c06:	c3                   	ret    

00801c07 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	57                   	push   %edi
  801c0b:	56                   	push   %esi
  801c0c:	53                   	push   %ebx
  801c0d:	83 ec 28             	sub    $0x28,%esp
  801c10:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c13:	56                   	push   %esi
  801c14:	e8 c7 f6 ff ff       	call   8012e0 <fd2data>
  801c19:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c1b:	83 c4 10             	add    $0x10,%esp
  801c1e:	bf 00 00 00 00       	mov    $0x0,%edi
  801c23:	eb 4b                	jmp    801c70 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c25:	89 da                	mov    %ebx,%edx
  801c27:	89 f0                	mov    %esi,%eax
  801c29:	e8 6d ff ff ff       	call   801b9b <_pipeisclosed>
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	75 48                	jne    801c7a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c32:	e8 89 f0 ff ff       	call   800cc0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c37:	8b 43 04             	mov    0x4(%ebx),%eax
  801c3a:	8b 0b                	mov    (%ebx),%ecx
  801c3c:	8d 51 20             	lea    0x20(%ecx),%edx
  801c3f:	39 d0                	cmp    %edx,%eax
  801c41:	73 e2                	jae    801c25 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c46:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c4a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c4d:	89 c2                	mov    %eax,%edx
  801c4f:	c1 fa 1f             	sar    $0x1f,%edx
  801c52:	89 d1                	mov    %edx,%ecx
  801c54:	c1 e9 1b             	shr    $0x1b,%ecx
  801c57:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c5a:	83 e2 1f             	and    $0x1f,%edx
  801c5d:	29 ca                	sub    %ecx,%edx
  801c5f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c63:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c67:	83 c0 01             	add    $0x1,%eax
  801c6a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c6d:	83 c7 01             	add    $0x1,%edi
  801c70:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c73:	75 c2                	jne    801c37 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c75:	8b 45 10             	mov    0x10(%ebp),%eax
  801c78:	eb 05                	jmp    801c7f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c7a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c82:	5b                   	pop    %ebx
  801c83:	5e                   	pop    %esi
  801c84:	5f                   	pop    %edi
  801c85:	5d                   	pop    %ebp
  801c86:	c3                   	ret    

00801c87 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	57                   	push   %edi
  801c8b:	56                   	push   %esi
  801c8c:	53                   	push   %ebx
  801c8d:	83 ec 18             	sub    $0x18,%esp
  801c90:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c93:	57                   	push   %edi
  801c94:	e8 47 f6 ff ff       	call   8012e0 <fd2data>
  801c99:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c9b:	83 c4 10             	add    $0x10,%esp
  801c9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ca3:	eb 3d                	jmp    801ce2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ca5:	85 db                	test   %ebx,%ebx
  801ca7:	74 04                	je     801cad <devpipe_read+0x26>
				return i;
  801ca9:	89 d8                	mov    %ebx,%eax
  801cab:	eb 44                	jmp    801cf1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cad:	89 f2                	mov    %esi,%edx
  801caf:	89 f8                	mov    %edi,%eax
  801cb1:	e8 e5 fe ff ff       	call   801b9b <_pipeisclosed>
  801cb6:	85 c0                	test   %eax,%eax
  801cb8:	75 32                	jne    801cec <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cba:	e8 01 f0 ff ff       	call   800cc0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cbf:	8b 06                	mov    (%esi),%eax
  801cc1:	3b 46 04             	cmp    0x4(%esi),%eax
  801cc4:	74 df                	je     801ca5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cc6:	99                   	cltd   
  801cc7:	c1 ea 1b             	shr    $0x1b,%edx
  801cca:	01 d0                	add    %edx,%eax
  801ccc:	83 e0 1f             	and    $0x1f,%eax
  801ccf:	29 d0                	sub    %edx,%eax
  801cd1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cd9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cdc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cdf:	83 c3 01             	add    $0x1,%ebx
  801ce2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ce5:	75 d8                	jne    801cbf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ce7:	8b 45 10             	mov    0x10(%ebp),%eax
  801cea:	eb 05                	jmp    801cf1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cec:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf4:	5b                   	pop    %ebx
  801cf5:	5e                   	pop    %esi
  801cf6:	5f                   	pop    %edi
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    

00801cf9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	56                   	push   %esi
  801cfd:	53                   	push   %ebx
  801cfe:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d04:	50                   	push   %eax
  801d05:	e8 ed f5 ff ff       	call   8012f7 <fd_alloc>
  801d0a:	83 c4 10             	add    $0x10,%esp
  801d0d:	89 c2                	mov    %eax,%edx
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	0f 88 2c 01 00 00    	js     801e43 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d17:	83 ec 04             	sub    $0x4,%esp
  801d1a:	68 07 04 00 00       	push   $0x407
  801d1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d22:	6a 00                	push   $0x0
  801d24:	e8 b6 ef ff ff       	call   800cdf <sys_page_alloc>
  801d29:	83 c4 10             	add    $0x10,%esp
  801d2c:	89 c2                	mov    %eax,%edx
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	0f 88 0d 01 00 00    	js     801e43 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d36:	83 ec 0c             	sub    $0xc,%esp
  801d39:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d3c:	50                   	push   %eax
  801d3d:	e8 b5 f5 ff ff       	call   8012f7 <fd_alloc>
  801d42:	89 c3                	mov    %eax,%ebx
  801d44:	83 c4 10             	add    $0x10,%esp
  801d47:	85 c0                	test   %eax,%eax
  801d49:	0f 88 e2 00 00 00    	js     801e31 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4f:	83 ec 04             	sub    $0x4,%esp
  801d52:	68 07 04 00 00       	push   $0x407
  801d57:	ff 75 f0             	pushl  -0x10(%ebp)
  801d5a:	6a 00                	push   $0x0
  801d5c:	e8 7e ef ff ff       	call   800cdf <sys_page_alloc>
  801d61:	89 c3                	mov    %eax,%ebx
  801d63:	83 c4 10             	add    $0x10,%esp
  801d66:	85 c0                	test   %eax,%eax
  801d68:	0f 88 c3 00 00 00    	js     801e31 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d6e:	83 ec 0c             	sub    $0xc,%esp
  801d71:	ff 75 f4             	pushl  -0xc(%ebp)
  801d74:	e8 67 f5 ff ff       	call   8012e0 <fd2data>
  801d79:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d7b:	83 c4 0c             	add    $0xc,%esp
  801d7e:	68 07 04 00 00       	push   $0x407
  801d83:	50                   	push   %eax
  801d84:	6a 00                	push   $0x0
  801d86:	e8 54 ef ff ff       	call   800cdf <sys_page_alloc>
  801d8b:	89 c3                	mov    %eax,%ebx
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	85 c0                	test   %eax,%eax
  801d92:	0f 88 89 00 00 00    	js     801e21 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d98:	83 ec 0c             	sub    $0xc,%esp
  801d9b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9e:	e8 3d f5 ff ff       	call   8012e0 <fd2data>
  801da3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801daa:	50                   	push   %eax
  801dab:	6a 00                	push   $0x0
  801dad:	56                   	push   %esi
  801dae:	6a 00                	push   $0x0
  801db0:	e8 6d ef ff ff       	call   800d22 <sys_page_map>
  801db5:	89 c3                	mov    %eax,%ebx
  801db7:	83 c4 20             	add    $0x20,%esp
  801dba:	85 c0                	test   %eax,%eax
  801dbc:	78 55                	js     801e13 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dbe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dd3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ddc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dde:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801de1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801de8:	83 ec 0c             	sub    $0xc,%esp
  801deb:	ff 75 f4             	pushl  -0xc(%ebp)
  801dee:	e8 dd f4 ff ff       	call   8012d0 <fd2num>
  801df3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801df6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801df8:	83 c4 04             	add    $0x4,%esp
  801dfb:	ff 75 f0             	pushl  -0x10(%ebp)
  801dfe:	e8 cd f4 ff ff       	call   8012d0 <fd2num>
  801e03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e06:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e09:	83 c4 10             	add    $0x10,%esp
  801e0c:	ba 00 00 00 00       	mov    $0x0,%edx
  801e11:	eb 30                	jmp    801e43 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e13:	83 ec 08             	sub    $0x8,%esp
  801e16:	56                   	push   %esi
  801e17:	6a 00                	push   $0x0
  801e19:	e8 46 ef ff ff       	call   800d64 <sys_page_unmap>
  801e1e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e21:	83 ec 08             	sub    $0x8,%esp
  801e24:	ff 75 f0             	pushl  -0x10(%ebp)
  801e27:	6a 00                	push   $0x0
  801e29:	e8 36 ef ff ff       	call   800d64 <sys_page_unmap>
  801e2e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e31:	83 ec 08             	sub    $0x8,%esp
  801e34:	ff 75 f4             	pushl  -0xc(%ebp)
  801e37:	6a 00                	push   $0x0
  801e39:	e8 26 ef ff ff       	call   800d64 <sys_page_unmap>
  801e3e:	83 c4 10             	add    $0x10,%esp
  801e41:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e43:	89 d0                	mov    %edx,%eax
  801e45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e48:	5b                   	pop    %ebx
  801e49:	5e                   	pop    %esi
  801e4a:	5d                   	pop    %ebp
  801e4b:	c3                   	ret    

00801e4c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e55:	50                   	push   %eax
  801e56:	ff 75 08             	pushl  0x8(%ebp)
  801e59:	e8 e8 f4 ff ff       	call   801346 <fd_lookup>
  801e5e:	83 c4 10             	add    $0x10,%esp
  801e61:	85 c0                	test   %eax,%eax
  801e63:	78 18                	js     801e7d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e65:	83 ec 0c             	sub    $0xc,%esp
  801e68:	ff 75 f4             	pushl  -0xc(%ebp)
  801e6b:	e8 70 f4 ff ff       	call   8012e0 <fd2data>
	return _pipeisclosed(fd, p);
  801e70:	89 c2                	mov    %eax,%edx
  801e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e75:	e8 21 fd ff ff       	call   801b9b <_pipeisclosed>
  801e7a:	83 c4 10             	add    $0x10,%esp
}
  801e7d:	c9                   	leave  
  801e7e:	c3                   	ret    

00801e7f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e7f:	55                   	push   %ebp
  801e80:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e82:	b8 00 00 00 00       	mov    $0x0,%eax
  801e87:	5d                   	pop    %ebp
  801e88:	c3                   	ret    

00801e89 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e8f:	68 c7 28 80 00       	push   $0x8028c7
  801e94:	ff 75 0c             	pushl  0xc(%ebp)
  801e97:	e8 c9 e9 ff ff       	call   800865 <strcpy>
	return 0;
}
  801e9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea1:	c9                   	leave  
  801ea2:	c3                   	ret    

00801ea3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ea3:	55                   	push   %ebp
  801ea4:	89 e5                	mov    %esp,%ebp
  801ea6:	57                   	push   %edi
  801ea7:	56                   	push   %esi
  801ea8:	53                   	push   %ebx
  801ea9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eaf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eb4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eba:	eb 2d                	jmp    801ee9 <devcons_write+0x46>
		m = n - tot;
  801ebc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ebf:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ec1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ec4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ec9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ecc:	83 ec 04             	sub    $0x4,%esp
  801ecf:	53                   	push   %ebx
  801ed0:	03 45 0c             	add    0xc(%ebp),%eax
  801ed3:	50                   	push   %eax
  801ed4:	57                   	push   %edi
  801ed5:	e8 1d eb ff ff       	call   8009f7 <memmove>
		sys_cputs(buf, m);
  801eda:	83 c4 08             	add    $0x8,%esp
  801edd:	53                   	push   %ebx
  801ede:	57                   	push   %edi
  801edf:	e8 3f ed ff ff       	call   800c23 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ee4:	01 de                	add    %ebx,%esi
  801ee6:	83 c4 10             	add    $0x10,%esp
  801ee9:	89 f0                	mov    %esi,%eax
  801eeb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eee:	72 cc                	jb     801ebc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ef0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef3:	5b                   	pop    %ebx
  801ef4:	5e                   	pop    %esi
  801ef5:	5f                   	pop    %edi
  801ef6:	5d                   	pop    %ebp
  801ef7:	c3                   	ret    

00801ef8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	83 ec 08             	sub    $0x8,%esp
  801efe:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f03:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f07:	74 2a                	je     801f33 <devcons_read+0x3b>
  801f09:	eb 05                	jmp    801f10 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f0b:	e8 b0 ed ff ff       	call   800cc0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f10:	e8 2c ed ff ff       	call   800c41 <sys_cgetc>
  801f15:	85 c0                	test   %eax,%eax
  801f17:	74 f2                	je     801f0b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f19:	85 c0                	test   %eax,%eax
  801f1b:	78 16                	js     801f33 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f1d:	83 f8 04             	cmp    $0x4,%eax
  801f20:	74 0c                	je     801f2e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f22:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f25:	88 02                	mov    %al,(%edx)
	return 1;
  801f27:	b8 01 00 00 00       	mov    $0x1,%eax
  801f2c:	eb 05                	jmp    801f33 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f2e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f33:	c9                   	leave  
  801f34:	c3                   	ret    

00801f35 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f35:	55                   	push   %ebp
  801f36:	89 e5                	mov    %esp,%ebp
  801f38:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f41:	6a 01                	push   $0x1
  801f43:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f46:	50                   	push   %eax
  801f47:	e8 d7 ec ff ff       	call   800c23 <sys_cputs>
}
  801f4c:	83 c4 10             	add    $0x10,%esp
  801f4f:	c9                   	leave  
  801f50:	c3                   	ret    

00801f51 <getchar>:

int
getchar(void)
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
  801f54:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f57:	6a 01                	push   $0x1
  801f59:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f5c:	50                   	push   %eax
  801f5d:	6a 00                	push   $0x0
  801f5f:	e8 48 f6 ff ff       	call   8015ac <read>
	if (r < 0)
  801f64:	83 c4 10             	add    $0x10,%esp
  801f67:	85 c0                	test   %eax,%eax
  801f69:	78 0f                	js     801f7a <getchar+0x29>
		return r;
	if (r < 1)
  801f6b:	85 c0                	test   %eax,%eax
  801f6d:	7e 06                	jle    801f75 <getchar+0x24>
		return -E_EOF;
	return c;
  801f6f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f73:	eb 05                	jmp    801f7a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f75:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f7a:	c9                   	leave  
  801f7b:	c3                   	ret    

00801f7c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f7c:	55                   	push   %ebp
  801f7d:	89 e5                	mov    %esp,%ebp
  801f7f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f85:	50                   	push   %eax
  801f86:	ff 75 08             	pushl  0x8(%ebp)
  801f89:	e8 b8 f3 ff ff       	call   801346 <fd_lookup>
  801f8e:	83 c4 10             	add    $0x10,%esp
  801f91:	85 c0                	test   %eax,%eax
  801f93:	78 11                	js     801fa6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f98:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f9e:	39 10                	cmp    %edx,(%eax)
  801fa0:	0f 94 c0             	sete   %al
  801fa3:	0f b6 c0             	movzbl %al,%eax
}
  801fa6:	c9                   	leave  
  801fa7:	c3                   	ret    

00801fa8 <opencons>:

int
opencons(void)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb1:	50                   	push   %eax
  801fb2:	e8 40 f3 ff ff       	call   8012f7 <fd_alloc>
  801fb7:	83 c4 10             	add    $0x10,%esp
		return r;
  801fba:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fbc:	85 c0                	test   %eax,%eax
  801fbe:	78 3e                	js     801ffe <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fc0:	83 ec 04             	sub    $0x4,%esp
  801fc3:	68 07 04 00 00       	push   $0x407
  801fc8:	ff 75 f4             	pushl  -0xc(%ebp)
  801fcb:	6a 00                	push   $0x0
  801fcd:	e8 0d ed ff ff       	call   800cdf <sys_page_alloc>
  801fd2:	83 c4 10             	add    $0x10,%esp
		return r;
  801fd5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	78 23                	js     801ffe <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fdb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ff0:	83 ec 0c             	sub    $0xc,%esp
  801ff3:	50                   	push   %eax
  801ff4:	e8 d7 f2 ff ff       	call   8012d0 <fd2num>
  801ff9:	89 c2                	mov    %eax,%edx
  801ffb:	83 c4 10             	add    $0x10,%esp
}
  801ffe:	89 d0                	mov    %edx,%eax
  802000:	c9                   	leave  
  802001:	c3                   	ret    

00802002 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802002:	55                   	push   %ebp
  802003:	89 e5                	mov    %esp,%ebp
  802005:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  802008:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80200f:	75 52                	jne    802063 <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  802011:	83 ec 04             	sub    $0x4,%esp
  802014:	6a 07                	push   $0x7
  802016:	68 00 f0 bf ee       	push   $0xeebff000
  80201b:	6a 00                	push   $0x0
  80201d:	e8 bd ec ff ff       	call   800cdf <sys_page_alloc>
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	85 c0                	test   %eax,%eax
  802027:	79 12                	jns    80203b <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  802029:	50                   	push   %eax
  80202a:	68 e0 26 80 00       	push   $0x8026e0
  80202f:	6a 23                	push   $0x23
  802031:	68 d3 28 80 00       	push   $0x8028d3
  802036:	e8 1d e1 ff ff       	call   800158 <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  80203b:	83 ec 08             	sub    $0x8,%esp
  80203e:	68 6d 20 80 00       	push   $0x80206d
  802043:	6a 00                	push   $0x0
  802045:	e8 e0 ed ff ff       	call   800e2a <sys_env_set_pgfault_upcall>
  80204a:	83 c4 10             	add    $0x10,%esp
  80204d:	85 c0                	test   %eax,%eax
  80204f:	79 12                	jns    802063 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  802051:	50                   	push   %eax
  802052:	68 60 27 80 00       	push   $0x802760
  802057:	6a 26                	push   $0x26
  802059:	68 d3 28 80 00       	push   $0x8028d3
  80205e:	e8 f5 e0 ff ff       	call   800158 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802063:	8b 45 08             	mov    0x8(%ebp),%eax
  802066:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80206b:	c9                   	leave  
  80206c:	c3                   	ret    

0080206d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80206d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80206e:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802073:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802075:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  802078:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  80207c:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  802081:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  802085:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802087:	83 c4 08             	add    $0x8,%esp
	popal 
  80208a:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  80208b:	83 c4 04             	add    $0x4,%esp
	popfl
  80208e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80208f:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802090:	c3                   	ret    

00802091 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802091:	55                   	push   %ebp
  802092:	89 e5                	mov    %esp,%ebp
  802094:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802097:	89 d0                	mov    %edx,%eax
  802099:	c1 e8 16             	shr    $0x16,%eax
  80209c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020a3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020a8:	f6 c1 01             	test   $0x1,%cl
  8020ab:	74 1d                	je     8020ca <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020ad:	c1 ea 0c             	shr    $0xc,%edx
  8020b0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020b7:	f6 c2 01             	test   $0x1,%dl
  8020ba:	74 0e                	je     8020ca <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020bc:	c1 ea 0c             	shr    $0xc,%edx
  8020bf:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020c6:	ef 
  8020c7:	0f b7 c0             	movzwl %ax,%eax
}
  8020ca:	5d                   	pop    %ebp
  8020cb:	c3                   	ret    
  8020cc:	66 90                	xchg   %ax,%ax
  8020ce:	66 90                	xchg   %ax,%ax

008020d0 <__udivdi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e7:	85 f6                	test   %esi,%esi
  8020e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ed:	89 ca                	mov    %ecx,%edx
  8020ef:	89 f8                	mov    %edi,%eax
  8020f1:	75 3d                	jne    802130 <__udivdi3+0x60>
  8020f3:	39 cf                	cmp    %ecx,%edi
  8020f5:	0f 87 c5 00 00 00    	ja     8021c0 <__udivdi3+0xf0>
  8020fb:	85 ff                	test   %edi,%edi
  8020fd:	89 fd                	mov    %edi,%ebp
  8020ff:	75 0b                	jne    80210c <__udivdi3+0x3c>
  802101:	b8 01 00 00 00       	mov    $0x1,%eax
  802106:	31 d2                	xor    %edx,%edx
  802108:	f7 f7                	div    %edi
  80210a:	89 c5                	mov    %eax,%ebp
  80210c:	89 c8                	mov    %ecx,%eax
  80210e:	31 d2                	xor    %edx,%edx
  802110:	f7 f5                	div    %ebp
  802112:	89 c1                	mov    %eax,%ecx
  802114:	89 d8                	mov    %ebx,%eax
  802116:	89 cf                	mov    %ecx,%edi
  802118:	f7 f5                	div    %ebp
  80211a:	89 c3                	mov    %eax,%ebx
  80211c:	89 d8                	mov    %ebx,%eax
  80211e:	89 fa                	mov    %edi,%edx
  802120:	83 c4 1c             	add    $0x1c,%esp
  802123:	5b                   	pop    %ebx
  802124:	5e                   	pop    %esi
  802125:	5f                   	pop    %edi
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    
  802128:	90                   	nop
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	39 ce                	cmp    %ecx,%esi
  802132:	77 74                	ja     8021a8 <__udivdi3+0xd8>
  802134:	0f bd fe             	bsr    %esi,%edi
  802137:	83 f7 1f             	xor    $0x1f,%edi
  80213a:	0f 84 98 00 00 00    	je     8021d8 <__udivdi3+0x108>
  802140:	bb 20 00 00 00       	mov    $0x20,%ebx
  802145:	89 f9                	mov    %edi,%ecx
  802147:	89 c5                	mov    %eax,%ebp
  802149:	29 fb                	sub    %edi,%ebx
  80214b:	d3 e6                	shl    %cl,%esi
  80214d:	89 d9                	mov    %ebx,%ecx
  80214f:	d3 ed                	shr    %cl,%ebp
  802151:	89 f9                	mov    %edi,%ecx
  802153:	d3 e0                	shl    %cl,%eax
  802155:	09 ee                	or     %ebp,%esi
  802157:	89 d9                	mov    %ebx,%ecx
  802159:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80215d:	89 d5                	mov    %edx,%ebp
  80215f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802163:	d3 ed                	shr    %cl,%ebp
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e2                	shl    %cl,%edx
  802169:	89 d9                	mov    %ebx,%ecx
  80216b:	d3 e8                	shr    %cl,%eax
  80216d:	09 c2                	or     %eax,%edx
  80216f:	89 d0                	mov    %edx,%eax
  802171:	89 ea                	mov    %ebp,%edx
  802173:	f7 f6                	div    %esi
  802175:	89 d5                	mov    %edx,%ebp
  802177:	89 c3                	mov    %eax,%ebx
  802179:	f7 64 24 0c          	mull   0xc(%esp)
  80217d:	39 d5                	cmp    %edx,%ebp
  80217f:	72 10                	jb     802191 <__udivdi3+0xc1>
  802181:	8b 74 24 08          	mov    0x8(%esp),%esi
  802185:	89 f9                	mov    %edi,%ecx
  802187:	d3 e6                	shl    %cl,%esi
  802189:	39 c6                	cmp    %eax,%esi
  80218b:	73 07                	jae    802194 <__udivdi3+0xc4>
  80218d:	39 d5                	cmp    %edx,%ebp
  80218f:	75 03                	jne    802194 <__udivdi3+0xc4>
  802191:	83 eb 01             	sub    $0x1,%ebx
  802194:	31 ff                	xor    %edi,%edi
  802196:	89 d8                	mov    %ebx,%eax
  802198:	89 fa                	mov    %edi,%edx
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	31 ff                	xor    %edi,%edi
  8021aa:	31 db                	xor    %ebx,%ebx
  8021ac:	89 d8                	mov    %ebx,%eax
  8021ae:	89 fa                	mov    %edi,%edx
  8021b0:	83 c4 1c             	add    $0x1c,%esp
  8021b3:	5b                   	pop    %ebx
  8021b4:	5e                   	pop    %esi
  8021b5:	5f                   	pop    %edi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    
  8021b8:	90                   	nop
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	89 d8                	mov    %ebx,%eax
  8021c2:	f7 f7                	div    %edi
  8021c4:	31 ff                	xor    %edi,%edi
  8021c6:	89 c3                	mov    %eax,%ebx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 fa                	mov    %edi,%edx
  8021cc:	83 c4 1c             	add    $0x1c,%esp
  8021cf:	5b                   	pop    %ebx
  8021d0:	5e                   	pop    %esi
  8021d1:	5f                   	pop    %edi
  8021d2:	5d                   	pop    %ebp
  8021d3:	c3                   	ret    
  8021d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d8:	39 ce                	cmp    %ecx,%esi
  8021da:	72 0c                	jb     8021e8 <__udivdi3+0x118>
  8021dc:	31 db                	xor    %ebx,%ebx
  8021de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021e2:	0f 87 34 ff ff ff    	ja     80211c <__udivdi3+0x4c>
  8021e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021ed:	e9 2a ff ff ff       	jmp    80211c <__udivdi3+0x4c>
  8021f2:	66 90                	xchg   %ax,%ax
  8021f4:	66 90                	xchg   %ax,%ax
  8021f6:	66 90                	xchg   %ax,%ax
  8021f8:	66 90                	xchg   %ax,%ax
  8021fa:	66 90                	xchg   %ax,%ax
  8021fc:	66 90                	xchg   %ax,%ax
  8021fe:	66 90                	xchg   %ax,%ax

00802200 <__umoddi3>:
  802200:	55                   	push   %ebp
  802201:	57                   	push   %edi
  802202:	56                   	push   %esi
  802203:	53                   	push   %ebx
  802204:	83 ec 1c             	sub    $0x1c,%esp
  802207:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80220b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80220f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802217:	85 d2                	test   %edx,%edx
  802219:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80221d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802221:	89 f3                	mov    %esi,%ebx
  802223:	89 3c 24             	mov    %edi,(%esp)
  802226:	89 74 24 04          	mov    %esi,0x4(%esp)
  80222a:	75 1c                	jne    802248 <__umoddi3+0x48>
  80222c:	39 f7                	cmp    %esi,%edi
  80222e:	76 50                	jbe    802280 <__umoddi3+0x80>
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	f7 f7                	div    %edi
  802236:	89 d0                	mov    %edx,%eax
  802238:	31 d2                	xor    %edx,%edx
  80223a:	83 c4 1c             	add    $0x1c,%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5f                   	pop    %edi
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    
  802242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802248:	39 f2                	cmp    %esi,%edx
  80224a:	89 d0                	mov    %edx,%eax
  80224c:	77 52                	ja     8022a0 <__umoddi3+0xa0>
  80224e:	0f bd ea             	bsr    %edx,%ebp
  802251:	83 f5 1f             	xor    $0x1f,%ebp
  802254:	75 5a                	jne    8022b0 <__umoddi3+0xb0>
  802256:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80225a:	0f 82 e0 00 00 00    	jb     802340 <__umoddi3+0x140>
  802260:	39 0c 24             	cmp    %ecx,(%esp)
  802263:	0f 86 d7 00 00 00    	jbe    802340 <__umoddi3+0x140>
  802269:	8b 44 24 08          	mov    0x8(%esp),%eax
  80226d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802271:	83 c4 1c             	add    $0x1c,%esp
  802274:	5b                   	pop    %ebx
  802275:	5e                   	pop    %esi
  802276:	5f                   	pop    %edi
  802277:	5d                   	pop    %ebp
  802278:	c3                   	ret    
  802279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802280:	85 ff                	test   %edi,%edi
  802282:	89 fd                	mov    %edi,%ebp
  802284:	75 0b                	jne    802291 <__umoddi3+0x91>
  802286:	b8 01 00 00 00       	mov    $0x1,%eax
  80228b:	31 d2                	xor    %edx,%edx
  80228d:	f7 f7                	div    %edi
  80228f:	89 c5                	mov    %eax,%ebp
  802291:	89 f0                	mov    %esi,%eax
  802293:	31 d2                	xor    %edx,%edx
  802295:	f7 f5                	div    %ebp
  802297:	89 c8                	mov    %ecx,%eax
  802299:	f7 f5                	div    %ebp
  80229b:	89 d0                	mov    %edx,%eax
  80229d:	eb 99                	jmp    802238 <__umoddi3+0x38>
  80229f:	90                   	nop
  8022a0:	89 c8                	mov    %ecx,%eax
  8022a2:	89 f2                	mov    %esi,%edx
  8022a4:	83 c4 1c             	add    $0x1c,%esp
  8022a7:	5b                   	pop    %ebx
  8022a8:	5e                   	pop    %esi
  8022a9:	5f                   	pop    %edi
  8022aa:	5d                   	pop    %ebp
  8022ab:	c3                   	ret    
  8022ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	8b 34 24             	mov    (%esp),%esi
  8022b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022b8:	89 e9                	mov    %ebp,%ecx
  8022ba:	29 ef                	sub    %ebp,%edi
  8022bc:	d3 e0                	shl    %cl,%eax
  8022be:	89 f9                	mov    %edi,%ecx
  8022c0:	89 f2                	mov    %esi,%edx
  8022c2:	d3 ea                	shr    %cl,%edx
  8022c4:	89 e9                	mov    %ebp,%ecx
  8022c6:	09 c2                	or     %eax,%edx
  8022c8:	89 d8                	mov    %ebx,%eax
  8022ca:	89 14 24             	mov    %edx,(%esp)
  8022cd:	89 f2                	mov    %esi,%edx
  8022cf:	d3 e2                	shl    %cl,%edx
  8022d1:	89 f9                	mov    %edi,%ecx
  8022d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022db:	d3 e8                	shr    %cl,%eax
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	89 c6                	mov    %eax,%esi
  8022e1:	d3 e3                	shl    %cl,%ebx
  8022e3:	89 f9                	mov    %edi,%ecx
  8022e5:	89 d0                	mov    %edx,%eax
  8022e7:	d3 e8                	shr    %cl,%eax
  8022e9:	89 e9                	mov    %ebp,%ecx
  8022eb:	09 d8                	or     %ebx,%eax
  8022ed:	89 d3                	mov    %edx,%ebx
  8022ef:	89 f2                	mov    %esi,%edx
  8022f1:	f7 34 24             	divl   (%esp)
  8022f4:	89 d6                	mov    %edx,%esi
  8022f6:	d3 e3                	shl    %cl,%ebx
  8022f8:	f7 64 24 04          	mull   0x4(%esp)
  8022fc:	39 d6                	cmp    %edx,%esi
  8022fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802302:	89 d1                	mov    %edx,%ecx
  802304:	89 c3                	mov    %eax,%ebx
  802306:	72 08                	jb     802310 <__umoddi3+0x110>
  802308:	75 11                	jne    80231b <__umoddi3+0x11b>
  80230a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80230e:	73 0b                	jae    80231b <__umoddi3+0x11b>
  802310:	2b 44 24 04          	sub    0x4(%esp),%eax
  802314:	1b 14 24             	sbb    (%esp),%edx
  802317:	89 d1                	mov    %edx,%ecx
  802319:	89 c3                	mov    %eax,%ebx
  80231b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80231f:	29 da                	sub    %ebx,%edx
  802321:	19 ce                	sbb    %ecx,%esi
  802323:	89 f9                	mov    %edi,%ecx
  802325:	89 f0                	mov    %esi,%eax
  802327:	d3 e0                	shl    %cl,%eax
  802329:	89 e9                	mov    %ebp,%ecx
  80232b:	d3 ea                	shr    %cl,%edx
  80232d:	89 e9                	mov    %ebp,%ecx
  80232f:	d3 ee                	shr    %cl,%esi
  802331:	09 d0                	or     %edx,%eax
  802333:	89 f2                	mov    %esi,%edx
  802335:	83 c4 1c             	add    $0x1c,%esp
  802338:	5b                   	pop    %ebx
  802339:	5e                   	pop    %esi
  80233a:	5f                   	pop    %edi
  80233b:	5d                   	pop    %ebp
  80233c:	c3                   	ret    
  80233d:	8d 76 00             	lea    0x0(%esi),%esi
  802340:	29 f9                	sub    %edi,%ecx
  802342:	19 d6                	sbb    %edx,%esi
  802344:	89 74 24 04          	mov    %esi,0x4(%esp)
  802348:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80234c:	e9 18 ff ff ff       	jmp    802269 <__umoddi3+0x69>
