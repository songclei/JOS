
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 f7 05 00 00       	call   800628 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 4e 0d 00 00       	call   800d95 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 66 14 00 00       	call   8014bf <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 01 14 00 00       	call   801469 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 87 13 00 00       	call   801400 <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 00 25 80 00       	mov    $0x802500,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 0b 25 80 00       	push   $0x80250b
  8000ad:	6a 20                	push   $0x20
  8000af:	68 25 25 80 00       	push   $0x802525
  8000b4:	e8 cf 05 00 00       	call   800688 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 c0 26 80 00       	push   $0x8026c0
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 25 25 80 00       	push   $0x802525
  8000cc:	e8 b7 05 00 00       	call   800688 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 35 25 80 00       	mov    $0x802535,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 3e 25 80 00       	push   $0x80253e
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 25 25 80 00       	push   $0x802525
  8000f1:	e8 92 05 00 00       	call   800688 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 e4 26 80 00       	push   $0x8026e4
  800119:	6a 27                	push   $0x27
  80011b:	68 25 25 80 00       	push   $0x802525
  800120:	e8 63 05 00 00       	call   800688 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 56 25 80 00       	push   $0x802556
  80012d:	e8 2f 06 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 30 80 00    	call   *0x80301c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %e", r);
  80014e:	50                   	push   %eax
  80014f:	68 6a 25 80 00       	push   $0x80256a
  800154:	6a 2b                	push   $0x2b
  800156:	68 25 25 80 00       	push   $0x802525
  80015b:	e8 28 05 00 00       	call   800688 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 30 80 00    	pushl  0x803000
  800169:	e8 ee 0b 00 00       	call   800d5c <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 30 80 00    	pushl  0x803000
  80017f:	e8 d8 0b 00 00       	call   800d5c <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 14 27 80 00       	push   $0x802714
  80018f:	6a 2d                	push   $0x2d
  800191:	68 25 25 80 00       	push   $0x802525
  800196:	e8 ed 04 00 00       	call   800688 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 78 25 80 00       	push   $0x802578
  8001a3:	e8 b9 05 00 00       	call   800761 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 1c 0d 00 00       	call   800eda <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001be:	83 c4 0c             	add    $0xc,%esp
  8001c1:	68 00 02 00 00       	push   $0x200
  8001c6:	53                   	push   %ebx
  8001c7:	68 00 c0 cc cc       	push   $0xccccc000
  8001cc:	ff 15 10 30 80 00    	call   *0x803010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %e", r);
  8001d9:	50                   	push   %eax
  8001da:	68 8b 25 80 00       	push   $0x80258b
  8001df:	6a 32                	push   $0x32
  8001e1:	68 25 25 80 00       	push   $0x802525
  8001e6:	e8 9d 04 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 30 80 00    	pushl  0x803000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 3f 0c 00 00       	call   800e3f <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 99 25 80 00       	push   $0x802599
  80020f:	6a 34                	push   $0x34
  800211:	68 25 25 80 00       	push   $0x802525
  800216:	e8 6d 04 00 00       	call   800688 <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 b7 25 80 00       	push   $0x8025b7
  800223:	e8 39 05 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 30 80 00    	call   *0x803018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 ca 25 80 00       	push   $0x8025ca
  800242:	6a 38                	push   $0x38
  800244:	68 25 25 80 00       	push   $0x802525
  800249:	e8 3a 04 00 00       	call   800688 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 d9 25 80 00       	push   $0x8025d9
  800256:	e8 06 05 00 00       	call   800761 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  80025b:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800268:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80026b:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  800270:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800273:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  80027b:	83 c4 08             	add    $0x8,%esp
  80027e:	68 00 c0 cc cc       	push   $0xccccc000
  800283:	6a 00                	push   $0x0
  800285:	e8 0a 10 00 00       	call   801294 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80028a:	83 c4 0c             	add    $0xc,%esp
  80028d:	68 00 02 00 00       	push   $0x200
  800292:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800298:	50                   	push   %eax
  800299:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	ff 15 10 30 80 00    	call   *0x803010
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a9:	74 12                	je     8002bd <umain+0x23f>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002ab:	50                   	push   %eax
  8002ac:	68 3c 27 80 00       	push   $0x80273c
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 25 25 80 00       	push   $0x802525
  8002b8:	e8 cb 03 00 00       	call   800688 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 ed 25 80 00       	push   $0x8025ed
  8002c5:	e8 97 04 00 00       	call   800761 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 03 26 80 00       	mov    $0x802603,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 0d 26 80 00       	push   $0x80260d
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 25 25 80 00       	push   $0x802525
  8002ed:	e8 96 03 00 00       	call   800688 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 30 80 00    	pushl  0x803000
  800301:	e8 56 0a 00 00       	call   800d5c <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 30 80 00    	pushl  0x803000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 30 80 00    	pushl  0x803000
  800322:	e8 35 0a 00 00       	call   800d5c <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 26 26 80 00       	push   $0x802626
  800334:	6a 4b                	push   $0x4b
  800336:	68 25 25 80 00       	push   $0x802525
  80033b:	e8 48 03 00 00       	call   800688 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 35 26 80 00       	push   $0x802635
  800348:	e8 14 04 00 00       	call   800761 <cprintf>

	FVA->fd_offset = 0;
  80034d:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800354:	00 00 00 
	memset(buf, 0, sizeof buf);
  800357:	83 c4 0c             	add    $0xc,%esp
  80035a:	68 00 02 00 00       	push   $0x200
  80035f:	6a 00                	push   $0x0
  800361:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800367:	53                   	push   %ebx
  800368:	e8 6d 0b 00 00       	call   800eda <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80036d:	83 c4 0c             	add    $0xc,%esp
  800370:	68 00 02 00 00       	push   $0x200
  800375:	53                   	push   %ebx
  800376:	68 00 c0 cc cc       	push   $0xccccc000
  80037b:	ff 15 10 30 80 00    	call   *0x803010
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	79 12                	jns    80039c <umain+0x31e>
		panic("file_read after file_write: %e", r);
  80038a:	50                   	push   %eax
  80038b:	68 74 27 80 00       	push   $0x802774
  800390:	6a 51                	push   $0x51
  800392:	68 25 25 80 00       	push   $0x802525
  800397:	e8 ec 02 00 00       	call   800688 <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 30 80 00    	pushl  0x803000
  8003a5:	e8 b2 09 00 00       	call   800d5c <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 c3                	cmp    %eax,%ebx
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 94 27 80 00       	push   $0x802794
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 25 25 80 00       	push   $0x802525
  8003be:	e8 c5 02 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 30 80 00    	pushl  0x803000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 67 0a 00 00       	call   800e3f <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 cc 27 80 00       	push   $0x8027cc
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 25 25 80 00       	push   $0x802525
  8003ee:	e8 95 02 00 00       	call   800688 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 fc 27 80 00       	push   $0x8027fc
  8003fb:	e8 61 03 00 00       	call   800761 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 00 25 80 00       	push   $0x802500
  80040a:	e8 98 18 00 00       	call   801ca7 <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 11 25 80 00       	push   $0x802511
  800426:	6a 5a                	push   $0x5a
  800428:	68 25 25 80 00       	push   $0x802525
  80042d:	e8 56 02 00 00       	call   800688 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 49 26 80 00       	push   $0x802649
  80043e:	6a 5c                	push   $0x5c
  800440:	68 25 25 80 00       	push   $0x802525
  800445:	e8 3e 02 00 00       	call   800688 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 35 25 80 00       	push   $0x802535
  800454:	e8 4e 18 00 00       	call   801ca7 <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 44 25 80 00       	push   $0x802544
  800466:	6a 5f                	push   $0x5f
  800468:	68 25 25 80 00       	push   $0x802525
  80046d:	e8 16 02 00 00       	call   800688 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800472:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800475:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80047c:	75 12                	jne    800490 <umain+0x412>
  80047e:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800485:	75 09                	jne    800490 <umain+0x412>
  800487:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  80048e:	74 14                	je     8004a4 <umain+0x426>
		panic("open did not fill struct Fd correctly\n");
  800490:	83 ec 04             	sub    $0x4,%esp
  800493:	68 20 28 80 00       	push   $0x802820
  800498:	6a 62                	push   $0x62
  80049a:	68 25 25 80 00       	push   $0x802525
  80049f:	e8 e4 01 00 00       	call   800688 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 5c 25 80 00       	push   $0x80255c
  8004ac:	e8 b0 02 00 00       	call   800761 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 64 26 80 00       	push   $0x802664
  8004be:	e8 e4 17 00 00       	call   801ca7 <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 69 26 80 00       	push   $0x802669
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 25 25 80 00       	push   $0x802525
  8004d9:	e8 aa 01 00 00       	call   800688 <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 e6 09 00 00       	call   800eda <memset>
  8004f4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004fc:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800502:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800508:	83 ec 04             	sub    $0x4,%esp
  80050b:	68 00 02 00 00       	push   $0x200
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	e8 97 13 00 00       	call   8018ae <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 78 26 80 00       	push   $0x802678
  800528:	6a 6c                	push   $0x6c
  80052a:	68 25 25 80 00       	push   $0x802525
  80052f:	e8 54 01 00 00       	call   800688 <_panic>
  800534:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80053a:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80053c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800541:	75 bf                	jne    800502 <umain+0x484>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	56                   	push   %esi
  800547:	e8 4c 11 00 00       	call   801698 <close>


	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 64 26 80 00       	push   $0x802664
  800556:	e8 4c 17 00 00       	call   801ca7 <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 8a 26 80 00       	push   $0x80268a
  80056a:	6a 72                	push   $0x72
  80056c:	68 25 25 80 00       	push   $0x802525
  800571:	e8 12 01 00 00       	call   800688 <_panic>
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80057b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);

	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800581:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800587:	83 ec 04             	sub    $0x4,%esp
  80058a:	68 00 02 00 00       	push   $0x200
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	e8 cf 12 00 00       	call   801865 <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 98 26 80 00       	push   $0x802698
  8005a7:	6a 77                	push   $0x77
  8005a9:	68 25 25 80 00       	push   $0x802525
  8005ae:	e8 d5 00 00 00       	call   800688 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 48 28 80 00       	push   $0x802848
  8005c9:	6a 7a                	push   $0x7a
  8005cb:	68 25 25 80 00       	push   $0x802525
  8005d0:	e8 b3 00 00 00       	call   800688 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 74 28 80 00       	push   $0x802874
  8005e9:	6a 7d                	push   $0x7d
  8005eb:	68 25 25 80 00       	push   $0x802525
  8005f0:	e8 93 00 00 00       	call   800688 <_panic>
  8005f5:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  8005fb:	89 c3                	mov    %eax,%ebx


	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);

	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005fd:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800602:	0f 85 79 ff ff ff    	jne    800581 <umain+0x503>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800608:	83 ec 0c             	sub    $0xc,%esp
  80060b:	56                   	push   %esi
  80060c:	e8 87 10 00 00       	call   801698 <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 a9 26 80 00 	movl   $0x8026a9,(%esp)
  800618:	e8 44 01 00 00       	call   800761 <cprintf>
}
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800623:	5b                   	pop    %ebx
  800624:	5e                   	pop    %esi
  800625:	5f                   	pop    %edi
  800626:	5d                   	pop    %ebp
  800627:	c3                   	ret    

00800628 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	56                   	push   %esi
  80062c:	53                   	push   %ebx
  80062d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800630:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800633:	e8 99 0b 00 00       	call   8011d1 <sys_getenvid>
  800638:	25 ff 03 00 00       	and    $0x3ff,%eax
  80063d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800640:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800645:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80064a:	85 db                	test   %ebx,%ebx
  80064c:	7e 07                	jle    800655 <libmain+0x2d>
		binaryname = argv[0];
  80064e:	8b 06                	mov    (%esi),%eax
  800650:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	56                   	push   %esi
  800659:	53                   	push   %ebx
  80065a:	e8 1f fa ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  80065f:	e8 0a 00 00 00       	call   80066e <exit>
}
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    

0080066e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800674:	e8 4a 10 00 00       	call   8016c3 <close_all>
	sys_env_destroy(0);
  800679:	83 ec 0c             	sub    $0xc,%esp
  80067c:	6a 00                	push   $0x0
  80067e:	e8 0d 0b 00 00       	call   801190 <sys_env_destroy>
}
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	c9                   	leave  
  800687:	c3                   	ret    

00800688 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80068d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800690:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800696:	e8 36 0b 00 00       	call   8011d1 <sys_getenvid>
  80069b:	83 ec 0c             	sub    $0xc,%esp
  80069e:	ff 75 0c             	pushl  0xc(%ebp)
  8006a1:	ff 75 08             	pushl  0x8(%ebp)
  8006a4:	56                   	push   %esi
  8006a5:	50                   	push   %eax
  8006a6:	68 cc 28 80 00       	push   $0x8028cc
  8006ab:	e8 b1 00 00 00       	call   800761 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006b0:	83 c4 18             	add    $0x18,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	ff 75 10             	pushl  0x10(%ebp)
  8006b7:	e8 54 00 00 00       	call   800710 <vcprintf>
	cprintf("\n");
  8006bc:	c7 04 24 6c 2d 80 00 	movl   $0x802d6c,(%esp)
  8006c3:	e8 99 00 00 00       	call   800761 <cprintf>
  8006c8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006cb:	cc                   	int3   
  8006cc:	eb fd                	jmp    8006cb <_panic+0x43>

008006ce <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006d8:	8b 13                	mov    (%ebx),%edx
  8006da:	8d 42 01             	lea    0x1(%edx),%eax
  8006dd:	89 03                	mov    %eax,(%ebx)
  8006df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006eb:	75 1a                	jne    800707 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	68 ff 00 00 00       	push   $0xff
  8006f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8006f8:	50                   	push   %eax
  8006f9:	e8 55 0a 00 00       	call   801153 <sys_cputs>
		b->idx = 0;
  8006fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800704:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800707:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80070b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800719:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800720:	00 00 00 
	b.cnt = 0;
  800723:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80072a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	68 ce 06 80 00       	push   $0x8006ce
  80073f:	e8 54 01 00 00       	call   800898 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800744:	83 c4 08             	add    $0x8,%esp
  800747:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80074d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	e8 fa 09 00 00       	call   801153 <sys_cputs>

	return b.cnt;
}
  800759:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800767:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80076a:	50                   	push   %eax
  80076b:	ff 75 08             	pushl  0x8(%ebp)
  80076e:	e8 9d ff ff ff       	call   800710 <vcprintf>
	va_end(ap);

	return cnt;
}
  800773:	c9                   	leave  
  800774:	c3                   	ret    

00800775 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	57                   	push   %edi
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
  80077b:	83 ec 1c             	sub    $0x1c,%esp
  80077e:	89 c7                	mov    %eax,%edi
  800780:	89 d6                	mov    %edx,%esi
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
  800788:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80078e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800791:	bb 00 00 00 00       	mov    $0x0,%ebx
  800796:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800799:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80079c:	39 d3                	cmp    %edx,%ebx
  80079e:	72 05                	jb     8007a5 <printnum+0x30>
  8007a0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8007a3:	77 45                	ja     8007ea <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007a5:	83 ec 0c             	sub    $0xc,%esp
  8007a8:	ff 75 18             	pushl  0x18(%ebp)
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8007b1:	53                   	push   %ebx
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007be:	ff 75 dc             	pushl  -0x24(%ebp)
  8007c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8007c4:	e8 a7 1a 00 00       	call   802270 <__udivdi3>
  8007c9:	83 c4 18             	add    $0x18,%esp
  8007cc:	52                   	push   %edx
  8007cd:	50                   	push   %eax
  8007ce:	89 f2                	mov    %esi,%edx
  8007d0:	89 f8                	mov    %edi,%eax
  8007d2:	e8 9e ff ff ff       	call   800775 <printnum>
  8007d7:	83 c4 20             	add    $0x20,%esp
  8007da:	eb 18                	jmp    8007f4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	56                   	push   %esi
  8007e0:	ff 75 18             	pushl  0x18(%ebp)
  8007e3:	ff d7                	call   *%edi
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	eb 03                	jmp    8007ed <printnum+0x78>
  8007ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007ed:	83 eb 01             	sub    $0x1,%ebx
  8007f0:	85 db                	test   %ebx,%ebx
  8007f2:	7f e8                	jg     8007dc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	56                   	push   %esi
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800801:	ff 75 dc             	pushl  -0x24(%ebp)
  800804:	ff 75 d8             	pushl  -0x28(%ebp)
  800807:	e8 94 1b 00 00       	call   8023a0 <__umoddi3>
  80080c:	83 c4 14             	add    $0x14,%esp
  80080f:	0f be 80 ef 28 80 00 	movsbl 0x8028ef(%eax),%eax
  800816:	50                   	push   %eax
  800817:	ff d7                	call   *%edi
}
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5f                   	pop    %edi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800827:	83 fa 01             	cmp    $0x1,%edx
  80082a:	7e 0e                	jle    80083a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80082c:	8b 10                	mov    (%eax),%edx
  80082e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800831:	89 08                	mov    %ecx,(%eax)
  800833:	8b 02                	mov    (%edx),%eax
  800835:	8b 52 04             	mov    0x4(%edx),%edx
  800838:	eb 22                	jmp    80085c <getuint+0x38>
	else if (lflag)
  80083a:	85 d2                	test   %edx,%edx
  80083c:	74 10                	je     80084e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80083e:	8b 10                	mov    (%eax),%edx
  800840:	8d 4a 04             	lea    0x4(%edx),%ecx
  800843:	89 08                	mov    %ecx,(%eax)
  800845:	8b 02                	mov    (%edx),%eax
  800847:	ba 00 00 00 00       	mov    $0x0,%edx
  80084c:	eb 0e                	jmp    80085c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80084e:	8b 10                	mov    (%eax),%edx
  800850:	8d 4a 04             	lea    0x4(%edx),%ecx
  800853:	89 08                	mov    %ecx,(%eax)
  800855:	8b 02                	mov    (%edx),%eax
  800857:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800864:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800868:	8b 10                	mov    (%eax),%edx
  80086a:	3b 50 04             	cmp    0x4(%eax),%edx
  80086d:	73 0a                	jae    800879 <sprintputch+0x1b>
		*b->buf++ = ch;
  80086f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800872:	89 08                	mov    %ecx,(%eax)
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	88 02                	mov    %al,(%edx)
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800881:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800884:	50                   	push   %eax
  800885:	ff 75 10             	pushl  0x10(%ebp)
  800888:	ff 75 0c             	pushl  0xc(%ebp)
  80088b:	ff 75 08             	pushl  0x8(%ebp)
  80088e:	e8 05 00 00 00       	call   800898 <vprintfmt>
	va_end(ap);
}
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	57                   	push   %edi
  80089c:	56                   	push   %esi
  80089d:	53                   	push   %ebx
  80089e:	83 ec 2c             	sub    $0x2c,%esp
  8008a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008aa:	eb 12                	jmp    8008be <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	0f 84 38 04 00 00    	je     800cec <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	50                   	push   %eax
  8008b9:	ff d6                	call   *%esi
  8008bb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008be:	83 c7 01             	add    $0x1,%edi
  8008c1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008c5:	83 f8 25             	cmp    $0x25,%eax
  8008c8:	75 e2                	jne    8008ac <vprintfmt+0x14>
  8008ca:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8008ce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8008e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e8:	eb 07                	jmp    8008f1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8008ed:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f1:	8d 47 01             	lea    0x1(%edi),%eax
  8008f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008f7:	0f b6 07             	movzbl (%edi),%eax
  8008fa:	0f b6 c8             	movzbl %al,%ecx
  8008fd:	83 e8 23             	sub    $0x23,%eax
  800900:	3c 55                	cmp    $0x55,%al
  800902:	0f 87 c9 03 00 00    	ja     800cd1 <vprintfmt+0x439>
  800908:	0f b6 c0             	movzbl %al,%eax
  80090b:	ff 24 85 40 2a 80 00 	jmp    *0x802a40(,%eax,4)
  800912:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800915:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800919:	eb d6                	jmp    8008f1 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  80091b:	c7 05 00 40 80 00 00 	movl   $0x0,0x804000
  800922:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800925:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  800928:	eb 94                	jmp    8008be <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  80092a:	c7 05 00 40 80 00 01 	movl   $0x1,0x804000
  800931:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800934:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  800937:	eb 85                	jmp    8008be <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  800939:	c7 05 00 40 80 00 02 	movl   $0x2,0x804000
  800940:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800943:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  800946:	e9 73 ff ff ff       	jmp    8008be <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  80094b:	c7 05 00 40 80 00 03 	movl   $0x3,0x804000
  800952:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800955:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  800958:	e9 61 ff ff ff       	jmp    8008be <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  80095d:	c7 05 00 40 80 00 04 	movl   $0x4,0x804000
  800964:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800967:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  80096a:	e9 4f ff ff ff       	jmp    8008be <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80096f:	c7 05 00 40 80 00 05 	movl   $0x5,0x804000
  800976:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800979:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80097c:	e9 3d ff ff ff       	jmp    8008be <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  800981:	c7 05 00 40 80 00 06 	movl   $0x6,0x804000
  800988:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80098b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80098e:	e9 2b ff ff ff       	jmp    8008be <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  800993:	c7 05 00 40 80 00 07 	movl   $0x7,0x804000
  80099a:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80099d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8009a0:	e9 19 ff ff ff       	jmp    8008be <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  8009a5:	c7 05 00 40 80 00 08 	movl   $0x8,0x804000
  8009ac:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8009b2:	e9 07 ff ff ff       	jmp    8008be <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8009b7:	c7 05 00 40 80 00 09 	movl   $0x9,0x804000
  8009be:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8009c4:	e9 f5 fe ff ff       	jmp    8008be <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8009d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8009d7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8009db:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8009de:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8009e1:	83 fa 09             	cmp    $0x9,%edx
  8009e4:	77 3f                	ja     800a25 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8009e6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8009e9:	eb e9                	jmp    8009d4 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8009eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ee:	8d 48 04             	lea    0x4(%eax),%ecx
  8009f1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8009f4:	8b 00                	mov    (%eax),%eax
  8009f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8009fc:	eb 2d                	jmp    800a2b <vprintfmt+0x193>
  8009fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a01:	85 c0                	test   %eax,%eax
  800a03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a08:	0f 49 c8             	cmovns %eax,%ecx
  800a0b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a11:	e9 db fe ff ff       	jmp    8008f1 <vprintfmt+0x59>
  800a16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800a19:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800a20:	e9 cc fe ff ff       	jmp    8008f1 <vprintfmt+0x59>
  800a25:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a28:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800a2b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a2f:	0f 89 bc fe ff ff    	jns    8008f1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800a35:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a38:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a3b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800a42:	e9 aa fe ff ff       	jmp    8008f1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a47:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a4a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800a4d:	e9 9f fe ff ff       	jmp    8008f1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800a52:	8b 45 14             	mov    0x14(%ebp),%eax
  800a55:	8d 50 04             	lea    0x4(%eax),%edx
  800a58:	89 55 14             	mov    %edx,0x14(%ebp)
  800a5b:	83 ec 08             	sub    $0x8,%esp
  800a5e:	53                   	push   %ebx
  800a5f:	ff 30                	pushl  (%eax)
  800a61:	ff d6                	call   *%esi
			break;
  800a63:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a66:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800a69:	e9 50 fe ff ff       	jmp    8008be <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800a6e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a71:	8d 50 04             	lea    0x4(%eax),%edx
  800a74:	89 55 14             	mov    %edx,0x14(%ebp)
  800a77:	8b 00                	mov    (%eax),%eax
  800a79:	99                   	cltd   
  800a7a:	31 d0                	xor    %edx,%eax
  800a7c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a7e:	83 f8 0f             	cmp    $0xf,%eax
  800a81:	7f 0b                	jg     800a8e <vprintfmt+0x1f6>
  800a83:	8b 14 85 a0 2b 80 00 	mov    0x802ba0(,%eax,4),%edx
  800a8a:	85 d2                	test   %edx,%edx
  800a8c:	75 18                	jne    800aa6 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  800a8e:	50                   	push   %eax
  800a8f:	68 07 29 80 00       	push   $0x802907
  800a94:	53                   	push   %ebx
  800a95:	56                   	push   %esi
  800a96:	e8 e0 fd ff ff       	call   80087b <printfmt>
  800a9b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800aa1:	e9 18 fe ff ff       	jmp    8008be <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800aa6:	52                   	push   %edx
  800aa7:	68 09 2d 80 00       	push   $0x802d09
  800aac:	53                   	push   %ebx
  800aad:	56                   	push   %esi
  800aae:	e8 c8 fd ff ff       	call   80087b <printfmt>
  800ab3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ab6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ab9:	e9 00 fe ff ff       	jmp    8008be <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800abe:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac1:	8d 50 04             	lea    0x4(%eax),%edx
  800ac4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800ac9:	85 ff                	test   %edi,%edi
  800acb:	b8 00 29 80 00       	mov    $0x802900,%eax
  800ad0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800ad3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ad7:	0f 8e 94 00 00 00    	jle    800b71 <vprintfmt+0x2d9>
  800add:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800ae1:	0f 84 98 00 00 00    	je     800b7f <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  800ae7:	83 ec 08             	sub    $0x8,%esp
  800aea:	ff 75 d0             	pushl  -0x30(%ebp)
  800aed:	57                   	push   %edi
  800aee:	e8 81 02 00 00       	call   800d74 <strnlen>
  800af3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800af6:	29 c1                	sub    %eax,%ecx
  800af8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800afb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800afe:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800b02:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b05:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800b08:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b0a:	eb 0f                	jmp    800b1b <vprintfmt+0x283>
					putch(padc, putdat);
  800b0c:	83 ec 08             	sub    $0x8,%esp
  800b0f:	53                   	push   %ebx
  800b10:	ff 75 e0             	pushl  -0x20(%ebp)
  800b13:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b15:	83 ef 01             	sub    $0x1,%edi
  800b18:	83 c4 10             	add    $0x10,%esp
  800b1b:	85 ff                	test   %edi,%edi
  800b1d:	7f ed                	jg     800b0c <vprintfmt+0x274>
  800b1f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800b22:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800b25:	85 c9                	test   %ecx,%ecx
  800b27:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2c:	0f 49 c1             	cmovns %ecx,%eax
  800b2f:	29 c1                	sub    %eax,%ecx
  800b31:	89 75 08             	mov    %esi,0x8(%ebp)
  800b34:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800b37:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800b3a:	89 cb                	mov    %ecx,%ebx
  800b3c:	eb 4d                	jmp    800b8b <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b3e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b42:	74 1b                	je     800b5f <vprintfmt+0x2c7>
  800b44:	0f be c0             	movsbl %al,%eax
  800b47:	83 e8 20             	sub    $0x20,%eax
  800b4a:	83 f8 5e             	cmp    $0x5e,%eax
  800b4d:	76 10                	jbe    800b5f <vprintfmt+0x2c7>
					putch('?', putdat);
  800b4f:	83 ec 08             	sub    $0x8,%esp
  800b52:	ff 75 0c             	pushl  0xc(%ebp)
  800b55:	6a 3f                	push   $0x3f
  800b57:	ff 55 08             	call   *0x8(%ebp)
  800b5a:	83 c4 10             	add    $0x10,%esp
  800b5d:	eb 0d                	jmp    800b6c <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  800b5f:	83 ec 08             	sub    $0x8,%esp
  800b62:	ff 75 0c             	pushl  0xc(%ebp)
  800b65:	52                   	push   %edx
  800b66:	ff 55 08             	call   *0x8(%ebp)
  800b69:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b6c:	83 eb 01             	sub    $0x1,%ebx
  800b6f:	eb 1a                	jmp    800b8b <vprintfmt+0x2f3>
  800b71:	89 75 08             	mov    %esi,0x8(%ebp)
  800b74:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800b77:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800b7a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800b7d:	eb 0c                	jmp    800b8b <vprintfmt+0x2f3>
  800b7f:	89 75 08             	mov    %esi,0x8(%ebp)
  800b82:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800b85:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800b88:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800b8b:	83 c7 01             	add    $0x1,%edi
  800b8e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800b92:	0f be d0             	movsbl %al,%edx
  800b95:	85 d2                	test   %edx,%edx
  800b97:	74 23                	je     800bbc <vprintfmt+0x324>
  800b99:	85 f6                	test   %esi,%esi
  800b9b:	78 a1                	js     800b3e <vprintfmt+0x2a6>
  800b9d:	83 ee 01             	sub    $0x1,%esi
  800ba0:	79 9c                	jns    800b3e <vprintfmt+0x2a6>
  800ba2:	89 df                	mov    %ebx,%edi
  800ba4:	8b 75 08             	mov    0x8(%ebp),%esi
  800ba7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800baa:	eb 18                	jmp    800bc4 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800bac:	83 ec 08             	sub    $0x8,%esp
  800baf:	53                   	push   %ebx
  800bb0:	6a 20                	push   $0x20
  800bb2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bb4:	83 ef 01             	sub    $0x1,%edi
  800bb7:	83 c4 10             	add    $0x10,%esp
  800bba:	eb 08                	jmp    800bc4 <vprintfmt+0x32c>
  800bbc:	89 df                	mov    %ebx,%edi
  800bbe:	8b 75 08             	mov    0x8(%ebp),%esi
  800bc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bc4:	85 ff                	test   %edi,%edi
  800bc6:	7f e4                	jg     800bac <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bc8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bcb:	e9 ee fc ff ff       	jmp    8008be <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800bd0:	83 fa 01             	cmp    $0x1,%edx
  800bd3:	7e 16                	jle    800beb <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800bd5:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd8:	8d 50 08             	lea    0x8(%eax),%edx
  800bdb:	89 55 14             	mov    %edx,0x14(%ebp)
  800bde:	8b 50 04             	mov    0x4(%eax),%edx
  800be1:	8b 00                	mov    (%eax),%eax
  800be3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800be6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800be9:	eb 32                	jmp    800c1d <vprintfmt+0x385>
	else if (lflag)
  800beb:	85 d2                	test   %edx,%edx
  800bed:	74 18                	je     800c07 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  800bef:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf2:	8d 50 04             	lea    0x4(%eax),%edx
  800bf5:	89 55 14             	mov    %edx,0x14(%ebp)
  800bf8:	8b 00                	mov    (%eax),%eax
  800bfa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bfd:	89 c1                	mov    %eax,%ecx
  800bff:	c1 f9 1f             	sar    $0x1f,%ecx
  800c02:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800c05:	eb 16                	jmp    800c1d <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  800c07:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0a:	8d 50 04             	lea    0x4(%eax),%edx
  800c0d:	89 55 14             	mov    %edx,0x14(%ebp)
  800c10:	8b 00                	mov    (%eax),%eax
  800c12:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c15:	89 c1                	mov    %eax,%ecx
  800c17:	c1 f9 1f             	sar    $0x1f,%ecx
  800c1a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c1d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c20:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800c23:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800c28:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c2c:	79 6f                	jns    800c9d <vprintfmt+0x405>
				putch('-', putdat);
  800c2e:	83 ec 08             	sub    $0x8,%esp
  800c31:	53                   	push   %ebx
  800c32:	6a 2d                	push   $0x2d
  800c34:	ff d6                	call   *%esi
				num = -(long long) num;
  800c36:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c39:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800c3c:	f7 d8                	neg    %eax
  800c3e:	83 d2 00             	adc    $0x0,%edx
  800c41:	f7 da                	neg    %edx
  800c43:	83 c4 10             	add    $0x10,%esp
  800c46:	eb 55                	jmp    800c9d <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c48:	8d 45 14             	lea    0x14(%ebp),%eax
  800c4b:	e8 d4 fb ff ff       	call   800824 <getuint>
			base = 10;
  800c50:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800c55:	eb 46                	jmp    800c9d <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800c57:	8d 45 14             	lea    0x14(%ebp),%eax
  800c5a:	e8 c5 fb ff ff       	call   800824 <getuint>
			base = 8;
  800c5f:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800c64:	eb 37                	jmp    800c9d <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800c66:	83 ec 08             	sub    $0x8,%esp
  800c69:	53                   	push   %ebx
  800c6a:	6a 30                	push   $0x30
  800c6c:	ff d6                	call   *%esi
			putch('x', putdat);
  800c6e:	83 c4 08             	add    $0x8,%esp
  800c71:	53                   	push   %ebx
  800c72:	6a 78                	push   $0x78
  800c74:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800c76:	8b 45 14             	mov    0x14(%ebp),%eax
  800c79:	8d 50 04             	lea    0x4(%eax),%edx
  800c7c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800c7f:	8b 00                	mov    (%eax),%eax
  800c81:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800c86:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800c89:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800c8e:	eb 0d                	jmp    800c9d <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c90:	8d 45 14             	lea    0x14(%ebp),%eax
  800c93:	e8 8c fb ff ff       	call   800824 <getuint>
			base = 16;
  800c98:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800ca4:	51                   	push   %ecx
  800ca5:	ff 75 e0             	pushl  -0x20(%ebp)
  800ca8:	57                   	push   %edi
  800ca9:	52                   	push   %edx
  800caa:	50                   	push   %eax
  800cab:	89 da                	mov    %ebx,%edx
  800cad:	89 f0                	mov    %esi,%eax
  800caf:	e8 c1 fa ff ff       	call   800775 <printnum>
			break;
  800cb4:	83 c4 20             	add    $0x20,%esp
  800cb7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cba:	e9 ff fb ff ff       	jmp    8008be <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800cbf:	83 ec 08             	sub    $0x8,%esp
  800cc2:	53                   	push   %ebx
  800cc3:	51                   	push   %ecx
  800cc4:	ff d6                	call   *%esi
			break;
  800cc6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cc9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ccc:	e9 ed fb ff ff       	jmp    8008be <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800cd1:	83 ec 08             	sub    $0x8,%esp
  800cd4:	53                   	push   %ebx
  800cd5:	6a 25                	push   $0x25
  800cd7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800cd9:	83 c4 10             	add    $0x10,%esp
  800cdc:	eb 03                	jmp    800ce1 <vprintfmt+0x449>
  800cde:	83 ef 01             	sub    $0x1,%edi
  800ce1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ce5:	75 f7                	jne    800cde <vprintfmt+0x446>
  800ce7:	e9 d2 fb ff ff       	jmp    8008be <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800cec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	83 ec 18             	sub    $0x18,%esp
  800cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d00:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d03:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d07:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d0a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	74 26                	je     800d3b <vsnprintf+0x47>
  800d15:	85 d2                	test   %edx,%edx
  800d17:	7e 22                	jle    800d3b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d19:	ff 75 14             	pushl  0x14(%ebp)
  800d1c:	ff 75 10             	pushl  0x10(%ebp)
  800d1f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d22:	50                   	push   %eax
  800d23:	68 5e 08 80 00       	push   $0x80085e
  800d28:	e8 6b fb ff ff       	call   800898 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d30:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d36:	83 c4 10             	add    $0x10,%esp
  800d39:	eb 05                	jmp    800d40 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d3b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d40:	c9                   	leave  
  800d41:	c3                   	ret    

00800d42 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d48:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d4b:	50                   	push   %eax
  800d4c:	ff 75 10             	pushl  0x10(%ebp)
  800d4f:	ff 75 0c             	pushl  0xc(%ebp)
  800d52:	ff 75 08             	pushl  0x8(%ebp)
  800d55:	e8 9a ff ff ff       	call   800cf4 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d5a:	c9                   	leave  
  800d5b:	c3                   	ret    

00800d5c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d62:	b8 00 00 00 00       	mov    $0x0,%eax
  800d67:	eb 03                	jmp    800d6c <strlen+0x10>
		n++;
  800d69:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d6c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d70:	75 f7                	jne    800d69 <strlen+0xd>
		n++;
	return n;
}
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d82:	eb 03                	jmp    800d87 <strnlen+0x13>
		n++;
  800d84:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d87:	39 c2                	cmp    %eax,%edx
  800d89:	74 08                	je     800d93 <strnlen+0x1f>
  800d8b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800d8f:	75 f3                	jne    800d84 <strnlen+0x10>
  800d91:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	53                   	push   %ebx
  800d99:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d9f:	89 c2                	mov    %eax,%edx
  800da1:	83 c2 01             	add    $0x1,%edx
  800da4:	83 c1 01             	add    $0x1,%ecx
  800da7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800dab:	88 5a ff             	mov    %bl,-0x1(%edx)
  800dae:	84 db                	test   %bl,%bl
  800db0:	75 ef                	jne    800da1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800db2:	5b                   	pop    %ebx
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	53                   	push   %ebx
  800db9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800dbc:	53                   	push   %ebx
  800dbd:	e8 9a ff ff ff       	call   800d5c <strlen>
  800dc2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800dc5:	ff 75 0c             	pushl  0xc(%ebp)
  800dc8:	01 d8                	add    %ebx,%eax
  800dca:	50                   	push   %eax
  800dcb:	e8 c5 ff ff ff       	call   800d95 <strcpy>
	return dst;
}
  800dd0:	89 d8                	mov    %ebx,%eax
  800dd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dd5:	c9                   	leave  
  800dd6:	c3                   	ret    

00800dd7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	56                   	push   %esi
  800ddb:	53                   	push   %ebx
  800ddc:	8b 75 08             	mov    0x8(%ebp),%esi
  800ddf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de2:	89 f3                	mov    %esi,%ebx
  800de4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800de7:	89 f2                	mov    %esi,%edx
  800de9:	eb 0f                	jmp    800dfa <strncpy+0x23>
		*dst++ = *src;
  800deb:	83 c2 01             	add    $0x1,%edx
  800dee:	0f b6 01             	movzbl (%ecx),%eax
  800df1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800df4:	80 39 01             	cmpb   $0x1,(%ecx)
  800df7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dfa:	39 da                	cmp    %ebx,%edx
  800dfc:	75 ed                	jne    800deb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dfe:	89 f0                	mov    %esi,%eax
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
  800e09:	8b 75 08             	mov    0x8(%ebp),%esi
  800e0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0f:	8b 55 10             	mov    0x10(%ebp),%edx
  800e12:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e14:	85 d2                	test   %edx,%edx
  800e16:	74 21                	je     800e39 <strlcpy+0x35>
  800e18:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800e1c:	89 f2                	mov    %esi,%edx
  800e1e:	eb 09                	jmp    800e29 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800e20:	83 c2 01             	add    $0x1,%edx
  800e23:	83 c1 01             	add    $0x1,%ecx
  800e26:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e29:	39 c2                	cmp    %eax,%edx
  800e2b:	74 09                	je     800e36 <strlcpy+0x32>
  800e2d:	0f b6 19             	movzbl (%ecx),%ebx
  800e30:	84 db                	test   %bl,%bl
  800e32:	75 ec                	jne    800e20 <strlcpy+0x1c>
  800e34:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e36:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e39:	29 f0                	sub    %esi,%eax
}
  800e3b:	5b                   	pop    %ebx
  800e3c:	5e                   	pop    %esi
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e45:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e48:	eb 06                	jmp    800e50 <strcmp+0x11>
		p++, q++;
  800e4a:	83 c1 01             	add    $0x1,%ecx
  800e4d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e50:	0f b6 01             	movzbl (%ecx),%eax
  800e53:	84 c0                	test   %al,%al
  800e55:	74 04                	je     800e5b <strcmp+0x1c>
  800e57:	3a 02                	cmp    (%edx),%al
  800e59:	74 ef                	je     800e4a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e5b:	0f b6 c0             	movzbl %al,%eax
  800e5e:	0f b6 12             	movzbl (%edx),%edx
  800e61:	29 d0                	sub    %edx,%eax
}
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	53                   	push   %ebx
  800e69:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e6f:	89 c3                	mov    %eax,%ebx
  800e71:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e74:	eb 06                	jmp    800e7c <strncmp+0x17>
		n--, p++, q++;
  800e76:	83 c0 01             	add    $0x1,%eax
  800e79:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e7c:	39 d8                	cmp    %ebx,%eax
  800e7e:	74 15                	je     800e95 <strncmp+0x30>
  800e80:	0f b6 08             	movzbl (%eax),%ecx
  800e83:	84 c9                	test   %cl,%cl
  800e85:	74 04                	je     800e8b <strncmp+0x26>
  800e87:	3a 0a                	cmp    (%edx),%cl
  800e89:	74 eb                	je     800e76 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e8b:	0f b6 00             	movzbl (%eax),%eax
  800e8e:	0f b6 12             	movzbl (%edx),%edx
  800e91:	29 d0                	sub    %edx,%eax
  800e93:	eb 05                	jmp    800e9a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e95:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e9a:	5b                   	pop    %ebx
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ea7:	eb 07                	jmp    800eb0 <strchr+0x13>
		if (*s == c)
  800ea9:	38 ca                	cmp    %cl,%dl
  800eab:	74 0f                	je     800ebc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ead:	83 c0 01             	add    $0x1,%eax
  800eb0:	0f b6 10             	movzbl (%eax),%edx
  800eb3:	84 d2                	test   %dl,%dl
  800eb5:	75 f2                	jne    800ea9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800eb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ec8:	eb 03                	jmp    800ecd <strfind+0xf>
  800eca:	83 c0 01             	add    $0x1,%eax
  800ecd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ed0:	38 ca                	cmp    %cl,%dl
  800ed2:	74 04                	je     800ed8 <strfind+0x1a>
  800ed4:	84 d2                	test   %dl,%dl
  800ed6:	75 f2                	jne    800eca <strfind+0xc>
			break;
	return (char *) s;
}
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	57                   	push   %edi
  800ede:	56                   	push   %esi
  800edf:	53                   	push   %ebx
  800ee0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ee3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ee6:	85 c9                	test   %ecx,%ecx
  800ee8:	74 36                	je     800f20 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800eea:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ef0:	75 28                	jne    800f1a <memset+0x40>
  800ef2:	f6 c1 03             	test   $0x3,%cl
  800ef5:	75 23                	jne    800f1a <memset+0x40>
		c &= 0xFF;
  800ef7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800efb:	89 d3                	mov    %edx,%ebx
  800efd:	c1 e3 08             	shl    $0x8,%ebx
  800f00:	89 d6                	mov    %edx,%esi
  800f02:	c1 e6 18             	shl    $0x18,%esi
  800f05:	89 d0                	mov    %edx,%eax
  800f07:	c1 e0 10             	shl    $0x10,%eax
  800f0a:	09 f0                	or     %esi,%eax
  800f0c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f0e:	89 d8                	mov    %ebx,%eax
  800f10:	09 d0                	or     %edx,%eax
  800f12:	c1 e9 02             	shr    $0x2,%ecx
  800f15:	fc                   	cld    
  800f16:	f3 ab                	rep stos %eax,%es:(%edi)
  800f18:	eb 06                	jmp    800f20 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1d:	fc                   	cld    
  800f1e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f20:	89 f8                	mov    %edi,%eax
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f32:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f35:	39 c6                	cmp    %eax,%esi
  800f37:	73 35                	jae    800f6e <memmove+0x47>
  800f39:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f3c:	39 d0                	cmp    %edx,%eax
  800f3e:	73 2e                	jae    800f6e <memmove+0x47>
		s += n;
		d += n;
  800f40:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f43:	89 d6                	mov    %edx,%esi
  800f45:	09 fe                	or     %edi,%esi
  800f47:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f4d:	75 13                	jne    800f62 <memmove+0x3b>
  800f4f:	f6 c1 03             	test   $0x3,%cl
  800f52:	75 0e                	jne    800f62 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f54:	83 ef 04             	sub    $0x4,%edi
  800f57:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f5a:	c1 e9 02             	shr    $0x2,%ecx
  800f5d:	fd                   	std    
  800f5e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f60:	eb 09                	jmp    800f6b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f62:	83 ef 01             	sub    $0x1,%edi
  800f65:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f68:	fd                   	std    
  800f69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f6b:	fc                   	cld    
  800f6c:	eb 1d                	jmp    800f8b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f6e:	89 f2                	mov    %esi,%edx
  800f70:	09 c2                	or     %eax,%edx
  800f72:	f6 c2 03             	test   $0x3,%dl
  800f75:	75 0f                	jne    800f86 <memmove+0x5f>
  800f77:	f6 c1 03             	test   $0x3,%cl
  800f7a:	75 0a                	jne    800f86 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800f7c:	c1 e9 02             	shr    $0x2,%ecx
  800f7f:	89 c7                	mov    %eax,%edi
  800f81:	fc                   	cld    
  800f82:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f84:	eb 05                	jmp    800f8b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f86:	89 c7                	mov    %eax,%edi
  800f88:	fc                   	cld    
  800f89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f8b:	5e                   	pop    %esi
  800f8c:	5f                   	pop    %edi
  800f8d:	5d                   	pop    %ebp
  800f8e:	c3                   	ret    

00800f8f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f92:	ff 75 10             	pushl  0x10(%ebp)
  800f95:	ff 75 0c             	pushl  0xc(%ebp)
  800f98:	ff 75 08             	pushl  0x8(%ebp)
  800f9b:	e8 87 ff ff ff       	call   800f27 <memmove>
}
  800fa0:	c9                   	leave  
  800fa1:	c3                   	ret    

00800fa2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	56                   	push   %esi
  800fa6:	53                   	push   %ebx
  800fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800faa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fad:	89 c6                	mov    %eax,%esi
  800faf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fb2:	eb 1a                	jmp    800fce <memcmp+0x2c>
		if (*s1 != *s2)
  800fb4:	0f b6 08             	movzbl (%eax),%ecx
  800fb7:	0f b6 1a             	movzbl (%edx),%ebx
  800fba:	38 d9                	cmp    %bl,%cl
  800fbc:	74 0a                	je     800fc8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800fbe:	0f b6 c1             	movzbl %cl,%eax
  800fc1:	0f b6 db             	movzbl %bl,%ebx
  800fc4:	29 d8                	sub    %ebx,%eax
  800fc6:	eb 0f                	jmp    800fd7 <memcmp+0x35>
		s1++, s2++;
  800fc8:	83 c0 01             	add    $0x1,%eax
  800fcb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fce:	39 f0                	cmp    %esi,%eax
  800fd0:	75 e2                	jne    800fb4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fd7:	5b                   	pop    %ebx
  800fd8:	5e                   	pop    %esi
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    

00800fdb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	53                   	push   %ebx
  800fdf:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800fe2:	89 c1                	mov    %eax,%ecx
  800fe4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800fe7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800feb:	eb 0a                	jmp    800ff7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fed:	0f b6 10             	movzbl (%eax),%edx
  800ff0:	39 da                	cmp    %ebx,%edx
  800ff2:	74 07                	je     800ffb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ff4:	83 c0 01             	add    $0x1,%eax
  800ff7:	39 c8                	cmp    %ecx,%eax
  800ff9:	72 f2                	jb     800fed <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ffb:	5b                   	pop    %ebx
  800ffc:	5d                   	pop    %ebp
  800ffd:	c3                   	ret    

00800ffe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	57                   	push   %edi
  801002:	56                   	push   %esi
  801003:	53                   	push   %ebx
  801004:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801007:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80100a:	eb 03                	jmp    80100f <strtol+0x11>
		s++;
  80100c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80100f:	0f b6 01             	movzbl (%ecx),%eax
  801012:	3c 20                	cmp    $0x20,%al
  801014:	74 f6                	je     80100c <strtol+0xe>
  801016:	3c 09                	cmp    $0x9,%al
  801018:	74 f2                	je     80100c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80101a:	3c 2b                	cmp    $0x2b,%al
  80101c:	75 0a                	jne    801028 <strtol+0x2a>
		s++;
  80101e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801021:	bf 00 00 00 00       	mov    $0x0,%edi
  801026:	eb 11                	jmp    801039 <strtol+0x3b>
  801028:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80102d:	3c 2d                	cmp    $0x2d,%al
  80102f:	75 08                	jne    801039 <strtol+0x3b>
		s++, neg = 1;
  801031:	83 c1 01             	add    $0x1,%ecx
  801034:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801039:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80103f:	75 15                	jne    801056 <strtol+0x58>
  801041:	80 39 30             	cmpb   $0x30,(%ecx)
  801044:	75 10                	jne    801056 <strtol+0x58>
  801046:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80104a:	75 7c                	jne    8010c8 <strtol+0xca>
		s += 2, base = 16;
  80104c:	83 c1 02             	add    $0x2,%ecx
  80104f:	bb 10 00 00 00       	mov    $0x10,%ebx
  801054:	eb 16                	jmp    80106c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801056:	85 db                	test   %ebx,%ebx
  801058:	75 12                	jne    80106c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80105a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80105f:	80 39 30             	cmpb   $0x30,(%ecx)
  801062:	75 08                	jne    80106c <strtol+0x6e>
		s++, base = 8;
  801064:	83 c1 01             	add    $0x1,%ecx
  801067:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80106c:	b8 00 00 00 00       	mov    $0x0,%eax
  801071:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801074:	0f b6 11             	movzbl (%ecx),%edx
  801077:	8d 72 d0             	lea    -0x30(%edx),%esi
  80107a:	89 f3                	mov    %esi,%ebx
  80107c:	80 fb 09             	cmp    $0x9,%bl
  80107f:	77 08                	ja     801089 <strtol+0x8b>
			dig = *s - '0';
  801081:	0f be d2             	movsbl %dl,%edx
  801084:	83 ea 30             	sub    $0x30,%edx
  801087:	eb 22                	jmp    8010ab <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801089:	8d 72 9f             	lea    -0x61(%edx),%esi
  80108c:	89 f3                	mov    %esi,%ebx
  80108e:	80 fb 19             	cmp    $0x19,%bl
  801091:	77 08                	ja     80109b <strtol+0x9d>
			dig = *s - 'a' + 10;
  801093:	0f be d2             	movsbl %dl,%edx
  801096:	83 ea 57             	sub    $0x57,%edx
  801099:	eb 10                	jmp    8010ab <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80109b:	8d 72 bf             	lea    -0x41(%edx),%esi
  80109e:	89 f3                	mov    %esi,%ebx
  8010a0:	80 fb 19             	cmp    $0x19,%bl
  8010a3:	77 16                	ja     8010bb <strtol+0xbd>
			dig = *s - 'A' + 10;
  8010a5:	0f be d2             	movsbl %dl,%edx
  8010a8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8010ab:	3b 55 10             	cmp    0x10(%ebp),%edx
  8010ae:	7d 0b                	jge    8010bb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8010b0:	83 c1 01             	add    $0x1,%ecx
  8010b3:	0f af 45 10          	imul   0x10(%ebp),%eax
  8010b7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8010b9:	eb b9                	jmp    801074 <strtol+0x76>

	if (endptr)
  8010bb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010bf:	74 0d                	je     8010ce <strtol+0xd0>
		*endptr = (char *) s;
  8010c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010c4:	89 0e                	mov    %ecx,(%esi)
  8010c6:	eb 06                	jmp    8010ce <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010c8:	85 db                	test   %ebx,%ebx
  8010ca:	74 98                	je     801064 <strtol+0x66>
  8010cc:	eb 9e                	jmp    80106c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8010ce:	89 c2                	mov    %eax,%edx
  8010d0:	f7 da                	neg    %edx
  8010d2:	85 ff                	test   %edi,%edi
  8010d4:	0f 45 c2             	cmovne %edx,%eax
}
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	57                   	push   %edi
  8010e0:	56                   	push   %esi
  8010e1:	53                   	push   %ebx
  8010e2:	83 ec 04             	sub    $0x4,%esp
  8010e5:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  8010e8:	57                   	push   %edi
  8010e9:	e8 6e fc ff ff       	call   800d5c <strlen>
  8010ee:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  8010f1:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  8010f4:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  8010f9:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  8010fe:	eb 46                	jmp    801146 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  801100:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  801104:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801107:	80 f9 09             	cmp    $0x9,%cl
  80110a:	77 08                	ja     801114 <charhex_to_dec+0x38>
			num = s[i] - '0';
  80110c:	0f be d2             	movsbl %dl,%edx
  80110f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801112:	eb 27                	jmp    80113b <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  801114:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  801117:	80 f9 05             	cmp    $0x5,%cl
  80111a:	77 08                	ja     801124 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  80111c:	0f be d2             	movsbl %dl,%edx
  80111f:	8d 4a a9             	lea    -0x57(%edx),%ecx
  801122:	eb 17                	jmp    80113b <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  801124:	8d 4a bf             	lea    -0x41(%edx),%ecx
  801127:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  80112a:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  80112f:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  801133:	77 06                	ja     80113b <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  801135:	0f be d2             	movsbl %dl,%edx
  801138:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  80113b:	0f af ce             	imul   %esi,%ecx
  80113e:	01 c8                	add    %ecx,%eax
		base *= 16;
  801140:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801143:	83 eb 01             	sub    $0x1,%ebx
  801146:	83 fb 01             	cmp    $0x1,%ebx
  801149:	7f b5                	jg     801100 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  80114b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114e:	5b                   	pop    %ebx
  80114f:	5e                   	pop    %esi
  801150:	5f                   	pop    %edi
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	57                   	push   %edi
  801157:	56                   	push   %esi
  801158:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801159:	b8 00 00 00 00       	mov    $0x0,%eax
  80115e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801161:	8b 55 08             	mov    0x8(%ebp),%edx
  801164:	89 c3                	mov    %eax,%ebx
  801166:	89 c7                	mov    %eax,%edi
  801168:	89 c6                	mov    %eax,%esi
  80116a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80116c:	5b                   	pop    %ebx
  80116d:	5e                   	pop    %esi
  80116e:	5f                   	pop    %edi
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <sys_cgetc>:

int
sys_cgetc(void)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	57                   	push   %edi
  801175:	56                   	push   %esi
  801176:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801177:	ba 00 00 00 00       	mov    $0x0,%edx
  80117c:	b8 01 00 00 00       	mov    $0x1,%eax
  801181:	89 d1                	mov    %edx,%ecx
  801183:	89 d3                	mov    %edx,%ebx
  801185:	89 d7                	mov    %edx,%edi
  801187:	89 d6                	mov    %edx,%esi
  801189:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80118b:	5b                   	pop    %ebx
  80118c:	5e                   	pop    %esi
  80118d:	5f                   	pop    %edi
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	57                   	push   %edi
  801194:	56                   	push   %esi
  801195:	53                   	push   %ebx
  801196:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801199:	b9 00 00 00 00       	mov    $0x0,%ecx
  80119e:	b8 03 00 00 00       	mov    $0x3,%eax
  8011a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a6:	89 cb                	mov    %ecx,%ebx
  8011a8:	89 cf                	mov    %ecx,%edi
  8011aa:	89 ce                	mov    %ecx,%esi
  8011ac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	7e 17                	jle    8011c9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b2:	83 ec 0c             	sub    $0xc,%esp
  8011b5:	50                   	push   %eax
  8011b6:	6a 03                	push   $0x3
  8011b8:	68 ff 2b 80 00       	push   $0x802bff
  8011bd:	6a 23                	push   $0x23
  8011bf:	68 1c 2c 80 00       	push   $0x802c1c
  8011c4:	e8 bf f4 ff ff       	call   800688 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8011c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cc:	5b                   	pop    %ebx
  8011cd:	5e                   	pop    %esi
  8011ce:	5f                   	pop    %edi
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	57                   	push   %edi
  8011d5:	56                   	push   %esi
  8011d6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8011dc:	b8 02 00 00 00       	mov    $0x2,%eax
  8011e1:	89 d1                	mov    %edx,%ecx
  8011e3:	89 d3                	mov    %edx,%ebx
  8011e5:	89 d7                	mov    %edx,%edi
  8011e7:	89 d6                	mov    %edx,%esi
  8011e9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8011eb:	5b                   	pop    %ebx
  8011ec:	5e                   	pop    %esi
  8011ed:	5f                   	pop    %edi
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <sys_yield>:

void
sys_yield(void)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	57                   	push   %edi
  8011f4:	56                   	push   %esi
  8011f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8011fb:	b8 0b 00 00 00       	mov    $0xb,%eax
  801200:	89 d1                	mov    %edx,%ecx
  801202:	89 d3                	mov    %edx,%ebx
  801204:	89 d7                	mov    %edx,%edi
  801206:	89 d6                	mov    %edx,%esi
  801208:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80120a:	5b                   	pop    %ebx
  80120b:	5e                   	pop    %esi
  80120c:	5f                   	pop    %edi
  80120d:	5d                   	pop    %ebp
  80120e:	c3                   	ret    

0080120f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	57                   	push   %edi
  801213:	56                   	push   %esi
  801214:	53                   	push   %ebx
  801215:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801218:	be 00 00 00 00       	mov    $0x0,%esi
  80121d:	b8 04 00 00 00       	mov    $0x4,%eax
  801222:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801225:	8b 55 08             	mov    0x8(%ebp),%edx
  801228:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80122b:	89 f7                	mov    %esi,%edi
  80122d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80122f:	85 c0                	test   %eax,%eax
  801231:	7e 17                	jle    80124a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801233:	83 ec 0c             	sub    $0xc,%esp
  801236:	50                   	push   %eax
  801237:	6a 04                	push   $0x4
  801239:	68 ff 2b 80 00       	push   $0x802bff
  80123e:	6a 23                	push   $0x23
  801240:	68 1c 2c 80 00       	push   $0x802c1c
  801245:	e8 3e f4 ff ff       	call   800688 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80124a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	5f                   	pop    %edi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	57                   	push   %edi
  801256:	56                   	push   %esi
  801257:	53                   	push   %ebx
  801258:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80125b:	b8 05 00 00 00       	mov    $0x5,%eax
  801260:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801263:	8b 55 08             	mov    0x8(%ebp),%edx
  801266:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801269:	8b 7d 14             	mov    0x14(%ebp),%edi
  80126c:	8b 75 18             	mov    0x18(%ebp),%esi
  80126f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801271:	85 c0                	test   %eax,%eax
  801273:	7e 17                	jle    80128c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801275:	83 ec 0c             	sub    $0xc,%esp
  801278:	50                   	push   %eax
  801279:	6a 05                	push   $0x5
  80127b:	68 ff 2b 80 00       	push   $0x802bff
  801280:	6a 23                	push   $0x23
  801282:	68 1c 2c 80 00       	push   $0x802c1c
  801287:	e8 fc f3 ff ff       	call   800688 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80128c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128f:	5b                   	pop    %ebx
  801290:	5e                   	pop    %esi
  801291:	5f                   	pop    %edi
  801292:	5d                   	pop    %ebp
  801293:	c3                   	ret    

00801294 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	57                   	push   %edi
  801298:	56                   	push   %esi
  801299:	53                   	push   %ebx
  80129a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80129d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012a2:	b8 06 00 00 00       	mov    $0x6,%eax
  8012a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ad:	89 df                	mov    %ebx,%edi
  8012af:	89 de                	mov    %ebx,%esi
  8012b1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	7e 17                	jle    8012ce <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b7:	83 ec 0c             	sub    $0xc,%esp
  8012ba:	50                   	push   %eax
  8012bb:	6a 06                	push   $0x6
  8012bd:	68 ff 2b 80 00       	push   $0x802bff
  8012c2:	6a 23                	push   $0x23
  8012c4:	68 1c 2c 80 00       	push   $0x802c1c
  8012c9:	e8 ba f3 ff ff       	call   800688 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d1:	5b                   	pop    %ebx
  8012d2:	5e                   	pop    %esi
  8012d3:	5f                   	pop    %edi
  8012d4:	5d                   	pop    %ebp
  8012d5:	c3                   	ret    

008012d6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	57                   	push   %edi
  8012da:	56                   	push   %esi
  8012db:	53                   	push   %ebx
  8012dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e4:	b8 08 00 00 00       	mov    $0x8,%eax
  8012e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ef:	89 df                	mov    %ebx,%edi
  8012f1:	89 de                	mov    %ebx,%esi
  8012f3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	7e 17                	jle    801310 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012f9:	83 ec 0c             	sub    $0xc,%esp
  8012fc:	50                   	push   %eax
  8012fd:	6a 08                	push   $0x8
  8012ff:	68 ff 2b 80 00       	push   $0x802bff
  801304:	6a 23                	push   $0x23
  801306:	68 1c 2c 80 00       	push   $0x802c1c
  80130b:	e8 78 f3 ff ff       	call   800688 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801310:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801313:	5b                   	pop    %ebx
  801314:	5e                   	pop    %esi
  801315:	5f                   	pop    %edi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	57                   	push   %edi
  80131c:	56                   	push   %esi
  80131d:	53                   	push   %ebx
  80131e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801321:	bb 00 00 00 00       	mov    $0x0,%ebx
  801326:	b8 0a 00 00 00       	mov    $0xa,%eax
  80132b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132e:	8b 55 08             	mov    0x8(%ebp),%edx
  801331:	89 df                	mov    %ebx,%edi
  801333:	89 de                	mov    %ebx,%esi
  801335:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801337:	85 c0                	test   %eax,%eax
  801339:	7e 17                	jle    801352 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80133b:	83 ec 0c             	sub    $0xc,%esp
  80133e:	50                   	push   %eax
  80133f:	6a 0a                	push   $0xa
  801341:	68 ff 2b 80 00       	push   $0x802bff
  801346:	6a 23                	push   $0x23
  801348:	68 1c 2c 80 00       	push   $0x802c1c
  80134d:	e8 36 f3 ff ff       	call   800688 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801352:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801355:	5b                   	pop    %ebx
  801356:	5e                   	pop    %esi
  801357:	5f                   	pop    %edi
  801358:	5d                   	pop    %ebp
  801359:	c3                   	ret    

0080135a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	57                   	push   %edi
  80135e:	56                   	push   %esi
  80135f:	53                   	push   %ebx
  801360:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801363:	bb 00 00 00 00       	mov    $0x0,%ebx
  801368:	b8 09 00 00 00       	mov    $0x9,%eax
  80136d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801370:	8b 55 08             	mov    0x8(%ebp),%edx
  801373:	89 df                	mov    %ebx,%edi
  801375:	89 de                	mov    %ebx,%esi
  801377:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801379:	85 c0                	test   %eax,%eax
  80137b:	7e 17                	jle    801394 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80137d:	83 ec 0c             	sub    $0xc,%esp
  801380:	50                   	push   %eax
  801381:	6a 09                	push   $0x9
  801383:	68 ff 2b 80 00       	push   $0x802bff
  801388:	6a 23                	push   $0x23
  80138a:	68 1c 2c 80 00       	push   $0x802c1c
  80138f:	e8 f4 f2 ff ff       	call   800688 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801394:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801397:	5b                   	pop    %ebx
  801398:	5e                   	pop    %esi
  801399:	5f                   	pop    %edi
  80139a:	5d                   	pop    %ebp
  80139b:	c3                   	ret    

0080139c <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	57                   	push   %edi
  8013a0:	56                   	push   %esi
  8013a1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013a2:	be 00 00 00 00       	mov    $0x0,%esi
  8013a7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8013ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013af:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013b5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8013b8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8013ba:	5b                   	pop    %ebx
  8013bb:	5e                   	pop    %esi
  8013bc:	5f                   	pop    %edi
  8013bd:	5d                   	pop    %ebp
  8013be:	c3                   	ret    

008013bf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
  8013c2:	57                   	push   %edi
  8013c3:	56                   	push   %esi
  8013c4:	53                   	push   %ebx
  8013c5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013cd:	b8 0d 00 00 00       	mov    $0xd,%eax
  8013d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d5:	89 cb                	mov    %ecx,%ebx
  8013d7:	89 cf                	mov    %ecx,%edi
  8013d9:	89 ce                	mov    %ecx,%esi
  8013db:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	7e 17                	jle    8013f8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013e1:	83 ec 0c             	sub    $0xc,%esp
  8013e4:	50                   	push   %eax
  8013e5:	6a 0d                	push   $0xd
  8013e7:	68 ff 2b 80 00       	push   $0x802bff
  8013ec:	6a 23                	push   $0x23
  8013ee:	68 1c 2c 80 00       	push   $0x802c1c
  8013f3:	e8 90 f2 ff ff       	call   800688 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8013f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013fb:	5b                   	pop    %ebx
  8013fc:	5e                   	pop    %esi
  8013fd:	5f                   	pop    %edi
  8013fe:	5d                   	pop    %ebp
  8013ff:	c3                   	ret    

00801400 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	56                   	push   %esi
  801404:	53                   	push   %ebx
  801405:	8b 75 08             	mov    0x8(%ebp),%esi
  801408:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  80140e:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801410:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801415:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801418:	83 ec 0c             	sub    $0xc,%esp
  80141b:	50                   	push   %eax
  80141c:	e8 9e ff ff ff       	call   8013bf <sys_ipc_recv>
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	85 c0                	test   %eax,%eax
  801426:	79 16                	jns    80143e <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801428:	85 f6                	test   %esi,%esi
  80142a:	74 06                	je     801432 <ipc_recv+0x32>
			*from_env_store = 0;
  80142c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801432:	85 db                	test   %ebx,%ebx
  801434:	74 2c                	je     801462 <ipc_recv+0x62>
			*perm_store = 0;
  801436:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80143c:	eb 24                	jmp    801462 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  80143e:	85 f6                	test   %esi,%esi
  801440:	74 0a                	je     80144c <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801442:	a1 08 40 80 00       	mov    0x804008,%eax
  801447:	8b 40 74             	mov    0x74(%eax),%eax
  80144a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80144c:	85 db                	test   %ebx,%ebx
  80144e:	74 0a                	je     80145a <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801450:	a1 08 40 80 00       	mov    0x804008,%eax
  801455:	8b 40 78             	mov    0x78(%eax),%eax
  801458:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  80145a:	a1 08 40 80 00       	mov    0x804008,%eax
  80145f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801462:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801465:	5b                   	pop    %ebx
  801466:	5e                   	pop    %esi
  801467:	5d                   	pop    %ebp
  801468:	c3                   	ret    

00801469 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	57                   	push   %edi
  80146d:	56                   	push   %esi
  80146e:	53                   	push   %ebx
  80146f:	83 ec 0c             	sub    $0xc,%esp
  801472:	8b 7d 08             	mov    0x8(%ebp),%edi
  801475:	8b 75 0c             	mov    0xc(%ebp),%esi
  801478:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  80147b:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80147d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801482:	0f 44 d8             	cmove  %eax,%ebx
  801485:	eb 1e                	jmp    8014a5 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801487:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80148a:	74 14                	je     8014a0 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  80148c:	83 ec 04             	sub    $0x4,%esp
  80148f:	68 2c 2c 80 00       	push   $0x802c2c
  801494:	6a 44                	push   $0x44
  801496:	68 57 2c 80 00       	push   $0x802c57
  80149b:	e8 e8 f1 ff ff       	call   800688 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  8014a0:	e8 4b fd ff ff       	call   8011f0 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8014a5:	ff 75 14             	pushl  0x14(%ebp)
  8014a8:	53                   	push   %ebx
  8014a9:	56                   	push   %esi
  8014aa:	57                   	push   %edi
  8014ab:	e8 ec fe ff ff       	call   80139c <sys_ipc_try_send>
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	78 d0                	js     801487 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  8014b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ba:	5b                   	pop    %ebx
  8014bb:	5e                   	pop    %esi
  8014bc:	5f                   	pop    %edi
  8014bd:	5d                   	pop    %ebp
  8014be:	c3                   	ret    

008014bf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8014c5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8014ca:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8014cd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014d3:	8b 52 50             	mov    0x50(%edx),%edx
  8014d6:	39 ca                	cmp    %ecx,%edx
  8014d8:	75 0d                	jne    8014e7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8014da:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8014dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8014e2:	8b 40 48             	mov    0x48(%eax),%eax
  8014e5:	eb 0f                	jmp    8014f6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014e7:	83 c0 01             	add    $0x1,%eax
  8014ea:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014ef:	75 d9                	jne    8014ca <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8014f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f6:	5d                   	pop    %ebp
  8014f7:	c3                   	ret    

008014f8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fe:	05 00 00 00 30       	add    $0x30000000,%eax
  801503:	c1 e8 0c             	shr    $0xc,%eax
}
  801506:	5d                   	pop    %ebp
  801507:	c3                   	ret    

00801508 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80150b:	8b 45 08             	mov    0x8(%ebp),%eax
  80150e:	05 00 00 00 30       	add    $0x30000000,%eax
  801513:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801518:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80151d:	5d                   	pop    %ebp
  80151e:	c3                   	ret    

0080151f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801525:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	c1 ea 16             	shr    $0x16,%edx
  80152f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801536:	f6 c2 01             	test   $0x1,%dl
  801539:	74 11                	je     80154c <fd_alloc+0x2d>
  80153b:	89 c2                	mov    %eax,%edx
  80153d:	c1 ea 0c             	shr    $0xc,%edx
  801540:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801547:	f6 c2 01             	test   $0x1,%dl
  80154a:	75 09                	jne    801555 <fd_alloc+0x36>
			*fd_store = fd;
  80154c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80154e:	b8 00 00 00 00       	mov    $0x0,%eax
  801553:	eb 17                	jmp    80156c <fd_alloc+0x4d>
  801555:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80155a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80155f:	75 c9                	jne    80152a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801561:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801567:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80156c:	5d                   	pop    %ebp
  80156d:	c3                   	ret    

0080156e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801574:	83 f8 1f             	cmp    $0x1f,%eax
  801577:	77 36                	ja     8015af <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801579:	c1 e0 0c             	shl    $0xc,%eax
  80157c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801581:	89 c2                	mov    %eax,%edx
  801583:	c1 ea 16             	shr    $0x16,%edx
  801586:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80158d:	f6 c2 01             	test   $0x1,%dl
  801590:	74 24                	je     8015b6 <fd_lookup+0x48>
  801592:	89 c2                	mov    %eax,%edx
  801594:	c1 ea 0c             	shr    $0xc,%edx
  801597:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80159e:	f6 c2 01             	test   $0x1,%dl
  8015a1:	74 1a                	je     8015bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015a6:	89 02                	mov    %eax,(%edx)
	return 0;
  8015a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ad:	eb 13                	jmp    8015c2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b4:	eb 0c                	jmp    8015c2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015bb:	eb 05                	jmp    8015c2 <fd_lookup+0x54>
  8015bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015c2:	5d                   	pop    %ebp
  8015c3:	c3                   	ret    

008015c4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015cd:	ba e0 2c 80 00       	mov    $0x802ce0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8015d2:	eb 13                	jmp    8015e7 <dev_lookup+0x23>
  8015d4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8015d7:	39 08                	cmp    %ecx,(%eax)
  8015d9:	75 0c                	jne    8015e7 <dev_lookup+0x23>
			*dev = devtab[i];
  8015db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015de:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e5:	eb 2e                	jmp    801615 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015e7:	8b 02                	mov    (%edx),%eax
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	75 e7                	jne    8015d4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015ed:	a1 08 40 80 00       	mov    0x804008,%eax
  8015f2:	8b 40 48             	mov    0x48(%eax),%eax
  8015f5:	83 ec 04             	sub    $0x4,%esp
  8015f8:	51                   	push   %ecx
  8015f9:	50                   	push   %eax
  8015fa:	68 64 2c 80 00       	push   $0x802c64
  8015ff:	e8 5d f1 ff ff       	call   800761 <cprintf>
	*dev = 0;
  801604:	8b 45 0c             	mov    0xc(%ebp),%eax
  801607:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801615:	c9                   	leave  
  801616:	c3                   	ret    

00801617 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	56                   	push   %esi
  80161b:	53                   	push   %ebx
  80161c:	83 ec 10             	sub    $0x10,%esp
  80161f:	8b 75 08             	mov    0x8(%ebp),%esi
  801622:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801625:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801628:	50                   	push   %eax
  801629:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80162f:	c1 e8 0c             	shr    $0xc,%eax
  801632:	50                   	push   %eax
  801633:	e8 36 ff ff ff       	call   80156e <fd_lookup>
  801638:	83 c4 08             	add    $0x8,%esp
  80163b:	85 c0                	test   %eax,%eax
  80163d:	78 05                	js     801644 <fd_close+0x2d>
	    || fd != fd2) 
  80163f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801642:	74 0c                	je     801650 <fd_close+0x39>
		return (must_exist ? r : 0); 
  801644:	84 db                	test   %bl,%bl
  801646:	ba 00 00 00 00       	mov    $0x0,%edx
  80164b:	0f 44 c2             	cmove  %edx,%eax
  80164e:	eb 41                	jmp    801691 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801656:	50                   	push   %eax
  801657:	ff 36                	pushl  (%esi)
  801659:	e8 66 ff ff ff       	call   8015c4 <dev_lookup>
  80165e:	89 c3                	mov    %eax,%ebx
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	85 c0                	test   %eax,%eax
  801665:	78 1a                	js     801681 <fd_close+0x6a>
		if (dev->dev_close) 
  801667:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  80166d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  801672:	85 c0                	test   %eax,%eax
  801674:	74 0b                	je     801681 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801676:	83 ec 0c             	sub    $0xc,%esp
  801679:	56                   	push   %esi
  80167a:	ff d0                	call   *%eax
  80167c:	89 c3                	mov    %eax,%ebx
  80167e:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801681:	83 ec 08             	sub    $0x8,%esp
  801684:	56                   	push   %esi
  801685:	6a 00                	push   $0x0
  801687:	e8 08 fc ff ff       	call   801294 <sys_page_unmap>
	return r;
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	89 d8                	mov    %ebx,%eax
}
  801691:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801694:	5b                   	pop    %ebx
  801695:	5e                   	pop    %esi
  801696:	5d                   	pop    %ebp
  801697:	c3                   	ret    

00801698 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80169e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a1:	50                   	push   %eax
  8016a2:	ff 75 08             	pushl  0x8(%ebp)
  8016a5:	e8 c4 fe ff ff       	call   80156e <fd_lookup>
  8016aa:	83 c4 08             	add    $0x8,%esp
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	78 10                	js     8016c1 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  8016b1:	83 ec 08             	sub    $0x8,%esp
  8016b4:	6a 01                	push   $0x1
  8016b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b9:	e8 59 ff ff ff       	call   801617 <fd_close>
  8016be:	83 c4 10             	add    $0x10,%esp
}
  8016c1:	c9                   	leave  
  8016c2:	c3                   	ret    

008016c3 <close_all>:

void
close_all(void)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016ca:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016cf:	83 ec 0c             	sub    $0xc,%esp
  8016d2:	53                   	push   %ebx
  8016d3:	e8 c0 ff ff ff       	call   801698 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016d8:	83 c3 01             	add    $0x1,%ebx
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	83 fb 20             	cmp    $0x20,%ebx
  8016e1:	75 ec                	jne    8016cf <close_all+0xc>
		close(i);
}
  8016e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e6:	c9                   	leave  
  8016e7:	c3                   	ret    

008016e8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	57                   	push   %edi
  8016ec:	56                   	push   %esi
  8016ed:	53                   	push   %ebx
  8016ee:	83 ec 2c             	sub    $0x2c,%esp
  8016f1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016f4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016f7:	50                   	push   %eax
  8016f8:	ff 75 08             	pushl  0x8(%ebp)
  8016fb:	e8 6e fe ff ff       	call   80156e <fd_lookup>
  801700:	83 c4 08             	add    $0x8,%esp
  801703:	85 c0                	test   %eax,%eax
  801705:	0f 88 c1 00 00 00    	js     8017cc <dup+0xe4>
		return r;
	close(newfdnum);
  80170b:	83 ec 0c             	sub    $0xc,%esp
  80170e:	56                   	push   %esi
  80170f:	e8 84 ff ff ff       	call   801698 <close>

	newfd = INDEX2FD(newfdnum);
  801714:	89 f3                	mov    %esi,%ebx
  801716:	c1 e3 0c             	shl    $0xc,%ebx
  801719:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80171f:	83 c4 04             	add    $0x4,%esp
  801722:	ff 75 e4             	pushl  -0x1c(%ebp)
  801725:	e8 de fd ff ff       	call   801508 <fd2data>
  80172a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80172c:	89 1c 24             	mov    %ebx,(%esp)
  80172f:	e8 d4 fd ff ff       	call   801508 <fd2data>
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80173a:	89 f8                	mov    %edi,%eax
  80173c:	c1 e8 16             	shr    $0x16,%eax
  80173f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801746:	a8 01                	test   $0x1,%al
  801748:	74 37                	je     801781 <dup+0x99>
  80174a:	89 f8                	mov    %edi,%eax
  80174c:	c1 e8 0c             	shr    $0xc,%eax
  80174f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801756:	f6 c2 01             	test   $0x1,%dl
  801759:	74 26                	je     801781 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80175b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801762:	83 ec 0c             	sub    $0xc,%esp
  801765:	25 07 0e 00 00       	and    $0xe07,%eax
  80176a:	50                   	push   %eax
  80176b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80176e:	6a 00                	push   $0x0
  801770:	57                   	push   %edi
  801771:	6a 00                	push   $0x0
  801773:	e8 da fa ff ff       	call   801252 <sys_page_map>
  801778:	89 c7                	mov    %eax,%edi
  80177a:	83 c4 20             	add    $0x20,%esp
  80177d:	85 c0                	test   %eax,%eax
  80177f:	78 2e                	js     8017af <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801781:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801784:	89 d0                	mov    %edx,%eax
  801786:	c1 e8 0c             	shr    $0xc,%eax
  801789:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801790:	83 ec 0c             	sub    $0xc,%esp
  801793:	25 07 0e 00 00       	and    $0xe07,%eax
  801798:	50                   	push   %eax
  801799:	53                   	push   %ebx
  80179a:	6a 00                	push   $0x0
  80179c:	52                   	push   %edx
  80179d:	6a 00                	push   $0x0
  80179f:	e8 ae fa ff ff       	call   801252 <sys_page_map>
  8017a4:	89 c7                	mov    %eax,%edi
  8017a6:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8017a9:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017ab:	85 ff                	test   %edi,%edi
  8017ad:	79 1d                	jns    8017cc <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017af:	83 ec 08             	sub    $0x8,%esp
  8017b2:	53                   	push   %ebx
  8017b3:	6a 00                	push   $0x0
  8017b5:	e8 da fa ff ff       	call   801294 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017ba:	83 c4 08             	add    $0x8,%esp
  8017bd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8017c0:	6a 00                	push   $0x0
  8017c2:	e8 cd fa ff ff       	call   801294 <sys_page_unmap>
	return r;
  8017c7:	83 c4 10             	add    $0x10,%esp
  8017ca:	89 f8                	mov    %edi,%eax
}
  8017cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017cf:	5b                   	pop    %ebx
  8017d0:	5e                   	pop    %esi
  8017d1:	5f                   	pop    %edi
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    

008017d4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	53                   	push   %ebx
  8017d8:	83 ec 14             	sub    $0x14,%esp
  8017db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e1:	50                   	push   %eax
  8017e2:	53                   	push   %ebx
  8017e3:	e8 86 fd ff ff       	call   80156e <fd_lookup>
  8017e8:	83 c4 08             	add    $0x8,%esp
  8017eb:	89 c2                	mov    %eax,%edx
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	78 6d                	js     80185e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f1:	83 ec 08             	sub    $0x8,%esp
  8017f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f7:	50                   	push   %eax
  8017f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fb:	ff 30                	pushl  (%eax)
  8017fd:	e8 c2 fd ff ff       	call   8015c4 <dev_lookup>
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	85 c0                	test   %eax,%eax
  801807:	78 4c                	js     801855 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801809:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80180c:	8b 42 08             	mov    0x8(%edx),%eax
  80180f:	83 e0 03             	and    $0x3,%eax
  801812:	83 f8 01             	cmp    $0x1,%eax
  801815:	75 21                	jne    801838 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801817:	a1 08 40 80 00       	mov    0x804008,%eax
  80181c:	8b 40 48             	mov    0x48(%eax),%eax
  80181f:	83 ec 04             	sub    $0x4,%esp
  801822:	53                   	push   %ebx
  801823:	50                   	push   %eax
  801824:	68 a5 2c 80 00       	push   $0x802ca5
  801829:	e8 33 ef ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  80182e:	83 c4 10             	add    $0x10,%esp
  801831:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801836:	eb 26                	jmp    80185e <read+0x8a>
	}
	if (!dev->dev_read)
  801838:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183b:	8b 40 08             	mov    0x8(%eax),%eax
  80183e:	85 c0                	test   %eax,%eax
  801840:	74 17                	je     801859 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801842:	83 ec 04             	sub    $0x4,%esp
  801845:	ff 75 10             	pushl  0x10(%ebp)
  801848:	ff 75 0c             	pushl  0xc(%ebp)
  80184b:	52                   	push   %edx
  80184c:	ff d0                	call   *%eax
  80184e:	89 c2                	mov    %eax,%edx
  801850:	83 c4 10             	add    $0x10,%esp
  801853:	eb 09                	jmp    80185e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801855:	89 c2                	mov    %eax,%edx
  801857:	eb 05                	jmp    80185e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801859:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80185e:	89 d0                	mov    %edx,%eax
  801860:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801863:	c9                   	leave  
  801864:	c3                   	ret    

00801865 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	57                   	push   %edi
  801869:	56                   	push   %esi
  80186a:	53                   	push   %ebx
  80186b:	83 ec 0c             	sub    $0xc,%esp
  80186e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801871:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801874:	bb 00 00 00 00       	mov    $0x0,%ebx
  801879:	eb 21                	jmp    80189c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80187b:	83 ec 04             	sub    $0x4,%esp
  80187e:	89 f0                	mov    %esi,%eax
  801880:	29 d8                	sub    %ebx,%eax
  801882:	50                   	push   %eax
  801883:	89 d8                	mov    %ebx,%eax
  801885:	03 45 0c             	add    0xc(%ebp),%eax
  801888:	50                   	push   %eax
  801889:	57                   	push   %edi
  80188a:	e8 45 ff ff ff       	call   8017d4 <read>
		if (m < 0)
  80188f:	83 c4 10             	add    $0x10,%esp
  801892:	85 c0                	test   %eax,%eax
  801894:	78 10                	js     8018a6 <readn+0x41>
			return m;
		if (m == 0)
  801896:	85 c0                	test   %eax,%eax
  801898:	74 0a                	je     8018a4 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80189a:	01 c3                	add    %eax,%ebx
  80189c:	39 f3                	cmp    %esi,%ebx
  80189e:	72 db                	jb     80187b <readn+0x16>
  8018a0:	89 d8                	mov    %ebx,%eax
  8018a2:	eb 02                	jmp    8018a6 <readn+0x41>
  8018a4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8018a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018a9:	5b                   	pop    %ebx
  8018aa:	5e                   	pop    %esi
  8018ab:	5f                   	pop    %edi
  8018ac:	5d                   	pop    %ebp
  8018ad:	c3                   	ret    

008018ae <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	53                   	push   %ebx
  8018b2:	83 ec 14             	sub    $0x14,%esp
  8018b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018bb:	50                   	push   %eax
  8018bc:	53                   	push   %ebx
  8018bd:	e8 ac fc ff ff       	call   80156e <fd_lookup>
  8018c2:	83 c4 08             	add    $0x8,%esp
  8018c5:	89 c2                	mov    %eax,%edx
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	78 68                	js     801933 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018cb:	83 ec 08             	sub    $0x8,%esp
  8018ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d1:	50                   	push   %eax
  8018d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d5:	ff 30                	pushl  (%eax)
  8018d7:	e8 e8 fc ff ff       	call   8015c4 <dev_lookup>
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	78 47                	js     80192a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018ea:	75 21                	jne    80190d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018ec:	a1 08 40 80 00       	mov    0x804008,%eax
  8018f1:	8b 40 48             	mov    0x48(%eax),%eax
  8018f4:	83 ec 04             	sub    $0x4,%esp
  8018f7:	53                   	push   %ebx
  8018f8:	50                   	push   %eax
  8018f9:	68 c1 2c 80 00       	push   $0x802cc1
  8018fe:	e8 5e ee ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  801903:	83 c4 10             	add    $0x10,%esp
  801906:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80190b:	eb 26                	jmp    801933 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80190d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801910:	8b 52 0c             	mov    0xc(%edx),%edx
  801913:	85 d2                	test   %edx,%edx
  801915:	74 17                	je     80192e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801917:	83 ec 04             	sub    $0x4,%esp
  80191a:	ff 75 10             	pushl  0x10(%ebp)
  80191d:	ff 75 0c             	pushl  0xc(%ebp)
  801920:	50                   	push   %eax
  801921:	ff d2                	call   *%edx
  801923:	89 c2                	mov    %eax,%edx
  801925:	83 c4 10             	add    $0x10,%esp
  801928:	eb 09                	jmp    801933 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80192a:	89 c2                	mov    %eax,%edx
  80192c:	eb 05                	jmp    801933 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80192e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801933:	89 d0                	mov    %edx,%eax
  801935:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801938:	c9                   	leave  
  801939:	c3                   	ret    

0080193a <seek>:

int
seek(int fdnum, off_t offset)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801940:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801943:	50                   	push   %eax
  801944:	ff 75 08             	pushl  0x8(%ebp)
  801947:	e8 22 fc ff ff       	call   80156e <fd_lookup>
  80194c:	83 c4 08             	add    $0x8,%esp
  80194f:	85 c0                	test   %eax,%eax
  801951:	78 0e                	js     801961 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801953:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801956:	8b 55 0c             	mov    0xc(%ebp),%edx
  801959:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80195c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801961:	c9                   	leave  
  801962:	c3                   	ret    

00801963 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	53                   	push   %ebx
  801967:	83 ec 14             	sub    $0x14,%esp
  80196a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80196d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801970:	50                   	push   %eax
  801971:	53                   	push   %ebx
  801972:	e8 f7 fb ff ff       	call   80156e <fd_lookup>
  801977:	83 c4 08             	add    $0x8,%esp
  80197a:	89 c2                	mov    %eax,%edx
  80197c:	85 c0                	test   %eax,%eax
  80197e:	78 65                	js     8019e5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801980:	83 ec 08             	sub    $0x8,%esp
  801983:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801986:	50                   	push   %eax
  801987:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198a:	ff 30                	pushl  (%eax)
  80198c:	e8 33 fc ff ff       	call   8015c4 <dev_lookup>
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	85 c0                	test   %eax,%eax
  801996:	78 44                	js     8019dc <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801998:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80199b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80199f:	75 21                	jne    8019c2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019a1:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019a6:	8b 40 48             	mov    0x48(%eax),%eax
  8019a9:	83 ec 04             	sub    $0x4,%esp
  8019ac:	53                   	push   %ebx
  8019ad:	50                   	push   %eax
  8019ae:	68 84 2c 80 00       	push   $0x802c84
  8019b3:	e8 a9 ed ff ff       	call   800761 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019b8:	83 c4 10             	add    $0x10,%esp
  8019bb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8019c0:	eb 23                	jmp    8019e5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8019c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019c5:	8b 52 18             	mov    0x18(%edx),%edx
  8019c8:	85 d2                	test   %edx,%edx
  8019ca:	74 14                	je     8019e0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019cc:	83 ec 08             	sub    $0x8,%esp
  8019cf:	ff 75 0c             	pushl  0xc(%ebp)
  8019d2:	50                   	push   %eax
  8019d3:	ff d2                	call   *%edx
  8019d5:	89 c2                	mov    %eax,%edx
  8019d7:	83 c4 10             	add    $0x10,%esp
  8019da:	eb 09                	jmp    8019e5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019dc:	89 c2                	mov    %eax,%edx
  8019de:	eb 05                	jmp    8019e5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019e0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8019e5:	89 d0                	mov    %edx,%eax
  8019e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ea:	c9                   	leave  
  8019eb:	c3                   	ret    

008019ec <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
  8019ef:	53                   	push   %ebx
  8019f0:	83 ec 14             	sub    $0x14,%esp
  8019f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f9:	50                   	push   %eax
  8019fa:	ff 75 08             	pushl  0x8(%ebp)
  8019fd:	e8 6c fb ff ff       	call   80156e <fd_lookup>
  801a02:	83 c4 08             	add    $0x8,%esp
  801a05:	89 c2                	mov    %eax,%edx
  801a07:	85 c0                	test   %eax,%eax
  801a09:	78 58                	js     801a63 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a0b:	83 ec 08             	sub    $0x8,%esp
  801a0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a11:	50                   	push   %eax
  801a12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a15:	ff 30                	pushl  (%eax)
  801a17:	e8 a8 fb ff ff       	call   8015c4 <dev_lookup>
  801a1c:	83 c4 10             	add    $0x10,%esp
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	78 37                	js     801a5a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a26:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a2a:	74 32                	je     801a5e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a2c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a2f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a36:	00 00 00 
	stat->st_isdir = 0;
  801a39:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a40:	00 00 00 
	stat->st_dev = dev;
  801a43:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a49:	83 ec 08             	sub    $0x8,%esp
  801a4c:	53                   	push   %ebx
  801a4d:	ff 75 f0             	pushl  -0x10(%ebp)
  801a50:	ff 50 14             	call   *0x14(%eax)
  801a53:	89 c2                	mov    %eax,%edx
  801a55:	83 c4 10             	add    $0x10,%esp
  801a58:	eb 09                	jmp    801a63 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a5a:	89 c2                	mov    %eax,%edx
  801a5c:	eb 05                	jmp    801a63 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a5e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a63:	89 d0                	mov    %edx,%eax
  801a65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a68:	c9                   	leave  
  801a69:	c3                   	ret    

00801a6a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	56                   	push   %esi
  801a6e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a6f:	83 ec 08             	sub    $0x8,%esp
  801a72:	6a 00                	push   $0x0
  801a74:	ff 75 08             	pushl  0x8(%ebp)
  801a77:	e8 2b 02 00 00       	call   801ca7 <open>
  801a7c:	89 c3                	mov    %eax,%ebx
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	85 c0                	test   %eax,%eax
  801a83:	78 1b                	js     801aa0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a85:	83 ec 08             	sub    $0x8,%esp
  801a88:	ff 75 0c             	pushl  0xc(%ebp)
  801a8b:	50                   	push   %eax
  801a8c:	e8 5b ff ff ff       	call   8019ec <fstat>
  801a91:	89 c6                	mov    %eax,%esi
	close(fd);
  801a93:	89 1c 24             	mov    %ebx,(%esp)
  801a96:	e8 fd fb ff ff       	call   801698 <close>
	return r;
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	89 f0                	mov    %esi,%eax
}
  801aa0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa3:	5b                   	pop    %ebx
  801aa4:	5e                   	pop    %esi
  801aa5:	5d                   	pop    %ebp
  801aa6:	c3                   	ret    

00801aa7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	56                   	push   %esi
  801aab:	53                   	push   %ebx
  801aac:	89 c6                	mov    %eax,%esi
  801aae:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801ab0:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801ab7:	75 12                	jne    801acb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ab9:	83 ec 0c             	sub    $0xc,%esp
  801abc:	6a 01                	push   $0x1
  801abe:	e8 fc f9 ff ff       	call   8014bf <ipc_find_env>
  801ac3:	a3 04 40 80 00       	mov    %eax,0x804004
  801ac8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801acb:	6a 07                	push   $0x7
  801acd:	68 00 50 80 00       	push   $0x805000
  801ad2:	56                   	push   %esi
  801ad3:	ff 35 04 40 80 00    	pushl  0x804004
  801ad9:	e8 8b f9 ff ff       	call   801469 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801ade:	83 c4 0c             	add    $0xc,%esp
  801ae1:	6a 00                	push   $0x0
  801ae3:	53                   	push   %ebx
  801ae4:	6a 00                	push   $0x0
  801ae6:	e8 15 f9 ff ff       	call   801400 <ipc_recv>
}
  801aeb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aee:	5b                   	pop    %ebx
  801aef:	5e                   	pop    %esi
  801af0:	5d                   	pop    %ebp
  801af1:	c3                   	ret    

00801af2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801af8:	8b 45 08             	mov    0x8(%ebp),%eax
  801afb:	8b 40 0c             	mov    0xc(%eax),%eax
  801afe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801b03:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b06:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b10:	b8 02 00 00 00       	mov    $0x2,%eax
  801b15:	e8 8d ff ff ff       	call   801aa7 <fsipc>
}
  801b1a:	c9                   	leave  
  801b1b:	c3                   	ret    

00801b1c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b22:	8b 45 08             	mov    0x8(%ebp),%eax
  801b25:	8b 40 0c             	mov    0xc(%eax),%eax
  801b28:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b32:	b8 06 00 00 00       	mov    $0x6,%eax
  801b37:	e8 6b ff ff ff       	call   801aa7 <fsipc>
}
  801b3c:	c9                   	leave  
  801b3d:	c3                   	ret    

00801b3e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	53                   	push   %ebx
  801b42:	83 ec 04             	sub    $0x4,%esp
  801b45:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b48:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b4e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b53:	ba 00 00 00 00       	mov    $0x0,%edx
  801b58:	b8 05 00 00 00       	mov    $0x5,%eax
  801b5d:	e8 45 ff ff ff       	call   801aa7 <fsipc>
  801b62:	85 c0                	test   %eax,%eax
  801b64:	78 2c                	js     801b92 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b66:	83 ec 08             	sub    $0x8,%esp
  801b69:	68 00 50 80 00       	push   $0x805000
  801b6e:	53                   	push   %ebx
  801b6f:	e8 21 f2 ff ff       	call   800d95 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b74:	a1 80 50 80 00       	mov    0x805080,%eax
  801b79:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b7f:	a1 84 50 80 00       	mov    0x805084,%eax
  801b84:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b8a:	83 c4 10             	add    $0x10,%esp
  801b8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b95:	c9                   	leave  
  801b96:	c3                   	ret    

00801b97 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	53                   	push   %ebx
  801b9b:	83 ec 08             	sub    $0x8,%esp
  801b9e:	8b 45 10             	mov    0x10(%ebp),%eax
  801ba1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ba6:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801bab:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801bae:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb1:	8b 40 0c             	mov    0xc(%eax),%eax
  801bb4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801bb9:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801bbf:	53                   	push   %ebx
  801bc0:	ff 75 0c             	pushl  0xc(%ebp)
  801bc3:	68 08 50 80 00       	push   $0x805008
  801bc8:	e8 5a f3 ff ff       	call   800f27 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801bcd:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd2:	b8 04 00 00 00       	mov    $0x4,%eax
  801bd7:	e8 cb fe ff ff       	call   801aa7 <fsipc>
  801bdc:	83 c4 10             	add    $0x10,%esp
  801bdf:	85 c0                	test   %eax,%eax
  801be1:	78 3d                	js     801c20 <devfile_write+0x89>
		return r;

	assert(r <= n);
  801be3:	39 d8                	cmp    %ebx,%eax
  801be5:	76 19                	jbe    801c00 <devfile_write+0x69>
  801be7:	68 f0 2c 80 00       	push   $0x802cf0
  801bec:	68 f7 2c 80 00       	push   $0x802cf7
  801bf1:	68 9f 00 00 00       	push   $0x9f
  801bf6:	68 0c 2d 80 00       	push   $0x802d0c
  801bfb:	e8 88 ea ff ff       	call   800688 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801c00:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801c05:	76 19                	jbe    801c20 <devfile_write+0x89>
  801c07:	68 24 2d 80 00       	push   $0x802d24
  801c0c:	68 f7 2c 80 00       	push   $0x802cf7
  801c11:	68 a0 00 00 00       	push   $0xa0
  801c16:	68 0c 2d 80 00       	push   $0x802d0c
  801c1b:	e8 68 ea ff ff       	call   800688 <_panic>

	return r;
}
  801c20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c23:	c9                   	leave  
  801c24:	c3                   	ret    

00801c25 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	56                   	push   %esi
  801c29:	53                   	push   %ebx
  801c2a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c30:	8b 40 0c             	mov    0xc(%eax),%eax
  801c33:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801c38:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c43:	b8 03 00 00 00       	mov    $0x3,%eax
  801c48:	e8 5a fe ff ff       	call   801aa7 <fsipc>
  801c4d:	89 c3                	mov    %eax,%ebx
  801c4f:	85 c0                	test   %eax,%eax
  801c51:	78 4b                	js     801c9e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801c53:	39 c6                	cmp    %eax,%esi
  801c55:	73 16                	jae    801c6d <devfile_read+0x48>
  801c57:	68 f0 2c 80 00       	push   $0x802cf0
  801c5c:	68 f7 2c 80 00       	push   $0x802cf7
  801c61:	6a 7e                	push   $0x7e
  801c63:	68 0c 2d 80 00       	push   $0x802d0c
  801c68:	e8 1b ea ff ff       	call   800688 <_panic>
	assert(r <= PGSIZE);
  801c6d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c72:	7e 16                	jle    801c8a <devfile_read+0x65>
  801c74:	68 17 2d 80 00       	push   $0x802d17
  801c79:	68 f7 2c 80 00       	push   $0x802cf7
  801c7e:	6a 7f                	push   $0x7f
  801c80:	68 0c 2d 80 00       	push   $0x802d0c
  801c85:	e8 fe e9 ff ff       	call   800688 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c8a:	83 ec 04             	sub    $0x4,%esp
  801c8d:	50                   	push   %eax
  801c8e:	68 00 50 80 00       	push   $0x805000
  801c93:	ff 75 0c             	pushl  0xc(%ebp)
  801c96:	e8 8c f2 ff ff       	call   800f27 <memmove>
	return r;
  801c9b:	83 c4 10             	add    $0x10,%esp
}
  801c9e:	89 d8                	mov    %ebx,%eax
  801ca0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5e                   	pop    %esi
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    

00801ca7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	53                   	push   %ebx
  801cab:	83 ec 20             	sub    $0x20,%esp
  801cae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801cb1:	53                   	push   %ebx
  801cb2:	e8 a5 f0 ff ff       	call   800d5c <strlen>
  801cb7:	83 c4 10             	add    $0x10,%esp
  801cba:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801cbf:	7f 67                	jg     801d28 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cc1:	83 ec 0c             	sub    $0xc,%esp
  801cc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc7:	50                   	push   %eax
  801cc8:	e8 52 f8 ff ff       	call   80151f <fd_alloc>
  801ccd:	83 c4 10             	add    $0x10,%esp
		return r;
  801cd0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	78 57                	js     801d2d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801cd6:	83 ec 08             	sub    $0x8,%esp
  801cd9:	53                   	push   %ebx
  801cda:	68 00 50 80 00       	push   $0x805000
  801cdf:	e8 b1 f0 ff ff       	call   800d95 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ce4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801cec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cef:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf4:	e8 ae fd ff ff       	call   801aa7 <fsipc>
  801cf9:	89 c3                	mov    %eax,%ebx
  801cfb:	83 c4 10             	add    $0x10,%esp
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	79 14                	jns    801d16 <open+0x6f>
		fd_close(fd, 0);
  801d02:	83 ec 08             	sub    $0x8,%esp
  801d05:	6a 00                	push   $0x0
  801d07:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0a:	e8 08 f9 ff ff       	call   801617 <fd_close>
		return r;
  801d0f:	83 c4 10             	add    $0x10,%esp
  801d12:	89 da                	mov    %ebx,%edx
  801d14:	eb 17                	jmp    801d2d <open+0x86>
	}

	return fd2num(fd);
  801d16:	83 ec 0c             	sub    $0xc,%esp
  801d19:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1c:	e8 d7 f7 ff ff       	call   8014f8 <fd2num>
  801d21:	89 c2                	mov    %eax,%edx
  801d23:	83 c4 10             	add    $0x10,%esp
  801d26:	eb 05                	jmp    801d2d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d28:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d2d:	89 d0                	mov    %edx,%eax
  801d2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d32:	c9                   	leave  
  801d33:	c3                   	ret    

00801d34 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801d3f:	b8 08 00 00 00       	mov    $0x8,%eax
  801d44:	e8 5e fd ff ff       	call   801aa7 <fsipc>
}
  801d49:	c9                   	leave  
  801d4a:	c3                   	ret    

00801d4b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	56                   	push   %esi
  801d4f:	53                   	push   %ebx
  801d50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d53:	83 ec 0c             	sub    $0xc,%esp
  801d56:	ff 75 08             	pushl  0x8(%ebp)
  801d59:	e8 aa f7 ff ff       	call   801508 <fd2data>
  801d5e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d60:	83 c4 08             	add    $0x8,%esp
  801d63:	68 54 2d 80 00       	push   $0x802d54
  801d68:	53                   	push   %ebx
  801d69:	e8 27 f0 ff ff       	call   800d95 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d6e:	8b 46 04             	mov    0x4(%esi),%eax
  801d71:	2b 06                	sub    (%esi),%eax
  801d73:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d79:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d80:	00 00 00 
	stat->st_dev = &devpipe;
  801d83:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801d8a:	30 80 00 
	return 0;
}
  801d8d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d95:	5b                   	pop    %ebx
  801d96:	5e                   	pop    %esi
  801d97:	5d                   	pop    %ebp
  801d98:	c3                   	ret    

00801d99 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	53                   	push   %ebx
  801d9d:	83 ec 0c             	sub    $0xc,%esp
  801da0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801da3:	53                   	push   %ebx
  801da4:	6a 00                	push   $0x0
  801da6:	e8 e9 f4 ff ff       	call   801294 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dab:	89 1c 24             	mov    %ebx,(%esp)
  801dae:	e8 55 f7 ff ff       	call   801508 <fd2data>
  801db3:	83 c4 08             	add    $0x8,%esp
  801db6:	50                   	push   %eax
  801db7:	6a 00                	push   $0x0
  801db9:	e8 d6 f4 ff ff       	call   801294 <sys_page_unmap>
}
  801dbe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	57                   	push   %edi
  801dc7:	56                   	push   %esi
  801dc8:	53                   	push   %ebx
  801dc9:	83 ec 1c             	sub    $0x1c,%esp
  801dcc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801dcf:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801dd1:	a1 08 40 80 00       	mov    0x804008,%eax
  801dd6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801dd9:	83 ec 0c             	sub    $0xc,%esp
  801ddc:	ff 75 e0             	pushl  -0x20(%ebp)
  801ddf:	e8 46 04 00 00       	call   80222a <pageref>
  801de4:	89 c3                	mov    %eax,%ebx
  801de6:	89 3c 24             	mov    %edi,(%esp)
  801de9:	e8 3c 04 00 00       	call   80222a <pageref>
  801dee:	83 c4 10             	add    $0x10,%esp
  801df1:	39 c3                	cmp    %eax,%ebx
  801df3:	0f 94 c1             	sete   %cl
  801df6:	0f b6 c9             	movzbl %cl,%ecx
  801df9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801dfc:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e02:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e05:	39 ce                	cmp    %ecx,%esi
  801e07:	74 1b                	je     801e24 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e09:	39 c3                	cmp    %eax,%ebx
  801e0b:	75 c4                	jne    801dd1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e0d:	8b 42 58             	mov    0x58(%edx),%eax
  801e10:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e13:	50                   	push   %eax
  801e14:	56                   	push   %esi
  801e15:	68 5b 2d 80 00       	push   $0x802d5b
  801e1a:	e8 42 e9 ff ff       	call   800761 <cprintf>
  801e1f:	83 c4 10             	add    $0x10,%esp
  801e22:	eb ad                	jmp    801dd1 <_pipeisclosed+0xe>
	}
}
  801e24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e2a:	5b                   	pop    %ebx
  801e2b:	5e                   	pop    %esi
  801e2c:	5f                   	pop    %edi
  801e2d:	5d                   	pop    %ebp
  801e2e:	c3                   	ret    

00801e2f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	57                   	push   %edi
  801e33:	56                   	push   %esi
  801e34:	53                   	push   %ebx
  801e35:	83 ec 28             	sub    $0x28,%esp
  801e38:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e3b:	56                   	push   %esi
  801e3c:	e8 c7 f6 ff ff       	call   801508 <fd2data>
  801e41:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e43:	83 c4 10             	add    $0x10,%esp
  801e46:	bf 00 00 00 00       	mov    $0x0,%edi
  801e4b:	eb 4b                	jmp    801e98 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e4d:	89 da                	mov    %ebx,%edx
  801e4f:	89 f0                	mov    %esi,%eax
  801e51:	e8 6d ff ff ff       	call   801dc3 <_pipeisclosed>
  801e56:	85 c0                	test   %eax,%eax
  801e58:	75 48                	jne    801ea2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e5a:	e8 91 f3 ff ff       	call   8011f0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e5f:	8b 43 04             	mov    0x4(%ebx),%eax
  801e62:	8b 0b                	mov    (%ebx),%ecx
  801e64:	8d 51 20             	lea    0x20(%ecx),%edx
  801e67:	39 d0                	cmp    %edx,%eax
  801e69:	73 e2                	jae    801e4d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e6e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e72:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e75:	89 c2                	mov    %eax,%edx
  801e77:	c1 fa 1f             	sar    $0x1f,%edx
  801e7a:	89 d1                	mov    %edx,%ecx
  801e7c:	c1 e9 1b             	shr    $0x1b,%ecx
  801e7f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e82:	83 e2 1f             	and    $0x1f,%edx
  801e85:	29 ca                	sub    %ecx,%edx
  801e87:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e8b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e8f:	83 c0 01             	add    $0x1,%eax
  801e92:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e95:	83 c7 01             	add    $0x1,%edi
  801e98:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e9b:	75 c2                	jne    801e5f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801ea0:	eb 05                	jmp    801ea7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ea2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ea7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eaa:	5b                   	pop    %ebx
  801eab:	5e                   	pop    %esi
  801eac:	5f                   	pop    %edi
  801ead:	5d                   	pop    %ebp
  801eae:	c3                   	ret    

00801eaf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	57                   	push   %edi
  801eb3:	56                   	push   %esi
  801eb4:	53                   	push   %ebx
  801eb5:	83 ec 18             	sub    $0x18,%esp
  801eb8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ebb:	57                   	push   %edi
  801ebc:	e8 47 f6 ff ff       	call   801508 <fd2data>
  801ec1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ec3:	83 c4 10             	add    $0x10,%esp
  801ec6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ecb:	eb 3d                	jmp    801f0a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ecd:	85 db                	test   %ebx,%ebx
  801ecf:	74 04                	je     801ed5 <devpipe_read+0x26>
				return i;
  801ed1:	89 d8                	mov    %ebx,%eax
  801ed3:	eb 44                	jmp    801f19 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ed5:	89 f2                	mov    %esi,%edx
  801ed7:	89 f8                	mov    %edi,%eax
  801ed9:	e8 e5 fe ff ff       	call   801dc3 <_pipeisclosed>
  801ede:	85 c0                	test   %eax,%eax
  801ee0:	75 32                	jne    801f14 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ee2:	e8 09 f3 ff ff       	call   8011f0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ee7:	8b 06                	mov    (%esi),%eax
  801ee9:	3b 46 04             	cmp    0x4(%esi),%eax
  801eec:	74 df                	je     801ecd <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801eee:	99                   	cltd   
  801eef:	c1 ea 1b             	shr    $0x1b,%edx
  801ef2:	01 d0                	add    %edx,%eax
  801ef4:	83 e0 1f             	and    $0x1f,%eax
  801ef7:	29 d0                	sub    %edx,%eax
  801ef9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801efe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f01:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f04:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f07:	83 c3 01             	add    $0x1,%ebx
  801f0a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f0d:	75 d8                	jne    801ee7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f0f:	8b 45 10             	mov    0x10(%ebp),%eax
  801f12:	eb 05                	jmp    801f19 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f14:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1c:	5b                   	pop    %ebx
  801f1d:	5e                   	pop    %esi
  801f1e:	5f                   	pop    %edi
  801f1f:	5d                   	pop    %ebp
  801f20:	c3                   	ret    

00801f21 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	56                   	push   %esi
  801f25:	53                   	push   %ebx
  801f26:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f2c:	50                   	push   %eax
  801f2d:	e8 ed f5 ff ff       	call   80151f <fd_alloc>
  801f32:	83 c4 10             	add    $0x10,%esp
  801f35:	89 c2                	mov    %eax,%edx
  801f37:	85 c0                	test   %eax,%eax
  801f39:	0f 88 2c 01 00 00    	js     80206b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f3f:	83 ec 04             	sub    $0x4,%esp
  801f42:	68 07 04 00 00       	push   $0x407
  801f47:	ff 75 f4             	pushl  -0xc(%ebp)
  801f4a:	6a 00                	push   $0x0
  801f4c:	e8 be f2 ff ff       	call   80120f <sys_page_alloc>
  801f51:	83 c4 10             	add    $0x10,%esp
  801f54:	89 c2                	mov    %eax,%edx
  801f56:	85 c0                	test   %eax,%eax
  801f58:	0f 88 0d 01 00 00    	js     80206b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f5e:	83 ec 0c             	sub    $0xc,%esp
  801f61:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f64:	50                   	push   %eax
  801f65:	e8 b5 f5 ff ff       	call   80151f <fd_alloc>
  801f6a:	89 c3                	mov    %eax,%ebx
  801f6c:	83 c4 10             	add    $0x10,%esp
  801f6f:	85 c0                	test   %eax,%eax
  801f71:	0f 88 e2 00 00 00    	js     802059 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f77:	83 ec 04             	sub    $0x4,%esp
  801f7a:	68 07 04 00 00       	push   $0x407
  801f7f:	ff 75 f0             	pushl  -0x10(%ebp)
  801f82:	6a 00                	push   $0x0
  801f84:	e8 86 f2 ff ff       	call   80120f <sys_page_alloc>
  801f89:	89 c3                	mov    %eax,%ebx
  801f8b:	83 c4 10             	add    $0x10,%esp
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	0f 88 c3 00 00 00    	js     802059 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f96:	83 ec 0c             	sub    $0xc,%esp
  801f99:	ff 75 f4             	pushl  -0xc(%ebp)
  801f9c:	e8 67 f5 ff ff       	call   801508 <fd2data>
  801fa1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fa3:	83 c4 0c             	add    $0xc,%esp
  801fa6:	68 07 04 00 00       	push   $0x407
  801fab:	50                   	push   %eax
  801fac:	6a 00                	push   $0x0
  801fae:	e8 5c f2 ff ff       	call   80120f <sys_page_alloc>
  801fb3:	89 c3                	mov    %eax,%ebx
  801fb5:	83 c4 10             	add    $0x10,%esp
  801fb8:	85 c0                	test   %eax,%eax
  801fba:	0f 88 89 00 00 00    	js     802049 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc0:	83 ec 0c             	sub    $0xc,%esp
  801fc3:	ff 75 f0             	pushl  -0x10(%ebp)
  801fc6:	e8 3d f5 ff ff       	call   801508 <fd2data>
  801fcb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801fd2:	50                   	push   %eax
  801fd3:	6a 00                	push   $0x0
  801fd5:	56                   	push   %esi
  801fd6:	6a 00                	push   $0x0
  801fd8:	e8 75 f2 ff ff       	call   801252 <sys_page_map>
  801fdd:	89 c3                	mov    %eax,%ebx
  801fdf:	83 c4 20             	add    $0x20,%esp
  801fe2:	85 c0                	test   %eax,%eax
  801fe4:	78 55                	js     80203b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fe6:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fef:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ffb:	8b 15 24 30 80 00    	mov    0x803024,%edx
  802001:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802004:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802006:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802009:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802010:	83 ec 0c             	sub    $0xc,%esp
  802013:	ff 75 f4             	pushl  -0xc(%ebp)
  802016:	e8 dd f4 ff ff       	call   8014f8 <fd2num>
  80201b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80201e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802020:	83 c4 04             	add    $0x4,%esp
  802023:	ff 75 f0             	pushl  -0x10(%ebp)
  802026:	e8 cd f4 ff ff       	call   8014f8 <fd2num>
  80202b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80202e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802031:	83 c4 10             	add    $0x10,%esp
  802034:	ba 00 00 00 00       	mov    $0x0,%edx
  802039:	eb 30                	jmp    80206b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80203b:	83 ec 08             	sub    $0x8,%esp
  80203e:	56                   	push   %esi
  80203f:	6a 00                	push   $0x0
  802041:	e8 4e f2 ff ff       	call   801294 <sys_page_unmap>
  802046:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802049:	83 ec 08             	sub    $0x8,%esp
  80204c:	ff 75 f0             	pushl  -0x10(%ebp)
  80204f:	6a 00                	push   $0x0
  802051:	e8 3e f2 ff ff       	call   801294 <sys_page_unmap>
  802056:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802059:	83 ec 08             	sub    $0x8,%esp
  80205c:	ff 75 f4             	pushl  -0xc(%ebp)
  80205f:	6a 00                	push   $0x0
  802061:	e8 2e f2 ff ff       	call   801294 <sys_page_unmap>
  802066:	83 c4 10             	add    $0x10,%esp
  802069:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80206b:	89 d0                	mov    %edx,%eax
  80206d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802070:	5b                   	pop    %ebx
  802071:	5e                   	pop    %esi
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    

00802074 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80207a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80207d:	50                   	push   %eax
  80207e:	ff 75 08             	pushl  0x8(%ebp)
  802081:	e8 e8 f4 ff ff       	call   80156e <fd_lookup>
  802086:	83 c4 10             	add    $0x10,%esp
  802089:	85 c0                	test   %eax,%eax
  80208b:	78 18                	js     8020a5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80208d:	83 ec 0c             	sub    $0xc,%esp
  802090:	ff 75 f4             	pushl  -0xc(%ebp)
  802093:	e8 70 f4 ff ff       	call   801508 <fd2data>
	return _pipeisclosed(fd, p);
  802098:	89 c2                	mov    %eax,%edx
  80209a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209d:	e8 21 fd ff ff       	call   801dc3 <_pipeisclosed>
  8020a2:	83 c4 10             	add    $0x10,%esp
}
  8020a5:	c9                   	leave  
  8020a6:	c3                   	ret    

008020a7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020a7:	55                   	push   %ebp
  8020a8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8020af:	5d                   	pop    %ebp
  8020b0:	c3                   	ret    

008020b1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020b1:	55                   	push   %ebp
  8020b2:	89 e5                	mov    %esp,%ebp
  8020b4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020b7:	68 73 2d 80 00       	push   $0x802d73
  8020bc:	ff 75 0c             	pushl  0xc(%ebp)
  8020bf:	e8 d1 ec ff ff       	call   800d95 <strcpy>
	return 0;
}
  8020c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c9:	c9                   	leave  
  8020ca:	c3                   	ret    

008020cb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	57                   	push   %edi
  8020cf:	56                   	push   %esi
  8020d0:	53                   	push   %ebx
  8020d1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020d7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020dc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020e2:	eb 2d                	jmp    802111 <devcons_write+0x46>
		m = n - tot;
  8020e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020e7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8020e9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020ec:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020f1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020f4:	83 ec 04             	sub    $0x4,%esp
  8020f7:	53                   	push   %ebx
  8020f8:	03 45 0c             	add    0xc(%ebp),%eax
  8020fb:	50                   	push   %eax
  8020fc:	57                   	push   %edi
  8020fd:	e8 25 ee ff ff       	call   800f27 <memmove>
		sys_cputs(buf, m);
  802102:	83 c4 08             	add    $0x8,%esp
  802105:	53                   	push   %ebx
  802106:	57                   	push   %edi
  802107:	e8 47 f0 ff ff       	call   801153 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80210c:	01 de                	add    %ebx,%esi
  80210e:	83 c4 10             	add    $0x10,%esp
  802111:	89 f0                	mov    %esi,%eax
  802113:	3b 75 10             	cmp    0x10(%ebp),%esi
  802116:	72 cc                	jb     8020e4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80211b:	5b                   	pop    %ebx
  80211c:	5e                   	pop    %esi
  80211d:	5f                   	pop    %edi
  80211e:	5d                   	pop    %ebp
  80211f:	c3                   	ret    

00802120 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	83 ec 08             	sub    $0x8,%esp
  802126:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80212b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80212f:	74 2a                	je     80215b <devcons_read+0x3b>
  802131:	eb 05                	jmp    802138 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802133:	e8 b8 f0 ff ff       	call   8011f0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802138:	e8 34 f0 ff ff       	call   801171 <sys_cgetc>
  80213d:	85 c0                	test   %eax,%eax
  80213f:	74 f2                	je     802133 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802141:	85 c0                	test   %eax,%eax
  802143:	78 16                	js     80215b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802145:	83 f8 04             	cmp    $0x4,%eax
  802148:	74 0c                	je     802156 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80214a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80214d:	88 02                	mov    %al,(%edx)
	return 1;
  80214f:	b8 01 00 00 00       	mov    $0x1,%eax
  802154:	eb 05                	jmp    80215b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802156:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80215b:	c9                   	leave  
  80215c:	c3                   	ret    

0080215d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80215d:	55                   	push   %ebp
  80215e:	89 e5                	mov    %esp,%ebp
  802160:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802163:	8b 45 08             	mov    0x8(%ebp),%eax
  802166:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802169:	6a 01                	push   $0x1
  80216b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80216e:	50                   	push   %eax
  80216f:	e8 df ef ff ff       	call   801153 <sys_cputs>
}
  802174:	83 c4 10             	add    $0x10,%esp
  802177:	c9                   	leave  
  802178:	c3                   	ret    

00802179 <getchar>:

int
getchar(void)
{
  802179:	55                   	push   %ebp
  80217a:	89 e5                	mov    %esp,%ebp
  80217c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80217f:	6a 01                	push   $0x1
  802181:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802184:	50                   	push   %eax
  802185:	6a 00                	push   $0x0
  802187:	e8 48 f6 ff ff       	call   8017d4 <read>
	if (r < 0)
  80218c:	83 c4 10             	add    $0x10,%esp
  80218f:	85 c0                	test   %eax,%eax
  802191:	78 0f                	js     8021a2 <getchar+0x29>
		return r;
	if (r < 1)
  802193:	85 c0                	test   %eax,%eax
  802195:	7e 06                	jle    80219d <getchar+0x24>
		return -E_EOF;
	return c;
  802197:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80219b:	eb 05                	jmp    8021a2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80219d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021a2:	c9                   	leave  
  8021a3:	c3                   	ret    

008021a4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021a4:	55                   	push   %ebp
  8021a5:	89 e5                	mov    %esp,%ebp
  8021a7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ad:	50                   	push   %eax
  8021ae:	ff 75 08             	pushl  0x8(%ebp)
  8021b1:	e8 b8 f3 ff ff       	call   80156e <fd_lookup>
  8021b6:	83 c4 10             	add    $0x10,%esp
  8021b9:	85 c0                	test   %eax,%eax
  8021bb:	78 11                	js     8021ce <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c0:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8021c6:	39 10                	cmp    %edx,(%eax)
  8021c8:	0f 94 c0             	sete   %al
  8021cb:	0f b6 c0             	movzbl %al,%eax
}
  8021ce:	c9                   	leave  
  8021cf:	c3                   	ret    

008021d0 <opencons>:

int
opencons(void)
{
  8021d0:	55                   	push   %ebp
  8021d1:	89 e5                	mov    %esp,%ebp
  8021d3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021d9:	50                   	push   %eax
  8021da:	e8 40 f3 ff ff       	call   80151f <fd_alloc>
  8021df:	83 c4 10             	add    $0x10,%esp
		return r;
  8021e2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021e4:	85 c0                	test   %eax,%eax
  8021e6:	78 3e                	js     802226 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021e8:	83 ec 04             	sub    $0x4,%esp
  8021eb:	68 07 04 00 00       	push   $0x407
  8021f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8021f3:	6a 00                	push   $0x0
  8021f5:	e8 15 f0 ff ff       	call   80120f <sys_page_alloc>
  8021fa:	83 c4 10             	add    $0x10,%esp
		return r;
  8021fd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021ff:	85 c0                	test   %eax,%eax
  802201:	78 23                	js     802226 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802203:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802209:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80220e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802211:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802218:	83 ec 0c             	sub    $0xc,%esp
  80221b:	50                   	push   %eax
  80221c:	e8 d7 f2 ff ff       	call   8014f8 <fd2num>
  802221:	89 c2                	mov    %eax,%edx
  802223:	83 c4 10             	add    $0x10,%esp
}
  802226:	89 d0                	mov    %edx,%eax
  802228:	c9                   	leave  
  802229:	c3                   	ret    

0080222a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80222a:	55                   	push   %ebp
  80222b:	89 e5                	mov    %esp,%ebp
  80222d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802230:	89 d0                	mov    %edx,%eax
  802232:	c1 e8 16             	shr    $0x16,%eax
  802235:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80223c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802241:	f6 c1 01             	test   $0x1,%cl
  802244:	74 1d                	je     802263 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802246:	c1 ea 0c             	shr    $0xc,%edx
  802249:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802250:	f6 c2 01             	test   $0x1,%dl
  802253:	74 0e                	je     802263 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802255:	c1 ea 0c             	shr    $0xc,%edx
  802258:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80225f:	ef 
  802260:	0f b7 c0             	movzwl %ax,%eax
}
  802263:	5d                   	pop    %ebp
  802264:	c3                   	ret    
  802265:	66 90                	xchg   %ax,%ax
  802267:	66 90                	xchg   %ax,%ax
  802269:	66 90                	xchg   %ax,%ax
  80226b:	66 90                	xchg   %ax,%ax
  80226d:	66 90                	xchg   %ax,%ax
  80226f:	90                   	nop

00802270 <__udivdi3>:
  802270:	55                   	push   %ebp
  802271:	57                   	push   %edi
  802272:	56                   	push   %esi
  802273:	53                   	push   %ebx
  802274:	83 ec 1c             	sub    $0x1c,%esp
  802277:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80227b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80227f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802283:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802287:	85 f6                	test   %esi,%esi
  802289:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80228d:	89 ca                	mov    %ecx,%edx
  80228f:	89 f8                	mov    %edi,%eax
  802291:	75 3d                	jne    8022d0 <__udivdi3+0x60>
  802293:	39 cf                	cmp    %ecx,%edi
  802295:	0f 87 c5 00 00 00    	ja     802360 <__udivdi3+0xf0>
  80229b:	85 ff                	test   %edi,%edi
  80229d:	89 fd                	mov    %edi,%ebp
  80229f:	75 0b                	jne    8022ac <__udivdi3+0x3c>
  8022a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022a6:	31 d2                	xor    %edx,%edx
  8022a8:	f7 f7                	div    %edi
  8022aa:	89 c5                	mov    %eax,%ebp
  8022ac:	89 c8                	mov    %ecx,%eax
  8022ae:	31 d2                	xor    %edx,%edx
  8022b0:	f7 f5                	div    %ebp
  8022b2:	89 c1                	mov    %eax,%ecx
  8022b4:	89 d8                	mov    %ebx,%eax
  8022b6:	89 cf                	mov    %ecx,%edi
  8022b8:	f7 f5                	div    %ebp
  8022ba:	89 c3                	mov    %eax,%ebx
  8022bc:	89 d8                	mov    %ebx,%eax
  8022be:	89 fa                	mov    %edi,%edx
  8022c0:	83 c4 1c             	add    $0x1c,%esp
  8022c3:	5b                   	pop    %ebx
  8022c4:	5e                   	pop    %esi
  8022c5:	5f                   	pop    %edi
  8022c6:	5d                   	pop    %ebp
  8022c7:	c3                   	ret    
  8022c8:	90                   	nop
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	39 ce                	cmp    %ecx,%esi
  8022d2:	77 74                	ja     802348 <__udivdi3+0xd8>
  8022d4:	0f bd fe             	bsr    %esi,%edi
  8022d7:	83 f7 1f             	xor    $0x1f,%edi
  8022da:	0f 84 98 00 00 00    	je     802378 <__udivdi3+0x108>
  8022e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022e5:	89 f9                	mov    %edi,%ecx
  8022e7:	89 c5                	mov    %eax,%ebp
  8022e9:	29 fb                	sub    %edi,%ebx
  8022eb:	d3 e6                	shl    %cl,%esi
  8022ed:	89 d9                	mov    %ebx,%ecx
  8022ef:	d3 ed                	shr    %cl,%ebp
  8022f1:	89 f9                	mov    %edi,%ecx
  8022f3:	d3 e0                	shl    %cl,%eax
  8022f5:	09 ee                	or     %ebp,%esi
  8022f7:	89 d9                	mov    %ebx,%ecx
  8022f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022fd:	89 d5                	mov    %edx,%ebp
  8022ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802303:	d3 ed                	shr    %cl,%ebp
  802305:	89 f9                	mov    %edi,%ecx
  802307:	d3 e2                	shl    %cl,%edx
  802309:	89 d9                	mov    %ebx,%ecx
  80230b:	d3 e8                	shr    %cl,%eax
  80230d:	09 c2                	or     %eax,%edx
  80230f:	89 d0                	mov    %edx,%eax
  802311:	89 ea                	mov    %ebp,%edx
  802313:	f7 f6                	div    %esi
  802315:	89 d5                	mov    %edx,%ebp
  802317:	89 c3                	mov    %eax,%ebx
  802319:	f7 64 24 0c          	mull   0xc(%esp)
  80231d:	39 d5                	cmp    %edx,%ebp
  80231f:	72 10                	jb     802331 <__udivdi3+0xc1>
  802321:	8b 74 24 08          	mov    0x8(%esp),%esi
  802325:	89 f9                	mov    %edi,%ecx
  802327:	d3 e6                	shl    %cl,%esi
  802329:	39 c6                	cmp    %eax,%esi
  80232b:	73 07                	jae    802334 <__udivdi3+0xc4>
  80232d:	39 d5                	cmp    %edx,%ebp
  80232f:	75 03                	jne    802334 <__udivdi3+0xc4>
  802331:	83 eb 01             	sub    $0x1,%ebx
  802334:	31 ff                	xor    %edi,%edi
  802336:	89 d8                	mov    %ebx,%eax
  802338:	89 fa                	mov    %edi,%edx
  80233a:	83 c4 1c             	add    $0x1c,%esp
  80233d:	5b                   	pop    %ebx
  80233e:	5e                   	pop    %esi
  80233f:	5f                   	pop    %edi
  802340:	5d                   	pop    %ebp
  802341:	c3                   	ret    
  802342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802348:	31 ff                	xor    %edi,%edi
  80234a:	31 db                	xor    %ebx,%ebx
  80234c:	89 d8                	mov    %ebx,%eax
  80234e:	89 fa                	mov    %edi,%edx
  802350:	83 c4 1c             	add    $0x1c,%esp
  802353:	5b                   	pop    %ebx
  802354:	5e                   	pop    %esi
  802355:	5f                   	pop    %edi
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    
  802358:	90                   	nop
  802359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802360:	89 d8                	mov    %ebx,%eax
  802362:	f7 f7                	div    %edi
  802364:	31 ff                	xor    %edi,%edi
  802366:	89 c3                	mov    %eax,%ebx
  802368:	89 d8                	mov    %ebx,%eax
  80236a:	89 fa                	mov    %edi,%edx
  80236c:	83 c4 1c             	add    $0x1c,%esp
  80236f:	5b                   	pop    %ebx
  802370:	5e                   	pop    %esi
  802371:	5f                   	pop    %edi
  802372:	5d                   	pop    %ebp
  802373:	c3                   	ret    
  802374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802378:	39 ce                	cmp    %ecx,%esi
  80237a:	72 0c                	jb     802388 <__udivdi3+0x118>
  80237c:	31 db                	xor    %ebx,%ebx
  80237e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802382:	0f 87 34 ff ff ff    	ja     8022bc <__udivdi3+0x4c>
  802388:	bb 01 00 00 00       	mov    $0x1,%ebx
  80238d:	e9 2a ff ff ff       	jmp    8022bc <__udivdi3+0x4c>
  802392:	66 90                	xchg   %ax,%ax
  802394:	66 90                	xchg   %ax,%ax
  802396:	66 90                	xchg   %ax,%ax
  802398:	66 90                	xchg   %ax,%ax
  80239a:	66 90                	xchg   %ax,%ax
  80239c:	66 90                	xchg   %ax,%ax
  80239e:	66 90                	xchg   %ax,%ax

008023a0 <__umoddi3>:
  8023a0:	55                   	push   %ebp
  8023a1:	57                   	push   %edi
  8023a2:	56                   	push   %esi
  8023a3:	53                   	push   %ebx
  8023a4:	83 ec 1c             	sub    $0x1c,%esp
  8023a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8023ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8023af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023b7:	85 d2                	test   %edx,%edx
  8023b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023c1:	89 f3                	mov    %esi,%ebx
  8023c3:	89 3c 24             	mov    %edi,(%esp)
  8023c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023ca:	75 1c                	jne    8023e8 <__umoddi3+0x48>
  8023cc:	39 f7                	cmp    %esi,%edi
  8023ce:	76 50                	jbe    802420 <__umoddi3+0x80>
  8023d0:	89 c8                	mov    %ecx,%eax
  8023d2:	89 f2                	mov    %esi,%edx
  8023d4:	f7 f7                	div    %edi
  8023d6:	89 d0                	mov    %edx,%eax
  8023d8:	31 d2                	xor    %edx,%edx
  8023da:	83 c4 1c             	add    $0x1c,%esp
  8023dd:	5b                   	pop    %ebx
  8023de:	5e                   	pop    %esi
  8023df:	5f                   	pop    %edi
  8023e0:	5d                   	pop    %ebp
  8023e1:	c3                   	ret    
  8023e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023e8:	39 f2                	cmp    %esi,%edx
  8023ea:	89 d0                	mov    %edx,%eax
  8023ec:	77 52                	ja     802440 <__umoddi3+0xa0>
  8023ee:	0f bd ea             	bsr    %edx,%ebp
  8023f1:	83 f5 1f             	xor    $0x1f,%ebp
  8023f4:	75 5a                	jne    802450 <__umoddi3+0xb0>
  8023f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023fa:	0f 82 e0 00 00 00    	jb     8024e0 <__umoddi3+0x140>
  802400:	39 0c 24             	cmp    %ecx,(%esp)
  802403:	0f 86 d7 00 00 00    	jbe    8024e0 <__umoddi3+0x140>
  802409:	8b 44 24 08          	mov    0x8(%esp),%eax
  80240d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802411:	83 c4 1c             	add    $0x1c,%esp
  802414:	5b                   	pop    %ebx
  802415:	5e                   	pop    %esi
  802416:	5f                   	pop    %edi
  802417:	5d                   	pop    %ebp
  802418:	c3                   	ret    
  802419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802420:	85 ff                	test   %edi,%edi
  802422:	89 fd                	mov    %edi,%ebp
  802424:	75 0b                	jne    802431 <__umoddi3+0x91>
  802426:	b8 01 00 00 00       	mov    $0x1,%eax
  80242b:	31 d2                	xor    %edx,%edx
  80242d:	f7 f7                	div    %edi
  80242f:	89 c5                	mov    %eax,%ebp
  802431:	89 f0                	mov    %esi,%eax
  802433:	31 d2                	xor    %edx,%edx
  802435:	f7 f5                	div    %ebp
  802437:	89 c8                	mov    %ecx,%eax
  802439:	f7 f5                	div    %ebp
  80243b:	89 d0                	mov    %edx,%eax
  80243d:	eb 99                	jmp    8023d8 <__umoddi3+0x38>
  80243f:	90                   	nop
  802440:	89 c8                	mov    %ecx,%eax
  802442:	89 f2                	mov    %esi,%edx
  802444:	83 c4 1c             	add    $0x1c,%esp
  802447:	5b                   	pop    %ebx
  802448:	5e                   	pop    %esi
  802449:	5f                   	pop    %edi
  80244a:	5d                   	pop    %ebp
  80244b:	c3                   	ret    
  80244c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802450:	8b 34 24             	mov    (%esp),%esi
  802453:	bf 20 00 00 00       	mov    $0x20,%edi
  802458:	89 e9                	mov    %ebp,%ecx
  80245a:	29 ef                	sub    %ebp,%edi
  80245c:	d3 e0                	shl    %cl,%eax
  80245e:	89 f9                	mov    %edi,%ecx
  802460:	89 f2                	mov    %esi,%edx
  802462:	d3 ea                	shr    %cl,%edx
  802464:	89 e9                	mov    %ebp,%ecx
  802466:	09 c2                	or     %eax,%edx
  802468:	89 d8                	mov    %ebx,%eax
  80246a:	89 14 24             	mov    %edx,(%esp)
  80246d:	89 f2                	mov    %esi,%edx
  80246f:	d3 e2                	shl    %cl,%edx
  802471:	89 f9                	mov    %edi,%ecx
  802473:	89 54 24 04          	mov    %edx,0x4(%esp)
  802477:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80247b:	d3 e8                	shr    %cl,%eax
  80247d:	89 e9                	mov    %ebp,%ecx
  80247f:	89 c6                	mov    %eax,%esi
  802481:	d3 e3                	shl    %cl,%ebx
  802483:	89 f9                	mov    %edi,%ecx
  802485:	89 d0                	mov    %edx,%eax
  802487:	d3 e8                	shr    %cl,%eax
  802489:	89 e9                	mov    %ebp,%ecx
  80248b:	09 d8                	or     %ebx,%eax
  80248d:	89 d3                	mov    %edx,%ebx
  80248f:	89 f2                	mov    %esi,%edx
  802491:	f7 34 24             	divl   (%esp)
  802494:	89 d6                	mov    %edx,%esi
  802496:	d3 e3                	shl    %cl,%ebx
  802498:	f7 64 24 04          	mull   0x4(%esp)
  80249c:	39 d6                	cmp    %edx,%esi
  80249e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024a2:	89 d1                	mov    %edx,%ecx
  8024a4:	89 c3                	mov    %eax,%ebx
  8024a6:	72 08                	jb     8024b0 <__umoddi3+0x110>
  8024a8:	75 11                	jne    8024bb <__umoddi3+0x11b>
  8024aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8024ae:	73 0b                	jae    8024bb <__umoddi3+0x11b>
  8024b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8024b4:	1b 14 24             	sbb    (%esp),%edx
  8024b7:	89 d1                	mov    %edx,%ecx
  8024b9:	89 c3                	mov    %eax,%ebx
  8024bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024bf:	29 da                	sub    %ebx,%edx
  8024c1:	19 ce                	sbb    %ecx,%esi
  8024c3:	89 f9                	mov    %edi,%ecx
  8024c5:	89 f0                	mov    %esi,%eax
  8024c7:	d3 e0                	shl    %cl,%eax
  8024c9:	89 e9                	mov    %ebp,%ecx
  8024cb:	d3 ea                	shr    %cl,%edx
  8024cd:	89 e9                	mov    %ebp,%ecx
  8024cf:	d3 ee                	shr    %cl,%esi
  8024d1:	09 d0                	or     %edx,%eax
  8024d3:	89 f2                	mov    %esi,%edx
  8024d5:	83 c4 1c             	add    $0x1c,%esp
  8024d8:	5b                   	pop    %ebx
  8024d9:	5e                   	pop    %esi
  8024da:	5f                   	pop    %edi
  8024db:	5d                   	pop    %ebp
  8024dc:	c3                   	ret    
  8024dd:	8d 76 00             	lea    0x0(%esi),%esi
  8024e0:	29 f9                	sub    %edi,%ecx
  8024e2:	19 d6                	sbb    %edx,%esi
  8024e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024ec:	e9 18 ff ff ff       	jmp    802409 <__umoddi3+0x69>
