
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 c0 1f 80 00       	push   $0x801fc0
  80003e:	e8 d2 01 00 00       	call   800215 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 3b 20 80 00       	push   $0x80203b
  80005b:	6a 11                	push   $0x11
  80005d:	68 58 20 80 00       	push   $0x802058
  800062:	e8 d5 00 00 00       	call   80013c <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800067:	83 c0 01             	add    $0x1,%eax
  80006a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006f:	75 da                	jne    80004b <umain+0x18>
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800076:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 ef                	jne    800076 <umain+0x43>
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  80008c:	3b 04 85 20 40 80 00 	cmp    0x804020(,%eax,4),%eax
  800093:	74 12                	je     8000a7 <umain+0x74>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800095:	50                   	push   %eax
  800096:	68 e0 1f 80 00       	push   $0x801fe0
  80009b:	6a 16                	push   $0x16
  80009d:	68 58 20 80 00       	push   $0x802058
  8000a2:	e8 95 00 00 00       	call   80013c <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a7:	83 c0 01             	add    $0x1,%eax
  8000aa:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000af:	75 db                	jne    80008c <umain+0x59>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 08 20 80 00       	push   $0x802008
  8000b9:	e8 57 01 00 00       	call   800215 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 67 20 80 00       	push   $0x802067
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 58 20 80 00       	push   $0x802058
  8000d7:	e8 60 00 00 00       	call   80013c <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000e7:	e8 99 0b 00 00       	call   800c85 <sys_getenvid>
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f9:	a3 20 40 c0 00       	mov    %eax,0xc04020
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fe:	85 db                	test   %ebx,%ebx
  800100:	7e 07                	jle    800109 <libmain+0x2d>
		binaryname = argv[0];
  800102:	8b 06                	mov    (%esi),%eax
  800104:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	e8 20 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800113:	e8 0a 00 00 00       	call   800122 <exit>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800128:	e8 52 0f 00 00       	call   80107f <close_all>
	sys_env_destroy(0);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	6a 00                	push   $0x0
  800132:	e8 0d 0b 00 00       	call   800c44 <sys_env_destroy>
}
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800141:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800144:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80014a:	e8 36 0b 00 00       	call   800c85 <sys_getenvid>
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 75 0c             	pushl  0xc(%ebp)
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	56                   	push   %esi
  800159:	50                   	push   %eax
  80015a:	68 88 20 80 00       	push   $0x802088
  80015f:	e8 b1 00 00 00       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	pushl  0x10(%ebp)
  80016b:	e8 54 00 00 00       	call   8001c4 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 56 20 80 00 	movl   $0x802056,(%esp)
  800177:	e8 99 00 00 00       	call   800215 <cprintf>
  80017c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017f:	cc                   	int3   
  800180:	eb fd                	jmp    80017f <_panic+0x43>

00800182 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	53                   	push   %ebx
  800186:	83 ec 04             	sub    $0x4,%esp
  800189:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018c:	8b 13                	mov    (%ebx),%edx
  80018e:	8d 42 01             	lea    0x1(%edx),%eax
  800191:	89 03                	mov    %eax,(%ebx)
  800193:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800196:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019f:	75 1a                	jne    8001bb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	68 ff 00 00 00       	push   $0xff
  8001a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 55 0a 00 00       	call   800c07 <sys_cputs>
		b->idx = 0;
  8001b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d4:	00 00 00 
	b.cnt = 0;
  8001d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e1:	ff 75 0c             	pushl  0xc(%ebp)
  8001e4:	ff 75 08             	pushl  0x8(%ebp)
  8001e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	68 82 01 80 00       	push   $0x800182
  8001f3:	e8 54 01 00 00       	call   80034c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f8:	83 c4 08             	add    $0x8,%esp
  8001fb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800201:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	e8 fa 09 00 00       	call   800c07 <sys_cputs>

	return b.cnt;
}
  80020d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021e:	50                   	push   %eax
  80021f:	ff 75 08             	pushl  0x8(%ebp)
  800222:	e8 9d ff ff ff       	call   8001c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 1c             	sub    $0x1c,%esp
  800232:	89 c7                	mov    %eax,%edi
  800234:	89 d6                	mov    %edx,%esi
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800242:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800250:	39 d3                	cmp    %edx,%ebx
  800252:	72 05                	jb     800259 <printnum+0x30>
  800254:	39 45 10             	cmp    %eax,0x10(%ebp)
  800257:	77 45                	ja     80029e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800259:	83 ec 0c             	sub    $0xc,%esp
  80025c:	ff 75 18             	pushl  0x18(%ebp)
  80025f:	8b 45 14             	mov    0x14(%ebp),%eax
  800262:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800265:	53                   	push   %ebx
  800266:	ff 75 10             	pushl  0x10(%ebp)
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026f:	ff 75 e0             	pushl  -0x20(%ebp)
  800272:	ff 75 dc             	pushl  -0x24(%ebp)
  800275:	ff 75 d8             	pushl  -0x28(%ebp)
  800278:	e8 a3 1a 00 00       	call   801d20 <__udivdi3>
  80027d:	83 c4 18             	add    $0x18,%esp
  800280:	52                   	push   %edx
  800281:	50                   	push   %eax
  800282:	89 f2                	mov    %esi,%edx
  800284:	89 f8                	mov    %edi,%eax
  800286:	e8 9e ff ff ff       	call   800229 <printnum>
  80028b:	83 c4 20             	add    $0x20,%esp
  80028e:	eb 18                	jmp    8002a8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	56                   	push   %esi
  800294:	ff 75 18             	pushl  0x18(%ebp)
  800297:	ff d7                	call   *%edi
  800299:	83 c4 10             	add    $0x10,%esp
  80029c:	eb 03                	jmp    8002a1 <printnum+0x78>
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a1:	83 eb 01             	sub    $0x1,%ebx
  8002a4:	85 db                	test   %ebx,%ebx
  8002a6:	7f e8                	jg     800290 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	56                   	push   %esi
  8002ac:	83 ec 04             	sub    $0x4,%esp
  8002af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bb:	e8 90 1b 00 00       	call   801e50 <__umoddi3>
  8002c0:	83 c4 14             	add    $0x14,%esp
  8002c3:	0f be 80 ab 20 80 00 	movsbl 0x8020ab(%eax),%eax
  8002ca:	50                   	push   %eax
  8002cb:	ff d7                	call   *%edi
}
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d3:	5b                   	pop    %ebx
  8002d4:	5e                   	pop    %esi
  8002d5:	5f                   	pop    %edi
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002db:	83 fa 01             	cmp    $0x1,%edx
  8002de:	7e 0e                	jle    8002ee <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	8b 52 04             	mov    0x4(%edx),%edx
  8002ec:	eb 22                	jmp    800310 <getuint+0x38>
	else if (lflag)
  8002ee:	85 d2                	test   %edx,%edx
  8002f0:	74 10                	je     800302 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800300:	eb 0e                	jmp    800310 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800302:	8b 10                	mov    (%eax),%edx
  800304:	8d 4a 04             	lea    0x4(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800318:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031c:	8b 10                	mov    (%eax),%edx
  80031e:	3b 50 04             	cmp    0x4(%eax),%edx
  800321:	73 0a                	jae    80032d <sprintputch+0x1b>
		*b->buf++ = ch;
  800323:	8d 4a 01             	lea    0x1(%edx),%ecx
  800326:	89 08                	mov    %ecx,(%eax)
  800328:	8b 45 08             	mov    0x8(%ebp),%eax
  80032b:	88 02                	mov    %al,(%edx)
}
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800335:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800338:	50                   	push   %eax
  800339:	ff 75 10             	pushl  0x10(%ebp)
  80033c:	ff 75 0c             	pushl  0xc(%ebp)
  80033f:	ff 75 08             	pushl  0x8(%ebp)
  800342:	e8 05 00 00 00       	call   80034c <vprintfmt>
	va_end(ap);
}
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	c9                   	leave  
  80034b:	c3                   	ret    

0080034c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	57                   	push   %edi
  800350:	56                   	push   %esi
  800351:	53                   	push   %ebx
  800352:	83 ec 2c             	sub    $0x2c,%esp
  800355:	8b 75 08             	mov    0x8(%ebp),%esi
  800358:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035e:	eb 12                	jmp    800372 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800360:	85 c0                	test   %eax,%eax
  800362:	0f 84 38 04 00 00    	je     8007a0 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	53                   	push   %ebx
  80036c:	50                   	push   %eax
  80036d:	ff d6                	call   *%esi
  80036f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800372:	83 c7 01             	add    $0x1,%edi
  800375:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800379:	83 f8 25             	cmp    $0x25,%eax
  80037c:	75 e2                	jne    800360 <vprintfmt+0x14>
  80037e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800382:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800389:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800390:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800397:	ba 00 00 00 00       	mov    $0x0,%edx
  80039c:	eb 07                	jmp    8003a5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8d 47 01             	lea    0x1(%edi),%eax
  8003a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ab:	0f b6 07             	movzbl (%edi),%eax
  8003ae:	0f b6 c8             	movzbl %al,%ecx
  8003b1:	83 e8 23             	sub    $0x23,%eax
  8003b4:	3c 55                	cmp    $0x55,%al
  8003b6:	0f 87 c9 03 00 00    	ja     800785 <vprintfmt+0x439>
  8003bc:	0f b6 c0             	movzbl %al,%eax
  8003bf:	ff 24 85 e0 21 80 00 	jmp    *0x8021e0(,%eax,4)
  8003c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003cd:	eb d6                	jmp    8003a5 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  8003cf:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  8003d6:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  8003dc:	eb 94                	jmp    800372 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  8003de:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  8003e5:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  8003eb:	eb 85                	jmp    800372 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  8003ed:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  8003f4:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  8003fa:	e9 73 ff ff ff       	jmp    800372 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  8003ff:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  800406:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  80040c:	e9 61 ff ff ff       	jmp    800372 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  800411:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800418:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  80041e:	e9 4f ff ff ff       	jmp    800372 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  800423:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  80042a:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  800430:	e9 3d ff ff ff       	jmp    800372 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  800435:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  80043c:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  800442:	e9 2b ff ff ff       	jmp    800372 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  800447:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  80044e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  800454:	e9 19 ff ff ff       	jmp    800372 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800459:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  800460:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  800466:	e9 07 ff ff ff       	jmp    800372 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  80046b:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  800472:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800478:	e9 f5 fe ff ff       	jmp    800372 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800480:	b8 00 00 00 00       	mov    $0x0,%eax
  800485:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800488:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80048b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80048f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800492:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800495:	83 fa 09             	cmp    $0x9,%edx
  800498:	77 3f                	ja     8004d9 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80049a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80049d:	eb e9                	jmp    800488 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80049f:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a2:	8d 48 04             	lea    0x4(%eax),%ecx
  8004a5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004a8:	8b 00                	mov    (%eax),%eax
  8004aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b0:	eb 2d                	jmp    8004df <vprintfmt+0x193>
  8004b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004bc:	0f 49 c8             	cmovns %eax,%ecx
  8004bf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c5:	e9 db fe ff ff       	jmp    8003a5 <vprintfmt+0x59>
  8004ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004cd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004d4:	e9 cc fe ff ff       	jmp    8003a5 <vprintfmt+0x59>
  8004d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004dc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e3:	0f 89 bc fe ff ff    	jns    8003a5 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004e9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ef:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004f6:	e9 aa fe ff ff       	jmp    8003a5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004fb:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800501:	e9 9f fe ff ff       	jmp    8003a5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 50 04             	lea    0x4(%eax),%edx
  80050c:	89 55 14             	mov    %edx,0x14(%ebp)
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	53                   	push   %ebx
  800513:	ff 30                	pushl  (%eax)
  800515:	ff d6                	call   *%esi
			break;
  800517:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80051d:	e9 50 fe ff ff       	jmp    800372 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 50 04             	lea    0x4(%eax),%edx
  800528:	89 55 14             	mov    %edx,0x14(%ebp)
  80052b:	8b 00                	mov    (%eax),%eax
  80052d:	99                   	cltd   
  80052e:	31 d0                	xor    %edx,%eax
  800530:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800532:	83 f8 0f             	cmp    $0xf,%eax
  800535:	7f 0b                	jg     800542 <vprintfmt+0x1f6>
  800537:	8b 14 85 40 23 80 00 	mov    0x802340(,%eax,4),%edx
  80053e:	85 d2                	test   %edx,%edx
  800540:	75 18                	jne    80055a <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  800542:	50                   	push   %eax
  800543:	68 c3 20 80 00       	push   $0x8020c3
  800548:	53                   	push   %ebx
  800549:	56                   	push   %esi
  80054a:	e8 e0 fd ff ff       	call   80032f <printfmt>
  80054f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800555:	e9 18 fe ff ff       	jmp    800372 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80055a:	52                   	push   %edx
  80055b:	68 71 24 80 00       	push   $0x802471
  800560:	53                   	push   %ebx
  800561:	56                   	push   %esi
  800562:	e8 c8 fd ff ff       	call   80032f <printfmt>
  800567:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056d:	e9 00 fe ff ff       	jmp    800372 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 50 04             	lea    0x4(%eax),%edx
  800578:	89 55 14             	mov    %edx,0x14(%ebp)
  80057b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80057d:	85 ff                	test   %edi,%edi
  80057f:	b8 bc 20 80 00       	mov    $0x8020bc,%eax
  800584:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800587:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058b:	0f 8e 94 00 00 00    	jle    800625 <vprintfmt+0x2d9>
  800591:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800595:	0f 84 98 00 00 00    	je     800633 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  80059b:	83 ec 08             	sub    $0x8,%esp
  80059e:	ff 75 d0             	pushl  -0x30(%ebp)
  8005a1:	57                   	push   %edi
  8005a2:	e8 81 02 00 00       	call   800828 <strnlen>
  8005a7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005aa:	29 c1                	sub    %eax,%ecx
  8005ac:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005af:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005b2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005bc:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005be:	eb 0f                	jmp    8005cf <vprintfmt+0x283>
					putch(padc, putdat);
  8005c0:	83 ec 08             	sub    $0x8,%esp
  8005c3:	53                   	push   %ebx
  8005c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8005c7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c9:	83 ef 01             	sub    $0x1,%edi
  8005cc:	83 c4 10             	add    $0x10,%esp
  8005cf:	85 ff                	test   %edi,%edi
  8005d1:	7f ed                	jg     8005c0 <vprintfmt+0x274>
  8005d3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005d6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005d9:	85 c9                	test   %ecx,%ecx
  8005db:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e0:	0f 49 c1             	cmovns %ecx,%eax
  8005e3:	29 c1                	sub    %eax,%ecx
  8005e5:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005eb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ee:	89 cb                	mov    %ecx,%ebx
  8005f0:	eb 4d                	jmp    80063f <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f6:	74 1b                	je     800613 <vprintfmt+0x2c7>
  8005f8:	0f be c0             	movsbl %al,%eax
  8005fb:	83 e8 20             	sub    $0x20,%eax
  8005fe:	83 f8 5e             	cmp    $0x5e,%eax
  800601:	76 10                	jbe    800613 <vprintfmt+0x2c7>
					putch('?', putdat);
  800603:	83 ec 08             	sub    $0x8,%esp
  800606:	ff 75 0c             	pushl  0xc(%ebp)
  800609:	6a 3f                	push   $0x3f
  80060b:	ff 55 08             	call   *0x8(%ebp)
  80060e:	83 c4 10             	add    $0x10,%esp
  800611:	eb 0d                	jmp    800620 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  800613:	83 ec 08             	sub    $0x8,%esp
  800616:	ff 75 0c             	pushl  0xc(%ebp)
  800619:	52                   	push   %edx
  80061a:	ff 55 08             	call   *0x8(%ebp)
  80061d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800620:	83 eb 01             	sub    $0x1,%ebx
  800623:	eb 1a                	jmp    80063f <vprintfmt+0x2f3>
  800625:	89 75 08             	mov    %esi,0x8(%ebp)
  800628:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80062b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80062e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800631:	eb 0c                	jmp    80063f <vprintfmt+0x2f3>
  800633:	89 75 08             	mov    %esi,0x8(%ebp)
  800636:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800639:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80063c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80063f:	83 c7 01             	add    $0x1,%edi
  800642:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800646:	0f be d0             	movsbl %al,%edx
  800649:	85 d2                	test   %edx,%edx
  80064b:	74 23                	je     800670 <vprintfmt+0x324>
  80064d:	85 f6                	test   %esi,%esi
  80064f:	78 a1                	js     8005f2 <vprintfmt+0x2a6>
  800651:	83 ee 01             	sub    $0x1,%esi
  800654:	79 9c                	jns    8005f2 <vprintfmt+0x2a6>
  800656:	89 df                	mov    %ebx,%edi
  800658:	8b 75 08             	mov    0x8(%ebp),%esi
  80065b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80065e:	eb 18                	jmp    800678 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	6a 20                	push   $0x20
  800666:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800668:	83 ef 01             	sub    $0x1,%edi
  80066b:	83 c4 10             	add    $0x10,%esp
  80066e:	eb 08                	jmp    800678 <vprintfmt+0x32c>
  800670:	89 df                	mov    %ebx,%edi
  800672:	8b 75 08             	mov    0x8(%ebp),%esi
  800675:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800678:	85 ff                	test   %edi,%edi
  80067a:	7f e4                	jg     800660 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067f:	e9 ee fc ff ff       	jmp    800372 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800684:	83 fa 01             	cmp    $0x1,%edx
  800687:	7e 16                	jle    80069f <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8d 50 08             	lea    0x8(%eax),%edx
  80068f:	89 55 14             	mov    %edx,0x14(%ebp)
  800692:	8b 50 04             	mov    0x4(%eax),%edx
  800695:	8b 00                	mov    (%eax),%eax
  800697:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80069d:	eb 32                	jmp    8006d1 <vprintfmt+0x385>
	else if (lflag)
  80069f:	85 d2                	test   %edx,%edx
  8006a1:	74 18                	je     8006bb <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8d 50 04             	lea    0x4(%eax),%edx
  8006a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ac:	8b 00                	mov    (%eax),%eax
  8006ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b1:	89 c1                	mov    %eax,%ecx
  8006b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006b9:	eb 16                	jmp    8006d1 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8d 50 04             	lea    0x4(%eax),%edx
  8006c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c4:	8b 00                	mov    (%eax),%eax
  8006c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c9:	89 c1                	mov    %eax,%ecx
  8006cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006d7:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006dc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006e0:	79 6f                	jns    800751 <vprintfmt+0x405>
				putch('-', putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	6a 2d                	push   $0x2d
  8006e8:	ff d6                	call   *%esi
				num = -(long long) num;
  8006ea:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006f0:	f7 d8                	neg    %eax
  8006f2:	83 d2 00             	adc    $0x0,%edx
  8006f5:	f7 da                	neg    %edx
  8006f7:	83 c4 10             	add    $0x10,%esp
  8006fa:	eb 55                	jmp    800751 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ff:	e8 d4 fb ff ff       	call   8002d8 <getuint>
			base = 10;
  800704:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800709:	eb 46                	jmp    800751 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80070b:	8d 45 14             	lea    0x14(%ebp),%eax
  80070e:	e8 c5 fb ff ff       	call   8002d8 <getuint>
			base = 8;
  800713:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800718:	eb 37                	jmp    800751 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	53                   	push   %ebx
  80071e:	6a 30                	push   $0x30
  800720:	ff d6                	call   *%esi
			putch('x', putdat);
  800722:	83 c4 08             	add    $0x8,%esp
  800725:	53                   	push   %ebx
  800726:	6a 78                	push   $0x78
  800728:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80072a:	8b 45 14             	mov    0x14(%ebp),%eax
  80072d:	8d 50 04             	lea    0x4(%eax),%edx
  800730:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800733:	8b 00                	mov    (%eax),%eax
  800735:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80073a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80073d:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800742:	eb 0d                	jmp    800751 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800744:	8d 45 14             	lea    0x14(%ebp),%eax
  800747:	e8 8c fb ff ff       	call   8002d8 <getuint>
			base = 16;
  80074c:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800751:	83 ec 0c             	sub    $0xc,%esp
  800754:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800758:	51                   	push   %ecx
  800759:	ff 75 e0             	pushl  -0x20(%ebp)
  80075c:	57                   	push   %edi
  80075d:	52                   	push   %edx
  80075e:	50                   	push   %eax
  80075f:	89 da                	mov    %ebx,%edx
  800761:	89 f0                	mov    %esi,%eax
  800763:	e8 c1 fa ff ff       	call   800229 <printnum>
			break;
  800768:	83 c4 20             	add    $0x20,%esp
  80076b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80076e:	e9 ff fb ff ff       	jmp    800372 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	53                   	push   %ebx
  800777:	51                   	push   %ecx
  800778:	ff d6                	call   *%esi
			break;
  80077a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800780:	e9 ed fb ff ff       	jmp    800372 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	53                   	push   %ebx
  800789:	6a 25                	push   $0x25
  80078b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80078d:	83 c4 10             	add    $0x10,%esp
  800790:	eb 03                	jmp    800795 <vprintfmt+0x449>
  800792:	83 ef 01             	sub    $0x1,%edi
  800795:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800799:	75 f7                	jne    800792 <vprintfmt+0x446>
  80079b:	e9 d2 fb ff ff       	jmp    800372 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007a3:	5b                   	pop    %ebx
  8007a4:	5e                   	pop    %esi
  8007a5:	5f                   	pop    %edi
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	83 ec 18             	sub    $0x18,%esp
  8007ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007bb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c5:	85 c0                	test   %eax,%eax
  8007c7:	74 26                	je     8007ef <vsnprintf+0x47>
  8007c9:	85 d2                	test   %edx,%edx
  8007cb:	7e 22                	jle    8007ef <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007cd:	ff 75 14             	pushl  0x14(%ebp)
  8007d0:	ff 75 10             	pushl  0x10(%ebp)
  8007d3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d6:	50                   	push   %eax
  8007d7:	68 12 03 80 00       	push   $0x800312
  8007dc:	e8 6b fb ff ff       	call   80034c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ea:	83 c4 10             	add    $0x10,%esp
  8007ed:	eb 05                	jmp    8007f4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007f4:	c9                   	leave  
  8007f5:	c3                   	ret    

008007f6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007fc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ff:	50                   	push   %eax
  800800:	ff 75 10             	pushl  0x10(%ebp)
  800803:	ff 75 0c             	pushl  0xc(%ebp)
  800806:	ff 75 08             	pushl  0x8(%ebp)
  800809:	e8 9a ff ff ff       	call   8007a8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80080e:	c9                   	leave  
  80080f:	c3                   	ret    

00800810 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800816:	b8 00 00 00 00       	mov    $0x0,%eax
  80081b:	eb 03                	jmp    800820 <strlen+0x10>
		n++;
  80081d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800820:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800824:	75 f7                	jne    80081d <strlen+0xd>
		n++;
	return n;
}
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800831:	ba 00 00 00 00       	mov    $0x0,%edx
  800836:	eb 03                	jmp    80083b <strnlen+0x13>
		n++;
  800838:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083b:	39 c2                	cmp    %eax,%edx
  80083d:	74 08                	je     800847 <strnlen+0x1f>
  80083f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800843:	75 f3                	jne    800838 <strnlen+0x10>
  800845:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	53                   	push   %ebx
  80084d:	8b 45 08             	mov    0x8(%ebp),%eax
  800850:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800853:	89 c2                	mov    %eax,%edx
  800855:	83 c2 01             	add    $0x1,%edx
  800858:	83 c1 01             	add    $0x1,%ecx
  80085b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80085f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800862:	84 db                	test   %bl,%bl
  800864:	75 ef                	jne    800855 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800866:	5b                   	pop    %ebx
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	53                   	push   %ebx
  80086d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800870:	53                   	push   %ebx
  800871:	e8 9a ff ff ff       	call   800810 <strlen>
  800876:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800879:	ff 75 0c             	pushl  0xc(%ebp)
  80087c:	01 d8                	add    %ebx,%eax
  80087e:	50                   	push   %eax
  80087f:	e8 c5 ff ff ff       	call   800849 <strcpy>
	return dst;
}
  800884:	89 d8                	mov    %ebx,%eax
  800886:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800889:	c9                   	leave  
  80088a:	c3                   	ret    

0080088b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
  800890:	8b 75 08             	mov    0x8(%ebp),%esi
  800893:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800896:	89 f3                	mov    %esi,%ebx
  800898:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089b:	89 f2                	mov    %esi,%edx
  80089d:	eb 0f                	jmp    8008ae <strncpy+0x23>
		*dst++ = *src;
  80089f:	83 c2 01             	add    $0x1,%edx
  8008a2:	0f b6 01             	movzbl (%ecx),%eax
  8008a5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a8:	80 39 01             	cmpb   $0x1,(%ecx)
  8008ab:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ae:	39 da                	cmp    %ebx,%edx
  8008b0:	75 ed                	jne    80089f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008b2:	89 f0                	mov    %esi,%eax
  8008b4:	5b                   	pop    %ebx
  8008b5:	5e                   	pop    %esi
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
  8008bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c3:	8b 55 10             	mov    0x10(%ebp),%edx
  8008c6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c8:	85 d2                	test   %edx,%edx
  8008ca:	74 21                	je     8008ed <strlcpy+0x35>
  8008cc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008d0:	89 f2                	mov    %esi,%edx
  8008d2:	eb 09                	jmp    8008dd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008d4:	83 c2 01             	add    $0x1,%edx
  8008d7:	83 c1 01             	add    $0x1,%ecx
  8008da:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008dd:	39 c2                	cmp    %eax,%edx
  8008df:	74 09                	je     8008ea <strlcpy+0x32>
  8008e1:	0f b6 19             	movzbl (%ecx),%ebx
  8008e4:	84 db                	test   %bl,%bl
  8008e6:	75 ec                	jne    8008d4 <strlcpy+0x1c>
  8008e8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008ea:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ed:	29 f0                	sub    %esi,%eax
}
  8008ef:	5b                   	pop    %ebx
  8008f0:	5e                   	pop    %esi
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008fc:	eb 06                	jmp    800904 <strcmp+0x11>
		p++, q++;
  8008fe:	83 c1 01             	add    $0x1,%ecx
  800901:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800904:	0f b6 01             	movzbl (%ecx),%eax
  800907:	84 c0                	test   %al,%al
  800909:	74 04                	je     80090f <strcmp+0x1c>
  80090b:	3a 02                	cmp    (%edx),%al
  80090d:	74 ef                	je     8008fe <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80090f:	0f b6 c0             	movzbl %al,%eax
  800912:	0f b6 12             	movzbl (%edx),%edx
  800915:	29 d0                	sub    %edx,%eax
}
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	53                   	push   %ebx
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	8b 55 0c             	mov    0xc(%ebp),%edx
  800923:	89 c3                	mov    %eax,%ebx
  800925:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800928:	eb 06                	jmp    800930 <strncmp+0x17>
		n--, p++, q++;
  80092a:	83 c0 01             	add    $0x1,%eax
  80092d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800930:	39 d8                	cmp    %ebx,%eax
  800932:	74 15                	je     800949 <strncmp+0x30>
  800934:	0f b6 08             	movzbl (%eax),%ecx
  800937:	84 c9                	test   %cl,%cl
  800939:	74 04                	je     80093f <strncmp+0x26>
  80093b:	3a 0a                	cmp    (%edx),%cl
  80093d:	74 eb                	je     80092a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80093f:	0f b6 00             	movzbl (%eax),%eax
  800942:	0f b6 12             	movzbl (%edx),%edx
  800945:	29 d0                	sub    %edx,%eax
  800947:	eb 05                	jmp    80094e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800949:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80094e:	5b                   	pop    %ebx
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095b:	eb 07                	jmp    800964 <strchr+0x13>
		if (*s == c)
  80095d:	38 ca                	cmp    %cl,%dl
  80095f:	74 0f                	je     800970 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800961:	83 c0 01             	add    $0x1,%eax
  800964:	0f b6 10             	movzbl (%eax),%edx
  800967:	84 d2                	test   %dl,%dl
  800969:	75 f2                	jne    80095d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80096b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80097c:	eb 03                	jmp    800981 <strfind+0xf>
  80097e:	83 c0 01             	add    $0x1,%eax
  800981:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800984:	38 ca                	cmp    %cl,%dl
  800986:	74 04                	je     80098c <strfind+0x1a>
  800988:	84 d2                	test   %dl,%dl
  80098a:	75 f2                	jne    80097e <strfind+0xc>
			break;
	return (char *) s;
}
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	57                   	push   %edi
  800992:	56                   	push   %esi
  800993:	53                   	push   %ebx
  800994:	8b 7d 08             	mov    0x8(%ebp),%edi
  800997:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80099a:	85 c9                	test   %ecx,%ecx
  80099c:	74 36                	je     8009d4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80099e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a4:	75 28                	jne    8009ce <memset+0x40>
  8009a6:	f6 c1 03             	test   $0x3,%cl
  8009a9:	75 23                	jne    8009ce <memset+0x40>
		c &= 0xFF;
  8009ab:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009af:	89 d3                	mov    %edx,%ebx
  8009b1:	c1 e3 08             	shl    $0x8,%ebx
  8009b4:	89 d6                	mov    %edx,%esi
  8009b6:	c1 e6 18             	shl    $0x18,%esi
  8009b9:	89 d0                	mov    %edx,%eax
  8009bb:	c1 e0 10             	shl    $0x10,%eax
  8009be:	09 f0                	or     %esi,%eax
  8009c0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009c2:	89 d8                	mov    %ebx,%eax
  8009c4:	09 d0                	or     %edx,%eax
  8009c6:	c1 e9 02             	shr    $0x2,%ecx
  8009c9:	fc                   	cld    
  8009ca:	f3 ab                	rep stos %eax,%es:(%edi)
  8009cc:	eb 06                	jmp    8009d4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d1:	fc                   	cld    
  8009d2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009d4:	89 f8                	mov    %edi,%eax
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	5f                   	pop    %edi
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	57                   	push   %edi
  8009df:	56                   	push   %esi
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e9:	39 c6                	cmp    %eax,%esi
  8009eb:	73 35                	jae    800a22 <memmove+0x47>
  8009ed:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f0:	39 d0                	cmp    %edx,%eax
  8009f2:	73 2e                	jae    800a22 <memmove+0x47>
		s += n;
		d += n;
  8009f4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f7:	89 d6                	mov    %edx,%esi
  8009f9:	09 fe                	or     %edi,%esi
  8009fb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a01:	75 13                	jne    800a16 <memmove+0x3b>
  800a03:	f6 c1 03             	test   $0x3,%cl
  800a06:	75 0e                	jne    800a16 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a08:	83 ef 04             	sub    $0x4,%edi
  800a0b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a0e:	c1 e9 02             	shr    $0x2,%ecx
  800a11:	fd                   	std    
  800a12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a14:	eb 09                	jmp    800a1f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a16:	83 ef 01             	sub    $0x1,%edi
  800a19:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a1c:	fd                   	std    
  800a1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a1f:	fc                   	cld    
  800a20:	eb 1d                	jmp    800a3f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a22:	89 f2                	mov    %esi,%edx
  800a24:	09 c2                	or     %eax,%edx
  800a26:	f6 c2 03             	test   $0x3,%dl
  800a29:	75 0f                	jne    800a3a <memmove+0x5f>
  800a2b:	f6 c1 03             	test   $0x3,%cl
  800a2e:	75 0a                	jne    800a3a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a30:	c1 e9 02             	shr    $0x2,%ecx
  800a33:	89 c7                	mov    %eax,%edi
  800a35:	fc                   	cld    
  800a36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a38:	eb 05                	jmp    800a3f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a3a:	89 c7                	mov    %eax,%edi
  800a3c:	fc                   	cld    
  800a3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a3f:	5e                   	pop    %esi
  800a40:	5f                   	pop    %edi
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a46:	ff 75 10             	pushl  0x10(%ebp)
  800a49:	ff 75 0c             	pushl  0xc(%ebp)
  800a4c:	ff 75 08             	pushl  0x8(%ebp)
  800a4f:	e8 87 ff ff ff       	call   8009db <memmove>
}
  800a54:	c9                   	leave  
  800a55:	c3                   	ret    

00800a56 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a61:	89 c6                	mov    %eax,%esi
  800a63:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a66:	eb 1a                	jmp    800a82 <memcmp+0x2c>
		if (*s1 != *s2)
  800a68:	0f b6 08             	movzbl (%eax),%ecx
  800a6b:	0f b6 1a             	movzbl (%edx),%ebx
  800a6e:	38 d9                	cmp    %bl,%cl
  800a70:	74 0a                	je     800a7c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a72:	0f b6 c1             	movzbl %cl,%eax
  800a75:	0f b6 db             	movzbl %bl,%ebx
  800a78:	29 d8                	sub    %ebx,%eax
  800a7a:	eb 0f                	jmp    800a8b <memcmp+0x35>
		s1++, s2++;
  800a7c:	83 c0 01             	add    $0x1,%eax
  800a7f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a82:	39 f0                	cmp    %esi,%eax
  800a84:	75 e2                	jne    800a68 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8b:	5b                   	pop    %ebx
  800a8c:	5e                   	pop    %esi
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	53                   	push   %ebx
  800a93:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a96:	89 c1                	mov    %eax,%ecx
  800a98:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a9b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a9f:	eb 0a                	jmp    800aab <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa1:	0f b6 10             	movzbl (%eax),%edx
  800aa4:	39 da                	cmp    %ebx,%edx
  800aa6:	74 07                	je     800aaf <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aa8:	83 c0 01             	add    $0x1,%eax
  800aab:	39 c8                	cmp    %ecx,%eax
  800aad:	72 f2                	jb     800aa1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aaf:	5b                   	pop    %ebx
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
  800ab8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800abb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abe:	eb 03                	jmp    800ac3 <strtol+0x11>
		s++;
  800ac0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac3:	0f b6 01             	movzbl (%ecx),%eax
  800ac6:	3c 20                	cmp    $0x20,%al
  800ac8:	74 f6                	je     800ac0 <strtol+0xe>
  800aca:	3c 09                	cmp    $0x9,%al
  800acc:	74 f2                	je     800ac0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ace:	3c 2b                	cmp    $0x2b,%al
  800ad0:	75 0a                	jne    800adc <strtol+0x2a>
		s++;
  800ad2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad5:	bf 00 00 00 00       	mov    $0x0,%edi
  800ada:	eb 11                	jmp    800aed <strtol+0x3b>
  800adc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ae1:	3c 2d                	cmp    $0x2d,%al
  800ae3:	75 08                	jne    800aed <strtol+0x3b>
		s++, neg = 1;
  800ae5:	83 c1 01             	add    $0x1,%ecx
  800ae8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aed:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800af3:	75 15                	jne    800b0a <strtol+0x58>
  800af5:	80 39 30             	cmpb   $0x30,(%ecx)
  800af8:	75 10                	jne    800b0a <strtol+0x58>
  800afa:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800afe:	75 7c                	jne    800b7c <strtol+0xca>
		s += 2, base = 16;
  800b00:	83 c1 02             	add    $0x2,%ecx
  800b03:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b08:	eb 16                	jmp    800b20 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b0a:	85 db                	test   %ebx,%ebx
  800b0c:	75 12                	jne    800b20 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b0e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b13:	80 39 30             	cmpb   $0x30,(%ecx)
  800b16:	75 08                	jne    800b20 <strtol+0x6e>
		s++, base = 8;
  800b18:	83 c1 01             	add    $0x1,%ecx
  800b1b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b20:	b8 00 00 00 00       	mov    $0x0,%eax
  800b25:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b28:	0f b6 11             	movzbl (%ecx),%edx
  800b2b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b2e:	89 f3                	mov    %esi,%ebx
  800b30:	80 fb 09             	cmp    $0x9,%bl
  800b33:	77 08                	ja     800b3d <strtol+0x8b>
			dig = *s - '0';
  800b35:	0f be d2             	movsbl %dl,%edx
  800b38:	83 ea 30             	sub    $0x30,%edx
  800b3b:	eb 22                	jmp    800b5f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b3d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b40:	89 f3                	mov    %esi,%ebx
  800b42:	80 fb 19             	cmp    $0x19,%bl
  800b45:	77 08                	ja     800b4f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b47:	0f be d2             	movsbl %dl,%edx
  800b4a:	83 ea 57             	sub    $0x57,%edx
  800b4d:	eb 10                	jmp    800b5f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b4f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b52:	89 f3                	mov    %esi,%ebx
  800b54:	80 fb 19             	cmp    $0x19,%bl
  800b57:	77 16                	ja     800b6f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b59:	0f be d2             	movsbl %dl,%edx
  800b5c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b5f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b62:	7d 0b                	jge    800b6f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b64:	83 c1 01             	add    $0x1,%ecx
  800b67:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b6b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b6d:	eb b9                	jmp    800b28 <strtol+0x76>

	if (endptr)
  800b6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b73:	74 0d                	je     800b82 <strtol+0xd0>
		*endptr = (char *) s;
  800b75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b78:	89 0e                	mov    %ecx,(%esi)
  800b7a:	eb 06                	jmp    800b82 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b7c:	85 db                	test   %ebx,%ebx
  800b7e:	74 98                	je     800b18 <strtol+0x66>
  800b80:	eb 9e                	jmp    800b20 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b82:	89 c2                	mov    %eax,%edx
  800b84:	f7 da                	neg    %edx
  800b86:	85 ff                	test   %edi,%edi
  800b88:	0f 45 c2             	cmovne %edx,%eax
}
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
  800b96:	83 ec 04             	sub    $0x4,%esp
  800b99:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800b9c:	57                   	push   %edi
  800b9d:	e8 6e fc ff ff       	call   800810 <strlen>
  800ba2:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800ba5:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800ba8:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800bad:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800bb2:	eb 46                	jmp    800bfa <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800bb4:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800bb8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800bbb:	80 f9 09             	cmp    $0x9,%cl
  800bbe:	77 08                	ja     800bc8 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800bc0:	0f be d2             	movsbl %dl,%edx
  800bc3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800bc6:	eb 27                	jmp    800bef <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800bc8:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800bcb:	80 f9 05             	cmp    $0x5,%cl
  800bce:	77 08                	ja     800bd8 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800bd0:	0f be d2             	movsbl %dl,%edx
  800bd3:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800bd6:	eb 17                	jmp    800bef <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800bd8:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800bdb:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800bde:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800be3:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800be7:	77 06                	ja     800bef <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800be9:	0f be d2             	movsbl %dl,%edx
  800bec:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800bef:	0f af ce             	imul   %esi,%ecx
  800bf2:	01 c8                	add    %ecx,%eax
		base *= 16;
  800bf4:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800bf7:	83 eb 01             	sub    $0x1,%ebx
  800bfa:	83 fb 01             	cmp    $0x1,%ebx
  800bfd:	7f b5                	jg     800bb4 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	89 c3                	mov    %eax,%ebx
  800c1a:	89 c7                	mov    %eax,%edi
  800c1c:	89 c6                	mov    %eax,%esi
  800c1e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c30:	b8 01 00 00 00       	mov    $0x1,%eax
  800c35:	89 d1                	mov    %edx,%ecx
  800c37:	89 d3                	mov    %edx,%ebx
  800c39:	89 d7                	mov    %edx,%edi
  800c3b:	89 d6                	mov    %edx,%esi
  800c3d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c52:	b8 03 00 00 00       	mov    $0x3,%eax
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	89 cb                	mov    %ecx,%ebx
  800c5c:	89 cf                	mov    %ecx,%edi
  800c5e:	89 ce                	mov    %ecx,%esi
  800c60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7e 17                	jle    800c7d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	50                   	push   %eax
  800c6a:	6a 03                	push   $0x3
  800c6c:	68 9f 23 80 00       	push   $0x80239f
  800c71:	6a 23                	push   $0x23
  800c73:	68 bc 23 80 00       	push   $0x8023bc
  800c78:	e8 bf f4 ff ff       	call   80013c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c90:	b8 02 00 00 00       	mov    $0x2,%eax
  800c95:	89 d1                	mov    %edx,%ecx
  800c97:	89 d3                	mov    %edx,%ebx
  800c99:	89 d7                	mov    %edx,%edi
  800c9b:	89 d6                	mov    %edx,%esi
  800c9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_yield>:

void
sys_yield(void)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	ba 00 00 00 00       	mov    $0x0,%edx
  800caf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb4:	89 d1                	mov    %edx,%ecx
  800cb6:	89 d3                	mov    %edx,%ebx
  800cb8:	89 d7                	mov    %edx,%edi
  800cba:	89 d6                	mov    %edx,%esi
  800cbc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	be 00 00 00 00       	mov    $0x0,%esi
  800cd1:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdf:	89 f7                	mov    %esi,%edi
  800ce1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 04                	push   $0x4
  800ced:	68 9f 23 80 00       	push   $0x80239f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 bc 23 80 00       	push   $0x8023bc
  800cf9:	e8 3e f4 ff ff       	call   80013c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	b8 05 00 00 00       	mov    $0x5,%eax
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d20:	8b 75 18             	mov    0x18(%ebp),%esi
  800d23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7e 17                	jle    800d40 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d29:	83 ec 0c             	sub    $0xc,%esp
  800d2c:	50                   	push   %eax
  800d2d:	6a 05                	push   $0x5
  800d2f:	68 9f 23 80 00       	push   $0x80239f
  800d34:	6a 23                	push   $0x23
  800d36:	68 bc 23 80 00       	push   $0x8023bc
  800d3b:	e8 fc f3 ff ff       	call   80013c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
  800d4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d56:	b8 06 00 00 00       	mov    $0x6,%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	89 df                	mov    %ebx,%edi
  800d63:	89 de                	mov    %ebx,%esi
  800d65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d67:	85 c0                	test   %eax,%eax
  800d69:	7e 17                	jle    800d82 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	50                   	push   %eax
  800d6f:	6a 06                	push   $0x6
  800d71:	68 9f 23 80 00       	push   $0x80239f
  800d76:	6a 23                	push   $0x23
  800d78:	68 bc 23 80 00       	push   $0x8023bc
  800d7d:	e8 ba f3 ff ff       	call   80013c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d98:	b8 08 00 00 00       	mov    $0x8,%eax
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	89 df                	mov    %ebx,%edi
  800da5:	89 de                	mov    %ebx,%esi
  800da7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7e 17                	jle    800dc4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	50                   	push   %eax
  800db1:	6a 08                	push   $0x8
  800db3:	68 9f 23 80 00       	push   $0x80239f
  800db8:	6a 23                	push   $0x23
  800dba:	68 bc 23 80 00       	push   $0x8023bc
  800dbf:	e8 78 f3 ff ff       	call   80013c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
  800dd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dda:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ddf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de2:	8b 55 08             	mov    0x8(%ebp),%edx
  800de5:	89 df                	mov    %ebx,%edi
  800de7:	89 de                	mov    %ebx,%esi
  800de9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800deb:	85 c0                	test   %eax,%eax
  800ded:	7e 17                	jle    800e06 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	50                   	push   %eax
  800df3:	6a 0a                	push   $0xa
  800df5:	68 9f 23 80 00       	push   $0x80239f
  800dfa:	6a 23                	push   $0x23
  800dfc:	68 bc 23 80 00       	push   $0x8023bc
  800e01:	e8 36 f3 ff ff       	call   80013c <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800e17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1c:	b8 09 00 00 00       	mov    $0x9,%eax
  800e21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e24:	8b 55 08             	mov    0x8(%ebp),%edx
  800e27:	89 df                	mov    %ebx,%edi
  800e29:	89 de                	mov    %ebx,%esi
  800e2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	7e 17                	jle    800e48 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e31:	83 ec 0c             	sub    $0xc,%esp
  800e34:	50                   	push   %eax
  800e35:	6a 09                	push   $0x9
  800e37:	68 9f 23 80 00       	push   $0x80239f
  800e3c:	6a 23                	push   $0x23
  800e3e:	68 bc 23 80 00       	push   $0x8023bc
  800e43:	e8 f4 f2 ff ff       	call   80013c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	57                   	push   %edi
  800e54:	56                   	push   %esi
  800e55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e56:	be 00 00 00 00       	mov    $0x0,%esi
  800e5b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e63:	8b 55 08             	mov    0x8(%ebp),%edx
  800e66:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e69:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e6e:	5b                   	pop    %ebx
  800e6f:	5e                   	pop    %esi
  800e70:	5f                   	pop    %edi
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    

00800e73 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	57                   	push   %edi
  800e77:	56                   	push   %esi
  800e78:	53                   	push   %ebx
  800e79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e81:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e86:	8b 55 08             	mov    0x8(%ebp),%edx
  800e89:	89 cb                	mov    %ecx,%ebx
  800e8b:	89 cf                	mov    %ecx,%edi
  800e8d:	89 ce                	mov    %ecx,%esi
  800e8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e91:	85 c0                	test   %eax,%eax
  800e93:	7e 17                	jle    800eac <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e95:	83 ec 0c             	sub    $0xc,%esp
  800e98:	50                   	push   %eax
  800e99:	6a 0d                	push   $0xd
  800e9b:	68 9f 23 80 00       	push   $0x80239f
  800ea0:	6a 23                	push   $0x23
  800ea2:	68 bc 23 80 00       	push   $0x8023bc
  800ea7:	e8 90 f2 ff ff       	call   80013c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eba:	05 00 00 00 30       	add    $0x30000000,%eax
  800ebf:	c1 e8 0c             	shr    $0xc,%eax
}
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eca:	05 00 00 00 30       	add    $0x30000000,%eax
  800ecf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ed4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ee6:	89 c2                	mov    %eax,%edx
  800ee8:	c1 ea 16             	shr    $0x16,%edx
  800eeb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ef2:	f6 c2 01             	test   $0x1,%dl
  800ef5:	74 11                	je     800f08 <fd_alloc+0x2d>
  800ef7:	89 c2                	mov    %eax,%edx
  800ef9:	c1 ea 0c             	shr    $0xc,%edx
  800efc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f03:	f6 c2 01             	test   $0x1,%dl
  800f06:	75 09                	jne    800f11 <fd_alloc+0x36>
			*fd_store = fd;
  800f08:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0f:	eb 17                	jmp    800f28 <fd_alloc+0x4d>
  800f11:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f16:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f1b:	75 c9                	jne    800ee6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f1d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f23:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    

00800f2a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f30:	83 f8 1f             	cmp    $0x1f,%eax
  800f33:	77 36                	ja     800f6b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f35:	c1 e0 0c             	shl    $0xc,%eax
  800f38:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f3d:	89 c2                	mov    %eax,%edx
  800f3f:	c1 ea 16             	shr    $0x16,%edx
  800f42:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f49:	f6 c2 01             	test   $0x1,%dl
  800f4c:	74 24                	je     800f72 <fd_lookup+0x48>
  800f4e:	89 c2                	mov    %eax,%edx
  800f50:	c1 ea 0c             	shr    $0xc,%edx
  800f53:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f5a:	f6 c2 01             	test   $0x1,%dl
  800f5d:	74 1a                	je     800f79 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f62:	89 02                	mov    %eax,(%edx)
	return 0;
  800f64:	b8 00 00 00 00       	mov    $0x0,%eax
  800f69:	eb 13                	jmp    800f7e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f6b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f70:	eb 0c                	jmp    800f7e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f72:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f77:	eb 05                	jmp    800f7e <fd_lookup+0x54>
  800f79:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    

00800f80 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	83 ec 08             	sub    $0x8,%esp
  800f86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f89:	ba 48 24 80 00       	mov    $0x802448,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f8e:	eb 13                	jmp    800fa3 <dev_lookup+0x23>
  800f90:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f93:	39 08                	cmp    %ecx,(%eax)
  800f95:	75 0c                	jne    800fa3 <dev_lookup+0x23>
			*dev = devtab[i];
  800f97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa1:	eb 2e                	jmp    800fd1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fa3:	8b 02                	mov    (%edx),%eax
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	75 e7                	jne    800f90 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fa9:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800fae:	8b 40 48             	mov    0x48(%eax),%eax
  800fb1:	83 ec 04             	sub    $0x4,%esp
  800fb4:	51                   	push   %ecx
  800fb5:	50                   	push   %eax
  800fb6:	68 cc 23 80 00       	push   $0x8023cc
  800fbb:	e8 55 f2 ff ff       	call   800215 <cprintf>
	*dev = 0;
  800fc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fc9:	83 c4 10             	add    $0x10,%esp
  800fcc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fd1:	c9                   	leave  
  800fd2:	c3                   	ret    

00800fd3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	56                   	push   %esi
  800fd7:	53                   	push   %ebx
  800fd8:	83 ec 10             	sub    $0x10,%esp
  800fdb:	8b 75 08             	mov    0x8(%ebp),%esi
  800fde:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fe1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe4:	50                   	push   %eax
  800fe5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800feb:	c1 e8 0c             	shr    $0xc,%eax
  800fee:	50                   	push   %eax
  800fef:	e8 36 ff ff ff       	call   800f2a <fd_lookup>
  800ff4:	83 c4 08             	add    $0x8,%esp
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	78 05                	js     801000 <fd_close+0x2d>
	    || fd != fd2) 
  800ffb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ffe:	74 0c                	je     80100c <fd_close+0x39>
		return (must_exist ? r : 0); 
  801000:	84 db                	test   %bl,%bl
  801002:	ba 00 00 00 00       	mov    $0x0,%edx
  801007:	0f 44 c2             	cmove  %edx,%eax
  80100a:	eb 41                	jmp    80104d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80100c:	83 ec 08             	sub    $0x8,%esp
  80100f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801012:	50                   	push   %eax
  801013:	ff 36                	pushl  (%esi)
  801015:	e8 66 ff ff ff       	call   800f80 <dev_lookup>
  80101a:	89 c3                	mov    %eax,%ebx
  80101c:	83 c4 10             	add    $0x10,%esp
  80101f:	85 c0                	test   %eax,%eax
  801021:	78 1a                	js     80103d <fd_close+0x6a>
		if (dev->dev_close) 
  801023:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801026:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  801029:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  80102e:	85 c0                	test   %eax,%eax
  801030:	74 0b                	je     80103d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	56                   	push   %esi
  801036:	ff d0                	call   *%eax
  801038:	89 c3                	mov    %eax,%ebx
  80103a:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80103d:	83 ec 08             	sub    $0x8,%esp
  801040:	56                   	push   %esi
  801041:	6a 00                	push   $0x0
  801043:	e8 00 fd ff ff       	call   800d48 <sys_page_unmap>
	return r;
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	89 d8                	mov    %ebx,%eax
}
  80104d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801050:	5b                   	pop    %ebx
  801051:	5e                   	pop    %esi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80105a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80105d:	50                   	push   %eax
  80105e:	ff 75 08             	pushl  0x8(%ebp)
  801061:	e8 c4 fe ff ff       	call   800f2a <fd_lookup>
  801066:	83 c4 08             	add    $0x8,%esp
  801069:	85 c0                	test   %eax,%eax
  80106b:	78 10                	js     80107d <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  80106d:	83 ec 08             	sub    $0x8,%esp
  801070:	6a 01                	push   $0x1
  801072:	ff 75 f4             	pushl  -0xc(%ebp)
  801075:	e8 59 ff ff ff       	call   800fd3 <fd_close>
  80107a:	83 c4 10             	add    $0x10,%esp
}
  80107d:	c9                   	leave  
  80107e:	c3                   	ret    

0080107f <close_all>:

void
close_all(void)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	53                   	push   %ebx
  801083:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801086:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80108b:	83 ec 0c             	sub    $0xc,%esp
  80108e:	53                   	push   %ebx
  80108f:	e8 c0 ff ff ff       	call   801054 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801094:	83 c3 01             	add    $0x1,%ebx
  801097:	83 c4 10             	add    $0x10,%esp
  80109a:	83 fb 20             	cmp    $0x20,%ebx
  80109d:	75 ec                	jne    80108b <close_all+0xc>
		close(i);
}
  80109f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a2:	c9                   	leave  
  8010a3:	c3                   	ret    

008010a4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	57                   	push   %edi
  8010a8:	56                   	push   %esi
  8010a9:	53                   	push   %ebx
  8010aa:	83 ec 2c             	sub    $0x2c,%esp
  8010ad:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010b0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010b3:	50                   	push   %eax
  8010b4:	ff 75 08             	pushl  0x8(%ebp)
  8010b7:	e8 6e fe ff ff       	call   800f2a <fd_lookup>
  8010bc:	83 c4 08             	add    $0x8,%esp
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	0f 88 c1 00 00 00    	js     801188 <dup+0xe4>
		return r;
	close(newfdnum);
  8010c7:	83 ec 0c             	sub    $0xc,%esp
  8010ca:	56                   	push   %esi
  8010cb:	e8 84 ff ff ff       	call   801054 <close>

	newfd = INDEX2FD(newfdnum);
  8010d0:	89 f3                	mov    %esi,%ebx
  8010d2:	c1 e3 0c             	shl    $0xc,%ebx
  8010d5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010db:	83 c4 04             	add    $0x4,%esp
  8010de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e1:	e8 de fd ff ff       	call   800ec4 <fd2data>
  8010e6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010e8:	89 1c 24             	mov    %ebx,(%esp)
  8010eb:	e8 d4 fd ff ff       	call   800ec4 <fd2data>
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010f6:	89 f8                	mov    %edi,%eax
  8010f8:	c1 e8 16             	shr    $0x16,%eax
  8010fb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801102:	a8 01                	test   $0x1,%al
  801104:	74 37                	je     80113d <dup+0x99>
  801106:	89 f8                	mov    %edi,%eax
  801108:	c1 e8 0c             	shr    $0xc,%eax
  80110b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801112:	f6 c2 01             	test   $0x1,%dl
  801115:	74 26                	je     80113d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801117:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80111e:	83 ec 0c             	sub    $0xc,%esp
  801121:	25 07 0e 00 00       	and    $0xe07,%eax
  801126:	50                   	push   %eax
  801127:	ff 75 d4             	pushl  -0x2c(%ebp)
  80112a:	6a 00                	push   $0x0
  80112c:	57                   	push   %edi
  80112d:	6a 00                	push   $0x0
  80112f:	e8 d2 fb ff ff       	call   800d06 <sys_page_map>
  801134:	89 c7                	mov    %eax,%edi
  801136:	83 c4 20             	add    $0x20,%esp
  801139:	85 c0                	test   %eax,%eax
  80113b:	78 2e                	js     80116b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80113d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801140:	89 d0                	mov    %edx,%eax
  801142:	c1 e8 0c             	shr    $0xc,%eax
  801145:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80114c:	83 ec 0c             	sub    $0xc,%esp
  80114f:	25 07 0e 00 00       	and    $0xe07,%eax
  801154:	50                   	push   %eax
  801155:	53                   	push   %ebx
  801156:	6a 00                	push   $0x0
  801158:	52                   	push   %edx
  801159:	6a 00                	push   $0x0
  80115b:	e8 a6 fb ff ff       	call   800d06 <sys_page_map>
  801160:	89 c7                	mov    %eax,%edi
  801162:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801165:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801167:	85 ff                	test   %edi,%edi
  801169:	79 1d                	jns    801188 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80116b:	83 ec 08             	sub    $0x8,%esp
  80116e:	53                   	push   %ebx
  80116f:	6a 00                	push   $0x0
  801171:	e8 d2 fb ff ff       	call   800d48 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801176:	83 c4 08             	add    $0x8,%esp
  801179:	ff 75 d4             	pushl  -0x2c(%ebp)
  80117c:	6a 00                	push   $0x0
  80117e:	e8 c5 fb ff ff       	call   800d48 <sys_page_unmap>
	return r;
  801183:	83 c4 10             	add    $0x10,%esp
  801186:	89 f8                	mov    %edi,%eax
}
  801188:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118b:	5b                   	pop    %ebx
  80118c:	5e                   	pop    %esi
  80118d:	5f                   	pop    %edi
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	53                   	push   %ebx
  801194:	83 ec 14             	sub    $0x14,%esp
  801197:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119d:	50                   	push   %eax
  80119e:	53                   	push   %ebx
  80119f:	e8 86 fd ff ff       	call   800f2a <fd_lookup>
  8011a4:	83 c4 08             	add    $0x8,%esp
  8011a7:	89 c2                	mov    %eax,%edx
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	78 6d                	js     80121a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ad:	83 ec 08             	sub    $0x8,%esp
  8011b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b3:	50                   	push   %eax
  8011b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b7:	ff 30                	pushl  (%eax)
  8011b9:	e8 c2 fd ff ff       	call   800f80 <dev_lookup>
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	78 4c                	js     801211 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011c8:	8b 42 08             	mov    0x8(%edx),%eax
  8011cb:	83 e0 03             	and    $0x3,%eax
  8011ce:	83 f8 01             	cmp    $0x1,%eax
  8011d1:	75 21                	jne    8011f4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011d3:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8011d8:	8b 40 48             	mov    0x48(%eax),%eax
  8011db:	83 ec 04             	sub    $0x4,%esp
  8011de:	53                   	push   %ebx
  8011df:	50                   	push   %eax
  8011e0:	68 0d 24 80 00       	push   $0x80240d
  8011e5:	e8 2b f0 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011f2:	eb 26                	jmp    80121a <read+0x8a>
	}
	if (!dev->dev_read)
  8011f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f7:	8b 40 08             	mov    0x8(%eax),%eax
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	74 17                	je     801215 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011fe:	83 ec 04             	sub    $0x4,%esp
  801201:	ff 75 10             	pushl  0x10(%ebp)
  801204:	ff 75 0c             	pushl  0xc(%ebp)
  801207:	52                   	push   %edx
  801208:	ff d0                	call   *%eax
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	eb 09                	jmp    80121a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801211:	89 c2                	mov    %eax,%edx
  801213:	eb 05                	jmp    80121a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801215:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80121a:	89 d0                	mov    %edx,%eax
  80121c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121f:	c9                   	leave  
  801220:	c3                   	ret    

00801221 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	57                   	push   %edi
  801225:	56                   	push   %esi
  801226:	53                   	push   %ebx
  801227:	83 ec 0c             	sub    $0xc,%esp
  80122a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80122d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801230:	bb 00 00 00 00       	mov    $0x0,%ebx
  801235:	eb 21                	jmp    801258 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801237:	83 ec 04             	sub    $0x4,%esp
  80123a:	89 f0                	mov    %esi,%eax
  80123c:	29 d8                	sub    %ebx,%eax
  80123e:	50                   	push   %eax
  80123f:	89 d8                	mov    %ebx,%eax
  801241:	03 45 0c             	add    0xc(%ebp),%eax
  801244:	50                   	push   %eax
  801245:	57                   	push   %edi
  801246:	e8 45 ff ff ff       	call   801190 <read>
		if (m < 0)
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	85 c0                	test   %eax,%eax
  801250:	78 10                	js     801262 <readn+0x41>
			return m;
		if (m == 0)
  801252:	85 c0                	test   %eax,%eax
  801254:	74 0a                	je     801260 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801256:	01 c3                	add    %eax,%ebx
  801258:	39 f3                	cmp    %esi,%ebx
  80125a:	72 db                	jb     801237 <readn+0x16>
  80125c:	89 d8                	mov    %ebx,%eax
  80125e:	eb 02                	jmp    801262 <readn+0x41>
  801260:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801262:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801265:	5b                   	pop    %ebx
  801266:	5e                   	pop    %esi
  801267:	5f                   	pop    %edi
  801268:	5d                   	pop    %ebp
  801269:	c3                   	ret    

0080126a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	53                   	push   %ebx
  80126e:	83 ec 14             	sub    $0x14,%esp
  801271:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801274:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801277:	50                   	push   %eax
  801278:	53                   	push   %ebx
  801279:	e8 ac fc ff ff       	call   800f2a <fd_lookup>
  80127e:	83 c4 08             	add    $0x8,%esp
  801281:	89 c2                	mov    %eax,%edx
  801283:	85 c0                	test   %eax,%eax
  801285:	78 68                	js     8012ef <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801287:	83 ec 08             	sub    $0x8,%esp
  80128a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128d:	50                   	push   %eax
  80128e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801291:	ff 30                	pushl  (%eax)
  801293:	e8 e8 fc ff ff       	call   800f80 <dev_lookup>
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	85 c0                	test   %eax,%eax
  80129d:	78 47                	js     8012e6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80129f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a6:	75 21                	jne    8012c9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a8:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8012ad:	8b 40 48             	mov    0x48(%eax),%eax
  8012b0:	83 ec 04             	sub    $0x4,%esp
  8012b3:	53                   	push   %ebx
  8012b4:	50                   	push   %eax
  8012b5:	68 29 24 80 00       	push   $0x802429
  8012ba:	e8 56 ef ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  8012bf:	83 c4 10             	add    $0x10,%esp
  8012c2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012c7:	eb 26                	jmp    8012ef <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012cc:	8b 52 0c             	mov    0xc(%edx),%edx
  8012cf:	85 d2                	test   %edx,%edx
  8012d1:	74 17                	je     8012ea <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012d3:	83 ec 04             	sub    $0x4,%esp
  8012d6:	ff 75 10             	pushl  0x10(%ebp)
  8012d9:	ff 75 0c             	pushl  0xc(%ebp)
  8012dc:	50                   	push   %eax
  8012dd:	ff d2                	call   *%edx
  8012df:	89 c2                	mov    %eax,%edx
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	eb 09                	jmp    8012ef <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e6:	89 c2                	mov    %eax,%edx
  8012e8:	eb 05                	jmp    8012ef <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012ea:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012ef:	89 d0                	mov    %edx,%eax
  8012f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f4:	c9                   	leave  
  8012f5:	c3                   	ret    

008012f6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012fc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012ff:	50                   	push   %eax
  801300:	ff 75 08             	pushl  0x8(%ebp)
  801303:	e8 22 fc ff ff       	call   800f2a <fd_lookup>
  801308:	83 c4 08             	add    $0x8,%esp
  80130b:	85 c0                	test   %eax,%eax
  80130d:	78 0e                	js     80131d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80130f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801312:	8b 55 0c             	mov    0xc(%ebp),%edx
  801315:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801318:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80131d:	c9                   	leave  
  80131e:	c3                   	ret    

0080131f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	53                   	push   %ebx
  801323:	83 ec 14             	sub    $0x14,%esp
  801326:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801329:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132c:	50                   	push   %eax
  80132d:	53                   	push   %ebx
  80132e:	e8 f7 fb ff ff       	call   800f2a <fd_lookup>
  801333:	83 c4 08             	add    $0x8,%esp
  801336:	89 c2                	mov    %eax,%edx
  801338:	85 c0                	test   %eax,%eax
  80133a:	78 65                	js     8013a1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133c:	83 ec 08             	sub    $0x8,%esp
  80133f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801342:	50                   	push   %eax
  801343:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801346:	ff 30                	pushl  (%eax)
  801348:	e8 33 fc ff ff       	call   800f80 <dev_lookup>
  80134d:	83 c4 10             	add    $0x10,%esp
  801350:	85 c0                	test   %eax,%eax
  801352:	78 44                	js     801398 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801354:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801357:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80135b:	75 21                	jne    80137e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80135d:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801362:	8b 40 48             	mov    0x48(%eax),%eax
  801365:	83 ec 04             	sub    $0x4,%esp
  801368:	53                   	push   %ebx
  801369:	50                   	push   %eax
  80136a:	68 ec 23 80 00       	push   $0x8023ec
  80136f:	e8 a1 ee ff ff       	call   800215 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801374:	83 c4 10             	add    $0x10,%esp
  801377:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80137c:	eb 23                	jmp    8013a1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80137e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801381:	8b 52 18             	mov    0x18(%edx),%edx
  801384:	85 d2                	test   %edx,%edx
  801386:	74 14                	je     80139c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	ff 75 0c             	pushl  0xc(%ebp)
  80138e:	50                   	push   %eax
  80138f:	ff d2                	call   *%edx
  801391:	89 c2                	mov    %eax,%edx
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	eb 09                	jmp    8013a1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801398:	89 c2                	mov    %eax,%edx
  80139a:	eb 05                	jmp    8013a1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80139c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013a1:	89 d0                	mov    %edx,%eax
  8013a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a6:	c9                   	leave  
  8013a7:	c3                   	ret    

008013a8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	53                   	push   %ebx
  8013ac:	83 ec 14             	sub    $0x14,%esp
  8013af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b5:	50                   	push   %eax
  8013b6:	ff 75 08             	pushl  0x8(%ebp)
  8013b9:	e8 6c fb ff ff       	call   800f2a <fd_lookup>
  8013be:	83 c4 08             	add    $0x8,%esp
  8013c1:	89 c2                	mov    %eax,%edx
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	78 58                	js     80141f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c7:	83 ec 08             	sub    $0x8,%esp
  8013ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cd:	50                   	push   %eax
  8013ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d1:	ff 30                	pushl  (%eax)
  8013d3:	e8 a8 fb ff ff       	call   800f80 <dev_lookup>
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	78 37                	js     801416 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013e6:	74 32                	je     80141a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013e8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013eb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013f2:	00 00 00 
	stat->st_isdir = 0;
  8013f5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013fc:	00 00 00 
	stat->st_dev = dev;
  8013ff:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801405:	83 ec 08             	sub    $0x8,%esp
  801408:	53                   	push   %ebx
  801409:	ff 75 f0             	pushl  -0x10(%ebp)
  80140c:	ff 50 14             	call   *0x14(%eax)
  80140f:	89 c2                	mov    %eax,%edx
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	eb 09                	jmp    80141f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801416:	89 c2                	mov    %eax,%edx
  801418:	eb 05                	jmp    80141f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80141a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80141f:	89 d0                	mov    %edx,%eax
  801421:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801424:	c9                   	leave  
  801425:	c3                   	ret    

00801426 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	56                   	push   %esi
  80142a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80142b:	83 ec 08             	sub    $0x8,%esp
  80142e:	6a 00                	push   $0x0
  801430:	ff 75 08             	pushl  0x8(%ebp)
  801433:	e8 2b 02 00 00       	call   801663 <open>
  801438:	89 c3                	mov    %eax,%ebx
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 1b                	js     80145c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801441:	83 ec 08             	sub    $0x8,%esp
  801444:	ff 75 0c             	pushl  0xc(%ebp)
  801447:	50                   	push   %eax
  801448:	e8 5b ff ff ff       	call   8013a8 <fstat>
  80144d:	89 c6                	mov    %eax,%esi
	close(fd);
  80144f:	89 1c 24             	mov    %ebx,(%esp)
  801452:	e8 fd fb ff ff       	call   801054 <close>
	return r;
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	89 f0                	mov    %esi,%eax
}
  80145c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145f:	5b                   	pop    %ebx
  801460:	5e                   	pop    %esi
  801461:	5d                   	pop    %ebp
  801462:	c3                   	ret    

00801463 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801463:	55                   	push   %ebp
  801464:	89 e5                	mov    %esp,%ebp
  801466:	56                   	push   %esi
  801467:	53                   	push   %ebx
  801468:	89 c6                	mov    %eax,%esi
  80146a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80146c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801473:	75 12                	jne    801487 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801475:	83 ec 0c             	sub    $0xc,%esp
  801478:	6a 01                	push   $0x1
  80147a:	e8 26 08 00 00       	call   801ca5 <ipc_find_env>
  80147f:	a3 04 40 80 00       	mov    %eax,0x804004
  801484:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801487:	6a 07                	push   $0x7
  801489:	68 00 50 c0 00       	push   $0xc05000
  80148e:	56                   	push   %esi
  80148f:	ff 35 04 40 80 00    	pushl  0x804004
  801495:	e8 b5 07 00 00       	call   801c4f <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80149a:	83 c4 0c             	add    $0xc,%esp
  80149d:	6a 00                	push   $0x0
  80149f:	53                   	push   %ebx
  8014a0:	6a 00                	push   $0x0
  8014a2:	e8 3f 07 00 00       	call   801be6 <ipc_recv>
}
  8014a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014aa:	5b                   	pop    %ebx
  8014ab:	5e                   	pop    %esi
  8014ac:	5d                   	pop    %ebp
  8014ad:	c3                   	ret    

008014ae <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ba:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  8014bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c2:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cc:	b8 02 00 00 00       	mov    $0x2,%eax
  8014d1:	e8 8d ff ff ff       	call   801463 <fsipc>
}
  8014d6:	c9                   	leave  
  8014d7:	c3                   	ret    

008014d8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014de:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e4:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  8014e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8014f3:	e8 6b ff ff ff       	call   801463 <fsipc>
}
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	53                   	push   %ebx
  8014fe:	83 ec 04             	sub    $0x4,%esp
  801501:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801504:	8b 45 08             	mov    0x8(%ebp),%eax
  801507:	8b 40 0c             	mov    0xc(%eax),%eax
  80150a:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80150f:	ba 00 00 00 00       	mov    $0x0,%edx
  801514:	b8 05 00 00 00       	mov    $0x5,%eax
  801519:	e8 45 ff ff ff       	call   801463 <fsipc>
  80151e:	85 c0                	test   %eax,%eax
  801520:	78 2c                	js     80154e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801522:	83 ec 08             	sub    $0x8,%esp
  801525:	68 00 50 c0 00       	push   $0xc05000
  80152a:	53                   	push   %ebx
  80152b:	e8 19 f3 ff ff       	call   800849 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801530:	a1 80 50 c0 00       	mov    0xc05080,%eax
  801535:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80153b:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801540:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80154e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801551:	c9                   	leave  
  801552:	c3                   	ret    

00801553 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	53                   	push   %ebx
  801557:	83 ec 08             	sub    $0x8,%esp
  80155a:	8b 45 10             	mov    0x10(%ebp),%eax
  80155d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801562:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801567:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80156a:	8b 45 08             	mov    0x8(%ebp),%eax
  80156d:	8b 40 0c             	mov    0xc(%eax),%eax
  801570:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.write.req_n = n;
  801575:	89 1d 04 50 c0 00    	mov    %ebx,0xc05004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80157b:	53                   	push   %ebx
  80157c:	ff 75 0c             	pushl  0xc(%ebp)
  80157f:	68 08 50 c0 00       	push   $0xc05008
  801584:	e8 52 f4 ff ff       	call   8009db <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801589:	ba 00 00 00 00       	mov    $0x0,%edx
  80158e:	b8 04 00 00 00       	mov    $0x4,%eax
  801593:	e8 cb fe ff ff       	call   801463 <fsipc>
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 3d                	js     8015dc <devfile_write+0x89>
		return r;

	assert(r <= n);
  80159f:	39 d8                	cmp    %ebx,%eax
  8015a1:	76 19                	jbe    8015bc <devfile_write+0x69>
  8015a3:	68 58 24 80 00       	push   $0x802458
  8015a8:	68 5f 24 80 00       	push   $0x80245f
  8015ad:	68 9f 00 00 00       	push   $0x9f
  8015b2:	68 74 24 80 00       	push   $0x802474
  8015b7:	e8 80 eb ff ff       	call   80013c <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  8015bc:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015c1:	76 19                	jbe    8015dc <devfile_write+0x89>
  8015c3:	68 8c 24 80 00       	push   $0x80248c
  8015c8:	68 5f 24 80 00       	push   $0x80245f
  8015cd:	68 a0 00 00 00       	push   $0xa0
  8015d2:	68 74 24 80 00       	push   $0x802474
  8015d7:	e8 60 eb ff ff       	call   80013c <_panic>

	return r;
}
  8015dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015df:	c9                   	leave  
  8015e0:	c3                   	ret    

008015e1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	56                   	push   %esi
  8015e5:	53                   	push   %ebx
  8015e6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ef:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  8015f4:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ff:	b8 03 00 00 00       	mov    $0x3,%eax
  801604:	e8 5a fe ff ff       	call   801463 <fsipc>
  801609:	89 c3                	mov    %eax,%ebx
  80160b:	85 c0                	test   %eax,%eax
  80160d:	78 4b                	js     80165a <devfile_read+0x79>
		return r;
	assert(r <= n);
  80160f:	39 c6                	cmp    %eax,%esi
  801611:	73 16                	jae    801629 <devfile_read+0x48>
  801613:	68 58 24 80 00       	push   $0x802458
  801618:	68 5f 24 80 00       	push   $0x80245f
  80161d:	6a 7e                	push   $0x7e
  80161f:	68 74 24 80 00       	push   $0x802474
  801624:	e8 13 eb ff ff       	call   80013c <_panic>
	assert(r <= PGSIZE);
  801629:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80162e:	7e 16                	jle    801646 <devfile_read+0x65>
  801630:	68 7f 24 80 00       	push   $0x80247f
  801635:	68 5f 24 80 00       	push   $0x80245f
  80163a:	6a 7f                	push   $0x7f
  80163c:	68 74 24 80 00       	push   $0x802474
  801641:	e8 f6 ea ff ff       	call   80013c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801646:	83 ec 04             	sub    $0x4,%esp
  801649:	50                   	push   %eax
  80164a:	68 00 50 c0 00       	push   $0xc05000
  80164f:	ff 75 0c             	pushl  0xc(%ebp)
  801652:	e8 84 f3 ff ff       	call   8009db <memmove>
	return r;
  801657:	83 c4 10             	add    $0x10,%esp
}
  80165a:	89 d8                	mov    %ebx,%eax
  80165c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80165f:	5b                   	pop    %ebx
  801660:	5e                   	pop    %esi
  801661:	5d                   	pop    %ebp
  801662:	c3                   	ret    

00801663 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	53                   	push   %ebx
  801667:	83 ec 20             	sub    $0x20,%esp
  80166a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80166d:	53                   	push   %ebx
  80166e:	e8 9d f1 ff ff       	call   800810 <strlen>
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80167b:	7f 67                	jg     8016e4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80167d:	83 ec 0c             	sub    $0xc,%esp
  801680:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801683:	50                   	push   %eax
  801684:	e8 52 f8 ff ff       	call   800edb <fd_alloc>
  801689:	83 c4 10             	add    $0x10,%esp
		return r;
  80168c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80168e:	85 c0                	test   %eax,%eax
  801690:	78 57                	js     8016e9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801692:	83 ec 08             	sub    $0x8,%esp
  801695:	53                   	push   %ebx
  801696:	68 00 50 c0 00       	push   $0xc05000
  80169b:	e8 a9 f1 ff ff       	call   800849 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a3:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8016b0:	e8 ae fd ff ff       	call   801463 <fsipc>
  8016b5:	89 c3                	mov    %eax,%ebx
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	79 14                	jns    8016d2 <open+0x6f>
		fd_close(fd, 0);
  8016be:	83 ec 08             	sub    $0x8,%esp
  8016c1:	6a 00                	push   $0x0
  8016c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8016c6:	e8 08 f9 ff ff       	call   800fd3 <fd_close>
		return r;
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	89 da                	mov    %ebx,%edx
  8016d0:	eb 17                	jmp    8016e9 <open+0x86>
	}

	return fd2num(fd);
  8016d2:	83 ec 0c             	sub    $0xc,%esp
  8016d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8016d8:	e8 d7 f7 ff ff       	call   800eb4 <fd2num>
  8016dd:	89 c2                	mov    %eax,%edx
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	eb 05                	jmp    8016e9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016e4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016e9:	89 d0                	mov    %edx,%eax
  8016eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fb:	b8 08 00 00 00       	mov    $0x8,%eax
  801700:	e8 5e fd ff ff       	call   801463 <fsipc>
}
  801705:	c9                   	leave  
  801706:	c3                   	ret    

00801707 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	56                   	push   %esi
  80170b:	53                   	push   %ebx
  80170c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80170f:	83 ec 0c             	sub    $0xc,%esp
  801712:	ff 75 08             	pushl  0x8(%ebp)
  801715:	e8 aa f7 ff ff       	call   800ec4 <fd2data>
  80171a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80171c:	83 c4 08             	add    $0x8,%esp
  80171f:	68 b9 24 80 00       	push   $0x8024b9
  801724:	53                   	push   %ebx
  801725:	e8 1f f1 ff ff       	call   800849 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80172a:	8b 46 04             	mov    0x4(%esi),%eax
  80172d:	2b 06                	sub    (%esi),%eax
  80172f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801735:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80173c:	00 00 00 
	stat->st_dev = &devpipe;
  80173f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801746:	30 80 00 
	return 0;
}
  801749:	b8 00 00 00 00       	mov    $0x0,%eax
  80174e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801751:	5b                   	pop    %ebx
  801752:	5e                   	pop    %esi
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	53                   	push   %ebx
  801759:	83 ec 0c             	sub    $0xc,%esp
  80175c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80175f:	53                   	push   %ebx
  801760:	6a 00                	push   $0x0
  801762:	e8 e1 f5 ff ff       	call   800d48 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801767:	89 1c 24             	mov    %ebx,(%esp)
  80176a:	e8 55 f7 ff ff       	call   800ec4 <fd2data>
  80176f:	83 c4 08             	add    $0x8,%esp
  801772:	50                   	push   %eax
  801773:	6a 00                	push   $0x0
  801775:	e8 ce f5 ff ff       	call   800d48 <sys_page_unmap>
}
  80177a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177d:	c9                   	leave  
  80177e:	c3                   	ret    

0080177f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	57                   	push   %edi
  801783:	56                   	push   %esi
  801784:	53                   	push   %ebx
  801785:	83 ec 1c             	sub    $0x1c,%esp
  801788:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80178b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80178d:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801792:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801795:	83 ec 0c             	sub    $0xc,%esp
  801798:	ff 75 e0             	pushl  -0x20(%ebp)
  80179b:	e8 3e 05 00 00       	call   801cde <pageref>
  8017a0:	89 c3                	mov    %eax,%ebx
  8017a2:	89 3c 24             	mov    %edi,(%esp)
  8017a5:	e8 34 05 00 00       	call   801cde <pageref>
  8017aa:	83 c4 10             	add    $0x10,%esp
  8017ad:	39 c3                	cmp    %eax,%ebx
  8017af:	0f 94 c1             	sete   %cl
  8017b2:	0f b6 c9             	movzbl %cl,%ecx
  8017b5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8017b8:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  8017be:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017c1:	39 ce                	cmp    %ecx,%esi
  8017c3:	74 1b                	je     8017e0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8017c5:	39 c3                	cmp    %eax,%ebx
  8017c7:	75 c4                	jne    80178d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017c9:	8b 42 58             	mov    0x58(%edx),%eax
  8017cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017cf:	50                   	push   %eax
  8017d0:	56                   	push   %esi
  8017d1:	68 c0 24 80 00       	push   $0x8024c0
  8017d6:	e8 3a ea ff ff       	call   800215 <cprintf>
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	eb ad                	jmp    80178d <_pipeisclosed+0xe>
	}
}
  8017e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e6:	5b                   	pop    %ebx
  8017e7:	5e                   	pop    %esi
  8017e8:	5f                   	pop    %edi
  8017e9:	5d                   	pop    %ebp
  8017ea:	c3                   	ret    

008017eb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	57                   	push   %edi
  8017ef:	56                   	push   %esi
  8017f0:	53                   	push   %ebx
  8017f1:	83 ec 28             	sub    $0x28,%esp
  8017f4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8017f7:	56                   	push   %esi
  8017f8:	e8 c7 f6 ff ff       	call   800ec4 <fd2data>
  8017fd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ff:	83 c4 10             	add    $0x10,%esp
  801802:	bf 00 00 00 00       	mov    $0x0,%edi
  801807:	eb 4b                	jmp    801854 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801809:	89 da                	mov    %ebx,%edx
  80180b:	89 f0                	mov    %esi,%eax
  80180d:	e8 6d ff ff ff       	call   80177f <_pipeisclosed>
  801812:	85 c0                	test   %eax,%eax
  801814:	75 48                	jne    80185e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801816:	e8 89 f4 ff ff       	call   800ca4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80181b:	8b 43 04             	mov    0x4(%ebx),%eax
  80181e:	8b 0b                	mov    (%ebx),%ecx
  801820:	8d 51 20             	lea    0x20(%ecx),%edx
  801823:	39 d0                	cmp    %edx,%eax
  801825:	73 e2                	jae    801809 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801827:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80182a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80182e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801831:	89 c2                	mov    %eax,%edx
  801833:	c1 fa 1f             	sar    $0x1f,%edx
  801836:	89 d1                	mov    %edx,%ecx
  801838:	c1 e9 1b             	shr    $0x1b,%ecx
  80183b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80183e:	83 e2 1f             	and    $0x1f,%edx
  801841:	29 ca                	sub    %ecx,%edx
  801843:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801847:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80184b:	83 c0 01             	add    $0x1,%eax
  80184e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801851:	83 c7 01             	add    $0x1,%edi
  801854:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801857:	75 c2                	jne    80181b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801859:	8b 45 10             	mov    0x10(%ebp),%eax
  80185c:	eb 05                	jmp    801863 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80185e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801863:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801866:	5b                   	pop    %ebx
  801867:	5e                   	pop    %esi
  801868:	5f                   	pop    %edi
  801869:	5d                   	pop    %ebp
  80186a:	c3                   	ret    

0080186b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	57                   	push   %edi
  80186f:	56                   	push   %esi
  801870:	53                   	push   %ebx
  801871:	83 ec 18             	sub    $0x18,%esp
  801874:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801877:	57                   	push   %edi
  801878:	e8 47 f6 ff ff       	call   800ec4 <fd2data>
  80187d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80187f:	83 c4 10             	add    $0x10,%esp
  801882:	bb 00 00 00 00       	mov    $0x0,%ebx
  801887:	eb 3d                	jmp    8018c6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801889:	85 db                	test   %ebx,%ebx
  80188b:	74 04                	je     801891 <devpipe_read+0x26>
				return i;
  80188d:	89 d8                	mov    %ebx,%eax
  80188f:	eb 44                	jmp    8018d5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801891:	89 f2                	mov    %esi,%edx
  801893:	89 f8                	mov    %edi,%eax
  801895:	e8 e5 fe ff ff       	call   80177f <_pipeisclosed>
  80189a:	85 c0                	test   %eax,%eax
  80189c:	75 32                	jne    8018d0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80189e:	e8 01 f4 ff ff       	call   800ca4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8018a3:	8b 06                	mov    (%esi),%eax
  8018a5:	3b 46 04             	cmp    0x4(%esi),%eax
  8018a8:	74 df                	je     801889 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018aa:	99                   	cltd   
  8018ab:	c1 ea 1b             	shr    $0x1b,%edx
  8018ae:	01 d0                	add    %edx,%eax
  8018b0:	83 e0 1f             	and    $0x1f,%eax
  8018b3:	29 d0                	sub    %edx,%eax
  8018b5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8018ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018bd:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8018c0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018c3:	83 c3 01             	add    $0x1,%ebx
  8018c6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8018c9:	75 d8                	jne    8018a3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8018cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8018ce:	eb 05                	jmp    8018d5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018d0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018d8:	5b                   	pop    %ebx
  8018d9:	5e                   	pop    %esi
  8018da:	5f                   	pop    %edi
  8018db:	5d                   	pop    %ebp
  8018dc:	c3                   	ret    

008018dd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	56                   	push   %esi
  8018e1:	53                   	push   %ebx
  8018e2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e8:	50                   	push   %eax
  8018e9:	e8 ed f5 ff ff       	call   800edb <fd_alloc>
  8018ee:	83 c4 10             	add    $0x10,%esp
  8018f1:	89 c2                	mov    %eax,%edx
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	0f 88 2c 01 00 00    	js     801a27 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018fb:	83 ec 04             	sub    $0x4,%esp
  8018fe:	68 07 04 00 00       	push   $0x407
  801903:	ff 75 f4             	pushl  -0xc(%ebp)
  801906:	6a 00                	push   $0x0
  801908:	e8 b6 f3 ff ff       	call   800cc3 <sys_page_alloc>
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	89 c2                	mov    %eax,%edx
  801912:	85 c0                	test   %eax,%eax
  801914:	0f 88 0d 01 00 00    	js     801a27 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80191a:	83 ec 0c             	sub    $0xc,%esp
  80191d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801920:	50                   	push   %eax
  801921:	e8 b5 f5 ff ff       	call   800edb <fd_alloc>
  801926:	89 c3                	mov    %eax,%ebx
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	85 c0                	test   %eax,%eax
  80192d:	0f 88 e2 00 00 00    	js     801a15 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801933:	83 ec 04             	sub    $0x4,%esp
  801936:	68 07 04 00 00       	push   $0x407
  80193b:	ff 75 f0             	pushl  -0x10(%ebp)
  80193e:	6a 00                	push   $0x0
  801940:	e8 7e f3 ff ff       	call   800cc3 <sys_page_alloc>
  801945:	89 c3                	mov    %eax,%ebx
  801947:	83 c4 10             	add    $0x10,%esp
  80194a:	85 c0                	test   %eax,%eax
  80194c:	0f 88 c3 00 00 00    	js     801a15 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801952:	83 ec 0c             	sub    $0xc,%esp
  801955:	ff 75 f4             	pushl  -0xc(%ebp)
  801958:	e8 67 f5 ff ff       	call   800ec4 <fd2data>
  80195d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80195f:	83 c4 0c             	add    $0xc,%esp
  801962:	68 07 04 00 00       	push   $0x407
  801967:	50                   	push   %eax
  801968:	6a 00                	push   $0x0
  80196a:	e8 54 f3 ff ff       	call   800cc3 <sys_page_alloc>
  80196f:	89 c3                	mov    %eax,%ebx
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	85 c0                	test   %eax,%eax
  801976:	0f 88 89 00 00 00    	js     801a05 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80197c:	83 ec 0c             	sub    $0xc,%esp
  80197f:	ff 75 f0             	pushl  -0x10(%ebp)
  801982:	e8 3d f5 ff ff       	call   800ec4 <fd2data>
  801987:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80198e:	50                   	push   %eax
  80198f:	6a 00                	push   $0x0
  801991:	56                   	push   %esi
  801992:	6a 00                	push   $0x0
  801994:	e8 6d f3 ff ff       	call   800d06 <sys_page_map>
  801999:	89 c3                	mov    %eax,%ebx
  80199b:	83 c4 20             	add    $0x20,%esp
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 55                	js     8019f7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019a2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ab:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019b7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8019cc:	83 ec 0c             	sub    $0xc,%esp
  8019cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d2:	e8 dd f4 ff ff       	call   800eb4 <fd2num>
  8019d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019da:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8019dc:	83 c4 04             	add    $0x4,%esp
  8019df:	ff 75 f0             	pushl  -0x10(%ebp)
  8019e2:	e8 cd f4 ff ff       	call   800eb4 <fd2num>
  8019e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ea:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8019ed:	83 c4 10             	add    $0x10,%esp
  8019f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f5:	eb 30                	jmp    801a27 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8019f7:	83 ec 08             	sub    $0x8,%esp
  8019fa:	56                   	push   %esi
  8019fb:	6a 00                	push   $0x0
  8019fd:	e8 46 f3 ff ff       	call   800d48 <sys_page_unmap>
  801a02:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a05:	83 ec 08             	sub    $0x8,%esp
  801a08:	ff 75 f0             	pushl  -0x10(%ebp)
  801a0b:	6a 00                	push   $0x0
  801a0d:	e8 36 f3 ff ff       	call   800d48 <sys_page_unmap>
  801a12:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a15:	83 ec 08             	sub    $0x8,%esp
  801a18:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1b:	6a 00                	push   $0x0
  801a1d:	e8 26 f3 ff ff       	call   800d48 <sys_page_unmap>
  801a22:	83 c4 10             	add    $0x10,%esp
  801a25:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a27:	89 d0                	mov    %edx,%eax
  801a29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2c:	5b                   	pop    %ebx
  801a2d:	5e                   	pop    %esi
  801a2e:	5d                   	pop    %ebp
  801a2f:	c3                   	ret    

00801a30 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a39:	50                   	push   %eax
  801a3a:	ff 75 08             	pushl  0x8(%ebp)
  801a3d:	e8 e8 f4 ff ff       	call   800f2a <fd_lookup>
  801a42:	83 c4 10             	add    $0x10,%esp
  801a45:	85 c0                	test   %eax,%eax
  801a47:	78 18                	js     801a61 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a49:	83 ec 0c             	sub    $0xc,%esp
  801a4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a4f:	e8 70 f4 ff ff       	call   800ec4 <fd2data>
	return _pipeisclosed(fd, p);
  801a54:	89 c2                	mov    %eax,%edx
  801a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a59:	e8 21 fd ff ff       	call   80177f <_pipeisclosed>
  801a5e:	83 c4 10             	add    $0x10,%esp
}
  801a61:	c9                   	leave  
  801a62:	c3                   	ret    

00801a63 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a66:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    

00801a6d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a73:	68 d8 24 80 00       	push   $0x8024d8
  801a78:	ff 75 0c             	pushl  0xc(%ebp)
  801a7b:	e8 c9 ed ff ff       	call   800849 <strcpy>
	return 0;
}
  801a80:	b8 00 00 00 00       	mov    $0x0,%eax
  801a85:	c9                   	leave  
  801a86:	c3                   	ret    

00801a87 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	57                   	push   %edi
  801a8b:	56                   	push   %esi
  801a8c:	53                   	push   %ebx
  801a8d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a93:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a98:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a9e:	eb 2d                	jmp    801acd <devcons_write+0x46>
		m = n - tot;
  801aa0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801aa3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801aa5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801aa8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801aad:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ab0:	83 ec 04             	sub    $0x4,%esp
  801ab3:	53                   	push   %ebx
  801ab4:	03 45 0c             	add    0xc(%ebp),%eax
  801ab7:	50                   	push   %eax
  801ab8:	57                   	push   %edi
  801ab9:	e8 1d ef ff ff       	call   8009db <memmove>
		sys_cputs(buf, m);
  801abe:	83 c4 08             	add    $0x8,%esp
  801ac1:	53                   	push   %ebx
  801ac2:	57                   	push   %edi
  801ac3:	e8 3f f1 ff ff       	call   800c07 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ac8:	01 de                	add    %ebx,%esi
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	89 f0                	mov    %esi,%eax
  801acf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ad2:	72 cc                	jb     801aa0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ad4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad7:	5b                   	pop    %ebx
  801ad8:	5e                   	pop    %esi
  801ad9:	5f                   	pop    %edi
  801ada:	5d                   	pop    %ebp
  801adb:	c3                   	ret    

00801adc <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	83 ec 08             	sub    $0x8,%esp
  801ae2:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ae7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801aeb:	74 2a                	je     801b17 <devcons_read+0x3b>
  801aed:	eb 05                	jmp    801af4 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801aef:	e8 b0 f1 ff ff       	call   800ca4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801af4:	e8 2c f1 ff ff       	call   800c25 <sys_cgetc>
  801af9:	85 c0                	test   %eax,%eax
  801afb:	74 f2                	je     801aef <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801afd:	85 c0                	test   %eax,%eax
  801aff:	78 16                	js     801b17 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b01:	83 f8 04             	cmp    $0x4,%eax
  801b04:	74 0c                	je     801b12 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b06:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b09:	88 02                	mov    %al,(%edx)
	return 1;
  801b0b:	b8 01 00 00 00       	mov    $0x1,%eax
  801b10:	eb 05                	jmp    801b17 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b12:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b17:	c9                   	leave  
  801b18:	c3                   	ret    

00801b19 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b22:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b25:	6a 01                	push   $0x1
  801b27:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b2a:	50                   	push   %eax
  801b2b:	e8 d7 f0 ff ff       	call   800c07 <sys_cputs>
}
  801b30:	83 c4 10             	add    $0x10,%esp
  801b33:	c9                   	leave  
  801b34:	c3                   	ret    

00801b35 <getchar>:

int
getchar(void)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b3b:	6a 01                	push   $0x1
  801b3d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b40:	50                   	push   %eax
  801b41:	6a 00                	push   $0x0
  801b43:	e8 48 f6 ff ff       	call   801190 <read>
	if (r < 0)
  801b48:	83 c4 10             	add    $0x10,%esp
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	78 0f                	js     801b5e <getchar+0x29>
		return r;
	if (r < 1)
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	7e 06                	jle    801b59 <getchar+0x24>
		return -E_EOF;
	return c;
  801b53:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b57:	eb 05                	jmp    801b5e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b59:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b5e:	c9                   	leave  
  801b5f:	c3                   	ret    

00801b60 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b69:	50                   	push   %eax
  801b6a:	ff 75 08             	pushl  0x8(%ebp)
  801b6d:	e8 b8 f3 ff ff       	call   800f2a <fd_lookup>
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	85 c0                	test   %eax,%eax
  801b77:	78 11                	js     801b8a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b82:	39 10                	cmp    %edx,(%eax)
  801b84:	0f 94 c0             	sete   %al
  801b87:	0f b6 c0             	movzbl %al,%eax
}
  801b8a:	c9                   	leave  
  801b8b:	c3                   	ret    

00801b8c <opencons>:

int
opencons(void)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b95:	50                   	push   %eax
  801b96:	e8 40 f3 ff ff       	call   800edb <fd_alloc>
  801b9b:	83 c4 10             	add    $0x10,%esp
		return r;
  801b9e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ba0:	85 c0                	test   %eax,%eax
  801ba2:	78 3e                	js     801be2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ba4:	83 ec 04             	sub    $0x4,%esp
  801ba7:	68 07 04 00 00       	push   $0x407
  801bac:	ff 75 f4             	pushl  -0xc(%ebp)
  801baf:	6a 00                	push   $0x0
  801bb1:	e8 0d f1 ff ff       	call   800cc3 <sys_page_alloc>
  801bb6:	83 c4 10             	add    $0x10,%esp
		return r;
  801bb9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	78 23                	js     801be2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801bbf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bcd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bd4:	83 ec 0c             	sub    $0xc,%esp
  801bd7:	50                   	push   %eax
  801bd8:	e8 d7 f2 ff ff       	call   800eb4 <fd2num>
  801bdd:	89 c2                	mov    %eax,%edx
  801bdf:	83 c4 10             	add    $0x10,%esp
}
  801be2:	89 d0                	mov    %edx,%eax
  801be4:	c9                   	leave  
  801be5:	c3                   	ret    

00801be6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	56                   	push   %esi
  801bea:	53                   	push   %ebx
  801beb:	8b 75 08             	mov    0x8(%ebp),%esi
  801bee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801bf4:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801bf6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801bfb:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801bfe:	83 ec 0c             	sub    $0xc,%esp
  801c01:	50                   	push   %eax
  801c02:	e8 6c f2 ff ff       	call   800e73 <sys_ipc_recv>
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	85 c0                	test   %eax,%eax
  801c0c:	79 16                	jns    801c24 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801c0e:	85 f6                	test   %esi,%esi
  801c10:	74 06                	je     801c18 <ipc_recv+0x32>
			*from_env_store = 0;
  801c12:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801c18:	85 db                	test   %ebx,%ebx
  801c1a:	74 2c                	je     801c48 <ipc_recv+0x62>
			*perm_store = 0;
  801c1c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c22:	eb 24                	jmp    801c48 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801c24:	85 f6                	test   %esi,%esi
  801c26:	74 0a                	je     801c32 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801c28:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801c2d:	8b 40 74             	mov    0x74(%eax),%eax
  801c30:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801c32:	85 db                	test   %ebx,%ebx
  801c34:	74 0a                	je     801c40 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801c36:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801c3b:	8b 40 78             	mov    0x78(%eax),%eax
  801c3e:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801c40:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801c45:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c4b:	5b                   	pop    %ebx
  801c4c:	5e                   	pop    %esi
  801c4d:	5d                   	pop    %ebp
  801c4e:	c3                   	ret    

00801c4f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	57                   	push   %edi
  801c53:	56                   	push   %esi
  801c54:	53                   	push   %ebx
  801c55:	83 ec 0c             	sub    $0xc,%esp
  801c58:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801c61:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801c63:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c68:	0f 44 d8             	cmove  %eax,%ebx
  801c6b:	eb 1e                	jmp    801c8b <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801c6d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c70:	74 14                	je     801c86 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801c72:	83 ec 04             	sub    $0x4,%esp
  801c75:	68 e4 24 80 00       	push   $0x8024e4
  801c7a:	6a 44                	push   $0x44
  801c7c:	68 10 25 80 00       	push   $0x802510
  801c81:	e8 b6 e4 ff ff       	call   80013c <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801c86:	e8 19 f0 ff ff       	call   800ca4 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c8b:	ff 75 14             	pushl  0x14(%ebp)
  801c8e:	53                   	push   %ebx
  801c8f:	56                   	push   %esi
  801c90:	57                   	push   %edi
  801c91:	e8 ba f1 ff ff       	call   800e50 <sys_ipc_try_send>
  801c96:	83 c4 10             	add    $0x10,%esp
  801c99:	85 c0                	test   %eax,%eax
  801c9b:	78 d0                	js     801c6d <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801c9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca0:	5b                   	pop    %ebx
  801ca1:	5e                   	pop    %esi
  801ca2:	5f                   	pop    %edi
  801ca3:	5d                   	pop    %ebp
  801ca4:	c3                   	ret    

00801ca5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
  801ca8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cab:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cb0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cb3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cb9:	8b 52 50             	mov    0x50(%edx),%edx
  801cbc:	39 ca                	cmp    %ecx,%edx
  801cbe:	75 0d                	jne    801ccd <ipc_find_env+0x28>
			return envs[i].env_id;
  801cc0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cc3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801cc8:	8b 40 48             	mov    0x48(%eax),%eax
  801ccb:	eb 0f                	jmp    801cdc <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ccd:	83 c0 01             	add    $0x1,%eax
  801cd0:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cd5:	75 d9                	jne    801cb0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cd7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cdc:	5d                   	pop    %ebp
  801cdd:	c3                   	ret    

00801cde <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ce4:	89 d0                	mov    %edx,%eax
  801ce6:	c1 e8 16             	shr    $0x16,%eax
  801ce9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801cf0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cf5:	f6 c1 01             	test   $0x1,%cl
  801cf8:	74 1d                	je     801d17 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cfa:	c1 ea 0c             	shr    $0xc,%edx
  801cfd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d04:	f6 c2 01             	test   $0x1,%dl
  801d07:	74 0e                	je     801d17 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d09:	c1 ea 0c             	shr    $0xc,%edx
  801d0c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d13:	ef 
  801d14:	0f b7 c0             	movzwl %ax,%eax
}
  801d17:	5d                   	pop    %ebp
  801d18:	c3                   	ret    
  801d19:	66 90                	xchg   %ax,%ax
  801d1b:	66 90                	xchg   %ax,%ax
  801d1d:	66 90                	xchg   %ax,%ax
  801d1f:	90                   	nop

00801d20 <__udivdi3>:
  801d20:	55                   	push   %ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 1c             	sub    $0x1c,%esp
  801d27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801d2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801d2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d37:	85 f6                	test   %esi,%esi
  801d39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d3d:	89 ca                	mov    %ecx,%edx
  801d3f:	89 f8                	mov    %edi,%eax
  801d41:	75 3d                	jne    801d80 <__udivdi3+0x60>
  801d43:	39 cf                	cmp    %ecx,%edi
  801d45:	0f 87 c5 00 00 00    	ja     801e10 <__udivdi3+0xf0>
  801d4b:	85 ff                	test   %edi,%edi
  801d4d:	89 fd                	mov    %edi,%ebp
  801d4f:	75 0b                	jne    801d5c <__udivdi3+0x3c>
  801d51:	b8 01 00 00 00       	mov    $0x1,%eax
  801d56:	31 d2                	xor    %edx,%edx
  801d58:	f7 f7                	div    %edi
  801d5a:	89 c5                	mov    %eax,%ebp
  801d5c:	89 c8                	mov    %ecx,%eax
  801d5e:	31 d2                	xor    %edx,%edx
  801d60:	f7 f5                	div    %ebp
  801d62:	89 c1                	mov    %eax,%ecx
  801d64:	89 d8                	mov    %ebx,%eax
  801d66:	89 cf                	mov    %ecx,%edi
  801d68:	f7 f5                	div    %ebp
  801d6a:	89 c3                	mov    %eax,%ebx
  801d6c:	89 d8                	mov    %ebx,%eax
  801d6e:	89 fa                	mov    %edi,%edx
  801d70:	83 c4 1c             	add    $0x1c,%esp
  801d73:	5b                   	pop    %ebx
  801d74:	5e                   	pop    %esi
  801d75:	5f                   	pop    %edi
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    
  801d78:	90                   	nop
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	39 ce                	cmp    %ecx,%esi
  801d82:	77 74                	ja     801df8 <__udivdi3+0xd8>
  801d84:	0f bd fe             	bsr    %esi,%edi
  801d87:	83 f7 1f             	xor    $0x1f,%edi
  801d8a:	0f 84 98 00 00 00    	je     801e28 <__udivdi3+0x108>
  801d90:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d95:	89 f9                	mov    %edi,%ecx
  801d97:	89 c5                	mov    %eax,%ebp
  801d99:	29 fb                	sub    %edi,%ebx
  801d9b:	d3 e6                	shl    %cl,%esi
  801d9d:	89 d9                	mov    %ebx,%ecx
  801d9f:	d3 ed                	shr    %cl,%ebp
  801da1:	89 f9                	mov    %edi,%ecx
  801da3:	d3 e0                	shl    %cl,%eax
  801da5:	09 ee                	or     %ebp,%esi
  801da7:	89 d9                	mov    %ebx,%ecx
  801da9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dad:	89 d5                	mov    %edx,%ebp
  801daf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801db3:	d3 ed                	shr    %cl,%ebp
  801db5:	89 f9                	mov    %edi,%ecx
  801db7:	d3 e2                	shl    %cl,%edx
  801db9:	89 d9                	mov    %ebx,%ecx
  801dbb:	d3 e8                	shr    %cl,%eax
  801dbd:	09 c2                	or     %eax,%edx
  801dbf:	89 d0                	mov    %edx,%eax
  801dc1:	89 ea                	mov    %ebp,%edx
  801dc3:	f7 f6                	div    %esi
  801dc5:	89 d5                	mov    %edx,%ebp
  801dc7:	89 c3                	mov    %eax,%ebx
  801dc9:	f7 64 24 0c          	mull   0xc(%esp)
  801dcd:	39 d5                	cmp    %edx,%ebp
  801dcf:	72 10                	jb     801de1 <__udivdi3+0xc1>
  801dd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801dd5:	89 f9                	mov    %edi,%ecx
  801dd7:	d3 e6                	shl    %cl,%esi
  801dd9:	39 c6                	cmp    %eax,%esi
  801ddb:	73 07                	jae    801de4 <__udivdi3+0xc4>
  801ddd:	39 d5                	cmp    %edx,%ebp
  801ddf:	75 03                	jne    801de4 <__udivdi3+0xc4>
  801de1:	83 eb 01             	sub    $0x1,%ebx
  801de4:	31 ff                	xor    %edi,%edi
  801de6:	89 d8                	mov    %ebx,%eax
  801de8:	89 fa                	mov    %edi,%edx
  801dea:	83 c4 1c             	add    $0x1c,%esp
  801ded:	5b                   	pop    %ebx
  801dee:	5e                   	pop    %esi
  801def:	5f                   	pop    %edi
  801df0:	5d                   	pop    %ebp
  801df1:	c3                   	ret    
  801df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801df8:	31 ff                	xor    %edi,%edi
  801dfa:	31 db                	xor    %ebx,%ebx
  801dfc:	89 d8                	mov    %ebx,%eax
  801dfe:	89 fa                	mov    %edi,%edx
  801e00:	83 c4 1c             	add    $0x1c,%esp
  801e03:	5b                   	pop    %ebx
  801e04:	5e                   	pop    %esi
  801e05:	5f                   	pop    %edi
  801e06:	5d                   	pop    %ebp
  801e07:	c3                   	ret    
  801e08:	90                   	nop
  801e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e10:	89 d8                	mov    %ebx,%eax
  801e12:	f7 f7                	div    %edi
  801e14:	31 ff                	xor    %edi,%edi
  801e16:	89 c3                	mov    %eax,%ebx
  801e18:	89 d8                	mov    %ebx,%eax
  801e1a:	89 fa                	mov    %edi,%edx
  801e1c:	83 c4 1c             	add    $0x1c,%esp
  801e1f:	5b                   	pop    %ebx
  801e20:	5e                   	pop    %esi
  801e21:	5f                   	pop    %edi
  801e22:	5d                   	pop    %ebp
  801e23:	c3                   	ret    
  801e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e28:	39 ce                	cmp    %ecx,%esi
  801e2a:	72 0c                	jb     801e38 <__udivdi3+0x118>
  801e2c:	31 db                	xor    %ebx,%ebx
  801e2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801e32:	0f 87 34 ff ff ff    	ja     801d6c <__udivdi3+0x4c>
  801e38:	bb 01 00 00 00       	mov    $0x1,%ebx
  801e3d:	e9 2a ff ff ff       	jmp    801d6c <__udivdi3+0x4c>
  801e42:	66 90                	xchg   %ax,%ax
  801e44:	66 90                	xchg   %ax,%ax
  801e46:	66 90                	xchg   %ax,%ax
  801e48:	66 90                	xchg   %ax,%ax
  801e4a:	66 90                	xchg   %ax,%ax
  801e4c:	66 90                	xchg   %ax,%ax
  801e4e:	66 90                	xchg   %ax,%ax

00801e50 <__umoddi3>:
  801e50:	55                   	push   %ebp
  801e51:	57                   	push   %edi
  801e52:	56                   	push   %esi
  801e53:	53                   	push   %ebx
  801e54:	83 ec 1c             	sub    $0x1c,%esp
  801e57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e67:	85 d2                	test   %edx,%edx
  801e69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e71:	89 f3                	mov    %esi,%ebx
  801e73:	89 3c 24             	mov    %edi,(%esp)
  801e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e7a:	75 1c                	jne    801e98 <__umoddi3+0x48>
  801e7c:	39 f7                	cmp    %esi,%edi
  801e7e:	76 50                	jbe    801ed0 <__umoddi3+0x80>
  801e80:	89 c8                	mov    %ecx,%eax
  801e82:	89 f2                	mov    %esi,%edx
  801e84:	f7 f7                	div    %edi
  801e86:	89 d0                	mov    %edx,%eax
  801e88:	31 d2                	xor    %edx,%edx
  801e8a:	83 c4 1c             	add    $0x1c,%esp
  801e8d:	5b                   	pop    %ebx
  801e8e:	5e                   	pop    %esi
  801e8f:	5f                   	pop    %edi
  801e90:	5d                   	pop    %ebp
  801e91:	c3                   	ret    
  801e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e98:	39 f2                	cmp    %esi,%edx
  801e9a:	89 d0                	mov    %edx,%eax
  801e9c:	77 52                	ja     801ef0 <__umoddi3+0xa0>
  801e9e:	0f bd ea             	bsr    %edx,%ebp
  801ea1:	83 f5 1f             	xor    $0x1f,%ebp
  801ea4:	75 5a                	jne    801f00 <__umoddi3+0xb0>
  801ea6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801eaa:	0f 82 e0 00 00 00    	jb     801f90 <__umoddi3+0x140>
  801eb0:	39 0c 24             	cmp    %ecx,(%esp)
  801eb3:	0f 86 d7 00 00 00    	jbe    801f90 <__umoddi3+0x140>
  801eb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ebd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ec1:	83 c4 1c             	add    $0x1c,%esp
  801ec4:	5b                   	pop    %ebx
  801ec5:	5e                   	pop    %esi
  801ec6:	5f                   	pop    %edi
  801ec7:	5d                   	pop    %ebp
  801ec8:	c3                   	ret    
  801ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ed0:	85 ff                	test   %edi,%edi
  801ed2:	89 fd                	mov    %edi,%ebp
  801ed4:	75 0b                	jne    801ee1 <__umoddi3+0x91>
  801ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  801edb:	31 d2                	xor    %edx,%edx
  801edd:	f7 f7                	div    %edi
  801edf:	89 c5                	mov    %eax,%ebp
  801ee1:	89 f0                	mov    %esi,%eax
  801ee3:	31 d2                	xor    %edx,%edx
  801ee5:	f7 f5                	div    %ebp
  801ee7:	89 c8                	mov    %ecx,%eax
  801ee9:	f7 f5                	div    %ebp
  801eeb:	89 d0                	mov    %edx,%eax
  801eed:	eb 99                	jmp    801e88 <__umoddi3+0x38>
  801eef:	90                   	nop
  801ef0:	89 c8                	mov    %ecx,%eax
  801ef2:	89 f2                	mov    %esi,%edx
  801ef4:	83 c4 1c             	add    $0x1c,%esp
  801ef7:	5b                   	pop    %ebx
  801ef8:	5e                   	pop    %esi
  801ef9:	5f                   	pop    %edi
  801efa:	5d                   	pop    %ebp
  801efb:	c3                   	ret    
  801efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f00:	8b 34 24             	mov    (%esp),%esi
  801f03:	bf 20 00 00 00       	mov    $0x20,%edi
  801f08:	89 e9                	mov    %ebp,%ecx
  801f0a:	29 ef                	sub    %ebp,%edi
  801f0c:	d3 e0                	shl    %cl,%eax
  801f0e:	89 f9                	mov    %edi,%ecx
  801f10:	89 f2                	mov    %esi,%edx
  801f12:	d3 ea                	shr    %cl,%edx
  801f14:	89 e9                	mov    %ebp,%ecx
  801f16:	09 c2                	or     %eax,%edx
  801f18:	89 d8                	mov    %ebx,%eax
  801f1a:	89 14 24             	mov    %edx,(%esp)
  801f1d:	89 f2                	mov    %esi,%edx
  801f1f:	d3 e2                	shl    %cl,%edx
  801f21:	89 f9                	mov    %edi,%ecx
  801f23:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f2b:	d3 e8                	shr    %cl,%eax
  801f2d:	89 e9                	mov    %ebp,%ecx
  801f2f:	89 c6                	mov    %eax,%esi
  801f31:	d3 e3                	shl    %cl,%ebx
  801f33:	89 f9                	mov    %edi,%ecx
  801f35:	89 d0                	mov    %edx,%eax
  801f37:	d3 e8                	shr    %cl,%eax
  801f39:	89 e9                	mov    %ebp,%ecx
  801f3b:	09 d8                	or     %ebx,%eax
  801f3d:	89 d3                	mov    %edx,%ebx
  801f3f:	89 f2                	mov    %esi,%edx
  801f41:	f7 34 24             	divl   (%esp)
  801f44:	89 d6                	mov    %edx,%esi
  801f46:	d3 e3                	shl    %cl,%ebx
  801f48:	f7 64 24 04          	mull   0x4(%esp)
  801f4c:	39 d6                	cmp    %edx,%esi
  801f4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f52:	89 d1                	mov    %edx,%ecx
  801f54:	89 c3                	mov    %eax,%ebx
  801f56:	72 08                	jb     801f60 <__umoddi3+0x110>
  801f58:	75 11                	jne    801f6b <__umoddi3+0x11b>
  801f5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801f5e:	73 0b                	jae    801f6b <__umoddi3+0x11b>
  801f60:	2b 44 24 04          	sub    0x4(%esp),%eax
  801f64:	1b 14 24             	sbb    (%esp),%edx
  801f67:	89 d1                	mov    %edx,%ecx
  801f69:	89 c3                	mov    %eax,%ebx
  801f6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f6f:	29 da                	sub    %ebx,%edx
  801f71:	19 ce                	sbb    %ecx,%esi
  801f73:	89 f9                	mov    %edi,%ecx
  801f75:	89 f0                	mov    %esi,%eax
  801f77:	d3 e0                	shl    %cl,%eax
  801f79:	89 e9                	mov    %ebp,%ecx
  801f7b:	d3 ea                	shr    %cl,%edx
  801f7d:	89 e9                	mov    %ebp,%ecx
  801f7f:	d3 ee                	shr    %cl,%esi
  801f81:	09 d0                	or     %edx,%eax
  801f83:	89 f2                	mov    %esi,%edx
  801f85:	83 c4 1c             	add    $0x1c,%esp
  801f88:	5b                   	pop    %ebx
  801f89:	5e                   	pop    %esi
  801f8a:	5f                   	pop    %edi
  801f8b:	5d                   	pop    %ebp
  801f8c:	c3                   	ret    
  801f8d:	8d 76 00             	lea    0x0(%esi),%esi
  801f90:	29 f9                	sub    %edi,%ecx
  801f92:	19 d6                	sbb    %edx,%esi
  801f94:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f9c:	e9 18 ff ff ff       	jmp    801eb9 <__umoddi3+0x69>
