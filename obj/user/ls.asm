
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 93 02 00 00       	call   8002c4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80003e:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800045:	74 20                	je     800067 <ls1+0x34>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800047:	89 f0                	mov    %esi,%eax
  800049:	3c 01                	cmp    $0x1,%al
  80004b:	19 c0                	sbb    %eax,%eax
  80004d:	83 e0 c9             	and    $0xffffffc9,%eax
  800050:	83 c0 64             	add    $0x64,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	ff 75 10             	pushl  0x10(%ebp)
  80005a:	68 02 24 80 00       	push   $0x802402
  80005f:	e8 d9 1a 00 00       	call   801b3d <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 68 24 80 00       	mov    $0x802468,%eax
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	74 1e                	je     800093 <ls1+0x60>
  800075:	83 ec 0c             	sub    $0xc,%esp
  800078:	53                   	push   %ebx
  800079:	e8 7a 09 00 00       	call   8009f8 <strlen>
  80007e:	83 c4 10             	add    $0x10,%esp
			sep = "/";
		else
			sep = "";
  800081:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800086:	ba 68 24 80 00       	mov    $0x802468,%edx
  80008b:	b8 00 24 80 00       	mov    $0x802400,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 0b 24 80 00       	push   $0x80240b
  80009d:	e8 9b 1a 00 00       	call   801b3d <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 91 28 80 00       	push   $0x802891
  8000b0:	e8 88 1a 00 00       	call   801b3d <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000bf:	74 16                	je     8000d7 <ls1+0xa4>
  8000c1:	89 f0                	mov    %esi,%eax
  8000c3:	84 c0                	test   %al,%al
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 00 24 80 00       	push   $0x802400
  8000cf:	e8 69 1a 00 00       	call   801b3d <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 67 24 80 00       	push   $0x802467
  8000df:	e8 59 1a 00 00       	call   801b3d <printf>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	81 ec 14 01 00 00    	sub    $0x114,%esp
  8000fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fd:	6a 00                	push   $0x0
  8000ff:	57                   	push   %edi
  800100:	e8 9a 18 00 00       	call   80199f <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 10 24 80 00       	push   $0x802410
  800118:	6a 1d                	push   $0x1d
  80011a:	68 1c 24 80 00       	push   $0x80241c
  80011f:	e8 00 02 00 00       	call   800324 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  800124:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80012b:	74 28                	je     800155 <lsdir+0x67>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  80012d:	56                   	push   %esi
  80012e:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  800134:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80013b:	0f 94 c0             	sete   %al
  80013e:	0f b6 c0             	movzbl %al,%eax
  800141:	50                   	push   %eax
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	e8 e9 fe ff ff       	call   800033 <ls1>
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	eb 06                	jmp    800155 <lsdir+0x67>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80014f:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800155:	83 ec 04             	sub    $0x4,%esp
  800158:	68 00 01 00 00       	push   $0x100
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
  80015f:	e8 f9 13 00 00       	call   80155d <readn>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	3d 00 01 00 00       	cmp    $0x100,%eax
  80016c:	74 b6                	je     800124 <lsdir+0x36>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 12                	jle    800184 <lsdir+0x96>
		panic("short read in directory %s", path);
  800172:	57                   	push   %edi
  800173:	68 26 24 80 00       	push   $0x802426
  800178:	6a 22                	push   $0x22
  80017a:	68 1c 24 80 00       	push   $0x80241c
  80017f:	e8 a0 01 00 00       	call   800324 <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 6c 24 80 00       	push   $0x80246c
  800192:	6a 24                	push   $0x24
  800194:	68 1c 24 80 00       	push   $0x80241c
  800199:	e8 86 01 00 00       	call   800324 <_panic>
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001b3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001b9:	50                   	push   %eax
  8001ba:	53                   	push   %ebx
  8001bb:	e8 a2 15 00 00       	call   801762 <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 41 24 80 00       	push   $0x802441
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 1c 24 80 00       	push   $0x80241c
  8001d8:	e8 47 01 00 00       	call   800324 <_panic>
	if (st.st_isdir && !flag['d'])
  8001dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	74 1a                	je     8001fe <ls+0x58>
  8001e4:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  8001eb:	75 11                	jne    8001fe <ls+0x58>
		lsdir(path, prefix);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 0c             	pushl  0xc(%ebp)
  8001f3:	53                   	push   %ebx
  8001f4:	e8 f5 fe ff ff       	call   8000ee <lsdir>
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb 17                	jmp    800215 <ls+0x6f>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  8001fe:	53                   	push   %ebx
  8001ff:	ff 75 ec             	pushl  -0x14(%ebp)
  800202:	85 c0                	test   %eax,%eax
  800204:	0f 95 c0             	setne  %al
  800207:	0f b6 c0             	movzbl %al,%eax
  80020a:	50                   	push   %eax
  80020b:	6a 00                	push   $0x0
  80020d:	e8 21 fe ff ff       	call   800033 <ls1>
  800212:	83 c4 10             	add    $0x10,%esp
}
  800215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <usage>:
	printf("\n");
}

void
usage(void)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800220:	68 4d 24 80 00       	push   $0x80244d
  800225:	e8 13 19 00 00       	call   801b3d <printf>
	exit();
  80022a:	e8 db 00 00 00       	call   80030a <exit>
}
  80022f:	83 c4 10             	add    $0x10,%esp
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <umain>:

void
umain(int argc, char **argv)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 14             	sub    $0x14,%esp
  80023c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  80023f:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800242:	50                   	push   %eax
  800243:	56                   	push   %esi
  800244:	8d 45 08             	lea    0x8(%ebp),%eax
  800247:	50                   	push   %eax
  800248:	e8 4f 0e 00 00       	call   80109c <argstart>
	while ((i = argnext(&args)) >= 0)
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  800253:	eb 1e                	jmp    800273 <umain+0x3f>
		switch (i) {
  800255:	83 f8 64             	cmp    $0x64,%eax
  800258:	74 0a                	je     800264 <umain+0x30>
  80025a:	83 f8 6c             	cmp    $0x6c,%eax
  80025d:	74 05                	je     800264 <umain+0x30>
  80025f:	83 f8 46             	cmp    $0x46,%eax
  800262:	75 0a                	jne    80026e <umain+0x3a>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  800264:	83 04 85 20 40 80 00 	addl   $0x1,0x804020(,%eax,4)
  80026b:	01 
			break;
  80026c:	eb 05                	jmp    800273 <umain+0x3f>
		default:
			usage();
  80026e:	e8 a7 ff ff ff       	call   80021a <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	53                   	push   %ebx
  800277:	e8 50 0e 00 00       	call   8010cc <argnext>
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	85 c0                	test   %eax,%eax
  800281:	79 d2                	jns    800255 <umain+0x21>
  800283:	bb 01 00 00 00       	mov    $0x1,%ebx
			break;
		default:
			usage();
		}

	if (argc == 1)
  800288:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80028c:	75 2a                	jne    8002b8 <umain+0x84>
		ls("/", "");
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	68 68 24 80 00       	push   $0x802468
  800296:	68 00 24 80 00       	push   $0x802400
  80029b:	e8 06 ff ff ff       	call   8001a6 <ls>
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	eb 18                	jmp    8002bd <umain+0x89>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  8002a5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	50                   	push   %eax
  8002ac:	50                   	push   %eax
  8002ad:	e8 f4 fe ff ff       	call   8001a6 <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  8002b2:	83 c3 01             	add    $0x1,%ebx
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  8002bb:	7c e8                	jl     8002a5 <umain+0x71>
			ls(argv[i], argv[i]);
	}
}
  8002bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002cf:	e8 99 0b 00 00       	call   800e6d <sys_getenvid>
  8002d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002dc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e1:	a3 20 44 80 00       	mov    %eax,0x804420
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e6:	85 db                	test   %ebx,%ebx
  8002e8:	7e 07                	jle    8002f1 <libmain+0x2d>
		binaryname = argv[0];
  8002ea:	8b 06                	mov    (%esi),%eax
  8002ec:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002f1:	83 ec 08             	sub    $0x8,%esp
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	e8 39 ff ff ff       	call   800234 <umain>

	// exit gracefully
	exit();
  8002fb:	e8 0a 00 00 00       	call   80030a <exit>
}
  800300:	83 c4 10             	add    $0x10,%esp
  800303:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800310:	e8 a6 10 00 00       	call   8013bb <close_all>
	sys_env_destroy(0);
  800315:	83 ec 0c             	sub    $0xc,%esp
  800318:	6a 00                	push   $0x0
  80031a:	e8 0d 0b 00 00       	call   800e2c <sys_env_destroy>
}
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800329:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80032c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800332:	e8 36 0b 00 00       	call   800e6d <sys_getenvid>
  800337:	83 ec 0c             	sub    $0xc,%esp
  80033a:	ff 75 0c             	pushl  0xc(%ebp)
  80033d:	ff 75 08             	pushl  0x8(%ebp)
  800340:	56                   	push   %esi
  800341:	50                   	push   %eax
  800342:	68 98 24 80 00       	push   $0x802498
  800347:	e8 b1 00 00 00       	call   8003fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80034c:	83 c4 18             	add    $0x18,%esp
  80034f:	53                   	push   %ebx
  800350:	ff 75 10             	pushl  0x10(%ebp)
  800353:	e8 54 00 00 00       	call   8003ac <vcprintf>
	cprintf("\n");
  800358:	c7 04 24 67 24 80 00 	movl   $0x802467,(%esp)
  80035f:	e8 99 00 00 00       	call   8003fd <cprintf>
  800364:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800367:	cc                   	int3   
  800368:	eb fd                	jmp    800367 <_panic+0x43>

0080036a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	53                   	push   %ebx
  80036e:	83 ec 04             	sub    $0x4,%esp
  800371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800374:	8b 13                	mov    (%ebx),%edx
  800376:	8d 42 01             	lea    0x1(%edx),%eax
  800379:	89 03                	mov    %eax,(%ebx)
  80037b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800382:	3d ff 00 00 00       	cmp    $0xff,%eax
  800387:	75 1a                	jne    8003a3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	68 ff 00 00 00       	push   $0xff
  800391:	8d 43 08             	lea    0x8(%ebx),%eax
  800394:	50                   	push   %eax
  800395:	e8 55 0a 00 00       	call   800def <sys_cputs>
		b->idx = 0;
  80039a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    

008003ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003bc:	00 00 00 
	b.cnt = 0;
  8003bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c9:	ff 75 0c             	pushl  0xc(%ebp)
  8003cc:	ff 75 08             	pushl  0x8(%ebp)
  8003cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d5:	50                   	push   %eax
  8003d6:	68 6a 03 80 00       	push   $0x80036a
  8003db:	e8 54 01 00 00       	call   800534 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e0:	83 c4 08             	add    $0x8,%esp
  8003e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ef:	50                   	push   %eax
  8003f0:	e8 fa 09 00 00       	call   800def <sys_cputs>

	return b.cnt;
}
  8003f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003fb:	c9                   	leave  
  8003fc:	c3                   	ret    

008003fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800403:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800406:	50                   	push   %eax
  800407:	ff 75 08             	pushl  0x8(%ebp)
  80040a:	e8 9d ff ff ff       	call   8003ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 1c             	sub    $0x1c,%esp
  80041a:	89 c7                	mov    %eax,%edi
  80041c:	89 d6                	mov    %edx,%esi
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
  800421:	8b 55 0c             	mov    0xc(%ebp),%edx
  800424:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800427:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80042a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80042d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800432:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800435:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800438:	39 d3                	cmp    %edx,%ebx
  80043a:	72 05                	jb     800441 <printnum+0x30>
  80043c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80043f:	77 45                	ja     800486 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800441:	83 ec 0c             	sub    $0xc,%esp
  800444:	ff 75 18             	pushl  0x18(%ebp)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80044d:	53                   	push   %ebx
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	ff 75 e4             	pushl  -0x1c(%ebp)
  800457:	ff 75 e0             	pushl  -0x20(%ebp)
  80045a:	ff 75 dc             	pushl  -0x24(%ebp)
  80045d:	ff 75 d8             	pushl  -0x28(%ebp)
  800460:	e8 0b 1d 00 00       	call   802170 <__udivdi3>
  800465:	83 c4 18             	add    $0x18,%esp
  800468:	52                   	push   %edx
  800469:	50                   	push   %eax
  80046a:	89 f2                	mov    %esi,%edx
  80046c:	89 f8                	mov    %edi,%eax
  80046e:	e8 9e ff ff ff       	call   800411 <printnum>
  800473:	83 c4 20             	add    $0x20,%esp
  800476:	eb 18                	jmp    800490 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	56                   	push   %esi
  80047c:	ff 75 18             	pushl  0x18(%ebp)
  80047f:	ff d7                	call   *%edi
  800481:	83 c4 10             	add    $0x10,%esp
  800484:	eb 03                	jmp    800489 <printnum+0x78>
  800486:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800489:	83 eb 01             	sub    $0x1,%ebx
  80048c:	85 db                	test   %ebx,%ebx
  80048e:	7f e8                	jg     800478 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	56                   	push   %esi
  800494:	83 ec 04             	sub    $0x4,%esp
  800497:	ff 75 e4             	pushl  -0x1c(%ebp)
  80049a:	ff 75 e0             	pushl  -0x20(%ebp)
  80049d:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a3:	e8 f8 1d 00 00       	call   8022a0 <__umoddi3>
  8004a8:	83 c4 14             	add    $0x14,%esp
  8004ab:	0f be 80 bb 24 80 00 	movsbl 0x8024bb(%eax),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff d7                	call   *%edi
}
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004bb:	5b                   	pop    %ebx
  8004bc:	5e                   	pop    %esi
  8004bd:	5f                   	pop    %edi
  8004be:	5d                   	pop    %ebp
  8004bf:	c3                   	ret    

008004c0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c3:	83 fa 01             	cmp    $0x1,%edx
  8004c6:	7e 0e                	jle    8004d6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	8b 52 04             	mov    0x4(%edx),%edx
  8004d4:	eb 22                	jmp    8004f8 <getuint+0x38>
	else if (lflag)
  8004d6:	85 d2                	test   %edx,%edx
  8004d8:	74 10                	je     8004ea <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004df:	89 08                	mov    %ecx,(%eax)
  8004e1:	8b 02                	mov    (%edx),%eax
  8004e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e8:	eb 0e                	jmp    8004f8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ea:	8b 10                	mov    (%eax),%edx
  8004ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ef:	89 08                	mov    %ecx,(%eax)
  8004f1:	8b 02                	mov    (%edx),%eax
  8004f3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f8:	5d                   	pop    %ebp
  8004f9:	c3                   	ret    

008004fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800500:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800504:	8b 10                	mov    (%eax),%edx
  800506:	3b 50 04             	cmp    0x4(%eax),%edx
  800509:	73 0a                	jae    800515 <sprintputch+0x1b>
		*b->buf++ = ch;
  80050b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80050e:	89 08                	mov    %ecx,(%eax)
  800510:	8b 45 08             	mov    0x8(%ebp),%eax
  800513:	88 02                	mov    %al,(%edx)
}
  800515:	5d                   	pop    %ebp
  800516:	c3                   	ret    

00800517 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800517:	55                   	push   %ebp
  800518:	89 e5                	mov    %esp,%ebp
  80051a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80051d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800520:	50                   	push   %eax
  800521:	ff 75 10             	pushl  0x10(%ebp)
  800524:	ff 75 0c             	pushl  0xc(%ebp)
  800527:	ff 75 08             	pushl  0x8(%ebp)
  80052a:	e8 05 00 00 00       	call   800534 <vprintfmt>
	va_end(ap);
}
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	c9                   	leave  
  800533:	c3                   	ret    

00800534 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	57                   	push   %edi
  800538:	56                   	push   %esi
  800539:	53                   	push   %ebx
  80053a:	83 ec 2c             	sub    $0x2c,%esp
  80053d:	8b 75 08             	mov    0x8(%ebp),%esi
  800540:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800543:	8b 7d 10             	mov    0x10(%ebp),%edi
  800546:	eb 12                	jmp    80055a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800548:	85 c0                	test   %eax,%eax
  80054a:	0f 84 38 04 00 00    	je     800988 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	53                   	push   %ebx
  800554:	50                   	push   %eax
  800555:	ff d6                	call   *%esi
  800557:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80055a:	83 c7 01             	add    $0x1,%edi
  80055d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800561:	83 f8 25             	cmp    $0x25,%eax
  800564:	75 e2                	jne    800548 <vprintfmt+0x14>
  800566:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80056a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800571:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800578:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80057f:	ba 00 00 00 00       	mov    $0x0,%edx
  800584:	eb 07                	jmp    80058d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  800589:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8d 47 01             	lea    0x1(%edi),%eax
  800590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800593:	0f b6 07             	movzbl (%edi),%eax
  800596:	0f b6 c8             	movzbl %al,%ecx
  800599:	83 e8 23             	sub    $0x23,%eax
  80059c:	3c 55                	cmp    $0x55,%al
  80059e:	0f 87 c9 03 00 00    	ja     80096d <vprintfmt+0x439>
  8005a4:	0f b6 c0             	movzbl %al,%eax
  8005a7:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  8005ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005b5:	eb d6                	jmp    80058d <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  8005b7:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  8005be:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  8005c4:	eb 94                	jmp    80055a <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  8005c6:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  8005cd:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  8005d3:	eb 85                	jmp    80055a <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  8005d5:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  8005dc:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  8005e2:	e9 73 ff ff ff       	jmp    80055a <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  8005e7:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  8005ee:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  8005f4:	e9 61 ff ff ff       	jmp    80055a <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  8005f9:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800600:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800603:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  800606:	e9 4f ff ff ff       	jmp    80055a <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80060b:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800612:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800615:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  800618:	e9 3d ff ff ff       	jmp    80055a <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  80061d:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  800624:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800627:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80062a:	e9 2b ff ff ff       	jmp    80055a <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  80062f:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  800636:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800639:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  80063c:	e9 19 ff ff ff       	jmp    80055a <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800641:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  800648:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  80064e:	e9 07 ff ff ff       	jmp    80055a <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  800653:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  80065a:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800660:	e9 f5 fe ff ff       	jmp    80055a <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800665:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800668:	b8 00 00 00 00       	mov    $0x0,%eax
  80066d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800670:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800673:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800677:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80067a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80067d:	83 fa 09             	cmp    $0x9,%edx
  800680:	77 3f                	ja     8006c1 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800682:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800685:	eb e9                	jmp    800670 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8d 48 04             	lea    0x4(%eax),%ecx
  80068d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800690:	8b 00                	mov    (%eax),%eax
  800692:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800695:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800698:	eb 2d                	jmp    8006c7 <vprintfmt+0x193>
  80069a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80069d:	85 c0                	test   %eax,%eax
  80069f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a4:	0f 49 c8             	cmovns %eax,%ecx
  8006a7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ad:	e9 db fe ff ff       	jmp    80058d <vprintfmt+0x59>
  8006b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006b5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006bc:	e9 cc fe ff ff       	jmp    80058d <vprintfmt+0x59>
  8006c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006c4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006cb:	0f 89 bc fe ff ff    	jns    80058d <vprintfmt+0x59>
				width = precision, precision = -1;
  8006d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006de:	e9 aa fe ff ff       	jmp    80058d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006e3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006e9:	e9 9f fe ff ff       	jmp    80058d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8d 50 04             	lea    0x4(%eax),%edx
  8006f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	53                   	push   %ebx
  8006fb:	ff 30                	pushl  (%eax)
  8006fd:	ff d6                	call   *%esi
			break;
  8006ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800702:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800705:	e9 50 fe ff ff       	jmp    80055a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8d 50 04             	lea    0x4(%eax),%edx
  800710:	89 55 14             	mov    %edx,0x14(%ebp)
  800713:	8b 00                	mov    (%eax),%eax
  800715:	99                   	cltd   
  800716:	31 d0                	xor    %edx,%eax
  800718:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80071a:	83 f8 0f             	cmp    $0xf,%eax
  80071d:	7f 0b                	jg     80072a <vprintfmt+0x1f6>
  80071f:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  800726:	85 d2                	test   %edx,%edx
  800728:	75 18                	jne    800742 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80072a:	50                   	push   %eax
  80072b:	68 d3 24 80 00       	push   $0x8024d3
  800730:	53                   	push   %ebx
  800731:	56                   	push   %esi
  800732:	e8 e0 fd ff ff       	call   800517 <printfmt>
  800737:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80073d:	e9 18 fe ff ff       	jmp    80055a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800742:	52                   	push   %edx
  800743:	68 91 28 80 00       	push   $0x802891
  800748:	53                   	push   %ebx
  800749:	56                   	push   %esi
  80074a:	e8 c8 fd ff ff       	call   800517 <printfmt>
  80074f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800752:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800755:	e9 00 fe ff ff       	jmp    80055a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80075a:	8b 45 14             	mov    0x14(%ebp),%eax
  80075d:	8d 50 04             	lea    0x4(%eax),%edx
  800760:	89 55 14             	mov    %edx,0x14(%ebp)
  800763:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800765:	85 ff                	test   %edi,%edi
  800767:	b8 cc 24 80 00       	mov    $0x8024cc,%eax
  80076c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80076f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800773:	0f 8e 94 00 00 00    	jle    80080d <vprintfmt+0x2d9>
  800779:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80077d:	0f 84 98 00 00 00    	je     80081b <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  800783:	83 ec 08             	sub    $0x8,%esp
  800786:	ff 75 d0             	pushl  -0x30(%ebp)
  800789:	57                   	push   %edi
  80078a:	e8 81 02 00 00       	call   800a10 <strnlen>
  80078f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800792:	29 c1                	sub    %eax,%ecx
  800794:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800797:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80079a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80079e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007a4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a6:	eb 0f                	jmp    8007b7 <vprintfmt+0x283>
					putch(padc, putdat);
  8007a8:	83 ec 08             	sub    $0x8,%esp
  8007ab:	53                   	push   %ebx
  8007ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8007af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b1:	83 ef 01             	sub    $0x1,%edi
  8007b4:	83 c4 10             	add    $0x10,%esp
  8007b7:	85 ff                	test   %edi,%edi
  8007b9:	7f ed                	jg     8007a8 <vprintfmt+0x274>
  8007bb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007be:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007c1:	85 c9                	test   %ecx,%ecx
  8007c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c8:	0f 49 c1             	cmovns %ecx,%eax
  8007cb:	29 c1                	sub    %eax,%ecx
  8007cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8007d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007d6:	89 cb                	mov    %ecx,%ebx
  8007d8:	eb 4d                	jmp    800827 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007de:	74 1b                	je     8007fb <vprintfmt+0x2c7>
  8007e0:	0f be c0             	movsbl %al,%eax
  8007e3:	83 e8 20             	sub    $0x20,%eax
  8007e6:	83 f8 5e             	cmp    $0x5e,%eax
  8007e9:	76 10                	jbe    8007fb <vprintfmt+0x2c7>
					putch('?', putdat);
  8007eb:	83 ec 08             	sub    $0x8,%esp
  8007ee:	ff 75 0c             	pushl  0xc(%ebp)
  8007f1:	6a 3f                	push   $0x3f
  8007f3:	ff 55 08             	call   *0x8(%ebp)
  8007f6:	83 c4 10             	add    $0x10,%esp
  8007f9:	eb 0d                	jmp    800808 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	ff 75 0c             	pushl  0xc(%ebp)
  800801:	52                   	push   %edx
  800802:	ff 55 08             	call   *0x8(%ebp)
  800805:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800808:	83 eb 01             	sub    $0x1,%ebx
  80080b:	eb 1a                	jmp    800827 <vprintfmt+0x2f3>
  80080d:	89 75 08             	mov    %esi,0x8(%ebp)
  800810:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800813:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800816:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800819:	eb 0c                	jmp    800827 <vprintfmt+0x2f3>
  80081b:	89 75 08             	mov    %esi,0x8(%ebp)
  80081e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800821:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800824:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800827:	83 c7 01             	add    $0x1,%edi
  80082a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80082e:	0f be d0             	movsbl %al,%edx
  800831:	85 d2                	test   %edx,%edx
  800833:	74 23                	je     800858 <vprintfmt+0x324>
  800835:	85 f6                	test   %esi,%esi
  800837:	78 a1                	js     8007da <vprintfmt+0x2a6>
  800839:	83 ee 01             	sub    $0x1,%esi
  80083c:	79 9c                	jns    8007da <vprintfmt+0x2a6>
  80083e:	89 df                	mov    %ebx,%edi
  800840:	8b 75 08             	mov    0x8(%ebp),%esi
  800843:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800846:	eb 18                	jmp    800860 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800848:	83 ec 08             	sub    $0x8,%esp
  80084b:	53                   	push   %ebx
  80084c:	6a 20                	push   $0x20
  80084e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800850:	83 ef 01             	sub    $0x1,%edi
  800853:	83 c4 10             	add    $0x10,%esp
  800856:	eb 08                	jmp    800860 <vprintfmt+0x32c>
  800858:	89 df                	mov    %ebx,%edi
  80085a:	8b 75 08             	mov    0x8(%ebp),%esi
  80085d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800860:	85 ff                	test   %edi,%edi
  800862:	7f e4                	jg     800848 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800864:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800867:	e9 ee fc ff ff       	jmp    80055a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80086c:	83 fa 01             	cmp    $0x1,%edx
  80086f:	7e 16                	jle    800887 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800871:	8b 45 14             	mov    0x14(%ebp),%eax
  800874:	8d 50 08             	lea    0x8(%eax),%edx
  800877:	89 55 14             	mov    %edx,0x14(%ebp)
  80087a:	8b 50 04             	mov    0x4(%eax),%edx
  80087d:	8b 00                	mov    (%eax),%eax
  80087f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800882:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800885:	eb 32                	jmp    8008b9 <vprintfmt+0x385>
	else if (lflag)
  800887:	85 d2                	test   %edx,%edx
  800889:	74 18                	je     8008a3 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  80088b:	8b 45 14             	mov    0x14(%ebp),%eax
  80088e:	8d 50 04             	lea    0x4(%eax),%edx
  800891:	89 55 14             	mov    %edx,0x14(%ebp)
  800894:	8b 00                	mov    (%eax),%eax
  800896:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800899:	89 c1                	mov    %eax,%ecx
  80089b:	c1 f9 1f             	sar    $0x1f,%ecx
  80089e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008a1:	eb 16                	jmp    8008b9 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  8008a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a6:	8d 50 04             	lea    0x4(%eax),%edx
  8008a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ac:	8b 00                	mov    (%eax),%eax
  8008ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b1:	89 c1                	mov    %eax,%ecx
  8008b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8008b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008bf:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008c4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008c8:	79 6f                	jns    800939 <vprintfmt+0x405>
				putch('-', putdat);
  8008ca:	83 ec 08             	sub    $0x8,%esp
  8008cd:	53                   	push   %ebx
  8008ce:	6a 2d                	push   $0x2d
  8008d0:	ff d6                	call   *%esi
				num = -(long long) num;
  8008d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008d8:	f7 d8                	neg    %eax
  8008da:	83 d2 00             	adc    $0x0,%edx
  8008dd:	f7 da                	neg    %edx
  8008df:	83 c4 10             	add    $0x10,%esp
  8008e2:	eb 55                	jmp    800939 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e7:	e8 d4 fb ff ff       	call   8004c0 <getuint>
			base = 10;
  8008ec:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8008f1:	eb 46                	jmp    800939 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8008f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008f6:	e8 c5 fb ff ff       	call   8004c0 <getuint>
			base = 8;
  8008fb:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800900:	eb 37                	jmp    800939 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800902:	83 ec 08             	sub    $0x8,%esp
  800905:	53                   	push   %ebx
  800906:	6a 30                	push   $0x30
  800908:	ff d6                	call   *%esi
			putch('x', putdat);
  80090a:	83 c4 08             	add    $0x8,%esp
  80090d:	53                   	push   %ebx
  80090e:	6a 78                	push   $0x78
  800910:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800912:	8b 45 14             	mov    0x14(%ebp),%eax
  800915:	8d 50 04             	lea    0x4(%eax),%edx
  800918:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80091b:	8b 00                	mov    (%eax),%eax
  80091d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800922:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800925:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80092a:	eb 0d                	jmp    800939 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80092c:	8d 45 14             	lea    0x14(%ebp),%eax
  80092f:	e8 8c fb ff ff       	call   8004c0 <getuint>
			base = 16;
  800934:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800939:	83 ec 0c             	sub    $0xc,%esp
  80093c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800940:	51                   	push   %ecx
  800941:	ff 75 e0             	pushl  -0x20(%ebp)
  800944:	57                   	push   %edi
  800945:	52                   	push   %edx
  800946:	50                   	push   %eax
  800947:	89 da                	mov    %ebx,%edx
  800949:	89 f0                	mov    %esi,%eax
  80094b:	e8 c1 fa ff ff       	call   800411 <printnum>
			break;
  800950:	83 c4 20             	add    $0x20,%esp
  800953:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800956:	e9 ff fb ff ff       	jmp    80055a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80095b:	83 ec 08             	sub    $0x8,%esp
  80095e:	53                   	push   %ebx
  80095f:	51                   	push   %ecx
  800960:	ff d6                	call   *%esi
			break;
  800962:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800965:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800968:	e9 ed fb ff ff       	jmp    80055a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80096d:	83 ec 08             	sub    $0x8,%esp
  800970:	53                   	push   %ebx
  800971:	6a 25                	push   $0x25
  800973:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800975:	83 c4 10             	add    $0x10,%esp
  800978:	eb 03                	jmp    80097d <vprintfmt+0x449>
  80097a:	83 ef 01             	sub    $0x1,%edi
  80097d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800981:	75 f7                	jne    80097a <vprintfmt+0x446>
  800983:	e9 d2 fb ff ff       	jmp    80055a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800988:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80098b:	5b                   	pop    %ebx
  80098c:	5e                   	pop    %esi
  80098d:	5f                   	pop    %edi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	83 ec 18             	sub    $0x18,%esp
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80099c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80099f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009a3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009ad:	85 c0                	test   %eax,%eax
  8009af:	74 26                	je     8009d7 <vsnprintf+0x47>
  8009b1:	85 d2                	test   %edx,%edx
  8009b3:	7e 22                	jle    8009d7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009b5:	ff 75 14             	pushl  0x14(%ebp)
  8009b8:	ff 75 10             	pushl  0x10(%ebp)
  8009bb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009be:	50                   	push   %eax
  8009bf:	68 fa 04 80 00       	push   $0x8004fa
  8009c4:	e8 6b fb ff ff       	call   800534 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009cc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d2:	83 c4 10             	add    $0x10,%esp
  8009d5:	eb 05                	jmp    8009dc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009dc:	c9                   	leave  
  8009dd:	c3                   	ret    

008009de <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009e4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009e7:	50                   	push   %eax
  8009e8:	ff 75 10             	pushl  0x10(%ebp)
  8009eb:	ff 75 0c             	pushl  0xc(%ebp)
  8009ee:	ff 75 08             	pushl  0x8(%ebp)
  8009f1:	e8 9a ff ff ff       	call   800990 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009f6:	c9                   	leave  
  8009f7:	c3                   	ret    

008009f8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800a03:	eb 03                	jmp    800a08 <strlen+0x10>
		n++;
  800a05:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a08:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a0c:	75 f7                	jne    800a05 <strlen+0xd>
		n++;
	return n;
}
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a16:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a19:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1e:	eb 03                	jmp    800a23 <strnlen+0x13>
		n++;
  800a20:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a23:	39 c2                	cmp    %eax,%edx
  800a25:	74 08                	je     800a2f <strnlen+0x1f>
  800a27:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a2b:	75 f3                	jne    800a20 <strnlen+0x10>
  800a2d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	53                   	push   %ebx
  800a35:	8b 45 08             	mov    0x8(%ebp),%eax
  800a38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a3b:	89 c2                	mov    %eax,%edx
  800a3d:	83 c2 01             	add    $0x1,%edx
  800a40:	83 c1 01             	add    $0x1,%ecx
  800a43:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a47:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a4a:	84 db                	test   %bl,%bl
  800a4c:	75 ef                	jne    800a3d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a4e:	5b                   	pop    %ebx
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	53                   	push   %ebx
  800a55:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a58:	53                   	push   %ebx
  800a59:	e8 9a ff ff ff       	call   8009f8 <strlen>
  800a5e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a61:	ff 75 0c             	pushl  0xc(%ebp)
  800a64:	01 d8                	add    %ebx,%eax
  800a66:	50                   	push   %eax
  800a67:	e8 c5 ff ff ff       	call   800a31 <strcpy>
	return dst;
}
  800a6c:	89 d8                	mov    %ebx,%eax
  800a6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a71:	c9                   	leave  
  800a72:	c3                   	ret    

00800a73 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
  800a78:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7e:	89 f3                	mov    %esi,%ebx
  800a80:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a83:	89 f2                	mov    %esi,%edx
  800a85:	eb 0f                	jmp    800a96 <strncpy+0x23>
		*dst++ = *src;
  800a87:	83 c2 01             	add    $0x1,%edx
  800a8a:	0f b6 01             	movzbl (%ecx),%eax
  800a8d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a90:	80 39 01             	cmpb   $0x1,(%ecx)
  800a93:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a96:	39 da                	cmp    %ebx,%edx
  800a98:	75 ed                	jne    800a87 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a9a:	89 f0                	mov    %esi,%eax
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aab:	8b 55 10             	mov    0x10(%ebp),%edx
  800aae:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab0:	85 d2                	test   %edx,%edx
  800ab2:	74 21                	je     800ad5 <strlcpy+0x35>
  800ab4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ab8:	89 f2                	mov    %esi,%edx
  800aba:	eb 09                	jmp    800ac5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800abc:	83 c2 01             	add    $0x1,%edx
  800abf:	83 c1 01             	add    $0x1,%ecx
  800ac2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ac5:	39 c2                	cmp    %eax,%edx
  800ac7:	74 09                	je     800ad2 <strlcpy+0x32>
  800ac9:	0f b6 19             	movzbl (%ecx),%ebx
  800acc:	84 db                	test   %bl,%bl
  800ace:	75 ec                	jne    800abc <strlcpy+0x1c>
  800ad0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ad2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ad5:	29 f0                	sub    %esi,%eax
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ae4:	eb 06                	jmp    800aec <strcmp+0x11>
		p++, q++;
  800ae6:	83 c1 01             	add    $0x1,%ecx
  800ae9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aec:	0f b6 01             	movzbl (%ecx),%eax
  800aef:	84 c0                	test   %al,%al
  800af1:	74 04                	je     800af7 <strcmp+0x1c>
  800af3:	3a 02                	cmp    (%edx),%al
  800af5:	74 ef                	je     800ae6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800af7:	0f b6 c0             	movzbl %al,%eax
  800afa:	0f b6 12             	movzbl (%edx),%edx
  800afd:	29 d0                	sub    %edx,%eax
}
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	53                   	push   %ebx
  800b05:	8b 45 08             	mov    0x8(%ebp),%eax
  800b08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0b:	89 c3                	mov    %eax,%ebx
  800b0d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b10:	eb 06                	jmp    800b18 <strncmp+0x17>
		n--, p++, q++;
  800b12:	83 c0 01             	add    $0x1,%eax
  800b15:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b18:	39 d8                	cmp    %ebx,%eax
  800b1a:	74 15                	je     800b31 <strncmp+0x30>
  800b1c:	0f b6 08             	movzbl (%eax),%ecx
  800b1f:	84 c9                	test   %cl,%cl
  800b21:	74 04                	je     800b27 <strncmp+0x26>
  800b23:	3a 0a                	cmp    (%edx),%cl
  800b25:	74 eb                	je     800b12 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b27:	0f b6 00             	movzbl (%eax),%eax
  800b2a:	0f b6 12             	movzbl (%edx),%edx
  800b2d:	29 d0                	sub    %edx,%eax
  800b2f:	eb 05                	jmp    800b36 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b31:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b36:	5b                   	pop    %ebx
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b43:	eb 07                	jmp    800b4c <strchr+0x13>
		if (*s == c)
  800b45:	38 ca                	cmp    %cl,%dl
  800b47:	74 0f                	je     800b58 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b49:	83 c0 01             	add    $0x1,%eax
  800b4c:	0f b6 10             	movzbl (%eax),%edx
  800b4f:	84 d2                	test   %dl,%dl
  800b51:	75 f2                	jne    800b45 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b64:	eb 03                	jmp    800b69 <strfind+0xf>
  800b66:	83 c0 01             	add    $0x1,%eax
  800b69:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b6c:	38 ca                	cmp    %cl,%dl
  800b6e:	74 04                	je     800b74 <strfind+0x1a>
  800b70:	84 d2                	test   %dl,%dl
  800b72:	75 f2                	jne    800b66 <strfind+0xc>
			break;
	return (char *) s;
}
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b82:	85 c9                	test   %ecx,%ecx
  800b84:	74 36                	je     800bbc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b86:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b8c:	75 28                	jne    800bb6 <memset+0x40>
  800b8e:	f6 c1 03             	test   $0x3,%cl
  800b91:	75 23                	jne    800bb6 <memset+0x40>
		c &= 0xFF;
  800b93:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b97:	89 d3                	mov    %edx,%ebx
  800b99:	c1 e3 08             	shl    $0x8,%ebx
  800b9c:	89 d6                	mov    %edx,%esi
  800b9e:	c1 e6 18             	shl    $0x18,%esi
  800ba1:	89 d0                	mov    %edx,%eax
  800ba3:	c1 e0 10             	shl    $0x10,%eax
  800ba6:	09 f0                	or     %esi,%eax
  800ba8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800baa:	89 d8                	mov    %ebx,%eax
  800bac:	09 d0                	or     %edx,%eax
  800bae:	c1 e9 02             	shr    $0x2,%ecx
  800bb1:	fc                   	cld    
  800bb2:	f3 ab                	rep stos %eax,%es:(%edi)
  800bb4:	eb 06                	jmp    800bbc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb9:	fc                   	cld    
  800bba:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bbc:	89 f8                	mov    %edi,%eax
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bd1:	39 c6                	cmp    %eax,%esi
  800bd3:	73 35                	jae    800c0a <memmove+0x47>
  800bd5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bd8:	39 d0                	cmp    %edx,%eax
  800bda:	73 2e                	jae    800c0a <memmove+0x47>
		s += n;
		d += n;
  800bdc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bdf:	89 d6                	mov    %edx,%esi
  800be1:	09 fe                	or     %edi,%esi
  800be3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800be9:	75 13                	jne    800bfe <memmove+0x3b>
  800beb:	f6 c1 03             	test   $0x3,%cl
  800bee:	75 0e                	jne    800bfe <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bf0:	83 ef 04             	sub    $0x4,%edi
  800bf3:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bf6:	c1 e9 02             	shr    $0x2,%ecx
  800bf9:	fd                   	std    
  800bfa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bfc:	eb 09                	jmp    800c07 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bfe:	83 ef 01             	sub    $0x1,%edi
  800c01:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c04:	fd                   	std    
  800c05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c07:	fc                   	cld    
  800c08:	eb 1d                	jmp    800c27 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0a:	89 f2                	mov    %esi,%edx
  800c0c:	09 c2                	or     %eax,%edx
  800c0e:	f6 c2 03             	test   $0x3,%dl
  800c11:	75 0f                	jne    800c22 <memmove+0x5f>
  800c13:	f6 c1 03             	test   $0x3,%cl
  800c16:	75 0a                	jne    800c22 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c18:	c1 e9 02             	shr    $0x2,%ecx
  800c1b:	89 c7                	mov    %eax,%edi
  800c1d:	fc                   	cld    
  800c1e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c20:	eb 05                	jmp    800c27 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c22:	89 c7                	mov    %eax,%edi
  800c24:	fc                   	cld    
  800c25:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c2e:	ff 75 10             	pushl  0x10(%ebp)
  800c31:	ff 75 0c             	pushl  0xc(%ebp)
  800c34:	ff 75 08             	pushl  0x8(%ebp)
  800c37:	e8 87 ff ff ff       	call   800bc3 <memmove>
}
  800c3c:	c9                   	leave  
  800c3d:	c3                   	ret    

00800c3e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	8b 45 08             	mov    0x8(%ebp),%eax
  800c46:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c49:	89 c6                	mov    %eax,%esi
  800c4b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c4e:	eb 1a                	jmp    800c6a <memcmp+0x2c>
		if (*s1 != *s2)
  800c50:	0f b6 08             	movzbl (%eax),%ecx
  800c53:	0f b6 1a             	movzbl (%edx),%ebx
  800c56:	38 d9                	cmp    %bl,%cl
  800c58:	74 0a                	je     800c64 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c5a:	0f b6 c1             	movzbl %cl,%eax
  800c5d:	0f b6 db             	movzbl %bl,%ebx
  800c60:	29 d8                	sub    %ebx,%eax
  800c62:	eb 0f                	jmp    800c73 <memcmp+0x35>
		s1++, s2++;
  800c64:	83 c0 01             	add    $0x1,%eax
  800c67:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6a:	39 f0                	cmp    %esi,%eax
  800c6c:	75 e2                	jne    800c50 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	53                   	push   %ebx
  800c7b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c7e:	89 c1                	mov    %eax,%ecx
  800c80:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c83:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c87:	eb 0a                	jmp    800c93 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c89:	0f b6 10             	movzbl (%eax),%edx
  800c8c:	39 da                	cmp    %ebx,%edx
  800c8e:	74 07                	je     800c97 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c90:	83 c0 01             	add    $0x1,%eax
  800c93:	39 c8                	cmp    %ecx,%eax
  800c95:	72 f2                	jb     800c89 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c97:	5b                   	pop    %ebx
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca6:	eb 03                	jmp    800cab <strtol+0x11>
		s++;
  800ca8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cab:	0f b6 01             	movzbl (%ecx),%eax
  800cae:	3c 20                	cmp    $0x20,%al
  800cb0:	74 f6                	je     800ca8 <strtol+0xe>
  800cb2:	3c 09                	cmp    $0x9,%al
  800cb4:	74 f2                	je     800ca8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cb6:	3c 2b                	cmp    $0x2b,%al
  800cb8:	75 0a                	jne    800cc4 <strtol+0x2a>
		s++;
  800cba:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cbd:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc2:	eb 11                	jmp    800cd5 <strtol+0x3b>
  800cc4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cc9:	3c 2d                	cmp    $0x2d,%al
  800ccb:	75 08                	jne    800cd5 <strtol+0x3b>
		s++, neg = 1;
  800ccd:	83 c1 01             	add    $0x1,%ecx
  800cd0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cdb:	75 15                	jne    800cf2 <strtol+0x58>
  800cdd:	80 39 30             	cmpb   $0x30,(%ecx)
  800ce0:	75 10                	jne    800cf2 <strtol+0x58>
  800ce2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ce6:	75 7c                	jne    800d64 <strtol+0xca>
		s += 2, base = 16;
  800ce8:	83 c1 02             	add    $0x2,%ecx
  800ceb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cf0:	eb 16                	jmp    800d08 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cf2:	85 db                	test   %ebx,%ebx
  800cf4:	75 12                	jne    800d08 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cf6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cfb:	80 39 30             	cmpb   $0x30,(%ecx)
  800cfe:	75 08                	jne    800d08 <strtol+0x6e>
		s++, base = 8;
  800d00:	83 c1 01             	add    $0x1,%ecx
  800d03:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d08:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d10:	0f b6 11             	movzbl (%ecx),%edx
  800d13:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d16:	89 f3                	mov    %esi,%ebx
  800d18:	80 fb 09             	cmp    $0x9,%bl
  800d1b:	77 08                	ja     800d25 <strtol+0x8b>
			dig = *s - '0';
  800d1d:	0f be d2             	movsbl %dl,%edx
  800d20:	83 ea 30             	sub    $0x30,%edx
  800d23:	eb 22                	jmp    800d47 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d25:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d28:	89 f3                	mov    %esi,%ebx
  800d2a:	80 fb 19             	cmp    $0x19,%bl
  800d2d:	77 08                	ja     800d37 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d2f:	0f be d2             	movsbl %dl,%edx
  800d32:	83 ea 57             	sub    $0x57,%edx
  800d35:	eb 10                	jmp    800d47 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d37:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d3a:	89 f3                	mov    %esi,%ebx
  800d3c:	80 fb 19             	cmp    $0x19,%bl
  800d3f:	77 16                	ja     800d57 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d41:	0f be d2             	movsbl %dl,%edx
  800d44:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d47:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d4a:	7d 0b                	jge    800d57 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d4c:	83 c1 01             	add    $0x1,%ecx
  800d4f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d53:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d55:	eb b9                	jmp    800d10 <strtol+0x76>

	if (endptr)
  800d57:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d5b:	74 0d                	je     800d6a <strtol+0xd0>
		*endptr = (char *) s;
  800d5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d60:	89 0e                	mov    %ecx,(%esi)
  800d62:	eb 06                	jmp    800d6a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d64:	85 db                	test   %ebx,%ebx
  800d66:	74 98                	je     800d00 <strtol+0x66>
  800d68:	eb 9e                	jmp    800d08 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d6a:	89 c2                	mov    %eax,%edx
  800d6c:	f7 da                	neg    %edx
  800d6e:	85 ff                	test   %edi,%edi
  800d70:	0f 45 c2             	cmovne %edx,%eax
}
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
  800d7e:	83 ec 04             	sub    $0x4,%esp
  800d81:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  800d84:	57                   	push   %edi
  800d85:	e8 6e fc ff ff       	call   8009f8 <strlen>
  800d8a:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800d8d:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  800d90:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  800d95:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800d9a:	eb 46                	jmp    800de2 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  800d9c:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  800da0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800da3:	80 f9 09             	cmp    $0x9,%cl
  800da6:	77 08                	ja     800db0 <charhex_to_dec+0x38>
			num = s[i] - '0';
  800da8:	0f be d2             	movsbl %dl,%edx
  800dab:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800dae:	eb 27                	jmp    800dd7 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  800db0:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  800db3:	80 f9 05             	cmp    $0x5,%cl
  800db6:	77 08                	ja     800dc0 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  800db8:	0f be d2             	movsbl %dl,%edx
  800dbb:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800dbe:	eb 17                	jmp    800dd7 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800dc0:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800dc3:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  800dc6:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800dcb:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800dcf:	77 06                	ja     800dd7 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800dd1:	0f be d2             	movsbl %dl,%edx
  800dd4:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  800dd7:	0f af ce             	imul   %esi,%ecx
  800dda:	01 c8                	add    %ecx,%eax
		base *= 16;
  800ddc:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800ddf:	83 eb 01             	sub    $0x1,%ebx
  800de2:	83 fb 01             	cmp    $0x1,%ebx
  800de5:	7f b5                	jg     800d9c <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  800de7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	57                   	push   %edi
  800df3:	56                   	push   %esi
  800df4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	89 c3                	mov    %eax,%ebx
  800e02:	89 c7                	mov    %eax,%edi
  800e04:	89 c6                	mov    %eax,%esi
  800e06:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_cgetc>:

int
sys_cgetc(void)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e13:	ba 00 00 00 00       	mov    $0x0,%edx
  800e18:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1d:	89 d1                	mov    %edx,%ecx
  800e1f:	89 d3                	mov    %edx,%ebx
  800e21:	89 d7                	mov    %edx,%edi
  800e23:	89 d6                	mov    %edx,%esi
  800e25:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
  800e32:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e3a:	b8 03 00 00 00       	mov    $0x3,%eax
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	89 cb                	mov    %ecx,%ebx
  800e44:	89 cf                	mov    %ecx,%edi
  800e46:	89 ce                	mov    %ecx,%esi
  800e48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4a:	85 c0                	test   %eax,%eax
  800e4c:	7e 17                	jle    800e65 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4e:	83 ec 0c             	sub    $0xc,%esp
  800e51:	50                   	push   %eax
  800e52:	6a 03                	push   $0x3
  800e54:	68 bf 27 80 00       	push   $0x8027bf
  800e59:	6a 23                	push   $0x23
  800e5b:	68 dc 27 80 00       	push   $0x8027dc
  800e60:	e8 bf f4 ff ff       	call   800324 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e68:	5b                   	pop    %ebx
  800e69:	5e                   	pop    %esi
  800e6a:	5f                   	pop    %edi
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    

00800e6d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	57                   	push   %edi
  800e71:	56                   	push   %esi
  800e72:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e73:	ba 00 00 00 00       	mov    $0x0,%edx
  800e78:	b8 02 00 00 00       	mov    $0x2,%eax
  800e7d:	89 d1                	mov    %edx,%ecx
  800e7f:	89 d3                	mov    %edx,%ebx
  800e81:	89 d7                	mov    %edx,%edi
  800e83:	89 d6                	mov    %edx,%esi
  800e85:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e87:	5b                   	pop    %ebx
  800e88:	5e                   	pop    %esi
  800e89:	5f                   	pop    %edi
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <sys_yield>:

void
sys_yield(void)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	57                   	push   %edi
  800e90:	56                   	push   %esi
  800e91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e92:	ba 00 00 00 00       	mov    $0x0,%edx
  800e97:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e9c:	89 d1                	mov    %edx,%ecx
  800e9e:	89 d3                	mov    %edx,%ebx
  800ea0:	89 d7                	mov    %edx,%edi
  800ea2:	89 d6                	mov    %edx,%esi
  800ea4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ea6:	5b                   	pop    %ebx
  800ea7:	5e                   	pop    %esi
  800ea8:	5f                   	pop    %edi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	57                   	push   %edi
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
  800eb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb4:	be 00 00 00 00       	mov    $0x0,%esi
  800eb9:	b8 04 00 00 00       	mov    $0x4,%eax
  800ebe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec7:	89 f7                	mov    %esi,%edi
  800ec9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	7e 17                	jle    800ee6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecf:	83 ec 0c             	sub    $0xc,%esp
  800ed2:	50                   	push   %eax
  800ed3:	6a 04                	push   $0x4
  800ed5:	68 bf 27 80 00       	push   $0x8027bf
  800eda:	6a 23                	push   $0x23
  800edc:	68 dc 27 80 00       	push   $0x8027dc
  800ee1:	e8 3e f4 ff ff       	call   800324 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ee6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee9:	5b                   	pop    %ebx
  800eea:	5e                   	pop    %esi
  800eeb:	5f                   	pop    %edi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef7:	b8 05 00 00 00       	mov    $0x5,%eax
  800efc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eff:	8b 55 08             	mov    0x8(%ebp),%edx
  800f02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f05:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f08:	8b 75 18             	mov    0x18(%ebp),%esi
  800f0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	7e 17                	jle    800f28 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f11:	83 ec 0c             	sub    $0xc,%esp
  800f14:	50                   	push   %eax
  800f15:	6a 05                	push   $0x5
  800f17:	68 bf 27 80 00       	push   $0x8027bf
  800f1c:	6a 23                	push   $0x23
  800f1e:	68 dc 27 80 00       	push   $0x8027dc
  800f23:	e8 fc f3 ff ff       	call   800324 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2b:	5b                   	pop    %ebx
  800f2c:	5e                   	pop    %esi
  800f2d:	5f                   	pop    %edi
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	57                   	push   %edi
  800f34:	56                   	push   %esi
  800f35:	53                   	push   %ebx
  800f36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3e:	b8 06 00 00 00       	mov    $0x6,%eax
  800f43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f46:	8b 55 08             	mov    0x8(%ebp),%edx
  800f49:	89 df                	mov    %ebx,%edi
  800f4b:	89 de                	mov    %ebx,%esi
  800f4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	7e 17                	jle    800f6a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f53:	83 ec 0c             	sub    $0xc,%esp
  800f56:	50                   	push   %eax
  800f57:	6a 06                	push   $0x6
  800f59:	68 bf 27 80 00       	push   $0x8027bf
  800f5e:	6a 23                	push   $0x23
  800f60:	68 dc 27 80 00       	push   $0x8027dc
  800f65:	e8 ba f3 ff ff       	call   800324 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6d:	5b                   	pop    %ebx
  800f6e:	5e                   	pop    %esi
  800f6f:	5f                   	pop    %edi
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    

00800f72 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	57                   	push   %edi
  800f76:	56                   	push   %esi
  800f77:	53                   	push   %ebx
  800f78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f80:	b8 08 00 00 00       	mov    $0x8,%eax
  800f85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f88:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8b:	89 df                	mov    %ebx,%edi
  800f8d:	89 de                	mov    %ebx,%esi
  800f8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f91:	85 c0                	test   %eax,%eax
  800f93:	7e 17                	jle    800fac <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f95:	83 ec 0c             	sub    $0xc,%esp
  800f98:	50                   	push   %eax
  800f99:	6a 08                	push   $0x8
  800f9b:	68 bf 27 80 00       	push   $0x8027bf
  800fa0:	6a 23                	push   $0x23
  800fa2:	68 dc 27 80 00       	push   $0x8027dc
  800fa7:	e8 78 f3 ff ff       	call   800324 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800faf:	5b                   	pop    %ebx
  800fb0:	5e                   	pop    %esi
  800fb1:	5f                   	pop    %edi
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	57                   	push   %edi
  800fb8:	56                   	push   %esi
  800fb9:	53                   	push   %ebx
  800fba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fca:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcd:	89 df                	mov    %ebx,%edi
  800fcf:	89 de                	mov    %ebx,%esi
  800fd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	7e 17                	jle    800fee <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	50                   	push   %eax
  800fdb:	6a 0a                	push   $0xa
  800fdd:	68 bf 27 80 00       	push   $0x8027bf
  800fe2:	6a 23                	push   $0x23
  800fe4:	68 dc 27 80 00       	push   $0x8027dc
  800fe9:	e8 36 f3 ff ff       	call   800324 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	57                   	push   %edi
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
  800ffc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801004:	b8 09 00 00 00       	mov    $0x9,%eax
  801009:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80100c:	8b 55 08             	mov    0x8(%ebp),%edx
  80100f:	89 df                	mov    %ebx,%edi
  801011:	89 de                	mov    %ebx,%esi
  801013:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801015:	85 c0                	test   %eax,%eax
  801017:	7e 17                	jle    801030 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801019:	83 ec 0c             	sub    $0xc,%esp
  80101c:	50                   	push   %eax
  80101d:	6a 09                	push   $0x9
  80101f:	68 bf 27 80 00       	push   $0x8027bf
  801024:	6a 23                	push   $0x23
  801026:	68 dc 27 80 00       	push   $0x8027dc
  80102b:	e8 f4 f2 ff ff       	call   800324 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801030:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801033:	5b                   	pop    %ebx
  801034:	5e                   	pop    %esi
  801035:	5f                   	pop    %edi
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    

00801038 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	57                   	push   %edi
  80103c:	56                   	push   %esi
  80103d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103e:	be 00 00 00 00       	mov    $0x0,%esi
  801043:	b8 0c 00 00 00       	mov    $0xc,%eax
  801048:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104b:	8b 55 08             	mov    0x8(%ebp),%edx
  80104e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801051:	8b 7d 14             	mov    0x14(%ebp),%edi
  801054:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801056:	5b                   	pop    %ebx
  801057:	5e                   	pop    %esi
  801058:	5f                   	pop    %edi
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    

0080105b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	57                   	push   %edi
  80105f:	56                   	push   %esi
  801060:	53                   	push   %ebx
  801061:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801064:	b9 00 00 00 00       	mov    $0x0,%ecx
  801069:	b8 0d 00 00 00       	mov    $0xd,%eax
  80106e:	8b 55 08             	mov    0x8(%ebp),%edx
  801071:	89 cb                	mov    %ecx,%ebx
  801073:	89 cf                	mov    %ecx,%edi
  801075:	89 ce                	mov    %ecx,%esi
  801077:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801079:	85 c0                	test   %eax,%eax
  80107b:	7e 17                	jle    801094 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107d:	83 ec 0c             	sub    $0xc,%esp
  801080:	50                   	push   %eax
  801081:	6a 0d                	push   $0xd
  801083:	68 bf 27 80 00       	push   $0x8027bf
  801088:	6a 23                	push   $0x23
  80108a:	68 dc 27 80 00       	push   $0x8027dc
  80108f:	e8 90 f2 ff ff       	call   800324 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801094:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801097:	5b                   	pop    %ebx
  801098:	5e                   	pop    %esi
  801099:	5f                   	pop    %edi
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    

0080109c <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a5:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  8010a8:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  8010aa:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  8010ad:	83 3a 01             	cmpl   $0x1,(%edx)
  8010b0:	7e 09                	jle    8010bb <argstart+0x1f>
  8010b2:	ba 68 24 80 00       	mov    $0x802468,%edx
  8010b7:	85 c9                	test   %ecx,%ecx
  8010b9:	75 05                	jne    8010c0 <argstart+0x24>
  8010bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c0:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  8010c3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  8010ca:	5d                   	pop    %ebp
  8010cb:	c3                   	ret    

008010cc <argnext>:

int
argnext(struct Argstate *args)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	53                   	push   %ebx
  8010d0:	83 ec 04             	sub    $0x4,%esp
  8010d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  8010d6:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  8010dd:	8b 43 08             	mov    0x8(%ebx),%eax
  8010e0:	85 c0                	test   %eax,%eax
  8010e2:	74 6f                	je     801153 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  8010e4:	80 38 00             	cmpb   $0x0,(%eax)
  8010e7:	75 4e                	jne    801137 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  8010e9:	8b 0b                	mov    (%ebx),%ecx
  8010eb:	83 39 01             	cmpl   $0x1,(%ecx)
  8010ee:	74 55                	je     801145 <argnext+0x79>
		    || args->argv[1][0] != '-'
  8010f0:	8b 53 04             	mov    0x4(%ebx),%edx
  8010f3:	8b 42 04             	mov    0x4(%edx),%eax
  8010f6:	80 38 2d             	cmpb   $0x2d,(%eax)
  8010f9:	75 4a                	jne    801145 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  8010fb:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8010ff:	74 44                	je     801145 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801101:	83 c0 01             	add    $0x1,%eax
  801104:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801107:	83 ec 04             	sub    $0x4,%esp
  80110a:	8b 01                	mov    (%ecx),%eax
  80110c:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801113:	50                   	push   %eax
  801114:	8d 42 08             	lea    0x8(%edx),%eax
  801117:	50                   	push   %eax
  801118:	83 c2 04             	add    $0x4,%edx
  80111b:	52                   	push   %edx
  80111c:	e8 a2 fa ff ff       	call   800bc3 <memmove>
		(*args->argc)--;
  801121:	8b 03                	mov    (%ebx),%eax
  801123:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801126:	8b 43 08             	mov    0x8(%ebx),%eax
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	80 38 2d             	cmpb   $0x2d,(%eax)
  80112f:	75 06                	jne    801137 <argnext+0x6b>
  801131:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801135:	74 0e                	je     801145 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801137:	8b 53 08             	mov    0x8(%ebx),%edx
  80113a:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  80113d:	83 c2 01             	add    $0x1,%edx
  801140:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801143:	eb 13                	jmp    801158 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801145:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  80114c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801151:	eb 05                	jmp    801158 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801153:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801158:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115b:	c9                   	leave  
  80115c:	c3                   	ret    

0080115d <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	53                   	push   %ebx
  801161:	83 ec 04             	sub    $0x4,%esp
  801164:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801167:	8b 43 08             	mov    0x8(%ebx),%eax
  80116a:	85 c0                	test   %eax,%eax
  80116c:	74 58                	je     8011c6 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  80116e:	80 38 00             	cmpb   $0x0,(%eax)
  801171:	74 0c                	je     80117f <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801173:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801176:	c7 43 08 68 24 80 00 	movl   $0x802468,0x8(%ebx)
  80117d:	eb 42                	jmp    8011c1 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  80117f:	8b 13                	mov    (%ebx),%edx
  801181:	83 3a 01             	cmpl   $0x1,(%edx)
  801184:	7e 2d                	jle    8011b3 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801186:	8b 43 04             	mov    0x4(%ebx),%eax
  801189:	8b 48 04             	mov    0x4(%eax),%ecx
  80118c:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80118f:	83 ec 04             	sub    $0x4,%esp
  801192:	8b 12                	mov    (%edx),%edx
  801194:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  80119b:	52                   	push   %edx
  80119c:	8d 50 08             	lea    0x8(%eax),%edx
  80119f:	52                   	push   %edx
  8011a0:	83 c0 04             	add    $0x4,%eax
  8011a3:	50                   	push   %eax
  8011a4:	e8 1a fa ff ff       	call   800bc3 <memmove>
		(*args->argc)--;
  8011a9:	8b 03                	mov    (%ebx),%eax
  8011ab:	83 28 01             	subl   $0x1,(%eax)
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	eb 0e                	jmp    8011c1 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  8011b3:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8011ba:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8011c1:	8b 43 0c             	mov    0xc(%ebx),%eax
  8011c4:	eb 05                	jmp    8011cb <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8011c6:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8011cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ce:	c9                   	leave  
  8011cf:	c3                   	ret    

008011d0 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	83 ec 08             	sub    $0x8,%esp
  8011d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8011d9:	8b 51 0c             	mov    0xc(%ecx),%edx
  8011dc:	89 d0                	mov    %edx,%eax
  8011de:	85 d2                	test   %edx,%edx
  8011e0:	75 0c                	jne    8011ee <argvalue+0x1e>
  8011e2:	83 ec 0c             	sub    $0xc,%esp
  8011e5:	51                   	push   %ecx
  8011e6:	e8 72 ff ff ff       	call   80115d <argnextvalue>
  8011eb:	83 c4 10             	add    $0x10,%esp
}
  8011ee:	c9                   	leave  
  8011ef:	c3                   	ret    

008011f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    

00801200 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801203:	8b 45 08             	mov    0x8(%ebp),%eax
  801206:	05 00 00 00 30       	add    $0x30000000,%eax
  80120b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801210:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801215:	5d                   	pop    %ebp
  801216:	c3                   	ret    

00801217 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80121d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801222:	89 c2                	mov    %eax,%edx
  801224:	c1 ea 16             	shr    $0x16,%edx
  801227:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80122e:	f6 c2 01             	test   $0x1,%dl
  801231:	74 11                	je     801244 <fd_alloc+0x2d>
  801233:	89 c2                	mov    %eax,%edx
  801235:	c1 ea 0c             	shr    $0xc,%edx
  801238:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80123f:	f6 c2 01             	test   $0x1,%dl
  801242:	75 09                	jne    80124d <fd_alloc+0x36>
			*fd_store = fd;
  801244:	89 01                	mov    %eax,(%ecx)
			return 0;
  801246:	b8 00 00 00 00       	mov    $0x0,%eax
  80124b:	eb 17                	jmp    801264 <fd_alloc+0x4d>
  80124d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801252:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801257:	75 c9                	jne    801222 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801259:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80125f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801264:	5d                   	pop    %ebp
  801265:	c3                   	ret    

00801266 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80126c:	83 f8 1f             	cmp    $0x1f,%eax
  80126f:	77 36                	ja     8012a7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801271:	c1 e0 0c             	shl    $0xc,%eax
  801274:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801279:	89 c2                	mov    %eax,%edx
  80127b:	c1 ea 16             	shr    $0x16,%edx
  80127e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801285:	f6 c2 01             	test   $0x1,%dl
  801288:	74 24                	je     8012ae <fd_lookup+0x48>
  80128a:	89 c2                	mov    %eax,%edx
  80128c:	c1 ea 0c             	shr    $0xc,%edx
  80128f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801296:	f6 c2 01             	test   $0x1,%dl
  801299:	74 1a                	je     8012b5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80129b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80129e:	89 02                	mov    %eax,(%edx)
	return 0;
  8012a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a5:	eb 13                	jmp    8012ba <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ac:	eb 0c                	jmp    8012ba <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b3:	eb 05                	jmp    8012ba <fd_lookup+0x54>
  8012b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012ba:	5d                   	pop    %ebp
  8012bb:	c3                   	ret    

008012bc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	83 ec 08             	sub    $0x8,%esp
  8012c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c5:	ba 68 28 80 00       	mov    $0x802868,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ca:	eb 13                	jmp    8012df <dev_lookup+0x23>
  8012cc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012cf:	39 08                	cmp    %ecx,(%eax)
  8012d1:	75 0c                	jne    8012df <dev_lookup+0x23>
			*dev = devtab[i];
  8012d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012dd:	eb 2e                	jmp    80130d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012df:	8b 02                	mov    (%edx),%eax
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	75 e7                	jne    8012cc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012e5:	a1 20 44 80 00       	mov    0x804420,%eax
  8012ea:	8b 40 48             	mov    0x48(%eax),%eax
  8012ed:	83 ec 04             	sub    $0x4,%esp
  8012f0:	51                   	push   %ecx
  8012f1:	50                   	push   %eax
  8012f2:	68 ec 27 80 00       	push   $0x8027ec
  8012f7:	e8 01 f1 ff ff       	call   8003fd <cprintf>
	*dev = 0;
  8012fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80130d:	c9                   	leave  
  80130e:	c3                   	ret    

0080130f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	56                   	push   %esi
  801313:	53                   	push   %ebx
  801314:	83 ec 10             	sub    $0x10,%esp
  801317:	8b 75 08             	mov    0x8(%ebp),%esi
  80131a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80131d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801320:	50                   	push   %eax
  801321:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801327:	c1 e8 0c             	shr    $0xc,%eax
  80132a:	50                   	push   %eax
  80132b:	e8 36 ff ff ff       	call   801266 <fd_lookup>
  801330:	83 c4 08             	add    $0x8,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	78 05                	js     80133c <fd_close+0x2d>
	    || fd != fd2) 
  801337:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80133a:	74 0c                	je     801348 <fd_close+0x39>
		return (must_exist ? r : 0); 
  80133c:	84 db                	test   %bl,%bl
  80133e:	ba 00 00 00 00       	mov    $0x0,%edx
  801343:	0f 44 c2             	cmove  %edx,%eax
  801346:	eb 41                	jmp    801389 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801348:	83 ec 08             	sub    $0x8,%esp
  80134b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134e:	50                   	push   %eax
  80134f:	ff 36                	pushl  (%esi)
  801351:	e8 66 ff ff ff       	call   8012bc <dev_lookup>
  801356:	89 c3                	mov    %eax,%ebx
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	85 c0                	test   %eax,%eax
  80135d:	78 1a                	js     801379 <fd_close+0x6a>
		if (dev->dev_close) 
  80135f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801362:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  801365:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  80136a:	85 c0                	test   %eax,%eax
  80136c:	74 0b                	je     801379 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80136e:	83 ec 0c             	sub    $0xc,%esp
  801371:	56                   	push   %esi
  801372:	ff d0                	call   *%eax
  801374:	89 c3                	mov    %eax,%ebx
  801376:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	56                   	push   %esi
  80137d:	6a 00                	push   $0x0
  80137f:	e8 ac fb ff ff       	call   800f30 <sys_page_unmap>
	return r;
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	89 d8                	mov    %ebx,%eax
}
  801389:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80138c:	5b                   	pop    %ebx
  80138d:	5e                   	pop    %esi
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    

00801390 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801396:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801399:	50                   	push   %eax
  80139a:	ff 75 08             	pushl  0x8(%ebp)
  80139d:	e8 c4 fe ff ff       	call   801266 <fd_lookup>
  8013a2:	83 c4 08             	add    $0x8,%esp
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	78 10                	js     8013b9 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  8013a9:	83 ec 08             	sub    $0x8,%esp
  8013ac:	6a 01                	push   $0x1
  8013ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b1:	e8 59 ff ff ff       	call   80130f <fd_close>
  8013b6:	83 c4 10             	add    $0x10,%esp
}
  8013b9:	c9                   	leave  
  8013ba:	c3                   	ret    

008013bb <close_all>:

void
close_all(void)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	53                   	push   %ebx
  8013bf:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013c2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013c7:	83 ec 0c             	sub    $0xc,%esp
  8013ca:	53                   	push   %ebx
  8013cb:	e8 c0 ff ff ff       	call   801390 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013d0:	83 c3 01             	add    $0x1,%ebx
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	83 fb 20             	cmp    $0x20,%ebx
  8013d9:	75 ec                	jne    8013c7 <close_all+0xc>
		close(i);
}
  8013db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013de:	c9                   	leave  
  8013df:	c3                   	ret    

008013e0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	57                   	push   %edi
  8013e4:	56                   	push   %esi
  8013e5:	53                   	push   %ebx
  8013e6:	83 ec 2c             	sub    $0x2c,%esp
  8013e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013ec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013ef:	50                   	push   %eax
  8013f0:	ff 75 08             	pushl  0x8(%ebp)
  8013f3:	e8 6e fe ff ff       	call   801266 <fd_lookup>
  8013f8:	83 c4 08             	add    $0x8,%esp
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	0f 88 c1 00 00 00    	js     8014c4 <dup+0xe4>
		return r;
	close(newfdnum);
  801403:	83 ec 0c             	sub    $0xc,%esp
  801406:	56                   	push   %esi
  801407:	e8 84 ff ff ff       	call   801390 <close>

	newfd = INDEX2FD(newfdnum);
  80140c:	89 f3                	mov    %esi,%ebx
  80140e:	c1 e3 0c             	shl    $0xc,%ebx
  801411:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801417:	83 c4 04             	add    $0x4,%esp
  80141a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80141d:	e8 de fd ff ff       	call   801200 <fd2data>
  801422:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801424:	89 1c 24             	mov    %ebx,(%esp)
  801427:	e8 d4 fd ff ff       	call   801200 <fd2data>
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801432:	89 f8                	mov    %edi,%eax
  801434:	c1 e8 16             	shr    $0x16,%eax
  801437:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80143e:	a8 01                	test   $0x1,%al
  801440:	74 37                	je     801479 <dup+0x99>
  801442:	89 f8                	mov    %edi,%eax
  801444:	c1 e8 0c             	shr    $0xc,%eax
  801447:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80144e:	f6 c2 01             	test   $0x1,%dl
  801451:	74 26                	je     801479 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801453:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80145a:	83 ec 0c             	sub    $0xc,%esp
  80145d:	25 07 0e 00 00       	and    $0xe07,%eax
  801462:	50                   	push   %eax
  801463:	ff 75 d4             	pushl  -0x2c(%ebp)
  801466:	6a 00                	push   $0x0
  801468:	57                   	push   %edi
  801469:	6a 00                	push   $0x0
  80146b:	e8 7e fa ff ff       	call   800eee <sys_page_map>
  801470:	89 c7                	mov    %eax,%edi
  801472:	83 c4 20             	add    $0x20,%esp
  801475:	85 c0                	test   %eax,%eax
  801477:	78 2e                	js     8014a7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801479:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80147c:	89 d0                	mov    %edx,%eax
  80147e:	c1 e8 0c             	shr    $0xc,%eax
  801481:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801488:	83 ec 0c             	sub    $0xc,%esp
  80148b:	25 07 0e 00 00       	and    $0xe07,%eax
  801490:	50                   	push   %eax
  801491:	53                   	push   %ebx
  801492:	6a 00                	push   $0x0
  801494:	52                   	push   %edx
  801495:	6a 00                	push   $0x0
  801497:	e8 52 fa ff ff       	call   800eee <sys_page_map>
  80149c:	89 c7                	mov    %eax,%edi
  80149e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014a1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014a3:	85 ff                	test   %edi,%edi
  8014a5:	79 1d                	jns    8014c4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014a7:	83 ec 08             	sub    $0x8,%esp
  8014aa:	53                   	push   %ebx
  8014ab:	6a 00                	push   $0x0
  8014ad:	e8 7e fa ff ff       	call   800f30 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014b2:	83 c4 08             	add    $0x8,%esp
  8014b5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014b8:	6a 00                	push   $0x0
  8014ba:	e8 71 fa ff ff       	call   800f30 <sys_page_unmap>
	return r;
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	89 f8                	mov    %edi,%eax
}
  8014c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c7:	5b                   	pop    %ebx
  8014c8:	5e                   	pop    %esi
  8014c9:	5f                   	pop    %edi
  8014ca:	5d                   	pop    %ebp
  8014cb:	c3                   	ret    

008014cc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	53                   	push   %ebx
  8014d0:	83 ec 14             	sub    $0x14,%esp
  8014d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d9:	50                   	push   %eax
  8014da:	53                   	push   %ebx
  8014db:	e8 86 fd ff ff       	call   801266 <fd_lookup>
  8014e0:	83 c4 08             	add    $0x8,%esp
  8014e3:	89 c2                	mov    %eax,%edx
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 6d                	js     801556 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e9:	83 ec 08             	sub    $0x8,%esp
  8014ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ef:	50                   	push   %eax
  8014f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f3:	ff 30                	pushl  (%eax)
  8014f5:	e8 c2 fd ff ff       	call   8012bc <dev_lookup>
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	78 4c                	js     80154d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801501:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801504:	8b 42 08             	mov    0x8(%edx),%eax
  801507:	83 e0 03             	and    $0x3,%eax
  80150a:	83 f8 01             	cmp    $0x1,%eax
  80150d:	75 21                	jne    801530 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80150f:	a1 20 44 80 00       	mov    0x804420,%eax
  801514:	8b 40 48             	mov    0x48(%eax),%eax
  801517:	83 ec 04             	sub    $0x4,%esp
  80151a:	53                   	push   %ebx
  80151b:	50                   	push   %eax
  80151c:	68 2d 28 80 00       	push   $0x80282d
  801521:	e8 d7 ee ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80152e:	eb 26                	jmp    801556 <read+0x8a>
	}
	if (!dev->dev_read)
  801530:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801533:	8b 40 08             	mov    0x8(%eax),%eax
  801536:	85 c0                	test   %eax,%eax
  801538:	74 17                	je     801551 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80153a:	83 ec 04             	sub    $0x4,%esp
  80153d:	ff 75 10             	pushl  0x10(%ebp)
  801540:	ff 75 0c             	pushl  0xc(%ebp)
  801543:	52                   	push   %edx
  801544:	ff d0                	call   *%eax
  801546:	89 c2                	mov    %eax,%edx
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	eb 09                	jmp    801556 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154d:	89 c2                	mov    %eax,%edx
  80154f:	eb 05                	jmp    801556 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801551:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801556:	89 d0                	mov    %edx,%eax
  801558:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155b:	c9                   	leave  
  80155c:	c3                   	ret    

0080155d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	57                   	push   %edi
  801561:	56                   	push   %esi
  801562:	53                   	push   %ebx
  801563:	83 ec 0c             	sub    $0xc,%esp
  801566:	8b 7d 08             	mov    0x8(%ebp),%edi
  801569:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80156c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801571:	eb 21                	jmp    801594 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801573:	83 ec 04             	sub    $0x4,%esp
  801576:	89 f0                	mov    %esi,%eax
  801578:	29 d8                	sub    %ebx,%eax
  80157a:	50                   	push   %eax
  80157b:	89 d8                	mov    %ebx,%eax
  80157d:	03 45 0c             	add    0xc(%ebp),%eax
  801580:	50                   	push   %eax
  801581:	57                   	push   %edi
  801582:	e8 45 ff ff ff       	call   8014cc <read>
		if (m < 0)
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	85 c0                	test   %eax,%eax
  80158c:	78 10                	js     80159e <readn+0x41>
			return m;
		if (m == 0)
  80158e:	85 c0                	test   %eax,%eax
  801590:	74 0a                	je     80159c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801592:	01 c3                	add    %eax,%ebx
  801594:	39 f3                	cmp    %esi,%ebx
  801596:	72 db                	jb     801573 <readn+0x16>
  801598:	89 d8                	mov    %ebx,%eax
  80159a:	eb 02                	jmp    80159e <readn+0x41>
  80159c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80159e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a1:	5b                   	pop    %ebx
  8015a2:	5e                   	pop    %esi
  8015a3:	5f                   	pop    %edi
  8015a4:	5d                   	pop    %ebp
  8015a5:	c3                   	ret    

008015a6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	53                   	push   %ebx
  8015aa:	83 ec 14             	sub    $0x14,%esp
  8015ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	53                   	push   %ebx
  8015b5:	e8 ac fc ff ff       	call   801266 <fd_lookup>
  8015ba:	83 c4 08             	add    $0x8,%esp
  8015bd:	89 c2                	mov    %eax,%edx
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 68                	js     80162b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c3:	83 ec 08             	sub    $0x8,%esp
  8015c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cd:	ff 30                	pushl  (%eax)
  8015cf:	e8 e8 fc ff ff       	call   8012bc <dev_lookup>
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 47                	js     801622 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015de:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015e2:	75 21                	jne    801605 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015e4:	a1 20 44 80 00       	mov    0x804420,%eax
  8015e9:	8b 40 48             	mov    0x48(%eax),%eax
  8015ec:	83 ec 04             	sub    $0x4,%esp
  8015ef:	53                   	push   %ebx
  8015f0:	50                   	push   %eax
  8015f1:	68 49 28 80 00       	push   $0x802849
  8015f6:	e8 02 ee ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801603:	eb 26                	jmp    80162b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801605:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801608:	8b 52 0c             	mov    0xc(%edx),%edx
  80160b:	85 d2                	test   %edx,%edx
  80160d:	74 17                	je     801626 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80160f:	83 ec 04             	sub    $0x4,%esp
  801612:	ff 75 10             	pushl  0x10(%ebp)
  801615:	ff 75 0c             	pushl  0xc(%ebp)
  801618:	50                   	push   %eax
  801619:	ff d2                	call   *%edx
  80161b:	89 c2                	mov    %eax,%edx
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	eb 09                	jmp    80162b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801622:	89 c2                	mov    %eax,%edx
  801624:	eb 05                	jmp    80162b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801626:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80162b:	89 d0                	mov    %edx,%eax
  80162d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801630:	c9                   	leave  
  801631:	c3                   	ret    

00801632 <seek>:

int
seek(int fdnum, off_t offset)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801638:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80163b:	50                   	push   %eax
  80163c:	ff 75 08             	pushl  0x8(%ebp)
  80163f:	e8 22 fc ff ff       	call   801266 <fd_lookup>
  801644:	83 c4 08             	add    $0x8,%esp
  801647:	85 c0                	test   %eax,%eax
  801649:	78 0e                	js     801659 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80164b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80164e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801651:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801654:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801659:	c9                   	leave  
  80165a:	c3                   	ret    

0080165b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	53                   	push   %ebx
  80165f:	83 ec 14             	sub    $0x14,%esp
  801662:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801665:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	53                   	push   %ebx
  80166a:	e8 f7 fb ff ff       	call   801266 <fd_lookup>
  80166f:	83 c4 08             	add    $0x8,%esp
  801672:	89 c2                	mov    %eax,%edx
  801674:	85 c0                	test   %eax,%eax
  801676:	78 65                	js     8016dd <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801678:	83 ec 08             	sub    $0x8,%esp
  80167b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167e:	50                   	push   %eax
  80167f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801682:	ff 30                	pushl  (%eax)
  801684:	e8 33 fc ff ff       	call   8012bc <dev_lookup>
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 44                	js     8016d4 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801690:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801693:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801697:	75 21                	jne    8016ba <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801699:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80169e:	8b 40 48             	mov    0x48(%eax),%eax
  8016a1:	83 ec 04             	sub    $0x4,%esp
  8016a4:	53                   	push   %ebx
  8016a5:	50                   	push   %eax
  8016a6:	68 0c 28 80 00       	push   $0x80280c
  8016ab:	e8 4d ed ff ff       	call   8003fd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016b8:	eb 23                	jmp    8016dd <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016bd:	8b 52 18             	mov    0x18(%edx),%edx
  8016c0:	85 d2                	test   %edx,%edx
  8016c2:	74 14                	je     8016d8 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016c4:	83 ec 08             	sub    $0x8,%esp
  8016c7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ca:	50                   	push   %eax
  8016cb:	ff d2                	call   *%edx
  8016cd:	89 c2                	mov    %eax,%edx
  8016cf:	83 c4 10             	add    $0x10,%esp
  8016d2:	eb 09                	jmp    8016dd <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d4:	89 c2                	mov    %eax,%edx
  8016d6:	eb 05                	jmp    8016dd <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016dd:	89 d0                	mov    %edx,%eax
  8016df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e2:	c9                   	leave  
  8016e3:	c3                   	ret    

008016e4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	53                   	push   %ebx
  8016e8:	83 ec 14             	sub    $0x14,%esp
  8016eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f1:	50                   	push   %eax
  8016f2:	ff 75 08             	pushl  0x8(%ebp)
  8016f5:	e8 6c fb ff ff       	call   801266 <fd_lookup>
  8016fa:	83 c4 08             	add    $0x8,%esp
  8016fd:	89 c2                	mov    %eax,%edx
  8016ff:	85 c0                	test   %eax,%eax
  801701:	78 58                	js     80175b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801703:	83 ec 08             	sub    $0x8,%esp
  801706:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801709:	50                   	push   %eax
  80170a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170d:	ff 30                	pushl  (%eax)
  80170f:	e8 a8 fb ff ff       	call   8012bc <dev_lookup>
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	85 c0                	test   %eax,%eax
  801719:	78 37                	js     801752 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80171b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801722:	74 32                	je     801756 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801724:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801727:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80172e:	00 00 00 
	stat->st_isdir = 0;
  801731:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801738:	00 00 00 
	stat->st_dev = dev;
  80173b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801741:	83 ec 08             	sub    $0x8,%esp
  801744:	53                   	push   %ebx
  801745:	ff 75 f0             	pushl  -0x10(%ebp)
  801748:	ff 50 14             	call   *0x14(%eax)
  80174b:	89 c2                	mov    %eax,%edx
  80174d:	83 c4 10             	add    $0x10,%esp
  801750:	eb 09                	jmp    80175b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801752:	89 c2                	mov    %eax,%edx
  801754:	eb 05                	jmp    80175b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801756:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80175b:	89 d0                	mov    %edx,%eax
  80175d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801760:	c9                   	leave  
  801761:	c3                   	ret    

00801762 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	56                   	push   %esi
  801766:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	6a 00                	push   $0x0
  80176c:	ff 75 08             	pushl  0x8(%ebp)
  80176f:	e8 2b 02 00 00       	call   80199f <open>
  801774:	89 c3                	mov    %eax,%ebx
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	85 c0                	test   %eax,%eax
  80177b:	78 1b                	js     801798 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80177d:	83 ec 08             	sub    $0x8,%esp
  801780:	ff 75 0c             	pushl  0xc(%ebp)
  801783:	50                   	push   %eax
  801784:	e8 5b ff ff ff       	call   8016e4 <fstat>
  801789:	89 c6                	mov    %eax,%esi
	close(fd);
  80178b:	89 1c 24             	mov    %ebx,(%esp)
  80178e:	e8 fd fb ff ff       	call   801390 <close>
	return r;
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	89 f0                	mov    %esi,%eax
}
  801798:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179b:	5b                   	pop    %ebx
  80179c:	5e                   	pop    %esi
  80179d:	5d                   	pop    %ebp
  80179e:	c3                   	ret    

0080179f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80179f:	55                   	push   %ebp
  8017a0:	89 e5                	mov    %esp,%ebp
  8017a2:	56                   	push   %esi
  8017a3:	53                   	push   %ebx
  8017a4:	89 c6                	mov    %eax,%esi
  8017a6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017a8:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017af:	75 12                	jne    8017c3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017b1:	83 ec 0c             	sub    $0xc,%esp
  8017b4:	6a 01                	push   $0x1
  8017b6:	e8 36 09 00 00       	call   8020f1 <ipc_find_env>
  8017bb:	a3 04 40 80 00       	mov    %eax,0x804004
  8017c0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017c3:	6a 07                	push   $0x7
  8017c5:	68 00 50 80 00       	push   $0x805000
  8017ca:	56                   	push   %esi
  8017cb:	ff 35 04 40 80 00    	pushl  0x804004
  8017d1:	e8 c5 08 00 00       	call   80209b <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8017d6:	83 c4 0c             	add    $0xc,%esp
  8017d9:	6a 00                	push   $0x0
  8017db:	53                   	push   %ebx
  8017dc:	6a 00                	push   $0x0
  8017de:	e8 4f 08 00 00       	call   802032 <ipc_recv>
}
  8017e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e6:	5b                   	pop    %ebx
  8017e7:	5e                   	pop    %esi
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017fe:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801803:	ba 00 00 00 00       	mov    $0x0,%edx
  801808:	b8 02 00 00 00       	mov    $0x2,%eax
  80180d:	e8 8d ff ff ff       	call   80179f <fsipc>
}
  801812:	c9                   	leave  
  801813:	c3                   	ret    

00801814 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80181a:	8b 45 08             	mov    0x8(%ebp),%eax
  80181d:	8b 40 0c             	mov    0xc(%eax),%eax
  801820:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801825:	ba 00 00 00 00       	mov    $0x0,%edx
  80182a:	b8 06 00 00 00       	mov    $0x6,%eax
  80182f:	e8 6b ff ff ff       	call   80179f <fsipc>
}
  801834:	c9                   	leave  
  801835:	c3                   	ret    

00801836 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	53                   	push   %ebx
  80183a:	83 ec 04             	sub    $0x4,%esp
  80183d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801840:	8b 45 08             	mov    0x8(%ebp),%eax
  801843:	8b 40 0c             	mov    0xc(%eax),%eax
  801846:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80184b:	ba 00 00 00 00       	mov    $0x0,%edx
  801850:	b8 05 00 00 00       	mov    $0x5,%eax
  801855:	e8 45 ff ff ff       	call   80179f <fsipc>
  80185a:	85 c0                	test   %eax,%eax
  80185c:	78 2c                	js     80188a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80185e:	83 ec 08             	sub    $0x8,%esp
  801861:	68 00 50 80 00       	push   $0x805000
  801866:	53                   	push   %ebx
  801867:	e8 c5 f1 ff ff       	call   800a31 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80186c:	a1 80 50 80 00       	mov    0x805080,%eax
  801871:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801877:	a1 84 50 80 00       	mov    0x805084,%eax
  80187c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80188a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188d:	c9                   	leave  
  80188e:	c3                   	ret    

0080188f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	53                   	push   %ebx
  801893:	83 ec 08             	sub    $0x8,%esp
  801896:	8b 45 10             	mov    0x10(%ebp),%eax
  801899:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80189e:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8018a3:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ac:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  8018b1:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018b7:	53                   	push   %ebx
  8018b8:	ff 75 0c             	pushl  0xc(%ebp)
  8018bb:	68 08 50 80 00       	push   $0x805008
  8018c0:	e8 fe f2 ff ff       	call   800bc3 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8018c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ca:	b8 04 00 00 00       	mov    $0x4,%eax
  8018cf:	e8 cb fe ff ff       	call   80179f <fsipc>
  8018d4:	83 c4 10             	add    $0x10,%esp
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	78 3d                	js     801918 <devfile_write+0x89>
		return r;

	assert(r <= n);
  8018db:	39 d8                	cmp    %ebx,%eax
  8018dd:	76 19                	jbe    8018f8 <devfile_write+0x69>
  8018df:	68 78 28 80 00       	push   $0x802878
  8018e4:	68 7f 28 80 00       	push   $0x80287f
  8018e9:	68 9f 00 00 00       	push   $0x9f
  8018ee:	68 94 28 80 00       	push   $0x802894
  8018f3:	e8 2c ea ff ff       	call   800324 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  8018f8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018fd:	76 19                	jbe    801918 <devfile_write+0x89>
  8018ff:	68 ac 28 80 00       	push   $0x8028ac
  801904:	68 7f 28 80 00       	push   $0x80287f
  801909:	68 a0 00 00 00       	push   $0xa0
  80190e:	68 94 28 80 00       	push   $0x802894
  801913:	e8 0c ea ff ff       	call   800324 <_panic>

	return r;
}
  801918:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80191b:	c9                   	leave  
  80191c:	c3                   	ret    

0080191d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	56                   	push   %esi
  801921:	53                   	push   %ebx
  801922:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801925:	8b 45 08             	mov    0x8(%ebp),%eax
  801928:	8b 40 0c             	mov    0xc(%eax),%eax
  80192b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801930:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801936:	ba 00 00 00 00       	mov    $0x0,%edx
  80193b:	b8 03 00 00 00       	mov    $0x3,%eax
  801940:	e8 5a fe ff ff       	call   80179f <fsipc>
  801945:	89 c3                	mov    %eax,%ebx
  801947:	85 c0                	test   %eax,%eax
  801949:	78 4b                	js     801996 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80194b:	39 c6                	cmp    %eax,%esi
  80194d:	73 16                	jae    801965 <devfile_read+0x48>
  80194f:	68 78 28 80 00       	push   $0x802878
  801954:	68 7f 28 80 00       	push   $0x80287f
  801959:	6a 7e                	push   $0x7e
  80195b:	68 94 28 80 00       	push   $0x802894
  801960:	e8 bf e9 ff ff       	call   800324 <_panic>
	assert(r <= PGSIZE);
  801965:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80196a:	7e 16                	jle    801982 <devfile_read+0x65>
  80196c:	68 9f 28 80 00       	push   $0x80289f
  801971:	68 7f 28 80 00       	push   $0x80287f
  801976:	6a 7f                	push   $0x7f
  801978:	68 94 28 80 00       	push   $0x802894
  80197d:	e8 a2 e9 ff ff       	call   800324 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801982:	83 ec 04             	sub    $0x4,%esp
  801985:	50                   	push   %eax
  801986:	68 00 50 80 00       	push   $0x805000
  80198b:	ff 75 0c             	pushl  0xc(%ebp)
  80198e:	e8 30 f2 ff ff       	call   800bc3 <memmove>
	return r;
  801993:	83 c4 10             	add    $0x10,%esp
}
  801996:	89 d8                	mov    %ebx,%eax
  801998:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199b:	5b                   	pop    %ebx
  80199c:	5e                   	pop    %esi
  80199d:	5d                   	pop    %ebp
  80199e:	c3                   	ret    

0080199f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	53                   	push   %ebx
  8019a3:	83 ec 20             	sub    $0x20,%esp
  8019a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019a9:	53                   	push   %ebx
  8019aa:	e8 49 f0 ff ff       	call   8009f8 <strlen>
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019b7:	7f 67                	jg     801a20 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019b9:	83 ec 0c             	sub    $0xc,%esp
  8019bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bf:	50                   	push   %eax
  8019c0:	e8 52 f8 ff ff       	call   801217 <fd_alloc>
  8019c5:	83 c4 10             	add    $0x10,%esp
		return r;
  8019c8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	78 57                	js     801a25 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019ce:	83 ec 08             	sub    $0x8,%esp
  8019d1:	53                   	push   %ebx
  8019d2:	68 00 50 80 00       	push   $0x805000
  8019d7:	e8 55 f0 ff ff       	call   800a31 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019df:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ec:	e8 ae fd ff ff       	call   80179f <fsipc>
  8019f1:	89 c3                	mov    %eax,%ebx
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	79 14                	jns    801a0e <open+0x6f>
		fd_close(fd, 0);
  8019fa:	83 ec 08             	sub    $0x8,%esp
  8019fd:	6a 00                	push   $0x0
  8019ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801a02:	e8 08 f9 ff ff       	call   80130f <fd_close>
		return r;
  801a07:	83 c4 10             	add    $0x10,%esp
  801a0a:	89 da                	mov    %ebx,%edx
  801a0c:	eb 17                	jmp    801a25 <open+0x86>
	}

	return fd2num(fd);
  801a0e:	83 ec 0c             	sub    $0xc,%esp
  801a11:	ff 75 f4             	pushl  -0xc(%ebp)
  801a14:	e8 d7 f7 ff ff       	call   8011f0 <fd2num>
  801a19:	89 c2                	mov    %eax,%edx
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	eb 05                	jmp    801a25 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a20:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a25:	89 d0                	mov    %edx,%eax
  801a27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2a:	c9                   	leave  
  801a2b:	c3                   	ret    

00801a2c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a32:	ba 00 00 00 00       	mov    $0x0,%edx
  801a37:	b8 08 00 00 00       	mov    $0x8,%eax
  801a3c:	e8 5e fd ff ff       	call   80179f <fsipc>
}
  801a41:	c9                   	leave  
  801a42:	c3                   	ret    

00801a43 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801a43:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801a47:	7e 37                	jle    801a80 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	53                   	push   %ebx
  801a4d:	83 ec 08             	sub    $0x8,%esp
  801a50:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801a52:	ff 70 04             	pushl  0x4(%eax)
  801a55:	8d 40 10             	lea    0x10(%eax),%eax
  801a58:	50                   	push   %eax
  801a59:	ff 33                	pushl  (%ebx)
  801a5b:	e8 46 fb ff ff       	call   8015a6 <write>
		if (result > 0)
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	85 c0                	test   %eax,%eax
  801a65:	7e 03                	jle    801a6a <writebuf+0x27>
			b->result += result;
  801a67:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801a6a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a6d:	74 0d                	je     801a7c <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801a6f:	85 c0                	test   %eax,%eax
  801a71:	ba 00 00 00 00       	mov    $0x0,%edx
  801a76:	0f 4f c2             	cmovg  %edx,%eax
  801a79:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801a7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a7f:	c9                   	leave  
  801a80:	f3 c3                	repz ret 

00801a82 <putch>:

static void
putch(int ch, void *thunk)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	53                   	push   %ebx
  801a86:	83 ec 04             	sub    $0x4,%esp
  801a89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801a8c:	8b 53 04             	mov    0x4(%ebx),%edx
  801a8f:	8d 42 01             	lea    0x1(%edx),%eax
  801a92:	89 43 04             	mov    %eax,0x4(%ebx)
  801a95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a98:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801a9c:	3d 00 01 00 00       	cmp    $0x100,%eax
  801aa1:	75 0e                	jne    801ab1 <putch+0x2f>
		writebuf(b);
  801aa3:	89 d8                	mov    %ebx,%eax
  801aa5:	e8 99 ff ff ff       	call   801a43 <writebuf>
		b->idx = 0;
  801aaa:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801ab1:	83 c4 04             	add    $0x4,%esp
  801ab4:	5b                   	pop    %ebx
  801ab5:	5d                   	pop    %ebp
  801ab6:	c3                   	ret    

00801ab7 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac3:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801ac9:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801ad0:	00 00 00 
	b.result = 0;
  801ad3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801ada:	00 00 00 
	b.error = 1;
  801add:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801ae4:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801ae7:	ff 75 10             	pushl  0x10(%ebp)
  801aea:	ff 75 0c             	pushl  0xc(%ebp)
  801aed:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801af3:	50                   	push   %eax
  801af4:	68 82 1a 80 00       	push   $0x801a82
  801af9:	e8 36 ea ff ff       	call   800534 <vprintfmt>
	if (b.idx > 0)
  801afe:	83 c4 10             	add    $0x10,%esp
  801b01:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801b08:	7e 0b                	jle    801b15 <vfprintf+0x5e>
		writebuf(&b);
  801b0a:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801b10:	e8 2e ff ff ff       	call   801a43 <writebuf>

	return (b.result ? b.result : b.error);
  801b15:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801b24:	c9                   	leave  
  801b25:	c3                   	ret    

00801b26 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b2c:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801b2f:	50                   	push   %eax
  801b30:	ff 75 0c             	pushl  0xc(%ebp)
  801b33:	ff 75 08             	pushl  0x8(%ebp)
  801b36:	e8 7c ff ff ff       	call   801ab7 <vfprintf>
	va_end(ap);

	return cnt;
}
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    

00801b3d <printf>:

int
printf(const char *fmt, ...)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b43:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801b46:	50                   	push   %eax
  801b47:	ff 75 08             	pushl  0x8(%ebp)
  801b4a:	6a 01                	push   $0x1
  801b4c:	e8 66 ff ff ff       	call   801ab7 <vfprintf>
	va_end(ap);

	return cnt;
}
  801b51:	c9                   	leave  
  801b52:	c3                   	ret    

00801b53 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	56                   	push   %esi
  801b57:	53                   	push   %ebx
  801b58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b5b:	83 ec 0c             	sub    $0xc,%esp
  801b5e:	ff 75 08             	pushl  0x8(%ebp)
  801b61:	e8 9a f6 ff ff       	call   801200 <fd2data>
  801b66:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b68:	83 c4 08             	add    $0x8,%esp
  801b6b:	68 d9 28 80 00       	push   $0x8028d9
  801b70:	53                   	push   %ebx
  801b71:	e8 bb ee ff ff       	call   800a31 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b76:	8b 46 04             	mov    0x4(%esi),%eax
  801b79:	2b 06                	sub    (%esi),%eax
  801b7b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b81:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b88:	00 00 00 
	stat->st_dev = &devpipe;
  801b8b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b92:	30 80 00 
	return 0;
}
  801b95:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9d:	5b                   	pop    %ebx
  801b9e:	5e                   	pop    %esi
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    

00801ba1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	53                   	push   %ebx
  801ba5:	83 ec 0c             	sub    $0xc,%esp
  801ba8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bab:	53                   	push   %ebx
  801bac:	6a 00                	push   $0x0
  801bae:	e8 7d f3 ff ff       	call   800f30 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bb3:	89 1c 24             	mov    %ebx,(%esp)
  801bb6:	e8 45 f6 ff ff       	call   801200 <fd2data>
  801bbb:	83 c4 08             	add    $0x8,%esp
  801bbe:	50                   	push   %eax
  801bbf:	6a 00                	push   $0x0
  801bc1:	e8 6a f3 ff ff       	call   800f30 <sys_page_unmap>
}
  801bc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc9:	c9                   	leave  
  801bca:	c3                   	ret    

00801bcb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	57                   	push   %edi
  801bcf:	56                   	push   %esi
  801bd0:	53                   	push   %ebx
  801bd1:	83 ec 1c             	sub    $0x1c,%esp
  801bd4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bd7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bd9:	a1 20 44 80 00       	mov    0x804420,%eax
  801bde:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801be1:	83 ec 0c             	sub    $0xc,%esp
  801be4:	ff 75 e0             	pushl  -0x20(%ebp)
  801be7:	e8 3e 05 00 00       	call   80212a <pageref>
  801bec:	89 c3                	mov    %eax,%ebx
  801bee:	89 3c 24             	mov    %edi,(%esp)
  801bf1:	e8 34 05 00 00       	call   80212a <pageref>
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	39 c3                	cmp    %eax,%ebx
  801bfb:	0f 94 c1             	sete   %cl
  801bfe:	0f b6 c9             	movzbl %cl,%ecx
  801c01:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c04:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801c0a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c0d:	39 ce                	cmp    %ecx,%esi
  801c0f:	74 1b                	je     801c2c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c11:	39 c3                	cmp    %eax,%ebx
  801c13:	75 c4                	jne    801bd9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c15:	8b 42 58             	mov    0x58(%edx),%eax
  801c18:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c1b:	50                   	push   %eax
  801c1c:	56                   	push   %esi
  801c1d:	68 e0 28 80 00       	push   $0x8028e0
  801c22:	e8 d6 e7 ff ff       	call   8003fd <cprintf>
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	eb ad                	jmp    801bd9 <_pipeisclosed+0xe>
	}
}
  801c2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c32:	5b                   	pop    %ebx
  801c33:	5e                   	pop    %esi
  801c34:	5f                   	pop    %edi
  801c35:	5d                   	pop    %ebp
  801c36:	c3                   	ret    

00801c37 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	57                   	push   %edi
  801c3b:	56                   	push   %esi
  801c3c:	53                   	push   %ebx
  801c3d:	83 ec 28             	sub    $0x28,%esp
  801c40:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c43:	56                   	push   %esi
  801c44:	e8 b7 f5 ff ff       	call   801200 <fd2data>
  801c49:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c4b:	83 c4 10             	add    $0x10,%esp
  801c4e:	bf 00 00 00 00       	mov    $0x0,%edi
  801c53:	eb 4b                	jmp    801ca0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c55:	89 da                	mov    %ebx,%edx
  801c57:	89 f0                	mov    %esi,%eax
  801c59:	e8 6d ff ff ff       	call   801bcb <_pipeisclosed>
  801c5e:	85 c0                	test   %eax,%eax
  801c60:	75 48                	jne    801caa <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c62:	e8 25 f2 ff ff       	call   800e8c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c67:	8b 43 04             	mov    0x4(%ebx),%eax
  801c6a:	8b 0b                	mov    (%ebx),%ecx
  801c6c:	8d 51 20             	lea    0x20(%ecx),%edx
  801c6f:	39 d0                	cmp    %edx,%eax
  801c71:	73 e2                	jae    801c55 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c76:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c7a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c7d:	89 c2                	mov    %eax,%edx
  801c7f:	c1 fa 1f             	sar    $0x1f,%edx
  801c82:	89 d1                	mov    %edx,%ecx
  801c84:	c1 e9 1b             	shr    $0x1b,%ecx
  801c87:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c8a:	83 e2 1f             	and    $0x1f,%edx
  801c8d:	29 ca                	sub    %ecx,%edx
  801c8f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c93:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c97:	83 c0 01             	add    $0x1,%eax
  801c9a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c9d:	83 c7 01             	add    $0x1,%edi
  801ca0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ca3:	75 c2                	jne    801c67 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ca5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca8:	eb 05                	jmp    801caf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801caa:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb2:	5b                   	pop    %ebx
  801cb3:	5e                   	pop    %esi
  801cb4:	5f                   	pop    %edi
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    

00801cb7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	57                   	push   %edi
  801cbb:	56                   	push   %esi
  801cbc:	53                   	push   %ebx
  801cbd:	83 ec 18             	sub    $0x18,%esp
  801cc0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cc3:	57                   	push   %edi
  801cc4:	e8 37 f5 ff ff       	call   801200 <fd2data>
  801cc9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ccb:	83 c4 10             	add    $0x10,%esp
  801cce:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cd3:	eb 3d                	jmp    801d12 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cd5:	85 db                	test   %ebx,%ebx
  801cd7:	74 04                	je     801cdd <devpipe_read+0x26>
				return i;
  801cd9:	89 d8                	mov    %ebx,%eax
  801cdb:	eb 44                	jmp    801d21 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cdd:	89 f2                	mov    %esi,%edx
  801cdf:	89 f8                	mov    %edi,%eax
  801ce1:	e8 e5 fe ff ff       	call   801bcb <_pipeisclosed>
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	75 32                	jne    801d1c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cea:	e8 9d f1 ff ff       	call   800e8c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cef:	8b 06                	mov    (%esi),%eax
  801cf1:	3b 46 04             	cmp    0x4(%esi),%eax
  801cf4:	74 df                	je     801cd5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cf6:	99                   	cltd   
  801cf7:	c1 ea 1b             	shr    $0x1b,%edx
  801cfa:	01 d0                	add    %edx,%eax
  801cfc:	83 e0 1f             	and    $0x1f,%eax
  801cff:	29 d0                	sub    %edx,%eax
  801d01:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d09:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d0c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d0f:	83 c3 01             	add    $0x1,%ebx
  801d12:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d15:	75 d8                	jne    801cef <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d17:	8b 45 10             	mov    0x10(%ebp),%eax
  801d1a:	eb 05                	jmp    801d21 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d1c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5f                   	pop    %edi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    

00801d29 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
  801d2c:	56                   	push   %esi
  801d2d:	53                   	push   %ebx
  801d2e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d34:	50                   	push   %eax
  801d35:	e8 dd f4 ff ff       	call   801217 <fd_alloc>
  801d3a:	83 c4 10             	add    $0x10,%esp
  801d3d:	89 c2                	mov    %eax,%edx
  801d3f:	85 c0                	test   %eax,%eax
  801d41:	0f 88 2c 01 00 00    	js     801e73 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d47:	83 ec 04             	sub    $0x4,%esp
  801d4a:	68 07 04 00 00       	push   $0x407
  801d4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d52:	6a 00                	push   $0x0
  801d54:	e8 52 f1 ff ff       	call   800eab <sys_page_alloc>
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	89 c2                	mov    %eax,%edx
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	0f 88 0d 01 00 00    	js     801e73 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d66:	83 ec 0c             	sub    $0xc,%esp
  801d69:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d6c:	50                   	push   %eax
  801d6d:	e8 a5 f4 ff ff       	call   801217 <fd_alloc>
  801d72:	89 c3                	mov    %eax,%ebx
  801d74:	83 c4 10             	add    $0x10,%esp
  801d77:	85 c0                	test   %eax,%eax
  801d79:	0f 88 e2 00 00 00    	js     801e61 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d7f:	83 ec 04             	sub    $0x4,%esp
  801d82:	68 07 04 00 00       	push   $0x407
  801d87:	ff 75 f0             	pushl  -0x10(%ebp)
  801d8a:	6a 00                	push   $0x0
  801d8c:	e8 1a f1 ff ff       	call   800eab <sys_page_alloc>
  801d91:	89 c3                	mov    %eax,%ebx
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	85 c0                	test   %eax,%eax
  801d98:	0f 88 c3 00 00 00    	js     801e61 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d9e:	83 ec 0c             	sub    $0xc,%esp
  801da1:	ff 75 f4             	pushl  -0xc(%ebp)
  801da4:	e8 57 f4 ff ff       	call   801200 <fd2data>
  801da9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dab:	83 c4 0c             	add    $0xc,%esp
  801dae:	68 07 04 00 00       	push   $0x407
  801db3:	50                   	push   %eax
  801db4:	6a 00                	push   $0x0
  801db6:	e8 f0 f0 ff ff       	call   800eab <sys_page_alloc>
  801dbb:	89 c3                	mov    %eax,%ebx
  801dbd:	83 c4 10             	add    $0x10,%esp
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	0f 88 89 00 00 00    	js     801e51 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc8:	83 ec 0c             	sub    $0xc,%esp
  801dcb:	ff 75 f0             	pushl  -0x10(%ebp)
  801dce:	e8 2d f4 ff ff       	call   801200 <fd2data>
  801dd3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dda:	50                   	push   %eax
  801ddb:	6a 00                	push   $0x0
  801ddd:	56                   	push   %esi
  801dde:	6a 00                	push   $0x0
  801de0:	e8 09 f1 ff ff       	call   800eee <sys_page_map>
  801de5:	89 c3                	mov    %eax,%ebx
  801de7:	83 c4 20             	add    $0x20,%esp
  801dea:	85 c0                	test   %eax,%eax
  801dec:	78 55                	js     801e43 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dee:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e03:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e0c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e11:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e18:	83 ec 0c             	sub    $0xc,%esp
  801e1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1e:	e8 cd f3 ff ff       	call   8011f0 <fd2num>
  801e23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e26:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e28:	83 c4 04             	add    $0x4,%esp
  801e2b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e2e:	e8 bd f3 ff ff       	call   8011f0 <fd2num>
  801e33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e36:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e39:	83 c4 10             	add    $0x10,%esp
  801e3c:	ba 00 00 00 00       	mov    $0x0,%edx
  801e41:	eb 30                	jmp    801e73 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e43:	83 ec 08             	sub    $0x8,%esp
  801e46:	56                   	push   %esi
  801e47:	6a 00                	push   $0x0
  801e49:	e8 e2 f0 ff ff       	call   800f30 <sys_page_unmap>
  801e4e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e51:	83 ec 08             	sub    $0x8,%esp
  801e54:	ff 75 f0             	pushl  -0x10(%ebp)
  801e57:	6a 00                	push   $0x0
  801e59:	e8 d2 f0 ff ff       	call   800f30 <sys_page_unmap>
  801e5e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e61:	83 ec 08             	sub    $0x8,%esp
  801e64:	ff 75 f4             	pushl  -0xc(%ebp)
  801e67:	6a 00                	push   $0x0
  801e69:	e8 c2 f0 ff ff       	call   800f30 <sys_page_unmap>
  801e6e:	83 c4 10             	add    $0x10,%esp
  801e71:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e73:	89 d0                	mov    %edx,%eax
  801e75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5d                   	pop    %ebp
  801e7b:	c3                   	ret    

00801e7c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e85:	50                   	push   %eax
  801e86:	ff 75 08             	pushl  0x8(%ebp)
  801e89:	e8 d8 f3 ff ff       	call   801266 <fd_lookup>
  801e8e:	83 c4 10             	add    $0x10,%esp
  801e91:	85 c0                	test   %eax,%eax
  801e93:	78 18                	js     801ead <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e95:	83 ec 0c             	sub    $0xc,%esp
  801e98:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9b:	e8 60 f3 ff ff       	call   801200 <fd2data>
	return _pipeisclosed(fd, p);
  801ea0:	89 c2                	mov    %eax,%edx
  801ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea5:	e8 21 fd ff ff       	call   801bcb <_pipeisclosed>
  801eaa:	83 c4 10             	add    $0x10,%esp
}
  801ead:	c9                   	leave  
  801eae:	c3                   	ret    

00801eaf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb7:	5d                   	pop    %ebp
  801eb8:	c3                   	ret    

00801eb9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ebf:	68 f8 28 80 00       	push   $0x8028f8
  801ec4:	ff 75 0c             	pushl  0xc(%ebp)
  801ec7:	e8 65 eb ff ff       	call   800a31 <strcpy>
	return 0;
}
  801ecc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed1:	c9                   	leave  
  801ed2:	c3                   	ret    

00801ed3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ed3:	55                   	push   %ebp
  801ed4:	89 e5                	mov    %esp,%ebp
  801ed6:	57                   	push   %edi
  801ed7:	56                   	push   %esi
  801ed8:	53                   	push   %ebx
  801ed9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801edf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ee4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eea:	eb 2d                	jmp    801f19 <devcons_write+0x46>
		m = n - tot;
  801eec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eef:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ef1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ef4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ef9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801efc:	83 ec 04             	sub    $0x4,%esp
  801eff:	53                   	push   %ebx
  801f00:	03 45 0c             	add    0xc(%ebp),%eax
  801f03:	50                   	push   %eax
  801f04:	57                   	push   %edi
  801f05:	e8 b9 ec ff ff       	call   800bc3 <memmove>
		sys_cputs(buf, m);
  801f0a:	83 c4 08             	add    $0x8,%esp
  801f0d:	53                   	push   %ebx
  801f0e:	57                   	push   %edi
  801f0f:	e8 db ee ff ff       	call   800def <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f14:	01 de                	add    %ebx,%esi
  801f16:	83 c4 10             	add    $0x10,%esp
  801f19:	89 f0                	mov    %esi,%eax
  801f1b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f1e:	72 cc                	jb     801eec <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f23:	5b                   	pop    %ebx
  801f24:	5e                   	pop    %esi
  801f25:	5f                   	pop    %edi
  801f26:	5d                   	pop    %ebp
  801f27:	c3                   	ret    

00801f28 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	83 ec 08             	sub    $0x8,%esp
  801f2e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f33:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f37:	74 2a                	je     801f63 <devcons_read+0x3b>
  801f39:	eb 05                	jmp    801f40 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f3b:	e8 4c ef ff ff       	call   800e8c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f40:	e8 c8 ee ff ff       	call   800e0d <sys_cgetc>
  801f45:	85 c0                	test   %eax,%eax
  801f47:	74 f2                	je     801f3b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f49:	85 c0                	test   %eax,%eax
  801f4b:	78 16                	js     801f63 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f4d:	83 f8 04             	cmp    $0x4,%eax
  801f50:	74 0c                	je     801f5e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f52:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f55:	88 02                	mov    %al,(%edx)
	return 1;
  801f57:	b8 01 00 00 00       	mov    $0x1,%eax
  801f5c:	eb 05                	jmp    801f63 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f5e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f63:	c9                   	leave  
  801f64:	c3                   	ret    

00801f65 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f65:	55                   	push   %ebp
  801f66:	89 e5                	mov    %esp,%ebp
  801f68:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f71:	6a 01                	push   $0x1
  801f73:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f76:	50                   	push   %eax
  801f77:	e8 73 ee ff ff       	call   800def <sys_cputs>
}
  801f7c:	83 c4 10             	add    $0x10,%esp
  801f7f:	c9                   	leave  
  801f80:	c3                   	ret    

00801f81 <getchar>:

int
getchar(void)
{
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f87:	6a 01                	push   $0x1
  801f89:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f8c:	50                   	push   %eax
  801f8d:	6a 00                	push   $0x0
  801f8f:	e8 38 f5 ff ff       	call   8014cc <read>
	if (r < 0)
  801f94:	83 c4 10             	add    $0x10,%esp
  801f97:	85 c0                	test   %eax,%eax
  801f99:	78 0f                	js     801faa <getchar+0x29>
		return r;
	if (r < 1)
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	7e 06                	jle    801fa5 <getchar+0x24>
		return -E_EOF;
	return c;
  801f9f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fa3:	eb 05                	jmp    801faa <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fa5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801faa:	c9                   	leave  
  801fab:	c3                   	ret    

00801fac <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb5:	50                   	push   %eax
  801fb6:	ff 75 08             	pushl  0x8(%ebp)
  801fb9:	e8 a8 f2 ff ff       	call   801266 <fd_lookup>
  801fbe:	83 c4 10             	add    $0x10,%esp
  801fc1:	85 c0                	test   %eax,%eax
  801fc3:	78 11                	js     801fd6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fce:	39 10                	cmp    %edx,(%eax)
  801fd0:	0f 94 c0             	sete   %al
  801fd3:	0f b6 c0             	movzbl %al,%eax
}
  801fd6:	c9                   	leave  
  801fd7:	c3                   	ret    

00801fd8 <opencons>:

int
opencons(void)
{
  801fd8:	55                   	push   %ebp
  801fd9:	89 e5                	mov    %esp,%ebp
  801fdb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fde:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe1:	50                   	push   %eax
  801fe2:	e8 30 f2 ff ff       	call   801217 <fd_alloc>
  801fe7:	83 c4 10             	add    $0x10,%esp
		return r;
  801fea:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fec:	85 c0                	test   %eax,%eax
  801fee:	78 3e                	js     80202e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ff0:	83 ec 04             	sub    $0x4,%esp
  801ff3:	68 07 04 00 00       	push   $0x407
  801ff8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ffb:	6a 00                	push   $0x0
  801ffd:	e8 a9 ee ff ff       	call   800eab <sys_page_alloc>
  802002:	83 c4 10             	add    $0x10,%esp
		return r;
  802005:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802007:	85 c0                	test   %eax,%eax
  802009:	78 23                	js     80202e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80200b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802011:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802014:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802016:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802019:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802020:	83 ec 0c             	sub    $0xc,%esp
  802023:	50                   	push   %eax
  802024:	e8 c7 f1 ff ff       	call   8011f0 <fd2num>
  802029:	89 c2                	mov    %eax,%edx
  80202b:	83 c4 10             	add    $0x10,%esp
}
  80202e:	89 d0                	mov    %edx,%eax
  802030:	c9                   	leave  
  802031:	c3                   	ret    

00802032 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	56                   	push   %esi
  802036:	53                   	push   %ebx
  802037:	8b 75 08             	mov    0x8(%ebp),%esi
  80203a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80203d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  802040:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802042:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802047:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  80204a:	83 ec 0c             	sub    $0xc,%esp
  80204d:	50                   	push   %eax
  80204e:	e8 08 f0 ff ff       	call   80105b <sys_ipc_recv>
  802053:	83 c4 10             	add    $0x10,%esp
  802056:	85 c0                	test   %eax,%eax
  802058:	79 16                	jns    802070 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  80205a:	85 f6                	test   %esi,%esi
  80205c:	74 06                	je     802064 <ipc_recv+0x32>
			*from_env_store = 0;
  80205e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  802064:	85 db                	test   %ebx,%ebx
  802066:	74 2c                	je     802094 <ipc_recv+0x62>
			*perm_store = 0;
  802068:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80206e:	eb 24                	jmp    802094 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  802070:	85 f6                	test   %esi,%esi
  802072:	74 0a                	je     80207e <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  802074:	a1 20 44 80 00       	mov    0x804420,%eax
  802079:	8b 40 74             	mov    0x74(%eax),%eax
  80207c:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80207e:	85 db                	test   %ebx,%ebx
  802080:	74 0a                	je     80208c <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  802082:	a1 20 44 80 00       	mov    0x804420,%eax
  802087:	8b 40 78             	mov    0x78(%eax),%eax
  80208a:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  80208c:	a1 20 44 80 00       	mov    0x804420,%eax
  802091:	8b 40 70             	mov    0x70(%eax),%eax
}
  802094:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802097:	5b                   	pop    %ebx
  802098:	5e                   	pop    %esi
  802099:	5d                   	pop    %ebp
  80209a:	c3                   	ret    

0080209b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80209b:	55                   	push   %ebp
  80209c:	89 e5                	mov    %esp,%ebp
  80209e:	57                   	push   %edi
  80209f:	56                   	push   %esi
  8020a0:	53                   	push   %ebx
  8020a1:	83 ec 0c             	sub    $0xc,%esp
  8020a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020a7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8020ad:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8020af:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020b4:	0f 44 d8             	cmove  %eax,%ebx
  8020b7:	eb 1e                	jmp    8020d7 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  8020b9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020bc:	74 14                	je     8020d2 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  8020be:	83 ec 04             	sub    $0x4,%esp
  8020c1:	68 04 29 80 00       	push   $0x802904
  8020c6:	6a 44                	push   $0x44
  8020c8:	68 30 29 80 00       	push   $0x802930
  8020cd:	e8 52 e2 ff ff       	call   800324 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  8020d2:	e8 b5 ed ff ff       	call   800e8c <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8020d7:	ff 75 14             	pushl  0x14(%ebp)
  8020da:	53                   	push   %ebx
  8020db:	56                   	push   %esi
  8020dc:	57                   	push   %edi
  8020dd:	e8 56 ef ff ff       	call   801038 <sys_ipc_try_send>
  8020e2:	83 c4 10             	add    $0x10,%esp
  8020e5:	85 c0                	test   %eax,%eax
  8020e7:	78 d0                	js     8020b9 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  8020e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ec:	5b                   	pop    %ebx
  8020ed:	5e                   	pop    %esi
  8020ee:	5f                   	pop    %edi
  8020ef:	5d                   	pop    %ebp
  8020f0:	c3                   	ret    

008020f1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020f1:	55                   	push   %ebp
  8020f2:	89 e5                	mov    %esp,%ebp
  8020f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020f7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020fc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020ff:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802105:	8b 52 50             	mov    0x50(%edx),%edx
  802108:	39 ca                	cmp    %ecx,%edx
  80210a:	75 0d                	jne    802119 <ipc_find_env+0x28>
			return envs[i].env_id;
  80210c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80210f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802114:	8b 40 48             	mov    0x48(%eax),%eax
  802117:	eb 0f                	jmp    802128 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802119:	83 c0 01             	add    $0x1,%eax
  80211c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802121:	75 d9                	jne    8020fc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802123:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802128:	5d                   	pop    %ebp
  802129:	c3                   	ret    

0080212a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80212a:	55                   	push   %ebp
  80212b:	89 e5                	mov    %esp,%ebp
  80212d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802130:	89 d0                	mov    %edx,%eax
  802132:	c1 e8 16             	shr    $0x16,%eax
  802135:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80213c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802141:	f6 c1 01             	test   $0x1,%cl
  802144:	74 1d                	je     802163 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802146:	c1 ea 0c             	shr    $0xc,%edx
  802149:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802150:	f6 c2 01             	test   $0x1,%dl
  802153:	74 0e                	je     802163 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802155:	c1 ea 0c             	shr    $0xc,%edx
  802158:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80215f:	ef 
  802160:	0f b7 c0             	movzwl %ax,%eax
}
  802163:	5d                   	pop    %ebp
  802164:	c3                   	ret    
  802165:	66 90                	xchg   %ax,%ax
  802167:	66 90                	xchg   %ax,%ax
  802169:	66 90                	xchg   %ax,%ax
  80216b:	66 90                	xchg   %ax,%ax
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
