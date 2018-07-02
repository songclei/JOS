
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 dc 00 00 00       	call   80010d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	68 40 22 80 00       	push   $0x802240
  80003e:	e8 bd 01 00 00       	call   800200 <cprintf>
	exit();
  800043:	e8 0b 01 00 00       	call   800153 <exit>
}
  800048:	83 c4 10             	add    $0x10,%esp
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	ff 75 0c             	pushl  0xc(%ebp)
  800063:	8d 45 08             	lea    0x8(%ebp),%eax
  800066:	50                   	push   %eax
  800067:	e8 33 0e 00 00       	call   800e9f <argstart>
	while ((i = argnext(&args)) >= 0)
  80006c:	83 c4 10             	add    $0x10,%esp
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  80006f:	be 00 00 00 00       	mov    $0x0,%esi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800074:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80007a:	eb 11                	jmp    80008d <umain+0x40>
		if (i == '1')
  80007c:	83 f8 31             	cmp    $0x31,%eax
  80007f:	74 07                	je     800088 <umain+0x3b>
			usefprint = 1;
		else
			usage();
  800081:	e8 ad ff ff ff       	call   800033 <usage>
  800086:	eb 05                	jmp    80008d <umain+0x40>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  800088:	be 01 00 00 00       	mov    $0x1,%esi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	53                   	push   %ebx
  800091:	e8 39 0e 00 00       	call   800ecf <argnext>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 df                	jns    80007c <umain+0x2f>
  80009d:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a2:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	57                   	push   %edi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 35 14 00 00       	call   8014e7 <fstat>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	78 44                	js     8000fd <umain+0xb0>
			if (usefprint)
  8000b9:	85 f6                	test   %esi,%esi
  8000bb:	74 22                	je     8000df <umain+0x92>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c3:	ff 70 04             	pushl  0x4(%eax)
  8000c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8000c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8000cc:	57                   	push   %edi
  8000cd:	53                   	push   %ebx
  8000ce:	68 54 22 80 00       	push   $0x802254
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 4f 18 00 00       	call   801929 <fprintf>
  8000da:	83 c4 20             	add    $0x20,%esp
  8000dd:	eb 1e                	jmp    8000fd <umain+0xb0>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e5:	ff 70 04             	pushl  0x4(%eax)
  8000e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8000ee:	57                   	push   %edi
  8000ef:	53                   	push   %ebx
  8000f0:	68 54 22 80 00       	push   $0x802254
  8000f5:	e8 06 01 00 00       	call   800200 <cprintf>
  8000fa:	83 c4 20             	add    $0x20,%esp
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  8000fd:	83 c3 01             	add    $0x1,%ebx
  800100:	83 fb 20             	cmp    $0x20,%ebx
  800103:	75 a3                	jne    8000a8 <umain+0x5b>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
  800112:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800115:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800118:	e8 53 0b 00 00       	call   800c70 <sys_getenvid>
  80011d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800122:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800125:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012a:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012f:	85 db                	test   %ebx,%ebx
  800131:	7e 07                	jle    80013a <libmain+0x2d>
		binaryname = argv[0];
  800133:	8b 06                	mov    (%esi),%eax
  800135:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013a:	83 ec 08             	sub    $0x8,%esp
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
  80013f:	e8 09 ff ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800144:	e8 0a 00 00 00       	call   800153 <exit>
}
  800149:	83 c4 10             	add    $0x10,%esp
  80014c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800159:	e8 60 10 00 00       	call   8011be <close_all>
	sys_env_destroy(0);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	6a 00                	push   $0x0
  800163:	e8 c7 0a 00 00       	call   800c2f <sys_env_destroy>
}
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	53                   	push   %ebx
  800171:	83 ec 04             	sub    $0x4,%esp
  800174:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800177:	8b 13                	mov    (%ebx),%edx
  800179:	8d 42 01             	lea    0x1(%edx),%eax
  80017c:	89 03                	mov    %eax,(%ebx)
  80017e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800181:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800185:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018a:	75 1a                	jne    8001a6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	68 ff 00 00 00       	push   $0xff
  800194:	8d 43 08             	lea    0x8(%ebx),%eax
  800197:	50                   	push   %eax
  800198:	e8 55 0a 00 00       	call   800bf2 <sys_cputs>
		b->idx = 0;
  80019d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bf:	00 00 00 
	b.cnt = 0;
  8001c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cc:	ff 75 0c             	pushl  0xc(%ebp)
  8001cf:	ff 75 08             	pushl  0x8(%ebp)
  8001d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d8:	50                   	push   %eax
  8001d9:	68 6d 01 80 00       	push   $0x80016d
  8001de:	e8 54 01 00 00       	call   800337 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e3:	83 c4 08             	add    $0x8,%esp
  8001e6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ec:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 fa 09 00 00       	call   800bf2 <sys_cputs>

	return b.cnt;
}
  8001f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800206:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800209:	50                   	push   %eax
  80020a:	ff 75 08             	pushl  0x8(%ebp)
  80020d:	e8 9d ff ff ff       	call   8001af <vcprintf>
	va_end(ap);

	return cnt;
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 1c             	sub    $0x1c,%esp
  80021d:	89 c7                	mov    %eax,%edi
  80021f:	89 d6                	mov    %edx,%esi
  800221:	8b 45 08             	mov    0x8(%ebp),%eax
  800224:	8b 55 0c             	mov    0xc(%ebp),%edx
  800227:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800230:	bb 00 00 00 00       	mov    $0x0,%ebx
  800235:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800238:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023b:	39 d3                	cmp    %edx,%ebx
  80023d:	72 05                	jb     800244 <printnum+0x30>
  80023f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800242:	77 45                	ja     800289 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	ff 75 18             	pushl  0x18(%ebp)
  80024a:	8b 45 14             	mov    0x14(%ebp),%eax
  80024d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800250:	53                   	push   %ebx
  800251:	ff 75 10             	pushl  0x10(%ebp)
  800254:	83 ec 08             	sub    $0x8,%esp
  800257:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025a:	ff 75 e0             	pushl  -0x20(%ebp)
  80025d:	ff 75 dc             	pushl  -0x24(%ebp)
  800260:	ff 75 d8             	pushl  -0x28(%ebp)
  800263:	e8 48 1d 00 00       	call   801fb0 <__udivdi3>
  800268:	83 c4 18             	add    $0x18,%esp
  80026b:	52                   	push   %edx
  80026c:	50                   	push   %eax
  80026d:	89 f2                	mov    %esi,%edx
  80026f:	89 f8                	mov    %edi,%eax
  800271:	e8 9e ff ff ff       	call   800214 <printnum>
  800276:	83 c4 20             	add    $0x20,%esp
  800279:	eb 18                	jmp    800293 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027b:	83 ec 08             	sub    $0x8,%esp
  80027e:	56                   	push   %esi
  80027f:	ff 75 18             	pushl  0x18(%ebp)
  800282:	ff d7                	call   *%edi
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	eb 03                	jmp    80028c <printnum+0x78>
  800289:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028c:	83 eb 01             	sub    $0x1,%ebx
  80028f:	85 db                	test   %ebx,%ebx
  800291:	7f e8                	jg     80027b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	56                   	push   %esi
  800297:	83 ec 04             	sub    $0x4,%esp
  80029a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029d:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a6:	e8 35 1e 00 00       	call   8020e0 <__umoddi3>
  8002ab:	83 c4 14             	add    $0x14,%esp
  8002ae:	0f be 80 86 22 80 00 	movsbl 0x802286(%eax),%eax
  8002b5:	50                   	push   %eax
  8002b6:	ff d7                	call   *%edi
}
  8002b8:	83 c4 10             	add    $0x10,%esp
  8002bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c6:	83 fa 01             	cmp    $0x1,%edx
  8002c9:	7e 0e                	jle    8002d9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	8b 52 04             	mov    0x4(%edx),%edx
  8002d7:	eb 22                	jmp    8002fb <getuint+0x38>
	else if (lflag)
  8002d9:	85 d2                	test   %edx,%edx
  8002db:	74 10                	je     8002ed <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002eb:	eb 0e                	jmp    8002fb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800303:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800307:	8b 10                	mov    (%eax),%edx
  800309:	3b 50 04             	cmp    0x4(%eax),%edx
  80030c:	73 0a                	jae    800318 <sprintputch+0x1b>
		*b->buf++ = ch;
  80030e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 45 08             	mov    0x8(%ebp),%eax
  800316:	88 02                	mov    %al,(%edx)
}
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800320:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800323:	50                   	push   %eax
  800324:	ff 75 10             	pushl  0x10(%ebp)
  800327:	ff 75 0c             	pushl  0xc(%ebp)
  80032a:	ff 75 08             	pushl  0x8(%ebp)
  80032d:	e8 05 00 00 00       	call   800337 <vprintfmt>
	va_end(ap);
}
  800332:	83 c4 10             	add    $0x10,%esp
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	57                   	push   %edi
  80033b:	56                   	push   %esi
  80033c:	53                   	push   %ebx
  80033d:	83 ec 2c             	sub    $0x2c,%esp
  800340:	8b 75 08             	mov    0x8(%ebp),%esi
  800343:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800346:	8b 7d 10             	mov    0x10(%ebp),%edi
  800349:	eb 12                	jmp    80035d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034b:	85 c0                	test   %eax,%eax
  80034d:	0f 84 38 04 00 00    	je     80078b <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800353:	83 ec 08             	sub    $0x8,%esp
  800356:	53                   	push   %ebx
  800357:	50                   	push   %eax
  800358:	ff d6                	call   *%esi
  80035a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035d:	83 c7 01             	add    $0x1,%edi
  800360:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800364:	83 f8 25             	cmp    $0x25,%eax
  800367:	75 e2                	jne    80034b <vprintfmt+0x14>
  800369:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80036d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800374:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
  800387:	eb 07                	jmp    800390 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  80038c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8d 47 01             	lea    0x1(%edi),%eax
  800393:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800396:	0f b6 07             	movzbl (%edi),%eax
  800399:	0f b6 c8             	movzbl %al,%ecx
  80039c:	83 e8 23             	sub    $0x23,%eax
  80039f:	3c 55                	cmp    $0x55,%al
  8003a1:	0f 87 c9 03 00 00    	ja     800770 <vprintfmt+0x439>
  8003a7:	0f b6 c0             	movzbl %al,%eax
  8003aa:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b8:	eb d6                	jmp    800390 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  8003ba:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  8003c1:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  8003c7:	eb 94                	jmp    80035d <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  8003c9:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  8003d0:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  8003d6:	eb 85                	jmp    80035d <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  8003d8:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  8003df:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  8003e5:	e9 73 ff ff ff       	jmp    80035d <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  8003ea:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  8003f1:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  8003f7:	e9 61 ff ff ff       	jmp    80035d <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  8003fc:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800403:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  800409:	e9 4f ff ff ff       	jmp    80035d <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80040e:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800415:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80041b:	e9 3d ff ff ff       	jmp    80035d <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  800420:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  800427:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80042d:	e9 2b ff ff ff       	jmp    80035d <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  800432:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  800439:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  80043f:	e9 19 ff ff ff       	jmp    80035d <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800444:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  80044b:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  800451:	e9 07 ff ff ff       	jmp    80035d <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  800456:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  80045d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800463:	e9 f5 fe ff ff       	jmp    80035d <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800468:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046b:	b8 00 00 00 00       	mov    $0x0,%eax
  800470:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800473:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800476:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80047a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80047d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800480:	83 fa 09             	cmp    $0x9,%edx
  800483:	77 3f                	ja     8004c4 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800485:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800488:	eb e9                	jmp    800473 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048a:	8b 45 14             	mov    0x14(%ebp),%eax
  80048d:	8d 48 04             	lea    0x4(%eax),%ecx
  800490:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800493:	8b 00                	mov    (%eax),%eax
  800495:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80049b:	eb 2d                	jmp    8004ca <vprintfmt+0x193>
  80049d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a0:	85 c0                	test   %eax,%eax
  8004a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004a7:	0f 49 c8             	cmovns %eax,%ecx
  8004aa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b0:	e9 db fe ff ff       	jmp    800390 <vprintfmt+0x59>
  8004b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004bf:	e9 cc fe ff ff       	jmp    800390 <vprintfmt+0x59>
  8004c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004c7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ce:	0f 89 bc fe ff ff    	jns    800390 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004da:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004e1:	e9 aa fe ff ff       	jmp    800390 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ec:	e9 9f fe ff ff       	jmp    800390 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8d 50 04             	lea    0x4(%eax),%edx
  8004f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	ff 30                	pushl  (%eax)
  800500:	ff d6                	call   *%esi
			break;
  800502:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800505:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800508:	e9 50 fe ff ff       	jmp    80035d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8d 50 04             	lea    0x4(%eax),%edx
  800513:	89 55 14             	mov    %edx,0x14(%ebp)
  800516:	8b 00                	mov    (%eax),%eax
  800518:	99                   	cltd   
  800519:	31 d0                	xor    %edx,%eax
  80051b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051d:	83 f8 0f             	cmp    $0xf,%eax
  800520:	7f 0b                	jg     80052d <vprintfmt+0x1f6>
  800522:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  800529:	85 d2                	test   %edx,%edx
  80052b:	75 18                	jne    800545 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80052d:	50                   	push   %eax
  80052e:	68 9e 22 80 00       	push   $0x80229e
  800533:	53                   	push   %ebx
  800534:	56                   	push   %esi
  800535:	e8 e0 fd ff ff       	call   80031a <printfmt>
  80053a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800540:	e9 18 fe ff ff       	jmp    80035d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800545:	52                   	push   %edx
  800546:	68 51 26 80 00       	push   $0x802651
  80054b:	53                   	push   %ebx
  80054c:	56                   	push   %esi
  80054d:	e8 c8 fd ff ff       	call   80031a <printfmt>
  800552:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800555:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800558:	e9 00 fe ff ff       	jmp    80035d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8d 50 04             	lea    0x4(%eax),%edx
  800563:	89 55 14             	mov    %edx,0x14(%ebp)
  800566:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800568:	85 ff                	test   %edi,%edi
  80056a:	b8 97 22 80 00       	mov    $0x802297,%eax
  80056f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800572:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800576:	0f 8e 94 00 00 00    	jle    800610 <vprintfmt+0x2d9>
  80057c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800580:	0f 84 98 00 00 00    	je     80061e <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  800586:	83 ec 08             	sub    $0x8,%esp
  800589:	ff 75 d0             	pushl  -0x30(%ebp)
  80058c:	57                   	push   %edi
  80058d:	e8 81 02 00 00       	call   800813 <strnlen>
  800592:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800595:	29 c1                	sub    %eax,%ecx
  800597:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80059a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80059d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005a7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a9:	eb 0f                	jmp    8005ba <vprintfmt+0x283>
					putch(padc, putdat);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	53                   	push   %ebx
  8005af:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b4:	83 ef 01             	sub    $0x1,%edi
  8005b7:	83 c4 10             	add    $0x10,%esp
  8005ba:	85 ff                	test   %edi,%edi
  8005bc:	7f ed                	jg     8005ab <vprintfmt+0x274>
  8005be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005c1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005c4:	85 c9                	test   %ecx,%ecx
  8005c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005cb:	0f 49 c1             	cmovns %ecx,%eax
  8005ce:	29 c1                	sub    %eax,%ecx
  8005d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d9:	89 cb                	mov    %ecx,%ebx
  8005db:	eb 4d                	jmp    80062a <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e1:	74 1b                	je     8005fe <vprintfmt+0x2c7>
  8005e3:	0f be c0             	movsbl %al,%eax
  8005e6:	83 e8 20             	sub    $0x20,%eax
  8005e9:	83 f8 5e             	cmp    $0x5e,%eax
  8005ec:	76 10                	jbe    8005fe <vprintfmt+0x2c7>
					putch('?', putdat);
  8005ee:	83 ec 08             	sub    $0x8,%esp
  8005f1:	ff 75 0c             	pushl  0xc(%ebp)
  8005f4:	6a 3f                	push   $0x3f
  8005f6:	ff 55 08             	call   *0x8(%ebp)
  8005f9:	83 c4 10             	add    $0x10,%esp
  8005fc:	eb 0d                	jmp    80060b <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	ff 75 0c             	pushl  0xc(%ebp)
  800604:	52                   	push   %edx
  800605:	ff 55 08             	call   *0x8(%ebp)
  800608:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060b:	83 eb 01             	sub    $0x1,%ebx
  80060e:	eb 1a                	jmp    80062a <vprintfmt+0x2f3>
  800610:	89 75 08             	mov    %esi,0x8(%ebp)
  800613:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800616:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800619:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80061c:	eb 0c                	jmp    80062a <vprintfmt+0x2f3>
  80061e:	89 75 08             	mov    %esi,0x8(%ebp)
  800621:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800624:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800627:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80062a:	83 c7 01             	add    $0x1,%edi
  80062d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800631:	0f be d0             	movsbl %al,%edx
  800634:	85 d2                	test   %edx,%edx
  800636:	74 23                	je     80065b <vprintfmt+0x324>
  800638:	85 f6                	test   %esi,%esi
  80063a:	78 a1                	js     8005dd <vprintfmt+0x2a6>
  80063c:	83 ee 01             	sub    $0x1,%esi
  80063f:	79 9c                	jns    8005dd <vprintfmt+0x2a6>
  800641:	89 df                	mov    %ebx,%edi
  800643:	8b 75 08             	mov    0x8(%ebp),%esi
  800646:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800649:	eb 18                	jmp    800663 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	53                   	push   %ebx
  80064f:	6a 20                	push   $0x20
  800651:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800653:	83 ef 01             	sub    $0x1,%edi
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	eb 08                	jmp    800663 <vprintfmt+0x32c>
  80065b:	89 df                	mov    %ebx,%edi
  80065d:	8b 75 08             	mov    0x8(%ebp),%esi
  800660:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800663:	85 ff                	test   %edi,%edi
  800665:	7f e4                	jg     80064b <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800667:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80066a:	e9 ee fc ff ff       	jmp    80035d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066f:	83 fa 01             	cmp    $0x1,%edx
  800672:	7e 16                	jle    80068a <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8d 50 08             	lea    0x8(%eax),%edx
  80067a:	89 55 14             	mov    %edx,0x14(%ebp)
  80067d:	8b 50 04             	mov    0x4(%eax),%edx
  800680:	8b 00                	mov    (%eax),%eax
  800682:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800685:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800688:	eb 32                	jmp    8006bc <vprintfmt+0x385>
	else if (lflag)
  80068a:	85 d2                	test   %edx,%edx
  80068c:	74 18                	je     8006a6 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8d 50 04             	lea    0x4(%eax),%edx
  800694:	89 55 14             	mov    %edx,0x14(%ebp)
  800697:	8b 00                	mov    (%eax),%eax
  800699:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069c:	89 c1                	mov    %eax,%ecx
  80069e:	c1 f9 1f             	sar    $0x1f,%ecx
  8006a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a4:	eb 16                	jmp    8006bc <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 00                	mov    (%eax),%eax
  8006b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b4:	89 c1                	mov    %eax,%ecx
  8006b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c2:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006cb:	79 6f                	jns    80073c <vprintfmt+0x405>
				putch('-', putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	6a 2d                	push   $0x2d
  8006d3:	ff d6                	call   *%esi
				num = -(long long) num;
  8006d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006db:	f7 d8                	neg    %eax
  8006dd:	83 d2 00             	adc    $0x0,%edx
  8006e0:	f7 da                	neg    %edx
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	eb 55                	jmp    80073c <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ea:	e8 d4 fb ff ff       	call   8002c3 <getuint>
			base = 10;
  8006ef:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8006f4:	eb 46                	jmp    80073c <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f9:	e8 c5 fb ff ff       	call   8002c3 <getuint>
			base = 8;
  8006fe:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800703:	eb 37                	jmp    80073c <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	53                   	push   %ebx
  800709:	6a 30                	push   $0x30
  80070b:	ff d6                	call   *%esi
			putch('x', putdat);
  80070d:	83 c4 08             	add    $0x8,%esp
  800710:	53                   	push   %ebx
  800711:	6a 78                	push   $0x78
  800713:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8d 50 04             	lea    0x4(%eax),%edx
  80071b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80071e:	8b 00                	mov    (%eax),%eax
  800720:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800725:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800728:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80072d:	eb 0d                	jmp    80073c <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80072f:	8d 45 14             	lea    0x14(%ebp),%eax
  800732:	e8 8c fb ff ff       	call   8002c3 <getuint>
			base = 16;
  800737:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073c:	83 ec 0c             	sub    $0xc,%esp
  80073f:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800743:	51                   	push   %ecx
  800744:	ff 75 e0             	pushl  -0x20(%ebp)
  800747:	57                   	push   %edi
  800748:	52                   	push   %edx
  800749:	50                   	push   %eax
  80074a:	89 da                	mov    %ebx,%edx
  80074c:	89 f0                	mov    %esi,%eax
  80074e:	e8 c1 fa ff ff       	call   800214 <printnum>
			break;
  800753:	83 c4 20             	add    $0x20,%esp
  800756:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800759:	e9 ff fb ff ff       	jmp    80035d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80075e:	83 ec 08             	sub    $0x8,%esp
  800761:	53                   	push   %ebx
  800762:	51                   	push   %ecx
  800763:	ff d6                	call   *%esi
			break;
  800765:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800768:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80076b:	e9 ed fb ff ff       	jmp    80035d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	53                   	push   %ebx
  800774:	6a 25                	push   $0x25
  800776:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	eb 03                	jmp    800780 <vprintfmt+0x449>
  80077d:	83 ef 01             	sub    $0x1,%edi
  800780:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800784:	75 f7                	jne    80077d <vprintfmt+0x446>
  800786:	e9 d2 fb ff ff       	jmp    80035d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80078b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078e:	5b                   	pop    %ebx
  80078f:	5e                   	pop    %esi
  800790:	5f                   	pop    %edi
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	83 ec 18             	sub    $0x18,%esp
  800799:	8b 45 08             	mov    0x8(%ebp),%eax
  80079c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80079f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b0:	85 c0                	test   %eax,%eax
  8007b2:	74 26                	je     8007da <vsnprintf+0x47>
  8007b4:	85 d2                	test   %edx,%edx
  8007b6:	7e 22                	jle    8007da <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b8:	ff 75 14             	pushl  0x14(%ebp)
  8007bb:	ff 75 10             	pushl  0x10(%ebp)
  8007be:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c1:	50                   	push   %eax
  8007c2:	68 fd 02 80 00       	push   $0x8002fd
  8007c7:	e8 6b fb ff ff       	call   800337 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007cf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d5:	83 c4 10             	add    $0x10,%esp
  8007d8:	eb 05                	jmp    8007df <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    

008007e1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ea:	50                   	push   %eax
  8007eb:	ff 75 10             	pushl  0x10(%ebp)
  8007ee:	ff 75 0c             	pushl  0xc(%ebp)
  8007f1:	ff 75 08             	pushl  0x8(%ebp)
  8007f4:	e8 9a ff ff ff       	call   800793 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800801:	b8 00 00 00 00       	mov    $0x0,%eax
  800806:	eb 03                	jmp    80080b <strlen+0x10>
		n++;
  800808:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80080f:	75 f7                	jne    800808 <strlen+0xd>
		n++;
	return n;
}
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800819:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081c:	ba 00 00 00 00       	mov    $0x0,%edx
  800821:	eb 03                	jmp    800826 <strnlen+0x13>
		n++;
  800823:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800826:	39 c2                	cmp    %eax,%edx
  800828:	74 08                	je     800832 <strnlen+0x1f>
  80082a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80082e:	75 f3                	jne    800823 <strnlen+0x10>
  800830:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	53                   	push   %ebx
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80083e:	89 c2                	mov    %eax,%edx
  800840:	83 c2 01             	add    $0x1,%edx
  800843:	83 c1 01             	add    $0x1,%ecx
  800846:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80084d:	84 db                	test   %bl,%bl
  80084f:	75 ef                	jne    800840 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800851:	5b                   	pop    %ebx
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	53                   	push   %ebx
  800858:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085b:	53                   	push   %ebx
  80085c:	e8 9a ff ff ff       	call   8007fb <strlen>
  800861:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800864:	ff 75 0c             	pushl  0xc(%ebp)
  800867:	01 d8                	add    %ebx,%eax
  800869:	50                   	push   %eax
  80086a:	e8 c5 ff ff ff       	call   800834 <strcpy>
	return dst;
}
  80086f:	89 d8                	mov    %ebx,%eax
  800871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800874:	c9                   	leave  
  800875:	c3                   	ret    

00800876 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 75 08             	mov    0x8(%ebp),%esi
  80087e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800881:	89 f3                	mov    %esi,%ebx
  800883:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800886:	89 f2                	mov    %esi,%edx
  800888:	eb 0f                	jmp    800899 <strncpy+0x23>
		*dst++ = *src;
  80088a:	83 c2 01             	add    $0x1,%edx
  80088d:	0f b6 01             	movzbl (%ecx),%eax
  800890:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800893:	80 39 01             	cmpb   $0x1,(%ecx)
  800896:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800899:	39 da                	cmp    %ebx,%edx
  80089b:	75 ed                	jne    80088a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80089d:	89 f0                	mov    %esi,%eax
  80089f:	5b                   	pop    %ebx
  8008a0:	5e                   	pop    %esi
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
  8008a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ae:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b3:	85 d2                	test   %edx,%edx
  8008b5:	74 21                	je     8008d8 <strlcpy+0x35>
  8008b7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008bb:	89 f2                	mov    %esi,%edx
  8008bd:	eb 09                	jmp    8008c8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008bf:	83 c2 01             	add    $0x1,%edx
  8008c2:	83 c1 01             	add    $0x1,%ecx
  8008c5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c8:	39 c2                	cmp    %eax,%edx
  8008ca:	74 09                	je     8008d5 <strlcpy+0x32>
  8008cc:	0f b6 19             	movzbl (%ecx),%ebx
  8008cf:	84 db                	test   %bl,%bl
  8008d1:	75 ec                	jne    8008bf <strlcpy+0x1c>
  8008d3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008d8:	29 f0                	sub    %esi,%eax
}
  8008da:	5b                   	pop    %ebx
  8008db:	5e                   	pop    %esi
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e7:	eb 06                	jmp    8008ef <strcmp+0x11>
		p++, q++;
  8008e9:	83 c1 01             	add    $0x1,%ecx
  8008ec:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ef:	0f b6 01             	movzbl (%ecx),%eax
  8008f2:	84 c0                	test   %al,%al
  8008f4:	74 04                	je     8008fa <strcmp+0x1c>
  8008f6:	3a 02                	cmp    (%edx),%al
  8008f8:	74 ef                	je     8008e9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fa:	0f b6 c0             	movzbl %al,%eax
  8008fd:	0f b6 12             	movzbl (%edx),%edx
  800900:	29 d0                	sub    %edx,%eax
}
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	53                   	push   %ebx
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090e:	89 c3                	mov    %eax,%ebx
  800910:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800913:	eb 06                	jmp    80091b <strncmp+0x17>
		n--, p++, q++;
  800915:	83 c0 01             	add    $0x1,%eax
  800918:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80091b:	39 d8                	cmp    %ebx,%eax
  80091d:	74 15                	je     800934 <strncmp+0x30>
  80091f:	0f b6 08             	movzbl (%eax),%ecx
  800922:	84 c9                	test   %cl,%cl
  800924:	74 04                	je     80092a <strncmp+0x26>
  800926:	3a 0a                	cmp    (%edx),%cl
  800928:	74 eb                	je     800915 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092a:	0f b6 00             	movzbl (%eax),%eax
  80092d:	0f b6 12             	movzbl (%edx),%edx
  800930:	29 d0                	sub    %edx,%eax
  800932:	eb 05                	jmp    800939 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800939:	5b                   	pop    %ebx
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800946:	eb 07                	jmp    80094f <strchr+0x13>
		if (*s == c)
  800948:	38 ca                	cmp    %cl,%dl
  80094a:	74 0f                	je     80095b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094c:	83 c0 01             	add    $0x1,%eax
  80094f:	0f b6 10             	movzbl (%eax),%edx
  800952:	84 d2                	test   %dl,%dl
  800954:	75 f2                	jne    800948 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800967:	eb 03                	jmp    80096c <strfind+0xf>
  800969:	83 c0 01             	add    $0x1,%eax
  80096c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80096f:	38 ca                	cmp    %cl,%dl
  800971:	74 04                	je     800977 <strfind+0x1a>
  800973:	84 d2                	test   %dl,%dl
  800975:	75 f2                	jne    800969 <strfind+0xc>
			break;
	return (char *) s;
}
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	57                   	push   %edi
  80097d:	56                   	push   %esi
  80097e:	53                   	push   %ebx
  80097f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800982:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800985:	85 c9                	test   %ecx,%ecx
  800987:	74 36                	je     8009bf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800989:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098f:	75 28                	jne    8009b9 <memset+0x40>
  800991:	f6 c1 03             	test   $0x3,%cl
  800994:	75 23                	jne    8009b9 <memset+0x40>
		c &= 0xFF;
  800996:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099a:	89 d3                	mov    %edx,%ebx
  80099c:	c1 e3 08             	shl    $0x8,%ebx
  80099f:	89 d6                	mov    %edx,%esi
  8009a1:	c1 e6 18             	shl    $0x18,%esi
  8009a4:	89 d0                	mov    %edx,%eax
  8009a6:	c1 e0 10             	shl    $0x10,%eax
  8009a9:	09 f0                	or     %esi,%eax
  8009ab:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009ad:	89 d8                	mov    %ebx,%eax
  8009af:	09 d0                	or     %edx,%eax
  8009b1:	c1 e9 02             	shr    $0x2,%ecx
  8009b4:	fc                   	cld    
  8009b5:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b7:	eb 06                	jmp    8009bf <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bc:	fc                   	cld    
  8009bd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009bf:	89 f8                	mov    %edi,%eax
  8009c1:	5b                   	pop    %ebx
  8009c2:	5e                   	pop    %esi
  8009c3:	5f                   	pop    %edi
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	57                   	push   %edi
  8009ca:	56                   	push   %esi
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d4:	39 c6                	cmp    %eax,%esi
  8009d6:	73 35                	jae    800a0d <memmove+0x47>
  8009d8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009db:	39 d0                	cmp    %edx,%eax
  8009dd:	73 2e                	jae    800a0d <memmove+0x47>
		s += n;
		d += n;
  8009df:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e2:	89 d6                	mov    %edx,%esi
  8009e4:	09 fe                	or     %edi,%esi
  8009e6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ec:	75 13                	jne    800a01 <memmove+0x3b>
  8009ee:	f6 c1 03             	test   $0x3,%cl
  8009f1:	75 0e                	jne    800a01 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009f3:	83 ef 04             	sub    $0x4,%edi
  8009f6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f9:	c1 e9 02             	shr    $0x2,%ecx
  8009fc:	fd                   	std    
  8009fd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ff:	eb 09                	jmp    800a0a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a01:	83 ef 01             	sub    $0x1,%edi
  800a04:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a07:	fd                   	std    
  800a08:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0a:	fc                   	cld    
  800a0b:	eb 1d                	jmp    800a2a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0d:	89 f2                	mov    %esi,%edx
  800a0f:	09 c2                	or     %eax,%edx
  800a11:	f6 c2 03             	test   $0x3,%dl
  800a14:	75 0f                	jne    800a25 <memmove+0x5f>
  800a16:	f6 c1 03             	test   $0x3,%cl
  800a19:	75 0a                	jne    800a25 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a1b:	c1 e9 02             	shr    $0x2,%ecx
  800a1e:	89 c7                	mov    %eax,%edi
  800a20:	fc                   	cld    
  800a21:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a23:	eb 05                	jmp    800a2a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a25:	89 c7                	mov    %eax,%edi
  800a27:	fc                   	cld    
  800a28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a2a:	5e                   	pop    %esi
  800a2b:	5f                   	pop    %edi
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a31:	ff 75 10             	pushl  0x10(%ebp)
  800a34:	ff 75 0c             	pushl  0xc(%ebp)
  800a37:	ff 75 08             	pushl  0x8(%ebp)
  800a3a:	e8 87 ff ff ff       	call   8009c6 <memmove>
}
  800a3f:	c9                   	leave  
  800a40:	c3                   	ret    

00800a41 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4c:	89 c6                	mov    %eax,%esi
  800a4e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a51:	eb 1a                	jmp    800a6d <memcmp+0x2c>
		if (*s1 != *s2)
  800a53:	0f b6 08             	movzbl (%eax),%ecx
  800a56:	0f b6 1a             	movzbl (%edx),%ebx
  800a59:	38 d9                	cmp    %bl,%cl
  800a5b:	74 0a                	je     800a67 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a5d:	0f b6 c1             	movzbl %cl,%eax
  800a60:	0f b6 db             	movzbl %bl,%ebx
  800a63:	29 d8                	sub    %ebx,%eax
  800a65:	eb 0f                	jmp    800a76 <memcmp+0x35>
		s1++, s2++;
  800a67:	83 c0 01             	add    $0x1,%eax
  800a6a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6d:	39 f0                	cmp    %esi,%eax
  800a6f:	75 e2                	jne    800a53 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	53                   	push   %ebx
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a81:	89 c1                	mov    %eax,%ecx
  800a83:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a86:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8a:	eb 0a                	jmp    800a96 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8c:	0f b6 10             	movzbl (%eax),%edx
  800a8f:	39 da                	cmp    %ebx,%edx
  800a91:	74 07                	je     800a9a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a93:	83 c0 01             	add    $0x1,%eax
  800a96:	39 c8                	cmp    %ecx,%eax
  800a98:	72 f2                	jb     800a8c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a9a:	5b                   	pop    %ebx
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa9:	eb 03                	jmp    800aae <strtol+0x11>
		s++;
  800aab:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aae:	0f b6 01             	movzbl (%ecx),%eax
  800ab1:	3c 20                	cmp    $0x20,%al
  800ab3:	74 f6                	je     800aab <strtol+0xe>
  800ab5:	3c 09                	cmp    $0x9,%al
  800ab7:	74 f2                	je     800aab <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab9:	3c 2b                	cmp    $0x2b,%al
  800abb:	75 0a                	jne    800ac7 <strtol+0x2a>
		s++;
  800abd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac5:	eb 11                	jmp    800ad8 <strtol+0x3b>
  800ac7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800acc:	3c 2d                	cmp    $0x2d,%al
  800ace:	75 08                	jne    800ad8 <strtol+0x3b>
		s++, neg = 1;
  800ad0:	83 c1 01             	add    $0x1,%ecx
  800ad3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ade:	75 15                	jne    800af5 <strtol+0x58>
  800ae0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae3:	75 10                	jne    800af5 <strtol+0x58>
  800ae5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ae9:	75 7c                	jne    800b67 <strtol+0xca>
		s += 2, base = 16;
  800aeb:	83 c1 02             	add    $0x2,%ecx
  800aee:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af3:	eb 16                	jmp    800b0b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800af5:	85 db                	test   %ebx,%ebx
  800af7:	75 12                	jne    800b0b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800af9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800afe:	80 39 30             	cmpb   $0x30,(%ecx)
  800b01:	75 08                	jne    800b0b <strtol+0x6e>
		s++, base = 8;
  800b03:	83 c1 01             	add    $0x1,%ecx
  800b06:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b10:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b13:	0f b6 11             	movzbl (%ecx),%edx
  800b16:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b19:	89 f3                	mov    %esi,%ebx
  800b1b:	80 fb 09             	cmp    $0x9,%bl
  800b1e:	77 08                	ja     800b28 <strtol+0x8b>
			dig = *s - '0';
  800b20:	0f be d2             	movsbl %dl,%edx
  800b23:	83 ea 30             	sub    $0x30,%edx
  800b26:	eb 22                	jmp    800b4a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b28:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2b:	89 f3                	mov    %esi,%ebx
  800b2d:	80 fb 19             	cmp    $0x19,%bl
  800b30:	77 08                	ja     800b3a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b32:	0f be d2             	movsbl %dl,%edx
  800b35:	83 ea 57             	sub    $0x57,%edx
  800b38:	eb 10                	jmp    800b4a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b3a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b3d:	89 f3                	mov    %esi,%ebx
  800b3f:	80 fb 19             	cmp    $0x19,%bl
  800b42:	77 16                	ja     800b5a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b44:	0f be d2             	movsbl %dl,%edx
  800b47:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b4a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b4d:	7d 0b                	jge    800b5a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b4f:	83 c1 01             	add    $0x1,%ecx
  800b52:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b56:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b58:	eb b9                	jmp    800b13 <strtol+0x76>

	if (endptr)
  800b5a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b5e:	74 0d                	je     800b6d <strtol+0xd0>
		*endptr = (char *) s;
  800b60:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b63:	89 0e                	mov    %ecx,(%esi)
  800b65:	eb 06                	jmp    800b6d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b67:	85 db                	test   %ebx,%ebx
  800b69:	74 98                	je     800b03 <strtol+0x66>
  800b6b:	eb 9e                	jmp    800b0b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b6d:	89 c2                	mov    %eax,%edx
  800b6f:	f7 da                	neg    %edx
  800b71:	85 ff                	test   %edi,%edi
  800b73:	0f 45 c2             	cmovne %edx,%eax
}
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	83 ec 04             	sub    $0x4,%esp
  800b84:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800b87:	57                   	push   %edi
  800b88:	e8 6e fc ff ff       	call   8007fb <strlen>
  800b8d:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b90:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800b93:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800b98:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800b9d:	eb 46                	jmp    800be5 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800b9f:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800ba3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800ba6:	80 f9 09             	cmp    $0x9,%cl
  800ba9:	77 08                	ja     800bb3 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800bab:	0f be d2             	movsbl %dl,%edx
  800bae:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800bb1:	eb 27                	jmp    800bda <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800bb3:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800bb6:	80 f9 05             	cmp    $0x5,%cl
  800bb9:	77 08                	ja     800bc3 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800bbb:	0f be d2             	movsbl %dl,%edx
  800bbe:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800bc1:	eb 17                	jmp    800bda <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800bc3:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800bc6:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800bc9:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800bce:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800bd2:	77 06                	ja     800bda <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800bd4:	0f be d2             	movsbl %dl,%edx
  800bd7:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800bda:	0f af ce             	imul   %esi,%ecx
  800bdd:	01 c8                	add    %ecx,%eax
		base *= 16;
  800bdf:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800be2:	83 eb 01             	sub    $0x1,%ebx
  800be5:	83 fb 01             	cmp    $0x1,%ebx
  800be8:	7f b5                	jg     800b9f <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800bea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c00:	8b 55 08             	mov    0x8(%ebp),%edx
  800c03:	89 c3                	mov    %eax,%ebx
  800c05:	89 c7                	mov    %eax,%edi
  800c07:	89 c6                	mov    %eax,%esi
  800c09:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c16:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800c20:	89 d1                	mov    %edx,%ecx
  800c22:	89 d3                	mov    %edx,%ebx
  800c24:	89 d7                	mov    %edx,%edi
  800c26:	89 d6                	mov    %edx,%esi
  800c28:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3d:	b8 03 00 00 00       	mov    $0x3,%eax
  800c42:	8b 55 08             	mov    0x8(%ebp),%edx
  800c45:	89 cb                	mov    %ecx,%ebx
  800c47:	89 cf                	mov    %ecx,%edi
  800c49:	89 ce                	mov    %ecx,%esi
  800c4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	7e 17                	jle    800c68 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c51:	83 ec 0c             	sub    $0xc,%esp
  800c54:	50                   	push   %eax
  800c55:	6a 03                	push   $0x3
  800c57:	68 7f 25 80 00       	push   $0x80257f
  800c5c:	6a 23                	push   $0x23
  800c5e:	68 9c 25 80 00       	push   $0x80259c
  800c63:	e8 cd 11 00 00       	call   801e35 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c76:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800c80:	89 d1                	mov    %edx,%ecx
  800c82:	89 d3                	mov    %edx,%ebx
  800c84:	89 d7                	mov    %edx,%edi
  800c86:	89 d6                	mov    %edx,%esi
  800c88:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_yield>:

void
sys_yield(void)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c95:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c9f:	89 d1                	mov    %edx,%ecx
  800ca1:	89 d3                	mov    %edx,%ebx
  800ca3:	89 d7                	mov    %edx,%edi
  800ca5:	89 d6                	mov    %edx,%esi
  800ca7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	5d                   	pop    %ebp
  800cad:	c3                   	ret    

00800cae <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
  800cb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb7:	be 00 00 00 00       	mov    $0x0,%esi
  800cbc:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cca:	89 f7                	mov    %esi,%edi
  800ccc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	7e 17                	jle    800ce9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	50                   	push   %eax
  800cd6:	6a 04                	push   $0x4
  800cd8:	68 7f 25 80 00       	push   $0x80257f
  800cdd:	6a 23                	push   $0x23
  800cdf:	68 9c 25 80 00       	push   $0x80259c
  800ce4:	e8 4c 11 00 00       	call   801e35 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfa:	b8 05 00 00 00       	mov    $0x5,%eax
  800cff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d02:	8b 55 08             	mov    0x8(%ebp),%edx
  800d05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0b:	8b 75 18             	mov    0x18(%ebp),%esi
  800d0e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d10:	85 c0                	test   %eax,%eax
  800d12:	7e 17                	jle    800d2b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d14:	83 ec 0c             	sub    $0xc,%esp
  800d17:	50                   	push   %eax
  800d18:	6a 05                	push   $0x5
  800d1a:	68 7f 25 80 00       	push   $0x80257f
  800d1f:	6a 23                	push   $0x23
  800d21:	68 9c 25 80 00       	push   $0x80259c
  800d26:	e8 0a 11 00 00       	call   801e35 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d41:	b8 06 00 00 00       	mov    $0x6,%eax
  800d46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	89 df                	mov    %ebx,%edi
  800d4e:	89 de                	mov    %ebx,%esi
  800d50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d52:	85 c0                	test   %eax,%eax
  800d54:	7e 17                	jle    800d6d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d56:	83 ec 0c             	sub    $0xc,%esp
  800d59:	50                   	push   %eax
  800d5a:	6a 06                	push   $0x6
  800d5c:	68 7f 25 80 00       	push   $0x80257f
  800d61:	6a 23                	push   $0x23
  800d63:	68 9c 25 80 00       	push   $0x80259c
  800d68:	e8 c8 10 00 00       	call   801e35 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	57                   	push   %edi
  800d79:	56                   	push   %esi
  800d7a:	53                   	push   %ebx
  800d7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d83:	b8 08 00 00 00       	mov    $0x8,%eax
  800d88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8e:	89 df                	mov    %ebx,%edi
  800d90:	89 de                	mov    %ebx,%esi
  800d92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d94:	85 c0                	test   %eax,%eax
  800d96:	7e 17                	jle    800daf <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d98:	83 ec 0c             	sub    $0xc,%esp
  800d9b:	50                   	push   %eax
  800d9c:	6a 08                	push   $0x8
  800d9e:	68 7f 25 80 00       	push   $0x80257f
  800da3:	6a 23                	push   $0x23
  800da5:	68 9c 25 80 00       	push   $0x80259c
  800daa:	e8 86 10 00 00       	call   801e35 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800daf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	57                   	push   %edi
  800dbb:	56                   	push   %esi
  800dbc:	53                   	push   %ebx
  800dbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	89 df                	mov    %ebx,%edi
  800dd2:	89 de                	mov    %ebx,%esi
  800dd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	7e 17                	jle    800df1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dda:	83 ec 0c             	sub    $0xc,%esp
  800ddd:	50                   	push   %eax
  800dde:	6a 0a                	push   $0xa
  800de0:	68 7f 25 80 00       	push   $0x80257f
  800de5:	6a 23                	push   $0x23
  800de7:	68 9c 25 80 00       	push   $0x80259c
  800dec:	e8 44 10 00 00       	call   801e35 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800df1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	57                   	push   %edi
  800dfd:	56                   	push   %esi
  800dfe:	53                   	push   %ebx
  800dff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e07:	b8 09 00 00 00       	mov    $0x9,%eax
  800e0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e12:	89 df                	mov    %ebx,%edi
  800e14:	89 de                	mov    %ebx,%esi
  800e16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	7e 17                	jle    800e33 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1c:	83 ec 0c             	sub    $0xc,%esp
  800e1f:	50                   	push   %eax
  800e20:	6a 09                	push   $0x9
  800e22:	68 7f 25 80 00       	push   $0x80257f
  800e27:	6a 23                	push   $0x23
  800e29:	68 9c 25 80 00       	push   $0x80259c
  800e2e:	e8 02 10 00 00       	call   801e35 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e36:	5b                   	pop    %ebx
  800e37:	5e                   	pop    %esi
  800e38:	5f                   	pop    %edi
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    

00800e3b <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	57                   	push   %edi
  800e3f:	56                   	push   %esi
  800e40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e41:	be 00 00 00 00       	mov    $0x0,%esi
  800e46:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e57:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e59:	5b                   	pop    %ebx
  800e5a:	5e                   	pop    %esi
  800e5b:	5f                   	pop    %edi
  800e5c:	5d                   	pop    %ebp
  800e5d:	c3                   	ret    

00800e5e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	53                   	push   %ebx
  800e64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e6c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e71:	8b 55 08             	mov    0x8(%ebp),%edx
  800e74:	89 cb                	mov    %ecx,%ebx
  800e76:	89 cf                	mov    %ecx,%edi
  800e78:	89 ce                	mov    %ecx,%esi
  800e7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	7e 17                	jle    800e97 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e80:	83 ec 0c             	sub    $0xc,%esp
  800e83:	50                   	push   %eax
  800e84:	6a 0d                	push   $0xd
  800e86:	68 7f 25 80 00       	push   $0x80257f
  800e8b:	6a 23                	push   $0x23
  800e8d:	68 9c 25 80 00       	push   $0x80259c
  800e92:	e8 9e 0f 00 00       	call   801e35 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9a:	5b                   	pop    %ebx
  800e9b:	5e                   	pop    %esi
  800e9c:	5f                   	pop    %edi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea8:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800eab:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800ead:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800eb0:	83 3a 01             	cmpl   $0x1,(%edx)
  800eb3:	7e 09                	jle    800ebe <argstart+0x1f>
  800eb5:	ba 51 22 80 00       	mov    $0x802251,%edx
  800eba:	85 c9                	test   %ecx,%ecx
  800ebc:	75 05                	jne    800ec3 <argstart+0x24>
  800ebe:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec3:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800ec6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    

00800ecf <argnext>:

int
argnext(struct Argstate *args)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	53                   	push   %ebx
  800ed3:	83 ec 04             	sub    $0x4,%esp
  800ed6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800ed9:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800ee0:	8b 43 08             	mov    0x8(%ebx),%eax
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	74 6f                	je     800f56 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800ee7:	80 38 00             	cmpb   $0x0,(%eax)
  800eea:	75 4e                	jne    800f3a <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800eec:	8b 0b                	mov    (%ebx),%ecx
  800eee:	83 39 01             	cmpl   $0x1,(%ecx)
  800ef1:	74 55                	je     800f48 <argnext+0x79>
		    || args->argv[1][0] != '-'
  800ef3:	8b 53 04             	mov    0x4(%ebx),%edx
  800ef6:	8b 42 04             	mov    0x4(%edx),%eax
  800ef9:	80 38 2d             	cmpb   $0x2d,(%eax)
  800efc:	75 4a                	jne    800f48 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800efe:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800f02:	74 44                	je     800f48 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800f04:	83 c0 01             	add    $0x1,%eax
  800f07:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f0a:	83 ec 04             	sub    $0x4,%esp
  800f0d:	8b 01                	mov    (%ecx),%eax
  800f0f:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800f16:	50                   	push   %eax
  800f17:	8d 42 08             	lea    0x8(%edx),%eax
  800f1a:	50                   	push   %eax
  800f1b:	83 c2 04             	add    $0x4,%edx
  800f1e:	52                   	push   %edx
  800f1f:	e8 a2 fa ff ff       	call   8009c6 <memmove>
		(*args->argc)--;
  800f24:	8b 03                	mov    (%ebx),%eax
  800f26:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800f29:	8b 43 08             	mov    0x8(%ebx),%eax
  800f2c:	83 c4 10             	add    $0x10,%esp
  800f2f:	80 38 2d             	cmpb   $0x2d,(%eax)
  800f32:	75 06                	jne    800f3a <argnext+0x6b>
  800f34:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800f38:	74 0e                	je     800f48 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800f3a:	8b 53 08             	mov    0x8(%ebx),%edx
  800f3d:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800f40:	83 c2 01             	add    $0x1,%edx
  800f43:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800f46:	eb 13                	jmp    800f5b <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  800f48:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800f4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800f54:	eb 05                	jmp    800f5b <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800f56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800f5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f5e:	c9                   	leave  
  800f5f:	c3                   	ret    

00800f60 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	53                   	push   %ebx
  800f64:	83 ec 04             	sub    $0x4,%esp
  800f67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800f6a:	8b 43 08             	mov    0x8(%ebx),%eax
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	74 58                	je     800fc9 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  800f71:	80 38 00             	cmpb   $0x0,(%eax)
  800f74:	74 0c                	je     800f82 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800f76:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800f79:	c7 43 08 51 22 80 00 	movl   $0x802251,0x8(%ebx)
  800f80:	eb 42                	jmp    800fc4 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  800f82:	8b 13                	mov    (%ebx),%edx
  800f84:	83 3a 01             	cmpl   $0x1,(%edx)
  800f87:	7e 2d                	jle    800fb6 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  800f89:	8b 43 04             	mov    0x4(%ebx),%eax
  800f8c:	8b 48 04             	mov    0x4(%eax),%ecx
  800f8f:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f92:	83 ec 04             	sub    $0x4,%esp
  800f95:	8b 12                	mov    (%edx),%edx
  800f97:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800f9e:	52                   	push   %edx
  800f9f:	8d 50 08             	lea    0x8(%eax),%edx
  800fa2:	52                   	push   %edx
  800fa3:	83 c0 04             	add    $0x4,%eax
  800fa6:	50                   	push   %eax
  800fa7:	e8 1a fa ff ff       	call   8009c6 <memmove>
		(*args->argc)--;
  800fac:	8b 03                	mov    (%ebx),%eax
  800fae:	83 28 01             	subl   $0x1,(%eax)
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	eb 0e                	jmp    800fc4 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  800fb6:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800fbd:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800fc4:	8b 43 0c             	mov    0xc(%ebx),%eax
  800fc7:	eb 05                	jmp    800fce <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800fc9:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800fce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd1:	c9                   	leave  
  800fd2:	c3                   	ret    

00800fd3 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	83 ec 08             	sub    $0x8,%esp
  800fd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800fdc:	8b 51 0c             	mov    0xc(%ecx),%edx
  800fdf:	89 d0                	mov    %edx,%eax
  800fe1:	85 d2                	test   %edx,%edx
  800fe3:	75 0c                	jne    800ff1 <argvalue+0x1e>
  800fe5:	83 ec 0c             	sub    $0xc,%esp
  800fe8:	51                   	push   %ecx
  800fe9:	e8 72 ff ff ff       	call   800f60 <argnextvalue>
  800fee:	83 c4 10             	add    $0x10,%esp
}
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    

00800ff3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ff6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff9:	05 00 00 00 30       	add    $0x30000000,%eax
  800ffe:	c1 e8 0c             	shr    $0xc,%eax
}
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    

00801003 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801006:	8b 45 08             	mov    0x8(%ebp),%eax
  801009:	05 00 00 00 30       	add    $0x30000000,%eax
  80100e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801013:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801020:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801025:	89 c2                	mov    %eax,%edx
  801027:	c1 ea 16             	shr    $0x16,%edx
  80102a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801031:	f6 c2 01             	test   $0x1,%dl
  801034:	74 11                	je     801047 <fd_alloc+0x2d>
  801036:	89 c2                	mov    %eax,%edx
  801038:	c1 ea 0c             	shr    $0xc,%edx
  80103b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801042:	f6 c2 01             	test   $0x1,%dl
  801045:	75 09                	jne    801050 <fd_alloc+0x36>
			*fd_store = fd;
  801047:	89 01                	mov    %eax,(%ecx)
			return 0;
  801049:	b8 00 00 00 00       	mov    $0x0,%eax
  80104e:	eb 17                	jmp    801067 <fd_alloc+0x4d>
  801050:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801055:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80105a:	75 c9                	jne    801025 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80105c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801062:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    

00801069 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80106f:	83 f8 1f             	cmp    $0x1f,%eax
  801072:	77 36                	ja     8010aa <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801074:	c1 e0 0c             	shl    $0xc,%eax
  801077:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80107c:	89 c2                	mov    %eax,%edx
  80107e:	c1 ea 16             	shr    $0x16,%edx
  801081:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801088:	f6 c2 01             	test   $0x1,%dl
  80108b:	74 24                	je     8010b1 <fd_lookup+0x48>
  80108d:	89 c2                	mov    %eax,%edx
  80108f:	c1 ea 0c             	shr    $0xc,%edx
  801092:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801099:	f6 c2 01             	test   $0x1,%dl
  80109c:	74 1a                	je     8010b8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80109e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a1:	89 02                	mov    %eax,(%edx)
	return 0;
  8010a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a8:	eb 13                	jmp    8010bd <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010af:	eb 0c                	jmp    8010bd <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010b6:	eb 05                	jmp    8010bd <fd_lookup+0x54>
  8010b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	83 ec 08             	sub    $0x8,%esp
  8010c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c8:	ba 28 26 80 00       	mov    $0x802628,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010cd:	eb 13                	jmp    8010e2 <dev_lookup+0x23>
  8010cf:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010d2:	39 08                	cmp    %ecx,(%eax)
  8010d4:	75 0c                	jne    8010e2 <dev_lookup+0x23>
			*dev = devtab[i];
  8010d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010db:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e0:	eb 2e                	jmp    801110 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010e2:	8b 02                	mov    (%edx),%eax
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	75 e7                	jne    8010cf <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010e8:	a1 08 40 80 00       	mov    0x804008,%eax
  8010ed:	8b 40 48             	mov    0x48(%eax),%eax
  8010f0:	83 ec 04             	sub    $0x4,%esp
  8010f3:	51                   	push   %ecx
  8010f4:	50                   	push   %eax
  8010f5:	68 ac 25 80 00       	push   $0x8025ac
  8010fa:	e8 01 f1 ff ff       	call   800200 <cprintf>
	*dev = 0;
  8010ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801102:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801108:	83 c4 10             	add    $0x10,%esp
  80110b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801110:	c9                   	leave  
  801111:	c3                   	ret    

00801112 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
  801115:	56                   	push   %esi
  801116:	53                   	push   %ebx
  801117:	83 ec 10             	sub    $0x10,%esp
  80111a:	8b 75 08             	mov    0x8(%ebp),%esi
  80111d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801120:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801123:	50                   	push   %eax
  801124:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80112a:	c1 e8 0c             	shr    $0xc,%eax
  80112d:	50                   	push   %eax
  80112e:	e8 36 ff ff ff       	call   801069 <fd_lookup>
  801133:	83 c4 08             	add    $0x8,%esp
  801136:	85 c0                	test   %eax,%eax
  801138:	78 05                	js     80113f <fd_close+0x2d>
	    || fd != fd2) 
  80113a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80113d:	74 0c                	je     80114b <fd_close+0x39>
		return (must_exist ? r : 0); 
  80113f:	84 db                	test   %bl,%bl
  801141:	ba 00 00 00 00       	mov    $0x0,%edx
  801146:	0f 44 c2             	cmove  %edx,%eax
  801149:	eb 41                	jmp    80118c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80114b:	83 ec 08             	sub    $0x8,%esp
  80114e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801151:	50                   	push   %eax
  801152:	ff 36                	pushl  (%esi)
  801154:	e8 66 ff ff ff       	call   8010bf <dev_lookup>
  801159:	89 c3                	mov    %eax,%ebx
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	85 c0                	test   %eax,%eax
  801160:	78 1a                	js     80117c <fd_close+0x6a>
		if (dev->dev_close) 
  801162:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801165:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  801168:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  80116d:	85 c0                	test   %eax,%eax
  80116f:	74 0b                	je     80117c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801171:	83 ec 0c             	sub    $0xc,%esp
  801174:	56                   	push   %esi
  801175:	ff d0                	call   *%eax
  801177:	89 c3                	mov    %eax,%ebx
  801179:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80117c:	83 ec 08             	sub    $0x8,%esp
  80117f:	56                   	push   %esi
  801180:	6a 00                	push   $0x0
  801182:	e8 ac fb ff ff       	call   800d33 <sys_page_unmap>
	return r;
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	89 d8                	mov    %ebx,%eax
}
  80118c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80118f:	5b                   	pop    %ebx
  801190:	5e                   	pop    %esi
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    

00801193 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801199:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119c:	50                   	push   %eax
  80119d:	ff 75 08             	pushl  0x8(%ebp)
  8011a0:	e8 c4 fe ff ff       	call   801069 <fd_lookup>
  8011a5:	83 c4 08             	add    $0x8,%esp
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	78 10                	js     8011bc <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  8011ac:	83 ec 08             	sub    $0x8,%esp
  8011af:	6a 01                	push   $0x1
  8011b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8011b4:	e8 59 ff ff ff       	call   801112 <fd_close>
  8011b9:	83 c4 10             	add    $0x10,%esp
}
  8011bc:	c9                   	leave  
  8011bd:	c3                   	ret    

008011be <close_all>:

void
close_all(void)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	53                   	push   %ebx
  8011c2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011c5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011ca:	83 ec 0c             	sub    $0xc,%esp
  8011cd:	53                   	push   %ebx
  8011ce:	e8 c0 ff ff ff       	call   801193 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011d3:	83 c3 01             	add    $0x1,%ebx
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	83 fb 20             	cmp    $0x20,%ebx
  8011dc:	75 ec                	jne    8011ca <close_all+0xc>
		close(i);
}
  8011de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e1:	c9                   	leave  
  8011e2:	c3                   	ret    

008011e3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	57                   	push   %edi
  8011e7:	56                   	push   %esi
  8011e8:	53                   	push   %ebx
  8011e9:	83 ec 2c             	sub    $0x2c,%esp
  8011ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011ef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011f2:	50                   	push   %eax
  8011f3:	ff 75 08             	pushl  0x8(%ebp)
  8011f6:	e8 6e fe ff ff       	call   801069 <fd_lookup>
  8011fb:	83 c4 08             	add    $0x8,%esp
  8011fe:	85 c0                	test   %eax,%eax
  801200:	0f 88 c1 00 00 00    	js     8012c7 <dup+0xe4>
		return r;
	close(newfdnum);
  801206:	83 ec 0c             	sub    $0xc,%esp
  801209:	56                   	push   %esi
  80120a:	e8 84 ff ff ff       	call   801193 <close>

	newfd = INDEX2FD(newfdnum);
  80120f:	89 f3                	mov    %esi,%ebx
  801211:	c1 e3 0c             	shl    $0xc,%ebx
  801214:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80121a:	83 c4 04             	add    $0x4,%esp
  80121d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801220:	e8 de fd ff ff       	call   801003 <fd2data>
  801225:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801227:	89 1c 24             	mov    %ebx,(%esp)
  80122a:	e8 d4 fd ff ff       	call   801003 <fd2data>
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801235:	89 f8                	mov    %edi,%eax
  801237:	c1 e8 16             	shr    $0x16,%eax
  80123a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801241:	a8 01                	test   $0x1,%al
  801243:	74 37                	je     80127c <dup+0x99>
  801245:	89 f8                	mov    %edi,%eax
  801247:	c1 e8 0c             	shr    $0xc,%eax
  80124a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801251:	f6 c2 01             	test   $0x1,%dl
  801254:	74 26                	je     80127c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801256:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80125d:	83 ec 0c             	sub    $0xc,%esp
  801260:	25 07 0e 00 00       	and    $0xe07,%eax
  801265:	50                   	push   %eax
  801266:	ff 75 d4             	pushl  -0x2c(%ebp)
  801269:	6a 00                	push   $0x0
  80126b:	57                   	push   %edi
  80126c:	6a 00                	push   $0x0
  80126e:	e8 7e fa ff ff       	call   800cf1 <sys_page_map>
  801273:	89 c7                	mov    %eax,%edi
  801275:	83 c4 20             	add    $0x20,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	78 2e                	js     8012aa <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80127c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80127f:	89 d0                	mov    %edx,%eax
  801281:	c1 e8 0c             	shr    $0xc,%eax
  801284:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80128b:	83 ec 0c             	sub    $0xc,%esp
  80128e:	25 07 0e 00 00       	and    $0xe07,%eax
  801293:	50                   	push   %eax
  801294:	53                   	push   %ebx
  801295:	6a 00                	push   $0x0
  801297:	52                   	push   %edx
  801298:	6a 00                	push   $0x0
  80129a:	e8 52 fa ff ff       	call   800cf1 <sys_page_map>
  80129f:	89 c7                	mov    %eax,%edi
  8012a1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012a4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012a6:	85 ff                	test   %edi,%edi
  8012a8:	79 1d                	jns    8012c7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	53                   	push   %ebx
  8012ae:	6a 00                	push   $0x0
  8012b0:	e8 7e fa ff ff       	call   800d33 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012b5:	83 c4 08             	add    $0x8,%esp
  8012b8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012bb:	6a 00                	push   $0x0
  8012bd:	e8 71 fa ff ff       	call   800d33 <sys_page_unmap>
	return r;
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	89 f8                	mov    %edi,%eax
}
  8012c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ca:	5b                   	pop    %ebx
  8012cb:	5e                   	pop    %esi
  8012cc:	5f                   	pop    %edi
  8012cd:	5d                   	pop    %ebp
  8012ce:	c3                   	ret    

008012cf <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	53                   	push   %ebx
  8012d3:	83 ec 14             	sub    $0x14,%esp
  8012d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012dc:	50                   	push   %eax
  8012dd:	53                   	push   %ebx
  8012de:	e8 86 fd ff ff       	call   801069 <fd_lookup>
  8012e3:	83 c4 08             	add    $0x8,%esp
  8012e6:	89 c2                	mov    %eax,%edx
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	78 6d                	js     801359 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ec:	83 ec 08             	sub    $0x8,%esp
  8012ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f2:	50                   	push   %eax
  8012f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f6:	ff 30                	pushl  (%eax)
  8012f8:	e8 c2 fd ff ff       	call   8010bf <dev_lookup>
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	78 4c                	js     801350 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801304:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801307:	8b 42 08             	mov    0x8(%edx),%eax
  80130a:	83 e0 03             	and    $0x3,%eax
  80130d:	83 f8 01             	cmp    $0x1,%eax
  801310:	75 21                	jne    801333 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801312:	a1 08 40 80 00       	mov    0x804008,%eax
  801317:	8b 40 48             	mov    0x48(%eax),%eax
  80131a:	83 ec 04             	sub    $0x4,%esp
  80131d:	53                   	push   %ebx
  80131e:	50                   	push   %eax
  80131f:	68 ed 25 80 00       	push   $0x8025ed
  801324:	e8 d7 ee ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  801329:	83 c4 10             	add    $0x10,%esp
  80132c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801331:	eb 26                	jmp    801359 <read+0x8a>
	}
	if (!dev->dev_read)
  801333:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801336:	8b 40 08             	mov    0x8(%eax),%eax
  801339:	85 c0                	test   %eax,%eax
  80133b:	74 17                	je     801354 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80133d:	83 ec 04             	sub    $0x4,%esp
  801340:	ff 75 10             	pushl  0x10(%ebp)
  801343:	ff 75 0c             	pushl  0xc(%ebp)
  801346:	52                   	push   %edx
  801347:	ff d0                	call   *%eax
  801349:	89 c2                	mov    %eax,%edx
  80134b:	83 c4 10             	add    $0x10,%esp
  80134e:	eb 09                	jmp    801359 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801350:	89 c2                	mov    %eax,%edx
  801352:	eb 05                	jmp    801359 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801354:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801359:	89 d0                	mov    %edx,%eax
  80135b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135e:	c9                   	leave  
  80135f:	c3                   	ret    

00801360 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	57                   	push   %edi
  801364:	56                   	push   %esi
  801365:	53                   	push   %ebx
  801366:	83 ec 0c             	sub    $0xc,%esp
  801369:	8b 7d 08             	mov    0x8(%ebp),%edi
  80136c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80136f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801374:	eb 21                	jmp    801397 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801376:	83 ec 04             	sub    $0x4,%esp
  801379:	89 f0                	mov    %esi,%eax
  80137b:	29 d8                	sub    %ebx,%eax
  80137d:	50                   	push   %eax
  80137e:	89 d8                	mov    %ebx,%eax
  801380:	03 45 0c             	add    0xc(%ebp),%eax
  801383:	50                   	push   %eax
  801384:	57                   	push   %edi
  801385:	e8 45 ff ff ff       	call   8012cf <read>
		if (m < 0)
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	85 c0                	test   %eax,%eax
  80138f:	78 10                	js     8013a1 <readn+0x41>
			return m;
		if (m == 0)
  801391:	85 c0                	test   %eax,%eax
  801393:	74 0a                	je     80139f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801395:	01 c3                	add    %eax,%ebx
  801397:	39 f3                	cmp    %esi,%ebx
  801399:	72 db                	jb     801376 <readn+0x16>
  80139b:	89 d8                	mov    %ebx,%eax
  80139d:	eb 02                	jmp    8013a1 <readn+0x41>
  80139f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a4:	5b                   	pop    %ebx
  8013a5:	5e                   	pop    %esi
  8013a6:	5f                   	pop    %edi
  8013a7:	5d                   	pop    %ebp
  8013a8:	c3                   	ret    

008013a9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	53                   	push   %ebx
  8013ad:	83 ec 14             	sub    $0x14,%esp
  8013b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b6:	50                   	push   %eax
  8013b7:	53                   	push   %ebx
  8013b8:	e8 ac fc ff ff       	call   801069 <fd_lookup>
  8013bd:	83 c4 08             	add    $0x8,%esp
  8013c0:	89 c2                	mov    %eax,%edx
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	78 68                	js     80142e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c6:	83 ec 08             	sub    $0x8,%esp
  8013c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cc:	50                   	push   %eax
  8013cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d0:	ff 30                	pushl  (%eax)
  8013d2:	e8 e8 fc ff ff       	call   8010bf <dev_lookup>
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 47                	js     801425 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013e5:	75 21                	jne    801408 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013e7:	a1 08 40 80 00       	mov    0x804008,%eax
  8013ec:	8b 40 48             	mov    0x48(%eax),%eax
  8013ef:	83 ec 04             	sub    $0x4,%esp
  8013f2:	53                   	push   %ebx
  8013f3:	50                   	push   %eax
  8013f4:	68 09 26 80 00       	push   $0x802609
  8013f9:	e8 02 ee ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801406:	eb 26                	jmp    80142e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801408:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80140b:	8b 52 0c             	mov    0xc(%edx),%edx
  80140e:	85 d2                	test   %edx,%edx
  801410:	74 17                	je     801429 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801412:	83 ec 04             	sub    $0x4,%esp
  801415:	ff 75 10             	pushl  0x10(%ebp)
  801418:	ff 75 0c             	pushl  0xc(%ebp)
  80141b:	50                   	push   %eax
  80141c:	ff d2                	call   *%edx
  80141e:	89 c2                	mov    %eax,%edx
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	eb 09                	jmp    80142e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801425:	89 c2                	mov    %eax,%edx
  801427:	eb 05                	jmp    80142e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801429:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80142e:	89 d0                	mov    %edx,%eax
  801430:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801433:	c9                   	leave  
  801434:	c3                   	ret    

00801435 <seek>:

int
seek(int fdnum, off_t offset)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80143b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80143e:	50                   	push   %eax
  80143f:	ff 75 08             	pushl  0x8(%ebp)
  801442:	e8 22 fc ff ff       	call   801069 <fd_lookup>
  801447:	83 c4 08             	add    $0x8,%esp
  80144a:	85 c0                	test   %eax,%eax
  80144c:	78 0e                	js     80145c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80144e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801451:	8b 55 0c             	mov    0xc(%ebp),%edx
  801454:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801457:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80145c:	c9                   	leave  
  80145d:	c3                   	ret    

0080145e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	53                   	push   %ebx
  801462:	83 ec 14             	sub    $0x14,%esp
  801465:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801468:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146b:	50                   	push   %eax
  80146c:	53                   	push   %ebx
  80146d:	e8 f7 fb ff ff       	call   801069 <fd_lookup>
  801472:	83 c4 08             	add    $0x8,%esp
  801475:	89 c2                	mov    %eax,%edx
  801477:	85 c0                	test   %eax,%eax
  801479:	78 65                	js     8014e0 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147b:	83 ec 08             	sub    $0x8,%esp
  80147e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801481:	50                   	push   %eax
  801482:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801485:	ff 30                	pushl  (%eax)
  801487:	e8 33 fc ff ff       	call   8010bf <dev_lookup>
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	85 c0                	test   %eax,%eax
  801491:	78 44                	js     8014d7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801493:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801496:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80149a:	75 21                	jne    8014bd <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80149c:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014a1:	8b 40 48             	mov    0x48(%eax),%eax
  8014a4:	83 ec 04             	sub    $0x4,%esp
  8014a7:	53                   	push   %ebx
  8014a8:	50                   	push   %eax
  8014a9:	68 cc 25 80 00       	push   $0x8025cc
  8014ae:	e8 4d ed ff ff       	call   800200 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014bb:	eb 23                	jmp    8014e0 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c0:	8b 52 18             	mov    0x18(%edx),%edx
  8014c3:	85 d2                	test   %edx,%edx
  8014c5:	74 14                	je     8014db <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014c7:	83 ec 08             	sub    $0x8,%esp
  8014ca:	ff 75 0c             	pushl  0xc(%ebp)
  8014cd:	50                   	push   %eax
  8014ce:	ff d2                	call   *%edx
  8014d0:	89 c2                	mov    %eax,%edx
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	eb 09                	jmp    8014e0 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d7:	89 c2                	mov    %eax,%edx
  8014d9:	eb 05                	jmp    8014e0 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8014e0:	89 d0                	mov    %edx,%eax
  8014e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e5:	c9                   	leave  
  8014e6:	c3                   	ret    

008014e7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	53                   	push   %ebx
  8014eb:	83 ec 14             	sub    $0x14,%esp
  8014ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f4:	50                   	push   %eax
  8014f5:	ff 75 08             	pushl  0x8(%ebp)
  8014f8:	e8 6c fb ff ff       	call   801069 <fd_lookup>
  8014fd:	83 c4 08             	add    $0x8,%esp
  801500:	89 c2                	mov    %eax,%edx
  801502:	85 c0                	test   %eax,%eax
  801504:	78 58                	js     80155e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801506:	83 ec 08             	sub    $0x8,%esp
  801509:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150c:	50                   	push   %eax
  80150d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801510:	ff 30                	pushl  (%eax)
  801512:	e8 a8 fb ff ff       	call   8010bf <dev_lookup>
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	85 c0                	test   %eax,%eax
  80151c:	78 37                	js     801555 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80151e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801521:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801525:	74 32                	je     801559 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801527:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80152a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801531:	00 00 00 
	stat->st_isdir = 0;
  801534:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80153b:	00 00 00 
	stat->st_dev = dev;
  80153e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801544:	83 ec 08             	sub    $0x8,%esp
  801547:	53                   	push   %ebx
  801548:	ff 75 f0             	pushl  -0x10(%ebp)
  80154b:	ff 50 14             	call   *0x14(%eax)
  80154e:	89 c2                	mov    %eax,%edx
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	eb 09                	jmp    80155e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801555:	89 c2                	mov    %eax,%edx
  801557:	eb 05                	jmp    80155e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801559:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80155e:	89 d0                	mov    %edx,%eax
  801560:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801563:	c9                   	leave  
  801564:	c3                   	ret    

00801565 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	56                   	push   %esi
  801569:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80156a:	83 ec 08             	sub    $0x8,%esp
  80156d:	6a 00                	push   $0x0
  80156f:	ff 75 08             	pushl  0x8(%ebp)
  801572:	e8 2b 02 00 00       	call   8017a2 <open>
  801577:	89 c3                	mov    %eax,%ebx
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 1b                	js     80159b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801580:	83 ec 08             	sub    $0x8,%esp
  801583:	ff 75 0c             	pushl  0xc(%ebp)
  801586:	50                   	push   %eax
  801587:	e8 5b ff ff ff       	call   8014e7 <fstat>
  80158c:	89 c6                	mov    %eax,%esi
	close(fd);
  80158e:	89 1c 24             	mov    %ebx,(%esp)
  801591:	e8 fd fb ff ff       	call   801193 <close>
	return r;
  801596:	83 c4 10             	add    $0x10,%esp
  801599:	89 f0                	mov    %esi,%eax
}
  80159b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159e:	5b                   	pop    %ebx
  80159f:	5e                   	pop    %esi
  8015a0:	5d                   	pop    %ebp
  8015a1:	c3                   	ret    

008015a2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	56                   	push   %esi
  8015a6:	53                   	push   %ebx
  8015a7:	89 c6                	mov    %eax,%esi
  8015a9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015ab:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8015b2:	75 12                	jne    8015c6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015b4:	83 ec 0c             	sub    $0xc,%esp
  8015b7:	6a 01                	push   $0x1
  8015b9:	e8 7c 09 00 00       	call   801f3a <ipc_find_env>
  8015be:	a3 04 40 80 00       	mov    %eax,0x804004
  8015c3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015c6:	6a 07                	push   $0x7
  8015c8:	68 00 50 80 00       	push   $0x805000
  8015cd:	56                   	push   %esi
  8015ce:	ff 35 04 40 80 00    	pushl  0x804004
  8015d4:	e8 0b 09 00 00       	call   801ee4 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8015d9:	83 c4 0c             	add    $0xc,%esp
  8015dc:	6a 00                	push   $0x0
  8015de:	53                   	push   %ebx
  8015df:	6a 00                	push   $0x0
  8015e1:	e8 95 08 00 00       	call   801e7b <ipc_recv>
}
  8015e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e9:	5b                   	pop    %ebx
  8015ea:	5e                   	pop    %esi
  8015eb:	5d                   	pop    %ebp
  8015ec:	c3                   	ret    

008015ed <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8015f9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801601:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801606:	ba 00 00 00 00       	mov    $0x0,%edx
  80160b:	b8 02 00 00 00       	mov    $0x2,%eax
  801610:	e8 8d ff ff ff       	call   8015a2 <fsipc>
}
  801615:	c9                   	leave  
  801616:	c3                   	ret    

00801617 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80161d:	8b 45 08             	mov    0x8(%ebp),%eax
  801620:	8b 40 0c             	mov    0xc(%eax),%eax
  801623:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801628:	ba 00 00 00 00       	mov    $0x0,%edx
  80162d:	b8 06 00 00 00       	mov    $0x6,%eax
  801632:	e8 6b ff ff ff       	call   8015a2 <fsipc>
}
  801637:	c9                   	leave  
  801638:	c3                   	ret    

00801639 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	53                   	push   %ebx
  80163d:	83 ec 04             	sub    $0x4,%esp
  801640:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801643:	8b 45 08             	mov    0x8(%ebp),%eax
  801646:	8b 40 0c             	mov    0xc(%eax),%eax
  801649:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80164e:	ba 00 00 00 00       	mov    $0x0,%edx
  801653:	b8 05 00 00 00       	mov    $0x5,%eax
  801658:	e8 45 ff ff ff       	call   8015a2 <fsipc>
  80165d:	85 c0                	test   %eax,%eax
  80165f:	78 2c                	js     80168d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801661:	83 ec 08             	sub    $0x8,%esp
  801664:	68 00 50 80 00       	push   $0x805000
  801669:	53                   	push   %ebx
  80166a:	e8 c5 f1 ff ff       	call   800834 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80166f:	a1 80 50 80 00       	mov    0x805080,%eax
  801674:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80167a:	a1 84 50 80 00       	mov    0x805084,%eax
  80167f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80168d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801690:	c9                   	leave  
  801691:	c3                   	ret    

00801692 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	53                   	push   %ebx
  801696:	83 ec 08             	sub    $0x8,%esp
  801699:	8b 45 10             	mov    0x10(%ebp),%eax
  80169c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016a1:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8016a6:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8016af:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  8016b4:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8016ba:	53                   	push   %ebx
  8016bb:	ff 75 0c             	pushl  0xc(%ebp)
  8016be:	68 08 50 80 00       	push   $0x805008
  8016c3:	e8 fe f2 ff ff       	call   8009c6 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8016c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cd:	b8 04 00 00 00       	mov    $0x4,%eax
  8016d2:	e8 cb fe ff ff       	call   8015a2 <fsipc>
  8016d7:	83 c4 10             	add    $0x10,%esp
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	78 3d                	js     80171b <devfile_write+0x89>
		return r;

	assert(r <= n);
  8016de:	39 d8                	cmp    %ebx,%eax
  8016e0:	76 19                	jbe    8016fb <devfile_write+0x69>
  8016e2:	68 38 26 80 00       	push   $0x802638
  8016e7:	68 3f 26 80 00       	push   $0x80263f
  8016ec:	68 9f 00 00 00       	push   $0x9f
  8016f1:	68 54 26 80 00       	push   $0x802654
  8016f6:	e8 3a 07 00 00       	call   801e35 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  8016fb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801700:	76 19                	jbe    80171b <devfile_write+0x89>
  801702:	68 6c 26 80 00       	push   $0x80266c
  801707:	68 3f 26 80 00       	push   $0x80263f
  80170c:	68 a0 00 00 00       	push   $0xa0
  801711:	68 54 26 80 00       	push   $0x802654
  801716:	e8 1a 07 00 00       	call   801e35 <_panic>

	return r;
}
  80171b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171e:	c9                   	leave  
  80171f:	c3                   	ret    

00801720 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	56                   	push   %esi
  801724:	53                   	push   %ebx
  801725:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801728:	8b 45 08             	mov    0x8(%ebp),%eax
  80172b:	8b 40 0c             	mov    0xc(%eax),%eax
  80172e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801733:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801739:	ba 00 00 00 00       	mov    $0x0,%edx
  80173e:	b8 03 00 00 00       	mov    $0x3,%eax
  801743:	e8 5a fe ff ff       	call   8015a2 <fsipc>
  801748:	89 c3                	mov    %eax,%ebx
  80174a:	85 c0                	test   %eax,%eax
  80174c:	78 4b                	js     801799 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80174e:	39 c6                	cmp    %eax,%esi
  801750:	73 16                	jae    801768 <devfile_read+0x48>
  801752:	68 38 26 80 00       	push   $0x802638
  801757:	68 3f 26 80 00       	push   $0x80263f
  80175c:	6a 7e                	push   $0x7e
  80175e:	68 54 26 80 00       	push   $0x802654
  801763:	e8 cd 06 00 00       	call   801e35 <_panic>
	assert(r <= PGSIZE);
  801768:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80176d:	7e 16                	jle    801785 <devfile_read+0x65>
  80176f:	68 5f 26 80 00       	push   $0x80265f
  801774:	68 3f 26 80 00       	push   $0x80263f
  801779:	6a 7f                	push   $0x7f
  80177b:	68 54 26 80 00       	push   $0x802654
  801780:	e8 b0 06 00 00       	call   801e35 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801785:	83 ec 04             	sub    $0x4,%esp
  801788:	50                   	push   %eax
  801789:	68 00 50 80 00       	push   $0x805000
  80178e:	ff 75 0c             	pushl  0xc(%ebp)
  801791:	e8 30 f2 ff ff       	call   8009c6 <memmove>
	return r;
  801796:	83 c4 10             	add    $0x10,%esp
}
  801799:	89 d8                	mov    %ebx,%eax
  80179b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179e:	5b                   	pop    %ebx
  80179f:	5e                   	pop    %esi
  8017a0:	5d                   	pop    %ebp
  8017a1:	c3                   	ret    

008017a2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	53                   	push   %ebx
  8017a6:	83 ec 20             	sub    $0x20,%esp
  8017a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017ac:	53                   	push   %ebx
  8017ad:	e8 49 f0 ff ff       	call   8007fb <strlen>
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017ba:	7f 67                	jg     801823 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017bc:	83 ec 0c             	sub    $0xc,%esp
  8017bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c2:	50                   	push   %eax
  8017c3:	e8 52 f8 ff ff       	call   80101a <fd_alloc>
  8017c8:	83 c4 10             	add    $0x10,%esp
		return r;
  8017cb:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	78 57                	js     801828 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017d1:	83 ec 08             	sub    $0x8,%esp
  8017d4:	53                   	push   %ebx
  8017d5:	68 00 50 80 00       	push   $0x805000
  8017da:	e8 55 f0 ff ff       	call   800834 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8017ef:	e8 ae fd ff ff       	call   8015a2 <fsipc>
  8017f4:	89 c3                	mov    %eax,%ebx
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	79 14                	jns    801811 <open+0x6f>
		fd_close(fd, 0);
  8017fd:	83 ec 08             	sub    $0x8,%esp
  801800:	6a 00                	push   $0x0
  801802:	ff 75 f4             	pushl  -0xc(%ebp)
  801805:	e8 08 f9 ff ff       	call   801112 <fd_close>
		return r;
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	89 da                	mov    %ebx,%edx
  80180f:	eb 17                	jmp    801828 <open+0x86>
	}

	return fd2num(fd);
  801811:	83 ec 0c             	sub    $0xc,%esp
  801814:	ff 75 f4             	pushl  -0xc(%ebp)
  801817:	e8 d7 f7 ff ff       	call   800ff3 <fd2num>
  80181c:	89 c2                	mov    %eax,%edx
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	eb 05                	jmp    801828 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801823:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801828:	89 d0                	mov    %edx,%eax
  80182a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182d:	c9                   	leave  
  80182e:	c3                   	ret    

0080182f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801835:	ba 00 00 00 00       	mov    $0x0,%edx
  80183a:	b8 08 00 00 00       	mov    $0x8,%eax
  80183f:	e8 5e fd ff ff       	call   8015a2 <fsipc>
}
  801844:	c9                   	leave  
  801845:	c3                   	ret    

00801846 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801846:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80184a:	7e 37                	jle    801883 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	53                   	push   %ebx
  801850:	83 ec 08             	sub    $0x8,%esp
  801853:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801855:	ff 70 04             	pushl  0x4(%eax)
  801858:	8d 40 10             	lea    0x10(%eax),%eax
  80185b:	50                   	push   %eax
  80185c:	ff 33                	pushl  (%ebx)
  80185e:	e8 46 fb ff ff       	call   8013a9 <write>
		if (result > 0)
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	85 c0                	test   %eax,%eax
  801868:	7e 03                	jle    80186d <writebuf+0x27>
			b->result += result;
  80186a:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80186d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801870:	74 0d                	je     80187f <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801872:	85 c0                	test   %eax,%eax
  801874:	ba 00 00 00 00       	mov    $0x0,%edx
  801879:	0f 4f c2             	cmovg  %edx,%eax
  80187c:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80187f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801882:	c9                   	leave  
  801883:	f3 c3                	repz ret 

00801885 <putch>:

static void
putch(int ch, void *thunk)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	53                   	push   %ebx
  801889:	83 ec 04             	sub    $0x4,%esp
  80188c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80188f:	8b 53 04             	mov    0x4(%ebx),%edx
  801892:	8d 42 01             	lea    0x1(%edx),%eax
  801895:	89 43 04             	mov    %eax,0x4(%ebx)
  801898:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80189b:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80189f:	3d 00 01 00 00       	cmp    $0x100,%eax
  8018a4:	75 0e                	jne    8018b4 <putch+0x2f>
		writebuf(b);
  8018a6:	89 d8                	mov    %ebx,%eax
  8018a8:	e8 99 ff ff ff       	call   801846 <writebuf>
		b->idx = 0;
  8018ad:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8018b4:	83 c4 04             	add    $0x4,%esp
  8018b7:	5b                   	pop    %ebx
  8018b8:	5d                   	pop    %ebp
  8018b9:	c3                   	ret    

008018ba <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8018c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c6:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8018cc:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8018d3:	00 00 00 
	b.result = 0;
  8018d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8018dd:	00 00 00 
	b.error = 1;
  8018e0:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8018e7:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8018ea:	ff 75 10             	pushl  0x10(%ebp)
  8018ed:	ff 75 0c             	pushl  0xc(%ebp)
  8018f0:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018f6:	50                   	push   %eax
  8018f7:	68 85 18 80 00       	push   $0x801885
  8018fc:	e8 36 ea ff ff       	call   800337 <vprintfmt>
	if (b.idx > 0)
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80190b:	7e 0b                	jle    801918 <vfprintf+0x5e>
		writebuf(&b);
  80190d:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801913:	e8 2e ff ff ff       	call   801846 <writebuf>

	return (b.result ? b.result : b.error);
  801918:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80191e:	85 c0                	test   %eax,%eax
  801920:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801927:	c9                   	leave  
  801928:	c3                   	ret    

00801929 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80192f:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801932:	50                   	push   %eax
  801933:	ff 75 0c             	pushl  0xc(%ebp)
  801936:	ff 75 08             	pushl  0x8(%ebp)
  801939:	e8 7c ff ff ff       	call   8018ba <vfprintf>
	va_end(ap);

	return cnt;
}
  80193e:	c9                   	leave  
  80193f:	c3                   	ret    

00801940 <printf>:

int
printf(const char *fmt, ...)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801946:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801949:	50                   	push   %eax
  80194a:	ff 75 08             	pushl  0x8(%ebp)
  80194d:	6a 01                	push   $0x1
  80194f:	e8 66 ff ff ff       	call   8018ba <vfprintf>
	va_end(ap);

	return cnt;
}
  801954:	c9                   	leave  
  801955:	c3                   	ret    

00801956 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	56                   	push   %esi
  80195a:	53                   	push   %ebx
  80195b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80195e:	83 ec 0c             	sub    $0xc,%esp
  801961:	ff 75 08             	pushl  0x8(%ebp)
  801964:	e8 9a f6 ff ff       	call   801003 <fd2data>
  801969:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80196b:	83 c4 08             	add    $0x8,%esp
  80196e:	68 99 26 80 00       	push   $0x802699
  801973:	53                   	push   %ebx
  801974:	e8 bb ee ff ff       	call   800834 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801979:	8b 46 04             	mov    0x4(%esi),%eax
  80197c:	2b 06                	sub    (%esi),%eax
  80197e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801984:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80198b:	00 00 00 
	stat->st_dev = &devpipe;
  80198e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801995:	30 80 00 
	return 0;
}
  801998:	b8 00 00 00 00       	mov    $0x0,%eax
  80199d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a0:	5b                   	pop    %ebx
  8019a1:	5e                   	pop    %esi
  8019a2:	5d                   	pop    %ebp
  8019a3:	c3                   	ret    

008019a4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	53                   	push   %ebx
  8019a8:	83 ec 0c             	sub    $0xc,%esp
  8019ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019ae:	53                   	push   %ebx
  8019af:	6a 00                	push   $0x0
  8019b1:	e8 7d f3 ff ff       	call   800d33 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019b6:	89 1c 24             	mov    %ebx,(%esp)
  8019b9:	e8 45 f6 ff ff       	call   801003 <fd2data>
  8019be:	83 c4 08             	add    $0x8,%esp
  8019c1:	50                   	push   %eax
  8019c2:	6a 00                	push   $0x0
  8019c4:	e8 6a f3 ff ff       	call   800d33 <sys_page_unmap>
}
  8019c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019cc:	c9                   	leave  
  8019cd:	c3                   	ret    

008019ce <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	57                   	push   %edi
  8019d2:	56                   	push   %esi
  8019d3:	53                   	push   %ebx
  8019d4:	83 ec 1c             	sub    $0x1c,%esp
  8019d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019da:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019dc:	a1 08 40 80 00       	mov    0x804008,%eax
  8019e1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019e4:	83 ec 0c             	sub    $0xc,%esp
  8019e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8019ea:	e8 84 05 00 00       	call   801f73 <pageref>
  8019ef:	89 c3                	mov    %eax,%ebx
  8019f1:	89 3c 24             	mov    %edi,(%esp)
  8019f4:	e8 7a 05 00 00       	call   801f73 <pageref>
  8019f9:	83 c4 10             	add    $0x10,%esp
  8019fc:	39 c3                	cmp    %eax,%ebx
  8019fe:	0f 94 c1             	sete   %cl
  801a01:	0f b6 c9             	movzbl %cl,%ecx
  801a04:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a07:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a0d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a10:	39 ce                	cmp    %ecx,%esi
  801a12:	74 1b                	je     801a2f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a14:	39 c3                	cmp    %eax,%ebx
  801a16:	75 c4                	jne    8019dc <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a18:	8b 42 58             	mov    0x58(%edx),%eax
  801a1b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a1e:	50                   	push   %eax
  801a1f:	56                   	push   %esi
  801a20:	68 a0 26 80 00       	push   $0x8026a0
  801a25:	e8 d6 e7 ff ff       	call   800200 <cprintf>
  801a2a:	83 c4 10             	add    $0x10,%esp
  801a2d:	eb ad                	jmp    8019dc <_pipeisclosed+0xe>
	}
}
  801a2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a35:	5b                   	pop    %ebx
  801a36:	5e                   	pop    %esi
  801a37:	5f                   	pop    %edi
  801a38:	5d                   	pop    %ebp
  801a39:	c3                   	ret    

00801a3a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	57                   	push   %edi
  801a3e:	56                   	push   %esi
  801a3f:	53                   	push   %ebx
  801a40:	83 ec 28             	sub    $0x28,%esp
  801a43:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a46:	56                   	push   %esi
  801a47:	e8 b7 f5 ff ff       	call   801003 <fd2data>
  801a4c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	bf 00 00 00 00       	mov    $0x0,%edi
  801a56:	eb 4b                	jmp    801aa3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a58:	89 da                	mov    %ebx,%edx
  801a5a:	89 f0                	mov    %esi,%eax
  801a5c:	e8 6d ff ff ff       	call   8019ce <_pipeisclosed>
  801a61:	85 c0                	test   %eax,%eax
  801a63:	75 48                	jne    801aad <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a65:	e8 25 f2 ff ff       	call   800c8f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a6a:	8b 43 04             	mov    0x4(%ebx),%eax
  801a6d:	8b 0b                	mov    (%ebx),%ecx
  801a6f:	8d 51 20             	lea    0x20(%ecx),%edx
  801a72:	39 d0                	cmp    %edx,%eax
  801a74:	73 e2                	jae    801a58 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a79:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a7d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a80:	89 c2                	mov    %eax,%edx
  801a82:	c1 fa 1f             	sar    $0x1f,%edx
  801a85:	89 d1                	mov    %edx,%ecx
  801a87:	c1 e9 1b             	shr    $0x1b,%ecx
  801a8a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a8d:	83 e2 1f             	and    $0x1f,%edx
  801a90:	29 ca                	sub    %ecx,%edx
  801a92:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a96:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a9a:	83 c0 01             	add    $0x1,%eax
  801a9d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa0:	83 c7 01             	add    $0x1,%edi
  801aa3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801aa6:	75 c2                	jne    801a6a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801aa8:	8b 45 10             	mov    0x10(%ebp),%eax
  801aab:	eb 05                	jmp    801ab2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aad:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ab2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab5:	5b                   	pop    %ebx
  801ab6:	5e                   	pop    %esi
  801ab7:	5f                   	pop    %edi
  801ab8:	5d                   	pop    %ebp
  801ab9:	c3                   	ret    

00801aba <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	57                   	push   %edi
  801abe:	56                   	push   %esi
  801abf:	53                   	push   %ebx
  801ac0:	83 ec 18             	sub    $0x18,%esp
  801ac3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ac6:	57                   	push   %edi
  801ac7:	e8 37 f5 ff ff       	call   801003 <fd2data>
  801acc:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ad6:	eb 3d                	jmp    801b15 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ad8:	85 db                	test   %ebx,%ebx
  801ada:	74 04                	je     801ae0 <devpipe_read+0x26>
				return i;
  801adc:	89 d8                	mov    %ebx,%eax
  801ade:	eb 44                	jmp    801b24 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ae0:	89 f2                	mov    %esi,%edx
  801ae2:	89 f8                	mov    %edi,%eax
  801ae4:	e8 e5 fe ff ff       	call   8019ce <_pipeisclosed>
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	75 32                	jne    801b1f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801aed:	e8 9d f1 ff ff       	call   800c8f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801af2:	8b 06                	mov    (%esi),%eax
  801af4:	3b 46 04             	cmp    0x4(%esi),%eax
  801af7:	74 df                	je     801ad8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801af9:	99                   	cltd   
  801afa:	c1 ea 1b             	shr    $0x1b,%edx
  801afd:	01 d0                	add    %edx,%eax
  801aff:	83 e0 1f             	and    $0x1f,%eax
  801b02:	29 d0                	sub    %edx,%eax
  801b04:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b0f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b12:	83 c3 01             	add    $0x1,%ebx
  801b15:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b18:	75 d8                	jne    801af2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b1a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b1d:	eb 05                	jmp    801b24 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b1f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b27:	5b                   	pop    %ebx
  801b28:	5e                   	pop    %esi
  801b29:	5f                   	pop    %edi
  801b2a:	5d                   	pop    %ebp
  801b2b:	c3                   	ret    

00801b2c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	56                   	push   %esi
  801b30:	53                   	push   %ebx
  801b31:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b37:	50                   	push   %eax
  801b38:	e8 dd f4 ff ff       	call   80101a <fd_alloc>
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	89 c2                	mov    %eax,%edx
  801b42:	85 c0                	test   %eax,%eax
  801b44:	0f 88 2c 01 00 00    	js     801c76 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b4a:	83 ec 04             	sub    $0x4,%esp
  801b4d:	68 07 04 00 00       	push   $0x407
  801b52:	ff 75 f4             	pushl  -0xc(%ebp)
  801b55:	6a 00                	push   $0x0
  801b57:	e8 52 f1 ff ff       	call   800cae <sys_page_alloc>
  801b5c:	83 c4 10             	add    $0x10,%esp
  801b5f:	89 c2                	mov    %eax,%edx
  801b61:	85 c0                	test   %eax,%eax
  801b63:	0f 88 0d 01 00 00    	js     801c76 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b69:	83 ec 0c             	sub    $0xc,%esp
  801b6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b6f:	50                   	push   %eax
  801b70:	e8 a5 f4 ff ff       	call   80101a <fd_alloc>
  801b75:	89 c3                	mov    %eax,%ebx
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	0f 88 e2 00 00 00    	js     801c64 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b82:	83 ec 04             	sub    $0x4,%esp
  801b85:	68 07 04 00 00       	push   $0x407
  801b8a:	ff 75 f0             	pushl  -0x10(%ebp)
  801b8d:	6a 00                	push   $0x0
  801b8f:	e8 1a f1 ff ff       	call   800cae <sys_page_alloc>
  801b94:	89 c3                	mov    %eax,%ebx
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	0f 88 c3 00 00 00    	js     801c64 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ba1:	83 ec 0c             	sub    $0xc,%esp
  801ba4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba7:	e8 57 f4 ff ff       	call   801003 <fd2data>
  801bac:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bae:	83 c4 0c             	add    $0xc,%esp
  801bb1:	68 07 04 00 00       	push   $0x407
  801bb6:	50                   	push   %eax
  801bb7:	6a 00                	push   $0x0
  801bb9:	e8 f0 f0 ff ff       	call   800cae <sys_page_alloc>
  801bbe:	89 c3                	mov    %eax,%ebx
  801bc0:	83 c4 10             	add    $0x10,%esp
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	0f 88 89 00 00 00    	js     801c54 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bcb:	83 ec 0c             	sub    $0xc,%esp
  801bce:	ff 75 f0             	pushl  -0x10(%ebp)
  801bd1:	e8 2d f4 ff ff       	call   801003 <fd2data>
  801bd6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bdd:	50                   	push   %eax
  801bde:	6a 00                	push   $0x0
  801be0:	56                   	push   %esi
  801be1:	6a 00                	push   $0x0
  801be3:	e8 09 f1 ff ff       	call   800cf1 <sys_page_map>
  801be8:	89 c3                	mov    %eax,%ebx
  801bea:	83 c4 20             	add    $0x20,%esp
  801bed:	85 c0                	test   %eax,%eax
  801bef:	78 55                	js     801c46 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bf1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bff:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c06:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c0f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c14:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c1b:	83 ec 0c             	sub    $0xc,%esp
  801c1e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c21:	e8 cd f3 ff ff       	call   800ff3 <fd2num>
  801c26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c29:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c2b:	83 c4 04             	add    $0x4,%esp
  801c2e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c31:	e8 bd f3 ff ff       	call   800ff3 <fd2num>
  801c36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c39:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c44:	eb 30                	jmp    801c76 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c46:	83 ec 08             	sub    $0x8,%esp
  801c49:	56                   	push   %esi
  801c4a:	6a 00                	push   $0x0
  801c4c:	e8 e2 f0 ff ff       	call   800d33 <sys_page_unmap>
  801c51:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c54:	83 ec 08             	sub    $0x8,%esp
  801c57:	ff 75 f0             	pushl  -0x10(%ebp)
  801c5a:	6a 00                	push   $0x0
  801c5c:	e8 d2 f0 ff ff       	call   800d33 <sys_page_unmap>
  801c61:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c64:	83 ec 08             	sub    $0x8,%esp
  801c67:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6a:	6a 00                	push   $0x0
  801c6c:	e8 c2 f0 ff ff       	call   800d33 <sys_page_unmap>
  801c71:	83 c4 10             	add    $0x10,%esp
  801c74:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c76:	89 d0                	mov    %edx,%eax
  801c78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c7b:	5b                   	pop    %ebx
  801c7c:	5e                   	pop    %esi
  801c7d:	5d                   	pop    %ebp
  801c7e:	c3                   	ret    

00801c7f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
  801c82:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c88:	50                   	push   %eax
  801c89:	ff 75 08             	pushl  0x8(%ebp)
  801c8c:	e8 d8 f3 ff ff       	call   801069 <fd_lookup>
  801c91:	83 c4 10             	add    $0x10,%esp
  801c94:	85 c0                	test   %eax,%eax
  801c96:	78 18                	js     801cb0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c98:	83 ec 0c             	sub    $0xc,%esp
  801c9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9e:	e8 60 f3 ff ff       	call   801003 <fd2data>
	return _pipeisclosed(fd, p);
  801ca3:	89 c2                	mov    %eax,%edx
  801ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca8:	e8 21 fd ff ff       	call   8019ce <_pipeisclosed>
  801cad:	83 c4 10             	add    $0x10,%esp
}
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    

00801cb2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cb5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cba:	5d                   	pop    %ebp
  801cbb:	c3                   	ret    

00801cbc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cc2:	68 b8 26 80 00       	push   $0x8026b8
  801cc7:	ff 75 0c             	pushl  0xc(%ebp)
  801cca:	e8 65 eb ff ff       	call   800834 <strcpy>
	return 0;
}
  801ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd4:	c9                   	leave  
  801cd5:	c3                   	ret    

00801cd6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cd6:	55                   	push   %ebp
  801cd7:	89 e5                	mov    %esp,%ebp
  801cd9:	57                   	push   %edi
  801cda:	56                   	push   %esi
  801cdb:	53                   	push   %ebx
  801cdc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ce2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ce7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ced:	eb 2d                	jmp    801d1c <devcons_write+0x46>
		m = n - tot;
  801cef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cf2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cf4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cf7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cfc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cff:	83 ec 04             	sub    $0x4,%esp
  801d02:	53                   	push   %ebx
  801d03:	03 45 0c             	add    0xc(%ebp),%eax
  801d06:	50                   	push   %eax
  801d07:	57                   	push   %edi
  801d08:	e8 b9 ec ff ff       	call   8009c6 <memmove>
		sys_cputs(buf, m);
  801d0d:	83 c4 08             	add    $0x8,%esp
  801d10:	53                   	push   %ebx
  801d11:	57                   	push   %edi
  801d12:	e8 db ee ff ff       	call   800bf2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d17:	01 de                	add    %ebx,%esi
  801d19:	83 c4 10             	add    $0x10,%esp
  801d1c:	89 f0                	mov    %esi,%eax
  801d1e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d21:	72 cc                	jb     801cef <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d26:	5b                   	pop    %ebx
  801d27:	5e                   	pop    %esi
  801d28:	5f                   	pop    %edi
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    

00801d2b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	83 ec 08             	sub    $0x8,%esp
  801d31:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d36:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d3a:	74 2a                	je     801d66 <devcons_read+0x3b>
  801d3c:	eb 05                	jmp    801d43 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d3e:	e8 4c ef ff ff       	call   800c8f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d43:	e8 c8 ee ff ff       	call   800c10 <sys_cgetc>
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	74 f2                	je     801d3e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d4c:	85 c0                	test   %eax,%eax
  801d4e:	78 16                	js     801d66 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d50:	83 f8 04             	cmp    $0x4,%eax
  801d53:	74 0c                	je     801d61 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d55:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d58:	88 02                	mov    %al,(%edx)
	return 1;
  801d5a:	b8 01 00 00 00       	mov    $0x1,%eax
  801d5f:	eb 05                	jmp    801d66 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d61:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d66:	c9                   	leave  
  801d67:	c3                   	ret    

00801d68 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d71:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d74:	6a 01                	push   $0x1
  801d76:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d79:	50                   	push   %eax
  801d7a:	e8 73 ee ff ff       	call   800bf2 <sys_cputs>
}
  801d7f:	83 c4 10             	add    $0x10,%esp
  801d82:	c9                   	leave  
  801d83:	c3                   	ret    

00801d84 <getchar>:

int
getchar(void)
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d8a:	6a 01                	push   $0x1
  801d8c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d8f:	50                   	push   %eax
  801d90:	6a 00                	push   $0x0
  801d92:	e8 38 f5 ff ff       	call   8012cf <read>
	if (r < 0)
  801d97:	83 c4 10             	add    $0x10,%esp
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	78 0f                	js     801dad <getchar+0x29>
		return r;
	if (r < 1)
  801d9e:	85 c0                	test   %eax,%eax
  801da0:	7e 06                	jle    801da8 <getchar+0x24>
		return -E_EOF;
	return c;
  801da2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801da6:	eb 05                	jmp    801dad <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801da8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dad:	c9                   	leave  
  801dae:	c3                   	ret    

00801daf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801db5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db8:	50                   	push   %eax
  801db9:	ff 75 08             	pushl  0x8(%ebp)
  801dbc:	e8 a8 f2 ff ff       	call   801069 <fd_lookup>
  801dc1:	83 c4 10             	add    $0x10,%esp
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	78 11                	js     801dd9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dd1:	39 10                	cmp    %edx,(%eax)
  801dd3:	0f 94 c0             	sete   %al
  801dd6:	0f b6 c0             	movzbl %al,%eax
}
  801dd9:	c9                   	leave  
  801dda:	c3                   	ret    

00801ddb <opencons>:

int
opencons(void)
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801de1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de4:	50                   	push   %eax
  801de5:	e8 30 f2 ff ff       	call   80101a <fd_alloc>
  801dea:	83 c4 10             	add    $0x10,%esp
		return r;
  801ded:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801def:	85 c0                	test   %eax,%eax
  801df1:	78 3e                	js     801e31 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801df3:	83 ec 04             	sub    $0x4,%esp
  801df6:	68 07 04 00 00       	push   $0x407
  801dfb:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfe:	6a 00                	push   $0x0
  801e00:	e8 a9 ee ff ff       	call   800cae <sys_page_alloc>
  801e05:	83 c4 10             	add    $0x10,%esp
		return r;
  801e08:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	78 23                	js     801e31 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e0e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e17:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e23:	83 ec 0c             	sub    $0xc,%esp
  801e26:	50                   	push   %eax
  801e27:	e8 c7 f1 ff ff       	call   800ff3 <fd2num>
  801e2c:	89 c2                	mov    %eax,%edx
  801e2e:	83 c4 10             	add    $0x10,%esp
}
  801e31:	89 d0                	mov    %edx,%eax
  801e33:	c9                   	leave  
  801e34:	c3                   	ret    

00801e35 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
  801e38:	56                   	push   %esi
  801e39:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e3a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e3d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e43:	e8 28 ee ff ff       	call   800c70 <sys_getenvid>
  801e48:	83 ec 0c             	sub    $0xc,%esp
  801e4b:	ff 75 0c             	pushl  0xc(%ebp)
  801e4e:	ff 75 08             	pushl  0x8(%ebp)
  801e51:	56                   	push   %esi
  801e52:	50                   	push   %eax
  801e53:	68 c4 26 80 00       	push   $0x8026c4
  801e58:	e8 a3 e3 ff ff       	call   800200 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e5d:	83 c4 18             	add    $0x18,%esp
  801e60:	53                   	push   %ebx
  801e61:	ff 75 10             	pushl  0x10(%ebp)
  801e64:	e8 46 e3 ff ff       	call   8001af <vcprintf>
	cprintf("\n");
  801e69:	c7 04 24 50 22 80 00 	movl   $0x802250,(%esp)
  801e70:	e8 8b e3 ff ff       	call   800200 <cprintf>
  801e75:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e78:	cc                   	int3   
  801e79:	eb fd                	jmp    801e78 <_panic+0x43>

00801e7b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	56                   	push   %esi
  801e7f:	53                   	push   %ebx
  801e80:	8b 75 08             	mov    0x8(%ebp),%esi
  801e83:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801e89:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801e8b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e90:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801e93:	83 ec 0c             	sub    $0xc,%esp
  801e96:	50                   	push   %eax
  801e97:	e8 c2 ef ff ff       	call   800e5e <sys_ipc_recv>
  801e9c:	83 c4 10             	add    $0x10,%esp
  801e9f:	85 c0                	test   %eax,%eax
  801ea1:	79 16                	jns    801eb9 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801ea3:	85 f6                	test   %esi,%esi
  801ea5:	74 06                	je     801ead <ipc_recv+0x32>
			*from_env_store = 0;
  801ea7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801ead:	85 db                	test   %ebx,%ebx
  801eaf:	74 2c                	je     801edd <ipc_recv+0x62>
			*perm_store = 0;
  801eb1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801eb7:	eb 24                	jmp    801edd <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801eb9:	85 f6                	test   %esi,%esi
  801ebb:	74 0a                	je     801ec7 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801ebd:	a1 08 40 80 00       	mov    0x804008,%eax
  801ec2:	8b 40 74             	mov    0x74(%eax),%eax
  801ec5:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801ec7:	85 db                	test   %ebx,%ebx
  801ec9:	74 0a                	je     801ed5 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801ecb:	a1 08 40 80 00       	mov    0x804008,%eax
  801ed0:	8b 40 78             	mov    0x78(%eax),%eax
  801ed3:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801ed5:	a1 08 40 80 00       	mov    0x804008,%eax
  801eda:	8b 40 70             	mov    0x70(%eax),%eax
}
  801edd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee0:	5b                   	pop    %ebx
  801ee1:	5e                   	pop    %esi
  801ee2:	5d                   	pop    %ebp
  801ee3:	c3                   	ret    

00801ee4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
  801ee7:	57                   	push   %edi
  801ee8:	56                   	push   %esi
  801ee9:	53                   	push   %ebx
  801eea:	83 ec 0c             	sub    $0xc,%esp
  801eed:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ef0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ef3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801ef6:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801ef8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801efd:	0f 44 d8             	cmove  %eax,%ebx
  801f00:	eb 1e                	jmp    801f20 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801f02:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f05:	74 14                	je     801f1b <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801f07:	83 ec 04             	sub    $0x4,%esp
  801f0a:	68 e8 26 80 00       	push   $0x8026e8
  801f0f:	6a 44                	push   $0x44
  801f11:	68 14 27 80 00       	push   $0x802714
  801f16:	e8 1a ff ff ff       	call   801e35 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801f1b:	e8 6f ed ff ff       	call   800c8f <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801f20:	ff 75 14             	pushl  0x14(%ebp)
  801f23:	53                   	push   %ebx
  801f24:	56                   	push   %esi
  801f25:	57                   	push   %edi
  801f26:	e8 10 ef ff ff       	call   800e3b <sys_ipc_try_send>
  801f2b:	83 c4 10             	add    $0x10,%esp
  801f2e:	85 c0                	test   %eax,%eax
  801f30:	78 d0                	js     801f02 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801f32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f35:	5b                   	pop    %ebx
  801f36:	5e                   	pop    %esi
  801f37:	5f                   	pop    %edi
  801f38:	5d                   	pop    %ebp
  801f39:	c3                   	ret    

00801f3a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f40:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f45:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f48:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f4e:	8b 52 50             	mov    0x50(%edx),%edx
  801f51:	39 ca                	cmp    %ecx,%edx
  801f53:	75 0d                	jne    801f62 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f55:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f58:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f5d:	8b 40 48             	mov    0x48(%eax),%eax
  801f60:	eb 0f                	jmp    801f71 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f62:	83 c0 01             	add    $0x1,%eax
  801f65:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f6a:	75 d9                	jne    801f45 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f71:	5d                   	pop    %ebp
  801f72:	c3                   	ret    

00801f73 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f79:	89 d0                	mov    %edx,%eax
  801f7b:	c1 e8 16             	shr    $0x16,%eax
  801f7e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f85:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8a:	f6 c1 01             	test   $0x1,%cl
  801f8d:	74 1d                	je     801fac <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f8f:	c1 ea 0c             	shr    $0xc,%edx
  801f92:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f99:	f6 c2 01             	test   $0x1,%dl
  801f9c:	74 0e                	je     801fac <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f9e:	c1 ea 0c             	shr    $0xc,%edx
  801fa1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fa8:	ef 
  801fa9:	0f b7 c0             	movzwl %ax,%eax
}
  801fac:	5d                   	pop    %ebp
  801fad:	c3                   	ret    
  801fae:	66 90                	xchg   %ax,%ax

00801fb0 <__udivdi3>:
  801fb0:	55                   	push   %ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 1c             	sub    $0x1c,%esp
  801fb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fc7:	85 f6                	test   %esi,%esi
  801fc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fcd:	89 ca                	mov    %ecx,%edx
  801fcf:	89 f8                	mov    %edi,%eax
  801fd1:	75 3d                	jne    802010 <__udivdi3+0x60>
  801fd3:	39 cf                	cmp    %ecx,%edi
  801fd5:	0f 87 c5 00 00 00    	ja     8020a0 <__udivdi3+0xf0>
  801fdb:	85 ff                	test   %edi,%edi
  801fdd:	89 fd                	mov    %edi,%ebp
  801fdf:	75 0b                	jne    801fec <__udivdi3+0x3c>
  801fe1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fe6:	31 d2                	xor    %edx,%edx
  801fe8:	f7 f7                	div    %edi
  801fea:	89 c5                	mov    %eax,%ebp
  801fec:	89 c8                	mov    %ecx,%eax
  801fee:	31 d2                	xor    %edx,%edx
  801ff0:	f7 f5                	div    %ebp
  801ff2:	89 c1                	mov    %eax,%ecx
  801ff4:	89 d8                	mov    %ebx,%eax
  801ff6:	89 cf                	mov    %ecx,%edi
  801ff8:	f7 f5                	div    %ebp
  801ffa:	89 c3                	mov    %eax,%ebx
  801ffc:	89 d8                	mov    %ebx,%eax
  801ffe:	89 fa                	mov    %edi,%edx
  802000:	83 c4 1c             	add    $0x1c,%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    
  802008:	90                   	nop
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	39 ce                	cmp    %ecx,%esi
  802012:	77 74                	ja     802088 <__udivdi3+0xd8>
  802014:	0f bd fe             	bsr    %esi,%edi
  802017:	83 f7 1f             	xor    $0x1f,%edi
  80201a:	0f 84 98 00 00 00    	je     8020b8 <__udivdi3+0x108>
  802020:	bb 20 00 00 00       	mov    $0x20,%ebx
  802025:	89 f9                	mov    %edi,%ecx
  802027:	89 c5                	mov    %eax,%ebp
  802029:	29 fb                	sub    %edi,%ebx
  80202b:	d3 e6                	shl    %cl,%esi
  80202d:	89 d9                	mov    %ebx,%ecx
  80202f:	d3 ed                	shr    %cl,%ebp
  802031:	89 f9                	mov    %edi,%ecx
  802033:	d3 e0                	shl    %cl,%eax
  802035:	09 ee                	or     %ebp,%esi
  802037:	89 d9                	mov    %ebx,%ecx
  802039:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80203d:	89 d5                	mov    %edx,%ebp
  80203f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802043:	d3 ed                	shr    %cl,%ebp
  802045:	89 f9                	mov    %edi,%ecx
  802047:	d3 e2                	shl    %cl,%edx
  802049:	89 d9                	mov    %ebx,%ecx
  80204b:	d3 e8                	shr    %cl,%eax
  80204d:	09 c2                	or     %eax,%edx
  80204f:	89 d0                	mov    %edx,%eax
  802051:	89 ea                	mov    %ebp,%edx
  802053:	f7 f6                	div    %esi
  802055:	89 d5                	mov    %edx,%ebp
  802057:	89 c3                	mov    %eax,%ebx
  802059:	f7 64 24 0c          	mull   0xc(%esp)
  80205d:	39 d5                	cmp    %edx,%ebp
  80205f:	72 10                	jb     802071 <__udivdi3+0xc1>
  802061:	8b 74 24 08          	mov    0x8(%esp),%esi
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e6                	shl    %cl,%esi
  802069:	39 c6                	cmp    %eax,%esi
  80206b:	73 07                	jae    802074 <__udivdi3+0xc4>
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	75 03                	jne    802074 <__udivdi3+0xc4>
  802071:	83 eb 01             	sub    $0x1,%ebx
  802074:	31 ff                	xor    %edi,%edi
  802076:	89 d8                	mov    %ebx,%eax
  802078:	89 fa                	mov    %edi,%edx
  80207a:	83 c4 1c             	add    $0x1c,%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5e                   	pop    %esi
  80207f:	5f                   	pop    %edi
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    
  802082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802088:	31 ff                	xor    %edi,%edi
  80208a:	31 db                	xor    %ebx,%ebx
  80208c:	89 d8                	mov    %ebx,%eax
  80208e:	89 fa                	mov    %edi,%edx
  802090:	83 c4 1c             	add    $0x1c,%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5f                   	pop    %edi
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    
  802098:	90                   	nop
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 d8                	mov    %ebx,%eax
  8020a2:	f7 f7                	div    %edi
  8020a4:	31 ff                	xor    %edi,%edi
  8020a6:	89 c3                	mov    %eax,%ebx
  8020a8:	89 d8                	mov    %ebx,%eax
  8020aa:	89 fa                	mov    %edi,%edx
  8020ac:	83 c4 1c             	add    $0x1c,%esp
  8020af:	5b                   	pop    %ebx
  8020b0:	5e                   	pop    %esi
  8020b1:	5f                   	pop    %edi
  8020b2:	5d                   	pop    %ebp
  8020b3:	c3                   	ret    
  8020b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b8:	39 ce                	cmp    %ecx,%esi
  8020ba:	72 0c                	jb     8020c8 <__udivdi3+0x118>
  8020bc:	31 db                	xor    %ebx,%ebx
  8020be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020c2:	0f 87 34 ff ff ff    	ja     801ffc <__udivdi3+0x4c>
  8020c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020cd:	e9 2a ff ff ff       	jmp    801ffc <__udivdi3+0x4c>
  8020d2:	66 90                	xchg   %ax,%ax
  8020d4:	66 90                	xchg   %ax,%ax
  8020d6:	66 90                	xchg   %ax,%ax
  8020d8:	66 90                	xchg   %ax,%ax
  8020da:	66 90                	xchg   %ax,%ax
  8020dc:	66 90                	xchg   %ax,%ax
  8020de:	66 90                	xchg   %ax,%ax

008020e0 <__umoddi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020f7:	85 d2                	test   %edx,%edx
  8020f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802101:	89 f3                	mov    %esi,%ebx
  802103:	89 3c 24             	mov    %edi,(%esp)
  802106:	89 74 24 04          	mov    %esi,0x4(%esp)
  80210a:	75 1c                	jne    802128 <__umoddi3+0x48>
  80210c:	39 f7                	cmp    %esi,%edi
  80210e:	76 50                	jbe    802160 <__umoddi3+0x80>
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 f2                	mov    %esi,%edx
  802114:	f7 f7                	div    %edi
  802116:	89 d0                	mov    %edx,%eax
  802118:	31 d2                	xor    %edx,%edx
  80211a:	83 c4 1c             	add    $0x1c,%esp
  80211d:	5b                   	pop    %ebx
  80211e:	5e                   	pop    %esi
  80211f:	5f                   	pop    %edi
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    
  802122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802128:	39 f2                	cmp    %esi,%edx
  80212a:	89 d0                	mov    %edx,%eax
  80212c:	77 52                	ja     802180 <__umoddi3+0xa0>
  80212e:	0f bd ea             	bsr    %edx,%ebp
  802131:	83 f5 1f             	xor    $0x1f,%ebp
  802134:	75 5a                	jne    802190 <__umoddi3+0xb0>
  802136:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80213a:	0f 82 e0 00 00 00    	jb     802220 <__umoddi3+0x140>
  802140:	39 0c 24             	cmp    %ecx,(%esp)
  802143:	0f 86 d7 00 00 00    	jbe    802220 <__umoddi3+0x140>
  802149:	8b 44 24 08          	mov    0x8(%esp),%eax
  80214d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802151:	83 c4 1c             	add    $0x1c,%esp
  802154:	5b                   	pop    %ebx
  802155:	5e                   	pop    %esi
  802156:	5f                   	pop    %edi
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	85 ff                	test   %edi,%edi
  802162:	89 fd                	mov    %edi,%ebp
  802164:	75 0b                	jne    802171 <__umoddi3+0x91>
  802166:	b8 01 00 00 00       	mov    $0x1,%eax
  80216b:	31 d2                	xor    %edx,%edx
  80216d:	f7 f7                	div    %edi
  80216f:	89 c5                	mov    %eax,%ebp
  802171:	89 f0                	mov    %esi,%eax
  802173:	31 d2                	xor    %edx,%edx
  802175:	f7 f5                	div    %ebp
  802177:	89 c8                	mov    %ecx,%eax
  802179:	f7 f5                	div    %ebp
  80217b:	89 d0                	mov    %edx,%eax
  80217d:	eb 99                	jmp    802118 <__umoddi3+0x38>
  80217f:	90                   	nop
  802180:	89 c8                	mov    %ecx,%eax
  802182:	89 f2                	mov    %esi,%edx
  802184:	83 c4 1c             	add    $0x1c,%esp
  802187:	5b                   	pop    %ebx
  802188:	5e                   	pop    %esi
  802189:	5f                   	pop    %edi
  80218a:	5d                   	pop    %ebp
  80218b:	c3                   	ret    
  80218c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802190:	8b 34 24             	mov    (%esp),%esi
  802193:	bf 20 00 00 00       	mov    $0x20,%edi
  802198:	89 e9                	mov    %ebp,%ecx
  80219a:	29 ef                	sub    %ebp,%edi
  80219c:	d3 e0                	shl    %cl,%eax
  80219e:	89 f9                	mov    %edi,%ecx
  8021a0:	89 f2                	mov    %esi,%edx
  8021a2:	d3 ea                	shr    %cl,%edx
  8021a4:	89 e9                	mov    %ebp,%ecx
  8021a6:	09 c2                	or     %eax,%edx
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	89 14 24             	mov    %edx,(%esp)
  8021ad:	89 f2                	mov    %esi,%edx
  8021af:	d3 e2                	shl    %cl,%edx
  8021b1:	89 f9                	mov    %edi,%ecx
  8021b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	89 e9                	mov    %ebp,%ecx
  8021bf:	89 c6                	mov    %eax,%esi
  8021c1:	d3 e3                	shl    %cl,%ebx
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	89 d0                	mov    %edx,%eax
  8021c7:	d3 e8                	shr    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	09 d8                	or     %ebx,%eax
  8021cd:	89 d3                	mov    %edx,%ebx
  8021cf:	89 f2                	mov    %esi,%edx
  8021d1:	f7 34 24             	divl   (%esp)
  8021d4:	89 d6                	mov    %edx,%esi
  8021d6:	d3 e3                	shl    %cl,%ebx
  8021d8:	f7 64 24 04          	mull   0x4(%esp)
  8021dc:	39 d6                	cmp    %edx,%esi
  8021de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021e2:	89 d1                	mov    %edx,%ecx
  8021e4:	89 c3                	mov    %eax,%ebx
  8021e6:	72 08                	jb     8021f0 <__umoddi3+0x110>
  8021e8:	75 11                	jne    8021fb <__umoddi3+0x11b>
  8021ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ee:	73 0b                	jae    8021fb <__umoddi3+0x11b>
  8021f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021f4:	1b 14 24             	sbb    (%esp),%edx
  8021f7:	89 d1                	mov    %edx,%ecx
  8021f9:	89 c3                	mov    %eax,%ebx
  8021fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021ff:	29 da                	sub    %ebx,%edx
  802201:	19 ce                	sbb    %ecx,%esi
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 f0                	mov    %esi,%eax
  802207:	d3 e0                	shl    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	d3 ea                	shr    %cl,%edx
  80220d:	89 e9                	mov    %ebp,%ecx
  80220f:	d3 ee                	shr    %cl,%esi
  802211:	09 d0                	or     %edx,%eax
  802213:	89 f2                	mov    %esi,%edx
  802215:	83 c4 1c             	add    $0x1c,%esp
  802218:	5b                   	pop    %ebx
  802219:	5e                   	pop    %esi
  80221a:	5f                   	pop    %edi
  80221b:	5d                   	pop    %ebp
  80221c:	c3                   	ret    
  80221d:	8d 76 00             	lea    0x0(%esi),%esi
  802220:	29 f9                	sub    %edi,%ecx
  802222:	19 d6                	sbb    %edx,%esi
  802224:	89 74 24 04          	mov    %esi,0x4(%esp)
  802228:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80222c:	e9 18 ff ff ff       	jmp    802149 <__umoddi3+0x69>
