
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 02 0c 00 00       	call   800c44 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 60 23 80 00       	push   $0x802360
  80004c:	e8 83 01 00 00       	call   8001d4 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 4c 07 00 00       	call   8007cf <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 71 23 80 00       	push   $0x802371
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 10 07 00 00       	call   8007b5 <snprintf>
	
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 9c 0e 00 00       	call   800f49 <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 65 00 00 00       	call   800127 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 70 23 80 00       	push   $0x802370
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ec:	e8 53 0b 00 00       	call   800c44 <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 db                	test   %ebx,%ebx
  800105:	7e 07                	jle    80010e <libmain+0x2d>
		binaryname = argv[0];
  800107:	8b 06                	mov    (%esi),%eax
  800109:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	e8 b4 ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  800118:	e8 0a 00 00 00       	call   800127 <exit>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012d:	e8 14 12 00 00       	call   801346 <close_all>
	sys_env_destroy(0);
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	6a 00                	push   $0x0
  800137:	e8 c7 0a 00 00       	call   800c03 <sys_env_destroy>
}
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	53                   	push   %ebx
  800145:	83 ec 04             	sub    $0x4,%esp
  800148:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014b:	8b 13                	mov    (%ebx),%edx
  80014d:	8d 42 01             	lea    0x1(%edx),%eax
  800150:	89 03                	mov    %eax,(%ebx)
  800152:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800155:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800159:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015e:	75 1a                	jne    80017a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	68 ff 00 00 00       	push   $0xff
  800168:	8d 43 08             	lea    0x8(%ebx),%eax
  80016b:	50                   	push   %eax
  80016c:	e8 55 0a 00 00       	call   800bc6 <sys_cputs>
		b->idx = 0;
  800171:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800177:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800193:	00 00 00 
	b.cnt = 0;
  800196:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a0:	ff 75 0c             	pushl  0xc(%ebp)
  8001a3:	ff 75 08             	pushl  0x8(%ebp)
  8001a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ac:	50                   	push   %eax
  8001ad:	68 41 01 80 00       	push   $0x800141
  8001b2:	e8 54 01 00 00       	call   80030b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b7:	83 c4 08             	add    $0x8,%esp
  8001ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	e8 fa 09 00 00       	call   800bc6 <sys_cputs>

	return b.cnt;
}
  8001cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dd:	50                   	push   %eax
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	e8 9d ff ff ff       	call   800183 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 1c             	sub    $0x1c,%esp
  8001f1:	89 c7                	mov    %eax,%edi
  8001f3:	89 d6                	mov    %edx,%esi
  8001f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800201:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800204:	bb 00 00 00 00       	mov    $0x0,%ebx
  800209:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80020c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80020f:	39 d3                	cmp    %edx,%ebx
  800211:	72 05                	jb     800218 <printnum+0x30>
  800213:	39 45 10             	cmp    %eax,0x10(%ebp)
  800216:	77 45                	ja     80025d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	ff 75 18             	pushl  0x18(%ebp)
  80021e:	8b 45 14             	mov    0x14(%ebp),%eax
  800221:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800224:	53                   	push   %ebx
  800225:	ff 75 10             	pushl  0x10(%ebp)
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 84 1e 00 00       	call   8020c0 <__udivdi3>
  80023c:	83 c4 18             	add    $0x18,%esp
  80023f:	52                   	push   %edx
  800240:	50                   	push   %eax
  800241:	89 f2                	mov    %esi,%edx
  800243:	89 f8                	mov    %edi,%eax
  800245:	e8 9e ff ff ff       	call   8001e8 <printnum>
  80024a:	83 c4 20             	add    $0x20,%esp
  80024d:	eb 18                	jmp    800267 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	56                   	push   %esi
  800253:	ff 75 18             	pushl  0x18(%ebp)
  800256:	ff d7                	call   *%edi
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	eb 03                	jmp    800260 <printnum+0x78>
  80025d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800260:	83 eb 01             	sub    $0x1,%ebx
  800263:	85 db                	test   %ebx,%ebx
  800265:	7f e8                	jg     80024f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	56                   	push   %esi
  80026b:	83 ec 04             	sub    $0x4,%esp
  80026e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800271:	ff 75 e0             	pushl  -0x20(%ebp)
  800274:	ff 75 dc             	pushl  -0x24(%ebp)
  800277:	ff 75 d8             	pushl  -0x28(%ebp)
  80027a:	e8 71 1f 00 00       	call   8021f0 <__umoddi3>
  80027f:	83 c4 14             	add    $0x14,%esp
  800282:	0f be 80 80 23 80 00 	movsbl 0x802380(%eax),%eax
  800289:	50                   	push   %eax
  80028a:	ff d7                	call   *%edi
}
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5f                   	pop    %edi
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    

00800297 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80029a:	83 fa 01             	cmp    $0x1,%edx
  80029d:	7e 0e                	jle    8002ad <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 02                	mov    (%edx),%eax
  8002a8:	8b 52 04             	mov    0x4(%edx),%edx
  8002ab:	eb 22                	jmp    8002cf <getuint+0x38>
	else if (lflag)
  8002ad:	85 d2                	test   %edx,%edx
  8002af:	74 10                	je     8002c1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b1:	8b 10                	mov    (%eax),%edx
  8002b3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b6:	89 08                	mov    %ecx,(%eax)
  8002b8:	8b 02                	mov    (%edx),%eax
  8002ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bf:	eb 0e                	jmp    8002cf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c1:	8b 10                	mov    (%eax),%edx
  8002c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c6:	89 08                	mov    %ecx,(%eax)
  8002c8:	8b 02                	mov    (%edx),%eax
  8002ca:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e0:	73 0a                	jae    8002ec <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ea:	88 02                	mov    %al,(%edx)
}
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f7:	50                   	push   %eax
  8002f8:	ff 75 10             	pushl  0x10(%ebp)
  8002fb:	ff 75 0c             	pushl  0xc(%ebp)
  8002fe:	ff 75 08             	pushl  0x8(%ebp)
  800301:	e8 05 00 00 00       	call   80030b <vprintfmt>
	va_end(ap);
}
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	c9                   	leave  
  80030a:	c3                   	ret    

0080030b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	57                   	push   %edi
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
  800311:	83 ec 2c             	sub    $0x2c,%esp
  800314:	8b 75 08             	mov    0x8(%ebp),%esi
  800317:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031d:	eb 12                	jmp    800331 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031f:	85 c0                	test   %eax,%eax
  800321:	0f 84 38 04 00 00    	je     80075f <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800327:	83 ec 08             	sub    $0x8,%esp
  80032a:	53                   	push   %ebx
  80032b:	50                   	push   %eax
  80032c:	ff d6                	call   *%esi
  80032e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800331:	83 c7 01             	add    $0x1,%edi
  800334:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800338:	83 f8 25             	cmp    $0x25,%eax
  80033b:	75 e2                	jne    80031f <vprintfmt+0x14>
  80033d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800341:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800348:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800356:	ba 00 00 00 00       	mov    $0x0,%edx
  80035b:	eb 07                	jmp    800364 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  800360:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8d 47 01             	lea    0x1(%edi),%eax
  800367:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036a:	0f b6 07             	movzbl (%edi),%eax
  80036d:	0f b6 c8             	movzbl %al,%ecx
  800370:	83 e8 23             	sub    $0x23,%eax
  800373:	3c 55                	cmp    $0x55,%al
  800375:	0f 87 c9 03 00 00    	ja     800744 <vprintfmt+0x439>
  80037b:	0f b6 c0             	movzbl %al,%eax
  80037e:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800388:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80038c:	eb d6                	jmp    800364 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  80038e:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  800395:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  80039b:	eb 94                	jmp    800331 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  80039d:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  8003a4:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  8003aa:	eb 85                	jmp    800331 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  8003ac:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  8003b3:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  8003b9:	e9 73 ff ff ff       	jmp    800331 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  8003be:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  8003c5:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  8003cb:	e9 61 ff ff ff       	jmp    800331 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  8003d0:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  8003d7:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  8003dd:	e9 4f ff ff ff       	jmp    800331 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  8003e2:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  8003e9:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  8003ef:	e9 3d ff ff ff       	jmp    800331 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  8003f4:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  8003fb:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  800401:	e9 2b ff ff ff       	jmp    800331 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  800406:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  80040d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  800413:	e9 19 ff ff ff       	jmp    800331 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800418:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  80041f:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  800425:	e9 07 ff ff ff       	jmp    800331 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  80042a:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  800431:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800437:	e9 f5 fe ff ff       	jmp    800331 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800447:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80044a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80044e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800451:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800454:	83 fa 09             	cmp    $0x9,%edx
  800457:	77 3f                	ja     800498 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800459:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80045c:	eb e9                	jmp    800447 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 48 04             	lea    0x4(%eax),%ecx
  800464:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800467:	8b 00                	mov    (%eax),%eax
  800469:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80046f:	eb 2d                	jmp    80049e <vprintfmt+0x193>
  800471:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800474:	85 c0                	test   %eax,%eax
  800476:	b9 00 00 00 00       	mov    $0x0,%ecx
  80047b:	0f 49 c8             	cmovns %eax,%ecx
  80047e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800484:	e9 db fe ff ff       	jmp    800364 <vprintfmt+0x59>
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80048c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800493:	e9 cc fe ff ff       	jmp    800364 <vprintfmt+0x59>
  800498:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80049b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80049e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a2:	0f 89 bc fe ff ff    	jns    800364 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004a8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ae:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b5:	e9 aa fe ff ff       	jmp    800364 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ba:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c0:	e9 9f fe ff ff       	jmp    800364 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 50 04             	lea    0x4(%eax),%edx
  8004cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	53                   	push   %ebx
  8004d2:	ff 30                	pushl  (%eax)
  8004d4:	ff d6                	call   *%esi
			break;
  8004d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004dc:	e9 50 fe ff ff       	jmp    800331 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8d 50 04             	lea    0x4(%eax),%edx
  8004e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ea:	8b 00                	mov    (%eax),%eax
  8004ec:	99                   	cltd   
  8004ed:	31 d0                	xor    %edx,%eax
  8004ef:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f1:	83 f8 0f             	cmp    $0xf,%eax
  8004f4:	7f 0b                	jg     800501 <vprintfmt+0x1f6>
  8004f6:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8004fd:	85 d2                	test   %edx,%edx
  8004ff:	75 18                	jne    800519 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  800501:	50                   	push   %eax
  800502:	68 98 23 80 00       	push   $0x802398
  800507:	53                   	push   %ebx
  800508:	56                   	push   %esi
  800509:	e8 e0 fd ff ff       	call   8002ee <printfmt>
  80050e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800511:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800514:	e9 18 fe ff ff       	jmp    800331 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800519:	52                   	push   %edx
  80051a:	68 05 28 80 00       	push   $0x802805
  80051f:	53                   	push   %ebx
  800520:	56                   	push   %esi
  800521:	e8 c8 fd ff ff       	call   8002ee <printfmt>
  800526:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800529:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052c:	e9 00 fe ff ff       	jmp    800331 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8d 50 04             	lea    0x4(%eax),%edx
  800537:	89 55 14             	mov    %edx,0x14(%ebp)
  80053a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80053c:	85 ff                	test   %edi,%edi
  80053e:	b8 91 23 80 00       	mov    $0x802391,%eax
  800543:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800546:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054a:	0f 8e 94 00 00 00    	jle    8005e4 <vprintfmt+0x2d9>
  800550:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800554:	0f 84 98 00 00 00    	je     8005f2 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	ff 75 d0             	pushl  -0x30(%ebp)
  800560:	57                   	push   %edi
  800561:	e8 81 02 00 00       	call   8007e7 <strnlen>
  800566:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800569:	29 c1                	sub    %eax,%ecx
  80056b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80056e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800571:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800575:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800578:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80057b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057d:	eb 0f                	jmp    80058e <vprintfmt+0x283>
					putch(padc, putdat);
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	53                   	push   %ebx
  800583:	ff 75 e0             	pushl  -0x20(%ebp)
  800586:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800588:	83 ef 01             	sub    $0x1,%edi
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	85 ff                	test   %edi,%edi
  800590:	7f ed                	jg     80057f <vprintfmt+0x274>
  800592:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800595:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800598:	85 c9                	test   %ecx,%ecx
  80059a:	b8 00 00 00 00       	mov    $0x0,%eax
  80059f:	0f 49 c1             	cmovns %ecx,%eax
  8005a2:	29 c1                	sub    %eax,%ecx
  8005a4:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005aa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ad:	89 cb                	mov    %ecx,%ebx
  8005af:	eb 4d                	jmp    8005fe <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b5:	74 1b                	je     8005d2 <vprintfmt+0x2c7>
  8005b7:	0f be c0             	movsbl %al,%eax
  8005ba:	83 e8 20             	sub    $0x20,%eax
  8005bd:	83 f8 5e             	cmp    $0x5e,%eax
  8005c0:	76 10                	jbe    8005d2 <vprintfmt+0x2c7>
					putch('?', putdat);
  8005c2:	83 ec 08             	sub    $0x8,%esp
  8005c5:	ff 75 0c             	pushl  0xc(%ebp)
  8005c8:	6a 3f                	push   $0x3f
  8005ca:	ff 55 08             	call   *0x8(%ebp)
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	eb 0d                	jmp    8005df <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  8005d2:	83 ec 08             	sub    $0x8,%esp
  8005d5:	ff 75 0c             	pushl  0xc(%ebp)
  8005d8:	52                   	push   %edx
  8005d9:	ff 55 08             	call   *0x8(%ebp)
  8005dc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005df:	83 eb 01             	sub    $0x1,%ebx
  8005e2:	eb 1a                	jmp    8005fe <vprintfmt+0x2f3>
  8005e4:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ea:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ed:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f0:	eb 0c                	jmp    8005fe <vprintfmt+0x2f3>
  8005f2:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005fb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005fe:	83 c7 01             	add    $0x1,%edi
  800601:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800605:	0f be d0             	movsbl %al,%edx
  800608:	85 d2                	test   %edx,%edx
  80060a:	74 23                	je     80062f <vprintfmt+0x324>
  80060c:	85 f6                	test   %esi,%esi
  80060e:	78 a1                	js     8005b1 <vprintfmt+0x2a6>
  800610:	83 ee 01             	sub    $0x1,%esi
  800613:	79 9c                	jns    8005b1 <vprintfmt+0x2a6>
  800615:	89 df                	mov    %ebx,%edi
  800617:	8b 75 08             	mov    0x8(%ebp),%esi
  80061a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061d:	eb 18                	jmp    800637 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	53                   	push   %ebx
  800623:	6a 20                	push   $0x20
  800625:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800627:	83 ef 01             	sub    $0x1,%edi
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	eb 08                	jmp    800637 <vprintfmt+0x32c>
  80062f:	89 df                	mov    %ebx,%edi
  800631:	8b 75 08             	mov    0x8(%ebp),%esi
  800634:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800637:	85 ff                	test   %edi,%edi
  800639:	7f e4                	jg     80061f <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063e:	e9 ee fc ff ff       	jmp    800331 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800643:	83 fa 01             	cmp    $0x1,%edx
  800646:	7e 16                	jle    80065e <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8d 50 08             	lea    0x8(%eax),%edx
  80064e:	89 55 14             	mov    %edx,0x14(%ebp)
  800651:	8b 50 04             	mov    0x4(%eax),%edx
  800654:	8b 00                	mov    (%eax),%eax
  800656:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800659:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80065c:	eb 32                	jmp    800690 <vprintfmt+0x385>
	else if (lflag)
  80065e:	85 d2                	test   %edx,%edx
  800660:	74 18                	je     80067a <vprintfmt+0x36f>
		return va_arg(*ap, long);
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 50 04             	lea    0x4(%eax),%edx
  800668:	89 55 14             	mov    %edx,0x14(%ebp)
  80066b:	8b 00                	mov    (%eax),%eax
  80066d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800670:	89 c1                	mov    %eax,%ecx
  800672:	c1 f9 1f             	sar    $0x1f,%ecx
  800675:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800678:	eb 16                	jmp    800690 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 50 04             	lea    0x4(%eax),%edx
  800680:	89 55 14             	mov    %edx,0x14(%ebp)
  800683:	8b 00                	mov    (%eax),%eax
  800685:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800688:	89 c1                	mov    %eax,%ecx
  80068a:	c1 f9 1f             	sar    $0x1f,%ecx
  80068d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800690:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800693:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800696:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80069b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80069f:	79 6f                	jns    800710 <vprintfmt+0x405>
				putch('-', putdat);
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	53                   	push   %ebx
  8006a5:	6a 2d                	push   $0x2d
  8006a7:	ff d6                	call   *%esi
				num = -(long long) num;
  8006a9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ac:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006af:	f7 d8                	neg    %eax
  8006b1:	83 d2 00             	adc    $0x0,%edx
  8006b4:	f7 da                	neg    %edx
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	eb 55                	jmp    800710 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006be:	e8 d4 fb ff ff       	call   800297 <getuint>
			base = 10;
  8006c3:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8006c8:	eb 46                	jmp    800710 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cd:	e8 c5 fb ff ff       	call   800297 <getuint>
			base = 8;
  8006d2:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8006d7:	eb 37                	jmp    800710 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	53                   	push   %ebx
  8006dd:	6a 30                	push   $0x30
  8006df:	ff d6                	call   *%esi
			putch('x', putdat);
  8006e1:	83 c4 08             	add    $0x8,%esp
  8006e4:	53                   	push   %ebx
  8006e5:	6a 78                	push   $0x78
  8006e7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8d 50 04             	lea    0x4(%eax),%edx
  8006ef:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006f2:	8b 00                	mov    (%eax),%eax
  8006f4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006f9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006fc:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800701:	eb 0d                	jmp    800710 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
  800706:	e8 8c fb ff ff       	call   800297 <getuint>
			base = 16;
  80070b:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800710:	83 ec 0c             	sub    $0xc,%esp
  800713:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800717:	51                   	push   %ecx
  800718:	ff 75 e0             	pushl  -0x20(%ebp)
  80071b:	57                   	push   %edi
  80071c:	52                   	push   %edx
  80071d:	50                   	push   %eax
  80071e:	89 da                	mov    %ebx,%edx
  800720:	89 f0                	mov    %esi,%eax
  800722:	e8 c1 fa ff ff       	call   8001e8 <printnum>
			break;
  800727:	83 c4 20             	add    $0x20,%esp
  80072a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80072d:	e9 ff fb ff ff       	jmp    800331 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	53                   	push   %ebx
  800736:	51                   	push   %ecx
  800737:	ff d6                	call   *%esi
			break;
  800739:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80073f:	e9 ed fb ff ff       	jmp    800331 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800744:	83 ec 08             	sub    $0x8,%esp
  800747:	53                   	push   %ebx
  800748:	6a 25                	push   $0x25
  80074a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	eb 03                	jmp    800754 <vprintfmt+0x449>
  800751:	83 ef 01             	sub    $0x1,%edi
  800754:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800758:	75 f7                	jne    800751 <vprintfmt+0x446>
  80075a:	e9 d2 fb ff ff       	jmp    800331 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80075f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800762:	5b                   	pop    %ebx
  800763:	5e                   	pop    %esi
  800764:	5f                   	pop    %edi
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	83 ec 18             	sub    $0x18,%esp
  80076d:	8b 45 08             	mov    0x8(%ebp),%eax
  800770:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800773:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800776:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80077a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800784:	85 c0                	test   %eax,%eax
  800786:	74 26                	je     8007ae <vsnprintf+0x47>
  800788:	85 d2                	test   %edx,%edx
  80078a:	7e 22                	jle    8007ae <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078c:	ff 75 14             	pushl  0x14(%ebp)
  80078f:	ff 75 10             	pushl  0x10(%ebp)
  800792:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800795:	50                   	push   %eax
  800796:	68 d1 02 80 00       	push   $0x8002d1
  80079b:	e8 6b fb ff ff       	call   80030b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a9:	83 c4 10             	add    $0x10,%esp
  8007ac:	eb 05                	jmp    8007b3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007bb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007be:	50                   	push   %eax
  8007bf:	ff 75 10             	pushl  0x10(%ebp)
  8007c2:	ff 75 0c             	pushl  0xc(%ebp)
  8007c5:	ff 75 08             	pushl  0x8(%ebp)
  8007c8:	e8 9a ff ff ff       	call   800767 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007cd:	c9                   	leave  
  8007ce:	c3                   	ret    

008007cf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007da:	eb 03                	jmp    8007df <strlen+0x10>
		n++;
  8007dc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007df:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e3:	75 f7                	jne    8007dc <strlen+0xd>
		n++;
	return n;
}
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ed:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f5:	eb 03                	jmp    8007fa <strnlen+0x13>
		n++;
  8007f7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fa:	39 c2                	cmp    %eax,%edx
  8007fc:	74 08                	je     800806 <strnlen+0x1f>
  8007fe:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800802:	75 f3                	jne    8007f7 <strnlen+0x10>
  800804:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	53                   	push   %ebx
  80080c:	8b 45 08             	mov    0x8(%ebp),%eax
  80080f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800812:	89 c2                	mov    %eax,%edx
  800814:	83 c2 01             	add    $0x1,%edx
  800817:	83 c1 01             	add    $0x1,%ecx
  80081a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80081e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800821:	84 db                	test   %bl,%bl
  800823:	75 ef                	jne    800814 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800825:	5b                   	pop    %ebx
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	53                   	push   %ebx
  80082c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082f:	53                   	push   %ebx
  800830:	e8 9a ff ff ff       	call   8007cf <strlen>
  800835:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800838:	ff 75 0c             	pushl  0xc(%ebp)
  80083b:	01 d8                	add    %ebx,%eax
  80083d:	50                   	push   %eax
  80083e:	e8 c5 ff ff ff       	call   800808 <strcpy>
	return dst;
}
  800843:	89 d8                	mov    %ebx,%eax
  800845:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800848:	c9                   	leave  
  800849:	c3                   	ret    

0080084a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	56                   	push   %esi
  80084e:	53                   	push   %ebx
  80084f:	8b 75 08             	mov    0x8(%ebp),%esi
  800852:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800855:	89 f3                	mov    %esi,%ebx
  800857:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085a:	89 f2                	mov    %esi,%edx
  80085c:	eb 0f                	jmp    80086d <strncpy+0x23>
		*dst++ = *src;
  80085e:	83 c2 01             	add    $0x1,%edx
  800861:	0f b6 01             	movzbl (%ecx),%eax
  800864:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800867:	80 39 01             	cmpb   $0x1,(%ecx)
  80086a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086d:	39 da                	cmp    %ebx,%edx
  80086f:	75 ed                	jne    80085e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800871:	89 f0                	mov    %esi,%eax
  800873:	5b                   	pop    %ebx
  800874:	5e                   	pop    %esi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	56                   	push   %esi
  80087b:	53                   	push   %ebx
  80087c:	8b 75 08             	mov    0x8(%ebp),%esi
  80087f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800882:	8b 55 10             	mov    0x10(%ebp),%edx
  800885:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800887:	85 d2                	test   %edx,%edx
  800889:	74 21                	je     8008ac <strlcpy+0x35>
  80088b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80088f:	89 f2                	mov    %esi,%edx
  800891:	eb 09                	jmp    80089c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800893:	83 c2 01             	add    $0x1,%edx
  800896:	83 c1 01             	add    $0x1,%ecx
  800899:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80089c:	39 c2                	cmp    %eax,%edx
  80089e:	74 09                	je     8008a9 <strlcpy+0x32>
  8008a0:	0f b6 19             	movzbl (%ecx),%ebx
  8008a3:	84 db                	test   %bl,%bl
  8008a5:	75 ec                	jne    800893 <strlcpy+0x1c>
  8008a7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008a9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ac:	29 f0                	sub    %esi,%eax
}
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008bb:	eb 06                	jmp    8008c3 <strcmp+0x11>
		p++, q++;
  8008bd:	83 c1 01             	add    $0x1,%ecx
  8008c0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c3:	0f b6 01             	movzbl (%ecx),%eax
  8008c6:	84 c0                	test   %al,%al
  8008c8:	74 04                	je     8008ce <strcmp+0x1c>
  8008ca:	3a 02                	cmp    (%edx),%al
  8008cc:	74 ef                	je     8008bd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ce:	0f b6 c0             	movzbl %al,%eax
  8008d1:	0f b6 12             	movzbl (%edx),%edx
  8008d4:	29 d0                	sub    %edx,%eax
}
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	53                   	push   %ebx
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e2:	89 c3                	mov    %eax,%ebx
  8008e4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e7:	eb 06                	jmp    8008ef <strncmp+0x17>
		n--, p++, q++;
  8008e9:	83 c0 01             	add    $0x1,%eax
  8008ec:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ef:	39 d8                	cmp    %ebx,%eax
  8008f1:	74 15                	je     800908 <strncmp+0x30>
  8008f3:	0f b6 08             	movzbl (%eax),%ecx
  8008f6:	84 c9                	test   %cl,%cl
  8008f8:	74 04                	je     8008fe <strncmp+0x26>
  8008fa:	3a 0a                	cmp    (%edx),%cl
  8008fc:	74 eb                	je     8008e9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fe:	0f b6 00             	movzbl (%eax),%eax
  800901:	0f b6 12             	movzbl (%edx),%edx
  800904:	29 d0                	sub    %edx,%eax
  800906:	eb 05                	jmp    80090d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800908:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80090d:	5b                   	pop    %ebx
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	8b 45 08             	mov    0x8(%ebp),%eax
  800916:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091a:	eb 07                	jmp    800923 <strchr+0x13>
		if (*s == c)
  80091c:	38 ca                	cmp    %cl,%dl
  80091e:	74 0f                	je     80092f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800920:	83 c0 01             	add    $0x1,%eax
  800923:	0f b6 10             	movzbl (%eax),%edx
  800926:	84 d2                	test   %dl,%dl
  800928:	75 f2                	jne    80091c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80092a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	8b 45 08             	mov    0x8(%ebp),%eax
  800937:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093b:	eb 03                	jmp    800940 <strfind+0xf>
  80093d:	83 c0 01             	add    $0x1,%eax
  800940:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800943:	38 ca                	cmp    %cl,%dl
  800945:	74 04                	je     80094b <strfind+0x1a>
  800947:	84 d2                	test   %dl,%dl
  800949:	75 f2                	jne    80093d <strfind+0xc>
			break;
	return (char *) s;
}
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	57                   	push   %edi
  800951:	56                   	push   %esi
  800952:	53                   	push   %ebx
  800953:	8b 7d 08             	mov    0x8(%ebp),%edi
  800956:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800959:	85 c9                	test   %ecx,%ecx
  80095b:	74 36                	je     800993 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800963:	75 28                	jne    80098d <memset+0x40>
  800965:	f6 c1 03             	test   $0x3,%cl
  800968:	75 23                	jne    80098d <memset+0x40>
		c &= 0xFF;
  80096a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096e:	89 d3                	mov    %edx,%ebx
  800970:	c1 e3 08             	shl    $0x8,%ebx
  800973:	89 d6                	mov    %edx,%esi
  800975:	c1 e6 18             	shl    $0x18,%esi
  800978:	89 d0                	mov    %edx,%eax
  80097a:	c1 e0 10             	shl    $0x10,%eax
  80097d:	09 f0                	or     %esi,%eax
  80097f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800981:	89 d8                	mov    %ebx,%eax
  800983:	09 d0                	or     %edx,%eax
  800985:	c1 e9 02             	shr    $0x2,%ecx
  800988:	fc                   	cld    
  800989:	f3 ab                	rep stos %eax,%es:(%edi)
  80098b:	eb 06                	jmp    800993 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800990:	fc                   	cld    
  800991:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800993:	89 f8                	mov    %edi,%eax
  800995:	5b                   	pop    %ebx
  800996:	5e                   	pop    %esi
  800997:	5f                   	pop    %edi
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	57                   	push   %edi
  80099e:	56                   	push   %esi
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a8:	39 c6                	cmp    %eax,%esi
  8009aa:	73 35                	jae    8009e1 <memmove+0x47>
  8009ac:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009af:	39 d0                	cmp    %edx,%eax
  8009b1:	73 2e                	jae    8009e1 <memmove+0x47>
		s += n;
		d += n;
  8009b3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b6:	89 d6                	mov    %edx,%esi
  8009b8:	09 fe                	or     %edi,%esi
  8009ba:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c0:	75 13                	jne    8009d5 <memmove+0x3b>
  8009c2:	f6 c1 03             	test   $0x3,%cl
  8009c5:	75 0e                	jne    8009d5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009c7:	83 ef 04             	sub    $0x4,%edi
  8009ca:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009cd:	c1 e9 02             	shr    $0x2,%ecx
  8009d0:	fd                   	std    
  8009d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d3:	eb 09                	jmp    8009de <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d5:	83 ef 01             	sub    $0x1,%edi
  8009d8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009db:	fd                   	std    
  8009dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009de:	fc                   	cld    
  8009df:	eb 1d                	jmp    8009fe <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e1:	89 f2                	mov    %esi,%edx
  8009e3:	09 c2                	or     %eax,%edx
  8009e5:	f6 c2 03             	test   $0x3,%dl
  8009e8:	75 0f                	jne    8009f9 <memmove+0x5f>
  8009ea:	f6 c1 03             	test   $0x3,%cl
  8009ed:	75 0a                	jne    8009f9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009ef:	c1 e9 02             	shr    $0x2,%ecx
  8009f2:	89 c7                	mov    %eax,%edi
  8009f4:	fc                   	cld    
  8009f5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f7:	eb 05                	jmp    8009fe <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f9:	89 c7                	mov    %eax,%edi
  8009fb:	fc                   	cld    
  8009fc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fe:	5e                   	pop    %esi
  8009ff:	5f                   	pop    %edi
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a05:	ff 75 10             	pushl  0x10(%ebp)
  800a08:	ff 75 0c             	pushl  0xc(%ebp)
  800a0b:	ff 75 08             	pushl  0x8(%ebp)
  800a0e:	e8 87 ff ff ff       	call   80099a <memmove>
}
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a20:	89 c6                	mov    %eax,%esi
  800a22:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a25:	eb 1a                	jmp    800a41 <memcmp+0x2c>
		if (*s1 != *s2)
  800a27:	0f b6 08             	movzbl (%eax),%ecx
  800a2a:	0f b6 1a             	movzbl (%edx),%ebx
  800a2d:	38 d9                	cmp    %bl,%cl
  800a2f:	74 0a                	je     800a3b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a31:	0f b6 c1             	movzbl %cl,%eax
  800a34:	0f b6 db             	movzbl %bl,%ebx
  800a37:	29 d8                	sub    %ebx,%eax
  800a39:	eb 0f                	jmp    800a4a <memcmp+0x35>
		s1++, s2++;
  800a3b:	83 c0 01             	add    $0x1,%eax
  800a3e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a41:	39 f0                	cmp    %esi,%eax
  800a43:	75 e2                	jne    800a27 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4a:	5b                   	pop    %ebx
  800a4b:	5e                   	pop    %esi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	53                   	push   %ebx
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a55:	89 c1                	mov    %eax,%ecx
  800a57:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5e:	eb 0a                	jmp    800a6a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a60:	0f b6 10             	movzbl (%eax),%edx
  800a63:	39 da                	cmp    %ebx,%edx
  800a65:	74 07                	je     800a6e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a67:	83 c0 01             	add    $0x1,%eax
  800a6a:	39 c8                	cmp    %ecx,%eax
  800a6c:	72 f2                	jb     800a60 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6e:	5b                   	pop    %ebx
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	57                   	push   %edi
  800a75:	56                   	push   %esi
  800a76:	53                   	push   %ebx
  800a77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7d:	eb 03                	jmp    800a82 <strtol+0x11>
		s++;
  800a7f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a82:	0f b6 01             	movzbl (%ecx),%eax
  800a85:	3c 20                	cmp    $0x20,%al
  800a87:	74 f6                	je     800a7f <strtol+0xe>
  800a89:	3c 09                	cmp    $0x9,%al
  800a8b:	74 f2                	je     800a7f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8d:	3c 2b                	cmp    $0x2b,%al
  800a8f:	75 0a                	jne    800a9b <strtol+0x2a>
		s++;
  800a91:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a94:	bf 00 00 00 00       	mov    $0x0,%edi
  800a99:	eb 11                	jmp    800aac <strtol+0x3b>
  800a9b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa0:	3c 2d                	cmp    $0x2d,%al
  800aa2:	75 08                	jne    800aac <strtol+0x3b>
		s++, neg = 1;
  800aa4:	83 c1 01             	add    $0x1,%ecx
  800aa7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aac:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ab2:	75 15                	jne    800ac9 <strtol+0x58>
  800ab4:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab7:	75 10                	jne    800ac9 <strtol+0x58>
  800ab9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800abd:	75 7c                	jne    800b3b <strtol+0xca>
		s += 2, base = 16;
  800abf:	83 c1 02             	add    $0x2,%ecx
  800ac2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac7:	eb 16                	jmp    800adf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ac9:	85 db                	test   %ebx,%ebx
  800acb:	75 12                	jne    800adf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800acd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad5:	75 08                	jne    800adf <strtol+0x6e>
		s++, base = 8;
  800ad7:	83 c1 01             	add    $0x1,%ecx
  800ada:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800adf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae7:	0f b6 11             	movzbl (%ecx),%edx
  800aea:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aed:	89 f3                	mov    %esi,%ebx
  800aef:	80 fb 09             	cmp    $0x9,%bl
  800af2:	77 08                	ja     800afc <strtol+0x8b>
			dig = *s - '0';
  800af4:	0f be d2             	movsbl %dl,%edx
  800af7:	83 ea 30             	sub    $0x30,%edx
  800afa:	eb 22                	jmp    800b1e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800afc:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aff:	89 f3                	mov    %esi,%ebx
  800b01:	80 fb 19             	cmp    $0x19,%bl
  800b04:	77 08                	ja     800b0e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b06:	0f be d2             	movsbl %dl,%edx
  800b09:	83 ea 57             	sub    $0x57,%edx
  800b0c:	eb 10                	jmp    800b1e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b0e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b11:	89 f3                	mov    %esi,%ebx
  800b13:	80 fb 19             	cmp    $0x19,%bl
  800b16:	77 16                	ja     800b2e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b18:	0f be d2             	movsbl %dl,%edx
  800b1b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b1e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b21:	7d 0b                	jge    800b2e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b23:	83 c1 01             	add    $0x1,%ecx
  800b26:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b2a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b2c:	eb b9                	jmp    800ae7 <strtol+0x76>

	if (endptr)
  800b2e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b32:	74 0d                	je     800b41 <strtol+0xd0>
		*endptr = (char *) s;
  800b34:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b37:	89 0e                	mov    %ecx,(%esi)
  800b39:	eb 06                	jmp    800b41 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b3b:	85 db                	test   %ebx,%ebx
  800b3d:	74 98                	je     800ad7 <strtol+0x66>
  800b3f:	eb 9e                	jmp    800adf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b41:	89 c2                	mov    %eax,%edx
  800b43:	f7 da                	neg    %edx
  800b45:	85 ff                	test   %edi,%edi
  800b47:	0f 45 c2             	cmovne %edx,%eax
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
  800b55:	83 ec 04             	sub    $0x4,%esp
  800b58:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800b5b:	57                   	push   %edi
  800b5c:	e8 6e fc ff ff       	call   8007cf <strlen>
  800b61:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b64:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800b67:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b71:	eb 46                	jmp    800bb9 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800b73:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800b77:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b7a:	80 f9 09             	cmp    $0x9,%cl
  800b7d:	77 08                	ja     800b87 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800b7f:	0f be d2             	movsbl %dl,%edx
  800b82:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800b85:	eb 27                	jmp    800bae <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800b87:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800b8a:	80 f9 05             	cmp    $0x5,%cl
  800b8d:	77 08                	ja     800b97 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800b8f:	0f be d2             	movsbl %dl,%edx
  800b92:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800b95:	eb 17                	jmp    800bae <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800b97:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800b9a:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800b9d:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800ba2:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800ba6:	77 06                	ja     800bae <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800ba8:	0f be d2             	movsbl %dl,%edx
  800bab:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800bae:	0f af ce             	imul   %esi,%ecx
  800bb1:	01 c8                	add    %ecx,%eax
		base *= 16;
  800bb3:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800bb6:	83 eb 01             	sub    $0x1,%ebx
  800bb9:	83 fb 01             	cmp    $0x1,%ebx
  800bbc:	7f b5                	jg     800b73 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800bbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	89 c3                	mov    %eax,%ebx
  800bd9:	89 c7                	mov    %eax,%edi
  800bdb:	89 c6                	mov    %eax,%esi
  800bdd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	ba 00 00 00 00       	mov    $0x0,%edx
  800bef:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf4:	89 d1                	mov    %edx,%ecx
  800bf6:	89 d3                	mov    %edx,%ebx
  800bf8:	89 d7                	mov    %edx,%edi
  800bfa:	89 d6                	mov    %edx,%esi
  800bfc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c11:	b8 03 00 00 00       	mov    $0x3,%eax
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	89 cb                	mov    %ecx,%ebx
  800c1b:	89 cf                	mov    %ecx,%edi
  800c1d:	89 ce                	mov    %ecx,%esi
  800c1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7e 17                	jle    800c3c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c25:	83 ec 0c             	sub    $0xc,%esp
  800c28:	50                   	push   %eax
  800c29:	6a 03                	push   $0x3
  800c2b:	68 7f 26 80 00       	push   $0x80267f
  800c30:	6a 23                	push   $0x23
  800c32:	68 9c 26 80 00       	push   $0x80269c
  800c37:	e8 71 12 00 00       	call   801ead <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4f:	b8 02 00 00 00       	mov    $0x2,%eax
  800c54:	89 d1                	mov    %edx,%ecx
  800c56:	89 d3                	mov    %edx,%ebx
  800c58:	89 d7                	mov    %edx,%edi
  800c5a:	89 d6                	mov    %edx,%esi
  800c5c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_yield>:

void
sys_yield(void)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c73:	89 d1                	mov    %edx,%ecx
  800c75:	89 d3                	mov    %edx,%ebx
  800c77:	89 d7                	mov    %edx,%edi
  800c79:	89 d6                	mov    %edx,%esi
  800c7b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	be 00 00 00 00       	mov    $0x0,%esi
  800c90:	b8 04 00 00 00       	mov    $0x4,%eax
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9e:	89 f7                	mov    %esi,%edi
  800ca0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	7e 17                	jle    800cbd <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	50                   	push   %eax
  800caa:	6a 04                	push   $0x4
  800cac:	68 7f 26 80 00       	push   $0x80267f
  800cb1:	6a 23                	push   $0x23
  800cb3:	68 9c 26 80 00       	push   $0x80269c
  800cb8:	e8 f0 11 00 00       	call   801ead <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	b8 05 00 00 00       	mov    $0x5,%eax
  800cd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cdf:	8b 75 18             	mov    0x18(%ebp),%esi
  800ce2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	7e 17                	jle    800cff <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce8:	83 ec 0c             	sub    $0xc,%esp
  800ceb:	50                   	push   %eax
  800cec:	6a 05                	push   $0x5
  800cee:	68 7f 26 80 00       	push   $0x80267f
  800cf3:	6a 23                	push   $0x23
  800cf5:	68 9c 26 80 00       	push   $0x80269c
  800cfa:	e8 ae 11 00 00       	call   801ead <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d15:	b8 06 00 00 00       	mov    $0x6,%eax
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	89 df                	mov    %ebx,%edi
  800d22:	89 de                	mov    %ebx,%esi
  800d24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 17                	jle    800d41 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	83 ec 0c             	sub    $0xc,%esp
  800d2d:	50                   	push   %eax
  800d2e:	6a 06                	push   $0x6
  800d30:	68 7f 26 80 00       	push   $0x80267f
  800d35:	6a 23                	push   $0x23
  800d37:	68 9c 26 80 00       	push   $0x80269c
  800d3c:	e8 6c 11 00 00       	call   801ead <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	57                   	push   %edi
  800d4d:	56                   	push   %esi
  800d4e:	53                   	push   %ebx
  800d4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d57:	b8 08 00 00 00       	mov    $0x8,%eax
  800d5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d62:	89 df                	mov    %ebx,%edi
  800d64:	89 de                	mov    %ebx,%esi
  800d66:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	7e 17                	jle    800d83 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6c:	83 ec 0c             	sub    $0xc,%esp
  800d6f:	50                   	push   %eax
  800d70:	6a 08                	push   $0x8
  800d72:	68 7f 26 80 00       	push   $0x80267f
  800d77:	6a 23                	push   $0x23
  800d79:	68 9c 26 80 00       	push   $0x80269c
  800d7e:	e8 2a 11 00 00       	call   801ead <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d99:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da1:	8b 55 08             	mov    0x8(%ebp),%edx
  800da4:	89 df                	mov    %ebx,%edi
  800da6:	89 de                	mov    %ebx,%esi
  800da8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800daa:	85 c0                	test   %eax,%eax
  800dac:	7e 17                	jle    800dc5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dae:	83 ec 0c             	sub    $0xc,%esp
  800db1:	50                   	push   %eax
  800db2:	6a 0a                	push   $0xa
  800db4:	68 7f 26 80 00       	push   $0x80267f
  800db9:	6a 23                	push   $0x23
  800dbb:	68 9c 26 80 00       	push   $0x80269c
  800dc0:	e8 e8 10 00 00       	call   801ead <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	57                   	push   %edi
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddb:	b8 09 00 00 00       	mov    $0x9,%eax
  800de0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de3:	8b 55 08             	mov    0x8(%ebp),%edx
  800de6:	89 df                	mov    %ebx,%edi
  800de8:	89 de                	mov    %ebx,%esi
  800dea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dec:	85 c0                	test   %eax,%eax
  800dee:	7e 17                	jle    800e07 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df0:	83 ec 0c             	sub    $0xc,%esp
  800df3:	50                   	push   %eax
  800df4:	6a 09                	push   $0x9
  800df6:	68 7f 26 80 00       	push   $0x80267f
  800dfb:	6a 23                	push   $0x23
  800dfd:	68 9c 26 80 00       	push   $0x80269c
  800e02:	e8 a6 10 00 00       	call   801ead <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0a:	5b                   	pop    %ebx
  800e0b:	5e                   	pop    %esi
  800e0c:	5f                   	pop    %edi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	57                   	push   %edi
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e15:	be 00 00 00 00       	mov    $0x0,%esi
  800e1a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e22:	8b 55 08             	mov    0x8(%ebp),%edx
  800e25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e28:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800e3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e40:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e45:	8b 55 08             	mov    0x8(%ebp),%edx
  800e48:	89 cb                	mov    %ecx,%ebx
  800e4a:	89 cf                	mov    %ecx,%edi
  800e4c:	89 ce                	mov    %ecx,%esi
  800e4e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e50:	85 c0                	test   %eax,%eax
  800e52:	7e 17                	jle    800e6b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e54:	83 ec 0c             	sub    $0xc,%esp
  800e57:	50                   	push   %eax
  800e58:	6a 0d                	push   $0xd
  800e5a:	68 7f 26 80 00       	push   $0x80267f
  800e5f:	6a 23                	push   $0x23
  800e61:	68 9c 26 80 00       	push   $0x80269c
  800e66:	e8 42 10 00 00       	call   801ead <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6e:	5b                   	pop    %ebx
  800e6f:	5e                   	pop    %esi
  800e70:	5f                   	pop    %edi
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    

00800e73 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	53                   	push   %ebx
  800e77:	83 ec 04             	sub    $0x4,%esp
  800e7a:	8b 45 08             	mov    0x8(%ebp),%eax

	
	void *addr = (void *) utf->utf_fault_va;
  800e7d:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800e7f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e83:	74 11                	je     800e96 <pgfault+0x23>
  800e85:	89 d8                	mov    %ebx,%eax
  800e87:	c1 e8 0c             	shr    $0xc,%eax
  800e8a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e91:	f6 c4 08             	test   $0x8,%ah
  800e94:	75 14                	jne    800eaa <pgfault+0x37>
		panic("page fault");
  800e96:	83 ec 04             	sub    $0x4,%esp
  800e99:	68 aa 26 80 00       	push   $0x8026aa
  800e9e:	6a 5b                	push   $0x5b
  800ea0:	68 b5 26 80 00       	push   $0x8026b5
  800ea5:	e8 03 10 00 00       	call   801ead <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// allocate a new page and map it at a temporary location
	if((r = sys_page_alloc(0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800eaa:	83 ec 04             	sub    $0x4,%esp
  800ead:	6a 07                	push   $0x7
  800eaf:	68 00 f0 7f 00       	push   $0x7ff000
  800eb4:	6a 00                	push   $0x0
  800eb6:	e8 c7 fd ff ff       	call   800c82 <sys_page_alloc>
  800ebb:	83 c4 10             	add    $0x10,%esp
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	79 12                	jns    800ed4 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800ec2:	50                   	push   %eax
  800ec3:	68 c0 26 80 00       	push   $0x8026c0
  800ec8:	6a 66                	push   $0x66
  800eca:	68 b5 26 80 00       	push   $0x8026b5
  800ecf:	e8 d9 0f 00 00       	call   801ead <_panic>

	// copy date to new page
	//strncpy((char *)PFTEMP, (char *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
	memcpy((void *)PFTEMP, (void *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
  800ed4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800eda:	83 ec 04             	sub    $0x4,%esp
  800edd:	68 00 10 00 00       	push   $0x1000
  800ee2:	53                   	push   %ebx
  800ee3:	68 00 f0 7f 00       	push   $0x7ff000
  800ee8:	e8 15 fb ff ff       	call   800a02 <memcpy>

	// move the new page to the old page's address
	if((r = sys_page_map(0, (void *)PFTEMP, 0, (void *)
  800eed:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ef4:	53                   	push   %ebx
  800ef5:	6a 00                	push   $0x0
  800ef7:	68 00 f0 7f 00       	push   $0x7ff000
  800efc:	6a 00                	push   $0x0
  800efe:	e8 c2 fd ff ff       	call   800cc5 <sys_page_map>
  800f03:	83 c4 20             	add    $0x20,%esp
  800f06:	85 c0                	test   %eax,%eax
  800f08:	79 12                	jns    800f1c <pgfault+0xa9>
		(ROUNDDOWN(addr, PGSIZE)), PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_map: %e", r);
  800f0a:	50                   	push   %eax
  800f0b:	68 d3 26 80 00       	push   $0x8026d3
  800f10:	6a 6f                	push   $0x6f
  800f12:	68 b5 26 80 00       	push   $0x8026b5
  800f17:	e8 91 0f 00 00       	call   801ead <_panic>

	// unmap page on PFTEMP
	if((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800f1c:	83 ec 08             	sub    $0x8,%esp
  800f1f:	68 00 f0 7f 00       	push   $0x7ff000
  800f24:	6a 00                	push   $0x0
  800f26:	e8 dc fd ff ff       	call   800d07 <sys_page_unmap>
  800f2b:	83 c4 10             	add    $0x10,%esp
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	79 12                	jns    800f44 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  800f32:	50                   	push   %eax
  800f33:	68 e4 26 80 00       	push   $0x8026e4
  800f38:	6a 73                	push   $0x73
  800f3a:	68 b5 26 80 00       	push   $0x8026b5
  800f3f:	e8 69 0f 00 00       	call   801ead <_panic>


}
  800f44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f47:	c9                   	leave  
  800f48:	c3                   	ret    

00800f49 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	57                   	push   %edi
  800f4d:	56                   	push   %esi
  800f4e:	53                   	push   %ebx
  800f4f:	83 ec 28             	sub    $0x28,%esp

	#ifdef CHALLENGE 
	set_exception_handler(pgfault, T_PGFLT);
	#else
	// set up page fault handler
	set_pgfault_handler(pgfault);
  800f52:	68 73 0e 80 00       	push   $0x800e73
  800f57:	e8 97 0f 00 00       	call   801ef3 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f5c:	b8 07 00 00 00       	mov    $0x7,%eax
  800f61:	cd 30                	int    $0x30
  800f63:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	#endif

	// create a child
	envid = sys_exofork();
	if (envid < 0)
  800f69:	83 c4 10             	add    $0x10,%esp
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	79 15                	jns    800f85 <fork+0x3c>
		panic("sys_exofork: %e", envid);
  800f70:	50                   	push   %eax
  800f71:	68 f7 26 80 00       	push   $0x8026f7
  800f76:	68 d0 00 00 00       	push   $0xd0
  800f7b:	68 b5 26 80 00       	push   $0x8026b5
  800f80:	e8 28 0f 00 00       	call   801ead <_panic>
  800f85:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f8a:	be 00 08 00 00       	mov    $0x800,%esi
	// we are the child
	if(envid == 0) {
  800f8f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f93:	75 21                	jne    800fb6 <fork+0x6d>
		// the copied valude of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800f95:	e8 aa fc ff ff       	call   800c44 <sys_getenvid>
  800f9a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f9f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fa2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fa7:	a3 08 40 80 00       	mov    %eax,0x804008
		/*// alloc exception stack
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
			PTE_P | PTE_U | PTE_W)) < 0)
			panic("sys_page_alloc: %e", r);*/

		return 0;
  800fac:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb1:	e9 a3 01 00 00       	jmp    801159 <fork+0x210>
{
	int r;

	// LAB 4: Your code here.
	
	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P))
  800fb6:	89 d8                	mov    %ebx,%eax
  800fb8:	c1 e8 16             	shr    $0x16,%eax
  800fbb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc2:	a8 01                	test   $0x1,%al
  800fc4:	0f 84 f0 00 00 00    	je     8010ba <fork+0x171>
		return 0;

	// virtual page pn's page table entry
	pte_t pe = uvpt[pn];
  800fca:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi


	if((pe & PTE_P) && (pe & PTE_U)) {
  800fd1:	89 f8                	mov    %edi,%eax
  800fd3:	83 e0 05             	and    $0x5,%eax
  800fd6:	83 f8 05             	cmp    $0x5,%eax
  800fd9:	0f 85 db 00 00 00    	jne    8010ba <fork+0x171>
		// share with the child environment 
		if(pe & PTE_SHARE) {
  800fdf:	f7 c7 00 04 00 00    	test   $0x400,%edi
  800fe5:	74 36                	je     80101d <fork+0xd4>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  800fe7:	83 ec 0c             	sub    $0xc,%esp
  800fea:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  800ff0:	57                   	push   %edi
  800ff1:	53                   	push   %ebx
  800ff2:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff5:	53                   	push   %ebx
  800ff6:	6a 00                	push   $0x0
  800ff8:	e8 c8 fc ff ff       	call   800cc5 <sys_page_map>
  800ffd:	83 c4 20             	add    $0x20,%esp
  801000:	85 c0                	test   %eax,%eax
  801002:	0f 89 b2 00 00 00    	jns    8010ba <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  801008:	50                   	push   %eax
  801009:	68 07 27 80 00       	push   $0x802707
  80100e:	68 97 00 00 00       	push   $0x97
  801013:	68 b5 26 80 00       	push   $0x8026b5
  801018:	e8 90 0e 00 00       	call   801ead <_panic>
		}
		// the page is writable or copy-on-write
		else if((pe & PTE_W) || (pe & PTE_COW)) {
  80101d:	f7 c7 02 08 00 00    	test   $0x802,%edi
  801023:	74 63                	je     801088 <fork+0x13f>
			// create the child mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, 
  801025:	81 e7 05 06 00 00    	and    $0x605,%edi
  80102b:	81 cf 00 08 00 00    	or     $0x800,%edi
  801031:	83 ec 0c             	sub    $0xc,%esp
  801034:	57                   	push   %edi
  801035:	53                   	push   %ebx
  801036:	ff 75 e4             	pushl  -0x1c(%ebp)
  801039:	53                   	push   %ebx
  80103a:	6a 00                	push   $0x0
  80103c:	e8 84 fc ff ff       	call   800cc5 <sys_page_map>
  801041:	83 c4 20             	add    $0x20,%esp
  801044:	85 c0                	test   %eax,%eax
  801046:	79 15                	jns    80105d <fork+0x114>
				(void *)(pn*PGSIZE), (pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  801048:	50                   	push   %eax
  801049:	68 07 27 80 00       	push   $0x802707
  80104e:	68 9e 00 00 00       	push   $0x9e
  801053:	68 b5 26 80 00       	push   $0x8026b5
  801058:	e8 50 0e 00 00       	call   801ead <_panic>
			// map the parent mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE),
  80105d:	83 ec 0c             	sub    $0xc,%esp
  801060:	57                   	push   %edi
  801061:	53                   	push   %ebx
  801062:	6a 00                	push   $0x0
  801064:	53                   	push   %ebx
  801065:	6a 00                	push   $0x0
  801067:	e8 59 fc ff ff       	call   800cc5 <sys_page_map>
  80106c:	83 c4 20             	add    $0x20,%esp
  80106f:	85 c0                	test   %eax,%eax
  801071:	79 47                	jns    8010ba <fork+0x171>
				(pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  801073:	50                   	push   %eax
  801074:	68 07 27 80 00       	push   $0x802707
  801079:	68 a2 00 00 00       	push   $0xa2
  80107e:	68 b5 26 80 00       	push   $0x8026b5
  801083:	e8 25 0e 00 00       	call   801ead <_panic>
		}	
		else {
			// create the child mapping read only
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  801088:	83 ec 0c             	sub    $0xc,%esp
  80108b:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  801091:	57                   	push   %edi
  801092:	53                   	push   %ebx
  801093:	ff 75 e4             	pushl  -0x1c(%ebp)
  801096:	53                   	push   %ebx
  801097:	6a 00                	push   $0x0
  801099:	e8 27 fc ff ff       	call   800cc5 <sys_page_map>
  80109e:	83 c4 20             	add    $0x20,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	79 15                	jns    8010ba <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  8010a5:	50                   	push   %eax
  8010a6:	68 07 27 80 00       	push   $0x802707
  8010ab:	68 a8 00 00 00       	push   $0xa8
  8010b0:	68 b5 26 80 00       	push   $0x8026b5
  8010b5:	e8 f3 0d 00 00       	call   801ead <_panic>
			panic("sys_page_alloc: %e", r);*/

		return 0;
	}
	// copy address to child environment's page dirctory
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn)
  8010ba:	83 c6 01             	add    $0x1,%esi
  8010bd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010c3:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8010c9:	0f 85 e7 fe ff ff    	jne    800fb6 <fork+0x6d>
	#ifdef CHALLENGE 
	if((r = sys_env_set_exception_upcall(envid, thisenv->env_exception_upcall)) < 0)
		panic("sys_env_set_exception_upcall: %e", r);
	#else
	// set child's page fault handler
	if((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  8010cf:	a1 08 40 80 00       	mov    0x804008,%eax
  8010d4:	8b 40 64             	mov    0x64(%eax),%eax
  8010d7:	83 ec 08             	sub    $0x8,%esp
  8010da:	50                   	push   %eax
  8010db:	ff 75 e0             	pushl  -0x20(%ebp)
  8010de:	e8 ea fc ff ff       	call   800dcd <sys_env_set_pgfault_upcall>
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	79 15                	jns    8010ff <fork+0x1b6>
		panic("sys_env_set_pgfault_upcall: %e", r);
  8010ea:	50                   	push   %eax
  8010eb:	68 40 27 80 00       	push   $0x802740
  8010f0:	68 e9 00 00 00       	push   $0xe9
  8010f5:	68 b5 26 80 00       	push   $0x8026b5
  8010fa:	e8 ae 0d 00 00       	call   801ead <_panic>
	#endif

	// alloc exception stack for child environment
	if((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), 
  8010ff:	83 ec 04             	sub    $0x4,%esp
  801102:	6a 07                	push   $0x7
  801104:	68 00 f0 bf ee       	push   $0xeebff000
  801109:	ff 75 e0             	pushl  -0x20(%ebp)
  80110c:	e8 71 fb ff ff       	call   800c82 <sys_page_alloc>
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	85 c0                	test   %eax,%eax
  801116:	79 15                	jns    80112d <fork+0x1e4>
		PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
  801118:	50                   	push   %eax
  801119:	68 c0 26 80 00       	push   $0x8026c0
  80111e:	68 ef 00 00 00       	push   $0xef
  801123:	68 b5 26 80 00       	push   $0x8026b5
  801128:	e8 80 0d 00 00       	call   801ead <_panic>

	// start the child environment running
	if((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80112d:	83 ec 08             	sub    $0x8,%esp
  801130:	6a 02                	push   $0x2
  801132:	ff 75 e0             	pushl  -0x20(%ebp)
  801135:	e8 0f fc ff ff       	call   800d49 <sys_env_set_status>
  80113a:	83 c4 10             	add    $0x10,%esp
  80113d:	85 c0                	test   %eax,%eax
  80113f:	79 15                	jns    801156 <fork+0x20d>
		panic("sys_env_set_status: %e", r);
  801141:	50                   	push   %eax
  801142:	68 13 27 80 00       	push   $0x802713
  801147:	68 f3 00 00 00       	push   $0xf3
  80114c:	68 b5 26 80 00       	push   $0x8026b5
  801151:	e8 57 0d 00 00       	call   801ead <_panic>

	return envid;
  801156:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801159:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115c:	5b                   	pop    %ebx
  80115d:	5e                   	pop    %esi
  80115e:	5f                   	pop    %edi
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    

00801161 <sfork>:

// Challenge!
int
sfork(void)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801167:	68 2a 27 80 00       	push   $0x80272a
  80116c:	68 fc 00 00 00       	push   $0xfc
  801171:	68 b5 26 80 00       	push   $0x8026b5
  801176:	e8 32 0d 00 00       	call   801ead <_panic>

0080117b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80117e:	8b 45 08             	mov    0x8(%ebp),%eax
  801181:	05 00 00 00 30       	add    $0x30000000,%eax
  801186:	c1 e8 0c             	shr    $0xc,%eax
}
  801189:	5d                   	pop    %ebp
  80118a:	c3                   	ret    

0080118b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80118b:	55                   	push   %ebp
  80118c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80118e:	8b 45 08             	mov    0x8(%ebp),%eax
  801191:	05 00 00 00 30       	add    $0x30000000,%eax
  801196:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80119b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011a0:	5d                   	pop    %ebp
  8011a1:	c3                   	ret    

008011a2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011a2:	55                   	push   %ebp
  8011a3:	89 e5                	mov    %esp,%ebp
  8011a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ad:	89 c2                	mov    %eax,%edx
  8011af:	c1 ea 16             	shr    $0x16,%edx
  8011b2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b9:	f6 c2 01             	test   $0x1,%dl
  8011bc:	74 11                	je     8011cf <fd_alloc+0x2d>
  8011be:	89 c2                	mov    %eax,%edx
  8011c0:	c1 ea 0c             	shr    $0xc,%edx
  8011c3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ca:	f6 c2 01             	test   $0x1,%dl
  8011cd:	75 09                	jne    8011d8 <fd_alloc+0x36>
			*fd_store = fd;
  8011cf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d6:	eb 17                	jmp    8011ef <fd_alloc+0x4d>
  8011d8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011dd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011e2:	75 c9                	jne    8011ad <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011ea:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    

008011f1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f7:	83 f8 1f             	cmp    $0x1f,%eax
  8011fa:	77 36                	ja     801232 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011fc:	c1 e0 0c             	shl    $0xc,%eax
  8011ff:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801204:	89 c2                	mov    %eax,%edx
  801206:	c1 ea 16             	shr    $0x16,%edx
  801209:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801210:	f6 c2 01             	test   $0x1,%dl
  801213:	74 24                	je     801239 <fd_lookup+0x48>
  801215:	89 c2                	mov    %eax,%edx
  801217:	c1 ea 0c             	shr    $0xc,%edx
  80121a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801221:	f6 c2 01             	test   $0x1,%dl
  801224:	74 1a                	je     801240 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801226:	8b 55 0c             	mov    0xc(%ebp),%edx
  801229:	89 02                	mov    %eax,(%edx)
	return 0;
  80122b:	b8 00 00 00 00       	mov    $0x0,%eax
  801230:	eb 13                	jmp    801245 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801232:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801237:	eb 0c                	jmp    801245 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801239:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123e:	eb 05                	jmp    801245 <fd_lookup+0x54>
  801240:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801245:	5d                   	pop    %ebp
  801246:	c3                   	ret    

00801247 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	83 ec 08             	sub    $0x8,%esp
  80124d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801250:	ba dc 27 80 00       	mov    $0x8027dc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801255:	eb 13                	jmp    80126a <dev_lookup+0x23>
  801257:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80125a:	39 08                	cmp    %ecx,(%eax)
  80125c:	75 0c                	jne    80126a <dev_lookup+0x23>
			*dev = devtab[i];
  80125e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801261:	89 01                	mov    %eax,(%ecx)
			return 0;
  801263:	b8 00 00 00 00       	mov    $0x0,%eax
  801268:	eb 2e                	jmp    801298 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80126a:	8b 02                	mov    (%edx),%eax
  80126c:	85 c0                	test   %eax,%eax
  80126e:	75 e7                	jne    801257 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801270:	a1 08 40 80 00       	mov    0x804008,%eax
  801275:	8b 40 48             	mov    0x48(%eax),%eax
  801278:	83 ec 04             	sub    $0x4,%esp
  80127b:	51                   	push   %ecx
  80127c:	50                   	push   %eax
  80127d:	68 60 27 80 00       	push   $0x802760
  801282:	e8 4d ef ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  801287:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801298:	c9                   	leave  
  801299:	c3                   	ret    

0080129a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	56                   	push   %esi
  80129e:	53                   	push   %ebx
  80129f:	83 ec 10             	sub    $0x10,%esp
  8012a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ab:	50                   	push   %eax
  8012ac:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012b2:	c1 e8 0c             	shr    $0xc,%eax
  8012b5:	50                   	push   %eax
  8012b6:	e8 36 ff ff ff       	call   8011f1 <fd_lookup>
  8012bb:	83 c4 08             	add    $0x8,%esp
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	78 05                	js     8012c7 <fd_close+0x2d>
	    || fd != fd2) 
  8012c2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012c5:	74 0c                	je     8012d3 <fd_close+0x39>
		return (must_exist ? r : 0); 
  8012c7:	84 db                	test   %bl,%bl
  8012c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ce:	0f 44 c2             	cmove  %edx,%eax
  8012d1:	eb 41                	jmp    801314 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012d3:	83 ec 08             	sub    $0x8,%esp
  8012d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d9:	50                   	push   %eax
  8012da:	ff 36                	pushl  (%esi)
  8012dc:	e8 66 ff ff ff       	call   801247 <dev_lookup>
  8012e1:	89 c3                	mov    %eax,%ebx
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	78 1a                	js     801304 <fd_close+0x6a>
		if (dev->dev_close) 
  8012ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ed:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8012f0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	74 0b                	je     801304 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012f9:	83 ec 0c             	sub    $0xc,%esp
  8012fc:	56                   	push   %esi
  8012fd:	ff d0                	call   *%eax
  8012ff:	89 c3                	mov    %eax,%ebx
  801301:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	56                   	push   %esi
  801308:	6a 00                	push   $0x0
  80130a:	e8 f8 f9 ff ff       	call   800d07 <sys_page_unmap>
	return r;
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	89 d8                	mov    %ebx,%eax
}
  801314:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801317:	5b                   	pop    %ebx
  801318:	5e                   	pop    %esi
  801319:	5d                   	pop    %ebp
  80131a:	c3                   	ret    

0080131b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801321:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801324:	50                   	push   %eax
  801325:	ff 75 08             	pushl  0x8(%ebp)
  801328:	e8 c4 fe ff ff       	call   8011f1 <fd_lookup>
  80132d:	83 c4 08             	add    $0x8,%esp
  801330:	85 c0                	test   %eax,%eax
  801332:	78 10                	js     801344 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  801334:	83 ec 08             	sub    $0x8,%esp
  801337:	6a 01                	push   $0x1
  801339:	ff 75 f4             	pushl  -0xc(%ebp)
  80133c:	e8 59 ff ff ff       	call   80129a <fd_close>
  801341:	83 c4 10             	add    $0x10,%esp
}
  801344:	c9                   	leave  
  801345:	c3                   	ret    

00801346 <close_all>:

void
close_all(void)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	53                   	push   %ebx
  80134a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80134d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801352:	83 ec 0c             	sub    $0xc,%esp
  801355:	53                   	push   %ebx
  801356:	e8 c0 ff ff ff       	call   80131b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80135b:	83 c3 01             	add    $0x1,%ebx
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	83 fb 20             	cmp    $0x20,%ebx
  801364:	75 ec                	jne    801352 <close_all+0xc>
		close(i);
}
  801366:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801369:	c9                   	leave  
  80136a:	c3                   	ret    

0080136b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	57                   	push   %edi
  80136f:	56                   	push   %esi
  801370:	53                   	push   %ebx
  801371:	83 ec 2c             	sub    $0x2c,%esp
  801374:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801377:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80137a:	50                   	push   %eax
  80137b:	ff 75 08             	pushl  0x8(%ebp)
  80137e:	e8 6e fe ff ff       	call   8011f1 <fd_lookup>
  801383:	83 c4 08             	add    $0x8,%esp
  801386:	85 c0                	test   %eax,%eax
  801388:	0f 88 c1 00 00 00    	js     80144f <dup+0xe4>
		return r;
	close(newfdnum);
  80138e:	83 ec 0c             	sub    $0xc,%esp
  801391:	56                   	push   %esi
  801392:	e8 84 ff ff ff       	call   80131b <close>

	newfd = INDEX2FD(newfdnum);
  801397:	89 f3                	mov    %esi,%ebx
  801399:	c1 e3 0c             	shl    $0xc,%ebx
  80139c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013a2:	83 c4 04             	add    $0x4,%esp
  8013a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013a8:	e8 de fd ff ff       	call   80118b <fd2data>
  8013ad:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013af:	89 1c 24             	mov    %ebx,(%esp)
  8013b2:	e8 d4 fd ff ff       	call   80118b <fd2data>
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013bd:	89 f8                	mov    %edi,%eax
  8013bf:	c1 e8 16             	shr    $0x16,%eax
  8013c2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013c9:	a8 01                	test   $0x1,%al
  8013cb:	74 37                	je     801404 <dup+0x99>
  8013cd:	89 f8                	mov    %edi,%eax
  8013cf:	c1 e8 0c             	shr    $0xc,%eax
  8013d2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013d9:	f6 c2 01             	test   $0x1,%dl
  8013dc:	74 26                	je     801404 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e5:	83 ec 0c             	sub    $0xc,%esp
  8013e8:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ed:	50                   	push   %eax
  8013ee:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f1:	6a 00                	push   $0x0
  8013f3:	57                   	push   %edi
  8013f4:	6a 00                	push   $0x0
  8013f6:	e8 ca f8 ff ff       	call   800cc5 <sys_page_map>
  8013fb:	89 c7                	mov    %eax,%edi
  8013fd:	83 c4 20             	add    $0x20,%esp
  801400:	85 c0                	test   %eax,%eax
  801402:	78 2e                	js     801432 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801404:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801407:	89 d0                	mov    %edx,%eax
  801409:	c1 e8 0c             	shr    $0xc,%eax
  80140c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801413:	83 ec 0c             	sub    $0xc,%esp
  801416:	25 07 0e 00 00       	and    $0xe07,%eax
  80141b:	50                   	push   %eax
  80141c:	53                   	push   %ebx
  80141d:	6a 00                	push   $0x0
  80141f:	52                   	push   %edx
  801420:	6a 00                	push   $0x0
  801422:	e8 9e f8 ff ff       	call   800cc5 <sys_page_map>
  801427:	89 c7                	mov    %eax,%edi
  801429:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80142c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80142e:	85 ff                	test   %edi,%edi
  801430:	79 1d                	jns    80144f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801432:	83 ec 08             	sub    $0x8,%esp
  801435:	53                   	push   %ebx
  801436:	6a 00                	push   $0x0
  801438:	e8 ca f8 ff ff       	call   800d07 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80143d:	83 c4 08             	add    $0x8,%esp
  801440:	ff 75 d4             	pushl  -0x2c(%ebp)
  801443:	6a 00                	push   $0x0
  801445:	e8 bd f8 ff ff       	call   800d07 <sys_page_unmap>
	return r;
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	89 f8                	mov    %edi,%eax
}
  80144f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801452:	5b                   	pop    %ebx
  801453:	5e                   	pop    %esi
  801454:	5f                   	pop    %edi
  801455:	5d                   	pop    %ebp
  801456:	c3                   	ret    

00801457 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	53                   	push   %ebx
  80145b:	83 ec 14             	sub    $0x14,%esp
  80145e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801461:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801464:	50                   	push   %eax
  801465:	53                   	push   %ebx
  801466:	e8 86 fd ff ff       	call   8011f1 <fd_lookup>
  80146b:	83 c4 08             	add    $0x8,%esp
  80146e:	89 c2                	mov    %eax,%edx
  801470:	85 c0                	test   %eax,%eax
  801472:	78 6d                	js     8014e1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801474:	83 ec 08             	sub    $0x8,%esp
  801477:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147e:	ff 30                	pushl  (%eax)
  801480:	e8 c2 fd ff ff       	call   801247 <dev_lookup>
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	85 c0                	test   %eax,%eax
  80148a:	78 4c                	js     8014d8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80148c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80148f:	8b 42 08             	mov    0x8(%edx),%eax
  801492:	83 e0 03             	and    $0x3,%eax
  801495:	83 f8 01             	cmp    $0x1,%eax
  801498:	75 21                	jne    8014bb <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80149a:	a1 08 40 80 00       	mov    0x804008,%eax
  80149f:	8b 40 48             	mov    0x48(%eax),%eax
  8014a2:	83 ec 04             	sub    $0x4,%esp
  8014a5:	53                   	push   %ebx
  8014a6:	50                   	push   %eax
  8014a7:	68 a1 27 80 00       	push   $0x8027a1
  8014ac:	e8 23 ed ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014b9:	eb 26                	jmp    8014e1 <read+0x8a>
	}
	if (!dev->dev_read)
  8014bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014be:	8b 40 08             	mov    0x8(%eax),%eax
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	74 17                	je     8014dc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014c5:	83 ec 04             	sub    $0x4,%esp
  8014c8:	ff 75 10             	pushl  0x10(%ebp)
  8014cb:	ff 75 0c             	pushl  0xc(%ebp)
  8014ce:	52                   	push   %edx
  8014cf:	ff d0                	call   *%eax
  8014d1:	89 c2                	mov    %eax,%edx
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	eb 09                	jmp    8014e1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d8:	89 c2                	mov    %eax,%edx
  8014da:	eb 05                	jmp    8014e1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014e1:	89 d0                	mov    %edx,%eax
  8014e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e6:	c9                   	leave  
  8014e7:	c3                   	ret    

008014e8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	57                   	push   %edi
  8014ec:	56                   	push   %esi
  8014ed:	53                   	push   %ebx
  8014ee:	83 ec 0c             	sub    $0xc,%esp
  8014f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014f4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014fc:	eb 21                	jmp    80151f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014fe:	83 ec 04             	sub    $0x4,%esp
  801501:	89 f0                	mov    %esi,%eax
  801503:	29 d8                	sub    %ebx,%eax
  801505:	50                   	push   %eax
  801506:	89 d8                	mov    %ebx,%eax
  801508:	03 45 0c             	add    0xc(%ebp),%eax
  80150b:	50                   	push   %eax
  80150c:	57                   	push   %edi
  80150d:	e8 45 ff ff ff       	call   801457 <read>
		if (m < 0)
  801512:	83 c4 10             	add    $0x10,%esp
  801515:	85 c0                	test   %eax,%eax
  801517:	78 10                	js     801529 <readn+0x41>
			return m;
		if (m == 0)
  801519:	85 c0                	test   %eax,%eax
  80151b:	74 0a                	je     801527 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80151d:	01 c3                	add    %eax,%ebx
  80151f:	39 f3                	cmp    %esi,%ebx
  801521:	72 db                	jb     8014fe <readn+0x16>
  801523:	89 d8                	mov    %ebx,%eax
  801525:	eb 02                	jmp    801529 <readn+0x41>
  801527:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801529:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152c:	5b                   	pop    %ebx
  80152d:	5e                   	pop    %esi
  80152e:	5f                   	pop    %edi
  80152f:	5d                   	pop    %ebp
  801530:	c3                   	ret    

00801531 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	53                   	push   %ebx
  801535:	83 ec 14             	sub    $0x14,%esp
  801538:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153e:	50                   	push   %eax
  80153f:	53                   	push   %ebx
  801540:	e8 ac fc ff ff       	call   8011f1 <fd_lookup>
  801545:	83 c4 08             	add    $0x8,%esp
  801548:	89 c2                	mov    %eax,%edx
  80154a:	85 c0                	test   %eax,%eax
  80154c:	78 68                	js     8015b6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154e:	83 ec 08             	sub    $0x8,%esp
  801551:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801554:	50                   	push   %eax
  801555:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801558:	ff 30                	pushl  (%eax)
  80155a:	e8 e8 fc ff ff       	call   801247 <dev_lookup>
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	85 c0                	test   %eax,%eax
  801564:	78 47                	js     8015ad <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801566:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801569:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80156d:	75 21                	jne    801590 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80156f:	a1 08 40 80 00       	mov    0x804008,%eax
  801574:	8b 40 48             	mov    0x48(%eax),%eax
  801577:	83 ec 04             	sub    $0x4,%esp
  80157a:	53                   	push   %ebx
  80157b:	50                   	push   %eax
  80157c:	68 bd 27 80 00       	push   $0x8027bd
  801581:	e8 4e ec ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80158e:	eb 26                	jmp    8015b6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801590:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801593:	8b 52 0c             	mov    0xc(%edx),%edx
  801596:	85 d2                	test   %edx,%edx
  801598:	74 17                	je     8015b1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80159a:	83 ec 04             	sub    $0x4,%esp
  80159d:	ff 75 10             	pushl  0x10(%ebp)
  8015a0:	ff 75 0c             	pushl  0xc(%ebp)
  8015a3:	50                   	push   %eax
  8015a4:	ff d2                	call   *%edx
  8015a6:	89 c2                	mov    %eax,%edx
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	eb 09                	jmp    8015b6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ad:	89 c2                	mov    %eax,%edx
  8015af:	eb 05                	jmp    8015b6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015b6:	89 d0                	mov    %edx,%eax
  8015b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bb:	c9                   	leave  
  8015bc:	c3                   	ret    

008015bd <seek>:

int
seek(int fdnum, off_t offset)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
  8015c0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015c6:	50                   	push   %eax
  8015c7:	ff 75 08             	pushl  0x8(%ebp)
  8015ca:	e8 22 fc ff ff       	call   8011f1 <fd_lookup>
  8015cf:	83 c4 08             	add    $0x8,%esp
  8015d2:	85 c0                	test   %eax,%eax
  8015d4:	78 0e                	js     8015e4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015dc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e4:	c9                   	leave  
  8015e5:	c3                   	ret    

008015e6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	53                   	push   %ebx
  8015ea:	83 ec 14             	sub    $0x14,%esp
  8015ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f3:	50                   	push   %eax
  8015f4:	53                   	push   %ebx
  8015f5:	e8 f7 fb ff ff       	call   8011f1 <fd_lookup>
  8015fa:	83 c4 08             	add    $0x8,%esp
  8015fd:	89 c2                	mov    %eax,%edx
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 65                	js     801668 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801603:	83 ec 08             	sub    $0x8,%esp
  801606:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801609:	50                   	push   %eax
  80160a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160d:	ff 30                	pushl  (%eax)
  80160f:	e8 33 fc ff ff       	call   801247 <dev_lookup>
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	85 c0                	test   %eax,%eax
  801619:	78 44                	js     80165f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80161b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801622:	75 21                	jne    801645 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801624:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801629:	8b 40 48             	mov    0x48(%eax),%eax
  80162c:	83 ec 04             	sub    $0x4,%esp
  80162f:	53                   	push   %ebx
  801630:	50                   	push   %eax
  801631:	68 80 27 80 00       	push   $0x802780
  801636:	e8 99 eb ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801643:	eb 23                	jmp    801668 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801645:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801648:	8b 52 18             	mov    0x18(%edx),%edx
  80164b:	85 d2                	test   %edx,%edx
  80164d:	74 14                	je     801663 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80164f:	83 ec 08             	sub    $0x8,%esp
  801652:	ff 75 0c             	pushl  0xc(%ebp)
  801655:	50                   	push   %eax
  801656:	ff d2                	call   *%edx
  801658:	89 c2                	mov    %eax,%edx
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	eb 09                	jmp    801668 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165f:	89 c2                	mov    %eax,%edx
  801661:	eb 05                	jmp    801668 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801663:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801668:	89 d0                	mov    %edx,%eax
  80166a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166d:	c9                   	leave  
  80166e:	c3                   	ret    

0080166f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	53                   	push   %ebx
  801673:	83 ec 14             	sub    $0x14,%esp
  801676:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801679:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167c:	50                   	push   %eax
  80167d:	ff 75 08             	pushl  0x8(%ebp)
  801680:	e8 6c fb ff ff       	call   8011f1 <fd_lookup>
  801685:	83 c4 08             	add    $0x8,%esp
  801688:	89 c2                	mov    %eax,%edx
  80168a:	85 c0                	test   %eax,%eax
  80168c:	78 58                	js     8016e6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168e:	83 ec 08             	sub    $0x8,%esp
  801691:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801694:	50                   	push   %eax
  801695:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801698:	ff 30                	pushl  (%eax)
  80169a:	e8 a8 fb ff ff       	call   801247 <dev_lookup>
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	78 37                	js     8016dd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016ad:	74 32                	je     8016e1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016af:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016b2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016b9:	00 00 00 
	stat->st_isdir = 0;
  8016bc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016c3:	00 00 00 
	stat->st_dev = dev;
  8016c6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016cc:	83 ec 08             	sub    $0x8,%esp
  8016cf:	53                   	push   %ebx
  8016d0:	ff 75 f0             	pushl  -0x10(%ebp)
  8016d3:	ff 50 14             	call   *0x14(%eax)
  8016d6:	89 c2                	mov    %eax,%edx
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	eb 09                	jmp    8016e6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016dd:	89 c2                	mov    %eax,%edx
  8016df:	eb 05                	jmp    8016e6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016e1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016e6:	89 d0                	mov    %edx,%eax
  8016e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016eb:	c9                   	leave  
  8016ec:	c3                   	ret    

008016ed <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	56                   	push   %esi
  8016f1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016f2:	83 ec 08             	sub    $0x8,%esp
  8016f5:	6a 00                	push   $0x0
  8016f7:	ff 75 08             	pushl  0x8(%ebp)
  8016fa:	e8 2b 02 00 00       	call   80192a <open>
  8016ff:	89 c3                	mov    %eax,%ebx
  801701:	83 c4 10             	add    $0x10,%esp
  801704:	85 c0                	test   %eax,%eax
  801706:	78 1b                	js     801723 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801708:	83 ec 08             	sub    $0x8,%esp
  80170b:	ff 75 0c             	pushl  0xc(%ebp)
  80170e:	50                   	push   %eax
  80170f:	e8 5b ff ff ff       	call   80166f <fstat>
  801714:	89 c6                	mov    %eax,%esi
	close(fd);
  801716:	89 1c 24             	mov    %ebx,(%esp)
  801719:	e8 fd fb ff ff       	call   80131b <close>
	return r;
  80171e:	83 c4 10             	add    $0x10,%esp
  801721:	89 f0                	mov    %esi,%eax
}
  801723:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801726:	5b                   	pop    %ebx
  801727:	5e                   	pop    %esi
  801728:	5d                   	pop    %ebp
  801729:	c3                   	ret    

0080172a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	56                   	push   %esi
  80172e:	53                   	push   %ebx
  80172f:	89 c6                	mov    %eax,%esi
  801731:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801733:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80173a:	75 12                	jne    80174e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80173c:	83 ec 0c             	sub    $0xc,%esp
  80173f:	6a 01                	push   $0x1
  801741:	e8 fb 08 00 00       	call   802041 <ipc_find_env>
  801746:	a3 04 40 80 00       	mov    %eax,0x804004
  80174b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80174e:	6a 07                	push   $0x7
  801750:	68 00 50 80 00       	push   $0x805000
  801755:	56                   	push   %esi
  801756:	ff 35 04 40 80 00    	pushl  0x804004
  80175c:	e8 8a 08 00 00       	call   801feb <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801761:	83 c4 0c             	add    $0xc,%esp
  801764:	6a 00                	push   $0x0
  801766:	53                   	push   %ebx
  801767:	6a 00                	push   $0x0
  801769:	e8 14 08 00 00       	call   801f82 <ipc_recv>
}
  80176e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801771:	5b                   	pop    %ebx
  801772:	5e                   	pop    %esi
  801773:	5d                   	pop    %ebp
  801774:	c3                   	ret    

00801775 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80177b:	8b 45 08             	mov    0x8(%ebp),%eax
  80177e:	8b 40 0c             	mov    0xc(%eax),%eax
  801781:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801786:	8b 45 0c             	mov    0xc(%ebp),%eax
  801789:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80178e:	ba 00 00 00 00       	mov    $0x0,%edx
  801793:	b8 02 00 00 00       	mov    $0x2,%eax
  801798:	e8 8d ff ff ff       	call   80172a <fsipc>
}
  80179d:	c9                   	leave  
  80179e:	c3                   	ret    

0080179f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80179f:	55                   	push   %ebp
  8017a0:	89 e5                	mov    %esp,%ebp
  8017a2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ab:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b5:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ba:	e8 6b ff ff ff       	call   80172a <fsipc>
}
  8017bf:	c9                   	leave  
  8017c0:	c3                   	ret    

008017c1 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017c1:	55                   	push   %ebp
  8017c2:	89 e5                	mov    %esp,%ebp
  8017c4:	53                   	push   %ebx
  8017c5:	83 ec 04             	sub    $0x4,%esp
  8017c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017db:	b8 05 00 00 00       	mov    $0x5,%eax
  8017e0:	e8 45 ff ff ff       	call   80172a <fsipc>
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	78 2c                	js     801815 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017e9:	83 ec 08             	sub    $0x8,%esp
  8017ec:	68 00 50 80 00       	push   $0x805000
  8017f1:	53                   	push   %ebx
  8017f2:	e8 11 f0 ff ff       	call   800808 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017f7:	a1 80 50 80 00       	mov    0x805080,%eax
  8017fc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801802:	a1 84 50 80 00       	mov    0x805084,%eax
  801807:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801815:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	53                   	push   %ebx
  80181e:	83 ec 08             	sub    $0x8,%esp
  801821:	8b 45 10             	mov    0x10(%ebp),%eax
  801824:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801829:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80182e:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801831:	8b 45 08             	mov    0x8(%ebp),%eax
  801834:	8b 40 0c             	mov    0xc(%eax),%eax
  801837:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  80183c:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801842:	53                   	push   %ebx
  801843:	ff 75 0c             	pushl  0xc(%ebp)
  801846:	68 08 50 80 00       	push   $0x805008
  80184b:	e8 4a f1 ff ff       	call   80099a <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801850:	ba 00 00 00 00       	mov    $0x0,%edx
  801855:	b8 04 00 00 00       	mov    $0x4,%eax
  80185a:	e8 cb fe ff ff       	call   80172a <fsipc>
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	85 c0                	test   %eax,%eax
  801864:	78 3d                	js     8018a3 <devfile_write+0x89>
		return r;

	assert(r <= n);
  801866:	39 d8                	cmp    %ebx,%eax
  801868:	76 19                	jbe    801883 <devfile_write+0x69>
  80186a:	68 ec 27 80 00       	push   $0x8027ec
  80186f:	68 f3 27 80 00       	push   $0x8027f3
  801874:	68 9f 00 00 00       	push   $0x9f
  801879:	68 08 28 80 00       	push   $0x802808
  80187e:	e8 2a 06 00 00       	call   801ead <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801883:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801888:	76 19                	jbe    8018a3 <devfile_write+0x89>
  80188a:	68 20 28 80 00       	push   $0x802820
  80188f:	68 f3 27 80 00       	push   $0x8027f3
  801894:	68 a0 00 00 00       	push   $0xa0
  801899:	68 08 28 80 00       	push   $0x802808
  80189e:	e8 0a 06 00 00       	call   801ead <_panic>

	return r;
}
  8018a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a6:	c9                   	leave  
  8018a7:	c3                   	ret    

008018a8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	56                   	push   %esi
  8018ac:	53                   	push   %ebx
  8018ad:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018bb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c6:	b8 03 00 00 00       	mov    $0x3,%eax
  8018cb:	e8 5a fe ff ff       	call   80172a <fsipc>
  8018d0:	89 c3                	mov    %eax,%ebx
  8018d2:	85 c0                	test   %eax,%eax
  8018d4:	78 4b                	js     801921 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018d6:	39 c6                	cmp    %eax,%esi
  8018d8:	73 16                	jae    8018f0 <devfile_read+0x48>
  8018da:	68 ec 27 80 00       	push   $0x8027ec
  8018df:	68 f3 27 80 00       	push   $0x8027f3
  8018e4:	6a 7e                	push   $0x7e
  8018e6:	68 08 28 80 00       	push   $0x802808
  8018eb:	e8 bd 05 00 00       	call   801ead <_panic>
	assert(r <= PGSIZE);
  8018f0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018f5:	7e 16                	jle    80190d <devfile_read+0x65>
  8018f7:	68 13 28 80 00       	push   $0x802813
  8018fc:	68 f3 27 80 00       	push   $0x8027f3
  801901:	6a 7f                	push   $0x7f
  801903:	68 08 28 80 00       	push   $0x802808
  801908:	e8 a0 05 00 00       	call   801ead <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80190d:	83 ec 04             	sub    $0x4,%esp
  801910:	50                   	push   %eax
  801911:	68 00 50 80 00       	push   $0x805000
  801916:	ff 75 0c             	pushl  0xc(%ebp)
  801919:	e8 7c f0 ff ff       	call   80099a <memmove>
	return r;
  80191e:	83 c4 10             	add    $0x10,%esp
}
  801921:	89 d8                	mov    %ebx,%eax
  801923:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801926:	5b                   	pop    %ebx
  801927:	5e                   	pop    %esi
  801928:	5d                   	pop    %ebp
  801929:	c3                   	ret    

0080192a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	53                   	push   %ebx
  80192e:	83 ec 20             	sub    $0x20,%esp
  801931:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801934:	53                   	push   %ebx
  801935:	e8 95 ee ff ff       	call   8007cf <strlen>
  80193a:	83 c4 10             	add    $0x10,%esp
  80193d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801942:	7f 67                	jg     8019ab <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801944:	83 ec 0c             	sub    $0xc,%esp
  801947:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194a:	50                   	push   %eax
  80194b:	e8 52 f8 ff ff       	call   8011a2 <fd_alloc>
  801950:	83 c4 10             	add    $0x10,%esp
		return r;
  801953:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801955:	85 c0                	test   %eax,%eax
  801957:	78 57                	js     8019b0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801959:	83 ec 08             	sub    $0x8,%esp
  80195c:	53                   	push   %ebx
  80195d:	68 00 50 80 00       	push   $0x805000
  801962:	e8 a1 ee ff ff       	call   800808 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801967:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80196f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801972:	b8 01 00 00 00       	mov    $0x1,%eax
  801977:	e8 ae fd ff ff       	call   80172a <fsipc>
  80197c:	89 c3                	mov    %eax,%ebx
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	85 c0                	test   %eax,%eax
  801983:	79 14                	jns    801999 <open+0x6f>
		fd_close(fd, 0);
  801985:	83 ec 08             	sub    $0x8,%esp
  801988:	6a 00                	push   $0x0
  80198a:	ff 75 f4             	pushl  -0xc(%ebp)
  80198d:	e8 08 f9 ff ff       	call   80129a <fd_close>
		return r;
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	89 da                	mov    %ebx,%edx
  801997:	eb 17                	jmp    8019b0 <open+0x86>
	}

	return fd2num(fd);
  801999:	83 ec 0c             	sub    $0xc,%esp
  80199c:	ff 75 f4             	pushl  -0xc(%ebp)
  80199f:	e8 d7 f7 ff ff       	call   80117b <fd2num>
  8019a4:	89 c2                	mov    %eax,%edx
  8019a6:	83 c4 10             	add    $0x10,%esp
  8019a9:	eb 05                	jmp    8019b0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019ab:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019b0:	89 d0                	mov    %edx,%eax
  8019b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b5:	c9                   	leave  
  8019b6:	c3                   	ret    

008019b7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c2:	b8 08 00 00 00       	mov    $0x8,%eax
  8019c7:	e8 5e fd ff ff       	call   80172a <fsipc>
}
  8019cc:	c9                   	leave  
  8019cd:	c3                   	ret    

008019ce <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	56                   	push   %esi
  8019d2:	53                   	push   %ebx
  8019d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019d6:	83 ec 0c             	sub    $0xc,%esp
  8019d9:	ff 75 08             	pushl  0x8(%ebp)
  8019dc:	e8 aa f7 ff ff       	call   80118b <fd2data>
  8019e1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019e3:	83 c4 08             	add    $0x8,%esp
  8019e6:	68 4d 28 80 00       	push   $0x80284d
  8019eb:	53                   	push   %ebx
  8019ec:	e8 17 ee ff ff       	call   800808 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019f1:	8b 46 04             	mov    0x4(%esi),%eax
  8019f4:	2b 06                	sub    (%esi),%eax
  8019f6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019fc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a03:	00 00 00 
	stat->st_dev = &devpipe;
  801a06:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a0d:	30 80 00 
	return 0;
}
  801a10:	b8 00 00 00 00       	mov    $0x0,%eax
  801a15:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a18:	5b                   	pop    %ebx
  801a19:	5e                   	pop    %esi
  801a1a:	5d                   	pop    %ebp
  801a1b:	c3                   	ret    

00801a1c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	53                   	push   %ebx
  801a20:	83 ec 0c             	sub    $0xc,%esp
  801a23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a26:	53                   	push   %ebx
  801a27:	6a 00                	push   $0x0
  801a29:	e8 d9 f2 ff ff       	call   800d07 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a2e:	89 1c 24             	mov    %ebx,(%esp)
  801a31:	e8 55 f7 ff ff       	call   80118b <fd2data>
  801a36:	83 c4 08             	add    $0x8,%esp
  801a39:	50                   	push   %eax
  801a3a:	6a 00                	push   $0x0
  801a3c:	e8 c6 f2 ff ff       	call   800d07 <sys_page_unmap>
}
  801a41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a44:	c9                   	leave  
  801a45:	c3                   	ret    

00801a46 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	57                   	push   %edi
  801a4a:	56                   	push   %esi
  801a4b:	53                   	push   %ebx
  801a4c:	83 ec 1c             	sub    $0x1c,%esp
  801a4f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a52:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a54:	a1 08 40 80 00       	mov    0x804008,%eax
  801a59:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a5c:	83 ec 0c             	sub    $0xc,%esp
  801a5f:	ff 75 e0             	pushl  -0x20(%ebp)
  801a62:	e8 13 06 00 00       	call   80207a <pageref>
  801a67:	89 c3                	mov    %eax,%ebx
  801a69:	89 3c 24             	mov    %edi,(%esp)
  801a6c:	e8 09 06 00 00       	call   80207a <pageref>
  801a71:	83 c4 10             	add    $0x10,%esp
  801a74:	39 c3                	cmp    %eax,%ebx
  801a76:	0f 94 c1             	sete   %cl
  801a79:	0f b6 c9             	movzbl %cl,%ecx
  801a7c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a7f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a85:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a88:	39 ce                	cmp    %ecx,%esi
  801a8a:	74 1b                	je     801aa7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a8c:	39 c3                	cmp    %eax,%ebx
  801a8e:	75 c4                	jne    801a54 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a90:	8b 42 58             	mov    0x58(%edx),%eax
  801a93:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a96:	50                   	push   %eax
  801a97:	56                   	push   %esi
  801a98:	68 54 28 80 00       	push   $0x802854
  801a9d:	e8 32 e7 ff ff       	call   8001d4 <cprintf>
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	eb ad                	jmp    801a54 <_pipeisclosed+0xe>
	}
}
  801aa7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aad:	5b                   	pop    %ebx
  801aae:	5e                   	pop    %esi
  801aaf:	5f                   	pop    %edi
  801ab0:	5d                   	pop    %ebp
  801ab1:	c3                   	ret    

00801ab2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ab2:	55                   	push   %ebp
  801ab3:	89 e5                	mov    %esp,%ebp
  801ab5:	57                   	push   %edi
  801ab6:	56                   	push   %esi
  801ab7:	53                   	push   %ebx
  801ab8:	83 ec 28             	sub    $0x28,%esp
  801abb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801abe:	56                   	push   %esi
  801abf:	e8 c7 f6 ff ff       	call   80118b <fd2data>
  801ac4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	bf 00 00 00 00       	mov    $0x0,%edi
  801ace:	eb 4b                	jmp    801b1b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ad0:	89 da                	mov    %ebx,%edx
  801ad2:	89 f0                	mov    %esi,%eax
  801ad4:	e8 6d ff ff ff       	call   801a46 <_pipeisclosed>
  801ad9:	85 c0                	test   %eax,%eax
  801adb:	75 48                	jne    801b25 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801add:	e8 81 f1 ff ff       	call   800c63 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ae2:	8b 43 04             	mov    0x4(%ebx),%eax
  801ae5:	8b 0b                	mov    (%ebx),%ecx
  801ae7:	8d 51 20             	lea    0x20(%ecx),%edx
  801aea:	39 d0                	cmp    %edx,%eax
  801aec:	73 e2                	jae    801ad0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801aee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801af1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801af5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801af8:	89 c2                	mov    %eax,%edx
  801afa:	c1 fa 1f             	sar    $0x1f,%edx
  801afd:	89 d1                	mov    %edx,%ecx
  801aff:	c1 e9 1b             	shr    $0x1b,%ecx
  801b02:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b05:	83 e2 1f             	and    $0x1f,%edx
  801b08:	29 ca                	sub    %ecx,%edx
  801b0a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b0e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b12:	83 c0 01             	add    $0x1,%eax
  801b15:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b18:	83 c7 01             	add    $0x1,%edi
  801b1b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b1e:	75 c2                	jne    801ae2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b20:	8b 45 10             	mov    0x10(%ebp),%eax
  801b23:	eb 05                	jmp    801b2a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b25:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2d:	5b                   	pop    %ebx
  801b2e:	5e                   	pop    %esi
  801b2f:	5f                   	pop    %edi
  801b30:	5d                   	pop    %ebp
  801b31:	c3                   	ret    

00801b32 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	57                   	push   %edi
  801b36:	56                   	push   %esi
  801b37:	53                   	push   %ebx
  801b38:	83 ec 18             	sub    $0x18,%esp
  801b3b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b3e:	57                   	push   %edi
  801b3f:	e8 47 f6 ff ff       	call   80118b <fd2data>
  801b44:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b4e:	eb 3d                	jmp    801b8d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b50:	85 db                	test   %ebx,%ebx
  801b52:	74 04                	je     801b58 <devpipe_read+0x26>
				return i;
  801b54:	89 d8                	mov    %ebx,%eax
  801b56:	eb 44                	jmp    801b9c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b58:	89 f2                	mov    %esi,%edx
  801b5a:	89 f8                	mov    %edi,%eax
  801b5c:	e8 e5 fe ff ff       	call   801a46 <_pipeisclosed>
  801b61:	85 c0                	test   %eax,%eax
  801b63:	75 32                	jne    801b97 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b65:	e8 f9 f0 ff ff       	call   800c63 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b6a:	8b 06                	mov    (%esi),%eax
  801b6c:	3b 46 04             	cmp    0x4(%esi),%eax
  801b6f:	74 df                	je     801b50 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b71:	99                   	cltd   
  801b72:	c1 ea 1b             	shr    $0x1b,%edx
  801b75:	01 d0                	add    %edx,%eax
  801b77:	83 e0 1f             	and    $0x1f,%eax
  801b7a:	29 d0                	sub    %edx,%eax
  801b7c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b84:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b87:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8a:	83 c3 01             	add    $0x1,%ebx
  801b8d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b90:	75 d8                	jne    801b6a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b92:	8b 45 10             	mov    0x10(%ebp),%eax
  801b95:	eb 05                	jmp    801b9c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b97:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9f:	5b                   	pop    %ebx
  801ba0:	5e                   	pop    %esi
  801ba1:	5f                   	pop    %edi
  801ba2:	5d                   	pop    %ebp
  801ba3:	c3                   	ret    

00801ba4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	56                   	push   %esi
  801ba8:	53                   	push   %ebx
  801ba9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801baf:	50                   	push   %eax
  801bb0:	e8 ed f5 ff ff       	call   8011a2 <fd_alloc>
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	89 c2                	mov    %eax,%edx
  801bba:	85 c0                	test   %eax,%eax
  801bbc:	0f 88 2c 01 00 00    	js     801cee <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc2:	83 ec 04             	sub    $0x4,%esp
  801bc5:	68 07 04 00 00       	push   $0x407
  801bca:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcd:	6a 00                	push   $0x0
  801bcf:	e8 ae f0 ff ff       	call   800c82 <sys_page_alloc>
  801bd4:	83 c4 10             	add    $0x10,%esp
  801bd7:	89 c2                	mov    %eax,%edx
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	0f 88 0d 01 00 00    	js     801cee <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801be1:	83 ec 0c             	sub    $0xc,%esp
  801be4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801be7:	50                   	push   %eax
  801be8:	e8 b5 f5 ff ff       	call   8011a2 <fd_alloc>
  801bed:	89 c3                	mov    %eax,%ebx
  801bef:	83 c4 10             	add    $0x10,%esp
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	0f 88 e2 00 00 00    	js     801cdc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfa:	83 ec 04             	sub    $0x4,%esp
  801bfd:	68 07 04 00 00       	push   $0x407
  801c02:	ff 75 f0             	pushl  -0x10(%ebp)
  801c05:	6a 00                	push   $0x0
  801c07:	e8 76 f0 ff ff       	call   800c82 <sys_page_alloc>
  801c0c:	89 c3                	mov    %eax,%ebx
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	85 c0                	test   %eax,%eax
  801c13:	0f 88 c3 00 00 00    	js     801cdc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c19:	83 ec 0c             	sub    $0xc,%esp
  801c1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1f:	e8 67 f5 ff ff       	call   80118b <fd2data>
  801c24:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c26:	83 c4 0c             	add    $0xc,%esp
  801c29:	68 07 04 00 00       	push   $0x407
  801c2e:	50                   	push   %eax
  801c2f:	6a 00                	push   $0x0
  801c31:	e8 4c f0 ff ff       	call   800c82 <sys_page_alloc>
  801c36:	89 c3                	mov    %eax,%ebx
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	85 c0                	test   %eax,%eax
  801c3d:	0f 88 89 00 00 00    	js     801ccc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c43:	83 ec 0c             	sub    $0xc,%esp
  801c46:	ff 75 f0             	pushl  -0x10(%ebp)
  801c49:	e8 3d f5 ff ff       	call   80118b <fd2data>
  801c4e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c55:	50                   	push   %eax
  801c56:	6a 00                	push   $0x0
  801c58:	56                   	push   %esi
  801c59:	6a 00                	push   $0x0
  801c5b:	e8 65 f0 ff ff       	call   800cc5 <sys_page_map>
  801c60:	89 c3                	mov    %eax,%ebx
  801c62:	83 c4 20             	add    $0x20,%esp
  801c65:	85 c0                	test   %eax,%eax
  801c67:	78 55                	js     801cbe <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c69:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c72:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c77:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c7e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c84:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c87:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c8c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c93:	83 ec 0c             	sub    $0xc,%esp
  801c96:	ff 75 f4             	pushl  -0xc(%ebp)
  801c99:	e8 dd f4 ff ff       	call   80117b <fd2num>
  801c9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ca3:	83 c4 04             	add    $0x4,%esp
  801ca6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca9:	e8 cd f4 ff ff       	call   80117b <fd2num>
  801cae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cb4:	83 c4 10             	add    $0x10,%esp
  801cb7:	ba 00 00 00 00       	mov    $0x0,%edx
  801cbc:	eb 30                	jmp    801cee <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cbe:	83 ec 08             	sub    $0x8,%esp
  801cc1:	56                   	push   %esi
  801cc2:	6a 00                	push   $0x0
  801cc4:	e8 3e f0 ff ff       	call   800d07 <sys_page_unmap>
  801cc9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ccc:	83 ec 08             	sub    $0x8,%esp
  801ccf:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd2:	6a 00                	push   $0x0
  801cd4:	e8 2e f0 ff ff       	call   800d07 <sys_page_unmap>
  801cd9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cdc:	83 ec 08             	sub    $0x8,%esp
  801cdf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce2:	6a 00                	push   $0x0
  801ce4:	e8 1e f0 ff ff       	call   800d07 <sys_page_unmap>
  801ce9:	83 c4 10             	add    $0x10,%esp
  801cec:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cee:	89 d0                	mov    %edx,%eax
  801cf0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5d                   	pop    %ebp
  801cf6:	c3                   	ret    

00801cf7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cf7:	55                   	push   %ebp
  801cf8:	89 e5                	mov    %esp,%ebp
  801cfa:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cfd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d00:	50                   	push   %eax
  801d01:	ff 75 08             	pushl  0x8(%ebp)
  801d04:	e8 e8 f4 ff ff       	call   8011f1 <fd_lookup>
  801d09:	83 c4 10             	add    $0x10,%esp
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	78 18                	js     801d28 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d10:	83 ec 0c             	sub    $0xc,%esp
  801d13:	ff 75 f4             	pushl  -0xc(%ebp)
  801d16:	e8 70 f4 ff ff       	call   80118b <fd2data>
	return _pipeisclosed(fd, p);
  801d1b:	89 c2                	mov    %eax,%edx
  801d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d20:	e8 21 fd ff ff       	call   801a46 <_pipeisclosed>
  801d25:	83 c4 10             	add    $0x10,%esp
}
  801d28:	c9                   	leave  
  801d29:	c3                   	ret    

00801d2a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d2a:	55                   	push   %ebp
  801d2b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d2d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d32:	5d                   	pop    %ebp
  801d33:	c3                   	ret    

00801d34 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d3a:	68 6c 28 80 00       	push   $0x80286c
  801d3f:	ff 75 0c             	pushl  0xc(%ebp)
  801d42:	e8 c1 ea ff ff       	call   800808 <strcpy>
	return 0;
}
  801d47:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4c:	c9                   	leave  
  801d4d:	c3                   	ret    

00801d4e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	57                   	push   %edi
  801d52:	56                   	push   %esi
  801d53:	53                   	push   %ebx
  801d54:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d5a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d5f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d65:	eb 2d                	jmp    801d94 <devcons_write+0x46>
		m = n - tot;
  801d67:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d6a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d6c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d6f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d74:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d77:	83 ec 04             	sub    $0x4,%esp
  801d7a:	53                   	push   %ebx
  801d7b:	03 45 0c             	add    0xc(%ebp),%eax
  801d7e:	50                   	push   %eax
  801d7f:	57                   	push   %edi
  801d80:	e8 15 ec ff ff       	call   80099a <memmove>
		sys_cputs(buf, m);
  801d85:	83 c4 08             	add    $0x8,%esp
  801d88:	53                   	push   %ebx
  801d89:	57                   	push   %edi
  801d8a:	e8 37 ee ff ff       	call   800bc6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d8f:	01 de                	add    %ebx,%esi
  801d91:	83 c4 10             	add    $0x10,%esp
  801d94:	89 f0                	mov    %esi,%eax
  801d96:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d99:	72 cc                	jb     801d67 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d9e:	5b                   	pop    %ebx
  801d9f:	5e                   	pop    %esi
  801da0:	5f                   	pop    %edi
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    

00801da3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	83 ec 08             	sub    $0x8,%esp
  801da9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801db2:	74 2a                	je     801dde <devcons_read+0x3b>
  801db4:	eb 05                	jmp    801dbb <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801db6:	e8 a8 ee ff ff       	call   800c63 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dbb:	e8 24 ee ff ff       	call   800be4 <sys_cgetc>
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	74 f2                	je     801db6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	78 16                	js     801dde <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dc8:	83 f8 04             	cmp    $0x4,%eax
  801dcb:	74 0c                	je     801dd9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dcd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd0:	88 02                	mov    %al,(%edx)
	return 1;
  801dd2:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd7:	eb 05                	jmp    801dde <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dd9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dde:	c9                   	leave  
  801ddf:	c3                   	ret    

00801de0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801de6:	8b 45 08             	mov    0x8(%ebp),%eax
  801de9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dec:	6a 01                	push   $0x1
  801dee:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df1:	50                   	push   %eax
  801df2:	e8 cf ed ff ff       	call   800bc6 <sys_cputs>
}
  801df7:	83 c4 10             	add    $0x10,%esp
  801dfa:	c9                   	leave  
  801dfb:	c3                   	ret    

00801dfc <getchar>:

int
getchar(void)
{
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e02:	6a 01                	push   $0x1
  801e04:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e07:	50                   	push   %eax
  801e08:	6a 00                	push   $0x0
  801e0a:	e8 48 f6 ff ff       	call   801457 <read>
	if (r < 0)
  801e0f:	83 c4 10             	add    $0x10,%esp
  801e12:	85 c0                	test   %eax,%eax
  801e14:	78 0f                	js     801e25 <getchar+0x29>
		return r;
	if (r < 1)
  801e16:	85 c0                	test   %eax,%eax
  801e18:	7e 06                	jle    801e20 <getchar+0x24>
		return -E_EOF;
	return c;
  801e1a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e1e:	eb 05                	jmp    801e25 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e20:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e25:	c9                   	leave  
  801e26:	c3                   	ret    

00801e27 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
  801e2a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e30:	50                   	push   %eax
  801e31:	ff 75 08             	pushl  0x8(%ebp)
  801e34:	e8 b8 f3 ff ff       	call   8011f1 <fd_lookup>
  801e39:	83 c4 10             	add    $0x10,%esp
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	78 11                	js     801e51 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e43:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e49:	39 10                	cmp    %edx,(%eax)
  801e4b:	0f 94 c0             	sete   %al
  801e4e:	0f b6 c0             	movzbl %al,%eax
}
  801e51:	c9                   	leave  
  801e52:	c3                   	ret    

00801e53 <opencons>:

int
opencons(void)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5c:	50                   	push   %eax
  801e5d:	e8 40 f3 ff ff       	call   8011a2 <fd_alloc>
  801e62:	83 c4 10             	add    $0x10,%esp
		return r;
  801e65:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e67:	85 c0                	test   %eax,%eax
  801e69:	78 3e                	js     801ea9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e6b:	83 ec 04             	sub    $0x4,%esp
  801e6e:	68 07 04 00 00       	push   $0x407
  801e73:	ff 75 f4             	pushl  -0xc(%ebp)
  801e76:	6a 00                	push   $0x0
  801e78:	e8 05 ee ff ff       	call   800c82 <sys_page_alloc>
  801e7d:	83 c4 10             	add    $0x10,%esp
		return r;
  801e80:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e82:	85 c0                	test   %eax,%eax
  801e84:	78 23                	js     801ea9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e86:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e94:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e9b:	83 ec 0c             	sub    $0xc,%esp
  801e9e:	50                   	push   %eax
  801e9f:	e8 d7 f2 ff ff       	call   80117b <fd2num>
  801ea4:	89 c2                	mov    %eax,%edx
  801ea6:	83 c4 10             	add    $0x10,%esp
}
  801ea9:	89 d0                	mov    %edx,%eax
  801eab:	c9                   	leave  
  801eac:	c3                   	ret    

00801ead <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	56                   	push   %esi
  801eb1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801eb2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801eb5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ebb:	e8 84 ed ff ff       	call   800c44 <sys_getenvid>
  801ec0:	83 ec 0c             	sub    $0xc,%esp
  801ec3:	ff 75 0c             	pushl  0xc(%ebp)
  801ec6:	ff 75 08             	pushl  0x8(%ebp)
  801ec9:	56                   	push   %esi
  801eca:	50                   	push   %eax
  801ecb:	68 78 28 80 00       	push   $0x802878
  801ed0:	e8 ff e2 ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ed5:	83 c4 18             	add    $0x18,%esp
  801ed8:	53                   	push   %ebx
  801ed9:	ff 75 10             	pushl  0x10(%ebp)
  801edc:	e8 a2 e2 ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  801ee1:	c7 04 24 6f 23 80 00 	movl   $0x80236f,(%esp)
  801ee8:	e8 e7 e2 ff ff       	call   8001d4 <cprintf>
  801eed:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ef0:	cc                   	int3   
  801ef1:	eb fd                	jmp    801ef0 <_panic+0x43>

00801ef3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801ef9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f00:	75 52                	jne    801f54 <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  801f02:	83 ec 04             	sub    $0x4,%esp
  801f05:	6a 07                	push   $0x7
  801f07:	68 00 f0 bf ee       	push   $0xeebff000
  801f0c:	6a 00                	push   $0x0
  801f0e:	e8 6f ed ff ff       	call   800c82 <sys_page_alloc>
  801f13:	83 c4 10             	add    $0x10,%esp
  801f16:	85 c0                	test   %eax,%eax
  801f18:	79 12                	jns    801f2c <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  801f1a:	50                   	push   %eax
  801f1b:	68 c0 26 80 00       	push   $0x8026c0
  801f20:	6a 23                	push   $0x23
  801f22:	68 9b 28 80 00       	push   $0x80289b
  801f27:	e8 81 ff ff ff       	call   801ead <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  801f2c:	83 ec 08             	sub    $0x8,%esp
  801f2f:	68 5e 1f 80 00       	push   $0x801f5e
  801f34:	6a 00                	push   $0x0
  801f36:	e8 92 ee ff ff       	call   800dcd <sys_env_set_pgfault_upcall>
  801f3b:	83 c4 10             	add    $0x10,%esp
  801f3e:	85 c0                	test   %eax,%eax
  801f40:	79 12                	jns    801f54 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  801f42:	50                   	push   %eax
  801f43:	68 40 27 80 00       	push   $0x802740
  801f48:	6a 26                	push   $0x26
  801f4a:	68 9b 28 80 00       	push   $0x80289b
  801f4f:	e8 59 ff ff ff       	call   801ead <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f54:	8b 45 08             	mov    0x8(%ebp),%eax
  801f57:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f5c:	c9                   	leave  
  801f5d:	c3                   	ret    

00801f5e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f5e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f5f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f64:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f66:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  801f69:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  801f6d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  801f72:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  801f76:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801f78:	83 c4 08             	add    $0x8,%esp
	popal 
  801f7b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801f7c:	83 c4 04             	add    $0x4,%esp
	popfl
  801f7f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f80:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f81:	c3                   	ret    

00801f82 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f82:	55                   	push   %ebp
  801f83:	89 e5                	mov    %esp,%ebp
  801f85:	56                   	push   %esi
  801f86:	53                   	push   %ebx
  801f87:	8b 75 08             	mov    0x8(%ebp),%esi
  801f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801f90:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f92:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f97:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801f9a:	83 ec 0c             	sub    $0xc,%esp
  801f9d:	50                   	push   %eax
  801f9e:	e8 8f ee ff ff       	call   800e32 <sys_ipc_recv>
  801fa3:	83 c4 10             	add    $0x10,%esp
  801fa6:	85 c0                	test   %eax,%eax
  801fa8:	79 16                	jns    801fc0 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801faa:	85 f6                	test   %esi,%esi
  801fac:	74 06                	je     801fb4 <ipc_recv+0x32>
			*from_env_store = 0;
  801fae:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801fb4:	85 db                	test   %ebx,%ebx
  801fb6:	74 2c                	je     801fe4 <ipc_recv+0x62>
			*perm_store = 0;
  801fb8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801fbe:	eb 24                	jmp    801fe4 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801fc0:	85 f6                	test   %esi,%esi
  801fc2:	74 0a                	je     801fce <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801fc4:	a1 08 40 80 00       	mov    0x804008,%eax
  801fc9:	8b 40 74             	mov    0x74(%eax),%eax
  801fcc:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801fce:	85 db                	test   %ebx,%ebx
  801fd0:	74 0a                	je     801fdc <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801fd2:	a1 08 40 80 00       	mov    0x804008,%eax
  801fd7:	8b 40 78             	mov    0x78(%eax),%eax
  801fda:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801fdc:	a1 08 40 80 00       	mov    0x804008,%eax
  801fe1:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fe4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fe7:	5b                   	pop    %ebx
  801fe8:	5e                   	pop    %esi
  801fe9:	5d                   	pop    %ebp
  801fea:	c3                   	ret    

00801feb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	57                   	push   %edi
  801fef:	56                   	push   %esi
  801ff0:	53                   	push   %ebx
  801ff1:	83 ec 0c             	sub    $0xc,%esp
  801ff4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ff7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ffa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801ffd:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801fff:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802004:	0f 44 d8             	cmove  %eax,%ebx
  802007:	eb 1e                	jmp    802027 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  802009:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80200c:	74 14                	je     802022 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  80200e:	83 ec 04             	sub    $0x4,%esp
  802011:	68 ac 28 80 00       	push   $0x8028ac
  802016:	6a 44                	push   $0x44
  802018:	68 d8 28 80 00       	push   $0x8028d8
  80201d:	e8 8b fe ff ff       	call   801ead <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  802022:	e8 3c ec ff ff       	call   800c63 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802027:	ff 75 14             	pushl  0x14(%ebp)
  80202a:	53                   	push   %ebx
  80202b:	56                   	push   %esi
  80202c:	57                   	push   %edi
  80202d:	e8 dd ed ff ff       	call   800e0f <sys_ipc_try_send>
  802032:	83 c4 10             	add    $0x10,%esp
  802035:	85 c0                	test   %eax,%eax
  802037:	78 d0                	js     802009 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  802039:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80203c:	5b                   	pop    %ebx
  80203d:	5e                   	pop    %esi
  80203e:	5f                   	pop    %edi
  80203f:	5d                   	pop    %ebp
  802040:	c3                   	ret    

00802041 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802041:	55                   	push   %ebp
  802042:	89 e5                	mov    %esp,%ebp
  802044:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802047:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80204c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80204f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802055:	8b 52 50             	mov    0x50(%edx),%edx
  802058:	39 ca                	cmp    %ecx,%edx
  80205a:	75 0d                	jne    802069 <ipc_find_env+0x28>
			return envs[i].env_id;
  80205c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80205f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802064:	8b 40 48             	mov    0x48(%eax),%eax
  802067:	eb 0f                	jmp    802078 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802069:	83 c0 01             	add    $0x1,%eax
  80206c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802071:	75 d9                	jne    80204c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802073:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    

0080207a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80207a:	55                   	push   %ebp
  80207b:	89 e5                	mov    %esp,%ebp
  80207d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802080:	89 d0                	mov    %edx,%eax
  802082:	c1 e8 16             	shr    $0x16,%eax
  802085:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80208c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802091:	f6 c1 01             	test   $0x1,%cl
  802094:	74 1d                	je     8020b3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802096:	c1 ea 0c             	shr    $0xc,%edx
  802099:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020a0:	f6 c2 01             	test   $0x1,%dl
  8020a3:	74 0e                	je     8020b3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020a5:	c1 ea 0c             	shr    $0xc,%edx
  8020a8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020af:	ef 
  8020b0:	0f b7 c0             	movzwl %ax,%eax
}
  8020b3:	5d                   	pop    %ebp
  8020b4:	c3                   	ret    
  8020b5:	66 90                	xchg   %ax,%ax
  8020b7:	66 90                	xchg   %ax,%ax
  8020b9:	66 90                	xchg   %ax,%ax
  8020bb:	66 90                	xchg   %ax,%ax
  8020bd:	66 90                	xchg   %ax,%ax
  8020bf:	90                   	nop

008020c0 <__udivdi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 f6                	test   %esi,%esi
  8020d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020dd:	89 ca                	mov    %ecx,%edx
  8020df:	89 f8                	mov    %edi,%eax
  8020e1:	75 3d                	jne    802120 <__udivdi3+0x60>
  8020e3:	39 cf                	cmp    %ecx,%edi
  8020e5:	0f 87 c5 00 00 00    	ja     8021b0 <__udivdi3+0xf0>
  8020eb:	85 ff                	test   %edi,%edi
  8020ed:	89 fd                	mov    %edi,%ebp
  8020ef:	75 0b                	jne    8020fc <__udivdi3+0x3c>
  8020f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f6:	31 d2                	xor    %edx,%edx
  8020f8:	f7 f7                	div    %edi
  8020fa:	89 c5                	mov    %eax,%ebp
  8020fc:	89 c8                	mov    %ecx,%eax
  8020fe:	31 d2                	xor    %edx,%edx
  802100:	f7 f5                	div    %ebp
  802102:	89 c1                	mov    %eax,%ecx
  802104:	89 d8                	mov    %ebx,%eax
  802106:	89 cf                	mov    %ecx,%edi
  802108:	f7 f5                	div    %ebp
  80210a:	89 c3                	mov    %eax,%ebx
  80210c:	89 d8                	mov    %ebx,%eax
  80210e:	89 fa                	mov    %edi,%edx
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
  802118:	90                   	nop
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	39 ce                	cmp    %ecx,%esi
  802122:	77 74                	ja     802198 <__udivdi3+0xd8>
  802124:	0f bd fe             	bsr    %esi,%edi
  802127:	83 f7 1f             	xor    $0x1f,%edi
  80212a:	0f 84 98 00 00 00    	je     8021c8 <__udivdi3+0x108>
  802130:	bb 20 00 00 00       	mov    $0x20,%ebx
  802135:	89 f9                	mov    %edi,%ecx
  802137:	89 c5                	mov    %eax,%ebp
  802139:	29 fb                	sub    %edi,%ebx
  80213b:	d3 e6                	shl    %cl,%esi
  80213d:	89 d9                	mov    %ebx,%ecx
  80213f:	d3 ed                	shr    %cl,%ebp
  802141:	89 f9                	mov    %edi,%ecx
  802143:	d3 e0                	shl    %cl,%eax
  802145:	09 ee                	or     %ebp,%esi
  802147:	89 d9                	mov    %ebx,%ecx
  802149:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80214d:	89 d5                	mov    %edx,%ebp
  80214f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802153:	d3 ed                	shr    %cl,%ebp
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 e2                	shl    %cl,%edx
  802159:	89 d9                	mov    %ebx,%ecx
  80215b:	d3 e8                	shr    %cl,%eax
  80215d:	09 c2                	or     %eax,%edx
  80215f:	89 d0                	mov    %edx,%eax
  802161:	89 ea                	mov    %ebp,%edx
  802163:	f7 f6                	div    %esi
  802165:	89 d5                	mov    %edx,%ebp
  802167:	89 c3                	mov    %eax,%ebx
  802169:	f7 64 24 0c          	mull   0xc(%esp)
  80216d:	39 d5                	cmp    %edx,%ebp
  80216f:	72 10                	jb     802181 <__udivdi3+0xc1>
  802171:	8b 74 24 08          	mov    0x8(%esp),%esi
  802175:	89 f9                	mov    %edi,%ecx
  802177:	d3 e6                	shl    %cl,%esi
  802179:	39 c6                	cmp    %eax,%esi
  80217b:	73 07                	jae    802184 <__udivdi3+0xc4>
  80217d:	39 d5                	cmp    %edx,%ebp
  80217f:	75 03                	jne    802184 <__udivdi3+0xc4>
  802181:	83 eb 01             	sub    $0x1,%ebx
  802184:	31 ff                	xor    %edi,%edi
  802186:	89 d8                	mov    %ebx,%eax
  802188:	89 fa                	mov    %edi,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	31 ff                	xor    %edi,%edi
  80219a:	31 db                	xor    %ebx,%ebx
  80219c:	89 d8                	mov    %ebx,%eax
  80219e:	89 fa                	mov    %edi,%edx
  8021a0:	83 c4 1c             	add    $0x1c,%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5f                   	pop    %edi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    
  8021a8:	90                   	nop
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	89 d8                	mov    %ebx,%eax
  8021b2:	f7 f7                	div    %edi
  8021b4:	31 ff                	xor    %edi,%edi
  8021b6:	89 c3                	mov    %eax,%ebx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 fa                	mov    %edi,%edx
  8021bc:	83 c4 1c             	add    $0x1c,%esp
  8021bf:	5b                   	pop    %ebx
  8021c0:	5e                   	pop    %esi
  8021c1:	5f                   	pop    %edi
  8021c2:	5d                   	pop    %ebp
  8021c3:	c3                   	ret    
  8021c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c8:	39 ce                	cmp    %ecx,%esi
  8021ca:	72 0c                	jb     8021d8 <__udivdi3+0x118>
  8021cc:	31 db                	xor    %ebx,%ebx
  8021ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021d2:	0f 87 34 ff ff ff    	ja     80210c <__udivdi3+0x4c>
  8021d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021dd:	e9 2a ff ff ff       	jmp    80210c <__udivdi3+0x4c>
  8021e2:	66 90                	xchg   %ax,%ax
  8021e4:	66 90                	xchg   %ax,%ax
  8021e6:	66 90                	xchg   %ax,%ax
  8021e8:	66 90                	xchg   %ax,%ax
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <__umoddi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	53                   	push   %ebx
  8021f4:	83 ec 1c             	sub    $0x1c,%esp
  8021f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802207:	85 d2                	test   %edx,%edx
  802209:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80220d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802211:	89 f3                	mov    %esi,%ebx
  802213:	89 3c 24             	mov    %edi,(%esp)
  802216:	89 74 24 04          	mov    %esi,0x4(%esp)
  80221a:	75 1c                	jne    802238 <__umoddi3+0x48>
  80221c:	39 f7                	cmp    %esi,%edi
  80221e:	76 50                	jbe    802270 <__umoddi3+0x80>
  802220:	89 c8                	mov    %ecx,%eax
  802222:	89 f2                	mov    %esi,%edx
  802224:	f7 f7                	div    %edi
  802226:	89 d0                	mov    %edx,%eax
  802228:	31 d2                	xor    %edx,%edx
  80222a:	83 c4 1c             	add    $0x1c,%esp
  80222d:	5b                   	pop    %ebx
  80222e:	5e                   	pop    %esi
  80222f:	5f                   	pop    %edi
  802230:	5d                   	pop    %ebp
  802231:	c3                   	ret    
  802232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802238:	39 f2                	cmp    %esi,%edx
  80223a:	89 d0                	mov    %edx,%eax
  80223c:	77 52                	ja     802290 <__umoddi3+0xa0>
  80223e:	0f bd ea             	bsr    %edx,%ebp
  802241:	83 f5 1f             	xor    $0x1f,%ebp
  802244:	75 5a                	jne    8022a0 <__umoddi3+0xb0>
  802246:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80224a:	0f 82 e0 00 00 00    	jb     802330 <__umoddi3+0x140>
  802250:	39 0c 24             	cmp    %ecx,(%esp)
  802253:	0f 86 d7 00 00 00    	jbe    802330 <__umoddi3+0x140>
  802259:	8b 44 24 08          	mov    0x8(%esp),%eax
  80225d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802261:	83 c4 1c             	add    $0x1c,%esp
  802264:	5b                   	pop    %ebx
  802265:	5e                   	pop    %esi
  802266:	5f                   	pop    %edi
  802267:	5d                   	pop    %ebp
  802268:	c3                   	ret    
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	85 ff                	test   %edi,%edi
  802272:	89 fd                	mov    %edi,%ebp
  802274:	75 0b                	jne    802281 <__umoddi3+0x91>
  802276:	b8 01 00 00 00       	mov    $0x1,%eax
  80227b:	31 d2                	xor    %edx,%edx
  80227d:	f7 f7                	div    %edi
  80227f:	89 c5                	mov    %eax,%ebp
  802281:	89 f0                	mov    %esi,%eax
  802283:	31 d2                	xor    %edx,%edx
  802285:	f7 f5                	div    %ebp
  802287:	89 c8                	mov    %ecx,%eax
  802289:	f7 f5                	div    %ebp
  80228b:	89 d0                	mov    %edx,%eax
  80228d:	eb 99                	jmp    802228 <__umoddi3+0x38>
  80228f:	90                   	nop
  802290:	89 c8                	mov    %ecx,%eax
  802292:	89 f2                	mov    %esi,%edx
  802294:	83 c4 1c             	add    $0x1c,%esp
  802297:	5b                   	pop    %ebx
  802298:	5e                   	pop    %esi
  802299:	5f                   	pop    %edi
  80229a:	5d                   	pop    %ebp
  80229b:	c3                   	ret    
  80229c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	8b 34 24             	mov    (%esp),%esi
  8022a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022a8:	89 e9                	mov    %ebp,%ecx
  8022aa:	29 ef                	sub    %ebp,%edi
  8022ac:	d3 e0                	shl    %cl,%eax
  8022ae:	89 f9                	mov    %edi,%ecx
  8022b0:	89 f2                	mov    %esi,%edx
  8022b2:	d3 ea                	shr    %cl,%edx
  8022b4:	89 e9                	mov    %ebp,%ecx
  8022b6:	09 c2                	or     %eax,%edx
  8022b8:	89 d8                	mov    %ebx,%eax
  8022ba:	89 14 24             	mov    %edx,(%esp)
  8022bd:	89 f2                	mov    %esi,%edx
  8022bf:	d3 e2                	shl    %cl,%edx
  8022c1:	89 f9                	mov    %edi,%ecx
  8022c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022cb:	d3 e8                	shr    %cl,%eax
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	89 c6                	mov    %eax,%esi
  8022d1:	d3 e3                	shl    %cl,%ebx
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 d0                	mov    %edx,%eax
  8022d7:	d3 e8                	shr    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	09 d8                	or     %ebx,%eax
  8022dd:	89 d3                	mov    %edx,%ebx
  8022df:	89 f2                	mov    %esi,%edx
  8022e1:	f7 34 24             	divl   (%esp)
  8022e4:	89 d6                	mov    %edx,%esi
  8022e6:	d3 e3                	shl    %cl,%ebx
  8022e8:	f7 64 24 04          	mull   0x4(%esp)
  8022ec:	39 d6                	cmp    %edx,%esi
  8022ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022f2:	89 d1                	mov    %edx,%ecx
  8022f4:	89 c3                	mov    %eax,%ebx
  8022f6:	72 08                	jb     802300 <__umoddi3+0x110>
  8022f8:	75 11                	jne    80230b <__umoddi3+0x11b>
  8022fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022fe:	73 0b                	jae    80230b <__umoddi3+0x11b>
  802300:	2b 44 24 04          	sub    0x4(%esp),%eax
  802304:	1b 14 24             	sbb    (%esp),%edx
  802307:	89 d1                	mov    %edx,%ecx
  802309:	89 c3                	mov    %eax,%ebx
  80230b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80230f:	29 da                	sub    %ebx,%edx
  802311:	19 ce                	sbb    %ecx,%esi
  802313:	89 f9                	mov    %edi,%ecx
  802315:	89 f0                	mov    %esi,%eax
  802317:	d3 e0                	shl    %cl,%eax
  802319:	89 e9                	mov    %ebp,%ecx
  80231b:	d3 ea                	shr    %cl,%edx
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	d3 ee                	shr    %cl,%esi
  802321:	09 d0                	or     %edx,%eax
  802323:	89 f2                	mov    %esi,%edx
  802325:	83 c4 1c             	add    $0x1c,%esp
  802328:	5b                   	pop    %ebx
  802329:	5e                   	pop    %esi
  80232a:	5f                   	pop    %edi
  80232b:	5d                   	pop    %ebp
  80232c:	c3                   	ret    
  80232d:	8d 76 00             	lea    0x0(%esi),%esi
  802330:	29 f9                	sub    %edi,%ecx
  802332:	19 d6                	sbb    %edx,%esi
  802334:	89 74 24 04          	mov    %esi,0x4(%esp)
  802338:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80233c:	e9 18 ff ff ff       	jmp    802259 <__umoddi3+0x69>
