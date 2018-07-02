
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 07 02 00 00       	call   800238 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 34 16 00 00       	call   801685 <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 20                	je     800079 <primeproc+0x46>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	85 c0                	test   %eax,%eax
  80005e:	ba 00 00 00 00       	mov    $0x0,%edx
  800063:	0f 4e d0             	cmovle %eax,%edx
  800066:	52                   	push   %edx
  800067:	50                   	push   %eax
  800068:	68 a0 24 80 00       	push   $0x8024a0
  80006d:	6a 15                	push   $0x15
  80006f:	68 cf 24 80 00       	push   $0x8024cf
  800074:	e8 1f 02 00 00       	call   800298 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 e1 24 80 00       	push   $0x8024e1
  800084:	e8 e8 02 00 00       	call   800371 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 b0 1c 00 00       	call   801d41 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 e5 24 80 00       	push   $0x8024e5
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 cf 24 80 00       	push   $0x8024cf
  8000a8:	e8 eb 01 00 00       	call   800298 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 34 10 00 00       	call   8010e6 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 fe 28 80 00       	push   $0x8028fe
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 cf 24 80 00       	push   $0x8024cf
  8000c3:	e8 d0 01 00 00       	call   800298 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 e3 13 00 00       	call   8014b8 <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 d8 13 00 00       	call   8014b8 <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 c2 13 00 00       	call   8014b8 <close>
	wfd = pfd[1];
  8000f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f9:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fc:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000ff:	83 ec 04             	sub    $0x4,%esp
  800102:	6a 04                	push   $0x4
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 7a 15 00 00       	call   801685 <readn>
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	83 f8 04             	cmp    $0x4,%eax
  800111:	74 24                	je     800137 <primeproc+0x104>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800113:	83 ec 04             	sub    $0x4,%esp
  800116:	85 c0                	test   %eax,%eax
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	0f 4e d0             	cmovle %eax,%edx
  800120:	52                   	push   %edx
  800121:	50                   	push   %eax
  800122:	53                   	push   %ebx
  800123:	ff 75 e0             	pushl  -0x20(%ebp)
  800126:	68 ee 24 80 00       	push   $0x8024ee
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 cf 24 80 00       	push   $0x8024cf
  800132:	e8 61 01 00 00       	call   800298 <_panic>
		if (i%p)
  800137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013a:	99                   	cltd   
  80013b:	f7 7d e0             	idivl  -0x20(%ebp)
  80013e:	85 d2                	test   %edx,%edx
  800140:	74 bd                	je     8000ff <primeproc+0xcc>
			if ((r=write(wfd, &i, 4)) != 4)
  800142:	83 ec 04             	sub    $0x4,%esp
  800145:	6a 04                	push   $0x4
  800147:	56                   	push   %esi
  800148:	57                   	push   %edi
  800149:	e8 80 15 00 00       	call   8016ce <write>
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	83 f8 04             	cmp    $0x4,%eax
  800154:	74 a9                	je     8000ff <primeproc+0xcc>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800156:	83 ec 08             	sub    $0x8,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	0f 4e d0             	cmovle %eax,%edx
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	68 0a 25 80 00       	push   $0x80250a
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 cf 24 80 00       	push   $0x8024cf
  800174:	e8 1f 01 00 00       	call   800298 <_panic>

00800179 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800180:	c7 05 00 30 80 00 24 	movl   $0x802524,0x803000
  800187:	25 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 ae 1b 00 00       	call   801d41 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 e5 24 80 00       	push   $0x8024e5
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 cf 24 80 00       	push   $0x8024cf
  8001aa:	e8 e9 00 00 00       	call   800298 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 32 0f 00 00       	call   8010e6 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 fe 28 80 00       	push   $0x8028fe
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 cf 24 80 00       	push   $0x8024cf
  8001c5:	e8 ce 00 00 00       	call   800298 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 df 12 00 00       	call   8014b8 <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 c9 12 00 00       	call   8014b8 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ef:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f6:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f9:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	6a 04                	push   $0x4
  800201:	53                   	push   %ebx
  800202:	ff 75 f0             	pushl  -0x10(%ebp)
  800205:	e8 c4 14 00 00       	call   8016ce <write>
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	83 f8 04             	cmp    $0x4,%eax
  800210:	74 20                	je     800232 <umain+0xb9>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	85 c0                	test   %eax,%eax
  800217:	ba 00 00 00 00       	mov    $0x0,%edx
  80021c:	0f 4e d0             	cmovle %eax,%edx
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	68 2f 25 80 00       	push   $0x80252f
  800226:	6a 4a                	push   $0x4a
  800228:	68 cf 24 80 00       	push   $0x8024cf
  80022d:	e8 66 00 00 00       	call   800298 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  800236:	eb c4                	jmp    8001fc <umain+0x83>

00800238 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800240:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800243:	e8 99 0b 00 00       	call   800de1 <sys_getenvid>
  800248:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800250:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800255:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7e 07                	jle    800265 <libmain+0x2d>
		binaryname = argv[0];
  80025e:	8b 06                	mov    (%esi),%eax
  800260:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	e8 0a ff ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  80026f:	e8 0a 00 00 00       	call   80027e <exit>
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800284:	e8 5a 12 00 00       	call   8014e3 <close_all>
	sys_env_destroy(0);
  800289:	83 ec 0c             	sub    $0xc,%esp
  80028c:	6a 00                	push   $0x0
  80028e:	e8 0d 0b 00 00       	call   800da0 <sys_env_destroy>
}
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a6:	e8 36 0b 00 00       	call   800de1 <sys_getenvid>
  8002ab:	83 ec 0c             	sub    $0xc,%esp
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	ff 75 08             	pushl  0x8(%ebp)
  8002b4:	56                   	push   %esi
  8002b5:	50                   	push   %eax
  8002b6:	68 54 25 80 00       	push   $0x802554
  8002bb:	e8 b1 00 00 00       	call   800371 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	83 c4 18             	add    $0x18,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	e8 54 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  8002cc:	c7 04 24 e3 24 80 00 	movl   $0x8024e3,(%esp)
  8002d3:	e8 99 00 00 00       	call   800371 <cprintf>
  8002d8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002db:	cc                   	int3   
  8002dc:	eb fd                	jmp    8002db <_panic+0x43>

008002de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 04             	sub    $0x4,%esp
  8002e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e8:	8b 13                	mov    (%ebx),%edx
  8002ea:	8d 42 01             	lea    0x1(%edx),%eax
  8002ed:	89 03                	mov    %eax,(%ebx)
  8002ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002fb:	75 1a                	jne    800317 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	68 ff 00 00 00       	push   $0xff
  800305:	8d 43 08             	lea    0x8(%ebx),%eax
  800308:	50                   	push   %eax
  800309:	e8 55 0a 00 00       	call   800d63 <sys_cputs>
		b->idx = 0;
  80030e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800314:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800317:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80031b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800329:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800330:	00 00 00 
	b.cnt = 0;
  800333:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033d:	ff 75 0c             	pushl  0xc(%ebp)
  800340:	ff 75 08             	pushl  0x8(%ebp)
  800343:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800349:	50                   	push   %eax
  80034a:	68 de 02 80 00       	push   $0x8002de
  80034f:	e8 54 01 00 00       	call   8004a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800354:	83 c4 08             	add    $0x8,%esp
  800357:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800363:	50                   	push   %eax
  800364:	e8 fa 09 00 00       	call   800d63 <sys_cputs>

	return b.cnt;
}
  800369:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800377:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80037a:	50                   	push   %eax
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 9d ff ff ff       	call   800320 <vcprintf>
	va_end(ap);

	return cnt;
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 1c             	sub    $0x1c,%esp
  80038e:	89 c7                	mov    %eax,%edi
  800390:	89 d6                	mov    %edx,%esi
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	8b 55 0c             	mov    0xc(%ebp),%edx
  800398:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ac:	39 d3                	cmp    %edx,%ebx
  8003ae:	72 05                	jb     8003b5 <printnum+0x30>
  8003b0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b3:	77 45                	ja     8003fa <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b5:	83 ec 0c             	sub    $0xc,%esp
  8003b8:	ff 75 18             	pushl  0x18(%ebp)
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c1:	53                   	push   %ebx
  8003c2:	ff 75 10             	pushl  0x10(%ebp)
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d4:	e8 37 1e 00 00       	call   802210 <__udivdi3>
  8003d9:	83 c4 18             	add    $0x18,%esp
  8003dc:	52                   	push   %edx
  8003dd:	50                   	push   %eax
  8003de:	89 f2                	mov    %esi,%edx
  8003e0:	89 f8                	mov    %edi,%eax
  8003e2:	e8 9e ff ff ff       	call   800385 <printnum>
  8003e7:	83 c4 20             	add    $0x20,%esp
  8003ea:	eb 18                	jmp    800404 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	56                   	push   %esi
  8003f0:	ff 75 18             	pushl  0x18(%ebp)
  8003f3:	ff d7                	call   *%edi
  8003f5:	83 c4 10             	add    $0x10,%esp
  8003f8:	eb 03                	jmp    8003fd <printnum+0x78>
  8003fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fd:	83 eb 01             	sub    $0x1,%ebx
  800400:	85 db                	test   %ebx,%ebx
  800402:	7f e8                	jg     8003ec <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	56                   	push   %esi
  800408:	83 ec 04             	sub    $0x4,%esp
  80040b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040e:	ff 75 e0             	pushl  -0x20(%ebp)
  800411:	ff 75 dc             	pushl  -0x24(%ebp)
  800414:	ff 75 d8             	pushl  -0x28(%ebp)
  800417:	e8 24 1f 00 00       	call   802340 <__umoddi3>
  80041c:	83 c4 14             	add    $0x14,%esp
  80041f:	0f be 80 77 25 80 00 	movsbl 0x802577(%eax),%eax
  800426:	50                   	push   %eax
  800427:	ff d7                	call   *%edi
}
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042f:	5b                   	pop    %ebx
  800430:	5e                   	pop    %esi
  800431:	5f                   	pop    %edi
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800437:	83 fa 01             	cmp    $0x1,%edx
  80043a:	7e 0e                	jle    80044a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80043c:	8b 10                	mov    (%eax),%edx
  80043e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800441:	89 08                	mov    %ecx,(%eax)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	8b 52 04             	mov    0x4(%edx),%edx
  800448:	eb 22                	jmp    80046c <getuint+0x38>
	else if (lflag)
  80044a:	85 d2                	test   %edx,%edx
  80044c:	74 10                	je     80045e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80044e:	8b 10                	mov    (%eax),%edx
  800450:	8d 4a 04             	lea    0x4(%edx),%ecx
  800453:	89 08                	mov    %ecx,(%eax)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	ba 00 00 00 00       	mov    $0x0,%edx
  80045c:	eb 0e                	jmp    80046c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80045e:	8b 10                	mov    (%eax),%edx
  800460:	8d 4a 04             	lea    0x4(%edx),%ecx
  800463:	89 08                	mov    %ecx,(%eax)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    

0080046e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800474:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800478:	8b 10                	mov    (%eax),%edx
  80047a:	3b 50 04             	cmp    0x4(%eax),%edx
  80047d:	73 0a                	jae    800489 <sprintputch+0x1b>
		*b->buf++ = ch;
  80047f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800482:	89 08                	mov    %ecx,(%eax)
  800484:	8b 45 08             	mov    0x8(%ebp),%eax
  800487:	88 02                	mov    %al,(%edx)
}
  800489:	5d                   	pop    %ebp
  80048a:	c3                   	ret    

0080048b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800491:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800494:	50                   	push   %eax
  800495:	ff 75 10             	pushl  0x10(%ebp)
  800498:	ff 75 0c             	pushl  0xc(%ebp)
  80049b:	ff 75 08             	pushl  0x8(%ebp)
  80049e:	e8 05 00 00 00       	call   8004a8 <vprintfmt>
	va_end(ap);
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	c9                   	leave  
  8004a7:	c3                   	ret    

008004a8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	57                   	push   %edi
  8004ac:	56                   	push   %esi
  8004ad:	53                   	push   %ebx
  8004ae:	83 ec 2c             	sub    $0x2c,%esp
  8004b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ba:	eb 12                	jmp    8004ce <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	0f 84 38 04 00 00    	je     8008fc <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	53                   	push   %ebx
  8004c8:	50                   	push   %eax
  8004c9:	ff d6                	call   *%esi
  8004cb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ce:	83 c7 01             	add    $0x1,%edi
  8004d1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d5:	83 f8 25             	cmp    $0x25,%eax
  8004d8:	75 e2                	jne    8004bc <vprintfmt+0x14>
  8004da:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004de:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004e5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004ec:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f8:	eb 07                	jmp    800501 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8004fd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8d 47 01             	lea    0x1(%edi),%eax
  800504:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800507:	0f b6 07             	movzbl (%edi),%eax
  80050a:	0f b6 c8             	movzbl %al,%ecx
  80050d:	83 e8 23             	sub    $0x23,%eax
  800510:	3c 55                	cmp    $0x55,%al
  800512:	0f 87 c9 03 00 00    	ja     8008e1 <vprintfmt+0x439>
  800518:	0f b6 c0             	movzbl %al,%eax
  80051b:	ff 24 85 c0 26 80 00 	jmp    *0x8026c0(,%eax,4)
  800522:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800525:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800529:	eb d6                	jmp    800501 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  80052b:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  800532:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800535:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  800538:	eb 94                	jmp    8004ce <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  80053a:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  800541:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800544:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  800547:	eb 85                	jmp    8004ce <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  800549:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  800550:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800553:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  800556:	e9 73 ff ff ff       	jmp    8004ce <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  80055b:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  800562:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800565:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  800568:	e9 61 ff ff ff       	jmp    8004ce <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  80056d:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800574:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800577:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  80057a:	e9 4f ff ff ff       	jmp    8004ce <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80057f:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800586:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800589:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80058c:	e9 3d ff ff ff       	jmp    8004ce <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  800591:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  800598:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80059e:	e9 2b ff ff ff       	jmp    8004ce <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  8005a3:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  8005aa:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8005b0:	e9 19 ff ff ff       	jmp    8004ce <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  8005b5:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  8005bc:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8005c2:	e9 07 ff ff ff       	jmp    8004ce <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8005c7:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  8005ce:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8005d4:	e9 f5 fe ff ff       	jmp    8004ce <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005e7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005eb:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005ee:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005f1:	83 fa 09             	cmp    $0x9,%edx
  8005f4:	77 3f                	ja     800635 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005f6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005f9:	eb e9                	jmp    8005e4 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 48 04             	lea    0x4(%eax),%ecx
  800601:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800604:	8b 00                	mov    (%eax),%eax
  800606:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800609:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80060c:	eb 2d                	jmp    80063b <vprintfmt+0x193>
  80060e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800611:	85 c0                	test   %eax,%eax
  800613:	b9 00 00 00 00       	mov    $0x0,%ecx
  800618:	0f 49 c8             	cmovns %eax,%ecx
  80061b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800621:	e9 db fe ff ff       	jmp    800501 <vprintfmt+0x59>
  800626:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800629:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800630:	e9 cc fe ff ff       	jmp    800501 <vprintfmt+0x59>
  800635:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800638:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80063b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80063f:	0f 89 bc fe ff ff    	jns    800501 <vprintfmt+0x59>
				width = precision, precision = -1;
  800645:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800648:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80064b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800652:	e9 aa fe ff ff       	jmp    800501 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800657:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80065d:	e9 9f fe ff ff       	jmp    800501 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 50 04             	lea    0x4(%eax),%edx
  800668:	89 55 14             	mov    %edx,0x14(%ebp)
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	ff 30                	pushl  (%eax)
  800671:	ff d6                	call   *%esi
			break;
  800673:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800676:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800679:	e9 50 fe ff ff       	jmp    8004ce <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 50 04             	lea    0x4(%eax),%edx
  800684:	89 55 14             	mov    %edx,0x14(%ebp)
  800687:	8b 00                	mov    (%eax),%eax
  800689:	99                   	cltd   
  80068a:	31 d0                	xor    %edx,%eax
  80068c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80068e:	83 f8 0f             	cmp    $0xf,%eax
  800691:	7f 0b                	jg     80069e <vprintfmt+0x1f6>
  800693:	8b 14 85 20 28 80 00 	mov    0x802820(,%eax,4),%edx
  80069a:	85 d2                	test   %edx,%edx
  80069c:	75 18                	jne    8006b6 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80069e:	50                   	push   %eax
  80069f:	68 8f 25 80 00       	push   $0x80258f
  8006a4:	53                   	push   %ebx
  8006a5:	56                   	push   %esi
  8006a6:	e8 e0 fd ff ff       	call   80048b <printfmt>
  8006ab:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006b1:	e9 18 fe ff ff       	jmp    8004ce <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006b6:	52                   	push   %edx
  8006b7:	68 05 2a 80 00       	push   $0x802a05
  8006bc:	53                   	push   %ebx
  8006bd:	56                   	push   %esi
  8006be:	e8 c8 fd ff ff       	call   80048b <printfmt>
  8006c3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c9:	e9 00 fe ff ff       	jmp    8004ce <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8d 50 04             	lea    0x4(%eax),%edx
  8006d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006d9:	85 ff                	test   %edi,%edi
  8006db:	b8 88 25 80 00       	mov    $0x802588,%eax
  8006e0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006e3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006e7:	0f 8e 94 00 00 00    	jle    800781 <vprintfmt+0x2d9>
  8006ed:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006f1:	0f 84 98 00 00 00    	je     80078f <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	ff 75 d0             	pushl  -0x30(%ebp)
  8006fd:	57                   	push   %edi
  8006fe:	e8 81 02 00 00       	call   800984 <strnlen>
  800703:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800706:	29 c1                	sub    %eax,%ecx
  800708:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80070b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80070e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800712:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800715:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800718:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80071a:	eb 0f                	jmp    80072b <vprintfmt+0x283>
					putch(padc, putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	ff 75 e0             	pushl  -0x20(%ebp)
  800723:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800725:	83 ef 01             	sub    $0x1,%edi
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	85 ff                	test   %edi,%edi
  80072d:	7f ed                	jg     80071c <vprintfmt+0x274>
  80072f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800732:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800735:	85 c9                	test   %ecx,%ecx
  800737:	b8 00 00 00 00       	mov    $0x0,%eax
  80073c:	0f 49 c1             	cmovns %ecx,%eax
  80073f:	29 c1                	sub    %eax,%ecx
  800741:	89 75 08             	mov    %esi,0x8(%ebp)
  800744:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800747:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80074a:	89 cb                	mov    %ecx,%ebx
  80074c:	eb 4d                	jmp    80079b <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80074e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800752:	74 1b                	je     80076f <vprintfmt+0x2c7>
  800754:	0f be c0             	movsbl %al,%eax
  800757:	83 e8 20             	sub    $0x20,%eax
  80075a:	83 f8 5e             	cmp    $0x5e,%eax
  80075d:	76 10                	jbe    80076f <vprintfmt+0x2c7>
					putch('?', putdat);
  80075f:	83 ec 08             	sub    $0x8,%esp
  800762:	ff 75 0c             	pushl  0xc(%ebp)
  800765:	6a 3f                	push   $0x3f
  800767:	ff 55 08             	call   *0x8(%ebp)
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	eb 0d                	jmp    80077c <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	ff 75 0c             	pushl  0xc(%ebp)
  800775:	52                   	push   %edx
  800776:	ff 55 08             	call   *0x8(%ebp)
  800779:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80077c:	83 eb 01             	sub    $0x1,%ebx
  80077f:	eb 1a                	jmp    80079b <vprintfmt+0x2f3>
  800781:	89 75 08             	mov    %esi,0x8(%ebp)
  800784:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800787:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80078a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80078d:	eb 0c                	jmp    80079b <vprintfmt+0x2f3>
  80078f:	89 75 08             	mov    %esi,0x8(%ebp)
  800792:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800795:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800798:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80079b:	83 c7 01             	add    $0x1,%edi
  80079e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007a2:	0f be d0             	movsbl %al,%edx
  8007a5:	85 d2                	test   %edx,%edx
  8007a7:	74 23                	je     8007cc <vprintfmt+0x324>
  8007a9:	85 f6                	test   %esi,%esi
  8007ab:	78 a1                	js     80074e <vprintfmt+0x2a6>
  8007ad:	83 ee 01             	sub    $0x1,%esi
  8007b0:	79 9c                	jns    80074e <vprintfmt+0x2a6>
  8007b2:	89 df                	mov    %ebx,%edi
  8007b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ba:	eb 18                	jmp    8007d4 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007bc:	83 ec 08             	sub    $0x8,%esp
  8007bf:	53                   	push   %ebx
  8007c0:	6a 20                	push   $0x20
  8007c2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007c4:	83 ef 01             	sub    $0x1,%edi
  8007c7:	83 c4 10             	add    $0x10,%esp
  8007ca:	eb 08                	jmp    8007d4 <vprintfmt+0x32c>
  8007cc:	89 df                	mov    %ebx,%edi
  8007ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d4:	85 ff                	test   %edi,%edi
  8007d6:	7f e4                	jg     8007bc <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007db:	e9 ee fc ff ff       	jmp    8004ce <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007e0:	83 fa 01             	cmp    $0x1,%edx
  8007e3:	7e 16                	jle    8007fb <vprintfmt+0x353>
		return va_arg(*ap, long long);
  8007e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e8:	8d 50 08             	lea    0x8(%eax),%edx
  8007eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ee:	8b 50 04             	mov    0x4(%eax),%edx
  8007f1:	8b 00                	mov    (%eax),%eax
  8007f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007f9:	eb 32                	jmp    80082d <vprintfmt+0x385>
	else if (lflag)
  8007fb:	85 d2                	test   %edx,%edx
  8007fd:	74 18                	je     800817 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8d 50 04             	lea    0x4(%eax),%edx
  800805:	89 55 14             	mov    %edx,0x14(%ebp)
  800808:	8b 00                	mov    (%eax),%eax
  80080a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80080d:	89 c1                	mov    %eax,%ecx
  80080f:	c1 f9 1f             	sar    $0x1f,%ecx
  800812:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800815:	eb 16                	jmp    80082d <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  800817:	8b 45 14             	mov    0x14(%ebp),%eax
  80081a:	8d 50 04             	lea    0x4(%eax),%edx
  80081d:	89 55 14             	mov    %edx,0x14(%ebp)
  800820:	8b 00                	mov    (%eax),%eax
  800822:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800825:	89 c1                	mov    %eax,%ecx
  800827:	c1 f9 1f             	sar    $0x1f,%ecx
  80082a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80082d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800830:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800833:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800838:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80083c:	79 6f                	jns    8008ad <vprintfmt+0x405>
				putch('-', putdat);
  80083e:	83 ec 08             	sub    $0x8,%esp
  800841:	53                   	push   %ebx
  800842:	6a 2d                	push   $0x2d
  800844:	ff d6                	call   *%esi
				num = -(long long) num;
  800846:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800849:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80084c:	f7 d8                	neg    %eax
  80084e:	83 d2 00             	adc    $0x0,%edx
  800851:	f7 da                	neg    %edx
  800853:	83 c4 10             	add    $0x10,%esp
  800856:	eb 55                	jmp    8008ad <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800858:	8d 45 14             	lea    0x14(%ebp),%eax
  80085b:	e8 d4 fb ff ff       	call   800434 <getuint>
			base = 10;
  800860:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800865:	eb 46                	jmp    8008ad <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800867:	8d 45 14             	lea    0x14(%ebp),%eax
  80086a:	e8 c5 fb ff ff       	call   800434 <getuint>
			base = 8;
  80086f:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800874:	eb 37                	jmp    8008ad <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800876:	83 ec 08             	sub    $0x8,%esp
  800879:	53                   	push   %ebx
  80087a:	6a 30                	push   $0x30
  80087c:	ff d6                	call   *%esi
			putch('x', putdat);
  80087e:	83 c4 08             	add    $0x8,%esp
  800881:	53                   	push   %ebx
  800882:	6a 78                	push   $0x78
  800884:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800886:	8b 45 14             	mov    0x14(%ebp),%eax
  800889:	8d 50 04             	lea    0x4(%eax),%edx
  80088c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80088f:	8b 00                	mov    (%eax),%eax
  800891:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800896:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800899:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80089e:	eb 0d                	jmp    8008ad <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a3:	e8 8c fb ff ff       	call   800434 <getuint>
			base = 16;
  8008a8:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008ad:	83 ec 0c             	sub    $0xc,%esp
  8008b0:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8008b4:	51                   	push   %ecx
  8008b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b8:	57                   	push   %edi
  8008b9:	52                   	push   %edx
  8008ba:	50                   	push   %eax
  8008bb:	89 da                	mov    %ebx,%edx
  8008bd:	89 f0                	mov    %esi,%eax
  8008bf:	e8 c1 fa ff ff       	call   800385 <printnum>
			break;
  8008c4:	83 c4 20             	add    $0x20,%esp
  8008c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ca:	e9 ff fb ff ff       	jmp    8004ce <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008cf:	83 ec 08             	sub    $0x8,%esp
  8008d2:	53                   	push   %ebx
  8008d3:	51                   	push   %ecx
  8008d4:	ff d6                	call   *%esi
			break;
  8008d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008dc:	e9 ed fb ff ff       	jmp    8004ce <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	53                   	push   %ebx
  8008e5:	6a 25                	push   $0x25
  8008e7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	eb 03                	jmp    8008f1 <vprintfmt+0x449>
  8008ee:	83 ef 01             	sub    $0x1,%edi
  8008f1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008f5:	75 f7                	jne    8008ee <vprintfmt+0x446>
  8008f7:	e9 d2 fb ff ff       	jmp    8004ce <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5f                   	pop    %edi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	83 ec 18             	sub    $0x18,%esp
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800910:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800913:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800917:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80091a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800921:	85 c0                	test   %eax,%eax
  800923:	74 26                	je     80094b <vsnprintf+0x47>
  800925:	85 d2                	test   %edx,%edx
  800927:	7e 22                	jle    80094b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800929:	ff 75 14             	pushl  0x14(%ebp)
  80092c:	ff 75 10             	pushl  0x10(%ebp)
  80092f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800932:	50                   	push   %eax
  800933:	68 6e 04 80 00       	push   $0x80046e
  800938:	e8 6b fb ff ff       	call   8004a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80093d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800940:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800943:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800946:	83 c4 10             	add    $0x10,%esp
  800949:	eb 05                	jmp    800950 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80094b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800950:	c9                   	leave  
  800951:	c3                   	ret    

00800952 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800958:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80095b:	50                   	push   %eax
  80095c:	ff 75 10             	pushl  0x10(%ebp)
  80095f:	ff 75 0c             	pushl  0xc(%ebp)
  800962:	ff 75 08             	pushl  0x8(%ebp)
  800965:	e8 9a ff ff ff       	call   800904 <vsnprintf>
	va_end(ap);

	return rc;
}
  80096a:	c9                   	leave  
  80096b:	c3                   	ret    

0080096c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800972:	b8 00 00 00 00       	mov    $0x0,%eax
  800977:	eb 03                	jmp    80097c <strlen+0x10>
		n++;
  800979:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80097c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800980:	75 f7                	jne    800979 <strlen+0xd>
		n++;
	return n;
}
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098d:	ba 00 00 00 00       	mov    $0x0,%edx
  800992:	eb 03                	jmp    800997 <strnlen+0x13>
		n++;
  800994:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800997:	39 c2                	cmp    %eax,%edx
  800999:	74 08                	je     8009a3 <strnlen+0x1f>
  80099b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80099f:	75 f3                	jne    800994 <strnlen+0x10>
  8009a1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	53                   	push   %ebx
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009af:	89 c2                	mov    %eax,%edx
  8009b1:	83 c2 01             	add    $0x1,%edx
  8009b4:	83 c1 01             	add    $0x1,%ecx
  8009b7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009bb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009be:	84 db                	test   %bl,%bl
  8009c0:	75 ef                	jne    8009b1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009c2:	5b                   	pop    %ebx
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	53                   	push   %ebx
  8009c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009cc:	53                   	push   %ebx
  8009cd:	e8 9a ff ff ff       	call   80096c <strlen>
  8009d2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009d5:	ff 75 0c             	pushl  0xc(%ebp)
  8009d8:	01 d8                	add    %ebx,%eax
  8009da:	50                   	push   %eax
  8009db:	e8 c5 ff ff ff       	call   8009a5 <strcpy>
	return dst;
}
  8009e0:	89 d8                	mov    %ebx,%eax
  8009e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e5:	c9                   	leave  
  8009e6:	c3                   	ret    

008009e7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	56                   	push   %esi
  8009eb:	53                   	push   %ebx
  8009ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f2:	89 f3                	mov    %esi,%ebx
  8009f4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f7:	89 f2                	mov    %esi,%edx
  8009f9:	eb 0f                	jmp    800a0a <strncpy+0x23>
		*dst++ = *src;
  8009fb:	83 c2 01             	add    $0x1,%edx
  8009fe:	0f b6 01             	movzbl (%ecx),%eax
  800a01:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a04:	80 39 01             	cmpb   $0x1,(%ecx)
  800a07:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0a:	39 da                	cmp    %ebx,%edx
  800a0c:	75 ed                	jne    8009fb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a0e:	89 f0                	mov    %esi,%eax
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1f:	8b 55 10             	mov    0x10(%ebp),%edx
  800a22:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a24:	85 d2                	test   %edx,%edx
  800a26:	74 21                	je     800a49 <strlcpy+0x35>
  800a28:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a2c:	89 f2                	mov    %esi,%edx
  800a2e:	eb 09                	jmp    800a39 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a30:	83 c2 01             	add    $0x1,%edx
  800a33:	83 c1 01             	add    $0x1,%ecx
  800a36:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a39:	39 c2                	cmp    %eax,%edx
  800a3b:	74 09                	je     800a46 <strlcpy+0x32>
  800a3d:	0f b6 19             	movzbl (%ecx),%ebx
  800a40:	84 db                	test   %bl,%bl
  800a42:	75 ec                	jne    800a30 <strlcpy+0x1c>
  800a44:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a46:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a49:	29 f0                	sub    %esi,%eax
}
  800a4b:	5b                   	pop    %ebx
  800a4c:	5e                   	pop    %esi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a55:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a58:	eb 06                	jmp    800a60 <strcmp+0x11>
		p++, q++;
  800a5a:	83 c1 01             	add    $0x1,%ecx
  800a5d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a60:	0f b6 01             	movzbl (%ecx),%eax
  800a63:	84 c0                	test   %al,%al
  800a65:	74 04                	je     800a6b <strcmp+0x1c>
  800a67:	3a 02                	cmp    (%edx),%al
  800a69:	74 ef                	je     800a5a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a6b:	0f b6 c0             	movzbl %al,%eax
  800a6e:	0f b6 12             	movzbl (%edx),%edx
  800a71:	29 d0                	sub    %edx,%eax
}
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	53                   	push   %ebx
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7f:	89 c3                	mov    %eax,%ebx
  800a81:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a84:	eb 06                	jmp    800a8c <strncmp+0x17>
		n--, p++, q++;
  800a86:	83 c0 01             	add    $0x1,%eax
  800a89:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a8c:	39 d8                	cmp    %ebx,%eax
  800a8e:	74 15                	je     800aa5 <strncmp+0x30>
  800a90:	0f b6 08             	movzbl (%eax),%ecx
  800a93:	84 c9                	test   %cl,%cl
  800a95:	74 04                	je     800a9b <strncmp+0x26>
  800a97:	3a 0a                	cmp    (%edx),%cl
  800a99:	74 eb                	je     800a86 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a9b:	0f b6 00             	movzbl (%eax),%eax
  800a9e:	0f b6 12             	movzbl (%edx),%edx
  800aa1:	29 d0                	sub    %edx,%eax
  800aa3:	eb 05                	jmp    800aaa <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aa5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aaa:	5b                   	pop    %ebx
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab7:	eb 07                	jmp    800ac0 <strchr+0x13>
		if (*s == c)
  800ab9:	38 ca                	cmp    %cl,%dl
  800abb:	74 0f                	je     800acc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800abd:	83 c0 01             	add    $0x1,%eax
  800ac0:	0f b6 10             	movzbl (%eax),%edx
  800ac3:	84 d2                	test   %dl,%dl
  800ac5:	75 f2                	jne    800ab9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad8:	eb 03                	jmp    800add <strfind+0xf>
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ae0:	38 ca                	cmp    %cl,%dl
  800ae2:	74 04                	je     800ae8 <strfind+0x1a>
  800ae4:	84 d2                	test   %dl,%dl
  800ae6:	75 f2                	jne    800ada <strfind+0xc>
			break;
	return (char *) s;
}
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
  800af0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800af6:	85 c9                	test   %ecx,%ecx
  800af8:	74 36                	je     800b30 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800afa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b00:	75 28                	jne    800b2a <memset+0x40>
  800b02:	f6 c1 03             	test   $0x3,%cl
  800b05:	75 23                	jne    800b2a <memset+0x40>
		c &= 0xFF;
  800b07:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b0b:	89 d3                	mov    %edx,%ebx
  800b0d:	c1 e3 08             	shl    $0x8,%ebx
  800b10:	89 d6                	mov    %edx,%esi
  800b12:	c1 e6 18             	shl    $0x18,%esi
  800b15:	89 d0                	mov    %edx,%eax
  800b17:	c1 e0 10             	shl    $0x10,%eax
  800b1a:	09 f0                	or     %esi,%eax
  800b1c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b1e:	89 d8                	mov    %ebx,%eax
  800b20:	09 d0                	or     %edx,%eax
  800b22:	c1 e9 02             	shr    $0x2,%ecx
  800b25:	fc                   	cld    
  800b26:	f3 ab                	rep stos %eax,%es:(%edi)
  800b28:	eb 06                	jmp    800b30 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2d:	fc                   	cld    
  800b2e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b30:	89 f8                	mov    %edi,%eax
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b42:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b45:	39 c6                	cmp    %eax,%esi
  800b47:	73 35                	jae    800b7e <memmove+0x47>
  800b49:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b4c:	39 d0                	cmp    %edx,%eax
  800b4e:	73 2e                	jae    800b7e <memmove+0x47>
		s += n;
		d += n;
  800b50:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b53:	89 d6                	mov    %edx,%esi
  800b55:	09 fe                	or     %edi,%esi
  800b57:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b5d:	75 13                	jne    800b72 <memmove+0x3b>
  800b5f:	f6 c1 03             	test   $0x3,%cl
  800b62:	75 0e                	jne    800b72 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b64:	83 ef 04             	sub    $0x4,%edi
  800b67:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b6a:	c1 e9 02             	shr    $0x2,%ecx
  800b6d:	fd                   	std    
  800b6e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b70:	eb 09                	jmp    800b7b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b72:	83 ef 01             	sub    $0x1,%edi
  800b75:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b78:	fd                   	std    
  800b79:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b7b:	fc                   	cld    
  800b7c:	eb 1d                	jmp    800b9b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7e:	89 f2                	mov    %esi,%edx
  800b80:	09 c2                	or     %eax,%edx
  800b82:	f6 c2 03             	test   $0x3,%dl
  800b85:	75 0f                	jne    800b96 <memmove+0x5f>
  800b87:	f6 c1 03             	test   $0x3,%cl
  800b8a:	75 0a                	jne    800b96 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b8c:	c1 e9 02             	shr    $0x2,%ecx
  800b8f:	89 c7                	mov    %eax,%edi
  800b91:	fc                   	cld    
  800b92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b94:	eb 05                	jmp    800b9b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b96:	89 c7                	mov    %eax,%edi
  800b98:	fc                   	cld    
  800b99:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ba2:	ff 75 10             	pushl  0x10(%ebp)
  800ba5:	ff 75 0c             	pushl  0xc(%ebp)
  800ba8:	ff 75 08             	pushl  0x8(%ebp)
  800bab:	e8 87 ff ff ff       	call   800b37 <memmove>
}
  800bb0:	c9                   	leave  
  800bb1:	c3                   	ret    

00800bb2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bba:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bbd:	89 c6                	mov    %eax,%esi
  800bbf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc2:	eb 1a                	jmp    800bde <memcmp+0x2c>
		if (*s1 != *s2)
  800bc4:	0f b6 08             	movzbl (%eax),%ecx
  800bc7:	0f b6 1a             	movzbl (%edx),%ebx
  800bca:	38 d9                	cmp    %bl,%cl
  800bcc:	74 0a                	je     800bd8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bce:	0f b6 c1             	movzbl %cl,%eax
  800bd1:	0f b6 db             	movzbl %bl,%ebx
  800bd4:	29 d8                	sub    %ebx,%eax
  800bd6:	eb 0f                	jmp    800be7 <memcmp+0x35>
		s1++, s2++;
  800bd8:	83 c0 01             	add    $0x1,%eax
  800bdb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bde:	39 f0                	cmp    %esi,%eax
  800be0:	75 e2                	jne    800bc4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800be2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	53                   	push   %ebx
  800bef:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bf2:	89 c1                	mov    %eax,%ecx
  800bf4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bfb:	eb 0a                	jmp    800c07 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bfd:	0f b6 10             	movzbl (%eax),%edx
  800c00:	39 da                	cmp    %ebx,%edx
  800c02:	74 07                	je     800c0b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c04:	83 c0 01             	add    $0x1,%eax
  800c07:	39 c8                	cmp    %ecx,%eax
  800c09:	72 f2                	jb     800bfd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c0b:	5b                   	pop    %ebx
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
  800c14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1a:	eb 03                	jmp    800c1f <strtol+0x11>
		s++;
  800c1c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1f:	0f b6 01             	movzbl (%ecx),%eax
  800c22:	3c 20                	cmp    $0x20,%al
  800c24:	74 f6                	je     800c1c <strtol+0xe>
  800c26:	3c 09                	cmp    $0x9,%al
  800c28:	74 f2                	je     800c1c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c2a:	3c 2b                	cmp    $0x2b,%al
  800c2c:	75 0a                	jne    800c38 <strtol+0x2a>
		s++;
  800c2e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c31:	bf 00 00 00 00       	mov    $0x0,%edi
  800c36:	eb 11                	jmp    800c49 <strtol+0x3b>
  800c38:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c3d:	3c 2d                	cmp    $0x2d,%al
  800c3f:	75 08                	jne    800c49 <strtol+0x3b>
		s++, neg = 1;
  800c41:	83 c1 01             	add    $0x1,%ecx
  800c44:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c49:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c4f:	75 15                	jne    800c66 <strtol+0x58>
  800c51:	80 39 30             	cmpb   $0x30,(%ecx)
  800c54:	75 10                	jne    800c66 <strtol+0x58>
  800c56:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c5a:	75 7c                	jne    800cd8 <strtol+0xca>
		s += 2, base = 16;
  800c5c:	83 c1 02             	add    $0x2,%ecx
  800c5f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c64:	eb 16                	jmp    800c7c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c66:	85 db                	test   %ebx,%ebx
  800c68:	75 12                	jne    800c7c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c6a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c6f:	80 39 30             	cmpb   $0x30,(%ecx)
  800c72:	75 08                	jne    800c7c <strtol+0x6e>
		s++, base = 8;
  800c74:	83 c1 01             	add    $0x1,%ecx
  800c77:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c81:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c84:	0f b6 11             	movzbl (%ecx),%edx
  800c87:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c8a:	89 f3                	mov    %esi,%ebx
  800c8c:	80 fb 09             	cmp    $0x9,%bl
  800c8f:	77 08                	ja     800c99 <strtol+0x8b>
			dig = *s - '0';
  800c91:	0f be d2             	movsbl %dl,%edx
  800c94:	83 ea 30             	sub    $0x30,%edx
  800c97:	eb 22                	jmp    800cbb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c99:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c9c:	89 f3                	mov    %esi,%ebx
  800c9e:	80 fb 19             	cmp    $0x19,%bl
  800ca1:	77 08                	ja     800cab <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ca3:	0f be d2             	movsbl %dl,%edx
  800ca6:	83 ea 57             	sub    $0x57,%edx
  800ca9:	eb 10                	jmp    800cbb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cab:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cae:	89 f3                	mov    %esi,%ebx
  800cb0:	80 fb 19             	cmp    $0x19,%bl
  800cb3:	77 16                	ja     800ccb <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cb5:	0f be d2             	movsbl %dl,%edx
  800cb8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cbb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cbe:	7d 0b                	jge    800ccb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cc0:	83 c1 01             	add    $0x1,%ecx
  800cc3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cc7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cc9:	eb b9                	jmp    800c84 <strtol+0x76>

	if (endptr)
  800ccb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ccf:	74 0d                	je     800cde <strtol+0xd0>
		*endptr = (char *) s;
  800cd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd4:	89 0e                	mov    %ecx,(%esi)
  800cd6:	eb 06                	jmp    800cde <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cd8:	85 db                	test   %ebx,%ebx
  800cda:	74 98                	je     800c74 <strtol+0x66>
  800cdc:	eb 9e                	jmp    800c7c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cde:	89 c2                	mov    %eax,%edx
  800ce0:	f7 da                	neg    %edx
  800ce2:	85 ff                	test   %edi,%edi
  800ce4:	0f 45 c2             	cmovne %edx,%eax
}
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	83 ec 04             	sub    $0x4,%esp
  800cf5:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800cf8:	57                   	push   %edi
  800cf9:	e8 6e fc ff ff       	call   80096c <strlen>
  800cfe:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800d01:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800d04:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800d09:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800d0e:	eb 46                	jmp    800d56 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800d10:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800d14:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800d17:	80 f9 09             	cmp    $0x9,%cl
  800d1a:	77 08                	ja     800d24 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800d1c:	0f be d2             	movsbl %dl,%edx
  800d1f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800d22:	eb 27                	jmp    800d4b <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800d24:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800d27:	80 f9 05             	cmp    $0x5,%cl
  800d2a:	77 08                	ja     800d34 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800d2c:	0f be d2             	movsbl %dl,%edx
  800d2f:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800d32:	eb 17                	jmp    800d4b <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800d34:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800d37:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800d3a:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800d3f:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800d43:	77 06                	ja     800d4b <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800d45:	0f be d2             	movsbl %dl,%edx
  800d48:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800d4b:	0f af ce             	imul   %esi,%ecx
  800d4e:	01 c8                	add    %ecx,%eax
		base *= 16;
  800d50:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800d53:	83 eb 01             	sub    $0x1,%ebx
  800d56:	83 fb 01             	cmp    $0x1,%ebx
  800d59:	7f b5                	jg     800d10 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d69:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 c3                	mov    %eax,%ebx
  800d76:	89 c7                	mov    %eax,%edi
  800d78:	89 c6                	mov    %eax,%esi
  800d7a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d87:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d91:	89 d1                	mov    %edx,%ecx
  800d93:	89 d3                	mov    %edx,%ebx
  800d95:	89 d7                	mov    %edx,%edi
  800d97:	89 d6                	mov    %edx,%esi
  800d99:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800da9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dae:	b8 03 00 00 00       	mov    $0x3,%eax
  800db3:	8b 55 08             	mov    0x8(%ebp),%edx
  800db6:	89 cb                	mov    %ecx,%ebx
  800db8:	89 cf                	mov    %ecx,%edi
  800dba:	89 ce                	mov    %ecx,%esi
  800dbc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	7e 17                	jle    800dd9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc2:	83 ec 0c             	sub    $0xc,%esp
  800dc5:	50                   	push   %eax
  800dc6:	6a 03                	push   $0x3
  800dc8:	68 7f 28 80 00       	push   $0x80287f
  800dcd:	6a 23                	push   $0x23
  800dcf:	68 9c 28 80 00       	push   $0x80289c
  800dd4:	e8 bf f4 ff ff       	call   800298 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	57                   	push   %edi
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de7:	ba 00 00 00 00       	mov    $0x0,%edx
  800dec:	b8 02 00 00 00       	mov    $0x2,%eax
  800df1:	89 d1                	mov    %edx,%ecx
  800df3:	89 d3                	mov    %edx,%ebx
  800df5:	89 d7                	mov    %edx,%edi
  800df7:	89 d6                	mov    %edx,%esi
  800df9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_yield>:

void
sys_yield(void)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e06:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e10:	89 d1                	mov    %edx,%ecx
  800e12:	89 d3                	mov    %edx,%ebx
  800e14:	89 d7                	mov    %edx,%edi
  800e16:	89 d6                	mov    %edx,%esi
  800e18:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e1a:	5b                   	pop    %ebx
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800e28:	be 00 00 00 00       	mov    $0x0,%esi
  800e2d:	b8 04 00 00 00       	mov    $0x4,%eax
  800e32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e35:	8b 55 08             	mov    0x8(%ebp),%edx
  800e38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3b:	89 f7                	mov    %esi,%edi
  800e3d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	7e 17                	jle    800e5a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e43:	83 ec 0c             	sub    $0xc,%esp
  800e46:	50                   	push   %eax
  800e47:	6a 04                	push   $0x4
  800e49:	68 7f 28 80 00       	push   $0x80287f
  800e4e:	6a 23                	push   $0x23
  800e50:	68 9c 28 80 00       	push   $0x80289c
  800e55:	e8 3e f4 ff ff       	call   800298 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	57                   	push   %edi
  800e66:	56                   	push   %esi
  800e67:	53                   	push   %ebx
  800e68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6b:	b8 05 00 00 00       	mov    $0x5,%eax
  800e70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e73:	8b 55 08             	mov    0x8(%ebp),%edx
  800e76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e79:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e7c:	8b 75 18             	mov    0x18(%ebp),%esi
  800e7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e81:	85 c0                	test   %eax,%eax
  800e83:	7e 17                	jle    800e9c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e85:	83 ec 0c             	sub    $0xc,%esp
  800e88:	50                   	push   %eax
  800e89:	6a 05                	push   $0x5
  800e8b:	68 7f 28 80 00       	push   $0x80287f
  800e90:	6a 23                	push   $0x23
  800e92:	68 9c 28 80 00       	push   $0x80289c
  800e97:	e8 fc f3 ff ff       	call   800298 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5f                   	pop    %edi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	53                   	push   %ebx
  800eaa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ead:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb2:	b8 06 00 00 00       	mov    $0x6,%eax
  800eb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eba:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebd:	89 df                	mov    %ebx,%edi
  800ebf:	89 de                	mov    %ebx,%esi
  800ec1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	7e 17                	jle    800ede <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec7:	83 ec 0c             	sub    $0xc,%esp
  800eca:	50                   	push   %eax
  800ecb:	6a 06                	push   $0x6
  800ecd:	68 7f 28 80 00       	push   $0x80287f
  800ed2:	6a 23                	push   $0x23
  800ed4:	68 9c 28 80 00       	push   $0x80289c
  800ed9:	e8 ba f3 ff ff       	call   800298 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ede:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5f                   	pop    %edi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    

00800ee6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	57                   	push   %edi
  800eea:	56                   	push   %esi
  800eeb:	53                   	push   %ebx
  800eec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef4:	b8 08 00 00 00       	mov    $0x8,%eax
  800ef9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efc:	8b 55 08             	mov    0x8(%ebp),%edx
  800eff:	89 df                	mov    %ebx,%edi
  800f01:	89 de                	mov    %ebx,%esi
  800f03:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f05:	85 c0                	test   %eax,%eax
  800f07:	7e 17                	jle    800f20 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f09:	83 ec 0c             	sub    $0xc,%esp
  800f0c:	50                   	push   %eax
  800f0d:	6a 08                	push   $0x8
  800f0f:	68 7f 28 80 00       	push   $0x80287f
  800f14:	6a 23                	push   $0x23
  800f16:	68 9c 28 80 00       	push   $0x80289c
  800f1b:	e8 78 f3 ff ff       	call   800298 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f23:	5b                   	pop    %ebx
  800f24:	5e                   	pop    %esi
  800f25:	5f                   	pop    %edi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    

00800f28 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	57                   	push   %edi
  800f2c:	56                   	push   %esi
  800f2d:	53                   	push   %ebx
  800f2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f36:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f41:	89 df                	mov    %ebx,%edi
  800f43:	89 de                	mov    %ebx,%esi
  800f45:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f47:	85 c0                	test   %eax,%eax
  800f49:	7e 17                	jle    800f62 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4b:	83 ec 0c             	sub    $0xc,%esp
  800f4e:	50                   	push   %eax
  800f4f:	6a 0a                	push   $0xa
  800f51:	68 7f 28 80 00       	push   $0x80287f
  800f56:	6a 23                	push   $0x23
  800f58:	68 9c 28 80 00       	push   $0x80289c
  800f5d:	e8 36 f3 ff ff       	call   800298 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f65:	5b                   	pop    %ebx
  800f66:	5e                   	pop    %esi
  800f67:	5f                   	pop    %edi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    

00800f6a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	57                   	push   %edi
  800f6e:	56                   	push   %esi
  800f6f:	53                   	push   %ebx
  800f70:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f78:	b8 09 00 00 00       	mov    $0x9,%eax
  800f7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f80:	8b 55 08             	mov    0x8(%ebp),%edx
  800f83:	89 df                	mov    %ebx,%edi
  800f85:	89 de                	mov    %ebx,%esi
  800f87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	7e 17                	jle    800fa4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8d:	83 ec 0c             	sub    $0xc,%esp
  800f90:	50                   	push   %eax
  800f91:	6a 09                	push   $0x9
  800f93:	68 7f 28 80 00       	push   $0x80287f
  800f98:	6a 23                	push   $0x23
  800f9a:	68 9c 28 80 00       	push   $0x80289c
  800f9f:	e8 f4 f2 ff ff       	call   800298 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa7:	5b                   	pop    %ebx
  800fa8:	5e                   	pop    %esi
  800fa9:	5f                   	pop    %edi
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	57                   	push   %edi
  800fb0:	56                   	push   %esi
  800fb1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb2:	be 00 00 00 00       	mov    $0x0,%esi
  800fb7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fc5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fc8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fca:	5b                   	pop    %ebx
  800fcb:	5e                   	pop    %esi
  800fcc:	5f                   	pop    %edi
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    

00800fcf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	57                   	push   %edi
  800fd3:	56                   	push   %esi
  800fd4:	53                   	push   %ebx
  800fd5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fdd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fe2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe5:	89 cb                	mov    %ecx,%ebx
  800fe7:	89 cf                	mov    %ecx,%edi
  800fe9:	89 ce                	mov    %ecx,%esi
  800feb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fed:	85 c0                	test   %eax,%eax
  800fef:	7e 17                	jle    801008 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	50                   	push   %eax
  800ff5:	6a 0d                	push   $0xd
  800ff7:	68 7f 28 80 00       	push   $0x80287f
  800ffc:	6a 23                	push   $0x23
  800ffe:	68 9c 28 80 00       	push   $0x80289c
  801003:	e8 90 f2 ff ff       	call   800298 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801008:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	53                   	push   %ebx
  801014:	83 ec 04             	sub    $0x4,%esp
  801017:	8b 45 08             	mov    0x8(%ebp),%eax

	
	void *addr = (void *) utf->utf_fault_va;
  80101a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  80101c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801020:	74 11                	je     801033 <pgfault+0x23>
  801022:	89 d8                	mov    %ebx,%eax
  801024:	c1 e8 0c             	shr    $0xc,%eax
  801027:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80102e:	f6 c4 08             	test   $0x8,%ah
  801031:	75 14                	jne    801047 <pgfault+0x37>
		panic("page fault");
  801033:	83 ec 04             	sub    $0x4,%esp
  801036:	68 aa 28 80 00       	push   $0x8028aa
  80103b:	6a 5b                	push   $0x5b
  80103d:	68 b5 28 80 00       	push   $0x8028b5
  801042:	e8 51 f2 ff ff       	call   800298 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// allocate a new page and map it at a temporary location
	if((r = sys_page_alloc(0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  801047:	83 ec 04             	sub    $0x4,%esp
  80104a:	6a 07                	push   $0x7
  80104c:	68 00 f0 7f 00       	push   $0x7ff000
  801051:	6a 00                	push   $0x0
  801053:	e8 c7 fd ff ff       	call   800e1f <sys_page_alloc>
  801058:	83 c4 10             	add    $0x10,%esp
  80105b:	85 c0                	test   %eax,%eax
  80105d:	79 12                	jns    801071 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  80105f:	50                   	push   %eax
  801060:	68 c0 28 80 00       	push   $0x8028c0
  801065:	6a 66                	push   $0x66
  801067:	68 b5 28 80 00       	push   $0x8028b5
  80106c:	e8 27 f2 ff ff       	call   800298 <_panic>

	// copy date to new page
	//strncpy((char *)PFTEMP, (char *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
	memcpy((void *)PFTEMP, (void *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
  801071:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801077:	83 ec 04             	sub    $0x4,%esp
  80107a:	68 00 10 00 00       	push   $0x1000
  80107f:	53                   	push   %ebx
  801080:	68 00 f0 7f 00       	push   $0x7ff000
  801085:	e8 15 fb ff ff       	call   800b9f <memcpy>

	// move the new page to the old page's address
	if((r = sys_page_map(0, (void *)PFTEMP, 0, (void *)
  80108a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801091:	53                   	push   %ebx
  801092:	6a 00                	push   $0x0
  801094:	68 00 f0 7f 00       	push   $0x7ff000
  801099:	6a 00                	push   $0x0
  80109b:	e8 c2 fd ff ff       	call   800e62 <sys_page_map>
  8010a0:	83 c4 20             	add    $0x20,%esp
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	79 12                	jns    8010b9 <pgfault+0xa9>
		(ROUNDDOWN(addr, PGSIZE)), PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_map: %e", r);
  8010a7:	50                   	push   %eax
  8010a8:	68 d3 28 80 00       	push   $0x8028d3
  8010ad:	6a 6f                	push   $0x6f
  8010af:	68 b5 28 80 00       	push   $0x8028b5
  8010b4:	e8 df f1 ff ff       	call   800298 <_panic>

	// unmap page on PFTEMP
	if((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  8010b9:	83 ec 08             	sub    $0x8,%esp
  8010bc:	68 00 f0 7f 00       	push   $0x7ff000
  8010c1:	6a 00                	push   $0x0
  8010c3:	e8 dc fd ff ff       	call   800ea4 <sys_page_unmap>
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	79 12                	jns    8010e1 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  8010cf:	50                   	push   %eax
  8010d0:	68 e4 28 80 00       	push   $0x8028e4
  8010d5:	6a 73                	push   $0x73
  8010d7:	68 b5 28 80 00       	push   $0x8028b5
  8010dc:	e8 b7 f1 ff ff       	call   800298 <_panic>


}
  8010e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e4:	c9                   	leave  
  8010e5:	c3                   	ret    

008010e6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	57                   	push   %edi
  8010ea:	56                   	push   %esi
  8010eb:	53                   	push   %ebx
  8010ec:	83 ec 28             	sub    $0x28,%esp

	#ifdef CHALLENGE 
	set_exception_handler(pgfault, T_PGFLT);
	#else
	// set up page fault handler
	set_pgfault_handler(pgfault);
  8010ef:	68 10 10 80 00       	push   $0x801010
  8010f4:	e8 51 0f 00 00       	call   80204a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010f9:	b8 07 00 00 00       	mov    $0x7,%eax
  8010fe:	cd 30                	int    $0x30
  801100:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801103:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	#endif

	// create a child
	envid = sys_exofork();
	if (envid < 0)
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	85 c0                	test   %eax,%eax
  80110b:	79 15                	jns    801122 <fork+0x3c>
		panic("sys_exofork: %e", envid);
  80110d:	50                   	push   %eax
  80110e:	68 f7 28 80 00       	push   $0x8028f7
  801113:	68 d0 00 00 00       	push   $0xd0
  801118:	68 b5 28 80 00       	push   $0x8028b5
  80111d:	e8 76 f1 ff ff       	call   800298 <_panic>
  801122:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801127:	be 00 08 00 00       	mov    $0x800,%esi
	// we are the child
	if(envid == 0) {
  80112c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801130:	75 21                	jne    801153 <fork+0x6d>
		// the copied valude of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  801132:	e8 aa fc ff ff       	call   800de1 <sys_getenvid>
  801137:	25 ff 03 00 00       	and    $0x3ff,%eax
  80113c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80113f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801144:	a3 08 40 80 00       	mov    %eax,0x804008
		/*// alloc exception stack
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
			PTE_P | PTE_U | PTE_W)) < 0)
			panic("sys_page_alloc: %e", r);*/

		return 0;
  801149:	b8 00 00 00 00       	mov    $0x0,%eax
  80114e:	e9 a3 01 00 00       	jmp    8012f6 <fork+0x210>
{
	int r;

	// LAB 4: Your code here.
	
	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P))
  801153:	89 d8                	mov    %ebx,%eax
  801155:	c1 e8 16             	shr    $0x16,%eax
  801158:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80115f:	a8 01                	test   $0x1,%al
  801161:	0f 84 f0 00 00 00    	je     801257 <fork+0x171>
		return 0;

	// virtual page pn's page table entry
	pte_t pe = uvpt[pn];
  801167:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi


	if((pe & PTE_P) && (pe & PTE_U)) {
  80116e:	89 f8                	mov    %edi,%eax
  801170:	83 e0 05             	and    $0x5,%eax
  801173:	83 f8 05             	cmp    $0x5,%eax
  801176:	0f 85 db 00 00 00    	jne    801257 <fork+0x171>
		// share with the child environment 
		if(pe & PTE_SHARE) {
  80117c:	f7 c7 00 04 00 00    	test   $0x400,%edi
  801182:	74 36                	je     8011ba <fork+0xd4>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  801184:	83 ec 0c             	sub    $0xc,%esp
  801187:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  80118d:	57                   	push   %edi
  80118e:	53                   	push   %ebx
  80118f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801192:	53                   	push   %ebx
  801193:	6a 00                	push   $0x0
  801195:	e8 c8 fc ff ff       	call   800e62 <sys_page_map>
  80119a:	83 c4 20             	add    $0x20,%esp
  80119d:	85 c0                	test   %eax,%eax
  80119f:	0f 89 b2 00 00 00    	jns    801257 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  8011a5:	50                   	push   %eax
  8011a6:	68 07 29 80 00       	push   $0x802907
  8011ab:	68 97 00 00 00       	push   $0x97
  8011b0:	68 b5 28 80 00       	push   $0x8028b5
  8011b5:	e8 de f0 ff ff       	call   800298 <_panic>
		}
		// the page is writable or copy-on-write
		else if((pe & PTE_W) || (pe & PTE_COW)) {
  8011ba:	f7 c7 02 08 00 00    	test   $0x802,%edi
  8011c0:	74 63                	je     801225 <fork+0x13f>
			// create the child mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, 
  8011c2:	81 e7 05 06 00 00    	and    $0x605,%edi
  8011c8:	81 cf 00 08 00 00    	or     $0x800,%edi
  8011ce:	83 ec 0c             	sub    $0xc,%esp
  8011d1:	57                   	push   %edi
  8011d2:	53                   	push   %ebx
  8011d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d6:	53                   	push   %ebx
  8011d7:	6a 00                	push   $0x0
  8011d9:	e8 84 fc ff ff       	call   800e62 <sys_page_map>
  8011de:	83 c4 20             	add    $0x20,%esp
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	79 15                	jns    8011fa <fork+0x114>
				(void *)(pn*PGSIZE), (pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  8011e5:	50                   	push   %eax
  8011e6:	68 07 29 80 00       	push   $0x802907
  8011eb:	68 9e 00 00 00       	push   $0x9e
  8011f0:	68 b5 28 80 00       	push   $0x8028b5
  8011f5:	e8 9e f0 ff ff       	call   800298 <_panic>
			// map the parent mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE),
  8011fa:	83 ec 0c             	sub    $0xc,%esp
  8011fd:	57                   	push   %edi
  8011fe:	53                   	push   %ebx
  8011ff:	6a 00                	push   $0x0
  801201:	53                   	push   %ebx
  801202:	6a 00                	push   $0x0
  801204:	e8 59 fc ff ff       	call   800e62 <sys_page_map>
  801209:	83 c4 20             	add    $0x20,%esp
  80120c:	85 c0                	test   %eax,%eax
  80120e:	79 47                	jns    801257 <fork+0x171>
				(pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  801210:	50                   	push   %eax
  801211:	68 07 29 80 00       	push   $0x802907
  801216:	68 a2 00 00 00       	push   $0xa2
  80121b:	68 b5 28 80 00       	push   $0x8028b5
  801220:	e8 73 f0 ff ff       	call   800298 <_panic>
		}	
		else {
			// create the child mapping read only
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  801225:	83 ec 0c             	sub    $0xc,%esp
  801228:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  80122e:	57                   	push   %edi
  80122f:	53                   	push   %ebx
  801230:	ff 75 e4             	pushl  -0x1c(%ebp)
  801233:	53                   	push   %ebx
  801234:	6a 00                	push   $0x0
  801236:	e8 27 fc ff ff       	call   800e62 <sys_page_map>
  80123b:	83 c4 20             	add    $0x20,%esp
  80123e:	85 c0                	test   %eax,%eax
  801240:	79 15                	jns    801257 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  801242:	50                   	push   %eax
  801243:	68 07 29 80 00       	push   $0x802907
  801248:	68 a8 00 00 00       	push   $0xa8
  80124d:	68 b5 28 80 00       	push   $0x8028b5
  801252:	e8 41 f0 ff ff       	call   800298 <_panic>
			panic("sys_page_alloc: %e", r);*/

		return 0;
	}
	// copy address to child environment's page dirctory
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn)
  801257:	83 c6 01             	add    $0x1,%esi
  80125a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801260:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801266:	0f 85 e7 fe ff ff    	jne    801153 <fork+0x6d>
	#ifdef CHALLENGE 
	if((r = sys_env_set_exception_upcall(envid, thisenv->env_exception_upcall)) < 0)
		panic("sys_env_set_exception_upcall: %e", r);
	#else
	// set child's page fault handler
	if((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  80126c:	a1 08 40 80 00       	mov    0x804008,%eax
  801271:	8b 40 64             	mov    0x64(%eax),%eax
  801274:	83 ec 08             	sub    $0x8,%esp
  801277:	50                   	push   %eax
  801278:	ff 75 e0             	pushl  -0x20(%ebp)
  80127b:	e8 ea fc ff ff       	call   800f6a <sys_env_set_pgfault_upcall>
  801280:	83 c4 10             	add    $0x10,%esp
  801283:	85 c0                	test   %eax,%eax
  801285:	79 15                	jns    80129c <fork+0x1b6>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801287:	50                   	push   %eax
  801288:	68 40 29 80 00       	push   $0x802940
  80128d:	68 e9 00 00 00       	push   $0xe9
  801292:	68 b5 28 80 00       	push   $0x8028b5
  801297:	e8 fc ef ff ff       	call   800298 <_panic>
	#endif

	// alloc exception stack for child environment
	if((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), 
  80129c:	83 ec 04             	sub    $0x4,%esp
  80129f:	6a 07                	push   $0x7
  8012a1:	68 00 f0 bf ee       	push   $0xeebff000
  8012a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8012a9:	e8 71 fb ff ff       	call   800e1f <sys_page_alloc>
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	79 15                	jns    8012ca <fork+0x1e4>
		PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
  8012b5:	50                   	push   %eax
  8012b6:	68 c0 28 80 00       	push   $0x8028c0
  8012bb:	68 ef 00 00 00       	push   $0xef
  8012c0:	68 b5 28 80 00       	push   $0x8028b5
  8012c5:	e8 ce ef ff ff       	call   800298 <_panic>

	// start the child environment running
	if((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8012ca:	83 ec 08             	sub    $0x8,%esp
  8012cd:	6a 02                	push   $0x2
  8012cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8012d2:	e8 0f fc ff ff       	call   800ee6 <sys_env_set_status>
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	79 15                	jns    8012f3 <fork+0x20d>
		panic("sys_env_set_status: %e", r);
  8012de:	50                   	push   %eax
  8012df:	68 13 29 80 00       	push   $0x802913
  8012e4:	68 f3 00 00 00       	push   $0xf3
  8012e9:	68 b5 28 80 00       	push   $0x8028b5
  8012ee:	e8 a5 ef ff ff       	call   800298 <_panic>

	return envid;
  8012f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  8012f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f9:	5b                   	pop    %ebx
  8012fa:	5e                   	pop    %esi
  8012fb:	5f                   	pop    %edi
  8012fc:	5d                   	pop    %ebp
  8012fd:	c3                   	ret    

008012fe <sfork>:

// Challenge!
int
sfork(void)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801304:	68 2a 29 80 00       	push   $0x80292a
  801309:	68 fc 00 00 00       	push   $0xfc
  80130e:	68 b5 28 80 00       	push   $0x8028b5
  801313:	e8 80 ef ff ff       	call   800298 <_panic>

00801318 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80131b:	8b 45 08             	mov    0x8(%ebp),%eax
  80131e:	05 00 00 00 30       	add    $0x30000000,%eax
  801323:	c1 e8 0c             	shr    $0xc,%eax
}
  801326:	5d                   	pop    %ebp
  801327:	c3                   	ret    

00801328 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80132b:	8b 45 08             	mov    0x8(%ebp),%eax
  80132e:	05 00 00 00 30       	add    $0x30000000,%eax
  801333:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801338:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80133d:	5d                   	pop    %ebp
  80133e:	c3                   	ret    

0080133f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801345:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80134a:	89 c2                	mov    %eax,%edx
  80134c:	c1 ea 16             	shr    $0x16,%edx
  80134f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801356:	f6 c2 01             	test   $0x1,%dl
  801359:	74 11                	je     80136c <fd_alloc+0x2d>
  80135b:	89 c2                	mov    %eax,%edx
  80135d:	c1 ea 0c             	shr    $0xc,%edx
  801360:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801367:	f6 c2 01             	test   $0x1,%dl
  80136a:	75 09                	jne    801375 <fd_alloc+0x36>
			*fd_store = fd;
  80136c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80136e:	b8 00 00 00 00       	mov    $0x0,%eax
  801373:	eb 17                	jmp    80138c <fd_alloc+0x4d>
  801375:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80137a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80137f:	75 c9                	jne    80134a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801381:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801387:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80138c:	5d                   	pop    %ebp
  80138d:	c3                   	ret    

0080138e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801394:	83 f8 1f             	cmp    $0x1f,%eax
  801397:	77 36                	ja     8013cf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801399:	c1 e0 0c             	shl    $0xc,%eax
  80139c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013a1:	89 c2                	mov    %eax,%edx
  8013a3:	c1 ea 16             	shr    $0x16,%edx
  8013a6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ad:	f6 c2 01             	test   $0x1,%dl
  8013b0:	74 24                	je     8013d6 <fd_lookup+0x48>
  8013b2:	89 c2                	mov    %eax,%edx
  8013b4:	c1 ea 0c             	shr    $0xc,%edx
  8013b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013be:	f6 c2 01             	test   $0x1,%dl
  8013c1:	74 1a                	je     8013dd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c6:	89 02                	mov    %eax,(%edx)
	return 0;
  8013c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013cd:	eb 13                	jmp    8013e2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d4:	eb 0c                	jmp    8013e2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013db:	eb 05                	jmp    8013e2 <fd_lookup+0x54>
  8013dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013e2:	5d                   	pop    %ebp
  8013e3:	c3                   	ret    

008013e4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ed:	ba dc 29 80 00       	mov    $0x8029dc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013f2:	eb 13                	jmp    801407 <dev_lookup+0x23>
  8013f4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013f7:	39 08                	cmp    %ecx,(%eax)
  8013f9:	75 0c                	jne    801407 <dev_lookup+0x23>
			*dev = devtab[i];
  8013fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013fe:	89 01                	mov    %eax,(%ecx)
			return 0;
  801400:	b8 00 00 00 00       	mov    $0x0,%eax
  801405:	eb 2e                	jmp    801435 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801407:	8b 02                	mov    (%edx),%eax
  801409:	85 c0                	test   %eax,%eax
  80140b:	75 e7                	jne    8013f4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80140d:	a1 08 40 80 00       	mov    0x804008,%eax
  801412:	8b 40 48             	mov    0x48(%eax),%eax
  801415:	83 ec 04             	sub    $0x4,%esp
  801418:	51                   	push   %ecx
  801419:	50                   	push   %eax
  80141a:	68 60 29 80 00       	push   $0x802960
  80141f:	e8 4d ef ff ff       	call   800371 <cprintf>
	*dev = 0;
  801424:	8b 45 0c             	mov    0xc(%ebp),%eax
  801427:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80142d:	83 c4 10             	add    $0x10,%esp
  801430:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801435:	c9                   	leave  
  801436:	c3                   	ret    

00801437 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	56                   	push   %esi
  80143b:	53                   	push   %ebx
  80143c:	83 ec 10             	sub    $0x10,%esp
  80143f:	8b 75 08             	mov    0x8(%ebp),%esi
  801442:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801445:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80144f:	c1 e8 0c             	shr    $0xc,%eax
  801452:	50                   	push   %eax
  801453:	e8 36 ff ff ff       	call   80138e <fd_lookup>
  801458:	83 c4 08             	add    $0x8,%esp
  80145b:	85 c0                	test   %eax,%eax
  80145d:	78 05                	js     801464 <fd_close+0x2d>
	    || fd != fd2) 
  80145f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801462:	74 0c                	je     801470 <fd_close+0x39>
		return (must_exist ? r : 0); 
  801464:	84 db                	test   %bl,%bl
  801466:	ba 00 00 00 00       	mov    $0x0,%edx
  80146b:	0f 44 c2             	cmove  %edx,%eax
  80146e:	eb 41                	jmp    8014b1 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801470:	83 ec 08             	sub    $0x8,%esp
  801473:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801476:	50                   	push   %eax
  801477:	ff 36                	pushl  (%esi)
  801479:	e8 66 ff ff ff       	call   8013e4 <dev_lookup>
  80147e:	89 c3                	mov    %eax,%ebx
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	85 c0                	test   %eax,%eax
  801485:	78 1a                	js     8014a1 <fd_close+0x6a>
		if (dev->dev_close) 
  801487:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  80148d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  801492:	85 c0                	test   %eax,%eax
  801494:	74 0b                	je     8014a1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801496:	83 ec 0c             	sub    $0xc,%esp
  801499:	56                   	push   %esi
  80149a:	ff d0                	call   *%eax
  80149c:	89 c3                	mov    %eax,%ebx
  80149e:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014a1:	83 ec 08             	sub    $0x8,%esp
  8014a4:	56                   	push   %esi
  8014a5:	6a 00                	push   $0x0
  8014a7:	e8 f8 f9 ff ff       	call   800ea4 <sys_page_unmap>
	return r;
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	89 d8                	mov    %ebx,%eax
}
  8014b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b4:	5b                   	pop    %ebx
  8014b5:	5e                   	pop    %esi
  8014b6:	5d                   	pop    %ebp
  8014b7:	c3                   	ret    

008014b8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c1:	50                   	push   %eax
  8014c2:	ff 75 08             	pushl  0x8(%ebp)
  8014c5:	e8 c4 fe ff ff       	call   80138e <fd_lookup>
  8014ca:	83 c4 08             	add    $0x8,%esp
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	78 10                	js     8014e1 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  8014d1:	83 ec 08             	sub    $0x8,%esp
  8014d4:	6a 01                	push   $0x1
  8014d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d9:	e8 59 ff ff ff       	call   801437 <fd_close>
  8014de:	83 c4 10             	add    $0x10,%esp
}
  8014e1:	c9                   	leave  
  8014e2:	c3                   	ret    

008014e3 <close_all>:

void
close_all(void)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	53                   	push   %ebx
  8014e7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ea:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014ef:	83 ec 0c             	sub    $0xc,%esp
  8014f2:	53                   	push   %ebx
  8014f3:	e8 c0 ff ff ff       	call   8014b8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014f8:	83 c3 01             	add    $0x1,%ebx
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	83 fb 20             	cmp    $0x20,%ebx
  801501:	75 ec                	jne    8014ef <close_all+0xc>
		close(i);
}
  801503:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801506:	c9                   	leave  
  801507:	c3                   	ret    

00801508 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	57                   	push   %edi
  80150c:	56                   	push   %esi
  80150d:	53                   	push   %ebx
  80150e:	83 ec 2c             	sub    $0x2c,%esp
  801511:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801514:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801517:	50                   	push   %eax
  801518:	ff 75 08             	pushl  0x8(%ebp)
  80151b:	e8 6e fe ff ff       	call   80138e <fd_lookup>
  801520:	83 c4 08             	add    $0x8,%esp
  801523:	85 c0                	test   %eax,%eax
  801525:	0f 88 c1 00 00 00    	js     8015ec <dup+0xe4>
		return r;
	close(newfdnum);
  80152b:	83 ec 0c             	sub    $0xc,%esp
  80152e:	56                   	push   %esi
  80152f:	e8 84 ff ff ff       	call   8014b8 <close>

	newfd = INDEX2FD(newfdnum);
  801534:	89 f3                	mov    %esi,%ebx
  801536:	c1 e3 0c             	shl    $0xc,%ebx
  801539:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80153f:	83 c4 04             	add    $0x4,%esp
  801542:	ff 75 e4             	pushl  -0x1c(%ebp)
  801545:	e8 de fd ff ff       	call   801328 <fd2data>
  80154a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80154c:	89 1c 24             	mov    %ebx,(%esp)
  80154f:	e8 d4 fd ff ff       	call   801328 <fd2data>
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80155a:	89 f8                	mov    %edi,%eax
  80155c:	c1 e8 16             	shr    $0x16,%eax
  80155f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801566:	a8 01                	test   $0x1,%al
  801568:	74 37                	je     8015a1 <dup+0x99>
  80156a:	89 f8                	mov    %edi,%eax
  80156c:	c1 e8 0c             	shr    $0xc,%eax
  80156f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801576:	f6 c2 01             	test   $0x1,%dl
  801579:	74 26                	je     8015a1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80157b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801582:	83 ec 0c             	sub    $0xc,%esp
  801585:	25 07 0e 00 00       	and    $0xe07,%eax
  80158a:	50                   	push   %eax
  80158b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80158e:	6a 00                	push   $0x0
  801590:	57                   	push   %edi
  801591:	6a 00                	push   $0x0
  801593:	e8 ca f8 ff ff       	call   800e62 <sys_page_map>
  801598:	89 c7                	mov    %eax,%edi
  80159a:	83 c4 20             	add    $0x20,%esp
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 2e                	js     8015cf <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015a4:	89 d0                	mov    %edx,%eax
  8015a6:	c1 e8 0c             	shr    $0xc,%eax
  8015a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015b0:	83 ec 0c             	sub    $0xc,%esp
  8015b3:	25 07 0e 00 00       	and    $0xe07,%eax
  8015b8:	50                   	push   %eax
  8015b9:	53                   	push   %ebx
  8015ba:	6a 00                	push   $0x0
  8015bc:	52                   	push   %edx
  8015bd:	6a 00                	push   $0x0
  8015bf:	e8 9e f8 ff ff       	call   800e62 <sys_page_map>
  8015c4:	89 c7                	mov    %eax,%edi
  8015c6:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015c9:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015cb:	85 ff                	test   %edi,%edi
  8015cd:	79 1d                	jns    8015ec <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015cf:	83 ec 08             	sub    $0x8,%esp
  8015d2:	53                   	push   %ebx
  8015d3:	6a 00                	push   $0x0
  8015d5:	e8 ca f8 ff ff       	call   800ea4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015da:	83 c4 08             	add    $0x8,%esp
  8015dd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015e0:	6a 00                	push   $0x0
  8015e2:	e8 bd f8 ff ff       	call   800ea4 <sys_page_unmap>
	return r;
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	89 f8                	mov    %edi,%eax
}
  8015ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ef:	5b                   	pop    %ebx
  8015f0:	5e                   	pop    %esi
  8015f1:	5f                   	pop    %edi
  8015f2:	5d                   	pop    %ebp
  8015f3:	c3                   	ret    

008015f4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	53                   	push   %ebx
  8015f8:	83 ec 14             	sub    $0x14,%esp
  8015fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801601:	50                   	push   %eax
  801602:	53                   	push   %ebx
  801603:	e8 86 fd ff ff       	call   80138e <fd_lookup>
  801608:	83 c4 08             	add    $0x8,%esp
  80160b:	89 c2                	mov    %eax,%edx
  80160d:	85 c0                	test   %eax,%eax
  80160f:	78 6d                	js     80167e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801611:	83 ec 08             	sub    $0x8,%esp
  801614:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801617:	50                   	push   %eax
  801618:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161b:	ff 30                	pushl  (%eax)
  80161d:	e8 c2 fd ff ff       	call   8013e4 <dev_lookup>
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	85 c0                	test   %eax,%eax
  801627:	78 4c                	js     801675 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801629:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80162c:	8b 42 08             	mov    0x8(%edx),%eax
  80162f:	83 e0 03             	and    $0x3,%eax
  801632:	83 f8 01             	cmp    $0x1,%eax
  801635:	75 21                	jne    801658 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801637:	a1 08 40 80 00       	mov    0x804008,%eax
  80163c:	8b 40 48             	mov    0x48(%eax),%eax
  80163f:	83 ec 04             	sub    $0x4,%esp
  801642:	53                   	push   %ebx
  801643:	50                   	push   %eax
  801644:	68 a1 29 80 00       	push   $0x8029a1
  801649:	e8 23 ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801656:	eb 26                	jmp    80167e <read+0x8a>
	}
	if (!dev->dev_read)
  801658:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165b:	8b 40 08             	mov    0x8(%eax),%eax
  80165e:	85 c0                	test   %eax,%eax
  801660:	74 17                	je     801679 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801662:	83 ec 04             	sub    $0x4,%esp
  801665:	ff 75 10             	pushl  0x10(%ebp)
  801668:	ff 75 0c             	pushl  0xc(%ebp)
  80166b:	52                   	push   %edx
  80166c:	ff d0                	call   *%eax
  80166e:	89 c2                	mov    %eax,%edx
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	eb 09                	jmp    80167e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801675:	89 c2                	mov    %eax,%edx
  801677:	eb 05                	jmp    80167e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801679:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80167e:	89 d0                	mov    %edx,%eax
  801680:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801683:	c9                   	leave  
  801684:	c3                   	ret    

00801685 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	57                   	push   %edi
  801689:	56                   	push   %esi
  80168a:	53                   	push   %ebx
  80168b:	83 ec 0c             	sub    $0xc,%esp
  80168e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801691:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801694:	bb 00 00 00 00       	mov    $0x0,%ebx
  801699:	eb 21                	jmp    8016bc <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80169b:	83 ec 04             	sub    $0x4,%esp
  80169e:	89 f0                	mov    %esi,%eax
  8016a0:	29 d8                	sub    %ebx,%eax
  8016a2:	50                   	push   %eax
  8016a3:	89 d8                	mov    %ebx,%eax
  8016a5:	03 45 0c             	add    0xc(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	57                   	push   %edi
  8016aa:	e8 45 ff ff ff       	call   8015f4 <read>
		if (m < 0)
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	78 10                	js     8016c6 <readn+0x41>
			return m;
		if (m == 0)
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	74 0a                	je     8016c4 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016ba:	01 c3                	add    %eax,%ebx
  8016bc:	39 f3                	cmp    %esi,%ebx
  8016be:	72 db                	jb     80169b <readn+0x16>
  8016c0:	89 d8                	mov    %ebx,%eax
  8016c2:	eb 02                	jmp    8016c6 <readn+0x41>
  8016c4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c9:	5b                   	pop    %ebx
  8016ca:	5e                   	pop    %esi
  8016cb:	5f                   	pop    %edi
  8016cc:	5d                   	pop    %ebp
  8016cd:	c3                   	ret    

008016ce <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	53                   	push   %ebx
  8016d2:	83 ec 14             	sub    $0x14,%esp
  8016d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016db:	50                   	push   %eax
  8016dc:	53                   	push   %ebx
  8016dd:	e8 ac fc ff ff       	call   80138e <fd_lookup>
  8016e2:	83 c4 08             	add    $0x8,%esp
  8016e5:	89 c2                	mov    %eax,%edx
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	78 68                	js     801753 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016eb:	83 ec 08             	sub    $0x8,%esp
  8016ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f1:	50                   	push   %eax
  8016f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f5:	ff 30                	pushl  (%eax)
  8016f7:	e8 e8 fc ff ff       	call   8013e4 <dev_lookup>
  8016fc:	83 c4 10             	add    $0x10,%esp
  8016ff:	85 c0                	test   %eax,%eax
  801701:	78 47                	js     80174a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801703:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801706:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80170a:	75 21                	jne    80172d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80170c:	a1 08 40 80 00       	mov    0x804008,%eax
  801711:	8b 40 48             	mov    0x48(%eax),%eax
  801714:	83 ec 04             	sub    $0x4,%esp
  801717:	53                   	push   %ebx
  801718:	50                   	push   %eax
  801719:	68 bd 29 80 00       	push   $0x8029bd
  80171e:	e8 4e ec ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80172b:	eb 26                	jmp    801753 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80172d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801730:	8b 52 0c             	mov    0xc(%edx),%edx
  801733:	85 d2                	test   %edx,%edx
  801735:	74 17                	je     80174e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801737:	83 ec 04             	sub    $0x4,%esp
  80173a:	ff 75 10             	pushl  0x10(%ebp)
  80173d:	ff 75 0c             	pushl  0xc(%ebp)
  801740:	50                   	push   %eax
  801741:	ff d2                	call   *%edx
  801743:	89 c2                	mov    %eax,%edx
  801745:	83 c4 10             	add    $0x10,%esp
  801748:	eb 09                	jmp    801753 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174a:	89 c2                	mov    %eax,%edx
  80174c:	eb 05                	jmp    801753 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80174e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801753:	89 d0                	mov    %edx,%eax
  801755:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801758:	c9                   	leave  
  801759:	c3                   	ret    

0080175a <seek>:

int
seek(int fdnum, off_t offset)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801760:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801763:	50                   	push   %eax
  801764:	ff 75 08             	pushl  0x8(%ebp)
  801767:	e8 22 fc ff ff       	call   80138e <fd_lookup>
  80176c:	83 c4 08             	add    $0x8,%esp
  80176f:	85 c0                	test   %eax,%eax
  801771:	78 0e                	js     801781 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801773:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801776:	8b 55 0c             	mov    0xc(%ebp),%edx
  801779:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80177c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801781:	c9                   	leave  
  801782:	c3                   	ret    

00801783 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	53                   	push   %ebx
  801787:	83 ec 14             	sub    $0x14,%esp
  80178a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801790:	50                   	push   %eax
  801791:	53                   	push   %ebx
  801792:	e8 f7 fb ff ff       	call   80138e <fd_lookup>
  801797:	83 c4 08             	add    $0x8,%esp
  80179a:	89 c2                	mov    %eax,%edx
  80179c:	85 c0                	test   %eax,%eax
  80179e:	78 65                	js     801805 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a0:	83 ec 08             	sub    $0x8,%esp
  8017a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a6:	50                   	push   %eax
  8017a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017aa:	ff 30                	pushl  (%eax)
  8017ac:	e8 33 fc ff ff       	call   8013e4 <dev_lookup>
  8017b1:	83 c4 10             	add    $0x10,%esp
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	78 44                	js     8017fc <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017bf:	75 21                	jne    8017e2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017c1:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017c6:	8b 40 48             	mov    0x48(%eax),%eax
  8017c9:	83 ec 04             	sub    $0x4,%esp
  8017cc:	53                   	push   %ebx
  8017cd:	50                   	push   %eax
  8017ce:	68 80 29 80 00       	push   $0x802980
  8017d3:	e8 99 eb ff ff       	call   800371 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017d8:	83 c4 10             	add    $0x10,%esp
  8017db:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017e0:	eb 23                	jmp    801805 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e5:	8b 52 18             	mov    0x18(%edx),%edx
  8017e8:	85 d2                	test   %edx,%edx
  8017ea:	74 14                	je     801800 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017ec:	83 ec 08             	sub    $0x8,%esp
  8017ef:	ff 75 0c             	pushl  0xc(%ebp)
  8017f2:	50                   	push   %eax
  8017f3:	ff d2                	call   *%edx
  8017f5:	89 c2                	mov    %eax,%edx
  8017f7:	83 c4 10             	add    $0x10,%esp
  8017fa:	eb 09                	jmp    801805 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fc:	89 c2                	mov    %eax,%edx
  8017fe:	eb 05                	jmp    801805 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801800:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801805:	89 d0                	mov    %edx,%eax
  801807:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180a:	c9                   	leave  
  80180b:	c3                   	ret    

0080180c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	53                   	push   %ebx
  801810:	83 ec 14             	sub    $0x14,%esp
  801813:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801816:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801819:	50                   	push   %eax
  80181a:	ff 75 08             	pushl  0x8(%ebp)
  80181d:	e8 6c fb ff ff       	call   80138e <fd_lookup>
  801822:	83 c4 08             	add    $0x8,%esp
  801825:	89 c2                	mov    %eax,%edx
  801827:	85 c0                	test   %eax,%eax
  801829:	78 58                	js     801883 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182b:	83 ec 08             	sub    $0x8,%esp
  80182e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801831:	50                   	push   %eax
  801832:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801835:	ff 30                	pushl  (%eax)
  801837:	e8 a8 fb ff ff       	call   8013e4 <dev_lookup>
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	85 c0                	test   %eax,%eax
  801841:	78 37                	js     80187a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801843:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801846:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80184a:	74 32                	je     80187e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80184c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80184f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801856:	00 00 00 
	stat->st_isdir = 0;
  801859:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801860:	00 00 00 
	stat->st_dev = dev;
  801863:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801869:	83 ec 08             	sub    $0x8,%esp
  80186c:	53                   	push   %ebx
  80186d:	ff 75 f0             	pushl  -0x10(%ebp)
  801870:	ff 50 14             	call   *0x14(%eax)
  801873:	89 c2                	mov    %eax,%edx
  801875:	83 c4 10             	add    $0x10,%esp
  801878:	eb 09                	jmp    801883 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187a:	89 c2                	mov    %eax,%edx
  80187c:	eb 05                	jmp    801883 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80187e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801883:	89 d0                	mov    %edx,%eax
  801885:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801888:	c9                   	leave  
  801889:	c3                   	ret    

0080188a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	56                   	push   %esi
  80188e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80188f:	83 ec 08             	sub    $0x8,%esp
  801892:	6a 00                	push   $0x0
  801894:	ff 75 08             	pushl  0x8(%ebp)
  801897:	e8 2b 02 00 00       	call   801ac7 <open>
  80189c:	89 c3                	mov    %eax,%ebx
  80189e:	83 c4 10             	add    $0x10,%esp
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	78 1b                	js     8018c0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018a5:	83 ec 08             	sub    $0x8,%esp
  8018a8:	ff 75 0c             	pushl  0xc(%ebp)
  8018ab:	50                   	push   %eax
  8018ac:	e8 5b ff ff ff       	call   80180c <fstat>
  8018b1:	89 c6                	mov    %eax,%esi
	close(fd);
  8018b3:	89 1c 24             	mov    %ebx,(%esp)
  8018b6:	e8 fd fb ff ff       	call   8014b8 <close>
	return r;
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	89 f0                	mov    %esi,%eax
}
  8018c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c3:	5b                   	pop    %ebx
  8018c4:	5e                   	pop    %esi
  8018c5:	5d                   	pop    %ebp
  8018c6:	c3                   	ret    

008018c7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	56                   	push   %esi
  8018cb:	53                   	push   %ebx
  8018cc:	89 c6                	mov    %eax,%esi
  8018ce:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018d0:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8018d7:	75 12                	jne    8018eb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018d9:	83 ec 0c             	sub    $0xc,%esp
  8018dc:	6a 01                	push   $0x1
  8018de:	e8 b5 08 00 00       	call   802198 <ipc_find_env>
  8018e3:	a3 04 40 80 00       	mov    %eax,0x804004
  8018e8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018eb:	6a 07                	push   $0x7
  8018ed:	68 00 50 80 00       	push   $0x805000
  8018f2:	56                   	push   %esi
  8018f3:	ff 35 04 40 80 00    	pushl  0x804004
  8018f9:	e8 44 08 00 00       	call   802142 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8018fe:	83 c4 0c             	add    $0xc,%esp
  801901:	6a 00                	push   $0x0
  801903:	53                   	push   %ebx
  801904:	6a 00                	push   $0x0
  801906:	e8 ce 07 00 00       	call   8020d9 <ipc_recv>
}
  80190b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190e:	5b                   	pop    %ebx
  80190f:	5e                   	pop    %esi
  801910:	5d                   	pop    %ebp
  801911:	c3                   	ret    

00801912 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
  801915:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801918:	8b 45 08             	mov    0x8(%ebp),%eax
  80191b:	8b 40 0c             	mov    0xc(%eax),%eax
  80191e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801923:	8b 45 0c             	mov    0xc(%ebp),%eax
  801926:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80192b:	ba 00 00 00 00       	mov    $0x0,%edx
  801930:	b8 02 00 00 00       	mov    $0x2,%eax
  801935:	e8 8d ff ff ff       	call   8018c7 <fsipc>
}
  80193a:	c9                   	leave  
  80193b:	c3                   	ret    

0080193c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801942:	8b 45 08             	mov    0x8(%ebp),%eax
  801945:	8b 40 0c             	mov    0xc(%eax),%eax
  801948:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80194d:	ba 00 00 00 00       	mov    $0x0,%edx
  801952:	b8 06 00 00 00       	mov    $0x6,%eax
  801957:	e8 6b ff ff ff       	call   8018c7 <fsipc>
}
  80195c:	c9                   	leave  
  80195d:	c3                   	ret    

0080195e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	53                   	push   %ebx
  801962:	83 ec 04             	sub    $0x4,%esp
  801965:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801968:	8b 45 08             	mov    0x8(%ebp),%eax
  80196b:	8b 40 0c             	mov    0xc(%eax),%eax
  80196e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801973:	ba 00 00 00 00       	mov    $0x0,%edx
  801978:	b8 05 00 00 00       	mov    $0x5,%eax
  80197d:	e8 45 ff ff ff       	call   8018c7 <fsipc>
  801982:	85 c0                	test   %eax,%eax
  801984:	78 2c                	js     8019b2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801986:	83 ec 08             	sub    $0x8,%esp
  801989:	68 00 50 80 00       	push   $0x805000
  80198e:	53                   	push   %ebx
  80198f:	e8 11 f0 ff ff       	call   8009a5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801994:	a1 80 50 80 00       	mov    0x805080,%eax
  801999:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80199f:	a1 84 50 80 00       	mov    0x805084,%eax
  8019a4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019aa:	83 c4 10             	add    $0x10,%esp
  8019ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b5:	c9                   	leave  
  8019b6:	c3                   	ret    

008019b7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	53                   	push   %ebx
  8019bb:	83 ec 08             	sub    $0x8,%esp
  8019be:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019c6:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8019cb:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  8019d9:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8019df:	53                   	push   %ebx
  8019e0:	ff 75 0c             	pushl  0xc(%ebp)
  8019e3:	68 08 50 80 00       	push   $0x805008
  8019e8:	e8 4a f1 ff ff       	call   800b37 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8019ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f2:	b8 04 00 00 00       	mov    $0x4,%eax
  8019f7:	e8 cb fe ff ff       	call   8018c7 <fsipc>
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	78 3d                	js     801a40 <devfile_write+0x89>
		return r;

	assert(r <= n);
  801a03:	39 d8                	cmp    %ebx,%eax
  801a05:	76 19                	jbe    801a20 <devfile_write+0x69>
  801a07:	68 ec 29 80 00       	push   $0x8029ec
  801a0c:	68 f3 29 80 00       	push   $0x8029f3
  801a11:	68 9f 00 00 00       	push   $0x9f
  801a16:	68 08 2a 80 00       	push   $0x802a08
  801a1b:	e8 78 e8 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801a20:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a25:	76 19                	jbe    801a40 <devfile_write+0x89>
  801a27:	68 20 2a 80 00       	push   $0x802a20
  801a2c:	68 f3 29 80 00       	push   $0x8029f3
  801a31:	68 a0 00 00 00       	push   $0xa0
  801a36:	68 08 2a 80 00       	push   $0x802a08
  801a3b:	e8 58 e8 ff ff       	call   800298 <_panic>

	return r;
}
  801a40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a43:	c9                   	leave  
  801a44:	c3                   	ret    

00801a45 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	56                   	push   %esi
  801a49:	53                   	push   %ebx
  801a4a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a50:	8b 40 0c             	mov    0xc(%eax),%eax
  801a53:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a58:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a5e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a63:	b8 03 00 00 00       	mov    $0x3,%eax
  801a68:	e8 5a fe ff ff       	call   8018c7 <fsipc>
  801a6d:	89 c3                	mov    %eax,%ebx
  801a6f:	85 c0                	test   %eax,%eax
  801a71:	78 4b                	js     801abe <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a73:	39 c6                	cmp    %eax,%esi
  801a75:	73 16                	jae    801a8d <devfile_read+0x48>
  801a77:	68 ec 29 80 00       	push   $0x8029ec
  801a7c:	68 f3 29 80 00       	push   $0x8029f3
  801a81:	6a 7e                	push   $0x7e
  801a83:	68 08 2a 80 00       	push   $0x802a08
  801a88:	e8 0b e8 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE);
  801a8d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a92:	7e 16                	jle    801aaa <devfile_read+0x65>
  801a94:	68 13 2a 80 00       	push   $0x802a13
  801a99:	68 f3 29 80 00       	push   $0x8029f3
  801a9e:	6a 7f                	push   $0x7f
  801aa0:	68 08 2a 80 00       	push   $0x802a08
  801aa5:	e8 ee e7 ff ff       	call   800298 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801aaa:	83 ec 04             	sub    $0x4,%esp
  801aad:	50                   	push   %eax
  801aae:	68 00 50 80 00       	push   $0x805000
  801ab3:	ff 75 0c             	pushl  0xc(%ebp)
  801ab6:	e8 7c f0 ff ff       	call   800b37 <memmove>
	return r;
  801abb:	83 c4 10             	add    $0x10,%esp
}
  801abe:	89 d8                	mov    %ebx,%eax
  801ac0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac3:	5b                   	pop    %ebx
  801ac4:	5e                   	pop    %esi
  801ac5:	5d                   	pop    %ebp
  801ac6:	c3                   	ret    

00801ac7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	53                   	push   %ebx
  801acb:	83 ec 20             	sub    $0x20,%esp
  801ace:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ad1:	53                   	push   %ebx
  801ad2:	e8 95 ee ff ff       	call   80096c <strlen>
  801ad7:	83 c4 10             	add    $0x10,%esp
  801ada:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801adf:	7f 67                	jg     801b48 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ae1:	83 ec 0c             	sub    $0xc,%esp
  801ae4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae7:	50                   	push   %eax
  801ae8:	e8 52 f8 ff ff       	call   80133f <fd_alloc>
  801aed:	83 c4 10             	add    $0x10,%esp
		return r;
  801af0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801af2:	85 c0                	test   %eax,%eax
  801af4:	78 57                	js     801b4d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801af6:	83 ec 08             	sub    $0x8,%esp
  801af9:	53                   	push   %ebx
  801afa:	68 00 50 80 00       	push   $0x805000
  801aff:	e8 a1 ee ff ff       	call   8009a5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b07:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b0f:	b8 01 00 00 00       	mov    $0x1,%eax
  801b14:	e8 ae fd ff ff       	call   8018c7 <fsipc>
  801b19:	89 c3                	mov    %eax,%ebx
  801b1b:	83 c4 10             	add    $0x10,%esp
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	79 14                	jns    801b36 <open+0x6f>
		fd_close(fd, 0);
  801b22:	83 ec 08             	sub    $0x8,%esp
  801b25:	6a 00                	push   $0x0
  801b27:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2a:	e8 08 f9 ff ff       	call   801437 <fd_close>
		return r;
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	89 da                	mov    %ebx,%edx
  801b34:	eb 17                	jmp    801b4d <open+0x86>
	}

	return fd2num(fd);
  801b36:	83 ec 0c             	sub    $0xc,%esp
  801b39:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3c:	e8 d7 f7 ff ff       	call   801318 <fd2num>
  801b41:	89 c2                	mov    %eax,%edx
  801b43:	83 c4 10             	add    $0x10,%esp
  801b46:	eb 05                	jmp    801b4d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b48:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b4d:	89 d0                	mov    %edx,%eax
  801b4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b52:	c9                   	leave  
  801b53:	c3                   	ret    

00801b54 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b5a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b5f:	b8 08 00 00 00       	mov    $0x8,%eax
  801b64:	e8 5e fd ff ff       	call   8018c7 <fsipc>
}
  801b69:	c9                   	leave  
  801b6a:	c3                   	ret    

00801b6b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	56                   	push   %esi
  801b6f:	53                   	push   %ebx
  801b70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b73:	83 ec 0c             	sub    $0xc,%esp
  801b76:	ff 75 08             	pushl  0x8(%ebp)
  801b79:	e8 aa f7 ff ff       	call   801328 <fd2data>
  801b7e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b80:	83 c4 08             	add    $0x8,%esp
  801b83:	68 4d 2a 80 00       	push   $0x802a4d
  801b88:	53                   	push   %ebx
  801b89:	e8 17 ee ff ff       	call   8009a5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b8e:	8b 46 04             	mov    0x4(%esi),%eax
  801b91:	2b 06                	sub    (%esi),%eax
  801b93:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b99:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ba0:	00 00 00 
	stat->st_dev = &devpipe;
  801ba3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801baa:	30 80 00 
	return 0;
}
  801bad:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb5:	5b                   	pop    %ebx
  801bb6:	5e                   	pop    %esi
  801bb7:	5d                   	pop    %ebp
  801bb8:	c3                   	ret    

00801bb9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bb9:	55                   	push   %ebp
  801bba:	89 e5                	mov    %esp,%ebp
  801bbc:	53                   	push   %ebx
  801bbd:	83 ec 0c             	sub    $0xc,%esp
  801bc0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bc3:	53                   	push   %ebx
  801bc4:	6a 00                	push   $0x0
  801bc6:	e8 d9 f2 ff ff       	call   800ea4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bcb:	89 1c 24             	mov    %ebx,(%esp)
  801bce:	e8 55 f7 ff ff       	call   801328 <fd2data>
  801bd3:	83 c4 08             	add    $0x8,%esp
  801bd6:	50                   	push   %eax
  801bd7:	6a 00                	push   $0x0
  801bd9:	e8 c6 f2 ff ff       	call   800ea4 <sys_page_unmap>
}
  801bde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be1:	c9                   	leave  
  801be2:	c3                   	ret    

00801be3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801be3:	55                   	push   %ebp
  801be4:	89 e5                	mov    %esp,%ebp
  801be6:	57                   	push   %edi
  801be7:	56                   	push   %esi
  801be8:	53                   	push   %ebx
  801be9:	83 ec 1c             	sub    $0x1c,%esp
  801bec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bef:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bf1:	a1 08 40 80 00       	mov    0x804008,%eax
  801bf6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bf9:	83 ec 0c             	sub    $0xc,%esp
  801bfc:	ff 75 e0             	pushl  -0x20(%ebp)
  801bff:	e8 cd 05 00 00       	call   8021d1 <pageref>
  801c04:	89 c3                	mov    %eax,%ebx
  801c06:	89 3c 24             	mov    %edi,(%esp)
  801c09:	e8 c3 05 00 00       	call   8021d1 <pageref>
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	39 c3                	cmp    %eax,%ebx
  801c13:	0f 94 c1             	sete   %cl
  801c16:	0f b6 c9             	movzbl %cl,%ecx
  801c19:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c1c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801c22:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c25:	39 ce                	cmp    %ecx,%esi
  801c27:	74 1b                	je     801c44 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c29:	39 c3                	cmp    %eax,%ebx
  801c2b:	75 c4                	jne    801bf1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c2d:	8b 42 58             	mov    0x58(%edx),%eax
  801c30:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c33:	50                   	push   %eax
  801c34:	56                   	push   %esi
  801c35:	68 54 2a 80 00       	push   $0x802a54
  801c3a:	e8 32 e7 ff ff       	call   800371 <cprintf>
  801c3f:	83 c4 10             	add    $0x10,%esp
  801c42:	eb ad                	jmp    801bf1 <_pipeisclosed+0xe>
	}
}
  801c44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c4a:	5b                   	pop    %ebx
  801c4b:	5e                   	pop    %esi
  801c4c:	5f                   	pop    %edi
  801c4d:	5d                   	pop    %ebp
  801c4e:	c3                   	ret    

00801c4f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	57                   	push   %edi
  801c53:	56                   	push   %esi
  801c54:	53                   	push   %ebx
  801c55:	83 ec 28             	sub    $0x28,%esp
  801c58:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c5b:	56                   	push   %esi
  801c5c:	e8 c7 f6 ff ff       	call   801328 <fd2data>
  801c61:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	bf 00 00 00 00       	mov    $0x0,%edi
  801c6b:	eb 4b                	jmp    801cb8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c6d:	89 da                	mov    %ebx,%edx
  801c6f:	89 f0                	mov    %esi,%eax
  801c71:	e8 6d ff ff ff       	call   801be3 <_pipeisclosed>
  801c76:	85 c0                	test   %eax,%eax
  801c78:	75 48                	jne    801cc2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c7a:	e8 81 f1 ff ff       	call   800e00 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c7f:	8b 43 04             	mov    0x4(%ebx),%eax
  801c82:	8b 0b                	mov    (%ebx),%ecx
  801c84:	8d 51 20             	lea    0x20(%ecx),%edx
  801c87:	39 d0                	cmp    %edx,%eax
  801c89:	73 e2                	jae    801c6d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c8e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c92:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c95:	89 c2                	mov    %eax,%edx
  801c97:	c1 fa 1f             	sar    $0x1f,%edx
  801c9a:	89 d1                	mov    %edx,%ecx
  801c9c:	c1 e9 1b             	shr    $0x1b,%ecx
  801c9f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ca2:	83 e2 1f             	and    $0x1f,%edx
  801ca5:	29 ca                	sub    %ecx,%edx
  801ca7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cab:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801caf:	83 c0 01             	add    $0x1,%eax
  801cb2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb5:	83 c7 01             	add    $0x1,%edi
  801cb8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cbb:	75 c2                	jne    801c7f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cbd:	8b 45 10             	mov    0x10(%ebp),%eax
  801cc0:	eb 05                	jmp    801cc7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cc2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cca:	5b                   	pop    %ebx
  801ccb:	5e                   	pop    %esi
  801ccc:	5f                   	pop    %edi
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    

00801ccf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	57                   	push   %edi
  801cd3:	56                   	push   %esi
  801cd4:	53                   	push   %ebx
  801cd5:	83 ec 18             	sub    $0x18,%esp
  801cd8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cdb:	57                   	push   %edi
  801cdc:	e8 47 f6 ff ff       	call   801328 <fd2data>
  801ce1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce3:	83 c4 10             	add    $0x10,%esp
  801ce6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ceb:	eb 3d                	jmp    801d2a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ced:	85 db                	test   %ebx,%ebx
  801cef:	74 04                	je     801cf5 <devpipe_read+0x26>
				return i;
  801cf1:	89 d8                	mov    %ebx,%eax
  801cf3:	eb 44                	jmp    801d39 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cf5:	89 f2                	mov    %esi,%edx
  801cf7:	89 f8                	mov    %edi,%eax
  801cf9:	e8 e5 fe ff ff       	call   801be3 <_pipeisclosed>
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	75 32                	jne    801d34 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d02:	e8 f9 f0 ff ff       	call   800e00 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d07:	8b 06                	mov    (%esi),%eax
  801d09:	3b 46 04             	cmp    0x4(%esi),%eax
  801d0c:	74 df                	je     801ced <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d0e:	99                   	cltd   
  801d0f:	c1 ea 1b             	shr    $0x1b,%edx
  801d12:	01 d0                	add    %edx,%eax
  801d14:	83 e0 1f             	and    $0x1f,%eax
  801d17:	29 d0                	sub    %edx,%eax
  801d19:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d21:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d24:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d27:	83 c3 01             	add    $0x1,%ebx
  801d2a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d2d:	75 d8                	jne    801d07 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d2f:	8b 45 10             	mov    0x10(%ebp),%eax
  801d32:	eb 05                	jmp    801d39 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d34:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d3c:	5b                   	pop    %ebx
  801d3d:	5e                   	pop    %esi
  801d3e:	5f                   	pop    %edi
  801d3f:	5d                   	pop    %ebp
  801d40:	c3                   	ret    

00801d41 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	56                   	push   %esi
  801d45:	53                   	push   %ebx
  801d46:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4c:	50                   	push   %eax
  801d4d:	e8 ed f5 ff ff       	call   80133f <fd_alloc>
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	89 c2                	mov    %eax,%edx
  801d57:	85 c0                	test   %eax,%eax
  801d59:	0f 88 2c 01 00 00    	js     801e8b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5f:	83 ec 04             	sub    $0x4,%esp
  801d62:	68 07 04 00 00       	push   $0x407
  801d67:	ff 75 f4             	pushl  -0xc(%ebp)
  801d6a:	6a 00                	push   $0x0
  801d6c:	e8 ae f0 ff ff       	call   800e1f <sys_page_alloc>
  801d71:	83 c4 10             	add    $0x10,%esp
  801d74:	89 c2                	mov    %eax,%edx
  801d76:	85 c0                	test   %eax,%eax
  801d78:	0f 88 0d 01 00 00    	js     801e8b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d7e:	83 ec 0c             	sub    $0xc,%esp
  801d81:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d84:	50                   	push   %eax
  801d85:	e8 b5 f5 ff ff       	call   80133f <fd_alloc>
  801d8a:	89 c3                	mov    %eax,%ebx
  801d8c:	83 c4 10             	add    $0x10,%esp
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	0f 88 e2 00 00 00    	js     801e79 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d97:	83 ec 04             	sub    $0x4,%esp
  801d9a:	68 07 04 00 00       	push   $0x407
  801d9f:	ff 75 f0             	pushl  -0x10(%ebp)
  801da2:	6a 00                	push   $0x0
  801da4:	e8 76 f0 ff ff       	call   800e1f <sys_page_alloc>
  801da9:	89 c3                	mov    %eax,%ebx
  801dab:	83 c4 10             	add    $0x10,%esp
  801dae:	85 c0                	test   %eax,%eax
  801db0:	0f 88 c3 00 00 00    	js     801e79 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801db6:	83 ec 0c             	sub    $0xc,%esp
  801db9:	ff 75 f4             	pushl  -0xc(%ebp)
  801dbc:	e8 67 f5 ff ff       	call   801328 <fd2data>
  801dc1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc3:	83 c4 0c             	add    $0xc,%esp
  801dc6:	68 07 04 00 00       	push   $0x407
  801dcb:	50                   	push   %eax
  801dcc:	6a 00                	push   $0x0
  801dce:	e8 4c f0 ff ff       	call   800e1f <sys_page_alloc>
  801dd3:	89 c3                	mov    %eax,%ebx
  801dd5:	83 c4 10             	add    $0x10,%esp
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	0f 88 89 00 00 00    	js     801e69 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de0:	83 ec 0c             	sub    $0xc,%esp
  801de3:	ff 75 f0             	pushl  -0x10(%ebp)
  801de6:	e8 3d f5 ff ff       	call   801328 <fd2data>
  801deb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801df2:	50                   	push   %eax
  801df3:	6a 00                	push   $0x0
  801df5:	56                   	push   %esi
  801df6:	6a 00                	push   $0x0
  801df8:	e8 65 f0 ff ff       	call   800e62 <sys_page_map>
  801dfd:	89 c3                	mov    %eax,%ebx
  801dff:	83 c4 20             	add    $0x20,%esp
  801e02:	85 c0                	test   %eax,%eax
  801e04:	78 55                	js     801e5b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e06:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e14:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e1b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e24:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e29:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e30:	83 ec 0c             	sub    $0xc,%esp
  801e33:	ff 75 f4             	pushl  -0xc(%ebp)
  801e36:	e8 dd f4 ff ff       	call   801318 <fd2num>
  801e3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e3e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e40:	83 c4 04             	add    $0x4,%esp
  801e43:	ff 75 f0             	pushl  -0x10(%ebp)
  801e46:	e8 cd f4 ff ff       	call   801318 <fd2num>
  801e4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e4e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e51:	83 c4 10             	add    $0x10,%esp
  801e54:	ba 00 00 00 00       	mov    $0x0,%edx
  801e59:	eb 30                	jmp    801e8b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e5b:	83 ec 08             	sub    $0x8,%esp
  801e5e:	56                   	push   %esi
  801e5f:	6a 00                	push   $0x0
  801e61:	e8 3e f0 ff ff       	call   800ea4 <sys_page_unmap>
  801e66:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e69:	83 ec 08             	sub    $0x8,%esp
  801e6c:	ff 75 f0             	pushl  -0x10(%ebp)
  801e6f:	6a 00                	push   $0x0
  801e71:	e8 2e f0 ff ff       	call   800ea4 <sys_page_unmap>
  801e76:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e79:	83 ec 08             	sub    $0x8,%esp
  801e7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e7f:	6a 00                	push   $0x0
  801e81:	e8 1e f0 ff ff       	call   800ea4 <sys_page_unmap>
  801e86:	83 c4 10             	add    $0x10,%esp
  801e89:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e8b:	89 d0                	mov    %edx,%eax
  801e8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e90:	5b                   	pop    %ebx
  801e91:	5e                   	pop    %esi
  801e92:	5d                   	pop    %ebp
  801e93:	c3                   	ret    

00801e94 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e9d:	50                   	push   %eax
  801e9e:	ff 75 08             	pushl  0x8(%ebp)
  801ea1:	e8 e8 f4 ff ff       	call   80138e <fd_lookup>
  801ea6:	83 c4 10             	add    $0x10,%esp
  801ea9:	85 c0                	test   %eax,%eax
  801eab:	78 18                	js     801ec5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ead:	83 ec 0c             	sub    $0xc,%esp
  801eb0:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb3:	e8 70 f4 ff ff       	call   801328 <fd2data>
	return _pipeisclosed(fd, p);
  801eb8:	89 c2                	mov    %eax,%edx
  801eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebd:	e8 21 fd ff ff       	call   801be3 <_pipeisclosed>
  801ec2:	83 c4 10             	add    $0x10,%esp
}
  801ec5:	c9                   	leave  
  801ec6:	c3                   	ret    

00801ec7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801eca:	b8 00 00 00 00       	mov    $0x0,%eax
  801ecf:	5d                   	pop    %ebp
  801ed0:	c3                   	ret    

00801ed1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ed7:	68 67 2a 80 00       	push   $0x802a67
  801edc:	ff 75 0c             	pushl  0xc(%ebp)
  801edf:	e8 c1 ea ff ff       	call   8009a5 <strcpy>
	return 0;
}
  801ee4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee9:	c9                   	leave  
  801eea:	c3                   	ret    

00801eeb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	57                   	push   %edi
  801eef:	56                   	push   %esi
  801ef0:	53                   	push   %ebx
  801ef1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ef7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801efc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f02:	eb 2d                	jmp    801f31 <devcons_write+0x46>
		m = n - tot;
  801f04:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f07:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f09:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f0c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f11:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f14:	83 ec 04             	sub    $0x4,%esp
  801f17:	53                   	push   %ebx
  801f18:	03 45 0c             	add    0xc(%ebp),%eax
  801f1b:	50                   	push   %eax
  801f1c:	57                   	push   %edi
  801f1d:	e8 15 ec ff ff       	call   800b37 <memmove>
		sys_cputs(buf, m);
  801f22:	83 c4 08             	add    $0x8,%esp
  801f25:	53                   	push   %ebx
  801f26:	57                   	push   %edi
  801f27:	e8 37 ee ff ff       	call   800d63 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f2c:	01 de                	add    %ebx,%esi
  801f2e:	83 c4 10             	add    $0x10,%esp
  801f31:	89 f0                	mov    %esi,%eax
  801f33:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f36:	72 cc                	jb     801f04 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3b:	5b                   	pop    %ebx
  801f3c:	5e                   	pop    %esi
  801f3d:	5f                   	pop    %edi
  801f3e:	5d                   	pop    %ebp
  801f3f:	c3                   	ret    

00801f40 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	83 ec 08             	sub    $0x8,%esp
  801f46:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f4b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f4f:	74 2a                	je     801f7b <devcons_read+0x3b>
  801f51:	eb 05                	jmp    801f58 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f53:	e8 a8 ee ff ff       	call   800e00 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f58:	e8 24 ee ff ff       	call   800d81 <sys_cgetc>
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	74 f2                	je     801f53 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f61:	85 c0                	test   %eax,%eax
  801f63:	78 16                	js     801f7b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f65:	83 f8 04             	cmp    $0x4,%eax
  801f68:	74 0c                	je     801f76 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f6d:	88 02                	mov    %al,(%edx)
	return 1;
  801f6f:	b8 01 00 00 00       	mov    $0x1,%eax
  801f74:	eb 05                	jmp    801f7b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f76:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f7b:	c9                   	leave  
  801f7c:	c3                   	ret    

00801f7d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f7d:	55                   	push   %ebp
  801f7e:	89 e5                	mov    %esp,%ebp
  801f80:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f83:	8b 45 08             	mov    0x8(%ebp),%eax
  801f86:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f89:	6a 01                	push   $0x1
  801f8b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f8e:	50                   	push   %eax
  801f8f:	e8 cf ed ff ff       	call   800d63 <sys_cputs>
}
  801f94:	83 c4 10             	add    $0x10,%esp
  801f97:	c9                   	leave  
  801f98:	c3                   	ret    

00801f99 <getchar>:

int
getchar(void)
{
  801f99:	55                   	push   %ebp
  801f9a:	89 e5                	mov    %esp,%ebp
  801f9c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f9f:	6a 01                	push   $0x1
  801fa1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fa4:	50                   	push   %eax
  801fa5:	6a 00                	push   $0x0
  801fa7:	e8 48 f6 ff ff       	call   8015f4 <read>
	if (r < 0)
  801fac:	83 c4 10             	add    $0x10,%esp
  801faf:	85 c0                	test   %eax,%eax
  801fb1:	78 0f                	js     801fc2 <getchar+0x29>
		return r;
	if (r < 1)
  801fb3:	85 c0                	test   %eax,%eax
  801fb5:	7e 06                	jle    801fbd <getchar+0x24>
		return -E_EOF;
	return c;
  801fb7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fbb:	eb 05                	jmp    801fc2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fbd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fc2:	c9                   	leave  
  801fc3:	c3                   	ret    

00801fc4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fcd:	50                   	push   %eax
  801fce:	ff 75 08             	pushl  0x8(%ebp)
  801fd1:	e8 b8 f3 ff ff       	call   80138e <fd_lookup>
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	78 11                	js     801fee <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fe6:	39 10                	cmp    %edx,(%eax)
  801fe8:	0f 94 c0             	sete   %al
  801feb:	0f b6 c0             	movzbl %al,%eax
}
  801fee:	c9                   	leave  
  801fef:	c3                   	ret    

00801ff0 <opencons>:

int
opencons(void)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ff6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff9:	50                   	push   %eax
  801ffa:	e8 40 f3 ff ff       	call   80133f <fd_alloc>
  801fff:	83 c4 10             	add    $0x10,%esp
		return r;
  802002:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802004:	85 c0                	test   %eax,%eax
  802006:	78 3e                	js     802046 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802008:	83 ec 04             	sub    $0x4,%esp
  80200b:	68 07 04 00 00       	push   $0x407
  802010:	ff 75 f4             	pushl  -0xc(%ebp)
  802013:	6a 00                	push   $0x0
  802015:	e8 05 ee ff ff       	call   800e1f <sys_page_alloc>
  80201a:	83 c4 10             	add    $0x10,%esp
		return r;
  80201d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80201f:	85 c0                	test   %eax,%eax
  802021:	78 23                	js     802046 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802023:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802029:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80202e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802031:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802038:	83 ec 0c             	sub    $0xc,%esp
  80203b:	50                   	push   %eax
  80203c:	e8 d7 f2 ff ff       	call   801318 <fd2num>
  802041:	89 c2                	mov    %eax,%edx
  802043:	83 c4 10             	add    $0x10,%esp
}
  802046:	89 d0                	mov    %edx,%eax
  802048:	c9                   	leave  
  802049:	c3                   	ret    

0080204a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
  80204d:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  802050:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802057:	75 52                	jne    8020ab <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  802059:	83 ec 04             	sub    $0x4,%esp
  80205c:	6a 07                	push   $0x7
  80205e:	68 00 f0 bf ee       	push   $0xeebff000
  802063:	6a 00                	push   $0x0
  802065:	e8 b5 ed ff ff       	call   800e1f <sys_page_alloc>
  80206a:	83 c4 10             	add    $0x10,%esp
  80206d:	85 c0                	test   %eax,%eax
  80206f:	79 12                	jns    802083 <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  802071:	50                   	push   %eax
  802072:	68 c0 28 80 00       	push   $0x8028c0
  802077:	6a 23                	push   $0x23
  802079:	68 73 2a 80 00       	push   $0x802a73
  80207e:	e8 15 e2 ff ff       	call   800298 <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  802083:	83 ec 08             	sub    $0x8,%esp
  802086:	68 b5 20 80 00       	push   $0x8020b5
  80208b:	6a 00                	push   $0x0
  80208d:	e8 d8 ee ff ff       	call   800f6a <sys_env_set_pgfault_upcall>
  802092:	83 c4 10             	add    $0x10,%esp
  802095:	85 c0                	test   %eax,%eax
  802097:	79 12                	jns    8020ab <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  802099:	50                   	push   %eax
  80209a:	68 40 29 80 00       	push   $0x802940
  80209f:	6a 26                	push   $0x26
  8020a1:	68 73 2a 80 00       	push   $0x802a73
  8020a6:	e8 ed e1 ff ff       	call   800298 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ae:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8020b3:	c9                   	leave  
  8020b4:	c3                   	ret    

008020b5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020b5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020b6:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020bb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020bd:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  8020c0:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  8020c4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  8020c9:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  8020cd:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8020cf:	83 c4 08             	add    $0x8,%esp
	popal 
  8020d2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8020d3:	83 c4 04             	add    $0x4,%esp
	popfl
  8020d6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8020d7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020d8:	c3                   	ret    

008020d9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020d9:	55                   	push   %ebp
  8020da:	89 e5                	mov    %esp,%ebp
  8020dc:	56                   	push   %esi
  8020dd:	53                   	push   %ebx
  8020de:	8b 75 08             	mov    0x8(%ebp),%esi
  8020e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  8020e7:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8020e9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8020ee:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  8020f1:	83 ec 0c             	sub    $0xc,%esp
  8020f4:	50                   	push   %eax
  8020f5:	e8 d5 ee ff ff       	call   800fcf <sys_ipc_recv>
  8020fa:	83 c4 10             	add    $0x10,%esp
  8020fd:	85 c0                	test   %eax,%eax
  8020ff:	79 16                	jns    802117 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  802101:	85 f6                	test   %esi,%esi
  802103:	74 06                	je     80210b <ipc_recv+0x32>
			*from_env_store = 0;
  802105:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  80210b:	85 db                	test   %ebx,%ebx
  80210d:	74 2c                	je     80213b <ipc_recv+0x62>
			*perm_store = 0;
  80210f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802115:	eb 24                	jmp    80213b <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  802117:	85 f6                	test   %esi,%esi
  802119:	74 0a                	je     802125 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  80211b:	a1 08 40 80 00       	mov    0x804008,%eax
  802120:	8b 40 74             	mov    0x74(%eax),%eax
  802123:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  802125:	85 db                	test   %ebx,%ebx
  802127:	74 0a                	je     802133 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  802129:	a1 08 40 80 00       	mov    0x804008,%eax
  80212e:	8b 40 78             	mov    0x78(%eax),%eax
  802131:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  802133:	a1 08 40 80 00       	mov    0x804008,%eax
  802138:	8b 40 70             	mov    0x70(%eax),%eax
}
  80213b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80213e:	5b                   	pop    %ebx
  80213f:	5e                   	pop    %esi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    

00802142 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802142:	55                   	push   %ebp
  802143:	89 e5                	mov    %esp,%ebp
  802145:	57                   	push   %edi
  802146:	56                   	push   %esi
  802147:	53                   	push   %ebx
  802148:	83 ec 0c             	sub    $0xc,%esp
  80214b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80214e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802151:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  802154:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802156:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80215b:	0f 44 d8             	cmove  %eax,%ebx
  80215e:	eb 1e                	jmp    80217e <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  802160:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802163:	74 14                	je     802179 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  802165:	83 ec 04             	sub    $0x4,%esp
  802168:	68 84 2a 80 00       	push   $0x802a84
  80216d:	6a 44                	push   $0x44
  80216f:	68 b0 2a 80 00       	push   $0x802ab0
  802174:	e8 1f e1 ff ff       	call   800298 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  802179:	e8 82 ec ff ff       	call   800e00 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80217e:	ff 75 14             	pushl  0x14(%ebp)
  802181:	53                   	push   %ebx
  802182:	56                   	push   %esi
  802183:	57                   	push   %edi
  802184:	e8 23 ee ff ff       	call   800fac <sys_ipc_try_send>
  802189:	83 c4 10             	add    $0x10,%esp
  80218c:	85 c0                	test   %eax,%eax
  80218e:	78 d0                	js     802160 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  802190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802193:	5b                   	pop    %ebx
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    

00802198 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80219e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021a3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8021a6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021ac:	8b 52 50             	mov    0x50(%edx),%edx
  8021af:	39 ca                	cmp    %ecx,%edx
  8021b1:	75 0d                	jne    8021c0 <ipc_find_env+0x28>
			return envs[i].env_id;
  8021b3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021b6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021bb:	8b 40 48             	mov    0x48(%eax),%eax
  8021be:	eb 0f                	jmp    8021cf <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021c0:	83 c0 01             	add    $0x1,%eax
  8021c3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021c8:	75 d9                	jne    8021a3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021cf:	5d                   	pop    %ebp
  8021d0:	c3                   	ret    

008021d1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021d1:	55                   	push   %ebp
  8021d2:	89 e5                	mov    %esp,%ebp
  8021d4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021d7:	89 d0                	mov    %edx,%eax
  8021d9:	c1 e8 16             	shr    $0x16,%eax
  8021dc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021e3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021e8:	f6 c1 01             	test   $0x1,%cl
  8021eb:	74 1d                	je     80220a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021ed:	c1 ea 0c             	shr    $0xc,%edx
  8021f0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021f7:	f6 c2 01             	test   $0x1,%dl
  8021fa:	74 0e                	je     80220a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021fc:	c1 ea 0c             	shr    $0xc,%edx
  8021ff:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802206:	ef 
  802207:	0f b7 c0             	movzwl %ax,%eax
}
  80220a:	5d                   	pop    %ebp
  80220b:	c3                   	ret    
  80220c:	66 90                	xchg   %ax,%ax
  80220e:	66 90                	xchg   %ax,%ax

00802210 <__udivdi3>:
  802210:	55                   	push   %ebp
  802211:	57                   	push   %edi
  802212:	56                   	push   %esi
  802213:	53                   	push   %ebx
  802214:	83 ec 1c             	sub    $0x1c,%esp
  802217:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80221b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80221f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802223:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802227:	85 f6                	test   %esi,%esi
  802229:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80222d:	89 ca                	mov    %ecx,%edx
  80222f:	89 f8                	mov    %edi,%eax
  802231:	75 3d                	jne    802270 <__udivdi3+0x60>
  802233:	39 cf                	cmp    %ecx,%edi
  802235:	0f 87 c5 00 00 00    	ja     802300 <__udivdi3+0xf0>
  80223b:	85 ff                	test   %edi,%edi
  80223d:	89 fd                	mov    %edi,%ebp
  80223f:	75 0b                	jne    80224c <__udivdi3+0x3c>
  802241:	b8 01 00 00 00       	mov    $0x1,%eax
  802246:	31 d2                	xor    %edx,%edx
  802248:	f7 f7                	div    %edi
  80224a:	89 c5                	mov    %eax,%ebp
  80224c:	89 c8                	mov    %ecx,%eax
  80224e:	31 d2                	xor    %edx,%edx
  802250:	f7 f5                	div    %ebp
  802252:	89 c1                	mov    %eax,%ecx
  802254:	89 d8                	mov    %ebx,%eax
  802256:	89 cf                	mov    %ecx,%edi
  802258:	f7 f5                	div    %ebp
  80225a:	89 c3                	mov    %eax,%ebx
  80225c:	89 d8                	mov    %ebx,%eax
  80225e:	89 fa                	mov    %edi,%edx
  802260:	83 c4 1c             	add    $0x1c,%esp
  802263:	5b                   	pop    %ebx
  802264:	5e                   	pop    %esi
  802265:	5f                   	pop    %edi
  802266:	5d                   	pop    %ebp
  802267:	c3                   	ret    
  802268:	90                   	nop
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	39 ce                	cmp    %ecx,%esi
  802272:	77 74                	ja     8022e8 <__udivdi3+0xd8>
  802274:	0f bd fe             	bsr    %esi,%edi
  802277:	83 f7 1f             	xor    $0x1f,%edi
  80227a:	0f 84 98 00 00 00    	je     802318 <__udivdi3+0x108>
  802280:	bb 20 00 00 00       	mov    $0x20,%ebx
  802285:	89 f9                	mov    %edi,%ecx
  802287:	89 c5                	mov    %eax,%ebp
  802289:	29 fb                	sub    %edi,%ebx
  80228b:	d3 e6                	shl    %cl,%esi
  80228d:	89 d9                	mov    %ebx,%ecx
  80228f:	d3 ed                	shr    %cl,%ebp
  802291:	89 f9                	mov    %edi,%ecx
  802293:	d3 e0                	shl    %cl,%eax
  802295:	09 ee                	or     %ebp,%esi
  802297:	89 d9                	mov    %ebx,%ecx
  802299:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80229d:	89 d5                	mov    %edx,%ebp
  80229f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022a3:	d3 ed                	shr    %cl,%ebp
  8022a5:	89 f9                	mov    %edi,%ecx
  8022a7:	d3 e2                	shl    %cl,%edx
  8022a9:	89 d9                	mov    %ebx,%ecx
  8022ab:	d3 e8                	shr    %cl,%eax
  8022ad:	09 c2                	or     %eax,%edx
  8022af:	89 d0                	mov    %edx,%eax
  8022b1:	89 ea                	mov    %ebp,%edx
  8022b3:	f7 f6                	div    %esi
  8022b5:	89 d5                	mov    %edx,%ebp
  8022b7:	89 c3                	mov    %eax,%ebx
  8022b9:	f7 64 24 0c          	mull   0xc(%esp)
  8022bd:	39 d5                	cmp    %edx,%ebp
  8022bf:	72 10                	jb     8022d1 <__udivdi3+0xc1>
  8022c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022c5:	89 f9                	mov    %edi,%ecx
  8022c7:	d3 e6                	shl    %cl,%esi
  8022c9:	39 c6                	cmp    %eax,%esi
  8022cb:	73 07                	jae    8022d4 <__udivdi3+0xc4>
  8022cd:	39 d5                	cmp    %edx,%ebp
  8022cf:	75 03                	jne    8022d4 <__udivdi3+0xc4>
  8022d1:	83 eb 01             	sub    $0x1,%ebx
  8022d4:	31 ff                	xor    %edi,%edi
  8022d6:	89 d8                	mov    %ebx,%eax
  8022d8:	89 fa                	mov    %edi,%edx
  8022da:	83 c4 1c             	add    $0x1c,%esp
  8022dd:	5b                   	pop    %ebx
  8022de:	5e                   	pop    %esi
  8022df:	5f                   	pop    %edi
  8022e0:	5d                   	pop    %ebp
  8022e1:	c3                   	ret    
  8022e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e8:	31 ff                	xor    %edi,%edi
  8022ea:	31 db                	xor    %ebx,%ebx
  8022ec:	89 d8                	mov    %ebx,%eax
  8022ee:	89 fa                	mov    %edi,%edx
  8022f0:	83 c4 1c             	add    $0x1c,%esp
  8022f3:	5b                   	pop    %ebx
  8022f4:	5e                   	pop    %esi
  8022f5:	5f                   	pop    %edi
  8022f6:	5d                   	pop    %ebp
  8022f7:	c3                   	ret    
  8022f8:	90                   	nop
  8022f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802300:	89 d8                	mov    %ebx,%eax
  802302:	f7 f7                	div    %edi
  802304:	31 ff                	xor    %edi,%edi
  802306:	89 c3                	mov    %eax,%ebx
  802308:	89 d8                	mov    %ebx,%eax
  80230a:	89 fa                	mov    %edi,%edx
  80230c:	83 c4 1c             	add    $0x1c,%esp
  80230f:	5b                   	pop    %ebx
  802310:	5e                   	pop    %esi
  802311:	5f                   	pop    %edi
  802312:	5d                   	pop    %ebp
  802313:	c3                   	ret    
  802314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802318:	39 ce                	cmp    %ecx,%esi
  80231a:	72 0c                	jb     802328 <__udivdi3+0x118>
  80231c:	31 db                	xor    %ebx,%ebx
  80231e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802322:	0f 87 34 ff ff ff    	ja     80225c <__udivdi3+0x4c>
  802328:	bb 01 00 00 00       	mov    $0x1,%ebx
  80232d:	e9 2a ff ff ff       	jmp    80225c <__udivdi3+0x4c>
  802332:	66 90                	xchg   %ax,%ax
  802334:	66 90                	xchg   %ax,%ax
  802336:	66 90                	xchg   %ax,%ax
  802338:	66 90                	xchg   %ax,%ax
  80233a:	66 90                	xchg   %ax,%ax
  80233c:	66 90                	xchg   %ax,%ax
  80233e:	66 90                	xchg   %ax,%ax

00802340 <__umoddi3>:
  802340:	55                   	push   %ebp
  802341:	57                   	push   %edi
  802342:	56                   	push   %esi
  802343:	53                   	push   %ebx
  802344:	83 ec 1c             	sub    $0x1c,%esp
  802347:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80234b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80234f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802353:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802357:	85 d2                	test   %edx,%edx
  802359:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80235d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802361:	89 f3                	mov    %esi,%ebx
  802363:	89 3c 24             	mov    %edi,(%esp)
  802366:	89 74 24 04          	mov    %esi,0x4(%esp)
  80236a:	75 1c                	jne    802388 <__umoddi3+0x48>
  80236c:	39 f7                	cmp    %esi,%edi
  80236e:	76 50                	jbe    8023c0 <__umoddi3+0x80>
  802370:	89 c8                	mov    %ecx,%eax
  802372:	89 f2                	mov    %esi,%edx
  802374:	f7 f7                	div    %edi
  802376:	89 d0                	mov    %edx,%eax
  802378:	31 d2                	xor    %edx,%edx
  80237a:	83 c4 1c             	add    $0x1c,%esp
  80237d:	5b                   	pop    %ebx
  80237e:	5e                   	pop    %esi
  80237f:	5f                   	pop    %edi
  802380:	5d                   	pop    %ebp
  802381:	c3                   	ret    
  802382:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802388:	39 f2                	cmp    %esi,%edx
  80238a:	89 d0                	mov    %edx,%eax
  80238c:	77 52                	ja     8023e0 <__umoddi3+0xa0>
  80238e:	0f bd ea             	bsr    %edx,%ebp
  802391:	83 f5 1f             	xor    $0x1f,%ebp
  802394:	75 5a                	jne    8023f0 <__umoddi3+0xb0>
  802396:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80239a:	0f 82 e0 00 00 00    	jb     802480 <__umoddi3+0x140>
  8023a0:	39 0c 24             	cmp    %ecx,(%esp)
  8023a3:	0f 86 d7 00 00 00    	jbe    802480 <__umoddi3+0x140>
  8023a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023b1:	83 c4 1c             	add    $0x1c,%esp
  8023b4:	5b                   	pop    %ebx
  8023b5:	5e                   	pop    %esi
  8023b6:	5f                   	pop    %edi
  8023b7:	5d                   	pop    %ebp
  8023b8:	c3                   	ret    
  8023b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	85 ff                	test   %edi,%edi
  8023c2:	89 fd                	mov    %edi,%ebp
  8023c4:	75 0b                	jne    8023d1 <__umoddi3+0x91>
  8023c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023cb:	31 d2                	xor    %edx,%edx
  8023cd:	f7 f7                	div    %edi
  8023cf:	89 c5                	mov    %eax,%ebp
  8023d1:	89 f0                	mov    %esi,%eax
  8023d3:	31 d2                	xor    %edx,%edx
  8023d5:	f7 f5                	div    %ebp
  8023d7:	89 c8                	mov    %ecx,%eax
  8023d9:	f7 f5                	div    %ebp
  8023db:	89 d0                	mov    %edx,%eax
  8023dd:	eb 99                	jmp    802378 <__umoddi3+0x38>
  8023df:	90                   	nop
  8023e0:	89 c8                	mov    %ecx,%eax
  8023e2:	89 f2                	mov    %esi,%edx
  8023e4:	83 c4 1c             	add    $0x1c,%esp
  8023e7:	5b                   	pop    %ebx
  8023e8:	5e                   	pop    %esi
  8023e9:	5f                   	pop    %edi
  8023ea:	5d                   	pop    %ebp
  8023eb:	c3                   	ret    
  8023ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	8b 34 24             	mov    (%esp),%esi
  8023f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023f8:	89 e9                	mov    %ebp,%ecx
  8023fa:	29 ef                	sub    %ebp,%edi
  8023fc:	d3 e0                	shl    %cl,%eax
  8023fe:	89 f9                	mov    %edi,%ecx
  802400:	89 f2                	mov    %esi,%edx
  802402:	d3 ea                	shr    %cl,%edx
  802404:	89 e9                	mov    %ebp,%ecx
  802406:	09 c2                	or     %eax,%edx
  802408:	89 d8                	mov    %ebx,%eax
  80240a:	89 14 24             	mov    %edx,(%esp)
  80240d:	89 f2                	mov    %esi,%edx
  80240f:	d3 e2                	shl    %cl,%edx
  802411:	89 f9                	mov    %edi,%ecx
  802413:	89 54 24 04          	mov    %edx,0x4(%esp)
  802417:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80241b:	d3 e8                	shr    %cl,%eax
  80241d:	89 e9                	mov    %ebp,%ecx
  80241f:	89 c6                	mov    %eax,%esi
  802421:	d3 e3                	shl    %cl,%ebx
  802423:	89 f9                	mov    %edi,%ecx
  802425:	89 d0                	mov    %edx,%eax
  802427:	d3 e8                	shr    %cl,%eax
  802429:	89 e9                	mov    %ebp,%ecx
  80242b:	09 d8                	or     %ebx,%eax
  80242d:	89 d3                	mov    %edx,%ebx
  80242f:	89 f2                	mov    %esi,%edx
  802431:	f7 34 24             	divl   (%esp)
  802434:	89 d6                	mov    %edx,%esi
  802436:	d3 e3                	shl    %cl,%ebx
  802438:	f7 64 24 04          	mull   0x4(%esp)
  80243c:	39 d6                	cmp    %edx,%esi
  80243e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802442:	89 d1                	mov    %edx,%ecx
  802444:	89 c3                	mov    %eax,%ebx
  802446:	72 08                	jb     802450 <__umoddi3+0x110>
  802448:	75 11                	jne    80245b <__umoddi3+0x11b>
  80244a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80244e:	73 0b                	jae    80245b <__umoddi3+0x11b>
  802450:	2b 44 24 04          	sub    0x4(%esp),%eax
  802454:	1b 14 24             	sbb    (%esp),%edx
  802457:	89 d1                	mov    %edx,%ecx
  802459:	89 c3                	mov    %eax,%ebx
  80245b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80245f:	29 da                	sub    %ebx,%edx
  802461:	19 ce                	sbb    %ecx,%esi
  802463:	89 f9                	mov    %edi,%ecx
  802465:	89 f0                	mov    %esi,%eax
  802467:	d3 e0                	shl    %cl,%eax
  802469:	89 e9                	mov    %ebp,%ecx
  80246b:	d3 ea                	shr    %cl,%edx
  80246d:	89 e9                	mov    %ebp,%ecx
  80246f:	d3 ee                	shr    %cl,%esi
  802471:	09 d0                	or     %edx,%eax
  802473:	89 f2                	mov    %esi,%edx
  802475:	83 c4 1c             	add    $0x1c,%esp
  802478:	5b                   	pop    %ebx
  802479:	5e                   	pop    %esi
  80247a:	5f                   	pop    %edi
  80247b:	5d                   	pop    %ebp
  80247c:	c3                   	ret    
  80247d:	8d 76 00             	lea    0x0(%esi),%esi
  802480:	29 f9                	sub    %edi,%ecx
  802482:	19 d6                	sbb    %edx,%esi
  802484:	89 74 24 04          	mov    %esi,0x4(%esp)
  802488:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80248c:	e9 18 ff ff ff       	jmp    8023a9 <__umoddi3+0x69>
