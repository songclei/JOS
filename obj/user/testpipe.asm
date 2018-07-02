
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 81 02 00 00       	call   8002b2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 80 	movl   $0x802580,0x803004
  800042:	25 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 6d 1d 00 00       	call   801dbb <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 8c 25 80 00       	push   $0x80258c
  80005d:	6a 0e                	push   $0xe
  80005f:	68 95 25 80 00       	push   $0x802595
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 f2 10 00 00       	call   801160 <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 7e 2a 80 00       	push   $0x802a7e
  80007a:	6a 11                	push   $0x11
  80007c:	68 95 25 80 00       	push   $0x802595
  800081:	e8 8c 02 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 08 40 80 00       	mov    0x804008,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 a5 25 80 00       	push   $0x8025a5
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 80 14 00 00       	call   801532 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 c2 25 80 00       	push   $0x8025c2
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 23 16 00 00       	call   8016ff <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 df 25 80 00       	push   $0x8025df
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 95 25 80 00       	push   $0x802595
  8000f2:	e8 1b 02 00 00       	call   800312 <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 bb 09 00 00       	call   800ac9 <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 e8 25 80 00       	push   $0x8025e8
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 04 26 80 00       	push   $0x802604
  800134:	e8 b2 02 00 00       	call   8003eb <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 b7 01 00 00       	call   8002f8 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 08 40 80 00       	mov    0x804008,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 a5 25 80 00       	push   $0x8025a5
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 c8 13 00 00       	call   801532 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 08 40 80 00       	mov    0x804008,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 17 26 80 00       	push   $0x802617
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 55 08 00 00       	call   8009e6 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 a5 15 00 00       	call   801748 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 33 08 00 00       	call   8009e6 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 34 26 80 00       	push   $0x802634
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 95 25 80 00       	push   $0x802595
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 5b 13 00 00       	call   801532 <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 5e 1d 00 00       	call   801f41 <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 3e 	movl   $0x80263e,0x803004
  8001ea:	26 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 c3 1b 00 00       	call   801dbb <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 8c 25 80 00       	push   $0x80258c
  800207:	6a 2c                	push   $0x2c
  800209:	68 95 25 80 00       	push   $0x802595
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 48 0f 00 00       	call   801160 <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 7e 2a 80 00       	push   $0x802a7e
  800224:	6a 2f                	push   $0x2f
  800226:	68 95 25 80 00       	push   $0x802595
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 f3 12 00 00       	call   801532 <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 4b 26 80 00       	push   $0x80264b
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 4d 26 80 00       	push   $0x80264d
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 e7 14 00 00       	call   801748 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 4f 26 80 00       	push   $0x80264f
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 a9 12 00 00       	call   801532 <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 9e 12 00 00       	call   801532 <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 a5 1c 00 00       	call   801f41 <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 6c 26 80 00 	movl   $0x80266c,(%esp)
  8002a3:	e8 43 01 00 00       	call   8003eb <cprintf>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002bd:	e8 99 0b 00 00       	call   800e5b <sys_getenvid>
  8002c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002cf:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7e 07                	jle    8002df <libmain+0x2d>
		binaryname = argv[0];
  8002d8:	8b 06                	mov    (%esi),%eax
  8002da:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	e8 4a fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002e9:	e8 0a 00 00 00       	call   8002f8 <exit>
}
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002fe:	e8 5a 12 00 00       	call   80155d <close_all>
	sys_env_destroy(0);
  800303:	83 ec 0c             	sub    $0xc,%esp
  800306:	6a 00                	push   $0x0
  800308:	e8 0d 0b 00 00       	call   800e1a <sys_env_destroy>
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031a:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800320:	e8 36 0b 00 00       	call   800e5b <sys_getenvid>
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	56                   	push   %esi
  80032f:	50                   	push   %eax
  800330:	68 d0 26 80 00       	push   $0x8026d0
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  80034d:	e8 99 00 00 00       	call   8003eb <cprintf>
  800352:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800355:	cc                   	int3   
  800356:	eb fd                	jmp    800355 <_panic+0x43>

00800358 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	83 ec 04             	sub    $0x4,%esp
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800362:	8b 13                	mov    (%ebx),%edx
  800364:	8d 42 01             	lea    0x1(%edx),%eax
  800367:	89 03                	mov    %eax,(%ebx)
  800369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800370:	3d ff 00 00 00       	cmp    $0xff,%eax
  800375:	75 1a                	jne    800391 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	68 ff 00 00 00       	push   $0xff
  80037f:	8d 43 08             	lea    0x8(%ebx),%eax
  800382:	50                   	push   %eax
  800383:	e8 55 0a 00 00       	call   800ddd <sys_cputs>
		b->idx = 0;
  800388:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800391:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800395:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003aa:	00 00 00 
	b.cnt = 0;
  8003ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c3:	50                   	push   %eax
  8003c4:	68 58 03 80 00       	push   $0x800358
  8003c9:	e8 54 01 00 00       	call   800522 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ce:	83 c4 08             	add    $0x8,%esp
  8003d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	e8 fa 09 00 00       	call   800ddd <sys_cputs>

	return b.cnt;
}
  8003e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f4:	50                   	push   %eax
  8003f5:	ff 75 08             	pushl  0x8(%ebp)
  8003f8:	e8 9d ff ff ff       	call   80039a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	57                   	push   %edi
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
  800405:	83 ec 1c             	sub    $0x1c,%esp
  800408:	89 c7                	mov    %eax,%edi
  80040a:	89 d6                	mov    %edx,%esi
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800412:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800415:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800418:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800420:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800423:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800426:	39 d3                	cmp    %edx,%ebx
  800428:	72 05                	jb     80042f <printnum+0x30>
  80042a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042d:	77 45                	ja     800474 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042f:	83 ec 0c             	sub    $0xc,%esp
  800432:	ff 75 18             	pushl  0x18(%ebp)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043b:	53                   	push   %ebx
  80043c:	ff 75 10             	pushl  0x10(%ebp)
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	ff 75 e4             	pushl  -0x1c(%ebp)
  800445:	ff 75 e0             	pushl  -0x20(%ebp)
  800448:	ff 75 dc             	pushl  -0x24(%ebp)
  80044b:	ff 75 d8             	pushl  -0x28(%ebp)
  80044e:	e8 8d 1e 00 00       	call   8022e0 <__udivdi3>
  800453:	83 c4 18             	add    $0x18,%esp
  800456:	52                   	push   %edx
  800457:	50                   	push   %eax
  800458:	89 f2                	mov    %esi,%edx
  80045a:	89 f8                	mov    %edi,%eax
  80045c:	e8 9e ff ff ff       	call   8003ff <printnum>
  800461:	83 c4 20             	add    $0x20,%esp
  800464:	eb 18                	jmp    80047e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	ff 75 18             	pushl  0x18(%ebp)
  80046d:	ff d7                	call   *%edi
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	eb 03                	jmp    800477 <printnum+0x78>
  800474:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800477:	83 eb 01             	sub    $0x1,%ebx
  80047a:	85 db                	test   %ebx,%ebx
  80047c:	7f e8                	jg     800466 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	56                   	push   %esi
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	ff 75 e4             	pushl  -0x1c(%ebp)
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff 75 dc             	pushl  -0x24(%ebp)
  80048e:	ff 75 d8             	pushl  -0x28(%ebp)
  800491:	e8 7a 1f 00 00       	call   802410 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 f3 26 80 00 	movsbl 0x8026f3(%eax),%eax
  8004a0:	50                   	push   %eax
  8004a1:	ff d7                	call   *%edi
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a9:	5b                   	pop    %ebx
  8004aa:	5e                   	pop    %esi
  8004ab:	5f                   	pop    %edi
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    

008004ae <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004b1:	83 fa 01             	cmp    $0x1,%edx
  8004b4:	7e 0e                	jle    8004c4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b6:	8b 10                	mov    (%eax),%edx
  8004b8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004bb:	89 08                	mov    %ecx,(%eax)
  8004bd:	8b 02                	mov    (%edx),%eax
  8004bf:	8b 52 04             	mov    0x4(%edx),%edx
  8004c2:	eb 22                	jmp    8004e6 <getuint+0x38>
	else if (lflag)
  8004c4:	85 d2                	test   %edx,%edx
  8004c6:	74 10                	je     8004d8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d6:	eb 0e                	jmp    8004e6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d8:	8b 10                	mov    (%eax),%edx
  8004da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004dd:	89 08                	mov    %ecx,(%eax)
  8004df:	8b 02                	mov    (%edx),%eax
  8004e1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e6:	5d                   	pop    %ebp
  8004e7:	c3                   	ret    

008004e8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ee:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f2:	8b 10                	mov    (%eax),%edx
  8004f4:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f7:	73 0a                	jae    800503 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fc:	89 08                	mov    %ecx,(%eax)
  8004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800501:	88 02                	mov    %al,(%edx)
}
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    

00800505 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050e:	50                   	push   %eax
  80050f:	ff 75 10             	pushl  0x10(%ebp)
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	ff 75 08             	pushl  0x8(%ebp)
  800518:	e8 05 00 00 00       	call   800522 <vprintfmt>
	va_end(ap);
}
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	57                   	push   %edi
  800526:	56                   	push   %esi
  800527:	53                   	push   %ebx
  800528:	83 ec 2c             	sub    $0x2c,%esp
  80052b:	8b 75 08             	mov    0x8(%ebp),%esi
  80052e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800531:	8b 7d 10             	mov    0x10(%ebp),%edi
  800534:	eb 12                	jmp    800548 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800536:	85 c0                	test   %eax,%eax
  800538:	0f 84 38 04 00 00    	je     800976 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	53                   	push   %ebx
  800542:	50                   	push   %eax
  800543:	ff d6                	call   *%esi
  800545:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800548:	83 c7 01             	add    $0x1,%edi
  80054b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054f:	83 f8 25             	cmp    $0x25,%eax
  800552:	75 e2                	jne    800536 <vprintfmt+0x14>
  800554:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800558:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80055f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800566:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80056d:	ba 00 00 00 00       	mov    $0x0,%edx
  800572:	eb 07                	jmp    80057b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800574:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  800577:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8d 47 01             	lea    0x1(%edi),%eax
  80057e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800581:	0f b6 07             	movzbl (%edi),%eax
  800584:	0f b6 c8             	movzbl %al,%ecx
  800587:	83 e8 23             	sub    $0x23,%eax
  80058a:	3c 55                	cmp    $0x55,%al
  80058c:	0f 87 c9 03 00 00    	ja     80095b <vprintfmt+0x439>
  800592:	0f b6 c0             	movzbl %al,%eax
  800595:	ff 24 85 40 28 80 00 	jmp    *0x802840(,%eax,4)
  80059c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80059f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005a3:	eb d6                	jmp    80057b <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  8005a5:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  8005ac:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  8005b2:	eb 94                	jmp    800548 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  8005b4:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  8005bb:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  8005c1:	eb 85                	jmp    800548 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  8005c3:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  8005ca:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  8005d0:	e9 73 ff ff ff       	jmp    800548 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  8005d5:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  8005dc:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  8005e2:	e9 61 ff ff ff       	jmp    800548 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  8005e7:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  8005ee:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  8005f4:	e9 4f ff ff ff       	jmp    800548 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  8005f9:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800600:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800603:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  800606:	e9 3d ff ff ff       	jmp    800548 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  80060b:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  800612:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800615:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  800618:	e9 2b ff ff ff       	jmp    800548 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  80061d:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  800624:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800627:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  80062a:	e9 19 ff ff ff       	jmp    800548 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  80062f:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  800636:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800639:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  80063c:	e9 07 ff ff ff       	jmp    800548 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  800641:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  800648:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  80064e:	e9 f5 fe ff ff       	jmp    800548 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800653:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800656:	b8 00 00 00 00       	mov    $0x0,%eax
  80065b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80065e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800661:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800665:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800668:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80066b:	83 fa 09             	cmp    $0x9,%edx
  80066e:	77 3f                	ja     8006af <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800670:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800673:	eb e9                	jmp    80065e <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8d 48 04             	lea    0x4(%eax),%ecx
  80067b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80067e:	8b 00                	mov    (%eax),%eax
  800680:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800683:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800686:	eb 2d                	jmp    8006b5 <vprintfmt+0x193>
  800688:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80068b:	85 c0                	test   %eax,%eax
  80068d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800692:	0f 49 c8             	cmovns %eax,%ecx
  800695:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800698:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069b:	e9 db fe ff ff       	jmp    80057b <vprintfmt+0x59>
  8006a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006a3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006aa:	e9 cc fe ff ff       	jmp    80057b <vprintfmt+0x59>
  8006af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006b2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b9:	0f 89 bc fe ff ff    	jns    80057b <vprintfmt+0x59>
				width = precision, precision = -1;
  8006bf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006c5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006cc:	e9 aa fe ff ff       	jmp    80057b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006d1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006d7:	e9 9f fe ff ff       	jmp    80057b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8d 50 04             	lea    0x4(%eax),%edx
  8006e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	53                   	push   %ebx
  8006e9:	ff 30                	pushl  (%eax)
  8006eb:	ff d6                	call   *%esi
			break;
  8006ed:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006f3:	e9 50 fe ff ff       	jmp    800548 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 50 04             	lea    0x4(%eax),%edx
  8006fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800701:	8b 00                	mov    (%eax),%eax
  800703:	99                   	cltd   
  800704:	31 d0                	xor    %edx,%eax
  800706:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800708:	83 f8 0f             	cmp    $0xf,%eax
  80070b:	7f 0b                	jg     800718 <vprintfmt+0x1f6>
  80070d:	8b 14 85 a0 29 80 00 	mov    0x8029a0(,%eax,4),%edx
  800714:	85 d2                	test   %edx,%edx
  800716:	75 18                	jne    800730 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  800718:	50                   	push   %eax
  800719:	68 0b 27 80 00       	push   $0x80270b
  80071e:	53                   	push   %ebx
  80071f:	56                   	push   %esi
  800720:	e8 e0 fd ff ff       	call   800505 <printfmt>
  800725:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800728:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80072b:	e9 18 fe ff ff       	jmp    800548 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800730:	52                   	push   %edx
  800731:	68 85 2b 80 00       	push   $0x802b85
  800736:	53                   	push   %ebx
  800737:	56                   	push   %esi
  800738:	e8 c8 fd ff ff       	call   800505 <printfmt>
  80073d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800740:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800743:	e9 00 fe ff ff       	jmp    800548 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8d 50 04             	lea    0x4(%eax),%edx
  80074e:	89 55 14             	mov    %edx,0x14(%ebp)
  800751:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800753:	85 ff                	test   %edi,%edi
  800755:	b8 04 27 80 00       	mov    $0x802704,%eax
  80075a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80075d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800761:	0f 8e 94 00 00 00    	jle    8007fb <vprintfmt+0x2d9>
  800767:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80076b:	0f 84 98 00 00 00    	je     800809 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  800771:	83 ec 08             	sub    $0x8,%esp
  800774:	ff 75 d0             	pushl  -0x30(%ebp)
  800777:	57                   	push   %edi
  800778:	e8 81 02 00 00       	call   8009fe <strnlen>
  80077d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800780:	29 c1                	sub    %eax,%ecx
  800782:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800785:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800788:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80078c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80078f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800792:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800794:	eb 0f                	jmp    8007a5 <vprintfmt+0x283>
					putch(padc, putdat);
  800796:	83 ec 08             	sub    $0x8,%esp
  800799:	53                   	push   %ebx
  80079a:	ff 75 e0             	pushl  -0x20(%ebp)
  80079d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80079f:	83 ef 01             	sub    $0x1,%edi
  8007a2:	83 c4 10             	add    $0x10,%esp
  8007a5:	85 ff                	test   %edi,%edi
  8007a7:	7f ed                	jg     800796 <vprintfmt+0x274>
  8007a9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007ac:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007af:	85 c9                	test   %ecx,%ecx
  8007b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b6:	0f 49 c1             	cmovns %ecx,%eax
  8007b9:	29 c1                	sub    %eax,%ecx
  8007bb:	89 75 08             	mov    %esi,0x8(%ebp)
  8007be:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007c4:	89 cb                	mov    %ecx,%ebx
  8007c6:	eb 4d                	jmp    800815 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007c8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007cc:	74 1b                	je     8007e9 <vprintfmt+0x2c7>
  8007ce:	0f be c0             	movsbl %al,%eax
  8007d1:	83 e8 20             	sub    $0x20,%eax
  8007d4:	83 f8 5e             	cmp    $0x5e,%eax
  8007d7:	76 10                	jbe    8007e9 <vprintfmt+0x2c7>
					putch('?', putdat);
  8007d9:	83 ec 08             	sub    $0x8,%esp
  8007dc:	ff 75 0c             	pushl  0xc(%ebp)
  8007df:	6a 3f                	push   $0x3f
  8007e1:	ff 55 08             	call   *0x8(%ebp)
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	eb 0d                	jmp    8007f6 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  8007e9:	83 ec 08             	sub    $0x8,%esp
  8007ec:	ff 75 0c             	pushl  0xc(%ebp)
  8007ef:	52                   	push   %edx
  8007f0:	ff 55 08             	call   *0x8(%ebp)
  8007f3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f6:	83 eb 01             	sub    $0x1,%ebx
  8007f9:	eb 1a                	jmp    800815 <vprintfmt+0x2f3>
  8007fb:	89 75 08             	mov    %esi,0x8(%ebp)
  8007fe:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800801:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800804:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800807:	eb 0c                	jmp    800815 <vprintfmt+0x2f3>
  800809:	89 75 08             	mov    %esi,0x8(%ebp)
  80080c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80080f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800812:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800815:	83 c7 01             	add    $0x1,%edi
  800818:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80081c:	0f be d0             	movsbl %al,%edx
  80081f:	85 d2                	test   %edx,%edx
  800821:	74 23                	je     800846 <vprintfmt+0x324>
  800823:	85 f6                	test   %esi,%esi
  800825:	78 a1                	js     8007c8 <vprintfmt+0x2a6>
  800827:	83 ee 01             	sub    $0x1,%esi
  80082a:	79 9c                	jns    8007c8 <vprintfmt+0x2a6>
  80082c:	89 df                	mov    %ebx,%edi
  80082e:	8b 75 08             	mov    0x8(%ebp),%esi
  800831:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800834:	eb 18                	jmp    80084e <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800836:	83 ec 08             	sub    $0x8,%esp
  800839:	53                   	push   %ebx
  80083a:	6a 20                	push   $0x20
  80083c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80083e:	83 ef 01             	sub    $0x1,%edi
  800841:	83 c4 10             	add    $0x10,%esp
  800844:	eb 08                	jmp    80084e <vprintfmt+0x32c>
  800846:	89 df                	mov    %ebx,%edi
  800848:	8b 75 08             	mov    0x8(%ebp),%esi
  80084b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80084e:	85 ff                	test   %edi,%edi
  800850:	7f e4                	jg     800836 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800852:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800855:	e9 ee fc ff ff       	jmp    800548 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80085a:	83 fa 01             	cmp    $0x1,%edx
  80085d:	7e 16                	jle    800875 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  80085f:	8b 45 14             	mov    0x14(%ebp),%eax
  800862:	8d 50 08             	lea    0x8(%eax),%edx
  800865:	89 55 14             	mov    %edx,0x14(%ebp)
  800868:	8b 50 04             	mov    0x4(%eax),%edx
  80086b:	8b 00                	mov    (%eax),%eax
  80086d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800870:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800873:	eb 32                	jmp    8008a7 <vprintfmt+0x385>
	else if (lflag)
  800875:	85 d2                	test   %edx,%edx
  800877:	74 18                	je     800891 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  800879:	8b 45 14             	mov    0x14(%ebp),%eax
  80087c:	8d 50 04             	lea    0x4(%eax),%edx
  80087f:	89 55 14             	mov    %edx,0x14(%ebp)
  800882:	8b 00                	mov    (%eax),%eax
  800884:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800887:	89 c1                	mov    %eax,%ecx
  800889:	c1 f9 1f             	sar    $0x1f,%ecx
  80088c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80088f:	eb 16                	jmp    8008a7 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  800891:	8b 45 14             	mov    0x14(%ebp),%eax
  800894:	8d 50 04             	lea    0x4(%eax),%edx
  800897:	89 55 14             	mov    %edx,0x14(%ebp)
  80089a:	8b 00                	mov    (%eax),%eax
  80089c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80089f:	89 c1                	mov    %eax,%ecx
  8008a1:	c1 f9 1f             	sar    $0x1f,%ecx
  8008a4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008a7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008aa:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008ad:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008b2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008b6:	79 6f                	jns    800927 <vprintfmt+0x405>
				putch('-', putdat);
  8008b8:	83 ec 08             	sub    $0x8,%esp
  8008bb:	53                   	push   %ebx
  8008bc:	6a 2d                	push   $0x2d
  8008be:	ff d6                	call   *%esi
				num = -(long long) num;
  8008c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008c6:	f7 d8                	neg    %eax
  8008c8:	83 d2 00             	adc    $0x0,%edx
  8008cb:	f7 da                	neg    %edx
  8008cd:	83 c4 10             	add    $0x10,%esp
  8008d0:	eb 55                	jmp    800927 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d5:	e8 d4 fb ff ff       	call   8004ae <getuint>
			base = 10;
  8008da:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8008df:	eb 46                	jmp    800927 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8008e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e4:	e8 c5 fb ff ff       	call   8004ae <getuint>
			base = 8;
  8008e9:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8008ee:	eb 37                	jmp    800927 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  8008f0:	83 ec 08             	sub    $0x8,%esp
  8008f3:	53                   	push   %ebx
  8008f4:	6a 30                	push   $0x30
  8008f6:	ff d6                	call   *%esi
			putch('x', putdat);
  8008f8:	83 c4 08             	add    $0x8,%esp
  8008fb:	53                   	push   %ebx
  8008fc:	6a 78                	push   $0x78
  8008fe:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800900:	8b 45 14             	mov    0x14(%ebp),%eax
  800903:	8d 50 04             	lea    0x4(%eax),%edx
  800906:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800909:	8b 00                	mov    (%eax),%eax
  80090b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800910:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800913:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800918:	eb 0d                	jmp    800927 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80091a:	8d 45 14             	lea    0x14(%ebp),%eax
  80091d:	e8 8c fb ff ff       	call   8004ae <getuint>
			base = 16;
  800922:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800927:	83 ec 0c             	sub    $0xc,%esp
  80092a:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  80092e:	51                   	push   %ecx
  80092f:	ff 75 e0             	pushl  -0x20(%ebp)
  800932:	57                   	push   %edi
  800933:	52                   	push   %edx
  800934:	50                   	push   %eax
  800935:	89 da                	mov    %ebx,%edx
  800937:	89 f0                	mov    %esi,%eax
  800939:	e8 c1 fa ff ff       	call   8003ff <printnum>
			break;
  80093e:	83 c4 20             	add    $0x20,%esp
  800941:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800944:	e9 ff fb ff ff       	jmp    800548 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800949:	83 ec 08             	sub    $0x8,%esp
  80094c:	53                   	push   %ebx
  80094d:	51                   	push   %ecx
  80094e:	ff d6                	call   *%esi
			break;
  800950:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800953:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800956:	e9 ed fb ff ff       	jmp    800548 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80095b:	83 ec 08             	sub    $0x8,%esp
  80095e:	53                   	push   %ebx
  80095f:	6a 25                	push   $0x25
  800961:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800963:	83 c4 10             	add    $0x10,%esp
  800966:	eb 03                	jmp    80096b <vprintfmt+0x449>
  800968:	83 ef 01             	sub    $0x1,%edi
  80096b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80096f:	75 f7                	jne    800968 <vprintfmt+0x446>
  800971:	e9 d2 fb ff ff       	jmp    800548 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800976:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800979:	5b                   	pop    %ebx
  80097a:	5e                   	pop    %esi
  80097b:	5f                   	pop    %edi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	83 ec 18             	sub    $0x18,%esp
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80098a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80098d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800991:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800994:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80099b:	85 c0                	test   %eax,%eax
  80099d:	74 26                	je     8009c5 <vsnprintf+0x47>
  80099f:	85 d2                	test   %edx,%edx
  8009a1:	7e 22                	jle    8009c5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009a3:	ff 75 14             	pushl  0x14(%ebp)
  8009a6:	ff 75 10             	pushl  0x10(%ebp)
  8009a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ac:	50                   	push   %eax
  8009ad:	68 e8 04 80 00       	push   $0x8004e8
  8009b2:	e8 6b fb ff ff       	call   800522 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009ba:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c0:	83 c4 10             	add    $0x10,%esp
  8009c3:	eb 05                	jmp    8009ca <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009ca:	c9                   	leave  
  8009cb:	c3                   	ret    

008009cc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009d2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009d5:	50                   	push   %eax
  8009d6:	ff 75 10             	pushl  0x10(%ebp)
  8009d9:	ff 75 0c             	pushl  0xc(%ebp)
  8009dc:	ff 75 08             	pushl  0x8(%ebp)
  8009df:	e8 9a ff ff ff       	call   80097e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009e4:	c9                   	leave  
  8009e5:	c3                   	ret    

008009e6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f1:	eb 03                	jmp    8009f6 <strlen+0x10>
		n++;
  8009f3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009fa:	75 f7                	jne    8009f3 <strlen+0xd>
		n++;
	return n;
}
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a04:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a07:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0c:	eb 03                	jmp    800a11 <strnlen+0x13>
		n++;
  800a0e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a11:	39 c2                	cmp    %eax,%edx
  800a13:	74 08                	je     800a1d <strnlen+0x1f>
  800a15:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a19:	75 f3                	jne    800a0e <strnlen+0x10>
  800a1b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	53                   	push   %ebx
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a29:	89 c2                	mov    %eax,%edx
  800a2b:	83 c2 01             	add    $0x1,%edx
  800a2e:	83 c1 01             	add    $0x1,%ecx
  800a31:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a35:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a38:	84 db                	test   %bl,%bl
  800a3a:	75 ef                	jne    800a2b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a3c:	5b                   	pop    %ebx
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	53                   	push   %ebx
  800a43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a46:	53                   	push   %ebx
  800a47:	e8 9a ff ff ff       	call   8009e6 <strlen>
  800a4c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a4f:	ff 75 0c             	pushl  0xc(%ebp)
  800a52:	01 d8                	add    %ebx,%eax
  800a54:	50                   	push   %eax
  800a55:	e8 c5 ff ff ff       	call   800a1f <strcpy>
	return dst;
}
  800a5a:	89 d8                	mov    %ebx,%eax
  800a5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a5f:	c9                   	leave  
  800a60:	c3                   	ret    

00800a61 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
  800a66:	8b 75 08             	mov    0x8(%ebp),%esi
  800a69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6c:	89 f3                	mov    %esi,%ebx
  800a6e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a71:	89 f2                	mov    %esi,%edx
  800a73:	eb 0f                	jmp    800a84 <strncpy+0x23>
		*dst++ = *src;
  800a75:	83 c2 01             	add    $0x1,%edx
  800a78:	0f b6 01             	movzbl (%ecx),%eax
  800a7b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a7e:	80 39 01             	cmpb   $0x1,(%ecx)
  800a81:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a84:	39 da                	cmp    %ebx,%edx
  800a86:	75 ed                	jne    800a75 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a88:	89 f0                	mov    %esi,%eax
  800a8a:	5b                   	pop    %ebx
  800a8b:	5e                   	pop    %esi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
  800a93:	8b 75 08             	mov    0x8(%ebp),%esi
  800a96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a99:	8b 55 10             	mov    0x10(%ebp),%edx
  800a9c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a9e:	85 d2                	test   %edx,%edx
  800aa0:	74 21                	je     800ac3 <strlcpy+0x35>
  800aa2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800aa6:	89 f2                	mov    %esi,%edx
  800aa8:	eb 09                	jmp    800ab3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aaa:	83 c2 01             	add    $0x1,%edx
  800aad:	83 c1 01             	add    $0x1,%ecx
  800ab0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ab3:	39 c2                	cmp    %eax,%edx
  800ab5:	74 09                	je     800ac0 <strlcpy+0x32>
  800ab7:	0f b6 19             	movzbl (%ecx),%ebx
  800aba:	84 db                	test   %bl,%bl
  800abc:	75 ec                	jne    800aaa <strlcpy+0x1c>
  800abe:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ac0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ac3:	29 f0                	sub    %esi,%eax
}
  800ac5:	5b                   	pop    %ebx
  800ac6:	5e                   	pop    %esi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ad2:	eb 06                	jmp    800ada <strcmp+0x11>
		p++, q++;
  800ad4:	83 c1 01             	add    $0x1,%ecx
  800ad7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ada:	0f b6 01             	movzbl (%ecx),%eax
  800add:	84 c0                	test   %al,%al
  800adf:	74 04                	je     800ae5 <strcmp+0x1c>
  800ae1:	3a 02                	cmp    (%edx),%al
  800ae3:	74 ef                	je     800ad4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae5:	0f b6 c0             	movzbl %al,%eax
  800ae8:	0f b6 12             	movzbl (%edx),%edx
  800aeb:	29 d0                	sub    %edx,%eax
}
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	53                   	push   %ebx
  800af3:	8b 45 08             	mov    0x8(%ebp),%eax
  800af6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af9:	89 c3                	mov    %eax,%ebx
  800afb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800afe:	eb 06                	jmp    800b06 <strncmp+0x17>
		n--, p++, q++;
  800b00:	83 c0 01             	add    $0x1,%eax
  800b03:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b06:	39 d8                	cmp    %ebx,%eax
  800b08:	74 15                	je     800b1f <strncmp+0x30>
  800b0a:	0f b6 08             	movzbl (%eax),%ecx
  800b0d:	84 c9                	test   %cl,%cl
  800b0f:	74 04                	je     800b15 <strncmp+0x26>
  800b11:	3a 0a                	cmp    (%edx),%cl
  800b13:	74 eb                	je     800b00 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b15:	0f b6 00             	movzbl (%eax),%eax
  800b18:	0f b6 12             	movzbl (%edx),%edx
  800b1b:	29 d0                	sub    %edx,%eax
  800b1d:	eb 05                	jmp    800b24 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b1f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b24:	5b                   	pop    %ebx
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b31:	eb 07                	jmp    800b3a <strchr+0x13>
		if (*s == c)
  800b33:	38 ca                	cmp    %cl,%dl
  800b35:	74 0f                	je     800b46 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b37:	83 c0 01             	add    $0x1,%eax
  800b3a:	0f b6 10             	movzbl (%eax),%edx
  800b3d:	84 d2                	test   %dl,%dl
  800b3f:	75 f2                	jne    800b33 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b52:	eb 03                	jmp    800b57 <strfind+0xf>
  800b54:	83 c0 01             	add    $0x1,%eax
  800b57:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b5a:	38 ca                	cmp    %cl,%dl
  800b5c:	74 04                	je     800b62 <strfind+0x1a>
  800b5e:	84 d2                	test   %dl,%dl
  800b60:	75 f2                	jne    800b54 <strfind+0xc>
			break;
	return (char *) s;
}
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
  800b6a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b6d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b70:	85 c9                	test   %ecx,%ecx
  800b72:	74 36                	je     800baa <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b74:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b7a:	75 28                	jne    800ba4 <memset+0x40>
  800b7c:	f6 c1 03             	test   $0x3,%cl
  800b7f:	75 23                	jne    800ba4 <memset+0x40>
		c &= 0xFF;
  800b81:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b85:	89 d3                	mov    %edx,%ebx
  800b87:	c1 e3 08             	shl    $0x8,%ebx
  800b8a:	89 d6                	mov    %edx,%esi
  800b8c:	c1 e6 18             	shl    $0x18,%esi
  800b8f:	89 d0                	mov    %edx,%eax
  800b91:	c1 e0 10             	shl    $0x10,%eax
  800b94:	09 f0                	or     %esi,%eax
  800b96:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b98:	89 d8                	mov    %ebx,%eax
  800b9a:	09 d0                	or     %edx,%eax
  800b9c:	c1 e9 02             	shr    $0x2,%ecx
  800b9f:	fc                   	cld    
  800ba0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba2:	eb 06                	jmp    800baa <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba7:	fc                   	cld    
  800ba8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800baa:	89 f8                	mov    %edi,%eax
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bbf:	39 c6                	cmp    %eax,%esi
  800bc1:	73 35                	jae    800bf8 <memmove+0x47>
  800bc3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc6:	39 d0                	cmp    %edx,%eax
  800bc8:	73 2e                	jae    800bf8 <memmove+0x47>
		s += n;
		d += n;
  800bca:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bcd:	89 d6                	mov    %edx,%esi
  800bcf:	09 fe                	or     %edi,%esi
  800bd1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bd7:	75 13                	jne    800bec <memmove+0x3b>
  800bd9:	f6 c1 03             	test   $0x3,%cl
  800bdc:	75 0e                	jne    800bec <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bde:	83 ef 04             	sub    $0x4,%edi
  800be1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be4:	c1 e9 02             	shr    $0x2,%ecx
  800be7:	fd                   	std    
  800be8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bea:	eb 09                	jmp    800bf5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bec:	83 ef 01             	sub    $0x1,%edi
  800bef:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bf2:	fd                   	std    
  800bf3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bf5:	fc                   	cld    
  800bf6:	eb 1d                	jmp    800c15 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf8:	89 f2                	mov    %esi,%edx
  800bfa:	09 c2                	or     %eax,%edx
  800bfc:	f6 c2 03             	test   $0x3,%dl
  800bff:	75 0f                	jne    800c10 <memmove+0x5f>
  800c01:	f6 c1 03             	test   $0x3,%cl
  800c04:	75 0a                	jne    800c10 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c06:	c1 e9 02             	shr    $0x2,%ecx
  800c09:	89 c7                	mov    %eax,%edi
  800c0b:	fc                   	cld    
  800c0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0e:	eb 05                	jmp    800c15 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c10:	89 c7                	mov    %eax,%edi
  800c12:	fc                   	cld    
  800c13:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c1c:	ff 75 10             	pushl  0x10(%ebp)
  800c1f:	ff 75 0c             	pushl  0xc(%ebp)
  800c22:	ff 75 08             	pushl  0x8(%ebp)
  800c25:	e8 87 ff ff ff       	call   800bb1 <memmove>
}
  800c2a:	c9                   	leave  
  800c2b:	c3                   	ret    

00800c2c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	8b 45 08             	mov    0x8(%ebp),%eax
  800c34:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c37:	89 c6                	mov    %eax,%esi
  800c39:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3c:	eb 1a                	jmp    800c58 <memcmp+0x2c>
		if (*s1 != *s2)
  800c3e:	0f b6 08             	movzbl (%eax),%ecx
  800c41:	0f b6 1a             	movzbl (%edx),%ebx
  800c44:	38 d9                	cmp    %bl,%cl
  800c46:	74 0a                	je     800c52 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c48:	0f b6 c1             	movzbl %cl,%eax
  800c4b:	0f b6 db             	movzbl %bl,%ebx
  800c4e:	29 d8                	sub    %ebx,%eax
  800c50:	eb 0f                	jmp    800c61 <memcmp+0x35>
		s1++, s2++;
  800c52:	83 c0 01             	add    $0x1,%eax
  800c55:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c58:	39 f0                	cmp    %esi,%eax
  800c5a:	75 e2                	jne    800c3e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	53                   	push   %ebx
  800c69:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c6c:	89 c1                	mov    %eax,%ecx
  800c6e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c71:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c75:	eb 0a                	jmp    800c81 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c77:	0f b6 10             	movzbl (%eax),%edx
  800c7a:	39 da                	cmp    %ebx,%edx
  800c7c:	74 07                	je     800c85 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c7e:	83 c0 01             	add    $0x1,%eax
  800c81:	39 c8                	cmp    %ecx,%eax
  800c83:	72 f2                	jb     800c77 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c85:	5b                   	pop    %ebx
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c91:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c94:	eb 03                	jmp    800c99 <strtol+0x11>
		s++;
  800c96:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c99:	0f b6 01             	movzbl (%ecx),%eax
  800c9c:	3c 20                	cmp    $0x20,%al
  800c9e:	74 f6                	je     800c96 <strtol+0xe>
  800ca0:	3c 09                	cmp    $0x9,%al
  800ca2:	74 f2                	je     800c96 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ca4:	3c 2b                	cmp    $0x2b,%al
  800ca6:	75 0a                	jne    800cb2 <strtol+0x2a>
		s++;
  800ca8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cab:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb0:	eb 11                	jmp    800cc3 <strtol+0x3b>
  800cb2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cb7:	3c 2d                	cmp    $0x2d,%al
  800cb9:	75 08                	jne    800cc3 <strtol+0x3b>
		s++, neg = 1;
  800cbb:	83 c1 01             	add    $0x1,%ecx
  800cbe:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cc9:	75 15                	jne    800ce0 <strtol+0x58>
  800ccb:	80 39 30             	cmpb   $0x30,(%ecx)
  800cce:	75 10                	jne    800ce0 <strtol+0x58>
  800cd0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cd4:	75 7c                	jne    800d52 <strtol+0xca>
		s += 2, base = 16;
  800cd6:	83 c1 02             	add    $0x2,%ecx
  800cd9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cde:	eb 16                	jmp    800cf6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ce0:	85 db                	test   %ebx,%ebx
  800ce2:	75 12                	jne    800cf6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ce4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce9:	80 39 30             	cmpb   $0x30,(%ecx)
  800cec:	75 08                	jne    800cf6 <strtol+0x6e>
		s++, base = 8;
  800cee:	83 c1 01             	add    $0x1,%ecx
  800cf1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cf6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cfe:	0f b6 11             	movzbl (%ecx),%edx
  800d01:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d04:	89 f3                	mov    %esi,%ebx
  800d06:	80 fb 09             	cmp    $0x9,%bl
  800d09:	77 08                	ja     800d13 <strtol+0x8b>
			dig = *s - '0';
  800d0b:	0f be d2             	movsbl %dl,%edx
  800d0e:	83 ea 30             	sub    $0x30,%edx
  800d11:	eb 22                	jmp    800d35 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d13:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d16:	89 f3                	mov    %esi,%ebx
  800d18:	80 fb 19             	cmp    $0x19,%bl
  800d1b:	77 08                	ja     800d25 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d1d:	0f be d2             	movsbl %dl,%edx
  800d20:	83 ea 57             	sub    $0x57,%edx
  800d23:	eb 10                	jmp    800d35 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d25:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d28:	89 f3                	mov    %esi,%ebx
  800d2a:	80 fb 19             	cmp    $0x19,%bl
  800d2d:	77 16                	ja     800d45 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d2f:	0f be d2             	movsbl %dl,%edx
  800d32:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d35:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d38:	7d 0b                	jge    800d45 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d3a:	83 c1 01             	add    $0x1,%ecx
  800d3d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d41:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d43:	eb b9                	jmp    800cfe <strtol+0x76>

	if (endptr)
  800d45:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d49:	74 0d                	je     800d58 <strtol+0xd0>
		*endptr = (char *) s;
  800d4b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d4e:	89 0e                	mov    %ecx,(%esi)
  800d50:	eb 06                	jmp    800d58 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d52:	85 db                	test   %ebx,%ebx
  800d54:	74 98                	je     800cee <strtol+0x66>
  800d56:	eb 9e                	jmp    800cf6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d58:	89 c2                	mov    %eax,%edx
  800d5a:	f7 da                	neg    %edx
  800d5c:	85 ff                	test   %edi,%edi
  800d5e:	0f 45 c2             	cmovne %edx,%eax
}
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 04             	sub    $0x4,%esp
  800d6f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800d72:	57                   	push   %edi
  800d73:	e8 6e fc ff ff       	call   8009e6 <strlen>
  800d78:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800d7b:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800d7e:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800d83:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800d88:	eb 46                	jmp    800dd0 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800d8a:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800d8e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800d91:	80 f9 09             	cmp    $0x9,%cl
  800d94:	77 08                	ja     800d9e <charhex_to_dec+0x38>
			num = s[i] - '0';
  800d96:	0f be d2             	movsbl %dl,%edx
  800d99:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800d9c:	eb 27                	jmp    800dc5 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800d9e:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800da1:	80 f9 05             	cmp    $0x5,%cl
  800da4:	77 08                	ja     800dae <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800da6:	0f be d2             	movsbl %dl,%edx
  800da9:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800dac:	eb 17                	jmp    800dc5 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800dae:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800db1:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800db4:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800db9:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800dbd:	77 06                	ja     800dc5 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800dbf:	0f be d2             	movsbl %dl,%edx
  800dc2:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800dc5:	0f af ce             	imul   %esi,%ecx
  800dc8:	01 c8                	add    %ecx,%eax
		base *= 16;
  800dca:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800dcd:	83 eb 01             	sub    $0x1,%ebx
  800dd0:	83 fb 01             	cmp    $0x1,%ebx
  800dd3:	7f b5                	jg     800d8a <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800dd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de3:	b8 00 00 00 00       	mov    $0x0,%eax
  800de8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800deb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dee:	89 c3                	mov    %eax,%ebx
  800df0:	89 c7                	mov    %eax,%edi
  800df2:	89 c6                	mov    %eax,%esi
  800df4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <sys_cgetc>:

int
sys_cgetc(void)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	57                   	push   %edi
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e01:	ba 00 00 00 00       	mov    $0x0,%edx
  800e06:	b8 01 00 00 00       	mov    $0x1,%eax
  800e0b:	89 d1                	mov    %edx,%ecx
  800e0d:	89 d3                	mov    %edx,%ebx
  800e0f:	89 d7                	mov    %edx,%edi
  800e11:	89 d6                	mov    %edx,%esi
  800e13:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	57                   	push   %edi
  800e1e:	56                   	push   %esi
  800e1f:	53                   	push   %ebx
  800e20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e23:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e28:	b8 03 00 00 00       	mov    $0x3,%eax
  800e2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e30:	89 cb                	mov    %ecx,%ebx
  800e32:	89 cf                	mov    %ecx,%edi
  800e34:	89 ce                	mov    %ecx,%esi
  800e36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e38:	85 c0                	test   %eax,%eax
  800e3a:	7e 17                	jle    800e53 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3c:	83 ec 0c             	sub    $0xc,%esp
  800e3f:	50                   	push   %eax
  800e40:	6a 03                	push   $0x3
  800e42:	68 ff 29 80 00       	push   $0x8029ff
  800e47:	6a 23                	push   $0x23
  800e49:	68 1c 2a 80 00       	push   $0x802a1c
  800e4e:	e8 bf f4 ff ff       	call   800312 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e56:	5b                   	pop    %ebx
  800e57:	5e                   	pop    %esi
  800e58:	5f                   	pop    %edi
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    

00800e5b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	57                   	push   %edi
  800e5f:	56                   	push   %esi
  800e60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e61:	ba 00 00 00 00       	mov    $0x0,%edx
  800e66:	b8 02 00 00 00       	mov    $0x2,%eax
  800e6b:	89 d1                	mov    %edx,%ecx
  800e6d:	89 d3                	mov    %edx,%ebx
  800e6f:	89 d7                	mov    %edx,%edi
  800e71:	89 d6                	mov    %edx,%esi
  800e73:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5f                   	pop    %edi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <sys_yield>:

void
sys_yield(void)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	57                   	push   %edi
  800e7e:	56                   	push   %esi
  800e7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e80:	ba 00 00 00 00       	mov    $0x0,%edx
  800e85:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e8a:	89 d1                	mov    %edx,%ecx
  800e8c:	89 d3                	mov    %edx,%ebx
  800e8e:	89 d7                	mov    %edx,%edi
  800e90:	89 d6                	mov    %edx,%esi
  800e92:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	57                   	push   %edi
  800e9d:	56                   	push   %esi
  800e9e:	53                   	push   %ebx
  800e9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea2:	be 00 00 00 00       	mov    $0x0,%esi
  800ea7:	b8 04 00 00 00       	mov    $0x4,%eax
  800eac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eaf:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb5:	89 f7                	mov    %esi,%edi
  800eb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	7e 17                	jle    800ed4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebd:	83 ec 0c             	sub    $0xc,%esp
  800ec0:	50                   	push   %eax
  800ec1:	6a 04                	push   $0x4
  800ec3:	68 ff 29 80 00       	push   $0x8029ff
  800ec8:	6a 23                	push   $0x23
  800eca:	68 1c 2a 80 00       	push   $0x802a1c
  800ecf:	e8 3e f4 ff ff       	call   800312 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ed4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed7:	5b                   	pop    %ebx
  800ed8:	5e                   	pop    %esi
  800ed9:	5f                   	pop    %edi
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	57                   	push   %edi
  800ee0:	56                   	push   %esi
  800ee1:	53                   	push   %ebx
  800ee2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee5:	b8 05 00 00 00       	mov    $0x5,%eax
  800eea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eed:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ef6:	8b 75 18             	mov    0x18(%ebp),%esi
  800ef9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800efb:	85 c0                	test   %eax,%eax
  800efd:	7e 17                	jle    800f16 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eff:	83 ec 0c             	sub    $0xc,%esp
  800f02:	50                   	push   %eax
  800f03:	6a 05                	push   $0x5
  800f05:	68 ff 29 80 00       	push   $0x8029ff
  800f0a:	6a 23                	push   $0x23
  800f0c:	68 1c 2a 80 00       	push   $0x802a1c
  800f11:	e8 fc f3 ff ff       	call   800312 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f19:	5b                   	pop    %ebx
  800f1a:	5e                   	pop    %esi
  800f1b:	5f                   	pop    %edi
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	53                   	push   %ebx
  800f24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2c:	b8 06 00 00 00       	mov    $0x6,%eax
  800f31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f34:	8b 55 08             	mov    0x8(%ebp),%edx
  800f37:	89 df                	mov    %ebx,%edi
  800f39:	89 de                	mov    %ebx,%esi
  800f3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	7e 17                	jle    800f58 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f41:	83 ec 0c             	sub    $0xc,%esp
  800f44:	50                   	push   %eax
  800f45:	6a 06                	push   $0x6
  800f47:	68 ff 29 80 00       	push   $0x8029ff
  800f4c:	6a 23                	push   $0x23
  800f4e:	68 1c 2a 80 00       	push   $0x802a1c
  800f53:	e8 ba f3 ff ff       	call   800312 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5b:	5b                   	pop    %ebx
  800f5c:	5e                   	pop    %esi
  800f5d:	5f                   	pop    %edi
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	57                   	push   %edi
  800f64:	56                   	push   %esi
  800f65:	53                   	push   %ebx
  800f66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f6e:	b8 08 00 00 00       	mov    $0x8,%eax
  800f73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f76:	8b 55 08             	mov    0x8(%ebp),%edx
  800f79:	89 df                	mov    %ebx,%edi
  800f7b:	89 de                	mov    %ebx,%esi
  800f7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	7e 17                	jle    800f9a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f83:	83 ec 0c             	sub    $0xc,%esp
  800f86:	50                   	push   %eax
  800f87:	6a 08                	push   $0x8
  800f89:	68 ff 29 80 00       	push   $0x8029ff
  800f8e:	6a 23                	push   $0x23
  800f90:	68 1c 2a 80 00       	push   $0x802a1c
  800f95:	e8 78 f3 ff ff       	call   800312 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5f                   	pop    %edi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	57                   	push   %edi
  800fa6:	56                   	push   %esi
  800fa7:	53                   	push   %ebx
  800fa8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbb:	89 df                	mov    %ebx,%edi
  800fbd:	89 de                	mov    %ebx,%esi
  800fbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	7e 17                	jle    800fdc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc5:	83 ec 0c             	sub    $0xc,%esp
  800fc8:	50                   	push   %eax
  800fc9:	6a 0a                	push   $0xa
  800fcb:	68 ff 29 80 00       	push   $0x8029ff
  800fd0:	6a 23                	push   $0x23
  800fd2:	68 1c 2a 80 00       	push   $0x802a1c
  800fd7:	e8 36 f3 ff ff       	call   800312 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fdf:	5b                   	pop    %ebx
  800fe0:	5e                   	pop    %esi
  800fe1:	5f                   	pop    %edi
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	57                   	push   %edi
  800fe8:	56                   	push   %esi
  800fe9:	53                   	push   %ebx
  800fea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fed:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff2:	b8 09 00 00 00       	mov    $0x9,%eax
  800ff7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffa:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffd:	89 df                	mov    %ebx,%edi
  800fff:	89 de                	mov    %ebx,%esi
  801001:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801003:	85 c0                	test   %eax,%eax
  801005:	7e 17                	jle    80101e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	50                   	push   %eax
  80100b:	6a 09                	push   $0x9
  80100d:	68 ff 29 80 00       	push   $0x8029ff
  801012:	6a 23                	push   $0x23
  801014:	68 1c 2a 80 00       	push   $0x802a1c
  801019:	e8 f4 f2 ff ff       	call   800312 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80101e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801021:	5b                   	pop    %ebx
  801022:	5e                   	pop    %esi
  801023:	5f                   	pop    %edi
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	57                   	push   %edi
  80102a:	56                   	push   %esi
  80102b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80102c:	be 00 00 00 00       	mov    $0x0,%esi
  801031:	b8 0c 00 00 00       	mov    $0xc,%eax
  801036:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801039:	8b 55 08             	mov    0x8(%ebp),%edx
  80103c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80103f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801042:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801044:	5b                   	pop    %ebx
  801045:	5e                   	pop    %esi
  801046:	5f                   	pop    %edi
  801047:	5d                   	pop    %ebp
  801048:	c3                   	ret    

00801049 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	57                   	push   %edi
  80104d:	56                   	push   %esi
  80104e:	53                   	push   %ebx
  80104f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801052:	b9 00 00 00 00       	mov    $0x0,%ecx
  801057:	b8 0d 00 00 00       	mov    $0xd,%eax
  80105c:	8b 55 08             	mov    0x8(%ebp),%edx
  80105f:	89 cb                	mov    %ecx,%ebx
  801061:	89 cf                	mov    %ecx,%edi
  801063:	89 ce                	mov    %ecx,%esi
  801065:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801067:	85 c0                	test   %eax,%eax
  801069:	7e 17                	jle    801082 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80106b:	83 ec 0c             	sub    $0xc,%esp
  80106e:	50                   	push   %eax
  80106f:	6a 0d                	push   $0xd
  801071:	68 ff 29 80 00       	push   $0x8029ff
  801076:	6a 23                	push   $0x23
  801078:	68 1c 2a 80 00       	push   $0x802a1c
  80107d:	e8 90 f2 ff ff       	call   800312 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801082:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801085:	5b                   	pop    %ebx
  801086:	5e                   	pop    %esi
  801087:	5f                   	pop    %edi
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    

0080108a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	53                   	push   %ebx
  80108e:	83 ec 04             	sub    $0x4,%esp
  801091:	8b 45 08             	mov    0x8(%ebp),%eax

	
	void *addr = (void *) utf->utf_fault_va;
  801094:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  801096:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80109a:	74 11                	je     8010ad <pgfault+0x23>
  80109c:	89 d8                	mov    %ebx,%eax
  80109e:	c1 e8 0c             	shr    $0xc,%eax
  8010a1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a8:	f6 c4 08             	test   $0x8,%ah
  8010ab:	75 14                	jne    8010c1 <pgfault+0x37>
		panic("page fault");
  8010ad:	83 ec 04             	sub    $0x4,%esp
  8010b0:	68 2a 2a 80 00       	push   $0x802a2a
  8010b5:	6a 5b                	push   $0x5b
  8010b7:	68 35 2a 80 00       	push   $0x802a35
  8010bc:	e8 51 f2 ff ff       	call   800312 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// allocate a new page and map it at a temporary location
	if((r = sys_page_alloc(0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  8010c1:	83 ec 04             	sub    $0x4,%esp
  8010c4:	6a 07                	push   $0x7
  8010c6:	68 00 f0 7f 00       	push   $0x7ff000
  8010cb:	6a 00                	push   $0x0
  8010cd:	e8 c7 fd ff ff       	call   800e99 <sys_page_alloc>
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	79 12                	jns    8010eb <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  8010d9:	50                   	push   %eax
  8010da:	68 40 2a 80 00       	push   $0x802a40
  8010df:	6a 66                	push   $0x66
  8010e1:	68 35 2a 80 00       	push   $0x802a35
  8010e6:	e8 27 f2 ff ff       	call   800312 <_panic>

	// copy date to new page
	//strncpy((char *)PFTEMP, (char *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
	memcpy((void *)PFTEMP, (void *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
  8010eb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8010f1:	83 ec 04             	sub    $0x4,%esp
  8010f4:	68 00 10 00 00       	push   $0x1000
  8010f9:	53                   	push   %ebx
  8010fa:	68 00 f0 7f 00       	push   $0x7ff000
  8010ff:	e8 15 fb ff ff       	call   800c19 <memcpy>

	// move the new page to the old page's address
	if((r = sys_page_map(0, (void *)PFTEMP, 0, (void *)
  801104:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80110b:	53                   	push   %ebx
  80110c:	6a 00                	push   $0x0
  80110e:	68 00 f0 7f 00       	push   $0x7ff000
  801113:	6a 00                	push   $0x0
  801115:	e8 c2 fd ff ff       	call   800edc <sys_page_map>
  80111a:	83 c4 20             	add    $0x20,%esp
  80111d:	85 c0                	test   %eax,%eax
  80111f:	79 12                	jns    801133 <pgfault+0xa9>
		(ROUNDDOWN(addr, PGSIZE)), PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_map: %e", r);
  801121:	50                   	push   %eax
  801122:	68 53 2a 80 00       	push   $0x802a53
  801127:	6a 6f                	push   $0x6f
  801129:	68 35 2a 80 00       	push   $0x802a35
  80112e:	e8 df f1 ff ff       	call   800312 <_panic>

	// unmap page on PFTEMP
	if((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  801133:	83 ec 08             	sub    $0x8,%esp
  801136:	68 00 f0 7f 00       	push   $0x7ff000
  80113b:	6a 00                	push   $0x0
  80113d:	e8 dc fd ff ff       	call   800f1e <sys_page_unmap>
  801142:	83 c4 10             	add    $0x10,%esp
  801145:	85 c0                	test   %eax,%eax
  801147:	79 12                	jns    80115b <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  801149:	50                   	push   %eax
  80114a:	68 64 2a 80 00       	push   $0x802a64
  80114f:	6a 73                	push   $0x73
  801151:	68 35 2a 80 00       	push   $0x802a35
  801156:	e8 b7 f1 ff ff       	call   800312 <_panic>


}
  80115b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115e:	c9                   	leave  
  80115f:	c3                   	ret    

00801160 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	57                   	push   %edi
  801164:	56                   	push   %esi
  801165:	53                   	push   %ebx
  801166:	83 ec 28             	sub    $0x28,%esp

	#ifdef CHALLENGE 
	set_exception_handler(pgfault, T_PGFLT);
	#else
	// set up page fault handler
	set_pgfault_handler(pgfault);
  801169:	68 8a 10 80 00       	push   $0x80108a
  80116e:	e8 a0 0f 00 00       	call   802113 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801173:	b8 07 00 00 00       	mov    $0x7,%eax
  801178:	cd 30                	int    $0x30
  80117a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80117d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	#endif

	// create a child
	envid = sys_exofork();
	if (envid < 0)
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	85 c0                	test   %eax,%eax
  801185:	79 15                	jns    80119c <fork+0x3c>
		panic("sys_exofork: %e", envid);
  801187:	50                   	push   %eax
  801188:	68 77 2a 80 00       	push   $0x802a77
  80118d:	68 d0 00 00 00       	push   $0xd0
  801192:	68 35 2a 80 00       	push   $0x802a35
  801197:	e8 76 f1 ff ff       	call   800312 <_panic>
  80119c:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8011a1:	be 00 08 00 00       	mov    $0x800,%esi
	// we are the child
	if(envid == 0) {
  8011a6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8011aa:	75 21                	jne    8011cd <fork+0x6d>
		// the copied valude of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8011ac:	e8 aa fc ff ff       	call   800e5b <sys_getenvid>
  8011b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011be:	a3 08 40 80 00       	mov    %eax,0x804008
		/*// alloc exception stack
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
			PTE_P | PTE_U | PTE_W)) < 0)
			panic("sys_page_alloc: %e", r);*/

		return 0;
  8011c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c8:	e9 a3 01 00 00       	jmp    801370 <fork+0x210>
{
	int r;

	// LAB 4: Your code here.
	
	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P))
  8011cd:	89 d8                	mov    %ebx,%eax
  8011cf:	c1 e8 16             	shr    $0x16,%eax
  8011d2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011d9:	a8 01                	test   $0x1,%al
  8011db:	0f 84 f0 00 00 00    	je     8012d1 <fork+0x171>
		return 0;

	// virtual page pn's page table entry
	pte_t pe = uvpt[pn];
  8011e1:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi


	if((pe & PTE_P) && (pe & PTE_U)) {
  8011e8:	89 f8                	mov    %edi,%eax
  8011ea:	83 e0 05             	and    $0x5,%eax
  8011ed:	83 f8 05             	cmp    $0x5,%eax
  8011f0:	0f 85 db 00 00 00    	jne    8012d1 <fork+0x171>
		// share with the child environment 
		if(pe & PTE_SHARE) {
  8011f6:	f7 c7 00 04 00 00    	test   $0x400,%edi
  8011fc:	74 36                	je     801234 <fork+0xd4>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  8011fe:	83 ec 0c             	sub    $0xc,%esp
  801201:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  801207:	57                   	push   %edi
  801208:	53                   	push   %ebx
  801209:	ff 75 e4             	pushl  -0x1c(%ebp)
  80120c:	53                   	push   %ebx
  80120d:	6a 00                	push   $0x0
  80120f:	e8 c8 fc ff ff       	call   800edc <sys_page_map>
  801214:	83 c4 20             	add    $0x20,%esp
  801217:	85 c0                	test   %eax,%eax
  801219:	0f 89 b2 00 00 00    	jns    8012d1 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  80121f:	50                   	push   %eax
  801220:	68 87 2a 80 00       	push   $0x802a87
  801225:	68 97 00 00 00       	push   $0x97
  80122a:	68 35 2a 80 00       	push   $0x802a35
  80122f:	e8 de f0 ff ff       	call   800312 <_panic>
		}
		// the page is writable or copy-on-write
		else if((pe & PTE_W) || (pe & PTE_COW)) {
  801234:	f7 c7 02 08 00 00    	test   $0x802,%edi
  80123a:	74 63                	je     80129f <fork+0x13f>
			// create the child mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, 
  80123c:	81 e7 05 06 00 00    	and    $0x605,%edi
  801242:	81 cf 00 08 00 00    	or     $0x800,%edi
  801248:	83 ec 0c             	sub    $0xc,%esp
  80124b:	57                   	push   %edi
  80124c:	53                   	push   %ebx
  80124d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801250:	53                   	push   %ebx
  801251:	6a 00                	push   $0x0
  801253:	e8 84 fc ff ff       	call   800edc <sys_page_map>
  801258:	83 c4 20             	add    $0x20,%esp
  80125b:	85 c0                	test   %eax,%eax
  80125d:	79 15                	jns    801274 <fork+0x114>
				(void *)(pn*PGSIZE), (pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  80125f:	50                   	push   %eax
  801260:	68 87 2a 80 00       	push   $0x802a87
  801265:	68 9e 00 00 00       	push   $0x9e
  80126a:	68 35 2a 80 00       	push   $0x802a35
  80126f:	e8 9e f0 ff ff       	call   800312 <_panic>
			// map the parent mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE),
  801274:	83 ec 0c             	sub    $0xc,%esp
  801277:	57                   	push   %edi
  801278:	53                   	push   %ebx
  801279:	6a 00                	push   $0x0
  80127b:	53                   	push   %ebx
  80127c:	6a 00                	push   $0x0
  80127e:	e8 59 fc ff ff       	call   800edc <sys_page_map>
  801283:	83 c4 20             	add    $0x20,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	79 47                	jns    8012d1 <fork+0x171>
				(pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  80128a:	50                   	push   %eax
  80128b:	68 87 2a 80 00       	push   $0x802a87
  801290:	68 a2 00 00 00       	push   $0xa2
  801295:	68 35 2a 80 00       	push   $0x802a35
  80129a:	e8 73 f0 ff ff       	call   800312 <_panic>
		}	
		else {
			// create the child mapping read only
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  80129f:	83 ec 0c             	sub    $0xc,%esp
  8012a2:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  8012a8:	57                   	push   %edi
  8012a9:	53                   	push   %ebx
  8012aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012ad:	53                   	push   %ebx
  8012ae:	6a 00                	push   $0x0
  8012b0:	e8 27 fc ff ff       	call   800edc <sys_page_map>
  8012b5:	83 c4 20             	add    $0x20,%esp
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	79 15                	jns    8012d1 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  8012bc:	50                   	push   %eax
  8012bd:	68 87 2a 80 00       	push   $0x802a87
  8012c2:	68 a8 00 00 00       	push   $0xa8
  8012c7:	68 35 2a 80 00       	push   $0x802a35
  8012cc:	e8 41 f0 ff ff       	call   800312 <_panic>
			panic("sys_page_alloc: %e", r);*/

		return 0;
	}
	// copy address to child environment's page dirctory
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn)
  8012d1:	83 c6 01             	add    $0x1,%esi
  8012d4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8012da:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8012e0:	0f 85 e7 fe ff ff    	jne    8011cd <fork+0x6d>
	#ifdef CHALLENGE 
	if((r = sys_env_set_exception_upcall(envid, thisenv->env_exception_upcall)) < 0)
		panic("sys_env_set_exception_upcall: %e", r);
	#else
	// set child's page fault handler
	if((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  8012e6:	a1 08 40 80 00       	mov    0x804008,%eax
  8012eb:	8b 40 64             	mov    0x64(%eax),%eax
  8012ee:	83 ec 08             	sub    $0x8,%esp
  8012f1:	50                   	push   %eax
  8012f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8012f5:	e8 ea fc ff ff       	call   800fe4 <sys_env_set_pgfault_upcall>
  8012fa:	83 c4 10             	add    $0x10,%esp
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	79 15                	jns    801316 <fork+0x1b6>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801301:	50                   	push   %eax
  801302:	68 c0 2a 80 00       	push   $0x802ac0
  801307:	68 e9 00 00 00       	push   $0xe9
  80130c:	68 35 2a 80 00       	push   $0x802a35
  801311:	e8 fc ef ff ff       	call   800312 <_panic>
	#endif

	// alloc exception stack for child environment
	if((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), 
  801316:	83 ec 04             	sub    $0x4,%esp
  801319:	6a 07                	push   $0x7
  80131b:	68 00 f0 bf ee       	push   $0xeebff000
  801320:	ff 75 e0             	pushl  -0x20(%ebp)
  801323:	e8 71 fb ff ff       	call   800e99 <sys_page_alloc>
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	85 c0                	test   %eax,%eax
  80132d:	79 15                	jns    801344 <fork+0x1e4>
		PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
  80132f:	50                   	push   %eax
  801330:	68 40 2a 80 00       	push   $0x802a40
  801335:	68 ef 00 00 00       	push   $0xef
  80133a:	68 35 2a 80 00       	push   $0x802a35
  80133f:	e8 ce ef ff ff       	call   800312 <_panic>

	// start the child environment running
	if((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801344:	83 ec 08             	sub    $0x8,%esp
  801347:	6a 02                	push   $0x2
  801349:	ff 75 e0             	pushl  -0x20(%ebp)
  80134c:	e8 0f fc ff ff       	call   800f60 <sys_env_set_status>
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	85 c0                	test   %eax,%eax
  801356:	79 15                	jns    80136d <fork+0x20d>
		panic("sys_env_set_status: %e", r);
  801358:	50                   	push   %eax
  801359:	68 93 2a 80 00       	push   $0x802a93
  80135e:	68 f3 00 00 00       	push   $0xf3
  801363:	68 35 2a 80 00       	push   $0x802a35
  801368:	e8 a5 ef ff ff       	call   800312 <_panic>

	return envid;
  80136d:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801370:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801373:	5b                   	pop    %ebx
  801374:	5e                   	pop    %esi
  801375:	5f                   	pop    %edi
  801376:	5d                   	pop    %ebp
  801377:	c3                   	ret    

00801378 <sfork>:

// Challenge!
int
sfork(void)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80137e:	68 aa 2a 80 00       	push   $0x802aaa
  801383:	68 fc 00 00 00       	push   $0xfc
  801388:	68 35 2a 80 00       	push   $0x802a35
  80138d:	e8 80 ef ff ff       	call   800312 <_panic>

00801392 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801395:	8b 45 08             	mov    0x8(%ebp),%eax
  801398:	05 00 00 00 30       	add    $0x30000000,%eax
  80139d:	c1 e8 0c             	shr    $0xc,%eax
}
  8013a0:	5d                   	pop    %ebp
  8013a1:	c3                   	ret    

008013a2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a8:	05 00 00 00 30       	add    $0x30000000,%eax
  8013ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013b2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013b7:	5d                   	pop    %ebp
  8013b8:	c3                   	ret    

008013b9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013b9:	55                   	push   %ebp
  8013ba:	89 e5                	mov    %esp,%ebp
  8013bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013bf:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013c4:	89 c2                	mov    %eax,%edx
  8013c6:	c1 ea 16             	shr    $0x16,%edx
  8013c9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013d0:	f6 c2 01             	test   $0x1,%dl
  8013d3:	74 11                	je     8013e6 <fd_alloc+0x2d>
  8013d5:	89 c2                	mov    %eax,%edx
  8013d7:	c1 ea 0c             	shr    $0xc,%edx
  8013da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013e1:	f6 c2 01             	test   $0x1,%dl
  8013e4:	75 09                	jne    8013ef <fd_alloc+0x36>
			*fd_store = fd;
  8013e6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ed:	eb 17                	jmp    801406 <fd_alloc+0x4d>
  8013ef:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013f4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013f9:	75 c9                	jne    8013c4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013fb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801401:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    

00801408 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80140e:	83 f8 1f             	cmp    $0x1f,%eax
  801411:	77 36                	ja     801449 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801413:	c1 e0 0c             	shl    $0xc,%eax
  801416:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80141b:	89 c2                	mov    %eax,%edx
  80141d:	c1 ea 16             	shr    $0x16,%edx
  801420:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801427:	f6 c2 01             	test   $0x1,%dl
  80142a:	74 24                	je     801450 <fd_lookup+0x48>
  80142c:	89 c2                	mov    %eax,%edx
  80142e:	c1 ea 0c             	shr    $0xc,%edx
  801431:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801438:	f6 c2 01             	test   $0x1,%dl
  80143b:	74 1a                	je     801457 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80143d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801440:	89 02                	mov    %eax,(%edx)
	return 0;
  801442:	b8 00 00 00 00       	mov    $0x0,%eax
  801447:	eb 13                	jmp    80145c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801449:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80144e:	eb 0c                	jmp    80145c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801450:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801455:	eb 05                	jmp    80145c <fd_lookup+0x54>
  801457:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80145c:	5d                   	pop    %ebp
  80145d:	c3                   	ret    

0080145e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	83 ec 08             	sub    $0x8,%esp
  801464:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801467:	ba 5c 2b 80 00       	mov    $0x802b5c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80146c:	eb 13                	jmp    801481 <dev_lookup+0x23>
  80146e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801471:	39 08                	cmp    %ecx,(%eax)
  801473:	75 0c                	jne    801481 <dev_lookup+0x23>
			*dev = devtab[i];
  801475:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801478:	89 01                	mov    %eax,(%ecx)
			return 0;
  80147a:	b8 00 00 00 00       	mov    $0x0,%eax
  80147f:	eb 2e                	jmp    8014af <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801481:	8b 02                	mov    (%edx),%eax
  801483:	85 c0                	test   %eax,%eax
  801485:	75 e7                	jne    80146e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801487:	a1 08 40 80 00       	mov    0x804008,%eax
  80148c:	8b 40 48             	mov    0x48(%eax),%eax
  80148f:	83 ec 04             	sub    $0x4,%esp
  801492:	51                   	push   %ecx
  801493:	50                   	push   %eax
  801494:	68 e0 2a 80 00       	push   $0x802ae0
  801499:	e8 4d ef ff ff       	call   8003eb <cprintf>
	*dev = 0;
  80149e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014a7:	83 c4 10             	add    $0x10,%esp
  8014aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014af:	c9                   	leave  
  8014b0:	c3                   	ret    

008014b1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	56                   	push   %esi
  8014b5:	53                   	push   %ebx
  8014b6:	83 ec 10             	sub    $0x10,%esp
  8014b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8014bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c2:	50                   	push   %eax
  8014c3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014c9:	c1 e8 0c             	shr    $0xc,%eax
  8014cc:	50                   	push   %eax
  8014cd:	e8 36 ff ff ff       	call   801408 <fd_lookup>
  8014d2:	83 c4 08             	add    $0x8,%esp
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 05                	js     8014de <fd_close+0x2d>
	    || fd != fd2) 
  8014d9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014dc:	74 0c                	je     8014ea <fd_close+0x39>
		return (must_exist ? r : 0); 
  8014de:	84 db                	test   %bl,%bl
  8014e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e5:	0f 44 c2             	cmove  %edx,%eax
  8014e8:	eb 41                	jmp    80152b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014ea:	83 ec 08             	sub    $0x8,%esp
  8014ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f0:	50                   	push   %eax
  8014f1:	ff 36                	pushl  (%esi)
  8014f3:	e8 66 ff ff ff       	call   80145e <dev_lookup>
  8014f8:	89 c3                	mov    %eax,%ebx
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	78 1a                	js     80151b <fd_close+0x6a>
		if (dev->dev_close) 
  801501:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801504:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  801507:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  80150c:	85 c0                	test   %eax,%eax
  80150e:	74 0b                	je     80151b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801510:	83 ec 0c             	sub    $0xc,%esp
  801513:	56                   	push   %esi
  801514:	ff d0                	call   *%eax
  801516:	89 c3                	mov    %eax,%ebx
  801518:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80151b:	83 ec 08             	sub    $0x8,%esp
  80151e:	56                   	push   %esi
  80151f:	6a 00                	push   $0x0
  801521:	e8 f8 f9 ff ff       	call   800f1e <sys_page_unmap>
	return r;
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	89 d8                	mov    %ebx,%eax
}
  80152b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152e:	5b                   	pop    %ebx
  80152f:	5e                   	pop    %esi
  801530:	5d                   	pop    %ebp
  801531:	c3                   	ret    

00801532 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801538:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153b:	50                   	push   %eax
  80153c:	ff 75 08             	pushl  0x8(%ebp)
  80153f:	e8 c4 fe ff ff       	call   801408 <fd_lookup>
  801544:	83 c4 08             	add    $0x8,%esp
  801547:	85 c0                	test   %eax,%eax
  801549:	78 10                	js     80155b <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  80154b:	83 ec 08             	sub    $0x8,%esp
  80154e:	6a 01                	push   $0x1
  801550:	ff 75 f4             	pushl  -0xc(%ebp)
  801553:	e8 59 ff ff ff       	call   8014b1 <fd_close>
  801558:	83 c4 10             	add    $0x10,%esp
}
  80155b:	c9                   	leave  
  80155c:	c3                   	ret    

0080155d <close_all>:

void
close_all(void)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	53                   	push   %ebx
  801561:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801564:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801569:	83 ec 0c             	sub    $0xc,%esp
  80156c:	53                   	push   %ebx
  80156d:	e8 c0 ff ff ff       	call   801532 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801572:	83 c3 01             	add    $0x1,%ebx
  801575:	83 c4 10             	add    $0x10,%esp
  801578:	83 fb 20             	cmp    $0x20,%ebx
  80157b:	75 ec                	jne    801569 <close_all+0xc>
		close(i);
}
  80157d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801580:	c9                   	leave  
  801581:	c3                   	ret    

00801582 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	57                   	push   %edi
  801586:	56                   	push   %esi
  801587:	53                   	push   %ebx
  801588:	83 ec 2c             	sub    $0x2c,%esp
  80158b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80158e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801591:	50                   	push   %eax
  801592:	ff 75 08             	pushl  0x8(%ebp)
  801595:	e8 6e fe ff ff       	call   801408 <fd_lookup>
  80159a:	83 c4 08             	add    $0x8,%esp
  80159d:	85 c0                	test   %eax,%eax
  80159f:	0f 88 c1 00 00 00    	js     801666 <dup+0xe4>
		return r;
	close(newfdnum);
  8015a5:	83 ec 0c             	sub    $0xc,%esp
  8015a8:	56                   	push   %esi
  8015a9:	e8 84 ff ff ff       	call   801532 <close>

	newfd = INDEX2FD(newfdnum);
  8015ae:	89 f3                	mov    %esi,%ebx
  8015b0:	c1 e3 0c             	shl    $0xc,%ebx
  8015b3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015b9:	83 c4 04             	add    $0x4,%esp
  8015bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015bf:	e8 de fd ff ff       	call   8013a2 <fd2data>
  8015c4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015c6:	89 1c 24             	mov    %ebx,(%esp)
  8015c9:	e8 d4 fd ff ff       	call   8013a2 <fd2data>
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015d4:	89 f8                	mov    %edi,%eax
  8015d6:	c1 e8 16             	shr    $0x16,%eax
  8015d9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015e0:	a8 01                	test   $0x1,%al
  8015e2:	74 37                	je     80161b <dup+0x99>
  8015e4:	89 f8                	mov    %edi,%eax
  8015e6:	c1 e8 0c             	shr    $0xc,%eax
  8015e9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015f0:	f6 c2 01             	test   $0x1,%dl
  8015f3:	74 26                	je     80161b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015f5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015fc:	83 ec 0c             	sub    $0xc,%esp
  8015ff:	25 07 0e 00 00       	and    $0xe07,%eax
  801604:	50                   	push   %eax
  801605:	ff 75 d4             	pushl  -0x2c(%ebp)
  801608:	6a 00                	push   $0x0
  80160a:	57                   	push   %edi
  80160b:	6a 00                	push   $0x0
  80160d:	e8 ca f8 ff ff       	call   800edc <sys_page_map>
  801612:	89 c7                	mov    %eax,%edi
  801614:	83 c4 20             	add    $0x20,%esp
  801617:	85 c0                	test   %eax,%eax
  801619:	78 2e                	js     801649 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80161b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80161e:	89 d0                	mov    %edx,%eax
  801620:	c1 e8 0c             	shr    $0xc,%eax
  801623:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80162a:	83 ec 0c             	sub    $0xc,%esp
  80162d:	25 07 0e 00 00       	and    $0xe07,%eax
  801632:	50                   	push   %eax
  801633:	53                   	push   %ebx
  801634:	6a 00                	push   $0x0
  801636:	52                   	push   %edx
  801637:	6a 00                	push   $0x0
  801639:	e8 9e f8 ff ff       	call   800edc <sys_page_map>
  80163e:	89 c7                	mov    %eax,%edi
  801640:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801643:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801645:	85 ff                	test   %edi,%edi
  801647:	79 1d                	jns    801666 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801649:	83 ec 08             	sub    $0x8,%esp
  80164c:	53                   	push   %ebx
  80164d:	6a 00                	push   $0x0
  80164f:	e8 ca f8 ff ff       	call   800f1e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801654:	83 c4 08             	add    $0x8,%esp
  801657:	ff 75 d4             	pushl  -0x2c(%ebp)
  80165a:	6a 00                	push   $0x0
  80165c:	e8 bd f8 ff ff       	call   800f1e <sys_page_unmap>
	return r;
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	89 f8                	mov    %edi,%eax
}
  801666:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801669:	5b                   	pop    %ebx
  80166a:	5e                   	pop    %esi
  80166b:	5f                   	pop    %edi
  80166c:	5d                   	pop    %ebp
  80166d:	c3                   	ret    

0080166e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	53                   	push   %ebx
  801672:	83 ec 14             	sub    $0x14,%esp
  801675:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801678:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167b:	50                   	push   %eax
  80167c:	53                   	push   %ebx
  80167d:	e8 86 fd ff ff       	call   801408 <fd_lookup>
  801682:	83 c4 08             	add    $0x8,%esp
  801685:	89 c2                	mov    %eax,%edx
  801687:	85 c0                	test   %eax,%eax
  801689:	78 6d                	js     8016f8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168b:	83 ec 08             	sub    $0x8,%esp
  80168e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801691:	50                   	push   %eax
  801692:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801695:	ff 30                	pushl  (%eax)
  801697:	e8 c2 fd ff ff       	call   80145e <dev_lookup>
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	78 4c                	js     8016ef <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016a6:	8b 42 08             	mov    0x8(%edx),%eax
  8016a9:	83 e0 03             	and    $0x3,%eax
  8016ac:	83 f8 01             	cmp    $0x1,%eax
  8016af:	75 21                	jne    8016d2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016b1:	a1 08 40 80 00       	mov    0x804008,%eax
  8016b6:	8b 40 48             	mov    0x48(%eax),%eax
  8016b9:	83 ec 04             	sub    $0x4,%esp
  8016bc:	53                   	push   %ebx
  8016bd:	50                   	push   %eax
  8016be:	68 21 2b 80 00       	push   $0x802b21
  8016c3:	e8 23 ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  8016c8:	83 c4 10             	add    $0x10,%esp
  8016cb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016d0:	eb 26                	jmp    8016f8 <read+0x8a>
	}
	if (!dev->dev_read)
  8016d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d5:	8b 40 08             	mov    0x8(%eax),%eax
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	74 17                	je     8016f3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016dc:	83 ec 04             	sub    $0x4,%esp
  8016df:	ff 75 10             	pushl  0x10(%ebp)
  8016e2:	ff 75 0c             	pushl  0xc(%ebp)
  8016e5:	52                   	push   %edx
  8016e6:	ff d0                	call   *%eax
  8016e8:	89 c2                	mov    %eax,%edx
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	eb 09                	jmp    8016f8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ef:	89 c2                	mov    %eax,%edx
  8016f1:	eb 05                	jmp    8016f8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8016f8:	89 d0                	mov    %edx,%eax
  8016fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fd:	c9                   	leave  
  8016fe:	c3                   	ret    

008016ff <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	57                   	push   %edi
  801703:	56                   	push   %esi
  801704:	53                   	push   %ebx
  801705:	83 ec 0c             	sub    $0xc,%esp
  801708:	8b 7d 08             	mov    0x8(%ebp),%edi
  80170b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80170e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801713:	eb 21                	jmp    801736 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801715:	83 ec 04             	sub    $0x4,%esp
  801718:	89 f0                	mov    %esi,%eax
  80171a:	29 d8                	sub    %ebx,%eax
  80171c:	50                   	push   %eax
  80171d:	89 d8                	mov    %ebx,%eax
  80171f:	03 45 0c             	add    0xc(%ebp),%eax
  801722:	50                   	push   %eax
  801723:	57                   	push   %edi
  801724:	e8 45 ff ff ff       	call   80166e <read>
		if (m < 0)
  801729:	83 c4 10             	add    $0x10,%esp
  80172c:	85 c0                	test   %eax,%eax
  80172e:	78 10                	js     801740 <readn+0x41>
			return m;
		if (m == 0)
  801730:	85 c0                	test   %eax,%eax
  801732:	74 0a                	je     80173e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801734:	01 c3                	add    %eax,%ebx
  801736:	39 f3                	cmp    %esi,%ebx
  801738:	72 db                	jb     801715 <readn+0x16>
  80173a:	89 d8                	mov    %ebx,%eax
  80173c:	eb 02                	jmp    801740 <readn+0x41>
  80173e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801740:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801743:	5b                   	pop    %ebx
  801744:	5e                   	pop    %esi
  801745:	5f                   	pop    %edi
  801746:	5d                   	pop    %ebp
  801747:	c3                   	ret    

00801748 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	53                   	push   %ebx
  80174c:	83 ec 14             	sub    $0x14,%esp
  80174f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801752:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801755:	50                   	push   %eax
  801756:	53                   	push   %ebx
  801757:	e8 ac fc ff ff       	call   801408 <fd_lookup>
  80175c:	83 c4 08             	add    $0x8,%esp
  80175f:	89 c2                	mov    %eax,%edx
  801761:	85 c0                	test   %eax,%eax
  801763:	78 68                	js     8017cd <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801765:	83 ec 08             	sub    $0x8,%esp
  801768:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176b:	50                   	push   %eax
  80176c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176f:	ff 30                	pushl  (%eax)
  801771:	e8 e8 fc ff ff       	call   80145e <dev_lookup>
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	85 c0                	test   %eax,%eax
  80177b:	78 47                	js     8017c4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80177d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801780:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801784:	75 21                	jne    8017a7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801786:	a1 08 40 80 00       	mov    0x804008,%eax
  80178b:	8b 40 48             	mov    0x48(%eax),%eax
  80178e:	83 ec 04             	sub    $0x4,%esp
  801791:	53                   	push   %ebx
  801792:	50                   	push   %eax
  801793:	68 3d 2b 80 00       	push   $0x802b3d
  801798:	e8 4e ec ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  80179d:	83 c4 10             	add    $0x10,%esp
  8017a0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017a5:	eb 26                	jmp    8017cd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017aa:	8b 52 0c             	mov    0xc(%edx),%edx
  8017ad:	85 d2                	test   %edx,%edx
  8017af:	74 17                	je     8017c8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017b1:	83 ec 04             	sub    $0x4,%esp
  8017b4:	ff 75 10             	pushl  0x10(%ebp)
  8017b7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ba:	50                   	push   %eax
  8017bb:	ff d2                	call   *%edx
  8017bd:	89 c2                	mov    %eax,%edx
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	eb 09                	jmp    8017cd <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c4:	89 c2                	mov    %eax,%edx
  8017c6:	eb 05                	jmp    8017cd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017c8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017cd:	89 d0                	mov    %edx,%eax
  8017cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d2:	c9                   	leave  
  8017d3:	c3                   	ret    

008017d4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017da:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017dd:	50                   	push   %eax
  8017de:	ff 75 08             	pushl  0x8(%ebp)
  8017e1:	e8 22 fc ff ff       	call   801408 <fd_lookup>
  8017e6:	83 c4 08             	add    $0x8,%esp
  8017e9:	85 c0                	test   %eax,%eax
  8017eb:	78 0e                	js     8017fb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fb:	c9                   	leave  
  8017fc:	c3                   	ret    

008017fd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	53                   	push   %ebx
  801801:	83 ec 14             	sub    $0x14,%esp
  801804:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801807:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80180a:	50                   	push   %eax
  80180b:	53                   	push   %ebx
  80180c:	e8 f7 fb ff ff       	call   801408 <fd_lookup>
  801811:	83 c4 08             	add    $0x8,%esp
  801814:	89 c2                	mov    %eax,%edx
  801816:	85 c0                	test   %eax,%eax
  801818:	78 65                	js     80187f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80181a:	83 ec 08             	sub    $0x8,%esp
  80181d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801820:	50                   	push   %eax
  801821:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801824:	ff 30                	pushl  (%eax)
  801826:	e8 33 fc ff ff       	call   80145e <dev_lookup>
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	85 c0                	test   %eax,%eax
  801830:	78 44                	js     801876 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801832:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801835:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801839:	75 21                	jne    80185c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80183b:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801840:	8b 40 48             	mov    0x48(%eax),%eax
  801843:	83 ec 04             	sub    $0x4,%esp
  801846:	53                   	push   %ebx
  801847:	50                   	push   %eax
  801848:	68 00 2b 80 00       	push   $0x802b00
  80184d:	e8 99 eb ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80185a:	eb 23                	jmp    80187f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80185c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185f:	8b 52 18             	mov    0x18(%edx),%edx
  801862:	85 d2                	test   %edx,%edx
  801864:	74 14                	je     80187a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801866:	83 ec 08             	sub    $0x8,%esp
  801869:	ff 75 0c             	pushl  0xc(%ebp)
  80186c:	50                   	push   %eax
  80186d:	ff d2                	call   *%edx
  80186f:	89 c2                	mov    %eax,%edx
  801871:	83 c4 10             	add    $0x10,%esp
  801874:	eb 09                	jmp    80187f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801876:	89 c2                	mov    %eax,%edx
  801878:	eb 05                	jmp    80187f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80187a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80187f:	89 d0                	mov    %edx,%eax
  801881:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801884:	c9                   	leave  
  801885:	c3                   	ret    

00801886 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	53                   	push   %ebx
  80188a:	83 ec 14             	sub    $0x14,%esp
  80188d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801890:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801893:	50                   	push   %eax
  801894:	ff 75 08             	pushl  0x8(%ebp)
  801897:	e8 6c fb ff ff       	call   801408 <fd_lookup>
  80189c:	83 c4 08             	add    $0x8,%esp
  80189f:	89 c2                	mov    %eax,%edx
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	78 58                	js     8018fd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a5:	83 ec 08             	sub    $0x8,%esp
  8018a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ab:	50                   	push   %eax
  8018ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018af:	ff 30                	pushl  (%eax)
  8018b1:	e8 a8 fb ff ff       	call   80145e <dev_lookup>
  8018b6:	83 c4 10             	add    $0x10,%esp
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	78 37                	js     8018f4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018c4:	74 32                	je     8018f8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018c6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018c9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018d0:	00 00 00 
	stat->st_isdir = 0;
  8018d3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018da:	00 00 00 
	stat->st_dev = dev;
  8018dd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018e3:	83 ec 08             	sub    $0x8,%esp
  8018e6:	53                   	push   %ebx
  8018e7:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ea:	ff 50 14             	call   *0x14(%eax)
  8018ed:	89 c2                	mov    %eax,%edx
  8018ef:	83 c4 10             	add    $0x10,%esp
  8018f2:	eb 09                	jmp    8018fd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f4:	89 c2                	mov    %eax,%edx
  8018f6:	eb 05                	jmp    8018fd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018f8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018fd:	89 d0                	mov    %edx,%eax
  8018ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801902:	c9                   	leave  
  801903:	c3                   	ret    

00801904 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	56                   	push   %esi
  801908:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801909:	83 ec 08             	sub    $0x8,%esp
  80190c:	6a 00                	push   $0x0
  80190e:	ff 75 08             	pushl  0x8(%ebp)
  801911:	e8 2b 02 00 00       	call   801b41 <open>
  801916:	89 c3                	mov    %eax,%ebx
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	85 c0                	test   %eax,%eax
  80191d:	78 1b                	js     80193a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80191f:	83 ec 08             	sub    $0x8,%esp
  801922:	ff 75 0c             	pushl  0xc(%ebp)
  801925:	50                   	push   %eax
  801926:	e8 5b ff ff ff       	call   801886 <fstat>
  80192b:	89 c6                	mov    %eax,%esi
	close(fd);
  80192d:	89 1c 24             	mov    %ebx,(%esp)
  801930:	e8 fd fb ff ff       	call   801532 <close>
	return r;
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	89 f0                	mov    %esi,%eax
}
  80193a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193d:	5b                   	pop    %ebx
  80193e:	5e                   	pop    %esi
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    

00801941 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	56                   	push   %esi
  801945:	53                   	push   %ebx
  801946:	89 c6                	mov    %eax,%esi
  801948:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80194a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801951:	75 12                	jne    801965 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801953:	83 ec 0c             	sub    $0xc,%esp
  801956:	6a 01                	push   $0x1
  801958:	e8 04 09 00 00       	call   802261 <ipc_find_env>
  80195d:	a3 04 40 80 00       	mov    %eax,0x804004
  801962:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801965:	6a 07                	push   $0x7
  801967:	68 00 50 80 00       	push   $0x805000
  80196c:	56                   	push   %esi
  80196d:	ff 35 04 40 80 00    	pushl  0x804004
  801973:	e8 93 08 00 00       	call   80220b <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801978:	83 c4 0c             	add    $0xc,%esp
  80197b:	6a 00                	push   $0x0
  80197d:	53                   	push   %ebx
  80197e:	6a 00                	push   $0x0
  801980:	e8 1d 08 00 00       	call   8021a2 <ipc_recv>
}
  801985:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801988:	5b                   	pop    %ebx
  801989:	5e                   	pop    %esi
  80198a:	5d                   	pop    %ebp
  80198b:	c3                   	ret    

0080198c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801992:	8b 45 08             	mov    0x8(%ebp),%eax
  801995:	8b 40 0c             	mov    0xc(%eax),%eax
  801998:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80199d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019aa:	b8 02 00 00 00       	mov    $0x2,%eax
  8019af:	e8 8d ff ff ff       	call   801941 <fsipc>
}
  8019b4:	c9                   	leave  
  8019b5:	c3                   	ret    

008019b6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cc:	b8 06 00 00 00       	mov    $0x6,%eax
  8019d1:	e8 6b ff ff ff       	call   801941 <fsipc>
}
  8019d6:	c9                   	leave  
  8019d7:	c3                   	ret    

008019d8 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	53                   	push   %ebx
  8019dc:	83 ec 04             	sub    $0x4,%esp
  8019df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f2:	b8 05 00 00 00       	mov    $0x5,%eax
  8019f7:	e8 45 ff ff ff       	call   801941 <fsipc>
  8019fc:	85 c0                	test   %eax,%eax
  8019fe:	78 2c                	js     801a2c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a00:	83 ec 08             	sub    $0x8,%esp
  801a03:	68 00 50 80 00       	push   $0x805000
  801a08:	53                   	push   %ebx
  801a09:	e8 11 f0 ff ff       	call   800a1f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a0e:	a1 80 50 80 00       	mov    0x805080,%eax
  801a13:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a19:	a1 84 50 80 00       	mov    0x805084,%eax
  801a1e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2f:	c9                   	leave  
  801a30:	c3                   	ret    

00801a31 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	53                   	push   %ebx
  801a35:	83 ec 08             	sub    $0x8,%esp
  801a38:	8b 45 10             	mov    0x10(%ebp),%eax
  801a3b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a40:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801a45:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a48:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a4e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801a53:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801a59:	53                   	push   %ebx
  801a5a:	ff 75 0c             	pushl  0xc(%ebp)
  801a5d:	68 08 50 80 00       	push   $0x805008
  801a62:	e8 4a f1 ff ff       	call   800bb1 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801a67:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6c:	b8 04 00 00 00       	mov    $0x4,%eax
  801a71:	e8 cb fe ff ff       	call   801941 <fsipc>
  801a76:	83 c4 10             	add    $0x10,%esp
  801a79:	85 c0                	test   %eax,%eax
  801a7b:	78 3d                	js     801aba <devfile_write+0x89>
		return r;

	assert(r <= n);
  801a7d:	39 d8                	cmp    %ebx,%eax
  801a7f:	76 19                	jbe    801a9a <devfile_write+0x69>
  801a81:	68 6c 2b 80 00       	push   $0x802b6c
  801a86:	68 73 2b 80 00       	push   $0x802b73
  801a8b:	68 9f 00 00 00       	push   $0x9f
  801a90:	68 88 2b 80 00       	push   $0x802b88
  801a95:	e8 78 e8 ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801a9a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a9f:	76 19                	jbe    801aba <devfile_write+0x89>
  801aa1:	68 a0 2b 80 00       	push   $0x802ba0
  801aa6:	68 73 2b 80 00       	push   $0x802b73
  801aab:	68 a0 00 00 00       	push   $0xa0
  801ab0:	68 88 2b 80 00       	push   $0x802b88
  801ab5:	e8 58 e8 ff ff       	call   800312 <_panic>

	return r;
}
  801aba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abd:	c9                   	leave  
  801abe:	c3                   	ret    

00801abf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	56                   	push   %esi
  801ac3:	53                   	push   %ebx
  801ac4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aca:	8b 40 0c             	mov    0xc(%eax),%eax
  801acd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ad2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ad8:	ba 00 00 00 00       	mov    $0x0,%edx
  801add:	b8 03 00 00 00       	mov    $0x3,%eax
  801ae2:	e8 5a fe ff ff       	call   801941 <fsipc>
  801ae7:	89 c3                	mov    %eax,%ebx
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	78 4b                	js     801b38 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801aed:	39 c6                	cmp    %eax,%esi
  801aef:	73 16                	jae    801b07 <devfile_read+0x48>
  801af1:	68 6c 2b 80 00       	push   $0x802b6c
  801af6:	68 73 2b 80 00       	push   $0x802b73
  801afb:	6a 7e                	push   $0x7e
  801afd:	68 88 2b 80 00       	push   $0x802b88
  801b02:	e8 0b e8 ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  801b07:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b0c:	7e 16                	jle    801b24 <devfile_read+0x65>
  801b0e:	68 93 2b 80 00       	push   $0x802b93
  801b13:	68 73 2b 80 00       	push   $0x802b73
  801b18:	6a 7f                	push   $0x7f
  801b1a:	68 88 2b 80 00       	push   $0x802b88
  801b1f:	e8 ee e7 ff ff       	call   800312 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b24:	83 ec 04             	sub    $0x4,%esp
  801b27:	50                   	push   %eax
  801b28:	68 00 50 80 00       	push   $0x805000
  801b2d:	ff 75 0c             	pushl  0xc(%ebp)
  801b30:	e8 7c f0 ff ff       	call   800bb1 <memmove>
	return r;
  801b35:	83 c4 10             	add    $0x10,%esp
}
  801b38:	89 d8                	mov    %ebx,%eax
  801b3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b3d:	5b                   	pop    %ebx
  801b3e:	5e                   	pop    %esi
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    

00801b41 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	53                   	push   %ebx
  801b45:	83 ec 20             	sub    $0x20,%esp
  801b48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b4b:	53                   	push   %ebx
  801b4c:	e8 95 ee ff ff       	call   8009e6 <strlen>
  801b51:	83 c4 10             	add    $0x10,%esp
  801b54:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b59:	7f 67                	jg     801bc2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b5b:	83 ec 0c             	sub    $0xc,%esp
  801b5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b61:	50                   	push   %eax
  801b62:	e8 52 f8 ff ff       	call   8013b9 <fd_alloc>
  801b67:	83 c4 10             	add    $0x10,%esp
		return r;
  801b6a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b6c:	85 c0                	test   %eax,%eax
  801b6e:	78 57                	js     801bc7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b70:	83 ec 08             	sub    $0x8,%esp
  801b73:	53                   	push   %ebx
  801b74:	68 00 50 80 00       	push   $0x805000
  801b79:	e8 a1 ee ff ff       	call   800a1f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b81:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b86:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b89:	b8 01 00 00 00       	mov    $0x1,%eax
  801b8e:	e8 ae fd ff ff       	call   801941 <fsipc>
  801b93:	89 c3                	mov    %eax,%ebx
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	79 14                	jns    801bb0 <open+0x6f>
		fd_close(fd, 0);
  801b9c:	83 ec 08             	sub    $0x8,%esp
  801b9f:	6a 00                	push   $0x0
  801ba1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba4:	e8 08 f9 ff ff       	call   8014b1 <fd_close>
		return r;
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	89 da                	mov    %ebx,%edx
  801bae:	eb 17                	jmp    801bc7 <open+0x86>
	}

	return fd2num(fd);
  801bb0:	83 ec 0c             	sub    $0xc,%esp
  801bb3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb6:	e8 d7 f7 ff ff       	call   801392 <fd2num>
  801bbb:	89 c2                	mov    %eax,%edx
  801bbd:	83 c4 10             	add    $0x10,%esp
  801bc0:	eb 05                	jmp    801bc7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bc2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bc7:	89 d0                	mov    %edx,%eax
  801bc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bcc:	c9                   	leave  
  801bcd:	c3                   	ret    

00801bce <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd9:	b8 08 00 00 00       	mov    $0x8,%eax
  801bde:	e8 5e fd ff ff       	call   801941 <fsipc>
}
  801be3:	c9                   	leave  
  801be4:	c3                   	ret    

00801be5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	56                   	push   %esi
  801be9:	53                   	push   %ebx
  801bea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bed:	83 ec 0c             	sub    $0xc,%esp
  801bf0:	ff 75 08             	pushl  0x8(%ebp)
  801bf3:	e8 aa f7 ff ff       	call   8013a2 <fd2data>
  801bf8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bfa:	83 c4 08             	add    $0x8,%esp
  801bfd:	68 cd 2b 80 00       	push   $0x802bcd
  801c02:	53                   	push   %ebx
  801c03:	e8 17 ee ff ff       	call   800a1f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c08:	8b 46 04             	mov    0x4(%esi),%eax
  801c0b:	2b 06                	sub    (%esi),%eax
  801c0d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c13:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c1a:	00 00 00 
	stat->st_dev = &devpipe;
  801c1d:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801c24:	30 80 00 
	return 0;
}
  801c27:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5d                   	pop    %ebp
  801c32:	c3                   	ret    

00801c33 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	53                   	push   %ebx
  801c37:	83 ec 0c             	sub    $0xc,%esp
  801c3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c3d:	53                   	push   %ebx
  801c3e:	6a 00                	push   $0x0
  801c40:	e8 d9 f2 ff ff       	call   800f1e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c45:	89 1c 24             	mov    %ebx,(%esp)
  801c48:	e8 55 f7 ff ff       	call   8013a2 <fd2data>
  801c4d:	83 c4 08             	add    $0x8,%esp
  801c50:	50                   	push   %eax
  801c51:	6a 00                	push   $0x0
  801c53:	e8 c6 f2 ff ff       	call   800f1e <sys_page_unmap>
}
  801c58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c5b:	c9                   	leave  
  801c5c:	c3                   	ret    

00801c5d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	57                   	push   %edi
  801c61:	56                   	push   %esi
  801c62:	53                   	push   %ebx
  801c63:	83 ec 1c             	sub    $0x1c,%esp
  801c66:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c69:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c6b:	a1 08 40 80 00       	mov    0x804008,%eax
  801c70:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c73:	83 ec 0c             	sub    $0xc,%esp
  801c76:	ff 75 e0             	pushl  -0x20(%ebp)
  801c79:	e8 1c 06 00 00       	call   80229a <pageref>
  801c7e:	89 c3                	mov    %eax,%ebx
  801c80:	89 3c 24             	mov    %edi,(%esp)
  801c83:	e8 12 06 00 00       	call   80229a <pageref>
  801c88:	83 c4 10             	add    $0x10,%esp
  801c8b:	39 c3                	cmp    %eax,%ebx
  801c8d:	0f 94 c1             	sete   %cl
  801c90:	0f b6 c9             	movzbl %cl,%ecx
  801c93:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c96:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801c9c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c9f:	39 ce                	cmp    %ecx,%esi
  801ca1:	74 1b                	je     801cbe <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ca3:	39 c3                	cmp    %eax,%ebx
  801ca5:	75 c4                	jne    801c6b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ca7:	8b 42 58             	mov    0x58(%edx),%eax
  801caa:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cad:	50                   	push   %eax
  801cae:	56                   	push   %esi
  801caf:	68 d4 2b 80 00       	push   $0x802bd4
  801cb4:	e8 32 e7 ff ff       	call   8003eb <cprintf>
  801cb9:	83 c4 10             	add    $0x10,%esp
  801cbc:	eb ad                	jmp    801c6b <_pipeisclosed+0xe>
	}
}
  801cbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc4:	5b                   	pop    %ebx
  801cc5:	5e                   	pop    %esi
  801cc6:	5f                   	pop    %edi
  801cc7:	5d                   	pop    %ebp
  801cc8:	c3                   	ret    

00801cc9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	57                   	push   %edi
  801ccd:	56                   	push   %esi
  801cce:	53                   	push   %ebx
  801ccf:	83 ec 28             	sub    $0x28,%esp
  801cd2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cd5:	56                   	push   %esi
  801cd6:	e8 c7 f6 ff ff       	call   8013a2 <fd2data>
  801cdb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	bf 00 00 00 00       	mov    $0x0,%edi
  801ce5:	eb 4b                	jmp    801d32 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ce7:	89 da                	mov    %ebx,%edx
  801ce9:	89 f0                	mov    %esi,%eax
  801ceb:	e8 6d ff ff ff       	call   801c5d <_pipeisclosed>
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	75 48                	jne    801d3c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cf4:	e8 81 f1 ff ff       	call   800e7a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cf9:	8b 43 04             	mov    0x4(%ebx),%eax
  801cfc:	8b 0b                	mov    (%ebx),%ecx
  801cfe:	8d 51 20             	lea    0x20(%ecx),%edx
  801d01:	39 d0                	cmp    %edx,%eax
  801d03:	73 e2                	jae    801ce7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d08:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d0c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d0f:	89 c2                	mov    %eax,%edx
  801d11:	c1 fa 1f             	sar    $0x1f,%edx
  801d14:	89 d1                	mov    %edx,%ecx
  801d16:	c1 e9 1b             	shr    $0x1b,%ecx
  801d19:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d1c:	83 e2 1f             	and    $0x1f,%edx
  801d1f:	29 ca                	sub    %ecx,%edx
  801d21:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d25:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d29:	83 c0 01             	add    $0x1,%eax
  801d2c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d2f:	83 c7 01             	add    $0x1,%edi
  801d32:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d35:	75 c2                	jne    801cf9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d37:	8b 45 10             	mov    0x10(%ebp),%eax
  801d3a:	eb 05                	jmp    801d41 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d3c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d44:	5b                   	pop    %ebx
  801d45:	5e                   	pop    %esi
  801d46:	5f                   	pop    %edi
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    

00801d49 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	57                   	push   %edi
  801d4d:	56                   	push   %esi
  801d4e:	53                   	push   %ebx
  801d4f:	83 ec 18             	sub    $0x18,%esp
  801d52:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d55:	57                   	push   %edi
  801d56:	e8 47 f6 ff ff       	call   8013a2 <fd2data>
  801d5b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d5d:	83 c4 10             	add    $0x10,%esp
  801d60:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d65:	eb 3d                	jmp    801da4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d67:	85 db                	test   %ebx,%ebx
  801d69:	74 04                	je     801d6f <devpipe_read+0x26>
				return i;
  801d6b:	89 d8                	mov    %ebx,%eax
  801d6d:	eb 44                	jmp    801db3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d6f:	89 f2                	mov    %esi,%edx
  801d71:	89 f8                	mov    %edi,%eax
  801d73:	e8 e5 fe ff ff       	call   801c5d <_pipeisclosed>
  801d78:	85 c0                	test   %eax,%eax
  801d7a:	75 32                	jne    801dae <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d7c:	e8 f9 f0 ff ff       	call   800e7a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d81:	8b 06                	mov    (%esi),%eax
  801d83:	3b 46 04             	cmp    0x4(%esi),%eax
  801d86:	74 df                	je     801d67 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d88:	99                   	cltd   
  801d89:	c1 ea 1b             	shr    $0x1b,%edx
  801d8c:	01 d0                	add    %edx,%eax
  801d8e:	83 e0 1f             	and    $0x1f,%eax
  801d91:	29 d0                	sub    %edx,%eax
  801d93:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d9b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d9e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da1:	83 c3 01             	add    $0x1,%ebx
  801da4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801da7:	75 d8                	jne    801d81 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801da9:	8b 45 10             	mov    0x10(%ebp),%eax
  801dac:	eb 05                	jmp    801db3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dae:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801db3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db6:	5b                   	pop    %ebx
  801db7:	5e                   	pop    %esi
  801db8:	5f                   	pop    %edi
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    

00801dbb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	56                   	push   %esi
  801dbf:	53                   	push   %ebx
  801dc0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801dc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc6:	50                   	push   %eax
  801dc7:	e8 ed f5 ff ff       	call   8013b9 <fd_alloc>
  801dcc:	83 c4 10             	add    $0x10,%esp
  801dcf:	89 c2                	mov    %eax,%edx
  801dd1:	85 c0                	test   %eax,%eax
  801dd3:	0f 88 2c 01 00 00    	js     801f05 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd9:	83 ec 04             	sub    $0x4,%esp
  801ddc:	68 07 04 00 00       	push   $0x407
  801de1:	ff 75 f4             	pushl  -0xc(%ebp)
  801de4:	6a 00                	push   $0x0
  801de6:	e8 ae f0 ff ff       	call   800e99 <sys_page_alloc>
  801deb:	83 c4 10             	add    $0x10,%esp
  801dee:	89 c2                	mov    %eax,%edx
  801df0:	85 c0                	test   %eax,%eax
  801df2:	0f 88 0d 01 00 00    	js     801f05 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801df8:	83 ec 0c             	sub    $0xc,%esp
  801dfb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dfe:	50                   	push   %eax
  801dff:	e8 b5 f5 ff ff       	call   8013b9 <fd_alloc>
  801e04:	89 c3                	mov    %eax,%ebx
  801e06:	83 c4 10             	add    $0x10,%esp
  801e09:	85 c0                	test   %eax,%eax
  801e0b:	0f 88 e2 00 00 00    	js     801ef3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e11:	83 ec 04             	sub    $0x4,%esp
  801e14:	68 07 04 00 00       	push   $0x407
  801e19:	ff 75 f0             	pushl  -0x10(%ebp)
  801e1c:	6a 00                	push   $0x0
  801e1e:	e8 76 f0 ff ff       	call   800e99 <sys_page_alloc>
  801e23:	89 c3                	mov    %eax,%ebx
  801e25:	83 c4 10             	add    $0x10,%esp
  801e28:	85 c0                	test   %eax,%eax
  801e2a:	0f 88 c3 00 00 00    	js     801ef3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e30:	83 ec 0c             	sub    $0xc,%esp
  801e33:	ff 75 f4             	pushl  -0xc(%ebp)
  801e36:	e8 67 f5 ff ff       	call   8013a2 <fd2data>
  801e3b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e3d:	83 c4 0c             	add    $0xc,%esp
  801e40:	68 07 04 00 00       	push   $0x407
  801e45:	50                   	push   %eax
  801e46:	6a 00                	push   $0x0
  801e48:	e8 4c f0 ff ff       	call   800e99 <sys_page_alloc>
  801e4d:	89 c3                	mov    %eax,%ebx
  801e4f:	83 c4 10             	add    $0x10,%esp
  801e52:	85 c0                	test   %eax,%eax
  801e54:	0f 88 89 00 00 00    	js     801ee3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5a:	83 ec 0c             	sub    $0xc,%esp
  801e5d:	ff 75 f0             	pushl  -0x10(%ebp)
  801e60:	e8 3d f5 ff ff       	call   8013a2 <fd2data>
  801e65:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e6c:	50                   	push   %eax
  801e6d:	6a 00                	push   $0x0
  801e6f:	56                   	push   %esi
  801e70:	6a 00                	push   $0x0
  801e72:	e8 65 f0 ff ff       	call   800edc <sys_page_map>
  801e77:	89 c3                	mov    %eax,%ebx
  801e79:	83 c4 20             	add    $0x20,%esp
  801e7c:	85 c0                	test   %eax,%eax
  801e7e:	78 55                	js     801ed5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e80:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e89:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e95:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e9e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ea0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ea3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801eaa:	83 ec 0c             	sub    $0xc,%esp
  801ead:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb0:	e8 dd f4 ff ff       	call   801392 <fd2num>
  801eb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eb8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801eba:	83 c4 04             	add    $0x4,%esp
  801ebd:	ff 75 f0             	pushl  -0x10(%ebp)
  801ec0:	e8 cd f4 ff ff       	call   801392 <fd2num>
  801ec5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ec8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ecb:	83 c4 10             	add    $0x10,%esp
  801ece:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed3:	eb 30                	jmp    801f05 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ed5:	83 ec 08             	sub    $0x8,%esp
  801ed8:	56                   	push   %esi
  801ed9:	6a 00                	push   $0x0
  801edb:	e8 3e f0 ff ff       	call   800f1e <sys_page_unmap>
  801ee0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ee3:	83 ec 08             	sub    $0x8,%esp
  801ee6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ee9:	6a 00                	push   $0x0
  801eeb:	e8 2e f0 ff ff       	call   800f1e <sys_page_unmap>
  801ef0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ef3:	83 ec 08             	sub    $0x8,%esp
  801ef6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef9:	6a 00                	push   $0x0
  801efb:	e8 1e f0 ff ff       	call   800f1e <sys_page_unmap>
  801f00:	83 c4 10             	add    $0x10,%esp
  801f03:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f05:	89 d0                	mov    %edx,%eax
  801f07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0a:	5b                   	pop    %ebx
  801f0b:	5e                   	pop    %esi
  801f0c:	5d                   	pop    %ebp
  801f0d:	c3                   	ret    

00801f0e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f17:	50                   	push   %eax
  801f18:	ff 75 08             	pushl  0x8(%ebp)
  801f1b:	e8 e8 f4 ff ff       	call   801408 <fd_lookup>
  801f20:	83 c4 10             	add    $0x10,%esp
  801f23:	85 c0                	test   %eax,%eax
  801f25:	78 18                	js     801f3f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f27:	83 ec 0c             	sub    $0xc,%esp
  801f2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f2d:	e8 70 f4 ff ff       	call   8013a2 <fd2data>
	return _pipeisclosed(fd, p);
  801f32:	89 c2                	mov    %eax,%edx
  801f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f37:	e8 21 fd ff ff       	call   801c5d <_pipeisclosed>
  801f3c:	83 c4 10             	add    $0x10,%esp
}
  801f3f:	c9                   	leave  
  801f40:	c3                   	ret    

00801f41 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801f41:	55                   	push   %ebp
  801f42:	89 e5                	mov    %esp,%ebp
  801f44:	56                   	push   %esi
  801f45:	53                   	push   %ebx
  801f46:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801f49:	85 f6                	test   %esi,%esi
  801f4b:	75 16                	jne    801f63 <wait+0x22>
  801f4d:	68 ec 2b 80 00       	push   $0x802bec
  801f52:	68 73 2b 80 00       	push   $0x802b73
  801f57:	6a 09                	push   $0x9
  801f59:	68 f7 2b 80 00       	push   $0x802bf7
  801f5e:	e8 af e3 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  801f63:	89 f3                	mov    %esi,%ebx
  801f65:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801f6b:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801f6e:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801f74:	eb 05                	jmp    801f7b <wait+0x3a>
		sys_yield();
  801f76:	e8 ff ee ff ff       	call   800e7a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801f7b:	8b 43 48             	mov    0x48(%ebx),%eax
  801f7e:	39 c6                	cmp    %eax,%esi
  801f80:	75 07                	jne    801f89 <wait+0x48>
  801f82:	8b 43 54             	mov    0x54(%ebx),%eax
  801f85:	85 c0                	test   %eax,%eax
  801f87:	75 ed                	jne    801f76 <wait+0x35>
		sys_yield();
}
  801f89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f8c:	5b                   	pop    %ebx
  801f8d:	5e                   	pop    %esi
  801f8e:	5d                   	pop    %ebp
  801f8f:	c3                   	ret    

00801f90 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f93:	b8 00 00 00 00       	mov    $0x0,%eax
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    

00801f9a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fa0:	68 02 2c 80 00       	push   $0x802c02
  801fa5:	ff 75 0c             	pushl  0xc(%ebp)
  801fa8:	e8 72 ea ff ff       	call   800a1f <strcpy>
	return 0;
}
  801fad:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb2:	c9                   	leave  
  801fb3:	c3                   	ret    

00801fb4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	57                   	push   %edi
  801fb8:	56                   	push   %esi
  801fb9:	53                   	push   %ebx
  801fba:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fc0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fc5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fcb:	eb 2d                	jmp    801ffa <devcons_write+0x46>
		m = n - tot;
  801fcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fd0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fd2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fd5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fda:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fdd:	83 ec 04             	sub    $0x4,%esp
  801fe0:	53                   	push   %ebx
  801fe1:	03 45 0c             	add    0xc(%ebp),%eax
  801fe4:	50                   	push   %eax
  801fe5:	57                   	push   %edi
  801fe6:	e8 c6 eb ff ff       	call   800bb1 <memmove>
		sys_cputs(buf, m);
  801feb:	83 c4 08             	add    $0x8,%esp
  801fee:	53                   	push   %ebx
  801fef:	57                   	push   %edi
  801ff0:	e8 e8 ed ff ff       	call   800ddd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ff5:	01 de                	add    %ebx,%esi
  801ff7:	83 c4 10             	add    $0x10,%esp
  801ffa:	89 f0                	mov    %esi,%eax
  801ffc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fff:	72 cc                	jb     801fcd <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802001:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802004:	5b                   	pop    %ebx
  802005:	5e                   	pop    %esi
  802006:	5f                   	pop    %edi
  802007:	5d                   	pop    %ebp
  802008:	c3                   	ret    

00802009 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802009:	55                   	push   %ebp
  80200a:	89 e5                	mov    %esp,%ebp
  80200c:	83 ec 08             	sub    $0x8,%esp
  80200f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802014:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802018:	74 2a                	je     802044 <devcons_read+0x3b>
  80201a:	eb 05                	jmp    802021 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80201c:	e8 59 ee ff ff       	call   800e7a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802021:	e8 d5 ed ff ff       	call   800dfb <sys_cgetc>
  802026:	85 c0                	test   %eax,%eax
  802028:	74 f2                	je     80201c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80202a:	85 c0                	test   %eax,%eax
  80202c:	78 16                	js     802044 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80202e:	83 f8 04             	cmp    $0x4,%eax
  802031:	74 0c                	je     80203f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802033:	8b 55 0c             	mov    0xc(%ebp),%edx
  802036:	88 02                	mov    %al,(%edx)
	return 1;
  802038:	b8 01 00 00 00       	mov    $0x1,%eax
  80203d:	eb 05                	jmp    802044 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80203f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802044:	c9                   	leave  
  802045:	c3                   	ret    

00802046 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802046:	55                   	push   %ebp
  802047:	89 e5                	mov    %esp,%ebp
  802049:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80204c:	8b 45 08             	mov    0x8(%ebp),%eax
  80204f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802052:	6a 01                	push   $0x1
  802054:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802057:	50                   	push   %eax
  802058:	e8 80 ed ff ff       	call   800ddd <sys_cputs>
}
  80205d:	83 c4 10             	add    $0x10,%esp
  802060:	c9                   	leave  
  802061:	c3                   	ret    

00802062 <getchar>:

int
getchar(void)
{
  802062:	55                   	push   %ebp
  802063:	89 e5                	mov    %esp,%ebp
  802065:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802068:	6a 01                	push   $0x1
  80206a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80206d:	50                   	push   %eax
  80206e:	6a 00                	push   $0x0
  802070:	e8 f9 f5 ff ff       	call   80166e <read>
	if (r < 0)
  802075:	83 c4 10             	add    $0x10,%esp
  802078:	85 c0                	test   %eax,%eax
  80207a:	78 0f                	js     80208b <getchar+0x29>
		return r;
	if (r < 1)
  80207c:	85 c0                	test   %eax,%eax
  80207e:	7e 06                	jle    802086 <getchar+0x24>
		return -E_EOF;
	return c;
  802080:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802084:	eb 05                	jmp    80208b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802086:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80208b:	c9                   	leave  
  80208c:	c3                   	ret    

0080208d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80208d:	55                   	push   %ebp
  80208e:	89 e5                	mov    %esp,%ebp
  802090:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802093:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802096:	50                   	push   %eax
  802097:	ff 75 08             	pushl  0x8(%ebp)
  80209a:	e8 69 f3 ff ff       	call   801408 <fd_lookup>
  80209f:	83 c4 10             	add    $0x10,%esp
  8020a2:	85 c0                	test   %eax,%eax
  8020a4:	78 11                	js     8020b7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a9:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020af:	39 10                	cmp    %edx,(%eax)
  8020b1:	0f 94 c0             	sete   %al
  8020b4:	0f b6 c0             	movzbl %al,%eax
}
  8020b7:	c9                   	leave  
  8020b8:	c3                   	ret    

008020b9 <opencons>:

int
opencons(void)
{
  8020b9:	55                   	push   %ebp
  8020ba:	89 e5                	mov    %esp,%ebp
  8020bc:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c2:	50                   	push   %eax
  8020c3:	e8 f1 f2 ff ff       	call   8013b9 <fd_alloc>
  8020c8:	83 c4 10             	add    $0x10,%esp
		return r;
  8020cb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	78 3e                	js     80210f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020d1:	83 ec 04             	sub    $0x4,%esp
  8020d4:	68 07 04 00 00       	push   $0x407
  8020d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8020dc:	6a 00                	push   $0x0
  8020de:	e8 b6 ed ff ff       	call   800e99 <sys_page_alloc>
  8020e3:	83 c4 10             	add    $0x10,%esp
		return r;
  8020e6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020e8:	85 c0                	test   %eax,%eax
  8020ea:	78 23                	js     80210f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020ec:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802101:	83 ec 0c             	sub    $0xc,%esp
  802104:	50                   	push   %eax
  802105:	e8 88 f2 ff ff       	call   801392 <fd2num>
  80210a:	89 c2                	mov    %eax,%edx
  80210c:	83 c4 10             	add    $0x10,%esp
}
  80210f:	89 d0                	mov    %edx,%eax
  802111:	c9                   	leave  
  802112:	c3                   	ret    

00802113 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802113:	55                   	push   %ebp
  802114:	89 e5                	mov    %esp,%ebp
  802116:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  802119:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802120:	75 52                	jne    802174 <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  802122:	83 ec 04             	sub    $0x4,%esp
  802125:	6a 07                	push   $0x7
  802127:	68 00 f0 bf ee       	push   $0xeebff000
  80212c:	6a 00                	push   $0x0
  80212e:	e8 66 ed ff ff       	call   800e99 <sys_page_alloc>
  802133:	83 c4 10             	add    $0x10,%esp
  802136:	85 c0                	test   %eax,%eax
  802138:	79 12                	jns    80214c <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  80213a:	50                   	push   %eax
  80213b:	68 40 2a 80 00       	push   $0x802a40
  802140:	6a 23                	push   $0x23
  802142:	68 0e 2c 80 00       	push   $0x802c0e
  802147:	e8 c6 e1 ff ff       	call   800312 <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  80214c:	83 ec 08             	sub    $0x8,%esp
  80214f:	68 7e 21 80 00       	push   $0x80217e
  802154:	6a 00                	push   $0x0
  802156:	e8 89 ee ff ff       	call   800fe4 <sys_env_set_pgfault_upcall>
  80215b:	83 c4 10             	add    $0x10,%esp
  80215e:	85 c0                	test   %eax,%eax
  802160:	79 12                	jns    802174 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  802162:	50                   	push   %eax
  802163:	68 c0 2a 80 00       	push   $0x802ac0
  802168:	6a 26                	push   $0x26
  80216a:	68 0e 2c 80 00       	push   $0x802c0e
  80216f:	e8 9e e1 ff ff       	call   800312 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802174:	8b 45 08             	mov    0x8(%ebp),%eax
  802177:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80217c:	c9                   	leave  
  80217d:	c3                   	ret    

0080217e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80217e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80217f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802184:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802186:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  802189:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  80218d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  802192:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  802196:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802198:	83 c4 08             	add    $0x8,%esp
	popal 
  80219b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  80219c:	83 c4 04             	add    $0x4,%esp
	popfl
  80219f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8021a0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8021a1:	c3                   	ret    

008021a2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021a2:	55                   	push   %ebp
  8021a3:	89 e5                	mov    %esp,%ebp
  8021a5:	56                   	push   %esi
  8021a6:	53                   	push   %ebx
  8021a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8021aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  8021b0:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8021b2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8021b7:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  8021ba:	83 ec 0c             	sub    $0xc,%esp
  8021bd:	50                   	push   %eax
  8021be:	e8 86 ee ff ff       	call   801049 <sys_ipc_recv>
  8021c3:	83 c4 10             	add    $0x10,%esp
  8021c6:	85 c0                	test   %eax,%eax
  8021c8:	79 16                	jns    8021e0 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  8021ca:	85 f6                	test   %esi,%esi
  8021cc:	74 06                	je     8021d4 <ipc_recv+0x32>
			*from_env_store = 0;
  8021ce:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  8021d4:	85 db                	test   %ebx,%ebx
  8021d6:	74 2c                	je     802204 <ipc_recv+0x62>
			*perm_store = 0;
  8021d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8021de:	eb 24                	jmp    802204 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  8021e0:	85 f6                	test   %esi,%esi
  8021e2:	74 0a                	je     8021ee <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  8021e4:	a1 08 40 80 00       	mov    0x804008,%eax
  8021e9:	8b 40 74             	mov    0x74(%eax),%eax
  8021ec:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  8021ee:	85 db                	test   %ebx,%ebx
  8021f0:	74 0a                	je     8021fc <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  8021f2:	a1 08 40 80 00       	mov    0x804008,%eax
  8021f7:	8b 40 78             	mov    0x78(%eax),%eax
  8021fa:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  8021fc:	a1 08 40 80 00       	mov    0x804008,%eax
  802201:	8b 40 70             	mov    0x70(%eax),%eax
}
  802204:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802207:	5b                   	pop    %ebx
  802208:	5e                   	pop    %esi
  802209:	5d                   	pop    %ebp
  80220a:	c3                   	ret    

0080220b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80220b:	55                   	push   %ebp
  80220c:	89 e5                	mov    %esp,%ebp
  80220e:	57                   	push   %edi
  80220f:	56                   	push   %esi
  802210:	53                   	push   %ebx
  802211:	83 ec 0c             	sub    $0xc,%esp
  802214:	8b 7d 08             	mov    0x8(%ebp),%edi
  802217:	8b 75 0c             	mov    0xc(%ebp),%esi
  80221a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  80221d:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80221f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802224:	0f 44 d8             	cmove  %eax,%ebx
  802227:	eb 1e                	jmp    802247 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  802229:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80222c:	74 14                	je     802242 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  80222e:	83 ec 04             	sub    $0x4,%esp
  802231:	68 1c 2c 80 00       	push   $0x802c1c
  802236:	6a 44                	push   $0x44
  802238:	68 48 2c 80 00       	push   $0x802c48
  80223d:	e8 d0 e0 ff ff       	call   800312 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  802242:	e8 33 ec ff ff       	call   800e7a <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802247:	ff 75 14             	pushl  0x14(%ebp)
  80224a:	53                   	push   %ebx
  80224b:	56                   	push   %esi
  80224c:	57                   	push   %edi
  80224d:	e8 d4 ed ff ff       	call   801026 <sys_ipc_try_send>
  802252:	83 c4 10             	add    $0x10,%esp
  802255:	85 c0                	test   %eax,%eax
  802257:	78 d0                	js     802229 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  802259:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80225c:	5b                   	pop    %ebx
  80225d:	5e                   	pop    %esi
  80225e:	5f                   	pop    %edi
  80225f:	5d                   	pop    %ebp
  802260:	c3                   	ret    

00802261 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802261:	55                   	push   %ebp
  802262:	89 e5                	mov    %esp,%ebp
  802264:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802267:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80226c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80226f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802275:	8b 52 50             	mov    0x50(%edx),%edx
  802278:	39 ca                	cmp    %ecx,%edx
  80227a:	75 0d                	jne    802289 <ipc_find_env+0x28>
			return envs[i].env_id;
  80227c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80227f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802284:	8b 40 48             	mov    0x48(%eax),%eax
  802287:	eb 0f                	jmp    802298 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802289:	83 c0 01             	add    $0x1,%eax
  80228c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802291:	75 d9                	jne    80226c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802293:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802298:	5d                   	pop    %ebp
  802299:	c3                   	ret    

0080229a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80229a:	55                   	push   %ebp
  80229b:	89 e5                	mov    %esp,%ebp
  80229d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022a0:	89 d0                	mov    %edx,%eax
  8022a2:	c1 e8 16             	shr    $0x16,%eax
  8022a5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022ac:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022b1:	f6 c1 01             	test   $0x1,%cl
  8022b4:	74 1d                	je     8022d3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022b6:	c1 ea 0c             	shr    $0xc,%edx
  8022b9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022c0:	f6 c2 01             	test   $0x1,%dl
  8022c3:	74 0e                	je     8022d3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022c5:	c1 ea 0c             	shr    $0xc,%edx
  8022c8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8022cf:	ef 
  8022d0:	0f b7 c0             	movzwl %ax,%eax
}
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    
  8022d5:	66 90                	xchg   %ax,%ax
  8022d7:	66 90                	xchg   %ax,%ax
  8022d9:	66 90                	xchg   %ax,%ax
  8022db:	66 90                	xchg   %ax,%ax
  8022dd:	66 90                	xchg   %ax,%ax
  8022df:	90                   	nop

008022e0 <__udivdi3>:
  8022e0:	55                   	push   %ebp
  8022e1:	57                   	push   %edi
  8022e2:	56                   	push   %esi
  8022e3:	53                   	push   %ebx
  8022e4:	83 ec 1c             	sub    $0x1c,%esp
  8022e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8022eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8022ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8022f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022f7:	85 f6                	test   %esi,%esi
  8022f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022fd:	89 ca                	mov    %ecx,%edx
  8022ff:	89 f8                	mov    %edi,%eax
  802301:	75 3d                	jne    802340 <__udivdi3+0x60>
  802303:	39 cf                	cmp    %ecx,%edi
  802305:	0f 87 c5 00 00 00    	ja     8023d0 <__udivdi3+0xf0>
  80230b:	85 ff                	test   %edi,%edi
  80230d:	89 fd                	mov    %edi,%ebp
  80230f:	75 0b                	jne    80231c <__udivdi3+0x3c>
  802311:	b8 01 00 00 00       	mov    $0x1,%eax
  802316:	31 d2                	xor    %edx,%edx
  802318:	f7 f7                	div    %edi
  80231a:	89 c5                	mov    %eax,%ebp
  80231c:	89 c8                	mov    %ecx,%eax
  80231e:	31 d2                	xor    %edx,%edx
  802320:	f7 f5                	div    %ebp
  802322:	89 c1                	mov    %eax,%ecx
  802324:	89 d8                	mov    %ebx,%eax
  802326:	89 cf                	mov    %ecx,%edi
  802328:	f7 f5                	div    %ebp
  80232a:	89 c3                	mov    %eax,%ebx
  80232c:	89 d8                	mov    %ebx,%eax
  80232e:	89 fa                	mov    %edi,%edx
  802330:	83 c4 1c             	add    $0x1c,%esp
  802333:	5b                   	pop    %ebx
  802334:	5e                   	pop    %esi
  802335:	5f                   	pop    %edi
  802336:	5d                   	pop    %ebp
  802337:	c3                   	ret    
  802338:	90                   	nop
  802339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802340:	39 ce                	cmp    %ecx,%esi
  802342:	77 74                	ja     8023b8 <__udivdi3+0xd8>
  802344:	0f bd fe             	bsr    %esi,%edi
  802347:	83 f7 1f             	xor    $0x1f,%edi
  80234a:	0f 84 98 00 00 00    	je     8023e8 <__udivdi3+0x108>
  802350:	bb 20 00 00 00       	mov    $0x20,%ebx
  802355:	89 f9                	mov    %edi,%ecx
  802357:	89 c5                	mov    %eax,%ebp
  802359:	29 fb                	sub    %edi,%ebx
  80235b:	d3 e6                	shl    %cl,%esi
  80235d:	89 d9                	mov    %ebx,%ecx
  80235f:	d3 ed                	shr    %cl,%ebp
  802361:	89 f9                	mov    %edi,%ecx
  802363:	d3 e0                	shl    %cl,%eax
  802365:	09 ee                	or     %ebp,%esi
  802367:	89 d9                	mov    %ebx,%ecx
  802369:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80236d:	89 d5                	mov    %edx,%ebp
  80236f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802373:	d3 ed                	shr    %cl,%ebp
  802375:	89 f9                	mov    %edi,%ecx
  802377:	d3 e2                	shl    %cl,%edx
  802379:	89 d9                	mov    %ebx,%ecx
  80237b:	d3 e8                	shr    %cl,%eax
  80237d:	09 c2                	or     %eax,%edx
  80237f:	89 d0                	mov    %edx,%eax
  802381:	89 ea                	mov    %ebp,%edx
  802383:	f7 f6                	div    %esi
  802385:	89 d5                	mov    %edx,%ebp
  802387:	89 c3                	mov    %eax,%ebx
  802389:	f7 64 24 0c          	mull   0xc(%esp)
  80238d:	39 d5                	cmp    %edx,%ebp
  80238f:	72 10                	jb     8023a1 <__udivdi3+0xc1>
  802391:	8b 74 24 08          	mov    0x8(%esp),%esi
  802395:	89 f9                	mov    %edi,%ecx
  802397:	d3 e6                	shl    %cl,%esi
  802399:	39 c6                	cmp    %eax,%esi
  80239b:	73 07                	jae    8023a4 <__udivdi3+0xc4>
  80239d:	39 d5                	cmp    %edx,%ebp
  80239f:	75 03                	jne    8023a4 <__udivdi3+0xc4>
  8023a1:	83 eb 01             	sub    $0x1,%ebx
  8023a4:	31 ff                	xor    %edi,%edi
  8023a6:	89 d8                	mov    %ebx,%eax
  8023a8:	89 fa                	mov    %edi,%edx
  8023aa:	83 c4 1c             	add    $0x1c,%esp
  8023ad:	5b                   	pop    %ebx
  8023ae:	5e                   	pop    %esi
  8023af:	5f                   	pop    %edi
  8023b0:	5d                   	pop    %ebp
  8023b1:	c3                   	ret    
  8023b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023b8:	31 ff                	xor    %edi,%edi
  8023ba:	31 db                	xor    %ebx,%ebx
  8023bc:	89 d8                	mov    %ebx,%eax
  8023be:	89 fa                	mov    %edi,%edx
  8023c0:	83 c4 1c             	add    $0x1c,%esp
  8023c3:	5b                   	pop    %ebx
  8023c4:	5e                   	pop    %esi
  8023c5:	5f                   	pop    %edi
  8023c6:	5d                   	pop    %ebp
  8023c7:	c3                   	ret    
  8023c8:	90                   	nop
  8023c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	89 d8                	mov    %ebx,%eax
  8023d2:	f7 f7                	div    %edi
  8023d4:	31 ff                	xor    %edi,%edi
  8023d6:	89 c3                	mov    %eax,%ebx
  8023d8:	89 d8                	mov    %ebx,%eax
  8023da:	89 fa                	mov    %edi,%edx
  8023dc:	83 c4 1c             	add    $0x1c,%esp
  8023df:	5b                   	pop    %ebx
  8023e0:	5e                   	pop    %esi
  8023e1:	5f                   	pop    %edi
  8023e2:	5d                   	pop    %ebp
  8023e3:	c3                   	ret    
  8023e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e8:	39 ce                	cmp    %ecx,%esi
  8023ea:	72 0c                	jb     8023f8 <__udivdi3+0x118>
  8023ec:	31 db                	xor    %ebx,%ebx
  8023ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8023f2:	0f 87 34 ff ff ff    	ja     80232c <__udivdi3+0x4c>
  8023f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8023fd:	e9 2a ff ff ff       	jmp    80232c <__udivdi3+0x4c>
  802402:	66 90                	xchg   %ax,%ax
  802404:	66 90                	xchg   %ax,%ax
  802406:	66 90                	xchg   %ax,%ax
  802408:	66 90                	xchg   %ax,%ax
  80240a:	66 90                	xchg   %ax,%ax
  80240c:	66 90                	xchg   %ax,%ax
  80240e:	66 90                	xchg   %ax,%ax

00802410 <__umoddi3>:
  802410:	55                   	push   %ebp
  802411:	57                   	push   %edi
  802412:	56                   	push   %esi
  802413:	53                   	push   %ebx
  802414:	83 ec 1c             	sub    $0x1c,%esp
  802417:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80241b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80241f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802423:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802427:	85 d2                	test   %edx,%edx
  802429:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80242d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802431:	89 f3                	mov    %esi,%ebx
  802433:	89 3c 24             	mov    %edi,(%esp)
  802436:	89 74 24 04          	mov    %esi,0x4(%esp)
  80243a:	75 1c                	jne    802458 <__umoddi3+0x48>
  80243c:	39 f7                	cmp    %esi,%edi
  80243e:	76 50                	jbe    802490 <__umoddi3+0x80>
  802440:	89 c8                	mov    %ecx,%eax
  802442:	89 f2                	mov    %esi,%edx
  802444:	f7 f7                	div    %edi
  802446:	89 d0                	mov    %edx,%eax
  802448:	31 d2                	xor    %edx,%edx
  80244a:	83 c4 1c             	add    $0x1c,%esp
  80244d:	5b                   	pop    %ebx
  80244e:	5e                   	pop    %esi
  80244f:	5f                   	pop    %edi
  802450:	5d                   	pop    %ebp
  802451:	c3                   	ret    
  802452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802458:	39 f2                	cmp    %esi,%edx
  80245a:	89 d0                	mov    %edx,%eax
  80245c:	77 52                	ja     8024b0 <__umoddi3+0xa0>
  80245e:	0f bd ea             	bsr    %edx,%ebp
  802461:	83 f5 1f             	xor    $0x1f,%ebp
  802464:	75 5a                	jne    8024c0 <__umoddi3+0xb0>
  802466:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80246a:	0f 82 e0 00 00 00    	jb     802550 <__umoddi3+0x140>
  802470:	39 0c 24             	cmp    %ecx,(%esp)
  802473:	0f 86 d7 00 00 00    	jbe    802550 <__umoddi3+0x140>
  802479:	8b 44 24 08          	mov    0x8(%esp),%eax
  80247d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802481:	83 c4 1c             	add    $0x1c,%esp
  802484:	5b                   	pop    %ebx
  802485:	5e                   	pop    %esi
  802486:	5f                   	pop    %edi
  802487:	5d                   	pop    %ebp
  802488:	c3                   	ret    
  802489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802490:	85 ff                	test   %edi,%edi
  802492:	89 fd                	mov    %edi,%ebp
  802494:	75 0b                	jne    8024a1 <__umoddi3+0x91>
  802496:	b8 01 00 00 00       	mov    $0x1,%eax
  80249b:	31 d2                	xor    %edx,%edx
  80249d:	f7 f7                	div    %edi
  80249f:	89 c5                	mov    %eax,%ebp
  8024a1:	89 f0                	mov    %esi,%eax
  8024a3:	31 d2                	xor    %edx,%edx
  8024a5:	f7 f5                	div    %ebp
  8024a7:	89 c8                	mov    %ecx,%eax
  8024a9:	f7 f5                	div    %ebp
  8024ab:	89 d0                	mov    %edx,%eax
  8024ad:	eb 99                	jmp    802448 <__umoddi3+0x38>
  8024af:	90                   	nop
  8024b0:	89 c8                	mov    %ecx,%eax
  8024b2:	89 f2                	mov    %esi,%edx
  8024b4:	83 c4 1c             	add    $0x1c,%esp
  8024b7:	5b                   	pop    %ebx
  8024b8:	5e                   	pop    %esi
  8024b9:	5f                   	pop    %edi
  8024ba:	5d                   	pop    %ebp
  8024bb:	c3                   	ret    
  8024bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024c0:	8b 34 24             	mov    (%esp),%esi
  8024c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8024c8:	89 e9                	mov    %ebp,%ecx
  8024ca:	29 ef                	sub    %ebp,%edi
  8024cc:	d3 e0                	shl    %cl,%eax
  8024ce:	89 f9                	mov    %edi,%ecx
  8024d0:	89 f2                	mov    %esi,%edx
  8024d2:	d3 ea                	shr    %cl,%edx
  8024d4:	89 e9                	mov    %ebp,%ecx
  8024d6:	09 c2                	or     %eax,%edx
  8024d8:	89 d8                	mov    %ebx,%eax
  8024da:	89 14 24             	mov    %edx,(%esp)
  8024dd:	89 f2                	mov    %esi,%edx
  8024df:	d3 e2                	shl    %cl,%edx
  8024e1:	89 f9                	mov    %edi,%ecx
  8024e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024eb:	d3 e8                	shr    %cl,%eax
  8024ed:	89 e9                	mov    %ebp,%ecx
  8024ef:	89 c6                	mov    %eax,%esi
  8024f1:	d3 e3                	shl    %cl,%ebx
  8024f3:	89 f9                	mov    %edi,%ecx
  8024f5:	89 d0                	mov    %edx,%eax
  8024f7:	d3 e8                	shr    %cl,%eax
  8024f9:	89 e9                	mov    %ebp,%ecx
  8024fb:	09 d8                	or     %ebx,%eax
  8024fd:	89 d3                	mov    %edx,%ebx
  8024ff:	89 f2                	mov    %esi,%edx
  802501:	f7 34 24             	divl   (%esp)
  802504:	89 d6                	mov    %edx,%esi
  802506:	d3 e3                	shl    %cl,%ebx
  802508:	f7 64 24 04          	mull   0x4(%esp)
  80250c:	39 d6                	cmp    %edx,%esi
  80250e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802512:	89 d1                	mov    %edx,%ecx
  802514:	89 c3                	mov    %eax,%ebx
  802516:	72 08                	jb     802520 <__umoddi3+0x110>
  802518:	75 11                	jne    80252b <__umoddi3+0x11b>
  80251a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80251e:	73 0b                	jae    80252b <__umoddi3+0x11b>
  802520:	2b 44 24 04          	sub    0x4(%esp),%eax
  802524:	1b 14 24             	sbb    (%esp),%edx
  802527:	89 d1                	mov    %edx,%ecx
  802529:	89 c3                	mov    %eax,%ebx
  80252b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80252f:	29 da                	sub    %ebx,%edx
  802531:	19 ce                	sbb    %ecx,%esi
  802533:	89 f9                	mov    %edi,%ecx
  802535:	89 f0                	mov    %esi,%eax
  802537:	d3 e0                	shl    %cl,%eax
  802539:	89 e9                	mov    %ebp,%ecx
  80253b:	d3 ea                	shr    %cl,%edx
  80253d:	89 e9                	mov    %ebp,%ecx
  80253f:	d3 ee                	shr    %cl,%esi
  802541:	09 d0                	or     %edx,%eax
  802543:	89 f2                	mov    %esi,%edx
  802545:	83 c4 1c             	add    $0x1c,%esp
  802548:	5b                   	pop    %ebx
  802549:	5e                   	pop    %esi
  80254a:	5f                   	pop    %edi
  80254b:	5d                   	pop    %ebp
  80254c:	c3                   	ret    
  80254d:	8d 76 00             	lea    0x0(%esi),%esi
  802550:	29 f9                	sub    %edi,%ecx
  802552:	19 d6                	sbb    %edx,%esi
  802554:	89 74 24 04          	mov    %esi,0x4(%esp)
  802558:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80255c:	e9 18 ff ff ff       	jmp    802479 <__umoddi3+0x69>
