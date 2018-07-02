
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 6e 03 00 00       	call   80039f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003e:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800043:	ba 00 00 00 00       	mov    $0x0,%edx
  800048:	eb 0c                	jmp    800056 <sum+0x23>
		tot ^= i * s[i];
  80004a:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004e:	0f af ca             	imul   %edx,%ecx
  800051:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800053:	83 c2 01             	add    $0x1,%edx
  800056:	39 da                	cmp    %ebx,%edx
  800058:	7c f0                	jl     80004a <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  80005a:	5b                   	pop    %ebx
  80005b:	5e                   	pop    %esi
  80005c:	5d                   	pop    %ebp
  80005d:	c3                   	ret    

0080005e <umain>:

void
umain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	81 ec 18 01 00 00    	sub    $0x118,%esp
  80006a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006d:	68 00 27 80 00       	push   $0x802700
  800072:	e8 61 04 00 00       	call   8004d8 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800077:	83 c4 08             	add    $0x8,%esp
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 30 80 00       	push   $0x803000
  800084:	e8 aa ff ff ff       	call   800033 <sum>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 18                	je     8000ab <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	68 9e 98 0f 00       	push   $0xf989e
  80009b:	50                   	push   %eax
  80009c:	68 c8 27 80 00       	push   $0x8027c8
  8000a1:	e8 32 04 00 00       	call   8004d8 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 0f 27 80 00       	push   $0x80270f
  8000b3:	e8 20 04 00 00       	call   8004d8 <cprintf>
  8000b8:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	68 70 17 00 00       	push   $0x1770
  8000c3:	68 20 50 80 00       	push   $0x805020
  8000c8:	e8 66 ff ff ff       	call   800033 <sum>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	74 13                	je     8000e7 <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	50                   	push   %eax
  8000d8:	68 04 28 80 00       	push   $0x802804
  8000dd:	e8 f6 03 00 00       	call   8004d8 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 26 27 80 00       	push   $0x802726
  8000ef:	e8 e4 03 00 00       	call   8004d8 <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 3c 27 80 00       	push   $0x80273c
  8000ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 21 0a 00 00       	call   800b2c <strcat>
	for (i = 0; i < argc; i++) {
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800113:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800119:	eb 2e                	jmp    800149 <umain+0xeb>
		strcat(args, " '");
  80011b:	83 ec 08             	sub    $0x8,%esp
  80011e:	68 48 27 80 00       	push   $0x802748
  800123:	56                   	push   %esi
  800124:	e8 03 0a 00 00       	call   800b2c <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 f7 09 00 00       	call   800b2c <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 49 27 80 00       	push   $0x802749
  80013d:	56                   	push   %esi
  80013e:	e8 e9 09 00 00       	call   800b2c <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80014c:	7c cd                	jl     80011b <umain+0xbd>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800157:	50                   	push   %eax
  800158:	68 4b 27 80 00       	push   $0x80274b
  80015d:	e8 76 03 00 00       	call   8004d8 <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 4f 27 80 00 	movl   $0x80274f,(%esp)
  800169:	e8 6a 03 00 00       	call   8004d8 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 9d 11 00 00       	call   801317 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 61 27 80 00       	push   $0x802761
  80018c:	6a 37                	push   $0x37
  80018e:	68 6e 27 80 00       	push   $0x80276e
  800193:	e8 67 02 00 00       	call   8003ff <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 7a 27 80 00       	push   $0x80277a
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 6e 27 80 00       	push   $0x80276e
  8001a9:	e8 51 02 00 00       	call   8003ff <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 ad 11 00 00       	call   801367 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 94 27 80 00       	push   $0x802794
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 6e 27 80 00       	push   $0x80276e
  8001ce:	e8 2c 02 00 00       	call   8003ff <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 9c 27 80 00       	push   $0x80279c
  8001db:	e8 f8 02 00 00       	call   8004d8 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 b0 27 80 00       	push   $0x8027b0
  8001ea:	68 af 27 80 00       	push   $0x8027af
  8001ef:	e8 18 1d 00 00       	call   801f0c <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 b3 27 80 00       	push   $0x8027b3
  800204:	e8 cf 02 00 00       	call   8004d8 <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 c4 20 00 00       	call   8022db <wait>
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	eb b7                	jmp    8001d3 <umain+0x175>

0080021c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80021f:	b8 00 00 00 00       	mov    $0x0,%eax
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80022c:	68 33 28 80 00       	push   $0x802833
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	e8 d3 08 00 00       	call   800b0c <strcpy>
	return 0;
}
  800239:	b8 00 00 00 00       	mov    $0x0,%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80024c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800251:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800257:	eb 2d                	jmp    800286 <devcons_write+0x46>
		m = n - tot;
  800259:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80025c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80025e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800261:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800266:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800269:	83 ec 04             	sub    $0x4,%esp
  80026c:	53                   	push   %ebx
  80026d:	03 45 0c             	add    0xc(%ebp),%eax
  800270:	50                   	push   %eax
  800271:	57                   	push   %edi
  800272:	e8 27 0a 00 00       	call   800c9e <memmove>
		sys_cputs(buf, m);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	53                   	push   %ebx
  80027b:	57                   	push   %edi
  80027c:	e8 49 0c 00 00       	call   800eca <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800281:	01 de                	add    %ebx,%esi
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	89 f0                	mov    %esi,%eax
  800288:	3b 75 10             	cmp    0x10(%ebp),%esi
  80028b:	72 cc                	jb     800259 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80028d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800290:	5b                   	pop    %ebx
  800291:	5e                   	pop    %esi
  800292:	5f                   	pop    %edi
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8002a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002a4:	74 2a                	je     8002d0 <devcons_read+0x3b>
  8002a6:	eb 05                	jmp    8002ad <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002a8:	e8 ba 0c 00 00       	call   800f67 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002ad:	e8 36 0c 00 00       	call   800ee8 <sys_cgetc>
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	74 f2                	je     8002a8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	78 16                	js     8002d0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002ba:	83 f8 04             	cmp    $0x4,%eax
  8002bd:	74 0c                	je     8002cb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8002bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c2:	88 02                	mov    %al,(%edx)
	return 1;
  8002c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8002c9:	eb 05                	jmp    8002d0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8002cb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002db:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8002de:	6a 01                	push   $0x1
  8002e0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 e1 0b 00 00       	call   800eca <sys_cputs>
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <getchar>:

int
getchar(void)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8002f4:	6a 01                	push   $0x1
  8002f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	6a 00                	push   $0x0
  8002fc:	e8 52 11 00 00       	call   801453 <read>
	if (r < 0)
  800301:	83 c4 10             	add    $0x10,%esp
  800304:	85 c0                	test   %eax,%eax
  800306:	78 0f                	js     800317 <getchar+0x29>
		return r;
	if (r < 1)
  800308:	85 c0                	test   %eax,%eax
  80030a:	7e 06                	jle    800312 <getchar+0x24>
		return -E_EOF;
	return c;
  80030c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800310:	eb 05                	jmp    800317 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800312:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80031f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800322:	50                   	push   %eax
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 c2 0e 00 00       	call   8011ed <fd_lookup>
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	85 c0                	test   %eax,%eax
  800330:	78 11                	js     800343 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800335:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80033b:	39 10                	cmp    %edx,(%eax)
  80033d:	0f 94 c0             	sete   %al
  800340:	0f b6 c0             	movzbl %al,%eax
}
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <opencons>:

int
opencons(void)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80034b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80034e:	50                   	push   %eax
  80034f:	e8 4a 0e 00 00       	call   80119e <fd_alloc>
  800354:	83 c4 10             	add    $0x10,%esp
		return r;
  800357:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800359:	85 c0                	test   %eax,%eax
  80035b:	78 3e                	js     80039b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80035d:	83 ec 04             	sub    $0x4,%esp
  800360:	68 07 04 00 00       	push   $0x407
  800365:	ff 75 f4             	pushl  -0xc(%ebp)
  800368:	6a 00                	push   $0x0
  80036a:	e8 17 0c 00 00       	call   800f86 <sys_page_alloc>
  80036f:	83 c4 10             	add    $0x10,%esp
		return r;
  800372:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800374:	85 c0                	test   %eax,%eax
  800376:	78 23                	js     80039b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800378:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80037e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800381:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800386:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	50                   	push   %eax
  800391:	e8 e1 0d 00 00       	call   801177 <fd2num>
  800396:	89 c2                	mov    %eax,%edx
  800398:	83 c4 10             	add    $0x10,%esp
}
  80039b:	89 d0                	mov    %edx,%eax
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8003aa:	e8 99 0b 00 00       	call   800f48 <sys_getenvid>
  8003af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8003b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003bc:	a3 90 67 80 00       	mov    %eax,0x806790
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003c1:	85 db                	test   %ebx,%ebx
  8003c3:	7e 07                	jle    8003cc <libmain+0x2d>
		binaryname = argv[0];
  8003c5:	8b 06                	mov    (%esi),%eax
  8003c7:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  8003cc:	83 ec 08             	sub    $0x8,%esp
  8003cf:	56                   	push   %esi
  8003d0:	53                   	push   %ebx
  8003d1:	e8 88 fc ff ff       	call   80005e <umain>

	// exit gracefully
	exit();
  8003d6:	e8 0a 00 00 00       	call   8003e5 <exit>
}
  8003db:	83 c4 10             	add    $0x10,%esp
  8003de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8003eb:	e8 52 0f 00 00       	call   801342 <close_all>
	sys_env_destroy(0);
  8003f0:	83 ec 0c             	sub    $0xc,%esp
  8003f3:	6a 00                	push   $0x0
  8003f5:	e8 0d 0b 00 00       	call   800f07 <sys_env_destroy>
}
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800404:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800407:	8b 35 8c 47 80 00    	mov    0x80478c,%esi
  80040d:	e8 36 0b 00 00       	call   800f48 <sys_getenvid>
  800412:	83 ec 0c             	sub    $0xc,%esp
  800415:	ff 75 0c             	pushl  0xc(%ebp)
  800418:	ff 75 08             	pushl  0x8(%ebp)
  80041b:	56                   	push   %esi
  80041c:	50                   	push   %eax
  80041d:	68 4c 28 80 00       	push   $0x80284c
  800422:	e8 b1 00 00 00       	call   8004d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800427:	83 c4 18             	add    $0x18,%esp
  80042a:	53                   	push   %ebx
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	e8 54 00 00 00       	call   800487 <vcprintf>
	cprintf("\n");
  800433:	c7 04 24 5e 2d 80 00 	movl   $0x802d5e,(%esp)
  80043a:	e8 99 00 00 00       	call   8004d8 <cprintf>
  80043f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800442:	cc                   	int3   
  800443:	eb fd                	jmp    800442 <_panic+0x43>

00800445 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	53                   	push   %ebx
  800449:	83 ec 04             	sub    $0x4,%esp
  80044c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80044f:	8b 13                	mov    (%ebx),%edx
  800451:	8d 42 01             	lea    0x1(%edx),%eax
  800454:	89 03                	mov    %eax,(%ebx)
  800456:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800459:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80045d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800462:	75 1a                	jne    80047e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	68 ff 00 00 00       	push   $0xff
  80046c:	8d 43 08             	lea    0x8(%ebx),%eax
  80046f:	50                   	push   %eax
  800470:	e8 55 0a 00 00       	call   800eca <sys_cputs>
		b->idx = 0;
  800475:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80047b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80047e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800482:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800485:	c9                   	leave  
  800486:	c3                   	ret    

00800487 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800487:	55                   	push   %ebp
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800490:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800497:	00 00 00 
	b.cnt = 0;
  80049a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a4:	ff 75 0c             	pushl  0xc(%ebp)
  8004a7:	ff 75 08             	pushl  0x8(%ebp)
  8004aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b0:	50                   	push   %eax
  8004b1:	68 45 04 80 00       	push   $0x800445
  8004b6:	e8 54 01 00 00       	call   80060f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004bb:	83 c4 08             	add    $0x8,%esp
  8004be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004ca:	50                   	push   %eax
  8004cb:	e8 fa 09 00 00       	call   800eca <sys_cputs>

	return b.cnt;
}
  8004d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d6:	c9                   	leave  
  8004d7:	c3                   	ret    

008004d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004d8:	55                   	push   %ebp
  8004d9:	89 e5                	mov    %esp,%ebp
  8004db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e1:	50                   	push   %eax
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	e8 9d ff ff ff       	call   800487 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    

008004ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	57                   	push   %edi
  8004f0:	56                   	push   %esi
  8004f1:	53                   	push   %ebx
  8004f2:	83 ec 1c             	sub    $0x1c,%esp
  8004f5:	89 c7                	mov    %eax,%edi
  8004f7:	89 d6                	mov    %edx,%esi
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800502:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800505:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800508:	bb 00 00 00 00       	mov    $0x0,%ebx
  80050d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800510:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800513:	39 d3                	cmp    %edx,%ebx
  800515:	72 05                	jb     80051c <printnum+0x30>
  800517:	39 45 10             	cmp    %eax,0x10(%ebp)
  80051a:	77 45                	ja     800561 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80051c:	83 ec 0c             	sub    $0xc,%esp
  80051f:	ff 75 18             	pushl  0x18(%ebp)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800528:	53                   	push   %ebx
  800529:	ff 75 10             	pushl  0x10(%ebp)
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800532:	ff 75 e0             	pushl  -0x20(%ebp)
  800535:	ff 75 dc             	pushl  -0x24(%ebp)
  800538:	ff 75 d8             	pushl  -0x28(%ebp)
  80053b:	e8 20 1f 00 00       	call   802460 <__udivdi3>
  800540:	83 c4 18             	add    $0x18,%esp
  800543:	52                   	push   %edx
  800544:	50                   	push   %eax
  800545:	89 f2                	mov    %esi,%edx
  800547:	89 f8                	mov    %edi,%eax
  800549:	e8 9e ff ff ff       	call   8004ec <printnum>
  80054e:	83 c4 20             	add    $0x20,%esp
  800551:	eb 18                	jmp    80056b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	56                   	push   %esi
  800557:	ff 75 18             	pushl  0x18(%ebp)
  80055a:	ff d7                	call   *%edi
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	eb 03                	jmp    800564 <printnum+0x78>
  800561:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800564:	83 eb 01             	sub    $0x1,%ebx
  800567:	85 db                	test   %ebx,%ebx
  800569:	7f e8                	jg     800553 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	56                   	push   %esi
  80056f:	83 ec 04             	sub    $0x4,%esp
  800572:	ff 75 e4             	pushl  -0x1c(%ebp)
  800575:	ff 75 e0             	pushl  -0x20(%ebp)
  800578:	ff 75 dc             	pushl  -0x24(%ebp)
  80057b:	ff 75 d8             	pushl  -0x28(%ebp)
  80057e:	e8 0d 20 00 00       	call   802590 <__umoddi3>
  800583:	83 c4 14             	add    $0x14,%esp
  800586:	0f be 80 6f 28 80 00 	movsbl 0x80286f(%eax),%eax
  80058d:	50                   	push   %eax
  80058e:	ff d7                	call   *%edi
}
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800596:	5b                   	pop    %ebx
  800597:	5e                   	pop    %esi
  800598:	5f                   	pop    %edi
  800599:	5d                   	pop    %ebp
  80059a:	c3                   	ret    

0080059b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80059b:	55                   	push   %ebp
  80059c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80059e:	83 fa 01             	cmp    $0x1,%edx
  8005a1:	7e 0e                	jle    8005b1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005a3:	8b 10                	mov    (%eax),%edx
  8005a5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005a8:	89 08                	mov    %ecx,(%eax)
  8005aa:	8b 02                	mov    (%edx),%eax
  8005ac:	8b 52 04             	mov    0x4(%edx),%edx
  8005af:	eb 22                	jmp    8005d3 <getuint+0x38>
	else if (lflag)
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 10                	je     8005c5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ba:	89 08                	mov    %ecx,(%eax)
  8005bc:	8b 02                	mov    (%edx),%eax
  8005be:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c3:	eb 0e                	jmp    8005d3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ca:	89 08                	mov    %ecx,(%eax)
  8005cc:	8b 02                	mov    (%edx),%eax
  8005ce:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005d3:	5d                   	pop    %ebp
  8005d4:	c3                   	ret    

008005d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005db:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005df:	8b 10                	mov    (%eax),%edx
  8005e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8005e4:	73 0a                	jae    8005f0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005e9:	89 08                	mov    %ecx,(%eax)
  8005eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ee:	88 02                	mov    %al,(%edx)
}
  8005f0:	5d                   	pop    %ebp
  8005f1:	c3                   	ret    

008005f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005fb:	50                   	push   %eax
  8005fc:	ff 75 10             	pushl  0x10(%ebp)
  8005ff:	ff 75 0c             	pushl  0xc(%ebp)
  800602:	ff 75 08             	pushl  0x8(%ebp)
  800605:	e8 05 00 00 00       	call   80060f <vprintfmt>
	va_end(ap);
}
  80060a:	83 c4 10             	add    $0x10,%esp
  80060d:	c9                   	leave  
  80060e:	c3                   	ret    

0080060f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80060f:	55                   	push   %ebp
  800610:	89 e5                	mov    %esp,%ebp
  800612:	57                   	push   %edi
  800613:	56                   	push   %esi
  800614:	53                   	push   %ebx
  800615:	83 ec 2c             	sub    $0x2c,%esp
  800618:	8b 75 08             	mov    0x8(%ebp),%esi
  80061b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800621:	eb 12                	jmp    800635 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800623:	85 c0                	test   %eax,%eax
  800625:	0f 84 38 04 00 00    	je     800a63 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	50                   	push   %eax
  800630:	ff d6                	call   *%esi
  800632:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800635:	83 c7 01             	add    $0x1,%edi
  800638:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063c:	83 f8 25             	cmp    $0x25,%eax
  80063f:	75 e2                	jne    800623 <vprintfmt+0x14>
  800641:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800645:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80064c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800653:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80065a:	ba 00 00 00 00       	mov    $0x0,%edx
  80065f:	eb 07                	jmp    800668 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  800664:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800668:	8d 47 01             	lea    0x1(%edi),%eax
  80066b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80066e:	0f b6 07             	movzbl (%edi),%eax
  800671:	0f b6 c8             	movzbl %al,%ecx
  800674:	83 e8 23             	sub    $0x23,%eax
  800677:	3c 55                	cmp    $0x55,%al
  800679:	0f 87 c9 03 00 00    	ja     800a48 <vprintfmt+0x439>
  80067f:	0f b6 c0             	movzbl %al,%eax
  800682:	ff 24 85 c0 29 80 00 	jmp    *0x8029c0(,%eax,4)
  800689:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80068c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800690:	eb d6                	jmp    800668 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  800692:	c7 05 00 50 80 00 00 	movl   $0x0,0x805000
  800699:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  80069f:	eb 94                	jmp    800635 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  8006a1:	c7 05 00 50 80 00 01 	movl   $0x1,0x805000
  8006a8:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  8006ae:	eb 85                	jmp    800635 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  8006b0:	c7 05 00 50 80 00 02 	movl   $0x2,0x805000
  8006b7:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  8006bd:	e9 73 ff ff ff       	jmp    800635 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  8006c2:	c7 05 00 50 80 00 03 	movl   $0x3,0x805000
  8006c9:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  8006cf:	e9 61 ff ff ff       	jmp    800635 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  8006d4:	c7 05 00 50 80 00 04 	movl   $0x4,0x805000
  8006db:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  8006e1:	e9 4f ff ff ff       	jmp    800635 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  8006e6:	c7 05 00 50 80 00 05 	movl   $0x5,0x805000
  8006ed:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  8006f3:	e9 3d ff ff ff       	jmp    800635 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  8006f8:	c7 05 00 50 80 00 06 	movl   $0x6,0x805000
  8006ff:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800702:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  800705:	e9 2b ff ff ff       	jmp    800635 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  80070a:	c7 05 00 50 80 00 07 	movl   $0x7,0x805000
  800711:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800714:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  800717:	e9 19 ff ff ff       	jmp    800635 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  80071c:	c7 05 00 50 80 00 08 	movl   $0x8,0x805000
  800723:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  800729:	e9 07 ff ff ff       	jmp    800635 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  80072e:	c7 05 00 50 80 00 09 	movl   $0x9,0x805000
  800735:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800738:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  80073b:	e9 f5 fe ff ff       	jmp    800635 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800740:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800743:	b8 00 00 00 00       	mov    $0x0,%eax
  800748:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80074b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80074e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800752:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800755:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800758:	83 fa 09             	cmp    $0x9,%edx
  80075b:	77 3f                	ja     80079c <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80075d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800760:	eb e9                	jmp    80074b <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	8d 48 04             	lea    0x4(%eax),%ecx
  800768:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80076b:	8b 00                	mov    (%eax),%eax
  80076d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800770:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800773:	eb 2d                	jmp    8007a2 <vprintfmt+0x193>
  800775:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800778:	85 c0                	test   %eax,%eax
  80077a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80077f:	0f 49 c8             	cmovns %eax,%ecx
  800782:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800785:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800788:	e9 db fe ff ff       	jmp    800668 <vprintfmt+0x59>
  80078d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800790:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800797:	e9 cc fe ff ff       	jmp    800668 <vprintfmt+0x59>
  80079c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80079f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007a6:	0f 89 bc fe ff ff    	jns    800668 <vprintfmt+0x59>
				width = precision, precision = -1;
  8007ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007b2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007b9:	e9 aa fe ff ff       	jmp    800668 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007be:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007c4:	e9 9f fe ff ff       	jmp    800668 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cc:	8d 50 04             	lea    0x4(%eax),%edx
  8007cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	53                   	push   %ebx
  8007d6:	ff 30                	pushl  (%eax)
  8007d8:	ff d6                	call   *%esi
			break;
  8007da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007e0:	e9 50 fe ff ff       	jmp    800635 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e8:	8d 50 04             	lea    0x4(%eax),%edx
  8007eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ee:	8b 00                	mov    (%eax),%eax
  8007f0:	99                   	cltd   
  8007f1:	31 d0                	xor    %edx,%eax
  8007f3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007f5:	83 f8 0f             	cmp    $0xf,%eax
  8007f8:	7f 0b                	jg     800805 <vprintfmt+0x1f6>
  8007fa:	8b 14 85 20 2b 80 00 	mov    0x802b20(,%eax,4),%edx
  800801:	85 d2                	test   %edx,%edx
  800803:	75 18                	jne    80081d <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  800805:	50                   	push   %eax
  800806:	68 87 28 80 00       	push   $0x802887
  80080b:	53                   	push   %ebx
  80080c:	56                   	push   %esi
  80080d:	e8 e0 fd ff ff       	call   8005f2 <printfmt>
  800812:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800815:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800818:	e9 18 fe ff ff       	jmp    800635 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80081d:	52                   	push   %edx
  80081e:	68 51 2c 80 00       	push   $0x802c51
  800823:	53                   	push   %ebx
  800824:	56                   	push   %esi
  800825:	e8 c8 fd ff ff       	call   8005f2 <printfmt>
  80082a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800830:	e9 00 fe ff ff       	jmp    800635 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800835:	8b 45 14             	mov    0x14(%ebp),%eax
  800838:	8d 50 04             	lea    0x4(%eax),%edx
  80083b:	89 55 14             	mov    %edx,0x14(%ebp)
  80083e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800840:	85 ff                	test   %edi,%edi
  800842:	b8 80 28 80 00       	mov    $0x802880,%eax
  800847:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80084a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80084e:	0f 8e 94 00 00 00    	jle    8008e8 <vprintfmt+0x2d9>
  800854:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800858:	0f 84 98 00 00 00    	je     8008f6 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	ff 75 d0             	pushl  -0x30(%ebp)
  800864:	57                   	push   %edi
  800865:	e8 81 02 00 00       	call   800aeb <strnlen>
  80086a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80086d:	29 c1                	sub    %eax,%ecx
  80086f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800872:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800875:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800879:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80087c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80087f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800881:	eb 0f                	jmp    800892 <vprintfmt+0x283>
					putch(padc, putdat);
  800883:	83 ec 08             	sub    $0x8,%esp
  800886:	53                   	push   %ebx
  800887:	ff 75 e0             	pushl  -0x20(%ebp)
  80088a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80088c:	83 ef 01             	sub    $0x1,%edi
  80088f:	83 c4 10             	add    $0x10,%esp
  800892:	85 ff                	test   %edi,%edi
  800894:	7f ed                	jg     800883 <vprintfmt+0x274>
  800896:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800899:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80089c:	85 c9                	test   %ecx,%ecx
  80089e:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a3:	0f 49 c1             	cmovns %ecx,%eax
  8008a6:	29 c1                	sub    %eax,%ecx
  8008a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8008ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008b1:	89 cb                	mov    %ecx,%ebx
  8008b3:	eb 4d                	jmp    800902 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008b9:	74 1b                	je     8008d6 <vprintfmt+0x2c7>
  8008bb:	0f be c0             	movsbl %al,%eax
  8008be:	83 e8 20             	sub    $0x20,%eax
  8008c1:	83 f8 5e             	cmp    $0x5e,%eax
  8008c4:	76 10                	jbe    8008d6 <vprintfmt+0x2c7>
					putch('?', putdat);
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	ff 75 0c             	pushl  0xc(%ebp)
  8008cc:	6a 3f                	push   $0x3f
  8008ce:	ff 55 08             	call   *0x8(%ebp)
  8008d1:	83 c4 10             	add    $0x10,%esp
  8008d4:	eb 0d                	jmp    8008e3 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  8008d6:	83 ec 08             	sub    $0x8,%esp
  8008d9:	ff 75 0c             	pushl  0xc(%ebp)
  8008dc:	52                   	push   %edx
  8008dd:	ff 55 08             	call   *0x8(%ebp)
  8008e0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008e3:	83 eb 01             	sub    $0x1,%ebx
  8008e6:	eb 1a                	jmp    800902 <vprintfmt+0x2f3>
  8008e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8008eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8008f4:	eb 0c                	jmp    800902 <vprintfmt+0x2f3>
  8008f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8008f9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008ff:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800902:	83 c7 01             	add    $0x1,%edi
  800905:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800909:	0f be d0             	movsbl %al,%edx
  80090c:	85 d2                	test   %edx,%edx
  80090e:	74 23                	je     800933 <vprintfmt+0x324>
  800910:	85 f6                	test   %esi,%esi
  800912:	78 a1                	js     8008b5 <vprintfmt+0x2a6>
  800914:	83 ee 01             	sub    $0x1,%esi
  800917:	79 9c                	jns    8008b5 <vprintfmt+0x2a6>
  800919:	89 df                	mov    %ebx,%edi
  80091b:	8b 75 08             	mov    0x8(%ebp),%esi
  80091e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800921:	eb 18                	jmp    80093b <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800923:	83 ec 08             	sub    $0x8,%esp
  800926:	53                   	push   %ebx
  800927:	6a 20                	push   $0x20
  800929:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80092b:	83 ef 01             	sub    $0x1,%edi
  80092e:	83 c4 10             	add    $0x10,%esp
  800931:	eb 08                	jmp    80093b <vprintfmt+0x32c>
  800933:	89 df                	mov    %ebx,%edi
  800935:	8b 75 08             	mov    0x8(%ebp),%esi
  800938:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80093b:	85 ff                	test   %edi,%edi
  80093d:	7f e4                	jg     800923 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800942:	e9 ee fc ff ff       	jmp    800635 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800947:	83 fa 01             	cmp    $0x1,%edx
  80094a:	7e 16                	jle    800962 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  80094c:	8b 45 14             	mov    0x14(%ebp),%eax
  80094f:	8d 50 08             	lea    0x8(%eax),%edx
  800952:	89 55 14             	mov    %edx,0x14(%ebp)
  800955:	8b 50 04             	mov    0x4(%eax),%edx
  800958:	8b 00                	mov    (%eax),%eax
  80095a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80095d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800960:	eb 32                	jmp    800994 <vprintfmt+0x385>
	else if (lflag)
  800962:	85 d2                	test   %edx,%edx
  800964:	74 18                	je     80097e <vprintfmt+0x36f>
		return va_arg(*ap, long);
  800966:	8b 45 14             	mov    0x14(%ebp),%eax
  800969:	8d 50 04             	lea    0x4(%eax),%edx
  80096c:	89 55 14             	mov    %edx,0x14(%ebp)
  80096f:	8b 00                	mov    (%eax),%eax
  800971:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800974:	89 c1                	mov    %eax,%ecx
  800976:	c1 f9 1f             	sar    $0x1f,%ecx
  800979:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80097c:	eb 16                	jmp    800994 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  80097e:	8b 45 14             	mov    0x14(%ebp),%eax
  800981:	8d 50 04             	lea    0x4(%eax),%edx
  800984:	89 55 14             	mov    %edx,0x14(%ebp)
  800987:	8b 00                	mov    (%eax),%eax
  800989:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098c:	89 c1                	mov    %eax,%ecx
  80098e:	c1 f9 1f             	sar    $0x1f,%ecx
  800991:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800994:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800997:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80099a:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80099f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009a3:	79 6f                	jns    800a14 <vprintfmt+0x405>
				putch('-', putdat);
  8009a5:	83 ec 08             	sub    $0x8,%esp
  8009a8:	53                   	push   %ebx
  8009a9:	6a 2d                	push   $0x2d
  8009ab:	ff d6                	call   *%esi
				num = -(long long) num;
  8009ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009b3:	f7 d8                	neg    %eax
  8009b5:	83 d2 00             	adc    $0x0,%edx
  8009b8:	f7 da                	neg    %edx
  8009ba:	83 c4 10             	add    $0x10,%esp
  8009bd:	eb 55                	jmp    800a14 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c2:	e8 d4 fb ff ff       	call   80059b <getuint>
			base = 10;
  8009c7:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8009cc:	eb 46                	jmp    800a14 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8009d1:	e8 c5 fb ff ff       	call   80059b <getuint>
			base = 8;
  8009d6:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8009db:	eb 37                	jmp    800a14 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  8009dd:	83 ec 08             	sub    $0x8,%esp
  8009e0:	53                   	push   %ebx
  8009e1:	6a 30                	push   $0x30
  8009e3:	ff d6                	call   *%esi
			putch('x', putdat);
  8009e5:	83 c4 08             	add    $0x8,%esp
  8009e8:	53                   	push   %ebx
  8009e9:	6a 78                	push   $0x78
  8009eb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f0:	8d 50 04             	lea    0x4(%eax),%edx
  8009f3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009f6:	8b 00                	mov    (%eax),%eax
  8009f8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8009fd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a00:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800a05:	eb 0d                	jmp    800a14 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a07:	8d 45 14             	lea    0x14(%ebp),%eax
  800a0a:	e8 8c fb ff ff       	call   80059b <getuint>
			base = 16;
  800a0f:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a14:	83 ec 0c             	sub    $0xc,%esp
  800a17:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800a1b:	51                   	push   %ecx
  800a1c:	ff 75 e0             	pushl  -0x20(%ebp)
  800a1f:	57                   	push   %edi
  800a20:	52                   	push   %edx
  800a21:	50                   	push   %eax
  800a22:	89 da                	mov    %ebx,%edx
  800a24:	89 f0                	mov    %esi,%eax
  800a26:	e8 c1 fa ff ff       	call   8004ec <printnum>
			break;
  800a2b:	83 c4 20             	add    $0x20,%esp
  800a2e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a31:	e9 ff fb ff ff       	jmp    800635 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a36:	83 ec 08             	sub    $0x8,%esp
  800a39:	53                   	push   %ebx
  800a3a:	51                   	push   %ecx
  800a3b:	ff d6                	call   *%esi
			break;
  800a3d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a43:	e9 ed fb ff ff       	jmp    800635 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a48:	83 ec 08             	sub    $0x8,%esp
  800a4b:	53                   	push   %ebx
  800a4c:	6a 25                	push   $0x25
  800a4e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a50:	83 c4 10             	add    $0x10,%esp
  800a53:	eb 03                	jmp    800a58 <vprintfmt+0x449>
  800a55:	83 ef 01             	sub    $0x1,%edi
  800a58:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a5c:	75 f7                	jne    800a55 <vprintfmt+0x446>
  800a5e:	e9 d2 fb ff ff       	jmp    800635 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a66:	5b                   	pop    %ebx
  800a67:	5e                   	pop    %esi
  800a68:	5f                   	pop    %edi
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	83 ec 18             	sub    $0x18,%esp
  800a71:	8b 45 08             	mov    0x8(%ebp),%eax
  800a74:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a77:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a7a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a7e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a81:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a88:	85 c0                	test   %eax,%eax
  800a8a:	74 26                	je     800ab2 <vsnprintf+0x47>
  800a8c:	85 d2                	test   %edx,%edx
  800a8e:	7e 22                	jle    800ab2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a90:	ff 75 14             	pushl  0x14(%ebp)
  800a93:	ff 75 10             	pushl  0x10(%ebp)
  800a96:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a99:	50                   	push   %eax
  800a9a:	68 d5 05 80 00       	push   $0x8005d5
  800a9f:	e8 6b fb ff ff       	call   80060f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800aa4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800aa7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aad:	83 c4 10             	add    $0x10,%esp
  800ab0:	eb 05                	jmp    800ab7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ab2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ab7:	c9                   	leave  
  800ab8:	c3                   	ret    

00800ab9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800abf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ac2:	50                   	push   %eax
  800ac3:	ff 75 10             	pushl  0x10(%ebp)
  800ac6:	ff 75 0c             	pushl  0xc(%ebp)
  800ac9:	ff 75 08             	pushl  0x8(%ebp)
  800acc:	e8 9a ff ff ff       	call   800a6b <vsnprintf>
	va_end(ap);

	return rc;
}
  800ad1:	c9                   	leave  
  800ad2:	c3                   	ret    

00800ad3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ade:	eb 03                	jmp    800ae3 <strlen+0x10>
		n++;
  800ae0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ae3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ae7:	75 f7                	jne    800ae0 <strlen+0xd>
		n++;
	return n;
}
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800af4:	ba 00 00 00 00       	mov    $0x0,%edx
  800af9:	eb 03                	jmp    800afe <strnlen+0x13>
		n++;
  800afb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800afe:	39 c2                	cmp    %eax,%edx
  800b00:	74 08                	je     800b0a <strnlen+0x1f>
  800b02:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b06:	75 f3                	jne    800afb <strnlen+0x10>
  800b08:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	53                   	push   %ebx
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b16:	89 c2                	mov    %eax,%edx
  800b18:	83 c2 01             	add    $0x1,%edx
  800b1b:	83 c1 01             	add    $0x1,%ecx
  800b1e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b22:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b25:	84 db                	test   %bl,%bl
  800b27:	75 ef                	jne    800b18 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b29:	5b                   	pop    %ebx
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	53                   	push   %ebx
  800b30:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b33:	53                   	push   %ebx
  800b34:	e8 9a ff ff ff       	call   800ad3 <strlen>
  800b39:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b3c:	ff 75 0c             	pushl  0xc(%ebp)
  800b3f:	01 d8                	add    %ebx,%eax
  800b41:	50                   	push   %eax
  800b42:	e8 c5 ff ff ff       	call   800b0c <strcpy>
	return dst;
}
  800b47:	89 d8                	mov    %ebx,%eax
  800b49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b4c:	c9                   	leave  
  800b4d:	c3                   	ret    

00800b4e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
  800b53:	8b 75 08             	mov    0x8(%ebp),%esi
  800b56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b59:	89 f3                	mov    %esi,%ebx
  800b5b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b5e:	89 f2                	mov    %esi,%edx
  800b60:	eb 0f                	jmp    800b71 <strncpy+0x23>
		*dst++ = *src;
  800b62:	83 c2 01             	add    $0x1,%edx
  800b65:	0f b6 01             	movzbl (%ecx),%eax
  800b68:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b6b:	80 39 01             	cmpb   $0x1,(%ecx)
  800b6e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b71:	39 da                	cmp    %ebx,%edx
  800b73:	75 ed                	jne    800b62 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b75:	89 f0                	mov    %esi,%eax
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
  800b80:	8b 75 08             	mov    0x8(%ebp),%esi
  800b83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b86:	8b 55 10             	mov    0x10(%ebp),%edx
  800b89:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b8b:	85 d2                	test   %edx,%edx
  800b8d:	74 21                	je     800bb0 <strlcpy+0x35>
  800b8f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b93:	89 f2                	mov    %esi,%edx
  800b95:	eb 09                	jmp    800ba0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b97:	83 c2 01             	add    $0x1,%edx
  800b9a:	83 c1 01             	add    $0x1,%ecx
  800b9d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ba0:	39 c2                	cmp    %eax,%edx
  800ba2:	74 09                	je     800bad <strlcpy+0x32>
  800ba4:	0f b6 19             	movzbl (%ecx),%ebx
  800ba7:	84 db                	test   %bl,%bl
  800ba9:	75 ec                	jne    800b97 <strlcpy+0x1c>
  800bab:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bad:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bb0:	29 f0                	sub    %esi,%eax
}
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bbc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bbf:	eb 06                	jmp    800bc7 <strcmp+0x11>
		p++, q++;
  800bc1:	83 c1 01             	add    $0x1,%ecx
  800bc4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bc7:	0f b6 01             	movzbl (%ecx),%eax
  800bca:	84 c0                	test   %al,%al
  800bcc:	74 04                	je     800bd2 <strcmp+0x1c>
  800bce:	3a 02                	cmp    (%edx),%al
  800bd0:	74 ef                	je     800bc1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bd2:	0f b6 c0             	movzbl %al,%eax
  800bd5:	0f b6 12             	movzbl (%edx),%edx
  800bd8:	29 d0                	sub    %edx,%eax
}
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	53                   	push   %ebx
  800be0:	8b 45 08             	mov    0x8(%ebp),%eax
  800be3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be6:	89 c3                	mov    %eax,%ebx
  800be8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800beb:	eb 06                	jmp    800bf3 <strncmp+0x17>
		n--, p++, q++;
  800bed:	83 c0 01             	add    $0x1,%eax
  800bf0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bf3:	39 d8                	cmp    %ebx,%eax
  800bf5:	74 15                	je     800c0c <strncmp+0x30>
  800bf7:	0f b6 08             	movzbl (%eax),%ecx
  800bfa:	84 c9                	test   %cl,%cl
  800bfc:	74 04                	je     800c02 <strncmp+0x26>
  800bfe:	3a 0a                	cmp    (%edx),%cl
  800c00:	74 eb                	je     800bed <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c02:	0f b6 00             	movzbl (%eax),%eax
  800c05:	0f b6 12             	movzbl (%edx),%edx
  800c08:	29 d0                	sub    %edx,%eax
  800c0a:	eb 05                	jmp    800c11 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c0c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c11:	5b                   	pop    %ebx
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c1e:	eb 07                	jmp    800c27 <strchr+0x13>
		if (*s == c)
  800c20:	38 ca                	cmp    %cl,%dl
  800c22:	74 0f                	je     800c33 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c24:	83 c0 01             	add    $0x1,%eax
  800c27:	0f b6 10             	movzbl (%eax),%edx
  800c2a:	84 d2                	test   %dl,%dl
  800c2c:	75 f2                	jne    800c20 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c3f:	eb 03                	jmp    800c44 <strfind+0xf>
  800c41:	83 c0 01             	add    $0x1,%eax
  800c44:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c47:	38 ca                	cmp    %cl,%dl
  800c49:	74 04                	je     800c4f <strfind+0x1a>
  800c4b:	84 d2                	test   %dl,%dl
  800c4d:	75 f2                	jne    800c41 <strfind+0xc>
			break;
	return (char *) s;
}
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c5d:	85 c9                	test   %ecx,%ecx
  800c5f:	74 36                	je     800c97 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c61:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c67:	75 28                	jne    800c91 <memset+0x40>
  800c69:	f6 c1 03             	test   $0x3,%cl
  800c6c:	75 23                	jne    800c91 <memset+0x40>
		c &= 0xFF;
  800c6e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c72:	89 d3                	mov    %edx,%ebx
  800c74:	c1 e3 08             	shl    $0x8,%ebx
  800c77:	89 d6                	mov    %edx,%esi
  800c79:	c1 e6 18             	shl    $0x18,%esi
  800c7c:	89 d0                	mov    %edx,%eax
  800c7e:	c1 e0 10             	shl    $0x10,%eax
  800c81:	09 f0                	or     %esi,%eax
  800c83:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c85:	89 d8                	mov    %ebx,%eax
  800c87:	09 d0                	or     %edx,%eax
  800c89:	c1 e9 02             	shr    $0x2,%ecx
  800c8c:	fc                   	cld    
  800c8d:	f3 ab                	rep stos %eax,%es:(%edi)
  800c8f:	eb 06                	jmp    800c97 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c91:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c94:	fc                   	cld    
  800c95:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c97:	89 f8                	mov    %edi,%eax
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cac:	39 c6                	cmp    %eax,%esi
  800cae:	73 35                	jae    800ce5 <memmove+0x47>
  800cb0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cb3:	39 d0                	cmp    %edx,%eax
  800cb5:	73 2e                	jae    800ce5 <memmove+0x47>
		s += n;
		d += n;
  800cb7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cba:	89 d6                	mov    %edx,%esi
  800cbc:	09 fe                	or     %edi,%esi
  800cbe:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cc4:	75 13                	jne    800cd9 <memmove+0x3b>
  800cc6:	f6 c1 03             	test   $0x3,%cl
  800cc9:	75 0e                	jne    800cd9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ccb:	83 ef 04             	sub    $0x4,%edi
  800cce:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cd1:	c1 e9 02             	shr    $0x2,%ecx
  800cd4:	fd                   	std    
  800cd5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cd7:	eb 09                	jmp    800ce2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cd9:	83 ef 01             	sub    $0x1,%edi
  800cdc:	8d 72 ff             	lea    -0x1(%edx),%esi
  800cdf:	fd                   	std    
  800ce0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ce2:	fc                   	cld    
  800ce3:	eb 1d                	jmp    800d02 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ce5:	89 f2                	mov    %esi,%edx
  800ce7:	09 c2                	or     %eax,%edx
  800ce9:	f6 c2 03             	test   $0x3,%dl
  800cec:	75 0f                	jne    800cfd <memmove+0x5f>
  800cee:	f6 c1 03             	test   $0x3,%cl
  800cf1:	75 0a                	jne    800cfd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800cf3:	c1 e9 02             	shr    $0x2,%ecx
  800cf6:	89 c7                	mov    %eax,%edi
  800cf8:	fc                   	cld    
  800cf9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cfb:	eb 05                	jmp    800d02 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cfd:	89 c7                	mov    %eax,%edi
  800cff:	fc                   	cld    
  800d00:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d09:	ff 75 10             	pushl  0x10(%ebp)
  800d0c:	ff 75 0c             	pushl  0xc(%ebp)
  800d0f:	ff 75 08             	pushl  0x8(%ebp)
  800d12:	e8 87 ff ff ff       	call   800c9e <memmove>
}
  800d17:	c9                   	leave  
  800d18:	c3                   	ret    

00800d19 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d24:	89 c6                	mov    %eax,%esi
  800d26:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d29:	eb 1a                	jmp    800d45 <memcmp+0x2c>
		if (*s1 != *s2)
  800d2b:	0f b6 08             	movzbl (%eax),%ecx
  800d2e:	0f b6 1a             	movzbl (%edx),%ebx
  800d31:	38 d9                	cmp    %bl,%cl
  800d33:	74 0a                	je     800d3f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d35:	0f b6 c1             	movzbl %cl,%eax
  800d38:	0f b6 db             	movzbl %bl,%ebx
  800d3b:	29 d8                	sub    %ebx,%eax
  800d3d:	eb 0f                	jmp    800d4e <memcmp+0x35>
		s1++, s2++;
  800d3f:	83 c0 01             	add    $0x1,%eax
  800d42:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d45:	39 f0                	cmp    %esi,%eax
  800d47:	75 e2                	jne    800d2b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	53                   	push   %ebx
  800d56:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d59:	89 c1                	mov    %eax,%ecx
  800d5b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d5e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d62:	eb 0a                	jmp    800d6e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d64:	0f b6 10             	movzbl (%eax),%edx
  800d67:	39 da                	cmp    %ebx,%edx
  800d69:	74 07                	je     800d72 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d6b:	83 c0 01             	add    $0x1,%eax
  800d6e:	39 c8                	cmp    %ecx,%eax
  800d70:	72 f2                	jb     800d64 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d72:	5b                   	pop    %ebx
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	57                   	push   %edi
  800d79:	56                   	push   %esi
  800d7a:	53                   	push   %ebx
  800d7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d81:	eb 03                	jmp    800d86 <strtol+0x11>
		s++;
  800d83:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d86:	0f b6 01             	movzbl (%ecx),%eax
  800d89:	3c 20                	cmp    $0x20,%al
  800d8b:	74 f6                	je     800d83 <strtol+0xe>
  800d8d:	3c 09                	cmp    $0x9,%al
  800d8f:	74 f2                	je     800d83 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d91:	3c 2b                	cmp    $0x2b,%al
  800d93:	75 0a                	jne    800d9f <strtol+0x2a>
		s++;
  800d95:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d98:	bf 00 00 00 00       	mov    $0x0,%edi
  800d9d:	eb 11                	jmp    800db0 <strtol+0x3b>
  800d9f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800da4:	3c 2d                	cmp    $0x2d,%al
  800da6:	75 08                	jne    800db0 <strtol+0x3b>
		s++, neg = 1;
  800da8:	83 c1 01             	add    $0x1,%ecx
  800dab:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800db0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800db6:	75 15                	jne    800dcd <strtol+0x58>
  800db8:	80 39 30             	cmpb   $0x30,(%ecx)
  800dbb:	75 10                	jne    800dcd <strtol+0x58>
  800dbd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800dc1:	75 7c                	jne    800e3f <strtol+0xca>
		s += 2, base = 16;
  800dc3:	83 c1 02             	add    $0x2,%ecx
  800dc6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dcb:	eb 16                	jmp    800de3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800dcd:	85 db                	test   %ebx,%ebx
  800dcf:	75 12                	jne    800de3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dd1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dd6:	80 39 30             	cmpb   $0x30,(%ecx)
  800dd9:	75 08                	jne    800de3 <strtol+0x6e>
		s++, base = 8;
  800ddb:	83 c1 01             	add    $0x1,%ecx
  800dde:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800de3:	b8 00 00 00 00       	mov    $0x0,%eax
  800de8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800deb:	0f b6 11             	movzbl (%ecx),%edx
  800dee:	8d 72 d0             	lea    -0x30(%edx),%esi
  800df1:	89 f3                	mov    %esi,%ebx
  800df3:	80 fb 09             	cmp    $0x9,%bl
  800df6:	77 08                	ja     800e00 <strtol+0x8b>
			dig = *s - '0';
  800df8:	0f be d2             	movsbl %dl,%edx
  800dfb:	83 ea 30             	sub    $0x30,%edx
  800dfe:	eb 22                	jmp    800e22 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e00:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e03:	89 f3                	mov    %esi,%ebx
  800e05:	80 fb 19             	cmp    $0x19,%bl
  800e08:	77 08                	ja     800e12 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e0a:	0f be d2             	movsbl %dl,%edx
  800e0d:	83 ea 57             	sub    $0x57,%edx
  800e10:	eb 10                	jmp    800e22 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e12:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e15:	89 f3                	mov    %esi,%ebx
  800e17:	80 fb 19             	cmp    $0x19,%bl
  800e1a:	77 16                	ja     800e32 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e1c:	0f be d2             	movsbl %dl,%edx
  800e1f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e22:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e25:	7d 0b                	jge    800e32 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e27:	83 c1 01             	add    $0x1,%ecx
  800e2a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e2e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e30:	eb b9                	jmp    800deb <strtol+0x76>

	if (endptr)
  800e32:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e36:	74 0d                	je     800e45 <strtol+0xd0>
		*endptr = (char *) s;
  800e38:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e3b:	89 0e                	mov    %ecx,(%esi)
  800e3d:	eb 06                	jmp    800e45 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e3f:	85 db                	test   %ebx,%ebx
  800e41:	74 98                	je     800ddb <strtol+0x66>
  800e43:	eb 9e                	jmp    800de3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e45:	89 c2                	mov    %eax,%edx
  800e47:	f7 da                	neg    %edx
  800e49:	85 ff                	test   %edi,%edi
  800e4b:	0f 45 c2             	cmovne %edx,%eax
}
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	57                   	push   %edi
  800e57:	56                   	push   %esi
  800e58:	53                   	push   %ebx
  800e59:	83 ec 04             	sub    $0x4,%esp
  800e5c:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800e5f:	57                   	push   %edi
  800e60:	e8 6e fc ff ff       	call   800ad3 <strlen>
  800e65:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800e68:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800e6b:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800e70:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800e75:	eb 46                	jmp    800ebd <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800e77:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800e7b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800e7e:	80 f9 09             	cmp    $0x9,%cl
  800e81:	77 08                	ja     800e8b <charhex_to_dec+0x38>
			num = s[i] - '0';
  800e83:	0f be d2             	movsbl %dl,%edx
  800e86:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800e89:	eb 27                	jmp    800eb2 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800e8b:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800e8e:	80 f9 05             	cmp    $0x5,%cl
  800e91:	77 08                	ja     800e9b <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800e93:	0f be d2             	movsbl %dl,%edx
  800e96:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800e99:	eb 17                	jmp    800eb2 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800e9b:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800e9e:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800ea1:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800ea6:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800eaa:	77 06                	ja     800eb2 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800eac:	0f be d2             	movsbl %dl,%edx
  800eaf:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800eb2:	0f af ce             	imul   %esi,%ecx
  800eb5:	01 c8                	add    %ecx,%eax
		base *= 16;
  800eb7:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800eba:	83 eb 01             	sub    $0x1,%ebx
  800ebd:	83 fb 01             	cmp    $0x1,%ebx
  800ec0:	7f b5                	jg     800e77 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800ec2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	57                   	push   %edi
  800ece:	56                   	push   %esi
  800ecf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed8:	8b 55 08             	mov    0x8(%ebp),%edx
  800edb:	89 c3                	mov    %eax,%ebx
  800edd:	89 c7                	mov    %eax,%edi
  800edf:	89 c6                	mov    %eax,%esi
  800ee1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ee3:	5b                   	pop    %ebx
  800ee4:	5e                   	pop    %esi
  800ee5:	5f                   	pop    %edi
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	57                   	push   %edi
  800eec:	56                   	push   %esi
  800eed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eee:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef8:	89 d1                	mov    %edx,%ecx
  800efa:	89 d3                	mov    %edx,%ebx
  800efc:	89 d7                	mov    %edx,%edi
  800efe:	89 d6                	mov    %edx,%esi
  800f00:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	57                   	push   %edi
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
  800f0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f10:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f15:	b8 03 00 00 00       	mov    $0x3,%eax
  800f1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1d:	89 cb                	mov    %ecx,%ebx
  800f1f:	89 cf                	mov    %ecx,%edi
  800f21:	89 ce                	mov    %ecx,%esi
  800f23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f25:	85 c0                	test   %eax,%eax
  800f27:	7e 17                	jle    800f40 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f29:	83 ec 0c             	sub    $0xc,%esp
  800f2c:	50                   	push   %eax
  800f2d:	6a 03                	push   $0x3
  800f2f:	68 7f 2b 80 00       	push   $0x802b7f
  800f34:	6a 23                	push   $0x23
  800f36:	68 9c 2b 80 00       	push   $0x802b9c
  800f3b:	e8 bf f4 ff ff       	call   8003ff <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f43:	5b                   	pop    %ebx
  800f44:	5e                   	pop    %esi
  800f45:	5f                   	pop    %edi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    

00800f48 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	57                   	push   %edi
  800f4c:	56                   	push   %esi
  800f4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f53:	b8 02 00 00 00       	mov    $0x2,%eax
  800f58:	89 d1                	mov    %edx,%ecx
  800f5a:	89 d3                	mov    %edx,%ebx
  800f5c:	89 d7                	mov    %edx,%edi
  800f5e:	89 d6                	mov    %edx,%esi
  800f60:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f62:	5b                   	pop    %ebx
  800f63:	5e                   	pop    %esi
  800f64:	5f                   	pop    %edi
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <sys_yield>:

void
sys_yield(void)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	57                   	push   %edi
  800f6b:	56                   	push   %esi
  800f6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f72:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f77:	89 d1                	mov    %edx,%ecx
  800f79:	89 d3                	mov    %edx,%ebx
  800f7b:	89 d7                	mov    %edx,%edi
  800f7d:	89 d6                	mov    %edx,%esi
  800f7f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5f                   	pop    %edi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	57                   	push   %edi
  800f8a:	56                   	push   %esi
  800f8b:	53                   	push   %ebx
  800f8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8f:	be 00 00 00 00       	mov    $0x0,%esi
  800f94:	b8 04 00 00 00       	mov    $0x4,%eax
  800f99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa2:	89 f7                	mov    %esi,%edi
  800fa4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	7e 17                	jle    800fc1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800faa:	83 ec 0c             	sub    $0xc,%esp
  800fad:	50                   	push   %eax
  800fae:	6a 04                	push   $0x4
  800fb0:	68 7f 2b 80 00       	push   $0x802b7f
  800fb5:	6a 23                	push   $0x23
  800fb7:	68 9c 2b 80 00       	push   $0x802b9c
  800fbc:	e8 3e f4 ff ff       	call   8003ff <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc4:	5b                   	pop    %ebx
  800fc5:	5e                   	pop    %esi
  800fc6:	5f                   	pop    %edi
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    

00800fc9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	57                   	push   %edi
  800fcd:	56                   	push   %esi
  800fce:	53                   	push   %ebx
  800fcf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd2:	b8 05 00 00 00       	mov    $0x5,%eax
  800fd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fda:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fe0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fe3:	8b 75 18             	mov    0x18(%ebp),%esi
  800fe6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	7e 17                	jle    801003 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fec:	83 ec 0c             	sub    $0xc,%esp
  800fef:	50                   	push   %eax
  800ff0:	6a 05                	push   $0x5
  800ff2:	68 7f 2b 80 00       	push   $0x802b7f
  800ff7:	6a 23                	push   $0x23
  800ff9:	68 9c 2b 80 00       	push   $0x802b9c
  800ffe:	e8 fc f3 ff ff       	call   8003ff <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801003:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801006:	5b                   	pop    %ebx
  801007:	5e                   	pop    %esi
  801008:	5f                   	pop    %edi
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	57                   	push   %edi
  80100f:	56                   	push   %esi
  801010:	53                   	push   %ebx
  801011:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801014:	bb 00 00 00 00       	mov    $0x0,%ebx
  801019:	b8 06 00 00 00       	mov    $0x6,%eax
  80101e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801021:	8b 55 08             	mov    0x8(%ebp),%edx
  801024:	89 df                	mov    %ebx,%edi
  801026:	89 de                	mov    %ebx,%esi
  801028:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80102a:	85 c0                	test   %eax,%eax
  80102c:	7e 17                	jle    801045 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102e:	83 ec 0c             	sub    $0xc,%esp
  801031:	50                   	push   %eax
  801032:	6a 06                	push   $0x6
  801034:	68 7f 2b 80 00       	push   $0x802b7f
  801039:	6a 23                	push   $0x23
  80103b:	68 9c 2b 80 00       	push   $0x802b9c
  801040:	e8 ba f3 ff ff       	call   8003ff <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801045:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801048:	5b                   	pop    %ebx
  801049:	5e                   	pop    %esi
  80104a:	5f                   	pop    %edi
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    

0080104d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	57                   	push   %edi
  801051:	56                   	push   %esi
  801052:	53                   	push   %ebx
  801053:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801056:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105b:	b8 08 00 00 00       	mov    $0x8,%eax
  801060:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801063:	8b 55 08             	mov    0x8(%ebp),%edx
  801066:	89 df                	mov    %ebx,%edi
  801068:	89 de                	mov    %ebx,%esi
  80106a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80106c:	85 c0                	test   %eax,%eax
  80106e:	7e 17                	jle    801087 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801070:	83 ec 0c             	sub    $0xc,%esp
  801073:	50                   	push   %eax
  801074:	6a 08                	push   $0x8
  801076:	68 7f 2b 80 00       	push   $0x802b7f
  80107b:	6a 23                	push   $0x23
  80107d:	68 9c 2b 80 00       	push   $0x802b9c
  801082:	e8 78 f3 ff ff       	call   8003ff <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801087:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108a:	5b                   	pop    %ebx
  80108b:	5e                   	pop    %esi
  80108c:	5f                   	pop    %edi
  80108d:	5d                   	pop    %ebp
  80108e:	c3                   	ret    

0080108f <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	57                   	push   %edi
  801093:	56                   	push   %esi
  801094:	53                   	push   %ebx
  801095:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801098:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109d:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a8:	89 df                	mov    %ebx,%edi
  8010aa:	89 de                	mov    %ebx,%esi
  8010ac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	7e 17                	jle    8010c9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b2:	83 ec 0c             	sub    $0xc,%esp
  8010b5:	50                   	push   %eax
  8010b6:	6a 0a                	push   $0xa
  8010b8:	68 7f 2b 80 00       	push   $0x802b7f
  8010bd:	6a 23                	push   $0x23
  8010bf:	68 9c 2b 80 00       	push   $0x802b9c
  8010c4:	e8 36 f3 ff ff       	call   8003ff <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cc:	5b                   	pop    %ebx
  8010cd:	5e                   	pop    %esi
  8010ce:	5f                   	pop    %edi
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	57                   	push   %edi
  8010d5:	56                   	push   %esi
  8010d6:	53                   	push   %ebx
  8010d7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010df:	b8 09 00 00 00       	mov    $0x9,%eax
  8010e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ea:	89 df                	mov    %ebx,%edi
  8010ec:	89 de                	mov    %ebx,%esi
  8010ee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010f0:	85 c0                	test   %eax,%eax
  8010f2:	7e 17                	jle    80110b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f4:	83 ec 0c             	sub    $0xc,%esp
  8010f7:	50                   	push   %eax
  8010f8:	6a 09                	push   $0x9
  8010fa:	68 7f 2b 80 00       	push   $0x802b7f
  8010ff:	6a 23                	push   $0x23
  801101:	68 9c 2b 80 00       	push   $0x802b9c
  801106:	e8 f4 f2 ff ff       	call   8003ff <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80110b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110e:	5b                   	pop    %ebx
  80110f:	5e                   	pop    %esi
  801110:	5f                   	pop    %edi
  801111:	5d                   	pop    %ebp
  801112:	c3                   	ret    

00801113 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
  801116:	57                   	push   %edi
  801117:	56                   	push   %esi
  801118:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801119:	be 00 00 00 00       	mov    $0x0,%esi
  80111e:	b8 0c 00 00 00       	mov    $0xc,%eax
  801123:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801126:	8b 55 08             	mov    0x8(%ebp),%edx
  801129:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80112c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80112f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	57                   	push   %edi
  80113a:	56                   	push   %esi
  80113b:	53                   	push   %ebx
  80113c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801144:	b8 0d 00 00 00       	mov    $0xd,%eax
  801149:	8b 55 08             	mov    0x8(%ebp),%edx
  80114c:	89 cb                	mov    %ecx,%ebx
  80114e:	89 cf                	mov    %ecx,%edi
  801150:	89 ce                	mov    %ecx,%esi
  801152:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801154:	85 c0                	test   %eax,%eax
  801156:	7e 17                	jle    80116f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801158:	83 ec 0c             	sub    $0xc,%esp
  80115b:	50                   	push   %eax
  80115c:	6a 0d                	push   $0xd
  80115e:	68 7f 2b 80 00       	push   $0x802b7f
  801163:	6a 23                	push   $0x23
  801165:	68 9c 2b 80 00       	push   $0x802b9c
  80116a:	e8 90 f2 ff ff       	call   8003ff <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80116f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801172:	5b                   	pop    %ebx
  801173:	5e                   	pop    %esi
  801174:	5f                   	pop    %edi
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80117a:	8b 45 08             	mov    0x8(%ebp),%eax
  80117d:	05 00 00 00 30       	add    $0x30000000,%eax
  801182:	c1 e8 0c             	shr    $0xc,%eax
}
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80118a:	8b 45 08             	mov    0x8(%ebp),%eax
  80118d:	05 00 00 00 30       	add    $0x30000000,%eax
  801192:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801197:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011a9:	89 c2                	mov    %eax,%edx
  8011ab:	c1 ea 16             	shr    $0x16,%edx
  8011ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b5:	f6 c2 01             	test   $0x1,%dl
  8011b8:	74 11                	je     8011cb <fd_alloc+0x2d>
  8011ba:	89 c2                	mov    %eax,%edx
  8011bc:	c1 ea 0c             	shr    $0xc,%edx
  8011bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c6:	f6 c2 01             	test   $0x1,%dl
  8011c9:	75 09                	jne    8011d4 <fd_alloc+0x36>
			*fd_store = fd;
  8011cb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d2:	eb 17                	jmp    8011eb <fd_alloc+0x4d>
  8011d4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011d9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011de:	75 c9                	jne    8011a9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011e6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f3:	83 f8 1f             	cmp    $0x1f,%eax
  8011f6:	77 36                	ja     80122e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011f8:	c1 e0 0c             	shl    $0xc,%eax
  8011fb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801200:	89 c2                	mov    %eax,%edx
  801202:	c1 ea 16             	shr    $0x16,%edx
  801205:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80120c:	f6 c2 01             	test   $0x1,%dl
  80120f:	74 24                	je     801235 <fd_lookup+0x48>
  801211:	89 c2                	mov    %eax,%edx
  801213:	c1 ea 0c             	shr    $0xc,%edx
  801216:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121d:	f6 c2 01             	test   $0x1,%dl
  801220:	74 1a                	je     80123c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801222:	8b 55 0c             	mov    0xc(%ebp),%edx
  801225:	89 02                	mov    %eax,(%edx)
	return 0;
  801227:	b8 00 00 00 00       	mov    $0x0,%eax
  80122c:	eb 13                	jmp    801241 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80122e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801233:	eb 0c                	jmp    801241 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801235:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123a:	eb 05                	jmp    801241 <fd_lookup+0x54>
  80123c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    

00801243 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	83 ec 08             	sub    $0x8,%esp
  801249:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124c:	ba 28 2c 80 00       	mov    $0x802c28,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801251:	eb 13                	jmp    801266 <dev_lookup+0x23>
  801253:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801256:	39 08                	cmp    %ecx,(%eax)
  801258:	75 0c                	jne    801266 <dev_lookup+0x23>
			*dev = devtab[i];
  80125a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80125d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80125f:	b8 00 00 00 00       	mov    $0x0,%eax
  801264:	eb 2e                	jmp    801294 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801266:	8b 02                	mov    (%edx),%eax
  801268:	85 c0                	test   %eax,%eax
  80126a:	75 e7                	jne    801253 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80126c:	a1 90 67 80 00       	mov    0x806790,%eax
  801271:	8b 40 48             	mov    0x48(%eax),%eax
  801274:	83 ec 04             	sub    $0x4,%esp
  801277:	51                   	push   %ecx
  801278:	50                   	push   %eax
  801279:	68 ac 2b 80 00       	push   $0x802bac
  80127e:	e8 55 f2 ff ff       	call   8004d8 <cprintf>
	*dev = 0;
  801283:	8b 45 0c             	mov    0xc(%ebp),%eax
  801286:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801294:	c9                   	leave  
  801295:	c3                   	ret    

00801296 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	56                   	push   %esi
  80129a:	53                   	push   %ebx
  80129b:	83 ec 10             	sub    $0x10,%esp
  80129e:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012ae:	c1 e8 0c             	shr    $0xc,%eax
  8012b1:	50                   	push   %eax
  8012b2:	e8 36 ff ff ff       	call   8011ed <fd_lookup>
  8012b7:	83 c4 08             	add    $0x8,%esp
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	78 05                	js     8012c3 <fd_close+0x2d>
	    || fd != fd2) 
  8012be:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012c1:	74 0c                	je     8012cf <fd_close+0x39>
		return (must_exist ? r : 0); 
  8012c3:	84 db                	test   %bl,%bl
  8012c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ca:	0f 44 c2             	cmove  %edx,%eax
  8012cd:	eb 41                	jmp    801310 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012cf:	83 ec 08             	sub    $0x8,%esp
  8012d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d5:	50                   	push   %eax
  8012d6:	ff 36                	pushl  (%esi)
  8012d8:	e8 66 ff ff ff       	call   801243 <dev_lookup>
  8012dd:	89 c3                	mov    %eax,%ebx
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 1a                	js     801300 <fd_close+0x6a>
		if (dev->dev_close) 
  8012e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8012ec:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	74 0b                	je     801300 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012f5:	83 ec 0c             	sub    $0xc,%esp
  8012f8:	56                   	push   %esi
  8012f9:	ff d0                	call   *%eax
  8012fb:	89 c3                	mov    %eax,%ebx
  8012fd:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801300:	83 ec 08             	sub    $0x8,%esp
  801303:	56                   	push   %esi
  801304:	6a 00                	push   $0x0
  801306:	e8 00 fd ff ff       	call   80100b <sys_page_unmap>
	return r;
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	89 d8                	mov    %ebx,%eax
}
  801310:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801313:	5b                   	pop    %ebx
  801314:	5e                   	pop    %esi
  801315:	5d                   	pop    %ebp
  801316:	c3                   	ret    

00801317 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80131d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801320:	50                   	push   %eax
  801321:	ff 75 08             	pushl  0x8(%ebp)
  801324:	e8 c4 fe ff ff       	call   8011ed <fd_lookup>
  801329:	83 c4 08             	add    $0x8,%esp
  80132c:	85 c0                	test   %eax,%eax
  80132e:	78 10                	js     801340 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  801330:	83 ec 08             	sub    $0x8,%esp
  801333:	6a 01                	push   $0x1
  801335:	ff 75 f4             	pushl  -0xc(%ebp)
  801338:	e8 59 ff ff ff       	call   801296 <fd_close>
  80133d:	83 c4 10             	add    $0x10,%esp
}
  801340:	c9                   	leave  
  801341:	c3                   	ret    

00801342 <close_all>:

void
close_all(void)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	53                   	push   %ebx
  801346:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801349:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80134e:	83 ec 0c             	sub    $0xc,%esp
  801351:	53                   	push   %ebx
  801352:	e8 c0 ff ff ff       	call   801317 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801357:	83 c3 01             	add    $0x1,%ebx
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	83 fb 20             	cmp    $0x20,%ebx
  801360:	75 ec                	jne    80134e <close_all+0xc>
		close(i);
}
  801362:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801365:	c9                   	leave  
  801366:	c3                   	ret    

00801367 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	57                   	push   %edi
  80136b:	56                   	push   %esi
  80136c:	53                   	push   %ebx
  80136d:	83 ec 2c             	sub    $0x2c,%esp
  801370:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801373:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801376:	50                   	push   %eax
  801377:	ff 75 08             	pushl  0x8(%ebp)
  80137a:	e8 6e fe ff ff       	call   8011ed <fd_lookup>
  80137f:	83 c4 08             	add    $0x8,%esp
  801382:	85 c0                	test   %eax,%eax
  801384:	0f 88 c1 00 00 00    	js     80144b <dup+0xe4>
		return r;
	close(newfdnum);
  80138a:	83 ec 0c             	sub    $0xc,%esp
  80138d:	56                   	push   %esi
  80138e:	e8 84 ff ff ff       	call   801317 <close>

	newfd = INDEX2FD(newfdnum);
  801393:	89 f3                	mov    %esi,%ebx
  801395:	c1 e3 0c             	shl    $0xc,%ebx
  801398:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80139e:	83 c4 04             	add    $0x4,%esp
  8013a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013a4:	e8 de fd ff ff       	call   801187 <fd2data>
  8013a9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013ab:	89 1c 24             	mov    %ebx,(%esp)
  8013ae:	e8 d4 fd ff ff       	call   801187 <fd2data>
  8013b3:	83 c4 10             	add    $0x10,%esp
  8013b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013b9:	89 f8                	mov    %edi,%eax
  8013bb:	c1 e8 16             	shr    $0x16,%eax
  8013be:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013c5:	a8 01                	test   $0x1,%al
  8013c7:	74 37                	je     801400 <dup+0x99>
  8013c9:	89 f8                	mov    %edi,%eax
  8013cb:	c1 e8 0c             	shr    $0xc,%eax
  8013ce:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013d5:	f6 c2 01             	test   $0x1,%dl
  8013d8:	74 26                	je     801400 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013da:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e1:	83 ec 0c             	sub    $0xc,%esp
  8013e4:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e9:	50                   	push   %eax
  8013ea:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013ed:	6a 00                	push   $0x0
  8013ef:	57                   	push   %edi
  8013f0:	6a 00                	push   $0x0
  8013f2:	e8 d2 fb ff ff       	call   800fc9 <sys_page_map>
  8013f7:	89 c7                	mov    %eax,%edi
  8013f9:	83 c4 20             	add    $0x20,%esp
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	78 2e                	js     80142e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801400:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801403:	89 d0                	mov    %edx,%eax
  801405:	c1 e8 0c             	shr    $0xc,%eax
  801408:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80140f:	83 ec 0c             	sub    $0xc,%esp
  801412:	25 07 0e 00 00       	and    $0xe07,%eax
  801417:	50                   	push   %eax
  801418:	53                   	push   %ebx
  801419:	6a 00                	push   $0x0
  80141b:	52                   	push   %edx
  80141c:	6a 00                	push   $0x0
  80141e:	e8 a6 fb ff ff       	call   800fc9 <sys_page_map>
  801423:	89 c7                	mov    %eax,%edi
  801425:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801428:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80142a:	85 ff                	test   %edi,%edi
  80142c:	79 1d                	jns    80144b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	53                   	push   %ebx
  801432:	6a 00                	push   $0x0
  801434:	e8 d2 fb ff ff       	call   80100b <sys_page_unmap>
	sys_page_unmap(0, nva);
  801439:	83 c4 08             	add    $0x8,%esp
  80143c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80143f:	6a 00                	push   $0x0
  801441:	e8 c5 fb ff ff       	call   80100b <sys_page_unmap>
	return r;
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	89 f8                	mov    %edi,%eax
}
  80144b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80144e:	5b                   	pop    %ebx
  80144f:	5e                   	pop    %esi
  801450:	5f                   	pop    %edi
  801451:	5d                   	pop    %ebp
  801452:	c3                   	ret    

00801453 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	53                   	push   %ebx
  801457:	83 ec 14             	sub    $0x14,%esp
  80145a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80145d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801460:	50                   	push   %eax
  801461:	53                   	push   %ebx
  801462:	e8 86 fd ff ff       	call   8011ed <fd_lookup>
  801467:	83 c4 08             	add    $0x8,%esp
  80146a:	89 c2                	mov    %eax,%edx
  80146c:	85 c0                	test   %eax,%eax
  80146e:	78 6d                	js     8014dd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801470:	83 ec 08             	sub    $0x8,%esp
  801473:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801476:	50                   	push   %eax
  801477:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147a:	ff 30                	pushl  (%eax)
  80147c:	e8 c2 fd ff ff       	call   801243 <dev_lookup>
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	85 c0                	test   %eax,%eax
  801486:	78 4c                	js     8014d4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801488:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80148b:	8b 42 08             	mov    0x8(%edx),%eax
  80148e:	83 e0 03             	and    $0x3,%eax
  801491:	83 f8 01             	cmp    $0x1,%eax
  801494:	75 21                	jne    8014b7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801496:	a1 90 67 80 00       	mov    0x806790,%eax
  80149b:	8b 40 48             	mov    0x48(%eax),%eax
  80149e:	83 ec 04             	sub    $0x4,%esp
  8014a1:	53                   	push   %ebx
  8014a2:	50                   	push   %eax
  8014a3:	68 ed 2b 80 00       	push   $0x802bed
  8014a8:	e8 2b f0 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014b5:	eb 26                	jmp    8014dd <read+0x8a>
	}
	if (!dev->dev_read)
  8014b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ba:	8b 40 08             	mov    0x8(%eax),%eax
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	74 17                	je     8014d8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014c1:	83 ec 04             	sub    $0x4,%esp
  8014c4:	ff 75 10             	pushl  0x10(%ebp)
  8014c7:	ff 75 0c             	pushl  0xc(%ebp)
  8014ca:	52                   	push   %edx
  8014cb:	ff d0                	call   *%eax
  8014cd:	89 c2                	mov    %eax,%edx
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	eb 09                	jmp    8014dd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d4:	89 c2                	mov    %eax,%edx
  8014d6:	eb 05                	jmp    8014dd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014dd:	89 d0                	mov    %edx,%eax
  8014df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e2:	c9                   	leave  
  8014e3:	c3                   	ret    

008014e4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	57                   	push   %edi
  8014e8:	56                   	push   %esi
  8014e9:	53                   	push   %ebx
  8014ea:	83 ec 0c             	sub    $0xc,%esp
  8014ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014f0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f8:	eb 21                	jmp    80151b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014fa:	83 ec 04             	sub    $0x4,%esp
  8014fd:	89 f0                	mov    %esi,%eax
  8014ff:	29 d8                	sub    %ebx,%eax
  801501:	50                   	push   %eax
  801502:	89 d8                	mov    %ebx,%eax
  801504:	03 45 0c             	add    0xc(%ebp),%eax
  801507:	50                   	push   %eax
  801508:	57                   	push   %edi
  801509:	e8 45 ff ff ff       	call   801453 <read>
		if (m < 0)
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	85 c0                	test   %eax,%eax
  801513:	78 10                	js     801525 <readn+0x41>
			return m;
		if (m == 0)
  801515:	85 c0                	test   %eax,%eax
  801517:	74 0a                	je     801523 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801519:	01 c3                	add    %eax,%ebx
  80151b:	39 f3                	cmp    %esi,%ebx
  80151d:	72 db                	jb     8014fa <readn+0x16>
  80151f:	89 d8                	mov    %ebx,%eax
  801521:	eb 02                	jmp    801525 <readn+0x41>
  801523:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801525:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801528:	5b                   	pop    %ebx
  801529:	5e                   	pop    %esi
  80152a:	5f                   	pop    %edi
  80152b:	5d                   	pop    %ebp
  80152c:	c3                   	ret    

0080152d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	53                   	push   %ebx
  801531:	83 ec 14             	sub    $0x14,%esp
  801534:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801537:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153a:	50                   	push   %eax
  80153b:	53                   	push   %ebx
  80153c:	e8 ac fc ff ff       	call   8011ed <fd_lookup>
  801541:	83 c4 08             	add    $0x8,%esp
  801544:	89 c2                	mov    %eax,%edx
  801546:	85 c0                	test   %eax,%eax
  801548:	78 68                	js     8015b2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154a:	83 ec 08             	sub    $0x8,%esp
  80154d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801550:	50                   	push   %eax
  801551:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801554:	ff 30                	pushl  (%eax)
  801556:	e8 e8 fc ff ff       	call   801243 <dev_lookup>
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	85 c0                	test   %eax,%eax
  801560:	78 47                	js     8015a9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801562:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801565:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801569:	75 21                	jne    80158c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80156b:	a1 90 67 80 00       	mov    0x806790,%eax
  801570:	8b 40 48             	mov    0x48(%eax),%eax
  801573:	83 ec 04             	sub    $0x4,%esp
  801576:	53                   	push   %ebx
  801577:	50                   	push   %eax
  801578:	68 09 2c 80 00       	push   $0x802c09
  80157d:	e8 56 ef ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80158a:	eb 26                	jmp    8015b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80158c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80158f:	8b 52 0c             	mov    0xc(%edx),%edx
  801592:	85 d2                	test   %edx,%edx
  801594:	74 17                	je     8015ad <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801596:	83 ec 04             	sub    $0x4,%esp
  801599:	ff 75 10             	pushl  0x10(%ebp)
  80159c:	ff 75 0c             	pushl  0xc(%ebp)
  80159f:	50                   	push   %eax
  8015a0:	ff d2                	call   *%edx
  8015a2:	89 c2                	mov    %eax,%edx
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	eb 09                	jmp    8015b2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a9:	89 c2                	mov    %eax,%edx
  8015ab:	eb 05                	jmp    8015b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015b2:	89 d0                	mov    %edx,%eax
  8015b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b7:	c9                   	leave  
  8015b8:	c3                   	ret    

008015b9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015bf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015c2:	50                   	push   %eax
  8015c3:	ff 75 08             	pushl  0x8(%ebp)
  8015c6:	e8 22 fc ff ff       	call   8011ed <fd_lookup>
  8015cb:	83 c4 08             	add    $0x8,%esp
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 0e                	js     8015e0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e0:	c9                   	leave  
  8015e1:	c3                   	ret    

008015e2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	53                   	push   %ebx
  8015e6:	83 ec 14             	sub    $0x14,%esp
  8015e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ef:	50                   	push   %eax
  8015f0:	53                   	push   %ebx
  8015f1:	e8 f7 fb ff ff       	call   8011ed <fd_lookup>
  8015f6:	83 c4 08             	add    $0x8,%esp
  8015f9:	89 c2                	mov    %eax,%edx
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	78 65                	js     801664 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ff:	83 ec 08             	sub    $0x8,%esp
  801602:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801605:	50                   	push   %eax
  801606:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801609:	ff 30                	pushl  (%eax)
  80160b:	e8 33 fc ff ff       	call   801243 <dev_lookup>
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	78 44                	js     80165b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801617:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80161e:	75 21                	jne    801641 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801620:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801625:	8b 40 48             	mov    0x48(%eax),%eax
  801628:	83 ec 04             	sub    $0x4,%esp
  80162b:	53                   	push   %ebx
  80162c:	50                   	push   %eax
  80162d:	68 cc 2b 80 00       	push   $0x802bcc
  801632:	e8 a1 ee ff ff       	call   8004d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80163f:	eb 23                	jmp    801664 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801641:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801644:	8b 52 18             	mov    0x18(%edx),%edx
  801647:	85 d2                	test   %edx,%edx
  801649:	74 14                	je     80165f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80164b:	83 ec 08             	sub    $0x8,%esp
  80164e:	ff 75 0c             	pushl  0xc(%ebp)
  801651:	50                   	push   %eax
  801652:	ff d2                	call   *%edx
  801654:	89 c2                	mov    %eax,%edx
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	eb 09                	jmp    801664 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165b:	89 c2                	mov    %eax,%edx
  80165d:	eb 05                	jmp    801664 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80165f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801664:	89 d0                	mov    %edx,%eax
  801666:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801669:	c9                   	leave  
  80166a:	c3                   	ret    

0080166b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	53                   	push   %ebx
  80166f:	83 ec 14             	sub    $0x14,%esp
  801672:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801675:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801678:	50                   	push   %eax
  801679:	ff 75 08             	pushl  0x8(%ebp)
  80167c:	e8 6c fb ff ff       	call   8011ed <fd_lookup>
  801681:	83 c4 08             	add    $0x8,%esp
  801684:	89 c2                	mov    %eax,%edx
  801686:	85 c0                	test   %eax,%eax
  801688:	78 58                	js     8016e2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168a:	83 ec 08             	sub    $0x8,%esp
  80168d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801694:	ff 30                	pushl  (%eax)
  801696:	e8 a8 fb ff ff       	call   801243 <dev_lookup>
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	78 37                	js     8016d9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016a9:	74 32                	je     8016dd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016ab:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016ae:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016b5:	00 00 00 
	stat->st_isdir = 0;
  8016b8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016bf:	00 00 00 
	stat->st_dev = dev;
  8016c2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016c8:	83 ec 08             	sub    $0x8,%esp
  8016cb:	53                   	push   %ebx
  8016cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8016cf:	ff 50 14             	call   *0x14(%eax)
  8016d2:	89 c2                	mov    %eax,%edx
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	eb 09                	jmp    8016e2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d9:	89 c2                	mov    %eax,%edx
  8016db:	eb 05                	jmp    8016e2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016e2:	89 d0                	mov    %edx,%eax
  8016e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e7:	c9                   	leave  
  8016e8:	c3                   	ret    

008016e9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	56                   	push   %esi
  8016ed:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ee:	83 ec 08             	sub    $0x8,%esp
  8016f1:	6a 00                	push   $0x0
  8016f3:	ff 75 08             	pushl  0x8(%ebp)
  8016f6:	e8 2b 02 00 00       	call   801926 <open>
  8016fb:	89 c3                	mov    %eax,%ebx
  8016fd:	83 c4 10             	add    $0x10,%esp
  801700:	85 c0                	test   %eax,%eax
  801702:	78 1b                	js     80171f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801704:	83 ec 08             	sub    $0x8,%esp
  801707:	ff 75 0c             	pushl  0xc(%ebp)
  80170a:	50                   	push   %eax
  80170b:	e8 5b ff ff ff       	call   80166b <fstat>
  801710:	89 c6                	mov    %eax,%esi
	close(fd);
  801712:	89 1c 24             	mov    %ebx,(%esp)
  801715:	e8 fd fb ff ff       	call   801317 <close>
	return r;
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	89 f0                	mov    %esi,%eax
}
  80171f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801722:	5b                   	pop    %ebx
  801723:	5e                   	pop    %esi
  801724:	5d                   	pop    %ebp
  801725:	c3                   	ret    

00801726 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	56                   	push   %esi
  80172a:	53                   	push   %ebx
  80172b:	89 c6                	mov    %eax,%esi
  80172d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80172f:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801736:	75 12                	jne    80174a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801738:	83 ec 0c             	sub    $0xc,%esp
  80173b:	6a 01                	push   $0x1
  80173d:	e8 a7 0c 00 00       	call   8023e9 <ipc_find_env>
  801742:	a3 04 50 80 00       	mov    %eax,0x805004
  801747:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80174a:	6a 07                	push   $0x7
  80174c:	68 00 70 80 00       	push   $0x807000
  801751:	56                   	push   %esi
  801752:	ff 35 04 50 80 00    	pushl  0x805004
  801758:	e8 36 0c 00 00       	call   802393 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80175d:	83 c4 0c             	add    $0xc,%esp
  801760:	6a 00                	push   $0x0
  801762:	53                   	push   %ebx
  801763:	6a 00                	push   $0x0
  801765:	e8 c0 0b 00 00       	call   80232a <ipc_recv>
}
  80176a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176d:	5b                   	pop    %ebx
  80176e:	5e                   	pop    %esi
  80176f:	5d                   	pop    %ebp
  801770:	c3                   	ret    

00801771 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801777:	8b 45 08             	mov    0x8(%ebp),%eax
  80177a:	8b 40 0c             	mov    0xc(%eax),%eax
  80177d:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801782:	8b 45 0c             	mov    0xc(%ebp),%eax
  801785:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80178a:	ba 00 00 00 00       	mov    $0x0,%edx
  80178f:	b8 02 00 00 00       	mov    $0x2,%eax
  801794:	e8 8d ff ff ff       	call   801726 <fsipc>
}
  801799:	c9                   	leave  
  80179a:	c3                   	ret    

0080179b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a7:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8017ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b1:	b8 06 00 00 00       	mov    $0x6,%eax
  8017b6:	e8 6b ff ff ff       	call   801726 <fsipc>
}
  8017bb:	c9                   	leave  
  8017bc:	c3                   	ret    

008017bd <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	53                   	push   %ebx
  8017c1:	83 ec 04             	sub    $0x4,%esp
  8017c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8017cd:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d7:	b8 05 00 00 00       	mov    $0x5,%eax
  8017dc:	e8 45 ff ff ff       	call   801726 <fsipc>
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	78 2c                	js     801811 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	68 00 70 80 00       	push   $0x807000
  8017ed:	53                   	push   %ebx
  8017ee:	e8 19 f3 ff ff       	call   800b0c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017f3:	a1 80 70 80 00       	mov    0x807080,%eax
  8017f8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017fe:	a1 84 70 80 00       	mov    0x807084,%eax
  801803:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801811:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801814:	c9                   	leave  
  801815:	c3                   	ret    

00801816 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	53                   	push   %ebx
  80181a:	83 ec 08             	sub    $0x8,%esp
  80181d:	8b 45 10             	mov    0x10(%ebp),%eax
  801820:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801825:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80182a:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80182d:	8b 45 08             	mov    0x8(%ebp),%eax
  801830:	8b 40 0c             	mov    0xc(%eax),%eax
  801833:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.write.req_n = n;
  801838:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80183e:	53                   	push   %ebx
  80183f:	ff 75 0c             	pushl  0xc(%ebp)
  801842:	68 08 70 80 00       	push   $0x807008
  801847:	e8 52 f4 ff ff       	call   800c9e <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80184c:	ba 00 00 00 00       	mov    $0x0,%edx
  801851:	b8 04 00 00 00       	mov    $0x4,%eax
  801856:	e8 cb fe ff ff       	call   801726 <fsipc>
  80185b:	83 c4 10             	add    $0x10,%esp
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 3d                	js     80189f <devfile_write+0x89>
		return r;

	assert(r <= n);
  801862:	39 d8                	cmp    %ebx,%eax
  801864:	76 19                	jbe    80187f <devfile_write+0x69>
  801866:	68 38 2c 80 00       	push   $0x802c38
  80186b:	68 3f 2c 80 00       	push   $0x802c3f
  801870:	68 9f 00 00 00       	push   $0x9f
  801875:	68 54 2c 80 00       	push   $0x802c54
  80187a:	e8 80 eb ff ff       	call   8003ff <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  80187f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801884:	76 19                	jbe    80189f <devfile_write+0x89>
  801886:	68 6c 2c 80 00       	push   $0x802c6c
  80188b:	68 3f 2c 80 00       	push   $0x802c3f
  801890:	68 a0 00 00 00       	push   $0xa0
  801895:	68 54 2c 80 00       	push   $0x802c54
  80189a:	e8 60 eb ff ff       	call   8003ff <_panic>

	return r;
}
  80189f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a2:	c9                   	leave  
  8018a3:	c3                   	ret    

008018a4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	56                   	push   %esi
  8018a8:	53                   	push   %ebx
  8018a9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8018af:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b2:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8018b7:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c2:	b8 03 00 00 00       	mov    $0x3,%eax
  8018c7:	e8 5a fe ff ff       	call   801726 <fsipc>
  8018cc:	89 c3                	mov    %eax,%ebx
  8018ce:	85 c0                	test   %eax,%eax
  8018d0:	78 4b                	js     80191d <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018d2:	39 c6                	cmp    %eax,%esi
  8018d4:	73 16                	jae    8018ec <devfile_read+0x48>
  8018d6:	68 38 2c 80 00       	push   $0x802c38
  8018db:	68 3f 2c 80 00       	push   $0x802c3f
  8018e0:	6a 7e                	push   $0x7e
  8018e2:	68 54 2c 80 00       	push   $0x802c54
  8018e7:	e8 13 eb ff ff       	call   8003ff <_panic>
	assert(r <= PGSIZE);
  8018ec:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018f1:	7e 16                	jle    801909 <devfile_read+0x65>
  8018f3:	68 5f 2c 80 00       	push   $0x802c5f
  8018f8:	68 3f 2c 80 00       	push   $0x802c3f
  8018fd:	6a 7f                	push   $0x7f
  8018ff:	68 54 2c 80 00       	push   $0x802c54
  801904:	e8 f6 ea ff ff       	call   8003ff <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801909:	83 ec 04             	sub    $0x4,%esp
  80190c:	50                   	push   %eax
  80190d:	68 00 70 80 00       	push   $0x807000
  801912:	ff 75 0c             	pushl  0xc(%ebp)
  801915:	e8 84 f3 ff ff       	call   800c9e <memmove>
	return r;
  80191a:	83 c4 10             	add    $0x10,%esp
}
  80191d:	89 d8                	mov    %ebx,%eax
  80191f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801922:	5b                   	pop    %ebx
  801923:	5e                   	pop    %esi
  801924:	5d                   	pop    %ebp
  801925:	c3                   	ret    

00801926 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	53                   	push   %ebx
  80192a:	83 ec 20             	sub    $0x20,%esp
  80192d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801930:	53                   	push   %ebx
  801931:	e8 9d f1 ff ff       	call   800ad3 <strlen>
  801936:	83 c4 10             	add    $0x10,%esp
  801939:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80193e:	7f 67                	jg     8019a7 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801940:	83 ec 0c             	sub    $0xc,%esp
  801943:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801946:	50                   	push   %eax
  801947:	e8 52 f8 ff ff       	call   80119e <fd_alloc>
  80194c:	83 c4 10             	add    $0x10,%esp
		return r;
  80194f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801951:	85 c0                	test   %eax,%eax
  801953:	78 57                	js     8019ac <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801955:	83 ec 08             	sub    $0x8,%esp
  801958:	53                   	push   %ebx
  801959:	68 00 70 80 00       	push   $0x807000
  80195e:	e8 a9 f1 ff ff       	call   800b0c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801963:	8b 45 0c             	mov    0xc(%ebp),%eax
  801966:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80196b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80196e:	b8 01 00 00 00       	mov    $0x1,%eax
  801973:	e8 ae fd ff ff       	call   801726 <fsipc>
  801978:	89 c3                	mov    %eax,%ebx
  80197a:	83 c4 10             	add    $0x10,%esp
  80197d:	85 c0                	test   %eax,%eax
  80197f:	79 14                	jns    801995 <open+0x6f>
		fd_close(fd, 0);
  801981:	83 ec 08             	sub    $0x8,%esp
  801984:	6a 00                	push   $0x0
  801986:	ff 75 f4             	pushl  -0xc(%ebp)
  801989:	e8 08 f9 ff ff       	call   801296 <fd_close>
		return r;
  80198e:	83 c4 10             	add    $0x10,%esp
  801991:	89 da                	mov    %ebx,%edx
  801993:	eb 17                	jmp    8019ac <open+0x86>
	}

	return fd2num(fd);
  801995:	83 ec 0c             	sub    $0xc,%esp
  801998:	ff 75 f4             	pushl  -0xc(%ebp)
  80199b:	e8 d7 f7 ff ff       	call   801177 <fd2num>
  8019a0:	89 c2                	mov    %eax,%edx
  8019a2:	83 c4 10             	add    $0x10,%esp
  8019a5:	eb 05                	jmp    8019ac <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019a7:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019ac:	89 d0                	mov    %edx,%eax
  8019ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b1:	c9                   	leave  
  8019b2:	c3                   	ret    

008019b3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019be:	b8 08 00 00 00       	mov    $0x8,%eax
  8019c3:	e8 5e fd ff ff       	call   801726 <fsipc>
}
  8019c8:	c9                   	leave  
  8019c9:	c3                   	ret    

008019ca <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	57                   	push   %edi
  8019ce:	56                   	push   %esi
  8019cf:	53                   	push   %ebx
  8019d0:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8019d6:	6a 00                	push   $0x0
  8019d8:	ff 75 08             	pushl  0x8(%ebp)
  8019db:	e8 46 ff ff ff       	call   801926 <open>
  8019e0:	89 c7                	mov    %eax,%edi
  8019e2:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8019e8:	83 c4 10             	add    $0x10,%esp
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	0f 88 af 04 00 00    	js     801ea2 <spawn+0x4d8>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8019f3:	83 ec 04             	sub    $0x4,%esp
  8019f6:	68 00 02 00 00       	push   $0x200
  8019fb:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801a01:	50                   	push   %eax
  801a02:	57                   	push   %edi
  801a03:	e8 dc fa ff ff       	call   8014e4 <readn>
  801a08:	83 c4 10             	add    $0x10,%esp
  801a0b:	3d 00 02 00 00       	cmp    $0x200,%eax
  801a10:	75 0c                	jne    801a1e <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801a12:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801a19:	45 4c 46 
  801a1c:	74 33                	je     801a51 <spawn+0x87>
		close(fd);
  801a1e:	83 ec 0c             	sub    $0xc,%esp
  801a21:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a27:	e8 eb f8 ff ff       	call   801317 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a2c:	83 c4 0c             	add    $0xc,%esp
  801a2f:	68 7f 45 4c 46       	push   $0x464c457f
  801a34:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801a3a:	68 99 2c 80 00       	push   $0x802c99
  801a3f:	e8 94 ea ff ff       	call   8004d8 <cprintf>
		return -E_NOT_EXEC;
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801a4c:	e9 b1 04 00 00       	jmp    801f02 <spawn+0x538>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801a51:	b8 07 00 00 00       	mov    $0x7,%eax
  801a56:	cd 30                	int    $0x30
  801a58:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a5e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a64:	85 c0                	test   %eax,%eax
  801a66:	0f 88 3e 04 00 00    	js     801eaa <spawn+0x4e0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a6c:	89 c6                	mov    %eax,%esi
  801a6e:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801a74:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801a77:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801a7d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a83:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a88:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a8a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a90:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a96:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a9b:	be 00 00 00 00       	mov    $0x0,%esi
  801aa0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801aa3:	eb 13                	jmp    801ab8 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801aa5:	83 ec 0c             	sub    $0xc,%esp
  801aa8:	50                   	push   %eax
  801aa9:	e8 25 f0 ff ff       	call   800ad3 <strlen>
  801aae:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ab2:	83 c3 01             	add    $0x1,%ebx
  801ab5:	83 c4 10             	add    $0x10,%esp
  801ab8:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801abf:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	75 df                	jne    801aa5 <spawn+0xdb>
  801ac6:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801acc:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801ad2:	bf 00 10 40 00       	mov    $0x401000,%edi
  801ad7:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801ad9:	89 fa                	mov    %edi,%edx
  801adb:	83 e2 fc             	and    $0xfffffffc,%edx
  801ade:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801ae5:	29 c2                	sub    %eax,%edx
  801ae7:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801aed:	8d 42 f8             	lea    -0x8(%edx),%eax
  801af0:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801af5:	0f 86 bf 03 00 00    	jbe    801eba <spawn+0x4f0>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801afb:	83 ec 04             	sub    $0x4,%esp
  801afe:	6a 07                	push   $0x7
  801b00:	68 00 00 40 00       	push   $0x400000
  801b05:	6a 00                	push   $0x0
  801b07:	e8 7a f4 ff ff       	call   800f86 <sys_page_alloc>
  801b0c:	83 c4 10             	add    $0x10,%esp
  801b0f:	85 c0                	test   %eax,%eax
  801b11:	0f 88 aa 03 00 00    	js     801ec1 <spawn+0x4f7>
  801b17:	be 00 00 00 00       	mov    $0x0,%esi
  801b1c:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801b22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b25:	eb 30                	jmp    801b57 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801b27:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801b2d:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801b33:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801b36:	83 ec 08             	sub    $0x8,%esp
  801b39:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b3c:	57                   	push   %edi
  801b3d:	e8 ca ef ff ff       	call   800b0c <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b42:	83 c4 04             	add    $0x4,%esp
  801b45:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b48:	e8 86 ef ff ff       	call   800ad3 <strlen>
  801b4d:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b51:	83 c6 01             	add    $0x1,%esi
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801b5d:	7f c8                	jg     801b27 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801b5f:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b65:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801b6b:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b72:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b78:	74 19                	je     801b93 <spawn+0x1c9>
  801b7a:	68 20 2d 80 00       	push   $0x802d20
  801b7f:	68 3f 2c 80 00       	push   $0x802c3f
  801b84:	68 f2 00 00 00       	push   $0xf2
  801b89:	68 b3 2c 80 00       	push   $0x802cb3
  801b8e:	e8 6c e8 ff ff       	call   8003ff <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b93:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801b99:	89 f8                	mov    %edi,%eax
  801b9b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801ba0:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801ba3:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ba9:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801bac:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801bb2:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801bb8:	83 ec 0c             	sub    $0xc,%esp
  801bbb:	6a 07                	push   $0x7
  801bbd:	68 00 d0 bf ee       	push   $0xeebfd000
  801bc2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801bc8:	68 00 00 40 00       	push   $0x400000
  801bcd:	6a 00                	push   $0x0
  801bcf:	e8 f5 f3 ff ff       	call   800fc9 <sys_page_map>
  801bd4:	89 c3                	mov    %eax,%ebx
  801bd6:	83 c4 20             	add    $0x20,%esp
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	0f 88 0f 03 00 00    	js     801ef0 <spawn+0x526>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801be1:	83 ec 08             	sub    $0x8,%esp
  801be4:	68 00 00 40 00       	push   $0x400000
  801be9:	6a 00                	push   $0x0
  801beb:	e8 1b f4 ff ff       	call   80100b <sys_page_unmap>
  801bf0:	89 c3                	mov    %eax,%ebx
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	0f 88 f3 02 00 00    	js     801ef0 <spawn+0x526>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801bfd:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801c03:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801c0a:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c10:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801c17:	00 00 00 
  801c1a:	e9 88 01 00 00       	jmp    801da7 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801c1f:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801c25:	83 38 01             	cmpl   $0x1,(%eax)
  801c28:	0f 85 6b 01 00 00    	jne    801d99 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c2e:	89 c7                	mov    %eax,%edi
  801c30:	8b 40 18             	mov    0x18(%eax),%eax
  801c33:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801c39:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801c3c:	83 f8 01             	cmp    $0x1,%eax
  801c3f:	19 c0                	sbb    %eax,%eax
  801c41:	83 e0 fe             	and    $0xfffffffe,%eax
  801c44:	83 c0 07             	add    $0x7,%eax
  801c47:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801c4d:	89 f8                	mov    %edi,%eax
  801c4f:	8b 7f 04             	mov    0x4(%edi),%edi
  801c52:	89 f9                	mov    %edi,%ecx
  801c54:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801c5a:	8b 78 10             	mov    0x10(%eax),%edi
  801c5d:	8b 50 14             	mov    0x14(%eax),%edx
  801c60:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801c66:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801c69:	89 f0                	mov    %esi,%eax
  801c6b:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c70:	74 14                	je     801c86 <spawn+0x2bc>
		va -= i;
  801c72:	29 c6                	sub    %eax,%esi
		memsz += i;
  801c74:	01 c2                	add    %eax,%edx
  801c76:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801c7c:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801c7e:	29 c1                	sub    %eax,%ecx
  801c80:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c86:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c8b:	e9 f7 00 00 00       	jmp    801d87 <spawn+0x3bd>
		if (i >= filesz) {
  801c90:	39 df                	cmp    %ebx,%edi
  801c92:	77 27                	ja     801cbb <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c94:	83 ec 04             	sub    $0x4,%esp
  801c97:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c9d:	56                   	push   %esi
  801c9e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801ca4:	e8 dd f2 ff ff       	call   800f86 <sys_page_alloc>
  801ca9:	83 c4 10             	add    $0x10,%esp
  801cac:	85 c0                	test   %eax,%eax
  801cae:	0f 89 c7 00 00 00    	jns    801d7b <spawn+0x3b1>
  801cb4:	89 c3                	mov    %eax,%ebx
  801cb6:	e9 14 02 00 00       	jmp    801ecf <spawn+0x505>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801cbb:	83 ec 04             	sub    $0x4,%esp
  801cbe:	6a 07                	push   $0x7
  801cc0:	68 00 00 40 00       	push   $0x400000
  801cc5:	6a 00                	push   $0x0
  801cc7:	e8 ba f2 ff ff       	call   800f86 <sys_page_alloc>
  801ccc:	83 c4 10             	add    $0x10,%esp
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	0f 88 ee 01 00 00    	js     801ec5 <spawn+0x4fb>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801cd7:	83 ec 08             	sub    $0x8,%esp
  801cda:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801ce0:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801ce6:	50                   	push   %eax
  801ce7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ced:	e8 c7 f8 ff ff       	call   8015b9 <seek>
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	0f 88 cc 01 00 00    	js     801ec9 <spawn+0x4ff>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801cfd:	83 ec 04             	sub    $0x4,%esp
  801d00:	89 f8                	mov    %edi,%eax
  801d02:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801d08:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d0d:	ba 00 10 00 00       	mov    $0x1000,%edx
  801d12:	0f 47 c2             	cmova  %edx,%eax
  801d15:	50                   	push   %eax
  801d16:	68 00 00 40 00       	push   $0x400000
  801d1b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d21:	e8 be f7 ff ff       	call   8014e4 <readn>
  801d26:	83 c4 10             	add    $0x10,%esp
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	0f 88 9c 01 00 00    	js     801ecd <spawn+0x503>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801d31:	83 ec 0c             	sub    $0xc,%esp
  801d34:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801d3a:	56                   	push   %esi
  801d3b:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801d41:	68 00 00 40 00       	push   $0x400000
  801d46:	6a 00                	push   $0x0
  801d48:	e8 7c f2 ff ff       	call   800fc9 <sys_page_map>
  801d4d:	83 c4 20             	add    $0x20,%esp
  801d50:	85 c0                	test   %eax,%eax
  801d52:	79 15                	jns    801d69 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801d54:	50                   	push   %eax
  801d55:	68 bf 2c 80 00       	push   $0x802cbf
  801d5a:	68 25 01 00 00       	push   $0x125
  801d5f:	68 b3 2c 80 00       	push   $0x802cb3
  801d64:	e8 96 e6 ff ff       	call   8003ff <_panic>
			sys_page_unmap(0, UTEMP);
  801d69:	83 ec 08             	sub    $0x8,%esp
  801d6c:	68 00 00 40 00       	push   $0x400000
  801d71:	6a 00                	push   $0x0
  801d73:	e8 93 f2 ff ff       	call   80100b <sys_page_unmap>
  801d78:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d7b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d81:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d87:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801d8d:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801d93:	0f 87 f7 fe ff ff    	ja     801c90 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d99:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801da0:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801da7:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801dae:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801db4:	0f 8c 65 fe ff ff    	jl     801c1f <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801dba:	83 ec 0c             	sub    $0xc,%esp
  801dbd:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801dc3:	e8 4f f5 ff ff       	call   801317 <close>
  801dc8:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	int r;

	// loop through all page table entries
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn) {
  801dcb:	bb 00 08 00 00       	mov    $0x800,%ebx
  801dd0:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		// the page table does not exist at all
		if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) {
  801dd6:	89 d8                	mov    %ebx,%eax
  801dd8:	c1 e0 0c             	shl    $0xc,%eax
  801ddb:	89 c2                	mov    %eax,%edx
  801ddd:	c1 ea 16             	shr    $0x16,%edx
  801de0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801de7:	f6 c2 01             	test   $0x1,%dl
  801dea:	75 08                	jne    801df4 <spawn+0x42a>
			pn += NPTENTRIES - 1;
  801dec:	81 c3 ff 03 00 00    	add    $0x3ff,%ebx
  801df2:	eb 3c                	jmp    801e30 <spawn+0x466>
			continue;
		}

		// virtual page pn's page table entry
		pte_t pe = uvpt[pn];
  801df4:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx

		// share the page with the new environment
		if(pe & PTE_SHARE) {
  801dfb:	f6 c6 04             	test   $0x4,%dh
  801dfe:	74 30                	je     801e30 <spawn+0x466>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), child, 
  801e00:	83 ec 0c             	sub    $0xc,%esp
  801e03:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801e09:	52                   	push   %edx
  801e0a:	50                   	push   %eax
  801e0b:	56                   	push   %esi
  801e0c:	50                   	push   %eax
  801e0d:	6a 00                	push   $0x0
  801e0f:	e8 b5 f1 ff ff       	call   800fc9 <sys_page_map>
  801e14:	83 c4 20             	add    $0x20,%esp
  801e17:	85 c0                	test   %eax,%eax
  801e19:	79 15                	jns    801e30 <spawn+0x466>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("copy_shared: %e", r);
  801e1b:	50                   	push   %eax
  801e1c:	68 dc 2c 80 00       	push   $0x802cdc
  801e21:	68 42 01 00 00       	push   $0x142
  801e26:	68 b3 2c 80 00       	push   $0x802cb3
  801e2b:	e8 cf e5 ff ff       	call   8003ff <_panic>
{
	// LAB 5: Your code here.
	int r;

	// loop through all page table entries
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn) {
  801e30:	83 c3 01             	add    $0x1,%ebx
  801e33:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801e39:	76 9b                	jbe    801dd6 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e3b:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e42:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e45:	83 ec 08             	sub    $0x8,%esp
  801e48:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e4e:	50                   	push   %eax
  801e4f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e55:	e8 35 f2 ff ff       	call   80108f <sys_env_set_trapframe>
  801e5a:	83 c4 10             	add    $0x10,%esp
  801e5d:	85 c0                	test   %eax,%eax
  801e5f:	79 15                	jns    801e76 <spawn+0x4ac>
		panic("sys_env_set_trapframe: %e", r);
  801e61:	50                   	push   %eax
  801e62:	68 ec 2c 80 00       	push   $0x802cec
  801e67:	68 86 00 00 00       	push   $0x86
  801e6c:	68 b3 2c 80 00       	push   $0x802cb3
  801e71:	e8 89 e5 ff ff       	call   8003ff <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e76:	83 ec 08             	sub    $0x8,%esp
  801e79:	6a 02                	push   $0x2
  801e7b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e81:	e8 c7 f1 ff ff       	call   80104d <sys_env_set_status>
  801e86:	83 c4 10             	add    $0x10,%esp
  801e89:	85 c0                	test   %eax,%eax
  801e8b:	79 25                	jns    801eb2 <spawn+0x4e8>
		panic("sys_env_set_status: %e", r);
  801e8d:	50                   	push   %eax
  801e8e:	68 06 2d 80 00       	push   $0x802d06
  801e93:	68 89 00 00 00       	push   $0x89
  801e98:	68 b3 2c 80 00       	push   $0x802cb3
  801e9d:	e8 5d e5 ff ff       	call   8003ff <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801ea2:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801ea8:	eb 58                	jmp    801f02 <spawn+0x538>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801eaa:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801eb0:	eb 50                	jmp    801f02 <spawn+0x538>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801eb2:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801eb8:	eb 48                	jmp    801f02 <spawn+0x538>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801eba:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801ebf:	eb 41                	jmp    801f02 <spawn+0x538>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801ec1:	89 c3                	mov    %eax,%ebx
  801ec3:	eb 3d                	jmp    801f02 <spawn+0x538>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ec5:	89 c3                	mov    %eax,%ebx
  801ec7:	eb 06                	jmp    801ecf <spawn+0x505>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ec9:	89 c3                	mov    %eax,%ebx
  801ecb:	eb 02                	jmp    801ecf <spawn+0x505>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ecd:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801ecf:	83 ec 0c             	sub    $0xc,%esp
  801ed2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ed8:	e8 2a f0 ff ff       	call   800f07 <sys_env_destroy>
	close(fd);
  801edd:	83 c4 04             	add    $0x4,%esp
  801ee0:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ee6:	e8 2c f4 ff ff       	call   801317 <close>
	return r;
  801eeb:	83 c4 10             	add    $0x10,%esp
  801eee:	eb 12                	jmp    801f02 <spawn+0x538>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801ef0:	83 ec 08             	sub    $0x8,%esp
  801ef3:	68 00 00 40 00       	push   $0x400000
  801ef8:	6a 00                	push   $0x0
  801efa:	e8 0c f1 ff ff       	call   80100b <sys_page_unmap>
  801eff:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801f02:	89 d8                	mov    %ebx,%eax
  801f04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f07:	5b                   	pop    %ebx
  801f08:	5e                   	pop    %esi
  801f09:	5f                   	pop    %edi
  801f0a:	5d                   	pop    %ebp
  801f0b:	c3                   	ret    

00801f0c <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	56                   	push   %esi
  801f10:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f11:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801f14:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f19:	eb 03                	jmp    801f1e <spawnl+0x12>
		argc++;
  801f1b:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f1e:	83 c2 04             	add    $0x4,%edx
  801f21:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801f25:	75 f4                	jne    801f1b <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801f27:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801f2e:	83 e2 f0             	and    $0xfffffff0,%edx
  801f31:	29 d4                	sub    %edx,%esp
  801f33:	8d 54 24 03          	lea    0x3(%esp),%edx
  801f37:	c1 ea 02             	shr    $0x2,%edx
  801f3a:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801f41:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801f43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f46:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801f4d:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801f54:	00 
  801f55:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f57:	b8 00 00 00 00       	mov    $0x0,%eax
  801f5c:	eb 0a                	jmp    801f68 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801f5e:	83 c0 01             	add    $0x1,%eax
  801f61:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801f65:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f68:	39 d0                	cmp    %edx,%eax
  801f6a:	75 f2                	jne    801f5e <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f6c:	83 ec 08             	sub    $0x8,%esp
  801f6f:	56                   	push   %esi
  801f70:	ff 75 08             	pushl  0x8(%ebp)
  801f73:	e8 52 fa ff ff       	call   8019ca <spawn>
}
  801f78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f7b:	5b                   	pop    %ebx
  801f7c:	5e                   	pop    %esi
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    

00801f7f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f87:	83 ec 0c             	sub    $0xc,%esp
  801f8a:	ff 75 08             	pushl  0x8(%ebp)
  801f8d:	e8 f5 f1 ff ff       	call   801187 <fd2data>
  801f92:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f94:	83 c4 08             	add    $0x8,%esp
  801f97:	68 46 2d 80 00       	push   $0x802d46
  801f9c:	53                   	push   %ebx
  801f9d:	e8 6a eb ff ff       	call   800b0c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fa2:	8b 46 04             	mov    0x4(%esi),%eax
  801fa5:	2b 06                	sub    (%esi),%eax
  801fa7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801fad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fb4:	00 00 00 
	stat->st_dev = &devpipe;
  801fb7:	c7 83 88 00 00 00 ac 	movl   $0x8047ac,0x88(%ebx)
  801fbe:	47 80 00 
	return 0;
}
  801fc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc9:	5b                   	pop    %ebx
  801fca:	5e                   	pop    %esi
  801fcb:	5d                   	pop    %ebp
  801fcc:	c3                   	ret    

00801fcd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	53                   	push   %ebx
  801fd1:	83 ec 0c             	sub    $0xc,%esp
  801fd4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fd7:	53                   	push   %ebx
  801fd8:	6a 00                	push   $0x0
  801fda:	e8 2c f0 ff ff       	call   80100b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fdf:	89 1c 24             	mov    %ebx,(%esp)
  801fe2:	e8 a0 f1 ff ff       	call   801187 <fd2data>
  801fe7:	83 c4 08             	add    $0x8,%esp
  801fea:	50                   	push   %eax
  801feb:	6a 00                	push   $0x0
  801fed:	e8 19 f0 ff ff       	call   80100b <sys_page_unmap>
}
  801ff2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ff5:	c9                   	leave  
  801ff6:	c3                   	ret    

00801ff7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ff7:	55                   	push   %ebp
  801ff8:	89 e5                	mov    %esp,%ebp
  801ffa:	57                   	push   %edi
  801ffb:	56                   	push   %esi
  801ffc:	53                   	push   %ebx
  801ffd:	83 ec 1c             	sub    $0x1c,%esp
  802000:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802003:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802005:	a1 90 67 80 00       	mov    0x806790,%eax
  80200a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80200d:	83 ec 0c             	sub    $0xc,%esp
  802010:	ff 75 e0             	pushl  -0x20(%ebp)
  802013:	e8 0a 04 00 00       	call   802422 <pageref>
  802018:	89 c3                	mov    %eax,%ebx
  80201a:	89 3c 24             	mov    %edi,(%esp)
  80201d:	e8 00 04 00 00       	call   802422 <pageref>
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	39 c3                	cmp    %eax,%ebx
  802027:	0f 94 c1             	sete   %cl
  80202a:	0f b6 c9             	movzbl %cl,%ecx
  80202d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802030:	8b 15 90 67 80 00    	mov    0x806790,%edx
  802036:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802039:	39 ce                	cmp    %ecx,%esi
  80203b:	74 1b                	je     802058 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80203d:	39 c3                	cmp    %eax,%ebx
  80203f:	75 c4                	jne    802005 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802041:	8b 42 58             	mov    0x58(%edx),%eax
  802044:	ff 75 e4             	pushl  -0x1c(%ebp)
  802047:	50                   	push   %eax
  802048:	56                   	push   %esi
  802049:	68 4d 2d 80 00       	push   $0x802d4d
  80204e:	e8 85 e4 ff ff       	call   8004d8 <cprintf>
  802053:	83 c4 10             	add    $0x10,%esp
  802056:	eb ad                	jmp    802005 <_pipeisclosed+0xe>
	}
}
  802058:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80205b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80205e:	5b                   	pop    %ebx
  80205f:	5e                   	pop    %esi
  802060:	5f                   	pop    %edi
  802061:	5d                   	pop    %ebp
  802062:	c3                   	ret    

00802063 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802063:	55                   	push   %ebp
  802064:	89 e5                	mov    %esp,%ebp
  802066:	57                   	push   %edi
  802067:	56                   	push   %esi
  802068:	53                   	push   %ebx
  802069:	83 ec 28             	sub    $0x28,%esp
  80206c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80206f:	56                   	push   %esi
  802070:	e8 12 f1 ff ff       	call   801187 <fd2data>
  802075:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802077:	83 c4 10             	add    $0x10,%esp
  80207a:	bf 00 00 00 00       	mov    $0x0,%edi
  80207f:	eb 4b                	jmp    8020cc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802081:	89 da                	mov    %ebx,%edx
  802083:	89 f0                	mov    %esi,%eax
  802085:	e8 6d ff ff ff       	call   801ff7 <_pipeisclosed>
  80208a:	85 c0                	test   %eax,%eax
  80208c:	75 48                	jne    8020d6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80208e:	e8 d4 ee ff ff       	call   800f67 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802093:	8b 43 04             	mov    0x4(%ebx),%eax
  802096:	8b 0b                	mov    (%ebx),%ecx
  802098:	8d 51 20             	lea    0x20(%ecx),%edx
  80209b:	39 d0                	cmp    %edx,%eax
  80209d:	73 e2                	jae    802081 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80209f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020a2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020a6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020a9:	89 c2                	mov    %eax,%edx
  8020ab:	c1 fa 1f             	sar    $0x1f,%edx
  8020ae:	89 d1                	mov    %edx,%ecx
  8020b0:	c1 e9 1b             	shr    $0x1b,%ecx
  8020b3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020b6:	83 e2 1f             	and    $0x1f,%edx
  8020b9:	29 ca                	sub    %ecx,%edx
  8020bb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020bf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020c3:	83 c0 01             	add    $0x1,%eax
  8020c6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020c9:	83 c7 01             	add    $0x1,%edi
  8020cc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020cf:	75 c2                	jne    802093 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8020d4:	eb 05                	jmp    8020db <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020d6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020de:	5b                   	pop    %ebx
  8020df:	5e                   	pop    %esi
  8020e0:	5f                   	pop    %edi
  8020e1:	5d                   	pop    %ebp
  8020e2:	c3                   	ret    

008020e3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020e3:	55                   	push   %ebp
  8020e4:	89 e5                	mov    %esp,%ebp
  8020e6:	57                   	push   %edi
  8020e7:	56                   	push   %esi
  8020e8:	53                   	push   %ebx
  8020e9:	83 ec 18             	sub    $0x18,%esp
  8020ec:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020ef:	57                   	push   %edi
  8020f0:	e8 92 f0 ff ff       	call   801187 <fd2data>
  8020f5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020f7:	83 c4 10             	add    $0x10,%esp
  8020fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020ff:	eb 3d                	jmp    80213e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802101:	85 db                	test   %ebx,%ebx
  802103:	74 04                	je     802109 <devpipe_read+0x26>
				return i;
  802105:	89 d8                	mov    %ebx,%eax
  802107:	eb 44                	jmp    80214d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802109:	89 f2                	mov    %esi,%edx
  80210b:	89 f8                	mov    %edi,%eax
  80210d:	e8 e5 fe ff ff       	call   801ff7 <_pipeisclosed>
  802112:	85 c0                	test   %eax,%eax
  802114:	75 32                	jne    802148 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802116:	e8 4c ee ff ff       	call   800f67 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80211b:	8b 06                	mov    (%esi),%eax
  80211d:	3b 46 04             	cmp    0x4(%esi),%eax
  802120:	74 df                	je     802101 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802122:	99                   	cltd   
  802123:	c1 ea 1b             	shr    $0x1b,%edx
  802126:	01 d0                	add    %edx,%eax
  802128:	83 e0 1f             	and    $0x1f,%eax
  80212b:	29 d0                	sub    %edx,%eax
  80212d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802132:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802135:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802138:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80213b:	83 c3 01             	add    $0x1,%ebx
  80213e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802141:	75 d8                	jne    80211b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802143:	8b 45 10             	mov    0x10(%ebp),%eax
  802146:	eb 05                	jmp    80214d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802148:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80214d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802150:	5b                   	pop    %ebx
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    

00802155 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802155:	55                   	push   %ebp
  802156:	89 e5                	mov    %esp,%ebp
  802158:	56                   	push   %esi
  802159:	53                   	push   %ebx
  80215a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80215d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802160:	50                   	push   %eax
  802161:	e8 38 f0 ff ff       	call   80119e <fd_alloc>
  802166:	83 c4 10             	add    $0x10,%esp
  802169:	89 c2                	mov    %eax,%edx
  80216b:	85 c0                	test   %eax,%eax
  80216d:	0f 88 2c 01 00 00    	js     80229f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802173:	83 ec 04             	sub    $0x4,%esp
  802176:	68 07 04 00 00       	push   $0x407
  80217b:	ff 75 f4             	pushl  -0xc(%ebp)
  80217e:	6a 00                	push   $0x0
  802180:	e8 01 ee ff ff       	call   800f86 <sys_page_alloc>
  802185:	83 c4 10             	add    $0x10,%esp
  802188:	89 c2                	mov    %eax,%edx
  80218a:	85 c0                	test   %eax,%eax
  80218c:	0f 88 0d 01 00 00    	js     80229f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802192:	83 ec 0c             	sub    $0xc,%esp
  802195:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802198:	50                   	push   %eax
  802199:	e8 00 f0 ff ff       	call   80119e <fd_alloc>
  80219e:	89 c3                	mov    %eax,%ebx
  8021a0:	83 c4 10             	add    $0x10,%esp
  8021a3:	85 c0                	test   %eax,%eax
  8021a5:	0f 88 e2 00 00 00    	js     80228d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ab:	83 ec 04             	sub    $0x4,%esp
  8021ae:	68 07 04 00 00       	push   $0x407
  8021b3:	ff 75 f0             	pushl  -0x10(%ebp)
  8021b6:	6a 00                	push   $0x0
  8021b8:	e8 c9 ed ff ff       	call   800f86 <sys_page_alloc>
  8021bd:	89 c3                	mov    %eax,%ebx
  8021bf:	83 c4 10             	add    $0x10,%esp
  8021c2:	85 c0                	test   %eax,%eax
  8021c4:	0f 88 c3 00 00 00    	js     80228d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021ca:	83 ec 0c             	sub    $0xc,%esp
  8021cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8021d0:	e8 b2 ef ff ff       	call   801187 <fd2data>
  8021d5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021d7:	83 c4 0c             	add    $0xc,%esp
  8021da:	68 07 04 00 00       	push   $0x407
  8021df:	50                   	push   %eax
  8021e0:	6a 00                	push   $0x0
  8021e2:	e8 9f ed ff ff       	call   800f86 <sys_page_alloc>
  8021e7:	89 c3                	mov    %eax,%ebx
  8021e9:	83 c4 10             	add    $0x10,%esp
  8021ec:	85 c0                	test   %eax,%eax
  8021ee:	0f 88 89 00 00 00    	js     80227d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021f4:	83 ec 0c             	sub    $0xc,%esp
  8021f7:	ff 75 f0             	pushl  -0x10(%ebp)
  8021fa:	e8 88 ef ff ff       	call   801187 <fd2data>
  8021ff:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802206:	50                   	push   %eax
  802207:	6a 00                	push   $0x0
  802209:	56                   	push   %esi
  80220a:	6a 00                	push   $0x0
  80220c:	e8 b8 ed ff ff       	call   800fc9 <sys_page_map>
  802211:	89 c3                	mov    %eax,%ebx
  802213:	83 c4 20             	add    $0x20,%esp
  802216:	85 c0                	test   %eax,%eax
  802218:	78 55                	js     80226f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80221a:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802220:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802223:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802225:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802228:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80222f:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802235:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802238:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80223a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80223d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802244:	83 ec 0c             	sub    $0xc,%esp
  802247:	ff 75 f4             	pushl  -0xc(%ebp)
  80224a:	e8 28 ef ff ff       	call   801177 <fd2num>
  80224f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802252:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802254:	83 c4 04             	add    $0x4,%esp
  802257:	ff 75 f0             	pushl  -0x10(%ebp)
  80225a:	e8 18 ef ff ff       	call   801177 <fd2num>
  80225f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802262:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802265:	83 c4 10             	add    $0x10,%esp
  802268:	ba 00 00 00 00       	mov    $0x0,%edx
  80226d:	eb 30                	jmp    80229f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80226f:	83 ec 08             	sub    $0x8,%esp
  802272:	56                   	push   %esi
  802273:	6a 00                	push   $0x0
  802275:	e8 91 ed ff ff       	call   80100b <sys_page_unmap>
  80227a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80227d:	83 ec 08             	sub    $0x8,%esp
  802280:	ff 75 f0             	pushl  -0x10(%ebp)
  802283:	6a 00                	push   $0x0
  802285:	e8 81 ed ff ff       	call   80100b <sys_page_unmap>
  80228a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80228d:	83 ec 08             	sub    $0x8,%esp
  802290:	ff 75 f4             	pushl  -0xc(%ebp)
  802293:	6a 00                	push   $0x0
  802295:	e8 71 ed ff ff       	call   80100b <sys_page_unmap>
  80229a:	83 c4 10             	add    $0x10,%esp
  80229d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80229f:	89 d0                	mov    %edx,%eax
  8022a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022a4:	5b                   	pop    %ebx
  8022a5:	5e                   	pop    %esi
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    

008022a8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022b1:	50                   	push   %eax
  8022b2:	ff 75 08             	pushl  0x8(%ebp)
  8022b5:	e8 33 ef ff ff       	call   8011ed <fd_lookup>
  8022ba:	83 c4 10             	add    $0x10,%esp
  8022bd:	85 c0                	test   %eax,%eax
  8022bf:	78 18                	js     8022d9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022c1:	83 ec 0c             	sub    $0xc,%esp
  8022c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8022c7:	e8 bb ee ff ff       	call   801187 <fd2data>
	return _pipeisclosed(fd, p);
  8022cc:	89 c2                	mov    %eax,%edx
  8022ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d1:	e8 21 fd ff ff       	call   801ff7 <_pipeisclosed>
  8022d6:	83 c4 10             	add    $0x10,%esp
}
  8022d9:	c9                   	leave  
  8022da:	c3                   	ret    

008022db <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8022db:	55                   	push   %ebp
  8022dc:	89 e5                	mov    %esp,%ebp
  8022de:	56                   	push   %esi
  8022df:	53                   	push   %ebx
  8022e0:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8022e3:	85 f6                	test   %esi,%esi
  8022e5:	75 16                	jne    8022fd <wait+0x22>
  8022e7:	68 65 2d 80 00       	push   $0x802d65
  8022ec:	68 3f 2c 80 00       	push   $0x802c3f
  8022f1:	6a 09                	push   $0x9
  8022f3:	68 70 2d 80 00       	push   $0x802d70
  8022f8:	e8 02 e1 ff ff       	call   8003ff <_panic>
	e = &envs[ENVX(envid)];
  8022fd:	89 f3                	mov    %esi,%ebx
  8022ff:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802305:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802308:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80230e:	eb 05                	jmp    802315 <wait+0x3a>
		sys_yield();
  802310:	e8 52 ec ff ff       	call   800f67 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802315:	8b 43 48             	mov    0x48(%ebx),%eax
  802318:	39 c6                	cmp    %eax,%esi
  80231a:	75 07                	jne    802323 <wait+0x48>
  80231c:	8b 43 54             	mov    0x54(%ebx),%eax
  80231f:	85 c0                	test   %eax,%eax
  802321:	75 ed                	jne    802310 <wait+0x35>
		sys_yield();
}
  802323:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802326:	5b                   	pop    %ebx
  802327:	5e                   	pop    %esi
  802328:	5d                   	pop    %ebp
  802329:	c3                   	ret    

0080232a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80232a:	55                   	push   %ebp
  80232b:	89 e5                	mov    %esp,%ebp
  80232d:	56                   	push   %esi
  80232e:	53                   	push   %ebx
  80232f:	8b 75 08             	mov    0x8(%ebp),%esi
  802332:	8b 45 0c             	mov    0xc(%ebp),%eax
  802335:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  802338:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80233a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80233f:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  802342:	83 ec 0c             	sub    $0xc,%esp
  802345:	50                   	push   %eax
  802346:	e8 eb ed ff ff       	call   801136 <sys_ipc_recv>
  80234b:	83 c4 10             	add    $0x10,%esp
  80234e:	85 c0                	test   %eax,%eax
  802350:	79 16                	jns    802368 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  802352:	85 f6                	test   %esi,%esi
  802354:	74 06                	je     80235c <ipc_recv+0x32>
			*from_env_store = 0;
  802356:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  80235c:	85 db                	test   %ebx,%ebx
  80235e:	74 2c                	je     80238c <ipc_recv+0x62>
			*perm_store = 0;
  802360:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802366:	eb 24                	jmp    80238c <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  802368:	85 f6                	test   %esi,%esi
  80236a:	74 0a                	je     802376 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  80236c:	a1 90 67 80 00       	mov    0x806790,%eax
  802371:	8b 40 74             	mov    0x74(%eax),%eax
  802374:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  802376:	85 db                	test   %ebx,%ebx
  802378:	74 0a                	je     802384 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  80237a:	a1 90 67 80 00       	mov    0x806790,%eax
  80237f:	8b 40 78             	mov    0x78(%eax),%eax
  802382:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  802384:	a1 90 67 80 00       	mov    0x806790,%eax
  802389:	8b 40 70             	mov    0x70(%eax),%eax
}
  80238c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80238f:	5b                   	pop    %ebx
  802390:	5e                   	pop    %esi
  802391:	5d                   	pop    %ebp
  802392:	c3                   	ret    

00802393 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802393:	55                   	push   %ebp
  802394:	89 e5                	mov    %esp,%ebp
  802396:	57                   	push   %edi
  802397:	56                   	push   %esi
  802398:	53                   	push   %ebx
  802399:	83 ec 0c             	sub    $0xc,%esp
  80239c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80239f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8023a5:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8023a7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023ac:	0f 44 d8             	cmove  %eax,%ebx
  8023af:	eb 1e                	jmp    8023cf <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  8023b1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023b4:	74 14                	je     8023ca <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  8023b6:	83 ec 04             	sub    $0x4,%esp
  8023b9:	68 7c 2d 80 00       	push   $0x802d7c
  8023be:	6a 44                	push   $0x44
  8023c0:	68 a8 2d 80 00       	push   $0x802da8
  8023c5:	e8 35 e0 ff ff       	call   8003ff <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  8023ca:	e8 98 eb ff ff       	call   800f67 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8023cf:	ff 75 14             	pushl  0x14(%ebp)
  8023d2:	53                   	push   %ebx
  8023d3:	56                   	push   %esi
  8023d4:	57                   	push   %edi
  8023d5:	e8 39 ed ff ff       	call   801113 <sys_ipc_try_send>
  8023da:	83 c4 10             	add    $0x10,%esp
  8023dd:	85 c0                	test   %eax,%eax
  8023df:	78 d0                	js     8023b1 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  8023e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023e4:	5b                   	pop    %ebx
  8023e5:	5e                   	pop    %esi
  8023e6:	5f                   	pop    %edi
  8023e7:	5d                   	pop    %ebp
  8023e8:	c3                   	ret    

008023e9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023e9:	55                   	push   %ebp
  8023ea:	89 e5                	mov    %esp,%ebp
  8023ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023ef:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023f4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023f7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023fd:	8b 52 50             	mov    0x50(%edx),%edx
  802400:	39 ca                	cmp    %ecx,%edx
  802402:	75 0d                	jne    802411 <ipc_find_env+0x28>
			return envs[i].env_id;
  802404:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802407:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80240c:	8b 40 48             	mov    0x48(%eax),%eax
  80240f:	eb 0f                	jmp    802420 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802411:	83 c0 01             	add    $0x1,%eax
  802414:	3d 00 04 00 00       	cmp    $0x400,%eax
  802419:	75 d9                	jne    8023f4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80241b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802420:	5d                   	pop    %ebp
  802421:	c3                   	ret    

00802422 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802422:	55                   	push   %ebp
  802423:	89 e5                	mov    %esp,%ebp
  802425:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802428:	89 d0                	mov    %edx,%eax
  80242a:	c1 e8 16             	shr    $0x16,%eax
  80242d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802434:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802439:	f6 c1 01             	test   $0x1,%cl
  80243c:	74 1d                	je     80245b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80243e:	c1 ea 0c             	shr    $0xc,%edx
  802441:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802448:	f6 c2 01             	test   $0x1,%dl
  80244b:	74 0e                	je     80245b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80244d:	c1 ea 0c             	shr    $0xc,%edx
  802450:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802457:	ef 
  802458:	0f b7 c0             	movzwl %ax,%eax
}
  80245b:	5d                   	pop    %ebp
  80245c:	c3                   	ret    
  80245d:	66 90                	xchg   %ax,%ax
  80245f:	90                   	nop

00802460 <__udivdi3>:
  802460:	55                   	push   %ebp
  802461:	57                   	push   %edi
  802462:	56                   	push   %esi
  802463:	53                   	push   %ebx
  802464:	83 ec 1c             	sub    $0x1c,%esp
  802467:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80246b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80246f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802473:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802477:	85 f6                	test   %esi,%esi
  802479:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80247d:	89 ca                	mov    %ecx,%edx
  80247f:	89 f8                	mov    %edi,%eax
  802481:	75 3d                	jne    8024c0 <__udivdi3+0x60>
  802483:	39 cf                	cmp    %ecx,%edi
  802485:	0f 87 c5 00 00 00    	ja     802550 <__udivdi3+0xf0>
  80248b:	85 ff                	test   %edi,%edi
  80248d:	89 fd                	mov    %edi,%ebp
  80248f:	75 0b                	jne    80249c <__udivdi3+0x3c>
  802491:	b8 01 00 00 00       	mov    $0x1,%eax
  802496:	31 d2                	xor    %edx,%edx
  802498:	f7 f7                	div    %edi
  80249a:	89 c5                	mov    %eax,%ebp
  80249c:	89 c8                	mov    %ecx,%eax
  80249e:	31 d2                	xor    %edx,%edx
  8024a0:	f7 f5                	div    %ebp
  8024a2:	89 c1                	mov    %eax,%ecx
  8024a4:	89 d8                	mov    %ebx,%eax
  8024a6:	89 cf                	mov    %ecx,%edi
  8024a8:	f7 f5                	div    %ebp
  8024aa:	89 c3                	mov    %eax,%ebx
  8024ac:	89 d8                	mov    %ebx,%eax
  8024ae:	89 fa                	mov    %edi,%edx
  8024b0:	83 c4 1c             	add    $0x1c,%esp
  8024b3:	5b                   	pop    %ebx
  8024b4:	5e                   	pop    %esi
  8024b5:	5f                   	pop    %edi
  8024b6:	5d                   	pop    %ebp
  8024b7:	c3                   	ret    
  8024b8:	90                   	nop
  8024b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024c0:	39 ce                	cmp    %ecx,%esi
  8024c2:	77 74                	ja     802538 <__udivdi3+0xd8>
  8024c4:	0f bd fe             	bsr    %esi,%edi
  8024c7:	83 f7 1f             	xor    $0x1f,%edi
  8024ca:	0f 84 98 00 00 00    	je     802568 <__udivdi3+0x108>
  8024d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024d5:	89 f9                	mov    %edi,%ecx
  8024d7:	89 c5                	mov    %eax,%ebp
  8024d9:	29 fb                	sub    %edi,%ebx
  8024db:	d3 e6                	shl    %cl,%esi
  8024dd:	89 d9                	mov    %ebx,%ecx
  8024df:	d3 ed                	shr    %cl,%ebp
  8024e1:	89 f9                	mov    %edi,%ecx
  8024e3:	d3 e0                	shl    %cl,%eax
  8024e5:	09 ee                	or     %ebp,%esi
  8024e7:	89 d9                	mov    %ebx,%ecx
  8024e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024ed:	89 d5                	mov    %edx,%ebp
  8024ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024f3:	d3 ed                	shr    %cl,%ebp
  8024f5:	89 f9                	mov    %edi,%ecx
  8024f7:	d3 e2                	shl    %cl,%edx
  8024f9:	89 d9                	mov    %ebx,%ecx
  8024fb:	d3 e8                	shr    %cl,%eax
  8024fd:	09 c2                	or     %eax,%edx
  8024ff:	89 d0                	mov    %edx,%eax
  802501:	89 ea                	mov    %ebp,%edx
  802503:	f7 f6                	div    %esi
  802505:	89 d5                	mov    %edx,%ebp
  802507:	89 c3                	mov    %eax,%ebx
  802509:	f7 64 24 0c          	mull   0xc(%esp)
  80250d:	39 d5                	cmp    %edx,%ebp
  80250f:	72 10                	jb     802521 <__udivdi3+0xc1>
  802511:	8b 74 24 08          	mov    0x8(%esp),%esi
  802515:	89 f9                	mov    %edi,%ecx
  802517:	d3 e6                	shl    %cl,%esi
  802519:	39 c6                	cmp    %eax,%esi
  80251b:	73 07                	jae    802524 <__udivdi3+0xc4>
  80251d:	39 d5                	cmp    %edx,%ebp
  80251f:	75 03                	jne    802524 <__udivdi3+0xc4>
  802521:	83 eb 01             	sub    $0x1,%ebx
  802524:	31 ff                	xor    %edi,%edi
  802526:	89 d8                	mov    %ebx,%eax
  802528:	89 fa                	mov    %edi,%edx
  80252a:	83 c4 1c             	add    $0x1c,%esp
  80252d:	5b                   	pop    %ebx
  80252e:	5e                   	pop    %esi
  80252f:	5f                   	pop    %edi
  802530:	5d                   	pop    %ebp
  802531:	c3                   	ret    
  802532:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802538:	31 ff                	xor    %edi,%edi
  80253a:	31 db                	xor    %ebx,%ebx
  80253c:	89 d8                	mov    %ebx,%eax
  80253e:	89 fa                	mov    %edi,%edx
  802540:	83 c4 1c             	add    $0x1c,%esp
  802543:	5b                   	pop    %ebx
  802544:	5e                   	pop    %esi
  802545:	5f                   	pop    %edi
  802546:	5d                   	pop    %ebp
  802547:	c3                   	ret    
  802548:	90                   	nop
  802549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802550:	89 d8                	mov    %ebx,%eax
  802552:	f7 f7                	div    %edi
  802554:	31 ff                	xor    %edi,%edi
  802556:	89 c3                	mov    %eax,%ebx
  802558:	89 d8                	mov    %ebx,%eax
  80255a:	89 fa                	mov    %edi,%edx
  80255c:	83 c4 1c             	add    $0x1c,%esp
  80255f:	5b                   	pop    %ebx
  802560:	5e                   	pop    %esi
  802561:	5f                   	pop    %edi
  802562:	5d                   	pop    %ebp
  802563:	c3                   	ret    
  802564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802568:	39 ce                	cmp    %ecx,%esi
  80256a:	72 0c                	jb     802578 <__udivdi3+0x118>
  80256c:	31 db                	xor    %ebx,%ebx
  80256e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802572:	0f 87 34 ff ff ff    	ja     8024ac <__udivdi3+0x4c>
  802578:	bb 01 00 00 00       	mov    $0x1,%ebx
  80257d:	e9 2a ff ff ff       	jmp    8024ac <__udivdi3+0x4c>
  802582:	66 90                	xchg   %ax,%ax
  802584:	66 90                	xchg   %ax,%ax
  802586:	66 90                	xchg   %ax,%ax
  802588:	66 90                	xchg   %ax,%ax
  80258a:	66 90                	xchg   %ax,%ax
  80258c:	66 90                	xchg   %ax,%ax
  80258e:	66 90                	xchg   %ax,%ax

00802590 <__umoddi3>:
  802590:	55                   	push   %ebp
  802591:	57                   	push   %edi
  802592:	56                   	push   %esi
  802593:	53                   	push   %ebx
  802594:	83 ec 1c             	sub    $0x1c,%esp
  802597:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80259b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80259f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025a7:	85 d2                	test   %edx,%edx
  8025a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025b1:	89 f3                	mov    %esi,%ebx
  8025b3:	89 3c 24             	mov    %edi,(%esp)
  8025b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025ba:	75 1c                	jne    8025d8 <__umoddi3+0x48>
  8025bc:	39 f7                	cmp    %esi,%edi
  8025be:	76 50                	jbe    802610 <__umoddi3+0x80>
  8025c0:	89 c8                	mov    %ecx,%eax
  8025c2:	89 f2                	mov    %esi,%edx
  8025c4:	f7 f7                	div    %edi
  8025c6:	89 d0                	mov    %edx,%eax
  8025c8:	31 d2                	xor    %edx,%edx
  8025ca:	83 c4 1c             	add    $0x1c,%esp
  8025cd:	5b                   	pop    %ebx
  8025ce:	5e                   	pop    %esi
  8025cf:	5f                   	pop    %edi
  8025d0:	5d                   	pop    %ebp
  8025d1:	c3                   	ret    
  8025d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025d8:	39 f2                	cmp    %esi,%edx
  8025da:	89 d0                	mov    %edx,%eax
  8025dc:	77 52                	ja     802630 <__umoddi3+0xa0>
  8025de:	0f bd ea             	bsr    %edx,%ebp
  8025e1:	83 f5 1f             	xor    $0x1f,%ebp
  8025e4:	75 5a                	jne    802640 <__umoddi3+0xb0>
  8025e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025ea:	0f 82 e0 00 00 00    	jb     8026d0 <__umoddi3+0x140>
  8025f0:	39 0c 24             	cmp    %ecx,(%esp)
  8025f3:	0f 86 d7 00 00 00    	jbe    8026d0 <__umoddi3+0x140>
  8025f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802601:	83 c4 1c             	add    $0x1c,%esp
  802604:	5b                   	pop    %ebx
  802605:	5e                   	pop    %esi
  802606:	5f                   	pop    %edi
  802607:	5d                   	pop    %ebp
  802608:	c3                   	ret    
  802609:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802610:	85 ff                	test   %edi,%edi
  802612:	89 fd                	mov    %edi,%ebp
  802614:	75 0b                	jne    802621 <__umoddi3+0x91>
  802616:	b8 01 00 00 00       	mov    $0x1,%eax
  80261b:	31 d2                	xor    %edx,%edx
  80261d:	f7 f7                	div    %edi
  80261f:	89 c5                	mov    %eax,%ebp
  802621:	89 f0                	mov    %esi,%eax
  802623:	31 d2                	xor    %edx,%edx
  802625:	f7 f5                	div    %ebp
  802627:	89 c8                	mov    %ecx,%eax
  802629:	f7 f5                	div    %ebp
  80262b:	89 d0                	mov    %edx,%eax
  80262d:	eb 99                	jmp    8025c8 <__umoddi3+0x38>
  80262f:	90                   	nop
  802630:	89 c8                	mov    %ecx,%eax
  802632:	89 f2                	mov    %esi,%edx
  802634:	83 c4 1c             	add    $0x1c,%esp
  802637:	5b                   	pop    %ebx
  802638:	5e                   	pop    %esi
  802639:	5f                   	pop    %edi
  80263a:	5d                   	pop    %ebp
  80263b:	c3                   	ret    
  80263c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802640:	8b 34 24             	mov    (%esp),%esi
  802643:	bf 20 00 00 00       	mov    $0x20,%edi
  802648:	89 e9                	mov    %ebp,%ecx
  80264a:	29 ef                	sub    %ebp,%edi
  80264c:	d3 e0                	shl    %cl,%eax
  80264e:	89 f9                	mov    %edi,%ecx
  802650:	89 f2                	mov    %esi,%edx
  802652:	d3 ea                	shr    %cl,%edx
  802654:	89 e9                	mov    %ebp,%ecx
  802656:	09 c2                	or     %eax,%edx
  802658:	89 d8                	mov    %ebx,%eax
  80265a:	89 14 24             	mov    %edx,(%esp)
  80265d:	89 f2                	mov    %esi,%edx
  80265f:	d3 e2                	shl    %cl,%edx
  802661:	89 f9                	mov    %edi,%ecx
  802663:	89 54 24 04          	mov    %edx,0x4(%esp)
  802667:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80266b:	d3 e8                	shr    %cl,%eax
  80266d:	89 e9                	mov    %ebp,%ecx
  80266f:	89 c6                	mov    %eax,%esi
  802671:	d3 e3                	shl    %cl,%ebx
  802673:	89 f9                	mov    %edi,%ecx
  802675:	89 d0                	mov    %edx,%eax
  802677:	d3 e8                	shr    %cl,%eax
  802679:	89 e9                	mov    %ebp,%ecx
  80267b:	09 d8                	or     %ebx,%eax
  80267d:	89 d3                	mov    %edx,%ebx
  80267f:	89 f2                	mov    %esi,%edx
  802681:	f7 34 24             	divl   (%esp)
  802684:	89 d6                	mov    %edx,%esi
  802686:	d3 e3                	shl    %cl,%ebx
  802688:	f7 64 24 04          	mull   0x4(%esp)
  80268c:	39 d6                	cmp    %edx,%esi
  80268e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802692:	89 d1                	mov    %edx,%ecx
  802694:	89 c3                	mov    %eax,%ebx
  802696:	72 08                	jb     8026a0 <__umoddi3+0x110>
  802698:	75 11                	jne    8026ab <__umoddi3+0x11b>
  80269a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80269e:	73 0b                	jae    8026ab <__umoddi3+0x11b>
  8026a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026a4:	1b 14 24             	sbb    (%esp),%edx
  8026a7:	89 d1                	mov    %edx,%ecx
  8026a9:	89 c3                	mov    %eax,%ebx
  8026ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026af:	29 da                	sub    %ebx,%edx
  8026b1:	19 ce                	sbb    %ecx,%esi
  8026b3:	89 f9                	mov    %edi,%ecx
  8026b5:	89 f0                	mov    %esi,%eax
  8026b7:	d3 e0                	shl    %cl,%eax
  8026b9:	89 e9                	mov    %ebp,%ecx
  8026bb:	d3 ea                	shr    %cl,%edx
  8026bd:	89 e9                	mov    %ebp,%ecx
  8026bf:	d3 ee                	shr    %cl,%esi
  8026c1:	09 d0                	or     %edx,%eax
  8026c3:	89 f2                	mov    %esi,%edx
  8026c5:	83 c4 1c             	add    $0x1c,%esp
  8026c8:	5b                   	pop    %ebx
  8026c9:	5e                   	pop    %esi
  8026ca:	5f                   	pop    %edi
  8026cb:	5d                   	pop    %ebp
  8026cc:	c3                   	ret    
  8026cd:	8d 76 00             	lea    0x0(%esi),%esi
  8026d0:	29 f9                	sub    %edi,%ecx
  8026d2:	19 d6                	sbb    %edx,%esi
  8026d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026dc:	e9 18 ff ff ff       	jmp    8025f9 <__umoddi3+0x69>
