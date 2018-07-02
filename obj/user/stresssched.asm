
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 59 0c 00 00       	call   800c96 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 52 0f 00 00       	call   800f9b <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 54 0c 00 00       	call   800cb5 <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 2b 0c 00 00       	call   800cb5 <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 08 40 80 00       	mov    0x804008,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 08 40 80 00       	mov    %eax,0x804008
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 60 23 80 00       	push   $0x802360
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 88 23 80 00       	push   $0x802388
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 9b 23 80 00       	push   $0x80239b
  8000de:	e8 43 01 00 00       	call   800226 <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f8:	e8 99 0b 00 00       	call   800c96 <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 0c 40 80 00       	mov    %eax,0x80400c
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800124:	e8 0a 00 00 00       	call   800133 <exit>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800139:	e8 5a 12 00 00       	call   801398 <close_all>
	sys_env_destroy(0);
  80013e:	83 ec 0c             	sub    $0xc,%esp
  800141:	6a 00                	push   $0x0
  800143:	e8 0d 0b 00 00       	call   800c55 <sys_env_destroy>
}
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800152:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800155:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80015b:	e8 36 0b 00 00       	call   800c96 <sys_getenvid>
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 75 0c             	pushl  0xc(%ebp)
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	56                   	push   %esi
  80016a:	50                   	push   %eax
  80016b:	68 c4 23 80 00       	push   $0x8023c4
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 b7 23 80 00 	movl   $0x8023b7,(%esp)
  800188:	e8 99 00 00 00       	call   800226 <cprintf>
  80018d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800190:	cc                   	int3   
  800191:	eb fd                	jmp    800190 <_panic+0x43>

00800193 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	53                   	push   %ebx
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019d:	8b 13                	mov    (%ebx),%edx
  80019f:	8d 42 01             	lea    0x1(%edx),%eax
  8001a2:	89 03                	mov    %eax,(%ebx)
  8001a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b0:	75 1a                	jne    8001cc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	68 ff 00 00 00       	push   $0xff
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 55 0a 00 00       	call   800c18 <sys_cputs>
		b->idx = 0;
  8001c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	ff 75 08             	pushl  0x8(%ebp)
  8001f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	68 93 01 80 00       	push   $0x800193
  800204:	e8 54 01 00 00       	call   80035d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800209:	83 c4 08             	add    $0x8,%esp
  80020c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800212:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800218:	50                   	push   %eax
  800219:	e8 fa 09 00 00       	call   800c18 <sys_cputs>

	return b.cnt;
}
  80021e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022f:	50                   	push   %eax
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	e8 9d ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 1c             	sub    $0x1c,%esp
  800243:	89 c7                	mov    %eax,%edi
  800245:	89 d6                	mov    %edx,%esi
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800250:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800261:	39 d3                	cmp    %edx,%ebx
  800263:	72 05                	jb     80026a <printnum+0x30>
  800265:	39 45 10             	cmp    %eax,0x10(%ebp)
  800268:	77 45                	ja     8002af <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	8b 45 14             	mov    0x14(%ebp),%eax
  800273:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800276:	53                   	push   %ebx
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800280:	ff 75 e0             	pushl  -0x20(%ebp)
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	ff 75 d8             	pushl  -0x28(%ebp)
  800289:	e8 42 1e 00 00       	call   8020d0 <__udivdi3>
  80028e:	83 c4 18             	add    $0x18,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	89 f2                	mov    %esi,%edx
  800295:	89 f8                	mov    %edi,%eax
  800297:	e8 9e ff ff ff       	call   80023a <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 18                	jmp    8002b9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	ff 75 18             	pushl  0x18(%ebp)
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	eb 03                	jmp    8002b2 <printnum+0x78>
  8002af:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 eb 01             	sub    $0x1,%ebx
  8002b5:	85 db                	test   %ebx,%ebx
  8002b7:	7f e8                	jg     8002a1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	83 ec 04             	sub    $0x4,%esp
  8002c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cc:	e8 2f 1f 00 00       	call   802200 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 e7 23 80 00 	movsbl 0x8023e7(%eax),%eax
  8002db:	50                   	push   %eax
  8002dc:	ff d7                	call   *%edi
}
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5e                   	pop    %esi
  8002e6:	5f                   	pop    %edi
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ec:	83 fa 01             	cmp    $0x1,%edx
  8002ef:	7e 0e                	jle    8002ff <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f6:	89 08                	mov    %ecx,(%eax)
  8002f8:	8b 02                	mov    (%edx),%eax
  8002fa:	8b 52 04             	mov    0x4(%edx),%edx
  8002fd:	eb 22                	jmp    800321 <getuint+0x38>
	else if (lflag)
  8002ff:	85 d2                	test   %edx,%edx
  800301:	74 10                	je     800313 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800303:	8b 10                	mov    (%eax),%edx
  800305:	8d 4a 04             	lea    0x4(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 02                	mov    (%edx),%eax
  80030c:	ba 00 00 00 00       	mov    $0x0,%edx
  800311:	eb 0e                	jmp    800321 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800313:	8b 10                	mov    (%eax),%edx
  800315:	8d 4a 04             	lea    0x4(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 02                	mov    (%edx),%eax
  80031c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800329:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	3b 50 04             	cmp    0x4(%eax),%edx
  800332:	73 0a                	jae    80033e <sprintputch+0x1b>
		*b->buf++ = ch;
  800334:	8d 4a 01             	lea    0x1(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 45 08             	mov    0x8(%ebp),%eax
  80033c:	88 02                	mov    %al,(%edx)
}
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    

00800340 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800346:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800349:	50                   	push   %eax
  80034a:	ff 75 10             	pushl  0x10(%ebp)
  80034d:	ff 75 0c             	pushl  0xc(%ebp)
  800350:	ff 75 08             	pushl  0x8(%ebp)
  800353:	e8 05 00 00 00       	call   80035d <vprintfmt>
	va_end(ap);
}
  800358:	83 c4 10             	add    $0x10,%esp
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	57                   	push   %edi
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 2c             	sub    $0x2c,%esp
  800366:	8b 75 08             	mov    0x8(%ebp),%esi
  800369:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036f:	eb 12                	jmp    800383 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800371:	85 c0                	test   %eax,%eax
  800373:	0f 84 38 04 00 00    	je     8007b1 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	53                   	push   %ebx
  80037d:	50                   	push   %eax
  80037e:	ff d6                	call   *%esi
  800380:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800383:	83 c7 01             	add    $0x1,%edi
  800386:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80038a:	83 f8 25             	cmp    $0x25,%eax
  80038d:	75 e2                	jne    800371 <vprintfmt+0x14>
  80038f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800393:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ad:	eb 07                	jmp    8003b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8d 47 01             	lea    0x1(%edi),%eax
  8003b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bc:	0f b6 07             	movzbl (%edi),%eax
  8003bf:	0f b6 c8             	movzbl %al,%ecx
  8003c2:	83 e8 23             	sub    $0x23,%eax
  8003c5:	3c 55                	cmp    $0x55,%al
  8003c7:	0f 87 c9 03 00 00    	ja     800796 <vprintfmt+0x439>
  8003cd:	0f b6 c0             	movzbl %al,%eax
  8003d0:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003da:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003de:	eb d6                	jmp    8003b6 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  8003e0:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  8003e7:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  8003ed:	eb 94                	jmp    800383 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  8003ef:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  8003f6:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  8003fc:	eb 85                	jmp    800383 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  8003fe:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  800405:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  80040b:	e9 73 ff ff ff       	jmp    800383 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  800410:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  800417:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  80041d:	e9 61 ff ff ff       	jmp    800383 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  800422:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800429:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  80042f:	e9 4f ff ff ff       	jmp    800383 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  800434:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  80043b:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  800441:	e9 3d ff ff ff       	jmp    800383 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  800446:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  80044d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  800453:	e9 2b ff ff ff       	jmp    800383 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  800458:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  80045f:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800462:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  800465:	e9 19 ff ff ff       	jmp    800383 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  80046a:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  800471:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  800477:	e9 07 ff ff ff       	jmp    800383 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  80047c:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  800483:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800489:	e9 f5 fe ff ff       	jmp    800383 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800491:	b8 00 00 00 00       	mov    $0x0,%eax
  800496:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800499:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80049c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004a0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004a3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004a6:	83 fa 09             	cmp    $0x9,%edx
  8004a9:	77 3f                	ja     8004ea <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ab:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004ae:	eb e9                	jmp    800499 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8d 48 04             	lea    0x4(%eax),%ecx
  8004b6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004b9:	8b 00                	mov    (%eax),%eax
  8004bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004c1:	eb 2d                	jmp    8004f0 <vprintfmt+0x193>
  8004c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004cd:	0f 49 c8             	cmovns %eax,%ecx
  8004d0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d6:	e9 db fe ff ff       	jmp    8003b6 <vprintfmt+0x59>
  8004db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004de:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004e5:	e9 cc fe ff ff       	jmp    8003b6 <vprintfmt+0x59>
  8004ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004ed:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f4:	0f 89 bc fe ff ff    	jns    8003b6 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800500:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800507:	e9 aa fe ff ff       	jmp    8003b6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80050c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800512:	e9 9f fe ff ff       	jmp    8003b6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 50 04             	lea    0x4(%eax),%edx
  80051d:	89 55 14             	mov    %edx,0x14(%ebp)
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	53                   	push   %ebx
  800524:	ff 30                	pushl  (%eax)
  800526:	ff d6                	call   *%esi
			break;
  800528:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80052e:	e9 50 fe ff ff       	jmp    800383 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 04             	lea    0x4(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 00                	mov    (%eax),%eax
  80053e:	99                   	cltd   
  80053f:	31 d0                	xor    %edx,%eax
  800541:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800543:	83 f8 0f             	cmp    $0xf,%eax
  800546:	7f 0b                	jg     800553 <vprintfmt+0x1f6>
  800548:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  80054f:	85 d2                	test   %edx,%edx
  800551:	75 18                	jne    80056b <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  800553:	50                   	push   %eax
  800554:	68 ff 23 80 00       	push   $0x8023ff
  800559:	53                   	push   %ebx
  80055a:	56                   	push   %esi
  80055b:	e8 e0 fd ff ff       	call   800340 <printfmt>
  800560:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800563:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800566:	e9 18 fe ff ff       	jmp    800383 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80056b:	52                   	push   %edx
  80056c:	68 65 28 80 00       	push   $0x802865
  800571:	53                   	push   %ebx
  800572:	56                   	push   %esi
  800573:	e8 c8 fd ff ff       	call   800340 <printfmt>
  800578:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057e:	e9 00 fe ff ff       	jmp    800383 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 50 04             	lea    0x4(%eax),%edx
  800589:	89 55 14             	mov    %edx,0x14(%ebp)
  80058c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80058e:	85 ff                	test   %edi,%edi
  800590:	b8 f8 23 80 00       	mov    $0x8023f8,%eax
  800595:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800598:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80059c:	0f 8e 94 00 00 00    	jle    800636 <vprintfmt+0x2d9>
  8005a2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005a6:	0f 84 98 00 00 00    	je     800644 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	ff 75 d0             	pushl  -0x30(%ebp)
  8005b2:	57                   	push   %edi
  8005b3:	e8 81 02 00 00       	call   800839 <strnlen>
  8005b8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005bb:	29 c1                	sub    %eax,%ecx
  8005bd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005c0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005c3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ca:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005cd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cf:	eb 0f                	jmp    8005e0 <vprintfmt+0x283>
					putch(padc, putdat);
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8005d8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005da:	83 ef 01             	sub    $0x1,%edi
  8005dd:	83 c4 10             	add    $0x10,%esp
  8005e0:	85 ff                	test   %edi,%edi
  8005e2:	7f ed                	jg     8005d1 <vprintfmt+0x274>
  8005e4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005e7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005ea:	85 c9                	test   %ecx,%ecx
  8005ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f1:	0f 49 c1             	cmovns %ecx,%eax
  8005f4:	29 c1                	sub    %eax,%ecx
  8005f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ff:	89 cb                	mov    %ecx,%ebx
  800601:	eb 4d                	jmp    800650 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800603:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800607:	74 1b                	je     800624 <vprintfmt+0x2c7>
  800609:	0f be c0             	movsbl %al,%eax
  80060c:	83 e8 20             	sub    $0x20,%eax
  80060f:	83 f8 5e             	cmp    $0x5e,%eax
  800612:	76 10                	jbe    800624 <vprintfmt+0x2c7>
					putch('?', putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	ff 75 0c             	pushl  0xc(%ebp)
  80061a:	6a 3f                	push   $0x3f
  80061c:	ff 55 08             	call   *0x8(%ebp)
  80061f:	83 c4 10             	add    $0x10,%esp
  800622:	eb 0d                	jmp    800631 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	ff 75 0c             	pushl  0xc(%ebp)
  80062a:	52                   	push   %edx
  80062b:	ff 55 08             	call   *0x8(%ebp)
  80062e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800631:	83 eb 01             	sub    $0x1,%ebx
  800634:	eb 1a                	jmp    800650 <vprintfmt+0x2f3>
  800636:	89 75 08             	mov    %esi,0x8(%ebp)
  800639:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80063c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80063f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800642:	eb 0c                	jmp    800650 <vprintfmt+0x2f3>
  800644:	89 75 08             	mov    %esi,0x8(%ebp)
  800647:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80064a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80064d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800650:	83 c7 01             	add    $0x1,%edi
  800653:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800657:	0f be d0             	movsbl %al,%edx
  80065a:	85 d2                	test   %edx,%edx
  80065c:	74 23                	je     800681 <vprintfmt+0x324>
  80065e:	85 f6                	test   %esi,%esi
  800660:	78 a1                	js     800603 <vprintfmt+0x2a6>
  800662:	83 ee 01             	sub    $0x1,%esi
  800665:	79 9c                	jns    800603 <vprintfmt+0x2a6>
  800667:	89 df                	mov    %ebx,%edi
  800669:	8b 75 08             	mov    0x8(%ebp),%esi
  80066c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80066f:	eb 18                	jmp    800689 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	53                   	push   %ebx
  800675:	6a 20                	push   $0x20
  800677:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800679:	83 ef 01             	sub    $0x1,%edi
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	eb 08                	jmp    800689 <vprintfmt+0x32c>
  800681:	89 df                	mov    %ebx,%edi
  800683:	8b 75 08             	mov    0x8(%ebp),%esi
  800686:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800689:	85 ff                	test   %edi,%edi
  80068b:	7f e4                	jg     800671 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800690:	e9 ee fc ff ff       	jmp    800383 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800695:	83 fa 01             	cmp    $0x1,%edx
  800698:	7e 16                	jle    8006b0 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8d 50 08             	lea    0x8(%eax),%edx
  8006a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a3:	8b 50 04             	mov    0x4(%eax),%edx
  8006a6:	8b 00                	mov    (%eax),%eax
  8006a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ae:	eb 32                	jmp    8006e2 <vprintfmt+0x385>
	else if (lflag)
  8006b0:	85 d2                	test   %edx,%edx
  8006b2:	74 18                	je     8006cc <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c2:	89 c1                	mov    %eax,%ecx
  8006c4:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ca:	eb 16                	jmp    8006e2 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8d 50 04             	lea    0x4(%eax),%edx
  8006d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d5:	8b 00                	mov    (%eax),%eax
  8006d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006da:	89 c1                	mov    %eax,%ecx
  8006dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006e5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e8:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006ed:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006f1:	79 6f                	jns    800762 <vprintfmt+0x405>
				putch('-', putdat);
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	53                   	push   %ebx
  8006f7:	6a 2d                	push   $0x2d
  8006f9:	ff d6                	call   *%esi
				num = -(long long) num;
  8006fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800701:	f7 d8                	neg    %eax
  800703:	83 d2 00             	adc    $0x0,%edx
  800706:	f7 da                	neg    %edx
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	eb 55                	jmp    800762 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80070d:	8d 45 14             	lea    0x14(%ebp),%eax
  800710:	e8 d4 fb ff ff       	call   8002e9 <getuint>
			base = 10;
  800715:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80071a:	eb 46                	jmp    800762 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80071c:	8d 45 14             	lea    0x14(%ebp),%eax
  80071f:	e8 c5 fb ff ff       	call   8002e9 <getuint>
			base = 8;
  800724:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800729:	eb 37                	jmp    800762 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  80072b:	83 ec 08             	sub    $0x8,%esp
  80072e:	53                   	push   %ebx
  80072f:	6a 30                	push   $0x30
  800731:	ff d6                	call   *%esi
			putch('x', putdat);
  800733:	83 c4 08             	add    $0x8,%esp
  800736:	53                   	push   %ebx
  800737:	6a 78                	push   $0x78
  800739:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80073b:	8b 45 14             	mov    0x14(%ebp),%eax
  80073e:	8d 50 04             	lea    0x4(%eax),%edx
  800741:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800744:	8b 00                	mov    (%eax),%eax
  800746:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80074b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80074e:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800753:	eb 0d                	jmp    800762 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800755:	8d 45 14             	lea    0x14(%ebp),%eax
  800758:	e8 8c fb ff ff       	call   8002e9 <getuint>
			base = 16;
  80075d:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800762:	83 ec 0c             	sub    $0xc,%esp
  800765:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800769:	51                   	push   %ecx
  80076a:	ff 75 e0             	pushl  -0x20(%ebp)
  80076d:	57                   	push   %edi
  80076e:	52                   	push   %edx
  80076f:	50                   	push   %eax
  800770:	89 da                	mov    %ebx,%edx
  800772:	89 f0                	mov    %esi,%eax
  800774:	e8 c1 fa ff ff       	call   80023a <printnum>
			break;
  800779:	83 c4 20             	add    $0x20,%esp
  80077c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077f:	e9 ff fb ff ff       	jmp    800383 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	53                   	push   %ebx
  800788:	51                   	push   %ecx
  800789:	ff d6                	call   *%esi
			break;
  80078b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800791:	e9 ed fb ff ff       	jmp    800383 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800796:	83 ec 08             	sub    $0x8,%esp
  800799:	53                   	push   %ebx
  80079a:	6a 25                	push   $0x25
  80079c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80079e:	83 c4 10             	add    $0x10,%esp
  8007a1:	eb 03                	jmp    8007a6 <vprintfmt+0x449>
  8007a3:	83 ef 01             	sub    $0x1,%edi
  8007a6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007aa:	75 f7                	jne    8007a3 <vprintfmt+0x446>
  8007ac:	e9 d2 fb ff ff       	jmp    800383 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007b4:	5b                   	pop    %ebx
  8007b5:	5e                   	pop    %esi
  8007b6:	5f                   	pop    %edi
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    

008007b9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	83 ec 18             	sub    $0x18,%esp
  8007bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007cc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d6:	85 c0                	test   %eax,%eax
  8007d8:	74 26                	je     800800 <vsnprintf+0x47>
  8007da:	85 d2                	test   %edx,%edx
  8007dc:	7e 22                	jle    800800 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007de:	ff 75 14             	pushl  0x14(%ebp)
  8007e1:	ff 75 10             	pushl  0x10(%ebp)
  8007e4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e7:	50                   	push   %eax
  8007e8:	68 23 03 80 00       	push   $0x800323
  8007ed:	e8 6b fb ff ff       	call   80035d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007fb:	83 c4 10             	add    $0x10,%esp
  8007fe:	eb 05                	jmp    800805 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800800:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800805:	c9                   	leave  
  800806:	c3                   	ret    

00800807 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80080d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800810:	50                   	push   %eax
  800811:	ff 75 10             	pushl  0x10(%ebp)
  800814:	ff 75 0c             	pushl  0xc(%ebp)
  800817:	ff 75 08             	pushl  0x8(%ebp)
  80081a:	e8 9a ff ff ff       	call   8007b9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80081f:	c9                   	leave  
  800820:	c3                   	ret    

00800821 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800827:	b8 00 00 00 00       	mov    $0x0,%eax
  80082c:	eb 03                	jmp    800831 <strlen+0x10>
		n++;
  80082e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800831:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800835:	75 f7                	jne    80082e <strlen+0xd>
		n++;
	return n;
}
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800842:	ba 00 00 00 00       	mov    $0x0,%edx
  800847:	eb 03                	jmp    80084c <strnlen+0x13>
		n++;
  800849:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084c:	39 c2                	cmp    %eax,%edx
  80084e:	74 08                	je     800858 <strnlen+0x1f>
  800850:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800854:	75 f3                	jne    800849 <strnlen+0x10>
  800856:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	53                   	push   %ebx
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800864:	89 c2                	mov    %eax,%edx
  800866:	83 c2 01             	add    $0x1,%edx
  800869:	83 c1 01             	add    $0x1,%ecx
  80086c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800870:	88 5a ff             	mov    %bl,-0x1(%edx)
  800873:	84 db                	test   %bl,%bl
  800875:	75 ef                	jne    800866 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800877:	5b                   	pop    %ebx
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	53                   	push   %ebx
  80087e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800881:	53                   	push   %ebx
  800882:	e8 9a ff ff ff       	call   800821 <strlen>
  800887:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80088a:	ff 75 0c             	pushl  0xc(%ebp)
  80088d:	01 d8                	add    %ebx,%eax
  80088f:	50                   	push   %eax
  800890:	e8 c5 ff ff ff       	call   80085a <strcpy>
	return dst;
}
  800895:	89 d8                	mov    %ebx,%eax
  800897:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089a:	c9                   	leave  
  80089b:	c3                   	ret    

0080089c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	56                   	push   %esi
  8008a0:	53                   	push   %ebx
  8008a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a7:	89 f3                	mov    %esi,%ebx
  8008a9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ac:	89 f2                	mov    %esi,%edx
  8008ae:	eb 0f                	jmp    8008bf <strncpy+0x23>
		*dst++ = *src;
  8008b0:	83 c2 01             	add    $0x1,%edx
  8008b3:	0f b6 01             	movzbl (%ecx),%eax
  8008b6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b9:	80 39 01             	cmpb   $0x1,(%ecx)
  8008bc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008bf:	39 da                	cmp    %ebx,%edx
  8008c1:	75 ed                	jne    8008b0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008c3:	89 f0                	mov    %esi,%eax
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
  8008ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d4:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d9:	85 d2                	test   %edx,%edx
  8008db:	74 21                	je     8008fe <strlcpy+0x35>
  8008dd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008e1:	89 f2                	mov    %esi,%edx
  8008e3:	eb 09                	jmp    8008ee <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008e5:	83 c2 01             	add    $0x1,%edx
  8008e8:	83 c1 01             	add    $0x1,%ecx
  8008eb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ee:	39 c2                	cmp    %eax,%edx
  8008f0:	74 09                	je     8008fb <strlcpy+0x32>
  8008f2:	0f b6 19             	movzbl (%ecx),%ebx
  8008f5:	84 db                	test   %bl,%bl
  8008f7:	75 ec                	jne    8008e5 <strlcpy+0x1c>
  8008f9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008fb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008fe:	29 f0                	sub    %esi,%eax
}
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80090d:	eb 06                	jmp    800915 <strcmp+0x11>
		p++, q++;
  80090f:	83 c1 01             	add    $0x1,%ecx
  800912:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800915:	0f b6 01             	movzbl (%ecx),%eax
  800918:	84 c0                	test   %al,%al
  80091a:	74 04                	je     800920 <strcmp+0x1c>
  80091c:	3a 02                	cmp    (%edx),%al
  80091e:	74 ef                	je     80090f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800920:	0f b6 c0             	movzbl %al,%eax
  800923:	0f b6 12             	movzbl (%edx),%edx
  800926:	29 d0                	sub    %edx,%eax
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	53                   	push   %ebx
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 55 0c             	mov    0xc(%ebp),%edx
  800934:	89 c3                	mov    %eax,%ebx
  800936:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800939:	eb 06                	jmp    800941 <strncmp+0x17>
		n--, p++, q++;
  80093b:	83 c0 01             	add    $0x1,%eax
  80093e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800941:	39 d8                	cmp    %ebx,%eax
  800943:	74 15                	je     80095a <strncmp+0x30>
  800945:	0f b6 08             	movzbl (%eax),%ecx
  800948:	84 c9                	test   %cl,%cl
  80094a:	74 04                	je     800950 <strncmp+0x26>
  80094c:	3a 0a                	cmp    (%edx),%cl
  80094e:	74 eb                	je     80093b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800950:	0f b6 00             	movzbl (%eax),%eax
  800953:	0f b6 12             	movzbl (%edx),%edx
  800956:	29 d0                	sub    %edx,%eax
  800958:	eb 05                	jmp    80095f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80095a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80095f:	5b                   	pop    %ebx
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096c:	eb 07                	jmp    800975 <strchr+0x13>
		if (*s == c)
  80096e:	38 ca                	cmp    %cl,%dl
  800970:	74 0f                	je     800981 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800972:	83 c0 01             	add    $0x1,%eax
  800975:	0f b6 10             	movzbl (%eax),%edx
  800978:	84 d2                	test   %dl,%dl
  80097a:	75 f2                	jne    80096e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80097c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098d:	eb 03                	jmp    800992 <strfind+0xf>
  80098f:	83 c0 01             	add    $0x1,%eax
  800992:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800995:	38 ca                	cmp    %cl,%dl
  800997:	74 04                	je     80099d <strfind+0x1a>
  800999:	84 d2                	test   %dl,%dl
  80099b:	75 f2                	jne    80098f <strfind+0xc>
			break;
	return (char *) s;
}
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	57                   	push   %edi
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ab:	85 c9                	test   %ecx,%ecx
  8009ad:	74 36                	je     8009e5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009af:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b5:	75 28                	jne    8009df <memset+0x40>
  8009b7:	f6 c1 03             	test   $0x3,%cl
  8009ba:	75 23                	jne    8009df <memset+0x40>
		c &= 0xFF;
  8009bc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c0:	89 d3                	mov    %edx,%ebx
  8009c2:	c1 e3 08             	shl    $0x8,%ebx
  8009c5:	89 d6                	mov    %edx,%esi
  8009c7:	c1 e6 18             	shl    $0x18,%esi
  8009ca:	89 d0                	mov    %edx,%eax
  8009cc:	c1 e0 10             	shl    $0x10,%eax
  8009cf:	09 f0                	or     %esi,%eax
  8009d1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009d3:	89 d8                	mov    %ebx,%eax
  8009d5:	09 d0                	or     %edx,%eax
  8009d7:	c1 e9 02             	shr    $0x2,%ecx
  8009da:	fc                   	cld    
  8009db:	f3 ab                	rep stos %eax,%es:(%edi)
  8009dd:	eb 06                	jmp    8009e5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e2:	fc                   	cld    
  8009e3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e5:	89 f8                	mov    %edi,%eax
  8009e7:	5b                   	pop    %ebx
  8009e8:	5e                   	pop    %esi
  8009e9:	5f                   	pop    %edi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	57                   	push   %edi
  8009f0:	56                   	push   %esi
  8009f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009fa:	39 c6                	cmp    %eax,%esi
  8009fc:	73 35                	jae    800a33 <memmove+0x47>
  8009fe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a01:	39 d0                	cmp    %edx,%eax
  800a03:	73 2e                	jae    800a33 <memmove+0x47>
		s += n;
		d += n;
  800a05:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a08:	89 d6                	mov    %edx,%esi
  800a0a:	09 fe                	or     %edi,%esi
  800a0c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a12:	75 13                	jne    800a27 <memmove+0x3b>
  800a14:	f6 c1 03             	test   $0x3,%cl
  800a17:	75 0e                	jne    800a27 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a19:	83 ef 04             	sub    $0x4,%edi
  800a1c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1f:	c1 e9 02             	shr    $0x2,%ecx
  800a22:	fd                   	std    
  800a23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a25:	eb 09                	jmp    800a30 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a27:	83 ef 01             	sub    $0x1,%edi
  800a2a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a2d:	fd                   	std    
  800a2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a30:	fc                   	cld    
  800a31:	eb 1d                	jmp    800a50 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a33:	89 f2                	mov    %esi,%edx
  800a35:	09 c2                	or     %eax,%edx
  800a37:	f6 c2 03             	test   $0x3,%dl
  800a3a:	75 0f                	jne    800a4b <memmove+0x5f>
  800a3c:	f6 c1 03             	test   $0x3,%cl
  800a3f:	75 0a                	jne    800a4b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a41:	c1 e9 02             	shr    $0x2,%ecx
  800a44:	89 c7                	mov    %eax,%edi
  800a46:	fc                   	cld    
  800a47:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a49:	eb 05                	jmp    800a50 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a4b:	89 c7                	mov    %eax,%edi
  800a4d:	fc                   	cld    
  800a4e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a50:	5e                   	pop    %esi
  800a51:	5f                   	pop    %edi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a57:	ff 75 10             	pushl  0x10(%ebp)
  800a5a:	ff 75 0c             	pushl  0xc(%ebp)
  800a5d:	ff 75 08             	pushl  0x8(%ebp)
  800a60:	e8 87 ff ff ff       	call   8009ec <memmove>
}
  800a65:	c9                   	leave  
  800a66:	c3                   	ret    

00800a67 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a72:	89 c6                	mov    %eax,%esi
  800a74:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a77:	eb 1a                	jmp    800a93 <memcmp+0x2c>
		if (*s1 != *s2)
  800a79:	0f b6 08             	movzbl (%eax),%ecx
  800a7c:	0f b6 1a             	movzbl (%edx),%ebx
  800a7f:	38 d9                	cmp    %bl,%cl
  800a81:	74 0a                	je     800a8d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a83:	0f b6 c1             	movzbl %cl,%eax
  800a86:	0f b6 db             	movzbl %bl,%ebx
  800a89:	29 d8                	sub    %ebx,%eax
  800a8b:	eb 0f                	jmp    800a9c <memcmp+0x35>
		s1++, s2++;
  800a8d:	83 c0 01             	add    $0x1,%eax
  800a90:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a93:	39 f0                	cmp    %esi,%eax
  800a95:	75 e2                	jne    800a79 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	53                   	push   %ebx
  800aa4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aa7:	89 c1                	mov    %eax,%ecx
  800aa9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aac:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab0:	eb 0a                	jmp    800abc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab2:	0f b6 10             	movzbl (%eax),%edx
  800ab5:	39 da                	cmp    %ebx,%edx
  800ab7:	74 07                	je     800ac0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab9:	83 c0 01             	add    $0x1,%eax
  800abc:	39 c8                	cmp    %ecx,%eax
  800abe:	72 f2                	jb     800ab2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800acf:	eb 03                	jmp    800ad4 <strtol+0x11>
		s++;
  800ad1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad4:	0f b6 01             	movzbl (%ecx),%eax
  800ad7:	3c 20                	cmp    $0x20,%al
  800ad9:	74 f6                	je     800ad1 <strtol+0xe>
  800adb:	3c 09                	cmp    $0x9,%al
  800add:	74 f2                	je     800ad1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800adf:	3c 2b                	cmp    $0x2b,%al
  800ae1:	75 0a                	jne    800aed <strtol+0x2a>
		s++;
  800ae3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae6:	bf 00 00 00 00       	mov    $0x0,%edi
  800aeb:	eb 11                	jmp    800afe <strtol+0x3b>
  800aed:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800af2:	3c 2d                	cmp    $0x2d,%al
  800af4:	75 08                	jne    800afe <strtol+0x3b>
		s++, neg = 1;
  800af6:	83 c1 01             	add    $0x1,%ecx
  800af9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800afe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b04:	75 15                	jne    800b1b <strtol+0x58>
  800b06:	80 39 30             	cmpb   $0x30,(%ecx)
  800b09:	75 10                	jne    800b1b <strtol+0x58>
  800b0b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b0f:	75 7c                	jne    800b8d <strtol+0xca>
		s += 2, base = 16;
  800b11:	83 c1 02             	add    $0x2,%ecx
  800b14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b19:	eb 16                	jmp    800b31 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b1b:	85 db                	test   %ebx,%ebx
  800b1d:	75 12                	jne    800b31 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b1f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b24:	80 39 30             	cmpb   $0x30,(%ecx)
  800b27:	75 08                	jne    800b31 <strtol+0x6e>
		s++, base = 8;
  800b29:	83 c1 01             	add    $0x1,%ecx
  800b2c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b31:	b8 00 00 00 00       	mov    $0x0,%eax
  800b36:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b39:	0f b6 11             	movzbl (%ecx),%edx
  800b3c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b3f:	89 f3                	mov    %esi,%ebx
  800b41:	80 fb 09             	cmp    $0x9,%bl
  800b44:	77 08                	ja     800b4e <strtol+0x8b>
			dig = *s - '0';
  800b46:	0f be d2             	movsbl %dl,%edx
  800b49:	83 ea 30             	sub    $0x30,%edx
  800b4c:	eb 22                	jmp    800b70 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b4e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b51:	89 f3                	mov    %esi,%ebx
  800b53:	80 fb 19             	cmp    $0x19,%bl
  800b56:	77 08                	ja     800b60 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b58:	0f be d2             	movsbl %dl,%edx
  800b5b:	83 ea 57             	sub    $0x57,%edx
  800b5e:	eb 10                	jmp    800b70 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b60:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b63:	89 f3                	mov    %esi,%ebx
  800b65:	80 fb 19             	cmp    $0x19,%bl
  800b68:	77 16                	ja     800b80 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b6a:	0f be d2             	movsbl %dl,%edx
  800b6d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b70:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b73:	7d 0b                	jge    800b80 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b75:	83 c1 01             	add    $0x1,%ecx
  800b78:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b7c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b7e:	eb b9                	jmp    800b39 <strtol+0x76>

	if (endptr)
  800b80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b84:	74 0d                	je     800b93 <strtol+0xd0>
		*endptr = (char *) s;
  800b86:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b89:	89 0e                	mov    %ecx,(%esi)
  800b8b:	eb 06                	jmp    800b93 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b8d:	85 db                	test   %ebx,%ebx
  800b8f:	74 98                	je     800b29 <strtol+0x66>
  800b91:	eb 9e                	jmp    800b31 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b93:	89 c2                	mov    %eax,%edx
  800b95:	f7 da                	neg    %edx
  800b97:	85 ff                	test   %edi,%edi
  800b99:	0f 45 c2             	cmovne %edx,%eax
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 04             	sub    $0x4,%esp
  800baa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800bad:	57                   	push   %edi
  800bae:	e8 6e fc ff ff       	call   800821 <strlen>
  800bb3:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800bb6:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800bb9:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800bbe:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800bc3:	eb 46                	jmp    800c0b <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800bc5:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800bc9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800bcc:	80 f9 09             	cmp    $0x9,%cl
  800bcf:	77 08                	ja     800bd9 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800bd1:	0f be d2             	movsbl %dl,%edx
  800bd4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800bd7:	eb 27                	jmp    800c00 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800bd9:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800bdc:	80 f9 05             	cmp    $0x5,%cl
  800bdf:	77 08                	ja     800be9 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800be1:	0f be d2             	movsbl %dl,%edx
  800be4:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800be7:	eb 17                	jmp    800c00 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800be9:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800bec:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800bef:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800bf4:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800bf8:	77 06                	ja     800c00 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800bfa:	0f be d2             	movsbl %dl,%edx
  800bfd:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800c00:	0f af ce             	imul   %esi,%ecx
  800c03:	01 c8                	add    %ecx,%eax
		base *= 16;
  800c05:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800c08:	83 eb 01             	sub    $0x1,%ebx
  800c0b:	83 fb 01             	cmp    $0x1,%ebx
  800c0e:	7f b5                	jg     800bc5 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800c10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	89 c3                	mov    %eax,%ebx
  800c2b:	89 c7                	mov    %eax,%edi
  800c2d:	89 c6                	mov    %eax,%esi
  800c2f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c41:	b8 01 00 00 00       	mov    $0x1,%eax
  800c46:	89 d1                	mov    %edx,%ecx
  800c48:	89 d3                	mov    %edx,%ebx
  800c4a:	89 d7                	mov    %edx,%edi
  800c4c:	89 d6                	mov    %edx,%esi
  800c4e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c63:	b8 03 00 00 00       	mov    $0x3,%eax
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	89 cb                	mov    %ecx,%ebx
  800c6d:	89 cf                	mov    %ecx,%edi
  800c6f:	89 ce                	mov    %ecx,%esi
  800c71:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c73:	85 c0                	test   %eax,%eax
  800c75:	7e 17                	jle    800c8e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c77:	83 ec 0c             	sub    $0xc,%esp
  800c7a:	50                   	push   %eax
  800c7b:	6a 03                	push   $0x3
  800c7d:	68 df 26 80 00       	push   $0x8026df
  800c82:	6a 23                	push   $0x23
  800c84:	68 fc 26 80 00       	push   $0x8026fc
  800c89:	e8 bf f4 ff ff       	call   80014d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca1:	b8 02 00 00 00       	mov    $0x2,%eax
  800ca6:	89 d1                	mov    %edx,%ecx
  800ca8:	89 d3                	mov    %edx,%ebx
  800caa:	89 d7                	mov    %edx,%edi
  800cac:	89 d6                	mov    %edx,%esi
  800cae:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <sys_yield>:

void
sys_yield(void)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cc5:	89 d1                	mov    %edx,%ecx
  800cc7:	89 d3                	mov    %edx,%ebx
  800cc9:	89 d7                	mov    %edx,%edi
  800ccb:	89 d6                	mov    %edx,%esi
  800ccd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
  800cda:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdd:	be 00 00 00 00       	mov    $0x0,%esi
  800ce2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ce7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf0:	89 f7                	mov    %esi,%edi
  800cf2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	7e 17                	jle    800d0f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf8:	83 ec 0c             	sub    $0xc,%esp
  800cfb:	50                   	push   %eax
  800cfc:	6a 04                	push   $0x4
  800cfe:	68 df 26 80 00       	push   $0x8026df
  800d03:	6a 23                	push   $0x23
  800d05:	68 fc 26 80 00       	push   $0x8026fc
  800d0a:	e8 3e f4 ff ff       	call   80014d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d20:	b8 05 00 00 00       	mov    $0x5,%eax
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d31:	8b 75 18             	mov    0x18(%ebp),%esi
  800d34:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7e 17                	jle    800d51 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3a:	83 ec 0c             	sub    $0xc,%esp
  800d3d:	50                   	push   %eax
  800d3e:	6a 05                	push   $0x5
  800d40:	68 df 26 80 00       	push   $0x8026df
  800d45:	6a 23                	push   $0x23
  800d47:	68 fc 26 80 00       	push   $0x8026fc
  800d4c:	e8 fc f3 ff ff       	call   80014d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
  800d5f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d62:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d67:	b8 06 00 00 00       	mov    $0x6,%eax
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	89 df                	mov    %ebx,%edi
  800d74:	89 de                	mov    %ebx,%esi
  800d76:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	7e 17                	jle    800d93 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7c:	83 ec 0c             	sub    $0xc,%esp
  800d7f:	50                   	push   %eax
  800d80:	6a 06                	push   $0x6
  800d82:	68 df 26 80 00       	push   $0x8026df
  800d87:	6a 23                	push   $0x23
  800d89:	68 fc 26 80 00       	push   $0x8026fc
  800d8e:	e8 ba f3 ff ff       	call   80014d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da9:	b8 08 00 00 00       	mov    $0x8,%eax
  800dae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db1:	8b 55 08             	mov    0x8(%ebp),%edx
  800db4:	89 df                	mov    %ebx,%edi
  800db6:	89 de                	mov    %ebx,%esi
  800db8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	7e 17                	jle    800dd5 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbe:	83 ec 0c             	sub    $0xc,%esp
  800dc1:	50                   	push   %eax
  800dc2:	6a 08                	push   $0x8
  800dc4:	68 df 26 80 00       	push   $0x8026df
  800dc9:	6a 23                	push   $0x23
  800dcb:	68 fc 26 80 00       	push   $0x8026fc
  800dd0:	e8 78 f3 ff ff       	call   80014d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
  800de3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800deb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df3:	8b 55 08             	mov    0x8(%ebp),%edx
  800df6:	89 df                	mov    %ebx,%edi
  800df8:	89 de                	mov    %ebx,%esi
  800dfa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	7e 17                	jle    800e17 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e00:	83 ec 0c             	sub    $0xc,%esp
  800e03:	50                   	push   %eax
  800e04:	6a 0a                	push   $0xa
  800e06:	68 df 26 80 00       	push   $0x8026df
  800e0b:	6a 23                	push   $0x23
  800e0d:	68 fc 26 80 00       	push   $0x8026fc
  800e12:	e8 36 f3 ff ff       	call   80014d <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1a:	5b                   	pop    %ebx
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	57                   	push   %edi
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
  800e25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2d:	b8 09 00 00 00       	mov    $0x9,%eax
  800e32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e35:	8b 55 08             	mov    0x8(%ebp),%edx
  800e38:	89 df                	mov    %ebx,%edi
  800e3a:	89 de                	mov    %ebx,%esi
  800e3c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	7e 17                	jle    800e59 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e42:	83 ec 0c             	sub    $0xc,%esp
  800e45:	50                   	push   %eax
  800e46:	6a 09                	push   $0x9
  800e48:	68 df 26 80 00       	push   $0x8026df
  800e4d:	6a 23                	push   $0x23
  800e4f:	68 fc 26 80 00       	push   $0x8026fc
  800e54:	e8 f4 f2 ff ff       	call   80014d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	57                   	push   %edi
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e67:	be 00 00 00 00       	mov    $0x0,%esi
  800e6c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e74:	8b 55 08             	mov    0x8(%ebp),%edx
  800e77:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e7d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800e8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e92:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 cb                	mov    %ecx,%ebx
  800e9c:	89 cf                	mov    %ecx,%edi
  800e9e:	89 ce                	mov    %ecx,%esi
  800ea0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea2:	85 c0                	test   %eax,%eax
  800ea4:	7e 17                	jle    800ebd <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea6:	83 ec 0c             	sub    $0xc,%esp
  800ea9:	50                   	push   %eax
  800eaa:	6a 0d                	push   $0xd
  800eac:	68 df 26 80 00       	push   $0x8026df
  800eb1:	6a 23                	push   $0x23
  800eb3:	68 fc 26 80 00       	push   $0x8026fc
  800eb8:	e8 90 f2 ff ff       	call   80014d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ebd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	53                   	push   %ebx
  800ec9:	83 ec 04             	sub    $0x4,%esp
  800ecc:	8b 45 08             	mov    0x8(%ebp),%eax

	
	void *addr = (void *) utf->utf_fault_va;
  800ecf:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800ed1:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ed5:	74 11                	je     800ee8 <pgfault+0x23>
  800ed7:	89 d8                	mov    %ebx,%eax
  800ed9:	c1 e8 0c             	shr    $0xc,%eax
  800edc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ee3:	f6 c4 08             	test   $0x8,%ah
  800ee6:	75 14                	jne    800efc <pgfault+0x37>
		panic("page fault");
  800ee8:	83 ec 04             	sub    $0x4,%esp
  800eeb:	68 0a 27 80 00       	push   $0x80270a
  800ef0:	6a 5b                	push   $0x5b
  800ef2:	68 15 27 80 00       	push   $0x802715
  800ef7:	e8 51 f2 ff ff       	call   80014d <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// allocate a new page and map it at a temporary location
	if((r = sys_page_alloc(0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800efc:	83 ec 04             	sub    $0x4,%esp
  800eff:	6a 07                	push   $0x7
  800f01:	68 00 f0 7f 00       	push   $0x7ff000
  800f06:	6a 00                	push   $0x0
  800f08:	e8 c7 fd ff ff       	call   800cd4 <sys_page_alloc>
  800f0d:	83 c4 10             	add    $0x10,%esp
  800f10:	85 c0                	test   %eax,%eax
  800f12:	79 12                	jns    800f26 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800f14:	50                   	push   %eax
  800f15:	68 20 27 80 00       	push   $0x802720
  800f1a:	6a 66                	push   $0x66
  800f1c:	68 15 27 80 00       	push   $0x802715
  800f21:	e8 27 f2 ff ff       	call   80014d <_panic>

	// copy date to new page
	//strncpy((char *)PFTEMP, (char *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
	memcpy((void *)PFTEMP, (void *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
  800f26:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f2c:	83 ec 04             	sub    $0x4,%esp
  800f2f:	68 00 10 00 00       	push   $0x1000
  800f34:	53                   	push   %ebx
  800f35:	68 00 f0 7f 00       	push   $0x7ff000
  800f3a:	e8 15 fb ff ff       	call   800a54 <memcpy>

	// move the new page to the old page's address
	if((r = sys_page_map(0, (void *)PFTEMP, 0, (void *)
  800f3f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f46:	53                   	push   %ebx
  800f47:	6a 00                	push   $0x0
  800f49:	68 00 f0 7f 00       	push   $0x7ff000
  800f4e:	6a 00                	push   $0x0
  800f50:	e8 c2 fd ff ff       	call   800d17 <sys_page_map>
  800f55:	83 c4 20             	add    $0x20,%esp
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	79 12                	jns    800f6e <pgfault+0xa9>
		(ROUNDDOWN(addr, PGSIZE)), PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_map: %e", r);
  800f5c:	50                   	push   %eax
  800f5d:	68 33 27 80 00       	push   $0x802733
  800f62:	6a 6f                	push   $0x6f
  800f64:	68 15 27 80 00       	push   $0x802715
  800f69:	e8 df f1 ff ff       	call   80014d <_panic>

	// unmap page on PFTEMP
	if((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800f6e:	83 ec 08             	sub    $0x8,%esp
  800f71:	68 00 f0 7f 00       	push   $0x7ff000
  800f76:	6a 00                	push   $0x0
  800f78:	e8 dc fd ff ff       	call   800d59 <sys_page_unmap>
  800f7d:	83 c4 10             	add    $0x10,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	79 12                	jns    800f96 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  800f84:	50                   	push   %eax
  800f85:	68 44 27 80 00       	push   $0x802744
  800f8a:	6a 73                	push   $0x73
  800f8c:	68 15 27 80 00       	push   $0x802715
  800f91:	e8 b7 f1 ff ff       	call   80014d <_panic>


}
  800f96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f99:	c9                   	leave  
  800f9a:	c3                   	ret    

00800f9b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	57                   	push   %edi
  800f9f:	56                   	push   %esi
  800fa0:	53                   	push   %ebx
  800fa1:	83 ec 28             	sub    $0x28,%esp

	#ifdef CHALLENGE 
	set_exception_handler(pgfault, T_PGFLT);
	#else
	// set up page fault handler
	set_pgfault_handler(pgfault);
  800fa4:	68 c5 0e 80 00       	push   $0x800ec5
  800fa9:	e8 51 0f 00 00       	call   801eff <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fae:	b8 07 00 00 00       	mov    $0x7,%eax
  800fb3:	cd 30                	int    $0x30
  800fb5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fb8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	#endif

	// create a child
	envid = sys_exofork();
	if (envid < 0)
  800fbb:	83 c4 10             	add    $0x10,%esp
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	79 15                	jns    800fd7 <fork+0x3c>
		panic("sys_exofork: %e", envid);
  800fc2:	50                   	push   %eax
  800fc3:	68 57 27 80 00       	push   $0x802757
  800fc8:	68 d0 00 00 00       	push   $0xd0
  800fcd:	68 15 27 80 00       	push   $0x802715
  800fd2:	e8 76 f1 ff ff       	call   80014d <_panic>
  800fd7:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800fdc:	be 00 08 00 00       	mov    $0x800,%esi
	// we are the child
	if(envid == 0) {
  800fe1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800fe5:	75 21                	jne    801008 <fork+0x6d>
		// the copied valude of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800fe7:	e8 aa fc ff ff       	call   800c96 <sys_getenvid>
  800fec:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ff1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ff4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ff9:	a3 0c 40 80 00       	mov    %eax,0x80400c
		/*// alloc exception stack
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
			PTE_P | PTE_U | PTE_W)) < 0)
			panic("sys_page_alloc: %e", r);*/

		return 0;
  800ffe:	b8 00 00 00 00       	mov    $0x0,%eax
  801003:	e9 a3 01 00 00       	jmp    8011ab <fork+0x210>
{
	int r;

	// LAB 4: Your code here.
	
	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P))
  801008:	89 d8                	mov    %ebx,%eax
  80100a:	c1 e8 16             	shr    $0x16,%eax
  80100d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801014:	a8 01                	test   $0x1,%al
  801016:	0f 84 f0 00 00 00    	je     80110c <fork+0x171>
		return 0;

	// virtual page pn's page table entry
	pte_t pe = uvpt[pn];
  80101c:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi


	if((pe & PTE_P) && (pe & PTE_U)) {
  801023:	89 f8                	mov    %edi,%eax
  801025:	83 e0 05             	and    $0x5,%eax
  801028:	83 f8 05             	cmp    $0x5,%eax
  80102b:	0f 85 db 00 00 00    	jne    80110c <fork+0x171>
		// share with the child environment 
		if(pe & PTE_SHARE) {
  801031:	f7 c7 00 04 00 00    	test   $0x400,%edi
  801037:	74 36                	je     80106f <fork+0xd4>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  801039:	83 ec 0c             	sub    $0xc,%esp
  80103c:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  801042:	57                   	push   %edi
  801043:	53                   	push   %ebx
  801044:	ff 75 e4             	pushl  -0x1c(%ebp)
  801047:	53                   	push   %ebx
  801048:	6a 00                	push   $0x0
  80104a:	e8 c8 fc ff ff       	call   800d17 <sys_page_map>
  80104f:	83 c4 20             	add    $0x20,%esp
  801052:	85 c0                	test   %eax,%eax
  801054:	0f 89 b2 00 00 00    	jns    80110c <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  80105a:	50                   	push   %eax
  80105b:	68 67 27 80 00       	push   $0x802767
  801060:	68 97 00 00 00       	push   $0x97
  801065:	68 15 27 80 00       	push   $0x802715
  80106a:	e8 de f0 ff ff       	call   80014d <_panic>
		}
		// the page is writable or copy-on-write
		else if((pe & PTE_W) || (pe & PTE_COW)) {
  80106f:	f7 c7 02 08 00 00    	test   $0x802,%edi
  801075:	74 63                	je     8010da <fork+0x13f>
			// create the child mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, 
  801077:	81 e7 05 06 00 00    	and    $0x605,%edi
  80107d:	81 cf 00 08 00 00    	or     $0x800,%edi
  801083:	83 ec 0c             	sub    $0xc,%esp
  801086:	57                   	push   %edi
  801087:	53                   	push   %ebx
  801088:	ff 75 e4             	pushl  -0x1c(%ebp)
  80108b:	53                   	push   %ebx
  80108c:	6a 00                	push   $0x0
  80108e:	e8 84 fc ff ff       	call   800d17 <sys_page_map>
  801093:	83 c4 20             	add    $0x20,%esp
  801096:	85 c0                	test   %eax,%eax
  801098:	79 15                	jns    8010af <fork+0x114>
				(void *)(pn*PGSIZE), (pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  80109a:	50                   	push   %eax
  80109b:	68 67 27 80 00       	push   $0x802767
  8010a0:	68 9e 00 00 00       	push   $0x9e
  8010a5:	68 15 27 80 00       	push   $0x802715
  8010aa:	e8 9e f0 ff ff       	call   80014d <_panic>
			// map the parent mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE),
  8010af:	83 ec 0c             	sub    $0xc,%esp
  8010b2:	57                   	push   %edi
  8010b3:	53                   	push   %ebx
  8010b4:	6a 00                	push   $0x0
  8010b6:	53                   	push   %ebx
  8010b7:	6a 00                	push   $0x0
  8010b9:	e8 59 fc ff ff       	call   800d17 <sys_page_map>
  8010be:	83 c4 20             	add    $0x20,%esp
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	79 47                	jns    80110c <fork+0x171>
				(pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  8010c5:	50                   	push   %eax
  8010c6:	68 67 27 80 00       	push   $0x802767
  8010cb:	68 a2 00 00 00       	push   $0xa2
  8010d0:	68 15 27 80 00       	push   $0x802715
  8010d5:	e8 73 f0 ff ff       	call   80014d <_panic>
		}	
		else {
			// create the child mapping read only
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  8010da:	83 ec 0c             	sub    $0xc,%esp
  8010dd:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  8010e3:	57                   	push   %edi
  8010e4:	53                   	push   %ebx
  8010e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e8:	53                   	push   %ebx
  8010e9:	6a 00                	push   $0x0
  8010eb:	e8 27 fc ff ff       	call   800d17 <sys_page_map>
  8010f0:	83 c4 20             	add    $0x20,%esp
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	79 15                	jns    80110c <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  8010f7:	50                   	push   %eax
  8010f8:	68 67 27 80 00       	push   $0x802767
  8010fd:	68 a8 00 00 00       	push   $0xa8
  801102:	68 15 27 80 00       	push   $0x802715
  801107:	e8 41 f0 ff ff       	call   80014d <_panic>
			panic("sys_page_alloc: %e", r);*/

		return 0;
	}
	// copy address to child environment's page dirctory
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn)
  80110c:	83 c6 01             	add    $0x1,%esi
  80110f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801115:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  80111b:	0f 85 e7 fe ff ff    	jne    801008 <fork+0x6d>
	#ifdef CHALLENGE 
	if((r = sys_env_set_exception_upcall(envid, thisenv->env_exception_upcall)) < 0)
		panic("sys_env_set_exception_upcall: %e", r);
	#else
	// set child's page fault handler
	if((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  801121:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801126:	8b 40 64             	mov    0x64(%eax),%eax
  801129:	83 ec 08             	sub    $0x8,%esp
  80112c:	50                   	push   %eax
  80112d:	ff 75 e0             	pushl  -0x20(%ebp)
  801130:	e8 ea fc ff ff       	call   800e1f <sys_env_set_pgfault_upcall>
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	85 c0                	test   %eax,%eax
  80113a:	79 15                	jns    801151 <fork+0x1b6>
		panic("sys_env_set_pgfault_upcall: %e", r);
  80113c:	50                   	push   %eax
  80113d:	68 a0 27 80 00       	push   $0x8027a0
  801142:	68 e9 00 00 00       	push   $0xe9
  801147:	68 15 27 80 00       	push   $0x802715
  80114c:	e8 fc ef ff ff       	call   80014d <_panic>
	#endif

	// alloc exception stack for child environment
	if((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), 
  801151:	83 ec 04             	sub    $0x4,%esp
  801154:	6a 07                	push   $0x7
  801156:	68 00 f0 bf ee       	push   $0xeebff000
  80115b:	ff 75 e0             	pushl  -0x20(%ebp)
  80115e:	e8 71 fb ff ff       	call   800cd4 <sys_page_alloc>
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	85 c0                	test   %eax,%eax
  801168:	79 15                	jns    80117f <fork+0x1e4>
		PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
  80116a:	50                   	push   %eax
  80116b:	68 20 27 80 00       	push   $0x802720
  801170:	68 ef 00 00 00       	push   $0xef
  801175:	68 15 27 80 00       	push   $0x802715
  80117a:	e8 ce ef ff ff       	call   80014d <_panic>

	// start the child environment running
	if((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80117f:	83 ec 08             	sub    $0x8,%esp
  801182:	6a 02                	push   $0x2
  801184:	ff 75 e0             	pushl  -0x20(%ebp)
  801187:	e8 0f fc ff ff       	call   800d9b <sys_env_set_status>
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	85 c0                	test   %eax,%eax
  801191:	79 15                	jns    8011a8 <fork+0x20d>
		panic("sys_env_set_status: %e", r);
  801193:	50                   	push   %eax
  801194:	68 73 27 80 00       	push   $0x802773
  801199:	68 f3 00 00 00       	push   $0xf3
  80119e:	68 15 27 80 00       	push   $0x802715
  8011a3:	e8 a5 ef ff ff       	call   80014d <_panic>

	return envid;
  8011a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  8011ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ae:	5b                   	pop    %ebx
  8011af:	5e                   	pop    %esi
  8011b0:	5f                   	pop    %edi
  8011b1:	5d                   	pop    %ebp
  8011b2:	c3                   	ret    

008011b3 <sfork>:

// Challenge!
int
sfork(void)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011b9:	68 8a 27 80 00       	push   $0x80278a
  8011be:	68 fc 00 00 00       	push   $0xfc
  8011c3:	68 15 27 80 00       	push   $0x802715
  8011c8:	e8 80 ef ff ff       	call   80014d <_panic>

008011cd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d3:	05 00 00 00 30       	add    $0x30000000,%eax
  8011d8:	c1 e8 0c             	shr    $0xc,%eax
}
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e3:	05 00 00 00 30       	add    $0x30000000,%eax
  8011e8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011ed:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    

008011f4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011fa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	c1 ea 16             	shr    $0x16,%edx
  801204:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80120b:	f6 c2 01             	test   $0x1,%dl
  80120e:	74 11                	je     801221 <fd_alloc+0x2d>
  801210:	89 c2                	mov    %eax,%edx
  801212:	c1 ea 0c             	shr    $0xc,%edx
  801215:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121c:	f6 c2 01             	test   $0x1,%dl
  80121f:	75 09                	jne    80122a <fd_alloc+0x36>
			*fd_store = fd;
  801221:	89 01                	mov    %eax,(%ecx)
			return 0;
  801223:	b8 00 00 00 00       	mov    $0x0,%eax
  801228:	eb 17                	jmp    801241 <fd_alloc+0x4d>
  80122a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80122f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801234:	75 c9                	jne    8011ff <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801236:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80123c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    

00801243 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801249:	83 f8 1f             	cmp    $0x1f,%eax
  80124c:	77 36                	ja     801284 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80124e:	c1 e0 0c             	shl    $0xc,%eax
  801251:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801256:	89 c2                	mov    %eax,%edx
  801258:	c1 ea 16             	shr    $0x16,%edx
  80125b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801262:	f6 c2 01             	test   $0x1,%dl
  801265:	74 24                	je     80128b <fd_lookup+0x48>
  801267:	89 c2                	mov    %eax,%edx
  801269:	c1 ea 0c             	shr    $0xc,%edx
  80126c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801273:	f6 c2 01             	test   $0x1,%dl
  801276:	74 1a                	je     801292 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801278:	8b 55 0c             	mov    0xc(%ebp),%edx
  80127b:	89 02                	mov    %eax,(%edx)
	return 0;
  80127d:	b8 00 00 00 00       	mov    $0x0,%eax
  801282:	eb 13                	jmp    801297 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801284:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801289:	eb 0c                	jmp    801297 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80128b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801290:	eb 05                	jmp    801297 <fd_lookup+0x54>
  801292:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801297:	5d                   	pop    %ebp
  801298:	c3                   	ret    

00801299 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	83 ec 08             	sub    $0x8,%esp
  80129f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a2:	ba 3c 28 80 00       	mov    $0x80283c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012a7:	eb 13                	jmp    8012bc <dev_lookup+0x23>
  8012a9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012ac:	39 08                	cmp    %ecx,(%eax)
  8012ae:	75 0c                	jne    8012bc <dev_lookup+0x23>
			*dev = devtab[i];
  8012b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ba:	eb 2e                	jmp    8012ea <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012bc:	8b 02                	mov    (%edx),%eax
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	75 e7                	jne    8012a9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012c2:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8012c7:	8b 40 48             	mov    0x48(%eax),%eax
  8012ca:	83 ec 04             	sub    $0x4,%esp
  8012cd:	51                   	push   %ecx
  8012ce:	50                   	push   %eax
  8012cf:	68 c0 27 80 00       	push   $0x8027c0
  8012d4:	e8 4d ef ff ff       	call   800226 <cprintf>
	*dev = 0;
  8012d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012dc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012ea:	c9                   	leave  
  8012eb:	c3                   	ret    

008012ec <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	56                   	push   %esi
  8012f0:	53                   	push   %ebx
  8012f1:	83 ec 10             	sub    $0x10,%esp
  8012f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8012f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012fd:	50                   	push   %eax
  8012fe:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801304:	c1 e8 0c             	shr    $0xc,%eax
  801307:	50                   	push   %eax
  801308:	e8 36 ff ff ff       	call   801243 <fd_lookup>
  80130d:	83 c4 08             	add    $0x8,%esp
  801310:	85 c0                	test   %eax,%eax
  801312:	78 05                	js     801319 <fd_close+0x2d>
	    || fd != fd2) 
  801314:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801317:	74 0c                	je     801325 <fd_close+0x39>
		return (must_exist ? r : 0); 
  801319:	84 db                	test   %bl,%bl
  80131b:	ba 00 00 00 00       	mov    $0x0,%edx
  801320:	0f 44 c2             	cmove  %edx,%eax
  801323:	eb 41                	jmp    801366 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801325:	83 ec 08             	sub    $0x8,%esp
  801328:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132b:	50                   	push   %eax
  80132c:	ff 36                	pushl  (%esi)
  80132e:	e8 66 ff ff ff       	call   801299 <dev_lookup>
  801333:	89 c3                	mov    %eax,%ebx
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	85 c0                	test   %eax,%eax
  80133a:	78 1a                	js     801356 <fd_close+0x6a>
		if (dev->dev_close) 
  80133c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  801342:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  801347:	85 c0                	test   %eax,%eax
  801349:	74 0b                	je     801356 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80134b:	83 ec 0c             	sub    $0xc,%esp
  80134e:	56                   	push   %esi
  80134f:	ff d0                	call   *%eax
  801351:	89 c3                	mov    %eax,%ebx
  801353:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801356:	83 ec 08             	sub    $0x8,%esp
  801359:	56                   	push   %esi
  80135a:	6a 00                	push   $0x0
  80135c:	e8 f8 f9 ff ff       	call   800d59 <sys_page_unmap>
	return r;
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	89 d8                	mov    %ebx,%eax
}
  801366:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801369:	5b                   	pop    %ebx
  80136a:	5e                   	pop    %esi
  80136b:	5d                   	pop    %ebp
  80136c:	c3                   	ret    

0080136d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801373:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801376:	50                   	push   %eax
  801377:	ff 75 08             	pushl  0x8(%ebp)
  80137a:	e8 c4 fe ff ff       	call   801243 <fd_lookup>
  80137f:	83 c4 08             	add    $0x8,%esp
  801382:	85 c0                	test   %eax,%eax
  801384:	78 10                	js     801396 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  801386:	83 ec 08             	sub    $0x8,%esp
  801389:	6a 01                	push   $0x1
  80138b:	ff 75 f4             	pushl  -0xc(%ebp)
  80138e:	e8 59 ff ff ff       	call   8012ec <fd_close>
  801393:	83 c4 10             	add    $0x10,%esp
}
  801396:	c9                   	leave  
  801397:	c3                   	ret    

00801398 <close_all>:

void
close_all(void)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	53                   	push   %ebx
  80139c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80139f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013a4:	83 ec 0c             	sub    $0xc,%esp
  8013a7:	53                   	push   %ebx
  8013a8:	e8 c0 ff ff ff       	call   80136d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ad:	83 c3 01             	add    $0x1,%ebx
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	83 fb 20             	cmp    $0x20,%ebx
  8013b6:	75 ec                	jne    8013a4 <close_all+0xc>
		close(i);
}
  8013b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bb:	c9                   	leave  
  8013bc:	c3                   	ret    

008013bd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	57                   	push   %edi
  8013c1:	56                   	push   %esi
  8013c2:	53                   	push   %ebx
  8013c3:	83 ec 2c             	sub    $0x2c,%esp
  8013c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013c9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013cc:	50                   	push   %eax
  8013cd:	ff 75 08             	pushl  0x8(%ebp)
  8013d0:	e8 6e fe ff ff       	call   801243 <fd_lookup>
  8013d5:	83 c4 08             	add    $0x8,%esp
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	0f 88 c1 00 00 00    	js     8014a1 <dup+0xe4>
		return r;
	close(newfdnum);
  8013e0:	83 ec 0c             	sub    $0xc,%esp
  8013e3:	56                   	push   %esi
  8013e4:	e8 84 ff ff ff       	call   80136d <close>

	newfd = INDEX2FD(newfdnum);
  8013e9:	89 f3                	mov    %esi,%ebx
  8013eb:	c1 e3 0c             	shl    $0xc,%ebx
  8013ee:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013f4:	83 c4 04             	add    $0x4,%esp
  8013f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013fa:	e8 de fd ff ff       	call   8011dd <fd2data>
  8013ff:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801401:	89 1c 24             	mov    %ebx,(%esp)
  801404:	e8 d4 fd ff ff       	call   8011dd <fd2data>
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80140f:	89 f8                	mov    %edi,%eax
  801411:	c1 e8 16             	shr    $0x16,%eax
  801414:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80141b:	a8 01                	test   $0x1,%al
  80141d:	74 37                	je     801456 <dup+0x99>
  80141f:	89 f8                	mov    %edi,%eax
  801421:	c1 e8 0c             	shr    $0xc,%eax
  801424:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80142b:	f6 c2 01             	test   $0x1,%dl
  80142e:	74 26                	je     801456 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801430:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801437:	83 ec 0c             	sub    $0xc,%esp
  80143a:	25 07 0e 00 00       	and    $0xe07,%eax
  80143f:	50                   	push   %eax
  801440:	ff 75 d4             	pushl  -0x2c(%ebp)
  801443:	6a 00                	push   $0x0
  801445:	57                   	push   %edi
  801446:	6a 00                	push   $0x0
  801448:	e8 ca f8 ff ff       	call   800d17 <sys_page_map>
  80144d:	89 c7                	mov    %eax,%edi
  80144f:	83 c4 20             	add    $0x20,%esp
  801452:	85 c0                	test   %eax,%eax
  801454:	78 2e                	js     801484 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801456:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801459:	89 d0                	mov    %edx,%eax
  80145b:	c1 e8 0c             	shr    $0xc,%eax
  80145e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801465:	83 ec 0c             	sub    $0xc,%esp
  801468:	25 07 0e 00 00       	and    $0xe07,%eax
  80146d:	50                   	push   %eax
  80146e:	53                   	push   %ebx
  80146f:	6a 00                	push   $0x0
  801471:	52                   	push   %edx
  801472:	6a 00                	push   $0x0
  801474:	e8 9e f8 ff ff       	call   800d17 <sys_page_map>
  801479:	89 c7                	mov    %eax,%edi
  80147b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80147e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801480:	85 ff                	test   %edi,%edi
  801482:	79 1d                	jns    8014a1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801484:	83 ec 08             	sub    $0x8,%esp
  801487:	53                   	push   %ebx
  801488:	6a 00                	push   $0x0
  80148a:	e8 ca f8 ff ff       	call   800d59 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80148f:	83 c4 08             	add    $0x8,%esp
  801492:	ff 75 d4             	pushl  -0x2c(%ebp)
  801495:	6a 00                	push   $0x0
  801497:	e8 bd f8 ff ff       	call   800d59 <sys_page_unmap>
	return r;
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	89 f8                	mov    %edi,%eax
}
  8014a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014a4:	5b                   	pop    %ebx
  8014a5:	5e                   	pop    %esi
  8014a6:	5f                   	pop    %edi
  8014a7:	5d                   	pop    %ebp
  8014a8:	c3                   	ret    

008014a9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	53                   	push   %ebx
  8014ad:	83 ec 14             	sub    $0x14,%esp
  8014b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b6:	50                   	push   %eax
  8014b7:	53                   	push   %ebx
  8014b8:	e8 86 fd ff ff       	call   801243 <fd_lookup>
  8014bd:	83 c4 08             	add    $0x8,%esp
  8014c0:	89 c2                	mov    %eax,%edx
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	78 6d                	js     801533 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c6:	83 ec 08             	sub    $0x8,%esp
  8014c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014cc:	50                   	push   %eax
  8014cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d0:	ff 30                	pushl  (%eax)
  8014d2:	e8 c2 fd ff ff       	call   801299 <dev_lookup>
  8014d7:	83 c4 10             	add    $0x10,%esp
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 4c                	js     80152a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014de:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014e1:	8b 42 08             	mov    0x8(%edx),%eax
  8014e4:	83 e0 03             	and    $0x3,%eax
  8014e7:	83 f8 01             	cmp    $0x1,%eax
  8014ea:	75 21                	jne    80150d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ec:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8014f1:	8b 40 48             	mov    0x48(%eax),%eax
  8014f4:	83 ec 04             	sub    $0x4,%esp
  8014f7:	53                   	push   %ebx
  8014f8:	50                   	push   %eax
  8014f9:	68 01 28 80 00       	push   $0x802801
  8014fe:	e8 23 ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801503:	83 c4 10             	add    $0x10,%esp
  801506:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80150b:	eb 26                	jmp    801533 <read+0x8a>
	}
	if (!dev->dev_read)
  80150d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801510:	8b 40 08             	mov    0x8(%eax),%eax
  801513:	85 c0                	test   %eax,%eax
  801515:	74 17                	je     80152e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801517:	83 ec 04             	sub    $0x4,%esp
  80151a:	ff 75 10             	pushl  0x10(%ebp)
  80151d:	ff 75 0c             	pushl  0xc(%ebp)
  801520:	52                   	push   %edx
  801521:	ff d0                	call   *%eax
  801523:	89 c2                	mov    %eax,%edx
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	eb 09                	jmp    801533 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	eb 05                	jmp    801533 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80152e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801533:	89 d0                	mov    %edx,%eax
  801535:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801538:	c9                   	leave  
  801539:	c3                   	ret    

0080153a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	57                   	push   %edi
  80153e:	56                   	push   %esi
  80153f:	53                   	push   %ebx
  801540:	83 ec 0c             	sub    $0xc,%esp
  801543:	8b 7d 08             	mov    0x8(%ebp),%edi
  801546:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801549:	bb 00 00 00 00       	mov    $0x0,%ebx
  80154e:	eb 21                	jmp    801571 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801550:	83 ec 04             	sub    $0x4,%esp
  801553:	89 f0                	mov    %esi,%eax
  801555:	29 d8                	sub    %ebx,%eax
  801557:	50                   	push   %eax
  801558:	89 d8                	mov    %ebx,%eax
  80155a:	03 45 0c             	add    0xc(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	57                   	push   %edi
  80155f:	e8 45 ff ff ff       	call   8014a9 <read>
		if (m < 0)
  801564:	83 c4 10             	add    $0x10,%esp
  801567:	85 c0                	test   %eax,%eax
  801569:	78 10                	js     80157b <readn+0x41>
			return m;
		if (m == 0)
  80156b:	85 c0                	test   %eax,%eax
  80156d:	74 0a                	je     801579 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80156f:	01 c3                	add    %eax,%ebx
  801571:	39 f3                	cmp    %esi,%ebx
  801573:	72 db                	jb     801550 <readn+0x16>
  801575:	89 d8                	mov    %ebx,%eax
  801577:	eb 02                	jmp    80157b <readn+0x41>
  801579:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80157b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80157e:	5b                   	pop    %ebx
  80157f:	5e                   	pop    %esi
  801580:	5f                   	pop    %edi
  801581:	5d                   	pop    %ebp
  801582:	c3                   	ret    

00801583 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	53                   	push   %ebx
  801587:	83 ec 14             	sub    $0x14,%esp
  80158a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801590:	50                   	push   %eax
  801591:	53                   	push   %ebx
  801592:	e8 ac fc ff ff       	call   801243 <fd_lookup>
  801597:	83 c4 08             	add    $0x8,%esp
  80159a:	89 c2                	mov    %eax,%edx
  80159c:	85 c0                	test   %eax,%eax
  80159e:	78 68                	js     801608 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a0:	83 ec 08             	sub    $0x8,%esp
  8015a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a6:	50                   	push   %eax
  8015a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015aa:	ff 30                	pushl  (%eax)
  8015ac:	e8 e8 fc ff ff       	call   801299 <dev_lookup>
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	78 47                	js     8015ff <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015bf:	75 21                	jne    8015e2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c1:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8015c6:	8b 40 48             	mov    0x48(%eax),%eax
  8015c9:	83 ec 04             	sub    $0x4,%esp
  8015cc:	53                   	push   %ebx
  8015cd:	50                   	push   %eax
  8015ce:	68 1d 28 80 00       	push   $0x80281d
  8015d3:	e8 4e ec ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e0:	eb 26                	jmp    801608 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e5:	8b 52 0c             	mov    0xc(%edx),%edx
  8015e8:	85 d2                	test   %edx,%edx
  8015ea:	74 17                	je     801603 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015ec:	83 ec 04             	sub    $0x4,%esp
  8015ef:	ff 75 10             	pushl  0x10(%ebp)
  8015f2:	ff 75 0c             	pushl  0xc(%ebp)
  8015f5:	50                   	push   %eax
  8015f6:	ff d2                	call   *%edx
  8015f8:	89 c2                	mov    %eax,%edx
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	eb 09                	jmp    801608 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ff:	89 c2                	mov    %eax,%edx
  801601:	eb 05                	jmp    801608 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801603:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801608:	89 d0                	mov    %edx,%eax
  80160a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160d:	c9                   	leave  
  80160e:	c3                   	ret    

0080160f <seek>:

int
seek(int fdnum, off_t offset)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801615:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801618:	50                   	push   %eax
  801619:	ff 75 08             	pushl  0x8(%ebp)
  80161c:	e8 22 fc ff ff       	call   801243 <fd_lookup>
  801621:	83 c4 08             	add    $0x8,%esp
  801624:	85 c0                	test   %eax,%eax
  801626:	78 0e                	js     801636 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801628:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80162b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80162e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801631:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801636:	c9                   	leave  
  801637:	c3                   	ret    

00801638 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	53                   	push   %ebx
  80163c:	83 ec 14             	sub    $0x14,%esp
  80163f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801642:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801645:	50                   	push   %eax
  801646:	53                   	push   %ebx
  801647:	e8 f7 fb ff ff       	call   801243 <fd_lookup>
  80164c:	83 c4 08             	add    $0x8,%esp
  80164f:	89 c2                	mov    %eax,%edx
  801651:	85 c0                	test   %eax,%eax
  801653:	78 65                	js     8016ba <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801655:	83 ec 08             	sub    $0x8,%esp
  801658:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165b:	50                   	push   %eax
  80165c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165f:	ff 30                	pushl  (%eax)
  801661:	e8 33 fc ff ff       	call   801299 <dev_lookup>
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	85 c0                	test   %eax,%eax
  80166b:	78 44                	js     8016b1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80166d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801670:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801674:	75 21                	jne    801697 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801676:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80167b:	8b 40 48             	mov    0x48(%eax),%eax
  80167e:	83 ec 04             	sub    $0x4,%esp
  801681:	53                   	push   %ebx
  801682:	50                   	push   %eax
  801683:	68 e0 27 80 00       	push   $0x8027e0
  801688:	e8 99 eb ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801695:	eb 23                	jmp    8016ba <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801697:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80169a:	8b 52 18             	mov    0x18(%edx),%edx
  80169d:	85 d2                	test   %edx,%edx
  80169f:	74 14                	je     8016b5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016a1:	83 ec 08             	sub    $0x8,%esp
  8016a4:	ff 75 0c             	pushl  0xc(%ebp)
  8016a7:	50                   	push   %eax
  8016a8:	ff d2                	call   *%edx
  8016aa:	89 c2                	mov    %eax,%edx
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	eb 09                	jmp    8016ba <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b1:	89 c2                	mov    %eax,%edx
  8016b3:	eb 05                	jmp    8016ba <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016ba:	89 d0                	mov    %edx,%eax
  8016bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	53                   	push   %ebx
  8016c5:	83 ec 14             	sub    $0x14,%esp
  8016c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ce:	50                   	push   %eax
  8016cf:	ff 75 08             	pushl  0x8(%ebp)
  8016d2:	e8 6c fb ff ff       	call   801243 <fd_lookup>
  8016d7:	83 c4 08             	add    $0x8,%esp
  8016da:	89 c2                	mov    %eax,%edx
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 58                	js     801738 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e0:	83 ec 08             	sub    $0x8,%esp
  8016e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e6:	50                   	push   %eax
  8016e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ea:	ff 30                	pushl  (%eax)
  8016ec:	e8 a8 fb ff ff       	call   801299 <dev_lookup>
  8016f1:	83 c4 10             	add    $0x10,%esp
  8016f4:	85 c0                	test   %eax,%eax
  8016f6:	78 37                	js     80172f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016fb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016ff:	74 32                	je     801733 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801701:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801704:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80170b:	00 00 00 
	stat->st_isdir = 0;
  80170e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801715:	00 00 00 
	stat->st_dev = dev;
  801718:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80171e:	83 ec 08             	sub    $0x8,%esp
  801721:	53                   	push   %ebx
  801722:	ff 75 f0             	pushl  -0x10(%ebp)
  801725:	ff 50 14             	call   *0x14(%eax)
  801728:	89 c2                	mov    %eax,%edx
  80172a:	83 c4 10             	add    $0x10,%esp
  80172d:	eb 09                	jmp    801738 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172f:	89 c2                	mov    %eax,%edx
  801731:	eb 05                	jmp    801738 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801733:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801738:	89 d0                	mov    %edx,%eax
  80173a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173d:	c9                   	leave  
  80173e:	c3                   	ret    

0080173f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	56                   	push   %esi
  801743:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801744:	83 ec 08             	sub    $0x8,%esp
  801747:	6a 00                	push   $0x0
  801749:	ff 75 08             	pushl  0x8(%ebp)
  80174c:	e8 2b 02 00 00       	call   80197c <open>
  801751:	89 c3                	mov    %eax,%ebx
  801753:	83 c4 10             	add    $0x10,%esp
  801756:	85 c0                	test   %eax,%eax
  801758:	78 1b                	js     801775 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80175a:	83 ec 08             	sub    $0x8,%esp
  80175d:	ff 75 0c             	pushl  0xc(%ebp)
  801760:	50                   	push   %eax
  801761:	e8 5b ff ff ff       	call   8016c1 <fstat>
  801766:	89 c6                	mov    %eax,%esi
	close(fd);
  801768:	89 1c 24             	mov    %ebx,(%esp)
  80176b:	e8 fd fb ff ff       	call   80136d <close>
	return r;
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	89 f0                	mov    %esi,%eax
}
  801775:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801778:	5b                   	pop    %ebx
  801779:	5e                   	pop    %esi
  80177a:	5d                   	pop    %ebp
  80177b:	c3                   	ret    

0080177c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	56                   	push   %esi
  801780:	53                   	push   %ebx
  801781:	89 c6                	mov    %eax,%esi
  801783:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801785:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80178c:	75 12                	jne    8017a0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80178e:	83 ec 0c             	sub    $0xc,%esp
  801791:	6a 01                	push   $0x1
  801793:	e8 b5 08 00 00       	call   80204d <ipc_find_env>
  801798:	a3 04 40 80 00       	mov    %eax,0x804004
  80179d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017a0:	6a 07                	push   $0x7
  8017a2:	68 00 50 80 00       	push   $0x805000
  8017a7:	56                   	push   %esi
  8017a8:	ff 35 04 40 80 00    	pushl  0x804004
  8017ae:	e8 44 08 00 00       	call   801ff7 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8017b3:	83 c4 0c             	add    $0xc,%esp
  8017b6:	6a 00                	push   $0x0
  8017b8:	53                   	push   %ebx
  8017b9:	6a 00                	push   $0x0
  8017bb:	e8 ce 07 00 00       	call   801f8e <ipc_recv>
}
  8017c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c3:	5b                   	pop    %ebx
  8017c4:	5e                   	pop    %esi
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    

008017c7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017db:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e5:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ea:	e8 8d ff ff ff       	call   80177c <fsipc>
}
  8017ef:	c9                   	leave  
  8017f0:	c3                   	ret    

008017f1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8017fd:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801802:	ba 00 00 00 00       	mov    $0x0,%edx
  801807:	b8 06 00 00 00       	mov    $0x6,%eax
  80180c:	e8 6b ff ff ff       	call   80177c <fsipc>
}
  801811:	c9                   	leave  
  801812:	c3                   	ret    

00801813 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	53                   	push   %ebx
  801817:	83 ec 04             	sub    $0x4,%esp
  80181a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80181d:	8b 45 08             	mov    0x8(%ebp),%eax
  801820:	8b 40 0c             	mov    0xc(%eax),%eax
  801823:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801828:	ba 00 00 00 00       	mov    $0x0,%edx
  80182d:	b8 05 00 00 00       	mov    $0x5,%eax
  801832:	e8 45 ff ff ff       	call   80177c <fsipc>
  801837:	85 c0                	test   %eax,%eax
  801839:	78 2c                	js     801867 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80183b:	83 ec 08             	sub    $0x8,%esp
  80183e:	68 00 50 80 00       	push   $0x805000
  801843:	53                   	push   %ebx
  801844:	e8 11 f0 ff ff       	call   80085a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801849:	a1 80 50 80 00       	mov    0x805080,%eax
  80184e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801854:	a1 84 50 80 00       	mov    0x805084,%eax
  801859:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186a:	c9                   	leave  
  80186b:	c3                   	ret    

0080186c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	53                   	push   %ebx
  801870:	83 ec 08             	sub    $0x8,%esp
  801873:	8b 45 10             	mov    0x10(%ebp),%eax
  801876:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80187b:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801880:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801883:	8b 45 08             	mov    0x8(%ebp),%eax
  801886:	8b 40 0c             	mov    0xc(%eax),%eax
  801889:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  80188e:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801894:	53                   	push   %ebx
  801895:	ff 75 0c             	pushl  0xc(%ebp)
  801898:	68 08 50 80 00       	push   $0x805008
  80189d:	e8 4a f1 ff ff       	call   8009ec <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8018a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8018ac:	e8 cb fe ff ff       	call   80177c <fsipc>
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	78 3d                	js     8018f5 <devfile_write+0x89>
		return r;

	assert(r <= n);
  8018b8:	39 d8                	cmp    %ebx,%eax
  8018ba:	76 19                	jbe    8018d5 <devfile_write+0x69>
  8018bc:	68 4c 28 80 00       	push   $0x80284c
  8018c1:	68 53 28 80 00       	push   $0x802853
  8018c6:	68 9f 00 00 00       	push   $0x9f
  8018cb:	68 68 28 80 00       	push   $0x802868
  8018d0:	e8 78 e8 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  8018d5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018da:	76 19                	jbe    8018f5 <devfile_write+0x89>
  8018dc:	68 80 28 80 00       	push   $0x802880
  8018e1:	68 53 28 80 00       	push   $0x802853
  8018e6:	68 a0 00 00 00       	push   $0xa0
  8018eb:	68 68 28 80 00       	push   $0x802868
  8018f0:	e8 58 e8 ff ff       	call   80014d <_panic>

	return r;
}
  8018f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f8:	c9                   	leave  
  8018f9:	c3                   	ret    

008018fa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	56                   	push   %esi
  8018fe:	53                   	push   %ebx
  8018ff:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801902:	8b 45 08             	mov    0x8(%ebp),%eax
  801905:	8b 40 0c             	mov    0xc(%eax),%eax
  801908:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80190d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801913:	ba 00 00 00 00       	mov    $0x0,%edx
  801918:	b8 03 00 00 00       	mov    $0x3,%eax
  80191d:	e8 5a fe ff ff       	call   80177c <fsipc>
  801922:	89 c3                	mov    %eax,%ebx
  801924:	85 c0                	test   %eax,%eax
  801926:	78 4b                	js     801973 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801928:	39 c6                	cmp    %eax,%esi
  80192a:	73 16                	jae    801942 <devfile_read+0x48>
  80192c:	68 4c 28 80 00       	push   $0x80284c
  801931:	68 53 28 80 00       	push   $0x802853
  801936:	6a 7e                	push   $0x7e
  801938:	68 68 28 80 00       	push   $0x802868
  80193d:	e8 0b e8 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  801942:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801947:	7e 16                	jle    80195f <devfile_read+0x65>
  801949:	68 73 28 80 00       	push   $0x802873
  80194e:	68 53 28 80 00       	push   $0x802853
  801953:	6a 7f                	push   $0x7f
  801955:	68 68 28 80 00       	push   $0x802868
  80195a:	e8 ee e7 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80195f:	83 ec 04             	sub    $0x4,%esp
  801962:	50                   	push   %eax
  801963:	68 00 50 80 00       	push   $0x805000
  801968:	ff 75 0c             	pushl  0xc(%ebp)
  80196b:	e8 7c f0 ff ff       	call   8009ec <memmove>
	return r;
  801970:	83 c4 10             	add    $0x10,%esp
}
  801973:	89 d8                	mov    %ebx,%eax
  801975:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801978:	5b                   	pop    %ebx
  801979:	5e                   	pop    %esi
  80197a:	5d                   	pop    %ebp
  80197b:	c3                   	ret    

0080197c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	53                   	push   %ebx
  801980:	83 ec 20             	sub    $0x20,%esp
  801983:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801986:	53                   	push   %ebx
  801987:	e8 95 ee ff ff       	call   800821 <strlen>
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801994:	7f 67                	jg     8019fd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801996:	83 ec 0c             	sub    $0xc,%esp
  801999:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199c:	50                   	push   %eax
  80199d:	e8 52 f8 ff ff       	call   8011f4 <fd_alloc>
  8019a2:	83 c4 10             	add    $0x10,%esp
		return r;
  8019a5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 57                	js     801a02 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019ab:	83 ec 08             	sub    $0x8,%esp
  8019ae:	53                   	push   %ebx
  8019af:	68 00 50 80 00       	push   $0x805000
  8019b4:	e8 a1 ee ff ff       	call   80085a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019bc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c9:	e8 ae fd ff ff       	call   80177c <fsipc>
  8019ce:	89 c3                	mov    %eax,%ebx
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	79 14                	jns    8019eb <open+0x6f>
		fd_close(fd, 0);
  8019d7:	83 ec 08             	sub    $0x8,%esp
  8019da:	6a 00                	push   $0x0
  8019dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8019df:	e8 08 f9 ff ff       	call   8012ec <fd_close>
		return r;
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	89 da                	mov    %ebx,%edx
  8019e9:	eb 17                	jmp    801a02 <open+0x86>
	}

	return fd2num(fd);
  8019eb:	83 ec 0c             	sub    $0xc,%esp
  8019ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f1:	e8 d7 f7 ff ff       	call   8011cd <fd2num>
  8019f6:	89 c2                	mov    %eax,%edx
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	eb 05                	jmp    801a02 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019fd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a02:	89 d0                	mov    %edx,%eax
  801a04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a07:	c9                   	leave  
  801a08:	c3                   	ret    

00801a09 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a14:	b8 08 00 00 00       	mov    $0x8,%eax
  801a19:	e8 5e fd ff ff       	call   80177c <fsipc>
}
  801a1e:	c9                   	leave  
  801a1f:	c3                   	ret    

00801a20 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	56                   	push   %esi
  801a24:	53                   	push   %ebx
  801a25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a28:	83 ec 0c             	sub    $0xc,%esp
  801a2b:	ff 75 08             	pushl  0x8(%ebp)
  801a2e:	e8 aa f7 ff ff       	call   8011dd <fd2data>
  801a33:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a35:	83 c4 08             	add    $0x8,%esp
  801a38:	68 ad 28 80 00       	push   $0x8028ad
  801a3d:	53                   	push   %ebx
  801a3e:	e8 17 ee ff ff       	call   80085a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a43:	8b 46 04             	mov    0x4(%esi),%eax
  801a46:	2b 06                	sub    (%esi),%eax
  801a48:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a4e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a55:	00 00 00 
	stat->st_dev = &devpipe;
  801a58:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a5f:	30 80 00 
	return 0;
}
  801a62:	b8 00 00 00 00       	mov    $0x0,%eax
  801a67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6a:	5b                   	pop    %ebx
  801a6b:	5e                   	pop    %esi
  801a6c:	5d                   	pop    %ebp
  801a6d:	c3                   	ret    

00801a6e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	53                   	push   %ebx
  801a72:	83 ec 0c             	sub    $0xc,%esp
  801a75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a78:	53                   	push   %ebx
  801a79:	6a 00                	push   $0x0
  801a7b:	e8 d9 f2 ff ff       	call   800d59 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a80:	89 1c 24             	mov    %ebx,(%esp)
  801a83:	e8 55 f7 ff ff       	call   8011dd <fd2data>
  801a88:	83 c4 08             	add    $0x8,%esp
  801a8b:	50                   	push   %eax
  801a8c:	6a 00                	push   $0x0
  801a8e:	e8 c6 f2 ff ff       	call   800d59 <sys_page_unmap>
}
  801a93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a96:	c9                   	leave  
  801a97:	c3                   	ret    

00801a98 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	57                   	push   %edi
  801a9c:	56                   	push   %esi
  801a9d:	53                   	push   %ebx
  801a9e:	83 ec 1c             	sub    $0x1c,%esp
  801aa1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aa4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aa6:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801aab:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801aae:	83 ec 0c             	sub    $0xc,%esp
  801ab1:	ff 75 e0             	pushl  -0x20(%ebp)
  801ab4:	e8 cd 05 00 00       	call   802086 <pageref>
  801ab9:	89 c3                	mov    %eax,%ebx
  801abb:	89 3c 24             	mov    %edi,(%esp)
  801abe:	e8 c3 05 00 00       	call   802086 <pageref>
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	39 c3                	cmp    %eax,%ebx
  801ac8:	0f 94 c1             	sete   %cl
  801acb:	0f b6 c9             	movzbl %cl,%ecx
  801ace:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ad1:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801ad7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ada:	39 ce                	cmp    %ecx,%esi
  801adc:	74 1b                	je     801af9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ade:	39 c3                	cmp    %eax,%ebx
  801ae0:	75 c4                	jne    801aa6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ae2:	8b 42 58             	mov    0x58(%edx),%eax
  801ae5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ae8:	50                   	push   %eax
  801ae9:	56                   	push   %esi
  801aea:	68 b4 28 80 00       	push   $0x8028b4
  801aef:	e8 32 e7 ff ff       	call   800226 <cprintf>
  801af4:	83 c4 10             	add    $0x10,%esp
  801af7:	eb ad                	jmp    801aa6 <_pipeisclosed+0xe>
	}
}
  801af9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801afc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aff:	5b                   	pop    %ebx
  801b00:	5e                   	pop    %esi
  801b01:	5f                   	pop    %edi
  801b02:	5d                   	pop    %ebp
  801b03:	c3                   	ret    

00801b04 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	57                   	push   %edi
  801b08:	56                   	push   %esi
  801b09:	53                   	push   %ebx
  801b0a:	83 ec 28             	sub    $0x28,%esp
  801b0d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b10:	56                   	push   %esi
  801b11:	e8 c7 f6 ff ff       	call   8011dd <fd2data>
  801b16:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	bf 00 00 00 00       	mov    $0x0,%edi
  801b20:	eb 4b                	jmp    801b6d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b22:	89 da                	mov    %ebx,%edx
  801b24:	89 f0                	mov    %esi,%eax
  801b26:	e8 6d ff ff ff       	call   801a98 <_pipeisclosed>
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	75 48                	jne    801b77 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b2f:	e8 81 f1 ff ff       	call   800cb5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b34:	8b 43 04             	mov    0x4(%ebx),%eax
  801b37:	8b 0b                	mov    (%ebx),%ecx
  801b39:	8d 51 20             	lea    0x20(%ecx),%edx
  801b3c:	39 d0                	cmp    %edx,%eax
  801b3e:	73 e2                	jae    801b22 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b43:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b47:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b4a:	89 c2                	mov    %eax,%edx
  801b4c:	c1 fa 1f             	sar    $0x1f,%edx
  801b4f:	89 d1                	mov    %edx,%ecx
  801b51:	c1 e9 1b             	shr    $0x1b,%ecx
  801b54:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b57:	83 e2 1f             	and    $0x1f,%edx
  801b5a:	29 ca                	sub    %ecx,%edx
  801b5c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b60:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b64:	83 c0 01             	add    $0x1,%eax
  801b67:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6a:	83 c7 01             	add    $0x1,%edi
  801b6d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b70:	75 c2                	jne    801b34 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b72:	8b 45 10             	mov    0x10(%ebp),%eax
  801b75:	eb 05                	jmp    801b7c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b77:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7f:	5b                   	pop    %ebx
  801b80:	5e                   	pop    %esi
  801b81:	5f                   	pop    %edi
  801b82:	5d                   	pop    %ebp
  801b83:	c3                   	ret    

00801b84 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	57                   	push   %edi
  801b88:	56                   	push   %esi
  801b89:	53                   	push   %ebx
  801b8a:	83 ec 18             	sub    $0x18,%esp
  801b8d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b90:	57                   	push   %edi
  801b91:	e8 47 f6 ff ff       	call   8011dd <fd2data>
  801b96:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ba0:	eb 3d                	jmp    801bdf <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ba2:	85 db                	test   %ebx,%ebx
  801ba4:	74 04                	je     801baa <devpipe_read+0x26>
				return i;
  801ba6:	89 d8                	mov    %ebx,%eax
  801ba8:	eb 44                	jmp    801bee <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801baa:	89 f2                	mov    %esi,%edx
  801bac:	89 f8                	mov    %edi,%eax
  801bae:	e8 e5 fe ff ff       	call   801a98 <_pipeisclosed>
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	75 32                	jne    801be9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bb7:	e8 f9 f0 ff ff       	call   800cb5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bbc:	8b 06                	mov    (%esi),%eax
  801bbe:	3b 46 04             	cmp    0x4(%esi),%eax
  801bc1:	74 df                	je     801ba2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bc3:	99                   	cltd   
  801bc4:	c1 ea 1b             	shr    $0x1b,%edx
  801bc7:	01 d0                	add    %edx,%eax
  801bc9:	83 e0 1f             	and    $0x1f,%eax
  801bcc:	29 d0                	sub    %edx,%eax
  801bce:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bd9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bdc:	83 c3 01             	add    $0x1,%ebx
  801bdf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801be2:	75 d8                	jne    801bbc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801be4:	8b 45 10             	mov    0x10(%ebp),%eax
  801be7:	eb 05                	jmp    801bee <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801be9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf1:	5b                   	pop    %ebx
  801bf2:	5e                   	pop    %esi
  801bf3:	5f                   	pop    %edi
  801bf4:	5d                   	pop    %ebp
  801bf5:	c3                   	ret    

00801bf6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	56                   	push   %esi
  801bfa:	53                   	push   %ebx
  801bfb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bfe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c01:	50                   	push   %eax
  801c02:	e8 ed f5 ff ff       	call   8011f4 <fd_alloc>
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	89 c2                	mov    %eax,%edx
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	0f 88 2c 01 00 00    	js     801d40 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c14:	83 ec 04             	sub    $0x4,%esp
  801c17:	68 07 04 00 00       	push   $0x407
  801c1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1f:	6a 00                	push   $0x0
  801c21:	e8 ae f0 ff ff       	call   800cd4 <sys_page_alloc>
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	89 c2                	mov    %eax,%edx
  801c2b:	85 c0                	test   %eax,%eax
  801c2d:	0f 88 0d 01 00 00    	js     801d40 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c33:	83 ec 0c             	sub    $0xc,%esp
  801c36:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c39:	50                   	push   %eax
  801c3a:	e8 b5 f5 ff ff       	call   8011f4 <fd_alloc>
  801c3f:	89 c3                	mov    %eax,%ebx
  801c41:	83 c4 10             	add    $0x10,%esp
  801c44:	85 c0                	test   %eax,%eax
  801c46:	0f 88 e2 00 00 00    	js     801d2e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4c:	83 ec 04             	sub    $0x4,%esp
  801c4f:	68 07 04 00 00       	push   $0x407
  801c54:	ff 75 f0             	pushl  -0x10(%ebp)
  801c57:	6a 00                	push   $0x0
  801c59:	e8 76 f0 ff ff       	call   800cd4 <sys_page_alloc>
  801c5e:	89 c3                	mov    %eax,%ebx
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	85 c0                	test   %eax,%eax
  801c65:	0f 88 c3 00 00 00    	js     801d2e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c6b:	83 ec 0c             	sub    $0xc,%esp
  801c6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c71:	e8 67 f5 ff ff       	call   8011dd <fd2data>
  801c76:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c78:	83 c4 0c             	add    $0xc,%esp
  801c7b:	68 07 04 00 00       	push   $0x407
  801c80:	50                   	push   %eax
  801c81:	6a 00                	push   $0x0
  801c83:	e8 4c f0 ff ff       	call   800cd4 <sys_page_alloc>
  801c88:	89 c3                	mov    %eax,%ebx
  801c8a:	83 c4 10             	add    $0x10,%esp
  801c8d:	85 c0                	test   %eax,%eax
  801c8f:	0f 88 89 00 00 00    	js     801d1e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c95:	83 ec 0c             	sub    $0xc,%esp
  801c98:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9b:	e8 3d f5 ff ff       	call   8011dd <fd2data>
  801ca0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ca7:	50                   	push   %eax
  801ca8:	6a 00                	push   $0x0
  801caa:	56                   	push   %esi
  801cab:	6a 00                	push   $0x0
  801cad:	e8 65 f0 ff ff       	call   800d17 <sys_page_map>
  801cb2:	89 c3                	mov    %eax,%ebx
  801cb4:	83 c4 20             	add    $0x20,%esp
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	78 55                	js     801d10 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cbb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cd0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cde:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ce5:	83 ec 0c             	sub    $0xc,%esp
  801ce8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ceb:	e8 dd f4 ff ff       	call   8011cd <fd2num>
  801cf0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cf5:	83 c4 04             	add    $0x4,%esp
  801cf8:	ff 75 f0             	pushl  -0x10(%ebp)
  801cfb:	e8 cd f4 ff ff       	call   8011cd <fd2num>
  801d00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d03:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d06:	83 c4 10             	add    $0x10,%esp
  801d09:	ba 00 00 00 00       	mov    $0x0,%edx
  801d0e:	eb 30                	jmp    801d40 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d10:	83 ec 08             	sub    $0x8,%esp
  801d13:	56                   	push   %esi
  801d14:	6a 00                	push   $0x0
  801d16:	e8 3e f0 ff ff       	call   800d59 <sys_page_unmap>
  801d1b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d1e:	83 ec 08             	sub    $0x8,%esp
  801d21:	ff 75 f0             	pushl  -0x10(%ebp)
  801d24:	6a 00                	push   $0x0
  801d26:	e8 2e f0 ff ff       	call   800d59 <sys_page_unmap>
  801d2b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d2e:	83 ec 08             	sub    $0x8,%esp
  801d31:	ff 75 f4             	pushl  -0xc(%ebp)
  801d34:	6a 00                	push   $0x0
  801d36:	e8 1e f0 ff ff       	call   800d59 <sys_page_unmap>
  801d3b:	83 c4 10             	add    $0x10,%esp
  801d3e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d40:	89 d0                	mov    %edx,%eax
  801d42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d45:	5b                   	pop    %ebx
  801d46:	5e                   	pop    %esi
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    

00801d49 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d52:	50                   	push   %eax
  801d53:	ff 75 08             	pushl  0x8(%ebp)
  801d56:	e8 e8 f4 ff ff       	call   801243 <fd_lookup>
  801d5b:	83 c4 10             	add    $0x10,%esp
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	78 18                	js     801d7a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d62:	83 ec 0c             	sub    $0xc,%esp
  801d65:	ff 75 f4             	pushl  -0xc(%ebp)
  801d68:	e8 70 f4 ff ff       	call   8011dd <fd2data>
	return _pipeisclosed(fd, p);
  801d6d:	89 c2                	mov    %eax,%edx
  801d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d72:	e8 21 fd ff ff       	call   801a98 <_pipeisclosed>
  801d77:	83 c4 10             	add    $0x10,%esp
}
  801d7a:	c9                   	leave  
  801d7b:	c3                   	ret    

00801d7c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d7f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d84:	5d                   	pop    %ebp
  801d85:	c3                   	ret    

00801d86 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d8c:	68 cc 28 80 00       	push   $0x8028cc
  801d91:	ff 75 0c             	pushl  0xc(%ebp)
  801d94:	e8 c1 ea ff ff       	call   80085a <strcpy>
	return 0;
}
  801d99:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9e:	c9                   	leave  
  801d9f:	c3                   	ret    

00801da0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	57                   	push   %edi
  801da4:	56                   	push   %esi
  801da5:	53                   	push   %ebx
  801da6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dac:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801db1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db7:	eb 2d                	jmp    801de6 <devcons_write+0x46>
		m = n - tot;
  801db9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dbc:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dbe:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dc1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dc6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dc9:	83 ec 04             	sub    $0x4,%esp
  801dcc:	53                   	push   %ebx
  801dcd:	03 45 0c             	add    0xc(%ebp),%eax
  801dd0:	50                   	push   %eax
  801dd1:	57                   	push   %edi
  801dd2:	e8 15 ec ff ff       	call   8009ec <memmove>
		sys_cputs(buf, m);
  801dd7:	83 c4 08             	add    $0x8,%esp
  801dda:	53                   	push   %ebx
  801ddb:	57                   	push   %edi
  801ddc:	e8 37 ee ff ff       	call   800c18 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801de1:	01 de                	add    %ebx,%esi
  801de3:	83 c4 10             	add    $0x10,%esp
  801de6:	89 f0                	mov    %esi,%eax
  801de8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801deb:	72 cc                	jb     801db9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ded:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df0:	5b                   	pop    %ebx
  801df1:	5e                   	pop    %esi
  801df2:	5f                   	pop    %edi
  801df3:	5d                   	pop    %ebp
  801df4:	c3                   	ret    

00801df5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	83 ec 08             	sub    $0x8,%esp
  801dfb:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e00:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e04:	74 2a                	je     801e30 <devcons_read+0x3b>
  801e06:	eb 05                	jmp    801e0d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e08:	e8 a8 ee ff ff       	call   800cb5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e0d:	e8 24 ee ff ff       	call   800c36 <sys_cgetc>
  801e12:	85 c0                	test   %eax,%eax
  801e14:	74 f2                	je     801e08 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e16:	85 c0                	test   %eax,%eax
  801e18:	78 16                	js     801e30 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e1a:	83 f8 04             	cmp    $0x4,%eax
  801e1d:	74 0c                	je     801e2b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e22:	88 02                	mov    %al,(%edx)
	return 1;
  801e24:	b8 01 00 00 00       	mov    $0x1,%eax
  801e29:	eb 05                	jmp    801e30 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e2b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e30:	c9                   	leave  
  801e31:	c3                   	ret    

00801e32 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e38:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e3e:	6a 01                	push   $0x1
  801e40:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e43:	50                   	push   %eax
  801e44:	e8 cf ed ff ff       	call   800c18 <sys_cputs>
}
  801e49:	83 c4 10             	add    $0x10,%esp
  801e4c:	c9                   	leave  
  801e4d:	c3                   	ret    

00801e4e <getchar>:

int
getchar(void)
{
  801e4e:	55                   	push   %ebp
  801e4f:	89 e5                	mov    %esp,%ebp
  801e51:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e54:	6a 01                	push   $0x1
  801e56:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e59:	50                   	push   %eax
  801e5a:	6a 00                	push   $0x0
  801e5c:	e8 48 f6 ff ff       	call   8014a9 <read>
	if (r < 0)
  801e61:	83 c4 10             	add    $0x10,%esp
  801e64:	85 c0                	test   %eax,%eax
  801e66:	78 0f                	js     801e77 <getchar+0x29>
		return r;
	if (r < 1)
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	7e 06                	jle    801e72 <getchar+0x24>
		return -E_EOF;
	return c;
  801e6c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e70:	eb 05                	jmp    801e77 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e72:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e77:	c9                   	leave  
  801e78:	c3                   	ret    

00801e79 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e82:	50                   	push   %eax
  801e83:	ff 75 08             	pushl  0x8(%ebp)
  801e86:	e8 b8 f3 ff ff       	call   801243 <fd_lookup>
  801e8b:	83 c4 10             	add    $0x10,%esp
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	78 11                	js     801ea3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e95:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e9b:	39 10                	cmp    %edx,(%eax)
  801e9d:	0f 94 c0             	sete   %al
  801ea0:	0f b6 c0             	movzbl %al,%eax
}
  801ea3:	c9                   	leave  
  801ea4:	c3                   	ret    

00801ea5 <opencons>:

int
opencons(void)
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eae:	50                   	push   %eax
  801eaf:	e8 40 f3 ff ff       	call   8011f4 <fd_alloc>
  801eb4:	83 c4 10             	add    $0x10,%esp
		return r;
  801eb7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eb9:	85 c0                	test   %eax,%eax
  801ebb:	78 3e                	js     801efb <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ebd:	83 ec 04             	sub    $0x4,%esp
  801ec0:	68 07 04 00 00       	push   $0x407
  801ec5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec8:	6a 00                	push   $0x0
  801eca:	e8 05 ee ff ff       	call   800cd4 <sys_page_alloc>
  801ecf:	83 c4 10             	add    $0x10,%esp
		return r;
  801ed2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	78 23                	js     801efb <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ed8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eed:	83 ec 0c             	sub    $0xc,%esp
  801ef0:	50                   	push   %eax
  801ef1:	e8 d7 f2 ff ff       	call   8011cd <fd2num>
  801ef6:	89 c2                	mov    %eax,%edx
  801ef8:	83 c4 10             	add    $0x10,%esp
}
  801efb:	89 d0                	mov    %edx,%eax
  801efd:	c9                   	leave  
  801efe:	c3                   	ret    

00801eff <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eff:	55                   	push   %ebp
  801f00:	89 e5                	mov    %esp,%ebp
  801f02:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801f05:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f0c:	75 52                	jne    801f60 <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  801f0e:	83 ec 04             	sub    $0x4,%esp
  801f11:	6a 07                	push   $0x7
  801f13:	68 00 f0 bf ee       	push   $0xeebff000
  801f18:	6a 00                	push   $0x0
  801f1a:	e8 b5 ed ff ff       	call   800cd4 <sys_page_alloc>
  801f1f:	83 c4 10             	add    $0x10,%esp
  801f22:	85 c0                	test   %eax,%eax
  801f24:	79 12                	jns    801f38 <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  801f26:	50                   	push   %eax
  801f27:	68 20 27 80 00       	push   $0x802720
  801f2c:	6a 23                	push   $0x23
  801f2e:	68 d8 28 80 00       	push   $0x8028d8
  801f33:	e8 15 e2 ff ff       	call   80014d <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  801f38:	83 ec 08             	sub    $0x8,%esp
  801f3b:	68 6a 1f 80 00       	push   $0x801f6a
  801f40:	6a 00                	push   $0x0
  801f42:	e8 d8 ee ff ff       	call   800e1f <sys_env_set_pgfault_upcall>
  801f47:	83 c4 10             	add    $0x10,%esp
  801f4a:	85 c0                	test   %eax,%eax
  801f4c:	79 12                	jns    801f60 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  801f4e:	50                   	push   %eax
  801f4f:	68 a0 27 80 00       	push   $0x8027a0
  801f54:	6a 26                	push   $0x26
  801f56:	68 d8 28 80 00       	push   $0x8028d8
  801f5b:	e8 ed e1 ff ff       	call   80014d <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f60:	8b 45 08             	mov    0x8(%ebp),%eax
  801f63:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f68:	c9                   	leave  
  801f69:	c3                   	ret    

00801f6a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f6a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f6b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f70:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f72:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  801f75:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  801f79:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  801f7e:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  801f82:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801f84:	83 c4 08             	add    $0x8,%esp
	popal 
  801f87:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801f88:	83 c4 04             	add    $0x4,%esp
	popfl
  801f8b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f8c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f8d:	c3                   	ret    

00801f8e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	56                   	push   %esi
  801f92:	53                   	push   %ebx
  801f93:	8b 75 08             	mov    0x8(%ebp),%esi
  801f96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801f9c:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f9e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fa3:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801fa6:	83 ec 0c             	sub    $0xc,%esp
  801fa9:	50                   	push   %eax
  801faa:	e8 d5 ee ff ff       	call   800e84 <sys_ipc_recv>
  801faf:	83 c4 10             	add    $0x10,%esp
  801fb2:	85 c0                	test   %eax,%eax
  801fb4:	79 16                	jns    801fcc <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801fb6:	85 f6                	test   %esi,%esi
  801fb8:	74 06                	je     801fc0 <ipc_recv+0x32>
			*from_env_store = 0;
  801fba:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801fc0:	85 db                	test   %ebx,%ebx
  801fc2:	74 2c                	je     801ff0 <ipc_recv+0x62>
			*perm_store = 0;
  801fc4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801fca:	eb 24                	jmp    801ff0 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801fcc:	85 f6                	test   %esi,%esi
  801fce:	74 0a                	je     801fda <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801fd0:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801fd5:	8b 40 74             	mov    0x74(%eax),%eax
  801fd8:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801fda:	85 db                	test   %ebx,%ebx
  801fdc:	74 0a                	je     801fe8 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801fde:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801fe3:	8b 40 78             	mov    0x78(%eax),%eax
  801fe6:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801fe8:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801fed:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ff0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ff3:	5b                   	pop    %ebx
  801ff4:	5e                   	pop    %esi
  801ff5:	5d                   	pop    %ebp
  801ff6:	c3                   	ret    

00801ff7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ff7:	55                   	push   %ebp
  801ff8:	89 e5                	mov    %esp,%ebp
  801ffa:	57                   	push   %edi
  801ffb:	56                   	push   %esi
  801ffc:	53                   	push   %ebx
  801ffd:	83 ec 0c             	sub    $0xc,%esp
  802000:	8b 7d 08             	mov    0x8(%ebp),%edi
  802003:	8b 75 0c             	mov    0xc(%ebp),%esi
  802006:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  802009:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80200b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802010:	0f 44 d8             	cmove  %eax,%ebx
  802013:	eb 1e                	jmp    802033 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  802015:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802018:	74 14                	je     80202e <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  80201a:	83 ec 04             	sub    $0x4,%esp
  80201d:	68 e8 28 80 00       	push   $0x8028e8
  802022:	6a 44                	push   $0x44
  802024:	68 14 29 80 00       	push   $0x802914
  802029:	e8 1f e1 ff ff       	call   80014d <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  80202e:	e8 82 ec ff ff       	call   800cb5 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802033:	ff 75 14             	pushl  0x14(%ebp)
  802036:	53                   	push   %ebx
  802037:	56                   	push   %esi
  802038:	57                   	push   %edi
  802039:	e8 23 ee ff ff       	call   800e61 <sys_ipc_try_send>
  80203e:	83 c4 10             	add    $0x10,%esp
  802041:	85 c0                	test   %eax,%eax
  802043:	78 d0                	js     802015 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  802045:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802048:	5b                   	pop    %ebx
  802049:	5e                   	pop    %esi
  80204a:	5f                   	pop    %edi
  80204b:	5d                   	pop    %ebp
  80204c:	c3                   	ret    

0080204d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80204d:	55                   	push   %ebp
  80204e:	89 e5                	mov    %esp,%ebp
  802050:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802053:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802058:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80205b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802061:	8b 52 50             	mov    0x50(%edx),%edx
  802064:	39 ca                	cmp    %ecx,%edx
  802066:	75 0d                	jne    802075 <ipc_find_env+0x28>
			return envs[i].env_id;
  802068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80206b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802070:	8b 40 48             	mov    0x48(%eax),%eax
  802073:	eb 0f                	jmp    802084 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802075:	83 c0 01             	add    $0x1,%eax
  802078:	3d 00 04 00 00       	cmp    $0x400,%eax
  80207d:	75 d9                	jne    802058 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80207f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802084:	5d                   	pop    %ebp
  802085:	c3                   	ret    

00802086 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80208c:	89 d0                	mov    %edx,%eax
  80208e:	c1 e8 16             	shr    $0x16,%eax
  802091:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802098:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80209d:	f6 c1 01             	test   $0x1,%cl
  8020a0:	74 1d                	je     8020bf <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020a2:	c1 ea 0c             	shr    $0xc,%edx
  8020a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020ac:	f6 c2 01             	test   $0x1,%dl
  8020af:	74 0e                	je     8020bf <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020b1:	c1 ea 0c             	shr    $0xc,%edx
  8020b4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020bb:	ef 
  8020bc:	0f b7 c0             	movzwl %ax,%eax
}
  8020bf:	5d                   	pop    %ebp
  8020c0:	c3                   	ret    
  8020c1:	66 90                	xchg   %ax,%ax
  8020c3:	66 90                	xchg   %ax,%ax
  8020c5:	66 90                	xchg   %ax,%ax
  8020c7:	66 90                	xchg   %ax,%ax
  8020c9:	66 90                	xchg   %ax,%ax
  8020cb:	66 90                	xchg   %ax,%ax
  8020cd:	66 90                	xchg   %ax,%ax
  8020cf:	90                   	nop

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
