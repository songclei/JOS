
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 3d 11 00 00       	call   80117e <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  80004e:	e8 0e 0c 00 00       	call   800c61 <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 80 23 80 00       	push   $0x802380
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 f7 0b 00 00       	call   800c61 <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 9a 23 80 00       	push   $0x80239a
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 7a 11 00 00       	call   801201 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 fe 10 00 00       	call   801198 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 ae 0b 00 00       	call   800c61 <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 b0 23 80 00       	push   $0x8023b0
  8000c2:	e8 2a 01 00 00       	call   8001f1 <cprintf>
		if (val == 10)
  8000c7:	a1 08 40 80 00       	mov    0x804008,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 08 40 80 00       	mov    %eax,0x804008
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 17 11 00 00       	call   801201 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 08 40 80 00 0a 	cmpl   $0xa,0x804008
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800109:	e8 53 0b 00 00       	call   800c61 <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 0c 40 80 00       	mov    %eax,0x80400c
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 fe fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014a:	e8 0c 13 00 00       	call   80145b <close_all>
	sys_env_destroy(0);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	6a 00                	push   $0x0
  800154:	e8 c7 0a 00 00       	call   800c20 <sys_env_destroy>
}
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	53                   	push   %ebx
  800162:	83 ec 04             	sub    $0x4,%esp
  800165:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800168:	8b 13                	mov    (%ebx),%edx
  80016a:	8d 42 01             	lea    0x1(%edx),%eax
  80016d:	89 03                	mov    %eax,(%ebx)
  80016f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800172:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800176:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017b:	75 1a                	jne    800197 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017d:	83 ec 08             	sub    $0x8,%esp
  800180:	68 ff 00 00 00       	push   $0xff
  800185:	8d 43 08             	lea    0x8(%ebx),%eax
  800188:	50                   	push   %eax
  800189:	e8 55 0a 00 00       	call   800be3 <sys_cputs>
		b->idx = 0;
  80018e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800194:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800197:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b0:	00 00 00 
	b.cnt = 0;
  8001b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bd:	ff 75 0c             	pushl  0xc(%ebp)
  8001c0:	ff 75 08             	pushl  0x8(%ebp)
  8001c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c9:	50                   	push   %eax
  8001ca:	68 5e 01 80 00       	push   $0x80015e
  8001cf:	e8 54 01 00 00       	call   800328 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d4:	83 c4 08             	add    $0x8,%esp
  8001d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e3:	50                   	push   %eax
  8001e4:	e8 fa 09 00 00       	call   800be3 <sys_cputs>

	return b.cnt;
}
  8001e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fa:	50                   	push   %eax
  8001fb:	ff 75 08             	pushl  0x8(%ebp)
  8001fe:	e8 9d ff ff ff       	call   8001a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	57                   	push   %edi
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	83 ec 1c             	sub    $0x1c,%esp
  80020e:	89 c7                	mov    %eax,%edi
  800210:	89 d6                	mov    %edx,%esi
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	8b 55 0c             	mov    0xc(%ebp),%edx
  800218:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800221:	bb 00 00 00 00       	mov    $0x0,%ebx
  800226:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800229:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022c:	39 d3                	cmp    %edx,%ebx
  80022e:	72 05                	jb     800235 <printnum+0x30>
  800230:	39 45 10             	cmp    %eax,0x10(%ebp)
  800233:	77 45                	ja     80027a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	ff 75 18             	pushl  0x18(%ebp)
  80023b:	8b 45 14             	mov    0x14(%ebp),%eax
  80023e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800241:	53                   	push   %ebx
  800242:	ff 75 10             	pushl  0x10(%ebp)
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024b:	ff 75 e0             	pushl  -0x20(%ebp)
  80024e:	ff 75 dc             	pushl  -0x24(%ebp)
  800251:	ff 75 d8             	pushl  -0x28(%ebp)
  800254:	e8 87 1e 00 00       	call   8020e0 <__udivdi3>
  800259:	83 c4 18             	add    $0x18,%esp
  80025c:	52                   	push   %edx
  80025d:	50                   	push   %eax
  80025e:	89 f2                	mov    %esi,%edx
  800260:	89 f8                	mov    %edi,%eax
  800262:	e8 9e ff ff ff       	call   800205 <printnum>
  800267:	83 c4 20             	add    $0x20,%esp
  80026a:	eb 18                	jmp    800284 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	56                   	push   %esi
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	ff d7                	call   *%edi
  800275:	83 c4 10             	add    $0x10,%esp
  800278:	eb 03                	jmp    80027d <printnum+0x78>
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f e8                	jg     80026c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	56                   	push   %esi
  800288:	83 ec 04             	sub    $0x4,%esp
  80028b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028e:	ff 75 e0             	pushl  -0x20(%ebp)
  800291:	ff 75 dc             	pushl  -0x24(%ebp)
  800294:	ff 75 d8             	pushl  -0x28(%ebp)
  800297:	e8 74 1f 00 00       	call   802210 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 e0 23 80 00 	movsbl 0x8023e0(%eax),%eax
  8002a6:	50                   	push   %eax
  8002a7:	ff d7                	call   *%edi
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b7:	83 fa 01             	cmp    $0x1,%edx
  8002ba:	7e 0e                	jle    8002ca <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	8b 52 04             	mov    0x4(%edx),%edx
  8002c8:	eb 22                	jmp    8002ec <getuint+0x38>
	else if (lflag)
  8002ca:	85 d2                	test   %edx,%edx
  8002cc:	74 10                	je     8002de <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dc:	eb 0e                	jmp    8002ec <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fd:	73 0a                	jae    800309 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800302:	89 08                	mov    %ecx,(%eax)
  800304:	8b 45 08             	mov    0x8(%ebp),%eax
  800307:	88 02                	mov    %al,(%edx)
}
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800311:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800314:	50                   	push   %eax
  800315:	ff 75 10             	pushl  0x10(%ebp)
  800318:	ff 75 0c             	pushl  0xc(%ebp)
  80031b:	ff 75 08             	pushl  0x8(%ebp)
  80031e:	e8 05 00 00 00       	call   800328 <vprintfmt>
	va_end(ap);
}
  800323:	83 c4 10             	add    $0x10,%esp
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 2c             	sub    $0x2c,%esp
  800331:	8b 75 08             	mov    0x8(%ebp),%esi
  800334:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800337:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033a:	eb 12                	jmp    80034e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80033c:	85 c0                	test   %eax,%eax
  80033e:	0f 84 38 04 00 00    	je     80077c <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	53                   	push   %ebx
  800348:	50                   	push   %eax
  800349:	ff d6                	call   *%esi
  80034b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034e:	83 c7 01             	add    $0x1,%edi
  800351:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800355:	83 f8 25             	cmp    $0x25,%eax
  800358:	75 e2                	jne    80033c <vprintfmt+0x14>
  80035a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800365:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800373:	ba 00 00 00 00       	mov    $0x0,%edx
  800378:	eb 07                	jmp    800381 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  80037d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8d 47 01             	lea    0x1(%edi),%eax
  800384:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800387:	0f b6 07             	movzbl (%edi),%eax
  80038a:	0f b6 c8             	movzbl %al,%ecx
  80038d:	83 e8 23             	sub    $0x23,%eax
  800390:	3c 55                	cmp    $0x55,%al
  800392:	0f 87 c9 03 00 00    	ja     800761 <vprintfmt+0x439>
  800398:	0f b6 c0             	movzbl %al,%eax
  80039b:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a9:	eb d6                	jmp    800381 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  8003ab:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  8003b2:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  8003b8:	eb 94                	jmp    80034e <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  8003ba:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  8003c1:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  8003c7:	eb 85                	jmp    80034e <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  8003c9:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  8003d0:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  8003d6:	e9 73 ff ff ff       	jmp    80034e <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  8003db:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  8003e2:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  8003e8:	e9 61 ff ff ff       	jmp    80034e <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  8003ed:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  8003f4:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  8003fa:	e9 4f ff ff ff       	jmp    80034e <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  8003ff:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800406:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80040c:	e9 3d ff ff ff       	jmp    80034e <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  800411:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  800418:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80041e:	e9 2b ff ff ff       	jmp    80034e <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  800423:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  80042a:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  800430:	e9 19 ff ff ff       	jmp    80034e <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800435:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  80043c:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  800442:	e9 07 ff ff ff       	jmp    80034e <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  800447:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  80044e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800454:	e9 f5 fe ff ff       	jmp    80034e <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80045c:	b8 00 00 00 00       	mov    $0x0,%eax
  800461:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800464:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800467:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80046b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80046e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800471:	83 fa 09             	cmp    $0x9,%edx
  800474:	77 3f                	ja     8004b5 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800476:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800479:	eb e9                	jmp    800464 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	8d 48 04             	lea    0x4(%eax),%ecx
  800481:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800484:	8b 00                	mov    (%eax),%eax
  800486:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80048c:	eb 2d                	jmp    8004bb <vprintfmt+0x193>
  80048e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800491:	85 c0                	test   %eax,%eax
  800493:	b9 00 00 00 00       	mov    $0x0,%ecx
  800498:	0f 49 c8             	cmovns %eax,%ecx
  80049b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a1:	e9 db fe ff ff       	jmp    800381 <vprintfmt+0x59>
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004a9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004b0:	e9 cc fe ff ff       	jmp    800381 <vprintfmt+0x59>
  8004b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004b8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004bf:	0f 89 bc fe ff ff    	jns    800381 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004d2:	e9 aa fe ff ff       	jmp    800381 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004dd:	e9 9f fe ff ff       	jmp    800381 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e5:	8d 50 04             	lea    0x4(%eax),%edx
  8004e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	53                   	push   %ebx
  8004ef:	ff 30                	pushl  (%eax)
  8004f1:	ff d6                	call   *%esi
			break;
  8004f3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004f9:	e9 50 fe ff ff       	jmp    80034e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800501:	8d 50 04             	lea    0x4(%eax),%edx
  800504:	89 55 14             	mov    %edx,0x14(%ebp)
  800507:	8b 00                	mov    (%eax),%eax
  800509:	99                   	cltd   
  80050a:	31 d0                	xor    %edx,%eax
  80050c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80050e:	83 f8 0f             	cmp    $0xf,%eax
  800511:	7f 0b                	jg     80051e <vprintfmt+0x1f6>
  800513:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  80051a:	85 d2                	test   %edx,%edx
  80051c:	75 18                	jne    800536 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80051e:	50                   	push   %eax
  80051f:	68 f8 23 80 00       	push   $0x8023f8
  800524:	53                   	push   %ebx
  800525:	56                   	push   %esi
  800526:	e8 e0 fd ff ff       	call   80030b <printfmt>
  80052b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800531:	e9 18 fe ff ff       	jmp    80034e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800536:	52                   	push   %edx
  800537:	68 9d 28 80 00       	push   $0x80289d
  80053c:	53                   	push   %ebx
  80053d:	56                   	push   %esi
  80053e:	e8 c8 fd ff ff       	call   80030b <printfmt>
  800543:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800549:	e9 00 fe ff ff       	jmp    80034e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8d 50 04             	lea    0x4(%eax),%edx
  800554:	89 55 14             	mov    %edx,0x14(%ebp)
  800557:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800559:	85 ff                	test   %edi,%edi
  80055b:	b8 f1 23 80 00       	mov    $0x8023f1,%eax
  800560:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800563:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800567:	0f 8e 94 00 00 00    	jle    800601 <vprintfmt+0x2d9>
  80056d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800571:	0f 84 98 00 00 00    	je     80060f <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  800577:	83 ec 08             	sub    $0x8,%esp
  80057a:	ff 75 d0             	pushl  -0x30(%ebp)
  80057d:	57                   	push   %edi
  80057e:	e8 81 02 00 00       	call   800804 <strnlen>
  800583:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800586:	29 c1                	sub    %eax,%ecx
  800588:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80058b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80058e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800592:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800595:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800598:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80059a:	eb 0f                	jmp    8005ab <vprintfmt+0x283>
					putch(padc, putdat);
  80059c:	83 ec 08             	sub    $0x8,%esp
  80059f:	53                   	push   %ebx
  8005a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8005a3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a5:	83 ef 01             	sub    $0x1,%edi
  8005a8:	83 c4 10             	add    $0x10,%esp
  8005ab:	85 ff                	test   %edi,%edi
  8005ad:	7f ed                	jg     80059c <vprintfmt+0x274>
  8005af:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005b2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005b5:	85 c9                	test   %ecx,%ecx
  8005b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005bc:	0f 49 c1             	cmovns %ecx,%eax
  8005bf:	29 c1                	sub    %eax,%ecx
  8005c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ca:	89 cb                	mov    %ecx,%ebx
  8005cc:	eb 4d                	jmp    80061b <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005d2:	74 1b                	je     8005ef <vprintfmt+0x2c7>
  8005d4:	0f be c0             	movsbl %al,%eax
  8005d7:	83 e8 20             	sub    $0x20,%eax
  8005da:	83 f8 5e             	cmp    $0x5e,%eax
  8005dd:	76 10                	jbe    8005ef <vprintfmt+0x2c7>
					putch('?', putdat);
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	ff 75 0c             	pushl  0xc(%ebp)
  8005e5:	6a 3f                	push   $0x3f
  8005e7:	ff 55 08             	call   *0x8(%ebp)
  8005ea:	83 c4 10             	add    $0x10,%esp
  8005ed:	eb 0d                	jmp    8005fc <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	ff 75 0c             	pushl  0xc(%ebp)
  8005f5:	52                   	push   %edx
  8005f6:	ff 55 08             	call   *0x8(%ebp)
  8005f9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fc:	83 eb 01             	sub    $0x1,%ebx
  8005ff:	eb 1a                	jmp    80061b <vprintfmt+0x2f3>
  800601:	89 75 08             	mov    %esi,0x8(%ebp)
  800604:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800607:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80060a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80060d:	eb 0c                	jmp    80061b <vprintfmt+0x2f3>
  80060f:	89 75 08             	mov    %esi,0x8(%ebp)
  800612:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800615:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800618:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80061b:	83 c7 01             	add    $0x1,%edi
  80061e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800622:	0f be d0             	movsbl %al,%edx
  800625:	85 d2                	test   %edx,%edx
  800627:	74 23                	je     80064c <vprintfmt+0x324>
  800629:	85 f6                	test   %esi,%esi
  80062b:	78 a1                	js     8005ce <vprintfmt+0x2a6>
  80062d:	83 ee 01             	sub    $0x1,%esi
  800630:	79 9c                	jns    8005ce <vprintfmt+0x2a6>
  800632:	89 df                	mov    %ebx,%edi
  800634:	8b 75 08             	mov    0x8(%ebp),%esi
  800637:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063a:	eb 18                	jmp    800654 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	6a 20                	push   $0x20
  800642:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800644:	83 ef 01             	sub    $0x1,%edi
  800647:	83 c4 10             	add    $0x10,%esp
  80064a:	eb 08                	jmp    800654 <vprintfmt+0x32c>
  80064c:	89 df                	mov    %ebx,%edi
  80064e:	8b 75 08             	mov    0x8(%ebp),%esi
  800651:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800654:	85 ff                	test   %edi,%edi
  800656:	7f e4                	jg     80063c <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800658:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065b:	e9 ee fc ff ff       	jmp    80034e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800660:	83 fa 01             	cmp    $0x1,%edx
  800663:	7e 16                	jle    80067b <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8d 50 08             	lea    0x8(%eax),%edx
  80066b:	89 55 14             	mov    %edx,0x14(%ebp)
  80066e:	8b 50 04             	mov    0x4(%eax),%edx
  800671:	8b 00                	mov    (%eax),%eax
  800673:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800676:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800679:	eb 32                	jmp    8006ad <vprintfmt+0x385>
	else if (lflag)
  80067b:	85 d2                	test   %edx,%edx
  80067d:	74 18                	je     800697 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8d 50 04             	lea    0x4(%eax),%edx
  800685:	89 55 14             	mov    %edx,0x14(%ebp)
  800688:	8b 00                	mov    (%eax),%eax
  80068a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068d:	89 c1                	mov    %eax,%ecx
  80068f:	c1 f9 1f             	sar    $0x1f,%ecx
  800692:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800695:	eb 16                	jmp    8006ad <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 50 04             	lea    0x4(%eax),%edx
  80069d:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a0:	8b 00                	mov    (%eax),%eax
  8006a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a5:	89 c1                	mov    %eax,%ecx
  8006a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006b3:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006b8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006bc:	79 6f                	jns    80072d <vprintfmt+0x405>
				putch('-', putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	6a 2d                	push   $0x2d
  8006c4:	ff d6                	call   *%esi
				num = -(long long) num;
  8006c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006c9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006cc:	f7 d8                	neg    %eax
  8006ce:	83 d2 00             	adc    $0x0,%edx
  8006d1:	f7 da                	neg    %edx
  8006d3:	83 c4 10             	add    $0x10,%esp
  8006d6:	eb 55                	jmp    80072d <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006db:	e8 d4 fb ff ff       	call   8002b4 <getuint>
			base = 10;
  8006e0:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8006e5:	eb 46                	jmp    80072d <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ea:	e8 c5 fb ff ff       	call   8002b4 <getuint>
			base = 8;
  8006ef:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8006f4:	eb 37                	jmp    80072d <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	53                   	push   %ebx
  8006fa:	6a 30                	push   $0x30
  8006fc:	ff d6                	call   *%esi
			putch('x', putdat);
  8006fe:	83 c4 08             	add    $0x8,%esp
  800701:	53                   	push   %ebx
  800702:	6a 78                	push   $0x78
  800704:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 50 04             	lea    0x4(%eax),%edx
  80070c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80070f:	8b 00                	mov    (%eax),%eax
  800711:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800716:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800719:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80071e:	eb 0d                	jmp    80072d <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800720:	8d 45 14             	lea    0x14(%ebp),%eax
  800723:	e8 8c fb ff ff       	call   8002b4 <getuint>
			base = 16;
  800728:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80072d:	83 ec 0c             	sub    $0xc,%esp
  800730:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800734:	51                   	push   %ecx
  800735:	ff 75 e0             	pushl  -0x20(%ebp)
  800738:	57                   	push   %edi
  800739:	52                   	push   %edx
  80073a:	50                   	push   %eax
  80073b:	89 da                	mov    %ebx,%edx
  80073d:	89 f0                	mov    %esi,%eax
  80073f:	e8 c1 fa ff ff       	call   800205 <printnum>
			break;
  800744:	83 c4 20             	add    $0x20,%esp
  800747:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80074a:	e9 ff fb ff ff       	jmp    80034e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80074f:	83 ec 08             	sub    $0x8,%esp
  800752:	53                   	push   %ebx
  800753:	51                   	push   %ecx
  800754:	ff d6                	call   *%esi
			break;
  800756:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800759:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80075c:	e9 ed fb ff ff       	jmp    80034e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	53                   	push   %ebx
  800765:	6a 25                	push   $0x25
  800767:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800769:	83 c4 10             	add    $0x10,%esp
  80076c:	eb 03                	jmp    800771 <vprintfmt+0x449>
  80076e:	83 ef 01             	sub    $0x1,%edi
  800771:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800775:	75 f7                	jne    80076e <vprintfmt+0x446>
  800777:	e9 d2 fb ff ff       	jmp    80034e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80077c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80077f:	5b                   	pop    %ebx
  800780:	5e                   	pop    %esi
  800781:	5f                   	pop    %edi
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	83 ec 18             	sub    $0x18,%esp
  80078a:	8b 45 08             	mov    0x8(%ebp),%eax
  80078d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800790:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800793:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800797:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80079a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a1:	85 c0                	test   %eax,%eax
  8007a3:	74 26                	je     8007cb <vsnprintf+0x47>
  8007a5:	85 d2                	test   %edx,%edx
  8007a7:	7e 22                	jle    8007cb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a9:	ff 75 14             	pushl  0x14(%ebp)
  8007ac:	ff 75 10             	pushl  0x10(%ebp)
  8007af:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b2:	50                   	push   %eax
  8007b3:	68 ee 02 80 00       	push   $0x8002ee
  8007b8:	e8 6b fb ff ff       	call   800328 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c6:	83 c4 10             	add    $0x10,%esp
  8007c9:	eb 05                	jmp    8007d0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    

008007d2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007db:	50                   	push   %eax
  8007dc:	ff 75 10             	pushl  0x10(%ebp)
  8007df:	ff 75 0c             	pushl  0xc(%ebp)
  8007e2:	ff 75 08             	pushl  0x8(%ebp)
  8007e5:	e8 9a ff ff ff       	call   800784 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ea:	c9                   	leave  
  8007eb:	c3                   	ret    

008007ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f7:	eb 03                	jmp    8007fc <strlen+0x10>
		n++;
  8007f9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800800:	75 f7                	jne    8007f9 <strlen+0xd>
		n++;
	return n;
}
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080d:	ba 00 00 00 00       	mov    $0x0,%edx
  800812:	eb 03                	jmp    800817 <strnlen+0x13>
		n++;
  800814:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800817:	39 c2                	cmp    %eax,%edx
  800819:	74 08                	je     800823 <strnlen+0x1f>
  80081b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80081f:	75 f3                	jne    800814 <strnlen+0x10>
  800821:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	53                   	push   %ebx
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80082f:	89 c2                	mov    %eax,%edx
  800831:	83 c2 01             	add    $0x1,%edx
  800834:	83 c1 01             	add    $0x1,%ecx
  800837:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80083b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80083e:	84 db                	test   %bl,%bl
  800840:	75 ef                	jne    800831 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800842:	5b                   	pop    %ebx
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	53                   	push   %ebx
  800849:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80084c:	53                   	push   %ebx
  80084d:	e8 9a ff ff ff       	call   8007ec <strlen>
  800852:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800855:	ff 75 0c             	pushl  0xc(%ebp)
  800858:	01 d8                	add    %ebx,%eax
  80085a:	50                   	push   %eax
  80085b:	e8 c5 ff ff ff       	call   800825 <strcpy>
	return dst;
}
  800860:	89 d8                	mov    %ebx,%eax
  800862:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800865:	c9                   	leave  
  800866:	c3                   	ret    

00800867 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	56                   	push   %esi
  80086b:	53                   	push   %ebx
  80086c:	8b 75 08             	mov    0x8(%ebp),%esi
  80086f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800872:	89 f3                	mov    %esi,%ebx
  800874:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800877:	89 f2                	mov    %esi,%edx
  800879:	eb 0f                	jmp    80088a <strncpy+0x23>
		*dst++ = *src;
  80087b:	83 c2 01             	add    $0x1,%edx
  80087e:	0f b6 01             	movzbl (%ecx),%eax
  800881:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800884:	80 39 01             	cmpb   $0x1,(%ecx)
  800887:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088a:	39 da                	cmp    %ebx,%edx
  80088c:	75 ed                	jne    80087b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80088e:	89 f0                	mov    %esi,%eax
  800890:	5b                   	pop    %ebx
  800891:	5e                   	pop    %esi
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	56                   	push   %esi
  800898:	53                   	push   %ebx
  800899:	8b 75 08             	mov    0x8(%ebp),%esi
  80089c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089f:	8b 55 10             	mov    0x10(%ebp),%edx
  8008a2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a4:	85 d2                	test   %edx,%edx
  8008a6:	74 21                	je     8008c9 <strlcpy+0x35>
  8008a8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008ac:	89 f2                	mov    %esi,%edx
  8008ae:	eb 09                	jmp    8008b9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b0:	83 c2 01             	add    $0x1,%edx
  8008b3:	83 c1 01             	add    $0x1,%ecx
  8008b6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b9:	39 c2                	cmp    %eax,%edx
  8008bb:	74 09                	je     8008c6 <strlcpy+0x32>
  8008bd:	0f b6 19             	movzbl (%ecx),%ebx
  8008c0:	84 db                	test   %bl,%bl
  8008c2:	75 ec                	jne    8008b0 <strlcpy+0x1c>
  8008c4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008c6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008c9:	29 f0                	sub    %esi,%eax
}
  8008cb:	5b                   	pop    %ebx
  8008cc:	5e                   	pop    %esi
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d8:	eb 06                	jmp    8008e0 <strcmp+0x11>
		p++, q++;
  8008da:	83 c1 01             	add    $0x1,%ecx
  8008dd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e0:	0f b6 01             	movzbl (%ecx),%eax
  8008e3:	84 c0                	test   %al,%al
  8008e5:	74 04                	je     8008eb <strcmp+0x1c>
  8008e7:	3a 02                	cmp    (%edx),%al
  8008e9:	74 ef                	je     8008da <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008eb:	0f b6 c0             	movzbl %al,%eax
  8008ee:	0f b6 12             	movzbl (%edx),%edx
  8008f1:	29 d0                	sub    %edx,%eax
}
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	53                   	push   %ebx
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ff:	89 c3                	mov    %eax,%ebx
  800901:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800904:	eb 06                	jmp    80090c <strncmp+0x17>
		n--, p++, q++;
  800906:	83 c0 01             	add    $0x1,%eax
  800909:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80090c:	39 d8                	cmp    %ebx,%eax
  80090e:	74 15                	je     800925 <strncmp+0x30>
  800910:	0f b6 08             	movzbl (%eax),%ecx
  800913:	84 c9                	test   %cl,%cl
  800915:	74 04                	je     80091b <strncmp+0x26>
  800917:	3a 0a                	cmp    (%edx),%cl
  800919:	74 eb                	je     800906 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80091b:	0f b6 00             	movzbl (%eax),%eax
  80091e:	0f b6 12             	movzbl (%edx),%edx
  800921:	29 d0                	sub    %edx,%eax
  800923:	eb 05                	jmp    80092a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800925:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80092a:	5b                   	pop    %ebx
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800937:	eb 07                	jmp    800940 <strchr+0x13>
		if (*s == c)
  800939:	38 ca                	cmp    %cl,%dl
  80093b:	74 0f                	je     80094c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80093d:	83 c0 01             	add    $0x1,%eax
  800940:	0f b6 10             	movzbl (%eax),%edx
  800943:	84 d2                	test   %dl,%dl
  800945:	75 f2                	jne    800939 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800947:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800958:	eb 03                	jmp    80095d <strfind+0xf>
  80095a:	83 c0 01             	add    $0x1,%eax
  80095d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800960:	38 ca                	cmp    %cl,%dl
  800962:	74 04                	je     800968 <strfind+0x1a>
  800964:	84 d2                	test   %dl,%dl
  800966:	75 f2                	jne    80095a <strfind+0xc>
			break;
	return (char *) s;
}
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	57                   	push   %edi
  80096e:	56                   	push   %esi
  80096f:	53                   	push   %ebx
  800970:	8b 7d 08             	mov    0x8(%ebp),%edi
  800973:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800976:	85 c9                	test   %ecx,%ecx
  800978:	74 36                	je     8009b0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80097a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800980:	75 28                	jne    8009aa <memset+0x40>
  800982:	f6 c1 03             	test   $0x3,%cl
  800985:	75 23                	jne    8009aa <memset+0x40>
		c &= 0xFF;
  800987:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80098b:	89 d3                	mov    %edx,%ebx
  80098d:	c1 e3 08             	shl    $0x8,%ebx
  800990:	89 d6                	mov    %edx,%esi
  800992:	c1 e6 18             	shl    $0x18,%esi
  800995:	89 d0                	mov    %edx,%eax
  800997:	c1 e0 10             	shl    $0x10,%eax
  80099a:	09 f0                	or     %esi,%eax
  80099c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80099e:	89 d8                	mov    %ebx,%eax
  8009a0:	09 d0                	or     %edx,%eax
  8009a2:	c1 e9 02             	shr    $0x2,%ecx
  8009a5:	fc                   	cld    
  8009a6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a8:	eb 06                	jmp    8009b0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ad:	fc                   	cld    
  8009ae:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b0:	89 f8                	mov    %edi,%eax
  8009b2:	5b                   	pop    %ebx
  8009b3:	5e                   	pop    %esi
  8009b4:	5f                   	pop    %edi
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	57                   	push   %edi
  8009bb:	56                   	push   %esi
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c5:	39 c6                	cmp    %eax,%esi
  8009c7:	73 35                	jae    8009fe <memmove+0x47>
  8009c9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009cc:	39 d0                	cmp    %edx,%eax
  8009ce:	73 2e                	jae    8009fe <memmove+0x47>
		s += n;
		d += n;
  8009d0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d3:	89 d6                	mov    %edx,%esi
  8009d5:	09 fe                	or     %edi,%esi
  8009d7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009dd:	75 13                	jne    8009f2 <memmove+0x3b>
  8009df:	f6 c1 03             	test   $0x3,%cl
  8009e2:	75 0e                	jne    8009f2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009e4:	83 ef 04             	sub    $0x4,%edi
  8009e7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ea:	c1 e9 02             	shr    $0x2,%ecx
  8009ed:	fd                   	std    
  8009ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f0:	eb 09                	jmp    8009fb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009f2:	83 ef 01             	sub    $0x1,%edi
  8009f5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009f8:	fd                   	std    
  8009f9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009fb:	fc                   	cld    
  8009fc:	eb 1d                	jmp    800a1b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fe:	89 f2                	mov    %esi,%edx
  800a00:	09 c2                	or     %eax,%edx
  800a02:	f6 c2 03             	test   $0x3,%dl
  800a05:	75 0f                	jne    800a16 <memmove+0x5f>
  800a07:	f6 c1 03             	test   $0x3,%cl
  800a0a:	75 0a                	jne    800a16 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a0c:	c1 e9 02             	shr    $0x2,%ecx
  800a0f:	89 c7                	mov    %eax,%edi
  800a11:	fc                   	cld    
  800a12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a14:	eb 05                	jmp    800a1b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a16:	89 c7                	mov    %eax,%edi
  800a18:	fc                   	cld    
  800a19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a1b:	5e                   	pop    %esi
  800a1c:	5f                   	pop    %edi
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a22:	ff 75 10             	pushl  0x10(%ebp)
  800a25:	ff 75 0c             	pushl  0xc(%ebp)
  800a28:	ff 75 08             	pushl  0x8(%ebp)
  800a2b:	e8 87 ff ff ff       	call   8009b7 <memmove>
}
  800a30:	c9                   	leave  
  800a31:	c3                   	ret    

00800a32 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	56                   	push   %esi
  800a36:	53                   	push   %ebx
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3d:	89 c6                	mov    %eax,%esi
  800a3f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a42:	eb 1a                	jmp    800a5e <memcmp+0x2c>
		if (*s1 != *s2)
  800a44:	0f b6 08             	movzbl (%eax),%ecx
  800a47:	0f b6 1a             	movzbl (%edx),%ebx
  800a4a:	38 d9                	cmp    %bl,%cl
  800a4c:	74 0a                	je     800a58 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a4e:	0f b6 c1             	movzbl %cl,%eax
  800a51:	0f b6 db             	movzbl %bl,%ebx
  800a54:	29 d8                	sub    %ebx,%eax
  800a56:	eb 0f                	jmp    800a67 <memcmp+0x35>
		s1++, s2++;
  800a58:	83 c0 01             	add    $0x1,%eax
  800a5b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5e:	39 f0                	cmp    %esi,%eax
  800a60:	75 e2                	jne    800a44 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a67:	5b                   	pop    %ebx
  800a68:	5e                   	pop    %esi
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	53                   	push   %ebx
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a72:	89 c1                	mov    %eax,%ecx
  800a74:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a77:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a7b:	eb 0a                	jmp    800a87 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a7d:	0f b6 10             	movzbl (%eax),%edx
  800a80:	39 da                	cmp    %ebx,%edx
  800a82:	74 07                	je     800a8b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a84:	83 c0 01             	add    $0x1,%eax
  800a87:	39 c8                	cmp    %ecx,%eax
  800a89:	72 f2                	jb     800a7d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a8b:	5b                   	pop    %ebx
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	57                   	push   %edi
  800a92:	56                   	push   %esi
  800a93:	53                   	push   %ebx
  800a94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9a:	eb 03                	jmp    800a9f <strtol+0x11>
		s++;
  800a9c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9f:	0f b6 01             	movzbl (%ecx),%eax
  800aa2:	3c 20                	cmp    $0x20,%al
  800aa4:	74 f6                	je     800a9c <strtol+0xe>
  800aa6:	3c 09                	cmp    $0x9,%al
  800aa8:	74 f2                	je     800a9c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aaa:	3c 2b                	cmp    $0x2b,%al
  800aac:	75 0a                	jne    800ab8 <strtol+0x2a>
		s++;
  800aae:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab6:	eb 11                	jmp    800ac9 <strtol+0x3b>
  800ab8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800abd:	3c 2d                	cmp    $0x2d,%al
  800abf:	75 08                	jne    800ac9 <strtol+0x3b>
		s++, neg = 1;
  800ac1:	83 c1 01             	add    $0x1,%ecx
  800ac4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800acf:	75 15                	jne    800ae6 <strtol+0x58>
  800ad1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad4:	75 10                	jne    800ae6 <strtol+0x58>
  800ad6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ada:	75 7c                	jne    800b58 <strtol+0xca>
		s += 2, base = 16;
  800adc:	83 c1 02             	add    $0x2,%ecx
  800adf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae4:	eb 16                	jmp    800afc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ae6:	85 db                	test   %ebx,%ebx
  800ae8:	75 12                	jne    800afc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aea:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aef:	80 39 30             	cmpb   $0x30,(%ecx)
  800af2:	75 08                	jne    800afc <strtol+0x6e>
		s++, base = 8;
  800af4:	83 c1 01             	add    $0x1,%ecx
  800af7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800afc:	b8 00 00 00 00       	mov    $0x0,%eax
  800b01:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b04:	0f b6 11             	movzbl (%ecx),%edx
  800b07:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b0a:	89 f3                	mov    %esi,%ebx
  800b0c:	80 fb 09             	cmp    $0x9,%bl
  800b0f:	77 08                	ja     800b19 <strtol+0x8b>
			dig = *s - '0';
  800b11:	0f be d2             	movsbl %dl,%edx
  800b14:	83 ea 30             	sub    $0x30,%edx
  800b17:	eb 22                	jmp    800b3b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b19:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b1c:	89 f3                	mov    %esi,%ebx
  800b1e:	80 fb 19             	cmp    $0x19,%bl
  800b21:	77 08                	ja     800b2b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b23:	0f be d2             	movsbl %dl,%edx
  800b26:	83 ea 57             	sub    $0x57,%edx
  800b29:	eb 10                	jmp    800b3b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b2b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b2e:	89 f3                	mov    %esi,%ebx
  800b30:	80 fb 19             	cmp    $0x19,%bl
  800b33:	77 16                	ja     800b4b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b35:	0f be d2             	movsbl %dl,%edx
  800b38:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b3b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b3e:	7d 0b                	jge    800b4b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b40:	83 c1 01             	add    $0x1,%ecx
  800b43:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b47:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b49:	eb b9                	jmp    800b04 <strtol+0x76>

	if (endptr)
  800b4b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b4f:	74 0d                	je     800b5e <strtol+0xd0>
		*endptr = (char *) s;
  800b51:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b54:	89 0e                	mov    %ecx,(%esi)
  800b56:	eb 06                	jmp    800b5e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b58:	85 db                	test   %ebx,%ebx
  800b5a:	74 98                	je     800af4 <strtol+0x66>
  800b5c:	eb 9e                	jmp    800afc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b5e:	89 c2                	mov    %eax,%edx
  800b60:	f7 da                	neg    %edx
  800b62:	85 ff                	test   %edi,%edi
  800b64:	0f 45 c2             	cmovne %edx,%eax
}
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	83 ec 04             	sub    $0x4,%esp
  800b75:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800b78:	57                   	push   %edi
  800b79:	e8 6e fc ff ff       	call   8007ec <strlen>
  800b7e:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b81:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800b84:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800b89:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b8e:	eb 46                	jmp    800bd6 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800b90:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800b94:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b97:	80 f9 09             	cmp    $0x9,%cl
  800b9a:	77 08                	ja     800ba4 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800b9c:	0f be d2             	movsbl %dl,%edx
  800b9f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800ba2:	eb 27                	jmp    800bcb <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800ba4:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800ba7:	80 f9 05             	cmp    $0x5,%cl
  800baa:	77 08                	ja     800bb4 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800bac:	0f be d2             	movsbl %dl,%edx
  800baf:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800bb2:	eb 17                	jmp    800bcb <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800bb4:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800bb7:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800bba:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800bbf:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800bc3:	77 06                	ja     800bcb <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800bc5:	0f be d2             	movsbl %dl,%edx
  800bc8:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800bcb:	0f af ce             	imul   %esi,%ecx
  800bce:	01 c8                	add    %ecx,%eax
		base *= 16;
  800bd0:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800bd3:	83 eb 01             	sub    $0x1,%ebx
  800bd6:	83 fb 01             	cmp    $0x1,%ebx
  800bd9:	7f b5                	jg     800b90 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800bdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	89 c3                	mov    %eax,%ebx
  800bf6:	89 c7                	mov    %eax,%edi
  800bf8:	89 c6                	mov    %eax,%esi
  800bfa:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c07:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800c11:	89 d1                	mov    %edx,%ecx
  800c13:	89 d3                	mov    %edx,%ebx
  800c15:	89 d7                	mov    %edx,%edi
  800c17:	89 d6                	mov    %edx,%esi
  800c19:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
  800c26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c33:	8b 55 08             	mov    0x8(%ebp),%edx
  800c36:	89 cb                	mov    %ecx,%ebx
  800c38:	89 cf                	mov    %ecx,%edi
  800c3a:	89 ce                	mov    %ecx,%esi
  800c3c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	7e 17                	jle    800c59 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c42:	83 ec 0c             	sub    $0xc,%esp
  800c45:	50                   	push   %eax
  800c46:	6a 03                	push   $0x3
  800c48:	68 df 26 80 00       	push   $0x8026df
  800c4d:	6a 23                	push   $0x23
  800c4f:	68 fc 26 80 00       	push   $0x8026fc
  800c54:	e8 69 13 00 00       	call   801fc2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c67:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6c:	b8 02 00 00 00       	mov    $0x2,%eax
  800c71:	89 d1                	mov    %edx,%ecx
  800c73:	89 d3                	mov    %edx,%ebx
  800c75:	89 d7                	mov    %edx,%edi
  800c77:	89 d6                	mov    %edx,%esi
  800c79:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_yield>:

void
sys_yield(void)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c86:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c90:	89 d1                	mov    %edx,%ecx
  800c92:	89 d3                	mov    %edx,%ebx
  800c94:	89 d7                	mov    %edx,%edi
  800c96:	89 d6                	mov    %edx,%esi
  800c98:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	57                   	push   %edi
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
  800ca5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	be 00 00 00 00       	mov    $0x0,%esi
  800cad:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbb:	89 f7                	mov    %esi,%edi
  800cbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbf:	85 c0                	test   %eax,%eax
  800cc1:	7e 17                	jle    800cda <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc3:	83 ec 0c             	sub    $0xc,%esp
  800cc6:	50                   	push   %eax
  800cc7:	6a 04                	push   $0x4
  800cc9:	68 df 26 80 00       	push   $0x8026df
  800cce:	6a 23                	push   $0x23
  800cd0:	68 fc 26 80 00       	push   $0x8026fc
  800cd5:	e8 e8 12 00 00       	call   801fc2 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
  800ce8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ceb:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cfc:	8b 75 18             	mov    0x18(%ebp),%esi
  800cff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	7e 17                	jle    800d1c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d05:	83 ec 0c             	sub    $0xc,%esp
  800d08:	50                   	push   %eax
  800d09:	6a 05                	push   $0x5
  800d0b:	68 df 26 80 00       	push   $0x8026df
  800d10:	6a 23                	push   $0x23
  800d12:	68 fc 26 80 00       	push   $0x8026fc
  800d17:	e8 a6 12 00 00       	call   801fc2 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
  800d2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d32:	b8 06 00 00 00       	mov    $0x6,%eax
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	89 df                	mov    %ebx,%edi
  800d3f:	89 de                	mov    %ebx,%esi
  800d41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d43:	85 c0                	test   %eax,%eax
  800d45:	7e 17                	jle    800d5e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	50                   	push   %eax
  800d4b:	6a 06                	push   $0x6
  800d4d:	68 df 26 80 00       	push   $0x8026df
  800d52:	6a 23                	push   $0x23
  800d54:	68 fc 26 80 00       	push   $0x8026fc
  800d59:	e8 64 12 00 00       	call   801fc2 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d74:	b8 08 00 00 00       	mov    $0x8,%eax
  800d79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	89 df                	mov    %ebx,%edi
  800d81:	89 de                	mov    %ebx,%esi
  800d83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d85:	85 c0                	test   %eax,%eax
  800d87:	7e 17                	jle    800da0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	50                   	push   %eax
  800d8d:	6a 08                	push   $0x8
  800d8f:	68 df 26 80 00       	push   $0x8026df
  800d94:	6a 23                	push   $0x23
  800d96:	68 fc 26 80 00       	push   $0x8026fc
  800d9b:	e8 22 12 00 00       	call   801fc2 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800da0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
  800dae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	89 df                	mov    %ebx,%edi
  800dc3:	89 de                	mov    %ebx,%esi
  800dc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	7e 17                	jle    800de2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcb:	83 ec 0c             	sub    $0xc,%esp
  800dce:	50                   	push   %eax
  800dcf:	6a 0a                	push   $0xa
  800dd1:	68 df 26 80 00       	push   $0x8026df
  800dd6:	6a 23                	push   $0x23
  800dd8:	68 fc 26 80 00       	push   $0x8026fc
  800ddd:	e8 e0 11 00 00       	call   801fc2 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800de2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	57                   	push   %edi
  800dee:	56                   	push   %esi
  800def:	53                   	push   %ebx
  800df0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df8:	b8 09 00 00 00       	mov    $0x9,%eax
  800dfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e00:	8b 55 08             	mov    0x8(%ebp),%edx
  800e03:	89 df                	mov    %ebx,%edi
  800e05:	89 de                	mov    %ebx,%esi
  800e07:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	7e 17                	jle    800e24 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0d:	83 ec 0c             	sub    $0xc,%esp
  800e10:	50                   	push   %eax
  800e11:	6a 09                	push   $0x9
  800e13:	68 df 26 80 00       	push   $0x8026df
  800e18:	6a 23                	push   $0x23
  800e1a:	68 fc 26 80 00       	push   $0x8026fc
  800e1f:	e8 9e 11 00 00       	call   801fc2 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e32:	be 00 00 00 00       	mov    $0x0,%esi
  800e37:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e45:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e48:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5f                   	pop    %edi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	57                   	push   %edi
  800e53:	56                   	push   %esi
  800e54:	53                   	push   %ebx
  800e55:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e62:	8b 55 08             	mov    0x8(%ebp),%edx
  800e65:	89 cb                	mov    %ecx,%ebx
  800e67:	89 cf                	mov    %ecx,%edi
  800e69:	89 ce                	mov    %ecx,%esi
  800e6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	7e 17                	jle    800e88 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e71:	83 ec 0c             	sub    $0xc,%esp
  800e74:	50                   	push   %eax
  800e75:	6a 0d                	push   $0xd
  800e77:	68 df 26 80 00       	push   $0x8026df
  800e7c:	6a 23                	push   $0x23
  800e7e:	68 fc 26 80 00       	push   $0x8026fc
  800e83:	e8 3a 11 00 00       	call   801fc2 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5f                   	pop    %edi
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	53                   	push   %ebx
  800e94:	83 ec 04             	sub    $0x4,%esp
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax

	
	void *addr = (void *) utf->utf_fault_va;
  800e9a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800e9c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ea0:	74 11                	je     800eb3 <pgfault+0x23>
  800ea2:	89 d8                	mov    %ebx,%eax
  800ea4:	c1 e8 0c             	shr    $0xc,%eax
  800ea7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eae:	f6 c4 08             	test   $0x8,%ah
  800eb1:	75 14                	jne    800ec7 <pgfault+0x37>
		panic("page fault");
  800eb3:	83 ec 04             	sub    $0x4,%esp
  800eb6:	68 0a 27 80 00       	push   $0x80270a
  800ebb:	6a 5b                	push   $0x5b
  800ebd:	68 15 27 80 00       	push   $0x802715
  800ec2:	e8 fb 10 00 00       	call   801fc2 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// allocate a new page and map it at a temporary location
	if((r = sys_page_alloc(0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800ec7:	83 ec 04             	sub    $0x4,%esp
  800eca:	6a 07                	push   $0x7
  800ecc:	68 00 f0 7f 00       	push   $0x7ff000
  800ed1:	6a 00                	push   $0x0
  800ed3:	e8 c7 fd ff ff       	call   800c9f <sys_page_alloc>
  800ed8:	83 c4 10             	add    $0x10,%esp
  800edb:	85 c0                	test   %eax,%eax
  800edd:	79 12                	jns    800ef1 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800edf:	50                   	push   %eax
  800ee0:	68 20 27 80 00       	push   $0x802720
  800ee5:	6a 66                	push   $0x66
  800ee7:	68 15 27 80 00       	push   $0x802715
  800eec:	e8 d1 10 00 00       	call   801fc2 <_panic>

	// copy date to new page
	//strncpy((char *)PFTEMP, (char *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
	memcpy((void *)PFTEMP, (void *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
  800ef1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800ef7:	83 ec 04             	sub    $0x4,%esp
  800efa:	68 00 10 00 00       	push   $0x1000
  800eff:	53                   	push   %ebx
  800f00:	68 00 f0 7f 00       	push   $0x7ff000
  800f05:	e8 15 fb ff ff       	call   800a1f <memcpy>

	// move the new page to the old page's address
	if((r = sys_page_map(0, (void *)PFTEMP, 0, (void *)
  800f0a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f11:	53                   	push   %ebx
  800f12:	6a 00                	push   $0x0
  800f14:	68 00 f0 7f 00       	push   $0x7ff000
  800f19:	6a 00                	push   $0x0
  800f1b:	e8 c2 fd ff ff       	call   800ce2 <sys_page_map>
  800f20:	83 c4 20             	add    $0x20,%esp
  800f23:	85 c0                	test   %eax,%eax
  800f25:	79 12                	jns    800f39 <pgfault+0xa9>
		(ROUNDDOWN(addr, PGSIZE)), PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_map: %e", r);
  800f27:	50                   	push   %eax
  800f28:	68 33 27 80 00       	push   $0x802733
  800f2d:	6a 6f                	push   $0x6f
  800f2f:	68 15 27 80 00       	push   $0x802715
  800f34:	e8 89 10 00 00       	call   801fc2 <_panic>

	// unmap page on PFTEMP
	if((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800f39:	83 ec 08             	sub    $0x8,%esp
  800f3c:	68 00 f0 7f 00       	push   $0x7ff000
  800f41:	6a 00                	push   $0x0
  800f43:	e8 dc fd ff ff       	call   800d24 <sys_page_unmap>
  800f48:	83 c4 10             	add    $0x10,%esp
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	79 12                	jns    800f61 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  800f4f:	50                   	push   %eax
  800f50:	68 44 27 80 00       	push   $0x802744
  800f55:	6a 73                	push   $0x73
  800f57:	68 15 27 80 00       	push   $0x802715
  800f5c:	e8 61 10 00 00       	call   801fc2 <_panic>


}
  800f61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f64:	c9                   	leave  
  800f65:	c3                   	ret    

00800f66 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	57                   	push   %edi
  800f6a:	56                   	push   %esi
  800f6b:	53                   	push   %ebx
  800f6c:	83 ec 28             	sub    $0x28,%esp

	#ifdef CHALLENGE 
	set_exception_handler(pgfault, T_PGFLT);
	#else
	// set up page fault handler
	set_pgfault_handler(pgfault);
  800f6f:	68 90 0e 80 00       	push   $0x800e90
  800f74:	e8 8f 10 00 00       	call   802008 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f79:	b8 07 00 00 00       	mov    $0x7,%eax
  800f7e:	cd 30                	int    $0x30
  800f80:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f83:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	#endif

	// create a child
	envid = sys_exofork();
	if (envid < 0)
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	79 15                	jns    800fa2 <fork+0x3c>
		panic("sys_exofork: %e", envid);
  800f8d:	50                   	push   %eax
  800f8e:	68 57 27 80 00       	push   $0x802757
  800f93:	68 d0 00 00 00       	push   $0xd0
  800f98:	68 15 27 80 00       	push   $0x802715
  800f9d:	e8 20 10 00 00       	call   801fc2 <_panic>
  800fa2:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800fa7:	be 00 08 00 00       	mov    $0x800,%esi
	// we are the child
	if(envid == 0) {
  800fac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800fb0:	75 21                	jne    800fd3 <fork+0x6d>
		// the copied valude of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800fb2:	e8 aa fc ff ff       	call   800c61 <sys_getenvid>
  800fb7:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fbc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fbf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fc4:	a3 0c 40 80 00       	mov    %eax,0x80400c
		/*// alloc exception stack
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
			PTE_P | PTE_U | PTE_W)) < 0)
			panic("sys_page_alloc: %e", r);*/

		return 0;
  800fc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fce:	e9 a3 01 00 00       	jmp    801176 <fork+0x210>
{
	int r;

	// LAB 4: Your code here.
	
	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P))
  800fd3:	89 d8                	mov    %ebx,%eax
  800fd5:	c1 e8 16             	shr    $0x16,%eax
  800fd8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fdf:	a8 01                	test   $0x1,%al
  800fe1:	0f 84 f0 00 00 00    	je     8010d7 <fork+0x171>
		return 0;

	// virtual page pn's page table entry
	pte_t pe = uvpt[pn];
  800fe7:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi


	if((pe & PTE_P) && (pe & PTE_U)) {
  800fee:	89 f8                	mov    %edi,%eax
  800ff0:	83 e0 05             	and    $0x5,%eax
  800ff3:	83 f8 05             	cmp    $0x5,%eax
  800ff6:	0f 85 db 00 00 00    	jne    8010d7 <fork+0x171>
		// share with the child environment 
		if(pe & PTE_SHARE) {
  800ffc:	f7 c7 00 04 00 00    	test   $0x400,%edi
  801002:	74 36                	je     80103a <fork+0xd4>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  80100d:	57                   	push   %edi
  80100e:	53                   	push   %ebx
  80100f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801012:	53                   	push   %ebx
  801013:	6a 00                	push   $0x0
  801015:	e8 c8 fc ff ff       	call   800ce2 <sys_page_map>
  80101a:	83 c4 20             	add    $0x20,%esp
  80101d:	85 c0                	test   %eax,%eax
  80101f:	0f 89 b2 00 00 00    	jns    8010d7 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  801025:	50                   	push   %eax
  801026:	68 67 27 80 00       	push   $0x802767
  80102b:	68 97 00 00 00       	push   $0x97
  801030:	68 15 27 80 00       	push   $0x802715
  801035:	e8 88 0f 00 00       	call   801fc2 <_panic>
		}
		// the page is writable or copy-on-write
		else if((pe & PTE_W) || (pe & PTE_COW)) {
  80103a:	f7 c7 02 08 00 00    	test   $0x802,%edi
  801040:	74 63                	je     8010a5 <fork+0x13f>
			// create the child mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, 
  801042:	81 e7 05 06 00 00    	and    $0x605,%edi
  801048:	81 cf 00 08 00 00    	or     $0x800,%edi
  80104e:	83 ec 0c             	sub    $0xc,%esp
  801051:	57                   	push   %edi
  801052:	53                   	push   %ebx
  801053:	ff 75 e4             	pushl  -0x1c(%ebp)
  801056:	53                   	push   %ebx
  801057:	6a 00                	push   $0x0
  801059:	e8 84 fc ff ff       	call   800ce2 <sys_page_map>
  80105e:	83 c4 20             	add    $0x20,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	79 15                	jns    80107a <fork+0x114>
				(void *)(pn*PGSIZE), (pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  801065:	50                   	push   %eax
  801066:	68 67 27 80 00       	push   $0x802767
  80106b:	68 9e 00 00 00       	push   $0x9e
  801070:	68 15 27 80 00       	push   $0x802715
  801075:	e8 48 0f 00 00       	call   801fc2 <_panic>
			// map the parent mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE),
  80107a:	83 ec 0c             	sub    $0xc,%esp
  80107d:	57                   	push   %edi
  80107e:	53                   	push   %ebx
  80107f:	6a 00                	push   $0x0
  801081:	53                   	push   %ebx
  801082:	6a 00                	push   $0x0
  801084:	e8 59 fc ff ff       	call   800ce2 <sys_page_map>
  801089:	83 c4 20             	add    $0x20,%esp
  80108c:	85 c0                	test   %eax,%eax
  80108e:	79 47                	jns    8010d7 <fork+0x171>
				(pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  801090:	50                   	push   %eax
  801091:	68 67 27 80 00       	push   $0x802767
  801096:	68 a2 00 00 00       	push   $0xa2
  80109b:	68 15 27 80 00       	push   $0x802715
  8010a0:	e8 1d 0f 00 00       	call   801fc2 <_panic>
		}	
		else {
			// create the child mapping read only
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  8010ae:	57                   	push   %edi
  8010af:	53                   	push   %ebx
  8010b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b3:	53                   	push   %ebx
  8010b4:	6a 00                	push   $0x0
  8010b6:	e8 27 fc ff ff       	call   800ce2 <sys_page_map>
  8010bb:	83 c4 20             	add    $0x20,%esp
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	79 15                	jns    8010d7 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  8010c2:	50                   	push   %eax
  8010c3:	68 67 27 80 00       	push   $0x802767
  8010c8:	68 a8 00 00 00       	push   $0xa8
  8010cd:	68 15 27 80 00       	push   $0x802715
  8010d2:	e8 eb 0e 00 00       	call   801fc2 <_panic>
			panic("sys_page_alloc: %e", r);*/

		return 0;
	}
	// copy address to child environment's page dirctory
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn)
  8010d7:	83 c6 01             	add    $0x1,%esi
  8010da:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010e0:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8010e6:	0f 85 e7 fe ff ff    	jne    800fd3 <fork+0x6d>
	#ifdef CHALLENGE 
	if((r = sys_env_set_exception_upcall(envid, thisenv->env_exception_upcall)) < 0)
		panic("sys_env_set_exception_upcall: %e", r);
	#else
	// set child's page fault handler
	if((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  8010ec:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8010f1:	8b 40 64             	mov    0x64(%eax),%eax
  8010f4:	83 ec 08             	sub    $0x8,%esp
  8010f7:	50                   	push   %eax
  8010f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8010fb:	e8 ea fc ff ff       	call   800dea <sys_env_set_pgfault_upcall>
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	85 c0                	test   %eax,%eax
  801105:	79 15                	jns    80111c <fork+0x1b6>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801107:	50                   	push   %eax
  801108:	68 a0 27 80 00       	push   $0x8027a0
  80110d:	68 e9 00 00 00       	push   $0xe9
  801112:	68 15 27 80 00       	push   $0x802715
  801117:	e8 a6 0e 00 00       	call   801fc2 <_panic>
	#endif

	// alloc exception stack for child environment
	if((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), 
  80111c:	83 ec 04             	sub    $0x4,%esp
  80111f:	6a 07                	push   $0x7
  801121:	68 00 f0 bf ee       	push   $0xeebff000
  801126:	ff 75 e0             	pushl  -0x20(%ebp)
  801129:	e8 71 fb ff ff       	call   800c9f <sys_page_alloc>
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	85 c0                	test   %eax,%eax
  801133:	79 15                	jns    80114a <fork+0x1e4>
		PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
  801135:	50                   	push   %eax
  801136:	68 20 27 80 00       	push   $0x802720
  80113b:	68 ef 00 00 00       	push   $0xef
  801140:	68 15 27 80 00       	push   $0x802715
  801145:	e8 78 0e 00 00       	call   801fc2 <_panic>

	// start the child environment running
	if((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80114a:	83 ec 08             	sub    $0x8,%esp
  80114d:	6a 02                	push   $0x2
  80114f:	ff 75 e0             	pushl  -0x20(%ebp)
  801152:	e8 0f fc ff ff       	call   800d66 <sys_env_set_status>
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	85 c0                	test   %eax,%eax
  80115c:	79 15                	jns    801173 <fork+0x20d>
		panic("sys_env_set_status: %e", r);
  80115e:	50                   	push   %eax
  80115f:	68 73 27 80 00       	push   $0x802773
  801164:	68 f3 00 00 00       	push   $0xf3
  801169:	68 15 27 80 00       	push   $0x802715
  80116e:	e8 4f 0e 00 00       	call   801fc2 <_panic>

	return envid;
  801173:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801176:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801179:	5b                   	pop    %ebx
  80117a:	5e                   	pop    %esi
  80117b:	5f                   	pop    %edi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    

0080117e <sfork>:

// Challenge!
int
sfork(void)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801184:	68 8a 27 80 00       	push   $0x80278a
  801189:	68 fc 00 00 00       	push   $0xfc
  80118e:	68 15 27 80 00       	push   $0x802715
  801193:	e8 2a 0e 00 00       	call   801fc2 <_panic>

00801198 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	56                   	push   %esi
  80119c:	53                   	push   %ebx
  80119d:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  8011a6:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8011a8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8011ad:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  8011b0:	83 ec 0c             	sub    $0xc,%esp
  8011b3:	50                   	push   %eax
  8011b4:	e8 96 fc ff ff       	call   800e4f <sys_ipc_recv>
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	79 16                	jns    8011d6 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  8011c0:	85 f6                	test   %esi,%esi
  8011c2:	74 06                	je     8011ca <ipc_recv+0x32>
			*from_env_store = 0;
  8011c4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  8011ca:	85 db                	test   %ebx,%ebx
  8011cc:	74 2c                	je     8011fa <ipc_recv+0x62>
			*perm_store = 0;
  8011ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011d4:	eb 24                	jmp    8011fa <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  8011d6:	85 f6                	test   %esi,%esi
  8011d8:	74 0a                	je     8011e4 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  8011da:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8011df:	8b 40 74             	mov    0x74(%eax),%eax
  8011e2:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  8011e4:	85 db                	test   %ebx,%ebx
  8011e6:	74 0a                	je     8011f2 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  8011e8:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8011ed:	8b 40 78             	mov    0x78(%eax),%eax
  8011f0:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  8011f2:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8011f7:	8b 40 70             	mov    0x70(%eax),%eax
}
  8011fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011fd:	5b                   	pop    %ebx
  8011fe:	5e                   	pop    %esi
  8011ff:	5d                   	pop    %ebp
  801200:	c3                   	ret    

00801201 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	57                   	push   %edi
  801205:	56                   	push   %esi
  801206:	53                   	push   %ebx
  801207:	83 ec 0c             	sub    $0xc,%esp
  80120a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80120d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801210:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801213:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801215:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80121a:	0f 44 d8             	cmove  %eax,%ebx
  80121d:	eb 1e                	jmp    80123d <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  80121f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801222:	74 14                	je     801238 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801224:	83 ec 04             	sub    $0x4,%esp
  801227:	68 c0 27 80 00       	push   $0x8027c0
  80122c:	6a 44                	push   $0x44
  80122e:	68 eb 27 80 00       	push   $0x8027eb
  801233:	e8 8a 0d 00 00       	call   801fc2 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801238:	e8 43 fa ff ff       	call   800c80 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80123d:	ff 75 14             	pushl  0x14(%ebp)
  801240:	53                   	push   %ebx
  801241:	56                   	push   %esi
  801242:	57                   	push   %edi
  801243:	e8 e4 fb ff ff       	call   800e2c <sys_ipc_try_send>
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	85 c0                	test   %eax,%eax
  80124d:	78 d0                	js     80121f <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  80124f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801252:	5b                   	pop    %ebx
  801253:	5e                   	pop    %esi
  801254:	5f                   	pop    %edi
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    

00801257 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80125d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801262:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801265:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80126b:	8b 52 50             	mov    0x50(%edx),%edx
  80126e:	39 ca                	cmp    %ecx,%edx
  801270:	75 0d                	jne    80127f <ipc_find_env+0x28>
			return envs[i].env_id;
  801272:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801275:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80127a:	8b 40 48             	mov    0x48(%eax),%eax
  80127d:	eb 0f                	jmp    80128e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80127f:	83 c0 01             	add    $0x1,%eax
  801282:	3d 00 04 00 00       	cmp    $0x400,%eax
  801287:	75 d9                	jne    801262 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801289:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80128e:	5d                   	pop    %ebp
  80128f:	c3                   	ret    

00801290 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801293:	8b 45 08             	mov    0x8(%ebp),%eax
  801296:	05 00 00 00 30       	add    $0x30000000,%eax
  80129b:	c1 e8 0c             	shr    $0xc,%eax
}
  80129e:	5d                   	pop    %ebp
  80129f:	c3                   	ret    

008012a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8012ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012b0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012b5:	5d                   	pop    %ebp
  8012b6:	c3                   	ret    

008012b7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012bd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012c2:	89 c2                	mov    %eax,%edx
  8012c4:	c1 ea 16             	shr    $0x16,%edx
  8012c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ce:	f6 c2 01             	test   $0x1,%dl
  8012d1:	74 11                	je     8012e4 <fd_alloc+0x2d>
  8012d3:	89 c2                	mov    %eax,%edx
  8012d5:	c1 ea 0c             	shr    $0xc,%edx
  8012d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012df:	f6 c2 01             	test   $0x1,%dl
  8012e2:	75 09                	jne    8012ed <fd_alloc+0x36>
			*fd_store = fd;
  8012e4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012eb:	eb 17                	jmp    801304 <fd_alloc+0x4d>
  8012ed:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012f2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012f7:	75 c9                	jne    8012c2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012f9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012ff:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801304:	5d                   	pop    %ebp
  801305:	c3                   	ret    

00801306 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
  801309:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80130c:	83 f8 1f             	cmp    $0x1f,%eax
  80130f:	77 36                	ja     801347 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801311:	c1 e0 0c             	shl    $0xc,%eax
  801314:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801319:	89 c2                	mov    %eax,%edx
  80131b:	c1 ea 16             	shr    $0x16,%edx
  80131e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801325:	f6 c2 01             	test   $0x1,%dl
  801328:	74 24                	je     80134e <fd_lookup+0x48>
  80132a:	89 c2                	mov    %eax,%edx
  80132c:	c1 ea 0c             	shr    $0xc,%edx
  80132f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801336:	f6 c2 01             	test   $0x1,%dl
  801339:	74 1a                	je     801355 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80133b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80133e:	89 02                	mov    %eax,(%edx)
	return 0;
  801340:	b8 00 00 00 00       	mov    $0x0,%eax
  801345:	eb 13                	jmp    80135a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801347:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80134c:	eb 0c                	jmp    80135a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80134e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801353:	eb 05                	jmp    80135a <fd_lookup+0x54>
  801355:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    

0080135c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	83 ec 08             	sub    $0x8,%esp
  801362:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801365:	ba 74 28 80 00       	mov    $0x802874,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80136a:	eb 13                	jmp    80137f <dev_lookup+0x23>
  80136c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80136f:	39 08                	cmp    %ecx,(%eax)
  801371:	75 0c                	jne    80137f <dev_lookup+0x23>
			*dev = devtab[i];
  801373:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801376:	89 01                	mov    %eax,(%ecx)
			return 0;
  801378:	b8 00 00 00 00       	mov    $0x0,%eax
  80137d:	eb 2e                	jmp    8013ad <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80137f:	8b 02                	mov    (%edx),%eax
  801381:	85 c0                	test   %eax,%eax
  801383:	75 e7                	jne    80136c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801385:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80138a:	8b 40 48             	mov    0x48(%eax),%eax
  80138d:	83 ec 04             	sub    $0x4,%esp
  801390:	51                   	push   %ecx
  801391:	50                   	push   %eax
  801392:	68 f8 27 80 00       	push   $0x8027f8
  801397:	e8 55 ee ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  80139c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013ad:	c9                   	leave  
  8013ae:	c3                   	ret    

008013af <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013af:	55                   	push   %ebp
  8013b0:	89 e5                	mov    %esp,%ebp
  8013b2:	56                   	push   %esi
  8013b3:	53                   	push   %ebx
  8013b4:	83 ec 10             	sub    $0x10,%esp
  8013b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8013ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c0:	50                   	push   %eax
  8013c1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013c7:	c1 e8 0c             	shr    $0xc,%eax
  8013ca:	50                   	push   %eax
  8013cb:	e8 36 ff ff ff       	call   801306 <fd_lookup>
  8013d0:	83 c4 08             	add    $0x8,%esp
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	78 05                	js     8013dc <fd_close+0x2d>
	    || fd != fd2) 
  8013d7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013da:	74 0c                	je     8013e8 <fd_close+0x39>
		return (must_exist ? r : 0); 
  8013dc:	84 db                	test   %bl,%bl
  8013de:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e3:	0f 44 c2             	cmove  %edx,%eax
  8013e6:	eb 41                	jmp    801429 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013e8:	83 ec 08             	sub    $0x8,%esp
  8013eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ee:	50                   	push   %eax
  8013ef:	ff 36                	pushl  (%esi)
  8013f1:	e8 66 ff ff ff       	call   80135c <dev_lookup>
  8013f6:	89 c3                	mov    %eax,%ebx
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 1a                	js     801419 <fd_close+0x6a>
		if (dev->dev_close) 
  8013ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801402:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  801405:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  80140a:	85 c0                	test   %eax,%eax
  80140c:	74 0b                	je     801419 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80140e:	83 ec 0c             	sub    $0xc,%esp
  801411:	56                   	push   %esi
  801412:	ff d0                	call   *%eax
  801414:	89 c3                	mov    %eax,%ebx
  801416:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801419:	83 ec 08             	sub    $0x8,%esp
  80141c:	56                   	push   %esi
  80141d:	6a 00                	push   $0x0
  80141f:	e8 00 f9 ff ff       	call   800d24 <sys_page_unmap>
	return r;
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	89 d8                	mov    %ebx,%eax
}
  801429:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142c:	5b                   	pop    %ebx
  80142d:	5e                   	pop    %esi
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    

00801430 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801436:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801439:	50                   	push   %eax
  80143a:	ff 75 08             	pushl  0x8(%ebp)
  80143d:	e8 c4 fe ff ff       	call   801306 <fd_lookup>
  801442:	83 c4 08             	add    $0x8,%esp
  801445:	85 c0                	test   %eax,%eax
  801447:	78 10                	js     801459 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  801449:	83 ec 08             	sub    $0x8,%esp
  80144c:	6a 01                	push   $0x1
  80144e:	ff 75 f4             	pushl  -0xc(%ebp)
  801451:	e8 59 ff ff ff       	call   8013af <fd_close>
  801456:	83 c4 10             	add    $0x10,%esp
}
  801459:	c9                   	leave  
  80145a:	c3                   	ret    

0080145b <close_all>:

void
close_all(void)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	53                   	push   %ebx
  80145f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801462:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801467:	83 ec 0c             	sub    $0xc,%esp
  80146a:	53                   	push   %ebx
  80146b:	e8 c0 ff ff ff       	call   801430 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801470:	83 c3 01             	add    $0x1,%ebx
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	83 fb 20             	cmp    $0x20,%ebx
  801479:	75 ec                	jne    801467 <close_all+0xc>
		close(i);
}
  80147b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147e:	c9                   	leave  
  80147f:	c3                   	ret    

00801480 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	57                   	push   %edi
  801484:	56                   	push   %esi
  801485:	53                   	push   %ebx
  801486:	83 ec 2c             	sub    $0x2c,%esp
  801489:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80148c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80148f:	50                   	push   %eax
  801490:	ff 75 08             	pushl  0x8(%ebp)
  801493:	e8 6e fe ff ff       	call   801306 <fd_lookup>
  801498:	83 c4 08             	add    $0x8,%esp
  80149b:	85 c0                	test   %eax,%eax
  80149d:	0f 88 c1 00 00 00    	js     801564 <dup+0xe4>
		return r;
	close(newfdnum);
  8014a3:	83 ec 0c             	sub    $0xc,%esp
  8014a6:	56                   	push   %esi
  8014a7:	e8 84 ff ff ff       	call   801430 <close>

	newfd = INDEX2FD(newfdnum);
  8014ac:	89 f3                	mov    %esi,%ebx
  8014ae:	c1 e3 0c             	shl    $0xc,%ebx
  8014b1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014b7:	83 c4 04             	add    $0x4,%esp
  8014ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014bd:	e8 de fd ff ff       	call   8012a0 <fd2data>
  8014c2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014c4:	89 1c 24             	mov    %ebx,(%esp)
  8014c7:	e8 d4 fd ff ff       	call   8012a0 <fd2data>
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014d2:	89 f8                	mov    %edi,%eax
  8014d4:	c1 e8 16             	shr    $0x16,%eax
  8014d7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014de:	a8 01                	test   $0x1,%al
  8014e0:	74 37                	je     801519 <dup+0x99>
  8014e2:	89 f8                	mov    %edi,%eax
  8014e4:	c1 e8 0c             	shr    $0xc,%eax
  8014e7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014ee:	f6 c2 01             	test   $0x1,%dl
  8014f1:	74 26                	je     801519 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014fa:	83 ec 0c             	sub    $0xc,%esp
  8014fd:	25 07 0e 00 00       	and    $0xe07,%eax
  801502:	50                   	push   %eax
  801503:	ff 75 d4             	pushl  -0x2c(%ebp)
  801506:	6a 00                	push   $0x0
  801508:	57                   	push   %edi
  801509:	6a 00                	push   $0x0
  80150b:	e8 d2 f7 ff ff       	call   800ce2 <sys_page_map>
  801510:	89 c7                	mov    %eax,%edi
  801512:	83 c4 20             	add    $0x20,%esp
  801515:	85 c0                	test   %eax,%eax
  801517:	78 2e                	js     801547 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801519:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80151c:	89 d0                	mov    %edx,%eax
  80151e:	c1 e8 0c             	shr    $0xc,%eax
  801521:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801528:	83 ec 0c             	sub    $0xc,%esp
  80152b:	25 07 0e 00 00       	and    $0xe07,%eax
  801530:	50                   	push   %eax
  801531:	53                   	push   %ebx
  801532:	6a 00                	push   $0x0
  801534:	52                   	push   %edx
  801535:	6a 00                	push   $0x0
  801537:	e8 a6 f7 ff ff       	call   800ce2 <sys_page_map>
  80153c:	89 c7                	mov    %eax,%edi
  80153e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801541:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801543:	85 ff                	test   %edi,%edi
  801545:	79 1d                	jns    801564 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801547:	83 ec 08             	sub    $0x8,%esp
  80154a:	53                   	push   %ebx
  80154b:	6a 00                	push   $0x0
  80154d:	e8 d2 f7 ff ff       	call   800d24 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801552:	83 c4 08             	add    $0x8,%esp
  801555:	ff 75 d4             	pushl  -0x2c(%ebp)
  801558:	6a 00                	push   $0x0
  80155a:	e8 c5 f7 ff ff       	call   800d24 <sys_page_unmap>
	return r;
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	89 f8                	mov    %edi,%eax
}
  801564:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801567:	5b                   	pop    %ebx
  801568:	5e                   	pop    %esi
  801569:	5f                   	pop    %edi
  80156a:	5d                   	pop    %ebp
  80156b:	c3                   	ret    

0080156c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	53                   	push   %ebx
  801570:	83 ec 14             	sub    $0x14,%esp
  801573:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801576:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	53                   	push   %ebx
  80157b:	e8 86 fd ff ff       	call   801306 <fd_lookup>
  801580:	83 c4 08             	add    $0x8,%esp
  801583:	89 c2                	mov    %eax,%edx
  801585:	85 c0                	test   %eax,%eax
  801587:	78 6d                	js     8015f6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158f:	50                   	push   %eax
  801590:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801593:	ff 30                	pushl  (%eax)
  801595:	e8 c2 fd ff ff       	call   80135c <dev_lookup>
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 4c                	js     8015ed <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015a4:	8b 42 08             	mov    0x8(%edx),%eax
  8015a7:	83 e0 03             	and    $0x3,%eax
  8015aa:	83 f8 01             	cmp    $0x1,%eax
  8015ad:	75 21                	jne    8015d0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015af:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8015b4:	8b 40 48             	mov    0x48(%eax),%eax
  8015b7:	83 ec 04             	sub    $0x4,%esp
  8015ba:	53                   	push   %ebx
  8015bb:	50                   	push   %eax
  8015bc:	68 39 28 80 00       	push   $0x802839
  8015c1:	e8 2b ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ce:	eb 26                	jmp    8015f6 <read+0x8a>
	}
	if (!dev->dev_read)
  8015d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d3:	8b 40 08             	mov    0x8(%eax),%eax
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	74 17                	je     8015f1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015da:	83 ec 04             	sub    $0x4,%esp
  8015dd:	ff 75 10             	pushl  0x10(%ebp)
  8015e0:	ff 75 0c             	pushl  0xc(%ebp)
  8015e3:	52                   	push   %edx
  8015e4:	ff d0                	call   *%eax
  8015e6:	89 c2                	mov    %eax,%edx
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	eb 09                	jmp    8015f6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ed:	89 c2                	mov    %eax,%edx
  8015ef:	eb 05                	jmp    8015f6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015f1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015f6:	89 d0                	mov    %edx,%eax
  8015f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fb:	c9                   	leave  
  8015fc:	c3                   	ret    

008015fd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	57                   	push   %edi
  801601:	56                   	push   %esi
  801602:	53                   	push   %ebx
  801603:	83 ec 0c             	sub    $0xc,%esp
  801606:	8b 7d 08             	mov    0x8(%ebp),%edi
  801609:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80160c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801611:	eb 21                	jmp    801634 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801613:	83 ec 04             	sub    $0x4,%esp
  801616:	89 f0                	mov    %esi,%eax
  801618:	29 d8                	sub    %ebx,%eax
  80161a:	50                   	push   %eax
  80161b:	89 d8                	mov    %ebx,%eax
  80161d:	03 45 0c             	add    0xc(%ebp),%eax
  801620:	50                   	push   %eax
  801621:	57                   	push   %edi
  801622:	e8 45 ff ff ff       	call   80156c <read>
		if (m < 0)
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 10                	js     80163e <readn+0x41>
			return m;
		if (m == 0)
  80162e:	85 c0                	test   %eax,%eax
  801630:	74 0a                	je     80163c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801632:	01 c3                	add    %eax,%ebx
  801634:	39 f3                	cmp    %esi,%ebx
  801636:	72 db                	jb     801613 <readn+0x16>
  801638:	89 d8                	mov    %ebx,%eax
  80163a:	eb 02                	jmp    80163e <readn+0x41>
  80163c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80163e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801641:	5b                   	pop    %ebx
  801642:	5e                   	pop    %esi
  801643:	5f                   	pop    %edi
  801644:	5d                   	pop    %ebp
  801645:	c3                   	ret    

00801646 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	53                   	push   %ebx
  80164a:	83 ec 14             	sub    $0x14,%esp
  80164d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801650:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801653:	50                   	push   %eax
  801654:	53                   	push   %ebx
  801655:	e8 ac fc ff ff       	call   801306 <fd_lookup>
  80165a:	83 c4 08             	add    $0x8,%esp
  80165d:	89 c2                	mov    %eax,%edx
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 68                	js     8016cb <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801669:	50                   	push   %eax
  80166a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166d:	ff 30                	pushl  (%eax)
  80166f:	e8 e8 fc ff ff       	call   80135c <dev_lookup>
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	85 c0                	test   %eax,%eax
  801679:	78 47                	js     8016c2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80167b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801682:	75 21                	jne    8016a5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801684:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801689:	8b 40 48             	mov    0x48(%eax),%eax
  80168c:	83 ec 04             	sub    $0x4,%esp
  80168f:	53                   	push   %ebx
  801690:	50                   	push   %eax
  801691:	68 55 28 80 00       	push   $0x802855
  801696:	e8 56 eb ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a3:	eb 26                	jmp    8016cb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8016ab:	85 d2                	test   %edx,%edx
  8016ad:	74 17                	je     8016c6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016af:	83 ec 04             	sub    $0x4,%esp
  8016b2:	ff 75 10             	pushl  0x10(%ebp)
  8016b5:	ff 75 0c             	pushl  0xc(%ebp)
  8016b8:	50                   	push   %eax
  8016b9:	ff d2                	call   *%edx
  8016bb:	89 c2                	mov    %eax,%edx
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	eb 09                	jmp    8016cb <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c2:	89 c2                	mov    %eax,%edx
  8016c4:	eb 05                	jmp    8016cb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016cb:	89 d0                	mov    %edx,%eax
  8016cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d0:	c9                   	leave  
  8016d1:	c3                   	ret    

008016d2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016d8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016db:	50                   	push   %eax
  8016dc:	ff 75 08             	pushl  0x8(%ebp)
  8016df:	e8 22 fc ff ff       	call   801306 <fd_lookup>
  8016e4:	83 c4 08             	add    $0x8,%esp
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	78 0e                	js     8016f9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f9:	c9                   	leave  
  8016fa:	c3                   	ret    

008016fb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	53                   	push   %ebx
  8016ff:	83 ec 14             	sub    $0x14,%esp
  801702:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801705:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801708:	50                   	push   %eax
  801709:	53                   	push   %ebx
  80170a:	e8 f7 fb ff ff       	call   801306 <fd_lookup>
  80170f:	83 c4 08             	add    $0x8,%esp
  801712:	89 c2                	mov    %eax,%edx
  801714:	85 c0                	test   %eax,%eax
  801716:	78 65                	js     80177d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801718:	83 ec 08             	sub    $0x8,%esp
  80171b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171e:	50                   	push   %eax
  80171f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801722:	ff 30                	pushl  (%eax)
  801724:	e8 33 fc ff ff       	call   80135c <dev_lookup>
  801729:	83 c4 10             	add    $0x10,%esp
  80172c:	85 c0                	test   %eax,%eax
  80172e:	78 44                	js     801774 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801730:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801733:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801737:	75 21                	jne    80175a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801739:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80173e:	8b 40 48             	mov    0x48(%eax),%eax
  801741:	83 ec 04             	sub    $0x4,%esp
  801744:	53                   	push   %ebx
  801745:	50                   	push   %eax
  801746:	68 18 28 80 00       	push   $0x802818
  80174b:	e8 a1 ea ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801758:	eb 23                	jmp    80177d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80175a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80175d:	8b 52 18             	mov    0x18(%edx),%edx
  801760:	85 d2                	test   %edx,%edx
  801762:	74 14                	je     801778 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801764:	83 ec 08             	sub    $0x8,%esp
  801767:	ff 75 0c             	pushl  0xc(%ebp)
  80176a:	50                   	push   %eax
  80176b:	ff d2                	call   *%edx
  80176d:	89 c2                	mov    %eax,%edx
  80176f:	83 c4 10             	add    $0x10,%esp
  801772:	eb 09                	jmp    80177d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801774:	89 c2                	mov    %eax,%edx
  801776:	eb 05                	jmp    80177d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801778:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80177d:	89 d0                	mov    %edx,%eax
  80177f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801782:	c9                   	leave  
  801783:	c3                   	ret    

00801784 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	53                   	push   %ebx
  801788:	83 ec 14             	sub    $0x14,%esp
  80178b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801791:	50                   	push   %eax
  801792:	ff 75 08             	pushl  0x8(%ebp)
  801795:	e8 6c fb ff ff       	call   801306 <fd_lookup>
  80179a:	83 c4 08             	add    $0x8,%esp
  80179d:	89 c2                	mov    %eax,%edx
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	78 58                	js     8017fb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a3:	83 ec 08             	sub    $0x8,%esp
  8017a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a9:	50                   	push   %eax
  8017aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ad:	ff 30                	pushl  (%eax)
  8017af:	e8 a8 fb ff ff       	call   80135c <dev_lookup>
  8017b4:	83 c4 10             	add    $0x10,%esp
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 37                	js     8017f2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017be:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017c2:	74 32                	je     8017f6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017c4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017c7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017ce:	00 00 00 
	stat->st_isdir = 0;
  8017d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017d8:	00 00 00 
	stat->st_dev = dev;
  8017db:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017e1:	83 ec 08             	sub    $0x8,%esp
  8017e4:	53                   	push   %ebx
  8017e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8017e8:	ff 50 14             	call   *0x14(%eax)
  8017eb:	89 c2                	mov    %eax,%edx
  8017ed:	83 c4 10             	add    $0x10,%esp
  8017f0:	eb 09                	jmp    8017fb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f2:	89 c2                	mov    %eax,%edx
  8017f4:	eb 05                	jmp    8017fb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017f6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017fb:	89 d0                	mov    %edx,%eax
  8017fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801800:	c9                   	leave  
  801801:	c3                   	ret    

00801802 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	56                   	push   %esi
  801806:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801807:	83 ec 08             	sub    $0x8,%esp
  80180a:	6a 00                	push   $0x0
  80180c:	ff 75 08             	pushl  0x8(%ebp)
  80180f:	e8 2b 02 00 00       	call   801a3f <open>
  801814:	89 c3                	mov    %eax,%ebx
  801816:	83 c4 10             	add    $0x10,%esp
  801819:	85 c0                	test   %eax,%eax
  80181b:	78 1b                	js     801838 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80181d:	83 ec 08             	sub    $0x8,%esp
  801820:	ff 75 0c             	pushl  0xc(%ebp)
  801823:	50                   	push   %eax
  801824:	e8 5b ff ff ff       	call   801784 <fstat>
  801829:	89 c6                	mov    %eax,%esi
	close(fd);
  80182b:	89 1c 24             	mov    %ebx,(%esp)
  80182e:	e8 fd fb ff ff       	call   801430 <close>
	return r;
  801833:	83 c4 10             	add    $0x10,%esp
  801836:	89 f0                	mov    %esi,%eax
}
  801838:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183b:	5b                   	pop    %ebx
  80183c:	5e                   	pop    %esi
  80183d:	5d                   	pop    %ebp
  80183e:	c3                   	ret    

0080183f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	56                   	push   %esi
  801843:	53                   	push   %ebx
  801844:	89 c6                	mov    %eax,%esi
  801846:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801848:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80184f:	75 12                	jne    801863 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801851:	83 ec 0c             	sub    $0xc,%esp
  801854:	6a 01                	push   $0x1
  801856:	e8 fc f9 ff ff       	call   801257 <ipc_find_env>
  80185b:	a3 04 40 80 00       	mov    %eax,0x804004
  801860:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801863:	6a 07                	push   $0x7
  801865:	68 00 50 80 00       	push   $0x805000
  80186a:	56                   	push   %esi
  80186b:	ff 35 04 40 80 00    	pushl  0x804004
  801871:	e8 8b f9 ff ff       	call   801201 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801876:	83 c4 0c             	add    $0xc,%esp
  801879:	6a 00                	push   $0x0
  80187b:	53                   	push   %ebx
  80187c:	6a 00                	push   $0x0
  80187e:	e8 15 f9 ff ff       	call   801198 <ipc_recv>
}
  801883:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801886:	5b                   	pop    %ebx
  801887:	5e                   	pop    %esi
  801888:	5d                   	pop    %ebp
  801889:	c3                   	ret    

0080188a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801890:	8b 45 08             	mov    0x8(%ebp),%eax
  801893:	8b 40 0c             	mov    0xc(%eax),%eax
  801896:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80189b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a8:	b8 02 00 00 00       	mov    $0x2,%eax
  8018ad:	e8 8d ff ff ff       	call   80183f <fsipc>
}
  8018b2:	c9                   	leave  
  8018b3:	c3                   	ret    

008018b4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ca:	b8 06 00 00 00       	mov    $0x6,%eax
  8018cf:	e8 6b ff ff ff       	call   80183f <fsipc>
}
  8018d4:	c9                   	leave  
  8018d5:	c3                   	ret    

008018d6 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	53                   	push   %ebx
  8018da:	83 ec 04             	sub    $0x4,%esp
  8018dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8018f5:	e8 45 ff ff ff       	call   80183f <fsipc>
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	78 2c                	js     80192a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018fe:	83 ec 08             	sub    $0x8,%esp
  801901:	68 00 50 80 00       	push   $0x805000
  801906:	53                   	push   %ebx
  801907:	e8 19 ef ff ff       	call   800825 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80190c:	a1 80 50 80 00       	mov    0x805080,%eax
  801911:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801917:	a1 84 50 80 00       	mov    0x805084,%eax
  80191c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801922:	83 c4 10             	add    $0x10,%esp
  801925:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192d:	c9                   	leave  
  80192e:	c3                   	ret    

0080192f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	53                   	push   %ebx
  801933:	83 ec 08             	sub    $0x8,%esp
  801936:	8b 45 10             	mov    0x10(%ebp),%eax
  801939:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80193e:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801943:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801946:	8b 45 08             	mov    0x8(%ebp),%eax
  801949:	8b 40 0c             	mov    0xc(%eax),%eax
  80194c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801951:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801957:	53                   	push   %ebx
  801958:	ff 75 0c             	pushl  0xc(%ebp)
  80195b:	68 08 50 80 00       	push   $0x805008
  801960:	e8 52 f0 ff ff       	call   8009b7 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801965:	ba 00 00 00 00       	mov    $0x0,%edx
  80196a:	b8 04 00 00 00       	mov    $0x4,%eax
  80196f:	e8 cb fe ff ff       	call   80183f <fsipc>
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	85 c0                	test   %eax,%eax
  801979:	78 3d                	js     8019b8 <devfile_write+0x89>
		return r;

	assert(r <= n);
  80197b:	39 d8                	cmp    %ebx,%eax
  80197d:	76 19                	jbe    801998 <devfile_write+0x69>
  80197f:	68 84 28 80 00       	push   $0x802884
  801984:	68 8b 28 80 00       	push   $0x80288b
  801989:	68 9f 00 00 00       	push   $0x9f
  80198e:	68 a0 28 80 00       	push   $0x8028a0
  801993:	e8 2a 06 00 00       	call   801fc2 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801998:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80199d:	76 19                	jbe    8019b8 <devfile_write+0x89>
  80199f:	68 b8 28 80 00       	push   $0x8028b8
  8019a4:	68 8b 28 80 00       	push   $0x80288b
  8019a9:	68 a0 00 00 00       	push   $0xa0
  8019ae:	68 a0 28 80 00       	push   $0x8028a0
  8019b3:	e8 0a 06 00 00       	call   801fc2 <_panic>

	return r;
}
  8019b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019bb:	c9                   	leave  
  8019bc:	c3                   	ret    

008019bd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	56                   	push   %esi
  8019c1:	53                   	push   %ebx
  8019c2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8019cb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019d0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019db:	b8 03 00 00 00       	mov    $0x3,%eax
  8019e0:	e8 5a fe ff ff       	call   80183f <fsipc>
  8019e5:	89 c3                	mov    %eax,%ebx
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	78 4b                	js     801a36 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019eb:	39 c6                	cmp    %eax,%esi
  8019ed:	73 16                	jae    801a05 <devfile_read+0x48>
  8019ef:	68 84 28 80 00       	push   $0x802884
  8019f4:	68 8b 28 80 00       	push   $0x80288b
  8019f9:	6a 7e                	push   $0x7e
  8019fb:	68 a0 28 80 00       	push   $0x8028a0
  801a00:	e8 bd 05 00 00       	call   801fc2 <_panic>
	assert(r <= PGSIZE);
  801a05:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a0a:	7e 16                	jle    801a22 <devfile_read+0x65>
  801a0c:	68 ab 28 80 00       	push   $0x8028ab
  801a11:	68 8b 28 80 00       	push   $0x80288b
  801a16:	6a 7f                	push   $0x7f
  801a18:	68 a0 28 80 00       	push   $0x8028a0
  801a1d:	e8 a0 05 00 00       	call   801fc2 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a22:	83 ec 04             	sub    $0x4,%esp
  801a25:	50                   	push   %eax
  801a26:	68 00 50 80 00       	push   $0x805000
  801a2b:	ff 75 0c             	pushl  0xc(%ebp)
  801a2e:	e8 84 ef ff ff       	call   8009b7 <memmove>
	return r;
  801a33:	83 c4 10             	add    $0x10,%esp
}
  801a36:	89 d8                	mov    %ebx,%eax
  801a38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3b:	5b                   	pop    %ebx
  801a3c:	5e                   	pop    %esi
  801a3d:	5d                   	pop    %ebp
  801a3e:	c3                   	ret    

00801a3f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	53                   	push   %ebx
  801a43:	83 ec 20             	sub    $0x20,%esp
  801a46:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a49:	53                   	push   %ebx
  801a4a:	e8 9d ed ff ff       	call   8007ec <strlen>
  801a4f:	83 c4 10             	add    $0x10,%esp
  801a52:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a57:	7f 67                	jg     801ac0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a59:	83 ec 0c             	sub    $0xc,%esp
  801a5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5f:	50                   	push   %eax
  801a60:	e8 52 f8 ff ff       	call   8012b7 <fd_alloc>
  801a65:	83 c4 10             	add    $0x10,%esp
		return r;
  801a68:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	78 57                	js     801ac5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a6e:	83 ec 08             	sub    $0x8,%esp
  801a71:	53                   	push   %ebx
  801a72:	68 00 50 80 00       	push   $0x805000
  801a77:	e8 a9 ed ff ff       	call   800825 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a84:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a87:	b8 01 00 00 00       	mov    $0x1,%eax
  801a8c:	e8 ae fd ff ff       	call   80183f <fsipc>
  801a91:	89 c3                	mov    %eax,%ebx
  801a93:	83 c4 10             	add    $0x10,%esp
  801a96:	85 c0                	test   %eax,%eax
  801a98:	79 14                	jns    801aae <open+0x6f>
		fd_close(fd, 0);
  801a9a:	83 ec 08             	sub    $0x8,%esp
  801a9d:	6a 00                	push   $0x0
  801a9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa2:	e8 08 f9 ff ff       	call   8013af <fd_close>
		return r;
  801aa7:	83 c4 10             	add    $0x10,%esp
  801aaa:	89 da                	mov    %ebx,%edx
  801aac:	eb 17                	jmp    801ac5 <open+0x86>
	}

	return fd2num(fd);
  801aae:	83 ec 0c             	sub    $0xc,%esp
  801ab1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab4:	e8 d7 f7 ff ff       	call   801290 <fd2num>
  801ab9:	89 c2                	mov    %eax,%edx
  801abb:	83 c4 10             	add    $0x10,%esp
  801abe:	eb 05                	jmp    801ac5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ac0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ac5:	89 d0                	mov    %edx,%eax
  801ac7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aca:	c9                   	leave  
  801acb:	c3                   	ret    

00801acc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ad2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad7:	b8 08 00 00 00       	mov    $0x8,%eax
  801adc:	e8 5e fd ff ff       	call   80183f <fsipc>
}
  801ae1:	c9                   	leave  
  801ae2:	c3                   	ret    

00801ae3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	56                   	push   %esi
  801ae7:	53                   	push   %ebx
  801ae8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801aeb:	83 ec 0c             	sub    $0xc,%esp
  801aee:	ff 75 08             	pushl  0x8(%ebp)
  801af1:	e8 aa f7 ff ff       	call   8012a0 <fd2data>
  801af6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801af8:	83 c4 08             	add    $0x8,%esp
  801afb:	68 e5 28 80 00       	push   $0x8028e5
  801b00:	53                   	push   %ebx
  801b01:	e8 1f ed ff ff       	call   800825 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b06:	8b 46 04             	mov    0x4(%esi),%eax
  801b09:	2b 06                	sub    (%esi),%eax
  801b0b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b11:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b18:	00 00 00 
	stat->st_dev = &devpipe;
  801b1b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b22:	30 80 00 
	return 0;
}
  801b25:	b8 00 00 00 00       	mov    $0x0,%eax
  801b2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2d:	5b                   	pop    %ebx
  801b2e:	5e                   	pop    %esi
  801b2f:	5d                   	pop    %ebp
  801b30:	c3                   	ret    

00801b31 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b31:	55                   	push   %ebp
  801b32:	89 e5                	mov    %esp,%ebp
  801b34:	53                   	push   %ebx
  801b35:	83 ec 0c             	sub    $0xc,%esp
  801b38:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b3b:	53                   	push   %ebx
  801b3c:	6a 00                	push   $0x0
  801b3e:	e8 e1 f1 ff ff       	call   800d24 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b43:	89 1c 24             	mov    %ebx,(%esp)
  801b46:	e8 55 f7 ff ff       	call   8012a0 <fd2data>
  801b4b:	83 c4 08             	add    $0x8,%esp
  801b4e:	50                   	push   %eax
  801b4f:	6a 00                	push   $0x0
  801b51:	e8 ce f1 ff ff       	call   800d24 <sys_page_unmap>
}
  801b56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b59:	c9                   	leave  
  801b5a:	c3                   	ret    

00801b5b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	57                   	push   %edi
  801b5f:	56                   	push   %esi
  801b60:	53                   	push   %ebx
  801b61:	83 ec 1c             	sub    $0x1c,%esp
  801b64:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b67:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b69:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801b6e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b71:	83 ec 0c             	sub    $0xc,%esp
  801b74:	ff 75 e0             	pushl  -0x20(%ebp)
  801b77:	e8 1b 05 00 00       	call   802097 <pageref>
  801b7c:	89 c3                	mov    %eax,%ebx
  801b7e:	89 3c 24             	mov    %edi,(%esp)
  801b81:	e8 11 05 00 00       	call   802097 <pageref>
  801b86:	83 c4 10             	add    $0x10,%esp
  801b89:	39 c3                	cmp    %eax,%ebx
  801b8b:	0f 94 c1             	sete   %cl
  801b8e:	0f b6 c9             	movzbl %cl,%ecx
  801b91:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b94:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801b9a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b9d:	39 ce                	cmp    %ecx,%esi
  801b9f:	74 1b                	je     801bbc <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ba1:	39 c3                	cmp    %eax,%ebx
  801ba3:	75 c4                	jne    801b69 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ba5:	8b 42 58             	mov    0x58(%edx),%eax
  801ba8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bab:	50                   	push   %eax
  801bac:	56                   	push   %esi
  801bad:	68 ec 28 80 00       	push   $0x8028ec
  801bb2:	e8 3a e6 ff ff       	call   8001f1 <cprintf>
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	eb ad                	jmp    801b69 <_pipeisclosed+0xe>
	}
}
  801bbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc2:	5b                   	pop    %ebx
  801bc3:	5e                   	pop    %esi
  801bc4:	5f                   	pop    %edi
  801bc5:	5d                   	pop    %ebp
  801bc6:	c3                   	ret    

00801bc7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bc7:	55                   	push   %ebp
  801bc8:	89 e5                	mov    %esp,%ebp
  801bca:	57                   	push   %edi
  801bcb:	56                   	push   %esi
  801bcc:	53                   	push   %ebx
  801bcd:	83 ec 28             	sub    $0x28,%esp
  801bd0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bd3:	56                   	push   %esi
  801bd4:	e8 c7 f6 ff ff       	call   8012a0 <fd2data>
  801bd9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	bf 00 00 00 00       	mov    $0x0,%edi
  801be3:	eb 4b                	jmp    801c30 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801be5:	89 da                	mov    %ebx,%edx
  801be7:	89 f0                	mov    %esi,%eax
  801be9:	e8 6d ff ff ff       	call   801b5b <_pipeisclosed>
  801bee:	85 c0                	test   %eax,%eax
  801bf0:	75 48                	jne    801c3a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bf2:	e8 89 f0 ff ff       	call   800c80 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bf7:	8b 43 04             	mov    0x4(%ebx),%eax
  801bfa:	8b 0b                	mov    (%ebx),%ecx
  801bfc:	8d 51 20             	lea    0x20(%ecx),%edx
  801bff:	39 d0                	cmp    %edx,%eax
  801c01:	73 e2                	jae    801be5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c06:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c0a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c0d:	89 c2                	mov    %eax,%edx
  801c0f:	c1 fa 1f             	sar    $0x1f,%edx
  801c12:	89 d1                	mov    %edx,%ecx
  801c14:	c1 e9 1b             	shr    $0x1b,%ecx
  801c17:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c1a:	83 e2 1f             	and    $0x1f,%edx
  801c1d:	29 ca                	sub    %ecx,%edx
  801c1f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c23:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c27:	83 c0 01             	add    $0x1,%eax
  801c2a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c2d:	83 c7 01             	add    $0x1,%edi
  801c30:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c33:	75 c2                	jne    801bf7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c35:	8b 45 10             	mov    0x10(%ebp),%eax
  801c38:	eb 05                	jmp    801c3f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c3a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c42:	5b                   	pop    %ebx
  801c43:	5e                   	pop    %esi
  801c44:	5f                   	pop    %edi
  801c45:	5d                   	pop    %ebp
  801c46:	c3                   	ret    

00801c47 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	57                   	push   %edi
  801c4b:	56                   	push   %esi
  801c4c:	53                   	push   %ebx
  801c4d:	83 ec 18             	sub    $0x18,%esp
  801c50:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c53:	57                   	push   %edi
  801c54:	e8 47 f6 ff ff       	call   8012a0 <fd2data>
  801c59:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c5b:	83 c4 10             	add    $0x10,%esp
  801c5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c63:	eb 3d                	jmp    801ca2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c65:	85 db                	test   %ebx,%ebx
  801c67:	74 04                	je     801c6d <devpipe_read+0x26>
				return i;
  801c69:	89 d8                	mov    %ebx,%eax
  801c6b:	eb 44                	jmp    801cb1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c6d:	89 f2                	mov    %esi,%edx
  801c6f:	89 f8                	mov    %edi,%eax
  801c71:	e8 e5 fe ff ff       	call   801b5b <_pipeisclosed>
  801c76:	85 c0                	test   %eax,%eax
  801c78:	75 32                	jne    801cac <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c7a:	e8 01 f0 ff ff       	call   800c80 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c7f:	8b 06                	mov    (%esi),%eax
  801c81:	3b 46 04             	cmp    0x4(%esi),%eax
  801c84:	74 df                	je     801c65 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c86:	99                   	cltd   
  801c87:	c1 ea 1b             	shr    $0x1b,%edx
  801c8a:	01 d0                	add    %edx,%eax
  801c8c:	83 e0 1f             	and    $0x1f,%eax
  801c8f:	29 d0                	sub    %edx,%eax
  801c91:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c99:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c9c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c9f:	83 c3 01             	add    $0x1,%ebx
  801ca2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ca5:	75 d8                	jne    801c7f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ca7:	8b 45 10             	mov    0x10(%ebp),%eax
  801caa:	eb 05                	jmp    801cb1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cac:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb4:	5b                   	pop    %ebx
  801cb5:	5e                   	pop    %esi
  801cb6:	5f                   	pop    %edi
  801cb7:	5d                   	pop    %ebp
  801cb8:	c3                   	ret    

00801cb9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cb9:	55                   	push   %ebp
  801cba:	89 e5                	mov    %esp,%ebp
  801cbc:	56                   	push   %esi
  801cbd:	53                   	push   %ebx
  801cbe:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc4:	50                   	push   %eax
  801cc5:	e8 ed f5 ff ff       	call   8012b7 <fd_alloc>
  801cca:	83 c4 10             	add    $0x10,%esp
  801ccd:	89 c2                	mov    %eax,%edx
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	0f 88 2c 01 00 00    	js     801e03 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd7:	83 ec 04             	sub    $0x4,%esp
  801cda:	68 07 04 00 00       	push   $0x407
  801cdf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce2:	6a 00                	push   $0x0
  801ce4:	e8 b6 ef ff ff       	call   800c9f <sys_page_alloc>
  801ce9:	83 c4 10             	add    $0x10,%esp
  801cec:	89 c2                	mov    %eax,%edx
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	0f 88 0d 01 00 00    	js     801e03 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cf6:	83 ec 0c             	sub    $0xc,%esp
  801cf9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cfc:	50                   	push   %eax
  801cfd:	e8 b5 f5 ff ff       	call   8012b7 <fd_alloc>
  801d02:	89 c3                	mov    %eax,%ebx
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	85 c0                	test   %eax,%eax
  801d09:	0f 88 e2 00 00 00    	js     801df1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d0f:	83 ec 04             	sub    $0x4,%esp
  801d12:	68 07 04 00 00       	push   $0x407
  801d17:	ff 75 f0             	pushl  -0x10(%ebp)
  801d1a:	6a 00                	push   $0x0
  801d1c:	e8 7e ef ff ff       	call   800c9f <sys_page_alloc>
  801d21:	89 c3                	mov    %eax,%ebx
  801d23:	83 c4 10             	add    $0x10,%esp
  801d26:	85 c0                	test   %eax,%eax
  801d28:	0f 88 c3 00 00 00    	js     801df1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d2e:	83 ec 0c             	sub    $0xc,%esp
  801d31:	ff 75 f4             	pushl  -0xc(%ebp)
  801d34:	e8 67 f5 ff ff       	call   8012a0 <fd2data>
  801d39:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d3b:	83 c4 0c             	add    $0xc,%esp
  801d3e:	68 07 04 00 00       	push   $0x407
  801d43:	50                   	push   %eax
  801d44:	6a 00                	push   $0x0
  801d46:	e8 54 ef ff ff       	call   800c9f <sys_page_alloc>
  801d4b:	89 c3                	mov    %eax,%ebx
  801d4d:	83 c4 10             	add    $0x10,%esp
  801d50:	85 c0                	test   %eax,%eax
  801d52:	0f 88 89 00 00 00    	js     801de1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d58:	83 ec 0c             	sub    $0xc,%esp
  801d5b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d5e:	e8 3d f5 ff ff       	call   8012a0 <fd2data>
  801d63:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d6a:	50                   	push   %eax
  801d6b:	6a 00                	push   $0x0
  801d6d:	56                   	push   %esi
  801d6e:	6a 00                	push   $0x0
  801d70:	e8 6d ef ff ff       	call   800ce2 <sys_page_map>
  801d75:	89 c3                	mov    %eax,%ebx
  801d77:	83 c4 20             	add    $0x20,%esp
  801d7a:	85 c0                	test   %eax,%eax
  801d7c:	78 55                	js     801dd3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d7e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d87:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d93:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d9c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801da8:	83 ec 0c             	sub    $0xc,%esp
  801dab:	ff 75 f4             	pushl  -0xc(%ebp)
  801dae:	e8 dd f4 ff ff       	call   801290 <fd2num>
  801db3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801db6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801db8:	83 c4 04             	add    $0x4,%esp
  801dbb:	ff 75 f0             	pushl  -0x10(%ebp)
  801dbe:	e8 cd f4 ff ff       	call   801290 <fd2num>
  801dc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dc9:	83 c4 10             	add    $0x10,%esp
  801dcc:	ba 00 00 00 00       	mov    $0x0,%edx
  801dd1:	eb 30                	jmp    801e03 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dd3:	83 ec 08             	sub    $0x8,%esp
  801dd6:	56                   	push   %esi
  801dd7:	6a 00                	push   $0x0
  801dd9:	e8 46 ef ff ff       	call   800d24 <sys_page_unmap>
  801dde:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801de1:	83 ec 08             	sub    $0x8,%esp
  801de4:	ff 75 f0             	pushl  -0x10(%ebp)
  801de7:	6a 00                	push   $0x0
  801de9:	e8 36 ef ff ff       	call   800d24 <sys_page_unmap>
  801dee:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801df1:	83 ec 08             	sub    $0x8,%esp
  801df4:	ff 75 f4             	pushl  -0xc(%ebp)
  801df7:	6a 00                	push   $0x0
  801df9:	e8 26 ef ff ff       	call   800d24 <sys_page_unmap>
  801dfe:	83 c4 10             	add    $0x10,%esp
  801e01:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e03:	89 d0                	mov    %edx,%eax
  801e05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e08:	5b                   	pop    %ebx
  801e09:	5e                   	pop    %esi
  801e0a:	5d                   	pop    %ebp
  801e0b:	c3                   	ret    

00801e0c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
  801e0f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e15:	50                   	push   %eax
  801e16:	ff 75 08             	pushl  0x8(%ebp)
  801e19:	e8 e8 f4 ff ff       	call   801306 <fd_lookup>
  801e1e:	83 c4 10             	add    $0x10,%esp
  801e21:	85 c0                	test   %eax,%eax
  801e23:	78 18                	js     801e3d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e25:	83 ec 0c             	sub    $0xc,%esp
  801e28:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2b:	e8 70 f4 ff ff       	call   8012a0 <fd2data>
	return _pipeisclosed(fd, p);
  801e30:	89 c2                	mov    %eax,%edx
  801e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e35:	e8 21 fd ff ff       	call   801b5b <_pipeisclosed>
  801e3a:	83 c4 10             	add    $0x10,%esp
}
  801e3d:	c9                   	leave  
  801e3e:	c3                   	ret    

00801e3f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e42:	b8 00 00 00 00       	mov    $0x0,%eax
  801e47:	5d                   	pop    %ebp
  801e48:	c3                   	ret    

00801e49 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e49:	55                   	push   %ebp
  801e4a:	89 e5                	mov    %esp,%ebp
  801e4c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e4f:	68 04 29 80 00       	push   $0x802904
  801e54:	ff 75 0c             	pushl  0xc(%ebp)
  801e57:	e8 c9 e9 ff ff       	call   800825 <strcpy>
	return 0;
}
  801e5c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e61:	c9                   	leave  
  801e62:	c3                   	ret    

00801e63 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e63:	55                   	push   %ebp
  801e64:	89 e5                	mov    %esp,%ebp
  801e66:	57                   	push   %edi
  801e67:	56                   	push   %esi
  801e68:	53                   	push   %ebx
  801e69:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e6f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e74:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e7a:	eb 2d                	jmp    801ea9 <devcons_write+0x46>
		m = n - tot;
  801e7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e7f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e81:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e84:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e89:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e8c:	83 ec 04             	sub    $0x4,%esp
  801e8f:	53                   	push   %ebx
  801e90:	03 45 0c             	add    0xc(%ebp),%eax
  801e93:	50                   	push   %eax
  801e94:	57                   	push   %edi
  801e95:	e8 1d eb ff ff       	call   8009b7 <memmove>
		sys_cputs(buf, m);
  801e9a:	83 c4 08             	add    $0x8,%esp
  801e9d:	53                   	push   %ebx
  801e9e:	57                   	push   %edi
  801e9f:	e8 3f ed ff ff       	call   800be3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ea4:	01 de                	add    %ebx,%esi
  801ea6:	83 c4 10             	add    $0x10,%esp
  801ea9:	89 f0                	mov    %esi,%eax
  801eab:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eae:	72 cc                	jb     801e7c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801eb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb3:	5b                   	pop    %ebx
  801eb4:	5e                   	pop    %esi
  801eb5:	5f                   	pop    %edi
  801eb6:	5d                   	pop    %ebp
  801eb7:	c3                   	ret    

00801eb8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
  801ebb:	83 ec 08             	sub    $0x8,%esp
  801ebe:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ec3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ec7:	74 2a                	je     801ef3 <devcons_read+0x3b>
  801ec9:	eb 05                	jmp    801ed0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ecb:	e8 b0 ed ff ff       	call   800c80 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ed0:	e8 2c ed ff ff       	call   800c01 <sys_cgetc>
  801ed5:	85 c0                	test   %eax,%eax
  801ed7:	74 f2                	je     801ecb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	78 16                	js     801ef3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801edd:	83 f8 04             	cmp    $0x4,%eax
  801ee0:	74 0c                	je     801eee <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ee2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ee5:	88 02                	mov    %al,(%edx)
	return 1;
  801ee7:	b8 01 00 00 00       	mov    $0x1,%eax
  801eec:	eb 05                	jmp    801ef3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801eee:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ef3:	c9                   	leave  
  801ef4:	c3                   	ret    

00801ef5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ef5:	55                   	push   %ebp
  801ef6:	89 e5                	mov    %esp,%ebp
  801ef8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801efb:	8b 45 08             	mov    0x8(%ebp),%eax
  801efe:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f01:	6a 01                	push   $0x1
  801f03:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f06:	50                   	push   %eax
  801f07:	e8 d7 ec ff ff       	call   800be3 <sys_cputs>
}
  801f0c:	83 c4 10             	add    $0x10,%esp
  801f0f:	c9                   	leave  
  801f10:	c3                   	ret    

00801f11 <getchar>:

int
getchar(void)
{
  801f11:	55                   	push   %ebp
  801f12:	89 e5                	mov    %esp,%ebp
  801f14:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f17:	6a 01                	push   $0x1
  801f19:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f1c:	50                   	push   %eax
  801f1d:	6a 00                	push   $0x0
  801f1f:	e8 48 f6 ff ff       	call   80156c <read>
	if (r < 0)
  801f24:	83 c4 10             	add    $0x10,%esp
  801f27:	85 c0                	test   %eax,%eax
  801f29:	78 0f                	js     801f3a <getchar+0x29>
		return r;
	if (r < 1)
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	7e 06                	jle    801f35 <getchar+0x24>
		return -E_EOF;
	return c;
  801f2f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f33:	eb 05                	jmp    801f3a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f35:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f3a:	c9                   	leave  
  801f3b:	c3                   	ret    

00801f3c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f45:	50                   	push   %eax
  801f46:	ff 75 08             	pushl  0x8(%ebp)
  801f49:	e8 b8 f3 ff ff       	call   801306 <fd_lookup>
  801f4e:	83 c4 10             	add    $0x10,%esp
  801f51:	85 c0                	test   %eax,%eax
  801f53:	78 11                	js     801f66 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f58:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f5e:	39 10                	cmp    %edx,(%eax)
  801f60:	0f 94 c0             	sete   %al
  801f63:	0f b6 c0             	movzbl %al,%eax
}
  801f66:	c9                   	leave  
  801f67:	c3                   	ret    

00801f68 <opencons>:

int
opencons(void)
{
  801f68:	55                   	push   %ebp
  801f69:	89 e5                	mov    %esp,%ebp
  801f6b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f71:	50                   	push   %eax
  801f72:	e8 40 f3 ff ff       	call   8012b7 <fd_alloc>
  801f77:	83 c4 10             	add    $0x10,%esp
		return r;
  801f7a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f7c:	85 c0                	test   %eax,%eax
  801f7e:	78 3e                	js     801fbe <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f80:	83 ec 04             	sub    $0x4,%esp
  801f83:	68 07 04 00 00       	push   $0x407
  801f88:	ff 75 f4             	pushl  -0xc(%ebp)
  801f8b:	6a 00                	push   $0x0
  801f8d:	e8 0d ed ff ff       	call   800c9f <sys_page_alloc>
  801f92:	83 c4 10             	add    $0x10,%esp
		return r;
  801f95:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f97:	85 c0                	test   %eax,%eax
  801f99:	78 23                	js     801fbe <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f9b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fb0:	83 ec 0c             	sub    $0xc,%esp
  801fb3:	50                   	push   %eax
  801fb4:	e8 d7 f2 ff ff       	call   801290 <fd2num>
  801fb9:	89 c2                	mov    %eax,%edx
  801fbb:	83 c4 10             	add    $0x10,%esp
}
  801fbe:	89 d0                	mov    %edx,%eax
  801fc0:	c9                   	leave  
  801fc1:	c3                   	ret    

00801fc2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fc2:	55                   	push   %ebp
  801fc3:	89 e5                	mov    %esp,%ebp
  801fc5:	56                   	push   %esi
  801fc6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fc7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fca:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801fd0:	e8 8c ec ff ff       	call   800c61 <sys_getenvid>
  801fd5:	83 ec 0c             	sub    $0xc,%esp
  801fd8:	ff 75 0c             	pushl  0xc(%ebp)
  801fdb:	ff 75 08             	pushl  0x8(%ebp)
  801fde:	56                   	push   %esi
  801fdf:	50                   	push   %eax
  801fe0:	68 10 29 80 00       	push   $0x802910
  801fe5:	e8 07 e2 ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fea:	83 c4 18             	add    $0x18,%esp
  801fed:	53                   	push   %ebx
  801fee:	ff 75 10             	pushl  0x10(%ebp)
  801ff1:	e8 aa e1 ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  801ff6:	c7 04 24 fd 28 80 00 	movl   $0x8028fd,(%esp)
  801ffd:	e8 ef e1 ff ff       	call   8001f1 <cprintf>
  802002:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802005:	cc                   	int3   
  802006:	eb fd                	jmp    802005 <_panic+0x43>

00802008 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802008:	55                   	push   %ebp
  802009:	89 e5                	mov    %esp,%ebp
  80200b:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  80200e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802015:	75 52                	jne    802069 <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  802017:	83 ec 04             	sub    $0x4,%esp
  80201a:	6a 07                	push   $0x7
  80201c:	68 00 f0 bf ee       	push   $0xeebff000
  802021:	6a 00                	push   $0x0
  802023:	e8 77 ec ff ff       	call   800c9f <sys_page_alloc>
  802028:	83 c4 10             	add    $0x10,%esp
  80202b:	85 c0                	test   %eax,%eax
  80202d:	79 12                	jns    802041 <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  80202f:	50                   	push   %eax
  802030:	68 20 27 80 00       	push   $0x802720
  802035:	6a 23                	push   $0x23
  802037:	68 34 29 80 00       	push   $0x802934
  80203c:	e8 81 ff ff ff       	call   801fc2 <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  802041:	83 ec 08             	sub    $0x8,%esp
  802044:	68 73 20 80 00       	push   $0x802073
  802049:	6a 00                	push   $0x0
  80204b:	e8 9a ed ff ff       	call   800dea <sys_env_set_pgfault_upcall>
  802050:	83 c4 10             	add    $0x10,%esp
  802053:	85 c0                	test   %eax,%eax
  802055:	79 12                	jns    802069 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  802057:	50                   	push   %eax
  802058:	68 a0 27 80 00       	push   $0x8027a0
  80205d:	6a 26                	push   $0x26
  80205f:	68 34 29 80 00       	push   $0x802934
  802064:	e8 59 ff ff ff       	call   801fc2 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802069:	8b 45 08             	mov    0x8(%ebp),%eax
  80206c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802071:	c9                   	leave  
  802072:	c3                   	ret    

00802073 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802073:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802074:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802079:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80207b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  80207e:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  802082:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  802087:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  80208b:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80208d:	83 c4 08             	add    $0x8,%esp
	popal 
  802090:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802091:	83 c4 04             	add    $0x4,%esp
	popfl
  802094:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802095:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802096:	c3                   	ret    

00802097 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802097:	55                   	push   %ebp
  802098:	89 e5                	mov    %esp,%ebp
  80209a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80209d:	89 d0                	mov    %edx,%eax
  80209f:	c1 e8 16             	shr    $0x16,%eax
  8020a2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020a9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ae:	f6 c1 01             	test   $0x1,%cl
  8020b1:	74 1d                	je     8020d0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020b3:	c1 ea 0c             	shr    $0xc,%edx
  8020b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020bd:	f6 c2 01             	test   $0x1,%dl
  8020c0:	74 0e                	je     8020d0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020c2:	c1 ea 0c             	shr    $0xc,%edx
  8020c5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020cc:	ef 
  8020cd:	0f b7 c0             	movzwl %ax,%eax
}
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    
  8020d2:	66 90                	xchg   %ax,%ax
  8020d4:	66 90                	xchg   %ax,%ax
  8020d6:	66 90                	xchg   %ax,%ax
  8020d8:	66 90                	xchg   %ax,%ax
  8020da:	66 90                	xchg   %ax,%ax
  8020dc:	66 90                	xchg   %ax,%ax
  8020de:	66 90                	xchg   %ax,%ax

008020e0 <__udivdi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020f7:	85 f6                	test   %esi,%esi
  8020f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020fd:	89 ca                	mov    %ecx,%edx
  8020ff:	89 f8                	mov    %edi,%eax
  802101:	75 3d                	jne    802140 <__udivdi3+0x60>
  802103:	39 cf                	cmp    %ecx,%edi
  802105:	0f 87 c5 00 00 00    	ja     8021d0 <__udivdi3+0xf0>
  80210b:	85 ff                	test   %edi,%edi
  80210d:	89 fd                	mov    %edi,%ebp
  80210f:	75 0b                	jne    80211c <__udivdi3+0x3c>
  802111:	b8 01 00 00 00       	mov    $0x1,%eax
  802116:	31 d2                	xor    %edx,%edx
  802118:	f7 f7                	div    %edi
  80211a:	89 c5                	mov    %eax,%ebp
  80211c:	89 c8                	mov    %ecx,%eax
  80211e:	31 d2                	xor    %edx,%edx
  802120:	f7 f5                	div    %ebp
  802122:	89 c1                	mov    %eax,%ecx
  802124:	89 d8                	mov    %ebx,%eax
  802126:	89 cf                	mov    %ecx,%edi
  802128:	f7 f5                	div    %ebp
  80212a:	89 c3                	mov    %eax,%ebx
  80212c:	89 d8                	mov    %ebx,%eax
  80212e:	89 fa                	mov    %edi,%edx
  802130:	83 c4 1c             	add    $0x1c,%esp
  802133:	5b                   	pop    %ebx
  802134:	5e                   	pop    %esi
  802135:	5f                   	pop    %edi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    
  802138:	90                   	nop
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	39 ce                	cmp    %ecx,%esi
  802142:	77 74                	ja     8021b8 <__udivdi3+0xd8>
  802144:	0f bd fe             	bsr    %esi,%edi
  802147:	83 f7 1f             	xor    $0x1f,%edi
  80214a:	0f 84 98 00 00 00    	je     8021e8 <__udivdi3+0x108>
  802150:	bb 20 00 00 00       	mov    $0x20,%ebx
  802155:	89 f9                	mov    %edi,%ecx
  802157:	89 c5                	mov    %eax,%ebp
  802159:	29 fb                	sub    %edi,%ebx
  80215b:	d3 e6                	shl    %cl,%esi
  80215d:	89 d9                	mov    %ebx,%ecx
  80215f:	d3 ed                	shr    %cl,%ebp
  802161:	89 f9                	mov    %edi,%ecx
  802163:	d3 e0                	shl    %cl,%eax
  802165:	09 ee                	or     %ebp,%esi
  802167:	89 d9                	mov    %ebx,%ecx
  802169:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80216d:	89 d5                	mov    %edx,%ebp
  80216f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802173:	d3 ed                	shr    %cl,%ebp
  802175:	89 f9                	mov    %edi,%ecx
  802177:	d3 e2                	shl    %cl,%edx
  802179:	89 d9                	mov    %ebx,%ecx
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	09 c2                	or     %eax,%edx
  80217f:	89 d0                	mov    %edx,%eax
  802181:	89 ea                	mov    %ebp,%edx
  802183:	f7 f6                	div    %esi
  802185:	89 d5                	mov    %edx,%ebp
  802187:	89 c3                	mov    %eax,%ebx
  802189:	f7 64 24 0c          	mull   0xc(%esp)
  80218d:	39 d5                	cmp    %edx,%ebp
  80218f:	72 10                	jb     8021a1 <__udivdi3+0xc1>
  802191:	8b 74 24 08          	mov    0x8(%esp),%esi
  802195:	89 f9                	mov    %edi,%ecx
  802197:	d3 e6                	shl    %cl,%esi
  802199:	39 c6                	cmp    %eax,%esi
  80219b:	73 07                	jae    8021a4 <__udivdi3+0xc4>
  80219d:	39 d5                	cmp    %edx,%ebp
  80219f:	75 03                	jne    8021a4 <__udivdi3+0xc4>
  8021a1:	83 eb 01             	sub    $0x1,%ebx
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 d8                	mov    %ebx,%eax
  8021a8:	89 fa                	mov    %edi,%edx
  8021aa:	83 c4 1c             	add    $0x1c,%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5f                   	pop    %edi
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    
  8021b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b8:	31 ff                	xor    %edi,%edi
  8021ba:	31 db                	xor    %ebx,%ebx
  8021bc:	89 d8                	mov    %ebx,%eax
  8021be:	89 fa                	mov    %edi,%edx
  8021c0:	83 c4 1c             	add    $0x1c,%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5f                   	pop    %edi
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    
  8021c8:	90                   	nop
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	89 d8                	mov    %ebx,%eax
  8021d2:	f7 f7                	div    %edi
  8021d4:	31 ff                	xor    %edi,%edi
  8021d6:	89 c3                	mov    %eax,%ebx
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	89 fa                	mov    %edi,%edx
  8021dc:	83 c4 1c             	add    $0x1c,%esp
  8021df:	5b                   	pop    %ebx
  8021e0:	5e                   	pop    %esi
  8021e1:	5f                   	pop    %edi
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    
  8021e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e8:	39 ce                	cmp    %ecx,%esi
  8021ea:	72 0c                	jb     8021f8 <__udivdi3+0x118>
  8021ec:	31 db                	xor    %ebx,%ebx
  8021ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021f2:	0f 87 34 ff ff ff    	ja     80212c <__udivdi3+0x4c>
  8021f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021fd:	e9 2a ff ff ff       	jmp    80212c <__udivdi3+0x4c>
  802202:	66 90                	xchg   %ax,%ax
  802204:	66 90                	xchg   %ax,%ax
  802206:	66 90                	xchg   %ax,%ax
  802208:	66 90                	xchg   %ax,%ax
  80220a:	66 90                	xchg   %ax,%ax
  80220c:	66 90                	xchg   %ax,%ax
  80220e:	66 90                	xchg   %ax,%ax

00802210 <__umoddi3>:
  802210:	55                   	push   %ebp
  802211:	57                   	push   %edi
  802212:	56                   	push   %esi
  802213:	53                   	push   %ebx
  802214:	83 ec 1c             	sub    $0x1c,%esp
  802217:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80221b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80221f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802223:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802227:	85 d2                	test   %edx,%edx
  802229:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80222d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802231:	89 f3                	mov    %esi,%ebx
  802233:	89 3c 24             	mov    %edi,(%esp)
  802236:	89 74 24 04          	mov    %esi,0x4(%esp)
  80223a:	75 1c                	jne    802258 <__umoddi3+0x48>
  80223c:	39 f7                	cmp    %esi,%edi
  80223e:	76 50                	jbe    802290 <__umoddi3+0x80>
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	f7 f7                	div    %edi
  802246:	89 d0                	mov    %edx,%eax
  802248:	31 d2                	xor    %edx,%edx
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	39 f2                	cmp    %esi,%edx
  80225a:	89 d0                	mov    %edx,%eax
  80225c:	77 52                	ja     8022b0 <__umoddi3+0xa0>
  80225e:	0f bd ea             	bsr    %edx,%ebp
  802261:	83 f5 1f             	xor    $0x1f,%ebp
  802264:	75 5a                	jne    8022c0 <__umoddi3+0xb0>
  802266:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80226a:	0f 82 e0 00 00 00    	jb     802350 <__umoddi3+0x140>
  802270:	39 0c 24             	cmp    %ecx,(%esp)
  802273:	0f 86 d7 00 00 00    	jbe    802350 <__umoddi3+0x140>
  802279:	8b 44 24 08          	mov    0x8(%esp),%eax
  80227d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802281:	83 c4 1c             	add    $0x1c,%esp
  802284:	5b                   	pop    %ebx
  802285:	5e                   	pop    %esi
  802286:	5f                   	pop    %edi
  802287:	5d                   	pop    %ebp
  802288:	c3                   	ret    
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	85 ff                	test   %edi,%edi
  802292:	89 fd                	mov    %edi,%ebp
  802294:	75 0b                	jne    8022a1 <__umoddi3+0x91>
  802296:	b8 01 00 00 00       	mov    $0x1,%eax
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	f7 f7                	div    %edi
  80229f:	89 c5                	mov    %eax,%ebp
  8022a1:	89 f0                	mov    %esi,%eax
  8022a3:	31 d2                	xor    %edx,%edx
  8022a5:	f7 f5                	div    %ebp
  8022a7:	89 c8                	mov    %ecx,%eax
  8022a9:	f7 f5                	div    %ebp
  8022ab:	89 d0                	mov    %edx,%eax
  8022ad:	eb 99                	jmp    802248 <__umoddi3+0x38>
  8022af:	90                   	nop
  8022b0:	89 c8                	mov    %ecx,%eax
  8022b2:	89 f2                	mov    %esi,%edx
  8022b4:	83 c4 1c             	add    $0x1c,%esp
  8022b7:	5b                   	pop    %ebx
  8022b8:	5e                   	pop    %esi
  8022b9:	5f                   	pop    %edi
  8022ba:	5d                   	pop    %ebp
  8022bb:	c3                   	ret    
  8022bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	8b 34 24             	mov    (%esp),%esi
  8022c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022c8:	89 e9                	mov    %ebp,%ecx
  8022ca:	29 ef                	sub    %ebp,%edi
  8022cc:	d3 e0                	shl    %cl,%eax
  8022ce:	89 f9                	mov    %edi,%ecx
  8022d0:	89 f2                	mov    %esi,%edx
  8022d2:	d3 ea                	shr    %cl,%edx
  8022d4:	89 e9                	mov    %ebp,%ecx
  8022d6:	09 c2                	or     %eax,%edx
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	89 14 24             	mov    %edx,(%esp)
  8022dd:	89 f2                	mov    %esi,%edx
  8022df:	d3 e2                	shl    %cl,%edx
  8022e1:	89 f9                	mov    %edi,%ecx
  8022e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022eb:	d3 e8                	shr    %cl,%eax
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	89 c6                	mov    %eax,%esi
  8022f1:	d3 e3                	shl    %cl,%ebx
  8022f3:	89 f9                	mov    %edi,%ecx
  8022f5:	89 d0                	mov    %edx,%eax
  8022f7:	d3 e8                	shr    %cl,%eax
  8022f9:	89 e9                	mov    %ebp,%ecx
  8022fb:	09 d8                	or     %ebx,%eax
  8022fd:	89 d3                	mov    %edx,%ebx
  8022ff:	89 f2                	mov    %esi,%edx
  802301:	f7 34 24             	divl   (%esp)
  802304:	89 d6                	mov    %edx,%esi
  802306:	d3 e3                	shl    %cl,%ebx
  802308:	f7 64 24 04          	mull   0x4(%esp)
  80230c:	39 d6                	cmp    %edx,%esi
  80230e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802312:	89 d1                	mov    %edx,%ecx
  802314:	89 c3                	mov    %eax,%ebx
  802316:	72 08                	jb     802320 <__umoddi3+0x110>
  802318:	75 11                	jne    80232b <__umoddi3+0x11b>
  80231a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80231e:	73 0b                	jae    80232b <__umoddi3+0x11b>
  802320:	2b 44 24 04          	sub    0x4(%esp),%eax
  802324:	1b 14 24             	sbb    (%esp),%edx
  802327:	89 d1                	mov    %edx,%ecx
  802329:	89 c3                	mov    %eax,%ebx
  80232b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80232f:	29 da                	sub    %ebx,%edx
  802331:	19 ce                	sbb    %ecx,%esi
  802333:	89 f9                	mov    %edi,%ecx
  802335:	89 f0                	mov    %esi,%eax
  802337:	d3 e0                	shl    %cl,%eax
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	d3 ea                	shr    %cl,%edx
  80233d:	89 e9                	mov    %ebp,%ecx
  80233f:	d3 ee                	shr    %cl,%esi
  802341:	09 d0                	or     %edx,%eax
  802343:	89 f2                	mov    %esi,%edx
  802345:	83 c4 1c             	add    $0x1c,%esp
  802348:	5b                   	pop    %ebx
  802349:	5e                   	pop    %esi
  80234a:	5f                   	pop    %edi
  80234b:	5d                   	pop    %ebp
  80234c:	c3                   	ret    
  80234d:	8d 76 00             	lea    0x0(%esi),%esi
  802350:	29 f9                	sub    %edi,%ecx
  802352:	19 d6                	sbb    %edx,%esi
  802354:	89 74 24 04          	mov    %esi,0x4(%esp)
  802358:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80235c:	e9 18 ff ff ff       	jmp    802279 <__umoddi3+0x69>
