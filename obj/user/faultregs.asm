
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 66 05 00 00       	call   800597 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 31 25 80 00       	push   $0x802531
  800049:	68 00 25 80 00       	push   $0x802500
  80004e:	e8 7d 06 00 00       	call   8006d0 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 10 25 80 00       	push   $0x802510
  80005c:	68 14 25 80 00       	push   $0x802514
  800061:	e8 6a 06 00 00       	call   8006d0 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 24 25 80 00       	push   $0x802524
  800077:	e8 54 06 00 00       	call   8006d0 <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 28 25 80 00       	push   $0x802528
  80008e:	e8 3d 06 00 00       	call   8006d0 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 32 25 80 00       	push   $0x802532
  8000a6:	68 14 25 80 00       	push   $0x802514
  8000ab:	e8 20 06 00 00       	call   8006d0 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 24 25 80 00       	push   $0x802524
  8000c3:	e8 08 06 00 00       	call   8006d0 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 28 25 80 00       	push   $0x802528
  8000d5:	e8 f6 05 00 00       	call   8006d0 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 36 25 80 00       	push   $0x802536
  8000ed:	68 14 25 80 00       	push   $0x802514
  8000f2:	e8 d9 05 00 00       	call   8006d0 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 24 25 80 00       	push   $0x802524
  80010a:	e8 c1 05 00 00       	call   8006d0 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 28 25 80 00       	push   $0x802528
  80011c:	e8 af 05 00 00       	call   8006d0 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 3a 25 80 00       	push   $0x80253a
  800134:	68 14 25 80 00       	push   $0x802514
  800139:	e8 92 05 00 00       	call   8006d0 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 24 25 80 00       	push   $0x802524
  800151:	e8 7a 05 00 00       	call   8006d0 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 28 25 80 00       	push   $0x802528
  800163:	e8 68 05 00 00       	call   8006d0 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 3e 25 80 00       	push   $0x80253e
  80017b:	68 14 25 80 00       	push   $0x802514
  800180:	e8 4b 05 00 00       	call   8006d0 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 24 25 80 00       	push   $0x802524
  800198:	e8 33 05 00 00       	call   8006d0 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 28 25 80 00       	push   $0x802528
  8001aa:	e8 21 05 00 00       	call   8006d0 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 42 25 80 00       	push   $0x802542
  8001c2:	68 14 25 80 00       	push   $0x802514
  8001c7:	e8 04 05 00 00       	call   8006d0 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 24 25 80 00       	push   $0x802524
  8001df:	e8 ec 04 00 00       	call   8006d0 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 28 25 80 00       	push   $0x802528
  8001f1:	e8 da 04 00 00       	call   8006d0 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 46 25 80 00       	push   $0x802546
  800209:	68 14 25 80 00       	push   $0x802514
  80020e:	e8 bd 04 00 00       	call   8006d0 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 24 25 80 00       	push   $0x802524
  800226:	e8 a5 04 00 00       	call   8006d0 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 28 25 80 00       	push   $0x802528
  800238:	e8 93 04 00 00       	call   8006d0 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 4a 25 80 00       	push   $0x80254a
  800250:	68 14 25 80 00       	push   $0x802514
  800255:	e8 76 04 00 00       	call   8006d0 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 24 25 80 00       	push   $0x802524
  80026d:	e8 5e 04 00 00       	call   8006d0 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 28 25 80 00       	push   $0x802528
  80027f:	e8 4c 04 00 00       	call   8006d0 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 4e 25 80 00       	push   $0x80254e
  800297:	68 14 25 80 00       	push   $0x802514
  80029c:	e8 2f 04 00 00       	call   8006d0 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 24 25 80 00       	push   $0x802524
  8002b4:	e8 17 04 00 00       	call   8006d0 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 55 25 80 00       	push   $0x802555
  8002c4:	68 14 25 80 00       	push   $0x802514
  8002c9:	e8 02 04 00 00       	call   8006d0 <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 28 25 80 00       	push   $0x802528
  8002e3:	e8 e8 03 00 00       	call   8006d0 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 55 25 80 00       	push   $0x802555
  8002f3:	68 14 25 80 00       	push   $0x802514
  8002f8:	e8 d3 03 00 00       	call   8006d0 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 24 25 80 00       	push   $0x802524
  800312:	e8 b9 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 59 25 80 00       	push   $0x802559
  800322:	e8 a9 03 00 00       	call   8006d0 <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 28 25 80 00       	push   $0x802528
  800338:	e8 93 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 59 25 80 00       	push   $0x802559
  800348:	e8 83 03 00 00       	call   8006d0 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 24 25 80 00       	push   $0x802524
  80035a:	e8 71 03 00 00       	call   8006d0 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 28 25 80 00       	push   $0x802528
  80036c:	e8 5f 03 00 00       	call   8006d0 <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 24 25 80 00       	push   $0x802524
  80037e:	e8 4d 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 59 25 80 00       	push   $0x802559
  80038e:	e8 3d 03 00 00       	call   8006d0 <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 c0 25 80 00       	push   $0x8025c0
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 67 25 80 00       	push   $0x802567
  8003c6:	e8 2c 02 00 00       	call   8005f7 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 40 40 80 00    	mov    %edx,0x804040
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 44 40 80 00    	mov    %edx,0x804044
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 48 40 80 00    	mov    %edx,0x804048
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 50 40 80 00    	mov    %edx,0x804050
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 54 40 80 00    	mov    %edx,0x804054
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 58 40 80 00    	mov    %edx,0x804058
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags & ~FL_RF;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800425:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  80042b:	8b 40 30             	mov    0x30(%eax),%eax
  80042e:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	68 7f 25 80 00       	push   $0x80257f
  80043b:	68 8d 25 80 00       	push   $0x80258d
  800440:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800445:	ba 78 25 80 00       	mov    $0x802578,%edx
  80044a:	b8 80 40 80 00       	mov    $0x804080,%eax
  80044f:	e8 df fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800454:	83 c4 0c             	add    $0xc,%esp
  800457:	6a 07                	push   $0x7
  800459:	68 00 00 40 00       	push   $0x400000
  80045e:	6a 00                	push   $0x0
  800460:	e8 19 0d 00 00       	call   80117e <sys_page_alloc>
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	85 c0                	test   %eax,%eax
  80046a:	79 12                	jns    80047e <pgfault+0xde>
		panic("sys_page_alloc: %e", r);
  80046c:	50                   	push   %eax
  80046d:	68 94 25 80 00       	push   $0x802594
  800472:	6a 5c                	push   $0x5c
  800474:	68 67 25 80 00       	push   $0x802567
  800479:	e8 79 01 00 00       	call   8005f7 <_panic>
}
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <umain>:

void
umain(int argc, char **argv)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800486:	68 a0 03 80 00       	push   $0x8003a0
  80048b:	e8 df 0e 00 00       	call   80136f <set_pgfault_handler>

	asm volatile(
  800490:	50                   	push   %eax
  800491:	9c                   	pushf  
  800492:	58                   	pop    %eax
  800493:	0d d5 08 00 00       	or     $0x8d5,%eax
  800498:	50                   	push   %eax
  800499:	9d                   	popf   
  80049a:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  80049f:	8d 05 da 04 80 00    	lea    0x8004da,%eax
  8004a5:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004aa:	58                   	pop    %eax
  8004ab:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004b1:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004b7:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  8004bd:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  8004c3:	89 15 94 40 80 00    	mov    %edx,0x804094
  8004c9:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  8004cf:	a3 9c 40 80 00       	mov    %eax,0x80409c
  8004d4:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  8004da:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e1:	00 00 00 
  8004e4:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004ea:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004f0:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004f6:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004fc:	89 15 14 40 80 00    	mov    %edx,0x804014
  800502:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800508:	a3 1c 40 80 00       	mov    %eax,0x80401c
  80050d:	89 25 28 40 80 00    	mov    %esp,0x804028
  800513:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800519:	8b 35 84 40 80 00    	mov    0x804084,%esi
  80051f:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  800525:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  80052b:	8b 15 94 40 80 00    	mov    0x804094,%edx
  800531:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800537:	a1 9c 40 80 00       	mov    0x80409c,%eax
  80053c:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  800542:	50                   	push   %eax
  800543:	9c                   	pushf  
  800544:	58                   	pop    %eax
  800545:	a3 24 40 80 00       	mov    %eax,0x804024
  80054a:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800555:	74 10                	je     800567 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800557:	83 ec 0c             	sub    $0xc,%esp
  80055a:	68 f4 25 80 00       	push   $0x8025f4
  80055f:	e8 6c 01 00 00       	call   8006d0 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800567:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  80056c:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	68 a7 25 80 00       	push   $0x8025a7
  800579:	68 b8 25 80 00       	push   $0x8025b8
  80057e:	b9 00 40 80 00       	mov    $0x804000,%ecx
  800583:	ba 78 25 80 00       	mov    $0x802578,%edx
  800588:	b8 80 40 80 00       	mov    $0x804080,%eax
  80058d:	e8 a1 fa ff ff       	call   800033 <check_regs>
}
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	c9                   	leave  
  800596:	c3                   	ret    

00800597 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800597:	55                   	push   %ebp
  800598:	89 e5                	mov    %esp,%ebp
  80059a:	56                   	push   %esi
  80059b:	53                   	push   %ebx
  80059c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80059f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8005a2:	e8 99 0b 00 00       	call   801140 <sys_getenvid>
  8005a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005ac:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005af:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005b4:	a3 b4 40 80 00       	mov    %eax,0x8040b4
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b9:	85 db                	test   %ebx,%ebx
  8005bb:	7e 07                	jle    8005c4 <libmain+0x2d>
		binaryname = argv[0];
  8005bd:	8b 06                	mov    (%esi),%eax
  8005bf:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	56                   	push   %esi
  8005c8:	53                   	push   %ebx
  8005c9:	e8 b2 fe ff ff       	call   800480 <umain>

	// exit gracefully
	exit();
  8005ce:	e8 0a 00 00 00       	call   8005dd <exit>
}
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d9:	5b                   	pop    %ebx
  8005da:	5e                   	pop    %esi
  8005db:	5d                   	pop    %ebp
  8005dc:	c3                   	ret    

008005dd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005dd:	55                   	push   %ebp
  8005de:	89 e5                	mov    %esp,%ebp
  8005e0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005e3:	e8 e1 0f 00 00       	call   8015c9 <close_all>
	sys_env_destroy(0);
  8005e8:	83 ec 0c             	sub    $0xc,%esp
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 0d 0b 00 00       	call   8010ff <sys_env_destroy>
}
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	c9                   	leave  
  8005f6:	c3                   	ret    

008005f7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f7:	55                   	push   %ebp
  8005f8:	89 e5                	mov    %esp,%ebp
  8005fa:	56                   	push   %esi
  8005fb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005fc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005ff:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800605:	e8 36 0b 00 00       	call   801140 <sys_getenvid>
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	ff 75 0c             	pushl  0xc(%ebp)
  800610:	ff 75 08             	pushl  0x8(%ebp)
  800613:	56                   	push   %esi
  800614:	50                   	push   %eax
  800615:	68 20 26 80 00       	push   $0x802620
  80061a:	e8 b1 00 00 00       	call   8006d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80061f:	83 c4 18             	add    $0x18,%esp
  800622:	53                   	push   %ebx
  800623:	ff 75 10             	pushl  0x10(%ebp)
  800626:	e8 54 00 00 00       	call   80067f <vcprintf>
	cprintf("\n");
  80062b:	c7 04 24 30 25 80 00 	movl   $0x802530,(%esp)
  800632:	e8 99 00 00 00       	call   8006d0 <cprintf>
  800637:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80063a:	cc                   	int3   
  80063b:	eb fd                	jmp    80063a <_panic+0x43>

0080063d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	53                   	push   %ebx
  800641:	83 ec 04             	sub    $0x4,%esp
  800644:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800647:	8b 13                	mov    (%ebx),%edx
  800649:	8d 42 01             	lea    0x1(%edx),%eax
  80064c:	89 03                	mov    %eax,(%ebx)
  80064e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800651:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800655:	3d ff 00 00 00       	cmp    $0xff,%eax
  80065a:	75 1a                	jne    800676 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	68 ff 00 00 00       	push   $0xff
  800664:	8d 43 08             	lea    0x8(%ebx),%eax
  800667:	50                   	push   %eax
  800668:	e8 55 0a 00 00       	call   8010c2 <sys_cputs>
		b->idx = 0;
  80066d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800673:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800676:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80067a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80067d:	c9                   	leave  
  80067e:	c3                   	ret    

0080067f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800688:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80068f:	00 00 00 
	b.cnt = 0;
  800692:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800699:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80069c:	ff 75 0c             	pushl  0xc(%ebp)
  80069f:	ff 75 08             	pushl  0x8(%ebp)
  8006a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a8:	50                   	push   %eax
  8006a9:	68 3d 06 80 00       	push   $0x80063d
  8006ae:	e8 54 01 00 00       	call   800807 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006b3:	83 c4 08             	add    $0x8,%esp
  8006b6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006c2:	50                   	push   %eax
  8006c3:	e8 fa 09 00 00       	call   8010c2 <sys_cputs>

	return b.cnt;
}
  8006c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d9:	50                   	push   %eax
  8006da:	ff 75 08             	pushl  0x8(%ebp)
  8006dd:	e8 9d ff ff ff       	call   80067f <vcprintf>
	va_end(ap);

	return cnt;
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	57                   	push   %edi
  8006e8:	56                   	push   %esi
  8006e9:	53                   	push   %ebx
  8006ea:	83 ec 1c             	sub    $0x1c,%esp
  8006ed:	89 c7                	mov    %eax,%edi
  8006ef:	89 d6                	mov    %edx,%esi
  8006f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800700:	bb 00 00 00 00       	mov    $0x0,%ebx
  800705:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800708:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80070b:	39 d3                	cmp    %edx,%ebx
  80070d:	72 05                	jb     800714 <printnum+0x30>
  80070f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800712:	77 45                	ja     800759 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800714:	83 ec 0c             	sub    $0xc,%esp
  800717:	ff 75 18             	pushl  0x18(%ebp)
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800720:	53                   	push   %ebx
  800721:	ff 75 10             	pushl  0x10(%ebp)
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	ff 75 e4             	pushl  -0x1c(%ebp)
  80072a:	ff 75 e0             	pushl  -0x20(%ebp)
  80072d:	ff 75 dc             	pushl  -0x24(%ebp)
  800730:	ff 75 d8             	pushl  -0x28(%ebp)
  800733:	e8 38 1b 00 00       	call   802270 <__udivdi3>
  800738:	83 c4 18             	add    $0x18,%esp
  80073b:	52                   	push   %edx
  80073c:	50                   	push   %eax
  80073d:	89 f2                	mov    %esi,%edx
  80073f:	89 f8                	mov    %edi,%eax
  800741:	e8 9e ff ff ff       	call   8006e4 <printnum>
  800746:	83 c4 20             	add    $0x20,%esp
  800749:	eb 18                	jmp    800763 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	56                   	push   %esi
  80074f:	ff 75 18             	pushl  0x18(%ebp)
  800752:	ff d7                	call   *%edi
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	eb 03                	jmp    80075c <printnum+0x78>
  800759:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80075c:	83 eb 01             	sub    $0x1,%ebx
  80075f:	85 db                	test   %ebx,%ebx
  800761:	7f e8                	jg     80074b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	56                   	push   %esi
  800767:	83 ec 04             	sub    $0x4,%esp
  80076a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80076d:	ff 75 e0             	pushl  -0x20(%ebp)
  800770:	ff 75 dc             	pushl  -0x24(%ebp)
  800773:	ff 75 d8             	pushl  -0x28(%ebp)
  800776:	e8 25 1c 00 00       	call   8023a0 <__umoddi3>
  80077b:	83 c4 14             	add    $0x14,%esp
  80077e:	0f be 80 43 26 80 00 	movsbl 0x802643(%eax),%eax
  800785:	50                   	push   %eax
  800786:	ff d7                	call   *%edi
}
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078e:	5b                   	pop    %ebx
  80078f:	5e                   	pop    %esi
  800790:	5f                   	pop    %edi
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800796:	83 fa 01             	cmp    $0x1,%edx
  800799:	7e 0e                	jle    8007a9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80079b:	8b 10                	mov    (%eax),%edx
  80079d:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007a0:	89 08                	mov    %ecx,(%eax)
  8007a2:	8b 02                	mov    (%edx),%eax
  8007a4:	8b 52 04             	mov    0x4(%edx),%edx
  8007a7:	eb 22                	jmp    8007cb <getuint+0x38>
	else if (lflag)
  8007a9:	85 d2                	test   %edx,%edx
  8007ab:	74 10                	je     8007bd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007ad:	8b 10                	mov    (%eax),%edx
  8007af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b2:	89 08                	mov    %ecx,(%eax)
  8007b4:	8b 02                	mov    (%edx),%eax
  8007b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8007bb:	eb 0e                	jmp    8007cb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007bd:	8b 10                	mov    (%eax),%edx
  8007bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007c2:	89 08                	mov    %ecx,(%eax)
  8007c4:	8b 02                	mov    (%edx),%eax
  8007c6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007d7:	8b 10                	mov    (%eax),%edx
  8007d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8007dc:	73 0a                	jae    8007e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007de:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007e1:	89 08                	mov    %ecx,(%eax)
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	88 02                	mov    %al,(%edx)
}
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007f3:	50                   	push   %eax
  8007f4:	ff 75 10             	pushl  0x10(%ebp)
  8007f7:	ff 75 0c             	pushl  0xc(%ebp)
  8007fa:	ff 75 08             	pushl  0x8(%ebp)
  8007fd:	e8 05 00 00 00       	call   800807 <vprintfmt>
	va_end(ap);
}
  800802:	83 c4 10             	add    $0x10,%esp
  800805:	c9                   	leave  
  800806:	c3                   	ret    

00800807 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	57                   	push   %edi
  80080b:	56                   	push   %esi
  80080c:	53                   	push   %ebx
  80080d:	83 ec 2c             	sub    $0x2c,%esp
  800810:	8b 75 08             	mov    0x8(%ebp),%esi
  800813:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800816:	8b 7d 10             	mov    0x10(%ebp),%edi
  800819:	eb 12                	jmp    80082d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80081b:	85 c0                	test   %eax,%eax
  80081d:	0f 84 38 04 00 00    	je     800c5b <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	53                   	push   %ebx
  800827:	50                   	push   %eax
  800828:	ff d6                	call   *%esi
  80082a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80082d:	83 c7 01             	add    $0x1,%edi
  800830:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800834:	83 f8 25             	cmp    $0x25,%eax
  800837:	75 e2                	jne    80081b <vprintfmt+0x14>
  800839:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80083d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800844:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80084b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800852:	ba 00 00 00 00       	mov    $0x0,%edx
  800857:	eb 07                	jmp    800860 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800859:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  80085c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800860:	8d 47 01             	lea    0x1(%edi),%eax
  800863:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800866:	0f b6 07             	movzbl (%edi),%eax
  800869:	0f b6 c8             	movzbl %al,%ecx
  80086c:	83 e8 23             	sub    $0x23,%eax
  80086f:	3c 55                	cmp    $0x55,%al
  800871:	0f 87 c9 03 00 00    	ja     800c40 <vprintfmt+0x439>
  800877:	0f b6 c0             	movzbl %al,%eax
  80087a:	ff 24 85 80 27 80 00 	jmp    *0x802780(,%eax,4)
  800881:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800884:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800888:	eb d6                	jmp    800860 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  80088a:	c7 05 ac 40 80 00 00 	movl   $0x0,0x8040ac
  800891:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800894:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  800897:	eb 94                	jmp    80082d <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  800899:	c7 05 ac 40 80 00 01 	movl   $0x1,0x8040ac
  8008a0:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  8008a6:	eb 85                	jmp    80082d <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  8008a8:	c7 05 ac 40 80 00 02 	movl   $0x2,0x8040ac
  8008af:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  8008b5:	e9 73 ff ff ff       	jmp    80082d <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  8008ba:	c7 05 ac 40 80 00 03 	movl   $0x3,0x8040ac
  8008c1:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  8008c7:	e9 61 ff ff ff       	jmp    80082d <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  8008cc:	c7 05 ac 40 80 00 04 	movl   $0x4,0x8040ac
  8008d3:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  8008d9:	e9 4f ff ff ff       	jmp    80082d <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  8008de:	c7 05 ac 40 80 00 05 	movl   $0x5,0x8040ac
  8008e5:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  8008eb:	e9 3d ff ff ff       	jmp    80082d <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  8008f0:	c7 05 ac 40 80 00 06 	movl   $0x6,0x8040ac
  8008f7:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  8008fd:	e9 2b ff ff ff       	jmp    80082d <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  800902:	c7 05 ac 40 80 00 07 	movl   $0x7,0x8040ac
  800909:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  80090f:	e9 19 ff ff ff       	jmp    80082d <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  800914:	c7 05 ac 40 80 00 08 	movl   $0x8,0x8040ac
  80091b:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  800921:	e9 07 ff ff ff       	jmp    80082d <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  800926:	c7 05 ac 40 80 00 09 	movl   $0x9,0x8040ac
  80092d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800930:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  800933:	e9 f5 fe ff ff       	jmp    80082d <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800938:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80093b:	b8 00 00 00 00       	mov    $0x0,%eax
  800940:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800943:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800946:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80094a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80094d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800950:	83 fa 09             	cmp    $0x9,%edx
  800953:	77 3f                	ja     800994 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800955:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800958:	eb e9                	jmp    800943 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80095a:	8b 45 14             	mov    0x14(%ebp),%eax
  80095d:	8d 48 04             	lea    0x4(%eax),%ecx
  800960:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800963:	8b 00                	mov    (%eax),%eax
  800965:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800968:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80096b:	eb 2d                	jmp    80099a <vprintfmt+0x193>
  80096d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800970:	85 c0                	test   %eax,%eax
  800972:	b9 00 00 00 00       	mov    $0x0,%ecx
  800977:	0f 49 c8             	cmovns %eax,%ecx
  80097a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800980:	e9 db fe ff ff       	jmp    800860 <vprintfmt+0x59>
  800985:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800988:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80098f:	e9 cc fe ff ff       	jmp    800860 <vprintfmt+0x59>
  800994:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800997:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80099a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80099e:	0f 89 bc fe ff ff    	jns    800860 <vprintfmt+0x59>
				width = precision, precision = -1;
  8009a4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8009a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009aa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8009b1:	e9 aa fe ff ff       	jmp    800860 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8009b6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8009bc:	e9 9f fe ff ff       	jmp    800860 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8009c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c4:	8d 50 04             	lea    0x4(%eax),%edx
  8009c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ca:	83 ec 08             	sub    $0x8,%esp
  8009cd:	53                   	push   %ebx
  8009ce:	ff 30                	pushl  (%eax)
  8009d0:	ff d6                	call   *%esi
			break;
  8009d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009d8:	e9 50 fe ff ff       	jmp    80082d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e0:	8d 50 04             	lea    0x4(%eax),%edx
  8009e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8009e6:	8b 00                	mov    (%eax),%eax
  8009e8:	99                   	cltd   
  8009e9:	31 d0                	xor    %edx,%eax
  8009eb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009ed:	83 f8 0f             	cmp    $0xf,%eax
  8009f0:	7f 0b                	jg     8009fd <vprintfmt+0x1f6>
  8009f2:	8b 14 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%edx
  8009f9:	85 d2                	test   %edx,%edx
  8009fb:	75 18                	jne    800a15 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  8009fd:	50                   	push   %eax
  8009fe:	68 5b 26 80 00       	push   $0x80265b
  800a03:	53                   	push   %ebx
  800a04:	56                   	push   %esi
  800a05:	e8 e0 fd ff ff       	call   8007ea <printfmt>
  800a0a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800a10:	e9 18 fe ff ff       	jmp    80082d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800a15:	52                   	push   %edx
  800a16:	68 3d 2a 80 00       	push   $0x802a3d
  800a1b:	53                   	push   %ebx
  800a1c:	56                   	push   %esi
  800a1d:	e8 c8 fd ff ff       	call   8007ea <printfmt>
  800a22:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a28:	e9 00 fe ff ff       	jmp    80082d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a2d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a30:	8d 50 04             	lea    0x4(%eax),%edx
  800a33:	89 55 14             	mov    %edx,0x14(%ebp)
  800a36:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a38:	85 ff                	test   %edi,%edi
  800a3a:	b8 54 26 80 00       	mov    $0x802654,%eax
  800a3f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a42:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a46:	0f 8e 94 00 00 00    	jle    800ae0 <vprintfmt+0x2d9>
  800a4c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a50:	0f 84 98 00 00 00    	je     800aee <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a56:	83 ec 08             	sub    $0x8,%esp
  800a59:	ff 75 d0             	pushl  -0x30(%ebp)
  800a5c:	57                   	push   %edi
  800a5d:	e8 81 02 00 00       	call   800ce3 <strnlen>
  800a62:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a65:	29 c1                	sub    %eax,%ecx
  800a67:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800a6a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a6d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a71:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a74:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a77:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a79:	eb 0f                	jmp    800a8a <vprintfmt+0x283>
					putch(padc, putdat);
  800a7b:	83 ec 08             	sub    $0x8,%esp
  800a7e:	53                   	push   %ebx
  800a7f:	ff 75 e0             	pushl  -0x20(%ebp)
  800a82:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a84:	83 ef 01             	sub    $0x1,%edi
  800a87:	83 c4 10             	add    $0x10,%esp
  800a8a:	85 ff                	test   %edi,%edi
  800a8c:	7f ed                	jg     800a7b <vprintfmt+0x274>
  800a8e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a91:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a94:	85 c9                	test   %ecx,%ecx
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9b:	0f 49 c1             	cmovns %ecx,%eax
  800a9e:	29 c1                	sub    %eax,%ecx
  800aa0:	89 75 08             	mov    %esi,0x8(%ebp)
  800aa3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800aa6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800aa9:	89 cb                	mov    %ecx,%ebx
  800aab:	eb 4d                	jmp    800afa <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800aad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ab1:	74 1b                	je     800ace <vprintfmt+0x2c7>
  800ab3:	0f be c0             	movsbl %al,%eax
  800ab6:	83 e8 20             	sub    $0x20,%eax
  800ab9:	83 f8 5e             	cmp    $0x5e,%eax
  800abc:	76 10                	jbe    800ace <vprintfmt+0x2c7>
					putch('?', putdat);
  800abe:	83 ec 08             	sub    $0x8,%esp
  800ac1:	ff 75 0c             	pushl  0xc(%ebp)
  800ac4:	6a 3f                	push   $0x3f
  800ac6:	ff 55 08             	call   *0x8(%ebp)
  800ac9:	83 c4 10             	add    $0x10,%esp
  800acc:	eb 0d                	jmp    800adb <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  800ace:	83 ec 08             	sub    $0x8,%esp
  800ad1:	ff 75 0c             	pushl  0xc(%ebp)
  800ad4:	52                   	push   %edx
  800ad5:	ff 55 08             	call   *0x8(%ebp)
  800ad8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800adb:	83 eb 01             	sub    $0x1,%ebx
  800ade:	eb 1a                	jmp    800afa <vprintfmt+0x2f3>
  800ae0:	89 75 08             	mov    %esi,0x8(%ebp)
  800ae3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ae6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ae9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800aec:	eb 0c                	jmp    800afa <vprintfmt+0x2f3>
  800aee:	89 75 08             	mov    %esi,0x8(%ebp)
  800af1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800af4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800af7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800afa:	83 c7 01             	add    $0x1,%edi
  800afd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800b01:	0f be d0             	movsbl %al,%edx
  800b04:	85 d2                	test   %edx,%edx
  800b06:	74 23                	je     800b2b <vprintfmt+0x324>
  800b08:	85 f6                	test   %esi,%esi
  800b0a:	78 a1                	js     800aad <vprintfmt+0x2a6>
  800b0c:	83 ee 01             	sub    $0x1,%esi
  800b0f:	79 9c                	jns    800aad <vprintfmt+0x2a6>
  800b11:	89 df                	mov    %ebx,%edi
  800b13:	8b 75 08             	mov    0x8(%ebp),%esi
  800b16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b19:	eb 18                	jmp    800b33 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b1b:	83 ec 08             	sub    $0x8,%esp
  800b1e:	53                   	push   %ebx
  800b1f:	6a 20                	push   $0x20
  800b21:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b23:	83 ef 01             	sub    $0x1,%edi
  800b26:	83 c4 10             	add    $0x10,%esp
  800b29:	eb 08                	jmp    800b33 <vprintfmt+0x32c>
  800b2b:	89 df                	mov    %ebx,%edi
  800b2d:	8b 75 08             	mov    0x8(%ebp),%esi
  800b30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b33:	85 ff                	test   %edi,%edi
  800b35:	7f e4                	jg     800b1b <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b37:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b3a:	e9 ee fc ff ff       	jmp    80082d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b3f:	83 fa 01             	cmp    $0x1,%edx
  800b42:	7e 16                	jle    800b5a <vprintfmt+0x353>
		return va_arg(*ap, long long);
  800b44:	8b 45 14             	mov    0x14(%ebp),%eax
  800b47:	8d 50 08             	lea    0x8(%eax),%edx
  800b4a:	89 55 14             	mov    %edx,0x14(%ebp)
  800b4d:	8b 50 04             	mov    0x4(%eax),%edx
  800b50:	8b 00                	mov    (%eax),%eax
  800b52:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b55:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b58:	eb 32                	jmp    800b8c <vprintfmt+0x385>
	else if (lflag)
  800b5a:	85 d2                	test   %edx,%edx
  800b5c:	74 18                	je     800b76 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  800b5e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b61:	8d 50 04             	lea    0x4(%eax),%edx
  800b64:	89 55 14             	mov    %edx,0x14(%ebp)
  800b67:	8b 00                	mov    (%eax),%eax
  800b69:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b6c:	89 c1                	mov    %eax,%ecx
  800b6e:	c1 f9 1f             	sar    $0x1f,%ecx
  800b71:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b74:	eb 16                	jmp    800b8c <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  800b76:	8b 45 14             	mov    0x14(%ebp),%eax
  800b79:	8d 50 04             	lea    0x4(%eax),%edx
  800b7c:	89 55 14             	mov    %edx,0x14(%ebp)
  800b7f:	8b 00                	mov    (%eax),%eax
  800b81:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b84:	89 c1                	mov    %eax,%ecx
  800b86:	c1 f9 1f             	sar    $0x1f,%ecx
  800b89:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b8c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b8f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b92:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b97:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b9b:	79 6f                	jns    800c0c <vprintfmt+0x405>
				putch('-', putdat);
  800b9d:	83 ec 08             	sub    $0x8,%esp
  800ba0:	53                   	push   %ebx
  800ba1:	6a 2d                	push   $0x2d
  800ba3:	ff d6                	call   *%esi
				num = -(long long) num;
  800ba5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ba8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800bab:	f7 d8                	neg    %eax
  800bad:	83 d2 00             	adc    $0x0,%edx
  800bb0:	f7 da                	neg    %edx
  800bb2:	83 c4 10             	add    $0x10,%esp
  800bb5:	eb 55                	jmp    800c0c <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800bb7:	8d 45 14             	lea    0x14(%ebp),%eax
  800bba:	e8 d4 fb ff ff       	call   800793 <getuint>
			base = 10;
  800bbf:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800bc4:	eb 46                	jmp    800c0c <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800bc6:	8d 45 14             	lea    0x14(%ebp),%eax
  800bc9:	e8 c5 fb ff ff       	call   800793 <getuint>
			base = 8;
  800bce:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  800bd3:	eb 37                	jmp    800c0c <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  800bd5:	83 ec 08             	sub    $0x8,%esp
  800bd8:	53                   	push   %ebx
  800bd9:	6a 30                	push   $0x30
  800bdb:	ff d6                	call   *%esi
			putch('x', putdat);
  800bdd:	83 c4 08             	add    $0x8,%esp
  800be0:	53                   	push   %ebx
  800be1:	6a 78                	push   $0x78
  800be3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800be5:	8b 45 14             	mov    0x14(%ebp),%eax
  800be8:	8d 50 04             	lea    0x4(%eax),%edx
  800beb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bee:	8b 00                	mov    (%eax),%eax
  800bf0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bf5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bf8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800bfd:	eb 0d                	jmp    800c0c <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bff:	8d 45 14             	lea    0x14(%ebp),%eax
  800c02:	e8 8c fb ff ff       	call   800793 <getuint>
			base = 16;
  800c07:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c0c:	83 ec 0c             	sub    $0xc,%esp
  800c0f:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800c13:	51                   	push   %ecx
  800c14:	ff 75 e0             	pushl  -0x20(%ebp)
  800c17:	57                   	push   %edi
  800c18:	52                   	push   %edx
  800c19:	50                   	push   %eax
  800c1a:	89 da                	mov    %ebx,%edx
  800c1c:	89 f0                	mov    %esi,%eax
  800c1e:	e8 c1 fa ff ff       	call   8006e4 <printnum>
			break;
  800c23:	83 c4 20             	add    $0x20,%esp
  800c26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c29:	e9 ff fb ff ff       	jmp    80082d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c2e:	83 ec 08             	sub    $0x8,%esp
  800c31:	53                   	push   %ebx
  800c32:	51                   	push   %ecx
  800c33:	ff d6                	call   *%esi
			break;
  800c35:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c38:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c3b:	e9 ed fb ff ff       	jmp    80082d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c40:	83 ec 08             	sub    $0x8,%esp
  800c43:	53                   	push   %ebx
  800c44:	6a 25                	push   $0x25
  800c46:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c48:	83 c4 10             	add    $0x10,%esp
  800c4b:	eb 03                	jmp    800c50 <vprintfmt+0x449>
  800c4d:	83 ef 01             	sub    $0x1,%edi
  800c50:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c54:	75 f7                	jne    800c4d <vprintfmt+0x446>
  800c56:	e9 d2 fb ff ff       	jmp    80082d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	83 ec 18             	sub    $0x18,%esp
  800c69:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c72:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c76:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c79:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	74 26                	je     800caa <vsnprintf+0x47>
  800c84:	85 d2                	test   %edx,%edx
  800c86:	7e 22                	jle    800caa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c88:	ff 75 14             	pushl  0x14(%ebp)
  800c8b:	ff 75 10             	pushl  0x10(%ebp)
  800c8e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c91:	50                   	push   %eax
  800c92:	68 cd 07 80 00       	push   $0x8007cd
  800c97:	e8 6b fb ff ff       	call   800807 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c9f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca5:	83 c4 10             	add    $0x10,%esp
  800ca8:	eb 05                	jmp    800caf <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800caa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    

00800cb1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cb7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cba:	50                   	push   %eax
  800cbb:	ff 75 10             	pushl  0x10(%ebp)
  800cbe:	ff 75 0c             	pushl  0xc(%ebp)
  800cc1:	ff 75 08             	pushl  0x8(%ebp)
  800cc4:	e8 9a ff ff ff       	call   800c63 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cc9:	c9                   	leave  
  800cca:	c3                   	ret    

00800ccb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd6:	eb 03                	jmp    800cdb <strlen+0x10>
		n++;
  800cd8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cdb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cdf:	75 f7                	jne    800cd8 <strlen+0xd>
		n++;
	return n;
}
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cec:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf1:	eb 03                	jmp    800cf6 <strnlen+0x13>
		n++;
  800cf3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cf6:	39 c2                	cmp    %eax,%edx
  800cf8:	74 08                	je     800d02 <strnlen+0x1f>
  800cfa:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800cfe:	75 f3                	jne    800cf3 <strnlen+0x10>
  800d00:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	53                   	push   %ebx
  800d08:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d0e:	89 c2                	mov    %eax,%edx
  800d10:	83 c2 01             	add    $0x1,%edx
  800d13:	83 c1 01             	add    $0x1,%ecx
  800d16:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d1a:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d1d:	84 db                	test   %bl,%bl
  800d1f:	75 ef                	jne    800d10 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d21:	5b                   	pop    %ebx
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	53                   	push   %ebx
  800d28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d2b:	53                   	push   %ebx
  800d2c:	e8 9a ff ff ff       	call   800ccb <strlen>
  800d31:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d34:	ff 75 0c             	pushl  0xc(%ebp)
  800d37:	01 d8                	add    %ebx,%eax
  800d39:	50                   	push   %eax
  800d3a:	e8 c5 ff ff ff       	call   800d04 <strcpy>
	return dst;
}
  800d3f:	89 d8                	mov    %ebx,%eax
  800d41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d44:	c9                   	leave  
  800d45:	c3                   	ret    

00800d46 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	8b 75 08             	mov    0x8(%ebp),%esi
  800d4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d51:	89 f3                	mov    %esi,%ebx
  800d53:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d56:	89 f2                	mov    %esi,%edx
  800d58:	eb 0f                	jmp    800d69 <strncpy+0x23>
		*dst++ = *src;
  800d5a:	83 c2 01             	add    $0x1,%edx
  800d5d:	0f b6 01             	movzbl (%ecx),%eax
  800d60:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d63:	80 39 01             	cmpb   $0x1,(%ecx)
  800d66:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d69:	39 da                	cmp    %ebx,%edx
  800d6b:	75 ed                	jne    800d5a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d6d:	89 f0                	mov    %esi,%eax
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	8b 75 08             	mov    0x8(%ebp),%esi
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7e:	8b 55 10             	mov    0x10(%ebp),%edx
  800d81:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d83:	85 d2                	test   %edx,%edx
  800d85:	74 21                	je     800da8 <strlcpy+0x35>
  800d87:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d8b:	89 f2                	mov    %esi,%edx
  800d8d:	eb 09                	jmp    800d98 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d8f:	83 c2 01             	add    $0x1,%edx
  800d92:	83 c1 01             	add    $0x1,%ecx
  800d95:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d98:	39 c2                	cmp    %eax,%edx
  800d9a:	74 09                	je     800da5 <strlcpy+0x32>
  800d9c:	0f b6 19             	movzbl (%ecx),%ebx
  800d9f:	84 db                	test   %bl,%bl
  800da1:	75 ec                	jne    800d8f <strlcpy+0x1c>
  800da3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800da5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800da8:	29 f0                	sub    %esi,%eax
}
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800db7:	eb 06                	jmp    800dbf <strcmp+0x11>
		p++, q++;
  800db9:	83 c1 01             	add    $0x1,%ecx
  800dbc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800dbf:	0f b6 01             	movzbl (%ecx),%eax
  800dc2:	84 c0                	test   %al,%al
  800dc4:	74 04                	je     800dca <strcmp+0x1c>
  800dc6:	3a 02                	cmp    (%edx),%al
  800dc8:	74 ef                	je     800db9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dca:	0f b6 c0             	movzbl %al,%eax
  800dcd:	0f b6 12             	movzbl (%edx),%edx
  800dd0:	29 d0                	sub    %edx,%eax
}
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	53                   	push   %ebx
  800dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dde:	89 c3                	mov    %eax,%ebx
  800de0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800de3:	eb 06                	jmp    800deb <strncmp+0x17>
		n--, p++, q++;
  800de5:	83 c0 01             	add    $0x1,%eax
  800de8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800deb:	39 d8                	cmp    %ebx,%eax
  800ded:	74 15                	je     800e04 <strncmp+0x30>
  800def:	0f b6 08             	movzbl (%eax),%ecx
  800df2:	84 c9                	test   %cl,%cl
  800df4:	74 04                	je     800dfa <strncmp+0x26>
  800df6:	3a 0a                	cmp    (%edx),%cl
  800df8:	74 eb                	je     800de5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dfa:	0f b6 00             	movzbl (%eax),%eax
  800dfd:	0f b6 12             	movzbl (%edx),%edx
  800e00:	29 d0                	sub    %edx,%eax
  800e02:	eb 05                	jmp    800e09 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e04:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e09:	5b                   	pop    %ebx
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e12:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e16:	eb 07                	jmp    800e1f <strchr+0x13>
		if (*s == c)
  800e18:	38 ca                	cmp    %cl,%dl
  800e1a:	74 0f                	je     800e2b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e1c:	83 c0 01             	add    $0x1,%eax
  800e1f:	0f b6 10             	movzbl (%eax),%edx
  800e22:	84 d2                	test   %dl,%dl
  800e24:	75 f2                	jne    800e18 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	8b 45 08             	mov    0x8(%ebp),%eax
  800e33:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e37:	eb 03                	jmp    800e3c <strfind+0xf>
  800e39:	83 c0 01             	add    $0x1,%eax
  800e3c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e3f:	38 ca                	cmp    %cl,%dl
  800e41:	74 04                	je     800e47 <strfind+0x1a>
  800e43:	84 d2                	test   %dl,%dl
  800e45:	75 f2                	jne    800e39 <strfind+0xc>
			break;
	return (char *) s;
}
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
  800e4f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e52:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e55:	85 c9                	test   %ecx,%ecx
  800e57:	74 36                	je     800e8f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e59:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e5f:	75 28                	jne    800e89 <memset+0x40>
  800e61:	f6 c1 03             	test   $0x3,%cl
  800e64:	75 23                	jne    800e89 <memset+0x40>
		c &= 0xFF;
  800e66:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e6a:	89 d3                	mov    %edx,%ebx
  800e6c:	c1 e3 08             	shl    $0x8,%ebx
  800e6f:	89 d6                	mov    %edx,%esi
  800e71:	c1 e6 18             	shl    $0x18,%esi
  800e74:	89 d0                	mov    %edx,%eax
  800e76:	c1 e0 10             	shl    $0x10,%eax
  800e79:	09 f0                	or     %esi,%eax
  800e7b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e7d:	89 d8                	mov    %ebx,%eax
  800e7f:	09 d0                	or     %edx,%eax
  800e81:	c1 e9 02             	shr    $0x2,%ecx
  800e84:	fc                   	cld    
  800e85:	f3 ab                	rep stos %eax,%es:(%edi)
  800e87:	eb 06                	jmp    800e8f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8c:	fc                   	cld    
  800e8d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e8f:	89 f8                	mov    %edi,%eax
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ea1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ea4:	39 c6                	cmp    %eax,%esi
  800ea6:	73 35                	jae    800edd <memmove+0x47>
  800ea8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800eab:	39 d0                	cmp    %edx,%eax
  800ead:	73 2e                	jae    800edd <memmove+0x47>
		s += n;
		d += n;
  800eaf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eb2:	89 d6                	mov    %edx,%esi
  800eb4:	09 fe                	or     %edi,%esi
  800eb6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ebc:	75 13                	jne    800ed1 <memmove+0x3b>
  800ebe:	f6 c1 03             	test   $0x3,%cl
  800ec1:	75 0e                	jne    800ed1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ec3:	83 ef 04             	sub    $0x4,%edi
  800ec6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ec9:	c1 e9 02             	shr    $0x2,%ecx
  800ecc:	fd                   	std    
  800ecd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ecf:	eb 09                	jmp    800eda <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ed1:	83 ef 01             	sub    $0x1,%edi
  800ed4:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ed7:	fd                   	std    
  800ed8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800eda:	fc                   	cld    
  800edb:	eb 1d                	jmp    800efa <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800edd:	89 f2                	mov    %esi,%edx
  800edf:	09 c2                	or     %eax,%edx
  800ee1:	f6 c2 03             	test   $0x3,%dl
  800ee4:	75 0f                	jne    800ef5 <memmove+0x5f>
  800ee6:	f6 c1 03             	test   $0x3,%cl
  800ee9:	75 0a                	jne    800ef5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800eeb:	c1 e9 02             	shr    $0x2,%ecx
  800eee:	89 c7                	mov    %eax,%edi
  800ef0:	fc                   	cld    
  800ef1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ef3:	eb 05                	jmp    800efa <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ef5:	89 c7                	mov    %eax,%edi
  800ef7:	fc                   	cld    
  800ef8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800efa:	5e                   	pop    %esi
  800efb:	5f                   	pop    %edi
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f01:	ff 75 10             	pushl  0x10(%ebp)
  800f04:	ff 75 0c             	pushl  0xc(%ebp)
  800f07:	ff 75 08             	pushl  0x8(%ebp)
  800f0a:	e8 87 ff ff ff       	call   800e96 <memmove>
}
  800f0f:	c9                   	leave  
  800f10:	c3                   	ret    

00800f11 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	56                   	push   %esi
  800f15:	53                   	push   %ebx
  800f16:	8b 45 08             	mov    0x8(%ebp),%eax
  800f19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f1c:	89 c6                	mov    %eax,%esi
  800f1e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f21:	eb 1a                	jmp    800f3d <memcmp+0x2c>
		if (*s1 != *s2)
  800f23:	0f b6 08             	movzbl (%eax),%ecx
  800f26:	0f b6 1a             	movzbl (%edx),%ebx
  800f29:	38 d9                	cmp    %bl,%cl
  800f2b:	74 0a                	je     800f37 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f2d:	0f b6 c1             	movzbl %cl,%eax
  800f30:	0f b6 db             	movzbl %bl,%ebx
  800f33:	29 d8                	sub    %ebx,%eax
  800f35:	eb 0f                	jmp    800f46 <memcmp+0x35>
		s1++, s2++;
  800f37:	83 c0 01             	add    $0x1,%eax
  800f3a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f3d:	39 f0                	cmp    %esi,%eax
  800f3f:	75 e2                	jne    800f23 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f46:	5b                   	pop    %ebx
  800f47:	5e                   	pop    %esi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	53                   	push   %ebx
  800f4e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f51:	89 c1                	mov    %eax,%ecx
  800f53:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f56:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f5a:	eb 0a                	jmp    800f66 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f5c:	0f b6 10             	movzbl (%eax),%edx
  800f5f:	39 da                	cmp    %ebx,%edx
  800f61:	74 07                	je     800f6a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f63:	83 c0 01             	add    $0x1,%eax
  800f66:	39 c8                	cmp    %ecx,%eax
  800f68:	72 f2                	jb     800f5c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f6a:	5b                   	pop    %ebx
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	57                   	push   %edi
  800f71:	56                   	push   %esi
  800f72:	53                   	push   %ebx
  800f73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f79:	eb 03                	jmp    800f7e <strtol+0x11>
		s++;
  800f7b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f7e:	0f b6 01             	movzbl (%ecx),%eax
  800f81:	3c 20                	cmp    $0x20,%al
  800f83:	74 f6                	je     800f7b <strtol+0xe>
  800f85:	3c 09                	cmp    $0x9,%al
  800f87:	74 f2                	je     800f7b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f89:	3c 2b                	cmp    $0x2b,%al
  800f8b:	75 0a                	jne    800f97 <strtol+0x2a>
		s++;
  800f8d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f90:	bf 00 00 00 00       	mov    $0x0,%edi
  800f95:	eb 11                	jmp    800fa8 <strtol+0x3b>
  800f97:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f9c:	3c 2d                	cmp    $0x2d,%al
  800f9e:	75 08                	jne    800fa8 <strtol+0x3b>
		s++, neg = 1;
  800fa0:	83 c1 01             	add    $0x1,%ecx
  800fa3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fa8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800fae:	75 15                	jne    800fc5 <strtol+0x58>
  800fb0:	80 39 30             	cmpb   $0x30,(%ecx)
  800fb3:	75 10                	jne    800fc5 <strtol+0x58>
  800fb5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800fb9:	75 7c                	jne    801037 <strtol+0xca>
		s += 2, base = 16;
  800fbb:	83 c1 02             	add    $0x2,%ecx
  800fbe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fc3:	eb 16                	jmp    800fdb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800fc5:	85 db                	test   %ebx,%ebx
  800fc7:	75 12                	jne    800fdb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fc9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fce:	80 39 30             	cmpb   $0x30,(%ecx)
  800fd1:	75 08                	jne    800fdb <strtol+0x6e>
		s++, base = 8;
  800fd3:	83 c1 01             	add    $0x1,%ecx
  800fd6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800fdb:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fe3:	0f b6 11             	movzbl (%ecx),%edx
  800fe6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800fe9:	89 f3                	mov    %esi,%ebx
  800feb:	80 fb 09             	cmp    $0x9,%bl
  800fee:	77 08                	ja     800ff8 <strtol+0x8b>
			dig = *s - '0';
  800ff0:	0f be d2             	movsbl %dl,%edx
  800ff3:	83 ea 30             	sub    $0x30,%edx
  800ff6:	eb 22                	jmp    80101a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ff8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ffb:	89 f3                	mov    %esi,%ebx
  800ffd:	80 fb 19             	cmp    $0x19,%bl
  801000:	77 08                	ja     80100a <strtol+0x9d>
			dig = *s - 'a' + 10;
  801002:	0f be d2             	movsbl %dl,%edx
  801005:	83 ea 57             	sub    $0x57,%edx
  801008:	eb 10                	jmp    80101a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80100a:	8d 72 bf             	lea    -0x41(%edx),%esi
  80100d:	89 f3                	mov    %esi,%ebx
  80100f:	80 fb 19             	cmp    $0x19,%bl
  801012:	77 16                	ja     80102a <strtol+0xbd>
			dig = *s - 'A' + 10;
  801014:	0f be d2             	movsbl %dl,%edx
  801017:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80101a:	3b 55 10             	cmp    0x10(%ebp),%edx
  80101d:	7d 0b                	jge    80102a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80101f:	83 c1 01             	add    $0x1,%ecx
  801022:	0f af 45 10          	imul   0x10(%ebp),%eax
  801026:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801028:	eb b9                	jmp    800fe3 <strtol+0x76>

	if (endptr)
  80102a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80102e:	74 0d                	je     80103d <strtol+0xd0>
		*endptr = (char *) s;
  801030:	8b 75 0c             	mov    0xc(%ebp),%esi
  801033:	89 0e                	mov    %ecx,(%esi)
  801035:	eb 06                	jmp    80103d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801037:	85 db                	test   %ebx,%ebx
  801039:	74 98                	je     800fd3 <strtol+0x66>
  80103b:	eb 9e                	jmp    800fdb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80103d:	89 c2                	mov    %eax,%edx
  80103f:	f7 da                	neg    %edx
  801041:	85 ff                	test   %edi,%edi
  801043:	0f 45 c2             	cmovne %edx,%eax
}
  801046:	5b                   	pop    %ebx
  801047:	5e                   	pop    %esi
  801048:	5f                   	pop    %edi
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    

0080104b <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	57                   	push   %edi
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
  801051:	83 ec 04             	sub    $0x4,%esp
  801054:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  801057:	57                   	push   %edi
  801058:	e8 6e fc ff ff       	call   800ccb <strlen>
  80105d:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801060:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  801063:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  801068:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  80106d:	eb 46                	jmp    8010b5 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  80106f:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  801073:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801076:	80 f9 09             	cmp    $0x9,%cl
  801079:	77 08                	ja     801083 <charhex_to_dec+0x38>
			num = s[i] - '0';
  80107b:	0f be d2             	movsbl %dl,%edx
  80107e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801081:	eb 27                	jmp    8010aa <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  801083:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  801086:	80 f9 05             	cmp    $0x5,%cl
  801089:	77 08                	ja     801093 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  80108b:	0f be d2             	movsbl %dl,%edx
  80108e:	8d 4a a9             	lea    -0x57(%edx),%ecx
  801091:	eb 17                	jmp    8010aa <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  801093:	8d 4a bf             	lea    -0x41(%edx),%ecx
  801096:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  801099:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  80109e:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  8010a2:	77 06                	ja     8010aa <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  8010a4:	0f be d2             	movsbl %dl,%edx
  8010a7:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  8010aa:	0f af ce             	imul   %esi,%ecx
  8010ad:	01 c8                	add    %ecx,%eax
		base *= 16;
  8010af:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  8010b2:	83 eb 01             	sub    $0x1,%ebx
  8010b5:	83 fb 01             	cmp    $0x1,%ebx
  8010b8:	7f b5                	jg     80106f <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  8010ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010bd:	5b                   	pop    %ebx
  8010be:	5e                   	pop    %esi
  8010bf:	5f                   	pop    %edi
  8010c0:	5d                   	pop    %ebp
  8010c1:	c3                   	ret    

008010c2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	57                   	push   %edi
  8010c6:	56                   	push   %esi
  8010c7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d3:	89 c3                	mov    %eax,%ebx
  8010d5:	89 c7                	mov    %eax,%edi
  8010d7:	89 c6                	mov    %eax,%esi
  8010d9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	57                   	push   %edi
  8010e4:	56                   	push   %esi
  8010e5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8010eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f0:	89 d1                	mov    %edx,%ecx
  8010f2:	89 d3                	mov    %edx,%ebx
  8010f4:	89 d7                	mov    %edx,%edi
  8010f6:	89 d6                	mov    %edx,%esi
  8010f8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010fa:	5b                   	pop    %ebx
  8010fb:	5e                   	pop    %esi
  8010fc:	5f                   	pop    %edi
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	57                   	push   %edi
  801103:	56                   	push   %esi
  801104:	53                   	push   %ebx
  801105:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801108:	b9 00 00 00 00       	mov    $0x0,%ecx
  80110d:	b8 03 00 00 00       	mov    $0x3,%eax
  801112:	8b 55 08             	mov    0x8(%ebp),%edx
  801115:	89 cb                	mov    %ecx,%ebx
  801117:	89 cf                	mov    %ecx,%edi
  801119:	89 ce                	mov    %ecx,%esi
  80111b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80111d:	85 c0                	test   %eax,%eax
  80111f:	7e 17                	jle    801138 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801121:	83 ec 0c             	sub    $0xc,%esp
  801124:	50                   	push   %eax
  801125:	6a 03                	push   $0x3
  801127:	68 3f 29 80 00       	push   $0x80293f
  80112c:	6a 23                	push   $0x23
  80112e:	68 5c 29 80 00       	push   $0x80295c
  801133:	e8 bf f4 ff ff       	call   8005f7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801138:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113b:	5b                   	pop    %ebx
  80113c:	5e                   	pop    %esi
  80113d:	5f                   	pop    %edi
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	57                   	push   %edi
  801144:	56                   	push   %esi
  801145:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801146:	ba 00 00 00 00       	mov    $0x0,%edx
  80114b:	b8 02 00 00 00       	mov    $0x2,%eax
  801150:	89 d1                	mov    %edx,%ecx
  801152:	89 d3                	mov    %edx,%ebx
  801154:	89 d7                	mov    %edx,%edi
  801156:	89 d6                	mov    %edx,%esi
  801158:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80115a:	5b                   	pop    %ebx
  80115b:	5e                   	pop    %esi
  80115c:	5f                   	pop    %edi
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    

0080115f <sys_yield>:

void
sys_yield(void)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	57                   	push   %edi
  801163:	56                   	push   %esi
  801164:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801165:	ba 00 00 00 00       	mov    $0x0,%edx
  80116a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80116f:	89 d1                	mov    %edx,%ecx
  801171:	89 d3                	mov    %edx,%ebx
  801173:	89 d7                	mov    %edx,%edi
  801175:	89 d6                	mov    %edx,%esi
  801177:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801179:	5b                   	pop    %ebx
  80117a:	5e                   	pop    %esi
  80117b:	5f                   	pop    %edi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    

0080117e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	57                   	push   %edi
  801182:	56                   	push   %esi
  801183:	53                   	push   %ebx
  801184:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801187:	be 00 00 00 00       	mov    $0x0,%esi
  80118c:	b8 04 00 00 00       	mov    $0x4,%eax
  801191:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801194:	8b 55 08             	mov    0x8(%ebp),%edx
  801197:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80119a:	89 f7                	mov    %esi,%edi
  80119c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	7e 17                	jle    8011b9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a2:	83 ec 0c             	sub    $0xc,%esp
  8011a5:	50                   	push   %eax
  8011a6:	6a 04                	push   $0x4
  8011a8:	68 3f 29 80 00       	push   $0x80293f
  8011ad:	6a 23                	push   $0x23
  8011af:	68 5c 29 80 00       	push   $0x80295c
  8011b4:	e8 3e f4 ff ff       	call   8005f7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bc:	5b                   	pop    %ebx
  8011bd:	5e                   	pop    %esi
  8011be:	5f                   	pop    %edi
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    

008011c1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	57                   	push   %edi
  8011c5:	56                   	push   %esi
  8011c6:	53                   	push   %ebx
  8011c7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8011cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011d8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011db:	8b 75 18             	mov    0x18(%ebp),%esi
  8011de:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	7e 17                	jle    8011fb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e4:	83 ec 0c             	sub    $0xc,%esp
  8011e7:	50                   	push   %eax
  8011e8:	6a 05                	push   $0x5
  8011ea:	68 3f 29 80 00       	push   $0x80293f
  8011ef:	6a 23                	push   $0x23
  8011f1:	68 5c 29 80 00       	push   $0x80295c
  8011f6:	e8 fc f3 ff ff       	call   8005f7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fe:	5b                   	pop    %ebx
  8011ff:	5e                   	pop    %esi
  801200:	5f                   	pop    %edi
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	57                   	push   %edi
  801207:	56                   	push   %esi
  801208:	53                   	push   %ebx
  801209:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80120c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801211:	b8 06 00 00 00       	mov    $0x6,%eax
  801216:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801219:	8b 55 08             	mov    0x8(%ebp),%edx
  80121c:	89 df                	mov    %ebx,%edi
  80121e:	89 de                	mov    %ebx,%esi
  801220:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801222:	85 c0                	test   %eax,%eax
  801224:	7e 17                	jle    80123d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801226:	83 ec 0c             	sub    $0xc,%esp
  801229:	50                   	push   %eax
  80122a:	6a 06                	push   $0x6
  80122c:	68 3f 29 80 00       	push   $0x80293f
  801231:	6a 23                	push   $0x23
  801233:	68 5c 29 80 00       	push   $0x80295c
  801238:	e8 ba f3 ff ff       	call   8005f7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80123d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801240:	5b                   	pop    %ebx
  801241:	5e                   	pop    %esi
  801242:	5f                   	pop    %edi
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    

00801245 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	57                   	push   %edi
  801249:	56                   	push   %esi
  80124a:	53                   	push   %ebx
  80124b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80124e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801253:	b8 08 00 00 00       	mov    $0x8,%eax
  801258:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80125b:	8b 55 08             	mov    0x8(%ebp),%edx
  80125e:	89 df                	mov    %ebx,%edi
  801260:	89 de                	mov    %ebx,%esi
  801262:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801264:	85 c0                	test   %eax,%eax
  801266:	7e 17                	jle    80127f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801268:	83 ec 0c             	sub    $0xc,%esp
  80126b:	50                   	push   %eax
  80126c:	6a 08                	push   $0x8
  80126e:	68 3f 29 80 00       	push   $0x80293f
  801273:	6a 23                	push   $0x23
  801275:	68 5c 29 80 00       	push   $0x80295c
  80127a:	e8 78 f3 ff ff       	call   8005f7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80127f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801282:	5b                   	pop    %ebx
  801283:	5e                   	pop    %esi
  801284:	5f                   	pop    %edi
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    

00801287 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	57                   	push   %edi
  80128b:	56                   	push   %esi
  80128c:	53                   	push   %ebx
  80128d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801290:	bb 00 00 00 00       	mov    $0x0,%ebx
  801295:	b8 0a 00 00 00       	mov    $0xa,%eax
  80129a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80129d:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a0:	89 df                	mov    %ebx,%edi
  8012a2:	89 de                	mov    %ebx,%esi
  8012a4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	7e 17                	jle    8012c1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012aa:	83 ec 0c             	sub    $0xc,%esp
  8012ad:	50                   	push   %eax
  8012ae:	6a 0a                	push   $0xa
  8012b0:	68 3f 29 80 00       	push   $0x80293f
  8012b5:	6a 23                	push   $0x23
  8012b7:	68 5c 29 80 00       	push   $0x80295c
  8012bc:	e8 36 f3 ff ff       	call   8005f7 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8012c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c4:	5b                   	pop    %ebx
  8012c5:	5e                   	pop    %esi
  8012c6:	5f                   	pop    %edi
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	57                   	push   %edi
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
  8012cf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d7:	b8 09 00 00 00       	mov    $0x9,%eax
  8012dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012df:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e2:	89 df                	mov    %ebx,%edi
  8012e4:	89 de                	mov    %ebx,%esi
  8012e6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	7e 17                	jle    801303 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012ec:	83 ec 0c             	sub    $0xc,%esp
  8012ef:	50                   	push   %eax
  8012f0:	6a 09                	push   $0x9
  8012f2:	68 3f 29 80 00       	push   $0x80293f
  8012f7:	6a 23                	push   $0x23
  8012f9:	68 5c 29 80 00       	push   $0x80295c
  8012fe:	e8 f4 f2 ff ff       	call   8005f7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801303:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801306:	5b                   	pop    %ebx
  801307:	5e                   	pop    %esi
  801308:	5f                   	pop    %edi
  801309:	5d                   	pop    %ebp
  80130a:	c3                   	ret    

0080130b <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	57                   	push   %edi
  80130f:	56                   	push   %esi
  801310:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801311:	be 00 00 00 00       	mov    $0x0,%esi
  801316:	b8 0c 00 00 00       	mov    $0xc,%eax
  80131b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80131e:	8b 55 08             	mov    0x8(%ebp),%edx
  801321:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801324:	8b 7d 14             	mov    0x14(%ebp),%edi
  801327:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801329:	5b                   	pop    %ebx
  80132a:	5e                   	pop    %esi
  80132b:	5f                   	pop    %edi
  80132c:	5d                   	pop    %ebp
  80132d:	c3                   	ret    

0080132e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	57                   	push   %edi
  801332:	56                   	push   %esi
  801333:	53                   	push   %ebx
  801334:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801337:	b9 00 00 00 00       	mov    $0x0,%ecx
  80133c:	b8 0d 00 00 00       	mov    $0xd,%eax
  801341:	8b 55 08             	mov    0x8(%ebp),%edx
  801344:	89 cb                	mov    %ecx,%ebx
  801346:	89 cf                	mov    %ecx,%edi
  801348:	89 ce                	mov    %ecx,%esi
  80134a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80134c:	85 c0                	test   %eax,%eax
  80134e:	7e 17                	jle    801367 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801350:	83 ec 0c             	sub    $0xc,%esp
  801353:	50                   	push   %eax
  801354:	6a 0d                	push   $0xd
  801356:	68 3f 29 80 00       	push   $0x80293f
  80135b:	6a 23                	push   $0x23
  80135d:	68 5c 29 80 00       	push   $0x80295c
  801362:	e8 90 f2 ff ff       	call   8005f7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801367:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80136a:	5b                   	pop    %ebx
  80136b:	5e                   	pop    %esi
  80136c:	5f                   	pop    %edi
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    

0080136f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801375:	83 3d b8 40 80 00 00 	cmpl   $0x0,0x8040b8
  80137c:	75 52                	jne    8013d0 <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  80137e:	83 ec 04             	sub    $0x4,%esp
  801381:	6a 07                	push   $0x7
  801383:	68 00 f0 bf ee       	push   $0xeebff000
  801388:	6a 00                	push   $0x0
  80138a:	e8 ef fd ff ff       	call   80117e <sys_page_alloc>
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	85 c0                	test   %eax,%eax
  801394:	79 12                	jns    8013a8 <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  801396:	50                   	push   %eax
  801397:	68 94 25 80 00       	push   $0x802594
  80139c:	6a 23                	push   $0x23
  80139e:	68 6a 29 80 00       	push   $0x80296a
  8013a3:	e8 4f f2 ff ff       	call   8005f7 <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	68 da 13 80 00       	push   $0x8013da
  8013b0:	6a 00                	push   $0x0
  8013b2:	e8 12 ff ff ff       	call   8012c9 <sys_env_set_pgfault_upcall>
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	79 12                	jns    8013d0 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  8013be:	50                   	push   %eax
  8013bf:	68 78 29 80 00       	push   $0x802978
  8013c4:	6a 26                	push   $0x26
  8013c6:	68 6a 29 80 00       	push   $0x80296a
  8013cb:	e8 27 f2 ff ff       	call   8005f7 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d3:	a3 b8 40 80 00       	mov    %eax,0x8040b8
}
  8013d8:	c9                   	leave  
  8013d9:	c3                   	ret    

008013da <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013da:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013db:	a1 b8 40 80 00       	mov    0x8040b8,%eax
	call *%eax
  8013e0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013e2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  8013e5:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  8013e9:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  8013ee:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  8013f2:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8013f4:	83 c4 08             	add    $0x8,%esp
	popal 
  8013f7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8013f8:	83 c4 04             	add    $0x4,%esp
	popfl
  8013fb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8013fc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8013fd:	c3                   	ret    

008013fe <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801401:	8b 45 08             	mov    0x8(%ebp),%eax
  801404:	05 00 00 00 30       	add    $0x30000000,%eax
  801409:	c1 e8 0c             	shr    $0xc,%eax
}
  80140c:	5d                   	pop    %ebp
  80140d:	c3                   	ret    

0080140e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801411:	8b 45 08             	mov    0x8(%ebp),%eax
  801414:	05 00 00 00 30       	add    $0x30000000,%eax
  801419:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80141e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    

00801425 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80142b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801430:	89 c2                	mov    %eax,%edx
  801432:	c1 ea 16             	shr    $0x16,%edx
  801435:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80143c:	f6 c2 01             	test   $0x1,%dl
  80143f:	74 11                	je     801452 <fd_alloc+0x2d>
  801441:	89 c2                	mov    %eax,%edx
  801443:	c1 ea 0c             	shr    $0xc,%edx
  801446:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80144d:	f6 c2 01             	test   $0x1,%dl
  801450:	75 09                	jne    80145b <fd_alloc+0x36>
			*fd_store = fd;
  801452:	89 01                	mov    %eax,(%ecx)
			return 0;
  801454:	b8 00 00 00 00       	mov    $0x0,%eax
  801459:	eb 17                	jmp    801472 <fd_alloc+0x4d>
  80145b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801460:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801465:	75 c9                	jne    801430 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801467:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80146d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801472:	5d                   	pop    %ebp
  801473:	c3                   	ret    

00801474 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80147a:	83 f8 1f             	cmp    $0x1f,%eax
  80147d:	77 36                	ja     8014b5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80147f:	c1 e0 0c             	shl    $0xc,%eax
  801482:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801487:	89 c2                	mov    %eax,%edx
  801489:	c1 ea 16             	shr    $0x16,%edx
  80148c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801493:	f6 c2 01             	test   $0x1,%dl
  801496:	74 24                	je     8014bc <fd_lookup+0x48>
  801498:	89 c2                	mov    %eax,%edx
  80149a:	c1 ea 0c             	shr    $0xc,%edx
  80149d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014a4:	f6 c2 01             	test   $0x1,%dl
  8014a7:	74 1a                	je     8014c3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ac:	89 02                	mov    %eax,(%edx)
	return 0;
  8014ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b3:	eb 13                	jmp    8014c8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ba:	eb 0c                	jmp    8014c8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c1:	eb 05                	jmp    8014c8 <fd_lookup+0x54>
  8014c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014c8:	5d                   	pop    %ebp
  8014c9:	c3                   	ret    

008014ca <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	83 ec 08             	sub    $0x8,%esp
  8014d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014d3:	ba 14 2a 80 00       	mov    $0x802a14,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014d8:	eb 13                	jmp    8014ed <dev_lookup+0x23>
  8014da:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014dd:	39 08                	cmp    %ecx,(%eax)
  8014df:	75 0c                	jne    8014ed <dev_lookup+0x23>
			*dev = devtab[i];
  8014e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014e4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014eb:	eb 2e                	jmp    80151b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014ed:	8b 02                	mov    (%edx),%eax
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	75 e7                	jne    8014da <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014f3:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8014f8:	8b 40 48             	mov    0x48(%eax),%eax
  8014fb:	83 ec 04             	sub    $0x4,%esp
  8014fe:	51                   	push   %ecx
  8014ff:	50                   	push   %eax
  801500:	68 98 29 80 00       	push   $0x802998
  801505:	e8 c6 f1 ff ff       	call   8006d0 <cprintf>
	*dev = 0;
  80150a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80150d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80151b:	c9                   	leave  
  80151c:	c3                   	ret    

0080151d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	56                   	push   %esi
  801521:	53                   	push   %ebx
  801522:	83 ec 10             	sub    $0x10,%esp
  801525:	8b 75 08             	mov    0x8(%ebp),%esi
  801528:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80152b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152e:	50                   	push   %eax
  80152f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801535:	c1 e8 0c             	shr    $0xc,%eax
  801538:	50                   	push   %eax
  801539:	e8 36 ff ff ff       	call   801474 <fd_lookup>
  80153e:	83 c4 08             	add    $0x8,%esp
  801541:	85 c0                	test   %eax,%eax
  801543:	78 05                	js     80154a <fd_close+0x2d>
	    || fd != fd2) 
  801545:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801548:	74 0c                	je     801556 <fd_close+0x39>
		return (must_exist ? r : 0); 
  80154a:	84 db                	test   %bl,%bl
  80154c:	ba 00 00 00 00       	mov    $0x0,%edx
  801551:	0f 44 c2             	cmove  %edx,%eax
  801554:	eb 41                	jmp    801597 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801556:	83 ec 08             	sub    $0x8,%esp
  801559:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155c:	50                   	push   %eax
  80155d:	ff 36                	pushl  (%esi)
  80155f:	e8 66 ff ff ff       	call   8014ca <dev_lookup>
  801564:	89 c3                	mov    %eax,%ebx
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 1a                	js     801587 <fd_close+0x6a>
		if (dev->dev_close) 
  80156d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801570:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  801573:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  801578:	85 c0                	test   %eax,%eax
  80157a:	74 0b                	je     801587 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80157c:	83 ec 0c             	sub    $0xc,%esp
  80157f:	56                   	push   %esi
  801580:	ff d0                	call   *%eax
  801582:	89 c3                	mov    %eax,%ebx
  801584:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801587:	83 ec 08             	sub    $0x8,%esp
  80158a:	56                   	push   %esi
  80158b:	6a 00                	push   $0x0
  80158d:	e8 71 fc ff ff       	call   801203 <sys_page_unmap>
	return r;
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	89 d8                	mov    %ebx,%eax
}
  801597:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159a:	5b                   	pop    %ebx
  80159b:	5e                   	pop    %esi
  80159c:	5d                   	pop    %ebp
  80159d:	c3                   	ret    

0080159e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80159e:	55                   	push   %ebp
  80159f:	89 e5                	mov    %esp,%ebp
  8015a1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a7:	50                   	push   %eax
  8015a8:	ff 75 08             	pushl  0x8(%ebp)
  8015ab:	e8 c4 fe ff ff       	call   801474 <fd_lookup>
  8015b0:	83 c4 08             	add    $0x8,%esp
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	78 10                	js     8015c7 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  8015b7:	83 ec 08             	sub    $0x8,%esp
  8015ba:	6a 01                	push   $0x1
  8015bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8015bf:	e8 59 ff ff ff       	call   80151d <fd_close>
  8015c4:	83 c4 10             	add    $0x10,%esp
}
  8015c7:	c9                   	leave  
  8015c8:	c3                   	ret    

008015c9 <close_all>:

void
close_all(void)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	53                   	push   %ebx
  8015cd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015d0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015d5:	83 ec 0c             	sub    $0xc,%esp
  8015d8:	53                   	push   %ebx
  8015d9:	e8 c0 ff ff ff       	call   80159e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015de:	83 c3 01             	add    $0x1,%ebx
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	83 fb 20             	cmp    $0x20,%ebx
  8015e7:	75 ec                	jne    8015d5 <close_all+0xc>
		close(i);
}
  8015e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ec:	c9                   	leave  
  8015ed:	c3                   	ret    

008015ee <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	57                   	push   %edi
  8015f2:	56                   	push   %esi
  8015f3:	53                   	push   %ebx
  8015f4:	83 ec 2c             	sub    $0x2c,%esp
  8015f7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	ff 75 08             	pushl  0x8(%ebp)
  801601:	e8 6e fe ff ff       	call   801474 <fd_lookup>
  801606:	83 c4 08             	add    $0x8,%esp
  801609:	85 c0                	test   %eax,%eax
  80160b:	0f 88 c1 00 00 00    	js     8016d2 <dup+0xe4>
		return r;
	close(newfdnum);
  801611:	83 ec 0c             	sub    $0xc,%esp
  801614:	56                   	push   %esi
  801615:	e8 84 ff ff ff       	call   80159e <close>

	newfd = INDEX2FD(newfdnum);
  80161a:	89 f3                	mov    %esi,%ebx
  80161c:	c1 e3 0c             	shl    $0xc,%ebx
  80161f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801625:	83 c4 04             	add    $0x4,%esp
  801628:	ff 75 e4             	pushl  -0x1c(%ebp)
  80162b:	e8 de fd ff ff       	call   80140e <fd2data>
  801630:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801632:	89 1c 24             	mov    %ebx,(%esp)
  801635:	e8 d4 fd ff ff       	call   80140e <fd2data>
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801640:	89 f8                	mov    %edi,%eax
  801642:	c1 e8 16             	shr    $0x16,%eax
  801645:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80164c:	a8 01                	test   $0x1,%al
  80164e:	74 37                	je     801687 <dup+0x99>
  801650:	89 f8                	mov    %edi,%eax
  801652:	c1 e8 0c             	shr    $0xc,%eax
  801655:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80165c:	f6 c2 01             	test   $0x1,%dl
  80165f:	74 26                	je     801687 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801661:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801668:	83 ec 0c             	sub    $0xc,%esp
  80166b:	25 07 0e 00 00       	and    $0xe07,%eax
  801670:	50                   	push   %eax
  801671:	ff 75 d4             	pushl  -0x2c(%ebp)
  801674:	6a 00                	push   $0x0
  801676:	57                   	push   %edi
  801677:	6a 00                	push   $0x0
  801679:	e8 43 fb ff ff       	call   8011c1 <sys_page_map>
  80167e:	89 c7                	mov    %eax,%edi
  801680:	83 c4 20             	add    $0x20,%esp
  801683:	85 c0                	test   %eax,%eax
  801685:	78 2e                	js     8016b5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801687:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80168a:	89 d0                	mov    %edx,%eax
  80168c:	c1 e8 0c             	shr    $0xc,%eax
  80168f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801696:	83 ec 0c             	sub    $0xc,%esp
  801699:	25 07 0e 00 00       	and    $0xe07,%eax
  80169e:	50                   	push   %eax
  80169f:	53                   	push   %ebx
  8016a0:	6a 00                	push   $0x0
  8016a2:	52                   	push   %edx
  8016a3:	6a 00                	push   $0x0
  8016a5:	e8 17 fb ff ff       	call   8011c1 <sys_page_map>
  8016aa:	89 c7                	mov    %eax,%edi
  8016ac:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016af:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016b1:	85 ff                	test   %edi,%edi
  8016b3:	79 1d                	jns    8016d2 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016b5:	83 ec 08             	sub    $0x8,%esp
  8016b8:	53                   	push   %ebx
  8016b9:	6a 00                	push   $0x0
  8016bb:	e8 43 fb ff ff       	call   801203 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016c0:	83 c4 08             	add    $0x8,%esp
  8016c3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016c6:	6a 00                	push   $0x0
  8016c8:	e8 36 fb ff ff       	call   801203 <sys_page_unmap>
	return r;
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	89 f8                	mov    %edi,%eax
}
  8016d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d5:	5b                   	pop    %ebx
  8016d6:	5e                   	pop    %esi
  8016d7:	5f                   	pop    %edi
  8016d8:	5d                   	pop    %ebp
  8016d9:	c3                   	ret    

008016da <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	53                   	push   %ebx
  8016de:	83 ec 14             	sub    $0x14,%esp
  8016e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e7:	50                   	push   %eax
  8016e8:	53                   	push   %ebx
  8016e9:	e8 86 fd ff ff       	call   801474 <fd_lookup>
  8016ee:	83 c4 08             	add    $0x8,%esp
  8016f1:	89 c2                	mov    %eax,%edx
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	78 6d                	js     801764 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f7:	83 ec 08             	sub    $0x8,%esp
  8016fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fd:	50                   	push   %eax
  8016fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801701:	ff 30                	pushl  (%eax)
  801703:	e8 c2 fd ff ff       	call   8014ca <dev_lookup>
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	85 c0                	test   %eax,%eax
  80170d:	78 4c                	js     80175b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80170f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801712:	8b 42 08             	mov    0x8(%edx),%eax
  801715:	83 e0 03             	and    $0x3,%eax
  801718:	83 f8 01             	cmp    $0x1,%eax
  80171b:	75 21                	jne    80173e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80171d:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  801722:	8b 40 48             	mov    0x48(%eax),%eax
  801725:	83 ec 04             	sub    $0x4,%esp
  801728:	53                   	push   %ebx
  801729:	50                   	push   %eax
  80172a:	68 d9 29 80 00       	push   $0x8029d9
  80172f:	e8 9c ef ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80173c:	eb 26                	jmp    801764 <read+0x8a>
	}
	if (!dev->dev_read)
  80173e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801741:	8b 40 08             	mov    0x8(%eax),%eax
  801744:	85 c0                	test   %eax,%eax
  801746:	74 17                	je     80175f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801748:	83 ec 04             	sub    $0x4,%esp
  80174b:	ff 75 10             	pushl  0x10(%ebp)
  80174e:	ff 75 0c             	pushl  0xc(%ebp)
  801751:	52                   	push   %edx
  801752:	ff d0                	call   *%eax
  801754:	89 c2                	mov    %eax,%edx
  801756:	83 c4 10             	add    $0x10,%esp
  801759:	eb 09                	jmp    801764 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175b:	89 c2                	mov    %eax,%edx
  80175d:	eb 05                	jmp    801764 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80175f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801764:	89 d0                	mov    %edx,%eax
  801766:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801769:	c9                   	leave  
  80176a:	c3                   	ret    

0080176b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	57                   	push   %edi
  80176f:	56                   	push   %esi
  801770:	53                   	push   %ebx
  801771:	83 ec 0c             	sub    $0xc,%esp
  801774:	8b 7d 08             	mov    0x8(%ebp),%edi
  801777:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80177a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80177f:	eb 21                	jmp    8017a2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801781:	83 ec 04             	sub    $0x4,%esp
  801784:	89 f0                	mov    %esi,%eax
  801786:	29 d8                	sub    %ebx,%eax
  801788:	50                   	push   %eax
  801789:	89 d8                	mov    %ebx,%eax
  80178b:	03 45 0c             	add    0xc(%ebp),%eax
  80178e:	50                   	push   %eax
  80178f:	57                   	push   %edi
  801790:	e8 45 ff ff ff       	call   8016da <read>
		if (m < 0)
  801795:	83 c4 10             	add    $0x10,%esp
  801798:	85 c0                	test   %eax,%eax
  80179a:	78 10                	js     8017ac <readn+0x41>
			return m;
		if (m == 0)
  80179c:	85 c0                	test   %eax,%eax
  80179e:	74 0a                	je     8017aa <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017a0:	01 c3                	add    %eax,%ebx
  8017a2:	39 f3                	cmp    %esi,%ebx
  8017a4:	72 db                	jb     801781 <readn+0x16>
  8017a6:	89 d8                	mov    %ebx,%eax
  8017a8:	eb 02                	jmp    8017ac <readn+0x41>
  8017aa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017af:	5b                   	pop    %ebx
  8017b0:	5e                   	pop    %esi
  8017b1:	5f                   	pop    %edi
  8017b2:	5d                   	pop    %ebp
  8017b3:	c3                   	ret    

008017b4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	53                   	push   %ebx
  8017b8:	83 ec 14             	sub    $0x14,%esp
  8017bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c1:	50                   	push   %eax
  8017c2:	53                   	push   %ebx
  8017c3:	e8 ac fc ff ff       	call   801474 <fd_lookup>
  8017c8:	83 c4 08             	add    $0x8,%esp
  8017cb:	89 c2                	mov    %eax,%edx
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	78 68                	js     801839 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d1:	83 ec 08             	sub    $0x8,%esp
  8017d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d7:	50                   	push   %eax
  8017d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017db:	ff 30                	pushl  (%eax)
  8017dd:	e8 e8 fc ff ff       	call   8014ca <dev_lookup>
  8017e2:	83 c4 10             	add    $0x10,%esp
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	78 47                	js     801830 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ec:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017f0:	75 21                	jne    801813 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017f2:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8017f7:	8b 40 48             	mov    0x48(%eax),%eax
  8017fa:	83 ec 04             	sub    $0x4,%esp
  8017fd:	53                   	push   %ebx
  8017fe:	50                   	push   %eax
  8017ff:	68 f5 29 80 00       	push   $0x8029f5
  801804:	e8 c7 ee ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801811:	eb 26                	jmp    801839 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801813:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801816:	8b 52 0c             	mov    0xc(%edx),%edx
  801819:	85 d2                	test   %edx,%edx
  80181b:	74 17                	je     801834 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80181d:	83 ec 04             	sub    $0x4,%esp
  801820:	ff 75 10             	pushl  0x10(%ebp)
  801823:	ff 75 0c             	pushl  0xc(%ebp)
  801826:	50                   	push   %eax
  801827:	ff d2                	call   *%edx
  801829:	89 c2                	mov    %eax,%edx
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	eb 09                	jmp    801839 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801830:	89 c2                	mov    %eax,%edx
  801832:	eb 05                	jmp    801839 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801834:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801839:	89 d0                	mov    %edx,%eax
  80183b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <seek>:

int
seek(int fdnum, off_t offset)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801846:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801849:	50                   	push   %eax
  80184a:	ff 75 08             	pushl  0x8(%ebp)
  80184d:	e8 22 fc ff ff       	call   801474 <fd_lookup>
  801852:	83 c4 08             	add    $0x8,%esp
  801855:	85 c0                	test   %eax,%eax
  801857:	78 0e                	js     801867 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801859:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80185c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80185f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801862:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801867:	c9                   	leave  
  801868:	c3                   	ret    

00801869 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	53                   	push   %ebx
  80186d:	83 ec 14             	sub    $0x14,%esp
  801870:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801873:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801876:	50                   	push   %eax
  801877:	53                   	push   %ebx
  801878:	e8 f7 fb ff ff       	call   801474 <fd_lookup>
  80187d:	83 c4 08             	add    $0x8,%esp
  801880:	89 c2                	mov    %eax,%edx
  801882:	85 c0                	test   %eax,%eax
  801884:	78 65                	js     8018eb <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801886:	83 ec 08             	sub    $0x8,%esp
  801889:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188c:	50                   	push   %eax
  80188d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801890:	ff 30                	pushl  (%eax)
  801892:	e8 33 fc ff ff       	call   8014ca <dev_lookup>
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	85 c0                	test   %eax,%eax
  80189c:	78 44                	js     8018e2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80189e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018a5:	75 21                	jne    8018c8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018a7:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018ac:	8b 40 48             	mov    0x48(%eax),%eax
  8018af:	83 ec 04             	sub    $0x4,%esp
  8018b2:	53                   	push   %ebx
  8018b3:	50                   	push   %eax
  8018b4:	68 b8 29 80 00       	push   $0x8029b8
  8018b9:	e8 12 ee ff ff       	call   8006d0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018c6:	eb 23                	jmp    8018eb <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018cb:	8b 52 18             	mov    0x18(%edx),%edx
  8018ce:	85 d2                	test   %edx,%edx
  8018d0:	74 14                	je     8018e6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018d2:	83 ec 08             	sub    $0x8,%esp
  8018d5:	ff 75 0c             	pushl  0xc(%ebp)
  8018d8:	50                   	push   %eax
  8018d9:	ff d2                	call   *%edx
  8018db:	89 c2                	mov    %eax,%edx
  8018dd:	83 c4 10             	add    $0x10,%esp
  8018e0:	eb 09                	jmp    8018eb <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e2:	89 c2                	mov    %eax,%edx
  8018e4:	eb 05                	jmp    8018eb <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018eb:	89 d0                	mov    %edx,%eax
  8018ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f0:	c9                   	leave  
  8018f1:	c3                   	ret    

008018f2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	53                   	push   %ebx
  8018f6:	83 ec 14             	sub    $0x14,%esp
  8018f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ff:	50                   	push   %eax
  801900:	ff 75 08             	pushl  0x8(%ebp)
  801903:	e8 6c fb ff ff       	call   801474 <fd_lookup>
  801908:	83 c4 08             	add    $0x8,%esp
  80190b:	89 c2                	mov    %eax,%edx
  80190d:	85 c0                	test   %eax,%eax
  80190f:	78 58                	js     801969 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801911:	83 ec 08             	sub    $0x8,%esp
  801914:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801917:	50                   	push   %eax
  801918:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191b:	ff 30                	pushl  (%eax)
  80191d:	e8 a8 fb ff ff       	call   8014ca <dev_lookup>
  801922:	83 c4 10             	add    $0x10,%esp
  801925:	85 c0                	test   %eax,%eax
  801927:	78 37                	js     801960 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801929:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801930:	74 32                	je     801964 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801932:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801935:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80193c:	00 00 00 
	stat->st_isdir = 0;
  80193f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801946:	00 00 00 
	stat->st_dev = dev;
  801949:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80194f:	83 ec 08             	sub    $0x8,%esp
  801952:	53                   	push   %ebx
  801953:	ff 75 f0             	pushl  -0x10(%ebp)
  801956:	ff 50 14             	call   *0x14(%eax)
  801959:	89 c2                	mov    %eax,%edx
  80195b:	83 c4 10             	add    $0x10,%esp
  80195e:	eb 09                	jmp    801969 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801960:	89 c2                	mov    %eax,%edx
  801962:	eb 05                	jmp    801969 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801964:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801969:	89 d0                	mov    %edx,%eax
  80196b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	56                   	push   %esi
  801974:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801975:	83 ec 08             	sub    $0x8,%esp
  801978:	6a 00                	push   $0x0
  80197a:	ff 75 08             	pushl  0x8(%ebp)
  80197d:	e8 2b 02 00 00       	call   801bad <open>
  801982:	89 c3                	mov    %eax,%ebx
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	85 c0                	test   %eax,%eax
  801989:	78 1b                	js     8019a6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80198b:	83 ec 08             	sub    $0x8,%esp
  80198e:	ff 75 0c             	pushl  0xc(%ebp)
  801991:	50                   	push   %eax
  801992:	e8 5b ff ff ff       	call   8018f2 <fstat>
  801997:	89 c6                	mov    %eax,%esi
	close(fd);
  801999:	89 1c 24             	mov    %ebx,(%esp)
  80199c:	e8 fd fb ff ff       	call   80159e <close>
	return r;
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	89 f0                	mov    %esi,%eax
}
  8019a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a9:	5b                   	pop    %ebx
  8019aa:	5e                   	pop    %esi
  8019ab:	5d                   	pop    %ebp
  8019ac:	c3                   	ret    

008019ad <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	56                   	push   %esi
  8019b1:	53                   	push   %ebx
  8019b2:	89 c6                	mov    %eax,%esi
  8019b4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019b6:	83 3d b0 40 80 00 00 	cmpl   $0x0,0x8040b0
  8019bd:	75 12                	jne    8019d1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019bf:	83 ec 0c             	sub    $0xc,%esp
  8019c2:	6a 01                	push   $0x1
  8019c4:	e8 26 08 00 00       	call   8021ef <ipc_find_env>
  8019c9:	a3 b0 40 80 00       	mov    %eax,0x8040b0
  8019ce:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019d1:	6a 07                	push   $0x7
  8019d3:	68 00 50 80 00       	push   $0x805000
  8019d8:	56                   	push   %esi
  8019d9:	ff 35 b0 40 80 00    	pushl  0x8040b0
  8019df:	e8 b5 07 00 00       	call   802199 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8019e4:	83 c4 0c             	add    $0xc,%esp
  8019e7:	6a 00                	push   $0x0
  8019e9:	53                   	push   %ebx
  8019ea:	6a 00                	push   $0x0
  8019ec:	e8 3f 07 00 00       	call   802130 <ipc_recv>
}
  8019f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f4:	5b                   	pop    %ebx
  8019f5:	5e                   	pop    %esi
  8019f6:	5d                   	pop    %ebp
  8019f7:	c3                   	ret    

008019f8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801a01:	8b 40 0c             	mov    0xc(%eax),%eax
  801a04:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a11:	ba 00 00 00 00       	mov    $0x0,%edx
  801a16:	b8 02 00 00 00       	mov    $0x2,%eax
  801a1b:	e8 8d ff ff ff       	call   8019ad <fsipc>
}
  801a20:	c9                   	leave  
  801a21:	c3                   	ret    

00801a22 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a28:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a2e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a33:	ba 00 00 00 00       	mov    $0x0,%edx
  801a38:	b8 06 00 00 00       	mov    $0x6,%eax
  801a3d:	e8 6b ff ff ff       	call   8019ad <fsipc>
}
  801a42:	c9                   	leave  
  801a43:	c3                   	ret    

00801a44 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	53                   	push   %ebx
  801a48:	83 ec 04             	sub    $0x4,%esp
  801a4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a51:	8b 40 0c             	mov    0xc(%eax),%eax
  801a54:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a59:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5e:	b8 05 00 00 00       	mov    $0x5,%eax
  801a63:	e8 45 ff ff ff       	call   8019ad <fsipc>
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	78 2c                	js     801a98 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a6c:	83 ec 08             	sub    $0x8,%esp
  801a6f:	68 00 50 80 00       	push   $0x805000
  801a74:	53                   	push   %ebx
  801a75:	e8 8a f2 ff ff       	call   800d04 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a7a:	a1 80 50 80 00       	mov    0x805080,%eax
  801a7f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a85:	a1 84 50 80 00       	mov    0x805084,%eax
  801a8a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	53                   	push   %ebx
  801aa1:	83 ec 08             	sub    $0x8,%esp
  801aa4:	8b 45 10             	mov    0x10(%ebp),%eax
  801aa7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801aac:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801ab1:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab7:	8b 40 0c             	mov    0xc(%eax),%eax
  801aba:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801abf:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801ac5:	53                   	push   %ebx
  801ac6:	ff 75 0c             	pushl  0xc(%ebp)
  801ac9:	68 08 50 80 00       	push   $0x805008
  801ace:	e8 c3 f3 ff ff       	call   800e96 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801ad3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad8:	b8 04 00 00 00       	mov    $0x4,%eax
  801add:	e8 cb fe ff ff       	call   8019ad <fsipc>
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	78 3d                	js     801b26 <devfile_write+0x89>
		return r;

	assert(r <= n);
  801ae9:	39 d8                	cmp    %ebx,%eax
  801aeb:	76 19                	jbe    801b06 <devfile_write+0x69>
  801aed:	68 24 2a 80 00       	push   $0x802a24
  801af2:	68 2b 2a 80 00       	push   $0x802a2b
  801af7:	68 9f 00 00 00       	push   $0x9f
  801afc:	68 40 2a 80 00       	push   $0x802a40
  801b01:	e8 f1 ea ff ff       	call   8005f7 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  801b06:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b0b:	76 19                	jbe    801b26 <devfile_write+0x89>
  801b0d:	68 58 2a 80 00       	push   $0x802a58
  801b12:	68 2b 2a 80 00       	push   $0x802a2b
  801b17:	68 a0 00 00 00       	push   $0xa0
  801b1c:	68 40 2a 80 00       	push   $0x802a40
  801b21:	e8 d1 ea ff ff       	call   8005f7 <_panic>

	return r;
}
  801b26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	56                   	push   %esi
  801b2f:	53                   	push   %ebx
  801b30:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b33:	8b 45 08             	mov    0x8(%ebp),%eax
  801b36:	8b 40 0c             	mov    0xc(%eax),%eax
  801b39:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b3e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b44:	ba 00 00 00 00       	mov    $0x0,%edx
  801b49:	b8 03 00 00 00       	mov    $0x3,%eax
  801b4e:	e8 5a fe ff ff       	call   8019ad <fsipc>
  801b53:	89 c3                	mov    %eax,%ebx
  801b55:	85 c0                	test   %eax,%eax
  801b57:	78 4b                	js     801ba4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b59:	39 c6                	cmp    %eax,%esi
  801b5b:	73 16                	jae    801b73 <devfile_read+0x48>
  801b5d:	68 24 2a 80 00       	push   $0x802a24
  801b62:	68 2b 2a 80 00       	push   $0x802a2b
  801b67:	6a 7e                	push   $0x7e
  801b69:	68 40 2a 80 00       	push   $0x802a40
  801b6e:	e8 84 ea ff ff       	call   8005f7 <_panic>
	assert(r <= PGSIZE);
  801b73:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b78:	7e 16                	jle    801b90 <devfile_read+0x65>
  801b7a:	68 4b 2a 80 00       	push   $0x802a4b
  801b7f:	68 2b 2a 80 00       	push   $0x802a2b
  801b84:	6a 7f                	push   $0x7f
  801b86:	68 40 2a 80 00       	push   $0x802a40
  801b8b:	e8 67 ea ff ff       	call   8005f7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b90:	83 ec 04             	sub    $0x4,%esp
  801b93:	50                   	push   %eax
  801b94:	68 00 50 80 00       	push   $0x805000
  801b99:	ff 75 0c             	pushl  0xc(%ebp)
  801b9c:	e8 f5 f2 ff ff       	call   800e96 <memmove>
	return r;
  801ba1:	83 c4 10             	add    $0x10,%esp
}
  801ba4:	89 d8                	mov    %ebx,%eax
  801ba6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba9:	5b                   	pop    %ebx
  801baa:	5e                   	pop    %esi
  801bab:	5d                   	pop    %ebp
  801bac:	c3                   	ret    

00801bad <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	53                   	push   %ebx
  801bb1:	83 ec 20             	sub    $0x20,%esp
  801bb4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bb7:	53                   	push   %ebx
  801bb8:	e8 0e f1 ff ff       	call   800ccb <strlen>
  801bbd:	83 c4 10             	add    $0x10,%esp
  801bc0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bc5:	7f 67                	jg     801c2e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bc7:	83 ec 0c             	sub    $0xc,%esp
  801bca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bcd:	50                   	push   %eax
  801bce:	e8 52 f8 ff ff       	call   801425 <fd_alloc>
  801bd3:	83 c4 10             	add    $0x10,%esp
		return r;
  801bd6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	78 57                	js     801c33 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bdc:	83 ec 08             	sub    $0x8,%esp
  801bdf:	53                   	push   %ebx
  801be0:	68 00 50 80 00       	push   $0x805000
  801be5:	e8 1a f1 ff ff       	call   800d04 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bea:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bed:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bf2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bf5:	b8 01 00 00 00       	mov    $0x1,%eax
  801bfa:	e8 ae fd ff ff       	call   8019ad <fsipc>
  801bff:	89 c3                	mov    %eax,%ebx
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	85 c0                	test   %eax,%eax
  801c06:	79 14                	jns    801c1c <open+0x6f>
		fd_close(fd, 0);
  801c08:	83 ec 08             	sub    $0x8,%esp
  801c0b:	6a 00                	push   $0x0
  801c0d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c10:	e8 08 f9 ff ff       	call   80151d <fd_close>
		return r;
  801c15:	83 c4 10             	add    $0x10,%esp
  801c18:	89 da                	mov    %ebx,%edx
  801c1a:	eb 17                	jmp    801c33 <open+0x86>
	}

	return fd2num(fd);
  801c1c:	83 ec 0c             	sub    $0xc,%esp
  801c1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c22:	e8 d7 f7 ff ff       	call   8013fe <fd2num>
  801c27:	89 c2                	mov    %eax,%edx
  801c29:	83 c4 10             	add    $0x10,%esp
  801c2c:	eb 05                	jmp    801c33 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c2e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c33:	89 d0                	mov    %edx,%eax
  801c35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    

00801c3a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c40:	ba 00 00 00 00       	mov    $0x0,%edx
  801c45:	b8 08 00 00 00       	mov    $0x8,%eax
  801c4a:	e8 5e fd ff ff       	call   8019ad <fsipc>
}
  801c4f:	c9                   	leave  
  801c50:	c3                   	ret    

00801c51 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	56                   	push   %esi
  801c55:	53                   	push   %ebx
  801c56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c59:	83 ec 0c             	sub    $0xc,%esp
  801c5c:	ff 75 08             	pushl  0x8(%ebp)
  801c5f:	e8 aa f7 ff ff       	call   80140e <fd2data>
  801c64:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c66:	83 c4 08             	add    $0x8,%esp
  801c69:	68 85 2a 80 00       	push   $0x802a85
  801c6e:	53                   	push   %ebx
  801c6f:	e8 90 f0 ff ff       	call   800d04 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c74:	8b 46 04             	mov    0x4(%esi),%eax
  801c77:	2b 06                	sub    (%esi),%eax
  801c79:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c7f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c86:	00 00 00 
	stat->st_dev = &devpipe;
  801c89:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c90:	30 80 00 
	return 0;
}
  801c93:	b8 00 00 00 00       	mov    $0x0,%eax
  801c98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c9b:	5b                   	pop    %ebx
  801c9c:	5e                   	pop    %esi
  801c9d:	5d                   	pop    %ebp
  801c9e:	c3                   	ret    

00801c9f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	53                   	push   %ebx
  801ca3:	83 ec 0c             	sub    $0xc,%esp
  801ca6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ca9:	53                   	push   %ebx
  801caa:	6a 00                	push   $0x0
  801cac:	e8 52 f5 ff ff       	call   801203 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cb1:	89 1c 24             	mov    %ebx,(%esp)
  801cb4:	e8 55 f7 ff ff       	call   80140e <fd2data>
  801cb9:	83 c4 08             	add    $0x8,%esp
  801cbc:	50                   	push   %eax
  801cbd:	6a 00                	push   $0x0
  801cbf:	e8 3f f5 ff ff       	call   801203 <sys_page_unmap>
}
  801cc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc7:	c9                   	leave  
  801cc8:	c3                   	ret    

00801cc9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	57                   	push   %edi
  801ccd:	56                   	push   %esi
  801cce:	53                   	push   %ebx
  801ccf:	83 ec 1c             	sub    $0x1c,%esp
  801cd2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cd5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cd7:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  801cdc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801cdf:	83 ec 0c             	sub    $0xc,%esp
  801ce2:	ff 75 e0             	pushl  -0x20(%ebp)
  801ce5:	e8 3e 05 00 00       	call   802228 <pageref>
  801cea:	89 c3                	mov    %eax,%ebx
  801cec:	89 3c 24             	mov    %edi,(%esp)
  801cef:	e8 34 05 00 00       	call   802228 <pageref>
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	39 c3                	cmp    %eax,%ebx
  801cf9:	0f 94 c1             	sete   %cl
  801cfc:	0f b6 c9             	movzbl %cl,%ecx
  801cff:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d02:	8b 15 b4 40 80 00    	mov    0x8040b4,%edx
  801d08:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d0b:	39 ce                	cmp    %ecx,%esi
  801d0d:	74 1b                	je     801d2a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d0f:	39 c3                	cmp    %eax,%ebx
  801d11:	75 c4                	jne    801cd7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d13:	8b 42 58             	mov    0x58(%edx),%eax
  801d16:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d19:	50                   	push   %eax
  801d1a:	56                   	push   %esi
  801d1b:	68 8c 2a 80 00       	push   $0x802a8c
  801d20:	e8 ab e9 ff ff       	call   8006d0 <cprintf>
  801d25:	83 c4 10             	add    $0x10,%esp
  801d28:	eb ad                	jmp    801cd7 <_pipeisclosed+0xe>
	}
}
  801d2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d30:	5b                   	pop    %ebx
  801d31:	5e                   	pop    %esi
  801d32:	5f                   	pop    %edi
  801d33:	5d                   	pop    %ebp
  801d34:	c3                   	ret    

00801d35 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	57                   	push   %edi
  801d39:	56                   	push   %esi
  801d3a:	53                   	push   %ebx
  801d3b:	83 ec 28             	sub    $0x28,%esp
  801d3e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d41:	56                   	push   %esi
  801d42:	e8 c7 f6 ff ff       	call   80140e <fd2data>
  801d47:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d49:	83 c4 10             	add    $0x10,%esp
  801d4c:	bf 00 00 00 00       	mov    $0x0,%edi
  801d51:	eb 4b                	jmp    801d9e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d53:	89 da                	mov    %ebx,%edx
  801d55:	89 f0                	mov    %esi,%eax
  801d57:	e8 6d ff ff ff       	call   801cc9 <_pipeisclosed>
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	75 48                	jne    801da8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d60:	e8 fa f3 ff ff       	call   80115f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d65:	8b 43 04             	mov    0x4(%ebx),%eax
  801d68:	8b 0b                	mov    (%ebx),%ecx
  801d6a:	8d 51 20             	lea    0x20(%ecx),%edx
  801d6d:	39 d0                	cmp    %edx,%eax
  801d6f:	73 e2                	jae    801d53 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d74:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d78:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d7b:	89 c2                	mov    %eax,%edx
  801d7d:	c1 fa 1f             	sar    $0x1f,%edx
  801d80:	89 d1                	mov    %edx,%ecx
  801d82:	c1 e9 1b             	shr    $0x1b,%ecx
  801d85:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d88:	83 e2 1f             	and    $0x1f,%edx
  801d8b:	29 ca                	sub    %ecx,%edx
  801d8d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d91:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d95:	83 c0 01             	add    $0x1,%eax
  801d98:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d9b:	83 c7 01             	add    $0x1,%edi
  801d9e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801da1:	75 c2                	jne    801d65 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801da3:	8b 45 10             	mov    0x10(%ebp),%eax
  801da6:	eb 05                	jmp    801dad <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801da8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db0:	5b                   	pop    %ebx
  801db1:	5e                   	pop    %esi
  801db2:	5f                   	pop    %edi
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    

00801db5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	57                   	push   %edi
  801db9:	56                   	push   %esi
  801dba:	53                   	push   %ebx
  801dbb:	83 ec 18             	sub    $0x18,%esp
  801dbe:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dc1:	57                   	push   %edi
  801dc2:	e8 47 f6 ff ff       	call   80140e <fd2data>
  801dc7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dc9:	83 c4 10             	add    $0x10,%esp
  801dcc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dd1:	eb 3d                	jmp    801e10 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dd3:	85 db                	test   %ebx,%ebx
  801dd5:	74 04                	je     801ddb <devpipe_read+0x26>
				return i;
  801dd7:	89 d8                	mov    %ebx,%eax
  801dd9:	eb 44                	jmp    801e1f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ddb:	89 f2                	mov    %esi,%edx
  801ddd:	89 f8                	mov    %edi,%eax
  801ddf:	e8 e5 fe ff ff       	call   801cc9 <_pipeisclosed>
  801de4:	85 c0                	test   %eax,%eax
  801de6:	75 32                	jne    801e1a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801de8:	e8 72 f3 ff ff       	call   80115f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ded:	8b 06                	mov    (%esi),%eax
  801def:	3b 46 04             	cmp    0x4(%esi),%eax
  801df2:	74 df                	je     801dd3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801df4:	99                   	cltd   
  801df5:	c1 ea 1b             	shr    $0x1b,%edx
  801df8:	01 d0                	add    %edx,%eax
  801dfa:	83 e0 1f             	and    $0x1f,%eax
  801dfd:	29 d0                	sub    %edx,%eax
  801dff:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e07:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e0a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e0d:	83 c3 01             	add    $0x1,%ebx
  801e10:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e13:	75 d8                	jne    801ded <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e15:	8b 45 10             	mov    0x10(%ebp),%eax
  801e18:	eb 05                	jmp    801e1f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e1a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e22:	5b                   	pop    %ebx
  801e23:	5e                   	pop    %esi
  801e24:	5f                   	pop    %edi
  801e25:	5d                   	pop    %ebp
  801e26:	c3                   	ret    

00801e27 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
  801e2a:	56                   	push   %esi
  801e2b:	53                   	push   %ebx
  801e2c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e32:	50                   	push   %eax
  801e33:	e8 ed f5 ff ff       	call   801425 <fd_alloc>
  801e38:	83 c4 10             	add    $0x10,%esp
  801e3b:	89 c2                	mov    %eax,%edx
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	0f 88 2c 01 00 00    	js     801f71 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e45:	83 ec 04             	sub    $0x4,%esp
  801e48:	68 07 04 00 00       	push   $0x407
  801e4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e50:	6a 00                	push   $0x0
  801e52:	e8 27 f3 ff ff       	call   80117e <sys_page_alloc>
  801e57:	83 c4 10             	add    $0x10,%esp
  801e5a:	89 c2                	mov    %eax,%edx
  801e5c:	85 c0                	test   %eax,%eax
  801e5e:	0f 88 0d 01 00 00    	js     801f71 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e64:	83 ec 0c             	sub    $0xc,%esp
  801e67:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e6a:	50                   	push   %eax
  801e6b:	e8 b5 f5 ff ff       	call   801425 <fd_alloc>
  801e70:	89 c3                	mov    %eax,%ebx
  801e72:	83 c4 10             	add    $0x10,%esp
  801e75:	85 c0                	test   %eax,%eax
  801e77:	0f 88 e2 00 00 00    	js     801f5f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e7d:	83 ec 04             	sub    $0x4,%esp
  801e80:	68 07 04 00 00       	push   $0x407
  801e85:	ff 75 f0             	pushl  -0x10(%ebp)
  801e88:	6a 00                	push   $0x0
  801e8a:	e8 ef f2 ff ff       	call   80117e <sys_page_alloc>
  801e8f:	89 c3                	mov    %eax,%ebx
  801e91:	83 c4 10             	add    $0x10,%esp
  801e94:	85 c0                	test   %eax,%eax
  801e96:	0f 88 c3 00 00 00    	js     801f5f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e9c:	83 ec 0c             	sub    $0xc,%esp
  801e9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea2:	e8 67 f5 ff ff       	call   80140e <fd2data>
  801ea7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea9:	83 c4 0c             	add    $0xc,%esp
  801eac:	68 07 04 00 00       	push   $0x407
  801eb1:	50                   	push   %eax
  801eb2:	6a 00                	push   $0x0
  801eb4:	e8 c5 f2 ff ff       	call   80117e <sys_page_alloc>
  801eb9:	89 c3                	mov    %eax,%ebx
  801ebb:	83 c4 10             	add    $0x10,%esp
  801ebe:	85 c0                	test   %eax,%eax
  801ec0:	0f 88 89 00 00 00    	js     801f4f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec6:	83 ec 0c             	sub    $0xc,%esp
  801ec9:	ff 75 f0             	pushl  -0x10(%ebp)
  801ecc:	e8 3d f5 ff ff       	call   80140e <fd2data>
  801ed1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ed8:	50                   	push   %eax
  801ed9:	6a 00                	push   $0x0
  801edb:	56                   	push   %esi
  801edc:	6a 00                	push   $0x0
  801ede:	e8 de f2 ff ff       	call   8011c1 <sys_page_map>
  801ee3:	89 c3                	mov    %eax,%ebx
  801ee5:	83 c4 20             	add    $0x20,%esp
  801ee8:	85 c0                	test   %eax,%eax
  801eea:	78 55                	js     801f41 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801eec:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f01:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f0a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f0f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f16:	83 ec 0c             	sub    $0xc,%esp
  801f19:	ff 75 f4             	pushl  -0xc(%ebp)
  801f1c:	e8 dd f4 ff ff       	call   8013fe <fd2num>
  801f21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f24:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f26:	83 c4 04             	add    $0x4,%esp
  801f29:	ff 75 f0             	pushl  -0x10(%ebp)
  801f2c:	e8 cd f4 ff ff       	call   8013fe <fd2num>
  801f31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f34:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f37:	83 c4 10             	add    $0x10,%esp
  801f3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801f3f:	eb 30                	jmp    801f71 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f41:	83 ec 08             	sub    $0x8,%esp
  801f44:	56                   	push   %esi
  801f45:	6a 00                	push   $0x0
  801f47:	e8 b7 f2 ff ff       	call   801203 <sys_page_unmap>
  801f4c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f4f:	83 ec 08             	sub    $0x8,%esp
  801f52:	ff 75 f0             	pushl  -0x10(%ebp)
  801f55:	6a 00                	push   $0x0
  801f57:	e8 a7 f2 ff ff       	call   801203 <sys_page_unmap>
  801f5c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f5f:	83 ec 08             	sub    $0x8,%esp
  801f62:	ff 75 f4             	pushl  -0xc(%ebp)
  801f65:	6a 00                	push   $0x0
  801f67:	e8 97 f2 ff ff       	call   801203 <sys_page_unmap>
  801f6c:	83 c4 10             	add    $0x10,%esp
  801f6f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f71:	89 d0                	mov    %edx,%eax
  801f73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f76:	5b                   	pop    %ebx
  801f77:	5e                   	pop    %esi
  801f78:	5d                   	pop    %ebp
  801f79:	c3                   	ret    

00801f7a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f83:	50                   	push   %eax
  801f84:	ff 75 08             	pushl  0x8(%ebp)
  801f87:	e8 e8 f4 ff ff       	call   801474 <fd_lookup>
  801f8c:	83 c4 10             	add    $0x10,%esp
  801f8f:	85 c0                	test   %eax,%eax
  801f91:	78 18                	js     801fab <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f93:	83 ec 0c             	sub    $0xc,%esp
  801f96:	ff 75 f4             	pushl  -0xc(%ebp)
  801f99:	e8 70 f4 ff ff       	call   80140e <fd2data>
	return _pipeisclosed(fd, p);
  801f9e:	89 c2                	mov    %eax,%edx
  801fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa3:	e8 21 fd ff ff       	call   801cc9 <_pipeisclosed>
  801fa8:	83 c4 10             	add    $0x10,%esp
}
  801fab:	c9                   	leave  
  801fac:	c3                   	ret    

00801fad <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fad:	55                   	push   %ebp
  801fae:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fb0:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb5:	5d                   	pop    %ebp
  801fb6:	c3                   	ret    

00801fb7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fbd:	68 a4 2a 80 00       	push   $0x802aa4
  801fc2:	ff 75 0c             	pushl  0xc(%ebp)
  801fc5:	e8 3a ed ff ff       	call   800d04 <strcpy>
	return 0;
}
  801fca:	b8 00 00 00 00       	mov    $0x0,%eax
  801fcf:	c9                   	leave  
  801fd0:	c3                   	ret    

00801fd1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fd1:	55                   	push   %ebp
  801fd2:	89 e5                	mov    %esp,%ebp
  801fd4:	57                   	push   %edi
  801fd5:	56                   	push   %esi
  801fd6:	53                   	push   %ebx
  801fd7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fdd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fe2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fe8:	eb 2d                	jmp    802017 <devcons_write+0x46>
		m = n - tot;
  801fea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fed:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fef:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ff2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ff7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ffa:	83 ec 04             	sub    $0x4,%esp
  801ffd:	53                   	push   %ebx
  801ffe:	03 45 0c             	add    0xc(%ebp),%eax
  802001:	50                   	push   %eax
  802002:	57                   	push   %edi
  802003:	e8 8e ee ff ff       	call   800e96 <memmove>
		sys_cputs(buf, m);
  802008:	83 c4 08             	add    $0x8,%esp
  80200b:	53                   	push   %ebx
  80200c:	57                   	push   %edi
  80200d:	e8 b0 f0 ff ff       	call   8010c2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802012:	01 de                	add    %ebx,%esi
  802014:	83 c4 10             	add    $0x10,%esp
  802017:	89 f0                	mov    %esi,%eax
  802019:	3b 75 10             	cmp    0x10(%ebp),%esi
  80201c:	72 cc                	jb     801fea <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80201e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802021:	5b                   	pop    %ebx
  802022:	5e                   	pop    %esi
  802023:	5f                   	pop    %edi
  802024:	5d                   	pop    %ebp
  802025:	c3                   	ret    

00802026 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802026:	55                   	push   %ebp
  802027:	89 e5                	mov    %esp,%ebp
  802029:	83 ec 08             	sub    $0x8,%esp
  80202c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802031:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802035:	74 2a                	je     802061 <devcons_read+0x3b>
  802037:	eb 05                	jmp    80203e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802039:	e8 21 f1 ff ff       	call   80115f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80203e:	e8 9d f0 ff ff       	call   8010e0 <sys_cgetc>
  802043:	85 c0                	test   %eax,%eax
  802045:	74 f2                	je     802039 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802047:	85 c0                	test   %eax,%eax
  802049:	78 16                	js     802061 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80204b:	83 f8 04             	cmp    $0x4,%eax
  80204e:	74 0c                	je     80205c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802050:	8b 55 0c             	mov    0xc(%ebp),%edx
  802053:	88 02                	mov    %al,(%edx)
	return 1;
  802055:	b8 01 00 00 00       	mov    $0x1,%eax
  80205a:	eb 05                	jmp    802061 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80205c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802061:	c9                   	leave  
  802062:	c3                   	ret    

00802063 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802063:	55                   	push   %ebp
  802064:	89 e5                	mov    %esp,%ebp
  802066:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802069:	8b 45 08             	mov    0x8(%ebp),%eax
  80206c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80206f:	6a 01                	push   $0x1
  802071:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802074:	50                   	push   %eax
  802075:	e8 48 f0 ff ff       	call   8010c2 <sys_cputs>
}
  80207a:	83 c4 10             	add    $0x10,%esp
  80207d:	c9                   	leave  
  80207e:	c3                   	ret    

0080207f <getchar>:

int
getchar(void)
{
  80207f:	55                   	push   %ebp
  802080:	89 e5                	mov    %esp,%ebp
  802082:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802085:	6a 01                	push   $0x1
  802087:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80208a:	50                   	push   %eax
  80208b:	6a 00                	push   $0x0
  80208d:	e8 48 f6 ff ff       	call   8016da <read>
	if (r < 0)
  802092:	83 c4 10             	add    $0x10,%esp
  802095:	85 c0                	test   %eax,%eax
  802097:	78 0f                	js     8020a8 <getchar+0x29>
		return r;
	if (r < 1)
  802099:	85 c0                	test   %eax,%eax
  80209b:	7e 06                	jle    8020a3 <getchar+0x24>
		return -E_EOF;
	return c;
  80209d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020a1:	eb 05                	jmp    8020a8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020a3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020a8:	c9                   	leave  
  8020a9:	c3                   	ret    

008020aa <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020aa:	55                   	push   %ebp
  8020ab:	89 e5                	mov    %esp,%ebp
  8020ad:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b3:	50                   	push   %eax
  8020b4:	ff 75 08             	pushl  0x8(%ebp)
  8020b7:	e8 b8 f3 ff ff       	call   801474 <fd_lookup>
  8020bc:	83 c4 10             	add    $0x10,%esp
  8020bf:	85 c0                	test   %eax,%eax
  8020c1:	78 11                	js     8020d4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020cc:	39 10                	cmp    %edx,(%eax)
  8020ce:	0f 94 c0             	sete   %al
  8020d1:	0f b6 c0             	movzbl %al,%eax
}
  8020d4:	c9                   	leave  
  8020d5:	c3                   	ret    

008020d6 <opencons>:

int
opencons(void)
{
  8020d6:	55                   	push   %ebp
  8020d7:	89 e5                	mov    %esp,%ebp
  8020d9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020df:	50                   	push   %eax
  8020e0:	e8 40 f3 ff ff       	call   801425 <fd_alloc>
  8020e5:	83 c4 10             	add    $0x10,%esp
		return r;
  8020e8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020ea:	85 c0                	test   %eax,%eax
  8020ec:	78 3e                	js     80212c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020ee:	83 ec 04             	sub    $0x4,%esp
  8020f1:	68 07 04 00 00       	push   $0x407
  8020f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8020f9:	6a 00                	push   $0x0
  8020fb:	e8 7e f0 ff ff       	call   80117e <sys_page_alloc>
  802100:	83 c4 10             	add    $0x10,%esp
		return r;
  802103:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802105:	85 c0                	test   %eax,%eax
  802107:	78 23                	js     80212c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802109:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80210f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802112:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802114:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802117:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80211e:	83 ec 0c             	sub    $0xc,%esp
  802121:	50                   	push   %eax
  802122:	e8 d7 f2 ff ff       	call   8013fe <fd2num>
  802127:	89 c2                	mov    %eax,%edx
  802129:	83 c4 10             	add    $0x10,%esp
}
  80212c:	89 d0                	mov    %edx,%eax
  80212e:	c9                   	leave  
  80212f:	c3                   	ret    

00802130 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	56                   	push   %esi
  802134:	53                   	push   %ebx
  802135:	8b 75 08             	mov    0x8(%ebp),%esi
  802138:	8b 45 0c             	mov    0xc(%ebp),%eax
  80213b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  80213e:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802140:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802145:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  802148:	83 ec 0c             	sub    $0xc,%esp
  80214b:	50                   	push   %eax
  80214c:	e8 dd f1 ff ff       	call   80132e <sys_ipc_recv>
  802151:	83 c4 10             	add    $0x10,%esp
  802154:	85 c0                	test   %eax,%eax
  802156:	79 16                	jns    80216e <ipc_recv+0x3e>
		if(from_env_store != NULL)
  802158:	85 f6                	test   %esi,%esi
  80215a:	74 06                	je     802162 <ipc_recv+0x32>
			*from_env_store = 0;
  80215c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  802162:	85 db                	test   %ebx,%ebx
  802164:	74 2c                	je     802192 <ipc_recv+0x62>
			*perm_store = 0;
  802166:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80216c:	eb 24                	jmp    802192 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  80216e:	85 f6                	test   %esi,%esi
  802170:	74 0a                	je     80217c <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  802172:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  802177:	8b 40 74             	mov    0x74(%eax),%eax
  80217a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80217c:	85 db                	test   %ebx,%ebx
  80217e:	74 0a                	je     80218a <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  802180:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  802185:	8b 40 78             	mov    0x78(%eax),%eax
  802188:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  80218a:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  80218f:	8b 40 70             	mov    0x70(%eax),%eax
}
  802192:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802195:	5b                   	pop    %ebx
  802196:	5e                   	pop    %esi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    

00802199 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802199:	55                   	push   %ebp
  80219a:	89 e5                	mov    %esp,%ebp
  80219c:	57                   	push   %edi
  80219d:	56                   	push   %esi
  80219e:	53                   	push   %ebx
  80219f:	83 ec 0c             	sub    $0xc,%esp
  8021a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8021ab:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8021ad:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8021b2:	0f 44 d8             	cmove  %eax,%ebx
  8021b5:	eb 1e                	jmp    8021d5 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  8021b7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021ba:	74 14                	je     8021d0 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  8021bc:	83 ec 04             	sub    $0x4,%esp
  8021bf:	68 b0 2a 80 00       	push   $0x802ab0
  8021c4:	6a 44                	push   $0x44
  8021c6:	68 dc 2a 80 00       	push   $0x802adc
  8021cb:	e8 27 e4 ff ff       	call   8005f7 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  8021d0:	e8 8a ef ff ff       	call   80115f <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8021d5:	ff 75 14             	pushl  0x14(%ebp)
  8021d8:	53                   	push   %ebx
  8021d9:	56                   	push   %esi
  8021da:	57                   	push   %edi
  8021db:	e8 2b f1 ff ff       	call   80130b <sys_ipc_try_send>
  8021e0:	83 c4 10             	add    $0x10,%esp
  8021e3:	85 c0                	test   %eax,%eax
  8021e5:	78 d0                	js     8021b7 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  8021e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021ea:	5b                   	pop    %ebx
  8021eb:	5e                   	pop    %esi
  8021ec:	5f                   	pop    %edi
  8021ed:	5d                   	pop    %ebp
  8021ee:	c3                   	ret    

008021ef <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021ef:	55                   	push   %ebp
  8021f0:	89 e5                	mov    %esp,%ebp
  8021f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021f5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021fa:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8021fd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802203:	8b 52 50             	mov    0x50(%edx),%edx
  802206:	39 ca                	cmp    %ecx,%edx
  802208:	75 0d                	jne    802217 <ipc_find_env+0x28>
			return envs[i].env_id;
  80220a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80220d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802212:	8b 40 48             	mov    0x48(%eax),%eax
  802215:	eb 0f                	jmp    802226 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802217:	83 c0 01             	add    $0x1,%eax
  80221a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80221f:	75 d9                	jne    8021fa <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802221:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802226:	5d                   	pop    %ebp
  802227:	c3                   	ret    

00802228 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802228:	55                   	push   %ebp
  802229:	89 e5                	mov    %esp,%ebp
  80222b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80222e:	89 d0                	mov    %edx,%eax
  802230:	c1 e8 16             	shr    $0x16,%eax
  802233:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80223a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80223f:	f6 c1 01             	test   $0x1,%cl
  802242:	74 1d                	je     802261 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802244:	c1 ea 0c             	shr    $0xc,%edx
  802247:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80224e:	f6 c2 01             	test   $0x1,%dl
  802251:	74 0e                	je     802261 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802253:	c1 ea 0c             	shr    $0xc,%edx
  802256:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80225d:	ef 
  80225e:	0f b7 c0             	movzwl %ax,%eax
}
  802261:	5d                   	pop    %ebp
  802262:	c3                   	ret    
  802263:	66 90                	xchg   %ax,%ax
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
