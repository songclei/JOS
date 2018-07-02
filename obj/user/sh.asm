
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 84 09 00 00       	call   8009b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int t;

	if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	75 2c                	jne    800072 <_gettoken+0x3f>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  80004b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800052:	0f 8e 3e 01 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("GETTOKEN NULL\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 00 34 80 00       	push   $0x803400
  800060:	e8 89 0a 00 00       	call   800aee <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
		return 0;
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e9 24 01 00 00       	jmp    800196 <_gettoken+0x163>
	}

	if (debug > 1)
  800072:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800079:	7e 11                	jle    80008c <_gettoken+0x59>
		cprintf("GETTOKEN: %s\n", s);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	53                   	push   %ebx
  80007f:	68 0f 34 80 00       	push   $0x80340f
  800084:	e8 65 0a 00 00       	call   800aee <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  80008c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	*p2 = 0;
  800092:	8b 45 10             	mov    0x10(%ebp),%eax
  800095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80009b:	eb 07                	jmp    8000a4 <_gettoken+0x71>
		*s++ = 0;
  80009d:	83 c3 01             	add    $0x1,%ebx
  8000a0:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	0f be 03             	movsbl (%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	68 1d 34 80 00       	push   $0x80341d
  8000b0:	e8 68 12 00 00       	call   80131d <strchr>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	75 e1                	jne    80009d <_gettoken+0x6a>
		*s++ = 0;
	if (*s == 0) {
  8000bc:	0f b6 03             	movzbl (%ebx),%eax
  8000bf:	84 c0                	test   %al,%al
  8000c1:	75 2c                	jne    8000ef <_gettoken+0xbc>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000c8:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000cf:	0f 8e c1 00 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("EOL\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 22 34 80 00       	push   $0x803422
  8000dd:	e8 0c 0a 00 00       	call   800aee <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 33 34 80 00       	push   $0x803433
  8000fb:	e8 1d 12 00 00       	call   80131d <strchr>
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	85 c0                	test   %eax,%eax
  800105:	74 30                	je     800137 <_gettoken+0x104>
		t = *s;
  800107:	0f be 3b             	movsbl (%ebx),%edi
		*p1 = s;
  80010a:	89 1e                	mov    %ebx,(%esi)
		*s++ = 0;
  80010c:	c6 03 00             	movb   $0x0,(%ebx)
		*p2 = s;
  80010f:	83 c3 01             	add    $0x1,%ebx
  800112:	8b 45 10             	mov    0x10(%ebp),%eax
  800115:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  800117:	89 f8                	mov    %edi,%eax
	if (strchr(SYMBOLS, *s)) {
		t = *s;
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
  800119:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800120:	7e 74                	jle    800196 <_gettoken+0x163>
			cprintf("TOK %c\n", t);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	57                   	push   %edi
  800126:	68 27 34 80 00       	push   $0x803427
  80012b:	e8 be 09 00 00       	call   800aee <cprintf>
  800130:	83 c4 10             	add    $0x10,%esp
		return t;
  800133:	89 f8                	mov    %edi,%eax
  800135:	eb 5f                	jmp    800196 <_gettoken+0x163>
	}
	*p1 = s;
  800137:	89 1e                	mov    %ebx,(%esi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800139:	eb 03                	jmp    80013e <_gettoken+0x10b>
		s++;
  80013b:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013e:	0f b6 03             	movzbl (%ebx),%eax
  800141:	84 c0                	test   %al,%al
  800143:	74 18                	je     80015d <_gettoken+0x12a>
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	0f be c0             	movsbl %al,%eax
  80014b:	50                   	push   %eax
  80014c:	68 2f 34 80 00       	push   $0x80342f
  800151:	e8 c7 11 00 00       	call   80131d <strchr>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	74 de                	je     80013b <_gettoken+0x108>
		s++;
	*p2 = s;
  80015d:	8b 45 10             	mov    0x10(%ebp),%eax
  800160:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800162:	b8 77 00 00 00       	mov    $0x77,%eax
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800167:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80016e:	7e 26                	jle    800196 <_gettoken+0x163>
		t = **p2;
  800170:	0f b6 3b             	movzbl (%ebx),%edi
		**p2 = 0;
  800173:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	ff 36                	pushl  (%esi)
  80017b:	68 3b 34 80 00       	push   $0x80343b
  800180:	e8 69 09 00 00       	call   800aee <cprintf>
		**p2 = t;
  800185:	8b 45 10             	mov    0x10(%ebp),%eax
  800188:	8b 00                	mov    (%eax),%eax
  80018a:	89 fa                	mov    %edi,%edx
  80018c:	88 10                	mov    %dl,(%eax)
  80018e:	83 c4 10             	add    $0x10,%esp
	}
	return 'w';
  800191:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <gettoken>:

int
gettoken(char *s, char **p1)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	74 22                	je     8001cd <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001ab:	83 ec 04             	sub    $0x4,%esp
  8001ae:	68 0c 50 80 00       	push   $0x80500c
  8001b3:	68 10 50 80 00       	push   $0x805010
  8001b8:	50                   	push   %eax
  8001b9:	e8 75 fe ff ff       	call   800033 <_gettoken>
  8001be:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cb:	eb 3a                	jmp    800207 <gettoken+0x69>
	}
	c = nc;
  8001cd:	a1 08 50 80 00       	mov    0x805008,%eax
  8001d2:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001da:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001e0:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	68 0c 50 80 00       	push   $0x80500c
  8001ea:	68 10 50 80 00       	push   $0x805010
  8001ef:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001f5:	e8 39 fe ff ff       	call   800033 <_gettoken>
  8001fa:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001ff:	a1 04 50 80 00       	mov    0x805004,%eax
  800204:	83 c4 10             	add    $0x10,%esp
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800215:	6a 00                	push   $0x0
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 7f ff ff ff       	call   80019e <gettoken>
  80021f:	83 c4 10             	add    $0x10,%esp

again:
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800222:	8d 5d a4             	lea    -0x5c(%ebp),%ebx

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800225:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	53                   	push   %ebx
  80022e:	6a 00                	push   $0x0
  800230:	e8 69 ff ff ff       	call   80019e <gettoken>
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	83 f8 3e             	cmp    $0x3e,%eax
  80023b:	0f 84 cc 00 00 00    	je     80030d <runcmd+0x104>
  800241:	83 f8 3e             	cmp    $0x3e,%eax
  800244:	7f 12                	jg     800258 <runcmd+0x4f>
  800246:	85 c0                	test   %eax,%eax
  800248:	0f 84 3b 02 00 00    	je     800489 <runcmd+0x280>
  80024e:	83 f8 3c             	cmp    $0x3c,%eax
  800251:	74 3e                	je     800291 <runcmd+0x88>
  800253:	e9 1f 02 00 00       	jmp    800477 <runcmd+0x26e>
  800258:	83 f8 77             	cmp    $0x77,%eax
  80025b:	74 0e                	je     80026b <runcmd+0x62>
  80025d:	83 f8 7c             	cmp    $0x7c,%eax
  800260:	0f 84 25 01 00 00    	je     80038b <runcmd+0x182>
  800266:	e9 0c 02 00 00       	jmp    800477 <runcmd+0x26e>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026b:	83 fe 10             	cmp    $0x10,%esi
  80026e:	75 15                	jne    800285 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	68 45 34 80 00       	push   $0x803445
  800278:	e8 71 08 00 00       	call   800aee <cprintf>
				exit();
  80027d:	e8 79 07 00 00       	call   8009fb <exit>
  800282:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  800285:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800288:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80028c:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  80028f:	eb 99                	jmp    80022a <runcmd+0x21>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	53                   	push   %ebx
  800295:	6a 00                	push   $0x0
  800297:	e8 02 ff ff ff       	call   80019e <gettoken>
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	83 f8 77             	cmp    $0x77,%eax
  8002a2:	74 15                	je     8002b9 <runcmd+0xb0>
				cprintf("syntax error: < not followed by word\n");
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 90 35 80 00       	push   $0x803590
  8002ac:	e8 3d 08 00 00       	call   800aee <cprintf>
				exit();
  8002b1:	e8 45 07 00 00       	call   8009fb <exit>
  8002b6:	83 c4 10             	add    $0x10,%esp
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			if ((fd = open(t, O_RDONLY)) < 0) {
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	6a 00                	push   $0x0
  8002be:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c1:	e8 c5 21 00 00       	call   80248b <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 1b                	jns    8002ea <runcmd+0xe1>
				cprintf("open %s for read: %e", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 59 34 80 00       	push   $0x803459
  8002db:	e8 0e 08 00 00       	call   800aee <cprintf>
				exit();
  8002e0:	e8 16 07 00 00       	call   8009fb <exit>
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	eb 08                	jmp    8002f2 <runcmd+0xe9>
			}
			if (fd != 0) {
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	0f 84 38 ff ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 0);
  8002f2:	83 ec 08             	sub    $0x8,%esp
  8002f5:	6a 00                	push   $0x0
  8002f7:	57                   	push   %edi
  8002f8:	e8 cf 1b 00 00       	call   801ecc <dup>
				close(fd);
  8002fd:	89 3c 24             	mov    %edi,(%esp)
  800300:	e8 77 1b 00 00       	call   801e7c <close>
  800305:	83 c4 10             	add    $0x10,%esp
  800308:	e9 1d ff ff ff       	jmp    80022a <runcmd+0x21>

			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	53                   	push   %ebx
  800311:	6a 00                	push   $0x0
  800313:	e8 86 fe ff ff       	call   80019e <gettoken>
  800318:	83 c4 10             	add    $0x10,%esp
  80031b:	83 f8 77             	cmp    $0x77,%eax
  80031e:	74 15                	je     800335 <runcmd+0x12c>
				cprintf("syntax error: > not followed by word\n");
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	68 b8 35 80 00       	push   $0x8035b8
  800328:	e8 c1 07 00 00       	call   800aee <cprintf>
				exit();
  80032d:	e8 c9 06 00 00       	call   8009fb <exit>
  800332:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	68 01 03 00 00       	push   $0x301
  80033d:	ff 75 a4             	pushl  -0x5c(%ebp)
  800340:	e8 46 21 00 00       	call   80248b <open>
  800345:	89 c7                	mov    %eax,%edi
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 19                	jns    800367 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	50                   	push   %eax
  800352:	ff 75 a4             	pushl  -0x5c(%ebp)
  800355:	68 6e 34 80 00       	push   $0x80346e
  80035a:	e8 8f 07 00 00       	call   800aee <cprintf>
				exit();
  80035f:	e8 97 06 00 00       	call   8009fb <exit>
  800364:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800367:	83 ff 01             	cmp    $0x1,%edi
  80036a:	0f 84 ba fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	6a 01                	push   $0x1
  800375:	57                   	push   %edi
  800376:	e8 51 1b 00 00       	call   801ecc <dup>
				close(fd);
  80037b:	89 3c 24             	mov    %edi,(%esp)
  80037e:	e8 f9 1a 00 00       	call   801e7c <close>
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	e9 9f fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038b:	83 ec 0c             	sub    $0xc,%esp
  80038e:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	e8 30 2a 00 00       	call   802dca <pipe>
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	85 c0                	test   %eax,%eax
  80039f:	79 16                	jns    8003b7 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	50                   	push   %eax
  8003a5:	68 84 34 80 00       	push   $0x803484
  8003aa:	e8 3f 07 00 00       	call   800aee <cprintf>
				exit();
  8003af:	e8 47 06 00 00       	call   8009fb <exit>
  8003b4:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003be:	74 1c                	je     8003dc <runcmd+0x1d3>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003c0:	83 ec 04             	sub    $0x4,%esp
  8003c3:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003c9:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003cf:	68 8d 34 80 00       	push   $0x80348d
  8003d4:	e8 15 07 00 00       	call   800aee <cprintf>
  8003d9:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003dc:	e8 75 15 00 00       	call   801956 <fork>
  8003e1:	89 c7                	mov    %eax,%edi
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	79 16                	jns    8003fd <runcmd+0x1f4>
				cprintf("fork: %e", r);
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	50                   	push   %eax
  8003eb:	68 ce 39 80 00       	push   $0x8039ce
  8003f0:	e8 f9 06 00 00       	call   800aee <cprintf>
				exit();
  8003f5:	e8 01 06 00 00       	call   8009fb <exit>
  8003fa:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003fd:	85 ff                	test   %edi,%edi
  8003ff:	75 3c                	jne    80043d <runcmd+0x234>
				if (p[0] != 0) {
  800401:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	74 1c                	je     800427 <runcmd+0x21e>
					dup(p[0], 0);
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	6a 00                	push   $0x0
  800410:	50                   	push   %eax
  800411:	e8 b6 1a 00 00       	call   801ecc <dup>
					close(p[0]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041f:	e8 58 1a 00 00       	call   801e7c <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800430:	e8 47 1a 00 00       	call   801e7c <close>
				goto again;
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	e9 e8 fd ff ff       	jmp    800225 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  80043d:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800443:	83 f8 01             	cmp    $0x1,%eax
  800446:	74 1c                	je     800464 <runcmd+0x25b>
					dup(p[1], 1);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	6a 01                	push   $0x1
  80044d:	50                   	push   %eax
  80044e:	e8 79 1a 00 00       	call   801ecc <dup>
					close(p[1]);
  800453:	83 c4 04             	add    $0x4,%esp
  800456:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045c:	e8 1b 1a 00 00       	call   801e7c <close>
  800461:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800464:	83 ec 0c             	sub    $0xc,%esp
  800467:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046d:	e8 0a 1a 00 00       	call   801e7c <close>
				goto runit;
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb 17                	jmp    80048e <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800477:	50                   	push   %eax
  800478:	68 9a 34 80 00       	push   $0x80349a
  80047d:	6a 78                	push   $0x78
  80047f:	68 b6 34 80 00       	push   $0x8034b6
  800484:	e8 8c 05 00 00       	call   800a15 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800489:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  80048e:	85 f6                	test   %esi,%esi
  800490:	75 22                	jne    8004b4 <runcmd+0x2ab>
		if (debug)
  800492:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800499:	0f 84 96 01 00 00    	je     800635 <runcmd+0x42c>
			cprintf("EMPTY COMMAND\n");
  80049f:	83 ec 0c             	sub    $0xc,%esp
  8004a2:	68 c0 34 80 00       	push   $0x8034c0
  8004a7:	e8 42 06 00 00       	call   800aee <cprintf>
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	e9 81 01 00 00       	jmp    800635 <runcmd+0x42c>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004b4:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004b7:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004ba:	74 23                	je     8004df <runcmd+0x2d6>
		argv0buf[0] = '/';
  8004bc:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	50                   	push   %eax
  8004c7:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004cd:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004d3:	50                   	push   %eax
  8004d4:	e8 3c 0d 00 00       	call   801215 <strcpy>
		argv[0] = argv0buf;
  8004d9:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  8004dc:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004df:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004e6:	00 

	// Print the command.
	if (debug) {
  8004e7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004ee:	74 49                	je     800539 <runcmd+0x330>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004f0:	a1 24 54 80 00       	mov    0x805424,%eax
  8004f5:	8b 40 48             	mov    0x48(%eax),%eax
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	50                   	push   %eax
  8004fc:	68 cf 34 80 00       	push   $0x8034cf
  800501:	e8 e8 05 00 00       	call   800aee <cprintf>
  800506:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	eb 11                	jmp    80051f <runcmd+0x316>
			cprintf(" %s", argv[i]);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	50                   	push   %eax
  800512:	68 57 35 80 00       	push   $0x803557
  800517:	e8 d2 05 00 00       	call   800aee <cprintf>
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800522:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800525:	85 c0                	test   %eax,%eax
  800527:	75 e5                	jne    80050e <runcmd+0x305>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  800529:	83 ec 0c             	sub    $0xc,%esp
  80052c:	68 20 34 80 00       	push   $0x803420
  800531:	e8 b8 05 00 00       	call   800aee <cprintf>
  800536:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	ff 75 a8             	pushl  -0x58(%ebp)
  800543:	e8 f7 20 00 00       	call   80263f <spawn>
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	85 c0                	test   %eax,%eax
  80054f:	0f 89 c3 00 00 00    	jns    800618 <runcmd+0x40f>
		cprintf("spawn %s: %e\n", argv[0], r);
  800555:	83 ec 04             	sub    $0x4,%esp
  800558:	50                   	push   %eax
  800559:	ff 75 a8             	pushl  -0x58(%ebp)
  80055c:	68 dd 34 80 00       	push   $0x8034dd
  800561:	e8 88 05 00 00       	call   800aee <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800566:	e8 3c 19 00 00       	call   801ea7 <close_all>
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 4c                	jmp    8005bc <runcmd+0x3b3>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800570:	a1 24 54 80 00       	mov    0x805424,%eax
  800575:	8b 40 48             	mov    0x48(%eax),%eax
  800578:	53                   	push   %ebx
  800579:	ff 75 a8             	pushl  -0x58(%ebp)
  80057c:	50                   	push   %eax
  80057d:	68 eb 34 80 00       	push   $0x8034eb
  800582:	e8 67 05 00 00       	call   800aee <cprintf>
  800587:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80058a:	83 ec 0c             	sub    $0xc,%esp
  80058d:	53                   	push   %ebx
  80058e:	e8 bd 29 00 00       	call   802f50 <wait>
		if (debug)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80059d:	0f 84 8c 00 00 00    	je     80062f <runcmd+0x426>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a3:	a1 24 54 80 00       	mov    0x805424,%eax
  8005a8:	8b 40 48             	mov    0x48(%eax),%eax
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	50                   	push   %eax
  8005af:	68 00 35 80 00       	push   $0x803500
  8005b4:	e8 35 05 00 00       	call   800aee <cprintf>
  8005b9:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005bc:	85 ff                	test   %edi,%edi
  8005be:	74 51                	je     800611 <runcmd+0x408>
		if (debug)
  8005c0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005c7:	74 1a                	je     8005e3 <runcmd+0x3da>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005c9:	a1 24 54 80 00       	mov    0x805424,%eax
  8005ce:	8b 40 48             	mov    0x48(%eax),%eax
  8005d1:	83 ec 04             	sub    $0x4,%esp
  8005d4:	57                   	push   %edi
  8005d5:	50                   	push   %eax
  8005d6:	68 16 35 80 00       	push   $0x803516
  8005db:	e8 0e 05 00 00       	call   800aee <cprintf>
  8005e0:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	57                   	push   %edi
  8005e7:	e8 64 29 00 00       	call   802f50 <wait>
		if (debug)
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f6:	74 19                	je     800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005f8:	a1 24 54 80 00       	mov    0x805424,%eax
  8005fd:	8b 40 48             	mov    0x48(%eax),%eax
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	50                   	push   %eax
  800604:	68 00 35 80 00       	push   $0x803500
  800609:	e8 e0 04 00 00       	call   800aee <cprintf>
  80060e:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800611:	e8 e5 03 00 00       	call   8009fb <exit>
  800616:	eb 1d                	jmp    800635 <runcmd+0x42c>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800618:	e8 8a 18 00 00       	call   801ea7 <close_all>
	if (r >= 0) {
		if (debug)
  80061d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800624:	0f 84 60 ff ff ff    	je     80058a <runcmd+0x381>
  80062a:	e9 41 ff ff ff       	jmp    800570 <runcmd+0x367>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80062f:	85 ff                	test   %edi,%edi
  800631:	75 b0                	jne    8005e3 <runcmd+0x3da>
  800633:	eb dc                	jmp    800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  800635:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800638:	5b                   	pop    %ebx
  800639:	5e                   	pop    %esi
  80063a:	5f                   	pop    %edi
  80063b:	5d                   	pop    %ebp
  80063c:	c3                   	ret    

0080063d <usage>:
}


void
usage(void)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800643:	68 e0 35 80 00       	push   $0x8035e0
  800648:	e8 a1 04 00 00       	call   800aee <cprintf>
	exit();
  80064d:	e8 a9 03 00 00       	call   8009fb <exit>
}
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	c9                   	leave  
  800656:	c3                   	ret    

00800657 <umain>:

void
umain(int argc, char **argv)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	57                   	push   %edi
  80065b:	56                   	push   %esi
  80065c:	53                   	push   %ebx
  80065d:	83 ec 30             	sub    $0x30,%esp
  800660:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800663:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800666:	50                   	push   %eax
  800667:	57                   	push   %edi
  800668:	8d 45 08             	lea    0x8(%ebp),%eax
  80066b:	50                   	push   %eax
  80066c:	e8 17 15 00 00       	call   801b88 <argstart>
	while ((r = argnext(&args)) >= 0)
  800671:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800674:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80067b:	be 3f 00 00 00       	mov    $0x3f,%esi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800680:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800683:	eb 2f                	jmp    8006b4 <umain+0x5d>
		switch (r) {
  800685:	83 f8 69             	cmp    $0x69,%eax
  800688:	74 25                	je     8006af <umain+0x58>
  80068a:	83 f8 78             	cmp    $0x78,%eax
  80068d:	74 07                	je     800696 <umain+0x3f>
  80068f:	83 f8 64             	cmp    $0x64,%eax
  800692:	75 14                	jne    8006a8 <umain+0x51>
  800694:	eb 09                	jmp    80069f <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800696:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  80069d:	eb 15                	jmp    8006b4 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  80069f:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  8006a6:	eb 0c                	jmp    8006b4 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006a8:	e8 90 ff ff ff       	call   80063d <usage>
  8006ad:	eb 05                	jmp    8006b4 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006af:	be 01 00 00 00       	mov    $0x1,%esi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	e8 fb 14 00 00       	call   801bb8 <argnext>
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	85 c0                	test   %eax,%eax
  8006c2:	79 c1                	jns    800685 <umain+0x2e>
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006c4:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006c8:	7e 05                	jle    8006cf <umain+0x78>
		usage();
  8006ca:	e8 6e ff ff ff       	call   80063d <usage>
	if (argc == 2) {
  8006cf:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006d3:	75 56                	jne    80072b <umain+0xd4>
		close(0);
  8006d5:	83 ec 0c             	sub    $0xc,%esp
  8006d8:	6a 00                	push   $0x0
  8006da:	e8 9d 17 00 00       	call   801e7c <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006df:	83 c4 08             	add    $0x8,%esp
  8006e2:	6a 00                	push   $0x0
  8006e4:	ff 77 04             	pushl  0x4(%edi)
  8006e7:	e8 9f 1d 00 00       	call   80248b <open>
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	79 1b                	jns    80070e <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006f3:	83 ec 0c             	sub    $0xc,%esp
  8006f6:	50                   	push   %eax
  8006f7:	ff 77 04             	pushl  0x4(%edi)
  8006fa:	68 33 35 80 00       	push   $0x803533
  8006ff:	68 28 01 00 00       	push   $0x128
  800704:	68 b6 34 80 00       	push   $0x8034b6
  800709:	e8 07 03 00 00       	call   800a15 <_panic>
		assert(r == 0);
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 19                	je     80072b <umain+0xd4>
  800712:	68 3f 35 80 00       	push   $0x80353f
  800717:	68 46 35 80 00       	push   $0x803546
  80071c:	68 29 01 00 00       	push   $0x129
  800721:	68 b6 34 80 00       	push   $0x8034b6
  800726:	e8 ea 02 00 00       	call   800a15 <_panic>
	}
	if (interactive == '?')
  80072b:	83 fe 3f             	cmp    $0x3f,%esi
  80072e:	75 0f                	jne    80073f <umain+0xe8>
		interactive = iscons(0);
  800730:	83 ec 0c             	sub    $0xc,%esp
  800733:	6a 00                	push   $0x0
  800735:	e8 f5 01 00 00       	call   80092f <iscons>
  80073a:	89 c6                	mov    %eax,%esi
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	85 f6                	test   %esi,%esi
  800741:	b8 00 00 00 00       	mov    $0x0,%eax
  800746:	bf 5b 35 80 00       	mov    $0x80355b,%edi
  80074b:	0f 44 f8             	cmove  %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80074e:	83 ec 0c             	sub    $0xc,%esp
  800751:	57                   	push   %edi
  800752:	e8 92 09 00 00       	call   8010e9 <readline>
  800757:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	85 c0                	test   %eax,%eax
  80075e:	75 1e                	jne    80077e <umain+0x127>
			if (debug)
  800760:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800767:	74 10                	je     800779 <umain+0x122>
				cprintf("EXITING\n");
  800769:	83 ec 0c             	sub    $0xc,%esp
  80076c:	68 5e 35 80 00       	push   $0x80355e
  800771:	e8 78 03 00 00       	call   800aee <cprintf>
  800776:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  800779:	e8 7d 02 00 00       	call   8009fb <exit>
		}
		if (debug)
  80077e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800785:	74 11                	je     800798 <umain+0x141>
			cprintf("LINE: %s\n", buf);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	68 67 35 80 00       	push   $0x803567
  800790:	e8 59 03 00 00       	call   800aee <cprintf>
  800795:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  800798:	80 3b 23             	cmpb   $0x23,(%ebx)
  80079b:	74 b1                	je     80074e <umain+0xf7>
			continue;
		if (echocmds)
  80079d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a1:	74 11                	je     8007b4 <umain+0x15d>
			printf("# %s\n", buf);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	68 71 35 80 00       	push   $0x803571
  8007ac:	e8 78 1e 00 00       	call   802629 <printf>
  8007b1:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007bb:	74 10                	je     8007cd <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007bd:	83 ec 0c             	sub    $0xc,%esp
  8007c0:	68 77 35 80 00       	push   $0x803577
  8007c5:	e8 24 03 00 00       	call   800aee <cprintf>
  8007ca:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007cd:	e8 84 11 00 00       	call   801956 <fork>
  8007d2:	89 c6                	mov    %eax,%esi
  8007d4:	85 c0                	test   %eax,%eax
  8007d6:	79 15                	jns    8007ed <umain+0x196>
			panic("fork: %e", r);
  8007d8:	50                   	push   %eax
  8007d9:	68 ce 39 80 00       	push   $0x8039ce
  8007de:	68 40 01 00 00       	push   $0x140
  8007e3:	68 b6 34 80 00       	push   $0x8034b6
  8007e8:	e8 28 02 00 00       	call   800a15 <_panic>
		if (debug)
  8007ed:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f4:	74 11                	je     800807 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	50                   	push   %eax
  8007fa:	68 84 35 80 00       	push   $0x803584
  8007ff:	e8 ea 02 00 00       	call   800aee <cprintf>
  800804:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800807:	85 f6                	test   %esi,%esi
  800809:	75 16                	jne    800821 <umain+0x1ca>
			runcmd(buf);
  80080b:	83 ec 0c             	sub    $0xc,%esp
  80080e:	53                   	push   %ebx
  80080f:	e8 f5 f9 ff ff       	call   800209 <runcmd>
			exit();
  800814:	e8 e2 01 00 00       	call   8009fb <exit>
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	e9 2d ff ff ff       	jmp    80074e <umain+0xf7>
		} else
			wait(r);
  800821:	83 ec 0c             	sub    $0xc,%esp
  800824:	56                   	push   %esi
  800825:	e8 26 27 00 00       	call   802f50 <wait>
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	e9 1c ff ff ff       	jmp    80074e <umain+0xf7>

00800832 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800842:	68 01 36 80 00       	push   $0x803601
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	e8 c6 09 00 00       	call   801215 <strcpy>
	return 0;
}
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
  800854:	c9                   	leave  
  800855:	c3                   	ret    

00800856 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	57                   	push   %edi
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800862:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800867:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80086d:	eb 2d                	jmp    80089c <devcons_write+0x46>
		m = n - tot;
  80086f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800872:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800874:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800877:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80087c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80087f:	83 ec 04             	sub    $0x4,%esp
  800882:	53                   	push   %ebx
  800883:	03 45 0c             	add    0xc(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	57                   	push   %edi
  800888:	e8 1a 0b 00 00       	call   8013a7 <memmove>
		sys_cputs(buf, m);
  80088d:	83 c4 08             	add    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	57                   	push   %edi
  800892:	e8 3c 0d 00 00       	call   8015d3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800897:	01 de                	add    %ebx,%esi
  800899:	83 c4 10             	add    $0x10,%esp
  80089c:	89 f0                	mov    %esi,%eax
  80089e:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008a1:	72 cc                	jb     80086f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8008b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008ba:	74 2a                	je     8008e6 <devcons_read+0x3b>
  8008bc:	eb 05                	jmp    8008c3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008be:	e8 ad 0d 00 00       	call   801670 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c3:	e8 29 0d 00 00       	call   8015f1 <sys_cgetc>
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	74 f2                	je     8008be <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	78 16                	js     8008e6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008d0:	83 f8 04             	cmp    $0x4,%eax
  8008d3:	74 0c                	je     8008e1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d8:	88 02                	mov    %al,(%edx)
	return 1;
  8008da:	b8 01 00 00 00       	mov    $0x1,%eax
  8008df:	eb 05                	jmp    8008e6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008f4:	6a 01                	push   $0x1
  8008f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008f9:	50                   	push   %eax
  8008fa:	e8 d4 0c 00 00       	call   8015d3 <sys_cputs>
}
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <getchar>:

int
getchar(void)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80090a:	6a 01                	push   $0x1
  80090c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80090f:	50                   	push   %eax
  800910:	6a 00                	push   $0x0
  800912:	e8 a1 16 00 00       	call   801fb8 <read>
	if (r < 0)
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	85 c0                	test   %eax,%eax
  80091c:	78 0f                	js     80092d <getchar+0x29>
		return r;
	if (r < 1)
  80091e:	85 c0                	test   %eax,%eax
  800920:	7e 06                	jle    800928 <getchar+0x24>
		return -E_EOF;
	return c;
  800922:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800926:	eb 05                	jmp    80092d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800928:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800935:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800938:	50                   	push   %eax
  800939:	ff 75 08             	pushl  0x8(%ebp)
  80093c:	e8 11 14 00 00       	call   801d52 <fd_lookup>
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	85 c0                	test   %eax,%eax
  800946:	78 11                	js     800959 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800948:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800951:	39 10                	cmp    %edx,(%eax)
  800953:	0f 94 c0             	sete   %al
  800956:	0f b6 c0             	movzbl %al,%eax
}
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <opencons>:

int
opencons(void)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800961:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800964:	50                   	push   %eax
  800965:	e8 99 13 00 00       	call   801d03 <fd_alloc>
  80096a:	83 c4 10             	add    $0x10,%esp
		return r;
  80096d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80096f:	85 c0                	test   %eax,%eax
  800971:	78 3e                	js     8009b1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800973:	83 ec 04             	sub    $0x4,%esp
  800976:	68 07 04 00 00       	push   $0x407
  80097b:	ff 75 f4             	pushl  -0xc(%ebp)
  80097e:	6a 00                	push   $0x0
  800980:	e8 0a 0d 00 00       	call   80168f <sys_page_alloc>
  800985:	83 c4 10             	add    $0x10,%esp
		return r;
  800988:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80098a:	85 c0                	test   %eax,%eax
  80098c:	78 23                	js     8009b1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80098e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800997:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009a3:	83 ec 0c             	sub    $0xc,%esp
  8009a6:	50                   	push   %eax
  8009a7:	e8 30 13 00 00       	call   801cdc <fd2num>
  8009ac:	89 c2                	mov    %eax,%edx
  8009ae:	83 c4 10             	add    $0x10,%esp
}
  8009b1:	89 d0                	mov    %edx,%eax
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8009c0:	e8 8c 0c 00 00       	call   801651 <sys_getenvid>
  8009c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8009cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009d2:	a3 24 54 80 00       	mov    %eax,0x805424
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009d7:	85 db                	test   %ebx,%ebx
  8009d9:	7e 07                	jle    8009e2 <libmain+0x2d>
		binaryname = argv[0];
  8009db:	8b 06                	mov    (%esi),%eax
  8009dd:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009e2:	83 ec 08             	sub    $0x8,%esp
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	e8 6b fc ff ff       	call   800657 <umain>

	// exit gracefully
	exit();
  8009ec:	e8 0a 00 00 00       	call   8009fb <exit>
}
  8009f1:	83 c4 10             	add    $0x10,%esp
  8009f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009f7:	5b                   	pop    %ebx
  8009f8:	5e                   	pop    %esi
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a01:	e8 a1 14 00 00       	call   801ea7 <close_all>
	sys_env_destroy(0);
  800a06:	83 ec 0c             	sub    $0xc,%esp
  800a09:	6a 00                	push   $0x0
  800a0b:	e8 00 0c 00 00       	call   801610 <sys_env_destroy>
}
  800a10:	83 c4 10             	add    $0x10,%esp
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a1a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a1d:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a23:	e8 29 0c 00 00       	call   801651 <sys_getenvid>
  800a28:	83 ec 0c             	sub    $0xc,%esp
  800a2b:	ff 75 0c             	pushl  0xc(%ebp)
  800a2e:	ff 75 08             	pushl  0x8(%ebp)
  800a31:	56                   	push   %esi
  800a32:	50                   	push   %eax
  800a33:	68 18 36 80 00       	push   $0x803618
  800a38:	e8 b1 00 00 00       	call   800aee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a3d:	83 c4 18             	add    $0x18,%esp
  800a40:	53                   	push   %ebx
  800a41:	ff 75 10             	pushl  0x10(%ebp)
  800a44:	e8 54 00 00 00       	call   800a9d <vcprintf>
	cprintf("\n");
  800a49:	c7 04 24 20 34 80 00 	movl   $0x803420,(%esp)
  800a50:	e8 99 00 00 00       	call   800aee <cprintf>
  800a55:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a58:	cc                   	int3   
  800a59:	eb fd                	jmp    800a58 <_panic+0x43>

00800a5b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	83 ec 04             	sub    $0x4,%esp
  800a62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a65:	8b 13                	mov    (%ebx),%edx
  800a67:	8d 42 01             	lea    0x1(%edx),%eax
  800a6a:	89 03                	mov    %eax,(%ebx)
  800a6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a73:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a78:	75 1a                	jne    800a94 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a7a:	83 ec 08             	sub    $0x8,%esp
  800a7d:	68 ff 00 00 00       	push   $0xff
  800a82:	8d 43 08             	lea    0x8(%ebx),%eax
  800a85:	50                   	push   %eax
  800a86:	e8 48 0b 00 00       	call   8015d3 <sys_cputs>
		b->idx = 0;
  800a8b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800a91:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800a94:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800a98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800aa6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800aad:	00 00 00 
	b.cnt = 0;
  800ab0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ab7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800aba:	ff 75 0c             	pushl  0xc(%ebp)
  800abd:	ff 75 08             	pushl  0x8(%ebp)
  800ac0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ac6:	50                   	push   %eax
  800ac7:	68 5b 0a 80 00       	push   $0x800a5b
  800acc:	e8 54 01 00 00       	call   800c25 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800ad1:	83 c4 08             	add    $0x8,%esp
  800ad4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800ada:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800ae0:	50                   	push   %eax
  800ae1:	e8 ed 0a 00 00       	call   8015d3 <sys_cputs>

	return b.cnt;
}
  800ae6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    

00800aee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800af4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800af7:	50                   	push   %eax
  800af8:	ff 75 08             	pushl  0x8(%ebp)
  800afb:	e8 9d ff ff ff       	call   800a9d <vcprintf>
	va_end(ap);

	return cnt;
}
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	83 ec 1c             	sub    $0x1c,%esp
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	89 d6                	mov    %edx,%esi
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b15:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b18:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b23:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b26:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b29:	39 d3                	cmp    %edx,%ebx
  800b2b:	72 05                	jb     800b32 <printnum+0x30>
  800b2d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b30:	77 45                	ja     800b77 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	ff 75 18             	pushl  0x18(%ebp)
  800b38:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b3e:	53                   	push   %ebx
  800b3f:	ff 75 10             	pushl  0x10(%ebp)
  800b42:	83 ec 08             	sub    $0x8,%esp
  800b45:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b48:	ff 75 e0             	pushl  -0x20(%ebp)
  800b4b:	ff 75 dc             	pushl  -0x24(%ebp)
  800b4e:	ff 75 d8             	pushl  -0x28(%ebp)
  800b51:	e8 1a 26 00 00       	call   803170 <__udivdi3>
  800b56:	83 c4 18             	add    $0x18,%esp
  800b59:	52                   	push   %edx
  800b5a:	50                   	push   %eax
  800b5b:	89 f2                	mov    %esi,%edx
  800b5d:	89 f8                	mov    %edi,%eax
  800b5f:	e8 9e ff ff ff       	call   800b02 <printnum>
  800b64:	83 c4 20             	add    $0x20,%esp
  800b67:	eb 18                	jmp    800b81 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b69:	83 ec 08             	sub    $0x8,%esp
  800b6c:	56                   	push   %esi
  800b6d:	ff 75 18             	pushl  0x18(%ebp)
  800b70:	ff d7                	call   *%edi
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	eb 03                	jmp    800b7a <printnum+0x78>
  800b77:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b7a:	83 eb 01             	sub    $0x1,%ebx
  800b7d:	85 db                	test   %ebx,%ebx
  800b7f:	7f e8                	jg     800b69 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b81:	83 ec 08             	sub    $0x8,%esp
  800b84:	56                   	push   %esi
  800b85:	83 ec 04             	sub    $0x4,%esp
  800b88:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b8b:	ff 75 e0             	pushl  -0x20(%ebp)
  800b8e:	ff 75 dc             	pushl  -0x24(%ebp)
  800b91:	ff 75 d8             	pushl  -0x28(%ebp)
  800b94:	e8 07 27 00 00       	call   8032a0 <__umoddi3>
  800b99:	83 c4 14             	add    $0x14,%esp
  800b9c:	0f be 80 3b 36 80 00 	movsbl 0x80363b(%eax),%eax
  800ba3:	50                   	push   %eax
  800ba4:	ff d7                	call   *%edi
}
  800ba6:	83 c4 10             	add    $0x10,%esp
  800ba9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bb4:	83 fa 01             	cmp    $0x1,%edx
  800bb7:	7e 0e                	jle    800bc7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bb9:	8b 10                	mov    (%eax),%edx
  800bbb:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bbe:	89 08                	mov    %ecx,(%eax)
  800bc0:	8b 02                	mov    (%edx),%eax
  800bc2:	8b 52 04             	mov    0x4(%edx),%edx
  800bc5:	eb 22                	jmp    800be9 <getuint+0x38>
	else if (lflag)
  800bc7:	85 d2                	test   %edx,%edx
  800bc9:	74 10                	je     800bdb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bcb:	8b 10                	mov    (%eax),%edx
  800bcd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bd0:	89 08                	mov    %ecx,(%eax)
  800bd2:	8b 02                	mov    (%edx),%eax
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	eb 0e                	jmp    800be9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800bdb:	8b 10                	mov    (%eax),%edx
  800bdd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800be0:	89 08                	mov    %ecx,(%eax)
  800be2:	8b 02                	mov    (%edx),%eax
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800bf1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800bf5:	8b 10                	mov    (%eax),%edx
  800bf7:	3b 50 04             	cmp    0x4(%eax),%edx
  800bfa:	73 0a                	jae    800c06 <sprintputch+0x1b>
		*b->buf++ = ch;
  800bfc:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bff:	89 08                	mov    %ecx,(%eax)
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	88 02                	mov    %al,(%edx)
}
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c0e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c11:	50                   	push   %eax
  800c12:	ff 75 10             	pushl  0x10(%ebp)
  800c15:	ff 75 0c             	pushl  0xc(%ebp)
  800c18:	ff 75 08             	pushl  0x8(%ebp)
  800c1b:	e8 05 00 00 00       	call   800c25 <vprintfmt>
	va_end(ap);
}
  800c20:	83 c4 10             	add    $0x10,%esp
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 2c             	sub    $0x2c,%esp
  800c2e:	8b 75 08             	mov    0x8(%ebp),%esi
  800c31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c34:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c37:	eb 12                	jmp    800c4b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	0f 84 38 04 00 00    	je     801079 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800c41:	83 ec 08             	sub    $0x8,%esp
  800c44:	53                   	push   %ebx
  800c45:	50                   	push   %eax
  800c46:	ff d6                	call   *%esi
  800c48:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c4b:	83 c7 01             	add    $0x1,%edi
  800c4e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c52:	83 f8 25             	cmp    $0x25,%eax
  800c55:	75 e2                	jne    800c39 <vprintfmt+0x14>
  800c57:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c5b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c62:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c69:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c70:	ba 00 00 00 00       	mov    $0x0,%edx
  800c75:	eb 07                	jmp    800c7e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  800c7a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c7e:	8d 47 01             	lea    0x1(%edi),%eax
  800c81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c84:	0f b6 07             	movzbl (%edi),%eax
  800c87:	0f b6 c8             	movzbl %al,%ecx
  800c8a:	83 e8 23             	sub    $0x23,%eax
  800c8d:	3c 55                	cmp    $0x55,%al
  800c8f:	0f 87 c9 03 00 00    	ja     80105e <vprintfmt+0x439>
  800c95:	0f b6 c0             	movzbl %al,%eax
  800c98:	ff 24 85 80 37 80 00 	jmp    *0x803780(,%eax,4)
  800c9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800ca2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800ca6:	eb d6                	jmp    800c7e <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  800ca8:	c7 05 14 50 80 00 00 	movl   $0x0,0x805014
  800caf:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cb2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  800cb5:	eb 94                	jmp    800c4b <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  800cb7:	c7 05 14 50 80 00 01 	movl   $0x1,0x805014
  800cbe:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cc1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  800cc4:	eb 85                	jmp    800c4b <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  800cc6:	c7 05 14 50 80 00 02 	movl   $0x2,0x805014
  800ccd:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cd0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  800cd3:	e9 73 ff ff ff       	jmp    800c4b <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  800cd8:	c7 05 14 50 80 00 03 	movl   $0x3,0x805014
  800cdf:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ce2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  800ce5:	e9 61 ff ff ff       	jmp    800c4b <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  800cea:	c7 05 14 50 80 00 04 	movl   $0x4,0x805014
  800cf1:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cf4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  800cf7:	e9 4f ff ff ff       	jmp    800c4b <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  800cfc:	c7 05 14 50 80 00 05 	movl   $0x5,0x805014
  800d03:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  800d09:	e9 3d ff ff ff       	jmp    800c4b <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  800d0e:	c7 05 14 50 80 00 06 	movl   $0x6,0x805014
  800d15:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  800d1b:	e9 2b ff ff ff       	jmp    800c4b <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  800d20:	c7 05 14 50 80 00 07 	movl   $0x7,0x805014
  800d27:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d2a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  800d2d:	e9 19 ff ff ff       	jmp    800c4b <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800d32:	c7 05 14 50 80 00 08 	movl   $0x8,0x805014
  800d39:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  800d3f:	e9 07 ff ff ff       	jmp    800c4b <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  800d44:	c7 05 14 50 80 00 09 	movl   $0x9,0x805014
  800d4b:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d4e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800d51:	e9 f5 fe ff ff       	jmp    800c4b <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d56:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d59:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800d61:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800d64:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800d68:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800d6b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800d6e:	83 fa 09             	cmp    $0x9,%edx
  800d71:	77 3f                	ja     800db2 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800d73:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800d76:	eb e9                	jmp    800d61 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800d78:	8b 45 14             	mov    0x14(%ebp),%eax
  800d7b:	8d 48 04             	lea    0x4(%eax),%ecx
  800d7e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800d81:	8b 00                	mov    (%eax),%eax
  800d83:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d86:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800d89:	eb 2d                	jmp    800db8 <vprintfmt+0x193>
  800d8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d95:	0f 49 c8             	cmovns %eax,%ecx
  800d98:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d9b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d9e:	e9 db fe ff ff       	jmp    800c7e <vprintfmt+0x59>
  800da3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800da6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800dad:	e9 cc fe ff ff       	jmp    800c7e <vprintfmt+0x59>
  800db2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800db5:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800db8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800dbc:	0f 89 bc fe ff ff    	jns    800c7e <vprintfmt+0x59>
				width = precision, precision = -1;
  800dc2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800dc5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800dc8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800dcf:	e9 aa fe ff ff       	jmp    800c7e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800dd4:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dd7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800dda:	e9 9f fe ff ff       	jmp    800c7e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800ddf:	8b 45 14             	mov    0x14(%ebp),%eax
  800de2:	8d 50 04             	lea    0x4(%eax),%edx
  800de5:	89 55 14             	mov    %edx,0x14(%ebp)
  800de8:	83 ec 08             	sub    $0x8,%esp
  800deb:	53                   	push   %ebx
  800dec:	ff 30                	pushl  (%eax)
  800dee:	ff d6                	call   *%esi
			break;
  800df0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800df3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800df6:	e9 50 fe ff ff       	jmp    800c4b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800dfb:	8b 45 14             	mov    0x14(%ebp),%eax
  800dfe:	8d 50 04             	lea    0x4(%eax),%edx
  800e01:	89 55 14             	mov    %edx,0x14(%ebp)
  800e04:	8b 00                	mov    (%eax),%eax
  800e06:	99                   	cltd   
  800e07:	31 d0                	xor    %edx,%eax
  800e09:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800e0b:	83 f8 0f             	cmp    $0xf,%eax
  800e0e:	7f 0b                	jg     800e1b <vprintfmt+0x1f6>
  800e10:	8b 14 85 e0 38 80 00 	mov    0x8038e0(,%eax,4),%edx
  800e17:	85 d2                	test   %edx,%edx
  800e19:	75 18                	jne    800e33 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  800e1b:	50                   	push   %eax
  800e1c:	68 53 36 80 00       	push   $0x803653
  800e21:	53                   	push   %ebx
  800e22:	56                   	push   %esi
  800e23:	e8 e0 fd ff ff       	call   800c08 <printfmt>
  800e28:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e2b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800e2e:	e9 18 fe ff ff       	jmp    800c4b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800e33:	52                   	push   %edx
  800e34:	68 58 35 80 00       	push   $0x803558
  800e39:	53                   	push   %ebx
  800e3a:	56                   	push   %esi
  800e3b:	e8 c8 fd ff ff       	call   800c08 <printfmt>
  800e40:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e43:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e46:	e9 00 fe ff ff       	jmp    800c4b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800e4b:	8b 45 14             	mov    0x14(%ebp),%eax
  800e4e:	8d 50 04             	lea    0x4(%eax),%edx
  800e51:	89 55 14             	mov    %edx,0x14(%ebp)
  800e54:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800e56:	85 ff                	test   %edi,%edi
  800e58:	b8 4c 36 80 00       	mov    $0x80364c,%eax
  800e5d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800e60:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800e64:	0f 8e 94 00 00 00    	jle    800efe <vprintfmt+0x2d9>
  800e6a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800e6e:	0f 84 98 00 00 00    	je     800f0c <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  800e74:	83 ec 08             	sub    $0x8,%esp
  800e77:	ff 75 d0             	pushl  -0x30(%ebp)
  800e7a:	57                   	push   %edi
  800e7b:	e8 74 03 00 00       	call   8011f4 <strnlen>
  800e80:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800e83:	29 c1                	sub    %eax,%ecx
  800e85:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800e88:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800e8b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800e8f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e92:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800e95:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e97:	eb 0f                	jmp    800ea8 <vprintfmt+0x283>
					putch(padc, putdat);
  800e99:	83 ec 08             	sub    $0x8,%esp
  800e9c:	53                   	push   %ebx
  800e9d:	ff 75 e0             	pushl  -0x20(%ebp)
  800ea0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800ea2:	83 ef 01             	sub    $0x1,%edi
  800ea5:	83 c4 10             	add    $0x10,%esp
  800ea8:	85 ff                	test   %edi,%edi
  800eaa:	7f ed                	jg     800e99 <vprintfmt+0x274>
  800eac:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800eaf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800eb2:	85 c9                	test   %ecx,%ecx
  800eb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb9:	0f 49 c1             	cmovns %ecx,%eax
  800ebc:	29 c1                	sub    %eax,%ecx
  800ebe:	89 75 08             	mov    %esi,0x8(%ebp)
  800ec1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ec4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ec7:	89 cb                	mov    %ecx,%ebx
  800ec9:	eb 4d                	jmp    800f18 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800ecb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ecf:	74 1b                	je     800eec <vprintfmt+0x2c7>
  800ed1:	0f be c0             	movsbl %al,%eax
  800ed4:	83 e8 20             	sub    $0x20,%eax
  800ed7:	83 f8 5e             	cmp    $0x5e,%eax
  800eda:	76 10                	jbe    800eec <vprintfmt+0x2c7>
					putch('?', putdat);
  800edc:	83 ec 08             	sub    $0x8,%esp
  800edf:	ff 75 0c             	pushl  0xc(%ebp)
  800ee2:	6a 3f                	push   $0x3f
  800ee4:	ff 55 08             	call   *0x8(%ebp)
  800ee7:	83 c4 10             	add    $0x10,%esp
  800eea:	eb 0d                	jmp    800ef9 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  800eec:	83 ec 08             	sub    $0x8,%esp
  800eef:	ff 75 0c             	pushl  0xc(%ebp)
  800ef2:	52                   	push   %edx
  800ef3:	ff 55 08             	call   *0x8(%ebp)
  800ef6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ef9:	83 eb 01             	sub    $0x1,%ebx
  800efc:	eb 1a                	jmp    800f18 <vprintfmt+0x2f3>
  800efe:	89 75 08             	mov    %esi,0x8(%ebp)
  800f01:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800f04:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800f07:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800f0a:	eb 0c                	jmp    800f18 <vprintfmt+0x2f3>
  800f0c:	89 75 08             	mov    %esi,0x8(%ebp)
  800f0f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800f12:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800f15:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800f18:	83 c7 01             	add    $0x1,%edi
  800f1b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800f1f:	0f be d0             	movsbl %al,%edx
  800f22:	85 d2                	test   %edx,%edx
  800f24:	74 23                	je     800f49 <vprintfmt+0x324>
  800f26:	85 f6                	test   %esi,%esi
  800f28:	78 a1                	js     800ecb <vprintfmt+0x2a6>
  800f2a:	83 ee 01             	sub    $0x1,%esi
  800f2d:	79 9c                	jns    800ecb <vprintfmt+0x2a6>
  800f2f:	89 df                	mov    %ebx,%edi
  800f31:	8b 75 08             	mov    0x8(%ebp),%esi
  800f34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f37:	eb 18                	jmp    800f51 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800f39:	83 ec 08             	sub    $0x8,%esp
  800f3c:	53                   	push   %ebx
  800f3d:	6a 20                	push   $0x20
  800f3f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800f41:	83 ef 01             	sub    $0x1,%edi
  800f44:	83 c4 10             	add    $0x10,%esp
  800f47:	eb 08                	jmp    800f51 <vprintfmt+0x32c>
  800f49:	89 df                	mov    %ebx,%edi
  800f4b:	8b 75 08             	mov    0x8(%ebp),%esi
  800f4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f51:	85 ff                	test   %edi,%edi
  800f53:	7f e4                	jg     800f39 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f58:	e9 ee fc ff ff       	jmp    800c4b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800f5d:	83 fa 01             	cmp    $0x1,%edx
  800f60:	7e 16                	jle    800f78 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800f62:	8b 45 14             	mov    0x14(%ebp),%eax
  800f65:	8d 50 08             	lea    0x8(%eax),%edx
  800f68:	89 55 14             	mov    %edx,0x14(%ebp)
  800f6b:	8b 50 04             	mov    0x4(%eax),%edx
  800f6e:	8b 00                	mov    (%eax),%eax
  800f70:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f73:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800f76:	eb 32                	jmp    800faa <vprintfmt+0x385>
	else if (lflag)
  800f78:	85 d2                	test   %edx,%edx
  800f7a:	74 18                	je     800f94 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  800f7c:	8b 45 14             	mov    0x14(%ebp),%eax
  800f7f:	8d 50 04             	lea    0x4(%eax),%edx
  800f82:	89 55 14             	mov    %edx,0x14(%ebp)
  800f85:	8b 00                	mov    (%eax),%eax
  800f87:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f8a:	89 c1                	mov    %eax,%ecx
  800f8c:	c1 f9 1f             	sar    $0x1f,%ecx
  800f8f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800f92:	eb 16                	jmp    800faa <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  800f94:	8b 45 14             	mov    0x14(%ebp),%eax
  800f97:	8d 50 04             	lea    0x4(%eax),%edx
  800f9a:	89 55 14             	mov    %edx,0x14(%ebp)
  800f9d:	8b 00                	mov    (%eax),%eax
  800f9f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800fa2:	89 c1                	mov    %eax,%ecx
  800fa4:	c1 f9 1f             	sar    $0x1f,%ecx
  800fa7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800faa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800fad:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800fb0:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800fb5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800fb9:	79 6f                	jns    80102a <vprintfmt+0x405>
				putch('-', putdat);
  800fbb:	83 ec 08             	sub    $0x8,%esp
  800fbe:	53                   	push   %ebx
  800fbf:	6a 2d                	push   $0x2d
  800fc1:	ff d6                	call   *%esi
				num = -(long long) num;
  800fc3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800fc6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800fc9:	f7 d8                	neg    %eax
  800fcb:	83 d2 00             	adc    $0x0,%edx
  800fce:	f7 da                	neg    %edx
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	eb 55                	jmp    80102a <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800fd5:	8d 45 14             	lea    0x14(%ebp),%eax
  800fd8:	e8 d4 fb ff ff       	call   800bb1 <getuint>
			base = 10;
  800fdd:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800fe2:	eb 46                	jmp    80102a <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800fe4:	8d 45 14             	lea    0x14(%ebp),%eax
  800fe7:	e8 c5 fb ff ff       	call   800bb1 <getuint>
			base = 8;
  800fec:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800ff1:	eb 37                	jmp    80102a <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800ff3:	83 ec 08             	sub    $0x8,%esp
  800ff6:	53                   	push   %ebx
  800ff7:	6a 30                	push   $0x30
  800ff9:	ff d6                	call   *%esi
			putch('x', putdat);
  800ffb:	83 c4 08             	add    $0x8,%esp
  800ffe:	53                   	push   %ebx
  800fff:	6a 78                	push   $0x78
  801001:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801003:	8b 45 14             	mov    0x14(%ebp),%eax
  801006:	8d 50 04             	lea    0x4(%eax),%edx
  801009:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80100c:	8b 00                	mov    (%eax),%eax
  80100e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801013:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801016:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80101b:	eb 0d                	jmp    80102a <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80101d:	8d 45 14             	lea    0x14(%ebp),%eax
  801020:	e8 8c fb ff ff       	call   800bb1 <getuint>
			base = 16;
  801025:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80102a:	83 ec 0c             	sub    $0xc,%esp
  80102d:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  801031:	51                   	push   %ecx
  801032:	ff 75 e0             	pushl  -0x20(%ebp)
  801035:	57                   	push   %edi
  801036:	52                   	push   %edx
  801037:	50                   	push   %eax
  801038:	89 da                	mov    %ebx,%edx
  80103a:	89 f0                	mov    %esi,%eax
  80103c:	e8 c1 fa ff ff       	call   800b02 <printnum>
			break;
  801041:	83 c4 20             	add    $0x20,%esp
  801044:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801047:	e9 ff fb ff ff       	jmp    800c4b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80104c:	83 ec 08             	sub    $0x8,%esp
  80104f:	53                   	push   %ebx
  801050:	51                   	push   %ecx
  801051:	ff d6                	call   *%esi
			break;
  801053:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801056:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801059:	e9 ed fb ff ff       	jmp    800c4b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80105e:	83 ec 08             	sub    $0x8,%esp
  801061:	53                   	push   %ebx
  801062:	6a 25                	push   $0x25
  801064:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801066:	83 c4 10             	add    $0x10,%esp
  801069:	eb 03                	jmp    80106e <vprintfmt+0x449>
  80106b:	83 ef 01             	sub    $0x1,%edi
  80106e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801072:	75 f7                	jne    80106b <vprintfmt+0x446>
  801074:	e9 d2 fb ff ff       	jmp    800c4b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801079:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107c:	5b                   	pop    %ebx
  80107d:	5e                   	pop    %esi
  80107e:	5f                   	pop    %edi
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    

00801081 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	83 ec 18             	sub    $0x18,%esp
  801087:	8b 45 08             	mov    0x8(%ebp),%eax
  80108a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80108d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801090:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801094:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801097:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	74 26                	je     8010c8 <vsnprintf+0x47>
  8010a2:	85 d2                	test   %edx,%edx
  8010a4:	7e 22                	jle    8010c8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8010a6:	ff 75 14             	pushl  0x14(%ebp)
  8010a9:	ff 75 10             	pushl  0x10(%ebp)
  8010ac:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8010af:	50                   	push   %eax
  8010b0:	68 eb 0b 80 00       	push   $0x800beb
  8010b5:	e8 6b fb ff ff       	call   800c25 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8010ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8010bd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8010c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c3:	83 c4 10             	add    $0x10,%esp
  8010c6:	eb 05                	jmp    8010cd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8010c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8010cd:	c9                   	leave  
  8010ce:	c3                   	ret    

008010cf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8010d5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8010d8:	50                   	push   %eax
  8010d9:	ff 75 10             	pushl  0x10(%ebp)
  8010dc:	ff 75 0c             	pushl  0xc(%ebp)
  8010df:	ff 75 08             	pushl  0x8(%ebp)
  8010e2:	e8 9a ff ff ff       	call   801081 <vsnprintf>
	va_end(ap);

	return rc;
}
  8010e7:	c9                   	leave  
  8010e8:	c3                   	ret    

008010e9 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	57                   	push   %edi
  8010ed:	56                   	push   %esi
  8010ee:	53                   	push   %ebx
  8010ef:	83 ec 0c             	sub    $0xc,%esp
  8010f2:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	74 13                	je     80110c <readline+0x23>
		fprintf(1, "%s", prompt);
  8010f9:	83 ec 04             	sub    $0x4,%esp
  8010fc:	50                   	push   %eax
  8010fd:	68 58 35 80 00       	push   $0x803558
  801102:	6a 01                	push   $0x1
  801104:	e8 09 15 00 00       	call   802612 <fprintf>
  801109:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  80110c:	83 ec 0c             	sub    $0xc,%esp
  80110f:	6a 00                	push   $0x0
  801111:	e8 19 f8 ff ff       	call   80092f <iscons>
  801116:	89 c7                	mov    %eax,%edi
  801118:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  80111b:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  801120:	e8 df f7 ff ff       	call   800904 <getchar>
  801125:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  801127:	85 c0                	test   %eax,%eax
  801129:	79 29                	jns    801154 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  80112b:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  801130:	83 fb f8             	cmp    $0xfffffff8,%ebx
  801133:	0f 84 9b 00 00 00    	je     8011d4 <readline+0xeb>
				cprintf("read error: %e\n", c);
  801139:	83 ec 08             	sub    $0x8,%esp
  80113c:	53                   	push   %ebx
  80113d:	68 3f 39 80 00       	push   $0x80393f
  801142:	e8 a7 f9 ff ff       	call   800aee <cprintf>
  801147:	83 c4 10             	add    $0x10,%esp
			return NULL;
  80114a:	b8 00 00 00 00       	mov    $0x0,%eax
  80114f:	e9 80 00 00 00       	jmp    8011d4 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  801154:	83 f8 08             	cmp    $0x8,%eax
  801157:	0f 94 c2             	sete   %dl
  80115a:	83 f8 7f             	cmp    $0x7f,%eax
  80115d:	0f 94 c0             	sete   %al
  801160:	08 c2                	or     %al,%dl
  801162:	74 1a                	je     80117e <readline+0x95>
  801164:	85 f6                	test   %esi,%esi
  801166:	7e 16                	jle    80117e <readline+0x95>
			if (echoing)
  801168:	85 ff                	test   %edi,%edi
  80116a:	74 0d                	je     801179 <readline+0x90>
				cputchar('\b');
  80116c:	83 ec 0c             	sub    $0xc,%esp
  80116f:	6a 08                	push   $0x8
  801171:	e8 72 f7 ff ff       	call   8008e8 <cputchar>
  801176:	83 c4 10             	add    $0x10,%esp
			i--;
  801179:	83 ee 01             	sub    $0x1,%esi
  80117c:	eb a2                	jmp    801120 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  80117e:	83 fb 1f             	cmp    $0x1f,%ebx
  801181:	7e 26                	jle    8011a9 <readline+0xc0>
  801183:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  801189:	7f 1e                	jg     8011a9 <readline+0xc0>
			if (echoing)
  80118b:	85 ff                	test   %edi,%edi
  80118d:	74 0c                	je     80119b <readline+0xb2>
				cputchar(c);
  80118f:	83 ec 0c             	sub    $0xc,%esp
  801192:	53                   	push   %ebx
  801193:	e8 50 f7 ff ff       	call   8008e8 <cputchar>
  801198:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  80119b:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  8011a1:	8d 76 01             	lea    0x1(%esi),%esi
  8011a4:	e9 77 ff ff ff       	jmp    801120 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8011a9:	83 fb 0a             	cmp    $0xa,%ebx
  8011ac:	74 09                	je     8011b7 <readline+0xce>
  8011ae:	83 fb 0d             	cmp    $0xd,%ebx
  8011b1:	0f 85 69 ff ff ff    	jne    801120 <readline+0x37>
			if (echoing)
  8011b7:	85 ff                	test   %edi,%edi
  8011b9:	74 0d                	je     8011c8 <readline+0xdf>
				cputchar('\n');
  8011bb:	83 ec 0c             	sub    $0xc,%esp
  8011be:	6a 0a                	push   $0xa
  8011c0:	e8 23 f7 ff ff       	call   8008e8 <cputchar>
  8011c5:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  8011c8:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  8011cf:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  8011d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d7:	5b                   	pop    %ebx
  8011d8:	5e                   	pop    %esi
  8011d9:	5f                   	pop    %edi
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    

008011dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8011e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e7:	eb 03                	jmp    8011ec <strlen+0x10>
		n++;
  8011e9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8011ec:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8011f0:	75 f7                	jne    8011e9 <strlen+0xd>
		n++;
	return n;
}
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    

008011f4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011fa:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801202:	eb 03                	jmp    801207 <strnlen+0x13>
		n++;
  801204:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801207:	39 c2                	cmp    %eax,%edx
  801209:	74 08                	je     801213 <strnlen+0x1f>
  80120b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80120f:	75 f3                	jne    801204 <strnlen+0x10>
  801211:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	53                   	push   %ebx
  801219:	8b 45 08             	mov    0x8(%ebp),%eax
  80121c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80121f:	89 c2                	mov    %eax,%edx
  801221:	83 c2 01             	add    $0x1,%edx
  801224:	83 c1 01             	add    $0x1,%ecx
  801227:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80122b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80122e:	84 db                	test   %bl,%bl
  801230:	75 ef                	jne    801221 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801232:	5b                   	pop    %ebx
  801233:	5d                   	pop    %ebp
  801234:	c3                   	ret    

00801235 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	53                   	push   %ebx
  801239:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80123c:	53                   	push   %ebx
  80123d:	e8 9a ff ff ff       	call   8011dc <strlen>
  801242:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801245:	ff 75 0c             	pushl  0xc(%ebp)
  801248:	01 d8                	add    %ebx,%eax
  80124a:	50                   	push   %eax
  80124b:	e8 c5 ff ff ff       	call   801215 <strcpy>
	return dst;
}
  801250:	89 d8                	mov    %ebx,%eax
  801252:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801255:	c9                   	leave  
  801256:	c3                   	ret    

00801257 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	56                   	push   %esi
  80125b:	53                   	push   %ebx
  80125c:	8b 75 08             	mov    0x8(%ebp),%esi
  80125f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801262:	89 f3                	mov    %esi,%ebx
  801264:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801267:	89 f2                	mov    %esi,%edx
  801269:	eb 0f                	jmp    80127a <strncpy+0x23>
		*dst++ = *src;
  80126b:	83 c2 01             	add    $0x1,%edx
  80126e:	0f b6 01             	movzbl (%ecx),%eax
  801271:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801274:	80 39 01             	cmpb   $0x1,(%ecx)
  801277:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80127a:	39 da                	cmp    %ebx,%edx
  80127c:	75 ed                	jne    80126b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80127e:	89 f0                	mov    %esi,%eax
  801280:	5b                   	pop    %ebx
  801281:	5e                   	pop    %esi
  801282:	5d                   	pop    %ebp
  801283:	c3                   	ret    

00801284 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	56                   	push   %esi
  801288:	53                   	push   %ebx
  801289:	8b 75 08             	mov    0x8(%ebp),%esi
  80128c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128f:	8b 55 10             	mov    0x10(%ebp),%edx
  801292:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801294:	85 d2                	test   %edx,%edx
  801296:	74 21                	je     8012b9 <strlcpy+0x35>
  801298:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80129c:	89 f2                	mov    %esi,%edx
  80129e:	eb 09                	jmp    8012a9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8012a0:	83 c2 01             	add    $0x1,%edx
  8012a3:	83 c1 01             	add    $0x1,%ecx
  8012a6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8012a9:	39 c2                	cmp    %eax,%edx
  8012ab:	74 09                	je     8012b6 <strlcpy+0x32>
  8012ad:	0f b6 19             	movzbl (%ecx),%ebx
  8012b0:	84 db                	test   %bl,%bl
  8012b2:	75 ec                	jne    8012a0 <strlcpy+0x1c>
  8012b4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8012b6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8012b9:	29 f0                	sub    %esi,%eax
}
  8012bb:	5b                   	pop    %ebx
  8012bc:	5e                   	pop    %esi
  8012bd:	5d                   	pop    %ebp
  8012be:	c3                   	ret    

008012bf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8012c8:	eb 06                	jmp    8012d0 <strcmp+0x11>
		p++, q++;
  8012ca:	83 c1 01             	add    $0x1,%ecx
  8012cd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8012d0:	0f b6 01             	movzbl (%ecx),%eax
  8012d3:	84 c0                	test   %al,%al
  8012d5:	74 04                	je     8012db <strcmp+0x1c>
  8012d7:	3a 02                	cmp    (%edx),%al
  8012d9:	74 ef                	je     8012ca <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8012db:	0f b6 c0             	movzbl %al,%eax
  8012de:	0f b6 12             	movzbl (%edx),%edx
  8012e1:	29 d0                	sub    %edx,%eax
}
  8012e3:	5d                   	pop    %ebp
  8012e4:	c3                   	ret    

008012e5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	53                   	push   %ebx
  8012e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ef:	89 c3                	mov    %eax,%ebx
  8012f1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8012f4:	eb 06                	jmp    8012fc <strncmp+0x17>
		n--, p++, q++;
  8012f6:	83 c0 01             	add    $0x1,%eax
  8012f9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8012fc:	39 d8                	cmp    %ebx,%eax
  8012fe:	74 15                	je     801315 <strncmp+0x30>
  801300:	0f b6 08             	movzbl (%eax),%ecx
  801303:	84 c9                	test   %cl,%cl
  801305:	74 04                	je     80130b <strncmp+0x26>
  801307:	3a 0a                	cmp    (%edx),%cl
  801309:	74 eb                	je     8012f6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80130b:	0f b6 00             	movzbl (%eax),%eax
  80130e:	0f b6 12             	movzbl (%edx),%edx
  801311:	29 d0                	sub    %edx,%eax
  801313:	eb 05                	jmp    80131a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801315:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80131a:	5b                   	pop    %ebx
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    

0080131d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	8b 45 08             	mov    0x8(%ebp),%eax
  801323:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801327:	eb 07                	jmp    801330 <strchr+0x13>
		if (*s == c)
  801329:	38 ca                	cmp    %cl,%dl
  80132b:	74 0f                	je     80133c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80132d:	83 c0 01             	add    $0x1,%eax
  801330:	0f b6 10             	movzbl (%eax),%edx
  801333:	84 d2                	test   %dl,%dl
  801335:	75 f2                	jne    801329 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801337:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80133c:	5d                   	pop    %ebp
  80133d:	c3                   	ret    

0080133e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	8b 45 08             	mov    0x8(%ebp),%eax
  801344:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801348:	eb 03                	jmp    80134d <strfind+0xf>
  80134a:	83 c0 01             	add    $0x1,%eax
  80134d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801350:	38 ca                	cmp    %cl,%dl
  801352:	74 04                	je     801358 <strfind+0x1a>
  801354:	84 d2                	test   %dl,%dl
  801356:	75 f2                	jne    80134a <strfind+0xc>
			break;
	return (char *) s;
}
  801358:	5d                   	pop    %ebp
  801359:	c3                   	ret    

0080135a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	57                   	push   %edi
  80135e:	56                   	push   %esi
  80135f:	53                   	push   %ebx
  801360:	8b 7d 08             	mov    0x8(%ebp),%edi
  801363:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801366:	85 c9                	test   %ecx,%ecx
  801368:	74 36                	je     8013a0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80136a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801370:	75 28                	jne    80139a <memset+0x40>
  801372:	f6 c1 03             	test   $0x3,%cl
  801375:	75 23                	jne    80139a <memset+0x40>
		c &= 0xFF;
  801377:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80137b:	89 d3                	mov    %edx,%ebx
  80137d:	c1 e3 08             	shl    $0x8,%ebx
  801380:	89 d6                	mov    %edx,%esi
  801382:	c1 e6 18             	shl    $0x18,%esi
  801385:	89 d0                	mov    %edx,%eax
  801387:	c1 e0 10             	shl    $0x10,%eax
  80138a:	09 f0                	or     %esi,%eax
  80138c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80138e:	89 d8                	mov    %ebx,%eax
  801390:	09 d0                	or     %edx,%eax
  801392:	c1 e9 02             	shr    $0x2,%ecx
  801395:	fc                   	cld    
  801396:	f3 ab                	rep stos %eax,%es:(%edi)
  801398:	eb 06                	jmp    8013a0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80139a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139d:	fc                   	cld    
  80139e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8013a0:	89 f8                	mov    %edi,%eax
  8013a2:	5b                   	pop    %ebx
  8013a3:	5e                   	pop    %esi
  8013a4:	5f                   	pop    %edi
  8013a5:	5d                   	pop    %ebp
  8013a6:	c3                   	ret    

008013a7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	57                   	push   %edi
  8013ab:	56                   	push   %esi
  8013ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8013af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8013b5:	39 c6                	cmp    %eax,%esi
  8013b7:	73 35                	jae    8013ee <memmove+0x47>
  8013b9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8013bc:	39 d0                	cmp    %edx,%eax
  8013be:	73 2e                	jae    8013ee <memmove+0x47>
		s += n;
		d += n;
  8013c0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013c3:	89 d6                	mov    %edx,%esi
  8013c5:	09 fe                	or     %edi,%esi
  8013c7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8013cd:	75 13                	jne    8013e2 <memmove+0x3b>
  8013cf:	f6 c1 03             	test   $0x3,%cl
  8013d2:	75 0e                	jne    8013e2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8013d4:	83 ef 04             	sub    $0x4,%edi
  8013d7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8013da:	c1 e9 02             	shr    $0x2,%ecx
  8013dd:	fd                   	std    
  8013de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013e0:	eb 09                	jmp    8013eb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8013e2:	83 ef 01             	sub    $0x1,%edi
  8013e5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8013e8:	fd                   	std    
  8013e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8013eb:	fc                   	cld    
  8013ec:	eb 1d                	jmp    80140b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013ee:	89 f2                	mov    %esi,%edx
  8013f0:	09 c2                	or     %eax,%edx
  8013f2:	f6 c2 03             	test   $0x3,%dl
  8013f5:	75 0f                	jne    801406 <memmove+0x5f>
  8013f7:	f6 c1 03             	test   $0x3,%cl
  8013fa:	75 0a                	jne    801406 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8013fc:	c1 e9 02             	shr    $0x2,%ecx
  8013ff:	89 c7                	mov    %eax,%edi
  801401:	fc                   	cld    
  801402:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801404:	eb 05                	jmp    80140b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801406:	89 c7                	mov    %eax,%edi
  801408:	fc                   	cld    
  801409:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80140b:	5e                   	pop    %esi
  80140c:	5f                   	pop    %edi
  80140d:	5d                   	pop    %ebp
  80140e:	c3                   	ret    

0080140f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801412:	ff 75 10             	pushl  0x10(%ebp)
  801415:	ff 75 0c             	pushl  0xc(%ebp)
  801418:	ff 75 08             	pushl  0x8(%ebp)
  80141b:	e8 87 ff ff ff       	call   8013a7 <memmove>
}
  801420:	c9                   	leave  
  801421:	c3                   	ret    

00801422 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	56                   	push   %esi
  801426:	53                   	push   %ebx
  801427:	8b 45 08             	mov    0x8(%ebp),%eax
  80142a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80142d:	89 c6                	mov    %eax,%esi
  80142f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801432:	eb 1a                	jmp    80144e <memcmp+0x2c>
		if (*s1 != *s2)
  801434:	0f b6 08             	movzbl (%eax),%ecx
  801437:	0f b6 1a             	movzbl (%edx),%ebx
  80143a:	38 d9                	cmp    %bl,%cl
  80143c:	74 0a                	je     801448 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80143e:	0f b6 c1             	movzbl %cl,%eax
  801441:	0f b6 db             	movzbl %bl,%ebx
  801444:	29 d8                	sub    %ebx,%eax
  801446:	eb 0f                	jmp    801457 <memcmp+0x35>
		s1++, s2++;
  801448:	83 c0 01             	add    $0x1,%eax
  80144b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80144e:	39 f0                	cmp    %esi,%eax
  801450:	75 e2                	jne    801434 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801452:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801457:	5b                   	pop    %ebx
  801458:	5e                   	pop    %esi
  801459:	5d                   	pop    %ebp
  80145a:	c3                   	ret    

0080145b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	53                   	push   %ebx
  80145f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801462:	89 c1                	mov    %eax,%ecx
  801464:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801467:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80146b:	eb 0a                	jmp    801477 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80146d:	0f b6 10             	movzbl (%eax),%edx
  801470:	39 da                	cmp    %ebx,%edx
  801472:	74 07                	je     80147b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801474:	83 c0 01             	add    $0x1,%eax
  801477:	39 c8                	cmp    %ecx,%eax
  801479:	72 f2                	jb     80146d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80147b:	5b                   	pop    %ebx
  80147c:	5d                   	pop    %ebp
  80147d:	c3                   	ret    

0080147e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	57                   	push   %edi
  801482:	56                   	push   %esi
  801483:	53                   	push   %ebx
  801484:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801487:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80148a:	eb 03                	jmp    80148f <strtol+0x11>
		s++;
  80148c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80148f:	0f b6 01             	movzbl (%ecx),%eax
  801492:	3c 20                	cmp    $0x20,%al
  801494:	74 f6                	je     80148c <strtol+0xe>
  801496:	3c 09                	cmp    $0x9,%al
  801498:	74 f2                	je     80148c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80149a:	3c 2b                	cmp    $0x2b,%al
  80149c:	75 0a                	jne    8014a8 <strtol+0x2a>
		s++;
  80149e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8014a1:	bf 00 00 00 00       	mov    $0x0,%edi
  8014a6:	eb 11                	jmp    8014b9 <strtol+0x3b>
  8014a8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8014ad:	3c 2d                	cmp    $0x2d,%al
  8014af:	75 08                	jne    8014b9 <strtol+0x3b>
		s++, neg = 1;
  8014b1:	83 c1 01             	add    $0x1,%ecx
  8014b4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8014b9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8014bf:	75 15                	jne    8014d6 <strtol+0x58>
  8014c1:	80 39 30             	cmpb   $0x30,(%ecx)
  8014c4:	75 10                	jne    8014d6 <strtol+0x58>
  8014c6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8014ca:	75 7c                	jne    801548 <strtol+0xca>
		s += 2, base = 16;
  8014cc:	83 c1 02             	add    $0x2,%ecx
  8014cf:	bb 10 00 00 00       	mov    $0x10,%ebx
  8014d4:	eb 16                	jmp    8014ec <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8014d6:	85 db                	test   %ebx,%ebx
  8014d8:	75 12                	jne    8014ec <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8014da:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014df:	80 39 30             	cmpb   $0x30,(%ecx)
  8014e2:	75 08                	jne    8014ec <strtol+0x6e>
		s++, base = 8;
  8014e4:	83 c1 01             	add    $0x1,%ecx
  8014e7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8014ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8014f4:	0f b6 11             	movzbl (%ecx),%edx
  8014f7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8014fa:	89 f3                	mov    %esi,%ebx
  8014fc:	80 fb 09             	cmp    $0x9,%bl
  8014ff:	77 08                	ja     801509 <strtol+0x8b>
			dig = *s - '0';
  801501:	0f be d2             	movsbl %dl,%edx
  801504:	83 ea 30             	sub    $0x30,%edx
  801507:	eb 22                	jmp    80152b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801509:	8d 72 9f             	lea    -0x61(%edx),%esi
  80150c:	89 f3                	mov    %esi,%ebx
  80150e:	80 fb 19             	cmp    $0x19,%bl
  801511:	77 08                	ja     80151b <strtol+0x9d>
			dig = *s - 'a' + 10;
  801513:	0f be d2             	movsbl %dl,%edx
  801516:	83 ea 57             	sub    $0x57,%edx
  801519:	eb 10                	jmp    80152b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80151b:	8d 72 bf             	lea    -0x41(%edx),%esi
  80151e:	89 f3                	mov    %esi,%ebx
  801520:	80 fb 19             	cmp    $0x19,%bl
  801523:	77 16                	ja     80153b <strtol+0xbd>
			dig = *s - 'A' + 10;
  801525:	0f be d2             	movsbl %dl,%edx
  801528:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80152b:	3b 55 10             	cmp    0x10(%ebp),%edx
  80152e:	7d 0b                	jge    80153b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801530:	83 c1 01             	add    $0x1,%ecx
  801533:	0f af 45 10          	imul   0x10(%ebp),%eax
  801537:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801539:	eb b9                	jmp    8014f4 <strtol+0x76>

	if (endptr)
  80153b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80153f:	74 0d                	je     80154e <strtol+0xd0>
		*endptr = (char *) s;
  801541:	8b 75 0c             	mov    0xc(%ebp),%esi
  801544:	89 0e                	mov    %ecx,(%esi)
  801546:	eb 06                	jmp    80154e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801548:	85 db                	test   %ebx,%ebx
  80154a:	74 98                	je     8014e4 <strtol+0x66>
  80154c:	eb 9e                	jmp    8014ec <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80154e:	89 c2                	mov    %eax,%edx
  801550:	f7 da                	neg    %edx
  801552:	85 ff                	test   %edi,%edi
  801554:	0f 45 c2             	cmovne %edx,%eax
}
  801557:	5b                   	pop    %ebx
  801558:	5e                   	pop    %esi
  801559:	5f                   	pop    %edi
  80155a:	5d                   	pop    %ebp
  80155b:	c3                   	ret    

0080155c <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	57                   	push   %edi
  801560:	56                   	push   %esi
  801561:	53                   	push   %ebx
  801562:	83 ec 04             	sub    $0x4,%esp
  801565:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  801568:	57                   	push   %edi
  801569:	e8 6e fc ff ff       	call   8011dc <strlen>
  80156e:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801571:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  801574:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  801579:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  80157e:	eb 46                	jmp    8015c6 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  801580:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  801584:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801587:	80 f9 09             	cmp    $0x9,%cl
  80158a:	77 08                	ja     801594 <charhex_to_dec+0x38>
			num = s[i] - '0';
  80158c:	0f be d2             	movsbl %dl,%edx
  80158f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801592:	eb 27                	jmp    8015bb <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  801594:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  801597:	80 f9 05             	cmp    $0x5,%cl
  80159a:	77 08                	ja     8015a4 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  80159c:	0f be d2             	movsbl %dl,%edx
  80159f:	8d 4a a9             	lea    -0x57(%edx),%ecx
  8015a2:	eb 17                	jmp    8015bb <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  8015a4:	8d 4a bf             	lea    -0x41(%edx),%ecx
  8015a7:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  8015aa:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  8015af:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  8015b3:	77 06                	ja     8015bb <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  8015b5:	0f be d2             	movsbl %dl,%edx
  8015b8:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  8015bb:	0f af ce             	imul   %esi,%ecx
  8015be:	01 c8                	add    %ecx,%eax
		base *= 16;
  8015c0:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  8015c3:	83 eb 01             	sub    $0x1,%ebx
  8015c6:	83 fb 01             	cmp    $0x1,%ebx
  8015c9:	7f b5                	jg     801580 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  8015cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ce:	5b                   	pop    %ebx
  8015cf:	5e                   	pop    %esi
  8015d0:	5f                   	pop    %edi
  8015d1:	5d                   	pop    %ebp
  8015d2:	c3                   	ret    

008015d3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	57                   	push   %edi
  8015d7:	56                   	push   %esi
  8015d8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8015de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8015e4:	89 c3                	mov    %eax,%ebx
  8015e6:	89 c7                	mov    %eax,%edi
  8015e8:	89 c6                	mov    %eax,%esi
  8015ea:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8015ec:	5b                   	pop    %ebx
  8015ed:	5e                   	pop    %esi
  8015ee:	5f                   	pop    %edi
  8015ef:	5d                   	pop    %ebp
  8015f0:	c3                   	ret    

008015f1 <sys_cgetc>:

int
sys_cgetc(void)
{
  8015f1:	55                   	push   %ebp
  8015f2:	89 e5                	mov    %esp,%ebp
  8015f4:	57                   	push   %edi
  8015f5:	56                   	push   %esi
  8015f6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015fc:	b8 01 00 00 00       	mov    $0x1,%eax
  801601:	89 d1                	mov    %edx,%ecx
  801603:	89 d3                	mov    %edx,%ebx
  801605:	89 d7                	mov    %edx,%edi
  801607:	89 d6                	mov    %edx,%esi
  801609:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80160b:	5b                   	pop    %ebx
  80160c:	5e                   	pop    %esi
  80160d:	5f                   	pop    %edi
  80160e:	5d                   	pop    %ebp
  80160f:	c3                   	ret    

00801610 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	57                   	push   %edi
  801614:	56                   	push   %esi
  801615:	53                   	push   %ebx
  801616:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801619:	b9 00 00 00 00       	mov    $0x0,%ecx
  80161e:	b8 03 00 00 00       	mov    $0x3,%eax
  801623:	8b 55 08             	mov    0x8(%ebp),%edx
  801626:	89 cb                	mov    %ecx,%ebx
  801628:	89 cf                	mov    %ecx,%edi
  80162a:	89 ce                	mov    %ecx,%esi
  80162c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80162e:	85 c0                	test   %eax,%eax
  801630:	7e 17                	jle    801649 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801632:	83 ec 0c             	sub    $0xc,%esp
  801635:	50                   	push   %eax
  801636:	6a 03                	push   $0x3
  801638:	68 4f 39 80 00       	push   $0x80394f
  80163d:	6a 23                	push   $0x23
  80163f:	68 6c 39 80 00       	push   $0x80396c
  801644:	e8 cc f3 ff ff       	call   800a15 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801649:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164c:	5b                   	pop    %ebx
  80164d:	5e                   	pop    %esi
  80164e:	5f                   	pop    %edi
  80164f:	5d                   	pop    %ebp
  801650:	c3                   	ret    

00801651 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	57                   	push   %edi
  801655:	56                   	push   %esi
  801656:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801657:	ba 00 00 00 00       	mov    $0x0,%edx
  80165c:	b8 02 00 00 00       	mov    $0x2,%eax
  801661:	89 d1                	mov    %edx,%ecx
  801663:	89 d3                	mov    %edx,%ebx
  801665:	89 d7                	mov    %edx,%edi
  801667:	89 d6                	mov    %edx,%esi
  801669:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80166b:	5b                   	pop    %ebx
  80166c:	5e                   	pop    %esi
  80166d:	5f                   	pop    %edi
  80166e:	5d                   	pop    %ebp
  80166f:	c3                   	ret    

00801670 <sys_yield>:

void
sys_yield(void)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	57                   	push   %edi
  801674:	56                   	push   %esi
  801675:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801676:	ba 00 00 00 00       	mov    $0x0,%edx
  80167b:	b8 0b 00 00 00       	mov    $0xb,%eax
  801680:	89 d1                	mov    %edx,%ecx
  801682:	89 d3                	mov    %edx,%ebx
  801684:	89 d7                	mov    %edx,%edi
  801686:	89 d6                	mov    %edx,%esi
  801688:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80168a:	5b                   	pop    %ebx
  80168b:	5e                   	pop    %esi
  80168c:	5f                   	pop    %edi
  80168d:	5d                   	pop    %ebp
  80168e:	c3                   	ret    

0080168f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	57                   	push   %edi
  801693:	56                   	push   %esi
  801694:	53                   	push   %ebx
  801695:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801698:	be 00 00 00 00       	mov    $0x0,%esi
  80169d:	b8 04 00 00 00       	mov    $0x4,%eax
  8016a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8016a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016ab:	89 f7                	mov    %esi,%edi
  8016ad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	7e 17                	jle    8016ca <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016b3:	83 ec 0c             	sub    $0xc,%esp
  8016b6:	50                   	push   %eax
  8016b7:	6a 04                	push   $0x4
  8016b9:	68 4f 39 80 00       	push   $0x80394f
  8016be:	6a 23                	push   $0x23
  8016c0:	68 6c 39 80 00       	push   $0x80396c
  8016c5:	e8 4b f3 ff ff       	call   800a15 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8016ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cd:	5b                   	pop    %ebx
  8016ce:	5e                   	pop    %esi
  8016cf:	5f                   	pop    %edi
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    

008016d2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	57                   	push   %edi
  8016d6:	56                   	push   %esi
  8016d7:	53                   	push   %ebx
  8016d8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016db:	b8 05 00 00 00       	mov    $0x5,%eax
  8016e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8016e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016e9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8016ec:	8b 75 18             	mov    0x18(%ebp),%esi
  8016ef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	7e 17                	jle    80170c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016f5:	83 ec 0c             	sub    $0xc,%esp
  8016f8:	50                   	push   %eax
  8016f9:	6a 05                	push   $0x5
  8016fb:	68 4f 39 80 00       	push   $0x80394f
  801700:	6a 23                	push   $0x23
  801702:	68 6c 39 80 00       	push   $0x80396c
  801707:	e8 09 f3 ff ff       	call   800a15 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80170c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170f:	5b                   	pop    %ebx
  801710:	5e                   	pop    %esi
  801711:	5f                   	pop    %edi
  801712:	5d                   	pop    %ebp
  801713:	c3                   	ret    

00801714 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	57                   	push   %edi
  801718:	56                   	push   %esi
  801719:	53                   	push   %ebx
  80171a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80171d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801722:	b8 06 00 00 00       	mov    $0x6,%eax
  801727:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172a:	8b 55 08             	mov    0x8(%ebp),%edx
  80172d:	89 df                	mov    %ebx,%edi
  80172f:	89 de                	mov    %ebx,%esi
  801731:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801733:	85 c0                	test   %eax,%eax
  801735:	7e 17                	jle    80174e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801737:	83 ec 0c             	sub    $0xc,%esp
  80173a:	50                   	push   %eax
  80173b:	6a 06                	push   $0x6
  80173d:	68 4f 39 80 00       	push   $0x80394f
  801742:	6a 23                	push   $0x23
  801744:	68 6c 39 80 00       	push   $0x80396c
  801749:	e8 c7 f2 ff ff       	call   800a15 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80174e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801751:	5b                   	pop    %ebx
  801752:	5e                   	pop    %esi
  801753:	5f                   	pop    %edi
  801754:	5d                   	pop    %ebp
  801755:	c3                   	ret    

00801756 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	57                   	push   %edi
  80175a:	56                   	push   %esi
  80175b:	53                   	push   %ebx
  80175c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80175f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801764:	b8 08 00 00 00       	mov    $0x8,%eax
  801769:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80176c:	8b 55 08             	mov    0x8(%ebp),%edx
  80176f:	89 df                	mov    %ebx,%edi
  801771:	89 de                	mov    %ebx,%esi
  801773:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801775:	85 c0                	test   %eax,%eax
  801777:	7e 17                	jle    801790 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801779:	83 ec 0c             	sub    $0xc,%esp
  80177c:	50                   	push   %eax
  80177d:	6a 08                	push   $0x8
  80177f:	68 4f 39 80 00       	push   $0x80394f
  801784:	6a 23                	push   $0x23
  801786:	68 6c 39 80 00       	push   $0x80396c
  80178b:	e8 85 f2 ff ff       	call   800a15 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801790:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801793:	5b                   	pop    %ebx
  801794:	5e                   	pop    %esi
  801795:	5f                   	pop    %edi
  801796:	5d                   	pop    %ebp
  801797:	c3                   	ret    

00801798 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	57                   	push   %edi
  80179c:	56                   	push   %esi
  80179d:	53                   	push   %ebx
  80179e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8017ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b1:	89 df                	mov    %ebx,%edi
  8017b3:	89 de                	mov    %ebx,%esi
  8017b5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	7e 17                	jle    8017d2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017bb:	83 ec 0c             	sub    $0xc,%esp
  8017be:	50                   	push   %eax
  8017bf:	6a 0a                	push   $0xa
  8017c1:	68 4f 39 80 00       	push   $0x80394f
  8017c6:	6a 23                	push   $0x23
  8017c8:	68 6c 39 80 00       	push   $0x80396c
  8017cd:	e8 43 f2 ff ff       	call   800a15 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8017d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d5:	5b                   	pop    %ebx
  8017d6:	5e                   	pop    %esi
  8017d7:	5f                   	pop    %edi
  8017d8:	5d                   	pop    %ebp
  8017d9:	c3                   	ret    

008017da <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	57                   	push   %edi
  8017de:	56                   	push   %esi
  8017df:	53                   	push   %ebx
  8017e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017e8:	b8 09 00 00 00       	mov    $0x9,%eax
  8017ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8017f3:	89 df                	mov    %ebx,%edi
  8017f5:	89 de                	mov    %ebx,%esi
  8017f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	7e 17                	jle    801814 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017fd:	83 ec 0c             	sub    $0xc,%esp
  801800:	50                   	push   %eax
  801801:	6a 09                	push   $0x9
  801803:	68 4f 39 80 00       	push   $0x80394f
  801808:	6a 23                	push   $0x23
  80180a:	68 6c 39 80 00       	push   $0x80396c
  80180f:	e8 01 f2 ff ff       	call   800a15 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801814:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801817:	5b                   	pop    %ebx
  801818:	5e                   	pop    %esi
  801819:	5f                   	pop    %edi
  80181a:	5d                   	pop    %ebp
  80181b:	c3                   	ret    

0080181c <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	57                   	push   %edi
  801820:	56                   	push   %esi
  801821:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801822:	be 00 00 00 00       	mov    $0x0,%esi
  801827:	b8 0c 00 00 00       	mov    $0xc,%eax
  80182c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80182f:	8b 55 08             	mov    0x8(%ebp),%edx
  801832:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801835:	8b 7d 14             	mov    0x14(%ebp),%edi
  801838:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80183a:	5b                   	pop    %ebx
  80183b:	5e                   	pop    %esi
  80183c:	5f                   	pop    %edi
  80183d:	5d                   	pop    %ebp
  80183e:	c3                   	ret    

0080183f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	57                   	push   %edi
  801843:	56                   	push   %esi
  801844:	53                   	push   %ebx
  801845:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801848:	b9 00 00 00 00       	mov    $0x0,%ecx
  80184d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801852:	8b 55 08             	mov    0x8(%ebp),%edx
  801855:	89 cb                	mov    %ecx,%ebx
  801857:	89 cf                	mov    %ecx,%edi
  801859:	89 ce                	mov    %ecx,%esi
  80185b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80185d:	85 c0                	test   %eax,%eax
  80185f:	7e 17                	jle    801878 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801861:	83 ec 0c             	sub    $0xc,%esp
  801864:	50                   	push   %eax
  801865:	6a 0d                	push   $0xd
  801867:	68 4f 39 80 00       	push   $0x80394f
  80186c:	6a 23                	push   $0x23
  80186e:	68 6c 39 80 00       	push   $0x80396c
  801873:	e8 9d f1 ff ff       	call   800a15 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801878:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80187b:	5b                   	pop    %ebx
  80187c:	5e                   	pop    %esi
  80187d:	5f                   	pop    %edi
  80187e:	5d                   	pop    %ebp
  80187f:	c3                   	ret    

00801880 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	53                   	push   %ebx
  801884:	83 ec 04             	sub    $0x4,%esp
  801887:	8b 45 08             	mov    0x8(%ebp),%eax

	
	void *addr = (void *) utf->utf_fault_va;
  80188a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  80188c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801890:	74 11                	je     8018a3 <pgfault+0x23>
  801892:	89 d8                	mov    %ebx,%eax
  801894:	c1 e8 0c             	shr    $0xc,%eax
  801897:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80189e:	f6 c4 08             	test   $0x8,%ah
  8018a1:	75 14                	jne    8018b7 <pgfault+0x37>
		panic("page fault");
  8018a3:	83 ec 04             	sub    $0x4,%esp
  8018a6:	68 7a 39 80 00       	push   $0x80397a
  8018ab:	6a 5b                	push   $0x5b
  8018ad:	68 85 39 80 00       	push   $0x803985
  8018b2:	e8 5e f1 ff ff       	call   800a15 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// allocate a new page and map it at a temporary location
	if((r = sys_page_alloc(0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  8018b7:	83 ec 04             	sub    $0x4,%esp
  8018ba:	6a 07                	push   $0x7
  8018bc:	68 00 f0 7f 00       	push   $0x7ff000
  8018c1:	6a 00                	push   $0x0
  8018c3:	e8 c7 fd ff ff       	call   80168f <sys_page_alloc>
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	79 12                	jns    8018e1 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  8018cf:	50                   	push   %eax
  8018d0:	68 90 39 80 00       	push   $0x803990
  8018d5:	6a 66                	push   $0x66
  8018d7:	68 85 39 80 00       	push   $0x803985
  8018dc:	e8 34 f1 ff ff       	call   800a15 <_panic>

	// copy date to new page
	//strncpy((char *)PFTEMP, (char *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
	memcpy((void *)PFTEMP, (void *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);
  8018e1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8018e7:	83 ec 04             	sub    $0x4,%esp
  8018ea:	68 00 10 00 00       	push   $0x1000
  8018ef:	53                   	push   %ebx
  8018f0:	68 00 f0 7f 00       	push   $0x7ff000
  8018f5:	e8 15 fb ff ff       	call   80140f <memcpy>

	// move the new page to the old page's address
	if((r = sys_page_map(0, (void *)PFTEMP, 0, (void *)
  8018fa:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801901:	53                   	push   %ebx
  801902:	6a 00                	push   $0x0
  801904:	68 00 f0 7f 00       	push   $0x7ff000
  801909:	6a 00                	push   $0x0
  80190b:	e8 c2 fd ff ff       	call   8016d2 <sys_page_map>
  801910:	83 c4 20             	add    $0x20,%esp
  801913:	85 c0                	test   %eax,%eax
  801915:	79 12                	jns    801929 <pgfault+0xa9>
		(ROUNDDOWN(addr, PGSIZE)), PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_map: %e", r);
  801917:	50                   	push   %eax
  801918:	68 a3 39 80 00       	push   $0x8039a3
  80191d:	6a 6f                	push   $0x6f
  80191f:	68 85 39 80 00       	push   $0x803985
  801924:	e8 ec f0 ff ff       	call   800a15 <_panic>

	// unmap page on PFTEMP
	if((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  801929:	83 ec 08             	sub    $0x8,%esp
  80192c:	68 00 f0 7f 00       	push   $0x7ff000
  801931:	6a 00                	push   $0x0
  801933:	e8 dc fd ff ff       	call   801714 <sys_page_unmap>
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	85 c0                	test   %eax,%eax
  80193d:	79 12                	jns    801951 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  80193f:	50                   	push   %eax
  801940:	68 b4 39 80 00       	push   $0x8039b4
  801945:	6a 73                	push   $0x73
  801947:	68 85 39 80 00       	push   $0x803985
  80194c:	e8 c4 f0 ff ff       	call   800a15 <_panic>


}
  801951:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801954:	c9                   	leave  
  801955:	c3                   	ret    

00801956 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	57                   	push   %edi
  80195a:	56                   	push   %esi
  80195b:	53                   	push   %ebx
  80195c:	83 ec 28             	sub    $0x28,%esp

	#ifdef CHALLENGE 
	set_exception_handler(pgfault, T_PGFLT);
	#else
	// set up page fault handler
	set_pgfault_handler(pgfault);
  80195f:	68 80 18 80 00       	push   $0x801880
  801964:	e8 36 16 00 00       	call   802f9f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801969:	b8 07 00 00 00       	mov    $0x7,%eax
  80196e:	cd 30                	int    $0x30
  801970:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801973:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	#endif

	// create a child
	envid = sys_exofork();
	if (envid < 0)
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	85 c0                	test   %eax,%eax
  80197b:	79 15                	jns    801992 <fork+0x3c>
		panic("sys_exofork: %e", envid);
  80197d:	50                   	push   %eax
  80197e:	68 c7 39 80 00       	push   $0x8039c7
  801983:	68 d0 00 00 00       	push   $0xd0
  801988:	68 85 39 80 00       	push   $0x803985
  80198d:	e8 83 f0 ff ff       	call   800a15 <_panic>
  801992:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801997:	be 00 08 00 00       	mov    $0x800,%esi
	// we are the child
	if(envid == 0) {
  80199c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8019a0:	75 21                	jne    8019c3 <fork+0x6d>
		// the copied valude of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8019a2:	e8 aa fc ff ff       	call   801651 <sys_getenvid>
  8019a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8019ac:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8019af:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8019b4:	a3 24 54 80 00       	mov    %eax,0x805424
		/*// alloc exception stack
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
			PTE_P | PTE_U | PTE_W)) < 0)
			panic("sys_page_alloc: %e", r);*/

		return 0;
  8019b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019be:	e9 a3 01 00 00       	jmp    801b66 <fork+0x210>
{
	int r;

	// LAB 4: Your code here.
	
	if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P))
  8019c3:	89 d8                	mov    %ebx,%eax
  8019c5:	c1 e8 16             	shr    $0x16,%eax
  8019c8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019cf:	a8 01                	test   $0x1,%al
  8019d1:	0f 84 f0 00 00 00    	je     801ac7 <fork+0x171>
		return 0;

	// virtual page pn's page table entry
	pte_t pe = uvpt[pn];
  8019d7:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi


	if((pe & PTE_P) && (pe & PTE_U)) {
  8019de:	89 f8                	mov    %edi,%eax
  8019e0:	83 e0 05             	and    $0x5,%eax
  8019e3:	83 f8 05             	cmp    $0x5,%eax
  8019e6:	0f 85 db 00 00 00    	jne    801ac7 <fork+0x171>
		// share with the child environment 
		if(pe & PTE_SHARE) {
  8019ec:	f7 c7 00 04 00 00    	test   $0x400,%edi
  8019f2:	74 36                	je     801a2a <fork+0xd4>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  8019f4:	83 ec 0c             	sub    $0xc,%esp
  8019f7:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  8019fd:	57                   	push   %edi
  8019fe:	53                   	push   %ebx
  8019ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a02:	53                   	push   %ebx
  801a03:	6a 00                	push   $0x0
  801a05:	e8 c8 fc ff ff       	call   8016d2 <sys_page_map>
  801a0a:	83 c4 20             	add    $0x20,%esp
  801a0d:	85 c0                	test   %eax,%eax
  801a0f:	0f 89 b2 00 00 00    	jns    801ac7 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  801a15:	50                   	push   %eax
  801a16:	68 d7 39 80 00       	push   $0x8039d7
  801a1b:	68 97 00 00 00       	push   $0x97
  801a20:	68 85 39 80 00       	push   $0x803985
  801a25:	e8 eb ef ff ff       	call   800a15 <_panic>
		}
		// the page is writable or copy-on-write
		else if((pe & PTE_W) || (pe & PTE_COW)) {
  801a2a:	f7 c7 02 08 00 00    	test   $0x802,%edi
  801a30:	74 63                	je     801a95 <fork+0x13f>
			// create the child mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, 
  801a32:	81 e7 05 06 00 00    	and    $0x605,%edi
  801a38:	81 cf 00 08 00 00    	or     $0x800,%edi
  801a3e:	83 ec 0c             	sub    $0xc,%esp
  801a41:	57                   	push   %edi
  801a42:	53                   	push   %ebx
  801a43:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a46:	53                   	push   %ebx
  801a47:	6a 00                	push   $0x0
  801a49:	e8 84 fc ff ff       	call   8016d2 <sys_page_map>
  801a4e:	83 c4 20             	add    $0x20,%esp
  801a51:	85 c0                	test   %eax,%eax
  801a53:	79 15                	jns    801a6a <fork+0x114>
				(void *)(pn*PGSIZE), (pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  801a55:	50                   	push   %eax
  801a56:	68 d7 39 80 00       	push   $0x8039d7
  801a5b:	68 9e 00 00 00       	push   $0x9e
  801a60:	68 85 39 80 00       	push   $0x803985
  801a65:	e8 ab ef ff ff       	call   800a15 <_panic>
			// map the parent mapping copy-on-write
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE),
  801a6a:	83 ec 0c             	sub    $0xc,%esp
  801a6d:	57                   	push   %edi
  801a6e:	53                   	push   %ebx
  801a6f:	6a 00                	push   $0x0
  801a71:	53                   	push   %ebx
  801a72:	6a 00                	push   $0x0
  801a74:	e8 59 fc ff ff       	call   8016d2 <sys_page_map>
  801a79:	83 c4 20             	add    $0x20,%esp
  801a7c:	85 c0                	test   %eax,%eax
  801a7e:	79 47                	jns    801ac7 <fork+0x171>
				(pe&PTE_SYSCALL&~PTE_W)|PTE_COW)) < 0)
				panic("duppage: %e", r);
  801a80:	50                   	push   %eax
  801a81:	68 d7 39 80 00       	push   $0x8039d7
  801a86:	68 a2 00 00 00       	push   $0xa2
  801a8b:	68 85 39 80 00       	push   $0x803985
  801a90:	e8 80 ef ff ff       	call   800a15 <_panic>
		}	
		else {
			// create the child mapping read only
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
  801a95:	83 ec 0c             	sub    $0xc,%esp
  801a98:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  801a9e:	57                   	push   %edi
  801a9f:	53                   	push   %ebx
  801aa0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aa3:	53                   	push   %ebx
  801aa4:	6a 00                	push   $0x0
  801aa6:	e8 27 fc ff ff       	call   8016d2 <sys_page_map>
  801aab:	83 c4 20             	add    $0x20,%esp
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	79 15                	jns    801ac7 <fork+0x171>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("duppage: %e", r);
  801ab2:	50                   	push   %eax
  801ab3:	68 d7 39 80 00       	push   $0x8039d7
  801ab8:	68 a8 00 00 00       	push   $0xa8
  801abd:	68 85 39 80 00       	push   $0x803985
  801ac2:	e8 4e ef ff ff       	call   800a15 <_panic>
			panic("sys_page_alloc: %e", r);*/

		return 0;
	}
	// copy address to child environment's page dirctory
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn)
  801ac7:	83 c6 01             	add    $0x1,%esi
  801aca:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ad0:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801ad6:	0f 85 e7 fe ff ff    	jne    8019c3 <fork+0x6d>
	#ifdef CHALLENGE 
	if((r = sys_env_set_exception_upcall(envid, thisenv->env_exception_upcall)) < 0)
		panic("sys_env_set_exception_upcall: %e", r);
	#else
	// set child's page fault handler
	if((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  801adc:	a1 24 54 80 00       	mov    0x805424,%eax
  801ae1:	8b 40 64             	mov    0x64(%eax),%eax
  801ae4:	83 ec 08             	sub    $0x8,%esp
  801ae7:	50                   	push   %eax
  801ae8:	ff 75 e0             	pushl  -0x20(%ebp)
  801aeb:	e8 ea fc ff ff       	call   8017da <sys_env_set_pgfault_upcall>
  801af0:	83 c4 10             	add    $0x10,%esp
  801af3:	85 c0                	test   %eax,%eax
  801af5:	79 15                	jns    801b0c <fork+0x1b6>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801af7:	50                   	push   %eax
  801af8:	68 10 3a 80 00       	push   $0x803a10
  801afd:	68 e9 00 00 00       	push   $0xe9
  801b02:	68 85 39 80 00       	push   $0x803985
  801b07:	e8 09 ef ff ff       	call   800a15 <_panic>
	#endif

	// alloc exception stack for child environment
	if((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), 
  801b0c:	83 ec 04             	sub    $0x4,%esp
  801b0f:	6a 07                	push   $0x7
  801b11:	68 00 f0 bf ee       	push   $0xeebff000
  801b16:	ff 75 e0             	pushl  -0x20(%ebp)
  801b19:	e8 71 fb ff ff       	call   80168f <sys_page_alloc>
  801b1e:	83 c4 10             	add    $0x10,%esp
  801b21:	85 c0                	test   %eax,%eax
  801b23:	79 15                	jns    801b3a <fork+0x1e4>
		PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
  801b25:	50                   	push   %eax
  801b26:	68 90 39 80 00       	push   $0x803990
  801b2b:	68 ef 00 00 00       	push   $0xef
  801b30:	68 85 39 80 00       	push   $0x803985
  801b35:	e8 db ee ff ff       	call   800a15 <_panic>

	// start the child environment running
	if((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801b3a:	83 ec 08             	sub    $0x8,%esp
  801b3d:	6a 02                	push   $0x2
  801b3f:	ff 75 e0             	pushl  -0x20(%ebp)
  801b42:	e8 0f fc ff ff       	call   801756 <sys_env_set_status>
  801b47:	83 c4 10             	add    $0x10,%esp
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	79 15                	jns    801b63 <fork+0x20d>
		panic("sys_env_set_status: %e", r);
  801b4e:	50                   	push   %eax
  801b4f:	68 e3 39 80 00       	push   $0x8039e3
  801b54:	68 f3 00 00 00       	push   $0xf3
  801b59:	68 85 39 80 00       	push   $0x803985
  801b5e:	e8 b2 ee ff ff       	call   800a15 <_panic>

	return envid;
  801b63:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801b66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b69:	5b                   	pop    %ebx
  801b6a:	5e                   	pop    %esi
  801b6b:	5f                   	pop    %edi
  801b6c:	5d                   	pop    %ebp
  801b6d:	c3                   	ret    

00801b6e <sfork>:

// Challenge!
int
sfork(void)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801b74:	68 fa 39 80 00       	push   $0x8039fa
  801b79:	68 fc 00 00 00       	push   $0xfc
  801b7e:	68 85 39 80 00       	push   $0x803985
  801b83:	e8 8d ee ff ff       	call   800a15 <_panic>

00801b88 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	8b 55 08             	mov    0x8(%ebp),%edx
  801b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b91:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801b94:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801b96:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801b99:	83 3a 01             	cmpl   $0x1,(%edx)
  801b9c:	7e 09                	jle    801ba7 <argstart+0x1f>
  801b9e:	ba 21 34 80 00       	mov    $0x803421,%edx
  801ba3:	85 c9                	test   %ecx,%ecx
  801ba5:	75 05                	jne    801bac <argstart+0x24>
  801ba7:	ba 00 00 00 00       	mov    $0x0,%edx
  801bac:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801baf:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    

00801bb8 <argnext>:

int
argnext(struct Argstate *args)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	53                   	push   %ebx
  801bbc:	83 ec 04             	sub    $0x4,%esp
  801bbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801bc2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801bc9:	8b 43 08             	mov    0x8(%ebx),%eax
  801bcc:	85 c0                	test   %eax,%eax
  801bce:	74 6f                	je     801c3f <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801bd0:	80 38 00             	cmpb   $0x0,(%eax)
  801bd3:	75 4e                	jne    801c23 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801bd5:	8b 0b                	mov    (%ebx),%ecx
  801bd7:	83 39 01             	cmpl   $0x1,(%ecx)
  801bda:	74 55                	je     801c31 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801bdc:	8b 53 04             	mov    0x4(%ebx),%edx
  801bdf:	8b 42 04             	mov    0x4(%edx),%eax
  801be2:	80 38 2d             	cmpb   $0x2d,(%eax)
  801be5:	75 4a                	jne    801c31 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801be7:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801beb:	74 44                	je     801c31 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801bed:	83 c0 01             	add    $0x1,%eax
  801bf0:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801bf3:	83 ec 04             	sub    $0x4,%esp
  801bf6:	8b 01                	mov    (%ecx),%eax
  801bf8:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801bff:	50                   	push   %eax
  801c00:	8d 42 08             	lea    0x8(%edx),%eax
  801c03:	50                   	push   %eax
  801c04:	83 c2 04             	add    $0x4,%edx
  801c07:	52                   	push   %edx
  801c08:	e8 9a f7 ff ff       	call   8013a7 <memmove>
		(*args->argc)--;
  801c0d:	8b 03                	mov    (%ebx),%eax
  801c0f:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801c12:	8b 43 08             	mov    0x8(%ebx),%eax
  801c15:	83 c4 10             	add    $0x10,%esp
  801c18:	80 38 2d             	cmpb   $0x2d,(%eax)
  801c1b:	75 06                	jne    801c23 <argnext+0x6b>
  801c1d:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801c21:	74 0e                	je     801c31 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801c23:	8b 53 08             	mov    0x8(%ebx),%edx
  801c26:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801c29:	83 c2 01             	add    $0x1,%edx
  801c2c:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801c2f:	eb 13                	jmp    801c44 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801c31:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801c38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801c3d:	eb 05                	jmp    801c44 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801c3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801c44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c47:	c9                   	leave  
  801c48:	c3                   	ret    

00801c49 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
  801c4c:	53                   	push   %ebx
  801c4d:	83 ec 04             	sub    $0x4,%esp
  801c50:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801c53:	8b 43 08             	mov    0x8(%ebx),%eax
  801c56:	85 c0                	test   %eax,%eax
  801c58:	74 58                	je     801cb2 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801c5a:	80 38 00             	cmpb   $0x0,(%eax)
  801c5d:	74 0c                	je     801c6b <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801c5f:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801c62:	c7 43 08 21 34 80 00 	movl   $0x803421,0x8(%ebx)
  801c69:	eb 42                	jmp    801cad <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801c6b:	8b 13                	mov    (%ebx),%edx
  801c6d:	83 3a 01             	cmpl   $0x1,(%edx)
  801c70:	7e 2d                	jle    801c9f <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801c72:	8b 43 04             	mov    0x4(%ebx),%eax
  801c75:	8b 48 04             	mov    0x4(%eax),%ecx
  801c78:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801c7b:	83 ec 04             	sub    $0x4,%esp
  801c7e:	8b 12                	mov    (%edx),%edx
  801c80:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801c87:	52                   	push   %edx
  801c88:	8d 50 08             	lea    0x8(%eax),%edx
  801c8b:	52                   	push   %edx
  801c8c:	83 c0 04             	add    $0x4,%eax
  801c8f:	50                   	push   %eax
  801c90:	e8 12 f7 ff ff       	call   8013a7 <memmove>
		(*args->argc)--;
  801c95:	8b 03                	mov    (%ebx),%eax
  801c97:	83 28 01             	subl   $0x1,(%eax)
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	eb 0e                	jmp    801cad <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801c9f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801ca6:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801cad:	8b 43 0c             	mov    0xc(%ebx),%eax
  801cb0:	eb 05                	jmp    801cb7 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801cb2:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801cb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cba:	c9                   	leave  
  801cbb:	c3                   	ret    

00801cbc <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	83 ec 08             	sub    $0x8,%esp
  801cc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801cc5:	8b 51 0c             	mov    0xc(%ecx),%edx
  801cc8:	89 d0                	mov    %edx,%eax
  801cca:	85 d2                	test   %edx,%edx
  801ccc:	75 0c                	jne    801cda <argvalue+0x1e>
  801cce:	83 ec 0c             	sub    $0xc,%esp
  801cd1:	51                   	push   %ecx
  801cd2:	e8 72 ff ff ff       	call   801c49 <argnextvalue>
  801cd7:	83 c4 10             	add    $0x10,%esp
}
  801cda:	c9                   	leave  
  801cdb:	c3                   	ret    

00801cdc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce2:	05 00 00 00 30       	add    $0x30000000,%eax
  801ce7:	c1 e8 0c             	shr    $0xc,%eax
}
  801cea:	5d                   	pop    %ebp
  801ceb:	c3                   	ret    

00801cec <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801cef:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf2:	05 00 00 00 30       	add    $0x30000000,%eax
  801cf7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801cfc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801d01:	5d                   	pop    %ebp
  801d02:	c3                   	ret    

00801d03 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
  801d06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d09:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801d0e:	89 c2                	mov    %eax,%edx
  801d10:	c1 ea 16             	shr    $0x16,%edx
  801d13:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d1a:	f6 c2 01             	test   $0x1,%dl
  801d1d:	74 11                	je     801d30 <fd_alloc+0x2d>
  801d1f:	89 c2                	mov    %eax,%edx
  801d21:	c1 ea 0c             	shr    $0xc,%edx
  801d24:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d2b:	f6 c2 01             	test   $0x1,%dl
  801d2e:	75 09                	jne    801d39 <fd_alloc+0x36>
			*fd_store = fd;
  801d30:	89 01                	mov    %eax,(%ecx)
			return 0;
  801d32:	b8 00 00 00 00       	mov    $0x0,%eax
  801d37:	eb 17                	jmp    801d50 <fd_alloc+0x4d>
  801d39:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801d3e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801d43:	75 c9                	jne    801d0e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801d45:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801d4b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    

00801d52 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801d58:	83 f8 1f             	cmp    $0x1f,%eax
  801d5b:	77 36                	ja     801d93 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801d5d:	c1 e0 0c             	shl    $0xc,%eax
  801d60:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801d65:	89 c2                	mov    %eax,%edx
  801d67:	c1 ea 16             	shr    $0x16,%edx
  801d6a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d71:	f6 c2 01             	test   $0x1,%dl
  801d74:	74 24                	je     801d9a <fd_lookup+0x48>
  801d76:	89 c2                	mov    %eax,%edx
  801d78:	c1 ea 0c             	shr    $0xc,%edx
  801d7b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d82:	f6 c2 01             	test   $0x1,%dl
  801d85:	74 1a                	je     801da1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801d87:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d8a:	89 02                	mov    %eax,(%edx)
	return 0;
  801d8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d91:	eb 13                	jmp    801da6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801d93:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d98:	eb 0c                	jmp    801da6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801d9a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d9f:	eb 05                	jmp    801da6 <fd_lookup+0x54>
  801da1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801da6:	5d                   	pop    %ebp
  801da7:	c3                   	ret    

00801da8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	83 ec 08             	sub    $0x8,%esp
  801dae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801db1:	ba ac 3a 80 00       	mov    $0x803aac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801db6:	eb 13                	jmp    801dcb <dev_lookup+0x23>
  801db8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801dbb:	39 08                	cmp    %ecx,(%eax)
  801dbd:	75 0c                	jne    801dcb <dev_lookup+0x23>
			*dev = devtab[i];
  801dbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dc2:	89 01                	mov    %eax,(%ecx)
			return 0;
  801dc4:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc9:	eb 2e                	jmp    801df9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801dcb:	8b 02                	mov    (%edx),%eax
  801dcd:	85 c0                	test   %eax,%eax
  801dcf:	75 e7                	jne    801db8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801dd1:	a1 24 54 80 00       	mov    0x805424,%eax
  801dd6:	8b 40 48             	mov    0x48(%eax),%eax
  801dd9:	83 ec 04             	sub    $0x4,%esp
  801ddc:	51                   	push   %ecx
  801ddd:	50                   	push   %eax
  801dde:	68 30 3a 80 00       	push   $0x803a30
  801de3:	e8 06 ed ff ff       	call   800aee <cprintf>
	*dev = 0;
  801de8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801deb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801df1:	83 c4 10             	add    $0x10,%esp
  801df4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    

00801dfb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	56                   	push   %esi
  801dff:	53                   	push   %ebx
  801e00:	83 ec 10             	sub    $0x10,%esp
  801e03:	8b 75 08             	mov    0x8(%ebp),%esi
  801e06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801e09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e0c:	50                   	push   %eax
  801e0d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801e13:	c1 e8 0c             	shr    $0xc,%eax
  801e16:	50                   	push   %eax
  801e17:	e8 36 ff ff ff       	call   801d52 <fd_lookup>
  801e1c:	83 c4 08             	add    $0x8,%esp
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	78 05                	js     801e28 <fd_close+0x2d>
	    || fd != fd2) 
  801e23:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801e26:	74 0c                	je     801e34 <fd_close+0x39>
		return (must_exist ? r : 0); 
  801e28:	84 db                	test   %bl,%bl
  801e2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801e2f:	0f 44 c2             	cmove  %edx,%eax
  801e32:	eb 41                	jmp    801e75 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801e34:	83 ec 08             	sub    $0x8,%esp
  801e37:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e3a:	50                   	push   %eax
  801e3b:	ff 36                	pushl  (%esi)
  801e3d:	e8 66 ff ff ff       	call   801da8 <dev_lookup>
  801e42:	89 c3                	mov    %eax,%ebx
  801e44:	83 c4 10             	add    $0x10,%esp
  801e47:	85 c0                	test   %eax,%eax
  801e49:	78 1a                	js     801e65 <fd_close+0x6a>
		if (dev->dev_close) 
  801e4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e4e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  801e51:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  801e56:	85 c0                	test   %eax,%eax
  801e58:	74 0b                	je     801e65 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801e5a:	83 ec 0c             	sub    $0xc,%esp
  801e5d:	56                   	push   %esi
  801e5e:	ff d0                	call   *%eax
  801e60:	89 c3                	mov    %eax,%ebx
  801e62:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801e65:	83 ec 08             	sub    $0x8,%esp
  801e68:	56                   	push   %esi
  801e69:	6a 00                	push   $0x0
  801e6b:	e8 a4 f8 ff ff       	call   801714 <sys_page_unmap>
	return r;
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	89 d8                	mov    %ebx,%eax
}
  801e75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5d                   	pop    %ebp
  801e7b:	c3                   	ret    

00801e7c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e85:	50                   	push   %eax
  801e86:	ff 75 08             	pushl  0x8(%ebp)
  801e89:	e8 c4 fe ff ff       	call   801d52 <fd_lookup>
  801e8e:	83 c4 08             	add    $0x8,%esp
  801e91:	85 c0                	test   %eax,%eax
  801e93:	78 10                	js     801ea5 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  801e95:	83 ec 08             	sub    $0x8,%esp
  801e98:	6a 01                	push   $0x1
  801e9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9d:	e8 59 ff ff ff       	call   801dfb <fd_close>
  801ea2:	83 c4 10             	add    $0x10,%esp
}
  801ea5:	c9                   	leave  
  801ea6:	c3                   	ret    

00801ea7 <close_all>:

void
close_all(void)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	53                   	push   %ebx
  801eab:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801eae:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801eb3:	83 ec 0c             	sub    $0xc,%esp
  801eb6:	53                   	push   %ebx
  801eb7:	e8 c0 ff ff ff       	call   801e7c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801ebc:	83 c3 01             	add    $0x1,%ebx
  801ebf:	83 c4 10             	add    $0x10,%esp
  801ec2:	83 fb 20             	cmp    $0x20,%ebx
  801ec5:	75 ec                	jne    801eb3 <close_all+0xc>
		close(i);
}
  801ec7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eca:	c9                   	leave  
  801ecb:	c3                   	ret    

00801ecc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801ecc:	55                   	push   %ebp
  801ecd:	89 e5                	mov    %esp,%ebp
  801ecf:	57                   	push   %edi
  801ed0:	56                   	push   %esi
  801ed1:	53                   	push   %ebx
  801ed2:	83 ec 2c             	sub    $0x2c,%esp
  801ed5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801ed8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801edb:	50                   	push   %eax
  801edc:	ff 75 08             	pushl  0x8(%ebp)
  801edf:	e8 6e fe ff ff       	call   801d52 <fd_lookup>
  801ee4:	83 c4 08             	add    $0x8,%esp
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	0f 88 c1 00 00 00    	js     801fb0 <dup+0xe4>
		return r;
	close(newfdnum);
  801eef:	83 ec 0c             	sub    $0xc,%esp
  801ef2:	56                   	push   %esi
  801ef3:	e8 84 ff ff ff       	call   801e7c <close>

	newfd = INDEX2FD(newfdnum);
  801ef8:	89 f3                	mov    %esi,%ebx
  801efa:	c1 e3 0c             	shl    $0xc,%ebx
  801efd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801f03:	83 c4 04             	add    $0x4,%esp
  801f06:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f09:	e8 de fd ff ff       	call   801cec <fd2data>
  801f0e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801f10:	89 1c 24             	mov    %ebx,(%esp)
  801f13:	e8 d4 fd ff ff       	call   801cec <fd2data>
  801f18:	83 c4 10             	add    $0x10,%esp
  801f1b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801f1e:	89 f8                	mov    %edi,%eax
  801f20:	c1 e8 16             	shr    $0x16,%eax
  801f23:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801f2a:	a8 01                	test   $0x1,%al
  801f2c:	74 37                	je     801f65 <dup+0x99>
  801f2e:	89 f8                	mov    %edi,%eax
  801f30:	c1 e8 0c             	shr    $0xc,%eax
  801f33:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801f3a:	f6 c2 01             	test   $0x1,%dl
  801f3d:	74 26                	je     801f65 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801f3f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f46:	83 ec 0c             	sub    $0xc,%esp
  801f49:	25 07 0e 00 00       	and    $0xe07,%eax
  801f4e:	50                   	push   %eax
  801f4f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801f52:	6a 00                	push   $0x0
  801f54:	57                   	push   %edi
  801f55:	6a 00                	push   $0x0
  801f57:	e8 76 f7 ff ff       	call   8016d2 <sys_page_map>
  801f5c:	89 c7                	mov    %eax,%edi
  801f5e:	83 c4 20             	add    $0x20,%esp
  801f61:	85 c0                	test   %eax,%eax
  801f63:	78 2e                	js     801f93 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801f65:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801f68:	89 d0                	mov    %edx,%eax
  801f6a:	c1 e8 0c             	shr    $0xc,%eax
  801f6d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f74:	83 ec 0c             	sub    $0xc,%esp
  801f77:	25 07 0e 00 00       	and    $0xe07,%eax
  801f7c:	50                   	push   %eax
  801f7d:	53                   	push   %ebx
  801f7e:	6a 00                	push   $0x0
  801f80:	52                   	push   %edx
  801f81:	6a 00                	push   $0x0
  801f83:	e8 4a f7 ff ff       	call   8016d2 <sys_page_map>
  801f88:	89 c7                	mov    %eax,%edi
  801f8a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801f8d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801f8f:	85 ff                	test   %edi,%edi
  801f91:	79 1d                	jns    801fb0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801f93:	83 ec 08             	sub    $0x8,%esp
  801f96:	53                   	push   %ebx
  801f97:	6a 00                	push   $0x0
  801f99:	e8 76 f7 ff ff       	call   801714 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801f9e:	83 c4 08             	add    $0x8,%esp
  801fa1:	ff 75 d4             	pushl  -0x2c(%ebp)
  801fa4:	6a 00                	push   $0x0
  801fa6:	e8 69 f7 ff ff       	call   801714 <sys_page_unmap>
	return r;
  801fab:	83 c4 10             	add    $0x10,%esp
  801fae:	89 f8                	mov    %edi,%eax
}
  801fb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5f                   	pop    %edi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    

00801fb8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	53                   	push   %ebx
  801fbc:	83 ec 14             	sub    $0x14,%esp
  801fbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fc2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fc5:	50                   	push   %eax
  801fc6:	53                   	push   %ebx
  801fc7:	e8 86 fd ff ff       	call   801d52 <fd_lookup>
  801fcc:	83 c4 08             	add    $0x8,%esp
  801fcf:	89 c2                	mov    %eax,%edx
  801fd1:	85 c0                	test   %eax,%eax
  801fd3:	78 6d                	js     802042 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fd5:	83 ec 08             	sub    $0x8,%esp
  801fd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fdb:	50                   	push   %eax
  801fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fdf:	ff 30                	pushl  (%eax)
  801fe1:	e8 c2 fd ff ff       	call   801da8 <dev_lookup>
  801fe6:	83 c4 10             	add    $0x10,%esp
  801fe9:	85 c0                	test   %eax,%eax
  801feb:	78 4c                	js     802039 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801fed:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ff0:	8b 42 08             	mov    0x8(%edx),%eax
  801ff3:	83 e0 03             	and    $0x3,%eax
  801ff6:	83 f8 01             	cmp    $0x1,%eax
  801ff9:	75 21                	jne    80201c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801ffb:	a1 24 54 80 00       	mov    0x805424,%eax
  802000:	8b 40 48             	mov    0x48(%eax),%eax
  802003:	83 ec 04             	sub    $0x4,%esp
  802006:	53                   	push   %ebx
  802007:	50                   	push   %eax
  802008:	68 71 3a 80 00       	push   $0x803a71
  80200d:	e8 dc ea ff ff       	call   800aee <cprintf>
		return -E_INVAL;
  802012:	83 c4 10             	add    $0x10,%esp
  802015:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80201a:	eb 26                	jmp    802042 <read+0x8a>
	}
	if (!dev->dev_read)
  80201c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201f:	8b 40 08             	mov    0x8(%eax),%eax
  802022:	85 c0                	test   %eax,%eax
  802024:	74 17                	je     80203d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802026:	83 ec 04             	sub    $0x4,%esp
  802029:	ff 75 10             	pushl  0x10(%ebp)
  80202c:	ff 75 0c             	pushl  0xc(%ebp)
  80202f:	52                   	push   %edx
  802030:	ff d0                	call   *%eax
  802032:	89 c2                	mov    %eax,%edx
  802034:	83 c4 10             	add    $0x10,%esp
  802037:	eb 09                	jmp    802042 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802039:	89 c2                	mov    %eax,%edx
  80203b:	eb 05                	jmp    802042 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80203d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802042:	89 d0                	mov    %edx,%eax
  802044:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802047:	c9                   	leave  
  802048:	c3                   	ret    

00802049 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802049:	55                   	push   %ebp
  80204a:	89 e5                	mov    %esp,%ebp
  80204c:	57                   	push   %edi
  80204d:	56                   	push   %esi
  80204e:	53                   	push   %ebx
  80204f:	83 ec 0c             	sub    $0xc,%esp
  802052:	8b 7d 08             	mov    0x8(%ebp),%edi
  802055:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802058:	bb 00 00 00 00       	mov    $0x0,%ebx
  80205d:	eb 21                	jmp    802080 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80205f:	83 ec 04             	sub    $0x4,%esp
  802062:	89 f0                	mov    %esi,%eax
  802064:	29 d8                	sub    %ebx,%eax
  802066:	50                   	push   %eax
  802067:	89 d8                	mov    %ebx,%eax
  802069:	03 45 0c             	add    0xc(%ebp),%eax
  80206c:	50                   	push   %eax
  80206d:	57                   	push   %edi
  80206e:	e8 45 ff ff ff       	call   801fb8 <read>
		if (m < 0)
  802073:	83 c4 10             	add    $0x10,%esp
  802076:	85 c0                	test   %eax,%eax
  802078:	78 10                	js     80208a <readn+0x41>
			return m;
		if (m == 0)
  80207a:	85 c0                	test   %eax,%eax
  80207c:	74 0a                	je     802088 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80207e:	01 c3                	add    %eax,%ebx
  802080:	39 f3                	cmp    %esi,%ebx
  802082:	72 db                	jb     80205f <readn+0x16>
  802084:	89 d8                	mov    %ebx,%eax
  802086:	eb 02                	jmp    80208a <readn+0x41>
  802088:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80208a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    

00802092 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802092:	55                   	push   %ebp
  802093:	89 e5                	mov    %esp,%ebp
  802095:	53                   	push   %ebx
  802096:	83 ec 14             	sub    $0x14,%esp
  802099:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80209c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80209f:	50                   	push   %eax
  8020a0:	53                   	push   %ebx
  8020a1:	e8 ac fc ff ff       	call   801d52 <fd_lookup>
  8020a6:	83 c4 08             	add    $0x8,%esp
  8020a9:	89 c2                	mov    %eax,%edx
  8020ab:	85 c0                	test   %eax,%eax
  8020ad:	78 68                	js     802117 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020af:	83 ec 08             	sub    $0x8,%esp
  8020b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b5:	50                   	push   %eax
  8020b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020b9:	ff 30                	pushl  (%eax)
  8020bb:	e8 e8 fc ff ff       	call   801da8 <dev_lookup>
  8020c0:	83 c4 10             	add    $0x10,%esp
  8020c3:	85 c0                	test   %eax,%eax
  8020c5:	78 47                	js     80210e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8020c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8020ce:	75 21                	jne    8020f1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8020d0:	a1 24 54 80 00       	mov    0x805424,%eax
  8020d5:	8b 40 48             	mov    0x48(%eax),%eax
  8020d8:	83 ec 04             	sub    $0x4,%esp
  8020db:	53                   	push   %ebx
  8020dc:	50                   	push   %eax
  8020dd:	68 8d 3a 80 00       	push   $0x803a8d
  8020e2:	e8 07 ea ff ff       	call   800aee <cprintf>
		return -E_INVAL;
  8020e7:	83 c4 10             	add    $0x10,%esp
  8020ea:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8020ef:	eb 26                	jmp    802117 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8020f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020f4:	8b 52 0c             	mov    0xc(%edx),%edx
  8020f7:	85 d2                	test   %edx,%edx
  8020f9:	74 17                	je     802112 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8020fb:	83 ec 04             	sub    $0x4,%esp
  8020fe:	ff 75 10             	pushl  0x10(%ebp)
  802101:	ff 75 0c             	pushl  0xc(%ebp)
  802104:	50                   	push   %eax
  802105:	ff d2                	call   *%edx
  802107:	89 c2                	mov    %eax,%edx
  802109:	83 c4 10             	add    $0x10,%esp
  80210c:	eb 09                	jmp    802117 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80210e:	89 c2                	mov    %eax,%edx
  802110:	eb 05                	jmp    802117 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802112:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802117:	89 d0                	mov    %edx,%eax
  802119:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80211c:	c9                   	leave  
  80211d:	c3                   	ret    

0080211e <seek>:

int
seek(int fdnum, off_t offset)
{
  80211e:	55                   	push   %ebp
  80211f:	89 e5                	mov    %esp,%ebp
  802121:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802124:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802127:	50                   	push   %eax
  802128:	ff 75 08             	pushl  0x8(%ebp)
  80212b:	e8 22 fc ff ff       	call   801d52 <fd_lookup>
  802130:	83 c4 08             	add    $0x8,%esp
  802133:	85 c0                	test   %eax,%eax
  802135:	78 0e                	js     802145 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802137:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80213a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80213d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802140:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802145:	c9                   	leave  
  802146:	c3                   	ret    

00802147 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802147:	55                   	push   %ebp
  802148:	89 e5                	mov    %esp,%ebp
  80214a:	53                   	push   %ebx
  80214b:	83 ec 14             	sub    $0x14,%esp
  80214e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802151:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802154:	50                   	push   %eax
  802155:	53                   	push   %ebx
  802156:	e8 f7 fb ff ff       	call   801d52 <fd_lookup>
  80215b:	83 c4 08             	add    $0x8,%esp
  80215e:	89 c2                	mov    %eax,%edx
  802160:	85 c0                	test   %eax,%eax
  802162:	78 65                	js     8021c9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802164:	83 ec 08             	sub    $0x8,%esp
  802167:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80216a:	50                   	push   %eax
  80216b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80216e:	ff 30                	pushl  (%eax)
  802170:	e8 33 fc ff ff       	call   801da8 <dev_lookup>
  802175:	83 c4 10             	add    $0x10,%esp
  802178:	85 c0                	test   %eax,%eax
  80217a:	78 44                	js     8021c0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80217c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80217f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802183:	75 21                	jne    8021a6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802185:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80218a:	8b 40 48             	mov    0x48(%eax),%eax
  80218d:	83 ec 04             	sub    $0x4,%esp
  802190:	53                   	push   %ebx
  802191:	50                   	push   %eax
  802192:	68 50 3a 80 00       	push   $0x803a50
  802197:	e8 52 e9 ff ff       	call   800aee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80219c:	83 c4 10             	add    $0x10,%esp
  80219f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8021a4:	eb 23                	jmp    8021c9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8021a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021a9:	8b 52 18             	mov    0x18(%edx),%edx
  8021ac:	85 d2                	test   %edx,%edx
  8021ae:	74 14                	je     8021c4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8021b0:	83 ec 08             	sub    $0x8,%esp
  8021b3:	ff 75 0c             	pushl  0xc(%ebp)
  8021b6:	50                   	push   %eax
  8021b7:	ff d2                	call   *%edx
  8021b9:	89 c2                	mov    %eax,%edx
  8021bb:	83 c4 10             	add    $0x10,%esp
  8021be:	eb 09                	jmp    8021c9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021c0:	89 c2                	mov    %eax,%edx
  8021c2:	eb 05                	jmp    8021c9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8021c4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8021c9:	89 d0                	mov    %edx,%eax
  8021cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021ce:	c9                   	leave  
  8021cf:	c3                   	ret    

008021d0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8021d0:	55                   	push   %ebp
  8021d1:	89 e5                	mov    %esp,%ebp
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 14             	sub    $0x14,%esp
  8021d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8021da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021dd:	50                   	push   %eax
  8021de:	ff 75 08             	pushl  0x8(%ebp)
  8021e1:	e8 6c fb ff ff       	call   801d52 <fd_lookup>
  8021e6:	83 c4 08             	add    $0x8,%esp
  8021e9:	89 c2                	mov    %eax,%edx
  8021eb:	85 c0                	test   %eax,%eax
  8021ed:	78 58                	js     802247 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021ef:	83 ec 08             	sub    $0x8,%esp
  8021f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021f5:	50                   	push   %eax
  8021f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021f9:	ff 30                	pushl  (%eax)
  8021fb:	e8 a8 fb ff ff       	call   801da8 <dev_lookup>
  802200:	83 c4 10             	add    $0x10,%esp
  802203:	85 c0                	test   %eax,%eax
  802205:	78 37                	js     80223e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802207:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80220e:	74 32                	je     802242 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802210:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802213:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80221a:	00 00 00 
	stat->st_isdir = 0;
  80221d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802224:	00 00 00 
	stat->st_dev = dev;
  802227:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80222d:	83 ec 08             	sub    $0x8,%esp
  802230:	53                   	push   %ebx
  802231:	ff 75 f0             	pushl  -0x10(%ebp)
  802234:	ff 50 14             	call   *0x14(%eax)
  802237:	89 c2                	mov    %eax,%edx
  802239:	83 c4 10             	add    $0x10,%esp
  80223c:	eb 09                	jmp    802247 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80223e:	89 c2                	mov    %eax,%edx
  802240:	eb 05                	jmp    802247 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802242:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802247:	89 d0                	mov    %edx,%eax
  802249:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80224c:	c9                   	leave  
  80224d:	c3                   	ret    

0080224e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80224e:	55                   	push   %ebp
  80224f:	89 e5                	mov    %esp,%ebp
  802251:	56                   	push   %esi
  802252:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802253:	83 ec 08             	sub    $0x8,%esp
  802256:	6a 00                	push   $0x0
  802258:	ff 75 08             	pushl  0x8(%ebp)
  80225b:	e8 2b 02 00 00       	call   80248b <open>
  802260:	89 c3                	mov    %eax,%ebx
  802262:	83 c4 10             	add    $0x10,%esp
  802265:	85 c0                	test   %eax,%eax
  802267:	78 1b                	js     802284 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802269:	83 ec 08             	sub    $0x8,%esp
  80226c:	ff 75 0c             	pushl  0xc(%ebp)
  80226f:	50                   	push   %eax
  802270:	e8 5b ff ff ff       	call   8021d0 <fstat>
  802275:	89 c6                	mov    %eax,%esi
	close(fd);
  802277:	89 1c 24             	mov    %ebx,(%esp)
  80227a:	e8 fd fb ff ff       	call   801e7c <close>
	return r;
  80227f:	83 c4 10             	add    $0x10,%esp
  802282:	89 f0                	mov    %esi,%eax
}
  802284:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802287:	5b                   	pop    %ebx
  802288:	5e                   	pop    %esi
  802289:	5d                   	pop    %ebp
  80228a:	c3                   	ret    

0080228b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80228b:	55                   	push   %ebp
  80228c:	89 e5                	mov    %esp,%ebp
  80228e:	56                   	push   %esi
  80228f:	53                   	push   %ebx
  802290:	89 c6                	mov    %eax,%esi
  802292:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802294:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  80229b:	75 12                	jne    8022af <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80229d:	83 ec 0c             	sub    $0xc,%esp
  8022a0:	6a 01                	push   $0x1
  8022a2:	e8 46 0e 00 00       	call   8030ed <ipc_find_env>
  8022a7:	a3 20 54 80 00       	mov    %eax,0x805420
  8022ac:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8022af:	6a 07                	push   $0x7
  8022b1:	68 00 60 80 00       	push   $0x806000
  8022b6:	56                   	push   %esi
  8022b7:	ff 35 20 54 80 00    	pushl  0x805420
  8022bd:	e8 d5 0d 00 00       	call   803097 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8022c2:	83 c4 0c             	add    $0xc,%esp
  8022c5:	6a 00                	push   $0x0
  8022c7:	53                   	push   %ebx
  8022c8:	6a 00                	push   $0x0
  8022ca:	e8 5f 0d 00 00       	call   80302e <ipc_recv>
}
  8022cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022d2:	5b                   	pop    %ebx
  8022d3:	5e                   	pop    %esi
  8022d4:	5d                   	pop    %ebp
  8022d5:	c3                   	ret    

008022d6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8022d6:	55                   	push   %ebp
  8022d7:	89 e5                	mov    %esp,%ebp
  8022d9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8022dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8022df:	8b 40 0c             	mov    0xc(%eax),%eax
  8022e2:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8022e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ea:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8022ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8022f4:	b8 02 00 00 00       	mov    $0x2,%eax
  8022f9:	e8 8d ff ff ff       	call   80228b <fsipc>
}
  8022fe:	c9                   	leave  
  8022ff:	c3                   	ret    

00802300 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802300:	55                   	push   %ebp
  802301:	89 e5                	mov    %esp,%ebp
  802303:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802306:	8b 45 08             	mov    0x8(%ebp),%eax
  802309:	8b 40 0c             	mov    0xc(%eax),%eax
  80230c:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802311:	ba 00 00 00 00       	mov    $0x0,%edx
  802316:	b8 06 00 00 00       	mov    $0x6,%eax
  80231b:	e8 6b ff ff ff       	call   80228b <fsipc>
}
  802320:	c9                   	leave  
  802321:	c3                   	ret    

00802322 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802322:	55                   	push   %ebp
  802323:	89 e5                	mov    %esp,%ebp
  802325:	53                   	push   %ebx
  802326:	83 ec 04             	sub    $0x4,%esp
  802329:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80232c:	8b 45 08             	mov    0x8(%ebp),%eax
  80232f:	8b 40 0c             	mov    0xc(%eax),%eax
  802332:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802337:	ba 00 00 00 00       	mov    $0x0,%edx
  80233c:	b8 05 00 00 00       	mov    $0x5,%eax
  802341:	e8 45 ff ff ff       	call   80228b <fsipc>
  802346:	85 c0                	test   %eax,%eax
  802348:	78 2c                	js     802376 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80234a:	83 ec 08             	sub    $0x8,%esp
  80234d:	68 00 60 80 00       	push   $0x806000
  802352:	53                   	push   %ebx
  802353:	e8 bd ee ff ff       	call   801215 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802358:	a1 80 60 80 00       	mov    0x806080,%eax
  80235d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802363:	a1 84 60 80 00       	mov    0x806084,%eax
  802368:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80236e:	83 c4 10             	add    $0x10,%esp
  802371:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802376:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802379:	c9                   	leave  
  80237a:	c3                   	ret    

0080237b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80237b:	55                   	push   %ebp
  80237c:	89 e5                	mov    %esp,%ebp
  80237e:	53                   	push   %ebx
  80237f:	83 ec 08             	sub    $0x8,%esp
  802382:	8b 45 10             	mov    0x10(%ebp),%eax
  802385:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80238a:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80238f:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802392:	8b 45 08             	mov    0x8(%ebp),%eax
  802395:	8b 40 0c             	mov    0xc(%eax),%eax
  802398:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.write.req_n = n;
  80239d:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8023a3:	53                   	push   %ebx
  8023a4:	ff 75 0c             	pushl  0xc(%ebp)
  8023a7:	68 08 60 80 00       	push   $0x806008
  8023ac:	e8 f6 ef ff ff       	call   8013a7 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8023b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8023b6:	b8 04 00 00 00       	mov    $0x4,%eax
  8023bb:	e8 cb fe ff ff       	call   80228b <fsipc>
  8023c0:	83 c4 10             	add    $0x10,%esp
  8023c3:	85 c0                	test   %eax,%eax
  8023c5:	78 3d                	js     802404 <devfile_write+0x89>
		return r;

	assert(r <= n);
  8023c7:	39 d8                	cmp    %ebx,%eax
  8023c9:	76 19                	jbe    8023e4 <devfile_write+0x69>
  8023cb:	68 bc 3a 80 00       	push   $0x803abc
  8023d0:	68 46 35 80 00       	push   $0x803546
  8023d5:	68 9f 00 00 00       	push   $0x9f
  8023da:	68 c3 3a 80 00       	push   $0x803ac3
  8023df:	e8 31 e6 ff ff       	call   800a15 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  8023e4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8023e9:	76 19                	jbe    802404 <devfile_write+0x89>
  8023eb:	68 dc 3a 80 00       	push   $0x803adc
  8023f0:	68 46 35 80 00       	push   $0x803546
  8023f5:	68 a0 00 00 00       	push   $0xa0
  8023fa:	68 c3 3a 80 00       	push   $0x803ac3
  8023ff:	e8 11 e6 ff ff       	call   800a15 <_panic>

	return r;
}
  802404:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802407:	c9                   	leave  
  802408:	c3                   	ret    

00802409 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802409:	55                   	push   %ebp
  80240a:	89 e5                	mov    %esp,%ebp
  80240c:	56                   	push   %esi
  80240d:	53                   	push   %ebx
  80240e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802411:	8b 45 08             	mov    0x8(%ebp),%eax
  802414:	8b 40 0c             	mov    0xc(%eax),%eax
  802417:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80241c:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802422:	ba 00 00 00 00       	mov    $0x0,%edx
  802427:	b8 03 00 00 00       	mov    $0x3,%eax
  80242c:	e8 5a fe ff ff       	call   80228b <fsipc>
  802431:	89 c3                	mov    %eax,%ebx
  802433:	85 c0                	test   %eax,%eax
  802435:	78 4b                	js     802482 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802437:	39 c6                	cmp    %eax,%esi
  802439:	73 16                	jae    802451 <devfile_read+0x48>
  80243b:	68 bc 3a 80 00       	push   $0x803abc
  802440:	68 46 35 80 00       	push   $0x803546
  802445:	6a 7e                	push   $0x7e
  802447:	68 c3 3a 80 00       	push   $0x803ac3
  80244c:	e8 c4 e5 ff ff       	call   800a15 <_panic>
	assert(r <= PGSIZE);
  802451:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802456:	7e 16                	jle    80246e <devfile_read+0x65>
  802458:	68 ce 3a 80 00       	push   $0x803ace
  80245d:	68 46 35 80 00       	push   $0x803546
  802462:	6a 7f                	push   $0x7f
  802464:	68 c3 3a 80 00       	push   $0x803ac3
  802469:	e8 a7 e5 ff ff       	call   800a15 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80246e:	83 ec 04             	sub    $0x4,%esp
  802471:	50                   	push   %eax
  802472:	68 00 60 80 00       	push   $0x806000
  802477:	ff 75 0c             	pushl  0xc(%ebp)
  80247a:	e8 28 ef ff ff       	call   8013a7 <memmove>
	return r;
  80247f:	83 c4 10             	add    $0x10,%esp
}
  802482:	89 d8                	mov    %ebx,%eax
  802484:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802487:	5b                   	pop    %ebx
  802488:	5e                   	pop    %esi
  802489:	5d                   	pop    %ebp
  80248a:	c3                   	ret    

0080248b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80248b:	55                   	push   %ebp
  80248c:	89 e5                	mov    %esp,%ebp
  80248e:	53                   	push   %ebx
  80248f:	83 ec 20             	sub    $0x20,%esp
  802492:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802495:	53                   	push   %ebx
  802496:	e8 41 ed ff ff       	call   8011dc <strlen>
  80249b:	83 c4 10             	add    $0x10,%esp
  80249e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8024a3:	7f 67                	jg     80250c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8024a5:	83 ec 0c             	sub    $0xc,%esp
  8024a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024ab:	50                   	push   %eax
  8024ac:	e8 52 f8 ff ff       	call   801d03 <fd_alloc>
  8024b1:	83 c4 10             	add    $0x10,%esp
		return r;
  8024b4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8024b6:	85 c0                	test   %eax,%eax
  8024b8:	78 57                	js     802511 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8024ba:	83 ec 08             	sub    $0x8,%esp
  8024bd:	53                   	push   %ebx
  8024be:	68 00 60 80 00       	push   $0x806000
  8024c3:	e8 4d ed ff ff       	call   801215 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8024c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024cb:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8024d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8024d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8024d8:	e8 ae fd ff ff       	call   80228b <fsipc>
  8024dd:	89 c3                	mov    %eax,%ebx
  8024df:	83 c4 10             	add    $0x10,%esp
  8024e2:	85 c0                	test   %eax,%eax
  8024e4:	79 14                	jns    8024fa <open+0x6f>
		fd_close(fd, 0);
  8024e6:	83 ec 08             	sub    $0x8,%esp
  8024e9:	6a 00                	push   $0x0
  8024eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8024ee:	e8 08 f9 ff ff       	call   801dfb <fd_close>
		return r;
  8024f3:	83 c4 10             	add    $0x10,%esp
  8024f6:	89 da                	mov    %ebx,%edx
  8024f8:	eb 17                	jmp    802511 <open+0x86>
	}

	return fd2num(fd);
  8024fa:	83 ec 0c             	sub    $0xc,%esp
  8024fd:	ff 75 f4             	pushl  -0xc(%ebp)
  802500:	e8 d7 f7 ff ff       	call   801cdc <fd2num>
  802505:	89 c2                	mov    %eax,%edx
  802507:	83 c4 10             	add    $0x10,%esp
  80250a:	eb 05                	jmp    802511 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80250c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802511:	89 d0                	mov    %edx,%eax
  802513:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802516:	c9                   	leave  
  802517:	c3                   	ret    

00802518 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802518:	55                   	push   %ebp
  802519:	89 e5                	mov    %esp,%ebp
  80251b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80251e:	ba 00 00 00 00       	mov    $0x0,%edx
  802523:	b8 08 00 00 00       	mov    $0x8,%eax
  802528:	e8 5e fd ff ff       	call   80228b <fsipc>
}
  80252d:	c9                   	leave  
  80252e:	c3                   	ret    

0080252f <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80252f:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802533:	7e 37                	jle    80256c <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  802535:	55                   	push   %ebp
  802536:	89 e5                	mov    %esp,%ebp
  802538:	53                   	push   %ebx
  802539:	83 ec 08             	sub    $0x8,%esp
  80253c:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80253e:	ff 70 04             	pushl  0x4(%eax)
  802541:	8d 40 10             	lea    0x10(%eax),%eax
  802544:	50                   	push   %eax
  802545:	ff 33                	pushl  (%ebx)
  802547:	e8 46 fb ff ff       	call   802092 <write>
		if (result > 0)
  80254c:	83 c4 10             	add    $0x10,%esp
  80254f:	85 c0                	test   %eax,%eax
  802551:	7e 03                	jle    802556 <writebuf+0x27>
			b->result += result;
  802553:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802556:	3b 43 04             	cmp    0x4(%ebx),%eax
  802559:	74 0d                	je     802568 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80255b:	85 c0                	test   %eax,%eax
  80255d:	ba 00 00 00 00       	mov    $0x0,%edx
  802562:	0f 4f c2             	cmovg  %edx,%eax
  802565:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  802568:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80256b:	c9                   	leave  
  80256c:	f3 c3                	repz ret 

0080256e <putch>:

static void
putch(int ch, void *thunk)
{
  80256e:	55                   	push   %ebp
  80256f:	89 e5                	mov    %esp,%ebp
  802571:	53                   	push   %ebx
  802572:	83 ec 04             	sub    $0x4,%esp
  802575:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802578:	8b 53 04             	mov    0x4(%ebx),%edx
  80257b:	8d 42 01             	lea    0x1(%edx),%eax
  80257e:	89 43 04             	mov    %eax,0x4(%ebx)
  802581:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802584:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  802588:	3d 00 01 00 00       	cmp    $0x100,%eax
  80258d:	75 0e                	jne    80259d <putch+0x2f>
		writebuf(b);
  80258f:	89 d8                	mov    %ebx,%eax
  802591:	e8 99 ff ff ff       	call   80252f <writebuf>
		b->idx = 0;
  802596:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80259d:	83 c4 04             	add    $0x4,%esp
  8025a0:	5b                   	pop    %ebx
  8025a1:	5d                   	pop    %ebp
  8025a2:	c3                   	ret    

008025a3 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8025a3:	55                   	push   %ebp
  8025a4:	89 e5                	mov    %esp,%ebp
  8025a6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8025ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8025af:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8025b5:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8025bc:	00 00 00 
	b.result = 0;
  8025bf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8025c6:	00 00 00 
	b.error = 1;
  8025c9:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8025d0:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8025d3:	ff 75 10             	pushl  0x10(%ebp)
  8025d6:	ff 75 0c             	pushl  0xc(%ebp)
  8025d9:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8025df:	50                   	push   %eax
  8025e0:	68 6e 25 80 00       	push   $0x80256e
  8025e5:	e8 3b e6 ff ff       	call   800c25 <vprintfmt>
	if (b.idx > 0)
  8025ea:	83 c4 10             	add    $0x10,%esp
  8025ed:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8025f4:	7e 0b                	jle    802601 <vfprintf+0x5e>
		writebuf(&b);
  8025f6:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8025fc:	e8 2e ff ff ff       	call   80252f <writebuf>

	return (b.result ? b.result : b.error);
  802601:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802607:	85 c0                	test   %eax,%eax
  802609:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  802610:	c9                   	leave  
  802611:	c3                   	ret    

00802612 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802612:	55                   	push   %ebp
  802613:	89 e5                	mov    %esp,%ebp
  802615:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802618:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80261b:	50                   	push   %eax
  80261c:	ff 75 0c             	pushl  0xc(%ebp)
  80261f:	ff 75 08             	pushl  0x8(%ebp)
  802622:	e8 7c ff ff ff       	call   8025a3 <vfprintf>
	va_end(ap);

	return cnt;
}
  802627:	c9                   	leave  
  802628:	c3                   	ret    

00802629 <printf>:

int
printf(const char *fmt, ...)
{
  802629:	55                   	push   %ebp
  80262a:	89 e5                	mov    %esp,%ebp
  80262c:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80262f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802632:	50                   	push   %eax
  802633:	ff 75 08             	pushl  0x8(%ebp)
  802636:	6a 01                	push   $0x1
  802638:	e8 66 ff ff ff       	call   8025a3 <vfprintf>
	va_end(ap);

	return cnt;
}
  80263d:	c9                   	leave  
  80263e:	c3                   	ret    

0080263f <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80263f:	55                   	push   %ebp
  802640:	89 e5                	mov    %esp,%ebp
  802642:	57                   	push   %edi
  802643:	56                   	push   %esi
  802644:	53                   	push   %ebx
  802645:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80264b:	6a 00                	push   $0x0
  80264d:	ff 75 08             	pushl  0x8(%ebp)
  802650:	e8 36 fe ff ff       	call   80248b <open>
  802655:	89 c7                	mov    %eax,%edi
  802657:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80265d:	83 c4 10             	add    $0x10,%esp
  802660:	85 c0                	test   %eax,%eax
  802662:	0f 88 af 04 00 00    	js     802b17 <spawn+0x4d8>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802668:	83 ec 04             	sub    $0x4,%esp
  80266b:	68 00 02 00 00       	push   $0x200
  802670:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802676:	50                   	push   %eax
  802677:	57                   	push   %edi
  802678:	e8 cc f9 ff ff       	call   802049 <readn>
  80267d:	83 c4 10             	add    $0x10,%esp
  802680:	3d 00 02 00 00       	cmp    $0x200,%eax
  802685:	75 0c                	jne    802693 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  802687:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80268e:	45 4c 46 
  802691:	74 33                	je     8026c6 <spawn+0x87>
		close(fd);
  802693:	83 ec 0c             	sub    $0xc,%esp
  802696:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80269c:	e8 db f7 ff ff       	call   801e7c <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8026a1:	83 c4 0c             	add    $0xc,%esp
  8026a4:	68 7f 45 4c 46       	push   $0x464c457f
  8026a9:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8026af:	68 09 3b 80 00       	push   $0x803b09
  8026b4:	e8 35 e4 ff ff       	call   800aee <cprintf>
		return -E_NOT_EXEC;
  8026b9:	83 c4 10             	add    $0x10,%esp
  8026bc:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8026c1:	e9 b1 04 00 00       	jmp    802b77 <spawn+0x538>
  8026c6:	b8 07 00 00 00       	mov    $0x7,%eax
  8026cb:	cd 30                	int    $0x30
  8026cd:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8026d3:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8026d9:	85 c0                	test   %eax,%eax
  8026db:	0f 88 3e 04 00 00    	js     802b1f <spawn+0x4e0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8026e1:	89 c6                	mov    %eax,%esi
  8026e3:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8026e9:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8026ec:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8026f2:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8026f8:	b9 11 00 00 00       	mov    $0x11,%ecx
  8026fd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8026ff:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802705:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80270b:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  802710:	be 00 00 00 00       	mov    $0x0,%esi
  802715:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802718:	eb 13                	jmp    80272d <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80271a:	83 ec 0c             	sub    $0xc,%esp
  80271d:	50                   	push   %eax
  80271e:	e8 b9 ea ff ff       	call   8011dc <strlen>
  802723:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802727:	83 c3 01             	add    $0x1,%ebx
  80272a:	83 c4 10             	add    $0x10,%esp
  80272d:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  802734:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  802737:	85 c0                	test   %eax,%eax
  802739:	75 df                	jne    80271a <spawn+0xdb>
  80273b:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  802741:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802747:	bf 00 10 40 00       	mov    $0x401000,%edi
  80274c:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80274e:	89 fa                	mov    %edi,%edx
  802750:	83 e2 fc             	and    $0xfffffffc,%edx
  802753:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80275a:	29 c2                	sub    %eax,%edx
  80275c:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802762:	8d 42 f8             	lea    -0x8(%edx),%eax
  802765:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80276a:	0f 86 bf 03 00 00    	jbe    802b2f <spawn+0x4f0>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802770:	83 ec 04             	sub    $0x4,%esp
  802773:	6a 07                	push   $0x7
  802775:	68 00 00 40 00       	push   $0x400000
  80277a:	6a 00                	push   $0x0
  80277c:	e8 0e ef ff ff       	call   80168f <sys_page_alloc>
  802781:	83 c4 10             	add    $0x10,%esp
  802784:	85 c0                	test   %eax,%eax
  802786:	0f 88 aa 03 00 00    	js     802b36 <spawn+0x4f7>
  80278c:	be 00 00 00 00       	mov    $0x0,%esi
  802791:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802797:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80279a:	eb 30                	jmp    8027cc <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80279c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8027a2:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8027a8:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8027ab:	83 ec 08             	sub    $0x8,%esp
  8027ae:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8027b1:	57                   	push   %edi
  8027b2:	e8 5e ea ff ff       	call   801215 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8027b7:	83 c4 04             	add    $0x4,%esp
  8027ba:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8027bd:	e8 1a ea ff ff       	call   8011dc <strlen>
  8027c2:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8027c6:	83 c6 01             	add    $0x1,%esi
  8027c9:	83 c4 10             	add    $0x10,%esp
  8027cc:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8027d2:	7f c8                	jg     80279c <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8027d4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8027da:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8027e0:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8027e7:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8027ed:	74 19                	je     802808 <spawn+0x1c9>
  8027ef:	68 78 3b 80 00       	push   $0x803b78
  8027f4:	68 46 35 80 00       	push   $0x803546
  8027f9:	68 f2 00 00 00       	push   $0xf2
  8027fe:	68 23 3b 80 00       	push   $0x803b23
  802803:	e8 0d e2 ff ff       	call   800a15 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802808:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80280e:	89 f8                	mov    %edi,%eax
  802810:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802815:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  802818:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80281e:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802821:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  802827:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80282d:	83 ec 0c             	sub    $0xc,%esp
  802830:	6a 07                	push   $0x7
  802832:	68 00 d0 bf ee       	push   $0xeebfd000
  802837:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80283d:	68 00 00 40 00       	push   $0x400000
  802842:	6a 00                	push   $0x0
  802844:	e8 89 ee ff ff       	call   8016d2 <sys_page_map>
  802849:	89 c3                	mov    %eax,%ebx
  80284b:	83 c4 20             	add    $0x20,%esp
  80284e:	85 c0                	test   %eax,%eax
  802850:	0f 88 0f 03 00 00    	js     802b65 <spawn+0x526>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802856:	83 ec 08             	sub    $0x8,%esp
  802859:	68 00 00 40 00       	push   $0x400000
  80285e:	6a 00                	push   $0x0
  802860:	e8 af ee ff ff       	call   801714 <sys_page_unmap>
  802865:	89 c3                	mov    %eax,%ebx
  802867:	83 c4 10             	add    $0x10,%esp
  80286a:	85 c0                	test   %eax,%eax
  80286c:	0f 88 f3 02 00 00    	js     802b65 <spawn+0x526>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802872:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802878:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80287f:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802885:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  80288c:	00 00 00 
  80288f:	e9 88 01 00 00       	jmp    802a1c <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  802894:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80289a:	83 38 01             	cmpl   $0x1,(%eax)
  80289d:	0f 85 6b 01 00 00    	jne    802a0e <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8028a3:	89 c7                	mov    %eax,%edi
  8028a5:	8b 40 18             	mov    0x18(%eax),%eax
  8028a8:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8028ae:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8028b1:	83 f8 01             	cmp    $0x1,%eax
  8028b4:	19 c0                	sbb    %eax,%eax
  8028b6:	83 e0 fe             	and    $0xfffffffe,%eax
  8028b9:	83 c0 07             	add    $0x7,%eax
  8028bc:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8028c2:	89 f8                	mov    %edi,%eax
  8028c4:	8b 7f 04             	mov    0x4(%edi),%edi
  8028c7:	89 f9                	mov    %edi,%ecx
  8028c9:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8028cf:	8b 78 10             	mov    0x10(%eax),%edi
  8028d2:	8b 50 14             	mov    0x14(%eax),%edx
  8028d5:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  8028db:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8028de:	89 f0                	mov    %esi,%eax
  8028e0:	25 ff 0f 00 00       	and    $0xfff,%eax
  8028e5:	74 14                	je     8028fb <spawn+0x2bc>
		va -= i;
  8028e7:	29 c6                	sub    %eax,%esi
		memsz += i;
  8028e9:	01 c2                	add    %eax,%edx
  8028eb:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8028f1:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8028f3:	29 c1                	sub    %eax,%ecx
  8028f5:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8028fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  802900:	e9 f7 00 00 00       	jmp    8029fc <spawn+0x3bd>
		if (i >= filesz) {
  802905:	39 df                	cmp    %ebx,%edi
  802907:	77 27                	ja     802930 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802909:	83 ec 04             	sub    $0x4,%esp
  80290c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802912:	56                   	push   %esi
  802913:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802919:	e8 71 ed ff ff       	call   80168f <sys_page_alloc>
  80291e:	83 c4 10             	add    $0x10,%esp
  802921:	85 c0                	test   %eax,%eax
  802923:	0f 89 c7 00 00 00    	jns    8029f0 <spawn+0x3b1>
  802929:	89 c3                	mov    %eax,%ebx
  80292b:	e9 14 02 00 00       	jmp    802b44 <spawn+0x505>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802930:	83 ec 04             	sub    $0x4,%esp
  802933:	6a 07                	push   $0x7
  802935:	68 00 00 40 00       	push   $0x400000
  80293a:	6a 00                	push   $0x0
  80293c:	e8 4e ed ff ff       	call   80168f <sys_page_alloc>
  802941:	83 c4 10             	add    $0x10,%esp
  802944:	85 c0                	test   %eax,%eax
  802946:	0f 88 ee 01 00 00    	js     802b3a <spawn+0x4fb>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80294c:	83 ec 08             	sub    $0x8,%esp
  80294f:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802955:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  80295b:	50                   	push   %eax
  80295c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802962:	e8 b7 f7 ff ff       	call   80211e <seek>
  802967:	83 c4 10             	add    $0x10,%esp
  80296a:	85 c0                	test   %eax,%eax
  80296c:	0f 88 cc 01 00 00    	js     802b3e <spawn+0x4ff>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802972:	83 ec 04             	sub    $0x4,%esp
  802975:	89 f8                	mov    %edi,%eax
  802977:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  80297d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802982:	ba 00 10 00 00       	mov    $0x1000,%edx
  802987:	0f 47 c2             	cmova  %edx,%eax
  80298a:	50                   	push   %eax
  80298b:	68 00 00 40 00       	push   $0x400000
  802990:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802996:	e8 ae f6 ff ff       	call   802049 <readn>
  80299b:	83 c4 10             	add    $0x10,%esp
  80299e:	85 c0                	test   %eax,%eax
  8029a0:	0f 88 9c 01 00 00    	js     802b42 <spawn+0x503>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8029a6:	83 ec 0c             	sub    $0xc,%esp
  8029a9:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8029af:	56                   	push   %esi
  8029b0:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8029b6:	68 00 00 40 00       	push   $0x400000
  8029bb:	6a 00                	push   $0x0
  8029bd:	e8 10 ed ff ff       	call   8016d2 <sys_page_map>
  8029c2:	83 c4 20             	add    $0x20,%esp
  8029c5:	85 c0                	test   %eax,%eax
  8029c7:	79 15                	jns    8029de <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  8029c9:	50                   	push   %eax
  8029ca:	68 2f 3b 80 00       	push   $0x803b2f
  8029cf:	68 25 01 00 00       	push   $0x125
  8029d4:	68 23 3b 80 00       	push   $0x803b23
  8029d9:	e8 37 e0 ff ff       	call   800a15 <_panic>
			sys_page_unmap(0, UTEMP);
  8029de:	83 ec 08             	sub    $0x8,%esp
  8029e1:	68 00 00 40 00       	push   $0x400000
  8029e6:	6a 00                	push   $0x0
  8029e8:	e8 27 ed ff ff       	call   801714 <sys_page_unmap>
  8029ed:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8029f0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8029f6:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8029fc:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802a02:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  802a08:	0f 87 f7 fe ff ff    	ja     802905 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802a0e:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802a15:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802a1c:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802a23:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802a29:	0f 8c 65 fe ff ff    	jl     802894 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802a2f:	83 ec 0c             	sub    $0xc,%esp
  802a32:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802a38:	e8 3f f4 ff ff       	call   801e7c <close>
  802a3d:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	int r;

	// loop through all page table entries
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn) {
  802a40:	bb 00 08 00 00       	mov    $0x800,%ebx
  802a45:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		// the page table does not exist at all
		if(!(uvpd[PDX(pn*PGSIZE)] & PTE_P)) {
  802a4b:	89 d8                	mov    %ebx,%eax
  802a4d:	c1 e0 0c             	shl    $0xc,%eax
  802a50:	89 c2                	mov    %eax,%edx
  802a52:	c1 ea 16             	shr    $0x16,%edx
  802a55:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802a5c:	f6 c2 01             	test   $0x1,%dl
  802a5f:	75 08                	jne    802a69 <spawn+0x42a>
			pn += NPTENTRIES - 1;
  802a61:	81 c3 ff 03 00 00    	add    $0x3ff,%ebx
  802a67:	eb 3c                	jmp    802aa5 <spawn+0x466>
			continue;
		}

		// virtual page pn's page table entry
		pte_t pe = uvpt[pn];
  802a69:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx

		// share the page with the new environment
		if(pe & PTE_SHARE) {
  802a70:	f6 c6 04             	test   $0x4,%dh
  802a73:	74 30                	je     802aa5 <spawn+0x466>
			if((r = sys_page_map(0, (void *)(pn*PGSIZE), child, 
  802a75:	83 ec 0c             	sub    $0xc,%esp
  802a78:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  802a7e:	52                   	push   %edx
  802a7f:	50                   	push   %eax
  802a80:	56                   	push   %esi
  802a81:	50                   	push   %eax
  802a82:	6a 00                	push   $0x0
  802a84:	e8 49 ec ff ff       	call   8016d2 <sys_page_map>
  802a89:	83 c4 20             	add    $0x20,%esp
  802a8c:	85 c0                	test   %eax,%eax
  802a8e:	79 15                	jns    802aa5 <spawn+0x466>
				(void *)(pn*PGSIZE), pe&PTE_SYSCALL)) < 0)
				panic("copy_shared: %e", r);
  802a90:	50                   	push   %eax
  802a91:	68 4c 3b 80 00       	push   $0x803b4c
  802a96:	68 42 01 00 00       	push   $0x142
  802a9b:	68 23 3b 80 00       	push   $0x803b23
  802aa0:	e8 70 df ff ff       	call   800a15 <_panic>
{
	// LAB 5: Your code here.
	int r;

	// loop through all page table entries
	for(unsigned pn = UTEXT/PGSIZE; pn < (UXSTACKTOP-PGSIZE)/PGSIZE; ++pn) {
  802aa5:	83 c3 01             	add    $0x1,%ebx
  802aa8:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  802aae:	76 9b                	jbe    802a4b <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802ab0:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802ab7:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802aba:	83 ec 08             	sub    $0x8,%esp
  802abd:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802ac3:	50                   	push   %eax
  802ac4:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802aca:	e8 c9 ec ff ff       	call   801798 <sys_env_set_trapframe>
  802acf:	83 c4 10             	add    $0x10,%esp
  802ad2:	85 c0                	test   %eax,%eax
  802ad4:	79 15                	jns    802aeb <spawn+0x4ac>
		panic("sys_env_set_trapframe: %e", r);
  802ad6:	50                   	push   %eax
  802ad7:	68 5c 3b 80 00       	push   $0x803b5c
  802adc:	68 86 00 00 00       	push   $0x86
  802ae1:	68 23 3b 80 00       	push   $0x803b23
  802ae6:	e8 2a df ff ff       	call   800a15 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802aeb:	83 ec 08             	sub    $0x8,%esp
  802aee:	6a 02                	push   $0x2
  802af0:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802af6:	e8 5b ec ff ff       	call   801756 <sys_env_set_status>
  802afb:	83 c4 10             	add    $0x10,%esp
  802afe:	85 c0                	test   %eax,%eax
  802b00:	79 25                	jns    802b27 <spawn+0x4e8>
		panic("sys_env_set_status: %e", r);
  802b02:	50                   	push   %eax
  802b03:	68 e3 39 80 00       	push   $0x8039e3
  802b08:	68 89 00 00 00       	push   $0x89
  802b0d:	68 23 3b 80 00       	push   $0x803b23
  802b12:	e8 fe de ff ff       	call   800a15 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802b17:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802b1d:	eb 58                	jmp    802b77 <spawn+0x538>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802b1f:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802b25:	eb 50                	jmp    802b77 <spawn+0x538>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802b27:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802b2d:	eb 48                	jmp    802b77 <spawn+0x538>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802b2f:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802b34:	eb 41                	jmp    802b77 <spawn+0x538>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802b36:	89 c3                	mov    %eax,%ebx
  802b38:	eb 3d                	jmp    802b77 <spawn+0x538>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802b3a:	89 c3                	mov    %eax,%ebx
  802b3c:	eb 06                	jmp    802b44 <spawn+0x505>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802b3e:	89 c3                	mov    %eax,%ebx
  802b40:	eb 02                	jmp    802b44 <spawn+0x505>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802b42:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802b44:	83 ec 0c             	sub    $0xc,%esp
  802b47:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802b4d:	e8 be ea ff ff       	call   801610 <sys_env_destroy>
	close(fd);
  802b52:	83 c4 04             	add    $0x4,%esp
  802b55:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802b5b:	e8 1c f3 ff ff       	call   801e7c <close>
	return r;
  802b60:	83 c4 10             	add    $0x10,%esp
  802b63:	eb 12                	jmp    802b77 <spawn+0x538>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802b65:	83 ec 08             	sub    $0x8,%esp
  802b68:	68 00 00 40 00       	push   $0x400000
  802b6d:	6a 00                	push   $0x0
  802b6f:	e8 a0 eb ff ff       	call   801714 <sys_page_unmap>
  802b74:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802b77:	89 d8                	mov    %ebx,%eax
  802b79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b7c:	5b                   	pop    %ebx
  802b7d:	5e                   	pop    %esi
  802b7e:	5f                   	pop    %edi
  802b7f:	5d                   	pop    %ebp
  802b80:	c3                   	ret    

00802b81 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802b81:	55                   	push   %ebp
  802b82:	89 e5                	mov    %esp,%ebp
  802b84:	56                   	push   %esi
  802b85:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802b86:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802b89:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802b8e:	eb 03                	jmp    802b93 <spawnl+0x12>
		argc++;
  802b90:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802b93:	83 c2 04             	add    $0x4,%edx
  802b96:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802b9a:	75 f4                	jne    802b90 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802b9c:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802ba3:	83 e2 f0             	and    $0xfffffff0,%edx
  802ba6:	29 d4                	sub    %edx,%esp
  802ba8:	8d 54 24 03          	lea    0x3(%esp),%edx
  802bac:	c1 ea 02             	shr    $0x2,%edx
  802baf:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802bb6:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802bbb:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802bc2:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802bc9:	00 
  802bca:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  802bd1:	eb 0a                	jmp    802bdd <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802bd3:	83 c0 01             	add    $0x1,%eax
  802bd6:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802bda:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802bdd:	39 d0                	cmp    %edx,%eax
  802bdf:	75 f2                	jne    802bd3 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802be1:	83 ec 08             	sub    $0x8,%esp
  802be4:	56                   	push   %esi
  802be5:	ff 75 08             	pushl  0x8(%ebp)
  802be8:	e8 52 fa ff ff       	call   80263f <spawn>
}
  802bed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802bf0:	5b                   	pop    %ebx
  802bf1:	5e                   	pop    %esi
  802bf2:	5d                   	pop    %ebp
  802bf3:	c3                   	ret    

00802bf4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802bf4:	55                   	push   %ebp
  802bf5:	89 e5                	mov    %esp,%ebp
  802bf7:	56                   	push   %esi
  802bf8:	53                   	push   %ebx
  802bf9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802bfc:	83 ec 0c             	sub    $0xc,%esp
  802bff:	ff 75 08             	pushl  0x8(%ebp)
  802c02:	e8 e5 f0 ff ff       	call   801cec <fd2data>
  802c07:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802c09:	83 c4 08             	add    $0x8,%esp
  802c0c:	68 9e 3b 80 00       	push   $0x803b9e
  802c11:	53                   	push   %ebx
  802c12:	e8 fe e5 ff ff       	call   801215 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802c17:	8b 46 04             	mov    0x4(%esi),%eax
  802c1a:	2b 06                	sub    (%esi),%eax
  802c1c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802c22:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802c29:	00 00 00 
	stat->st_dev = &devpipe;
  802c2c:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802c33:	40 80 00 
	return 0;
}
  802c36:	b8 00 00 00 00       	mov    $0x0,%eax
  802c3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802c3e:	5b                   	pop    %ebx
  802c3f:	5e                   	pop    %esi
  802c40:	5d                   	pop    %ebp
  802c41:	c3                   	ret    

00802c42 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802c42:	55                   	push   %ebp
  802c43:	89 e5                	mov    %esp,%ebp
  802c45:	53                   	push   %ebx
  802c46:	83 ec 0c             	sub    $0xc,%esp
  802c49:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802c4c:	53                   	push   %ebx
  802c4d:	6a 00                	push   $0x0
  802c4f:	e8 c0 ea ff ff       	call   801714 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802c54:	89 1c 24             	mov    %ebx,(%esp)
  802c57:	e8 90 f0 ff ff       	call   801cec <fd2data>
  802c5c:	83 c4 08             	add    $0x8,%esp
  802c5f:	50                   	push   %eax
  802c60:	6a 00                	push   $0x0
  802c62:	e8 ad ea ff ff       	call   801714 <sys_page_unmap>
}
  802c67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c6a:	c9                   	leave  
  802c6b:	c3                   	ret    

00802c6c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802c6c:	55                   	push   %ebp
  802c6d:	89 e5                	mov    %esp,%ebp
  802c6f:	57                   	push   %edi
  802c70:	56                   	push   %esi
  802c71:	53                   	push   %ebx
  802c72:	83 ec 1c             	sub    $0x1c,%esp
  802c75:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802c78:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802c7a:	a1 24 54 80 00       	mov    0x805424,%eax
  802c7f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802c82:	83 ec 0c             	sub    $0xc,%esp
  802c85:	ff 75 e0             	pushl  -0x20(%ebp)
  802c88:	e8 99 04 00 00       	call   803126 <pageref>
  802c8d:	89 c3                	mov    %eax,%ebx
  802c8f:	89 3c 24             	mov    %edi,(%esp)
  802c92:	e8 8f 04 00 00       	call   803126 <pageref>
  802c97:	83 c4 10             	add    $0x10,%esp
  802c9a:	39 c3                	cmp    %eax,%ebx
  802c9c:	0f 94 c1             	sete   %cl
  802c9f:	0f b6 c9             	movzbl %cl,%ecx
  802ca2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802ca5:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802cab:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802cae:	39 ce                	cmp    %ecx,%esi
  802cb0:	74 1b                	je     802ccd <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802cb2:	39 c3                	cmp    %eax,%ebx
  802cb4:	75 c4                	jne    802c7a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802cb6:	8b 42 58             	mov    0x58(%edx),%eax
  802cb9:	ff 75 e4             	pushl  -0x1c(%ebp)
  802cbc:	50                   	push   %eax
  802cbd:	56                   	push   %esi
  802cbe:	68 a5 3b 80 00       	push   $0x803ba5
  802cc3:	e8 26 de ff ff       	call   800aee <cprintf>
  802cc8:	83 c4 10             	add    $0x10,%esp
  802ccb:	eb ad                	jmp    802c7a <_pipeisclosed+0xe>
	}
}
  802ccd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802cd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cd3:	5b                   	pop    %ebx
  802cd4:	5e                   	pop    %esi
  802cd5:	5f                   	pop    %edi
  802cd6:	5d                   	pop    %ebp
  802cd7:	c3                   	ret    

00802cd8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802cd8:	55                   	push   %ebp
  802cd9:	89 e5                	mov    %esp,%ebp
  802cdb:	57                   	push   %edi
  802cdc:	56                   	push   %esi
  802cdd:	53                   	push   %ebx
  802cde:	83 ec 28             	sub    $0x28,%esp
  802ce1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802ce4:	56                   	push   %esi
  802ce5:	e8 02 f0 ff ff       	call   801cec <fd2data>
  802cea:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802cec:	83 c4 10             	add    $0x10,%esp
  802cef:	bf 00 00 00 00       	mov    $0x0,%edi
  802cf4:	eb 4b                	jmp    802d41 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802cf6:	89 da                	mov    %ebx,%edx
  802cf8:	89 f0                	mov    %esi,%eax
  802cfa:	e8 6d ff ff ff       	call   802c6c <_pipeisclosed>
  802cff:	85 c0                	test   %eax,%eax
  802d01:	75 48                	jne    802d4b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802d03:	e8 68 e9 ff ff       	call   801670 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802d08:	8b 43 04             	mov    0x4(%ebx),%eax
  802d0b:	8b 0b                	mov    (%ebx),%ecx
  802d0d:	8d 51 20             	lea    0x20(%ecx),%edx
  802d10:	39 d0                	cmp    %edx,%eax
  802d12:	73 e2                	jae    802cf6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802d17:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802d1b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802d1e:	89 c2                	mov    %eax,%edx
  802d20:	c1 fa 1f             	sar    $0x1f,%edx
  802d23:	89 d1                	mov    %edx,%ecx
  802d25:	c1 e9 1b             	shr    $0x1b,%ecx
  802d28:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802d2b:	83 e2 1f             	and    $0x1f,%edx
  802d2e:	29 ca                	sub    %ecx,%edx
  802d30:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802d34:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802d38:	83 c0 01             	add    $0x1,%eax
  802d3b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802d3e:	83 c7 01             	add    $0x1,%edi
  802d41:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802d44:	75 c2                	jne    802d08 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802d46:	8b 45 10             	mov    0x10(%ebp),%eax
  802d49:	eb 05                	jmp    802d50 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802d4b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802d50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d53:	5b                   	pop    %ebx
  802d54:	5e                   	pop    %esi
  802d55:	5f                   	pop    %edi
  802d56:	5d                   	pop    %ebp
  802d57:	c3                   	ret    

00802d58 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802d58:	55                   	push   %ebp
  802d59:	89 e5                	mov    %esp,%ebp
  802d5b:	57                   	push   %edi
  802d5c:	56                   	push   %esi
  802d5d:	53                   	push   %ebx
  802d5e:	83 ec 18             	sub    $0x18,%esp
  802d61:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802d64:	57                   	push   %edi
  802d65:	e8 82 ef ff ff       	call   801cec <fd2data>
  802d6a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802d6c:	83 c4 10             	add    $0x10,%esp
  802d6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802d74:	eb 3d                	jmp    802db3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802d76:	85 db                	test   %ebx,%ebx
  802d78:	74 04                	je     802d7e <devpipe_read+0x26>
				return i;
  802d7a:	89 d8                	mov    %ebx,%eax
  802d7c:	eb 44                	jmp    802dc2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802d7e:	89 f2                	mov    %esi,%edx
  802d80:	89 f8                	mov    %edi,%eax
  802d82:	e8 e5 fe ff ff       	call   802c6c <_pipeisclosed>
  802d87:	85 c0                	test   %eax,%eax
  802d89:	75 32                	jne    802dbd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802d8b:	e8 e0 e8 ff ff       	call   801670 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802d90:	8b 06                	mov    (%esi),%eax
  802d92:	3b 46 04             	cmp    0x4(%esi),%eax
  802d95:	74 df                	je     802d76 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802d97:	99                   	cltd   
  802d98:	c1 ea 1b             	shr    $0x1b,%edx
  802d9b:	01 d0                	add    %edx,%eax
  802d9d:	83 e0 1f             	and    $0x1f,%eax
  802da0:	29 d0                	sub    %edx,%eax
  802da2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802da7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802daa:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802dad:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802db0:	83 c3 01             	add    $0x1,%ebx
  802db3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802db6:	75 d8                	jne    802d90 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802db8:	8b 45 10             	mov    0x10(%ebp),%eax
  802dbb:	eb 05                	jmp    802dc2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802dbd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802dc5:	5b                   	pop    %ebx
  802dc6:	5e                   	pop    %esi
  802dc7:	5f                   	pop    %edi
  802dc8:	5d                   	pop    %ebp
  802dc9:	c3                   	ret    

00802dca <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802dca:	55                   	push   %ebp
  802dcb:	89 e5                	mov    %esp,%ebp
  802dcd:	56                   	push   %esi
  802dce:	53                   	push   %ebx
  802dcf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802dd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802dd5:	50                   	push   %eax
  802dd6:	e8 28 ef ff ff       	call   801d03 <fd_alloc>
  802ddb:	83 c4 10             	add    $0x10,%esp
  802dde:	89 c2                	mov    %eax,%edx
  802de0:	85 c0                	test   %eax,%eax
  802de2:	0f 88 2c 01 00 00    	js     802f14 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802de8:	83 ec 04             	sub    $0x4,%esp
  802deb:	68 07 04 00 00       	push   $0x407
  802df0:	ff 75 f4             	pushl  -0xc(%ebp)
  802df3:	6a 00                	push   $0x0
  802df5:	e8 95 e8 ff ff       	call   80168f <sys_page_alloc>
  802dfa:	83 c4 10             	add    $0x10,%esp
  802dfd:	89 c2                	mov    %eax,%edx
  802dff:	85 c0                	test   %eax,%eax
  802e01:	0f 88 0d 01 00 00    	js     802f14 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802e07:	83 ec 0c             	sub    $0xc,%esp
  802e0a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802e0d:	50                   	push   %eax
  802e0e:	e8 f0 ee ff ff       	call   801d03 <fd_alloc>
  802e13:	89 c3                	mov    %eax,%ebx
  802e15:	83 c4 10             	add    $0x10,%esp
  802e18:	85 c0                	test   %eax,%eax
  802e1a:	0f 88 e2 00 00 00    	js     802f02 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802e20:	83 ec 04             	sub    $0x4,%esp
  802e23:	68 07 04 00 00       	push   $0x407
  802e28:	ff 75 f0             	pushl  -0x10(%ebp)
  802e2b:	6a 00                	push   $0x0
  802e2d:	e8 5d e8 ff ff       	call   80168f <sys_page_alloc>
  802e32:	89 c3                	mov    %eax,%ebx
  802e34:	83 c4 10             	add    $0x10,%esp
  802e37:	85 c0                	test   %eax,%eax
  802e39:	0f 88 c3 00 00 00    	js     802f02 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802e3f:	83 ec 0c             	sub    $0xc,%esp
  802e42:	ff 75 f4             	pushl  -0xc(%ebp)
  802e45:	e8 a2 ee ff ff       	call   801cec <fd2data>
  802e4a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802e4c:	83 c4 0c             	add    $0xc,%esp
  802e4f:	68 07 04 00 00       	push   $0x407
  802e54:	50                   	push   %eax
  802e55:	6a 00                	push   $0x0
  802e57:	e8 33 e8 ff ff       	call   80168f <sys_page_alloc>
  802e5c:	89 c3                	mov    %eax,%ebx
  802e5e:	83 c4 10             	add    $0x10,%esp
  802e61:	85 c0                	test   %eax,%eax
  802e63:	0f 88 89 00 00 00    	js     802ef2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802e69:	83 ec 0c             	sub    $0xc,%esp
  802e6c:	ff 75 f0             	pushl  -0x10(%ebp)
  802e6f:	e8 78 ee ff ff       	call   801cec <fd2data>
  802e74:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802e7b:	50                   	push   %eax
  802e7c:	6a 00                	push   $0x0
  802e7e:	56                   	push   %esi
  802e7f:	6a 00                	push   $0x0
  802e81:	e8 4c e8 ff ff       	call   8016d2 <sys_page_map>
  802e86:	89 c3                	mov    %eax,%ebx
  802e88:	83 c4 20             	add    $0x20,%esp
  802e8b:	85 c0                	test   %eax,%eax
  802e8d:	78 55                	js     802ee4 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802e8f:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e98:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e9d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802ea4:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802eaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ead:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802eaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802eb2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802eb9:	83 ec 0c             	sub    $0xc,%esp
  802ebc:	ff 75 f4             	pushl  -0xc(%ebp)
  802ebf:	e8 18 ee ff ff       	call   801cdc <fd2num>
  802ec4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802ec7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802ec9:	83 c4 04             	add    $0x4,%esp
  802ecc:	ff 75 f0             	pushl  -0x10(%ebp)
  802ecf:	e8 08 ee ff ff       	call   801cdc <fd2num>
  802ed4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802ed7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802eda:	83 c4 10             	add    $0x10,%esp
  802edd:	ba 00 00 00 00       	mov    $0x0,%edx
  802ee2:	eb 30                	jmp    802f14 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802ee4:	83 ec 08             	sub    $0x8,%esp
  802ee7:	56                   	push   %esi
  802ee8:	6a 00                	push   $0x0
  802eea:	e8 25 e8 ff ff       	call   801714 <sys_page_unmap>
  802eef:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802ef2:	83 ec 08             	sub    $0x8,%esp
  802ef5:	ff 75 f0             	pushl  -0x10(%ebp)
  802ef8:	6a 00                	push   $0x0
  802efa:	e8 15 e8 ff ff       	call   801714 <sys_page_unmap>
  802eff:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802f02:	83 ec 08             	sub    $0x8,%esp
  802f05:	ff 75 f4             	pushl  -0xc(%ebp)
  802f08:	6a 00                	push   $0x0
  802f0a:	e8 05 e8 ff ff       	call   801714 <sys_page_unmap>
  802f0f:	83 c4 10             	add    $0x10,%esp
  802f12:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802f14:	89 d0                	mov    %edx,%eax
  802f16:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f19:	5b                   	pop    %ebx
  802f1a:	5e                   	pop    %esi
  802f1b:	5d                   	pop    %ebp
  802f1c:	c3                   	ret    

00802f1d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802f1d:	55                   	push   %ebp
  802f1e:	89 e5                	mov    %esp,%ebp
  802f20:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802f23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f26:	50                   	push   %eax
  802f27:	ff 75 08             	pushl  0x8(%ebp)
  802f2a:	e8 23 ee ff ff       	call   801d52 <fd_lookup>
  802f2f:	83 c4 10             	add    $0x10,%esp
  802f32:	85 c0                	test   %eax,%eax
  802f34:	78 18                	js     802f4e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802f36:	83 ec 0c             	sub    $0xc,%esp
  802f39:	ff 75 f4             	pushl  -0xc(%ebp)
  802f3c:	e8 ab ed ff ff       	call   801cec <fd2data>
	return _pipeisclosed(fd, p);
  802f41:	89 c2                	mov    %eax,%edx
  802f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f46:	e8 21 fd ff ff       	call   802c6c <_pipeisclosed>
  802f4b:	83 c4 10             	add    $0x10,%esp
}
  802f4e:	c9                   	leave  
  802f4f:	c3                   	ret    

00802f50 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802f50:	55                   	push   %ebp
  802f51:	89 e5                	mov    %esp,%ebp
  802f53:	56                   	push   %esi
  802f54:	53                   	push   %ebx
  802f55:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802f58:	85 f6                	test   %esi,%esi
  802f5a:	75 16                	jne    802f72 <wait+0x22>
  802f5c:	68 bd 3b 80 00       	push   $0x803bbd
  802f61:	68 46 35 80 00       	push   $0x803546
  802f66:	6a 09                	push   $0x9
  802f68:	68 c8 3b 80 00       	push   $0x803bc8
  802f6d:	e8 a3 da ff ff       	call   800a15 <_panic>
	e = &envs[ENVX(envid)];
  802f72:	89 f3                	mov    %esi,%ebx
  802f74:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802f7a:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802f7d:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802f83:	eb 05                	jmp    802f8a <wait+0x3a>
		sys_yield();
  802f85:	e8 e6 e6 ff ff       	call   801670 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802f8a:	8b 43 48             	mov    0x48(%ebx),%eax
  802f8d:	39 c6                	cmp    %eax,%esi
  802f8f:	75 07                	jne    802f98 <wait+0x48>
  802f91:	8b 43 54             	mov    0x54(%ebx),%eax
  802f94:	85 c0                	test   %eax,%eax
  802f96:	75 ed                	jne    802f85 <wait+0x35>
		sys_yield();
}
  802f98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f9b:	5b                   	pop    %ebx
  802f9c:	5e                   	pop    %esi
  802f9d:	5d                   	pop    %ebp
  802f9e:	c3                   	ret    

00802f9f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802f9f:	55                   	push   %ebp
  802fa0:	89 e5                	mov    %esp,%ebp
  802fa2:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  802fa5:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802fac:	75 52                	jne    803000 <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  802fae:	83 ec 04             	sub    $0x4,%esp
  802fb1:	6a 07                	push   $0x7
  802fb3:	68 00 f0 bf ee       	push   $0xeebff000
  802fb8:	6a 00                	push   $0x0
  802fba:	e8 d0 e6 ff ff       	call   80168f <sys_page_alloc>
  802fbf:	83 c4 10             	add    $0x10,%esp
  802fc2:	85 c0                	test   %eax,%eax
  802fc4:	79 12                	jns    802fd8 <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  802fc6:	50                   	push   %eax
  802fc7:	68 90 39 80 00       	push   $0x803990
  802fcc:	6a 23                	push   $0x23
  802fce:	68 d3 3b 80 00       	push   $0x803bd3
  802fd3:	e8 3d da ff ff       	call   800a15 <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  802fd8:	83 ec 08             	sub    $0x8,%esp
  802fdb:	68 0a 30 80 00       	push   $0x80300a
  802fe0:	6a 00                	push   $0x0
  802fe2:	e8 f3 e7 ff ff       	call   8017da <sys_env_set_pgfault_upcall>
  802fe7:	83 c4 10             	add    $0x10,%esp
  802fea:	85 c0                	test   %eax,%eax
  802fec:	79 12                	jns    803000 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  802fee:	50                   	push   %eax
  802fef:	68 10 3a 80 00       	push   $0x803a10
  802ff4:	6a 26                	push   $0x26
  802ff6:	68 d3 3b 80 00       	push   $0x803bd3
  802ffb:	e8 15 da ff ff       	call   800a15 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  803000:	8b 45 08             	mov    0x8(%ebp),%eax
  803003:	a3 00 70 80 00       	mov    %eax,0x807000
}
  803008:	c9                   	leave  
  803009:	c3                   	ret    

0080300a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80300a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80300b:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  803010:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  803012:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  803015:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  803019:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  80301e:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  803022:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  803024:	83 c4 08             	add    $0x8,%esp
	popal 
  803027:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  803028:	83 c4 04             	add    $0x4,%esp
	popfl
  80302b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80302c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80302d:	c3                   	ret    

0080302e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80302e:	55                   	push   %ebp
  80302f:	89 e5                	mov    %esp,%ebp
  803031:	56                   	push   %esi
  803032:	53                   	push   %ebx
  803033:	8b 75 08             	mov    0x8(%ebp),%esi
  803036:	8b 45 0c             	mov    0xc(%ebp),%eax
  803039:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  80303c:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80303e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  803043:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  803046:	83 ec 0c             	sub    $0xc,%esp
  803049:	50                   	push   %eax
  80304a:	e8 f0 e7 ff ff       	call   80183f <sys_ipc_recv>
  80304f:	83 c4 10             	add    $0x10,%esp
  803052:	85 c0                	test   %eax,%eax
  803054:	79 16                	jns    80306c <ipc_recv+0x3e>
		if(from_env_store != NULL)
  803056:	85 f6                	test   %esi,%esi
  803058:	74 06                	je     803060 <ipc_recv+0x32>
			*from_env_store = 0;
  80305a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  803060:	85 db                	test   %ebx,%ebx
  803062:	74 2c                	je     803090 <ipc_recv+0x62>
			*perm_store = 0;
  803064:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80306a:	eb 24                	jmp    803090 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  80306c:	85 f6                	test   %esi,%esi
  80306e:	74 0a                	je     80307a <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  803070:	a1 24 54 80 00       	mov    0x805424,%eax
  803075:	8b 40 74             	mov    0x74(%eax),%eax
  803078:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80307a:	85 db                	test   %ebx,%ebx
  80307c:	74 0a                	je     803088 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  80307e:	a1 24 54 80 00       	mov    0x805424,%eax
  803083:	8b 40 78             	mov    0x78(%eax),%eax
  803086:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  803088:	a1 24 54 80 00       	mov    0x805424,%eax
  80308d:	8b 40 70             	mov    0x70(%eax),%eax
}
  803090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803093:	5b                   	pop    %ebx
  803094:	5e                   	pop    %esi
  803095:	5d                   	pop    %ebp
  803096:	c3                   	ret    

00803097 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  803097:	55                   	push   %ebp
  803098:	89 e5                	mov    %esp,%ebp
  80309a:	57                   	push   %edi
  80309b:	56                   	push   %esi
  80309c:	53                   	push   %ebx
  80309d:	83 ec 0c             	sub    $0xc,%esp
  8030a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8030a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8030a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8030a9:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8030ab:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8030b0:	0f 44 d8             	cmove  %eax,%ebx
  8030b3:	eb 1e                	jmp    8030d3 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  8030b5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8030b8:	74 14                	je     8030ce <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  8030ba:	83 ec 04             	sub    $0x4,%esp
  8030bd:	68 e4 3b 80 00       	push   $0x803be4
  8030c2:	6a 44                	push   $0x44
  8030c4:	68 10 3c 80 00       	push   $0x803c10
  8030c9:	e8 47 d9 ff ff       	call   800a15 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  8030ce:	e8 9d e5 ff ff       	call   801670 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8030d3:	ff 75 14             	pushl  0x14(%ebp)
  8030d6:	53                   	push   %ebx
  8030d7:	56                   	push   %esi
  8030d8:	57                   	push   %edi
  8030d9:	e8 3e e7 ff ff       	call   80181c <sys_ipc_try_send>
  8030de:	83 c4 10             	add    $0x10,%esp
  8030e1:	85 c0                	test   %eax,%eax
  8030e3:	78 d0                	js     8030b5 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  8030e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8030e8:	5b                   	pop    %ebx
  8030e9:	5e                   	pop    %esi
  8030ea:	5f                   	pop    %edi
  8030eb:	5d                   	pop    %ebp
  8030ec:	c3                   	ret    

008030ed <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8030ed:	55                   	push   %ebp
  8030ee:	89 e5                	mov    %esp,%ebp
  8030f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8030f3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8030f8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8030fb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803101:	8b 52 50             	mov    0x50(%edx),%edx
  803104:	39 ca                	cmp    %ecx,%edx
  803106:	75 0d                	jne    803115 <ipc_find_env+0x28>
			return envs[i].env_id;
  803108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80310b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  803110:	8b 40 48             	mov    0x48(%eax),%eax
  803113:	eb 0f                	jmp    803124 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  803115:	83 c0 01             	add    $0x1,%eax
  803118:	3d 00 04 00 00       	cmp    $0x400,%eax
  80311d:	75 d9                	jne    8030f8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80311f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803124:	5d                   	pop    %ebp
  803125:	c3                   	ret    

00803126 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803126:	55                   	push   %ebp
  803127:	89 e5                	mov    %esp,%ebp
  803129:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80312c:	89 d0                	mov    %edx,%eax
  80312e:	c1 e8 16             	shr    $0x16,%eax
  803131:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803138:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80313d:	f6 c1 01             	test   $0x1,%cl
  803140:	74 1d                	je     80315f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803142:	c1 ea 0c             	shr    $0xc,%edx
  803145:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80314c:	f6 c2 01             	test   $0x1,%dl
  80314f:	74 0e                	je     80315f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803151:	c1 ea 0c             	shr    $0xc,%edx
  803154:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80315b:	ef 
  80315c:	0f b7 c0             	movzwl %ax,%eax
}
  80315f:	5d                   	pop    %ebp
  803160:	c3                   	ret    
  803161:	66 90                	xchg   %ax,%ax
  803163:	66 90                	xchg   %ax,%ax
  803165:	66 90                	xchg   %ax,%ax
  803167:	66 90                	xchg   %ax,%ax
  803169:	66 90                	xchg   %ax,%ax
  80316b:	66 90                	xchg   %ax,%ax
  80316d:	66 90                	xchg   %ax,%ax
  80316f:	90                   	nop

00803170 <__udivdi3>:
  803170:	55                   	push   %ebp
  803171:	57                   	push   %edi
  803172:	56                   	push   %esi
  803173:	53                   	push   %ebx
  803174:	83 ec 1c             	sub    $0x1c,%esp
  803177:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80317b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80317f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803187:	85 f6                	test   %esi,%esi
  803189:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80318d:	89 ca                	mov    %ecx,%edx
  80318f:	89 f8                	mov    %edi,%eax
  803191:	75 3d                	jne    8031d0 <__udivdi3+0x60>
  803193:	39 cf                	cmp    %ecx,%edi
  803195:	0f 87 c5 00 00 00    	ja     803260 <__udivdi3+0xf0>
  80319b:	85 ff                	test   %edi,%edi
  80319d:	89 fd                	mov    %edi,%ebp
  80319f:	75 0b                	jne    8031ac <__udivdi3+0x3c>
  8031a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8031a6:	31 d2                	xor    %edx,%edx
  8031a8:	f7 f7                	div    %edi
  8031aa:	89 c5                	mov    %eax,%ebp
  8031ac:	89 c8                	mov    %ecx,%eax
  8031ae:	31 d2                	xor    %edx,%edx
  8031b0:	f7 f5                	div    %ebp
  8031b2:	89 c1                	mov    %eax,%ecx
  8031b4:	89 d8                	mov    %ebx,%eax
  8031b6:	89 cf                	mov    %ecx,%edi
  8031b8:	f7 f5                	div    %ebp
  8031ba:	89 c3                	mov    %eax,%ebx
  8031bc:	89 d8                	mov    %ebx,%eax
  8031be:	89 fa                	mov    %edi,%edx
  8031c0:	83 c4 1c             	add    $0x1c,%esp
  8031c3:	5b                   	pop    %ebx
  8031c4:	5e                   	pop    %esi
  8031c5:	5f                   	pop    %edi
  8031c6:	5d                   	pop    %ebp
  8031c7:	c3                   	ret    
  8031c8:	90                   	nop
  8031c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8031d0:	39 ce                	cmp    %ecx,%esi
  8031d2:	77 74                	ja     803248 <__udivdi3+0xd8>
  8031d4:	0f bd fe             	bsr    %esi,%edi
  8031d7:	83 f7 1f             	xor    $0x1f,%edi
  8031da:	0f 84 98 00 00 00    	je     803278 <__udivdi3+0x108>
  8031e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8031e5:	89 f9                	mov    %edi,%ecx
  8031e7:	89 c5                	mov    %eax,%ebp
  8031e9:	29 fb                	sub    %edi,%ebx
  8031eb:	d3 e6                	shl    %cl,%esi
  8031ed:	89 d9                	mov    %ebx,%ecx
  8031ef:	d3 ed                	shr    %cl,%ebp
  8031f1:	89 f9                	mov    %edi,%ecx
  8031f3:	d3 e0                	shl    %cl,%eax
  8031f5:	09 ee                	or     %ebp,%esi
  8031f7:	89 d9                	mov    %ebx,%ecx
  8031f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8031fd:	89 d5                	mov    %edx,%ebp
  8031ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  803203:	d3 ed                	shr    %cl,%ebp
  803205:	89 f9                	mov    %edi,%ecx
  803207:	d3 e2                	shl    %cl,%edx
  803209:	89 d9                	mov    %ebx,%ecx
  80320b:	d3 e8                	shr    %cl,%eax
  80320d:	09 c2                	or     %eax,%edx
  80320f:	89 d0                	mov    %edx,%eax
  803211:	89 ea                	mov    %ebp,%edx
  803213:	f7 f6                	div    %esi
  803215:	89 d5                	mov    %edx,%ebp
  803217:	89 c3                	mov    %eax,%ebx
  803219:	f7 64 24 0c          	mull   0xc(%esp)
  80321d:	39 d5                	cmp    %edx,%ebp
  80321f:	72 10                	jb     803231 <__udivdi3+0xc1>
  803221:	8b 74 24 08          	mov    0x8(%esp),%esi
  803225:	89 f9                	mov    %edi,%ecx
  803227:	d3 e6                	shl    %cl,%esi
  803229:	39 c6                	cmp    %eax,%esi
  80322b:	73 07                	jae    803234 <__udivdi3+0xc4>
  80322d:	39 d5                	cmp    %edx,%ebp
  80322f:	75 03                	jne    803234 <__udivdi3+0xc4>
  803231:	83 eb 01             	sub    $0x1,%ebx
  803234:	31 ff                	xor    %edi,%edi
  803236:	89 d8                	mov    %ebx,%eax
  803238:	89 fa                	mov    %edi,%edx
  80323a:	83 c4 1c             	add    $0x1c,%esp
  80323d:	5b                   	pop    %ebx
  80323e:	5e                   	pop    %esi
  80323f:	5f                   	pop    %edi
  803240:	5d                   	pop    %ebp
  803241:	c3                   	ret    
  803242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803248:	31 ff                	xor    %edi,%edi
  80324a:	31 db                	xor    %ebx,%ebx
  80324c:	89 d8                	mov    %ebx,%eax
  80324e:	89 fa                	mov    %edi,%edx
  803250:	83 c4 1c             	add    $0x1c,%esp
  803253:	5b                   	pop    %ebx
  803254:	5e                   	pop    %esi
  803255:	5f                   	pop    %edi
  803256:	5d                   	pop    %ebp
  803257:	c3                   	ret    
  803258:	90                   	nop
  803259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803260:	89 d8                	mov    %ebx,%eax
  803262:	f7 f7                	div    %edi
  803264:	31 ff                	xor    %edi,%edi
  803266:	89 c3                	mov    %eax,%ebx
  803268:	89 d8                	mov    %ebx,%eax
  80326a:	89 fa                	mov    %edi,%edx
  80326c:	83 c4 1c             	add    $0x1c,%esp
  80326f:	5b                   	pop    %ebx
  803270:	5e                   	pop    %esi
  803271:	5f                   	pop    %edi
  803272:	5d                   	pop    %ebp
  803273:	c3                   	ret    
  803274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803278:	39 ce                	cmp    %ecx,%esi
  80327a:	72 0c                	jb     803288 <__udivdi3+0x118>
  80327c:	31 db                	xor    %ebx,%ebx
  80327e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803282:	0f 87 34 ff ff ff    	ja     8031bc <__udivdi3+0x4c>
  803288:	bb 01 00 00 00       	mov    $0x1,%ebx
  80328d:	e9 2a ff ff ff       	jmp    8031bc <__udivdi3+0x4c>
  803292:	66 90                	xchg   %ax,%ax
  803294:	66 90                	xchg   %ax,%ax
  803296:	66 90                	xchg   %ax,%ax
  803298:	66 90                	xchg   %ax,%ax
  80329a:	66 90                	xchg   %ax,%ax
  80329c:	66 90                	xchg   %ax,%ax
  80329e:	66 90                	xchg   %ax,%ax

008032a0 <__umoddi3>:
  8032a0:	55                   	push   %ebp
  8032a1:	57                   	push   %edi
  8032a2:	56                   	push   %esi
  8032a3:	53                   	push   %ebx
  8032a4:	83 ec 1c             	sub    $0x1c,%esp
  8032a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8032ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8032af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8032b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8032b7:	85 d2                	test   %edx,%edx
  8032b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8032bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8032c1:	89 f3                	mov    %esi,%ebx
  8032c3:	89 3c 24             	mov    %edi,(%esp)
  8032c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8032ca:	75 1c                	jne    8032e8 <__umoddi3+0x48>
  8032cc:	39 f7                	cmp    %esi,%edi
  8032ce:	76 50                	jbe    803320 <__umoddi3+0x80>
  8032d0:	89 c8                	mov    %ecx,%eax
  8032d2:	89 f2                	mov    %esi,%edx
  8032d4:	f7 f7                	div    %edi
  8032d6:	89 d0                	mov    %edx,%eax
  8032d8:	31 d2                	xor    %edx,%edx
  8032da:	83 c4 1c             	add    $0x1c,%esp
  8032dd:	5b                   	pop    %ebx
  8032de:	5e                   	pop    %esi
  8032df:	5f                   	pop    %edi
  8032e0:	5d                   	pop    %ebp
  8032e1:	c3                   	ret    
  8032e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8032e8:	39 f2                	cmp    %esi,%edx
  8032ea:	89 d0                	mov    %edx,%eax
  8032ec:	77 52                	ja     803340 <__umoddi3+0xa0>
  8032ee:	0f bd ea             	bsr    %edx,%ebp
  8032f1:	83 f5 1f             	xor    $0x1f,%ebp
  8032f4:	75 5a                	jne    803350 <__umoddi3+0xb0>
  8032f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8032fa:	0f 82 e0 00 00 00    	jb     8033e0 <__umoddi3+0x140>
  803300:	39 0c 24             	cmp    %ecx,(%esp)
  803303:	0f 86 d7 00 00 00    	jbe    8033e0 <__umoddi3+0x140>
  803309:	8b 44 24 08          	mov    0x8(%esp),%eax
  80330d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803311:	83 c4 1c             	add    $0x1c,%esp
  803314:	5b                   	pop    %ebx
  803315:	5e                   	pop    %esi
  803316:	5f                   	pop    %edi
  803317:	5d                   	pop    %ebp
  803318:	c3                   	ret    
  803319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803320:	85 ff                	test   %edi,%edi
  803322:	89 fd                	mov    %edi,%ebp
  803324:	75 0b                	jne    803331 <__umoddi3+0x91>
  803326:	b8 01 00 00 00       	mov    $0x1,%eax
  80332b:	31 d2                	xor    %edx,%edx
  80332d:	f7 f7                	div    %edi
  80332f:	89 c5                	mov    %eax,%ebp
  803331:	89 f0                	mov    %esi,%eax
  803333:	31 d2                	xor    %edx,%edx
  803335:	f7 f5                	div    %ebp
  803337:	89 c8                	mov    %ecx,%eax
  803339:	f7 f5                	div    %ebp
  80333b:	89 d0                	mov    %edx,%eax
  80333d:	eb 99                	jmp    8032d8 <__umoddi3+0x38>
  80333f:	90                   	nop
  803340:	89 c8                	mov    %ecx,%eax
  803342:	89 f2                	mov    %esi,%edx
  803344:	83 c4 1c             	add    $0x1c,%esp
  803347:	5b                   	pop    %ebx
  803348:	5e                   	pop    %esi
  803349:	5f                   	pop    %edi
  80334a:	5d                   	pop    %ebp
  80334b:	c3                   	ret    
  80334c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803350:	8b 34 24             	mov    (%esp),%esi
  803353:	bf 20 00 00 00       	mov    $0x20,%edi
  803358:	89 e9                	mov    %ebp,%ecx
  80335a:	29 ef                	sub    %ebp,%edi
  80335c:	d3 e0                	shl    %cl,%eax
  80335e:	89 f9                	mov    %edi,%ecx
  803360:	89 f2                	mov    %esi,%edx
  803362:	d3 ea                	shr    %cl,%edx
  803364:	89 e9                	mov    %ebp,%ecx
  803366:	09 c2                	or     %eax,%edx
  803368:	89 d8                	mov    %ebx,%eax
  80336a:	89 14 24             	mov    %edx,(%esp)
  80336d:	89 f2                	mov    %esi,%edx
  80336f:	d3 e2                	shl    %cl,%edx
  803371:	89 f9                	mov    %edi,%ecx
  803373:	89 54 24 04          	mov    %edx,0x4(%esp)
  803377:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80337b:	d3 e8                	shr    %cl,%eax
  80337d:	89 e9                	mov    %ebp,%ecx
  80337f:	89 c6                	mov    %eax,%esi
  803381:	d3 e3                	shl    %cl,%ebx
  803383:	89 f9                	mov    %edi,%ecx
  803385:	89 d0                	mov    %edx,%eax
  803387:	d3 e8                	shr    %cl,%eax
  803389:	89 e9                	mov    %ebp,%ecx
  80338b:	09 d8                	or     %ebx,%eax
  80338d:	89 d3                	mov    %edx,%ebx
  80338f:	89 f2                	mov    %esi,%edx
  803391:	f7 34 24             	divl   (%esp)
  803394:	89 d6                	mov    %edx,%esi
  803396:	d3 e3                	shl    %cl,%ebx
  803398:	f7 64 24 04          	mull   0x4(%esp)
  80339c:	39 d6                	cmp    %edx,%esi
  80339e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8033a2:	89 d1                	mov    %edx,%ecx
  8033a4:	89 c3                	mov    %eax,%ebx
  8033a6:	72 08                	jb     8033b0 <__umoddi3+0x110>
  8033a8:	75 11                	jne    8033bb <__umoddi3+0x11b>
  8033aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8033ae:	73 0b                	jae    8033bb <__umoddi3+0x11b>
  8033b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8033b4:	1b 14 24             	sbb    (%esp),%edx
  8033b7:	89 d1                	mov    %edx,%ecx
  8033b9:	89 c3                	mov    %eax,%ebx
  8033bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8033bf:	29 da                	sub    %ebx,%edx
  8033c1:	19 ce                	sbb    %ecx,%esi
  8033c3:	89 f9                	mov    %edi,%ecx
  8033c5:	89 f0                	mov    %esi,%eax
  8033c7:	d3 e0                	shl    %cl,%eax
  8033c9:	89 e9                	mov    %ebp,%ecx
  8033cb:	d3 ea                	shr    %cl,%edx
  8033cd:	89 e9                	mov    %ebp,%ecx
  8033cf:	d3 ee                	shr    %cl,%esi
  8033d1:	09 d0                	or     %edx,%eax
  8033d3:	89 f2                	mov    %esi,%edx
  8033d5:	83 c4 1c             	add    $0x1c,%esp
  8033d8:	5b                   	pop    %ebx
  8033d9:	5e                   	pop    %esi
  8033da:	5f                   	pop    %edi
  8033db:	5d                   	pop    %ebp
  8033dc:	c3                   	ret    
  8033dd:	8d 76 00             	lea    0x0(%esi),%esi
  8033e0:	29 f9                	sub    %edi,%ecx
  8033e2:	19 d6                	sbb    %edx,%esi
  8033e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8033e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8033ec:	e9 18 ff ff ff       	jmp    803309 <__umoddi3+0x69>
