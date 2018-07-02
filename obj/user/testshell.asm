
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 53 04 00 00       	call   800484 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 57 19 00 00       	call   8019a6 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 4d 19 00 00       	call   8019a6 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 eb 2b 80 00 	movl   $0x802beb,(%esp)
  80006c:	e8 4c 05 00 00       	call   8005bd <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 2c 0f 00 00       	call   800faf <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 ae 17 00 00       	call   801840 <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 fa 2b 80 00       	push   $0x802bfa
  8000a1:	e8 17 05 00 00       	call   8005bd <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 f7 0e 00 00       	call   800faf <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 79 17 00 00       	call   801840 <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 f5 2b 80 00       	push   $0x802bf5
  8000d6:	e8 e2 04 00 00       	call   8005bd <cprintf>
	exit();
  8000db:	e8 ea 03 00 00       	call   8004ca <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 09 16 00 00       	call   801704 <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 fd 15 00 00       	call   801704 <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 08 2c 80 00       	push   $0x802c08
  80011b:	e8 f3 1b 00 00       	call   801d13 <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 15 2c 80 00       	push   $0x802c15
  80012f:	6a 13                	push   $0x13
  800131:	68 2b 2c 80 00       	push   $0x802c2b
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 fb 23 00 00       	call   802542 <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 3c 2c 80 00       	push   $0x802c3c
  800154:	6a 15                	push   $0x15
  800156:	68 2b 2c 80 00       	push   $0x802c2b
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 a4 2b 80 00       	push   $0x802ba4
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 bd 11 00 00       	call   801332 <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 5e 30 80 00       	push   $0x80305e
  800182:	6a 1a                	push   $0x1a
  800184:	68 2b 2c 80 00       	push   $0x802c2b
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 b7 15 00 00       	call   801754 <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 ac 15 00 00       	call   801754 <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 54 15 00 00       	call   801704 <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 4c 15 00 00       	call   801704 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 45 2c 80 00       	push   $0x802c45
  8001bf:	68 12 2c 80 00       	push   $0x802c12
  8001c4:	68 48 2c 80 00       	push   $0x802c48
  8001c9:	e8 2b 21 00 00       	call   8022f9 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 4c 2c 80 00       	push   $0x802c4c
  8001dd:	6a 21                	push   $0x21
  8001df:	68 2b 2c 80 00       	push   $0x802c2b
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 11 15 00 00       	call   801704 <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 05 15 00 00       	call   801704 <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 c1 24 00 00       	call   8026c8 <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 ec 14 00 00       	call   801704 <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 e4 14 00 00       	call   801704 <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 56 2c 80 00       	push   $0x802c56
  800230:	e8 de 1a 00 00       	call   801d13 <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 c8 2b 80 00       	push   $0x802bc8
  800245:	6a 2c                	push   $0x2c
  800247:	68 2b 2c 80 00       	push   $0x802c2b
  80024c:	e8 93 02 00 00       	call   8004e4 <_panic>
  800251:	be 01 00 00 00       	mov    $0x1,%esi
  800256:	bf 00 00 00 00       	mov    $0x0,%edi

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	ff 75 d0             	pushl  -0x30(%ebp)
  800267:	e8 d4 15 00 00       	call   801840 <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 c1 15 00 00       	call   801840 <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 64 2c 80 00       	push   $0x802c64
  80028c:	6a 33                	push   $0x33
  80028e:	68 2b 2c 80 00       	push   $0x802c2b
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 7e 2c 80 00       	push   $0x802c7e
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 2b 2c 80 00       	push   $0x802c2b
  8002a9:	e8 36 02 00 00       	call   8004e4 <_panic>
		if (n1 == 0 && n2 == 0)
  8002ae:	89 da                	mov    %ebx,%edx
  8002b0:	09 c2                	or     %eax,%edx
  8002b2:	74 34                	je     8002e8 <umain+0x1fd>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b4:	83 fb 01             	cmp    $0x1,%ebx
  8002b7:	75 0e                	jne    8002c7 <umain+0x1dc>
  8002b9:	83 f8 01             	cmp    $0x1,%eax
  8002bc:	75 09                	jne    8002c7 <umain+0x1dc>
  8002be:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002c2:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c5:	74 12                	je     8002d9 <umain+0x1ee>
			wrong(rfd, kfd, nloff);
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	57                   	push   %edi
  8002cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d1:	e8 5d fd ff ff       	call   800033 <wrong>
  8002d6:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
			nloff = off+1;
  8002d9:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002dd:	0f 44 fe             	cmove  %esi,%edi
  8002e0:	83 c6 01             	add    $0x1,%esi
	}
  8002e3:	e9 73 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 98 2c 80 00       	push   $0x802c98
  8002f0:	e8 c8 02 00 00       	call   8005bd <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8002f5:	cc                   	int3   

	breakpoint();
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800311:	68 ad 2c 80 00       	push   $0x802cad
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	e8 d3 08 00 00       	call   800bf1 <strcpy>
	return 0;
}
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800331:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800336:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80033c:	eb 2d                	jmp    80036b <devcons_write+0x46>
		m = n - tot;
  80033e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800341:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800343:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800346:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80034b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	53                   	push   %ebx
  800352:	03 45 0c             	add    0xc(%ebp),%eax
  800355:	50                   	push   %eax
  800356:	57                   	push   %edi
  800357:	e8 27 0a 00 00       	call   800d83 <memmove>
		sys_cputs(buf, m);
  80035c:	83 c4 08             	add    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	57                   	push   %edi
  800361:	e8 49 0c 00 00       	call   800faf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800366:	01 de                	add    %ebx,%esi
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	89 f0                	mov    %esi,%eax
  80036d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800370:	72 cc                	jb     80033e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800385:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800389:	74 2a                	je     8003b5 <devcons_read+0x3b>
  80038b:	eb 05                	jmp    800392 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80038d:	e8 ba 0c 00 00       	call   80104c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800392:	e8 36 0c 00 00       	call   800fcd <sys_cgetc>
  800397:	85 c0                	test   %eax,%eax
  800399:	74 f2                	je     80038d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	78 16                	js     8003b5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80039f:	83 f8 04             	cmp    $0x4,%eax
  8003a2:	74 0c                	je     8003b0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	88 02                	mov    %al,(%edx)
	return 1;
  8003a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8003ae:	eb 05                	jmp    8003b5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003c3:	6a 01                	push   $0x1
  8003c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 e1 0b 00 00       	call   800faf <sys_cputs>
}
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <getchar>:

int
getchar(void)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003d9:	6a 01                	push   $0x1
  8003db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	6a 00                	push   $0x0
  8003e1:	e8 5a 14 00 00       	call   801840 <read>
	if (r < 0)
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	78 0f                	js     8003fc <getchar+0x29>
		return r;
	if (r < 1)
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	7e 06                	jle    8003f7 <getchar+0x24>
		return -E_EOF;
	return c;
  8003f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8003f5:	eb 05                	jmp    8003fc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8003f7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800407:	50                   	push   %eax
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	e8 ca 11 00 00       	call   8015da <fd_lookup>
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 c0                	test   %eax,%eax
  800415:	78 11                	js     800428 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800420:	39 10                	cmp    %edx,(%eax)
  800422:	0f 94 c0             	sete   %al
  800425:	0f b6 c0             	movzbl %al,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <opencons>:

int
opencons(void)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800433:	50                   	push   %eax
  800434:	e8 52 11 00 00       	call   80158b <fd_alloc>
  800439:	83 c4 10             	add    $0x10,%esp
		return r;
  80043c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80043e:	85 c0                	test   %eax,%eax
  800440:	78 3e                	js     800480 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	68 07 04 00 00       	push   $0x407
  80044a:	ff 75 f4             	pushl  -0xc(%ebp)
  80044d:	6a 00                	push   $0x0
  80044f:	e8 17 0c 00 00       	call   80106b <sys_page_alloc>
  800454:	83 c4 10             	add    $0x10,%esp
		return r;
  800457:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 23                	js     800480 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80045d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800466:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	50                   	push   %eax
  800476:	e8 e9 10 00 00       	call   801564 <fd2num>
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	83 c4 10             	add    $0x10,%esp
}
  800480:	89 d0                	mov    %edx,%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80048f:	e8 99 0b 00 00       	call   80102d <sys_getenvid>
  800494:	25 ff 03 00 00       	and    $0x3ff,%eax
  800499:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80049c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a1:	a3 08 50 80 00       	mov    %eax,0x805008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004a6:	85 db                	test   %ebx,%ebx
  8004a8:	7e 07                	jle    8004b1 <libmain+0x2d>
		binaryname = argv[0];
  8004aa:	8b 06                	mov    (%esi),%eax
  8004ac:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	e8 30 fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004bb:	e8 0a 00 00 00       	call   8004ca <exit>
}
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c6:	5b                   	pop    %ebx
  8004c7:	5e                   	pop    %esi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004d0:	e8 5a 12 00 00       	call   80172f <close_all>
	sys_env_destroy(0);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 0d 0b 00 00       	call   800fec <sys_env_destroy>
}
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ec:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004f2:	e8 36 0b 00 00       	call   80102d <sys_getenvid>
  8004f7:	83 ec 0c             	sub    $0xc,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	ff 75 08             	pushl  0x8(%ebp)
  800500:	56                   	push   %esi
  800501:	50                   	push   %eax
  800502:	68 c4 2c 80 00       	push   $0x802cc4
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 f8 2b 80 00 	movl   $0x802bf8,(%esp)
  80051f:	e8 99 00 00 00       	call   8005bd <cprintf>
  800524:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800527:	cc                   	int3   
  800528:	eb fd                	jmp    800527 <_panic+0x43>

0080052a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800534:	8b 13                	mov    (%ebx),%edx
  800536:	8d 42 01             	lea    0x1(%edx),%eax
  800539:	89 03                	mov    %eax,(%ebx)
  80053b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800542:	3d ff 00 00 00       	cmp    $0xff,%eax
  800547:	75 1a                	jne    800563 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	68 ff 00 00 00       	push   $0xff
  800551:	8d 43 08             	lea    0x8(%ebx),%eax
  800554:	50                   	push   %eax
  800555:	e8 55 0a 00 00       	call   800faf <sys_cputs>
		b->idx = 0;
  80055a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800560:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800563:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056a:	c9                   	leave  
  80056b:	c3                   	ret    

0080056c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800575:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057c:	00 00 00 
	b.cnt = 0;
  80057f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800586:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800589:	ff 75 0c             	pushl  0xc(%ebp)
  80058c:	ff 75 08             	pushl  0x8(%ebp)
  80058f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800595:	50                   	push   %eax
  800596:	68 2a 05 80 00       	push   $0x80052a
  80059b:	e8 54 01 00 00       	call   8006f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005af:	50                   	push   %eax
  8005b0:	e8 fa 09 00 00       	call   800faf <sys_cputs>

	return b.cnt;
}
  8005b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 08             	pushl  0x8(%ebp)
  8005ca:	e8 9d ff ff ff       	call   80056c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    

008005d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	57                   	push   %edi
  8005d5:	56                   	push   %esi
  8005d6:	53                   	push   %ebx
  8005d7:	83 ec 1c             	sub    $0x1c,%esp
  8005da:	89 c7                	mov    %eax,%edi
  8005dc:	89 d6                	mov    %edx,%esi
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005f8:	39 d3                	cmp    %edx,%ebx
  8005fa:	72 05                	jb     800601 <printnum+0x30>
  8005fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005ff:	77 45                	ja     800646 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	ff 75 18             	pushl  0x18(%ebp)
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80060d:	53                   	push   %ebx
  80060e:	ff 75 10             	pushl  0x10(%ebp)
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	ff 75 e4             	pushl  -0x1c(%ebp)
  800617:	ff 75 e0             	pushl  -0x20(%ebp)
  80061a:	ff 75 dc             	pushl  -0x24(%ebp)
  80061d:	ff 75 d8             	pushl  -0x28(%ebp)
  800620:	e8 bb 22 00 00       	call   8028e0 <__udivdi3>
  800625:	83 c4 18             	add    $0x18,%esp
  800628:	52                   	push   %edx
  800629:	50                   	push   %eax
  80062a:	89 f2                	mov    %esi,%edx
  80062c:	89 f8                	mov    %edi,%eax
  80062e:	e8 9e ff ff ff       	call   8005d1 <printnum>
  800633:	83 c4 20             	add    $0x20,%esp
  800636:	eb 18                	jmp    800650 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	56                   	push   %esi
  80063c:	ff 75 18             	pushl  0x18(%ebp)
  80063f:	ff d7                	call   *%edi
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	eb 03                	jmp    800649 <printnum+0x78>
  800646:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800649:	83 eb 01             	sub    $0x1,%ebx
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f e8                	jg     800638 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	56                   	push   %esi
  800654:	83 ec 04             	sub    $0x4,%esp
  800657:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065a:	ff 75 e0             	pushl  -0x20(%ebp)
  80065d:	ff 75 dc             	pushl  -0x24(%ebp)
  800660:	ff 75 d8             	pushl  -0x28(%ebp)
  800663:	e8 a8 23 00 00       	call   802a10 <__umoddi3>
  800668:	83 c4 14             	add    $0x14,%esp
  80066b:	0f be 80 e7 2c 80 00 	movsbl 0x802ce7(%eax),%eax
  800672:	50                   	push   %eax
  800673:	ff d7                	call   *%edi
}
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800683:	83 fa 01             	cmp    $0x1,%edx
  800686:	7e 0e                	jle    800696 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80068d:	89 08                	mov    %ecx,(%eax)
  80068f:	8b 02                	mov    (%edx),%eax
  800691:	8b 52 04             	mov    0x4(%edx),%edx
  800694:	eb 22                	jmp    8006b8 <getuint+0x38>
	else if (lflag)
  800696:	85 d2                	test   %edx,%edx
  800698:	74 10                	je     8006aa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069f:	89 08                	mov    %ecx,(%eax)
  8006a1:	8b 02                	mov    (%edx),%eax
  8006a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a8:	eb 0e                	jmp    8006b8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006af:	89 08                	mov    %ecx,(%eax)
  8006b1:	8b 02                	mov    (%edx),%eax
  8006b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006c0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	3b 50 04             	cmp    0x4(%eax),%edx
  8006c9:	73 0a                	jae    8006d5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006cb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006ce:	89 08                	mov    %ecx,(%eax)
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	88 02                	mov    %al,(%edx)
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006e0:	50                   	push   %eax
  8006e1:	ff 75 10             	pushl  0x10(%ebp)
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	ff 75 08             	pushl  0x8(%ebp)
  8006ea:	e8 05 00 00 00       	call   8006f4 <vprintfmt>
	va_end(ap);
}
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	57                   	push   %edi
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
  8006fa:	83 ec 2c             	sub    $0x2c,%esp
  8006fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800700:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800703:	8b 7d 10             	mov    0x10(%ebp),%edi
  800706:	eb 12                	jmp    80071a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800708:	85 c0                	test   %eax,%eax
  80070a:	0f 84 38 04 00 00    	je     800b48 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	50                   	push   %eax
  800715:	ff d6                	call   *%esi
  800717:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80071a:	83 c7 01             	add    $0x1,%edi
  80071d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800721:	83 f8 25             	cmp    $0x25,%eax
  800724:	75 e2                	jne    800708 <vprintfmt+0x14>
  800726:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80072a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800731:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800738:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80073f:	ba 00 00 00 00       	mov    $0x0,%edx
  800744:	eb 07                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  800749:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074d:	8d 47 01             	lea    0x1(%edi),%eax
  800750:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800753:	0f b6 07             	movzbl (%edi),%eax
  800756:	0f b6 c8             	movzbl %al,%ecx
  800759:	83 e8 23             	sub    $0x23,%eax
  80075c:	3c 55                	cmp    $0x55,%al
  80075e:	0f 87 c9 03 00 00    	ja     800b2d <vprintfmt+0x439>
  800764:	0f b6 c0             	movzbl %al,%eax
  800767:	ff 24 85 20 2e 80 00 	jmp    *0x802e20(,%eax,4)
  80076e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800771:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800775:	eb d6                	jmp    80074d <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  800777:	c7 05 00 50 80 00 00 	movl   $0x0,0x805000
  80077e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800781:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  800784:	eb 94                	jmp    80071a <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  800786:	c7 05 00 50 80 00 01 	movl   $0x1,0x805000
  80078d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800790:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  800793:	eb 85                	jmp    80071a <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  800795:	c7 05 00 50 80 00 02 	movl   $0x2,0x805000
  80079c:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  8007a2:	e9 73 ff ff ff       	jmp    80071a <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  8007a7:	c7 05 00 50 80 00 03 	movl   $0x3,0x805000
  8007ae:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  8007b4:	e9 61 ff ff ff       	jmp    80071a <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  8007b9:	c7 05 00 50 80 00 04 	movl   $0x4,0x805000
  8007c0:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  8007c6:	e9 4f ff ff ff       	jmp    80071a <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  8007cb:	c7 05 00 50 80 00 05 	movl   $0x5,0x805000
  8007d2:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  8007d8:	e9 3d ff ff ff       	jmp    80071a <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  8007dd:	c7 05 00 50 80 00 06 	movl   $0x6,0x805000
  8007e4:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  8007ea:	e9 2b ff ff ff       	jmp    80071a <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  8007ef:	c7 05 00 50 80 00 07 	movl   $0x7,0x805000
  8007f6:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8007fc:	e9 19 ff ff ff       	jmp    80071a <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800801:	c7 05 00 50 80 00 08 	movl   $0x8,0x805000
  800808:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  80080e:	e9 07 ff ff ff       	jmp    80071a <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  800813:	c7 05 00 50 80 00 09 	movl   $0x9,0x805000
  80081a:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800820:	e9 f5 fe ff ff       	jmp    80071a <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800825:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800828:	b8 00 00 00 00       	mov    $0x0,%eax
  80082d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800830:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800833:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800837:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80083a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80083d:	83 fa 09             	cmp    $0x9,%edx
  800840:	77 3f                	ja     800881 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800842:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800845:	eb e9                	jmp    800830 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800847:	8b 45 14             	mov    0x14(%ebp),%eax
  80084a:	8d 48 04             	lea    0x4(%eax),%ecx
  80084d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800850:	8b 00                	mov    (%eax),%eax
  800852:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800855:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800858:	eb 2d                	jmp    800887 <vprintfmt+0x193>
  80085a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80085d:	85 c0                	test   %eax,%eax
  80085f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800864:	0f 49 c8             	cmovns %eax,%ecx
  800867:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80086d:	e9 db fe ff ff       	jmp    80074d <vprintfmt+0x59>
  800872:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800875:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80087c:	e9 cc fe ff ff       	jmp    80074d <vprintfmt+0x59>
  800881:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800884:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800887:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80088b:	0f 89 bc fe ff ff    	jns    80074d <vprintfmt+0x59>
				width = precision, precision = -1;
  800891:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800894:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800897:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80089e:	e9 aa fe ff ff       	jmp    80074d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008a3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008a9:	e9 9f fe ff ff       	jmp    80074d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b1:	8d 50 04             	lea    0x4(%eax),%edx
  8008b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b7:	83 ec 08             	sub    $0x8,%esp
  8008ba:	53                   	push   %ebx
  8008bb:	ff 30                	pushl  (%eax)
  8008bd:	ff d6                	call   *%esi
			break;
  8008bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008c5:	e9 50 fe ff ff       	jmp    80071a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cd:	8d 50 04             	lea    0x4(%eax),%edx
  8008d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d3:	8b 00                	mov    (%eax),%eax
  8008d5:	99                   	cltd   
  8008d6:	31 d0                	xor    %edx,%eax
  8008d8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008da:	83 f8 0f             	cmp    $0xf,%eax
  8008dd:	7f 0b                	jg     8008ea <vprintfmt+0x1f6>
  8008df:	8b 14 85 80 2f 80 00 	mov    0x802f80(,%eax,4),%edx
  8008e6:	85 d2                	test   %edx,%edx
  8008e8:	75 18                	jne    800902 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  8008ea:	50                   	push   %eax
  8008eb:	68 ff 2c 80 00       	push   $0x802cff
  8008f0:	53                   	push   %ebx
  8008f1:	56                   	push   %esi
  8008f2:	e8 e0 fd ff ff       	call   8006d7 <printfmt>
  8008f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8008fd:	e9 18 fe ff ff       	jmp    80071a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800902:	52                   	push   %edx
  800903:	68 65 31 80 00       	push   $0x803165
  800908:	53                   	push   %ebx
  800909:	56                   	push   %esi
  80090a:	e8 c8 fd ff ff       	call   8006d7 <printfmt>
  80090f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800912:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800915:	e9 00 fe ff ff       	jmp    80071a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80091a:	8b 45 14             	mov    0x14(%ebp),%eax
  80091d:	8d 50 04             	lea    0x4(%eax),%edx
  800920:	89 55 14             	mov    %edx,0x14(%ebp)
  800923:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800925:	85 ff                	test   %edi,%edi
  800927:	b8 f8 2c 80 00       	mov    $0x802cf8,%eax
  80092c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80092f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800933:	0f 8e 94 00 00 00    	jle    8009cd <vprintfmt+0x2d9>
  800939:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80093d:	0f 84 98 00 00 00    	je     8009db <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  800943:	83 ec 08             	sub    $0x8,%esp
  800946:	ff 75 d0             	pushl  -0x30(%ebp)
  800949:	57                   	push   %edi
  80094a:	e8 81 02 00 00       	call   800bd0 <strnlen>
  80094f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800952:	29 c1                	sub    %eax,%ecx
  800954:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800957:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80095a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80095e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800961:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800964:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800966:	eb 0f                	jmp    800977 <vprintfmt+0x283>
					putch(padc, putdat);
  800968:	83 ec 08             	sub    $0x8,%esp
  80096b:	53                   	push   %ebx
  80096c:	ff 75 e0             	pushl  -0x20(%ebp)
  80096f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800971:	83 ef 01             	sub    $0x1,%edi
  800974:	83 c4 10             	add    $0x10,%esp
  800977:	85 ff                	test   %edi,%edi
  800979:	7f ed                	jg     800968 <vprintfmt+0x274>
  80097b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80097e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800981:	85 c9                	test   %ecx,%ecx
  800983:	b8 00 00 00 00       	mov    $0x0,%eax
  800988:	0f 49 c1             	cmovns %ecx,%eax
  80098b:	29 c1                	sub    %eax,%ecx
  80098d:	89 75 08             	mov    %esi,0x8(%ebp)
  800990:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800993:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800996:	89 cb                	mov    %ecx,%ebx
  800998:	eb 4d                	jmp    8009e7 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80099a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80099e:	74 1b                	je     8009bb <vprintfmt+0x2c7>
  8009a0:	0f be c0             	movsbl %al,%eax
  8009a3:	83 e8 20             	sub    $0x20,%eax
  8009a6:	83 f8 5e             	cmp    $0x5e,%eax
  8009a9:	76 10                	jbe    8009bb <vprintfmt+0x2c7>
					putch('?', putdat);
  8009ab:	83 ec 08             	sub    $0x8,%esp
  8009ae:	ff 75 0c             	pushl  0xc(%ebp)
  8009b1:	6a 3f                	push   $0x3f
  8009b3:	ff 55 08             	call   *0x8(%ebp)
  8009b6:	83 c4 10             	add    $0x10,%esp
  8009b9:	eb 0d                	jmp    8009c8 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  8009bb:	83 ec 08             	sub    $0x8,%esp
  8009be:	ff 75 0c             	pushl  0xc(%ebp)
  8009c1:	52                   	push   %edx
  8009c2:	ff 55 08             	call   *0x8(%ebp)
  8009c5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009c8:	83 eb 01             	sub    $0x1,%ebx
  8009cb:	eb 1a                	jmp    8009e7 <vprintfmt+0x2f3>
  8009cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8009d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8009d9:	eb 0c                	jmp    8009e7 <vprintfmt+0x2f3>
  8009db:	89 75 08             	mov    %esi,0x8(%ebp)
  8009de:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009e4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8009e7:	83 c7 01             	add    $0x1,%edi
  8009ea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8009ee:	0f be d0             	movsbl %al,%edx
  8009f1:	85 d2                	test   %edx,%edx
  8009f3:	74 23                	je     800a18 <vprintfmt+0x324>
  8009f5:	85 f6                	test   %esi,%esi
  8009f7:	78 a1                	js     80099a <vprintfmt+0x2a6>
  8009f9:	83 ee 01             	sub    $0x1,%esi
  8009fc:	79 9c                	jns    80099a <vprintfmt+0x2a6>
  8009fe:	89 df                	mov    %ebx,%edi
  800a00:	8b 75 08             	mov    0x8(%ebp),%esi
  800a03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a06:	eb 18                	jmp    800a20 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a08:	83 ec 08             	sub    $0x8,%esp
  800a0b:	53                   	push   %ebx
  800a0c:	6a 20                	push   $0x20
  800a0e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a10:	83 ef 01             	sub    $0x1,%edi
  800a13:	83 c4 10             	add    $0x10,%esp
  800a16:	eb 08                	jmp    800a20 <vprintfmt+0x32c>
  800a18:	89 df                	mov    %ebx,%edi
  800a1a:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a20:	85 ff                	test   %edi,%edi
  800a22:	7f e4                	jg     800a08 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a24:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a27:	e9 ee fc ff ff       	jmp    80071a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a2c:	83 fa 01             	cmp    $0x1,%edx
  800a2f:	7e 16                	jle    800a47 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800a31:	8b 45 14             	mov    0x14(%ebp),%eax
  800a34:	8d 50 08             	lea    0x8(%eax),%edx
  800a37:	89 55 14             	mov    %edx,0x14(%ebp)
  800a3a:	8b 50 04             	mov    0x4(%eax),%edx
  800a3d:	8b 00                	mov    (%eax),%eax
  800a3f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a42:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a45:	eb 32                	jmp    800a79 <vprintfmt+0x385>
	else if (lflag)
  800a47:	85 d2                	test   %edx,%edx
  800a49:	74 18                	je     800a63 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  800a4b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a4e:	8d 50 04             	lea    0x4(%eax),%edx
  800a51:	89 55 14             	mov    %edx,0x14(%ebp)
  800a54:	8b 00                	mov    (%eax),%eax
  800a56:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a59:	89 c1                	mov    %eax,%ecx
  800a5b:	c1 f9 1f             	sar    $0x1f,%ecx
  800a5e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800a61:	eb 16                	jmp    800a79 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  800a63:	8b 45 14             	mov    0x14(%ebp),%eax
  800a66:	8d 50 04             	lea    0x4(%eax),%edx
  800a69:	89 55 14             	mov    %edx,0x14(%ebp)
  800a6c:	8b 00                	mov    (%eax),%eax
  800a6e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a71:	89 c1                	mov    %eax,%ecx
  800a73:	c1 f9 1f             	sar    $0x1f,%ecx
  800a76:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a79:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800a7c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a7f:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a84:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a88:	79 6f                	jns    800af9 <vprintfmt+0x405>
				putch('-', putdat);
  800a8a:	83 ec 08             	sub    $0x8,%esp
  800a8d:	53                   	push   %ebx
  800a8e:	6a 2d                	push   $0x2d
  800a90:	ff d6                	call   *%esi
				num = -(long long) num;
  800a92:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800a95:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800a98:	f7 d8                	neg    %eax
  800a9a:	83 d2 00             	adc    $0x0,%edx
  800a9d:	f7 da                	neg    %edx
  800a9f:	83 c4 10             	add    $0x10,%esp
  800aa2:	eb 55                	jmp    800af9 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800aa4:	8d 45 14             	lea    0x14(%ebp),%eax
  800aa7:	e8 d4 fb ff ff       	call   800680 <getuint>
			base = 10;
  800aac:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800ab1:	eb 46                	jmp    800af9 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800ab3:	8d 45 14             	lea    0x14(%ebp),%eax
  800ab6:	e8 c5 fb ff ff       	call   800680 <getuint>
			base = 8;
  800abb:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800ac0:	eb 37                	jmp    800af9 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800ac2:	83 ec 08             	sub    $0x8,%esp
  800ac5:	53                   	push   %ebx
  800ac6:	6a 30                	push   $0x30
  800ac8:	ff d6                	call   *%esi
			putch('x', putdat);
  800aca:	83 c4 08             	add    $0x8,%esp
  800acd:	53                   	push   %ebx
  800ace:	6a 78                	push   $0x78
  800ad0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ad2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad5:	8d 50 04             	lea    0x4(%eax),%edx
  800ad8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800adb:	8b 00                	mov    (%eax),%eax
  800add:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800ae2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ae5:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800aea:	eb 0d                	jmp    800af9 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800aec:	8d 45 14             	lea    0x14(%ebp),%eax
  800aef:	e8 8c fb ff ff       	call   800680 <getuint>
			base = 16;
  800af4:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800af9:	83 ec 0c             	sub    $0xc,%esp
  800afc:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800b00:	51                   	push   %ecx
  800b01:	ff 75 e0             	pushl  -0x20(%ebp)
  800b04:	57                   	push   %edi
  800b05:	52                   	push   %edx
  800b06:	50                   	push   %eax
  800b07:	89 da                	mov    %ebx,%edx
  800b09:	89 f0                	mov    %esi,%eax
  800b0b:	e8 c1 fa ff ff       	call   8005d1 <printnum>
			break;
  800b10:	83 c4 20             	add    $0x20,%esp
  800b13:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b16:	e9 ff fb ff ff       	jmp    80071a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b1b:	83 ec 08             	sub    $0x8,%esp
  800b1e:	53                   	push   %ebx
  800b1f:	51                   	push   %ecx
  800b20:	ff d6                	call   *%esi
			break;
  800b22:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b28:	e9 ed fb ff ff       	jmp    80071a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b2d:	83 ec 08             	sub    $0x8,%esp
  800b30:	53                   	push   %ebx
  800b31:	6a 25                	push   $0x25
  800b33:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b35:	83 c4 10             	add    $0x10,%esp
  800b38:	eb 03                	jmp    800b3d <vprintfmt+0x449>
  800b3a:	83 ef 01             	sub    $0x1,%edi
  800b3d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800b41:	75 f7                	jne    800b3a <vprintfmt+0x446>
  800b43:	e9 d2 fb ff ff       	jmp    80071a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800b48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4b:	5b                   	pop    %ebx
  800b4c:	5e                   	pop    %esi
  800b4d:	5f                   	pop    %edi
  800b4e:	5d                   	pop    %ebp
  800b4f:	c3                   	ret    

00800b50 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	83 ec 18             	sub    $0x18,%esp
  800b56:	8b 45 08             	mov    0x8(%ebp),%eax
  800b59:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b5c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b5f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b63:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	74 26                	je     800b97 <vsnprintf+0x47>
  800b71:	85 d2                	test   %edx,%edx
  800b73:	7e 22                	jle    800b97 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b75:	ff 75 14             	pushl  0x14(%ebp)
  800b78:	ff 75 10             	pushl  0x10(%ebp)
  800b7b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b7e:	50                   	push   %eax
  800b7f:	68 ba 06 80 00       	push   $0x8006ba
  800b84:	e8 6b fb ff ff       	call   8006f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b89:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b8c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b92:	83 c4 10             	add    $0x10,%esp
  800b95:	eb 05                	jmp    800b9c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b9c:	c9                   	leave  
  800b9d:	c3                   	ret    

00800b9e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ba4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ba7:	50                   	push   %eax
  800ba8:	ff 75 10             	pushl  0x10(%ebp)
  800bab:	ff 75 0c             	pushl  0xc(%ebp)
  800bae:	ff 75 08             	pushl  0x8(%ebp)
  800bb1:	e8 9a ff ff ff       	call   800b50 <vsnprintf>
	va_end(ap);

	return rc;
}
  800bb6:	c9                   	leave  
  800bb7:	c3                   	ret    

00800bb8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc3:	eb 03                	jmp    800bc8 <strlen+0x10>
		n++;
  800bc5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bc8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bcc:	75 f7                	jne    800bc5 <strlen+0xd>
		n++;
	return n;
}
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bde:	eb 03                	jmp    800be3 <strnlen+0x13>
		n++;
  800be0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800be3:	39 c2                	cmp    %eax,%edx
  800be5:	74 08                	je     800bef <strnlen+0x1f>
  800be7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800beb:	75 f3                	jne    800be0 <strnlen+0x10>
  800bed:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	53                   	push   %ebx
  800bf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bfb:	89 c2                	mov    %eax,%edx
  800bfd:	83 c2 01             	add    $0x1,%edx
  800c00:	83 c1 01             	add    $0x1,%ecx
  800c03:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c07:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c0a:	84 db                	test   %bl,%bl
  800c0c:	75 ef                	jne    800bfd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	53                   	push   %ebx
  800c15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c18:	53                   	push   %ebx
  800c19:	e8 9a ff ff ff       	call   800bb8 <strlen>
  800c1e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c21:	ff 75 0c             	pushl  0xc(%ebp)
  800c24:	01 d8                	add    %ebx,%eax
  800c26:	50                   	push   %eax
  800c27:	e8 c5 ff ff ff       	call   800bf1 <strcpy>
	return dst;
}
  800c2c:	89 d8                	mov    %ebx,%eax
  800c2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c31:	c9                   	leave  
  800c32:	c3                   	ret    

00800c33 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	8b 75 08             	mov    0x8(%ebp),%esi
  800c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3e:	89 f3                	mov    %esi,%ebx
  800c40:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c43:	89 f2                	mov    %esi,%edx
  800c45:	eb 0f                	jmp    800c56 <strncpy+0x23>
		*dst++ = *src;
  800c47:	83 c2 01             	add    $0x1,%edx
  800c4a:	0f b6 01             	movzbl (%ecx),%eax
  800c4d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c50:	80 39 01             	cmpb   $0x1,(%ecx)
  800c53:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c56:	39 da                	cmp    %ebx,%edx
  800c58:	75 ed                	jne    800c47 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c5a:	89 f0                	mov    %esi,%eax
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
  800c65:	8b 75 08             	mov    0x8(%ebp),%esi
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	8b 55 10             	mov    0x10(%ebp),%edx
  800c6e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c70:	85 d2                	test   %edx,%edx
  800c72:	74 21                	je     800c95 <strlcpy+0x35>
  800c74:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c78:	89 f2                	mov    %esi,%edx
  800c7a:	eb 09                	jmp    800c85 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c7c:	83 c2 01             	add    $0x1,%edx
  800c7f:	83 c1 01             	add    $0x1,%ecx
  800c82:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c85:	39 c2                	cmp    %eax,%edx
  800c87:	74 09                	je     800c92 <strlcpy+0x32>
  800c89:	0f b6 19             	movzbl (%ecx),%ebx
  800c8c:	84 db                	test   %bl,%bl
  800c8e:	75 ec                	jne    800c7c <strlcpy+0x1c>
  800c90:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c92:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c95:	29 f0                	sub    %esi,%eax
}
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ca4:	eb 06                	jmp    800cac <strcmp+0x11>
		p++, q++;
  800ca6:	83 c1 01             	add    $0x1,%ecx
  800ca9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800cac:	0f b6 01             	movzbl (%ecx),%eax
  800caf:	84 c0                	test   %al,%al
  800cb1:	74 04                	je     800cb7 <strcmp+0x1c>
  800cb3:	3a 02                	cmp    (%edx),%al
  800cb5:	74 ef                	je     800ca6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800cb7:	0f b6 c0             	movzbl %al,%eax
  800cba:	0f b6 12             	movzbl (%edx),%edx
  800cbd:	29 d0                	sub    %edx,%eax
}
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	53                   	push   %ebx
  800cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ccb:	89 c3                	mov    %eax,%ebx
  800ccd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800cd0:	eb 06                	jmp    800cd8 <strncmp+0x17>
		n--, p++, q++;
  800cd2:	83 c0 01             	add    $0x1,%eax
  800cd5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cd8:	39 d8                	cmp    %ebx,%eax
  800cda:	74 15                	je     800cf1 <strncmp+0x30>
  800cdc:	0f b6 08             	movzbl (%eax),%ecx
  800cdf:	84 c9                	test   %cl,%cl
  800ce1:	74 04                	je     800ce7 <strncmp+0x26>
  800ce3:	3a 0a                	cmp    (%edx),%cl
  800ce5:	74 eb                	je     800cd2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ce7:	0f b6 00             	movzbl (%eax),%eax
  800cea:	0f b6 12             	movzbl (%edx),%edx
  800ced:	29 d0                	sub    %edx,%eax
  800cef:	eb 05                	jmp    800cf6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cf1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cf6:	5b                   	pop    %ebx
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d03:	eb 07                	jmp    800d0c <strchr+0x13>
		if (*s == c)
  800d05:	38 ca                	cmp    %cl,%dl
  800d07:	74 0f                	je     800d18 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d09:	83 c0 01             	add    $0x1,%eax
  800d0c:	0f b6 10             	movzbl (%eax),%edx
  800d0f:	84 d2                	test   %dl,%dl
  800d11:	75 f2                	jne    800d05 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d20:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d24:	eb 03                	jmp    800d29 <strfind+0xf>
  800d26:	83 c0 01             	add    $0x1,%eax
  800d29:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d2c:	38 ca                	cmp    %cl,%dl
  800d2e:	74 04                	je     800d34 <strfind+0x1a>
  800d30:	84 d2                	test   %dl,%dl
  800d32:	75 f2                	jne    800d26 <strfind+0xc>
			break;
	return (char *) s;
}
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d42:	85 c9                	test   %ecx,%ecx
  800d44:	74 36                	je     800d7c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d46:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d4c:	75 28                	jne    800d76 <memset+0x40>
  800d4e:	f6 c1 03             	test   $0x3,%cl
  800d51:	75 23                	jne    800d76 <memset+0x40>
		c &= 0xFF;
  800d53:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d57:	89 d3                	mov    %edx,%ebx
  800d59:	c1 e3 08             	shl    $0x8,%ebx
  800d5c:	89 d6                	mov    %edx,%esi
  800d5e:	c1 e6 18             	shl    $0x18,%esi
  800d61:	89 d0                	mov    %edx,%eax
  800d63:	c1 e0 10             	shl    $0x10,%eax
  800d66:	09 f0                	or     %esi,%eax
  800d68:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800d6a:	89 d8                	mov    %ebx,%eax
  800d6c:	09 d0                	or     %edx,%eax
  800d6e:	c1 e9 02             	shr    $0x2,%ecx
  800d71:	fc                   	cld    
  800d72:	f3 ab                	rep stos %eax,%es:(%edi)
  800d74:	eb 06                	jmp    800d7c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d79:	fc                   	cld    
  800d7a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d7c:	89 f8                	mov    %edi,%eax
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d91:	39 c6                	cmp    %eax,%esi
  800d93:	73 35                	jae    800dca <memmove+0x47>
  800d95:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d98:	39 d0                	cmp    %edx,%eax
  800d9a:	73 2e                	jae    800dca <memmove+0x47>
		s += n;
		d += n;
  800d9c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d9f:	89 d6                	mov    %edx,%esi
  800da1:	09 fe                	or     %edi,%esi
  800da3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800da9:	75 13                	jne    800dbe <memmove+0x3b>
  800dab:	f6 c1 03             	test   $0x3,%cl
  800dae:	75 0e                	jne    800dbe <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800db0:	83 ef 04             	sub    $0x4,%edi
  800db3:	8d 72 fc             	lea    -0x4(%edx),%esi
  800db6:	c1 e9 02             	shr    $0x2,%ecx
  800db9:	fd                   	std    
  800dba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dbc:	eb 09                	jmp    800dc7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800dbe:	83 ef 01             	sub    $0x1,%edi
  800dc1:	8d 72 ff             	lea    -0x1(%edx),%esi
  800dc4:	fd                   	std    
  800dc5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800dc7:	fc                   	cld    
  800dc8:	eb 1d                	jmp    800de7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dca:	89 f2                	mov    %esi,%edx
  800dcc:	09 c2                	or     %eax,%edx
  800dce:	f6 c2 03             	test   $0x3,%dl
  800dd1:	75 0f                	jne    800de2 <memmove+0x5f>
  800dd3:	f6 c1 03             	test   $0x3,%cl
  800dd6:	75 0a                	jne    800de2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800dd8:	c1 e9 02             	shr    $0x2,%ecx
  800ddb:	89 c7                	mov    %eax,%edi
  800ddd:	fc                   	cld    
  800dde:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800de0:	eb 05                	jmp    800de7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800de2:	89 c7                	mov    %eax,%edi
  800de4:	fc                   	cld    
  800de5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800dee:	ff 75 10             	pushl  0x10(%ebp)
  800df1:	ff 75 0c             	pushl  0xc(%ebp)
  800df4:	ff 75 08             	pushl  0x8(%ebp)
  800df7:	e8 87 ff ff ff       	call   800d83 <memmove>
}
  800dfc:	c9                   	leave  
  800dfd:	c3                   	ret    

00800dfe <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	8b 45 08             	mov    0x8(%ebp),%eax
  800e06:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e09:	89 c6                	mov    %eax,%esi
  800e0b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e0e:	eb 1a                	jmp    800e2a <memcmp+0x2c>
		if (*s1 != *s2)
  800e10:	0f b6 08             	movzbl (%eax),%ecx
  800e13:	0f b6 1a             	movzbl (%edx),%ebx
  800e16:	38 d9                	cmp    %bl,%cl
  800e18:	74 0a                	je     800e24 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e1a:	0f b6 c1             	movzbl %cl,%eax
  800e1d:	0f b6 db             	movzbl %bl,%ebx
  800e20:	29 d8                	sub    %ebx,%eax
  800e22:	eb 0f                	jmp    800e33 <memcmp+0x35>
		s1++, s2++;
  800e24:	83 c0 01             	add    $0x1,%eax
  800e27:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e2a:	39 f0                	cmp    %esi,%eax
  800e2c:	75 e2                	jne    800e10 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	53                   	push   %ebx
  800e3b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e3e:	89 c1                	mov    %eax,%ecx
  800e40:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800e43:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e47:	eb 0a                	jmp    800e53 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e49:	0f b6 10             	movzbl (%eax),%edx
  800e4c:	39 da                	cmp    %ebx,%edx
  800e4e:	74 07                	je     800e57 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e50:	83 c0 01             	add    $0x1,%eax
  800e53:	39 c8                	cmp    %ecx,%eax
  800e55:	72 f2                	jb     800e49 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e57:	5b                   	pop    %ebx
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	57                   	push   %edi
  800e5e:	56                   	push   %esi
  800e5f:	53                   	push   %ebx
  800e60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e66:	eb 03                	jmp    800e6b <strtol+0x11>
		s++;
  800e68:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e6b:	0f b6 01             	movzbl (%ecx),%eax
  800e6e:	3c 20                	cmp    $0x20,%al
  800e70:	74 f6                	je     800e68 <strtol+0xe>
  800e72:	3c 09                	cmp    $0x9,%al
  800e74:	74 f2                	je     800e68 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e76:	3c 2b                	cmp    $0x2b,%al
  800e78:	75 0a                	jne    800e84 <strtol+0x2a>
		s++;
  800e7a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e7d:	bf 00 00 00 00       	mov    $0x0,%edi
  800e82:	eb 11                	jmp    800e95 <strtol+0x3b>
  800e84:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e89:	3c 2d                	cmp    $0x2d,%al
  800e8b:	75 08                	jne    800e95 <strtol+0x3b>
		s++, neg = 1;
  800e8d:	83 c1 01             	add    $0x1,%ecx
  800e90:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e95:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e9b:	75 15                	jne    800eb2 <strtol+0x58>
  800e9d:	80 39 30             	cmpb   $0x30,(%ecx)
  800ea0:	75 10                	jne    800eb2 <strtol+0x58>
  800ea2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ea6:	75 7c                	jne    800f24 <strtol+0xca>
		s += 2, base = 16;
  800ea8:	83 c1 02             	add    $0x2,%ecx
  800eab:	bb 10 00 00 00       	mov    $0x10,%ebx
  800eb0:	eb 16                	jmp    800ec8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800eb2:	85 db                	test   %ebx,%ebx
  800eb4:	75 12                	jne    800ec8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800eb6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ebb:	80 39 30             	cmpb   $0x30,(%ecx)
  800ebe:	75 08                	jne    800ec8 <strtol+0x6e>
		s++, base = 8;
  800ec0:	83 c1 01             	add    $0x1,%ecx
  800ec3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ec8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ed0:	0f b6 11             	movzbl (%ecx),%edx
  800ed3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ed6:	89 f3                	mov    %esi,%ebx
  800ed8:	80 fb 09             	cmp    $0x9,%bl
  800edb:	77 08                	ja     800ee5 <strtol+0x8b>
			dig = *s - '0';
  800edd:	0f be d2             	movsbl %dl,%edx
  800ee0:	83 ea 30             	sub    $0x30,%edx
  800ee3:	eb 22                	jmp    800f07 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ee5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ee8:	89 f3                	mov    %esi,%ebx
  800eea:	80 fb 19             	cmp    $0x19,%bl
  800eed:	77 08                	ja     800ef7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800eef:	0f be d2             	movsbl %dl,%edx
  800ef2:	83 ea 57             	sub    $0x57,%edx
  800ef5:	eb 10                	jmp    800f07 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ef7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800efa:	89 f3                	mov    %esi,%ebx
  800efc:	80 fb 19             	cmp    $0x19,%bl
  800eff:	77 16                	ja     800f17 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f01:	0f be d2             	movsbl %dl,%edx
  800f04:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f07:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f0a:	7d 0b                	jge    800f17 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800f0c:	83 c1 01             	add    $0x1,%ecx
  800f0f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f13:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f15:	eb b9                	jmp    800ed0 <strtol+0x76>

	if (endptr)
  800f17:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f1b:	74 0d                	je     800f2a <strtol+0xd0>
		*endptr = (char *) s;
  800f1d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f20:	89 0e                	mov    %ecx,(%esi)
  800f22:	eb 06                	jmp    800f2a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f24:	85 db                	test   %ebx,%ebx
  800f26:	74 98                	je     800ec0 <strtol+0x66>
  800f28:	eb 9e                	jmp    800ec8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800f2a:	89 c2                	mov    %eax,%edx
  800f2c:	f7 da                	neg    %edx
  800f2e:	85 ff                	test   %edi,%edi
  800f30:	0f 45 c2             	cmovne %edx,%eax
}
  800f33:	5b                   	pop    %ebx
  800f34:	5e                   	pop    %esi
  800f35:	5f                   	pop    %edi
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    

00800f38 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	57                   	push   %edi
  800f3c:	56                   	push   %esi
  800f3d:	53                   	push   %ebx
  800f3e:	83 ec 04             	sub    $0x4,%esp
  800f41:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800f44:	57                   	push   %edi
  800f45:	e8 6e fc ff ff       	call   800bb8 <strlen>
  800f4a:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800f4d:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800f50:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800f55:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800f5a:	eb 46                	jmp    800fa2 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800f5c:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800f60:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800f63:	80 f9 09             	cmp    $0x9,%cl
  800f66:	77 08                	ja     800f70 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800f68:	0f be d2             	movsbl %dl,%edx
  800f6b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800f6e:	eb 27                	jmp    800f97 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800f70:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800f73:	80 f9 05             	cmp    $0x5,%cl
  800f76:	77 08                	ja     800f80 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800f78:	0f be d2             	movsbl %dl,%edx
  800f7b:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800f7e:	eb 17                	jmp    800f97 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800f80:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800f83:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800f86:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800f8b:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800f8f:	77 06                	ja     800f97 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800f91:	0f be d2             	movsbl %dl,%edx
  800f94:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800f97:	0f af ce             	imul   %esi,%ecx
  800f9a:	01 c8                	add    %ecx,%eax
		base *= 16;
  800f9c:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800f9f:	83 eb 01             	sub    $0x1,%ebx
  800fa2:	83 fb 01             	cmp    $0x1,%ebx
  800fa5:	7f b5                	jg     800f5c <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800fa7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800faa:	5b                   	pop    %ebx
  800fab:	5e                   	pop    %esi
  800fac:	5f                   	pop    %edi
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    

00800faf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	57                   	push   %edi
  800fb3:	56                   	push   %esi
  800fb4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800fba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc0:	89 c3                	mov    %eax,%ebx
  800fc2:	89 c7                	mov    %eax,%edi
  800fc4:	89 c6                	mov    %eax,%esi
  800fc6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fc8:	5b                   	pop    %ebx
  800fc9:	5e                   	pop    %esi
  800fca:	5f                   	pop    %edi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    

00800fcd <sys_cgetc>:

int
sys_cgetc(void)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	57                   	push   %edi
  800fd1:	56                   	push   %esi
  800fd2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd8:	b8 01 00 00 00       	mov    $0x1,%eax
  800fdd:	89 d1                	mov    %edx,%ecx
  800fdf:	89 d3                	mov    %edx,%ebx
  800fe1:	89 d7                	mov    %edx,%edi
  800fe3:	89 d6                	mov    %edx,%esi
  800fe5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fe7:	5b                   	pop    %ebx
  800fe8:	5e                   	pop    %esi
  800fe9:	5f                   	pop    %edi
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	57                   	push   %edi
  800ff0:	56                   	push   %esi
  800ff1:	53                   	push   %ebx
  800ff2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ffa:	b8 03 00 00 00       	mov    $0x3,%eax
  800fff:	8b 55 08             	mov    0x8(%ebp),%edx
  801002:	89 cb                	mov    %ecx,%ebx
  801004:	89 cf                	mov    %ecx,%edi
  801006:	89 ce                	mov    %ecx,%esi
  801008:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80100a:	85 c0                	test   %eax,%eax
  80100c:	7e 17                	jle    801025 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100e:	83 ec 0c             	sub    $0xc,%esp
  801011:	50                   	push   %eax
  801012:	6a 03                	push   $0x3
  801014:	68 df 2f 80 00       	push   $0x802fdf
  801019:	6a 23                	push   $0x23
  80101b:	68 fc 2f 80 00       	push   $0x802ffc
  801020:	e8 bf f4 ff ff       	call   8004e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801025:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    

0080102d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	57                   	push   %edi
  801031:	56                   	push   %esi
  801032:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801033:	ba 00 00 00 00       	mov    $0x0,%edx
  801038:	b8 02 00 00 00       	mov    $0x2,%eax
  80103d:	89 d1                	mov    %edx,%ecx
  80103f:	89 d3                	mov    %edx,%ebx
  801041:	89 d7                	mov    %edx,%edi
  801043:	89 d6                	mov    %edx,%esi
  801045:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801047:	5b                   	pop    %ebx
  801048:	5e                   	pop    %esi
  801049:	5f                   	pop    %edi
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    

0080104c <sys_yield>:

void
sys_yield(void)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	57                   	push   %edi
  801050:	56                   	push   %esi
  801051:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801052:	ba 00 00 00 00       	mov    $0x0,%edx
  801057:	b8 0b 00 00 00       	mov    $0xb,%eax
  80105c:	89 d1                	mov    %edx,%ecx
  80105e:	89 d3                	mov    %edx,%ebx
  801060:	89 d7                	mov    %edx,%edi
  801062:	89 d6                	mov    %edx,%esi
  801064:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801066:	5b                   	pop    %ebx
  801067:	5e                   	pop    %esi
  801068:	5f                   	pop    %edi
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    

0080106b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	57                   	push   %edi
  80106f:	56                   	push   %esi
  801070:	53                   	push   %ebx
  801071:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801074:	be 00 00 00 00       	mov    $0x0,%esi
  801079:	b8 04 00 00 00       	mov    $0x4,%eax
  80107e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801081:	8b 55 08             	mov    0x8(%ebp),%edx
  801084:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801087:	89 f7                	mov    %esi,%edi
  801089:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80108b:	85 c0                	test   %eax,%eax
  80108d:	7e 17                	jle    8010a6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108f:	83 ec 0c             	sub    $0xc,%esp
  801092:	50                   	push   %eax
  801093:	6a 04                	push   $0x4
  801095:	68 df 2f 80 00       	push   $0x802fdf
  80109a:	6a 23                	push   $0x23
  80109c:	68 fc 2f 80 00       	push   $0x802ffc
  8010a1:	e8 3e f4 ff ff       	call   8004e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a9:	5b                   	pop    %ebx
  8010aa:	5e                   	pop    %esi
  8010ab:	5f                   	pop    %edi
  8010ac:	5d                   	pop    %ebp
  8010ad:	c3                   	ret    

008010ae <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	57                   	push   %edi
  8010b2:	56                   	push   %esi
  8010b3:	53                   	push   %ebx
  8010b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8010bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010c5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010c8:	8b 75 18             	mov    0x18(%ebp),%esi
  8010cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	7e 17                	jle    8010e8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d1:	83 ec 0c             	sub    $0xc,%esp
  8010d4:	50                   	push   %eax
  8010d5:	6a 05                	push   $0x5
  8010d7:	68 df 2f 80 00       	push   $0x802fdf
  8010dc:	6a 23                	push   $0x23
  8010de:	68 fc 2f 80 00       	push   $0x802ffc
  8010e3:	e8 fc f3 ff ff       	call   8004e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010fe:	b8 06 00 00 00       	mov    $0x6,%eax
  801103:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801106:	8b 55 08             	mov    0x8(%ebp),%edx
  801109:	89 df                	mov    %ebx,%edi
  80110b:	89 de                	mov    %ebx,%esi
  80110d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80110f:	85 c0                	test   %eax,%eax
  801111:	7e 17                	jle    80112a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801113:	83 ec 0c             	sub    $0xc,%esp
  801116:	50                   	push   %eax
  801117:	6a 06                	push   $0x6
  801119:	68 df 2f 80 00       	push   $0x802fdf
  80111e:	6a 23                	push   $0x23
  801120:	68 fc 2f 80 00       	push   $0x802ffc
  801125:	e8 ba f3 ff ff       	call   8004e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80112a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112d:	5b                   	pop    %ebx
  80112e:	5e                   	pop    %esi
  80112f:	5f                   	pop    %edi
  801130:	5d                   	pop    %ebp
  801131:	c3                   	ret    

00801132 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	57                   	push   %edi
  801136:	56                   	push   %esi
  801137:	53                   	push   %ebx
  801138:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801140:	b8 08 00 00 00       	mov    $0x8,%eax
  801145:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801148:	8b 55 08             	mov    0x8(%ebp),%edx
  80114b:	89 df                	mov    %ebx,%edi
  80114d:	89 de                	mov    %ebx,%esi
  80114f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801151:	85 c0                	test   %eax,%eax
  801153:	7e 17                	jle    80116c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801155:	83 ec 0c             	sub    $0xc,%esp
  801158:	50                   	push   %eax
  801159:	6a 08                	push   $0x8
  80115b:	68 df 2f 80 00       	push   $0x802fdf
  801160:	6a 23                	push   $0x23
  801162:	68 fc 2f 80 00       	push   $0x802ffc
  801167:	e8 78 f3 ff ff       	call   8004e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80116c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116f:	5b                   	pop    %ebx
  801170:	5e                   	pop    %esi
  801171:	5f                   	pop    %edi
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	57                   	push   %edi
  801178:	56                   	push   %esi
  801179:	53                   	push   %ebx
  80117a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801182:	b8 0a 00 00 00       	mov    $0xa,%eax
  801187:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118a:	8b 55 08             	mov    0x8(%ebp),%edx
  80118d:	89 df                	mov    %ebx,%edi
  80118f:	89 de                	mov    %ebx,%esi
  801191:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801193:	85 c0                	test   %eax,%eax
  801195:	7e 17                	jle    8011ae <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801197:	83 ec 0c             	sub    $0xc,%esp
  80119a:	50                   	push   %eax
  80119b:	6a 0a                	push   $0xa
  80119d:	68 df 2f 80 00       	push   $0x802fdf
  8011a2:	6a 23                	push   $0x23
  8011a4:	68 fc 2f 80 00       	push   $0x802ffc
  8011a9:	e8 36 f3 ff ff       	call   8004e4 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b1:	5b                   	pop    %ebx
  8011b2:	5e                   	pop    %esi
  8011b3:	5f                   	pop    %edi
  8011b4:	5d                   	pop    %ebp
  8011b5:	c3                   	ret    

008011b6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	57                   	push   %edi
  8011ba:	56                   	push   %esi
  8011bb:	53                   	push   %ebx
  8011bc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c4:	b8 09 00 00 00       	mov    $0x9,%eax
  8011c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011cf:	89 df                	mov    %ebx,%edi
  8011d1:	89 de                	mov    %ebx,%esi
  8011d3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	7e 17                	jle    8011f0 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011d9:	83 ec 0c             	sub    $0xc,%esp
  8011dc:	50                   	push   %eax
  8011dd:	6a 09                	push   $0x9
  8011df:	68 df 2f 80 00       	push   $0x802fdf
  8011e4:	6a 23                	push   $0x23
  8011e6:	68 fc 2f 80 00       	push   $0x802ffc
  8011eb:	e8 f4 f2 ff ff       	call   8004e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f3:	5b                   	pop    %ebx
  8011f4:	5e                   	pop    %esi
  8011f5:	5f                   	pop    %edi
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    

008011f8 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	57                   	push   %edi
  8011fc:	56                   	push   %esi
  8011fd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011fe:	be 00 00 00 00       	mov    $0x0,%esi
  801203:	b8 0c 00 00 00       	mov    $0xc,%eax
  801208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120b:	8b 55 08             	mov    0x8(%ebp),%edx
  80120e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801211:	8b 7d 14             	mov    0x14(%ebp),%edi
  801214:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801216:	5b                   	pop    %ebx
  801217:	5e                   	pop    %esi
  801218:	5f                   	pop    %edi
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	57                   	push   %edi
  80121f:	56                   	push   %esi
  801220:	53                   	push   %ebx
  801221:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801224:	b9 00 00 00 00       	mov    $0x0,%ecx
  801229:	b8 0d 00 00 00       	mov    $0xd,%eax
  80122e:	8b 55 08             	mov    0x8(%ebp),%edx
  801231:	89 cb                	mov    %ecx,%ebx
  801233:	89 cf                	mov    %ecx,%edi
  801235:	89 ce                	mov    %ecx,%esi
  801237:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801239:	85 c0                	test   %eax,%eax
  80123b:	7e 17                	jle    801254 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80123d:	83 ec 0c             	sub    $0xc,%esp
  801240:	50                   	push   %eax
  801241:	6a 0d                	push   $0xd
  801243:	68 df 2f 80 00       	push   $0x802fdf
  801248:	6a 23                	push   $0x23
  80124a:	68 fc 2f 80 00       	push   $0x802ffc
  80124f:	e8 90 f2 ff ff       	call   8004e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801254:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801257:	5b                   	pop    %ebx
  801258:	5e                   	pop    %esi
  801259:	5f                   	pop    %edi
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	53                   	push   %ebx
  801260:	83 ec 04             	sub    $0x4,%esp
  801263:	8b 45 08             	mov    0x8(%ebp),%eax

	
	void *addr = (void *) utf->utf_fault_va;
  801266:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  801268:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80126c:	74 11                	je     80127f <pgfault+0x23>
  80126e:	89 d8                	mov    %ebx,%eax
  801270:	c1 e8 0c             	shr    $0xc,%eax
  801273:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80127a:	f6 c4 08             	test   $0x8,%ah
  80127d:	75 14                	jne    801293 <pgfault+0x37>
		panic("page fault");
  80127f:	83 ec 04             	sub    $0x4,%esp
  801282:	68 0a 30 80 00       	push   $0x80300a
  801287:	6a 5b                	push   $0x5b
  801289:	68 15 30 80 00       	push   $0x803015
  80128e:	e8 51 f2 ff ff       	call   8004e4 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// allocate a new page and map it at a temporary location
	if((r = sys_page_alloc(0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  801293:	83 ec 04             	sub    $0x4,%esp
  801296:	6a 07                	push   $0x7
  801298:	68 00 f0 7f 00       	push   $0x7ff000
  80129d:	6a 00                	push   $0x0
  80129f:	e8 c7 fd ff ff       	call   80106b <sys_page_alloc>
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	79 12                	jns    8012bd <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  8012ab:	50                   	push   %eax
  8012ac:	68 20 30 80 00       	push   $0x803020
  8012b1:	6a 66                	push   $0x66
  8012b3:	68 15 30 80 00       	push   $0x803015
  8012b8:	e8 27 f2 ff ff       	call   8004e4 <_panic>

	// copy date to new page
	//strncpy((char *)PFTEMP, (char *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
	memcpy((void *)PFTEMP, (void *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
  8012bd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8012c3:	83 ec 04             	sub    $0x4,%esp
  8012c6:	68 00 10 00 00       	push   $0x1000
  8012cb:	53                   	push   %ebx
  8012cc:	68 00 f0 7f 00       	push   $0x7ff000
  8012d1:	e8 15 fb ff ff       	call   800deb <memcpy>

	// move the new page to the old page's address
	if((r = sys_page_map(0, (void *)PFTEMP, 0, (void *)
  8012d6:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8012dd:	53                   	push   %ebx
  8012de:	6a 00                	push   $0x0
  8012e0:	68 00 f0 7f 00       	push   $0x7ff000
  8012e5:	6a 00                	push   $0x0
  8012e7:	e8 c2 fd ff ff       	call   8010ae <sys_page_map>
  8012ec:	83 c4 20             	add    $0x20,%esp
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	79 12                	jns    801305 <pgfault+0xa9>
		(ROUNDDOWN(addr, PGSIZE)), PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_map: %e", r);
  8012f3:	50                   	push   %eax
  8012f4:	68 33 30 80 00       	push   $0x803033
  8012f9:	6a 6f                	push   $0x6f
  8012fb:	68 15 30 80 00       	push   $0x803015
  801300:	e8 df f1 ff ff       	call   8004e4 <_panic>

	// unmap page on PFTEMP
	if((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  801305:	83 ec 08             	sub    $0x8,%esp
  801308:	68 00 f0 7f 00       	push   $0x7ff000
  80130d:	6a 00                	push   $0x0
  80130f:	e8 dc fd ff ff       	call   8010f0 <sys_page_unmap>
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	85 c0                	test   %eax,%eax
  801319:	79 12                	jns    80132d <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  80131b:	50                   	push   %eax
  80131c:	68 44 30 80 00       	push   $0x803044
  801321:	6a 73                	push   $0x73
  801323:	68 15 30 80 00       	push   $0x803015
  801328:	e8 b7 f1 ff ff       	call   8004e4 <_panic>


}
  80132d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801330:	c9                   	leave  
  801331:	c3                   	ret    

00801332 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	57                   	push   %edi
  801336:	56                   	push   %esi
  801337:	53                   	push   %ebx
  801338:	83 ec 28             	sub    $0x28,%esp

	#ifdef CHALLENGE 
	set_exception_handler(pgfault, T_PGFLT);
	#else
	// set up page fault handler
	set_pgfault_handler(pgfault);
  80133b:	68 5c 12 80 00       	push   $0x80125c
  801340:	e8 d2 13 00 00       	call   802717 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801345:	b8 07 00 00 00       	mov    $0x7,%eax
  80134a:	cd 30                	int    $0x30
  80134c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80134f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	#endif

	// create a child
	envid = sys_exofork();
	if (envid < 0)
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	79 15                	jns    80136e <fork+0x3c>
		panic("sys_exofork: %e", envid);
  801359:	50                   	push   %eax
  80135a:	68 57 30 80 00       	push   $0x803057
  80135f:	68 d0 00 00 00       	push   $0xd0
  801364:	68 15 30 80 00       	push   $0x803015
  801369:	e8 76 f1 ff ff       	call   8004e4 <_panic>
  80136e:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801373:	be 00 08 00 00       	mov    $0x800,%esi
	// we are the child
	if(envid == 0) {
  801378:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80137c:	75 21                	jne    80139f <fork+0x6d>
		// the copied valude of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  80137e:	e8 aa fc ff ff       	call   80102d <sys_getenvid>
  801383:	25 ff 03 00 00       	and    $0x3ff,%eax
  801388:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80138b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801390:	a3 08 50 80 00       	mov    %eax,0x805008
		/*// alloc exception stack
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
			PTE_P | PTE_U | PTE_W)) < 0)
			panic("sys_page_alloc: %e", r);*/

		return 0;
  801395:	b8 00 00 00 00       	mov    $0x0,%eax
  80139a:	e9 a3 01 00 00       	jmp    801542 <fork+0x210>
{
	int r;

	// LAB 4: Your code here.
	
	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P))
  80139f:	89 d8                	mov    %ebx,%eax
  8013a1:	c1 e8 16             	shr    $0x16,%eax
  8013a4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013ab:	a8 01                	test   $0x1,%al
  8013ad:	0f 84 f0 00 00 00    	je     8014a3 <fork+0x171>
		return 0;

	// virtual page pn's page table entry
	pte_t pe = uvpt[pn];
  8013b3:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi


	if((pe & PTE_P) && (pe & PTE_U)) {
  8013ba:	89 f8                	mov    %edi,%eax
  8013bc:	83 e0 05             	and    $0x5,%eax
  8013bf:	83 f8 05             	cmp    $0x5,%eax
  8013c2:	0f 85 db 00 00 00    	jne    8014a3 <fork+0x171>
		// share with the child environment 
		if(pe & PTE_SHARE) {
  8013c8:	f7 c7 00 04 00 00    	test   $0x400,%edi
  8013ce:	74 36                	je     801406 <fork+0xd4>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  8013d0:	83 ec 0c             	sub    $0xc,%esp
  8013d3:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  8013d9:	57                   	push   %edi
  8013da:	53                   	push   %ebx
  8013db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013de:	53                   	push   %ebx
  8013df:	6a 00                	push   $0x0
  8013e1:	e8 c8 fc ff ff       	call   8010ae <sys_page_map>
  8013e6:	83 c4 20             	add    $0x20,%esp
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	0f 89 b2 00 00 00    	jns    8014a3 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  8013f1:	50                   	push   %eax
  8013f2:	68 67 30 80 00       	push   $0x803067
  8013f7:	68 97 00 00 00       	push   $0x97
  8013fc:	68 15 30 80 00       	push   $0x803015
  801401:	e8 de f0 ff ff       	call   8004e4 <_panic>
		}
		// the page is writable or copy-on-write
		else if((pe & PTE_W) || (pe & PTE_COW)) {
  801406:	f7 c7 02 08 00 00    	test   $0x802,%edi
  80140c:	74 63                	je     801471 <fork+0x13f>
			// create the child mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, 
  80140e:	81 e7 05 06 00 00    	and    $0x605,%edi
  801414:	81 cf 00 08 00 00    	or     $0x800,%edi
  80141a:	83 ec 0c             	sub    $0xc,%esp
  80141d:	57                   	push   %edi
  80141e:	53                   	push   %ebx
  80141f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801422:	53                   	push   %ebx
  801423:	6a 00                	push   $0x0
  801425:	e8 84 fc ff ff       	call   8010ae <sys_page_map>
  80142a:	83 c4 20             	add    $0x20,%esp
  80142d:	85 c0                	test   %eax,%eax
  80142f:	79 15                	jns    801446 <fork+0x114>
				(void *)(pn*PGSIZE), (pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  801431:	50                   	push   %eax
  801432:	68 67 30 80 00       	push   $0x803067
  801437:	68 9e 00 00 00       	push   $0x9e
  80143c:	68 15 30 80 00       	push   $0x803015
  801441:	e8 9e f0 ff ff       	call   8004e4 <_panic>
			// map the parent mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE),
  801446:	83 ec 0c             	sub    $0xc,%esp
  801449:	57                   	push   %edi
  80144a:	53                   	push   %ebx
  80144b:	6a 00                	push   $0x0
  80144d:	53                   	push   %ebx
  80144e:	6a 00                	push   $0x0
  801450:	e8 59 fc ff ff       	call   8010ae <sys_page_map>
  801455:	83 c4 20             	add    $0x20,%esp
  801458:	85 c0                	test   %eax,%eax
  80145a:	79 47                	jns    8014a3 <fork+0x171>
				(pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  80145c:	50                   	push   %eax
  80145d:	68 67 30 80 00       	push   $0x803067
  801462:	68 a2 00 00 00       	push   $0xa2
  801467:	68 15 30 80 00       	push   $0x803015
  80146c:	e8 73 f0 ff ff       	call   8004e4 <_panic>
		}	
		else {
			// create the child mapping read only
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  801471:	83 ec 0c             	sub    $0xc,%esp
  801474:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  80147a:	57                   	push   %edi
  80147b:	53                   	push   %ebx
  80147c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80147f:	53                   	push   %ebx
  801480:	6a 00                	push   $0x0
  801482:	e8 27 fc ff ff       	call   8010ae <sys_page_map>
  801487:	83 c4 20             	add    $0x20,%esp
  80148a:	85 c0                	test   %eax,%eax
  80148c:	79 15                	jns    8014a3 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  80148e:	50                   	push   %eax
  80148f:	68 67 30 80 00       	push   $0x803067
  801494:	68 a8 00 00 00       	push   $0xa8
  801499:	68 15 30 80 00       	push   $0x803015
  80149e:	e8 41 f0 ff ff       	call   8004e4 <_panic>
			panic("sys_page_alloc: %e", r);*/

		return 0;
	}
	// copy address to child environment's page dirctory
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn)
  8014a3:	83 c6 01             	add    $0x1,%esi
  8014a6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8014ac:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8014b2:	0f 85 e7 fe ff ff    	jne    80139f <fork+0x6d>
	#ifdef CHALLENGE 
	if((r = sys_env_set_exception_upcall(envid, thisenv->env_exception_upcall)) < 0)
		panic("sys_env_set_exception_upcall: %e", r);
	#else
	// set child's page fault handler
	if((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  8014b8:	a1 08 50 80 00       	mov    0x805008,%eax
  8014bd:	8b 40 64             	mov    0x64(%eax),%eax
  8014c0:	83 ec 08             	sub    $0x8,%esp
  8014c3:	50                   	push   %eax
  8014c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8014c7:	e8 ea fc ff ff       	call   8011b6 <sys_env_set_pgfault_upcall>
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	79 15                	jns    8014e8 <fork+0x1b6>
		panic("sys_env_set_pgfault_upcall: %e", r);
  8014d3:	50                   	push   %eax
  8014d4:	68 a0 30 80 00       	push   $0x8030a0
  8014d9:	68 e9 00 00 00       	push   $0xe9
  8014de:	68 15 30 80 00       	push   $0x803015
  8014e3:	e8 fc ef ff ff       	call   8004e4 <_panic>
	#endif

	// alloc exception stack for child environment
	if((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), 
  8014e8:	83 ec 04             	sub    $0x4,%esp
  8014eb:	6a 07                	push   $0x7
  8014ed:	68 00 f0 bf ee       	push   $0xeebff000
  8014f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8014f5:	e8 71 fb ff ff       	call   80106b <sys_page_alloc>
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	79 15                	jns    801516 <fork+0x1e4>
		PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
  801501:	50                   	push   %eax
  801502:	68 20 30 80 00       	push   $0x803020
  801507:	68 ef 00 00 00       	push   $0xef
  80150c:	68 15 30 80 00       	push   $0x803015
  801511:	e8 ce ef ff ff       	call   8004e4 <_panic>

	// start the child environment running
	if((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801516:	83 ec 08             	sub    $0x8,%esp
  801519:	6a 02                	push   $0x2
  80151b:	ff 75 e0             	pushl  -0x20(%ebp)
  80151e:	e8 0f fc ff ff       	call   801132 <sys_env_set_status>
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	85 c0                	test   %eax,%eax
  801528:	79 15                	jns    80153f <fork+0x20d>
		panic("sys_env_set_status: %e", r);
  80152a:	50                   	push   %eax
  80152b:	68 73 30 80 00       	push   $0x803073
  801530:	68 f3 00 00 00       	push   $0xf3
  801535:	68 15 30 80 00       	push   $0x803015
  80153a:	e8 a5 ef ff ff       	call   8004e4 <_panic>

	return envid;
  80153f:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801542:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801545:	5b                   	pop    %ebx
  801546:	5e                   	pop    %esi
  801547:	5f                   	pop    %edi
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    

0080154a <sfork>:

// Challenge!
int
sfork(void)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801550:	68 8a 30 80 00       	push   $0x80308a
  801555:	68 fc 00 00 00       	push   $0xfc
  80155a:	68 15 30 80 00       	push   $0x803015
  80155f:	e8 80 ef ff ff       	call   8004e4 <_panic>

00801564 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801567:	8b 45 08             	mov    0x8(%ebp),%eax
  80156a:	05 00 00 00 30       	add    $0x30000000,%eax
  80156f:	c1 e8 0c             	shr    $0xc,%eax
}
  801572:	5d                   	pop    %ebp
  801573:	c3                   	ret    

00801574 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801577:	8b 45 08             	mov    0x8(%ebp),%eax
  80157a:	05 00 00 00 30       	add    $0x30000000,%eax
  80157f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801584:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801589:	5d                   	pop    %ebp
  80158a:	c3                   	ret    

0080158b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801591:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801596:	89 c2                	mov    %eax,%edx
  801598:	c1 ea 16             	shr    $0x16,%edx
  80159b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015a2:	f6 c2 01             	test   $0x1,%dl
  8015a5:	74 11                	je     8015b8 <fd_alloc+0x2d>
  8015a7:	89 c2                	mov    %eax,%edx
  8015a9:	c1 ea 0c             	shr    $0xc,%edx
  8015ac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015b3:	f6 c2 01             	test   $0x1,%dl
  8015b6:	75 09                	jne    8015c1 <fd_alloc+0x36>
			*fd_store = fd;
  8015b8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8015bf:	eb 17                	jmp    8015d8 <fd_alloc+0x4d>
  8015c1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8015c6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8015cb:	75 c9                	jne    801596 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8015cd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8015d3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8015d8:	5d                   	pop    %ebp
  8015d9:	c3                   	ret    

008015da <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015e0:	83 f8 1f             	cmp    $0x1f,%eax
  8015e3:	77 36                	ja     80161b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015e5:	c1 e0 0c             	shl    $0xc,%eax
  8015e8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015ed:	89 c2                	mov    %eax,%edx
  8015ef:	c1 ea 16             	shr    $0x16,%edx
  8015f2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015f9:	f6 c2 01             	test   $0x1,%dl
  8015fc:	74 24                	je     801622 <fd_lookup+0x48>
  8015fe:	89 c2                	mov    %eax,%edx
  801600:	c1 ea 0c             	shr    $0xc,%edx
  801603:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80160a:	f6 c2 01             	test   $0x1,%dl
  80160d:	74 1a                	je     801629 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80160f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801612:	89 02                	mov    %eax,(%edx)
	return 0;
  801614:	b8 00 00 00 00       	mov    $0x0,%eax
  801619:	eb 13                	jmp    80162e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80161b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801620:	eb 0c                	jmp    80162e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801622:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801627:	eb 05                	jmp    80162e <fd_lookup+0x54>
  801629:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80162e:	5d                   	pop    %ebp
  80162f:	c3                   	ret    

00801630 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	83 ec 08             	sub    $0x8,%esp
  801636:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801639:	ba 3c 31 80 00       	mov    $0x80313c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80163e:	eb 13                	jmp    801653 <dev_lookup+0x23>
  801640:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801643:	39 08                	cmp    %ecx,(%eax)
  801645:	75 0c                	jne    801653 <dev_lookup+0x23>
			*dev = devtab[i];
  801647:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80164a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80164c:	b8 00 00 00 00       	mov    $0x0,%eax
  801651:	eb 2e                	jmp    801681 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801653:	8b 02                	mov    (%edx),%eax
  801655:	85 c0                	test   %eax,%eax
  801657:	75 e7                	jne    801640 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801659:	a1 08 50 80 00       	mov    0x805008,%eax
  80165e:	8b 40 48             	mov    0x48(%eax),%eax
  801661:	83 ec 04             	sub    $0x4,%esp
  801664:	51                   	push   %ecx
  801665:	50                   	push   %eax
  801666:	68 c0 30 80 00       	push   $0x8030c0
  80166b:	e8 4d ef ff ff       	call   8005bd <cprintf>
	*dev = 0;
  801670:	8b 45 0c             	mov    0xc(%ebp),%eax
  801673:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	56                   	push   %esi
  801687:	53                   	push   %ebx
  801688:	83 ec 10             	sub    $0x10,%esp
  80168b:	8b 75 08             	mov    0x8(%ebp),%esi
  80168e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801691:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801694:	50                   	push   %eax
  801695:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80169b:	c1 e8 0c             	shr    $0xc,%eax
  80169e:	50                   	push   %eax
  80169f:	e8 36 ff ff ff       	call   8015da <fd_lookup>
  8016a4:	83 c4 08             	add    $0x8,%esp
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	78 05                	js     8016b0 <fd_close+0x2d>
	    || fd != fd2) 
  8016ab:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8016ae:	74 0c                	je     8016bc <fd_close+0x39>
		return (must_exist ? r : 0); 
  8016b0:	84 db                	test   %bl,%bl
  8016b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b7:	0f 44 c2             	cmove  %edx,%eax
  8016ba:	eb 41                	jmp    8016fd <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8016bc:	83 ec 08             	sub    $0x8,%esp
  8016bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c2:	50                   	push   %eax
  8016c3:	ff 36                	pushl  (%esi)
  8016c5:	e8 66 ff ff ff       	call   801630 <dev_lookup>
  8016ca:	89 c3                	mov    %eax,%ebx
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	78 1a                	js     8016ed <fd_close+0x6a>
		if (dev->dev_close) 
  8016d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8016d9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	74 0b                	je     8016ed <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8016e2:	83 ec 0c             	sub    $0xc,%esp
  8016e5:	56                   	push   %esi
  8016e6:	ff d0                	call   *%eax
  8016e8:	89 c3                	mov    %eax,%ebx
  8016ea:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8016ed:	83 ec 08             	sub    $0x8,%esp
  8016f0:	56                   	push   %esi
  8016f1:	6a 00                	push   $0x0
  8016f3:	e8 f8 f9 ff ff       	call   8010f0 <sys_page_unmap>
	return r;
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	89 d8                	mov    %ebx,%eax
}
  8016fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801700:	5b                   	pop    %ebx
  801701:	5e                   	pop    %esi
  801702:	5d                   	pop    %ebp
  801703:	c3                   	ret    

00801704 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80170a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170d:	50                   	push   %eax
  80170e:	ff 75 08             	pushl  0x8(%ebp)
  801711:	e8 c4 fe ff ff       	call   8015da <fd_lookup>
  801716:	83 c4 08             	add    $0x8,%esp
  801719:	85 c0                	test   %eax,%eax
  80171b:	78 10                	js     80172d <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  80171d:	83 ec 08             	sub    $0x8,%esp
  801720:	6a 01                	push   $0x1
  801722:	ff 75 f4             	pushl  -0xc(%ebp)
  801725:	e8 59 ff ff ff       	call   801683 <fd_close>
  80172a:	83 c4 10             	add    $0x10,%esp
}
  80172d:	c9                   	leave  
  80172e:	c3                   	ret    

0080172f <close_all>:

void
close_all(void)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	53                   	push   %ebx
  801733:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801736:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80173b:	83 ec 0c             	sub    $0xc,%esp
  80173e:	53                   	push   %ebx
  80173f:	e8 c0 ff ff ff       	call   801704 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801744:	83 c3 01             	add    $0x1,%ebx
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	83 fb 20             	cmp    $0x20,%ebx
  80174d:	75 ec                	jne    80173b <close_all+0xc>
		close(i);
}
  80174f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801752:	c9                   	leave  
  801753:	c3                   	ret    

00801754 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	57                   	push   %edi
  801758:	56                   	push   %esi
  801759:	53                   	push   %ebx
  80175a:	83 ec 2c             	sub    $0x2c,%esp
  80175d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801760:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801763:	50                   	push   %eax
  801764:	ff 75 08             	pushl  0x8(%ebp)
  801767:	e8 6e fe ff ff       	call   8015da <fd_lookup>
  80176c:	83 c4 08             	add    $0x8,%esp
  80176f:	85 c0                	test   %eax,%eax
  801771:	0f 88 c1 00 00 00    	js     801838 <dup+0xe4>
		return r;
	close(newfdnum);
  801777:	83 ec 0c             	sub    $0xc,%esp
  80177a:	56                   	push   %esi
  80177b:	e8 84 ff ff ff       	call   801704 <close>

	newfd = INDEX2FD(newfdnum);
  801780:	89 f3                	mov    %esi,%ebx
  801782:	c1 e3 0c             	shl    $0xc,%ebx
  801785:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80178b:	83 c4 04             	add    $0x4,%esp
  80178e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801791:	e8 de fd ff ff       	call   801574 <fd2data>
  801796:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801798:	89 1c 24             	mov    %ebx,(%esp)
  80179b:	e8 d4 fd ff ff       	call   801574 <fd2data>
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8017a6:	89 f8                	mov    %edi,%eax
  8017a8:	c1 e8 16             	shr    $0x16,%eax
  8017ab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017b2:	a8 01                	test   $0x1,%al
  8017b4:	74 37                	je     8017ed <dup+0x99>
  8017b6:	89 f8                	mov    %edi,%eax
  8017b8:	c1 e8 0c             	shr    $0xc,%eax
  8017bb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8017c2:	f6 c2 01             	test   $0x1,%dl
  8017c5:	74 26                	je     8017ed <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8017c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017ce:	83 ec 0c             	sub    $0xc,%esp
  8017d1:	25 07 0e 00 00       	and    $0xe07,%eax
  8017d6:	50                   	push   %eax
  8017d7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8017da:	6a 00                	push   $0x0
  8017dc:	57                   	push   %edi
  8017dd:	6a 00                	push   $0x0
  8017df:	e8 ca f8 ff ff       	call   8010ae <sys_page_map>
  8017e4:	89 c7                	mov    %eax,%edi
  8017e6:	83 c4 20             	add    $0x20,%esp
  8017e9:	85 c0                	test   %eax,%eax
  8017eb:	78 2e                	js     80181b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017f0:	89 d0                	mov    %edx,%eax
  8017f2:	c1 e8 0c             	shr    $0xc,%eax
  8017f5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017fc:	83 ec 0c             	sub    $0xc,%esp
  8017ff:	25 07 0e 00 00       	and    $0xe07,%eax
  801804:	50                   	push   %eax
  801805:	53                   	push   %ebx
  801806:	6a 00                	push   $0x0
  801808:	52                   	push   %edx
  801809:	6a 00                	push   $0x0
  80180b:	e8 9e f8 ff ff       	call   8010ae <sys_page_map>
  801810:	89 c7                	mov    %eax,%edi
  801812:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801815:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801817:	85 ff                	test   %edi,%edi
  801819:	79 1d                	jns    801838 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80181b:	83 ec 08             	sub    $0x8,%esp
  80181e:	53                   	push   %ebx
  80181f:	6a 00                	push   $0x0
  801821:	e8 ca f8 ff ff       	call   8010f0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801826:	83 c4 08             	add    $0x8,%esp
  801829:	ff 75 d4             	pushl  -0x2c(%ebp)
  80182c:	6a 00                	push   $0x0
  80182e:	e8 bd f8 ff ff       	call   8010f0 <sys_page_unmap>
	return r;
  801833:	83 c4 10             	add    $0x10,%esp
  801836:	89 f8                	mov    %edi,%eax
}
  801838:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80183b:	5b                   	pop    %ebx
  80183c:	5e                   	pop    %esi
  80183d:	5f                   	pop    %edi
  80183e:	5d                   	pop    %ebp
  80183f:	c3                   	ret    

00801840 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	53                   	push   %ebx
  801844:	83 ec 14             	sub    $0x14,%esp
  801847:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80184a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80184d:	50                   	push   %eax
  80184e:	53                   	push   %ebx
  80184f:	e8 86 fd ff ff       	call   8015da <fd_lookup>
  801854:	83 c4 08             	add    $0x8,%esp
  801857:	89 c2                	mov    %eax,%edx
  801859:	85 c0                	test   %eax,%eax
  80185b:	78 6d                	js     8018ca <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80185d:	83 ec 08             	sub    $0x8,%esp
  801860:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801863:	50                   	push   %eax
  801864:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801867:	ff 30                	pushl  (%eax)
  801869:	e8 c2 fd ff ff       	call   801630 <dev_lookup>
  80186e:	83 c4 10             	add    $0x10,%esp
  801871:	85 c0                	test   %eax,%eax
  801873:	78 4c                	js     8018c1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801875:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801878:	8b 42 08             	mov    0x8(%edx),%eax
  80187b:	83 e0 03             	and    $0x3,%eax
  80187e:	83 f8 01             	cmp    $0x1,%eax
  801881:	75 21                	jne    8018a4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801883:	a1 08 50 80 00       	mov    0x805008,%eax
  801888:	8b 40 48             	mov    0x48(%eax),%eax
  80188b:	83 ec 04             	sub    $0x4,%esp
  80188e:	53                   	push   %ebx
  80188f:	50                   	push   %eax
  801890:	68 01 31 80 00       	push   $0x803101
  801895:	e8 23 ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018a2:	eb 26                	jmp    8018ca <read+0x8a>
	}
	if (!dev->dev_read)
  8018a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a7:	8b 40 08             	mov    0x8(%eax),%eax
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	74 17                	je     8018c5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8018ae:	83 ec 04             	sub    $0x4,%esp
  8018b1:	ff 75 10             	pushl  0x10(%ebp)
  8018b4:	ff 75 0c             	pushl  0xc(%ebp)
  8018b7:	52                   	push   %edx
  8018b8:	ff d0                	call   *%eax
  8018ba:	89 c2                	mov    %eax,%edx
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	eb 09                	jmp    8018ca <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c1:	89 c2                	mov    %eax,%edx
  8018c3:	eb 05                	jmp    8018ca <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8018c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8018ca:	89 d0                	mov    %edx,%eax
  8018cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	57                   	push   %edi
  8018d5:	56                   	push   %esi
  8018d6:	53                   	push   %ebx
  8018d7:	83 ec 0c             	sub    $0xc,%esp
  8018da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018dd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018e5:	eb 21                	jmp    801908 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018e7:	83 ec 04             	sub    $0x4,%esp
  8018ea:	89 f0                	mov    %esi,%eax
  8018ec:	29 d8                	sub    %ebx,%eax
  8018ee:	50                   	push   %eax
  8018ef:	89 d8                	mov    %ebx,%eax
  8018f1:	03 45 0c             	add    0xc(%ebp),%eax
  8018f4:	50                   	push   %eax
  8018f5:	57                   	push   %edi
  8018f6:	e8 45 ff ff ff       	call   801840 <read>
		if (m < 0)
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	85 c0                	test   %eax,%eax
  801900:	78 10                	js     801912 <readn+0x41>
			return m;
		if (m == 0)
  801902:	85 c0                	test   %eax,%eax
  801904:	74 0a                	je     801910 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801906:	01 c3                	add    %eax,%ebx
  801908:	39 f3                	cmp    %esi,%ebx
  80190a:	72 db                	jb     8018e7 <readn+0x16>
  80190c:	89 d8                	mov    %ebx,%eax
  80190e:	eb 02                	jmp    801912 <readn+0x41>
  801910:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801912:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801915:	5b                   	pop    %ebx
  801916:	5e                   	pop    %esi
  801917:	5f                   	pop    %edi
  801918:	5d                   	pop    %ebp
  801919:	c3                   	ret    

0080191a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	53                   	push   %ebx
  80191e:	83 ec 14             	sub    $0x14,%esp
  801921:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801924:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801927:	50                   	push   %eax
  801928:	53                   	push   %ebx
  801929:	e8 ac fc ff ff       	call   8015da <fd_lookup>
  80192e:	83 c4 08             	add    $0x8,%esp
  801931:	89 c2                	mov    %eax,%edx
  801933:	85 c0                	test   %eax,%eax
  801935:	78 68                	js     80199f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801937:	83 ec 08             	sub    $0x8,%esp
  80193a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193d:	50                   	push   %eax
  80193e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801941:	ff 30                	pushl  (%eax)
  801943:	e8 e8 fc ff ff       	call   801630 <dev_lookup>
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	85 c0                	test   %eax,%eax
  80194d:	78 47                	js     801996 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80194f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801952:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801956:	75 21                	jne    801979 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801958:	a1 08 50 80 00       	mov    0x805008,%eax
  80195d:	8b 40 48             	mov    0x48(%eax),%eax
  801960:	83 ec 04             	sub    $0x4,%esp
  801963:	53                   	push   %ebx
  801964:	50                   	push   %eax
  801965:	68 1d 31 80 00       	push   $0x80311d
  80196a:	e8 4e ec ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  80196f:	83 c4 10             	add    $0x10,%esp
  801972:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801977:	eb 26                	jmp    80199f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801979:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80197c:	8b 52 0c             	mov    0xc(%edx),%edx
  80197f:	85 d2                	test   %edx,%edx
  801981:	74 17                	je     80199a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801983:	83 ec 04             	sub    $0x4,%esp
  801986:	ff 75 10             	pushl  0x10(%ebp)
  801989:	ff 75 0c             	pushl  0xc(%ebp)
  80198c:	50                   	push   %eax
  80198d:	ff d2                	call   *%edx
  80198f:	89 c2                	mov    %eax,%edx
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	eb 09                	jmp    80199f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801996:	89 c2                	mov    %eax,%edx
  801998:	eb 05                	jmp    80199f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80199a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80199f:	89 d0                	mov    %edx,%eax
  8019a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a4:	c9                   	leave  
  8019a5:	c3                   	ret    

008019a6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019ac:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8019af:	50                   	push   %eax
  8019b0:	ff 75 08             	pushl  0x8(%ebp)
  8019b3:	e8 22 fc ff ff       	call   8015da <fd_lookup>
  8019b8:	83 c4 08             	add    $0x8,%esp
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	78 0e                	js     8019cd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8019bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8019c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019c5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8019c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019cd:	c9                   	leave  
  8019ce:	c3                   	ret    

008019cf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	53                   	push   %ebx
  8019d3:	83 ec 14             	sub    $0x14,%esp
  8019d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019dc:	50                   	push   %eax
  8019dd:	53                   	push   %ebx
  8019de:	e8 f7 fb ff ff       	call   8015da <fd_lookup>
  8019e3:	83 c4 08             	add    $0x8,%esp
  8019e6:	89 c2                	mov    %eax,%edx
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	78 65                	js     801a51 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019ec:	83 ec 08             	sub    $0x8,%esp
  8019ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f2:	50                   	push   %eax
  8019f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019f6:	ff 30                	pushl  (%eax)
  8019f8:	e8 33 fc ff ff       	call   801630 <dev_lookup>
  8019fd:	83 c4 10             	add    $0x10,%esp
  801a00:	85 c0                	test   %eax,%eax
  801a02:	78 44                	js     801a48 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a07:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a0b:	75 21                	jne    801a2e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801a0d:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801a12:	8b 40 48             	mov    0x48(%eax),%eax
  801a15:	83 ec 04             	sub    $0x4,%esp
  801a18:	53                   	push   %ebx
  801a19:	50                   	push   %eax
  801a1a:	68 e0 30 80 00       	push   $0x8030e0
  801a1f:	e8 99 eb ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801a2c:	eb 23                	jmp    801a51 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801a2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a31:	8b 52 18             	mov    0x18(%edx),%edx
  801a34:	85 d2                	test   %edx,%edx
  801a36:	74 14                	je     801a4c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a38:	83 ec 08             	sub    $0x8,%esp
  801a3b:	ff 75 0c             	pushl  0xc(%ebp)
  801a3e:	50                   	push   %eax
  801a3f:	ff d2                	call   *%edx
  801a41:	89 c2                	mov    %eax,%edx
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	eb 09                	jmp    801a51 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a48:	89 c2                	mov    %eax,%edx
  801a4a:	eb 05                	jmp    801a51 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a4c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801a51:	89 d0                	mov    %edx,%eax
  801a53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a56:	c9                   	leave  
  801a57:	c3                   	ret    

00801a58 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	53                   	push   %ebx
  801a5c:	83 ec 14             	sub    $0x14,%esp
  801a5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a62:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a65:	50                   	push   %eax
  801a66:	ff 75 08             	pushl  0x8(%ebp)
  801a69:	e8 6c fb ff ff       	call   8015da <fd_lookup>
  801a6e:	83 c4 08             	add    $0x8,%esp
  801a71:	89 c2                	mov    %eax,%edx
  801a73:	85 c0                	test   %eax,%eax
  801a75:	78 58                	js     801acf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a77:	83 ec 08             	sub    $0x8,%esp
  801a7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7d:	50                   	push   %eax
  801a7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a81:	ff 30                	pushl  (%eax)
  801a83:	e8 a8 fb ff ff       	call   801630 <dev_lookup>
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	78 37                	js     801ac6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a92:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a96:	74 32                	je     801aca <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a98:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a9b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801aa2:	00 00 00 
	stat->st_isdir = 0;
  801aa5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801aac:	00 00 00 
	stat->st_dev = dev;
  801aaf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801ab5:	83 ec 08             	sub    $0x8,%esp
  801ab8:	53                   	push   %ebx
  801ab9:	ff 75 f0             	pushl  -0x10(%ebp)
  801abc:	ff 50 14             	call   *0x14(%eax)
  801abf:	89 c2                	mov    %eax,%edx
  801ac1:	83 c4 10             	add    $0x10,%esp
  801ac4:	eb 09                	jmp    801acf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ac6:	89 c2                	mov    %eax,%edx
  801ac8:	eb 05                	jmp    801acf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801aca:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801acf:	89 d0                	mov    %edx,%eax
  801ad1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad4:	c9                   	leave  
  801ad5:	c3                   	ret    

00801ad6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	56                   	push   %esi
  801ada:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801adb:	83 ec 08             	sub    $0x8,%esp
  801ade:	6a 00                	push   $0x0
  801ae0:	ff 75 08             	pushl  0x8(%ebp)
  801ae3:	e8 2b 02 00 00       	call   801d13 <open>
  801ae8:	89 c3                	mov    %eax,%ebx
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	85 c0                	test   %eax,%eax
  801aef:	78 1b                	js     801b0c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801af1:	83 ec 08             	sub    $0x8,%esp
  801af4:	ff 75 0c             	pushl  0xc(%ebp)
  801af7:	50                   	push   %eax
  801af8:	e8 5b ff ff ff       	call   801a58 <fstat>
  801afd:	89 c6                	mov    %eax,%esi
	close(fd);
  801aff:	89 1c 24             	mov    %ebx,(%esp)
  801b02:	e8 fd fb ff ff       	call   801704 <close>
	return r;
  801b07:	83 c4 10             	add    $0x10,%esp
  801b0a:	89 f0                	mov    %esi,%eax
}
  801b0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b0f:	5b                   	pop    %ebx
  801b10:	5e                   	pop    %esi
  801b11:	5d                   	pop    %ebp
  801b12:	c3                   	ret    

00801b13 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	56                   	push   %esi
  801b17:	53                   	push   %ebx
  801b18:	89 c6                	mov    %eax,%esi
  801b1a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801b1c:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801b23:	75 12                	jne    801b37 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b25:	83 ec 0c             	sub    $0xc,%esp
  801b28:	6a 01                	push   $0x1
  801b2a:	e8 36 0d 00 00       	call   802865 <ipc_find_env>
  801b2f:	a3 04 50 80 00       	mov    %eax,0x805004
  801b34:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b37:	6a 07                	push   $0x7
  801b39:	68 00 60 80 00       	push   $0x806000
  801b3e:	56                   	push   %esi
  801b3f:	ff 35 04 50 80 00    	pushl  0x805004
  801b45:	e8 c5 0c 00 00       	call   80280f <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801b4a:	83 c4 0c             	add    $0xc,%esp
  801b4d:	6a 00                	push   $0x0
  801b4f:	53                   	push   %ebx
  801b50:	6a 00                	push   $0x0
  801b52:	e8 4f 0c 00 00       	call   8027a6 <ipc_recv>
}
  801b57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5a:	5b                   	pop    %ebx
  801b5b:	5e                   	pop    %esi
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    

00801b5e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b64:	8b 45 08             	mov    0x8(%ebp),%eax
  801b67:	8b 40 0c             	mov    0xc(%eax),%eax
  801b6a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b72:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b77:	ba 00 00 00 00       	mov    $0x0,%edx
  801b7c:	b8 02 00 00 00       	mov    $0x2,%eax
  801b81:	e8 8d ff ff ff       	call   801b13 <fsipc>
}
  801b86:	c9                   	leave  
  801b87:	c3                   	ret    

00801b88 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b91:	8b 40 0c             	mov    0xc(%eax),%eax
  801b94:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b99:	ba 00 00 00 00       	mov    $0x0,%edx
  801b9e:	b8 06 00 00 00       	mov    $0x6,%eax
  801ba3:	e8 6b ff ff ff       	call   801b13 <fsipc>
}
  801ba8:	c9                   	leave  
  801ba9:	c3                   	ret    

00801baa <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801baa:	55                   	push   %ebp
  801bab:	89 e5                	mov    %esp,%ebp
  801bad:	53                   	push   %ebx
  801bae:	83 ec 04             	sub    $0x4,%esp
  801bb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb7:	8b 40 0c             	mov    0xc(%eax),%eax
  801bba:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801bbf:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc4:	b8 05 00 00 00       	mov    $0x5,%eax
  801bc9:	e8 45 ff ff ff       	call   801b13 <fsipc>
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	78 2c                	js     801bfe <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801bd2:	83 ec 08             	sub    $0x8,%esp
  801bd5:	68 00 60 80 00       	push   $0x806000
  801bda:	53                   	push   %ebx
  801bdb:	e8 11 f0 ff ff       	call   800bf1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801be0:	a1 80 60 80 00       	mov    0x806080,%eax
  801be5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801beb:	a1 84 60 80 00       	mov    0x806084,%eax
  801bf0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bfe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c01:	c9                   	leave  
  801c02:	c3                   	ret    

00801c03 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	53                   	push   %ebx
  801c07:	83 ec 08             	sub    $0x8,%esp
  801c0a:	8b 45 10             	mov    0x10(%ebp),%eax
  801c0d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801c12:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801c17:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1d:	8b 40 0c             	mov    0xc(%eax),%eax
  801c20:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.write.req_n = n;
  801c25:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801c2b:	53                   	push   %ebx
  801c2c:	ff 75 0c             	pushl  0xc(%ebp)
  801c2f:	68 08 60 80 00       	push   $0x806008
  801c34:	e8 4a f1 ff ff       	call   800d83 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801c39:	ba 00 00 00 00       	mov    $0x0,%edx
  801c3e:	b8 04 00 00 00       	mov    $0x4,%eax
  801c43:	e8 cb fe ff ff       	call   801b13 <fsipc>
  801c48:	83 c4 10             	add    $0x10,%esp
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	78 3d                	js     801c8c <devfile_write+0x89>
		return r;

	assert(r <= n);
  801c4f:	39 d8                	cmp    %ebx,%eax
  801c51:	76 19                	jbe    801c6c <devfile_write+0x69>
  801c53:	68 4c 31 80 00       	push   $0x80314c
  801c58:	68 53 31 80 00       	push   $0x803153
  801c5d:	68 9f 00 00 00       	push   $0x9f
  801c62:	68 68 31 80 00       	push   $0x803168
  801c67:	e8 78 e8 ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801c6c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801c71:	76 19                	jbe    801c8c <devfile_write+0x89>
  801c73:	68 80 31 80 00       	push   $0x803180
  801c78:	68 53 31 80 00       	push   $0x803153
  801c7d:	68 a0 00 00 00       	push   $0xa0
  801c82:	68 68 31 80 00       	push   $0x803168
  801c87:	e8 58 e8 ff ff       	call   8004e4 <_panic>

	return r;
}
  801c8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c8f:	c9                   	leave  
  801c90:	c3                   	ret    

00801c91 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	56                   	push   %esi
  801c95:	53                   	push   %ebx
  801c96:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c99:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9c:	8b 40 0c             	mov    0xc(%eax),%eax
  801c9f:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801ca4:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801caa:	ba 00 00 00 00       	mov    $0x0,%edx
  801caf:	b8 03 00 00 00       	mov    $0x3,%eax
  801cb4:	e8 5a fe ff ff       	call   801b13 <fsipc>
  801cb9:	89 c3                	mov    %eax,%ebx
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	78 4b                	js     801d0a <devfile_read+0x79>
		return r;
	assert(r <= n);
  801cbf:	39 c6                	cmp    %eax,%esi
  801cc1:	73 16                	jae    801cd9 <devfile_read+0x48>
  801cc3:	68 4c 31 80 00       	push   $0x80314c
  801cc8:	68 53 31 80 00       	push   $0x803153
  801ccd:	6a 7e                	push   $0x7e
  801ccf:	68 68 31 80 00       	push   $0x803168
  801cd4:	e8 0b e8 ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801cd9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801cde:	7e 16                	jle    801cf6 <devfile_read+0x65>
  801ce0:	68 73 31 80 00       	push   $0x803173
  801ce5:	68 53 31 80 00       	push   $0x803153
  801cea:	6a 7f                	push   $0x7f
  801cec:	68 68 31 80 00       	push   $0x803168
  801cf1:	e8 ee e7 ff ff       	call   8004e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801cf6:	83 ec 04             	sub    $0x4,%esp
  801cf9:	50                   	push   %eax
  801cfa:	68 00 60 80 00       	push   $0x806000
  801cff:	ff 75 0c             	pushl  0xc(%ebp)
  801d02:	e8 7c f0 ff ff       	call   800d83 <memmove>
	return r;
  801d07:	83 c4 10             	add    $0x10,%esp
}
  801d0a:	89 d8                	mov    %ebx,%eax
  801d0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    

00801d13 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	53                   	push   %ebx
  801d17:	83 ec 20             	sub    $0x20,%esp
  801d1a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801d1d:	53                   	push   %ebx
  801d1e:	e8 95 ee ff ff       	call   800bb8 <strlen>
  801d23:	83 c4 10             	add    $0x10,%esp
  801d26:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d2b:	7f 67                	jg     801d94 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d2d:	83 ec 0c             	sub    $0xc,%esp
  801d30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d33:	50                   	push   %eax
  801d34:	e8 52 f8 ff ff       	call   80158b <fd_alloc>
  801d39:	83 c4 10             	add    $0x10,%esp
		return r;
  801d3c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	78 57                	js     801d99 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801d42:	83 ec 08             	sub    $0x8,%esp
  801d45:	53                   	push   %ebx
  801d46:	68 00 60 80 00       	push   $0x806000
  801d4b:	e8 a1 ee ff ff       	call   800bf1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d53:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d58:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d5b:	b8 01 00 00 00       	mov    $0x1,%eax
  801d60:	e8 ae fd ff ff       	call   801b13 <fsipc>
  801d65:	89 c3                	mov    %eax,%ebx
  801d67:	83 c4 10             	add    $0x10,%esp
  801d6a:	85 c0                	test   %eax,%eax
  801d6c:	79 14                	jns    801d82 <open+0x6f>
		fd_close(fd, 0);
  801d6e:	83 ec 08             	sub    $0x8,%esp
  801d71:	6a 00                	push   $0x0
  801d73:	ff 75 f4             	pushl  -0xc(%ebp)
  801d76:	e8 08 f9 ff ff       	call   801683 <fd_close>
		return r;
  801d7b:	83 c4 10             	add    $0x10,%esp
  801d7e:	89 da                	mov    %ebx,%edx
  801d80:	eb 17                	jmp    801d99 <open+0x86>
	}

	return fd2num(fd);
  801d82:	83 ec 0c             	sub    $0xc,%esp
  801d85:	ff 75 f4             	pushl  -0xc(%ebp)
  801d88:	e8 d7 f7 ff ff       	call   801564 <fd2num>
  801d8d:	89 c2                	mov    %eax,%edx
  801d8f:	83 c4 10             	add    $0x10,%esp
  801d92:	eb 05                	jmp    801d99 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d94:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d99:	89 d0                	mov    %edx,%eax
  801d9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d9e:	c9                   	leave  
  801d9f:	c3                   	ret    

00801da0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801da6:	ba 00 00 00 00       	mov    $0x0,%edx
  801dab:	b8 08 00 00 00       	mov    $0x8,%eax
  801db0:	e8 5e fd ff ff       	call   801b13 <fsipc>
}
  801db5:	c9                   	leave  
  801db6:	c3                   	ret    

00801db7 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	57                   	push   %edi
  801dbb:	56                   	push   %esi
  801dbc:	53                   	push   %ebx
  801dbd:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801dc3:	6a 00                	push   $0x0
  801dc5:	ff 75 08             	pushl  0x8(%ebp)
  801dc8:	e8 46 ff ff ff       	call   801d13 <open>
  801dcd:	89 c7                	mov    %eax,%edi
  801dcf:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801dd5:	83 c4 10             	add    $0x10,%esp
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	0f 88 af 04 00 00    	js     80228f <spawn+0x4d8>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801de0:	83 ec 04             	sub    $0x4,%esp
  801de3:	68 00 02 00 00       	push   $0x200
  801de8:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801dee:	50                   	push   %eax
  801def:	57                   	push   %edi
  801df0:	e8 dc fa ff ff       	call   8018d1 <readn>
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	3d 00 02 00 00       	cmp    $0x200,%eax
  801dfd:	75 0c                	jne    801e0b <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801dff:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801e06:	45 4c 46 
  801e09:	74 33                	je     801e3e <spawn+0x87>
		close(fd);
  801e0b:	83 ec 0c             	sub    $0xc,%esp
  801e0e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e14:	e8 eb f8 ff ff       	call   801704 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801e19:	83 c4 0c             	add    $0xc,%esp
  801e1c:	68 7f 45 4c 46       	push   $0x464c457f
  801e21:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801e27:	68 ad 31 80 00       	push   $0x8031ad
  801e2c:	e8 8c e7 ff ff       	call   8005bd <cprintf>
		return -E_NOT_EXEC;
  801e31:	83 c4 10             	add    $0x10,%esp
  801e34:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801e39:	e9 b1 04 00 00       	jmp    8022ef <spawn+0x538>
  801e3e:	b8 07 00 00 00       	mov    $0x7,%eax
  801e43:	cd 30                	int    $0x30
  801e45:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801e4b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801e51:	85 c0                	test   %eax,%eax
  801e53:	0f 88 3e 04 00 00    	js     802297 <spawn+0x4e0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801e59:	89 c6                	mov    %eax,%esi
  801e5b:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801e61:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801e64:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801e6a:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801e70:	b9 11 00 00 00       	mov    $0x11,%ecx
  801e75:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801e77:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801e7d:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801e83:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801e88:	be 00 00 00 00       	mov    $0x0,%esi
  801e8d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e90:	eb 13                	jmp    801ea5 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801e92:	83 ec 0c             	sub    $0xc,%esp
  801e95:	50                   	push   %eax
  801e96:	e8 1d ed ff ff       	call   800bb8 <strlen>
  801e9b:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801e9f:	83 c3 01             	add    $0x1,%ebx
  801ea2:	83 c4 10             	add    $0x10,%esp
  801ea5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801eac:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	75 df                	jne    801e92 <spawn+0xdb>
  801eb3:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801eb9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801ebf:	bf 00 10 40 00       	mov    $0x401000,%edi
  801ec4:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801ec6:	89 fa                	mov    %edi,%edx
  801ec8:	83 e2 fc             	and    $0xfffffffc,%edx
  801ecb:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801ed2:	29 c2                	sub    %eax,%edx
  801ed4:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801eda:	8d 42 f8             	lea    -0x8(%edx),%eax
  801edd:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801ee2:	0f 86 bf 03 00 00    	jbe    8022a7 <spawn+0x4f0>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ee8:	83 ec 04             	sub    $0x4,%esp
  801eeb:	6a 07                	push   $0x7
  801eed:	68 00 00 40 00       	push   $0x400000
  801ef2:	6a 00                	push   $0x0
  801ef4:	e8 72 f1 ff ff       	call   80106b <sys_page_alloc>
  801ef9:	83 c4 10             	add    $0x10,%esp
  801efc:	85 c0                	test   %eax,%eax
  801efe:	0f 88 aa 03 00 00    	js     8022ae <spawn+0x4f7>
  801f04:	be 00 00 00 00       	mov    $0x0,%esi
  801f09:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801f0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f12:	eb 30                	jmp    801f44 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801f14:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801f1a:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801f20:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801f23:	83 ec 08             	sub    $0x8,%esp
  801f26:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801f29:	57                   	push   %edi
  801f2a:	e8 c2 ec ff ff       	call   800bf1 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801f2f:	83 c4 04             	add    $0x4,%esp
  801f32:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801f35:	e8 7e ec ff ff       	call   800bb8 <strlen>
  801f3a:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801f3e:	83 c6 01             	add    $0x1,%esi
  801f41:	83 c4 10             	add    $0x10,%esp
  801f44:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801f4a:	7f c8                	jg     801f14 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801f4c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801f52:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801f58:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801f5f:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801f65:	74 19                	je     801f80 <spawn+0x1c9>
  801f67:	68 1c 32 80 00       	push   $0x80321c
  801f6c:	68 53 31 80 00       	push   $0x803153
  801f71:	68 f2 00 00 00       	push   $0xf2
  801f76:	68 c7 31 80 00       	push   $0x8031c7
  801f7b:	e8 64 e5 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801f80:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801f86:	89 f8                	mov    %edi,%eax
  801f88:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801f8d:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801f90:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f96:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801f99:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801f9f:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801fa5:	83 ec 0c             	sub    $0xc,%esp
  801fa8:	6a 07                	push   $0x7
  801faa:	68 00 d0 bf ee       	push   $0xeebfd000
  801faf:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801fb5:	68 00 00 40 00       	push   $0x400000
  801fba:	6a 00                	push   $0x0
  801fbc:	e8 ed f0 ff ff       	call   8010ae <sys_page_map>
  801fc1:	89 c3                	mov    %eax,%ebx
  801fc3:	83 c4 20             	add    $0x20,%esp
  801fc6:	85 c0                	test   %eax,%eax
  801fc8:	0f 88 0f 03 00 00    	js     8022dd <spawn+0x526>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801fce:	83 ec 08             	sub    $0x8,%esp
  801fd1:	68 00 00 40 00       	push   $0x400000
  801fd6:	6a 00                	push   $0x0
  801fd8:	e8 13 f1 ff ff       	call   8010f0 <sys_page_unmap>
  801fdd:	89 c3                	mov    %eax,%ebx
  801fdf:	83 c4 10             	add    $0x10,%esp
  801fe2:	85 c0                	test   %eax,%eax
  801fe4:	0f 88 f3 02 00 00    	js     8022dd <spawn+0x526>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801fea:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801ff0:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ff7:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ffd:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802004:	00 00 00 
  802007:	e9 88 01 00 00       	jmp    802194 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  80200c:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802012:	83 38 01             	cmpl   $0x1,(%eax)
  802015:	0f 85 6b 01 00 00    	jne    802186 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80201b:	89 c7                	mov    %eax,%edi
  80201d:	8b 40 18             	mov    0x18(%eax),%eax
  802020:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802026:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802029:	83 f8 01             	cmp    $0x1,%eax
  80202c:	19 c0                	sbb    %eax,%eax
  80202e:	83 e0 fe             	and    $0xfffffffe,%eax
  802031:	83 c0 07             	add    $0x7,%eax
  802034:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80203a:	89 f8                	mov    %edi,%eax
  80203c:	8b 7f 04             	mov    0x4(%edi),%edi
  80203f:	89 f9                	mov    %edi,%ecx
  802041:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  802047:	8b 78 10             	mov    0x10(%eax),%edi
  80204a:	8b 50 14             	mov    0x14(%eax),%edx
  80204d:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  802053:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802056:	89 f0                	mov    %esi,%eax
  802058:	25 ff 0f 00 00       	and    $0xfff,%eax
  80205d:	74 14                	je     802073 <spawn+0x2bc>
		va -= i;
  80205f:	29 c6                	sub    %eax,%esi
		memsz += i;
  802061:	01 c2                	add    %eax,%edx
  802063:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  802069:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80206b:	29 c1                	sub    %eax,%ecx
  80206d:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802073:	bb 00 00 00 00       	mov    $0x0,%ebx
  802078:	e9 f7 00 00 00       	jmp    802174 <spawn+0x3bd>
		if (i >= filesz) {
  80207d:	39 df                	cmp    %ebx,%edi
  80207f:	77 27                	ja     8020a8 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802081:	83 ec 04             	sub    $0x4,%esp
  802084:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80208a:	56                   	push   %esi
  80208b:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802091:	e8 d5 ef ff ff       	call   80106b <sys_page_alloc>
  802096:	83 c4 10             	add    $0x10,%esp
  802099:	85 c0                	test   %eax,%eax
  80209b:	0f 89 c7 00 00 00    	jns    802168 <spawn+0x3b1>
  8020a1:	89 c3                	mov    %eax,%ebx
  8020a3:	e9 14 02 00 00       	jmp    8022bc <spawn+0x505>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8020a8:	83 ec 04             	sub    $0x4,%esp
  8020ab:	6a 07                	push   $0x7
  8020ad:	68 00 00 40 00       	push   $0x400000
  8020b2:	6a 00                	push   $0x0
  8020b4:	e8 b2 ef ff ff       	call   80106b <sys_page_alloc>
  8020b9:	83 c4 10             	add    $0x10,%esp
  8020bc:	85 c0                	test   %eax,%eax
  8020be:	0f 88 ee 01 00 00    	js     8022b2 <spawn+0x4fb>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8020c4:	83 ec 08             	sub    $0x8,%esp
  8020c7:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8020cd:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8020d3:	50                   	push   %eax
  8020d4:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8020da:	e8 c7 f8 ff ff       	call   8019a6 <seek>
  8020df:	83 c4 10             	add    $0x10,%esp
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	0f 88 cc 01 00 00    	js     8022b6 <spawn+0x4ff>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8020ea:	83 ec 04             	sub    $0x4,%esp
  8020ed:	89 f8                	mov    %edi,%eax
  8020ef:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8020f5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8020fa:	ba 00 10 00 00       	mov    $0x1000,%edx
  8020ff:	0f 47 c2             	cmova  %edx,%eax
  802102:	50                   	push   %eax
  802103:	68 00 00 40 00       	push   $0x400000
  802108:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80210e:	e8 be f7 ff ff       	call   8018d1 <readn>
  802113:	83 c4 10             	add    $0x10,%esp
  802116:	85 c0                	test   %eax,%eax
  802118:	0f 88 9c 01 00 00    	js     8022ba <spawn+0x503>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80211e:	83 ec 0c             	sub    $0xc,%esp
  802121:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802127:	56                   	push   %esi
  802128:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80212e:	68 00 00 40 00       	push   $0x400000
  802133:	6a 00                	push   $0x0
  802135:	e8 74 ef ff ff       	call   8010ae <sys_page_map>
  80213a:	83 c4 20             	add    $0x20,%esp
  80213d:	85 c0                	test   %eax,%eax
  80213f:	79 15                	jns    802156 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  802141:	50                   	push   %eax
  802142:	68 d3 31 80 00       	push   $0x8031d3
  802147:	68 25 01 00 00       	push   $0x125
  80214c:	68 c7 31 80 00       	push   $0x8031c7
  802151:	e8 8e e3 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  802156:	83 ec 08             	sub    $0x8,%esp
  802159:	68 00 00 40 00       	push   $0x400000
  80215e:	6a 00                	push   $0x0
  802160:	e8 8b ef ff ff       	call   8010f0 <sys_page_unmap>
  802165:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802168:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80216e:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802174:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80217a:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  802180:	0f 87 f7 fe ff ff    	ja     80207d <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802186:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  80218d:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802194:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80219b:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8021a1:	0f 8c 65 fe ff ff    	jl     80200c <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8021a7:	83 ec 0c             	sub    $0xc,%esp
  8021aa:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8021b0:	e8 4f f5 ff ff       	call   801704 <close>
  8021b5:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	int r;

	// loop through all page table entries
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn) {
  8021b8:	bb 00 08 00 00       	mov    $0x800,%ebx
  8021bd:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		// the page table does not exist at all
		if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) {
  8021c3:	89 d8                	mov    %ebx,%eax
  8021c5:	c1 e0 0c             	shl    $0xc,%eax
  8021c8:	89 c2                	mov    %eax,%edx
  8021ca:	c1 ea 16             	shr    $0x16,%edx
  8021cd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8021d4:	f6 c2 01             	test   $0x1,%dl
  8021d7:	75 08                	jne    8021e1 <spawn+0x42a>
			pn += NPTENTRIES - 1;
  8021d9:	81 c3 ff 03 00 00    	add    $0x3ff,%ebx
  8021df:	eb 3c                	jmp    80221d <spawn+0x466>
			continue;
		}

		// virtual page pn's page table entry
		pte_t pe = uvpt[pn];
  8021e1:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx

		// share the page with the new environment
		if(pe & PTE_SHARE) {
  8021e8:	f6 c6 04             	test   $0x4,%dh
  8021eb:	74 30                	je     80221d <spawn+0x466>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), child, 
  8021ed:	83 ec 0c             	sub    $0xc,%esp
  8021f0:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8021f6:	52                   	push   %edx
  8021f7:	50                   	push   %eax
  8021f8:	56                   	push   %esi
  8021f9:	50                   	push   %eax
  8021fa:	6a 00                	push   $0x0
  8021fc:	e8 ad ee ff ff       	call   8010ae <sys_page_map>
  802201:	83 c4 20             	add    $0x20,%esp
  802204:	85 c0                	test   %eax,%eax
  802206:	79 15                	jns    80221d <spawn+0x466>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("copy_shared: %e", r);
  802208:	50                   	push   %eax
  802209:	68 f0 31 80 00       	push   $0x8031f0
  80220e:	68 42 01 00 00       	push   $0x142
  802213:	68 c7 31 80 00       	push   $0x8031c7
  802218:	e8 c7 e2 ff ff       	call   8004e4 <_panic>
{
	// LAB 5: Your code here.
	int r;

	// loop through all page table entries
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn) {
  80221d:	83 c3 01             	add    $0x1,%ebx
  802220:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  802226:	76 9b                	jbe    8021c3 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802228:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  80222f:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802232:	83 ec 08             	sub    $0x8,%esp
  802235:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80223b:	50                   	push   %eax
  80223c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802242:	e8 2d ef ff ff       	call   801174 <sys_env_set_trapframe>
  802247:	83 c4 10             	add    $0x10,%esp
  80224a:	85 c0                	test   %eax,%eax
  80224c:	79 15                	jns    802263 <spawn+0x4ac>
		panic("sys_env_set_trapframe: %e", r);
  80224e:	50                   	push   %eax
  80224f:	68 00 32 80 00       	push   $0x803200
  802254:	68 86 00 00 00       	push   $0x86
  802259:	68 c7 31 80 00       	push   $0x8031c7
  80225e:	e8 81 e2 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802263:	83 ec 08             	sub    $0x8,%esp
  802266:	6a 02                	push   $0x2
  802268:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80226e:	e8 bf ee ff ff       	call   801132 <sys_env_set_status>
  802273:	83 c4 10             	add    $0x10,%esp
  802276:	85 c0                	test   %eax,%eax
  802278:	79 25                	jns    80229f <spawn+0x4e8>
		panic("sys_env_set_status: %e", r);
  80227a:	50                   	push   %eax
  80227b:	68 73 30 80 00       	push   $0x803073
  802280:	68 89 00 00 00       	push   $0x89
  802285:	68 c7 31 80 00       	push   $0x8031c7
  80228a:	e8 55 e2 ff ff       	call   8004e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80228f:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802295:	eb 58                	jmp    8022ef <spawn+0x538>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802297:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80229d:	eb 50                	jmp    8022ef <spawn+0x538>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  80229f:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8022a5:	eb 48                	jmp    8022ef <spawn+0x538>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8022a7:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8022ac:	eb 41                	jmp    8022ef <spawn+0x538>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8022ae:	89 c3                	mov    %eax,%ebx
  8022b0:	eb 3d                	jmp    8022ef <spawn+0x538>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8022b2:	89 c3                	mov    %eax,%ebx
  8022b4:	eb 06                	jmp    8022bc <spawn+0x505>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8022b6:	89 c3                	mov    %eax,%ebx
  8022b8:	eb 02                	jmp    8022bc <spawn+0x505>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8022ba:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8022bc:	83 ec 0c             	sub    $0xc,%esp
  8022bf:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8022c5:	e8 22 ed ff ff       	call   800fec <sys_env_destroy>
	close(fd);
  8022ca:	83 c4 04             	add    $0x4,%esp
  8022cd:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8022d3:	e8 2c f4 ff ff       	call   801704 <close>
	return r;
  8022d8:	83 c4 10             	add    $0x10,%esp
  8022db:	eb 12                	jmp    8022ef <spawn+0x538>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8022dd:	83 ec 08             	sub    $0x8,%esp
  8022e0:	68 00 00 40 00       	push   $0x400000
  8022e5:	6a 00                	push   $0x0
  8022e7:	e8 04 ee ff ff       	call   8010f0 <sys_page_unmap>
  8022ec:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8022ef:	89 d8                	mov    %ebx,%eax
  8022f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022f4:	5b                   	pop    %ebx
  8022f5:	5e                   	pop    %esi
  8022f6:	5f                   	pop    %edi
  8022f7:	5d                   	pop    %ebp
  8022f8:	c3                   	ret    

008022f9 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8022f9:	55                   	push   %ebp
  8022fa:	89 e5                	mov    %esp,%ebp
  8022fc:	56                   	push   %esi
  8022fd:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8022fe:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802301:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802306:	eb 03                	jmp    80230b <spawnl+0x12>
		argc++;
  802308:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80230b:	83 c2 04             	add    $0x4,%edx
  80230e:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802312:	75 f4                	jne    802308 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802314:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  80231b:	83 e2 f0             	and    $0xfffffff0,%edx
  80231e:	29 d4                	sub    %edx,%esp
  802320:	8d 54 24 03          	lea    0x3(%esp),%edx
  802324:	c1 ea 02             	shr    $0x2,%edx
  802327:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  80232e:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802333:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  80233a:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802341:	00 
  802342:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802344:	b8 00 00 00 00       	mov    $0x0,%eax
  802349:	eb 0a                	jmp    802355 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  80234b:	83 c0 01             	add    $0x1,%eax
  80234e:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802352:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802355:	39 d0                	cmp    %edx,%eax
  802357:	75 f2                	jne    80234b <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802359:	83 ec 08             	sub    $0x8,%esp
  80235c:	56                   	push   %esi
  80235d:	ff 75 08             	pushl  0x8(%ebp)
  802360:	e8 52 fa ff ff       	call   801db7 <spawn>
}
  802365:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802368:	5b                   	pop    %ebx
  802369:	5e                   	pop    %esi
  80236a:	5d                   	pop    %ebp
  80236b:	c3                   	ret    

0080236c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80236c:	55                   	push   %ebp
  80236d:	89 e5                	mov    %esp,%ebp
  80236f:	56                   	push   %esi
  802370:	53                   	push   %ebx
  802371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802374:	83 ec 0c             	sub    $0xc,%esp
  802377:	ff 75 08             	pushl  0x8(%ebp)
  80237a:	e8 f5 f1 ff ff       	call   801574 <fd2data>
  80237f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802381:	83 c4 08             	add    $0x8,%esp
  802384:	68 42 32 80 00       	push   $0x803242
  802389:	53                   	push   %ebx
  80238a:	e8 62 e8 ff ff       	call   800bf1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80238f:	8b 46 04             	mov    0x4(%esi),%eax
  802392:	2b 06                	sub    (%esi),%eax
  802394:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80239a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8023a1:	00 00 00 
	stat->st_dev = &devpipe;
  8023a4:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  8023ab:	40 80 00 
	return 0;
}
  8023ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8023b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023b6:	5b                   	pop    %ebx
  8023b7:	5e                   	pop    %esi
  8023b8:	5d                   	pop    %ebp
  8023b9:	c3                   	ret    

008023ba <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8023ba:	55                   	push   %ebp
  8023bb:	89 e5                	mov    %esp,%ebp
  8023bd:	53                   	push   %ebx
  8023be:	83 ec 0c             	sub    $0xc,%esp
  8023c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8023c4:	53                   	push   %ebx
  8023c5:	6a 00                	push   $0x0
  8023c7:	e8 24 ed ff ff       	call   8010f0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8023cc:	89 1c 24             	mov    %ebx,(%esp)
  8023cf:	e8 a0 f1 ff ff       	call   801574 <fd2data>
  8023d4:	83 c4 08             	add    $0x8,%esp
  8023d7:	50                   	push   %eax
  8023d8:	6a 00                	push   $0x0
  8023da:	e8 11 ed ff ff       	call   8010f0 <sys_page_unmap>
}
  8023df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023e2:	c9                   	leave  
  8023e3:	c3                   	ret    

008023e4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8023e4:	55                   	push   %ebp
  8023e5:	89 e5                	mov    %esp,%ebp
  8023e7:	57                   	push   %edi
  8023e8:	56                   	push   %esi
  8023e9:	53                   	push   %ebx
  8023ea:	83 ec 1c             	sub    $0x1c,%esp
  8023ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8023f0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8023f2:	a1 08 50 80 00       	mov    0x805008,%eax
  8023f7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8023fa:	83 ec 0c             	sub    $0xc,%esp
  8023fd:	ff 75 e0             	pushl  -0x20(%ebp)
  802400:	e8 99 04 00 00       	call   80289e <pageref>
  802405:	89 c3                	mov    %eax,%ebx
  802407:	89 3c 24             	mov    %edi,(%esp)
  80240a:	e8 8f 04 00 00       	call   80289e <pageref>
  80240f:	83 c4 10             	add    $0x10,%esp
  802412:	39 c3                	cmp    %eax,%ebx
  802414:	0f 94 c1             	sete   %cl
  802417:	0f b6 c9             	movzbl %cl,%ecx
  80241a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80241d:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802423:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802426:	39 ce                	cmp    %ecx,%esi
  802428:	74 1b                	je     802445 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80242a:	39 c3                	cmp    %eax,%ebx
  80242c:	75 c4                	jne    8023f2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80242e:	8b 42 58             	mov    0x58(%edx),%eax
  802431:	ff 75 e4             	pushl  -0x1c(%ebp)
  802434:	50                   	push   %eax
  802435:	56                   	push   %esi
  802436:	68 49 32 80 00       	push   $0x803249
  80243b:	e8 7d e1 ff ff       	call   8005bd <cprintf>
  802440:	83 c4 10             	add    $0x10,%esp
  802443:	eb ad                	jmp    8023f2 <_pipeisclosed+0xe>
	}
}
  802445:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802448:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80244b:	5b                   	pop    %ebx
  80244c:	5e                   	pop    %esi
  80244d:	5f                   	pop    %edi
  80244e:	5d                   	pop    %ebp
  80244f:	c3                   	ret    

00802450 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802450:	55                   	push   %ebp
  802451:	89 e5                	mov    %esp,%ebp
  802453:	57                   	push   %edi
  802454:	56                   	push   %esi
  802455:	53                   	push   %ebx
  802456:	83 ec 28             	sub    $0x28,%esp
  802459:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80245c:	56                   	push   %esi
  80245d:	e8 12 f1 ff ff       	call   801574 <fd2data>
  802462:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802464:	83 c4 10             	add    $0x10,%esp
  802467:	bf 00 00 00 00       	mov    $0x0,%edi
  80246c:	eb 4b                	jmp    8024b9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80246e:	89 da                	mov    %ebx,%edx
  802470:	89 f0                	mov    %esi,%eax
  802472:	e8 6d ff ff ff       	call   8023e4 <_pipeisclosed>
  802477:	85 c0                	test   %eax,%eax
  802479:	75 48                	jne    8024c3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80247b:	e8 cc eb ff ff       	call   80104c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802480:	8b 43 04             	mov    0x4(%ebx),%eax
  802483:	8b 0b                	mov    (%ebx),%ecx
  802485:	8d 51 20             	lea    0x20(%ecx),%edx
  802488:	39 d0                	cmp    %edx,%eax
  80248a:	73 e2                	jae    80246e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80248c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80248f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802493:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802496:	89 c2                	mov    %eax,%edx
  802498:	c1 fa 1f             	sar    $0x1f,%edx
  80249b:	89 d1                	mov    %edx,%ecx
  80249d:	c1 e9 1b             	shr    $0x1b,%ecx
  8024a0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8024a3:	83 e2 1f             	and    $0x1f,%edx
  8024a6:	29 ca                	sub    %ecx,%edx
  8024a8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8024ac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8024b0:	83 c0 01             	add    $0x1,%eax
  8024b3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024b6:	83 c7 01             	add    $0x1,%edi
  8024b9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8024bc:	75 c2                	jne    802480 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8024be:	8b 45 10             	mov    0x10(%ebp),%eax
  8024c1:	eb 05                	jmp    8024c8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8024c3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8024c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024cb:	5b                   	pop    %ebx
  8024cc:	5e                   	pop    %esi
  8024cd:	5f                   	pop    %edi
  8024ce:	5d                   	pop    %ebp
  8024cf:	c3                   	ret    

008024d0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8024d0:	55                   	push   %ebp
  8024d1:	89 e5                	mov    %esp,%ebp
  8024d3:	57                   	push   %edi
  8024d4:	56                   	push   %esi
  8024d5:	53                   	push   %ebx
  8024d6:	83 ec 18             	sub    $0x18,%esp
  8024d9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8024dc:	57                   	push   %edi
  8024dd:	e8 92 f0 ff ff       	call   801574 <fd2data>
  8024e2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024e4:	83 c4 10             	add    $0x10,%esp
  8024e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024ec:	eb 3d                	jmp    80252b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8024ee:	85 db                	test   %ebx,%ebx
  8024f0:	74 04                	je     8024f6 <devpipe_read+0x26>
				return i;
  8024f2:	89 d8                	mov    %ebx,%eax
  8024f4:	eb 44                	jmp    80253a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8024f6:	89 f2                	mov    %esi,%edx
  8024f8:	89 f8                	mov    %edi,%eax
  8024fa:	e8 e5 fe ff ff       	call   8023e4 <_pipeisclosed>
  8024ff:	85 c0                	test   %eax,%eax
  802501:	75 32                	jne    802535 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802503:	e8 44 eb ff ff       	call   80104c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802508:	8b 06                	mov    (%esi),%eax
  80250a:	3b 46 04             	cmp    0x4(%esi),%eax
  80250d:	74 df                	je     8024ee <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80250f:	99                   	cltd   
  802510:	c1 ea 1b             	shr    $0x1b,%edx
  802513:	01 d0                	add    %edx,%eax
  802515:	83 e0 1f             	and    $0x1f,%eax
  802518:	29 d0                	sub    %edx,%eax
  80251a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80251f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802522:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802525:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802528:	83 c3 01             	add    $0x1,%ebx
  80252b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80252e:	75 d8                	jne    802508 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802530:	8b 45 10             	mov    0x10(%ebp),%eax
  802533:	eb 05                	jmp    80253a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802535:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80253a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80253d:	5b                   	pop    %ebx
  80253e:	5e                   	pop    %esi
  80253f:	5f                   	pop    %edi
  802540:	5d                   	pop    %ebp
  802541:	c3                   	ret    

00802542 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802542:	55                   	push   %ebp
  802543:	89 e5                	mov    %esp,%ebp
  802545:	56                   	push   %esi
  802546:	53                   	push   %ebx
  802547:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80254a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80254d:	50                   	push   %eax
  80254e:	e8 38 f0 ff ff       	call   80158b <fd_alloc>
  802553:	83 c4 10             	add    $0x10,%esp
  802556:	89 c2                	mov    %eax,%edx
  802558:	85 c0                	test   %eax,%eax
  80255a:	0f 88 2c 01 00 00    	js     80268c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802560:	83 ec 04             	sub    $0x4,%esp
  802563:	68 07 04 00 00       	push   $0x407
  802568:	ff 75 f4             	pushl  -0xc(%ebp)
  80256b:	6a 00                	push   $0x0
  80256d:	e8 f9 ea ff ff       	call   80106b <sys_page_alloc>
  802572:	83 c4 10             	add    $0x10,%esp
  802575:	89 c2                	mov    %eax,%edx
  802577:	85 c0                	test   %eax,%eax
  802579:	0f 88 0d 01 00 00    	js     80268c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80257f:	83 ec 0c             	sub    $0xc,%esp
  802582:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802585:	50                   	push   %eax
  802586:	e8 00 f0 ff ff       	call   80158b <fd_alloc>
  80258b:	89 c3                	mov    %eax,%ebx
  80258d:	83 c4 10             	add    $0x10,%esp
  802590:	85 c0                	test   %eax,%eax
  802592:	0f 88 e2 00 00 00    	js     80267a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802598:	83 ec 04             	sub    $0x4,%esp
  80259b:	68 07 04 00 00       	push   $0x407
  8025a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8025a3:	6a 00                	push   $0x0
  8025a5:	e8 c1 ea ff ff       	call   80106b <sys_page_alloc>
  8025aa:	89 c3                	mov    %eax,%ebx
  8025ac:	83 c4 10             	add    $0x10,%esp
  8025af:	85 c0                	test   %eax,%eax
  8025b1:	0f 88 c3 00 00 00    	js     80267a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8025b7:	83 ec 0c             	sub    $0xc,%esp
  8025ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8025bd:	e8 b2 ef ff ff       	call   801574 <fd2data>
  8025c2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025c4:	83 c4 0c             	add    $0xc,%esp
  8025c7:	68 07 04 00 00       	push   $0x407
  8025cc:	50                   	push   %eax
  8025cd:	6a 00                	push   $0x0
  8025cf:	e8 97 ea ff ff       	call   80106b <sys_page_alloc>
  8025d4:	89 c3                	mov    %eax,%ebx
  8025d6:	83 c4 10             	add    $0x10,%esp
  8025d9:	85 c0                	test   %eax,%eax
  8025db:	0f 88 89 00 00 00    	js     80266a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025e1:	83 ec 0c             	sub    $0xc,%esp
  8025e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8025e7:	e8 88 ef ff ff       	call   801574 <fd2data>
  8025ec:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8025f3:	50                   	push   %eax
  8025f4:	6a 00                	push   $0x0
  8025f6:	56                   	push   %esi
  8025f7:	6a 00                	push   $0x0
  8025f9:	e8 b0 ea ff ff       	call   8010ae <sys_page_map>
  8025fe:	89 c3                	mov    %eax,%ebx
  802600:	83 c4 20             	add    $0x20,%esp
  802603:	85 c0                	test   %eax,%eax
  802605:	78 55                	js     80265c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802607:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80260d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802610:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802612:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802615:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80261c:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802622:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802625:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802627:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80262a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802631:	83 ec 0c             	sub    $0xc,%esp
  802634:	ff 75 f4             	pushl  -0xc(%ebp)
  802637:	e8 28 ef ff ff       	call   801564 <fd2num>
  80263c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80263f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802641:	83 c4 04             	add    $0x4,%esp
  802644:	ff 75 f0             	pushl  -0x10(%ebp)
  802647:	e8 18 ef ff ff       	call   801564 <fd2num>
  80264c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80264f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802652:	83 c4 10             	add    $0x10,%esp
  802655:	ba 00 00 00 00       	mov    $0x0,%edx
  80265a:	eb 30                	jmp    80268c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80265c:	83 ec 08             	sub    $0x8,%esp
  80265f:	56                   	push   %esi
  802660:	6a 00                	push   $0x0
  802662:	e8 89 ea ff ff       	call   8010f0 <sys_page_unmap>
  802667:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80266a:	83 ec 08             	sub    $0x8,%esp
  80266d:	ff 75 f0             	pushl  -0x10(%ebp)
  802670:	6a 00                	push   $0x0
  802672:	e8 79 ea ff ff       	call   8010f0 <sys_page_unmap>
  802677:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80267a:	83 ec 08             	sub    $0x8,%esp
  80267d:	ff 75 f4             	pushl  -0xc(%ebp)
  802680:	6a 00                	push   $0x0
  802682:	e8 69 ea ff ff       	call   8010f0 <sys_page_unmap>
  802687:	83 c4 10             	add    $0x10,%esp
  80268a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80268c:	89 d0                	mov    %edx,%eax
  80268e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802691:	5b                   	pop    %ebx
  802692:	5e                   	pop    %esi
  802693:	5d                   	pop    %ebp
  802694:	c3                   	ret    

00802695 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802695:	55                   	push   %ebp
  802696:	89 e5                	mov    %esp,%ebp
  802698:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80269b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80269e:	50                   	push   %eax
  80269f:	ff 75 08             	pushl  0x8(%ebp)
  8026a2:	e8 33 ef ff ff       	call   8015da <fd_lookup>
  8026a7:	83 c4 10             	add    $0x10,%esp
  8026aa:	85 c0                	test   %eax,%eax
  8026ac:	78 18                	js     8026c6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8026ae:	83 ec 0c             	sub    $0xc,%esp
  8026b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8026b4:	e8 bb ee ff ff       	call   801574 <fd2data>
	return _pipeisclosed(fd, p);
  8026b9:	89 c2                	mov    %eax,%edx
  8026bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026be:	e8 21 fd ff ff       	call   8023e4 <_pipeisclosed>
  8026c3:	83 c4 10             	add    $0x10,%esp
}
  8026c6:	c9                   	leave  
  8026c7:	c3                   	ret    

008026c8 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8026c8:	55                   	push   %ebp
  8026c9:	89 e5                	mov    %esp,%ebp
  8026cb:	56                   	push   %esi
  8026cc:	53                   	push   %ebx
  8026cd:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8026d0:	85 f6                	test   %esi,%esi
  8026d2:	75 16                	jne    8026ea <wait+0x22>
  8026d4:	68 61 32 80 00       	push   $0x803261
  8026d9:	68 53 31 80 00       	push   $0x803153
  8026de:	6a 09                	push   $0x9
  8026e0:	68 6c 32 80 00       	push   $0x80326c
  8026e5:	e8 fa dd ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  8026ea:	89 f3                	mov    %esi,%ebx
  8026ec:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8026f2:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8026f5:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8026fb:	eb 05                	jmp    802702 <wait+0x3a>
		sys_yield();
  8026fd:	e8 4a e9 ff ff       	call   80104c <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802702:	8b 43 48             	mov    0x48(%ebx),%eax
  802705:	39 c6                	cmp    %eax,%esi
  802707:	75 07                	jne    802710 <wait+0x48>
  802709:	8b 43 54             	mov    0x54(%ebx),%eax
  80270c:	85 c0                	test   %eax,%eax
  80270e:	75 ed                	jne    8026fd <wait+0x35>
		sys_yield();
}
  802710:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802713:	5b                   	pop    %ebx
  802714:	5e                   	pop    %esi
  802715:	5d                   	pop    %ebp
  802716:	c3                   	ret    

00802717 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802717:	55                   	push   %ebp
  802718:	89 e5                	mov    %esp,%ebp
  80271a:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  80271d:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802724:	75 52                	jne    802778 <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  802726:	83 ec 04             	sub    $0x4,%esp
  802729:	6a 07                	push   $0x7
  80272b:	68 00 f0 bf ee       	push   $0xeebff000
  802730:	6a 00                	push   $0x0
  802732:	e8 34 e9 ff ff       	call   80106b <sys_page_alloc>
  802737:	83 c4 10             	add    $0x10,%esp
  80273a:	85 c0                	test   %eax,%eax
  80273c:	79 12                	jns    802750 <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  80273e:	50                   	push   %eax
  80273f:	68 20 30 80 00       	push   $0x803020
  802744:	6a 23                	push   $0x23
  802746:	68 77 32 80 00       	push   $0x803277
  80274b:	e8 94 dd ff ff       	call   8004e4 <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  802750:	83 ec 08             	sub    $0x8,%esp
  802753:	68 82 27 80 00       	push   $0x802782
  802758:	6a 00                	push   $0x0
  80275a:	e8 57 ea ff ff       	call   8011b6 <sys_env_set_pgfault_upcall>
  80275f:	83 c4 10             	add    $0x10,%esp
  802762:	85 c0                	test   %eax,%eax
  802764:	79 12                	jns    802778 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  802766:	50                   	push   %eax
  802767:	68 a0 30 80 00       	push   $0x8030a0
  80276c:	6a 26                	push   $0x26
  80276e:	68 77 32 80 00       	push   $0x803277
  802773:	e8 6c dd ff ff       	call   8004e4 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802778:	8b 45 08             	mov    0x8(%ebp),%eax
  80277b:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802780:	c9                   	leave  
  802781:	c3                   	ret    

00802782 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802782:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802783:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802788:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80278a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  80278d:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  802791:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  802796:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  80279a:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80279c:	83 c4 08             	add    $0x8,%esp
	popal 
  80279f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8027a0:	83 c4 04             	add    $0x4,%esp
	popfl
  8027a3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8027a4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8027a5:	c3                   	ret    

008027a6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8027a6:	55                   	push   %ebp
  8027a7:	89 e5                	mov    %esp,%ebp
  8027a9:	56                   	push   %esi
  8027aa:	53                   	push   %ebx
  8027ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8027ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  8027b4:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8027b6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8027bb:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  8027be:	83 ec 0c             	sub    $0xc,%esp
  8027c1:	50                   	push   %eax
  8027c2:	e8 54 ea ff ff       	call   80121b <sys_ipc_recv>
  8027c7:	83 c4 10             	add    $0x10,%esp
  8027ca:	85 c0                	test   %eax,%eax
  8027cc:	79 16                	jns    8027e4 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  8027ce:	85 f6                	test   %esi,%esi
  8027d0:	74 06                	je     8027d8 <ipc_recv+0x32>
			*from_env_store = 0;
  8027d2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  8027d8:	85 db                	test   %ebx,%ebx
  8027da:	74 2c                	je     802808 <ipc_recv+0x62>
			*perm_store = 0;
  8027dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8027e2:	eb 24                	jmp    802808 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  8027e4:	85 f6                	test   %esi,%esi
  8027e6:	74 0a                	je     8027f2 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  8027e8:	a1 08 50 80 00       	mov    0x805008,%eax
  8027ed:	8b 40 74             	mov    0x74(%eax),%eax
  8027f0:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  8027f2:	85 db                	test   %ebx,%ebx
  8027f4:	74 0a                	je     802800 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  8027f6:	a1 08 50 80 00       	mov    0x805008,%eax
  8027fb:	8b 40 78             	mov    0x78(%eax),%eax
  8027fe:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  802800:	a1 08 50 80 00       	mov    0x805008,%eax
  802805:	8b 40 70             	mov    0x70(%eax),%eax
}
  802808:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80280b:	5b                   	pop    %ebx
  80280c:	5e                   	pop    %esi
  80280d:	5d                   	pop    %ebp
  80280e:	c3                   	ret    

0080280f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80280f:	55                   	push   %ebp
  802810:	89 e5                	mov    %esp,%ebp
  802812:	57                   	push   %edi
  802813:	56                   	push   %esi
  802814:	53                   	push   %ebx
  802815:	83 ec 0c             	sub    $0xc,%esp
  802818:	8b 7d 08             	mov    0x8(%ebp),%edi
  80281b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80281e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  802821:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802823:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802828:	0f 44 d8             	cmove  %eax,%ebx
  80282b:	eb 1e                	jmp    80284b <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  80282d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802830:	74 14                	je     802846 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  802832:	83 ec 04             	sub    $0x4,%esp
  802835:	68 88 32 80 00       	push   $0x803288
  80283a:	6a 44                	push   $0x44
  80283c:	68 b4 32 80 00       	push   $0x8032b4
  802841:	e8 9e dc ff ff       	call   8004e4 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  802846:	e8 01 e8 ff ff       	call   80104c <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80284b:	ff 75 14             	pushl  0x14(%ebp)
  80284e:	53                   	push   %ebx
  80284f:	56                   	push   %esi
  802850:	57                   	push   %edi
  802851:	e8 a2 e9 ff ff       	call   8011f8 <sys_ipc_try_send>
  802856:	83 c4 10             	add    $0x10,%esp
  802859:	85 c0                	test   %eax,%eax
  80285b:	78 d0                	js     80282d <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  80285d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802860:	5b                   	pop    %ebx
  802861:	5e                   	pop    %esi
  802862:	5f                   	pop    %edi
  802863:	5d                   	pop    %ebp
  802864:	c3                   	ret    

00802865 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802865:	55                   	push   %ebp
  802866:	89 e5                	mov    %esp,%ebp
  802868:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80286b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802870:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802873:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802879:	8b 52 50             	mov    0x50(%edx),%edx
  80287c:	39 ca                	cmp    %ecx,%edx
  80287e:	75 0d                	jne    80288d <ipc_find_env+0x28>
			return envs[i].env_id;
  802880:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802883:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802888:	8b 40 48             	mov    0x48(%eax),%eax
  80288b:	eb 0f                	jmp    80289c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80288d:	83 c0 01             	add    $0x1,%eax
  802890:	3d 00 04 00 00       	cmp    $0x400,%eax
  802895:	75 d9                	jne    802870 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802897:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80289c:	5d                   	pop    %ebp
  80289d:	c3                   	ret    

0080289e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80289e:	55                   	push   %ebp
  80289f:	89 e5                	mov    %esp,%ebp
  8028a1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8028a4:	89 d0                	mov    %edx,%eax
  8028a6:	c1 e8 16             	shr    $0x16,%eax
  8028a9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8028b0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8028b5:	f6 c1 01             	test   $0x1,%cl
  8028b8:	74 1d                	je     8028d7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8028ba:	c1 ea 0c             	shr    $0xc,%edx
  8028bd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8028c4:	f6 c2 01             	test   $0x1,%dl
  8028c7:	74 0e                	je     8028d7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8028c9:	c1 ea 0c             	shr    $0xc,%edx
  8028cc:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8028d3:	ef 
  8028d4:	0f b7 c0             	movzwl %ax,%eax
}
  8028d7:	5d                   	pop    %ebp
  8028d8:	c3                   	ret    
  8028d9:	66 90                	xchg   %ax,%ax
  8028db:	66 90                	xchg   %ax,%ax
  8028dd:	66 90                	xchg   %ax,%ax
  8028df:	90                   	nop

008028e0 <__udivdi3>:
  8028e0:	55                   	push   %ebp
  8028e1:	57                   	push   %edi
  8028e2:	56                   	push   %esi
  8028e3:	53                   	push   %ebx
  8028e4:	83 ec 1c             	sub    $0x1c,%esp
  8028e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8028eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8028ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8028f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028f7:	85 f6                	test   %esi,%esi
  8028f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028fd:	89 ca                	mov    %ecx,%edx
  8028ff:	89 f8                	mov    %edi,%eax
  802901:	75 3d                	jne    802940 <__udivdi3+0x60>
  802903:	39 cf                	cmp    %ecx,%edi
  802905:	0f 87 c5 00 00 00    	ja     8029d0 <__udivdi3+0xf0>
  80290b:	85 ff                	test   %edi,%edi
  80290d:	89 fd                	mov    %edi,%ebp
  80290f:	75 0b                	jne    80291c <__udivdi3+0x3c>
  802911:	b8 01 00 00 00       	mov    $0x1,%eax
  802916:	31 d2                	xor    %edx,%edx
  802918:	f7 f7                	div    %edi
  80291a:	89 c5                	mov    %eax,%ebp
  80291c:	89 c8                	mov    %ecx,%eax
  80291e:	31 d2                	xor    %edx,%edx
  802920:	f7 f5                	div    %ebp
  802922:	89 c1                	mov    %eax,%ecx
  802924:	89 d8                	mov    %ebx,%eax
  802926:	89 cf                	mov    %ecx,%edi
  802928:	f7 f5                	div    %ebp
  80292a:	89 c3                	mov    %eax,%ebx
  80292c:	89 d8                	mov    %ebx,%eax
  80292e:	89 fa                	mov    %edi,%edx
  802930:	83 c4 1c             	add    $0x1c,%esp
  802933:	5b                   	pop    %ebx
  802934:	5e                   	pop    %esi
  802935:	5f                   	pop    %edi
  802936:	5d                   	pop    %ebp
  802937:	c3                   	ret    
  802938:	90                   	nop
  802939:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802940:	39 ce                	cmp    %ecx,%esi
  802942:	77 74                	ja     8029b8 <__udivdi3+0xd8>
  802944:	0f bd fe             	bsr    %esi,%edi
  802947:	83 f7 1f             	xor    $0x1f,%edi
  80294a:	0f 84 98 00 00 00    	je     8029e8 <__udivdi3+0x108>
  802950:	bb 20 00 00 00       	mov    $0x20,%ebx
  802955:	89 f9                	mov    %edi,%ecx
  802957:	89 c5                	mov    %eax,%ebp
  802959:	29 fb                	sub    %edi,%ebx
  80295b:	d3 e6                	shl    %cl,%esi
  80295d:	89 d9                	mov    %ebx,%ecx
  80295f:	d3 ed                	shr    %cl,%ebp
  802961:	89 f9                	mov    %edi,%ecx
  802963:	d3 e0                	shl    %cl,%eax
  802965:	09 ee                	or     %ebp,%esi
  802967:	89 d9                	mov    %ebx,%ecx
  802969:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80296d:	89 d5                	mov    %edx,%ebp
  80296f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802973:	d3 ed                	shr    %cl,%ebp
  802975:	89 f9                	mov    %edi,%ecx
  802977:	d3 e2                	shl    %cl,%edx
  802979:	89 d9                	mov    %ebx,%ecx
  80297b:	d3 e8                	shr    %cl,%eax
  80297d:	09 c2                	or     %eax,%edx
  80297f:	89 d0                	mov    %edx,%eax
  802981:	89 ea                	mov    %ebp,%edx
  802983:	f7 f6                	div    %esi
  802985:	89 d5                	mov    %edx,%ebp
  802987:	89 c3                	mov    %eax,%ebx
  802989:	f7 64 24 0c          	mull   0xc(%esp)
  80298d:	39 d5                	cmp    %edx,%ebp
  80298f:	72 10                	jb     8029a1 <__udivdi3+0xc1>
  802991:	8b 74 24 08          	mov    0x8(%esp),%esi
  802995:	89 f9                	mov    %edi,%ecx
  802997:	d3 e6                	shl    %cl,%esi
  802999:	39 c6                	cmp    %eax,%esi
  80299b:	73 07                	jae    8029a4 <__udivdi3+0xc4>
  80299d:	39 d5                	cmp    %edx,%ebp
  80299f:	75 03                	jne    8029a4 <__udivdi3+0xc4>
  8029a1:	83 eb 01             	sub    $0x1,%ebx
  8029a4:	31 ff                	xor    %edi,%edi
  8029a6:	89 d8                	mov    %ebx,%eax
  8029a8:	89 fa                	mov    %edi,%edx
  8029aa:	83 c4 1c             	add    $0x1c,%esp
  8029ad:	5b                   	pop    %ebx
  8029ae:	5e                   	pop    %esi
  8029af:	5f                   	pop    %edi
  8029b0:	5d                   	pop    %ebp
  8029b1:	c3                   	ret    
  8029b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029b8:	31 ff                	xor    %edi,%edi
  8029ba:	31 db                	xor    %ebx,%ebx
  8029bc:	89 d8                	mov    %ebx,%eax
  8029be:	89 fa                	mov    %edi,%edx
  8029c0:	83 c4 1c             	add    $0x1c,%esp
  8029c3:	5b                   	pop    %ebx
  8029c4:	5e                   	pop    %esi
  8029c5:	5f                   	pop    %edi
  8029c6:	5d                   	pop    %ebp
  8029c7:	c3                   	ret    
  8029c8:	90                   	nop
  8029c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029d0:	89 d8                	mov    %ebx,%eax
  8029d2:	f7 f7                	div    %edi
  8029d4:	31 ff                	xor    %edi,%edi
  8029d6:	89 c3                	mov    %eax,%ebx
  8029d8:	89 d8                	mov    %ebx,%eax
  8029da:	89 fa                	mov    %edi,%edx
  8029dc:	83 c4 1c             	add    $0x1c,%esp
  8029df:	5b                   	pop    %ebx
  8029e0:	5e                   	pop    %esi
  8029e1:	5f                   	pop    %edi
  8029e2:	5d                   	pop    %ebp
  8029e3:	c3                   	ret    
  8029e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029e8:	39 ce                	cmp    %ecx,%esi
  8029ea:	72 0c                	jb     8029f8 <__udivdi3+0x118>
  8029ec:	31 db                	xor    %ebx,%ebx
  8029ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8029f2:	0f 87 34 ff ff ff    	ja     80292c <__udivdi3+0x4c>
  8029f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8029fd:	e9 2a ff ff ff       	jmp    80292c <__udivdi3+0x4c>
  802a02:	66 90                	xchg   %ax,%ax
  802a04:	66 90                	xchg   %ax,%ax
  802a06:	66 90                	xchg   %ax,%ax
  802a08:	66 90                	xchg   %ax,%ax
  802a0a:	66 90                	xchg   %ax,%ax
  802a0c:	66 90                	xchg   %ax,%ax
  802a0e:	66 90                	xchg   %ax,%ax

00802a10 <__umoddi3>:
  802a10:	55                   	push   %ebp
  802a11:	57                   	push   %edi
  802a12:	56                   	push   %esi
  802a13:	53                   	push   %ebx
  802a14:	83 ec 1c             	sub    $0x1c,%esp
  802a17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802a1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802a1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802a23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802a27:	85 d2                	test   %edx,%edx
  802a29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802a2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a31:	89 f3                	mov    %esi,%ebx
  802a33:	89 3c 24             	mov    %edi,(%esp)
  802a36:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a3a:	75 1c                	jne    802a58 <__umoddi3+0x48>
  802a3c:	39 f7                	cmp    %esi,%edi
  802a3e:	76 50                	jbe    802a90 <__umoddi3+0x80>
  802a40:	89 c8                	mov    %ecx,%eax
  802a42:	89 f2                	mov    %esi,%edx
  802a44:	f7 f7                	div    %edi
  802a46:	89 d0                	mov    %edx,%eax
  802a48:	31 d2                	xor    %edx,%edx
  802a4a:	83 c4 1c             	add    $0x1c,%esp
  802a4d:	5b                   	pop    %ebx
  802a4e:	5e                   	pop    %esi
  802a4f:	5f                   	pop    %edi
  802a50:	5d                   	pop    %ebp
  802a51:	c3                   	ret    
  802a52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a58:	39 f2                	cmp    %esi,%edx
  802a5a:	89 d0                	mov    %edx,%eax
  802a5c:	77 52                	ja     802ab0 <__umoddi3+0xa0>
  802a5e:	0f bd ea             	bsr    %edx,%ebp
  802a61:	83 f5 1f             	xor    $0x1f,%ebp
  802a64:	75 5a                	jne    802ac0 <__umoddi3+0xb0>
  802a66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802a6a:	0f 82 e0 00 00 00    	jb     802b50 <__umoddi3+0x140>
  802a70:	39 0c 24             	cmp    %ecx,(%esp)
  802a73:	0f 86 d7 00 00 00    	jbe    802b50 <__umoddi3+0x140>
  802a79:	8b 44 24 08          	mov    0x8(%esp),%eax
  802a7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802a81:	83 c4 1c             	add    $0x1c,%esp
  802a84:	5b                   	pop    %ebx
  802a85:	5e                   	pop    %esi
  802a86:	5f                   	pop    %edi
  802a87:	5d                   	pop    %ebp
  802a88:	c3                   	ret    
  802a89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a90:	85 ff                	test   %edi,%edi
  802a92:	89 fd                	mov    %edi,%ebp
  802a94:	75 0b                	jne    802aa1 <__umoddi3+0x91>
  802a96:	b8 01 00 00 00       	mov    $0x1,%eax
  802a9b:	31 d2                	xor    %edx,%edx
  802a9d:	f7 f7                	div    %edi
  802a9f:	89 c5                	mov    %eax,%ebp
  802aa1:	89 f0                	mov    %esi,%eax
  802aa3:	31 d2                	xor    %edx,%edx
  802aa5:	f7 f5                	div    %ebp
  802aa7:	89 c8                	mov    %ecx,%eax
  802aa9:	f7 f5                	div    %ebp
  802aab:	89 d0                	mov    %edx,%eax
  802aad:	eb 99                	jmp    802a48 <__umoddi3+0x38>
  802aaf:	90                   	nop
  802ab0:	89 c8                	mov    %ecx,%eax
  802ab2:	89 f2                	mov    %esi,%edx
  802ab4:	83 c4 1c             	add    $0x1c,%esp
  802ab7:	5b                   	pop    %ebx
  802ab8:	5e                   	pop    %esi
  802ab9:	5f                   	pop    %edi
  802aba:	5d                   	pop    %ebp
  802abb:	c3                   	ret    
  802abc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ac0:	8b 34 24             	mov    (%esp),%esi
  802ac3:	bf 20 00 00 00       	mov    $0x20,%edi
  802ac8:	89 e9                	mov    %ebp,%ecx
  802aca:	29 ef                	sub    %ebp,%edi
  802acc:	d3 e0                	shl    %cl,%eax
  802ace:	89 f9                	mov    %edi,%ecx
  802ad0:	89 f2                	mov    %esi,%edx
  802ad2:	d3 ea                	shr    %cl,%edx
  802ad4:	89 e9                	mov    %ebp,%ecx
  802ad6:	09 c2                	or     %eax,%edx
  802ad8:	89 d8                	mov    %ebx,%eax
  802ada:	89 14 24             	mov    %edx,(%esp)
  802add:	89 f2                	mov    %esi,%edx
  802adf:	d3 e2                	shl    %cl,%edx
  802ae1:	89 f9                	mov    %edi,%ecx
  802ae3:	89 54 24 04          	mov    %edx,0x4(%esp)
  802ae7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802aeb:	d3 e8                	shr    %cl,%eax
  802aed:	89 e9                	mov    %ebp,%ecx
  802aef:	89 c6                	mov    %eax,%esi
  802af1:	d3 e3                	shl    %cl,%ebx
  802af3:	89 f9                	mov    %edi,%ecx
  802af5:	89 d0                	mov    %edx,%eax
  802af7:	d3 e8                	shr    %cl,%eax
  802af9:	89 e9                	mov    %ebp,%ecx
  802afb:	09 d8                	or     %ebx,%eax
  802afd:	89 d3                	mov    %edx,%ebx
  802aff:	89 f2                	mov    %esi,%edx
  802b01:	f7 34 24             	divl   (%esp)
  802b04:	89 d6                	mov    %edx,%esi
  802b06:	d3 e3                	shl    %cl,%ebx
  802b08:	f7 64 24 04          	mull   0x4(%esp)
  802b0c:	39 d6                	cmp    %edx,%esi
  802b0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802b12:	89 d1                	mov    %edx,%ecx
  802b14:	89 c3                	mov    %eax,%ebx
  802b16:	72 08                	jb     802b20 <__umoddi3+0x110>
  802b18:	75 11                	jne    802b2b <__umoddi3+0x11b>
  802b1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802b1e:	73 0b                	jae    802b2b <__umoddi3+0x11b>
  802b20:	2b 44 24 04          	sub    0x4(%esp),%eax
  802b24:	1b 14 24             	sbb    (%esp),%edx
  802b27:	89 d1                	mov    %edx,%ecx
  802b29:	89 c3                	mov    %eax,%ebx
  802b2b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802b2f:	29 da                	sub    %ebx,%edx
  802b31:	19 ce                	sbb    %ecx,%esi
  802b33:	89 f9                	mov    %edi,%ecx
  802b35:	89 f0                	mov    %esi,%eax
  802b37:	d3 e0                	shl    %cl,%eax
  802b39:	89 e9                	mov    %ebp,%ecx
  802b3b:	d3 ea                	shr    %cl,%edx
  802b3d:	89 e9                	mov    %ebp,%ecx
  802b3f:	d3 ee                	shr    %cl,%esi
  802b41:	09 d0                	or     %edx,%eax
  802b43:	89 f2                	mov    %esi,%edx
  802b45:	83 c4 1c             	add    $0x1c,%esp
  802b48:	5b                   	pop    %ebx
  802b49:	5e                   	pop    %esi
  802b4a:	5f                   	pop    %edi
  802b4b:	5d                   	pop    %ebp
  802b4c:	c3                   	ret    
  802b4d:	8d 76 00             	lea    0x0(%esi),%esi
  802b50:	29 f9                	sub    %edi,%ecx
  802b52:	19 d6                	sbb    %edx,%esi
  802b54:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b5c:	e9 18 ff ff ff       	jmp    802a79 <__umoddi3+0x69>
