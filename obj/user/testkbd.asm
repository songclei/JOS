
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 3b 02 00 00       	call   80026c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  80003f:	e8 e3 0e 00 00       	call   800f27 <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800044:	83 eb 01             	sub    $0x1,%ebx
  800047:	75 f6                	jne    80003f <umain+0xc>
		sys_yield();

	close(0);
  800049:	83 ec 0c             	sub    $0xc,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	e8 84 12 00 00       	call   8012d7 <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 12                	jns    800071 <umain+0x3e>
		panic("opencons: %e", r);
  80005f:	50                   	push   %eax
  800060:	68 c0 21 80 00       	push   $0x8021c0
  800065:	6a 0f                	push   $0xf
  800067:	68 cd 21 80 00       	push   $0x8021cd
  80006c:	e8 5b 02 00 00       	call   8002cc <_panic>
	if (r != 0)
  800071:	85 c0                	test   %eax,%eax
  800073:	74 12                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800075:	50                   	push   %eax
  800076:	68 dc 21 80 00       	push   $0x8021dc
  80007b:	6a 11                	push   $0x11
  80007d:	68 cd 21 80 00       	push   $0x8021cd
  800082:	e8 45 02 00 00       	call   8002cc <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 94 12 00 00       	call   801327 <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 12                	jns    8000ac <umain+0x79>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 f6 21 80 00       	push   $0x8021f6
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 cd 21 80 00       	push   $0x8021cd
  8000a7:	e8 20 02 00 00       	call   8002cc <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 fe 21 80 00       	push   $0x8021fe
  8000b4:	e8 e7 08 00 00       	call   8009a0 <readline>
		if (buf != NULL)
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	74 15                	je     8000d5 <umain+0xa2>
			fprintf(1, "%s\n", buf);
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	50                   	push   %eax
  8000c4:	68 0c 22 80 00       	push   $0x80220c
  8000c9:	6a 01                	push   $0x1
  8000cb:	e8 9d 19 00 00       	call   801a6d <fprintf>
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	eb d7                	jmp    8000ac <umain+0x79>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 10 22 80 00       	push   $0x802210
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 89 19 00 00       	call   801a6d <fprintf>
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	eb c3                	jmp    8000ac <umain+0x79>

008000e9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8000ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000f9:	68 28 22 80 00       	push   $0x802228
  8000fe:	ff 75 0c             	pushl  0xc(%ebp)
  800101:	e8 c6 09 00 00       	call   800acc <strcpy>
	return 0;
}
  800106:	b8 00 00 00 00       	mov    $0x0,%eax
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800119:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80011e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800124:	eb 2d                	jmp    800153 <devcons_write+0x46>
		m = n - tot;
  800126:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800129:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80012b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80012e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800133:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800136:	83 ec 04             	sub    $0x4,%esp
  800139:	53                   	push   %ebx
  80013a:	03 45 0c             	add    0xc(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	57                   	push   %edi
  80013f:	e8 1a 0b 00 00       	call   800c5e <memmove>
		sys_cputs(buf, m);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	53                   	push   %ebx
  800148:	57                   	push   %edi
  800149:	e8 3c 0d 00 00       	call   800e8a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80014e:	01 de                	add    %ebx,%esi
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	89 f0                	mov    %esi,%eax
  800155:	3b 75 10             	cmp    0x10(%ebp),%esi
  800158:	72 cc                	jb     800126 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80015a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 08             	sub    $0x8,%esp
  800168:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80016d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800171:	74 2a                	je     80019d <devcons_read+0x3b>
  800173:	eb 05                	jmp    80017a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800175:	e8 ad 0d 00 00       	call   800f27 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80017a:	e8 29 0d 00 00       	call   800ea8 <sys_cgetc>
  80017f:	85 c0                	test   %eax,%eax
  800181:	74 f2                	je     800175 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	78 16                	js     80019d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800187:	83 f8 04             	cmp    $0x4,%eax
  80018a:	74 0c                	je     800198 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80018c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018f:	88 02                	mov    %al,(%edx)
	return 1;
  800191:	b8 01 00 00 00       	mov    $0x1,%eax
  800196:	eb 05                	jmp    80019d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800198:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    

0080019f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8001a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001ab:	6a 01                	push   $0x1
  8001ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 d4 0c 00 00       	call   800e8a <sys_cputs>
}
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <getchar>:

int
getchar(void)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8001c1:	6a 01                	push   $0x1
  8001c3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	6a 00                	push   $0x0
  8001c9:	e8 45 12 00 00       	call   801413 <read>
	if (r < 0)
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	85 c0                	test   %eax,%eax
  8001d3:	78 0f                	js     8001e4 <getchar+0x29>
		return r;
	if (r < 1)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7e 06                	jle    8001df <getchar+0x24>
		return -E_EOF;
	return c;
  8001d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8001dd:	eb 05                	jmp    8001e4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8001df:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8001ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	e8 b5 0f 00 00       	call   8011ad <fd_lookup>
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	78 11                	js     800210 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8001ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800202:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800208:	39 10                	cmp    %edx,(%eax)
  80020a:	0f 94 c0             	sete   %al
  80020d:	0f b6 c0             	movzbl %al,%eax
}
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <opencons>:

int
opencons(void)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 3d 0f 00 00       	call   80115e <fd_alloc>
  800221:	83 c4 10             	add    $0x10,%esp
		return r;
  800224:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800226:	85 c0                	test   %eax,%eax
  800228:	78 3e                	js     800268 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	68 07 04 00 00       	push   $0x407
  800232:	ff 75 f4             	pushl  -0xc(%ebp)
  800235:	6a 00                	push   $0x0
  800237:	e8 0a 0d 00 00       	call   800f46 <sys_page_alloc>
  80023c:	83 c4 10             	add    $0x10,%esp
		return r;
  80023f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	78 23                	js     800268 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800245:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80024b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80024e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800250:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800253:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	e8 d4 0e 00 00       	call   801137 <fd2num>
  800263:	89 c2                	mov    %eax,%edx
  800265:	83 c4 10             	add    $0x10,%esp
}
  800268:	89 d0                	mov    %edx,%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800274:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800277:	e8 8c 0c 00 00       	call   800f08 <sys_getenvid>
  80027c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800281:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800284:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800289:	a3 24 44 80 00       	mov    %eax,0x804424
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80028e:	85 db                	test   %ebx,%ebx
  800290:	7e 07                	jle    800299 <libmain+0x2d>
		binaryname = argv[0];
  800292:	8b 06                	mov    (%esi),%eax
  800294:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	e8 90 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002a3:	e8 0a 00 00 00       	call   8002b2 <exit>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002b8:	e8 45 10 00 00       	call   801302 <close_all>
	sys_env_destroy(0);
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	6a 00                	push   $0x0
  8002c2:	e8 00 0c 00 00       	call   800ec7 <sys_env_destroy>
}
  8002c7:	83 c4 10             	add    $0x10,%esp
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d4:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002da:	e8 29 0c 00 00       	call   800f08 <sys_getenvid>
  8002df:	83 ec 0c             	sub    $0xc,%esp
  8002e2:	ff 75 0c             	pushl  0xc(%ebp)
  8002e5:	ff 75 08             	pushl  0x8(%ebp)
  8002e8:	56                   	push   %esi
  8002e9:	50                   	push   %eax
  8002ea:	68 40 22 80 00       	push   $0x802240
  8002ef:	e8 b1 00 00 00       	call   8003a5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	53                   	push   %ebx
  8002f8:	ff 75 10             	pushl  0x10(%ebp)
  8002fb:	e8 54 00 00 00       	call   800354 <vcprintf>
	cprintf("\n");
  800300:	c7 04 24 26 22 80 00 	movl   $0x802226,(%esp)
  800307:	e8 99 00 00 00       	call   8003a5 <cprintf>
  80030c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80030f:	cc                   	int3   
  800310:	eb fd                	jmp    80030f <_panic+0x43>

00800312 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	53                   	push   %ebx
  800316:	83 ec 04             	sub    $0x4,%esp
  800319:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80031c:	8b 13                	mov    (%ebx),%edx
  80031e:	8d 42 01             	lea    0x1(%edx),%eax
  800321:	89 03                	mov    %eax,(%ebx)
  800323:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800326:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80032a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80032f:	75 1a                	jne    80034b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	68 ff 00 00 00       	push   $0xff
  800339:	8d 43 08             	lea    0x8(%ebx),%eax
  80033c:	50                   	push   %eax
  80033d:	e8 48 0b 00 00       	call   800e8a <sys_cputs>
		b->idx = 0;
  800342:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800348:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80034b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80034f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80035d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800364:	00 00 00 
	b.cnt = 0;
  800367:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80036e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800371:	ff 75 0c             	pushl  0xc(%ebp)
  800374:	ff 75 08             	pushl  0x8(%ebp)
  800377:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80037d:	50                   	push   %eax
  80037e:	68 12 03 80 00       	push   $0x800312
  800383:	e8 54 01 00 00       	call   8004dc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800388:	83 c4 08             	add    $0x8,%esp
  80038b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800391:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800397:	50                   	push   %eax
  800398:	e8 ed 0a 00 00       	call   800e8a <sys_cputs>

	return b.cnt;
}
  80039d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a3:	c9                   	leave  
  8003a4:	c3                   	ret    

008003a5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ab:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ae:	50                   	push   %eax
  8003af:	ff 75 08             	pushl  0x8(%ebp)
  8003b2:	e8 9d ff ff ff       	call   800354 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    

008003b9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	57                   	push   %edi
  8003bd:	56                   	push   %esi
  8003be:	53                   	push   %ebx
  8003bf:	83 ec 1c             	sub    $0x1c,%esp
  8003c2:	89 c7                	mov    %eax,%edi
  8003c4:	89 d6                	mov    %edx,%esi
  8003c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003da:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003dd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003e0:	39 d3                	cmp    %edx,%ebx
  8003e2:	72 05                	jb     8003e9 <printnum+0x30>
  8003e4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003e7:	77 45                	ja     80042e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003e9:	83 ec 0c             	sub    $0xc,%esp
  8003ec:	ff 75 18             	pushl  0x18(%ebp)
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003f5:	53                   	push   %ebx
  8003f6:	ff 75 10             	pushl  0x10(%ebp)
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800402:	ff 75 dc             	pushl  -0x24(%ebp)
  800405:	ff 75 d8             	pushl  -0x28(%ebp)
  800408:	e8 23 1b 00 00       	call   801f30 <__udivdi3>
  80040d:	83 c4 18             	add    $0x18,%esp
  800410:	52                   	push   %edx
  800411:	50                   	push   %eax
  800412:	89 f2                	mov    %esi,%edx
  800414:	89 f8                	mov    %edi,%eax
  800416:	e8 9e ff ff ff       	call   8003b9 <printnum>
  80041b:	83 c4 20             	add    $0x20,%esp
  80041e:	eb 18                	jmp    800438 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	56                   	push   %esi
  800424:	ff 75 18             	pushl  0x18(%ebp)
  800427:	ff d7                	call   *%edi
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	eb 03                	jmp    800431 <printnum+0x78>
  80042e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800431:	83 eb 01             	sub    $0x1,%ebx
  800434:	85 db                	test   %ebx,%ebx
  800436:	7f e8                	jg     800420 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	56                   	push   %esi
  80043c:	83 ec 04             	sub    $0x4,%esp
  80043f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800442:	ff 75 e0             	pushl  -0x20(%ebp)
  800445:	ff 75 dc             	pushl  -0x24(%ebp)
  800448:	ff 75 d8             	pushl  -0x28(%ebp)
  80044b:	e8 10 1c 00 00       	call   802060 <__umoddi3>
  800450:	83 c4 14             	add    $0x14,%esp
  800453:	0f be 80 63 22 80 00 	movsbl 0x802263(%eax),%eax
  80045a:	50                   	push   %eax
  80045b:	ff d7                	call   *%edi
}
  80045d:	83 c4 10             	add    $0x10,%esp
  800460:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800463:	5b                   	pop    %ebx
  800464:	5e                   	pop    %esi
  800465:	5f                   	pop    %edi
  800466:	5d                   	pop    %ebp
  800467:	c3                   	ret    

00800468 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80046b:	83 fa 01             	cmp    $0x1,%edx
  80046e:	7e 0e                	jle    80047e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800470:	8b 10                	mov    (%eax),%edx
  800472:	8d 4a 08             	lea    0x8(%edx),%ecx
  800475:	89 08                	mov    %ecx,(%eax)
  800477:	8b 02                	mov    (%edx),%eax
  800479:	8b 52 04             	mov    0x4(%edx),%edx
  80047c:	eb 22                	jmp    8004a0 <getuint+0x38>
	else if (lflag)
  80047e:	85 d2                	test   %edx,%edx
  800480:	74 10                	je     800492 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800482:	8b 10                	mov    (%eax),%edx
  800484:	8d 4a 04             	lea    0x4(%edx),%ecx
  800487:	89 08                	mov    %ecx,(%eax)
  800489:	8b 02                	mov    (%edx),%eax
  80048b:	ba 00 00 00 00       	mov    $0x0,%edx
  800490:	eb 0e                	jmp    8004a0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800492:	8b 10                	mov    (%eax),%edx
  800494:	8d 4a 04             	lea    0x4(%edx),%ecx
  800497:	89 08                	mov    %ecx,(%eax)
  800499:	8b 02                	mov    (%edx),%eax
  80049b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004a0:	5d                   	pop    %ebp
  8004a1:	c3                   	ret    

008004a2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a2:	55                   	push   %ebp
  8004a3:	89 e5                	mov    %esp,%ebp
  8004a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ac:	8b 10                	mov    (%eax),%edx
  8004ae:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b1:	73 0a                	jae    8004bd <sprintputch+0x1b>
		*b->buf++ = ch;
  8004b3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b6:	89 08                	mov    %ecx,(%eax)
  8004b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bb:	88 02                	mov    %al,(%edx)
}
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    

008004bf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
  8004c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004c5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c8:	50                   	push   %eax
  8004c9:	ff 75 10             	pushl  0x10(%ebp)
  8004cc:	ff 75 0c             	pushl  0xc(%ebp)
  8004cf:	ff 75 08             	pushl  0x8(%ebp)
  8004d2:	e8 05 00 00 00       	call   8004dc <vprintfmt>
	va_end(ap);
}
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	c9                   	leave  
  8004db:	c3                   	ret    

008004dc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	57                   	push   %edi
  8004e0:	56                   	push   %esi
  8004e1:	53                   	push   %ebx
  8004e2:	83 ec 2c             	sub    $0x2c,%esp
  8004e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004eb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ee:	eb 12                	jmp    800502 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	0f 84 38 04 00 00    	je     800930 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	53                   	push   %ebx
  8004fc:	50                   	push   %eax
  8004fd:	ff d6                	call   *%esi
  8004ff:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800502:	83 c7 01             	add    $0x1,%edi
  800505:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800509:	83 f8 25             	cmp    $0x25,%eax
  80050c:	75 e2                	jne    8004f0 <vprintfmt+0x14>
  80050e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800512:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800519:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800520:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800527:	ba 00 00 00 00       	mov    $0x0,%edx
  80052c:	eb 07                	jmp    800535 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  800531:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800535:	8d 47 01             	lea    0x1(%edi),%eax
  800538:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80053b:	0f b6 07             	movzbl (%edi),%eax
  80053e:	0f b6 c8             	movzbl %al,%ecx
  800541:	83 e8 23             	sub    $0x23,%eax
  800544:	3c 55                	cmp    $0x55,%al
  800546:	0f 87 c9 03 00 00    	ja     800915 <vprintfmt+0x439>
  80054c:	0f b6 c0             	movzbl %al,%eax
  80054f:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800559:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80055d:	eb d6                	jmp    800535 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  80055f:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  800566:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800569:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  80056c:	eb 94                	jmp    800502 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  80056e:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  800575:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800578:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  80057b:	eb 85                	jmp    800502 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  80057d:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  800584:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  80058a:	e9 73 ff ff ff       	jmp    800502 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  80058f:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  800596:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800599:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  80059c:	e9 61 ff ff ff       	jmp    800502 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  8005a1:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  8005a8:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  8005ae:	e9 4f ff ff ff       	jmp    800502 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  8005b3:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  8005ba:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  8005c0:	e9 3d ff ff ff       	jmp    800502 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  8005c5:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  8005cc:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  8005d2:	e9 2b ff ff ff       	jmp    800502 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  8005d7:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  8005de:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8005e4:	e9 19 ff ff ff       	jmp    800502 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  8005e9:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  8005f0:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8005f6:	e9 07 ff ff ff       	jmp    800502 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8005fb:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  800602:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800605:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800608:	e9 f5 fe ff ff       	jmp    800502 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800610:	b8 00 00 00 00       	mov    $0x0,%eax
  800615:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800618:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80061b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80061f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800622:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800625:	83 fa 09             	cmp    $0x9,%edx
  800628:	77 3f                	ja     800669 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80062a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80062d:	eb e9                	jmp    800618 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8d 48 04             	lea    0x4(%eax),%ecx
  800635:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800638:	8b 00                	mov    (%eax),%eax
  80063a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800640:	eb 2d                	jmp    80066f <vprintfmt+0x193>
  800642:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800645:	85 c0                	test   %eax,%eax
  800647:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064c:	0f 49 c8             	cmovns %eax,%ecx
  80064f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800655:	e9 db fe ff ff       	jmp    800535 <vprintfmt+0x59>
  80065a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80065d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800664:	e9 cc fe ff ff       	jmp    800535 <vprintfmt+0x59>
  800669:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80066f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800673:	0f 89 bc fe ff ff    	jns    800535 <vprintfmt+0x59>
				width = precision, precision = -1;
  800679:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80067c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80067f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800686:	e9 aa fe ff ff       	jmp    800535 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80068b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800691:	e9 9f fe ff ff       	jmp    800535 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8d 50 04             	lea    0x4(%eax),%edx
  80069c:	89 55 14             	mov    %edx,0x14(%ebp)
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	ff 30                	pushl  (%eax)
  8006a5:	ff d6                	call   *%esi
			break;
  8006a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006ad:	e9 50 fe ff ff       	jmp    800502 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 50 04             	lea    0x4(%eax),%edx
  8006b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bb:	8b 00                	mov    (%eax),%eax
  8006bd:	99                   	cltd   
  8006be:	31 d0                	xor    %edx,%eax
  8006c0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006c2:	83 f8 0f             	cmp    $0xf,%eax
  8006c5:	7f 0b                	jg     8006d2 <vprintfmt+0x1f6>
  8006c7:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  8006ce:	85 d2                	test   %edx,%edx
  8006d0:	75 18                	jne    8006ea <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  8006d2:	50                   	push   %eax
  8006d3:	68 7b 22 80 00       	push   $0x80227b
  8006d8:	53                   	push   %ebx
  8006d9:	56                   	push   %esi
  8006da:	e8 e0 fd ff ff       	call   8004bf <printfmt>
  8006df:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006e5:	e9 18 fe ff ff       	jmp    800502 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006ea:	52                   	push   %edx
  8006eb:	68 41 26 80 00       	push   $0x802641
  8006f0:	53                   	push   %ebx
  8006f1:	56                   	push   %esi
  8006f2:	e8 c8 fd ff ff       	call   8004bf <printfmt>
  8006f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006fd:	e9 00 fe ff ff       	jmp    800502 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8d 50 04             	lea    0x4(%eax),%edx
  800708:	89 55 14             	mov    %edx,0x14(%ebp)
  80070b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80070d:	85 ff                	test   %edi,%edi
  80070f:	b8 74 22 80 00       	mov    $0x802274,%eax
  800714:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800717:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80071b:	0f 8e 94 00 00 00    	jle    8007b5 <vprintfmt+0x2d9>
  800721:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800725:	0f 84 98 00 00 00    	je     8007c3 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  80072b:	83 ec 08             	sub    $0x8,%esp
  80072e:	ff 75 d0             	pushl  -0x30(%ebp)
  800731:	57                   	push   %edi
  800732:	e8 74 03 00 00       	call   800aab <strnlen>
  800737:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80073a:	29 c1                	sub    %eax,%ecx
  80073c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80073f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800742:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800746:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800749:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80074c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80074e:	eb 0f                	jmp    80075f <vprintfmt+0x283>
					putch(padc, putdat);
  800750:	83 ec 08             	sub    $0x8,%esp
  800753:	53                   	push   %ebx
  800754:	ff 75 e0             	pushl  -0x20(%ebp)
  800757:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800759:	83 ef 01             	sub    $0x1,%edi
  80075c:	83 c4 10             	add    $0x10,%esp
  80075f:	85 ff                	test   %edi,%edi
  800761:	7f ed                	jg     800750 <vprintfmt+0x274>
  800763:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800766:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800769:	85 c9                	test   %ecx,%ecx
  80076b:	b8 00 00 00 00       	mov    $0x0,%eax
  800770:	0f 49 c1             	cmovns %ecx,%eax
  800773:	29 c1                	sub    %eax,%ecx
  800775:	89 75 08             	mov    %esi,0x8(%ebp)
  800778:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80077b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80077e:	89 cb                	mov    %ecx,%ebx
  800780:	eb 4d                	jmp    8007cf <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800782:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800786:	74 1b                	je     8007a3 <vprintfmt+0x2c7>
  800788:	0f be c0             	movsbl %al,%eax
  80078b:	83 e8 20             	sub    $0x20,%eax
  80078e:	83 f8 5e             	cmp    $0x5e,%eax
  800791:	76 10                	jbe    8007a3 <vprintfmt+0x2c7>
					putch('?', putdat);
  800793:	83 ec 08             	sub    $0x8,%esp
  800796:	ff 75 0c             	pushl  0xc(%ebp)
  800799:	6a 3f                	push   $0x3f
  80079b:	ff 55 08             	call   *0x8(%ebp)
  80079e:	83 c4 10             	add    $0x10,%esp
  8007a1:	eb 0d                	jmp    8007b0 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	ff 75 0c             	pushl  0xc(%ebp)
  8007a9:	52                   	push   %edx
  8007aa:	ff 55 08             	call   *0x8(%ebp)
  8007ad:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007b0:	83 eb 01             	sub    $0x1,%ebx
  8007b3:	eb 1a                	jmp    8007cf <vprintfmt+0x2f3>
  8007b5:	89 75 08             	mov    %esi,0x8(%ebp)
  8007b8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007bb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007be:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007c1:	eb 0c                	jmp    8007cf <vprintfmt+0x2f3>
  8007c3:	89 75 08             	mov    %esi,0x8(%ebp)
  8007c6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007c9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007cc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007cf:	83 c7 01             	add    $0x1,%edi
  8007d2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007d6:	0f be d0             	movsbl %al,%edx
  8007d9:	85 d2                	test   %edx,%edx
  8007db:	74 23                	je     800800 <vprintfmt+0x324>
  8007dd:	85 f6                	test   %esi,%esi
  8007df:	78 a1                	js     800782 <vprintfmt+0x2a6>
  8007e1:	83 ee 01             	sub    $0x1,%esi
  8007e4:	79 9c                	jns    800782 <vprintfmt+0x2a6>
  8007e6:	89 df                	mov    %ebx,%edi
  8007e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ee:	eb 18                	jmp    800808 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007f0:	83 ec 08             	sub    $0x8,%esp
  8007f3:	53                   	push   %ebx
  8007f4:	6a 20                	push   $0x20
  8007f6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007f8:	83 ef 01             	sub    $0x1,%edi
  8007fb:	83 c4 10             	add    $0x10,%esp
  8007fe:	eb 08                	jmp    800808 <vprintfmt+0x32c>
  800800:	89 df                	mov    %ebx,%edi
  800802:	8b 75 08             	mov    0x8(%ebp),%esi
  800805:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800808:	85 ff                	test   %edi,%edi
  80080a:	7f e4                	jg     8007f0 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80080f:	e9 ee fc ff ff       	jmp    800502 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800814:	83 fa 01             	cmp    $0x1,%edx
  800817:	7e 16                	jle    80082f <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800819:	8b 45 14             	mov    0x14(%ebp),%eax
  80081c:	8d 50 08             	lea    0x8(%eax),%edx
  80081f:	89 55 14             	mov    %edx,0x14(%ebp)
  800822:	8b 50 04             	mov    0x4(%eax),%edx
  800825:	8b 00                	mov    (%eax),%eax
  800827:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80082a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80082d:	eb 32                	jmp    800861 <vprintfmt+0x385>
	else if (lflag)
  80082f:	85 d2                	test   %edx,%edx
  800831:	74 18                	je     80084b <vprintfmt+0x36f>
		return va_arg(*ap, long);
  800833:	8b 45 14             	mov    0x14(%ebp),%eax
  800836:	8d 50 04             	lea    0x4(%eax),%edx
  800839:	89 55 14             	mov    %edx,0x14(%ebp)
  80083c:	8b 00                	mov    (%eax),%eax
  80083e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800841:	89 c1                	mov    %eax,%ecx
  800843:	c1 f9 1f             	sar    $0x1f,%ecx
  800846:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800849:	eb 16                	jmp    800861 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  80084b:	8b 45 14             	mov    0x14(%ebp),%eax
  80084e:	8d 50 04             	lea    0x4(%eax),%edx
  800851:	89 55 14             	mov    %edx,0x14(%ebp)
  800854:	8b 00                	mov    (%eax),%eax
  800856:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800859:	89 c1                	mov    %eax,%ecx
  80085b:	c1 f9 1f             	sar    $0x1f,%ecx
  80085e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800861:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800864:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800867:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80086c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800870:	79 6f                	jns    8008e1 <vprintfmt+0x405>
				putch('-', putdat);
  800872:	83 ec 08             	sub    $0x8,%esp
  800875:	53                   	push   %ebx
  800876:	6a 2d                	push   $0x2d
  800878:	ff d6                	call   *%esi
				num = -(long long) num;
  80087a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80087d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800880:	f7 d8                	neg    %eax
  800882:	83 d2 00             	adc    $0x0,%edx
  800885:	f7 da                	neg    %edx
  800887:	83 c4 10             	add    $0x10,%esp
  80088a:	eb 55                	jmp    8008e1 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80088c:	8d 45 14             	lea    0x14(%ebp),%eax
  80088f:	e8 d4 fb ff ff       	call   800468 <getuint>
			base = 10;
  800894:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800899:	eb 46                	jmp    8008e1 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80089b:	8d 45 14             	lea    0x14(%ebp),%eax
  80089e:	e8 c5 fb ff ff       	call   800468 <getuint>
			base = 8;
  8008a3:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8008a8:	eb 37                	jmp    8008e1 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  8008aa:	83 ec 08             	sub    $0x8,%esp
  8008ad:	53                   	push   %ebx
  8008ae:	6a 30                	push   $0x30
  8008b0:	ff d6                	call   *%esi
			putch('x', putdat);
  8008b2:	83 c4 08             	add    $0x8,%esp
  8008b5:	53                   	push   %ebx
  8008b6:	6a 78                	push   $0x78
  8008b8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bd:	8d 50 04             	lea    0x4(%eax),%edx
  8008c0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008c3:	8b 00                	mov    (%eax),%eax
  8008c5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008ca:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008cd:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8008d2:	eb 0d                	jmp    8008e1 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008d4:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d7:	e8 8c fb ff ff       	call   800468 <getuint>
			base = 16;
  8008dc:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008e1:	83 ec 0c             	sub    $0xc,%esp
  8008e4:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8008e8:	51                   	push   %ecx
  8008e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8008ec:	57                   	push   %edi
  8008ed:	52                   	push   %edx
  8008ee:	50                   	push   %eax
  8008ef:	89 da                	mov    %ebx,%edx
  8008f1:	89 f0                	mov    %esi,%eax
  8008f3:	e8 c1 fa ff ff       	call   8003b9 <printnum>
			break;
  8008f8:	83 c4 20             	add    $0x20,%esp
  8008fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008fe:	e9 ff fb ff ff       	jmp    800502 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800903:	83 ec 08             	sub    $0x8,%esp
  800906:	53                   	push   %ebx
  800907:	51                   	push   %ecx
  800908:	ff d6                	call   *%esi
			break;
  80090a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800910:	e9 ed fb ff ff       	jmp    800502 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800915:	83 ec 08             	sub    $0x8,%esp
  800918:	53                   	push   %ebx
  800919:	6a 25                	push   $0x25
  80091b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80091d:	83 c4 10             	add    $0x10,%esp
  800920:	eb 03                	jmp    800925 <vprintfmt+0x449>
  800922:	83 ef 01             	sub    $0x1,%edi
  800925:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800929:	75 f7                	jne    800922 <vprintfmt+0x446>
  80092b:	e9 d2 fb ff ff       	jmp    800502 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800930:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800933:	5b                   	pop    %ebx
  800934:	5e                   	pop    %esi
  800935:	5f                   	pop    %edi
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	83 ec 18             	sub    $0x18,%esp
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800944:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800947:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80094b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80094e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800955:	85 c0                	test   %eax,%eax
  800957:	74 26                	je     80097f <vsnprintf+0x47>
  800959:	85 d2                	test   %edx,%edx
  80095b:	7e 22                	jle    80097f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80095d:	ff 75 14             	pushl  0x14(%ebp)
  800960:	ff 75 10             	pushl  0x10(%ebp)
  800963:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800966:	50                   	push   %eax
  800967:	68 a2 04 80 00       	push   $0x8004a2
  80096c:	e8 6b fb ff ff       	call   8004dc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800971:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800974:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800977:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80097a:	83 c4 10             	add    $0x10,%esp
  80097d:	eb 05                	jmp    800984 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80097f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800984:	c9                   	leave  
  800985:	c3                   	ret    

00800986 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80098c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80098f:	50                   	push   %eax
  800990:	ff 75 10             	pushl  0x10(%ebp)
  800993:	ff 75 0c             	pushl  0xc(%ebp)
  800996:	ff 75 08             	pushl  0x8(%ebp)
  800999:	e8 9a ff ff ff       	call   800938 <vsnprintf>
	va_end(ap);

	return rc;
}
  80099e:	c9                   	leave  
  80099f:	c3                   	ret    

008009a0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	57                   	push   %edi
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
  8009a6:	83 ec 0c             	sub    $0xc,%esp
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8009ac:	85 c0                	test   %eax,%eax
  8009ae:	74 13                	je     8009c3 <readline+0x23>
		fprintf(1, "%s", prompt);
  8009b0:	83 ec 04             	sub    $0x4,%esp
  8009b3:	50                   	push   %eax
  8009b4:	68 41 26 80 00       	push   $0x802641
  8009b9:	6a 01                	push   $0x1
  8009bb:	e8 ad 10 00 00       	call   801a6d <fprintf>
  8009c0:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  8009c3:	83 ec 0c             	sub    $0xc,%esp
  8009c6:	6a 00                	push   $0x0
  8009c8:	e8 19 f8 ff ff       	call   8001e6 <iscons>
  8009cd:	89 c7                	mov    %eax,%edi
  8009cf:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8009d2:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8009d7:	e8 df f7 ff ff       	call   8001bb <getchar>
  8009dc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8009de:	85 c0                	test   %eax,%eax
  8009e0:	79 29                	jns    800a0b <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  8009e7:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8009ea:	0f 84 9b 00 00 00    	je     800a8b <readline+0xeb>
				cprintf("read error: %e\n", c);
  8009f0:	83 ec 08             	sub    $0x8,%esp
  8009f3:	53                   	push   %ebx
  8009f4:	68 5f 25 80 00       	push   $0x80255f
  8009f9:	e8 a7 f9 ff ff       	call   8003a5 <cprintf>
  8009fe:	83 c4 10             	add    $0x10,%esp
			return NULL;
  800a01:	b8 00 00 00 00       	mov    $0x0,%eax
  800a06:	e9 80 00 00 00       	jmp    800a8b <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800a0b:	83 f8 08             	cmp    $0x8,%eax
  800a0e:	0f 94 c2             	sete   %dl
  800a11:	83 f8 7f             	cmp    $0x7f,%eax
  800a14:	0f 94 c0             	sete   %al
  800a17:	08 c2                	or     %al,%dl
  800a19:	74 1a                	je     800a35 <readline+0x95>
  800a1b:	85 f6                	test   %esi,%esi
  800a1d:	7e 16                	jle    800a35 <readline+0x95>
			if (echoing)
  800a1f:	85 ff                	test   %edi,%edi
  800a21:	74 0d                	je     800a30 <readline+0x90>
				cputchar('\b');
  800a23:	83 ec 0c             	sub    $0xc,%esp
  800a26:	6a 08                	push   $0x8
  800a28:	e8 72 f7 ff ff       	call   80019f <cputchar>
  800a2d:	83 c4 10             	add    $0x10,%esp
			i--;
  800a30:	83 ee 01             	sub    $0x1,%esi
  800a33:	eb a2                	jmp    8009d7 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800a35:	83 fb 1f             	cmp    $0x1f,%ebx
  800a38:	7e 26                	jle    800a60 <readline+0xc0>
  800a3a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800a40:	7f 1e                	jg     800a60 <readline+0xc0>
			if (echoing)
  800a42:	85 ff                	test   %edi,%edi
  800a44:	74 0c                	je     800a52 <readline+0xb2>
				cputchar(c);
  800a46:	83 ec 0c             	sub    $0xc,%esp
  800a49:	53                   	push   %ebx
  800a4a:	e8 50 f7 ff ff       	call   80019f <cputchar>
  800a4f:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  800a52:	88 9e 20 40 80 00    	mov    %bl,0x804020(%esi)
  800a58:	8d 76 01             	lea    0x1(%esi),%esi
  800a5b:	e9 77 ff ff ff       	jmp    8009d7 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  800a60:	83 fb 0a             	cmp    $0xa,%ebx
  800a63:	74 09                	je     800a6e <readline+0xce>
  800a65:	83 fb 0d             	cmp    $0xd,%ebx
  800a68:	0f 85 69 ff ff ff    	jne    8009d7 <readline+0x37>
			if (echoing)
  800a6e:	85 ff                	test   %edi,%edi
  800a70:	74 0d                	je     800a7f <readline+0xdf>
				cputchar('\n');
  800a72:	83 ec 0c             	sub    $0xc,%esp
  800a75:	6a 0a                	push   $0xa
  800a77:	e8 23 f7 ff ff       	call   80019f <cputchar>
  800a7c:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  800a7f:	c6 86 20 40 80 00 00 	movb   $0x0,0x804020(%esi)
			return buf;
  800a86:	b8 20 40 80 00       	mov    $0x804020,%eax
		}
	}
}
  800a8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a8e:	5b                   	pop    %ebx
  800a8f:	5e                   	pop    %esi
  800a90:	5f                   	pop    %edi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a99:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9e:	eb 03                	jmp    800aa3 <strlen+0x10>
		n++;
  800aa0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800aa3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800aa7:	75 f7                	jne    800aa0 <strlen+0xd>
		n++;
	return n;
}
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ab4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab9:	eb 03                	jmp    800abe <strnlen+0x13>
		n++;
  800abb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800abe:	39 c2                	cmp    %eax,%edx
  800ac0:	74 08                	je     800aca <strnlen+0x1f>
  800ac2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800ac6:	75 f3                	jne    800abb <strnlen+0x10>
  800ac8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	53                   	push   %ebx
  800ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ad6:	89 c2                	mov    %eax,%edx
  800ad8:	83 c2 01             	add    $0x1,%edx
  800adb:	83 c1 01             	add    $0x1,%ecx
  800ade:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ae2:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ae5:	84 db                	test   %bl,%bl
  800ae7:	75 ef                	jne    800ad8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	53                   	push   %ebx
  800af0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800af3:	53                   	push   %ebx
  800af4:	e8 9a ff ff ff       	call   800a93 <strlen>
  800af9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800afc:	ff 75 0c             	pushl  0xc(%ebp)
  800aff:	01 d8                	add    %ebx,%eax
  800b01:	50                   	push   %eax
  800b02:	e8 c5 ff ff ff       	call   800acc <strcpy>
	return dst;
}
  800b07:	89 d8                	mov    %ebx,%eax
  800b09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b0c:	c9                   	leave  
  800b0d:	c3                   	ret    

00800b0e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
  800b13:	8b 75 08             	mov    0x8(%ebp),%esi
  800b16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b19:	89 f3                	mov    %esi,%ebx
  800b1b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b1e:	89 f2                	mov    %esi,%edx
  800b20:	eb 0f                	jmp    800b31 <strncpy+0x23>
		*dst++ = *src;
  800b22:	83 c2 01             	add    $0x1,%edx
  800b25:	0f b6 01             	movzbl (%ecx),%eax
  800b28:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b2b:	80 39 01             	cmpb   $0x1,(%ecx)
  800b2e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b31:	39 da                	cmp    %ebx,%edx
  800b33:	75 ed                	jne    800b22 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b35:	89 f0                	mov    %esi,%eax
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
  800b40:	8b 75 08             	mov    0x8(%ebp),%esi
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b46:	8b 55 10             	mov    0x10(%ebp),%edx
  800b49:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b4b:	85 d2                	test   %edx,%edx
  800b4d:	74 21                	je     800b70 <strlcpy+0x35>
  800b4f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b53:	89 f2                	mov    %esi,%edx
  800b55:	eb 09                	jmp    800b60 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b57:	83 c2 01             	add    $0x1,%edx
  800b5a:	83 c1 01             	add    $0x1,%ecx
  800b5d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b60:	39 c2                	cmp    %eax,%edx
  800b62:	74 09                	je     800b6d <strlcpy+0x32>
  800b64:	0f b6 19             	movzbl (%ecx),%ebx
  800b67:	84 db                	test   %bl,%bl
  800b69:	75 ec                	jne    800b57 <strlcpy+0x1c>
  800b6b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b6d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b70:	29 f0                	sub    %esi,%eax
}
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b7f:	eb 06                	jmp    800b87 <strcmp+0x11>
		p++, q++;
  800b81:	83 c1 01             	add    $0x1,%ecx
  800b84:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b87:	0f b6 01             	movzbl (%ecx),%eax
  800b8a:	84 c0                	test   %al,%al
  800b8c:	74 04                	je     800b92 <strcmp+0x1c>
  800b8e:	3a 02                	cmp    (%edx),%al
  800b90:	74 ef                	je     800b81 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b92:	0f b6 c0             	movzbl %al,%eax
  800b95:	0f b6 12             	movzbl (%edx),%edx
  800b98:	29 d0                	sub    %edx,%eax
}
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	53                   	push   %ebx
  800ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba6:	89 c3                	mov    %eax,%ebx
  800ba8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800bab:	eb 06                	jmp    800bb3 <strncmp+0x17>
		n--, p++, q++;
  800bad:	83 c0 01             	add    $0x1,%eax
  800bb0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bb3:	39 d8                	cmp    %ebx,%eax
  800bb5:	74 15                	je     800bcc <strncmp+0x30>
  800bb7:	0f b6 08             	movzbl (%eax),%ecx
  800bba:	84 c9                	test   %cl,%cl
  800bbc:	74 04                	je     800bc2 <strncmp+0x26>
  800bbe:	3a 0a                	cmp    (%edx),%cl
  800bc0:	74 eb                	je     800bad <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bc2:	0f b6 00             	movzbl (%eax),%eax
  800bc5:	0f b6 12             	movzbl (%edx),%edx
  800bc8:	29 d0                	sub    %edx,%eax
  800bca:	eb 05                	jmp    800bd1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bcc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bda:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bde:	eb 07                	jmp    800be7 <strchr+0x13>
		if (*s == c)
  800be0:	38 ca                	cmp    %cl,%dl
  800be2:	74 0f                	je     800bf3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800be4:	83 c0 01             	add    $0x1,%eax
  800be7:	0f b6 10             	movzbl (%eax),%edx
  800bea:	84 d2                	test   %dl,%dl
  800bec:	75 f2                	jne    800be0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800bee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bff:	eb 03                	jmp    800c04 <strfind+0xf>
  800c01:	83 c0 01             	add    $0x1,%eax
  800c04:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c07:	38 ca                	cmp    %cl,%dl
  800c09:	74 04                	je     800c0f <strfind+0x1a>
  800c0b:	84 d2                	test   %dl,%dl
  800c0d:	75 f2                	jne    800c01 <strfind+0xc>
			break;
	return (char *) s;
}
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
  800c17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c1d:	85 c9                	test   %ecx,%ecx
  800c1f:	74 36                	je     800c57 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c21:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c27:	75 28                	jne    800c51 <memset+0x40>
  800c29:	f6 c1 03             	test   $0x3,%cl
  800c2c:	75 23                	jne    800c51 <memset+0x40>
		c &= 0xFF;
  800c2e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c32:	89 d3                	mov    %edx,%ebx
  800c34:	c1 e3 08             	shl    $0x8,%ebx
  800c37:	89 d6                	mov    %edx,%esi
  800c39:	c1 e6 18             	shl    $0x18,%esi
  800c3c:	89 d0                	mov    %edx,%eax
  800c3e:	c1 e0 10             	shl    $0x10,%eax
  800c41:	09 f0                	or     %esi,%eax
  800c43:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c45:	89 d8                	mov    %ebx,%eax
  800c47:	09 d0                	or     %edx,%eax
  800c49:	c1 e9 02             	shr    $0x2,%ecx
  800c4c:	fc                   	cld    
  800c4d:	f3 ab                	rep stos %eax,%es:(%edi)
  800c4f:	eb 06                	jmp    800c57 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c54:	fc                   	cld    
  800c55:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c57:	89 f8                	mov    %edi,%eax
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	8b 45 08             	mov    0x8(%ebp),%eax
  800c66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c69:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c6c:	39 c6                	cmp    %eax,%esi
  800c6e:	73 35                	jae    800ca5 <memmove+0x47>
  800c70:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c73:	39 d0                	cmp    %edx,%eax
  800c75:	73 2e                	jae    800ca5 <memmove+0x47>
		s += n;
		d += n;
  800c77:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c7a:	89 d6                	mov    %edx,%esi
  800c7c:	09 fe                	or     %edi,%esi
  800c7e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c84:	75 13                	jne    800c99 <memmove+0x3b>
  800c86:	f6 c1 03             	test   $0x3,%cl
  800c89:	75 0e                	jne    800c99 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c8b:	83 ef 04             	sub    $0x4,%edi
  800c8e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c91:	c1 e9 02             	shr    $0x2,%ecx
  800c94:	fd                   	std    
  800c95:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c97:	eb 09                	jmp    800ca2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c99:	83 ef 01             	sub    $0x1,%edi
  800c9c:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c9f:	fd                   	std    
  800ca0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ca2:	fc                   	cld    
  800ca3:	eb 1d                	jmp    800cc2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ca5:	89 f2                	mov    %esi,%edx
  800ca7:	09 c2                	or     %eax,%edx
  800ca9:	f6 c2 03             	test   $0x3,%dl
  800cac:	75 0f                	jne    800cbd <memmove+0x5f>
  800cae:	f6 c1 03             	test   $0x3,%cl
  800cb1:	75 0a                	jne    800cbd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800cb3:	c1 e9 02             	shr    $0x2,%ecx
  800cb6:	89 c7                	mov    %eax,%edi
  800cb8:	fc                   	cld    
  800cb9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cbb:	eb 05                	jmp    800cc2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cbd:	89 c7                	mov    %eax,%edi
  800cbf:	fc                   	cld    
  800cc0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800cc9:	ff 75 10             	pushl  0x10(%ebp)
  800ccc:	ff 75 0c             	pushl  0xc(%ebp)
  800ccf:	ff 75 08             	pushl  0x8(%ebp)
  800cd2:	e8 87 ff ff ff       	call   800c5e <memmove>
}
  800cd7:	c9                   	leave  
  800cd8:	c3                   	ret    

00800cd9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ce4:	89 c6                	mov    %eax,%esi
  800ce6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ce9:	eb 1a                	jmp    800d05 <memcmp+0x2c>
		if (*s1 != *s2)
  800ceb:	0f b6 08             	movzbl (%eax),%ecx
  800cee:	0f b6 1a             	movzbl (%edx),%ebx
  800cf1:	38 d9                	cmp    %bl,%cl
  800cf3:	74 0a                	je     800cff <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800cf5:	0f b6 c1             	movzbl %cl,%eax
  800cf8:	0f b6 db             	movzbl %bl,%ebx
  800cfb:	29 d8                	sub    %ebx,%eax
  800cfd:	eb 0f                	jmp    800d0e <memcmp+0x35>
		s1++, s2++;
  800cff:	83 c0 01             	add    $0x1,%eax
  800d02:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d05:	39 f0                	cmp    %esi,%eax
  800d07:	75 e2                	jne    800ceb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	53                   	push   %ebx
  800d16:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d19:	89 c1                	mov    %eax,%ecx
  800d1b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d1e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d22:	eb 0a                	jmp    800d2e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d24:	0f b6 10             	movzbl (%eax),%edx
  800d27:	39 da                	cmp    %ebx,%edx
  800d29:	74 07                	je     800d32 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d2b:	83 c0 01             	add    $0x1,%eax
  800d2e:	39 c8                	cmp    %ecx,%eax
  800d30:	72 f2                	jb     800d24 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d32:	5b                   	pop    %ebx
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
  800d3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d41:	eb 03                	jmp    800d46 <strtol+0x11>
		s++;
  800d43:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d46:	0f b6 01             	movzbl (%ecx),%eax
  800d49:	3c 20                	cmp    $0x20,%al
  800d4b:	74 f6                	je     800d43 <strtol+0xe>
  800d4d:	3c 09                	cmp    $0x9,%al
  800d4f:	74 f2                	je     800d43 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d51:	3c 2b                	cmp    $0x2b,%al
  800d53:	75 0a                	jne    800d5f <strtol+0x2a>
		s++;
  800d55:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d58:	bf 00 00 00 00       	mov    $0x0,%edi
  800d5d:	eb 11                	jmp    800d70 <strtol+0x3b>
  800d5f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d64:	3c 2d                	cmp    $0x2d,%al
  800d66:	75 08                	jne    800d70 <strtol+0x3b>
		s++, neg = 1;
  800d68:	83 c1 01             	add    $0x1,%ecx
  800d6b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d70:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d76:	75 15                	jne    800d8d <strtol+0x58>
  800d78:	80 39 30             	cmpb   $0x30,(%ecx)
  800d7b:	75 10                	jne    800d8d <strtol+0x58>
  800d7d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d81:	75 7c                	jne    800dff <strtol+0xca>
		s += 2, base = 16;
  800d83:	83 c1 02             	add    $0x2,%ecx
  800d86:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d8b:	eb 16                	jmp    800da3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d8d:	85 db                	test   %ebx,%ebx
  800d8f:	75 12                	jne    800da3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d91:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d96:	80 39 30             	cmpb   $0x30,(%ecx)
  800d99:	75 08                	jne    800da3 <strtol+0x6e>
		s++, base = 8;
  800d9b:	83 c1 01             	add    $0x1,%ecx
  800d9e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800da3:	b8 00 00 00 00       	mov    $0x0,%eax
  800da8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dab:	0f b6 11             	movzbl (%ecx),%edx
  800dae:	8d 72 d0             	lea    -0x30(%edx),%esi
  800db1:	89 f3                	mov    %esi,%ebx
  800db3:	80 fb 09             	cmp    $0x9,%bl
  800db6:	77 08                	ja     800dc0 <strtol+0x8b>
			dig = *s - '0';
  800db8:	0f be d2             	movsbl %dl,%edx
  800dbb:	83 ea 30             	sub    $0x30,%edx
  800dbe:	eb 22                	jmp    800de2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800dc0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dc3:	89 f3                	mov    %esi,%ebx
  800dc5:	80 fb 19             	cmp    $0x19,%bl
  800dc8:	77 08                	ja     800dd2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800dca:	0f be d2             	movsbl %dl,%edx
  800dcd:	83 ea 57             	sub    $0x57,%edx
  800dd0:	eb 10                	jmp    800de2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800dd2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dd5:	89 f3                	mov    %esi,%ebx
  800dd7:	80 fb 19             	cmp    $0x19,%bl
  800dda:	77 16                	ja     800df2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ddc:	0f be d2             	movsbl %dl,%edx
  800ddf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800de2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800de5:	7d 0b                	jge    800df2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800de7:	83 c1 01             	add    $0x1,%ecx
  800dea:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dee:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800df0:	eb b9                	jmp    800dab <strtol+0x76>

	if (endptr)
  800df2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800df6:	74 0d                	je     800e05 <strtol+0xd0>
		*endptr = (char *) s;
  800df8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dfb:	89 0e                	mov    %ecx,(%esi)
  800dfd:	eb 06                	jmp    800e05 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dff:	85 db                	test   %ebx,%ebx
  800e01:	74 98                	je     800d9b <strtol+0x66>
  800e03:	eb 9e                	jmp    800da3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e05:	89 c2                	mov    %eax,%edx
  800e07:	f7 da                	neg    %edx
  800e09:	85 ff                	test   %edi,%edi
  800e0b:	0f 45 c2             	cmovne %edx,%eax
}
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	83 ec 04             	sub    $0x4,%esp
  800e1c:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800e1f:	57                   	push   %edi
  800e20:	e8 6e fc ff ff       	call   800a93 <strlen>
  800e25:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800e28:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800e2b:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800e30:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800e35:	eb 46                	jmp    800e7d <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800e37:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800e3b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800e3e:	80 f9 09             	cmp    $0x9,%cl
  800e41:	77 08                	ja     800e4b <charhex_to_dec+0x38>
			num = s[i] - '0';
  800e43:	0f be d2             	movsbl %dl,%edx
  800e46:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800e49:	eb 27                	jmp    800e72 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800e4b:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800e4e:	80 f9 05             	cmp    $0x5,%cl
  800e51:	77 08                	ja     800e5b <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800e53:	0f be d2             	movsbl %dl,%edx
  800e56:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800e59:	eb 17                	jmp    800e72 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800e5b:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800e5e:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800e61:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800e66:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800e6a:	77 06                	ja     800e72 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800e6c:	0f be d2             	movsbl %dl,%edx
  800e6f:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800e72:	0f af ce             	imul   %esi,%ecx
  800e75:	01 c8                	add    %ecx,%eax
		base *= 16;
  800e77:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800e7a:	83 eb 01             	sub    $0x1,%ebx
  800e7d:	83 fb 01             	cmp    $0x1,%ebx
  800e80:	7f b5                	jg     800e37 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800e82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e85:	5b                   	pop    %ebx
  800e86:	5e                   	pop    %esi
  800e87:	5f                   	pop    %edi
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    

00800e8a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	57                   	push   %edi
  800e8e:	56                   	push   %esi
  800e8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e90:	b8 00 00 00 00       	mov    $0x0,%eax
  800e95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e98:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9b:	89 c3                	mov    %eax,%ebx
  800e9d:	89 c7                	mov    %eax,%edi
  800e9f:	89 c6                	mov    %eax,%esi
  800ea1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	57                   	push   %edi
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eae:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb3:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb8:	89 d1                	mov    %edx,%ecx
  800eba:	89 d3                	mov    %edx,%ebx
  800ebc:	89 d7                	mov    %edx,%edi
  800ebe:	89 d6                	mov    %edx,%esi
  800ec0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ec2:	5b                   	pop    %ebx
  800ec3:	5e                   	pop    %esi
  800ec4:	5f                   	pop    %edi
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	57                   	push   %edi
  800ecb:	56                   	push   %esi
  800ecc:	53                   	push   %ebx
  800ecd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed5:	b8 03 00 00 00       	mov    $0x3,%eax
  800eda:	8b 55 08             	mov    0x8(%ebp),%edx
  800edd:	89 cb                	mov    %ecx,%ebx
  800edf:	89 cf                	mov    %ecx,%edi
  800ee1:	89 ce                	mov    %ecx,%esi
  800ee3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	7e 17                	jle    800f00 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee9:	83 ec 0c             	sub    $0xc,%esp
  800eec:	50                   	push   %eax
  800eed:	6a 03                	push   $0x3
  800eef:	68 6f 25 80 00       	push   $0x80256f
  800ef4:	6a 23                	push   $0x23
  800ef6:	68 8c 25 80 00       	push   $0x80258c
  800efb:	e8 cc f3 ff ff       	call   8002cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f13:	b8 02 00 00 00       	mov    $0x2,%eax
  800f18:	89 d1                	mov    %edx,%ecx
  800f1a:	89 d3                	mov    %edx,%ebx
  800f1c:	89 d7                	mov    %edx,%edi
  800f1e:	89 d6                	mov    %edx,%esi
  800f20:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <sys_yield>:

void
sys_yield(void)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f32:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f37:	89 d1                	mov    %edx,%ecx
  800f39:	89 d3                	mov    %edx,%ebx
  800f3b:	89 d7                	mov    %edx,%edi
  800f3d:	89 d6                	mov    %edx,%esi
  800f3f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f41:	5b                   	pop    %ebx
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	57                   	push   %edi
  800f4a:	56                   	push   %esi
  800f4b:	53                   	push   %ebx
  800f4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4f:	be 00 00 00 00       	mov    $0x0,%esi
  800f54:	b8 04 00 00 00       	mov    $0x4,%eax
  800f59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f62:	89 f7                	mov    %esi,%edi
  800f64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f66:	85 c0                	test   %eax,%eax
  800f68:	7e 17                	jle    800f81 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6a:	83 ec 0c             	sub    $0xc,%esp
  800f6d:	50                   	push   %eax
  800f6e:	6a 04                	push   $0x4
  800f70:	68 6f 25 80 00       	push   $0x80256f
  800f75:	6a 23                	push   $0x23
  800f77:	68 8c 25 80 00       	push   $0x80258c
  800f7c:	e8 4b f3 ff ff       	call   8002cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    

00800f89 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	57                   	push   %edi
  800f8d:	56                   	push   %esi
  800f8e:	53                   	push   %ebx
  800f8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f92:	b8 05 00 00 00       	mov    $0x5,%eax
  800f97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fa3:	8b 75 18             	mov    0x18(%ebp),%esi
  800fa6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	7e 17                	jle    800fc3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fac:	83 ec 0c             	sub    $0xc,%esp
  800faf:	50                   	push   %eax
  800fb0:	6a 05                	push   $0x5
  800fb2:	68 6f 25 80 00       	push   $0x80256f
  800fb7:	6a 23                	push   $0x23
  800fb9:	68 8c 25 80 00       	push   $0x80258c
  800fbe:	e8 09 f3 ff ff       	call   8002cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc6:	5b                   	pop    %ebx
  800fc7:	5e                   	pop    %esi
  800fc8:	5f                   	pop    %edi
  800fc9:	5d                   	pop    %ebp
  800fca:	c3                   	ret    

00800fcb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	57                   	push   %edi
  800fcf:	56                   	push   %esi
  800fd0:	53                   	push   %ebx
  800fd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd9:	b8 06 00 00 00       	mov    $0x6,%eax
  800fde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe4:	89 df                	mov    %ebx,%edi
  800fe6:	89 de                	mov    %ebx,%esi
  800fe8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	7e 17                	jle    801005 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fee:	83 ec 0c             	sub    $0xc,%esp
  800ff1:	50                   	push   %eax
  800ff2:	6a 06                	push   $0x6
  800ff4:	68 6f 25 80 00       	push   $0x80256f
  800ff9:	6a 23                	push   $0x23
  800ffb:	68 8c 25 80 00       	push   $0x80258c
  801000:	e8 c7 f2 ff ff       	call   8002cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801005:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801008:	5b                   	pop    %ebx
  801009:	5e                   	pop    %esi
  80100a:	5f                   	pop    %edi
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    

0080100d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	57                   	push   %edi
  801011:	56                   	push   %esi
  801012:	53                   	push   %ebx
  801013:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801016:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101b:	b8 08 00 00 00       	mov    $0x8,%eax
  801020:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801023:	8b 55 08             	mov    0x8(%ebp),%edx
  801026:	89 df                	mov    %ebx,%edi
  801028:	89 de                	mov    %ebx,%esi
  80102a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80102c:	85 c0                	test   %eax,%eax
  80102e:	7e 17                	jle    801047 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801030:	83 ec 0c             	sub    $0xc,%esp
  801033:	50                   	push   %eax
  801034:	6a 08                	push   $0x8
  801036:	68 6f 25 80 00       	push   $0x80256f
  80103b:	6a 23                	push   $0x23
  80103d:	68 8c 25 80 00       	push   $0x80258c
  801042:	e8 85 f2 ff ff       	call   8002cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801047:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104a:	5b                   	pop    %ebx
  80104b:	5e                   	pop    %esi
  80104c:	5f                   	pop    %edi
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    

0080104f <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	57                   	push   %edi
  801053:	56                   	push   %esi
  801054:	53                   	push   %ebx
  801055:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801058:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801062:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801065:	8b 55 08             	mov    0x8(%ebp),%edx
  801068:	89 df                	mov    %ebx,%edi
  80106a:	89 de                	mov    %ebx,%esi
  80106c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80106e:	85 c0                	test   %eax,%eax
  801070:	7e 17                	jle    801089 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801072:	83 ec 0c             	sub    $0xc,%esp
  801075:	50                   	push   %eax
  801076:	6a 0a                	push   $0xa
  801078:	68 6f 25 80 00       	push   $0x80256f
  80107d:	6a 23                	push   $0x23
  80107f:	68 8c 25 80 00       	push   $0x80258c
  801084:	e8 43 f2 ff ff       	call   8002cc <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801089:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108c:	5b                   	pop    %ebx
  80108d:	5e                   	pop    %esi
  80108e:	5f                   	pop    %edi
  80108f:	5d                   	pop    %ebp
  801090:	c3                   	ret    

00801091 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	57                   	push   %edi
  801095:	56                   	push   %esi
  801096:	53                   	push   %ebx
  801097:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109f:	b8 09 00 00 00       	mov    $0x9,%eax
  8010a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010aa:	89 df                	mov    %ebx,%edi
  8010ac:	89 de                	mov    %ebx,%esi
  8010ae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	7e 17                	jle    8010cb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b4:	83 ec 0c             	sub    $0xc,%esp
  8010b7:	50                   	push   %eax
  8010b8:	6a 09                	push   $0x9
  8010ba:	68 6f 25 80 00       	push   $0x80256f
  8010bf:	6a 23                	push   $0x23
  8010c1:	68 8c 25 80 00       	push   $0x80258c
  8010c6:	e8 01 f2 ff ff       	call   8002cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ce:	5b                   	pop    %ebx
  8010cf:	5e                   	pop    %esi
  8010d0:	5f                   	pop    %edi
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    

008010d3 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	57                   	push   %edi
  8010d7:	56                   	push   %esi
  8010d8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d9:	be 00 00 00 00       	mov    $0x0,%esi
  8010de:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ec:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ef:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f1:	5b                   	pop    %ebx
  8010f2:	5e                   	pop    %esi
  8010f3:	5f                   	pop    %edi
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    

008010f6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	57                   	push   %edi
  8010fa:	56                   	push   %esi
  8010fb:	53                   	push   %ebx
  8010fc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  801104:	b8 0d 00 00 00       	mov    $0xd,%eax
  801109:	8b 55 08             	mov    0x8(%ebp),%edx
  80110c:	89 cb                	mov    %ecx,%ebx
  80110e:	89 cf                	mov    %ecx,%edi
  801110:	89 ce                	mov    %ecx,%esi
  801112:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801114:	85 c0                	test   %eax,%eax
  801116:	7e 17                	jle    80112f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801118:	83 ec 0c             	sub    $0xc,%esp
  80111b:	50                   	push   %eax
  80111c:	6a 0d                	push   $0xd
  80111e:	68 6f 25 80 00       	push   $0x80256f
  801123:	6a 23                	push   $0x23
  801125:	68 8c 25 80 00       	push   $0x80258c
  80112a:	e8 9d f1 ff ff       	call   8002cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80112f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5f                   	pop    %edi
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80113a:	8b 45 08             	mov    0x8(%ebp),%eax
  80113d:	05 00 00 00 30       	add    $0x30000000,%eax
  801142:	c1 e8 0c             	shr    $0xc,%eax
}
  801145:	5d                   	pop    %ebp
  801146:	c3                   	ret    

00801147 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80114a:	8b 45 08             	mov    0x8(%ebp),%eax
  80114d:	05 00 00 00 30       	add    $0x30000000,%eax
  801152:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801157:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    

0080115e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801164:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801169:	89 c2                	mov    %eax,%edx
  80116b:	c1 ea 16             	shr    $0x16,%edx
  80116e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801175:	f6 c2 01             	test   $0x1,%dl
  801178:	74 11                	je     80118b <fd_alloc+0x2d>
  80117a:	89 c2                	mov    %eax,%edx
  80117c:	c1 ea 0c             	shr    $0xc,%edx
  80117f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801186:	f6 c2 01             	test   $0x1,%dl
  801189:	75 09                	jne    801194 <fd_alloc+0x36>
			*fd_store = fd;
  80118b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80118d:	b8 00 00 00 00       	mov    $0x0,%eax
  801192:	eb 17                	jmp    8011ab <fd_alloc+0x4d>
  801194:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801199:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80119e:	75 c9                	jne    801169 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011a0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011a6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011ab:	5d                   	pop    %ebp
  8011ac:	c3                   	ret    

008011ad <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
  8011b0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011b3:	83 f8 1f             	cmp    $0x1f,%eax
  8011b6:	77 36                	ja     8011ee <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011b8:	c1 e0 0c             	shl    $0xc,%eax
  8011bb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011c0:	89 c2                	mov    %eax,%edx
  8011c2:	c1 ea 16             	shr    $0x16,%edx
  8011c5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011cc:	f6 c2 01             	test   $0x1,%dl
  8011cf:	74 24                	je     8011f5 <fd_lookup+0x48>
  8011d1:	89 c2                	mov    %eax,%edx
  8011d3:	c1 ea 0c             	shr    $0xc,%edx
  8011d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011dd:	f6 c2 01             	test   $0x1,%dl
  8011e0:	74 1a                	je     8011fc <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e5:	89 02                	mov    %eax,(%edx)
	return 0;
  8011e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ec:	eb 13                	jmp    801201 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f3:	eb 0c                	jmp    801201 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011fa:	eb 05                	jmp    801201 <fd_lookup+0x54>
  8011fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	83 ec 08             	sub    $0x8,%esp
  801209:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120c:	ba 18 26 80 00       	mov    $0x802618,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801211:	eb 13                	jmp    801226 <dev_lookup+0x23>
  801213:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801216:	39 08                	cmp    %ecx,(%eax)
  801218:	75 0c                	jne    801226 <dev_lookup+0x23>
			*dev = devtab[i];
  80121a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80121d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80121f:	b8 00 00 00 00       	mov    $0x0,%eax
  801224:	eb 2e                	jmp    801254 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801226:	8b 02                	mov    (%edx),%eax
  801228:	85 c0                	test   %eax,%eax
  80122a:	75 e7                	jne    801213 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80122c:	a1 24 44 80 00       	mov    0x804424,%eax
  801231:	8b 40 48             	mov    0x48(%eax),%eax
  801234:	83 ec 04             	sub    $0x4,%esp
  801237:	51                   	push   %ecx
  801238:	50                   	push   %eax
  801239:	68 9c 25 80 00       	push   $0x80259c
  80123e:	e8 62 f1 ff ff       	call   8003a5 <cprintf>
	*dev = 0;
  801243:	8b 45 0c             	mov    0xc(%ebp),%eax
  801246:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801254:	c9                   	leave  
  801255:	c3                   	ret    

00801256 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	56                   	push   %esi
  80125a:	53                   	push   %ebx
  80125b:	83 ec 10             	sub    $0x10,%esp
  80125e:	8b 75 08             	mov    0x8(%ebp),%esi
  801261:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801264:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801267:	50                   	push   %eax
  801268:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80126e:	c1 e8 0c             	shr    $0xc,%eax
  801271:	50                   	push   %eax
  801272:	e8 36 ff ff ff       	call   8011ad <fd_lookup>
  801277:	83 c4 08             	add    $0x8,%esp
  80127a:	85 c0                	test   %eax,%eax
  80127c:	78 05                	js     801283 <fd_close+0x2d>
	    || fd != fd2) 
  80127e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801281:	74 0c                	je     80128f <fd_close+0x39>
		return (must_exist ? r : 0); 
  801283:	84 db                	test   %bl,%bl
  801285:	ba 00 00 00 00       	mov    $0x0,%edx
  80128a:	0f 44 c2             	cmove  %edx,%eax
  80128d:	eb 41                	jmp    8012d0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80128f:	83 ec 08             	sub    $0x8,%esp
  801292:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801295:	50                   	push   %eax
  801296:	ff 36                	pushl  (%esi)
  801298:	e8 66 ff ff ff       	call   801203 <dev_lookup>
  80129d:	89 c3                	mov    %eax,%ebx
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	78 1a                	js     8012c0 <fd_close+0x6a>
		if (dev->dev_close) 
  8012a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8012ac:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	74 0b                	je     8012c0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012b5:	83 ec 0c             	sub    $0xc,%esp
  8012b8:	56                   	push   %esi
  8012b9:	ff d0                	call   *%eax
  8012bb:	89 c3                	mov    %eax,%ebx
  8012bd:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012c0:	83 ec 08             	sub    $0x8,%esp
  8012c3:	56                   	push   %esi
  8012c4:	6a 00                	push   $0x0
  8012c6:	e8 00 fd ff ff       	call   800fcb <sys_page_unmap>
	return r;
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	89 d8                	mov    %ebx,%eax
}
  8012d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d3:	5b                   	pop    %ebx
  8012d4:	5e                   	pop    %esi
  8012d5:	5d                   	pop    %ebp
  8012d6:	c3                   	ret    

008012d7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012d7:	55                   	push   %ebp
  8012d8:	89 e5                	mov    %esp,%ebp
  8012da:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e0:	50                   	push   %eax
  8012e1:	ff 75 08             	pushl  0x8(%ebp)
  8012e4:	e8 c4 fe ff ff       	call   8011ad <fd_lookup>
  8012e9:	83 c4 08             	add    $0x8,%esp
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	78 10                	js     801300 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  8012f0:	83 ec 08             	sub    $0x8,%esp
  8012f3:	6a 01                	push   $0x1
  8012f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f8:	e8 59 ff ff ff       	call   801256 <fd_close>
  8012fd:	83 c4 10             	add    $0x10,%esp
}
  801300:	c9                   	leave  
  801301:	c3                   	ret    

00801302 <close_all>:

void
close_all(void)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	53                   	push   %ebx
  801306:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801309:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80130e:	83 ec 0c             	sub    $0xc,%esp
  801311:	53                   	push   %ebx
  801312:	e8 c0 ff ff ff       	call   8012d7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801317:	83 c3 01             	add    $0x1,%ebx
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	83 fb 20             	cmp    $0x20,%ebx
  801320:	75 ec                	jne    80130e <close_all+0xc>
		close(i);
}
  801322:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801325:	c9                   	leave  
  801326:	c3                   	ret    

00801327 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
  80132a:	57                   	push   %edi
  80132b:	56                   	push   %esi
  80132c:	53                   	push   %ebx
  80132d:	83 ec 2c             	sub    $0x2c,%esp
  801330:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801333:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801336:	50                   	push   %eax
  801337:	ff 75 08             	pushl  0x8(%ebp)
  80133a:	e8 6e fe ff ff       	call   8011ad <fd_lookup>
  80133f:	83 c4 08             	add    $0x8,%esp
  801342:	85 c0                	test   %eax,%eax
  801344:	0f 88 c1 00 00 00    	js     80140b <dup+0xe4>
		return r;
	close(newfdnum);
  80134a:	83 ec 0c             	sub    $0xc,%esp
  80134d:	56                   	push   %esi
  80134e:	e8 84 ff ff ff       	call   8012d7 <close>

	newfd = INDEX2FD(newfdnum);
  801353:	89 f3                	mov    %esi,%ebx
  801355:	c1 e3 0c             	shl    $0xc,%ebx
  801358:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80135e:	83 c4 04             	add    $0x4,%esp
  801361:	ff 75 e4             	pushl  -0x1c(%ebp)
  801364:	e8 de fd ff ff       	call   801147 <fd2data>
  801369:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80136b:	89 1c 24             	mov    %ebx,(%esp)
  80136e:	e8 d4 fd ff ff       	call   801147 <fd2data>
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801379:	89 f8                	mov    %edi,%eax
  80137b:	c1 e8 16             	shr    $0x16,%eax
  80137e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801385:	a8 01                	test   $0x1,%al
  801387:	74 37                	je     8013c0 <dup+0x99>
  801389:	89 f8                	mov    %edi,%eax
  80138b:	c1 e8 0c             	shr    $0xc,%eax
  80138e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801395:	f6 c2 01             	test   $0x1,%dl
  801398:	74 26                	je     8013c0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80139a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a1:	83 ec 0c             	sub    $0xc,%esp
  8013a4:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a9:	50                   	push   %eax
  8013aa:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013ad:	6a 00                	push   $0x0
  8013af:	57                   	push   %edi
  8013b0:	6a 00                	push   $0x0
  8013b2:	e8 d2 fb ff ff       	call   800f89 <sys_page_map>
  8013b7:	89 c7                	mov    %eax,%edi
  8013b9:	83 c4 20             	add    $0x20,%esp
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 2e                	js     8013ee <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013c3:	89 d0                	mov    %edx,%eax
  8013c5:	c1 e8 0c             	shr    $0xc,%eax
  8013c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013cf:	83 ec 0c             	sub    $0xc,%esp
  8013d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8013d7:	50                   	push   %eax
  8013d8:	53                   	push   %ebx
  8013d9:	6a 00                	push   $0x0
  8013db:	52                   	push   %edx
  8013dc:	6a 00                	push   $0x0
  8013de:	e8 a6 fb ff ff       	call   800f89 <sys_page_map>
  8013e3:	89 c7                	mov    %eax,%edi
  8013e5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013e8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ea:	85 ff                	test   %edi,%edi
  8013ec:	79 1d                	jns    80140b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013ee:	83 ec 08             	sub    $0x8,%esp
  8013f1:	53                   	push   %ebx
  8013f2:	6a 00                	push   $0x0
  8013f4:	e8 d2 fb ff ff       	call   800fcb <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013f9:	83 c4 08             	add    $0x8,%esp
  8013fc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013ff:	6a 00                	push   $0x0
  801401:	e8 c5 fb ff ff       	call   800fcb <sys_page_unmap>
	return r;
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	89 f8                	mov    %edi,%eax
}
  80140b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80140e:	5b                   	pop    %ebx
  80140f:	5e                   	pop    %esi
  801410:	5f                   	pop    %edi
  801411:	5d                   	pop    %ebp
  801412:	c3                   	ret    

00801413 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	53                   	push   %ebx
  801417:	83 ec 14             	sub    $0x14,%esp
  80141a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801420:	50                   	push   %eax
  801421:	53                   	push   %ebx
  801422:	e8 86 fd ff ff       	call   8011ad <fd_lookup>
  801427:	83 c4 08             	add    $0x8,%esp
  80142a:	89 c2                	mov    %eax,%edx
  80142c:	85 c0                	test   %eax,%eax
  80142e:	78 6d                	js     80149d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801430:	83 ec 08             	sub    $0x8,%esp
  801433:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801436:	50                   	push   %eax
  801437:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143a:	ff 30                	pushl  (%eax)
  80143c:	e8 c2 fd ff ff       	call   801203 <dev_lookup>
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	85 c0                	test   %eax,%eax
  801446:	78 4c                	js     801494 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801448:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80144b:	8b 42 08             	mov    0x8(%edx),%eax
  80144e:	83 e0 03             	and    $0x3,%eax
  801451:	83 f8 01             	cmp    $0x1,%eax
  801454:	75 21                	jne    801477 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801456:	a1 24 44 80 00       	mov    0x804424,%eax
  80145b:	8b 40 48             	mov    0x48(%eax),%eax
  80145e:	83 ec 04             	sub    $0x4,%esp
  801461:	53                   	push   %ebx
  801462:	50                   	push   %eax
  801463:	68 dd 25 80 00       	push   $0x8025dd
  801468:	e8 38 ef ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  80146d:	83 c4 10             	add    $0x10,%esp
  801470:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801475:	eb 26                	jmp    80149d <read+0x8a>
	}
	if (!dev->dev_read)
  801477:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147a:	8b 40 08             	mov    0x8(%eax),%eax
  80147d:	85 c0                	test   %eax,%eax
  80147f:	74 17                	je     801498 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801481:	83 ec 04             	sub    $0x4,%esp
  801484:	ff 75 10             	pushl  0x10(%ebp)
  801487:	ff 75 0c             	pushl  0xc(%ebp)
  80148a:	52                   	push   %edx
  80148b:	ff d0                	call   *%eax
  80148d:	89 c2                	mov    %eax,%edx
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	eb 09                	jmp    80149d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801494:	89 c2                	mov    %eax,%edx
  801496:	eb 05                	jmp    80149d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801498:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80149d:	89 d0                	mov    %edx,%eax
  80149f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a2:	c9                   	leave  
  8014a3:	c3                   	ret    

008014a4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	57                   	push   %edi
  8014a8:	56                   	push   %esi
  8014a9:	53                   	push   %ebx
  8014aa:	83 ec 0c             	sub    $0xc,%esp
  8014ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014b0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b8:	eb 21                	jmp    8014db <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014ba:	83 ec 04             	sub    $0x4,%esp
  8014bd:	89 f0                	mov    %esi,%eax
  8014bf:	29 d8                	sub    %ebx,%eax
  8014c1:	50                   	push   %eax
  8014c2:	89 d8                	mov    %ebx,%eax
  8014c4:	03 45 0c             	add    0xc(%ebp),%eax
  8014c7:	50                   	push   %eax
  8014c8:	57                   	push   %edi
  8014c9:	e8 45 ff ff ff       	call   801413 <read>
		if (m < 0)
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 10                	js     8014e5 <readn+0x41>
			return m;
		if (m == 0)
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	74 0a                	je     8014e3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d9:	01 c3                	add    %eax,%ebx
  8014db:	39 f3                	cmp    %esi,%ebx
  8014dd:	72 db                	jb     8014ba <readn+0x16>
  8014df:	89 d8                	mov    %ebx,%eax
  8014e1:	eb 02                	jmp    8014e5 <readn+0x41>
  8014e3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e8:	5b                   	pop    %ebx
  8014e9:	5e                   	pop    %esi
  8014ea:	5f                   	pop    %edi
  8014eb:	5d                   	pop    %ebp
  8014ec:	c3                   	ret    

008014ed <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	53                   	push   %ebx
  8014f1:	83 ec 14             	sub    $0x14,%esp
  8014f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fa:	50                   	push   %eax
  8014fb:	53                   	push   %ebx
  8014fc:	e8 ac fc ff ff       	call   8011ad <fd_lookup>
  801501:	83 c4 08             	add    $0x8,%esp
  801504:	89 c2                	mov    %eax,%edx
  801506:	85 c0                	test   %eax,%eax
  801508:	78 68                	js     801572 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150a:	83 ec 08             	sub    $0x8,%esp
  80150d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801510:	50                   	push   %eax
  801511:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801514:	ff 30                	pushl  (%eax)
  801516:	e8 e8 fc ff ff       	call   801203 <dev_lookup>
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	85 c0                	test   %eax,%eax
  801520:	78 47                	js     801569 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801522:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801525:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801529:	75 21                	jne    80154c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80152b:	a1 24 44 80 00       	mov    0x804424,%eax
  801530:	8b 40 48             	mov    0x48(%eax),%eax
  801533:	83 ec 04             	sub    $0x4,%esp
  801536:	53                   	push   %ebx
  801537:	50                   	push   %eax
  801538:	68 f9 25 80 00       	push   $0x8025f9
  80153d:	e8 63 ee ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  801542:	83 c4 10             	add    $0x10,%esp
  801545:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80154a:	eb 26                	jmp    801572 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80154c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80154f:	8b 52 0c             	mov    0xc(%edx),%edx
  801552:	85 d2                	test   %edx,%edx
  801554:	74 17                	je     80156d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801556:	83 ec 04             	sub    $0x4,%esp
  801559:	ff 75 10             	pushl  0x10(%ebp)
  80155c:	ff 75 0c             	pushl  0xc(%ebp)
  80155f:	50                   	push   %eax
  801560:	ff d2                	call   *%edx
  801562:	89 c2                	mov    %eax,%edx
  801564:	83 c4 10             	add    $0x10,%esp
  801567:	eb 09                	jmp    801572 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801569:	89 c2                	mov    %eax,%edx
  80156b:	eb 05                	jmp    801572 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80156d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801572:	89 d0                	mov    %edx,%eax
  801574:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801577:	c9                   	leave  
  801578:	c3                   	ret    

00801579 <seek>:

int
seek(int fdnum, off_t offset)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80157f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801582:	50                   	push   %eax
  801583:	ff 75 08             	pushl  0x8(%ebp)
  801586:	e8 22 fc ff ff       	call   8011ad <fd_lookup>
  80158b:	83 c4 08             	add    $0x8,%esp
  80158e:	85 c0                	test   %eax,%eax
  801590:	78 0e                	js     8015a0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801592:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801595:	8b 55 0c             	mov    0xc(%ebp),%edx
  801598:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80159b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a0:	c9                   	leave  
  8015a1:	c3                   	ret    

008015a2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	53                   	push   %ebx
  8015a6:	83 ec 14             	sub    $0x14,%esp
  8015a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015af:	50                   	push   %eax
  8015b0:	53                   	push   %ebx
  8015b1:	e8 f7 fb ff ff       	call   8011ad <fd_lookup>
  8015b6:	83 c4 08             	add    $0x8,%esp
  8015b9:	89 c2                	mov    %eax,%edx
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 65                	js     801624 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bf:	83 ec 08             	sub    $0x8,%esp
  8015c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c5:	50                   	push   %eax
  8015c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c9:	ff 30                	pushl  (%eax)
  8015cb:	e8 33 fc ff ff       	call   801203 <dev_lookup>
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 44                	js     80161b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015da:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015de:	75 21                	jne    801601 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015e0:	a1 24 44 80 00       	mov    0x804424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015e5:	8b 40 48             	mov    0x48(%eax),%eax
  8015e8:	83 ec 04             	sub    $0x4,%esp
  8015eb:	53                   	push   %ebx
  8015ec:	50                   	push   %eax
  8015ed:	68 bc 25 80 00       	push   $0x8025bc
  8015f2:	e8 ae ed ff ff       	call   8003a5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ff:	eb 23                	jmp    801624 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801601:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801604:	8b 52 18             	mov    0x18(%edx),%edx
  801607:	85 d2                	test   %edx,%edx
  801609:	74 14                	je     80161f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80160b:	83 ec 08             	sub    $0x8,%esp
  80160e:	ff 75 0c             	pushl  0xc(%ebp)
  801611:	50                   	push   %eax
  801612:	ff d2                	call   *%edx
  801614:	89 c2                	mov    %eax,%edx
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	eb 09                	jmp    801624 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161b:	89 c2                	mov    %eax,%edx
  80161d:	eb 05                	jmp    801624 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80161f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801624:	89 d0                	mov    %edx,%eax
  801626:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801629:	c9                   	leave  
  80162a:	c3                   	ret    

0080162b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	53                   	push   %ebx
  80162f:	83 ec 14             	sub    $0x14,%esp
  801632:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801635:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801638:	50                   	push   %eax
  801639:	ff 75 08             	pushl  0x8(%ebp)
  80163c:	e8 6c fb ff ff       	call   8011ad <fd_lookup>
  801641:	83 c4 08             	add    $0x8,%esp
  801644:	89 c2                	mov    %eax,%edx
  801646:	85 c0                	test   %eax,%eax
  801648:	78 58                	js     8016a2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164a:	83 ec 08             	sub    $0x8,%esp
  80164d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801650:	50                   	push   %eax
  801651:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801654:	ff 30                	pushl  (%eax)
  801656:	e8 a8 fb ff ff       	call   801203 <dev_lookup>
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	85 c0                	test   %eax,%eax
  801660:	78 37                	js     801699 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801662:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801665:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801669:	74 32                	je     80169d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80166b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80166e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801675:	00 00 00 
	stat->st_isdir = 0;
  801678:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80167f:	00 00 00 
	stat->st_dev = dev;
  801682:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801688:	83 ec 08             	sub    $0x8,%esp
  80168b:	53                   	push   %ebx
  80168c:	ff 75 f0             	pushl  -0x10(%ebp)
  80168f:	ff 50 14             	call   *0x14(%eax)
  801692:	89 c2                	mov    %eax,%edx
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	eb 09                	jmp    8016a2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801699:	89 c2                	mov    %eax,%edx
  80169b:	eb 05                	jmp    8016a2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80169d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016a2:	89 d0                	mov    %edx,%eax
  8016a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a7:	c9                   	leave  
  8016a8:	c3                   	ret    

008016a9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	56                   	push   %esi
  8016ad:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	6a 00                	push   $0x0
  8016b3:	ff 75 08             	pushl  0x8(%ebp)
  8016b6:	e8 2b 02 00 00       	call   8018e6 <open>
  8016bb:	89 c3                	mov    %eax,%ebx
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	78 1b                	js     8016df <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016c4:	83 ec 08             	sub    $0x8,%esp
  8016c7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ca:	50                   	push   %eax
  8016cb:	e8 5b ff ff ff       	call   80162b <fstat>
  8016d0:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d2:	89 1c 24             	mov    %ebx,(%esp)
  8016d5:	e8 fd fb ff ff       	call   8012d7 <close>
	return r;
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	89 f0                	mov    %esi,%eax
}
  8016df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e2:	5b                   	pop    %ebx
  8016e3:	5e                   	pop    %esi
  8016e4:	5d                   	pop    %ebp
  8016e5:	c3                   	ret    

008016e6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	56                   	push   %esi
  8016ea:	53                   	push   %ebx
  8016eb:	89 c6                	mov    %eax,%esi
  8016ed:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016ef:	83 3d 20 44 80 00 00 	cmpl   $0x0,0x804420
  8016f6:	75 12                	jne    80170a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016f8:	83 ec 0c             	sub    $0xc,%esp
  8016fb:	6a 01                	push   $0x1
  8016fd:	e8 b3 07 00 00       	call   801eb5 <ipc_find_env>
  801702:	a3 20 44 80 00       	mov    %eax,0x804420
  801707:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80170a:	6a 07                	push   $0x7
  80170c:	68 00 50 80 00       	push   $0x805000
  801711:	56                   	push   %esi
  801712:	ff 35 20 44 80 00    	pushl  0x804420
  801718:	e8 42 07 00 00       	call   801e5f <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80171d:	83 c4 0c             	add    $0xc,%esp
  801720:	6a 00                	push   $0x0
  801722:	53                   	push   %ebx
  801723:	6a 00                	push   $0x0
  801725:	e8 cc 06 00 00       	call   801df6 <ipc_recv>
}
  80172a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172d:	5b                   	pop    %ebx
  80172e:	5e                   	pop    %esi
  80172f:	5d                   	pop    %ebp
  801730:	c3                   	ret    

00801731 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801737:	8b 45 08             	mov    0x8(%ebp),%eax
  80173a:	8b 40 0c             	mov    0xc(%eax),%eax
  80173d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801742:	8b 45 0c             	mov    0xc(%ebp),%eax
  801745:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80174a:	ba 00 00 00 00       	mov    $0x0,%edx
  80174f:	b8 02 00 00 00       	mov    $0x2,%eax
  801754:	e8 8d ff ff ff       	call   8016e6 <fsipc>
}
  801759:	c9                   	leave  
  80175a:	c3                   	ret    

0080175b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801761:	8b 45 08             	mov    0x8(%ebp),%eax
  801764:	8b 40 0c             	mov    0xc(%eax),%eax
  801767:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80176c:	ba 00 00 00 00       	mov    $0x0,%edx
  801771:	b8 06 00 00 00       	mov    $0x6,%eax
  801776:	e8 6b ff ff ff       	call   8016e6 <fsipc>
}
  80177b:	c9                   	leave  
  80177c:	c3                   	ret    

0080177d <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	53                   	push   %ebx
  801781:	83 ec 04             	sub    $0x4,%esp
  801784:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801787:	8b 45 08             	mov    0x8(%ebp),%eax
  80178a:	8b 40 0c             	mov    0xc(%eax),%eax
  80178d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801792:	ba 00 00 00 00       	mov    $0x0,%edx
  801797:	b8 05 00 00 00       	mov    $0x5,%eax
  80179c:	e8 45 ff ff ff       	call   8016e6 <fsipc>
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 2c                	js     8017d1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017a5:	83 ec 08             	sub    $0x8,%esp
  8017a8:	68 00 50 80 00       	push   $0x805000
  8017ad:	53                   	push   %ebx
  8017ae:	e8 19 f3 ff ff       	call   800acc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017b3:	a1 80 50 80 00       	mov    0x805080,%eax
  8017b8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017be:	a1 84 50 80 00       	mov    0x805084,%eax
  8017c3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d4:	c9                   	leave  
  8017d5:	c3                   	ret    

008017d6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	53                   	push   %ebx
  8017da:	83 ec 08             	sub    $0x8,%esp
  8017dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8017e0:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017e5:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8017ea:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  8017f8:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017fe:	53                   	push   %ebx
  8017ff:	ff 75 0c             	pushl  0xc(%ebp)
  801802:	68 08 50 80 00       	push   $0x805008
  801807:	e8 52 f4 ff ff       	call   800c5e <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80180c:	ba 00 00 00 00       	mov    $0x0,%edx
  801811:	b8 04 00 00 00       	mov    $0x4,%eax
  801816:	e8 cb fe ff ff       	call   8016e6 <fsipc>
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	85 c0                	test   %eax,%eax
  801820:	78 3d                	js     80185f <devfile_write+0x89>
		return r;

	assert(r <= n);
  801822:	39 d8                	cmp    %ebx,%eax
  801824:	76 19                	jbe    80183f <devfile_write+0x69>
  801826:	68 28 26 80 00       	push   $0x802628
  80182b:	68 2f 26 80 00       	push   $0x80262f
  801830:	68 9f 00 00 00       	push   $0x9f
  801835:	68 44 26 80 00       	push   $0x802644
  80183a:	e8 8d ea ff ff       	call   8002cc <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  80183f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801844:	76 19                	jbe    80185f <devfile_write+0x89>
  801846:	68 5c 26 80 00       	push   $0x80265c
  80184b:	68 2f 26 80 00       	push   $0x80262f
  801850:	68 a0 00 00 00       	push   $0xa0
  801855:	68 44 26 80 00       	push   $0x802644
  80185a:	e8 6d ea ff ff       	call   8002cc <_panic>

	return r;
}
  80185f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801862:	c9                   	leave  
  801863:	c3                   	ret    

00801864 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	56                   	push   %esi
  801868:	53                   	push   %ebx
  801869:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80186c:	8b 45 08             	mov    0x8(%ebp),%eax
  80186f:	8b 40 0c             	mov    0xc(%eax),%eax
  801872:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801877:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80187d:	ba 00 00 00 00       	mov    $0x0,%edx
  801882:	b8 03 00 00 00       	mov    $0x3,%eax
  801887:	e8 5a fe ff ff       	call   8016e6 <fsipc>
  80188c:	89 c3                	mov    %eax,%ebx
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 4b                	js     8018dd <devfile_read+0x79>
		return r;
	assert(r <= n);
  801892:	39 c6                	cmp    %eax,%esi
  801894:	73 16                	jae    8018ac <devfile_read+0x48>
  801896:	68 28 26 80 00       	push   $0x802628
  80189b:	68 2f 26 80 00       	push   $0x80262f
  8018a0:	6a 7e                	push   $0x7e
  8018a2:	68 44 26 80 00       	push   $0x802644
  8018a7:	e8 20 ea ff ff       	call   8002cc <_panic>
	assert(r <= PGSIZE);
  8018ac:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018b1:	7e 16                	jle    8018c9 <devfile_read+0x65>
  8018b3:	68 4f 26 80 00       	push   $0x80264f
  8018b8:	68 2f 26 80 00       	push   $0x80262f
  8018bd:	6a 7f                	push   $0x7f
  8018bf:	68 44 26 80 00       	push   $0x802644
  8018c4:	e8 03 ea ff ff       	call   8002cc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018c9:	83 ec 04             	sub    $0x4,%esp
  8018cc:	50                   	push   %eax
  8018cd:	68 00 50 80 00       	push   $0x805000
  8018d2:	ff 75 0c             	pushl  0xc(%ebp)
  8018d5:	e8 84 f3 ff ff       	call   800c5e <memmove>
	return r;
  8018da:	83 c4 10             	add    $0x10,%esp
}
  8018dd:	89 d8                	mov    %ebx,%eax
  8018df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e2:	5b                   	pop    %ebx
  8018e3:	5e                   	pop    %esi
  8018e4:	5d                   	pop    %ebp
  8018e5:	c3                   	ret    

008018e6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	53                   	push   %ebx
  8018ea:	83 ec 20             	sub    $0x20,%esp
  8018ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018f0:	53                   	push   %ebx
  8018f1:	e8 9d f1 ff ff       	call   800a93 <strlen>
  8018f6:	83 c4 10             	add    $0x10,%esp
  8018f9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018fe:	7f 67                	jg     801967 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801900:	83 ec 0c             	sub    $0xc,%esp
  801903:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801906:	50                   	push   %eax
  801907:	e8 52 f8 ff ff       	call   80115e <fd_alloc>
  80190c:	83 c4 10             	add    $0x10,%esp
		return r;
  80190f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801911:	85 c0                	test   %eax,%eax
  801913:	78 57                	js     80196c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801915:	83 ec 08             	sub    $0x8,%esp
  801918:	53                   	push   %ebx
  801919:	68 00 50 80 00       	push   $0x805000
  80191e:	e8 a9 f1 ff ff       	call   800acc <strcpy>
	fsipcbuf.open.req_omode = mode;
  801923:	8b 45 0c             	mov    0xc(%ebp),%eax
  801926:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80192b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80192e:	b8 01 00 00 00       	mov    $0x1,%eax
  801933:	e8 ae fd ff ff       	call   8016e6 <fsipc>
  801938:	89 c3                	mov    %eax,%ebx
  80193a:	83 c4 10             	add    $0x10,%esp
  80193d:	85 c0                	test   %eax,%eax
  80193f:	79 14                	jns    801955 <open+0x6f>
		fd_close(fd, 0);
  801941:	83 ec 08             	sub    $0x8,%esp
  801944:	6a 00                	push   $0x0
  801946:	ff 75 f4             	pushl  -0xc(%ebp)
  801949:	e8 08 f9 ff ff       	call   801256 <fd_close>
		return r;
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	89 da                	mov    %ebx,%edx
  801953:	eb 17                	jmp    80196c <open+0x86>
	}

	return fd2num(fd);
  801955:	83 ec 0c             	sub    $0xc,%esp
  801958:	ff 75 f4             	pushl  -0xc(%ebp)
  80195b:	e8 d7 f7 ff ff       	call   801137 <fd2num>
  801960:	89 c2                	mov    %eax,%edx
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	eb 05                	jmp    80196c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801967:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80196c:	89 d0                	mov    %edx,%eax
  80196e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801971:	c9                   	leave  
  801972:	c3                   	ret    

00801973 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801979:	ba 00 00 00 00       	mov    $0x0,%edx
  80197e:	b8 08 00 00 00       	mov    $0x8,%eax
  801983:	e8 5e fd ff ff       	call   8016e6 <fsipc>
}
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80198a:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80198e:	7e 37                	jle    8019c7 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	53                   	push   %ebx
  801994:	83 ec 08             	sub    $0x8,%esp
  801997:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801999:	ff 70 04             	pushl  0x4(%eax)
  80199c:	8d 40 10             	lea    0x10(%eax),%eax
  80199f:	50                   	push   %eax
  8019a0:	ff 33                	pushl  (%ebx)
  8019a2:	e8 46 fb ff ff       	call   8014ed <write>
		if (result > 0)
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	85 c0                	test   %eax,%eax
  8019ac:	7e 03                	jle    8019b1 <writebuf+0x27>
			b->result += result;
  8019ae:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8019b1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019b4:	74 0d                	je     8019c3 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bd:	0f 4f c2             	cmovg  %edx,%eax
  8019c0:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8019c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c6:	c9                   	leave  
  8019c7:	f3 c3                	repz ret 

008019c9 <putch>:

static void
putch(int ch, void *thunk)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	53                   	push   %ebx
  8019cd:	83 ec 04             	sub    $0x4,%esp
  8019d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8019d3:	8b 53 04             	mov    0x4(%ebx),%edx
  8019d6:	8d 42 01             	lea    0x1(%edx),%eax
  8019d9:	89 43 04             	mov    %eax,0x4(%ebx)
  8019dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019df:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8019e3:	3d 00 01 00 00       	cmp    $0x100,%eax
  8019e8:	75 0e                	jne    8019f8 <putch+0x2f>
		writebuf(b);
  8019ea:	89 d8                	mov    %ebx,%eax
  8019ec:	e8 99 ff ff ff       	call   80198a <writebuf>
		b->idx = 0;
  8019f1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8019f8:	83 c4 04             	add    $0x4,%esp
  8019fb:	5b                   	pop    %ebx
  8019fc:	5d                   	pop    %ebp
  8019fd:	c3                   	ret    

008019fe <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801a07:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0a:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801a10:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801a17:	00 00 00 
	b.result = 0;
  801a1a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a21:	00 00 00 
	b.error = 1;
  801a24:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801a2b:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801a2e:	ff 75 10             	pushl  0x10(%ebp)
  801a31:	ff 75 0c             	pushl  0xc(%ebp)
  801a34:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a3a:	50                   	push   %eax
  801a3b:	68 c9 19 80 00       	push   $0x8019c9
  801a40:	e8 97 ea ff ff       	call   8004dc <vprintfmt>
	if (b.idx > 0)
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801a4f:	7e 0b                	jle    801a5c <vfprintf+0x5e>
		writebuf(&b);
  801a51:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a57:	e8 2e ff ff ff       	call   80198a <writebuf>

	return (b.result ? b.result : b.error);
  801a5c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801a62:	85 c0                	test   %eax,%eax
  801a64:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a73:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a76:	50                   	push   %eax
  801a77:	ff 75 0c             	pushl  0xc(%ebp)
  801a7a:	ff 75 08             	pushl  0x8(%ebp)
  801a7d:	e8 7c ff ff ff       	call   8019fe <vfprintf>
	va_end(ap);

	return cnt;
}
  801a82:	c9                   	leave  
  801a83:	c3                   	ret    

00801a84 <printf>:

int
printf(const char *fmt, ...)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a8a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a8d:	50                   	push   %eax
  801a8e:	ff 75 08             	pushl  0x8(%ebp)
  801a91:	6a 01                	push   $0x1
  801a93:	e8 66 ff ff ff       	call   8019fe <vfprintf>
	va_end(ap);

	return cnt;
}
  801a98:	c9                   	leave  
  801a99:	c3                   	ret    

00801a9a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	56                   	push   %esi
  801a9e:	53                   	push   %ebx
  801a9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801aa2:	83 ec 0c             	sub    $0xc,%esp
  801aa5:	ff 75 08             	pushl  0x8(%ebp)
  801aa8:	e8 9a f6 ff ff       	call   801147 <fd2data>
  801aad:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aaf:	83 c4 08             	add    $0x8,%esp
  801ab2:	68 89 26 80 00       	push   $0x802689
  801ab7:	53                   	push   %ebx
  801ab8:	e8 0f f0 ff ff       	call   800acc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801abd:	8b 46 04             	mov    0x4(%esi),%eax
  801ac0:	2b 06                	sub    (%esi),%eax
  801ac2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ac8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801acf:	00 00 00 
	stat->st_dev = &devpipe;
  801ad2:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ad9:	30 80 00 
	return 0;
}
  801adc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae4:	5b                   	pop    %ebx
  801ae5:	5e                   	pop    %esi
  801ae6:	5d                   	pop    %ebp
  801ae7:	c3                   	ret    

00801ae8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	53                   	push   %ebx
  801aec:	83 ec 0c             	sub    $0xc,%esp
  801aef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801af2:	53                   	push   %ebx
  801af3:	6a 00                	push   $0x0
  801af5:	e8 d1 f4 ff ff       	call   800fcb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801afa:	89 1c 24             	mov    %ebx,(%esp)
  801afd:	e8 45 f6 ff ff       	call   801147 <fd2data>
  801b02:	83 c4 08             	add    $0x8,%esp
  801b05:	50                   	push   %eax
  801b06:	6a 00                	push   $0x0
  801b08:	e8 be f4 ff ff       	call   800fcb <sys_page_unmap>
}
  801b0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    

00801b12 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	57                   	push   %edi
  801b16:	56                   	push   %esi
  801b17:	53                   	push   %ebx
  801b18:	83 ec 1c             	sub    $0x1c,%esp
  801b1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b1e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b20:	a1 24 44 80 00       	mov    0x804424,%eax
  801b25:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b28:	83 ec 0c             	sub    $0xc,%esp
  801b2b:	ff 75 e0             	pushl  -0x20(%ebp)
  801b2e:	e8 bb 03 00 00       	call   801eee <pageref>
  801b33:	89 c3                	mov    %eax,%ebx
  801b35:	89 3c 24             	mov    %edi,(%esp)
  801b38:	e8 b1 03 00 00       	call   801eee <pageref>
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	39 c3                	cmp    %eax,%ebx
  801b42:	0f 94 c1             	sete   %cl
  801b45:	0f b6 c9             	movzbl %cl,%ecx
  801b48:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b4b:	8b 15 24 44 80 00    	mov    0x804424,%edx
  801b51:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b54:	39 ce                	cmp    %ecx,%esi
  801b56:	74 1b                	je     801b73 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b58:	39 c3                	cmp    %eax,%ebx
  801b5a:	75 c4                	jne    801b20 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b5c:	8b 42 58             	mov    0x58(%edx),%eax
  801b5f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b62:	50                   	push   %eax
  801b63:	56                   	push   %esi
  801b64:	68 90 26 80 00       	push   $0x802690
  801b69:	e8 37 e8 ff ff       	call   8003a5 <cprintf>
  801b6e:	83 c4 10             	add    $0x10,%esp
  801b71:	eb ad                	jmp    801b20 <_pipeisclosed+0xe>
	}
}
  801b73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b79:	5b                   	pop    %ebx
  801b7a:	5e                   	pop    %esi
  801b7b:	5f                   	pop    %edi
  801b7c:	5d                   	pop    %ebp
  801b7d:	c3                   	ret    

00801b7e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	57                   	push   %edi
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	83 ec 28             	sub    $0x28,%esp
  801b87:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b8a:	56                   	push   %esi
  801b8b:	e8 b7 f5 ff ff       	call   801147 <fd2data>
  801b90:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b92:	83 c4 10             	add    $0x10,%esp
  801b95:	bf 00 00 00 00       	mov    $0x0,%edi
  801b9a:	eb 4b                	jmp    801be7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b9c:	89 da                	mov    %ebx,%edx
  801b9e:	89 f0                	mov    %esi,%eax
  801ba0:	e8 6d ff ff ff       	call   801b12 <_pipeisclosed>
  801ba5:	85 c0                	test   %eax,%eax
  801ba7:	75 48                	jne    801bf1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ba9:	e8 79 f3 ff ff       	call   800f27 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bae:	8b 43 04             	mov    0x4(%ebx),%eax
  801bb1:	8b 0b                	mov    (%ebx),%ecx
  801bb3:	8d 51 20             	lea    0x20(%ecx),%edx
  801bb6:	39 d0                	cmp    %edx,%eax
  801bb8:	73 e2                	jae    801b9c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bc1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bc4:	89 c2                	mov    %eax,%edx
  801bc6:	c1 fa 1f             	sar    $0x1f,%edx
  801bc9:	89 d1                	mov    %edx,%ecx
  801bcb:	c1 e9 1b             	shr    $0x1b,%ecx
  801bce:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bd1:	83 e2 1f             	and    $0x1f,%edx
  801bd4:	29 ca                	sub    %ecx,%edx
  801bd6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bda:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bde:	83 c0 01             	add    $0x1,%eax
  801be1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be4:	83 c7 01             	add    $0x1,%edi
  801be7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bea:	75 c2                	jne    801bae <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bec:	8b 45 10             	mov    0x10(%ebp),%eax
  801bef:	eb 05                	jmp    801bf6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bf1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf9:	5b                   	pop    %ebx
  801bfa:	5e                   	pop    %esi
  801bfb:	5f                   	pop    %edi
  801bfc:	5d                   	pop    %ebp
  801bfd:	c3                   	ret    

00801bfe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	57                   	push   %edi
  801c02:	56                   	push   %esi
  801c03:	53                   	push   %ebx
  801c04:	83 ec 18             	sub    $0x18,%esp
  801c07:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c0a:	57                   	push   %edi
  801c0b:	e8 37 f5 ff ff       	call   801147 <fd2data>
  801c10:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c12:	83 c4 10             	add    $0x10,%esp
  801c15:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c1a:	eb 3d                	jmp    801c59 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c1c:	85 db                	test   %ebx,%ebx
  801c1e:	74 04                	je     801c24 <devpipe_read+0x26>
				return i;
  801c20:	89 d8                	mov    %ebx,%eax
  801c22:	eb 44                	jmp    801c68 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c24:	89 f2                	mov    %esi,%edx
  801c26:	89 f8                	mov    %edi,%eax
  801c28:	e8 e5 fe ff ff       	call   801b12 <_pipeisclosed>
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	75 32                	jne    801c63 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c31:	e8 f1 f2 ff ff       	call   800f27 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c36:	8b 06                	mov    (%esi),%eax
  801c38:	3b 46 04             	cmp    0x4(%esi),%eax
  801c3b:	74 df                	je     801c1c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c3d:	99                   	cltd   
  801c3e:	c1 ea 1b             	shr    $0x1b,%edx
  801c41:	01 d0                	add    %edx,%eax
  801c43:	83 e0 1f             	and    $0x1f,%eax
  801c46:	29 d0                	sub    %edx,%eax
  801c48:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c50:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c53:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c56:	83 c3 01             	add    $0x1,%ebx
  801c59:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c5c:	75 d8                	jne    801c36 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c5e:	8b 45 10             	mov    0x10(%ebp),%eax
  801c61:	eb 05                	jmp    801c68 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c63:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c6b:	5b                   	pop    %ebx
  801c6c:	5e                   	pop    %esi
  801c6d:	5f                   	pop    %edi
  801c6e:	5d                   	pop    %ebp
  801c6f:	c3                   	ret    

00801c70 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	56                   	push   %esi
  801c74:	53                   	push   %ebx
  801c75:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7b:	50                   	push   %eax
  801c7c:	e8 dd f4 ff ff       	call   80115e <fd_alloc>
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	89 c2                	mov    %eax,%edx
  801c86:	85 c0                	test   %eax,%eax
  801c88:	0f 88 2c 01 00 00    	js     801dba <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8e:	83 ec 04             	sub    $0x4,%esp
  801c91:	68 07 04 00 00       	push   $0x407
  801c96:	ff 75 f4             	pushl  -0xc(%ebp)
  801c99:	6a 00                	push   $0x0
  801c9b:	e8 a6 f2 ff ff       	call   800f46 <sys_page_alloc>
  801ca0:	83 c4 10             	add    $0x10,%esp
  801ca3:	89 c2                	mov    %eax,%edx
  801ca5:	85 c0                	test   %eax,%eax
  801ca7:	0f 88 0d 01 00 00    	js     801dba <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cad:	83 ec 0c             	sub    $0xc,%esp
  801cb0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cb3:	50                   	push   %eax
  801cb4:	e8 a5 f4 ff ff       	call   80115e <fd_alloc>
  801cb9:	89 c3                	mov    %eax,%ebx
  801cbb:	83 c4 10             	add    $0x10,%esp
  801cbe:	85 c0                	test   %eax,%eax
  801cc0:	0f 88 e2 00 00 00    	js     801da8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc6:	83 ec 04             	sub    $0x4,%esp
  801cc9:	68 07 04 00 00       	push   $0x407
  801cce:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd1:	6a 00                	push   $0x0
  801cd3:	e8 6e f2 ff ff       	call   800f46 <sys_page_alloc>
  801cd8:	89 c3                	mov    %eax,%ebx
  801cda:	83 c4 10             	add    $0x10,%esp
  801cdd:	85 c0                	test   %eax,%eax
  801cdf:	0f 88 c3 00 00 00    	js     801da8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ce5:	83 ec 0c             	sub    $0xc,%esp
  801ce8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ceb:	e8 57 f4 ff ff       	call   801147 <fd2data>
  801cf0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf2:	83 c4 0c             	add    $0xc,%esp
  801cf5:	68 07 04 00 00       	push   $0x407
  801cfa:	50                   	push   %eax
  801cfb:	6a 00                	push   $0x0
  801cfd:	e8 44 f2 ff ff       	call   800f46 <sys_page_alloc>
  801d02:	89 c3                	mov    %eax,%ebx
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	85 c0                	test   %eax,%eax
  801d09:	0f 88 89 00 00 00    	js     801d98 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d0f:	83 ec 0c             	sub    $0xc,%esp
  801d12:	ff 75 f0             	pushl  -0x10(%ebp)
  801d15:	e8 2d f4 ff ff       	call   801147 <fd2data>
  801d1a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d21:	50                   	push   %eax
  801d22:	6a 00                	push   $0x0
  801d24:	56                   	push   %esi
  801d25:	6a 00                	push   $0x0
  801d27:	e8 5d f2 ff ff       	call   800f89 <sys_page_map>
  801d2c:	89 c3                	mov    %eax,%ebx
  801d2e:	83 c4 20             	add    $0x20,%esp
  801d31:	85 c0                	test   %eax,%eax
  801d33:	78 55                	js     801d8a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d35:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d43:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d4a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d53:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d58:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d5f:	83 ec 0c             	sub    $0xc,%esp
  801d62:	ff 75 f4             	pushl  -0xc(%ebp)
  801d65:	e8 cd f3 ff ff       	call   801137 <fd2num>
  801d6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d6d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d6f:	83 c4 04             	add    $0x4,%esp
  801d72:	ff 75 f0             	pushl  -0x10(%ebp)
  801d75:	e8 bd f3 ff ff       	call   801137 <fd2num>
  801d7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d7d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d80:	83 c4 10             	add    $0x10,%esp
  801d83:	ba 00 00 00 00       	mov    $0x0,%edx
  801d88:	eb 30                	jmp    801dba <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d8a:	83 ec 08             	sub    $0x8,%esp
  801d8d:	56                   	push   %esi
  801d8e:	6a 00                	push   $0x0
  801d90:	e8 36 f2 ff ff       	call   800fcb <sys_page_unmap>
  801d95:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d98:	83 ec 08             	sub    $0x8,%esp
  801d9b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9e:	6a 00                	push   $0x0
  801da0:	e8 26 f2 ff ff       	call   800fcb <sys_page_unmap>
  801da5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801da8:	83 ec 08             	sub    $0x8,%esp
  801dab:	ff 75 f4             	pushl  -0xc(%ebp)
  801dae:	6a 00                	push   $0x0
  801db0:	e8 16 f2 ff ff       	call   800fcb <sys_page_unmap>
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dba:	89 d0                	mov    %edx,%eax
  801dbc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dbf:	5b                   	pop    %ebx
  801dc0:	5e                   	pop    %esi
  801dc1:	5d                   	pop    %ebp
  801dc2:	c3                   	ret    

00801dc3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dcc:	50                   	push   %eax
  801dcd:	ff 75 08             	pushl  0x8(%ebp)
  801dd0:	e8 d8 f3 ff ff       	call   8011ad <fd_lookup>
  801dd5:	83 c4 10             	add    $0x10,%esp
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	78 18                	js     801df4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ddc:	83 ec 0c             	sub    $0xc,%esp
  801ddf:	ff 75 f4             	pushl  -0xc(%ebp)
  801de2:	e8 60 f3 ff ff       	call   801147 <fd2data>
	return _pipeisclosed(fd, p);
  801de7:	89 c2                	mov    %eax,%edx
  801de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dec:	e8 21 fd ff ff       	call   801b12 <_pipeisclosed>
  801df1:	83 c4 10             	add    $0x10,%esp
}
  801df4:	c9                   	leave  
  801df5:	c3                   	ret    

00801df6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	56                   	push   %esi
  801dfa:	53                   	push   %ebx
  801dfb:	8b 75 08             	mov    0x8(%ebp),%esi
  801dfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801e04:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801e06:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e0b:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801e0e:	83 ec 0c             	sub    $0xc,%esp
  801e11:	50                   	push   %eax
  801e12:	e8 df f2 ff ff       	call   8010f6 <sys_ipc_recv>
  801e17:	83 c4 10             	add    $0x10,%esp
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	79 16                	jns    801e34 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801e1e:	85 f6                	test   %esi,%esi
  801e20:	74 06                	je     801e28 <ipc_recv+0x32>
			*from_env_store = 0;
  801e22:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801e28:	85 db                	test   %ebx,%ebx
  801e2a:	74 2c                	je     801e58 <ipc_recv+0x62>
			*perm_store = 0;
  801e2c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801e32:	eb 24                	jmp    801e58 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801e34:	85 f6                	test   %esi,%esi
  801e36:	74 0a                	je     801e42 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801e38:	a1 24 44 80 00       	mov    0x804424,%eax
  801e3d:	8b 40 74             	mov    0x74(%eax),%eax
  801e40:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801e42:	85 db                	test   %ebx,%ebx
  801e44:	74 0a                	je     801e50 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801e46:	a1 24 44 80 00       	mov    0x804424,%eax
  801e4b:	8b 40 78             	mov    0x78(%eax),%eax
  801e4e:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801e50:	a1 24 44 80 00       	mov    0x804424,%eax
  801e55:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e5b:	5b                   	pop    %ebx
  801e5c:	5e                   	pop    %esi
  801e5d:	5d                   	pop    %ebp
  801e5e:	c3                   	ret    

00801e5f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e5f:	55                   	push   %ebp
  801e60:	89 e5                	mov    %esp,%ebp
  801e62:	57                   	push   %edi
  801e63:	56                   	push   %esi
  801e64:	53                   	push   %ebx
  801e65:	83 ec 0c             	sub    $0xc,%esp
  801e68:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e6b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801e71:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801e73:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e78:	0f 44 d8             	cmove  %eax,%ebx
  801e7b:	eb 1e                	jmp    801e9b <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801e7d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e80:	74 14                	je     801e96 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801e82:	83 ec 04             	sub    $0x4,%esp
  801e85:	68 a8 26 80 00       	push   $0x8026a8
  801e8a:	6a 44                	push   $0x44
  801e8c:	68 d4 26 80 00       	push   $0x8026d4
  801e91:	e8 36 e4 ff ff       	call   8002cc <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801e96:	e8 8c f0 ff ff       	call   800f27 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801e9b:	ff 75 14             	pushl  0x14(%ebp)
  801e9e:	53                   	push   %ebx
  801e9f:	56                   	push   %esi
  801ea0:	57                   	push   %edi
  801ea1:	e8 2d f2 ff ff       	call   8010d3 <sys_ipc_try_send>
  801ea6:	83 c4 10             	add    $0x10,%esp
  801ea9:	85 c0                	test   %eax,%eax
  801eab:	78 d0                	js     801e7d <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801ead:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb0:	5b                   	pop    %ebx
  801eb1:	5e                   	pop    %esi
  801eb2:	5f                   	pop    %edi
  801eb3:	5d                   	pop    %ebp
  801eb4:	c3                   	ret    

00801eb5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eb5:	55                   	push   %ebp
  801eb6:	89 e5                	mov    %esp,%ebp
  801eb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ebb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ec0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ec3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ec9:	8b 52 50             	mov    0x50(%edx),%edx
  801ecc:	39 ca                	cmp    %ecx,%edx
  801ece:	75 0d                	jne    801edd <ipc_find_env+0x28>
			return envs[i].env_id;
  801ed0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ed3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ed8:	8b 40 48             	mov    0x48(%eax),%eax
  801edb:	eb 0f                	jmp    801eec <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801edd:	83 c0 01             	add    $0x1,%eax
  801ee0:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ee5:	75 d9                	jne    801ec0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ee7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eec:	5d                   	pop    %ebp
  801eed:	c3                   	ret    

00801eee <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ef4:	89 d0                	mov    %edx,%eax
  801ef6:	c1 e8 16             	shr    $0x16,%eax
  801ef9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f00:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f05:	f6 c1 01             	test   $0x1,%cl
  801f08:	74 1d                	je     801f27 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f0a:	c1 ea 0c             	shr    $0xc,%edx
  801f0d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f14:	f6 c2 01             	test   $0x1,%dl
  801f17:	74 0e                	je     801f27 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f19:	c1 ea 0c             	shr    $0xc,%edx
  801f1c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f23:	ef 
  801f24:	0f b7 c0             	movzwl %ax,%eax
}
  801f27:	5d                   	pop    %ebp
  801f28:	c3                   	ret    
  801f29:	66 90                	xchg   %ax,%ax
  801f2b:	66 90                	xchg   %ax,%ax
  801f2d:	66 90                	xchg   %ax,%ax
  801f2f:	90                   	nop

00801f30 <__udivdi3>:
  801f30:	55                   	push   %ebp
  801f31:	57                   	push   %edi
  801f32:	56                   	push   %esi
  801f33:	53                   	push   %ebx
  801f34:	83 ec 1c             	sub    $0x1c,%esp
  801f37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f47:	85 f6                	test   %esi,%esi
  801f49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f4d:	89 ca                	mov    %ecx,%edx
  801f4f:	89 f8                	mov    %edi,%eax
  801f51:	75 3d                	jne    801f90 <__udivdi3+0x60>
  801f53:	39 cf                	cmp    %ecx,%edi
  801f55:	0f 87 c5 00 00 00    	ja     802020 <__udivdi3+0xf0>
  801f5b:	85 ff                	test   %edi,%edi
  801f5d:	89 fd                	mov    %edi,%ebp
  801f5f:	75 0b                	jne    801f6c <__udivdi3+0x3c>
  801f61:	b8 01 00 00 00       	mov    $0x1,%eax
  801f66:	31 d2                	xor    %edx,%edx
  801f68:	f7 f7                	div    %edi
  801f6a:	89 c5                	mov    %eax,%ebp
  801f6c:	89 c8                	mov    %ecx,%eax
  801f6e:	31 d2                	xor    %edx,%edx
  801f70:	f7 f5                	div    %ebp
  801f72:	89 c1                	mov    %eax,%ecx
  801f74:	89 d8                	mov    %ebx,%eax
  801f76:	89 cf                	mov    %ecx,%edi
  801f78:	f7 f5                	div    %ebp
  801f7a:	89 c3                	mov    %eax,%ebx
  801f7c:	89 d8                	mov    %ebx,%eax
  801f7e:	89 fa                	mov    %edi,%edx
  801f80:	83 c4 1c             	add    $0x1c,%esp
  801f83:	5b                   	pop    %ebx
  801f84:	5e                   	pop    %esi
  801f85:	5f                   	pop    %edi
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    
  801f88:	90                   	nop
  801f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f90:	39 ce                	cmp    %ecx,%esi
  801f92:	77 74                	ja     802008 <__udivdi3+0xd8>
  801f94:	0f bd fe             	bsr    %esi,%edi
  801f97:	83 f7 1f             	xor    $0x1f,%edi
  801f9a:	0f 84 98 00 00 00    	je     802038 <__udivdi3+0x108>
  801fa0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fa5:	89 f9                	mov    %edi,%ecx
  801fa7:	89 c5                	mov    %eax,%ebp
  801fa9:	29 fb                	sub    %edi,%ebx
  801fab:	d3 e6                	shl    %cl,%esi
  801fad:	89 d9                	mov    %ebx,%ecx
  801faf:	d3 ed                	shr    %cl,%ebp
  801fb1:	89 f9                	mov    %edi,%ecx
  801fb3:	d3 e0                	shl    %cl,%eax
  801fb5:	09 ee                	or     %ebp,%esi
  801fb7:	89 d9                	mov    %ebx,%ecx
  801fb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fbd:	89 d5                	mov    %edx,%ebp
  801fbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fc3:	d3 ed                	shr    %cl,%ebp
  801fc5:	89 f9                	mov    %edi,%ecx
  801fc7:	d3 e2                	shl    %cl,%edx
  801fc9:	89 d9                	mov    %ebx,%ecx
  801fcb:	d3 e8                	shr    %cl,%eax
  801fcd:	09 c2                	or     %eax,%edx
  801fcf:	89 d0                	mov    %edx,%eax
  801fd1:	89 ea                	mov    %ebp,%edx
  801fd3:	f7 f6                	div    %esi
  801fd5:	89 d5                	mov    %edx,%ebp
  801fd7:	89 c3                	mov    %eax,%ebx
  801fd9:	f7 64 24 0c          	mull   0xc(%esp)
  801fdd:	39 d5                	cmp    %edx,%ebp
  801fdf:	72 10                	jb     801ff1 <__udivdi3+0xc1>
  801fe1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	d3 e6                	shl    %cl,%esi
  801fe9:	39 c6                	cmp    %eax,%esi
  801feb:	73 07                	jae    801ff4 <__udivdi3+0xc4>
  801fed:	39 d5                	cmp    %edx,%ebp
  801fef:	75 03                	jne    801ff4 <__udivdi3+0xc4>
  801ff1:	83 eb 01             	sub    $0x1,%ebx
  801ff4:	31 ff                	xor    %edi,%edi
  801ff6:	89 d8                	mov    %ebx,%eax
  801ff8:	89 fa                	mov    %edi,%edx
  801ffa:	83 c4 1c             	add    $0x1c,%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5e                   	pop    %esi
  801fff:	5f                   	pop    %edi
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    
  802002:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802008:	31 ff                	xor    %edi,%edi
  80200a:	31 db                	xor    %ebx,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	89 d8                	mov    %ebx,%eax
  802022:	f7 f7                	div    %edi
  802024:	31 ff                	xor    %edi,%edi
  802026:	89 c3                	mov    %eax,%ebx
  802028:	89 d8                	mov    %ebx,%eax
  80202a:	89 fa                	mov    %edi,%edx
  80202c:	83 c4 1c             	add    $0x1c,%esp
  80202f:	5b                   	pop    %ebx
  802030:	5e                   	pop    %esi
  802031:	5f                   	pop    %edi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    
  802034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802038:	39 ce                	cmp    %ecx,%esi
  80203a:	72 0c                	jb     802048 <__udivdi3+0x118>
  80203c:	31 db                	xor    %ebx,%ebx
  80203e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802042:	0f 87 34 ff ff ff    	ja     801f7c <__udivdi3+0x4c>
  802048:	bb 01 00 00 00       	mov    $0x1,%ebx
  80204d:	e9 2a ff ff ff       	jmp    801f7c <__udivdi3+0x4c>
  802052:	66 90                	xchg   %ax,%ax
  802054:	66 90                	xchg   %ax,%ax
  802056:	66 90                	xchg   %ax,%ax
  802058:	66 90                	xchg   %ax,%ax
  80205a:	66 90                	xchg   %ax,%ax
  80205c:	66 90                	xchg   %ax,%ax
  80205e:	66 90                	xchg   %ax,%ax

00802060 <__umoddi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 1c             	sub    $0x1c,%esp
  802067:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80206b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80206f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802077:	85 d2                	test   %edx,%edx
  802079:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80207d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802081:	89 f3                	mov    %esi,%ebx
  802083:	89 3c 24             	mov    %edi,(%esp)
  802086:	89 74 24 04          	mov    %esi,0x4(%esp)
  80208a:	75 1c                	jne    8020a8 <__umoddi3+0x48>
  80208c:	39 f7                	cmp    %esi,%edi
  80208e:	76 50                	jbe    8020e0 <__umoddi3+0x80>
  802090:	89 c8                	mov    %ecx,%eax
  802092:	89 f2                	mov    %esi,%edx
  802094:	f7 f7                	div    %edi
  802096:	89 d0                	mov    %edx,%eax
  802098:	31 d2                	xor    %edx,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	39 f2                	cmp    %esi,%edx
  8020aa:	89 d0                	mov    %edx,%eax
  8020ac:	77 52                	ja     802100 <__umoddi3+0xa0>
  8020ae:	0f bd ea             	bsr    %edx,%ebp
  8020b1:	83 f5 1f             	xor    $0x1f,%ebp
  8020b4:	75 5a                	jne    802110 <__umoddi3+0xb0>
  8020b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ba:	0f 82 e0 00 00 00    	jb     8021a0 <__umoddi3+0x140>
  8020c0:	39 0c 24             	cmp    %ecx,(%esp)
  8020c3:	0f 86 d7 00 00 00    	jbe    8021a0 <__umoddi3+0x140>
  8020c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020d1:	83 c4 1c             	add    $0x1c,%esp
  8020d4:	5b                   	pop    %ebx
  8020d5:	5e                   	pop    %esi
  8020d6:	5f                   	pop    %edi
  8020d7:	5d                   	pop    %ebp
  8020d8:	c3                   	ret    
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	85 ff                	test   %edi,%edi
  8020e2:	89 fd                	mov    %edi,%ebp
  8020e4:	75 0b                	jne    8020f1 <__umoddi3+0x91>
  8020e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020eb:	31 d2                	xor    %edx,%edx
  8020ed:	f7 f7                	div    %edi
  8020ef:	89 c5                	mov    %eax,%ebp
  8020f1:	89 f0                	mov    %esi,%eax
  8020f3:	31 d2                	xor    %edx,%edx
  8020f5:	f7 f5                	div    %ebp
  8020f7:	89 c8                	mov    %ecx,%eax
  8020f9:	f7 f5                	div    %ebp
  8020fb:	89 d0                	mov    %edx,%eax
  8020fd:	eb 99                	jmp    802098 <__umoddi3+0x38>
  8020ff:	90                   	nop
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 f2                	mov    %esi,%edx
  802104:	83 c4 1c             	add    $0x1c,%esp
  802107:	5b                   	pop    %ebx
  802108:	5e                   	pop    %esi
  802109:	5f                   	pop    %edi
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    
  80210c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802110:	8b 34 24             	mov    (%esp),%esi
  802113:	bf 20 00 00 00       	mov    $0x20,%edi
  802118:	89 e9                	mov    %ebp,%ecx
  80211a:	29 ef                	sub    %ebp,%edi
  80211c:	d3 e0                	shl    %cl,%eax
  80211e:	89 f9                	mov    %edi,%ecx
  802120:	89 f2                	mov    %esi,%edx
  802122:	d3 ea                	shr    %cl,%edx
  802124:	89 e9                	mov    %ebp,%ecx
  802126:	09 c2                	or     %eax,%edx
  802128:	89 d8                	mov    %ebx,%eax
  80212a:	89 14 24             	mov    %edx,(%esp)
  80212d:	89 f2                	mov    %esi,%edx
  80212f:	d3 e2                	shl    %cl,%edx
  802131:	89 f9                	mov    %edi,%ecx
  802133:	89 54 24 04          	mov    %edx,0x4(%esp)
  802137:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80213b:	d3 e8                	shr    %cl,%eax
  80213d:	89 e9                	mov    %ebp,%ecx
  80213f:	89 c6                	mov    %eax,%esi
  802141:	d3 e3                	shl    %cl,%ebx
  802143:	89 f9                	mov    %edi,%ecx
  802145:	89 d0                	mov    %edx,%eax
  802147:	d3 e8                	shr    %cl,%eax
  802149:	89 e9                	mov    %ebp,%ecx
  80214b:	09 d8                	or     %ebx,%eax
  80214d:	89 d3                	mov    %edx,%ebx
  80214f:	89 f2                	mov    %esi,%edx
  802151:	f7 34 24             	divl   (%esp)
  802154:	89 d6                	mov    %edx,%esi
  802156:	d3 e3                	shl    %cl,%ebx
  802158:	f7 64 24 04          	mull   0x4(%esp)
  80215c:	39 d6                	cmp    %edx,%esi
  80215e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802162:	89 d1                	mov    %edx,%ecx
  802164:	89 c3                	mov    %eax,%ebx
  802166:	72 08                	jb     802170 <__umoddi3+0x110>
  802168:	75 11                	jne    80217b <__umoddi3+0x11b>
  80216a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80216e:	73 0b                	jae    80217b <__umoddi3+0x11b>
  802170:	2b 44 24 04          	sub    0x4(%esp),%eax
  802174:	1b 14 24             	sbb    (%esp),%edx
  802177:	89 d1                	mov    %edx,%ecx
  802179:	89 c3                	mov    %eax,%ebx
  80217b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80217f:	29 da                	sub    %ebx,%edx
  802181:	19 ce                	sbb    %ecx,%esi
  802183:	89 f9                	mov    %edi,%ecx
  802185:	89 f0                	mov    %esi,%eax
  802187:	d3 e0                	shl    %cl,%eax
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	d3 ea                	shr    %cl,%edx
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	d3 ee                	shr    %cl,%esi
  802191:	09 d0                	or     %edx,%eax
  802193:	89 f2                	mov    %esi,%edx
  802195:	83 c4 1c             	add    $0x1c,%esp
  802198:	5b                   	pop    %ebx
  802199:	5e                   	pop    %esi
  80219a:	5f                   	pop    %edi
  80219b:	5d                   	pop    %ebp
  80219c:	c3                   	ret    
  80219d:	8d 76 00             	lea    0x0(%esi),%esi
  8021a0:	29 f9                	sub    %edi,%ecx
  8021a2:	19 d6                	sbb    %edx,%esi
  8021a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ac:	e9 18 ff ff ff       	jmp    8020c9 <__umoddi3+0x69>
