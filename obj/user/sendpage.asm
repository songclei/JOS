
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 68 01 00 00       	call   800199 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 c3 0f 00 00       	call   801001 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9f 00 00 00    	jne    8000e8 <umain+0xb5>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 d7 11 00 00       	call   801233 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 00 24 80 00       	push   $0x802400
  80006c:	e8 1b 02 00 00       	call   80028c <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 08 08 00 00       	call   800887 <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 fd 08 00 00       	call   800990 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 14 24 80 00       	push   $0x802414
  8000a2:	e8 e5 01 00 00       	call   80028c <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 30 80 00    	pushl  0x803000
  8000b3:	e8 cf 07 00 00       	call   800887 <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 30 80 00    	pushl  0x803000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 eb 09 00 00       	call   800aba <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 bc 11 00 00       	call   80129c <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 3a 0c 00 00       	call   800d3a <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 30 80 00    	pushl  0x803004
  800109:	e8 79 07 00 00       	call   800887 <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 30 80 00    	pushl  0x803004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 95 09 00 00       	call   800aba <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 66 11 00 00       	call   80129c <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 ea 10 00 00       	call   801233 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 00 24 80 00       	push   $0x802400
  800159:	e8 2e 01 00 00       	call   80028c <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 30 80 00    	pushl  0x803000
  800167:	e8 1b 07 00 00       	call   800887 <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 30 80 00    	pushl  0x803000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 10 08 00 00       	call   800990 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 34 24 80 00       	push   $0x802434
  80018f:	e8 f8 00 00 00       	call   80028c <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
	return;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001a4:	e8 53 0b 00 00       	call   800cfc <sys_getenvid>
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b6:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	7e 07                	jle    8001c6 <libmain+0x2d>
		binaryname = argv[0];
  8001bf:	8b 06                	mov    (%esi),%eax
  8001c1:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	e8 63 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d0:	e8 0a 00 00 00       	call   8001df <exit>
}
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e5:	e8 0c 13 00 00       	call   8014f6 <close_all>
	sys_env_destroy(0);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	e8 c7 0a 00 00       	call   800cbb <sys_env_destroy>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800203:	8b 13                	mov    (%ebx),%edx
  800205:	8d 42 01             	lea    0x1(%edx),%eax
  800208:	89 03                	mov    %eax,(%ebx)
  80020a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800211:	3d ff 00 00 00       	cmp    $0xff,%eax
  800216:	75 1a                	jne    800232 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	68 ff 00 00 00       	push   $0xff
  800220:	8d 43 08             	lea    0x8(%ebx),%eax
  800223:	50                   	push   %eax
  800224:	e8 55 0a 00 00       	call   800c7e <sys_cputs>
		b->idx = 0;
  800229:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800232:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800236:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800244:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024b:	00 00 00 
	b.cnt = 0;
  80024e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800255:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800264:	50                   	push   %eax
  800265:	68 f9 01 80 00       	push   $0x8001f9
  80026a:	e8 54 01 00 00       	call   8003c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026f:	83 c4 08             	add    $0x8,%esp
  800272:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800278:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027e:	50                   	push   %eax
  80027f:	e8 fa 09 00 00       	call   800c7e <sys_cputs>

	return b.cnt;
}
  800284:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800292:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 08             	pushl  0x8(%ebp)
  800299:	e8 9d ff ff ff       	call   80023b <vcprintf>
	va_end(ap);

	return cnt;
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 1c             	sub    $0x1c,%esp
  8002a9:	89 c7                	mov    %eax,%edi
  8002ab:	89 d6                	mov    %edx,%esi
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002c7:	39 d3                	cmp    %edx,%ebx
  8002c9:	72 05                	jb     8002d0 <printnum+0x30>
  8002cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ce:	77 45                	ja     800315 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	ff 75 18             	pushl  0x18(%ebp)
  8002d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002dc:	53                   	push   %ebx
  8002dd:	ff 75 10             	pushl  0x10(%ebp)
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ef:	e8 7c 1e 00 00       	call   802170 <__udivdi3>
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	52                   	push   %edx
  8002f8:	50                   	push   %eax
  8002f9:	89 f2                	mov    %esi,%edx
  8002fb:	89 f8                	mov    %edi,%eax
  8002fd:	e8 9e ff ff ff       	call   8002a0 <printnum>
  800302:	83 c4 20             	add    $0x20,%esp
  800305:	eb 18                	jmp    80031f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	ff 75 18             	pushl  0x18(%ebp)
  80030e:	ff d7                	call   *%edi
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	eb 03                	jmp    800318 <printnum+0x78>
  800315:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	85 db                	test   %ebx,%ebx
  80031d:	7f e8                	jg     800307 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	56                   	push   %esi
  800323:	83 ec 04             	sub    $0x4,%esp
  800326:	ff 75 e4             	pushl  -0x1c(%ebp)
  800329:	ff 75 e0             	pushl  -0x20(%ebp)
  80032c:	ff 75 dc             	pushl  -0x24(%ebp)
  80032f:	ff 75 d8             	pushl  -0x28(%ebp)
  800332:	e8 69 1f 00 00       	call   8022a0 <__umoddi3>
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	0f be 80 ac 24 80 00 	movsbl 0x8024ac(%eax),%eax
  800341:	50                   	push   %eax
  800342:	ff d7                	call   *%edi
}
  800344:	83 c4 10             	add    $0x10,%esp
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800352:	83 fa 01             	cmp    $0x1,%edx
  800355:	7e 0e                	jle    800365 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800357:	8b 10                	mov    (%eax),%edx
  800359:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035c:	89 08                	mov    %ecx,(%eax)
  80035e:	8b 02                	mov    (%edx),%eax
  800360:	8b 52 04             	mov    0x4(%edx),%edx
  800363:	eb 22                	jmp    800387 <getuint+0x38>
	else if (lflag)
  800365:	85 d2                	test   %edx,%edx
  800367:	74 10                	je     800379 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036e:	89 08                	mov    %ecx,(%eax)
  800370:	8b 02                	mov    (%edx),%eax
  800372:	ba 00 00 00 00       	mov    $0x0,%edx
  800377:	eb 0e                	jmp    800387 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800387:	5d                   	pop    %ebp
  800388:	c3                   	ret    

00800389 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800393:	8b 10                	mov    (%eax),%edx
  800395:	3b 50 04             	cmp    0x4(%eax),%edx
  800398:	73 0a                	jae    8003a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80039d:	89 08                	mov    %ecx,(%eax)
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a2:	88 02                	mov    %al,(%edx)
}
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003af:	50                   	push   %eax
  8003b0:	ff 75 10             	pushl  0x10(%ebp)
  8003b3:	ff 75 0c             	pushl  0xc(%ebp)
  8003b6:	ff 75 08             	pushl  0x8(%ebp)
  8003b9:	e8 05 00 00 00       	call   8003c3 <vprintfmt>
	va_end(ap);
}
  8003be:	83 c4 10             	add    $0x10,%esp
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    

008003c3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	57                   	push   %edi
  8003c7:	56                   	push   %esi
  8003c8:	53                   	push   %ebx
  8003c9:	83 ec 2c             	sub    $0x2c,%esp
  8003cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8003cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d5:	eb 12                	jmp    8003e9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	0f 84 38 04 00 00    	je     800817 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8003df:	83 ec 08             	sub    $0x8,%esp
  8003e2:	53                   	push   %ebx
  8003e3:	50                   	push   %eax
  8003e4:	ff d6                	call   *%esi
  8003e6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e9:	83 c7 01             	add    $0x1,%edi
  8003ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003f0:	83 f8 25             	cmp    $0x25,%eax
  8003f3:	75 e2                	jne    8003d7 <vprintfmt+0x14>
  8003f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800400:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800407:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80040e:	ba 00 00 00 00       	mov    $0x0,%edx
  800413:	eb 07                	jmp    80041c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  800418:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8d 47 01             	lea    0x1(%edi),%eax
  80041f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800422:	0f b6 07             	movzbl (%edi),%eax
  800425:	0f b6 c8             	movzbl %al,%ecx
  800428:	83 e8 23             	sub    $0x23,%eax
  80042b:	3c 55                	cmp    $0x55,%al
  80042d:	0f 87 c9 03 00 00    	ja     8007fc <vprintfmt+0x439>
  800433:	0f b6 c0             	movzbl %al,%eax
  800436:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800440:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800444:	eb d6                	jmp    80041c <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  800446:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  80044d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  800453:	eb 94                	jmp    8003e9 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  800455:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  80045c:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  800462:	eb 85                	jmp    8003e9 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  800464:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  80046b:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  800471:	e9 73 ff ff ff       	jmp    8003e9 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  800476:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  80047d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800480:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  800483:	e9 61 ff ff ff       	jmp    8003e9 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  800488:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  80048f:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  800495:	e9 4f ff ff ff       	jmp    8003e9 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80049a:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  8004a1:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  8004a7:	e9 3d ff ff ff       	jmp    8003e9 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  8004ac:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  8004b3:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  8004b9:	e9 2b ff ff ff       	jmp    8003e9 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  8004be:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  8004c5:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8004cb:	e9 19 ff ff ff       	jmp    8003e9 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  8004d0:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  8004d7:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8004dd:	e9 07 ff ff ff       	jmp    8003e9 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8004e2:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  8004e9:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8004ef:	e9 f5 fe ff ff       	jmp    8003e9 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ff:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800502:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800506:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800509:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80050c:	83 fa 09             	cmp    $0x9,%edx
  80050f:	77 3f                	ja     800550 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800511:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800514:	eb e9                	jmp    8004ff <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 48 04             	lea    0x4(%eax),%ecx
  80051c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800524:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800527:	eb 2d                	jmp    800556 <vprintfmt+0x193>
  800529:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052c:	85 c0                	test   %eax,%eax
  80052e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800533:	0f 49 c8             	cmovns %eax,%ecx
  800536:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053c:	e9 db fe ff ff       	jmp    80041c <vprintfmt+0x59>
  800541:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800544:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80054b:	e9 cc fe ff ff       	jmp    80041c <vprintfmt+0x59>
  800550:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800553:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800556:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80055a:	0f 89 bc fe ff ff    	jns    80041c <vprintfmt+0x59>
				width = precision, precision = -1;
  800560:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800563:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800566:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80056d:	e9 aa fe ff ff       	jmp    80041c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800572:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800575:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800578:	e9 9f fe ff ff       	jmp    80041c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8d 50 04             	lea    0x4(%eax),%edx
  800583:	89 55 14             	mov    %edx,0x14(%ebp)
  800586:	83 ec 08             	sub    $0x8,%esp
  800589:	53                   	push   %ebx
  80058a:	ff 30                	pushl  (%eax)
  80058c:	ff d6                	call   *%esi
			break;
  80058e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800591:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800594:	e9 50 fe ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8d 50 04             	lea    0x4(%eax),%edx
  80059f:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	99                   	cltd   
  8005a5:	31 d0                	xor    %edx,%eax
  8005a7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a9:	83 f8 0f             	cmp    $0xf,%eax
  8005ac:	7f 0b                	jg     8005b9 <vprintfmt+0x1f6>
  8005ae:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  8005b5:	85 d2                	test   %edx,%edx
  8005b7:	75 18                	jne    8005d1 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  8005b9:	50                   	push   %eax
  8005ba:	68 c4 24 80 00       	push   $0x8024c4
  8005bf:	53                   	push   %ebx
  8005c0:	56                   	push   %esi
  8005c1:	e8 e0 fd ff ff       	call   8003a6 <printfmt>
  8005c6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005cc:	e9 18 fe ff ff       	jmp    8003e9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005d1:	52                   	push   %edx
  8005d2:	68 5d 29 80 00       	push   $0x80295d
  8005d7:	53                   	push   %ebx
  8005d8:	56                   	push   %esi
  8005d9:	e8 c8 fd ff ff       	call   8003a6 <printfmt>
  8005de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e4:	e9 00 fe ff ff       	jmp    8003e9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8d 50 04             	lea    0x4(%eax),%edx
  8005ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005f4:	85 ff                	test   %edi,%edi
  8005f6:	b8 bd 24 80 00       	mov    $0x8024bd,%eax
  8005fb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005fe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800602:	0f 8e 94 00 00 00    	jle    80069c <vprintfmt+0x2d9>
  800608:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80060c:	0f 84 98 00 00 00    	je     8006aa <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	ff 75 d0             	pushl  -0x30(%ebp)
  800618:	57                   	push   %edi
  800619:	e8 81 02 00 00       	call   80089f <strnlen>
  80061e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800621:	29 c1                	sub    %eax,%ecx
  800623:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800626:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800629:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80062d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800630:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800633:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800635:	eb 0f                	jmp    800646 <vprintfmt+0x283>
					putch(padc, putdat);
  800637:	83 ec 08             	sub    $0x8,%esp
  80063a:	53                   	push   %ebx
  80063b:	ff 75 e0             	pushl  -0x20(%ebp)
  80063e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800640:	83 ef 01             	sub    $0x1,%edi
  800643:	83 c4 10             	add    $0x10,%esp
  800646:	85 ff                	test   %edi,%edi
  800648:	7f ed                	jg     800637 <vprintfmt+0x274>
  80064a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80064d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800650:	85 c9                	test   %ecx,%ecx
  800652:	b8 00 00 00 00       	mov    $0x0,%eax
  800657:	0f 49 c1             	cmovns %ecx,%eax
  80065a:	29 c1                	sub    %eax,%ecx
  80065c:	89 75 08             	mov    %esi,0x8(%ebp)
  80065f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800662:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800665:	89 cb                	mov    %ecx,%ebx
  800667:	eb 4d                	jmp    8006b6 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800669:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80066d:	74 1b                	je     80068a <vprintfmt+0x2c7>
  80066f:	0f be c0             	movsbl %al,%eax
  800672:	83 e8 20             	sub    $0x20,%eax
  800675:	83 f8 5e             	cmp    $0x5e,%eax
  800678:	76 10                	jbe    80068a <vprintfmt+0x2c7>
					putch('?', putdat);
  80067a:	83 ec 08             	sub    $0x8,%esp
  80067d:	ff 75 0c             	pushl  0xc(%ebp)
  800680:	6a 3f                	push   $0x3f
  800682:	ff 55 08             	call   *0x8(%ebp)
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	eb 0d                	jmp    800697 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	ff 75 0c             	pushl  0xc(%ebp)
  800690:	52                   	push   %edx
  800691:	ff 55 08             	call   *0x8(%ebp)
  800694:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800697:	83 eb 01             	sub    $0x1,%ebx
  80069a:	eb 1a                	jmp    8006b6 <vprintfmt+0x2f3>
  80069c:	89 75 08             	mov    %esi,0x8(%ebp)
  80069f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006a2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006a5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006a8:	eb 0c                	jmp    8006b6 <vprintfmt+0x2f3>
  8006aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8006ad:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006b6:	83 c7 01             	add    $0x1,%edi
  8006b9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006bd:	0f be d0             	movsbl %al,%edx
  8006c0:	85 d2                	test   %edx,%edx
  8006c2:	74 23                	je     8006e7 <vprintfmt+0x324>
  8006c4:	85 f6                	test   %esi,%esi
  8006c6:	78 a1                	js     800669 <vprintfmt+0x2a6>
  8006c8:	83 ee 01             	sub    $0x1,%esi
  8006cb:	79 9c                	jns    800669 <vprintfmt+0x2a6>
  8006cd:	89 df                	mov    %ebx,%edi
  8006cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d5:	eb 18                	jmp    8006ef <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	53                   	push   %ebx
  8006db:	6a 20                	push   $0x20
  8006dd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006df:	83 ef 01             	sub    $0x1,%edi
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	eb 08                	jmp    8006ef <vprintfmt+0x32c>
  8006e7:	89 df                	mov    %ebx,%edi
  8006e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ef:	85 ff                	test   %edi,%edi
  8006f1:	7f e4                	jg     8006d7 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f6:	e9 ee fc ff ff       	jmp    8003e9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006fb:	83 fa 01             	cmp    $0x1,%edx
  8006fe:	7e 16                	jle    800716 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800700:	8b 45 14             	mov    0x14(%ebp),%eax
  800703:	8d 50 08             	lea    0x8(%eax),%edx
  800706:	89 55 14             	mov    %edx,0x14(%ebp)
  800709:	8b 50 04             	mov    0x4(%eax),%edx
  80070c:	8b 00                	mov    (%eax),%eax
  80070e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800711:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800714:	eb 32                	jmp    800748 <vprintfmt+0x385>
	else if (lflag)
  800716:	85 d2                	test   %edx,%edx
  800718:	74 18                	je     800732 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8d 50 04             	lea    0x4(%eax),%edx
  800720:	89 55 14             	mov    %edx,0x14(%ebp)
  800723:	8b 00                	mov    (%eax),%eax
  800725:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800728:	89 c1                	mov    %eax,%ecx
  80072a:	c1 f9 1f             	sar    $0x1f,%ecx
  80072d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800730:	eb 16                	jmp    800748 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8d 50 04             	lea    0x4(%eax),%edx
  800738:	89 55 14             	mov    %edx,0x14(%ebp)
  80073b:	8b 00                	mov    (%eax),%eax
  80073d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800740:	89 c1                	mov    %eax,%ecx
  800742:	c1 f9 1f             	sar    $0x1f,%ecx
  800745:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800748:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80074b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80074e:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800753:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800757:	79 6f                	jns    8007c8 <vprintfmt+0x405>
				putch('-', putdat);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	53                   	push   %ebx
  80075d:	6a 2d                	push   $0x2d
  80075f:	ff d6                	call   *%esi
				num = -(long long) num;
  800761:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800764:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800767:	f7 d8                	neg    %eax
  800769:	83 d2 00             	adc    $0x0,%edx
  80076c:	f7 da                	neg    %edx
  80076e:	83 c4 10             	add    $0x10,%esp
  800771:	eb 55                	jmp    8007c8 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800773:	8d 45 14             	lea    0x14(%ebp),%eax
  800776:	e8 d4 fb ff ff       	call   80034f <getuint>
			base = 10;
  80077b:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800780:	eb 46                	jmp    8007c8 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800782:	8d 45 14             	lea    0x14(%ebp),%eax
  800785:	e8 c5 fb ff ff       	call   80034f <getuint>
			base = 8;
  80078a:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  80078f:	eb 37                	jmp    8007c8 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800791:	83 ec 08             	sub    $0x8,%esp
  800794:	53                   	push   %ebx
  800795:	6a 30                	push   $0x30
  800797:	ff d6                	call   *%esi
			putch('x', putdat);
  800799:	83 c4 08             	add    $0x8,%esp
  80079c:	53                   	push   %ebx
  80079d:	6a 78                	push   $0x78
  80079f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a4:	8d 50 04             	lea    0x4(%eax),%edx
  8007a7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007aa:	8b 00                	mov    (%eax),%eax
  8007ac:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007b1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007b4:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8007b9:	eb 0d                	jmp    8007c8 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007be:	e8 8c fb ff ff       	call   80034f <getuint>
			base = 16;
  8007c3:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c8:	83 ec 0c             	sub    $0xc,%esp
  8007cb:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8007cf:	51                   	push   %ecx
  8007d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d3:	57                   	push   %edi
  8007d4:	52                   	push   %edx
  8007d5:	50                   	push   %eax
  8007d6:	89 da                	mov    %ebx,%edx
  8007d8:	89 f0                	mov    %esi,%eax
  8007da:	e8 c1 fa ff ff       	call   8002a0 <printnum>
			break;
  8007df:	83 c4 20             	add    $0x20,%esp
  8007e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007e5:	e9 ff fb ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ea:	83 ec 08             	sub    $0x8,%esp
  8007ed:	53                   	push   %ebx
  8007ee:	51                   	push   %ecx
  8007ef:	ff d6                	call   *%esi
			break;
  8007f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007f7:	e9 ed fb ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007fc:	83 ec 08             	sub    $0x8,%esp
  8007ff:	53                   	push   %ebx
  800800:	6a 25                	push   $0x25
  800802:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800804:	83 c4 10             	add    $0x10,%esp
  800807:	eb 03                	jmp    80080c <vprintfmt+0x449>
  800809:	83 ef 01             	sub    $0x1,%edi
  80080c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800810:	75 f7                	jne    800809 <vprintfmt+0x446>
  800812:	e9 d2 fb ff ff       	jmp    8003e9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800817:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081a:	5b                   	pop    %ebx
  80081b:	5e                   	pop    %esi
  80081c:	5f                   	pop    %edi
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	83 ec 18             	sub    $0x18,%esp
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800832:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800835:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083c:	85 c0                	test   %eax,%eax
  80083e:	74 26                	je     800866 <vsnprintf+0x47>
  800840:	85 d2                	test   %edx,%edx
  800842:	7e 22                	jle    800866 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800844:	ff 75 14             	pushl  0x14(%ebp)
  800847:	ff 75 10             	pushl  0x10(%ebp)
  80084a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084d:	50                   	push   %eax
  80084e:	68 89 03 80 00       	push   $0x800389
  800853:	e8 6b fb ff ff       	call   8003c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800858:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800861:	83 c4 10             	add    $0x10,%esp
  800864:	eb 05                	jmp    80086b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800866:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    

0080086d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800873:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800876:	50                   	push   %eax
  800877:	ff 75 10             	pushl  0x10(%ebp)
  80087a:	ff 75 0c             	pushl  0xc(%ebp)
  80087d:	ff 75 08             	pushl  0x8(%ebp)
  800880:	e8 9a ff ff ff       	call   80081f <vsnprintf>
	va_end(ap);

	return rc;
}
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80088d:	b8 00 00 00 00       	mov    $0x0,%eax
  800892:	eb 03                	jmp    800897 <strlen+0x10>
		n++;
  800894:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800897:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80089b:	75 f7                	jne    800894 <strlen+0xd>
		n++;
	return n;
}
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ad:	eb 03                	jmp    8008b2 <strnlen+0x13>
		n++;
  8008af:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b2:	39 c2                	cmp    %eax,%edx
  8008b4:	74 08                	je     8008be <strnlen+0x1f>
  8008b6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008ba:	75 f3                	jne    8008af <strnlen+0x10>
  8008bc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	53                   	push   %ebx
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ca:	89 c2                	mov    %eax,%edx
  8008cc:	83 c2 01             	add    $0x1,%edx
  8008cf:	83 c1 01             	add    $0x1,%ecx
  8008d2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008d6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d9:	84 db                	test   %bl,%bl
  8008db:	75 ef                	jne    8008cc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008dd:	5b                   	pop    %ebx
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	53                   	push   %ebx
  8008e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e7:	53                   	push   %ebx
  8008e8:	e8 9a ff ff ff       	call   800887 <strlen>
  8008ed:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008f0:	ff 75 0c             	pushl  0xc(%ebp)
  8008f3:	01 d8                	add    %ebx,%eax
  8008f5:	50                   	push   %eax
  8008f6:	e8 c5 ff ff ff       	call   8008c0 <strcpy>
	return dst;
}
  8008fb:	89 d8                	mov    %ebx,%eax
  8008fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	56                   	push   %esi
  800906:	53                   	push   %ebx
  800907:	8b 75 08             	mov    0x8(%ebp),%esi
  80090a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090d:	89 f3                	mov    %esi,%ebx
  80090f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800912:	89 f2                	mov    %esi,%edx
  800914:	eb 0f                	jmp    800925 <strncpy+0x23>
		*dst++ = *src;
  800916:	83 c2 01             	add    $0x1,%edx
  800919:	0f b6 01             	movzbl (%ecx),%eax
  80091c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80091f:	80 39 01             	cmpb   $0x1,(%ecx)
  800922:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800925:	39 da                	cmp    %ebx,%edx
  800927:	75 ed                	jne    800916 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800929:	89 f0                	mov    %esi,%eax
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	56                   	push   %esi
  800933:	53                   	push   %ebx
  800934:	8b 75 08             	mov    0x8(%ebp),%esi
  800937:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093a:	8b 55 10             	mov    0x10(%ebp),%edx
  80093d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80093f:	85 d2                	test   %edx,%edx
  800941:	74 21                	je     800964 <strlcpy+0x35>
  800943:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800947:	89 f2                	mov    %esi,%edx
  800949:	eb 09                	jmp    800954 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80094b:	83 c2 01             	add    $0x1,%edx
  80094e:	83 c1 01             	add    $0x1,%ecx
  800951:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800954:	39 c2                	cmp    %eax,%edx
  800956:	74 09                	je     800961 <strlcpy+0x32>
  800958:	0f b6 19             	movzbl (%ecx),%ebx
  80095b:	84 db                	test   %bl,%bl
  80095d:	75 ec                	jne    80094b <strlcpy+0x1c>
  80095f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800961:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800964:	29 f0                	sub    %esi,%eax
}
  800966:	5b                   	pop    %ebx
  800967:	5e                   	pop    %esi
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800973:	eb 06                	jmp    80097b <strcmp+0x11>
		p++, q++;
  800975:	83 c1 01             	add    $0x1,%ecx
  800978:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80097b:	0f b6 01             	movzbl (%ecx),%eax
  80097e:	84 c0                	test   %al,%al
  800980:	74 04                	je     800986 <strcmp+0x1c>
  800982:	3a 02                	cmp    (%edx),%al
  800984:	74 ef                	je     800975 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800986:	0f b6 c0             	movzbl %al,%eax
  800989:	0f b6 12             	movzbl (%edx),%edx
  80098c:	29 d0                	sub    %edx,%eax
}
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	53                   	push   %ebx
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099a:	89 c3                	mov    %eax,%ebx
  80099c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80099f:	eb 06                	jmp    8009a7 <strncmp+0x17>
		n--, p++, q++;
  8009a1:	83 c0 01             	add    $0x1,%eax
  8009a4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a7:	39 d8                	cmp    %ebx,%eax
  8009a9:	74 15                	je     8009c0 <strncmp+0x30>
  8009ab:	0f b6 08             	movzbl (%eax),%ecx
  8009ae:	84 c9                	test   %cl,%cl
  8009b0:	74 04                	je     8009b6 <strncmp+0x26>
  8009b2:	3a 0a                	cmp    (%edx),%cl
  8009b4:	74 eb                	je     8009a1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b6:	0f b6 00             	movzbl (%eax),%eax
  8009b9:	0f b6 12             	movzbl (%edx),%edx
  8009bc:	29 d0                	sub    %edx,%eax
  8009be:	eb 05                	jmp    8009c5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c5:	5b                   	pop    %ebx
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d2:	eb 07                	jmp    8009db <strchr+0x13>
		if (*s == c)
  8009d4:	38 ca                	cmp    %cl,%dl
  8009d6:	74 0f                	je     8009e7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d8:	83 c0 01             	add    $0x1,%eax
  8009db:	0f b6 10             	movzbl (%eax),%edx
  8009de:	84 d2                	test   %dl,%dl
  8009e0:	75 f2                	jne    8009d4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f3:	eb 03                	jmp    8009f8 <strfind+0xf>
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009fb:	38 ca                	cmp    %cl,%dl
  8009fd:	74 04                	je     800a03 <strfind+0x1a>
  8009ff:	84 d2                	test   %dl,%dl
  800a01:	75 f2                	jne    8009f5 <strfind+0xc>
			break;
	return (char *) s;
}
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	57                   	push   %edi
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a11:	85 c9                	test   %ecx,%ecx
  800a13:	74 36                	je     800a4b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1b:	75 28                	jne    800a45 <memset+0x40>
  800a1d:	f6 c1 03             	test   $0x3,%cl
  800a20:	75 23                	jne    800a45 <memset+0x40>
		c &= 0xFF;
  800a22:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a26:	89 d3                	mov    %edx,%ebx
  800a28:	c1 e3 08             	shl    $0x8,%ebx
  800a2b:	89 d6                	mov    %edx,%esi
  800a2d:	c1 e6 18             	shl    $0x18,%esi
  800a30:	89 d0                	mov    %edx,%eax
  800a32:	c1 e0 10             	shl    $0x10,%eax
  800a35:	09 f0                	or     %esi,%eax
  800a37:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a39:	89 d8                	mov    %ebx,%eax
  800a3b:	09 d0                	or     %edx,%eax
  800a3d:	c1 e9 02             	shr    $0x2,%ecx
  800a40:	fc                   	cld    
  800a41:	f3 ab                	rep stos %eax,%es:(%edi)
  800a43:	eb 06                	jmp    800a4b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a48:	fc                   	cld    
  800a49:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4b:	89 f8                	mov    %edi,%eax
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	57                   	push   %edi
  800a56:	56                   	push   %esi
  800a57:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a60:	39 c6                	cmp    %eax,%esi
  800a62:	73 35                	jae    800a99 <memmove+0x47>
  800a64:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a67:	39 d0                	cmp    %edx,%eax
  800a69:	73 2e                	jae    800a99 <memmove+0x47>
		s += n;
		d += n;
  800a6b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6e:	89 d6                	mov    %edx,%esi
  800a70:	09 fe                	or     %edi,%esi
  800a72:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a78:	75 13                	jne    800a8d <memmove+0x3b>
  800a7a:	f6 c1 03             	test   $0x3,%cl
  800a7d:	75 0e                	jne    800a8d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a7f:	83 ef 04             	sub    $0x4,%edi
  800a82:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a85:	c1 e9 02             	shr    $0x2,%ecx
  800a88:	fd                   	std    
  800a89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8b:	eb 09                	jmp    800a96 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a8d:	83 ef 01             	sub    $0x1,%edi
  800a90:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a93:	fd                   	std    
  800a94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a96:	fc                   	cld    
  800a97:	eb 1d                	jmp    800ab6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a99:	89 f2                	mov    %esi,%edx
  800a9b:	09 c2                	or     %eax,%edx
  800a9d:	f6 c2 03             	test   $0x3,%dl
  800aa0:	75 0f                	jne    800ab1 <memmove+0x5f>
  800aa2:	f6 c1 03             	test   $0x3,%cl
  800aa5:	75 0a                	jne    800ab1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800aa7:	c1 e9 02             	shr    $0x2,%ecx
  800aaa:	89 c7                	mov    %eax,%edi
  800aac:	fc                   	cld    
  800aad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aaf:	eb 05                	jmp    800ab6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ab1:	89 c7                	mov    %eax,%edi
  800ab3:	fc                   	cld    
  800ab4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800abd:	ff 75 10             	pushl  0x10(%ebp)
  800ac0:	ff 75 0c             	pushl  0xc(%ebp)
  800ac3:	ff 75 08             	pushl  0x8(%ebp)
  800ac6:	e8 87 ff ff ff       	call   800a52 <memmove>
}
  800acb:	c9                   	leave  
  800acc:	c3                   	ret    

00800acd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad8:	89 c6                	mov    %eax,%esi
  800ada:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800add:	eb 1a                	jmp    800af9 <memcmp+0x2c>
		if (*s1 != *s2)
  800adf:	0f b6 08             	movzbl (%eax),%ecx
  800ae2:	0f b6 1a             	movzbl (%edx),%ebx
  800ae5:	38 d9                	cmp    %bl,%cl
  800ae7:	74 0a                	je     800af3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ae9:	0f b6 c1             	movzbl %cl,%eax
  800aec:	0f b6 db             	movzbl %bl,%ebx
  800aef:	29 d8                	sub    %ebx,%eax
  800af1:	eb 0f                	jmp    800b02 <memcmp+0x35>
		s1++, s2++;
  800af3:	83 c0 01             	add    $0x1,%eax
  800af6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af9:	39 f0                	cmp    %esi,%eax
  800afb:	75 e2                	jne    800adf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	53                   	push   %ebx
  800b0a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b0d:	89 c1                	mov    %eax,%ecx
  800b0f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b12:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b16:	eb 0a                	jmp    800b22 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b18:	0f b6 10             	movzbl (%eax),%edx
  800b1b:	39 da                	cmp    %ebx,%edx
  800b1d:	74 07                	je     800b26 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b1f:	83 c0 01             	add    $0x1,%eax
  800b22:	39 c8                	cmp    %ecx,%eax
  800b24:	72 f2                	jb     800b18 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b26:	5b                   	pop    %ebx
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b35:	eb 03                	jmp    800b3a <strtol+0x11>
		s++;
  800b37:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3a:	0f b6 01             	movzbl (%ecx),%eax
  800b3d:	3c 20                	cmp    $0x20,%al
  800b3f:	74 f6                	je     800b37 <strtol+0xe>
  800b41:	3c 09                	cmp    $0x9,%al
  800b43:	74 f2                	je     800b37 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b45:	3c 2b                	cmp    $0x2b,%al
  800b47:	75 0a                	jne    800b53 <strtol+0x2a>
		s++;
  800b49:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b51:	eb 11                	jmp    800b64 <strtol+0x3b>
  800b53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b58:	3c 2d                	cmp    $0x2d,%al
  800b5a:	75 08                	jne    800b64 <strtol+0x3b>
		s++, neg = 1;
  800b5c:	83 c1 01             	add    $0x1,%ecx
  800b5f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b64:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b6a:	75 15                	jne    800b81 <strtol+0x58>
  800b6c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6f:	75 10                	jne    800b81 <strtol+0x58>
  800b71:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b75:	75 7c                	jne    800bf3 <strtol+0xca>
		s += 2, base = 16;
  800b77:	83 c1 02             	add    $0x2,%ecx
  800b7a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b7f:	eb 16                	jmp    800b97 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b81:	85 db                	test   %ebx,%ebx
  800b83:	75 12                	jne    800b97 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b85:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b8a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b8d:	75 08                	jne    800b97 <strtol+0x6e>
		s++, base = 8;
  800b8f:	83 c1 01             	add    $0x1,%ecx
  800b92:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b9f:	0f b6 11             	movzbl (%ecx),%edx
  800ba2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ba5:	89 f3                	mov    %esi,%ebx
  800ba7:	80 fb 09             	cmp    $0x9,%bl
  800baa:	77 08                	ja     800bb4 <strtol+0x8b>
			dig = *s - '0';
  800bac:	0f be d2             	movsbl %dl,%edx
  800baf:	83 ea 30             	sub    $0x30,%edx
  800bb2:	eb 22                	jmp    800bd6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bb4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bb7:	89 f3                	mov    %esi,%ebx
  800bb9:	80 fb 19             	cmp    $0x19,%bl
  800bbc:	77 08                	ja     800bc6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bbe:	0f be d2             	movsbl %dl,%edx
  800bc1:	83 ea 57             	sub    $0x57,%edx
  800bc4:	eb 10                	jmp    800bd6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bc6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc9:	89 f3                	mov    %esi,%ebx
  800bcb:	80 fb 19             	cmp    $0x19,%bl
  800bce:	77 16                	ja     800be6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bd0:	0f be d2             	movsbl %dl,%edx
  800bd3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bd6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bd9:	7d 0b                	jge    800be6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bdb:	83 c1 01             	add    $0x1,%ecx
  800bde:	0f af 45 10          	imul   0x10(%ebp),%eax
  800be2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800be4:	eb b9                	jmp    800b9f <strtol+0x76>

	if (endptr)
  800be6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bea:	74 0d                	je     800bf9 <strtol+0xd0>
		*endptr = (char *) s;
  800bec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bef:	89 0e                	mov    %ecx,(%esi)
  800bf1:	eb 06                	jmp    800bf9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf3:	85 db                	test   %ebx,%ebx
  800bf5:	74 98                	je     800b8f <strtol+0x66>
  800bf7:	eb 9e                	jmp    800b97 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bf9:	89 c2                	mov    %eax,%edx
  800bfb:	f7 da                	neg    %edx
  800bfd:	85 ff                	test   %edi,%edi
  800bff:	0f 45 c2             	cmovne %edx,%eax
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 04             	sub    $0x4,%esp
  800c10:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800c13:	57                   	push   %edi
  800c14:	e8 6e fc ff ff       	call   800887 <strlen>
  800c19:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800c1c:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800c1f:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800c24:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800c29:	eb 46                	jmp    800c71 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800c2b:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800c2f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800c32:	80 f9 09             	cmp    $0x9,%cl
  800c35:	77 08                	ja     800c3f <charhex_to_dec+0x38>
			num = s[i] - '0';
  800c37:	0f be d2             	movsbl %dl,%edx
  800c3a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800c3d:	eb 27                	jmp    800c66 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800c3f:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800c42:	80 f9 05             	cmp    $0x5,%cl
  800c45:	77 08                	ja     800c4f <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800c47:	0f be d2             	movsbl %dl,%edx
  800c4a:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800c4d:	eb 17                	jmp    800c66 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800c4f:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800c52:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800c55:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800c5a:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800c5e:	77 06                	ja     800c66 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800c60:	0f be d2             	movsbl %dl,%edx
  800c63:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800c66:	0f af ce             	imul   %esi,%ecx
  800c69:	01 c8                	add    %ecx,%eax
		base *= 16;
  800c6b:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800c6e:	83 eb 01             	sub    $0x1,%ebx
  800c71:	83 fb 01             	cmp    $0x1,%ebx
  800c74:	7f b5                	jg     800c2b <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	b8 00 00 00 00       	mov    $0x0,%eax
  800c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	89 c3                	mov    %eax,%ebx
  800c91:	89 c7                	mov    %eax,%edi
  800c93:	89 c6                	mov    %eax,%esi
  800c95:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_cgetc>:

int
sys_cgetc(void)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca7:	b8 01 00 00 00       	mov    $0x1,%eax
  800cac:	89 d1                	mov    %edx,%ecx
  800cae:	89 d3                	mov    %edx,%ebx
  800cb0:	89 d7                	mov    %edx,%edi
  800cb2:	89 d6                	mov    %edx,%esi
  800cb4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
  800cc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc9:	b8 03 00 00 00       	mov    $0x3,%eax
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	89 cb                	mov    %ecx,%ebx
  800cd3:	89 cf                	mov    %ecx,%edi
  800cd5:	89 ce                	mov    %ecx,%esi
  800cd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd9:	85 c0                	test   %eax,%eax
  800cdb:	7e 17                	jle    800cf4 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdd:	83 ec 0c             	sub    $0xc,%esp
  800ce0:	50                   	push   %eax
  800ce1:	6a 03                	push   $0x3
  800ce3:	68 9f 27 80 00       	push   $0x80279f
  800ce8:	6a 23                	push   $0x23
  800cea:	68 bc 27 80 00       	push   $0x8027bc
  800cef:	e8 69 13 00 00       	call   80205d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800d07:	b8 02 00 00 00       	mov    $0x2,%eax
  800d0c:	89 d1                	mov    %edx,%ecx
  800d0e:	89 d3                	mov    %edx,%ebx
  800d10:	89 d7                	mov    %edx,%edi
  800d12:	89 d6                	mov    %edx,%esi
  800d14:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_yield>:

void
sys_yield(void)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d21:	ba 00 00 00 00       	mov    $0x0,%edx
  800d26:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d2b:	89 d1                	mov    %edx,%ecx
  800d2d:	89 d3                	mov    %edx,%ebx
  800d2f:	89 d7                	mov    %edx,%edi
  800d31:	89 d6                	mov    %edx,%esi
  800d33:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	be 00 00 00 00       	mov    $0x0,%esi
  800d48:	b8 04 00 00 00       	mov    $0x4,%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d56:	89 f7                	mov    %esi,%edi
  800d58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	7e 17                	jle    800d75 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5e:	83 ec 0c             	sub    $0xc,%esp
  800d61:	50                   	push   %eax
  800d62:	6a 04                	push   $0x4
  800d64:	68 9f 27 80 00       	push   $0x80279f
  800d69:	6a 23                	push   $0x23
  800d6b:	68 bc 27 80 00       	push   $0x8027bc
  800d70:	e8 e8 12 00 00       	call   80205d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d86:	b8 05 00 00 00       	mov    $0x5,%eax
  800d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d94:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d97:	8b 75 18             	mov    0x18(%ebp),%esi
  800d9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	7e 17                	jle    800db7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	50                   	push   %eax
  800da4:	6a 05                	push   $0x5
  800da6:	68 9f 27 80 00       	push   $0x80279f
  800dab:	6a 23                	push   $0x23
  800dad:	68 bc 27 80 00       	push   $0x8027bc
  800db2:	e8 a6 12 00 00       	call   80205d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800db7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
  800dc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcd:	b8 06 00 00 00       	mov    $0x6,%eax
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd8:	89 df                	mov    %ebx,%edi
  800dda:	89 de                	mov    %ebx,%esi
  800ddc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dde:	85 c0                	test   %eax,%eax
  800de0:	7e 17                	jle    800df9 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	83 ec 0c             	sub    $0xc,%esp
  800de5:	50                   	push   %eax
  800de6:	6a 06                	push   $0x6
  800de8:	68 9f 27 80 00       	push   $0x80279f
  800ded:	6a 23                	push   $0x23
  800def:	68 bc 27 80 00       	push   $0x8027bc
  800df4:	e8 64 12 00 00       	call   80205d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800df9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800e0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0f:	b8 08 00 00 00       	mov    $0x8,%eax
  800e14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e17:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1a:	89 df                	mov    %ebx,%edi
  800e1c:	89 de                	mov    %ebx,%esi
  800e1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e20:	85 c0                	test   %eax,%eax
  800e22:	7e 17                	jle    800e3b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e24:	83 ec 0c             	sub    $0xc,%esp
  800e27:	50                   	push   %eax
  800e28:	6a 08                	push   $0x8
  800e2a:	68 9f 27 80 00       	push   $0x80279f
  800e2f:	6a 23                	push   $0x23
  800e31:	68 bc 27 80 00       	push   $0x8027bc
  800e36:	e8 22 12 00 00       	call   80205d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800e51:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800e64:	7e 17                	jle    800e7d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e66:	83 ec 0c             	sub    $0xc,%esp
  800e69:	50                   	push   %eax
  800e6a:	6a 0a                	push   $0xa
  800e6c:	68 9f 27 80 00       	push   $0x80279f
  800e71:	6a 23                	push   $0x23
  800e73:	68 bc 27 80 00       	push   $0x8027bc
  800e78:	e8 e0 11 00 00       	call   80205d <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800e93:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800ea6:	7e 17                	jle    800ebf <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea8:	83 ec 0c             	sub    $0xc,%esp
  800eab:	50                   	push   %eax
  800eac:	6a 09                	push   $0x9
  800eae:	68 9f 27 80 00       	push   $0x80279f
  800eb3:	6a 23                	push   $0x23
  800eb5:	68 bc 27 80 00       	push   $0x8027bc
  800eba:	e8 9e 11 00 00       	call   80205d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ebf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec2:	5b                   	pop    %ebx
  800ec3:	5e                   	pop    %esi
  800ec4:	5f                   	pop    %edi
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	57                   	push   %edi
  800ecb:	56                   	push   %esi
  800ecc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecd:	be 00 00 00 00       	mov    $0x0,%esi
  800ed2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ed7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eda:	8b 55 08             	mov    0x8(%ebp),%edx
  800edd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ee3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ee5:	5b                   	pop    %ebx
  800ee6:	5e                   	pop    %esi
  800ee7:	5f                   	pop    %edi
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	57                   	push   %edi
  800eee:	56                   	push   %esi
  800eef:	53                   	push   %ebx
  800ef0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ef8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800efd:	8b 55 08             	mov    0x8(%ebp),%edx
  800f00:	89 cb                	mov    %ecx,%ebx
  800f02:	89 cf                	mov    %ecx,%edi
  800f04:	89 ce                	mov    %ecx,%esi
  800f06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	7e 17                	jle    800f23 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0c:	83 ec 0c             	sub    $0xc,%esp
  800f0f:	50                   	push   %eax
  800f10:	6a 0d                	push   $0xd
  800f12:	68 9f 27 80 00       	push   $0x80279f
  800f17:	6a 23                	push   $0x23
  800f19:	68 bc 27 80 00       	push   $0x8027bc
  800f1e:	e8 3a 11 00 00       	call   80205d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f26:	5b                   	pop    %ebx
  800f27:	5e                   	pop    %esi
  800f28:	5f                   	pop    %edi
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    

00800f2b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	53                   	push   %ebx
  800f2f:	83 ec 04             	sub    $0x4,%esp
  800f32:	8b 45 08             	mov    0x8(%ebp),%eax

	
	void *addr = (void *) utf->utf_fault_va;
  800f35:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800f37:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f3b:	74 11                	je     800f4e <pgfault+0x23>
  800f3d:	89 d8                	mov    %ebx,%eax
  800f3f:	c1 e8 0c             	shr    $0xc,%eax
  800f42:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f49:	f6 c4 08             	test   $0x8,%ah
  800f4c:	75 14                	jne    800f62 <pgfault+0x37>
		panic("page fault");
  800f4e:	83 ec 04             	sub    $0x4,%esp
  800f51:	68 ca 27 80 00       	push   $0x8027ca
  800f56:	6a 5b                	push   $0x5b
  800f58:	68 d5 27 80 00       	push   $0x8027d5
  800f5d:	e8 fb 10 00 00       	call   80205d <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// allocate a new page and map it at a temporary location
	if((r = sys_page_alloc(0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800f62:	83 ec 04             	sub    $0x4,%esp
  800f65:	6a 07                	push   $0x7
  800f67:	68 00 f0 7f 00       	push   $0x7ff000
  800f6c:	6a 00                	push   $0x0
  800f6e:	e8 c7 fd ff ff       	call   800d3a <sys_page_alloc>
  800f73:	83 c4 10             	add    $0x10,%esp
  800f76:	85 c0                	test   %eax,%eax
  800f78:	79 12                	jns    800f8c <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800f7a:	50                   	push   %eax
  800f7b:	68 e0 27 80 00       	push   $0x8027e0
  800f80:	6a 66                	push   $0x66
  800f82:	68 d5 27 80 00       	push   $0x8027d5
  800f87:	e8 d1 10 00 00       	call   80205d <_panic>

	// copy date to new page
	//strncpy((char *)PFTEMP, (char *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
	memcpy((void *)PFTEMP, (void *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
  800f8c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f92:	83 ec 04             	sub    $0x4,%esp
  800f95:	68 00 10 00 00       	push   $0x1000
  800f9a:	53                   	push   %ebx
  800f9b:	68 00 f0 7f 00       	push   $0x7ff000
  800fa0:	e8 15 fb ff ff       	call   800aba <memcpy>

	// move the new page to the old page's address
	if((r = sys_page_map(0, (void *)PFTEMP, 0, (void *)
  800fa5:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fac:	53                   	push   %ebx
  800fad:	6a 00                	push   $0x0
  800faf:	68 00 f0 7f 00       	push   $0x7ff000
  800fb4:	6a 00                	push   $0x0
  800fb6:	e8 c2 fd ff ff       	call   800d7d <sys_page_map>
  800fbb:	83 c4 20             	add    $0x20,%esp
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	79 12                	jns    800fd4 <pgfault+0xa9>
		(ROUNDDOWN(addr, PGSIZE)), PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_map: %e", r);
  800fc2:	50                   	push   %eax
  800fc3:	68 f3 27 80 00       	push   $0x8027f3
  800fc8:	6a 6f                	push   $0x6f
  800fca:	68 d5 27 80 00       	push   $0x8027d5
  800fcf:	e8 89 10 00 00       	call   80205d <_panic>

	// unmap page on PFTEMP
	if((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800fd4:	83 ec 08             	sub    $0x8,%esp
  800fd7:	68 00 f0 7f 00       	push   $0x7ff000
  800fdc:	6a 00                	push   $0x0
  800fde:	e8 dc fd ff ff       	call   800dbf <sys_page_unmap>
  800fe3:	83 c4 10             	add    $0x10,%esp
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	79 12                	jns    800ffc <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  800fea:	50                   	push   %eax
  800feb:	68 04 28 80 00       	push   $0x802804
  800ff0:	6a 73                	push   $0x73
  800ff2:	68 d5 27 80 00       	push   $0x8027d5
  800ff7:	e8 61 10 00 00       	call   80205d <_panic>


}
  800ffc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fff:	c9                   	leave  
  801000:	c3                   	ret    

00801001 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	57                   	push   %edi
  801005:	56                   	push   %esi
  801006:	53                   	push   %ebx
  801007:	83 ec 28             	sub    $0x28,%esp

	#ifdef CHALLENGE 
	set_exception_handler(pgfault, T_PGFLT);
	#else
	// set up page fault handler
	set_pgfault_handler(pgfault);
  80100a:	68 2b 0f 80 00       	push   $0x800f2b
  80100f:	e8 8f 10 00 00       	call   8020a3 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801014:	b8 07 00 00 00       	mov    $0x7,%eax
  801019:	cd 30                	int    $0x30
  80101b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80101e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	#endif

	// create a child
	envid = sys_exofork();
	if (envid < 0)
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	85 c0                	test   %eax,%eax
  801026:	79 15                	jns    80103d <fork+0x3c>
		panic("sys_exofork: %e", envid);
  801028:	50                   	push   %eax
  801029:	68 17 28 80 00       	push   $0x802817
  80102e:	68 d0 00 00 00       	push   $0xd0
  801033:	68 d5 27 80 00       	push   $0x8027d5
  801038:	e8 20 10 00 00       	call   80205d <_panic>
  80103d:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801042:	be 00 08 00 00       	mov    $0x800,%esi
	// we are the child
	if(envid == 0) {
  801047:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80104b:	75 21                	jne    80106e <fork+0x6d>
		// the copied valude of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  80104d:	e8 aa fc ff ff       	call   800cfc <sys_getenvid>
  801052:	25 ff 03 00 00       	and    $0x3ff,%eax
  801057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80105a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80105f:	a3 08 40 80 00       	mov    %eax,0x804008
		/*// alloc exception stack
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
			PTE_P | PTE_U | PTE_W)) < 0)
			panic("sys_page_alloc: %e", r);*/

		return 0;
  801064:	b8 00 00 00 00       	mov    $0x0,%eax
  801069:	e9 a3 01 00 00       	jmp    801211 <fork+0x210>
{
	int r;

	// LAB 4: Your code here.
	
	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P))
  80106e:	89 d8                	mov    %ebx,%eax
  801070:	c1 e8 16             	shr    $0x16,%eax
  801073:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107a:	a8 01                	test   $0x1,%al
  80107c:	0f 84 f0 00 00 00    	je     801172 <fork+0x171>
		return 0;

	// virtual page pn's page table entry
	pte_t pe = uvpt[pn];
  801082:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi


	if((pe & PTE_P) && (pe & PTE_U)) {
  801089:	89 f8                	mov    %edi,%eax
  80108b:	83 e0 05             	and    $0x5,%eax
  80108e:	83 f8 05             	cmp    $0x5,%eax
  801091:	0f 85 db 00 00 00    	jne    801172 <fork+0x171>
		// share with the child environment 
		if(pe & PTE_SHARE) {
  801097:	f7 c7 00 04 00 00    	test   $0x400,%edi
  80109d:	74 36                	je     8010d5 <fork+0xd4>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  80109f:	83 ec 0c             	sub    $0xc,%esp
  8010a2:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  8010a8:	57                   	push   %edi
  8010a9:	53                   	push   %ebx
  8010aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ad:	53                   	push   %ebx
  8010ae:	6a 00                	push   $0x0
  8010b0:	e8 c8 fc ff ff       	call   800d7d <sys_page_map>
  8010b5:	83 c4 20             	add    $0x20,%esp
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	0f 89 b2 00 00 00    	jns    801172 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  8010c0:	50                   	push   %eax
  8010c1:	68 27 28 80 00       	push   $0x802827
  8010c6:	68 97 00 00 00       	push   $0x97
  8010cb:	68 d5 27 80 00       	push   $0x8027d5
  8010d0:	e8 88 0f 00 00       	call   80205d <_panic>
		}
		// the page is writable or copy-on-write
		else if((pe & PTE_W) || (pe & PTE_COW)) {
  8010d5:	f7 c7 02 08 00 00    	test   $0x802,%edi
  8010db:	74 63                	je     801140 <fork+0x13f>
			// create the child mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, 
  8010dd:	81 e7 05 06 00 00    	and    $0x605,%edi
  8010e3:	81 cf 00 08 00 00    	or     $0x800,%edi
  8010e9:	83 ec 0c             	sub    $0xc,%esp
  8010ec:	57                   	push   %edi
  8010ed:	53                   	push   %ebx
  8010ee:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f1:	53                   	push   %ebx
  8010f2:	6a 00                	push   $0x0
  8010f4:	e8 84 fc ff ff       	call   800d7d <sys_page_map>
  8010f9:	83 c4 20             	add    $0x20,%esp
  8010fc:	85 c0                	test   %eax,%eax
  8010fe:	79 15                	jns    801115 <fork+0x114>
				(void *)(pn*PGSIZE), (pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  801100:	50                   	push   %eax
  801101:	68 27 28 80 00       	push   $0x802827
  801106:	68 9e 00 00 00       	push   $0x9e
  80110b:	68 d5 27 80 00       	push   $0x8027d5
  801110:	e8 48 0f 00 00       	call   80205d <_panic>
			// map the parent mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE),
  801115:	83 ec 0c             	sub    $0xc,%esp
  801118:	57                   	push   %edi
  801119:	53                   	push   %ebx
  80111a:	6a 00                	push   $0x0
  80111c:	53                   	push   %ebx
  80111d:	6a 00                	push   $0x0
  80111f:	e8 59 fc ff ff       	call   800d7d <sys_page_map>
  801124:	83 c4 20             	add    $0x20,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	79 47                	jns    801172 <fork+0x171>
				(pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  80112b:	50                   	push   %eax
  80112c:	68 27 28 80 00       	push   $0x802827
  801131:	68 a2 00 00 00       	push   $0xa2
  801136:	68 d5 27 80 00       	push   $0x8027d5
  80113b:	e8 1d 0f 00 00       	call   80205d <_panic>
		}	
		else {
			// create the child mapping read only
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  801140:	83 ec 0c             	sub    $0xc,%esp
  801143:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  801149:	57                   	push   %edi
  80114a:	53                   	push   %ebx
  80114b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80114e:	53                   	push   %ebx
  80114f:	6a 00                	push   $0x0
  801151:	e8 27 fc ff ff       	call   800d7d <sys_page_map>
  801156:	83 c4 20             	add    $0x20,%esp
  801159:	85 c0                	test   %eax,%eax
  80115b:	79 15                	jns    801172 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  80115d:	50                   	push   %eax
  80115e:	68 27 28 80 00       	push   $0x802827
  801163:	68 a8 00 00 00       	push   $0xa8
  801168:	68 d5 27 80 00       	push   $0x8027d5
  80116d:	e8 eb 0e 00 00       	call   80205d <_panic>
			panic("sys_page_alloc: %e", r);*/

		return 0;
	}
	// copy address to child environment's page dirctory
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn)
  801172:	83 c6 01             	add    $0x1,%esi
  801175:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80117b:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801181:	0f 85 e7 fe ff ff    	jne    80106e <fork+0x6d>
	#ifdef CHALLENGE 
	if((r = sys_env_set_exception_upcall(envid, thisenv->env_exception_upcall)) < 0)
		panic("sys_env_set_exception_upcall: %e", r);
	#else
	// set child's page fault handler
	if((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  801187:	a1 08 40 80 00       	mov    0x804008,%eax
  80118c:	8b 40 64             	mov    0x64(%eax),%eax
  80118f:	83 ec 08             	sub    $0x8,%esp
  801192:	50                   	push   %eax
  801193:	ff 75 e0             	pushl  -0x20(%ebp)
  801196:	e8 ea fc ff ff       	call   800e85 <sys_env_set_pgfault_upcall>
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	79 15                	jns    8011b7 <fork+0x1b6>
		panic("sys_env_set_pgfault_upcall: %e", r);
  8011a2:	50                   	push   %eax
  8011a3:	68 60 28 80 00       	push   $0x802860
  8011a8:	68 e9 00 00 00       	push   $0xe9
  8011ad:	68 d5 27 80 00       	push   $0x8027d5
  8011b2:	e8 a6 0e 00 00       	call   80205d <_panic>
	#endif

	// alloc exception stack for child environment
	if((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), 
  8011b7:	83 ec 04             	sub    $0x4,%esp
  8011ba:	6a 07                	push   $0x7
  8011bc:	68 00 f0 bf ee       	push   $0xeebff000
  8011c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c4:	e8 71 fb ff ff       	call   800d3a <sys_page_alloc>
  8011c9:	83 c4 10             	add    $0x10,%esp
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	79 15                	jns    8011e5 <fork+0x1e4>
		PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
  8011d0:	50                   	push   %eax
  8011d1:	68 e0 27 80 00       	push   $0x8027e0
  8011d6:	68 ef 00 00 00       	push   $0xef
  8011db:	68 d5 27 80 00       	push   $0x8027d5
  8011e0:	e8 78 0e 00 00       	call   80205d <_panic>

	// start the child environment running
	if((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8011e5:	83 ec 08             	sub    $0x8,%esp
  8011e8:	6a 02                	push   $0x2
  8011ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ed:	e8 0f fc ff ff       	call   800e01 <sys_env_set_status>
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	79 15                	jns    80120e <fork+0x20d>
		panic("sys_env_set_status: %e", r);
  8011f9:	50                   	push   %eax
  8011fa:	68 33 28 80 00       	push   $0x802833
  8011ff:	68 f3 00 00 00       	push   $0xf3
  801204:	68 d5 27 80 00       	push   $0x8027d5
  801209:	e8 4f 0e 00 00       	call   80205d <_panic>

	return envid;
  80120e:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801211:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801214:	5b                   	pop    %ebx
  801215:	5e                   	pop    %esi
  801216:	5f                   	pop    %edi
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <sfork>:

// Challenge!
int
sfork(void)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80121f:	68 4a 28 80 00       	push   $0x80284a
  801224:	68 fc 00 00 00       	push   $0xfc
  801229:	68 d5 27 80 00       	push   $0x8027d5
  80122e:	e8 2a 0e 00 00       	call   80205d <_panic>

00801233 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	56                   	push   %esi
  801237:	53                   	push   %ebx
  801238:	8b 75 08             	mov    0x8(%ebp),%esi
  80123b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801241:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801243:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801248:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  80124b:	83 ec 0c             	sub    $0xc,%esp
  80124e:	50                   	push   %eax
  80124f:	e8 96 fc ff ff       	call   800eea <sys_ipc_recv>
  801254:	83 c4 10             	add    $0x10,%esp
  801257:	85 c0                	test   %eax,%eax
  801259:	79 16                	jns    801271 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  80125b:	85 f6                	test   %esi,%esi
  80125d:	74 06                	je     801265 <ipc_recv+0x32>
			*from_env_store = 0;
  80125f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801265:	85 db                	test   %ebx,%ebx
  801267:	74 2c                	je     801295 <ipc_recv+0x62>
			*perm_store = 0;
  801269:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80126f:	eb 24                	jmp    801295 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801271:	85 f6                	test   %esi,%esi
  801273:	74 0a                	je     80127f <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801275:	a1 08 40 80 00       	mov    0x804008,%eax
  80127a:	8b 40 74             	mov    0x74(%eax),%eax
  80127d:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80127f:	85 db                	test   %ebx,%ebx
  801281:	74 0a                	je     80128d <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801283:	a1 08 40 80 00       	mov    0x804008,%eax
  801288:	8b 40 78             	mov    0x78(%eax),%eax
  80128b:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  80128d:	a1 08 40 80 00       	mov    0x804008,%eax
  801292:	8b 40 70             	mov    0x70(%eax),%eax
}
  801295:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801298:	5b                   	pop    %ebx
  801299:	5e                   	pop    %esi
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    

0080129c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	57                   	push   %edi
  8012a0:	56                   	push   %esi
  8012a1:	53                   	push   %ebx
  8012a2:	83 ec 0c             	sub    $0xc,%esp
  8012a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8012ae:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8012b0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8012b5:	0f 44 d8             	cmove  %eax,%ebx
  8012b8:	eb 1e                	jmp    8012d8 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  8012ba:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012bd:	74 14                	je     8012d3 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  8012bf:	83 ec 04             	sub    $0x4,%esp
  8012c2:	68 80 28 80 00       	push   $0x802880
  8012c7:	6a 44                	push   $0x44
  8012c9:	68 ab 28 80 00       	push   $0x8028ab
  8012ce:	e8 8a 0d 00 00       	call   80205d <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  8012d3:	e8 43 fa ff ff       	call   800d1b <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8012d8:	ff 75 14             	pushl  0x14(%ebp)
  8012db:	53                   	push   %ebx
  8012dc:	56                   	push   %esi
  8012dd:	57                   	push   %edi
  8012de:	e8 e4 fb ff ff       	call   800ec7 <sys_ipc_try_send>
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	78 d0                	js     8012ba <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  8012ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ed:	5b                   	pop    %ebx
  8012ee:	5e                   	pop    %esi
  8012ef:	5f                   	pop    %edi
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    

008012f2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012f8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012fd:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801300:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801306:	8b 52 50             	mov    0x50(%edx),%edx
  801309:	39 ca                	cmp    %ecx,%edx
  80130b:	75 0d                	jne    80131a <ipc_find_env+0x28>
			return envs[i].env_id;
  80130d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801310:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801315:	8b 40 48             	mov    0x48(%eax),%eax
  801318:	eb 0f                	jmp    801329 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80131a:	83 c0 01             	add    $0x1,%eax
  80131d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801322:	75 d9                	jne    8012fd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801324:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801329:	5d                   	pop    %ebp
  80132a:	c3                   	ret    

0080132b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80132b:	55                   	push   %ebp
  80132c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80132e:	8b 45 08             	mov    0x8(%ebp),%eax
  801331:	05 00 00 00 30       	add    $0x30000000,%eax
  801336:	c1 e8 0c             	shr    $0xc,%eax
}
  801339:	5d                   	pop    %ebp
  80133a:	c3                   	ret    

0080133b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80133e:	8b 45 08             	mov    0x8(%ebp),%eax
  801341:	05 00 00 00 30       	add    $0x30000000,%eax
  801346:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80134b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801350:	5d                   	pop    %ebp
  801351:	c3                   	ret    

00801352 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801358:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80135d:	89 c2                	mov    %eax,%edx
  80135f:	c1 ea 16             	shr    $0x16,%edx
  801362:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801369:	f6 c2 01             	test   $0x1,%dl
  80136c:	74 11                	je     80137f <fd_alloc+0x2d>
  80136e:	89 c2                	mov    %eax,%edx
  801370:	c1 ea 0c             	shr    $0xc,%edx
  801373:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80137a:	f6 c2 01             	test   $0x1,%dl
  80137d:	75 09                	jne    801388 <fd_alloc+0x36>
			*fd_store = fd;
  80137f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801381:	b8 00 00 00 00       	mov    $0x0,%eax
  801386:	eb 17                	jmp    80139f <fd_alloc+0x4d>
  801388:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80138d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801392:	75 c9                	jne    80135d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801394:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80139a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80139f:	5d                   	pop    %ebp
  8013a0:	c3                   	ret    

008013a1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013a7:	83 f8 1f             	cmp    $0x1f,%eax
  8013aa:	77 36                	ja     8013e2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013ac:	c1 e0 0c             	shl    $0xc,%eax
  8013af:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013b4:	89 c2                	mov    %eax,%edx
  8013b6:	c1 ea 16             	shr    $0x16,%edx
  8013b9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013c0:	f6 c2 01             	test   $0x1,%dl
  8013c3:	74 24                	je     8013e9 <fd_lookup+0x48>
  8013c5:	89 c2                	mov    %eax,%edx
  8013c7:	c1 ea 0c             	shr    $0xc,%edx
  8013ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013d1:	f6 c2 01             	test   $0x1,%dl
  8013d4:	74 1a                	je     8013f0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013d9:	89 02                	mov    %eax,(%edx)
	return 0;
  8013db:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e0:	eb 13                	jmp    8013f5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e7:	eb 0c                	jmp    8013f5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ee:	eb 05                	jmp    8013f5 <fd_lookup+0x54>
  8013f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013f5:	5d                   	pop    %ebp
  8013f6:	c3                   	ret    

008013f7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	83 ec 08             	sub    $0x8,%esp
  8013fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801400:	ba 34 29 80 00       	mov    $0x802934,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801405:	eb 13                	jmp    80141a <dev_lookup+0x23>
  801407:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80140a:	39 08                	cmp    %ecx,(%eax)
  80140c:	75 0c                	jne    80141a <dev_lookup+0x23>
			*dev = devtab[i];
  80140e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801411:	89 01                	mov    %eax,(%ecx)
			return 0;
  801413:	b8 00 00 00 00       	mov    $0x0,%eax
  801418:	eb 2e                	jmp    801448 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80141a:	8b 02                	mov    (%edx),%eax
  80141c:	85 c0                	test   %eax,%eax
  80141e:	75 e7                	jne    801407 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801420:	a1 08 40 80 00       	mov    0x804008,%eax
  801425:	8b 40 48             	mov    0x48(%eax),%eax
  801428:	83 ec 04             	sub    $0x4,%esp
  80142b:	51                   	push   %ecx
  80142c:	50                   	push   %eax
  80142d:	68 b8 28 80 00       	push   $0x8028b8
  801432:	e8 55 ee ff ff       	call   80028c <cprintf>
	*dev = 0;
  801437:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801448:	c9                   	leave  
  801449:	c3                   	ret    

0080144a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	56                   	push   %esi
  80144e:	53                   	push   %ebx
  80144f:	83 ec 10             	sub    $0x10,%esp
  801452:	8b 75 08             	mov    0x8(%ebp),%esi
  801455:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801458:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145b:	50                   	push   %eax
  80145c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801462:	c1 e8 0c             	shr    $0xc,%eax
  801465:	50                   	push   %eax
  801466:	e8 36 ff ff ff       	call   8013a1 <fd_lookup>
  80146b:	83 c4 08             	add    $0x8,%esp
  80146e:	85 c0                	test   %eax,%eax
  801470:	78 05                	js     801477 <fd_close+0x2d>
	    || fd != fd2) 
  801472:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801475:	74 0c                	je     801483 <fd_close+0x39>
		return (must_exist ? r : 0); 
  801477:	84 db                	test   %bl,%bl
  801479:	ba 00 00 00 00       	mov    $0x0,%edx
  80147e:	0f 44 c2             	cmove  %edx,%eax
  801481:	eb 41                	jmp    8014c4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801483:	83 ec 08             	sub    $0x8,%esp
  801486:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801489:	50                   	push   %eax
  80148a:	ff 36                	pushl  (%esi)
  80148c:	e8 66 ff ff ff       	call   8013f7 <dev_lookup>
  801491:	89 c3                	mov    %eax,%ebx
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	85 c0                	test   %eax,%eax
  801498:	78 1a                	js     8014b4 <fd_close+0x6a>
		if (dev->dev_close) 
  80149a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8014a0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	74 0b                	je     8014b4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014a9:	83 ec 0c             	sub    $0xc,%esp
  8014ac:	56                   	push   %esi
  8014ad:	ff d0                	call   *%eax
  8014af:	89 c3                	mov    %eax,%ebx
  8014b1:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014b4:	83 ec 08             	sub    $0x8,%esp
  8014b7:	56                   	push   %esi
  8014b8:	6a 00                	push   $0x0
  8014ba:	e8 00 f9 ff ff       	call   800dbf <sys_page_unmap>
	return r;
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	89 d8                	mov    %ebx,%eax
}
  8014c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c7:	5b                   	pop    %ebx
  8014c8:	5e                   	pop    %esi
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    

008014cb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d4:	50                   	push   %eax
  8014d5:	ff 75 08             	pushl  0x8(%ebp)
  8014d8:	e8 c4 fe ff ff       	call   8013a1 <fd_lookup>
  8014dd:	83 c4 08             	add    $0x8,%esp
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	78 10                	js     8014f4 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	6a 01                	push   $0x1
  8014e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ec:	e8 59 ff ff ff       	call   80144a <fd_close>
  8014f1:	83 c4 10             	add    $0x10,%esp
}
  8014f4:	c9                   	leave  
  8014f5:	c3                   	ret    

008014f6 <close_all>:

void
close_all(void)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	53                   	push   %ebx
  8014fa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014fd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801502:	83 ec 0c             	sub    $0xc,%esp
  801505:	53                   	push   %ebx
  801506:	e8 c0 ff ff ff       	call   8014cb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80150b:	83 c3 01             	add    $0x1,%ebx
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	83 fb 20             	cmp    $0x20,%ebx
  801514:	75 ec                	jne    801502 <close_all+0xc>
		close(i);
}
  801516:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801519:	c9                   	leave  
  80151a:	c3                   	ret    

0080151b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	57                   	push   %edi
  80151f:	56                   	push   %esi
  801520:	53                   	push   %ebx
  801521:	83 ec 2c             	sub    $0x2c,%esp
  801524:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801527:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80152a:	50                   	push   %eax
  80152b:	ff 75 08             	pushl  0x8(%ebp)
  80152e:	e8 6e fe ff ff       	call   8013a1 <fd_lookup>
  801533:	83 c4 08             	add    $0x8,%esp
  801536:	85 c0                	test   %eax,%eax
  801538:	0f 88 c1 00 00 00    	js     8015ff <dup+0xe4>
		return r;
	close(newfdnum);
  80153e:	83 ec 0c             	sub    $0xc,%esp
  801541:	56                   	push   %esi
  801542:	e8 84 ff ff ff       	call   8014cb <close>

	newfd = INDEX2FD(newfdnum);
  801547:	89 f3                	mov    %esi,%ebx
  801549:	c1 e3 0c             	shl    $0xc,%ebx
  80154c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801552:	83 c4 04             	add    $0x4,%esp
  801555:	ff 75 e4             	pushl  -0x1c(%ebp)
  801558:	e8 de fd ff ff       	call   80133b <fd2data>
  80155d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80155f:	89 1c 24             	mov    %ebx,(%esp)
  801562:	e8 d4 fd ff ff       	call   80133b <fd2data>
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80156d:	89 f8                	mov    %edi,%eax
  80156f:	c1 e8 16             	shr    $0x16,%eax
  801572:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801579:	a8 01                	test   $0x1,%al
  80157b:	74 37                	je     8015b4 <dup+0x99>
  80157d:	89 f8                	mov    %edi,%eax
  80157f:	c1 e8 0c             	shr    $0xc,%eax
  801582:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801589:	f6 c2 01             	test   $0x1,%dl
  80158c:	74 26                	je     8015b4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80158e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801595:	83 ec 0c             	sub    $0xc,%esp
  801598:	25 07 0e 00 00       	and    $0xe07,%eax
  80159d:	50                   	push   %eax
  80159e:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015a1:	6a 00                	push   $0x0
  8015a3:	57                   	push   %edi
  8015a4:	6a 00                	push   $0x0
  8015a6:	e8 d2 f7 ff ff       	call   800d7d <sys_page_map>
  8015ab:	89 c7                	mov    %eax,%edi
  8015ad:	83 c4 20             	add    $0x20,%esp
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	78 2e                	js     8015e2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015b7:	89 d0                	mov    %edx,%eax
  8015b9:	c1 e8 0c             	shr    $0xc,%eax
  8015bc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015c3:	83 ec 0c             	sub    $0xc,%esp
  8015c6:	25 07 0e 00 00       	and    $0xe07,%eax
  8015cb:	50                   	push   %eax
  8015cc:	53                   	push   %ebx
  8015cd:	6a 00                	push   $0x0
  8015cf:	52                   	push   %edx
  8015d0:	6a 00                	push   $0x0
  8015d2:	e8 a6 f7 ff ff       	call   800d7d <sys_page_map>
  8015d7:	89 c7                	mov    %eax,%edi
  8015d9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015dc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015de:	85 ff                	test   %edi,%edi
  8015e0:	79 1d                	jns    8015ff <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015e2:	83 ec 08             	sub    $0x8,%esp
  8015e5:	53                   	push   %ebx
  8015e6:	6a 00                	push   $0x0
  8015e8:	e8 d2 f7 ff ff       	call   800dbf <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015ed:	83 c4 08             	add    $0x8,%esp
  8015f0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015f3:	6a 00                	push   $0x0
  8015f5:	e8 c5 f7 ff ff       	call   800dbf <sys_page_unmap>
	return r;
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	89 f8                	mov    %edi,%eax
}
  8015ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801602:	5b                   	pop    %ebx
  801603:	5e                   	pop    %esi
  801604:	5f                   	pop    %edi
  801605:	5d                   	pop    %ebp
  801606:	c3                   	ret    

00801607 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	53                   	push   %ebx
  80160b:	83 ec 14             	sub    $0x14,%esp
  80160e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801611:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801614:	50                   	push   %eax
  801615:	53                   	push   %ebx
  801616:	e8 86 fd ff ff       	call   8013a1 <fd_lookup>
  80161b:	83 c4 08             	add    $0x8,%esp
  80161e:	89 c2                	mov    %eax,%edx
  801620:	85 c0                	test   %eax,%eax
  801622:	78 6d                	js     801691 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801624:	83 ec 08             	sub    $0x8,%esp
  801627:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162a:	50                   	push   %eax
  80162b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162e:	ff 30                	pushl  (%eax)
  801630:	e8 c2 fd ff ff       	call   8013f7 <dev_lookup>
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	85 c0                	test   %eax,%eax
  80163a:	78 4c                	js     801688 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80163c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80163f:	8b 42 08             	mov    0x8(%edx),%eax
  801642:	83 e0 03             	and    $0x3,%eax
  801645:	83 f8 01             	cmp    $0x1,%eax
  801648:	75 21                	jne    80166b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80164a:	a1 08 40 80 00       	mov    0x804008,%eax
  80164f:	8b 40 48             	mov    0x48(%eax),%eax
  801652:	83 ec 04             	sub    $0x4,%esp
  801655:	53                   	push   %ebx
  801656:	50                   	push   %eax
  801657:	68 f9 28 80 00       	push   $0x8028f9
  80165c:	e8 2b ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801669:	eb 26                	jmp    801691 <read+0x8a>
	}
	if (!dev->dev_read)
  80166b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166e:	8b 40 08             	mov    0x8(%eax),%eax
  801671:	85 c0                	test   %eax,%eax
  801673:	74 17                	je     80168c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801675:	83 ec 04             	sub    $0x4,%esp
  801678:	ff 75 10             	pushl  0x10(%ebp)
  80167b:	ff 75 0c             	pushl  0xc(%ebp)
  80167e:	52                   	push   %edx
  80167f:	ff d0                	call   *%eax
  801681:	89 c2                	mov    %eax,%edx
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	eb 09                	jmp    801691 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801688:	89 c2                	mov    %eax,%edx
  80168a:	eb 05                	jmp    801691 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80168c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801691:	89 d0                	mov    %edx,%eax
  801693:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801696:	c9                   	leave  
  801697:	c3                   	ret    

00801698 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	57                   	push   %edi
  80169c:	56                   	push   %esi
  80169d:	53                   	push   %ebx
  80169e:	83 ec 0c             	sub    $0xc,%esp
  8016a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016a4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ac:	eb 21                	jmp    8016cf <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016ae:	83 ec 04             	sub    $0x4,%esp
  8016b1:	89 f0                	mov    %esi,%eax
  8016b3:	29 d8                	sub    %ebx,%eax
  8016b5:	50                   	push   %eax
  8016b6:	89 d8                	mov    %ebx,%eax
  8016b8:	03 45 0c             	add    0xc(%ebp),%eax
  8016bb:	50                   	push   %eax
  8016bc:	57                   	push   %edi
  8016bd:	e8 45 ff ff ff       	call   801607 <read>
		if (m < 0)
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	78 10                	js     8016d9 <readn+0x41>
			return m;
		if (m == 0)
  8016c9:	85 c0                	test   %eax,%eax
  8016cb:	74 0a                	je     8016d7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016cd:	01 c3                	add    %eax,%ebx
  8016cf:	39 f3                	cmp    %esi,%ebx
  8016d1:	72 db                	jb     8016ae <readn+0x16>
  8016d3:	89 d8                	mov    %ebx,%eax
  8016d5:	eb 02                	jmp    8016d9 <readn+0x41>
  8016d7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016dc:	5b                   	pop    %ebx
  8016dd:	5e                   	pop    %esi
  8016de:	5f                   	pop    %edi
  8016df:	5d                   	pop    %ebp
  8016e0:	c3                   	ret    

008016e1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	53                   	push   %ebx
  8016e5:	83 ec 14             	sub    $0x14,%esp
  8016e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ee:	50                   	push   %eax
  8016ef:	53                   	push   %ebx
  8016f0:	e8 ac fc ff ff       	call   8013a1 <fd_lookup>
  8016f5:	83 c4 08             	add    $0x8,%esp
  8016f8:	89 c2                	mov    %eax,%edx
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 68                	js     801766 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fe:	83 ec 08             	sub    $0x8,%esp
  801701:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801704:	50                   	push   %eax
  801705:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801708:	ff 30                	pushl  (%eax)
  80170a:	e8 e8 fc ff ff       	call   8013f7 <dev_lookup>
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	85 c0                	test   %eax,%eax
  801714:	78 47                	js     80175d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801716:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801719:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80171d:	75 21                	jne    801740 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80171f:	a1 08 40 80 00       	mov    0x804008,%eax
  801724:	8b 40 48             	mov    0x48(%eax),%eax
  801727:	83 ec 04             	sub    $0x4,%esp
  80172a:	53                   	push   %ebx
  80172b:	50                   	push   %eax
  80172c:	68 15 29 80 00       	push   $0x802915
  801731:	e8 56 eb ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80173e:	eb 26                	jmp    801766 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801740:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801743:	8b 52 0c             	mov    0xc(%edx),%edx
  801746:	85 d2                	test   %edx,%edx
  801748:	74 17                	je     801761 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80174a:	83 ec 04             	sub    $0x4,%esp
  80174d:	ff 75 10             	pushl  0x10(%ebp)
  801750:	ff 75 0c             	pushl  0xc(%ebp)
  801753:	50                   	push   %eax
  801754:	ff d2                	call   *%edx
  801756:	89 c2                	mov    %eax,%edx
  801758:	83 c4 10             	add    $0x10,%esp
  80175b:	eb 09                	jmp    801766 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175d:	89 c2                	mov    %eax,%edx
  80175f:	eb 05                	jmp    801766 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801761:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801766:	89 d0                	mov    %edx,%eax
  801768:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176b:	c9                   	leave  
  80176c:	c3                   	ret    

0080176d <seek>:

int
seek(int fdnum, off_t offset)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801773:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801776:	50                   	push   %eax
  801777:	ff 75 08             	pushl  0x8(%ebp)
  80177a:	e8 22 fc ff ff       	call   8013a1 <fd_lookup>
  80177f:	83 c4 08             	add    $0x8,%esp
  801782:	85 c0                	test   %eax,%eax
  801784:	78 0e                	js     801794 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801786:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801789:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80178f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801794:	c9                   	leave  
  801795:	c3                   	ret    

00801796 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	53                   	push   %ebx
  80179a:	83 ec 14             	sub    $0x14,%esp
  80179d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a3:	50                   	push   %eax
  8017a4:	53                   	push   %ebx
  8017a5:	e8 f7 fb ff ff       	call   8013a1 <fd_lookup>
  8017aa:	83 c4 08             	add    $0x8,%esp
  8017ad:	89 c2                	mov    %eax,%edx
  8017af:	85 c0                	test   %eax,%eax
  8017b1:	78 65                	js     801818 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b3:	83 ec 08             	sub    $0x8,%esp
  8017b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b9:	50                   	push   %eax
  8017ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bd:	ff 30                	pushl  (%eax)
  8017bf:	e8 33 fc ff ff       	call   8013f7 <dev_lookup>
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	78 44                	js     80180f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ce:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017d2:	75 21                	jne    8017f5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017d4:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017d9:	8b 40 48             	mov    0x48(%eax),%eax
  8017dc:	83 ec 04             	sub    $0x4,%esp
  8017df:	53                   	push   %ebx
  8017e0:	50                   	push   %eax
  8017e1:	68 d8 28 80 00       	push   $0x8028d8
  8017e6:	e8 a1 ea ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017eb:	83 c4 10             	add    $0x10,%esp
  8017ee:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017f3:	eb 23                	jmp    801818 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f8:	8b 52 18             	mov    0x18(%edx),%edx
  8017fb:	85 d2                	test   %edx,%edx
  8017fd:	74 14                	je     801813 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017ff:	83 ec 08             	sub    $0x8,%esp
  801802:	ff 75 0c             	pushl  0xc(%ebp)
  801805:	50                   	push   %eax
  801806:	ff d2                	call   *%edx
  801808:	89 c2                	mov    %eax,%edx
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	eb 09                	jmp    801818 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80180f:	89 c2                	mov    %eax,%edx
  801811:	eb 05                	jmp    801818 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801813:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801818:	89 d0                	mov    %edx,%eax
  80181a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181d:	c9                   	leave  
  80181e:	c3                   	ret    

0080181f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	53                   	push   %ebx
  801823:	83 ec 14             	sub    $0x14,%esp
  801826:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801829:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182c:	50                   	push   %eax
  80182d:	ff 75 08             	pushl  0x8(%ebp)
  801830:	e8 6c fb ff ff       	call   8013a1 <fd_lookup>
  801835:	83 c4 08             	add    $0x8,%esp
  801838:	89 c2                	mov    %eax,%edx
  80183a:	85 c0                	test   %eax,%eax
  80183c:	78 58                	js     801896 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183e:	83 ec 08             	sub    $0x8,%esp
  801841:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801844:	50                   	push   %eax
  801845:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801848:	ff 30                	pushl  (%eax)
  80184a:	e8 a8 fb ff ff       	call   8013f7 <dev_lookup>
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	85 c0                	test   %eax,%eax
  801854:	78 37                	js     80188d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801856:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801859:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80185d:	74 32                	je     801891 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80185f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801862:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801869:	00 00 00 
	stat->st_isdir = 0;
  80186c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801873:	00 00 00 
	stat->st_dev = dev;
  801876:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80187c:	83 ec 08             	sub    $0x8,%esp
  80187f:	53                   	push   %ebx
  801880:	ff 75 f0             	pushl  -0x10(%ebp)
  801883:	ff 50 14             	call   *0x14(%eax)
  801886:	89 c2                	mov    %eax,%edx
  801888:	83 c4 10             	add    $0x10,%esp
  80188b:	eb 09                	jmp    801896 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80188d:	89 c2                	mov    %eax,%edx
  80188f:	eb 05                	jmp    801896 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801891:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801896:	89 d0                	mov    %edx,%eax
  801898:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189b:	c9                   	leave  
  80189c:	c3                   	ret    

0080189d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80189d:	55                   	push   %ebp
  80189e:	89 e5                	mov    %esp,%ebp
  8018a0:	56                   	push   %esi
  8018a1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018a2:	83 ec 08             	sub    $0x8,%esp
  8018a5:	6a 00                	push   $0x0
  8018a7:	ff 75 08             	pushl  0x8(%ebp)
  8018aa:	e8 2b 02 00 00       	call   801ada <open>
  8018af:	89 c3                	mov    %eax,%ebx
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	78 1b                	js     8018d3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018b8:	83 ec 08             	sub    $0x8,%esp
  8018bb:	ff 75 0c             	pushl  0xc(%ebp)
  8018be:	50                   	push   %eax
  8018bf:	e8 5b ff ff ff       	call   80181f <fstat>
  8018c4:	89 c6                	mov    %eax,%esi
	close(fd);
  8018c6:	89 1c 24             	mov    %ebx,(%esp)
  8018c9:	e8 fd fb ff ff       	call   8014cb <close>
	return r;
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	89 f0                	mov    %esi,%eax
}
  8018d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d6:	5b                   	pop    %ebx
  8018d7:	5e                   	pop    %esi
  8018d8:	5d                   	pop    %ebp
  8018d9:	c3                   	ret    

008018da <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
  8018dd:	56                   	push   %esi
  8018de:	53                   	push   %ebx
  8018df:	89 c6                	mov    %eax,%esi
  8018e1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018e3:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8018ea:	75 12                	jne    8018fe <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018ec:	83 ec 0c             	sub    $0xc,%esp
  8018ef:	6a 01                	push   $0x1
  8018f1:	e8 fc f9 ff ff       	call   8012f2 <ipc_find_env>
  8018f6:	a3 04 40 80 00       	mov    %eax,0x804004
  8018fb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018fe:	6a 07                	push   $0x7
  801900:	68 00 50 80 00       	push   $0x805000
  801905:	56                   	push   %esi
  801906:	ff 35 04 40 80 00    	pushl  0x804004
  80190c:	e8 8b f9 ff ff       	call   80129c <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801911:	83 c4 0c             	add    $0xc,%esp
  801914:	6a 00                	push   $0x0
  801916:	53                   	push   %ebx
  801917:	6a 00                	push   $0x0
  801919:	e8 15 f9 ff ff       	call   801233 <ipc_recv>
}
  80191e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801921:	5b                   	pop    %ebx
  801922:	5e                   	pop    %esi
  801923:	5d                   	pop    %ebp
  801924:	c3                   	ret    

00801925 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80192b:	8b 45 08             	mov    0x8(%ebp),%eax
  80192e:	8b 40 0c             	mov    0xc(%eax),%eax
  801931:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801936:	8b 45 0c             	mov    0xc(%ebp),%eax
  801939:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80193e:	ba 00 00 00 00       	mov    $0x0,%edx
  801943:	b8 02 00 00 00       	mov    $0x2,%eax
  801948:	e8 8d ff ff ff       	call   8018da <fsipc>
}
  80194d:	c9                   	leave  
  80194e:	c3                   	ret    

0080194f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801955:	8b 45 08             	mov    0x8(%ebp),%eax
  801958:	8b 40 0c             	mov    0xc(%eax),%eax
  80195b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801960:	ba 00 00 00 00       	mov    $0x0,%edx
  801965:	b8 06 00 00 00       	mov    $0x6,%eax
  80196a:	e8 6b ff ff ff       	call   8018da <fsipc>
}
  80196f:	c9                   	leave  
  801970:	c3                   	ret    

00801971 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	53                   	push   %ebx
  801975:	83 ec 04             	sub    $0x4,%esp
  801978:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80197b:	8b 45 08             	mov    0x8(%ebp),%eax
  80197e:	8b 40 0c             	mov    0xc(%eax),%eax
  801981:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801986:	ba 00 00 00 00       	mov    $0x0,%edx
  80198b:	b8 05 00 00 00       	mov    $0x5,%eax
  801990:	e8 45 ff ff ff       	call   8018da <fsipc>
  801995:	85 c0                	test   %eax,%eax
  801997:	78 2c                	js     8019c5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801999:	83 ec 08             	sub    $0x8,%esp
  80199c:	68 00 50 80 00       	push   $0x805000
  8019a1:	53                   	push   %ebx
  8019a2:	e8 19 ef ff ff       	call   8008c0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019a7:	a1 80 50 80 00       	mov    0x805080,%eax
  8019ac:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019b2:	a1 84 50 80 00       	mov    0x805084,%eax
  8019b7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019bd:	83 c4 10             	add    $0x10,%esp
  8019c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c8:	c9                   	leave  
  8019c9:	c3                   	ret    

008019ca <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	53                   	push   %ebx
  8019ce:	83 ec 08             	sub    $0x8,%esp
  8019d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8019d4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019d9:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8019de:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  8019ec:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8019f2:	53                   	push   %ebx
  8019f3:	ff 75 0c             	pushl  0xc(%ebp)
  8019f6:	68 08 50 80 00       	push   $0x805008
  8019fb:	e8 52 f0 ff ff       	call   800a52 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801a00:	ba 00 00 00 00       	mov    $0x0,%edx
  801a05:	b8 04 00 00 00       	mov    $0x4,%eax
  801a0a:	e8 cb fe ff ff       	call   8018da <fsipc>
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	85 c0                	test   %eax,%eax
  801a14:	78 3d                	js     801a53 <devfile_write+0x89>
		return r;

	assert(r <= n);
  801a16:	39 d8                	cmp    %ebx,%eax
  801a18:	76 19                	jbe    801a33 <devfile_write+0x69>
  801a1a:	68 44 29 80 00       	push   $0x802944
  801a1f:	68 4b 29 80 00       	push   $0x80294b
  801a24:	68 9f 00 00 00       	push   $0x9f
  801a29:	68 60 29 80 00       	push   $0x802960
  801a2e:	e8 2a 06 00 00       	call   80205d <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801a33:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a38:	76 19                	jbe    801a53 <devfile_write+0x89>
  801a3a:	68 78 29 80 00       	push   $0x802978
  801a3f:	68 4b 29 80 00       	push   $0x80294b
  801a44:	68 a0 00 00 00       	push   $0xa0
  801a49:	68 60 29 80 00       	push   $0x802960
  801a4e:	e8 0a 06 00 00       	call   80205d <_panic>

	return r;
}
  801a53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a56:	c9                   	leave  
  801a57:	c3                   	ret    

00801a58 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	56                   	push   %esi
  801a5c:	53                   	push   %ebx
  801a5d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a60:	8b 45 08             	mov    0x8(%ebp),%eax
  801a63:	8b 40 0c             	mov    0xc(%eax),%eax
  801a66:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a6b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a71:	ba 00 00 00 00       	mov    $0x0,%edx
  801a76:	b8 03 00 00 00       	mov    $0x3,%eax
  801a7b:	e8 5a fe ff ff       	call   8018da <fsipc>
  801a80:	89 c3                	mov    %eax,%ebx
  801a82:	85 c0                	test   %eax,%eax
  801a84:	78 4b                	js     801ad1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a86:	39 c6                	cmp    %eax,%esi
  801a88:	73 16                	jae    801aa0 <devfile_read+0x48>
  801a8a:	68 44 29 80 00       	push   $0x802944
  801a8f:	68 4b 29 80 00       	push   $0x80294b
  801a94:	6a 7e                	push   $0x7e
  801a96:	68 60 29 80 00       	push   $0x802960
  801a9b:	e8 bd 05 00 00       	call   80205d <_panic>
	assert(r <= PGSIZE);
  801aa0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801aa5:	7e 16                	jle    801abd <devfile_read+0x65>
  801aa7:	68 6b 29 80 00       	push   $0x80296b
  801aac:	68 4b 29 80 00       	push   $0x80294b
  801ab1:	6a 7f                	push   $0x7f
  801ab3:	68 60 29 80 00       	push   $0x802960
  801ab8:	e8 a0 05 00 00       	call   80205d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801abd:	83 ec 04             	sub    $0x4,%esp
  801ac0:	50                   	push   %eax
  801ac1:	68 00 50 80 00       	push   $0x805000
  801ac6:	ff 75 0c             	pushl  0xc(%ebp)
  801ac9:	e8 84 ef ff ff       	call   800a52 <memmove>
	return r;
  801ace:	83 c4 10             	add    $0x10,%esp
}
  801ad1:	89 d8                	mov    %ebx,%eax
  801ad3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad6:	5b                   	pop    %ebx
  801ad7:	5e                   	pop    %esi
  801ad8:	5d                   	pop    %ebp
  801ad9:	c3                   	ret    

00801ada <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	53                   	push   %ebx
  801ade:	83 ec 20             	sub    $0x20,%esp
  801ae1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ae4:	53                   	push   %ebx
  801ae5:	e8 9d ed ff ff       	call   800887 <strlen>
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801af2:	7f 67                	jg     801b5b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801af4:	83 ec 0c             	sub    $0xc,%esp
  801af7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afa:	50                   	push   %eax
  801afb:	e8 52 f8 ff ff       	call   801352 <fd_alloc>
  801b00:	83 c4 10             	add    $0x10,%esp
		return r;
  801b03:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b05:	85 c0                	test   %eax,%eax
  801b07:	78 57                	js     801b60 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b09:	83 ec 08             	sub    $0x8,%esp
  801b0c:	53                   	push   %ebx
  801b0d:	68 00 50 80 00       	push   $0x805000
  801b12:	e8 a9 ed ff ff       	call   8008c0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b22:	b8 01 00 00 00       	mov    $0x1,%eax
  801b27:	e8 ae fd ff ff       	call   8018da <fsipc>
  801b2c:	89 c3                	mov    %eax,%ebx
  801b2e:	83 c4 10             	add    $0x10,%esp
  801b31:	85 c0                	test   %eax,%eax
  801b33:	79 14                	jns    801b49 <open+0x6f>
		fd_close(fd, 0);
  801b35:	83 ec 08             	sub    $0x8,%esp
  801b38:	6a 00                	push   $0x0
  801b3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3d:	e8 08 f9 ff ff       	call   80144a <fd_close>
		return r;
  801b42:	83 c4 10             	add    $0x10,%esp
  801b45:	89 da                	mov    %ebx,%edx
  801b47:	eb 17                	jmp    801b60 <open+0x86>
	}

	return fd2num(fd);
  801b49:	83 ec 0c             	sub    $0xc,%esp
  801b4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4f:	e8 d7 f7 ff ff       	call   80132b <fd2num>
  801b54:	89 c2                	mov    %eax,%edx
  801b56:	83 c4 10             	add    $0x10,%esp
  801b59:	eb 05                	jmp    801b60 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b5b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b60:	89 d0                	mov    %edx,%eax
  801b62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b65:	c9                   	leave  
  801b66:	c3                   	ret    

00801b67 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b6d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b72:	b8 08 00 00 00       	mov    $0x8,%eax
  801b77:	e8 5e fd ff ff       	call   8018da <fsipc>
}
  801b7c:	c9                   	leave  
  801b7d:	c3                   	ret    

00801b7e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	56                   	push   %esi
  801b82:	53                   	push   %ebx
  801b83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b86:	83 ec 0c             	sub    $0xc,%esp
  801b89:	ff 75 08             	pushl  0x8(%ebp)
  801b8c:	e8 aa f7 ff ff       	call   80133b <fd2data>
  801b91:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b93:	83 c4 08             	add    $0x8,%esp
  801b96:	68 a5 29 80 00       	push   $0x8029a5
  801b9b:	53                   	push   %ebx
  801b9c:	e8 1f ed ff ff       	call   8008c0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ba1:	8b 46 04             	mov    0x4(%esi),%eax
  801ba4:	2b 06                	sub    (%esi),%eax
  801ba6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bb3:	00 00 00 
	stat->st_dev = &devpipe;
  801bb6:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801bbd:	30 80 00 
	return 0;
}
  801bc0:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc8:	5b                   	pop    %ebx
  801bc9:	5e                   	pop    %esi
  801bca:	5d                   	pop    %ebp
  801bcb:	c3                   	ret    

00801bcc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	53                   	push   %ebx
  801bd0:	83 ec 0c             	sub    $0xc,%esp
  801bd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bd6:	53                   	push   %ebx
  801bd7:	6a 00                	push   $0x0
  801bd9:	e8 e1 f1 ff ff       	call   800dbf <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bde:	89 1c 24             	mov    %ebx,(%esp)
  801be1:	e8 55 f7 ff ff       	call   80133b <fd2data>
  801be6:	83 c4 08             	add    $0x8,%esp
  801be9:	50                   	push   %eax
  801bea:	6a 00                	push   $0x0
  801bec:	e8 ce f1 ff ff       	call   800dbf <sys_page_unmap>
}
  801bf1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	57                   	push   %edi
  801bfa:	56                   	push   %esi
  801bfb:	53                   	push   %ebx
  801bfc:	83 ec 1c             	sub    $0x1c,%esp
  801bff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c02:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c04:	a1 08 40 80 00       	mov    0x804008,%eax
  801c09:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c0c:	83 ec 0c             	sub    $0xc,%esp
  801c0f:	ff 75 e0             	pushl  -0x20(%ebp)
  801c12:	e8 1b 05 00 00       	call   802132 <pageref>
  801c17:	89 c3                	mov    %eax,%ebx
  801c19:	89 3c 24             	mov    %edi,(%esp)
  801c1c:	e8 11 05 00 00       	call   802132 <pageref>
  801c21:	83 c4 10             	add    $0x10,%esp
  801c24:	39 c3                	cmp    %eax,%ebx
  801c26:	0f 94 c1             	sete   %cl
  801c29:	0f b6 c9             	movzbl %cl,%ecx
  801c2c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c2f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801c35:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c38:	39 ce                	cmp    %ecx,%esi
  801c3a:	74 1b                	je     801c57 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c3c:	39 c3                	cmp    %eax,%ebx
  801c3e:	75 c4                	jne    801c04 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c40:	8b 42 58             	mov    0x58(%edx),%eax
  801c43:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c46:	50                   	push   %eax
  801c47:	56                   	push   %esi
  801c48:	68 ac 29 80 00       	push   $0x8029ac
  801c4d:	e8 3a e6 ff ff       	call   80028c <cprintf>
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	eb ad                	jmp    801c04 <_pipeisclosed+0xe>
	}
}
  801c57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    

00801c62 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	57                   	push   %edi
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	83 ec 28             	sub    $0x28,%esp
  801c6b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c6e:	56                   	push   %esi
  801c6f:	e8 c7 f6 ff ff       	call   80133b <fd2data>
  801c74:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	bf 00 00 00 00       	mov    $0x0,%edi
  801c7e:	eb 4b                	jmp    801ccb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c80:	89 da                	mov    %ebx,%edx
  801c82:	89 f0                	mov    %esi,%eax
  801c84:	e8 6d ff ff ff       	call   801bf6 <_pipeisclosed>
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	75 48                	jne    801cd5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c8d:	e8 89 f0 ff ff       	call   800d1b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c92:	8b 43 04             	mov    0x4(%ebx),%eax
  801c95:	8b 0b                	mov    (%ebx),%ecx
  801c97:	8d 51 20             	lea    0x20(%ecx),%edx
  801c9a:	39 d0                	cmp    %edx,%eax
  801c9c:	73 e2                	jae    801c80 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ca5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ca8:	89 c2                	mov    %eax,%edx
  801caa:	c1 fa 1f             	sar    $0x1f,%edx
  801cad:	89 d1                	mov    %edx,%ecx
  801caf:	c1 e9 1b             	shr    $0x1b,%ecx
  801cb2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cb5:	83 e2 1f             	and    $0x1f,%edx
  801cb8:	29 ca                	sub    %ecx,%edx
  801cba:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cbe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cc2:	83 c0 01             	add    $0x1,%eax
  801cc5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc8:	83 c7 01             	add    $0x1,%edi
  801ccb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cce:	75 c2                	jne    801c92 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cd0:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd3:	eb 05                	jmp    801cda <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cd5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cdd:	5b                   	pop    %ebx
  801cde:	5e                   	pop    %esi
  801cdf:	5f                   	pop    %edi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    

00801ce2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	57                   	push   %edi
  801ce6:	56                   	push   %esi
  801ce7:	53                   	push   %ebx
  801ce8:	83 ec 18             	sub    $0x18,%esp
  801ceb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cee:	57                   	push   %edi
  801cef:	e8 47 f6 ff ff       	call   80133b <fd2data>
  801cf4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cf6:	83 c4 10             	add    $0x10,%esp
  801cf9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cfe:	eb 3d                	jmp    801d3d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d00:	85 db                	test   %ebx,%ebx
  801d02:	74 04                	je     801d08 <devpipe_read+0x26>
				return i;
  801d04:	89 d8                	mov    %ebx,%eax
  801d06:	eb 44                	jmp    801d4c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d08:	89 f2                	mov    %esi,%edx
  801d0a:	89 f8                	mov    %edi,%eax
  801d0c:	e8 e5 fe ff ff       	call   801bf6 <_pipeisclosed>
  801d11:	85 c0                	test   %eax,%eax
  801d13:	75 32                	jne    801d47 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d15:	e8 01 f0 ff ff       	call   800d1b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d1a:	8b 06                	mov    (%esi),%eax
  801d1c:	3b 46 04             	cmp    0x4(%esi),%eax
  801d1f:	74 df                	je     801d00 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d21:	99                   	cltd   
  801d22:	c1 ea 1b             	shr    $0x1b,%edx
  801d25:	01 d0                	add    %edx,%eax
  801d27:	83 e0 1f             	and    $0x1f,%eax
  801d2a:	29 d0                	sub    %edx,%eax
  801d2c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d34:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d37:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d3a:	83 c3 01             	add    $0x1,%ebx
  801d3d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d40:	75 d8                	jne    801d1a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d42:	8b 45 10             	mov    0x10(%ebp),%eax
  801d45:	eb 05                	jmp    801d4c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d47:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d4f:	5b                   	pop    %ebx
  801d50:	5e                   	pop    %esi
  801d51:	5f                   	pop    %edi
  801d52:	5d                   	pop    %ebp
  801d53:	c3                   	ret    

00801d54 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	56                   	push   %esi
  801d58:	53                   	push   %ebx
  801d59:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d5f:	50                   	push   %eax
  801d60:	e8 ed f5 ff ff       	call   801352 <fd_alloc>
  801d65:	83 c4 10             	add    $0x10,%esp
  801d68:	89 c2                	mov    %eax,%edx
  801d6a:	85 c0                	test   %eax,%eax
  801d6c:	0f 88 2c 01 00 00    	js     801e9e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d72:	83 ec 04             	sub    $0x4,%esp
  801d75:	68 07 04 00 00       	push   $0x407
  801d7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7d:	6a 00                	push   $0x0
  801d7f:	e8 b6 ef ff ff       	call   800d3a <sys_page_alloc>
  801d84:	83 c4 10             	add    $0x10,%esp
  801d87:	89 c2                	mov    %eax,%edx
  801d89:	85 c0                	test   %eax,%eax
  801d8b:	0f 88 0d 01 00 00    	js     801e9e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d91:	83 ec 0c             	sub    $0xc,%esp
  801d94:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d97:	50                   	push   %eax
  801d98:	e8 b5 f5 ff ff       	call   801352 <fd_alloc>
  801d9d:	89 c3                	mov    %eax,%ebx
  801d9f:	83 c4 10             	add    $0x10,%esp
  801da2:	85 c0                	test   %eax,%eax
  801da4:	0f 88 e2 00 00 00    	js     801e8c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801daa:	83 ec 04             	sub    $0x4,%esp
  801dad:	68 07 04 00 00       	push   $0x407
  801db2:	ff 75 f0             	pushl  -0x10(%ebp)
  801db5:	6a 00                	push   $0x0
  801db7:	e8 7e ef ff ff       	call   800d3a <sys_page_alloc>
  801dbc:	89 c3                	mov    %eax,%ebx
  801dbe:	83 c4 10             	add    $0x10,%esp
  801dc1:	85 c0                	test   %eax,%eax
  801dc3:	0f 88 c3 00 00 00    	js     801e8c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dc9:	83 ec 0c             	sub    $0xc,%esp
  801dcc:	ff 75 f4             	pushl  -0xc(%ebp)
  801dcf:	e8 67 f5 ff ff       	call   80133b <fd2data>
  801dd4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd6:	83 c4 0c             	add    $0xc,%esp
  801dd9:	68 07 04 00 00       	push   $0x407
  801dde:	50                   	push   %eax
  801ddf:	6a 00                	push   $0x0
  801de1:	e8 54 ef ff ff       	call   800d3a <sys_page_alloc>
  801de6:	89 c3                	mov    %eax,%ebx
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	85 c0                	test   %eax,%eax
  801ded:	0f 88 89 00 00 00    	js     801e7c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df3:	83 ec 0c             	sub    $0xc,%esp
  801df6:	ff 75 f0             	pushl  -0x10(%ebp)
  801df9:	e8 3d f5 ff ff       	call   80133b <fd2data>
  801dfe:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e05:	50                   	push   %eax
  801e06:	6a 00                	push   $0x0
  801e08:	56                   	push   %esi
  801e09:	6a 00                	push   $0x0
  801e0b:	e8 6d ef ff ff       	call   800d7d <sys_page_map>
  801e10:	89 c3                	mov    %eax,%ebx
  801e12:	83 c4 20             	add    $0x20,%esp
  801e15:	85 c0                	test   %eax,%eax
  801e17:	78 55                	js     801e6e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e19:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e22:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e27:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e2e:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801e34:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e37:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e3c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e43:	83 ec 0c             	sub    $0xc,%esp
  801e46:	ff 75 f4             	pushl  -0xc(%ebp)
  801e49:	e8 dd f4 ff ff       	call   80132b <fd2num>
  801e4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e51:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e53:	83 c4 04             	add    $0x4,%esp
  801e56:	ff 75 f0             	pushl  -0x10(%ebp)
  801e59:	e8 cd f4 ff ff       	call   80132b <fd2num>
  801e5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e61:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e64:	83 c4 10             	add    $0x10,%esp
  801e67:	ba 00 00 00 00       	mov    $0x0,%edx
  801e6c:	eb 30                	jmp    801e9e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e6e:	83 ec 08             	sub    $0x8,%esp
  801e71:	56                   	push   %esi
  801e72:	6a 00                	push   $0x0
  801e74:	e8 46 ef ff ff       	call   800dbf <sys_page_unmap>
  801e79:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e7c:	83 ec 08             	sub    $0x8,%esp
  801e7f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e82:	6a 00                	push   $0x0
  801e84:	e8 36 ef ff ff       	call   800dbf <sys_page_unmap>
  801e89:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e8c:	83 ec 08             	sub    $0x8,%esp
  801e8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e92:	6a 00                	push   $0x0
  801e94:	e8 26 ef ff ff       	call   800dbf <sys_page_unmap>
  801e99:	83 c4 10             	add    $0x10,%esp
  801e9c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e9e:	89 d0                	mov    %edx,%eax
  801ea0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea3:	5b                   	pop    %ebx
  801ea4:	5e                   	pop    %esi
  801ea5:	5d                   	pop    %ebp
  801ea6:	c3                   	ret    

00801ea7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ead:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb0:	50                   	push   %eax
  801eb1:	ff 75 08             	pushl  0x8(%ebp)
  801eb4:	e8 e8 f4 ff ff       	call   8013a1 <fd_lookup>
  801eb9:	83 c4 10             	add    $0x10,%esp
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	78 18                	js     801ed8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ec0:	83 ec 0c             	sub    $0xc,%esp
  801ec3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec6:	e8 70 f4 ff ff       	call   80133b <fd2data>
	return _pipeisclosed(fd, p);
  801ecb:	89 c2                	mov    %eax,%edx
  801ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed0:	e8 21 fd ff ff       	call   801bf6 <_pipeisclosed>
  801ed5:	83 c4 10             	add    $0x10,%esp
}
  801ed8:	c9                   	leave  
  801ed9:	c3                   	ret    

00801eda <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801edd:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee2:	5d                   	pop    %ebp
  801ee3:	c3                   	ret    

00801ee4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
  801ee7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eea:	68 c4 29 80 00       	push   $0x8029c4
  801eef:	ff 75 0c             	pushl  0xc(%ebp)
  801ef2:	e8 c9 e9 ff ff       	call   8008c0 <strcpy>
	return 0;
}
  801ef7:	b8 00 00 00 00       	mov    $0x0,%eax
  801efc:	c9                   	leave  
  801efd:	c3                   	ret    

00801efe <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	57                   	push   %edi
  801f02:	56                   	push   %esi
  801f03:	53                   	push   %ebx
  801f04:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f0a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f0f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f15:	eb 2d                	jmp    801f44 <devcons_write+0x46>
		m = n - tot;
  801f17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f1a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f1c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f1f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f24:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f27:	83 ec 04             	sub    $0x4,%esp
  801f2a:	53                   	push   %ebx
  801f2b:	03 45 0c             	add    0xc(%ebp),%eax
  801f2e:	50                   	push   %eax
  801f2f:	57                   	push   %edi
  801f30:	e8 1d eb ff ff       	call   800a52 <memmove>
		sys_cputs(buf, m);
  801f35:	83 c4 08             	add    $0x8,%esp
  801f38:	53                   	push   %ebx
  801f39:	57                   	push   %edi
  801f3a:	e8 3f ed ff ff       	call   800c7e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f3f:	01 de                	add    %ebx,%esi
  801f41:	83 c4 10             	add    $0x10,%esp
  801f44:	89 f0                	mov    %esi,%eax
  801f46:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f49:	72 cc                	jb     801f17 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4e:	5b                   	pop    %ebx
  801f4f:	5e                   	pop    %esi
  801f50:	5f                   	pop    %edi
  801f51:	5d                   	pop    %ebp
  801f52:	c3                   	ret    

00801f53 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	83 ec 08             	sub    $0x8,%esp
  801f59:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f62:	74 2a                	je     801f8e <devcons_read+0x3b>
  801f64:	eb 05                	jmp    801f6b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f66:	e8 b0 ed ff ff       	call   800d1b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f6b:	e8 2c ed ff ff       	call   800c9c <sys_cgetc>
  801f70:	85 c0                	test   %eax,%eax
  801f72:	74 f2                	je     801f66 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f74:	85 c0                	test   %eax,%eax
  801f76:	78 16                	js     801f8e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f78:	83 f8 04             	cmp    $0x4,%eax
  801f7b:	74 0c                	je     801f89 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f80:	88 02                	mov    %al,(%edx)
	return 1;
  801f82:	b8 01 00 00 00       	mov    $0x1,%eax
  801f87:	eb 05                	jmp    801f8e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f89:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f8e:	c9                   	leave  
  801f8f:	c3                   	ret    

00801f90 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f96:	8b 45 08             	mov    0x8(%ebp),%eax
  801f99:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f9c:	6a 01                	push   $0x1
  801f9e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fa1:	50                   	push   %eax
  801fa2:	e8 d7 ec ff ff       	call   800c7e <sys_cputs>
}
  801fa7:	83 c4 10             	add    $0x10,%esp
  801faa:	c9                   	leave  
  801fab:	c3                   	ret    

00801fac <getchar>:

int
getchar(void)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fb2:	6a 01                	push   $0x1
  801fb4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fb7:	50                   	push   %eax
  801fb8:	6a 00                	push   $0x0
  801fba:	e8 48 f6 ff ff       	call   801607 <read>
	if (r < 0)
  801fbf:	83 c4 10             	add    $0x10,%esp
  801fc2:	85 c0                	test   %eax,%eax
  801fc4:	78 0f                	js     801fd5 <getchar+0x29>
		return r;
	if (r < 1)
  801fc6:	85 c0                	test   %eax,%eax
  801fc8:	7e 06                	jle    801fd0 <getchar+0x24>
		return -E_EOF;
	return c;
  801fca:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fce:	eb 05                	jmp    801fd5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fd0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fd5:	c9                   	leave  
  801fd6:	c3                   	ret    

00801fd7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fd7:	55                   	push   %ebp
  801fd8:	89 e5                	mov    %esp,%ebp
  801fda:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fdd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe0:	50                   	push   %eax
  801fe1:	ff 75 08             	pushl  0x8(%ebp)
  801fe4:	e8 b8 f3 ff ff       	call   8013a1 <fd_lookup>
  801fe9:	83 c4 10             	add    $0x10,%esp
  801fec:	85 c0                	test   %eax,%eax
  801fee:	78 11                	js     802001 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff3:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801ff9:	39 10                	cmp    %edx,(%eax)
  801ffb:	0f 94 c0             	sete   %al
  801ffe:	0f b6 c0             	movzbl %al,%eax
}
  802001:	c9                   	leave  
  802002:	c3                   	ret    

00802003 <opencons>:

int
opencons(void)
{
  802003:	55                   	push   %ebp
  802004:	89 e5                	mov    %esp,%ebp
  802006:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802009:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80200c:	50                   	push   %eax
  80200d:	e8 40 f3 ff ff       	call   801352 <fd_alloc>
  802012:	83 c4 10             	add    $0x10,%esp
		return r;
  802015:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802017:	85 c0                	test   %eax,%eax
  802019:	78 3e                	js     802059 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80201b:	83 ec 04             	sub    $0x4,%esp
  80201e:	68 07 04 00 00       	push   $0x407
  802023:	ff 75 f4             	pushl  -0xc(%ebp)
  802026:	6a 00                	push   $0x0
  802028:	e8 0d ed ff ff       	call   800d3a <sys_page_alloc>
  80202d:	83 c4 10             	add    $0x10,%esp
		return r;
  802030:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802032:	85 c0                	test   %eax,%eax
  802034:	78 23                	js     802059 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802036:	8b 15 44 30 80 00    	mov    0x803044,%edx
  80203c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802041:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802044:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80204b:	83 ec 0c             	sub    $0xc,%esp
  80204e:	50                   	push   %eax
  80204f:	e8 d7 f2 ff ff       	call   80132b <fd2num>
  802054:	89 c2                	mov    %eax,%edx
  802056:	83 c4 10             	add    $0x10,%esp
}
  802059:	89 d0                	mov    %edx,%eax
  80205b:	c9                   	leave  
  80205c:	c3                   	ret    

0080205d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80205d:	55                   	push   %ebp
  80205e:	89 e5                	mov    %esp,%ebp
  802060:	56                   	push   %esi
  802061:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802062:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802065:	8b 35 08 30 80 00    	mov    0x803008,%esi
  80206b:	e8 8c ec ff ff       	call   800cfc <sys_getenvid>
  802070:	83 ec 0c             	sub    $0xc,%esp
  802073:	ff 75 0c             	pushl  0xc(%ebp)
  802076:	ff 75 08             	pushl  0x8(%ebp)
  802079:	56                   	push   %esi
  80207a:	50                   	push   %eax
  80207b:	68 d0 29 80 00       	push   $0x8029d0
  802080:	e8 07 e2 ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802085:	83 c4 18             	add    $0x18,%esp
  802088:	53                   	push   %ebx
  802089:	ff 75 10             	pushl  0x10(%ebp)
  80208c:	e8 aa e1 ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  802091:	c7 04 24 bd 29 80 00 	movl   $0x8029bd,(%esp)
  802098:	e8 ef e1 ff ff       	call   80028c <cprintf>
  80209d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8020a0:	cc                   	int3   
  8020a1:	eb fd                	jmp    8020a0 <_panic+0x43>

008020a3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020a3:	55                   	push   %ebp
  8020a4:	89 e5                	mov    %esp,%ebp
  8020a6:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  8020a9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8020b0:	75 52                	jne    802104 <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  8020b2:	83 ec 04             	sub    $0x4,%esp
  8020b5:	6a 07                	push   $0x7
  8020b7:	68 00 f0 bf ee       	push   $0xeebff000
  8020bc:	6a 00                	push   $0x0
  8020be:	e8 77 ec ff ff       	call   800d3a <sys_page_alloc>
  8020c3:	83 c4 10             	add    $0x10,%esp
  8020c6:	85 c0                	test   %eax,%eax
  8020c8:	79 12                	jns    8020dc <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  8020ca:	50                   	push   %eax
  8020cb:	68 e0 27 80 00       	push   $0x8027e0
  8020d0:	6a 23                	push   $0x23
  8020d2:	68 f4 29 80 00       	push   $0x8029f4
  8020d7:	e8 81 ff ff ff       	call   80205d <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  8020dc:	83 ec 08             	sub    $0x8,%esp
  8020df:	68 0e 21 80 00       	push   $0x80210e
  8020e4:	6a 00                	push   $0x0
  8020e6:	e8 9a ed ff ff       	call   800e85 <sys_env_set_pgfault_upcall>
  8020eb:	83 c4 10             	add    $0x10,%esp
  8020ee:	85 c0                	test   %eax,%eax
  8020f0:	79 12                	jns    802104 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  8020f2:	50                   	push   %eax
  8020f3:	68 60 28 80 00       	push   $0x802860
  8020f8:	6a 26                	push   $0x26
  8020fa:	68 f4 29 80 00       	push   $0x8029f4
  8020ff:	e8 59 ff ff ff       	call   80205d <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802104:	8b 45 08             	mov    0x8(%ebp),%eax
  802107:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80210c:	c9                   	leave  
  80210d:	c3                   	ret    

0080210e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80210e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80210f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802114:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802116:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  802119:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  80211d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  802122:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  802126:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802128:	83 c4 08             	add    $0x8,%esp
	popal 
  80212b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  80212c:	83 c4 04             	add    $0x4,%esp
	popfl
  80212f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802130:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802131:	c3                   	ret    

00802132 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
  802135:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802138:	89 d0                	mov    %edx,%eax
  80213a:	c1 e8 16             	shr    $0x16,%eax
  80213d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802144:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802149:	f6 c1 01             	test   $0x1,%cl
  80214c:	74 1d                	je     80216b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80214e:	c1 ea 0c             	shr    $0xc,%edx
  802151:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802158:	f6 c2 01             	test   $0x1,%dl
  80215b:	74 0e                	je     80216b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80215d:	c1 ea 0c             	shr    $0xc,%edx
  802160:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802167:	ef 
  802168:	0f b7 c0             	movzwl %ax,%eax
}
  80216b:	5d                   	pop    %ebp
  80216c:	c3                   	ret    
  80216d:	66 90                	xchg   %ax,%ax
  80216f:	90                   	nop

00802170 <__udivdi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	83 ec 1c             	sub    $0x1c,%esp
  802177:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80217b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80217f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802187:	85 f6                	test   %esi,%esi
  802189:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80218d:	89 ca                	mov    %ecx,%edx
  80218f:	89 f8                	mov    %edi,%eax
  802191:	75 3d                	jne    8021d0 <__udivdi3+0x60>
  802193:	39 cf                	cmp    %ecx,%edi
  802195:	0f 87 c5 00 00 00    	ja     802260 <__udivdi3+0xf0>
  80219b:	85 ff                	test   %edi,%edi
  80219d:	89 fd                	mov    %edi,%ebp
  80219f:	75 0b                	jne    8021ac <__udivdi3+0x3c>
  8021a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a6:	31 d2                	xor    %edx,%edx
  8021a8:	f7 f7                	div    %edi
  8021aa:	89 c5                	mov    %eax,%ebp
  8021ac:	89 c8                	mov    %ecx,%eax
  8021ae:	31 d2                	xor    %edx,%edx
  8021b0:	f7 f5                	div    %ebp
  8021b2:	89 c1                	mov    %eax,%ecx
  8021b4:	89 d8                	mov    %ebx,%eax
  8021b6:	89 cf                	mov    %ecx,%edi
  8021b8:	f7 f5                	div    %ebp
  8021ba:	89 c3                	mov    %eax,%ebx
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
  8021d0:	39 ce                	cmp    %ecx,%esi
  8021d2:	77 74                	ja     802248 <__udivdi3+0xd8>
  8021d4:	0f bd fe             	bsr    %esi,%edi
  8021d7:	83 f7 1f             	xor    $0x1f,%edi
  8021da:	0f 84 98 00 00 00    	je     802278 <__udivdi3+0x108>
  8021e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021e5:	89 f9                	mov    %edi,%ecx
  8021e7:	89 c5                	mov    %eax,%ebp
  8021e9:	29 fb                	sub    %edi,%ebx
  8021eb:	d3 e6                	shl    %cl,%esi
  8021ed:	89 d9                	mov    %ebx,%ecx
  8021ef:	d3 ed                	shr    %cl,%ebp
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	d3 e0                	shl    %cl,%eax
  8021f5:	09 ee                	or     %ebp,%esi
  8021f7:	89 d9                	mov    %ebx,%ecx
  8021f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021fd:	89 d5                	mov    %edx,%ebp
  8021ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802203:	d3 ed                	shr    %cl,%ebp
  802205:	89 f9                	mov    %edi,%ecx
  802207:	d3 e2                	shl    %cl,%edx
  802209:	89 d9                	mov    %ebx,%ecx
  80220b:	d3 e8                	shr    %cl,%eax
  80220d:	09 c2                	or     %eax,%edx
  80220f:	89 d0                	mov    %edx,%eax
  802211:	89 ea                	mov    %ebp,%edx
  802213:	f7 f6                	div    %esi
  802215:	89 d5                	mov    %edx,%ebp
  802217:	89 c3                	mov    %eax,%ebx
  802219:	f7 64 24 0c          	mull   0xc(%esp)
  80221d:	39 d5                	cmp    %edx,%ebp
  80221f:	72 10                	jb     802231 <__udivdi3+0xc1>
  802221:	8b 74 24 08          	mov    0x8(%esp),%esi
  802225:	89 f9                	mov    %edi,%ecx
  802227:	d3 e6                	shl    %cl,%esi
  802229:	39 c6                	cmp    %eax,%esi
  80222b:	73 07                	jae    802234 <__udivdi3+0xc4>
  80222d:	39 d5                	cmp    %edx,%ebp
  80222f:	75 03                	jne    802234 <__udivdi3+0xc4>
  802231:	83 eb 01             	sub    $0x1,%ebx
  802234:	31 ff                	xor    %edi,%edi
  802236:	89 d8                	mov    %ebx,%eax
  802238:	89 fa                	mov    %edi,%edx
  80223a:	83 c4 1c             	add    $0x1c,%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5f                   	pop    %edi
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    
  802242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802248:	31 ff                	xor    %edi,%edi
  80224a:	31 db                	xor    %ebx,%ebx
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
  802260:	89 d8                	mov    %ebx,%eax
  802262:	f7 f7                	div    %edi
  802264:	31 ff                	xor    %edi,%edi
  802266:	89 c3                	mov    %eax,%ebx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 fa                	mov    %edi,%edx
  80226c:	83 c4 1c             	add    $0x1c,%esp
  80226f:	5b                   	pop    %ebx
  802270:	5e                   	pop    %esi
  802271:	5f                   	pop    %edi
  802272:	5d                   	pop    %ebp
  802273:	c3                   	ret    
  802274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802278:	39 ce                	cmp    %ecx,%esi
  80227a:	72 0c                	jb     802288 <__udivdi3+0x118>
  80227c:	31 db                	xor    %ebx,%ebx
  80227e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802282:	0f 87 34 ff ff ff    	ja     8021bc <__udivdi3+0x4c>
  802288:	bb 01 00 00 00       	mov    $0x1,%ebx
  80228d:	e9 2a ff ff ff       	jmp    8021bc <__udivdi3+0x4c>
  802292:	66 90                	xchg   %ax,%ax
  802294:	66 90                	xchg   %ax,%ax
  802296:	66 90                	xchg   %ax,%ax
  802298:	66 90                	xchg   %ax,%ax
  80229a:	66 90                	xchg   %ax,%ax
  80229c:	66 90                	xchg   %ax,%ax
  80229e:	66 90                	xchg   %ax,%ax

008022a0 <__umoddi3>:
  8022a0:	55                   	push   %ebp
  8022a1:	57                   	push   %edi
  8022a2:	56                   	push   %esi
  8022a3:	53                   	push   %ebx
  8022a4:	83 ec 1c             	sub    $0x1c,%esp
  8022a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022b7:	85 d2                	test   %edx,%edx
  8022b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022c1:	89 f3                	mov    %esi,%ebx
  8022c3:	89 3c 24             	mov    %edi,(%esp)
  8022c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ca:	75 1c                	jne    8022e8 <__umoddi3+0x48>
  8022cc:	39 f7                	cmp    %esi,%edi
  8022ce:	76 50                	jbe    802320 <__umoddi3+0x80>
  8022d0:	89 c8                	mov    %ecx,%eax
  8022d2:	89 f2                	mov    %esi,%edx
  8022d4:	f7 f7                	div    %edi
  8022d6:	89 d0                	mov    %edx,%eax
  8022d8:	31 d2                	xor    %edx,%edx
  8022da:	83 c4 1c             	add    $0x1c,%esp
  8022dd:	5b                   	pop    %ebx
  8022de:	5e                   	pop    %esi
  8022df:	5f                   	pop    %edi
  8022e0:	5d                   	pop    %ebp
  8022e1:	c3                   	ret    
  8022e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e8:	39 f2                	cmp    %esi,%edx
  8022ea:	89 d0                	mov    %edx,%eax
  8022ec:	77 52                	ja     802340 <__umoddi3+0xa0>
  8022ee:	0f bd ea             	bsr    %edx,%ebp
  8022f1:	83 f5 1f             	xor    $0x1f,%ebp
  8022f4:	75 5a                	jne    802350 <__umoddi3+0xb0>
  8022f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022fa:	0f 82 e0 00 00 00    	jb     8023e0 <__umoddi3+0x140>
  802300:	39 0c 24             	cmp    %ecx,(%esp)
  802303:	0f 86 d7 00 00 00    	jbe    8023e0 <__umoddi3+0x140>
  802309:	8b 44 24 08          	mov    0x8(%esp),%eax
  80230d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802311:	83 c4 1c             	add    $0x1c,%esp
  802314:	5b                   	pop    %ebx
  802315:	5e                   	pop    %esi
  802316:	5f                   	pop    %edi
  802317:	5d                   	pop    %ebp
  802318:	c3                   	ret    
  802319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802320:	85 ff                	test   %edi,%edi
  802322:	89 fd                	mov    %edi,%ebp
  802324:	75 0b                	jne    802331 <__umoddi3+0x91>
  802326:	b8 01 00 00 00       	mov    $0x1,%eax
  80232b:	31 d2                	xor    %edx,%edx
  80232d:	f7 f7                	div    %edi
  80232f:	89 c5                	mov    %eax,%ebp
  802331:	89 f0                	mov    %esi,%eax
  802333:	31 d2                	xor    %edx,%edx
  802335:	f7 f5                	div    %ebp
  802337:	89 c8                	mov    %ecx,%eax
  802339:	f7 f5                	div    %ebp
  80233b:	89 d0                	mov    %edx,%eax
  80233d:	eb 99                	jmp    8022d8 <__umoddi3+0x38>
  80233f:	90                   	nop
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	83 c4 1c             	add    $0x1c,%esp
  802347:	5b                   	pop    %ebx
  802348:	5e                   	pop    %esi
  802349:	5f                   	pop    %edi
  80234a:	5d                   	pop    %ebp
  80234b:	c3                   	ret    
  80234c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802350:	8b 34 24             	mov    (%esp),%esi
  802353:	bf 20 00 00 00       	mov    $0x20,%edi
  802358:	89 e9                	mov    %ebp,%ecx
  80235a:	29 ef                	sub    %ebp,%edi
  80235c:	d3 e0                	shl    %cl,%eax
  80235e:	89 f9                	mov    %edi,%ecx
  802360:	89 f2                	mov    %esi,%edx
  802362:	d3 ea                	shr    %cl,%edx
  802364:	89 e9                	mov    %ebp,%ecx
  802366:	09 c2                	or     %eax,%edx
  802368:	89 d8                	mov    %ebx,%eax
  80236a:	89 14 24             	mov    %edx,(%esp)
  80236d:	89 f2                	mov    %esi,%edx
  80236f:	d3 e2                	shl    %cl,%edx
  802371:	89 f9                	mov    %edi,%ecx
  802373:	89 54 24 04          	mov    %edx,0x4(%esp)
  802377:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80237b:	d3 e8                	shr    %cl,%eax
  80237d:	89 e9                	mov    %ebp,%ecx
  80237f:	89 c6                	mov    %eax,%esi
  802381:	d3 e3                	shl    %cl,%ebx
  802383:	89 f9                	mov    %edi,%ecx
  802385:	89 d0                	mov    %edx,%eax
  802387:	d3 e8                	shr    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	09 d8                	or     %ebx,%eax
  80238d:	89 d3                	mov    %edx,%ebx
  80238f:	89 f2                	mov    %esi,%edx
  802391:	f7 34 24             	divl   (%esp)
  802394:	89 d6                	mov    %edx,%esi
  802396:	d3 e3                	shl    %cl,%ebx
  802398:	f7 64 24 04          	mull   0x4(%esp)
  80239c:	39 d6                	cmp    %edx,%esi
  80239e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023a2:	89 d1                	mov    %edx,%ecx
  8023a4:	89 c3                	mov    %eax,%ebx
  8023a6:	72 08                	jb     8023b0 <__umoddi3+0x110>
  8023a8:	75 11                	jne    8023bb <__umoddi3+0x11b>
  8023aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023ae:	73 0b                	jae    8023bb <__umoddi3+0x11b>
  8023b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023b4:	1b 14 24             	sbb    (%esp),%edx
  8023b7:	89 d1                	mov    %edx,%ecx
  8023b9:	89 c3                	mov    %eax,%ebx
  8023bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023bf:	29 da                	sub    %ebx,%edx
  8023c1:	19 ce                	sbb    %ecx,%esi
  8023c3:	89 f9                	mov    %edi,%ecx
  8023c5:	89 f0                	mov    %esi,%eax
  8023c7:	d3 e0                	shl    %cl,%eax
  8023c9:	89 e9                	mov    %ebp,%ecx
  8023cb:	d3 ea                	shr    %cl,%edx
  8023cd:	89 e9                	mov    %ebp,%ecx
  8023cf:	d3 ee                	shr    %cl,%esi
  8023d1:	09 d0                	or     %edx,%eax
  8023d3:	89 f2                	mov    %esi,%edx
  8023d5:	83 c4 1c             	add    $0x1c,%esp
  8023d8:	5b                   	pop    %ebx
  8023d9:	5e                   	pop    %esi
  8023da:	5f                   	pop    %edi
  8023db:	5d                   	pop    %ebp
  8023dc:	c3                   	ret    
  8023dd:	8d 76 00             	lea    0x0(%esi),%esi
  8023e0:	29 f9                	sub    %edi,%ecx
  8023e2:	19 d6                	sbb    %edx,%esi
  8023e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023ec:	e9 18 ff ff ff       	jmp    802309 <__umoddi3+0x69>
